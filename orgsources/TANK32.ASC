; source met alleen maar tank data

TANK_DATA:	EQU	32

	ORG	&h8000	; offset = &H4000
ST:
TANK1:

	DS	TANK_DATA

	; siege 1

	DB	24,15	; huidige x en y in 16
	DB	24,16	; dest. in 16
	DB	0,0	; offset t.o.v. bovenstaande coor    
;                             ; dit om een tank smooth te bewegen stapjes van 2
	DB	0	; eventuele step byte    
	DB	0,0	; speed step byte ( per stap een aantal p 
	DB	0	; richting byte nu 4 richtingen    
	DB	2	; de speed byte ( snelheid )   
	DB	&B00000001
	;              000       3 bits voor type tank    
	;             0          3e vrij !!!!!!!!!!!!!!!!!!! 
	;            0           4e bit voor normal move    
	;           0            5e bit voor attack move    
	;          0             6e bit voor do_attack    
	;         0              7e bit voor sprite select    

	DB	155	; power (delen door 8 voor schaal)
	DB	1	; nummer van de tank 
	DB	0	; 14 = doelwit nummer   
	DB	0	; 15 = afwk_move enzo   
	DB	190	; attack power   
	DB	150	; shield   
	DB	1	; HUIDIGE TIMER   
	DB	19	; ORG TIME   
	DB	0,0	; coordinaten geattacked doel   
	DB	&B00000000	; Bitjes rij..   
	;                1       ; 1 = in M_SEL   
	;               1        ; kannon schot 1   
	;              1         ; kannon schot 2   
	;             0          ; niet gebruikt   
	;           11           ; inslag 3 frames !!   
	;          1             ; wordt geSET als er op je geschoten is   
	;         1              ; harv bitje : 1=harv 0=stop   
	DB	&B00000000	; only AI ( please :)   
	;             0000       ; welke mission  ( 0=NON )   
	;            0           ; set=ultra mission (niet terug schieten) 
	;           0            ;6  set=   
	;          0             ;   
	;         0              ;   
	DB	0,0

	DB	0,0,0,0,0,0

	;      NR             AT    SC    TI   SP   

	;      000 = HARV    / 0   /140  /60  /2   
	;      001 = SIEGE   /190  /150  /19  /2   
	;      010 = TANK    /175  /140  /15  /2   
	;      011 = QUAD    /160  /120  /10  /4   
	;      100 = TRIKE   /155  /100  /7   /8   

; ---------- nu op 26 bytes -------------------------


	DS	126*TANK_DATA


;------------------------------ ROODE UNITS

	DB	1,1,1,1,0,0,0,0,0,0,2,&B00001000,255,128,0,0
	DB	0	; HARV  1R   
	DB	140
	DB	1
	DB	50
	DB	0,0
	DB	&B10000000	;automatisch harvest 
	DB	&B00000000
	DB	0,0
	DB	0,0,0,0,0,0

	DS	127*TANK_DATA
EI:
