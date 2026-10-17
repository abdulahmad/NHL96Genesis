;	The season stats screen and the playoff menu.

SetSframe	;Draw one sprite frame. a0 = framelist, d0/d1 = x/y cords, d2 = frame, d3 = start char a6 = Satt pointer, d6 =
	;link counter.
	cmp.w	#$40,d6	;MaxSprites
	bge.w	.exit
	movem.l	d0-d5/a0,-(sp)
	adda.l	4(a0),a0
	add.w	d2,d2
	move.w	2(a0,d2.w),d4
	sub.w	(a0,d2.w),d4
	lsr.w	#3,d4
	subq.w	#1,d4	;number of sprites in frame
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
	dc.b	$48,$E7,$FF,$FE,$42,$78,$D3,$12,$61,$00,$07,$2A,$20,$7C,$00,$18
	dc.b	$88,$2C,$4E,$B9,$00,$01,$21,$8A,$4E,$B9,$00,$1D,$BB,$92,$31,$FC
	dc.b	$00,$18,$BD,$3C,$08,$B8,$00,$02,$BF,$B2,$42,$78,$BF,$58,$31,$FC
	dc.b	$00,$0D,$BF,$5C,$31,$FC,$00,$0C,$BF,$5A,$42,$78,$BF,$56,$61,$00
	dc.b	$02,$88,$30,$38,$BF,$60,$B0,$7C,$00,$14,$6F,$00,$00,$06,$30,$3C
	dc.b	$00,$14,$53,$40,$31,$C0,$BF,$5E,$30,$38,$B0,$52,$B0,$78,$B0,$52
	dc.b	$67,$FA,$4E,$B9,$00,$01,$26,$40,$61,$00,$01,$26,$30,$38,$B0,$52
	dc.b	$B0,$78,$B0,$52,$67,$FA,$4E,$B9,$00,$01,$26,$40,$08,$F8,$00,$02
	dc.b	$BF,$B2,$61,$00,$05,$06,$46,$FC,$25,$00,$61,$00,$00,$AE,$08,$B8
	dc.b	$00,$02,$BF,$B2,$61,$00,$01,$48,$4A,$41,$67,$00,$00,$8A,$08,$01
	dc.b	$00,$07,$66,$00,$00,$88,$08,$01,$00,$02,$67,$00,$00,$24,$61,$00
	dc.b	$01,$B4,$53,$78,$BF,$56,$6A,$00,$00,$0A,$30,$3C,$00,$03,$31,$C0
	dc.b	$BF,$56,$42,$78,$BF,$58,$31,$FC,$00,$0C,$BF,$5A,$60,$00,$FF,$70
	dc.b	$08,$01,$00,$00,$67,$00,$00,$14,$4A,$78,$BF,$58,$67,$B6,$53,$78
	dc.b	$BF,$58,$53,$78,$BF,$5A,$60,$00,$FF,$70,$08,$01,$00,$01,$67,$00
	dc.b	$00,$18,$30,$38,$BF,$5A,$B0,$78,$BF,$5E,$6C,$98,$52,$78,$BF,$58
	dc.b	$52,$78,$BF,$5A,$60,$00,$FF,$52,$08,$01,$00,$03,$67,$86,$61,$00
	dc.b	$01,$54,$52,$78,$BF,$56,$30,$3C,$00,$03,$B0,$78,$BF,$56,$6C,$A2
	dc.b	$42,$78,$BF,$56,$60,$9C,$4E,$F9,$00,$02,$17,$4A,$21,$FC,$00,$01
	dc.b	$22,$A4,$DD,$AC,$4C,$DF,$7F,$FF,$4E,$75

