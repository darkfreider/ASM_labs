         
.model tiny

print_str macro out_str
    mov ah, 9
    mov dx, offset out_str
    int 21h
endm

read_str macro in_str
    mov ah, 0ah
    mov dx, offset in_str
    int 21h
endm

.code
.org 0x100

start:
    print_str msg
    print_str msg
    
    jmp $

;print_str first_msg

;skip_spaces:
   ; cmp byte ptr str[bx], ' '
    ;jne main_loop
    ;inc bx
    ;jmp skip_spaces


_mxln0 db 201   
str_len db 0
str db 200 dup(0)

msg db "hello seilor!", 0ah, 0dh, '$'
new_line_msg db 0ah, 0dh, '$'
    
end start