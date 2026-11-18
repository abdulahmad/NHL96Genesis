;	Loads for the replay icon and the home team graphics, the hi-score
;	screen, and clearing the penalties.

LoadReplayIcon						;Load the replay icon tiles (ReplayIconMap+8) at char d4 (ReplayIconChars)
	move.w	d4,(ReplayIconChars).w
	movea.l	#ReplayIconMap+8,a2
	jmp	DecompressGraphicsPlain

LoadHomeTeamGfx						;Load the HomeTeam graphics of TeamGfxList to VRAM d4 - $18
									;(DecompressGraphicsPlain). Called from setupice
									;and ClrHor
	move.w	d0,-(sp)
	subi.w	#$18,d4
	movea.l	#TeamGfxList,a2
	move.w	(HomeTeam).w,d0
	asl.w	#2,d0
	movea.l	(a2,d0.w),a2
	addq.w	#8,a2
	jsr	(DecompressGraphicsPlain).l
	move.w	(sp)+,d0
	rts

TeamGfxList							;The team graphics map of each team
									;(LoadHomeTeamGfx), a long pointer per team
	dc.l	$1419D2,$1465CC,$141CDC,$141FE6
	dc.l	$1422F0,$1425FA,$142904,$142C0E
	dc.l	$142F18,$143222,$14352C,$143836
	dc.l	$143B40,$143E4A,$144154,$14445E
	dc.l	$144768,$144A72,$144D7C,$145086
	dc.l	$145390,$14569A,$1459A4,$145CAE
	dc.l	$145FB8,$1462C2

PrintPlayerAssists					;Print " (" and the assists of player d0 of team a2 (PrintParenNumber)
	movem.l	d0/a2,-(sp)
	jsr	(printz).l
	String	' ('
	adda.w	#$DC,a2
	bra.w	PrintParenNumber

PrintPlayerGoals					;Print " (" and the goals of player d0 of team a2
	movem.l	d0/a2,-(sp)
	jsr	(printz).l
	String	' ('
	adda.w	#$C0,a2

PrintParenNumber					;Print the number at d0 of a2 (1 to 3 digits) and ")"
	move.b	(a2,d0.w),d0
	ext.w	d0
	move.w	#1,d1
	cmp.w	#9,d0
	ble.w	.0
	move.w	#2,d1
	cmp.w	#$63,d0
	ble.w	.0
	move.w	#3,d1
.0
	jsr	(PushNumberWidth).l
	jsr	(print).l
	jsr	(printz).l
	String	$29
	addq.w	#1,(printy).w
	move.w	#$E,(printx).w
	movem.l	(sp)+,d0/a2
	rts

PlaceBoardFall						;places a player falling at the boards (tests the position word at $58)
	cmpi.w	#SPAboardmidl,$58(a3)
	beq.w	.10
	cmpi.w	#SPAboardmidr,$58(a3)
	beq.w	.8
	cmpi.w	#SPAboardleft,$58(a3)
	beq.w	.6
	cmpi.w	#SPAboardtop,$58(a3)
	beq.w	.0
	cmpi.w	#SPAboardbot,$58(a3)
	beq.w	.3
	bra.w	.11
.0
	move.w	#$124,d0
	cmpi.w	#$56,(FallXPos).w
	bgt.w	.1
	cmpi.w	#$FFAA,(FallXPos).w
	bgt.w	.2
.1
	move.w	#$116,d0
.2
	sub.w	Ypos(a3),d0
	bmi.w	.11
	asr.w	#1,d0
	add.w	d0,Ypos(a3)
	bra.w	.11
.3
	move.w	#$FEDC,d0
	cmpi.w	#$56,(FallXPos).w
	bgt.w	.4
	cmpi.w	#$FFAA,(FallXPos).w
	bgt.w	.5
.4
	move.w	#$FEEA,d0
.5
	sub.w	Ypos(a3),d0
	bpl.w	.11
	asr.w	#1,d0
	add.w	d0,Ypos(a3)
	bra.w	.11
.6
	move.w	#$90,d0
	btst	#3,4(a3)
	beq.w	.7
	move.w	#$FF70,d0
.7
	sub.w	(a3),d0
	asr.w	#1,d0
	add.w	d0,(a3)
	bra.w	.11
; Code kept as bytes (decoded by decode_code.py).
	dc.b	$30,$3C,$00,$96,$08,$2B,$00,$03,$00,$04,$67,$00,$00,$06,$30,$3C
	dc.b	$FF,$6A,$90,$53,$E2,$40,$D1,$53,$60,$00,$00,$32
