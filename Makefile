LLVM=~/llvm80
MC=~/llvm80/bin/llvm-mc
ARCH=amdgcn
CPU=gfx900

CONV01=conv1x1.01.s

conv1x1.01: conv1x1.01.s
    ~/llvm80/bin/llvm-mc -arch=amdgcn -mcpu=gfx900 $@ -o $^

clean:
	rm *.o *.co