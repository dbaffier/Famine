%ifndef HEADER_ASM
 %define HEADER_ASM

%define FOLDER_1 "/tmp/test/"
%define FOLDER_2 "/tmp/test2/"

%define FILE_SIZE 256
%define LINUX_DIRENT 1024

%define SYS_WRITE 1
%define SYS_OPEN 2
%define SYS_CLOSE 3
%define SYS_EXIT 60
%define SYS_GETDENTS 217

%define SIGNATURE "Famine version 1.0 (c)oded by dbaffier"


%macro rel_init 0
call rel_hook
rel_hook: pop rbp
%endmacro

%define rel(offset) rbp + offset - rel_hook

struc LDIRENT_64
    .d_ino:          resq 1
    .d_off:          resq 1
    .d_reclen:       resw 1
    .d_type:         resb 1
    .d_name:         resb 1
endstruc

%endif


; DB allocates in chunks of 1 byte.
; DW allocates in chunks of 2 bytes.
; DD allocates in chunks of 4 bytes.
; DQ allocates in chunks of 8 bytes.

; RESB 1 allocates 1 byte.
; RESW 1 allocates 2 bytes.
; RESD 1 allocates 4 bytes.
; RESQ 1 allocates 8 bytes.