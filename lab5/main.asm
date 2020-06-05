org 0x100
BITS 16

CR equ 0x0d
NL equ 0x0a
; proper newline on windows/dos CR, NL

%macro terminate 0
	mov ax, 0x4c00
    int 0x21
%endmacro

%macro print_str 1
	mov ah, 9
    mov dx, %1
    int 21h
%endmacro

%macro debug_str_pring 2
	mov bx, word [%2]
	mov byte [%1 + bx], '$'
	print_str %1
	print_str msg_new_line
%endmacro


fake_start:
	jmp start
	
	msg_new_line db 0ah, 0dh, '$'
	; CMD line: " file_path target_str new_str"
	; skip space
	; read word 
	
	msg_reading_from_file: db "Reading from file!", 0ah, 0dh, '$'
	
	msg_not_enough_args:     db "Not enough arguments!", 0ah, 0dh,'$'
	msg_bad_args:            db "Bad argument line!", 0ah, 0dh, '$'
	msg_cant_open_files:     db "Can't open files!", 0ah, 0dh, '$'
	msg_cant_close_files:    db "Can't close files!", 0ah, 0dh, '$'
	msg_cant_read_from_file: db "Can't read from file!", 0ah, 0dh, '$'
	msg_improper_newline:    db "Ill formed new line, expected CR NL.", 0ah, 0dh, '$'
	msg_cant_write_to_file:  db "Can't write to a file!", 0ah, 0dh, '$'
	
	msg_cant_delete_file:    db "Can't delete file!", 0ah, 0dh, '$'
	msg_cant_rename_file:    db "Can't rename file!", 0ah, 0dh, '$'
	
	cmd_line_len dw 0
	cmd_line:    times 64 db 0
	
	file_name_len:   dw 0
	file_name:       times 64 db 0
	file_descr:      dw 0
	
	temp_file_name:  db "temp.txt", 0
	temp_file_descr: dw 0
	
	target_str_len: dw 0
	target_str:  times 64 db 0
	
	new_str_len: dw 0
	new_str:     times 64 db 0
	
	MAX_LINE_BUF_LEN equ 1024
	line_buf_len:  dw 0
	line_buf:      times MAX_LINE_BUF_LEN db 0
	temp_line_buf: times 16 * MAX_LINE_BUF_LEN db 0
	
	BUFF_SIZ equ 512
	input_buf_len: dw 0
	input_buf:     times BUFF_SIZ db 0
	input_index:   dw 0
	
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
	

remove_sub_str:
.done:
	ret

