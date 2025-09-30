section .data
    msg db '1337', 0xA

section .text

    global _start   
_start:

    mov rax, 1
    mov rsi, msg
    mov rdx, 5
    mov rdi, 1
    syscall

    mov rax, 60
    xor rdi, rdi
    syscall
    