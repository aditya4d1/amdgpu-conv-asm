//
// conv1x1 with output as c n h w
//

//
// For this kernel, we assume format n h w c and k c
//

//
// 64 elements per reduction = 16 float4_t,
// 1024 workitems -> 1024 / 16 = 64 channels per workgroup
//
// 56 * 16 = 896 workitems per workgroup
// So, a single width * channels can be run on a workgroup
// n * h * k number of workgroups should be launched
//

//
// dim3(16, 56, 1)
// dim3(h, n, k);

/*
__global__ void Kernel(float* output, float4_t* input, float4_t* filter) {
    int tx = threadIdx.x;
    int bx = blockIdx.x;
    int by = blockIdx.y;
    int bz = blockIdx.z;
    // c is 16
    float4_t val = input[tx + ty * 16 + bx * 16 * w + by * w * h * 16];
    float4_t filter = filter[tx + bz * 16];

    float dot_val = filter.x * val.x + filter.y * val.y + filter.z * val.z + filter.w * val.w;

    reduce_16_workitems(dot_val);

    if(tx == 0) {
        output[ty + bx * w + by * h * w + bz * n * h * w] = val;
    }
}
*/

//
// Next step, 
// double buffering
//

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
        enable_sgpr_workgroup_id_y = 1
        enable_sgpr_workgroup_id_z = 1
	.end_amd_kernel_code_t

//
// s6 = bx, s7 = by, s8 = bz
//

s_load_dwordx2 s[2:3], s[0:1] 0x8
s_mov_b32 s6, s2
s_mov_b32 s7, s3
s_mov_b32 s8, s4
s_load_dwordx2 s[4:5], s[0:1] 0x10
s_load_dwordx2 s[0:1], s[0:1] 0x0

//
// calculate input_id and put it in v2
//
v_lshlrev_b32 v2, 4, v1 // ty * 16
v_add_u32 v2, v2, v0 // tx + ty * 16
s_mul_i32 s9, s6, 16 * 64 // bx * 16 * c
v_add_u32 v2, v2, s9 // tx + ty * 16 + bx * 16 * c
s_mul_i32 s9, s7, 16 * 56 * 64 // by * c * h * 16
v_add_u32 v2, v2, s9 // tx + ty * 16 + bx * 16 * c + by * c * h * 16
v_lshlrev_b32 v2, 4, v2 // make input addressable to float4_t

//
// calculate filter_id and put it in v3
//
s_mul_i32 s9, s8, 16 // bz * c / 4
v_add_u32 v3, v0, s9 // tx + bz * c / 4
v_lshlrev_b32 v3, 4, v3 // make filter addressable to float4_t

// wait for input pointer to arrive
s_waitcnt lgkmcnt(2)

//
// v5, v6 stores input pointer
//
v_mov_b32 v6, s3
v_add_co_u32 v5, vcc, v2, s2
v_addc_co_u32 v6, vcc, v6, 0, vcc

// v7 -> v10 holds input data
flat_load_dwordx4 v[7:7+3], v[5:6]

// wait for filter pointer to arrive
s_waitcnt lgkmcnt(1)

// v11, v12 stores filter pointer
v_mov_b32 v12, s5
v_add_co_u32 v11, vcc, v3, s4
v_addc_co_u32 v12, vcc, v12, 0, vcc

// v13 -> v16 holds filter data
flat_load_dwordx4 v[13:13+3], v[11:12]

//
// calculate output_id and put it in v4
//
// ty + bx * h + by * h * w + bz * n * h * w
//
s_mul_i32 s9, s6, 56 // bx * h
v_add_u32 v4, v1, s9 // ty + bx * h
s_mul_i32 s9, s7, 56*56 // by * h * w
v_add_u32 v4, v4, s9 // ty + bx * h + by * h * w
s_mul_i32 s9, s8, 64 * 56 * 56 // bz * n * h * w
v_add_u32 v4, v4, s9 // ty + bx * h + by * h * w + bz * n * h * w
v_lshlrev_b32 v4, 2, v4 // make output pointer addressable to float

// wait for both input and filter data to arrive
s_waitcnt vmcnt(0)

v_mov_b32 v17, 0
v_mac_f32 v17, v7, v13
v_mac_f32 v17, v8, v14
v_mac_f32 v17, v9, v15
v_mac_f32 v17, v10, v16

s_nop 4
v_add_f32 v16, v17, v17 row_shr:1 bound_ctrl:0
s_nop 1
v_add_f32 v16, v17, v16 row_shr:2 bound_ctrl:0
s_nop 1
v_add_f32 v16, v17, v16 row_shr:3 bound_ctrl:0
s_nop 1
v_add_f32 v16, v16, v16 row_shr:4 bank_mask:0xe
s_nop 1
v_add_f32 v16, v16, v16 row_shr:8 bank_mask:0xc
s_nop 1

// wait for output pointer to arrive
s_waitcnt lgkmcnt(0)

// only v16, v4, s0, s1, v0 have useful data
// try to move this into branch
v_mov_b32 v15, s1
v_add_co_u32 v14, vcc, s0, v4
v_addc_co_u32 v15, vcc, 0, v15, vcc
v_cmp_eq_u32 vcc, v0, 0
s_cbranch_vccnz BB0_1

BB0_1:
    flat_store_dword v[14:15], v16
    s_endpgm
.Lfunc_end0:
	.size	hello_world, .Lfunc_end0-hello_world