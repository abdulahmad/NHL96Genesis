;	The roster menu and the trade screen.

RosterMenuList						;The roster menu (PlayoffMenuScreen): each item
									;routine returns its text in a1
	String	CC_SetAttribute,$07,CC_SetFont
	String	CC_SetAttribute,$05,CC_SetFont
	dc.l	.trade,.create,.freeagents,.release,.reset,.rosters,.exit,-1
.trade	movea.l	#.tradetxt,a1
	rts
.tradetxt	String	'Trade Players'
.create	movea.l	#.createtxt,a1
	rts
.createtxt	String	'Create Players'
.freeagents	movea.l	#.freeagentstxt,a1
	rts
.freeagentstxt	String	CC_SetX,$0C,'Sign Free Agents'
.release	movea.l	#.releasetxt,a1
	rts
.releasetxt	String	'Release Player'
.reset	movea.l	#.resettxt,a1
	rts
.resettxt	String	CC_SetX,$0E,'Reset Rosters'
.rosters	movea.l	#.rosterstxt,a1
	rts
.rosterstxt	String	CC_SetX,$0E,'Team Rosters'
.exit	movea.l	#.exittxt,a1
	rts
.exittxt	String	CC_SetX,$12,'Exit'

YesNoMenuList						;A Yes / No menu (PlayoffMenuScreen)
	String	CC_SetAttribute,$07,CC_SetFont
	String	CC_SetAttribute,$05,CC_SetFont
	dc.l	.yes,.no,-1
.yes	movea.l	#.yestxt,a1
	rts
.yestxt	String	'Yes'
.no	movea.l	#.notxt,a1
	rts
.notxt	String	'No'

MenuCreatePlayers					;Roster menu item Create Players
	jsr	(CreatePlayer).l
	rts

MenuSignFreeAgents					;Roster menu item Sign Free Agents
	jsr	(SignFreeAgents).l
	rts

MenuReleasePlayer					;Roster menu item Release Player
	jsr	(ReleasePlayers).l
	rts

TradePlayers						;The trade screen (roster menu item Trade Players): the two rosters with
									;position and rating
	move.w	#0,(HomeTeam).w
	move.w	#1,(VisTeam).w
	clr.w	(carddelay).w
	bsr.w	SetupTradeScreenVideo
	movea.l	#TradeSprites,a0
	jsr	(DrawScreenSprite).l
	jsr	(PStatsPalette).l
	clr.w	(pstatscount).l
	clr.w	(vislogochars).l
	move.w	#5,(homelogochars).l
	move.w	#5,(vislogochars+2).l
	clr.w	(vislogochars+4).l		;TestList index
	clr.w	(TeamSelectRedraw).l
	clr.w	(pstatsblockchars).l
	jsr	(clearTeamStats).l
	move.w	(HomeTeam).w,d7
	movea.l	#$FFFF3A98,a0
	movea.l	#$FFFF2AF8,a1
	bsr.w	FillTradeRosterList
	bsr.w	SortTradeRosterList
	movea.l	#$FFFF88B8,a0
	movea.l	#$FFFF2AFE,a1
	move.w	(VisTeam).w,d7
	bsr.w	FillTradeRosterList
	bsr.w	SortTradeRosterList
	jsr	(printz).l
	String	$8F,0,0
	bsr.w	DrawHomeTradeRoster
	bsr.w	DrawVisTradeRoster
	move.w	#$FFFF,($FFFFD014).w
	move.w	#$18,(palcount).w
	bclr	#2,(disflags).w
TradePlayersPrintTeams	equ	*
	move.w	(HomeTeam).w,d1
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),1,4
	bsr.w	DrawTradeTeamLogo
	move.w	(VisTeam).w,d1
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),1,$E
	bsr.w	DrawTradeTeamLogo
	bset	#2,(sflags11).w
	jsr	(printbigz).l
	String	$F8,4,1,$15,4,'pos',$F8,4,1,$1C,4,'RATING'
	jsr	(printbigz).l
	String	$F8,4,1,$15,$E,'pos',$F8,4,1,$1C,$E,'RATING'
	bclr	#2,(sflags11).w
	bsr.w	PrintTradeSmallText
	move.w	#$2500,sr
.loop
	cmpi.w	#$FFFF,($FFFFD014).w
	beq.w	.4
	bsr.w	WaitMenuFrame
	cmpi.w	#0,($FFFFD014).w
	beq.w	.1
	cmpi.w	#1,($FFFFD014).w
	bne.w	.3
.1
	tst.w	(vislogochars+4).l
	bne.w	.2
	move.w	sr,-(sp)
	bsr.w	DrawHomeTradeRoster
	move.w	(sp)+,sr
	bra.w	.4
.2
	move.w	sr,-(sp)
	bsr.w	DrawVisTradeRoster
	move.w	(sp)+,sr
	bra.w	.4
.3
	bsr.w	WaitMenuFrame
	move.w	sr,-(sp)
	bsr.w	DrawHomeTradeRoster
	move.w	(sp)+,sr
	bsr.w	WaitMenuFrame
	move.w	sr,-(sp)
	bsr.w	DrawVisTradeRoster
	move.w	(sp)+,sr
.4
	move.w	#$FFFF,($FFFFD014).w
	bsr.w	TradeReadPad
	tst.w	d1
	beq.w	TradeExit
	move.w	#$FFFF,($FFFFD014).w
	btst	#7,d1
	bne.w	.21
	btst	#2,d1
	bne.w	.loop2
	btst	#3,d1
	bne.w	.loop2
	btst	#5,d1
	bne.w	.19
	btst	#6,d1
	bne.w	.18
	btst	#0,d1
	bne.w	.14
	btst	#1,d1
	bne.w	.10
	btst	#4,d1
	beq.w	.loop
	rts
.loop2
	tst.w	(vislogochars+4).l
	bne.w	.7
	clr.w	(pstatscount).l
	move.w	#5,(homelogochars).l
	clr.w	(TeamSelectRedraw).l
	btst	#2,d1
	bne.w	.5
	addq.w	#1,(HomeTeam).w
	cmpi.w	#$1A,(HomeTeam).w
	bne.w	.6
	clr.w	(HomeTeam).w
	bra.w	.6
.5
	subq.w	#1,(HomeTeam).w
	bpl.w	.6
	move.w	#$19,(HomeTeam).w
.6
	move.w	(VisTeam).w,d7			;frame counter
	;loop
	cmp.w	(HomeTeam).w,d7
	beq.s	.loop2					;wait for a new frame
	jsr	(clearTeamStats).l			;read the pads
	move.w	(HomeTeam).w,d7
	movea.l	#$FFFF3A98,a0
	movea.l	#$FFFF2AF8,a1
	bsr.w	FillTradeRosterList
	bsr.w	SortTradeRosterList
	jsr	(printz).l
	String	$8F,0,0
	bsr.w	WaitMenuFrame
	move.w	sr,-(sp)
	bsr.w	DrawHomeTradeRoster
	move.w	(HomeTeam).w,d1
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),1,4
	bsr.w	DrawTradeTeamLogo
	move.w	(sp)+,sr
	move.w	#$FFFF,($FFFFD014).w
	bra.w	.loop
