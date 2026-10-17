;	The player stats list for one team, this game or the playoffs.

PlayerStatsScreen	;Pause menu Player Stats: PlayerStatsList with d7 = 0 (this game)
	;Code the listing does not decode: kept as bytes
	dc.b	$42,$47

PlayerStatsList	;Stats screen for team a2, d7 = 0 game / 1 playoff (plistplayoff): skaters or goalies sorted by
	;category DispAttribCtr; up / down scroll, left / right category, A the other team (game stats), B skaters / goalies
	move.w	d7,(plistplayoff).w
	movem.l	d0-d7/a0-a6,-(sp)
	clr.w	(carddelay).w
	clr.w	(DispAttribCtr).w
	move.w	$28(a2),(setupvalues+2).w
	bsr.w	PListSetup
	movea.l	#PlayerStatsSprites,a0
	jsr	(DrawScreenSprite).l
	move.w	#$18,(palcount).w
	bclr	#2,(disflags).w
	clr.w	(VertLineScrolling).w
	move.w	#$D,(word_FFD036).w
	move.w	#$C,(PlayerScrollCtr).w
	clr.w	(DispAttribCtr).w
.0
	move.w	(setupvalues+2).w,d7
	tst.w	(plistplayoff).w
	bne.w	.1
	cmpi.w	#5,(DispAttribCtr).w
	blt.w	.3
	bra.w	.2
.1
	cmpi.w	#4,(DispAttribCtr).w
	blt.w	.3
.2
	jsr	(GetGoalieCountD7).l
	subq.w	#1,d0
	move.w	d0,(word_FFD038).w
	bra.w	.draw
.3
	jsr	(GetGoalieCountD7).l
	move.w	d0,-(sp)
	jsr	(GetPlayerCountD7).l
	sub.w	(sp)+,d0
	subq.w	#1,d0
	move.w	d0,(word_FFD038).w
.draw
	bsr.w	PListBuild
	move.w	(vcount).w,d0
.loop2
	cmp.w	(vcount).w,d0
	beq.s	.loop2
	jsr	(PStatsClearList).l
.5
	move.w	(vcount).w,d0
.6
	cmp.w	(vcount).w,d0
	beq.s	.6
	jsr	(SetMenuScroll).l
	bsr.w	PListCategory
	bsr.w	PListTeamBlock
	bsr.w	PListHelp
	bsr.w	PListHeading
	move	#$2500,sr
	move.w	(vcount).w,d0
.7
	cmp.w	(vcount).w,d0
	beq.s	.7
	jsr	(SetMenuScroll).l
	bset	#2,(disflags).w
	bsr.w	PListPrint
	bsr.w	PListArrows
	move	#$2500,sr
	bclr	#2,(disflags).w
.input
	bsr.w	ReadAnyPad
	tst.w	d1
	beq.w	.22
	btst	#7,d1
	bne.w	.23
	btst	#2,d1
	beq.w	.right
	tst.w	(plistplayoff).w
	bne.w	.8
	cmpi.w	#5,(DispAttribCtr).w
	blt.w	.9
	subq.w	#1,(DispAttribCtr).w
	cmpi.w	#5,(DispAttribCtr).w
	bge.w	.11
	move.w	#7,(DispAttribCtr).w
	bra.w	.11
.8
	cmpi.w	#4,(DispAttribCtr).w
	blt.w	.10
	subq.w	#1,(DispAttribCtr).w
	cmpi.w	#4,(DispAttribCtr).w
	bge.w	.11
	move.w	#6,(DispAttribCtr).w
	bra.w	.11
.9
	subq.w	#1,(DispAttribCtr).w
	bpl.w	.11
	move.w	#4,(DispAttribCtr).w
	bra.w	.11
.10
	subq.w	#1,(DispAttribCtr).w
	bpl.w	.11
	move.w	#3,(DispAttribCtr).w
.11
	clr.w	(VertLineScrolling).w
	move.w	#$C,(PlayerScrollCtr).w
	bra.w	.0
.right
	btst	#0,d1
	beq.w	.13	;branch if not
	tst.w	(VertLineScrolling).w
	beq.w	.input
	subq.w	#1,(VertLineScrolling).w
	subq.w	#1,(PlayerScrollCtr).w
	bra.w	.5
