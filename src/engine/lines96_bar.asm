;	The line energy bar. linebar draws one line, and SetupTeamLine puts that
;	line back on the ice.

linebar	;Draw the energy bar of line d0 for team a2 at printx / printy
	movem.l	d0-d5/a0-a2,-(sp)
	bsr.w	getlinee
	move.w	(printa).w,-(sp)
	move.w	#$8000,(printa).w
	ext.l	d0
	divu.w	#$100,d0
	cmp.w	#$F,d0
	bls.w	.ok
	moveq	#$F,d0
.ok
	moveq	#$F,d1
	sub.w	d0,d1
	clr.w	d0
	movea.l	#EnergyBarMap,a1
	adda.l	4(a1),a1
	movea.w	#$772,a2
	move.w	(a1),d2
	moveq	#1,d3
	move.w	(energybarchars).w,d4
	moveq	#0,d5
	bsr.w	dobitmap
	move.w	(sp)+,(printa).w
	movem.l	(sp)+,d0-d5/a0-a2
	rts

getlinee	;d0 = line number, a2 = team struct. Return d0 = energy level of this line
	movem.l	d1-d5/a0-a3,-(sp)
	lea	$184(a2),a1
	asl.w	#3,d0
	adda.w	d0,a1
	clr.l	d0
	clr.w	d1
	movea.l	#priolist,a0
	move.w	$24(a2),d4
	bra.w	.next
.loop
	clr.w	d5
	move.b	(a0,d4.w),d5
	beq.w	.next
	clr.w	d3
	move.b	(a1,d5.w),d3
	asl.w	#1,d3
	addq.w	#1,d1
	add.w	$32(a2,d3.w),d0
.next
	dbf	d4,.loop
	divu.w	d1,d0
	movem.l	(sp)+,d1-d5/a0-a3
	rts

AvgCline	;Average energy of the current line.
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$70,$80,$42,$80,$42,$41,$74,$05,$30,$6A,$00,$22,$4A,$68
	dc.b	$00,$34,$6F,$00,$00,$10,$42,$43,$16,$28,$00,$67,$D6,$43,$D0,$72
	dc.b	$30,$34,$52,$41,$D0,$FC,$00,$80,$51,$CA,$FF,$E4,$4A,$41,$67,$00
	dc.b	$00,$04,$80,$C1,$4C,$DF,$01,$0E,$4E,$75

ChkShotStat	;Determine if a shot was taken and add it to the stats (crowd, team, shooter and goalie)
	btst	#0,(gmode).w
	bne.w	rtss2
	btst	#4,(gmode).w
	bne.w	rtss2
	bclr	#4,(sflags2).w
	bne.w	.Cwdupdate
	btst	#0,(sflags4).w
	beq.w	rtss2
	bclr	#3,(sflags8).w
	bne.w	.0
	bset	#3,(sflags8).w
	bra.w	rtss2
.0
	movem.l	d0-d1/a1-a3,-(sp)
	move.l	a4,-(sp)
	movea.l	#ScoreSum-6,a4
	adda.w	(ScoreSumbytes).w,a4
	movea.l	#tmstruct,a2
	btst	#7,2(a4)
	beq.w	.pllookup
	adda.w	#$39E,a2
.pllookup
	clr.w	d0
	move.b	3(a4),d0
	movea.l	(sp)+,a4
	movea.w	$22(a2),a2
	move.w	#5,d1
.findplayer
	cmp.b	$67(a2),d0
	beq.w	.foundplayer
	adda.w	#$80,a2
	dbf	d1,.findplayer
	bra.w	.ex
.foundplayer
	move.w	$52(a2),d0
	bra.w	.addShot
.Cwdupdate
	movem.l	d0-d1/a1-a3,-(sp)
	addi.w	#$64,(crowdlevel).w
	addi.w	#$A,(CwdExciteLvl).w
	move.w	(shotplayer).w,d0
.addShot
	asl.w	#7,d0
	movea.w	#(SortCords-M68K_RAM),a3
	adda.w	d0,a3
	bsr.w	loadTeamStruct
	addq.w	#1,(a2)
	btst	#5,(sflags2).w
	beq.w	.8
	btst	#6,(sflags2).w
	bne.w	.7
	btst	#6,$62(a3)
	bne.w	.8
.6
	addq.w	#1,$38E(a2)
	bra.w	.8
.7
	btst	#6,$62(a3)
	bne.s	.6
.8
	move.l	a2,-(sp)
	move.w	(gsp).w,d0
	add.w	d0,d0
	adda.w	d0,a2
	addq.w	#1,$384(a2)
	movea.l	(sp)+,a2
	clr.w	d0
	move.b	$67(a3),d0
	addi.w	#$F8,d0
	addq.b	#1,(a2,d0.w)
	move.w	$26(a1),d0
	bmi.w	.ex
	addi.w	#$F8,d0
	addq.b	#1,(a1,d0.w)
.ex
	movem.l	(sp)+,d0-d1/a1-a3
	rts

loadTeamStruct	;a2 = the team struct of player a3
	movea.w	#(tmstruct-M68K_RAM),a2
	lea	$39E(a2),a1
	btst	#6,$62(a3)
	beq.w	rtss2
	exg	a1,a2
	rts

SetupTeamForIntermission	;Reset the bench (ResetBench), then for each team SetupTeamLine
	bsr.w	ResetBench
	movea.w	#(tmstruct-M68K_RAM),a2
	lea	$39E(a2),a3
	bsr.w	SetupTeamLine
	exg	a2,a3

SetupTeamLine	;The line of team a3 back on the ice (reenergizeteam first)
	bsr.w	reenergizeteam
	clr.w	$16(a3)
	tst.w	(OptLine).w
	bne.w	rtss2
	move.w	$24(a3),d0
	sub.w	$24(a2),d0
	beq.w	rtss2
	move.w	#3,$16(a3)
	tst.w	d0
	bpl.w	rtss2
	move.w	#5,$16(a3)
	rts

RestoreTeamEnergy	;Restore the energy of team a2.
	;Code the listing does not decode: kept as bytes
	dc.b	$70,$36,$0C,$72,$FF,$FD,$00,$6C,$66,$00,$00,$10,$0C,$72,$FF,$FC
	dc.b	$00,$6C,$66,$00,$00,$06,$60,$00,$00,$08,$35,$BC,$10,$00,$00,$34
	dc.b	$55,$40,$6A,$DE,$4E,$75

reenergizeteam	;a2 = team: energy $1000 for every player not out for the game (-4); out for the period (-3) back to the bench
	;(-2)
	moveq	#$36,d0
.0
	cmpi.w	#$FFFC,$6C(a2,d0.w)
	beq.w	.1
	move.w	#$1000,$34(a2,d0.w)
	cmpi.w	#$FFFD,$6C(a2,d0.w)
	bne.w	.1
	move.w	#$FFFE,$6C(a2,d0.w)
.1
	subq.w	#2,d0
	bpl.s	.0
	rts

