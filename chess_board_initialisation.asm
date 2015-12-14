;*********************************************************************************************
;*********************************************************************************************
;***************************** Chess Board Initialisation ************************************
;*********************************************************************************************
;*********************************************************************************************
; Author: Richard Flint
; Date: 27/02/2015
;**********************************************************************************************
; This initialises the chess board either as a new game, or loads the positions of previous game
;**********************************************************************************************
chess_board_initialisation:
push r20
;
rcall CLRDIS
rcall MessLoadOut						;"Do you want to load previous game? (Y/N)"
loading_game_loop:						;Loop until user presses either [Y] or [N]
	in r20,pind
	com r20
	cpi r20,$10							;If presses $10 = N
	breq chess_piece_positions_new_game	;branch to new game positions 
	cpi r20,$08							;If presses $08 = Y
	brne loading_game_loop				;branch to load previous game
	jmp load_previous_game

chess_piece_positions_new_game:			;new game routine places pieces in starting positions
ldi r25,$01	  ;white to play first
;
			  ;black pieces at the bottom
ldi r20,$C1
sts $0112,r20 ;black pawn
sts $0122,r20 ;black pawn
sts $0132,r20 ;black pawn
sts $0142,r20 ;black pawn
sts $0152,r20 ;black pawn
sts $0162,r20 ;black pawn
sts $0172,r20 ;black pawn
sts $0182,r20 ;black pawn
;
ldi r20,$C4
sts $0111,r20 ;black castle
sts $0181,r20 ;black castle
;
ldi r20,$C2
sts $0121,r20 ;black knight
sts $0171,r20 ;black knight
;
ldi r20,$C3
sts $0131,r20 ;black bishop
sts $0161,r20 ;black bishop
;
ldi r20,$C5
sts $0151,r20 ;black queen
;
ldi r20,$C6
sts $0141,r20 ;black king
;
; White pieces at the top
ldi r20,$81
sts $0117,r20 ;white pawn
sts $0127,r20 ;white pawn
sts $0137,r20 ;white pawn
sts $0147,r20 ;white pawn
sts $0157,r20 ;white pawn
sts $0167,r20 ;white pawn
sts $0177,r20 ;white pawn
sts $0187,r20 ;white pawn
;
ldi r20,$84
sts $0118,r20 ;white castle
sts $0188,r20 ;white castle
;
ldi r20,$82
sts $0128,r20 ;white knight
sts $0178,r20 ;white knight
;
ldi r20,$83
sts $0138,r20 ;white bishop
sts $0168,r20 ;white bishop
;
ldi r20,$85
sts $0158,r20 ;white queen
;
ldi r20,$86
sts $0148,r20 ;white king

; the rest of the spaces clear (this is just to make sure!)
ldi r20,$00
sts $0113,r20
sts $0114,r20
sts $0115,r20
sts $0116,r20
sts $0123,r20
sts $0124,r20
sts $0125,r20
sts $0126,r20
sts $0133,r20
sts $0134,r20
sts $0135,r20
sts $0136,r20
sts $0143,r20
sts $0144,r20
sts $0145,r20
sts $0146,r20
sts $0153,r20
sts $0154,r20
sts $0155,r20
sts $0156,r20
sts $0163,r20
sts $0164,r20
sts $0165,r20
sts $0166,r20
sts $0173,r20
sts $0174,r20
sts $0175,r20
sts $0176,r20
sts $0183,r20
sts $0184,r20
sts $0185,r20
sts $0186,r20
;
pop r20
rcall CLRDIS
rcall MessNewGameStartOut		;"New game.Press enter to continue"
;
push r20						;Loop until user presses [enter]
startloop:
in r20,pind
com r20
cpi r20,$02
brne startloop
pop r20
ret
;
load_previous_game:
pop r20				;saved game will still be in SRAM so don't need to do anything
ret
;
