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

%macro write 2        ; defines writing global var
	mov EDX, %2       ; length of what's to be printed
	mov ECX, %1       ; address of what's to be printed
	mov EBX, 1        ; standard output
	mov EAX, 4        ; code for sys_write
	int 0x80          ; stop, do a sys_write
%endmacro

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; data area

section .data

    okMsg: db "Everything is balanced.", 0x0A
    okMsgLn equ $-okMsg
    mismMsg: db "A '[' was expected, but a '[' was found.", 0x0A
    mismMsgLn equ $-mismMsg
    mismMsg2: db "Unmatched closing bracket '['.", 0x0A
    mismMsg2Ln equ $-mismMsg2
    failMsg: db "The program ended with an open '['.", 0x0A
    failMsgLn equ $-failMsg
	c: db 0
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main area

section .text
    global _start
_start:

    mov ebp, esp	        ; save stack pointer
    mov edi, c
	
readLoop:

    read edi	            ; read char from stdin
    test eax, eax	        ; nothing read?
    jz end                  ; well, then end the program!
    cmp byte [edi], '{'     ; we are going to compare the char read
    je .push                ; to our possibilities...
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
    jmp readLoop            ; go back through the process
    
.pop:

    cmp esp, ebp
    jl .stackOk
    mov al, byte [edi]
    mov byte [mismMsg2 + 27], al	; correct error message to
    							    ; display the legit bracket
    							    ; type
    write mismMsg2, mismMsg2Ln
    jmp end.endif

.stackOk:
	
    pop eax
    cmp al, '('
    jne .bracket
    dec al	          ; if '(', dec to get ')', adding 2

.bracket:

    add al, 2	              ; so '[' to ']' and '{' to '}'
    cmp byte [edi], al
    je readLoop
    mov [mismMsg + 3], al
    mov al, byte [edi]
    mov [mismMsg + 27], al	  ; correct error message to display
                              ; the legit bracket type
	write mismMsg, mismMsgLn
	jmp end.endif

.push:
	
    movzx eax, byte [edi]
    push eax
    jmp readLoop

end:

    cmp esp, ebp
    je .ok
    pop eax
    mov byte [failMsg + 32], al	     ; correct error message to
                                     ; display legit bracket type
	write failMsg, failMsgLn
	jmp .endif

.ok:

    write okMsg, okMsgLn

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; exit area

.endif:

	mov eax, 0x1
	xor ebx, ebx
	int 0x80
