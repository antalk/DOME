	DW	&H000F
AI:
	JR	AI_WAIT
	CALL	AI_UPDATE_TNKS
	CALL	AI_ADD_TNKS
	RET

AI_WAIT:
	LD	BC,(AI-2)
	DEC	BC
	LD	(AI-2),BC
	LD	A,B
	OR	C
	RET	NZ

	LD	HL,AI
	LD	(HL),0
	INC	HL
	LD	(HL),0
	RET
;---------------------------------------
;---------------------------------------
; AI UPDATE OF TANKS
;---------------------------------------
;---------------------------------------

AI_UPDATE_TNKS:
	LD	IX,TANKRED
	LD	B,127	; ONLY RED
AI_UPDATE_LP:
	LD	A,(IX+13)
	OR	A
	JR	Z,AI_UPDATE_NXT	; NO TNK

	LD	A,(IX+11)
	AND	&B01100000
	JR	NZ,AI_UPDATE_NXT	; ATT NOT

	PUSH	BC
	CALL	AI_UPDATE_TEST
	POP	BC
AI_UPDATE_NXT:
	LD	DE,TANK_DATA
	ADD	IX,DE
	DJNZ	AI_UPDATE_LP
	RET

AI_UPDATE_TEST:
	LD	A,(IX+11)
	AND	&B00000111
	JP	Z,AI_HARVR	; HARV  ( RET IS NEXT TANK !!!)

	LD	A,(IX+23)
	AND	&H0F
	LD	HL,AI_MS_TAB	; TAB VOOR UPDATE MS 
	SLA	A
	LD	C,A
	LD	B,0
	ADD	HL,BC
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A
	JP	(HL)

AI_MS_TAB:
	DW	AI_MS15		; RANDOM ATTACK ALS MS=0
	DW	AI_MS01		; HARV PROTECT
	DW	AI_MS02		; HOOK #1
	DW	AI_MS03		; HOOK #2
	DW	AI_MS04		; RANDOM RIJDEN
	DW	AI_MS05		; PROTECT #1
	DW	AI_MS06		; PROTECT #2
	DW	AI_MS07		; PROTECT #3
	DW	AI_MS08		; PROTECT #4
	DW	AI_MS09		; MAKE ARMY #1
	DW	AI_MS10		; MAKE ARMY #2
	DW	AI_MS11		; FULL HOUSE #1
	DW	AI_MS12		; FULL HOUSE #2
	DW	AI_MS13		; FULL HOUSE #3
	DW	AI_MS14		; FULL HOUSE #4
	DW	AI_MS15		; RANDOM ATT

;================================================================================


AI_MS01:
	LD	A,(IX+26)
	BIT	7,A
	JP	Z,AI_MS01_NEXT	; BLAUWE 

	CALL	A_TO_IY
	LD	A,(IY+13)
	OR	A
	JP	Z,AI_MS01_NEXT	;LEEG 

	LD	A,(IY+11)
	AND	7
	JP	NZ,AI_MS01_NEXT	;  GEEN HARV 

	LD	A,(IY+14)
	OR	A
	JR	NZ,AI_MS01_ATT	; ATT

	BIT	4,(IX+11)	; MOVING 
	RET	NZ

	LD	B,(IY+0)
	LD	C,(IY+1)	; 1=RIJDEN NAAR DES. 

	LD	A,B
	SUB	4
	CP	(IX+0)
	RET	C

	; LD      A,B
	; ADD     A,4
	; CP      (IX+0)
	; RET     C

	;  LD      A,C
	;  SUB     A,4
	;  CP      (IX+1)
	;  RET     NC

	;  LD      A,C
	;  ADD     A,4
	;  CP      (IX+1)
	;  RET     C

