
;Program to initialise and control the DOGXL-160W lcd in 4 wire, 8-bit SPI-mode
;Hugo Jeanperrin
;27.02.15

;*******************Register-Definition*********************
.def rPage				= R16	;Byte containing the page address
.def rColumn			= R23	;Byte containing the column address
.def rByteLCD			= R18	;Byte sent to the lcd
.def rCount				= R19	
.def rTemp1				= R20
.def rTemp2				= R21
.def rTemp3				= R22

;*********************Port-Definition***********************
.equ PORTDOGLCD			= PORTB		; SPI output port
.equ PINDOGLCD			= PINB
.equ DDRDOGLCD			= DDRB
.equ cInitPortDOGLCD	= 0b11111111

.equ PinSDA				= 3			;Data transfer pin
.equ PinSCK				= 2			;Clock
.equ PinCD				= 0			;Command or data mode pin
.equ PinCS				= 1			;Chip select
.equ PinReset			= 4			;Is kept HIGH after the initialisation

.equ cSetPageAddress	= 0b01100000	;the five lower bits contain the current page (pins 0-4)
.equ cSetColAddrMSB		= 0b00010000	;the four lowest bits contain the highest nibble for the column
.equ cSetColAddrLSB		= 0b00000000	;the four lowest bits contain the lowest nibble for the column
.equ cNumColumnsLCD		= 160			;Number of pixels in the horizontal direction
.equ cNumPagesLCD		= 104/4		    ;Number of pixels along the vertical axis /4 (number of pages)
	
;The UC1610-LCD-Kontroller uses two bits to define a pixel
;Pixels: 1 = On, 00 = OFF
;A page and a column therefore represent one byte of information

;Constants setting the delay functions.
.equ cDelay5us			= 1			 
.equ cDelay10us			= 2



;*********************************************************************
;Interrupt-Table
;*********************************************************************
		jmp Initialise_LCD_DOGXL		                 ; jmp is 2 word instruction to set correct vector
		nop			; Vector Addresses are 2 words apart
		reti			; External 0 interrupt  Vector 
		nop			; Vector Addresses are 2 words apart
		reti			; External 1 interrupt  Vector 
		nop			; Vector Addresses are 2 words apart
		reti			; External 2 interrupt  Vector 
		nop			; Vector Addresses are 2 words apart
		reti			; External 3 interrupt  Vector 
		nop			; Vector Addresses are 2 words apart
		reti			; External 4 interrupt  Vector 
		nop			; Vector Addresses are 2 words apart
		reti			; External 5 interrupt  Vector 
		nop			; Vector Addresses are 2 words apart
		reti			; External 6 interrupt  Vector 
		nop			; Vector Addresses are 2 words apart
		reti			; External 7 interrupt  Vector 
		nop			; Vector Addresses are 2 words apart
		reti			; Timer 2 Compare Vector 
		nop			; Vector Addresses are 2 words apart
		reti			; Timer 2 Overflow Vector 
		nop			; Vector Addresses are 2 words apart
		reti			; Timer 1 Capture  Vector 
		nop			; Vector Addresses are 2 words apart
		reti			; Timer1 CompareA  Vector 
		nop			; Vector Addresses are 2 words apart
		reti			; Timer 1 CompareB  Vector 
		nop			; Vector Addresses are 2 words apart
		reti			; Timer 1 Overflow  Vector 
		nop			; Vector Addresses are 2 words apart
		reti			; Timer 0 Compare  Vector 
		nop 		; Timer 0 Overflow interrupt  Vector 
		nop			; Vector Addresses are 2 words apart
		reti			; SPI  Vector 
		nop			; Vector Addresses are 2 words apart
		reti			; UART Receive  Vector 
		nop			; Vector Addresses are 2 words apart
		reti			; UDR Empty  Vector 
		nop			; Vector Addresses are 2 words apart
		reti			; UART Transmit  Vector 
		nop			; Vector Addresses are 2 words apart
		reti			; ADC Conversion Complete Vector 
		nop			; Vector Addresses are 2 words apart
		reti			; EEPROM Ready Vector 
		nop			; Vector Addresses are 2 words apart
		reti			; Analog Comparator  Vector 
;---------------------------------------------------------------------


;*********************************************************************
Initialise_LCD_DOGXL:
	; ************* Stack Pointer Setup Code   
		ldi rTemp1, $0F
		
		; Stack Pointer Setup to 0x0FFF
		;out SPH,rTemp1		; Stack Pointer High Byte 
		;ldi r16, $FF		; Stack Pointer Setup 
		;out SPL,rTemp1		; Stack Pointer Low Byte 

		; ******* Port B Setup Code ****  
		;ldi r16, $FF		; will set to outputs to use Leds for debugging
		;out DDRB , r16		; Port B Direction Register
		;ldi r16, $FF		
		;out PORTB, r16		; Port B value
   
	;LCD initialisation
	rcall	fcInitGraphik_DOGLCD
	rcall	Main_DOGXL
	rcall coordinates
	ret	
