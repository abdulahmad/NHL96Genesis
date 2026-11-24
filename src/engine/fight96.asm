;	Fighting, new in 96. checkfight starts a fight when two players hit hard enough. The fighters
;	(assfight, fightinput, chkhit) and the players around them (assfwatch) are run by assignment
;	routines.

checkfight							;Look for the start of a fight between players a2 and a3 (impact $A or
									;more on both, no animation lock, no goalie, no faceoff): SetInst both
									;ways, then startfight for both and the other players watch (assignment
									;$15)
	tst.w	(OptFighting).w
	bne.w	.5
	btst	#5,(GameFlags).w
	bne.w	rtsfight
	tst.w	(gsp).w
	beq.w	rtsfight
	cmpi.w	#$A,impact(a3)
	blt.w	rtsfight
	cmpi.w	#$A,impact(a2)
	blt.w	rtsfight
	btst	#pfalock,pflags(a3)
	bne.w	rtsfight
	btst	#pfalock,pflags(a2)
	bne.w	rtsfight
	btst	#pf2pen,pflags2(a3)
	bne.w	rtsfight
	btst	#pf2pen,pflags2(a2)
	bne.w	rtsfight
	tst.w	position(a3)
	beq.w	rtsfight
	tst.w	position(a2)
	beq.w	rtsfight
	btst	#gmclock,(gmode).w
	bne.w	rtsfight
	btst	#0,(puck_pflags2).w
	bne.w	rtsfight
	cmpi.w	#$10A,Ypos(a3)
	bgt.w	rtsfight
	cmpi.w	#$10A,Ypos(a3)
	bgt.w	rtsfight
	movem.l	d0-d4/a0-a3,-(sp)
	movea.w	#(puckx-M68K_RAM),a0
	move.w	assnum(a0),d0
	cmpi.b	#$1B,asslist(a0,d0.w)
	beq.w	.4
	move.w	(ChkCnt).w,d0
	cmp.w	#$64,d0
	blt.w	.4
	bsr.w	SetInst
	exg	a2,a3
	bsr.w	SetInst
	exg	a2,a3
	btst	#pf2fight,pflags2(a3)
	beq.w	.4
	clr.w	(ChkCnt).w
	moveq	#$1B,d0
	movea.w	#(tmstruct+$130-M68K_RAM),a0
.0
	clr.b	$39E(a0)
	clr.b	(a0)+
	dbf	d0,.0
	addi.w	#$3E8,(Crowdlevel).w
	addi.w	#$23,(CwdExciteLvl).w
	clr.w	(FightSpare).w
	clr.l	(FightMash).w
	clr.l	(FightMash34).w
	bclr	#1,(sflags10).w
	bclr	#2,(sflags10).w
	bclr	#sfspdir,(sflags).w
	bclr	#sfssdir,(sflags).w
	move.w	SCnum(a3),(puckc).w
	move.w	Ypos(a3),d1
	add.w	Ypos(a2),d1
	asr.w	#1,d1
	move.w	d1,(yc1).w
	bset	#sf2drec,(sflags2).w
	bset	#sfslock,(sflags).w
	moveq	#2,d1
	move.w	(a3),d0
	cmp.w	(a2),d0
	blt.w	.1
	eori.w	#7,d1
.1
	move.w	d1,facedir(a3)
	eori.w	#7,d1
	move.w	d1,facedir(a2)
	move.l	a3,-(sp)
	bsr.w	startfight
	exg	a2,a3
	bsr.w	startfight
	movea.w	#(SortCords-M68K_RAM),a3
	move.l	#$15,d0
	moveq	#$B,d1
.2
	btst	#pf2fight,pflags2(a3)
	bne.w	.3
	tst.w	position(a3)			;check if goalie
	beq.w	.3
	btst	#pf2unav,pflags2(a3)
	bne.w	.3
	movem.w	d0,-(sp)
	move.w	assnum(a3),d0
	cmpi.b	#$D,asslist(a3,d0.w)
	movem.w	(sp)+,d0
	beq.w	.3
	jsr	(assinsert).l
.3
	adda.w	#$80,a3
	dbf	d1,.2
	movea.w	#(puckx-M68K_RAM),a3
	bset	#pf2fight,pflags2(a3)
	move.l	#$1A,d0
	jsr	(assinsert).l
	st	(collflag).w
	movea.l	(sp)+,a3
.4
	movem.l	(sp)+,d0-d4/a0-a3
.5
	rts

