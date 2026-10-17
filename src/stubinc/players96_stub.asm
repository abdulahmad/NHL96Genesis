;	Segment build for engine\players96.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$01FB52

; includes for stubs to replace removed code
	include	stubinc\ports.inc		;IO_* / VDP_* ports
	include	stubinc\equals.inc		;VDP status bits
	include	ram96.asm				;RAM map
	include	externs96.asm			;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac		;String

; External addresses outside, read from lst/nhl96.bin.
assinsert = $01A3D0					;logic96_vec
assreplace = $01A3DA				;logic96_vec
rtss2 = $01F84A						;collide96
priolist = $023426					;players96_sub
GetRosterName = $0101E6				;trade96
GetJerseyNumber = $0102B8			;trade96
GetPeriodTime = $0148A2				;hockey96
GetPlayerCount = $0157F4			;players96_count
chkpk2 = $018410					;logic96_puck
sublist = $0233BC					;players96_sub
AttributeCalc = $1D6F66				;code96_14
SetSeasonInjuries = $1E8840			;injury96


; Main segment code
	include	engine\players96.asm
