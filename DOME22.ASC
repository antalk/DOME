;--------------------------------------
;                 DOME
;
; (c) 1997 / 98 / 99 Paragon Productions
;
;--------------------------------------

; last modification date 23-05-99

TANK_DATA:	EQU	32	; 32 bytes
BUILD_DATA:	EQU	13
VELD_ADRES:	EQU	&H8000

TANKTAB:	EQU	&h1000
TANK1:	EQU	&H1000+32	;adres tank tabel !!!!!!!!!!!!!!!!!
TANKRED:	EQU	&H1000+128*TANK_DATA


;------------- DOME ----------------   kick off !!

	ORG	&H3000
ST:
	LD	(EXIT_STACK),SP
	CALL	INIT_DUNE2
	XOR	A
	LD	(EVENT),A
MAIN_LOOP:
	LD	A,(FIRE_BUTTONS)
	BIT	4,A
	JR	NZ,RESET_BUTTON0
	CALL	Z,CHECK_COOR
MAIN_LOOP2:
	LD	A,(FIRE_BUTTONS)
	BIT	5,A
	JR	NZ,RESET_BUTTON1
	CALL	Z,CANCELACTION
MAIN_LOOP3:
	;    CALL    CHK_SPATIE
	;   CALL    Z,TEST_ADD_TNK
	; CALL    NZ,SPICE_BOOM

	LD	A,(STOP)
	OR	A
	JP	NZ,EXIT_DUNE2

	CALL	UPDATE_EVENT
	JR	MAIN_LOOP

UPDATE_EVENT:
	LD	A,(EVENT)
	INC	A
	CP	6
	JR	NZ,UPD2
	XOR	A
UPD2:
	LD	(EVENT),A
	LD	HL,EVENTHANDLER
	SLA	A
	LD	C,A
	LD	B,0
	ADD	HL,BC
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
	JP	(HL)
RESET_BUTTON0:
	LD	HL,BUT_PRESSED
	RES	0,(HL)
	JR	MAIN_LOOP2
RESET_BUTTON1:
	LD	HL,BUT_PRESSED
	RES	1,(HL)
	JR	MAIN_LOOP3

;-----------------------------------------

INIT_DUNE2:
	CALL	CHECK_FOR_SAVE	;libfunc
	OR	A
	JR	Z,GET_SAVED_STATE	; restore save game

	CALL	INIT_BBAR
	CALL	MMODULE_INIT

	LD	HL,CPYTT

	LD	B,79
	XOR	A
LOOP0:	LD	(HL),A
	INC	HL
	DJNZ	LOOP0

	LD	(STOP),A

	LD	HL,(ADR)
	LD	BC,9*256+17*4
	ADD	HL,BC
	LD	(ADR),HL

	LD	A,18
	LD	(OFFSET),A
	LD	A,10
	LD	(OFFSET+1),A

	LD	IX,SPRATR+4	; radar sprite
	LD	(IX),128+10
	LD	(IX+1),193+18

	; even roode cc yard erbij

	LD	BC,4095
	LD	HL,&h8000
LOOPVELDCLR:
	LD	(HL),0
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	DEC	BC
	LD	A,B
	OR	C
	JR	NZ,LOOPVELDCLR

	CALL	MAKE_RED_BASE

	CALL	FREE_BLW_BASE	; creer gezichtsveld 1e keer

	;--------------------
	CALL	PUT_SPRITE	; radarsprite

	CALL	PUT_MONEY	; plaatsmoney
	CALL	CLEAR_ITEM	; maak itemscherm schoon

	CALL	INIT_MOUSE	; start mouse lookup

	LD	HL,INT_GAME
	CALL	PUT_INT	; PUT ADR DOME-INT 

	HALT		; geef buttons een kans
	RET

GET_SAVED_STATE:
	RET

;-------------------------------------

INIT_MOUSE:
	LD	A,15
	OUT	(&HA0),A
	IN	A,(&HA2)
	AND	&H8F
	OR	&H30
	LD	(MOUSE_PORT),A
	XOR	A
	LD	(MOUSE_USE),A
	LD	(MOUSE_OFF),A

	LD	HL,&H002D
	LD	A,0	;(&HFCC1)       ; SLOT ADR BIOS = 0 
	CALL	&H0C	; interslot call

	CP	3
	JR	Z,INIT_MOUSE_TR

	LD	A,31
	LD	(MOUSE_WAIT1),A
	LD	A,10
	LD	(MOUSE_WAIT2),A
	RET
INIT_MOUSE_TR:
	LD	A,31*5
	LD	(MOUSE_WAIT1),A
	LD	A,10*5
	LD	(MOUSE_WAIT2),A
	RET

;-----------------------------------------

EXIT_DUNE2:
	RET

;-------------------------------------------------
; check op scrollen randjes
;------------------------------------------------

CHKXY:
	LD	IX,SPRATR+4
	CALL	PUT_SPRITE

	LD	D,4

SCRL:
	LD	A,(MOUSEX)
	CP	251
	JP	NC,SCRL_R

	CP	4
	JP	C,SCRL_L

	LD	A,(MOUSEY)
	CP	200
	JP	NC,SCRL_D

	CP	4
	JP	C,SCRL_U

	LD	A,(CURSOR_TYPE)
	LD	(MOUSE_SHAPE),A
	RET

SCRL_R:
	LD	A,16
	LD	(MOUSE_SHAPE),A

	LD	HL,MAXSET
	LD	A,(OFFSET)
	CP	(HL)
	RET	Z
	INC	A
	LD	(OFFSET),A
	INC	(IX+1)

	LD	HL,(ADR)
	LD	B,0
	LD	C,D
	ADD	HL,BC
	LD	(ADR),HL

	CALL	BUILD
	JP	CHKXY

SCRL_L:
	LD	A,24
	LD	(MOUSE_SHAPE),A

	LD	A,(OFFSET)
	CP	1
	RET	Z
	DEC	A

	LD	(OFFSET),A
	DEC	(IX+1)

	LD	HL,(ADR)
	LD	B,0
	LD	C,D
	SBC	HL,BC
	LD	(ADR),HL

	CALL	BUILD
	JP	CHKXY

SCRL_D:
	LD	A,20
	LD	(MOUSE_SHAPE),A

	LD	HL,MAXSET+1
	LD	A,(OFFSET+1)
	CP	(HL)
	RET	Z

	INC	A

	LD	(OFFSET+1),A
	INC	(IX)

	XOR	A
	LD	HL,(ADR)

	INC	H

	LD	(ADR),HL
	CALL	BUILD
	JP	CHKXY

SCRL_U:
	LD	A,12
	LD	(MOUSE_SHAPE),A

	LD	A,(OFFSET+1)
	CP	1
	RET	Z

	DEC	A

	LD	(OFFSET+1),A
	DEC	(IX)

	XOR	A
	LD	HL,(ADR)

	DEC	H

	LD	(ADR),HL
	CALL	BUILD
	JP	CHKXY

;---------------- Tabel update !!!----------

CX:	DB	0
CY:	DB	0


UPDATE:
	LD	IX,TANK1
UPDATELOOP:
	LD	A,(IX+13)
	OR	A
	CALL	NZ,TEST_WAT_NU

	LD	DE,TANK_DATA
	ADD	IX,DE
	LD	HL,TOTTANK
	DEC	(HL)
	JP	NZ,UPDATELOOP

	LD	A,254
	LD	(TOTTANK),A
	RET

TOTTANK:	DB	254

TEST_WAT_NU:
	BIT	4,(IX+11)
	JP	NZ,DO_MOVE

	CALL	IMPACT_GFX

	BIT	6,(IX+11)
	JP	NZ,DO_ATTACK

	JP	CHECK_MOVE
	RET

DO_MOVE:
	LD	A,(IX+6)
	OR	A
	JR	Z,UPDATEXY

	DEC	(IX+6)	; verlaag de step byte  
	LD	A,(IX+4)	; x offset  
	SUB	(IX+7)	;  x speed eraf

	LD	(IX+4),A
	LD	A,(IX+5)
	SUB	(IX+8)	; y speed eraf
	LD	(IX+5),A
	RET

UPDATEXY:
	LD	(IX+4),0
	LD	(IX+5),0
	LD	(IX+6),0
	LD	(IX+7),0
	LD	(IX+8),0

	BIT	5,(IX+23)	; DIT BIT JE IS GUARD
	CALL	NZ,TNK_CHK	; KIJK EEN RONDJE OM ZICH HEEN

