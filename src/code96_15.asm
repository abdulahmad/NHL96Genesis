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
	move.w	#$96,d0
	btst	#3,4(a3)
	beq.w	.12
	move.w	#$FF6A,d0
.12
	sub.w	(a3),d0
	asr.w	#1,d0
	add.w	d0,(a3)
	bra.w	PlaceBoardFallExit
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
PlaceBoardFallExit	equ	*			;Shared return of PlaceBoardFall
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
PickFaceoffDirection	equ	*			;d0 = a random direction word from the table at $1D90D0; 6 near the center
	movem.l	a0,-(sp)
	movea.l	#$1D90D0,a0
	move.w	#$64,d0
	jsr	(randomd0).l
	andi.w	#7,d0
	add.w	d0,d0
	move.w	(a0,d0.w),d0
	cmpi.w	#$FFC0,(fox).w
	bgt.w	.2
	cmpi.w	#$C0,(foy).w
	bgt.w	.2
	move.w	#6,d0
.2
	movem.l	(sp)+,a0
	rts
	dc.b	$00,$03,$00,$05,$00,$03,$00,$01,$00,$05,$00,$02,$00,$03,$00,$03
	dc.b	$FF,$FF
chkFgtBit1ShotsLead	equ	*
	movem.l	d0-d2/a0-a2,-(sp)
	movea.l	#tmstruct,a0
	movea.l	#AwShots,a1
	move.w	$24(a0),d0				;home players on ice
	sub.w	$24(a1),d0
	beq.w	.4						;same number on the ice: done
	bpl.w	.3						;home has more: test home
	exg	a0,a1						;away has more: test the away team
.3
	cmpi.w	#6,$28(a0)
	bne.w	.4						;(the branch goes to the next line either way)
	;exit: restore the registers
.4
	movem.l	(sp)+,d0-d2/a0-a2
	rts

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
	movea.l	#tmstruct,a2
	cmp.w	Xvel(a2),d2
	beq.w	.1
	movea.l	#AwShots,a2
.1
	rts

PrepShotPass						;Called before setpassmode / SetShotMode. Loads TempWord1 to d1 when the
									;clock is running, then the movem restores d1 so it has no effect.
	movem.l	d1-d7/a0,-(sp)
	btst	#gmclock,(gmode).w
	bne.w	.0
	move.w	(TempWord1).w,d1
.0
	movem.l	(sp)+,d1-d7/a0
	rts
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#OptPad+8,a1
	jsr	(GetLogName).l
	move.w	(NameEntryLen).w,d0
	move.b	#0,(a1,d0.w)
	addq.w	#1,d0
	andi.w	#$FFFE,d0
	move.w	d0,-$2(a1)
	movem.l	(sp)+,d0-d7/a0-a6
	rts
	movem.l	d0-d7/a0/a2-a6,-(sp)
	move.w	(pad1user).w,d0
.loop
	tst.w	d0
	beq.w	.1
	movea.l	#NameEntryBuf+2,a1
	move.w	d0,(namelogsel).w
	jsr	(GetLogName).l
	adda.w	(NameEntryLen).w,a1
	move.b	#0,(a1)
	addq.w	#1,(NameEntryLen).w
	andi.w	#$FFFE,(NameEntryLen).w
	addq.w	#2,(NameEntryLen).w
	move.w	(NameEntryLen).w,(NameEntryBuf).w
	movea.l	#NameEntryBuf,a1
	move.l	a1,-(sp)
	movea.l	#TempLegSpd+2,a3
	movea.l	#$1D92C8,a1
	bsr.w	CopyString
	movea.l	(sp)+,a1
	movea.l	#TempLegSpd+2,a3
	jsr	(appstring).l
	movea.l	#TempLegSpd+2,a3
	jsr	(appendz).l
	String	')'
	movea.l	#TempLegSpd+2,a1
.loop2
	movem.l	(sp)+,d0-d7/a0/a2-a6
	rts
	dc.w	$000E,$2870,$6C61,$7965,$6420,$6279,$2000,$0002
