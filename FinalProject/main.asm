;
; FinalProject.asm
;
; Created: 12/13/2020 11:42:12 PM
; Author : BahaaAY
;

.ORG 0X00
TempWord:
	.db 'T','e','m','p','e','r','a','t','u','r','e',':'
HumWord:
	.db 'H','u','m','i','d','i','t','y',' ',' ',' ',':'
Main:

	LDI R18, HIGH(RAMEND)
	OUT SPH, R18	
	LDI R19, LOW(RAMEND)
	OUT SPL, R19
	CALL Delay_18ms								;Wait for LCD to Power On

LoopAutoRefresh:
	CALL INIT									;Initialize Ports
	CALL InitLCD								;Initialize LCD
	CALL CONV									;Get Humidity + Temp Data
	CALL SEND_HW
	CALL WriteH
	CALL toAsciiDH
	CALL SEND_TW
	CALL WRITET	
	CALL Delay_3s
	RJMP LoopAutoRefresh

LoopM:
	RJMP LoopM
INIT:
	LDI R16, 0XFF
	OUT DDRD, R16
	CBI DDRB, 0
	SBI DDRC,0
	SBI DDRC,1
	SBI DDRC,2
	RET

CONV:
	CBI PORTC, 2
	CALL Delay_18ms
	SBI PORTC, 2
	
	CBI PORTC, 2
	CBI DDRC,2
	CALL Delay_30us
	CALL Delay_80us
	CALL Delay_80us
	CALL Delay_50us

LoopConv:
	SBIS PINC,2
	RJMP LoopConv
	CALL sIRH
	CALL sDRH
	CALL sIT
	CALL toAsciiH								;Transform Humidity value to Ascii 	
	CALL toAsciiT

	RET
sIRH:
	LDI R18, 9

LoopIRH:
	DEC R18
	CPI R18,0
	BREQ DoneIRH
LIRH:
	SBIS PINC,2
	RJMP LIRH
	CALL Delay_30us
	SBIS PINC,2
	RJMP Save0H
	RJMP Save1H 
Save0H:

	LSL R25
	CBR R25,1


Ls0H:
	SBIS PINC,2
	RJMP LoopIRH
	RJMP Ls0H

Save1H:
	LSL R25
	SBR R25,1

Ls1H:
	SBIS PINC,2
	RJMP LoopIRH
	RJMP Ls1H


DoneIRH:
	MOV R16, R25
	RET
;========================================
;=========================================

sDRH:
	LDI R18, 9

LoopDRH:
	DEC R18
	CPI R18,0
	BREQ DoneDRH
LDRH:
	SBIS PINC,2
	RJMP LDRH
	CALL Delay_30us
	SBIS PINC,2
	RJMP Save0DH
	RJMP Save1DH 
Save0DH:

	LSL R22
	CBR R22,1


Ls0DH:
	SBIS PINC,2
	RJMP LoopDRH
	RJMP Ls0DH

Save1DH:
	LSL R22
	SBR R22,1

Ls1DH:
	SBIS PINC,2
	RJMP LoopDRH
	RJMP Ls1DH


DoneDRH:
	RET
;========================================================================================================================================================;
sIT:
	LDI R18, 9

LoopIT:
	DEC R18
	CPI R18,0
	BREQ DoneIT
LIT:
	SBIS PINC,2
	RJMP LIT
	CALL Delay_30us
	SBIS PINC,2
	RJMP Save0T
	RJMP Save1T 
Save0T:

	LSL R24
	CBR R24,1


Ls0T:
	SBIS PINC,2
	RJMP LoopIT
	RJMP Ls0T

Save1T:
	LSL R24
	SBR R24,1

Ls1T:
	SBIS PINC,2
	RJMP LoopIT
	RJMP Ls1T


DoneIT:
	RET

SEND_TW:
	LDI ZL,LOW(2*TempWord)
	LDI ZH, HIGH(2*TempWord)
LoopT:
	LPM R16, Z+
	CALL SEND_L
	CPI R16, ':'
	BRNE LoopT
	RET
SEND_HW:
	LDI ZL,LOW(2*HumWord)
	LDI ZH, HIGH(2*HumWord)
LoopH:
	LPM R16, Z+
	CALL SEND_L
	CPI R16, ':'
	BRNE LoopH
	RET
InitLCD:
	LDI R16, 0X01
	CALL SEND_C
	LDI R16, 0X38
	CALL SEND_C 
	LDI R16, 0X0F
	CALL SEND_C 
	RET
SEND_C:
	OUT PORTD, R16
	CBI PORTC,1
	SBI PORTC,0
	CBI PORTC,0
	CALL Delay_50us
	CALL Delay_50us
	RET

SEND_L:
	OUT PORTD, R16
	SBI PORTC,1
	SBI PORTC,0
	CBI PORTC,0
	CALL Delay_50us
	CALL Delay_50us
	RET

toAsciiH:
 	MOV R16, R25
HEX_to_BCDH:
    CLR     r17            ; clear register help
HEX_to_BCD_lH: 
    SUBI    r16,10         ; temp = temp — 10
    BRCS    HEX_to_BCD_2H   ; Abort if the transfer set
    INC     r17            ; Increment r17	
    RJMP    HEX_to_BCD_lH   ; We pass on the testing cycle again
HEX_to_BCD_2H: 
    SUBI    r16,-10        ; compensate a negative value in r16
    SWAP    r17            ; Change tetrad places
    OR	    r16,r17        ; Combine the received values in a packed BCD
