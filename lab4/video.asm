
SCREEN_HEIGHT equ 25
SCREEN_WIDTH equ 80

PRIVATE_secreen_buff: times (80 * 25 * 2) db 0   ; offscreen buffer

flip_offscreen_buffer:
	pusha
	
	mov ax, 0xb800
	mov es, ax
	
	mov bx, 0
	mov cx, (80 * 25)
.copy_loop:
	mov ax, word [PRIVATE_secreen_buff + bx]
	mov word [es:bx], ax
	add bx, 2
	loop .copy_loop
	
	popa
	ret

; void init_text_video(void)
init_text_video:
	push ax
	
	mov ax, 0xb800
	mov es, ax
	
	mov ax, 0x03
	int 0x10
	
	pop ax
	ret

; void restore_text_video(void)
restore_text_video:
	push ax
    
    mov ax, 0x03
    int 0x10
    
    pop ax
    ret
	

; void clear_screen(void)
clear_screen:
	pusha

	mov cx, 80 * 25
	mov bx, 0
.clear_loop:
	mov word [PRIVATE_secreen_buff + bx], (0x0200 | ' ')
	add bx, 2
	loop .clear_loop
	
	popa
	ret
	

; void put_char(int x, int y, int char);
; stack:
;       char -> bp + 8
;		y -> bp + 6
;		x -> bp + 4
;		ret_addr -> bp + 2
put_char:
	push bp
	mov bp, sp
	push ax
	push bx
	
	cmp word [bp + 4], 0
	jl .done
	cmp word [bp + 4], SCREEN_WIDTH
	jge .done
	cmp word [bp + 6], 0
	jl .done
	cmp word [bp + 6], SCREEN_HEIGHT
	jge .done
	
	; screen[y * 80 + x]
	; screen[(y << 6) + (y << 4) + x]
	mov bx, [bp + 6]
	mov ax, bx
	shl ax, 6
	shl bx, 4
	add bx, ax
	add bx, [bp + 4]
	shl bx, 1
	
	mov ax, word [bp + 8]
	mov word [PRIVATE_secreen_buff + bx], ax

.done:	
	pop bx
	pop ax
	pop bp
	ret

; void draw_rect(x, y, w, h, char)
; stack:
;       char -> bp + 12
;       h -> bp + 10
;       w -> bp + 8
;		y -> bp + 6
;		x -> bp + 4
;		ret_addr -> bp + 2
draw_rect:
	push bp
	mov bp, sp
	push ax
	push cx
	push bx
	
	mov ax, 0
.loop_y:
	cmp ax, [bp + 10]
	je .done
	
	mov cx, 0
.loop_x:
	cmp cx, [bp + 8]
	je .loop_y_end
	
	push word [bp + 12]
	
	mov bx, ax
	add bx, [bp + 6]
	push bx
	
	mov bx, cx
	add bx, [bp + 4]
	push bx
	call put_char
	add sp, 6
	
	inc cx
	jmp .loop_x
	
.loop_y_end:
	inc ax
	jmp .loop_y
	
.done:
	pop bx
	pop cx
	pop ax
	pop bp
	ret
	

score_string: db "Score: 00000"

; void print_score(int score);
; stack:
;       score -> bp + 4
;		ret_addr -> bp + 2
print_score:
	push bp
	mov bp, sp
	push es
	pusha
	
	push 0xb800
	pop es
	mov ax, word [bp + 4]	
	
	mov cx, 5
.form_string:
	xor dx, dx
	mov bx, 10 ; dx:ax
	div bx
	
	add dx, '0'
	mov bx, cx
	mov byte [score_string + bx + 6], dl

	loop .form_string
	
	xor bx, bx
	mov cx, 12
.print_loop:
	xor ax, ax
	mov al, byte [score_string + bx]
	
	or ax, 0x0200
	push ax
	push 0
	push bx
	call put_char
	add sp, 6
	
	inc bx
	loop .print_loop
	
	popa
	pop es
	pop bp
	ret














