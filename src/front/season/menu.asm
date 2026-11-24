;	The season stats screen and the playoff menu.

SetSframe							;Draw one sprite frame. a0 = framelist, d0/d1 = x/y cords, d2 = frame, d3
									;= start char a6 = Satt pointer, d6 =
									;link counter.
	cmp.w	#MaxSprites,d6			;MaxSprites
	bge.w	.exit
	movem.l	d0-d5/a0,-(sp)
	adda.l	4(a0),a0
	add.w	d2,d2
	move.w	2(a0,d2.w),d4
	sub.w	(a0,d2.w),d4
	lsr.w	#3,d4
	subq.w	#1,d4					;number of sprites in frame
	adda.w	(a0,d2.w),a0
.loop
	move.w	2(a0),d2
	andi.w	#$F000,d2
	lsr.w	#1,d2
	move.w	d2,-(sp)
	move.w	4(a0),d2
	andi.w	#$7FF,d2
	or.w	(sp)+,d2
	add.w	d3,d2
	move.w	(a0),(a6)
	add.w	d1,(a6)+
	move.b	2(a0),(a6)+
	move.b	d6,(a6)+
	move.w	d2,(a6)+
	move.w	6(a0),(a6)
	add.w	d0,(a6)+
	addq.w	#1,d6
	cmp.w	#$40,d6
	beq.w	.full
	addq.w	#8,a0
	dbf	d4,.loop
.full
	movem.l	(sp)+,d0-d5/a0
.exit
	rts
	movem.l	d0-d7/a0-a6,-(sp)
	clr.w	(carddelay).w
	bsr.w	SetupLeadersScreenVideo
	movea.l	#LeadersSprites,a0
	jsr	(DrawScreenSprite).l
	jsr	(PStatsPalette).l
	move.w	#$18,(palcount).w
	bclr	#2,(disflags).w
	clr.w	(pstatstop).w
	move.w	#$D,(pstatsrows).w
	move.w	#$C,(pstatsrow).w
	clr.w	(pstatscat).w
.loop2
	bsr.w	BuildPlayerLeaders
	move.w	(pstatslast+2).w,d0
	cmp.w	#$14,d0
	ble.w	.1
	move.w	#$14,d0
.1
	subq.w	#1,d0
	move.w	d0,(pstatslast).w
.loop3
	move.w	(Vcount).w,d0
.loop4
	cmp.w	(Vcount).w,d0
	beq.s	.loop4
	jsr	(SetMenuScroll).l
	bsr.w	PrintLeadersCategory
	move.w	(Vcount).w,d0
.loop5
	cmp.w	(Vcount).w,d0
	beq.s	.loop5
	jsr	(SetMenuScroll).l
	bset	#2,(disflags).w
	bsr.w	DrawLeaderRows
	move.w	#$2500,sr
	bsr.w	LeadersScrollArrows
	bclr	#2,(disflags).w
.loop6
	bsr.w	LeadersReadPad
	tst.w	d1
	beq.w	.5
	btst	#7,d1
	bne.w	.6
	btst	#2,d1
	beq.w	.2
	bsr.w	ClearLeadersRows
	subq.w	#1,(pstatscat).w
	bpl.w	.loop7
	move.w	#3,d0
	move.w	d0,(pstatscat).w
.loop7
	clr.w	(pstatstop).w
	move.w	#$C,(pstatsrow).w
	bra.w	.loop2
.2
	btst	#0,d1
	beq.w	.3
	tst.w	(pstatstop).w
	beq.s	.loop6
	subq.w	#1,(pstatstop).w
	subq.w	#1,(pstatsrow).w
	bra.w	.loop3
.3
	btst	#1,d1
	beq.w	.4
	move.w	(pstatsrow).w,d0
	cmp.w	(pstatslast).w,d0
	bge.s	.loop6
	addq.w	#1,(pstatstop).w
	addq.w	#1,(pstatsrow).w
	bra.w	.loop3
.4
	btst	#3,d1
	beq.s	.loop6
	bsr.w	ClearLeadersRows
	addq.w	#1,(pstatscat).w
	move.w	#3,d0
	cmp.w	(pstatscat).w,d0
	bge.s	.loop7
	clr.w	(pstatscat).w
	bra.s	.loop7
.5
	jmp	(Opening2).l
.6
	move.l	#SeasonMenuScreen,(NextScreenPtr).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts

LeadersScrollArrows					;League Leaders: draw up/down scroll arrows depending on list position.
	movem.l	d0-d7/a0-a6,-(sp)
	tst.w	(pstatstop).w
	beq.w	.1
	jsr	(printcurz).l
	String	$8F,2,$B,'{'
	bra.w	.2
.1
	jsr	(printcurz).l
	String	$8F,2,$B,' '
.2
	move.w	(pstatsrow).w,d1
	cmp.w	(pstatslast).w,d1
	bge.w	.3
	jsr	(printcurz).l
	String	$8F,2,$17,'}'
	bra.w	.4
.3
	jsr	(printcurz).l
	String	$8F,2,$17,' '
.4
	movem.l	(sp)+,d0-d7/a0-a6
	rts
PrintLeadersCategory	equ	*	;Print the category name of the leaders screen
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),$1E,8
	move.w	(pstatscat).w,d0
	movea.l	#$1DA8D8,a1
	jsr	(PrintBigListItem).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts
	dc.w	$000A,$476F,$616C,$7320,$2000,$000A,$4173,$7369
	dc.w	$7374,$7300,$000A,$506F,$696E,$7473,$2000,$000A
	dc.w	$2020,$2020,$4741,$4100
LeadersReadPad	equ	*
	dc.w	$2C3C,$0000,$5460,$3C3C,$0064,$3238,$B052,$9278
	dc.w	$B054,$67F2,$31F8,$B052,$B054,$4EB9,$0001,$2640
	dc.w	$4EB9,$0001,$B348,$4EB9,$0001,$B320,$4A41,$6700
	dc.w	$0006,$6000,$0050,$4EB9,$0001,$B360,$4EB9,$0001
	dc.w	$B320,$4A41,$6700,$0006,$6000,$003A,$4A78,$D250
	dc.w	$6700,$002E,$4EB9,$0001,$B378,$4EB9,$0001,$B320
	dc.w	$4A41,$6700,$0006,$6000,$001C,$4EB9,$0001,$B390
	dc.w	$4EB9,$0001,$B320,$4A41,$6700,$0006,$6000,$0006
	dc.w	$51CE,$FF84,$4E75
