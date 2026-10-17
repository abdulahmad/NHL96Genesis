;	The player frame update and the pad switches. updateplayers runs the collision,
;	the animation and the assignment for every player. chgplayer, setcplayer and
;	setpads choose which pad controls which skater.

updateplayers	;This routine calls all collision/animation/assignment code for all players. d7 = elapsed frames
	btst	#7,(sflags).w
	bne.w	.16
	ori.l	#$F,(PadControlBits).w
	cmpi.w	#5,(puckz).w
	bgt.w	.14
.13
	clr.w	(PuckZCntr).w
	bra.w	.16
.14
	move.w	(TmpPuckZ).w,d0
	cmp.w	(puckz).w,d0
	beq.w	.15
	move.w	(puckz).w,(TmpPuckZ).w
	bra.s	.13
.15
	addq.w	#1,(PuckZCntr).w
	cmpi.w	#$10,(PuckZCntr).w
	blt.w	.16
	clr.w	(PuckZCntr).w
	subq.w	#1,(puckz).w
.16
	bclr	#6,(sflags7).w
	move.w	(CurCrowdMeter).w,d0
	cmp.w	(CrowdRecord).w,d0
	blt.w	.17
	bset	#6,(sflags7).w
.17
	jsr	(SetSflags8Bit1).l
	tst.w	(puckc).w
	bmi.w	.18
	bclr	#7,(sflags8).w
	bclr	#1,(sflags6).w
	move.w	(puckc).w,d0
	asl.w	#7,d0
	movea.l	#SortCords,a3
	adda.w	d0,a3
	btst	#1,pflags3(a3)
	beq.w	.18
	bclr	#4,(gmode2).w
.18
	movea.w	#(SortCords-M68K_RAM),a3
.19
	move.l	(a3),OldXpos(a3)	;Xpos, oldXpos
	move.l	Ypos(a3),OldYpos(a3)	;Ypos, oldYpos
	move.l	Zpos(a3),OldZpos(a3)	;Zpos, oldZpos
	btst	#5,pflags3(a3)	;falling down?
	beq.w	.20	;branch if not
	clr.w	Xvel(a3)	;clear Xvel
	clr.w	Yvel(a3)	;clear Yvel
	tst.w	SPAnum(a3)	;check animation index
	bne.w	.0	;branch if index not 0
	jsr	(PlaceBoardFall).l
	bra.w	.20
.0
	cmpi.w	#SPAboardmidl,SPA(a3)
	beq.w	.9
	cmpi.w	#SPAboardmidr,SPA(a3)
	beq.w	.8
	cmpi.w	#SPAboardleft,SPA(a3)
	beq.w	.7
	cmpi.w	#SPAboardtop,SPA(a3)
	beq.w	.1
	cmpi.w	#SPAboardbot,SPA(a3)
	beq.w	.4
	bra.w	.20
.1
	move.w	#$124,d0
	cmpi.w	#$56,(FallXPos).w
	bgt.w	.2
	cmpi.w	#$FFAA,(FallXPos).w
	bgt.w	.3
.2
	move.w	#$116,d0
.3
	move.w	d0,Ypos(a3)
	bra.w	.20
.4
	move.w	#$FEDC,d0
	cmpi.w	#$56,(FallXPos).w
	bgt.w	.5
	cmpi.w	#$FFAA,(FallXPos).w
	bgt.w	.6
.5
	move.w	#$FEEA,d0
.6
	move.w	d0,Ypos(a3)
	bra.w	.20
.7
	move.w	#$90,(a3)
	btst	#3,attribute(a3)
	beq.w	.20
	move.w	#$FF70,(a3)
	bra.w	.20
	dc.b	$36,$BC,$00,$96,$08,$2B,$00,$03,$00,$04,$67,$00,$00,$2E,$36,$BC
	dc.b	$FF,$6A,$60,$00,$00,$26
.8
	move.w	#$FF70,(a3)
	btst	#3,attribute(a3)
	beq.w	.20
	move.w	#$90,(a3)
	bra.w	.20
.9
	move.w	#$FF6A,(a3)
	btst	#3,attribute(a3)
	beq.w	*+4
.20
	tst.w	position(a3)
	bmi.w	.32
	move.w	SCnum(a3),d0
	cmp.w	(puckc).w,d0
	beq.w	.top2
	bclr	#1,pflags3(a3)
