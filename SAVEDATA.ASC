;---------------------------------------
;
; SAVEGAME DATA FOR DOME
;
; (c) 1998 PARAGON Productions
;     Antal van Kalleveen
;
; USE: INCLUDE 4 in DOME22.ASM
;---------------------------------------
	DB	0

OFFSET:	DB	1,1	; zorg dat er altijd een rand omheen 

MBUSY:	DB	0
TNKADR:	DW	0


MS_COUNT:
	DB	0	; multiple select counter 

;----------------- sprites ---------------------
SPRATR:
MOUSEY:	DB	96
MOUSEX:	DB	128
MOUSE_SHAPE:	DB	0
	DB	4

	DB	0,0,4,4
	DB	0,0,8,8
	DB	0,0,12,12

	DB	0,0,32,16	; build vlak sprite 
	DB	0,0,32,20
	DB	0,0,32,24
	DB	0,0,32,28
	DB	0,0,32,32
	DB	0,0,32,36

	DB	0,0,36,40
	DB	0,0,40,44
	DB	0,0,44,48
	DB	0,0,48,52

;------------ BB Stuff -------------------
BBB_VALUE:
	; 1 = aanwezig             , build step, current step  
	; 2 = busy with building  
	; 3 = ready building  
	; 0 = niet aanwezig  

	DB	1,64,63,2	; status, steps, current, money neede 
	DB	1,8,7,24
	DB	1,64,63,80
	DB	0,16,15,10
	DB	0,2,1,90
	DB	0,4,3,14
	DB	0,8,7,1
	DB	0,2,1,2

TBB_VALUE:
	DB	0,16,15,0	; 5types units 
	DB	0,8,7,0
	DB	0,4,3,0
	DB	0,2,1,0
	DB	0,2,1,0	; BBB +13 

ETB_VALUE:
	DB	1,16,15,0
	DB	1,8,7,0
	DB	1,4,3,0
	DB	1,2,1,0
	DB	0,2,1,0	; BBB + 18 

B_BALK_TYPE:	DB	0
B_BALK_NR:	DB	0
T_BALK_NR:	DB	0
BB_WAIT:	DB	0
BB_UP_DOWN:	DB	0

; ----------- Upgrade Stuff -------------

UPG_LEV_BLD:	DB	0	; total upg level 
UPG_LEV_UNT:	DB	0	; MAX 4 ? 
IS_UNT_UPGRADING:	DB	0	; 1 per keer aub 
IS_BLD_UPGRADING:	DB	0

; ------------ Power Stuff ---------------

POWER_NEEDED:	DB	10
POWER_DELIVERED:	DB	0
HAS_RADAR:	DB	0	; is radarbuilding present ? 

; ------------ Money Stuff ---------------

DIS_MONEY:	DW	200
MONEY:	DW	300	; maal 10 
MONEY_POS:	DB	204,4
MONEY_CHAR:	DB	0,0,0,0,0

FPS_OUT:	DW	0

; ------------- Ontplof Stuff ---------------

PLOF_COUNT:	DB	0
PLOF_TABEL:
	DB	0,0,0	; X Y nummer 
	DB	0,0,0	; nummer = 0 > leeg einde rij 
	DB	0,0,0	; nummer = 1 > plof aanwezig 
	DB	0,0,0
	DS	240,0	; genoeg ruimte ? 


CPYTT:	; copy tank tabel  
	DS	144*2	; indeling is  0 1 of 2 en dan ix+ 
	DB	0,0	; voor de afronding z.w.m.z. en dus 4

P_BUILD:	DW	0	; pointer naar huidig geslect buildin

; -------- Tanks and Building Stuff ---------------

BUILDINGS:
	DB	4

BUILDING1:
	DB	1,7,25,13,2,2,200,150	; yard coors 
	DB	&B00000000
	;                0  ; repair bitje 
	;               0   ; is upgrading.. 
	;              0    ; refinery bezet ? 
	DB	0	; cur. upgrade level 
	DB	3	; max. upgrade level 
	DB	0	; upgrade status 
	DB	0	; powerdelivered only windtrap 

	DS	BUILD_DATA*24

	;--------------------------------------------- 
BUILDING_RED:
	DB	26,7,50,46,2,2,255,100,0,0,0,0,0
	DB	27,1,53,46,2,2,255,100,0,0,0,0,0
	DB	28,4,49,49,3,2,255,100,0,0,0,0,0

	DS	BUILD_DATA*22	; 50 stuks max. 
	; 25 blauw / 25 rood 

TNK_CNT_BLW:	DB	2
TNK_CNT_RED:	DB	2

BLD_CNT_BLW:	DB	1
BLD_CNT_RED:	DB	0

DED_CNT_BLW:	DW	0
DED_CNT_RED:	DW	0

END_SAVE_DAT:
	DB	255
