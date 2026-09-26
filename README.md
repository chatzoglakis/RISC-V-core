This repo includes a VHDL design for a standard 5 stage pipelined RISC V CPU core, running at a clock rate of 90 MHz, that implements the RV32I ISA. It also supports 4 button inputs as well as VGA output through a dedicated video subsystem. There is also a constraint file for implementation on the Zybo Z7 10 FPGA, testbenches and a pong program written in C that was used to test the CPU.

## Hardware Used
- Zybo Z7 10 FPGA
- VGA PMOD
- Arduino UNO, for loading programs via UART
>[!NOTE]
>To stream software binaries straight into the FPGA fabric without routing through the ARM processor, an Arduino Uno is repurposed as a transparent hardware bridge. A dedicated PMOD USB-UART module could also be used instead.

## CPU Overview
The CPU includes the following "modules":
- A **16KB Instruction RAM**
- The **Program Loader**, that receives instructions via UART and loads them into the Instruction RAM
- The **Immediate Generation Unit**, that creates appropriate immediate values based on the received instruction
- The **Control Unit**, which generates control signals so the CPU can execute each instruction
- The **Register File**, responsible for storing all of the CPU's registers
- The **ALU**, for arithmetic and logic
- The **Hazard Detection Unit**, that detects Load-Use hazards and stalls the pipeline
- The **Forwarding Unit**, which forwards values from the MEM and WB stages of the pipeline to the EX stage, to avoid RAW hazards
- The **Branch Condition Unit**, that resolves branches and flushes the pipeline
- A 16KB **Data RAM**
- The **Store Alignment Unit**, that formats data ram input appropriately for each store instruction (sw, sh, sb)
- The **Video Subsystem**, responsible for video output. Described in depth in the next section
- The **Data Loading Unit**, that formats data ram output appropriately for each load instruction (lw, lh, lb)

## Video Subsystem
The Video Subsystem consists of a VRAM circuit, which is just a dual ported byte addressable RAM. The chosen display size is **320*240**, making the total size of the VRAM 153600 bytes (each byte corresponding to a pixel), since the design is double buffered to prevent screen tearing (there are 2 buffers of 76800 bytes). 

The CPU writes to VRAM at specific addresses through regular store instructions. To avoid conflict with the DATA RAM, which ranges from `0x0` to `0x4000`, address `0x40000000` was chosen as the start of the VRAM. That means that by looking at bit 30 of the address value of a store instruction:
- The Store Alignment Unit stores the chosen data at the Data RAM when bit 30 of the address is 0
- The Store Alignment Unit stores the chosen data at the VRAM when bit 30 of the address is 1

The VGA controller reads each byte from the VRAM in order, constructs the specific rgb value based on the bytes value, and displays the color on the screen.

### CPU and VGA Controller Communication
To achieve correct video output with a double buffer, we need to ensure that the buffer being displayed at any moment and the buffer being written on by the CPU are always different. That means that the faster (90MHz) CPU would have to wait until the slower (25.2 MHz) VGA controller is done displaying a buffer to request a swap. This is the exact process the system follows:
- The programmer can request a framebuffer swap by writing at address `0x80000000` (VGA_CONTROL) via a store instruction. Every store toggles the CPU's swap_request flag
- The VGA Controller waits until VBLANK (the period between the end and the start of the screen) to check the swap_request flag. It compares its internal swap_ack flag to swap_request. If they are not equal, that means that there is a pending framebuffer swap request. The VGA Controller then sets the swap_ack flag to match swap_request and changes framebuffer.
- The vga_status flag is just the XNOR of the swap_request and swap_ack flags (just an equality check). The programmer can poll it via a load instruction in address `0x80000008`. If vga_status = 1, that means that the VGA Controller is busy displaying the framebuffer and we should wait before writing to the same framebuffer.

The software to achieve this communication looks like this:
```C
#define VGA_CONTROL ((volatile unsigned int*) 0x80000000)
#define VGA_STATUS ((volatile unsigned int*) 0x80000008)

int main(){
   while(1){
      while(*VGA_STATUS == 1); //wait until vga_status = 0 (until the request is acknowledged)

      draw_buffer(background_buffer); //draw function

      *VGA_CONTROL = 1; //write to vga_control to request swap

      background_buffer = !background_buffer;//change buffers
   }
}
```

## Button Input

The Zybo Z7 FPGA has 4 buttons connected to the FPGA fabric, all of which are used as input for the CPU. The CPU has a 4 bit button register which stores debounced button presses, each bit representing each button. The programmer can poll the state of the button register by using a load instruction at address `0x80000004` to see which buttons are pressed at any moment.

## Software Constraints

The CPU uses a Harvard memory architecture with separate Instruction RAM and Data RAM. Because the UART program loader targets Instruction RAM exclusively and no C runtime copy routine is present, the following rules should be followed when programming the CPU:

1. **Avoid Global const Arrays and Lookup Tables:**
   - Any data placed in `.rodata` (read only data) cannot be accessed via `lw` (loads target Data RAM, while `.rodata` resides in Instruction RAM).
   - Use mathematical approximations, bit-shifts, or explicit conditional ladders instead of memory tables.

2. **No Initialized Global Variables (`.data`):**
   - Variables with non-zero initializers (e.g., `static int state = 123;`) will not have their values copied to Data RAM on boot.
   - Declare globals uninitialized (placing them in `.bss`) and assign their initial values procedurally inside `main()`.

3. **Compiler Flags:**
   - Use `-fno-jump-tables` during compilation to prevent GCC from generating indirect jump tables in `.rodata` for `switch` statements.
