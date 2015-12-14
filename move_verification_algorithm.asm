;************************************************************************************************
;************************************************************************************************
;************************* Move Verification Algorithm ******************************************
;************************************************************************************************
;************************************************************************************************
; Author: Richard Flint
; Date: 27/02/2015
;************************************************************************************************
; This program checks whether the pieces present at the chosen start point can make a valid move
; to the destination point chosen.
;
;The program does not run in isolation. It is included in the main_program.asm,
;and is called as a routine (call move_verification_algorithm)
;********************* Input registers for reference *************************
; r16 = initial position
; r17 = final position
; r18 = piece information
; r19 = move type    				$00 = no move
; r20 = intermediate step
; r21 = intermediate piece
; r22 = valid move? 				$00 = not valid		$01 = valid
; r23 = is the space occupied?		$00 = unoccuped		$01 = white occupied 		$10 = black occupied
; r24 = colour of chosen piece (piece we are moving)  	$01 = white  				$10 = black
; r25 = colour that the piece should be (i.e. white or black turn?) $01 = white		$10 = black
;*****************************************************************************
;
;****************** r18 piece information for reference **********************
; r18 = 0xxx xxxx 	unoccupied
; r18 = 1xxx xxxx	occupied
; r18 = x0xx xxxx	white
; r18 = x1xx xxxx	black
; r18 = xxxx 0001	pawn
; r18 = xxxx 0010	
; r18 = xxxx 0011	
; r18 = xxxx 0100	
; r18 = xxxx 0101	queen
; r18 = xxxx 0110	king
;*****************************************************************************
;
;
;*****************************************************************************
;*********************** Identify which piece is moving **********************
;*****************************************************************************
move_verification_algorithm:
;
	mov r20,r16	;set intermediate move register as r20
	;
	;Identify which type of piece is being moved:
	cpi r18,$81			
	breq white_pawn_jump
	cpi r18,$C1
	breq black_pawn_jump
	cpi r18,$82
	breq knight_jump
	cpi r18,$C2
	breq knight_jump
	cpi r18,$83
	breq bishop_jump
	cpi r18,$C3
	breq bishop_jump
	cpi r18,$84
	breq castle_jump
	cpi r18,$C4
	breq castle_jump
	cpi r18,$85
	breq queen_jump
	cpi r18,$C5
	breq queen_jump
	cpi r18,$86
	breq king_jump
	cpi r18,$C6
	breq king_jump
	;
	ldi r22,$00			;if it is none of these, then the move is not valid
	ret					;this is marked by setting r22=$00
;
	white_pawn_jump:	;relative branch is out of range, so jumps must be used*
	jmp white_pawn
	black_pawn_jump:
	jmp black_pawn
	knight_jump:
	jmp knight
	bishop_jump:
	jmp bishop
	castle_jump:
	jmp castle
	queen_jump:
	jmp queen
	king_jump:
	jmp king
