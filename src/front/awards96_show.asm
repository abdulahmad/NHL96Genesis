;	The end-of-season awards. Nine pictures, and the winner of each.

SeasonAwards	;End of season awards: left / right go through the 9 awards (picture, name, description, winner),
	;start leaves
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(forceblack).l
	bsr.w	SetPlayoffAwardWinners
	bsr.w	AwardsScreenSetup
	move.w	#$18,(palcount).w
	bclr	#2,(disflags).w
	clr.w	(PlayerScrollCtr).w
.draw
	jsr	(DrawAwardWinnerLogo).l
	jsr	(DrawAwardPicture).l
	jsr	(PrintAwardName).l
	jsr	(PrintAwardDesc).l
	jsr	(PrintAwardWinner).l
	move.w	#$64,(palcount).w
	move	#$2500,sr
.frame
	move.w	(vcount).w,d0
.vwait
	cmp.w	(vcount).w,d0
	beq.s	.vwait
	jsr	(SetMenuScroll).l
	jsr	(orjoy).l
	btst	#7,d1
	bne.w	.2
	btst	#2,d1
	beq.w	.1
	move.w	(PlayerScrollCtr).w,d0
	subq.w	#1,d0
	bpl.w	.0
	move.w	#8,d0
.0
	move.w	d0,(PlayerScrollCtr).w
	bra.s	.draw
.1
	btst	#3,d1
	beq.s	.frame
	move.w	(PlayerScrollCtr).w,d0
	addq.w	#1,d0
	cmp.w	#8,d0
	ble.s	.0
	clr.w	d0
	bra.s	.0
.2
	movem.l	(sp)+,d0-d7/a0-a6
	rts

DrawAwardWinnerLogo	;The team logo of the winner of award PlayerScrollCtr
	jsr	(printz).l
	String	$8F,$03,$08
	bsr.w	GetAwardWinnerTeam
	move.w	(awardlogochars).w,d4
	clr.w	d5
	jsr	(DrawTeamLogoD7).l
	rts

DrawAwardPicture	;Draw the picture of award PlayerScrollCtr (AwardPictures)
	jsr	(printz).l
	String	$BF,$19,$09
	move.w	(PlayerScrollCtr).w,d0
	movea.l	#AwardPictures,a0
	asl.w	#2,d0
	movea.l	(a0,d0.w),a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	moveq	#$A,d2
	moveq	#$A,d3
	moveq	#2,d5
	move.w	(DispAttribCtr).w,d4
	jsr	(dobitmap).l
	rts

AwardPictures	;The award picture bitmaps, one per award
	dc.l	HartPic,ArtRossPic,NorrisPic,VezinaPic,ConnSmythePic
	dc.l	PresidentsPic,WalesPic,CampbellPic,PearsonPic

PrintAwardName	;Print the name of award PlayerScrollCtr (AwardNames)
	jsr	(printz).l
	String	$BF,$13,$05
	movea.l	#AwardNames,a1
	move.w	(PlayerScrollCtr).w,d0
	jsr	(SkipStrings).l
	move.w	(a1),d0
	subq.w	#2,d0
	lsr.w	#1,d0
	sub.w	d0,(printx).w
	bset	#2,(sflags11).w
	jsr	(printbig).l
	rts

AwardNames	;PrintAwardName Strings: the award names
	String	'hart memorial trophy'
	String	'  art ross trophy   '
	String	'james norris trophy '
	String	'   vezina trophy    '
	String	' conn smythe trophy '
	String	' presidents trophy  '
	String	'  prince of wales   '
	String	' clarence campbell  '
	String	' lester b. pearson  '

PrintAwardDesc	;Print the description of award PlayerScrollCtr (AwardDescs)
	jsr	(printcurz).l
	String	$8F,$02,$14,'                ',$8F,$02,$15,'                ',$8F,$02,$16,'                ',$8F,$02,$17,'                ',$8F,$02,$18,'                '
	movea.l	#AwardDescs,a1
	move.w	(PlayerScrollCtr).w,d0
	jsr	(SkipStrings).l
	jsr	(printcur).l
	rts

