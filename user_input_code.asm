;************************************************************************************************
;************************************************************************************************
;************************* USER INPUT POSITION **************************************************
;************************************************************************************************
;************************************************************************************************
; Author: Richard Flint
; Date: 27/02/2015
;************************************************************************************************
; This code allows the user to input both the coordinates of the piece he/she wants to move (start 
; position), and the coordinates of the destination (end position). It then outputs this information,
; along with information of the type of piece being moved.
;
;The program does not run in isolation. It is included in the main_program.asm,
;and is called as a routine (call valid_or_invalid)
;************************************************************************************************
;
; INPUT: 	Must have pieces set on the board
; OUTPUT: 	r16 gives start location
;			r17 gives destination
;			r18 gives piece information of piece in r16
;			r24 gives the selected piece colour 		  			$01 = white  		$10 = black
;			r25 gives the colour that the selected piece should be	$01 = white  		$10 = black
;
; Routine is called using: call user_input_position
;
;*****************************************************************************
;************************* Buttons for reference *****************************
;*****************************************************************************
; PIND = 00000001 ($01) ---> ESC
; PIND = 00000010 ($02) ---> Enter
; PIND = 00000100 ($04) ---> Backspace
; PIND = 00001000 ($08) ---> Y
; PIND = 00010000 ($10) ---> N
; PIND = 00100000 ($20) ---> 
; PIND = 01000000 ($40) ---> 
; PIND = 10000000 ($80) ---> 
;*****************************************************************************
user_input_position:				;call the entire routine
;
rcall select_colour_piece_message			;call a brief message prompting "Select piece..."
rcall Main2							;Main2 is the part of the code that records user input
rcall ascii_to_coordinate_mapping	;map the keypad input to ASCII values
rcall save_initial_position 		;initial position is saved in r16
;
rcall load_piece_information		;load piece information for piece in r16, and save in r18
rcall check_piece_is_present		;check that there is a piece in that square
rcall identify_colour				;identifies the colour of the selected piece, saves in r24
rcall check_piece_colour			;check that the piece selected is the right colour
;
rcall select_destination_message	;call a brief message stating "Select destination..."
rcall Main2							;Main2 is the part of the code that records user input
rcall ascii_to_coordinate_mapping	;map the keypad input to ASCII values
rcall save_final_position			; final position is saved in r17
;
ret									;return to main_program with r16,r17,r18 all recorded
;
; ************************************************************************************* ;
Main2:		
	;letter:
			  rcall CLRDIS			; Clear display
			  rcall Mess1out		; "Input letter"
			  rcall keyboard_input  ; Loops until letter entered
			  rcall keyboard_to_ASCII_letter	; Converts input to ASCII value
			  sts $C000, r20		; Immediately output letter. Letter temporarily stored in r20
			  rcall busylcd
			  ;
			  rcall Mess5spacesOut  ; Adds some spaces to display for nicer LCD output
			  rcall Mess2out		; "Press enter/delete"	
			  rcall enter_button	; Loops until enter or delete button pressed	
			  rcall save_letter 	; If enter is pressed, letter will be saved in XH
			  ;
	;number
			  rcall CLRDIS			; Clear display
			  rcall Mess3out		; "Input number"
			  rcall keyboard_input	; Loops until number entered
			  rcall keyboard_to_ASCII_number	; Converts input to ASCII value
			  sts $C000, r20		; Immediately output letter
			  rcall busylcd
			  ;
			  rcall Mess5spacesOut	; Adds some spaces for nicer LCD output
			  rcall Mess2out		; "Press enter/delete"
			  rcall enter_button	; Loops until enter or delete button pressed
			  rcall save_number		; If enter is pressed, number will be saved in XL
			  ;
	;display coordinates:		  
			  rcall CLRDIS
			  rcall Mess4out		; "Your coordinate: "
			  rcall display_coordinate ; Outputs coordinate on LCD screen
			  rcall Mess1spacesOut  ; Adds a space for nicer LCD output
			  rcall Mess6Out		; "Confirm? (Y/N)"
			  rcall yes_button		; If Y button is pressed, player has committed to move
			  rcall CLRDIS			; Clear display
			  ;			  	           
			  ret ;return to where user_input_position was called
;
;
;
;
;*****************************************************************************
;********************   Keyboard input ***************************************
;*****************************************************************************
;
keyboard_input:	
	push r16
	push r18
	push r19
	;
	; Part 1: Set the initial value to $0F
	;  
	ldi r16, $F0		; I/O (determins which pins are inputs and which are outputs) 
	out DDRE, r16		; Port D Direction Register
	ldi r16, $0F		; Initial value 
	out PORTE, r16		; Port D value
	;
	rcall DEL49ms
	;
	keyboard_loop2:
	in r19,PINE			; Read input from keypad
	cpi r19,$0F			; Check if any button has been pressed
	breq keyboard_loop2	; If no button pressed, then continue looping. If button pressed, carry on
	;
	; Part 2: Set the initial value to $F0
	;  
	ldi r16, $0F		; I/O (determins which pins are inputs and which are outputs)  
	out DDRE, r16		; Port D Direction Register
	ldi r16, $F0		; Initialise value 
	out PORTE, r16		; Port D value
	;
	rcall DEL49ms
	;
	in r18,PINE			; Read input from keypad
	cpi r18,$F0
	breq keyboard_error	;If they have taken their finger off the button too fast, it will register an error
	;
	add r19,r18			;combine coordinates
	mov r20,r19			;move to r20 for saving		
	;
	pop r19
	pop r18
	pop r16
	;
	ret					;returns to Main2 with coordinates temporarily saved in r20
	;
	keyboard_error:				;if the user has pressed they key too fast, it returns an error
	call CLRDIS
	call MessButtonErrorOut		;message out the error
	call BigBigDEL				;wait a bit
	call BigBigDEL
	call CLRDIS
	call MessPressAgainOut		;ask them to press again
	pop r19
	pop r18
	pop r16
	jmp keyboard_input			;jump back to the keyboard input