LeadersScrollArrows	;League Leaders: draw up/down scroll arrows depending on list position.
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$FF,$FE,$4A,$78,$BF,$58,$67,$00,$00,$12,$4E,$B9,$00,$01
	dc.b	$BC,$72,$00,$06,$8F,$02,$0B,$7B,$60,$00,$00,$0E,$4E,$B9,$00,$01
	dc.b	$BC,$72,$00,$06,$8F,$02,$0B,$20,$32,$38,$BF,$5A,$B2,$78,$BF,$5E
	dc.b	$6C,$00,$00,$12,$4E,$B9,$00,$01,$BC,$72,$00,$06,$8F,$02,$17,$7D
	dc.b	$60,$00,$00,$0E,$4E,$B9,$00,$01,$BC,$72,$00,$06,$8F,$02,$17,$20
	dc.b	$4C,$DF,$7F,$FF,$4E,$75,$48,$E7,$FF,$FE,$4E,$B9,$00,$01,$BB,$8E
	dc.b	$00,$06,$BF,$1E,$08,$00,$30,$38,$BF,$56,$22,$7C,$00,$1D,$A8,$D8
	dc.b	$4E,$B9,$00,$01,$D7,$E2,$4C,$DF,$7F,$FF,$4E,$75,$00,$0A,$47,$6F
	dc.b	$61,$6C,$73,$20,$20,$00,$00,$0A,$41,$73,$73,$69,$73,$74,$73,$00
	dc.b	$00,$0A,$50,$6F,$69,$6E,$74,$73,$20,$00,$00,$0A,$20,$20,$20,$20
	dc.b	$47,$41,$41,$00,$2C,$3C,$00,$00,$54,$60,$3C,$3C,$00,$64,$32,$38
	dc.b	$B0,$52,$92,$78,$B0,$54,$67,$F2,$31,$F8,$B0,$52,$B0,$54,$4E,$B9
	dc.b	$00,$01,$26,$40,$4E,$B9,$00,$01,$B3,$48,$4E,$B9,$00,$01,$B3,$20
	dc.b	$4A,$41,$67,$00,$00,$06,$60,$00,$00,$50,$4E,$B9,$00,$01,$B3,$60
	dc.b	$4E,$B9,$00,$01,$B3,$20,$4A,$41,$67,$00,$00,$06,$60,$00,$00,$3A
	dc.b	$4A,$78,$D2,$50,$67,$00,$00,$2E,$4E,$B9,$00,$01,$B3,$78,$4E,$B9
	dc.b	$00,$01,$B3,$20,$4A,$41,$67,$00,$00,$06,$60,$00,$00,$1C,$4E,$B9
	dc.b	$00,$01,$B3,$90,$4E,$B9,$00,$01,$B3,$20,$4A,$41,$67,$00,$00,$06
	dc.b	$60,$00,$00,$06,$51,$CE,$FF,$84,$4E,$75,$48,$E7,$FF,$FE,$30,$3C
	dc.b	$00,$24,$32,$3C,$00,$0D,$34,$3C,$07,$FF,$00,$42,$80,$00,$4E,$B9
	dc.b	$00,$01,$BB,$8E,$00,$06,$BF,$02,$0B,$00,$4E,$B9,$00,$01,$B9,$76
	dc.b	$4E,$B9,$00,$01,$BE,$D6,$00,$0E,$F8,$04,$01,$1E,$08,$20,$20,$20
	dc.b	$20,$20,$20,$20,$4E,$B9,$00,$01,$BE,$D6,$00,$1E,$F8,$04,$01,$09
	dc.b	$05,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	dc.b	$20,$20,$20,$20,$20,$20,$20,$00,$4C,$DF,$7F,$FF,$4E,$75

BuildPlayerLeaders	;League leaders: build and sort the list of category pstatscat through PlayerLeaderJumps
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(pstatscat).w,d0
	asl.w	#2,d0
	movea.l	#PlayerLeaderJumps,a0
	movea.l	(a0,d0.w),a0
	jmp	(a0)
	dc.b	$4C,$DF,$7F,$FF,$4E,$75

