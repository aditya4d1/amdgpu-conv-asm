#include <iostream>
#include <hip/hip_runtime.h>
#include <hip/hip_runtime_api.h>

#include <time.h>
#include <sys/time.h>
#define USECPSEC 1000000ULL

unsigned long long dtime_usec(unsigned long long start) {
    timeval tv;
    gettimeofday(&tv, 0);
    return ((tv.tv_sec*USECPSEC) + tv.tv_usec) - start;
}

constexpr int knum_iter = 1024;

typedef float float4_t __attribute__((ext_vector_type(4)));

template<int N, int C, int H, int W, int K>
__global__ void Kernel(float4_t* output, float4_t* input, float* filter) {
    int tx = threadIdx.x;
    int bx = blockIdx.x;
    int by = blockIdx.y;
    // H * W = workitems
    // K = workgroups

    for(int n = 0; n < N; n++) {
        float4_t out = {0};
        int c = 0;
        float4_t a[4], fil_a, b[4], fil_b;
        a[0] = input[n * C * H * W + c * H * W + tx];
        a[1] = input[n * C * H * W + (c+1) * H * W + tx];
        a[2] = input[n * C * H * W + (c+2) * H * W + tx];
        a[3] = input[n * C * H * W + (c+3) * H * W + tx];
        fil_a = reinterpret_cast<float4_t*>(filter)[by * C + c];
        c+= 4;
        for(; c < C; c+=8) {

            b[0] = input[n * C * H * W + c * H * W + tx];
            b[1] = input[n * C * H * W + (c+1) * H * W + tx];
            b[2] = input[n * C * H * W + (c+2) * H * W + tx];
            b[3] = input[n * C * H * W + (c+3) * H * W + tx];

            fil_b = reinterpret_cast<float4_t*>(filter)[by * C + c];

            out += a[0] * fil_a.x;
            out += a[1] * fil_a.y;
            out += a[2] * fil_a.z;
            out += a[3] * fil_a.w;

            a[0] = input[n * C * H * W + (c+4) * H * W + tx];
            a[1] = input[n * C * H * W + (c+5) * H * W + tx];
            a[2] = input[n * C * H * W + (c+6) * H * W + tx];
            a[3] = input[n * C * H * W + (c+7) * H * W + tx];

            fil_a = reinterpret_cast<float4_t*>(filter)[by * C + c];

            out += b[0] * fil_b.x;
            out += b[1] * fil_b.y;
            out += b[2] * fil_b.z;
            out += b[3] * fil_b.w;
        }
        b[0] = input[n * C * H * W + c * H * W + tx];
        b[1] = input[n * C * H * W + (c+1) * H * W + tx];
        b[2] = input[n * C * H * W + (c+2) * H * W + tx];
        b[3] = input[n * C * H * W + (c+3) * H * W + tx];

        fil_b = reinterpret_cast<float4_t*>(filter)[by * C + c];

        out += a[0] * fil_a.x;
        out += a[1] * fil_a.y;
        out += a[2] * fil_a.z;
        out += a[3] * fil_a.w;

        out += b[0] * fil_b.x;
        out += b[1] * fil_b.y;
        out += b[2] * fil_b.z;
        out += b[3] * fil_b.w;

/*
            a[0] = input[n * C * H * W + c * H * W + tx];
            a[1] = input[n * C * H * W + (c + 1) * H * W + tx];
            a[2] = input[n * C * H * W + (c + 2) * H * W + tx];
            a[3] = input[n * C * H * W + (c + 3) * H * W + tx];


    fil = *(reinterpret_cast<float4_t*>(filter) + by * C + c);

            asm volatile("\n\
    flat_load_dwordx4 %0, %4\n\
    flat_load_dwordx4 %1, %5\n\
    flat_load_dwordx4 %2, %6\n\
    flat_load_dwordx4 %3, %7\n\
    "
    :"=v"(a[0]), "=v"(a[1]), "=v"(a[2]), "=v"(a[3])
    :"v"(input + (n*C*H*W+c*H*W+tx)), "v"(input + (n*C*H*W+(c+1)*H*W+tx)), "v"(input+(n*C*H*W+(c+2)*H*W)), "v"(input+(n*C*H*W+(c+3)*H*W))
    );

    asm volatile("\n\
    s_waitcnt vmcnt(3)\n\
    v_mad_f32 %0, %4, %8, %0\n\
    v_mad_f32 %1, %5, %8, %1\n\
    v_mad_f32 %2, %6, %8, %2\n\
    v_mad_f32 %3, %7, %8, %3\n\
    ":"=v"(out.x), "=v"(out.y), "=v"(out.z), "=v"(out.w)
    :"v"(a[0].x), "v"(a[0].y), "v"(a[0].z), "v"(a[0].w),"v"(fil.x)
    );
    asm volatile("\n\
    s_waitcnt vmcnt(2)\n\
    v_mad_f32 %0, %4, %8, %0\n\
    v_mad_f32 %1, %5, %8, %1\n\
    v_mad_f32 %2, %6, %8, %2\n\
    v_mad_f32 %3, %7, %8, %3\n\
    ":"=v"(out.x), "=v"(out.y), "=v"(out.z), "=v"(out.w)
    :"v"(a[1].x), "v"(a[1].y), "v"(a[1].z), "v"(a[1].w),"v"(fil.x)
    );
    asm volatile("\n\
    s_waitcnt vmcnt(1)\n\
    v_mad_f32 %0, %4, %8, %0\n\
    v_mad_f32 %1, %5, %8, %1\n\
    v_mad_f32 %2, %6, %8, %2\n\
    v_mad_f32 %3, %7, %8, %3\n\
    ":"=v"(out.x), "=v"(out.y), "=v"(out.z), "=v"(out.w)
    :"v"(a[2].x), "v"(a[2].y), "v"(a[2].z), "v"(a[2].w),"v"(fil.x)
    );
    asm volatile("\n\
    s_waitcnt vmcnt(0)\n\
    v_mad_f32 %0, %4, %8, %0\n\
    v_mad_f32 %1, %5, %8, %1\n\
    v_mad_f32 %2, %6, %8, %2\n\
    v_mad_f32 %3, %7, %8, %3\n\
    ":"=v"(out.x), "=v"(out.y), "=v"(out.z), "=v"(out.w)
    :"v"(a[3].x), "v"(a[3].y), "v"(a[3].z), "v"(a[3].w),"v"(fil.x)
    );
*/
        output[n * K * H * W + by * H * W + tx] = out;
    }
}

int main() {
    constexpr int N = 64, C = 64, H = 56, W = 56, K = 64;
    float4_t *output, *input;
    float *filter;
    hipMalloc(&output, sizeof(float) * N * K * H * W);
    hipMalloc(&input, sizeof(float) * N * C * H * W);
    hipMalloc(&filter, sizeof(float) * K * C);

    hipEvent_t start, stop;
    hipEventCreate(&start);
    hipEventCreate(&stop);

    hipEventRecord(start);
    hipLaunchKernelGGL((Kernel<N,C,H,W/4,K>), dim3(1,K,1), dim3(W*H/4,1,1), 0, 0, output, input,filter);
    hipEventRecord(stop);

    hipEventSynchronize(stop);
    float mss = 0.0f;
    hipEventElapsedTime(&mss, start, stop);
    std::cout << double(mss) << std::endl;
    std::cout << (double(N * C * H * W * sizeof(float)))/ double(mss * 1024 * 1024 * 1024) << std::endl;
    std::cout << (double(N * C * K * 2)) / double(mss * 1024 * 1024 * 1024) << std::endl;
}
