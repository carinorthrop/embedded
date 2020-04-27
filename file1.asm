; *** *** *** *** *** *** *** *** *** *** *** *** ***
; *** Final Project 			Due: 05/01/2020
; *** Sydney O'Connor, Caroline Northrop, JT Salisbury 
; ***
; *** This program is an implementation of a basic stopwatch, using the 
; *** a matrix keypad and the LCD 2x16 bit display virtual hardware. 
; *** The stopwatch has 4 states: Reset, Stop, Lap, Start.
; *** Reset - Resets the counter display to zero, displays reset tag
; *** Stop - Stops the counter display, displays stop tag
; *** Lap - TODO 
; *** Start - Starts the counter display, displays start tag 

; P0 = command
; P1.0 = Enable
; P1.1 = R/W
; P1.2 = RS

; TODO: test lap, implement lap?? add real 1s delays

command equ 40h		; hold the command to be executed on the LCD
text equ 41h		; hold the value to be written to the LCD

decimalCount equ 42h	; initialize the counter values 
onesCount equ 43h
tensCount equ 44h

initProgram:
mov dptr, #Table ; set the lookup table
mov decimalCount, #00h	; the decimal counter
mov onesCount, #00h	; the ones counter
mov tensCount, #00h	; the tens counter

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
	clr P3.0		; P3.0 will control a row on the keypad
	setb P1.4 		; Start button
	setb P1.5 		; Lap button
	setb P1.6 		; Stop button
	setb P1.7 		; Reset button

	jnb P1.4, handleStart	; Jump to the start handler
	jnb P1.5, handleLap	; Jump to the lap handler
	jnb P1.6, handleStop	; Jump the stop handler
	jnb P1.7, handleReset	; Jump to the reset handler

handleStart:
	mov a, #0f7h 		; Set accum to 247
	add a, decimalCount	; Add the decimal count to accumulator
	jc testOnes		; Decimal is > 9, try to increase ones place
	jnc increaseDecimal	; Decimal is < 9, increase decimal

	testOnes:		; Test to see if ones place < 9
	mov a, #0f7h
	add a, onesCount
	jc testTens		; If we carry, then ones & decimal == 9, tst the tens place
	jnc increaseOnes	; If we don't carry, increment ones

	testTens:		; Test to see tens place is < 9
	mov a, #0f7h
	add a, tensCount
	jc zeroAll		; If it equals 9, then we should zero everything out
	jnc increaseTens	; If it is < 9, increment tens place

	increaseDecimal:	; Increment the decimal place
	mov a, decimalCount	; Add one to the count
	add a, #01h
	mov decimalCount, a	; Move incremented value back
	lcall printNums		; Print the numbers
	ljmp printStart		; Print the state

	increaseOnes:		; Increment the ones place
	mov a, onesCount
	add a, #01h
	mov onesCount, a	; Move incremented value back
	mov decimalCount, #00h	; Zero out the decimal place
	lcall printNums		; Print the numbers
	ljmp printStart		; Print the state

	increaseTens:		; Increment the tens place
	mov a, tensCount
	add a, #01h
	mov tensCount, a	; Move the incremented value back
	mov decimalCount, #00h	; Zero out the decimal place
	mov onesCount, #00h	; Zero out the ones place
	lcall printNums		; Print the numbers
	ljmp printStart		; Print the state

	zeroAll:		; Zero everything (99.9s)
	mov decimalCount, #00h	; Zero out the decimal place
	mov onesCount, #00h	; Zero out the ones place
	mov tensCount, #00h	; Zero out the tens place
	lcall printNums		; Print the numbers
	ljmp printStart		; Print the start

handleLap:
	jmp printLap

handleStop:
	lcall printNums
	jmp printStop

handleReset:
	mov decimalCount, #00h	; resets the decimal count to zero 
	mov onesCount, #00h	; resets the ones count to zero
	mov tensCount, #00h	; resets the tens count to zero
	lcall printNums
	ljmp printReset

printNums:
	mov command, #80h
	lcall writeCmd

	; Print value for tens count
	mov a, tensCount
	movc a, @a+dptr		; reference to the lookup table 
	mov text, a
	lcall writeText

	; Print value for ones count
	mov a, onesCount
	movc a, @a+dptr		; reference to the lookup table 
	mov text, a
	lcall writeText

	; Print the decimal place
	mov text, #2Eh 
	lcall writeText

	; Print value for decimal count
	mov a, decimalCount
	movc a, @a+dptr
	mov text, a
	lcall writeText

	; Print the s
	mov text, #73h
	lcall writeText

	ret

; show the start label on the LCD display 
printStart:
	; Move the cursor
	mov command, #0C6h
	lcall writeCmd

	mov text, #53h ; S
	lcall writeText

	mov text, #74h ; write t
	lcall writeText

	mov text, #61h ; write a
	lcall writeText

	mov text, #72h ; write r
	lcall writeText

	mov text, #74h ; write t
	lcall writeText

	ljmp main

; show the print label on the LCD display 
printReset:
	mov command, #0C6h
	lcall writeCmd

	mov text, #52h ; R
	lcall writeText

	mov text, #65h ; e
	lcall writeText

	mov text, #73h ; s
	lcall writeText

	mov text, #65h ; e
	lcall writeText

	mov text, #74h ; t
	lcall writeText

	ljmp main

; show the stop label on the LCD display 
printStop:
	mov command, #0C6h
	lcall writeCmd

	mov text, #53h ; S
	lcall writeText

	mov text, #74h ; t
	lcall writeText

	mov text, #6Fh ; o
	lcall writeText

	mov text, #70h ; p
	lcall writeText

	mov text, #20h ; blank
	lcall writeText

	ljmp main

; show the lap label on the LCD display 
printLap:
	mov command, #0C6h
	lcall writeCmd

	mov text, #4Ch ; L
	lcall writeText

	mov text, #61h ; a
	lcall writeText

	mov text, #70h ; p
	lcall writeText

	mov text, #20h ; blank
	lcall writeText

	mov text, #20h ; blank
	lcall writeText

	ljmp main
	
; Utility
writeCmd:
	mov P0, command
	clr P1.2 ; clear RS
	clr P1.1 ; clear R/W
	lcall LCDclock
	ret

writeText:
	mov P0, text
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
.db 30H	;	0	0	1	1	1	1	1	1	0x3F
.db 31H	;	1	0	0	0	0	1	1	0	0x06
.db 32H	;	2	1	0	1	1	0	1	1	0x5B
.db 33H	;	3	1	0	0	1	1	1	1	0x4F
.db 34H	;	4	1	1	0	0	1	1	0	0x66
.db 35H	;	5	1	1	0	1	1	0	1	0x6D
.db 36H	;	6	1	1	1	1	1	0	0	0x7C
.db 37H	;	7	0	0	0	0	1	1	1	0x07
.db 38H	;	8	1	1	1	1	1	1	1	0x7F
.db 39H	;	9	1	1	0	1	1	1	1	0x6F

.end


