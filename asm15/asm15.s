section .bss
    header resb 5        ; buffer pour stocker les 5 premiers octets

section .text
    global _start

_start:
    ; vérifier nombre d’arguments
    mov rbx, [rsp]        ; argc
    cmp rbx, 2
    jl exit_error         ; pas d’argument alors erreur

    ; argv[1]
    mov rdi, [rsp+16]     ; pointeur vers nom du fichier

    ; open(argv[1], O_RDONLY)
    mov rax, 2
    mov rsi, 0            ; O_RDONLY
    syscall
    cmp rax, 0
    js exit_error
    mov rdi, rax          ; fd

    ; read(fd, header, 5)
    mov rax, 0
    mov rsi, header
    mov rdx, 5
    syscall
    cmp rax, 5
    jl exit_error            ; impossible de lire 5 octets alors exit error

    ; vérifier ELF magic
    mov al, [header]
    cmp al, 0x7F
    jne exit_error
    mov al, [header+1]
    cmp al, 'E'
    jne exit_error
    mov al, [header+2]
    cmp al, 'L'
    jne exit_error
    mov al, [header+3]
    cmp al, 'F'
    jne exit_error

    ; vérifier classe (64 bits = 2)
    mov al, [header+4]
    cmp al, 2
    jne exit_error

is_elf64:
    mov rax, 60
    xor rdi, rdi     ; exit(0)
    syscall

exit_error:
    mov rax, 60
    mov rdi, 1       ; exit(1)
    syscall
