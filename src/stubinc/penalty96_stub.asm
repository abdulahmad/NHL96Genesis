;	Segment build for engine\penalty96.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$01BF94

; includes for stubs to replace removed code
	include	stubinc\ports.inc		;IO_* / VDP_* ports
	include	stubinc\equals.inc		;VDP status bits
	include	ram96.asm				;RAM map
	include	externs96.asm			;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac		;String

; External addresses outside, read from lst/nhl96.bin.
limitfo = $00A370					;faceoff96
ClearMessageLine = $00C0A2			;fight96
FindGoalie = $0168B8				;control96
assinsert = $01A3D0					;logic96_vec
assreplace = $01A3DA				;logic96_vec
Vmaddr = $01B678					;video96
dobitmap = $01B692					;video96
DecompressGraphicsPlain = $01B730	;video96
eraser = $01B976					;video96
Framer = $01B9B0					;video96
printz = $01BB8E					;video96
print = $01BBA0						;video96
PushTime = $01BD84					;video96
appendz = $01BE78					;video96
appstring = $01BE80					;video96
printbigcur = $01BEE8				;video96
GetPeriodTimeRemaining = $01EBCC	;collide96
rtss2 = $01F84A						;collide96
AssignByPosition = $01FE58			;players96
setplayer = $01FEA0					;players96
ShowThreeStars = $022820			;goal96_box
PenaltyShotBox = $022B70			;goal96_box
ShowGoalBox = $022C5E				;goal96_box
GetPlayerName = $022E70				;middle96
GetPlayerNumInitial = $022ED6		;middle96
bfasciicon = $0232C8				;middle96_ascii
priolist = $023426					;players96_sub
sfx = $088470						;sound96
song = $088586						;sound96
stop_current_song = $0885FC			;sound96
FramerMap = $091B86					;graphics96
RefTiles = $097E72					;graphics96
RefTilesHor = $098F30				;graphics96
EASNmap = $13D59E					;graphics96
BigFontMap = $1B89C8				;graphics96
BigFontMap3 = $1B9416				;graphics96
ShootoutWonBy = $1D82A2				;shootout96_path
updatePPTeamTime = $1D8618			;shootout96_path
SkipStrings = $01D7F2				;hockey96_inter
ZeroLong = $000772					;main96
Penaltylist = $00E818				;logic96
PenShotPenalties = $00EBC2			;logic96
DoubleMinorPenalties = $00EBF8		;logic96


; Main segment code
	include	engine\penalty96.asm
