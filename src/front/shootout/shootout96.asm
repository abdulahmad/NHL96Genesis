;	A penalty shot and a shootout. puckshootout starts the attempt. puckpenshot is
;	the face-off. EndPenaltyShotPlay ends the play and counts the goals.

puckshootout						;asstab entry: start a penalty shot or shootout attempt.
	bclr	#pfna,pflags(a3)
	beq.w	.8
	bclr	#4,(sflags9).w
	bset	#7,(sflags7).w
	clr.l	(padcont).w
	clr.l	(padcont+4).w
	clr.l	(padcont+8).w
	bclr	#7,(gmode2).w
	btst	#0,(gmode2).w
	beq.w	.1
	jsr	(NextShooter).l
	bra.w	.3
.1
	jsr	(StartShootoutPath).l
	move.l	a2,-(sp)
	movea.l	#tmstruct,a2
	tst.w	(BA_Team).w
	beq.w	.2
	movea.l	#AwShots,a2
.2
	addq.w	#1,$39A(a2)
	movea.l	(sp)+,a2
.3
	bclr	#2,(BA_PS_flags).w
	bclr	#4,(BA_PS_flags).w
	bclr	#5,(BA_PS_flags).w
	bclr	#6,(BA_PS_flags).w
	bset	#1,(sflags6).w
	btst	#gmpendel,(gmode).w
	beq.w	.4
	jmp	(Stop4Pen).l
.4
	bclr	#pfna,pflags(a3)
	btst	#0,(gmode2).w
	beq.w	.5
	tst.w	(shootoutteam).w
	bne.w	.7
	tst.w	(homeshootnum).w
	bne.w	.7
	move.w	(HomeTeam).w,(HmTeam).w
	move.w	#2,(SongIndex).w
	jsr	(ChooseSong).l
	move.w	(SongNum).w,-(sp)
	bra.w	.6
.5
	move.w	(HomeTeam).w,(HmTeam).w
	move.w	#2,(SongIndex).w
	jsr	(ChooseSong).l
	move.w	(SongNum).w,-(sp)
.6
	jsr	(song).l
.7
	bset	#gmclock,(gmode).w
	bset	#1,(gmode2).w
	clr.w	(puckvx).w
	clr.w	(puckvy).w
	move.w	#$F,(shootoutclock).w
	bsr.w	ReturnGoalies
	st	temp1(a3)
	st	temp2(a3)
.8
	bset	#2,(BA_PS_flags).w
	movem.w	d1-d2,-(sp)
	btst	#0,(gmode2).w
	beq.w	.9
	jsr	(SelectPenaltyShotSkater).l
	bmi.w	.loop
.9
	movem.w	(sp)+,d1-d2
	bra.w	.10
.loop
	movem.w	(sp)+,d1-d2
	bclr	#2,(BA_PS_flags).w
	move.w	#$1B,d0
	bsr.w	assreplace
	rts
.10
	movem.w	d1-d2,-(sp)
	move.w	(BA_Goalie_SCnum).w,d0
	movea.l	#SortCords,a2
	asl.w	#7,d0
	adda.w	d0,a2
	tst.w	position(a2)
	bne.w	.11
	btst	#pf2unav,pflags2(a2)
	beq.w	.14
.11
	move.w	(BA_Goalie_SCnum).w,d0
	move.w	#6,d2
.loop2
	subq.w	#1,d2
	bmi.s	.loop
	subq.w	#1,d0
	bpl.w	.12
	move.w	#5,d0
	bra.w	.13
.12
	cmp.w	#5,d0
	bne.w	.13
	move.w	#$B,d0
.13
	movea.l	#SortCords,a2
	move.w	d0,d1
	asl.w	#7,d1
	adda.w	d1,a2
	tst.w	position(a2)
	bne.s	.loop2
	btst	#pf2unav,pflags2(a2)
	bne.s	.loop2
	move.w	d0,(BA_Goalie_SCnum).w
.14
	movem.w	(sp)+,d1-d2
	movea.w	#(tmstruct-M68K_RAM),a2
	move.w	#$1F,d0
	bra.w	assreplace

SelectPenaltyShotSkater				;The best rated free skater of the shooting team.
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#tmstruct,a0
	tst.w	(BA_Team).w
	beq.w	.1
	movea.l	#AwShots,a0