.top2
	bsr.w	updateanim
	sub.b	d7,nopuck(a3)	;no puck control
	bpl.w	.np
	clr.b	nopuck(a3)	;clear upper byte of nopuck
.np
	sub.b	d7,$5F(a3)	;subtract # of frames from nopuck+1
	bpl.w	.np2
	clr.b	$5F(a3)	;clear lower byte of nopuck
.np2
	btst	#6,(sflags3).w	;check if penalty timer is up
	beq.w	.21
	clr.w	d0
	move.b	$67(a3),d0	;player offset on roster
	bmi.w	.21
	add.w	d0,d0
	addi.w	#$14C,d0
	jsr	(loadTeamStruct).l
	addq.w	#1,(a2,d0.w)	;add 1 to TOI for player
.21
	cmpi.w	#SPA17E4,SPA(a3)
	blt.w	.22
	cmpi.w	#SPA1F76,SPA(a3)
	ble.w	.done
.22
	move.w	(skillspeed).w,d4
	tst.w	(PalMode).w
	beq.w	.23
	move.w	(skillspeedpal).w,d4
.23
	cmpi.w	#2,(OptSkill).w
	bne.w	.24
	btst	#3,pflags(a3)
	beq.w	.24
	addq.w	#2,d4
.24
	mulu.w	d7,d4
	cmpi.w	#SPA2B88,SPA(a3)
	beq.w	.done
	tst.w	Zpos(a3)
	bne.w	.29
	moveq	#6,d2
	btst	#0,pflags(a3)
	beq.w	.25
	moveq	#9,d2
.25
	move.w	Xvel(a3),d0
	beq.w	.27
	asr.w	d2,d0
	bne.w	.26
	moveq	#1,d0
.26
	sub.w	d0,Xvel(a3)
.27
	move.w	Yvel(a3),d0
	beq.w	.29
	asr.w	d2,d0
	bne.w	.28
	moveq	#1,d0
.28
	sub.w	d0,Yvel(a3)
.29
	move.w	Xvel(a3),d0
	beq.w	.30
	muls.w	d4,d0
	add.l	d0,(a3)
.30
	move.w	Yvel(a3),d0
	beq.w	.31
	muls.w	d4,d0
	add.l	d0,Ypos(a3)
.31
	tst.w	Zpos(a3)
	bmi.w	.done
	bne.w	.10
	tst.w	Zvel(a3)
	beq.w	.done
.10
	asl.w	#1,d4
	sub.w	d4,Zvel(a3)
	asl.w	#1,d4
	sub.w	d4,Zvel(a3)
	lsr.w	#2,d4
	move.w	Zvel(a3),d0
	muls.w	d4,d0
	add.l	d0,Zpos(a3)
	bpl.w	.done
	clr.l	Zpos(a3)
	neg.w	Zvel(a3)
	asr	Zvel(a3)
	moveq	#5,d0
	sub.b	Zvel(a3),d0
	bpl.w	.11
	clr.w	d0
.11
	cmp.w	#3,d0
	bhi.w	.done
	clr.w	d0
	addi.w	#$2C,d0
	move.w	d0,-(sp)
	jsr	(sfx).l
.done
	move.w	SCnum(a3),d6	;SCnum
	cmp.w	(puckc).w,d6	;check if puck carrier
	bne.w	.tp
	btst	#0,pflags2(a3)
	bne.w	.tp
	btst	#7,(sflags).w
	bne.w	.tp	;not puck carrier
	moveq	#-2,d4
	bsr.w	setpads
.tp
	btst	#0,(sflags2).w	;sf2faceoff- check for faceoff
	bne.w	.tp2	;branch if faceoff
	tst.w	(holdreset).w
	beq.w	.tp2
	subq.w	#1,(holdreset).w
	beq.w	.12
	bpl.w	.tp2
.12
	clr.w	(holdreset).w
	move.w	#$F0F,(bholdtimer).w
	move.w	#$F0F,(bholdtimer34).w
.tp2
	jsr	(updatepadinput).l
.32
	adda.w	#$80,a3	;SCstruct size
	cmpi.w	#$F,SCnum-SCstruct(a3)	;compare Sortobjs-1 to SCnum-SCstruct
	blt.w	.19	;loop for all Sort objects
	rts