ClearLeadersRows	equ	*	;Clear the leaders rows and print the headings again
	dc.w	$48E7,$FFFE,$303C,$0024,$323C,$000D,$343C,$07FF
	dc.w	$0042,$8000,$4EB9,$0001,$BB8E,$0006,$BF02,$0B00
	dc.w	$4EB9,$0001,$B976,$4EB9,$0001,$BED6,$000E,$F804
	dc.w	$011E,$0820,$2020,$2020,$2020,$4EB9,$0001,$BED6
	dc.w	$001E,$F804,$0109,$0520,$2020,$2020,$2020,$2020
	dc.w	$2020,$2020,$2020,$2020,$2020,$2020,$2000,$4CDF
	dc.w	$7FFF,$4E75

BuildPlayerLeaders					;League leaders: build and sort the list of category pstatscat through
									;PlayerLeaderJumps
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(pstatscat).w,d0
	asl.w	#2,d0
	movea.l	#PlayerLeaderJumps,a0
	movea.l	(a0,d0.w),a0
	jmp	(a0)
BuildPlayerLeadersExit	equ	*
	movem.l	(sp)+,d0-d7/a0-a6
	rts

PlayerLeaderJumps					;BuildPlayerLeaders handler per category: goals, assists, points, goals
									;against average
	dc.w	$001D,$AA56,$001D,$AA88,$001D,$AABA,$001D,$AA16
	move.l	#$598C,d1
	moveq	#$E,d2
	moveq	#3,d3
	move.l	#$5DD0,d4
	moveq	#$D,d6
	btst	#2,(SeasonDay+2).w
	beq.w	.1
	move.l	#$3268,d1
	moveq	#$E,d2
	moveq	#3,d3
	move.l	#$3508,d4
	moveq	#$D,d6
.1
	movea.l	#ReadSRAMBitsSkip3,a5
	bset	#1,(BA_PS_flags).w
	bsr.w	BuildGoalieLeaders
	bra.s	BuildPlayerLeadersExit
	move.l	#$268,d1
	moveq	#$C,d2
	moveq	#$18,d3
	btst	#2,(SeasonDay+2).w
	beq.w	.2
	move.l	#$448,d1
	moveq	#$A,d2
	moveq	#$18,d3
.2
	movea.l	#ReadSRAMBitsSkip1,a5
	bclr	#1,(BA_PS_flags).w
	bsr.w	BuildSkaterLeaders
	bra.w	BuildPlayerLeadersExit
	move.l	#$1FA8,d1
	moveq	#$C,d2
	moveq	#$18,d3
	btst	#2,(SeasonDay+2).w
	beq.w	.3
	move.l	#$1348,d1
	moveq	#$A,d2
	moveq	#$18,d3
.3
	movea.l	#ReadSRAMBitsSkip1,a5
	bclr	#1,(BA_PS_flags).w
	bsr.w	BuildSkaterLeaders
	bra.w	BuildPlayerLeadersExit
	move.l	#$268,d1
	moveq	#$C,d2
	moveq	#$18,d3
	btst	#2,(SeasonDay+2).w
	beq.w	.4
	move.l	#$448,d1
	moveq	#$A,d2
	moveq	#$18,d3
.4
	movea.l	#ReadSRAMBitsSkip2,a5
	bclr	#1,(BA_PS_flags).w
	bsr.w	BuildSkaterLeaders
	bra.w	BuildPlayerLeadersExit
BuildGoalieLeaders					;Leaders: sort the goalies of every team into the leader list
	movea.l	#$FFFF193A,a0
	movea.l	#pstatslast+2,a2
	movea.l	#LeaderIds,a3
	clr.w	d7
	clr.w	(a2)
	clr.w	d5
.loop
	movem.l	d1/d4-d5/d7,-(sp)
	btst	#2,(SeasonDay+2).w
	beq.w	.1
	jsr	(GetPOSlotTeam).l
	move.w	d7,d5
	mulu.w	#$1B,d5
.1
	jsr	(GetGoalieCountD7).l
	move.w	d0,d3
	jsr	(a5)
	movem.l	(sp)+,d1/d4-d5/d7
	addi.l	#$2A,d1
	addi.l	#$27,d4
	addi.w	#$1B,d5
	addq.w	#1,d7
	btst	#2,(SeasonDay+2).w
	beq.w	.2
	cmp.w	#$10,d7
	blt.s	.loop
	bra.w	.3
.2
	cmp.w	#$1A,d7
	blt.s	.loop
.3
	move.w	(pstatslast+2).w,d3
	beq.w	PlayerLeaderJumpsExit
	subq.w	#1,d3
	clr.w	d4
	bra.w	SortLeaderValues
BuildSkaterLeaders					;Leaders: sort the skaters of every team into the leader list
	movea.l	#$FFFF193A,a0
	movea.l	#pstatslast+2,a2
	movea.l	#LeaderIds,a3
	clr.w	d7
	clr.w	(a2)
	clr.w	d5
.loop
	movem.w	d5/d7,-(sp)
	btst	#2,(SeasonDay+2).w
	beq.w	.1
	jsr	(GetPOSlotTeam).l
	move.w	d7,d5
	mulu.w	#$1B,d5
.1
	jsr	(GetPlayerCountD7).l
	move.w	d0,(PlayoffMenuTeam+2).w
	jsr	(GetGoalieCountD7).l
	sub.w	d0,(PlayoffMenuTeam+2).w
	subi.w	#$18,(PlayoffMenuTeam+2).w
	neg.w	(PlayoffMenuTeam+2).w
	add.w	d0,d5
	jsr	(a5)
	movem.w	(sp)+,d5/d7
	addi.w	#$1B,d5
	addq.w	#1,d7
	btst	#2,(SeasonDay+2).w
	beq.w	.2
	cmp.w	#$10,d7
	blt.s	.loop
	bra.w	.3
.2
	cmp.w	#$1A,d7
	blt.s	.loop
.3
	move.w	(pstatslast+2).w,d3
	beq.w	PlayerLeaderJumpsExit
	subq.w	#1,d3
	clr.w	d4
SortLeaderValues	equ	*	;Leaders: order the values a1 (up or down by BA_PS_flags) and note whether it changed
	movea.l	#$FFFF193A,a1
	movea.l	#LeaderIds,a0
	btst	#1,(BA_PS_flags).w
	bne.w	SortValuesUp
.loop2
	clr.w	d0
	clr.w	(TempWord1).w
	move.w	(pstatslast+2).w,d2
	beq.w	PlayerLeaderJumpsExit
	subq.w	#2,d2
	beq.w	PlayerLeaderJumpsExit
	bmi.w	PlayerLeaderJumpsExit