.8
	move.w	#$FF70,d0
	btst	#3,4(a3)
	beq.w	.9
	move.w	#$90,d0
.9
	sub.w	(a3),d0
	asr.w	#1,d0
	add.w	d0,(a3)
	bra.w	.11
.10
	move.w	#$FF6A,d0
	btst	#3,4(a3)
	beq.w	*+4
.13
	sub.w	(a3),d0
	asr.w	#1,d0
	add.w	d0,(a3)
.11
	rts

getFgtbyte							;d0 = $75(a2) / 4
	clr.w	d0						;clear d0
	move.b	$75(a2),d0				;move H/F bit into d0 (this is always even)
	lsr.w	#2,d0					;shift 2 right (divide by 4)
	rts

chkFgtBit1							;Z set when $77(a2) is 2 or less (d0 kept)
	cmpi.b	#2,$77(a2)
	ble.w	.0
	movem.w	d0,-(sp)
	move.w	#1,d0
	movem.w	(sp)+,d0
	bra.w	.1
.0
	movem.w	d0,-(sp)
	move.w	#0,d0
	movem.w	(sp)+,d0
.1
	rts
; Code kept as bytes (decoded by decode_code.py).
	dc.b	$48,$E7,$00,$80,$20,$7C,$00,$1D,$90,$D0,$30,$3C,$00,$64,$4E,$B9
	dc.b	$00,$01,$B0,$A6,$02,$40,$00,$07,$D0,$40,$30,$30,$00,$00,$0C,$78
	dc.b	$FF,$C0,$BF,$E2,$6E,$00,$00,$10,$0C,$78,$00,$C0,$BF,$E4,$6E,$00
	dc.b	$00,$06,$30,$3C,$00,$06,$4C,$DF,$01,$00,$4E,$75,$00,$03,$00,$05
	dc.b	$00,$03,$00,$01,$00,$05,$00,$02,$00,$03,$00,$03,$FF,$FF,$48,$E7
	dc.b	$E0,$E0,$20,$7C,$FF,$FF,$C7,$26,$22,$7C,$FF,$FF,$CA,$C4,$30,$28
	dc.b	$00,$24,$90,$69,$00,$24,$67,$00,$00,$12,$6A,$00,$00,$04,$C1,$49
	dc.b	$0C,$68,$00,$06,$00,$28,$66,$00,$00,$02,$4C,$DF,$07,$07,$4E,$75

HiScoreScreen						;vb2, the HiScoreBgMap and HiScoreImg bitmaps, then wait up to $50 * 4
									;frames or a button (waitx)
	move.l	#vb2,(VBint).w
	bclr	#df32c,(disflags).w
	move.w	#5,(Map3col1).w
	move.w	#$A000,(VmMAP2).w
	move.w	#7,(Map2col1).w
	move.w	#$C000,(VmMAP1).w
	move.w	#7,(Map1col1).w
	move.w	#$F000,(VmMAP3).w
	move.w	#$F800,(VSPRITES).w
	move.w	#$FC00,(VSCRLPM).w
	jsr	(forceblack).l
	movea.w	#(palfadenew-M68K_RAM),a0
	moveq	#$1F,d1
.loop
	clr.l	(a0)+
	dbf	d1,.loop
	jsr	(setVram_0).l
	jsr	(printz).l
	String	CC_Font2Pri,$0E,$03
	movea.l	#HiScoreBgMap,a2
	movea.l	a2,a0
	movea.l	a2,a1
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	move.w	(a1),d2
	move.w	2(a1),d3
	clr.w	d4
	moveq	#$F,d5
	jsr	(dobitmap).l
	jsr	(printz).l
	String	CC_Font2Pri,$10,$10
	movea.l	#HiScoreImg,a2
	movea.l	a2,a0
	movea.l	a2,a1
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	move.w	(a1),d2
	move.w	2(a1),d3
	moveq	#0,d5
	jsr	(dobitmap).l
	move.w	#$18,(palcount).w
	move	#$2500,sr
	move.w	#$50,(seed).w
.loop2
	moveq	#4,d0
	jsr	(waitx).l
	tst.w	d1
	bne.w	.0
	subq.w	#1,(seed).w
	bpl.s	.loop2
.0
	jsr	(forceblack).l
	move	#$2700,sr
	rts
