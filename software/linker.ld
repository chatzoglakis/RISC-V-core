OUTPUT_ARCH("riscv")
ENTRY(_start)

MEMORY
{
    /* Instruction RAM: 16 KB (0x4000 bytes) at address 0x00000000 */
    IRAM (rx)  : ORIGIN = 0x00000000, LENGTH = 16K

    /* Data RAM: 16 KB (0x4000 bytes) at address 0x00000000 */
    DRAM (rwx) : ORIGIN = 0x00000000, LENGTH = 16K
}

SECTIONS
{
    /* ---------------------------------------------------------
       Code and Read-Only Data (Mapped into Instruction Memory)
       --------------------------------------------------------- */
    .text : {
        . = ALIGN(4);
        KEEP(*(.text.init))     /* Startup code (_start in crt0.s) must be at byte 0 */
        *(.text .text.*)        /* All compiled C functions */
        *(.rodata .rodata.*)    /* Read-only constants, string literals */
        *(.srodata .srodata.*)  /* Small read-only data */
        . = ALIGN(4);
        _etext = .;             /* Global symbol: End of code */
    } > IRAM

    /* ---------------------------------------------------------
       Initialized Data (Mapped into Data Memory)
       --------------------------------------------------------- */
    .data : {
        . = ALIGN(4);
        _sdata = .;             /* Global symbol: Start of initialized data */
        *(.data .data.*)        /* Initialized globals and statics (e.g., int x = 42;) */
        *(.sdata .sdata.*)      /* Small initialized data */
        . = ALIGN(4);
        _edata = .;             /* Global symbol: End of initialized data */
    } > DRAM

    /* ---------------------------------------------------------
       Global Pointer for RISC-V GP-relative relaxation
       --------------------------------------------------------- */
    __global_pointer$ = MIN(_sdata + 0x800, MAX(_sdata, _edata));

    /* ---------------------------------------------------------
       Uninitialized / Zero-Initialized Data (Mapped into Data Memory)
       --------------------------------------------------------- */
    .bss : {
        . = ALIGN(4);
        _sbss = .;              /* Global symbol: Start of BSS */
        *(.bss .bss.*)          /* Uninitialized globals (e.g., int y;) */
        *(.sbss .sbss.*)        /* Small uninitialized data */
        *(COMMON)               /* Common uninitialized variables */
        . = ALIGN(4);
        _ebss = .;              /* Global symbol: End of BSS */
    } > DRAM

    /* ---------------------------------------------------------
       Stack and Memory Bounds Symbols
       --------------------------------------------------------- */
    _stack_top = ORIGIN(DRAM) + LENGTH(DRAM); /* 0x00004000 */
    _end = .;
}