;	The playoff tree screen.

PlayoffScreen	;Bring up the playoff screen if in playoff mode (OptPlayMode nonzero): the tree, the series scores and
	;the team blocks, until start
	tst.w	(OptPlayMode).w
	beq.w	rtsPlayoffScreen
	btst	#7,(GameFlags).w
	beq.w	.1
	btst	#3,(SeasonFlags).w
	bne.w	.1
	cmpi.w	#4,(gamelevel).w
	bne.w	.1
	move.b	(potree+$1C).w,d0
	move.b	(potree+$1D).w,d1
	move.b	d0,d2
	cmp.b	(dword_FFDD82+2).w,d2
	bne.w	.0
	move.b	d1,d2
.0
	move.b	d2,(potree+$1E).w
.1
	jsr	(forceblack).l
	move.l	#SeasonMenuScreen,(NextScreenPtr).w
	move.w	(VSCRLPM).w,d0
	jsr	(Vmaddr).l
	clr.w	d0
	move.w	d0,(a0)
	move.w	d0,2(a0)
	move.l	#VBlank_Playoff,(vbint).l
	bclr	#1,(disflags).w
	move.w	#0,(VSCRLPM).w
	move.w	#$BC00,(VSPRITES).w
	move.w	#$B000,(VmMap3).w
	move.w	#6,(Map3col1).w
	move.w	#$C000,(VmMap2).w
	move.w	#7,(Map2col1).w
	move.w	#$E000,(VmMap1).w
	move.w	#7,(Map1col1).w
	move.w	#0,d0
	jsr	(setVram).l
	jsr	(printz).l
	String	$FF,$00,$00
	move.l	#$80,d0
	moveq	#$1C,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	move.w	#2,d4
	move.w	#$19,d1
	clr.w	d2
	movea.l	#setupvalues,a0
	movea.l	#TeamBlockPtrs,a1
.2
	move.w	d4,(a0)+
	move.w	d2,d0
	asl.w	#2,d0
	movea.l	(a1,d0.w),a2
	addq.w	#8,a2
	jsr	(DecompressGraphicsPlain).l
	addq.w	#1,d2
	dbf	d1,.2
	move.w	d4,(smallfontchars).w
	movea.l	#RosterFont+8,a2
	jsr	(DecompressGraphicsPlain).l
	move.l	#RosterFont,(smallfontptr).w
	movea.l	#PlayoffTreeMap+8,a2
	jsr	(printz).l
	String	$FF,$00,$00
	movea.l	#PlayoffTreeMap,a0
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
	move.w	d4,(ExtraChars).w
	movea.l	#PlayoffTeamFrameMap+8,a2
	jsr	(DecompressGraphicsPlain).l
	jsr	(printz).l
	String	$FE,$00,$00
	movea.l	#PlayoffTreeBgMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	move.w	(a1),d2
	clr.w	d0
	clr.w	d1
	move.w	2(a1),d3
	moveq	#1,d5
	jsr	(dobitmap).l
	movea.l	#VDP_CTRL,a0
	move.w	#$9200,(a0)
	movea.l	#potree,a1
	movea.l	#PlayoffTreeSetup,a0
	move.w	(gamelevel).w,d0
	asl.w	#1,d0
	adda.w	(a0,d0.w),a0
	clr.w	d4
	move.b	(a0)+,d4
.3
	jsr	(printz).l
	String	$BF,$00,$00
	move.b	(a0)+,(printx+1).w
	move.b	(a0)+,(printy+1).w
	clr.w	d1
	move.b	(a1)+,d1
	add.w	d1,d1
	bsr.w	DrawTeamBlocks
	dbf	d4,.3
	clr.w	d4
	move.b	(a0)+,d4
.4
	jsr	(printz).l
	String	$BF,$00,$02
	move.b	(a0)+,(printx+1).w
	clr.w	d0
	move.b	(a0)+,d0
	bsr.w	DrawTreeArrow
	dbf	d4,.4
	jsr	(printz).l
	String	$8F,$00,$00
	cmpi.w	#7,(bosgames).w
	beq.w	.6
	clr.w	d4
	move.b	(a0)+,d4
	bmi.w	.6
	movea.w	#(gsstruct-M68K_RAM),a2
.5
	move.b	(a0)+,(printx+1).w
	move.b	(a0)+,(printy+1).w
	bsr.w	PrintSeriesScore
	adda.w	#$10,a2
	dbf	d4,.5
.6
	tst.w	(gamelevel).w
	beq.w	*+4
.7
	move.w	#$18,(palcount).w
	movem.l	d0/a0,-(sp)
	movea.l	#PlayoffScrollStart,a0
	move.w	(gamelevel).w,d0
	add.w	d0,d0
	move.w	(a0,d0.w),d0
	cmpi.w	#$3C,(userblockx).w
	blt.w	.8
	neg.w	d0
.8
	move.w	d0,(DispAttribCtr).w
	movem.l	(sp)+,d0/a0
	move	#$2500,sr
	clr.w	d0
	clr.w	d4
	clr.w	(PlayerScrollCtr).w
	bsr.w	UpdatePlayoffScroll
.9
	bsr.w	PlayoffScreen_waitvsync
	movea.l	#rtss2,a0
	bsr.w	HandlePlayoffInput
	bra.s	.9

HandlePlayoffInput	;Read the pads: start leaves PlayoffScreen, right / left scroll the tree
	jsr	(FindHeldMenuPad).l
	btst	#7,d3
	bne.w	PlayoffScreenExit
	btst	#3,d3
	beq.w	.nr
	move.w	#$FFFC,(PlayerScrollCtr).w
.nr
	btst	#2,d3
	beq.w	UpdatePlayoffScroll
	move.w	#4,(PlayerScrollCtr).w

UpdatePlayoffScroll	;Move the tree one step and stop on a page boundary
	move.w	(PlayerScrollCtr).w,d0
	beq.w	rtsPlayoffScreen
	add.w	(DispAttribCtr).w,d0
	move.w	(gamelevel).w,d1
	cmp.w	#3,d1
	bls.w	.0
	moveq	#3,d1
.0
	move.w	#3,d1
	movem.l	a0,-(sp)
	movea.l	#PlayoffScrollStops,a0
	add.w	d1,d1
	move.w	(a0,d1.w),d1
	move.w	d1,(jerseynum).w
	movem.l	(sp)+,a0
	cmp.w	d1,d0
	bgt.w	rtsPlayoffScreen
	neg.w	d1
	cmp.w	d1,d0
	blt.w	rtsPlayoffScreen
	move.w	d0,(DispAttribCtr).w
	clr.w	(word_FFB8C4).w
	move.w	d0,d1
	addi.w	#$100,d1
	cmp.w	#$40,d1
	blt.w	.nox
	cmp.w	#$200,d1
	bgt.w	.nox
	move.w	d1,(word_FFB8C4).w
.nox
	ext.l	d0
	movea.l	#PlayoffScrollStops,a0
.1
	move.w	(a0)+,d0
	cmp.w	(DispAttribCtr).w,d0
	beq.w	.2
	neg.w	d0
	cmp.w	(DispAttribCtr).w,d0
	beq.w	.2
	cmpa.l	#PlayoffScrollStopsEnd,a0
	blt.s	.1
	rts
.2
	clr.w	(PlayerScrollCtr).w
	rts

PlayoffScreenExit	;Drop HandlePlayoffInput's return address and return from PlayoffScreen
	jsr	(forceblack).l
	addq.w	#4,sp

rtsPlayoffScreen	;Shared rts of PlayoffScreen and UpdatePlayoffScroll
	rts

PlayoffScreen_waitvsync	;Wait for the next frame; flash a colour each time palcount runs out
	tst.w	(palcount).w
	bpl.w	.wait
	movem.l	d0-d1/a0-a1,-(sp)
	movea.l	#palfadenew+$24,a0
	move.w	#$C,d1
	move.w	(a0),d0
