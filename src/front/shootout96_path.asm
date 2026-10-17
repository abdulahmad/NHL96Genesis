;	The shootout. The round box, the shooters, and the seven skate paths.

ShootoutModeBox	;Shootout round box: "SHOOTOUT MODE" (ShootoutModeBigTxt), the shooter " vs." the goalie, the goals of both
	;teams and the round
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#$FFFF,d0
	jsr	(prefmes).l
	jsr	(printz).l
	String	$BF,$03,$02
	moveq	#$1B,d0
	moveq	#$C,d1
	jsr	(Framer).l
	lea	ShootoutModeBigTxt(pc),a1
	jsr	(printbig2).l
	move.w	(BA_Skater_Offset).w,d0
	movea.l	#tmstruct,a2
	tst.w	(BA_Team).w
	beq.w	.0
	movea.l	#AwShots,a2
.0
	jsr	(FormatPlayerNumInitial).l
	move.w	(printx).w,-(sp)
	jsr	(print).l
	move.w	(sp)+,(printx).w
	addq.w	#1,(printy).w
	addq.w	#6,(printx).w
	jsr	(printz).l
	String	' vs.',$BF,$04,$07
	move.w	(BA_Goalie_SCnum).w,d0
	asl.w	#7,d0
	movea.l	#SortCords,a2
	adda.w	d0,a2
	clr.w	d0
	move.b	$67(a2),d0
	movea.l	#AwShots,a2
	tst.w	(BA_Team).w
	beq.w	.2
	movea.l	#tmstruct,a2
.2
	jsr	(FormatPlayerNumInitial).l
	jsr	(print).l
	jsr	(printbigz2).l
	String	$F8,$04,$01,$04,$08,'                         ',$FA,$02,$FD,$04,'                         '
	jsr	(printbigz1).l
	String	$F8,$04,$01,$05,$08,'<            >',$FD,$06
	movea.l	#tmstruct,a1
	movea.l	$1E(a1),a1
	adda.w	4(a1),a1
	jsr	(printbig1).l
	move.w	#$15,(printx).w
	move.w	(homeshootgoals).w,d0
	move.w	#3,d1
	jsr	(PushNumberWidth).l
	jsr	(printbig2).l
	jsr	(printbigz1).l
	String	$F8,$04,$01,$05,$0A,'<            >',$FD,$06
	movea.l	#AwShots,a1
	movea.l	$1E(a1),a1
	adda.w	4(a1),a1
	jsr	(printbig1).l
	move.w	#$15,(printx).w
	move.w	(awayshootgoals).w,d0
	move.w	#3,d1
	jsr	(PushNumberWidth).l
	jsr	(printbig2).l
	jsr	(printz).l
	String	$BF,$04,$0C,'       Round '
	move.w	(shootoutround).w,d0
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(print).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

ShootoutModeBigTxt	;ShootoutModeBox big text
	String	$F8,$04,$01,$04,$03,'      SHOOTOUT MODE      ',$F8,$04,$01,$04,$05

ShootoutInit	;Clear the player structs (SortCords) and the shootout state, then the shooter lists of both teams
	;(InitShooters)
	movea.l	#SortCords,a0
	move.w	#$3FF,d0
.loop
	clr.w	(a0)+
	dbf	d0,.loop
	clr.w	(shootoutdelay).w
	move.w	#1,(shootoutround).w
	bclr	#3,(gmode2).w
	clr.w	(homeshootgoals).w
	clr.w	(awayshootgoals).w
	clr.w	(homeshootnum).w
	clr.w	(shootoutteam).w
	rts

NextShooter	;Shootout: the next shooter (BA_Team, BA_Goalie_SCnum, StartShootoutPath), or the end (ExitToOpening).
	;Code the listing does not decode: kept as bytes
	dc.b	$08,$38,$00,$03,$C3,$48,$67,$00,$00,$08,$4E,$F9,$00,$02,$16,$EE
	dc.b	$48,$E7,$FF,$FE,$61,$00,$09,$98,$31,$F8,$D4,$54,$D2,$D2,$31,$FC
	dc.b	$00,$0B,$D2,$D6,$20,$7C,$FF,$FF,$D4,$3A,$4A,$78,$D4,$54,$67,$00
	dc.b	$00,$0E,$31,$FC,$00,$05,$D2,$D6,$20,$7C,$FF,$FF,$D4,$48,$30,$38
	dc.b	$D4,$46,$D0,$40,$31,$F0,$00,$00,$D2,$D8,$08,$B8,$00,$02,$B7,$C0
	dc.b	$4C,$DF,$7F,$FF,$4E,$75

