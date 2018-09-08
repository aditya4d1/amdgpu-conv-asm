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
        enable_sgpr_kernarg_segment_ptr = 1
        float_mode = 192
        enable_ieee_mode = 1
        enable_trap_handler = 1
        is_ptr64 = 1
        compute_pgm_rsrc2_user_sgpr = 2
        kernarg_segment_byte_size = 8
        wavefront_sgpr_count = 4
        workitem_vgpr_count = 4
        enable_sgpr_workgroup_id_x = 1
	.end_amd_kernel_code_t
    s_load_dwordx2 s[0:1], s[0:1], 0x0
    s_waitcnt lgkmcnt(0)
    s_mul_i32 s2, s2, 4
    s_add_u32 s0, s2, s0
    s_addc_u32 s1, 0, s1
    s_load_dword s2, s[0:1]
    s_waitcnt lgkmcnt(0)
    s_add_i32 s2, s2, 1
    s_store_dword s2, s[0:1], 0x0 glc
	s_endpgm
.Lfunc_end0:
	.size	hello_world, .Lfunc_end0-hello_world