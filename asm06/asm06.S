; add_exit.asm
; Additionne deux nombres passés en argument et renvoie le résultat comme code de sortie
; Usage: ./add_exit 5 3  => exit code 8

global _start

section .text
_start:
    ; Vérifier argc >= 3 (programme + 2 paramètres)
    mov rax, [rsp]        ; argc
    cmp rax, 3
    jb no_args            ; moins de 2 params -> exit 1

    ; Récupérer argv[1] et argv[2]
    mov rdi, [rsp + 8]    ; argv[0] (on ignore)
    mov rsi, [rsp + 16]   ; argv[1]
    mov rdx, [rsp + 24]   ; argv[2]

    ; Convertir argv[1] en entier
    mov rdi, rsi
    call atoi
    mov r8, rax           ; stocker premier nombre

    ; Convertir argv[2] en entier
    mov rdi, rdx
    call atoi
    add r8, rax           ; r8 = somme

    ; Limiter le code de sortie à 0-255
    mov rax, 60           ; sys_exit
    mov rdi, r8
    and rdi, 0xff
    syscall

no_args:
    mov rax, 60
    mov rdi, 1
    syscall

;-------------------------------------------------------
; atoi simple (gère aussi les nombres négatifs)
; entrée: rdi = adresse string
; sortie: rax = entier
atoi:
    xor rax, rax
    xor rcx, rcx
    mov bl, byte [rdi]
    cmp bl, '-'
    jne .atoi_loop_start
    ; signe négatif
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
