#include <stdio.h>

#include "platform.h"
#include "xparameters.h"
#include "xaxicdma.h"
#include "sleep.h"

#define BRAM_ADDR XPAR_AXI_BRAM_CTRL_1_S_AXI_BASEADDR
#define DMA_DEV_ID XPAR_AXICDMA_0_DEVICE_ID
#define BUFF_LEN 10
#define PRINT_BUFF_LEN 12
#define TX_BUFF_ADDR 0x0000FFF8 // some address in OCM
#define RX_BUFF_ADDR 0x40000000 // Not 'seen' by the PS

int Status;
XAxiCdma_Config *axi_cdma_cfg;
XAxiCdma axi_cdma;

int main()
{
	init_platform();
	printf("-------------------------------------\n\r");
	printf("AXI CDMA test\n\r");
	printf("-------------------------------------\n\r");

	// Buffer of data to transfer
	u32 *tx_buffer = (u32 *) TX_BUFF_ADDR;
	u32 *rx_buffer = (u32 *) RX_BUFF_ADDR;

	u32 i;
	for (i = 0; i < BUFF_LEN; i++) {
		*(tx_buffer + i) = 0xFFFFFFFa;
	}
	// Flush the buffer
	Xil_DCacheFlushRange((u32)TX_BUFF_ADDR, BUFF_LEN);



	// Set up the AXI CDMA
	axi_cdma_cfg = XAxiCdma_LookupConfig(XPAR_AXICDMA_0_DEVICE_ID);
	if (!axi_cdma_cfg){
		return XST_FAILURE;
	}
	Status = XAxiCdma_CfgInitialize(&axi_cdma, axi_cdma_cfg, axi_cdma_cfg->BaseAddress);
	if (Status != XST_SUCCESS){
		return XST_FAILURE;
	}

	// Disable interrupts
	XAxiCdma_IntrDisable(&axi_cdma, XAXICDMA_XR_IRQ_ALL_MASK);



	// Checking that the DMA core isn't busy before we start a transfer

	if (XAxiCdma_IsBusy(&axi_cdma)) {
		printf("AXI CDMA is busy...\n\r");
		while (XAxiCdma_IsBusy(&axi_cdma));
	}



	// Reading bram before we start the DMA transfer
	u32 *bram_read = (u32 *) BRAM_ADDR;
	printf("Prior to initiating the DMA transfer:\n\r");
	for (i = 0; i < PRINT_BUFF_LEN; i++) {
		printf("0x%08x\n\r", (unsigned int) *(bram_read + i));
	}
	printf("-------------------------------------\n\r");
	printf("TX buffer contents:\n\r");
	for (i = 0; i < PRINT_BUFF_LEN; i++) {
		printf("0x%08x\n\r", (unsigned int) *(tx_buffer + i));
	}
	printf("-------------------------------------\n\r");



	// Initiate a transfer
	Status = XAxiCdma_SimpleTransfer(
			&axi_cdma,
			(u32) tx_buffer,
			(u32) rx_buffer,
			BUFF_LEN * sizeof(u32),
			NULL,
			NULL);
	if (Status) {
		printf("Error occured: Status = %d\n\r", Status);
	}


	// Wait until core isn't busy
	if (XAxiCdma_IsBusy(&axi_cdma)) {
		printf("AXI CDMA is busy...\n\r");
		while (XAxiCdma_IsBusy(&axi_cdma));

	}

	// Read from BRAM to make sure it's done
	//Xil_DCacheInvalidateRange((u32)RX_BUFF_ADDR, BUFF_LEN); //CRASHES BECAUSE OUTSIDE 32 BIT ADDRESS RANGE
	printf("After DMA transfer:\n\r");
	for (i = 0; i < PRINT_BUFF_LEN; i++) {
		printf("0x%08x\n\r", (unsigned int) *(bram_read + i));
	}
	printf("-------------------------------------\n\r");
	cleanup_platform();
	return 0;
}