.7
	clr.w	(vislogochars).l
	move.w	#5,(vislogochars+2).l
	clr.w	(pstatsblockchars).l
	btst	#2,d1
	bne.w	.8
	addq.w	#1,(VisTeam).w
	cmpi.w	#$1A,(VisTeam).w
	bne.w	.9
	clr.w	(VisTeam).w
	bra.w	.9
.8
	subq.w	#1,(VisTeam).w
	bpl.w	.9
	move.w	#$19,(VisTeam).w
.9
	move.w	(VisTeam).w,d7
	cmp.w	(HomeTeam).w,d7
	beq.w	.loop2
	jsr	(clearTeamStats).l
	move.w	(VisTeam).w,d7
	movea.l	#$FFFF88B8,a0
	movea.l	#$FFFF2AFE,a1
	bsr.w	FillTradeRosterList
	bsr.w	SortTradeRosterList
	jsr	(printz).l
	String	$8F,0,0
	bsr.w	WaitMenuFrame
	move.w	sr,-(sp)
	bsr.w	DrawVisTradeRoster
	move.w	(VisTeam).w,d1
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),1,$E
	bsr.w	DrawTradeTeamLogo
	move.w	(sp)+,sr
	move.w	#$FFFF,($FFFFD014).w
	bra.w	.loop
.10
	movea.l	#pstatscount,a0
	movea.l	#homelogochars,a1
	movea.l	#TeamSelectRedraw,a2
	move.w	($FFFF2AFC).l,d3
	tst.w	(vislogochars+4).l
	beq.w	.11
	movea.l	#vislogochars,a0
	movea.l	#vislogochars+2,a1
	movea.l	#pstatsblockchars,a2
	move.w	($FFFF2B02).l,d3
.11
	subq.w	#1,d3
	cmpi.w	#5,(a2)
	blt.w	.12
	cmp.w	(a1),d3
	beq.w	.loop
	addq.w	#1,(a0)
	addq.w	#1,(a1)
	bra.w	.13
.12
	addq.w	#1,(a2)
.13
	move.w	#1,($FFFFD014).w
	bra.w	.loop
.14
	movea.l	#pstatscount,a0
	movea.l	#homelogochars,a1
	movea.l	#TeamSelectRedraw,a2
	tst.w	(vislogochars+4).l
	beq.w	.15
	movea.l	#vislogochars,a0
	movea.l	#vislogochars+2,a1
	movea.l	#pstatsblockchars,a2
.15
	tst.w	(a2)
	bne.w	.16
	tst.w	(a0)
	beq.w	.loop
	subq.w	#1,(a0)
	subq.w	#1,(a1)
	bra.w	.17
.16
	subq.w	#1,(a2)
.17
	move.w	#0,($FFFFD014).w
	bra.w	.loop
.18
	move.w	#6,($FFFFD014).w
	eori.w	#1,(vislogochars+4).l
	bra.w	.loop
.19
	move.w	#5,($FFFFD014).w
	move.w	(TeamSelectRedraw).l,d0
	add.w	(pstatscount).l,d0
	movea.l	#$FFFF3A98,a0
	tst.w	(vislogochars+4).l
	beq.w	.20
	move.w	(pstatsblockchars).l,d0
	add.w	(vislogochars).l,d0
	movea.l	#$FFFF88B8,a0
.20
	asl.w	#2,d0
	eori.b	#1,(a0,d0.w)
	bra.w	.loop
.21
	bsr.w	CheckTrade
	bne.w	TradeDone
	move.w	#7,($FFFFD014).w
	bra.w	TradePlayersPrintTeams

DrawHomeTradeRoster					;Draw the roster of HomeTeam with the chosen marks; falls into
									;DrawTradeRosterRows
	move.w	(TeamSelectRedraw).l,d5
	tst.w	(vislogochars+4).l
	beq.w	.1
	move.w	#$FFFF,d5
.1
	movea.l	#pstatscount,a5
	movea.l	#$FFFF3A98,a4
	move.w	#7,(printy).w
	move.w	(HomeTeam).w,d7
	bra.w	DrawTradeRosterRows

DrawVisTradeRoster					;The same for the visiting team
	move.w	(pstatsblockchars).l,d5
	tst.w	(vislogochars+4).l
	bne.w	.1
	move.w	#$FFFF,d5
.1
	movea.l	#vislogochars,a5
	movea.l	#$FFFF88B8,a4
	move.w	#$11,(printy).w
	move.w	(VisTeam).w,d7

DrawTradeRosterRows					;Draw the roster rows of team d7 (name, position, rating), * for the
									;chosen players
	move.w	(printy).w,-(sp)
	jsr	(printz).l
	String	$8F,0,0
	move.w	(sp)+,(printy).w
	clr.w	d6
	move.w	(a5),d0
	asl.w	#2,d0
	ext.l	d0
	adda.l	d0,a4
.loop
	jsr	(printsmallz).l
	String	$FD,2,'                                   '
	move.w	#2,(printx).w
	jsr	(printsmallz).l
	String	$FE,7,$F9
	cmp.w	d5,d6
	bne.w	.1
	jsr	(printsmallz).l
	String	$FE,5,$F9
.1
	tst.b	(a4)
	beq.w	.2
	jsr	(printsmallz).l
	String	'*'
.2
	move.w	#3,(printx).w
	clr.w	d0
	move.b	2(a4),d0
	jsr	(FormatPlayerNameD7).l
	jsr	(printsmall).l
	move.w	#$16,(printx).w
	movea.l	#PositionLetters,a1
	clr.w	d0
	move.b	1(a4),d0
	jsr	(PrintSmallListItem).l
	move.w	#$1E,(printx).w
	clr.w	d0
	move.b	3(a4),d0
	jsr	(SoftClampCoord).l
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	addq.l	#4,a4
	addq.w	#1,(printy).w
	addq.w	#1,d6
	cmp.w	#6,d6
	blt.w	.loop
	rts

TradeDone							;After a trade
	movea.l	#$FFFFD016,a1
	movea.l	#$FFFF3A98,a2
	move.w	(HomeTeam).w,d7
	move.w	($FFFF2AFC).l,d6
	bsr.w	BuildTradeList
	movea.l	#$FFFFD01E,a1
	movea.l	#$FFFF88B8,a2
	move.w	(VisTeam).w,d7
	move.w	($FFFF2B02).l,d6
	bsr.w	BuildTradeList
	movea.l	#$FFFF3A98,a0
	move.w	($FFFF2AFC).l,d3
	move.w	(HomeTeam).w,d7
	bsr.w	TradeValue
	move.w	d0,(TempWord1).w
	movea.l	#$FFFF88B8,a0
	move.w	($FFFF2B02).l,d3
	move.w	(VisTeam).w,d7
	bsr.w	TradeValue
	move.w	d0,(TempWord2).w
	sub.w	(TempWord1).w,d0
	bpl.w	.1
	neg.w	d0
