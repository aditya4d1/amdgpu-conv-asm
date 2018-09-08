//
// Transpose data from n c h w to n h w c
// out-place output
//

#include <iostream>
#include <hip/hip_runtime_api.h>

#define FILE_NAME "transpose01.co"
#define KERNEL_NAME "hello_world"

constexpr unsigned n = 64;
constexpr unsigned c = 128;
constexpr unsigned h = 64;
constexpr unsigned w = 64;

int main() {
    
}