.0
	move.w	2(a0),-(sp)
	move.w	d0,2(a0)
	move.w	(sp)+,d0
	addq.l	#2,a0
	dbf	d1,.0
	move.w	(palfadenew+$3E).w,(palfadenew+$24).w
	movem.l	(sp)+,d0-d1/a0-a1
	move.w	#3,(palcount).w
.wait
	move.w	(vcount).w,d0
	cmp.w	(oldvcount).w,d0
	beq.s	.wait
	move.w	d0,(oldvcount).w
	rts

PrintSeriesScore	;Print best of 7 wins "t-b" for game struct a2 at printx / printy
	movea.w	#(mesarea-M68K_RAM),a1
	move.w	#6,(a1)+
	move.w	4(a2),d0
	addi.w	#$30,d0
	move.b	d0,(a1)+
	move.b	#$2D,(a1)+
	move.w	6(a2),d0
	addi.w	#$30,d0
	move.b	d0,(a1)+
	clr.b	(a1)+
	movea.w	#(mesarea-M68K_RAM),a1
	jmp	printcur

DrawTreeArrow	;An rts: no tree arrows
	rts

DrawTeamBlocks	;Draw team block d1 at printx / printy; the user's team gets a frame
	movem.l	d0-d7/a0-a3,-(sp)
	movea.l	#potree,a0
	move.w	(potreeteam).w,d0
	move.b	(a0,d0.w),d0
	add.b	d0,d0
	cmp.b	d0,d1
	bne.w	.0
	move.w	(printx).w,(userblockx).w
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(printx).w,-(sp)
	move.w	(printy).w,-(sp)
	subq.w	#1,(printx).w
	subq.w	#1,(printy).w
	move.w	(ExtraChars).w,d4
	jsr	(printsmallz).l
	String	$FE,$00,$FF,$02
	movea.l	#PlayoffTeamFrameMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	movea.l	#$772,a2
	clr.w	d0
	clr.w	d1
	move.w	(a1),d2
	move.w	2(a1),d3
	moveq	#2,d5
	jsr	(dobitmap).l
	move.w	(sp)+,(printy).w
	move.w	(sp)+,(printx).w
	jsr	(printsmallz).l
	String	$FE,$04,$FF,$01
	movem.l	(sp)+,d0-d7/a0-a6
.0
	movea.l	#setupvalues,a0
	move.w	(a0,d1.w),d4
	add.w	d1,d1
	movea.l	#TeamBlockPtrs,a0
	movea.l	(a0,d1.w),a0
	asr.w	#1,d1
	movea.l	a0,a1
	adda.l	(a0),a0
	adda.l	4(a1),a1
	movea.w	#$772,a2
	clr.w	d0
	clr.w	d1
	move.w	(a1),d2
	moveq	#2,d3
	move.w	#$C,d5
	jsr	(dobitmap).l
	movem.l	(sp)+,d0-d7/a0-a3
	rts

VBlank_Playoff	;The PlayoffScreen vblank handler (vbint)
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$FF,$FE,$08,$38,$00,$02,$BF,$B2,$66,$00,$00,$20,$30,$38
	dc.b	$B0,$00,$4E,$B9,$00,$01,$B6,$78,$30,$3C,$FE,$C0,$D0,$78,$D0,$30
	dc.b	$30,$80,$31,$40,$00,$02,$4E,$B9,$00,$01,$AF,$D6,$52,$78,$B0,$52
	dc.b	$4E,$B9,$00,$02,$44,$86,$4C,$DF,$7F,$FF,$4E,$73,$00,$0A,$50,$6C
	dc.b	$61,$79,$6F,$66,$66,$73,$00,$10,$51,$75,$61,$72,$74,$65,$72,$66
	dc.b	$69,$6E,$61,$6C,$73,$00,$00,$0C,$53,$65,$6D,$69,$66,$69,$6E,$61
	dc.b	$6C,$73,$00,$08,$46,$69,$6E,$61,$6C,$73,$00,$0C,$43,$68,$61,$6D
	dc.b	$70,$69,$6F,$6E,$73,$00