;---------------------------------------------------------------------

;*************************************************************
;Delay-Function 5us
;*************************************************************
mDelay5us:
	LDI		XH, HIGH(cDelay5us)
	LDI     XL, LOW(cDelay5us)
LoopDelayLCD5us:
	;NOP          			;1 clock cycle (cc)
	SBIW X,1                ;2 cc
	BRNE	LoopDelayLCD5us	;1 cc
	ret
;--------------------------------------------------------------

;*************************************************************
;Delay-Function 10us
;*************************************************************
mDelay10us:
	LDI		XH, HIGH(cDelay10us)
	LDI     XL, LOW(cDelay10us)
LoopDelayLCD10us:
	;NOP          			;1 cc
	SBIW X,1				;2 cc
	BRNE	LoopDelayLCD10us	;1 cc
	ret
;--------------------------------------------------------------

;*************************************************************
;Delay-Makro 1ms
;*************************************************************
mDelay1ms:
	PUSH    XH
	PUSH    XL
;
; This is a 1 msec delay routine. Each cycle costs
; rcall       -> 3 CC
; ret         -> 4 CC
; 2*LDI       -> 2 CC 
; SBIW        -> 2 CC * 2286
; BRNE        -> 1/2 CC * 2286
; Total       -> 8009

            LDI XH, HIGH(2286)
            LDI XL, LOW (2286)
COUNT1ms:  
            SBIW X, 1
            BRNE COUNT1ms
			POP XH
			POP XL
            RET

;--------------------------------------------------------------

;*************************************************************
;Delay-Function 100ms
;*************************************************************
mDelay100ms:
		PUSH    XH
		PUSH    XL
		PUSH    rTemp1
;
; This is a 100 msec delay routine. 
; Do the 1 msed Function 100 times

            
			LDI rTemp1, 100
COUNT100ms:
			LDI XH, HIGH(2286)
            LDI XL, LOW (2286)

COUNT100ms2:  
            SBIW X, 1
            BRNE COUNT100ms2
			SUBI rTemp1,1
			BRNE COUNT100ms
			POP XH
			POP XL
			POP rTemp1
            RET
;--------------------------------------------------------------

;**************************************************************
;Delay Function 1s
;**************************************************************
delay1s:

ldi rTemp1,10
count1s:
	rcall mDelay100ms
	subi rTemp1,1
	brne count1s
	ret

;--------------------------------------------------------------

;*********************************************************************
;Main program
;*********************************************************************
Main_DOGXL:
	
	;Program draws a chessboard with no pieces
	CLR		rPage ; Start at page = 0
	LDI		rTemp1,6

LoopPage:
	ldi	rColumn,36	;Column start for the chessboard
	ldi		rByteLCD, 0b10101010 ; Four light gray pixels
	RCALL	fcSetCurrentLCDAddress
	LDI		rTemp2,12 ; Each square is 12 pixels wide
	CPI		rTemp1,4	; Alternate the colour every 3 pages (12 pixels)
	BRLO	LoopChessY
	DEC 	rTemp1
	ldi		rByteLCD, 0b10101010 ;Four dark gray pixels
	
LoopCol:
	
	CPI		rTemp2,0
	BREQ    LoopChessX
	DEC		rTemp2
	RCALL	fcSendDataToLCD
	INC		rColumn
	CPI		rColumn, 132 ;Column coordinate end for the chessboard
	BRNE	LoopCol

	
	INC		rPage
	CPI		rPage, 24 ; Page coordinate end for the chessboard
	BRLO	LoopPage

ret



EndMain:
	rjmp EndMain

LoopChessX:
	com rByteLCD
	ldi rTemp2,12
	rjmp LoopCol

LoopChessY:
	LDI		rByteLCD, 0b01010101 ;Four dark gray pixels
	DEC 	rTemp1
	cpi	rTemp1,0
	breq LoopChessy2
	rjmp LoopCol

LoopChessy2:
	ldi rTemp1,6
	rjmp LoopCol
;---------------------------------------------------------------------
;*********************************************************************
; Output coordinates to the screen
;*********************************************************************