;
;*Note: because the program is quite long, the breq command (and other relative commands) sometimes
;are insufficient by themselves because the routine is too far away. If this is the case,
;then the relative command redirects to a jmp statement, which then takes program to the
;correct routine
;
;********************************************************************************
;************** MOVE VERIFICATION ALGORITH FOR EACH PIECE ***********************
;********************************************************************************
;
;
;*****************************************************************************
;*************************      Knight     ***********************************
;*****************************************************************************
;
knight:					;move verification for a knight
push r20
;
cp r17,r16						;compare start and end positions
brlo knight_left				;if end is smaller than start, knight is moving right overall
;knight moving right			;if end is greater than start, knight is moving left overall
mov r20,r17						;temporarily set r20 as destination square to preserve r17
sub r20,r16						;find the difference between destination and start square
cpi r20,$12	;forward right 1	;the difference can only have a few set values for the knight move
breq knight_moving				;if it is one of these, then branch to move the knight
cpi r20,$21	;forward right 2			;
breq knight_moving
cpi r20,$1F	;back right 1
breq knight_moving
cpi r20,$E	;back right 2
breq knight_moving
;
ldi r22,$00						;if none of these are correct, then move is not valid
pop r20
ret								;this is marked by setting r22=$00
;
;knight moving left
knight_left:					;knight can only move left into a few different squares. Check each of these.
mov r20,r16						;temporarily set r20 as destination square to preserve r17
sub r20,r17						;the difference can only have a few set values for the knight move
cpi r20,$E	;forward left 1		;if it is one of these, then branch to move the knight
breq knight_moving
cpi r20,$1F	;forward left 2
breq knight_moving
cpi r20,$21	;back left 1
breq knight_moving
cpi r20,$12	;back left 2
breq knight_moving
;
ldi r22,$00						;if none of these are correct, then move is not valid
pop r20
ret								;this is marked by setting r22=$00
;
knight_moving:			;if destination is valid, still need to check that it is not occupied by same colour piece
pop r20
mov r20,r17				;set r20 (intermediate step) to be the destination
call is_the_square_occupied		;check if there is a piece in the destination square
cp r23,r24				;r23 gives colour of piece in destination square. r24 gives colour of piece moving
brne knight_move_valid	;destination square must either be free of have different colour piece
jmp moving_error		;if it doesn't then the move is not valid
knight_move_valid:
ldi r22,$01				;if it does, then the move is valid. This is saved by setting r22=$01
ret
;
;
;
;
;*****************************************************************************
;*************************      King     *************************************
;*****************************************************************************
;
king:								;move verification for a king
call move_identifier_algorithm		;identify type of move
cpi r19,$01							;branch/jump to relevant king check
breq king_forward
cpi r19,$02
breq king_backwards
cpi r19,$03
breq king_right
cpi r19,$04
breq king_left
cpi r19,$05
breq king_forward_diagonal_right_jump
cpi r19,$06
breq king_backwards_diagonal_left_jump
cpi r19,$07
breq king_forward_diagonal_left_jump
cpi r19,$08
breq king_backwards_diagonal_right_jump
ldi r22,$00							;if none of these are possible, then the move is not valid!
ret
;
king_forward_diagonal_right_jump:	;jumps needed because relative branch too far
jmp king_forward_diagonal_right
king_backwards_diagonal_left_jump:
jmp king_backwards_diagonal_left
king_forward_diagonal_left_jump:
jmp king_forward_diagonal_left
king_backwards_diagonal_right_jump:
jmp king_backwards_diagonal_right
;
king_forward:						;check that destination is just 1 square from start point
push r17
sub r17,r16
cpi r17,$01
breq king_forward_yes
pop r17
jmp moving_error
king_forward_yes:
pop r17
jmp moving_forward
;
king_backwards:						;check that destination is just 1 square from start point
push r16
sub r16,r17
cpi r16,$01
breq king_backwards_yes
pop r16
jmp moving_error
king_backwards_yes:
pop r16
jmp moving_backwards
;
king_right:							;check that destination is just 1 square from start point
push r17
sub r17,r16
cpi r17,$10
breq king_right_yes
pop r17
jmp moving_error
king_right_yes:
pop r17
jmp moving_right
;
king_left:							;check that destination is just 1 square from start point
push r16
sub r16,r17
cpi r16,$10
breq king_left_yes
pop r16
jmp moving_error
king_left_yes:
pop r16
jmp moving_left
;
king_forward_diagonal_right:		;check that destination is just 1 square from start point
push r17
sub r17,r16
cpi r17,$11
breq king_forward_diagonal_right_yes
pop r17
jmp moving_error
king_forward_diagonal_right_yes:
pop r17
jmp moving_forward_diagonal_right
;
king_backwards_diagonal_left:		;check that destination is just 1 square from start point
push r16
sub r16,r17
cpi r16,$11
breq king_backwards_diagonal_left_yes
pop r16
jmp moving_error
king_backwards_diagonal_left_yes:
pop r17
jmp moving_backwards_diagonal_left
;
king_forward_diagonal_left:			;check that destination is just 1 square from start point
push r16
sub r16,r17
cpi r16,$09
breq king_forward_diagonal_left_yes
pop r16
jmp moving_error
king_forward_diagonal_left_yes:
pop r17
jmp moving_forward_diagonal_left
;
king_backwards_diagonal_right:		;check that destination is just 1 square from start point
push r17
sub r17,r16
cpi r17,$09
breq king_backwards_diagonal_right_yes
pop r17
jmp moving_error
king_backwards_diagonal_right_yes:
pop r17
jmp moving_backwards_diagonal_right
;
;*****************************************************************************
;*************************      Queen     ***********************************
;*****************************************************************************
;				;move verification for a queen
queen:			;queen is just a combination of castle and bishop
call castle		;try castle moves
cpi r22,$00		
brne queen_2	;if castle move produces valid move, then branch to exit
call bishop		;if castle move does not produce valid move, then try a bishop move
queen_2:
RET
;
;*****************************************************************************
;*************************      Castle     ***********************************
;*****************************************************************************
;						
castle:								;move verification for a castle
call move_identifier_algorithm		;identify type of move
cpi r19,$01							;branch to type of move check
breq castle_moving_forward
cpi r19,$02
breq castle_moving_backwards
cpi r19,$03
breq castle_moving_right
cpi r19,$04
breq castle_moving_left
ldi r22, $00						;if none of these are applicable, then move is not valid
RET
;
castle_moving_forward:				;need to use jmp command because relative branch too far
jmp moving_forward
castle_moving_backwards:
jmp moving_backwards
castle_moving_right:
jmp moving_right
castle_moving_left:
jmp moving_left
;
;*****************************************************************************
;*************************      Bishop     ***********************************
;*****************************************************************************
;
bishop:										;move verification for a bishop
call move_identifier_algorithm				;identify type of move
cpi r19,$05									;branch/jmp to appropriate move type
breq bishop_moving_forward_diagonal_right
cpi r19,$06
breq bishop_moving_backwards_diagonal_left
cpi r19,$07
breq bishop_moving_forward_diagonal_left
cpi r19,$08
breq bishop_moving_backwards_diagonal_right
ldi r22, $00								;if none of these are applicable, then move is not valid
RET
;
bishop_moving_forward_diagonal_right:		;need to use jmp command because relative branch too far
jmp moving_forward_diagonal_right
bishop_moving_backwards_diagonal_left:
jmp moving_backwards_diagonal_left
bishop_moving_forward_diagonal_left:
jmp moving_forward_diagonal_left
bishop_moving_backwards_diagonal_right:
jmp moving_backwards_diagonal_right
;
;
;*****************************************************************************
;*************************     PAWNS     *************************************
;*****************************************************************************
;
;*****************************************************************************
;							White pawn
;****************************************************************************
white_pawn:
call move_identifier_algorithm				;identify type of move
cpi r19,$02 								;is the pawn stepping backwards 1 square?
breq white_pawn_backwards					;if yes, branch to correct routine
cpi r19,$08									;is the pawn stepping backwards diagonal right?
breq white_pawn_diagonal_backwards_right 	;if yes, then branch to correct routine
cpi r19,$06									;is the pawn stepping backwards diagonal left?
breq white_pawn_diagonal_backwards_left 	;if yes, then branch to correct routine
ldi r22,$00									;if it is none of these, then the move is ***NOT VALID***
RET
;
;
;*********************** White pawn diagonal backwards right **********************************
;
white_pawn_diagonal_backwards_right:
push r16
ldi r16,$F
add r20,r16
pop r16							;move forward 1 square backwards diagonal right
cp r20,r17						;is this the final destination?
brne moving_error_jump_01		;if no, then the move is not valid. If yes, then carry on
call is_the_square_occupied		;call routine to check if the destination square is full
cpi r23,$10						;check if square is occupied by a black piece
brne moving_error_jump_01		;if not, then the move is not valid
ldi r22,$01						;if yes, then the move is valid
RET
;
moving_error_jump_01:			;need to jump because moving_error routine is too far for relative branch
jmp moving_error
;*********************** White pawn diagonal backwards left **********************************
;
white_pawn_diagonal_backwards_left:
subi r20,$11					;move forward 1 square backwards diagonal left
cp r20,r17						;is this the final destination?
brne moving_error_jump_02		;if no, then the move is not valid. If yes, then carry on
call is_the_square_occupied		;call routine to check if the destination square is full
cpi r23,$10						;check if square is occupied by a white piece
brne moving_error_jump_02		;if not, then the move is not valid
ldi r22,$01						;if yes, then the move is valid
RET
;
moving_error_jump_02:			;need to jump because moving_error routine is too far for relative branch
jmp moving_error
;
;*********************** White pawn backwards ***********************************************
white_pawn_backwards:
subi r20,$01						;move backwards 1
call is_the_square_occupied	
cpi r23,$00
breq white_pawn_backwards_2			;if r23 = $00 (space is free), then can carry on on
jmp moving_error					;if space is not free, then move is not valid
;
white_pawn_backwards_2:
cp r20,r17							;is it the end position?
brne white_pawn_double_backwards 	;if it is not the end position, check double pawn move
ldi r22,$01							;if it is the end position, then the move is valid
RET									;return with valid move
;

