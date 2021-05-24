;------------------------------------
;               DOME
;
; (c) 1998 /2021 PARAGON Productions
;
;             
; loader.z80
; loads the game and starts it
;------------------------------------
	OUTPUT	binaries\loader.com

	ORG	$0100
ST:
	JP	START

	DB	$0D	; type dome.com

	DB	"DOME (c) 1998 PARAGON Productions",$0D,$0A
	DB	$1A	; Einde txt

	ORG	$C000	; after bios 

START:
	CALL	INIT_SCR	; SCREEN 0-80  + ROODE BALK  
	LD	HL,FILE0	; DOME BIOS 
	LD	A,0	; header 0 
	LD	BC,$0EFF	;  ! > 16 Kb 
	LD	DE,$0100	; adr 
	CALL	LOAD_FILE

	LD	HL,INT_DOS
	CALL	GET_INT

	LD	HL,RET
	CALL	PUT_TXT

	CALL	CHK_MSX	; MSX 2 OF HIGHER  

	LD	HL,FILE1
	LD	A,0
	LD	BC,$3FFF
	LD	DE,$4000
	CALL	LOAD_FILE

	LD	HL,$4000	; ADR IN RAM  
	LD	A,0	; PAGE (VRAM IN 64 KB) 
	LD	DE,$8000	; DE IN VRAM 
	CALL	POP.UP_START

	LD	HL,FILE2
	LD	A,0
	LD	BC,$3FFF
	LD	DE,$4000
	CALL	LOAD_FILE

	LD	HL,$4000	; ADR IN RAM   
	LD	A,1	; PAGE (VRAM IN 64 KB)  
	LD	DE,$0000	; DE IN VRAM  
	CALL	POP.UP_START

	LD	HL,FILE3
	LD	A,0
	LD	BC,$3FFF
	LD	DE,$4000
	CALL	LOAD_FILE

	LD	HL,$4000	; ADR IN RAM   
	LD	A,1	; PAGE (VRAM IN 64 KB)  
	LD	DE,$8000	; DE IN VRAM   
	CALL	POP.UP_START

	LD	HL,FILE4	; DOME Engine 
	LD	A,0	; header 0 
	LD	BC,$4FFF	;  ! > 16 Kb 
	LD	DE,$3000	; adr 
	CALL	LOAD_FILE

	LD	HL,FILE5	; Tank tabel 
	LD	A,0
	LD	BC,$1FFF
	LD	DE,$1000
	CALL	LOAD_FILE

	LD	HL,FILE6	; VELD
	LD	A,7	; is nog een BIN file
	LD	BC,$3FFF
	LD	DE,$8000	; van 8000-bfff ???
	CALL	LOAD_FILE

	HALT
	HALT

	CALL	SET_SCREEN5

	LD	HL,COLOR_DOME_GAME	; restore color  
	CALL	PUT_COLOR

	LD	A,($F3E0)	; screen5,2  
	OR	00000010b
	LD	($F3E0),A
	DI
	OUT	($99),A
	LD	A,129	; REG 1   
	OUT	($99),A
	EI

	LD	HL,SPRTAB	; maak sprites  
	CALL	MAK_SPR

	LD	HL,COPY_1_0
	CALL	PUTBLK

	DI		; >>> ????  
	CALL	$3000	; GO GAME !

	DI
	LD	HL,INT_DOS
	CALL	PUT_INT
	CALL	SET_SCREEN0
	EI

	LD	C,0	; officieel !!!!!
	CALL	DOS
	RET

;======================================

INIT_SCR:
	LD	A,80	; nog geen BIOS voorhanden
	LD	($F3AE),A
	LD	A,0	; SCREEN 0   
	LD	IY,($FCC1)
	LD	IX,$5F
	CALL	$1C

	LD	HL,2048
	LD	B,10
INIT_SCR_LOOP:
	LD	A,255
	LD	IY,($FCC1)
	LD	IX,$4D
	CALL	$1C
	INC	HL
	DJNZ	INIT_SCR_LOOP

	DI
	LD	A,15*16+8
	OUT	($99),A
	LD	A,128+12
	OUT	($99),A

	LD	A,16*5
	OUT	($99),A
	LD	A,128+13
	OUT	($99),A
	EI

	RET
CHK_MSX:
	LD	HL,TXT_MSX_TYPE
	CALL	PUT_TXT

	LD	HL,TXT_MSX_1
	OR	A
	CALL	Z,PUT_TXT

	LD	HL,$002D
	LD	A,($FCC1)
	CALL	$0C

	LD	HL,TXT_MSX_2
	CP	1
	JP	Z,PUT_TXT

	LD	HL,TXT_MSX_2P
	CP	2
	JP	Z,PUT_TXT

	LD	HL,TXT_MSX_TR
	CP	3
	JP	Z,PUT_TXT

	LD	HL,TXT_MSX_ON
	JP	PUT_TXT

