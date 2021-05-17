;---------------------------------
;            DOME LOADER
;
;   (c) 1998 PARAGON Productions
;
;             LOADER.DAT
;
;---------------------------------
	ORG	&H8000
ST:

	CALL	INIT_SCR	; SCREEN 0-80  + ROODE BALK

	LD	HL,FILE3	; Tank tabel
	LD	A,0
	LD	BC,&H1FFF
	LD	DE,&H4000
	CALL	LOAD_FILE

	LD	HL,&H4000	; ADR IN RAM  
	LD	A,0	; PAGE (VRAM IN 64 KB) 
	LD	DE,&H8000	; DE IN VRAM 
	CALL	POP.UP_START

	RET
;======================================

INIT_SCR:
	CALL	SET_SCREEN0
	ret

;-------------------------------------

POP.UP_START:
	LD	(PAGE),A
	LD	(ADRES),DE
	LD	(DATA),HL

	XOR	A

POP.UP:	ADD	A
	ADD	A
	ADD	A
	LD	E,A
	LD	D,0
	LD	IX,POPTBL
	ADD	IX,DE	; [IX]=POPTBL+8*[A] 

	LD	A,I	; IFF to P/V-flag 
	LD	A,-1
	JP	PE,POP.DI
	XOR	A
POP.DI:	LD	(POPIFF),A	; Interrupt status  (0: DI; -1: EI) 

	LD	A,(IX+1)
	LD	(POPPAG),A	; VDP-page (64 kB) 

	LD	L,(IX+2)
	LD	H,(IX+3)	; Source address in [HL] 
	LD	E,(HL)
	INC	HL
	LD	D,(HL)	; Length in [DE] 
	LD	L,(IX+4)
	LD	H,(IX+5)	; Dest. address in [HL] 
	ADD	HL,DE
	LD	(POPEND),HL	; Set end address 

	LD	L,(IX+4)
	LD	H,(IX+5)	; Dest. address in [HL] 
	CALL	POP.WR	; Set VDP to write 

	LD	L,(IX+2)
	LD	H,(IX+3)	; Source address in [HL] 
	LD	DE,&H04
	ADD	HL,DE	; Skip 4 bytes (the 2 addresses) 
	LD	BC,&H1098
	OTIR		; Write 1st 16 bytes in VRAM 

	LD	E,&H80
	EXX
	LD	L,(IX+4)
	LD	H,(IX+5)	; Dest. address in [HL] 
	LD	DE,&H10
	ADD	HL,DE	; Skip 16 bytes 
POP.00:	LD	A,(POPEND+1)
	CP	H
	JR	NZ,POP.01
	LD	A,(POPEND)
	CP	L
	RET	C
	RET	Z	; Return when (POPEND)<=[HL] 
POP.01:	EXX
	RLC	E
	JR	NC,POP.02
	LD	D,(HL)
	INC	HL
POP.02:	RLC	D
	LD	A,(HL)
	INC	HL
	JR	C,POP.03
	EXX

	CALL	POP.WR
	OUT	(&H98),A	; Write in VRAM 
	INC	HL
	JR	POP.00
;
POP.03:	BIT	7,A
	JR	NZ,POP.04
	EXX
	LD	D,&H00
	LD	E,A
	EXX
	XOR	A
	JR	POP.05
;
POP.04:	BIT	6,A
	JR	NZ,POP.06
	RES	7,A
	LD	BC,&H0400
POP.07:	RLC	E
	JR	NC,POP.08
	LD	D,(HL)
	INC	HL
POP.08:	RLC	D
	RLA
	RL	C
	DJNZ	POP.07
	ADD	A,&H80
	EXX
	LD	E,A
	EXX
	LD	A,C
	ADC	A,&H00
	EXX
	LD	D,A
	EXX
	LD	A,&H01
	JR	POP.05
;
POP.06:	AND	&H3F
	SRL	A
	EXX
	LD	D,A
	EXX
	LD	A,(HL)
	INC	HL
	RRA
	EXX
	LD	E,A
	EXX
	LD	A,&H02
	JR	NC,POP.09
	LD	C,&H01
	JR	POP.0A
;
POP.05:	LD	C,A
	INC	A
	RLC	E
	JR	NC,POP.0B
	LD	D,(HL)
	INC	HL
POP.0B:	RLC	D
	JR	NC,POP.09
