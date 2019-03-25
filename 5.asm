%macro putchars 2
      mov   eax, 4      ; sys_write
      mov   ebx, 1      ; stdout
      mov   ecx, %1     ; address of data
      mov   edx, %2     ; bytes count
      int   80h
%endmacro

%macro getchar 1
      mov   eax, 3      ; sys_read
      mov   ebx, 0      ; stdin
      mov   ecx, %1     ; address of data
      mov   edx, 1      ; bytes count
      int   80h
%endmacro

section .data
	OkMsg:		db "Everything is balanced.", 0x0A
	OkMsgLn		equ $-OkMsg
	MismMsg:	db "A '[' was expected, but a '[' was found.", 0x0A
	MismMsgLn	equ $-MismMsg
    MismMsg2:	db "Unmatched closing bracket '['.", 0x0A
    MismMsg2Ln	equ $-MismMsg2
	FailMsg:	db "The program ended with an open '['.", 0x0A
	FailMsgLn	equ $-FailMsg

	c:			db 0
section .text
	global _start
_start:

	mov ebp, esp		; save stack pointer
	mov edi, c

readloop:
		getchar edi		; read character from STDIN
		test eax, eax	; end program if zero bytes are read
		jz end
		cmp byte [edi], '{'
		je .push
		cmp byte [edi], '('
		je .push
		cmp byte [edi], '['
		je .push
        cmp byte [edi], '}'
        je .pop
        cmp byte [edi], ')'
        je .pop
        cmp byte [edi], ']'
        je .pop
		jmp readloop

.pop:
	cmp esp, ebp
	jl .stackok
		mov al, byte [edi]
		mov byte [MismMsg2 + 27], al	; adjust the error message to display the actual bracket type
		putchars MismMsg2, MismMsg2Ln
		jmp end.endif
.stackok:

	pop eax
	cmp al, '('
	jne .bracket
		dec al		; if it's '(' subtract 1 to get ')' adding 2
.bracket:
	add al, 2		; '[' + 2 is ']' and '{' + 2 is '}'

	cmp byte [edi], al
	je readloop
		mov [MismMsg + 3], al
		mov al, byte [edi]
		mov [MismMsg + 27], al			; adjust the error message to display the actual bracket type
		putchars MismMsg, MismMsgLn
	jmp end.endif
.push:

	movzx eax, byte [edi]
	push eax
	jmp readloop

end:
	cmp esp, ebp
	je	.ok
		pop eax
		mov byte [FailMsg + 32], al		; adjust the error message to display the actual bracket type
		putchars FailMsg, FailMsgLn
	jmp .endif
.ok:
		putchars OkMsg, OkMsgLn
.endif:

; quit
	mov eax, 0x1
	xor ebx, ebx
	int 80h
