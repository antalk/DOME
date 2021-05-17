;------------------------------------
;               DOME
;
; (c) 1998 PARAGON Productions
;
;             DOME.COM
;
;------------------------------------

	ORG	&H0100
ST:
	JP	START

	DB	&H0D	; type dome.com

	DB	"DOME (c) 1998 PARAGON Productions",&H0D,&H0A
	DB	&H1A	; Einde txt

	ORG	&H4000	; after bios

START:
	CALL	CREATE_LOG

	LD	HL,DOME_LIB0
	CALL	INIT_LIB

	LD	HL,LINE1
	CALL	WRITE_LOG

	LD	HL,FILE1
	LD	DE,&H0100
	CALL	LOAD_LIB

	LD	HL,LINE2
	CALL	WRITE_LOG

	LD	HL,FILE2
	LD	DE,&H8000
	CALL	LOAD_LIB

	LD	HL,LINE3
	CALL	WRITE_LOG

	CALL	CLOSE

	DI
	JP	&H8000
	RET

DOME_LIB0:	DB	"DOME    000"

FILE1:	DB	"BIOS    DAT"
FILE2:	DB	"LOADER  DAT"

	INCLUDE	3

LINE1:	DB	"LIB OPEN",255
LINE2:	DB	"BIOS LOADED",255
LINE3:	DB	"LOADER LOADED",255

EI:
