	.text
	.hsa_code_object_version 2,1
	.hsa_code_object_isa 9,0,0,"AMD","AMDGPU"
	.weak	_Z6KernelILi64ELi64ELi56ELi14ELi64EEvPDv4_fS1_Pf ; -- Begin function _Z6KernelILi64ELi64ELi56ELi14ELi64EEvPDv4_fS1_Pf
	.p2align	8
	.type	_Z6KernelILi64ELi64ELi56ELi14ELi64EEvPDv4_fS1_Pf,@function
	.amdgpu_hsa_kernel _Z6KernelILi64ELi64ELi56ELi14ELi64EEvPDv4_fS1_Pf
_Z6KernelILi64ELi64ELi56ELi14ELi64EEvPDv4_fS1_Pf: ; @_Z6KernelILi64ELi64ELi56ELi14ELi64EEvPDv4_fS1_Pf
.Lfunc_begin0:
	.amd_kernel_code_t
		amd_code_version_major = 1
		amd_code_version_minor = 1
		amd_machine_kind = 1
		amd_machine_version_major = 9
		amd_machine_version_minor = 0
		amd_machine_version_stepping = 0
		kernel_code_entry_byte_offset = 256
		kernel_code_prefetch_byte_size = 0
		max_scratch_backing_memory_byte_size = 0
		granulated_workitem_vgpr_count = 8
		granulated_wavefront_sgpr_count = 2
		priority = 0
		float_mode = 192
		priv = 0
		enable_dx10_clamp = 1
		debug_mode = 0
		enable_ieee_mode = 1
		enable_sgpr_private_segment_wave_byte_offset = 0
		user_sgpr_count = 6
		enable_trap_handler = 1
		enable_sgpr_workgroup_id_x = 1
		enable_sgpr_workgroup_id_y = 1
		enable_sgpr_workgroup_id_z = 0
		enable_sgpr_workgroup_info = 0
		enable_vgpr_workitem_id = 0
		enable_exception_msb = 0
		granulated_lds_size = 0
		enable_exception = 0
		enable_sgpr_private_segment_buffer = 1
		enable_sgpr_dispatch_ptr = 0
		enable_sgpr_queue_ptr = 0
		enable_sgpr_kernarg_segment_ptr = 1
		enable_sgpr_dispatch_id = 0
		enable_sgpr_flat_scratch_init = 0
		enable_sgpr_private_segment_size = 0
		enable_sgpr_grid_workgroup_count_x = 0
		enable_sgpr_grid_workgroup_count_y = 0
		enable_sgpr_grid_workgroup_count_z = 0
		enable_ordered_append_gds = 0
		private_element_size = 1
		is_ptr64 = 1
		is_dynamic_callstack = 0
		is_debug_enabled = 0
		is_xnack_enabled = 0
		workitem_private_segment_byte_size = 0
		workgroup_group_segment_byte_size = 0
		gds_segment_byte_size = 0
		kernarg_segment_byte_size = 24
		workgroup_fbarrier_count = 0
		wavefront_sgpr_count = 21
		workitem_vgpr_count = 35
		reserved_vgpr_first = 0
		reserved_vgpr_count = 0
		reserved_sgpr_first = 0
		reserved_sgpr_count = 0
		debug_wavefront_private_segment_offset_sgpr = 0
		debug_private_segment_buffer_sgpr = 0
		kernarg_segment_alignment = 4
		group_segment_alignment = 4
		private_segment_alignment = 4
		wavefront_size = 6
		call_convention = -1
		runtime_loader_kernel_symbol = 0
	.end_amd_kernel_code_t