CountShootoutGoals	;Shootout: count the goals and end it when one team cannot catch up (EndShootout)
	movem.l	d0-d7/a0-a6,-(sp)
	btst	#0,(shootoutteam+1).w
	beq.w	.switch
	cmpi.w	#5,(shootoutround).w
	blt.w	.switch
	move.w	(homeshootgoals).w,d0
	cmp.w	(awayshootgoals).w,d0
	beq.w	.switch
	bset	#3,(gmode2).w
	jsr	(EndShootout).l
	bra.w	.x
.switch
	eori.w	#1,(shootoutteam).w
	bne.w	.x
	addq.w	#1,(homeshootnum).w
	cmpi.w	#5,(homeshootnum).w
	blt.w	.1
	clr.w	(homeshootnum).w
.1
	addq.w	#1,(shootoutround).w
.x
	movem.l	(sp)+,d0-d7/a0-a6
	rts

InitShooters	;The 6 starters of the home (shootoutteam 0) or away team (save RAM roster SRLines, $82 bytes a team) as the
	;shooter list below homeshootnum / shootoutteam
	movea.l	#$FFFFD446,a0
	move.w	(HomeTeam).w,d0
	tst.w	(shootoutteam).w
	beq.w	.0
	move.w	(VisTeam).w,d0
	movea.l	#$FFFFD454,a0
.0
	movem.l	d7-a0,-(sp)
	move.w	d0,d7
	jsr	(GetTeamLines).l
	movea.l	a0,a1
	movem.l	(sp)+,d7-a0
	move.w	#5,d0
.1
	clr.w	d1
	move.b	(a1)+,d1
	subq.w	#1,d1
	move.w	d1,-(a0)
	dbf	d0,.1
	rts

ShootoutWonBy	;Shootout: "SHOOTOUT WON BY" and the winning team (printbig1)
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(printz).l
	String	$BF,$01,$0D
	move.w	#6,d1
	move.w	#$1E,d0
	jsr	(Framer).l
	jsr	(printbigz2).l
	String	$F8,$04,$01,$02,$0E,'      SHOOTOUT WON BY       '
	addq.w	#2,(printy).w
	move.w	(HomeTeam).w,d1
	move.w	(homeshootgoals).w,d0
	cmp.w	(awayshootgoals).w,d0
	bgt.w	.0
	move.w	(VisTeam).w,d1
.0
	asl.w	#2,d1
	movea.l	#$77E,a1
	movea.l	(a1,d1.w),a1
	adda.w	4(a1),a1
	move.w	(a1),d0
	subq.w	#2,d0
	asr.w	#1,d0
	move.w	#$10,(printx).w
	sub.w	d0,(printx).w
	subq.w	#1,(printx).w
	jsr	(printbigz1).l
	String	$3C
	jsr	(printbig1).l
	jsr	(printbigz1).l
	String	$3E
	movem.l	(sp)+,d0-d7/a0-a6
	rts

GetTeamNickname	;a1 = the nickname String of team a2, or HomeTxt / VisitorsTxt when it is empty.
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$80,$A0,$22,$4A,$22,$69,$00,$1E,$D2,$E9,$00,$04,$D2,$D1
	dc.b	$D2,$D1,$0C,$51,$00,$02,$66,$00,$00,$18,$22,$7C,$00,$1D,$83,$7C
	dc.b	$B5,$FC,$FF,$FF,$C7,$26,$67,$00,$00,$08,$22,$7C,$00,$1D,$83,$82
	dc.b	$4C,$DF,$05,$01,$4E,$75

HomeTxt	;GetTeamNickname: the home team without a nickname
	String	'Home'

VisitorsTxt	;GetTeamNickname: the away team without a nickname
	String	'Visitors'

GetTeamArena	;a1 = the arena String of team a2.
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$80,$A0,$22,$4A,$22,$69,$00,$1E,$D2,$E9,$00,$04,$D2,$D1
	dc.b	$D2,$D1,$D2,$D1,$4C,$DF,$05,$01,$4E,$75,$48,$E7,$FF,$FE,$4C,$DF
	dc.b	$7F,$FF,$4E,$75

EndShootout	;Shootout over: LockScroll, then the 5 skaters of player slots 1-5 (homeshootgoals > awayshootgoals) or 7-$B
	;are set up (setplayer) above or below the view and get assscore (assinsert 7)
	movem.l	d0-d7/a0-a6,-(sp)
	bset	#2,(sflags2).w
	jsr	(LockScroll).l
	move.w	#$60,(shootoutdelay).w
	movea.l	#SortCords,a3
	move.w	#0,d0
	move.w	(homeshootgoals).w,d2
	cmp.w	(awayshootgoals).w,d2
	bgt.w	.0
	move.w	#6,d0
