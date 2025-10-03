section .data
    resp_msg    db "Hello, client!", 0
    resp_len    equ $ - resp_msg

    prefix      db 'received: ""    '
    prefix_len  equ $ - prefix
    suffix      db """", 10
    suffix_len  equ $ - suffix

    ; sockaddr_in pour le client source (rempli par recvfrom)
    ; et pour le bind du serveur
section .bss
    buffer      resb 512
    src_addr    resb 16        ; struct sockaddr_in pour recvfrom
    addrlen     resq 1         ; socklen_t (we'll store 16 here)

section .text
    global _start

_start:
    ; socket(AF_INET=2, SOCK_DGRAM=2, 0)
    mov     rax, 41            ; sys_socket
    mov     rdi, 2             ; AF_INET
    mov     rsi, 2             ; SOCK_DGRAM
    xor     rdx, rdx           ; protocol = 0
    syscall
    cmp     rax, 0
    js      .fatal
    mov     r12, rax           ; sockfd in r12

    ; (optional) setsockopt SO_REUSEADDR to 1  -- makes bind a bit more flexible
    mov     rax, 54            ; sys_setsockopt
    mov     rdi, r12           ; fd
    mov     rsi, 1             ; SOL_SOCKET
    mov     rdx, 2             ; SO_REUSEADDR (value 2)
    ; pass pointer to integer 1
    mov     qword [rsp-8], 1   ; push a temporary 8 byte value on stack
    lea     r10, [rsp-8]
    mov     r8, 8              ; optlen = 8
    syscall
    add     rsp, 0             ; no-op (we used stack area at rsp-8; safe on entry)
    ; ignoring error if any

    ; build sockaddr_in server : AF_INET (2), port htons(1337), INADDR_ANY (0)
    ; layout: 2 bytes sin_family, 2 bytes sin_port(net), 4 bytes sin_addr, 8 bytes sin_zero
    mov     word [src_addr], 2         ; sin_family = AF_INET
    mov     ax, 1337
    xchg    al, ah                     ; htons(1337)
    mov     [src_addr+2], ax           ; sin_port
    mov     dword [src_addr+4], 0      ; INADDR_ANY = 0
    mov     qword [src_addr+8], 0      ; zero sin_zero mov dword [servaddr+4], 0x0100007F   ; 127.0.0.1

    ; bind(sockfd, &server_addr, 16)
    mov     rax, 49            ; sys_bind
    mov     rdi, r12
    lea     rsi, [src_addr]    ; address pointer
    mov     rdx, 16
    syscall
    cmp     rax, 0
    js      .fatal

    ; main loop: wait for datagram, print it, reply to sender
.loop:
    ; set addrlen = 16
    mov     qword [addrlen], 16

    ; recvfrom(sockfd, buffer, 512, 0, &src_addr, &addrlen)
    mov     rax, 45            ; sys_recvfrom
    mov     rdi, r12           ; sockfd
    lea     rsi, [buffer]      ; buf
    mov     rdx, 512           ; len
    xor     r10, r10           ; flags = 0
    lea     r8, [src_addr]     ; src_addr *
    lea     r9, [addrlen]      ; addrlen *
    syscall
    cmp     rax, 0
    jle      .loop             ; on error or 0 bytes, continue loop
    mov     r13, rax           ; bytes received

    ; write(1, prefix, prefix_len)
    mov     rax, 1             ; sys_write
    mov     rdi, 1
    mov     rsi, prefix
    mov     rdx, prefix_len
    syscall

    ; write(1, buffer, r13)
    mov     rax, 1
    mov     rdi, 1
    lea     rsi, [buffer]
    mov     rdx, r13
    syscall

    ; write(1, suffix, suffix_len)
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, suffix
    mov     rdx, suffix_len
    syscall

    ; sendto(sockfd, resp_msg, resp_len, 0, src_addr, addrlen)
    ; need to load addrlen value (socklen_t) into r9 (value, not pointer)
    mov     rax, 44            ; sys_sendto
    mov     rdi, r12
    mov     rsi, resp_msg
    mov     rdx, resp_len
    xor     r10, r10           ; flags = 0
    lea     r8, [src_addr]     ; dest addr pointer
    mov     r9, qword [addrlen] ; dest addrlen (value)
    syscall
    ; ignore send errors, continue
    jmp     .loop

.fatal:
    ; exit(2)
    mov     rax, 60
    mov     rdi, 2
    syscall