; %bb.0:                                ; %entry
	s_load_dwordx2 s[0:1], s[4:5], 0x0
	s_load_dwordx2 s[2:3], s[4:5], 0x8
	s_load_dwordx2 s[4:5], s[4:5], 0x10
	s_lshl_b32 s8, s7, 6
	s_ashr_i32 s9, s8, 31
	s_lshl_b64 s[8:9], s[8:9], 4
	v_lshlrev_b32_e32 v1, 4, v0
	s_waitcnt lgkmcnt(0)
	s_add_u32 s4, s4, s8
	s_addc_u32 s5, s5, s9
	s_add_u32 s8, s4, 64
	s_movk_i32 s6, 0x310
	v_mov_b32_e32 v2, s3
	v_add_co_u32_e32 v1, vcc, s2, v1
	s_mul_i32 s7, s7, s6
	v_addc_co_u32_e32 v2, vcc, 0, v2, vcc
	s_addc_u32 s9, s5, 0
	s_mov_b32 s10, 0
	v_mov_b32_e32 v3, 0
	s_mov_b32 s11, 0x9300
	s_movk_i32 s12, 0x6200
	s_movk_i32 s13, 0x3100
	s_mov_b32 s14, 0x18800
	s_mov_b32 s15, 0xc4000
BB0_1:                                  ; %for.body
                                        ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB0_3 Depth 2
	v_mov_b32_e32 v4, s4
	v_mov_b32_e32 v5, s5
	flat_load_dwordx4 v[13:16], v[4:5]
	v_mov_b32_e32 v4, v3
	v_mov_b32_e32 v5, v3
	v_mov_b32_e32 v6, v3
	v_mov_b32_e32 v7, v6
	v_mov_b32_e32 v6, v5
	s_mul_i32 s16, s10, 0xc400
	v_or_b32_e32 v8, s16, v0
	v_mov_b32_e32 v5, v4
	v_mov_b32_e32 v12, v2
	v_add_u32_e32 v9, 0xc40, v8
	s_mov_b64 s[16:17], s[8:9]
	v_mov_b32_e32 v11, v1
	s_mov_b32 s18, 4
	v_mov_b32_e32 v4, v3
	s_waitcnt vmcnt(0) lgkmcnt(0)
	s_branch BB0_3
BB0_2:                                  ; %for.body49
                                        ;   in Loop: Header=BB0_3 Depth=2
	v_mac_f32_e32 v4, v29, v13
	v_mac_f32_e32 v5, v30, v13
	v_mac_f32_e32 v6, v31, v13
	v_mac_f32_e32 v7, v32, v13
	v_mac_f32_e32 v7, v28, v14
	v_mac_f32_e32 v6, v27, v14
	v_mac_f32_e32 v5, v26, v14
	v_mac_f32_e32 v4, v25, v14
	s_add_i32 s18, s18, 8
	v_mac_f32_e32 v4, v21, v15
	v_mac_f32_e32 v5, v22, v15
	v_mac_f32_e32 v6, v23, v15
	v_mac_f32_e32 v7, v24, v15
	v_add_co_u32_e32 v11, vcc, s14, v11
	s_add_u32 s16, s16, 0x80
	v_add_u32_e32 v9, 0x1880, v9
	v_mac_f32_e32 v7, v20, v16
	v_mac_f32_e32 v6, v19, v16
	v_mac_f32_e32 v5, v18, v16
	v_mac_f32_e32 v4, v17, v16
	v_addc_co_u32_e32 v12, vcc, 0, v12, vcc
	s_addc_u32 s17, s17, 0