.1
	movea.l	#$1D92D6,a1
	bra.s	.loop2
	movem.l	d0-d7/a0/a2-a6,-(sp)
	move.w	(pad2user).w,d0
	bra.w	.loop

SetSflags8Bit1						;Always sets sflags8 bit 1 (the bclr is skipped)
	bra.w	.0
	dc.b	$08,$B8,$00,$01,$C3,$4C,$60,$00,$00,$08
.0
	bset	#1,(sflags8).w
	rts
SoftClampCoord	equ	*			;d0 = d0 (or d0 / 2 + $28 when under $50)
	cmp.w	#$50,d0
	bge.w	.exit
	asr.w	#1,d0
	addi.w	#$28,d0
.exit
	rts
	movem.w	d0-d1,-(sp)
	move.w	(puckx).w,d0
	sub.w	(a3),d0
	cmp.w	#$1E,d0
	bgt.w	.next
	move.w	(puckvx).w,d1
	eor.w	d1,d0
	andi.w	#$8000,d0
	beq.w	.next
	move.w	(pucky).w,d0
	sub.w	Ypos(a3),d0
	cmp.w	#$1E,d0
	bgt.w	.next
	move.w	(puckvy).w,d1
	eor.w	d1,d0
	andi.w	#$8000,d0
.next
	movem.w	(sp)+,d0-d1
	rts

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
	movem.l	d0/a0-a3,-(sp)
	move.w	(sflags2).w,-(sp)
	btst	#1,(gmode2).w
	bne.w	LeadSongExit
	movea.w	#(tmstruct-M68K_RAM),a2
	lea	$39E(a2),a3
	move.w	$24(a2),d0
	sub.w	$24(a3),d0
	beq.w	LeadSongExit
	bpl.w	.1
	btst	#sf2pwrtm,(sflags2).w
	bne.w	.2
	bsr.w	ClearSongLeadFlag
	bset	#sf2pwrtm,(sflags2).w
	bra.w	.2
.1
	exg	a2,a3
	btst	#sf2pwrtm,(sflags2).w
	beq.w	.2
	bsr.w	ClearSongLeadFlag
	bclr	#sf2pwrtm,(sflags2).w
.2
	bset	#sf2pwrplay,(sflags2).w
	bne.w	LeadSongExit
	cmpa.w	#(tmstruct-M68K_RAM),a3
	bne.w	.3
	move.w	(HomeTeam).w,(HmTeam).w
	move.w	#1,(SongIndex).w
	jsr	(ChooseSong).l
.loop
	bset	#6,(sflags8).w
	bra.w	LeadSongExit
.3
	move.w	(HomeTeam).w,(HmTeam).w
	move.w	#4,(SongIndex).w
	jsr	(ChooseSong).l
	bra.s	.loop
ClearSongLeadFlag					;Clear sflags2 bit 5
	bclr	#5,(sflags2).w
	rts
LeadSongExit	equ	*	;Restore sflags2 and the registers and return
	move.w	(sp)+,(sflags2).w
	movem.l	(sp)+,d0/a0-a3
	rts

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
	movem.l	d0-d7/a0-a6,-(sp)
	clr.w	(carddelay).w
	bsr.w	CanBlockExit
	bsr.w	CanBlockScreenInit
	movea.l	#StandingsSprites,a0
	jsr	(DrawScreenSprite).l
	move.w	#$18,(palcount).w
	bclr	#2,(disflags).w
	clr.w	(StandingsMode).w
.loop
	bsr.w	StandingsGroups
	movea.l	#StandingsBuf,a0
	jsr	(ReadStandings).l
	bsr.w	StandingsPoints
	bsr.w	SortStandings
	bsr.w	SortStandingsHeaders
	move.w	#$2500,sr
.loop2
	move.w	(Vcount).w,d0			;frame counter
	;loop
