; *** *** *** *** *** *** *** *** *** *** *** *** ***
; *** Final Project 			Due: 05/01/2020
; *** Sydney O'Connor, Caroline Northrop, JT Salisbury 
; ***
; *** need a description of this project here 

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
