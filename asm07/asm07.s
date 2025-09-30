global _start

section .bss
buffer resb 32       ; tampon pour la lecture

section .text
_start:
    ; Lire depuis stdin
    mov rax, 0        ; sys_read
    mov rdi, 0        ; fd = stdin
    mov rsi, buffer
    mov rdx, 32       ; lire max 32 octets
    syscall

    ; convertir en entier
    mov rdi, buffer
    call atoi
    mov rbx, rax      ; nombre à tester

    ; vérifier n <= 1
    cmp rbx, 2
    jb not_prime

    mov rcx, 2         ; diviseur
check_loop:
    mov rax, rbx
    xor rdx, rdx
    div rcx             ; rax / rcx
    cmp rdx, 0
    je not_prime        ; divisible -> pas premier
    inc rcx
    cmp rcx, rbx
    jl check_loop

prime:
    mov rax, 60
    xor rdi, rdi       ; exit 0 = premier
    syscall

not_prime:
    mov rax, 60
    mov rdi, 1         ; exit 1 = pas premier
    syscall

;----------------------------
; atoi : convertir chaîne ASCII -> entier
; gère les nombres négatifs
atoi:
    xor rax, rax
    xor rcx, rcx
    mov bl, byte [rdi]
    cmp bl, '-'
    jne .atoi_loop_start
    inc rdi
    mov rcx, 1
.atoi_loop_start:
    xor rax, rax
.atoi_loop:
    mov bl, byte [rdi]
    cmp bl, 10          ; saut de ligne
    je .atoi_done
    cmp bl, 0
    je .atoi_done
    sub bl, '0'
    imul rax, rax, 10
    add rax, rbx
    inc rdi
    jmp .atoi_loop
.atoi_done:
    cmp rcx, 1
    jne .atoi_return
    neg rax
.atoi_return:
    ret
