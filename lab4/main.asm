org 0x100
BITS 16

%define REFRESH_RATE 70
%define WAIT_SECS 1

fake_start:
	jmp start
	
	%include "video.asm"
	%include "kbd.asm"
	
pixel_x: dw 0
pixel_y: dw 100

start:
	mov bp, sp
	
    call init_video
	call install_kbd

	push 0 ;y
	push 0 ;x
	call put_pixel
	add sp, 4
	
	push 100 ;y
	push 100 ;x
	call put_pixel
	add sp, 4
	
	push 199  ;y
	push 319 ;x
	call put_pixel
	add sp, 4
	
.game_loop:
	cmp word [ESC_STATE], KEY_PRESSED
	je .done
	
	cmp word [Q_STATE], KEY_PRESSED
	jne .game_logic
	add word [pixel_x], 1
	
.game_logic:
	push word [pixel_y]
	push word [pixel_x]
	call put_pixel
	add sp, 4

.game_loop_end:
    call wait_frame
	jmp .game_loop
	
.done:
	call restore_kbd
    call restore_video

    mov ax, 0x4c00
    int 0x21