#include <iostream>
#include <hip/hip_runtime_api.h>
#include <hip/hip_runtime.h>

constexpr int knum_elements = 1024 * 1024 * 64;
constexpr size_t ksize_of_buffer = knum_elements * sizeof(float);

#define FILE_NAME "reduce01.co"
#define KERNEL_NAME "hello_world"

#define HIP_CHECK(status) \
    if(status != hipSuccess) std::cerr << "Failed at : " << __LINE__ << std::endl;

int main() {
    float* input_h = new float[knum_elements];
    float* output_h = new float[knum_elements];

    for(int i = 0; i < knum_elements; i++) {
        input_h[i] = 1.0f;
        output_h[i] = 0.0f;
    }

    hipDeviceptr_t input_d, output_d;
    HIP_CHECK(hipInit(0));
    hipDevice_t device;
    hipCtx_t context;
    HIP_CHECK(hipDeviceGet(&device, 0));
    HIP_CHECK(hipCtxCreate(&context, 0, device));

    HIP_CHECK(hipMalloc((void**)&input_d, ksize_of_buffer));
    HIP_CHECK(hipMalloc((void**)&output_d, ksize_of_buffer));

    HIP_CHECK(hipMemcpyHtoD(input_d, input_h, ksize_of_buffer));
    HIP_CHECK(hipMemcpyHtoD(output_d, output_h, ksize_of_buffer));

    hipModule_t module;
    hipFunction_t function;
    HIP_CHECK(hipModuleLoad(&module, FILE_NAME));
    HIP_CHECK(hipModuleGetFunction(&function, module, KERNEL_NAME));

    struct {
        void* output;
        void* input;
    } args;

    args.output = output_d;
    args.input = input_d;

    size_t size_of_args = sizeof(args);

    void* config[] = {HIP_LAUNCH_PARAM_BUFFER_POINTER, &args, HIP_LAUNCH_PARAM_BUFFER_SIZE, &size_of_args, HIP_LAUNCH_PARAM_END};

    auto start = std::chrono::high_resolution_clock::now();

    hipModuleLaunchKernel(function, (1024 * 8), 1, 1, int(1024), 1, 1, 0, 0, NULL, config);

    hipDeviceSynchronize();

    auto stop = std::chrono::high_resolution_clock::now();

    double sec = std::chrono::duration_cast<std::chrono::duration<double>>(stop - start).count();



    hipMemcpyDtoH(output_h, output_d, ksize_of_buffer);

    std::cout << sec << std::endl;
    double bw = double(ksize_of_buffer) / double(sec) / double(1024 * 1024 * 1024);
    std::cout << bw << std::endl;
}
