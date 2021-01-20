	.file	"main.c"
	.intel_syntax noprefix
	.text
	.globl	main
	.type	main, @function
main:
.LFB2:
	.cfi_startproc
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	mov	rbp, rsp
	.cfi_def_cfa_register 6
	sub	rsp, 80
	mov	rax, QWORD PTR fs:40
	mov	QWORD PTR [rbp-8], rax
	xor	eax, eax
	movabs	rax, 52104118038575
	mov	QWORD PTR [rbp-64], rax
	lea	rdx, [rbp-56]
	mov	eax, 0
	mov	ecx, 5
	mov	rdi, rdx
	rep stosq
	mov	rdx, rdi
	mov	WORD PTR [rdx], ax
	add	rdx, 2
	mov	DWORD PTR [rbp-68], 0
	jmp	.L2
.L3:
	mov	eax, DWORD PTR [rbp-68]
	add	eax, 6
	cdqe
	mov	BYTE PTR [rbp-64+rax], 99
	add	DWORD PTR [rbp-68], 1
.L2:
	cmp	DWORD PTR [rbp-68], 2
	jle	.L3
	mov	eax, 0
	mov	rsi, QWORD PTR [rbp-8]
	xor	rsi, QWORD PTR fs:40
	je	.L5
	call	__stack_chk_fail
.L5:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE2:
	.size	main, .-main
	.ident	"GCC: (Ubuntu 5.4.0-6ubuntu1~16.04.12) 5.4.0 20160609"
	.section	.note.GNU-stack,"",@progbits
