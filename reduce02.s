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
//
// In this example, we try to implement double buffered (pre-fetching) wavefront reduce
//


//
// First, we load first half of the buffer to vgprs but does not wait for it.
// Then, load second half of the buffer to vgprs but does not wait for it.
// We then, wait for first half of the buffer to come in.
// Do wavefront reduce on it.
// Wait for the second half of the buffer to come in.
// Do wavefront reduce on it.
//

/*
// length = 1024 * 1024 * 64 floats
// vector buffer length = 1024 * 1024 * 16
// half of vector buffer length = 1024 * 1024 * 8
// each workgroup does 1024 vectors
// total workgroups = 1024 * 1024 * 8 / 1024
__global__ void hello_world(float* output, float4_t* input) {
    int tx = threadIdx.x;
    int bx = blockIdx.x;
    int index = tx + bx * 1024;
    float4_t v1 = input[index];
    wavefront_reduce(v1);
    output[bx] = v1.x + v1.y + v1.z + v1.w;
}
*/

// As we are loading float4, = 16 bytes = 1 << 4
// shift left by 4 always
//    s_lshl_b32 s4, 1, s2 // for input indexing (1024 * sizeof(float4_t))
//    s_lshl_b32 s5, 2, s2 // for output indexing
    s_mul_i32 s4, s2, 1024 * 16
    s_mul_i32 s5, s2, 1024 * 4
    s_load_dwordx2 s[2:3], s[0:1], 0x8 // load input pointer
    s_load_dwordx2 s[0:1], s[0:1], 0x0 // load output pointer
    v_lshlrev_b32 v1, 4, v0
    v_add_u32 v1, v1, s4 // index
    s_waitcnt lgkmcnt(1) // just wait for input pointer

    v_mov_b32 v3, s3
    v_add_co_u32 v2, vcc, v1, s2
    v_addc_co_u32 v3, vcc, v3, 0, vcc
    flat_load_dwordx4 v[6:6+3], v[2:3] // 6 to 9 for first load

    // move output index to v1
    v_lshlrev_b32 v1, 2, v0
    v_add_u32 v1, v1, s5

    // reuse vgprs 2, 3 for output store
    v_mov_b32 v3, s1
    v_add_co_u32 v2, vcc, s0, v1
    v_addc_co_u32 v3, vcc, v3, 0, vcc

    s_waitcnt lgkmcnt(0)
// wait until output ptr is known
// this can't be pushed down as the pointer arithmetic can
// decrease perf

    v_add_f32 v14, v6, v7
    v_add_f32 v14, v8, v14
    v_add_f32 v14, v9, v14

    // add dpp code here

    s_nop 4
    v_add_f32 v15, v14, v14 row_shr:1 bound_ctrl:0
    s_nop 1
    v_add_f32 v15, v14, v15 row_shr:2 bound_ctrl:0
    s_nop 1
    v_add_f32 v15, v14, v15 row_shr:3 bound_ctrl:0
    s_nop 1
    v_add_f32 v15, v15, v15 row_shr:4 bank_mask:0xe
    s_nop 1
    v_add_f32 v15, v15, v15 row_shr:8 bank_mask:0xc
    s_nop 1
    v_add_f32 v15, v15, v15 row_bcast:15 row_mask:0xa
    s_nop 1
    v_add_f32 v15, v15, v15 row_bcast:31 row_mask:0xc
    s_nop 1

    flat_store_dword v[2:3], v15
    s_endpgm
.Lfunc_end0:
	.size	hello_world, .Lfunc_end0-hello_world
