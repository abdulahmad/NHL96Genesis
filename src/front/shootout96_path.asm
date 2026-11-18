;	The shootout. The round box, the shooters, and the seven skate paths.

ShootoutModeBox						;Shootout round box: "SHOOTOUT MODE" (ShootoutModeBigTxt), the shooter "
									;vs." the goalie, the goals of both
									;teams and the round
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#$FFFF,d0
	jsr	(prefmes).l
	jsr	(printz).l
	String	CC_Font1Pri,$03,$02
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
	String	' vs.',CC_Font1Pri,$04,$07
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
	String	CC_SetMapAndPosition,$04,$01,$04,$08,'                         ',CC_AddY,$02,CC_SetX,$04,'                         '
	jsr	(printbigz1).l
	String	CC_SetMapAndPosition,$04,$01,$05,$08,'<            >',CC_SetX,$06
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
	String	CC_SetMapAndPosition,$04,$01,$05,$0A,'<            >',CC_SetX,$06
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
	String	CC_Font1Pri,$04,$0C,'       Round '
	move.w	(shootoutround).w,d0
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(print).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

ShootoutModeBigTxt					;ShootoutModeBox big text
	String	CC_SetMapAndPosition,$04,$01,$04,$03,'      SHOOTOUT MODE      ',CC_SetMapAndPosition,$04,$01,$04,$05

ShootoutInit						;Clear the player structs (SortCords) and the shootout state, then the
									;shooter lists of both teams (InitShooters)
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

NextShooter							;Shootout: the next shooter (BA_Team, BA_Goalie_SCnum, StartShootoutPath),
									;or the end (ExitToOpening).
	btst	#3,(gmode2).w
	beq.w	.1
	jmp	(ExitToOpening).l
.1
	movem.l	d0-d7/a0-a6,-(sp)
	bsr.w	StartShootoutPath
	move.w	(shootoutteam).w,(BA_Team).w
	move.w	#$B,(BA_Goalie_SCnum).w
	movea.l	#shootoutround+2,a0
	tst.w	(shootoutteam).w
	beq.w	.2
	move.w	#5,(BA_Goalie_SCnum).w
	movea.l	#homeshootnum+2,a0
.2
	move.w	(homeshootnum).w,d0
	add.w	d0,d0
	move.w	(a0,d0.w),(BA_Skater_Offset).w
	bclr	#pfnc,(puckc+2).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts

CountShootoutGoals					;Shootout: count the goals and end it when one team cannot catch up
									;(EndShootout)
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

InitShooters						;The 6 starters of the home (shootoutteam 0) or away team (save RAM roster
									;SRLines, $82 bytes a team) as the
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

ShootoutWonBy						;Shootout: "SHOOTOUT WON BY" and the winning team (printbig1)
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(printz).l
	String	CC_Font1Pri,$01,$0D
	move.w	#6,d1
	move.w	#$1E,d0
	jsr	(Framer).l
	jsr	(printbigz2).l
	String	CC_SetMapAndPosition,$04,$01,$02,$0E,'      SHOOTOUT WON BY       '
	addq.w	#2,(printy).w
	move.w	(HomeTeam).w,d1
	move.w	(homeshootgoals).w,d0
	cmp.w	(awayshootgoals).w,d0
	bgt.w	.0
	move.w	(VisTeam).w,d1
.0
	asl.w	#2,d1
	movea.l	#TeamList,a1
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

GetTeamNickname						;a1 = the nickname String of team a2, or HomeTxt / VisitorsTxt when it is
									;empty.
	movem.l	d0/a0/a2,-(sp)
	movea.l	a2,a1
	movea.l	$1E(a1),a1				;tmdata
	adda.w	4(a1),a1				;city
	adda.w	(a1),a1					;abbreviation
	adda.w	(a1),a1					;nickname
	cmpi.w	#2,(a1)					;empty String?
	bne.w	.1
	movea.l	#HomeTxt,a1
	cmpa.l	#tmstruct,a2
	beq.w	.1
	movea.l	#VisitorsTxt,a1
.1
	movem.l	(sp)+,d0/a0/a2
	rts

HomeTxt								;GetTeamNickname: the home team without a nickname
	String	'Home'

VisitorsTxt							;GetTeamNickname: the away team without a nickname
	String	'Visitors'

