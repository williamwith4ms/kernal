CC = i686-elf-gcc
LD = i686-elf-ld
NASM = nasm
OBJCOPY = i686-elf-objcopy
ASMFLAGS = -f bin
CFLAGS = -m32 -ffreestanding -fno-builtin -I include
LDFLAGS = -T linker.ld -m elf_i386

C_SOURCES = $(wildcard src/kernel/*.c)
ASM_SOURCES = $(wildcard src/bootloader/*.asm)

C_OBJECTS = $(C_SOURCES:src/kernel/%.c=.build/%.o)
ASM_BINARIES = $(ASM_SOURCES:src/bootloader/%.asm=.build/%.bin)
ASM_OBJECTS = $(ASM_BINARIES:.bin=.o)

all: .build/boot.bin

.build/boot.bin: .build/bootloader_stage_0.bin .build/kernel.bin
	cat $^ > $@

.build/kernel.bin: .build/kernel.elf
	cp .build/kernel.elf .build/kernel.bin

.build/kernel.elf: $(C_OBJECTS) $(ASM_OBJECTS)
	@echo "Linking kernel.elf with objects: $(C_OBJECTS) $(ASM_OBJECTS)"
	$(LD) $(LDFLAGS) -o $@ $^

.build/%.o: src/kernel/%.c
	@echo "Compiling $< to $@"
	$(CC) $(CFLAGS) -c $< -o $@

.build/%.bin: src/bootloader/%.asm
	@echo "Assembling $< to $@"
	$(NASM) $(ASMFLAGS) $< -o $@

.build/%.o: .build/%.bin
	@echo "Converting $< to $@"
	$(OBJCOPY) -I binary -O elf32-i386 $< $@

clean:
	rm -f .build/*.o .build/*.bin .build/kernel.bin .build/kernel.elf

.PHONY: all clean