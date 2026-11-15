#include "graphics.h"

void fillScreen(int buffer, unsigned char color){
    int offset = (buffer) ? FRAME_SIZE : 0;
    for(int i = 0; i < FRAME_SIZE; i++){
        VRAM[offset + i] = color;
    } 
}

void drawPixel(const int buffer, const int x, const int y, const unsigned char color){
    int offset = (buffer) ? FRAME_SIZE : 0;

    VRAM[offset + (y << 8) + (y << 6) + x] = color;

}

void drawRectangle(int buffer, rectangle* rect, unsigned char color){
    int offset = (buffer) ? FRAME_SIZE : 0;
  
    for(int h = 0; h < rect->h; h++){
        int curr_y = rect->y + h;
        int index = (curr_y << 8) + (curr_y << 6) + offset;

        for(int w = 0; w < rect->w; w++){
            int curr_x = rect->x + w;
            VRAM[index + curr_x] = color; 
        }
    }
}

//Bresenham's Line Drawing Algorithm
void drawLine(const int background_buffer, int x1, int y1, const int x2, const int y2, const unsigned char color){
    int offset = (background_buffer) ? FRAME_SIZE : 0;

    int dx = (x2 >= x1) ? (x2 - x1) : (x1 - x2);
    int dy = (y2 >= y1) ? -(y2 - y1) : -(y1 - y2);

    int sx = (x1 < x2) ? 1 : -1;
    int sy = (y1 < y2) ? 1 : -1;
    int err = dx + dy;

    while(1){
        if(x1 >= 0 && x1 < 320 && y1 >= 0 && y1 < 240){
            int index = (y1 << 8) + (y1 << 6) + x1;
            VRAM[offset + index] = color;
        }

        if(x1 == x2 && y1 == y2){
            break;
        }

        int e2 = 2 * err;

        if(e2 >= dy){
            err += dy;
            x1 += sx;
        }

        if(e2 <= dx){
            err += dx;
            y1 += sy;
        }
    }
}

void drawCircle(const int background_buffer, const int cx, const int cy, const int r, const unsigned char color){
    if (r <= 0) {
        if (r == 0) drawPixel(background_buffer, cx, cy, color);
        return;
    }

    int x = 0;
    int y = r;
    // Initial decision parameter: d = 3 - 2*r
    int d = 3 - (r << 1);

    while (x <= y) {
        // 8-way octant symmetry
        drawPixel(background_buffer, cx + x, cy + y, color);
        drawPixel(background_buffer, cx - x, cy + y, color);
        drawPixel(background_buffer, cx + x, cy - y, color);
        drawPixel(background_buffer, cx - x, cy - y, color);
        drawPixel(background_buffer, cx + y, cy + x, color);
        drawPixel(background_buffer, cx - y, cy + x, color);
        drawPixel(background_buffer, cx + y, cy - x, color);
        drawPixel(background_buffer, cx - y, cy - x, color);

        if (d < 0) {
            // Next point is East: d = d + 4*x + 6
            d += (x << 2) + 6;
        } else {
            // Next point is South-East: d = d + 4*(x - y) + 10
            d += ((x - y) << 2) + 10;
            y--;
        }
        x++;
    }
}

void fillCircle(int buffer, int cx, int cy, int r, unsigned char color) {
    if (r < 0) return;
    if (r == 0) {
        drawPixel(buffer, cx, cy, color);
        return;
    }

    int x = 0;
    int y = r;
    int d = 3 - (r << 1);

    while (x <= y) {
        // Draw horizontal scanlines across symmetric pairs
        for (int i = cx - x; i <= cx + x; i++) {
            drawPixel(buffer, i, cy + y, color);
            drawPixel(buffer, i, cy - y, color);
        }
        for (int i = cx - y; i <= cx + y; i++) {
            drawPixel(buffer, i, cy + x, color);
            drawPixel(buffer, i, cy - x, color);
        }

        if (d < 0) {
            d += (x << 2) + 6;
        } else {
            d += ((x - y) << 2) + 10;
            y--;
        }
        x++;
    }
}

int hasIntersection(const rectangle* a, const rectangle* b){
    return (a->x < b->x + b->w &&
            a->x + a->w > b->x && 
            a->y < b->y + b->h &&
            a->y + a->h > b->y);
}