coordinates:

	LDI ZH, HIGH(2*Num8)
	LDI ZL, LOW(2*Num8)
	ldi rPage,0
	ldi rColumn,24
	rcall CharOut

	LDI ZH, HIGH(2*Num7)
	LDI ZL, LOW(2*Num7)
	ldi rPage,3
	ldi rColumn,24
	rcall CharOut

	LDI ZH, HIGH(2*Num6)
	LDI ZL, LOW(2*Num6)
	ldi rPage,6
	ldi rColumn,24
	rcall CharOut

	LDI ZH, HIGH(2*Num5)
	LDI ZL, LOW(2*Num5)
	ldi rPage,9
	ldi rColumn,24
	rcall CharOut

	LDI ZH, HIGH(2*Num4)
	LDI ZL, LOW(2*Num4)
	ldi rPage,12
	ldi rColumn,24
	rcall CharOut

	LDI ZH, HIGH(2*Num3)
	LDI ZL, LOW(2*Num3)
	ldi rPage,15
	ldi rColumn,24
	rcall CharOut

	LDI ZH, HIGH(2*Num2)
	LDI ZL, LOW(2*Num2)
	ldi rPage,18
	ldi rColumn,24
	rcall CharOut

	LDI ZH, HIGH(2*Num1)
	LDI ZL, LOW(2*Num1)
	ldi rPage,21
	ldi rColumn,24
	rcall CharOut

	LDI ZH, HIGH(2*Numa)
	LDI ZL, LOW(2*Numa)
	ldi rPage,24
	ldi rColumn,36
	rcall CharOut

	LDI ZH, HIGH(2*Numb)
	LDI ZL, LOW(2*Numb)
	ldi rPage,24
	ldi rColumn,48
	rcall CharOut

	LDI ZH, HIGH(2*Numc)
	LDI ZL, LOW(2*Numc)
	ldi rPage,24
	ldi rColumn,60
	rcall CharOut

	LDI ZH, HIGH(2*Numd)
	LDI ZL, LOW(2*Numd)
	ldi rPage,24
	ldi rColumn,72
	rcall CharOut

	LDI ZH, HIGH(2*Nume)
	LDI ZL, LOW(2*Nume)
	ldi rPage,24
	ldi rColumn,84
	rcall CharOut

	LDI ZH, HIGH(2*Numf)
	LDI ZL, LOW(2*Numf)
	ldi rPage,24
	ldi rColumn,96
	rcall CharOut

	LDI ZH, HIGH(2*Numg)
	LDI ZL, LOW(2*Numg)
	ldi rPage,24
	ldi rColumn,108
	rcall CharOut


	LDI ZH, HIGH(2*Numh)
	LDI ZL, LOW(2*Numh)
	ldi rPage,24
	ldi rColumn,120
	rcall CharOut
ret

;---------------------------------------------------------------------
;*********************************************************************
; Output pieces to the screen - this function can be called by the
; main program to output a move to the LCD screen. The destination is 
; given in r17 and the value of the piece is given by r18.
;*********************************************************************

output_DOGXL:
; Column value conversion
push r17
push r18

push r17
andi r17,0b11110000
cpi r17,$10
breq coordinate_a
cpi r17,$20
breq coordinate_b
cpi r17,$30
breq coordinate_c
cpi r17,$40
breq coordinate_d
cpi r17,$50
breq coordinate_e
cpi r17,$60
breq coordinate_f
cpi r17,$70
breq coordinate_g
cpi r17,$80
breq coordinate_h

coordinate_a:
ldi rColumn,36
rjmp Page_conversion
coordinate_b:
ldi rColumn,48
rjmp Page_conversion
coordinate_c:
ldi rColumn,60
rjmp Page_conversion
coordinate_d:
ldi rColumn,72
rjmp Page_conversion
coordinate_e:
ldi rColumn,84
rjmp Page_conversion
coordinate_f:
ldi rColumn,96
rjmp Page_conversion
coordinate_g:
ldi rColumn,108
rjmp Page_conversion
coordinate_h:
ldi rColumn,120
rjmp Page_conversion

Page_conversion:
pop r17
push r17
andi r17,0b00001111
cpi r17,$1
breq coordinate_1
cpi r17,$2
breq coordinate_2
cpi r17,$3
breq coordinate_3
cpi r17,$4
breq coordinate_4
cpi r17,$5
breq coordinate_5
cpi r17,$6
breq coordinate_6
cpi r17,$7
breq coordinate_7
cpi r17,$8
breq coordinate_8

coordinate_1:
ldi rPage,21
rjmp Piece_conversion
coordinate_2:
ldi rPage,18
rjmp Piece_conversion
coordinate_3:
ldi rPage,15
rjmp Piece_conversion
coordinate_4:
ldi rPage,12
rjmp Piece_conversion
coordinate_5:
ldi rPage,9
rjmp Piece_conversion
coordinate_6:
ldi rPage,6
rjmp Piece_conversion
coordinate_7:
ldi rPage,3
rjmp Piece_conversion
coordinate_8:
ldi rPage,0
rjmp Piece_conversion

Piece_conversion:
pop r17
rcall odd_or_even
add r18,r17

cpi r18,$81
breq white_pawn_black_background
cpi r18,$84
breq white_castle_black_background
cpi r18,$82
breq white_knight_black_background
cpi r18,$83
breq white_bishop_black_background
cpi r18,$85
breq white_queen_black_background
cpi r18,$86
breq white_king_black_background
rjmp white_white


;**************************

