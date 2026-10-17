;	The intermission. Intermission runs the between-period screens, and SetScore
;	updates the other games on the ticker.

Intermission	;Before the period: at game over (gsp 4) the records (UpdateRecords), then the intermission screens
	cmpi.w	#4,(gsp).w
	bne.w	.1
	move.w	#0,(gameclock).w
	jsr	(UpdateRecords).l
	btst	#7,(GameFlags).w
	beq.w	.1
	movem.l	a2,-(sp)
	jsr	(FindUserGame).l
	cmpa.l	#0,a2
	beq.w	.0
	move.b	(HmGoals+1).w,2(a2)
	move.b	(AwGoals+1).w,3(a2)
	jsr	(SaveUserGame).l
	jsr	(SaveGameStats).l
.0
	movem.l	(sp)+,a2
.1
	bsr.w	SetupTeamForIntermission
	moveq	#$F,d0
	movea.w	#(SortCords-M68K_RAM),a0
.clr
	clr.w	(a0)
	adda.w	#$80,a0
	dbf	d0,.clr
	move.w	(gsp).w,d0
	tst.w	(OptPlayMode).w
	beq.w	.2
	addq.w	#5,d0
.2
	asl.w	#2,d0
	lea	IntermissionMenus(pc),a0
	movea.l	(a0,d0.w),a0
	btst	#0,(gmode2).w
	beq.w	.3
	movea.l	#ShootoutIntermissionMenu,a0
.3
	bset	#0,(sflags).w
	movea.l	#SetupPauseScreen,a1
	jsr	(InitMenuState).l
	move.w	#$A8C,(IntermissionTimer).w
.4
	tst.w	(demoflag).w
	bne.w	.periodic
	subq.w	#1,(IntermissionTimer).w
	bmi.w	.5
.periodic
	jsr	(vcountwait).l
	jsr	(FindHeldMenuPad).l
	jsr	(ProcessInputWithRepeat).l
	jsr	(HandleMenuInput).l
	bne.s	.4
.5
	jsr	(forceblack).l
	rts
	dc.b	$4E,$75

IntermissionMenus	;The intermission menu by gsp, then the same with OptPlayMode (gsp + 5)
	dc.l	PregameMenu,IntermissionMenu,IntermissionMenu,IntermissionMenu,GameOverMenu
	dc.l	PlayoffPregameMenu,IntermissionMenu,IntermissionMenu,IntermissionMenu,PlayoffGameOverMenu

InitScores	;Early in the playoffs (gamelevel 0-1): 0-3 random SetScore goals for the other games of the day
	cmpi.w	#1,(gamelevel).w
	bgt.w	rtss2
	bsr.w	GetShifter
	movea.w	#(gsstruct-M68K_RAM),a0
	moveq	#$10,d0
	mulu.w	d1,d0
	adda.w	d0,a0
.top
	cmp.w	(gamenum).w,d1
	beq.w	.2
	btst	#2,$E(a0)
	bne.w	.2
	clr.w	8(a0)
	moveq	#3,d0
	bsr.w	randomd0
	bra.w	.1
.0
	bsr.w	SetScore
.1
	dbf	d0,.0
.2
	suba.w	#$10,a0
	dbf	d1,.top
	rts

UpdateScores	;Update the ticker score values of the other games (SetScore). Called from PeriodOver
	bsr.w	GetShifter
	move.w	d1,(TickerNum).w
	movea.w	#(gsstruct-M68K_RAM),a0
	moveq	#$10,d0
	mulu.w	d1,d0
	adda.w	d0,a0
.top
	cmp.w	(gamenum).w,d1
	beq.w	.next
	bclr	#1,$E(a0)
	btst	#2,$E(a0)
	bne.w	.next
	bsr.w	SetScore
.next
	suba.w	#$10,a0
	dbf	d1,.top
	rts

SetScore	;Add to the score of the game in a0. After period 3 a game within one goal goes to OT (gsper 3) and asks for a
	;highlight
	cmpi.w	#4,8(a0)
	bge.w	rtss2
	movem.l	d0-d1/a0-a1,-(sp)
	cmpi.w	#3,8(a0)
	bne.w	.o
	move.w	#5,8(a0)
	move.w	$A(a0),d0
	sub.w	$C(a0),d0
	cmp.w	#1,d0
	bgt.w	.ex
	cmp.w	#$FFFF,d0
	blt.w	.ex
	move.w	#3,8(a0)
	bset	#1,$E(a0)
	bra.w	.ex
.o
	addq.w	#1,8(a0)
	move.w	(a0),d0
	move.w	2(a0),d1
	bsr.w	.3
	add.w	d0,$A(a0)
	move.w	2(a0),d0
	move.w	(a0),d1
	bsr.w	.3
	add.w	d0,$C(a0)
.ex
	movem.l	(sp)+,d0-d1/a0-a1
	rts