GetTeamArena						;a1 = the arena String of team a2.
	movem.l	d0/a0/a2,-(sp)
	movea.l	a2,a1
	movea.l	$1E(a1),a1				;tmdata
	adda.w	4(a1),a1				;city
	adda.w	(a1),a1
	adda.w	(a1),a1
	adda.w	(a1),a1					;arena
	movem.l	(sp)+,d0/a0/a2
	rts
	movem.l	d0-d7/a0-a6,-(sp)
	movem.l	(sp)+,d0-d7/a0-a6
	rts

EndShootout							;Shootout over: LockScroll, then the 5 skaters of player slots 1-5
									;(homeshootgoals > awayshootgoals) or 7-$B
									;are set up (setplayer) above or below the view and get assscore
									;(assinsert 7)
	movem.l	d0-d7/a0-a6,-(sp)
	bset	#sf2drec,(sflags2).w
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
	movem.l	d0-d7/a0,-(sp)
	move.w	position(a3),d7
	subq.w	#1,d7					;position 1 is entry 0
	movea.l	#$1D84B4,a0
	btst	#pfgoal,pflags(a3)		;which net?
	beq.w	.3
	movea.l	#$1D84C4,a0
	;position boxes for his end
.3
	add.w	d7,d7					;word per position
	move.w	(a0,d7.w),d0			;X min of the box
	cmp.w	temp3(a3),d0
	blt.w	.4
	move.w	d0,temp3(a3)			;clamp to the left
	;X not left of the box
.4
	move.w	2(a0,d7.w),d0			;X max of the box
	cmp.w	temp3(a3),d0
	bgt.w	.5
	move.w	d0,temp3(a3)			;clamp to the right
	;X inside the box
.5
	move.w	4(a0,d7.w),d0			;Y min of the box
	cmp.w	temp4(a3),d0
	blt.w	.6
	move.w	d0,temp4(a3)			;clamp to the bottom
	;Y not below the box
.6
	move.w	6(a0,d7.w),d0			;Y max of the box
	cmp.w	temp4(a3),d0
	bgt.w	.7
	move.w	d0,temp4(a3)			;clamp to the top
	;exit: restore the registers
.7
	movem.l	(sp)+,d0-d7/a0
	rts
	dc.w	$FFB5,$0000,$0000,$011E,$0000,$004B,$0000,$011E
	dc.w	$FFB5,$0000,$FEE2,$0000,$0000,$004B,$FEE2,$0000

AddArenaAnimSprite					;Add the arena animation sprites; disabled in 96: the rts comes first and
									;the body after it is dead
	rts
	tst.w	(arenaanim).w
	bmi.w	AddArenaAnimSpriteDone
	tst.l	(arenaanim+6).w
	beq.w	AddArenaAnimSpriteDone
	btst	#4,(sflags4).w
	bne.w	AddArenaAnimSpriteDone
	btst	#3,(sflags2).w
	bne.w	AddArenaAnimSpriteDone
	btst	#7,(sflags).w
	bne.w	AddArenaAnimSpriteDone
	movea.l	(arenaanim+6).w,a1
	adda.l	4(a1),a1
	move.w	(Hpos).w,d4
	move.w	(Vpos).w,d5
	move.w	($FFFFD46E).w,d0
	bra.w	AddArenaAnimSpriteFrame
	andi.w	#$F,d2
	cmp.w	#3,d2
	bls.w	.4
	moveq	#3,d2
.4
	bra.w	.5
.loop2
	move.w	d3,d0
	add.w	d2,d0
	bsr.w	AddArenaAnimSpriteFrame
.5
	dbf	d2,.loop2
	rts

AddArenaAnimSpriteFrame	equ	*			;Add the sprite of arena animation frame d0 (d6 < $40) to the sprite list
.spr								;Add the arena animation sprites in view (the ShowCrowdFrame loop);
									;reached only from the dead body above
	ext.w	d0
	beq.w	.3
	cmp.w	#$40,d6
	bge.w	.3
	movem.l	d0-d5,-(sp)
	add.w	d0,d0
	movea.l	a1,a0
	move.w	2(a0,d0.w),d1
	sub.w	(a0,d0.w),d1
	lsr.w	#3,d1
	subq.w	#1,d1
	move.w	d1,-(sp)
	adda.w	(a0,d0.w),a0
	move.w	d4,d0
	addi.w	#$C0,d0
	move.w	d0,d1
	subi.w	#$90,d0
	addi.w	#$80,d1
	move.w	#$170,d2
	sub.w	d5,d2
	move.w	d2,d3
	subi.w	#$80,d2
	addi.w	#$70,d3
	move.w	(sp)+,d4