startfight							;Start the fight for player a3 against a2: AddPenalty2 $2E, setd0player,
									;assignment $14, push a3 back by facing, the fight SPA and PenCntDwn $140
	move.w	SCnum(a2),impactp(a3)
	move.w	#$2E,d0
	jsr	(AddPenalty2).l
	move.w	#$140,(PenCntDwn).w
	clr.w	(FightEngageCount).w
	move.w	SCnum(a3),d0
	jsr	(setd0player).l
	move.l	#$14,d0
	jsr	(assinsert).l
	bclr	#3,attribute(a3)
	move.w	#$FC00,d1
	cmpi.w	#2,facedir(a3)
	beq.w	.0
	bset	#3,attribute(a3)
	neg.w	d1
.0
	move.w	d1,Xvel(a3)
	bset	#2,pflags2(a3)
	bclr	#pf2aip,pflags2(a3)
	bset	#5,pflags2(a3)
	bclr	#pfalock,pflags(a3)
	move.w	#SPAfight,d1
	jmp	SetSPA

SetInst								;Both a3 and a2 need fight rating ($75) 1 or more: then pflags2 bit 0
									;(fighting) on both;
									;Z clear when a3 was already fighting
	cmpi.b	#1,checking(a3)
	blt.w	rtsfight
	cmpi.b	#1,checking(a2)
	blt.w	rtsfight
	clr.w	d1
	move.b	weight(a2),d1
	movea.w	#(tmstruct-M68K_RAM),a0
	btst	#pfteam,pflags(a2)
	beq.w	.tm
	adda.w	#$39E,a0
.tm
	adda.w	d1,a0
	move.b	$130(a0),d1
	asl.b	#1,d1
	neg.b	d1
	addi.b	#$10,d1
	cmp.b	checking(a2),d1
	bset	#pf2fight,pflags2(a2)
	bset	#pf2fight,pflags2(a3)
	bne.w	rtsfight
	rts

FightPenaltyTeammate				;Not called in this game. With penalties on and one frame in four, a
									;teammate of a4 who is a skater and on the ice gets the fighting
									;penalty (AddPenalty2 $2A)
	tst.w	(OptPen).w
	beq.w	rtsfight
	move.w	(HVcount).l,d0
	andi.w	#3,d0
	bne.w	rtsfight
	movea.l	a3,a4
	moveq	#5,d0
	movea.w	#(SortCords-M68K_RAM),a3
	btst	#pfteam,pflags(a4)
	beq.w	.loop
	adda.w	#$300,a3
.loop
	cmpa.w	a3,a4
	beq.w	.1
	tst.w	position(a3)
	ble.w	.1
	btst	#pf2pen,pflags2(a3)
	bne.w	.1
	btst	#pf2unav,pflags2(a3)
	bne.w	.1
	move.w	#$2A,d0
	jsr	(AddPenalty2).l
	movea.l	a4,a3
	rts
.1
	adda.w	#$80,a3
	dbf	d0,.loop
	movea.l	a4,a3

rtsfight							;The shared rts of the fight routines
	rts

assfight							;Assignment $14: the fighter (a3 = player)
	btst	#pfalock,pflags(a3)
	bne.s	rtsfight
	tst.w	(PenCntDwn).w
	bpl.w	.1
	jmp	(donothing).l
.1
	bclr	#pfna,pflags(a3)
	beq.w	.nna
	bclr	#7,(sflags12).w
	clr.w	d0
	move.b	checking(a3),d0
	add.w	d0,d0
	addq.w	#3,d0
	move.w	d0,temp3(a3)			;temp3 = strength
	clr.w	temp2(a3)
	move.w	#$FFFF,temp4(a3)		;temp4 = banner timer
	cmpi.w	#2,facedir(a3)
	bne.w	.nna
	move.w	#$5A,temp4(a3)			;90: one player shows the banner
.nna
	sub.w	d7,temp4(a3)			;Sub frames elapsed from temp4
	bcc.w	.nna2
	bsr.w	banner					;show fighters' names
.nna2
	tst.w	temp3(a3)				;temp3 < 0: fight over for this player
	bmi.s	rtsfight
	;a0 = opponent; scroll lock x = midpoint of both
	move.w	impactp(a3),d0
	asl.w	#scsize,d0				;scsize
	movea.w	#(SortCords-M68K_RAM),a0
	adda.w	d0,a0					;a0 = opponent
	move.w	(a3),d0
	add.w	(a0),d0
	asr.w	#1,d0
	move.w	d0,(xc1).w				;scroll lock between the fighters
	;computer fighter: punch when the opponent is within 20 px (extrapolated by velocity)
	btst	#pfjoycon,pflags(a3)
	bne.w	.j
	bset	#pf2aip,pflags2(a3)
	bne.w	.j
	cmpi.w	#SPAfight,SPA(a3)
	bne.w	.5
	cmpi.w	#$3E8,(glovecords+2).w
	bne.w	.4
	cmpi.w	#$3E8,(glovecords).w
	beq.w	.5
