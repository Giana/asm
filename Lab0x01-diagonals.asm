;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main area

section .text
    global _start
_start:

    mov dword [length], 0    ; initialize length to 0
    jmp _readEach            ; move on to reading each char of input
    
_readEach:
	
    read currChar            ; read current char
    test eax, eax            ; check if nothing read in, to end loop
    jnz _loop1               ; if not 0, move on to next loop
    
_loop1:

	mov dword [count], 0     ; initialize count to 0
	jmp _loop2               ; move on to next loop
	
_loop2:

    

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sys_read area

%macro read 1         ; defines reading global var
	mov EDX, 1000     ; # of bytes to be read
	mov ECX, ???      ; address where read input is stored
	mov EBX, 0        ; standard input
	mov EAX, 3        ; code for sys_read
	int 0x80          ; stop, do a sys_read
%endmacro

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sys_write area

%macro write 1        ; defines writing global var
	mov EDX, ???      ; length of what's to be printed
	mov ECX, ???      ; address of what's to be printed
	mov EBX, 1        ; standard output
	mov EAX, 4        ; code for sys_write
	int 0x80          ; stop, do a sys_write
%endmacro

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; data area

section .data

    newline db 0x0A         ; newline character
    space db 0x20           ; space character

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; reservation area

section .bss

    length resd 1           ; 4 bytes resvd for lngth of line
    currChar resd 1         ; 4 bytes resvd for current char
    count resd 1            ; 4 bytes resvd for counter