AI_MS01_LP:
	LD	B,(IY+0)
	LD	C,(IY+1)

	LD	HL,RAD_HARVR
	LD	A,R
	SRL	A	; NIET MEER DAN 64 AFK      
	SRL	A
	LD	C,A
	LD	B,0
	ADD	HL,BC
	LD	A,(HL)

	LD	B,(IY+0)	; X           
	ADD	B	; X+AFK      
	OR	A
	JP	Z,AI_MS01_LP
	CP	63
	JP	NC,AI_MS01_LP
	LD	B,A

	LD	C,(IY+1)	; Y           
	INC	HL
	LD	A,(HL)
	ADD	C	; Y+AFK                
	OR	A
	JP	Z,AI_MS01_LP
	CP	63
	JP	NC,AI_MS01_LP
	LD	C,A

	PUSH	BC
	CALL	CALC_ADR
	POP	BC
	LD	A,(HL)
	CP	48
	JP	NC,AI_MS01_LP

	LD	(IX+2),B
	LD	(IX+3),C	; NEW X.Y      

	RET

AI_MS01_ATT:
	LD	(IX+14),A	; NR KLOOJOO 
	RES	4,(IX+11)
	SET	5,(IX+11)	; HARV ONDER ATT 
	RES	6,(IX+11)
	RET

AI_MS01_NEXT:
	LD	IY,TANKRED	; (IX+26)=NO HARV 
	LD	B,127
	LD	DE,TANK_DATA
AI_MS01_NEXT_LP:
	LD	A,(IY+13)
	OR	A
	JR	Z,AI_MS01_NOT

	LD	A,(IY+11)	; GEEN CHK OP LEEG ??? 
	AND	&B00000111	; harvester
	JR	NZ,AI_MS01_NOT

	LD	A,(IY+13)
	LD	(IX+26),A	; HARV FOUND 
	RET
AI_MS01_NOT:
	ADD	IY,DE
	DJNZ	AI_MS01_NEXT_LP

	LD	A,(IX+23)
	AND	&HF0
	LD	(IX+23),A	; MIS 15/0 
	RET
;================================================================================
AI_MS02:
	;JP	&H3455
AI_MS03:
	;JP	&H243R
	RET
;================================================================================
AI_MS04:
	BIT	4,(IX+11)	; MOVING
	RET	NZ

	LD	A,R
	AND	&B00111111
	LD	B,A

	HALT		; DIT IS OM R TE VERANDEREN ( MOET !!!! )

	LD	A,R
	AND	&B00111111
	LD	C,A

	PUSH	BC
	CALL	CALC_ADR
	POP	BC
	LD	A,(HL)
	CP	48
	RET	NC		; STOON

	INC	HL
	LD	A,(HL)
	OR	A
	RET	NZ		; TANK

	LD	A,B
	AND	&B00110000
	SRL	A
	LD	E,A

	LD	A,C
	AND	&B00110000
	ADD		A
	OR	E
	LD	D,0
	LD	E,A
	LD	IY,AI_SECTORS
	ADD	IY,DE

	LD	A,(IY+0)
	OR	A
	RET	NZ		; GEEN BLAUW IN SECTOR

	LD	(IX+2),B
	LD		(IX+3),C
	RET
;================================================================================
AI_MS05:
AI_MS06:
AI_MS07:
AI_MS08:
	BIT	4,(IX+11)
	RET	NZ

	LD	HL,AI_PAT_COR
	LD	A,C
	SUB	10
	LD	C,A
	SLA	C	; 4
	SLA	C	; 8 POSITIONS
	ADD	HL,BC
AI_MS_PAT_LP:
	LD	D,(HL)
	INC	HL
	LD	E,(HL)
	INC	HL

	LD	A,D
	OR	A	; EINDE TAB      
	RET	Z	; DUS GEEN PLEKJE

	LD	B,D
	LD	C,E
	PUSH	HL
	CALL	CALC_ADR
	LD	A,(HL)
	CP	48
	JP	NC,AI_MS_PAT_NEXT

	INC	HL
	LD	A,(HL)
	OR	A
	JR	NZ,AI_MS_PAT_NEXT
	POP	HL

	LD	(IX+2),D	; NEW X,Y
	LD	(IX+3),E
	RET

AI_MS_PAT_NEXT:
	POP	HL
	JR	AI_MS_PAT_LP

AI_PAT_COR:
	DB	32,36,05,15,62,62,0,0
	DB	55,35,38,38,61,61,0,0
	DB	36,36,33,60,60,60,0,0
	DB	54,05,50,30,59,59,0,0

;================================================================================

AI_MS09:
AI_MS10:
	RET

;================================================================================

AI_MS11:
	LD	A,(AI_MS11_ATT_NR)
	JR	AI_MS_FULL
AI_MS12:
	LD	A,(AI_MS12_ATT_NR)
	JR	AI_MS_FULL
AI_MS13:
	LD	A,(AI_MS13_ATT_NR)
	JR	AI_MS_FULL
AI_MS14:
	LD	A,(AI_MS14_ATT_NR)
AI_MS_FULL:
	OR	A
	JR	NZ,AI_MS_FULL_ATT	; DO_ATT 

	BIT	4,(IX+11)
	RET	NZ		; MOVING

	LD	A,(IX+23)
	AND	&H0F
	LD	HL,AI_MS_COUNTER
	SLA	A
	LD	C,A
	LD	B,0
	ADD	HL,BC	; Spreekt voor zich !! ja ??
	LD	A,(HL)
	LD	B,A
	INC	HL
	LD	A,(HL)
	CP	B
	JP	Z,AI_MS_FULL_MAKE_ATT

	LD	A,R
	AND	&B01010101
	RET	NZ

AI_MS_FULL_MOVE:
	LD	B,(IX+0)
	LD	C,(IX+1)

	LD	A,B
	AND	&B00110000
	SRL	A
	SRL	A
	SRL	A
	SRL	A
	LD	E,A

	LD	A,C
	AND	&B00110000
	SRL	A
	SRL	A
	OR	E

	DEC	A		; EEN VAK TERUG
	AND	&H0F
	CALL	AI_XYRAN_SECTOR

	PUSH	BC
	CALL	CALC_ADR
	POP	BC
	LD	A,(HL)
	CP	48
	JP	NC,AI_MS_FULL_MOVE

	INC	HL	; 2TNK LAY
	LD	A,(HL)
	OR	A
	JR	NZ,AI_MS_FULL_MOVE

	LD	(IX+2),B	; NEW X,Y 
	LD	(IX+3),C
	RET

AI_MS_FULL_ATT:
	OR	A
	RET	Z

	BIT	7,A
	JR	NZ,AI_MS_FULL_NUL

	CALL	A_TO_IY

	LD	A,(IY+13)
	OR	A
	JR	Z,AI_MS_FULL_NUL

	LD	(IX+14),A
	RES	4,(IX+11)
	SET	5,(IX+11)
	RES	6,(IX+11)
	RET
AI_MS_FULL_NUL:
	LD	HL,AI_MS11_ATT_NR
	LD	(HL),0
	INC	HL
	LD	(HL),0
	INC	HL
	LD	(HL),0
	INC	HL
	LD	(HL),0
	RET

AI_MS_FULL_MAKE_ATT:
	LD	A,R
	OR	A
	JR	Z,AI_MS_FULL_MAKE_ATT
	BIT	7,A
	JR	NZ,AI_MS_FULL_MAKE_ATT
	CALL	A_TO_IY
	LD	A,(IY+13)
	OR	A
	RET	Z
	LD	B,A
	LD	A,(IX+23)
	AND	&H0F
	SUB	11
	LD	HL,AI_MS11_ATT_NR
	LD	E,A
	LD	D,0
	ADD	HL,DE
	LD	A,B
	LD	(HL),A
	RET

AI_MS11_ATT_NR:
	DB	0
AI_MS12_ATT_NR:
	DB	0
AI_MS13_ATT_NR:
	DB	0
AI_MS14_ATT_NR:
	DB	0

AI_XYRAN_SECTOR:
	LD	C,A
	AND	3
	ADD	A
	ADD	A
	ADD	A
	ADD	A
	LD	B,A
	LD	A,R
	AND	&H0F
	OR	B
	LD	B,A

	HALT			; VOOR DE RANDOM ( MOET !!!!:)

	LD	A,C
	AND	12
	ADD	A
	ADD	A
	LD	C,A
	LD	A,R
	AND	&H0F
	OR	C
	LD	C,A
	RET