.13
	btst	#1,d1
	beq.w	.12
	move.w	(PlayerScrollCtr).w,d0
	cmp.w	(word_FFD038).w,d0
	bge.w	.input
	addq.w	#1,(VertLineScrolling).w
	addq.w	#1,(PlayerScrollCtr).w	;next lower item
	bra.w	.5
.12
	btst	#6,d1
	beq.w	.16
	tst.w	(plistplayoff).w
	bne.w	.16
	cmpa.l	#tmstruct,a2
	beq.w	.14
	movea.l	#tmstruct,a2
	bra.w	.15
.14
	movea.l	#AwShots,a2
.15
	move.w	$28(a2),(setupvalues+2).w
	bra.w	.0
.16
	btst	#4,d1
	beq.w	.4
	tst.w	(plistplayoff).w
	bne.w	.17
	cmpi.w	#5,(DispAttribCtr).w
	blt.w	.18
	clr.w	(DispAttribCtr).w
	bra.w	.0
.17
	cmpi.w	#4,(DispAttribCtr).w
	blt.w	.oneside
	clr.w	(DispAttribCtr).w
	bra.w	.0
.oneside
	move.w	#4,(DispAttribCtr).w
	bra.w	.0
.18
	move.w	#5,(DispAttribCtr).w
	bra.w	.0
.4
	btst	#3,d1	;dbut
	beq.w	.input
	addq.w	#1,(DispAttribCtr).w	;next lower item
	tst.w	(plistplayoff).w
	bne.w	.20
	cmpi.w	#5,(DispAttribCtr).w
	blt.w	.11
	bgt.w	.19
	clr.w	(DispAttribCtr).w
	bra.w	.11
.19
	cmpi.w	#7,(DispAttribCtr).w
	ble.w	.11
	move.w	#5,(DispAttribCtr).w
	bra.w	.11
.20
	cmpi.w	#4,(DispAttribCtr).w
	blt.w	.11
	bgt.w	.21
	clr.w	(DispAttribCtr).w
	bra.w	.11
.21
	cmpi.w	#6,(DispAttribCtr).w
	ble.w	.11
	move.w	#4,(DispAttribCtr).w
	bra.w	.11
.22
	jmp	Opening2
.23
	move.l	#SeasonMenuScreen,(NextScreenPtr).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts

ReadAnyPad	;Wait for a press on pad 1 or 2 (3 and 4 with FourWayPlay); d1 = the buttons
	move.l	#$5460,d6
.wait
	move.w	#$64,d6
	move.w	(vcount).w,d1
	sub.w	(oldvcount).w,d1
	beq.s	.wait
	move.w	(vcount).w,(oldvcount).w
	jsr	(SetMenuScroll).l
	jsr	(ReadJoy1).l
	jsr	(ProcessInputWithRepeat).l
	tst.w	d1
	beq.w	.1
	bra.w	.exit
.1
	jsr	(ReadJoy2).l
	jsr	(ProcessInputWithRepeat).l
	tst.w	d1
	beq.w	.2
	bra.w	.exit
.2
	tst.w	(FourWayPlay).w
	beq.w	.4
	jsr	(ReadJoy3).l
	jsr	(ProcessInputWithRepeat).l
	tst.w	d1
	beq.w	.3
	bra.w	.exit
.3
	jsr	(ReadJoy4).l
	jsr	(ProcessInputWithRepeat).l
	tst.w	d1
	beq.w	.4
	bra.w	.exit
.4
	dbf	d6,.wait
.exit
	rts

PListArrows	;PlayerStatsList: the scroll marks { (VertLineScrolling above 0) and } (more rows below)
	movem.l	d0-d7/a0-a6,-(sp)
	tst.w	(VertLineScrolling).w
	beq.w	.0
	jsr	(printcurz).l
	String	$8F,$02,$0B,$7B
	bra.w	.1
.0
	jsr	(printcurz).l
	String	$8F,$02,$0B,$20
.1
	move.w	(PlayerScrollCtr).w,d1
	cmp.w	(word_FFD038).w,d1
	bge.w	.2
	jsr	(printcurz).l
	String	$8F,$02,$17,$7D
	bra.w	.3