updateanim	;Frame switch control on struct a3. Called from updateplayers
	tst.w	SPA(a3)	;test SPA
	bne.w	.ia	;branch if not 0
	bclr	#5,pflags(a3)	;clear anim lock
	bclr	#1,pflags2(a3)	;clear anim in progress
	rts
.ia
	movea.l	#SPAlist,a0	;animation data tables
	adda.w	SPA(a3),a0	;add SPA to a0 address
	move.w	$10(a0),d1
	move.w	facedir(a3),d0
	btst	#7,(sflags).w
	beq.w	.2
	cmpi.w	#$C,SCnum(a3)
	bge.w	.2
	subq.w	#2,d0
	andi.w	#7,d0
.2
	btst	#3,attribute(a3)	;x flip flag
	beq.w	.nox	;branch if no flip
	neg.w	d0	;negate d0
	addq.w	#8,d0	;add 8 to d0 for flipping
	andi.w	#7,d0	;pass first 3 bits
.nox
	asl.w	#1,d0	;mult by 2
	adda.w	(a0,d0.w),a0	;add the direction offset: a0 = this direction's frame,time pairs
	move.w	SPAnum(a3),d0	;SPANum into d0 (index into animation)
	move.w	(a0,d0.w),d2	;the new SPF frame of this animation
	tst.w	SPAcnt(a3)	;check if SPAcnt is 0 (time for a new frame)
	bmi.w	.1	;branch if so (SPAcnt is negative)
	sub.w	d7,SPAcnt(a3)	;sub frames elasped from SPAcnt
	bpl.w	.cframe	;branch if SPAcnt is positive
	btst	#0,(gmode).w
	beq.w	.3
	cmpi.w	#SPA3300,SPA(a3)
	bne.w	.3
	cmpi.w	#8,SPAnum(a3)
	bne.w	.3
	move.w	#$2F,-(sp)
	jsr	(sfx).l
.3
	btst	#4,(sflags9).w
	beq.w	.4
	cmpi.w	#SPA0AA2,SPA(a3)
	bne.w	.4
	cmpi.w	#$10,SPAnum(a3)
	bne.w	.4
	move.w	#$30,-(sp)
	jsr	(sfx).l
.4
	addq.w	#4,SPAnum(a3)	;add 4 to SPAnum (set for next index)
	addq.w	#4,d0	;add 4 to d0 (currently holds current index)
	tst.w	-2(a0,d0.w)	;the frame time for the previous frame
	bpl.w	.1	;branch if positive (not the end of the animation)
	cmpi.w	#SPA037A,SPA(a3)
	bne.w	.5
	bset	#1,(sflags12).w
.5
	clr.w	d0	;loop from the start
	clr.w	SPAnum(a3)
	bclr	#5,pflags(a3)	;clear animation lock
	bclr	#1,pflags2(a3)
	bclr	#5,pflags3(a3)
	btst	#0,d1
	bne.w	.1
	clr.w	SPA(a3)	;clear SPA
.1
	move.w	2(a0,d0.w),d0	;move frame time for animation frame into d0
	bpl.w	.0	;branch if positive
	neg.w	d0	;make d0 positive (this is the case if final frame)
.0
	move.w	d0,SPAcnt(a3)	;move d0 into SPAcnt
.cframe
	sub.b	d7,$66(a3)	;sub frames elapsed from glitch - limit minimum time between frame switches
	bpl.w	.rtss	;branch if glitch is positive still
	clr.b	$66(a3)	;clear glitch
	cmp.w	frame(a3),d2	;compare frame to d2
	beq.w	.rtss	;branch if equal
	move.w	d2,frame(a3)	;move d2 into frame
	move.b	#4,$66(a3)	;move 4 into glitch - /60 sec min frame switch time
.rtss
	rts

LockScroll	;xc1 / yc1 = Hpos / Vpos, sflags bit 6
	move.w	(Vpos).w,(yc1).w
	move.w	(Hpos).w,(xc1).w
	bset	#6,(sflags).w
	rts

checkwindow	;Scroll the window one step toward xc1 / yc1 (sflags bit 6) or the puck carrier
	move.w	(yc1).w,d2
	move.w	(xc1).w,d3
	btst	#6,(sflags).w
	bne.w	.dd
	movea.w	#(puckx-M68K_RAM),a3
	move.w	(puckc).w,d0
	bmi.w	.ok
	asl.w	#7,d0
	movea.w	#(SortCords-M68K_RAM),a3
	adda.w	d0,a3
	move.w	d7,d0
	add.w	d0,d0
	btst	#7,pflags(a3)
	beq.w	.gd
	add.w	d0,(yleader).w
	cmpi.w	#$32,(yleader).w
	blt.w	.ok
	move.w	#$32,(yleader).w
	bra.w	.ok
.gd
	sub.w	d0,(yleader).w
	cmpi.w	#$FFCE,(yleader).w
	bgt.w	.ok
	move.w	#$FFCE,(yleader).w
.ok
	move.w	Yvel(a3),d2
	asr.w	#7,d2
	add.w	Ypos(a3),d2
	add.w	(yleader).w,d2
	move.w	(a3),d3
	move.w	d2,(yc1).w
	move.w	d3,(xc1).w
.dd
	move.w	d2,d0
	sub.w	(Vpos).w,d0
	cmp.w	#$FFF6,d0
	bge.w	.3
	move.w	d2,d1
	subi.w	#$FFF6,d1
	cmp.w	#$FF18,d1
	bgt.w	.4
	move.w	#$FF18,d1
	bra.w	.4
.3
	cmp.w	#$A,d0
	ble.w	.2x
	move.w	d2,d1
	subi.w	#$A,d1
	cmp.w	#$F8,d1
	blt.w	.4
	move.w	#$F8,d1
.4
	sub.w	(Vpos).w,d1
	beq.w	.2x
	asr.w	#4,d1
	bne.w	.9
	addq.w	#1,d1
.9
	add.w	d1,(Vpos).w
.2x
	move.w	d3,d0
	sub.w	(Hpos).w,d0
	cmp.w	#$FFD8,d0
	bge.w	.7
	move.w	d3,d1
	subi.w	#$FFD8,d1
	cmp.w	#$FFC4,d1
	bge.w	.8
	move.w	#$FFC4,d1
	bra.w	.8
.7
	cmp.w	#$28,d0
	ble.w	.1
	move.w	d3,d1
	subi.w	#$28,d1
	cmp.w	#$3C,d1
	ble.w	.8
	move.w	#$3C,d1
.8
	sub.w	(Hpos).w,d1
	beq.w	.1
	asr.w	#4,d1
	bne.w	.0
	addq.w	#1,d1
.0
	add.w	d1,(Hpos).w
.1
	rts

FindGoalie	;d0 = SCnum of the goalie of the team of player d0 (the first position 0 going down
	;from player d0), -1 none
	movem.l	d1/a0,-(sp)
	movea.l	#SortCords,a0
	asl.w	#7,d0
	adda.w	d0,a0
	move.w	#5,d1
.0
	tst.w	position(a0)
	beq.w	.1
	suba.w	#$80,a0
	dbf	d1,.0
	move.w	#$FFFF,d0
	bra.w	.end
.1
	move.w	SCnum(a0),d0
.end
	movem.l	(sp)+,d1/a0
	rts
	;The burst code again; nothing reaches this copy.
	;Code the listing does not decode: kept as bytes
	dc.b	$4E,$B9,$00,$01,$FB,$24,$4A,$78,$D2,$64,$66,$00,$00,$1A,$04,$40
	dc.b	$00,$BA,$4E,$B9,$00,$01,$FB,$44,$08,$38,$00,$04,$C3,$4A,$67,$00
	dc.b	$00,$06,$30,$3C,$10,$00,$EE,$48,$32,$00,$34,$2B,$00,$54,$E5,$42
	dc.b	$20,$7C,$00,$01,$AE,$60,$C1,$F0,$20,$00,$C3,$F0,$20,$02,$D1,$6B
	dc.b	$00,$28,$D3,$6B,$00,$2A,$4E,$75

burst	;C button speed burst: take $BA energy unless OptLine is set, add a facedir push to Xvel / Yvel and set
	;SPAburst. Jumped to from doinput
	jsr	(getpde).l	;get players energy
	tst.w	(OptLine).w
	bne.w	.0
	subi.w	#$BA,d0
	jsr	(setpde).l	;decrease players energy
	btst	#4,(sflags7).w
	beq.w	.0
	move.w	#$1000,d0