POP.0A:	INC	A
	RLC	E
	JR	NC,POP.0C
	LD	D,(HL)
	INC	HL
POP.0C:	RLC	D
	JR	NC,POP.09
	INC	A
	RLC	E
	JR	NC,POP.0D
	LD	D,(HL)
	INC	HL
POP.0D:	RLC	D
	JR	NC,POP.09
	LD	A,&H02
POP.0E:	RLC	E
	JR	NC,POP.0F
	LD	D,(HL)
	INC	HL
POP.0F:	RLC	D
	JR	NC,POP.10
	INC	A
	CP	&H07
	JR	NZ,POP.0E
POP.10:	LD	B,A
	LD	A,&H01
POP.11:	RLC	E
	JR	NC,POP.12
	LD	D,(HL)
	INC	HL
POP.12:	RLC	D
	RLA
	DJNZ	POP.11
	ADD	A,C
POP.09:	EXX

	PUSH	AF
	PUSH	HL

	LD	(POPXXX),HL	; write address in (popxxx) 
	SCF
	SBC	HL,DE	; read address in [HL] 
	LD	C,&H98
	CALL	POP.13	; Simulate 'LDIR' in VRAM 

	POP	HL
	POP	AF
	LD	C,A
	LD	B,0
	INC	BC
	ADD	HL,BC	; [HL#]=[HL]+[A]+1 
	JP	POP.00

POP.13:	LD	B,A
	INC	DE
	LD	A,D
	OR	A
	JP	NZ,POP.15	; [DE]>255 = [D]>0: no overlap 

	LD	A,B	; [B]=len-1 
	SUB	E	; [E]=x 
	JP	C,POP.15	; [B]<[E]: no overlap  (len<=x) 

	INC	B
	PUSH	BC
	LD	B,E
	CALL	POP.RD	; read address still in [HL] 
	LD	HL,POPBUF
	INIR		; read x bytes in VRAM 

	LD	C,A
	LD	B,0
	INC	BC	; [BC]=len-x 
	LD	HL,POPBUF
	ADD	HL,DE
	EX	DE,HL	; [DE]=POPBUF+x 
	LD	HL,POPBUF	; [HL]=POPBUF 
	LDIR

POP.14:	POP	BC
	LD	HL,(POPXXX)
	CALL	POP.WR
	LD	HL,POPBUF
	OTIR		; write bytes in VRAM 
	RET

POP.15:	INC	B
	PUSH	BC
	CALL	POP.RD	; read address still in [HL] 
	LD	HL,POPBUF
	INIR		; read bytes in VRAM 
	JP	POP.14

POP.WR:	PUSH	BC	; Set write address 
	LD	C,A
	LD	A,(POPPAG)
	LD	B,A
	LD	A,H
	AND	&B11000000
	OR	B
	RLCA
	RLCA
	DI
	OUT	(&H99),A
	LD	A,&H8E
	OUT	(&H99),A
	LD	A,L
	LD	A,L
	OUT	(&H99),A
	LD	A,H
	AND	&H3F
	OR	&H40
	OUT	(&H99),A

	LD	A,(POPIFF)
	OR	A
	LD	A,C
	POP	BC
	RET	Z	; Restore int. status 
	EI
	RET

POP.RD:	PUSH	BC	; Set read address 
	LD	C,A
	LD	A,(POPPAG)
	LD	B,A
	LD	A,H
	AND	&B11000000
	OR	B
	RLCA
	RLCA
	DI
	OUT	(&H99),A
	LD	A,&H8E
	OUT	(&H99),A
	LD	A,L
	LD	A,L
	OUT	(&H99),A
	LD	A,H
	AND	&H3F
	OUT	(&H99),A

	LD	A,(POPIFF)
	OR	A
	LD	A,C
	POP	BC
	RET	Z	; Restore int. status 
	EI
	RET

;-------------------------------------
FILE3:
	DB	"PAGE5   ZOP"

POPPAG:	DB	0
POPIFF:	DB	0
POPEND:	DW	0
POPXXX:	DW	0
POPBUF:	DS	256

POPTBL:
	DB	7	; Mapperbank ( niet gebruikt ? ) 
PAGE:	DB	0	; VDP-page (64 kB or b16 of VRAM-add   
DATA:	DW	0	; Source address (in RAM)   
ADRES:	DW	0	; Dest. address (in VRAM)   
	DW	0	; End address (in VRAM, is calculated  




	INCLUDE	3