BB0_3:                                  ; %for.cond47
                                        ;   Parent Loop BB0_1 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	v_add_u32_e32 v21, s6, v9
	v_ashrrev_i32_e32 v22, 31, v21
	v_lshlrev_b64 v[29:30], 4, v[21:22]
	flat_load_dwordx4 v[21:24], v[11:12]
	v_add_co_u32_e32 v17, vcc, s11, v11
	v_addc_co_u32_e32 v18, vcc, 0, v12, vcc
	v_add_co_u32_e32 v25, vcc, s13, v11
	v_addc_co_u32_e32 v26, vcc, 0, v12, vcc
	v_add_co_u32_e32 v27, vcc, s12, v11
	v_addc_co_u32_e32 v28, vcc, 0, v12, vcc
	flat_load_dwordx4 v[17:20], v[17:18]
	v_ashrrev_i32_e32 v10, 31, v9
	v_mov_b32_e32 v32, s3
	v_add_u32_e32 v31, 0x620, v9
	v_mov_b32_e32 v33, s3
	v_mov_b32_e32 v34, s3
	s_cmp_gt_u32 s18, 63
	s_waitcnt vmcnt(0) lgkmcnt(0)
	v_mad_f32 v4, v13, v21, v4
	v_mad_f32 v5, v13, v22, v5
	v_mad_f32 v6, v13, v23, v6
	v_mac_f32_e32 v7, v13, v24
	flat_load_dwordx4 v[21:24], v[25:26]
	s_nop 0
	flat_load_dwordx4 v[25:28], v[27:28]
	s_waitcnt vmcnt(0) lgkmcnt(0)
	v_mac_f32_e32 v7, v14, v24
	v_mac_f32_e32 v6, v14, v23
	v_mac_f32_e32 v5, v14, v22
	v_mac_f32_e32 v4, v14, v21
	v_lshlrev_b64 v[13:14], 4, v[9:10]
	v_add_co_u32_e32 v13, vcc, s2, v13
	v_mac_f32_e32 v4, v15, v25
	v_addc_co_u32_e32 v14, vcc, v32, v14, vcc
	v_mac_f32_e32 v5, v15, v26
	v_mac_f32_e32 v6, v15, v27
	v_mac_f32_e32 v7, v15, v28
	v_mac_f32_e32 v4, v16, v17
	v_add_co_u32_e32 v17, vcc, s2, v29
	v_ashrrev_i32_e32 v32, 31, v31
	v_mac_f32_e32 v5, v16, v18
	v_mac_f32_e32 v7, v16, v20
	v_mac_f32_e32 v6, v16, v19
	v_add_u32_e32 v15, 0x930, v9
	v_addc_co_u32_e32 v18, vcc, v33, v30, vcc
	v_lshlrev_b64 v[19:20], 4, v[31:32]
	v_ashrrev_i32_e32 v16, 31, v15
	v_add_co_u32_e32 v21, vcc, s2, v19
	v_addc_co_u32_e32 v22, vcc, v34, v20, vcc
	v_lshlrev_b64 v[15:16], 4, v[15:16]
	v_mov_b32_e32 v34, s17
	v_mov_b32_e32 v10, s3
	v_add_co_u32_e32 v15, vcc, s2, v15
	v_addc_co_u32_e32 v16, vcc, v10, v16, vcc
	v_mov_b32_e32 v33, s16
	flat_load_dwordx4 v[25:28], v[17:18]
	s_nop 0
	flat_load_dwordx4 v[29:32], v[13:14]
	s_nop 0
	flat_load_dwordx4 v[17:20], v[15:16]
	s_nop 0
	flat_load_dwordx4 v[21:24], v[21:22]
	s_nop 0
	flat_load_dwordx4 v[13:16], v[33:34]
	s_waitcnt vmcnt(0) lgkmcnt(0)
	s_cbranch_scc0 BB0_2
; %bb.4:                                ; %for.end
                                        ;   in Loop: Header=BB0_1 Depth=1
	v_add_u32_e32 v8, s7, v8
	v_ashrrev_i32_e32 v9, 31, v8
	v_lshlrev_b64 v[8:9], 4, v[8:9]
	v_mac_f32_e32 v4, v29, v13
	v_mac_f32_e32 v5, v30, v13
	v_mac_f32_e32 v6, v31, v13
	v_mac_f32_e32 v7, v32, v13
	v_mov_b32_e32 v10, s1
	v_add_co_u32_e32 v8, vcc, s0, v8
	v_mac_f32_e32 v7, v28, v14
	v_mac_f32_e32 v6, v27, v14
	v_mac_f32_e32 v5, v26, v14
	v_mac_f32_e32 v4, v25, v14
	v_addc_co_u32_e32 v9, vcc, v10, v9, vcc
	v_mac_f32_e32 v4, v21, v15
	v_mac_f32_e32 v5, v22, v15
	v_mac_f32_e32 v6, v23, v15
	v_mac_f32_e32 v7, v24, v15
	s_add_i32 s10, s10, 1
	v_add_co_u32_e32 v1, vcc, s15, v1
	v_mac_f32_e32 v7, v20, v16
	v_mac_f32_e32 v6, v19, v16
	v_mac_f32_e32 v5, v18, v16
	v_mac_f32_e32 v4, v17, v16
	s_cmp_lg_u32 s10, 64
	v_addc_co_u32_e32 v2, vcc, 0, v2, vcc
	flat_store_dwordx4 v[8:9], v[4:7]
	s_waitcnt vmcnt(0) lgkmcnt(0)
	s_cbranch_scc1 BB0_1