.0
	asl.w	#7,d0
	adda.w	d0,a3
	move.w	#4,d2
	move.w	#6,d3
	bra.w	.2
.loop
	movem.w	d2-d3,-(sp)
	jsr	(setplayer).l
	move.w	#2,$34(a3)
	move.w	#$F0,d0
	tst.w	(Vpos).w
	bmi.w	.1
	move.w	#$FF10,d0
.1
	add.w	(Vpos).w,d0
	move.w	d0,$14(a3)
	move.w	#0,(a3)
	move.w	#7,d0
	jsr	(assinsert).l
	bclr	#5,$62(a3)
	bclr	#1,$63(a3)
	bclr	#2,$62(a3)
	movem.w	(sp)+,d2-d3
.2
	adda.l	#$80,a3
	dbf	d2,.loop
	movem.l	(sp)+,d0-d7/a0-a6
	rts
	dc.b	$48,$E7,$FF,$80,$3E,$2B,$00,$34,$53,$47,$20,$7C,$00,$1D,$84,$B4
	dc.b	$08,$2B,$00,$07,$00,$62,$67,$00,$00,$08,$20,$7C,$00,$1D,$84,$C4
	dc.b	$DE,$47,$30,$30,$70,$00,$B0,$6B,$00,$44,$6D,$00,$00,$06,$37,$40
	dc.b	$00,$44,$30,$30,$70,$02,$B0,$6B,$00,$44,$6E,$00,$00,$06,$37,$40
	dc.b	$00,$44,$30,$30,$70,$04,$B0,$6B,$00,$46,$6D,$00,$00,$06,$37,$40
	dc.b	$00,$46,$30,$30,$70,$06,$B0,$6B,$00,$46,$6E,$00,$00,$06,$37,$40
	dc.b	$00,$46,$4C,$DF,$01,$FF,$4E,$75,$FF,$B5,$00,$00,$00,$00,$01,$1E
	dc.b	$00,$00,$00,$4B,$00,$00,$01,$1E,$FF,$B5,$00,$00,$FE,$E2,$00,$00
	dc.b	$00,$00,$00,$4B,$FE,$E2,$00,$00

AddArenaAnimSprite	;Add the arena animation sprites; disabled in 96: the rts comes first and the body after it is dead
	rts
	dc.b	$4A,$78,$D4,$74,$6B,$00,$01,$18,$4A,$B8,$D4,$7A,$67,$00,$01,$10
	dc.b	$08,$38,$00,$04,$C3,$42,$66,$00,$01,$06,$08,$38,$00,$03,$C3,$3C
	dc.b	$66,$00,$00,$FC,$08,$38,$00,$07,$C3,$3A,$66,$00,$00,$F2,$22,$78
	dc.b	$D4,$7A,$D3,$E9,$00,$04,$38,$38,$BD,$32,$3A,$38,$BD,$2E,$30,$38
	dc.b	$D4,$6E,$60,$00,$00,$22,$02,$42,$00,$0F,$B4,$7C,$00,$03,$63,$00
	dc.b	$00,$04,$74,$03,$60,$00,$00,$0A,$30,$03,$D0,$42,$61,$00,$00,$08
	dc.b	$51,$CA,$FF,$F6,$4E,$75

.spr	;Add the arena animation sprites in view (the ShowCrowdFrame loop); reached only from the dead body above
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$80,$67,$00,$00,$B4,$BC,$7C,$00,$40,$6C,$00,$00,$AC,$48,$E7
	dc.b	$FC,$00,$D0,$40,$20,$49,$32,$30,$00,$02,$92,$70,$00,$00,$E6,$49
	dc.b	$53,$41,$3F,$01,$D0,$F0,$00,$00,$30,$04,$06,$40,$00,$C0,$32,$00
	dc.b	$04,$40,$00,$90,$06,$41,$00,$80,$34,$3C,$01,$70,$94,$45,$36,$02
	dc.b	$04,$42,$00,$80,$06,$43,$00,$70,$38,$1F,$B4,$50,$6E,$00,$00,$60
	dc.b	$B6,$50,$6D,$00,$00,$5A,$B0,$68,$00,$06,$6E,$00,$00,$52,$B2,$68
	dc.b	$00,$06,$6D,$00,$00,$4A,$3A,$10,$06,$45,$00,$70,$9A,$42,$3C,$C5
	dc.b	$1C,$E8,$00,$02,$02,$2E,$00,$0F,$FF,$FF,$1C,$C6,$1A,$28,$00,$04
	dc.b	$02,$45,$00,$F8,$E1,$4D,$3F,$05,$3A,$28,$00,$04,$02,$45,$07,$FF
	dc.b	$DA,$78,$D4,$6C,$8A,$5F,$3C,$C5,$3A,$28,$00,$06,$06,$45,$00,$70
	dc.b	$9A,$40,$3C,$C5,$52,$46,$BC,$7C,$00,$40,$67,$00,$00,$08,$50,$48
	dc.b	$51,$CC,$FF,$98,$4C,$DF,$00,$3F,$4E,$75,$48,$E7,$FF,$B0,$4E,$B9
	dc.b	$00,$02,$2F,$44,$30,$11,$55,$40,$33,$40,$00,$02,$54,$49,$4C,$DF
	dc.b	$0D,$FF,$4E,$75,$00,$06,$20,$2E,$20,$00,$4E,$75

