

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
	

; void put_char(int x, int y);
; stack:
;		y -> bp + 6
;		x -> bp + 4
;		ret_addr -> bp + 2
put_char:
	push bp
	mov bp, sp
	
	push ax
	push bx
	
	; screen[y * 80 + x]
	; screen[(y << 6) + (y << 4) + x]
	mov bx, [bp + 6]
	mov ax, bx
	shl ax, 6
	shl bx, 4
	add bx, ax
	add bx, [bp + 4]
	shl bx, 1
	
	mov word [PRIVATE_secreen_buff + bx], (0x0200 | 'z')
	
	pop bx
	pop ax
	pop bp
	ret

; void draw_rect(x, y, w, h)
; stack:
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
	
	mov bx, ax
	add bx, [bp + 6]
	push bx
	
	mov bx, cx
	add bx, [bp + 4]
	push bx
	call put_char
	add sp, 4
	
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

