PlayerLeaderJumps	;BuildPlayerLeaders handler per category: goals, assists, points, goals against average
	dc.b	$00,$1D,$AA,$56,$00,$1D,$AA,$88,$00,$1D,$AA,$BA,$00,$1D,$AA,$16
	dc.b	$22,$3C,$00,$00,$59,$8C,$74,$0E,$76,$03,$28,$3C,$00,$00,$5D,$D0
	dc.b	$7C,$0D,$08,$38,$00,$02,$DD,$80,$67,$00,$00,$14,$22,$3C,$00,$00
	dc.b	$32,$68,$74,$0E,$76,$03,$28,$3C,$00,$00,$35,$08,$7C,$0D,$2A,$7C
	dc.b	$00,$00,$98,$EC,$08,$F8,$00,$01,$C3,$40,$61,$00,$00,$9A,$60,$AA
	dc.b	$22,$3C,$00,$00,$02,$68,$74,$0C,$76,$18,$08,$38,$00,$02,$DD,$80
	dc.b	$67,$00,$00,$0C,$22,$3C,$00,$00,$04,$48,$74,$0A,$76,$18,$2A,$7C
	dc.b	$00,$00,$97,$A0,$08,$B8,$00,$01,$C3,$40,$61,$00,$00,$E6,$60,$00
	dc.b	$FF,$7A,$22,$3C,$00,$00,$1F,$A8,$74,$0C,$76,$18,$08,$38,$00,$02
	dc.b	$DD,$80,$67,$00,$00,$0C,$22,$3C,$00,$00,$13,$48,$74,$0A,$76,$18
	dc.b	$2A,$7C,$00,$00,$97,$A0,$08,$B8,$00,$01,$C3,$40,$61,$00,$00,$B4
	dc.b	$60,$00,$FF,$48,$22,$3C,$00,$00,$02,$68,$74,$0C,$76,$18,$08,$38
	dc.b	$00,$02,$DD,$80,$67,$00,$00,$0C,$22,$3C,$00,$00,$04,$48,$74,$0A
	dc.b	$76,$18,$2A,$7C,$00,$00,$98,$0E,$08,$B8,$00,$01,$C3,$40,$61,$00
	dc.b	$00,$82,$60,$00,$FF,$16,$20,$7C,$FF,$FF,$19,$3A,$24,$7C,$FF,$FF
	dc.b	$BF,$60,$26,$7C,$FF,$FF,$13,$88,$42,$47,$42,$52,$42,$45,$48,$E7
	dc.b	$4D,$00,$08,$38,$00,$02,$DD,$80,$67,$00,$00,$0E,$4E,$B9,$00,$01
	dc.b	$43,$BC,$3A,$07,$CA,$FC,$00,$1B,$4E,$B9,$00,$01,$57,$74,$36,$00
	dc.b	$4E,$95,$4C,$DF,$00,$B2,$06,$81,$00,$00,$00,$2A,$06,$84,$00,$00
	dc.b	$00,$27,$06,$45,$00,$1B,$52,$47,$08,$38,$00,$02,$DD,$80,$67,$00
	dc.b	$00,$0C,$BE,$7C,$00,$10,$6D,$B6,$60,$00,$00,$08,$BE,$7C,$00,$1A
	dc.b	$6D,$AC,$36,$38,$BF,$60,$67,$00,$00,$FA,$53,$43,$42,$44,$60,$00
	dc.b	$00,$86,$20,$7C,$FF,$FF,$19,$3A,$24,$7C,$FF,$FF,$BF,$60,$26,$7C
	dc.b	$FF,$FF,$13,$88,$42,$47,$42,$52,$42,$45,$48,$A7,$05,$00,$08,$38
	dc.b	$00,$02,$DD,$80,$67,$00,$00,$0E,$4E,$B9,$00,$01,$43,$BC,$3A,$07
	dc.b	$CA,$FC,$00,$1B,$4E,$B9,$00,$01,$57,$B2,$31,$C0,$DD,$C0,$4E,$B9
	dc.b	$00,$01,$57,$74,$91,$78,$DD,$C0,$04,$78,$00,$18,$DD,$C0,$44,$78
	dc.b	$DD,$C0,$DA,$40,$4E,$95,$4C,$9F,$00,$A0,$06,$45,$00,$1B,$52,$47
	dc.b	$08,$38,$00,$02,$DD,$80,$67,$00,$00,$0C,$BE,$7C,$00,$10,$6D,$AA
	dc.b	$60,$00,$00,$08,$BE,$7C,$00,$1A,$6D,$A0,$36,$38,$BF,$60,$67,$00
	dc.b	$00,$72,$53,$43,$42,$44,$22,$7C,$FF,$FF,$19,$3A,$20,$7C,$FF,$FF
	dc.b	$13,$88,$08,$38,$00,$01,$C3,$40,$66,$00,$00,$5A,$42,$40,$42,$78
	dc.b	$BF,$46,$34,$38,$BF,$60,$67,$00,$00,$4A,$55,$42,$67,$00,$00,$44
	dc.b	$6B,$00,$00,$40,$3A,$31,$00,$00,$3C,$31,$00,$02,$BC,$45,$6F,$00
	dc.b	$00,$26,$50,$F8,$BF,$46,$3F,$31,$00,$00,$3F,$31,$00,$02,$33,$9F
	dc.b	$00,$00,$33,$9F,$00,$02,$3F,$30,$00,$00,$3F,$30,$00,$02,$31,$9F
	dc.b	$00,$00,$31,$9F,$00,$02,$54,$40,$51,$CA,$FF,$CA,$4A,$78,$BF,$46
	dc.b	$66,$AA,$4E,$75

