%macro putchar 1
      mov   eax, 4      ; sys_write
      mov   ebx, 1      ; stdout
      mov   ecx, %1     ; address of data
      mov   edx, 1      ; bytes count
      int   80h
%endmacro

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
	AskNamePrompt:	db "Please enter your name: "
	AskNamePromptLn equ $-AskNamePrompt
	AskNamePrompt2: db "Thanks...", 0xA
	AskNamePrompt2Ln equ $-AskNamePrompt2
	NEWLINE:	db 0x0A	; \n symbol
	SPACES:		times 80 db 0x20

section .bss
	str: resb 80				; string buffer
	strend:						; end of the buffer
section .text
	global _start
_start:

	putchars AskNamePrompt, AskNamePromptLn
	mov edi, str

skipspaces:
		getchar edi				; read character from STDIN
		test eax, eax			; end program if zero bytes are read
		jz end
		cmp byte [edi], ' '		; continue if a space is encountered
		je skipspaces
		cmp byte [edi], 0x09	; or if it's \t
		je skipspaces
		cmp byte [edi], 0x0D	; or if it's \r
		je skipspaces
		cmp byte [edi], 0x0A	; or if it's \n
	je skipspaces

readstr:
		inc edi					; move forward in string buffer

		getchar edi				; read character from STDIN
		test eax, eax			; end loop if zero bytes are read
		jz endloop
		cmp byte [edi], ' '		; or if a space is encountered
		je endloop
		cmp byte [edi], 0x09	; or if it's \t
		je endloop
		cmp byte [edi], 0x0D	; or if it's \r
		je endloop
		cmp byte [edi], 0x0A	; or if it's \n
		je endloop
		cmp edi, strend			; or we're out of buffer
	jl readstr
endloop:

	putchars AskNamePrompt2, AskNamePrompt2Ln

	sub edi, str				; edi is string length now
	xor esi, esi				; esi = 0

printx:
	cmp esi, edi				; while esi != edi
	je end

	mov edx, edi
	shr edx, 1					; edx = edi/2
	cmp esi, edx				; is it the horizontal bar in the '+' sign?
	jne printv
		putchars str, edi		; just print the whole string
		jmp endif
printv:
		putchars SPACES, edx	; print leading spaces

		mov ecx, str
		add ecx, esi			; ecx = str + esi
		putchar ecx				; print a letter
endif:

	putchar NEWLINE

	inc esi						; esi++
	jmp printx					; end while

end:
	putchar NEWLINE

; quit
	mov eax, 0x1
	xor ebx, ebx
	int 80h
