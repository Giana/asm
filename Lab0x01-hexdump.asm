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
; constant area

columns equ 8         ; hard coded column #, easily changed

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; data area

section .data

    newline: db 0xA          ; newline character
    space: db 0x20           ; space character
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; reservation area

section .bss

    currChar: resd 1         ; 4 bytes resvd for current char
    count: resd 1            ; 4 bytes resvd for counter

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main area

section .text
	global _start
_start:

_loop1:

    movzx eax, byte [currChar]	; place char and fill front with 0s
    mov ah, al			        ; copy currChar left
    shr ah, 4			        ; shift it right a half byte (aka
    							; shift "out" the low "nibble", so
    							; I have read)
    and eax, 0f0fh		        ; mask, leave what we want
    cmp al, 0xA			        ; compare al to newline
    jb _loop2                   ; continue on to next loop			
    add al, 07h		            ; 41h - 30h - 0Ah

_readEach:
	
    read currChar          ; read current char
    test eax, eax          ; check if nothing read in, to end loop
    jnz _loop1           ; if not 0, move on to next loop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; exit area

	mov eax, 0x1
	xor ebx, ebx
	int 0x80
