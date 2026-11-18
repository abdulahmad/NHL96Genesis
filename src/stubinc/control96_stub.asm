;	Segment build for control96.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$0162F0

; includes for stubs to replace removed code
	include	stubinc\ports.inc		;IO_* / VDP_* ports
	include	stubinc\equals.inc		;VDP status bits
	include	ram96.asm				;RAM map
	include	externs96.asm			;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac		;String


; External addresses outside, read from lst/nhl96.bin.
SPAlist = $005F96					;frames96
updatepadinput = $00A4DC			;input96
SetSPA = $01A614					;skate96
dirtab = $01AE60					;skate96
loadTeamStruct = $01D328			;lines96_bar
getpde = $01FB24					;collide96
setpde = $01FB44					;collide96
sfx = $088470						;sound96
PlaceBoardFall = $1D8F66			;code96_15
SetSflags8Bit1 = $1D92EC			;code96_15
SPAgslam = $37A						;SPA value (frames96)
SPAgsweepchk = $52C					;SPA value (frames96)
SPAboxwallright = $AA2				;SPA value (frames96)
SPAHold3 = $16EE					;SPA value (frames96)
SPAinjuryfall = $17E4				;SPA value (frames96)
SPAinjury1 = $1F76					;SPA value (frames96)
SPAsweepchk = $216A					;SPA value (frames96)
SPAfallfwd = $2576					;SPA value (frames96)
SPAfallback = $26C8					;SPA value (frames96)
SPAbglass = $2B88					;SPA value (frames96)
SPAfpunchfinal = $3300				;SPA value (frames96)
SPAHold = $169C						;SPA value (frames96)
SPAboardbot = $2412					;SPA value (frames96)
SPAboardleft = $2360				;SPA value (frames96)
SPAboardmidl = $2084				;SPA value (frames96)
SPAboardmidr = $24C4				;SPA value (frames96)
SPAboardtop = $22AE					;SPA value (frames96)
SPAburst = $2C5C					;SPA value (frames96)
SPAhook = $1792						;SPA value (frames96)


; Main segment code
	include	control96.asm