; Code kept as bytes (decoded by decode_code.py).
	dc.b	$24,$7C,$FF,$FF,$C7,$26,$B4,$6A,$00,$28,$67,$00,$00,$08,$24,$7C
	dc.b	$FF,$FF,$CA,$C4,$4E,$75

PrepShotPass						;Called before setpassmode / SetShotMode. Loads TempWord1 to d1 when the
									;clock is running, then the movem restores d1 so it has no effect.
	movem.l	d1-d7/a0,-(sp)
	btst	#gmclock,(gmode).w
	bne.w	.0
	move.w	(TempWord1).w,d1
.0
	movem.l	(sp)+,d1-d7/a0
	rts
; Code kept as bytes (decoded by decode_code.py).
	dc.b	$48,$E7,$FF,$FE,$22,$7C,$FF,$FF,$DC,$AE,$4E,$B9,$00,$1E,$6B,$24
	dc.b	$30,$38,$D3,$C0,$13,$BC,$00,$00,$00,$00,$52,$40,$02,$40,$FF,$FE
	dc.b	$33,$40,$FF,$FE,$4C,$DF,$7F,$FF,$4E,$75,$48,$E7,$FF,$BE,$30,$38
	dc.b	$D2,$48,$4A,$40,$67,$00,$00,$80,$22,$7C,$FF,$FF,$D3,$AE,$31,$C0
	dc.b	$D3,$C2,$4E,$B9,$00,$1E,$6B,$24,$D2,$F8,$D3,$C0,$12,$BC,$00,$00
	dc.b	$52,$78,$D3,$C0,$02,$78,$FF,$FE,$D3,$C0,$54,$78,$D3,$C0,$31,$F8
	dc.b	$D3,$C0,$D3,$AC,$22,$7C,$FF,$FF,$D3,$AC,$2F,$09,$26,$7C,$FF,$FF
	dc.b	$BF,$54,$22,$7C,$00,$1D,$92,$C8,$61,$00,$E7,$F4,$22,$5F,$26,$7C
	dc.b	$FF,$FF,$BF,$54,$4E,$B9,$00,$01,$BE,$80,$26,$7C,$FF,$FF,$BF,$54
	dc.b	$4E,$B9,$00,$01,$BE,$78,$00,$04,$29,$00,$22,$7C,$FF,$FF,$BF,$54
	dc.b	$4C,$DF,$7D,$FF,$4E,$75,$00,$0E,$28,$70,$6C,$61,$79,$65,$64,$20
	dc.b	$62,$79,$20,$00,$00,$02,$22,$7C,$00,$1D,$92,$D6,$60,$E2,$48,$E7
	dc.b	$FF,$BE,$30,$38,$D2,$4A,$60,$00,$FF,$6A

SetSflags8Bit1						;Always sets sflags8 bit 1 (the bclr is skipped)
	bra.w	.0
	dc.b	$08,$B8,$00,$01,$C3,$4C,$60,$00,$00,$08
.0
	bset	#1,(sflags8).w
	rts
; Code kept as bytes (decoded by decode_code.py).
	dc.b	$B0,$7C,$00,$50,$6C,$00,$00,$08,$E2,$40,$06,$40,$00,$28,$4E,$75
	dc.b	$48,$A7,$C0,$00,$30,$38,$B7,$5E,$90,$53,$B0,$7C,$00,$1E,$6E,$00
	dc.b	$00,$2A,$32,$38,$B7,$86,$B3,$40,$02,$40,$80,$00,$67,$00,$00,$1C
	dc.b	$30,$38,$B7,$72,$90,$6B,$00,$14,$B0,$7C,$00,$1E,$6E,$00,$00,$0C
	dc.b	$32,$38,$B7,$88,$B3,$40,$02,$40,$80,$00,$4C,$9F,$00,$03,$4E,$75

ReadGoaliePulled					;Z clear when the team of a3 pulled its goalie ($26 of the team struct).
									;Called from doshot, assdefo asspuckc
									;and assnearest
	movem.l	a1,-(sp)
	movea.l	#tmstruct,a1
	btst	#pfteam,pflags(a3)
	beq.w	.0
	movea.l	#AwShots,a1
.0
	tst.w	$26(a1)
	movem.l	(sp)+,a1
	rts