.1
	clr.w	(recwins+2).w
	cmp.w	#2,d0
	ble.w	.4
	st	(recwins+2).w
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),2,7
	move.w	#$24,d0
	move.w	#6,d1
	jsr	(EraseBlank).l
	jsr	(printsmallz).l
	String	$FD,8,$FE,7,$FC,7
	move.w	(HomeTeam).w,d7
	move.w	(TempWord1).w,d0
	cmp.w	(TempWord2).w,d0
	bgt.w	.2
	move.w	(VisTeam).w,d7
.2
	movea.l	#$77E,a1
	move.w	d7,d0
	asl.w	#2,d0
	movea.l	(a1,d0.w),a1
	adda.w	4(a1),a1
	jsr	(printsmall).l
	jsr	(printsmallz).l
	String	' rejects trade.'
	jsr	(printsmallz).l
	String	$FD,8,$FC,9,'to overrule trade:',$FD,$14,$FA,1,'press c',$FD,8,$FA,1,'to accept decision:',$FD,$14,$FA,1,'press start'
.loop
	bsr.w	TradeReadPad
	btst	#5,d1
	beq.w	.3
	jsr	(ExecuteTrade).l
	bclr	#6,(GameFlags).w
	jsr	(MakeSRAMChecksum).l
	rts
.3
	btst	#7,d1
	beq.s	.loop
	move.w	#7,($FFFFD014).w
	bra.w	TradePlayersPrintTeams
.4
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),2,7
	move.w	#$24,d0
	move.w	#6,d1
	jsr	(EraseBlank).l
	jsr	(printsmallz).l
	String	$FE,7,$FD,8,$FC,7,'trade approved',$FD,8,$FC,9,'to cancel trade',$FD,$14,$FC,$A,'press c',$FD,8,$FC,$B,'to accept decision',$FD,$14,$FC,$C,'press start'
.loop2
	bsr.w	TradeReadPad
	btst	#5,d1
	beq.w	.5
	move.w	#7,($FFFFD014).w
	bra.w	TradePlayersPrintTeams
.5
	btst	#7,d1
	beq.s	.loop2
	jsr	(ExecuteTrade).l
	bclr	#6,(GameFlags).w
	jsr	(MakeSRAMChecksum).l
	rts

TradeValue							;d0 = trade value of the d3 players at a0: each rating (byte 3) mapped
									;through TradeRatingSteps /
									;TradeRatingValues
	subq.w	#1,d3
	clr.w	d0
.loop
	tst.b	(a0)
	beq.w	.2
	move.b	3(a0),d1
	movea.l	#TradeRatingSteps,a1
	movea.l	#TradeRatingValues,a2
	clr.w	d4
.loop2
	cmp.b	(a1,d4.w),d1
	ble.w	.1
	addq.w	#1,d4
	bra.s	.loop2
.1
	move.b	(a2,d4.w),d4
	ext.w	d4
	add.w	d4,d0
.2
	tst.l	(a0)+
	dbf	d3,.loop
	rts

TradeRatingSteps					;TradeValue: the rating steps
	dc.b	$28,$32,$3C,$46,$4B,$50,$55,$5A,$5F,$65

TradeRatingValues					;TradeValue: the value of each step
	dc.b	$01,$02,$03,$04,$05,$07,$0A,$0F,$14,$1E

TradeExit							;Leave the trade screen
	jmp	(Opening2).l

CheckTrade							;Check the trade (players chosen on both teams, at most three a team, the
									;roster limits); else the reason from InvalidTradeText Code the listing
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#ChosenGoalies1,a0
	movea.l	#$FFFF3A98,a1
	move.w	($FFFF2AFC).l,d0
	bsr.w	CountChosen
	movea.l	#ChosenGoalies2,a0
	movea.l	#$FFFF88B8,a1
	move.w	($FFFF2B02).l,d0
	bsr.w	CountChosen
	clr.w	d0
	move.w	#5,d1
	movea.l	#ChosenGoalies1,a0
.loop
	add.w	(a0)+,d0
	dbf	d1,.loop
	tst.w	d0
	bne.w	.1
	move.w	#0,(InvalidTradeReason).w
	bra.w	.6
.loop2
	move.w	#2,(InvalidTradeReason).w
	bra.w	.6
.loop3
	move.w	#3,(InvalidTradeReason).w
	bra.w	.6
.1
	move.w	(ChosenGoalies1).w,d0
	add.w	(ChosenSkaters1).w,d0
	add.w	(ChosenDefense1).w,d0
	cmp.w	#3,d0
	bgt.s	.loop3
	move.w	(ChosenGoalies2).w,d0
	add.w	(ChosenSkaters2).w,d0
	add.w	(ChosenDefense2).w,d0
	cmp.w	#3,d0
	bgt.s	.loop3
	move.w	(ChosenGoalies1).w,d0
	add.w	(ChosenSkaters1).w,d0
	add.w	(ChosenDefense1).w,d0
	beq.s	.loop2
	move.w	(ChosenGoalies2).w,d0
	add.w	(ChosenSkaters2).w,d0
	add.w	(ChosenDefense2).w,d0
	beq.s	.loop2
	move.w	($FFFF2AFC).l,d0
	sub.w	(ChosenGoalies1).w,d0
	sub.w	(ChosenSkaters1).w,d0
	sub.w	(ChosenDefense1).w,d0
	add.w	(ChosenGoalies2).w,d0
	add.w	(ChosenSkaters2).w,d0
	add.w	(ChosenDefense2).w,d0
	move.w	d0,(SRAMChecksum).w
	cmp.w	#$1B,d0
	ble.w	.2
.loop4
	move.w	#1,(InvalidTradeReason).w
	bra.w	.6
.2
	cmp.w	#$11,d0
	bge.w	.3
	bra.s	.loop4
.3
	movem.l	d0/d7,-(sp)
	move.w	(HomeTeam).w,d7
	jsr	(GetGoalieCountD7).l
	sub.w	(ChosenGoalies1).w,d0
	add.w	(ChosenGoalies2).w,d0
	sub.w	d0,(SRAMChecksum).w
	cmpi.w	#$18,(SRAMChecksum).w
	movem.l	(sp)+,d0/d7
	bgt.s	.loop4
	move.w	($FFFF2B02).l,d0
	sub.w	(ChosenGoalies2).w,d0
	sub.w	(ChosenSkaters2).w,d0
	sub.w	(ChosenDefense2).w,d0
	add.w	(ChosenGoalies1).w,d0
	add.w	(ChosenSkaters1).w,d0
	add.w	(ChosenDefense1).w,d0
	move.w	d0,(SRAMChecksum).w
	cmp.w	#$1B,d0
	ble.w	.4
	bra.s	.loop4
