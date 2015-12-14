;*****************************************************************************
;********************* VALID OR INVALID CHECK ********************************
;*****************************************************************************
; Author: Richard Flint
; Date: 27/02/2015
;*****************************************************************************
;This code applies a simple branch based on whether the Move Verification
;Algorithm determined the move to be valid or invalid.
;
;The program does not run in isolation. It is included in the main_program.asm,
;and is called as a routine (call valid_or_invalid)
;********************* Input registers for reference *************************
; r22 = valid move? 			$00 = not valid		$01 = valid
; r22 is the overall output from the Move Verification Algorithm
;*****************************************************************************
;
valid_or_invalid:			;call the routine
cpi r22,$00					;compare the output (r22) of the Move Verification Algorithm
breq invalid_move			;if r22=$00, it means the move is not valid
cpi r22,$01
breq valid_move				;if r22=$01, it means the move is valid
rjmp invalid_move			;if neither of these, then there has been some error...
;
invalid_move:				;invalide move routine
call CLRDIS
call MessInvalidMoveOut		;"Move not valid.Press enter to try again"
push r20
invalid_loop:				;Loop until enter is pressed
in r20,pind
com r20
cpi r20,$02
brne invalid_loop
pop r20
call CLRDIS
ret							;Once enter is pressed, return to main program without
;							;any move being made. Player can try again.
;
valid_move:					;valid move routine
call CLRDIS
call MessValidMoveOut		;"Move is valid. Press enter to continue"
push r20
valid_loop:					;Loop until enter is pressed
in r20,pind
com r20
cpi r20,$02
brne valid_loop
pop r20
call CLRDIS
rcall save_valid_move		;Once enter is pressed, call routine to save move into the SRAM
ret							;Return back to main program
;
save_valid_move:			;routine to save move into the SRAM
push XL
push XH
push r20
;
ldi XH,$01					;store destination in X
mov XL,r17
st X,r18					;move piece information into destination square
;
mov XL,r16					;ensure that the start square is cleared
ldi r20,$00					;this means that there is no piece in the start square
st X,r20					;store this in the SRAM
;
pop r20
pop XH
pop XL
ret
;*****************************************************************************


