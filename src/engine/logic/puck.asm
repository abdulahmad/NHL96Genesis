;	Goalie saves and the puck assignments. AdjustFacingDirection turns a player.
;	goaliesave picks the save. The entries cover the carrier, a breakaway, the nearest
;	skater, a pass and a shot.

AdjustFacingDirection				;Turn facedir one step toward direction d0 (not past the directions the
									;masks allow)
	move.w	facedir(a3),d1			;facedir
	sub.w	d1,d0
	beq.w	rtss2
	neg.w	d0
	andi.w	#4,d0
	lsr.w	#1,d0
	subq.w	#1,d0					;d0 = +1/-1
	btst	#pfjoycon,pflags(a3)	;pfjoycon
	bne.w	.add
	btst	d1,#$42
	beq.w	.add
	add.w	d0,d1
	btst	#pfgoal,pflags(a3)		;pfgoal
	bne.w	.dn
	btst	d1,#$83
	bra.w	.0
.dn
	btst	d1,#$38
.0
	beq.w	.1
	neg.w	d0
	add.w	d0,d1
.add
	add.w	d0,d1
.1
	andi.w	#7,d1
	move.w	d1,facedir(a3)			;facedir
	rts

goaliesave							;The goalie a3 makes a save of the puck crossing at a0: the save SPA from
									;saveanim by the side, height and
									;his hand, the crowd up, his speed cut
	addq.w	#1,(ChkCnt).w
	move.w	(a0),d0
	sub.w	(a3),d0					;sub goalie Xpos from d0
	move.w	d3,d1
	sub.w	Ypos(a3),d1				;sub goalie Ypos from d1
	bsr.w	vtoa
	sub.w	facedir(a3),d0
	andi.w	#7,d0
	move.w	d0,d3
	lsr.w	#2,d0					;divide d0 by 4
	btst	#3,attribute(a3)
	beq.w	.1
	eori.w	#1,d0
.1
	move.w	d0,(jerseynum).w
	cmpi.w	#8,(puckz).w			;high shot: shoulder saves
	bgt.w	.6
	cmpi.w	#$800,(puckvz).w
	bgt.w	.6
	bra.w	.low
.6
	movem.l	d0,-(sp)
	move.w	(a3),d0
	sub.w	(a0),d0
	cmp.w	#$10,d0
	bgt.w	.7
	cmp.w	#$FFF0,d0
	blt.w	.7
	movem.l	(sp)+,d0
	addq.w	#6,d0
	bra.w	.done
.7
	movem.l	(sp)+,d0
	bra.w	.done
.low
	addq.w	#4,d0
	cmpi.w	#8,2(a0)				;puckcross frames
	bls.w	.15
	cmpi.w	#2,facedir(a3)
	beq.w	.done
	cmpi.w	#6,facedir(a3)
	beq.w	.done
	tst.w	(puckc).w
	bmi.w	.done
	subq.w	#2,d0
	move.w	d1,-(sp)
	move.w	#$1000,d1
	move.w	d1,Xvel(a3)
	ori.w	#1,d0
	btst	#pfgoal,pflags(a3)
	bne.w	.10
	eori.w	#1,d0
.10
	move.w	#$FFFA,d1
	tst.w	Xvel(a3)
	bmi.w	.11
	neg.w	Xvel(a3)
.11
	tst.w	(a3)
	bpl.w	.13
	tst.w	Xvel(a3)
	bpl.w	.12
	neg.w	Xvel(a3)
.12
	move.w	#6,d1
	eori.w	#1,d0
.13
	add.w	d1,(a3)
	btst	#0,handed(a3)			;check hand of goalie
	beq.w	.14
	eori.w	#1,d0
.14
	move.w	(sp)+,d1
	bra.w	.done
.15
	movem.l	d0,-(sp)
	move.w	(a3),d0
	sub.w	(a0),d0
	cmp.w	#$10,d0
	ble.w	.16
	movem.l	(sp)+,d0
	bra.w	.17
.16
	cmp.w	#$FFF0,d0
	movem.l	(sp)+,d0
	bgt.w	.done
.17
	addq.w	#4,d0
.done
	add.w	d0,d0
	lea	saveanim(pc),a1
	move.w	(a1,d0.w),d1			;SPA of the save
	move.w	(a3),d0
	sub.w	(a0),d0
	bpl.w	.0
	neg.w	d0
.0
	cmp.w	#2,d0
	bgt.w	.2
	cmpi.w	#$C00,(puckvz).w
	bgt.w	.2
	move.w	#SPAgblock,d1
	cmpi.w	#$600,(puckvz).w
	bgt.w	.8
	move.w	#SPAgcatchlow,d1
	bra.w	.8
.2
	cmpi.w	#$400,(puckvz).w
	bgt.w	.5
	move.w	(a3),d0
	sub.w	(a0),d0
	bpl.w	.4
	neg.w	d0
.4
	cmp.w	#$A,d0
	blt.w	.5
	move.w	#SPAgglover2,d1
	btst	#0,(jerseynum+1).w
	beq.w	.3
	move.w	#SPAgglovel2,d1
.3
	bra.w	.8
.5
	cmp.w	#SPAgglovel,d1
	bne.w	.8
	andi.w	#3,d3
	beq.w	.8
	cmpi.b	#$B,aggress(a3)
	blt.w	.8
	move.w	#SPAgglovel2,d1
.8
	bsr.w	SetSPA
	addi.w	#$96,(Crowdlevel).w
	addi.w	#$A,(CwdExciteLvl).w
	asr	Xvel(a3)
	asr	Xvel(a3)
	asr	Yvel(a3)
	asr	Yvel(a3)
	btst	#pfgoal,pflags(a3)
	beq.w	.19
	cmpi.w	#3,facedir(a3)
	beq.w	.9
	cmpi.w	#5,facedir(a3)
	beq.w	.18
	bra.w	.20
.9
	subq.w	#1,facedir(a3)
	bra.w	.20
.18
	addq.w	#1,facedir(a3)
	bra.w	.20
.19
	cmpi.w	#7,facedir(a3)
	beq.s	.9
	cmpi.w	#1,facedir(a3)
	beq.s	.18
.20
	rts

saveanim							;SPA per save type
	dc.w	SPAgglover,SPAgglovel,SPAgstackr,SPAgstackl,SPAgstickr,SPAgstickl
	dc.w	SPAgglover,SPAgglovel,SPAgstickr,SPAgstickl,SPAgglover2,SPAgglovel2

assgoalietopuck						;asstab entry: the goalie skates to the loose puck.
	btst	#pfjoycon,pflags(a3)
	bne.w	assexit					;exit if joystick controlled
	btst	#gmclock,(gmode).w
	bne.w	assexit					;exit if clock stopped
	bsr.w	check4bench
	bclr	#pfna,pflags(a3)		;new assignment
	beq.w	.1
	clr.w	temp1(a3)
.1
	sub.b	d7,temp1(a3)
	bpl.w	.5
	move.b	aidef(a3),d0
	beq.w	.2
	btst	#6,(sflags7).w
	beq.w	.2
	subq.b	#1,d0
