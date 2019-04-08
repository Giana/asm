section .text
    global _replaceChar
    global _sumAndPrintList
    extern printf

_replaceChar:

    push ebp
    mov ebp, esp
    push esi
    push ebx

    xor	eax, eax
    xor	edx, edx                ; i = 0

    mov	esi, [ebp + 8]          ; textPtr
    mov	bl, [ebp + 16]          ; chS
    mov	cl, [ebp + 20]          ; chR

replaceloop:

    cmp	edx, [ebp + 12]         ; len
    jge	.end                    ; while i < len
    cmp	[esi + edx], bl         ; if(textPtr[i] == chS)
    jne	.noreplace
    mov	[esi + edx], cl         ; textPtr[i] = chR
    inc	eax                     ; chars replaced ++

.noreplace:

    inc	edx            ; i++
    jmp	replaceloop

.end:

    pop	ebx
    pop	esi

    leave
    ret

hdr: db "Numbers", 9, "Running Total", 0Ah, 0
fmt: db "%7d", 9, "%d", 0Ah, 0

_sumAndPrintList:

    push ebp
    mov ebp, esp
    push esi
    push edi
    push ebx

    xor ebx, ebx                ; i = 0
    xor esi, esi                ; sum = 0
    mov edi, [ebp + 8]          ; list

    push hdr
    call printf
    add esp, 4

;;; [ebp + 12] -- length

.addloop:

    add esi, [edi + 4*ebx]

    push esi
    push dword [edi + 4*ebx]
    push fmt
    call printf
    add esp, 12

    inc ebx
    cmp ebx, [ebp + 12]        ; length
    jl .addloop

    mov eax, esi
    pop ebx
    pop edi
    pop esi

    leave
    ret
