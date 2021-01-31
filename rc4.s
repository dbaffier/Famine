; section .text
global _rc4

_rc4:
    push rbp
    mov rbp, rsp
    sub rsp, 304
    lea rax, [rbp - 272]
	mov	qword [rbp - 280], rdi
	mov	qword [rbp - 288], rsi
	mov	dword [rbp - 292], edx
    mov	rdi, qword [rbp - 280]
	mov	rsi, rax
	call	KSA
	lea	rdi, [rbp - 272]
	mov	rsi, qword [rbp - 288]
	mov	edx, dword [rbp - 292]
    call	PRGA
    add rsp, 304
    pop rbp       
    ret

KSA:
    push rbp
    mov rbp, rsp
    sub rsp, 48 ; Maybe
    mov qword [rbp - 8], rdi   ; KEY
    mov qword [rbp - 16], rsi  ; STRING
    mov rdi, qword [rbp - 8]   ; KEY in rdi
    sub ecx, ecx
    sub al, al
    not ecx
    cld
    repne scasb
    not ecx
    dec ecx

    mov dword [rbp - 24], ecx ; LEN
    mov dword [rbp - 28], 0   ; init i = 0

KSA_LOOP:
    cmp dword [rbp - 28], 255
    jge KSA_LOOP_LEAVE
    mov eax, dword [rbp - 28]
    mov cl, al
    mov rdx, qword [rbp - 16]
    movsxd rsi, dword [rbp - 28]
    mov byte [rdx + rsi], cl
    mov eax, dword [rbp - 28]
    add eax, 1
    mov dword [rbp - 28], eax
    jmp KSA_LOOP

KSA_LOOP_LEAVE:
    mov dword [rbp - 20], 0   ; j =0
    mov dword [rbp - 32], 0   ; i = 0


KSA_LOOP_2:
    cmp dword [rbp - 32], 255
    jge KSA_END
    mov eax, dword [rbp - 20] 
    mov rcx, qword [rbp - 16]     
    movsxd rdx, dword [rbp - 32], 
    movzx esi, byte [rcx + rdx]    
    add eax, esi
    mov rcx, qword [rbp - 8]
    mov esi, dword [rbp - 32]
    mov dword [rbp - 36], eax
    mov eax, esi
    cdq
    idiv dword [rbp - 24]
    movsxd rdi, edx
    movsx edx, byte [rcx + rdi]
    mov esi, dword [rbp - 36]
    add esi, edx
    mov eax, esi
    cdq
    mov esi, 255
    idiv esi
    mov dword [rbp - 20], edx
    mov rcx, qword [rbp - 16]
    movsxd rdi, dword [rbp - 32]
    add rcx, rdi
    mov rdi, qword [rbp - 16]
    movsxd r8, dword [rbp - 20]
    add rdi, r8
    mov qword [rbp - 48], rdi
    mov rdi, rcx
    mov rsi, qword [rbp - 48]
    call swap

    mov eax, dword [rbp - 32]
    add eax, 1
    mov dword [rbp - 32], eax
    jmp KSA_LOOP_2

KSA_END:
    add rsp, 48
    pop rbp
    ret

PRGA:
    push rbp
    mov rbp, rsp
    sub rsp, 48

    mov	qword [rbp - 8], rdi
	mov	qword [rbp - 16], rsi
	mov	dword [rbp - 20], edx
	mov	dword [rbp - 24], 0
	mov	dword [rbp - 28], 0
	mov	dword [rbp - 32], 0
	mov	qword [rbp - 40], 0

PRGA_LOOP:
    mov	rax, qword [rbp - 40]
	mov	ecx, dword [rbp - 20]
	mov	edx, ecx
	cmp	rax, rdx
	jae	PRGA_LOOP_END

    ; in loop
    mov	eax, dword [rbp - 24]
	add	eax, 1
	cdq
	mov	ecx, 255
	idiv	ecx
	mov	dword [rbp - 24], edx
	mov	edx, dword [rbp - 28]
	mov	rsi, qword [rbp - 8]
	movsxd	rdi, dword [rbp - 24]
	movzx	r8d, byte [rsi + rdi]
	add	edx, r8d
	mov	eax, edx
	cdq
	idiv	ecx
	mov	dword [rbp - 28], edx
	mov	rsi, qword [rbp - 8]
	movsxd	rdi, dword [rbp - 24]
	add	rsi, rdi
	mov	rdi, qword [rbp - 8]
	movsxd	r9, dword [rbp - 28]
	add	rdi, r9
	mov	qword [rbp - 48], rdi
	mov	rdi, rsi
	mov	rsi, qword [rbp - 48]
	call	swap
	mov	rsi, qword [rbp - 8]
	mov	rdi, qword [rbp - 8]
	movsxd	r9, dword [rbp - 24]
	movzx	ecx, byte [rdi + r9]
	mov	rdi, qword [rbp - 8]
	movsxd	r9, dword [rbp - 28]
	movzx	edx, byte [rdi + r9]
	add	ecx, edx
	mov	eax, ecx
	cdq
	mov	ecx, 255
	idiv	ecx
	movsxd	rdi, edx
	movzx	ecx, byte [rsi + rdi]
	mov	dword [rbp - 32], ecx
	mov	ecx, dword [rbp - 32]
	mov	rsi, qword [rbp - 16]
	mov	rdi, qword [rbp - 40]
	movzx	edx, byte [rsi + rdi]
	xor	ecx, edx
	mov	r10b, cl
	mov	rsi, qword [rbp - 16]
	mov	rdi, qword [rbp - 40]
	mov	byte [rsi + rdi], r10b

    mov	rax, qword [rbp - 40]
	add	rax, 1
	mov	qword [rbp - 40], rax
	jmp	PRGA_LOOP

PRGA_LOOP_END:
    add	rsp, 48
	pop	rbp
	ret

swap:
    push rbp
    mov rbp, rsp
	mov	qword [rbp - 8], rdi
	mov	qword [rbp - 16], rsi
	mov	rsi, qword [rbp - 8]
	movzx	eax, byte [rsi]
	mov	dword [rbp - 20], eax
	mov	rsi, qword [rbp - 8]
	mov	cl, byte [rsi]
	mov	rsi, qword [rbp - 16]
	mov	byte [rsi], cl
	mov	eax, dword [rbp - 20]
	mov	cl, al
	mov	rsi, qword [rbp - 8]
	mov	byte [rsi], cl
	pop	rbp
	ret