PlayoffTreeSetup	;Playoff tree layout by gamelevel. Used by PlayoffScreen
	dc.b	$00,$0A,$00,$41,$00,$84,$00,$CF,$01,$1C,$0F,$01,$02,$01,$04,$01
	dc.b	$08,$01,$0A,$01,$0E,$01,$10,$01,$14,$01,$16,$66,$02,$66,$04,$66
	dc.b	$08,$66,$0A,$66,$0E,$66,$10,$66,$14,$66,$16,$01,$39,$00,$45,$0A
	dc.b	$07,$07,$06,$07,$0C,$07,$12,$07,$18,$6C,$06,$6C,$0C,$6C,$12,$6C
	dc.b	$18,$17,$01,$02,$01,$04,$01,$08,$01,$0A,$01,$0E,$01,$10,$01,$14
	dc.b	$01,$16,$66,$02,$66,$04,$66,$08,$66,$0A,$66,$0E,$66,$10,$66,$14
	dc.b	$66,$16,$12,$05,$12,$07,$12,$11,$12,$13,$55,$05,$55,$07,$55,$11
	dc.b	$55,$13,$03,$2B,$00,$39,$02,$45,$08,$53,$0A,$03,$18,$09,$18,$15
	dc.b	$5B,$09,$5B,$15,$1B,$01,$02,$01,$04,$01,$08,$01,$0A,$01,$0E,$01
	dc.b	$10,$01,$14,$01,$16,$66,$02,$66,$04,$66,$08,$66,$0A,$66,$0E,$66
	dc.b	$10,$66,$14,$66,$16,$12,$05,$12,$07,$12,$11,$12,$13,$55,$05,$55
	dc.b	$07,$55,$11,$55,$13,$21,$0B,$21,$0D,$47,$0B,$47,$0D,$05,$1D,$00
	dc.b	$2B,$02,$39,$04,$45,$06,$53,$08,$61,$0A,$01,$27,$0F,$4D,$0F,$1D
	dc.b	$01,$02,$01,$04,$01,$08,$01,$0A,$01,$0E,$01,$10,$01,$14,$01,$16
	dc.b	$66,$02,$66,$04,$66,$08,$66,$0A,$66,$0E,$66,$10,$66,$14,$66,$16
	dc.b	$12,$05,$12,$07,$12,$11,$12,$13,$55,$05,$55,$07,$55,$11,$55,$13
	dc.b	$21,$0B,$21,$0D,$47,$0B,$47,$0D,$29,$18,$40,$18,$05,$0F,$00,$1D
	dc.b	$02,$2B,$04,$53,$06,$61,$08,$6F,$0A,$00,$3B,$1A,$1E,$01,$02,$01
	dc.b	$04,$01,$08,$01,$0A,$01,$0E,$01,$10,$01,$14,$01,$16,$66,$02,$66
	dc.b	$04,$66,$08,$66,$0A,$66,$0E,$66,$10,$66,$14,$66,$16,$12,$05,$12
	dc.b	$07,$12,$11,$12,$13,$55,$05,$55,$07,$55,$11,$55,$13,$21,$0B,$21
	dc.b	$0D,$47,$0B,$47,$0D,$29,$18,$40,$18,$34,$11,$05,$0F,$00,$1D,$02
	dc.b	$2B,$04,$53,$06,$61,$08,$6F,$0A,$FF,$FF

PlayoffScrollStops	;Playoff tree scroll page positions; the last entry is the scroll limit
	dc.b	$00,$00,$00,$88,$00,$88,$01,$40

PlayoffScrollStopsEnd	;The end of PlayoffScrollStops
	dc.b	$01,$40

PlayoffScrollStart	;The start scroll of the playoff tree by gamelevel (negated for the other side)
	dc.b	$01,$40,$01,$40,$00,$88,$00,$00,$00,$00

