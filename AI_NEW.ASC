	DW	&H002F
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
AI_UPDATE_TNKS:
	LD	IX,TANKRED
	LD	B,127	; ONLY RED 
	LD	C,TANK_DATA
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
	LD	E,C	; tankdata 
	LD	D,0
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
	DW	AI_MS15	; RANDOM ATTACK ALS MS=0 
	DW	AI_MS01	; HARV PROTECT 
	DW	AI_MS02	; HOOK #1 
	DW	AI_MS03	; HOOK #2 
	DW	AI_MS04	; RANDOM RIJDEN 
	DW	AI_MS05	; PROTECT #1 
	DW	AI_MS06	; PROTECT #2 
	DW	AI_MS07	; PROTECT #3 
	DW	AI_MS08	; PROTECT #4 
	DW	AI_MS09	; MAKE ARMY #1 
	DW	AI_MS10	; MAKE ARMY #2 
	DW	AI_MS11	; FULL HOUSE #1 
	DW	AI_MS12	; FULL HOUSE #2 
	DW	AI_MS13	; FULL HOUSE #3 
	DW	AI_MS14	; FULL HOUSE #4 
	DW	AI_MS15	; RANDOM ATT 

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
	;JP     &H3455 
AI_MS03:
	;JP     &H243R 
	RET