white_pawn_black_background:
ldi ZH, HIGH(2*white_pawn_black_square)
ldi ZL, LOW(2*white_pawn_black_square)
rjmp piece_output
white_castle_black_background:
ldi ZH, HIGH(2*white_tower_black_square)
ldi ZL, LOW(2*white_tower_black_square)
rjmp piece_output
white_knight_black_background:
ldi ZH, HIGH(2*white_knight_black_square)
ldi ZL, LOW(2*white_knight_black_square)
rjmp piece_output
white_bishop_black_background:
ldi ZH, HIGH(2*white_bishop_black_square)
ldi ZL, LOW(2*white_bishop_black_square)
rjmp piece_output
white_queen_black_background:
ldi ZH, HIGH(2*white_queen_black_square)
ldi ZL, LOW(2*white_queen_black_square)
rjmp piece_output
white_king_black_background:
ldi ZH, HIGH(2*white_king_black_square)
ldi ZL, LOW(2*white_king_black_square)
rjmp piece_output


white_white:
cpi r18,$91
breq white_pawn_white_background
cpi r18,$94
breq white_castle_white_background
cpi r18,$92
breq white_knight_white_background
cpi r18,$93
breq white_bishop_white_background
cpi r18,$95
breq white_queen_white_background
cpi r18,$96
breq white_king_white_background
rjmp black_black



white_pawn_white_background:
ldi ZH, HIGH(2*white_pawn_white_square)
ldi ZL, LOW(2*white_pawn_white_square)
rjmp piece_output
white_castle_white_background:
ldi ZH, HIGH(2*white_tower_white_square)
ldi ZL, LOW(2*white_tower_white_square)
rjmp piece_output
white_knight_white_background:
ldi ZH, HIGH(2*white_knight_white_square)
ldi ZL, LOW(2*white_knight_white_square)
rjmp piece_output
white_bishop_white_background:
ldi ZH, HIGH(2*white_bishop_white_square)
ldi ZL, LOW(2*white_bishop_white_square)
rjmp piece_output
white_queen_white_background:
ldi ZH, HIGH(2*white_queen_white_square)
ldi ZL, LOW(2*white_queen_white_square)
rjmp piece_output
white_king_white_background:
ldi ZH, HIGH(2*white_king_white_square)
ldi ZL, LOW(2*white_king_white_square)
rjmp piece_output

black_black:

cpi r18,$C1
breq black_pawn_black_background
cpi r18,$C4
breq black_castle_black_background
cpi r18,$C2
breq black_knight_black_background
cpi r18,$C3
breq black_bishop_black_background
cpi r18,$C5
breq black_queen_black_background
cpi r18,$C6
breq black_king_black_background
rjmp black_white


black_pawn_black_background:
ldi ZH, HIGH(2*black_pawn_black_square)
ldi ZL, LOW(2*black_pawn_black_square)
rjmp piece_output
black_castle_black_background:
ldi ZH, HIGH(2*black_tower_black_square)
ldi ZL, LOW(2*black_tower_black_square)
rjmp piece_output
black_knight_black_background:
ldi ZH, HIGH(2*black_knight_black_square)
ldi ZL, LOW(2*black_knight_black_square)
rjmp piece_output
black_bishop_black_background:
ldi ZH, HIGH(2*black_bishop_black_square)
ldi ZL, LOW(2*black_bishop_black_square)
rjmp piece_output
black_queen_black_background:
ldi ZH, HIGH(2*black_queen_black_square)
ldi ZL, LOW(2*black_queen_black_square)
rjmp piece_output
black_king_black_background:
ldi ZH, HIGH(2*black_king_black_square)
ldi ZL, LOW(2*black_king_black_square)
rjmp piece_output

black_white:

cpi r18,$D1
breq black_pawn_white_background
cpi r18,$D4
breq black_castle_white_background
cpi r18,$D2
breq black_knight_white_background
cpi r18,$D3
breq black_bishop_white_background
cpi r18,$D5
breq black_queen_white_background
cpi r18,$D6
breq black_king_white_background
cpi r18,$00
breq black_empty_square
cpi r18,$10
breq white_empty_square


black_pawn_white_background:
ldi ZH, HIGH(2*black_pawn_white_square)
ldi ZL, LOW(2*black_pawn_white_square)
rjmp piece_output
black_castle_white_background:
ldi ZH, HIGH(2*black_tower_white_square)
ldi ZL, LOW(2*black_tower_white_square)
rjmp piece_output
black_knight_white_background:
ldi ZH, HIGH(2*black_knight_white_square)
ldi ZL, LOW(2*black_knight_white_square)
rjmp piece_output
black_bishop_white_background:
ldi ZH, HIGH(2*black_bishop_white_square)
ldi ZL, LOW(2*black_bishop_white_square)
rjmp piece_output
black_queen_white_background:
ldi ZH, HIGH(2*black_queen_white_square)
ldi ZL, LOW(2*black_queen_white_square)
rjmp piece_output
black_king_white_background:
ldi ZH, HIGH(2*black_king_white_square)
ldi ZL, LOW(2*black_king_white_square)
rjmp piece_output
black_empty_square:
ldi ZH, HIGH(2*empty_black_square)
ldi ZL, LOW(2*empty_black_square)
rjmp piece_output
white_empty_square:
ldi ZH, HIGH(2*empty_white_square)
ldi ZL, LOW(2*empty_white_square)
rjmp piece_output

piece_output:
rcall CharOut

pop r17
pop r18


ret
;---------------------------------------------------------------------
;*********************************************************************
; Initialise the board by outputting the pieces in the correct place
;*********************************************************************
pieces_initialisation:

	LDI ZH, HIGH(2*white_pawn_black_square)
	LDI ZL, LOW(2*white_pawn_black_square)
	ldi rPage,3
	ldi rColumn,36
	rcall CharOut

	LDI ZH, HIGH(2*white_pawn_black_square)
	LDI ZL, LOW(2*white_pawn_black_square)
	ldi rPage,3
	ldi rColumn,60
	rcall CharOut

	LDI ZH, HIGH(2*white_pawn_black_square)
	LDI ZL, LOW(2*white_pawn_black_square)
	ldi rPage,3
	ldi rColumn,84
	rcall CharOut

	LDI ZH, HIGH(2*white_pawn_black_square)
	LDI ZL, LOW(2*white_pawn_black_square)
	ldi rPage,3
	ldi rColumn,108
	rcall CharOut
	
	LDI ZH, HIGH(2*white_pawn_white_square)
	LDI ZL, LOW(2*white_pawn_white_square)
	ldi rPage,3
	ldi rColumn,48
	rcall CharOut

	LDI ZH, HIGH(2*white_pawn_white_square)
	LDI ZL, LOW(2*white_pawn_white_square)
	ldi rPage,3
	ldi rColumn,72
	rcall CharOut


	LDI ZH, HIGH(2*white_pawn_white_square)
	LDI ZL, LOW(2*white_pawn_white_square)
	ldi rPage,3
	ldi rColumn,96
	rcall CharOut

	LDI ZH, HIGH(2*white_pawn_white_square)
	LDI ZL, LOW(2*white_pawn_white_square)
	ldi rPage,3
	ldi rColumn,120
	rcall CharOut

	LDI ZH, HIGH(2*black_pawn_black_square)
	LDI ZL, LOW(2*black_pawn_black_square)
	ldi rPage,18
	ldi rColumn,48
	rcall CharOut

	LDI ZH, HIGH(2*black_pawn_black_square)
	LDI ZL, LOW(2*black_pawn_black_square)
	ldi rPage,18
	ldi rColumn,72
	rcall CharOut

	LDI ZH, HIGH(2*black_pawn_black_square)
	LDI ZL, LOW(2*black_pawn_black_square)
	ldi rPage,18
	ldi rColumn,96
	rcall CharOut

	LDI ZH, HIGH(2*black_pawn_black_square)
	LDI ZL, LOW(2*black_pawn_black_square)
	ldi rPage,18
	ldi rColumn,120
	rcall CharOut

	LDI ZH, HIGH(2*black_pawn_white_square)
	LDI ZL, LOW(2*black_pawn_white_square)
	ldi rPage,18
	ldi rColumn,36
	rcall CharOut

	LDI ZH, HIGH(2*black_pawn_white_square)
	LDI ZL, LOW(2*black_pawn_white_square)
	ldi rPage,18
	ldi rColumn,60
	rcall CharOut

	LDI ZH, HIGH(2*black_pawn_white_square)
	LDI ZL, LOW(2*black_pawn_white_square)
	ldi rPage,18
	ldi rColumn,84
	rcall CharOut

	LDI ZH, HIGH(2*black_pawn_white_square)
	LDI ZL, LOW(2*black_pawn_white_square)
	ldi rPage,18
	ldi rColumn,108
	rcall CharOut

	LDI ZH, HIGH(2*white_bishop_white_square)
	LDI ZL, LOW(2*white_bishop_white_square)
	ldi rPage,0
	ldi rColumn,60
	rcall CharOut
	
	LDI ZH, HIGH(2*black_bishop_white_square)
	LDI ZL, LOW(2*black_bishop_white_square)
	ldi rPage,21
	ldi rColumn,96
	rcall CharOut

	LDI ZH, HIGH(2*black_bishop_black_square)
	LDI ZL, LOW(2*black_bishop_black_square)
	ldi rPage,21
	ldi rColumn,60
	rcall CharOut

	LDI ZH, HIGH(2*white_bishop_black_square)
	LDI ZL, LOW(2*white_bishop_black_square)
	ldi rPage,0
	ldi rColumn,96
	rcall CharOut

	LDI ZH, HIGH(2*white_knight_black_square)
	LDI ZL, LOW(2*white_knight_black_square)
	ldi rPage,0
	ldi rColumn,48
	rcall CharOut

	LDI ZH, HIGH(2*black_knight_black_square)
	LDI ZL, LOW(2*black_knight_black_square)
	ldi rPage,21
	ldi rColumn,108
	rcall CharOut

	LDI ZH, HIGH(2*black_knight_white_square)
	LDI ZL, LOW(2*black_knight_white_square)
	ldi rPage,21
	ldi rColumn,48
	rcall CharOut

	LDI ZH, HIGH(2*white_knight_white_square)
	LDI ZL, LOW(2*white_knight_white_square)
	ldi rPage,0
	ldi rColumn,108
	rcall CharOut

	LDI ZH, HIGH(2*white_tower_white_square)
	LDI ZL, LOW(2*white_tower_white_square)
	ldi rPage,0
	ldi rColumn,36
	rcall CharOut

	LDI ZH, HIGH(2*black_tower_white_square)
	LDI ZL, LOW(2*black_tower_white_square)
	ldi rPage,21
	ldi rColumn,120
	rcall CharOut

	LDI ZH, HIGH(2*black_tower_black_square)
	LDI ZL, LOW(2*black_tower_black_square)
	ldi rPage,21
	ldi rColumn,36
	rcall CharOut

	LDI ZH, HIGH(2*white_tower_black_square)
	LDI ZL, LOW(2*white_tower_black_square)
	ldi rPage,0
	ldi rColumn,120
	rcall CharOut

	LDI ZH, HIGH(2*white_queen_white_square)
	LDI ZL, LOW(2*white_queen_white_square)
	ldi rPage,0
	ldi rColumn,84
	rcall CharOut

	LDI ZH, HIGH(2*black_queen_black_square)
	LDI ZL, LOW(2*black_queen_black_square)
	ldi rPage,21
	ldi rColumn,84
	rcall CharOut

	LDI ZH, HIGH(2*white_king_black_square)
	LDI ZL, LOW(2*white_king_black_square)
	ldi rPage,0
	ldi rColumn,72
	rcall CharOut

	LDI ZH, HIGH(2*black_king_white_square)
	LDI ZL, LOW(2*black_king_white_square)
	ldi rPage,21
	ldi rColumn,72
	rcall CharOut




