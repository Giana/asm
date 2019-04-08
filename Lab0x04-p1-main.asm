;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sys_read area

%macro read 1         ; defines reading global var
	mov edx, 1        ; # of bytes to be read
	mov ecx, %1       ; address where read input is stored
	mov ebx, 0        ; standard input
	mov eax, 3        ; code for sys_read
	int 0x80          ; stop, do a sys_read
%endmacro

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sys_write area

%macro write 2        ; defines writing global var
	mov edx, %2       ; length of what's to be printed
	mov ecx, %1       ; address of what's to be printed
	mov ebx, 1        ; standard output
	mov eax, 4        ; code for sys_write
	int 0x80          ; stop, do a sys_write
%endmacro

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; data area

section .data

    AskMsg1:    db "Enter character to search for: "
    AskMsg1Ln   equ $-AskMsg1
    AskMsg2:    db "Enter the replacement character: "
    AskMsg2Ln   equ $-AskMsg2
    AskMsg3:    db "Enter lines of text, blank line to exit", 0x0a
    AskMsg3Ln   equ $-AskMsg3

    s:          dd 0		; for search char
    r:          dd 0		; for replace char

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; reservation area

section .bss

    str: resb 512	        ; reserve big enough buffer for
                            ; reading lines from stdin
                            
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main area

section .text
    global _start
    extern _replaceChar

;; in: buffer addr (ecx), out: chars read (eax)
;; no buffer size checks since we assume lines of text will be
;; maximum of 100 characters

gets:

    push esi        ; save registers
    push edi
    push ebx

    xor esi, esi
    mov edi, ecx

.readchar:

    read edi                    ; read character from stdin
    test eax, eax               ; end program if 0 bytes read
    jz .end
        inc esi                 ; chars read++
        cmp byte [edi], 0x0A
        je .end
            inc edi             ; bufPtr++
            jmp .readchar

.end:

    mov eax, esi
    pop ebx        ; restore registers
    pop edi
    pop esi
    ret

_start:

    mov ebp, esp

askcharloop1:

    write AskMsg1, AskMsg1Ln

    mov ecx, str
    call gets                   ; read line from stdin
    test eax, eax
    jz end
        cmp byte [str], 0x0A    ; ask again if got newline
        je askcharloop1

    mov al, byte [str]
    mov byte [s], al            ; save the search character

askcharloop2:

    write AskMsg2, AskMsg2Ln

    mov ecx, str
    call gets                   ; read line from stdin
        test eax, eax
        jz end
        cmp byte [str], 0x0A    ; ask again if got newline
        je askcharloop2

    mov al, byte [str]
    mov byte [r], al            ; save the replace character

    write AskMsg3, AskMsg3Ln

replaceloop:

    mov ecx, str
    call gets                   ; read line from STDIN
    test eax, eax
    jz end
    cmp byte [str], 0x0A
    je end

    mov ebx, eax                ; save the string length

    push dword [r]
    push dword [s]
    push eax
    push str
    call _replaceChar
    add esp, 16                 ; cdecl calling convention
                                ; requires caller to clean stack

    write str, ebx              ; print the modified line
    jmp replaceloop
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; exit area

end:

    mov eax, 0x1
    xor ebx, ebx
    int 80h
