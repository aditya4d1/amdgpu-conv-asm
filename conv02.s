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
        kernarg_segment_byte_size = 24
        wavefront_sgpr_count = 10
        workitem_vgpr_count = 20
        enable_sgpr_workgroup_id_x = 1
	.end_amd_kernel_code_t
//
// In this example, we load filter to sgprs,
// image to vgprs and do a simple mac operation
//

    s_lshl_b32 s6, 2, s2
    s_load_dwordx2 s[2:3], s[0:1], 0x8 // load filter pointer
    s_load_dwordx2 s[4:5], s[0:1], 0x10 // load input pointer
    s_load_dwordx2 s[0:1], s[0:1], 0x0 // load output pointer

    v_lshlrev_b32 v0, 4, v0
    s_waitcnt lgkmcnt(0)
    s_add_u32 s6, s6, s2
    s_addc_u32 s7, 0, s7
    s_load_dword s7, s[6:7]

    v_mov_b32 v2, s1
    v_add_co_u32 v1, vcc, v0, s0
    v_addc_co_u32 v2, vcc, v2, 0, vcc
    flat_load_dwordx4 v[7:7+3], v[1:2]

    v_mov_b32 v4, s5
    v_add_co_u32 v3, vcc, v0, s4
    v_addc_co_u32 v4, vcc, v4, 0, vcc
    flat_load_dwordx4 v[3:3+3], v[3:4]

    s_waitcnt vmcnt(0) lgkmcnt(0)
    v_mac_f32 v7, v3, s7
    v_mac_f32 v8, v4, s7
    v_mac_f32 v9, v5, s7
    v_mac_f32 v10, v6, s7
    flat_store_dwordx4 v[1:2], v[7:7+3]
/**
typedef float float4_t __attribute__((ext_vector_type(4)));

__global__ void hello_world(float4_t* poutput, float* pfilter, float4_t* pimage) {
    int tx = threadIdx.x;
    int bx = blockIdx.x;
    float4 img = pimage[tx];
    float fil = pfilter[bx];
    float4 out{img.x * fil, img.y * fil, img.z * fil, img.w * fil};
    poutput[tx] = out;
}
*/

//
// The order in which the arguments are laid out
// in memory is output, filter, input
//
// The argument pointers are present in s[0:1]
//
// workgroup index in x dimension is in s2
//
// input image pointer is loaded into s[6:7]
// filter image is loaded into s[4:5]
// output image is loaded into s[0:1]
//
// s3 contains the index for accessing a float4 filter
// each filter element is loaded to s8
//

//
// vector alu pipe
//
// v0 is threadIdx.x
// v1 is pointer offset for input image
// v2 is pointer offset for output image
// v3, v4 are pointers to input image
// v5, v6 are pointers to output image
// v7,8,9,10 used for loading the image
// v11,12,13,14 used for computing the output
//

/*
// load filter and input image pointers
// to s4,5,6,7
    s_load_dwordx4 s[4:4+3], s[0:1], 0x8
    s_load_dwordx2 s[0:1], s[0:1], 0x0
// reset vgprs to 0 so that fmacs don't
// provide bad result
    v_mov_b32 v11, 0
    v_mov_b32 v12, 0
    v_mov_b32 v13, 0
    v_mov_b32 v14, 0
// compute pointer offset for filter
// as sizeof(float4) = 1 << 4 = 16
    s_lshl_b32 s3, 4, s2
// compute pointer offset for input image
    v_lshlrev_b32 v1, 4, v0
// compute pointer offset for output image
    v_lshlrev_b32 v2, 4, v0

// wait for filter and image pointers get loaded
    s_waitcnt lgkmcnt(1)

// compute filter pointer
    s_add_u32 s4, s4, s3
    s_addc_u32 s5, s5, 0

// load filter
    s_load_dword s8, s[4:5]

// compute image pointer
    v_mov_b32 v4, s7
    v_add_co_u32 v3, vcc, v1, s6
    v_addc_co_u32 v4, vcc, 0, v4, vcc

// wait for output argument to be loaded
    s_waitcnt lgkmcnt(1)

// compute output pointer
    v_mov_b32 v6, s1
    v_add_co_u32 v5, vcc, v0, s0
    v_addc_co_u32 v6, vcc, 0, v6, vcc

// load input image
    flat_load_dwordx4 v[7:10], v[3:4]

// wait for image and filter loads
    s_waitcnt lgkmcnt(0) vmcnt(0)

    v_mac_f32 v11, v7, s8
    v_mac_f32 v12, v8, s8
    v_mac_f32 v13, v9, s8
    v_mac_f32 v14, v10, s8


    flat_store_dwordx4 v[5:6], v[11:11+3]
*/
	s_endpgm
.Lfunc_end0:
	.size	hello_world, .Lfunc_end0-hello_world
