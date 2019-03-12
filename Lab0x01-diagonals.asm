;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sys_read area

%macro readC 1        ; defines reading global var
	mov EDX, 1000     ; # of bytes to be read
	mov ECX, ???      ; address where read input is stored
	mov EBX, 0        ; standard input
	mov EAX, 3        ; code for sys_read
	int 0x80          ; stop, do a sys_read
%endmacro

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sys_write area

%macro writeC 1
	mov EDX, ???
	mov ECX, ???
	mov EBX, 1
	mov EAX, 4
	int 0x80
%endmacro

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
