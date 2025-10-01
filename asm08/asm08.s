global _start
section .bss

    buffer resb 32

section .text


_start:
    cmp qword [rsp], 2
    jne fail_exit

    mov rsi, [rsp+16]
    call str_to_int 
    mov rbx, rax

    mov rax, rbx
    dec rax
    imul rax, rbx
    shr rax, 1
    mov rdi, buffer
    call int_to_str

    mov rdx, rax
    mov rax, 1
    mov rdi, 1
    mov rsi, buffer
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, nl
    mov rdx, 1
    syscall

    mov rax, 60
    xor rdi, rdi
    syscall

fail_exit:
    mov rax, 60
    mov rdi, 1
    syscall

str_to_int:
    xor rax, rax
.next_char:
    mov dl, [rsi]
    cmp dl, 0
    je .done
    sub dl, '0'
    imul rax, rax, 10
    add rax, rdx
    inc rsi
    jmp .next_char
.done:
    ret

int_to_str:
    mov r8, rdi
    add rdi, 31
    mov byte [rdi], 0
    dec rdi
.loop:
    xor rdx, rdx
    div qword [ten]
    add dl, '0'
    mov [rdi], dl
    dec rdi
    test rax, rax
    jnz .loop
    inc rdi
    mov rsi, rdi
    mov rdi, r8
    mov rcx, 32
    rep movsb
    mov rax, rsi
    sub rax, r8
    ret

section .data
    nl db 10
    ten dq 10