.loop3
	move.w	(a1,d0.w),d5
	move.w	2(a1,d0.w),d6
	cmp.w	d5,d6
	ble.w	.4
	st	(TempWord1).w
	move.w	(a1,d0.w),-(sp)
	move.w	2(a1,d0.w),-(sp)
	move.w	(sp)+,(a1,d0.w)
	move.w	(sp)+,2(a1,d0.w)
	move.w	(a0,d0.w),-(sp)
	move.w	2(a0,d0.w),-(sp)
	move.w	(sp)+,(a0,d0.w)
	move.w	(sp)+,2(a0,d0.w)
.4
	addq.w	#2,d0
	dbf	d2,.loop3
	tst.w	(TempWord1).w
	bne.s	.loop2
PlayerLeaderJumpsExit	equ	*
	rts

SortValuesUp						;Bubble sort the values at LeaderValues / players at LeaderPlayers
									;ascending.
	clr.w	d0
	clr.w	(TempWord1).w
	move.w	(pstatslast+2).w,d2
	beq.s	PlayerLeaderJumpsExit
	subq.w	#2,d2
	beq.s	PlayerLeaderJumpsExit
	bmi.s	PlayerLeaderJumpsExit
.loop
	move.w	(a1,d0.w),d5
	move.w	2(a1,d0.w),d6
	cmp.w	d5,d6
	bge.w	.1
	st	(TempWord1).w
	move.w	(a1,d0.w),-(sp)
	move.w	2(a1,d0.w),-(sp)
	move.w	(sp)+,(a1,d0.w)
	move.w	(sp)+,2(a1,d0.w)
	move.w	(a0,d0.w),-(sp)
	move.w	2(a0,d0.w),-(sp)
	move.w	(sp)+,(a0,d0.w)
	move.w	(sp)+,2(a0,d0.w)
.1
	addq.w	#2,d0
	dbf	d2,.loop
	tst.w	(TempWord1).w
	bne.s	SortValuesUp
	rts
DrawLeaderRows	equ	*	;Draw the rows of the player leaders table
	jsr	(printz).l
	String	$8F,0,0
	clr.w	d6
	movea.l	#$FFFF193A,a5
	move.w	#$B,(printy).w
.loop2
	move.w	#4,(printx).w
	movea.l	#BlankStatsRow,a1
	jsr	(printcur).l
	move.w	d6,d0
	add.w	(pstatstop).w,d0
	cmp.w	(pstatslast+2).w,d0
	blt.w	.2
	move.w	d6,d0
	add.w	(pstatstop).w,d0
	cmp.w	(pstatslast).w,d0
	bge.w	.6
	move.w	d0,(pstatslast).w
	bra.w	.6
.2
	move.w	#4,(printx).w
	move.w	d6,d0
	add.w	(pstatstop).w,d0
	move.w	d0,-(sp)
	addq.w	#1,d0
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printcur).l
	move.w	#7,(printx).w
	movea.l	#LeaderIds,a0
	move.w	d6,d0
	add.w	(pstatstop).w,d0
	add.w	d0,d0
	move.w	(a0,d0.w),d0
	ext.l	d0
	divu.w	#$1B,d0
	move.w	d0,d7
	swap	d0
	tst.w	(sp)+
	bne.w	.3
	move.w	(printx).w,-(sp)
	move.w	(printy).w,-(sp)
	move.w	(printa).w,-(sp)
	move.w	(printm).w,-(sp)
	jsr	(GetPlayerNameD7ToA1).l
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),$14,5
	move.w	d0,-(sp)
	move.w	(a1),d0
	subq.w	#2,d0
	asr.w	#1,d0
	sub.w	d0,(printx).w
	jsr	(printbig).l
	move.w	(sp)+,d0
	move.w	(sp)+,(printm).w
	move.w	(sp)+,(printa).w
	move.w	(sp)+,(printy).w
	move.w	(sp)+,(printx).w
.3
	jsr	(FormatPlayerNameD7).l
	jsr	(printcur).l
	move.w	#$19,(printx).w
	movea.l	#$77E,a1
	move.w	d7,d0
	asl.w	#2,d0
	movea.l	(a1,d0.w),a1
	adda.w	4(a1),a1
	adda.w	(a1),a1
	jsr	(printcur).l
	move.w	#$20,(printx).w
	movea.l	#$FFFF193A,a0
	move.w	d6,d0
	add.w	(pstatstop).w,d0
	add.w	d0,d0
	move.w	(a0,d0.w),d0
	cmpi.w	#3,(pstatscat).w
	bne.w	.4
	ext.l	d0
	divu.w	#$64,d0
	swap	d0
	move.w	d0,-(sp)
	swap	d0
	move.w	#3,d1
	jsr	(PushNumberWidth).l
	jsr	(printcur).l
	jsr	(printcurz).l
	String	'.'
	move.w	(sp)+,d0
	move.w	#2,d1
	jsr	(PushNumberWidthZero).l
	bra.w	.5
.4
	move.w	#3,d1
	jsr	(PushNumberWidth).l
.5
	jsr	(printcur).l
.6
	addq.w	#1,(printy).w
	addq.w	#1,d6
	cmp.w	(pstatsrows).w,d6
	blt.w	.loop2
	bra.w	.7
.7
	rts

BlankStatsRow						;A String of blanks that clears a stats list row
	dc.b	$00,$24,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	dc.b	$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	dc.b	$20,$20,$20,$20
SetupLeadersScreenVideo	equ	*	;Set the VBint handler, scroll and map addresses for the leaders screen and load its graphics
	bset	#5,(sflags12).w
	move.l	#VBlank_Menus,(VBint).w
	bclr	#dfok,(disflags).w
	bset	#dfng,(disflags).w
	bclr	#df32c,(disflags).w
	move.w	#0,(VSCRLPM).w
	move.w	#$B400,(VSPRITES).w
	move.w	#$B800,(VmMAP3).w
	move.w	#5,(Map3col).w
	move.w	#$C000,(VmMAP2).w
	move.w	#6,(Map2col).w
	move.w	#$E000,(VmMAP1).w
	move.w	#6,(Map1col).w
	move.w	#0,d0					;fade to color
	bset	#5,(disflags).w
	jsr	(setVram).l
	bclr	#5,(disflags).w
	jsr	(orjoy).l
	move.w	#1,d4
	movea.l	#LeadersSprites,a1
	jsr	(LoadScreenSprite).l
	move.w	d4,(smallfontchars).w
	movea.l	#RosterFont+8,a2
	jsr	(DecompressGraphicsPlain).l
	move.w	d4,(smallfont2chars).w
	movea.l	#SmallFontMap2+8,a2
	jsr	(DecompressGraphicsPlain).l
	move.l	#RosterFont,(smallfontptr).w
	move.w	d4,(BigFontchars).w
	movea.l	#BigFontMap4+8,a2
	jsr	(DecompressGraphicsPlain).l
	bset	#2,(sflags11).w
	jsr	(printsmallz).l
	String	$FF,1,$FD,0,$FC
	moveq	#$28,d0
	moveq	#$1C,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),0,0
	movea.l	#LeadersBgMap,a0
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
	String	-(TXPRI+TXMAP1),$B,1
	movea.l	#LeagueLeadersTitleMap,a0
	btst	#2,(SeasonDay+2).w
	beq.w	.1
	movea.l	#PlayoffLeadersTitleMap,a0