SortValuesUp	;Bubble sort the values at LeaderValues / players at LeaderPlayers ascending.
	;Code the listing does not decode: kept as bytes
	dc.b	$42,$40,$42,$78,$BF,$46,$34,$38,$BF,$60,$67,$F2,$55,$42,$67,$EE
	dc.b	$6B,$EC,$3A,$31,$00,$00,$3C,$31,$00,$02,$BC,$45,$6C,$00,$00,$26
	dc.b	$50,$F8,$BF,$46,$3F,$31,$00,$00,$3F,$31,$00,$02,$33,$9F,$00,$00
	dc.b	$33,$9F,$00,$02,$3F,$30,$00,$00,$3F,$30,$00,$02,$31,$9F,$00,$00
	dc.b	$31,$9F,$00,$02,$54,$40,$51,$CA,$FF,$CA,$4A,$78,$BF,$46,$66,$B0
	dc.b	$4E,$75,$4E,$B9,$00,$01,$BB,$8E,$00,$06,$8F,$00,$00,$00,$42,$46
	dc.b	$2A,$7C,$FF,$FF,$19,$3A,$31,$FC,$00,$0B,$B0,$42,$31,$FC,$00,$04
	dc.b	$B0,$40,$22,$7C,$00,$1D,$AE,$32,$4E,$B9,$00,$01,$BC,$84,$30,$06
	dc.b	$D0,$78,$BF,$58,$B0,$78,$BF,$60,$6D,$00,$00,$18,$30,$06,$D0,$78
	dc.b	$BF,$58,$B0,$78,$BF,$5E,$6C,$00,$01,$2C,$31,$C0,$BF,$5E,$60,$00
	dc.b	$01,$24,$31,$FC,$00,$04,$B0,$40,$30,$06,$D0,$78,$BF,$58,$3F,$00
	dc.b	$52,$40,$32,$3C,$00,$02,$4E,$B9,$00,$01,$BE,$1C,$4E,$B9,$00,$01
	dc.b	$BC,$84,$31,$FC,$00,$07,$B0,$40,$20,$7C,$FF,$FF,$13,$88,$30,$06
	dc.b	$D0,$78,$BF,$58,$D0,$40,$30,$30,$00,$00,$48,$C0,$80,$FC,$00,$1B
	dc.b	$3E,$00,$48,$40,$4A,$5F,$66,$00,$00,$48,$3F,$38,$B0,$40,$3F,$38
	dc.b	$B0,$42,$3F,$38,$B0,$44,$3F,$38,$B0,$46,$4E,$B9,$00,$01,$01,$6A
	dc.b	$4E,$B9,$00,$01,$BB,$8E,$00,$06,$BF,$14,$05,$00,$3F,$00,$30,$11
	dc.b	$55,$40,$E2,$40,$91,$78,$B0,$40,$4E,$B9,$00,$01,$BE,$EC,$30,$1F
	dc.b	$31,$DF,$B0,$46,$31,$DF,$B0,$44,$31,$DF,$B0,$42,$31,$DF,$B0,$40
	dc.b	$4E,$B9,$00,$01,$01,$7A,$4E,$B9,$00,$01,$BC,$84,$31,$FC,$00,$19
	dc.b	$B0,$40,$22,$7C,$00,$00,$07,$7E,$30,$07,$E5,$40,$22,$71,$00,$00
	dc.b	$D2,$E9,$00,$04,$D2,$D1,$4E,$B9,$00,$01,$BC,$84,$31,$FC,$00,$20
	dc.b	$B0,$40,$20,$7C,$FF,$FF,$19,$3A,$30,$06,$D0,$78,$BF,$58,$D0,$40
	dc.b	$30,$30,$00,$00,$0C,$78,$00,$03,$BF,$56,$66,$00,$00,$38,$48,$C0
	dc.b	$80,$FC,$00,$64,$48,$40,$3F,$00,$48,$40,$32,$3C,$00,$03,$4E,$B9
	dc.b	$00,$01,$BE,$1C,$4E,$B9,$00,$01,$BC,$84,$4E,$B9,$00,$01,$BC,$72
	dc.b	$00,$04,$2E,$00,$30,$1F,$32,$3C,$00,$02,$4E,$B9,$00,$02,$30,$E8
	dc.b	$60,$00,$00,$0C,$32,$3C,$00,$03,$4E,$B9,$00,$01,$BE,$1C,$4E,$B9
	dc.b	$00,$01,$BC,$84,$52,$78,$B0,$42,$52,$46,$BC,$78,$BF,$5C,$6D,$00
	dc.b	$FE,$9C,$60,$00,$00,$02,$4E,$75