EndOneTimer							;End a one-timer for a3: the one-timer bits cleared, onetimerplayer = -1,
									;SetSPA $856
	movem.l	d0/a0,-(sp)
	bclr	#pf3onetimer,pflags3(a3)
	bclr	#pfalock,pflags(a3)
	bclr	#pf2aip,pflags2(a3)
	clr.w	(onetimerflags).w
	st	(onetimerplayer).w
	move.w	d1,-(sp)
	move.w	#SPAglide,d1			;SPA
	jsr	(SetSPA).l
	tst.w	$34(a3)
	bpl.w	.0
	jsr	(assexit).l
	bra.w	.1
.0
	jsr	(AssignBySavedPos).l
.1
	clr.w	$5A(a3)
	st	$5C(a3)
	move.w	(sp)+,d1
	movem.l	(sp)+,d0/a0
	rts

TeamLogoPalettes					;Team logo palettes, 16 colors per team
	dc.b	$0E,$EA,$00,$00,$00,$42,$0E,$EA,$0E,$EA,$0E,$EE,$00,$00,$08,$88
	dc.b	$0A,$AA,$00,$68,$00,$8A,$00,$CE,$02,$60,$00,$40,$06,$64,$0E,$8E
	dc.b	$0E,$E8,$00,$8C,$00,$00,$0A,$0A,$0A,$0A,$0E,$EE,$00,$00,$0C,$8C
	dc.b	$00,$8C,$08,$88,$00,$68,$08,$46,$00,$44,$04,$22,$08,$CE,$02,$AE
	dc.b	$0E,$E8,$08,$22,$00,$8C,$0E,$E8,$0E,$E8,$0E,$EE,$00,$00,$0E,$C8
	dc.b	$04,$8C,$0C,$88,$00,$6C,$08,$66,$02,$68,$02,$24,$06,$20,$00,$CE
	dc.b	$0E,$E8,$00,$06,$00,$8C,$0E,$E8,$0E,$E8,$0E,$EE,$00,$00,$08,$EE
	dc.b	$02,$CE,$02,$AE,$02,$6E,$00,$0C,$0E,$E8,$0E,$E8,$0E,$E8,$0E,$E8
	dc.b	$0E,$E8,$00,$00,$00,$06,$0E,$E8,$0E,$E8,$0E,$EE,$00,$00,$08,$EE
	dc.b	$0A,$8E,$04,$AC,$0A,$88,$04,$6C,$02,$26,$06,$44,$02,$2E,$02,$62
	dc.b	$0E,$E8,$00,$00,$00,$42,$0E,$E8,$0E,$E8,$0E,$EE,$00,$00,$08,$AA
	dc.b	$06,$88,$04,$88,$04,$66,$02,$44,$02,$60,$00,$20,$0A,$CC,$00,$00
	dc.b	$0E,$E8,$00,$06,$00,$06,$0E,$E8,$0E,$E8,$0E,$EE,$00,$00,$0C,$8E
	dc.b	$08,$6E,$04,$4E,$08,$2E,$02,$0E,$0E,$E8,$0E,$E8,$0E,$E8,$0E,$E8
	dc.b	$0E,$E8,$06,$00,$00,$4A,$0E,$E8,$0E,$E8,$0E,$EE,$00,$00,$0C,$EA
	dc.b	$0A,$8E,$08,$A8,$04,$4E,$04,$88,$00,$2E,$04,$40,$04,$00,$0E,$E8
	dc.b	$0E,$EA,$00,$4A,$06,$00,$0E,$EA,$0E,$EA,$0E,$EE,$00,$00,$08,$AE
	dc.b	$04,$AE,$00,$66,$00,$88,$02,$20,$0A,$84,$08,$42,$02,$00,$00,$2E
	dc.b	$0E,$E8,$00,$42,$08,$22,$0E,$E8,$0E,$E8,$0E,$EE,$00,$00,$00,$20
	dc.b	$00,$40,$0A,$8A,$00,$20,$04,$66,$02,$00,$02,$24,$08,$88,$04,$22
	dc.b	$0E,$E8,$00,$00,$00,$00,$0E,$E8,$0E,$E8,$0E,$EE,$00,$00,$0A,$AA
	dc.b	$08,$88,$06,$66,$04,$44,$02,$22,$0C,$CC,$0E,$E8,$0E,$E8,$0E,$E8
	dc.b	$0E,$E8,$06,$00,$00,$06,$0E,$E8,$0E,$E8,$0E,$EE,$00,$00,$08,$8E
	dc.b	$02,$6E,$0C,$68,$00,$2E,$0A,$24,$0E,$AA,$0E,$E8,$0E,$E8,$0E,$E8
	dc.b	$0E,$E8,$00,$20,$00,$06,$0E,$E8,$0E,$E8,$0E,$EE,$00,$00,$0A,$AA
	dc.b	$00,$0A,$08,$88,$00,$0C,$00,$22,$00,$06,$0C,$CC,$0E,$E8,$0E,$E8
	dc.b	$0E,$E8,$08,$22,$00,$4A,$0E,$E8,$0E,$E8,$0E,$EE,$00,$00,$0A,$A8
	dc.b	$06,$6E,$08,$64,$02,$2C,$06,$2A,$00,$08,$06,$22,$02,$22,$0A,$8E
	dc.b	$0E,$E8,$06,$00,$00,$06,$0E,$E8,$0E,$E8,$0E,$EE,$00,$00,$0A,$AA
	dc.b	$0C,$86,$00,$2E,$0C,$60,$08,$44,$04,$44,$08,$40,$00,$08,$0E,$C8
	dc.b	$0E,$E8,$00,$06,$00,$6A,$0E,$E8,$0E,$E8,$0E,$EE,$00,$00,$06,$8A
	dc.b	$06,$88,$04,$66,$02,$44,$02,$2C,$02,$28,$00,$08,$0A,$AA,$00,$04
	dc.b	$0E,$E8,$00,$00,$00,$4A,$0E,$E8,$0E,$E8,$0E,$EE,$00,$00,$0C,$CC
	dc.b	$08,$8E,$0A,$AA,$04,$6E,$00,$6E,$08,$88,$06,$66,$00,$2E,$04,$44
	dc.b	$0E,$E8,$00,$00,$00,$8C,$0E,$E8,$0E,$E8,$0E,$EE,$00,$00,$0A,$AA
	dc.b	$08,$8A,$06,$6A,$04,$EE,$04,$64,$04,$40,$02,$CE,$02,$44,$0A,$EE
	dc.b	$0E,$E8,$06,$00,$00,$06,$0E,$E8,$0E,$E8,$0E,$EE,$00,$00,$0C,$00
	dc.b	$00,$0E,$0E,$44,$0E,$CE,$0E,$80,$08,$8E,$0E,$E8,$0E,$E8,$0E,$E8
	dc.b	$0E,$E8,$00,$00,$08,$22,$0E,$E8,$0E,$E8,$0E,$EE,$00,$00,$08,$60
	dc.b	$06,$42,$08,$88,$0C,$A8,$0A,$CC,$02,$AE,$00,$6E,$00,$48,$04,$6A
	dc.b	$0E,$E8,$08,$22,$00,$6A,$0E,$E8,$0E,$E8,$0E,$EE,$00,$00,$06,$02
	dc.b	$02,$4C,$00,$02,$00,$26,$00,$68,$04,$28,$08,$6E,$0E,$E8,$0E,$E8
	dc.b	$0E,$E8,$00,$00,$06,$00,$0E,$E8,$0E,$E8,$0E,$EE,$00,$00,$0C,$86
	dc.b	$0E,$84,$0A,$84,$0C,$44,$08,$22,$0E,$20,$06,$00,$0A,$00,$0E,$A8
	dc.b	$0E,$E8,$06,$00,$06,$00,$0E,$E8,$0E,$E8,$0E,$EE,$00,$00,$0E,$CA
	dc.b	$0A,$AA,$0C,$66,$08,$22,$0C,$CC,$0E,$E8,$0E,$E8,$0E,$E8,$0E,$E8
	dc.b	$0E,$E8,$00,$00,$00,$8C,$0E,$E8,$0E,$E8,$0E,$EE,$00,$00,$00,$CE
	dc.b	$00,$6A,$00,$4E,$00,$28,$00,$22,$00,$20,$00,$8E,$08,$88,$06,$CE
	dc.b	$0E,$E8,$00,$06,$06,$00,$0E,$E8,$0E,$E8,$0E,$EE,$00,$00,$02,$2C
	dc.b	$0C,$86,$0E,$A8,$08,$8E,$08,$42,$0E,$E8,$0E,$E8,$0E,$E8,$0E,$E8
	dc.b	$0E,$E8,$06,$00,$00,$06,$0E,$E8,$0E,$E8,$0E,$EE,$00,$00,$02,$2C
	dc.b	$04,$22,$0A,$AC,$06,$66,$0C,$AA,$04,$44,$06,$6E,$08,$CE,$02,$26
	dc.b	$0E,$E8,$00,$00,$00,$4A,$0E,$E8,$0E,$E8,$0E,$EE,$00,$00,$06,$88
	dc.b	$04,$64,$02,$44,$02,$22,$00,$4E,$00,$0A,$00,$22,$0A,$AA,$00,$00
	dc.b	$0E,$E8,$00,$00,$00,$4A,$0E,$E8,$0E,$E8,$0E,$EE,$00,$00,$06,$88
	dc.b	$04,$64,$02,$44,$02,$22,$00,$4E,$00,$0A,$00,$22,$0A,$AA,$00,$00

