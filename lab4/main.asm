org 0x100
BITS 16

%define REFRESH_RATE 70
%define WAIT_SECS 1

fake_start:
	jmp start
	
	%include "video.asm"
	%include "kbd.asm"
	
m_x:   dw 30
m_y:   dw 0

m_velocity_x: dw 0
m_velocity_y: dw 0

%define MAX_JUMP_COUNTER 10
jump_counter: dw 0
is_in_jump: dw 0
is_on_ground: dw 0

ESC_STATE:   dw KEY_RELEASED
A_STATE:     dw KEY_RELEASED
D_STATE:     dw KEY_RELEASED
SPACE_STATE: dw KEY_RELEASED

start:
	mov bp, sp
	
	call init_text_video
	call install_kbd
	
.game_loop:

	call grab_input
	
	cmp word [ESC_STATE], KEY_PRESSED
	je .done
	
	mov word [m_velocity_x], 0
	mov word [m_velocity_y], 0
	
.handle_d_key:
	cmp word [D_STATE], KEY_PRESSED
	jne .handle_a_key
	mov word [m_velocity_x], 1
	
.handle_a_key:	
	cmp word [A_STATE], KEY_PRESSED
	jne .handle_space_key ; change it if you want to add new keys
	mov word [m_velocity_x], -1
	
.handle_space_key:
	cmp word [SPACE_STATE], KEY_PRESSED
	jne .next_key_stab
	
	cmp word [is_in_jump], 1
	je .next_key_stab
	
	cmp word [is_on_ground], 0
	je .next_key_stab
	
	mov word [is_in_jump], 1
	
.next_key_stab:

.game_logic:
	call clear_screen
	
	cmp word [is_in_jump], 1
	jne .apply_gravity
	cmp word [jump_counter], MAX_JUMP_COUNTER
	jge .end_of_jump
	inc word [jump_counter]
	mov word [m_velocity_y], -1
	jmp .update_position
	
.end_of_jump:
	mov word [jump_counter], 0
	mov word [is_in_jump], 0
	
.apply_gravity:
	mov word [m_velocity_y], 1

.update_position:
	mov ax, word [m_velocity_x]
	add word [m_x], ax
	mov ax, word [m_velocity_y]
	add word [m_y], ax
	
	
	
	mov word [is_on_ground], 0
.solve_collisions:
	; solve collisions
	mov ax, word [m_y]
	add ax, 4
	cmp ax, 25
	jle .draw
	mov word [is_on_ground], 1
	mov word [m_y], 25 - 4
	
.draw:
	push 4 ; h
	push 8 ; w
	push word [m_y]
	push word [m_x]
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
	;mov dx, 0x80e8
	mov ax, 0x8600
	int 0x15
	
	popa
	ret

; int16 mul_fixed(int16 a, int16 b);
; stack:
;		b -> bp + 6
;		a -> bp + 4
;		ret_addr -> bp + 2
mul_fixed:
	push bp
	mov bp, sp
	push ax
	push bx
	push dx
	
	mov ax, word [bp + 4]
	shr ax, 3
	mov bx, word [bp + 6]
	shr bx, 3
	
	imul bx
	shr ax, 2
	
	pop dx
	pop bx
	pop ax
	pop bp
	ret
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	