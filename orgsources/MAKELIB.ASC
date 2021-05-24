
; Maak een LIBrary aan van files

	org	#0100

bdos:	equ	#05
setdta:	equ	26	; zet lees/schrijf-adres
open_file:	equ	15	; open file
close_file:	equ	16	; sluit file
create_file:	equ	22	; maak file aan
read_block:	equ	39	; laad van disk
write_block:	equ	38	; schrijf naar disk

entry_length:	equ	11 + 2 + 3

	call	count_files	; tel aantal files
	ld	(files),bc

	call	calc_length	; bereken lengte
	; directory
	ld	(dir_length),hl

	call	make_dir	; maak directory

	call	save_dir	; bewaar directory

	call	store_files	; bewaar files

	ld	de,fcb2
	ld	c,close_file
	call	bdos	; klaar!
	ret

; Tel aantal files
; In: -
; Uit: BC: aantal files
; Verandert: AF,BC,DE,HL
count_files:	ld	hl,file_names
	ld	bc,0
	ld	de,11

count_files1:	ld	a,(hl)
	or	a
	ret	z
	inc	bc
	add	hl,de
	jr	count_files1

; Bereken lengte directory
; In: BC: aantal files
; Uit: HL: lengte directory
; Verandert: AF, BC, DE, HL
calc_length:	ld	hl,3
	ld	de,entry_length

calc_length1:	ld	a,b
	or	c
	ret	z
	add	hl,de
	dec	bc
	jr	calc_length1

; Maak directory
; In: HL: lengte directory
; Uit: -
; Verandert: alles
make_dir:	ld	(getal1),hl
	ld	hl,0
	ld	(getal1+2),hl

	ld	hl,file_names
	ld	de,directory
	ld	bc,(files)

make_dir1:	push	bc

	push	hl
	push	de

	ld	bc,11
	ld	de,fname1
	ldir		; filenaam naar FCB

	pop	de
	pop	hl
	ld	bc,11
	ldir		; filenaam naar directory

	push	hl

	push	de
	ld	de,fcb1
	ld	c,open_file
	call	bdos
	ld	de,fcb1
	ld	c,close_file
	call	bdos
	pop	de
	ld	hl,(length1)

	ld	a,l
	ld	(de),a
	inc	de
	ld	a,h
	ld	(de),a
	inc	de

	ld	ix,getal1	; bewaar positie in file
	ld	a,(ix)
	ld	(de),a
	inc	de
	ld	a,(ix+1)
	ld	(de),a
	inc	de
	ld	a,(ix+2)
	ld	(de),a
	inc	de

	push	de

	ld	iy,getal2
	ld	(iy),l
	ld	(iy+1),h
	ld	ix,getal1
	call	add_32bit

	pop	de
	pop	hl
	pop	bc
	dec	bc
	ld	a,b
	or	c
	jp	nz,make_dir1
	xor	a
	ld	(de),a
	ret

; Bewaar directory
; In: -
; Uit: -
; Verandert: alles
save_dir:	ld	hl,lib_name
	ld	de,fname2
	ld	bc,11
	ldir

	ld	de,fcb2
	ld	c,create_file
	call	bdos	; cre	er file

	call	intfcb2

	ld	de,files
	ld	c,setdta
	call	bdos

	ld	de,fcb2
	ld	c,write_block
	ld	hl,(dir_length)
	call	bdos	; schrijf directory weg
	ret

; Bewaar files in .LIB-file
; In: -
; Uit: -
; Verandert: AF, BC, DE, HL
store_files:	ld	bc,(files)
	ld	hl,file_names

store_files1:	push	bc

	ld	bc,11
	ld	de,fname1
	ldir

	PUSH	HL

	LD	HL,fname1
	LD	B,11
	CALL	PUT_TXT
	LD	HL,RET
	LD	B,2
	CALL	PUT_TXT

	POP	HL
	PUSH	HL

	call	clrfcb1

	ld	c,open_file
	ld	de,fcb1
	call	bdos

	call	intfcb1

	ld	hl,(length1)
	call	copy_file	; kopieer file

	ld	de,fcb1
	ld	c,close_file
	call	bdos

	pop	hl
	pop	bc
	dec	bc
	ld	a,b
	or	c
	jp	nz,store_files1
	ret