.2
	jsr	(printcurz).l
	String	$8F,$02,$17,$20
.3
	movem.l	(sp)+,d0-d7/a0-a6
	rts

PListSetup	;PlayerStatsList: vram, fonts and the screen bitmaps
	move.l	a2,-(sp)
	bset	#5,(sflags12).w
	move.l	#VBlank_Menus,(vbint).w
	bclr	#0,(disflags).w
	bset	#2,(disflags).w
	bclr	#1,(disflags).w
	move.w	#0,(VSCRLPM).w
	move.w	#$B400,(VSPRITES).w
	move.w	#$B800,(VmMap3).w
	move.w	#5,(Map3col1).w
	move.w	#$C000,(VmMap2).w
	move.w	#6,(Map2col1).w
	move.w	#$E000,(VmMap1).w
	move.w	#6,(Map1col1).w
	move.w	#0,d0
	bset	#5,(disflags).w
	jsr	(setVram).l
	bclr	#5,(disflags).w
	jsr	(orjoy).l
	move.w	#1,d4
	movea.l	#PlayerStatsSprites,a1
	jsr	(LoadScreenSprite).l
	move.w	d4,(smallfontchars).w
	movea.l	#RosterFont+8,a2
	jsr	(DecompressGraphicsPlain).l
	move.w	d4,(smallfont2chars).w
	movea.l	#SmallFontMap2+8,a2
	jsr	(DecompressGraphicsPlain).l
	move.l	#RosterFont,(smallfontptr).w
	move.w	d4,(BigFontChars).w
	movea.l	#BigFontMap4+8,a2
	jsr	(DecompressGraphicsPlain).l
	bset	#2,(sflags11).w
	move.w	d4,(setupvalues).w
	addi.w	#$20,d4
	jsr	(printsmallz).l
	String	$FF,$01,$FD,$00,$FC
	moveq	#$28,d0
	moveq	#$1C,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	jsr	(printz).l
	String	$BF,$00,$00
	movea.l	#PlayerStatsBgMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	moveq	#$28,d2
	moveq	#$1C,d3
	moveq	#8,d5
	jsr	(dobitmap).l
	jsr	(printz).l
	String	$BF,$0B,$01
	movea.l	#PlayerStatsTitleMap,a0
	tst.w	(plistplayoff).w
	beq.w	.0
	movea.l	#PlayoffStatsTitleMap,a0
.0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	move.w	(a1),d2
	move.w	2(a1),d3
	moveq	#8,d5
	jsr	(dobitmap).l
	jsr	(PListHelp).l
	jsr	(printz).l
	String	$FE,$00,$00
	movea.l	#IceBgMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	moveq	#$40,d2
	moveq	#$1C,d3
	moveq	#1,d5
	jsr	(dobitmap).l
	bsr.w	PListHeading
	bsr.w	PListCategory
	bsr.w	PListTeamBlock
	jsr	(PStatsPalette).l
	move	#$2500,sr
	movea.l	(sp)+,a2
	rts

PListTeamBlock	;PlayerStatsList: the team block of the shown team (DrawSetupTeamBlock), then PListHeading
	move.w	d7,-(sp)
	jsr	(printz).l
	String	$BF,$01,$05
	move.w	(setupvalues).w,d4
	move.w	(setupvalues+2).w,d7
	jsr	(DrawSetupTeamBlock).l
	move.w	(sp)+,d7

PListHeading	;PlayerStatsList: the column heading, players or goalies
	tst.w	(plistplayoff).w
	bne.w	.1
	cmpi.w	#5,(DispAttribCtr).w
	bge.w	.0
	jsr	(printbigz).l
	String	$F8,$04,$01,$04,$08,'#  PLAYER     g   a   p  sh   pim'
	bra.w	.3
.0
	jsr	(printbigz).l
	String	$F8,$04,$01,$04,$08,'#  GOALIE        s     sh    sp  '
.1
	cmpi.w	#4,(DispAttribCtr).w
	bge.w	.2
	jsr	(printbigz).l
	String	$F8,$04,$01,$04,$08,'#  PLAYER         g   a   p   pim'
	bra.w	.3