.1
	move.w	#0,d1
	move.w	#$FFFF,d6
	move.w	#$FFFF,d5
	move.w	tmteam(a0),d7
	jsr	(GetPlayerCountD7).l
	subq.w	#1,d0
	move.w	d0,(puckanimchars).w
.loop
	tst.w	(puckanimchars).w
	bmi.w	.5
	movem.l	d0-d1/a1,-(sp)
	move.w	tmteam(a0),d7
	move.w	d1,d0
	jsr	(GetRosterName).l
	movea.l	a1,a2
	movem.l	(sp)+,d0-d1/a1
	adda.w	(a2),a2
	move.w	d1,d7
	asl.w	#1,d7
	move.b	attribute(a2),d0
	andi.w	#$F0,d0
	beq.w	.4
	btst	#0,(gmode2).w
	bne.w	.6
	cmpi.w	#$FFFE,$6C(a0,d7.w)
	beq.w	.2
	cmpi.w	#$FFFF,$6C(a0,d7.w)
	bne.w	.4
.2
	clr.w	d3
	clr.w	d0
	move.b	1(a2),d0
	andi.w	#$F,d0
	add.w	d0,d3
	move.b	2(a2),d0
	andi.w	#$F,d0
	add.w	d0,d3
	move.b	2(a2),d0
	andi.w	#$F0,d0
	lsr.w	#4,d0
	add.w	d0,d3
	move.b	3(a2),d0
	andi.w	#$F,d0
	add.w	d0,d3
	move.b	3(a2),d0
	andi.w	#$F0,d0
	lsr.w	#4,d0
	add.w	d0,d3
	move.b	5(a2),d0
	andi.w	#$F,d0
	add.w	d0,d3
	move.b	5(a2),d0
	andi.w	#$F0,d0
	lsr.w	#4,d0
	add.w	d0,d3
	move.b	frame(a2),d0
	andi.w	#$F0,d0
	lsr.w	#4,d0
	add.w	d0,d3
	move.b	7(a2),d0
	andi.w	#$F0,d0
	lsr.w	#4,d0
	add.w	d0,d3
	cmp.w	(BA_Skater_Offset).w,d1
	bne.w	.3
	move.w	#$7FFF,d3
.3
	cmp.w	d6,d3
	blt.w	.4
	move.w	d3,d6
	move.w	d1,d5
	bra.w	.4
.4
	addq.w	#1,d1
	subq.w	#1,(puckanimchars).w
	bra.w	.loop
.5
	tst.w	d5
	bmi.w	.8
	move.w	d5,(BA_Skater_Offset).w
.6
	move.w	#0,(BA_Sktr_SCnum).w
	tst.w	(BA_Team).w
	beq.w	.7
	move.w	#6,(BA_Sktr_SCnum).w
.7
	move.w	(BA_Sktr_SCnum).w,d0
	asl.w	#7,d0
	movea.l	#SortCords,a3
	adda.w	d0,a3
	move.w	(BA_Skater_Offset).w,d3
	bra.w	.9
.8
	move.w	#$FFFF,d0
	bra.w	.10
.9
	move.w	#1,d0
.10
	movem.l	(sp)+,d0-d7/a0-a6
	rts

puckpenshot							;asstab entry: the penalty shot / shootout face-off.
	bclr	#pfna,pflags(a3)
	beq.w	.19
	movem.l	d0-d7/a0-a6,-(sp)
	bsr.w	forceblack
.loop
	btst	#dfok,(disflags).w
	bne.s	.loop
	cmpi.w	#$258,(Crowdlevel).w
	bls.w	.1
	move.w	#$258,(Crowdlevel).w
	addi.w	#$14,(CwdExciteLvl).w
.1
	move.w	(ExtraChars).w,d4
	movea.l	#$97E7A,a2
	jsr	(DecompressGraphicsPlain).l
	bset	#dfclock,(disflags).w
	bclr	#sfpz,(sflags).w
	bclr	#0,(sflags3).w
	move.w	#$3E8,(glovecords+2).w
	move.w	#$3E8,(glovecords).w
	clr.b	(lty+2).w
	st	(RefCnt).w
	bclr	#1,(sflags2).w
	st	(passplayer).w
	bsr.w	ClrHor
	clr.w	(Vpos).w
	clr.w	(Hpos).w
	move.w	#0,(puckx).w
	move.w	#0,(pucky).w
	clr.w	(puckz).w
	clr.w	(puckvx).w
	clr.w	(puckvy).w
	clr.w	(puckvz).w
	st	(puckc).w
	movea.w	#(SortCords+(12*SCstruct)-M68K_RAM),a0	;goal net SCstruct
	clr.w	Xvel(a0)
	clr.w	Yvel(a0)
	clr.w	(a0)
	move.w	#$122,Ypos(a0)
	adda.w	#SCstruct,a0
	clr.w	Xvel(a0)
	clr.w	Yvel(a0)
	clr.w	(a0)
	move.w	#$FEDE,Ypos(a0)
	movea.w	#(SortCords+((puckscnum+1)*SCstruct)-M68K_RAM),a0	;puck shadow SCstruct
	move.w	#$299,frame(a0)
	clr.w	SPA(a0)
	clr.w	attribute(a0)
	clr.w	(puckx+4).w
	bclr	#sfslock,(sflags).w
	moveq	#$64,d4
.loop2
	bsr.w	checkwindow
	dbf	d4,.loop2
	move.w	#$3C,(yleader).w
	bsr.w	ResetBench
	movea.w	#(tmstruct-M68K_RAM),a2
	bsr.w	setpersonel
	bsr.w	SetupPenaltyShot
	adda.w	#$39E,a2
	bsr.w	setpersonel
	bsr.w	SetupPenaltyShot
	jsr	(resetplstuff).l
	move.l	a3,-(sp)
	movea.l	#SortCords+(11*SCstruct),a3	;away goalie SCstruct
	move.w	#$B,d2					;11 = # of player SCstructs
.loop3
	cmp.w	(BA_Sktr_SCnum).w,d2
	beq.w	.2
	cmp.w	(BA_Goalie_SCnum).w,d2
	beq.w	.7
	move.w	#$FF10,(a3)
	clr.w	Ypos(a3)
	clr.w	frame(a3)
	move.w	#$20,d0
	bsr.w	assinsert
	bra.w	.13
.2
	tst.w	position(a3)
	bpl.w	.4
	bclr	#pf2unav,pflags2(a3)
	beq.w	.4
	movem.l	d0-d7/a0-a6,-(sp)
	clr.w	d3
	move.b	weight(a3),d3
	jsr	(setplayer).l
	movem.l	(sp)+,d0-d7/a0-a6
	tst.w	position(a3)
	beq.w	.3
	bpl.w	.4
.3
	nop
.4
	move.w	(puckx).w,d0
	subi.w	#0,d0
	move.w	d0,(a3)
	move.w	(pucky).w,d0
	btst	#pfgoal,pflags(a3)
	bne.w	.5
	addi.w	#$10,d0
	move.w	#4,facedir(a3)
	bra.w	.6
.5
	addi.w	#$FFF0,d0
	move.w	#0,facedir(a3)
.6
	move.w	d0,Ypos(a3)
	clr.w	Xvel(a3)
	clr.w	Yvel(a3)
	clr.w	Zvel(a3)
	move.w	#$11,d0
	bsr.w	assinsert
	bra.w	.13
.7
	btst	#0,(gmode2).w
	beq.w	.8
	move.b	($FFFFD453).w,weight(a3)
	tst.w	(shootoutteam).w
	beq.w	.9
	move.b	($FFFFD445).w,weight(a3)
	bra.w	.9
.8
	tst.w	position(a3)
	bpl.w	.11
	bclr	#pf2unav,pflags2(a3)
	beq.w	.11
.9
	movem.l	d0-d7/a0-a6,-(sp)
	clr.w	d3
	move.b	weight(a3),d3
	jsr	(setplayer).l
	movem.l	(sp)+,d0-d7/a0-a6
	tst.w	position(a3)
	bne.w	.10
	bpl.w	.11
.10
	nop
.11
	bclr	#pf2unav,pflags2(a3)
	move.w	#0,d0
	move.w	#$E5,d1
	btst	#pfgoal,pflags(a3)
	bne.w	.12
	move.w	#$FF1B,d1
.12
	move.w	d0,(a3)
	move.w	d1,Ypos(a3)
	clr.w	Xvel(a3)
	clr.w	Yvel(a3)
	clr.w	Zpos(a3)
	sub.w	(puckx).w,d0
	sub.w	(pucky).w,d1
	neg.w	d0
	neg.w	d1
	bsr.w	vtoa
	move.w	d0,facedir(a3)
	bclr	#pf2unav,pflags2(a3)
	bclr	#pfalock,pflags(a3)
	move.w	#SPAglide,d1
	bsr.w	SetSPA