;------------------------------------
DOSAGAIN:
	JP	EXIT_ON_ERR

	RET
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
	LD	DE,$04
	ADD	HL,DE	; Skip 4 bytes (the 2 addresses)  
	LD	BC,$1098
	OTIR		; Write 1st 16 bytes in VRAM  

	LD	E,$80
	EXX
	LD	L,(IX+4)
	LD	H,(IX+5)	; Dest. address in [HL]  
	LD	DE,$10
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
	OUT	($98),A	; Write in VRAM  
	INC	HL
	JR	POP.00
;
POP.03:	BIT	7,A
	JR	NZ,POP.04
	EXX
	LD	D,$00
	LD	E,A
	EXX
	XOR	A
	JR	POP.05
;
POP.04:	BIT	6,A
	JR	NZ,POP.06
	RES	7,A
	LD	BC,$0400
POP.07:	RLC	E
	JR	NC,POP.08
	LD	D,(HL)
	INC	HL
POP.08:	RLC	D
	RLA
	RL	C
	DJNZ	POP.07
	ADD	A,$80
	EXX
	LD	E,A
	EXX
	LD	A,C
	ADC	A,$00
	EXX
	LD	D,A
	EXX
	LD	A,$01
	JR	POP.05
;
POP.06:	AND	$3F
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
	LD	A,$02
	JR	NC,POP.09
	LD	C,$01
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
	LD	A,$02
POP.0E:	RLC	E
	JR	NC,POP.0F
	LD	D,(HL)
	INC	HL
POP.0F:	RLC	D
	JR	NC,POP.10
	INC	A
	CP	$07
	JR	NZ,POP.0E
POP.10:	LD	B,A
	LD	A,$01
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
	LD	C,$98
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
	AND	11000000b
	OR	B
	RLCA
	RLCA
	DI
	OUT	($99),A
	LD	A,$8E
	OUT	($99),A
	LD	A,L
	LD	A,L
	OUT	($99),A
	LD	A,H
	AND	$3F
	OR	$40
	OUT	($99),A

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
	AND	11000000b
	OR	B
	RLCA
	RLCA
	DI
	OUT	($99),A
	LD	A,$8E
	OUT	($99),A
	LD	A,L
	LD	A,L
	OUT	($99),A
	LD	A,H
	AND	$3F
	OUT	($99),A

	LD	A,(POPIFF)
	OR	A
	LD	A,C
	POP	BC
	RET	Z	; Restore int. status  
	EI
	RET


;-------------------------------------


;-----------------------------------------------
PUTBLK:

	DI		; vdp klaar ?      
	LD	A,2	; waarde 2 in reg 15      
	OUT	($99),A
	LD	A,$8F	; execute      
	OUT	($99),A
	NOP
	NOP		; wacht op vdp      
PUTBLK_WAIT:
	IN	A,($99)	;lees status      
	RRA		; is CE nog 1 dan C is loop      
	JR	C,PUTBLK_WAIT

	XOR	A	; status reg. op 0      
	OUT	($99),A
	LD	A,$8F
	OUT	($99),A

	LD	A,$20	; register 32      
	OUT	($99),A	; als control register      
	LD	A,$91	;in reg 17      
	OUT	($99),A
	LD	BC,$0F9B	; 15 bytes naar port 9b      
	OTIR
	EI

	RET

MAK_SPR:
	DI
	LD	A,1
	OUT	($99),A
	LD	A,$8E
	OUT	($99),A
	LD	A,255
	OUT	($99),A
	LD	A,$37
	OUT	($99),A
	LD	HL,SPRTAB

	LD	B,13
LOOPIE:
	PUSH	BC
	LD	BC,$2098
	OTIR
	POP	BC
	DJNZ	LOOPIE

	EI
	RET

PUT_COLOR
	DI
	XOR	A
	OUT	($99),A
	LD	A,16+128
	OUT	($99),A

	LD	BC,$209A
	OTIR
	EI
	RET

;================= LOADING

INT_DOS:	DW	0

TXT_GFX_LOAD:	DB	"DOME-init : loading :",$1D

TXT_PUNT:	DB	".",$1D

TXT_READY:	DB	"READY.",$0A,$0D,$1D

TXT_LACH_DOME:DB	"Launching Dome......................"
	DB	$0A,$0D,$1D

