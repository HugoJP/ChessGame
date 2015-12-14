;*****************************************************************************
;*****************************************************************************
;********************   Save game interrupt    *******************************
;*****************************************************************************
;*****************************************************************************
; Author: Richard Flint
; Date: 27/02/2015
;************************************************************************************************
; When the user wants to stop the game, they must press ESC on the port 6 pin.
; This triggers the 0 external interrupt.
; This routine asks whether the player is sure they want to leave. If they
; do leave, then their game is saved.
;
; The program does not run in isolation. It is included in the main_program.asm,
; and is called as a routine (call move_verification_algorithm).
;*****************************************************************************
EXT_INT0:
	in r4,SREG						; It is advised to store and return SREG, so I do it
	;
	push r20
	push r16
	;
	rcall CLRDIS					; Clear LCD screen
	rcall Mess8out					; "Are you sure you want to exit? (Y/N)",0
	;
	interrupt_loop:					; Loop waits for confirmation on whether the user wants to exit
		in r16,pind
		com r16
		cpi r16,$08			
		breq save_game				; If user presses [Y], branch to save_game routine
		cpi r16,$10			
		brne interrupt_loop			; Loop until user presses [N]
		;							; If they do press [N], we need to return back to the game
		pop r16
		pop r20
		;
		out SREG,r4
		;
		sei							; return global interrupt to 1 (instead of using reti)
		rjmp return_game			; jump back to game
;
;*****************************************************************************
;********************   Save game function  **********************************
;*****************************************************************************
;
save_game:
rcall CLRDIS
rcall MessGameSavedOut		;"Exit completed!"
call BigBigDEL
call BigBigDEL
jmp Init

return_game:
push r16
push XL
push XH
ldi XH,$01
ldi XL,$10
ld r16,X
cpi r16,$00
breq return_initialisation
pop XH
pop XL
pop r16
jmp user_input_position

return_initialisation:
pop XH
pop XL
pop r16
jmp play_demo
