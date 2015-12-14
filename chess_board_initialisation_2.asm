;*********************************************************************************************
;*********************************************************************************************
;***************************** Chess Board Initialisation ************************************
;*********************************************************************************************
;*********************************************************************************************
;
;Initialises the chess board with pieces scattered about. It is used in debugging and checking
;the results of the code
;
;*********************************************************************************************
;
chess_board_initialisation_2:
push r20
;
rcall CLRDIS
;
chess_piece_positions_new_game_2:
ldi r20,$00
sts $0111,r20
sts $0112,r20
sts $0113,r20
ldi r20,$81
sts $0114,r20	;white pawn
ldi r20,$00
sts $0115,r20
sts $0116,r20
ldi r20,$84		
sts $0117,r20	;white castle
ldi r20,$00
sts $0118,r20
;
sts $0121,r20
sts $0122,r20
ldi r20,$C1
sts $0123,r20	;black pawn
ldi r20,$00
sts $0124,r20
sts $0125,r20
sts $0126,r20
sts $0127,r20
sts $0128,r20
;
sts $0131,r20
sts $0132,r20
sts $0133,r20
ldi r20,$81
sts $0134,r20	;white pawn
ldi r20,$00
sts $0135,r20
sts $0136,r20
sts $0137,r20
sts $0138,r20
;
sts $0141,r20
ldi r20,$C6
sts $0142,r20	;black king
ldi r20,$00
sts $0143,r20
sts $0144,r20
sts $0145,r20
sts $0146,r20
sts $0147,r20
sts $0148,r20
;
sts $0151,r20
ldi r20,$C5
sts $0152,r20	;black queen
ldi r20,$00
sts $0153,r20
ldi r20,$85
sts $0154,r20
ldi r20,$00
sts $0155,r20
sts $0156,r20
sts $0157,r20
sts $0158,r20
;
ldi r20,$C3
sts $0161,r20	;black bishop
ldi r20,$00
sts $0162,r20
sts $0163,r20
sts $0164,r20
sts $0165,r20
sts $0166,r20
sts $0167,r20
sts $0168,r20
;
sts $0171,r20
sts $0172,r20
sts $0173,r20
ldi r20,$C2
sts $0174,r20	;black knight
ldi r20,$00
sts $0175,r20
sts $0176,r20
sts $0177,r20
sts $0178,r20
;
sts $0181,r20
sts $0182,r20
sts $0183,r20
sts $0184,r20
sts $0185,r20
ldi r20,$C4
sts $0186,r20	;black castle
ldi r20,$00
sts $0187,r20
sts $0188,r20
;
pop r20
;
ret
