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
									;Code the listing does not decode: kept as bytes
	dc.b	$31,$FC,$00,$00,$C3,$A0,$31,$FC,$00,$01,$C3,$A2,$42,$78,$D3,$12
	dc.b	$61,$00,$0B,$60,$20,$7C,$00,$19,$26,$2C,$4E,$B9,$00,$01,$21,$8A
	dc.b	$4E,$B9,$00,$1D,$BB,$92,$42,$79,$FF,$FF,$27,$14,$42,$79,$FF,$FF
	dc.b	$27,$18,$33,$FC,$00,$05,$FF,$FF,$27,$16,$33,$FC,$00,$05,$FF,$FF
	dc.b	$27,$1A,$42,$79,$FF,$FF,$27,$1C,$42,$79,$FF,$FF,$27,$10,$42,$79
	dc.b	$FF,$FF,$27,$12,$4E,$B9,$00,$02,$14,$82,$3E,$38,$C3,$A0,$20,$7C
	dc.b	$FF,$FF,$3A,$98,$22,$7C,$FF,$FF,$2A,$F8,$61,$00,$0C,$EA,$61,$00
	dc.b	$0D,$8E,$20,$7C,$FF,$FF,$88,$B8,$22,$7C,$FF,$FF,$2A,$FE,$3E,$38
	dc.b	$C3,$A2,$61,$00,$0C,$D2,$61,$00,$0D,$76,$4E,$B9,$00,$01,$BB,$8E
	dc.b	$00,$06,$8F,$00,$00,$00,$61,$00,$03,$98,$61,$00,$03,$C2,$31,$FC
	dc.b	$FF,$FF,$D0,$14,$31,$FC,$00,$18,$BD,$3C,$08,$B8,$00,$02,$BF,$B2
	dc.b	$32,$38,$C3,$A0,$4E,$B9,$00,$01,$BB,$8E,$00,$06,$BF,$01,$04,$00
	dc.b	$61,$00,$0C,$54,$32,$38,$C3,$A2,$4E,$B9,$00,$01,$BB,$8E,$00,$06
	dc.b	$BF,$01,$0E,$00,$61,$00,$0C,$40,$08,$F8,$00,$02,$C3,$54,$4E,$B9
	dc.b	$00,$01,$BE,$D6,$00,$16,$F8,$04,$01,$15,$04,$70,$6F,$73,$F8,$04
	dc.b	$01,$1C,$04,$52,$41,$54,$49,$4E,$47,$00,$4E,$B9,$00,$01,$BE,$D6
	dc.b	$00,$16,$F8,$04,$01,$15,$0E,$70,$6F,$73,$F8,$04,$01,$1C,$0E,$52
	dc.b	$41,$54,$49,$4E,$47,$00,$08,$B8,$00,$02,$C3,$54,$61,$00,$0D,$1C
	dc.b	$46,$FC,$25,$00,$0C,$78,$FF,$FF,$D0,$14,$67,$00,$00,$54,$61,$00
	dc.b	$0A,$02,$0C,$78,$00,$00,$D0,$14,$67,$00,$00,$0C,$0C,$78,$00,$01
	dc.b	$D0,$14,$66,$00,$00,$24,$4A,$79,$FF,$FF,$27,$1C,$66,$00,$00,$0E
	dc.b	$40,$E7,$61,$00,$02,$DC,$46,$DF,$60,$00,$00,$26,$40,$E7,$61,$00
	dc.b	$02,$FE,$46,$DF,$60,$00,$00,$1A,$61,$00,$09,$C8,$40,$E7,$61,$00
	dc.b	$02,$C0,$46,$DF,$61,$00,$09,$BC,$40,$E7,$61,$00,$02,$E2,$46,$DF
	dc.b	$31,$FC,$FF,$FF,$D0,$14,$61,$00,$0D,$24,$4A,$41,$67,$00,$06,$3E
	dc.b	$31,$FC,$FF,$FF,$D0,$14,$08,$01,$00,$07,$66,$00,$02,$82,$08,$01
	dc.b	$00,$02,$66,$00,$00,$34,$08,$01,$00,$03,$66,$00,$00,$2C,$08,$01
	dc.b	$00,$05,$66,$00,$02,$2A,$08,$01,$00,$06,$66,$00,$02,$10,$08,$01
	dc.b	$00,$00,$66,$00,$01,$BA,$08,$01,$00,$01,$66,$00,$01,$54,$08,$01
	dc.b	$00,$04,$67,$00,$FF,$50,$4E,$75,$4A,$79,$FF,$FF,$27,$1C,$66,$00
	dc.b	$00,$A0,$42,$79,$FF,$FF,$27,$14,$33,$FC,$00,$05,$FF,$FF,$27,$16
	dc.b	$42,$79,$FF,$FF,$27,$10,$08,$01,$00,$02,$66,$00,$00,$18,$52,$78
	dc.b	$C3,$A0,$0C,$78,$00,$1A,$C3,$A0,$66,$00,$00,$18,$42,$78,$C3,$A0
	dc.b	$60,$00,$00,$10,$53,$78,$C3,$A0,$6A,$00,$00,$08,$31,$FC,$00,$19
	dc.b	$C3,$A0,$3E,$38,$C3,$A2,$BE,$78,$C3,$A0,$67,$AC,$4E,$B9,$00,$02
	dc.b	$14,$82,$3E,$38,$C3,$A0,$20,$7C,$FF,$FF,$3A,$98,$22,$7C,$FF,$FF
	dc.b	$2A,$F8,$61,$00,$0B,$12,$61,$00,$0B,$B6,$4E,$B9,$00,$01,$BB,$8E
	dc.b	$00,$06,$8F,$00,$00,$00,$61,$00,$08,$DA,$40,$E7,$61,$00,$01,$D2
	dc.b	$32,$38,$C3,$A0,$4E,$B9,$00,$01,$BB,$8E,$00,$06,$BF,$01,$04,$00
	dc.b	$61,$00,$0A,$A4,$46,$DF,$31,$FC,$FF,$FF,$D0,$14,$60,$00,$FE,$A6
	dc.b	$42,$79,$FF,$FF,$27,$18,$33,$FC,$00,$05,$FF,$FF,$27,$1A,$42,$79
	dc.b	$FF,$FF,$27,$12,$08,$01,$00,$02,$66,$00,$00,$18,$52,$78,$C3,$A2
	dc.b	$0C,$78,$00,$1A,$C3,$A2,$66,$00,$00,$18,$42,$78,$C3,$A2,$60,$00
	dc.b	$00,$10,$53,$78,$C3,$A2,$6A,$00,$00,$08,$31,$FC,$00,$19,$C3,$A2
	dc.b	$3E,$38,$C3,$A2,$BE,$78,$C3,$A0,$67,$00,$FF,$0E,$4E,$B9,$00,$02
	dc.b	$14,$82,$3E,$38,$C3,$A2,$20,$7C,$FF,$FF,$88,$B8,$22,$7C,$FF,$FF
	dc.b	$2A,$FE,$61,$00,$0A,$72,$61,$00,$0B,$16,$4E,$B9,$00,$01,$BB,$8E
	dc.b	$00,$06,$8F,$00,$00,$00,$61,$00,$08,$3A,$40,$E7,$61,$00,$01,$60
	dc.b	$32,$38,$C3,$A2,$4E,$B9,$00,$01,$BB,$8E,$00,$06,$BF,$01,$0E,$00
	dc.b	$61,$00,$0A,$04,$46,$DF,$31,$FC,$FF,$FF,$D0,$14,$60,$00,$FE,$06
	dc.b	$20,$7C,$FF,$FF,$27,$14,$22,$7C,$FF,$FF,$27,$16,$24,$7C,$FF,$FF
	dc.b	$27,$10,$36,$39,$FF,$FF,$2A,$FC,$4A,$79,$FF,$FF,$27,$1C,$67,$00
	dc.b	$00,$1A,$20,$7C,$FF,$FF,$27,$18,$22,$7C,$FF,$FF,$27,$1A,$24,$7C
	dc.b	$FF,$FF,$27,$12,$36,$39,$FF,$FF,$2B,$02,$53,$43,$0C,$52,$00,$05
	dc.b	$6D,$00,$00,$10,$B6,$51,$67,$00,$FD,$BC,$52,$50,$52,$51,$60,$00
	dc.b	$00,$04,$52,$52,$31,$FC,$00,$01,$D0,$14,$60,$00,$FD,$A8,$20,$7C
	dc.b	$FF,$FF,$27,$14,$22,$7C,$FF,$FF,$27,$16,$24,$7C,$FF,$FF,$27,$10
	dc.b	$4A,$79,$FF,$FF,$27,$1C,$67,$00,$00,$14,$20,$7C,$FF,$FF,$27,$18
	dc.b	$22,$7C,$FF,$FF,$27,$1A,$24,$7C,$FF,$FF,$27,$12,$4A,$52,$66,$00
	dc.b	$00,$10,$4A,$50,$67,$00,$FD,$6E,$53,$50,$53,$51,$60,$00,$00,$04
	dc.b	$53,$52,$31,$FC,$00,$00,$D0,$14,$60,$00,$FD,$5A,$31,$FC,$00,$06
	dc.b	$D0,$14,$0A,$79,$00,$01,$FF,$FF,$27,$1C,$60,$00,$FD,$48,$31,$FC
	dc.b	$00,$05,$D0,$14,$30,$39,$FF,$FF,$27,$10,$D0,$79,$FF,$FF,$27,$14
	dc.b	$20,$7C,$FF,$FF,$3A,$98,$4A,$79,$FF,$FF,$27,$1C,$67,$00,$00,$14
	dc.b	$30,$39,$FF,$FF,$27,$12,$D0,$79,$FF,$FF,$27,$18,$20,$7C,$FF,$FF
	dc.b	$88,$B8,$E5,$40,$0A,$30,$00,$01,$00,$00,$60,$00,$FD,$08,$61,$00
	dc.b	$03,$B2,$66,$00,$01,$48,$31,$FC,$00,$07,$D0,$14,$60,$00,$FC,$82

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
									;Code the listing does not decode: kept as bytes
	dc.b	$3F,$38,$B0,$42,$4E,$B9,$00,$01,$BB,$8E,$00,$06,$8F,$00,$00,$00
	dc.b	$31,$DF,$B0,$42,$42,$46,$30,$15,$E5,$40,$48,$C0,$D9,$C0,$4E,$B9
	dc.b	$00,$01,$BA,$2E,$00,$28,$FD,$02,$20,$20,$20,$20,$20,$20,$20,$20
	dc.b	$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	dc.b	$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$00,$31,$FC,$00,$02
	dc.b	$B0,$40,$4E,$B9,$00,$01,$BA,$2E,$00,$06,$FE,$07,$F9,$00,$BC,$45
	dc.b	$66,$00,$00,$0E,$4E,$B9,$00,$01,$BA,$2E,$00,$06,$FE,$05,$F9,$00
	dc.b	$4A,$14,$67,$00,$00,$0C,$4E,$B9,$00,$01,$BA,$2E,$00,$04,$2A,$00
	dc.b	$31,$FC,$00,$03,$B0,$40,$42,$40,$10,$2C,$00,$02,$4E,$B9,$00,$01
	dc.b	$01,$7A,$4E,$B9,$00,$01,$BA,$40,$31,$FC,$00,$16,$B0,$40,$22,$7C
	dc.b	$00,$1D,$D8,$FE,$42,$40,$10,$2C,$00,$01,$4E,$B9,$00,$01,$D7,$EA
	dc.b	$31,$FC,$00,$1E,$B0,$40,$42,$40,$10,$2C,$00,$03,$4E,$B9,$00,$1D
	dc.b	$93,$02,$32,$3C,$00,$02,$4E,$B9,$00,$01,$BE,$1C,$4E,$B9,$00,$01
	dc.b	$BA,$40,$58,$8C,$52,$78,$B0,$42,$52,$46,$BC,$7C,$00,$06
	dc.b	$6D,$00,$FF,$3E,$4E,$75

