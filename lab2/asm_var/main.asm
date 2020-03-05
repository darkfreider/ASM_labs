
.model tiny

IN_STATE equ 1
OUT_STATE equ 2 

TRUE equ 1
FALSE equ 0


.code
.org 0x100

start:

    ; TODO(max): null terminate w1 and w2
    mov ah, 0ah
    mov dx, offset _mxln0
    int 21h
    
    mov ah, 0ah
    mov dx, offset _mxln1
    int 21h
    
    mov ah, 0ah
    mov dx, offset _mxln2
    int 21h
           
           
    xor bx, bx
    
skip_spaces:
    cmp str[bx], ' '
    jne main_loop
    inc bx
    jmp skip_spaces
    
main_loop:
    cmp bx, [str_len]
    jae after_main_loop
    
    cmp str[bx], ' '
    jne _false
_true:
     
     
     
_false:
    cmp [state], OUT_STATE
    jne main_loop_end
    mov [state], IN_STATE
    mov [word_start], bx    
    
main_loop_end:
    inc bx
    jmp main_loop
    

after_main_loop:


end:  
    jmp end

word_start db 0
word_end db 0
found db FALSE
state db OUT_STATE    
    
_mxln0 db 200   
str_len db 0
str db 200 dup(0)
  
_mxln1 db 20  
w1_len db 0
w1 db 20 dup(0)
           
_mxln2 db 20           
w2_len db 0
w2 db 20 dup(0)     
    
end start