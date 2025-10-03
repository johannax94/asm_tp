; server.asm - Serveur UDP simple x86-64 Linux (NASM)
; Assemble : nasm -felf64 server.asm -o server.o
; Link     : ld server.o -o server

section .data
    resp_msg    db "Hello, client!", 0
    resp_len    equ $ - resp_msg

    prefix      db 'received: "'
    prefix_len  equ $ - prefix
    suffix      db '"', 10
    suffix_len  equ $ - suffix

    filename    db "messages", 0       ; fichier où écrire

section .bss
    buffer      resb 512
    src_addr    resb 16        ; sockaddr_in pour recvfrom
    addrlen     resq 1
    fd_file     resq 1

section .text
    global _start

_start:
    ; socket(AF_INET=2, SOCK_DGRAM=2, 0)
    mov     rax, 41
    mov     rdi, 2
    mov     rsi, 2
    xor     rdx, rdx
    syscall
    cmp     rax, 0
    js      .fatal
    mov     r12, rax           ; sockfd

    ; sockaddr_in server: AF_INET, port 1337, INADDR_ANY
    mov     word [src_addr], 2         ; AF_INET
    mov     ax, 1337
    xchg    al, ah                     ; htons(1337)
    mov     [src_addr+2], ax
    mov     dword [src_addr+4], 0      ; INADDR_ANY
    mov     qword [src_addr+8], 0      ; sin_zero

    ; bind(sockfd, &addr, 16)
    mov     rax, 49
    mov     rdi, r12
    lea     rsi, [src_addr]
    mov     rdx, 16
    syscall
    cmp     rax, 0
    js      .fatal

    ; open("messages", O_CREAT|O_WRONLY|O_APPEND, 0644)
    mov     rax, 2
    mov     rdi, filename
    mov     rsi, 0x441         ; O_CREAT(0x40)|O_WRONLY(0x1)|O_APPEND(0x400)
    mov     rdx, 0o644         ; mode = -rw-r--r--
    syscall
    cmp     rax, 0
    js      .fatal
    mov     [fd_file], rax

.loop:
    mov     qword [addrlen], 16

    ; recvfrom(sockfd, buffer, 512, 0, &src_addr, &addrlen)
    mov     rax, 45
    mov     rdi, r12
    lea     rsi, [buffer]
    mov     rdx, 512
    xor     r10, r10
    lea     r8, [src_addr]
    lea     r9, [addrlen]
    syscall
    cmp     rax, 0
    jle     .loop
    mov     r13, rax           ; nb d'octets reçus

    ; fd du fichier
    mov     r15, [fd_file]

    ; write(fd, prefix, prefix_len)
    mov     rax, 1
    mov     rdi, r15
    mov     rsi, prefix
    mov     rdx, prefix_len
    syscall

    ; write(fd, buffer, r13)
    mov     rax, 1
    mov     rdi, r15
    lea     rsi, [buffer]
    mov     rdx, r13
    syscall

    ; write(fd, suffix, suffix_len)
    mov     rax, 1
    mov     rdi, r15
    mov     rsi, suffix
    mov     rdx, suffix_len
    syscall

    ; sendto(sockfd, resp_msg, resp_len, 0, &src_addr, addrlen)
    mov     rax, 44
    mov     rdi, r12
    mov     rsi, resp_msg
    mov     rdx, resp_len
    xor     r10, r10
    lea     r8, [src_addr]
    mov     r9, qword [addrlen]
    syscall

    jmp     .loop

.fatal:
    mov     rax, 60
    mov     rdi, 1
    syscall
