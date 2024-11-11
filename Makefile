CC = i686-elf-gcc
LD = i686-elf-ld
NASM = nasm
OBJCOPY = i686-elf-objcopy
ASMFLAGS = -f bin
CFLAGS = -ffreestanding -fno-builtin -I include 
LDFLAGS = -T linker.ld -m elf_i386

C_SOURCES = $(wildcard src/kernel/*.c)
ASM_SOURCES = $(wildcard src/bootloader/*.asm)

C_OBJECTS = $(C_SOURCES:src/kernel/%.c=.build/%.o)
ASM_BINARIES = $(ASM_SOURCES:src/bootloader/%.asm=.build/%.bin)	

all: .build/boot.img

.build/boot.img: .build/bootloader_stage_0.bin .build/bootloader_stage_1.bin .build/kernel.bin
	# create blank disk image
	dd if=/dev/zero of=.build/boot.img bs=512 count=2880

	# place stage 0 at sector 1
	dd if=.build/bootloader_stage_0.bin of=.build/boot.img bs=512 count=1 conv=notrunc

	# place stage 1 at sector 2
	dd if=.build/bootloader_stage_1.bin of=.build/boot.img bs=512 count=1 seek=1 conv=notrunc
	
	# place kernel at sector 3 
	dd if=.build/kernel.bin of=.build/boot.img seek=2 conv=notrunc

.build/kernel.bin: .build/kernel.elf
	$(OBJCOPY) -O binary $< $@

.build/kernel.elf: $(C_OBJECTS)
	@echo "Linking $^ to $@"
	$(LD) $(LDFLAGS) -o $@ $^

.build/%.o: src/kernel/%.c
	@echo "Compiling $< to $@"
	$(CC) $(CFLAGS) -c $< -o $@

.build/bootloader_stage_0.bin: src/bootloader/bootloader_stage_0.asm
	@echo "Assembling $< to $@"
	$(NASM) $(ASMFLAGS) $< -o $@

.build/bootloader_stage_1.bin: src/bootloader/bootloader_stage_1.asm
	@echo "Assembling $< to $@"
	$(NASM) $(ASMFLAGS) $< -o $@

clean:
	rm -rf .build/*

.PHONY: all clean
