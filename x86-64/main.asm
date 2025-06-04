; main.asm
section .data
    global rows, cols
    rows    dq  20
    cols    dq  20
    clear   db 27, "[2J", 27, "[H"    ; ANSI clear screen
    clear_len equ $ - clear
    hide_cursor db 27, "[?25l"        ; Hide cursor
    hide_len equ $ - hide_cursor
    show_cursor db 27, "[?25h"        ; Show cursor
    show_len equ $ - show_cursor
    save_screen db 27, "[?1049h"      ; Save screen
    save_len equ $ - save_screen
    restore_screen db 27, "[?1049l"   ; Restore screen
    restore_len equ $ - restore_screen

section .bss
    global current_grid, next_grid
    current_grid    resb 400    ; 20 * 20 = 400 bytes
    next_grid       resb 400    ; 20 * 20 = 400 bytes

section .text
    global _start
    extern initialize_grid
    extern display_grid
    extern update_generation

_start:
    ; Save current screen and hide cursor
    mov rax, 1
    mov rdi, 1
    mov rsi, save_screen
    mov rdx, save_len
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, hide_cursor
    mov rdx, hide_len
    syscall

    ; Initialize grid with pattern
    call initialize_grid

main_loop:
    ; Clear screen and move to home position
    mov rax, 1
    mov rdi, 1
    mov rsi, clear
    mov rdx, clear_len
    syscall

    ; Display current generation
    call display_grid

    ; Update to next generation
    call update_generation

    ; Sleep briefly (100ms)
    mov rax, 35         ; sys_nanosleep
    mov rdi, timespec
    xor rsi, rsi
    syscall

    ; Continue loop
    jmp main_loop

    ; We never get here normally, but good practice
    jmp cleanup_exit

; Handle Ctrl+C
cleanup_exit:
    ; Show cursor
    mov rax, 1
    mov rdi, 1
    mov rsi, show_cursor
    mov rdx, show_len
    syscall

    ; Restore original screen
    mov rax, 1
    mov rdi, 1
    mov rsi, restore_screen
    mov rdx, restore_len
    syscall

    ; Exit
    mov rax, 60         ; sys_exit
    xor rdi, rdi        ; status = 0
    syscall

section .data
    timespec:
        dq 0              ; tv_sec (seconds)
        dq 100000000      ; tv_nsec (nanoseconds) - 0.1 seconds

section .note.GNU-stack noalloc noexec nowrite progbits
