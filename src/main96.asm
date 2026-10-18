;	Startup. This file holds the vector table and the cartridge header, runs Sega's startup code,
;	checks the region and the checksum, and then starts the game.
;
;	The region lock reads the country code as one hex digit of region bits (1 Japan, 2 Asia PAL, 4 USA,
;	8 Europe). If the console's region is not in it, it draws "DEVELOPED FOR USE ONLY WITH ... SYSTEMS."
;	and hangs.

InitialSP = $FFFFF6					;reset vector 0. 24-bit form of $FFFFFFF6. Begin moves the stack to Stack

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	Vectors
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

	dc.l	InitialSP				; 0 initial stack pointer
	dc.l	Start					; 1 initial program counter
	dc.l	AdrErr					; 2 bus error. Bus and address error share one handler
	dc.l	AdrErr					; 3 address error
	dc.l	InvOpCode				; 4 illegal instruction
	dc.l	DivBy0					; 5 zero divide
	dcb.b	72,$FF					; 6-23: CHK ... reserved, not used

	dc.l	IRQ7					; 24 spurious interrupt. IRQ7 is an rte
	dc.l	IRQ7					; 25 level 1, not used
	dc.l	IRQ7					; 26 level 2 (external), not used
	dc.l	IRQ7					; 27 level 3, not used
	dc.l	IRQ7					; 28 level 4: horizontal retrace (not used)
	dc.l	0						; 29 level 5: not used
	dc.l	VBjsr					; 30 level 6: vertical retrace, jumps through VBint
	dc.l	IRQ7					; 31 level 7

	dc.l	0,0,0,0					; 32-35: trap #0-#3, not used
	dcb.b	112,$FF					; 36-63: trap #4-#15 and reserved, not used

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	Cartridge header
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	include	sega\SegaIDTable96.asm

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	Start
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
Start								;Power on: the Sega hardware init, then the region lock, the checksum and
									;Begin
	include	sega\SegaInit.asm		;SegaInit, falls into CHECK_VDP

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	Region lock
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

CHECK_VDP							;Hot start lands here. Look the country code digit up in the table for the
									;console's region; 0 there means the cartridge is sold in this region, so
									;start the game
	tst.w	(Vctrl).l
	clr.l	d0
	move.b	(IO_PCBVER+1).l,d0		;version register: bit 7 = overseas, bit 6 = PAL
	lsr.b	#6,d0
	andi.b	#3,d0					;0 Japan NTSC, 1 Japan PAL, 2 overseas NTSC, 3 overseas PAL
	cmpi.b	#0,d0
	bne.s	.1
	lea	RegionJapanNtsc(pc),a6
	bra.s	.digit
.1	cmpi.b	#1,d0
	bne.s	.2
	lea	RegionJapanPal(pc),a6
	bra.s	.digit
.2	cmpi.b	#2,d0
	bne.s	.3
	lea	RegionOverseasNtsc(pc),a6
	bra.s	.digit
.3	cmpi.b	#3,d0
	bne.w	.regionHang
	lea	RegionOverseasPal(pc),a6
.digit								;country code letter to its hex value: '0'-'9' or 'A'-'F'
	clr.l	d6
	lea	(CountryCode).l,a0
	move.b	(a0),d6
	cmpi.b	#$40,d6
	blt.s	.num
	move.b	#'A'-10,d7
	sub.b	d7,d6
	bra.s	.look
.num	lsl.b	#4,d6
	lsr.b	#4,d6