; Copieer file naar .LIB-file
; In: HL: lengte file
; Uit: -
; Verandert: AF, BC, DE, HL
copy_file:	push	hl
	ld	c,setdta
	ld	de,directory
	call	bdos
	pop	hl

copy_file1:	ld	de,32768
	xor	a
	sbc	hl,de	; file >32768 bytes?
	jp	c,copy_file2	; Nee, copieer rest

	push	hl
	ld	hl,32768
	ld	de,fcb1
	ld	c,read_block
	call	bdos

	ld	hl,32768
	ld	de,fcb2
	ld	c,write_block
	call	bdos
	pop	hl
	jp	copy_file1

copy_file2:	add	hl,de
	push	hl
	ld	de,fcb1
	ld	c,read_block
	call	bdos
	pop	hl
	ld	de,fcb2
	ld	c,write_block
	call	bdos
	ret

; Tel twee 32-bits getallen op
; In: IX: adres getal 1
;     IY: adres getal 2
; Uit: getal 1 gevuld met resultaat
; Verandert: BC,DE,HL
add_32bit:	ld	l,(ix+0)
	ld	h,(ix+1)

	ld	e,(iy+0)
	ld	d,(iy+1)

	ld	c,(ix+2)
	ld	b,(ix+3)
	add	hl,de
	jr	nc,add_32bit1
	inc	bc
add_32bit1:	ld	(ix+0),l
	ld	(ix+1),h

	ld	l,(iy+2)
	ld	h,(iy+3)
	add	hl,bc
	ld	(ix+2),l
	ld	(ix+3),h
	ret

; Maak FCB 1 schoon
; In: -
; Uit: -
; Verandert: AF, BC, DE, HL
clrfcb1:	ld	hl,fcbdat1
	ld	bc,25
	xor	a
	ld	(hl),a
	ld	de,fcbdat1 + 1
	ldir
	ret

; Initialiseer FCB 1
; In: -
; Uit: -
; Verandert: AF, HL
intfcb1:	ld	hl,0
	ld	(fcb1 + 12),hl
	ld	(fcb1 + 33),hl
	ld	(fcb1 + 35),hl
	xor	a
	ld	(fcb1 + 32),a
	inc	hl
	ld	(fcb1 + 14),hl
	ret

; Initialiseer FCB 2
; In: -
; Uit: -
; Verandert: AF, HL
intfcb2:	ld	hl,0
	ld	(fcb2 + 12),hl
	ld	(fcb2 + 33),hl
	ld	(fcb2 + 35),hl
	xor	a
	ld	(fcb2 + 32),a
	inc	hl
	ld	(fcb2 + 14),hl
	ret
; HL=TXT
; B=LENGHTE

PUT_TXT:
	LD	A,(HL)
	LD	E,A
	LD	C,2
	PUSH	HL
	PUSH	BC
	CALL	bdos
	POP	BC
	POP	HL
	INC	HL
	DJNZ	PUT_TXT
	RET

RET:	DB	&H0A,&H0D


getal1:	defw	0,0	; opslagplaats voor de twee
getal2:	defw	0,0	; 32-bits getallen

dir_length:	defw	0	; lengte van directory

; Het eerste FCB
fcb1:	defb	0	; drive (0=default, 1 = A:)
fname1:	defm	"           "
fcbdat1:	defb	0,0,0,0
length1:	defb	0,0,0,0,0,0,0,0,0,0,0
	defb	0,0,0,0,0,0,0,0,0,0,0

; Het tweede FCB
fcb2:	defb	0	; drive (0=default, 2 = B:)
fname2:	defm	"           "
	defb	0,0,0,0,0,0,0,0,0,0,0,0,0
	defb	0,0,0,0,0,0,0,0,0,0,0,0,0

; Naam van de te maken .LIB-file
lib_name:	DB	"DOME    000"

; Lijst met files die in de .LIB-file moeten
file_names:
	DB	"BIOS    DAT"
	DB	"LOADER  DAT"
	DB	"BALKEN4 ZOP"
	DB	"UNITTOT ZOP"
	DB	"PAGE5   ZOP"
	DB	0

	; 0 = laatste gehad

files:	defw	0	; bewaarplaats aantal files
directory:	nop

