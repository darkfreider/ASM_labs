
.model tiny

IN_STATE equ 1
OUT_STATE equ 2 

TRUE equ 1
FALSE equ 0

print_str macro out_str
    mov ah, 9
    mov dx, offset out_str
    int 21h
endm

.code
.org 0x100

start:
    
    print_str first_msg
    
    mov ah, 0ah
    mov dx, offset _mxln0
    int 21h
    
    
    print_str second_msg
    
    mov ah, 0ah
    mov dx, offset _mxln1
    int 21h
            
    
    print_str third_msg
            
    mov ah, 0ah
    mov dx, offset _mxln2
    int 21h
    
    mov al, [str_len]
    add al, [w1_len]
    cmp al, [_mxln0]
    ja dont_have_enough_space       
           
    xor bx, bx
    
skip_spaces:
    cmp byte ptr str[bx], ' '
    jne main_loop
    inc bx
    jmp skip_spaces
    
main_loop:
    cmp bl, byte ptr [str_len]
    jae after_main_loop
    
    cmp byte ptr str[bx], ' '
    jne _false
_true:
    mov byte ptr [word_end], bl
    mov byte ptr [state], OUT_STATE
    
    mov al, [word_end]
    sub al, [word_start]
    cmp al, [w1_len]
    jne main_loop_end
    
    ; STRNCMP 1
    ; strncmp &str[word_start], w1, w1_len  
    mov dl, TRUE
    xor ax, ax
    mov al, byte ptr [word_start]
    mov si, ax ; index into str
    mov di, 0  ; index into w1
    mov cl, [w1_len]
strncmp_loop1:
    cmp cl, 0
    je after_strncmp1
    mov al, str[si]
    cmp al, w1[di]
    jne strncmp_not_equal1
    inc si
    inc di
    dec cl
    jmp strncmp_loop1
strncmp_not_equal1:
    mov dl, FALSE
       
after_strncmp1:
    cmp dl, TRUE
    jne main_loop_end
    mov [found], TRUE         
    jmp after_main_loop 
     
_false:
    cmp byte ptr [state], OUT_STATE
    jne main_loop_end
    mov [state], IN_STATE
    mov [word_start], bl    
    
main_loop_end:
    inc bx
    jmp main_loop
    

after_main_loop:
    mov [word_end], bl
    
    cmp bl, [str_len]
    jne finale_check
    
    ; STRNCMP 2
    ; strncmp &str[word_start], w1, w1_len  
    mov dl, TRUE
    xor ax, ax
    mov al, byte ptr [word_start]
    mov si, ax ; index into str
    mov di, 0  ; index into w1
    mov cl, [w1_len]
strncmp_loop2:
    cmp cl, 0
    je after_strncmp2
    mov al, str[si]
    cmp al, w1[di]
    jne strncmp_not_equal2
    inc si
    inc di
    dec cl
    jmp strncmp_loop2
strncmp_not_equal2:
    mov dl, FALSE
       
after_strncmp2:
    cmp dl, TRUE
    jne finale_check
    mov [found], TRUE         
    
finale_check:
    cmp [found], TRUE
    jne endd
    ; TODO(max): found word, shift string and insert word
    
    xor cx, cx
    mov cl, [str_len]
    sub cl, [word_start]
    inc cl
    
    xor ax, ax
    mov al, byte ptr [str_len]
    add ax, offset str
    mov si, ax ; end of str
    
    xor ax, ax
    mov al, byte ptr [str_len]
    add al, [w2_len]
    inc al
    add ax, offset str
    mov di, ax ; end of shifted shring
    
    std ; backward trawersal of string
    rep movsb
    
    xor cx, cx
    mov cl, [w2_len]
    inc cl
    cld
    mov di, si
    inc di
    mov si, offset w2
    rep movsb
    dec di
    mov [di], ' '
    
    ; print finale string   
    
    print_str new_line_msg
    
    mov ah, 40h
    mov bx, 1
    mov dx, offset str
    xor cx, cx
    add cl, [str_len]
    add cl, [w2_len]
    inc cl
    int 21h
    
    jmp endd

dont_have_enough_space:
    print_str err_msg
        
endd:  
    jmp endd

word_start db 0
word_end db 0
found db FALSE
state db OUT_STATE    
    
_mxln0 db 201   
str_len db 0
str db 200 dup(0)
  
_mxln1 db 21  
w1_len db 0
w1 db 20 dup(0)
           
_mxln2 db 21           
w2_len db 0
w2 db 20 dup(0)

first_msg db "enter input string: ", '$'
second_msg db 0ah, 0dh, "enter w1: ", '$'
third_msg db 0ah, 0dh, "enter w2: ", '$'
err_msg db 0ah, 0dh, "not enoutg space", '$'
new_line_msg db 0ah, 0dh, '$'
    
end start