.2
	lsr.b	#2,d0
	move.b	d0,temp1(a3)
	tst.w	(puckc).w
	bpl.w	assexit
	tst.w	(puckvy).w
	btst	#pfgoal,pflags(a3)
	beq.w	.3
	eori.b	#8,ccr
.3
	bmi.w	assexit
	movea.w	#(tmstruct-M68K_RAM),a1	;load home team struct into a1
	lea	$39E(a1),a2
	btst	#pfteam,pflags(a3)		;check if player is home or away
	beq.w	.4						;branch if home
	exg	a1,a2						;swap if away
.4
	cmpi.l	#$E10,$2A(a1)
	blt.w	assexit
	cmpi.l	#$640,tmnear(a2)
	blt.w	assexit
.5
	bra.w	skatetoIntercept

breakaway							;Breakaway for the carrier.
	bset	#2,(sflags5).w
	bclr	#pfna,pflags(a3)		;pfna - clear new assignment
	beq.w	.2						;jump if no new assignment
	move.w	#SFXbeep1,-(sp)			;ding SFX
	jsr	(sfx).l
	movem.l	a2,-(sp)
	movea.l	#tmstruct,a2			;move Home Team Struct into a2
	btst	#pfteam,pflags(a3)		;pfteam - check if home or away
	beq.w	.1						;jump if home
	movea.l	#AwShots,a2				;move Away Team Struct into a2
.1
	addq.w	#1,$392(a2)
	addi.w	#$14,(CwdExciteLvl).w	;add to CwdExcite
	addi.w	#$C8,(Crowdlevel).w		;add to Crowdlevel
	movem.l	(sp)+,a2
.2
	movem.w	d1,-(sp)
	move.w	Ypos(a3),d0				;move Ypos into d0
	move.w	Yvel(a3),d1				;move Yvel into d1
	beq.w	.3						;jump if Yvel = 0
	eor.w	d1,d0					;EOR d1 with d0. d0 will be negative if skating opposite direction of net
.loop
	movem.w	(sp)+,d1
	rts
.3
	move.w	#$FFFF,d1
	bra.s	.loop

BreakawayOffsidesFlagSet			;The breakaway / offsides flags of a3.
	btst	#pfna,pflags(a3)		;check for new assignment
	beq.w	.1						;branch if no new assignment
	bclr	#pf3oside,pflags3(a3)	;clear player offsides flag
	bclr	#pf3break,pflags3(a3)	;clear player breakaway flag
.1
	movem.w	d0-d1/a0,-(sp)
	move.w	#$11E,d0
	move.w	Ypos(a3),d1				;Ypos
	bpl.w	.2						;branch if Ypos is positive
	neg.w	d1						;negate d1
.2
	cmp.w	d0,d1					;compare position to top goal line
	bge.w	.loop4					;Branch if above it
	move.w	#$76,d0
	move.w	Ypos(a3),d1				;Ypos
	btst	#pfgoal,pflags(a3)		;check goal to shoot on (0=bottom, 1=top)
	bne.w	.3						;branch if top goal
	neg.w	d1						;bottom goal, so negate d0
	cmp.w	d1,d0					;compare Ypos to blue line Y
	bgt.w	.4
	bra.w	.5						;branch if in attack zone
.3
	cmp.w	d1,d0					;compare Ypos to blue line Y
	blt.w	.5						;branch if in offensive zone
.4
	bset	#pf3oside,pflags3(a3)	;set offsides flag
	bra.w	.loop4
.5
	bclr	#pf3oside,pflags3(a3)	;clear offside bit
	beq.w	.loop4					;branch if on the blue line
	move.w	Ypos(a3),d0
	btst	#pfgoal,pflags(a3)
	bne.w	.6
	neg.w	d0
.6
	subi.w	#$76,d0
	bpl.w	.7
	neg.w	d0
.7
	cmp.w	#$23,d0
	blt.w	.8
	bra.w	.loop4
.8
	move.w	Ypos(a3),d1
	movea.l	#SortCords+(11*SCstruct),a0	;loads last SCScruct player struct (Away pos #6)
	move.w	#$B,d0					;B = # of player structs to check (12)
	tst.w	d1						;checks if d1 is negative (determines what zone to check)
	bmi.w	.loop5
.loop
	cmp.w	Ypos(a0),d1				;compare Ypos of a0 player to d1 (Ypos puckc)
	bge.w	.9						;branch if d1 greater than or equal
	tst.w	position(a0)			;check if goalie
	beq.w	.9						;branch if goalie
	bra.w	.loop4
.9
	suba.w	#SCstruct,a0
	dbf	d0,.loop
.loop2
	bset	#pf3break,pflags3(a3)	;set breakaway bit
	move.w	#1,d0					;moves 1 into d0 (used by returned subroutine)
.loop3
	movem.w	(sp)+,d0-d1/a0
	rts
.loop4
	move.w	#0,d0					;move 0 into d0 (used on return to subroutine)
	bra.s	.loop3
.loop5
	cmp.w	$14(a0),d1				;check Ypos with d1 (d1 = blue line Y)
	ble.w	.10
	tst.w	$34(a0)					;checks if goalie (who would be below blue line)
	beq.w	.10
	bra.s	.loop4
.10
	suba.w	#SCstruct,a0			;back one sort object
	dbf	d0,.loop5
	bra.s	.loop2

chkpuckc							;asstab entry: breakaway carrier check, then asspuckc.
	btst	#0,(gmode2).w
	bne.w	.1
	btst	#2,(BA_PS_flags).w
	bne.w	.1
	bsr.w	breakaway
	bpl.w	asspuckc				;currently skating towards net in Y
.1
	bclr	#pf3break,pflags3(a3)	;clear breakaway bit
	move.w	#$10,d0
	bsr.w	assreplace

asspuckc							;asstab entry: the puck carrier.
	bclr	#2,(sflags5).w
	bne.w	.1
	bclr	#pf3break,pflags3(a3)
	;check the message timer
.1
	move.w	(puckc).w,d0
	cmp.w	SCnum(a3),d0
	bne.w	assexit
	btst	#2,(BA_PS_flags).w
	beq.w	.2
	cmpi.w	#1,(msgtimer).w
	bgt.w	.23
	;breakaway check
.2
	btst	#pf3break,pflags3(a3)
	bne.w	.3
	btst	#2,(BA_PS_flags).w
	bne.w	.3
	jsr	(BreakawayOffsidesFlagSet).l
	beq.w	.3						;branch if breakaway flag not set
	move.w	#$21,d0					;chkpuckc assignment
	bsr.w	assreplace
	bra.w	.3
	;no breakaway: normal puck carrier play
.3
	btst	#pfalock,pflags(a3)
	bne.w	rtss2
	btst	#2,(BA_PS_flags).w
	bne.w	.4
	btst	#gmclock,(gmode).w
	bne.w	donothing
	;breakaway check
.4
	btst	#pfjoycon,pflags(a3)
	bne.w	assexit
	bclr	#pfna,pflags(a3)
	beq.w	.9
	move.l	a0,-(sp)
	movea.l	#LastCarrierHome,a0
	btst	#pfteam,pflags(a3)
	beq.w	.5
	movea.l	#LastCarrierAway,a0