ret
;*********************************************************************
; Checkmate in 10 moves
;*********************************************************************
demo:

	rcall delay1s

	LDI ZH, HIGH(2*empty_black_square)
	LDI ZL, LOW(2*empty_black_square)
	ldi rPage,3
	ldi rColumn,84
	rcall CharOut
	
	LDI ZH, HIGH(2*white_pawn_black_square)
	LDI ZL, LOW(2*white_pawn_black_square)
	ldi rPage,9
	ldi rColumn,84
	rcall CharOut
	
	rcall delay1s
	
	LDI ZH, HIGH(2*empty_white_square)
	LDI ZL, LOW(2*empty_white_square)
	ldi rPage,18
	ldi rColumn,84
	rcall CharOut
	
	LDI ZH, HIGH(2*black_pawn_white_square)
	LDI ZL, LOW(2*black_pawn_white_square)
	ldi rPage,12
	ldi rColumn,84
	rcall CharOut
	
	rcall delay1s
	
	LDI ZH, HIGH(2*empty_black_square)
	LDI ZL, LOW(2*empty_black_square)
	ldi rPage,0
	ldi rColumn,48
	rcall CharOut
	
	LDI ZH, HIGH(2*white_knight_white_square)
	LDI ZL, LOW(2*white_knight_white_square)
	ldi rPage,6
	ldi rColumn,60
	rcall CharOut
	
	rcall delay1s
	
	LDI ZH, HIGH(2*empty_white_square)
	LDI ZL, LOW(2*empty_white_square)
	ldi rPage,21
	ldi rColumn,96
	rcall CharOut
	
	LDI ZH, HIGH(2*black_bishop_white_square)
	LDI ZL, LOW(2*black_bishop_white_square)
	ldi rPage,9
	ldi rColumn,48
	rcall CharOut
	
	rcall delay1s
	
	LDI ZH, HIGH(2*empty_white_square)
	LDI ZL, LOW(2*empty_white_square)
	ldi rPage,6
	ldi rColumn,60
	rcall CharOut
	
	LDI ZH, HIGH(2*white_knight_black_square)
	LDI ZL, LOW(2*white_knight_black_square)
	ldi rPage,12
	ldi rColumn,72
	rcall CharOut
	
	rcall delay1s
	
	LDI ZH, HIGH(2*empty_white_square)
	LDI ZL, LOW(2*empty_white_square)
	ldi rPage,18
	ldi rColumn,36
	rcall CharOut
	
	LDI ZH, HIGH(2*black_pawn_white_square)
	LDI ZL, LOW(2*black_pawn_white_square)
	ldi rPage,12
	ldi rColumn,36
	rcall CharOut
	
	rcall delay1s
	
	LDI ZH, HIGH(2*empty_white_square)
	LDI ZL, LOW(2*empty_white_square)
	ldi rPage,0
	ldi rColumn,84
	rcall CharOut

	LDI ZH, HIGH(2*white_queen_white_square)
	LDI ZL, LOW(2*white_queen_white_square)
	ldi rPage,6
	ldi rColumn,84
	rcall CharOut
	
	rcall delay1s
	
	LDI ZH, HIGH(2*empty_white_square)
	LDI ZL, LOW(2*empty_white_square)
	ldi rPage,18
	ldi rColumn,60
	rcall CharOut
	
	LDI ZH, HIGH(2*black_pawn_black_square)
	LDI ZL, LOW(2*black_pawn_black_square)
	ldi rPage,15
	ldi rColumn,60
	rcall CharOut
	
	rcall delay1s
	
	
	LDI ZH, HIGH(2*empty_white_square)
	LDI ZL, LOW(2*empty_white_square)
	ldi rPage,6
	ldi rColumn,84
	rcall CharOut


	LDI ZH, HIGH(2*white_queen_white_square)
	LDI ZL, LOW(2*white_queen_white_square)
	ldi rPage,15
	ldi rColumn,48
	rcall CharOut

	rcall delay1s
	
	ret

