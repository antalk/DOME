;---------------------------------------
;
; LIBRARY FUNCTIONS
;
; (c) 1998 PARAGON Productions
;
;---------------------------------------

	OUTPUT	binaries\library.bin

DOS:		EQU	$5
D_OPEN:		EQU	$0F
D_SETDMA:	EQU	$1A
D_READ:		EQU	$27 
D_WRITE:	EQU	$26
D_CREATE:	EQU	$16
D_CLOSE:	EQU	$10
D_GET_DRIVE:EQU	$19

GET_INT:	EQU	$0100
PUT_INT:	EQU	$0103
COLOR_WHITE	EQU	$0106
COLOR_BLACK	EQU	$0109
SCREEN_ON	EQU	$010C
SCREEN_OFF	EQU	$010F
SET_SCREEN0	EQU	$0112
SET_SCREEN5	EQU	$0115
SPRITES_ON	EQU	$0118
SPRITES_OFF	EQU	$011B
;PUT_SPRITE    EQU     $011E
SET_PAGE	EQU	$0121
GET_TIME	EQU	$0124
PUT_TXT		EQU	$0127
PUT_TXT2	EQU	$012A
SAVE_ENTRY	EQU	$012D
EXIT_ON_ERR	EQU	$0130


INIT_LIB:	JP	LOAD_DIR	; Laad dir. in mem
FILE_FIND:	JP	SEARCH_FILE
LOAD_LIB:	JP	GET_FILE
CLOSE_LIB:	JP	CLOSE

LOAD_FILE:	JP	LOAD_BIN

	RET		; stel dat ??
	; geen ORG 


