section .bss
    output_buffer resb 65

section .data
    linefeed db 10
    base_digits db "0123456789ABCDEF"
    binary_flag db "-b", 0

section .text
    global _start

_start:
    mov r14, 16
    mov r15, [rsp+16]

    cmp qword [rsp], 3
    jne .check_arg_count
    mov rdi, [rsp+16]
    mov rsi, binary_flag
    call compare_strings
    cmp rax, 0
    jne .check_arg_count

    mov r14, 2
    mov r15, [rsp+24]

.check_arg_count:
    cmp qword [rsp], 2
    jl exit_error

    mov rsi, r15
    call parse_ascii_to_int

    mov rdi, output_buffer
    mov rsi, r14
    call int_to_ascii_base

    mov rdx, rax
    mov rax, 1
    mov rdi, 1
    mov rsi, output_buffer
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, linefeed
    mov rdx, 1
    syscall

exit_ok:
    mov rax, 60
    xor rdi, rdi
    syscall

exit_error:
    mov rax, 60
    mov rdi, 1
    syscall

compare_strings:
    push rsi
    push rdi
.loop:
    mov al, [rdi]
    mov ah, [rsi]
    cmp al, ah
    jne .not_equal
    cmp al, 0
    je .equal
    inc rsi
    inc rdi
    jmp .loop
.equal:
    pop rdi
    pop rsi
    xor rax, rax
    ret
.not_equal:
    pop rdi
    pop rsi
    mov rax, 1
    ret

parse_ascii_to_int:
    xor rax, rax
    xor rbx, rbx
.loop:
    mov bl, [rsi]
    cmp bl, 0
    je .done
    sub bl, '0'
    imul rax, 10
    add rax, rbx
    inc rsi
    jmp .loop
.done:
    ret

int_to_ascii_base:
    mov r8, rdi
    mov r9, rsi
    add rdi, 64
    mov byte [rdi], 0
    dec rdi
.loop:
    xor rdx, rdx
    div r9
    lea r10, [base_digits]
    mov r10b, [r10+rdx]
    mov [rdi], r10b
    dec rdi
    test rax, rax
    jnz .loop

    inc rdi
    mov rdx, r8
    add rdx, 65
    sub rdx, rdi
    mov rax, rdx

    mov rcx, rax
    mov rsi, rdi
    mov rdi, r8
    rep movsb
    ret