.1
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
	move.w	(smallfontchars).w,-(sp)
	move.w	(smallfont2chars).w,(smallfontchars).w
	jsr	(printcurz).l
	String	$8F,$A,$19,'{}-SCROLL LIST',$8F,$A,$1A,'[]-CHANGE CATEGORY'
	move.w	(sp)+,(smallfontchars).w
	jsr	(printz).l
	String	$FE,0,0
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
	jsr	(printbigz).l
	String	$F8,4,1,7,8,'#',$F8,4,1,$B,8,'PLAYER',$F8,4,1,$18,8,'TEAM'
	move.w	#$2500,sr
	rts

SeasonPlayoffStats					;The playoff stats screen in a season (PlayoffStatsMenu with GameFlags bit
									;7): the players or goalies of a
									;team by category (pstatscat), the PStats helpers of code96_16
	movem.l	d0-d7/a0-a6,-(sp)
	clr.w	(carddelay).w
	clr.w	(pstatscat).w
	clr.w	(pstatsteam).l
	bset	#5,(sflags12).w
	bsr.w	PStatsSetup
	movea.l	#PlayerStatsSprites,a0
	jsr	(DrawScreenSprite).l
	move.w	#$18,(palcount).w
	bclr	#dfng,(disflags).w
	clr.w	(pstatstop).w
	move.w	#$D,(pstatsrows).w
	move.w	#$C,(pstatsrow).w
	clr.w	(pstatscat).w
.1
	move.w	(pstatsteam).l,d7
	btst	#2,(SeasonFlags).w
	beq.w	.2
	jsr	(GetPOSlotTeam).l
.2
	cmpi.w	#4,(pstatscat).w
	blt.w	.3
	jsr	(GetGoalieCountD7).l
	subq.w	#1,d0
	move.w	d0,(pstatslast).w
	bra.w	.draw
.3
	jsr	(GetGoalieCountD7).l
	move.w	d0,-(sp)
	jsr	(GetPlayerCountD7).l
	sub.w	(sp)+,d0
	subq.w	#1,d0
	move.w	d0,(pstatslast).w
.draw
	bsr.w	PStatsBuildList
	move.w	(Vcount).w,d0
.loop2
	cmp.w	(Vcount).w,d0
	beq.s	.loop2
	bsr.w	PStatsClearList
.4
	move.w	(Vcount).w,d0
.7
	cmp.w	(Vcount).w,d0
	beq.s	.7
	bsr.w	PStatsCategory
	bsr.w	PStatsTeamBlock
	bsr.w	PStatsHelp
	bsr.w	PStatsHeading
	move.w	(Vcount).w,d0
.loop3
	cmp.w	(Vcount).w,d0
	beq.s	.loop3
	bset	#dfng,(disflags).w
	jsr	(SetMenuScroll).l
	bsr.w	PStatsPrintList
	jsr	(SetMenuScroll).l
	move	#$2500,sr
	bsr.w	PStatsArrows
	jsr	(SetMenuScroll).l
	bclr	#dfng,(disflags).w
.input
	bsr.w	WaitAnyPad
	tst.w	d1
	beq.w	.17
	btst	#7,d1
	bne.w	.18
	btst	#2,d1
	beq.w	.right
	cmpi.w	#4,(pstatscat).w
	blt.w	.8
	subq.w	#1,(pstatscat).w
	cmpi.w	#4,(pstatscat).w
	bge.w	.9
	move.w	#6,(pstatscat).w
	bra.w	.9
.8
	subq.w	#1,(pstatscat).w
	bpl.w	.9
	move.w	#3,(pstatscat).w
.9
	clr.w	(pstatstop).w
	move.w	#$C,(pstatsrow).w
	bra.w	.1
.right
	btst	#0,d1
	beq.w	.13
	tst.w	(pstatstop).w
	beq.s	.input
	subq.w	#1,(pstatstop).w
	subq.w	#1,(pstatsrow).w
	bra.w	.4
.13
	btst	#1,d1
	beq.w	.6
	move.w	(pstatsrow).w,d0
	cmp.w	(pstatslast).w,d0
	bge.w	.input
	addq.w	#1,(pstatstop).w
	addq.w	#1,(pstatsrow).w		;next lower item
	bra.w	.4
.6
	btst	#6,d1
	beq.w	.5
	subq.w	#1,(pstatsteam).l
	bpl.w	.1
	btst	#2,(SeasonFlags).w
	beq.w	.10
	move.w	#$F,(pstatsteam).l
	bra.w	.1
.10
	move.w	#$19,(pstatsteam).l
	bra.w	.1
.5
	btst	#5,d1
	beq.w	.14
	addq.w	#1,(pstatsteam).l
	btst	#2,(SeasonFlags).w
	beq.w	.11
	cmpi.w	#$10,(pstatsteam).l
	bra.w	.12
.11
	cmpi.w	#$1A,(pstatsteam).l
.12
	bne.w	.1
	clr.w	(pstatsteam).l
	bra.w	.1
.14
	btst	#4,d1
	beq.w	.0
	cmpi.w	#4,(pstatscat).w
	blt.w	.15
	clr.w	(pstatscat).w
	bra.w	.1
.15
	move.w	#4,(pstatscat).w
	bra.w	.1
.0
	btst	#3,d1
	beq.w	.input
	addq.w	#1,(pstatscat).w
	cmpi.w	#4,(pstatscat).w
	blt.w	.9
	bgt.w	.16
	clr.w	(pstatscat).w
	bra.w	.9
.16
	cmpi.w	#6,(pstatscat).w
	ble.w	.9
	move.w	#4,(pstatscat).w
	bra.w	.9
.17
	bclr	#5,(sflags12).w
	jmp	Opening2
.18
	bclr	#5,(sflags12).w
	move.l	#SeasonMenuScreen,(NextScreenPtr).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts

WaitAnyPad							;Wait for a press on pad 1 or 2 (3 and 4 with
									;FourWayPlay); d1 = the buttons
	move.l	#$5460,d6