TradeDone							;After a trade
									;Code the listing does not decode: kept as bytes
	dc.b	$22,$7C,$FF,$FF,$D0,$16,$24,$7C,$FF,$FF
	dc.b	$3A,$98,$3E,$38,$C3,$A0,$3C,$39,$FF,$FF,$2A,$FC,$61,$00,$05,$C4
	dc.b	$22,$7C,$FF,$FF,$D0,$1E,$24,$7C,$FF,$FF,$88,$B8,$3E,$38,$C3,$A2
	dc.b	$3C,$39,$FF,$FF,$2B,$02,$61,$00,$05,$AA,$20,$7C,$FF,$FF,$3A,$98
	dc.b	$36,$39,$FF,$FF,$2A,$FC,$3E,$38,$C3,$A0,$61,$00,$01,$CE,$31,$C0
	dc.b	$BF,$46,$20,$7C,$FF,$FF,$88,$B8,$36,$39,$FF,$FF,$2B,$02,$3E,$38
	dc.b	$C3,$A2,$61,$00,$01,$B6,$31,$C0,$BF,$48,$90,$78,$BF,$46,$6A,$00
	dc.b	$00,$04,$44,$40,$42,$78,$BF,$7E,$B0,$7C,$00,$02,$6F,$00,$00,$F2
	dc.b	$50,$F8,$BF,$7E,$4E,$B9,$00,$01,$BB,$8E,$00,$06,$BF,$02,$07,$00
	dc.b	$30,$3C,$00,$24,$32,$3C,$00,$06,$4E,$B9,$00,$1D,$CF,$E2,$4E,$B9
	dc.b	$00,$01,$BA,$2E,$00,$08,$FD,$08,$FE,$07,$FC,$07,$3E,$38,$C3,$A0
	dc.b	$30,$38,$BF,$46,$B0,$78,$BF,$48,$6E,$00,$00,$06,$3E,$38,$C3,$A2
	dc.b	$22,$7C,$00,$00,$07,$7E,$30,$07,$E5,$40,$22,$71,$00,$00,$D2,$E9
	dc.b	$00,$04,$4E,$B9,$00,$01,$BA,$40,$4E,$B9,$00,$01,$BA,$2E,$00,$12
	dc.b	$20,$72,$65,$6A,$65,$63,$74,$73,$20,$74,$72,$61,$64,$65,$2E,$00
	dc.b	$4E,$B9,$00,$01,$BA,$2E,$00,$4A,$FD,$08,$FC,$09,$74,$6F,$20,$6F
	dc.b	$76,$65,$72,$72,$75,$6C,$65,$20,$74,$72,$61,$64,$65,$3A,$FD,$14
	dc.b	$FA,$01,$70,$72,$65,$73,$73,$20,$63,$FD,$08,$FA,$01,$74,$6F,$20
	dc.b	$61,$63,$63,$65,$70,$74,$20,$64,$65,$63,$69,$73,$69,$6F,$6E,$3A
	dc.b	$FD,$14,$FA,$01,$70,$72,$65,$73,$73,$20,$73,$74,$61,$72,$74,$00
	dc.b	$61,$00,$08,$04,$08,$01,$00,$05,$67,$00,$00,$16,$4E,$B9,$00,$1D
	dc.b	$D0,$86,$08,$B8,$00,$06,$C3,$50,$4E,$B9,$00,$02,$41,$AA,$4E,$75
	dc.b	$08,$01,$00,$07,$67,$DA,$31,$FC,$00,$07,$D0,$14,$60,$00,$F9,$DC
	dc.b	$4E,$B9,$00,$01,$BB,$8E,$00,$06,$BF,$02,$07,$00,$30,$3C,$00,$24
	dc.b	$32,$3C,$00,$06,$4E,$B9,$00,$1D,$CF,$E2,$4E,$B9,$00,$01,$BA,$2E
	dc.b	$00,$5A,$FE,$07,$FD,$08,$FC,$07,$74,$72,$61,$64,$65,$20,$61,$70
	dc.b	$70,$72,$6F,$76,$65,$64,$FD,$08,$FC,$09,$74,$6F,$20,$63,$61,$6E
	dc.b	$63,$65,$6C,$20,$74,$72,$61,$64,$65,$FD,$14,$FC,$0A,$70,$72,$65
	dc.b	$73,$73,$20,$63,$FD,$08,$FC,$0B,$74,$6F,$20,$61,$63,$63,$65,$70
	dc.b	$74,$20,$64,$65,$63,$69,$73,$69,$6F,$6E,$FD,$14,$FC,$0C,$70,$72
	dc.b	$65,$73,$73,$20,$73,$74,$61,$72,$74,$00,$61,$00,$07,$5A,$08,$01
	dc.b	$00,$05,$67,$00,$00,$0C,$31,$FC,$00,$07,$D0,$14,$60,$00,$F9,$4C
	dc.b	$08,$01,$00,$07,$67,$E4,$4E,$B9,$00,$1D,$D0,$86,$08,$B8,$00,$06
	dc.b	$C3,$50,$4E,$B9,$00,$02,$41,$AA,$4E,$75

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
									;does not decode: kept as bytes
	dc.b	$48,$E7,$FF,$FE,$20,$7C,$FF,$FF,$BF,$54,$22,$7C,$FF,$FF,$3A,$98
	dc.b	$30,$39,$FF,$FF,$2A,$FC,$61,$00,$02,$0C,$20,$7C,$FF,$FF,$BF,$5E
	dc.b	$22,$7C,$FF,$FF,$88,$B8,$30,$39,$FF,$FF,$2B,$02,$61,$00,$01,$F6
	dc.b	$42,$40,$32,$3C,$00,$05,$20,$7C,$FF,$FF,$BF,$54,$D0,$58,$51,$C9
	dc.b	$FF,$FC,$4A,$40,$66,$00,$00,$20,$31,$FC,$00,$00,$BF,$68,$60,$00
	dc.b	$01,$58,$31,$FC,$00,$02,$BF,$68,$60,$00,$01,$4E,$31,$FC,$00,$03
	dc.b	$BF,$68,$60,$00,$01,$44,$30,$38,$BF,$54,$D0,$78,$BF,$56,$D0,$78
	dc.b	$BF,$58,$B0,$7C,$00,$03,$6E,$E4,$30,$38,$BF,$5E,$D0,$78,$BF,$60
	dc.b	$D0,$78,$BF,$62,$B0,$7C,$00,$03,$6E,$D2,$30,$38,$BF,$54,$D0,$78
	dc.b	$BF,$56,$D0,$78,$BF,$58,$67,$BA,$30,$38,$BF,$5E,$D0,$78,$BF,$60
	dc.b	$D0,$78,$BF,$62,$67,$AC,$30,$39,$FF,$FF,$2A,$FC,$90,$78,$BF,$54
	dc.b	$90,$78,$BF,$56,$90,$78,$BF,$58,$D0,$78,$BF,$5E,$D0,$78,$BF,$60
	dc.b	$D0,$78,$BF,$62,$31,$C0,$DD,$BC,$B0,$7C,$00,$1B,$6F,$00,$00,$0C
	dc.b	$31,$FC,$00,$01,$BF,$68,$60,$00,$00,$D0,$B0,$7C,$00,$11,$6C,$00
	dc.b	$00,$04,$60,$EC,$48,$E7,$81,$00,$3E,$38,$C3,$A0,$4E,$B9,$00,$01
	dc.b	$57,$74,$90,$78,$BF,$54,$D0,$78,$BF,$5E,$91,$78,$DD,$BC,$0C,$78
	dc.b	$00,$18,$DD,$BC,$4C,$DF,$00,$81,$6E,$C6,$30,$39,$FF,$FF,$2B,$02
	dc.b	$90,$78,$BF,$5E,$90,$78,$BF,$60,$90,$78,$BF,$62,$D0,$78,$BF,$54
	dc.b	$D0,$78,$BF,$56,$D0,$78,$BF,$58,$31,$C0,$DD,$BC,$B0,$7C,$00,$1B
	dc.b	$6F,$00,$00,$04,$60,$9A,$B0,$7C,$00,$11,$6C,$00,$00,$04,$60,$90
	dc.b	$48,$E7,$81,$00,$3E,$38,$C3,$A2,$4E,$B9,$00,$01,$57,$74,$90,$78
	dc.b	$BF,$5E,$D0,$78,$BF,$54,$91,$78,$DD,$BC,$0C,$78,$00,$18,$DD,$BC
	dc.b	$4C,$DF,$00,$81,$6E,$00,$FF,$6A,$30,$39,$FF,$FF,$2A,$F8,$90,$78
	dc.b	$BF,$54,$D0,$78,$BF,$5E,$B0,$7C,$00,$02,$6D,$00,$FF,$54,$B0,$7C
	dc.b	$00,$03,$6E,$00,$FF,$4C,$30,$39,$FF,$FF,$2A,$FE,$90,$78,$BF,$5E
	dc.b	$D0,$78,$BF,$54,$B0,$7C,$00,$02,$6D,$00,$FF,$36,$B0,$7C,$00,$03
	dc.b	$6E,$00,$FF,$2E,$60,$00,$00,$6E,$4E,$B9,$00,$01,$BB,$8E,$00,$06
	dc.b	$BF,$02,$07,$00,$30,$3C,$00,$24,$32,$3C,$00,$06,$4E,$B9,$00,$1D
	dc.b	$CF,$E2,$4E,$B9,$00,$01,$BA,$2E,$00,$16,$FE,$07,$FD,$0D,$FC,$08
	dc.b	$49,$4E,$56,$41,$4C,$49,$44,$20,$20,$54,$52,$41,$44,$45,$30,$38
	dc.b	$BF,$68,$22,$7C,$00,$1D,$CB,$7A,$4E,$B9,$00,$01,$D7,$EA,$61,$00
	dc.b	$04,$EA,$34,$3C,$07,$FF,$4E,$B9,$00,$01,$BB,$8E,$00,$06,$BF,$02
	dc.b	$07,$00,$30,$3C,$00,$24,$32,$3C,$00,$06,$4E,$B9,$00,$01,$B9,$76
	dc.b	$60,$00,$00,$0A,$30,$3C,$00,$01,$60,$00,$00,$04,$42,$40,$4C,$DF
	dc.b	$7F,$FF,$4E,$75,$42,$50,$42,$68,$00,$02,$42,$68,$00,$04,$53,$40
	dc.b	$4A,$11,$67,$00,$00,$14,$4A,$29,$00,$01,$67,$00,$00,$0A,$52,$68
	dc.b	$00,$02,$60,$00,$00,$04,$52,$50,$4A,$99,$51,$C8,$FF,$E4,$4E,$75

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
	dc.w	$08F8,$0005,$C356,$21FC,$0001,$2D46,$D244,$08B8
	dc.w	$0000,$BFB2,$08F8,$0002,$BFB2,$08B8,$0001,$BFB2
	dc.w	$31FC,$0000,$B000,$31FC,$BC00,$B002,$31FC,$BC00
	dc.w	$B00C,$31FC,$0005,$B00E,$31FC,$C000,$B008,$31FC
	dc.w	$0006,$B00A,$31FC,$E000,$B004,$31FC,$0006,$B006
	dc.w	$303C,$0000,$08F8,$0005,$BFB2,$4EB9,$0001,$B57E
	dc.w	$08B8,$0005,$BFB2,$4EB9,$0001,$B2C4,$383C,$0001
	dc.w	$227C,$0019,$262C,$4EB9,$0001,$217A,$31C4,$B01C
	dc.w	$247C,$0017,$9170,$4EB9,$0001,$B730,$31C4,$B01E
	dc.w	$247C,$0017,$A16C,$4EB9,$0001,$B730,$21FC,$0017
	dc.w	$9168,$BF8A,$31C4,$B018,$247C,$0017,$B688,$4EB9
	dc.w	$0001,$B730,$4EB9,$0001,$BA2E,$0008,$FF01,$FD00
	dc.w	$FC00,$7028,$721C,$343C,$07FF,$4EB9,$0001,$B976
	dc.w	$4EB9,$0001,$BB8E,$0006,$BF00,$0000,$207C,$0019
	dc.w	$0EFE,$2248,$2448,$D1DA,$D3DA,$4240,$4241,$7428
	dc.w	$761C,$7A08,$4EB9,$0001,$B692,$4EB9,$0001,$BB8E
	dc.w	$0006,$BF0B,$0100,$207C,$0019,$06FE,$2248,$2448
	dc.w	$D1DA,$D3DA,$4240,$4241,$3411,$3629,$0002,$7A08
	dc.w	$4EB9,$0001,$B692,$6100,$01A0,$4EB9,$0001,$BB8E
	dc.w	$0006,$FE00,$0000,$207C,$0017,$0B0C,$2248,$2448
	dc.w	$D1DA,$D3DA,$4240,$4241,$7440,$761C,$7A01,$4EB9
	dc.w	$0001,$B692,$323C,$0019,$4242,$207C,$FFFF,$271E
	dc.w	$227C,$0001,$2BFE,$30C4,$3002,$E540,$2471,$0000
	dc.w	$504A,$4EB9,$0001,$B730,$5242,$51C9,$FFEA,$08F8
	dc.w	$0002,$C354,$4EB9,$0001,$BED6,$0012,$F807,$0115
	dc.w	$0470,$6F73,$F807,$0115,$0E70,$6F73,$08B8,$0002
	dc.w	$C354,$4E75,$48E7,$FFFE,$4240,$E541,$207C,$0001
	dc.w	$2BFE,$2070,$1000,$E249,$227C,$FFFF,$271E,$3831
	dc.w	$1000,$2248,$D1D0,$D3E9,$0004,$347C,$0772,$3411
	dc.w	$7602,$4240,$4241,$7A04,$4EB9,$0001,$B692,$4CDF
	dc.w	$7FFF,$4E75,$48E7,$FFFE,$4EB9,$0001,$5774,$3280
	dc.w	$4EB9,$0001,$57B2,$3340,$0004,$5340,$2448,$4241
	dc.w	$4292,$1541,$0002,$48E7,$8000,$3001,$4EB9,$0001
	dc.w	$03AA,$1540,$0001,$1600,$4CDF,$0001,$48E7,$C800
	dc.w	$2F0A,$4240,$102A,$0002,$31C0,$C448,$247C,$FFFF
	dc.w	$C726,$BE78,$C3A0,$6700,$0008,$247C,$FFFF,$CAC4
	dc.w	$2839,$0002,$3456,$4A03,$6600,$0008,$2839,$0002
	dc.w	SPAfpunchBhit1,$4EB9,$001D,$7DF8,$C0FC,$0064,$80C1,$48E7
	dc.w	$8000,$3038,$C448,$4EB9,$0001,$0378,$4CDF,$0001
	dc.w	$6700,$0002,$245F,$1540,$0003,$4CDF,$0013,$4A9A
	dc.w	$5241,$51C8,$FF7C,$4CDF,$7FFF,$4E75,$48E7,$FFFE
	dc.w	$4EB9,$0001,$57B2,$5540,$2448,$3200,$50C6,$142A
	dc.w	$0001,$B42A,$0005,$6F00,$0010,SPAboardbot,$262A,$0004
	dc.w	$2483,$2542,$0004,$4246,$584A,$51C9,$FFE2,$4A46
	dc.w	$67D6,$4CDF,$7FFF,$4E75,$3F38,$B01C,$31F8,$B01E
	dc.w	$B01C,$4EB9,$0001,$BC72,$003A,$8F07,$1961,$2D53
	dc.w	$7769,$7463,$6820,$5465,$616D,$8F07,$1A42,$2D43
	dc.w	$616E,$6365,$6C8F,$1519,$432D,$506C,$6179,$6572
	dc.w	$8F11,$1A53,$7461,$7274,$2D45,$7661,$6C75,$6174
	dc.w	$6500,$31DF,$B01C,$4E75

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
									;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$FF,$FE,$3E,$38,$D0,$16,$4E,$B9,$00,$1E,$0D,$86,$3E,$38
	dc.b	$D0,$1E,$4E,$B9
	dc.b	$00,$1E,$0D,$86,$20,$7C,$FF,$FF,$D0,$16,$61,$00,$00,$F8,$20,$7C
	dc.b	$FF,$FF,$D0,$1E,$61,$00,$00,$EE,$30,$7C,$D0,$16,$32,$7C,$D0,$1E
	dc.b	$3C,$3C,$00,$02,$24,$7C,$FF,$FF,$D3,$C8,$31,$D0,$BF,$4A,$30,$30
	dc.b	$60,$00,$6B,$00,$00,$0E,$31,$C0,$BF,$46,$61,$00,$01,$3C,$61,$00
	dc.b	$01,$08,$24,$7C,$FF,$FF,$D3,$DC,$31,$D1,$BF,$4A,$30,$31,$60,$00
	dc.b	$6B,$00,$00,$12,$31,$C0,$BF,$46,$61,$00,$01,$1E,$C3,$48,$61,$00
	dc.b	$00,$E8,$C3,$48,$24,$7C,$FF,$FF,$D3,$C8,$31,$D1,$BF,$4C,$3A,$30
	dc.b	$60,$00,$6B,$00,$00,$3A,$02,$45,$FF,$00,$3E,$11,$BA,$7C,$00,$00
	dc.b	$66,$00,$00,$0C,$4E,$B9,$00,$01,$57,$74,$60,$00,$00,$08,$4E,$B9
	dc.b	$00,$01,$57,$B2,$8A,$40,$31,$C5,$BF,$48,$61,$00,$03,$E0,$48,$E7
	dc.b	$FF,$FE,$C1,$49,$61,$00,$00,$80,$C1,$49,$4C,$DF,$7F,$FF,$24,$7C
	dc.b	$FF,$FF,$D3,$DC,$31,$D0,$BF,$4C,$3A,$31,$60,$00,$6B,$00,$00,$36
	dc.b	$02,$45,$FF,$00,$3E,$10,$BA,$7C,$00,$00,$66,$00,$00,$0C,$4E,$B9
	dc.b	$00,$01,$57,$74,$60,$00,$00,$08,$4E,$B9,$00,$01,$57,$B2,$8A,$40
	dc.b	$31,$C5,$BF,$48,$61,$00,$03,$96,$48,$E7,$FF,$FE,$61,$00,$00,$38
	dc.b	$4C,$DF,$7F,$FF,$54,$46,$BC,$7C,$00,$08,$6D,$00,$FF,$28,$4C,$DF
	dc.b	$7F,$FF,$4E,$75,$3E,$18,$3C,$3C,$00,$02,$30,$18,$6B,$00,$00,$12
	dc.b	$02,$40,$00,$FF,$4E,$B9,$00,$01,$03,$AA,$34,$00,$11,$42,$FF,$FE
	dc.b	$51,$CE,$FF,$E8,$4E,$75

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
									;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$FF,$FE,$2F,$0A,$3E,$38,$BF,$4A,$4E,$B9,$00,$01,$57,$74
	dc.b	$31,$C0,$D4,$88,$08,$F8,$00,$06,$C3,$50,$30,$38,$BF,$46,$02,$40
	dc.b	$00,$FF,$3E,$38,$BF,$4A,$48,$A7,$81,$00,$4E,$B9,$00,$1D,$D8,$BE
	dc.b	$34,$C0,$4C,$9F,$00,$81,$4E,$B9,$00,$01,$02,$B8,$34,$F8,$DD,$AA
	dc.b	$48,$E7,$FF,$FE,$20,$7C,$FF,$FF,$D1,$30,$30,$07,$C0,$FC,$00,$1B
	dc.b	$06,$80,$00,$00,$1B,$00,$72,$1B,$48,$E7,$C0,$80,$4E,$B9,$00,$02
	dc.b	$41,$E8,$30,$38,$BF,$46,$02,$40,$00,$FF,$32,$3C,$00,$1B,$92,$40
	dc.b	$67,$00,$00,$10,$14,$30,$00,$01,$11,$82,$00,$00,$52,$40,$51,$C9
	dc.b	$FF,$F4,$4C,$DF,$01,$03,$4E,$B9,$00,$02,$41,$88,$4C,$DF,$7F,$FF
	dc.b	$20,$7C,$FF,$FF,$D1,$30,$4E,$B9,$00,$01,$04,$AC,$30,$38,$BF,$46
	dc.b	$02,$40,$00,$FF,$D0,$40,$36,$3C,$00,$36,$32,$30,$00,$02,$31,$81
	dc.b	$00,$00,$54,$40,$B0,$43,$6D,$F2,$4E,$B9,$00,$01,$04,$CA,$20,$7C
	dc.b	$00,$20,$00,$00,$30,$07,$E5,$40,$48,$C0,$06,$80,$00,$00,$35,$98
	dc.b	$12,$30,$00,$01,$53,$01,$11,$81,$00,$01,$4A,$38,$BF,$46,$66,$00
	dc.b	$00,$0C,$12,$30,$00,$03,$53,$01,$11,$81,$00,$03,$BE,$7C,$00,$19
	dc.b	$6E,$00,$01,$AA,$4E,$B9,$00,$01,$14,$9E,$4A,$38,$BF,$46,$66,$00
	dc.b	$00,$B4,$74,$0E,$76,$03,$78,$2A,$22,$3C,$00,$00,$55,$48,$08,$38
	dc.b	$00,$02,$DD,$80,$67,$00,$00,$0E,$74,$0E,$76,$03,$78,$19,$22,$3C
	dc.b	$00,$00,$2F,$C8,$61,$00,$01,$7E,$74,$0E,$76,$03,$78,$2A,$22,$3C
	dc.b	$00,$00,$59,$8C,$08,$38,$00,$02,$DD,$80,$67,$00,$00,$0E,$74,$0E
	dc.b	$76,$03,$78,$19,$22,$3C,$00,$00,$32,$68,$61,$00,$01,$58,$74,$0D
	dc.b	$76,$03,$78,$27,$22,$3C,$00,$00,$5D,$D0,$08,$38,$00,$02,$DD,$80
	dc.b	$67,$00,$00,$0E,$74,$0D,$76,$03,$78,$18,$22,$3C,$00,$00,$35,$08
	dc.b	$61,$00,$01,$32,$34,$38,$DD,$BE,$B4,$78,$BF,$4A,$66,$00,$01,$00
	dc.b	$74,$0D,$76,$03,$78,$00,$22,$3C,$00,$00,$75,$F8,$61,$00,$01,$16
	dc.b	$74,$0D,$76,$03,$78,$00,$22,$3C,$00,$00,$76,$1F,$61,$00,$01,$06
	dc.b	$74,$0D,$76,$03,$78,$00,$22,$3C,$00,$00,$76,$46,$61,$00,$00,$F6
	dc.b	$60,$00,$00,$CE,$74,$0C,$76,$18,$28,$3C,$00,$00,$01,$20,$22,$3C
	dc.b	$00,$00,$02,$68,$08,$38,$00,$02,$DD,$80,$67,$00,$00,$12,$74,$0A
	dc.b	$76,$18,$28,$3C,$00,$00,$00,$93,$22,$3C,$00,$00,$04,$48,$61,$00
	dc.b	$00,$C4,$74,$0C,$76,$18,$28,$3C,$00,$00,$01,$20,$22,$3C,$00,$00
	dc.b	$1F,$A8,$08,$38,$00,$02,$DD,$80,$67,$00,$00,$12,$74,$0A,$76,$18
	dc.b	$28,$3C,$00,$00,$00,$93,$22,$3C,$00,$00,$13,$48,$61,$00,$00,$96
	dc.b	$74,$0A,$76,$18,$28,$3C,$00,$00,$00,$F0,$22,$3C,$00,$00,$3C,$E8
	dc.b	$08,$38,$00,$02,$DD,$80,$67,$00,$00,$12,$74,$09,$76,$18,$28,$3C
	dc.b	$00,$00,$00,$84,$22,$3C,$00,$00,$22,$48,$61,$00,$00,$68,$34,$38
	dc.b	$DD,$BE,$B4,$78,$BF,$4A,$66,$00,$00,$36,$74,$0A,$76,$18,$78,$00
	dc.b	$22,$3C,$00,$00,$73,$40,$61,$00,$00,$4C,$74,$0A,$76,$18,$78,$00
	dc.b	$22,$3C,$00,$00,$74,$30,$61,$00,$00,$3C,$74,$09,$76,$18,$78,$00
	dc.b	$22,$3C,$00,$00,$75,$20,$61,$00,$00,$2C,$60,$00,$00,$04,$5C,$4A
	dc.b	$74,$03,$76,$1B,$78,$51,$22,$3C,$00,$00,$ED,$F0,$08,$F8,$00,$05
	dc.b	$C3,$58,$61,$00,$00,$10,$08,$B8,$00,$05,$C3,$58,$24,$5F,$4C,$DF
	dc.b	$7F,$FF,$4E,$75

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
									;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$FF,$FE,$2F,$0A,$08,$F8,$00,$06,$C3,$50,$3E,$38,$BF,$4C
	dc.b	$30,$38,$BF,$48,$02,$40,$00,$FF,$20,$7C,$FF,$FF,$D1,$30,$4E,$B9
	dc.b	$00,$01,$04,$AC,$D0,$40,$36,$3C,$00,$38,$60,$00,$00,$0A,$32,$30
	dc.b	$30,$FE,$31,$81,$30,$00,$55,$43,$B6,$40,$6F,$00,$00,$04,$60,$EE
	dc.b	$31,$9A,$00,$00,$31,$DA,$DD,$AA,$2F,$08,$20,$7C,$00,$20,$00,$00
	dc.b	$30,$07,$E5,$40,$48,$C0,$06,$80,$00,$00,$35,$98,$12,$30,$00,$01
	dc.b	$52,$01,$11,$81,$00,$01,$4A,$38,$BF,$48,$66,$00,$00,$0C,$12,$30
	dc.b	$00,$03,$52,$01,$11,$81,$00,$03,$20,$5F,$4E,$B9,$00,$01,$04,$CA
	dc.b	$4E,$B9,$00,$01,$57,$74,$31,$C0,$D4,$88,$BE,$7C,$00,$19,$6E,$00
	dc.b	$02,$20,$4E,$B9,$00,$01,$14,$9E,$4A,$38,$BF,$48,$66,$00,$00,$BA
	dc.b	$74,$0E,$76,$03,$78,$2A,$22,$3C,$00,$00,$55,$48,$08,$38,$00,$02
	dc.b	$DD,$80,$67,$00,$00,$0E,$74,$0E,$76,$03,$78,$19,$22,$3C,$00,$00
	dc.b	$2F,$C8,$61,$00,$01,$FA,$74,$0E,$76,$03,$78,$2A,$22,$3C,$00,$00
	dc.b	$59,$8C,$08,$38,$00,$02,$DD,$80,$67,$00,$00,$0E,$74,$0E,$76,$03
	dc.b	$78,$19,$22,$3C,$00,$00,$32,$68,$61,$00,$01,$D4,$74,$0D,$76,$03
	dc.b	$78,$27,$22,$3C,$00,$00,$5D,$D0,$08,$38,$00,$02,$DD,$80,$67,$00
	dc.b	$00,$0E,$74,$0D,$76,$03,$78,$18,$22,$3C,$00,$00,$35,$08,$61,$00
	dc.b	$01,$AE,$34,$38,$DD,$BE,$B4,$78,$BF,$4C,$66,$00,$01,$0C,$42,$52
	dc.b	$74,$0D,$76,$03,$78,$00,$22,$3C,$00,$00,$75,$F8,$61,$00,$01,$90
	dc.b	$42,$52,$74,$0D,$76,$03,$78,$00,$22,$3C,$00,$00,$76,$1F,$61,$00
	dc.b	$01,$7E,$42,$52,$74,$0D,$76,$03,$78,$00,$22,$3C,$00,$00,$76,$46
	dc.b	$61,$00,$01,$6C,$60,$00,$00,$D4,$74,$0C,$76,$18,$28,$3C,$00,$00
	dc.b	$01,$20,$22,$3C,$00,$00,$02,$68,$08,$38,$00,$02,$DD,$80,$67,$00
	dc.b	$00,$12,$74,$0A,$76,$18,$28,$3C,$00,$00,$00,$93,$22,$3C,$00,$00
	dc.b	$04,$48,$61,$00,$01,$3A,$74,$0C,$76,$18,$28,$3C,$00,$00,$01,$20
	dc.b	$22,$3C,$00,$00,$1F,$A8,$08,$38,$00,$02,$DD,$80,$67,$00,$00,$12
	dc.b	$74,$0A,$76,$18,$28,$3C,$00,$00,$00,$93,$22,$3C,$00,$00,$13,$48
	dc.b	$61,$00,$01,$0C,$74,$0A,$76,$18,$28,$3C,$00,$00,$00,$F0,$22,$3C
	dc.b	$00,$00,$3C,$E8,$08,$38,$00,$02,$DD,$80,$67,$00,$00,$12,$74,$09
	dc.b	$76,$18,$28,$3C,$00,$00,$00,$84,$22,$3C,$00,$00,$22,$48,$61,$00
	dc.b	$00,$DE,$34,$38,$DD,$BE,$B4,$78,$BF,$4C,$66,$00,$00,$3C,$74,$0A
	dc.b	$76,$18,$78,$00,$22,$3C,$00,$00,$73,$40,$42,$52,$61,$00,$00,$C0
	dc.b	$74,$0A,$76,$18,$78,$00,$22,$3C,$00,$00,$74,$30,$42,$52,$61,$00
	dc.b	$00,$AE,$74,$09,$76,$18,$78,$00,$22,$3C,$00,$00,$75,$20,$42,$52
	dc.b	$61,$00,$00,$9C,$60,$00,$00,$04,$5C,$4A,$74,$03,$76,$1B,$78,$51
	dc.b	$22,$3C,$00,$00,$ED,$F0,$08,$F8,$00,$05,$C3,$58,$61,$00,$00,$80
	dc.b	$08,$B8,$00,$05,$C3,$58,$48,$E7,$FF,$FE,$20,$7C,$FF,$FF,$D1,$30
	dc.b	$3E,$38,$BF,$4C,$30,$07,$C0,$FC,$00,$1B,$06,$80,$00,$00,$1B,$00
	dc.b	$72,$1B,$48,$E7,$C0,$80,$4E,$B9,$00,$02,$41,$E8,$30,$38,$BF,$48
	dc.b	$02,$40,$00,$FF,$32,$3C,$00,$1B,$B2,$40,$67,$00,$00,$0E,$14,$30
	dc.b	$10,$FF,$11,$82,$10,$00,$51,$C9,$FF,$F0,$11,$B8,$DD,$AB,$10,$00
	dc.b	$4C,$DF,$01,$03,$4E,$B9,$00,$02,$41,$88,$4C,$DF,$7F,$FF,$30,$38
	dc.b	$BF,$48,$02,$40,$00,$FF,$3E,$38,$BF,$4C,$4E,$B9,$00,$1D,$D8,$32
	dc.b	$24,$5F,$4E,$B9,$00,$02,$41,$AA,$4C,$DF,$7F,$FF,$4E,$75

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