.4
	bsr.w	EngageFight
.5
	btst	#1,(sflags10).w
	bne.w	.19
	tst.w	SPA(a3)
	bne.w	.6
	move.w	#$30E6,d1
	jsr	(SetSPA).l
.6
	move.w	(a3),d0					;computer punches only when in range
	sub.w	(a0),d0
	move.w	Xvel(a3),d1
	asr.w	#8,d1
	add.w	d1,d0
	move.w	Xvel(a0),d1
	asr.w	#8,d1
	sub.w	d1,d0
	cmp.w	#$16,d0
	bgt.w	.j
	cmp.w	#$FFEA,d0
	blt.w	.j
	cmpi.w	#$3E8,(glovecords).w
	beq.w	.j
	cmpi.w	#$3E8,(glovecords+2).w
	beq.w	.j
	move.w	(a3),d1
	sub.w	(a0),d1
	bpl.w	.7
	neg.w	d1
.7
	move.w	(FightSpare).w,d0
	subq.w	#1,d0
	move.w	d0,(FightSpare).w
	bpl.w	.j
	move.w	#1,d0
	jsr	(randomd0).l
	move.w	d0,(FightSpare).w
	;random: grab 1/8, else high or low punch
	moveq	#8,d0
	jsr	(randomd0).l
	cmp.w	#1,d0
	bls.w	.p
	andi.w	#1,d0
.p
	asl.w	#1,d0					;word index into .al
	bra.w	.9
	dc.w	$7008,$4EB9,$0001,$B0A6,$B07C,$0002,$6300,$0006
	dc.w	$0240,$0001,$E340
.9
	lea	.al(pc),a1					;choose punch type
	move.w	(a1,d0.w),d1
	jsr	(SetSPA).l
.j
	bsr.w	chkhit					;check whether this punch connected
	btst	#1,(sflags10).w
	bne.w	.16
	cmpi.w	#SPAfight,SPA(a3)
	beq.w	.jc
	cmpi.w	#SPAfightstance,SPA(a3)
	beq.w	.jc
	btst	#pfjoycon,pflags(a3)
	bne.w	.jc
	move.w	(xc1).w,d0				;target x = xc1 + 10 (-10 when facing 2); Xvel += dx * 32
	addi.w	#$A,d0
	cmpi.w	#2,facedir(a3)
	bne.w	.11
	subi.w	#$14,d0
.11
	sub.w	(a3),d0					;dx to target
	asl.w	#5,d0					;add to Xvel (92 clamped and set it)
	add.w	d0,Xvel(a3)
.jc
	move.w	(yc1).w,d1				;Yvel = (yc1 - Ypos) * 256, clamped +-$1000
	sub.w	Ypos(a3),d1
	asl.w	#8,d1
	cmp.w	#$1000,d1
	blt.w	.13
	move.w	#$1000,d1
.13
	cmp.w	#$F000,d1
	bgt.w	.y2
	move.w	#$F000,d1
.y2
	move.w	d1,Yvel(a3)				;store Yvel
	tst.w	SPA(a3)
	bne.w	.15
	move.w	#$30E6,d1
	jsr	(SetSPA).l
.15
	rts
.16
	bsr.w	.hold
	tst.w	SPA(a3)
	bne.w	.17
	move.w	#$31BC,d1
	jsr	(SetSPA).l
.17
	rts
.al
	dc.w	SPAfgrab,SPAflow,SPAfgrab
.19
	bsr.w	.hold
	moveq	#8,d0
	jsr	(randomd0).l
	andi.w	#3,d0
	asl.w	#1,d0
	lea	.table20(pc),a1
	move.w	(a1,d0.w),d1
	jsr	(SetSPA).l
	bsr.w	chkhit
	rts
.table20
	dc.w	SPAfpunchA,SPAfpunchB,SPAfpunchA,SPAfpunchB
.hold								;Hold the two fighters together: stop a3 and when the fighters are more
									;than $18 pixels apart push them toward each other
	clr.w	Yvel(a3)
	clr.w	Xvel(a3)
	movem.l	d0,-(sp)
	move.w	(a3),d0
	sub.w	(a0),d0
	cmp.w	#$18,d0
	bgt.w	.21
	cmp.w	#$FFE8,d0
	blt.w	.21