.3	;SetScore: the goal weights of the teams of the game (sctab rows by team rating)
	asl.w	#2,d0
	movea.w	#TeamList,a1
	movea.l	(a1,d0.w),a1
	adda.w	8(a1),a1
	move.b	(a1),d0
	andi.w	#$70,d0
	lsr.w	#1,d0
	lea	sctab(pc),a1
	move.l	(a1,d0.w),(nibblebuffer).w
	move.l	4(a1,d0.w),(nibblebuffer+4).w
	asl.w	#2,d1
	movea.w	#TeamList,a1
	movea.l	(a1,d1.w),a1
	adda.w	8(a1),a1
	move.b	(a1),d0
	andi.w	#7,d0
	asl.w	#3,d0
	lea	sctab(pc),a1
	move.l	(a1,d0.w),d1
	add.l	d1,(nibblebuffer).w
	move.l	4(a1,d0.w),d1
	add.l	d1,(nibblebuffer+4).w
	moveq	#4,d0
	bra.w	WeightedRandomSelect

sctab	;Weights for 0, 1, 2, 3 goals, 8 rows
	dc.w	$2B,$1E,$17,$4
	dc.w	$27,$20,$18,$5
	dc.w	$23,$21,$1A,$6
	dc.w	$1E,$22,$1E,$6
	dc.w	$1A,$24,$1E,$8
	dc.w	$16,$25,$1F,$A
	dc.w	$13,$26,$1F,$C
	dc.w	$F,$26,$20,$F
	;After sctab: code that nothing in the listing reaches.
	;Code the listing does not decode: kept as bytes
	dc.b	$76,$FF,$0C,$78,$01,$E0,$C4,$BE,$6E,$00,$21,$EE,$36,$38,$D0,$26
	dc.b	$6B,$00,$21,$E6,$53,$78,$D0,$26,$B6,$78,$CF,$C4,$67,$EE,$70,$10
	dc.b	$C0,$C3,$30,$7C,$CF,$44,$D0,$C0,$08,$28,$00,$01,$00,$0E,$66,$DC
	dc.b	$08,$28,$00,$02,$00,$0E,$66,$D4,$4E,$75,$4A,$43,$6B,$00,$21,$BA
	dc.b	$61,$00,$01,$2A,$61,$00,$E3,$18,$52,$78,$B0,$40,$59,$78,$B0,$42
	dc.b	$3F,$38,$B0,$40,$61,$00,$4E,$3A,$31,$FC,$A0,$00,$B0,$44,$61,$00
	dc.b	$E4,$DC,$00,$1A,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	dc.b	$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$31,$D7,$B0,$40
	dc.b	$70,$01,$D0,$78,$CF,$CA,$4A,$78,$D2,$54,$66,$00,$00,$04,$42,$40
	dc.b	$43,$FA,$00,$7E,$61,$00,$01,$02,$30,$28,$00,$08,$53,$40,$22,$7C
	dc.b	$00,$02,$33,$84,$61,$00,$00,$FA,$30,$11,$E2,$48,$44,$40,$D0,$57
	dc.b	$06,$40,$00,$17,$31,$C0,$B0,$40,$61,$00,$E4,$94,$31,$FC,$80,$00
	dc.b	$B0,$44,$30,$28,$00,$02,$32,$28,$00,$0C,$61,$00,$00,$10,$30,$10
	dc.b	$32,$28,$00,$0A,$61,$00,$00,$06,$54,$4F,$4E,$75,$31,$EF,$00,$04
	dc.b	$B0,$40,$52,$78,$B0,$42,$32,$7C,$07,$7E,$E5,$40,$22,$71,$00,$00
	dc.b	$D2,$E9,$00,$04,$61,$00,$E4,$58,$31,$EF,$00,$04,$B0,$40,$06,$78
	dc.b	$00,$15,$B0,$40,$30,$01,$72,$02,$61,$00,$E6,$C0,$60,$00,$E4,$40
	dc.b	$00,$12,$45,$41,$20,$48,$6F,$63,$6B,$65,$79,$20,$4E,$69,$67,$68
	dc.b	$74,$00,$00,$18,$53,$74,$61,$6E,$6C,$65,$79,$20,$43,$75,$70,$20
	dc.b	$51,$75,$61,$6C,$69,$66,$69,$65,$72,$00,$00,$0E,$51,$75,$61,$72
	dc.b	$74,$65,$72,$66,$69,$6E,$61,$6C,$00,$18,$53,$74,$61,$6E,$6C,$65
	dc.b	$79,$20,$43,$75,$70,$20,$53,$65,$6D,$69,$66,$69,$6E,$61,$6C,$00
	dc.b	$61,$00,$00,$0A,$34,$3C,$07,$FF,$60,$00,$E1,$BA,$61,$00,$E3,$CE
	dc.b	$00,$06,$BD,$03,$17,$00,$08,$38,$00,$00,$C3,$3A,$66,$00,$00,$0C
	dc.b	$61,$00,$E3,$BA,$00,$06,$BF,$03,$17,$00,$70,$1A,$72,$05,$4E,$75

PrintBigListItem	;printbig String d0 of the String list a1 (SkipStrings).
	;Code the listing does not decode: kept as bytes
	dc.b	$61,$00,$00,$0E,$60,$00,$E7,$04

PrintSmallListItem	;printsmall String d0 of the String list a1 (SkipStrings).
	;Code the listing does not decode: kept as bytes
	dc.b	$61,$00,$00,$06,$60,$00,$E2,$50

SkipStrings	;a1 = String d0 of the String list a1
	bra.w	.1
.0
	adda.w	(a1),a1
.1
	dbf	d0,.0
	rts