.look	move.b	d6,d7				;keep the region bits for the message
	move.b	(a6,d6.w),d6
	tst.b	d6
	beq.w	RegionOK				;the cartridge lists this region: start the game wrong region: set the VDP
									;up and load RegionFont as tiles 0-$3A
	lea	(Vdata).l,a4
	lea	(Vctrl).l,a5
	move.w	#VDPR_MODE2+$64,(a5)	;reg 1: display on, vblank int, DMA off
	move.w	#VDPR_PLANEA+$30,(a5)	;reg 2: plane A at $C000
	move.w	#VDPR_MODE4+$81,(a5)	;reg 12: 40 cell mode
	move.w	#VDPR_AUTOINC+$02,(a5)	;reg 15: auto increment 2
	move.w	#VDPR_PLANESIZE+$01,(a5)	;reg 16: 64 x 32 cell planes
	move.l	#CRAM_W+(2<<16),(a5)	;cram write, address 2 (colour 1)
	move.w	#$EEE,(a4)				;colour 1 = white
	move.l	#VRAM_W,(a5)			;vram write, address 0
	lea	RegionFont(pc),a0
	move.w	#$3A,d0					;characters space to Z
	move.l	#$10000000,d2			;pixel mask: colour 1 in the nibble rol.l moves into place
.char
	move.w	#7,d6					;8 rows
.row
	move.b	(a0)+,d1				;1 bit per pixel, left pixel in bit 7
	move.l	#0,d4
	move.w	#7,d5					;8 pixels
.pixel
	rol.l	#4,d2
	ror.b	#1,d1
	bcc.s	.clear
	or.l	d2,d4					;set the pixel to colour 1
.clear
	dbf	d5,.pixel
	move.l	d4,(a4)					;one 4 bpp tile row
	dbf	d6,.row
	dbf	d0,.char
	;one line for each system the cartridge is sold for, by the country code digit
	cmpi.b	#1,d7
	bne.s	.d4
	bsr.w	PrintDeveloped
	bsr.w	PrintNtscMegaDrive
	bra.w	.systems
.d4	cmpi.b	#4,d7
	bne.s	.d5
	bsr.w	PrintDeveloped
	bsr.w	PrintNtscGenesis
	bra.w	.systems
.d5	cmpi.b	#5,d7
	bne.s	.dA
	bsr.w	PrintDeveloped
	bsr.w	PrintNtscGenesis
	bsr.w	PrintAnd
	bsr.w	PrintNtscMegaDrive
	bra.w	.systems
.dA	cmpi.b	#$A,d7
	bne.s	.dB
	bsr.w	PrintDeveloped
	bsr.w	PrintPalMegaDrive
	bra.w	.systems
.dB	cmpi.b	#$B,d7
	bne.s	.dC
	bsr.w	PrintDeveloped
	bsr.w	PrintNtscMegaDrive
	bsr.w	PrintAnd
	bsr.w	PrintPalMegaDrive
	bra.w	.systems
.dC	cmpi.b	#$C,d7
	bne.s	.dE
	bra.s	.uspal
.dE	cmpi.b	#$E,d7
	bne.s	.none
.uspal	bsr.w	PrintDeveloped
	bsr.w	PrintNtscGenesis
	bsr.w	PrintAnd
	bsr.w	PrintPalMegaDrive
	bra.w	.systems
.none	bra.s	.regionHang
.systems
	lea	SystemsTxt(pc),a0
	move.b	(a0)+,d0
	addq.w	#1,d1
	bsr.w	RegionPrint
.regionHang							;Wrong region: hang
	bra.s	.regionHang

PrintDeveloped						;"DEVELOPED FOR USE ONLY WITH" on row 8
	move.b	#8,d1
	lea	DevelopedTxt(pc),a0
	move.b	(a0)+,d0
	bsr.w	RegionPrint
	rts

PrintNtscMegaDrive					;"NTSC MEGA DRIVE" on the next row
	lea	NtscMegaDriveTxt(pc),a0
	move.b	(a0)+,d0
	addq.w	#1,d1
	bsr.w	RegionPrint
	rts

PrintNtscGenesis					;"NTSC GENESIS" on the next row
	lea	NtscGenesisTxt(pc),a0
	move.b	(a0)+,d0
	addq.w	#1,d1
	bsr.w	RegionPrint
	rts

