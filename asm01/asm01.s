section .text
    global _start


section .data 
    tb nb 0xf

_start:

    mov rdi, nb
    mov rax, 4
    mov rbx, 1
    mov rcx, 1
    syscall

    mov rax, 60
    syscall