.0
	lsr.w	#7,d0	;d0 will be $1000 with lines off
	move.w	d0,d1	;energy = speed increase (check violence)
	move.w	facedir(a3),d2	;facedir
	asl.w	#2,d2
	movea.l	#dirtab,a0
	muls.w	(a0,d2.w),d0
	muls.w	2(a0,d2.w),d1
	add.w	d0,Xvel(a3)
	add.w	d1,Yvel(a3)
	bset	#5,pflags(a3)
	move.w	#SPAburst,d1
	bra.w	SetSPA

holdplayer	;Hold check (SPAhook, SPAHold with the stick up); a puck carrier the checked player stops loses the puck.
	;Jumped to from doinput
	bset	#5,pflags(a3)	;lock animation
	move.w	#SPAhook,d1	;move anim into d1 - normal hold check
	tst.w	impact(a3)	;check if impact = 0
	beq.w	SetSPA
	movea.w	#(SortCords-M68K_RAM),a0	;move SortCord into a0
	move.w	impactp(a3),d0	;move last impact player into d0
	asl.w	#7,d0	;calc offset
	adda.w	d0,a0	;add offset to a0
	bset	#5,pflags(a3)	;lock animation
	move.w	#SPAhook,d1	;move anim into d1 - normal hold check
	tst.w	impact(a3)	;check if impact = 0
	beq.w	.2	;set anim if 0
	btst	#4,pflags3(a0)
	bne.w	.0
	cmpi.w	#$76,(a0)
	bgt.w	.0
	cmpi.w	#$FF8A,(a0)
	blt.w	.0
	cmpi.w	#$136,Ypos(a0)
	bgt.w	.0
	cmpi.w	#$FECA,Ypos(a0)
	blt.w	.0
	bra.w	.1
.0
	move.w	#SPA16EE,d1
	bra.w	.2
.1
	move.w	Ypos(a3),d0	;move Ypos checker into d0
	sub.w	Ypos(a0),d0	;sub Ypos of player
	btst	#7,pflags(a3)	;check goal checker is shooting at
	beq.w	.air	;jump if bottom
	neg.w	d0	;make d0 negative
.air
	bmi.w	.2
	move.w	#SPAHold,d1	;set anim - hold check stick in air
.2
	btst	#3,pflags(a0)
	beq.w	SetSPA
	tst.w	position(a0)
	beq.w	SetSPA
	move.w	(puckc).w,d0
	cmp.w	SCnum(a0),d0
	bne.w	SetSPA
	move.w	Xvel(a0),d0
	or.w	Yvel(a0),d0
	bne.w	SetSPA
	st	(puckc).w
	move.b	#$1E,nopuck(a0)
	bra.w	SetSPA

chgplayer	;The pad d4 takes the nearest free skater to where the puck is going (not a goalie, not locked or
	;unavailable; in a penalty shot / shootout only BA_Sktr_SCnum or BA_Goalie_SCnum), or sweep checks when it is the
	;same one. Jumped to from doinput
	btst	#6,(sflags5).w	;Check bit 6
	bne.w	.6
	movem.l	d0-d6/a0-a1,-(sp)
	move.w	(puckvx).w,d0	;lead puck slightly
	asr.w	#8,d0
	add.w	(puckx).w,d0
	move.w	(puckvy).w,d1
	asr.w	#8,d1
	add.w	(pucky).w,d1
	movem.w	d0-d1,-(sp)
	moveq	#5,d2
	move.w	d4,d3
	moveq	#-1,d5
	movea.l	#c1playernum,a0
	move.w	(a0,d4.w),d6
	movea.w	#(SortCords-M68K_RAM),a0	;start of search
	movea.w	#(cont1team-M68K_RAM),a1
	cmpi.w	#1,(a1,d4.w)
	beq.w	.t1
	adda.w	#$300,a0	;controller is on other team
.t1
	movea.w	#(c1playernum-M68K_RAM),a1
.top
	tst.w	position(a0)	;position
	bne.w	.3
	tst.w	(puckc).w
	bmi.w	.3
	movem.w	d1,-(sp)
	move.w	SCnum(a0),d1	;SCnum
	cmp.w	(a1,d4.w),d1
	movem.w	(sp)+,d1
	beq.w	.4