.loop3
	cmp.w	(Vcount).w,d0
	beq.s	.loop3					;wait for a new frame
	jsr	(SetMenuScroll).l			;read the pads
	cmpi.w	#$5460,(carddelay).w
	jsr	(orjoy).l
	jsr	(ProcessInputWithRepeat).l
	tst.w	d1
	beq.w	.8
	clr.w	(carddelay).w
.8
	btst	#7,d1
	bne.w	.13
	btst	#2,d1
	beq.w	.9
	eori.w	#1,(StandingsMode).w
	bra.s	.loop
.9
	btst	#3,d1
	beq.w	.10
	eori.w	#1,(StandingsMode).w
	bra.s	.loop
.10
	btst	#0,d1
	beq.w	.11
	eori.w	#2,(StandingsMode).w
	bra.w	.loop
.11
	btst	#1,d1
	beq.w	.12
	eori.w	#2,(StandingsMode).w
	bra.w	.loop
.12
	bra.s	.loop2
.13
	move.l	#SeasonMenuScreen,(NextScreenPtr).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts
CanBlockExit	equ	*	;Shared return of CanBlock
	rts
CanBlockScreenInit					;Set up the menu screen planes and VBlank handler (low confidence)
	bset	#5,(sflags12).w
	move.l	#VBlank_Menus,(VBint).w
	bclr	#dfok,(disflags).w
	bset	#dfng,(disflags).w
	bclr	#df32c,(disflags).w
	move.w	#0,(VSCRLPM).w
	move.w	#$B400,(VmMAP3).w
	move.w	#5,(Map3col1).w
	move.w	#$BC00,(VSPRITES).w
	move.w	#$C000,(VmMAP2).w
	move.w	#6,(Map2col1).w
	move.w	#$E000,(VmMAP1).w
	move.w	#6,(Map1col1).w
	move.w	#0,d0
	bset	#5,(disflags).w
	jsr	(setVram).l
	bclr	#5,(disflags).w
	jsr	(orjoy).l
	move.w	#1,d4
	movea.l	#StandingsSprites,a1
	jsr	(LoadScreenSprite).l
	move.w	d4,(smallfontchars).w
	movea.l	#SmallFontMap2+8,a2
	jsr	(DecompressGraphicsPlain).l
	subq.w	#1,d4
	move.l	#SmallFontMap2,(smallfontptr).w
	move.w	d4,(printbigchars).w
	movea.l	#BigFontMap2+8,a2
	jsr	(DecompressGraphicsPlain).l
	subi.w	#9,d4
	move.w	d4,(BigFontchars).w
	movea.l	#BigFontMap4+8,a2
	jsr	(DecompressGraphicsPlain).l
	move.w	#$19,d1
	clr.w	d2
	movea.l	#$FFFF2328,a0
	movea.l	#TeamBlockPtrs,a1
.loop
	cmp.w	#1,d2
	bne.w	.8
	move.w	d4,-(sp)
	move.w	(smallfontchars).w,d4
	addq.w	#1,d4
	move.w	d4,(a0)+
	movea.l	4(a1),a2
	addq.w	#8,a2
	jsr	(DecompressGraphicsPlain).l
	move.w	(sp)+,d4
	bra.w	.9
.8
	move.w	d4,(a0)+
	move.w	d2,d0
	asl.w	#2,d0
	movea.l	(a1,d0.w),a2
	addq.w	#8,a2
	jsr	(DecompressGraphicsPlain).l
.9
	addq.w	#1,d2
	dbf	d1,.loop
	jsr	(printsmallz).l
	String	$FF,1,$FD,0,$FC
	moveq	#$28,d0
	moveq	#$1C,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),0,0
	movea.l	#StandingsBgMap,a0
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
	movea.l	#StandingsTitleMap,a0
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
	jsr	(printcurz).l
	String	$8F,6,$1A,'{} CONFERENCE [] DIVISION'
	bset	#2,(sflags11).w
	jsr	(printbigz).l
	String	$F8,4,1,$14,8,'W',$F8,4,1,$19,8,'L',$F8,4,1,$1E,8,'T',$F8,4,1,$22,8,'PTS'
	move.w	#$2500,sr
	rts