; %bb.5:                                ; %for.end281
	s_endpgm
.Lfunc_end0:
	.size	_Z6KernelILi64ELi64ELi56ELi14ELi64EEvPDv4_fS1_Pf, .Lfunc_end0-_Z6KernelILi64ELi64ELi56ELi14ELi64EEvPDv4_fS1_Pf
                                        ; -- End function
	.section	.AMDGPU.csdata
; Kernel info:
; codeLenInByte = 768
; NumSgprs: 21
; NumVgprs: 35
; ScratchSize: 0
; FloatMode: 192
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 2
; VGPRBlocks: 8
; NumSGPRsForWavesPerEU: 21
; NumVGPRsForWavesPerEU: 35
; ReservedVGPRFirst: 0
; ReservedVGPRCount: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 6
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 1
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0

	.ident	"HCC clang version 7.0.0 (ssh://gerritgit/compute/ec/hcc-tot/clang 86791fc4961dc8ffde77bde20d7dfa5e5cbeff5e) (ssh://gerritgit/compute/ec/hcc-tot/llvm c1f9263485c0192d7af512ac2c7dd15d5082538e) (based on HCC 1.2.18272-47899bc-86791fc-c1f9263 )"
	.section	".note.GNU-stack"
	.amd_amdgpu_isa "amdgcn--amdhsa-amdgiz-gfx900"
	.amd_amdgpu_hsa_metadata
---
Version:         [ 1, 0 ]
Printf:          
  - '1:3:unknown'
  - '2:3:unknown'
  - '3:3:unknown'
  - '4:3:unknown'
  - '5:3:unknown'
  - '6:3:unknown'
  - '7:3:unknown'
Kernels:         
  - Name:            _Z6KernelILi64ELi64ELi56ELi14ELi64EEvPDv4_fS1_Pf
    SymbolName:      '_Z6KernelILi64ELi64ELi56ELi14ELi64EEvPDv4_fS1_Pf@kd'
    Language:        OpenCL C
    LanguageVersion: [ 2, 0 ]
    Args:            
      - Name:            output
        Size:            8
        Align:           8
        ValueKind:       GlobalBuffer
        ValueType:       F32
        AddrSpaceQual:   Generic
      - Name:            input
        Size:            8
        Align:           8
        ValueKind:       GlobalBuffer
        ValueType:       F32
        AddrSpaceQual:   Generic
      - Name:            filter
        Size:            8
        Align:           8
        ValueKind:       GlobalBuffer
        ValueType:       F32
        AddrSpaceQual:   Generic
      - Size:            8
        Align:           8
        ValueKind:       HiddenGlobalOffsetX
        ValueType:       I64
      - Size:            8
        Align:           8
        ValueKind:       HiddenGlobalOffsetY
        ValueType:       I64
      - Size:            8
        Align:           8
        ValueKind:       HiddenGlobalOffsetZ
        ValueType:       I64
      - Size:            8
        Align:           8
        ValueKind:       HiddenPrintfBuffer
        ValueType:       I8
        AddrSpaceQual:   Global
    CodeProps:       
      KernargSegmentSize: 24
      GroupSegmentFixedSize: 0
      PrivateSegmentFixedSize: 0
      KernargSegmentAlign: 8
      WavefrontSize:   64
      NumSGPRs:        21
      NumVGPRs:        35
      MaxFlatWorkGroupSize: 256
...

	.end_amd_amdgpu_hsa_metadata
