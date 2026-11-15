CC = riscv-none-elf-gcc
OBJCOPY = riscv-none-elf-objcopy

CFLAGS = -march=rv32i -mabi=ilp32 -O2 -fno-jump-tables -nostartfiles -ffreestanding -Iinclude -MMD -MP
LDFLAGS = -T linker.ld

TARGET = pong

SRCS_ASM = src/crt0.s
SRCS_C   = src/pong.c src/graphics.c src/drivers.c

OBJS = $(SRCS_ASM:.s=.o) $(SRCS_C:.c=.o)
DEPS = $(OBJS:.o=.d)

all: $(TARGET).bin

$(TARGET).bin: $(TARGET).elf
	$(OBJCOPY) -O binary $< $@

$(TARGET).elf: $(OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) $^ -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.s
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS) $(DEPS) $(TARGET).elf $(TARGET).bin

-include $(DEPS)

.PHONY: all clean