;================================================================================
AI_MS15:
	LD	A,R
	RES	7,A	; ALTIJD BLAUW 
	OR	A
	JR	Z,AI_MS15	; R= 4 OF 3
	CALL	A_TO_IY
	LD	A,(IY+13)
	OR	A
	RET	Z	; NO TNK 
	LD	(IX+14),A
	RES	4,(IX+11)
	SET	5,(IX+11)	; ATT
	RES	6,(IX+11)
	RET
;================================================================================
;================================================================================

AI_HARVR:
	BIT	4,(IX+11)
	JP	NZ,AI_HRVR_RIJT

	BIT	7,(IX+22)
	JP	Z,AI_HRVR_NO

	DEC	(IX+18)	; 2=NET DOEN ALSOF  EVEN HARVESTEN
	RET	NZ

	LD	A,(IX+19)
	LD	(IX+18),A

	LD	B,(IX+0)
	LD	C,(IX+1)	; 1=RIJDEN NAAR DES.               

	PUSH	BC
	CALL	CALC_ADR
	POP	BC	; 3=KIJK OP HRV              

	LD	A,(HL)
	CP	16
	JP	C,AI_HRVR_NO	; NEE RIJ VERDER              
	CP	48
	JP	NC,AI_HRVR_NO	;              

	CALL	AI_CALC_HRV2MON

	RES	7,(IX+22)	; ANDER HRVED HIJ 2X OP DIK ZAND 
	INC	B
	XOR	A
	LD	(IX+14),A

	LD	HL,(AI_MONEY)
	LD	C,B
	LD	B,0
	ADD	HL,BC
	RET	C	; ANDERS KOMEN OP BIJ DE NUL 
	LD	(AI_MONEY),HL

	RET

;--------- NO HARV

AI_HRVR_NO:
	LD	HL,RAD_HARVR
	LD	A,(IX+27)
	INC	(IX+27)	; SEARCH IN CIRCLE 
	SLA	A
	LD	C,A
	LD	B,0
	ADD	HL,BC

	LD	A,(HL)
	CP	100
	JP	Z,AI_STOP_HRVR

	LD	B,(IX+0)	; X                
	ADD	B	; X+AFK                
	JP	M,AI_HRVR_NO	; NEG            
	CP	63
	JP	NC,AI_HRVR_NO	; >63 EINDE VELD            
	LD	B,A

	LD	C,(IX+1)	; Y                
	INC	HL
	LD	A,(HL)
	ADD	C	; Y+AFK                
	JP	M,AI_HRVR_NO	; NEG            
	CP	63
	JP	NC,AI_HRVR_NO	; >63 EINDE VELD            
	LD	C,A

	PUSH	BC	; NEW X,Y                
	CALL	CALC_ADR
	POP	BC

	LD	A,(HL)	; IS ER HARVEST                
	CP	16
	JP	C,AI_HRVR_NO
	CP	48
	JP	NC,AI_HRVR_NO

	LD	(IX+2),B	; INIT NEW X,Y                
	LD	(IX+3),C

	SET	7,(IX+22)	; SET HARV BIT'JE 
	XOR	A
	LD	(IX+26),A	; SET WAIT COUNTER VAN RIJDEN 
	LD	(IX+27),A	; POS IN SEARCH CICLE 
	RET
AI_HRVR_RIJT:
	LD	A,(IX+26)	; CONTER OM TE RIJEN   
	INC	A
	AND	&B00111111
	LD	(IX+26),A
	RET	NZ

	LD	B,(IX+2)
	LD	C,(IX+3)	; WAAR WILLEN WE HEEN ??/   
	CALL	CALC_ADR
	INC	HL
	LD	A,(HL)	; STAAT DAAR EEN TNK   
	OR	A
	RET	Z	; JE HEBT AL EN DOEL 

	CALL	A_TO_IY
	LD	A,(IY+13)
	BIT	7,A
	JR	NZ,AI_HRVR_FREND

	LD	(IX+14),A	; DE KLOOJOO = MISSIE MAAKT HEM AFFF 
	RET
