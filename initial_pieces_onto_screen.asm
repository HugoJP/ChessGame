;*********************************************************************************************
;*********************************************************************************************
;***************************** Initial pieces onto screen ************************************
;*********************************************************************************************
;*********************************************************************************************
; Author: Richard Flint
; Date: 27/02/2015
;**********************************************************************************************
; Once the game has been initialised (chess_board_initialisation.asm), this routine loads the
; pieces onto the screen. The pieces can either be for a new game, or a loaded game.
;**********************************************************************************************
initial_pieces_onto_screen:
push XL
push XH
push r16
push r17
push r18
push r25

ldi XH,$01					;load location of A1
ldi XL,$11					;
ldi r16,$08					;load a loop counter (required because we only go up to 8 on hex unit)

initial_pieces_loop:		;
mov r17,XL					;r17 is the piece position in output_DOGXL routine
ld r18,X+					;r18 is the piece type, and this is stored at address X in SRAM
;
push r16					;need to push all registers again before calling output_DOGXL routine
push XL						;as the output_DOGXL routine changes their value
push XH
call output_DOGXL			;load piece onto screen
pop XH
pop XL
pop r16
;
cpi r16,$01					;check counter
breq counter_reset			;if we have looped 8 times, branch to counter_reset
subi r16,$01				;if not, subtract 1 from the counter
rjmp initial_pieces_loop	;and go again!

counter_reset:				;routine resets the counter to 8
ldi r16,$08
adiw X,$08					;it also changes the square on the board to the bottom of the next column
cpi XL,$91					;there are only 8 columns, so if we have $91, it means we have filled all squares
breq initial_pieces_exit
rjmp initial_pieces_loop

initial_pieces_exit:
pop r25
pop r18
pop r17
pop r16
pop XH
pop XL
ret

;**************************************************************************************************