BlankStatsRow	;A String of blanks that clears a stats list row
	dc.b	$00,$24,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	dc.b	$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	dc.b	$20,$20,$20,$20,$08,$F8,$00,$05,$C3,$56,$21,$FC,$00,$01,$2D,$46
	dc.b	$D2,$44,$08,$B8,$00,$00,$BF,$B2,$08,$F8,$00,$02,$BF,$B2,$08,$B8
	dc.b	$00,$01,$BF,$B2,$31,$FC,$00,$00,$B0,$00,$31,$FC,$B4,$00,$B0,$02
	dc.b	$31,$FC,$B8,$00,$B0,$0C,$31,$FC,$00,$05,$B0,$0E,$31,$FC,$C0,$00
	dc.b	$B0,$08,$31,$FC,$00,$06,$B0,$0A,$31,$FC,$E0,$00,$B0,$04,$31,$FC
	dc.b	$00,$06,$B0,$06,$30,$3C,$00,$00,$08,$F8,$00,$05,$BF,$B2,$4E,$B9
	dc.b	$00,$01,$B5,$7E,$08,$B8,$00,$05,$BF,$B2,$4E,$B9,$00,$01,$B2,$C4
	dc.b	$38,$3C,$00,$01,$22,$7C,$00,$18,$88,$2C,$4E,$B9,$00,$01,$21,$7A
	dc.b	$31,$C4,$B0,$1C,$24,$7C,$00,$17,$91,$70,$4E,$B9,$00,$01,$B7,$30
	dc.b	$31,$C4,$B0,$1E,$24,$7C,$00,$17,$A1,$6C,$4E,$B9,$00,$01,$B7,$30
	dc.b	$21,$FC,$00,$17,$91,$68,$BF,$8A,$31,$C4,$B0,$18,$24,$7C,$00,$17
	dc.b	$B6,$88,$4E,$B9,$00,$01,$B7,$30,$08,$F8,$00,$02,$C3,$54,$4E,$B9
	dc.b	$00,$01,$BA,$2E,$00,$08,$FF,$01,$FD,$00,$FC,$00,$70,$28,$72,$1C
	dc.b	$34,$3C,$07,$FF,$4E,$B9,$00,$01,$B9,$76,$4E,$B9,$00,$01,$BB,$8E
	dc.b	$00,$06,$BF,$00,$00,$00,$20,$7C,$00,$18,$63,$3E,$22,$48,$24,$48
	dc.b	$D1,$DA,$D3,$DA,$42,$40,$42,$41,$74,$28,$76,$1C,$7A,$08,$4E,$B9
	dc.b	$00,$01,$B6,$92,$4E,$B9,$00,$01,$BB,$8E,$00,$06,$BF,$0B,$01,$00
	dc.b	$20,$7C,$00,$18,$80,$0C,$08,$38,$00,$02,$DD,$80,$67,$00,$00,$08
	dc.b	$20,$7C,$00,$18,$8C,$4A,$22,$48,$24,$48,$D1,$DA,$D3,$DA,$42,$40
	dc.b	$42,$41,$34,$11,$36,$29,$00,$02,$7A,$08,$4E,$B9,$00,$01,$B6,$92
	dc.b	$3F,$38,$B0,$1C,$31,$F8,$B0,$1E,$B0,$1C,$4E,$B9,$00,$01,$BC,$72
	dc.b	$00,$28,$8F,$0A,$19,$7B,$7D,$2D,$53,$43,$52,$4F,$4C,$4C,$20,$4C
	dc.b	$49,$53,$54,$8F,$0A,$1A,$5B,$5D,$2D,$43,$48,$41,$4E,$47,$45,$20
	dc.b	$43,$41,$54,$45,$47,$4F,$52,$59,$31,$DF,$B0,$1C,$4E,$B9,$00,$01
	dc.b	$BB,$8E,$00,$06,$FE,$00,$00,$00,$20,$7C,$00,$17,$0B,$0C,$22,$48
	dc.b	$24,$48,$D1,$DA,$D3,$DA,$42,$40,$42,$41,$74,$40,$76,$1C,$7A,$01
	dc.b	$4E,$B9,$00,$01,$B6,$92,$4E,$B9,$00,$01,$BE,$D6,$00,$1C,$F8,$04
	dc.b	$01,$07,$08,$23,$F8,$04,$01,$0B,$08,$50,$4C,$41,$59,$45,$52,$F8
	dc.b	$04,$01,$18,$08,$54,$45,$41,$4D,$46,$FC,$25,$00,$4E,$75

