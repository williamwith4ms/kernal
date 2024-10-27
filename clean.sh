#!/bin/bash

BUILD_DIR=".build"
# clean up
echo "Cleaning up..."


if [ -d $BUILD_DIR ]; then
  rm -rf $BUILD_DIR
  echo "Deleted $BUILD_DIR"
  # create build directory
  mkdir -p $BUILD_DIR
else
  echo "$BUILD_DIR does not exist"
fi

