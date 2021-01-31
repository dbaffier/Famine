	.file	"main.c"
	.intel_syntax noprefix
	.text
	.globl	FNV32
	.type	FNV32, @function
FNV32:
.LFB2:
	.cfi_startproc
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	mov	rbp, rsp
	.cfi_def_cfa_register 6
	mov	QWORD PTR [rbp-24], rdi
	movabs	rax, -3750763034362895579
	mov	QWORD PTR [rbp-8], rax
	mov	DWORD PTR [rbp-16], 21
	mov	DWORD PTR [rbp-12], 0
	jmp	.L2
.L3:
	mov	edx, DWORD PTR [rbp-12]
	mov	rax, QWORD PTR [rbp-24]
	add	rax, rdx
	movzx	eax, BYTE PTR [rax]
	movsx	rax, al
	xor	QWORD PTR [rbp-8], rax
	mov	rdx, QWORD PTR [rbp-8]
	movabs	rax, 1099511628211
	imul	rax, rdx
	mov	QWORD PTR [rbp-8], rax
	sub	DWORD PTR [rbp-16], 1
	add	DWORD PTR [rbp-12], 1
.L2:
	cmp	DWORD PTR [rbp-16], 0
	jne	.L3
	mov	rax, QWORD PTR [rbp-8]
	pop	rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE2:
	.size	FNV32, .-FNV32
	.section	.rodata
.LC0:
	.string	"PQRH\211\341H\211\354]XH\215\025M"
	.string	""
	.string	""
	.string	"RR\303"
.LC1:
	.string	"1: %lx\n"
	.text
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
	mov	QWORD PTR [rbp-16], OFFSET FLAT:.LC0
	mov	rax, QWORD PTR [rbp-16]
	mov	rdi, rax
	call	puts
	mov	rax, QWORD PTR [rbp-16]
	mov	rdi, rax
	call	FNV32
	mov	QWORD PTR [rbp-8], rax
	mov	rax, QWORD PTR [rbp-8]
	mov	rsi, rax
	mov	edi, OFFSET FLAT:.LC1
	mov	eax, 0
	call	printf
	mov	eax, 0
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE3:
	.size	main, .-main
	.ident	"GCC: (Ubuntu 5.4.0-6ubuntu1~16.04.12) 5.4.0 20160609"
	.section	.note.GNU-stack,"",@progbits
