/******************************************************************************
*
 bgg* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include <stdlib.h>
#include "platform.h"

#include "xuartps.h"
#include "xparameters.h"

#include "xaxicdma.h"
#include "sleep.h"
#include "xil_printf.h"

#include "xscutimer.h"
#include "xscugic.h"


#include "command.h"
#include "pixel_data.h"


XAxiCdma_Config *axi_cdma_cfg;
XAxiCdma axi_cdma;

XUartPs_Config *Config;
XUartPs USB_uart;
XUartPs WIFI_uart;

XGpio gpio;

XScuTimer TimerInstance;	/* Cortex A9 Scu Private Timer Instance */
XScuGic IntcInstance;		/* Interrupt Controller Instance */

int driverControl;

#define BRAM_SETUP 0xC0000000
#define BRAM_LAYER_1 0xC2000000

long setup_bram();
long setup_uart();
long setup_interrupts();

void transfer(UINTPTR source, UINTPTR dest, int length);
void next_section();
void init_control();

static int current_theta = 0;

int main()
{
	init_platform();
	setup_uart();
	printf("--------------Initializing-----------------\n\r");
	printf("\t-GPIO\n\r");
	XGpio_Initialize(&gpio, 0);
	XGpio_SetDataDirection(&gpio, 2, 0x1);

	printf("\t-BRAM\n\r");
    if(setup_bram() == XST_FAILURE)
    {
    	return XST_FAILURE;
    }

	printf("\t-DRIVER\n\r");
	init_control();

	printf("\t-BUFFER\n\r");

	for(int i = 0; i < 10; i++)
	{
		frame_buffer[i] = (Frame*)calloc(1, sizeof(Frame));
		if(frame_buffer[i] == NULL)
			print("Dude wtf\n\r");
	}

	printf("\t-INTERRUPTS\n\r");
	setup_interrupts();

	printf("--------------DONE------------------------\n\r");

	while(1)
	{

		int count = XUartPs_Recv(&USB_uart, (u8*)buffer, 1);

		if(count == 1)
		{
			SerialFrame frame;
			printf("Received Command: %c\r\n", buffer[0]);

			switch(buffer[0])
			{
				case CLEAR_FRAME :

					break;
				case DRAW_FRAME :
					frame = receive_frame(&USB_uart, &USB_uart);
					package_frame(frame);
					free(frame.pixels);
					break;
				default:
					printf("\t-Unknown Command\r\n");
			}
		}

		//render();
	}


    cleanup_platform();
    return 0;
}

void hallSensor(void *CallBackRef)
{
	//XGpio_InterruptDisable(&gpio, XGPIO_IR_CH2_MASK);
	XScuTimer_Stop(&TimerInstance);
	current_theta = 0;
	static int count = 0;

	if(0x1 & XGpio_DiscreteRead(&gpio, 2))
	{
		printf("Magnet Count: %d\n\r", count);
		count++;
	}

	//In future, only increment this on the full revolution
	if(!((currentFrame == 9 && nextFrameToWrite == 0) || (currentFrame + 1 == nextFrameToWrite)))
	{
		if(currentFrame == 9)
			currentFrame = 0;
		else
			currentFrame++;
	}

	XScuTimer_LoadTimer(&TimerInstance, 162500000);

	/*
	 * Start the timer counter and then wait for it
	 * to timeout a number of times.
	 */
	XScuTimer_Start(&TimerInstance);


	XGpio_InterruptClear(&gpio, XGPIO_IR_CH2_MASK);
}

void render(void *CallBackRef)
{

	int current_layer = 0;

	//Change this for proper animations
	// TODO:
	//		-Selecting proper buffer of BRAM
	//		-Rotation timing??
	transfer(&(frame_buffer[currentFrame]->sections[current_theta].layers[current_layer]), BRAM_LAYER_1, sizeof(Layer));
	next_section();

	if(current_theta == 359)
		current_theta = 0;
	else
		current_theta++;


	XScuTimer_ClearInterruptStatus(&TimerInstance);

	XScuTimer_LoadTimer(&TimerInstance, 162500000);

	/*
	 * Start the timer counter and then wait for it
	 * to timeout a number of times.
	 */
	XScuTimer_Start(&TimerInstance);

}

long setup_bram() {
	// Set up the AXI CDMA
	int Status;

	axi_cdma_cfg = XAxiCdma_LookupConfig(XPAR_AXICDMA_0_DEVICE_ID);

	if (!axi_cdma_cfg){
		return XST_FAILURE;
	}

	Status = XAxiCdma_CfgInitialize(&axi_cdma, axi_cdma_cfg, axi_cdma_cfg->BaseAddress);

	if (Status != XST_SUCCESS){
		return XST_FAILURE;
	}


	XAxiCdma_IntrDisable(&axi_cdma, XAXICDMA_XR_IRQ_ALL_MASK);

	return XST_SUCCESS;
}

void transfer(UINTPTR source, UINTPTR dest, int length) {
	if (XAxiCdma_IsBusy(&axi_cdma)) {
//		printf("AXI CDMA is busy...\n\r");
		while (XAxiCdma_IsBusy(&axi_cdma));
	}

//	printf("Flushing cache...\n\r");
	Xil_DCacheFlushRange(source, length);

//	printf("Starting transfer!\n\r");
	// Initiate a transfer
	int Status = XAxiCdma_SimpleTransfer(
			&axi_cdma,
			source,
			dest,
			length,
			NULL,
			NULL);
	if (Status) {
		printf("Error occured: Status = %d\n\r", Status);
	}

	// Wait until core isn't busy
	if (XAxiCdma_IsBusy(&axi_cdma)) {
//		printf("AXI CDMA is busy...\n\r");
		while (XAxiCdma_IsBusy(&axi_cdma));
	}

//	printf("Transfer finished!\n\r");
}