.loop
	cmp.w	(a0),d2
	bgt.w	.1
	cmp.w	(a0),d3
	blt.w	.1
	cmp.w	6(a0),d0
	bgt.w	.1
	cmp.w	6(a0),d1
	blt.w	.1
	move.w	(a0),d5
	addi.w	#$70,d5
	sub.w	d2,d5
	move.w	d5,(a6)+
	move.b	2(a0),(a6)+
	andi.b	#$F,-$1(a6)
	move.b	d6,(a6)+
	move.b	4(a0),d5
	andi.w	#$F8,d5
	lsl.w	#8,d5
	move.w	d5,-(sp)
	move.w	4(a0),d5
	andi.w	#$7FF,d5
	add.w	($FFFFD46C).w,d5
	or.w	(sp)+,d5
	move.w	d5,(a6)+
	move.w	6(a0),d5
	addi.w	#$70,d5
	sub.w	d0,d5
	move.w	d5,(a6)+
	addq.w	#1,d6
	cmp.w	#$40,d6
	beq.w	.2
.1
	addq.w	#8,a0
	dbf	d4,.loop
.2
	movem.l	(sp)+,d0-d5
AddArenaAnimSpriteDone	equ	*
.3
	rts
	movem.l	d0-d7/a0/a2-a3,-(sp)
	jsr	(FormatPlayerNumInitial).l
	move.w	(a1),d0
	subq.w	#2,d0
	move.w	d0,2(a1)				;2 characters shorter
	addq.w	#2,a1					;length word moved up
	movem.l	(sp)+,d0-d7/a0/a2-a3
	rts
	dc.w	$0006,$202E,$2000
	rts

updatePPTeamTime					;Power play time of the teams, once a second. Called from updatepentime
	btst	#sf2pwrplay,(sflags2).w
	beq.w	.x
	movea.l	#tmstruct,a2
	btst	#sf2pwrtm,(sflags2).w
	beq.w	.0
	movea.l	#AwShots,a2
.0
	addq.w	#1,$38C(a2)
.x
	rts
	movem.l	d1-d7/a0-a6,-(sp)
	move.w	Xvel(a2),d0
	movea.l	#$1D865A,a0
	clr.w	d1
	move.b	(a0,d0.w),d1
	move.w	d1,d0
	movem.l	(sp)+,d1-d7/a0-a6
	rts
	dc.w	$334C,$494B,$4E43,$4B43,$3442,$4A49,$4442,$4A37
	dc.w	$454B,$4738,$4538,$4847,$4846,$5B59

ShortenMsgTimer						;Cap the message timer at 2, unless a second pad is on and a3 is not the
									;puck carrier
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

ManualGoalieMenu					;The "x Manual Goalie" pause menu item.
	movem.l	d0-d7/a0-a6,-(sp)
	tst.w	(OptNOP).w
	beq.w	.2
	bsr.w	SetMenuPadSide
	btst	#1,(sflags).w
	beq.w	.1
	eori.w	#1,(goaliemode2).w
	bra.w	.2
.1
	eori.w	#1,(goaliemode1).w
.2
	btst	#0,(gmode2).w
	bne.w	.3
	btst	#2,(BA_PS_flags).w
	beq.w	.12
.3
	btst	#1,(sflags).w
	bne.w	.8
	cmpi.w	#2,(OptNOP).w
	bne.w	.4
	cmpi.w	#5,(BA_Sktr_SCnum).w
	bgt.w	.12
	bra.w	.5
.4
	cmpi.w	#5,(BA_Sktr_SCnum).w
	ble.w	.12
.5
	move.w	#0,d0
	cmpi.w	#2,(OptNOP).w
	bne.w	.6
	move.w	#6,d0
.6
	tst.w	(goaliemode1).w
	bne.w	.7
	move.w	#5,d0
	cmpi.w	#2,(OptNOP).w
	bne.w	.7
	move.w	#$B,d0
.7
	jsr	(setc1player).l
	bra.w	.12
.8
	cmpi.w	#2,(OptNOP).w
	bne.w	.9
	cmpi.w	#5,(BA_Sktr_SCnum).w
	ble.w	.12
	bra.w	.10
.9
	cmpi.w	#5,(BA_Sktr_SCnum).w
	bgt.w	.12
