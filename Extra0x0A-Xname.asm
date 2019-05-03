;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sys_read area

%macro read 1         ; defines reading global var
	mov EDX, 1        ; # of bytes to be read
	mov ECX, %1       ; address where read input is stored
	mov EBX, 0        ; standard input
	mov EAX, 3        ; code for sys_read
	int 0x80          ; stop, do a sys_read
%endmacro

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sys_write area

%macro write 1        ; defines writing global var
	mov EDX, 1        ; bytes
	mov ECX, %1       ; address of what's to be printed
	mov EBX, 1        ; standard output
	mov EAX, 4        ; code for sys_write
	int 0x80          ; stop, do a sys_write
%endmacro


%macro writes 2       ; defines writing global var
	mov EDX, %2       ; bytes
	mov ECX, %1       ; address of what's to be printed
	mov EBX, 1        ; standard output
	mov EAX, 4        ; code for sys_write
	int 0x80          ; stop, do a sys_write
%endmacro

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; data area

section .data

    AskNamePrompt: db "Please enter your name: "
    AskNamePromptLn equ $-AskNamePrompt
    AskNamePrompt2: db "Thanks...", 0xA
    AskNamePrompt2Ln equ $-AskNamePrompt2
    NEWLINE: db 0x0A
    SPACES: times 80 db 0x20
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; reservation area

section .bss

    min: resd 1
    max: resd 1
    m: resd 1
    str: resb 80	; string buffer
    strend:	        ; end of the buffer

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main area

section .text
	global _start
_start:

    writes AskNamePrompt, AskNamePromptLn
    mov edi, str
	
skipspaces:

    read edi	            ; read character from stdin
    test eax, eax	        ; end program if zero bytes read
    jz end
    cmp byte [edi], ' '	    ; continue if space encountered
    je skipspaces
    cmp byte [edi], 0x09	; or if it's \t
    je skipspaces
    cmp byte [edi], 0x0D	; or if it's \r
    je skipspaces
    cmp byte [edi], 0x0A	; or if it's \n
    je skipspaces

readstr:

    inc edi	                ; move forward in string buffer
	read edi	            ; read character from stdin
    test eax, eax	        ; end loop if zero bytes read
    jz endloop
    cmp byte [edi], ' '   	; or if space encountered
    je endloop
    cmp byte [edi], 0x09	; or if it's \t
    je endloop
    cmp byte [edi], 0x0D	; or if it's \r
    je endloop
    cmp byte [edi], 0x0A	; or if it's \n
    je endloop
    cmp edi, strend	        ; or we're out of buffer
    jl readstr
    
endloop:
	
    writes AskNamePrompt2, AskNamePrompt2Ln
    sub edi, str	                        ; edi string length now
    dec edi
    xor esi, esi	                        ; esi is 0
    
printx:

    test edi, edi	      ; while edi >= 0
    js end
    cmp esi, edi	      ; if esi >= edi
    jl less
    mov [min], edi
    mov [max], esi
    mov [m], esi
    sub [m], edi
    jmp endif1	          ; else
    
less:

    mov [min], esi
    mov [max], edi
    mov [m], edi
    sub [m], esi
    
endif1:	
                                    ; endif
	
    dec dword [m]	                ; m = abs(esi - edi) - 1
                                    ; min = min(esi, edi)
                                    ; max = max(esi, edi)
    writes SPACES, dword [min]      ; print leading spaces
    mov ecx, str
    add ecx, dword [min]
    write ecx	                    ; print letter from left side
                                    ; of 'x'
    
    cmp esi, edi	                ; if (esi != edi), not the
                                    ; center of the 'x'
    je endif2
    writes SPACES, dword [m]	    ; print middle spaces
    
    mov ecx, str
    add ecx, dword [max]
    write ecx	                    ; print letter from right side
    
endif2:

    write NEWLINE
    inc esi	             ; esi changes from 0 to strlen - 1
    dec edi	             ; edi changes from strlen - 1 to 0
    jmp printx	         ; end while
    
end:

    write NEWLINE
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; exit area

	mov eax, 0x1
	xor ebx, ebx
	int 0x80
