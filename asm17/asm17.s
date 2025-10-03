section .bss
    buffer resb 256

section .text
    global _start

; atoi : convertir string en entier
; Entrée : rsi = pointeur
; Sortie : rax = entier
atoi:
    xor rax, rax
.parse:
    mov bl, [rsi]
    cmp bl, 0
    je .done
    cmp bl, 0Ah
    je .done
    cmp bl, '0'
    jl .done
    cmp bl, '9'
    jg .done
    sub bl, '0'
    imul rax, rax, 10
    add rax, rbx
    inc rsi
    jmp .parse
.done:
    ret

_start:
    ; vérifier argc
    mov rbx, [rsp]
    cmp rbx, 2
    jne exit_error

    ; argv[1] = décalage
    mov rsi, [rsp+16]
    call atoi
    mov r12, rax        ; décalage Caesar

    ; lire depuis stdin
    mov rax, 0
    mov rdi, 0
    mov rsi, buffer
    mov rdx, 256
    syscall
    cmp rax, 0
    jle exit_error
    mov r13, rax        ; sauvegarde taille lue

    mov rcx, 0

.loop:
    cmp rcx, r13
    jge .done

    mov al, [buffer+rcx]

    ; minuscules
    cmp al, 'a'
    jb .check_upper
    cmp al, 'z'
    ja .check_upper
    sub al, 'a'
    add al, r12b
.fix_lower:
    cmp al, 26
    jb .ok_lower
    sub al, 26
    jmp .fix_lower
.ok_lower:
    add al, 'a'
    mov [buffer+rcx], al
    jmp .next

.check_upper:
    cmp al, 'A'
    jb .next
    cmp al, 'Z'
    ja .next
    sub al, 'A'
    add al, r12b
.fix_upper:
    cmp al, 26
    jb .ok_upper
    sub al, 26
    jmp .fix_upper
.ok_upper:
    add al, 'A'
    mov [buffer+rcx], al

.next:
    inc rcx
    jmp .loop

.done:
    ; écrire résultat
    mov rax, 1
    mov rdi, 1
    mov rsi, buffer
    mov rdx, r13
    syscall

    ; exit(0)
    mov rax, 60
    xor rdi, rdi
    syscall

exit_error:
    mov rax, 60
    mov rdi, 1
    syscall