updatePPTeamTime	;Power play time of the teams, once a second. Called from updatepentime
	btst	#5,(sflags2).w
	beq.w	.x
	movea.l	#tmstruct,a2
	btst	#6,(sflags2).w
	beq.w	.0
	movea.l	#AwShots,a2
.0
	addq.w	#1,$38C(a2)
.x
	rts
	dc.b	$48,$E7,$7F,$FE,$30,$2A,$00,$28,$20,$7C,$00,$1D,$86,$5A,$42,$41
	dc.b	$12,$30,$00,$00,$30,$01,$4C,$DF,$7F,$FE,$4E,$75,$33,$4C,$49,$4B
	dc.b	$4E,$43,$4B,$43,$34,$42,$4A,$49,$44,$42,$4A,$37,$45,$4B,$47,$38
	dc.b	$45,$38,$48,$47,$48,$46,$5B,$59

ShortenMsgTimer	;Cap the message timer at 2, unless a second pad is on and a3 is not the puck carrier
	movem.l	d0,-(sp)
	tst.w	(cont2team).w
	beq.w	.0
	move.w	$52(a3),d0
	cmp.w	(puckc).w,d0
	bne.w	.x
.0
	cmpi.w	#2,(msgtimer).w
	ble.w	.x
	move.w	#2,(msgtimer).w
.x
	movem.l	(sp)+,d0
	rts

ManualGoalieMenu	;The "x Manual Goalie" pause menu item.
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$FF,$FE,$4A,$78,$D2,$56,$67,$00,$00,$20,$61,$00,$11,$92
	dc.b	$08,$38,$00,$01,$C3,$3A,$67,$00,$00,$0C,$0A,$78,$00,$01,$D2,$6E
	dc.b	$60,$00,$00,$08,$0A,$78,$00,$01,$D2,$6C,$08,$38,$00,$00,$C3,$48
	dc.b	$66,$00,$00,$0C,$08,$38,$00,$02,$C3,$40,$67,$00,$00,$9C,$08,$38
	dc.b	$00,$01,$C3,$3A,$66,$00,$00,$5A,$0C,$78,$00,$02,$D2,$56,$66,$00
	dc.b	$00,$10,$0C,$78,$00,$05,$D2,$D4,$6E,$00,$00,$7E,$60,$00,$00,$0C
	dc.b	$0C,$78,$00,$05,$D2,$D4,$6F,$00,$00,$70,$30,$3C,$00,$00,$0C,$78
	dc.b	$00,$02,$D2,$56,$66,$00,$00,$06,$30,$3C,$00,$06,$4A,$78,$D2,$6C
	dc.b	$66,$00,$00,$14,$30,$3C,$00,$05,$0C,$78,$00,$02,$D2,$56,$66,$00
	dc.b	$00,$06,$30,$3C,$00,$0B,$4E,$B9,$00,$01,$6C,$52,$60,$00,$00,$3A
	dc.b	$0C,$78,$00,$02,$D2,$56,$66,$00,$00,$10,$0C,$78,$00,$05,$D2,$D4
	dc.b	$6F,$00,$00,$26,$60,$00,$00,$0C,$0C,$78,$00,$05,$D2,$D4,$6E,$00
	dc.b	$00,$18,$30,$3C,$00,$06,$4A,$78,$D2,$6E,$66,$00,$00,$06,$30,$3C
	dc.b	$00,$0B,$4E,$B9,$00,$01,$6C,$5C,$4C,$DF,$7F,$FF,$4E,$75

