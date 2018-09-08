.text
.globl hello_world
.p2align 8
.type hello_world,@function
hello_world:
	s_load_dwordx2 s[0:1], s[0:1], 0x0


	v_lshlrev_b32_e32 v0, 2, v0

	s_waitcnt lgkmcnt(0)


	v_mov_b32_e32 v2, s1

	v_add_co_u32_e64 v1, vcc, v0, s0

	v_addc_co_u32_e32 v2, vcc, 0, v2, vcc


	flat_load_dword v3, v[1:2]

	s_waitcnt vmcnt(0)

	v_mov_b32_e32 v4, 0

	v_add_f32_e32 v4, v3, v3


	flat_store_dword v[1:2], v4

  s_endpgm
.Lfunc_end0:
  .size   hello_world, .Lfunc_end0-hello_world

.rodata
.p2align 6
.amdhsa_kernel hello_world
  .amdhsa_user_sgpr_kernarg_segment_ptr 1
  .amdhsa_next_free_vgpr .amdgcn.next_free_vgpr
  .amdhsa_next_free_sgpr .amdgcn.next_free_sgpr
.end_amdhsa_kernel