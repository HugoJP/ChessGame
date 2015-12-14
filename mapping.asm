;************************************************************************************************
;************************************************************************************************
;********************************* MAPPING  *****************************************************
;************************************************************************************************
;************************************************************************************************
;Author: Richard Flint
;Date: 1/3/2015
;
;*****************************************************************************
;********************   Keyboard to ASCII mapping ****************************
;*****************************************************************************
;
; This works as a systematic look-up table that takes the 16 bit
; binary number saved from the keyboard input, and converts it into the associated
; ASCII values. This is output on the alphanumeric display.
;
;*****************************************************************************
keyboard_to_ASCII_letter:
		cpi r20,$EE
		breq letterA
		cpi r20,$ED
		breq letterB
		cpi r20,$EB
		breq letterC
		cpi r20,$E7
		breq letterD
		cpi r20,$DE
		breq letterE
		cpi r20,$DD
		breq letterF
		cpi r20,$DB
		breq letterG
		cpi r20,$D7
		breq letterH
		;
		letterA:
		ldi r20,$41
		ret
		letterB:
		ldi r20,$42
		ret
		letterC:
		ldi r20,$43
		ret
		letterD:
		ldi r20,$44
		ret
		letterE:
		ldi r20,$45
		ret
		letterF:
		ldi r20,$46
		ret
		letterG:
		ldi r20,$47
		ret
		letterH:
		ldi r20,$48
		ret
		;
keyboard_to_ASCII_number:
		cpi r20,$BE
		breq number1
		cpi r20,$BD
		breq number2
		cpi r20,$BB
		breq number3
		cpi r20,$B7
		breq number4
		cpi r20,$7E
		breq number5
		cpi r20,$7D
		breq number6
		cpi r20,$7B
		breq number7
		cpi r20,$77
		breq number8
		;
		number1:
		ldi r20,$31
		ret
		number2:
		ldi r20,$32
		ret
		number3:
		ldi r20,$33
		ret
		number4:
		ldi r20,$34
		ret
		number5:
		ldi r20,$35
		ret
		number6:
		ldi r20,$36
		ret
		number7:
		ldi r20,$37
		ret
		number8:
		ldi r20,$38
		ret
;
;
;
;*****************************************************************************
;************************* ASCII to coordinate mapping ***********************
;*****************************************************************************
;
;This works as a systematic look-up table that takes the ASCII coordinates,
;and converts to the associated coordinate on the chess board. This coordinate
;system is defined in the report. For example, B3 corresponds to $0123.
;
;*****************************************************************************
ascii_to_coordinate_mapping:
cpi XH,$41
breq A_to_10
cpi XH,$42
breq B_to_20
cpi XH,$43
breq C_to_30
cpi XH,$44
breq D_to_40
cpi XH,$45
breq E_to_50
cpi XH,$46
breq F_to_60
cpi XH,$47
breq G_to_70
cpi XH,$48
breq H_to_80
ret
;
A_to_10:
ldi XH,$10
rjmp number_mapping
B_to_20:
ldi XH,$20
rjmp number_mapping
C_to_30:
ldi XH,$30
rjmp number_mapping
D_to_40:
ldi XH,$40
rjmp number_mapping
E_to_50:
ldi XH,$50
rjmp number_mapping
F_to_60:
ldi XH,$60
rjmp number_mapping
G_to_70:
ldi XH,$70
rjmp number_mapping
H_to_80:
ldi XH,$80
rjmp number_mapping
;
number_mapping:
cpi XL,$31
breq one_to_01
cpi XL,$32
breq two_to_02
cpi XL,$33
breq three_to_03
cpi XL,$34
breq four_to_04
cpi XL,$35
breq five_to_05
cpi XL,$36
breq six_to_06
cpi XL,$37
breq seven_to_07
cpi XL,$38
breq eight_to_08
ret
;
one_to_01:
ldi XL,$01
rjmp combine_coordinates
two_to_02:
ldi XL,$02
rjmp combine_coordinates
three_to_03:
ldi XL,$03
rjmp combine_coordinates
four_to_04:
ldi XL,$04
rjmp combine_coordinates
five_to_05:
ldi XL,$05
rjmp combine_coordinates
six_to_06:
ldi XL,$06
rjmp combine_coordinates
seven_to_07:
ldi XL,$07
rjmp combine_coordinates
eight_to_08:
ldi XL,$08
rjmp combine_coordinates
;
combine_coordinates:
add XL,XH
ldi XH,$00
ret
;
;*****************************************************************************
