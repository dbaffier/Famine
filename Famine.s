%define FOLDER_1 "/tmp/test"
%define FOLDER_2 "/tmp/test2"

%define FILE_SIZE 4
%define LINUX_DIRENT 128

%define SYS_WRITE 1
%define SYS_OPEN 2
%define SYS_CLOSE 3
%define SYS_EXIT 60
%define SYS_GETDENTS 217

%define SIGNATURE "Famine version 1.0 (c)oded by dbaffier"
[BITS 64]

section .text
    global _infect

_infect:
    ; maybe push ALL USEFULL REGISTERS to restore state before leaving infection
    mov rcx, FILE_SIZE + LINUX_DIRENT
    mov r10, 1
    ;[rsp] filename
    ;[rsp + 32] linux_dirent

loop_bss:
    xor rax, rax
    push rax                                ; 8 bytes on stack
    dec rcx
    cmp rcx, 0
    jg loop_bss
    ; RSP contains fake BSS
    ; mov rbp, rsp ; Maybe
    ; mov [rsp], word 2
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
    mov rax, SYS_CLOSE
    syscall
    xor rbx, rbx                            ; buffer offset

find_file:
    cmp rbx, 1024
    jge quit
    lea rsi, [rsp + 32]                     ; struct
    add rsi, rbx                            ; current offset
    add rsi, 18                             ; offset d_type
    cmp sil, 0x8                                  ; DT_REG
    jne next

    mov rax, SYS_WRITE
    mov rdi, 1                              ; stdout
    mov rdx, 5                      
    syscall

next:
    movzx r8, word [rsp + 32 + rbx + 16]               ; offset dirent + offset + d_reclen
    ; CHECK WHEN NO MORE FILES
    add rbx, r8
    jmp find_file

; next_folder:
;     cmp r10, 0
;     jg folder_2


quit:
    mov rax, SYS_EXIT
    mov rdi, 0
    syscall