void init_control() {
	driverControl = 0x0;
	int enable = 0x1 << 3;
	driverControl = enable | (1 << 2);

	Setup_Layer *setup = Setup_Layer_init();

	//Xil_DCacheFlushRange((UINTPTR)setup, sizeof(Setup_Layer));

	transfer((UINTPTR)setup, (UINTPTR)BRAM_SETUP, sizeof(Setup_Layer));


	XGpio_DiscreteWrite(&gpio, 1, enable);

	usleep(10);

	XGpio_DiscreteWrite(&gpio, 1, driverControl);

}

void next_section() {
	driverControl ^= 1 << 1;
	//driverControl ^= 1 << 0;
	XGpio_DiscreteWrite(&gpio, 1, driverControl);
}

long setup_uart() {
	int Status;

	Config = XUartPs_LookupConfig(XPAR_XUARTPS_0_DEVICE_ID);

	if (NULL == Config) {
		return XST_FAILURE;
	}

	Status = XUartPs_CfgInitialize(&USB_uart, Config, Config->BaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/* Check hardware build. */
	Status = XUartPs_SelfTest(&USB_uart);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	Config = XUartPs_LookupConfig(XPAR_XUARTPS_1_DEVICE_ID);

	if(NULL == Config) {
		return XST_FAILURE;
	}

	Status = XUartPs_CfgInitialize(&WIFI_uart, Config, Config->BaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}


	///heck hardware build.
	Status = XUartPs_SelfTest(&WIFI_uart);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	*/

	return XST_SUCCESS;
}

long setup_interrupts() {
	int Status;
	XScuTimer_Config *ConfigPtr;
	XScuGic_Config *IntcConfig;


	/*
	 * Initialize the Scu Private Timer driver.
	 */
	ConfigPtr = XScuTimer_LookupConfig(XPAR_XSCUTIMER_0_DEVICE_ID);
	Status = XScuTimer_CfgInitialize(&TimerInstance, ConfigPtr,
						ConfigPtr->BaseAddr);
	if (Status != XST_SUCCESS) {
			return XST_FAILURE;
		}

	/*
	 * Perform a self-test to ensure that the hardware was built correctly.
	 */
	Status = XScuTimer_SelfTest(&TimerInstance);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}


	/*
	 * Initialize the interrupt controller driver so that it is ready to
	 * use.
	 */
	IntcConfig = XScuGic_LookupConfig(XPAR_SCUGIC_SINGLE_DEVICE_ID);
	if (NULL == IntcConfig) {
		return XST_FAILURE;
	}

	Status = XScuGic_CfgInitialize(&IntcInstance, IntcConfig,
					IntcConfig->CpuBaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	//Xil_ExceptionInit();
	XGpio_InterruptEnable(&gpio, XGPIO_IR_CH2_MASK);
	XGpio_InterruptGlobalEnable(&gpio);


	/*
	 * Connect the interrupt controller interrupt handler to the hardware
	 * interrupt handling logic in the processor.
	 */
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_IRQ_INT,
				(Xil_ExceptionHandler)XScuGic_InterruptHandler,
				&IntcInstance);

	Xil_ExceptionEnable();

	// BUTTON STUFFFF-------------------------


	Status = XScuGic_Connect(&IntcInstance, XPAR_FABRIC_AXI_GPIO_0_IP2INTC_IRPT_INTR,
							(Xil_ExceptionHandler) hallSensor,
							(void *) &gpio);
	if (Status != XST_SUCCESS)
			return XST_FAILURE;

	XGpio_InterruptEnable(&gpio, XGPIO_IR_CH2_MASK);
	XGpio_InterruptGlobalEnable(&gpio);


	XScuGic_Enable(&IntcInstance, XPAR_FABRIC_AXI_GPIO_0_IP2INTC_IRPT_INTR);


	// ---------------------------------------
	/*
	 * Connect the device driver handler that will be called when an
	 * interrupt for the device occurs, the handler defined above performs
	 * the specific interrupt processing for the device.
	 */
	Status = XScuGic_Connect(&IntcInstance, XPAR_SCUTIMER_INTR,
				(Xil_ExceptionHandler)render,
				(void *)&TimerInstance);
	if (Status != XST_SUCCESS) {
		return Status;
	}

	/*
	 * Enable the interrupt for the device.
	 */
	XScuGic_Enable(&IntcInstance, XPAR_SCUTIMER_INTR);

	/*
	 * Enable the timer interrupts for timer mode.
	 */
	XScuTimer_EnableInterrupt(&TimerInstance);

	//Xil_ExceptionEnable();

	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Enable Auto reload mode.
	 */
//	XScuTimer_EnableAutoReload(&TimerInstance);


	/*
	 * Load the timer counter register.
	 */
//	XScuTimer_SetPrescaler(&TimerInstance, 0x1);
//	XScuTimer_LoadTimer(&TimerInstance, 162500000);

	//printf("prescalar value: %d\n", XScuTimer_GetPrescaler(&TimerInstance));
	//printf("load value: %u\n\r", XScuTimer_GetCounterValue(&TimerInstance));

	/*
	 * Start the timer counter and then wait for it
	 * to timeout a number of times.
	 */
//	XScuTimer_Start(&TimerInstance);

	return XST_SUCCESS;
}