AI_HRVR_FREND:
	LD	HL,RAD_HARVR
	LD	A,R
	SRL	A	; NIET MEER DAN 64 AFK'EN   
	SRL	A
	LD	C,A
	LD	B,0
	ADD	HL,BC
	LD	A,(HL)

	LD	B,(IY+2)	; X 
	ADD	B	; X+AFK        
	CP	63
	JP	NC,AI_HRVR_FREND
	LD	B,A

	LD	C,(IY+3)	; Y 
	INC	HL
	LD	A,(HL)
	ADD	C	; Y+AFK                  
	CP	63
	JP	NC,AI_HRVR_FREND
	LD	C,A

	LD	(IY+2),B
	LD	(IY+3),C	; NEW X.Y 

	RET
AI_STOP_HRVR:
	XOR	A
	LD	(IX+26),A
	RES	7,(IX+22)	; ECHT VAST              
	RET

;---------------------------------------
; AI ADD TANK + SET MISSION
;---------------------------------------
;---------------------------------------

AI_ADD_TNKS:
	LD	HL,(AI_MONEY)
	LD	BC,30
	XOR	A
	SBC	HL,BC
	RET	C		; CHK IF MONEY IF OKE

	LD	DE,AI_ADD_TNK_COR	; LD X,Y WWAAR TNK KUNNEN KOMEN

	LD	HL,AI_MS_COUNTER
	LD	B,16		; 15 MISSIONS + DUMMY   
AI_ADD_TNK_CHK_L:
	LD	A,(HL)		; CURRENT   
	INC	HL
	LD	C,A
	LD	A,(HL)		; MAXX   
	SUB	C
	JR	NZ,AI_ADD_TNKS_LP

	INC	HL
	DJNZ	AI_ADD_TNK_CHK_L
	RET			; NO MISSIONS FREE

AI_ADD_TNKS_LP:
	LD	A,(DE)
	LD	B,A
	INC	DE

	OR	A	; TAB OP
	RET	Z

	LD	A,(DE)
	LD	C,A
	INC	DE

	PUSH	DE	; TAB ADR
	PUSH	BC	; X,Y

	CALL	CALC_ADR
	INC	HL	; 2 TNK LAY   
	LD	A,(HL)

	POP	HL	; X,Y
	POP	DE	; TAB ADR

	OR	A	; CHK ON TNK
	JR	NZ,AI_ADD_TNKS_LP

;-----; ALLES OKE ???  => PLAATS TANK
;-----
	LD	B,0
	LD	A,R		; MAKE RND A TNK
	AND	&B00000011
	INC	A
	LD	C,A

	CALL	ADD_TANK
	OR	A
	RET	Z		; FAILDED

	PUSH	IY
	POP	IX

	LD	HL,(AI_MONEY)
	LD	BC,30
	XOR	A
	SBC	HL,BC		; CHK IS OK
	LD	(AI_MONEY),HL

	SET	5,(IX+23)	; SET GUARD

	LD	HL,AI_MS_COUNTER
	LD	D,0		; MS 0 
	LD	B,16		; 15 MISSIONS + DUMMY 
AI_ADD_TNK_MS_LP:
	LD	A,(HL)		; CURRENT 
	INC	HL
	LD	E,A
	LD	A,(HL)		; MAXX 
	SUB	E
	JR	NZ,AI_ADD_TNK_DONE

	INC	HL
	INC	D		; MISSIONS COUNTER 
	DJNZ	AI_ADD_TNK_MS_LP
	RET

AI_ADD_TNK_DONE:
	DEC	HL
	INC	(HL)		; CURRENT +1 
	LD	A,(IX+23)
	AND	&HF0
	OR	D
	LD	(IX+23),A