AwardDescs	;PrintAwardDesc Strings: the award descriptions
	String	$8F,$02,$14,'to the player',$8F,$02,$15,'adjudged to be',$8F,$02,$16,'the most',$8F,$02,$17,'valuable to',$8F,$02,$18,'his team'
	String	$8F,$02,$14,'to the player',$8F,$02,$15,'who leads the',$8F,$02,$16,'league in points',$8F,$02,$17,'at the end of',$8F,$02,$18,'the reg. season'
	String	$8F,$02,$14,'to the defensive',$8F,$02,$15,'player showing',$8F,$02,$16,'the greatest all',$8F,$02,$17,'around ability',$8F,$02,$18,'in the position'
	String	$8F,$02,$14,'to the goalie',$8F,$02,$15,'adjudged to be',$8F,$02,$16,'the best at',$8F,$02,$17,'his position'
	String	$8F,$02,$14,'to the most',$8F,$02,$15,'valuable player',$8F,$02,$16,'for his team',$8F,$02,$17,'in the playoffs'
	String	$8F,$02,$14,'to the club',$8F,$02,$15,'finishing the',$8F,$02,$16,'regular season',$8F,$02,$17,'with the best',$8F,$02,$18,'record'
	String	$8F,$02,$14,'to the winners',$8F,$02,$15,'of the',$8F,$02,$16,'Eastern',$8F,$02,$17,'Conference',$8F,$02,$18,'Championship'
	String	$8F,$02,$14,'to the winners',$8F,$02,$15,'of the',$8F,$02,$16,'Western',$8F,$02,$17,'Conference',$8F,$02,$18,'Championship'
	String	$8F,$02,$14,'to the nhl''s',$8F,$02,$15,'outstanding',$8F,$02,$16,'player chosen by',$8F,$02,$17,'player members',$8F,$02,$18,'of the nhlpa'

PrintAwardWinner	;Print the winner of award PlayerScrollCtr: a team (TeamAwardFlags) or a player "F. Name"
	bset	#2,(sflags11).w
	jsr	(printbigz).l
	String	$F8,$04,$01,$17,$15,'              '
	bsr.w	GetAwardWinner
	movea.l	#TeamAwardFlags,a0
	move.w	(PlayerScrollCtr).w,d1
	tst.b	(a0,d1.w)
	beq.w	.0
	move.w	d0,d7
	asl.w	#2,d7
	movea.l	#TeamList,a1
	movea.l	(a1,d7.w),a1
	adda.w	4(a1),a1
	bra.w	.1
.0
	swap	d0
	jsr	(GetCreatedName).l
	movea.l	a1,a0
	move.l	a0,-(sp)
	movea.w	#(TextBuffer-M68K_RAM),a1
	adda.w	(a0),a0
	move.b	(a0),d0
	movea.l	(sp)+,a0
	move.w	(a0)+,d0
	lea	-2(a0,d0.w),a2
	move.b	(a0)+,(a1)+
	move.b	#$2E,(a1)+
	move.b	#$20,(a1)+
.skipfirst
	cmpi.b	#$20,(a0)+
	bne.s	.skipfirst
.copy
	move.b	(a0)+,(a1)+
	cmpa.l	a0,a2
	bne.s	.copy
	jsr	(FinalizeTextBuffer).l
	movea.l	#mesarea,a1
.1
	jsr	(printz).l
	String	$BF,$1E,$15
	move.w	(a1),d0
	subq.w	#2,d0
	lsr.w	#1,d0
	sub.w	d0,(printx).w
	bset	#2,(sflags11).w
	jsr	(printbig).l
	rts

TeamAwardFlags	;Nonzero for a team award
	dc.b	0,0,0,0,0,1,1,1,0,$FF

