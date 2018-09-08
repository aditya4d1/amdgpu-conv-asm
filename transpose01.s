//
// Transform from n c h w to
// n h w c using double buffering
//

// Pass in two pointers

/*
template<int n, int c, int h, int w>
__global__ void Kernel(float4_t* output, float4_t* input) {
    int in_id = threadIdx.x + blockIdx.y * h * w + blockIdx.z * c * h * w;
    float4_t val = input[in_id];
    int out_id1 = blockIdx.y + threadIdx.x * c + blockIdx.z * c * h * w;
    int out_id2 = out_id1 + c;
    int out_id3 = out_id2 + c;
    int out_id4 = out_id3 + c;
    float* output_scalar_ptr = reinterpret_cast<float*>(output);
    output_scalar_ptr[out_id1] = val.x;
    output_scalar_ptr[out_id2] = val.y;
    output_scalar_ptr[out_id3] = val.z;
    output_scalar_ptr[out_id4] = val.w;
}
*/

// 1024 float4s per workgroup
// h = 64, w = 64
// h * w = 4096
// c = 128
// n = 64


	.hsa_code_object_version 2,1
	.hsa_code_object_isa 9,0,0,"AMD","AMDGPU"
	.p2align	8
	.type	hello_world,@function
	.amdgpu_hsa_kernel hello_world
hello_world:
.Lfunc_begin0:
	.amd_kernel_code_t
    	amd_code_version_major = 1
		amd_code_version_minor = 1
		amd_machine_kind = 1
		amd_machine_version_major = 9
		amd_machine_version_minor = 0
		amd_machine_version_stepping = 0
        granulated_workitem_vgpr_count = 5
        granulated_wavefront_sgpr_count = 5
        enable_sgpr_kernarg_segment_ptr = 1
        float_mode = 192
        enable_ieee_mode = 1
        enable_trap_handler = 1
        is_ptr64 = 1
        compute_pgm_rsrc2_user_sgpr = 2
        kernarg_segment_byte_size = 16
        wavefront_sgpr_count = 10
        workitem_vgpr_count = 20
        enable_sgpr_workgroup_id_x = 1
	.end_amd_kernel_code_t

s_load_dwordx2 s[2:3], s[0:1] 0x0
s_mov_b32 s5, s2
s_mov_b32 s6, s3
s_mov_b32 s7, s4
s_load_dwordx2 s[0:1], s[0:1] 0x8

// threadIdx.x + blockIdx.y * h * w + blockIdx.z * c * h * w
s_mul_i32 s8, 64*64, s6
s_mul_i32 s9, 128*64*64, s7
s_add_i32 s8, s8, s9
v_add_u32 v1, s8, v0
v_lshlrev_b32 v1, 4, v1

// blockIdx.y + threadIdx.x * c + blockIdx.z * c * h * w
s_mul_i32 s8, 128*64*64, s7
s_add_i32 s8, s8, s6
v_add_u32 v2, s8, v0
v_lshlrev_b32 v2, 2, v2

s_waitcnt lgkmcnt(1)

v_mov_b32 v4, s3
v_add_co_u32 v3, vcc, v2, s2
v_addc_co_u32 v4, vcc, v4, 0, vcc

flat_load_dwordx4 v[5:5+3], v[3:4]

s_waitcnt lgkmcnt(0)

v_mov_b32 v10, s1
v_add_co_u32 v9, vcc, v2, s0
v_addc_co_u32 v10, vcc, v10, 0, vcc

s_mov_b32 s0, 128

v_add_co_u32 v11, vcc, v9, s0
v_addc_co_u32 v12, vcc, v10, 0, vcc

v_add_co_u32 v13, vcc, v11, s0
v_addc_co_u32 v14, vcc, v12, 0, vcc

v_add_co_u32 v15, vcc, v13, s0
v_addc_co_u32 v16, vcc, v14, 0, vcc

s_waitcnt vmcnt(0)

flat_store_dword v[9:10], v5
flat_store_dword v[11:12], v6
flat_store_dword v[13:14], v7
flat_store_dword v[15:16], v8
    s_endpgm
.Lfunc_end0:
	.size	hello_world, .Lfunc_end0-hello_world