;===============================================================================
;===============================================================================
;
;     HIER WEET IK DE MISSIE VAN DE TANK DUS KAN IK HIER MET EEN PAAR CP'S
;     DE MISSIES AFVANGEN DIE EEN INIT NODIG HEBBEN VOOR ELKE TANK
;
;===============================================================================
;===============================================================================

	AND	&H0F
	CP	1
	JP	Z,AI_ADD_TNK_01

	CP	11
	JP	Z,AI_MS_FULL_MOVE
	CP	12
	JP	Z,AI_MS_FULL_MOVE
	CP	13
	JP	Z,AI_MS_FULL_MOVE
	CP	14
	JP	Z,AI_MS_FULL_MOVE

	RET

AI_ADD_TNK_01:
	LD	IY,TANKRED
	LD	B,127
	LD	DE,TANK_DATA
AI_ADD_TNK_01_0:
	LD	A,(IY+13)
	OR	A
	JR	Z,AI_ADD_TNK_01_1

	LD	A,(IY+11)	; GEEN CHK OP LEEG ???
	AND	&B00000111	; harvester              
	JR	Z,AI_ADD_TNK_01_2
AI_ADD_TNK_01_1:
	ADD	IY,DE
	DJNZ	AI_ADD_TNK_01_0
	RET
AI_ADD_TNK_01_2:
	LD	A,(IY+13)
	LD	(IX+26),A
	RET

;------
; TABEL'EN DIE DOOR DEZE SUB-AI WORDEN GEBRUIKT
;------

AI_ADD_TNK_COR:
	DB	50,45,51,45,52,45,0,0	; X,Y,0=END

AI_ADD_TNK_TYPE:	DB	0	; TIJDELIJKE OPSLAG VOOR TYPE TANK
	;                        	; NOG NIET IN GEBUIK

AI_MS_COUNTER:
	DB	0,0	; current/max
	DB	0,4	; PROTECT HARV		-- MISSION 1
	DB	0,0	; HOOK #1		-- MISSION 2
	DB	0,0	; HOOK #2		-- MISSION 3
	DB	0,2	; RANDOM RIJDEN		-- MISSION 4
	DB	0,2	; PROTECT #1		-- MISSION 5
	DB	0,3	; PROTECT #2		-- MISSION 6
	DB	0,4	; PROTECT #3		-- MISSION 7
	DB	0,3	; PROTECT #4		-- MISSION 8
	DB	0,0	; MAKE ARMY #1		-- MISSION 9
	DB	0,0	; MAKE ARMY #2		-- MISSION 10
	DB	0,0	; FULL HOUSE #1		-- MISSION 11
	DB	0,0	; FULL HOUSE #2		-- MISSION 12
	DB	0,0	; FULL HOUSE #3		-- MISSION 13
	DB	0,3	; FULL HOUSE #4		-- MISSION 14
	DB	0,4	; RANDOM ATT		-- MISSION 15
AI_MONEY:
	DW	400	; 24 CAR'S + HARV = 25 KILL'S

;---------------------------------------
;---------------------------------------
; AI : GOES OVER THE MAP AND STORES THINKS + UPD ANIMATION
;---------------------------------------
;---------------------------------------

AI_MP_SECTOR:
	DB	255
AI_MAPPING:
	LD	A,(AI_MP_SECTOR)
	INC	A
	AND	&H0F
	LD	(AI_MP_SECTOR),A

	LD	C,A
	AND	3
	ADD	A
	ADD	A
	ADD	A
	SLA	A
	LD	B,A	; X

	LD	A,C
	AND	12
	ADD	A
	ADD	A
	LD	C,A	; Y

	CALL	CALC_ADR
	DEC	HL
	PUSH	HL	; VELD ADR

	LD	A,(AI_MP_SECTOR)
	ADD	A
	ADD	A
	ADD	A	; 8 BYTES
	LD	E,A
	LD	D,0
	LD	IX,AI_SECTORS	; HANDIG
	ADD	IX,DE

	LD	HL,AI_SECTORS
	ADD	HL,DE	; OOK EVE DE SECOR LEGEN
	EX	DE,HL
	LD	HL,AI_SECTOR_EM
	LD	BC,8	; 6 BYTES PER SECTOR
	LDIR

	POP	HL
	LD	B,16
