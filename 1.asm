%macro putchar 1
      mov   eax, 4	; sys_write
      mov   ebx, 1	; stdout
      mov   ecx, %1	; address of data
      mov   edx, 1	; bytes count
      int   80h
%endmacro

%macro getchar 1
      mov   eax, 3	; sys_read
      mov   ebx, 0	; stdin
      mov   ecx, %1	; address of data
      mov   edx, 1	; bytes count
      int   80h
%endmacro

section .data
	NEWLINE:	db 0xA	; \n symbol
	SPACE:		db 0x20

section .bss
	c: resd 1	; current character
	w: resd 1	; line length
	i: resd 1	; loop counter for printspaces loop

section .text
	global _start
_start:
	
	mov     dword [w], 0
	jmp readchar					; start reading characters

readloop:
		mov     dword [i], 0		; int i = 0
		jmp printspaces

printspacesloop:					; for(;;)
			putchar SPACE
			inc     dword [i]		; i++
	
printspaces:
			mov     eax, [i]
			cmp     eax, [w]		; i < w
		jl  printspacesloop

		cmp     byte [c], 0Ah		; is current character a new-line character (LF)?
		jnz notlf
			mov     dword [w], 0	; yes - reset the line length
		jmp notlf2
notlf:
			inc     dword [w]
notlf2:

		putchar c					; print the current character
		
		cmp byte [c], 0Ah			; is it a new-line character (LF)?
		jz readchar
			putchar NEWLINE			; if not, print a new-line after it

readchar:

		getchar c					; read character from STDIN
		test eax, eax				; end loop if zero bytes are read
	jnz readloop

; quit
	mov eax, 0x1
	xor ebx, ebx
	int 80h