.wait
	move.w	#$64,d6
	move.w	(Vcount).w,d1
	sub.w	(OldVcount).w,d1
	beq.s	.wait
	jsr	(SetMenuScroll).l
	move.w	(Vcount).w,(OldVcount).w
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

PStatsArrows						;SeasonPlayoffStats: the scroll marks { (pstatstop above 0) and } (more
									;rows below)
	movem.l	d0-d7/a0-a6,-(sp)
	tst.w	(pstatstop).w
	beq.w	.0
	jsr	(printcurz).l
	String	CC_Font1Pal3Pri,$02,$0B,'{'
	bra.w	.1
.0
	jsr	(printcurz).l
	String	CC_Font1Pal3Pri,$02,$0B,' '
.1
	move.w	(pstatsrow).w,d1
	cmp.w	(pstatslast).w,d1
	bge.w	.2
	jsr	(printcurz).l
	String	CC_Font1Pal3Pri,$02,$17,'}'
	bra.w	.3
.2
	jsr	(printcurz).l
	String	CC_Font1Pal3Pri,$02,$17,' '
.3
	movem.l	(sp)+,d0-d7/a0-a6
	rts

PStatsClearList						;SeasonPlayoffStats: erase the list area
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#$24,d0
	move.w	#$D,d1
	move.w	#$7FF,d2
	ori.w	#$8000,d2
	jsr	(printz).l
	String	CC_Font1Pri,$02,$0B
	jsr	(eraser).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

PStatsSetup							;SeasonPlayoffStats: vram, fonts and the screen bitmaps, the heading, the
									;team block and the help
	bset	#5,(sflags12).w
	move.l	#VBlank_Menus,(VBint).w
	bclr	#dfok,(disflags).w
	bset	#dfng,(disflags).w
	bclr	#df32c,(disflags).w
	move.w	#0,(VSCRLPM).w
	move.w	#$B400,(VSPRITES).w
	move.w	#$B800,(VmMAP3).w
	move.w	#5,(Map3col).w
	move.w	#$C000,(VmMAP2).w
	move.w	#6,(Map2col).w
	move.w	#$E000,(VmMAP1).w
	move.w	#6,(Map1col).w
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
	move.w	d4,(BigFontchars).w
	movea.l	#BigFontMap4+8,a2
	jsr	(DecompressGraphicsPlain).l
	bset	#2,(sflags11).w
	move.w	d4,(pstatsblockchars).l
	addi.w	#$20,d4
	jsr	(printsmallz).l
	String	CC_SetMap,$01,CC_SetX,$00,CC_SetY
	moveq	#$28,d0
	moveq	#$1C,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	jsr	(printz).l
	String	CC_Font1Pri,$00,$00
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
	String	CC_Font1Pri,$0B,$01
	movea.l	#SeasonStatsTitleMap,a0
	btst	#2,(SeasonFlags).w
	beq.w	.0
	jsr	(printz).l
	String	CC_Font1Pri,$0B,$01
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
	bsr.w	PStatsHelp
	jsr	(printz).l
	String	CC_Font2,$00,$00
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
	bsr.w	PStatsHeading
	bsr.w	PStatsCategory
	bsr.w	PStatsTeamBlock
	bsr.w	PStatsPalette
	move	#$2500,sr
	rts

PStatsTeamBlock						;SeasonPlayoffStats: the team block of the shown team (DrawSetupTeamBlock)
	move.w	d7,-(sp)
	jsr	(printz).l
	String	CC_Font1Pri,$01,$05
	move.w	(pstatsblockchars).l,d4
	move.w	(pstatsteam).l,d7
	btst	#2,(SeasonFlags).w
	beq.w	.0
	jsr	(GetPOSlotTeam).l
.0
	jsr	(DrawSetupTeamBlock).l
	move.w	(sp)+,d7

PStatsHeading						;SeasonPlayoffStats: the column heading, players or goalies (pstatscat 4
									;and up)
	cmpi.w	#4,(pstatscat).w
	bge.w	.0
	jsr	(printbigz).l
	String	CC_SetMapAndPosition,$04,$01,$04,$08,'#  PLAYER         g   a   p   pim'
	bra.w	.1
.0
	jsr	(printbigz).l
	String	CC_SetMapAndPosition,$04,$01,$04,$08,'#  GOALIE        s     sh    sp  '
.1
	rts

PStatsHelp							;SeasonPlayoffStats: the button help lines
	cmpi.w	#4,(pstatscat).w
	bge.w	.1
	move.w	(smallfontchars).w,-(sp)
	move.w	(smallfont2chars).w,(smallfontchars).w
	jsr	(printcurz).l
	String	CC_Font1Pal3Pri,$04,$19,'{}-SCROLL LIST   A/C-TEAMS',CC_Font1Pal3Pri,$04,$1A,'[]-CATEGORY      B-GOALIES'
	move.w	(sp)+,(smallfontchars).w
	bra.w	.0
.1
	move.w	(smallfontchars).w,-(sp)
	move.w	(smallfont2chars).w,(smallfontchars).w
	jsr	(printcurz).l
	String	CC_Font1Pal3Pri,$04,$19,'{}-SCROLL LIST   A/C-TEAMS',CC_Font1Pal3Pri,$04,$1A,'[]-CATEGORY      B-PLAYERS'
	move.w	(sp)+,(smallfontchars).w
.0
	rts

PStatsCategory						;SeasonPlayoffStats: the name of category pstatscat (PStatsCategoryTxt)
	jsr	(printz).l
	String	CC_Font1Pri,$15,$05
	movea.l	#PStatsCategoryTxt,a1
	move.w	(pstatscat).w,d0
	jsr	(SkipStrings).l
	jsr	(printbig).l
	rts

PStatsCategoryTxt					;PStatsCategory: the category names
	dc.b	$00,$12,$20,$20,$20,$20,$20,$67,$6F,$61,$6C,$73,$20,$20,$20,$20
	dc.b	$20,$00,$00,$12,$20,$20,$20,$20,$61,$73,$73,$69,$73,$74,$73,$20
	dc.b	$20,$20,$20,$00,$00,$12,$20,$20,$20,$20,$20,$70,$6F,$69,$6E,$74
	dc.b	$73,$20,$20,$20,$20,$00,$00,$12,$70,$65,$6E,$61,$6C,$74,$79,$20
	dc.b	$6D,$69,$6E,$75,$74,$65,$73,$00,$00,$12,$20,$20,$20,$20,$20,$73
	dc.b	$61,$76,$65,$73,$20,$20,$20,$20,$20,$00,$00,$12,$20,$20,$20,$20
	dc.b	$20,$73,$68,$6F,$74,$73,$20,$20,$20,$20,$20,$00,$00,$12,$73,$61
	dc.b	$76,$65,$20,$70,$65,$72,$63,$65,$6E,$74,$61,$67,$65,$00