RunArenaAnim	;Run the arena animation (load its frames and tiles, step the frames); disabled in 96 by the leading rts
	rts
	dc.b	$4A,$78,$D4,$74,$6B,$00,$00,$56,$48,$E7,$FF,$FE,$4A,$B8,$D4,$7A
	dc.b	$66,$00,$00,$36,$30,$38,$D4,$74,$E7,$40,$20,$7C,$00,$1D,$88,$20
	dc.b	$21,$F0,$00,$00,$D4,$76,$21,$F0,$00,$04,$D4,$7A,$24,$70,$00,$04
	dc.b	$50,$4A,$38,$38,$D4,$6C,$4E,$B9,$00,$01,$B7,$30,$42,$78,$D4,$70
	dc.b	$61,$00,$00,$1C,$60,$00,$00,$12,$9F,$78,$D4,$72,$6A,$00,$00,$0A
	dc.b	$52,$78,$D4,$70,$61,$00,$00,$08,$4C,$DF,$7F,$FF,$4E,$75,$20,$78
	dc.b	$D4,$76,$30,$38,$D4,$70,$D0,$40,$12,$30,$00,$00,$48,$81,$31,$C1
	dc.b	$D4,$6E,$12,$30,$00,$01,$48,$81,$31,$C1,$D4,$72,$0C,$78,$FF,$FF
	dc.b	$D4,$6E,$66,$00,$00,$08,$42,$78,$D4,$70,$60,$D2,$0C,$78,$FF,$FE
	dc.b	$D4,$6E,$66,$00,$00,$06,$61,$00,$02,$A4,$4E,$75,$00,$1D,$8A,$50
	dc.b	$00,$14,$17,$B6,$00,$1D,$89,$88,$00,$14,$17,$B6,$00,$1D,$8A,$30
	dc.b	$00,$14,$17,$B6,$00,$1D,$89,$E8,$00,$14,$17,$B6,$00,$1D,$89,$B6
	dc.b	$00,$14,$17,$B6,$00,$1D,$8A,$30,$00,$14,$17,$B6,$00,$1D,$88,$92
	dc.b	$00,$14,$17,$B6,$00,$1D,$88,$60,$00,$14,$17,$B6,$01,$0A,$02,$0A
	dc.b	$03,$0A,$04,$0A,$05,$0A,$06,$0A,$07,$0A,$08,$0A,$01,$0A,$02,$0A
	dc.b	$03,$0A,$04,$0A,$05,$0A,$06,$0A,$07,$0A,$08,$0A,$01,$0A,$02,$0A
	dc.b	$03,$0A,$04,$0A,$05,$0A,$06,$0A,$07,$0A,$08,$0A,$FE,$00,$01,$0A
	dc.b	$02,$0A,$03,$0A,$04,$0A,$05,$0A,$06,$0A,$07,$0A,$08,$0A,$FF,$00
	dc.b	$01,$0A,$02,$0A,$03,$0A,$04,$0A,$05,$0A,$06,$0A,$07,$0A,$08,$0A
	dc.b	$09,$0A,$0A,$0A,$0B,$0A,$0C,$0A,$0D,$0A,$0E,$0A,$0F,$0A,$10,$0A
	dc.b	$11,$0A,$12,$0A,$13,$0A,$14,$0A,$15,$0A,$16,$0A,$17,$0A,$FE,$00
	dc.b	$01,$08,$02,$08,$03,$3C,$04,$3C,$03,$3C,$04,$3C,$03,$3C,$04,$3C
	dc.b	$03,$3C,$04,$3C,$03,$3C,$04,$3C,$03,$3C,$04,$3C,$03,$3C,$04,$3C
	dc.b	$03,$3C,$04,$3C,$03,$3C,$04,$3C,$03,$3C,$04,$3C,$03,$3C,$04,$3C
	dc.b	$03,$3C,$04,$3C,$03,$3C,$04,$3C,$03,$3C,$04,$3C,$03,$3C,$04,$3C
	dc.b	$03,$3C,$04,$3C,$03,$3C,$04,$3C,$03,$3C,$04,$3C,$03,$3C,$04,$3C
	dc.b	$02,$08,$01,$08,$FF,$00,$01,$08,$02,$08,$03,$08,$04,$08,$05,$08
	dc.b	$06,$08,$07,$08,$08,$08,$FF,$00,$01,$08,$02,$08,$03,$08,$04,$1E
	dc.b	$05,$08,$06,$08,$07,$08,$08,$1E,$05,$08,$06,$08,$07,$08,$08,$1E
	dc.b	$09,$08,$0A,$08,$0B,$08,$0C,$08,$0D,$08,$0E,$08,$FE,$00,$0F,$08
	dc.b	$10,$08,$11,$08,$12,$1E,$13,$08,$14,$08,$15,$08,$16,$1E,$13,$08
	dc.b	$14,$08,$15,$08,$16,$1E,$17,$08,$18,$08,$19,$08,$1A,$08,$1B,$08
	dc.b	$1C,$08,$FE,$00,$01,$08,$02,$08,$03,$08,$04,$08,$05,$08,$06,$08
	dc.b	$07,$08,$08,$08,$09,$08,$0A,$08,$0B,$08,$0C,$08,$0D,$08,$0E,$08
	dc.b	$0F,$08,$10,$08,$11,$08,$12,$08,$13,$08,$14,$08,$15,$08,$16,$08
	dc.b	$FE,$00,$01,$08,$02,$08,$03,$08,$04,$08,$05,$08,$06,$08,$07,$08
	dc.b	$08,$08,$09,$08,$0A,$08,$0B,$08,$0C,$08,$0D,$08,$0E,$08,$0F,$08
	dc.b	$10,$08,$11,$08,$12,$08,$13,$08,$14,$08,$15,$08,$16,$08,$17,$08
	dc.b	$18,$08,$18,$7F,$01,$08,$02,$08,$03,$08,$04,$08,$05,$08,$06,$08
	dc.b	$07,$08,$08,$08,$09,$08,$0A,$08,$0B,$08,$0C,$08,$0D,$08,$0E,$08
	dc.b	$0F,$08,$10,$08,$11,$08,$12,$08,$13,$08,$14,$08,$15,$08,$16,$08
	dc.b	$17,$08,$18,$08,$19,$08,$1A,$08,$1B,$08,$1C,$08,$1D,$08,$1E,$08
	dc.b	$1F,$08,$20,$08,$21,$08,$22,$08,$23,$08,$FE,$00,$01,$08,$02,$08
	dc.b	$03,$08,$04,$08,$05,$08,$06,$08,$07,$08,$08,$08,$09,$08,$0A,$08
	dc.b	$0B,$08,$0C,$08,$0D,$08,$0E,$08,$0F,$08,$FF,$00,$01,$0A,$02,$0A
	dc.b	$03,$0A,$04,$0A,$05,$0A,$06,$0A,$07,$0A,$08,$0A,$08,$0A,$08,$0A
	dc.b	$08,$0A,$08,$0A,$08,$0A,$08,$0A,$08,$7F,$08,$7F,$FE,$00,$08,$F8
	dc.b	$00,$06,$C3,$3A,$31,$FC,$00,$00,$BF,$DC,$31,$FC,$01,$60,$BF,$DE
	dc.b	$4E,$75

StartArenaAnim	;Start arena animation d0; disabled in 96 by the leading rts
	rts
	dc.b	$48,$E7,$FF,$FE,$31,$C0,$D4,$74,$21,$FC,$00,$00,$00,$00,$D4,$76
	dc.b	$21,$FC,$00,$00,$00,$00,$D4,$7A,$31,$FC,$00,$01,$D4,$6E,$42,$78
	dc.b	$D4,$70,$50,$F8,$D4,$7E,$4C,$DF,$7F,$FF,$4E,$75

SetFaceoffAnim	;Set the faceoff animation d0 (sflags7 bit 0)
	;Code the listing does not decode: kept as bytes
	dc.b	$08,$F8,$00,$00,$C3,$4A,$31,$C0,$D4,$7E,$4E,$75

EndArenaAnim	;End the arena animation (none running, sflags7 bit 0 cleared)
	;Code the listing does not decode: kept as bytes
	dc.b	$31,$FC,$FF,$FF,$D4,$74,$08,$B8,$00,$00,$C3,$4A,$4E,$75

ClearWinRecords	;Clear bytes 8-$B (wins, games) of the 8 ThreeStars records and write the $80 bytes to save RAM SRTeamRecords
	;(WriteSRAM, MakeSRAMChecksum).
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$FF,$FE,$20,$7C,$FF,$FF,$D1,$30,$3E,$3C,$00,$07,$42,$28
	dc.b	$00,$08,$42,$28,$00,$09,$42,$28,$00,$0A,$42,$28,$00,$0B,$42,$10
	dc.b	$42,$28,$00,$04,$42,$28,$00,$0C,$42,$28,$00,$0D,$D0,$FC,$00,$10
	dc.b	$51,$CF,$FF,$DC,$20,$3C,$00,$00,$0E,$CE,$22,$3C,$00,$00,$00,$80
	dc.b	$20,$7C,$FF,$FF,$D1,$30,$4E,$B9,$00,$02,$41,$88,$4E,$B9,$00,$02
	dc.b	$41,$AA,$4C,$DF,$7F,$FF,$4E,$75

