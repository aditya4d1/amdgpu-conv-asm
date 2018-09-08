//
// Copyright - Aditya Atluri - 2018 to present
//

#include <iostream>
#include <hip/hip_runtime.h>
#include <hip/hip_runtime_api.h>
#include <fstream>

//
// On Vega64, L2 cache is 4MB
// So, for this test we launch 2 * 256 * 1024 workitems
// each working on a float4
//

#include <time.h>
#include <sys/time.h>
#define USECPSEC 1000000ULL

unsigned long long dtime_usec(unsigned long long start) {
    timeval tv;
    gettimeofday(&tv, 0);
    return ((tv.tv_sec*USECPSEC) + tv.tv_usec) - start;
}

typedef float Float4 __attribute__((ext_vector_type(4)));

constexpr int kiter = 1024 * 1024;
constexpr int knum_offset = 1024 * 256;

template<size_t offset>
__global__ void Kernel(Float4* Ad, Float4* Bd) {
    int tx = threadIdx.x;
    int bx = blockIdx.x;
    int tid = tx + bx * 256;

    Float4 a = {0.0f};

    for(int i = 0; i < kiter; i++) {

    Float4 tmp;
    asm volatile("\
    global_load_dwordx4 %0, %1, off\n \
    s_waitcnt vmcnt(0)\n\
    ":"=v"(tmp): "v"(Ad + tid + (i%16) * offset));
    }

    Bd[tid] = a;
}

__global__ void Kernel(Float4* Ad, Float4* Bd, int offset) {
    int tx = threadIdx.x;
    int bx = blockIdx.x;
    int tid = tx + bx * 256;

    Float4 a = {0.0f};

    for(int i = 0; i < kiter; i++) {
        Float4 tmp;
        asm volatile("global_load_dwordx4 %0, %1, off\n\
        s_waitcnt vmcnt(0)\n\
        ":"=v"(tmp):"v"(Ad+tid+(i%16)*offset));
    }
    Bd[tid] = a;
}

int main() {
    Float4* Ad, *Bd;
    hipMalloc(&Ad, sizeof(Float4)*16*256*1024);
    hipMalloc(&Bd, sizeof(Float4)*16*256*1024);
    hipLaunchKernelGGL((Kernel<256*1024>), dim3(1,1,1), dim3(256,1,1), 0, 0, Ad, Bd);
    hipDeviceSynchronize();

    unsigned long long dt = dtime_usec(0);
    hipLaunchKernelGGL((Kernel<256*1024>), dim3(1024,1,1), dim3(256,1,1), 0, 0, Ad, Bd);
    hipDeviceSynchronize();

    dt = dtime_usec(dt);

    unsigned long long bytes = sizeof(Float4) * 256 * 1024 * kiter;
    float et = dt / (float)USECPSEC;
    unsigned long long MB = bytes / 1000000;

    float tp = (MB) / (et * 1000000);

    std::cout<<"BW: "<<tp<<" TBps"<<std::endl;

    dt = dtime_usec(0);
    hipLaunchKernelGGL((Kernel<1024>), dim3(1024,1,1), dim3(256,1,1), 0, 0, Ad, Bd);
    hipDeviceSynchronize();

    dt = dtime_usec(dt);

    bytes = sizeof(Float4) * 256 * 1024 * kiter;
    et = dt / (float)USECPSEC;
    MB = bytes / 1000000;

    tp = (MB) / (et * 1000000);

    std::cout<<"BW: "<<tp<<" TBps"<<std::endl;

    dt = dtime_usec(0);
    hipLaunchKernelGGL((Kernel<0>), dim3(64,1,1), dim3(256,1,1), 0, 0, Ad, Bd);
    hipDeviceSynchronize();

    dt = dtime_usec(dt);

    bytes = sizeof(Float4) * 256 * 64 * kiter;
    et = dt / (float)USECPSEC;
    MB = bytes / 1000000;

    tp = (MB) / (et * 1000000);

    std::cout<<"BW: "<<tp<<" TBps"<<std::endl;

    std::ofstream file_csv;
    file_csv.open("data.csv");

    for(int i = 0; i < knum_offset; i += 32) {
        std::cout << "offset: " << i << std::endl;

        bytes = sizeof(Float4) * 256 * 64 * kiter;

        dt = dtime_usec(0);
        hipLaunchKernelGGL(Kernel, dim3(64,1,1), dim3(256,1,1), 0, 0, Ad, Bd, i);
        hipDeviceSynchronize();

        dt = dtime_usec(dt);

        et = dt / (float)USECPSEC;
        MB = bytes / 1000000;

        tp = (MB) / (et * 1000000);

        std::cout << "BW: " << tp << " TBps" << std::endl;        
        file_csv << tp <<","<<i<<"\n";
    }

    file_csv.close();

}