PStatsBuildList						;SeasonPlayoffStats: the player or goalie list of the shown team, sorted
									;by category
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(pstatsteam).l,d7
	btst	#2,(SeasonFlags).w
	beq.w	.0
	jsr	(GetPOSlotTeam).l
.0
	cmpi.w	#4,(pstatscat).w
	bge.w	.9
	jsr	(GetPlayerCountD7).l
	move.w	d0,-(sp)
	jsr	(GetGoalieCountD7).l
	move.w	d0,d1
	sub.w	(sp)+,d0
	neg.w	d0
	move.w	d0,(pstatscount).l
	movea.l	#LeaderIds,a0
	bra.w	.2
.1
	move.w	d1,(a0)+
	addq.w	#1,d1
.2
	dbf	d0,.1
	btst	#2,(SeasonFlags).w
	beq.w	.3
	jsr	(GetTeamPOSlot).l
.3
	move.w	(pstatscount).l,d3
	movea.l	#$FFFF193A,a0
	move.l	#$268,d1
	moveq	#$C,d2
	move.l	#$120,d4
	btst	#2,(SeasonFlags).w
	beq.w	.4
	move.l	#$448,d1
	moveq	#$A,d2
	move.l	#$F0,d4
.4
	jsr	(ReadSRAMBitWords).l
	movea.l	#$FFFF1A02,a0
	move.l	#$1FA8,d1
	moveq	#$C,d2
	move.w	(pstatscount).l,d3
	move.l	#$120,d4
	btst	#2,(SeasonFlags).w
	beq.w	.5
	move.l	#$1348,d1
	moveq	#$A,d2
	move.l	#$F0,d4
.5
	jsr	(ReadSRAMBitWords).l
	movea.l	#$FFFF193A,a1
	movea.l	#$FFFF1A02,a2
	movea.l	#$FFFF1ACA,a0
	move.w	(pstatscount).l,d3
	bra.w	.7
.6
	move.w	(a1)+,d0
	add.w	(a2)+,d0
	move.w	d0,(a0)+
.7
	dbf	d3,.6
	movea.l	#$FFFF1B92,a0
	move.l	#$3CE8,d1
	moveq	#$A,d2
	move.w	(pstatscount).l,d3
	move.l	#$F0,d4
	btst	#2,(SeasonFlags).w
	beq.w	.8
	move.l	#$2248,d1
	moveq	#9,d2
	move.l	#$D8,d4
.8
	jsr	(ReadSRAMBitWords).l
	bra.w	.18
.9
	jsr	(GetGoalieCountD7).l
	move.w	d0,(pstatscount).l
	movea.l	#LeaderIds,a0
	clr.w	d1
	bra.w	.11
.10
	move.w	d1,(a0)+
	addq.w	#1,d1
.11
	dbf	d0,.10
	btst	#2,(SeasonFlags).w
	beq.w	.12
	jsr	(GetTeamPOSlot).l
.12
	movea.l	#$FFFF1C5A,a0
	move.w	(pstatscount).l,d3
	move.l	#$598C,d1
	moveq	#$E,d2
	moveq	#$2A,d4
	btst	#2,(SeasonFlags).w
	beq.w	.13
	move.l	#$3268,d1
	moveq	#$E,d2
	moveq	#$2A,d4
.13
	jsr	(ReadSRAMBitWords).l
	movea.l	#$FFFF1D22,a0
	move.l	#$5548,d1
	moveq	#$E,d2
	move.w	(pstatscount).l,d3
	moveq	#$2A,d4
	btst	#2,(SeasonFlags).w
	beq.w	.14
	move.l	#$2FC8,d1
	moveq	#$E,d2
	moveq	#$2A,d4
.14
	jsr	(ReadSRAMBitWords).l
	movea.l	#$FFFF1C5A,a0
	movea.l	#$FFFF1D22,a1
	movea.l	#$FFFF1DEA,a2
	move.w	(pstatscount).l,d3
	bra.w	.17
.15
	move.w	(a1)+,d0
	sub.w	(a0),d0
	move.w	d0,(a0)+
	move.w	-2(a1),d1
	beq.w	.16
	mulu.w	#$64,d0
	divu.w	d1,d0
.16
	move.w	d0,(a2)+
.17
	dbf	d3,.15
.18
	movea.l	#PStatsColumns,a0
	move.w	(pstatscat).w,d0
	asl.w	#2,d0
	movea.l	(a0,d0.w),a0
	movea.l	#LeaderIds,a1
	move.w	(a1),d0
	add.w	d0,d0
	suba.w	d0,a0
.19
	clr.w	(TempWord1).w
	clr.w	d0
	move.w	(pstatscount).l,d5
	subq.w	#2,d5
.20
	move.w	d0,d1
	add.w	d1,d1
	move.w	(a1,d1.w),d2
	move.w	2(a1,d1.w),d3
	add.w	d2,d2
	add.w	d3,d3
	move.w	(a0,d2.w),d4
	cmp.w	(a0,d3.w),d4
	bge.w	.21
	st	(TempWord1).w
	move.w	(a1,d1.w),d2
	move.w	2(a1,d1.w),d3
	move.w	d2,2(a1,d1.w)
	move.w	d3,(a1,d1.w)
.21
	addq.w	#1,d0
	dbf	d5,.20
	tst.w	(TempWord1).w
	bne.s	.19
	movem.l	(sp)+,d0-d7/a0-a6
	rts

PStatsColumns						;PStatsPrintValue: the stat offsets of each category
	dc.b	$FF,$FF,$19,$3A,$FF,$FF,$1A,$02,$FF,$FF,$1A,$CA,$FF,$FF,$1B,$92
	dc.b	$FF,$FF,$1C,$5A,$FF,$FF,$1D,$22,$FF,$FF,$1D,$EA

PStatsPrintList						;SeasonPlayoffStats: print the rows of the list
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(printz).l
	String	CC_Font1Pal3Pri,$00,$00
	clr.w	d6
	move.w	#$B,(printy).w
.0
	clr.w	(pstatscol).l
	cmpi.w	#4,(pstatscat).w
	blt.w	.1
	move.w	#4,(pstatscol).l
.1
	movea.l	#PStatsColumns,a5
	move.w	(pstatscol).l,d0
	asl.w	#2,d0
	movea.l	(a5,d0.w),a5
	move.w	#4,(printx).w
	movea.l	#BlankStatsRow,a1
	jsr	(printcur).l
	move.w	d6,d0
	add.w	(pstatstop).w,d0
	cmp.w	(pstatscount).l,d0
	blt.w	.2
	move.w	d6,d0
	add.w	(pstatstop).w,d0
	cmp.w	(pstatslast).w,d0
	bge.w	.11
	move.w	d0,(pstatslast).w
	bra.w	.11
.2
	move.w	#4,(printx).w
	movea.l	#LeaderIds,a0
	move.w	d6,d0
	add.w	(pstatstop).w,d0
	add.w	d0,d0
	move.w	(a0,d0.w),d0
	ext.l	d0
	move.w	d0,-(sp)
	move.w	(pstatsteam).l,d7
	btst	#2,(SeasonFlags).w
	beq.w	.3
	jsr	(GetPOSlotTeam).l
.3
	jsr	(FormatPlayerNameD7).l
	jsr	(printcur).l
	cmpi.w	#4,(pstatscat).w
	bge.w	.5
	move.w	(pstatsteam).l,d7
	btst	#2,(SeasonFlags).w
	beq.w	.4
	jsr	(GetPOSlotTeam).l
.4
	jsr	(GetGoalieCountD7).l
	sub.w	d0,(sp)
.5
	move.w	#$15,(printx).w
	cmpi.w	#4,(pstatscat).w
	blt.w	.6
	move.w	#$14,(printx).w
.6
	move.w	(sp),d0
	bsr.w	PStatsPrintValue
	beq.w	.10
	move.w	#$19,(printx).w
	cmpi.w	#4,(pstatscat).w
	blt.w	.7
	move.w	#$1A,(printx).w
.7
	move.w	(sp),d0
	bsr.w	PStatsPrintValue
	beq.w	.10
	move.w	#$1D,(printx).w
	cmpi.w	#4,(pstatscat).w
	blt.w	.8
	move.w	#$20,(printx).w
.8
	move.w	(sp),d0
	bsr.w	PStatsPrintValue
	beq.w	.10
	move.w	#$21,(printx).w
	cmpi.w	#4,(pstatscat).w
	blt.w	.9
	move.w	#0,(printx).w
.9
	move.w	(sp),d0
	bsr.w	PStatsPrintValue
.10
	tst.w	(sp)+
.11
	addq.w	#1,(printy).w
	addq.w	#1,d6
	cmp.w	(pstatsrows).w,d6
	blt.w	.0
	movem.l	(sp)+,d0-d7/a0-a6
	rts

PStatsPrintValue					;SeasonPlayoffStats: print stat column pstatscol of player d0
	move.w	d0,-(sp)
	move.w	(pstatscol).l,d0
	asl.w	#2,d0
	movea.l	#PStatsColumns,a0
	movea.l	(a0,d0.w),a0
	move.w	(sp)+,d0
	add.w	d0,d0
	move.w	(a0,d0.w),d0
	move.w	#3,d1
	cmpi.w	#4,(pstatscol).l
	blt.w	.0
	cmpi.w	#6,(pstatscol).l
	beq.w	.0
	move.w	#4,d1
.0
	jsr	(PushNumberWidth).l
	bsr.w	PStatsMark
	addq.w	#1,(pstatscol).l
	cmpi.w	#4,(pstatscol).l
	beq.w	.1
	cmpi.w	#7,(pstatscol).l
.1
	rts

PStatsMark							;SeasonPlayoffStats: print a value, highlighted in the column of the
									;category
	move.w	(printa).w,-(sp)
	move.w	(pstatscat).w,d0
	cmp.w	(pstatscol).l,d0
	bne.w	.0
	jsr	(printsmallz).l
	String	CC_SetAttribute,$05
.0
	jsr	(printcur).l
	move.w	(sp)+,(printa).w
	rts

PStatsPalette						;The palette of PStatsPal to palfadenew+$20
	movem.l	a0-a1,-(sp)
	movea.l	#PStatsPal,a0
	movea.l	#palfadenew+$20,a1
	move.w	#7,d0
.pal
	move.l	(a0)+,(a1)+
	dbf	d0,.pal
	movem.l	(sp)+,a0-a1
	rts

PlayoffMenuScreen					;The playoff menu screen: the playoff tree from save RAM (ReadPassData,
									;ReadPassBits, MakeTree), then the
									;roster menu loop (RosterMenuList); Reset Rosters asks Yes / No
									;(YesNoMenuList) before ClearPlayoffSave
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#$FFFF,(PlayoffMenuTeam).w
	move.w	(GameFlags).w,-(sp)
	bclr	#7,(GameFlags).w
	jsr	(ReadPassData).l
	move.w	(sp)+,(GameFlags).w
	movea.l	#pwddatabuffer,a3
	jsr	(ReadPassBits).l
	move.w	(gamelevel).w,d0
	or.w	(bosgames).w,d0
	beq.w	.0
	move.w	(GameFlags).w,-(sp)
	bclr	#7,(GameFlags).w
	jsr	(MakeTree).l
	move.w	(sp)+,(GameFlags).w
	movea.l	#potree,a0
	move.w	(potreeteam).w,d2
	move.b	(a0,d2.w),d2
	clr.w	(PlayoffMenuTeam).w
	move.b	d2,(PlayoffMenuTeam+1).w
.0
	clr.w	(carddelay).w
	bsr.w	PlayoffMenuInit
	bsr.w	PlayoffMenuSetup
	movea.l	#TransactionsSprites,a0
	jsr	(DrawScreenSprite).l
	jsr	(PStatsPalette).l
	move.w	#$18,(palcount).w
	bclr	#dfng,(disflags).w
.draw
	bsr.w	PlayoffMenuDraw
.frame
	move.w	(Vcount).w,d0
.loop2
	cmp.w	(Vcount).w,d0
	beq.s	.loop2
	jsr	(SetMenuScroll).l
	cmpi.w	#$5460,(carddelay).w
	jsr	(FindHeldMenuPad).l
	jsr	(ProcessInputWithRepeat).l
	tst.w	d1
	beq.w	.1
	clr.w	(carddelay).w
.1
	btst	#7,d1
	bne.w	.3
	btst	#5,d1
	bne.w	.3
	btst	#1,d1
	beq.w	.9
	cmpi.w	#6,(menuitem).w
	beq.s	.frame
	addq.w	#1,(menuitem).w
	bra.s	.draw
.9
	btst	#0,d1
	beq.w	.2
	tst.w	(menuitem).w
	beq.s	.frame
	subq.w	#1,(menuitem).w
	bra.s	.draw
.2
	bra.s	.draw
