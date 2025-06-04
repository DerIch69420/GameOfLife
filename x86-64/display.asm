; display.asm
section .data
    live_char db '*'    ; Character for live cell
    dead_char db '.'    ; Character for dead cell
    newline db 10       ; Newline character

section .text
    global display_grid
    extern current_grid

display_grid:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13

    xor r12, r12        ; row counter

.row_loop:
    xor r13, r13        ; column counter

.col_loop:
    ; Calculate cell offset
    mov rax, r12
    imul rax, 20
    add rax, r13
    
    ; Get cell state
    movzx rdx, byte [current_grid + rax]
    
    ; Choose character to print
    test rdx, rdx
    jz .print_dead
    
    ; Print live cell
    mov rax, 1
    mov rdi, 1
    lea rsi, [live_char]
    mov rdx, 1
    syscall
    jmp .char_done

.print_dead:
    mov rax, 1
    mov rdi, 1
    lea rsi, [dead_char]
    mov rdx, 1
    syscall

.char_done:
    inc r13
    cmp r13, 20
    jl .col_loop

    ; Print newline
    mov rax, 1
    mov rdi, 1
    lea rsi, [newline]
    mov rdx, 1
    syscall

    inc r12
    cmp r12, 20
    jl .row_loop

    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

section .note.GNU-stack noalloc noexec nowrite progbits
