#pragma once

#define VGA_CONTROL ((volatile unsigned int*) 0x80000000)
#define VGA_STATUS ((volatile unsigned int*) 0x80000008)
#define BUTTONS ((volatile unsigned int*) 0x80000004)

void requestBufferSwap(int* background_buffer);
void requestBufferSwapRNG(int* background_buffer, int* rng_state);
unsigned int random(int* rng_state);
int buttonPressed(int button);