.5
	move.w	SCnum(a3),(a0)
	movea.l	(sp)+,a0
	btst	#pf3break,pflags3(a3)
	beq.w	.6
	move.w	#SFXbeep1,-(sp)
	jsr	(sfx).l
	;breakaway crowd
.6
	btst	#pf3break,pflags3(a3)
	beq.w	.8
	movem.l	a2,-(sp)
	movea.l	#tmstruct,a2
	btst	#pfteam,pflags(a3)
	beq.w	.7
	movea.l	#AwShots,a2
	;team struct chosen
.7
	addq.w	#1,$392(a2)
	addi.w	#$14,(CwdExciteLvl).w
	addi.w	#$C8,(Crowdlevel).w
	movem.l	(sp)+,a2
	;breakaway check done
.8
	clr.w	temp1(a3)
	move.w	#8,temp2(a3)
	move.w	(HVcount).l,d0
	andi.w	#3,d0
	move.w	d0,temp3(a3)
	;count down the timer
.9
	sub.b	d7,temp1(a3)
	bpl.w	.16
	move.b	aioff(a3),temp1(a3)
	jsr	(ReadGoaliePulled).l
	bmi.w	.10
	btst	#6,(sflags7).w
	beq.w	.11
	tst.b	temp1(a3)
	beq.w	.11
	;goalie pulled or crowd meter broken: quicker decisions
.10
	subq.b	#1,temp1(a3)
	;shootout or penalty shot: the shootout shot check
.11
	btst	#2,(BA_PS_flags).w
	bne.w	.14
	btst	#0,(gmode2).w
	bne.w	.14
	jsr	(checkob).l
	bsr.w	chk4lc
	btst	#0,(gmode2).w
	bne.w	.14
	btst	#2,(BA_PS_flags).w
	bne.w	.14
	btst	#pf3break,pflags3(a3)
	bne.w	.13
	move.w	#1,d0
	btst	#pfteam,pflags(a3)
	beq.w	.12
	move.w	#2,d0
	;team pad chosen
.12
	cmp.w	(cont1team).w,d0
	beq.w	.13
	cmp.w	(cont2team).w,d0
	beq.w	.13
	btst	#1,(Vcount+1).w
	bne.w	.15
	;shoot check (on a computer pad, every other frame)
.13
	bsr.w	chk4shot
	bra.w	.15
	;bit 2 of BA_PS_flags set or bit 0 of gmode2 set
.14
	jsr	(ShootoutShootCheck).l
	bne.w	.16
	jsr	(shotdirmathAssShoot).l
	;then the pass check
.15
	bsr.w	chk4pass
	;skate on toward the target spot (.postab2)
.16
	moveq	#6,d0
	add.w	temp3(a3),d0			;add temp3 to d0
	lea	.table2(pc),a0
	btst	#sf2offsig,(sflags2).w	;#sf2offsig
	beq.w	.17
	move.w	position(a3),d0			;position
	;position for the offside check
.17
	asl.w	#2,d0
	move.w	2(a0,d0.w),d1
	move.w	(a0,d0.w),d0
	btst	#2,(BA_PS_flags).w
	bne.w	.18
	btst	#0,(gmode2).w
	beq.w	.19
	;skate the shootout path
.18
	jsr	(SkatePath).l
	cmpi.b	#$80,($FFFFD818).w
	beq.w	.23
	;normal skating
.19
	btst	#pfgoal,pflags(a3)		;pfgoal - 0 for bottom 1 for top
	bne.w	.20
	neg.w	d0
	neg.w	d1
	;coordinates for his end
.20
	lea	.table(pc),a0
	btst	#2,(BA_PS_flags).w
	bne.w	.21
	btst	#0,(gmode2).w
	beq.w	.22
	;shootout or penalty shot: path done
.21
	lea	.23(pc),a0
	;skate the path
.22
	bra.w	skateto
.table
	dc.w	$4880,$142B,$0028,$4882,$D478,$B75E,$162B,$002A
	dc.w	$4883,$D678,$B772,$4278,$BF18,$7805,$307C,$B05E
	dc.w	$0C6B,$0006,$0052,$6C00,$0006,$D0FC,$0300,$1228
	dc.w	$0028,$4881,$D250,$9242,$B27C,$0014,$6E00,$0058
	dc.w	$B27C,$FFEC,$6D00,$0050,$1228,$002A,$4881,$D268
	dc.w	$0014,$9243,$B27C,$0014,$6E00,$003C,$B27C,$FFEC
	dc.w	$6D00,$0034,$5278,$BF18,$3013,$9050,$322B,$0014
	dc.w	$9268,$0014,$6100,$20B2,$322B,$0054,$0A41,$0004
	dc.w	$B240,$6600,$0012,$3239,$00C0,$0008,$0241,$0001
	dc.w	$D041,$0240,$0007,$D0FC,$0080,$51CC,$FF92
.23
	rts
.table2
	dc.w	$FF9C,$FFEC,$0064,$FFEC,$FF88,$0028,$0014,$0028
	dc.w	$0078,$0028,$FFEC,$0028,$FFD8,$0106,$0000,$00F2
	dc.w	$0014,$00FC,$001E,$00FC
chk4lc								;Late check: when the puck is in the player half and the roll allows, set
									;the check bit
	btst	#4,(sflags7).w
	bne.w	rtss2
	move.w	(pucky).w,d0
	btst	#pfgoal,pflags(a3)
	bne.w	.1
	neg.w	d0
.1
	tst.w	d0
	bmi.w	rtss2
	cmp.w	#$76,d0
	bgt.w	rtss2
	move.w	(HVcount).l,d0
	andi.w	#3,d0
	bne.w	rtss2
	btst	#pf2lcm,pflags2(a3)
	bne.w	rtss2
	movea.w	#(tmstruct-M68K_RAM),a2
	lea	$39E(a2),a1
	btst	#pfteam,pflags(a3)
	beq.w	.2
	exg	a2,a1
.2
	bsr.w	AvgCline
	cmp.w	#$C00,d0
	bhi.w	rtss2
	bsr.w	CompLine
	bsr.w	setpersonel
	bsr.w	printscores1
	jmp	(shotdirmathAssShoot).l

chkpk								;With a power play (sflags2 bit 5) chkpk2, else Z set
	btst	#sf2pwrplay,(sflags2).w
	bne.w	chkpk2
	eori	#4,ccr					;Z flag
	rts

chkpk2								;Z set when a3's team is on the power play (sflags2 bit 6 against pfteam)
	movem.l	d0-d1,-(sp)
	btst	#sf2pwrtm,(sflags2).w	;#sf2pwrtm - 0 for team 1, 1 for team 2
	move	sr,d0
	btst	#pfteam,pflags(a3)
	move	sr,d1
	eor.w	d1,d0
	move	d0,ccr
	movem.l	(sp)+,d0-d1
	rts
	;After chkpk2: code that nothing in the listing reaches.
chk4shot	equ	*	;Choose to shoot: puck carrier with a clear lane and a random roll
	bsr.s	chkpk
	bne.w	.4						;killing penalty
	tst.w	(glovecords+4).w
	beq.w	.4						;no threat
	move.w	(HVcount).l,d0
	andi.w	#3,d0
	bne.w	.4
	move.w	#$76,d0
	btst	#pfgoal,pflags(a3)
	beq.w	.1
	move.w	#$FF8A,d0
	cmp.w	Ypos(a3),d0
	blt.w	.3
	bra.w	.2						;clear puck
.1
	cmp.w	Ypos(a3),d0
	bgt.w	.3						;clear puck
.2
	bset	#3,(sflags5).w
	jmp	(dopass).l
.3
	jmp	(shotdirmathAssShoot).l
.4
	btst	#pf3break,pflags3(a3)
	beq.w	.5
	move.w	#$1E,d0
	jsr	(randomd0).l
	addi.w	#$82,d0
	cmp.w	(pucky).w,d0
	blt.w	.loop
	neg.w	d0
	cmp.w	(pucky).w,d0
	bgt.w	.loop
	bra.w	.5
.loop
	move.w	#2,d0
	jsr	(randomd0s).l
	add.w	facedir(a3),d0
	andi.w	#7,d0
	move.w	d0,facedir(a3)
	jmp	(shotdirmathAssShoot).l
.5
	moveq	#$20,d4
	clr.w	d1
	move.b	spodds(a3),d1
	lsr.w	#1,d1
	sub.b	d1,d4
	asl.w	#4,d4
	move.w	#$11E,d1
	btst	#pfgoal,pflags(a3)
	bne.w	.6
	neg.w	d1
.6
	sub.w	(pucky).w,d1
	move.w	(puckx).w,d0
	neg.w	d0
	movem.w	d0-d1,-(sp)
	muls.w	d0,d0
	muls.w	d1,d1
	add.l	d0,d1
	cmp.l	#$2710,d1
	movem.w	(sp)+,d0-d1
	bhi.w	.10
	lsr.w	#4,d4
	bsr.w	vtoa
	move.w	d0,d5
	moveq	#5,d3
	movea.w	#(SortCords-M68K_RAM),a1
	cmpi.w	#6,SCnum(a3)
	bge.w	.loop2
	adda.w	#$300,a1
.loop2
	tst.w	$34(a1)
	beq.w	.7
	btst	#pfalock,pflags(a1)
	bne.w	.7
	move.w	(a1),d0
	sub.w	(puckx).w,d0
	move.w	$14(a1),d1
	sub.w	(pucky).w,d1
	bsr.w	vtoa
	cmp.w	d5,d0
	bne.w	.9
	asl.w	#1,d4
	bra.w	.9
.7
	cmpi.w	#$13,(a1)
	bgt.w	.8
	cmpi.w	#$FFED,(a1)
	blt.w	.8
	btst	#pf2aip,pflags2(a1)
	beq.w	.9
	clr.w	d3
.8
	moveq	#1,d4
.9
	adda.w	#SCstruct,a1
	dbf	d3,.loop2
.10
	move.w	d4,d0
	bsr.w	randomd0
	btst	#0,spodds(a3)
	beq.w	.11
	cmp.w	#7,d0
	bgt.w	rtss2
	bra.w	.13
.11
	cmpi.w	#$51,(puckx).w
	bgt.w	.12
	cmpi.w	#$FFAF,(puckx).w
	blt.w	.12
	subi.w	#$A,d0
.12
	cmp.w	#8,d0
	bgt.w	rtss2
.13
	move.w	(pucky).w,d0
	btst	#pfgoal,pflags(a3)
	bne.w	.14
	neg.w	d0
.14
	tst.w	d0
	bmi.w	rtss2
	move.w	#$11E,d1
	sub.w	d0,d1
	bmi.w	rtss2
	btst	#sf2offsig,(sflags2).w
	bne.w	rtss2
	bra.w	.loop
chk4pass	equ	*	;Choose to pass: random roll weighted by the stick hand and the lines
	tst.w	(glovecords+4).w
	bne.w	.15
	moveq	#$10,d0
	add.b	spodds(a3),d0
	bsr.w	randomd0
	cmp.w	#$C,d0
	bgt.w	rtss2
.15
	moveq	#6,d0
	bsr.w	randomd0
	cmpi.w	#6,SCnum(a3)
	blt.w	.16
	addq.w	#6,d0
.16
	tst.w	position(a3)
	beq.w	.17
	cmpi.w	#$28,(puckx).w
	bgt.w	.17
	cmpi.w	#$FFD8,(puckx).w
	blt.w	.17
	cmpi.w	#$E2,(pucky).w
	bgt.w	rtss2
	cmpi.w	#$FF1E,(pucky).w
	blt.w	rtss2
.17
	cmp.w	SCnum(a3),d0
	beq.w	rtss2
	asl.w	#7,d0
	movea.w	#(SortCords-M68K_RAM),a0
	adda.w	d0,a0
	tst.w	position(a0)
	ble.w	rtss2
	btst	#pf2unav,pflags2(a0)
	bne.w	rtss2
	btst	#pfalock,pflags(a0)
	bne.w	rtss2
	move.w	Ypos(a0),d0
	move.w	Ypos(a3),d1
	btst	#pfgoal,pflags(a3)
	bne.w	.18
	neg.w	d0
	neg.w	d1
.18
	btst	#gmoffs,(gmode).w
	beq.w	.19
	movem.w	d0-d1,-(sp)
	subi.w	#$76,d0
	subi.w	#$76,d1
	eor.w	d0,d1
	movem.w	(sp)+,d0-d1
	bmi.w	rtss2
.19
	cmp.w	#$76,d0
	bgt.w	.20
	sub.w	d1,d0
	cmp.w	#$FFF1,d0
	blt.w	rtss2
.20
	move.w	(a0),d0
	sub.w	(puckx).w,d0
	move.w	Ypos(a0),d1
	sub.w	(pucky).w,d1
	movem.w	d0-d1,-(sp)
	bsr.w	vtoa
	move.w	d0,(passdir).w
	movem.w	(sp)+,d1-d2
	muls.w	d1,d1
	muls.w	d2,d2
	add.l	d1,d2
	moveq	#5,d3
	movea.w	#(SortCords-M68K_RAM),a1
	cmpi.w	#6,SCnum(a3)
	bge.w	.loop3
	adda.w	#$300,a1
.loop3
	move.w	(a1),d0
	sub.w	(puckx).w,d0
	move.w	$14(a1),d1
	sub.w	(pucky).w,d1
	movem.w	d0-d1,-(sp)
	muls.w	d0,d0
	muls.w	d1,d1
	add.l	d0,d1
	cmp.l	d2,d1
	movem.w	(sp)+,d0-d1
	bhi.w	.21
	bsr.w	vtoa
	cmp.w	(passdir).w,d0
	beq.w	rtss2
.21
	adda.w	#SCstruct,a1
	dbf	d3,.loop3
	jsr	(dopass).l
	tst.w	position(a3)
	beq.w	rtss2
	addq.w	#4,sp
	bra.w	assexit