;--------------------------------------------------------------------

;********************************************************************
;Subroutine initialising the DOGXL-LCD
;********************************************************************
fcInitGraphik_DOGLCD:
	;Delay to give the screen time to power up
	rcall mDelay100ms
	;Initialisation of the LCD-Port. Reset is LOW
	LDI		rTemp1, cInitPortDOGLCD
	OUT		DDRDOGLCD, rTemp1
	CBI		PORTDOGLCD, PinReset
	CBI		PORTDOGLCD, PinSDA
	CBI		PORTDOGLCD, PinCD
	SBI		PORTDOGLCD, PinSCK
	CBI		PORTDOGLCD, PinCS
	rcall	mDelay1ms
	
	;Initialisation through the reset. This was taken from the DOGM 128-W-LCD
	;initialisation sequence (cf. datasheet ST7565R, pg 65). Without this sequence
	; the display doesn't start correctly.
	SBI		PORTDOGLCD, PinReset
	rcall	mDelay1ms
	CBI		PORTDOGLCD, PinReset
	rcall	mDelay10us
	SBI		PORTDOGLCD, PinReset
	rcall	mDelay10us

	;Initialisierung gem‰ﬂ Tabelle Datenblatt EA DOGXL160, S. 6
	LDI		rByteLCD, 0xF1			;Set last COM-Electrode to 104-1
	RCALL 	fcSendCommandToLCD
	LDI		rByteLCD, 0x67			;
	RCALL 	fcSendCommandToLCD
	LDI		rByteLCD, 0xC0			;Set Mapping control
	RCALL 	fcSendCommandToLCD
	LDI		rByteLCD, 0x40			;Set Scroll line LSB
	RCALL 	fcSendCommandToLCD
	LDI		rByteLCD, 0x50			;Set Scroll line MSB
	RCALL 	fcSendCommandToLCD
	LDI		rByteLCD, 0x2B			;Set Panel Loading
	RCALL 	fcSendCommandToLCD
	LDI		rByteLCD, 0xEB			;Set LCD Bias Ratio
	RCALL 	fcSendCommandToLCD
	LDI		rByteLCD, 0x81			;Set Vbias Potentiometer
	RCALL 	fcSendCommandToLCD
	LDI		rByteLCD, 0x5f			;Set Vbias Potentiometer
	RCALL 	fcSendCommandToLCD
	LDI		rByteLCD, 0x89			;Set RAM address control = auto increment
	RCALL 	fcSendCommandToLCD
	LDI		rByteLCD, 0xAF			;Display enable
	RCALL 	fcSendCommandToLCD
	rcall	mDelay1ms

	;Erase display
	RCALL	fcEraseDisplay
	
	ret
;-------------------------------------------------------------------------------

;********************************************************************
;Subroutine sends the address to the LCD.
;The values in the registers rColumn and rPage are given
;rPage, rColumn and rByteLCD are sent back unchanged
;********************************************************************
fcSetCurrentLCDAddress:
	;Save registers
	PUSH	rPage
	PUSH	rColumn
	PUSH	rByteLCD

	;rColumn contains column address (0 - 160).
	;rColumn needs to be used twice
	PUSH	rColumn
	LDI		rByteLCD, cSetColAddrMSB
	;Die 4 highest bits must be transferred to the lowest Nibble
	;The four highest bits are set to 00
	SWAP	rColumn
	ANDI	rColumn, 0b00001111
	;Send the highest nibble to the LCD.
	ADD		rByteLCD, rColumn
	RCALL	fcSendCommandToLCD
	;Pop rColumn and send the 4 lower bits to the LCD
	POP		rColumn
	LDI		rByteLCD, cSetColAddrLSB
	ANDI	rColumn, 0b00001111
	ADD		rByteLCD, rColumn
	RCALL	fcSendCommandToLCD
	;Send page
	LDI		rByteLCD, cSetPageAddress
	ADD		rByteLCD, rPage
	RCALL	fcSendCommandToLCD

	POP		rByteLCD
	POP		rColumn
	POP		rPage
	ret