SeasonPlayoffStats	;The playoff stats screen in a season (PlayoffStatsMenu with GameFlags bit 7): the players or goalies of a
	;team by category (pstatscat), the PStats helpers of code96_16
	movem.l	d0-d7/a0-a6,-(sp)
	clr.w	(carddelay).w
	clr.w	(pstatscat).w
	clr.w	(word_FF2720).l
	bset	#5,(sflags12).w
	bsr.w	PStatsSetup
	movea.l	#PlayerStatsSprites,a0
	jsr	(DrawScreenSprite).l
	move.w	#$18,(palcount).w
	bclr	#2,(disflags).w
	clr.w	(pstatstop).w
	move.w	#$D,(pstatsrows).w
	move.w	#$C,(pstatsrow).w
	clr.w	(pstatscat).w
.1
	move.w	(word_FF2720).l,d7
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
	move.w	(vcount).w,d0
.loop2
	cmp.w	(vcount).w,d0
	beq.s	.loop2
	bsr.w	PStatsClearList
.4
	move.w	(vcount).w,d0
.7
	cmp.w	(vcount).w,d0
	beq.s	.7
	bsr.w	PStatsCategory
	bsr.w	PStatsTeamBlock
	bsr.w	PStatsHelp
	bsr.w	PStatsHeading
	move.w	(vcount).w,d0
.loop3
	cmp.w	(vcount).w,d0
	beq.s	.loop3
	bset	#2,(disflags).w
	jsr	(SetMenuScroll).l
	bsr.w	PStatsPrintList
	jsr	(SetMenuScroll).l
	move	#$2500,sr
	bsr.w	PStatsArrows
	jsr	(SetMenuScroll).l
	bclr	#2,(disflags).w
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
	addq.w	#1,(pstatsrow).w	;next lower item
	bra.w	.4
.6
	btst	#6,d1
	beq.w	.5
	subq.w	#1,(word_FF2720).l
	bpl.w	.1
	btst	#2,(SeasonFlags).w
	beq.w	.10
	move.w	#$F,(word_FF2720).l
	bra.w	.1
.10
	move.w	#$19,(word_FF2720).l
	bra.w	.1
.5
	btst	#5,d1
	beq.w	.14
	addq.w	#1,(word_FF2720).l
	btst	#2,(SeasonFlags).w
	beq.w	.11
	cmpi.w	#$10,(word_FF2720).l
	bra.w	.12
.11
	cmpi.w	#$1A,(word_FF2720).l
.12
	bne.w	.1
	clr.w	(word_FF2720).l
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

WaitAnyPad	;Wait for a press on pad 1 or 2 (3 and 4 with FourWayPlay); d1 = the buttons
	move.l	#$5460,d6
.wait
	move.w	#$64,d6
	move.w	(vcount).w,d1
	sub.w	(oldvcount).w,d1
	beq.s	.wait
	jsr	(SetMenuScroll).l
	move.w	(vcount).w,(oldvcount).w
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

PStatsArrows	;SeasonPlayoffStats: the scroll marks { (pstatstop above 0) and } (more rows below)
	movem.l	d0-d7/a0-a6,-(sp)
	tst.w	(pstatstop).w
	beq.w	.0
	jsr	(printcurz).l
	String	$8F,$02,$0B,$7B
	bra.w	.1
.0
	jsr	(printcurz).l
	String	$8F,$02,$0B,$20
.1
	move.w	(pstatsrow).w,d1
	cmp.w	(pstatslast).w,d1
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

PStatsClearList	;SeasonPlayoffStats: erase the list area
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#$24,d0
	move.w	#$D,d1
	move.w	#$7FF,d2
	ori.w	#$8000,d2
	jsr	(printz).l
	String	$BF,$02,$0B
	jsr	(eraser).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

PStatsSetup	;SeasonPlayoffStats: vram, fonts and the screen bitmaps, the heading, the team block and the help
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
	move.w	d4,(pstatsblockchars).l
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
	movea.l	#SeasonStatsTitleMap,a0
	btst	#2,(SeasonFlags).w
	beq.w	.0
	jsr	(printz).l
	String	$BF,$0B,$01
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
	bsr.w	PStatsHeading
	bsr.w	PStatsCategory
	bsr.w	PStatsTeamBlock
	bsr.w	PStatsPalette
	move	#$2500,sr
	rts

