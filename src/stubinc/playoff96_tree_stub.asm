;	Segment build for engine\playoff96_tree.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$1E700A

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	ram96.asm		;RAM map
	include	externs96.asm		;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac	;String

; External addresses outside, read from lst/nhl96.bin.
printz = $01BB8E		;video96
SeasonMenuScreen = $0122A4		;season96
forceblack = $01AF52		;video96
dobitmap = $01B692		;video96
DecompressGraphicsPlain = $01B730		;video96
FindHeldMenuPad = $01B282		;video96
setVram = $01B57E		;video96
eraser = $01B976		;video96
printsmallz = $01BA2E		;video96
printcur = $01BC84		;video96
RosterFont = $179168		;graphics96
TeamBlockPtrs = $012BFE		;teamgfx96
Vmaddr = $01B678		;video96
rtss2 = $01F84A		;collide96
PlayoffTreeMap = $1BDCD4		;graphics96
PlayoffTreeBgMap = $1C0302		;graphics96
PlayoffTeamFrameMap = $1C4810		;graphics96


; Main segment code
	include	engine\playoff96_tree.asm