PSandSOpassdir	;Penalty shot / shootout: passdir = sopathdir (the end of the skate path NextPathPoint), turned by passdirlist
	;for the bottom net
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(sopathdir).w,d0
	btst	#7,$62(a3)
	bne.w	.0
	movea.l	#passdirlist,a0
	add.w	d0,d0
	move.w	(a0,d0.w),d0
.0
	move.w	d0,(passdir).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts

passdirlist	;PSandSOpassdir: passdir for the other net
	dc.b	$00,$00,$00,$07,$00,$06,$00,$05,$00,$04,$00,$03,$00,$02,$00,$01
	dc.b	$00,$08

StartShootoutPath	;Shootout: pick one of the 7 skate paths (ShootoutPaths) at random (sopath) and start it (NextPathPoint).
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$FF,$FE,$30,$3C,$00,$07,$4E,$B9,$00,$01,$B0,$A6,$B0,$7C
	dc.b	$00,$06,$6E,$F0,$31,$C0,$D8,$14,$08,$B8,$00,$03,$C3,$4A,$31,$FC
	dc.b	$FF,$FF,$D8,$16,$42,$78,$D8,$18,$61,$00,$00,$7C,$4C,$DF,$7F,$FF
	dc.b	$4E,$75

ShootoutPaths	;The 7 shootout skate paths (NextPathPoint)
	dc.l	ShootoutPath1
	dc.l	ShootoutPath2
	dc.l	ShootoutPath3
	dc.l	ShootoutPath4
	dc.l	ShootoutPath5
	dc.l	ShootoutPath6
	dc.l	ShootoutPath7

ShootoutPath1	;ShootoutPaths path: x, y points; $80 in the high byte ends it (low byte: sopathend, then sopathdir)
	dc.w	$10,$E2,$10,$D0,$8020,5

ShootoutPath2	;ShootoutPaths path: x, y points; $80 in the high byte ends it (low byte: sopathend, then sopathdir)
	dc.w	$FFC9,$A0,$FFFF,$C8,$FFE0,$D0,$8020,5

ShootoutPath3	;ShootoutPaths path: x, y points; $80 in the high byte ends it (low byte: sopathend, then sopathdir)
	dc.w	$FFB0,$40,$1A,$BC,$8020,5

ShootoutPath4	;ShootoutPaths path: x, y points; $80 in the high byte ends it (low byte: sopathend, then sopathdir)
	dc.w	$FFCE,$58,$14,$D0,$802C,5

ShootoutPath5	;ShootoutPaths path: x, y points; $80 in the high byte ends it (low byte: sopathend, then sopathdir)
	dc.w	$FFCE,8,$20,$D0,$8028,6

ShootoutPath6	;ShootoutPaths path: x, y points; $80 in the high byte ends it (low byte: sopathend, then sopathdir)
	dc.w	$1C,$F4,8,$E0,$8020,6

ShootoutPath7	;ShootoutPaths path: x, y points; $80 in the high byte ends it (low byte: sopathend, then sopathdir)
	dc.w	$FFE6,$F8,0,$E0,$8020,2

NextPathPoint	;Next point of shootout path sopath: sopathx / sopathy = x (turned by bit 0 of $76(a3)) / y; at the end ($80)
	;sflags7 bit 3, sopathend and sopathdir.
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$FF,$FE,$0C,$38,$00,$80,$D8,$18,$67,$00,$00,$56,$52,$78
	dc.b	$D8,$16,$30,$38,$D8,$16,$E5,$40,$20,$7C,$00,$1D,$8B,$92,$32,$38
	dc.b	$D8,$14,$E5,$41,$20,$70,$10,$00,$31,$F0,$00,$00,$D8,$18,$08,$2B
	dc.b	$00,$00,$00,$77,$67,$00,$00,$06,$44,$78,$D8,$18,$31,$F0,$00,$02
	dc.b	$D8,$1A,$0C,$30,$00,$80,$00,$04,$66,$00,$00,$18,$08,$F8,$00,$03
	dc.b	$C3,$4A,$42,$78,$D8,$1E,$11,$F0,$00,$05,$D8,$1F,$31,$F0,$00,$06
	dc.b	$D8,$1C,$4C,$DF,$7F,$FF,$4E,$75