PStatsTeamBlock	;SeasonPlayoffStats: the team block of the shown team (DrawSetupTeamBlock)
	move.w	d7,-(sp)
	jsr	(printz).l
	String	$BF,$01,$05
	move.w	(pstatsblockchars).l,d4
	move.w	(word_FF2720).l,d7
	btst	#2,(SeasonFlags).w
	beq.w	.0
	jsr	(GetPOSlotTeam).l
.0
	jsr	(DrawSetupTeamBlock).l
	move.w	(sp)+,d7

PStatsHeading	;SeasonPlayoffStats: the column heading, players or goalies (pstatscat 4 and up)
	cmpi.w	#4,(pstatscat).w
	bge.w	.0
	jsr	(printbigz).l
	String	$F8,$04,$01,$04,$08,'#  PLAYER         g   a   p   pim'
	bra.w	.1
.0
	jsr	(printbigz).l
	String	$F8,$04,$01,$04,$08,'#  GOALIE        s     sh    sp  '
.1
	rts

PStatsHelp	;SeasonPlayoffStats: the button help lines
	cmpi.w	#4,(pstatscat).w
	bge.w	.1
	move.w	(smallfontchars).w,-(sp)
	move.w	(smallfont2chars).w,(smallfontchars).w
	jsr	(printcurz).l
	String	$8F,$04,$19,'{}-SCROLL LIST   A/C-TEAMS',$8F,$04,$1A,'[]-CATEGORY      B-GOALIES'
	move.w	(sp)+,(smallfontchars).w
	bra.w	.0
.1
	move.w	(smallfontchars).w,-(sp)
	move.w	(smallfont2chars).w,(smallfontchars).w
	jsr	(printcurz).l
	String	$8F,$04,$19,'{}-SCROLL LIST   A/C-TEAMS',$8F,$04,$1A,'[]-CATEGORY      B-PLAYERS'
	move.w	(sp)+,(smallfontchars).w
.0
	rts

PStatsCategory	;SeasonPlayoffStats: the name of category pstatscat (PStatsCategoryTxt)
	jsr	(printz).l
	String	$BF,$15,$05
	movea.l	#PStatsCategoryTxt,a1
	move.w	(pstatscat).w,d0
	jsr	(SkipStrings).l
	jsr	(printbig).l
	rts

PStatsCategoryTxt	;PStatsCategory: the category names
	dc.b	$00,$12,$20,$20,$20,$20,$20,$67,$6F,$61,$6C,$73,$20,$20,$20,$20
	dc.b	$20,$00,$00,$12,$20,$20,$20,$20,$61,$73,$73,$69,$73,$74,$73,$20
	dc.b	$20,$20,$20,$00,$00,$12,$20,$20,$20,$20,$20,$70,$6F,$69,$6E,$74
	dc.b	$73,$20,$20,$20,$20,$00,$00,$12,$70,$65,$6E,$61,$6C,$74,$79,$20
	dc.b	$6D,$69,$6E,$75,$74,$65,$73,$00,$00,$12,$20,$20,$20,$20,$20,$73
	dc.b	$61,$76,$65,$73,$20,$20,$20,$20,$20,$00,$00,$12,$20,$20,$20,$20
	dc.b	$20,$73,$68,$6F,$74,$73,$20,$20,$20,$20,$20,$00,$00,$12,$73,$61
	dc.b	$76,$65,$20,$70,$65,$72,$63,$65,$6E,$74,$61,$67,$65,$00

PStatsBuildList	;SeasonPlayoffStats: the player or goalie list of the shown team, sorted by category
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(word_FF2720).l,d7
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
	movea.l	#$FFFF1388,a0
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
	movea.l	#$FFFF1388,a0
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
	movea.l	#$FFFF1388,a1
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

PStatsColumns	;PStatsPrintValue: the stat offsets of each category
	dc.b	$FF,$FF,$19,$3A,$FF,$FF,$1A,$02,$FF,$FF,$1A,$CA,$FF,$FF,$1B,$92
	dc.b	$FF,$FF,$1C,$5A,$FF,$FF,$1D,$22,$FF,$FF,$1D,$EA