.4
	cmp.w	#$11,d0
	bge.w	.5
	bra.s	.loop4
.5
	movem.l	d0/d7,-(sp)
	move.w	(VisTeam).w,d7
	jsr	(GetGoalieCountD7).l
	sub.w	(ChosenGoalies2).w,d0
	add.w	(ChosenGoalies1).w,d0
	sub.w	d0,(SRAMChecksum).w
	cmpi.w	#$18,(SRAMChecksum).w
	movem.l	(sp)+,d0/d7
	bgt.w	.loop4
	move.w	($FFFF2AF8).l,d0
	sub.w	(ChosenGoalies1).w,d0
	add.w	(ChosenGoalies2).w,d0
	cmp.w	#2,d0
	blt.w	.loop4
	cmp.w	#3,d0
	bgt.w	.loop4
	move.w	($FFFF2AFE).l,d0
	sub.w	(ChosenGoalies2).w,d0
	add.w	(ChosenGoalies1).w,d0
	cmp.w	#2,d0
	blt.w	.loop4
	cmp.w	#3,d0
	bgt.w	.loop4
	bra.w	.7
.6
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),2,7
	move.w	#$24,d0
	move.w	#6,d1
	jsr	(EraseBlank).l
	jsr	(printsmallz).l
	String	$FE,7,$FD,$D,$FC,8,'INVALID  TRADE'
	move.w	(InvalidTradeReason).w,d0
	movea.l	#InvalidTradeText,a1
	jsr	(PrintSmallListItem).l
	bsr.w	TradeReadPad
	move.w	#$7FF,d2
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),2,7
	move.w	#$24,d0
	move.w	#6,d1
	jsr	(eraser).l
	bra.w	.8
.7
	move.w	#1,d0
	bra.w	.9
.8
	clr.w	d0
.9
	movem.l	(sp)+,d0-d7/a0-a6
	rts
CountChosen							;Count the chosen players of the trade list (goalies, then skaters) into a0
	clr.w	(a0)
	clr.w	2(a0)
	clr.w	4(a0)
	subq.w	#1,d0
.loop
	tst.b	(a1)
	beq.w	.2
	tst.b	1(a1)
	beq.w	.1
	addq.w	#1,2(a0)
	bra.w	.2
.1
	addq.w	#1,(a0)
.2
	tst.l	(a1)+
	dbf	d0,.loop
	rts

InvalidTradeText					;CheckTrade: the reasons a trade is refused
	String	CC_SetX,$08,CC_SetY,$09,'no players selected on',CC_SetX,$08,CC_SetY,$0A,'one or more teams'
	String	CC_SetX,$08,CC_SetY,$09,'Roster Rules Violated.',CC_AddY,$01,CC_SetX,$08,'each team limited to',CC_AddY,$01,CC_SetX,$08,'2-3 goalies with a',CC_AddY,$01,CC_SetX,$08,'maximum of 27 players.'
	String	CC_SetX,$08,CC_SetY,$09,'no players selected on',CC_SetX,$08,CC_SetY,$0A,'one or more teams'
	String	CC_SetX,$08,CC_SetY,$09,'more than 3 players',CC_AddY,$01,CC_SetX,$08,'selected for trade on',CC_AddY,$01,CC_SetX,$08,'one or more teams'

WaitMenuFrame						;Wait for the next frame (Vcount), then SetMenuScroll; d0 kept Code the
	move.w	d0,-(sp)
	move.w	(Vcount).w,d0			;frame counter
	;loop
.loop
	cmp.w	(Vcount).w,d0
	beq.s	.loop					;wait for a new frame
	jsr	(SetMenuScroll).l			;read the pads
	move.w	(sp)+,d0
	rts

BuildTradeList						;Trade list of team d7: the chosen players ($FFFF = none) Code the listing
	move.w	d7,(a1)+
	move.w	#$FFFF,(a1)
	move.w	#$FFFF,2(a1)
	move.w	#$FFFF,4(a1)
	subq.w	#1,d6
.loop
	tst.b	(a2)
	beq.w	.1
	clr.w	d0
	move.b	2(a2),d0
	move.w	d0,(a1)+
.1
	tst.l	(a2)+
	dbf	d6,.loop
	rts
SetupTradeScreenVideo	equ	*	;Set the VBint handler, scroll and map addresses for the trade screen and load its graphics
	bset	#5,(sflags12).w
	move.l	#VBlank_Menus,(VBint).w
	bclr	#dfok,(disflags).w
	bset	#dfng,(disflags).w
	bclr	#df32c,(disflags).w
	move.w	#0,(VSCRLPM).w
	move.w	#$BC00,(VSPRITES).w
	move.w	#$BC00,(VmMAP3).w
	move.w	#5,(Map3col1).w
	move.w	#$C000,(VmMAP2).w
	move.w	#6,(Map2col1).w
	move.w	#$E000,(VmMAP1).w
	move.w	#6,(Map1col1).w
	move.w	#0,d0					;fade to color
	bset	#5,(disflags).w
	jsr	(setVram).l
	bclr	#5,(disflags).w
	jsr	(orjoy).l
	move.w	#1,d4
	movea.l	#TradeSprites,a1
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
	jsr	(printsmallz).l
	String	$FF,1,$FD,0,$FC
	moveq	#$28,d0
	moveq	#$1C,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),0,0
	movea.l	#TradeBgMap,a0
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
	movea.l	#TradeTitleMap,a0
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
	bsr.w	PrintTradeSmallText
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
	move.w	#$19,d1
	clr.w	d2
	movea.l	#vislogochars+6,a0
	movea.l	#TeamBlockPtrs,a1
.loop2
	move.w	d4,(a0)+
	move.w	d2,d0
	asl.w	#2,d0
	movea.l	(a1,d0.w),a2
	addq.w	#8,a2
	jsr	(DecompressGraphicsPlain).l
	addq.w	#1,d2
	dbf	d1,.loop2
	bset	#2,(sflags11).w
	jsr	(printbigz).l
	String	$F8,7,1,$15,4,'pos',$F8,7,1,$15,$E,'pos'
	bclr	#2,(sflags11).w
	rts