CHECK_MOVE:
	BIT	5,(IX+11)
	CALL	NZ,ATT_MOVE	; geen jump ?? WEL DUS !!

	LD	A,(IX+15)
	AND	&B11110000
	JP	NZ,AFWK_MOVE

	LD	A,(IX)
	SUB	(IX+2)
	LD	B,A
	LD	A,0
	RL	A
	LD	(CX),A
	LD	A,(IX+1)
	SUB	(IX+3)
	LD	C,A
	LD	A,0
	RL	A
	LD	(CY),A
	LD	A,B
	OR	C
	JP	Z,TURN_ROUND

	XOR	A
	LD	A,(IX+#00)
	SUB	(IX+#02)
	JP	Z,J82F1

	LD	A,(IX+#01)
	SUB	(IX+#03)
	JP	Z,J82E6

	LD	A,(CX)
	OR	A
	JR	Z,SCHUIN

	LD	A,(CY)
	OR	A
	JP	Z,POSITIE_2
	JP	POSITIE_4

SCHUIN:	LD	A,(CY)
	OR	A
	JP	Z,POSITIE_8
	JP	POSITIE_6

J82E6:	LD	A,(CX)
	OR	A
	JP	Z,POSITIE_7
	JP	POSITIE_3

J82F1:	LD	A,(CY)
	OR	A
	JP	Z,POSITIE_1
	JP	POSITIE_5

POSITIE_1:
	LD	B,(IX)
	LD	C,(IX+1)
	CALL	CALC_ADR
	LD	D,H
	LD	E,L

	CALL	CHKUP
	LD	A,1
	JP	NZ,POS1_KAN

	CALL	CHKUPLT
	LD	A,1+(8*16)
	JP	NZ,POS8_KAN

	CALL	CHKUPRI
	LD	A,1+(2*16)
	JP	NZ,POS2_KAN

	CALL	CHKLT
	LD	A,1+(7*16)
	JP	NZ,POS7_KAN

	CALL	CHKRI
	LD	A,1+(3*16)
	JP	NZ,POS3_KAN

	JP	TANK_VAST

POSITIE_2:
	LD	B,(IX)
	LD	C,(IX+1)
	CALL	CALC_ADR
	LD	D,H
	LD	E,L

	CALL	CHKUPRI
	LD	A,2
	JP	NZ,POS2_KAN

	CALL	CHKUP
	LD	A,2+(1*16)
	JP	NZ,POS1_KAN

	CALL	CHKRI
	LD	A,2+(3*16)
	JP	NZ,POS3_KAN

	CALL	CHKUPLT
	LD	A,2+(8*16)
	JP	NZ,POS8_KAN

	CALL	CHKDORI
	LD	A,2+(4*16)
	JP	NZ,POS4_KAN

	JP	TANK_VAST

POSITIE_3:
	LD	B,(IX)
	LD	C,(IX+1)
	CALL	CALC_ADR
	LD	D,H
	LD	E,L

	CALL	CHKRI
	LD	A,3
	JP	NZ,POS3_KAN

	CALL	CHKUPRI
	LD	A,3+(2*16)
	JP	NZ,POS2_KAN

	CALL	CHKDORI
	LD	A,3+(4*16)
	JP	NZ,POS4_KAN

	CALL	CHKUP
	LD	A,3+(1*16)
	JP	NZ,POS1_KAN

	CALL	CHKDN
	LD	A,3+(5*16)
	JP	NZ,POS5_KAN

	JP	TANK_VAST

POSITIE_4:
	LD	B,(IX)
	LD	C,(IX+1)
	CALL	CALC_ADR
	LD	D,H
	LD	E,L

	CALL	CHKDORI
	LD	A,4
	JP	NZ,POS4_KAN

	CALL	CHKDN
	LD	A,4+(5*16)
	JP	NZ,POS5_KAN

	CALL	CHKRI
	LD	A,4+(3*16)
	JP	NZ,POS3_KAN

	CALL	CHKUPRI
	LD	A,4+(2*16)
	JP	NZ,POS2_KAN

	CALL	CHKDOLT
	LD	A,4+(6*16)
	JP	NZ,POS6_KAN

	JP	TANK_VAST

POSITIE_5:
	LD	B,(IX)
	LD	C,(IX+1)
	CALL	CALC_ADR
	LD	D,H
	LD	E,L

	CALL	CHKDN
	LD	A,5
	JP	NZ,POS5_KAN

	CALL	CHKDOLT
	LD	A,5+(6*16)
	JP	NZ,POS6_KAN

	CALL	CHKDORI
	LD	A,5+(4*16)
	JP	NZ,POS4_KAN

	CALL	CHKLT
	LD	A,5+(7*16)
	JP	NZ,POS7_KAN

	CALL	CHKRI
	LD	A,5+(3*16)
	JP	NZ,POS3_KAN

	JP	TANK_VAST

POSITIE_6:
	LD	B,(IX)
	LD	C,(IX+1)
	CALL	CALC_ADR
	LD	D,H
	LD	E,L

	CALL	CHKDOLT
	LD	A,6
	JP	NZ,POS6_KAN

	CALL	CHKLT
	LD	A,6+(7*16)
	JP	NZ,POS7_KAN

	CALL	CHKDN
	LD	A,6+(5*16)
	JP	NZ,POS5_KAN

	CALL	CHKUPLT
	LD	A,6+(8*16)
	JP	NZ,POS8_KAN

	CALL	CHKDORI
	LD	A,6+(4*16)
	JP	NZ,POS4_KAN

	JP	TANK_VAST

POSITIE_7:
	LD	B,(IX)
	LD	C,(IX+1)
	CALL	CALC_ADR
	LD	D,H
	LD	E,L

	CALL	CHKLT
	LD	A,7
	JP	NZ,POS7_KAN

	CALL	CHKDOLT
	LD	A,7+(6*16)
	JP	NZ,POS6_KAN

	CALL	CHKUPLT
	LD	A,7+(8*16)
	JP	NZ,POS8_KAN

	CALL	CHKUP
	LD	A,7+(1*16)
	JP	NZ,POS1_KAN

	CALL	CHKDN
	LD	A,7+(5*16)
	JP	NZ,POS5_KAN

	JP	TANK_VAST

POSITIE_8:
	LD	B,(IX)
	LD	C,(IX+1)
	CALL	CALC_ADR
	LD	D,H
	LD	E,L

	CALL	CHKUPLT
	LD	A,8
	JP	NZ,POS8_KAN

	CALL	CHKUP
	LD	A,8+(1*16)
	JP	NZ,POS1_KAN

	CALL	CHKLT
	LD	A,8+(7*16)
	JP	NZ,POS7_KAN

	CALL	CHKUPRI
	LD	A,8+(2*16)
	JP	NZ,POS2_KAN

	CALL	CHKDOLT
	LD	A,8+(6*16)
	JP	NZ,POS6_KAN

	JP	TANK_VAST

POS1_KAN:	LD	(IX+15),A
POS10KAN:	SET	4,(IX+#0B)

	CALL	RES_TANK_LAY
	DEC	H
	LD	(HL),A
	DEC	HL
	DEC	HL
	LD	A,(HL)
	OR	A
	JR	Z,POS10KAN1
	LD	(HL),B
POS10KAN1:
	LD	(IX+#09),0
	LD	A,(IX+#0A)
	LD	(IX+#07),0
	; NEG
	LD	(IX+#08),A
	; NEG

	LD	(IX+4),0
	LD	(IX+5),16
	DEC	(IX+1)	; Y=Y-1

	JP	SPEED_STEP

POS2_KAN:	LD	(IX+15),A
POS20KAN:	SET	4,(IX+#0B)

	CALL	RES_TANK_LAY
	DEC	H	; - 256
	INC	HL
	INC	HL
	INC	HL
	INC	HL	; + 4
	LD	(HL),A
	DEC	HL
	DEC	HL
	LD	A,(HL)
	OR	A
	JR	Z,POS20KAN1
	LD	(HL),B
POS20KAN1:

	LD	(IX+#09),1
	LD	A,(IX+#0A)
	NEG
	LD	(IX+#07),A
	NEG
	; NEG
	LD	(IX+#08),A
	;  NEG

	LD	(IX+4),-16
	LD	(IX+5),16
	INC	(IX)	; X=X-1
	DEC	(IX+1)	; Y = Y -1

	JP	SPEED_STEP

POS3_KAN:	LD	(IX+15),A
POS30KAN:	SET	4,(IX+#0B)

	CALL	RES_TANK_LAY
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	LD	(HL),A
	DEC	HL
	DEC	HL
	LD	A,(HL)
	OR	A
	JR	Z,POS30KAN1
	LD	(HL),B
POS30KAN1:

	LD	(IX+#09),2
	LD	A,(IX+#0A)
	NEG
	LD	(IX+#07),A
	NEG
	LD	(IX+#08),0

	LD	(IX+4),-16
	LD	(IX+5),0
	INC	(IX)	; X=X+1
	JP	SPEED_STEP

POS4_KAN:	LD	(IX+15),A
POS40KAN:	SET	4,(IX+#0B)

	CALL	RES_TANK_LAY
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	INC	H
	LD	(HL),A
	DEC	HL
	DEC	HL
	LD	A,(HL)
	OR	A
	JR	Z,POS40KAN1
	LD	(HL),B
POS40KAN1:

	LD	(IX+#09),3
	LD	A,(IX+#0A)
	NEG
	LD	(IX+#07),A
	LD	(IX+#08),A
	NEG

	LD	(IX+4),-16
	LD	(IX+5),-16
	INC	(IX)	; X=X-1
	INC	(IX+1)	; Y = Y -1
	JP	SPEED_STEP

POS5_KAN:	LD	(IX+15),A
POS50KAN:	SET	4,(IX+#0B)

	CALL	RES_TANK_LAY
	INC	H
	LD	(HL),A
	DEC	HL
	DEC	HL
	LD	A,(HL)
	OR	A
	JR	Z,POS50KAN1
	LD	(HL),B
POS50KAN1:

	LD	(IX+#09),4
	LD	A,(IX+#0A)
	NEG
	LD	(IX+#08),A
	NEG
	LD	(IX+#07),0

	LD	(IX+4),0
	LD	(IX+5),-16
	INC	(IX+1)	; Y = Y + 1
	JP	SPEED_STEP

POS6_KAN:	LD	(IX+15),A
POS60KAN:	SET	4,(IX+#0B)

	CALL	RES_TANK_LAY
	INC	H
	DEC	HL
	DEC	HL
	DEC	HL
	DEC	HL
	LD	(HL),A
	DEC	HL
	DEC	HL
	LD	A,(HL)
	OR	A
	JR	Z,POS60KAN1
	LD	(HL),B
POS60KAN1:

	LD	(IX+#09),5
	LD	A,(IX+#0A)
	; NEG
	LD	(IX+#07),A
	; NEG
	NEG
	LD	(IX+#08),A
	NEG

	LD	(IX+4),16
	LD	(IX+5),-16
	DEC	(IX)	; X=X-1
	INC	(IX+1)	; Y = Y -1
	JP	SPEED_STEP

POS7_KAN:	LD	(IX+15),A
POS70KAN:	SET	4,(IX+#0B)

	CALL	RES_TANK_LAY
	DEC	HL
	DEC	HL
	DEC	HL
	DEC	HL
	LD	(HL),A
	DEC	HL
	DEC	HL
	LD	A,(HL)
	OR	A
	JR	Z,POS70KAN1
	LD	(HL),B
POS70KAN1:

	LD	(IX+#09),6
	LD	A,(IX+#0A)
	LD	(IX+#07),A
	LD	(IX+#08),0

	LD	(IX+4),16
	LD	(IX+5),0
	DEC	(IX)	; X=X-1
	JP	SPEED_STEP

POS8_KAN:	LD	(IX+15),A
POS80KAN:	SET	4,(IX+#0B)

	CALL	RES_TANK_LAY
	DEC	HL
	DEC	HL
	DEC	HL
	DEC	HL
	DEC	H
	LD	(HL),A
	DEC	HL
	DEC	HL
	LD	A,(HL)
	OR	A
	JR	Z,POS80KAN1
	LD	(HL),B
POS80KAN1:

	LD	(IX+#09),7
	LD	A,(IX+#0A)
	; NEG
	LD	(IX+#07),A
	LD	(IX+#08),A
	; NEG

	LD	(IX+4),+16
	LD	(IX+5),16
	DEC	(IX)	; X=X-1
	DEC	(IX+1)	; Y = Y -1 
	JP	SPEED_STEP

TANK_VAST:	LD	A,(IX)	; kan geen kant op !!
	LD	(IX+2),A
	LD	A,(IX+1)
	LD	(IX+3),A
	LD	(IX+15),0
	LD	(IX+7),0
	LD	(IX+8),0
	RET

AFWK_MOVE:	LD	A,(IX+15)
	AND	&B00001111
	LD	HL,CHK_TABEL
	DEC	A
	SLA	A
	SLA	A
	LD	C,A
	LD	B,0
	ADD	HL,BC
	PUSH	HL

	LD	DE,DYNACALL+1
	LD	A,(HL)
	LD	(DE),A
	INC	HL
	INC	DE
	LD	A,(HL)
	LD	(DE),A

	LD	B,(IX)
	LD	C,(IX+1)
	CALL	CALC_ADR

	CALL	DYNACALL
	POP	HL
	JR	Z,J84FB

	LD	(IX+15),0
	INC	HL
	INC	HL
	LD	DE,DYNAJUMP+1
	LD	A,(HL)
	LD	(DE),A
	INC	DE
	INC	HL
	LD	A,(HL)
	LD	(DE),A
	JP	DYNAJUMP
	RET

J84FB:	LD	HL,CHK_TABEL
	LD	A,(IX+15)
	AND	&B11110000
	SRL	A
	SRL	A
	SUB	4

	LD	C,A
	LD	B,0
	ADC	HL,BC
	PUSH	HL
	LD	DE,DYNACALL+1
	LD	A,(HL)
	LD	(DE),A
	INC	HL
	INC	DE
	LD	A,(HL)
	LD	(DE),A

	LD	B,(IX)
	LD	C,(IX+1)
	CALL	CALC_ADR

	CALL	DYNACALL
	POP	HL
	JR	Z,REVERSE_MOVE

	INC	HL
	INC	HL
	LD	DE,DYNAJUMP+1
	LD	A,(HL)
	LD	(DE),A
	INC	DE
	INC	HL
	LD	A,(HL)
	LD	(DE),A
	JP	DYNAJUMP
	RET

REVERSE_MOVE:
	LD	(IX+15),0
	RET

DYNACALL:	CALL	&H0
	RET

DYNAJUMP:	JP	&H0

CHK_TABEL:
	DW	CHKUP+2
	DW	POS10KAN
	DW	CHKUPRI+2
	DW	POS20KAN
	DW	CHKRI+2
	DW	POS30KAN
	DW	CHKDORI+2
	DW	POS40KAN
	DW	CHKDN+2
	DW	POS50KAN
	DW	CHKDOLT+2
	DW	POS60KAN
	DW	CHKLT+2
	DW	POS70KAN
	DW	CHKUPLT+2
	DW	POS80KAN


ATT_MOVE:	;                 ;attack en doel zoeken
	BIT	3,(IX+11)
	JP	NZ,ATT_MOVE_B	; op 1 is gebouw aanvallen

	LD	A,(IX+11)	; type tank
	AND	&B00000111
	SLA	A
	LD	HL,RADARS
	LD	C,A
	LD	B,0
	ADD	HL,BC

	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL

	LD	A,(IX+14)
	PUSH	IX
	CALL	A_TO_IX
	LD	B,(IX)	; doel enemy
	LD	C,(IX+1)	; doel enemy
	POP	IX
	LD	D,(IX)
	LD	E,(IX+1)

CHECK_AROUND:	LD	A,(HL)
	CP	100
	JR	Z,END_CHK_RND

	XOR	A
	LD	A,B
	ADC	(HL)
	CP	D
	INC	HL
	JR	NZ,J85A0

	XOR	A
	LD	A,C
	ADC	(HL)
	CP	E
	JR	Z,FND_TARGET
J85A0:
	INC	HL
	JP	CHECK_AROUND

FND_TARGET:
	LD	(IX+20),B
	LD	(IX+21),C

	LD	E,(HL)
	DEC	HL
	LD	D,(HL)

	CALL	CALC_RICHT

	LD	A,(IX)	; set x en y op einde
	LD	(IX+2),A
	LD	A,(IX+1)
	LD	(IX+3),A
	RES	4,(IX+11)	; reset move bit
	RES	5,(IX+11)	; reset att move bit
	SET	6,(IX+11)	; set att bit

	POP	AF	; return adres van stack af einde
	;                        ; update subroutine
	RET

END_CHK_RND:	; eindcoordinaat
	LD	(IX+2),B
	LD	(IX+3),C
	RET
;-------------------------------
; ATTACK GEBOUW
;-------------------------------

ATT_MOVE_B:
	LD	A,(IX+11)	; type tank 
	AND	&B00000111
	SLA	A
	LD	HL,RADARS
	LD	C,A
	LD	B,0
	ADD	HL,BC

	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL

	LD	B,(IX+2)	; doel gebouw
	LD	C,(IX+3)	; doel gebouw (loopt echt niet weg !)
	LD	D,(IX)	; gebouw kan hooguit al kapot zijn!
	LD	E,(IX+1)	; huidige coordinaten

CHECKAROUND2:	LD	A,(HL)
	CP	100
	RET	Z	;nog niet in zicht dus rij maardoor

	XOR	A
	LD	A,B
	ADC	(HL)
	CP	D
	INC	HL
	JR	NZ,CONT_001

	XOR	A
	LD	A,C
	ADC	(HL)
	CP	E
	JR	Z,FND_TAR_BLD
CONT_001:
	INC	HL
	JP	CHECKAROUND2

FND_TAR_BLD:
	;  CALL    COLOR_WHITE

	LD	E,(HL)
	DEC	HL
	LD	D,(HL)

	CALL	CALC_RICHT

	LD	A,(IX)
	LD	(IX+2),A
	LD	A,(IX+1)
	LD	(IX+3),A
	LD	(IX+4),0
	LD	(IX+5),0
	RES	5,(IX+11)
	SET	6,(IX+11)	; set do_attack bitje
	RET
;----------------------------------
;  berekend de richting waarheen de tank moet staan !
;--------------------------------
CALC_RICHT:
	LD	C,4
	LD	A,D
	OR	A
	JR	Z,TARGET_XNUL
	RL	A
	JR	C,TARGET_XNEG

	LD	A,E
	OR	A
	JR	Z,TARGET_YNUL
	RL	A
	JR	C,TARGET_YNEG

	INC	C
TARGET_YNUL:
	INC	C
TARGET_YNEG:
	INC	C
	JP	SET_RICHTING
TARGET_XNEG:
	LD	A,E
	OR	A
	JR	Z,TARGET_YNUL2
	RL	A
	JR	C,TARGET_YNEG2

	DEC	C
TARGET_YNUL2:
	DEC	C
TARGET_YNEG2:
	DEC	C
	JP	SET_RICHTING

TARGET_XNUL:
	RL	E
	LD	C,0
	JR	NC,SET_RICHTING
	LD	C,4
	JP	SET_RICHTING

SET_RICHTING:
	LD	(IX+9),C	; radar found bitje ook weer op 0
	RET
;---------------------------------------

TURN_ROUND:
	RES	4,(IX+11)	; move uit !

	LD	A,(IX+13)
	CP	127
	JR	NC,CONT_TURNR

	BIT	7,(IX+9)
	JR	NZ,CONT_TURNR
	SET	7,(IX+9)

	LD	A,(IX+11)	; type tank 
	AND	&B00000111
	SLA	A
	LD	HL,RADARS
	LD	C,A
	LD	B,0
	ADD	HL,BC
	LD	E,(HL)
	INC	HL
	LD	D,(HL)

TURN_LOOP:
	LD	A,(DE)
	CP	100
	JR	Z,CONT_TURNR

	ADD	(IX+1)
	LD	C,A

	INC	DE
	LD	A,(DE)
	ADD	(IX)
	LD	B,A

	LD	(FOG_COOR),BC
	CALL	CALC_ADR
	DEC	HL
	INC	DE
	LD	A,(HL)
	OR	A
	JR	Z,TURN_LOOP

	LD	(HL),0	; reveal fog of war
	INC	HL

	LD	A,(HAS_RADAR)
	OR	A
	JR	Z,TURN_LOOP
	LD	A,(IS_GREY)
	OR	A
	JR	NZ,TURN_LOOP

	PUSH	DE
	CALL	POINT
	LD	D,A	; inhoud adres

	LD	BC,(FOG_COOR)

	LD	A,C
	LD	C,B
	LD	B,A
	SRL	B
	RR	C

	CALL	D_TO_POINT

	POP	DE
	JR	TURN_LOOP

FOG_COOR:	DW	0

CONT_TURNR:
	LD	A,(IX+11)
	AND	&B00000111	; GEEN DRAAI HARV/COUNTER ATT
	JP	Z,AI_HARVB	; DE AI VAN DE BLAUWE HARV

	BIT	5,(IX+23)
	CALL	NZ,TNK_CHK	; GUARD FUNCTIE VOOR ROOD ALLEEN

	LD	A,(TURN_WAIT)
	DEC	A
	LD	(TURN_WAIT),A
	RET	NZ

	LD	A,R
	AND	&B00001111
	LD	(TURN_WAIT),A

	LD	A,(IX+9)
	LD	B,A

	LD	A,R	;refresh is random ??
	AND	&B00000011	; yes!!! is coool

	OR	A
	RET	Z

	CP	2
	JP	Z,T_ROUND_DEC

	INC	B
	JP	Z,UPDATE_TURN
T_ROUND_DEC:
	DEC	B

UPDATE_TURN:
	LD	A,(IX+9)
	AND	&B10000000
	OR	B	; fout correctie !
	AND	&B10000111	; radar update bitje meenemen
	LD	(IX+9),A
	RET

TURN_WAIT:	DB	10

;---------------------------------------------

DO_ATTACK:	; attack iets ??
	CALL	SHOOT_GFX

	DEC	(IX+18)
	RET	NZ

	BIT	3,(IX+11)
	JP	NZ,DO_ATT_BLD

	LD	L,(IX+13)	; eigen nummer

	LD	A,(IX+19)	; wait time before shot
	LD	(IX+18),A

	LD	A,(IX+14)	; nummer van slachtoffer
	LD	(QUAKE),A	;

	LD	H,(IX+16)	; power

	LD	E,(IX+20)
	LD	D,(IX+21)

	PUSH	IX
	CALL	A_TO_IX

	LD	A,(IX+4)	; offset is niet 0 !!!
	OR	(IX+5)
	JR	NZ,STOP_ATTACK

	LD	A,(IX)
	CP	E
	JR	NZ,STOP_ATTACK
	LD	A,(IX+1)
	CP	D
	JR	NZ,STOP_ATTACK

	; attack kan !

	LD	A,H
	SUB	(IX+17)	; -shield
	LD	B,A
	LD	A,(IX+12)	; power van QUAKE
	SUB	B
	LD	(IX+12),A
	JR	NC,CONT_ATTACK

	CALL	REMOVE_TANK
	POP	IX
	RET

CONT_ATTACK:
	SET	4,(IX+22)	; voor inslag ani 0e frame

	; BIT     5,(IX+23)        ; schiet nooit terug
	;JR      NZ,CONTATTACK2    ; jajajaja dit werkt lekker

	LD	(IX+14),L	; nummer degene die schiet

	LD	A,(IX+11)	; harvest filteren
	AND	&B00000111
	JR	Z,CONTATTACK3

	RES	3,(IX+11)	; reset attack build !!!
	RES	4,(IX+11)	; move uit
	SET	5,(IX+11)	; attack move aan
	CALL	TNK_CHK_HELP

CONTATTACK2:
	POP	IX
	SET	1,(IX+22)	; voor schiet ani
	RET
CONTATTACK3:
	LD	(IX+14),L
	POP	IX
	SET	1,(IX+22)
	RET

STOP_ATTACK:
	LD	A,(IX+13)
	POP	IX
	LD	(IX+14),A
	RES	6,(IX+11)
	SET	5,(IX+11)
	RET

DO_ATT_BLD:
	LD	A,(IX+14)

	CALL	A_TO_BLD

	LD	A,(IY)	;geen gebouw
	OR	A
	JR	Z,STOP_ATT_B

	SET	1,(IX+22)	; schiet ani
	LD	A,(IX+19)	; wait time before shot 
	LD	(IX+18),A

	LD	A,(IX+16)	;power TAnk
	SUB	(IY+7)	; -shield VAN GEBOUW
	LD	B,A
	LD	A,(IY+6)	; power van GEBOUW
	SUB	B
	LD	(IY+6),A
	JR	Z,KILL_B
	RET	NC	; alles is goed schiet nog maar eens
KILL_B:
	PUSH	IX
	CALL	REMOVE_BUILD
	POP	IX
STOP_ATT_B:
	RES	6,(IX+11)	; kappe met schietn
	RES	5,(IX+11)
	RET


;------------------------------------

SPEED_STEP:	LD	B,A
	LD	C,0
	LD	A,16
J8608:	SUB	B
	JR	Z,J860F
	INC	C
	JP	J8608
J860F:	LD	(IX+6),C

	RET

;--------------------------------------
SHOOT_GFX:
	LD	A,(IX+22)
	AND	&B00000110
	OR	A
	RET	Z

	LD	IY,IMPACT0
	SLA	A
	SLA	A
	SLA	A
	LD	B,A
	LD	A,144
	ADD	B
	LD	(IY),A

	CALL	COPY_SHOOT

	LD	A,(IX+22)
	LD	C,A
	AND	&B11111001
	LD	B,A
	LD	A,C
	AND	&B00000110
	SRL	A
	INC	A
	AND	&B00000011
	SLA	A
	OR	B
	LD	(IX+22),A

	RET

IMPACT_GFX:
	LD	A,(IX+22)
	AND	&B00110000
	OR	A
	RET	Z

	LD	IY,IMPACT0
	LD	B,A
	LD	A,192
	ADD	B
	LD	(IY),A

	CALL	COPY_SHOOT

	LD	A,(IX+22)
	LD	C,A
	AND	&B11001111
	LD	B,A
	LD	A,C
	AND	&B00110000
	SRL	A
	SRL	A
	SRL	A
	SRL	A
	INC	A
	AND	&B00000011
	SLA	A
	SLA	A
	SLA	A
	SLA	A
	OR	B
	LD	(IX+22),A
	RET
COPY_SHOOT:
	LD	BC,(OFFSET)	; tank in veld ?? 
	LD	A,(IX)
	SUB	C
	RET	C
	CP	10
	RET	NC

	LD	A,(IX+1)
	SUB	B
	RET	C
	CP	10
	RET	NC

	EXX
	LD	HL,(OFFSET)

	LD	A,(IX)
	SUB	L
	INC	A
	ADD	A
	ADD	A
	ADD	A
	ADD	A
	LD	(IY+4),A
	;  CP      16
	;  RET     C
	;  CP      161
	;  RET     NC

	LD	A,(IX+1)
	SUB	H
	INC	A
	ADD	A
	ADD	A
	ADD	A
	ADD	A
	LD	(IY+6),A
	;   CP      16
	;   RET     C
	;   CP      161
	;   RET     NC
	LD	A,(SWAP)	; ??? waarom 
	LD	(IY+7),A
	CALL	PUTBLK
	EXX
	RET

;-------------------------------------
CHKUP:
	LD	H,D
	LD	L,E

	DEC	H
	JP	CHK_ALL
CHKDN:
	LD	H,D
	LD	L,E

	INC	H
	JP	CHK_ALL
CHKRI:
	LD	H,D
	LD	L,E

	LD	BC,4
	ADD	HL,BC
	JP	CHK_ALL

CHKLT:
	LD	H,D
	LD	L,E

	LD	BC,-4
	ADC	HL,BC
	JP	CHK_ALL
CHKUPRI:
	LD	H,D
	LD	L,E

	DEC	H
	LD	BC,4
	ADD	HL,BC
	JP	CHK_ALL

CHKDORI:
	LD	H,D
	LD	L,E

	INC	H
	LD	BC,4
	ADD	HL,BC
	JP	CHK_ALL

CHKDOLT:
	LD	H,D
	LD	L,E

	INC	H
	LD	BC,-4
	ADC	HL,BC
	JP	CHK_ALL

CHKUPLT:
	LD	H,D
	LD	L,E

	DEC	H
	LD	BC,-4
	ADC	HL,BC

CHK_ALL:
	LD	A,(HL)
	CP	80
	JP	NC,RETURN_VAST
CHK_TANK_OBJ:
	INC	HL	; 2 byte van velddata  
	LD	A,(HL)	; tank nummer
	OR	A
	JP	Z,RETURN_LOS
RETURN_VAST:
	XOR	A
	OR	A
	RET
RETURN_LOS:
	LD	A,1
	OR	A
	RET

;------------------------------------------------
; update het radar scherm en je money
;------------------------------------------------
IS_GREY:	DB	0

RADAR_UPDATE:
	LD	A,(RADAR)
	INC	A
	AND	&B00000011
	LD	(RADAR),A
	CP	2	; eens in de 4 keer
	JR	Z,MAKE_RAD_MON
	JP	NZ,SHOW_POWER
	RET
MAKE_RAD_MON:
	LD	A,(HAS_RADAR)
	OR	A
	RET	Z

	LD	A,(POWER_NEEDED)
	LD	B,A
	LD	A,(POWER_DELIVERED)
	SUB	B
	JP	C,MAKE_GREY_RAD

	LD	A,(IS_GREY)
	OR	A
	JP	NZ,INIT_RADAR

	;                        ; alle tanks even doorlopen
	LD	B,254
	LD	IX,TANK1
	LD	C,TANK_DATA
MAKE_RAD_LP1:
	LD	A,(IX+13)
	OR	A
	JR	Z,MAKE_RAD_END

	PUSH	BC

	LD	D,(IX)
	LD	E,(IX+1)
	LD	B,(IX+24)
	LD	C,(IX+25)

	LD	A,D
	CP	B
	JR	NZ,MAKE_RAD_LP2

	LD	A,E
	CP	C
	JR	Z,MAKE_RAD_END2
MAKE_RAD_LP2:

	CALL	CALC_ADR
	DEC	HL
	LD	A,(HL)
	OR	A
	JR	NZ,MAKE_RAD_END3

	INC	HL
	PUSH	DE	; ligt aan CALC_ADR
	CALL	POINT
	;                      ; vlak in A
	LD	D,A
	CALL	PLACE_UNIT

	POP	BC	; nieuwe coor in BC
	LD	(IX+24),B
	LD	(IX+25),C

	CALL	CALC_ADR
	DEC	HL
	LD	A,(HL)
	OR	A
	JR	NZ,MAKE_RAD_END2

	INC	HL
	CALL	POINT2
	LD	D,A
	CALL	PLACE_UNIT
MAKE_RAD_END2:
	POP	BC
MAKE_RAD_END:
	LD	A,B
	LD	B,0
	ADD	IX,BC
	LD	B,A
	DJNZ	MAKE_RAD_LP1
	RET
MAKE_RAD_END3:

	LD	(IX+24),D
	LD	(IX+25),E
	JR	MAKE_RAD_END2

PLACE_UNIT:
	LD	C,(IX+24)
	LD	B,(IX+25)
	SRL	B
	RR	C
D_TO_POINT:
	LD	HL,96
	ADD	HL,BC	; hahyahah hihihiih lache he  

	LD	B,H
	LD	C,L
	DI
	LD	A,1
	CALL	SETVDP2
	LD	A,D
	OUT	(&H98),A	; oude positie weg
	EI
	LD	H,B
	LD	L,C
	DI
	LD	A,3
	CALL	SETVDP2
	LD	A,D
	OUT	(&H98),A
	EI
	RET

POINT:
	LD	A,L
	AND	&B00000111
	CP	&B00000001
	JR	NZ,POINT_R

	EX	DE,HL
	LD	A,(DE)

	LD	HL,RAD_COL_TAB_L
	SRL	A
	SRL	A
	SRL	A
	SRL	A	; / 16
	LD	C,A
	LD	B,0
	ADD	HL,BC	; adres
	LD	A,(HL)
	EX	AF,AF

	INC	DE
	INC	DE
	INC	DE
	LD	A,(DE)
	OR	A
	JR	NZ,POINT_L_Z

	INC	DE
	LD	A,(DE)

	LD	HL,RAD_COL_TAB_R
	SRL	A
	SRL	A
	SRL	A
	SRL	A
	LD	C,A
	LD	B,0
	ADD	HL,BC
	LD	D,(HL)
	EX	AF,AF
	OR	D
	RET
POINT_L_Z:
	LD	D,0
	EX	AF,AF
	OR	D
	RET
POINT_R:
	EX	DE,HL
	LD	A,(DE)

	LD	HL,RAD_COL_TAB_R
	SRL	A
	SRL	A
	SRL	A
	SRL	A	; / 16
	LD	C,A
	LD	B,0
	ADD	HL,BC	; adres
	LD	A,(HL)

	EX	AF,AF

	DEC	DE
	DEC	DE
	DEC	DE
	DEC	DE
	DEC	DE
	LD	A,(DE)
	OR	A
	JR	NZ,POINT_R_Z

	INC	DE
	LD	A,(DE)

	LD	HL,RAD_COL_TAB_L
	SRL	A
	SRL	A
	SRL	A
	SRL	A
	LD	C,A
	LD	B,0
	ADD	HL,BC
	LD	D,(HL)
	EX	AF,AF
	OR	D
	RET
POINT_R_Z:
	LD	D,0
	EX	AF,AF
	OR	D
	RET

POINT2:
	LD	A,L
	AND	&B00000111
	CP	&B00000001
	JR	NZ,POINT2_R

	EX	DE,HL

	LD	A,(IX+13)
	CP	128
	JR	C,POINT2_1
	LD	A,&B10100000
	JR	POINT2_2
POINT2_1:
	LD	A,&B11010000
POINT2_2:
	EX	AF,AF

	INC	DE
	INC	DE
	INC	DE
	LD	A,(DE)
	OR	A
	JR	NZ,POINT2_L_Z

	INC	DE
	INC	DE
	LD	A,(DE)
	OR	A
	JR	Z,POINT2_23
	CP	128
	JR	C,POINT2_22

	LD	D,&B00001010
	JR	POINT2_24
POINT2_22:
	LD	D,&B00001101
	JR	POINT2_24
POINT2_23:
	DEC	DE
	LD	A,(DE)
	LD	HL,RAD_COL_TAB_R
	SRL	A
	SRL	A
	SRL	A
	SRL	A
	LD	C,A
	LD	B,0
	ADD	HL,BC
	LD	D,(HL)
POINT2_24:
	EX	AF,AF
	OR	D
	RET
POINT2_L_Z:
	LD	D,0
	EX	AF,AF
	OR	D
	RET
POINT2_R:
	EX	DE,HL
	LD	A,(IX+13)
	CP	128
	JR	C,POINT2_3
	LD	A,&B00001010
	JR	POINT2_4
POINT2_3:
	LD	A,&B00001101
POINT2_4:
	EX	AF,AF

	DEC	DE
	DEC	DE
	DEC	DE
	DEC	DE
	DEC	DE

	LD	A,(DE)
	OR	A
	JR	NZ,POINT2_R_Z

	INC	DE
	INC	DE
	LD	A,(DE)
	OR	A
	JR	Z,POINT2_43
	CP	128
	JR	C,POINT2_42

	LD	D,&B10100000
	JR	POINT2_44
POINT2_42:
	LD	D,&B11010000
	JR	POINT2_44
POINT2_43:

	DEC	DE
	LD	A,(DE)

	LD	HL,RAD_COL_TAB_L
	SRL	A
	SRL	A
	SRL	A
	SRL	A
	LD	C,A
	LD	B,0
	ADD	HL,BC
	LD	D,(HL)
POINT2_44:
	EX	AF,AF
	OR	D
	RET
POINT2_R_Z:
	LD	D,0
	EX	AF,AF
	OR	D
	RET

MAKE_GREY_RAD:
	LD	A,1
	LD	(IS_GREY),A

	LD	A,R
	LD	E,A
	LD	D,&hE0

	LD	HL,96
	LD	(VDPADR),HL

	LD	A,1
	CALL	SETVDP

	LD	B,64	; hoogte v.d. radar ?   
MAKE_GREY_RAD1:	PUSH	BC
	LD	B,32	; lengte 
MAKE_GREY_RAD2:
	PUSH	BC
	LD	A,(DE)
	INC	DE
	AND	&B00000011
	LD	C,A
	LD	B,0
	LD	HL,RAD_GREY_TAB
	ADD	HL,BC
	LD	A,(HL)
	POP	BC
	DI
	OUT	(&H98),A
	EI
	DJNZ	MAKE_GREY_RAD2

	LD	HL,(VDPADR)
	LD	BC,128
	ADD	HL,BC
	LD	(VDPADR),HL
	LD	A,1
	CALL	SETVDP

	POP	BC
	DJNZ	MAKE_GREY_RAD1

	LD	HL,0
	XOR	A
	CALL	SETVDP

	LD	IY,RADCOP
	CALL	SPRITES_OFF
	CALL	PUTBLK
	JP	SPRITES_ON

RAD_COL_TAB_R:
	DB	&B00000001
	DB	&B00000010
	DB	&B00000011
	DB	&B00000100
	DB	&B00000100
	DB	&B00000101
	DB	&B00001101
	DB	&B00001101
	DB	&B00001010
	DB	&B00001010

RAD_COL_TAB_L:
	DB	&B00010000
	DB	&B00100000
	DB	&B00110000
	DB	&B01000000
	DB	&B01000000
	DB	&B01010000
	DB	&B11010000
	DB	&B11010000
	DB	&B10100000
	DB	&B10100000

RAD_GREY_TAB:
	DB	&B01000100
	DB	&B10011001
	DB	&B11101110
	DB	&B11111111


;------------------------------------

INIT_RADAR:
	;                CALL    COLOR_WHITE

	XOR	A
	LD	(IS_GREY),A

	DI
	LD	DE,VELD_ADRES

	LD	HL,96
	LD	(VDPADR),HL

	LD	A,1
	CALL	SETVDP2

	LD	B,64	; hoogte v.d. radar ?  
J89B7:	PUSH	BC
	LD	B,32	; lengte

J89BB:
	LD	A,(DE)
	OR	A
	LD	A,0
	JR	NZ,INIT_RADAR2

	PUSH	BC
	PUSH	DE

	INC	DE

	EX	DE,HL
	CALL	POINT
	POP	DE
	POP	BC
INIT_RADAR2:
	OUT	(&H98),A
	INC	DE
	INC	DE
	INC	DE
	INC	DE

	INC	DE
	INC	DE
	INC	DE
	INC	DE

	DJNZ	J89BB

	LD	HL,(VDPADR)
	LD	BC,128
	ADD	HL,BC
	LD	(VDPADR),HL
	LD	A,1
	CALL	SETVDP2

	POP	BC
	DJNZ	J89B7

	LD	HL,0
	XOR	A
	CALL	SETVDP2
	EI

	LD	IY,RADCOP
	CALL	SPRITES_OFF
	CALL	PUTBLK
	CALL	SPRITES_ON
	RET

SETVDP:	DI
	OUT	(&H99),A
	LD	A,14
	SET	7,A
	OUT	(&H99),A
	SET	6,H
	RES	7,H
	LD	A,L
	OUT	(&H99),A
	LD	A,H
	OUT	(&H99),A
	EI
	RET

SETVDP2:
	OUT	(&H99),A
	LD	A,14
	SET	7,A
	OUT	(&H99),A
	SET	6,H
	RES	7,H
	LD	A,L
	OUT	(&H99),A
	LD	A,H
	OUT	(&H99),A
	RET


;------------ BUILD -------------------
; main build event
;--------------------------------------

BUILD:
	; XOR     A
	;  LD      (&HFC9E),A

	LD	A,(SWAP)
	XOR	1
	LD	(SWAP),A

	CALL	VELD
	CALL	TANKS
	CALL	BUILD_SEL

	LD	A,(ISTEXT)
	OR	A
	CALL	NZ,PUT_TEXT

	LD	A,(SWAP)
	ADD	A	; dit schijnt sneller te zijn !  
	ADD	A	; DAN SLA, SLA ,SLA EN SLA SLA  
	ADD	A
	ADD	A
	ADD	A

	ADD	31

	DI		; nu altijd in int. dus ... 
	OUT	(&H99),A
	LD	A,2+128
	OUT	(&H99),A
	EI
	RET

BUILD_SEL:
	LD	A,(ITEMSELECTED)
	CP	128
	RET	C

	LD	IX,(P_BUILD)

BUILD_SEL1:
	LD	DE,(OFFSET)

	LD	A,(IX+2)
	SUB	E
	SLA	A
	SLA	A
	SLA	A
	SLA	A
	ADD	16
	LD	H,A

	LD	A,(IX+3)
	SUB	D
	SLA	A
	SLA	A
	SLA	A
	SLA	A
	ADD	16
	LD	L,A

	LD	A,(IX+2)
	LD	B,A
	LD	A,(OFFSET)
	LD	C,A
	DEC	A
	CP	B
	JP	NC,BUILD_SEL3
	ADD	A,10
	CP	B
	RET	C

	LD	A,(IX+3)
	LD	B,A
	LD	A,(OFFSET+1)
	LD	C,A
	DEC	A
	CP	B
	JP	NC,BUILD_SEL2
	ADD	A,10
	CP	B
	RET	C

	LD	IY,COP_BSEL_1
	LD	(IY+4),H
	LD	(IY+6),L
	EXX
	CALL	PUTBLK
	EXX

BUILD_SEL2:
	LD	A,(IX+3)
	ADD	(IX+5)
	DEC	A
	LD	B,A
	LD	A,(OFFSET+1)
	LD	C,A
	DEC	A
	CP	B
	RET	NC
	ADD	A,10
	CP	B
	JP	C,BUILD_SEL3

	LD	IY,COP_BSEL_2
	LD	A,(IX+5)
	DEC	A
	SLA	A
	SLA	A
	SLA	A
	SLA	A
	ADD	L
	LD	(IY+4),H

	LD	(IY+6),A
	EXX
	CALL	PUTBLK
	EXX

BUILD_SEL3:
	LD	A,(IX+2)
	ADD	(IX+4)
	DEC	A
	LD	B,A
	LD	A,(OFFSET)
	LD	C,A
	DEC	A
	CP	B
	RET	NC
	ADD	A,10
	CP	B
	RET	C

	LD	A,(IX+3)
	LD	B,A
	LD	A,(OFFSET+1)
	LD	C,A
	DEC	A
	CP	B
	JP	NC,BUILD_SEL4
	ADD	A,10
	CP	B
	RET	C

	LD	IY,COP_BSEL_3
	LD	A,(IX+4)
	DEC	A
	SLA	A
	SLA	A
	SLA	A
	SLA	A
	ADD	H
	LD	(IY+4),A

	LD	(IY+6),L
	EXX
	CALL	PUTBLK
	EXX


BUILD_SEL4:
	LD	A,(IX+3)
	ADD	(IX+5)
	DEC	A
	LD	B,A
	LD	A,(OFFSET+1)
	LD	C,A
	DEC	A
	CP	B
	RET	NC
	ADD	A,10
	CP	B
	RET	C

	LD	IY,COP_BSEL_4
	LD	A,(IX+5)
	DEC	A
	SLA	A
	SLA	A
	SLA	A
	SLA	A
	ADD	L
	LD	(IY+6),A
	LD	A,(IX+4)
	DEC	A
	SLA	A
	SLA	A
	SLA	A
	SLA	A
	ADD	H
	LD	(IY+4),A

	EXX
	JP	PUTBLK

	RET

TANKS:
	LD	IY,TNKCOP
	LD	(IY+2),160
	LD	(IY+10),16
	LD	(IY+8),16
	LD	(IY),0
	LD	A,(SWAP)
	LD	(IY+7),A

	XOR	A
	LD	(SELECTED),A
	LD	HL,CPYTT

FIELD_LOOP:	;                      ; eerst alles binnen kader
	LD	A,(HL)
	OR	A
	JR	Z,REMOVE_SPR	;  klaar !!!
	PUSH	HL
	CALL	HL_TO_IX	; elke unit 1 keer
FIELD:
	JP	PTANK
IN_SCREEN:
	POP	HL
	LD	(HL),3	; binnen scherm voor ontplof tabel 

	BIT	7,(IX+11)
	JR	Z,J8C14

	LD	IX,SPRATR+8
	LD	A,(IY+4)
	LD	(IX+1),A
	LD	A,(IY+6)
	LD	(IX),A
	EXX
	CALL	PUT_SPRITE
	EXX
	LD	A,1
	LD	(SELECTED),A
	JP	J8C14
CONT2:
	POP	HL
J8C14:
	INC	HL
	INC	HL
	JP	FIELD_LOOP

REMOVE_SPR:	LD	A,(SELECTED)
	OR	A
	JR	NZ,RAND1

	LD	IX,SPRATR+8
	LD	(IX),212
	CALL	PUT_SPRITE

RAND1:
	LD	HL,CPYTT
RAND1_LOOP:
	LD	A,(HL)
	OR	A
	JR	Z,RAND2
	CP	2
	JR	NC,RAND1_4

	LD	BC,(OFFSET)	; c=x  & b=y

	CALL	HL_TO_IX
	LD	A,C
	SUB	(IX)
	JR	Z,RAND1_6
	DEC	A
	JR	NZ,RAND1_4

	LD	A,(IX+4)	; mogelijkheid 3 check
	BIT	7,A
	JR	NZ,RAND1_4
RAND1_6:

	DEC	C
	DEC	B

	LD	A,(IX)
	SUB	C
	ADD	A
	ADD	A
	ADD	A
	ADD	A	; x * 16
	LD	C,A	;  0 v 16

	LD	A,(IX+1)
	SUB	B
	ADD	A
	ADD	A
	ADD	A
	ADD	A
	ADD	(IX+5)
	LD	B,A	; y* 16 + offset

	LD	A,(IX+4)
	OR	A
	JR	Z,RAND1_4	; positie 1 op 0 punt
	CP	-16
	JR	Z,RAND1_4

	LD	A,C
	ADD	(IX+4)
	LD	C,A

	LD	A,B
	CP	16
	JR	C,RAND1_4
	CP	161
	JR	NC,RAND1_4

	PUSH	HL
	CALL	PTANK_RI
	POP	HL
	LD	(HL),2
RAND1_4:
	INC	HL
	INC	HL
	JP	RAND1_LOOP

RAND2:
	LD	HL,CPYTT
RAND2_LOOP:
	LD	A,(HL)
	OR	A
	JR	Z,RAND3
	CP	2
	JR	NC,RAND2_4

	LD	BC,(OFFSET)	; c=x  & b=y 

	CALL	HL_TO_IX
	LD	A,B	; cp y offset
	SUB	(IX+1)
	JR	Z,RAND2_6	; ligt ie binnen de randjes !
	DEC	A
	JR	NZ,RAND2_4

	LD	A,(IX+5)	; mogelijkheid 3 check
	BIT	7,A
	JR	NZ,RAND2_4
RAND2_6:
	DEC	C
	DEC	B

	LD	A,(IX)
	SUB	C
	ADD	A
	ADD	A
	ADD	A
	ADD	A	; x * 16  + OFFSET
	ADD	(IX+4)
	LD	C,A

	LD	A,(IX+1)
	SUB	B
	ADD	A
	ADD	A
	ADD	A
	ADD	A
	LD	B,A	; y* 16

	LD	A,(IX+5)
	OR	A
	JR	Z,RAND2_4	; positie 1 op 0 punt
	CP	-16
	JR	Z,RAND2_4

	LD	A,B
	ADD	(IX+5)
	LD	B,A

	LD	A,C
	CP	16
	JR	C,RAND2_4
	CP	161
	JR	NC,RAND2_4

	PUSH	HL
	CALL	PTANK_DN
	POP	HL
	LD	(HL),2
RAND2_4:
	INC	HL
	INC	HL
	JP	RAND2_LOOP

RAND3:
	LD	HL,CPYTT
RAND3_LOOP:
	LD	A,(HL)
	OR	A
	JR	Z,RAND4
	CP	2
	JR	NC,RAND3_4

	LD	BC,(OFFSET)	; c=x  & b=y 
	LD	A,C
	ADD	10
	LD	C,A

	CALL	HL_TO_IX
	LD	A,C
	SUB	(IX)
	JR	Z,RAND3_6
	DEC	A
	JR	Z,RAND3_5
	JP	RAND3_4
RAND3_6:
	LD	A,(IX+4)	; mogelijkheid 4 check
	BIT	7,A
	JR	Z,RAND3_4
RAND3_5:
	DEC	C
	DEC	B

	LD	A,(IX)
	SUB	C
	ADD	A
	ADD	A
	ADD	A
	ADD	A	; x * 16 
	ADD	160	; einde rand erbij
	LD	C,A	; 160 v 176 eruit

	LD	A,(IX+1)
	SUB	B
	ADD	A
	ADD	A
	ADD	A
	ADD	A
	ADD	(IX+5)
	LD	B,A	; y* 16 + offset 

	LD	A,(IX+4)
	OR	A
	JR	Z,RAND3_4	; positie 1 op 0 punt
	CP	16
	JR	Z,RAND3_4

	LD	A,C
	ADD	(IX+4)
	LD	C,A

	LD	A,B
	CP	16
	JR	C,RAND3_4
	CP	161
	JR	NC,RAND3_4

	PUSH	HL
	CALL	PTANK_LT
	POP	HL
	LD	(HL),2
RAND3_4:
	INC	HL
	INC	HL
	JP	RAND3_LOOP

RAND4:
	LD	HL,CPYTT
RAND4_LOOP:
	LD	A,(HL)
	OR	A
	RET	Z
	CP	2
	JR	NC,RAND4_4

	LD	BC,(OFFSET)	; c=x  & b=y  
	LD	A,B
	ADD	10
	LD	B,A

	CALL	HL_TO_IX
	LD	A,B
	SUB	(IX+1)
	JR	Z,RAND4_6
	DEC	A
	JR	Z,RAND4_5
	JP	RAND4_4
RAND4_6:
	LD	A,(IX+5)	; mogelijkheid 4 check
	BIT	7,A
	JR	Z,RAND4_4
RAND4_5:

	DEC	C
	DEC	B

	LD	A,(IX)
	SUB	C
	ADD	A
	ADD	A
	ADD	A
	ADD	A	; x * 16 +offset
	ADD	(IX+4)
	LD	C,A

	LD	A,(IX+1)
	SUB	B
	ADD	A
	ADD	A
	ADD	A
	ADD	A
	ADD	160
	LD	B,A	; y* 16 + offset  

	LD	A,(IX+5)
	OR	A
	JR	Z,RAND4_4	; positie 1 op 0 punt
	CP	16
	JR	Z,RAND4_4

	LD	A,B
	ADD	(IX+5)
	LD	B,A

	LD	A,C
	CP	16
	JR	C,RAND4_4
	CP	161
	JR	NC,RAND4_4

	PUSH	HL
	CALL	PTANK_UP
	POP	HL
	LD	(HL),2
RAND4_4:
	INC	HL
	INC	HL
	JP	RAND4_LOOP

;-------------------------------------
; Include the AI.ASM !

	INCLUDE	2

;-----------------------------------
; ALLERLEI ZOOI
;-----------------------------------

ALGEMEEN_TIMER:
	DB	0
ALGEMEEN:
	CALL	PUT_FPS
	CALL	CHECK_BUILD
	CALL	MSELECTED
	CALL	REP_UPGR
	CALL	COMMANDO

	; deze functies maar eens in de 2 keer !!!
	; zijn niet interessant of niet echt nodig

	LD	A,(ALGEMEEN_TIMER)
	INC	A
	AND	&B00000001
	LD	(ALGEMEEN_TIMER),A
	RET	NZ

	CALL	UPDATE_STEPS
	CALL	RED_DEAD
	RET

ONTPLOFFEN:
	LD	A,(PLOF_COUNT)
	OR	A
	RET	Z	; helemaal nix

	LD	B,A
	LD	IX,PLOF_TABEL-3
LABEL0003:
	INC	IX
	INC	IX
	INC	IX
	LD	A,(IX+2)
	OR	A
	JR	Z,LABEL0003
	EXX
	CALL	NZ,DOE_ONTPLOF
	EXX
	DJNZ	LABEL0003
	RET		; geen ontploffingen !

DOE_ONTPLOF:
	CP	11
	JR	Z,ENDPLOF
	LD	IY,PLOF_COP
	ADD	A
	ADD	A
	ADD	A
	ADD	A
	LD	(IY),A

	CALL	PLOF_IN_RAND
	LD	A,B
	OR	A
	JP	Z,DOE_ONTPLOF2

	LD	HL,(OFFSET)

	LD	A,(IX)
	SUB	L
	INC	A
	ADD	A
	ADD	A
	ADD	A
	ADD	A
	LD	(IY+4),A

	LD	A,(IX+1)
	SUB	H
	INC	A
	ADD	A
	ADD	A
	ADD	A
	ADD	A
	LD	(IY+6),A
	LD	A,(SWAP)
	LD	(IY+7),A
	CALL	PUTBLK
DOE_ONTPLOF2:
	INC	(IX+2)
	RET
ENDPLOF:
	XOR	A
	LD	(IX),A
	LD	(IX+1),A
	LD	(IX+2),A
	LD	A,(PLOF_COUNT)
	DEC	A
	LD	(PLOF_COUNT),A
	RET

PLOF_IN_RAND:
	LD	B,0

	LD	HL,(OFFSET)
	LD	A,L
	ADD	A,10
	LD	E,A
	LD	A,H
	ADD	A,10
	LD	D,A
	LD	A,(IX)
	CP	L
	RET	C
	CP	E
	RET	NC
	LD	A,(IX+1)
	CP	H
	RET	C
	CP	D
	RET	NC
	LD	B,1
	RET

REP_UPGR:
	LD	IX,BUILDING1
	LD	C,BUILD_DATA
	LD	B,50	; max
REPAIR_LOOP:
	BIT	0,(IX+8)
	CALL	NZ,DO_REPAIR

	BIT	1,(IX+8)
	CALL	NZ,DO_UPGRADE

	LD	A,B
	LD	B,0
	ADD	IX,BC
	LD	B,A
	DJNZ	REPAIR_LOOP
	RET
DO_REPAIR:
	INC	(IX+6)

	LD	A,(IX+1)
	CP	1
	CALL	Z,REP_POW_ALSO

	LD	A,(IX+6)
	CP	255
	RET	NZ

	RES	0,(IX+8)

	CALL	RES_MENU
	RET

REP_POW_ALSO:
	LD	D,4
	LD	E,51
	LD	A,(IX+6)	;power building
REP_LOOP:
	SUB	E
	JR	C,REP_POW_ALSO2
	INC	D
	INC	D
	INC	D
	INC	D
	JP	REP_LOOP
REP_POW_ALSO2:
	LD	A,(IX+12)
	SUB	D	; geen verandering
	RET	NC

	LD	A,D
	SUB	(IX+12)
	LD	E,A
	LD	A,(POWER_DELIVERED)
	ADD	E
	LD	(POWER_DELIVERED),A
	LD	(IX+12),D	;change
	RET

DO_UPGRADE:
	INC	(IX+11)
	LD	A,(IX+11)
	OR	A
	RET	NZ

	RES	1,(IX+8)
	CALL	RES_MENU

	INC	(IX+9)	; upgrade lev 1 up

	LD	A,(IX+1)
	CP	7	; yard is +1 upgrade
	JR	Z,UPGR_BBAR

	CP	4
	JR	Z,UPGR_TBAR

	RET

RES_MENU:
	XOR	A
	LD	(ACTIVE_MENU),A
	PUSH	IX
	POP	DE
	LD	HL,(P_BUILD)
	SBC	HL,DE
	RET	NZ

	PUSH	BC
	LD	(P_BUILD),IX
	CALL	P_BLD_IMG	; reset build img
	CALL	COMMAND_B
	LD	IX,(P_BUILD)
	POP	BC	; terug in loop 
	RET

UPGR_BBAR:
	LD	A,(UPG_LEV_BLD)
	CP	3
	RET	Z	; max upg lev bereikt

	EXX
	PUSH	IX

	INC	A
	LD	(UPG_LEV_BLD),A
	ADD	4	; ????

	ADD	A	;         *2
	ADD	A	;        *4
	LD	C,A
	LD	B,0
	LD	HL,BBB_VALUE
	ADD	HL,BC
	LD	(HL),1	; maak beschikbaar

	CALL	INIT_BBAR
	POP	IX
	EXX

	XOR	A
	LD	(IS_BLD_UPGRADING),A
	RET		; terug in loop

UPGR_TBAR:
	LD	A,(UPG_LEV_UNT)
	CP	4
	RET	Z

	EXX
	INC	A
	LD	(UPG_LEV_UNT),A

	ADD	A
	ADD	A
	LD	C,A
	LD	B,0
	LD	HL,TBB_VALUE
	ADD	HL,BC
	LD	(HL),1

	PUSH	IX
	CALL	INIT_BBAR
	POP	IX
	EXX
	XOR	A
	LD	(IS_UNT_UPGRADING),A
	RET

MSELECTED:
	LD	A,(HAS_SELECT)
	OR	A
	RET	Z

	XOR	A
	LD	(TOTAL_SELECT),A

	LD	HL,(OFFSET)

	LD	A,(SEL_X0)
	SRL	A
	SRL	A
	SRL	A
	SRL	A
	ADD	L
	LD	B,A	; X0

	LD	A,(SEL_X1)
	SRL	A
	SRL	A
	SRL	A
	SRL	A
	ADD	L
	LD	C,A	; X1

	LD	A,(SEL_Y0)
	SRL	A
	SRL	A
	SRL	A
	SRL	A
	ADD	H
	LD	D,A	; Y0

	LD	A,(SEL_Y2)
	SRL	A
	SRL	A
	SRL	A
	SRL	A
	ADD	H
	LD	E,A	; Y2

	LD	HL,CPYTT
LOOP_MSEL:
	LD	A,(HL)
	OR	A
	RET	Z
	CP	3
	JR	NZ,LOOP_MSEL2

	INC	HL
	LD	A,(HL)

	PUSH	HL

	CALL	IN_MSEL
	POP	HL
	INC	HL
	JR	LOOP_MSEL
LOOP_MSEL2:
	INC	HL
	INC	HL
	JR	LOOP_MSEL

IN_MSEL:
	PUSH	BC
	CALL	A_TO_IX
	POP	BC

	BIT	7,(IX+13)	;type tank
	RET	NZ

	RES	0,(IX+22)

	LD	A,(IX)
	LD	H,A
	CP	B
	RET	C
	CP	C
	RET	NC
	LD	A,(IX+1)
	LD	L,A
	CP	D
	RET	C
	CP	E
	RET	NC

	LD	A,(TOTAL_SELECT)
	CP	25
	RET	Z	; niet meer erbij !
	INC	A
	LD	(TOTAL_SELECT),A

	LD	A,1
	LD	(MSELECT_ON),A

	SET	0,(IX+22)
	RET


RED_DEAD:
	LD	A,(CHK_RED_DEAD)
	INC	A
	AND	&B00111111
	LD	(CHK_RED_DEAD),A
	RET	NZ
CHK_RED:
	LD	HL,TANKRED
	LD	BC,13
	ADD	HL,BC
	LD	DE,TANK_DATA
	LD	B,128
LP_CHK_RED:
	BIT	7,(HL)
	RET	NZ
	ADD	HL,DE
	DJNZ	LP_CHK_RED
	LD	A,1
	LD	(STOP),A
	RET

CHK_RED_DEAD:
	DB	0

COMMANDO:
	LD	A,(MBUSY)
	OR	A
	RET	NZ
	LD	A,(ITEMSELECTED)
	OR	A
	RET	Z

	CP	127
	JR	NC,COMM_BLD

	DEC	A
	JP	Z,COMM_TNK_RED
	DEC	A
	JR	Z,COMM_HRV_RED
	RET

COMM_BLD:
	CP	192
	RET	NC	; geen rood gebouw

	LD	HL,(P_BUILD)
	LD	BC,8
	ADD	HL,BC

	LD	A,(ACTIVE_MENU)
	BIT	0,(HL)
	JR	Z,COMM_BLD2
	LD	IY,MENU_RED_REP
	LD	B,8
	CP	B
	JR	NZ,COMM_BLD3
	RET
COMM_BLD2:
	BIT	1,(HL)
	RET	Z
	LD	IY,MENU_RED_UPG
	LD	B,9
	CP	B
	RET	Z
COMM_BLD3:
	LD	A,B
	LD	(ACTIVE_MENU),A
	PUSH	IY
	CALL	COMMAND_B
	POP	IY
	JP	PUTBLK

COMM_HRV_RED:
	LD	HL,(TNKADR)
	LD	BC,11
	ADD	HL,BC

	LD	A,(ACTIVE_MENU)

	BIT	4,(HL)
	JR	Z,COMM_HRV_RED2

	EX	AF,AF
	LD	BC,15
	ADD	HL,BC
	LD	A,(HL)
	OR	A
	JR	Z,COMM_HRV_RED1
	EX	AF,AF
	LD	IY,MENU_RED_RET
	LD	B,11
	CP	B
	RET	Z
	JR	COMM_HRV_RED3
COMM_HRV_RED1:
	EX	AF,AF
	LD	IY,MENU_RED_MOV
	LD	B,4
	CP	B
	RET	Z
	JR	COMM_HRV_RED3
COMM_HRV_RED2:
	LD	BC,11
	ADD	HL,BC	; ix+22
	BIT	7,(HL)
	JR	Z,COMM_HRV_RED22
	LD	IY,MENU_RED_HRV
	LD	B,10	; 10 is harvsten menu
	CP	B
	RET	Z
	JR	COMM_HRV_RED3

COMM_HRV_RED22:
	LD	IY,MENU_RED_STP
	LD	B,1
	CP	B
	RET	Z
COMM_HRV_RED3:
	LD	A,B
	LD	(ACTIVE_MENU),A
	PUSH	IY
	CALL	COMMAND_HARV
	POP	IY
	JP	PUTBLK


COMM_TNK_RED:
	LD	HL,(TNKADR)
	LD	BC,11
	ADD	HL,BC

	LD	A,(ACTIVE_MENU)

	BIT	4,(HL)
	JR	Z,COMM_TNK_RED2
	LD	IY,MENU_RED_MOV
	LD	B,4
	CP	B
	JR	NZ,COMM_TNK_RED4
	RET

COMM_TNK_RED2:
	BIT	6,(HL)
	JR	Z,COMM_TNK_RED3
	LD	IY,MENU_RED_ATT
	LD	B,6
	CP	B
	JR	NZ,COMM_TNK_RED4
	RET
COMM_TNK_RED3:
	LD	IY,MENU_RED_STP
	LD	B,1
	CP	B
	RET	Z
COMM_TNK_RED4:
	LD	A,B
	LD	(ACTIVE_MENU),A
	PUSH	IY
	CALL	COMMAND_TANK
	POP	IY
	JP	PUTBLK

ACTIVE_MENU:
	DB	0


;----------------------------------------------
; Check op bouwen gebouwen steps ??
;--------------------------------------------

CHECK_BUILD:
	LD	HL,BBB_VALUE
	LD	B,18	; max 18 was 13
L_CHK_BUILD1:
	PUSH	BC
	LD	A,(HL)
	CP	2
	JR	Z,CHECK_BUILD2
	CP	3
	CALL	Z,READY_BUILD2
L_CHK_BUILD2:
	POP	BC
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	DJNZ	L_CHK_BUILD1
	RET

CHECK_BUILD2:
	LD	A,B
	CP	6	; lager/gelijk aan 5 is AI
	JR	C,L_CHK_BUILD2

	LD	A,12
	SUB	B
	ADD	6
	LD	B,A

	LD	A,(B_BALK_TYPE)
	OR	A
	LD	A,(B_BALK_NR)
	JR	Z,CHECK_BUILD22
	LD	A,(T_BALK_NR)	; is het visible ???
CHECK_BUILD22:
	CP	B
	JR	Z,CHECK_BUILD23
	JR	NC,L_CHK_BUILD2
CHECK_BUILD23:
	ADD	A,3
	CP	B
	JR	C,L_CHK_BUILD2

	LD	IY,BB_STEPS_BAR

	SUB	A,3
	LD	C,A
	LD	A,B
	SUB	C
	SLA	A
	SLA	A
	SLA	A
	SLA	A
	SLA	A
	ADD	34
	LD	(IY+4),A

	PUSH	HL
	INC	HL
	INC	HL
	LD	A,(HL)
	SRL	A
	SRL	A
	SRL	A

	INC	A
	LD	(IY+10),A

	CALL	PUTBLK
	LD	A,(IY+7)
	XOR	1
	LD	(IY+7),A
	CALL	PUTBLK
	POP	HL
	JP	L_CHK_BUILD2

READY_BUILD2:
	LD	A,B
	CP	6
	JP	C,AI_CREATE_CAR

	EX	AF,AF
	LD	A,B
	CP	11
	LD	A,(B_BALK_NR)
	JR	NC,READY_BUILD22

	LD	A,(T_BALK_NR)
READY_BUILD22:
	LD	E,A
	LD	(HL),4	; kan ook 3 zijn

	EX	AF,AF
	CP	11
	JR	C,CREATE_CAR	; car wordt gemaakt zonder click

	LD	A,(B_BALK_TYPE)
	OR	A
	RET	NZ	; if tbar visible then NOT

	LD	A,12
	SUB	B
	ADD	6
	LD	B,A

	LD	A,E	; is het visible ???
	CP	B
	JR	Z,READY_BUILD23
	RET	NC
READY_BUILD23:
	ADD	A,3
	CP	B
	RET	C

	LD	A,B
	ADD	A
	ADD	A
	ADD	A
	ADD	A
	ADD	A
	LD	D,A	; pos gebouw

	LD	A,(B_BALK_NR)
	LD	C,A
	LD	A,B
	SUB	C
	ADD	A
	ADD	A
	ADD	A
	ADD	A
	ADD	A
	ADD	32
	LD	E,A	; pos in scherm opbalk

	PUSH	HL
	LD	IY,BB_BLW_COP
	CALL	PUTBLK
	CALL	BB_PUT_BUILD
	LD	IY,BB_READY_COP
	CALL	PUTBLK
	CALL	P_BB_PART
	POP	HL
	RET

;-----------------------------------------

CREATE_CAR:

	SUB	6
	LD	(TYPE_OF_CAR),A

	PUSH	HL	; push bb_bar adres

	LD	HL,BUILDING1
	INC	HL
	LD	C,BUILD_DATA
	LD	B,25	; 25 gebouwen van jou
LOOP_CRT_CAR:
	PUSH	HL
	PUSH	BC
	LD	A,(HL)
	CP	4	; gevonden ? dan createcar
	CALL	Z,CREATE_CAR2
	POP	BC
	POP	HL
	LD	A,B
	LD	B,0
	ADD	HL,BC
	LD	B,A
	DJNZ	LOOP_CRT_CAR

	JP	CANT_CREATE_TNK
	RET		; mag eigenlijk niet hier komen
	;   komt hier als geen enkele factory kan plaatsen
CREATE_CAR2:
	;                        ; if gevonden POP stack en cont
	;                        ; else RET
	INC	HL
	LD	B,(HL)	; ?
	DEC	B
	INC	HL
	LD	C,(HL)	; hoekje factory

	CALL	CALC_ADR

	LD	DE,FACTORY_DEPLOY
CREATE_CAR2_LP:
	LD	A,(DE)
	CP	100
	RET	Z	; volgende factory

	PUSH	HL

	LD	A,(DE)
	LD	C,A
	INC	DE
	LD	A,(DE)
	LD	B,A
	INC	DE
	ADD	HL,BC
	LD	A,(HL)
	CP	80
	JR	NC,CREATE_CAR2_LP2	; kan niet op rots of huis
	INC	HL
	LD	A,(HL)
	OR	A
	JR	NZ,CREATE_CAR2_LP2	; kan niet op tank
	JR	CREATE_CAR3
CREATE_CAR2_LP2:
	POP	HL
	JR	CREATE_CAR2_LP
	RET		; probeer volgende factory

CREATE_CAR3:
	POP	AF	; adres
	POP	AF	; stack
	POP	AF	; BC from 1st loop
	POP	AF	; building data

	LD	BC,VELD_ADRES
	SBC	HL,BC
	SRL	L
	SRL	L
	LD	A,L
	LD	L,H
	LD	H,A

	LD	A,(TYPE_OF_CAR)
	LD	C,A
	LD	B,1	;blauw
	CALL	ADD_TANK
	;                        ; add tank kan ook fout gaan
	OR	A
	JR	Z,CANT_CREATE_TNK

	POP	HL	; adres bb_bar
	LD	(HL),1	; clear tank bar
	INC	HL	; dit pas NA dat
	LD	A,(HL)	; de tank gebouwd is
	INC	HL
	DEC	A
	LD	(HL),A

	DEC	HL
	DEC	HL

	LD	A,(B_BALK_TYPE)
	OR	A
	RET	Z

	LD	A,(TYPE_OF_CAR)
	LD	B,A
	LD	A,4
	SUB	B
	LD	C,A
	ADD	A
	ADD	A
	ADD	A
	ADD	A
	ADD	A
	LD	D,A	; type of car 0=trike

	LD	A,(T_BALK_NR)
	LD	B,A
	LD	A,C
	ADD	8
	SUB	B
	RET	C

	ADD	A
	ADD	A
	ADD	A
	ADD	A
	ADD	A
	ADD	32
	LD	E,A	; place on screen
	PUSH	HL

	LD	IY,BB_BLW_COP
	CALL	PUTBLK
	CALL	BB_PUT_BUILD
	CALL	P_BB_PART
	POP	HL
	RET

CANT_CREATE_TNK:
	;               ; bbar een stapje terug doen zodat ie
	;               ; weer in de queue stapt
	POP	HL

	LD	(HL),2
	INC	HL
	LD	A,255
	SUB	(HL)
	INC	HL
	LD	(HL),A
	DEC	HL
	DEC	HL
	RET		; en even een message


TYPE_OF_CAR:	DB	0
;----------------------------------
; check mouse na druk op knop
;----------------------------------

CHECK_COOR:

	LD	DE,(MOUSEY)

	LD	A,D
	CP	16
	JR	C,AREA3
	CP	176
	JR	NC,AREA3
	LD	A,E
	CP	16
	JR	C,AREA3
	CP	176
	JR	NC,AREA3

	LD	A,1	; VOOR MSEL
	LD	(PLAYFIELD),A

	LD	A,(MBUSY)	; doe commando
	OR	A
	JP	NZ,EXEC_COMMAND

	JP	WHICH_OBJECT	; pak een tank

AREA3:
	XOR	A
	LD	(PLAYFIELD),A

	LD	B,193
	LD	C,251
	LD	H,128
	LD	L,191

	LD	A,(MBUSY)
	OR	A
	JR	Z,AREA3_1

	LD	B,187
	LD	C,249
	LD	H,122
	LD	L,183
AREA3_1:
	LD	A,D
	CP	B
	JR	C,AREA4
	CP	C
	JR	NC,AREA4
	LD	A,E
	CP	H
	JR	C,AREA4
	CP	L
	JR	NC,AREA4

	LD	A,(MBUSY)	; doe commando 
	OR	A
	JP	NZ,EXEC_COMMAND2

	JP	MOVE_RAD_SCR

AREA4:	LD	A,D
	CP	200
	JR	C,AREA5
	CP	248
	JR	NC,AREA5
	LD	A,E
	CP	16
	JR	C,AREA5
	CP	104
	JR	NC,AREA5

	JP	WHICH_ITEM
AREA5:
	LD	A,D
	CP	32
	JR	C,AREA51
	CP	160
	JR	NC,AREA51
	LD	A,E
	CP	176
	JR	C,AREA51

	JP	SEL_FROM_BB

AREA51:
	LD	A,D
	CP	16
	JR	C,AREA6
	CP	32
	JR	NC,AREA6
	LD	A,E
	CP	176
	JR	C,AREA6
	CP	200
	JR	NC,AREA6

	JP	SCRL_BB_L
AREA6:
	LD	A,D
	CP	160
	JR	C,AREA6A
	CP	176
	JR	NC,AREA6A
	LD	A,E
	CP	176
	JR	C,AREA6A
	CP	200
	JR	NC,AREA6A

	JP	SCRL_BB_R

AREA6A:

	LD	A,D
	CP	226
	JR	C,AREA6B
	CP	246
	JR	NC,AREA6B
	LD	A,E
	CP	192
	JR	C,AREA6B
	CP	200
	JR	NC,AREA6B
	JP	SCRL_BB_UP
AREA6B:
	LD	A,D
	CP	194
	JR	C,AREA7
	CP	224
	JR	NC,AREA7
	LD	A,E
	CP	192
	JR	C,AREA7
	CP	200
	JR	NC,AREA7
	JP	SCRL_BB_DN

AREA7:
	LD	A,D	; option
	CP	80
	JR	C,AREA8
	CP	128
	JR	NC,AREA8
	LD	A,E
	CP	0
	JR	C,AREA8
	CP	12
	JR	NC,AREA8

	JP	OPTION_MENU

AREA8:
	LD	A,D
	CP	16
	JR	C,AREA9
	CP	64
	JR	NC,AREA9
	LD	A,E
	CP	0
	JR	C,AREA9
	CP	12
	JR	NC,AREA9

	LD	A,1
	LD	(STOP),A
	RET

AREA9:
	RET

;--------------------------------------------

WHICH_OBJECT:
	CALL	XYTO16
	LD	B,D
	LD	C,E
	CALL	CALC_ADR
	DEC	HL
	LD	A,(HL)
	OR	A
	RET	NZ	; op onzichtbaar
	INC	HL
	INC	HL
	LD	A,(HL)
	OR	A
	JP	Z,WHICH_OBJCT2	; geen tank !!!

	CALL	A_TO_IX
	LD	B,(IX+13)

	LD	IY,(TNKADR)
	LD	A,(IY+13)
	CP	B
	RET	Z	; dezelfde tank !

	RES	7,(IY+11)

	LD	(TNKADR),IX

	CALL	P_TNK_IMG

	BIT	7,(IX+13)	; soort bit
	JR	NZ,ENEMY_SELTD

	LD	A,100
	LD	(ISTEXT),A
	LD	A,R
	AND	&B00000011
	CALL	INIT_TEXT

	XOR	A
	LD	(ACTIVE_MENU),A

	LD	A,(IX+11)
	AND	&B00000111
	JR	Z,HARV_SELTD

	LD	A,1
	LD	(ITEMSELECTED),A
	;  CALL    COMMAND_TANK     ;gebeurt al in COMMANDO
	CALL	SHOW_POWER
	SET	7,(IX+11)
	RET
HARV_SELTD:
	LD	A,2
	LD	(ITEMSELECTED),A
	;  CALL    COMMAND_HARV
	CALL	SHOW_POWER
	SET	7,(IX+11)
	RET

ENEMY_SELTD:
	LD	A,32
	LD	(ITEMSELECTED),A
	CALL	COMMAND_ENM	; misschien cursor type reset
	CALL	SHOW_POWER
	SET	7,(IX+11)
	RET		; klaar dus uit de loop


WHICH_OBJCT2:
	DEC	HL
	LD	A,(HL)
	CP	96
	RET	C
	CP	160
	RET	Z

	LD	C,7	; yard
	CP	100
	JR	C,LOOP0_OBJCT2

	LD	C,1	; windtrap
	CP	104
	JR	C,LOOP0_OBJCT2

	LD	C,2	; ref
	CP	110
	JR	C,LOOP0_OBJCT2

	LD	C,5	; radar
	CP	114
	JR	C,LOOP0_OBJCT2

	LD	C,3	; silo
	CP	118
	JR	C,LOOP0_OBJCT2

	LD	C,4
	CP	124
	JR	C,LOOP0_OBJCT2


	LD	C,7
	CP	132
	JR	C,LOOP1_OBJCT2

	LD	C,1
	CP	136
	JR	C,LOOP1_OBJCT2
	LD	C,4
	CP	156
	JR	C,LOOP1_OBJCT2
	RET

LOOP0_OBJCT2:
	LD	IX,BUILDING1
	LD	B,25	; 25 blauwe
	LD	H,128	; voor itemselected
	JP	LOOP0_OBJ2
LOOP1_OBJCT2:
	LD	IX,BUILDING1+24*BUILD_DATA
	LD	H,192	; itemsel
	LD	B,25	; 25 x rood
LOOP0_OBJ2:
	PUSH	BC

	LD	A,(IX+1)
	CP	C
	JR	NZ,LOOP0_OBJ21

	LD	A,(IX+2)
	DEC	A
	CP	D
	JR	NC,LOOP0_OBJ21

	ADD	(IX+4)
	CP	D
	JR	C,LOOP0_OBJ21

	LD	A,(IX+3)
	DEC	A
	CP	E
	JR	NC,LOOP0_OBJ21

	ADD	(IX+5)
	CP	E
	JR	C,LOOP0_OBJ21

	LD	IY,(TNKADR)
	RES	7,(IY+11)

	LD	(P_BUILD),IX

	LD	A,H	; itemselected = 128 + c ???
	ADD	C	; YARD     is 128
	LD	(ITEMSELECTED),A

	CP	191
	JR	NC,ENEMY_BUILD

	CALL	COMMAND_B
	JR	LAB0023
ENEMY_BUILD:
	CALL	COMMAND_ENM	; misschien cursor type reset 
LAB0023:
	CALL	P_BLD_IMG
	CALL	SHOW_POWER
	POP	BC

	LD	HL,TANKTAB	; tnkadr resetten op 0
	LD	(TNKADR),HL
	XOR	A
	LD	(ACTIVE_MENU),A
	RET		; building gevonden !!! 


LOOP0_OBJ21:
	LD	BC,BUILD_DATA
	ADD	IX,BC
	POP	BC
	DJNZ	LOOP0_OBJ2

	RET

;-----------------------------------------
; PUT TANK IMAGE
;-------------------------------------------

P_TNK_IMG:
	LD	IY,GRAY_ITEM
	CALL	PUTBLK

	LD	IY,TANK_IMG
	LD	A,(IX+11)
	AND	&B00000111
	LD	B,A
	LD	A,4
	SUB	B
	ADD	A
	ADD	A
	ADD	A
	ADD	A
	ADD	A

	LD	(IY),A
	CALL	PUTBLK

	LD	IY,PUT_ITEM
	LD	(IY+7),0
	CALL	PUTBLK
	LD	(IY+7),1
	CALL	PUTBLK
	RET

;-----------------------------------------
; PUT BUILDING IMAGE
;-------------------------------------------

P_BLD_IMG:
	LD	IY,GRAY_ITEM
	CALL	PUTBLK

	LD	IY,BUILD_IMG
	LD	A,(IX+1)
	ADD	A
	ADD	A
	ADD	A
	ADD	A
	ADD	A
	LD	(IY),A
	CALL	PUTBLK

	LD	IY,PUT_ITEM
	LD	(IY+7),0
	CALL	PUTBLK
	LD	(IY+7),1
	CALL	PUTBLK
	RET

;-------------------------------------------------
MOVE_RAD_SCR:	;
	LD	HL,BUT_PRESSED
	BIT	0,(HL)
	RET	NZ

	LD	IX,SPRATR+4
	LD	HL,VELD_ADRES+260	;ADR+193    !!!

	LD	A,D
	CP	246
	JR	C,MOV_RAD_SCR1

	LD	A,245
MOV_RAD_SCR1:	LD	(IX+1),A
	SUB	193
	LD	C,A
	INC	A
	LD	(OFFSET),A

	SLA	C
	SLA	C

	LD	B,0
	ADD	HL,BC

	LD	A,E
	CP	181
	JR	C,MOV_RAD_SCR2

	LD	A,180
MOV_RAD_SCR2:	LD	(IX+0),A
	SUB	128
	LD	C,A
	INC	A
	LD	(OFFSET+1),A
	LD	B,C
	LD	C,0
	ADD	HL,BC
	LD	BC,(ADR)
	LD	(ADR),HL

	XOR	A
	SBC	HL,BC
	RET	Z

	CALL	PUT_SPRITE
	JP	BUILD	; om ontploffen niet buiten build om
;------------------------------------

WHICH_ITEM:	LD	A,(MBUSY)
	OR	A
	JP	NZ,CHK_CANCEL

	LD	A,(ITEMSELECTED)
	OR	A
	RET	Z
	CP	191	; enemy building
	RET	NC

	CP	64	; bb bar
	JR	NC,BUILDING_COM
	CP	31	; geen enemy of gebouw ??
	RET	NC
	CP	2	; eigen harv
	JR	Z,HARV_COMMAND

TANK_COMMAND:
	LD	A,E
	CP	96
	JR	NC,TANK_CANCEL	; moet eigenlijk stop zijn !!
	CP	88
	JP	NC,TANK_GUARD
	CP	80
	JP	NC,TANK_MOVE
	CP	72
	JP	NC,TANK_ATTACK
	RET

HARV_COMMAND:
	LD	A,E
	CP	96
	JP	NC,HARV_RETURN	;  return !
	CP	88
	JR	NC,TANK_GUARD	; stop !
	CP	80
	JP	NC,TANK_MOVE	; gewoon een move
	CP	72
	JP	NC,TANK_ATTACK	; wordt opgevat als harvest
	RET

BUILDING_COM:
	LD	A,E
	CP	96
	JP	NC,BUILD_CANCEL
	CP	88
	RET	NC
	CP	80
	JP	NC,BUILD_UPGR
	CP	72
	JP	NC,BUILD_REP

	RET

CHK_CANCEL:
	LD	A,E
	CP	96
	RET	C
CHK_CANCEL2:

	LD	A,(ITEMSELECTED)
	OR	A
	RET	Z
	CP	64
	JR	NC,CANCEL_BB
	CP	31	; enemy selected geen cancel
	RET	NC
	CP	2
	JR	Z,CANCEL_HARV

CANCEL_TANK:
	XOR	A
	LD	(MBUSY),A
	LD	(CURSOR_TYPE),A
	CALL	COMMAND_TANK
	RET

CANCEL_HARV:
	XOR	A
	LD	(MBUSY),A
	LD	(CURSOR_TYPE),A
	CALL	COMMAND_HARV	; command harv!!
	RET

CANCEL_BB:
	XOR	A
	LD	(MBUSY),A
	LD	(CURSOR_TYPE),A
	LD	(ITEMSELECTED),A
	CALL	CLEAR_ITEM
	JP	BB_CANCEL

TANK_CANCEL:
	CALL	CLEAR_ITEM

	LD	IX,(TNKADR)
	RES	7,(IX+11)
	LD	HL,TANKTAB
	LD	(TNKADR),HL
	RET

TANK_GUARD:	LD	IX,(TNKADR)
	LD	A,(IX)
	LD	(IX+2),A
	LD	A,(IX+1)
	LD	(IX+3),A
	RES	5,(IX+11)
	RES	6,(IX+11)
	RES	7,(IX+22)	;eigenlijk alleen voor harvesters :)

	LD	A,(IX+27)
	OR	A
	CALL	NZ,FREE_REFINERY
	RET

TANK_ATTACK:
	CALL	CANCEL_ITEM
	LD	A,2
	LD	(MBUSY),A
	LD	A,28
	LD	(CURSOR_TYPE),A
	RET

TANK_MOVE:
	CALL	CANCEL_ITEM
	LD	A,1
	LD	(MBUSY),A
	LD	A,28
	LD	(CURSOR_TYPE),A
	RET

EXEC_COMMAND2:
	; D en E moeten omgerekend worden naar 16 vlaks
	PUSH	DE
	LD	HL,(OFFSET)
	PUSH	HL

	LD	A,D
	SUB	186
	LD	(OFFSET),A
	LD	D,16

	LD	A,E
	SUB	121
	LD	(OFFSET+1),A
	LD	E,16
	CALL	EXEC_COMMAND

	POP	HL
	LD	(OFFSET),HL
	POP	DE
	RET

EXEC_COMMAND:
	LD	HL,BUT_PRESSED
	BIT	0,(HL)
	RET	NZ
	SET	0,(HL)

	XOR	A
	LD	(ACTIVE_MENU),A
	LD	A,(ITEMSELECTED)
	CP	1
	JR	Z,TNK_COMMAND
	CP	2
	JR	Z,HRV_COMMAND
	CP	128	; gebouw geselecteerd ??
	RET	NC

	CP	64	; alles tussen 64 - 128
	JP	NC,BB_COMMAND
	RET		; enemy

HRV_COMMAND:
	LD	A,(MBUSY)
	CP	1
	JR	Z,TNK_COM_MOVE
	CP	2
	JP	Z,HRV_COM_HRV
	RET

TNK_COMMAND:	LD	A,(MBUSY)
	CP	1
	JR	Z,TNK_COM_MOVE
	CP	2
	JP	Z,TNK_COM_ATT
	RET


TNK_COM_MOVE:
	CALL	XYTO16
	LD	IX,(TNKADR)
	LD	(IX+2),D
	LD	(IX+3),E
	RES	5,(IX+11)
	RES	6,(IX+11)
	RES	7,(IX+22)	;harvest bitje uit
	XOR	A
	LD	(IX+26),A	; harvest wachttijd uit

	LD	A,(IX+27)
	OR	A
	CALL	NZ,FREE_REFINERY

	LD	A,(MSELECT_ON)
	OR	A
	CALL	NZ,MOVE_MSEL

	LD	A,(ITEMSELECTED)
	CP	1
	CALL	Z,COMMAND_TANK
	CP	2
	CALL	Z,COMMAND_HARV

	XOR	A
	LD	(MBUSY),A
	LD	(CURSOR_TYPE),A
	RET

MOVE_MSEL:
	BIT	0,(IX+22)
	RET	Z

	LD	A,127	; tanksum
	LD	BC,TANK_DATA
	LD	IX,TANK1
	LD	IY,DEST_OFFSET
LP_MOVE_MSEL:
	BIT	0,(IX+22)
	CALL	NZ,DO_SEL_MOVE
	ADD	IX,BC
	DEC	A
	RET	Z
	JP	LP_MOVE_MSEL

DO_SEL_MOVE:
	EX	AF,AF
	LD	A,(IY)
	ADD	A,D
	LD	(IX+2),A
	LD	A,(IY+1)
	ADD	A,E
	LD	(IX+3),A
	INC	IY
	INC	IY
	EX	AF,AF
	RES	5,(IX+11)
	RES	6,(IX+11)
	RES	7,(IX+22)	;harvest bitje uit 
	RET

TNK_COM_ATT:
	LD	IX,(TNKADR)
	RES	6,(IX+11)

	CALL	XYTO16
	LD	B,D
	LD	C,E
	CALL	CALC_ADR

	LD	A,(HL)
	CP	80
	JR	C,TNK_COM_ATT2
	CP	144
	JR	NC,TNK_COM_ATT2
	JP	TNK_ATT_BLD

TNK_COM_ATT2:
	INC	HL

	LD	A,(HL)	; geen rooie
	CP	128
	RET	C

	LD	(IX+14),A	; nummer enemy tank

	RES	3,(IX+11)	; je valt een tank aan
	SET	5,(IX+11)
	LD	(IX+2),D	; x en y van enemy
	LD	(IX+3),E

	LD	A,(MSELECT_ON)	; multiple select attack
	OR	A
	CALL	NZ,ATT_MSEL

J8895:	XOR	A
	LD	(MBUSY),A
	LD	(CURSOR_TYPE),A

	CALL	COMMAND_TANK

	RET

ATT_MSEL:
	BIT	0,(IX+22)
	RET	Z

	LD	B,127	; tnksum
	LD	C,TANK_DATA
	LD	IX,TANK1
LP_ATT_MSEL:
	BIT	0,(IX+22)
	CALL	NZ,DO_SEL_ATT
	LD	A,B
	LD	B,0
	ADD	IX,BC
	LD	B,A
	DJNZ	LP_ATT_MSEL
	RET
DO_SEL_ATT:
	; zorg dat de harvesters niet in ATTSEL zitten !!!
	LD	A,(IX+11)
	AND	&B00000111
	OR	0
	RET	Z

	RES	3,(IX+11)
	SET	5,(IX+11)
	LD	(IX+2),D
	LD	(IX+3),E
	LD	A,(HL)
	LD	(IX+14),A
	RET

TNK_ATT_BLD:
	SET	3,(IX+11)	;ATT BUILDING
	SET	5,(IX+11)
	LD	(IX+2),D
	LD	(IX+3),E	; rij erheen

	LD	IY,BUILDING1
	LD	B,50	; 50 blauwe 
LOOP1_OBJ2:
	PUSH	BC

	LD	A,(IY+2)
	DEC	A
	CP	D
	JR	NC,LOOP1_OBJ21

	ADD	(IY+4)
	CP	D
	JR	C,LOOP1_OBJ21

	LD	A,(IY+3)
	DEC	A
	CP	E
	JR	NC,LOOP1_OBJ21

	ADD	(IY+5)
	CP	E
	JR	C,LOOP1_OBJ21

	POP	BC
	LD	H,(IY)	;nummer gebouw
	LD	(IX+14),H

	LD	A,(MSELECT_ON)	; multiple select attack 
	OR	A	; on building
	CALL	NZ,ATT_MSEL2

	JP	J8895	; menu goed
LOOP1_OBJ21:
	LD	BC,BUILD_DATA
	ADD	IY,BC
	POP	BC
	DJNZ	LOOP1_OBJ2

	RET		; als het goed is komt ie hier nooit !

ATT_MSEL2:
	BIT	0,(IX+22)
	RET	Z

	LD	IX,TANK1

	LD	B,127	; tnksum
	LD	C,TANK_DATA
LP_ATT_MSEL2:
	BIT	0,(IX+22)
	CALL	NZ,DO_SEL_ATT2
	LD	A,B
	LD	B,0
	ADD	IX,BC
	LD	B,A
	DJNZ	LP_ATT_MSEL2
	RET
DO_SEL_ATT2:
	;zorg    dat de harvesters niet in ATTSEL zitten !!!
	LD	A,(IX+11)
	AND	&B00000111
	OR	0
	RET	Z

	SET	3,(IX+11)
	SET	5,(IX+11)
	LD	(IX+2),D
	LD	(IX+3),E
	LD	(IX+14),H
	RET

;----------------------------------
HRV_COM_HRV:
	CALL	XYTO16
	PUSH	DE
	LD	B,D
	LD	C,E
	CALL	CALC_ADR
	POP	DE
	LD	A,(HL)

	CP	16
	RET	C
	CP	48
	RET	NC

	LD	IX,(TNKADR)
	LD	(IX+2),D
	LD	(IX+3),E
	SET	7,(IX+22)

	CALL	COMMAND_HARV
	XOR	A
	LD	(MBUSY),A
	LD	(CURSOR_TYPE),A

	LD	A,(IX+27)
	OR	A
	RET	Z

	; nu de refinery van bezet naar vrij zetten
	; wordt ook gebruikt vanuit move !
FREE_REFINERY:
	LD	B,A
	LD	HL,BUILDING1-BUILD_DATA
	LD	DE,BUILD_DATA
FIND_REF:
	ADD	HL,DE
	DJNZ	FIND_REF

	LD	DE,8	; IY+8
	ADD	HL,DE	; ref. free !
	RES	2,(HL)
	XOR	A
	LD	(IX+27),A
	RET

HARV_RETURN:
	LD	IX,(TNKADR)
	LD	A,50
	LD	(IX+26),A

HARV_RETURN2:
	LD	A,(IX+27)
	OR	A
	RET	NZ

	LD	HL,BUILDING1
	INC	HL
	LD	DE,BUILD_DATA
	LD	B,25	; max
HARV_R_LOOP:
	LD	A,(HL)
	CP	2
	JR	Z,HARV_RET2
HARV_R_LOOP2:
	ADD	HL,DE
	DJNZ	HARV_R_LOOP
	RET
HARV_RET2:
	PUSH	HL
	POP	IY

	BIT	2,(IY+7)	; BIT 2 IX+8 IS BEZET BIT
	JR	NZ,HARV_R_LOOP2
	SET	2,(IY+7)

	INC	HL
	LD	A,(HL)
	ADD	3

	LD	(IX+2),A
	INC	HL
	LD	A,(HL)
	ADD	2
	LD	(IX+3),A

	DEC	IY	; nummer refinery in ix+27
	LD	A,(IY)
	LD	(IX+27),A
	RET

BUILD_REP:
	LD	IX,(P_BUILD)
	LD	A,(IX+6)
	INC	A
	RET	Z
	BIT	1,(IX+8)
	RET	NZ
	SET	0,(IX+8)
	RET
BUILD_UPGR:
	LD	IX,(P_BUILD)
	LD	A,(IX+10)
	SUB	(IX+9)
	RET	Z
	BIT	0,(IX+8)	; repair is busy
	RET	NZ

	LD	A,(IX+1)
	CP	7
	JR	Z,BUILD_UPGR2

	LD	A,(IS_UNT_UPGRADING)
	OR	A
	RET	NZ
	SET	1,(IX+8)
	LD	A,1
	LD	(IS_UNT_UPGRADING),A
	RET
BUILD_UPGR2:
	LD	A,(IS_BLD_UPGRADING)
	OR	A
	RET	NZ
	SET	1,(IX+8)
	LD	A,1
	LD	(IS_BLD_UPGRADING),A
	RET

BUILD_CANCEL:
	LD	HL,BUT_PRESSED
	BIT	0,(HL)
	RET	NZ

	LD	IX,(P_BUILD)
	BIT	0,(IX+8)
	JR	NZ,BUILD_CANCEL3

	BIT	1,(IX+8)
	JR	NZ,BUILD_CANCEL2
	JP	CLEAR_ITEM
BUILD_CANCEL2:
	RES	1,(IX+8)
	LD	(IX+11),0	; upgrade lev op 0
	LD	A,(IX+1)
	CP	7
	JR	Z,BUILD_CANCEL4
	XOR	A
	LD	(IS_UNT_UPGRADING),A
	JR	BUILD_CANCEL3
BUILD_CANCEL4:
	XOR	A
	LD	(IS_BLD_UPGRADING),A
BUILD_CANCEL3:
	RES	0,(IX+8)
	SET	0,(HL)
	XOR	A
	LD	(ACTIVE_MENU),A
	CALL	COMMAND_B
	RET


;---------------------------------------
BB_COMMAND:
	LD	A,(BB_BLOCKED)
	OR	A
	RET	NZ

	LD	A,(ITEMSELECTED)
	CP	64
	JR	Z,P_BETON

	CP	65
	JP	Z,P_WINDTRAP

	CP	66
	JP	Z,P_REFINERY

	CP	67
	JP	Z,P_SILO

	CP	68
	JP	Z,P_FACTORY

	CP	69
	JP	Z,P_RADAR

	RET

P_BETON:
	CALL	XYTO16
	LD	B,D
	LD	C,E
	CALL	CALC_ADR

	LD	(HL),64	; danbeton erop

	JP	RESET_STATUS

P_CONST_Y:
	; to be done

	LD	A,10
	CALL	ADD_POWER

	RET

P_REFINERY:
	CALL	XYTO16

	PUSH	DE

	LD	H,2	; refinery is 3
	CALL	ADD_BUILDING
	POP	DE
	OR	A
	RET	Z	; building vol

	LD	B,D
	LD	C,E
	CALL	CALC_ADR

	CALL	NO_BETON_CHK
	LD	(HL),104	; refinery erop
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	CALL	NO_BETON_CHK
	LD	(HL),105
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	CALL	NO_BETON_CHK
	LD	(HL),106
	INC	H
	CALL	NO_BETON_CHK
	LD	(HL),109
	DEC	HL
	DEC	HL
	DEC	HL
	DEC	HL
	CALL	NO_BETON_CHK
	LD	(HL),108
	DEC	HL
	DEC	HL
	DEC	HL
	DEC	HL
	CALL	NO_BETON_CHK
	LD	(HL),107

	SET	2,(IX+8)	; ref. is bezet ! 

	LD	A,15
	CALL	ADD_POWER

	LD	A,(IX)
	EX	AF,AF

	LD	L,E
	INC	L
	LD	H,D
	INC	H
	INC	H
	LD	B,1
	LD	C,0
	CALL	ADD_TANK
	OR	A
	JR	Z,P_REFINERY2	; tanktab vol

	EX	AF,AF
	OR	A
	LD	(IY+27),A	; nummer gebouw

P_REFINERY2:
	JP	RESET_STATUS

P_FACTORY:
	CALL	XYTO16
	PUSH	DE

	LD	H,4
	CALL	ADD_BUILDING
	POP	DE
	OR	A
	RET	Z	; max. bereikt

	LD	A,(UPG_LEV_UNT)
	LD	(IX+9),A

	LD	B,D
	LD	C,E
	CALL	CALC_ADR

	CALL	NO_BETON_CHK
	LD	(HL),118	; refinery erop
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	CALL	NO_BETON_CHK
	LD	(HL),119
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	CALL	NO_BETON_CHK
	LD	(HL),120
	INC	H
	CALL	NO_BETON_CHK
	LD	(HL),123
	DEC	HL
	DEC	HL
	DEC	HL
	DEC	HL
	CALL	NO_BETON_CHK
	LD	(HL),122
	DEC	HL
	DEC	HL
	DEC	HL
	DEC	HL
	CALL	NO_BETON_CHK
	LD	(HL),121

	LD	A,20
	CALL	ADD_POWER

	;       ; Maak de eerste unit beschikbaar

	LD	HL,TBB_VALUE
	LD	A,(HL)
	OR	A
	JP	NZ,RESET_STATUS

	LD	(HL),1
	JP	RESET_STATUS

P_RADAR:
	CALL	XYTO16

	PUSH	DE

	LD	H,5	; radar    is 4
	CALL	ADD_BUILDING
	POP	DE
	OR	A
	RET	Z	; building vol

	LD	B,D
	LD	C,E
	CALL	CALC_ADR

	CALL	NO_BETON_CHK
	LD	(HL),110	; windtrap erop
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	CALL	NO_BETON_CHK
	LD	(HL),111
	INC	H
	CALL	NO_BETON_CHK
	LD	(HL),113
	DEC	HL
	DEC	HL
	DEC	HL
	DEC	HL
	CALL	NO_BETON_CHK
	LD	(HL),112

	LD	A,1
	LD	(HAS_RADAR),A

	LD	A,10
	CALL	ADD_POWER

	LD	A,(POWER_NEEDED)
	LD	B,A
	LD	A,(POWER_DELIVERED)
	SUB	B
	JP	C,RESET_STATUS

	CALL	INIT_RADAR

	JP	RESET_STATUS

P_SILO:
	CALL	XYTO16

	PUSH	DE

	LD	H,3	; silo is 5
	CALL	ADD_BUILDING
	POP	DE
	OR	A
	RET	Z	; building vol 

	LD	B,D
	LD	C,E
	CALL	CALC_ADR

	CALL	NO_BETON_CHK
	LD	(HL),114	; windtrap erop
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	CALL	NO_BETON_CHK
	LD	(HL),115
	INC	H
	CALL	NO_BETON_CHK
	LD	(HL),117
	DEC	HL
	DEC	HL
	DEC	HL
	DEC	HL
	CALL	NO_BETON_CHK
	LD	(HL),116

	LD	A,5
	CALL	ADD_POWER

	JP	RESET_STATUS

P_WINDTRAP:
	CALL	XYTO16

	PUSH	DE

	LD	H,1	; windtrap is 2
	CALL	ADD_BUILDING
	POP	DE
	OR	A
	RET	Z	; building vol 

	LD	B,D
	LD	C,E
	CALL	CALC_ADR

	CALL	NO_BETON_CHK2
	LD	(HL),100	; windtrap erop
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	CALL	NO_BETON_CHK2
	LD	(HL),101
	INC	H
	CALL	NO_BETON_CHK2
	LD	(HL),103
	DEC	HL
	DEC	HL
	DEC	HL
	DEC	HL
	CALL	NO_BETON_CHK2
	LD	(HL),102

	XOR	A
	LD	B,(IX+12)
	LD	A,(POWER_DELIVERED)
	ADD	B
	JR	C,P_WINDTRAP2

	LD	(POWER_DELIVERED),A
	JP	RESET_STATUS
P_WINDTRAP2:
	LD	A,255
	LD	(POWER_DELIVERED),A
	JP	RESET_STATUS

;------------------------------------------------
; ADD POWER
; in A = power to add
;------------------------------------------------

ADD_POWER:
	LD	B,A
	XOR	A	; clear carry ?
	LD	A,(POWER_NEEDED)
	ADD	B
	JR	C,ADD_POWER_FULL

	LD	(POWER_NEEDED),A
	RET

ADD_POWER_FULL:
	LD	A,255
	LD	(POWER_NEEDED),A
	RET

;----------------------------------------------
ADD_BUILDING:
	LD	A,(BUILDINGS)	; jammer niet meer
	CP	50	; dan 10 stuks !!
	LD	A,0
	RET	Z	; voor de veiligheid

	LD	IX,BUILDING1
	LD	C,BUILD_DATA	; even loopen
	LD	B,50	; max 50 stuks
LOOP_ADD_B:
	LD	A,(IX)
	OR	A
	JR	Z,ADD_BUILD2

	LD	(BUILD_NUM),A

	LD	A,B
	LD	B,0
	ADD	IX,BC
	LD	B,A
	DJNZ	LOOP_ADD_B
	LD	A,0
	RET

BUILD_NUM:	DB	0

ADD_BUILD2:
	LD	A,(BUILD_NUM)
	INC	A
	LD	(IX),A	; nummer vorige + 1
	LD	A,H	;type gebouw
	LD	(IX+1),A
	LD	(IX+2),D
	LD	(IX+3),E
	EXX
	; bewaar info per huisje 
	; anders 
	LD	HL,EXTR_B_DATA
	LD	B,0
	LD	C,A
	SLA	A
	SLA	A
	SLA	A	; maal 8
	ADD	C	; maal 9
	LD	C,A
	ADD	HL,BC

	PUSH	IX
	POP	DE	; DE is dest.
	INC	DE	; type
	INC	DE	;   x
	INC	DE	;   y
	INC	DE	; rest
	LD	BC,9

	LDIR		; pompen of verzuipen ! 

	EXX
	LD	HL,BUILDINGS
	INC	(HL)
	LD	A,1	; gebouw is goed toegevoegd

	RET

NO_BETON_CHK:
	LD	A,(HL)
	CP	64
	RET	Z
	LD	A,(IX+6)
	SUB	32
	LD	(IX+6),A
	RET

NO_BETON_CHK2:	; only for windtraps
	LD	A,(HL)
	CP	64
	RET	Z
	LD	A,(IX+6)
	SUB	32
	LD	(IX+6),A
	XOR	A
	LD	A,(IX+12)	; power
	SUB	4
	LD	(IX+12),A
	RET

RESET_STATUS:
	LD	A,(ITEMSELECTED)
	SUB	64
	LD	D,A

	LD	HL,BBB_VALUE
	SLA	A
	SLA	A
	LD	C,A
	LD	B,0
	ADD	HL,BC
	LD	(HL),1	; maak weer beschikbaar 
	INC	HL
	LD	A,(HL)

	INC	HL
	DEC	A
	LD	(HL),A

	INC	D	; correctie voor berekening

	LD	A,(B_BALK_NR)
	LD	E,A
	CP	D
	JR	NC,RESETSTATUS2
	ADD	A,4
	CP	D
	JR	C,RESETSTATUS2
	SUB	4

	DEC	D
	LD	A,D
	SUB	E
	ADD	A
	ADD	A
	ADD	A
	ADD	A
	ADD	A
	ADD	32
	LD	E,A

	LD	A,D
	ADD	A
	ADD	A
	ADD	A
	ADD	A
	ADD	A
	LD	D,A

	LD	IY,BB_BLW_COP
	CALL	PUTBLK
	CALL	BB_PUT_BUILD
	CALL	P_BB_PART
RESETSTATUS2:
	JP	CANCEL_BB

;---------------------------------------

CANCELACTION:
	LD	HL,BUT_PRESSED
	BIT	1,(HL)
	RET	NZ
	SET	1,(HL)

	LD	A,(MSELECT_ON)
	OR	A
	CALL	NZ,MSEL_OFF

	LD	A,(MBUSY)
	OR	A
	JP	NZ,CHK_CANCEL2

	LD	A,(ITEMSELECTED)
	OR	A
	RET	Z

	CALL	CLEAR_ITEM

	LD	IX,(TNKADR)
	RES	7,(IX+11)
	LD	HL,TANKTAB
	LD	(TNKADR),HL	; ook voor gebouwen ?
	LD	HL,0
	LD	(P_BUILD),HL	; ja dus
	RET

MSEL_OFF:
	LD	HL,TANK1
	LD	BC,22	;BYTE 22
	ADD	HL,BC

	LD	B,127	;tank sum
	LD	DE,TANK_DATA
CANCEL_LOOP:
	RES	0,(HL)
	ADD	HL,DE
	DJNZ	CANCEL_LOOP
	RET

;-----------------------------------------
BB_CANCEL:
	LD	BC,4
	LD	HL,SPRATR+16
	LD	(HL),212
	ADD	HL,BC
	LD	(HL),212
	ADD	HL,BC
	LD	(HL),212
	ADD	HL,BC
	LD	(HL),212
	ADD	HL,BC
	LD	(HL),212
	ADD	HL,BC
	LD	(HL),212

	DI
	LD	A,1
	OUT	(&H99),A
	LD	A,&H8E

	OUT	(&H99),A
	LD	A,&H10
	OUT	(&H99),A
	LD	A,&H76
	OUT	(&H99),A

	LD	HL,SPRATR+16
	LD	BC,&H1898
	OTIR
	EI
	RET

;---------------------------------------
; Build Balk commando
;---------------------------------------
SCRL_BB_L:
	LD	A,(BB_WAIT)
	OR	A
	RET	NZ

	LD	A,(B_BALK_TYPE)
	OR	A
	JR	Z,SCRL_BBB_L

	LD	A,(T_BALK_NR)
	CP	8
	RET	Z
	DEC	A
	LD	(T_BALK_NR),A
	JP	INIT_BBAR

SCRL_BBB_L:
	LD	A,(B_BALK_NR)
	OR	A
	RET	Z
	DEC	A
	LD	(B_BALK_NR),A
	JP	INIT_BBAR

SCRL_BB_R:
	LD	A,(BB_WAIT)
	OR	A
	RET	NZ

	LD	A,(B_BALK_TYPE)
	OR	A
	JR	Z,SCRL_BBB_R

	LD	A,(T_BALK_NR)
	CP	9
	RET	Z
	INC	A
	LD	(T_BALK_NR),A
	JP	INIT_BBAR
SCRL_BBB_R:
	LD	A,(B_BALK_NR)
	CP	4
	RET	Z
	INC	A
	LD	(B_BALK_NR),A
	JP	INIT_BBAR

SCRL_BB_UP:
	LD	A,(BB_WAIT)
	OR	A
	RET	NZ

	LD	A,(B_BALK_TYPE)
	CP	0
	RET	Z

	LD	A,0
	LD	(B_BALK_TYPE),A
	JP	INIT_BBAR

SCRL_BB_DN:
	LD	A,(BB_WAIT)
	OR	A
	RET	NZ

	LD	A,(B_BALK_TYPE)
	CP	32
	RET	Z
	LD	A,32
	LD	(B_BALK_TYPE),A

INIT_BBAR:
	LD	A,6
	LD	(BB_WAIT),A

	LD	A,(B_BALK_TYPE)
	OR	A
	JR	Z,PLACE_BBAR
PLACE_TBAR:
	CALL	SPRITES_OFF
	LD	HL,TBB_VALUE

	LD	A,(T_BALK_NR)
	SUB	8	; start op 9

	ADD	A
	ADD	A
	LD	C,A
	LD	B,0
	ADD	HL,BC	; begin van tbb_valuelijst

	ADD	A
	ADD	A
	ADD	A
	LD	D,A

	CALL	INIT_LOOP_BB

	RET
PLACE_BBAR:
	CALL	SPRITES_OFF

	LD	HL,BBB_VALUE

	LD	A,(B_BALK_NR)

	ADD	A	;  * 4
	ADD	A

	LD	C,A
	LD	B,0
	ADD	HL,BC

	ADD	A
	ADD	A
	ADD	A
	LD	D,A


INIT_LOOP_BB:
	LD	B,4	; aantal plaatjes
	LD	E,32	; plaats op scherm
LOOP_P_BBAR0:
	PUSH	BC
	PUSH	HL
	LD	A,(HL)

	CP	0
	JP	Z,P_BB_EMPTY

	CP	1
	JP	Z,P_BB_OCC

	CP	2
	JP	Z,P_BB_BUSY

	JP	P_BB_READY

END_LOOP_BB:
	POP	HL
	POP	BC
	LD	A,E
	ADD	32
	LD	E,A

	LD	A,D
	ADD	32
END_LOOPBB3:
	LD	D,A
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	DJNZ	LOOP_P_BBAR0
	CALL	SPRITES_ON

	RET

P_BB_EMPTY:
	LD	IY,BB_X_COP
	CALL	PUTBLK
	CALL	P_BB_PART
	JP	END_LOOP_BB

P_BB_OCC:
	LD	IY,BB_BLW_COP
	CALL	PUTBLK
	CALL	BB_PUT_BUILD
	CALL	P_BB_PART
	JP	END_LOOP_BB

P_BB_BUSY:
	LD	IY,BB_BLW_COP
	CALL	PUTBLK
	CALL	BB_PUT_BUILD
	LD	IY,BB_BUSY_COP
	CALL	PUTBLK
	CALL	P_BB_PART
	JP	END_LOOP_BB
P_BB_READY:
	LD	IY,BB_BLW_COP
	CALL	PUTBLK
	CALL	BB_PUT_BUILD
	LD	IY,BB_READY_COP
	CALL	PUTBLK
	CALL	P_BB_PART
	JP	END_LOOP_BB

BB_PUT_BUILD:
	;                        ; check if tank bar
	LD	A,(B_BALK_TYPE)
	OR	A
	JR	Z,BB_PUT_BUILD2
BB_PUT_TANK2:
	LD	IY,BB_TNK_COP
	LD	A,D
	LD	(IY),A
	JP	PUTBLK
BB_PUT_BUILD2:
	LD	IY,BB_BLD_COP
	LD	A,D
	; ADD     32
	LD	(IY),A

	JP	PUTBLK

P_BB_PART:
	LD	IY,BB_MOVE_COP
	LD	(IY+4),E	; plek op scherm
	LD	(IY+7),0
	CALL	PUTBLK
	LD	(IY+7),1
	CALL	PUTBLK
	RET

;-------------------------------------------

SEL_FROM_BB:
	LD	A,(MBUSY)
	OR	A
	RET	NZ

	LD	A,(B_BALK_TYPE)
	OR	A
	JR	Z,SEL_BUILDING

	LD	A,D
	SUB	32
	SRA	A
	SRA	A
	SRA	A
	SRA	A
	SRA	A	; / 32 
	LD	B,A

	LD	A,(T_BALK_NR)
	SUB	8
	ADD	B
	LD	E,A

	ADD	A	;  * 4 
	ADD	A	; 

	LD	C,A

	LD	B,0
	LD	HL,TBB_VALUE
	ADD	HL,BC

	LD	A,(HL)
	OR	A	; niet mogelijk 
	RET	Z
	CP	2	; al bezig 
	RET	Z
	CP	1	; ga beginnen 
	JP	Z,START_BUILD

	RET
SEL_BUILDING:
	LD	A,D
	SUB	32
	SRA	A
	SRA	A
	SRA	A
	SRA	A
	SRA	A	; / 32
	LD	B,A

	LD	A,(B_BALK_NR)
	ADD	B
	LD	E,A

	ADD	A	;  * 4
	ADD	A	;

	LD	C,A

	LD	B,0
	LD	HL,BBB_VALUE
	ADD	HL,BC

	LD	A,(HL)
	OR	A	; niet mogelijk
	RET	Z
	CP	2	; al bezig
	RET	Z
	CP	1	; ga beginnen
	JP	Z,START_BUILD

	; anders is ie ready  !!!!!!

	LD	A,E
	LD	C,A
	ADD	64	; 64 + item

	LD	(ITEMSELECTED),A
	LD	A,1
	LD	(MBUSY),A

	LD	HL,BB_TYPES	; cursor
	LD	B,0
	ADD	HL,BC
	LD	A,(HL)
	LD	(BB_SIZE),A

	LD	IX,(TNKADR)
	RES	7,(IX+11)	; geen tank

	LD	IX,IX_FOR_B
	;  INC     C
	LD	(IX+1),C
	CALL	P_BLD_IMG
	CALL	CANCEL_ITEM

	RET

IX_FOR_B:
	DB	0,0


START_BUILD:
	PUSH	HL

	INC	HL
	INC	HL
	INC	HL
	LD	A,(HL)
	LD	C,A
	LD	B,0
	CALL	CALC_MONEY

	POP	HL
	JR	C,NO_START	; niet genoeg geld

	LD	(HL),2

	LD	A,D	; cursor positie
	AND	&b11100000

	LD	IY,BB_BLD2_COP
	LD	(IY+4),A
	CALL	PUTBLK
	LD	A,(IY+7)
	XOR	1
	LD	(IY+7),A
	CALL	PUTBLK
	RET

NO_START:
	LD	A,50
	LD	(ISTEXT),A
	LD	A,5
	CALL	INIT_TEXT
	RET


;-----------------------------------------
; OPTION MENU  Win 98 version ! cool
; doet even nix
;-----------------------------------------

OPTION_MENU:
	LD	A,200
	LD	(ISTEXT),A
	LD	A,4
	CALL	INIT_TEXT
	RET

	LD	A,(MBUSY)
	OR	A
	RET	NZ

	XOR	A
	LD	(MSTOP),A
	LD	(MOUSE_SHAPE),A
	LD	(CURSOR_TYPE),A
	CALL	PULL_DOWN

MENU_MAIN:
	XOR	A
	;  CALL    FIRE_BUTTON0
	CALL	Z,MENU_COOR

	LD	A,(MSTOP)
	OR	A
	RET	NZ

	JP	MENU_MAIN

MENU_COOR:
	LD	DE,(MOUSEY)

	LD	A,D
	CP	96
	JR	C,MAREA2
	CP	144
	JR	NC,MAREA2
	LD	A,E
	CP	125
	JR	C,MAREA2
	CP	140
	JR	NC,MAREA2

	LD	A,1
	LD	(MSTOP),A
	RET
MAREA2:
	RET


PULL_DOWN:
	LD	A,(SWAP)
	LD	IY,MENU_COP
	LD	(IY+7),A
	CALL	SPRITES_OFF
	LD	B,110
DO_SCROLL:
	XOR	A
	LD	(JIFFY),A

	CALL	MENU_SCRL

MWAIT_LOOP:
	LD	A,(JIFFY)
	CP	1
	JR	C,MWAIT_LOOP
	XOR	A
	LD	(JIFFY),A

	DEC	B
	DEC	B

	JR	NZ,DO_SCROLL
	CALL	MENU_SCRL
	CALL	SPRITES_ON
	RET

MENU_SCRL:
	LD	A,112
	SUB	B
	LD	(IY+2),B
	LD	(IY+10),A
	LD	(IY+8),A
	EXX
	CALL	PUTBLK
	EXX
	RET

;---------------------------------------------
;          INTERRUPT ROUTINE !!!
;-----------------------------------------
INT_ROUTINE:
	DI
	PUSH	AF

	;   XOR     A
	;   OUT     (&H99),A
	;   LD      A,&H8F           ; reg 15 op 0
	;   OUT     (&H99),A

	IN	A,(&H99)	; CHK OF INT VAN VDP IS   
	AND	A
	JP	P,INT_NOT_V9938

	PUSH	BC
	PUSH	DE
	PUSH	HL
	PUSH	IX
	PUSH	IY
	EXX
	PUSH	BC
	PUSH	DE
	PUSH	HL
	CALL	INTERRUPT
	POP	HL
	POP	DE
	POP	BC
	EXX
	POP	IY
	POP	IX
	POP	HL
	POP	DE
	POP	BC
INT_NOT_V9938:
	LD	A,(JIFFY)	; eigen jiffy van 0 - 255 :)
	INC	A
	LD	(JIFFY),A

	POP	AF
	EI
	RETI		; Z80 NORM.... 

;---------------------------------------

INTERRUPT:
	LD	A,(ISTEXT)
	OR	A
	JR	Z,INTT_1
	DEC	A
	LD	(ISTEXT),A

INTT_1:
	LD	A,(BB_WAIT)
	OR	A
	JR	Z,INTT_2
	DEC	A
	LD	(BB_WAIT),A
INTT_2:
	CALL	I_READ_BUTTONS	; buttons uitlezen
	CALL	READ_MOUSIE

	LD	A,(ITEMSELECTED)
	CP	128
	JP	NC,INTT_3
	CP	64
	JP	NC,PLACE_BB_SPR
INTT_3:
	JP	MULTIPLE_SEL
	RET

READ_MOUSIE:
	; Gebruik spratr om x en y op te slaan ! 

	LD	A,(MOUSE_PORT)	; Get mouse port in C 
	LD	C,A
MOUSE1:
	LD	A,(MOUSE_WAIT1)
	LD	B,A	; Get Y move 
	CALL	READ_MOUSE
	RLCA
	RLCA
	RLCA
	RLCA
	LD	H,A
	CALL	READ_MOUSE
	OR	H
	LD	H,A
	CALL	READ_MOUSE	; Get X move 
	RLCA
	RLCA
	RLCA
	RLCA
	LD	L,A
	CALL	READ_MOUSE
	OR	L
	LD	C,H	; B = X-move / C = Y-move 
	LD	B,A

	LD	A,B	; Move -1,-1 ? 
	INC	A
	LD	H,A
	LD	A,C
	INC	A
	OR	H
	JR	NZ,MOUSE3

	LD	A,(MOUSE_USE)	; Check mouse use 
	OR	A
	JR	NZ,MOUSE2

	LD	A,(MOUSE_PORT)	; Check other port 
	XOR	&B01000000
	LD	(MOUSE_PORT),A

	JR	KEYBOARD

MOUSE2:
	LD	A,(MOUSE_OFF)	; na 20 keer -1,-1 is uit 
	INC	A
	LD	(MOUSE_OFF),A
	CP	20
	JR	C,MOUSE4
	XOR	A	; Deactivate mouse 
	LD	(MOUSE_USE),A

	JR	KEYBOARD

MOUSE3:	; Activate mouse / Keep mouse activat 
	XOR	A	; counter op 0 
	LD	(MOUSE_OFF),A
	DEC	A	; wordt weer gebruikt 
	LD	(MOUSE_USE),A

MOUSE4:
	LD	A,B	; If mouse is moved then skip keyboar 
	OR	C
	JR	NZ,CHK_PIJL_BORD	; niet 0,0 dan check 

KEYBOARD:
	; nog even geen keyboard 
	; RET


CHK_PIJL_BORD:	; In: B=y-coordinaat 

	LD	HL,SPRATR
	LD	A,(HL)
	SUB	B

	BIT	7,B
	JR	NZ,CHK_PIJL_BORD_Y1
	JR	NC,CHK_PIJL_BORD_Y3
	XOR	A
	JR	CHK_PIJL_BORD_Y3

CHK_PIJL_BORD_Y1:
	JR	NC,CHK_PIJL_BORD_Y2
	CP	204
	JR	C,CHK_PIJL_BORD_Y3

CHK_PIJL_BORD_Y2:
	LD	A,203

CHK_PIJL_BORD_Y3:
	LD	(HL),A
	INC	HL

	LD	A,(HL)
	SUB	C
	BIT	7,C
	JR	NZ,CHK_PIJL_BORD_X1
	JR	NC,CHK_PIJL_BORD_X3
	XOR	A
	JR	CHK_PIJL_BORD_X3

CHK_PIJL_BORD_X1:
	JR	NC,CHK_PIJL_BORD_X2
	CP	252
	JR	C,CHK_PIJL_BORD_X3
CHK_PIJL_BORD_X2:
	LD	A,251

CHK_PIJL_BORD_X3:
	LD	(HL),A

MOUSE_SPRITE:
	DEC	HL
	; spratr in hl !! 

	LD	A,1
	OUT	(&H99),A
	LD	A,&H8E
	OUT	(&H99),A

	LD	A,&H00	; ff  
	OUT	(&H99),A
	LD	A,&H76	; 35  
	OUT	(&H99),A

	LD	BC,&H0498
	OTIR
	RET

READ_MOUSE:
	LD	A,15
	OUT	(&HA0),A
	LD	A,C
	OUT	(&HA1),A
	XOR	&B00110000
	LD	C,A
	LD	A,14
	OUT	(&HA0),A
READ_MOUSE_L
	DJNZ	READ_MOUSE_L

	LD	A,(MOUSE_WAIT2)
	LD	B,A
	IN	A,(&HA2)
	AND	&H0F
	RET

;-----------------------------------------

I_READ_BUTTONS:
	XOR	A
	CALL	I_FIR_P1
	LD	(FIRE_BUTTONS),A
	RET

I_FIR_P1:	LD	B,A	; A=0 PORT 1 / A=1 PORT 2   
	LD	A,15

	OUT	(&HA0),A
	NOP
	IN	A,(&HA2)

	DJNZ	I_FIR_S1
	AND	&HDF
	OR	&H4C
	JR	I_FIR_S2
I_FIR_S1:	AND	&HAF
	OR	3
I_FIR_S2:	OUT	(&HA1),A
	LD	A,14
	OUT	(&HA0),A
	NOP
	IN	A,(&HA2)
	RET

CHK_SPATIE:
	IN	A,(&HAA)	; check op spatie...        
	AND	&HF0
	OR	8
	OUT	(&HAA),A
	IN	A,(&HA9)
	AND	1
	RET

;--------------------------------------------
;-        SUBS                              -
;--------------------------------------------

UPDATE_STEPS:
	LD	HL,BBB_VALUE
	LD	B,18
UPD_STEPS_L1:
	LD	A,(HL)
	CP	2
	JP	Z,DO_STEP_UPD
	INC	HL
	INC	HL
	INC	HL
	INC	HL
UPD_STEPS_L2:
	DJNZ	UPD_STEPS_L1
	RET

DO_STEP_UPD:
	INC	HL
	LD	A,(HL)
	LD	C,A
	INC	HL
	LD	A,(HL)
	ADD	C
	CP	255
	JP	Z,STEP_READY
	LD	(HL),A
	INC	HL
	INC	HL
	JP	UPD_STEPS_L2
STEP_READY:
	DEC	HL
	DEC	HL
	LD	(HL),3
	JP	UPD_STEPS_L1

;---------------------------------------

MULTIPLE_SEL:
	LD	A,(PLAYFIELD)
	OR	A
	JR	Z,LABEL0009

	LD	A,(FIRE_BUTTONS)
	BIT	4,A
	JR	Z,MS_1
LABEL0009:	;                       ;  ms uit
	XOR	A
	LD	(MS_COUNT),A
	LD	(HAS_SELECT),A
	LD	(TOTAL_SELECT),A
	LD	B,4
	LD	IX,SPRATR+40
	LD	DE,4
LABEL0008:
	LD	(IX),212
	EXX
	CALL	PUT_SPRITE2
	EXX
	ADD	IX,DE
	DJNZ	LABEL0008

	RET

MS_1:
	LD	A,(MS_COUNT)
	CP	10
	JR	Z,MS_2_2
	INC	A
	LD	(MS_COUNT),A
	CP	9
	RET	NZ
MS_2:
	INC	A
	LD	(MS_COUNT),A
	LD	HL,SPRATR
	LD	E,(HL)
	INC	HL
	LD	D,(HL)

	LD	(ORIGIN_Y),DE
	LD	A,1
	LD	(HAS_SELECT),A
	EXX
	LD	A,(MSELECT_ON)
	OR	A
	CALL	NZ,MSEL_OFF
	EXX

MS_2_2:
	LD	HL,SPRATR
	LD	E,(HL)
	INC	HL
	LD	D,(HL)

	LD	A,(ORIGIN_X)
	CP	D
	JR	NC,LABEL0005
	LD	(SEL_X0),A
	LD	A,D
	LD	(SEL_X1),A
	JP	LABEL0006
LABEL0005:
	LD	(SEL_X1),A
	LD	A,D
	LD	(SEL_X0),A

LABEL0006:
	LD	A,(ORIGIN_Y)
	CP	E
	JR	NC,LABEL0007
	LD	(SEL_Y0),A
	LD	A,E
	LD	(SEL_Y2),A
	JP	SEL_METH1
LABEL0007:
	LD	(SEL_Y2),A
	LD	A,E
	LD	(SEL_Y0),A

SEL_METH1:
	LD	BC,(SEL_Y0)
	LD	HL,(SEL_Y2)
	LD	DE,4

	LD	IX,SPRATR+40
	LD	(IX),C
	LD	(IX+1),B
	EXX
	CALL	PUT_SPRITE2
	EXX

	ADD	IX,DE
	LD	(IX),L
	LD	(IX+1),B
	EXX
	CALL	PUT_SPRITE2
	EXX

	ADD	IX,DE
	LD	(IX),C
	LD	(IX+1),H
	EXX
	CALL	PUT_SPRITE2
	EXX

	ADD	IX,DE
	LD	(IX),L
	LD	(IX+1),H
	CALL	PUT_SPRITE2

	RET

ORIGIN_Y:
	DB	0
ORIGIN_X:
	DB	0

SEL_Y0:	DB	0
SEL_X0:	DB	0
SEL_Y2:	DB	0
SEL_X1:	DB	0

;------------------------------------------
A_TO_IY:
	EXX		; schaduw BC,DE,HL !!!! 

	OR	A
	CALL	Z,CRASH

	LD	IY,TANK1-32

	RRC	A
	RRC	A
	RRC	A
	LD	B,A

	AND	&B11100000
	LD	C,A
	LD	A,B
	AND	&B00011111
	LD	B,A

	ADD	IY,BC
	EXX
	RET

HL_TO_IX:	INC	HL
	LD	A,(HL)
	DEC	HL
A_TO_IX:
	EXX		; schaduw BC,DE,HL !!!!

	OR	A
	CALL	Z,CRASH

	LD	IX,TANK1-32

	RRC	A
	RRC	A
	RRC	A
	LD	B,A

	AND	&B11100000
	LD	C,A
	LD	A,B
	AND	&B00011111
	LD	B,A

	ADD	IX,BC
	EXX
	RET

CRASH:
	; CALL    COLOR_WHITE

	;  POP     HL
	;  POP     HL
	;  LD      (CRASH_ADR),HL

	LD	HL,INT_DOS
	CALL	PUT_INT

	CALL	SET_SCREEN0

	LD	SP,(EXIT_STACK)
	RET		; einde prog

EXIT_STACK:	DW	0

CRASH_ADR:
	DW	0

A_TO_BLD:
	LD	IY,BUILDING1-BUILD_DATA
	EXX
	LD	C,A
	LD	B,0
	SLA	C	; *2
	RL	B
	SLA	C	; *4
	RL	B
	LD	D,B	; DE met 4maal
	LD	E,C
	ADD	IY,DE
	ADD	IY,DE	; *8
	ADD	IY,DE	; *12
	LD	C,A
	LD	B,0
	ADD	IY,BC
	EXX
	RET

;----------------------------------------------

VELD:
	LD	A,(SWAP)
	LD	(DOEL_PAGE),A

	XOR	A
	LD	(DOEL_Y),A
	LD	(DOEL_X),A

	LD	HL,(ADR)
	DEC	H
	DEC	HL
	DEC	HL
	DEC	HL
	DEC	HL

	LD	DE,CPYTT

	LD	B,12	; 12 * 12 cpytt   ; x in lengte
	LD	C,12
J8CAF:
	LD	A,(HL)
	EX	AF,AF

	LD	A,C
	CP	1
	JR	Z,MAKE_CPYTT
	CP	12
	JR	Z,MAKE_CPYTT

	LD	A,B
	CP	1
	JR	Z,MAKE_CPYTT
	CP	12
	JR	Z,MAKE_CPYTT

	LD	A,(HL)
	OR	A
	INC	HL
	JR	Z,PUT_FIELD
	LD	A,16
	LD	(BRON_X),A
	XOR	A
	JR	CONT_VELD
PUT_FIELD:
	LD	A,(HL)
	ADD	A
	ADD	A
	ADD	A
	ADD	A
	LD	(BRON_X),A
	LD	A,(HL)
	AND	&B11110000
CONT_VELD:
	LD	(BRON_Y),A
	LD	A,(DOEL_X)
	ADD	16
	LD	(DOEL_X),A

	EXX

	LD	HL,FASTCOP

	DI		; vdp klaar ?

	LD	A,32	; reg 32 + GEEN auto inc.
	OUT	(&H99),A	; als control register
	LD	A,&H91	;in reg 17   
	OUT	(&H99),A

	LD	A,2	; waarde 2 in reg 15
	OUT	(&H99),A
	LD	A,&H8F	; execute
	OUT	(&H99),A
LUS3:
	IN	A,(&H99)	;lees status
	RRA		; is CE nog 1 dan C is loop
	JR	C,LUS3

	XOR	A	; status reg. op 0  
	OUT	(&H99),A
	LD	A,&H8F
	OUT	(&H99),A

	LD	C,&H9B
	OUTI
	OUTI
	OUTI
	OUTI
	OUTI
	OUTI
	OUTI
	OUTI
	OUTI
	OUTI
	OUTI
	OUTI
	OUTI
	OUTI
	OUTI
	EI

	EXX
	DEC	HL
MAKE_CPYTT:
	INC	HL
	INC	HL

	EX	AF,AF
	OR	A
	JR	NZ,CONT_CPYTT
	LD	A,(HL)
	OR	A
	JR	Z,CONT_CPYTT
BLW_CPYTT:
	LD	A,1
	LD	(DE),A
	INC	DE
	LD	A,(HL)	; nummer tank of zo ???
	LD	(DE),A
	INC	DE
CONT_CPYTT:
	INC	HL
	INC	HL
	DEC	B
	JP	NZ,J8CAF

	DEC	C
	JR	Z,END_VELD

	LD	A,(DOEL_Y)
	ADD	16
	LD	(DOEL_Y),A
	XOR	A
	LD	(DOEL_X),A

	LD	A,C
	LD	BC,208	;   54+128        ; !!! 64-10 + 2*64
	ADC	HL,BC
	LD	C,A
	LD	B,12
	JP	J8CAF
END_VELD:
	XOR	A
	LD	(DE),A
	INC	DE
	LD	(DE),A	; laatste entry leeg 
	RET


;----------------------------------------

MLBC16:
	LD	B,0
	LD	C,A

	SLA	C
	RL	B
	SLA	C
	RL	B
	SLA	C
	RL	B
	SLA	C
	RL	B
	RET
;-----------------------------------------

PTANK:
	LD	A,(OFFSET)
	LD	B,A
	LD	A,(IX)
	SUB	B
	INC	A
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,(IX+4)
	LD	(IY+4),A
	CP	16
	JP	C,CONT2
	CP	161
	JP	NC,CONT2
	LD	A,(OFFSET+1)
	LD	B,A
	LD	A,(IX+1)
	SUB	B
	INC	A
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,(IX+5)
	LD	(IY+6),A
	CP	16
	JP	C,CONT2
	CP	161
	JP	NC,CONT2

	CALL	RITANK
	CALL	PUTBLK
	LD	(IY),0
	LD	(IY+2),160

	BIT	0,(IX+22)
	JP	Z,IN_SCREEN

	LD	HL,0	; super multiple select update
	LD	A,(IY+4)
	SRL	A
	LD	C,A
	LD	B,0
	ADD	HL,BC

	LD	A,(IY+6)
	LD	D,A
	LD	B,A
	SRL	B
	RR	C
	LD	C,0
	ADD	HL,BC
	LD	A,D
	AND	&B10000000
	RLC	A
	LD	E,A

	CALL	SETVDP
	LD	A,&hFF
	OUT	(&h98),A

	LD	BC,7
	ADD	HL,BC

	LD	A,E
	CALL	SETVDP
	LD	A,&hFF
	OUT	(&h98),A
;----------------------------------
	LD	BC,15*128-7
	ADD	HL,BC

	LD	A,D
	ADD	15
	AND	&B10000000
	RLC	A
	LD	E,A

	CALL	SETVDP
	LD	A,&hFF
	OUT	(&h98),A

	LD	BC,7
	ADD	HL,BC

	LD	A,E
	CALL	SETVDP
	LD	A,&hFF
	OUT	(&h98),A

	JP	IN_SCREEN

PTANK_UP:
	LD	(IY+4),C

	LD	(IY+6),B

	LD	A,176
	SUB	B
	LD	(IY+10),A


	LD	(IY+8),16
	CALL	RITANK
	CALL	PUTBLK
	LD	(IY+2),160
	LD	(IY+10),16
	LD	(IY),0
	RET

PTANK_LT:
	LD	(IY+6),B
	LD	(IY+4),C

	LD	A,176
	SUB	C
	LD	(IY+8),A

	; LD      (IY+4),A
	LD	(IY+10),16
	CALL	RITANK
	CALL	PUTBLK
	LD	(IY),0
	LD	(IY+2),160
	RET

PTANK_DN:
	LD	(IY+4),C
	LD	(IY+10),B
	LD	A,16
	SUB	B
	ADD	160
	LD	(IY+2),A
	LD	(IY+6),16
	LD	(IY+8),16
	CALL	RITANK
	CALL	PUTBLK
	LD	(IY),0
	LD	(IY+2),160
	RET

PTANK_RI:
	LD	(IY+6),B
	LD	(IY+8),C	; offset copieren
	LD	A,16
	SUB	C
	LD	(IY),A
	LD	(IY+4),16
	LD	(IY+10),16
	CALL	RITANK
	CALL	PUTBLK
	LD	(IY),0
	LD	(IY+2),160
	RET

RITANK:	LD	A,(IX+9)	; richting
	AND	&B00000111	; eventuele radar found bitje weg..
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,(IY)
	LD	(IY),A
	LD	A,(IX+11)
	AND	&B00000111	; type tank
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,(IY+2)
	LD	(IY+2),A
	LD	A,(IX+13)
	AND	&B10000000	;soort bit
	ADD	A,(IY)
	LD	(IY),A
	RET
;---------------------------------------------

XYTO16:	LD	A,D
	SRL	A
	SRL	A
	SRL	A
	SRL	A
	LD	B,A
	LD	A,(OFFSET)
	ADD	A,B
	DEC	A
	LD	D,A
	LD	A,E
	SRL	A
	SRL	A
	SRL	A
	SRL	A
	LD	B,A
	LD	A,(OFFSET+1)
	ADD	A,B
	DEC	A
	LD	E,A
	RET

;------------------------------------
;---  sub routine blocked !!!
;-----------------------------------

BLCKED:
	LD	A,(HL)
	CP	64
	RET		; deze return waarde kan nog veranderen !

CALC_ADR:
	LD	HL,VELD_ADRES

	LD	A,C	; Y MAAL 256
	ADD	H
	LD	H,A

	SLA	B	; X MAAL 4
	SLA	B
	LD	C,B
	LD	B,0
	ADD	HL,BC	; plus x
	INC	HL
	RET

	;
	;  PUSH    HL
	;  PUSH    IX

	;  INC     HL
	;  LD      A,(HL)
	;  OR      A
	;  JR      Z,CALC_ADR2

	;  CALL    A_TO_IX
	;  LD      B,(IX)
	;  LD      C,(IX+1)

	;  LD      HL,VELD_ADRES

	;  LD      A,C              ; Y MAAL 256
	;  ADD     H
	;  LD      H,A

	;  SLA     B                ; X MAAL 4
	;  SLA     B
	;  LD      C,B
	;  LD      B,0
	;  ADD     HL,BC            ; plus x
	;  INC     HL

	;  POP     IX
	;  POP     BC

	;  SBC     HL,BC
	;JP      NZ,CRASH

	;  PUSH    BC
	;  POP     HL
	;  RET
	;

CALC_ADR2:
	;   POP     IX
	;   POP     HL

	;   RET

;--------------------------------------
; UPD_TANK_LAY
;--------------------------------------
RES_TANK_LAY:
	LD	B,(IX)
	LD	C,(IX+1)
	CALL	CALC_ADR

	LD	A,(HL)
	CP	1
	JR	Z,RES_TANK_LAY2
	CP	16
	JR	NC,RES_TANK_LAY2

	LD	A,(IX+9)
	AND	&B00000011
	ADD	2
	LD	(HL),A

RES_TANK_LAY2:
	LD	B,0
	LD	A,(IX+13)
	CP	127
	JR	NC,NO_RADREVEAL	; rood ontdekt niet !!
	LD	B,255
NO_RADREVEAL:
	INC	B

	INC	HL
	LD	(HL),0	; RESET tank positie
	RET

;-----------------------------------------------
CLEAR_ITEM:
	XOR	A
	LD	(ITEMSELECTED),A
	LD	(CURSOR_TYPE),A
	LD	(MBUSY),A
	LD	(ACTIVE_MENU),A	; commando balk reset

	CALL	SPRITES_OFF

	LD	IY,MENU_COM_CLN
	XOR	A
	LD	(IY+7),A
	LD	A,72
	LD	(IY+6),A
	CALL	PUTBLK
	LD	A,80
	LD	(IY+6),A
	CALL	PUTBLK
	LD	A,88
	LD	(IY+6),A
	CALL	PUTBLK
	LD	A,96
	LD	(IY+6),A
	CALL	PUTBLK
	LD	A,58
	LD	(IY+6),A
	CALL	PUTBLK

	LD	IY,MENU_COM_SWP
	CALL	PUTBLK

	LD	IY,EMPTY
	LD	(IY+7),0
	CALL	PUTBLK
	LD	(IY+7),1
	CALL	PUTBLK

	JP	SPRITES_ON

SHOW_POWER:
	; show power units maar eerst die van windtraps !!

	DI		; eerst even int uit voor de sprites

	LD	HL,&H3000+14*128+109
	LD	(VDPADR),HL
	LD	A,0
	CALL	SETVDP2

	LD	A,(POWER_DELIVERED)
	SRL	A
	SRL	A
	SRL	A	; deel door 16
	SRL	A
	JR	Z,SHOW_POWER1

	LD	B,A
	EX	AF,AF
	LD	A,17
	SUB	B
	LD	C,A
	LD	A,&B10111011
POWERLOOP1:
	OUT	(&H98),A
	DJNZ	POWERLOOP1

	LD	B,C
	LD	A,&B00000000
POWERLOOP2:
	OUT	(&H98),A
	DJNZ	POWERLOOP2

SHOW_POWER1:
	LD	HL,&H3000+15*128+109
	LD	(VDPADR),HL
	LD	A,0
	CALL	SETVDP2

	LD	A,(POWER_NEEDED)
	SRL	A
	SRL	A
	SRL	A	; deel door 16
	SRL	A
	JR	Z,SHOW_POWER2

	LD	B,A
	EX	AF,AF
	LD	A,17
	SUB	B
	LD	C,A
	LD	A,&B10001000
POWERLOOP3:
	OUT	(&H98),A
	DJNZ	POWERLOOP3

	LD	B,C
	LD	A,&B00000000
POWERLOOP4:
	OUT	(&H98),A
	DJNZ	POWERLOOP4

SHOW_POWER2:
	EI		; int aan

	LD	IY,POWER_BLOCK
	CALL	PUTBLK

	LD	A,(ITEMSELECTED)
	OR	A
	RET	Z

	CP	2
	JP	Z,HARV_INHOUD

	CP	127
	JR	NC,BUILDING_POW
	CP	64
	RET	NC

	LD	IX,(TNKADR)
	LD	A,(IX+12)	; power berekenen 
	JP	SHOW_POW2

BUILDING_POW:
	LD	IX,(P_BUILD)
	LD	A,(IX+6)

SHOW_POW2:
	EX	AF,AF

	LD	A,(SWAP)
	XOR	1
	LD	E,A

	LD	IY,POWER_INFO	; volledige balk
	LD	(IY+7),E	; naar onzichtbare scherm
	CALL	PUTBLK
	EX	AF,AF

	SRL	A
	SRL	A
	SRL	A
	LD	B,A
	LD	A,31
	SUB	B
	RES	0,A	; even getal
	OR	A
	JR	Z,SHOW_POW3	; full power
	;

	LD	IY,POWER_BALK
	LD	(IY+8),A
	LD	(IY+7),E
	CALL	PUTBLK
SHOW_POW3:
	LD	IY,POWER_COP
	LD	(IY+3),E	; from onzichtbaar
	LD	A,E
	XOR	1
	LD	(IY+7),A	; to zichtbaar
	CALL	PUTBLK
	; nou nog het upgrade balkje

	LD	A,(ITEMSELECTED)
	CP	127
	RET	C

	BIT	1,(IX+8)
	RET	Z	; geen upgrade bar

	LD	A,(IX+11)	; upgrade status
	OR	A
	RET	Z

	SRL	A
	SRL	A
	SRL	A
	RES	0,A
	OR	A
	RET	Z
	LD	B,A

	LD	IY,HARV_BALK

	LD	A,32
	SUB	B
	LD	(IY+2),A

	ADD	24
	LD	(IY+6),A
	LD	(IY+10),B
	LD	A,(SWAP)
	LD	(IY+7),A
	EX	AF,AF
	CALL	PUTBLK
	LD	IY,HARV_COP
	EX	AF,AF
	LD	(IY+3),A
	XOR	1
	LD	(IY+7),A
	JP	PUTBLK
	RET

HARV_INHOUD:	;                ; harv inhoud displayen
	LD	IX,(TNKADR)
	LD	A,(IX+16)
	CP	7
	RET	C
	SUB	6
	SRL	A
	LD	B,A

	LD	IY,HARV_BALK

	LD	A,32
	SUB	B
	LD	(IY+2),A

	ADD	24
	LD	(IY+6),A
	LD	(IY+10),B
	LD	A,(SWAP)
	LD	(IY+7),A
	EX	AF,AF
	CALL	PUTBLK
	LD	IY,HARV_COP
	EX	AF,AF
	LD	(IY+3),A
	XOR	1
	LD	(IY+7),A
	JP	PUTBLK

COMMAND_TANK:
	LD	D,&B10000111
	JP	EXTRACT_COM
COMMAND_HARV:
	LD	D,&B00011110
	JP	EXTRACT_COM
COMMAND_B:
	LD	IY,(P_BUILD)
	LD	D,&B01000000
	BIT	0,(IY+8)
	JR	NZ,COMMAND_B3

	LD	D,&B00100000
	BIT	1,(IY+8)
	JR	NZ,COMMAND_B3

	LD	D,0
	LD	A,(IY+6)
	CP	255	; niet helemaal
	JR	Z,COMMAND_B2	; ?huh

	LD	D,&B01000000
COMMAND_B2:
	LD	A,(IY+10)
	SUB	(IY+9)
	JR	Z,COMMAND_B4
	LD	A,&B00100000
	OR	D
	LD	D,A
	JP	COMMAND_B4
COMMAND_B3:
	LD	A,&B10000000
	OR	D
	LD	D,A

COMMAND_B4:
	JP	EXTRACT_COM

CANCEL_ITEM:
	LD	D,&B10000000
	JP	EXTRACT_COM
COMMAND_ENM:
	LD	D,0
EXTRACT_COM:
	CALL	SPRITES_OFF

	LD	IY,MENU_COM_CLN
	XOR	A
	LD	(IY+7),A
	LD	A,72
	LD	(IY+6),A
	CALL	PUTBLK
	LD	A,80
	LD	(IY+6),A
	CALL	PUTBLK
	LD	A,88
	LD	(IY+6),A
	CALL	PUTBLK
	LD	A,96
	LD	(IY+6),A
	CALL	PUTBLK

	BIT	0,D
	LD	IY,MENU_COM_ATT
	CALL	NZ,PUTBLK
	BIT	1,D
	LD	IY,MENU_COM_MOV
	CALL	NZ,PUTBLK
	BIT	2,D
	LD	IY,MENU_COM_STP
	CALL	NZ,PUTBLK
	BIT	3,D
	LD	IY,MENU_COM_RET
	CALL	NZ,PUTBLK
	BIT	4,D
	LD	IY,MENU_COM_HRV
	CALL	NZ,PUTBLK
	BIT	5,D
	LD	IY,MENU_COM_UPG
	CALL	NZ,PUTBLK
	BIT	6,D
	LD	IY,MENU_COM_REP
	CALL	NZ,PUTBLK
	BIT	7,D
	LD	IY,MENU_COM_CAN
	CALL	NZ,PUTBLK

	LD	IY,MENU_COM_SW2
	CALL	PUTBLK
	JP	SPRITES_ON

;-------------------------------------------

REMOVE_TANK:
	; XOR     A                ; sample nummer 0
	; CALL    PLAY

	LD	D,(IX)
	LD	E,(IX+1)
	LD	B,D
	LD	C,E

	PUSH	IX
	LD	IX,PLOF_BUF
	LD	(IX),D
	LD	(IX+1),E
	CALL	ADD_PLOFJE
	POP	IX

	CALL	CALC_ADR	; 2 byte veld layer op 0
	LD	A,(HL)
	CP	16
	JR	NC,REMOVE_TANK2
	LD	A,R
	AND	&b00000011
	ADD	6
	LD	(HL),A
REMOVE_TANK2:
	INC	HL
	LD	(HL),0

	LD	C,(IX+25)	; Y
	LD	B,(IX+24)	; X
	CALL	CALC_ADR
	DEC	HL
	LD	A,(HL)
	OR	A
	JR	NZ,REMOVE_TANK3
	INC	HL
	CALL	POINT
	LD	D,A

	CALL	PLACE_UNIT
REMOVE_TANK3:
	BIT	7,(IX+11)
	CALL	NZ,CLEAR_ITEM

	LD	A,(IX+23)
	AND	&H0F
	CALL	NZ,AI_UPDATE	; ALS TNK EEN MIS HEEFT UPD DAN

	LD	A,(IX+13)	; nummer tank
	LD	H,A

	LD	B,254	; tank sum
	LD	DE,TANK_DATA	;loop door de tabel om attack
	LD	IY,TANK1	; nummers te resetten !!
LABEL0010:
	LD	A,(IY+14)
	CP	H
	CALL	Z,RES_ATTACK

	ADD	IY,DE
	DJNZ	LABEL0010

	; remove tank uit tnk_totaal
	; verschilt per tank

	LD	A,(IX+13)
	CP	128
	JR	C,REM_TNK_BLW

	LD	HL,(DED_CNT_RED)
	INC	HL
	LD	(DED_CNT_RED),HL

	LD	HL,TNK_CNT_RED
	JR	LABEL0012
REM_TNK_BLW:
	LD	HL,(DED_CNT_BLW)
	INC	HL
	LD	(DED_CNT_BLW),HL

	LD	HL,TNK_CNT_BLW
LABEL0012:
	DEC	(HL)

	PUSH	IX
	POP	HL
	LD	BC,TANK_DATA
LABEL0011:
	LD	(HL),0
	INC	HL
	DEC	BC
	LD	A,B
	OR	C
	JP	NZ,LABEL0011

	RET

RES_ATTACK:
	LD	(IY+14),0
	RES	5,(IY+11)
	RES	6,(IY+11)
	SET	4,(IY+11)
	LD	A,(IY+22)	; reset inslag shoot en
	AND	&B10000001	; of er op je geschotenis
	LD	(IY+22),A

	LD	A,(IY)
	LD	(IY+2),A
	LD	A,(IY+1)
	LD	(IY+3),A
	RET

REMOVE_BUILD:
	LD	IX,PLOF_BUF

	LD	D,(IY+2)
	LD	E,(IY+3)
	LD	B,D
	LD	C,E
	CALL	CALC_ADR
	LD	B,(IY+5)	;hoogte gebouw
REM_B_LOOPY:
	PUSH	HL
	PUSH	DE
	PUSH	BC

	LD	B,(IY+4)	; lengte gebouw
REM_B_LOOPX:
	LD	(IX),D
	LD	(IX+1),E

	CALL	ADD_PLOFJE
	LD	A,R
	AND	&b00000011
	ADD	65
	LD	(HL),A	; random stukje
	INC	D
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	DJNZ	REM_B_LOOPX

	POP	BC
	POP	DE
	POP	HL

	INC	E
	INC	H

	DJNZ	REM_B_LOOPY

	LD	HL,BUILDINGS
	DEC	(HL)	; gebouw -1

	LD	A,(IY)
	LD	(IY),0	; nummer op 0 is gebouw weg

	LD	A,(ITEMSELECTED)
	BIT	7,A
	RET	Z

	PUSH	IY
	POP	BC
	LD	IX,(P_BUILD)
	PUSH	IX
	POP	HL
	SBC	HL,BC
	JP	Z,CLEAR_ITEM
	RET
;-----------------------------------
; ADD_PLOFJE
;
; IN:  PLOF_BUF GEVULD ! X EN Y
;
;-----------------------------------

PLOF_BUF:	DB	0,0

ADD_PLOFJE:
	EXX
	LD	A,(PLOF_BUF)
	LD	D,A
	LD	A,(PLOF_BUF+1)
	LD	E,A

	LD	HL,PLOF_TABEL
	INC	HL
	INC	HL
	LD	A,80	; max ontplof stukjes
	LD	B,A
CHECK_PLOF:
	LD	A,(HL)
	OR	A
	JR	Z,LABEL0002

	INC	HL
	INC	HL
	INC	HL
	DJNZ	CHECK_PLOF	; even opletten
	RET		; max. plof bereikt
LABEL0002:

	LD	A,(PLOF_COUNT)
	INC	A	; 1 plofke erbij
	LD	(PLOF_COUNT),A

	LD	(HL),8	; NUMMER
	DEC	HL
	LD	(HL),E	; EN Y
	DEC	HL
	LD	(HL),D	; EN X
	EXX
	RET

;----------------------------------
; SPICE PLOF
;----------------------------------

WAIT:	DB	0

SPICE_BOOM:
	LD	A,(WAIT)
	INC	A
	AND	&B00000111
	LD	(WAIT),A
	RET	NZ

	LD	IX,(TNKADR)
	LD	B,(IX)
	LD	C,(IX+1)
	CALL	CALC_ADR
	PUSH	HL
	LD	IX,SPICE_RAD
	LD	B,9
SPICE_BOOM_LP:
	POP	HL
	PUSH	HL
	LD	E,(IX)
	LD	D,(IX+1)
	ADC	HL,DE
	LD	D,0
	LD	A,(HL)
	CP	48
	JR	NC,END_BOOM_LP

	CP	16
	JR	C,NORMAL_SPICE

	CP	32
	JR	C,EXTRA_SPICE

	LD	(HL),32
	JR	END_BOOM_LP
EXTRA_SPICE:
	LD	A,16
	LD	D,A
NORMAL_SPICE:
	LD	A,(IX+2)
	ADD	D
	LD	(HL),A
END_BOOM_LP:
	LD	DE,3
	ADD	IX,DE
	DJNZ	SPICE_BOOM_LP
	POP	HL
	RET

;-----------------------------------
; Music Module init
;-----------------------------------

MMODULE_INIT:
	LD	B,12
	LD	HL,PDATA_1

PLOOP1:	LD	A,(HL)
	OUT	(&HC0),A	; OUT REG    
	INC	HL
	LD	A,(HL)
	OUT	(&HC1),A	; OUT INHOUD    
	INC	HL
	DJNZ	PLOOP1	; TILL B=0 
	RET


;------------------------------------
; Play a sample
; A register bevat nummer sample
;-----------------------------------

PLAY:
	LD	HL,SAMPLES
	SLA	A
	LD	C,A
	LD	B,0
	ADD	HL,BC
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL

	LD	B,6

PLOOP2:	LD	A,(HL)
	OUT	(&HC0),A	; OUT REG
	INC	HL
	LD	A,(HL)
	OUT	(&HC1),A	; OUT INHOUD
	INC	HL
	DJNZ	PLOOP2	; TILL B=0
	RET

SAMPLES:
	DW	SAM_PLOF1
	DW	SAM_PLOF2

SAM_PLOF1:
	DB	7,1	; MOET!!!
	DB	9,0
	DB	10,0
	DB	11,&HFF	; EI LOW
	DB	12,&H07	; EI HI
	DB	7,&HA0	: IETS (&HA0 IS PLAY)

SAM_PLOF2:
	DB	7,1	; MOET!!! 
	DB	9,0
	DB	10,0
	DB	11,&HFF	; EI LOW 
	DB	12,&H07	; EI HI 
	DB	7,&HA0	: IETS (&HA0 IS PLAY)


; --------- swap mode   ----------------

CHANGE_INT:
	DI		; is dit nodig ? 
	LD	A,(&HF3DF)
	RES	4,A
	LD	(&HF3DF),A
	OUT	(&H99),A
	LD	A,128+0
	OUT	(&H99),A

	LD	A,16
	OUT	(&H99),A
	LD	A,128+19
	OUT	(&H99),A
	EI
	RET

;---------------------------------
; CALCULATE MONEY
; BC bevat bedrag * 10
; UIT Carry is te weinig !!!
;---------------------------------

CALC_MONEY:
	LD	HL,(MONEY)
	SBC	HL,BC
	RET	C
	LD	(MONEY),HL
	RET

;---------------------------------
; PLAATS MONEY
;----------------------------------

PUT_MONEY:
	LD	HL,(DIS_MONEY)
	LD	BC,(MONEY)
	SBC	HL,BC
	RET	Z
	LD	HL,(DIS_MONEY)
	JR	C,INC_MONEY

	DEC	HL
	DEC	HL
	DEC	HL
	DEC	HL
INC_MONEY:
	INC	HL
	INC	HL

	LD	(DIS_MONEY),HL

	LD	IY,DEEL2
	LD	IX,MONEY_CHAR
	LD	B,5	; aantal cijfers te delen

	CALL	DLINI

	LD	IX,MONEY_CHAR
	LD	HL,(MONEY_POS)
	LD	D,5

	JP	PUT_CHARS

PUT_FPS:
	RET

	;    LD      HL,(DED_CNT_RED)
	;    LD      IY,DEEL2
	;     LD      IX,MONEY_CHAR
	;     LD      B,5              ; aantal cijfers te delen

	;     CALL    DLINI
	;
	;      LD      IX,MONEY_CHAR
	;      LD      HL,(MONEY_POS)
	;      LD      D,5

	;      JP      PUT_CHARS

;----------------------------------
; DEEL - delen van getallen
;----------------------------------

DLINI:
	LD	D,(IY+1)
	LD	E,(IY)
	XOR	A

DEEL:
	SBC	HL,DE
	JR	C,ENDLP1
	INC	A
	JR	DEEL
ENDLP1:
	ADD	HL,DE
	LD	(IX),A
	LD	A,B
	CP	1
	RET	Z

	INC	IX
	INC	IY
	INC	IY
	DEC	B
	LD	D,(IY+1)
	LD	E,(IY)
	XOR	A
	JR	DEEL
;----------------------------------------
; PUT KARAKTER
;-------------------------------------

PUT_CHARS:
	LD	IY,LETCOP
	LD	(IY+4),L
	LD	(IY+6),H
PUT1LP:
	LD	A,(IX)
	SLA	A
	SLA	A
	SLA	A	;3 KEER = 8  > 2^3 
	;LD      B,A
	; LD      A,96
	;ADD     B
	LD	(IY),A

	CALL	PUTBLK
	LD	A,(IY+7)
	XOR	1
	LD	(IY+7),A
	CALL	PUTBLK

	LD	A,(IY+4)
	ADD	8
	LD	(IY+4),A

	INC	IX
	DEC	D
	JR	NZ,PUT1LP
	RET
;--------------------------------------------

INIT_TEXT:
	EXX
	LD	HL,TEXTTAB
	LD	B,0
	LD	C,A
	SLA	C
	RL	B
	ADD	HL,BC
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	(TEXTADR),DE
	EXX
	RET

;--------------------------------------------
PUT_TEXT:
	LD	IY,LETCOP2
	LD	DE,(TEXTADR)

	LD	(IY+4),20
	LD	(IY+6),20
PUT2LP:
	LD	A,(DE)
	CP	255
	RET	Z
	CP	32
	JR	Z,PUT2LP_CONT
DEBUG:
	SUB	46
	LD	B,0
	SLA	A
	RL	B
	SLA	A
	RL	B
	SLA	A	;3 KEER = 8  > 2^3  
	RL	B
	LD	(IY),A
	SLA	B
	SLA	B
	SLA	B
	LD	A,B
	ADD	136
	LD	(IY+2),A

	LD	A,(SWAP)
	LD	(IY+7),A
	CALL	PUTBLK
PUT2LP_CONT:
	INC	DE
	LD	A,(IY+4)
	ADD	6
	LD	(IY+4),A
	CP	160
	JR	C,PUT2LP
	LD	A,(IY+6)
	ADD	8
	LD	(IY+6),A
	LD	A,20
	LD	(IY+4),A
	JR	PUT2LP

;--------------------------------------

; routine voor kopieren van stukken scherm
; gewijzigd worden

; AF
; BC
; HL

PUTBLK:

	DI		; vdp klaar ? 
	LD	A,2	; waarde 2 in reg 15 
	OUT	(&H99),A
	LD	A,&H8F	; execute 
	OUT	(&H99),A
	NOP
	NOP		; wacht op vdp 
LUS2:
	IN	A,(&H99)	;lees status 
	RRA		; is CE nog 1 dan C is loop 
	JR	C,LUS2

	XOR	A	; status reg. op 0
	OUT	(&H99),A
	LD	A,&H8F	; reg 15 op 0  voor int!
	OUT	(&H99),A

	PUSH	IY	; hl moet iy bevatten !! 
	POP	HL

	LD	A,&H20	; register 32 
	OUT	(&H99),A	; als control register 
	LD	A,&H91	;in reg 17 
	OUT	(&H99),A
	; LD      BC,&H0F9B        ; 15 bytes naar port 9b

	LD	C,&H9B
	OUTI
	OUTI
	OUTI
	OUTI
	OUTI
	OUTI
	OUTI
	OUTI
	OUTI
	OUTI
	OUTI
	OUTI
	OUTI
	OUTI
	OUTI
	EI

	RET



;--------------------------------------------
; put sprite
; in = IX met attribuut tabel bevat ook nummer sprite
;-----------------------------------------


PUT_SPRITE:
	DI
	LD	A,1
	OUT	(&H99),A
	LD	A,&H8E
	OUT	(&H99),A
	LD	C,(IX+3)
	LD	B,0
	LD	HL,&H7600	; ipv 35FF
	ADD	HL,BC
	LD	A,L
	OUT	(&H99),A
	LD	A,H
	OUT	(&H99),A
	PUSH	IX
	POP	HL	; hl bevat attribuut tabel  
	LD	BC,&H0498
	OTIR
	EI
	RET

PUT_SPRITE2:
	LD	A,1
	OUT	(&H99),A
	LD	A,&H8E
	OUT	(&H99),A
	LD	C,(IX+3)
	LD	B,0
	LD	HL,&H7600	; ipv 35FF
	ADD	HL,BC
	LD	A,L
	OUT	(&H99),A
	LD	A,H
	OUT	(&H99),A
	PUSH	IX
	POP	HL	; hl bevat attribuut tabel   
	LD	BC,&H0498
	OTIR
	RET

SPRITE_CLR:
	LD	A,1	; Zet sprite kleur
	OUT	(&H99),A
	LD	A,&H8E
	OUT	(&H99),A

	LD	HL,&H7400	; 33FF
	ADD	HL,BC

	LD	A,L
	OUT	(&H99),A
	LD	A,H
	OUT	(&H99),A

	EX	DE,HL
	LD	BC,&H1098
	OTIR
	RET

PLACE_BB_SPR:
	XOR	A
	LD	(BB_BLOCKED),A
	LD	A,1
	LD	(BB_OUT_RANGE),A

	LD	IX,SPRATR+16
	LD	IY,BB_SERIE

	LD	HL,SPRATR

	LD	A,(HL)
	AND	&B11110000
	LD	E,A

	INC	HL
	LD	A,(HL)
	AND	&B11110000
	LD	D,A
	PUSH	DE

	CALL	XYTO16	; adres van eerste 
	LD	B,D
	LD	C,E
	CALL	CALC_ADR

	LD	A,(BB_SIZE)
	LD	(IY),A	; size in serie 
	INC	IY
	LD	B,A

SPR_LOOP0:
	LD	A,(BB_OUT_RANGE)
	OR	A
	JR	Z,SPR_LOOP0_CNT

	CALL	IS_OUT_RANGE
	;  LD      A,(BB_OUT_RANGE)
	;  OR      A
	;  JR      NZ,ADD_RED
SPR_LOOP0_CNT:
	DEC	HL
	LD	A,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	E,(HL)
	DEC	HL
	OR	A
	JR	NZ,ADD_RED
	LD	A,E
	OR	A
	JR	NZ,ADD_RED
	LD	A,D
	CP	64
	JR	C,ADD_RED
	CP	80
	JR	NC,ADD_RED

ADD_WHT:
	XOR	A
	LD	(IY),A
	JP	END_LOOP0
ADD_RED:
	LD	A,1
	LD	(IY),A

END_LOOP0:
	INC	IY
	CALL	CALC_NXT_ADR

	DJNZ	SPR_LOOP0

	POP	DE	;adres weer terug

	LD	IY,BB_SERIE

	LD	B,(IY)
	LD	C,0
	INC	IY
SPR_LOOP1:
	PUSH	BC

	PUSH	DE

	LD	A,E
	CP	16
	JP	C,OUT_RANGE
	CP	176
	JP	NC,OUT_RANGE
	LD	A,D
	CP	16
	JP	C,OUT_RANGE
	CP	176

	JP	C,IN_RANGE

OUT_RANGE:
	LD	E,212
IN_RANGE:
	LD	(IX),E
	LD	(IX+1),D

	CALL	KAN_BB_SPR
	POP	DE

	LD	BC,4
	ADD	IX,BC
	INC	IY

	POP	BC
	INC	C
	CALL	NEXT_COOR

	DJNZ	SPR_LOOP1
	RET

NEXT_COOR:
	LD	A,B
	DEC	A
	RET	Z

	CP	1
	JP	Z,NEXT_COOR1

	CP	2
	JP	Z,NEXT_COOR2

	CP	3
	JP	Z,NEXT_COOR1

	CP	4
	JP	Z,NEXT_COOR2

NEXT_COOR1:
	LD	A,E
	ADD	A,16
	LD	E,A
	RET

NEXT_COOR2:
	LD	A,D
	ADD	A,16
	LD	D,A
	LD	A,E
	SUB	A,16
	LD	E,A
	RET

CALC_NXT_ADR:
	LD	A,B
	DEC	A
	RET	Z

	CP	1
	JP	Z,NEXT_ADR1

	CP	2
	JP	Z,NEXT_ADR2

	CP	3
	JP	Z,NEXT_ADR1

	CP	4
	JP	Z,NEXT_ADR2
NEXT_ADR1:
	INC	H
	RET
NEXT_ADR2:
	DEC	H
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	RET

KAN_BB_SPR:
	LD	A,C
	ADD	4
	LD	C,A
	SLA	C
	SLA	C
	SLA	C
	SLA	C
	LD	B,0

	LD	A,(IY)
	CP	0
	JP	Z,BB_SPR_WHT
	JP	BB_SPR_RED

IS_OUT_RANGE:
	PUSH	HL
	LD	D,1

	DEC	H
	CALL	BB_TEST_RANGE

	INC	HL
	INC	HL
	INC	HL
	INC	HL
	CALL	BB_TEST_RANGE

	INC	H
	CALL	BB_TEST_RANGE
	INC	H
	CALL	BB_TEST_RANGE

	DEC	HL
	DEC	HL
	DEC	HL
	DEC	HL
	CALL	BB_TEST_RANGE

	DEC	HL
	DEC	HL
	DEC	HL
	DEC	HL
	CALL	BB_TEST_RANGE

	DEC	H
	CALL	BB_TEST_RANGE
	DEC	H
	CALL	BB_TEST_RANGE
	POP	HL

	LD	A,D
	LD	(BB_OUT_RANGE),A

	RET
BB_TEST_RANGE:
	LD	A,(HL)
	CP	128
	RET	NC

	LD	(STORAGE1),A

	LD	A,(ITEMSELECTED)
	CP	64
	JR	NZ,BB_TEST_RANGE2

	LD	A,(HL)
	CP	64
	JR	Z,BB_TEST_RANGE3
BB_TEST_RANGE2:
	LD	A,(STORAGE1)
	CP	96
	RET	C
BB_TEST_RANGE3:
	LD	D,0
	RET

STORAGE1:	DB	0


BB_SPR_WHT:
	LD	A,(BB_OUT_RANGE)
	OR	A
	JR	NZ,BB_SPR_RED

	LD	DE,SPRKLR_WHT
	CALL	SPRITE_CLR
	JP	PUT_SPRITE2
BB_SPR_RED:
	LD	A,1
	LD	(BB_BLOCKED),A
	LD	DE,SPRKLR_RD
	CALL	SPRITE_CLR
	JP	PUT_SPRITE2
;--------------------------------------------------
; ADD TANK !!
;
; routine die een tank toevoegd
;
; IN:
;     HL = coordinaten  H=Y   L=X
;     BC = soort tank & type   B=soort    C=type
;
; UIT:
;     A = nummer tank > 0 is gelukt
;
;-----------------------------------------------
ADD_TANK:
	LD	A,B
	OR	A
	JP	Z,ADD_TNK_RED

	LD	A,(TNK_CNT_BLW)
	CP	127	; NIET MEER DAN 127 TANKS
	LD	A,0
	RET	Z	;

	LD	A,(TNK_CNT_BLW)
	INC	A
	LD	(TNK_CNT_BLW),A

	LD	IX,TEMPLATE_TNK
	LD	(IX+11),C

	LD	(IX),H	; X EN Y
	LD	(IX+2),H
	LD	(IX+1),L	;
	LD	(IX+3),L	; dest. = source

	LD	IY,TANK1
	LD	DE,TANK_DATA
	LD	B,0	; niet 0 MAAR 1 !!!!!
LP_CALC_BLW:
	INC	B
	LD	A,(IY+13)
	OR	A
	JR	Z,ADD_TANK3
	ADD	IY,DE
	JR	LP_CALC_BLW

ADD_TANK3:
	LD	(IX+13),B	; nummer
	LD	(IX+12),255	; power

	LD	HL,TEMP_HARV	; search template
	LD	B,0
	SLA	C
	SLA	C
	ADD	HL,BC

	LD	A,(HL)
	LD	(IX+10),A	;speed byte
	INC	HL
	LD	A,(HL)
	LD	(IX+16),A	; attack
	INC	HL
	LD	A,(HL)
	LD	(IX+17),A	; shield
	INC	HL
	LD	A,(HL)
	LD	(IX+18),1	; wait time
	LD	(IX+19),A

	SET	5,(IX+23)	; set guard bitje !

	PUSH	IX
	POP	HL	;bron
	LD	BC,TANK_DATA	; aantal
	PUSH	IY
	POP	DE	; dest
	LDIR

	LD	B,(IY)
	LD	C,(IY+1)
	CALL	CALC_ADR
	LD	A,(IX+13)
	INC	HL
	LD	(HL),A	; update veld layer
	DEC	HL
	DEC	HL
	LD	(HL),0
	RET


ADD_TNK_RED:
	LD	A,(TNK_CNT_RED)
	CP	127	; NIET MEER DAN 127 TANKS 
	LD	A,0
	RET	Z	;

	LD	A,(TNK_CNT_RED)
	INC	A
	LD	(TNK_CNT_RED),A

	LD	IX,TEMPLATE_TNK
	LD	(IX+11),C

	LD	(IX),H	; X EN Y
	LD	(IX+2),H
	LD	(IX+1),L	;
	LD	(IX+3),L	; dest. = source

	LD	IY,TANKRED
	LD	DE,TANK_DATA
	LD	B,127	; dan is ie 128 bij de eerste loop
LP_CALC_RED:
	INC	B
	LD	A,(IY+13)
	OR	A
	JR	Z,ADD_TANK4
	ADD	IY,DE
	JR	LP_CALC_RED

ADD_TANK4:
	LD	(IX+13),B	; nummer 
	LD	(IX+12),255	; power 

	LD	HL,TEMP_HARV	; search template 
	LD	B,0
	SLA	C
	SLA	C
	ADD	HL,BC

	LD	A,(HL)
	LD	(IX+10),A	;speed byte 
	INC	HL
	LD	A,(HL)
	LD	(IX+16),A	; attack 
	INC	HL
	LD	A,(HL)
	LD	(IX+17),A	; shield 
	INC	HL
	LD	A,(HL)
	LD	(IX+18),1	; wait time 
	LD	(IX+19),A

	PUSH	IX
	POP	HL	;bron 
	LD	BC,TANK_DATA	; aantal 
	PUSH	IY
	POP	DE	; dest 
	LDIR

	LD	B,(IY)
	LD	C,(IY+1)
	CALL	CALC_ADR
	LD	A,(IX+13)
	INC	HL
	LD	(HL),A	; update veld layer 
	RET


TEST_ADD_TNK:
	;                LD      HL,(MONEY)       ; MAX 2TOTDE15
	;               LD      BC,30
	;              XOR     A
	;             SBC     HL,BC
	;            RET     C

	LD	A,R
	AND	&b00000011
	ADD	25
	LD	B,A

	LD	C,18
	PUSH	BC
	CALL	CALC_ADR
	INC	HL
	LD	A,(HL)
	OR	A
	POP	HL
	RET	NZ

	LD	A,R
	AND	&B00000001
	LD	B,1	; 1 = blauw   / 0 = rood
	LD	A,3	; random tank !!
	;  AND     &B00000011       ; joepie werkt !!
	INC	A	; 0 = 1 /  3 = 4
	LD	C,A
	CALL	ADD_TANK
	OR	A
	RET	Z

	LD	HL,(MONEY)	; MAX 2TOTDE15
	LD	BC,30
	XOR	A
	SBC	HL,BC
	LD	(MONEY),HL

	RET

MAKE_RED_BASE:
	LD	B,25	; over de steentjes heen....
	LD	C,13	; dit moet ook weg !!
	CALL	CALC_ADR
	LD	(HL),96
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	LD	(HL),97
	INC	H
	LD	(HL),99
	DEC	HL
	DEC	HL
	DEC	HL
	DEC	HL
	LD	(HL),98

	LD	B,50	;  dit kan dus hierna weer weg ! 
	LD	C,46
	CALL	CALC_ADR
	LD	(HL),112+16
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	LD	(HL),113+16
	INC	H
	LD	(HL),115+16
	DEC	HL
	DEC	HL
	DEC	HL
	DEC	HL
	LD	(HL),114+16

	LD	B,49	;  dit kan dus hierna weer weg !
	LD	C,49
	CALL	CALC_ADR
	LD	(HL),118+32	; factory
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	LD	(HL),119+32
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	LD	(HL),120+32
	INC	H
	LD	(HL),123+32
	DEC	HL
	DEC	HL
	DEC	HL
	DEC	HL
	LD	(HL),122+32
	DEC	HL
	DEC	HL
	DEC	HL
	DEC	HL
	LD	(HL),121+32

	LD	B,53	; EN DIT OOK
	LD	C,46
	CALL	CALC_ADR
	LD	(HL),132
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	LD	(HL),133
	INC	H
	LD	(HL),135
	DEC	HL
	DEC	HL
	DEC	HL
	DEC	HL
	LD	(HL),134
	RET

FREE_BLW_BASE:	;                      ; maak wat radar schoon !
	LD	B,25
	LD	C,10
	CALL	FREE_PART
	LD	B,29
	LD	C,12
	CALL	FREE_PART
	LD	B,28
	LD	C,19
	CALL	FREE_PART
	LD	B,50	; stukie rode base
	LD	C,46
	CALL	FREE_PART
	LD	B,49
	LD	C,52
	CALL	FREE_PART
	LD	B,53
	LD	C,49
	CALL	FREE_PART
	RET
FREE_PART:
	LD	DE,RAD_SIEGE
	CALL	FREE_PART_LOOP
	CALL	CALC_ADR
	DEC	HL
	LD	(HL),0
	RET

FREE_PART_LOOP:
	LD	A,(DE)
	CP	100
	RET	Z

	PUSH	BC

	ADD	B
	LD	B,A
	INC	DE

	LD	A,(DE)
	ADD	C
	LD	C,A
	INC	DE
	CALL	CALC_ADR
	POP	BC
	DEC	HL
	LD	(HL),0
	JR	FREE_PART_LOOP

	RET

;------------------------------------------------
; static Variabelen en data gebied
;------------------------------------------------

INT_DOS:	DW	0
INT_GAME:	DW	INT_ROUTINE

ADR:	DW	&H8000+260	; waar staat het veld ???? + de rand
LINE:	DB	10

FASTCOP:
BRON_X:	DB	0,0
BRON_Y:	DB	0,2
DOEL_X:	DB	0,0
DOEL_Y:	DB	0
DOEL_PAGE:	DB	0
NUM_X	DB	16,0
NUM_Y	DB	16,0
	DB	0,0
VDP_LOG:	DB	&HD0

ALGCOP:	DB	0,0,0,2,0,0,0,0,16,0,16,0,0,0,&HD0

TNKCOP:	DB	0,0,160,2,0,0,0,0,16,0,16,0,0,0,&H98

TNKCOP_RI:	DB	0,0,160,2,0,0,0,0,16,0,16,0,0,0,&H98
TNKCOP_DN:	DB	0,0,160,2,0,0,0,0,16,0,16,0,0,0,&H98
TNKCOP_LT:	DB	0,0,160,2,0,0,0,0,16,0,16,0,0,0,&H98
TNKCOP_UP:	DB	0,0,160,2,0,0,0,0,16,0,16,0,0,0,&H98

TANK_IMG:	DB	0,0,96,3,224,0,0,3,32,0,32,0,0,0,&H98
BUILD_IMG:	DB	0,0,64,3,224,0,0,3,32,0,32,0,0,0,&H98

EMPTY:	DB	160,0,0,3,208,0,24,0,32,0,32,0,0,0,&HD0

RADCOP:	DB	192,0,128,0,192,0,128,1,65,0,65,0,0,0,&HD0


POWER_BALK:	DB	200,0,56,3,208,0,58,0,32,0,8,0,0,0,&HD0
POWER_INFO:	DB	200,0,40,3,208,0,58,0,32,0,8,0,0,0,&HD0
POWER_COP:	DB	208,0,58,0,208,0,58,0,32,0,8,0,0,0,&HD0
HARV_BALK:	DB	192,0,0,3,232,0,24,0,8,0,32,0,0,0,&HD0
HARV_COP:	DB	232,0,24,0,232,0,24,0,8,0,32,0,0,0,&HD0

ITEM_CANCEL:	DB	208,0,120,3,200,0,96,0,48,0,8,0,0,0,&HD0
CANCEL_COP:	DB	208,0,96,3,200,0,72,0,48,0,32,0,0,0,&HD0

LIJN_COP:	DB	0,0,0,3
	DB	64,0,31,0
	DB	112,0,1,0
	DB	0,0,&HD0

MENU_COP:	DB	0,0,0,3
	DB	64,0,32,0
	DB	112,0,112,0
	DB	0,0,&HD0

PLOF_COP:	DB	0,0,64,2
	DB	0,0,0,0
	DB	16,0,16,0
	DB	0,0,&H98

LETCOP:	DB	0,0,128,3,0,0,0,0,8,0,8,0,0,0,&HD0
LETCOP2:	DB	0,0,136,3,0,0,0,0,8,0,8,0,0,0,&H98

CONCRETE_COP:	DB	0,0,80,2
	DB	0,0,0,0
	DB	16,0,16,0
	DB	0,0,&HD0

SHOOT0:
	DB	128,0,0,2
	DB	0,0,0,0
	DB	16,0,16,0
	DB	0,0,&h98

SHOOT1:
	DB	144,0,0,2
	DB	0,0,0,0
	DB	16,0,16,0
	DB	0,0,&h98

IMPACT0:
	DB	192,0,0,2
	DB	0,0,0,0
	DB	16,0,16,0
	DB	0,0,&h98

COP_BSEL_1:
	DB	192,0,64,2
	DB	0,0,0,0
	DB	16,0,16,0
	DB	0,0,&h98

COP_BSEL_2:
	DB	224,0,64,2
	DB	0,0,0,0
	DB	16,0,16,0
	DB	0,0,&h98
COP_BSEL_3:
	DB	208,0,64,2
	DB	0,0,0,0
	DB	16,0,16,0
	DB	0,0,&h98
COP_BSEL_4:
	DB	240,0,64,2
	DB	0,0,0,0
	DB	16,0,16,0
	DB	0,0,&h98

BB_BUSY_COP:
	DB	0,0,0,3
	DB	224,0,0,3
	DB	32,0,32,0
	DB	0,0,&h98

BB_BLW_COP:
	DB	32,0,0,3
	DB	224,0,0,3
	DB	32,0,32,0
	DB	0,0,&hD0

BB_RED_COP:
	DB	64,0,0,3
	DB	224,0,0,3
	DB	32,0,32,0
	DB	0,0,&hD0

BB_X_COP:
	DB	96,0,0,3
	DB	224,0,0,3
	DB	32,0,32,0
	DB	0,0,&hD0
BB_READY_COP:
	DB	128,0,0,3
	DB	224,0,0,3
	DB	32,0,32,0
	DB	0,0,&h98

BB_BLD_COP:
	DB	0,0,64,3
	DB	224,0,0,3
	DB	32,0,32,0
	DB	0,0,&h98
BB_TNK_COP:
	DB	0,0,96,3
	DB	224,0,0,3
	DB	32,0,32,0
	DB	0,0,&H98
BB_BLD2_COP:
	DB	0,0,0,3
	DB	0,0,176,0
	DB	32,0,32,0
	DB	0,0,&h98

BB_MOVE_COP:
	DB	224,0,0,3
	DB	0,0,176,0
	DB	32,0,32,0
	DB	0,0,&HD0

BB_STEPS_BAR:
	DB	194,0,0,3
	DB	0,0,176,0
	DB	4,0,16,0
	DB	0,0,&HD0
GRAY_ITEM:
	DB	160,0,0,3
	DB	224,0,0,3
	DB	32,0,32,0
	DB	0,0,&hD0
PUT_ITEM:
	DB	224,0,0,3
	DB	208,0,24,0
	DB	32,0,32,0
	DB	0,0,&HD0

MENU_COM_ATT:
	DB	0,0,32,3
	DB	200,0,72,0
	DB	48,0,8,0
	DB	0,0,&HD0

MENU_RED_ATT:
	DB	0,0,48,3
	DB	200,0,72,0
	DB	48,0,8,0
	DB	0,0,&HD0

MENU_COM_MOV:
	DB	48,0,32,3
	DB	200,0,80,0
	DB	48,0,8,0
	DB	0,0,&HD0
MENU_RED_MOV:
	DB	48,0,48,3
	DB	200,0,80,0
	DB	48,0,8,0
	DB	0,0,&HD0

MENU_COM_HRV:
	DB	144,0,32,3
	DB	200,0,72,0
	DB	48,0,8,0
	DB	0,0,&HD0
MENU_RED_HRV:
	DB	144,0,48,3
	DB	200,0,72,0
	DB	48,0,8,0
	DB	0,0,&HD0
MENU_COM_RET:
	DB	192,0,32,3
	DB	200,0,96,0
	DB	48,0,8,0
	DB	0,0,&HD0
MENU_RED_RET:
	DB	192,0,48,3
	DB	200,0,96,0
	DB	48,0,8,0
	DB	0,0,&HD0

MENU_COM_STP:
	DB	0,0,40,3
	DB	200,0,88,0
	DB	48,0,8,0
	DB	0,0,&HD0
MENU_RED_STP:
	DB	0,0,56,3
	DB	200,0,88,0
	DB	48,0,8,0
	DB	0,0,&HD0

MENU_COM_REP:
	DB	48,0,40,3
	DB	200,0,72,0
	DB	48,0,8,0
	DB	0,0,&HD0
MENU_RED_REP:
	DB	48,0,56,3
	DB	200,0,72,0
	DB	48,0,8,0
	DB	0,0,&HD0

MENU_COM_UPG:
	DB	96,0,40,3
	DB	200,0,80,0
	DB	48,0,8,0
	DB	0,0,&HD0
MENU_RED_UPG:
	DB	96,0,56,3
	DB	200,0,80,0
	DB	48,0,8,0
	DB	0,0,&HD0

MENU_COM_CAN:
	DB	144,0,40,3
	DB	200,0,96,0
	DB	48,0,8,0
	DB	0,0,&HD0

MENU_COM_CLN:
	DB	144,0,56,3
	DB	200,0,72,0
	DB	48,0,8,0
	DB	0,0,&HD0

MENU_COM_SWP:
	DB	200,0,58,0
	DB	200,0,58,1
	DB	48,0,46,0
	DB	0,0,&HD0

MENU_COM_SW2:
	DB	200,0,72,0
	DB	200,0,72,1
	DB	48,0,32,0
	DB	0,0,&HD0

POWER_BLOCK:
	DB	218,0,110,0
	DB	218,0,110,1
	DB	23,0,2,0
	DB	0,0,&HD0

JIFFY:	DB	0	; eigen jiffy !!! 0 -255 

SWAP:	DB	0

MAXSET:	DB	53,53	; vierkant veld !! is max offset + breedt 

BALK:	DB	0	; xlengte 
	DB	0	; ylengte 
	DW	0	; xbegin 
	DW	0	; ybegin 

STOP:	DB	0	; anders dan 0 is stop
MSTOP:	DB	0

RADAR:	DB	0	; niet elke keer updaten !! 
VDPADR:	DW	&H0300+100

TEMPLATE_TNK:
	DS	TANK_DATA,0	; template voor toevoegen tank !

TEMP_HARV:	;                         ;  templates per tank
	DB	2	; speed byte
	DB	0,140	; ATTACK / SHIELD
	DB	60
TEMP_SIEGE:
	DB	2
	DB	190,150
	DB	19
TEMP_TANK:
	DB	2
	DB	175,140
	DB	15
TEMP_QUAD:
	DB	4
	DB	160,120
	DB	10
TEMP_TRIKE:
	DB	8
	DB	155,80
	DB	7

SPRKLR_WHT:
	DB	15,15,15,15,15,15,15,15
	DB	15,15,15,15,15,15,15,15
SPRKLR_RD:
	DB	10,10,10,10,10,10,10,10
	DB	10,10,10,10,10,10,10,10

BB_TYPES:	DB	1,4,6,4,6,4,1,4,255	; zie bb

BB_SIZE:	DB	0	; 1, 4(2)  of 6(3)

BB_BLOCKED:	DB	0	; 1 is blocked 0 is vrij !
BB_OUT_RANGE:	DB	0

BB_SERIE:
	DB	0,0,0,0,0,0,0	; Hoe groot en welke spritesvoor BB

ITEMSELECTED:
	DB	0	; 0- 31 is enemy tanks of buildin
	;                        ; 32-63 is eigen tanks of building
	;                        ; 64-? item van build balk
SELECTED:
	DB	0	; is er een tank geselecteerd 
HAS_SELECT:
	DB	0	;er is multiple select gedaan
MSELECT_ON:
	DB	0	; er zijn tanks geselecteerd
TOTAL_SELECT:	DB	0	; nax 25 in selectie !

CURSOR_TYPE:
	DB	0	; ??

FIRE_BUTTONS:	DB	0

BUT_PRESSED:	DB	0	; bit 0 pressed but1
	;                        ; bit 1 pressed but2

RADARS:
	DW	RAD_DUMMY
	DW	RAD_SIEGE
	DW	RAD_TANK
	DW	RAD_QUAD
	DW	RAD_TRIKE

RAD_DUMMY:	DB	100,100

RAD_SIEGE:	;                          altijd op 100,100 eindigen
	DB	-1,-3,0,-3,1,-3
	DB	-2,-2,-1,-2,0,-2,1,-2,2,-2
	DB	-3,-1,-2,-1,-1,-1,0,-1,1,-1,2,-1,3,-1
	DB	-3,0,-2,0,-1,0,1,0,2,0,3,0
	DB	-3,1,-2,1,-1,1,0,1,1,1,2,1,3,1
	DB	-2,2,-1,2,0,2,1,2,2,2
	DB	-1,3,0,3,1,3
	DB	100,100

RAD_TANK:	;                          altijd op 100,100 eindigen
	DB	-1,-2,0,-2,1,-2
	DB	-2,-1,-1,-1,0,-1,1,-1,2,-1
	DB	-2,0,-1,0,1,0,2,0
	DB	-2,1,-1,1,0,1,1,1,2,1
	DB	-1,2,0,2,1,2
	DB	100,100

RAD_QUAD:	;                          altijd op 100,100 eindigen
	DB	-1,-1,0,-1,1,-1,-1,0,1,0,-1,1,0,1,1,1,100,100

RAD_TRIKE:	;                          altijd op 100,100 eindigen
	DB	-1,-1,0,-1,1,-1,-1,0,1,0,-1,1,0,1,1,1,100,100

RAD_HARVB:	;                          altijd op 100,100 eindigen  
	DB	-1,-1,0,-1,1,-1,-1,0,1,0,-1,1,0,1,1,1
	DB	0,-2,2,0,0,2,-2,0,2,-2,2,2,-2,2,-2,-2,100,100

RAD_HARVR:	;                          altijd op 100,100 eindigen         
	DB	-1,-1,0,-1,1,-1,-1,0,1,0,-1,1,0,1,1,1
	DB	0,-2,2,0,0,2,-2,0,2,-2,2,2,-2,2,-2,-2
	DB	0,-3,3,0,0,3,-3,0,3,-3,3,3,-3,3,-3,-3
	DB	0,-4,4,0,0,4,-4,0,4,-4,4,4,-4,4,-4,-4
	DB	0,-5,5,0,0,5,-5,0,5,-5,5,5,-5,5,-5,-5
	DB	0,-6,6,0,0,6,-6,0,6,-6,6,6,-6,6,-6,-6
	DB	0,-7,7,0,0,7,-7,0,7,-7,7,7,-7,7,-7,-7,100,100

SPICE_RAD:
	DW	-1*4+-1*256
	DB	17
	DW	0+-1*256
	DB	18
	DW	1*4+-1*256
	DB	19
	DW	-1*4+0*256
	DB	20
	DW	0+0
	DB	16
	DW	1*4+0*256
	DB	21
	DW	-1*4+1*256
	DB	22
	DW	0*4+1*256
	DB	23
	DW	1*4+1*256
	DB	24

FACTORY_DEPLOY:
	DW	(0*4)+0*256,(1*4)-1*256
	DW	(2*4)-1*256,(3*4)-1*256,(4*4)+0*256,(4*4)+1*256
	DW	(3*4)+2*256,(2*4)+2*256,(1*4)+2*256,(0*4)+256
	DW	(-1*4)+0,0-1*256,(1*4)-2*256,(2*4)-2*256
	DW	(3*4)-2*256,(4*4)-1*256,5*4,(5*4)+1*256,(4*4)+2*256
	DW	(3*4)+3*256,(2*4)+3*256,(1*4)+3*256,(0*4)+2*256
	DW	(-1*4)+1*256,100,100


QUAKE:	DB	0	; nummer van slachtoffer

PLAYFIELD:	DB	0	; cursor binnen area 3 = 1

MOUSE_OFF:	DB	0	;  AAN OF UIT 
MOUSE_USE:	DB	0	;  " """""""" 
MOUSE_PORT:	DB	0	;  PORT 1 OF 2 
MOUSE_WAIT1:	DB	0	;  WAIT CYCLE 1 
MOUSE_WAIT2:	DB	0	;  WAIT CYCLE 2 

DEEL2:	DW	10000
DEEL1:	DW	1000
		DW	100
DEEL0:	DW	10
		DW	1

ISTEXT:	DB	0

TEXTADR:	DW	0
TEXTTAB:
	DW	TEXT_TNK1
	DW	TEXT_TNK2
	DW	TEXT_TNK3
	DW	TEXT_TNK4
	DW	TEXT_MENU1
	DW	TEXT_OUTOFMONEY

TEXT_TNK1:	DB	"Yes sir >>",255
TEXT_TNK2:	DB	"Yo >>",255
TEXT_TNK3:	DB	"Affirmitive..",255
TEXT_TNK4:	DB	"Acknowledged",255
TEXT_MENU1:	DB	"DOME ALPHA 3",255
TEXT_OUTOFMONEY:	DB	"Not enough funds...",255

PDATA_1:
	DB	4,&H78	; CONTREL/FLAG   
	DB	7,1	; MOET!!!   
	DB	8,0	; DIV INIT   
	DB	9,0	; ST LOW   
	DB	10,0	S	; ST HI
	DB	11,&H0	; EI LOW   
	DB	12,&H0	; EI HI   
	DB	16,&HF0	; 16 Khz PLAY   
	DB	17,&H51	; 16 Khz PLAY   
	DB	18,255	; VOL ADPCM   
	DB	24,8	; ADPCM AAN   
	DB	7,&H60	: IETS (&HA0 IS PLAY)

DEST_OFFSET:
	DB	0,0,1,0,0,1,1,1
	DB	2,0,2,1,0,2,1,2,2,2
	DB	3,0,3,1,3,2,0,3,1,3,2,3,3,3
	DB	4,0,4,1,4,2,4,3,0,4,1,4,2,4,3,4,4,4

EVENT:	DB	0

EVENTHANDLER:
	DW	BUILD
	DW	UPDATE
	DW	CHKXY
	DW	RADAR_UPDATE
	DW	AI
	DW	ALGEMEEN

EXTR_B_DATA:
	DS	9,0	;   steen
	DB	2,2,255,154,0,0,0,0,20	; windtrap
	DB	3,2,255,154,0,0,0,0,0	; ref
	DB	2,2,255,154,0,0,0,0,0	; silo
	DB	3,2,255,154,0,0,2,0,0	; factory
	DB	2,2,255,154,0,0,0,0,0	; radar
	DB	1,1,255,154,0,0,0,0,0	; tower
	DB	2,2,255,154,0,0,3,0,0	; const yard.
	DS	9,0

	INCLUDE	3	; libfunc
	INCLUDE	4	; savedat
EI:
