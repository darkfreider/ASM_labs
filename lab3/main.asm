          
          
CR equ 0dh
          
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

start proc
    
    xor si, si
    mov cx, 5
_scan_raws_loop:    
    push cx
    
    print_str input_row_msg
    read_str _mxln_row
    mov word ptr [g_str_offs], 0
    
    mov cx, 6
_fill_row_loop:    
    call scan_int
    mov row_arr[si], ax
    add si, 2
    loop _fill_row_loop
    
    print_str new_line_msg
    
    pop cx
    loop _scan_raws_loop
    
    
    
    jmp $
start endp



is_digit proc
    push bp
    mov bp, sp
    push bx
    
    mov ax, 0
    mov bl, byte ptr [bp + 4]
    cmp bl, '0'
    jb _end
    cmp bl, '9'
    ja _end
    mov ax, 1
    
_end:
    pop bx    
    pop bp
    ret
is_digit endp
  
; PROC :: scan_int :: PROC     
; scans integer from g_row_str
; @params: string
; @ret_val: ax
; @side_effects: changes the value of ax, and g_row_str

scan_int proc
    push bp
    mov bp, sp 
    push bx
    push dx
    push si
    
    xor ax, ax
          
_skip_space_loop:
    mov si, [g_str_offs]
    mov al, byte ptr row_str[si]
    
    cmp byte ptr row_str[si], CR 
    je _pre_scan_int_loop
    cmp byte ptr row_str[si], ' '
    jne _pre_scan_int_loop
    
    inc word ptr [g_str_offs]                                   
    jmp _skip_space_loop

_pre_scan_int_loop:          
    xor bx, bx
    
_scan_int_loop:
    mov si, [g_str_offs]    
    cmp byte ptr row_str[si], CR
    je _end_scan_int
    push word ptr row_str[si]
    call is_digit
    cmp ax, 1
    pop ax
    jne _end_scan_int
    
    mov ax, 10
    mul bx
    jc _cant_handle_big_numbers
    mov dx, word ptr row_str[si]
    xor dh, dh
    add ax, dx
    sub ax, '0'
    mov bx, ax

    inc word ptr [g_str_offs]
    jmp _scan_int_loop
    
_cant_handle_big_numbers:
    print_str msg_cant_handle_big_numbers
          
_end_scan_int:
    mov ax, bx 
    
    pop si
    pop dx
    pop bx          
    pop bp
    ret    
scan_int endp

row_arr dw 0, 0, 0, 0, 0, 0
        dw 0, 0, 0, 0, 0, 0
        dw 0, 0, 0, 0, 0, 0
        dw 0, 0, 0, 0, 0, 0
        dw 0, 0, 0, 0, 0, 0

sum_row dw 0, 0, 0, 0, 0, 0

g_str_offs dw 0

_mxln_row db 201   
row_str_len db 0
row_str db 200 dup(0)

input_row_msg db "input row: ", '$'
msg_input db "input number: ", 0ah, 0dh, '$'
msg_cant_handle_big_numbers db "can't handle big numbers", 0ah, 0dh, '$'
new_line_msg db 0ah, 0dh, '$'
    
end start