DrawTradeTeamLogo	equ	*	;Draw the logo of team d1 on the trade screen
	movem.l	d0-d7/a0-a6,-(sp)
	clr.w	d0
	asl.w	#2,d1
	movea.l	#TeamBlockPtrs,a0
	movea.l	(a0,d1.w),a0
	lsr.w	#1,d1
	movea.l	#vislogochars+6,a1
	move.w	(a1,d1.w),d4
	movea.l	a0,a1
	adda.l	(a0),a0
	adda.l	4(a1),a1
	movea.w	#$772,a2
	move.w	(a1),d2
	moveq	#2,d3
	clr.w	d0
	clr.w	d1
	moveq	#4,d5
	jsr	(dobitmap).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts
FillTradeRosterList	equ	*	;Fill the trade roster list a0 with the players of the team (goalies first)
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(GetGoalieCountD7).l
	move.w	d0,(a1)
	jsr	(GetPlayerCountD7).l
	move.w	d0,4(a1)
	subq.w	#1,d0
	movea.l	a0,a2
	clr.w	d1
.loop3
	clr.l	(a2)
	move.b	d1,2(a2)
	movem.l	d0,-(sp)
	move.w	d1,d0
	jsr	(GetPositionSlot).l
	move.b	d0,1(a2)
	move.b	d0,d3
	movem.l	(sp)+,d0
	movem.l	d0-d1/d4,-(sp)
	move.l	a2,-(sp)
	clr.w	d0
	move.b	2(a2),d0
	move.w	d0,(RefStep).w
	movea.l	#tmstruct,a2
	cmp.w	(HomeTeam).w,d7
	beq.w	.2
	movea.l	#AwShots,a2
.2
	move.l	(PAttribOverallMask).l,d4
	tst.b	d3
	bne.w	.3
	move.l	(GAttribOverallMask).l,d4
.3
	jsr	(CalcAttrib).l
	mulu.w	#$64,d0
	divu.w	d1,d0
	movem.l	d0,-(sp)
	move.w	(RefStep).w,d0
	jsr	(GetJerseyNumberRead).l
	movem.l	(sp)+,d0
	beq.w	.4
.4
	movea.l	(sp)+,a2
	move.b	d0,3(a2)
	movem.l	(sp)+,d0-d1/d4
	tst.l	(a2)+
	addq.w	#1,d1
	dbf	d0,.loop3
	movem.l	(sp)+,d0-d7/a0-a6
	rts
SortTradeRosterList	equ	*	;Sort the trade roster list a0 by position
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(GetPlayerCountD7).l
	subq.w	#2,d0
.loop4
	movea.l	a0,a2
	move.w	d0,d1
	st	d6
.loop5
	move.b	1(a2),d2
	cmp.b	5(a2),d2
	ble.w	.5
	move.l	(a2),d2
	move.l	4(a2),d3
	move.l	d3,(a2)
	move.l	d2,4(a2)
	clr.w	d6
.5
	addq.w	#4,a2
	dbf	d1,.loop5
	tst.w	d6
	beq.s	.loop4
	movem.l	(sp)+,d0-d7/a0-a6
	rts
PrintTradeSmallText	equ	*	;Print the String that follows with the second small font set
	move.w	(smallfontchars).w,-(sp)
	move.w	(smallfont2chars).w,(smallfontchars).w
	jsr	(printcurz).l
	String	$8F,7,$19,'a-Switch Team',$8F,7,$1A,'B-Cancel',$8F,$15,$19,'C-Player',$8F,$11,$1A,'Start-Evaluate'
	move.w	(sp)+,(smallfontchars).w
	rts

EraseBlank							;Erase a d0 x d1 rectangle at printx / printy with the blank char $7FF
									;(eraser)
	movem.l	d0-d4/a0-a1,-(sp)
	move.w	(disflags).w,-(sp)
	bset	#2,(disflags).w
	move.w	#$7FF,d2
	jsr	(eraser).l
	move.w	(sp)+,(disflags).w
	movem.l	(sp)+,d0-d4/a0-a1
	rts
TradeReadPad	equ	*			;Wait one frame and read the pad for the trade screen
	move.l	#$5460,d6
.loop
	move.w	(Vcount).w,d1
	sub.w	(OldVcount).w,d1
	beq.s	.loop
	move.w	(Vcount).w,(OldVcount).w
	jsr	(SetMenuScroll).l
	jsr	(ReadJoy1).l
	jsr	(ProcessInputWithRepeat).l
	tst.w	d1
	beq.w	.1
	bra.w	.5
.1
	jsr	(ReadJoy2).l
	jsr	(ProcessInputWithRepeat).l
	tst.w	d1
	beq.w	.2
	bra.w	.5
.2
	tst.w	(FourWayPlay).w
	beq.w	.4
	jsr	(ReadJoy3).l
	jsr	(ProcessInputWithRepeat).l
	tst.w	d1
	beq.w	.3
	bra.w	.5
.3
	jsr	(ReadJoy4).l
	jsr	(ProcessInputWithRepeat).l
	tst.w	d1
	beq.w	.4
	bra.w	.5
.4
	dbf	d6,.loop
.5
	rts

ExecuteTrade						;Do the trade: clear both teams' saved blocks, tag the positions, move
									;each chosen player (ExtractTradedPlayer
									;/ InsertTradedPlayer)
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	($FFFFD016).w,d7
	jsr	(CheckTeamLines).l
	move.w	($FFFFD01E).w,d7
	jsr	(CheckTeamLines).l
	movea.l	#$FFFFD016,a0
	bsr.w	ConvertTradeSlots
	movea.l	#$FFFFD01E,a0
	bsr.w	ConvertTradeSlots
	movea.w	#$D016,a0
	movea.w	#(TickerNum-8-M68K_RAM),a1
	move.w	#2,d6
.loop
	movea.l	#nameentryvis+2,a2
	move.w	(a0),(TempRawSpd).w
	move.w	(a0,d6.w),d0
	bmi.w	.1
	move.w	d0,(TempWord1).w
	bsr.w	ExtractTradedPlayer
	bsr.w	ShiftTradeDown
.1
	movea.l	#$FFFFD3DC,a2
	move.w	(a1),(TempRawSpd).w
	move.w	(a1,d6.w),d0
	bmi.w	.2
	move.w	d0,(TempWord1).w
	bsr.w	ExtractTradedPlayer
	exg	a1,a0
	bsr.w	ShiftTradeDown
	exg	a1,a0
.2
	movea.l	#nameentryvis+2,a2
	move.w	(a1),(TempMaxSpd).w
	move.w	(a0,d6.w),d5
	bmi.w	.5
	andi.w	#$FF00,d5
	move.w	(a1),d7
	cmp.w	#0,d5
	bne.w	.3
	jsr	(GetGoalieCountD7).l
	bra.w	.4
.3
	jsr	(GetPlayerCountD7).l
.4
	or.w	d0,d5
	move.w	d5,(TempWord2).w
	bsr.w	InsertTradedPlayer
	movem.l	d0-d7/a0-a6,-(sp)
	exg	a0,a1
	bsr.w	ShiftTradeUp
	exg	a0,a1
	movem.l	(sp)+,d0-d7/a0-a6