AwardsScreenSetup	;Awards screen setup: vram, fonts and the background bitmaps
	bset	#5,(sflags12).w
	move.l	#VBlank_Menus,(vbint).w
	bclr	#0,(disflags).w
	bset	#2,(disflags).w
	bclr	#1,(disflags).w
	move.w	#0,(VSCRLPM).w
	move.w	#$B800,(VSPRITES).w
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
	movea.l	#AwardsSprites,a1
	jsr	(LoadScreenSprite).l
	move.w	#$1E,d4
	move.w	d4,(smallfontchars).w
	movea.l	#SmallFontMap2+8,a2
	jsr	(DecompressGraphicsPlain).l
	move.l	#SmallFontMap2,(smallfontptr).w
	move.w	d4,(BigFontChars).w
	movea.l	#BigFontMap4+8,a2
	jsr	(DecompressGraphicsPlain).l
	bset	#2,(sflags11).w
	jsr	(printsmallz).l
	String	$FF,$01,$FD,$00,$FC
	moveq	#$28,d0
	moveq	#$1C,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	jsr	(printz).l
	String	$BF,$00,$00
	movea.l	#AwardsBgMap,a0
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
	move.w	d4,(awardlogochars).w
	addi.w	#$A0,d4
	move.w	d4,(DispAttribCtr).w
	addi.w	#$64,d4
	jsr	(printz).l
	String	$BF,$0B,$01
	movea.l	#AwardsTitleMap,a0
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
	movea.l	#AwardsSprites,a0
	jsr	(DrawScreenSprite).l
	rts

GetAwardWinnerTeam	;d7 = the team of the winner of award PlayerScrollCtr (its save RAM award record)
	;Code the listing does not decode: kept as bytes
	dc.b	$20,$7C,$FF,$FF,$D1,$30,$20,$3C,$00,$00,$0D,$94,$32,$38,$D0,$34
	dc.b	$B2,$7C,$00,$08,$66,$00,$00,$04,$42,$41,$C2,$FC,$00,$04,$D0,$81
	dc.b	$32,$3C,$00,$04,$4E,$B9,$00,$02,$41,$E8,$3E,$28,$00,$02,$4E,$75

GetAwardWinner	;d0 = the 4-byte winner record of award PlayerScrollCtr (save RAM $D94 + award * 4, read to ThreeStars)
	movea.l	#ThreeStars,a0
	move.l	#$D94,d0
	move.w	(PlayerScrollCtr).w,d1
	cmp.w	#8,d1
	bne.w	.0
	clr.w	d1
.0
	mulu.w	#4,d1
	add.l	d1,d0
	move.w	#4,d1
	jsr	(ReadSRAM).l
	move.l	(a0),d0
	rts

