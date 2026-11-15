#include "graphics.h"
#include "drivers.h"

#define BALL_SPEED 5
#define PADDLE_SPEED 3

static unsigned int rng_state; 

int int_sqrt(int x) {
    if (x <= 0) return 0;
    int res = 0;
    int bit = 1 << 30;

    while (bit > x) {
        bit >>= 2;
    }

    while (bit != 0) {
        if (x >= res + bit) {
            x -= res + bit;
            res = (res >> 1) + bit;
        } else {
            res >>= 1;
        }
        bit >>= 2;
    }
    return res;
}

int multiply(int a, int b) {
    if (a == 0 || b == 0) return 0;

    unsigned int abs_a = (a > 0) ? a : -a;
    unsigned int abs_b = (b > 0) ? b : -b;
    unsigned int res = 0;

    while (abs_b > 0) {
        if (abs_b & 1) {
            res += abs_a;
        }
        abs_a <<= 1;
        abs_b >>= 1;
    }

    if ((a < 0 && b < 0) || (a > 0 && b > 0))
        return (int)res;
    
    return -(int)res;
}

int my_div(int dividend, int divisor) {
    if (divisor == 0 || dividend == 0) return 0;

    int abs_dividend = (dividend > 0) ? dividend : -dividend;
    int abs_divisor = (divisor > 0) ? divisor : -divisor;
    
    int res = 0;
    // Subtract abs_divisor repeatedly (with rounding by adding half divisor)
    int rem = abs_dividend + (abs_divisor >> 1);
    while (rem >= abs_divisor) {
        rem -= abs_divisor;
        res++;
    }

    if((dividend < 0 && divisor < 0) || (dividend > 0 && divisor > 0))
        return res;
    
    return -res;
}

int calculateBallVerticalChange(const rectangle* paddle, const rectangle* ball){
    int vy;
	
    if (ball->y < paddle->y + 10)
        vy = -BALL_SPEED;
    else if (ball->y > paddle->y + 20)
        vy = BALL_SPEED;
    else
        vy = 0;

    int jitter = (random(&rng_state) & 1) ? 1 : -1;
    if (random(&rng_state) & 2) {
        vy += jitter;
    }

    return vy;
}

int main(){
    rng_state = 0x92D68CA2;
    int background_buffer = 1;

    rectangle p1 = {20, 100, 30, 5};
    rectangle p2 = {300, 100, 30, 5};

    rectangle ball = {160, 120, 3, 3};

    int vx = BALL_SPEED;
    int vy = 0;
    
    while(1){
        fillScreen(background_buffer, DARK_GRAY);
            
        drawRectangle(background_buffer, &p1, RED);
        drawRectangle(background_buffer, &p2, RED);
        drawRectangle(background_buffer, &ball, ORANGE);

        if(hasIntersection(&p1, &ball)){
            ball.x = p1.x + p1.w;
            vx = BALL_SPEED;
            vy = multiply(calculateBallVerticalChange(&p1, &ball), 4);
        }
        else if(hasIntersection(&p2, &ball)){
            ball.x = p2.x - ball.w;
            vx = -BALL_SPEED;
            vy = multiply(calculateBallVerticalChange(&p2, &ball), 4);
        }

        if (ball.y <= 0) {
            ball.y = 0;
            vy = -vy;
        } 
        else if (ball.y >= (240 - ball.h)) {
            ball.y = 240 - ball.h;
            vy = -vy;
        }

        int magnitude = int_sqrt(multiply(vx, vx) + multiply(vy, vy));

        int step_x = my_div(multiply(vx, BALL_SPEED), magnitude);
        int step_y = my_div(multiply(vy, BALL_SPEED), magnitude);

        if (step_x == 0) step_x = (vx > 0) ? 1 : -1;

        ball.x += step_x;
        ball.y += step_y;
        
        if (ball.x <= 0 || ball.x >= (320 - ball.w)) {
            ball.x = 160;
            ball.y = 120;
            vy = 0;
            vx = (vx < 0) ? 10 : -10;
        }

        if (buttonPressed(0)) {
            p2.y += PADDLE_SPEED;
            if(p2.y > 240 - p2.h) p2.y = 240 - p2.h;
        }
        if (buttonPressed(1)) {
            p2.y -= PADDLE_SPEED;
            if (p2.y < 0) p2.y = 0;
        }
        if (buttonPressed(2)) {
            p1.y += PADDLE_SPEED;
            if(p1.y > 240 - p1.h) p1.y = 240 - p1.h;
        }
        if (buttonPressed(3)) {
            p1.y -= PADDLE_SPEED;
            if (p1.y < 0) p1.y = 0;
        }

        requestBufferSwapRNG(&background_buffer, &rng_state);
    }

    return 0;
}