white_pawn_double_backwards:
subi r20,$01						;move pawn backwards another 1 square
cp r20,r17
brne white_pawn_error_jump			;if this is not the final location, then error
call is_the_square_occupied			;call routine to check if the destination square is full
cpi r23,$00							;check if square is free
breq white_pawn_double_backwards_2	;if square is free, then carry on
jmp moving_error					;if square is not free, then the move is not vlaid
;
white_pawn_double_backwards_2:
push r16
;
lsl r16								;isolate the lowest hex unit in the start position of the pawn
lsl r16
lsl r16
lsl r16
;
cpi r16,$70							;check if pawn's initial position was a start game position
breq white_pawn_double_backwards_3	;if valid, branch to confirm valid move
pop r16								;if r16 is not the pawns position at the start of the game, then a double move is not valid
jmp moving_error
;
white_pawn_double_backwards_3:
ldi r22,$01							;signify that a double move is by setting r22=$01
pop r16
RET										
;
white_pawn_error_jump:				;need to jump because moving_error routine is too far for relative branch
jmp moving_error
;*****************************************************************************
;									Black pawn
;****************************************************************************
black_pawn:
call move_identifier_algorithm			;identify type of move
cpi r19,$01 							;is the pawn stepping forward 1 square?
breq black_pawn_forward					;if yes, branch to correct routine
cpi r19,$05								;is the pawn stepping forward diagonal right?
breq black_pawn_diagonal_forward_right 	;if yes, then branch to correct routine
cpi r19,$07								;is the pawn stepping forward diagonal left?
breq black_pawn_diagonal_forward_left 	;if yes, then branch to correct routine
ldi r22,$00								;if it is none of these, then the move is not valid
RET
;
;
;*********************** Black pawn diagonal forward right **********************************
;
black_pawn_diagonal_forward_right:
push r16
ldi r16,$11
add r20,r16
pop r16							;move forward 1 square forward diagonal right
cp r20,r17						;is this the final destination?
brne moving_error_jump_03		;if no, then the move is not valid. If yes, then carry on
call is_the_square_occupied		;call routine to check if the destination square is full
cpi r23,$01						;check if square is occupied by a white piece
brne moving_error_jump_03		;if not, then the move is not valid
ldi r22,$01						;if yes, then the move is valid
RET
;
moving_error_jump_03:			;need to jump because moving_error routine is too far for relative branch
jmp moving_error
;
;*********************** Black pawn diagonal forward left **********************************
;
black_pawn_diagonal_forward_left:
subi r20,$F					;move forward 1 square forward diagonal right
cp r20,r17						;is this the final destination?
brne moving_error_jump_04		;if no, then the move is not valid. If yes, then carry on
call is_the_square_occupied		;call routine to check if the destination square is full
cpi r23,$01						;check if square is occupied by a white piece
brne moving_error_jump_04		;if not, then the move is not valid
ldi r22,$01						;if yes, then the move is valid
RET
;
moving_error_jump_04:			;need to jump because moving_error routine is too far for relative branch
jmp moving_error
;
;*********************** Black pawn forward ***********************************************
black_pawn_forward:
push r16
ldi r16,$01
add r20,r16
pop r16							;move forward 1
call is_the_square_occupied		;call routine to check if the destination square is full
cpi r23,$00
breq black_pawn_forward_2		;if r23 = $00 (space is free), then can carry on on
jmp moving_error				;if space is not free, then move is not valid
;
black_pawn_forward_2:
cp r20,r17						;is it the end position?
brne black_pawn_double_forward	;if it is not the end position, check double pawn move
ldi r22,$01						;signal that the move is valid by setting r22=$01
RET	
;

