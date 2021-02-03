[BITS 64]
default rel

%include "header.asm"

section .data
    msg db "Hello world", 10, 0
    len  equ  $ - msg
    key db "0FI3Y1234", 0
    keylen equ $ - key

section .text
    global _famine

_famine:
    lea rdi, [rel msg]
    lea rsi, [rel key]
    mov rdx, len
    mov rcx, keylen
    call XORCipher
    lea rdi, [rel msg]
    lea rsi, [rel key]
    mov rdx, len
    mov rcx, keylen
    call XORCipher
    mov rax, 0
    ret

; rdi = data
; rsi = key
; rdx = data len
; rcx = key len
XORCipher:
    sub rsp, 16
    mov [rsp], ecx
    mov [rsp + 4], edx
    xor r8, r8
    .xor_loop:
        xor rdx, rdx
        mov eax, r8d
        div dword [rsp] ; edx = %

        mov rax, rsi
        add rax, rdx
        movzx edx, byte [rax]

        mov rcx, rdi
        add rcx, r8
        movzx ecx, byte [rcx]
        xor edx, ecx
        lea rcx, [rdi + r8]
        mov byte [rcx], dl
        add r8, 1
        cmp r8d, [rsp + 4]
        jb .xor_loop
        add rsp, 16
        ret