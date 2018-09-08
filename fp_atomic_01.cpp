#include <iostream>
#include <hip/hip_runtime_api.h>
#include <hip/hip_runtime.h>

typedef union {
    unsigned int i;
    float f;
} uif_t;

__global__ void fp_atomic_kernel(float* output, float* input) {
    int tid = threadIdx.x + blockIdx.x * 1024;
    float val = input[tid];
    unsigned int *address_as_ui = reinterpret_cast<unsigned int*>(output);
    unsigned int old = *address_as_ui, assumed;
    do {
        assumed = old;
        old = atomicCAS(address_as_ui, assumed, __float_as_int(val + __int_as_float(assumed)));
    } while (assumed != old);
}

constexpr unsigned len = 1024;

int main() {
    float* input = new float[len];
    float* output = new float[1];
    std::fill(input, input + len, 1.0f);
    std::fill(output, output + 1, 0.0f);
    float* output_d, *input_d;
    hipMalloc(&output_d, sizeof(float));
    hipMalloc(&input_d, sizeof(float) * len);
    hipMemcpy(input_d, input, sizeof(float) * len, hipMemcpyHostToDevice);
    hipMemcpy(output_d, output, sizeof(float), hipMemcpyHostToDevice);
    hipLaunchKernelGGL(fp_atomic_kernel, dim3(1,1,1), dim3(len,1,1), 0, 0, output_d, input_d);
    hipDeviceSynchronize();
    hipMemcpy(output, output_d, sizeof(float), hipMemcpyDeviceToHost);
    std::cout << output[0] << std::endl;
}