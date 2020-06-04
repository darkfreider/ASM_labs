
.model  tiny

print_str macro out_str
    mov ah, 9
    mov dx, offset out_str
    int 21h
endm

.code
org 100h

start:
	; command line = " 0x00 0x00"
	
	mov bx, offset program_end
	mov     cl, 4
	shr     bx, cl
	add     bx, 17 ; add 1 paragraph for alignment and 256 bytes for stack

	mov     ah, 4Ah
	int     21h

	mov     ax,bx ; set new SP value
	shl     ax,cl
	dec     ax
	mov     sp,ax
	
	; print id
	
	;;;; PRINTING ;;;;;;;;;;;
	
	; get numerical value of N
	mov al, ds:0084h
	call char_to_hex
	mov bl, al
	mov cl, 4
	shl bl, cl
	
	mov al, ds:0085h
	call char_to_hex
	or bl, al
	
	mov byte ptr N, bl
	
	; get numerical value of ID
	mov al, ds:0089h
	mov byte ptr process_id[2], al
	call char_to_hex
	mov bl, al
	mov cl, 4
	shl bl, cl
	
	mov al, ds:008ah
	mov byte ptr process_id[3], al
	call char_to_hex
	or bl, al
	
	mov byte ptr ID, bl
	
	; Pring current ID
	print_str process_id
	
	cmp byte ptr N, 1
	je start_end
	
	; patch command line for a child process N
	mov al, byte ptr N
	dec al
	mov cl, 4
	shr al, cl
	call hex_to_char
	mov byte ptr command_line[4], al
	
	mov al, byte ptr N
	dec al
	and al, 0fh
	call hex_to_char
	mov byte ptr command_line[5], al
	
	; patch command line for a child process ID
	mov al, byte ptr ID
	inc al
	mov cl, 4
	shr al, cl
	call hex_to_char
	mov byte ptr command_line[9], al
	
	mov al, byte ptr ID
	inc al
	and al, 0fh
	call hex_to_char
	mov byte ptr command_line[10], al
	
	;;;;;;;;;;;; EXEC ;;;;;;;;;;;;;;;
	mov     bx, offset command_line
	mov     cmd_off,bx
	mov     cmd_seg,ds
	
	mov     ax,ds
	mov     es,ax
	mov     bx, offset epb
	mov     dx, offset path

	mov     ax, 4B00h
	int     21h

start_end:
	print_str process_id
	
	int 20h
	

; al - hex value
; al - char (return)
hex_to_char_map db "0123456789abcdef"
hex_to_char:
	push bx
	xor bx, bx
	
	mov bl, al
	and bl, 0fh
	mov al, byte ptr hex_to_char_map[bx]
	
	pop bx
	ret

; al - char;
; al - hex value (return)
char_to_hex:
	.check_0_9:
		cmp al, '0'
		jl check_a_f
		cmp al, '9'
		jg check_a_f
		
		sub al, '0'
		jmp char_to_hex_end
		
	check_a_f:
		cmp al, 'a'
		jl char_to_hex_end
		cmp al, 'f'
		jg char_to_hex_end
		
		sub al, 'a'
		add al, 10

	char_to_hex_end:
		ret
  
path         db "C:\asm\lab7.com",0
command_line db 10, " 0x00 0x00"
epb          dw 0
cmd_off      dw ?
cmd_seg      dw ?
fcb1         dd ?
fcb2         dd ?

N db 0
ID db 0

process_id db "0x00", 0ah, 0dh, '$'
program_end: db ?
end start