.13
	suba.l	#SCstruct,a3
	dbf	d2,.loop3
	jsr	(SprSort).l
	movea.l	(sp)+,a3
	bsr.w	AssignPads
	move.w	(BA_Goalie_SCnum).w,d0
	asl.w	#7,d0
	movea.w	#(SortCords-M68K_RAM),a3
	adda.w	d0,a3
	move.w	#0,(a3)
	move.w	#$FF06,Ypos(a3)
	btst	#pfgoal,pflags(a3)
	bne.w	.14
	move.w	#$FA,Ypos(a3)
.14
	move.w	(BA_Goalie_SCnum).w,d0
	move.w	#1,d1
	btst	#pfteam,pflags(a3)
	beq.w	.15
	move.w	#2,d1
.15
	cmp.w	(cont1team).w,d1
	bne.w	.16
	jsr	(setc1player).l
	bra.w	.17
.16
	cmp.w	(cont2team).w,d1
	bne.w	.17
	jsr	(setc2player).l
.17
	move.w	#$E,d0
	bsr.w	assreplace
	bset	#7,(BA_PS_flags).w
	bset	#sf2drec,(sflags2).w
	move.w	#$190,(msgtimer).w
	tst.w	(cont1team).w
	bne.w	.18
	tst.w	(cont2team).w
	bne.w	.18
	move.w	#$64,(msgtimer).w
.18
	move.w	#$18,(palcount).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts
.19
	bset	#2,(gmode2).w
	move.w	#$18,d0
	bsr.w	assreplace
	clr.w	Xvel(a3)
	clr.w	Yvel(a3)
	rts

PenShotTable						;Penalty shot data
	dc.b	0,1,2,3,4,5,6,0,0,1,5,3,4,2,0,0
	dc.b	0,3,5,1,4,0,0,0,0,0
	dc.w	$FF06,$FFDD,$FFCE,$0023,$FFCE,$FFCE,$FFF6,$0000,$FFF1,$0032,$FFF6,$0000,$FFC4

UpdatePenaltyShotEnd				;The shot ends (BA_PS_flags bit 4) when the goalie has the puck, the loose
									;puck timer or the clock runs out. Runs on into EndPenaltyShotPlay
	movem.w	d0,-(sp)
	move.w	(puckc).w,d0
	cmp.w	(BA_Goalie_SCnum).w,d0
	movem.w	(sp)+,d0
	beq.w	.3
	btst	#5,(BA_PS_flags).w
	beq.w	.4
	btst	#5,(gmode2).w
	bne.w	.1
	tst.w	(puckc).w
	bpl.w	.2
	bset	#5,(gmode2).w
.1
	tst.w	(puckc).w
	bpl.w	.3
.2
	tst.w	(passmodetimer).w
	bmi.w	.3
	subq.w	#1,(passmodetimer).w
	bra.w	.4
.3
	bset	#4,(BA_PS_flags).w
.4
	tst.w	(shootoutclock).w
	bne.w	.5
	bset	#4,(BA_PS_flags).w
.5
	btst	#4,(BA_PS_flags).w
	bne.w	.6
	rts
.6
	btst	#6,(BA_PS_flags).w
	bne.w	EndPenaltyShotPlayExit
	bset	#6,(BA_PS_flags).w
	move.w	#$A,d0
	jsr	(AddPenalty2).l

EndPenaltyShotPlay					;LockScroll, end the penalty shot play (the BA flags), the shooter newpnum
									;back, then CountShootoutGoals
	jsr	(LockScroll).l
	btst	#0,(gmode2).w
	bne.w	.stopplay
	move.w	#$A,(replaydelay).w
	bset	#sf2drec,(sflags2).w
.stopplay
	bset	#gmclock,(gmode).w
	bclr	#2,(gmode2).w
	bclr	#2,(BA_PS_flags).w
	bclr	#3,(BA_PS_flags).w
	bclr	#5,(BA_PS_flags).w
	bclr	#4,(BA_PS_flags).w
	bclr	#6,(BA_PS_flags).w
	movem.l	d0/a0,-(sp)
	movea.l	#SortCords,a0
	move.w	(BA_Sktr_SCnum).w,d0
	asl.w	#7,d0
	move.b	(savednewpnum).w,$61(a0,d0.w)
	movem.l	(sp)+,d0/a0
	jsr	(CountShootoutGoals).l
EndPenaltyShotPlayExit	equ	*			;Shared return of EndPenaltyShotPlay
	rts