AI_MP_MAIN_LP:
	LD	C,B	; BC PUSH'EN ALLEN ALS NODIG

	LD	B,16
	CALL	AI_MP_LP

	LD	DE,192	; 256 - (16*4)
	ADD	HL,DE

	LD	B,C
	DJNZ	AI_MP_MAIN_LP
	RET
;----

AI_MP_LP:
	LD	A,(HL)
	OR	A
	CALL	Z,AI_MP_SEE	; SEE GATE

	INC	HL
	CALL	AI_MP_VELD	; HARV / STOON

	INC	HL
	LD	A,(HL)
	OR	A
	CALL	NZ,AI_MP_TANK	; BLW/RD TNK

	INC	HL
	LD	A,(HL)
	OR	A
	CALL	Z,AI_MP_ALG	; ANI

	INC	HL
	DJNZ	AI_MP_LP
	RET
;---

; VRIJE REG : AF, DE , AF , BC' , DE', HL' , IY

AI_MP_SEE:
	INC	(IX+4)
	RET
;==

AI_MP_VELD:
	;  LD      A,(HL)
	;  CPL
	;  LD      (HL),A

	RET
;==

AI_MP_TANK:
	BIT	7,A
	JR	Z,AI_MP_TNK_BLW
	INC	(IX+2)	; 1 BLAUWE TNK
	RET
AI_MP_TNK_BLW:
	INC	(IX+0)	; 1 BLAUWE TNK
	RET
;==

AI_MP_ALG:

	; ANIMATION

	RET
;===
AI_SECTOR_EM:
	DB	0	; BLAUWE		0
	DB	0	; BLAUWE BUILDINGS	1
	DB	0	; ROODE			2
	DB	0	; ROODE BUILDINGS	3
	DB	0	; SEE GATE (BLW)	4
	DB	0	; STOON            	5
	DB	0	; LEVEL HARV		6
	DB	0	; ???			7
	DB	0	; ???			7
AI_SECTORS:
	DS	16*8

;----------------------------------------
TNK_CHK:
	LD	B,(IX+0)
	LD	C,(IX+1)
	CALL	CALC_ADR
	INC	HL	; NAAR TNK LAYER          

	LD	A,(IX+13)
	AND	&H80
	LD	D,A	; BIT 7=OORSPORNG REQETER

	DEC	H	; UP          
	LD	A,(HL)
	OR	A
	CALL	NZ,FOUND_TNK

	INC	HL	; RIUP          
	INC	HL
	INC	HL
	INC	HL

	LD	A,(HL)
	OR	A
	CALL	NZ,FOUND_TNK

	INC	H	; RI          
	LD	A,(HL)
	OR	A
	CALL	NZ,FOUND_TNK

	INC	H	; RIDO          
	LD	A,(HL)
	OR	A
	CALL	NZ,FOUND_TNK

	DEC	HL	; DO          
	DEC	HL
	DEC	HL
	DEC	HL
	LD	A,(HL)
	OR	A
	CALL	NZ,FOUND_TNK

	DEC	HL	; DOLI          
	DEC	HL
	DEC	HL
	DEC	HL
	LD	A,(HL)
	OR	A
	CALL	NZ,FOUND_TNK

	DEC	H	; LI          
	LD	A,(HL)
	OR	A
	CALL	NZ,FOUND_TNK

	DEC	H	; LIUP          
	LD	A,(HL)
	OR	A
	CALL	NZ,FOUND_TNK
	RET
FOUND_TNK:
	CALL	A_TO_IY
	LD	A,(IY+13)
	LD	B,A
	AND	&H80
	SUB	D
	RET	Z	; CHK OP SOORT

	LD	(IX+14),B
	RES	4,(IX+11)
	SET	5,(IX+11)
	RES	6,(IX+11)
	POP	AF	; DO NOP FINCH CIRCLE
	RET


