;************************************************************************************************
;************************* Messages *************************************************************
;************************************************************************************************			
;
; These messages are used in the the main function and other included routines
;
; *********************** Define messages in program memory *************************************
Mess1:
	.db "Input letter: ",0
Mess2:
	.db "Press enter/delete",0
Mess3:
	.db "Input number: ",0
Mess4:
	.db "Your coordinate: ",0
Mess6:
	.db "Confirm? (Y/N)",0
Mess7:
	.db "Your move has been  made! Next turn...",0
Mess8:
	.db "Are you sure you    want to exit? (Y/N)",0
Mess1spaces:
	.db " ",0
Mess5spaces:
	.db "     ",0
MessError:
	.db "Error!",0
MessGameSaved:
	.db "Exit complete!",0
MessNoPieces:
	.db "No piece selected.  Press enter to retry",0
MessLoad:
	.db "Do you want to load previous game? (Y/N)",0
MessNewGameStart:
	.db "New game.Press enter to continue",0
MessSelectWhitePiece:
	.db "WHITE: Select your  piece...",0
MessSelectBlackPiece:
	.db "BLACK: Select your  piece...",0
MessSelectDestination:
	.db "Select move...",0
MessInvalidMove:
	.db "Move not valid.Press enter to try again",0
MessValidMove:
	.db "Move is valid. Press enter to continue",0
MessWrongColour:
	.db "You selected  wrong colour. Try again.",0
MessTurnOff:
	.db "Turn game off.",0
MessStartNewGame:
	.db "Do you want to start a new game? (Y/N)",0
MessWhiteWin:
	.db "WHITE WIN!!!!!!",0
MessBlackWin:
	.db "BLACK WIN!!!!!!",0
MessProgess:
	.db "You have got this far!",0
MessButtonError:
	.db "ERROR! Please hold  button longer!",0
MessPressAgain:
	.db "Press again:  ",0
MessPressESC:
	.db "Press ESC to exit   demo",0
MessDemoQuestion:
	.db "Do you want to play    chess? (Y/N)",0
; ******************* Message output routines **********************************
Mess1out:
	push ZH
	push ZL
	push r17
	;			
	LDI ZH, HIGH(2*Mess1)
	LDI ZL, LOW(2*Mess1)
	rjmp MessLoop
;
Mess2out:
	push ZH
	push ZL
	push r17
	;
	LDI ZH, HIGH(2*Mess2)
	LDI ZL, LOW(2*Mess2)
	rjmp MessLoop
;
Mess3out:
	push ZH
	push ZL
	push r17
	;
	LDI ZH, HIGH(2*Mess3)
	LDI ZL, LOW(2*Mess3)
	rjmp MessLoop
;
Mess4out:
	push ZH
	push ZL
	push r17
	;
	LDI ZH, HIGH(2*Mess4)
	LDI ZL, LOW(2*Mess4)
	rjmp MessLoop
	;		
Mess6out:
	push ZH
	push ZL
	push r17
	;
	LDI ZH, HIGH(2*Mess6)
	LDI ZL, LOW(2*Mess6)
	rjmp MessLoop
	;		
Mess7out:
	push ZH
	push ZL
	push r17
	;
	LDI ZH, HIGH(2*Mess7)
	LDI ZL, LOW(2*Mess7)
	rjmp MessLoop
;
Mess8out:
	push ZH
	push ZL
	push r17
	;
	LDI ZH, HIGH(2*Mess8)
	LDI ZL, LOW(2*Mess8)
	rjmp MessLoop
;
MessNoPiecesOut:
	push ZH
	push ZL
	push r17
	;
	LDI ZH, HIGH(2*MessNoPieces)
	LDI ZL, LOW(2*MessNoPieces)
	rjmp MessLoop
;
Mess1spacesOut:
	push ZH
	push ZL
	push r17
	;
	LDI ZH, HIGH(2*Mess1spaces)
	LDI ZL, LOW(2*Mess1spaces)
	rjmp MessLoop
	;		
Mess5spacesOut:
	push ZH
	push ZL
	push r17
	;
	LDI ZH, HIGH(2*Mess5spaces)
	LDI ZL, LOW(2*Mess5spaces)
	rjmp MessLoop
	;	
MessGameSavedOut:
	push ZH
	push ZL
	push r17
	;
	LDI ZH, HIGH(2*MessGameSaved)
	LDI ZL, LOW(2*MessGameSaved)
	rjmp MessLoop
	;
