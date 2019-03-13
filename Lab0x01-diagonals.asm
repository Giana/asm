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
    mov EDX, 1        ; length of what's to be printed
    mov ECX, %1       ; address of what's to be printed
    mov EBX, 1        ; standard output
    mov EAX, 4        ; code for sys_write
    int 0x80          ; stop, do a sys_write
%endmacro

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; data area

section .data

    newline: db 0xA          ; newline character
    space: db 0x20           ; space character

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; reservation area

section .bss

    length: resd 1           ; 4 bytes resvd for length of line
    currChar: resd 1         ; 4 bytes resvd for current char
    count: resd 1            ; 4 bytes resvd for counter

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main area

section .text
    global _start
_start:
	
    mov dword [length], 0    ; initialize length to 0
    jmp _readEach            ; move on to reading each char of input

_loop1:

    mov dword [count], 0   ; initialize count to 0
    jmp spaces             ; move on to next loop

_loop2:
	
    write space            ; put a space
    inc dword [count]      ; inc the count and move on
    
spaces:

    mov eax, [count]
    cmp eax, [length]      ; compare count and length
    jl _loop2              ; if count < length, move on to next loop
    
    cmp byte [currChar], 0x0A    ; compare current char to newline
    jnz nl1                      ; move to next loop
    
    mov dword [length], 0        ; it's a newline, set length to 0
    jmp nl2    
    
nl1:

    inc dword [length]          ; inc the length and move on
    
nl2:

    write currChar              ; print current char
    cmp byte [currChar], 0x0A   ; compare current char to newline
    jz _readEach                ; restart the cycle
    
    write newline               ; place newline after current char

_readEach:
	
    read currChar          ; read current char
    test eax, eax          ; check if nothing read in, to end loop
    jnz _loop1             ; if not 0, move on to next loop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; exit area

	mov eax, 0x1
	xor ebx, ebx
	int 0x80
