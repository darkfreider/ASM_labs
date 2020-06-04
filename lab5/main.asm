org 0x100
BITS 16

%macro terminate 0
	mov ax, 0x4c00
    int 0x21
%endmacro

%macro print_str 1
	mov ah, 9
    mov dx, %1
    int 21h
%endmacro

fake_start:
	jmp start
	
	msg_new_line db 0ah, 0dh, '$'
	; CMD line: " file_path target_str new_str"
	; skip space
	; read word 
	
	; data
	msg_not_enough_args: db "Not enough arguments!", 0ah, 0dh,'$'
	msg_bad_args:        db "Bad argument line!", 0ah, 0dh, '$'
	
	cmd_line_len dw 0
	cmd_line:    times 64 db 0
	
	file_name_len:  dw 0
	file_name:      times 64 db 0
	temp_file_name: db "temp.txt", 0
	
	target_str_len: dw 0
	target_str:  times 64 db 0
	
	new_str_len: dw 0
	new_str:     times 64 db 0
	
	MAX_LINE_BUF_LEN equ 1024
	line_buf_len:  dw 0
	line_buf:      times MAX_LINE_BUF_LEN db 0
	temp_line_buf: times MAX_LINE_BUF_LEN db 0
	
	
read_cmd_line:
	push bp
	mov bp, sp
	pusha
	
	cld
	
	xor cx, cx
	mov cl, byte [0x80]
	mov byte [cmd_line_len], cl
	
	mov si, 0x81
	mov di, cmd_line
	rep movsb

.done:	
	popa
	pop bp
	ret
	
parse_cmd_line:
	push bp
	mov bp, sp
	pusha
	; parse file name
	; parse target_str
	; parse new_str
	
	cld
	
	mov si, 0
.skip_space_0:
	cmp si, word [cmd_line_len]
	jge .not_enough_args
	cmp byte [cmd_line + si], ' '
	jne .parse_file_name
	inc si
	jmp .skip_space_0
	
.parse_file_name:

	mov di, file_name
.copy_file_name:
	cmp si, word [cmd_line_len]
	jge .not_enough_args
	cmp byte [cmd_line + si], ' '
	je .copy_file_name_end
	mov al, byte [cmd_line + si]
	stosb
	inc si
	inc word [file_name_len]
	jmp .copy_file_name
.copy_file_name_end:
	mov al, 0 ; zero terminate string
	stosb
	
.skip_space_1:
	cmp si, word [cmd_line_len]
	jge .not_enough_args
	cmp byte [cmd_line + si], ' '
	jne .parse_target_str
	inc si
	jmp .skip_space_1
	
.parse_target_str:

	mov di, target_str
.copy_target_str:
	cmp si, word [cmd_line_len]
	jge .not_enough_args
	cmp byte [cmd_line + si], ' '
	je .parse_target_str_end
	mov al, byte [cmd_line + si]
	stosb
	inc si
	inc word [target_str_len]
	jmp .copy_target_str
.parse_target_str_end:
	mov al, 0 ; zero terminate string
	stosb
	
.skip_space_2:
	cmp si, word [cmd_line_len]
	jge .not_enough_args
	cmp byte [cmd_line + si], ' '
	jne .parse_new_str
	inc si
	jmp .skip_space_2
	
.parse_new_str:
	mov di, new_str
.copy_new_str:
	cmp si, word [cmd_line_len]
	jge .parse_new_str_end
	cmp byte [cmd_line + si], ' '
	je .parse_new_str_end
	mov al, byte [cmd_line + si]
	stosb
	inc si
	inc word [new_str_len]
	jmp .copy_new_str
.parse_new_str_end:
	mov al, 0 ; zero terminate string
	stosb

.finale_check:
	cmp word [file_name_len], 0
	je .bad_args
	
	cmp word [target_str_len], 0
	je .bad_args
	
	cmp word [new_str_len], 0
	je .bad_args
	
	jmp .done

.not_enough_args:
	print_str msg_not_enough_args
	terminate
.bad_args:
	print_str msg_bad_args
	terminate

.done:
	popa
	pop bp
	ret
	ret
	
%macro debug_str_pring 2
	mov bx, word [%2]
	mov byte [%1 + bx], '$'
	print_str %1
	print_str msg_new_line
%endmacro

start:
	mov bp, sp
	mov ax, ds
	mov es, ax
	
	call read_cmd_line

	call parse_cmd_line
	
	debug_str_pring file_name, file_name_len
	debug_str_pring target_str, target_str_len
	debug_str_pring new_str, new_str_len
	
	mov ax, 0x4c00
    int 0x21























