/* linker.ld */
OUTPUT_FORMAT("elf32-i386");
ENTRY(kernel_main);
SECTIONS
{
    . = 0x00100000;

    .multiboot ALIGN(0x1000) :
    {
        *(.multiboot)
    }

    .text ALIGN(0x1000) :
    {
        *(.text)
    }

    .data ALIGN(0x1000) :
    {
        *(.data)
    }

    .bss ALIGN(0x1000) :
    {
        *(.bss)
    }
}
