;************************************************************************************************
;************************* KING CHECK ***********************************************************
;************************************************************************************************
; Author: Richard Flint
; Date: 27/02/2015
;************************************************************************************************
; This code checks whether both kings are still left on the board (it is easier to check
; this rather than idenfitying check and check-mate).
;************************************************************************************************
king_check:
push XL
push XH
push r16
;
ldi XH,$01						;start in the bottom left corner
ldi XL,$11
;
white_king_check_loop:			;first loop looks for a white king
ld r16,X+						;load the piece information of a square, then post-increment
cpi r16,$86						;is the piece the white king?
breq black_king_check			;if yes, then move on to finding the black king
cpi XL,$89						;if no, then repeat this for the whole board
brne white_king_check_loop		;if we get to $0189 and there is no white king, it means it has been taken
call initialise_LCD_DOGXL		;clear the chess board as blacks have won
call MessBlackWinOut			;The white king has been taken, so blacks win!
call BigBigDEL					;Leave the message on the screen for a few seconds
call BigBigDEL
call BigBigDEL
pop r16
rjmp start_new_game				;Jump to ask whether they want to start a new game
;
black_king_check:				;White king was found. Now search for black king
ldi XH,$01						;Go back to A1 square
ldi XL,$11
black_king_check_loop:			;Loop across all squares on the chess board again
ld r16,X+						;This is done by post-incrementing the location
cpi r16,$C6						;Check if a black king is on the square
breq both_kings_alive			;If the black king is found, both kings are alive!
cpi XL,$89						;Continue checking across the whole board
brne black_king_check_loop
call initialise_LCD_DOGXL		;clear the chess board as whites have won
call MessWhiteWinOut			;If the whole board is check, and no black king, whites win!!!
call BigBigDEL					;Keep message on the screen for a few seconds
call BigBigDEL
call BigBigDEL
pop r16
rjmp start_new_game				;Jump to ask whether they want to start a new game		
;
both_kings_alive:				;Both kings are alive, so return to main program to resume game
pop r16
pop XH
pop XL
ret
;
start_new_game:					;A king was taken, so we need to start a new game
call CLRDIS
call MessStartNewGameOut		; "Do you want to start a new game? (Y/N)"
push r16
start_new_game_loop:			;Loop until the user inputs [Y] or [N]
in r16,pind
com r16
cpi r16,$08						;If they press [Y]=$08 on PIND
breq start_new_game_yes			;branch to new game routine
cpi r16,$10						;If they press no,jump to 'no new game' routine
brne start_new_game_loop
pop r16
rjmp start_new_game_no
;
start_new_game_yes:				;New game just jumps to initialisation of main program
jmp Init
;
start_new_game_no:				;No new game outputs message then waits in infinite loop
call MessTurnOffOut				;"Turn game off."
TurnOffLoop:					;Infinite loop!
rjmp TurnOffLoop
;
;***********************************************************************************************
