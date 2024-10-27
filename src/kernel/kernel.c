#include "../include/kernel.h" // Include the header file

void print(const char *str) // Print function
{
    char *video_memory = (char *) 0xb8000; // Video memory address
    while(*str) {
      *video_memory++ = *str++;
      *video_memory++ = 0x07;
  }
}

void kernel_main() // Main function
{
    const char *message = "Hello World!";
    print(message);

    while(1); // hang
} 
