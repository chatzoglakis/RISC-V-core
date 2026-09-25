CC = riscv-none-elf-gcc
OBJCOPY = riscv-none-elf-objcopy
CFLAGS = -march=rv32i -mabi=ilp32 -O2 -fno-jump-tables -nostartfiles -ffreestanding

TARGET = pong

all: $(TARGET).bin

$(TARGET).elf: src/crt0.s src/main.c
	$(CC) $(CFLAGS) -T linker.ld $^ -o $@

$(TARGET).bin: $(TARGET).elf
	$(OBJCOPY) -O binary $< $@

clean:
	rm -f $(TARGET).elf $(TARGET).bin

.PHONY: all clean