LeadSong							;Not in a shootout (gmode2 bit 1) and one team has more players on ice
									;(tmap): once (sflags2 bit 5) ChooseSong
									;with SongIndex 1 (home) or 4, and sflags8 bit 6; sflags2 bit 6 keeps
									;which team. sflags2 is put back on exit. Called from puckfaceoff2.
									;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$80,$F0,$3F,$38,$C3,$3C,$08,$38,$00,$01,$C3,$48,$66,$00
	dc.b	$00,$92,$34,$7C,$C7,$26,$47,$EA,$03,$9E,$30,$2A,$00,$24,$90,$6B
	dc.b	$00,$24,$67,$00,$00,$7E,$6A,$00,$00,$1A,$08,$38,$00,$06,$C3,$3C
	dc.b	$66,$00,$00,$26,$61,$00,$00,$64,$08,$F8,$00,$06,$C3,$3C,$60,$00
	dc.b	$00,$18,$C5,$4B,$08,$38,$00,$06,$C3,$3C,$67,$00,$00,$0C,$61,$00
	dc.b	$00,$4A,$08,$B8,$00,$06,$C3,$3C,$08,$F8,$00,$05,$C3,$3C,$66,$00
	dc.b	$00,$42,$B6,$FC,$C7,$26,$66,$00,$00,$1E,$31,$F8,$C3,$A0,$D4,$8C
	dc.b	$31,$FC,$00,$01,$D4,$8E,$4E,$B9,$00,$08,$86,$88,$08,$F8,$00,$06
	dc.b	$C3,$4C,$60,$00,$00,$1E,$31,$F8,$C3,$A0,$D4,$8C,$31,$FC,$00,$04
	dc.b	$D4,$8E,$4E,$B9,$00,$08,$86,$88,$60,$E2,$08,$B8,$00,$05,$C3,$3C
	dc.b	$4E,$75,$31,$DF,$C3,$3C,$4C,$DF,$0F,$01,$4E,$75

