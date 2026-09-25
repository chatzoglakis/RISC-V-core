.section .text.init
.globl _start

_start:
    #set stack pointer at top of data memory (memory size is 16KB)
    li sp, 0x00004000

    # Jump to C entry point
    call main

1: j 1b