PrintPalMegaDrive					;"PAL AND FRENCH SECAM MEGA DRIVE" on the next row
	lea	PalMegaDriveTxt(pc),a0
	move.b	(a0)+,d0
	addq.w	#1,d1
	bsr.w	RegionPrint
	rts

PrintAnd							;"&" on the next row
	lea	AndTxt(pc),a0
	move.b	(a0)+,d0
	addq.w	#1,d1
	bsr.w	RegionPrint
	rts

RegionPrint							;Print the 0 terminated text at a0 on plane A ($C000), row d1, column d0.
									;Tile = character - $20
	move.b	d1,d2
	andi.l	#$FF,d2
	swap	d2
	lsl.l	#7,d2					;row * $80, in the address half of the vram command
	move.b	d0,d3
	andi.l	#$FF,d3
	swap	d3
	asl.l	#1,d3					;column * 2
	add.l	d3,d2
	addi.l	#VRAM_W+(($C000&$3FFF)<<16)+($C000>>14),d2	;vram write at $C000 + row * $80 + column * 2
	move.l	d2,(a5)
.0
	tst.b	(a0)
	beq.s	.1
	move.b	(a0)+,d2
	subi.b	#$20,d2
	andi.w	#$FF,d2
	move.w	d2,(a4)
	bra.s	.0
.1
	rts

;One table for each console region, indexed by the country code digit: 0 = sold there, 1 = not
RegionJapanNtsc
	dc.b	1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0
RegionJapanPal
	dc.b	1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0
RegionOverseasNtsc
	dc.b	1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0
RegionOverseasPal
	dc.b	1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0
;region lock text: column, then the characters, 0 terminated
DevelopedTxt
	dc.b	6,'DEVELOPED FOR USE ONLY WITH',0
AndTxt
	dc.b	$12,'&',0
SystemsTxt
	dc.b	$F,'SYSTEMS.',0
NtscMegaDriveTxt
	dc.b	$C,'NTSC MEGA DRIVE',0
NtscGenesisTxt
	dc.b	$D,'NTSC GENESIS',0
PalMegaDriveTxt
	dc.b	4,'PAL AND FRENCH SECAM MEGA DRIVE',0