.5
	movea.l	#$FFFFD3DC,a2
	move.w	(a0),(TempMaxSpd).w
	move.w	(a1,d6.w),d5
	bmi.w	.8
	andi.w	#$FF00,d5
	move.w	(a0),d7
	cmp.w	#0,d5
	bne.w	.6
	jsr	(GetGoalieCountD7).l
	bra.w	.7
.6
	jsr	(GetPlayerCountD7).l
.7
	or.w	d0,d5
	move.w	d5,(TempWord2).w
	bsr.w	InsertTradedPlayer
	movem.l	d0-d7/a0-a6,-(sp)
	bsr.w	ShiftTradeUp
	movem.l	(sp)+,d0-d7/a0-a6
.8
	addq.w	#2,d6
	cmp.w	#8,d6
	blt.w	.loop
	movem.l	(sp)+,d0-d7/a0-a6
	rts
ConvertTradeSlots					;Convert the three roster slot words at a0 to position slots
									;(GetPositionSlot)
	move.w	(a0)+,d7
	move.w	#2,d6
.loop
	move.w	(a0)+,d0
	bmi.w	.1
	andi.w	#$FF,d0
	jsr	(GetPositionSlot).l
	move.w	d0,d2
	move.b	d2,-$2(a0)
.1
	dbf	d6,.loop
	rts

ShiftTradeUp						;Trade list: the later player numbers at or after an inserted player
									;(TempWord2) go up one
	move.b	(TempWord2+1).w,d0
.loop
	tst.w	(a0,d6.w)
	bmi.w	.2
	cmp.b	1(a0,d6.w),d0
	bgt.w	.1
	addq.b	#1,1(a0,d6.w)
.1
	addq.w	#2,d6
	cmp.w	#8,d6
	blt.s	.loop
.2
	rts

ShiftTradeDown						;Trade list: the later player numbers after a removed player go down one
	movem.l	d0-d7/a0-a6,-(sp)
	addq.w	#2,d6
	cmp.w	#8,d6
	bge.w	.2
.loop
	tst.w	(a0,d6.w)
	bmi.w	.2
	cmp.b	1(a0,d6.w),d0
	bgt.w	.1
	subq.b	#1,1(a0,d6.w)
.1
	addq.w	#2,d6
	cmp.w	#8,d6
	blt.s	.loop
.2
	movem.l	(sp)+,d0-d7/a0-a6
	rts

ExtractTradedPlayer					;Take player TempWord1 out of team TempRawSpd into buffer a2 (roster id,
									;jersey, stats, injury)
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	a2,-(sp)
	move.w	(TempRawSpd).w,d7
	jsr	(GetGoalieCountD7).l
	move.w	d0,(userblockx).w
	bset	#6,(GameFlags).w
	move.w	(TempWord1).w,d0
	andi.w	#$FF,d0
	move.w	(TempRawSpd).w,d7
	movem.w	d0/d7,-(sp)
	jsr	(GetRosterId).l
	move.w	d0,(a2)+
	movem.w	(sp)+,d0/d7
	jsr	(GetJerseyNumber).l
	move.w	(jerseynum).w,(a2)+
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#CalTeam,a0
	move.w	d7,d0
	mulu.w	#$1B,d0
	addi.l	#$1B00,d0
	moveq	#$1B,d1
	movem.l	d0-d1/a0,-(sp)
	jsr	(ReadSRAM).l
	move.w	(TempWord1).w,d0
	andi.w	#$FF,d0
	move.w	#$1B,d1
	sub.w	d0,d1
	beq.w	.1
.loop
	move.b	1(a0,d0.w),d2
	move.b	d2,(a0,d0.w)
	addq.w	#1,d0
	dbf	d1,.loop
.1
	movem.l	(sp)+,d0-d1/a0
	jsr	(WriteSRAM).l
	movem.l	(sp)+,d0-d7/a0-a6
	movea.l	#CalTeam,a0
	jsr	(ReadCreatedPlayerSRAM).l
	move.w	(TempWord1).w,d0
	andi.w	#$FF,d0
	add.w	d0,d0
	move.w	#$36,d3
.loop2
	move.w	2(a0,d0.w),d1
	move.w	d1,(a0,d0.w)
	addq.w	#2,d0
	cmp.w	d3,d0
	blt.s	.loop2
	jsr	(WriteCreatedPlayerSRAM).l
	movea.l	#$200000,a0
	move.w	d7,d0
	asl.w	#2,d0
	ext.l	d0
	addi.l	#$3598,d0
	move.b	1(a0,d0.w),d1
	subq.b	#1,d1
	move.b	d1,1(a0,d0.w)
	tst.b	(TempWord1).w
	bne.w	.2
	move.b	3(a0,d0.w),d1
	subq.b	#1,d1
	move.b	d1,3(a0,d0.w)
.2
	cmp.w	#$19,d7
	bgt.w	.12
	jsr	(ReadSeasonHeader).l
	tst.b	(TempWord1).w
	bne.w	.6
	moveq	#$E,d2
	moveq	#3,d3
	moveq	#$2A,d4
	move.l	#$5548,d1
	btst	#2,(SeasonDay+2).w
	beq.w	.3
	moveq	#$E,d2
	moveq	#3,d3
	moveq	#$19,d4
	move.l	#$2FC8,d1
.3
	bsr.w	DeleteStatSlot			;Init channel
	moveq	#$E,d2
	moveq	#3,d3
	moveq	#$2A,d4
	move.l	#$598C,d1
	btst	#2,(SeasonDay+2).w
	beq.w	.4
	moveq	#$E,d2
	moveq	#3,d3
	moveq	#$19,d4
	move.l	#$3268,d1
.4
	bsr.w	DeleteStatSlot
	moveq	#$D,d2
	moveq	#3,d3
	moveq	#$27,d4
	move.l	#$5DD0,d1
	btst	#2,(SeasonDay+2).w
	beq.w	.5
	moveq	#$D,d2
	moveq	#3,d3
	moveq	#$18,d4
	move.l	#$3508,d1
.5
	bsr.w	DeleteStatSlot
	move.w	(PlayoffMenuTeam).w,d2
	cmp.w	(TempRawSpd).w,d2
	bne.w	.10
	moveq	#$D,d2
	moveq	#3,d3
	moveq	#0,d4
	move.l	#$75F8,d1
	bsr.w	DeleteStatSlot
	moveq	#$D,d2
	moveq	#3,d3
	moveq	#0,d4
	move.l	#$761F,d1
	bsr.w	DeleteStatSlot
	moveq	#$D,d2
	moveq	#3,d3
	moveq	#0,d4
	move.l	#$7646,d1
	bsr.w	DeleteStatSlot
	bra.w	.11