;--------------------------------------------------------------------

.include "characters_and_pieces.asm"
;********************************************************************
; Subroutine which outputs a 12*12 block to the screen by looking up in 
; a database characters_and_pieces.asm
;********************************************************************

CharOut:
			  push rTemp1
			  push rTemp2
			  push rTemp3
			  push rPage
			  push rColumn
			  push ZH
			  push ZL

              mov rTemp1,rPage
			  subi rTemp1,-3  ; Set maximum to rPage +3 (3*4 pixels)

			  mov rTemp2,rColumn
			  mov rTemp3,rColumn
			  subi rTemp3,-12 ; Set maximum to rColumn +12 (12 pixels)
			  
			  ; Output the character here
			  LoopPageChar:
				mov	rColumn,rTemp2
	
				  LoopColChar:
					lpm rByteLCD , Z+ ; Point to the character that is to be outputted 
										; and increment pointer
					rcall	fcSetCurrentLCDAddress
					rcall	fcSendDataToLCD
					inc		rColumn
					cp		rColumn, rTemp3
					brne	LoopColChar ; Only leave loop if column maximum is reached
		
				inc		rPage
				cp		rPage, rTemp1
				brlo	LoopPageChar ; Only leave loop if page max is reached

				pop rTemp1
				pop rTemp2
				pop rTemp3
				pop rPage
			  	pop rColumn
			  	pop ZH
			  	pop ZL
				     
				ret
;********************************************************************
; Subroutine which sends a byte to the LCD from fcSendData/CommandToLCD
; starting with the MSB. The data is sent on the rising edge of
; the clock. The byte sent to the display is contained in rByteLCD.
;********************************************************************
fcByteToLCD:
	PUSH	rByteLCD
	PUSH	rCount

	LDI 	rCount, 8
LoopBitToLCD:
	rcall mDelay5us
	CBI		PORTDOGLCD, PinSCK ; Clear clock bit
	CBI		PORTDOGLCD, PinSDA ; Clear data bit
	LSL 	rByteLCD 
	BRCC	LoopBit ; go to loop bit if carry cleared
	SBI		PORTDOGLCD, PinSDA ; else set bit on data pin
LoopBit:
	rcall	mDelay10us
	SBI		PORTDOGLCD, PinSCK ; send bit to screen by setting clock pin
	DEC		rCount
	CPI		rCount, 0
	BRNE	LoopBitToLCD ; do for all 8 bits

EndByteToLCD:
	rcall mDelay5us
	CBI		PORTDOGLCD, PinSCK

	POP		rCount
	POP		rByteLCD

	RET
;--------------------------------------------------------------------

;********************************************************************
;Subroutine which sends a command to the display
;The byte is contained in rByteLCD
;********************************************************************
fcSendCommandToLCD:
	CBI		PORTDOGLCD, PinCS		;Chip select
	rcall	mDelay10us
	CBI		PORTDOGLCD, PinCD
	rcall	mDelay10us
	RCALL	fcByteToLCD
	rcall	mDelay10us
	SBI		PORTDOGLCD, PinCS		;Chip "deselect"
	
	RET
;--------------------------------------------------------------------

;********************************************************************
;Subroutine which sends a data byte to the LCD
;The byte is contained in rByteLCD
;********************************************************************
fcSendDataToLCD:
	CBI		PORTDOGLCD, PinCS		;Chip select
	rcall	mDelay5us
	SBI		PORTDOGLCD, PinCD
	rcall	mDelay5us
	RCALL	fcByteToLCD
	rcall	mDelay5us
	SBI		PORTDOGLCD, PinCS		;Chip "deselct"
	
	RET
;--------------------------------------------------------------------


;********************************************************************
;Erase Diplay
;********************************************************************
fcEraseDisplay:
	CLR		rPage

LoopErase_1:
	CLR		rColumn
	RCALL	fcSetCurrentLCDAddress	
LoopErase_2:
	CLR		rByteLCD
	RCALL	fcSendDataToLCD
	INC		rColumn
	CPI		rColumn, cNumColumnsLCD
	BRNE	LoopErase_2

	INC		rPage
	CPI		rPage, cNumPagesLCD

	BRNE	LoopErase_1

EndEraseDisplay:
	RET
;--------------------------------------------------------------------

;*********************************************************************
;Check if the square has an odd or even address (sum of the coordinates)
;*********************************************************************

odd_or_even:
push rTemp2

push r17
andi r17, 0b00001111
mov rTemp2, r17
pop r17
lsr r17
lsr r17
lsr r17
lsr r17
add r17,rTemp2
andi r17,$01
cpi r17,1 ;skip if sum is even
breq end_bin

ldi r17,$00
pop rTemp2
ret

end_bin:
ldi r17,$10
pop rTemp2
ret
