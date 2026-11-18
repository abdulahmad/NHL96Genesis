;	Segment build for engine\pause96_menu.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$015490

; includes for stubs to replace removed code
	include	stubinc\ports.inc		;IO_* / VDP_* ports
	include	stubinc\equals.inc		;VDP status bits
	include	ram96.asm				;RAM map
	include	externs96.asm			;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac		;String

; External addresses outside, read from lst/nhl96.bin.
ReadTeamStats = $0225E0				;playoff96
SeasonPlayoffStats = $1DB020		;season96_menu
PlayerStatsList = $1E55BC			;stats96_list
AddFramer = $01C184					;pause96_return_stub
DecompressGraphicsPlain = $01B730	;pause96_return_stub
forceblack = $01AF52				;pause96_stub
LoadCrowdFrames = $0210D0			;display96
LoadEnergyBarTiles = $0210C2		;display96
LoadHomeTeamGfx = $1D8E6C			;code96_15
LoadReplayIcon = $1D8E5C			;code96_15
LoadSmallFont = $0243A0				;pause96_return_stub
setplayercolors = $0215B2			;control96_team
setupEASNmap = $0210B0				;display96
setupIceRinkPal = $02109A			;display96
Vmaddr = $01B678					;season96_stub


; Main segment code
	include	engine\pause96_menu.asm