.loop
	movem.l	(sp)+,d0
	rts
.21
	asl.w	#5,d0
	cmpi.w	#2,facedir(a3)
	beq.w	.22
	tst.w	d0
	bmi.w	.23
	neg.w	d0
	bra.w	.23
.22
	tst.w	d0
	bpl.w	.23
	neg.w	d0
.23
	move.w	d0,Xvel(a3)
	neg.w	d0
	move.w	d0,Xvel(a0)
	bra.s	.loop
chkhit								;Part of the fight that checks whether the punch of a3 hit the opponent a0
									;(frame change only)
	movem.l	d0/a0-a3,-(sp)
	move.w	frame(a3),d0
	cmp.w	oldframe(a3),d0
	beq.w	.ex
	btst	#1,(sflags10).w
	bne.w	.4
	cmp.w	#$5EA,d0
	beq.w	.dropped
	btst	#pfjoycon,pflags(a0)
	beq.w	.2
	btst	#pfjoycon,pflags(a3)
	beq.w	.2
	cmpi.w	#2,facedir(a0)
	beq.w	.1
	btst	#1,(FightFaceBits).w
	bne.w	.ex
	bra.w	.2
.1
	btst	#0,(FightFaceBits).w
	bne.w	.ex
.2
	cmpi.w	#SPAfgrabhit1,SPA(a0)
	beq.w	.ex
	cmpi.w	#SPAfgrabhit2,SPA(a0)
	beq.w	.ex
	cmpi.w	#SPAfgrabhit3,SPA(a0)
	beq.w	.ex
	cmpi.w	#SPAflowhit1,SPA(a0)
	beq.w	.ex
	cmpi.w	#SPAflowhit2,SPA(a0)
	beq.w	.ex
	cmpi.w	#SPAflowhit3,SPA(a0)
	beq.w	.ex
	move.w	(a3),d0
	sub.w	(a0),d0
	cmp.w	#$16,d0
	bgt.w	.ex
	cmp.w	#$FFEA,d0
	blt.w	.ex
	tst.w	d0
	bpl.w	.3
	neg.w	d0
.3
	cmp.w	#8,d0
	blt.w	.ex
	move.w	Ypos(a3),d0
	sub.w	Ypos(a0),d0
	cmp.w	#8,d0
	bgt.w	.ex
	cmp.w	#$FFF8,d0
	blt.w	.ex
	cmpi.w	#$3E8,(glovecords).w
	beq.w	.ex
	cmpi.w	#$3E8,(glovecords+2).w
	beq.w	.ex
	move.w	frame(a3),d0
	cmp.w	#$5F6,d0
	beq.w	.hithigh
	cmp.w	#$5FA,d0
	beq.w	.hithigh
	cmp.w	#$606,d0
	beq.w	.hitlow
	cmp.w	#$60A,d0
	beq.w	.hitlow
	cmp.w	#$613,d0
	beq.w	.grab
	cmp.w	#$617,d0
	beq.w	.grab
.ex
	movem.l	(sp)+,d0/a0-a3
	rts
.4
	btst	#2,(sflags10).w
	beq.w	.5
	move.w	(FightMasher).w,d0
	cmp.w	SCnum(a3),d0
	bne.w	.5
	move.w	#$3666,d1
	jsr	(SetSPA).l
	move.w	#$369C,d1
	exg	a0,a3
	jsr	(SetSPA).l
	bsr.w	.fall
	move.w	#$B4,(PenCntDwn).w
	bra.w	.19
.5
	cmpi.w	#SPAfpunchAhit1,SPA(a0)
	beq.s	.ex
	cmpi.w	#SPAfpunchAhit2,SPA(a0)
	beq.s	.ex
	cmpi.w	#SPAfpunchAhit3,SPA(a0)
	beq.s	.ex
	cmpi.w	#SPAfpunchBhit1,SPA(a0)
	beq.s	.ex
	cmpi.w	#SPAfpunchBhit2,SPA(a0)
	beq.s	.ex
	cmpi.w	#SPAfpunchBhit3,SPA(a0)
	beq.s	.ex
	move.w	(a3),d0
	sub.w	(a0),d0
	cmp.w	#$1E,d0
	bgt.s	.ex
	cmp.w	#$FFE2,d0
	blt.s	.ex
	move.w	frame(a3),d0
	cmp.w	#$61D,d0
	beq.w	.6
	cmp.w	#$621,d0
	beq.w	.6
	cmp.w	#$62E,d0
	beq.w	.7
	cmp.w	#$632,d0
	beq.w	.7
	bra.w	.ex
