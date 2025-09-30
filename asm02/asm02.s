section .data
    msg db 'Entrez un chiffre', 0xA
    len equ $ - msg
    not_42_msg db '1', 0xA
    is_42_msg db '1337', 0xA
    buffer db 0, 0

section .text


    global _start   
_start:

    mov rax, 1
    mov rdi, 1
    mov rsi, msg
    mov rdx, len
    syscall

    mov rax, 0
    mov rdi, 0
    mov rsi, buffer
    mov rdx, 2
    syscall

    mov al, byte [buffer]
    cmp al, '4'
    jne not_42
    mov al, byte [buffer + 1]
    cmp al, '2'
    jne not_42
    jmp is_42

    not_42:
    mov rax, 1
    mov rdi, 1
    mov rsi, not_42_msg
    mov rdx, 2
    syscall
    jmp exit

    is_42:
    mov rax, 1
    mov rdi, 1
    mov rsi, is_42_msg
    mov rdx, 4
    syscall
    jmp exit


    exit:
    mov rax, 60
    xor rdi, rdi
    syscall