; NOTE(max): find substring in a line_buf
;            We know the lenght of a substring (it's in target_str_len)
;            so we only need to find starting index
find_sub_str:
	push bp
	mov bp, sp
	push cx
	push dx
	push si
	push di
	; cx
	; dx
	; si - i
	; di - j
	
	mov cx, word [line_buf_len]
	sub cx, word [target_str_len]
	mov si, 0
.outer_loop: ; counter si - i
	cmp si, cx
	jg .not_found
	
	mov di, 0
	mov dx, word [target_str_len]
	.inner_loop: ; counter di - j
		cmp di, dx
		jge .check
		mov bx, si
		add bx, di
		mov al, byte [line_buf + bx]
		cmp al, byte [target_str + di]
		jne .check
		
		inc di
		jmp .inner_loop
		
.check:
	cmp di, word [target_str_len]
	jne .outer_loop_end
	mov ax, si
	jmp .done
	
.outer_loop_end:
	inc si
	jmp .outer_loop
	
.not_found:
	mov ax, -1
	; cx
	; dx
	; si - i
	; di - j
.done:
	pop di
	pop si
	pop dx
	pop cx
	pop bp
	ret
	
	
open_files:
	push bp
	mov bp, sp
	pusha
	
	xor cx, cx
	
.open_data_file: ; open existing file
	mov ah, 0x3d
	mov al, 0x20        ;readonly, block write, other cannot write (DOS 3.0+)
	mov dx, file_name
	int 0x21
	jc .fail
	mov word [file_descr], ax
	
.open_temp_file: ; open file and truncate
	xor cx, cx
	mov ax, 0x3c00
	mov dx, temp_file_name
	int 0x21
	jc .fail
	mov word [temp_file_descr], ax
	
	jmp .done
	
.fail:
	print_str msg_cant_open_files
	terminate
	
.done:
	popa
	pop bp
	ret
	
close_files:
	push bp
	mov bp, sp
	pusha
	
	mov bx, word [file_descr]
	mov ax, 0x3e00
	int 0x21
	jc .fail
	
	mov bx, word [temp_file_descr]
	mov ax, 0x3e00
	int 0x21
	jc .fail
	
	jmp .done
	
.fail:
	print_str msg_cant_close_files
	terminate
	
.done:
	popa
	pop bp
	ret
	
; output is in ax (al)
; al = -1 means EOF
get_char:
	push bp
	mov bp, sp
	push bx
	push cx
	push dx
	
	
	mov bx, word [input_buf_len]
	cmp word [input_index], bx
	jl .read_from_buffer
	
	;print_str msg_reading_from_file
	
	mov bx, word [file_descr]
	mov cx, BUFF_SIZ
	mov dx, input_buf
	mov ax, 0x3f00
	int 0x21
	jc .fail
	
	mov word [input_buf_len], ax
	mov word [input_index], 0
	cmp ax, 0
	jne .read_from_buffer
	mov ax, -1
	jmp .done
	
.fail:
	print_str msg_cant_read_from_file
	terminate
	
.read_from_buffer:
	xor ax, ax
	mov bx, word [input_index]
	mov al, byte [input_buf + bx]
	inc word [input_index]
	
.done:
	pop dx
	pop cx
	pop bx
	pop bp
	ret
	
get_line:
	push bp
	mov bp, sp
	push bx
	
	xor bx, bx
	mov word [line_buf_len], 0
	
.getline:
	call get_char
	cmp al, CR
	je .check_new_line
	cmp al, -1
	je .done
	mov byte [line_buf + bx], al
	inc bx
	inc word [line_buf_len]
	jmp .getline
	
	
	
.check_new_line:
	mov byte [line_buf + bx], al
	inc bx
	inc word [line_buf_len]
	
	call get_char
	cmp al, NL
	jne .improper_newline
	mov byte [line_buf + bx], al
	inc bx
	inc word [line_buf_len]
	jmp .done
	
.improper_newline:
	print_str msg_improper_newline
	terminate
	
.done:
	mov ax, word [line_buf_len]
	pop bx
	pop bp
	ret

write_line:
	push bp
	mov bp, sp
	pusha
	
	mov bx, word [temp_file_descr]
	mov cx, [line_buf_len]
	mov dx, line_buf
	mov ax, 0x4000
	int 0x21
	jnc .done
	
	print_str msg_cant_write_to_file
	terminate
	
.done:
	popa
	pop bp
	ret
	
tmp_msg: times 16 db 0

start:
	mov bp, sp
	mov ax, ds
	mov es, ax
	
	call read_cmd_line
	call parse_cmd_line
	
	call open_files
	
.main_loop:
	call get_line
	cmp ax, 0
	je .done

.replacement_loop:
	call find_sub_str
	cmp ax, -1
	je .replacement_loop_end
	
	cld
	
	mov cx, ax
	mov si, line_buf
	mov di, temp_line_buf
	rep movsb
	
	mov cx, word [new_str_len]
	mov si, new_str
	rep movsb
	
	mov si, line_buf
	add si, ax
	add si, word [target_str_len]
	mov cx, word [line_buf_len]
	sub cx, ax
	sub cx, word [target_str_len]
	rep movsb
	
	mov cx, MAX_LINE_BUF_LEN
	mov si, temp_line_buf
	mov di, line_buf
	rep movsb
	
	mov cx, word [line_buf_len]
	sub cx, word [target_str_len]
	add cx, word [new_str_len]
	mov word [line_buf_len], cx
	
	jmp .replacement_loop
	
.replacement_loop_end:
	call write_line
	jmp .main_loop
	
	
.done:
	call close_files
	
	; delete main data file
	mov dx, file_name
	xor cx, cx
	mov ax, 0x4100
	int 0x21
	jc .cant_delete_file
	
	; rename temp file
	mov dx, temp_file_name
	mov di, file_name
	xor cx, cx
	mov ax, 0x5600
	int 0x21
	jc .cant_rename_file
	
	mov ax, 0x4c00
    int 0x21

.cant_delete_file:
	print_str msg_cant_delete_file
	terminate
	
.cant_rename_file:
	print_str msg_cant_rename_file
	terminate






















