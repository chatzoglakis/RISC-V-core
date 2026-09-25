### Software Constraints

The CPU uses a Harvard memory architecture with separate Instruction RAM and Data RAM. Because the UART program loader targets Instruction RAM exclusively and no C runtime copy routine is present, the following rules should be followed when programming the CPU:

1. **Avoid Global const Arrays and Lookup Tables:**
   - Any data placed in `.rodata` (read only data) cannot be accessed via `lw` (loads target Data RAM, while `.rodata` resides in Instruction RAM).
   - Use mathematical approximations, bit-shifts, or explicit conditional ladders instead of memory tables.

2. **No Initialized Global Variables (`.data`):**
   - Variables with non-zero initializers (e.g., `static int state = 123;`) will not have their values copied to Data RAM on boot.
   - Declare globals uninitialized (placing them in `.bss`) and assign their initial values procedurally inside `main()`.

3. **Compiler Flags:**
   - Use `-fno-jump-tables` during compilation to prevent GCC from generating indirect jump tables in `.rodata` for `switch` statements.
