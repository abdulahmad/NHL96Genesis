;	The standings. Points, the groups, and the sort.

StandingsPoints						;Points and games of the 26 teams from StandingsBuf
	move.w	#$1A,d0
	movea.l	#StandingsBuf,a1
	movea.l	#CalMonth,a2
	movea.l	#StandingsOrder,a3
	clr.w	d2
	move.w	d1,-(sp)
	bra.w	.next
.loop
	move.w	d2,d5
	mulu.w	#3,d2
	clr.w	d3
	move.b	(a1,d2.w),d3
	add.w	d3,d3
	clr.w	d1
	move.b	1(a1,d2.w),d1
	add.w	d1,d3
	move.b	d3,(a2,d5.w)
	move.b	(a1,d2.w),d3
	move.b	d3,(a3,d5.w)
	move.w	d5,d2
	addq.w	#1,d2
.next
	dbf	d0,.loop
	move.w	(sp)+,d1
	rts

StandingsGroups						;StandingsList = the teams of group StandingsMode
	movea.l	#StandingsGroupTbl,a5
	move.w	(StandingsMode).w,d0
	asl.w	#2,d0
	movea.l	(a5,d0.w),a5
	clr.w	(CalTeam).w
	move.b	(a5)+,(CalTeam+1).w
	move.w	(CalTeam).w,d0
	movea.l	#StandingsList,a4
	bra.w	.1
.loop
	move.b	(a5)+,(a4)+
.1
	dbf	d0,.loop
	rts

StandingsGroupTbl					;StandingsGroups: the team list of each group (a count, then the teams)
	dc.l	StandingsGroup0,StandingsGroup1,StandingsGroup2,StandingsGroup3,StandingsGroup4,StandingsGroup4+$D

StandingsGroup0						;A team list (count, then the teams)
	dc.b	6,0,3,7,$A,$13,$17

StandingsGroup1						;A team list (count, then the teams)
	dc.b	6,4,5,6,$14,$16,$19

StandingsGroup2						;A team list (count, then the teams)
	dc.b	7,1,2,9,$B,$F,$11,$12

StandingsGroup3						;A team list (count, then the teams)
	dc.b	7,8,$C,$D,$E,$10,$15,$18

StandingsGroup4						;The team lists of the bigger groups (count, then the teams)
	dc.b	$0C,$00,$03,$07,$0A,$13,$17,$04,$05,$06,$14,$16,$19,$0E,$01,$02
	dc.b	$09,$0B,$0F,$11,$12,$08,$0C,$0D,$0E,$10,$15,$18

SortStandings						;Sort StandingsList by points, then by fewer games played
	movea.l	#StandingsList,a0
	movea.l	#CalMonth,a1
	movea.l	#StandingsOrder,a2
	move.w	d1,-(sp)
.pass
	bclr	#6,(sflags6).w
	clr.w	d7
.cmp
	clr.w	d6
	move.b	(a0,d7.w),d6
	clr.w	d0
	move.b	(a1,d6.w),d0
	move.b	1(a0,d7.w),d6
	clr.w	d1
	move.b	(a1,d6.w),d1
	cmp.w	d1,d0
	bgt.w	.next
	blt.w	.swap
	move.b	(a0,d7.w),d6
	move.b	(a2,d6.w),d0
	move.b	1(a0,d7.w),d6
	cmp.b	(a2,d6.w),d0
	bge.w	.next
.swap
	bset	#6,(sflags6).w
	move.b	(a0,d7.w),d5
	move.b	1(a0,d7.w),d4
	move.b	d5,1(a0,d7.w)
	move.b	d4,(a0,d7.w)
.next
	addq.w	#2,d7
	cmp.w	(CalTeam).w,d7
	bge.w	.4
	subq.w	#1,d7
	bra.s	.cmp
.4
	btst	#6,(sflags6).w
	bne.s	.pass
	move.w	(sp)+,d1
	rts
SortStandingsHeaders	equ	*	;Print and erase the two header rows of the standings
	move.w	#$10,d0
	move.w	#2,d1
	move.w	#$7FF,d2
	ori.w	#$8000,d2
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),1,$17
	jsr	(eraser).l
	move.w	#$12,d0
	move.w	#2,d1
	move.w	#$7FF,d2
	ori.w	#$8000,d2
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),$13,$17
	jsr	(eraser).l
	movea.l	#$1D9F90,a1
	move.w	(StandingsMode).w,d0
	jsr	(SkipStrings).l
	bset	#2,(sflags11).w
	jsr	(printbig).l
	move.w	(CalTeam).w,d7
	clr.w	d6
	movea.l	#StandingsList,a4
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),1,$B
	bra.w	.1