.6
	moveq	#$C,d2
	moveq	#$18,d3
	move.l	#$120,d4
	move.l	#$268,d1
	btst	#2,(SeasonDay+2).w
	beq.w	.7
	moveq	#$A,d2
	moveq	#$18,d3
	move.l	#$93,d4
	move.l	#$448,d1
.7
	bsr.w	DeleteStatSlot
	moveq	#$C,d2
	moveq	#$18,d3
	move.l	#$120,d4
	move.l	#$1FA8,d1
	btst	#2,(SeasonDay+2).w
	beq.w	.8
	moveq	#$A,d2
	moveq	#$18,d3
	move.l	#$93,d4
	move.l	#$1348,d1
.8
	bsr.w	DeleteStatSlot
	moveq	#$A,d2
	moveq	#$18,d3
	move.l	#$F0,d4
	move.l	#$3CE8,d1
	btst	#2,(SeasonDay+2).w
	beq.w	.9
	moveq	#9,d2
	moveq	#$18,d3
	move.l	#$84,d4
	move.l	#$2248,d1
.9
	bsr.w	DeleteStatSlot
	move.w	(PlayoffMenuTeam).w,d2
	cmp.w	(TempRawSpd).w,d2
	bne.w	.10
	moveq	#$A,d2
	moveq	#$18,d3
	moveq	#0,d4
	move.l	#$7340,d1
	bsr.w	DeleteStatSlot
	moveq	#$A,d2
	moveq	#$18,d3
	moveq	#0,d4
	move.l	#$7430,d1
	bsr.w	DeleteStatSlot
	moveq	#9,d2
	moveq	#$18,d3
	moveq	#0,d4
	move.l	#$7520,d1
	bsr.w	DeleteStatSlot
	bra.w	.11
.10
	addq.w	#6,a2
.11
	moveq	#3,d2
	moveq	#$1B,d3
	moveq	#$51,d4
	move.l	#$EDF0,d1
	bset	#5,(sflags13).w
	bsr.w	DeleteStatSlot
	bclr	#5,(sflags13).w
.12
	movea.l	(sp)+,a2
	movem.l	(sp)+,d0-d7/a0-a6
	rts

DeleteStatSlot						;Packed stat block d1 (d2 bits, d3 players, d4 bits a team) of team d7:
									;player TempWord1's value to (a2)+,
									;later ones down
	movea.l	#CalTeam,a0
	movem.l	d1-d4/a0,-(sp)
	jsr	(ReadSRAMBitWords).l
	movea.l	#CalTeam,a3
	move.w	(TempWord1).w,d0
	andi.w	#$FF,d0
	cmp.b	(userblockx+1).w,d0
	blt.w	.1
	btst	#5,(sflags13).w
	bne.w	.1
	sub.b	(userblockx+1).w,d0
.1
	add.w	d0,d0
	move.l	d3,-(sp)
	move.w	(a3,d0.w),d3
	move.w	d3,(a2)+
	move.l	(sp)+,d3
	subq.w	#1,d3
	add.w	d3,d3
.loop
	move.w	2(a3,d0.w),d1
	move.w	d1,(a3,d0.w)
	addq.w	#2,d0
	cmp.w	d3,d0
	blt.s	.loop
	clr.w	(a3,d0.w)
	movem.l	(sp)+,d1-d4/a0
	jmp	(WriteSRAMBitWords).l

InsertTradedPlayer					;Put the player in the buffer a2 into team TradeToTeam at TempWord2:
									;roster, player stats, saved lines
									;(FixLinesInserted), jersey number (FixJerseyNumber) and injury slot
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	a2,-(sp)
	bset	#6,(GameFlags).w
	move.w	(TempMaxSpd).w,d7
	move.w	(TempWord2).w,d0
	andi.w	#$FF,d0
	movea.l	#CalTeam,a0
	jsr	(ReadCreatedPlayerSRAM).l
	add.w	d0,d0
	move.w	#$38,d3
	bra.w	.1
.loop
	move.w	-$2(a0,d3.w),d1
	move.w	d1,(a0,d3.w)
.1
	subq.w	#2,d3
	cmp.w	d0,d3
	ble.w	.2
	bra.s	.loop
.2
	move.w	(a2)+,(a0,d0.w)
	move.w	(a2)+,(jerseynum).w
	move.l	a0,-(sp)
	movea.l	#$200000,a0
	move.w	d7,d0
	asl.w	#2,d0
	ext.l	d0
	addi.l	#$3598,d0
	move.b	1(a0,d0.w),d1
	addq.b	#1,d1
	move.b	d1,1(a0,d0.w)
	tst.b	(TempWord2).w
	bne.w	.3
	move.b	3(a0,d0.w),d1
	addq.b	#1,d1
	move.b	d1,3(a0,d0.w)
.3
	movea.l	(sp)+,a0
	jsr	(WriteCreatedPlayerSRAM).l
	jsr	(GetGoalieCountD7).l
	move.w	d0,(userblockx).w
	cmp.w	#$19,d7
	bgt.w	.14
	jsr	(ReadSeasonHeader).l
	tst.b	(TempWord2).w
	bne.w	.7
	moveq	#$E,d2
	moveq	#3,d3
	moveq	#$2A,d4
	move.l	#$5548,d1
	btst	#2,(SeasonDay+2).w
	beq.w	.4
	moveq	#$E,d2
	moveq	#3,d3
	moveq	#$19,d4
	move.l	#$2FC8,d1
.4
	bsr.w	InsertStatSlot			;Init channel
	moveq	#$E,d2
	moveq	#3,d3
	moveq	#$2A,d4
	move.l	#$598C,d1
	btst	#2,(SeasonDay+2).w
	beq.w	.5
	moveq	#$E,d2
	moveq	#3,d3
	moveq	#$19,d4
	move.l	#$3268,d1
.5
	bsr.w	InsertStatSlot
	moveq	#$D,d2
	moveq	#3,d3
	moveq	#$27,d4
	move.l	#$5DD0,d1
	btst	#2,(SeasonDay+2).w
	beq.w	.6
	moveq	#$D,d2
	moveq	#3,d3
	moveq	#$18,d4
	move.l	#$3508,d1
.6
	bsr.w	InsertStatSlot
	move.w	(PlayoffMenuTeam).w,d2
	cmp.w	(TempMaxSpd).w,d2
	bne.w	.11
	clr.w	(a2)
	moveq	#$D,d2
	moveq	#3,d3
	moveq	#0,d4
	move.l	#$75F8,d1
	bsr.w	InsertStatSlot
	clr.w	(a2)
	moveq	#$D,d2
	moveq	#3,d3
	moveq	#0,d4
	move.l	#$761F,d1
	bsr.w	InsertStatSlot
	clr.w	(a2)
	moveq	#$D,d2
	moveq	#3,d3
	moveq	#0,d4
	move.l	#$7646,d1
	bsr.w	InsertStatSlot
	bra.w	.12
