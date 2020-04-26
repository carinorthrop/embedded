; *** *** *** *** *** *** *** *** *** *** *** *** ***
; *** Final Project 			Due: 05/01/2020
; *** Sydney O'Connor, Caroline Northrop, JT Salisbury 
; ***
; *** need a description of this project here 

; P2 = command
; P1.0 = Enable
; P1.1 = R/W
; P1.2 = RS

command equ 40h
text equ 41h

decimalCount equ 42h
onesCount equ 43h
tensCount equ 44h

InitializeLCD:
	mov tmod, #01h ; timer 0 mode 1
	;lcall initDelay ; commented out because i don't want to wait
	mov command, #38h ; set function
	lcall writeCmd
	mov command, #0Fh ; set data pattern
	lcall writeCmd
	mov command, #01h ; clear display
    	lcall writeCmd
    	mov command, #06h ; auto advance cursor
	lcall writeCmd
	mov command, #0Fh ; turn on display
	lcall writeCmd

; Main
main:
	clr P3.0
	setb P1.4 ; start
	setb P1.5 ; lap
	setb P1.6 ; stop
	setb P1.7 ; reset

	jnb P1.4, handleStart
	jnb P1.5, handleLap
	jnb P1.6, handleStop
	jnb P1.7, handleReset

handleStart:

	sjmp main

handleLap:

	sjmp main

handleStop:

	sjmp main

handleReset:

	sjmp main


; Utility 
writeCmd:
	mov P0, command
	clr P1.2 ; clear RS
	clr P1.1 ; clear R/W
	lcall LCDclock
	ret
	
Writehar:
	mov P0, #00110000b
	setb P1.2 ; set RS
	clr P1.1 ; clear R/W
	lcall LCDclock
	ret

LCDclock:
	setb P1.0 ; enable
	nop
	clr P1.0 ; disable
	nop
	setb P1.0 ; enable it
	nop
	nop
	nop
	ret

initDelay:
	clr TF0
	clr TR0
	mov TH0, #3Ch
	mov TL0, #0AFh
	setb TR0
	delayLoop: 
		jnb TF0, delayLoop
	clr TR0
	clr TF0
	ret










; !!! Do not let program flow after here! 
; !!! Lookup table for display 
table:
	;		MSB						LSB
	;		g	f	e	d	c	b	a
.db 3FH	;	0	0	1	1	1	1	1	1	0x3F
.db 06H	;	1	0	0	0	0	1	1	0	0x06
.db 5BH	;	2	1	0	1	1	0	1	1	0x5B
.db 4FH	;	3	1	0	0	1	1	1	1	0x4F
.db 66H	;	4	1	1	0	0	1	1	0	0x66
.db 6DH	;	5	1	1	0	1	1	0	1	0x6D
.db 7CH	;	6	1	1	1	1	1	0	0	0x7C
.db 07H	;	7	0	0	0	0	1	1	1	0x07
.db 7FH	;	8	1	1	1	1	1	1	1	0x7F
.db 6FH	;	9	1	1	0	1	1	1	1	0x6F
.db 77H	;	A	1	1	1	0	1	1	1	0x77
.db 7CH	;	b	1	1	1	1	1	0	0	0x7C
.db 39H	;	c	0	0	0	1	1	1	1	0x0F (*)
.db 5EH ;	d	1	0	1	1	1	1	0	0x7E (*)
.db 79H	;	E	1	1	1	1	0	0	1	0x79
.db 71H	;	F	1	1	1	0	0	0	1	0x71
.db 0FFH ; just in case value. This should never be read back from a MOVC.

; !!! Also very important: Do not walk off the lookup table!
; !!! The returned result will be undefined. 
.end
