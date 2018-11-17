/*
 * pixel_data.h
 *
 *  Created on: Nov 10, 2018
 *      Author: TaySm
 */

#ifndef SRC_PIXEL_DATA_H_
#define SRC_PIXEL_DATA_H_

#define SETUP_COMMAND 0x96;

int LedValue[16] = {8,12,9,13,14,10,15,11,7,3,6,2,1,5,0,4};

typedef struct {
	uint16_t blue, green, red;
} Pixel;

typedef struct {
//	Pixel pixels[32];
	uint16_t pixels[32*3];
} Layer;

typedef struct {
	Layer layers[24];
} Frame;


typedef struct {
	uint32_t data[24];
} TLC_Setup;

typedef struct {
	TLC_Setup data[2];
} Setup_Layer;

void setBit(uint32_t *array, int bit_num, int bit_val) {

	if(bit_val)
	{
		array[(767 - bit_num)/32] |= 1 << (bit_num % 32);
	}
	else
	{
		array[(768 - bit_num)/32] &= ~(1 << (bit_num % 32));
	}
}

Setup_Layer* Setup_Layer_init() {
	Setup_Layer *setup = calloc(1, sizeof(Setup_Layer));

	int command[8] = {1, 0, 0, 1, 0, 1, 1, 0};
	int j = 0;
	for(int i = 767; i >= 760; i--) {
		//command
		setBit(setup->data[0].data, i, command[j]);
		j++;
	}
		//759:371 padding
	int function[5] = {0, 1, 0, 0, 1};
	j = 0;
	for(int i = 370; i >= 366; i--) {
		//setup function control
		setBit(setup->data[0].data, i, function[j]);
		j++;
	}
	for(int i = 365; i >= 345; i--) {
		//setup brightness control
		setBit(setup->data[0].data, i, 1);
	}

	int current[9] = {1, 1, 1, 1, 1, 1, 1, 1, 1};
	j = 0;
	for(int i = 344; i >= 336; i--) {
		//setup max current
		setBit(setup->data[0].data, i, current[j]);
		j++;
	}
	for(int i = 335; i >= 0; i--) {
		setBit(setup->data[0].data, i, 1); //Setup Dot Correction
	}

	memcpy(setup->data[1].data, setup->data[0].data, sizeof(TLC_Setup));

	return setup;
}

int getPixelOffset(int ledNum)
{
	int ledVal = 15 - LedValue[ledNum % 16];

	if(ledNum <= 15)
		return 16 + ledVal;
	else
		return ledVal;

}

void write_SixteenBits(int indexIntoBytes, uint16_t valueToWrite, Layer* currLayer)
{
	if(indexIntoBytes % 2)
		currLayer->pixels[indexIntoBytes - 1] = valueToWrite;
	else
		currLayer->pixels[indexIntoBytes + 1] = valueToWrite;
}

void write_PixelData(int offset, Pixel currPixel, Layer* currLayer)
{
	int calculatedOffset = 3*offset;
	write_SixteenBits(calculatedOffset, currPixel.blue, currLayer);
	write_SixteenBits(calculatedOffset+1, currPixel.green, currLayer);
	write_SixteenBits(calculatedOffset+2, currPixel.red, currLayer);
}

#endif /* SRC_PIXEL_DATA_H_ */