.3
	tst.w	position(a0)	;position
	ble.w	.next	;cant switch to goalie
.4
	btst	#2,pflags2(a0)	;#pf2unav
	bne.w	.next	;this player is unavailable for some reason
	movem.w	d1,-(sp)
	move.w	SCnum(a0),d1	;SCnum
	cmp.w	(a1,d4.w),d1
	movem.w	(sp)+,d1
	beq.w	.0
	btst	#3,pflags(a0)	;is player controlled?
	bne.w	.next	;yes branch
.0
	btst	#2,(BA_PS_flags).w
	beq.w	.1
	movem.l	d0,-(sp)
	move.w	(BA_Sktr_SCnum).w,d0
	cmp.w	SCnum(a0),d0
	movem.l	(sp)+,d0
	beq.w	.1
	movem.l	d0,-(sp)
	move.w	(BA_Goalie_SCnum).w,d0
	cmp.w	SCnum(a0),d0
	movem.l	(sp)+,d0
	bne.w	.next
.1
	movem.w	d1,-(sp)	;the pad's own player may be locked
	move.w	SCnum(a0),d1
	cmp.w	(a1,d4.w),d1
	movem.w	(sp)+,d1
	beq.w	.2
	btst	#5,pflags(a0)
	bne.w	.next
.2
	movem.w	(sp),d0-d1
	sub.w	(a0),d0	;Xpos
	muls.w	d0,d0
	sub.w	Ypos(a0),d1	;Ypos
	muls.w	d1,d1
	add.l	d1,d0
	cmp.l	d5,d0
	bhi.w	.next
	btst	#3,pflags(a0)
	beq.w	.5
	move.w	SCnum(a0),d1
	cmp.w	(a1,d4.w),d1
	bne.w	.next
	btst	#5,pflags(a0)
	beq.w	.5
	cmpi.w	#SPA2576,SPA(a0)
	beq.w	.next
	cmpi.w	#SPA26C8,SPA(a0)
	beq.w	.next
.5
	move.w	SCnum(a0),d1
	move.l	d0,d5
	move.w	d1,d6
.next
	adda.w	#$80,a0	;size of SCstruct
	dbf	d2,.top
	tst.l	d5
	bpl.w	.found
	tst.w	(a1,d4.w)
	bpl.w	.found
	tst.w	d6
	bpl.w	.found
	addq.w	#4,sp
	pea	(.ex).l
	rts
.found
	addq.w	#4,sp
	pea	(.ex).l
	cmp.w	(a1,d4.w),d6
	beq.w	.7	;player is same so sweep check
	move.w	d6,d0	;d0 now is new player
	jmp	setcplayer
.ex
	movem.l	(sp)+,d0-d6/a0-a1
.6
	rts
.7
	btst	#5,pflags(a3)
	beq.w	.8
	rts
.8
	tst.w	position(a3)
	beq.w	.9
	jmp	Sweepcheck
.9
	bset	#5,pflags(a3)
	move.w	#$52C,d1
	jmp	SetSPA

setcplayer	;Give pad d4 (0 / 2 / 4 / 6) player d0: restorepl the old one, then c1playernum + d4 = d0.
	;Jumped to from chgplayer
	movem.l	d0/a0-a1,-(sp)
	movea.l	#c1playernum,a0
	cmp.w	(a0,d4.w),d0
	beq.w	.x
	movem.w	d0-d1,-(sp)
	subq.w	#6,d0
	move.w	(a0,d4.w),d1
	bpl.w	.0
	movem.w	(sp)+,d0-d1
	bra.w	.1
.0
	subq.w	#6,d1
	eor.w	d0,d1
	movem.w	(sp)+,d0-d1
	bmi.w	.2
.1
	asr.w	#1,d4
	movea.l	#unk_FFC38C,a1
	st	(a1,d4.w)
	add.w	d4,d4
	move.w	(a0,d4.w),d1
	jsr	(restorepl).l
	move.w	d0,(a0,d4.w)
.x
	movem.l	(sp)+,d0/a0-a1
	rts
.2
	bra.s	.x

setc1player	;Give pad 1 player d0 (setcplayer, d4 = 0)
	move.w	d4,-(sp)
	clr.w	d4
	bsr.s	setcplayer
	move.w	(sp)+,d4
	rts