;
;
;*****************************************************************************
;********************   Select pieces messages  ******************************
;*****************************************************************************
;
select_colour_piece_message:
call CLRDIS
cpi r25,$01
breq select_white_piece_message
cpi r25,$10
breq select_black_piece_message
ret
;
select_white_piece_message:
call MessSelectWhitePieceOut
call BigBigDEL			;message is only temporary
call BigBigDEL
ret
select_black_piece_message:
call MessSelectBlackPieceOut
call BigBigDEL			;message is only temporary
call BigBigDEL
ret
;
;*****************************************************************************
;********************   Select destination messages **************************
;*****************************************************************************
select_destination_message:		;a temporary message notifying the stage of piece selection
		call CLRDIS
		call MessSelectDestinationOut	;"Select destination..."
		call BigBigDEL			;message is only temporary
		call BigBigDEL
		ret
;
;*****************************************************************************
;********************   Temporarily save values  *****************************
;*****************************************************************************
; Temporarily saves values into X
save_letter:
		mov XH, r20
		ret
;
save_number:
		mov XL, r20
		ret
;
;*****************************************************************************
;********************   Display coordinate ************************************
;*****************************************************************************
; Displays the coordinates temporarily stored in X
;
display_coordinate:
	sts $C000, XH
	rcall busylcd
	sts $C000, XL
	rcall busylcd
	ret
;
;
;*****************************************************************************
;************************* Save positions ************************************
;*****************************************************************************
;If move is accepted, then coordinates are transferred to appropriate registers
;
save_initial_position:
	mov r16,XL				;saves start position into r16 for use in rest of code
	ret
save_final_position:
	mov r17,XL				;saves destination in r17 for use in rest of code
	ret
;
;*****************************************************************************
;************************* Check piece colour ********************************
;*****************************************************************************
;
check_piece_colour:			;checks whether the square is filled with a piece
;							of the correct colour for whose turn it is
cp r25,r24
brne colour_not_ok
ret							;
;
colour_not_ok:
call MessWrongColourOut		;"You selected the wrong colour. Try again."
call BigBigDEL
call BigBigDEL
jmp user_input_position		;Return back to allow user another go.
;
;
;;****************************************************************************
;************************* Check piece is present ****************************
;*****************************************************************************
;Checks whether a piece is present in the start square selected
;
check_piece_is_present:
push r18
;
lsr r18							;isolate most significant bit in piece information
lsr r18		
lsr r18
lsr r18
lsr r18
lsr r18
lsr r18
cpi r18,$01						;if most significant bit = $01, then square is occupied.
brne no_piece_present
pop r18
ret								;if a piece is present, then return back with no problems
;
no_piece_present:				;if there is no piece present, we must communicate this
push r20
rcall CLRDIS	
rcall MessNoPiecesOut			;"No piece selected.  Press enter to retry"
;
no_piece_present_loop:			;loop until enter is pressed
	in r20,pind
	com r20
	cpi r20,$02
	brne no_piece_present_loop
	;
	pop r20
	pop r18
	jmp user_input_position		;using jmp is fine, but remember no ret has been used
	ret
;
;*****************************************************************************
;********************   Enter/delete button  *********************************
;*****************************************************************************
;
enter_button:			;routine loops until [enter] or [delete] is pressed
	push r23
	enter_button_loop:
		in r23,pind		; input from pin d buttons on microprocessor board
		com r23			; com input because pin d is inverted
		;
		cpi r23,$04		; branch if delete button is pressed
		breq delete_button
		;
		cpi r23,$02		; loop until enter button is pressed
		brne enter_button_loop
	pop r23
	ret

delete_button:
	pop r23
	jmp Main2			;if delete button is pressed, the program returns to the beginning
	;					;using jmp is fine, but remember no ret has been used

;*****************************************************************************
;********************   Yes/no button  *********************************
;*****************************************************************************
;
yes_button:				;routine loops until [Y] or [N] is pressed
	push r23
	yes_loop:
		in r23,pind		; input from pin d buttons on microprocessor board
		com r23			; com input because pin d is inverted

		cpi r23,$10		; branch if N button is pressed
		breq no_button

		cpi r23,$08		; loop until Y button is pressed
		brne yes_loop
	pop r23
	ret

no_button:
	pop r23
	jmp Main2			; if N button is pressed, the program returns to the beginning
	;					;using jmp is fine, but remember no ret has been used
;
;*****************************************************************************
;************************* Load piece information ****************************
;*****************************************************************************
;
load_piece_information:
push XH
push XL
;
mov XL,r16
ldi XH,$01		; piece information is stored at $01XX where XX is the coordinate
;
ld r18,X		; stored in r18
;
pop XL
pop XH
ret
;
;*****************************************************************************
;**********************      Identify colour     *****************************
;*****************************************************************************
identify_colour:
mov r24,r18 ;save piece type in r24 to identify colour
;
lsl r24		;isolate colour bit
lsr r24
lsr r24
lsr r24
lsr r24
lsr r24
lsr r24
;
cpi r24,$00
breq white_piece
ldi r24,$10			;black piece
ret
white_piece:		;white piece
ldi r24,$01
ret
;