EvadePC								;skateto extra routine: steer around the puck carrier (its address is
									;passed in a0).
	tst.w	(puckc).w
	bmi.w	rtss2					;no puck carrier
	move.b	Xvel(a3),d2				;Xvel
	sub.b	(puckvx).w,d2			;sub puckvx from Xvel
	ext.w	d2
	add.w	(a3),d2					;add Xpos
	sub.w	(puckx).w,d2			;Sub puckx
	cmp.w	#$28,d2					;'('   ; compare to 40 decimal
	bgt.w	rtss2					;exit if greater than 40
	cmp.w	#$FFD8,d2				;compare to -40
	blt.w	rtss2					;exit if less than -40
	move.b	Yvel(a3),d1				;Yvel
	sub.b	(puckvy).w,d1			;sub puckvy from Yvel
	ext.w	d1
	add.w	Ypos(a3),d1				;add Ypos to d1
	sub.w	(pucky).w,d1			;Sub pucky
	cmp.w	#$28,d1					;'('   ; compare to 40 dec
	bgt.w	rtss2					;exit if greater than
	cmp.w	#$FFD8,d1				;compare to -40 dec
	blt.w	rtss2					;exit if less than
	move.w	(a3),d0					;Xpos
	sub.w	(puckx).w,d0			;Sub puckx from Xpos
	move.w	Ypos(a3),d1				;Ypos
	sub.w	(pucky).w,d1			;Sub pucky from Ypos
	bsr.w	vtoa					;find direction and convert to 0-7
	btst	#gmoffs,(gmode).w		;check if offsides is on
	beq.w	.2						;exit if not
	move.w	Ypos(a3),d1				;Ypos
	btst	#pfgoal,pflags(a3)		;check what net shooting at
	bne.w	.1						;branch if top
	neg.w	d1						;negate d1 (Ypos)
.1
	subi.w	#$76,d1
	cmp.w	#$A,d1					;compare to 10 decimal
	bgt.w	.2						;exit if greater
	cmp.w	#$FFCE,d1
	blt.w	.2						;branch if less than
	moveq	#2,d0
	move.w	(a3),d1					;Xpos
	cmp.w	(puckx).w,d1			;compare puckx with Ypos difference
	bgt.w	.2						;exit if greater
	moveq	#6,d0
.2
	rts

checkob								;Offside watch (gmode bit 5): with a player of the attacking side past the
									;blue line ahead of the puck set sflags2 bit 7 (and the referee, PushRef),
									;clear it when they are all back
	btst	#gmoffs,(gmode).w
	beq.w	rtss2
	btst	#2,(BA_PS_flags).w
	bne.w	rtss2
	movem.l	d0-d1/a0,-(sp)
	moveq	#5,d0
	movea.w	#(SortCords-M68K_RAM),a0
	cmpi.w	#6,SCnum(a3)
	blt.w	.0
	adda.w	#$300,a0
.0
	moveq	#$7A,d1
	btst	#pfgoal,pflags(a3)
	bne.w	.top
	neg.w	d1
	cmp.w	(pucky).w,d1
	bgt.w	.3
.1
	tst.w	position(a0)
	bmi.w	.2
	cmp.w	Ypos(a0),d1
	bgt.w	.5
.2
	adda.w	#$80,a0
	dbf	d0,.1
.3
	moveq	#$40,d0
	bclr	#sf2offsig,(sflags2).w
	bne.w	.dref
.ex
	movem.l	(sp)+,d0-d1/a0
	rts
.5
	moveq	#6,d0
	bset	#sf2offsig,(sflags2).w
	bne.s	.ex
.dref
	tst.w	(RefCnt).w
	bpl.s	.ex
	bsr.w	PushRef
	bra.s	.ex
.top
	cmp.w	(pucky).w,d1
	blt.s	.3
.8
	tst.w	position(a0)
	bmi.w	.9
	cmp.w	Ypos(a0),d1
	blt.s	.5
.9
	adda.w	#$80,a0
	dbf	d0,.8
	bra.s	.3

assbreakaway						;asstab entry: breakaway; falls into assnearest.
	move.w	SCnum(a3),d0			;Move SCnum into d0
	cmp.w	(puckc).w,d0			;compare puck carrier SCnum with d0
	beq.w	.1						;branch if puck carrier
.loop
	bclr	#pf3break,pflags3(a3)	;clear breakaway bit
	move.w	#$11,d0
	bsr.w	assreplace
	bra.w	assnearest
.1
	jsr	(breakaway).l
	bmi.s	.loop

assnearest							;asstab entry: the player nearest the puck without it.
	bclr	#2,(sflags5).w
	bne.w	.1
	bclr	#pf3break,pflags3(a3)	;clear breakaway bit
	;check the puck
.1
	move.w	SCnum(a3),d0			;move SCnum into d0
	cmp.w	(puckc).w,d0			;compare with puck carrier SCnum
	bne.w	.2						;jump if not puck carrier
	btst	#pf3break,pflags3(a3)	;check breakaway bit
	bne.w	.2						;jump if set
	btst	#2,(BA_PS_flags).w		;check if bit 2 set (cleared on Faceoffs)
	bne.w	.2						;jump if set
	jsr	(BreakawayOffsidesFlagSet).l
	beq.w	.2
	move.w	#$22,d0					;22 - assbreakaway if flag set
	bsr.w	assreplace				;assreplace with assbreakaway
	bra.w	.2
	;assnearest: breakaway carriers switch to assbreakaway
.2
	bclr	#pfna,pflags(a3)		;pfna - clear new assignment
	beq.w	.7
	move.l	a0,-(sp)
	movea.l	#LastCarrierHome,a0
	btst	#pfteam,pflags(a3)
	beq.w	.3
	movea.l	#LastCarrierAway,a0
.3
	move.w	SCnum(a3),(a0)
	movea.l	(sp)+,a0
	btst	#pf3break,pflags3(a3)	;check if breakaway
	beq.w	.4						;jump if not
	move.w	#SFXbeep1,-(sp)			;ding SFX
	jsr	(sfx).l
	;breakaway crowd
.4
	btst	#pf3break,pflags3(a3)	;check if breakaway
	beq.w	.6						;jump if not
	movem.l	a2,-(sp)
	movea.l	#tmstruct,a2			;put Home Team Struct into a2
	btst	#pfteam,pflags(a3)		;pfteam - check home or away
	beq.w	.5						;jump if home
	movea.l	#AwShots,a2				;put Away Team Struct into a2
	;team struct chosen
.5
	addq.w	#1,$392(a2)				;add to breakaway attempt
	addi.w	#$14,(CwdExciteLvl).w	;add to excite level
	addi.w	#$C8,(Crowdlevel).w		;add to crowd level
	movem.l	(sp)+,a2
.6
	clr.w	temp3(a3)
	move.w	#8,temp2(a3)
	clr.w	temp1(a3)
.7
	tst.w	(puckc).w
	bmi.w	.9
	move.l	a0,-(sp)
	movea.l	#LastCarrierHome,a0
	cmpi.w	#5,(puckc).w
	ble.w	.8
	movea.l	#LastCarrierAway,a0
.8
	move.w	(puckc).w,(a0)
	movea.l	(sp)+,a0
	;count down the timer