PUT_NAM_FCB:	;                         ; In:  HL = file name pointer
	LD	DE,FCB+1
	LD	BC,$0B	; Out: A  = drive name (0 = def., 1 =  
	LDIR		; Cng: HL,DE BC,AF       
	XOR	A
	LD	(FCB),A	;      (DRVNAM) must be valid    
	RET

SETDMA:
	LD	C,D_SETDMA	; DE=ADR   
	JP	DOS
OPEN:
	LD	DE,FCB
	LD	C,D_OPEN
	CALL	DOS
	LD	HL,$01
	LD	(FCB+14),HL	; Record length = 1 byte    
	DEC	L
	LD	(FCB+33),HL
	LD	(FCB+35),HL	; Current record number = 0    
	RET

READ:
	LD	DE,FCB
	LD	C,D_READ	; HL=NR BYTES   
	JP	DOS

CLOSE:
	LD	DE,FCB
	LD	C,D_CLOSE
	JP	DOS

;---------------------------------------
; Load normal .BIN file
;
; HL=NAME      pointer
; BC=LENTE
; DE=ADR
; A=HEADER LENGTE / deze wordt getrashed
;---------------------------------------

LOAD_BIN:
	PUSH	BC
	PUSH	AF
	PUSH	DE

	CALL	PUT_NAM_FCB
	CALL	OPEN

	POP	DE
	CALL	SETDMA

	POP	HL
	LD	L,H	; KAN ?? 
	LD	H,0
	CALL	READ	; kan dit ??

	POP	HL
	CALL	READ	; op oude DMA adres ???
	CALL	CLOSE	; ja !! raar he ?!
	RET

/* Laad directory
* In: HL: Adres filename
*    DE: Bestemmingsadres directory
*/

LOAD_DIR:
	LD	DE,DIRECTORY

	PUSH	DE
	PUSH	DE

	CALL	PUT_NAM_FCB	; put HL in FCB
	CALL	OPEN

	POP	DE
	CALL	SETDMA	; destination is DIRECTORY

	LD	HL,2
	CALL	READ

	POP	HL	; In BC aantal files
	LD	C,(HL)
	INC	HL
	LD	B,(HL)

	LD	HL,0
	LD	DE,11 + 3 + 2	; lengte entry = name

CALC_LENGTH:
	ADD	HL,DE
	DEC	BC
	LD	A,B
	OR	C
	JR	NZ,CALC_LENGTH

	CALL	READ	; lees directory struct
	RET

; Zoek file op in directory en stel record number in
; In: HL: adres te laden file-naam
;     DE: adres directory
; Uit: HL: lengte file
;      A: 0 indien gelukt, 255 indien mislukt

SEARCH_FILE:
	PUSH	DE	; adres waar file naar toe meot

	LD	DE,DIRECTORY	; eerste2 bytes zijn aantal files
SEARCH_FILE0:

	PUSH	HL	; adres naam v.d. file
	PUSH	DE	; adres directory

	CALL	CMP_STR
	OR	A
	JR	Z,SEARCH_FILE1

	POP	DE
	LD	HL,11 + 2 + 3
	ADD	HL,DE
	EX	DE,HL	; DE = positie in directory
	POP	HL
	JR	SEARCH_FILE0

SEARCH_FILE1	;                        ; HL = adres in directory
	EX	DE,HL

	LD	E,(HL)
	INC	HL
	LD	D,(HL)	; laad lengte
	INC	HL
	PUSH	DE

	LD	DE,FCB + 33
	LD	BC,3
	LDIR		; Record Number naar FCB

	XOR	A	; drive ??
	LD	(DE),A

	POP	HL	; lengte in HL

	POP	DE
	POP	DE
	POP	DE
	RET

CMP_STR:
	LD	B,11
CMP_STR1:
	LD	A,(DE)
	CP	(HL)
	RET	NZ
	INC	HL
	INC	DE
	DJNZ	CMP_STR1
	XOR	A
	RET

GET_FILE:
	CALL	SEARCH_FILE	; if found lengte in HL

	PUSH	HL
	CALL	SETDMA	; DE is adres

	POP	HL
	CALL	READ
	RET

;----------------------------------------------
; SAVE FILE FUNCTIONS
;----------------------------------------------

CHECK_FOR_SAVE:
	LD	DE,SAVE_FCB
	LD	C,D_OPEN
	CALL	DOS
	RET

;--------------------------------------------------
; LOG FILE FUNCTIONS
;--------------------------------------------------

CREATE_LOG:
	PUSH	BC
	PUSH	DE
	PUSH	HL
	PUSH	IX
	PUSH	IY
	EXX
	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	DE,LOG_FCB
	LD	C,D_CREATE
	CALL	DOS
	JP	RELSTACK

CLOSE_LOG:
	PUSH	BC
	PUSH	DE
	PUSH	HL
	PUSH	IX
	PUSH	IY
	EXX
	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	DE,LOG_FCB
	LD	C,D_CLOSE
	CALL	DOS
	JP	RELSTACK

WRITE_LOG:
	CALL	WRITELOG_BUF

	PUSH	BC
	PUSH	DE
	PUSH	HL
	PUSH	IX
	PUSH	IY
	EXX
	PUSH	BC
	PUSH	DE
	PUSH	HL

	LD	DE,LOG_BUF
	LD	C,D_SETDMA
	CALL	DOS

	LD	DE,LOG_FCB
	LD	HL,1
	LD	(LOG_RECLEN),HL
	LD	C,D_WRITE
	LD	HL,52
	CALL	DOS
	JP	RELSTACK

WRITELOG_BUF:
	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	B,50
	LD	DE,LOG_BUF
WRITE_LOG_BL:
	LD	A,(HL)
	INC	HL
	CP	255
	JR	NZ,WRITE2
	LD	A,32
	DEC	HL
WRITE2:
	LD	(DE),A
	INC	DE
	DJNZ	WRITE_LOG_BL
	POP	HL
	POP	DE
	POP	BC
	RET

RELSTACK:
	POP	HL
	POP	DE
	POP	BC
	EXX
	POP	IY
	POP	IX
	POP	HL
	POP	DE
	POP	BC
	RET

LOG_BUF:	DS	50
	DB	10
	DB	13

FCB:	DB	0
FILENAME:	DB	"           "
BLOCK:	DW	#00
RECORDLENGTH:	DW	#00
FILELENGTH:	DW	#00,#00
SYSTEMVAR:	DW	#00,#00,#00,#00,#00,#00
	DB	0
RECORDNR:	DW	#00,#00

LOG_FCB:
	DB	0
LOG_NAME:	DB	"DOMELOG TXT"
LOG_BLOCK:	DW	0
LOG_RECLEN:	DW	0
LOG_BESTLEN:	DW	0,0
LOG_DATE:	DW	0
LOG_TIME:	DW	0
LOG_ID:	DB	0
LOG_DL:	DB	0
LOG_FIRCLS:	DW	0
LOG_LASCLS:	DW	0
LOG_RLSCLS:	DW	0
LOG_CR:	DB	0
LOG_RANREC:	DW	0,0

SAVE_FCB:
	DB	0
	DB	"SAVEDATADAT"
	DW	0
	DW	0
	DW	0,0
	DW	0
	DW	0
	DB	0
	DB	0
	DW	0
	DW	0
	DW	0
	DB	0
	DW	0,0

DIRECTORY:
	DB	0	; 7 BYTES PER FILE  OF 11+3+2
	;                        ; NAAM - LENGTE - REC.NUM
	