#define VGA_CONTROL ((volatile unsigned int*) 0x80000000)
#define VGA_STATUS ((volatile unsigned int*) 0x80000008)
#define BUTTONS ((volatile unsigned int*) 0x80000004)

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

#define BALL_SPEED 2
#define PADDLE_SPEED 3

//used for random number generation, by accumulating CPU cycles while waiting for the vga controller to enter VBLANK
static unsigned int rng_state; 

typedef struct{
    int x;
    int y;
    int h;
    int w;
}rectangle;


int calculateOffset(int buffer){
    if(!buffer){
        return 0;
    }
    else{
        return FRAME_SIZE;
    }
}

int buttonPressed(int button){
    return (*BUTTONS & (1 << button)) != 0;
}

void fillScreen(int buffer, unsigned char color){
    int offset = calculateOffset(buffer);

    for(int i = 0; i < FRAME_SIZE; i++){
        VRAM[offset + i] = color;
    } 
}

void drawRectangle(int buffer, int x_pos, int y_pos, int x_height, int y_height, unsigned char color){
    int offset = calculateOffset(buffer);
  
    for(int h = 0; h < y_height; h++){
        int curr_y = y_pos + h;
        int index = (curr_y << 8) + (curr_y << 6) + offset; //y*320 + offset

        for(int w = 0; w < x_height; w++){
            int curr_x = x_pos + w;
            
            VRAM[index + curr_x] = color; 
        }
    }
}

//Standard Xorshift32 PRNG
unsigned int random(){
    rng_state ^= rng_state << 13;
    rng_state ^= rng_state >> 17;
    rng_state ^= rng_state << 5;

    return rng_state;
}

int calculateBallVerticalChange(const rectangle* paddle, const rectangle* ball){
    int vy;
	
	if (ball->y < paddle->y + 10)
		vy = -BALL_SPEED;
	else if (ball->y > paddle->y + 20)
		vy = BALL_SPEED;
	else
		vy = 0;

    const int variation_table[8] = {-1, 0, 1, 0, -1, 1, 0, 0};
    int jitter = variation_table[random() & 7]; //Using '& 7' picks one of 8 pseudo-random variations without division

    vy += jitter;

    // Clamp vertical velocity so the ball won't go too fast
    if (vy > 4)  vy = 4;
    if (vy < -4) vy = -4;

    return vy;
}

int hasIntersection(const rectangle* a, const rectangle* b){
    return (a->x < b->x + b->w &&
            a->x + a->w > b->x && 
            a->y < b->y + b->h &&
            a->y + a->h> b->y);
}

int main(){
    rng_state = 0x92D68CA2;
    int background_buffer = 1; //framebuffer being currently drawn by the cpu

    rectangle p1 = {20 ,100, 30, 5};
    rectangle p2 = {300, 100, 30, 5};

    rectangle ball = {160, 120, 3, 3};
    int vx = BALL_SPEED;
    int vy = 0;
    
    while(1){

        while(*VGA_STATUS == 1){ //wait until the VGA controller reads the frame
            rng_state++;
        }; 

        if(background_buffer)
            fillScreen(background_buffer, DARK_GRAY);
        else
            fillScreen(background_buffer, DARK_GRAY);
            
        drawRectangle(background_buffer, p1.x, p1.y, p1.w, p1.h, RED);
        drawRectangle(background_buffer, p2.x, p2.y, p2.w, p2.h, RED);
        drawRectangle(background_buffer, ball.x, ball.y, ball.w, ball.h, ORANGE);

        if(hasIntersection(&p1, &ball)){
            ball.x = p1.x + p1.w;
            vx = BALL_SPEED;
            vy = calculateBallVerticalChange(&p1, &ball);
        }
        else if(hasIntersection(&p2, &ball)){
            ball.x = p2.x - ball.w;
            vx = -BALL_SPEED;
            vy = calculateBallVerticalChange(&p2, &ball);
        }

        if (ball.y <= 0) {
            ball.y = 0;
            vy = BALL_SPEED;
        } 
        else if (ball.y >= (240 - ball.h)) {
            ball.y = 240 - ball.h;
            vy = -BALL_SPEED;
        }

        ball.x += vx;
        ball.y += vy;
        
        if (ball.x <= 0 || ball.x >= (320 - ball.w)) {
			//respawn ball
			ball.x = 160;
			ball.y = 120;
			vy = 0;
			vx = (vx < 0) ? BALL_SPEED : -BALL_SPEED;
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

        *VGA_CONTROL = 1; //request framebuffer swap

        background_buffer = !background_buffer; //switch framebuffer
    }

    return 0;
}