ClearPenalties						;Clear the penalties: PBnum, Penaltytimer, PenCntDwn, PenBuf and both
									;teams' penalty slots (clrTmPdst)
	movem.l	d0/a0,-(sp)
	clr.w	(PBnum).w
	clr.w	(Penaltytimer).w
	clr.w	(PenCntDwn).w
	move.w	#$10,d0
	movea.l	#$FFFFC3A6,a0
.loop
	clr.l	(a0)+
	dbf	d0,.loop
	movea.l	#tmstruct,a0
	bsr.w	clrTmPdst
	movea.l	#AwShots,a0
	bsr.w	clrTmPdst
	movem.l	(sp)+,d0/a0
	rts

clrTmPdst							;Set the 26 tmpdst words of team a0 to -2 (bench), then -1
	move.w	#$1B,d0					;19 = 25 decimal (max roster size)
	adda.w	#$6C,a0
.loop
	move.w	#$FFFE,(a0)+			;-2 = bench
	dbf	d0,.loop
	move.w	#$FFFF,(a0)
	rts

SetMenuPadSide						;sflags bit 1 set when the team of pad menupadnum is above 1, else
									;cleared. Called from ManualGoalieMenu and
									;PrintMenuItem
	movem.l	d0/a0-a1,-(sp)
	movea.l	#padteams,a0
	move.w	(menupadnum).w,d0
	asl.w	#2,d0
	movea.l	(a0,d0.w),a0
	cmpi.w	#1,(a0)
	movem.l	(sp)+,d0/a0-a1
	ble.w	.0
	bset	#1,(sflags).w
	bra.w	.exit
.0
	bclr	#1,(sflags).w
.exit
	rts