black_pawn_double_forward:
push r16
ldi r16,$01
add r20,r16
pop r16									;move forward another 1
cp r20,r17
brne black_pawn_error_jump				;if this is not the final destination, then error
call is_the_square_occupied				;call routine to check if the destination square is full
cpi r23,$00								;check if square is free
breq black_pawn_double_forward_2		;if square is free, branch on
jmp moving_error						;if r23 is not free, move not valid
;
black_pawn_double_forward_2:
push r16
;
lsl r16								;isolate the lowest hex unit in the start position of the pawn
lsl r16
lsl r16
lsl r16
;
cpi r16,$20							;check if pawn's initial position was a start game position
breq black_pawn_double_forward_3	;if valid, branch to confirm valid move
pop r16								;if r16 is not the pawns initial position, then a double move is not valid
jmp moving_error
;
black_pawn_double_forward_3:
ldi r22,$01							;signify that a double move is valid by setting r22=$01
pop r16
RET	
;
black_pawn_error_jump:				;need to jump because moving_error routine is too far for relative branch
jmp moving_error
;
;
;********************************************************************************
;************************* GENERAL MOVEMENT ROUTINES ****************************
;********************************************************************************
;These routines are used by the castle, bishop and queen, all of whom can move
;large distances across the board. We not only need to check that the final destination
;is valid, but also that there are no pieces in between the start and end positions.
;
;********************************************************************************
;**************************** Moving forward ************************************
;********************************************************************************
moving_forward:
push r16
ldi r16,$01					;move forwards one
add r20,r16
pop r16			
call is_the_square_occupied	;call routine to check if the square is full
cpi r23,$00
breq moving_forward_2 		;if space is free, branch with no problems
cp r20,r17					;the space is not free. is this the final position?
breq moving_forward_3		;if this is the final position, then more tests are required, so branch on
jmp moving_error  			;if this is not the final position, then the movement is not possible regardless of colour
;
moving_forward_2:			;space is free
cp r20,r17					;is it the final position?
brne moving_forward 		;if no, then repeat
ldi r22,$01					;if this is the final position, then the move is valid
ret
;
moving_forward_3:			;space is not free but is also final destination
cp r23,r24					;compare colour of pieces
breq moving_error_jump1		;if the piece you are moving is the same colour as the piece in the final square, the move is not valid
ldi r22,$01					;if the piece you are moving is a different colour in the final square, then the move is valid
RET
;
moving_error_jump1:			;need to jump because relative branch out of range
jmp moving_error
;
;
;********************************************************************************
;**************************** Moving backwards **********************************
;********************************************************************************
;
moving_backwards:
subi r20,$01				;move backwards one
call is_the_square_occupied	;call routine to check if the square is full
cpi r23,$00
breq moving_backwards_2 	;if space is free, branch with no problems
cp r20,r17					;the space is not free. is this the final position?
breq moving_backwards_3		;if this is the final position, then more tests are required, so branch on
jmp moving_error  			;if this is not the final position, then the movement is not possible regardless of colour
;
moving_backwards_2:			;space is free
cp r20,r17					;is it the final position?
brne moving_backwards 		;if no, then repeat loop
ldi r22,$01					;if this is the final position, then the move is valid
ret
;
moving_backwards_3:			;space is not free but is also final destination
cp r23,r24					;compare colour of pieces
breq moving_error_jump2 	;if the piece you are moving is the same colour as the piece in the final square, the move is not valid
ldi r22,$01					;if the piece you are moving is a different colour in the final square, then the move is valid
RET
;
moving_error_jump2:			;need to jump because relative branch out of range
jmp moving_error
;
;********************************************************************************
;**************************** Moving right **********************************
;********************************************************************************
;
moving_right:
push r16
ldi r16,$10
add r20,r16						;move right one
pop r16
call is_the_square_occupied		;call routine to check if the square is full
cpi r23,$00
breq moving_right_2 			;if space is free, branch with no problems
cp r20,r17						;the space is not free. is this the final position?
breq moving_right_3				;if this is the final position, then more tests are required, so branch on
jmp moving_error  				;if this is not the final position, then the movement is not possible regardless of colour
;
moving_right_2:					;space is free
cp r20,r17						;is it the final position?
brne moving_right 				;if no, then branch back to move right another square
ldi r22,$01						;if this is the final position, then the move is valid
ret
;
moving_right_3:					;space is not free but is also final destination
cp r23,r24						;compare colours of pieces
breq moving_error_jump3 		;if the piece you are moving is the same colour as the piece in the final square, the move is not valid
ldi r22,$01						;if the piece you are moving is a different colour in the final square, then the move is valid
RET
;
moving_error_jump3:				;need to jump because relative branch out of range
jmp moving_error
;
;********************************************************************************
;**************************** Moving left **********************************
;********************************************************************************
;
moving_left:
subi r20,$10					;move left one
call is_the_square_occupied		;call routine to check if the square is full
cpi r23,$00
breq moving_left_2 				;if space is free, branch with no problems
cp r20,r17						;the space is not free. is this the final position?
breq moving_left_3				;if this is the final position, then more tests are required, so branch on
jmp moving_error  				;if this is not the final position, then the movement is not possible regardless of colour
;
moving_left_2:					;space is free
cp r20,r17						;is it the final position?
brne moving_left 				;if no, then repeat loop
ldi r22,$01						;if this is the final position, then the move is valid
ret
;
moving_left_3:					;space is not free but is also final destination
cp r23,r24						;compare colour of pieces
breq moving_error_jump4 		;if the piece you are moving is the same colour as the piece in the final square, the move is not valid
ldi r22,$01						;if the piece you are moving is a different colour in the final square, then the move is valid
RET
;
moving_error_jump4:				;need to jump because relative branch out of range
jmp moving_error
;
;
;********************************************************************************
;************************* Moving forward diagonal right ************************
;********************************************************************************
;
moving_forward_diagonal_right:
push r16
ldi r16,$11
add r20,r16
pop r16									;move forward diagonal right 1 square
call is_the_square_occupied				;call routine to check if the square is full
cpi r23,$00
breq moving_forward_diagonal_right_2  	;if space is free, branch with no problems
cp r20,r17								;the space is not free. is this the final position?
breq moving_forward_diagonal_right_3	;if this is the final position, then more tests are required, so branch on
jmp moving_error  						;if this is not the final position, then the movement is not possible regardless of colour
;
moving_forward_diagonal_right_2:		;space is free
cp r20,r17								;is it the final position?
brne moving_forward_diagonal_right 		;if no, then repeat loop
ldi r22,$01								;if this is the final position, then the move is valid
ret
;
moving_forward_diagonal_right_3:		;space is not free but is also final destination
cp r23,r24								;compare colour of pieces
breq moving_error_jump5					;if the piece you are moving is the same colour as the piece in the final square, the move is not valid
ldi r22,$01								;if the piece you are moving is a different colour in the final square, then the move is valid
RET
;
moving_error_jump5:						;need to jump because relative branch out of range
jmp moving_error
;
;********************************************************************************
;************************* Moving backwards diagonal left ***********************
;********************************************************************************
;
moving_backwards_diagonal_left:
subi r20,$11							;move backwards diagonal left 1 square
call is_the_square_occupied				;call routine to check if the square is full
cpi r23,$00
breq moving_backwards_diagonal_left_2  	;if space is free, branch with no problems
cp r20,r17								;the space is not free. is this the final position?
breq moving_backwards_diagonal_left_3	;if this is the final position, then more tests are required, so branch on
jmp moving_error  						;if this is not the final position, then the movement is not possible regardless of colour
;
moving_backwards_diagonal_left_2:		;space is free
cp r20,r17								;is it the final position?
brne moving_backwards_diagonal_left		;if no, then repeat loop
ldi r22,$01								;if this is the final position, then the move is valid
ret
;
moving_backwards_diagonal_left_3:		;space is not free but is also final destination
cp r23,r24								;compare colour of pieces
breq moving_error_jump6					;if the piece you are moving is the same colour as the piece in the final square, the move is not valid
ldi r22,$01								;if the piece you are moving is a different colour in the final square, then the move is valid
RET
;
moving_error_jump6:						;need to jump because relative branch out of range
jmp moving_error
;
;********************************************************************************
;************************* Moving forward diagonal left ***********************
;********************************************************************************
;
moving_forward_diagonal_left:
subi r20,$F							;move forward diagonal left 1 square
call is_the_square_occupied				;call routine to check if the square is full
cpi r23,$00
breq moving_forward_diagonal_left_2  	;if space is free, branch with no problems
cp r20,r17								;the space is not free. is this the final position?
breq moving_forward_diagonal_left_3		;if this is the final position, then more tests are required, so branch on
jmp moving_error  						;if this is not the final position, then the movement is not possible regardless of colour
;
moving_forward_diagonal_left_2:			;space is free
cp r20,r17								;is it the final position?
brne moving_forward_diagonal_left		;if no, then repeat loop
ldi r22,$01								;if this is the final position, then the move is valid
ret
;
moving_forward_diagonal_left_3:			;space is not free but is also final destination
cp r23,r24								;compare colour of pieces
breq moving_error_jump7					;if the piece you are moving is the same colour as the piece in the final square, the move is not valid
ldi r22,$01								;if the piece you are moving is a different colour in the final square, then the move is valid
RET
;
moving_error_jump7:
jmp moving_error
;
;********************************************************************************
;************************* Moving backwards diagonal right **********************
;********************************************************************************
;
moving_backwards_diagonal_right:
push r16
ldi r16,$F
add r20,r16
pop r16									;move backwards diagonal right 1 square
call is_the_square_occupied				;call routine to check if the square is full
cpi r23,$00
breq moving_backwards_diagonal_right_2  ;if space is free, branch with no problems
cp r20,r17								;the space is not free. is this the final position?
breq moving_backwards_diagonal_right_3	;if this is the final position, then more tests are required, so branch on
jmp moving_error  						;if this is not the final position, then the movement is not possible regardless of colour
;
moving_backwards_diagonal_right_2:		;space is free
cp r20,r17								;is it the final position?
brne moving_backwards_diagonal_right		;if no, then repeat loop
ldi r22,$01								;if this is the final position, then the move is valid
ret
;
moving_backwards_diagonal_right_3:		;space is not free but is also final destination
cp r23,r24								;compare colour of pieces
breq moving_error_jump8					;if the piece you are moving is the same colour as the piece in the final square, the move is not valid
ldi r22,$01								;if the piece you are moving is a different colour in the final square, then the move is valid
RET
;
moving_error_jump8:						;need to jump because relative branch out of range
jmp moving_error
;
;*************************************************************************************************
;*********************************** Movement error **********************************************
;*************************************************************************************************
moving_error:
ldi r22,$00								;return with move not valid by setting r22=$00
RET


;*****************************************************************************
;************************* Is the square occupied? ***************************
;*****************************************************************************
;This routine checks whether the intermediate step (r20) square is occupied, and
;if it is occupied, by what colour piece.
;
; r23 = is the space occupied?	$00 = unoccuped		$01 = white occupied 	$10 = black occupied
;
is_the_square_occupied:
push r21
push XL
push XH
;
ldi XH,$01							
mov XL,r20
ld r21,X								;load information about piece at intermediate step
;
lsr r21									;isolate two highest bits
lsr r21
lsr r21
lsr r21
lsr r21
lsr r21
;
cpi r21,$02								;compare two highest bits to definite values
breq square_is_occupied_by_white		;if 0000 0010 square is occupied by a white piece
cpi r21,$03								;if 0000 0011 square is occupied by a white piece
breq square_is_occupied_by_black
;
ldi r23,$00 							;if 0000 0000 square is not occupied
pop XH
pop XL
pop r21
ret
;
square_is_occupied_by_white:
ldi r23,$01								;identify white piece by setting r23=$01
pop XH
pop XL
pop r21
ret
;
square_is_occupied_by_black:
ldi r23,$10								;identify black piece by setting r23=$10
pop XH
pop XL
pop r21
ret
;*****************************************************************************


