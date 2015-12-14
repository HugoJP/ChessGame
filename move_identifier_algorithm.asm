; ***************************************************************************
; ***************************************************************************
; ************************** MOVE IDENTIFIER ALGORITHM **********************
; ***************************************************************************
; ***************************************************************************
; Author: Richard Flint
; Date: 27/02/2015
;
; This code takes the input position (r16) and final position (r17), and
; identifies the type of move. The output of this code is then used in the
; Move Verification Algorithm.
;
; Routine will output the following:
; 
; r19 = $01 	forward vertical move
; r19 = $02		backwards vertical move
; r19 = $03		right horizontal move
; r19 = $04 	left horizontal move
; r19 = $05 	forward right diagonal move
; r19 = $06 	backwards left diagonal move
; r19 = $07 	forwards left diagonal move
; r19 = $08 	backwards right diagonal move

; This code is written such that it can be included in the main program. It will 
; not compile in isolation.
;
; Routine can be called in the following way:
;			* call move_identifier_algorithm will run the whole program
;
;********************* Registers for reference *******************************
; r16 = initial position		(INPUT)
; r17 = final position			(INPUT)
; r18 = piece information		(INPUT)
; r19 = move type    			(OUTPUT)
;*****************************************************************************
;
;
move_identifier_algorithm:
push r18						;use r18 as a comparison to see if move has been identified yet
ldi r18,$00
;
rcall horizontal_move_check		;routine for checking whether input is horizontal move
cpse r19,r18					;if it isn't horizontal, skip to the next check
rjmp move_type_output			;if it is horizontal, jump to exit routine
rcall vertical_move_check		;routine for checking whether input is vertical move
cpse r19,r18					;if it isn't vertical, skip to next check
rjmp move_type_output			;if it is vertical, jump to exit routine
rcall diagonal_move_check		;routine for checking whether input is a diagonal move
cpse r19,r18					
rjmp move_type_output			;if isn't diagonal, no other options (knight not considered here), so jump to exit routine
;
move_type_output:		
pop r18
ret
;
;
; ************************ Horizontal Move Check *****************************
; Checks whether the move is a horizontal move
;
horizontal_move_check:
push r16
push r17
push XL
push XH
;
mov XL,r16							; store start and end positions
mov XH,r17
;
lsl XL								; shift left to isolate lowest hex unit of start position
lsl XL
lsl XL
lsl XL
;
lsl XH								; shift left to isolate lowest hex unit of end position
lsl XH
lsl XH
lsl XH
;
cp XL,XH							;compare lowest hex numbers
breq horizontal_direction_check		;lowest hex unit are equal if move is horizontal.
;
ldi r19,$00							; if not equal, move is not horizontal. Identify this via r19=$00
rjmp horizontal_pop					; jump to horizonal pop to pop back all registers that were pushed
;
	horizontal_direction_check:		;if it is a horizontal move, we need to identify which direction
	cp r17,r16						;checks if horizontal move is left or right
	brlo horizontal_left			;if end position is less than start position, move is left
	;								;if end position is greater than start position, move right
	ldi r19,$03						; move is horizontal right
	rjmp horizontal_pop
;
		horizontal_left:
		ldi r19,$04					;move is horizontal left
		rjmp horizontal_pop
;
;
horizontal_pop:						;pops back all variables pushed at the beginning of routine
pop XH
pop XL
pop r17
pop r16
ret
;
;
; ************************ Vertical Move Check *****************************
; Checks whether the move is vertical
;
vertical_move_check:
push r16
push r17
push XL
push XH
;
mov XL,r16							;move start position into XL so not lost
mov XH,r17							;move end posiition into XH so not lost
;
lsr XL								;isolate 2nd unit in HEX number for start position
lsr XL
lsr XL
lsr XL
;
lsr XH								;isolate 2nd unit in HEX number for end position
lsr XH
lsr XH
lsr XH
;
cp XH,XL							;if move is vertical, then 2nd unit in HEX should be equal
breq vertical_direction_check		;if it is equal, branch to routine that identifies direction
;
ldi r19,$00							;if it is not equal, move is not vertical
rjmp vertical_pop					;jump to pop everything back before exiting
;
	vertical_direction_check:		;if the move is identified as vertical, we still need to determine direction
	cp r17,r16						;if end position is greater than start position, vertical forwards move
	brlo vertical_backwards			;if end position is less that start position, vertical backwards move
	;
	ldi r19,$01						; move is vertical forwards
	rjmp vertical_pop
	;
		vertical_backwards:
		ldi r19,$02					; move is vertical backwards
		rjmp vertical_pop