.6
	exg	a0,a3
	bsr.w	.cwdgrab
	bset	#pf2aip,pflags2(a3)
	subq.w	#1,temp3(a3)
	bmi.w	.lost
	movem.l	d0/a0,-(sp)
	movea.l	#$BE18,a0
	move.w	#$64,d0
	jsr	(randomd0).l
	andi.w	#3,d0
	add.w	d0,d0
	move.w	(a0,d0.w),d1
	movem.l	(sp)+,d0/a0
	jsr	(SetSPA).l
	move.w	#9,-(sp)
	jsr	(sfx).l
	bra.w	.ex
	dc.w	SPAfpunchAhit1,SPAfpunchAhit2,SPAfpunchAhit3,SPAfpunchAhit1
.7
	exg	a0,a3
	bsr.w	.cwdgrab
	bset	#pf2aip,pflags2(a3)
	subq.w	#1,temp3(a3)
	bmi.w	.lost
	movem.l	d0/a0,-(sp)
	movea.l	#$BE6A,a0
	move.w	#$64,d0
	jsr	(randomd0).l
	andi.w	#3,d0
	add.w	d0,d0
	move.w	(a0,d0.w),d1
	movem.l	(sp)+,d0/a0
	jsr	(SetSPA).l
	move.w	#$A,-(sp)
	jsr	(sfx).l
	bra.w	.ex
	dc.w	SPAfpunchBhit1,SPAfpunchBhit2,SPAfpunchBhit3,SPAfpunchBhit1
.cwdgrab							;Crowd reacts to a grab hit and the held player a3 is shoved 3 pixels
	addi.w	#$50,(Crowdlevel).w
	addi.w	#$A,(CwdExciteLvl).w
	move.w	#3,d0
	cmpi.w	#2,facedir(a3)
	bne.w	.8
	neg.w	d0
.8
	add.w	d0,(a3)
	rts
.dropped
	bclr	#pf2npc,pflags2(a3)
	move.w	(xc1).w,d0
	cmp.w	#$5A,d0
	blt.w	.10
	moveq	#$5A,d0
.10
	cmp.w	#$FFA6,d0
	bgt.w	.11
	moveq	#-$5A,d0
.11
	asr.w	#2,d0
	bne.w	.12
	addq.w	#1,d0
.12
	movem.l	a0,-(sp)
	movea.l	#glovecords,a0
	cmpi.w	#2,facedir(a3)
	beq.w	.13
	movea.l	#glovecords+2,a0
.13
	move.b	d0,(a0)
	move.w	(yc1).w,d0
	asr.w	#2,d0
	move.b	d0,1(a0)
	movem.l	(sp)+,a0
	bra.w	.ex
.grab
	move.w	(a3),d0
	sub.w	(a0),d0
	cmp.w	#$1E,d0
	bgt.w	.ex
	cmp.w	#$FFE2,d0
	blt.w	.ex
	bset	#1,(sflags10).w
	bset	#pfnc,pflags(a3)
	bset	#pfnc,pflags(a0)
	exg	a0,a3
	bset	#pf2aip,pflags2(a3)
	move.w	#$31F6,d1
	jsr	(SetSPA).l
	bra.w	.ex
.hithigh
	exg	a0,a3
	bsr.w	.cwd
	bset	#pf2aip,pflags2(a3)
	subq.w	#1,temp3(a3)
	bmi.w	.lost
	movem.l	d0/a0,-(sp)
	movea.l	#$BF6C,a0
	move.w	#$64,d0
	jsr	(randomd0).l
	andi.w	#3,d0
	add.w	d0,d0
	move.w	(a0,d0.w),d1
	movem.l	(sp)+,d0/a0
	jsr	(SetSPA).l
	move.w	#9,-(sp)
	jsr	(sfx).l
	bra.w	.ex
	dc.w	SPAfgrabhit1,SPAfgrabhit2,SPAfgrabhit3,SPAfgrabhit1
.hitlow
	exg	a0,a3
	bsr.w	.cwd
	bset	#pf2aip,pflags2(a3)
	subq.w	#1,temp3(a3)
	bmi.w	.lost
	movem.l	d0/a0,-(sp)
	movea.l	#$BFBE,a0
	move.w	#$64,d0
	jsr	(randomd0).l
	andi.w	#3,d0
	add.w	d0,d0
	move.w	(a0,d0.w),d1
	movem.l	(sp)+,d0/a0
	jsr	(SetSPA).l
	move.w	#$A,-(sp)
	jsr	(sfx).l
	bra.w	.ex
	dc.w	SPAflowhit1,SPAflowhit2,SPAflowhit3,SPAflowhit1