;================================================================================
AI_MS04:
	BIT	4,(IX+11)	; MOVING 
	RET	NZ

	LD	A,R
	AND	&B00111111
	LD	B,A

	HALT		; DIT IS OM R TE VERANDEREN ( MOET !!

	LD	A,R
	AND	&B00111111
	LD	C,A

	PUSH	BC
	CALL	CALC_ADR
	POP	BC
	LD	A,(HL)
	CP	48
	RET	NC	; STOON 

	INC	HL
	LD	A,(HL)
	OR	A
	RET	NZ	; TANK 

	;  LD      A,B
	;  AND     &B00110000
	;  SRL     A
	;  LD      E,A

	; LD      A,C
	; AND     &B00110000
	; ADD     A
	; OR      E
	; LD      D,0
	; LD      E,A
	; LD      IY,AI_SECTORS
	; ADD     IY,DE

	; LD      A,(IY+0)
	; OR      A
	; RET     NZ               ; GEEN BLAUW IN SECTOR

	LD	(IX+2),B
	LD	(IX+3),C
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
	RET	NZ	; MOVING 

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

	DEC	A	; EEN VAK TERUG 
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

	HALT		; VOOR DE RANDOM ( MOET !!!!:) 

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

;--------- NO HARV -----------------------

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
	RET
AI_ADD_TNKS:
	LD	A,(AI_BUILD_CAR)
	OR	A
	RET	NZ

	LD	HL,AI_WAIT_COUNTER
	LD	A,(HL)
	DEC	(HL)
	OR	A
	RET	NZ

	LD	A,25
	LD	(AI_WAIT_COUNTER),A

	LD	A,R
	AND	&B00000011
	LD	(AI_CAR_TYPE),A

	SLA	A
	SLA	A
	LD	C,A
	LD	B,0
	LD	HL,ETB_VALUE
	ADD	HL,BC
	LD	A,(HL)
	CP	1
	RET	NZ
	LD	(HL),2	; tank wordt in de wachtrij gezet

	LD	A,(AI_CAR_TYPE)
	LD	B,A
	LD	A,4
	SUB	B
	LD	(AI_CAR_TYPE),A

	LD	A,1
	LD	(AI_BUILD_CAR),A
	RET

AI_CREATE_CAR:
	PUSH	BC
	CALL	AI_CREATE_CARI
	POP	BC
	RET

AI_CREATE_CARI:
	PUSH	HL	; push bb_bar adres 

	LD	HL,BUILDING_RED
	INC	HL	; build type
	LD	C,BUILD_DATA
	LD	B,25	; 25 gebouwen van AI
AI_LOOP_CRT_CAR:
	PUSH	HL
	PUSH	BC
	LD	A,(HL)
	CP	4	; gevonden ? dan createcar 
	CALL	Z,AI_CREATE_CAR2
	POP	BC
	POP	HL
	LD	A,B
	LD	B,0
	ADD	HL,BC
	LD	B,A
	DJNZ	AI_LOOP_CRT_CAR

	POP	HL	; terug naar orig. loop
	;  CALL    COLOR_WHITE
	RET		; mag eigenlijk niet hier komen 
	;   komt hier als geen enkele factory kan plaatsen 
AI_CREATE_CAR2:
	;                        ; if gevonden POP stack en cont 
	;                        ; else RET 
	INC	HL
	LD	B,(HL)	; ? 
	DEC	B
	INC	HL
	LD	C,(HL)	; hoekje factory 

	CALL	CALC_ADR

	LD	DE,FACTORY_DEPLOY
AI_CAR2_LP:
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
	JR	NC,AI_CAR2_LP2	; kan niet op rots of huis
	INC	HL
	LD	A,(HL)
	OR	A
	JR	NZ,AI_CAR2_LP2	; kan niet op tank
	JR	AI_CREATE_CAR3
AI_CAR2_LP2:
	POP	HL
	JR	AI_CAR2_LP
	RET		; probeer volgende factory 

AI_CREATE_CAR3:
	POP	AF	; BC
	POP	AF	; HL
	POP	AF	; adres
	POP	AF	; ret adres

	LD	BC,VELD_ADRES
	SBC	HL,BC
	SRL	L
	SRL	L
	LD	A,L
	LD	L,H	; HL = x & y
	LD	H,A

	LD	A,(AI_CAR_TYPE)
	LD	C,A
	LD	B,0	;rood
	CALL	ADD_TANK

	POP	HL
	LD	(HL),1	; clear tank bar 
	INC	HL	; dit pas NA dat 
	LD	A,(HL)	; de tank gebouwd is 
	INC	HL
	DEC	A
	LD	(HL),A

	DEC	HL
	DEC	HL

	XOR	A
	LD	(AI_BUILD_CAR),A
	;  LD      BC,25
	; LD      (AI_WAIT_COUNTER),BC
	RET		; terug org.loop
;-----------------------------------
; TANK CHECK.
;
; if any red tank is in the vicinity
; then attack mode
;-----------------------------------
TNK_CHK:
	LD	A,(IX+11)
	AND	&B00000111
	RET	Z	; niet harvester

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
;---------------------------------------
; TANK CHECK HELP VOOR BLAUW
;
; Zorgt ervoor dat de blauwe units
; elkaar helpen !
;---------------------------------------
TNK_CHK_HELP:
	; alleen even voor blauw 
	; CALL    COLOR_WHITE 

	BIT	7,(IX+13)
	RET	NZ

	LD	B,(IX+0)
	LD	C,(IX+1)
	CALL	CALC_ADR
	INC	HL	; NAAR TNK LAYER            

	;    LD      A,(IX+13) 
	;    LD      D,A 

	DEC	H	; UP            
	LD	A,(HL)
	OR	A
	CALL	NZ,FOUND_TNK2

	INC	HL	; RIUP            
	INC	HL
	INC	HL
	INC	HL

	LD	A,(HL)
	OR	A
	CALL	NZ,FOUND_TNK2

	INC	H	; RI            
	LD	A,(HL)
	OR	A
	CALL	NZ,FOUND_TNK2

	INC	H	; RIDO            
	LD	A,(HL)
	OR	A
	CALL	NZ,FOUND_TNK2

	DEC	HL	; DO            
	DEC	HL
	DEC	HL
	DEC	HL
	LD	A,(HL)
	OR	A
	CALL	NZ,FOUND_TNK2

	DEC	HL	; DOLI            
	DEC	HL
	DEC	HL
	DEC	HL
	LD	A,(HL)
	OR	A
	CALL	NZ,FOUND_TNK2

	DEC	H	; LI            
	LD	A,(HL)
	OR	A
	CALL	NZ,FOUND_TNK2

	DEC	H	; LIUP            
	LD	A,(HL)
	OR	A
	CALL	NZ,FOUND_TNK2
	RET
FOUND_TNK2:
	CALL	A_TO_IY	;  
	LD	A,(IY+13)
	BIT	7,A
	RET	NZ	; alleen blauwe mogen helpen 

	LD	A,(IY+11)
	AND	&B01110000
	RET	NZ	; ATT  & MOVE AFMAKEN 

	LD	A,(IX+14)
	LD	(IY+14),A
	RES	4,(IY+11)
	SET	5,(IY+11)
	RES	6,(IY+11)
	;   POP     AF          ; CIRLE AF MAKEN 
	RET

;------------------------------------
; In : IX  adres van harvester blauw
;------------------------------------
AI_HARVB:
	RET

	BIT	7,(IX+13)
	RET	NZ	; GEEN RODE        

	BIT	7,(IX+22)	;niet aan het harvesten    
	JP	Z,AI_HARVB_EMPTY

	LD	A,(IX+16)
	CP	70
	JP	Z,AI_HARVB_NULL

	DEC	(IX+18)	; counter
	RET	NZ
	LD	A,(IX+19)
	LD	(IX+18),A

	LD	B,(IX+0)
	LD	C,(IX+1)
	CALL	CALC_ADR

	LD	A,(HL)
	CP	48
	JP	NC,AI_HARVB_CHK_R	;GEEN harvest gevonden    
	CP	16
	JP	C,AI_HARVB_CHK_R	; GEEN harvest gevonden    

	; sta op harvest    
	; maak leeg en bepaal volgende stukje    

	CALL	AI_CALC_HRV2MON

	LD	A,(IX+16)
	ADD	B
	LD	(IX+16),A
	CP	70	; 700 MONEY    
	JR	NC,AI_HARVB_RET_B	;return to base    

	; bepaal volgende stukje    

	JR	AI_HARVB_CHK_R

AI_HARVB_RET_B:
	LD	A,70	;mooi afronden    
	LD	(IX+16),70	; jammer van de rest    

	LD	A,(IX+0)
	LD	(IX+20),A	; waar die vandaan kwam    
	LD	A,(IX+1)
	LD	(IX+21),A

	RES	7,(IX+22)	; harv uit    
	; en dan terug rijden    
	LD	A,50	;ix+26 <> 0 is return aan !    
	LD	(IX+26),A	; is tegelijk de wachtlus
	JP	HARV_RETURN2


AI_HARVB_CHK_R:
	LD	IY,RAD_HARVB
	LD	D,(IX+0)
	LD	E,(IX+1)
AI_HARVB_CHK_RL:
	LD	A,(IY+0)
	CP	100
	JR	Z,AI_HARVB_NULL

	ADC	A,D
	LD	B,A

	INC	IY
	LD	A,(IY+0)
	ADC	A,E
	LD	C,A

	INC	IY
	PUSH	BC
	CALL	CALC_ADR
	POP	BC
	LD	A,(HL)
	CP	16
	JR	C,AI_HARVB_CHK_RL
	CP	48
	JR	NC,AI_HARVB_CHK_RL

	INC	HL
	LD	A,(HL)
	OR	A
	CALL	NZ,AI_HARV_MOVEIT

	LD	(IX+2),B	; rij daar heen    
	LD	(IX+3),C
	RET

AI_HARV_MOVEIT:
	BIT	7,A	;rood mag niet uitwijken    
	RET	NZ

	CALL	A_TO_IY	; random ergens anders  
	LD	A,R	; maar wel in de buurt  
	AND	&B00000011
	ADD	D
	LD	(IY+2),A
	LD	A,R
	AND	&B00000011
	ADD	E
	LD	(IY+3),A
	RET

AI_HARVB_NULL:
	; geen harvest in cirkel kunnen vinden    
	RES	7,(IX+22)
	LD	A,(IX+16)
	OR	A
	JR	NZ,AI_HARVB_RET_B	; naar refinery terug    

	RET		; stop maar    

AI_HARVB_EMPTY:
	LD	A,(IX+26)
	OR	A
	RET	Z

	LD	A,(IX+16)
	OR	A
	JR	Z,AI_HARVB_EMPTY2
	LD	C,A
	LD	(IX+16),0

	LD	HL,(MONEY)
	LD	B,0
	ADD	HL,BC
	RET	C
	LD	(MONEY),HL
	RET
AI_HARVB_EMPTY2:
	LD	A,(IX+26)
	DEC	A
	LD	(IX+26),A
	RET	NZ

	LD	B,(IX+20)
	LD	C,(IX+21)
	LD	A,B
	OR	C
	RET	Z	; naar 0,0 is nix !  

	LD	(IX+2),B
	LD	(IX+3),C
	SET	7,(IX+22)
	RET

; -------------------------------------
; harvest to money
; IN HL = adres van harvest
; uit B = money
;--------------------------------------

AI_CALC_HRV2MON:
	LD	A,(HL)

	LD	C,0
	LD	B,10
	CP	16
	JR	Z,AI_CALC_2

	LD	C,16
	LD	B,10
	CP	32
	JR	Z,AI_CALC_2

	LD	C,16
	LD	B,8
	CP	39
	JR	NC,AI_CALC_2

	LD	C,16
	LD	B,4
	CP	33
	JR	NC,AI_CALC_2

	LD	C,0
	LD	B,8
	CP	25
	JR	NC,AI_CALC_2

	LD	C,0
	LD	B,4
AI_CALC_2:
	LD	A,C
	OR	A
	JR	Z,AI_CALC_3

	LD	A,(HL)
	SUB	C
AI_CALC_3:
	LD	(HL),A
	RET

AI_UPDATE:
	RET

AI_CHK_REPAIR:
	RET
AI_CHK_REBUILD:
	RET

AI_WAIT_COUNTER:	DB	25

AI_BUILD_CAR:	DB	0
AI_CAR_TYPE:	DB	0
AI_BUILD_BLD:	DB	0
	; 0 = niets doen
	; iets anders is ID building/car

AI_CUR_LEVEL:	DW	AI_LEVELAI

AI_LEVELAI:	DB	1,0,0	; 1 = level
	DB	2,1,0	; 2 = types of car
	DB	3,1,0	; 3 = level building
	DB	4,2,3
	DB	5,2,4
	DB	6,3,4
	DB	7,3,5
	DB	8,4,5
	DB	9,4,6
	DB	10,4,7

AI_MS_COUNTER:
	DB	0,0	; current/max 
	DB	0,4	; PROTECT HARV              -- MISSIO
	DB	0,0	; HOOK #1           -- MISSION 2 
	DB	0,0	; HOOK #2           -- MISSION 3 
	DB	0,2	; RANDOM RIJDEN             -- MISSIO
	DB	0,2	; PROTECT #1                -- MISSIO
	DB	0,3	; PROTECT #2                -- MISSIO
	DB	0,4	; PROTECT #3                -- MISSIO
	DB	0,3	; PROTECT #4                -- MISSIO
	DB	0,0	; MAKE ARMY #1              -- MISSIO
	DB	0,0	; MAKE ARMY #2              -- MISSIO
	DB	0,0	; FULL HOUSE #1             -- MISSIO
	DB	0,0	; FULL HOUSE #2             -- MISSIO
	DB	0,0	; FULL HOUSE #3             -- MISSIO
	DB	0,3	; FULL HOUSE #4             -- MISSIO
	DB	0,4	; RANDOM ATT                -- MISSIO

AI_MONEY:
	DW	400	; 24 CAR'S + HARV = 25 KILL'S 
