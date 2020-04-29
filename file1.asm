; *** *** *** *** *** *** *** *** *** *** *** *** ***
; *** Final Project 			Due: 05/01/2020
; *** Sydney O'Connor, Caroline Northrop, JT Salisbury
; ***
; *** This program is an implementation of a basic stopwatch, using the
; *** a matrix keypad and the LCD 2x16 bit display virtual hardware.
; *** The stopwatch has 4 states: Reset, Stop, Lap, Start.
; *** Reset - Resets the counter display to zero, displays reset tag
; *** Stop - Stops the counter display, displays stop tag
; *** Lap - Pauses the counter display, displays lap tag
; *** Start - Starts the counter display, displays start tag
;;;;;; LCD Wiring
; P0 = command/text
; P1.0 = Enable
; P1.1 = R/W
; P1.2 = RS
;;;;;; Keypad wiring
; P1.4 = Start
; P1.5 = Lap
; P1.6 = Stop
; P1.7 = Reset
; *********************NOTE*********************
; For use on a real device, lines 42, 110 and 332 should be uncommented out. For this lab, ignore delays was set to true on the LCD

command equ 40h		; hold the command to be executed on the LCD
text equ 41h		; hold the value to be written to the LCD
lastState equ 45h	; hold the value of the last state (1 = start FF, 2 = lap FE, 3 = reset FD, 4 = stop FC)

decimalCount equ 42h	; set variable to count tenths place
onesCount equ 43h	; set variable to count ones place
tensCount equ 44h	; set variable to count tens place

initProgram:
mov dptr, #Table ; set the lookup table
mov decimalCount, #00h	; the decimal counter
mov onesCount, #00h	; the ones counter
mov tensCount, #00h	; the tens counter
mov lastState, #01h	; begin in the start state

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

ljmp main	; This has been moved to the middle of the file due to jb address referencing capabilities

canMoveStart:	; Determine if we can move to the start state
	mov a, #0FCh 	; test if in stop state
	add a, lastState
	jc main

	jmp handleStart ; we can move to the start in lap, reset or start (garuanteed to be one of these)

handleStart:
	mov lastState, #01h	; Set the last state to 0x01 (start)

	mov a, #0f7h 		; Set accumulator to 247
	add a, decimalCount	; Add the decimal count to accumulator
	jc testOnes		; Decimal is > 9, try to increase ones place
	jnc increaseDecimal	; Decimal is < 9, increase decimal

	testOnes:		; Test to see if ones place < 9
	mov a, #0f7h		; set accumulator to 247
	add a, onesCount	; Add the ones count to accumulator
	jc testTens		; If we carry, then ones & decimal == 9, tst the tens place
	jnc increaseOnes	; If we don't carry, increment ones

	testTens:		; Test to see tens place is < 9
	mov a, #0f7h		; set accumulator to 247
	add a, tensCount	; add tens count to accumulator
	jc zeroAll		; If it equals 9, then we should zero everything out
	jnc increaseTens	; If it is < 9, increment tens place

	increaseDecimal:	; Increment the decimal place
	inc decimalCount	; Increase decimal count by one
	lcall printNums		; Print the numbers
	ljmp printStart		; Print the state

	increaseOnes:		; Increment the ones place
	inc onesCount		; Increment ones count by one
	mov decimalCount, #00h	; Zero out the decimal place
	lcall printNums		; Print the numbers
	ljmp printStart		; Print the state

	increaseTens:		; Increment the tens place
	inc tensCount		; Increment tens count by one
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

; Main
main:
	;lcall msDelay		; Delay to accurately represent 1/10 of a second
	clr P3.0		; P3.0 will control a row on the keypad
	setb P1.4 		; Start button
	setb P1.5 		; Lap button
	setb P1.6 		; Stop button
	setb P1.7 		; Reset button

	jnb P1.4, canMoveStart	; Jump to the start handler
	jnb P1.5, canMoveLap	; Jump to the lap handler
	jnb P1.6, canMoveStop	; Jump the stop handler
	jnb P1.7, canMoveReset	; Jump to the reset handler

	sjmp main		; No button is pressed, so we will just go back to main

canMoveLap:			; Determine if we can move to the lap state
	mov a, #0FCh 		; test if in stop state
	add a, lastState	; add last state to accumulator
	jc handleStop		; jump to stop handler if carry flag is high

	mov a, #0FDh 		; test if in reset state	
	add a, lastState	; add last state to accumulator
	jc handleReset		; jump to reset handler if carry flag is high

	mov a, #0FEh 		; test if in lap state
	add a, lastState	; add last state to accumulator
	jc handleLap		; jump to lap handler if carry flag is high


	jmp handleLap		; only state left is start

handleLap:
	mov lastState, #02h	; Set the last state to 0x02 (lap)

	jmp printLap

canMoveReset:
	mov a, #0FCh 		; test if in stop state
	add a, lastState
	jc handleReset

	mov a, #0FDh 		; test if in reset state
	add a, lastState
	jc handleReset

	mov a, #0FEh 		; test if in lap state
	add a, lastState
	jc handleReset


	jmp handleStart		; only state left is start

handleReset:
	mov lastState, #03h	; Set the last state to 0x03 (reset)

	mov decimalCount, #00h	; resets the decimal count to zero 
	mov onesCount, #00h	; resets the ones count to zero
	mov tensCount, #00h	; resets the tens count to zero
	lcall printNums
	ljmp printReset

canMoveStop:
	mov a, #0FCh 		; test if in stop state
	add a, lastState
	jc handleStop

	mov a, #0FDh 		; test if in reset state
	add a, lastState
	jc handleReset

	mov a, #0FEh 		; test if in lap state
	add a, lastState
	jc handleLap

	jmp handleStop		; only state left is start

handleStop:
	mov lastState, #04h	; Set the last state to 0x04 (stop)
	lcall printNums
	jmp printStop

printNums:
	mov command, #80h	; Setup which LCD block we print to
	lcall writeCmd

	; Print value for tens count
	mov a, tensCount	; move tens counter to accumulator
	movc a, @a+dptr		; Reference to the lookup table
	mov text, a
	lcall writeText		; print text

	; Print value for ones count
	mov a, onesCount	; move ones count to accumulator
	movc a, @a+dptr		; Reference to the lookup table
	mov text, a
	lcall writeText		; print text

	; Print the decimal place
	mov text, #2Eh		; hex value for period symbol
	lcall writeText		; print text

	; Print value for decimal count
	mov a, decimalCount	; move decimal count to accumulator
	movc a, @a+dptr		; reference lookup table
	mov text, a
	lcall writeText		; print text

	; Print the s
	mov text, #73h		; hex value for s
	lcall writeText		; print text

	ret

; show the start label on the LCD display
printStart:
	; Move the cursor
	mov command, #0C6h	; Setup which LCD block to print to
	lcall writeCmd

	mov text, #53h ; write S
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

; show the reset label on the LCD display
printReset:
	mov command, #0C6h	; Setup which LCD block to print to
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
	mov command, #0C6h	; Setup which LCD block to print to
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
	mov command, #0C6h	; Setup which LCD block to print to
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

; Utility functions
writeCmd:
	mov P0, command	; Move active command
	clr P1.2 	; clear RS
	clr P1.1 	; clear R/W
	lcall LCDclock
	ret

writeText:
	mov P0, text	; Move text to write
	setb P1.2 	; set RS
	clr P1.1 	; clear R/W
	lcall LCDclock
	ret

LCDclock:		; Clock the LCD and update the display
	setb P1.0 	; enable
	nop
	clr P1.0 	; disable
	nop
	setb P1.0 	; enable it
	;lcall clockDelay ; wait for 3ms
	ret

initDelay:			; Delay for 50ms
	clr TF0			; clear flags
	clr TR0
	mov TH0, #3Ch		; load timer value
	mov TL0, #0AFh
	setb TR0
	delayLoop:
		jnb TF0, delayLoop
	clr TR0
	clr TF0
	ret

msDelay:			; Delay for 100 ms
	lcall initDelay		; one 50ms delay
	lcall initDelay		; second 50ms delay

	ret

clockDelay:			; Delay for 3ms; used in the clock
	clr TF0			; clear flags
	clr TR0
	mov TH0, #0F4h		; load timer value (3ms)
	mov TL0, #47h
	setb TR0
	delayLoop2:
		jnb TF0, delayLoop2
	clr TR0
	clr TF0
	ret

; Lookup table for display
table:
	;		MSB						LSB
	;		g	f	e	d	c	b	a
.db 30h	;	0	0	1	1	1	1	1	1	0x3F
.db 31h	;	1	0	0	0	0	1	1	0	0x06
.db 32h	;	2	1	0	1	1	0	1	1	0x5B
.db 33h	;	3	1	0	0	1	1	1	1	0x4F
.db 34h	;	4	1	1	0	0	1	1	0	0x66
.db 35h	;	5	1	1	0	1	1	0	1	0x6D
.db 36h	;	6	1	1	1	1	1	0	0	0x7C
.db 37h	;	7	0	0	0	0	1	1	1	0x07
.db 38h	;	8	1	1	1	1	1	1	1	0x7F
.db 39h	;	9	1	1	0	1	1	1	1	0x6F

.end