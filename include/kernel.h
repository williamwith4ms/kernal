// multiboot header
#define MULTIBOOT_MAGIC 0x1BADB002
#define MULTIBOOT_FLAGS 0x00
#define MULTIBOOT_CHECKSUM -(MULTIBOOT_MAGIC + MULTIBOOT_FLAGS) & 0xFFFFFFFF

extern void kernel_main();

__attribute__((section(".multiboot")))
struct multiboot_header {
    unsigned int magic;
    unsigned int flags;
    unsigned int checksum;
} 

multiboot_header = {MULTIBOOT_MAGIC, MULTIBOOT_FLAGS, MULTIBOOT_CHECKSUM};