.cwd								;Crowd reacts to a punch; push the hit player a3 back (the knock back is
									;scaled by 0 in this game)
	addi.w	#$50,(Crowdlevel).w
	addi.w	#$A,(CwdExciteLvl).w
	moveq	#5,d0
	add.w	temp3(a0),d0
	mulu.w	#0,d0
	cmpi.w	#2,facedir(a3)
	bne.w	.17
	neg.w	d0
.17
	add.w	d0,Xvel(a3)
	rts
.fall								;a3 lost the fight: the winner a0 gets the fighting penalty and the crowd
									;cheers
	movem.l	a1,-(sp)
	movea.w	#(PenBuf-2-M68K_RAM),a1
.loop
	addq.w	#2,a1
	cmpi.b	#$26,(a1)
	bne.s	.loop
	move.b	1(a1),d0
	andi.w	#$F,d0
	cmp.w	SCnum(a0),d0
	bne.s	.loop
	move.b	#$28,(a1)
	movem.l	(sp)+,a1
	move.w	#9,-(sp)
	jsr	(sfx).l
	move.w	#$3C,(PenCntDwn).w
	move.w	#$FFFF,temp3(a0)
	addi.w	#$258,(Crowdlevel).w
	addi.w	#$1E,(CwdExciteLvl).w
	rts
.lost
	bsr.s	.fall
	move.w	#$36D2,d1
	jsr	(SetSPA).l
.19
	movea.w	#(tmstruct-M68K_RAM),a2
	move.w	#$B,-(sp)
	btst	#pfteam,pflags(a3)
	bne.w	.20
	lea	$39E(a2),a2
	move.w	#$C,(sp)
.20
	jsr	(song).l
	bra.w	.ex

EngageFight							;A/B/C during SPAfight: stop Xvel, SPAfightstance, count this fighter
									;(FightEngageCount). The second one: SetFightingMajors and GameFlags
									;bit 5; the first: PenCntDwn $140
	movem.l	d0-d3,-(sp)
	clr.w	Xvel(a3)
	addq.w	#1,(FightEngageCount).w
	move.w	#SPAfightstance,d1
	jsr	(SetSPA).l
	cmpi.w	#2,(FightEngageCount).w
	beq.w	.0
	move.w	#$140,(PenCntDwn).w
	bra.w	.1
.0
	bsr.w	SetFightingMajors
	bset	#5,(GameFlags).w
.1
	movem.l	(sp)+,d0-d3
	rts

ClearMessageLine					;Clear the message line
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),0,1,0
	moveq	#$28,d0
	moveq	#5,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts
banner								;Fight banner: close both line change boxes and frame a box with the name
									;and team of both fighters and "vs"
	movem.l	d0-d3/a0-a4,-(sp)
	movea.w	#(tmstruct-M68K_RAM),a2
	jsr	(lcfound2).l
	adda.w	#$39E,a2
	jsr	(lcfound2).l
	jsr	(box).l
	movea.w	#(PenBuf-M68K_RAM),a0
	clr.w	d2						;widest line
.find
	tst.w	(a0)+					;find end of penalty list
	bne.s	.find
	move.b	-$3(a0),d0				;last penalty: the two fighters
	clr.b	d3
	bsr.w	addinfo
	neg.b	d3
	move.b	-$5(a0),d0
	bsr.w	addinfo
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),$F,1
	move.w	d2,d0
	lsr.w	#1,d2
	sub.w	d2,(printx).w
	moveq	#5,d1
	jsr	(Framer).l
	move.w	#2,(printy).w
	tst.b	d3						;stronger fighter on top
	bmi.w	.neg
	move.w	#4,(printy).w
.neg
	move.b	-$3(a0),d0				;print each fighter line (name, team) in turn
	bsr.w	addinfo
	jsr	(print).l
	eori.w	#6,(printy).w
	move.b	-$5(a0),d0
	bsr.w	addinfo
	jsr	(print).l
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),$F,3,'vs'
	movem.l	(sp)+,d0-d3/a0-a4
	rts
addinfo								;d0 = penalty byte (player SCnum in the low nibble): build "<name> <team>"
									;in a1; add fighting to d3; keep the widest line in d2 and centre printx
	movea.w	#(SortCords-M68K_RAM),a1
	andi.w	#$F,d0
	asl.w	#7,d0
	add.b	$75(a1,d0.w),d3			;fighting
	movea.w	#(tmstruct-M68K_RAM),a2
	btst	#pfteam,$62(a1,d0.w)
	beq.w	.1
	adda.w	#$39E,a2
