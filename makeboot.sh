#!/bin/bash

SRC_DIR="src"
BUILD_DIR=".build"
STAGE0_ASM="bootloader/bootloader_stage_0.asm"
STAGE1_ASM="bootloader/bootloader_stage_1.asm"
STAGE0_BIN="bootloader_stage_0.bin"
STAGE1_BIN="bootloader_stage_1_debug.bin"
DISK_IMAGE="bootable_disk.img"

mkdir -p $BUILD_DIR

# delete old files
echo "Deleting old files..."
rm -f $BUILD_DIR/$STAGE0_BIN
rm -f $BUILD_DIR/$STAGE1_BIN
rm -f $BUILD_DIR/$DISK_IMAGE


nasm -f bin -o $BUILD_DIR/$STAGE0_BIN $SRC_DIR/$STAGE0_ASM
if [ $? -ne 0 ]; then
  echo "Error: Failed to assemble stage 0 bootloader."
  exit 1
fi

nasm -f bin -o $BUILD_DIR/$STAGE1_BIN $SRC_DIR/$STAGE1_ASM
if [ $? -ne 0 ]; then
  echo "Error: Failed to assemble stage 1 bootloader."
  exit 1
fi

dd if=/dev/zero of=$BUILD_DIR/$DISK_IMAGE bs=512 count=2880
if [ $? -ne 0 ]; then
  echo "Error: Failed to create disk image."
  exit 1
fi

dd if=$BUILD_DIR/$STAGE0_BIN of=$BUILD_DIR/$DISK_IMAGE conv=notrunc
if [ $? -ne 0 ]; then
  echo "Error: Failed to write stage 0 to disk image."
  exit 1
fi

dd if=$BUILD_DIR/$STAGE1_BIN of=$BUILD_DIR/$DISK_IMAGE bs=512 seek=1 conv=notrunc
if [ $? -ne 0 ]; then
  echo "Error: Failed to write stage 1 to disk image."
  exit 1
fi

echo "Bootable disk image created successfully: $BUILD_DIR/$DISK_IMAGE"
