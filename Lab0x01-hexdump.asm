;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sys_read area

%macro read 1             ; defines reading global var
	mov EDX, 1        ; # of bytes to be read
	mov ECX, %1       ; address where read input is stored
	mov EBX, 0        ; standard input
	mov EAX, 3        ; code for sys_read
	int 0x80          ; stop, do a sys_read
%endmacro

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sys_write area

%macro write 1            ; defines writing global var
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

_lncloop:

    movzx eax, byte [currChar]	; place char (in al) and fill front
                                ; with 0s
    mov ah, al			; copy currChar left
    shr ah, 4			; shift it right a half byte (aka
    				; shift "out" the low "nibble")
    and eax, 0f0fh		; high nibbles of ah and al zeroed
    cmp al, 0xA			; compare al to newline
    jb _hncloop                 ; continue to next loop if >=		
    add al, 07h		        ; 41h - 30h - 0Ah
    
_hncloop:

    add al, 30h			; adding 0, char conversion
    cmp ah, 0xA
    jb _loop2
    add ah, 07h
    
_loop2:

    add ah, 30h                 ; adding 0, char conversion
    mov [currChar], eax
    write currChar + 1	        ; high nib
    write currChar		; low nib	
    write space
    inc dword [count]
    cmp dword [count], columns	; compare, count < columns
    jl _readEach                ; if so, jump
    write newline
    mov dword [count], 0

_readEach:
	
    read currChar          ; read current char
    test eax, eax          ; check if nothing read in, to end loop
    jnz _lncloop           ; if not 0, move on to next loop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; exit area

	mov eax, 0x1
	xor ebx, ebx
	int 0x80
