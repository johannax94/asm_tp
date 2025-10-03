section .data
    ; message envoyé
    msg db "Hello, client!", 0
    msglen equ $ - msg

    ; messages affichage
    prefix db "message: ""        ; message: "
    prefix_len equ $ - prefix
    suffix db """", 10             ; " + newline
    suffix_len equ $ - suffix

    timeout_msg db "Timeout: no response from server", 10
    timeout_len equ $ - timeout_msg

    ; timeval pour SO_RCVTIMEO : 2s
    tv_sec  dq 0
    tv_usec dq 500000

section .bss
    buffer   resb 256
    cliaddr  resb 16       ; sockaddr_in client
    servaddr resb 16       ; sockaddr_in serveur

section .text
    global _start

_start:
    ; socket(AF_INET=2, SOCK_DGRAM=2, 0)
    mov rax, 41
    mov rdi, 2
    mov rsi, 2
    xor rdx, rdx
    syscall
    cmp rax, 0
    js .exit2
    mov r12, rax                    ; fd

    ; setsockopt(fd, SOL_SOCKET=1, SO_RCVTIMEO=20, &tv, 16)
    mov rax, 54
    mov rdi, r12
    mov rsi, 1                      ; SOL_SOCKET
    mov rdx, 20                     ; SO_RCVTIMEO
    
    mov r10, tv_sec
    mov r8, 16
    syscall
    cmp rax, 0
    js .exit2

    ; bind client : 0.0.0.0:0 (port auto)
    mov word  [cliaddr],   2        ; AF_INET
    mov word  [cliaddr+2], 0
    mov dword [cliaddr+4], 0        ; INADDR_ANY
    mov qword [cliaddr+8], 0
    mov rax, 49
    mov rdi, r12
    mov rsi, cliaddr
    mov rdx, 16
    syscall
    cmp rax, 0
    js .exit2

    ; sockaddr_in serveur : 127.0.0.1:1337
    mov word  [servaddr],   2
    mov ax, 1337                   ; htons(1337)
    xchg al, ah
    mov [servaddr+2], ax
    mov dword [servaddr+4], 0x0100007F   ; 127.0.0.1
    mov qword [servaddr+8], 0

    ; sendto(fd, msg, msglen, 0, &servaddr, 16)
    mov rax, 44
    mov rdi, r12
    mov rsi, msg
    mov rdx, msglen
    xor r10, r10
    mov r8,  servaddr
    mov r9,  16
    syscall
    cmp rax, 0
    js .exit2

    ; recvfrom(fd, buffer, 256, 0, NULL, NULL)
    mov rax, 45
    mov rdi, r12
    mov rsi, buffer
    mov rdx, 256
    xor r10, r10
    xor r8,  r8
    xor r9,  r9
    syscall
    cmp rax, 0
    jle .timeout
    mov r13, rax                     ; nb octets reçus

    ; print: message: "<réponse>"
    ; write(1, prefix, prefix_len)
    mov rax, 1
    mov rdi, 1
    mov rsi, prefix
    mov rdx, prefix_len
    syscall

    ; write(1, buffer, r13)
    mov rax, 1
    mov rdi, 1
    mov rsi, buffer
    mov rdx, r13
    syscall

    ; write(1, suffix, suffix_len)
    mov rax, 1
    mov rdi, 1
    mov rsi, suffix
    mov rdx, suffix_len
    syscall

    ; exit(0)
    mov rax, 60
    xor rdi, rdi
    syscall

.timeout:
    ; Timeout: no response from server
    mov rax, 1
    mov rdi, 1
    mov rsi, timeout_msg
    mov rdx, timeout_len
    syscall
    mov rax, 60
    mov rdi, 1
    syscall

.exit2:
    mov rax, 60
    mov rdi, 2
    syscall