.1
	move.b	$67(a1,d0.w),d0			;player number
	ext.w	d0
	jsr	(getname).l
	movea.w	a1,a3
	jsr	(appendz).l
	String	' '
	movea.l	$1E(a2),a1				;team name
	adda.w	4(a1),a1
	adda.w	(a1),a1
	jsr	(appstring).l
	cmp.w	(a3),d2
	bgt.w	.gt
	move.w	(a3),d2
.gt
	movea.w	a3,a1					;centre printx on the widest line so far
	move.w	(a1),d0
	lsr.w	#1,d0
	neg.w	d0
	addi.w	#$10,d0
	move.w	d0,(printx).w
	rts

assfwatch							;Assignment $15: a player watching the fight. Not decoded in the listing:
	btst	#pfalock,pflags(a3)
	bne.w	rtsfight
	btst	#pfjoycon,pflags(a3)
	bne.w	rtsfight
	;first time: temp1 = 0
	bclr	#pfna,pflags(a3)
	beq.w	.nna
	clr.w	temp1(a3)
.nna
	sub.w	d7,temp1(a3)			;every 60 frames pick a new spot
	bpl.w	.go
	addi.w	#$3C,temp1(a3)			;new spot every second
	;spot = 80 px from the fight (xc1,yc1) along the line to the player, x clamped to +-$7E
	move.w	(a3),d0
	sub.w	(xc1).w,d0
	move.w	Ypos(a3),d1
	sub.w	(yc1).w,d1
	movem.w	d0-d1,-(sp)
	muls.w	d0,d0
	muls.w	d1,d1
	add.l	d1,d0
	jsr	(Sroot).l
	move.w	d0,d2
	bne.w	.d
	moveq	#1,d2
.d
	movem.w	(sp)+,d0-d1				;restore dx,dy
	muls.w	#$50,d0					;80 pixels from the fight
	divs.w	d2,d0
	add.w	(xc1).w,d0
	move.w	#$8C,d3
	cmp.w	d3,d0
	blt.w	.x0
	move.w	d3,d0
.x0
	neg.w	d3						;upper clamp, then lower
	cmp.w	d3,d0
	bgt.w	.x1
	move.w	d3,d0
.x1
	move.w	d0,temp3(a3)			;temp3 = target x
	muls.w	#$50,d1
	divs.w	d2,d1
	add.w	(yc1).w,d1
	move.w	d1,temp4(a3)
.go
	move.w	temp3(a3),d0			;skate to the spot
	move.w	temp4(a3),d1
	lea	rtsfight(pc),a0
	jsr	(skateto).l
	jmp	(check4check).l

fightinput							;Controller processing for fighting
	btst	#2,(sflags10).w
	beq.w	.1
	movem.w	d0,-(sp)
	move.w	(FightMasher).w,d0
	cmp.w	SCnum(a3),d0
	movem.w	(sp)+,d0
	bne.w	.1
	bra.w	.2
.1
	tst.w	temp3(a3)
	bmi.w	rtsfight
	tst.w	(PenCntDwn).w
	bmi.w	rtsfight
	cmpi.w	#SPAfightstance,SPA(a3)
	beq.w	rtsfight
.2
	cmpi.w	#2,facedir(a3)
	beq.w	.3
	bclr	#1,(FightFaceBits).w
	bra.w	.4
.3
	bclr	#0,(FightFaceBits).w
.4
	move.w	d0,d2
	move.w	d1,-(sp)
	cmpi.w	#2,(FightEngageCount).w
	beq.w	.5
	move.w	#$280,(fightidletimer).w
	bne.w	.8
.5
	tst.w	d1
	bne.w	.7
	tst.w	(fightidletimer).w
	beq.w	.6
	subq.w	#1,(fightidletimer).w
	bra.w	.8
.6
	bset	#7,(sflags12).w
	bne.w	.8
	move.w	#8,(PenCntDwn).w
.7
	move.w	#$280,(fightidletimer).w
.8
	btst	#3,d2
	bne.w	.19
	btst	#1,(sflags10).w
	bne.w	.19
	cmpi.w	#SPAfight,SPA(a3)
	beq.w	.13
	cmpi.w	#2,facedir(a3)
	beq.w	.12
	cmp.w	#2,d2
	bne.w	.13
.9
	cmpi.w	#2,facedir(a3)
	beq.w	.10
	bset	#1,(FightFaceBits).w
	bra.w	.11