SPRTAB:
	DB	254,130,132,136,144,160,192,0
	DB	0,0,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0,0

	DB	$FF,$80,$80,$80,$80,$80,$80,$80
	DB	$80,$FF,0,0,0,0,0,0
	DB	$C0,$40,$40,$40,$40,$40,$40,$40
	DB	$40,$C0,0,0,0,0,0,0

	DB	$20,$40,$A0,$10,$08,0,0,0
	DB	0,0,0,$08,$10,$A0,$40,$20
	DB	$04,$02,$05,$08,$10,0,0,0
	DB	0,0,0,$10,$08,$05,$02,$04

	; pijl omhoog     
	DB	$01,$02,$04,$08,$0e,$02,$02,$03
	DB	0,0,0,0,0,0,0,0
	DB	$80,$40,$20,$10,$70,$40,$40,$c0
	DB	0,0,0,0,0,0,0,0
	; pijl rechts     
	DB	0,0,0,0,$18,$14,$F2,$81
	DB	$81,$F2,$14,$18,0,0,0,0
	DB	0,0,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0,0
	; pijl omlaag     
	DB	$03,$02,$02,$0E,$08,$04,$02,$01
	DB	0,0,0,0,0,0,0,0
	DB	$C0,$40,$40,$70,$10,$20,$40,$80
	DB	0,0,0,0,0,0,0,0
	; pijl links     
	DB	0,0,0,0,$18,$24,$47,$81
	DB	$81,$47,$24,$18,0,0,0,0
	DB	0,0,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0,0
	; attack rondje     
	DB	$07,$18,$20,$40,$40,$80,$83,$83
	DB	$80,$40,$40,$20,$18,$07,0,0
	DB	$80,$60,$10,$08,$08,$04,$04,$04
	DB	$04,$08,$08,$10,$60,$80,0,0
	; build blokje     
	DB	$88,$11,$22,$44,$88,$11,$22,$44
	DB	$88,$11,$22,$44,$88,$11,$22,$44
	DB	$88,$11,$22,$44,$88,$11,$22,$44
	DB	$88,$11,$22,$44,$88,$11,$22,$44
	; multiple select 1     
	DB	$F0,$80,$80,$80,$00,$00,$00,$00
	DB	$00,$00,$00,$00,$00,$00,$00,$00
	DB	$00,$00,$00,$00,$00,$00,$00,$00
	DB	$00,$00,$00,$00,$00,$00,$00,$00
	; multiple select 2     
	DB	$00,$00,$00,$00,$00,$00,$00,$00
	DB	$00,$00,$00,$00,$80,$80,$80,$f0
	DB	$00,$00,$00,$00,$00,$00,$00,$00
	DB	$00,$00,$00,$00,$00,$00,$00,$00
	; multiple select 3     
	DB	$00,$00,$00,$00,$00,$00,$00,$00
	DB	$00,$00,$00,$00,$00,$00,$00,$00
	DB	$0f,$01,$01,$01,$00,$00,$00,$00
	DB	$00,$00,$00,$00,$00,$00,$00,$00
	; multiple select 4     
	DB	$00,$00,$00,$00,$00,$00,$00,$00
	DB	$00,$00,$00,$00,$00,$00,$00,$00
	DB	$00,$00,$00,$00,$00,$00,$00,$00
	DB	$00,$00,$00,$00,$01,$01,$01,$0f

COLOR_DOME_GAME:
	DB	#00,#00,#62,#04,#52,#03,#50,#02
	DB	#23,#02,#20,#01,#53,#04,#11,#01
	DB	#00,#04,#45,#04,#40,#01,#72,#05
	DB	#04,#01,#06,#02,#00,#00,#77,#07

COPY_1_0:	DB	0,0,0,1
	DB	0,0,0,0
	DB	0,1,212,0
	DB	0,0,$D0


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

;---------------------------------

DOME_LIB0:	DB	"DOME    000"

FILE0:	DB	"BIOS    DAT"

FILE1:
	DB	"BALKEN4 ZOP"
FILE2:
	DB	"UNITTOT ZOP"
FILE3:
	DB	"PAGE5   ZOP"
FILE4:
	DB	"DOME    DAT"
FILE5:
	DB	"TANKTAB DAT"
FILE6:
	DB	"VELD    DAT"

;============================== TEXT'EN

RET:	DB	$0A,$0D,$1D
TXT:	DB	"    ",$0A,$0D,$1D

TXT_ERR:	DB	"Please install the specified device before loading "
	DB	"DOME...PRESS A KEY TO RESUME.",$0D,$1D

TXT_DOME_INIT:DB	"DOME_init : DOME v0.7c ",$0A,$0D,$1D


;===========  MSX_TYPE TXT'S

TXT_MSX_TYPE:	DB	"SYS_init : ",$1D
TXT_MSX_1:	DB	"MSX-1 Found.",$0A,$0D,$1D
TXT_MSX_2:	DB	"MSX-2 Found.",$0A,$0D,$1D
TXT_MSX_2P:	DB	"MSX-2+ Found.",$0A,$0D,$1D
TXT_MSX_TR:	DB	"MSX-TURBO-R Found.",$0A,$0D,$1D
TXT_MSX_ON:	DB	"MSX-3 Found ,let us know it's name.",$0A,$0D,$1D

;========== MOUSE TXT'S

TXT_MOUSE_SE:	DB	"Mouse_init: Scaning Game Ports...",$0A,$0D,$1D
TXT_MOUSE_YES:DB	"            Mouse found on port : "
TXT_MOUSE_PORT:	DB	" ",$0A,$0D,$1D
TXT_MOUSE_NO:	DB	"            No mouse found",$0A,$0D,$1D
TXT_MOUSE_ERR:DB	"You need a mouse connected on port 1 or 2 to "
	DB	"run DOME.",$0A,$0D,$1D

;============  DISK ERROR TXT'S

TXT_D_NO_BIN:	DB	"Error : the specified file is corruted..."
	DB	$0A,$0D,$1D

;===================== EXIT DOME

TXT_THANKS:	DB	"Thanks for playing Dome."
	DB	$0A,$0D,$1D

	INCLUDE	rebuild\library.z80