.2
	jsr	(printbigz).l
	String	$F8,$04,$01,$04,$08,'#  GOALIE        s     sh    sp  '
.3
	rts

PListHelp	;PlayerStatsList: the button help lines
	tst.w	(plistplayoff).w
	bne.w	.0
	cmpi.w	#5,(DispAttribCtr).w
	bge.w	.4
	bra.w	.1
.0
	cmpi.w	#4,(DispAttribCtr).w
	bge.w	.4
.1
	move.w	(smallfontchars).w,-(sp)
	move.w	(smallfont2chars).w,(smallfontchars).w
	tst.w	(plistplayoff).w
	beq.w	.2
	jsr	(printcurz).l
	String	$8F,$04,$19,'{}-SCROLL LIST            ',$8F,$04,$1A,'[]-CATEGORY      B-GOALIES'
	bra.w	.3
.2
	jsr	(printcurz).l
	String	$8F,$04,$19,'{}-SCROLL LIST   A-TEAMS  ',$8F,$04,$1A,'[]-CATEGORY      B-GOALIES'
.3
	move.w	(sp)+,(smallfontchars).w
	bra.w	.6
.4
	move.w	(smallfontchars).w,-(sp)
	move.w	(smallfont2chars).w,(smallfontchars).w
	tst.w	(plistplayoff).w
	beq.w	.5
	jsr	(printcurz).l
	String	$8F,$04,$19,'{}-SCROLL LIST            ',$8F,$04,$1A,'[]-CATEGORY      B-PLAYERS'
	move.w	(sp)+,(smallfontchars).w
	bra.w	.6
.5
	jsr	(printcurz).l
	String	$8F,$04,$19,'{}-SCROLL LIST   A-TEAMS  ',$8F,$04,$1A,'[]-CATEGORY      B-PLAYERS'
	move.w	(sp)+,(smallfontchars).w
.6
	rts

PListCategory	;PlayerStatsList: the name of category DispAttribCtr (PListPlayoffCats or PListGameCats)
	jsr	(printz).l
	String	$BF,$15,$05
	movea.l	#PListPlayoffCats,a1
	tst.w	(plistplayoff).w
	bne.w	.0
	movea.l	#PListGameCats,a1
.0
	move.w	(DispAttribCtr).w,d0
	jsr	(SkipStrings).l
	jsr	(printbig).l
	rts

PListPlayoffCats	;PListCategory: the playoff categories
	String	'     goals     '
	String	'    assists    '
	String	'     points    '
	String	'penalty minutes'
	String	'     saves     '
	String	'     shots     '
	String	'save percentage'

PListGameCats	;PListCategory: the game categories
	String	'     goals     '
	String	'    assists    '
	String	'     points    '
	String	'     shots     '
	String	'penalty minutes'
	String	'     saves     '
	String	'     shots     '
	String	'save percentage'

PListBuild	;PlayerStatsList: the player or goalie list of the shown team with its stat columns (PListColumns)
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(setupvalues+2).w,d7
	tst.w	(plistplayoff).w
	bne.w	.0
	cmpi.w	#5,(DispAttribCtr).w
	bge.w	.13
	bra.w	.1
.0
	cmpi.w	#4,(DispAttribCtr).w
	bge.w	.13
.1
	jsr	(GetPlayerCountD7).l
	move.w	d0,-(sp)
	jsr	(GetGoalieCountD7).l
	move.w	d0,(SRAMChecksum).w
	add.w	d0,(SRAMChecksum).w
	move.w	d0,d1
	adda.w	d1,a2
	sub.w	(sp)+,d0
	neg.w	d0
	move.w	d0,(screentimer).w
	movea.l	#$FFFFD040,a0
	bra.w	.3
.2
	move.w	d1,(a0)+
	addq.w	#1,d1
.3
	dbf	d0,.2
	move.w	(screentimer).w,d3
	movea.l	#$FFFFD078,a0
	tst.w	(plistplayoff).w
	beq.w	.4
	move.l	a2,-(sp)
	movea.l	#$FFFFCE62,a2
	move.w	(SRAMChecksum).w,d2
	bsr.w	PListWords
	movea.l	(sp)+,a2
	bra.w	.5
.4
	move.w	#$C0,d2
	bsr.w	PListBytes
