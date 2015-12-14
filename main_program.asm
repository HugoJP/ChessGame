; ***********************************************************************************************************************
; ***********************************************************************************************************************
; ***********************************************************************************************************************
;
;						Hugo and Rich AKA dogxlcrew present:
;									a chess game
;
; ***********************************************************************************************************************
; ***********************************************************************************************************************
; ***********************************************************************************************************************
;
.DEVICE ATmega128
.include "m128def.inc"	
;
.org	$0
	jmp Init    ; jmp is 2 word instruction to set correct vector
	jmp EXT_INT0; External 0 interrupt vector
;
Init:                
		;  Setup the Stack Pointer to point at the end of SRAM
		;  Put $0FFF in the 1 word SPH:SPL register pair
		; 
		ldi r16, $0F		; Stack Pointer Setup 
		out SPH,r16			; Stack Pointer High Byte 
		ldi r16, $FF		; Stack Pointer Setup 
		out SPL,r16			; Stack Pointer Low Byte 
   		;
		; RAMPZ Setup Code
		; Setup the RAMPZ so we are accessing the lower 64K words of program memory
		;
		ldi  r16, $00		; 1 = EPLM acts on upper 64K
		out RAMPZ, r16		; 0 = EPLM acts on lower 64K
		;
		; ******* Sleep Mode And SRAM  *******
		;			; tell it we want read and write activity on RE WR
		;
		ldi r16, $C0		; Idle Mode - SE bit in MCUCR not set
		out MCUCR, r16		; External SRAM Enable Wait State Enabled
   		;
		; Comparator Setup Code
		; set the Comparator Setup Registor to Disable Input capture and the comparator
		; 
		ldi r16,$80			; Comparator Disabled, Input Capture Disabled 
		out ACSR, r16
   		;   
		; ******* Port A Setup Code ****  
		ldi r16, $FF		; $FF is output
		out DDRA, r16		; Port A Direction Register
		ldi r16, $FF		; Init value 
		out PORTA, r16		; Port A value
   
		; ******* Port B Setup Code ****  
		ldi r16, $FF		; will set to outputs so i can use Leds for debugging
		out DDRB , r16		; Port B Direction Register
		ldi r16, $FF		; Who cares what is it....
		out PORTB, r16		; Port B value
   
		; ******* Port C Setup Code ****  
		ldi r16, $FF		; $FF is output
		out DDRC, r16		; Port A Direction Register
		ldi r16, $FF		; Init value 
		out PORTC, r16		; Port A value

		; ******* Port D Setup Code **** 
		; Setup PORTD (the switches on the STK300) as inputs by setting the direction register
		; bits to $00.  Set the initial value to $FF
		;  
		ldi r16, $00		; I/O: 
		out DDRD, r16		; Port D Direction Register
		ldi r16, $FF		; Init value 
		out PORTD, r16		; Port D value
;
		;
		; ******* Port F Setup Code ****  
		;ldi r16, $FF		; $FF is output
		;out DDRF, r16		; Port A Direction Register
		;ldi r16, $FF		; Init value 
		;out PORTF, r16		; Port A value
		;
		;
		; ******* External Interrupt setup code ******
		;
		ldi r16,$01
		out EIMSK, r16  
		sei
		;
		;Graphic LCD initialisation
		call initialise_LCD_DOGXL
		;
		;Alphanumeric LCD initialisation
		call alphanum_lcd_initialisation
		;
		;
		call MessDemoQuestionOut
		push r16
		demo_question_loop:
		in r16,PIND
		com r16
		cpi r16,$08
		breq play_game
		cpi r16,$10
		brne demo_question_loop
		pop r16
		play_demo:
		call CLRDIS
		call MessPressESCOut
		call initialise_LCD_DOGXL
		push r16
		push XL
		push XH
		ldi XH,$01
		ldi XL,$10
		ldi r16,$00
		st X,r16
		pop XH
		pop XL
		pop r16
		demo_loop:
		call pieces_initialisation
		call demo
		call initialise_LCD_DOGXL
		rjmp demo_loop
		play_game:
		pop r16
		push r16
		push XL
		push XH
		ldi XH,$01
		ldi XL,$10
		ldi r16,$01
		st X,r16
		pop XH
		pop XL
		pop r16
		call CLRDIS
		;
		push r16
		pind_clear_loop:
		in r16, PIND
		com r16
		cpi r16,$00
		breq continue
		rjmp pind_clear_loop
		continue:
		pop r16
		
		;
		;Place the pieces on the chess board
		call chess_board_initialisation

		;call chess_board_initialisation_2 	;this is a debugging initialisation
		;
		;Place inital pieces on screen
		call initial_pieces_onto_screen
MainMain:
call user_input_position
;
call move_verification_algorithm
;
call valid_or_invalid	;if valid, saves move. if invalid, does not save move
;
call king_check
;
cpi r22,$01
breq output_to_DOGXL_screen
rjmp MainMain
;***********************
output_to_DOGXL_screen:
push r25
push r16
call output_DOGXL
pop r16
mov r17,r16
ldi r18,$00
call output_DOGXL
pop r25
call change_colour
rjmp MainMain
;
; Include files
.include "initial_pieces_onto_screen.asm"
.include "valid_or_invalid.asm"
.include "change_colour.asm"
.include "king_check.asm"
.include "chess_board_initialisation.asm"
.include "chess_board_initialisation_2.asm"
.include "user_input_code.asm"
.include "move_identifier_algorithm.asm"
.include "move_verification_algorithm.asm"
.include "alphanumeric_lcd_initialisation.asm"
.include "delay_routines.asm"
.include "messages.asm"
.include "mapping.asm"
.include "save_game_interrupt.asm"
.include "dogxl_initialisation.asm"
