#include <iostream>
#include <hip/hip_runtime_api.h>
#include <hip/hip_runtime.h>

constexpr int knum_filter_elements = 1;
constexpr int knum_image_elements = 128;
constexpr size_t ksize_of_filter_buffer = knum_filter_elements * sizeof(float);
constexpr size_t ksize_of_image_buffer = knum_image_elements * sizeof(float);

#define FILE_NAME "conv02.co"
#define KERNEL_NAME "hello_world"

#define HIP_CHECK(status) \
    if(status != hipSuccess) std::cerr << "Failed at : " << __LINE__ << std::endl;

int main() {
    float* filter_h = new float[knum_filter_elements];
    float* image_h = new float[knum_image_elements];
    float* output_h = new float[knum_image_elements];

    for(int i = 0; i < knum_filter_elements; i++) {
        filter_h[i] = 2.0f;
    }

    for(int i = 0; i < knum_image_elements; i++) {
        image_h[i] = 3.0f;
        output_h[i] = 1.0f;
    }

    hipDeviceptr_t filter_d, image_d, output_d;
    HIP_CHECK(hipInit(0));
    hipDevice_t device;
    hipCtx_t context;
    HIP_CHECK(hipDeviceGet(&device, 0));
    HIP_CHECK(hipCtxCreate(&context, 0, device));

    HIP_CHECK(hipMalloc((void**)&filter_d, ksize_of_filter_buffer));
    HIP_CHECK(hipMalloc((void**)&image_d, ksize_of_image_buffer));
    HIP_CHECK(hipMalloc((void**)&output_d, ksize_of_image_buffer));

    HIP_CHECK(hipMemcpyHtoD(filter_d, filter_h, ksize_of_filter_buffer));
    HIP_CHECK(hipMemcpyHtoD(image_d, image_h, ksize_of_image_buffer));
    HIP_CHECK(hipMemcpyHtoD(output_d, output_h, ksize_of_image_buffer));

    hipModule_t module;
    hipFunction_t function;
    HIP_CHECK(hipModuleLoad(&module, FILE_NAME));
    HIP_CHECK(hipModuleGetFunction(&function, module, KERNEL_NAME));

    struct {
        void* output;
        void* filter;
        void* image;
    } args;

    args.output = output_d;
    args.filter = filter_d;
    args.image = image_d;

    size_t size_of_args = sizeof(args);

    void* config[] = {HIP_LAUNCH_PARAM_BUFFER_POINTER, &args, HIP_LAUNCH_PARAM_BUFFER_SIZE, &size_of_args, HIP_LAUNCH_PARAM_END};

    hipModuleLaunchKernel(function, 1, 1, 1, int(knum_image_elements/4), 1, 1, 0, 0, NULL, config);

    hipDeviceSynchronize();

    hipMemcpyDtoH(output_h, output_d, ksize_of_image_buffer);

    for(int i = 0; i < knum_image_elements; i++) {
        std::cout << output_h[i] << " ";
    }
    std::cout << std::endl;
}
