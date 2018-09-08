#!/bin/bash

FILENAME=reduce02

~/llvm80/bin/llvm-mc -arch=amdgcn -mcpu=gfx900 $FILENAME.s -filetype=obj -o $FILENAME.o
~/llvm80/bin/ld.lld -shared $FILENAME.o -o $FILENAME.co
