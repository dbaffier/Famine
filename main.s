	.file	"main.c"
	.intel_syntax noprefix
	.text
	.section	.rodata
.LC0:
	.string	"/tmp/test/Hello"
.LC1:
	.string	"%x\n"
.LC2:
	.string	"opop"
	.text
	.globl	main
	.type	main, @function
main:
.LFB6:
	.cfi_startproc
	endbr64
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	mov	rbp, rsp
	.cfi_def_cfa_register 6
	sub	rsp, 176
	mov	rax, QWORD PTR fs:40
	mov	QWORD PTR -8[rbp], rax
	xor	eax, eax
	mov	esi, 0
	lea	rdi, .LC0[rip]
	mov	eax, 0
	call	open@PLT
	mov	DWORD PTR -168[rbp], eax
	lea	rdx, -160[rbp]
	mov	eax, DWORD PTR -168[rbp]
	mov	rsi, rdx
	mov	edi, eax
	call	fstat@PLT
	mov	eax, DWORD PTR -136[rbp]
	mov	esi, eax
	lea	rdi, .LC1[rip]
	mov	eax, 0
	call	printf@PLT
	mov	eax, DWORD PTR -136[rbp]
	mov	edx, eax
	mov	esi, 577
	lea	rdi, .LC2[rip]
	mov	eax, 0
	call	open@PLT
	mov	DWORD PTR -164[rbp], eax
	mov	eax, 0
	mov	rcx, QWORD PTR -8[rbp]
	xor	rcx, QWORD PTR fs:40
	je	.L3
	call	__stack_chk_fail@PLT
.L3:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE6:
	.size	main, .-main
	.ident	"GCC: (Ubuntu 9.3.0-17ubuntu1~20.04) 9.3.0"
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
	.long	 1f - 0f
	.long	 4f - 1f
	.long	 5
0:
	.string	 "GNU"
1:
	.align 8
	.long	 0xc0000002
	.long	 3f - 2f
2:
	.long	 0x3
3:
	.align 8
4:
