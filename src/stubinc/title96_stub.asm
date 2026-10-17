;	Segment build for front\title96.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$1E889C

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	ram96.asm		;RAM map
	include	externs96.asm		;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac	;String

; External addresses outside, read from lst/nhl96.bin.
printz = $01BB8E		;video96
forceblack = $01AF52		;video96
setVram_0 = $01B594		;video96
dobitmap = $01B692		;video96
DecompressGraphicsPlain = $01B730		;video96
VBlank_Menus = $012D46		;teamgfx96
FindHeldMenuPad = $01B282		;video96
setVram = $01B57E		;video96
eraser = $01B976		;video96
printsmallz = $01BA2E		;video96
RosterFont = $179168		;graphics96
DoFill = $01B52E		;video96
VBlank = $0201DC		;display96
setupIceRinkPal = $02109A		;display96
Z80Program = $025500		;sound96
SoundBanks = $027026		;sound96
SoundCmd = $08839E		;sound96
Rinktilelist = $0923E4		;graphics96
randomd0 = $01B0A6		;video96
printsmall = $01BA40		;video96
updatescroll = $0203BC		;display96
KillCrowd = $020E28		;display96
updatesound = $0883D4		;sound96
sfx = $088470		;sound96
song = $088586		;sound96
SoundOff = $088676		;sound96
TitleScreenImg = $088A18		;scout96
NHLShieldMap = $08F2C6		;graphics96
NHLPALogoMap = $090686		;graphics96
CreditsBgMap = $0911B8		;graphics96
unk_1CCEE8 = $1CCEE8		;graphics96
unk_1D5420 = $1D5420		;graphics96


; Main segment code
	include	front\title96.asm
