;*************************************************************************
;************************* Change colour *********************************
;*************************************************************************
; Author: Richard Flint
; Date: 27/02/2015
;*************************************************************************
; A short routine that changes the colour of the piece to be moved.
; This is used in checking whether the movement is valid.
;
; This is not a stand alone code. It must be included in the main program.
;*************************************************************************
change_colour:
cpi r25,$01				;Has white just moved?
breq change_to_black	;If so, then change to black
ldi r25,$01				;If not, then change to white
ret
;
change_to_black:
ldi r25,$10				;Change to black
ret
;
;*************************************************************************