PStatsPrintList	;SeasonPlayoffStats: print the rows of the list
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(printz).l
	String	$8F,$00,$00
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
	movea.l	#$FFFF1388,a0
	move.w	d6,d0
	add.w	(pstatstop).w,d0
	add.w	d0,d0
	move.w	(a0,d0.w),d0
	ext.l	d0
	move.w	d0,-(sp)
	move.w	(word_FF2720).l,d7
	btst	#2,(SeasonFlags).w
	beq.w	.3
	jsr	(GetPOSlotTeam).l
.3
	jsr	(FormatPlayerNameD7).l
	jsr	(printcur).l
	cmpi.w	#4,(pstatscat).w
	bge.w	.5
	move.w	(word_FF2720).l,d7
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

PStatsPrintValue	;SeasonPlayoffStats: print stat column pstatscol of player d0
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

PStatsMark	;SeasonPlayoffStats: print a value, highlighted in the column of the category
	move.w	(printa).w,-(sp)
	move.w	(pstatscat).w,d0
	cmp.w	(pstatscol).l,d0
	bne.w	.0
	jsr	(printsmallz).l
	String	$FE,$05
.0
	jsr	(printcur).l
	move.w	(sp)+,(printa).w
	rts

PStatsPalette	;The palette of unk_17C2AE to palfadenew+$20
	movem.l	a0-a1,-(sp)
	movea.l	#unk_17C2AE,a0
	movea.l	#palfadenew+$20,a1
	move.w	#7,d0
.pal
	move.l	(a0)+,(a1)+
	dbf	d0,.pal
	movem.l	(sp)+,a0-a1
	rts

PlayoffMenuScreen	;The playoff menu screen: the playoff tree from save RAM (ReadPassData, ReadPassBits, maketree), then the
	;roster menu loop (RosterMenuList); Reset Rosters asks Yes / No (YesNoMenuList) before ClearPlayoffSave
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#$FFFF,(word_FFDDBE).w
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
	jsr	(maketree).l
	move.w	(sp)+,(GameFlags).w
	movea.l	#potree,a0
	move.w	(potreeteam).w,d2
	move.b	(a0,d2.w),d2
	clr.w	(word_FFDDBE).w
	move.b	d2,(word_FFDDBE+1).w
.0
	clr.w	(carddelay).w
	bsr.w	PlayoffMenuInit
	bsr.w	PlayoffMenuSetup
	movea.l	#TransactionsSprites,a0
	jsr	(DrawScreenSprite).l
	jsr	(PStatsPalette).l
	move.w	#$18,(palcount).w
	bclr	#2,(disflags).w
.draw
	bsr.w	PlayoffMenuDraw
.frame
	move.w	(vcount).w,d0
.loop2
	cmp.w	(vcount).w,d0
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
	String	$FF,$01,$FD,$0C,$FC,$0B
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
	String	$FF,$01,$FD,$0C,$FC,$0B
	move.w	#$11,d0
	move.w	#$D,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	jsr	(printsmallz).l
	String	$FE,$07,$F9,$00,$FD,$0E,$FC,$0B,'Reset Rosters'
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

PlayoffMenuRoutines	;PlayoffMenuScreen: the routine of each menu item
	dc.l	TradePlayers,MenuCreatePlayers,MenuSignFreeAgents,MenuReleasePlayer,ClearPlayoffSave,TeamRosterScreen
	dc.l	SeasonMenuScreen

PlayoffMenuDraw	;PlayoffMenuScreen: draw the menu (PrintMenuList2)
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(printz).l
	String	$8F,$00,$00
	jsr	(PrintMenuList2).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

PlayoffMenuInit	;PlayoffMenuScreen: menulist = RosterMenuList, item 0
	move.l	#RosterMenuList,(menulist).l
.0
	clr.w	(menuitem).w
	clr.w	(menuitem+2).w
	move.w	#7,(menurows).w
	move.w	#$D,(menux).w
	move.w	#$B,(menuy).w
	rts

PlayoffMenuSetup	;PlayoffMenuScreen: vram and the screen bitmaps
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
	String	$FF,$01,$FD,$00,$FC
	moveq	#$28,d0
	moveq	#$1C,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	jsr	(printz).l
	String	$BF,$00,$00
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
	String	$BF,$0B,$01
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
	String	$FE,$00,$00
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

ClearPlayoffSave	;Clear the saved playoffs in save RAM ($E68 and $DB4)
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
	jsr	(sub_11582).l
	bclr	#6,(GameFlags).w
	jsr	(MakeSRAMChecksum).l
	rts