MessLoadOut:
	push ZH
	push ZL
	push r17
	;
	LDI ZH, HIGH(2*MessLoad)
	LDI ZL, LOW(2*MessLoad)
	rjmp MessLoop
	;
MessNewGameStartOut:
	push ZH
	push ZL
	push r17
	;
	LDI ZH, HIGH(2*MessNewGameStart)
	LDI ZL, LOW(2*MessNewGameStart)
	rjmp MessLoop
	;
MessSelectWhitePieceOut:
	push ZH
	push ZL
	push r17
	;
	LDI ZH, HIGH(2*MessSelectWhitePiece)
	LDI ZL, LOW(2*MessSelectWhitePiece)
	rjmp MessLoop
	;
MessSelectBlackPieceOut:
	push ZH
	push ZL
	push r17
	;
	LDI ZH, HIGH(2*MessSelectBlackPiece)
	LDI ZL, LOW(2*MessSelectBlackPiece)
	rjmp MessLoop
	;
MessSelectDestinationOut:
	push ZH
	push ZL
	push r17
	;
	LDI ZH, HIGH(2*MessSelectDestination)
	LDI ZL, LOW(2*MessSelectDestination)
	rjmp MessLoop
	;
MessInvalidMoveOut:
	push ZH
	push ZL
	push r17
	;
	LDI ZH, HIGH(2*MessInvalidMove)
	LDI ZL, LOW(2*MessInvalidMove)
	rjmp MessLoop
	;			 
MessValidMoveOut:  
	push ZH
	push ZL
	push r17
	;
	LDI ZH, HIGH(2*MessValidMove)
	LDI ZL, LOW(2*MessValidMove)
	rjmp MessLoop 
;
MessWrongColourOut:
	push ZH
	push ZL
	push r17
	;
	LDI ZH, HIGH(2*MessWrongColour)
	LDI ZL, LOW(2*MessWrongColour)
	rjmp MessLoop 
;
MessTurnOffOut:
	push ZH
	push ZL
	push r17
	;
	LDI ZH, HIGH(2*MessTurnOff)
	LDI ZL, LOW(2*MessTurnOff)
	rjmp MessLoop 
;
MessStartNewGameOut:
	push ZH
	push ZL
	push r17
	;
	LDI ZH, HIGH(2*MessStartNewGame)
	LDI ZL, LOW(2*MessStartNewGame)
	rjmp MessLoop 
;
MessWhiteWinOut:
	push ZH
	push ZL
	push r17
	;
	LDI ZH, HIGH(2*MessWhiteWin)
	LDI ZL, LOW(2*MessWhiteWin)
	rjmp MessLoop 
;
MessBlackWinOut:
	push ZH
	push ZL
	push r17
	;
	LDI ZH, HIGH(2*MessBlackWin)
	LDI ZL, LOW(2*MessBlackWin)
	rjmp MessLoop 
;
MessProgessOut:
	push ZH
	push ZL
	push r17
	;
	LDI ZH, HIGH(2*MessProgess)
	LDI ZL, LOW(2*MessProgess)
	rjmp MessLoop 
;
MessButtonErrorOut:
	push ZH
	push ZL
	push r17
	;
	LDI ZH, HIGH(2*MessButtonError)
	LDI ZL, LOW(2*MessButtonError)
	rjmp MessLoop 
	;
;
MessPressAgainOut:
	push ZH
	push ZL
	push r17
	;
	LDI ZH, HIGH(2*MessPressAgain)
	LDI ZL, LOW(2*MessPressAgain)
	rjmp MessLoop 
;
MessPressESCOut:
	push ZH
	push ZL
	push r17
	;
	LDI ZH, HIGH(2*MessPressESC)
	LDI ZL, LOW(2*MessPressESC)
	rjmp MessLoop 
;
MessDemoQuestionOut:
	push ZH
	push ZL
	push r17
	;
	LDI ZH, HIGH(2*MessDemoQuestion)
	LDI ZL, LOW(2*MessDemoQuestion)
	rjmp MessLoop 
;; *********************** Message output loop *************************************
;
MessLoop:			; Loops until message has been outputted
	LPM r17 , Z+
	cpi r17, $00
	breq MessEnd
	sts $C000, r17
	push r16
	call busylcd
	pop r16
	RJMP MessLoop
MessEnd:     
	pop r17
	pop ZL
	pop ZH
	ret
;
;************************************************************************************