padteams							;The team word of each pad: cont1team ... cont4team
	dc.b	$FF,$FF,$C3,$90,$FF,$FF,$C3,$92,$FF,$FF,$C3,$94,$FF,$FF,$C3,$96
	dc.b	$08,$38,$00,$03,$C3,$3A,$66,$00,$00,$2E,$48,$E7,$A0,$80,$10,$2B
	dc.b	$00,$62,$12,$38,$C3,$64,$B3,$00,$08,$00,$00,$06,$67,$00,$00,$44
	dc.b	$60,$00,$00,$38,$08,$38,$00,$03,$C3,$3A,$67,$00,$00,$3A,$4A,$78
	dc.b	$B7,$BE,$6B,$00,$00,$32,$48,$E7,$A0,$80,$20,$7C,$FF,$FF,$B0,$5E
	dc.b	$30,$38,$B7,$BE,$EF,$40,$D0,$C0,$10,$28,$00,$62,$14,$2B,$00,$62
	dc.b	$B5,$00,$08,$00,$00,$06,$67,$00,$00,$0A,$32,$3C,$09,$9A,$60,$00
	dc.b	$00,$02,$4C,$DF,$01,$05,$4E,$75

CanBlock							;Ne when joystick player a3 may block the shot (SPAblock): pfalock clear,
									;sflags sfssdir set and GameFlags bit
									;2 clear (one block per shot; cleared while sfssdir is clear), a3 at y $56
									;or more toward the goal it shoots at, the puck carrier on the other team,
									;the direction (vtoa) from a3 to the puck the same as from the goal at y
									;$10B to the puck, a3 on the puck's side of x 0 and within y $B2 of it,
									;and a3 facing that direction or one next to it. d0 is restored.
	movem.l	d0-d3/a0-a2,-(sp)
	btst	#pfalock,pflags(a3)
	bne.w	.6
	btst	#sfssdir,(sflags).w
	bne.w	.1
	bclr	#3,(sflags10).w
.1
	btst	#3,(sflags10).w
	bne.w	.6
	move.w	Ypos(a3),d0
	btst	#pfgoal,pflags(a3)
	beq.w	.2
	neg.w	d0
.2
	cmp.w	#$76,d0
	blt.w	.6
	tst.w	(puckc).w
	bmi.w	.6
	movea.l	#SortCords,a0
	move.w	(puckc).w,d0
	asl.w	#7,d0
	adda.w	d0,a0
	move.b	$62(a0),d0
	move.b	pflags(a3),d1
	eor.b	d1,d0
	btst	#pfteam,d0
	beq.w	.6
	btst	#sfssdir,(sflags).w
	beq.w	.6
	move.w	(puckx).w,d0			;d0 = direction from a3 to the puck
	sub.w	(a3),d0
	move.w	(pucky).w,d1
	sub.w	Ypos(a3),d1
	jsr	(vtoa).l
	move.w	d0,-(sp)
	move.w	(puckx).w,d0			;direction from the goal at y $10B to the puck
	move.w	#$11E,d1
	btst	#pfgoal,pflags(a3)
	beq.w	.3
	neg.w	d1
.3
	sub.w	(pucky).w,d1
	neg.w	d1
	jsr	(vtoa).l
	cmp.w	(sp)+,d0
	bne.w	.6
	movem.w	d0,-(sp)
	move.w	(a3),d1
	move.w	(puckx).w,d0
	eor.w	d0,d1
	movem.w	(sp)+,d0
	bmi.w	.6
	move.w	(pucky).w,d1
	sub.w	Ypos(a3),d1
	bpl.w	.4
	neg.w	d1
.4
	cmp.w	#$BE,d1
	bgt.w	.6
	cmp.w	facedir(a3),d0
	beq.w	.5
	addq.w	#1,d0
	andi.w	#3,d0
	cmp.w	facedir(a3),d0
	beq.w	.5
	subq.w	#2,d0
	andi.w	#3,d0
	cmp.w	facedir(a3),d0
	bne.w	.6
.5
	move.w	#1,d0
	bra.w	.7
.6
	clr.w	d0
.7
	movem.l	(sp)+,d0-d3/a0-a2
	rts
