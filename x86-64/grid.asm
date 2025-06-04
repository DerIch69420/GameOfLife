; grid.asm
section .text
    global initialize_grid
    global update_generation
    extern current_grid
    extern next_grid

initialize_grid:
    push rbp
    mov rbp, rsp

    ; Clear grid first
    mov rcx, 400        ; 20x20 grid
    mov rdi, current_grid
    xor al, al
    rep stosb

    ; Set up glider:
    ;   .O.     position (1,1)
    ;   ..O     position (2,2)
    ;   OOO     position (3,0),(3,1),(3,2)

    ; Position (1,1)
    mov rax, 20         ; offset = row * 20 + col
    add rax, 1          ; col = 1
    mov byte [current_grid + rax], 1

    ; Position (2,2)
    mov rax, 40         ; row 2 * 20
    add rax, 2          ; col = 2
    mov byte [current_grid + rax], 1

    ; Position (3,0)
    mov rax, 60         ; row 3 * 20
    mov byte [current_grid + rax], 1

    ; Position (3,1)
    mov rax, 60         ; row 3 * 20
    add rax, 1          ; col = 1
    mov byte [current_grid + rax], 1

    ; Position (3,2)
    mov rax, 60         ; row 3 * 20
    add rax, 2          ; col = 2
    mov byte [current_grid + rax], 1

    leave
    ret

update_generation:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15

    ; Clear next grid
    mov rcx, 400
    mov rdi, next_grid
    xor al, al
    rep stosb

    ; For each cell
    xor r12, r12        ; row = 0
.row_loop:
    xor r13, r13        ; col = 0
.col_loop:
    ; Count neighbors for current cell
    xor ebx, ebx        ; neighbor count

    ; Check all 8 neighbors with bounds checking
    mov r14, r12        ; current row
    sub r14, 1          ; row - 1
    .neighbor_row:
        mov r15, r13        ; current col
        sub r15, 1          ; col - 1
        .neighbor_col:
            ; Skip if out of bounds
            cmp r14, 0
            jl .skip_neighbor
            cmp r14, 19
            jg .skip_neighbor
            cmp r15, 0
            jl .skip_neighbor
            cmp r15, 19
            jg .skip_neighbor
            
            ; Skip if current cell
            cmp r14, r12
            jne .check_cell
            cmp r15, r13
            jne .check_cell
            jmp .skip_neighbor

            .check_cell:
            ; Calculate offset
            mov rax, r14
            imul rax, 20
            add rax, r15
            movzx edx, byte [current_grid + rax]
            add ebx, edx    ; Add to neighbor count

            .skip_neighbor:
            inc r15
            mov rax, r13
            add rax, 1
            cmp r15, rax
            jle .neighbor_col

        inc r14
        mov rax, r12
        add rax, 1
        cmp r14, rax
        jle .neighbor_row

    ; Calculate current cell offset
    mov rax, r12
    imul rax, 20
    add rax, r13
    
    ; Get current cell state
    movzx edx, byte [current_grid + rax]

    ; Apply Game of Life rules
    test dl, dl
    jz .dead_cell

    ; Live cell rules
    cmp ebx, 2          ; Dies if < 2 neighbors
    jl .make_dead
    cmp ebx, 3          ; Dies if > 3 neighbors
    jg .make_dead
    mov byte [next_grid + rax], 1  ; Stays alive
    jmp .next_cell

.dead_cell:
    cmp ebx, 3          ; Becomes alive if exactly 3 neighbors
    je .make_alive
    jmp .make_dead

.make_alive:
    mov byte [next_grid + rax], 1
    jmp .next_cell

.make_dead:
    mov byte [next_grid + rax], 0

.next_cell:
    inc r13
    cmp r13, 20
    jl .col_loop

    inc r12
    cmp r12, 20
    jl .row_loop

    ; Swap current and next grids by copying
    mov rcx, 400
    mov rsi, next_grid
    mov rdi, current_grid
    rep movsb

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

section .note.GNU-stack noalloc noexec nowrite progbits
