#pragma once

// VRAM base (320x240 pixels, 8-bit color)
#define VRAM ((volatile unsigned char*) 0x40000000)
#define FRAME_SIZE (320 * 240)

#define BLACK 0b00000000  
#define WHITE 0b11111111  
#define RED 0b11100000  
#define GREEN 0b00011100  
#define BLUE 0b00000011  
#define YELLOW 0b11111100
#define CYAN 0b00011111 
#define MAGENTA 0b11100011  
#define ORANGE 0b11101100 
#define DARK_GRAY 0b01001001
#define LIGHT_GRAY 0b10110110

typedef struct{
    int x;
    int y;
    int h;
    int w;
} rectangle;

void fillScreen(int buffer, unsigned char color);
void drawPixel(const int buffer, const int x, const int y, const unsigned char color);
void drawRectangle(int buffer, rectangle* rect, unsigned char color);
void drawLine(const int background_buffer, int x1, int y1, const int x2, const int y2, const unsigned char color);
void drawCircle(const int background_buffer, const int cx, const int cy, const int radius, const unsigned char color);
void fillCircle(const int background_buffer, const int cx, const int cy, const int radius, const unsigned char color);
int hasIntersection(const rectangle* a, const rectangle* b);