setc2player	;Give pad 2 player d0 (setcplayer, d4 = 2)
	move.w	d4,-(sp)
	move.w	#2,d4
	bsr.s	setcplayer
	move.w	(sp)+,d4
	rts

setc3player	;Give pad 3 player d0 (setcplayer, d4 = 4)
	move.w	d4,-(sp)
	move.w	#4,d4
	bsr.s	setcplayer
	move.w	(sp)+,d4
	rts

setc4player	;Give pad 4 player d0 (setcplayer, d4 = 6)
	move.w	d4,-(sp)
	move.w	#6,d4
	bsr.w	setcplayer
	move.w	(sp)+,d4
	rts

Sweepcheck	;Sweep check animation for player a3 (SPA052C for a goalie, else SPA216A)
	move.w	#SPA216A,d1
	tst.w	position(a3)
	bne.w	.0
	move.w	#SPA052C,d1
.0
	bset	#5,pflags(a3)
	bra.w	SetSPA

restorepl	;d1 = old player (back to the computer), d0 = new player (joystick controlled)
	movem.l	a0,-(sp)
	movea.l	#SortCords,a0
	tst.w	d1
	blt.w	.spd
	cmp.w	#$B,d1
	bgt.w	.spd
	asl.w	#7,d1	;multiply d0 by 80 hex (SCsize)
	btst	#3,pflags2(a0,d1.w)	;#pfnp - no joystick pad
	beq.w	.cont
	lsr.w	#7,d1	;divide by 80 hex
	move.w	d1,d0
	bra.w	.ex
.cont
	bclr	#3,pflags(a0,d1.w)	;#pfjoycon
	btst	#3,pflags3(a0,d1.w)	;bit 3, pflags3
	bne.w	.spd
	bset	#1,pflags(a0,d1.w)	;#pfna - new assignment
.spd
	tst.w	d0	;checks if d0 0 or higher
	blt.w	.ex
	cmp.w	#$B,d0	;checks if d0 11 or less
	bgt.w	.ex
	move.w	d0,d1	;copies d0 into d1
	asl.w	#7,d1
	btst	#2,(BA_PS_flags).w
	bne.w	.chkgoalie
	btst	#0,(gmode2).w
	beq.w	.3
.chkgoalie
	tst.w	position(a0,d1.w)
	bne.w	.3
	btst	#6,pflags(a0,d1.w)	;check if home or away
	beq.w	.0
	tst.w	(goaliemode2).w
	bra.w	.1
.0
	tst.w	(goaliemode1).w
.1
	beq.w	.3
	bra.w	.ex	;the goalie stays with the computer
.3
	bset	#3,pflags(a0,d1.w)	;set pfjoycon for SCNum
.ex
	movem.l	(sp)+,a0
	rts

Findhittype	;Z by direction d0 relative to facedir and the hand (attribute bit 3): forehand or backhand
	movem.l	d0-d1,-(sp)
	move.w	#8,d1
	sub.w	facedir(a3),d1
	andi.w	#7,d1
	add.w	d1,d0
	andi.w	#7,d0
	btst	#3,attribute(a3)
	beq.w	.0
	btst	d0,#$1E
	movem.l	(sp)+,d0-d1
	rts
.0
	btst	d0,#$F0
	movem.l	(sp)+,d0-d1
	rts

setpads	;Put SCnum of a3 in the d4 nibble of PadControlBits; d4 = -2 puck carrier, 0 / 2 / 4 / 6 pads.
	;In a shootout only for a pad controlled player (pflags bit 3) or the puck carrier
	movem.l	d0-d1,-(sp)
	btst	#0,(gmode2).w
	beq.w	.0
	btst	#3,pflags(a3)
	bne.w	.0
	move.w	(puckc).w,d0	;puck carrier SCnum into d0
	cmp.w	SCnum(a3),d0	;is player puck carrier?
	bne.w	.1
.0
	moveq	#2,d0
	add.w	d4,d0
	add.w	d0,d0
	moveq	#-16,d1
	rol.l	d0,d1
	and.l	d1,(PadControlBits).w
	clr.l	d1
	move.w	SCnum(a3),d1
	asl.l	d0,d1
	or.l	d1,(PadControlBits).w
.1
	movem.l	(sp)+,d0-d1
	rts

