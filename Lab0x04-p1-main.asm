%macro putchars 2
	mov ecx, %1		; address of data
	mov edx, %2		; bytes count
	mov eax, 4		; sys_write
	mov ebx, 1		; stdout
	int 80h
%endmacro

%macro getchar 1
	mov ecx, %1		; address of data
	mov eax, 3		; sys_read
	mov ebx, 0		; stdin
	mov edx, 1		; bytes count
	int 80h
%endmacro

section .data
	AskMsg1:	db "Enter character to search for: "
	AskMsg1Ln	equ $-AskMsg1
	AskMsg2:	db "Enter the replacement character: "
	AskMsg2Ln	equ $-AskMsg2
	AskMsg3:	db "Enter lines of text, blank line to exit",0x0a
	AskMsg3Ln   equ $-AskMsg3

	s:			dd 0		; for search char
	r:			dd 0		; for replace char

section .bss
	str:		resb 512	; reserve big enough buffer for reading lines from stdin

section .text
	global _start
	extern _replaceChar

; in: buffer addr (ecx), out: chars read (eax)
; no buffer size checks since we assume lines of text will be maximum of 100 characters
gets:
	push esi			; save registers
	push edi
	push ebx

	xor esi, esi
	mov edi, ecx

.readchar:
	getchar edi			; read character from STDIN
	test eax, eax		; end program if zero bytes are read
	jz .end
		inc esi			; chars read++
		cmp byte [edi], 0x0A
		je .end
			inc edi		; bufPtr++
			jmp .readchar

.end:
	mov eax, esi
	pop ebx				; restore registers
	pop edi
	pop esi
	ret

_start:

	mov ebp, esp

askcharloop1:
		putchars AskMsg1, AskMsg1Ln

		mov ecx, str
		call gets				; read line from STDIN
		test eax, eax
		jz end
		cmp byte [str], 0x0A	; ask again if got newline
		je askcharloop1

	mov al, byte [str]
	mov byte [s], al			; save the search character

askcharloop2:
		putchars AskMsg2, AskMsg2Ln

		mov ecx, str
		call gets				; read line from STDIN
		test eax, eax
		jz end
		cmp byte [str], 0x0A	; ask again if got newline
		je askcharloop2

	mov al, byte [str]
	mov byte [r], al			; save the replace character

	putchars AskMsg3, AskMsg3Ln

replaceloop:
		mov ecx, str
		call gets				; read line from STDIN
		test eax, eax
		jz end
		cmp byte [str], 0x0A
		je end

		mov ebx, eax			; save the string length

		push dword [r]
		push dword [s]
		push eax
		push str
		call _replaceChar
		add esp, 16				; cdecl calling convention requires the caller to clean the stack

		putchars str, ebx		; print the modified line
		jmp replaceloop

end:
; quit
	mov eax, 0x1
	xor ebx, ebx
	int 80h
