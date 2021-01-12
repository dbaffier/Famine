%ifndef HEADER_ASM
 %define HEADER_ASM

%define FOLDER_1 "/tmp/test/"
%define FOLDER_2 "/tmp/test2/"

%define FILE_SIZE 256
%define DIRENT 1024
%define FSTAT 144
%define MAPPED_FILE 8

; ELF_DEFINITION
%define ET_EXEC 2
%define ET_DYN 3

;SYSCALL
%define SYS_WRITE 1
%define SYS_OPEN 2
%define SYS_CLOSE 3
%define SYS_FSTAT 5
%define SYS_EXIT 60
%define SYS_GETDENTS 217

%define SIGNATURE "Famine version 1.0 (c)oded by dbaffier"

%define printf xprintf

%macro rel_init 0
    call rel_hook
    rel_hook: pop r12
%endmacro

%define rel(offset) r12 + offset - rel_hook

%macro dbg 2
    lea rdi, %1
    mov rsi, %2
    call printf
%endmacro

%macro dbgs 2
    lea rdi, %1
    lea rsi, %2
    call printf
%endmacro

; This memset need to be updated.
%macro memset 2
    .memset:
        lea rdi, %1
        add rdi, %2
        dec %2
        mov byte [rdi], byte 0
        cmp %2, 0
        jge .memset
%endmacro

struc LDIRENT_64
    .d_ino:          resq 1
    .d_off:          resq 1
    .d_reclen:       resw 1
    .d_type:         resb 1
    .d_name:         resb 1
endstruc


struc Elf64_Ehdr
    .e_ident:            resb 16
    .e_type:             resw 1
    .e_machine:          resw 1
    .e_version:          resd 1
    .e_entry:            resq 1
    .e_phofff:           resq 1
    .e_shoff:            resq 1
    .e_flags:            resd 1
    .e_ehsize:           resw 1
    .e_phentsize:        resw 1
    .e_phnum:            resw 1
    .e_shentsize:        resw 1
    .e_shnum:            resw 1
    .e_shstrndx:         resw 1
endstruc


; DB allocates in chunks of 1 byte.
; DW allocates in chunks of 2 bytes.
; DD allocates in chunks of 4 bytes.
; DQ allocates in chunks of 8 bytes.

; RESB 1 allocates 1 byte.
; RESW 1 allocates 2 bytes.
; RESD 1 allocates 4 bytes.
; RESQ 1 allocates 8 bytes.

%macro PUSH 0
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push rbp
    push rsp
    push r8
    push r9
    push r10
    push r11
    push r12
    push r13
    push r14
    push r15
%endmacro

%macro POP 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop r11
    pop r10
    pop r9
    pop r8
    pop rsp
    pop rbp
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
%endmacro
%endif