.10
	bset	#0,(FightFaceBits).w
.11
	bra.w	.13
.12
	cmp.w	#6,d2
	beq.s	.9
.13
	cmpi.w	#SPAfight,SPA(a3)
	bne.w	.18
	movem.l	d0/a0,-(sp)
	movea.l	#SortCords,a0
	cmpi.w	#6,SCnum(a3)
	bge.w	.14
	movea.l	#SortCords+$300,a0
.14
	move.w	#5,d0
.15
	btst	#pf2fight,pflags2(a0)
	bne.w	.16
	adda.w	#$80,a0
	dbf	d0,.15
	bra.w	.17
.16
	move.w	(a3),d0
	sub.w	(a0),d0
	bpl.w	.0
	neg.w	d0
.0
	cmp.w	#$20,d0
	bgt.w	.17
	cmp.w	facedir(a3),d2
	bne.w	.17
	clr.w	d2
.17
	movem.l	(sp)+,d0/a0
.18
	andi.w	#7,d2
	jsr	(playeracc).l
.19
	move.w	(xc1).w,d0
	addi.w	#$C,d0
	cmpi.w	#2,facedir(a3)
	bne.w	.20
	subi.w	#$18,d0
.20
	sub.w	(a3),d0
	move.w	Xvel(a3),d1
	eor.w	d0,d1
	bpl.w	.22
	tst.w	d0
	bpl.w	.21
	neg.w	d0
.21
	muls.w	Xvel(a3),d0
	asr.l	#4,d0
	sub.w	d0,Xvel(a3)
.22
	move.w	(sp)+,d1
	bset	#pf2aip,pflags2(a3)
	bne.w	rtsfight
	move.w	d1,d2
	cmpi.w	#SPAfight,SPA(a3)
	bne.w	.24
	btst	#5,d2
	bne.w	.23
	btst	#6,d2
	bne.w	.23
	btst	#4,d2
	beq.w	.25
.23
	bra.w	EngageFight
.24
	btst	#1,(sflags10).w
	bne.w	.26
	move.w	#SPAfgrab,d1
	btst	#6,d2
	bne.w	.34
	move.w	#SPAflow,d1
	btst	#4,d2
	bne.w	.34
	move.w	#SPAfhigh,d1
	btst	#5,d2
	bne.w	.34
.25
	bclr	#pf2aip,pflags2(a3)
	rts
.26
	btst	#2,(sflags10).w
	bne.w	.27
	move.w	#SPAfpunchA,d1
	btst	#6,d2
	bne.w	.34
	move.w	#SPAfpunchB,d1
	btst	#4,d2
	bne.w	.34
	move.w	#SPAfmash,d1
	btst	#5,d2
	bne.w	.29
	bra.s	.25
.27
	tst.w	(PenCntDwn).w
	bmi.s	.25
	btst	#6,d2
	bne.w	.28
	btst	#4,d2
	bne.w	.28
	bra.s	.25
.28
	move.w	#SPAfpunchfinal,d1
	bra.w	.34
.29
	movem.l	a0,-(sp)
	movea.l	#FightMash,a0
	addq.w	#1,(a0,d4.w)
	cmpi.w	#$11,(a0,d4.w)
	movem.l	(sp)+,a0
	blt.w	.30
	bset	#2,(sflags10).w
	move.w	SCnum(a3),(FightMasher).w
	bra.w	.34
.30
	movem.l	d1/a0/a3,-(sp)
	movea.l	#SortCords,a0
	move.w	#$B,d0
.31
	btst	#pf2fight,pflags2(a0)
	beq.w	.32
	cmpa.l	a0,a3
	bne.w	.33
.32
	adda.w	#$80,a0
	dbf	d0,.31
.33
	movea.l	a0,a3
	move.w	#SPAfmashwin,d1
	bset	#pf2aip,pflags2(a3)
	jsr	(SetSPA).l
	movem.l	(sp)+,d1/a0/a3
.34
	jmp	SetSPA

SetFightingMajors					;Both fighters' roughing minors in PenBuf become fighting majors;
									;PenCntDwn $B40
	movem.l	a1,-(sp)
	movea.w	#(PenBuf-2-M68K_RAM),a1
.0
	addq.w	#2,a1
	cmpi.b	#$2E,(a1)
	bne.s	.0
	move.b	#$26,(a1)
.1
	addq.w	#2,a1
	cmpi.b	#$2E,(a1)
	bne.s	.1
	move.b	#$26,(a1)
	move.w	#$B40,(PenCntDwn).w
	movem.l	(sp)+,a1
	rts
