#include "drivers.h"

void requestBufferSwap(int* background_buffer){
    *VGA_CONTROL = 1;
        while(*VGA_STATUS == 0);
        while(*VGA_STATUS == 1){
        }; 

        *background_buffer = !*background_buffer;
}

void requestBufferSwapRNG(int* background_buffer, int *rng_state){
    *VGA_CONTROL = 1;
        while(*VGA_STATUS == 0);
        while(*VGA_STATUS == 1){
            *rng_state++;
        }; 

        *background_buffer = !*background_buffer;
}

unsigned int random(int* rng_state){
    *rng_state ^= *rng_state << 13;
    *rng_state ^= *rng_state >> 17;
    *rng_state ^= *rng_state << 5;
    return *rng_state;
}

int buttonPressed(int button){
    return (*BUTTONS & (1 << button)) != 0;
}
