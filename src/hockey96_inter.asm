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
	tst.w	d3
	bmi.w	rtss2
	bsr.w	sctabPrintHeader		;d0/d1 = box size
	bsr.w	Framer					;draw the ticker box
	addq.w	#1,(printx).w			;inside the frame, top row
	subq.w	#4,(printy).w
	move.w	(printx).w,-(sp)		;box x: .tn reads it at 4(sp), above its return address
	bsr.w	GetShifter
	move.w	#$A000,(printa).w
	bsr.w	printz
	String	'                        '
	move.w	(sp),(printx).w
	moveq	#1,d0
	add.w	(gamelevel).w,d0		;playoffs: label 1 + round
	tst.w	(OptPlayMode).w
	bne.w	.1
	clr.w	d0						;not playoffs: 'EA Hockey Night'
	;ticker title index chosen
.1
	lea	.table(pc),a1				;a1 = ticker title list
	bsr.w	PrintSmallListItem		;print the ticker title
	move.w	8(a0),d0				;gsper
	subq.w	#1,d0
	movea.l	#PerLabels,a1
	bsr.w	SkipStrings
	move.w	(a1),d0					;period name centered on x+$17
	lsr.w	#1,d0
	neg.w	d0
	add.w	(sp),d0
	addi.w	#$17,d0
	move.w	d0,(printx).w
	bsr.w	print
	move.w	#$8000,(printa).w
	move.w	2(a0),d0				;gst2
	move.w	$C(a0),d1				;gss2
	bsr.w	sctabPrintTeam			;team 2 on the first row
	move.w	(a0),d0					;gst1
	move.w	$A(a0),d1				;gss1
	bsr.w	sctabPrintTeam			;team 1 on the second row
	addq.w	#2,sp					;drop the saved printx
	rts
sctabPrintTeam	equ	*	;Print the team name of a scoreboard line
	;print team d0 name and score d1 on the next row
	move.w	4(sp),(printx).w		;print team d0 name and score d1 on the next row
	addq.w	#1,(printy).w
	movea.w	#$77E,a1				;team address table
	asl.w	#2,d0
	movea.l	(a1,d0.w),a1
	adda.w	4(a1),a1				;team name
	bsr.w	print
	move.w	4(sp),(printx).w
	addi.w	#$15,(printx).w			;92 23
	move.w	d1,d0
	moveq	#2,d1
	bsr.w	PushNumberWidth
	bra.w	print
.table
	dc.w	$0012,$4541,$2048,$6F63,$6B65,$7920,$4E69,$6768
	dc.w	$7400,$0018,$5374,$616E,$6C65,$7920,$4375,$7020
	dc.w	$5175,$616C,$6966,$6965,$7200,$000E,$5175,$6172
	dc.w	$7465,$7266,$696E,$616C,$0018,$5374,$616E,$6C65
	dc.w	$7920,$4375,$7020,$5365,$6D69,$6669,$6E61,$6C00
	dc.w	$6100,$000A,$343C,$07FF,$6000,$E1BA
sctabPrintHeader	equ	*	;Print the scoreboard header
	bsr.w	printz
	String	$BD,3,$17
	btst	#0,(sflags).w
	bne.w	.2
	bsr.w	printz
	String	-(TXPRI+TXMAP1),3,$17
.2
	moveq	#$1A,d0
	moveq	#5,d1
	rts

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