.3
	cmpi.l	#RosterMenuList,(menulist).l
	beq.w	.5
	tst.w	(menuitem).w
	bne.w	.4
	bsr.w	ClearPlayoffSave
.4
	move.l	#$772,(NextScreenPtr).w
	move.l	#RosterMenuList,(menulist).l
	clr.w	(menuitem).w
	clr.w	(menuitem+2).w
	move.w	#6,(menurows).w
	move.w	#$D,(menux).w
	move.w	#6,(menuy).w
	jsr	(printsmallz).l
	String	CC_SetMap,$01,CC_SetX,$0C,CC_SetY,$0B
	move.w	#$11,d0
	move.w	#$D,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	bsr.w	PlayoffMenuInit
	bra.w	.draw
.5
	movea.l	#PlayoffMenuRoutines,a0
	move.w	(menuitem).w,d0
	asl.w	#2,d0
	move.l	(a0,d0.w),(NextScreenPtr).w
	cmpi.l	#SeasonMenuScreen,(NextScreenPtr).w
	beq.w	.7
	cmpi.l	#ClearPlayoffSave,(NextScreenPtr).l
	bne.w	.6
	move.l	#YesNoMenuList,(menulist).l
	clr.w	(menuitem).w
	clr.w	(menuitem+2).w
	move.w	#2,(menurows).w
	move.w	#$12,(menux).w
	move.w	#$F,(menuy).w
	jsr	(printsmallz).l
	String	CC_SetMap,$01,CC_SetX,$0C,CC_SetY,$0B
	move.w	#$11,d0
	move.w	#$D,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	jsr	(printsmallz).l
	String	CC_SetAttribute,$07,CC_SetFont,$00,CC_SetX,$0E,CC_SetY,$0B,'Reset Rosters'
	bra.w	.draw
.6
	cmpi.l	#$772,(NextScreenPtr).w
	beq.w	.draw
	movea.l	(NextScreenPtr).w,a0
	bset	#6,(sflags11).w
	jsr	(a0)
	bclr	#6,(sflags11).w
	bra.w	.0
.7
	movem.l	(sp)+,d0-d7/a0-a6
	rts

PlayoffMenuRoutines					;PlayoffMenuScreen: the routine of each menu item
	dc.l	TradePlayers,MenuCreatePlayers,MenuSignFreeAgents,MenuReleasePlayer,ClearPlayoffSave,TeamRosterScreen
	dc.l	SeasonMenuScreen

PlayoffMenuDraw						;PlayoffMenuScreen: draw the menu (PrintMenuList2)
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(printz).l
	String	CC_Font1Pal3Pri,$00,$00
	jsr	(PrintMenuList2).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

PlayoffMenuInit						;PlayoffMenuScreen: menulist = RosterMenuList, item 0
	move.l	#RosterMenuList,(menulist).l
.0
	clr.w	(menuitem).w
	clr.w	(menuitem+2).w
	move.w	#7,(menurows).w
	move.w	#$D,(menux).w
	move.w	#$B,(menuy).w
	rts

PlayoffMenuSetup					;PlayoffMenuScreen: vram and the screen bitmaps
	bset	#5,(sflags12).w
	move.l	#VBlank_Menus,(VBint).w
	bclr	#dfok,(disflags).w
	bset	#dfng,(disflags).w
	bclr	#df32c,(disflags).w
	move.w	#0,(VSCRLPM).w
	move.w	#$B400,(VSPRITES).w
	move.w	#$B800,(VmMAP3).w
	move.w	#5,(Map3col).w
	move.w	#$C000,(VmMAP2).w
	move.w	#6,(Map2col).w
	move.w	#$E000,(VmMAP1).w
	move.w	#6,(Map1col).w
	move.w	#0,d0
	bset	#5,(disflags).w
	jsr	(setVram).l
	bclr	#5,(disflags).w
	jsr	(orjoy).l
	move.w	#1,d4
	movea.l	#TransactionsSprites,a1
	jsr	(LoadScreenSprite).l
	move.w	d4,(smallfontchars).w
	movea.l	#RosterFont+8,a2
	jsr	(DecompressGraphicsPlain).l
	move.w	d4,(smallfont2chars).w
	movea.l	#SmallFontMap2+8,a2
	jsr	(DecompressGraphicsPlain).l
	move.l	#RosterFont,(smallfontptr).w
	move.w	d4,(printbigchars).w
	movea.l	#BigFontMap2+8,a2
	jsr	(DecompressGraphicsPlain).l
	bclr	#2,(sflags11).w
	jsr	(printsmallz).l
	String	CC_SetMap,$01,CC_SetX,$00,CC_SetY
	moveq	#$28,d0
	moveq	#$1C,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	jsr	(printz).l
	String	CC_Font1Pri,$00,$00
	movea.l	#TransactionsBgMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	moveq	#$28,d2
	moveq	#$1C,d3
	moveq	#$C,d5
	jsr	(dobitmap).l
	jsr	(printz).l
	String	CC_Font1Pri,$0B,$01
	movea.l	#TransactionsTitleMap,a0
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
	jsr	(printz).l
	String	CC_Font2,$00,$00
	movea.l	#ControllerBgMap,a0
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
	move	#$2500,sr
	rts

ClearPlayoffSave					;Clear the saved playoffs in save RAM ($E68 and $DB4)
	bset	#6,(GameFlags).w
	move.l	#$E68,d0
	moveq	#$66,d1
	jsr	(ClearSRAMBytes).l
	move.l	#$DB4,d0
	moveq	#$32,d1
	jsr	(ClearSRAMBytes).l
	movem.l	d0/a0,-(sp)
	move.w	#$13,d0
	movea.l	#$201B68,a0
.0
	move.b	#$80,1(a0)
	addq.w	#4,a0
	dbf	d0,.0
	movem.l	(sp)+,d0/a0
	movem.l	a0-a2,-(sp)
	movea.l	#$201B68,a1
	clr.w	d1
	clr.w	d0
	move.b	($202A9D).l,d0
	bra.w	.2
.1
	move.b	d1,3(a1)
	move.b	#$1E,1(a1)
	addq.b	#1,($201BB9).l
	addq.l	#4,a1
	addq.w	#1,d1
.2
	dbf	d0,.1
	move.b	#$80,1(a1)
	move.b	#0,3(a1)
	movem.l	(sp)+,a0-a2
	jsr	(DefaultRosters).l
	move.l	#$1550,d0
	move.l	#$86E,d1
	movea.l	#$FFFF1550,a0
	jsr	(WriteSRAM).l
	jsr	(ClearRosterSave).l
	bclr	#6,(GameFlags).w
	jsr	(MakeSRAMChecksum).l
	rts
