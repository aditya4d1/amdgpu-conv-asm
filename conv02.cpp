#include <hip/hip_runtime.h>
#include <hip/hip_runtime_api.h>

typedef float float4_t __attribute__((ext_vector_type(4)));

__global__ void hello_world(float4_t* poutput, float* pfilter, float4_t* pimage) {
    int tx = threadIdx.x;
    int bx = blockIdx.x;
    float4_t img = pimage[tx];
    float fil = pfilter[bx];
    float4_t out{img.x * fil, img.y * fil, img.z * fil, img.w * fil};
    poutput[tx] = out;
}

int main() {
    float4_t* output, *image;
    float* filter;
    hipLaunchKernelGGL(hello_world, dim3(1,1,1), dim3(1,1,1), 0, 0, output, filter, image);
}