.5
	move.w	(screentimer).w,d3
	movea.l	#$FFFFD0B0,a0
	tst.w	(plistplayoff).w
	beq.w	.6
	move.l	a2,-(sp)
	movea.l	#$FFFFCE9A,a2
	move.w	(SRAMChecksum).w,d2
	bsr.w	PListWords
	movea.l	(sp)+,a2
	bra.w	.7
.6
	move.w	#$DC,d2
	bsr.w	PListBytes
.7
	move.l	a2,-(sp)
	movea.l	#$FFFFD078,a1
	movea.l	#$FFFFD0B0,a2
	movea.l	#$FFFFD0E8,a0
	move.w	(screentimer).w,d3
	bra.w	.9
.8
	move.w	(a1)+,d0
	add.w	(a2)+,d0
	move.w	d0,(a0)+
.9
	dbf	d3,.8
	movea.l	(sp)+,a2
	tst.w	(plistplayoff).w
	bne.w	.10
	movea.l	#$FFFFD120,a0
	move.w	(screentimer).w,d3
	move.w	#$F8,d2
	bsr.w	PListBytes
	movea.l	#$FFFFD158,a0
	move.w	(screentimer).w,d3
	move.w	#$114,d2
	bsr.w	PListBytes
	bra.w	.26
.10
	movea.l	#$FFFFD120,a0
	move.w	(screentimer).w,d3
	tst.w	(plistplayoff).w
	beq.w	.11
	move.l	a2,-(sp)
	movea.l	#$FFFFCF0A,a2
	move.w	(SRAMChecksum).w,d2
	bsr.w	PListWords
	movea.l	(sp)+,a2
	bra.w	.12
.11
	move.w	#$114,d2
	bsr.w	PListBytes
.12
	bra.w	.26
.13
	jsr	(GetGoalieCountD7).l
	move.w	d0,(screentimer).w
	movea.l	#$FFFFD040,a0
	clr.w	d1
	bra.w	.15
.14
	move.w	d1,(a0)+
	addq.w	#1,d1
.15
	dbf	d0,.14
	movea.l	#$FFFFD158,a0
	tst.w	(plistplayoff).w
	bne.w	.16
	movea.l	#$FFFFD190,a0
.16
	move.w	(screentimer).w,d3
	tst.w	(plistplayoff).w
	beq.w	.17
	move.l	a2,-(sp)
	movea.l	#$FFFFCE62,a2
	clr.w	d2
	bsr.w	PListWords
	movea.l	(sp)+,a2
	bra.w	.18
.17
	move.w	#$C0,d2
	bsr.w	PListBytes
.18
	movea.l	#$FFFFD190,a0
	tst.w	(plistplayoff).w
	bne.w	.19
	movea.l	#$FFFFD1C8,a0
.19
	move.w	(screentimer).w,d3
	tst.w	(plistplayoff).w
	beq.w	.20
	move.l	a2,-(sp)
	movea.l	#$FFFFCED2,a2
	clr.w	d2
	bsr.w	PListWords
	movea.l	(sp)+,a2
	bra.w	.21
.20
	move.w	#$F8,d2
	bsr.w	PListBytes
.21
	movea.l	#$FFFFD158,a0
	movea.l	#$FFFFD190,a1
	movea.l	#$FFFFD1C8,a2
	tst.w	(plistplayoff).w
	bne.w	.22
	movea.l	#$FFFFD190,a0
	movea.l	#$FFFFD1C8,a1
	movea.l	#$FFFFD200,a2
.22
	move.w	(screentimer).w,d3
	bra.w	.25
.23
	move.w	(a1)+,d0
	sub.w	(a0),d0
	move.w	d0,(a0)+
	move.w	-2(a1),d1
	beq.w	.24
	mulu.w	#$64,d0
	divu.w	d1,d0
.24
	move.w	d0,(a2)+
.25
	dbf	d3,.23
.26
	movea.l	#PListColumns,a0
	move.w	(DispAttribCtr).w,d0
	asl.w	#2,d0
	movea.l	(a0,d0.w),a0
	movea.l	#$FFFFD040,a1
	move.w	(a1),d0
	add.w	d0,d0
	suba.w	d0,a0
