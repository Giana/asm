; define some symbols (constants)
maxLvlBufferSize	equ 2000
maxSegmentIndex		equ maxLvlBufferSize - 1

section .data
usageMsg			db "Usage: Assemblipede levelFileName", 0x0A, 0x00
openFileFailMsg		db "Failed to open level file.", 0x0A, 0x00
badFileFormatMsg	db "Invalide File Format.", 0x0A, 0x00
readModeStr			db "r", 0x00

winMsg				db "YOU WIN!", 0
loseMsg				db "YOU LOSE", 0
pausedMsg			db "-PAUSED-", 0

;scanf formats
oneIntFmt			db "%d", 0x00    ; format string for scanf reading one integer
twoIntFmt			db "%d %d", 0x00 ; format string for scanf reading two integers

;printf formats
dbgIntFmt			db "Debug: %d %d", 0x0A, 0x00
gameStatusFmt		db "+===+ score: %3d +==+ food left: %3d +===+", 0x0a,
					db "+=== WASD move | SPC: pause | Q quit  ===+", 0x0a, 0x00

section .bss
lvlFilePtr	resd 1

lvlWidth	resd 1
lvlHeight	resd 1

gamePaused	resd 1	; game paused flag (0 is unpaused, nonzero is paused)
gameEnded	resd 1	; game ended flag
gameScore	resd 1	; game score is snake's length
foodCnt		resd 1		; food bits count

lvlBuffer	resb maxLvlBufferSize	; this stores that actual game level as a grid of asci text characters
									; this is the "picture" of the game which is redrawn each game tick
lvlBufSize	equ $ - lvlBuffer

xStep		resd 1		; -1, 0, or 1, how far to step horizontally per tick 
yStep		resd 1		; -1, 0, or 1, how far to step vertically per tick 
yDelta		resd 1		; amount to change address of head to move exacly one line up or down (should be lvlWidth+1)

segmentX	resd 1		; place to temporarily store X coordinate of a body segment (or head)
segmentY	resd 1		; place to temporarily store X coordinate of a body segment (or head)

headAddressInLvlBuffer resd 1	; address of millipede (player) head in the lvlBuffer = lvlBuffer + Y*yDelta + X
								; note: we never need to keep track of X & Y position separately
								; if we want to go "up" or "down" one step, we subtract or add yDelta (which is lvlWidth+1)

bodySegmentAddresses times maxLvlBufferSize resd 1	; array of pointers to location of body segments in the lvlBuffer
headIndex	resd 1	; index of the head Address in bodyAddresses
tailIndex	resd 1	; index of the tail Address (last body segmeent) in bodyAddresses
					; note that that headIndex and tailIndex "chase" each other around within the bodyAddresses array
					; and can wrap around so the head can be chasing the tail (when head is chasing tail, the entries in between are garbage data)
bodyLength	resd 1	; length of the millipede body -- should equal 1 + ( headIndex-tailIndex(modulo maxLvlBufferSize) )
					; "modulo" or "clock arithmetic" because head/tail indexes can "wrap around"


; std C lib functions
extern printf
extern fscanf
extern fgets
extern fopen
extern fclose
extern getchar
extern gets

; ncurses lib functions
extern initscr
extern cbreak
extern clear
extern endwin
extern printw
extern mvprintw
extern getch
extern curs_set
extern noecho
extern timeout
extern notimeout

global _start

section .text
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_start:
	
	;follow cdecl -- we will be using command line arguments
	push ebp
	mov ebp, esp

	; [EBP+4] is the arg count
	; [EBP+8,12,16,...] are pointers to strings
	; [EBP+8] is the command itself (usually the program name)
	; [EBP+12] is first argument...  

	; the args will be used by _LoadLevel -- getting the filename of the level data to load
	; loadlevel is purely internal to this program and does not need cdecl
	call _LoadLevel 

	; initialize ncurses stuff...
	
	call initscr  ; ncurses: initscr -- initialize the screen, ready for ncurses stuff...
	call cbreak   ; ncurses: cbreak -- disables line buffering so we can get immediate key input
	call clear    ; ncurses: clear -- clear the screen
	push 0
	call curs_set ; ncurses: curs_set(0) makes cursor invisible
	add esp, 4
	call noecho   ; ncurses: noecho -- don't echo type characters to screen
	push 250
	call timeout  ; ncurses: timeout(milliseconds) set how long getch() will wait for a keypress (determines game speed)
	add esp, 4

	; game loop

