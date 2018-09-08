#include <iostream>
#include <hip/hip_runtime_api.h>
#include <hip/hip_runtime.h>

constexpr int num_elements = 16;
constexpr size_t size = num_elements * sizeof(int);

#define FILE_NAME "conv01.co"
#define KERNEL_NAME "hello_world"

#define HIP_CHECK(status) \
    if(status != hipSuccess) std::cerr << "Failed at : " << __LINE__ << std::endl;

int main() {
    int* a_h = new int[num_elements];
    for(int i = 0; i < num_elements; i++) {
        a_h[i] = 0;
    }
    hipDeviceptr_t a_d;
    HIP_CHECK(hipInit(0));
    hipDevice_t device;
    hipCtx_t context;
    HIP_CHECK(hipDeviceGet(&device, 0));
    HIP_CHECK(hipCtxCreate(&context, 0, device));

    HIP_CHECK(hipMalloc((void**)&a_d, size));
    HIP_CHECK(hipMemcpyHtoD(a_d, a_h, size));

    hipModule_t module;
    hipFunction_t function;
    HIP_CHECK(hipModuleLoad(&module, FILE_NAME));
    HIP_CHECK(hipModuleGetFunction(&function, module, KERNEL_NAME));

    struct {
        void* in;
    } args;

    args.in = a_d;

    size_t size_of_args = sizeof(args);

    void* config[] = {HIP_LAUNCH_PARAM_BUFFER_POINTER, &args, HIP_LAUNCH_PARAM_BUFFER_SIZE, &size_of_args, HIP_LAUNCH_PARAM_END};

    hipModuleLaunchKernel(function, num_elements, 1, 1, 1, 1, 1, 0, 0, NULL, config);

    hipDeviceSynchronize();

    hipMemcpyDtoH(a_h, a_d, size);

    for(int i = 0; i < 16; i++) {
        std::cout << a_h[i] << " ";
    }
    std::cout << std::endl;
}