.27
	clr.w	(TempWord1).w
	clr.w	d0
	move.w	(screentimer).w,d5
	subq.w	#2,d5
.28
	move.w	d0,d1
	add.w	d1,d1
	move.w	(a1,d1.w),d2
	move.w	2(a1,d1.w),d3
	add.w	d2,d2
	add.w	d3,d3
	move.w	(a0,d2.w),d4
	cmp.w	(a0,d3.w),d4
	bge.w	.29
	st	(TempWord1).w
	move.w	(a1,d1.w),d2
	move.w	2(a1,d1.w),d3
	move.w	d2,2(a1,d1.w)
	move.w	d3,(a1,d1.w)
.29
	addq.w	#1,d0
	dbf	d5,.28
	tst.w	(TempWord1).w
	bne.s	.27
	movem.l	(sp)+,d0-d7/a0-a6
	rts

PListBytes	;d3 stat bytes of team a2 from offset d2 as words at a0
	move.l	a2,-(sp)
	subq.w	#1,d3
	clr.w	d4
.0
	move.b	(a2,d2.w),d4
	addq.w	#1,a2
	move.w	d4,(a0)+
	dbf	d3,.0
	movea.l	(sp)+,a2
	rts

PListWords	;d3 stat words of a2 from offset d2 to a0
	move.l	a2,-(sp)
	subq.w	#1,d3
	clr.w	d4
.0
	move.w	(a2,d2.w),d4
	addq.w	#2,a2
	move.w	d4,(a0)+
	dbf	d3,.0
	movea.l	(sp)+,a2
	rts

PListColumns	;PlayerStatsList: the stat column buffers
	dc.l	$FFFFD078,$FFFFD0B0,$FFFFD0E8,$FFFFD120,$FFFFD158,$FFFFD190,$FFFFD1C8,$FFFFD200

PListPrint	;PlayerStatsList: print the rows of the list
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(printz).l
	String	$8F,$00,$00
	clr.w	d6
	move.w	#$B,(printy).w
.0
	clr.w	(word_FFD238).w
	tst.w	(plistplayoff).w
	bne.w	.1
	cmpi.w	#5,(DispAttribCtr).w
	blt.w	.2
	move.w	#5,(word_FFD238).w
	bra.w	.2
.1
	cmpi.w	#4,(DispAttribCtr).w
	blt.w	.2
	move.w	#4,(word_FFD238).w
.2
	movea.l	#PListColumns,a5
	move.w	(word_FFD238).w,d0
	asl.w	#2,d0
	movea.l	(a5,d0.w),a5
	move.w	#4,(printx).w
	movea.l	#BlankStatsRow,a1
	jsr	(printcur).l
	move.w	d6,d0
	add.w	(VertLineScrolling).w,d0
	cmp.w	(screentimer).w,d0
	blt.w	.3
	move.w	d6,d0
	add.w	(VertLineScrolling).w,d0
	cmp.w	(word_FFD038).w,d0
	bge.w	.20
	move.w	d0,(word_FFD038).w
	bra.w	.20
.3
	move.w	#4,(printx).w
	movea.l	#setupvalues+4,a0
	move.w	d6,d0
	add.w	(VertLineScrolling).w,d0
	add.w	d0,d0
	move.w	(a0,d0.w),d0
	ext.l	d0
	move.w	d0,-(sp)
	move.w	(setupvalues+2).w,d7
	btst	#2,(SeasonFlags).w
	beq.w	*+4
.4
	jsr	(FormatPlayerNameD7).l
	jsr	(printcur).l
	tst.w	(plistplayoff).w
	bne.w	.5
	cmpi.w	#5,(DispAttribCtr).w
	bge.w	.8
	bra.w	.6
.5
	cmpi.w	#4,(DispAttribCtr).w
	bge.w	.8
.6
	move.w	(setupvalues+2).w,d7
	btst	#2,(SeasonFlags).w
	beq.w	*+4
.7
	jsr	(GetGoalieCountD7).l
	sub.w	d0,(sp)
.8
	move.w	#$11,(printx).w
	tst.w	(plistplayoff).w
	bne.w	.9
	cmpi.w	#5,(DispAttribCtr).w
	blt.w	.10
	move.w	#$14,(printx).w
	bra.w	.10
