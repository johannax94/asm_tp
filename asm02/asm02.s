section .data
    good db "42", 0x0A
    goodlen equ $ - good

    msg db "1337", 0x0A
    msglen equ $ - msg

section .bss
    buf resb 8

section .text
    global _start

_start:
    mov rax, 0
    mov rdi, 0
    mov rsi, buf
    mov rdx, 8
    syscall
    mov rbx, rax

    mov rcx, goodlen
    cmp rbx, rcx
    jne _fail

    mov rsi, buf
    mov rdi, good
    mov rcx, goodlen
    repe cmpsb
    jne _fail

_success:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg
    mov rdx, msglen
    syscall

    xor rdi, rdi
    mov rax, 60
    syscall

_fail:
    mov rdi, 1
    mov rax, 60
    syscall