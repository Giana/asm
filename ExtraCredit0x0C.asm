section .bss
	n:		resd 1
	last:	resd 1

section .text
	global _start
	extern strcmp
	extern puts

bubble_sort:
; accepts array size in ecx, array ptr in edx

	push ebx					; save regs
	push esi
	push edi

	mov ebp, ecx
	dec ebp						; n = array size - 1
	mov	[n], ebp

	test ebp, ebp
	jle	.end					; no point in sorting if n <= 0

	mov	ebx, edx				; save array ptr

	lea	eax, [edx + ecx*4 - 4]	; pointer to the last element = array ptr + (count - 1)*pointer_size (pointer size is 4 bytes)
	mov	[last], eax

.outer_loop:
		mov	esi, ebx			; ptr to the first arary element

.inner_loop:
			mov	edi, [esi]		; current element
			mov	ebp, [esi + 4]	; next element

			push ebp
			push edi
			call strcmp
			add	esp, 8

			test eax, eax
			jle .dontswap		; swap if return value > 0
				mov	[esi], ebp
				mov	[esi + 4], edi
.dontswap:

			add	esi, 4			; move on to the next array element
			cmp	[last], esi		; don't sort beyond the "last lement to sort"
		jnz	.inner_loop

		sub	dword [last], 4		; move pointer to the "last element to sort" forward because the rest is sorted already

		sub	dword [n], 1		; loop arraysize - 1 times
		cmp dword [n], 0
	jnz	.outer_loop

.end:

	pop edi						; restore regs
	pop esi
	pop ebx
	ret

_start:

	mov ebx, [esp]		; get argc
	lea esi, [esp + 4]	; get argv

	dec ebx				; skip argv[0]
	add esi, 4

	mov ecx, ebx		; array size
	mov edx, esi		; array ptr
	call bubble_sort

	jmp .printargv

.loop:
		push dword [esi]
		call puts
		add esp, 4

		add esi, 4		; argv++

		dec ebx
.printargv:
		test ebx, ebx	; loop argc - 1 times
	jnz .loop

; quit
	mov eax, 0x1
	xor ebx, ebx
	int 80h
