section .bss
    buffer resb 32

section .data
    nl db 10

section .text
    global _start

_start:
    mov rax, [rsp]          
    cmp rax, 4
    jne fail_exit           

    mov rsi, [rsp+16]       
    call str_to_int
    mov rbx, rax            

    mov rsi, [rsp+24]       
    call str_to_int
    cmp rax, rbx
    jle .skip2
    mov rbx, rax
.skip2:

    mov rsi, [rsp+32]       
    call str_to_int
    cmp rax, rbx
    jle .skip3
    mov rbx, rax
.skip3:

    mov rax, rbx
    mov rdi, buffer
    mov rdx, 10             
    call int_to_base

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
    xor rcx, rcx
    mov dl, [rsi]
    cmp dl, '-'
    jne .parse
    mov rcx, 1
    inc rsi
.parse:
    mov dl, [rsi]
    cmp dl, 0
    je .done
    sub dl, '0'
    imul rax, rax, 10
    add rax, rdx
    inc rsi
    jmp .parse
.done:
    test rcx, rcx
    jz .ret
    neg rax
.ret:
    ret

int_to_base:
    mov rcx, rdi
    mov r8, rdx
    xor r10b, r10b
    test rax, rax
    jns .cont
    neg rax
    mov r10b, 1
.cont:
    add rdi, 31
    mov byte [rdi], 0
    dec rdi
.convert_loop:
    xor rdx, rdx
    div r8
    mov r9b, dl
    cmp r9b, 10
    jb .digit
    add r9b, 'A' - 10
    jmp .store
.digit:
    add r9b, '0'
.store:
    mov [rdi], r9b
    dec rdi
    test rax, rax
    jnz .convert_loop
    inc rdi
    cmp r10b, 0
    je .no_sign
    dec rdi
    mov byte [rdi], '-'
.no_sign:
    mov rsi, rdi
    mov rdi, rcx
    mov rcx, 32
    rep movsb
    mov rax, rsi
    sub rax, rdi
    ret