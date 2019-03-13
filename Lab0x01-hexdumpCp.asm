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

nCOLS	equ 16		; number of columns

section .data
	NEWLINE:	db 0xA	; \n symbol
	SPACE:		db 0x20

section .bss
	c: resd 1	; current character
	i: resd 1	; columns counter

section .text
	global _start
_start:
	
	mov dword [i], 0
	jmp readchar

readloop:
		movzx eax, byte [c]	; e.g. we got 2E ('.'), so eax would be 00 00 00 2E
		mov ah, al			; 00 00 2E 2E
		shr ah, 4			; 00 00 02 2E
		and eax, 0f0fh		; 00 00 02 0E
		
		; convert low nibble
		cmp al, 0ah			; if al >= 'A'
		jb numeric1			
			add al, 07h		; 'A' is 41h and '0' is 30h, 41h - 30h - 0Ah = 7
numeric1:
		add al, 30h			; add ascii code of '0' 

		; similarly convert high nibble
		cmp ah, 0ah
		jb numeric2
			add ah, 07h
numeric2:
		add ah, 30h
		
		mov [c], eax	; store it back

		putchar c + 1	; print high nibble
		putchar c		; print low nibble
		
		putchar SPACE
		inc dword [i]	; increment the columns count

		cmp dword [i], nCOLS	; if i < nCOLS
		jl readchar
			putchar NEWLINE		; putchar('\n')
			mov dword [i], 0	; i = 0

readchar:

		getchar c		; read character from STDIN
		test eax, eax	; end loop if zero bytes are read
	jnz readloop

	putchar NEWLINE

; quit
	mov eax, 0x1
	xor ebx, ebx
	int 80h
