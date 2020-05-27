org 0x100
BITS 16


MARIO_WIDTH equ 2
MARIO_HEIGHT equ 2

fake_start:
	jmp start
	
	%include "video.asm"
	%include "kbd.asm"
	
m_x:   dw 30
m_y:   dw 0

m_velocity_x: dw 0
m_velocity_y: dw 0

MAX_JUMP_COUNTER equ 5
jump_counter: dw 0
is_in_jump: dw 0
is_on_ground: dw 0

camera_x: dw 0
camera_y: dw 0 ; should always be 0

offset_x: dw 0
offset_y: dw 0

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
	
	
	
	call solve_collisions
	
.draw:

	mov ax, word [m_x]
	mov word [camera_x], ax
	
	mov word [offset_x], ax
	sub word [offset_x], (80 / 2)
	
	; clamp camera to game boundaries
.clamp_camera_x_min:
	cmp word [offset_x], 0
	jge .clamp_camera_x_max
	mov word [offset_x], 0
.clamp_camera_x_max:
	cmp word [offset_x], LEVEL_WIDTH - 80
	jle .draw_level
	mov word [offset_x], LEVEL_WIDTH - 80
	
.draw_level:

	mov si, 0
.draw_level_y:
	cmp si, 25
	jge .draw_mario

	mov di, 0
.draw_level_x:
	cmp di, 80
	jge .draw_level_y_end
	
	push si ;y
	
	mov bx, di
	add bx, word [offset_x]
	push bx ; x
	call get_tile
	add sp, 4
	
	or ax, 0x0200
	
	push ax ; char
	push si ; y
	push di ; x
	call put_char
	add sp, 6
	
	inc di
	jmp .draw_level_x
	
.draw_level_y_end:
	inc si
	jmp .draw_level_y

.draw_mario:
	push (0x0200 | 'f')
	push MARIO_HEIGHT ; h
	push MARIO_WIDTH  ; w
	push word [m_y]
	
	mov ax, word [m_x]
	sub ax, word [offset_x]
	push ax
	call draw_rect
	add sp, 10

	
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
	
solve_collisions:
	push bp
	mov bp, sp
	push ax
	

.check_up_or_down:

	mov word [is_on_ground], 0
.moving_up:
	cmp word [m_velocity_y], 0
	jg .moving_down
	
	push word [m_y]
	push word [m_x]
	call get_tile
	add sp, 4
	cmp al, '.'
	je .moving_up_right
	add word [m_y], 1
	mov word [jump_counter], 0 ;!!!!
	mov word [is_in_jump], 0
	jmp .done
.moving_up_right:
	push word [m_y]
	mov ax, word [m_x]
	add ax, MARIO_WIDTH - 1
	push ax
	call get_tile
	add sp, 4
	cmp al, '.'
	je .done
	add word [m_y], 1
	mov word [jump_counter], 0 ;!!!!
	mov word [is_in_jump], 0
	jmp .done

.moving_down:
	mov ax, word [m_y]
	add ax, MARIO_HEIGHT - 1
	push ax
	push word [m_x]
	call get_tile
	add sp, 4
	cmp al, '.'
	je .down_check_right_bottom
	add word [m_y], -1
	mov word [is_on_ground], 1
	jmp .done

.down_check_right_bottom:
	mov ax, word [m_y]
	add ax, MARIO_HEIGHT - 1
	push ax
	mov ax, word [m_x]
	add ax, MARIO_WIDTH - 1
	push ax
	call get_tile
	add sp, 4
	cmp al, '.'
	je .done
	add word [m_y], -1
	mov word [is_on_ground], 1

.done:
	pop ax
	pop bp
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

; int get_tile(int x, int y)
; result is in ax reg
; stack:
;		y -> bp + 6
;		x -> bp + 4
;		ret_addr -> bp + 2
get_tile:
	push bp
	mov bp, sp
	push bx
	
	xor ax, ax
	mov al, ' '
	
	cmp word [bp + 4], 0
	jl .done
	cmp word [bp + 4], LEVEL_WIDTH
	jge .done
	cmp word [bp + 6], 0
	jl .done
	cmp word [bp + 6], LEVEL_HEIGHT
	jge .done
	
	mov ax, LEVEL_WIDTH
	imul word [bp + 6]
	add ax, word [bp + 4]
	mov bx, ax
	xor ax, ax
	mov al, byte [level + bx]
	
.done:
	pop bx
	pop bp
	ret

LEVEL_WIDTH equ (2 * 80)
LEVEL_HEIGHT equ 25
level: 
    db "################################################################################################################################################################"
	db "#..............................................................................##..............................................................................#"
	db "#..............................................................................##..............................................................................#"
	db "#..............................................................................##..............................................................................#"
	db "#..............................................................................##..............................................................................#"
	db "#..............................................................................##..............................................................................#"
	db "#..............................................................................##.........................................###########..........................#"
	db "#..............................................................................##.........................................###########..........................#"
	db "#................................####..........................................##................................####..........................................#"
	db "#................................####..........................................##................................####..........................................#"
	db "#................................####..........................................##................................####..........................................#"
	db "#................................####..........................................##................................####..........................................#"
	db "#................................####..........................................##................................####..........................................#"
	db "############................################################################################.............################################.............##########"
	db "#...#####......................................................................##...#####......................................................................#"
	db "#...#####......................................................................##...#####......................................................................#"
	db "#..............................................................................##............#####.............................................................#"
	db "#..............................................................................##..............................................................................#"
	db "#...............#########.....................###########.............................................########..######################..###..##..##............#"
	db "#.............................................###########......................................................................................................#"
	db "#.....................................................................................#########................................................................#"
	db "#.........................########.............................................................................................................................#"
	db "#..............................................................................##..............................................................................#"
	db "#..............................................................................##.................########.....................................................#"
	db "################################################################################################################################################################"
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	