.gameLoop:
		; update lvlBuffer based on player movement & game "AI"

		call _GameTick
		push eax				; save the return value

		; display level

		call clear				; ncurses: clear --  clears screen and puts print position in the top left corner

		push dword lvlBuffer	; lvlBuffer should just contain one large multiline string...
		call printw				; ncurses: printw -- works just like printf, except printing starts from current print position on the ncurses screen
								; here we are just using it to print entire lvlBuffer

		push dword [foodCnt]
		push dword [gameScore]
		push gameStatusFmt
		call printw				; show game status bar
		add esp, 16				; cdecl stack cleanup for two printw calls at once
		
		; show centered status messages (win/loss, pause)
		
		; if speeds are nonzero then game can be paused
		cmp dword [xStep], 0
		jnz .gameCanBePaused
		cmp dword [yStep], 0
		jnz .gameCanBePaused
		; game either ended or didn't start
		
		cmp dword [gameEnded], 0
		jz .endifPaused
			; game is ended
			
			mov ecx, winMsg
			cmp dword [foodCnt], 0
			jz .printWinMsg
				mov ecx, loseMsg
.printWinMsg:
			call _PrintCentered
			jmp .endifPaused
		
.gameCanBePaused:
		cmp dword [gamePaused], 0
		jz .endifPaused
			mov ecx, pausedMsg
			call _PrintCentered
.endifPaused:
		
		pop eax			; restore the _GameTick return value
		test eax, eax
	jnz .gameLoop		; loop while nonzero

	; wrapup ncurses stuff...
	
	call getch		; dunno why but this fixes not printing of the last "frame"
	call endwin		; cleanup/deallocate ncurses stuff (actually required, otherwise it messes up the terminal)

_exit:

	;sys_exit
	mov eax, 1	; sys_exit
	xor ebx, ebx
	int 80h

	; wrapup cdecl - not really necessary in this case because sys_exit terminates the program anyway
	leave	; "leave" is the same as "mov esp, ebp; pop ebp" btw
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  void __fastcall (because why not) _PrintCentered(char* text)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_PrintCentered:
	push ecx	; text
	mov ecx, dword [lvlWidth]
	shr ecx, 1
	sub ecx, 4
	push ecx	; column is lvlWidth/2 - 4. Our messages are conveniently 8 symbols long.
	mov ecx, dword [lvlHeight]
	shr ecx, 1
	push ecx	; row is lvlHeight/2
	call mvprintw
	add esp, 12
	
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  _GameTick
;;      handle a single tick fo the game clock
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