SetSeasonAwardWinners	;Write the regular season award winners (Hart, Art Ross, Norris, Vezina, Presidents') to save RAM from the
	;leaders
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#2,(pstatscat).w
	jsr	(BuildPlayerLeaders).l
	movea.l	#$201B28,a6
	move.w	(word_FF1388).l,d0
	ext.l	d0
	divu.w	#$1B,d0
	move.w	d0,d7
	swap	d0
	clr.w	4(a6)
	move.w	d7,6(a6)
	movea.l	#$FFFFDDAA,a0
	jsr	(GetSeasonRosterId).l
	move.b	(jerseynum).w,1(a6)
	move.b	(jerseynum+1).w,3(a6)
	addq.l	#8,a6
	move.w	(word_FF1388).l,d0
	ext.l	d0
	divu.w	#$1B,d0
	move.w	d0,d7
	swap	d0
	clr.w	4(a6)
	move.w	d7,6(a6)
	movea.l	#$FFFFDDAA,a0
	jsr	(GetSeasonRosterId).l
	move.b	(jerseynum).w,1(a6)
	move.b	(jerseynum+1).w,3(a6)
	addq.l	#8,a6
	movea.l	#$FFFF1388,a5
.0
	move.w	(a5),d0
	ext.l	d0
	divu.w	#$1B,d0
	move.w	d0,d7
	swap	d0
	movem.w	d0,-(sp)
	jsr	(GetPositionSlot).l
	move.w	d0,d1
	movem.w	(sp)+,d0
	cmp.w	#1,d1
	beq.w	.1
	cmp.w	#2,d1
	beq.w	.1
	addq.l	#2,a5
	bra.s	.0
.1
	clr.w	4(a6)
	move.w	d7,6(a6)
	movea.l	#$FFFFDDAA,a0
	jsr	(GetSeasonRosterId).l
	move.b	(jerseynum).w,1(a6)
	move.b	(jerseynum+1).w,3(a6)
	addq.l	#8,a6
	move.w	#3,(pstatscat).w
	jsr	(BuildPlayerLeaders).l
	move.w	(word_FF1388).l,d0
	ext.l	d0
	divu.w	#$1B,d0
	move.w	d0,d7
	swap	d0
	clr.w	4(a6)
	move.w	d7,6(a6)
	movea.l	#$FFFFDDAA,a0
	jsr	(GetSeasonRosterId).l
	move.b	(jerseynum).w,1(a6)
	move.b	(jerseynum+1).w,3(a6)
	adda.l	#$10,a6
	move.l	a6,-(sp)
	movea.l	#$FFFFD168,a0
	jsr	(ReadStandings).l
	jsr	(StandingsPoints).l
	movea.l	(sp)+,a6
	move.w	#$19,d6
	clr.w	d7
	clr.w	d5
	movea.l	#$FFFFD132,a0
.2
	clr.w	d0
	move.b	(a0)+,d0
	cmp.w	d0,d5
	bge.w	.3
	move.b	-1(a0),d5
	move.b	d7,(jerseynum+1).w
.3
	addq.w	#1,d7
	dbf	d6,.2
	move.b	(jerseynum+1).w,7(a6)
	clr.b	5(a6)
	bclr	#6,(GameFlags).w
	jsr	(MakeSRAMChecksum).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

SetPlayoffAwardWinners	;Write the Conn Smythe, Wales and Campbell winners to save RAM (the finalists, or the conference standings)
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#2,(pstatscat).w
	jsr	(BuildPlayerLeaders).l
	movea.l	#$201B48,a6
	move.w	(word_FF1388).l,d0
	btst	#1,(sflags11).w
	beq.w	.0
	move.w	($201B56).l,d7
	andi.w	#$FF,d7
	jsr	(GetGoalieCountD7).l
	move.w	d0,d1
	move.w	#3,d0
	jsr	(randomd0).l
	add.w	d1,d0
	bra.w	.1
.0
	ext.l	d0
	divu.w	#$1B,d0
	move.w	d0,d7
	swap	d0
.1
	clr.w	4(a6)
	move.w	d7,6(a6)
	movea.l	#$FFFFDDAA,a0
	jsr	(GetSeasonRosterId).l
	move.b	(jerseynum).w,1(a6)
	move.b	(jerseynum+1).w,3(a6)
	btst	#1,(sflags11).w
	beq.w	.2
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#5,(StandingsMode).w
	jsr	(StandingsGroups).l
	movea.l	#$FFFFD168,a0
	jsr	(ReadStandings).l
	jsr	(StandingsPoints).l
	jsr	(SortStandings).l
	clr.w	d7
	move.b	(StandingsList).w,d7
	movea.l	#$201B58,a6
	move.b	d7,7(a6)
	clr.b	5(a6)
	move.w	#4,(StandingsMode).w
	jsr	(StandingsGroups).l
	movea.l	#$FFFFD168,a0
	jsr	(ReadStandings).l
	jsr	(StandingsPoints).l
	jsr	(SortStandings).l
	clr.w	d7
	move.b	(StandingsList).w,d7
	movea.l	#$201B58,a6
	move.b	d7,$F(a6)
	clr.b	$D(a6)
	movem.l	(sp)+,d0-d7/a0-a6
	bra.w	.6
.2
	jsr	(maketree).l
	movea.l	#$201B58,a6
	movea.l	#$FFFFCFEE,a0
	movea.l	#StandingsGroup4,a1
	move.b	(a1)+,d1
	subq.w	#1,d1
.3
	move.b	(a1)+,d0
	cmp.b	(a0),d0
	beq.w	.4
	dbf	d1,.3
	bra.w	.5
.4
	move.b	1(a0),7(a6)
	clr.b	5(a6)
	move.b	(a0),$F(a6)
	clr.b	$D(a6)
	bra.w	.6
.5
	move.b	(a0),7(a6)
	clr.b	5(a6)
	move.b	1(a0),$F(a6)
	clr.b	$D(a6)
.6
	bclr	#6,(GameFlags).w
	jsr	(MakeSRAMChecksum).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

CupChampionsScreen	;The user's team won the Cup: a full screen picture with the team palette, small logo and name, until start
	btst	#3,(SeasonFlags).w
	beq.w	.3
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	#VBlank_SpriteFade,(vbint).w
	bclr	#0,(disflags).w
	bset	#2,(disflags).w
	bclr	#1,(disflags).w
	move.w	#0,(VSCRLPM).w
	move.w	#$B800,(VSPRITES).w
	move.w	#$B800,(VmMap3).w
	move.w	#5,(Map3col1).w
	move.w	#$C000,(VmMap2).w
	move.w	#6,(Map2col1).w
	move.w	#$E000,(VmMap1).w
	move.w	#6,(Map1col1).w
	move.w	#0,d0
	bclr	#5,(disflags).w
	jsr	(setVram).l
	move.w	(VSCRLPM).w,d0
	jsr	(Vmaddr).l
	move.w	#0,(a0)
	move.w	#0,d0
	move.w	d0,(a0)
	jsr	(orjoy).l
	move.w	#1,d4
	move.w	d4,(bigfont1chars).w
	movea.l	#BigFontMap+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$04,$F3,$45,$67,$89,$CB,$CA,$9F	;remap table
	bclr	#2,(sflags11).w
	jsr	(printsmallz).l
	String	$FF,$01,$FD,$00,$FC
	moveq	#$28,d0
	moveq	#$1C,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	jsr	(printz).l
	String	$BF,$00,$00
	movea.l	#CupChampsMap2,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	moveq	#$28,d2
	moveq	#$1C,d3
	moveq	#$F,d5
	jsr	(dobitmap).l
	movea.l	#CupChampsPals,a0
	clr.l	d0
	move.b	(dword_FFDD82+2).w,d0
	asl.w	#5,d0
	adda.l	d0,a0
	move.w	#7,d1
	movea.l	#$FFFFBD3E,a1
.0
	move.l	(a0)+,(a1)+
	dbf	d1,.0
	jsr	(printz).l
	String	$AF,$1D,$15
	movea.l	#SmallLogoPtrs,a0
	clr.w	d0
	move.b	(dword_FFDD82+2).w,d0
	asl.w	#2,d0
	movea.l	(a0,d0.w),a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	moveq	#5,d2
	moveq	#5,d3
	moveq	#0,d5
	jsr	(dobitmap).l
	jsr	(printz).l
	String	$FE,$00,$00
	movea.l	#CupChampsMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	moveq	#$28,d2
	moveq	#$1C,d3
	moveq	#0,d5
	jsr	(dobitmap).l
	jsr	(printz).l
	String	$AF,$14,$16
	movea.l	#$77E,a1
	clr.w	d0
	move.b	(dword_FFDD82+2).w,d0
	asl.w	#2,d0
	movea.l	(a1,d0.w),a1
	adda.w	4(a1),a1
	cmp.w	#0,d0
	bne.w	.1
	movea.l	#MightyDucksTxt,a1
.1
	move.w	(a1),d0
	subq.w	#2,d0
	asr.w	#1,d0
	sub.w	d0,(printx).w
	move.w	(bigfont1chars).w,(printbigchars).w
	move.l	#BigFontMap,(bigfontptr).w
	jsr	(printbigcur).l
	jsr	(printz).l
	String	$AF,$14,$18
	movea.l	#$77E,a1
	clr.w	d0
	move.b	(dword_FFDD82+2).w,d0
	asl.w	#2,d0
	movea.l	(a1,d0.w),a1
	adda.w	4(a1),a1
	adda.w	(a1),a1
	adda.w	(a1),a1
	cmp.w	#0,d0
	bne.w	.2
	movea.l	#OfAnaheimTxt,a1
.2
	move.w	(a1),d0
	subq.w	#2,d0
	asr.w	#1,d0
	sub.w	d0,(printx).w
	move.w	(bigfont1chars).w,(printbigchars).w
	move.l	#BigFontMap,(bigfontptr).w
	jsr	(printbigcur).l
	move.w	#$18,(palcount).w
	bclr	#2,(disflags).w
	move	#$2500,sr
	move.w	(vcount).w,d0
.loop2
	cmp.w	(vcount).w,d0
	beq.s	.loop2
	jsr	(orjoy).l
	btst	#7,d1
	beq.s	.loop2
	movem.l	(sp)+,d0-d7/a0-a6
.3
	rts

MightyDucksTxt	;CupChampionsScreen: Anaheim's first name line
	String	'mighty ducks'

OfAnaheimTxt	;CupChampionsScreen: Anaheim's second name line
	String	'of anaheim'