;
vertical_pop:
pop XH
pop XL
pop r17
pop r16
ret
;
; **************************************************************************
; ************************ Diagonal Move Check *****************************
; **************************************************************************
; Checks if the move is diagonal, and identifies which direction
diagonal_move_check:
push r16
push r17
push r20
push r21
push r22
push r23
push r24
push r25
push XL
push XH
push YL
push YH
;
mov XL,r16					;save start position into XL so not lost
mov XH,r16					;save start position into XL so not lost
mov YL,r17					;save end position into XL so not lost
mov YH,r17					;save end position into XL so not lost
;
lsl XL						;isolate lowest hex unit of start position
lsl XL
lsl XL
lsl XL
lsr XL
lsr XL
lsr XL
lsr XL
;
lsl YL						;isolate lowest hex unit of end position
lsl YL
lsl YL
lsl YL
lsr YL
lsr YL
lsr YL
lsr YL
;
lsr XH						; isolate second lowest hex unit of start position
lsr XH
lsr XH
lsr XH
;
lsr YH						; isolate second lowest hex unit of end position
lsr YH
lsr YH
lsr YH
;
; r16 = start position
; r17 = end position
; r16 = XH + XL = upper hex value + lower hex value
; r17 = YH + YL = upper hex value + lower hex value
;
; ************** Is it a forward diagonal right or backwards diagonal left? *****************************
;
diagonal_check_part_1:
;
mov r20,XL						; we need to maintain X and Y values, so transfer to new registers
mov r21,XH
mov r22,YL
mov r23,YH
;
cp r21,r20						; compare HEX units for start position
brlo inverse_subtract			; identify which is biggest
sub r21,r20						; if second hex unit is biggest, subtract first from second
ldi r24,$01						; if second hex unit is greater than first hex unit, set to $01 as marker
rjmp diagonal_check_part_2
;
	inverse_subtract:
	sub r20,r21					; if first hex unit is largest, subtract second unit from first hex unit
	mov r21,r20					; copy into r21 (simplifies code when doing the comparison)
	ldi r24,$00					; Set r24=$00 as marker
	rjmp diagonal_check_part_2
;
diagonal_check_part_2:
cp r23,r22						; repeat same proceedure as diagonal_check_part_1 with HEX units from end position
brlo inverse_subtract_2	
sub r23,r22
ldi r25,$01						; if upper hex is greater than lower hex, set to $01
rjmp diagonal_compare
;
	inverse_subtract_2:
	sub r22,r23
	mov r23,r22
	ldi r25,$00					;if lower hex is greater than upper hex, set to $00 
	rjmp diagonal_compare
;
diagonal_compare:					; r21 = difference between hex units for start position
									; r23 = difference between hex units for end position
cp r21,r23 							; is their difference the same?
brne diagonal_check_part_3			; if no, then the move is not this sort of diagonal. Skip on!
cp r24,r25							; if yes, then was the subtraction direction the same?
brne diagonal_check_part_3			; if no, then the move is not this sort of diagonal. Skip on!
;
cp r17,r16							; if yes, we just need to determine the direction
brlo diagonal_backwards_left_move
ldi r19,$05							; If end position > start position, it is a forward right diagonal move
rjmp diagonal_pop
;
	diagonal_backwards_left_move:	; If end position < start position, it is a backwards left diagonal move
	ldi r19,$06
	rjmp diagonal_pop
;
; ************** Is it a forward diagonal left or backwards diagonal right? *****************************
;
diagonal_check_part_3:
;
mov r20,XL						; restore registers
mov r21,XH
mov r22,YL
mov r23,YH
;
cp r22,r20						; compare first HEX unit between start and end position
brlo inverse_subtract_3			; establish which one is greater
sub r22,r20						; subtract smaller HEX unit from larger HEX unit
ldi r24,$01						; set marker
rjmp diagonal_check_part_4
;
	inverse_subtract_3:
	sub r20,r22					; subtract smaller HEX unit from larger HEX unit
	mov r22,r20					; transfer to r22 as it makes the comparison easier in a bit
	ldi r24,$00					; set marker
	rjmp diagonal_check_part_4
;
diagonal_check_part_4:			; do the same again with the 2nd HEX unit for the start and end position
cp r23,r21						; establish which one is greater
brlo inverse_subtract_4
sub r23,r21						; find the difference
ldi r25,$01						; set as marker
rjmp diagonal_compare_2
;
	inverse_subtract_4:
	sub r21,r23					; find the difference
	mov r23,r21					; save in r23
	ldi r25,$00					; set as marker
	rjmp diagonal_compare_2
;
diagonal_compare_2:				; compare whether the order of subtraction was different
cp r24,r25						
breq not_diagonal_move			; if no, then not a diagonal move
cp r23,r22						; if yes, compare magnitude of differences calculated
brne not_diagonal_move			; if not equal, then not a diagonal move
;
cp r17,r16						; compare start/end position to determine direction of movement
brlo diagonal_forward_left_move	; if end position is less than start position, branch to forward diagonal left
ldi r19,$08						; if not, then it is a backwards diagonal right
rjmp diagonal_pop
;
	diagonal_forward_left_move:
	ldi r19,$07					;save as forward diagonal left move
	rjmp diagonal_pop
;
not_diagonal_move:
ldi r19,$00
rjmp diagonal_pop
;
diagonal_pop:
pop YH
pop YL
pop XH
pop XL
pop r25
pop r24
pop r23
pop r22
pop r21
pop r20
pop r17
pop r16
ret
;
;***********************************************************************************************
