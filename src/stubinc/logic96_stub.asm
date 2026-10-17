;	Segment build for engine\logic96.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$00C548

; includes for stubs to replace removed code
	include	stubinc\ports.inc		;IO_* / VDP_* ports
	include	stubinc\equals.inc		;VDP status bits
	include	ram96.asm				;RAM map
	include	externs96.asm			;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac		;String

; External addresses outside, read from lst/nhl96.bin.
assfaceoff = $009A24				;faceoff96
assfaceoffpl = $009A40				;faceoff96
puckfaceoff = $009AD6				;faceoff96
puckfaceoff2 = $009E52				;faceoff96
assbench = $016E40					;logic96_ass
asseben = $016FCE					;logic96_ass
asspenalty = $017058				;logic96_ass
assdopen = $0171E0					;logic96_ass
assepen = $017210					;logic96_ass
assgoaliebreakwait = $0172C2		;logic96_ass
assstanley = $017334				;logic96_ass
assscore = $017388					;logic96_ass
assgoaliectrl = $01745A				;logic96_ass
assgoaliecpu = $0175BE				;logic96_ass
assgoalietopuck = $017E7E			;logic96_puck
chkpuckc = $018068					;logic96_puck
asspuckc = $018092					;logic96_puck
assbreakaway = $018874				;logic96_puck
assnearest = $01889A				;logic96_puck
asspassrec = $018ECA				;logic96_puck
assshoot = $018FE0					;logic96_puck
puckshootout = $019018				;shootout96
puckpenshot = $019326				;shootout96
pucknorm = $019B70					;logic96_pull
puckunflip = $019F14				;logic96_pull
puckshadow = $019F58				;logic96_vec
rtss2 = $01F84A						;collide96
assonetimer = $1D6872				;logic96_timer
assfight = $00B988					;fight96
assfwatch = $00C1C8					;fight96


; Main segment code
	include	engine\logic96.asm