.10
	move.w	#6,d0
	tst.w	(goaliemode2).w
	bne.w	.11
	move.w	#$B,d0
.11
	jsr	(setc2player).l
.12
	movem.l	(sp)+,d0-d7/a0-a6
	rts

RunArenaAnim						;Run the arena animation (load its frames and tiles, step the frames);
									;disabled in 96 by the leading rts
	rts
	tst.w	(arenaanim).w			;any arena animation?
	bmi.w	.3						;none running
	movem.l	d0-d7/a0-a6,-(sp)
	tst.l	(arenaanim+6).w			;first time?
	bne.w	.1						;already loaded: run it
	move.w	(arenaanim).w,d0
	asl.w	#3,d0					;8 bytes per animation
	movea.l	#$1D8820,a0
	move.l	(a0,d0.w),(arenaanim+2).w	;frame list
	move.l	4(a0,d0.w),(arenaanim+6).w
	movea.l	4(a0,d0.w),a2
	addq.w	#8,a2
	move.w	($FFFFD46C).w,d4
	jsr	(DecompressGraphicsPlain).l
	clr.w	($FFFFD470).w			;start of the list
	bsr.w	NextArenaFrame			;first frame
	bra.w	.2
	;arenaspritelist <> 0
.1
	sub.w	d7,($FFFFD472).w		;count down the frame time
	bpl.w	.2						;frame time not out yet
	addq.w	#1,($FFFFD470).w
	bsr.w	NextArenaFrame			;read the next frame
	;pop the d0-d7/a0-a6 saved above
.2
	movem.l	(sp)+,d0-d7/a0-a6
	;exit (also the end of the code above)
.3
	rts
NextArenaFrame						;Step the arena animation to the next frame of its frame list (wrap at the
									;end marker)
	movea.l	(arenaanim+2).w,a0		;frame list
	move.w	($FFFFD470).w,d0
	add.w	d0,d0					;2 bytes per entry
	move.b	(a0,d0.w),d1			;frame byte
	ext.w	d1
	move.w	d1,($FFFFD46E).w		;frame number
	move.b	1(a0,d0.w),d1
	ext.w	d1
	move.w	d1,($FFFFD472).w		;frame time
	cmpi.w	#$FFFF,($FFFFD46E).w
	bne.w	.1
	clr.w	($FFFFD470).w
	bra.s	NextArenaFrame			;$FF: back to the first frame
	;end of the frame list?
.1
	cmpi.w	#$FFFE,($FFFFD46E).w
	bne.w	.2
	bsr.w	EndArenaAnim			;$FE: end the animation
	;exit (also the end of the code above)
.2
	rts
	dc.w	$001D,$8A50,$0014,$17B6,$001D,$8988,$0014,$17B6
	dc.w	$001D,$8A30,$0014,$17B6,$001D,$89E8,$0014,$17B6
	dc.w	$001D,$89B6,$0014,$17B6,$001D,$8A30,$0014,$17B6
	dc.w	$001D,$8892,$0014,$17B6,$001D,$8860,$0014,$17B6
	dc.w	$010A,$020A,$030A,$040A,$050A,$060A,$070A,$080A
	dc.w	$010A,$020A,$030A,$040A,$050A,$060A,$070A,$080A
	dc.w	$010A,$020A,$030A,$040A,$050A,$060A,$070A,$080A
	dc.w	$FE00,$010A,$020A,$030A,$040A,$050A,$060A,$070A
	dc.w	$080A,$FF00,$010A,$020A,$030A,$040A,$050A,$060A
	dc.w	$070A,$080A,$090A,$0A0A,$0B0A,$0C0A,$0D0A,$0E0A
	dc.w	$0F0A,$100A,$110A,$120A,$130A,$140A,$150A,$160A
	dc.w	$170A,$FE00,$0108,$0208,$033C,$043C,$033C,$043C
	dc.w	$033C,$043C,$033C,$043C,$033C,$043C,$033C,$043C
	dc.w	$033C,$043C,$033C,$043C,$033C,$043C,$033C,$043C
	dc.w	$033C,$043C,$033C,$043C,$033C,$043C,$033C,$043C
	dc.w	$033C,$043C,$033C,$043C,$033C,$043C,$033C,$043C
	dc.w	$033C,$043C,$0208,$0108,$FF00,$0108,$0208,$0308
	dc.w	$0408,$0508,$0608,$0708,$0808,$FF00,$0108,$0208
	dc.w	$0308,$041E,$0508,$0608,$0708,$081E,$0508,$0608
	dc.w	$0708,$081E,$0908,$0A08,$0B08,$0C08,$0D08,$0E08
	dc.w	$FE00,$0F08,$1008,$1108,$121E,$1308,$1408,$1508
	dc.w	$161E,$1308,$1408,$1508,$161E,$1708,$1808,$1908
	dc.w	$1A08,$1B08,$1C08,$FE00,$0108,$0208,$0308,$0408
	dc.w	$0508,$0608,$0708,$0808,$0908,$0A08,$0B08,$0C08
	dc.w	$0D08,$0E08,$0F08,$1008,$1108,$1208,$1308,$1408
	dc.w	$1508,$1608,$FE00,$0108,$0208,$0308,$0408,$0508
	dc.w	$0608,$0708,$0808,$0908,$0A08,$0B08,$0C08,$0D08
	dc.w	$0E08,$0F08,$1008,$1108,$1208,$1308,$1408,$1508
	dc.w	$1608,$1708,$1808,$187F,$0108,$0208,$0308,$0408
	dc.w	$0508,$0608,$0708,$0808,$0908,$0A08,$0B08,$0C08
	dc.w	$0D08,$0E08,$0F08,$1008,$1108,$1208,$1308,$1408
	dc.w	$1508,$1608,$1708,$1808,$1908,$1A08,$1B08,$1C08
	dc.w	$1D08,$1E08,$1F08,$2008,$2108,$2208,$2308,$FE00
	dc.w	$0108,$0208,$0308,$0408,$0508,$0608,$0708,$0808
	dc.w	$0908,$0A08,$0B08,$0C08,$0D08,$0E08,$0F08,$FF00
	dc.w	$010A,$020A,$030A,$040A,$050A,$060A,$070A,$080A
	dc.w	$080A,$080A,$080A,$080A,$080A,$080A,$087F,$087F
	dc.w	$FE00,$08F8,$0006,$C33A,$31FC,$0000,$BFDC,$31FC
	dc.w	$0160,$BFDE,$4E75

StartArenaAnim						;Start arena animation d0; disabled in 96 by the leading rts
	rts
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	d0,(arenaanim).w
	move.l	#$0,(arenaanim+2).w		;RunArenaAnim loads the lists
	move.l	#$0,(arenaanim+6).w
	move.w	#1,($FFFFD46E).w		;first frame
	clr.w	($FFFFD470).w
	st	(faceoffanim).w				;no faceoff animation queued
	movem.l	(sp)+,d0-d7/a0-a6
	rts

SetFaceoffAnim						;Set the faceoff animation d0 (sflags7 bit 0)
	bset	#0,(sflags7).w
	move.w	d0,(faceoffanim).w
	rts

EndArenaAnim						;End the arena animation (none running, sflags7 bit 0 cleared) Code the
	move.w	#$FFFF,(arenaanim).w
	bclr	#0,(sflags7).w
	rts

ClearWinRecords						;Clear bytes 8-$B (wins, games) of the 8 ThreeStars records and write the
									;$80 bytes to save RAM SRTeamRecords
									;(WriteSRAM, MakeSRAMChecksum).
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#ThreeStars,a0
	move.w	#7,d7
.loop
	clr.b	8(a0)
	clr.b	9(a0)
	clr.b	$A(a0)
	clr.b	$B(a0)
	clr.b	(a0)
	clr.b	4(a0)
	clr.b	$C(a0)
	clr.b	$D(a0)
	adda.w	#$10,a0
	dbf	d7,.loop
	move.l	#$ECE,d0
	move.l	#$80,d1
	movea.l	#ThreeStars,a0
	jsr	(WriteSRAM).l
	jsr	(MakeSRAMChecksum).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

PSandSOpassdir						;Penalty shot / shootout: passdir = sopathdir (the end of the skate path
									;NextPathPoint), turned by passdirlist
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

passdirlist							;PSandSOpassdir: passdir for the other net
	dc.b	$00,$00,$00,$07,$00,$06,$00,$05,$00,$04,$00,$03,$00,$02,$00,$01
	dc.b	$00,$08

StartShootoutPath					;Shootout: pick one of the 7 skate paths (ShootoutPaths) at random
									;(sopath) and start it (NextPathPoint).
	movem.l	d0-d7/a0-a6,-(sp)
.loop
	move.w	#7,d0
	jsr	(randomd0).l
	cmp.w	#6,d0
	bgt.s	.loop
	move.w	d0,($FFFFD814).w
	bclr	#3,(sflags7).w
	move.w	#$FFFF,($FFFFD816).w
	clr.w	($FFFFD818).w
	bsr.w	NextPathPoint
	movem.l	(sp)+,d0-d7/a0-a6
	rts

ShootoutPaths						;The 7 shootout skate paths (NextPathPoint)
	dc.l	ShootoutPath1
	dc.l	ShootoutPath2
	dc.l	ShootoutPath3
	dc.l	ShootoutPath4
	dc.l	ShootoutPath5
	dc.l	ShootoutPath6
	dc.l	ShootoutPath7

ShootoutPath1						;ShootoutPaths path: x, y points; $80 in the high byte ends it (low byte:
									;sopathend, then sopathdir)
	dc.w	$10,$E2,$10,$D0,$8020,5

ShootoutPath2						;ShootoutPaths path: x, y points; $80 in the high byte ends it (low byte:
									;sopathend, then sopathdir)
	dc.w	$FFC9,$A0,$FFFF,$C8,$FFE0,$D0,$8020,5

ShootoutPath3						;ShootoutPaths path: x, y points; $80 in the high byte ends it (low byte:
									;sopathend, then sopathdir)
	dc.w	$FFB0,$40,$1A,$BC,$8020,5

ShootoutPath4						;ShootoutPaths path: x, y points; $80 in the high byte ends it (low byte:
									;sopathend, then sopathdir)
	dc.w	$FFCE,$58,$14,$D0,$802C,5

ShootoutPath5						;ShootoutPaths path: x, y points; $80 in the high byte ends it (low byte:
									;sopathend, then sopathdir)
	dc.w	$FFCE,8,$20,$D0,$8028,6

ShootoutPath6						;ShootoutPaths path: x, y points; $80 in the high byte ends it (low byte:
									;sopathend, then sopathdir)
	dc.w	$1C,$F4,8,$E0,$8020,6

ShootoutPath7						;ShootoutPaths path: x, y points; $80 in the high byte ends it (low byte:
									;sopathend, then sopathdir)
	dc.w	$FFE6,$F8,0,$E0,$8020,2

NextPathPoint						;Next point of shootout path sopath: sopathx / sopathy = x (turned by bit
									;0 of $76(a3)) / y; at the end ($80)
									;sflags7 bit 3, sopathend and sopathdir.
	movem.l	d0-d7/a0-a6,-(sp)
	cmpi.b	#$80,($FFFFD818).w
	beq.w	.2
	addq.w	#1,($FFFFD816).w
	move.w	($FFFFD816).w,d0
	asl.w	#2,d0
	movea.l	#ShootoutPaths,a0
	move.w	($FFFFD814).w,d1
	asl.w	#2,d1
	movea.l	(a0,d1.w),a0
	move.w	(a0,d0.w),($FFFFD818).w
	btst	#0,$77(a3)
	beq.w	.1
	neg.w	($FFFFD818).w
.1
	move.w	2(a0,d0.w),($FFFFD81A).w
	cmpi.b	#$80,4(a0,d0.w)
	bne.w	.2
	bset	#3,(sflags7).w
	clr.w	(sopathdir+2).w
	move.b	5(a0,d0.w),(sopathdir+3).w
	move.w	6(a0,d0.w),(sopathdir).w
.2
	movem.l	(sp)+,d0-d7/a0-a6
	rts

SkatePath							;Shootout skate path: d0 / d1 = the point (mirrored for the bottom net);
									;within $A of it ($12 while $28 /
									;$2A(a3) are 0) take the next one (NextPathPoint).
	movem.l	d2-d7/a0-a6,-(sp)
	cmpi.b	#$80,($FFFFD818).w
	beq.w	.9
	move.w	($FFFFD818).w,d0
	move.w	($FFFFD81A).w,d1
	btst	#pfgoal,pflags(a3)
	bne.w	.1
	neg.w	d0
	neg.w	d1
.1
	sub.w	(a3),d0
	bpl.w	.2
	neg.w	d0
.2
	tst.w	Xvel(a3)
	bne.w	.3
	tst.w	Yvel(a3)
	bne.w	.3
	cmp.w	#$12,d0
	ble.w	.4
.3
	cmp.w	#$A,d0
	bgt.w	.8
.4
	sub.w	Ypos(a3),d1
	bpl.w	.5
	neg.w	d1
.5
	tst.w	Xvel(a3)
	bne.w	.6
	tst.w	Yvel(a3)
	bne.w	.6
	cmp.w	#$12,d1
	ble.w	.7
.6
	cmp.w	#$A,d1
	bgt.w	.8
.7
	bsr.w	NextPathPoint
.8
	move.w	($FFFFD818).w,d0
	move.w	($FFFFD81A).w,d1
.9
	movem.l	(sp)+,d2-d7/a0-a6
	rts

ShootoutShootCheck					;Shootout, skater a3 has the puck (gmode2 bit 1): Z set (d0 is restored) =
									;shoot now after 3 (shootoutclock)
									;at the path end, within sopathend of its last point, or with the puck
									;stopped before $F.
	movem.l	d0-d7/a0-a6,-(sp)
	btst	#1,(gmode2).w
	beq.w	.6
	move.w	SCnum(a3),d0
	cmp.w	(puckc).w,d0
	bne.w	.6
	cmpi.w	#3,(shootoutclock).w
	ble.w	.5
	cmpi.b	#$80,($FFFFD818).w
	beq.w	.5
	btst	#3,(sflags7).w
	bne.w	.1
	tst.w	(puckvx).w
	bne.w	.6
	tst.w	(puckvy).w
	bne.w	.6
	cmpi.w	#$F,(shootoutclock).w
	blt.w	.5
	bra.w	.6
.1
	move.w	($FFFFD818).w,d0
	move.w	($FFFFD81A).w,d1
	btst	#pfgoal,pflags(a3)
	bne.w	.2
	neg.w	d0
	neg.w	d1
.2
	sub.w	(a3),d0
	bpl.w	.3
	neg.w	d0
.3
	sub.w	Ypos(a3),d1
	bpl.w	.4
	neg.w	d1
.4
	cmp.w	(sopathdir+2).w,d0
	bgt.w	.6
	cmp.w	(sopathdir+2).w,d1
	bgt.w	.6
.5
	clr.w	d0
	bra.w	.7
.6
	move.w	#1,d0
.7
	movem.l	(sp)+,d0-d7/a0-a6
	rts

UnpackPicture						;Unpack a picture a2: count.w, then 3 bytes per row of 8 pixels to 4 bit
									;pixels + 5 at picturebuf (count
									;first). Called from DrawPictureBox DrawMatchupPicture and
									;PlayerCardScreen.
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#sopathdir+4,a0
	movea.l	#$FFFFDCA2,a1
	move.w	(a2)+,d0
	move.w	d0,(a0)+
	asl.w	#3,d0
	subq.w	#1,d0
.loop
	clr.l	(a0)
	clr.l	(a1)
	move.b	(a2)+,(a1)
	move.b	(a2)+,1(a1)
	move.b	(a2)+,2(a1)
	move.l	#$0,-(sp)
	move.l	(a1),d2
	andi.l	#$E0000000,d2
	lsr.l	#1,d2
	addi.l	#$50000000,d2
	or.l	d2,(sp)
	move.l	(a1),d2
	andi.l	#$1C000000,d2
	lsr.l	#2,d2
	addi.l	#$5000000,d2
	or.l	d2,(sp)
	move.l	(a1),d2
	andi.l	#$3800000,d2
	lsr.l	#3,d2
	addi.l	#$500000,d2
	or.l	d2,(sp)
	move.l	(a1),d2
	andi.l	#$700000,d2
	lsr.l	#4,d2
	addi.l	#$50000,d2
	or.l	d2,(sp)
	move.l	(a1),d2
	andi.l	#$E0000,d2
	lsr.l	#5,d2
	addi.l	#$5000,d2
	or.l	d2,(sp)
	move.l	(a1),d2
	andi.l	#$1C000,d2
	lsr.l	#6,d2
	addi.l	#$500,d2
	or.l	d2,(sp)
	move.l	(a1),d2
	andi.l	#$3800,d2
	lsr.l	#7,d2
	addi.l	#$50,d2
	or.l	d2,(sp)
	move.l	(a1),d2
	andi.l	#$700,d2
	move.w	#8,d5
	lsr.l	d5,d2
	addq.l	#5,d2
	or.l	d2,(sp)
	move.l	(sp)+,(a0)+
	dbf	d0,.loop
	movem.l	(sp)+,d0-d7/a0-a6
	rts