.9
	move.w	SCnum(a3),d1			;checks if puck carrier
	cmp.w	(puckc).w,d1
	bne.w	.10						;jumps if not
	tst.w	position(a3)			;check if goalie
	beq.w	assgoaliecpu			;branch if goalie
	moveq	#$10,d0					;10 = asspuckc
	btst	#pfjoycon,pflags(a3)	;pfjoycon - check if controlled
	beq.w	assinsert				;jump if not
	rts								;human controlled: leave as is
	;d1 <> puckc
.10
	sub.b	d7,temp1(a3)			;subtract d7 (elapsed frames) from temp1
	bpl.w	.21						;jump if positive
	move.b	aioff(a3),temp1(a3)
	jsr	(ReadGoaliePulled).l		;check if goalie is pulled
	bmi.w	.11
	btst	#6,(sflags7).w			;check if crowd meter currently broken
	beq.w	.12						;jump if not broken
	tst.b	temp1(a3)				;check if temp1 is 0
	beq.w	.12						;jump if so
	;goalie pulled or crowd meter broken: quicker reactions
.11
	subq.b	#1,temp1(a3)			;subtract 1 from temp1
	;puck carrier in the slot: count it for the right team
.12
	btst	#5,(sflags6).w			;check if slot bit is set (puckc in slot)
	beq.w	.14						;branch if not set
	move.w	(puckc).w,d1			;move puck carrier SCnum
	cmp.w	#5,d1					;check if its home (5 or less) or away (6-11)
	bgt.w	.13						;jump if away
	btst	#pfteam,pflags(a3)		;pfteam
	beq.w	.14						;jump if home
	;loop
.loop
	move.b	temp1(a3),d1			;temp1 into d1
	ext.w	d1						;extend d1
	asr.w	#1,d1					;divide by 2
	move.b	d1,temp1(a3)			;move d1 into temp1 - cutting the timer in half
	bne.w	.14						;jump if not zero
	move.b	#1,temp1(a3)			;move 1 into temp1
	bra.w	.14
	;d1 > 5
.13
	btst	#pfteam,pflags(a3)		;pfteam - 0 home, 1 away
	beq.s	.loop					;jump if home
	;find our skater nearest the puck
.14
	clr.l	$2A(a2)					;no nearest skater yet
	move.w	(puckc).w,d1			;move puck carrier SCnum into d1
	bmi.w	.15						;branch if no puck carrier
	asl.w	#scsize,d1				;scsize
	movea.w	#(SortCords-M68K_RAM),a1	;Move SortCords into a1
	adda.w	d1,a1					;use d1 as offset
	move.b	pflags(a1),d0			;pflags of puck carrier
	move.b	pflags(a3),d1			;pflags of current player
	eor.b	d0,d1					;XOR pflags
	btst	#pfteam,d1				;check pfteam
	beq.w	.17						;branch if on same team
	;not the carrier
.15
	moveq	#-$1,d2					;-1
	moveq	#5,d4					;5 = # of players on team
	movea.w	$22(a2),a0				;SortCord start value for team
	;loop over our skaters: d2 = smallest distance^2 to the puck
