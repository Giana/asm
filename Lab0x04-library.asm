section .text
	global _replaceChar

_replaceChar:
	push ebp
	mov ebp, esp
	push esi
	push ebx

	xor	eax, eax
	xor	edx, edx				; i = 0

	mov	esi, [ebp + 8]			; textPtr
	mov	bl, [ebp + 16]			; chS
	mov	cl, [ebp + 20]			; chR

replaceloop:
	cmp	edx, [ebp + 12]			; len
	jge	.end					; while i < len
		cmp	[esi + edx], bl		; if(textPtr[i] == chS)
		jne	.noreplace
			mov	[esi + edx], cl	; textPtr[i] = chR
			inc	eax				; chars replaced ++

.noreplace:
		inc	edx					; i++
		jmp	replaceloop

.end:
	pop	ebx
	pop	esi

	leave
	ret
