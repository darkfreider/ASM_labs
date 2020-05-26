org 0x100
BITS 16

%define REFRESH_RATE 70
%define WAIT_SECS 1

fake_start:
	jmp start
	
	%include "video.asm"
	%include "kbd.asm"
	
pixel_x: dw 0
pixel_y: dw 5

ESC_STATE:   dw KEY_RELEASED
A_STATE:     dw KEY_RELEASED
D_STATE:     dw KEY_RELEASED
SPACE_STATE: dw KEY_RELEASED

start:
	mov bp, sp
	
	call init_text_video
	call install_kbd
	
	push 0
	push 0
	call put_char
	add sp, 4
	
	push 10
	push 10
	call put_char
	add sp, 4
	
	push 24
	push 79
	call put_char
	add sp, 4
	
.game_loop:

	call grab_input
	
	cmp word [ESC_STATE], KEY_PRESSED
	je .done
	
.handle_d_key:
	cmp word [D_STATE], KEY_PRESSED
	jne .handle_a_key
	add word [pixel_x], 1
	jmp .game_logic
	
.handle_a_key:	
	cmp word [A_STATE], KEY_PRESSED
	jne .handle_next_key_stab ; change it if you want to add new keys
	sub word [pixel_x], 1
	jmp .game_logic
	
.handle_next_key_stab:

.game_logic:
	call clear_screen
	
	push 4 ; h
	push 8 ; w
	push word [pixel_y]
	push word [pixel_x]
	call draw_rect
	add sp, 8

.game_loop_end:
	call flip_offscreen_buffer
    call frame_delay
	
	jmp .game_loop
	
.done:
	call restore_kbd
	call restore_text_video
	
    mov ax, 0x4c00
    int 0x21


; Grab kbd keys states for this frame	
grab_input:
	cli
	
	mov ax, word [KBD_ESC_STATE]
	mov word [ESC_STATE], ax
	
	mov ax, word [KBD_A_STATE]
	mov word [A_STATE], ax
	
	mov ax, word [KBD_D_STATE]
	mov word [D_STATE], ax
	
	mov ax, word [KBD_SPACE_STATE]
	mov word [SPACE_STATE], ax
	
	sti
	ret
	
; void frame_delay(void);
frame_delay:
	pusha
	
	mov cx, 0x00
	mov dx, 0xc350
	mov ax, 0x8600
	int 0x15
	
	popa
	ret
	
	
	
	

	
	
	
	
	
	
	
	
	
	
	ret