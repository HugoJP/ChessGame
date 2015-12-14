;************************************************************************************************
;************************************************************************************************
;************************* Alphanumeric Display Initialisation **********************************
;************************************************************************************************
;************************************************************************************************
; Display Initialization routine
;
; This is just the inialisation routine provided in the Microprocessors lecture notes/files
;
;************************************************************************************************
alphanum_lcd_initialisation:		
		CALL DEL15ms                	; wait 15ms for things to relax after power up           
		ldi r16,    $30	         		; Hitachi says do it...
		sts   $8000,r16                 ; so i do it....
		CALL DEL4P1ms             		; Hitachi says wait 4.1 msec
		sts   $8000,r16	        	 	; and again I do what I'm told
		call DEL100mus                 ; wait 100 mus
		sts   $8000,r16	         		; here we go again folks
                call busylcd		
		ldi r16, $3F	         		; Function Set : 2 lines + 5x7 Font
		sts  $8000,r16
                call busylcd
		ldi r16,  $08	         		;display off
		sts  $8000, r16
                call busylcd		
		ldi r16,  $01	         		;display on
		sts  $8000,  r16
                call busylcd
                ldi r16, $38	        ;function set
		sts  $8000, r16
		call busylcd
		ldi r16, $0E	        		;display on
		sts  $8000, r16
		call busylcd
		ldi r16, $06                    ;entry mode set increment no shift
		sts  $8000,  r16
                call busylcd
                clr r16
				ret
;
;**********************************************************************************
; This clears the display so we can start all over again
;
CLRDIS:
	    push r16
		ldi r16,$01		; Clear Display and send cursor 
		sts $8000,r16   ; to the most left position
		call busylcd
		pop r16
        ret
;
;**********************************************************************************
; A routine the probes the display BUSY bit
;

;busylcd: 
;
;Revised 1/2/05 according to comment from John Jones and
; Nicolas Osman
;   
busylcd:
		push r16
		busylcdloop:       
		lds r16, $8000   ;access 
        sbrc r16, 7      ;check busy bit  7
        rjmp busylcdloop
        call DEL100mus
		pop r16
		ret              ;return if clear
;
;
;*************************************************************************************
