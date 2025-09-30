section .bss
    buffer resb 32

section .text
    global _start                               
_start:
    
    mov rbx, [rsi + 8]
    mov rcx, [rsi + 16]

    mov rdi, rbx
    call atoi
    mov r8, rax

    mov rdi, rcx
    call atoi
    mov r9, rax

    add r8, r9

    mov rdi, r8
    mov rsi, buffer
    call itoa

    mov rax, 1
    mov rdi, 1
    mov rdx, 32
    syscall

    mov rax, 60
    xor rdi, rdi
    syscall

atoi:
    xor rax, rax
    xor rcx, rcx
.atoi_loop:
    mov bl, byte [rdi]
    cmp bl, 0
    je .atoi_done
    sub bl, '0'
    imul rax, rax, 10
    add rax, rbx
    inc rdi
    jmp .atoi_loop
.atoi_done:
    ret

itoa:
    mov rcx, rsi
    add rcx, 31
    mov byte [rcx], 0
    mov rax, rdi
.itoa_loop:
    xor rdx, rdx
    mov rbx, 10
    div rbx
    add dl, '0'
    dec rcx
    mov [rcx], dl
    test rax, rax
    jnz .itoa_loop
    mov rsi, rcx
    ret