; Code kept as bytes (decoded by decode_code.py).
	dc.w	$48E7,$FFFE,$4278,$D312,$6100,$00CA,$6100,$00C8
	dc.w	$207C,$0018,$3024,$4EB9,$0001,$218A,$31FC,$0018
	dc.w	$BD3C,$08B8,$0002,$BFB2,$4278,$D14C,$6100,$02EA
	dc.w	$207C,$FFFF,$D168,$4EB9,$0001,$161E,$6100,$028E
	dc.w	$6100,$0356,$6100,$03D2,$46FC,$2500,$3038,$B052
	dc.w	$B078,$B052,$67FA,$4EB9,$0001,$2640,$0C78,$5460
	dc.w	$D312,$4EB9,$0001,$B2C4,$4EB9,$0001,$B320,$4A41
	dc.w	$6700,$0006,$4278,$D312,$0801,$0007,$6600,$0048
	dc.w	$0801,$0002,$6700,$000A,$0A78,$0001,$D14C,$609C
	dc.w	$0801,$0003,$6700,$000A,$0A78,$0001,$D14C,$608C
	dc.w	$0801,$0000,$6700,$000C,$0A78,$0002,$D14C,$6000
	dc.w	$FF7C,$0801,$0001,$6700,$000C,$0A78,$0002,$D14C
	dc.w	$6000,$FF6A,$6086,$21FC,$0001,$22A4,$DDAC,$4CDF
	dc.w	$7FFF,$4E75,$4E75,$08F8,$0005,$C356,$21FC,$0001
	dc.w	$2D46,$D244,$08B8,$0000,$BFB2,$08F8,$0002,$BFB2
	dc.w	$08B8,$0001,$BFB2,$31FC,$0000,$B000,$31FC,$B400
	dc.w	$B00C,$31FC,$0005,$B00E,$31FC,$BC00,$B002,$31FC
	dc.w	$C000,$B008,$31FC,$0006,$B00A,$31FC,$E000,$B004
	dc.w	$31FC,$0006,$B006,$303C,$0000,$08F8,$0005,$BFB2
	dc.w	$4EB9,$0001,$B57E,$08B8,$0005,$BFB2,$4EB9,$0001
	dc.w	$B2C4,$383C,$0001,$227C,$0018,$3024,$4EB9,$0001
	dc.w	$217A,$31C4,$B01C,$247C,$0017,$A16C,$4EB9,$0001
	dc.w	$B730,$5344,$21FC,$0017,$A164,$BF8A,$31C4,$B014
	dc.w	$247C,$0017,$AA7A,$4EB9,$0001,$B730,$0444,$0009
	dc.w	$31C4,$B018,$247C,$0017,$B688,$4EB9,$0001,$B730
	dc.w	$323C,$0019,$4242,$207C,$FFFF,$2328,$227C,$0001
	dc.w	$2BFE,$B47C,$0001,$6600,$001E,$3F04,$3838,$B01C
	dc.w	$5244,$30C4,$2469,$0004,$504A,$4EB9,$0001,$B730
	dc.w	$381F,$6000,$0014,$30C4,$3002,$E540,$2471,$0000
	dc.w	$504A,$4EB9,$0001,$B730,$5242,$51C9,$FFC6,$4EB9
	dc.w	$0001,$BA2E,$0008,$FF01,$FD00,$FC00,$7028,$721C
	dc.w	$343C,$07FF,$4EB9,$0001,$B976,$4EB9,$0001,$BB8E
	dc.w	$0006,$BF00,$0000,$207C,$0018,$1456,$2248,$2448
	dc.w	$D1DA,$D3DA,$4240,$4241,$7428,$761C,$7A08,$4EB9
	dc.w	$0001,$B692,$4EB9,$0001,$BB8E,$0006,$BF0B,$0100
	dc.w	$207C,$0018,$0C36,$2248,$2448,$D1DA,$D3DA,$4240
	dc.w	$4241,$3411,$3629,$0002,$7A08,$4EB9,$0001,$B692
	dc.w	$4EB9,$0001,$BB8E,$0006,$FE00,$0000,$207C,$0017
	dc.w	$0B0C,$2248,$2448,$D1DA,$D3DA,$4240,$4241,$7440
	dc.w	$761C,$7A01,$4EB9,$0001,$B692,$4EB9,$0001,$BC72
	dc.w	$001E,$8F06,$1A7B,$7D20,$434F,$4E46,$4552,$454E
	dc.w	$4345,$205B,$5D20,$4449,$5649,$5349,$4F4E,$08F8
	dc.w	$0002,$C354,$4EB9,$0001,$BED6,$001C,$F804,$0114
	dc.w	$0857,$F804,$0119,$084C,$F804,$011E,$0854,$F804
	dc.w	$0122,$0850,$5453,$46FC,$2500,$4E75