RegionFont							;8 x 8, 1 bit per pixel, characters $20-$5A
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00	;' '
	dc.b	$18,$18,$18,$18,$00,$18,$18,$00	;'!'
	dc.b	$36,$36,$48,$00,$00,$00,$00,$00	;'"'
	dc.b	$12,$12,$7F,$12,$7F,$24,$24,$00	;'#'
	dc.b	$08,$3F,$48,$3E,$09,$7E,$08,$00	;'$'
	dc.b	$71,$52,$74,$08,$17,$25,$47,$00	;'%'
	dc.b	$18,$24,$18,$29,$45,$46,$39,$00	;'&'
	dc.b	$30,$30,$40,$00,$00,$00,$00,$00	;''''
	dc.b	$0C,$10,$20,$20,$20,$10,$0C,$00	;'('
	dc.b	$30,$08,$04,$04,$04,$08,$30,$00	;')'
	dc.b	$00,$08,$2A,$1C,$2A,$08,$00,$00	;'*'
	dc.b	$08,$08,$08,$7F,$08,$08,$08,$00	;'+'
	dc.b	$00,$00,$00,$00,$00,$30,$30,$40	;','
	dc.b	$00,$00,$00,$7F,$00,$00,$00,$00	;'-'
	dc.b	$00,$00,$00,$00,$00,$30,$30,$00	;'.'
	dc.b	$01,$02,$04,$08,$10,$20,$40,$00	;'/'
	dc.b	$1E,$33,$33,$33,$33,$33,$1E,$00	;'0'
	dc.b	$18,$38,$18,$18,$18,$18,$3C,$00	;'1'
	dc.b	$3E,$63,$63,$0E,$38,$60,$7F,$00	;'2'
	dc.b	$3E,$63,$03,$1E,$03,$63,$3E,$00	;'3'
	dc.b	$06,$0E,$1E,$36,$66,$7F,$06,$00	;'4'
	dc.b	$7E,$60,$7E,$63,$03,$63,$3E,$00	;'5'
	dc.b	$3E,$63,$60,$7E,$63,$63,$3E,$00	;'6'
	dc.b	$3F,$63,$06,$06,$0C,$0C,$18,$00	;'7'
	dc.b	$3E,$63,$63,$3E,$63,$63,$3E,$00	;'8'
	dc.b	$3E,$63,$63,$3F,$03,$63,$3E,$00	;'9'
	dc.b	$00,$18,$18,$00,$00,$18,$18,$00	;':'
	dc.b	$00,$18,$18,$00,$00,$18,$18,$20	;';'
	dc.b	$03,$0C,$30,$40,$30,$0C,$03,$00	;'<'
	dc.b	$00,$00,$7F,$00,$7F,$00,$00,$00	;'='
	dc.b	$60,$18,$06,$01,$06,$18,$60,$00	;'>'
	dc.b	$3E,$63,$03,$1E,$18,$00,$18,$00	;'?'
	dc.b	$3C,$42,$39,$49,$49,$49,$36,$00	;'@'
	dc.b	$1C,$1C,$36,$36,$7F,$63,$63,$00	;'A'
	dc.b	$7E,$63,$63,$7E,$63,$63,$7E,$00	;'B'
	dc.b	$3E,$73,$60,$60,$60,$73,$3E,$00	;'C'
	dc.b	$7E,$63,$63,$63,$63,$63,$7E,$00	;'D'
	dc.b	$3F,$30,$30,$3E,$30,$30,$3F,$00	;'E'
	dc.b	$3F,$30,$30,$3E,$30,$30,$30,$00	;'F'
	dc.b	$3E,$73,$60,$67,$63,$73,$3E,$00	;'G'
	dc.b	$66,$66,$66,$7E,$66,$66,$66,$00	;'H'
	dc.b	$18,$18,$18,$18,$18,$18,$18,$00	;'I'
	dc.b	$0C,$0C,$0C,$0C,$CC,$CC,$78,$00	;'J'
	dc.b	$63,$66,$6C,$78,$6C,$66,$63,$00	;'K'
	dc.b	$60,$60,$60,$60,$60,$60,$7F,$00	;'L'
	dc.b	$63,$77,$7F,$6B,$6B,$63,$63,$00	;'M'
	dc.b	$63,$73,$7B,$7F,$6F,$67,$63,$00	;'N'
	dc.b	$3E,$63,$63,$63,$63,$63,$3E,$00	;'O'
	dc.b	$7E,$63,$63,$7E,$60,$60,$60,$00	;'P'
	dc.b	$3E,$63,$63,$63,$6F,$63,$3F,$00	;'Q'
	dc.b	$7E,$63,$63,$7E,$68,$66,$67,$00	;'R'
	dc.b	$3E,$63,$70,$3E,$07,$63,$3E,$00	;'S'
	dc.b	$7E,$18,$18,$18,$18,$18,$18,$00	;'T'
	dc.b	$66,$66,$66,$66,$66,$66,$3C,$00	;'U'
	dc.b	$63,$63,$63,$36,$36,$1C,$1C,$00	;'V'
	dc.b	$6B,$6B,$6B,$6B,$6B,$7F,$36,$00	;'W'
	dc.b	$63,$63,$36,$1C,$36,$63,$63,$00	;'X'
	dc.b	$66,$66,$66,$3C,$18,$18,$18,$00	;'Y'
	dc.b	$7F,$07,$0E,$1C,$38,$70,$7F,$00	;'Z'

RegionOK							;The region is listed: checksum, then the game
	IF CHECKSUM=1
		jsr	(ValidationRoutine).l	;Red screen and hang if the ROM sum is wrong
	ELSE
		nop
		nop
		nop
	ENDIF
	jmp	(Begin).l

ZeroLong							;A zero long
	dc.l	0
