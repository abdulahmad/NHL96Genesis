;	The intermission. Intermission runs the between-period screens, and SetScore
;	updates the other games on the ticker.

Intermission						;Before the period: at game over (gsp 4) the records (UpdateRecords), then
									;the intermission screens
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
	bset	#sfpz,(sflags).w
	movea.l	#Pausemode_pall,a1
	jsr	(Pausemode_top).l
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

IntermissionMenus					;The intermission menu by gsp, then the same with OptPlayMode (gsp + 5)
	dc.l	PregameMenu,IntermissionMenu,IntermissionMenu,IntermissionMenu,GameOverMenu
	dc.l	PlayoffPregameMenu,IntermissionMenu,IntermissionMenu,IntermissionMenu,PlayoffGameOverMenu

InitScores							;Early in the playoffs (gamelevel 0-1): 0-3 random SetScore goals for the
									;other games of the day
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

UpdateScores						;Update the ticker score values of the other games (SetScore). Called from
									;PeriodOver
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

SetScore							;Add to the score of the game in a0. After period 3 a game within one goal
									;goes to OT (gsper 3) and asks for a
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

.3									;SetScore: the goal weights of the teams of the game (sctab rows by team
									;rating)
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

sctab								;Weights for 0, 1, 2, 3 goals, 8 rows
	dc.w	$2B,$1E,$17,$4
	dc.w	$27,$20,$18,$5
	dc.w	$23,$21,$1A,$6
	dc.w	$1E,$22,$1E,$6
	dc.w	$1A,$24,$1E,$8
	dc.w	$16,$25,$1F,$A
	dc.w	$13,$26,$1F,$C
	dc.w	$F,$26,$20,$F
	;After sctab: code that nothing in the listing reaches.
	moveq	#-$1,d3
	cmpi.w	#$1E0,(gameclock).w
	bgt.w	rtss2
.loop
	move.w	(TickerNum).w,d3
	bmi.w	rtss2
	subq.w	#1,(TickerNum).w
	cmp.w	(gamenum).w,d3
	beq.s	.loop
	moveq	#$10,d0					;gssize
	mulu.w	d3,d0
	movea.w	#(gsstruct-M68K_RAM),a0
	adda.w	d0,a0
	btst	#1,$E(a0)				;gsfhl
	bne.s	.loop					;don't show if hilite coming up
	btst	#2,$E(a0)				;gsfso
	bne.s	.loop					;don't show if the series is over for this game
	rts
	dc.w	$4A43,$6B00,$21BA,$6100,$012A,$6100,$E318,$5278
	dc.w	$B040,$5978,$B042,$3F38,$B040,$6100,$4E3A,$31FC
	dc.w	$A000,$B044,$6100,$E4DC,$001A,SPAturnl,SPAturnl,SPAturnl
	dc.w	SPAturnl,SPAturnl,SPAturnl,SPAturnl,SPAturnl,SPAturnl,SPAturnl,SPAturnl
	dc.w	SPAturnl,$31D7,$B040,$7001,$D078,$CFCA,$4A78,$D254
	dc.w	$6600,$0004,$4240,$43FA,$007E,$6100,$0102,$3028
	dc.w	$0008,$5340,$227C,$0002,$3384,$6100,$00FA,$3011
	dc.w	$E248,$4440,$D057,SPAgskate,$0017,$31C0,$B040,$6100
	dc.w	$E494,$31FC,$8000,$B044,$3028,$0002,$3228,$000C
	dc.w	$6100,$0010,$3010,$3228,$000A,$6100,$0006,$544F
	dc.w	$4E75,$31EF,$0004,$B040,$5278,$B042,$327C,$077E
	dc.w	$E540,$2271,$0000,$D2E9,$0004,$6100,$E458,$31EF
	dc.w	$0004,$B040,$0678,$0015,$B040,$3001,$7202,$6100
	dc.w	$E6C0,$6000,$E440,$0012,$4541,$2048,$6F63,$6B65
	dc.w	$7920,$4E69,$6768,$7400,$0018,$5374,$616E,$6C65
	dc.w	$7920,$4375,$7020,$5175,$616C,$6966,$6965,$7200
	dc.w	$000E,$5175,$6172,$7465,$7266,$696E,$616C,$0018
	dc.w	$5374,$616E,$6C65,$7920,$4375,$7020,$5365,$6D69
	dc.w	$6669,$6E61,$6C00,$6100,$000A,$343C,$07FF,$6000
	dc.w	$E1BA,$6100,$E3CE,$0006,$BD03,$1700,$0838,$0000
	dc.w	$C33A,$6600,$000C,$6100,$E3BA,$0006,$BF03,$1700
	dc.w	$701A,$7205,$4E75

PrintBigListItem					;printbig String d0 of the String list a1 (SkipStrings).
	bsr.w	SkipStrings
	bra.w	printbig

PrintSmallListItem					;printsmall String d0 of the String list a1 (SkipStrings).
	bsr.w	SkipStrings
	bra.w	printsmall

SkipStrings							;a1 = String d0 of the String list a1
	bra.w	.1
.0
	adda.w	(a1),a1
.1
	dbf	d0,.0
	rts

