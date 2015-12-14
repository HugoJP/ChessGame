;**********************************************************************************************
;**********************************************************************************************
;************************************** DELAY ROUTINES ****************************************
;**********************************************************************************************
;**********************************************************************************************
;These delay routines come from the sample code for the Microprocessor course. It is possible
;that the delay times do not match the time estimation given. For example, the routine Del49ms
;may not match a 149ms delay. This is because the delay codes were written for a different
;microprossor. There is no requirement for strict timing/delays in the coding of the chess rules,
;so any discrepancy is not very important.
;**********************************************************************************************
BigDEL:
             rcall Del49ms
             rcall Del49ms
             rcall Del49ms
             rcall Del49ms
             rcall Del49ms
             ret
BigBigDEL:
             rcall BigDEL
             rcall BigDEL
			 rcall BigDEL
			 rcall BigDEL
			 rcall BigDEL
			 rcall BigDEL
             ret
;
DEL15ms:
			push XH
			push XL

            LDI XH, HIGH(19997)
            LDI XL, LOW (19997)
COUNT:  
            SBIW XL, 1
            BRNE COUNT
;
			pop XL
			pop XH
            RET
;
DEL4P1ms:
            push XH
			push XL
			
			LDI XH, HIGH(5464)
            LDI XL, LOW (5464)
COUNT1:
            SBIW XL, 1
            BRNE COUNT1
            ;
			pop XL
			pop XH
			RET 
;
DEL100mus:
            push XH
			push XL
			
			LDI XH, HIGH(131)
            LDI XL, LOW (131)
COUNT2:
            SBIW XL, 1
            BRNE COUNT2
            ;
			pop XL
			pop XH
			RET 
;
DEL49ms:
            push XH
			push XL
			;
			LDI XH, HIGH(65535)
            LDI XL, LOW (65535)
COUNT3:
            SBIW XL, 1
            BRNE COUNT3
            
			pop XL
			pop XH
			RET 
			;
;**********************************************************************************************