.loop2
	tst.w	$34(a0)					;check if goalie
	ble.w	.16						;branch if goalie
	tst.b	$5E(a0)					;check if nopuck (cant touch puck)
	bne.w	.16						;branch if nopuck timer not 0
	btst	#pf2unav,$63(a0)		;pf2unav - unavailable
	bne.w	.16						;branch if unavailable
	move.w	$52(a0),d0
	cmp.w	(LastCarrierAway+2).w,d0
	beq.w	.16
	move.w	$36(a0),d0				;assnum - current assignment
	cmpi.b	#$13,$38(a0,d0.w)		;check if current assignment is asspassrec
	beq.w	.16						;branch if a0 is going to receive puck
	move.l	a0,-(sp)				;push onto stack
	bsr.w	GetHot					;get hot spot
	add.w	(a0),d0					;Xpos to d0
	sub.w	(puckx).w,d0			;sub puck Xpos
	add.w	$14(a0),d1				;add Ypos to d1
	sub.w	(pucky).w,d1			;sub puck Ypos
	move.w	(puckvx).w,d3			;puckvx into d3
	asr.w	#6,d3					;divide by 64
	sub.w	d3,d0					;sub d3 from d0 (X distance between player and puck)
	move.w	(puckvy).w,d3			;puckvy into d3
	asr.w	#6,d3					;divide by 64
	sub.w	d3,d1					;sub d3 from d1 (Y distance between player and puck)
	muls.w	d0,d0					;square d0
	muls.w	d1,d1					;square d1
	add.l	d1,d0					;add d1 to d0
	cmp.l	d2,d0					;compare d2 to d0
	bhi.w	.16						;branch if d0 higher than d2 (0 or a positive # first run)
	move.l	d0,d2					;move d0 into d2
	movea.w	a0,a1					;move a0 address into a1
	;next skater
.16
	adda.w	#SCstruct,a0			;SCstruct size
	dbf	d4,.loop2					;iterate through loop
	tst.l	d2						;check if 0
	bmi.w	.18						;branch if less (no one near puck)
	move.l	d2,$2A(a2)				;nearest skater's distance^2 to the puck
	;nearest skater found
.17
	cmpa.w	a1,a3					;a1 = closest to the puck, or puckc (if on same team)
	beq.w	.18						;branch if same
	btst	#gmclock,(gmode).w		;gmclock - 1 if stopped
	bne.w	.18						;jump if stopped
	btst	#pf2unav,$63(a1)		;pf2unav
	bne.w	.18						;jump if unavailable
	btst	#pf3onetimer,$64(a1)	;shooting one timer
	bne.w	.18						;jump if shooting
	exg	a1,a3						;swap addresses
	bclr	#pfdoff,$62(a3)			;clear pfdoff
	moveq	#$11,d0					;assnearest
	bsr.w	assinsert				;... and give him the assnearest assignment
	exg	a1,a3
	bra.w	assexit					;I (old a3) drop this assignment
	;nobody nearer: go to the puck
.18
	btst	#pfalock,pflags(a3)		;pfalock - check if locked in animation
	bne.w	rtss2					;exit if locked
	moveq	#2,d1					;move 2 into d1
	cmp.w	#$190,d2				;compare $190 (20^2) to d2. d2 = distance to puck^2
	bhi.w	.19						;branch if d2 higher
	subq.w	#2,d1					;close: d1 = 0
	cmpi.w	#2,position(a3)			;compare if position is F or D (1 and 2 are D)
	bls.w	.21						;jump if D
	;far from the puck
.19
	btst	#sf2pwrplay,(sflags2).w	;sf2pwrplay - check if PP
	beq.w	.20						;branch if no PP
	subq.w	#2,d1					;sub 2 from d1
	bsr.w	chkpk2
	bne.w	.20						;branch if on PK
	addq.w	#4,d1					;add 4 to d1
	;d1 = shift for the check odds (penalty kill uses less)
.20
	move.w	#$28,d0					;move $28 into d0 (40 dec)
	sub.b	checking(a3),d0
	asl.w	d1,d0					;shift d0 by value of d1
	bsr.w	randomd0				;RNG
	cmp.w	#2,d0					;compare 2 to d0
	bhi.w	.21						;branch if d0 more than 2
	move.w	#$F0,temp3(a3)			;move 240 dec into temp3
	;temp3 = 240 on a low roll: probably a hit timer
.21
	btst	#pfalock,pflags(a3)		;pfalock - check if anim lock
	bne.w	rtss2					;exit if locked
	btst	#2,(BA_PS_flags).w		;check bit 2
	beq.w	.22						;jump if not set
	btst	#5,(BA_PS_flags).w		;check bit 5
	beq.w	.23						;jump if not set
	;clock running?
.22
	btst	#gmclock,(gmode).w		;check if clock running
	bne.w	donothing				;branch if not
	;clock running: count down
.23
	btst	#pfjoycon,pflags(a3)	;pfjoycon - check if controlled
	bne.w	rtss2					;jump if controlled
	btst	#2,$30(a2)				;tmfmid of tmflags(a2)
	bne.w	.29
	tst.w	(puckc).w				;check if theres a puck carrier
	bmi.w	.41						;jump if no puck carrier
	tst.w	position(a3)
	beq.w	.28
	movem.l	d0/a0,-(sp)
	movea.l	#SortCords,a0
	move.w	(puckc).w,d0
	asl.w	#7,d0
	adda.w	d0,a0
	tst.w	position(a0)
	bne.w	.24
	movem.l	(sp)+,d0/a0
	clr.w	d0
	clr.w	d1
	lea	rtss2(pc),a0
	jmp	(skateto).l
	bra.w	.25
.24
	move.w	(puckvx).w,d0
	or.w	(puckvy).w,d0
	movem.l	(sp)+,d0/a0
	bne.w	.25
	bsr.w	check4check
	bra.w	.41
.25
	movem.w	d0,-(sp)
	move.w	(a3),d0
	sub.w	(puckx).w,d0
	bpl.w	.26
	neg.w	d0
.26
	cmp.w	#$3C,d0
	movem.w	(sp)+,d0
	bgt.w	.41
	movem.w	d0,-(sp)
	move.w	Ypos(a3),d0
	sub.w	(pucky).w,d0
	bpl.w	.27
	neg.w	d0
.27
	cmp.w	#$3C,d0
	movem.w	(sp)+,d0
	bgt.w	.41
.28
	sub.w	d7,temp3(a3)			;subtract frames from temp3
	bpl.w	.41						;jump if positive
	clr.w	temp3(a3)				;clear temp3
	;skate to the puck
.29
	bsr.w	PuckLeadPosition		;d0/d1 = halfway between
	movem.w	d0-d1,-(sp)				;d0 = future puckx, d1 = future pucky push on stack
	neg.w	d0						;or (0,-$F4) if pfgoal
	neg.w	d1
	addi.w	#$10A,d1
	btst	#pfgoal,pflags(a3)		;pfgoal - check what net shooting on
	beq.w	.30						;branch if bottom
	subi.w	#$214,d1
	;Y target for his end
.30
	asr.w	#1,d0					;divide by 2
	asr.w	#1,d1					;divide by 2
	add.w	(sp)+,d0				;add original future puckx
	add.w	(sp)+,d1				;add original future pucky
	btst	#2,$30(a2)				;?? - doesn't seem to be set anywhere
	beq.w	.32
	btst	#pfgoal,pflags(a3)		;pfgoal
	beq.w	.31						;branch if bottom
	cmp.w	#$71,d1
	blt.w	.32						;branch if in neutral zone or D zone
	move.w	#$62,d1
	bra.w	.32
.31
	cmp.w	#$FF8F,d1
	bgt.w	.32						;branch if in neutral zone or D zone
	move.w	#$FF9E,d1
	;carrier in the slot: speed boost toward the puck
.32
	btst	#5,(sflags6).w			;check if puckc is in the slot
	beq.w	.34						;branch if not
	move.b	legspd(a3),(TempLegSpd).w
	addq.b	#6,legspd(a3)
	addq.b	#2,legspd(a3)
	cmpi.b	#$1E,legspd(a3)
	ble.w	.33
	move.b	#$1E,legspd(a3)
	;skate, then put the leg speed back
.33
	lea	rtss2(pc),a0
	bsr.w	skateto
	move.b	(TempLegSpd).w,legspd(a3)
	bra.w	.35
	;bit 5 of sflags6 clear
.34
	lea	rtss2(pc),a0
	bsr.w	skateto
	;in the slot: chase the carrier
.35
	btst	#5,(sflags6).w
	beq.w	.39
	move.w	(pucky).w,d0
	move.w	Ypos(a3),d2				;Ypos into d2
	tst.w	d0						;check if d0 is 0
	bpl.w	.36						;branch if positive
	neg.w	d0						;make d0 negative
	neg.w	d2						;make d2 negative
	;puck side
.36
	sub.w	d0,d2					;sub d0 from d2 (equals how far puck is from player Ypos)
	cmp.w	#$A,d2					;check difference with A (10 decimal)
	blt.w	.38
	move.w	(a3),d0					;Xpos of player (gets here if player is between net and puck carrier)
	sub.w	(puckx).w,d0			;sub puckx from Xpos
	bpl.w	.37						;branch if positive difference
	neg.w	d0						;make d0 negative
	;|dx|
.37
	cmp.w	#$F,d0					;compare F (15 dec) with Xpos difference
	blt.w	.39						;branch if less than (within 15 pix in X direction)
	;exit (also the end of the code above)
.38
	rts
	;bit 5 of sflags6 clear or d0 < $F
.39
	btst	#5,(sflags6).w			;check if puckc is in the slot
	beq.w	check4check				;branch if not in slot
	move.b	checking(a3),d0
	ext.w	d0						;clear top byte of d0
	movem.l	d0/a3,-(sp)				;push to stack
	add.b	d0,d0					;add d0 to itself
	cmp.b	#$1E,d0					;compare max Chk to d0
	blt.w	.40						;branch if less
	move.b	#$1E,d0					;move 1E into d0
.40
	move.b	d0,checking(a3)
	bsr.w	check4check
	movem.l	(sp)+,d0/a3				;pop off stack
	move.b	d0,checking(a3)
	rts
	;skate to the puck (falls into check4check)
.41
	bsr.w	skatetoIntercept

check4check							;Check an opponent in front of a3.
	tst.w	position(a3)			;check if goalie
	bne.w	.1						;branch if not
	rts
.1
	btst	#pfjoycon,pflags(a3)	;a joystick player blocks the shot when CanBlock allows
	bne.w	.2
	jsr	(CanBlock).l
	beq.w	.2
	move.w	#SPAblock,d1
	bset	#3,(sflags10).w
	jsr	(SetSPA).l
	bset	#pfalock,pflags(a3)		;lock the animation
	rts
.2
	cmpi.w	#6,$24(a2)
	beq.w	.4
	move.w	Ypos(a3),d0
	btst	#pfgoal,pflags(a3)
	beq.w	.3
	neg.w	d0
.3
	cmp.w	#$76,d0
	bge.w	.4
.loop
	rts
.4
	move.w	#$28,d0
	tst.w	(puckc).w
	bmi.w	.7
	lea	assnum(a3),a0
	adda.w	(a0),a0
	addq.w	#2,a0
	cmpi.b	#$25,(a0)
	beq.s	.loop
	cmpi.b	#$27,(a0)
	beq.s	.loop
	cmpi.b	#2,(a0)
	bne.w	.7
	move.w	(a3),d0
	sub.w	(puckx).w,d0
	bpl.w	.5
	neg.w	d0
.5
	cmp.w	#$1E,d0
	bgt.w	.7
	move.w	Ypos(a3),d0
	sub.w	(pucky).w,d0
	bpl.w	.6
	neg.w	d0
.6
	cmp.w	#$1E,d0
	bgt.w	.7
	bra.w	.8
.7
	move.w	#$28,d0					;'('   ; start with 28 hex (40 decimal)
.8
	sub.b	checking(a3),d0
	tst.w	(OptPen).w				;check for penalties option
	beq.w	.9						;branch if not on
	asl.w	#1,d0					;mult by 2
.9
	bsr.w	randomd0				;RNG d0
	move.w	#6,d2
	cmpi.w	#1,(OptSkill).w
	beq.w	.10
	move.w	#3,d2
	cmpi.w	#0,(OptSkill).w
	beq.w	.10
	move.w	#1,d2
.10
	cmp.w	d2,d0
	bhi.w	rtss2					;exit if d0 higher than 6
	moveq	#5,d2					;move 5 into d2
	movea.w	#(SortCords-M68K_RAM),a0
	cmpi.w	#6,SCnum(a3)			;check if player on home team
	bge.w	.loop2					;branch if away
	adda.w	#$300,a0				;add if home (checks opposite team in loop)
.loop2
	tst.w	$34(a0)					;check if goalie
	beq.w	.13						;branch if goalie
	btst	#pfalock,$62(a0)		;check if locked in anim
	bne.w	.13						;branch if locked
	btst	#pf2fight,$63(a0)		;check if fighting
	bne.w	.13						;branch if fighting
	move.w	(a0),d0					;move Xpos into d0
	sub.w	(a3),d0					;sub a3 from a0
	cmp.w	#$1E,d0					;compare to 30 decimal
	bgt.w	.13						;branch if more than 30 decimal
	cmp.w	#$FFE2,d0				;compare to -30 decimal
	blt.w	.13						;branch if less than -30
	move.w	$14(a0),d1				;Ypos
	sub.w	Ypos(a3),d1				;subtract checker Ypos from d1
	cmp.w	#$1E,d1					;compare to 30 decimal
	bgt.w	.13						;branch if more
	cmp.w	#$FFE2,d1				;check with -30 decimal
	blt.w	.13						;branch if less
	bsr.w	vtoa					;determine direction
	move.w	facedir(a3),d1
	cmp.w	d1,d0
	beq.w	.12
	addq.w	#1,d0
	andi.w	#7,d0
	cmp.w	d1,d0
	beq.w	.11
	subq.w	#2,d0
	andi.w	#7,d0
	cmp.w	d1,d0
	bne.w	.13
.11
	bra.w	HoldplayerImpact
.12
	btst	#5,(sflags6).w			;check if puckc in slot
	bne.w	HoldplayerImpact		;branch if in slot
	move.w	(HVcount).l,d0			;move HVcounter into d0
	andi.w	#3,d0					;pass first 2 bits
	bne.w	burst					;throw check
	bra.w	HoldplayerImpact
.13
	adda.w	#SCstruct,a0			;move to next SCstruct
	dbf	d2,.loop2
	rts

asspassrec							;asstab entry: catch a pass.
	btst	#pfalock,pflags(a3)		;pfalock - animation lock
	bne.w	rtss2					;exit if locked
	btst	#gmclock,(gmode).w		;gmclock - check if clock running
	bne.w	donothing				;exit if clock stopped
	btst	#pfjoycon,pflags(a3)	;pfjoycon - joystick controlled?
	bne.w	assexit					;exit if controlled
	bclr	#pfna,pflags(a3)		;#pfna - clear new assignment
	beq.w	.nna
	bset	#pfdoff,pflags(a3)		;#pfdoff - set decceleration off
	move.b	#8,temp2+1(a3)			;move into temp2+1
	clr.b	temp2(a3)				;clear temp2 byte
	move.w	#$FFFE,temp4(a3)		;move into temp4
.nna
	tst.w	(puckc).w				;check if there is a puck carrier
	bpl.w	.exit					;exit if puck still in possession
	addq.w	#1,temp4(a3)			;add to temp4
	beq.w	.2						;branch if temp4 is zero
	bpl.w	.ex2					;branch if temp4 is positive
.2
	tst.w	(onetimerplayer).w
	bpl.w	.ex2
	tst.w	position(a3)			;test if goalie
	beq.w	.ex2					;exit if goalie
	move.w	d0,-(sp)				;push d0 on stack
	clr.w	temp4(a3)				;clear temp4
	move.w	#1,d0
	btst	#pfteam,pflags(a3)		;check if home or away
	beq.w	.3
	move.w	#2,d0					;away team
.3
	cmp.w	(cont1team).w,d0
	beq.w	.pop
	cmp.w	(cont2team).w,d0
	beq.w	.pop					;branch if so
	cmp.w	(cont3team).w,d0
	beq.w	.pop
	cmp.w	(cont4team).w,d0
	beq.w	.pop
	jsr	(PuckOnAttackHalf).l
	beq.w	.pop
	move.w	Ypos(a3),d0				;Ypos
	btst	#pfgoal,pflags(a3)		;pfgoal
	bne.w	.4						;branch if shooting at top
	neg.w	d0
.4
	cmp.w	#$76,d0
	blt.w	.5
	cmp.w	#$11E,d0
	bgt.w	.5
	bra.w	.6
.5
	move.w	#$64,d0
	jsr	(randomd0).l
	cmp.w	#$32,d0
	bgt.w	.pop
.6
	move.w	(sp)+,d0
	move.w	#$FFFF,(inputjoy).w
	bclr	#3,(GameFlags).w
	move.w	#$23,d0
	jmp	(assreplace).l
.pop
	move.w	(sp)+,d0
.ex2
	sub.b	d7,temp1(a3)
	bpl.w	rtss2
.exit
	bclr	#pfdoff,pflags(a3)
	bra.w	assexit
	move.w	temp3(a3),d0
	move.w	temp4(a3),d1
	lea	rtss2(pc),a0
	bra.w	skateto

assshoot							;asstab entry: computer shooting.
	btst	#pfalock,pflags(a3)		;pfalock - animation locked
	bne.w	rtss2
	bclr	#pfna,pflags(a3)		;clear pfna
	beq.w	.1
	jmp	(SetShotMode).l				;95 jmp (94 bra)
.1
	btst	#sfssdir,(sflags).w		;#sfssdir
	beq.w	assexit
	clr.w	d2
	sub.w	d7,temp2(a3)
	bpl.w	.2						;the bra.w ShotMode is now a shared jmp
	bset	#cbut,d2				;#cbut
.2
	jmp	(ShotMode).l