_GameTick:

	call getch	; the ncurses getch (allows us to not wait indefinitely -- google ncurses nodelay timeout
				; the single return character should be in AL

	cmp al, ' '
	je .keyPause
	cmp al, 'q'
	je .tickQuit

	; don't process movement keys if the game's ended
	cmp dword [gameEnded], 0
	jnz .tickEnd

	; don't process movement keys if the game's paused
	cmp dword [gamePaused], 0
	jnz .tickEnd

	; check for wasd and update player step in horizontal&vertical directions
	cmp al, 'w'
	je .keyUp
	cmp al, 'a'
	je .keyLeft
	cmp al, 's'
	je .keyDown
	cmp al, 'd'
	je .keyRight
	jmp .continue

.keyPause:
	; at the start of the game the X- and Y-speeds are zero so there's no point in pausing
	cmp dword [xStep], 0
	jnz .gameCanBePaused
	cmp dword [yStep], 0
	jnz .gameCanBePaused
	jmp .tickEnd

.gameCanBePaused:
	; 00000000 becomes ffffffff and vice versa
	not dword [gamePaused]

	; is it paused?
	cmp dword [gamePaused], 0
	jnz .tickEnd
	; it's not
	jmp .continue

	; [xStep] and [yStep] act as a sort of "velocity" or "step size per tick", can be either 1, 0 or -1
.keyUp:
	mov dword [xStep], 0
	mov dword [yStep], -1
	jmp .continue

.keyLeft:
	mov dword [xStep], -1
	mov dword [yStep], 0
	jmp .continue

.keyDown:
	mov dword [xStep], 0
	mov dword [yStep], 1
	jmp .continue

.keyRight:
	mov dword [xStep], 1
	mov dword [yStep], 0
	jmp .continue

.continue:

	; at the start of the game the X- and Y-speeds are zero so don't move
	cmp dword [xStep], 0
	jnz .move
	cmp dword [yStep], 0
	jz .tickEnd

.move:

	; fetch head & tail INDEXES into ESI & EDI
	mov esi, [headIndex]
	mov edi, [tailIndex] 
	; fetch head & tail ADDRESSES into EAX & EBX
	mov eax, [bodySegmentAddresses + 4*esi]
	mov ebx, [bodySegmentAddresses + 4*edi]

	; replace current head with a body segment
	mov byte [eax], 'o'
	; replace current tail with a space
	mov byte [ebx], ' '

	; increment headIndex (wrap if >= maxLvlBufferSize)
	add esi, 1
	cmp esi, maxSegmentIndex
	jl .skipWrapHeadIndex
		sub esi, maxSegmentIndex
.skipWrapHeadIndex:
	mov [headIndex], esi	; store the new head index back into memory

	; now do the same for the tail index
	add edi, 1
	cmp edi, maxSegmentIndex
	jl .skipWrapTailIndex
		sub edi, maxSegmentIndex
.skipWrapTailIndex:    
	mov [tailIndex], edi

	; get new location of head and put '@' there
	add eax, [xStep]	; add -1,1 or 0 to current address of head
	mov ecx, [yDelta]	; [yDelta] -- the number of bytes to wrap around to same position on next or previous line: lvlWidth+1 
	imul ecx, [yStep]	; multiply [ydelta] by -1,1, or 0, depending on whether we are moving up/down/neither
	add eax, ecx		; add it to the head position address

	cmp byte [eax], ' '
	je .cellAir
		; solid block or food
		cmp byte [eax], '*'
		jne .endGame
			; eat food, score++
			inc dword [gameScore]
			dec dword [foodCnt]
			
			; grow tail
			mov byte [ebx], 'o'
			dec dword [tailIndex]
			
			jmp .cellAir
.endGame:
		; ate all the food or died
		mov dword [gameEnded], 1
		mov dword [xStep], 0
		mov dword [yStep], 0
		jmp .tickEnd
.cellAir:

	mov byte [eax], '@'						; put the head in the new location
	mov [bodySegmentAddresses + 4*esi], eax	; save the new head address in bodySementAddressees[headIndex]

	; check if there's any food left
	cmp dword [foodCnt], 0
	jz .endGame
	
.tickEnd:
	mov eax, 1		; return 1	-- game loop continues
	ret

.tickQuit:
	xor eax, eax	; return 0 -- quit game
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  _LoadLevel
;;      Reads the level file, with some rudimentary verification of format
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

_LoadLevel:

	; check that we have exactly one arg (in addtion to command)
	mov edx, [ebp + 4]
	cmp edx, 2
	jne .usage

	; ok, try to open the file...
	push readModeStr
	push dword [ebp + 12]
	call fopen
	add esp, 8
	; file pointers should be in EAX now (or null on failure
	cmp eax, 0
	jle .openFileFail
	
	; OK we have the file, save the filepointer & read the file...
	mov [lvlFilePtr], eax

	; first line should tell us the width&height
	push lvlHeight				; address to store the height of the level
	push lvlWidth				; address to store the width of the level
	push twoIntFmt				; format string for reading a two integers
	push dword [lvlFilePtr]		; file pointer for the opened level file
	call fscanf
	add esp, 16					; remove scanf parameters from stack   

	;;vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
	; make sure ((width+1) * height) +1 is less than size of lvlBuffer 
	; "+1" for newline at end of each line
	; "-1" for null terminator at end of entire level
	; jump to _LevelExceedsMaximumSize
	;;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

	; calculat & store yDelta (number of character steps to arrive at exact same position in previous or next line
	mov eax, [lvlWidth]
	inc eax
	mov [yDelta], eax

	; use fgets to read (and ignore) remainder of the last line we read in...
	push dword [lvlFilePtr]
	push lvlBufSize
	push lvlBuffer				; whatever is still on the line we put here, but it will be overwritten below
	call fgets
	add esp,12

	; next lvlHeight lines should be the level itself

	; initialize for LoadLevelLoop... (we'll be using registers that are "safe" in cdecl function calls
	mov edi, lvlBuffer			; edx will point successively to beginning of each line
	mov esi, [lvlWidth]			; add 2 to this for newline & null for limit on what fgets will read 
	add esi, 2
	mov ebx, [lvlHeight]		; use ebx to count down lines read

.LoadLevelLoop:
		;fgets
		push dword [lvlFilePtr]	; file pointer 
		push esi				; max size of string to read in (included the added null terminator)
		push edi				; pointer to where we want that string to go (within lvlBuffer)
		call fgets				; read line from lvl file
		add esp, 12
		cmp eax, edi			; check for failure to successfully read -- return value should just be pointer to where the string was stored
		jne .badFileFormat

		;;vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
		; verify that line is the correct length, do not overflow the lvlBuffer
		; if wrong length, jump to _badFileFormat
		;;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

		dec ebx
		jz .LoadInitialBody 
		add edi, esi			; adjust edx to where next line will start in lvlBuffer
		sub edi, 1				; back off 1 because we want to overwrite the null terminators (except the last line)

	jmp .LoadLevelLoop

.LoadInitialBody:

	; but count food bits first
	mov edi, lvlBuffer
	.foodCountLoop:
		cmp byte [edi], '*'
		jnz .notFood
			inc dword [foodCnt]
		.notFood:
		
		inc edi
		cmp byte [edi], 0
	jnz .foodCountLoop

	; next line should tell us how many initial body segments
	push bodyLength
	push oneIntFmt
	push dword [lvlFilePtr]
	call fscanf
	add  esp, 12

	; next bodyLength lines should contain the X,Y coords of the body segments, starting with the head
	mov edi, [bodyLength]		; edi will be the index into bodySegmentAddresses array
	dec edi						; decrement by 1 because zero based -- this is index of the head
	mov [headIndex], edi
	mov dword [tailIndex], 0	; the index of the tailAddress will initially be 0

.LoadBodySegmentsLoop:        
		; next line should have the millipede head starting position
		push segmentY			; remember cdecl reverse order onto the stack -- in lvl file, it is X then Y
		push segmentX
		push twoIntFmt
		push dword [lvlFilePtr]
		call fscanf
		add esp, 16

		; increment snake's length, that'll be the initial game score
		inc dword [gameScore]

		; calculate the body segment's address within lvlBuffer
		; the store it in appropriate element within bodySegmentAddresses
		mov eax, lvlBuffer
		mov ecx, [segmentY]
		imul ecx, [yDelta]
		add eax, ecx			; eax now hold the address of this body segment within lvlBuffer
		add eax, [segmentX]
		mov esi, bodySegmentAddresses
		mov [esi + 4*edi], eax	; storing the address for this body segment in bodySegmentAddresses

		dec edi
		cmp edi, 0
		jl .DrawInitialBody		; jump if less than 0 -- we want another go around for 0 index
	jmp .LoadBodySegmentsLoop

.DrawInitialBody:
	mov edi, [headIndex]
	mov esi, bodySegmentAddresses
	mov edx, [esi + 4*edi]		; get the head address from bodySegmentAddresses
	mov byte [edx], '@'			; put the head '@' at that location within lvlBuffer

.DrawBodyLoop:
		dec edi
		cmp edi, 0
		jl .LoadLevelWrapup		; break out of loop after last segment
		mov edx, [esi + 4*edi]	; get the segment address from bodySegmentAddresses
		mov byte [edx], 'o'		; put the segment 'o' at that location within lvlBuffer
	jmp .DrawBodyLoop			; repeat for next segment

.LoadLevelWrapup:
	ret							; internal non-cdecl routine, so nothing else to do but return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.usage:
	push usageMsg
	call printf
	jmp _exit
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.openFileFail:
	push openFileFailMsg
	call printf
	jmp _exit
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.badFileFormat:
	push badFileFormatMsg
	call printf
	jmp _exit