SkatePath	;Shootout skate path: d0 / d1 = the point (mirrored for the bottom net); within $A of it ($12 while $28 /
	;$2A(a3) are 0) take the next one (NextPathPoint).
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$3F,$FE,$0C,$38,$00,$80,$D8,$18,$67,$00,$00,$76,$30,$38
	dc.b	$D8,$18,$32,$38,$D8,$1A,$08,$2B,$00,$07,$00,$62,$66,$00,$00,$06
	dc.b	$44,$40,$44,$41,$90,$53,$6A,$00,$00,$04,$44,$40,$4A,$6B,$00,$28
	dc.b	$66,$00,$00,$12,$4A,$6B,$00,$2A,$66,$00,$00,$0A,$B0,$7C,$00,$12
	dc.b	$6F,$00,$00,$0A,$B0,$7C,$00,$0A,$6E,$00,$00,$30,$92,$6B,$00,$14
	dc.b	$6A,$00,$00,$04,$44,$41,$4A,$6B,$00,$28,$66,$00,$00,$12,$4A,$6B
	dc.b	$00,$2A,$66,$00,$00,$0A,$B2,$7C,$00,$12,$6F,$00,$00,$0A,$B2,$7C
	dc.b	$00,$0A,$6E,$00,$00,$06,$61,$00,$FF,$20,$30,$38,$D8,$18,$32,$38
	dc.b	$D8,$1A,$4C,$DF,$7F,$FC,$4E,$75

ShootoutShootCheck	;Shootout, skater a3 has the puck (gmode2 bit 1): Z set (d0 is restored) = shoot now after 3 (shootoutclock)
	;at the path end, within sopathend of its last point, or with the puck stopped before $F.
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$FF,$FE,$08,$38,$00,$01,$C3,$48,$67,$00,$00,$88,$30,$2B
	dc.b	$00,$52,$B0,$78,$B7,$BE,$66,$00,$00,$7C,$0C,$78,$00,$03,$D3,$26
	dc.b	$6F,$00,$00,$6C,$0C,$38,$00,$80,$D8,$18,$67,$00,$00,$62,$08,$38
	dc.b	$00,$03,$C3,$4A,$66,$00,$00,$20,$4A,$78,$B7,$86,$66,$00,$00,$56
	dc.b	$4A,$78,$B7,$88,$66,$00,$00,$4E,$0C,$78,$00,$0F,$D3,$26,$6D,$00
	dc.b	$00,$3E,$60,$00,$00,$40,$30,$38,$D8,$18,$32,$38,$D8,$1A,$08,$2B
	dc.b	$00,$07,$00,$62,$66,$00,$00,$06,$44,$40,$44,$41,$90,$53,$6A,$00
	dc.b	$00,$04,$44,$40,$92,$6B,$00,$14,$6A,$00,$00,$04,$44,$41,$B0,$78
	dc.b	$D8,$1E,$6E,$00,$00,$10,$B2,$78,$D8,$1E,$6E,$00,$00,$08,$42,$40
	dc.b	$60,$00,$00,$06,$30,$3C,$00,$01,$4C,$DF,$7F,$FF,$4E,$75

UnpackPicture	;Unpack a picture a2: count.w, then 3 bytes per row of 8 pixels to 4 bit pixels + 5 at picturebuf (count
	;first). Called from DrawPictureBox DrawMatchupPicture and PlayerCardScreen.
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$FF,$FE,$20,$7C,$FF,$FF,$D8,$20,$22,$7C,$FF,$FF,$DC,$A2
	dc.b	$30,$1A,$30,$C0,$E7,$40,$53,$40,$42,$90,$42,$91,$12,$9A,$13,$5A
	dc.b	$00,$01,$13,$5A,$00,$02,$2F,$3C,$00,$00,$00,$00,$24,$11,$02,$82
	dc.b	$E0,$00,$00,$00,$E2,$8A,$06,$82,$50,$00,$00,$00,$85,$97,$24,$11
	dc.b	$02,$82,$1C,$00,$00,$00,$E4,$8A,$06,$82,$05,$00,$00,$00,$85,$97
	dc.b	$24,$11,$02,$82,$03,$80,$00,$00,$E6,$8A,$06,$82,$00,$50,$00,$00
	dc.b	$85,$97,$24,$11,$02,$82,$00,$70,$00,$00,$E8,$8A,$06,$82,$00,$05
	dc.b	$00,$00,$85,$97,$24,$11,$02,$82,$00,$0E,$00,$00,$EA,$8A,$06,$82
	dc.b	$00,$00,$50,$00,$85,$97,$24,$11,$02,$82,$00,$01,$C0,$00,$EC,$8A
	dc.b	$06,$82,$00,$00,$05,$00,$85,$97,$24,$11,$02,$82,$00,$00,$38,$00
	dc.b	$EE,$8A,$06,$82,$00,$00,$00,$50,$85,$97,$24,$11,$02,$82,$00,$00
	dc.b	$07,$00,$3A,$3C,$00,$08,$EA,$AA,$5A,$82,$85,$97,$20,$DF,$51,$C8
	dc.b	$FF,$58,$4C,$DF,$7F,$FF,$4E,$75