.loop
	clr.w	d1
	move.b	(a4,d6.w),d1
	bsr.w	DrawStandingsTeamLogo
	bsr.w	DrawStandingsRow
	addq.w	#2,(printy).w
	move.w	#1,(printx).w
	addq.w	#1,d6
.1
	dbf	d7,.loop
	rts
DrawStandingsRow					;Print one row of the standings table
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(printy).w,-(sp)
	move.w	d1,d2
	bclr	#2,(sflags11).w
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),0,$B
	move.w	d6,d1
	add.w	d1,d1
	add.w	d1,(printy).w
	movea.l	#StandingsBuf,a4
	move.w	d2,d5
	mulu.w	#3,d5
	clr.w	d0
	move.w	#3,d1
	move.b	(a4,d5.w),d0
	jsr	(PushNumberWidth).l
	move.w	#$14,(printx).w
	jsr	(printbig).l
	move.b	2(a4,d5.w),d0
	jsr	(PushNumberWidth).l
	move.w	#$18,(printx).w
	jsr	(printbig).l
	move.b	1(a4,d5.w),d0
	jsr	(PushNumberWidth).l
	move.w	#$1D,(printx).w
	jsr	(printbig).l
	move.b	(a4,d5.w),d0
	add.b	d0,d0
	add.b	1(a4,d5.w),d0
	move.w	#3,d1
	jsr	(PushNumberWidth).l
	move.w	#$22,(printx).w
	jsr	(printbig).l
	move.w	(sp)+,(printy).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts
DrawStandingsTeamLogo				;Draw the team logo of team d1 for the standings
	movem.l	d0-d7/a0-a6,-(sp)
	clr.w	d0
	asl.w	#2,d1
	movea.l	#TeamBlockPtrs,a0
	movea.l	(a0,d1.w),a0
	lsr.w	#1,d1
	movea.l	#$FFFF2328,a1
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
	dc.w	$0030,$F804,$010B,$0557,$4553,$5445,$524E,$2043
	dc.w	$4F4E,$4645,$5245,$4E43,$45F8,$0401,$0108,$5041
	dc.w	$4349,$4649,$4320,$4449,$5649,$5349,$4F4E,$2000
	dc.w	$0030,$F804,$010B,$0557,$4553,$5445,$524E,$2043
	dc.w	$4F4E,$4645,$5245,$4E43,$45F8,$0401,$0108,$4345
	dc.w	$4E54,$5241,$4C20,$4449,$5649,$5349,$4F4E,$2000
	dc.w	$0030,$F804,$010B,$0545,$4153,$5445,$524E,$2043
	dc.w	$4F4E,$4645,$5245,$4E43,$45F8,$0401,$0108,$4E2E
	dc.w	$4541,$5354,$2044,$4956,$4953,$494F,$4E20,$2000
	dc.w	$0030,$F804,$010B,$0545,$4153,$5445,$524E,$2043
	dc.w	$4F4E,$4645,$5245,$4E43,$45F8,$0401,$0108,$4154
	dc.w	$4C41,$4E54,$4943,$2044,$4956,$4953,$494F,$4E00
	dc.w	$48E7,$FFFE,$4278,$B8C6,$4278,$B8C8,$4EB9,$0001
	dc.w	$149E,$4EB9,$0001,$14E4,$4278,$D312,$6100,$016A
	dc.w	$6100,$018C,$207C,$0018,$5F90,$4EB9,$0001,$218A
	dc.w	$4EB9,$001D,$BB92,$31FC,$0018,$BD3C,$08B8,$0002
	dc.w	$BFB2,$40E7,$6100,$0132,$46DF,$3038,$B052,$B078
	dc.w	$B052,$67FA,$4EB9,$0001,$2640,$0C78,$2A30,$D312
	dc.w	$3038,$B8C8,$5240,$B07C,$0008,$6D00,$0014,$4EB9
	dc.w	$001E,$1AD4,$5278,$B8C6,$0278,$0007,$B8C6,$4240
	dc.w	$31C0,$B8C8,$4EB9,$0001,$B282,$4EB9,$0001,$B320
	dc.w	$4A41,$6700,$0006,$4278,$D312,$0801,$0007,$6600
	dc.w	$007E,$0801,$0001,$6700,$0018,$0C78,$0006,$CFFE
	dc.w	$6798,$5278,$CFFE,$0C78,$0005,$CFFE,$6684,$6082
	dc.w	$0801,$0000,$6700,$001C,$4A78,$CFFE,$6700,$FF7C
	dc.w	$5378,$CFFE,$0C78,$0005,$CFFE,$6600,$FF66,$6000
	dc.w	$FF62,$0801,$0002,$6700,$0018,$207C,$001D,$A1AC
	dc.w	$3038,$CFFE,$E540,$2070,$0000,$5350,$6000,$FF44
	dc.w	$0801,$0003,$6700,$FF44,$207C,$001D,$A1AC,$3038
	dc.w	$CFFE,$E540,$2070,$0000,$5250,$6000,$FF26,$11F8
	dc.w	$D25D,$DD81,$11F8,$D25F,$DD88,$11F8,$D261,$DD89
	dc.w	$11F8,$D263,$DD82,$11F8,$D265,$DD83,$11F8,$D267
	dc.w	$DD86,$11F8,$D269,$DD87,$4EB9,$0001,$147E,$21FC
	dc.w	$0001,$22A4,$DDAC,$4CDF,$7FFF,$4E75,$FFFF,$D25C
	dc.w	$FFFF,$D25E,$FFFF,$D260,$FFFF,$D262,$FFFF,$D264
	dc.w	$FFFF,$D266,$FFFF,$D268,$48E7,$FFFE,$4EB9,$0001
	dc.w	$455A,$4CDF,$7FFF,$4E75,$23FC,$001D,$A414,$FFFF
	dc.w	$D002,$4278,$CFFE,$4278,$D000,$31FC,$0007,$D00A
	dc.w	$31FC,$0013,$B03C,$31FC,$0009,$B03E,$4E75,$08F8
	dc.w	$0005,$C356,$21FC,$0001,$2D46,$D244,$08B8,$0000
	dc.w	$BFB2,$08F8,$0002,$BFB2,$08B8,$0001,$BFB2,$31FC
	dc.w	$0000,$B000,$31FC,$B400,$B002,$31FC,$B800,$B00C
	dc.w	$31FC,$0005,$B00E,$31FC,$C000,$B008,$31FC,$0006
	dc.w	$B00A,$31FC,$E000,$B004,$31FC,$0006,$B006,$303C
	dc.w	$0000,$08F8,$0005,$BFB2,$4EB9,$0001,$B57E,$08B8
	dc.w	$0005,$BFB2,$4EB9,$0001,$B2C4,$383C,$0001,$227C
	dc.w	$0018,$5F90,$4EB9,$0001,$217A,$31C4,$B01C,$247C
	dc.w	$0017,$9170,$4EB9,$0001,$B730,$31C4,$B01E,$247C
	dc.w	$0017,$A16C,$4EB9,$0001,$B730,$21FC,$0017,$9168
	dc.w	$BF8A,$31C4,$B014,$247C,$0017,$AA7A,$4EB9,$0001
	dc.w	$B730,$08B8,$0002,$C354,$4EB9,$0001,$BA2E,$0008
	dc.w	$FF01,$FD00,$FC00,$7028,$721C,$343C,$07FF,$4EB9
	dc.w	$0001,$B976,$4EB9,$0001,$BB8E,$0006,$BF00,$0000
	dc.w	$207C,$0018,$33A2,$2248,$2448,$D1DA,$D3DA,$4240
	dc.w	$4241,$7428,$761C,$7A08,$4EB9,$0001,$B692,$4EB9
	dc.w	$0001,$BB8E,$0006,$BF0B,$0100,$207C,$0018,$5770
	dc.w	$2248,$2448,$D1DA,$D3DA,$4240,$4241,$3411,$3629
	dc.w	$0002,$7A08,$4EB9,$0001,$B692,$3F38,$B01C,$31F8
	dc.w	$B01E,$B01C,$4EB9,$0001,$BC72,$002A,$8F0B,$197B
	dc.w	$7D2D,$5345,$4C45,$4354,$204F,$5054,$494F,$4E53
	dc.w	$8F0B,$1A5B,$5D2D,$4348,$414E,$4745,$204F,$5054
	dc.w	$494F,$4E53,$31DF,$B01C,$4EB9,$0001,$BB8E,$0006
	dc.w	$FE00,$0000,$207C,$0017,$0B0C,$2248,$2448,$D1DA
	dc.w	$D3DA,$4240,$4241,$7440,$761C,$7A01,$4EB9,$0001
	dc.w	$B692,$31C4,$B8C4,$247C,$001C,$4C56,$4EB9,$0001
	dc.w	$B730,$4EB9,$0001,$BC72,$0066,$8F03,$0950,$4552
	dc.w	$494F,$4420,$4C45,$4E47,$5448,$3A8F,$030B,$474F
	dc.w	$414C,$4945,$533A,$8F03,$0D55,$5345,$5220,$5245
	dc.w	$434F,$5244,$533A,$8F03,$0F50,$454E,$414C,$5449
	dc.w	$4553,$3A8F,$0311,$4C49,$4E45,$2043,$4841,$4E47
	dc.w	$4553,$3A8F,$0313,$4649,$4748,$5449,$4E47,$3A8F
	dc.w	$0315,$534B,$494C,$4C20,$4C45,$5645,$4C3A,$46FC
	dc.w	$2500,$4E75,$0006,$FE07,$F900,$0006,$FE05,$F900
	dc.w	$001D,$A490,$001D,$A440,$001D,$A4F4,$001D,$A544
	dc.w	$001D,$A5A8,$001D,$A60C,$001D,$A65C,$FFFF,$FFFF
	dc.w	$3038,$D25E,$6A00,$0006,$303C,$0001,$B07C,$0001
	dc.w	$6F00,$0004,$4240,$31C0,$D25E,$227C,$001D,$A468
	dc.w	$4EB9,$0001,$D7F2,$4E75,$0014,$4D41,$4E55,$414C
	dc.w	$2043,$4F4E,$5452,$4F4C,$2020,$2020,$0014,$4155
	dc.w	$544F,$2043,$4F4E,$5452,$4F4C,$2020,$2020,$2020
	dc.w	$3038,$D25C,$6A00,$0006,$303C,$0002,$B07C,$0002
	dc.w	$6F00,$0004,$4240,$31C0,$D25C,$227C,$001D,$A4B8
	dc.w	$4EB9,$0001,$D7F2,$4E75,$0014,$3520,$4D49,$4E55
	dc.w	$5445,$5320,$2020,$2020,$2020,$2020,$0014,$3130
	dc.w	$204D,$494E,$5554,$4553,$2020,$2020,$2020,$2020
	dc.w	$0014,$3230,$204D,$494E,$5554,$4553,$2020,$2020
	dc.w	$2020,$2020,$3038,$D260,$6A00,$0006,$303C,$0001
	dc.w	$B07C,$0001,$6F00,$0004,$4240,$31C0,$D260,$227C
	dc.w	$001D,$A51C,$4EB9,$0001,$D7F2,$4E75,$0014,$4F46
	dc.w	$4620,$2020,$2020,$2020,$2020,$2020,$2020,$2020
	dc.w	$0014,$4F4E,$2020,$2020,$2020,$2020,$2020,$2020
	dc.w	$2020,$2020,$3038,$D262,$6A00,$0006,$303C,$0002
	dc.w	$B07C,$0002,$6F00,$0004,$4240,$31C0,$D262,$227C
	dc.w	$001D,$A56C,$4EB9,$0001,$D7F2,$4E75,$0014,$4F46
	dc.w	$4620,$2020,$2020,$2020,$2020,$2020,$2020,$2020
	dc.w	$0014,$4F4E,$2C20,$4E4F,$204F,$4646,$5349,$4445
	dc.w	$5320,$2020,$0014,$4F4E,$2020,$2020,$2020,$2020
	dc.w	$2020,$2020,$2020,$2020,$3038,$D264,$6A00,$0006
	dc.w	$303C,$0002,$B07C,$0002,$6F00,$0004,$4240,$31C0
	dc.w	$D264,$227C,$001D,$A5D0,$4EB9,$0001,$D7F2,$4E75
	dc.w	$0014,$4F46,$4620,$2020,$2020,$2020,$2020,$2020
	dc.w	$2020,$2020,$0014,$4155,$544F,$2020,$2020,$2020
	dc.w	$2020,$2020,$2020,$2020,$0014,$4F4E,$2020,$2020
	dc.w	$2020,$2020,$2020,$2020,$2020,$2020,$3038,$D266
	dc.w	$6A00,$0006,$303C,$0001,$B07C,$0001,$6F00,$0004
	dc.w	$4240,$31C0,$D266,$227C,$001D,$A634,$4EB9,$0001
	dc.w	$D7F2,$4E75,$0014,$4F4E,$2020,$2020,$2020,$2020
	dc.w	$2020,$2020,$2020,$2020,$0014,$4F46,$4620,$2020
	dc.w	$2020,$2020,$2020,$2020,$2020,$2020,$3038,$D268
	dc.w	$6A00,$0006,$303C,$0002,$B07C,$0002,$6F00,$0004
	dc.w	$4240,$31C0,$D268,$227C,$001D,$A684,$4EB9,$0001
	dc.w	$D7F2,$4E75,$0014,$5052,$4F20,$2020,$2020,$2020
	dc.w	$2020,$2020,$2020,$2020,$0014,$414C,$4C2D,$5354
	dc.w	$4152,$2020,$2020,$2020,$2020,$2020,$0014,$524F
	dc.w	$4F4B,$4945,$2020,$2020,$2020,$2020,$2020,$2020