BCDtoAsciiH:
	LDI R17, 0X30
	MOV R1, R16
	ANDI R16, 0XF0
	LSR R16
	LSR R16
	LSR R16
	LSR R16
	ADD R16, R17
	MOV R26, R16
	MOV R16,R1
	ANDI R16, 0X0F
	ADD R16, R17
	MOV R27, R16
    RET

toAsciiDH:
 	MOV R16, R22
HEX_to_BCDDH:
    CLR     r17            ; clear register help
HEX_to_BCD_lDH: 
    SUBI    r16,10         ; temp = temp — 10
    BRCS    HEX_to_BCD_2DH   ; Abort if the transfer set
    INC     r17            ; Increment r17	
    RJMP    HEX_to_BCD_lDH   ; We pass on the testing cycle again
HEX_to_BCD_2DH: 
    SUBI    r16,-10        ; compensate a negative value in r16
    SWAP    r17            ; Change tetrad places
    OR	    r16,r17        ; Combine the received values in a packed BCD
BCDtoAsciiDH:
	LDI R17, 0X30
	MOV R1, R16
	ANDI R16, 0XF0
	LSR R16
	LSR R16
	LSR R16
	LSR R16
	ADD R16, R17
	MOV R26, R16
	MOV R16,R1
	ANDI R16, 0X0F
	ADD R16, R17
	MOV R27, R16
    RET

toAsciiT:
 	MOV R16, R24
HEX_to_BCDT:
    CLR     r17            ; clear register help
HEX_to_BCD_lT: 
    SUBI    r16,10         ; temp = temp — 10
    BRCS    HEX_to_BCD_2T   ; Abort if the transfer set
    INC     r17            ; Increment r17	
    RJMP    HEX_to_BCD_lT   ; We pass on the testing cycle again
HEX_to_BCD_2T: 
    SUBI    r16,-10        ; compensate a negative value in r16
    SWAP    r17            
    OR	    r16,r17        ; Combine the received values in a packed BCD
BCDtoAscii:
	LDI R17, 0X30
	MOV R1, R16
	ANDI R16, 0XF0
	LSR R16
	LSR R16
	LSR R16
	LSR R16
	ADD R16, R17
	MOV R28, R16
	MOV R16,R1
	ANDI R16, 0X0F
	ADD R16, R17
	MOV R29, R16
    RET

WriteH:
	MOV R16, R26
	CALL SEND_L
	MOV R16, R27
	CALL SEND_L
	LDI R16, ' '
	CALL SEND_L
	LDI R16, '%'
	CALL SEND_L
	LDI R16, 0XC0
	CALL SEND_C
	RET
WriteDH:
	MOV R16, R26
	CALL SEND_L
	MOV R16, R27
	CALL SEND_L
	LDI R16, '%'
	CALL SEND_L

	RET
WriteT:
	MOV R16, R28
	CALL SEND_L
	MOV R16, R29
	CALL SEND_L
	LDI R16, ' '
	CALL SEND_L
	LDI R16, 'C'
	CALL SEND_L
	RET


Delay_18ms:
	LDI R23, 0XEE
	STS TCNT1H, R23
	LDI R23, 0X6C
	STS TCNT1L, R23
	LDI R23,0
	STS TCCR1A, R23
	LDI R23, 3
	STS TCCR1B, R23
again18ms:
	SBIS TIFR1, TOV1
	RJMP again18ms
	LDI R23,0 
	STS TCCR1B, R23
	LDI R23, 1
	OUT TIFR1, R23 
	RET
Delay_40us:
	LDI R23, 0XFF
	STS TCNT1H, R23
	LDI R23, 0XF6
	STS TCNT1L, R23
	LDI R23,0
	STS TCCR1A, R23
	LDI R23, 3
	STS TCCR1B, R23
again40us:
	SBIS TIFR1, TOV1
	RJMP again40us
	LDI R23,0 
	STS TCCR1B, R23
	LDI R23, 3
	OUT TIFR1, R23 
	RET
Delay_50us:
	LDI R23, 0XFF
	STS TCNT1H, R23
	LDI R23, 0XF3
	STS TCNT1L, R23
	LDI R23,0
	STS TCCR1A, R23
	LDI R23, 3
	STS TCCR1B, R23
again50us:
	SBIS TIFR1, TOV1
	RJMP again50us
	LDI R23,0 
	STS TCCR1B, R23
	LDI R23, 3
	OUT TIFR1, R23 
	RET	
Delay_30us:
	LDI R23, 0XFF
	STS TCNT1H, R23
	LDI R23, 0XF8
	STS TCNT1L, R23
	LDI R23,0
	STS TCCR1A, R23
	LDI R23, 3
	STS TCCR1B, R23
again30us:
	SBIS TIFR1, TOV1
	RJMP again30us
	LDI R23,0 
	STS TCCR1B, R23
	LDI R23, 3
	OUT TIFR1, R23 
	RET	
Delay_80us:
	LDI R23, 0XFF
	STS TCNT1H, R23
	LDI R23, 0XEC
	STS TCNT1L, R23
	LDI R23,0
	STS TCCR1A, R23
	LDI R23, 3
	STS TCCR1B, R23
again80us:
	SBIS TIFR1, TOV1
	RJMP again80us
	LDI R23,0 
	STS TCCR1B, R23
	LDI R23, 3
	OUT TIFR1, R23 
	RET	
Delay_3s:
	LDI R23, 0X38
	STS TCNT1H, R23
	LDI R23, 0XAF
	STS TCNT1L, R23
	LDI R23,0
	STS TCCR1A, R23
	LDI R23, 5
	STS TCCR1B, R23
again3s:
	SBIS TIFR1, TOV1
	RJMP again3s
	LDI R23,0 
	STS TCCR1B, R23
	LDI R23, 3
	OUT TIFR1, R23 
	RET	

	
