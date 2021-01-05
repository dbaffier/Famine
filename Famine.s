%define FOLDER_1 "/tmp/test"
%define FOLDER_2 "/tmp/test2"

%define FILE_SIZE 8
%define BUFFER_SIZE 1024

%define SYS_OPEN 2
%define SYS_EXIT 60
%define SYS_GETDENTS64 217

%define SIGNATURE "Famine version 1.0 (c)oded by dbaffier"
[BITS 64]

section .text
    global _infect

_infect:
    ; maybe push ALL USEFULL REGISTERS to restore state before leaving infection
    mov rcx, FILE_SIZE + BUFFER_SIZE

loop_bss:
    mov rax, 0x00
    push rax                            ; 4 bytes on stack
    dec rcx
    cmp rcx, 0
    jne loop_bss
    ; RSP contains fake BSS
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





;; nasm -f elf -F dwarf -g cranky_data_virus.asm
;; ld -m elf_i386 -e v_start -o cranky_data_virus cranky_data_virus.o