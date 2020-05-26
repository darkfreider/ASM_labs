

PRIVATE_old_kbd_offset: dw 0
PRIVATE_old_kbd_seg:    dw 0

; void install_kbd(void);
install_kbd:
	push ax
	push bx
	push dx
	push es
	
	; get old kbd handler in es:bx
	mov ax, 0x3509
	int 0x21
	mov word [PRIVATE_old_kbd_offset], bx
	mov word [PRIVATE_old_kbd_seg], es
	
	; new kbd handler ds:dx
	mov ax, 0x2509
	mov dx, PRIVATE_kbd_isr
	int 0x21
	
	pop es
	pop dx
	pop bx
	pop ax
	
	ret
	

; void restore_kbd(void);	
restore_kbd:
	push ax
	push dx
	push ds
	
	mov ax, 0x2509
	mov dx, word [PRIVATE_old_kbd_offset]
	mov ds, word [PRIVATE_old_kbd_seg]
	int 0x21
	
	pop ds
	pop dx
	pop ax
	ret

	
%define KEY_PRESSED  0x01
%define KEY_RELEASED 0x02

KBD_ESC_STATE:   dw KEY_RELEASED
KBD_A_STATE:     dw KEY_RELEASED
KBD_D_STATE:     dw KEY_RELEASED
KBD_SPACE_STATE: dw KEY_RELEASED

%define KEYCODE_ESC_PR  0x01
%define KEYCODE_ESC_REL 0x81

%define KEYCODE_A_PR   0x1E
%define KEYCODE_A_REL  0x9E

%define KEYCODE_D_PR  0x20
%define KEYCODE_D_REL 0xA0

%define KEYCODE_SPACE_PR  0x39
%define KEYCODE_SPACE_REL 0xB9


PRIVATE_kbd_isr:
	push ax
	
	in al, 0x60

.handle_esc_pr:
	cmp al, KEYCODE_ESC_PR
	jne .handle_esc_rel
	mov word [KBD_ESC_STATE], KEY_PRESSED
	jmp .done
.handle_esc_rel:
	cmp al, KEYCODE_ESC_REL
	jne .handle_a_pr
	mov word [KBD_ESC_STATE], KEY_RELEASED
	jmp .done
	
.handle_a_pr:
	cmp al, KEYCODE_A_PR
	jne .handle_a_rel
	mov word [KBD_A_STATE], KEY_PRESSED
	jmp .done
.handle_a_rel:	
	cmp al, KEYCODE_A_REL
	jne .handle_d_pr
	mov word [KBD_A_STATE], KEY_RELEASED
	jmp .done
	
.handle_d_pr:
	cmp al, KEYCODE_D_PR
	jne .handle_d_rel
	mov word [KBD_D_STATE], KEY_PRESSED
	jmp .done
.handle_d_rel:
	cmp al, KEYCODE_D_REL
	jne .handle_space_pr
	mov word [KBD_D_STATE], KEY_RELEASED
	jmp .done
	
.handle_space_pr:
	cmp al, KEYCODE_SPACE_PR
	jne .handle_space_rel
	mov word [KBD_SPACE_STATE], KEY_PRESSED
	jmp .done
.handle_space_rel:
	cmp al, KEYCODE_SPACE_REL
	jne .handle_next_key_stab
	mov word [KBD_SPACE_STATE], KEY_RELEASED
	jmp .done
	
.handle_next_key_stab:	
.done:
	mov al, 0x20
	out 0x20, al
	
	pop ax
	iret