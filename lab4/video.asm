

; void init_video(void);
init_video:
    push ax

	mov ax, 0xa000
	mov es, ax
	
    mov ax, 0x13
    int 0x10

    pop ax
    ret

; void restore_video(void);
restore_video:
    push ax
    
    mov ax, 0x03
    int 0x10
    
    pop ax
    ret

; void wait_frame(void);
wait_frame:
    push ax
    push dx

    mov dx, 0x03da
    
.wait_retrace:
    in al, dx
    test al, 0x08
    jnz .wait_retrace

.wait_refresh_end:
    in al, dx
    test al, 0x08
    jz .wait_refresh_end

    pop dx
    pop ax
    ret
	
	
; void put_pixel(int x, int y);
; stack:
;		y -> bp + 6
;		x -> bp + 4
;		ret_addr -> bp + 2
put_pixel:
	push bp
	mov bp, sp
	
	push ax
	push bx
	
	; screen[(y << 8) + (y << 6) + x]
	mov bx, [bp + 6]
	mov ax, bx
	shl ax, 8
	shl bx, 6
	add bx, ax
	add bx, [bp + 4]
	
	mov byte [es:bx], 0x0f
	
	pop bx
	pop ax
	pop bp
	ret
