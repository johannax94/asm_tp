global _start

section .bss
buffer resb 32

section .text
_start:
    ; Vérifier qu'il y a au moins 2 arguments
    mov rax, [rsp]      ; argc
    cmp rax, 3
    jb no_args

    ; Récupérer argv[1] et argv[2]
    mov rdi, [rsp + 16] ; argv[1]
    call atoi
    mov r8, rax          ; premier nombre

    mov rdi, [rsp + 24] ; argv[2]
    call atoi
    add r8, rax          ; somme

    ; Convertir en string
    mov rdi, r8
    mov rsi, buffer
    call itoa

    ; Afficher
    mov rax, 1           ; sys_write
    mov rdi, 1           ; stdout
    mov rdx, 32
    syscall

    ; Sortie
    mov rax, 60
    xor rdi, rdi
    syscall

no_args:
    mov rax, 60
    mov rdi, 1
    syscall

;----------------------------
; atoi (chaîne -> entier, gère négatif)
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

;----------------------------
; itoa (entier -> string)
itoa:
    mov rcx, rsi
    add rcx, 31
    mov byte [rcx], 10   ; ajout saut de ligne
    dec rcx
    mov rax, rdi
    test rax, rax
    jns .itoa_loop
    ; négatif
    neg rax
    mov bl, '-'
    mov [rsi], bl
    inc rsi
.itoa_loop:
    xor rdx, rdx
    mov rbx, 10
    div rbx
    add dl, '0'
    mov [rcx], dl
    dec rcx
    test rax, rax
    jnz .itoa_loop
    inc rcx
    mov rsi, rcx
    ret
