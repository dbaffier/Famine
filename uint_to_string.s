	.file	"uint_to_string.c"
	.intel_syntax noprefix
	.text
	.globl	uint_to_string
	.type	uint_to_string, @function
uint_to_string:
.LFB2:
	.cfi_startproc
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	mov	rbp, rsp
	.cfi_def_cfa_register 6
	sub	rsp, 32
	mov	QWORD PTR [rbp-24], rdi
	mov	edi, 50
	call	malloc
	mov	QWORD PTR [rbp-8], rax
	mov	DWORD PTR [rbp-12], 0
	jmp	.L2
.L5:
	mov	rax, QWORD PTR [rbp-24]
	and	eax, 15
	mov	BYTE PTR [rbp-13], al
	cmp	BYTE PTR [rbp-13], 9
	jg	.L3
	movzx	eax, BYTE PTR [rbp-13]
	add	eax, 48
	mov	BYTE PTR [rbp-13], al
	jmp	.L4
.L3:
	movzx	eax, BYTE PTR [rbp-13]
	add	eax, 55
	mov	BYTE PTR [rbp-13], al
.L4:
	mov	rax, QWORD PTR [rbp-24]
	shr	rax, 4
	mov	QWORD PTR [rbp-24], rax
	mov	eax, DWORD PTR [rbp-12]
	movsx	rdx, eax
	mov	rax, QWORD PTR [rbp-8]
	add	rdx, rax
	movzx	eax, BYTE PTR [rbp-13]
	mov	BYTE PTR [rdx], al
	add	DWORD PTR [rbp-12], 1
.L2:
	cmp	QWORD PTR [rbp-24], 9
	ja	.L5
	mov	eax, DWORD PTR [rbp-12]
	movsx	rdx, eax
	mov	rax, QWORD PTR [rbp-8]
	add	rax, rdx
	mov	BYTE PTR [rax], 0
	mov	rax, QWORD PTR [rbp-8]
	mov	rdi, rax
	call	puts
	nop
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE2:
	.size	uint_to_string, .-uint_to_string
	.globl	main
	.type	main, @function
main:
.LFB3:
	.cfi_startproc
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	mov	rbp, rsp
	.cfi_def_cfa_register 6
	sub	rsp, 16
	movabs	rax, 730533494865776361
	mov	QWORD PTR [rbp-8], rax
	mov	rax, QWORD PTR [rbp-8]
	mov	rdi, rax
	call	uint_to_string
	mov	eax, 0
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE3:
	.size	main, .-main
	.ident	"GCC: (Ubuntu 5.4.0-6ubuntu1~16.04.12) 5.4.0 20160609"
	.section	.note.GNU-stack,"",@progbits