.7
	moveq	#$C,d2
	moveq	#$18,d3
	move.l	#$120,d4
	move.l	#$268,d1
	btst	#2,(SeasonDay+2).w
	beq.w	.8
	moveq	#$A,d2
	moveq	#$18,d3
	move.l	#$93,d4
	move.l	#$448,d1
.8
	bsr.w	InsertStatSlot
	moveq	#$C,d2
	moveq	#$18,d3
	move.l	#$120,d4
	move.l	#$1FA8,d1
	btst	#2,(SeasonDay+2).w
	beq.w	.9
	moveq	#$A,d2
	moveq	#$18,d3
	move.l	#$93,d4
	move.l	#$1348,d1
.9
	bsr.w	InsertStatSlot
	moveq	#$A,d2
	moveq	#$18,d3
	move.l	#$F0,d4
	move.l	#$3CE8,d1
	btst	#2,(SeasonDay+2).w
	beq.w	.10
	moveq	#9,d2
	moveq	#$18,d3
	move.l	#$84,d4
	move.l	#$2248,d1
.10
	bsr.w	InsertStatSlot
	move.w	(PlayoffMenuTeam).w,d2
	cmp.w	(TempMaxSpd).w,d2
	bne.w	.11
	moveq	#$A,d2
	moveq	#$18,d3
	moveq	#0,d4
	move.l	#$7340,d1
	clr.w	(a2)
	bsr.w	InsertStatSlot
	moveq	#$A,d2
	moveq	#$18,d3
	moveq	#0,d4
	move.l	#$7430,d1
	clr.w	(a2)
	bsr.w	InsertStatSlot
	moveq	#9,d2
	moveq	#$18,d3
	moveq	#0,d4
	move.l	#$7520,d1
	clr.w	(a2)
	bsr.w	InsertStatSlot
	bra.w	.12
.11
	addq.w	#6,a2
.12
	moveq	#3,d2
	moveq	#$1B,d3
	moveq	#$51,d4
	move.l	#$EDF0,d1
	bset	#5,(sflags13).w
	bsr.w	InsertStatSlot
	bclr	#5,(sflags13).w
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#CalTeam,a0
	move.w	(TempMaxSpd).w,d7
	move.w	d7,d0
	mulu.w	#$1B,d0
	addi.l	#$1B00,d0
	moveq	#$1B,d1
	movem.l	d0-d1/a0,-(sp)
	jsr	(ReadSRAM).l
	move.w	(TempWord2).w,d0
	andi.w	#$FF,d0
	move.w	#$1B,d1
.loop2
	cmp.w	d0,d1
	beq.w	.13
	move.b	-$1(a0,d1.w),d2
	move.b	d2,(a0,d1.w)
	dbf	d1,.loop2
.13
	move.b	(jerseynum+1).w,(a0,d1.w)
	movem.l	(sp)+,d0-d1/a0
	jsr	(WriteSRAM).l
	movem.l	(sp)+,d0-d7/a0-a6
	move.w	(TempWord2).w,d0
	andi.w	#$FF,d0
	move.w	(TempMaxSpd).w,d7
	jsr	(FixJerseyNumber).l
.14
	movea.l	(sp)+,a2
	jsr	(MakeSRAMChecksum).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

InsertStatSlot						;Packed stat block d1 (d2 bits, d3 players, d4 bits a team) of team d7:
									;insert (a2)+ at player TempWord2, later
									;ones up
	movea.l	#CalTeam,a0
	movem.l	d1-d4/a0,-(sp)
	jsr	(ReadSRAMBitWords).l
	movea.l	#CalTeam,a3
	move.w	(TempWord2).w,d0
	andi.w	#$FF,d0
	cmp.b	(userblockx+1).w,d0
	blt.w	.1
	btst	#5,(sflags13).w
	bne.w	.1
	sub.b	(userblockx+1).w,d0
.1
	add.w	d0,d0
	add.w	d3,d3
	bra.w	.2
.loop
	move.w	-$2(a3,d3.w),d1
	move.w	d1,(a3,d3.w)
.2
	subq.w	#2,d3
	cmp.w	d0,d3
	ble.w	.3
	bra.s	.loop
.3
	move.w	(a2)+,d1
	move.w	d1,(a3,d3.w)
	movem.l	(sp)+,d1-d4/a0
	jmp	(WriteSRAMBitWords).l

FixJerseyNumber						;Give player d0 of team d7 a jersey number no teammate has: step it up in
									;BCD, 99 wraps to 1
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	d0,d2
	jsr	(GetPlayerCountD7).l
	move.w	d0,d3
	movea.l	#ThreeStars,a0
	mulu.w	#$1B,d7
	ext.l	d7
	addi.l	#$1B00,d7
	move.l	d7,d0
	moveq	#$1B,d1
	movem.l	d0-d1/a0,-(sp)
	jsr	(ReadSRAM).l
.loop
	move.b	(a0,d2.w),d4
	move.w	d3,d5
	subq.w	#1,d5
	clr.w	d0
.loop2
	cmp.w	d0,d2
	beq.w	.2
	cmp.b	(a0,d0.w),d4
	bne.w	.2
	addq.b	#1,d4
	move.b	d4,d6
	andi.w	#$F,d6
	cmp.b	#$A,d6
	bne.w	.1
	addi.b	#$10,d4
	andi.w	#$F0,d4
	cmp.b	#$A0,d4
	bne.w	.1
	move.b	#1,d4
.1
	move.b	d4,(a0,d2.w)
	bra.s	.loop
.2
	addq.w	#1,d0
	dbf	d5,.loop2
	movem.l	(sp)+,d0-d1/a0
	jsr	(WriteSRAM).l
	jsr	(MakeSRAMChecksum).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

GetRosterId							;d0 = roster id word of player d0 of team d7 (season roster in save RAM
									;SRRosters, or d7 << 8 | d0 outside a
									;season)
	movem.l	d1/d6-d7/a0,-(sp)
	btst	#4,(sflags11).w
	beq.w	.1
	asl.w	#8,d7
	andi.w	#$FF,d0
	or.w	d7,d0
	bra.w	.2
.1
	mulu.w	#$36,d7
	add.w	d0,d0
	ext.l	d0
	add.l	d7,d0
	addi.l	#$1550,d0
	moveq	#2,d1
	movea.l	#recwins+4,a0
	jsr	(ReadSRAM).l
	move.w	(a0),d0
.2
	movem.l	(sp)+,d1/d6-d7/a0
	rts

PositionLetters						;The position of a roster row (TradePlayers and code96_17)
	String	'G'
	String	'LD'
	String	'RD'
	String	'LW'
	String	'C '
	String	'RW'