.9
	move.w	#$15,(printx).w
	cmpi.w	#4,(DispAttribCtr).w
	blt.w	.10
	move.w	#$14,(printx).w
.10
	move.w	(sp),d0
	bsr.w	PListValue
	beq.w	.19
	move.w	#$15,(printx).w
	tst.w	(plistplayoff).w
	bne.w	.11
	cmpi.w	#5,(DispAttribCtr).w
	blt.w	.12
	move.w	#$1A,(printx).w
	bra.w	.12
.11
	move.w	#$19,(printx).w
	cmpi.w	#4,(DispAttribCtr).w
	blt.w	.12
	move.w	#$1A,(printx).w
.12
	move.w	(sp),d0
	bsr.w	PListValue
	beq.w	.19
	move.w	#$19,(printx).w
	tst.w	(plistplayoff).w
	bne.w	.13
	cmpi.w	#5,(DispAttribCtr).w
	blt.w	.14
	move.w	#$20,(printx).w
	bra.w	.14
.13
	move.w	#$1D,(printx).w
	cmpi.w	#4,(DispAttribCtr).w
	blt.w	.14
	move.w	#$20,(printx).w
.14
	move.w	(sp),d0
	bsr.w	PListValue
	beq.w	.19
	move.w	#$1D,(printx).w
	tst.w	(plistplayoff).w
	bne.w	.15
	cmpi.w	#5,(DispAttribCtr).w
	blt.w	.16
	move.w	#0,(printx).w
	bra.w	.16
.15
	move.w	#$21,(printx).w
	cmpi.w	#4,(DispAttribCtr).w
	blt.w	.16
	move.w	#0,(printx).w
.16
	move.w	(sp),d0
	bsr.w	PListValue
	tst.w	(plistplayoff).w
	bne.w	.19
	move.w	#$21,(printx).w
	tst.w	(plistplayoff).w
	bne.w	.17
	cmpi.w	#5,(DispAttribCtr).w
	blt.w	.18
	move.w	#0,(printx).w
	bra.w	.18
.17
	cmpi.w	#4,(DispAttribCtr).w
	blt.w	.18
	move.w	#0,(printx).w
.18
	move.w	(sp),d0
	bsr.w	PListValue
.19
	tst.w	(sp)+
.20
	addq.w	#1,(printy).w
	addq.w	#1,d6
	cmp.w	(word_FFD036).w,d6
	blt.w	.0
	movem.l	(sp)+,d0-d7/a0-a6
	rts

PListValue	;PlayerStatsList: print stat column word_FFD238 of row d0
	move.w	d0,-(sp)
	move.w	(word_FFD238).w,d0
	asl.w	#2,d0
	movea.l	#PListColumns,a0
	movea.l	(a0,d0.w),a0
	move.w	(sp)+,d0
	add.w	d0,d0
	move.w	(a0,d0.w),d0
	move.w	#3,d1
	tst.w	(plistplayoff).w
	bne.w	.0
	cmpi.w	#5,(word_FFD238).w
	blt.w	.2
	cmpi.w	#7,(word_FFD238).w
	beq.w	.2
	bra.w	.1
.0
	cmpi.w	#4,(word_FFD238).w
	blt.w	.2
	cmpi.w	#6,(word_FFD238).w
	beq.w	.2
.1
	move.w	#4,d1
.2
	jsr	(PushNumberWidth).l
	bsr.w	PListMark
	addq.w	#1,(word_FFD238).w
	tst.w	(plistplayoff).w
	bne.w	.3
	cmpi.w	#5,(word_FFD238).w
	beq.w	.4
	cmpi.w	#8,(word_FFD238).w
	rts
.3
	cmpi.w	#4,(word_FFD238).w
	beq.w	.4
	cmpi.w	#7,(word_FFD238).w
.4
	rts

PListMark	;PlayerStatsList: print a value, highlighted in the column of the category
	move.w	(printa).w,-(sp)
	move.w	(DispAttribCtr).w,d0
	cmp.w	(word_FFD238).w,d0
	bne.w	.0
	jsr	(printsmallz).l
	String	$FE,$05
.0
	jsr	(printcur).l
	move.w	(sp)+,(printa).w
	rts

