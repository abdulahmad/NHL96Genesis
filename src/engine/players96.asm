;	Who is on the ice. setpersonel fills the ice from the line, setplayer brings
;	one player on, and ClampNibble keeps a rating in range.

setpersonel							;Put team a2 on the ice: the players of PlList (SetPlList) with setplayer
	movem.l	d0-d5/a0-a4,-(sp)
	btst	#7,(GameFlags).w
	beq.w	.0
	jsr	(SetSeasonInjuries).l
.0
	movea.w	$22(a2),a3
	moveq	#5,d4
.1
	st	$60(a3)
	st	$61(a3)
	adda.w	#$80,a3
	dbf	d4,.1
	bsr.w	SetPlList
	moveq	#5,d4
	movea.w	#(PlList-M68K_RAM),a4
.2
	clr.w	d5
	move.b	(a4,d4.w),d5
	beq.w	.4
	subq.w	#1,d5
	moveq	#5,d3
	movea.w	$22(a2),a3
	suba.w	#$80,a3
.3
	adda.w	#$80,a3
	cmp.b	$67(a3),d5
	dbeq	d3,.3
	bne.w	.4
	move.b	6(a4,d4.w),$60(a3)
	move.b	d5,$61(a3)
	clr.b	(a4,d4.w)
.4
	dbf	d4,.2
	moveq	#5,d4
	movea.w	#(PlList-M68K_RAM),a4
.5
	clr.w	d5
	move.b	(a4,d4.w),d5
	beq.w	.8
	subq.w	#1,d5
	moveq	#5,d3
	movea.w	$22(a2),a3
	suba.w	#$80,a3
.6
	adda.w	#$80,a3
	tst.b	$61(a3)
	dbmi	d3,.6
	bpl.w	.7
	movea.w	a3,a0
.7
	tst.w	$34(a3)
	dbpl	d3,.6
	move.b	6(a4,d4.w),$60(a0)
	move.b	d5,$61(a0)
	clr.b	(a4,d4.w)
.8
	dbf	d4,.5
	movem.l	(sp)+,d0-d5/a0-a4
	rts

SetPlList							;Create PlList of players who we want on the ice now. a2 = team struct.
									;Takes the current line (tmline) by
									;priolist; an unavailable player is replaced from sublist, else by roster
									;order (GetPlayerCount)
	movea.w	#(PlList-M68K_RAM),a4
	clr.l	(a4)					;clear 6 bytes (PlList)
	clr.w	4(a4)
	movea.l	#priolist,a0			;priority of positions
	tst.w	$26(a2)
	bpl.w	.0
	addq.w	#1,a0					;add 1 to a0
.0
	lea	$184(a2),a1
	move.w	$16(a2),d0
	asl.w	#3,d0					;mult by 8
	adda.w	d0,a1					;add to a1 to set a1 to currently selected line
	move.w	$24(a2),d4
	bra.w	.next
.1
	clr.w	d5
	move.b	(a0,d4.w),d5
	move.b	(a1,d5.w),(a4,d4.w)
	move.b	d5,6(a4,d4.w)
	bne.w	.next
	moveq	#1,d3
	add.w	$26(a2),d3
	move.b	d3,(a4,d4.w)
.next
	dbf	d4,.1
	moveq	#5,d4					;now check to see if player is available
.3
	move.b	(a4,d4.w),d3
	beq.w	.next1
	ext.w	d3
	subq.w	#1,d3
	add.w	d3,d3
	cmpi.w	#$FFFD,$6C(a2,d3.w)
	beq.w	.4
	cmpi.w	#$FFFC,$6C(a2,d3.w)
	beq.w	.4
	tst.w	$6C(a2,d3.w)
	ble.w	.next1
.4
	lea	$184(a2),a1
	move.b	6(a4,d4.w),d0			;move 6+a4+d4 into d0 (previous d5)
	ext.w	d0						;extend d0
	asl.w	#1,d0					;mult by 2
	movea.l	#sublist,a0				;move sublist into a0
	adda.w	(a0,d0.w),a0
.s1
	clr.w	d0
	move.b	(a0)+,d0
	bmi.w	.error
	move.b	(a1,d0.w),d0
	bsr.w	TryAddPlayerToList
	beq.s	.s1
.next1
	dbf	d4,.3
	rts
.error
	jsr	(GetPlayerCount).l			;then try the players from d0 down
	move.w	d0,d3
.try
	move.w	d3,d0
	subq.w	#1,d3
	bmi.s	.next1
	bsr.w	TryAddPlayerToList
	beq.s	.try
	bra.s	.next1

TryAddPlayerToList					;d0 = player number (1 based), d4 = PlList slot. Put d0 in the slot if he
									;is on the bench and not in PlList
									;yet (eq when taken)
	move.w	d0,d1
	subq.w	#1,d0
	add.w	d0,d0
	tst.w	$6C(a2,d0.w)
	bgt.w	.no
	cmpi.w	#$FFFD,$6C(a2,d0.w)
	beq.w	.no
	cmpi.w	#$FFFC,$6C(a2,d0.w)
	beq.w	.no
	moveq	#5,d0
.s2
	cmp.b	(a4,d0.w),d1
	dbeq	d0,.s2
	beq.w	.no
	move.b	d1,(a4,d4.w)
	rts
.no
	clr.w	d1
	rts

SetupPenaltyShot					;Penalty shot for team a2: the shooter plays center, the goalie stays, the
									;other players unavailable.
									;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$FC,$F0,$36,$6A,$00,$22,$78,$05,$30,$2B,$00,$52,$B0,$78
	dc.b	$D2,$D4,$67,$00,$00,$1C,$B0,$78,$D2,$D6,$67,$00,$00,$2E,$08,$EB
	dc.b	$00,$02,$00,$63,$30,$3C,$00,$20,$61,$00,$A6,$AA,$60,$00,$00,$38
	dc.b	$61,$00,$01,$20,$11,$EB,$00,$61,$C3,$82,$17,$78,$D2,$D9,$00,$61
	dc.b	$37,$7C,$00,$04,$00,$34,$60,$00,$00,$0A,$61,$00,$01,$06,$42,$6B
	dc.b	$00,$34,$42,$43,$16,$2B,$00,$61,$D6,$43,$35,$BC,$FF,$FF,$30,$6C
	dc.b	$E2,$4B,$61,$00,$01,$36,$50,$EB,$00,$61,$50,$EB,$00,$60,$D6,$FC
	dc.b	$00,$80,$51,$CC,$FF,$96,$4C,$DF,$0F,$3F,$4E,$75

forcepldata							;Force the player data.
									;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$F8,$F0,$36,$6A,$00,$22,$78,$05,$10,$2B,$00,$60,$48,$80
	dc.b	$4A,$6B,$00,$34,$66,$00,$00,$16,$4A,$40,$67,$00,$00,$10,$3F,$2B
	dc.b	$00,$52,$37,$7C,$00,$0F,$00,$52,$37,$5F,$00,$52,$37,$40,$00,$34
	dc.b	$6B,$00,$00,$2A,$61,$00,$00,$A0,$0C,$6B,$00,$04,$00,$34,$66,$00
	dc.b	$00,$08,$70,$11,$61,$00,$A6,$08,$42,$43,$16,$2B,$00,$61,$D6,$43
	dc.b	$35,$BC,$FF,$FF,$30,$6C,$E2,$4B,$61,$00,$00,$C4,$50,$EB,$00,$61
	dc.b	$50,$EB,$00,$60,$D6,$FC,$00,$80,$51,$CC,$FF,$A0,$4C,$DF,$0F,$1F
	dc.b	$4E,$75

ResetBench							;Remove all players from penalty box / put all players on their own bench
									;(not the injured, -3 / -4). Counts
									;the players left in the box in PBnum (home in the high nibble)
	clr.b	(PBnum).w				;PBnum = HV00
	moveq	#$10,d1
	movea.w	#(tmstruct-M68K_RAM),a0
	bsr.w	.rb
	moveq	#1,d1
	adda.w	#$39E,a0				;change to Away Team
.rb
	moveq	#$36,d0					;$32 = (MaxRos-1)*2 = 50 decimal
.rb1
	add.b	d1,(PBnum).w
	tst.w	$6C(a0,d0.w)			;check tmpdst
	ble.w	.cont
	btst	#4,$6C(a0,d0.w)			;test 3rd bit in tmpdst (4 decimal)
	beq.w	.next
	move.w	$6C(a0,d0.w),d2			;move tmpdst into d2
	andi.w	#$7FF,d2				;mask 7FF with d2. Passes lowest 11 bits
	bne.w	.next
	sub.b	d1,(PBnum).w
	bra.w	.next
.cont
	sub.b	d1,(PBnum).w
	cmpi.w	#$FFFD,$6C(a0,d0.w)		;compare -4 with tmpdst
	beq.w	.next
	cmpi.w	#$FFFC,$6C(a0,d0.w)
	beq.w	.next
	move.w	#$FFFE,$6C(a0,d0.w)		;move -2 into tmpdst
.next
	subq.w	#2,d0
	bpl.s	.rb1
	rts

AssignByPosition					;assreplace player a3 with the assignment of his position
	move.w	position(a3),d0
	bmi.w	rtss2
	st	$65(a3)
	lea	PosAssignTable(pc),a0
	move.b	(a0,d0.w),d0
	bra.w	assreplace

PosAssignTable						;Assignment byte for each position
	dc.b	$0E,$02,$02,$03,$05,$03,$05,$FF

AssignBySavedPos					;assreplace from the saved index at $65(a3), or from the position
	move.w	position(a3),d0
	bmi.w	rtss2
	tst.b	$65(a3)
	bmi.w	.0
	move.b	$65(a3),d0
.0
	lea	PosAssignTable2(pc),a0
	move.b	(a0,d0.w),d0
	bra.w	assreplace

PosAssignTable2						;Same assignment bytes as PosAssignTable
	dc.b	$0E,$02,$02,$03,$05,$03,$05,$FF

setplayer							;Bring player onto the ice and set his attributes. d3 = offset of player
									;on roster, a3 = sortcord of player.
									;Reads the roster bytes through AttributeCalc (attribute number in
									;TempWord2), adds the PP / PK, home / away and third period bonuses and
									;clamps them (ClampNibble).
	st	$65(a3)
	bclr	#6,$63(a3)
	movea.w	#(tmstruct-M68K_RAM),a0	;Start of Team Struct
	btst	#6,$62(a3)
	beq.w	.0
	adda.w	#$39E,a0
.0
	move.b	d3,$67(a3)
	moveq	#$A,d0
	ext.w	d3
	add.w	d3,d3					;= asl #1,d3. Accomplishes the same. Doubles d3
	move.w	$6C(a0,d3.w),d1			;move tmpdst(a0, d3) into d1
	bpl.w	.1
	moveq	#9,d0
	cmp.w	#$FFFE,d1				;-2 in this case
	bne.w	.nda
.1
	bsr.w	assinsert
	bclr	#5,$62(a3)
	clr.w	$58(a3)
.nda
	move.w	#$FFFF,$6C(a0,d3.w)		;clear out temp space
	lsr.w	#1,d3					;shift d3 back to its original value
	move.l	a0,-(sp)
	movea.l	$1E(a0),a0				;Offset 1E from Team Struct = The address where the team's data is stored
									;(roster, etc)
	adda.w	8(a0),a0
	clr.l	(PPBonus).w				;Clears all bonuses
	tst.w	$34(a3)					;check if goalie
	beq.w	.2
	btst	#sf2pwrplay,(sflags2).w	;might be checking for a PP
	beq.w	.habonus
	bsr.w	chkpk2
	beq.w	.pk
	move.b	1(a0),(PPBonus).w		;moves PP/PK byte into PPBonus
	andi.b	#$F,(PPBonus).w			;passes lower nibble of PP/PK byte (bug)
	bra.w	.habonus
.pk
	move.b	1(a0),d0				;moves PP/PK byte into d0
	lsr.b	#4,d0					;shifts d0.b 4 places, to remove the lower nibble
	neg.b	d0						;switches value to negative (because its a PK, its negative bonus)
	move.b	d0,(PPBonus+1).w		;move d0 into PKBonus
.habonus
	move.b	2(a0),d0				;This is location of Home/Away adv
	andi.b	#$F,d0					;pass the lower nibble (Away) to d0
	neg.b	d0						;make d0 negative (away disadvantage)
	btst	#6,$62(a3)
	bne.w	.3rdperbonuscheck
	move.b	2(a0),d0				;player is home, move Home/Away byte back in to d0
	lsr.b	#4,d0					;Shift d0 4 places right, to move upper nibble into d0
.3rdperbonuscheck
	move.b	d0,(PPBonus+3).w		;move d0 into HA bonus
	cmpi.w	#2,(gsp).w				;Check if period is 3rd or OT
	blt.w	.2
	bgt.w	.6
	jsr	(GetPeriodTime).l
	lsr.w	#1,d0					;divide by 2 (5 min length = 2:30)
	cmp.w	(gameclock).w,d0		;compare to game clock
	bgt.w	.2
.6
	move.w	(HmGoals).w,d0
	sub.w	(AwGoals).w,d0
	beq.w	.8
	btst	#6,$62(a3)
	beq.w	.home
	eori	#8,ccr					;If Aw team, checks if N flag is set from HmGoals-AwGoals.
.home
	bpl.w	.2
.8
	move.b	#2,(PPBonus+2).w		;move 2 into 3rd Per Bonus
.2
	movea.l	(sp)+,a0
	movem.l	d0/d7/a1,-(sp)
	move.w	$28(a0),d7
	move.w	d3,d0
	jsr	(GetRosterName).l
	jsr	(GetJerseyNumber).l
	adda.w	(a1),a1
	movea.l	a1,a0
	movem.l	(sp)+,d0/d7/a1
	move.b	(jerseynum+1).w,$70(a3)
	move.b	1(a0),d3				;move Wgt/Agl byte to d3
	andi.w	#$F0,d3					;Mask Wgt nibble
	lsr.w	#1,d3					;shift d3 1 bit right (This is taking Wgt and mult by 8)
	move.b	d3,$68(a3)
	move.b	1(a0),d3				;move Wgt/Agl byte to d3
	andi.b	#$F,d3					;mask Agl nibble
	move.w	#3,(TempWord2).w		;TempWord2 = 3
	jsr	(AttributeCalc).l			;attribute math and add hot/cold
	move.b	d3,$69(a3)
	move.b	2(a0),d3				;load Spd/OfA byte to d3
	lsr.b	#4,d3					;remove OfA nibble by shifting 4 bits right, moving Spd into lower nibble
	move.w	#4,(TempWord2).w		;TempWord2 = 4
	jsr	(AttributeCalc).l
	move.b	d3,$6A(a3)
	move.b	2(a0),d3				;move Spd/OfA byte to d3
	andi.b	#$F,d3
	move.w	#5,(TempWord2).w		;TempWord2 = 5
	jsr	(AttributeCalc).l
	add.b	(PPBonus).w,d3			;add Bonsuses to OfA
	add.b	(PPBonus+1).w,d3
	add.b	(PPBonus+3).w,d3
	add.b	(PPBonus+2).w,d3
	bsr.w	ClampNibble
	lsr.b	#1,d3					;shift right 1 bit (divide by 2)
	eori.b	#$F,d3					;XOR d3 with F
	addi.b	#$F,d3					;add F to d3
	lsr.b	#1,d3					;divide by 2
	move.b	d3,$6B(a3)
	move.b	3(a0),d3				;move DfA/ShP byte to d3
	lsr.b	#4,d3					;see above
	move.w	#6,(TempWord2).w
	jsr	(AttributeCalc).l
	add.b	(PPBonus+3).w,d3
	bsr.w	ClampNibble
	lsr.b	#1,d3
	eori.b	#$F,d3
	addi.b	#$F,d3
	lsr.b	#1,d3
	move.b	d3,$6C(a3)
	move.b	3(a0),$6D(a3)
	andi.b	#$F,$6D(a3)
	move.b	$6D(a3),d3
	move.w	#7,(TempWord2).w
	jsr	(AttributeCalc).l
	move.b	d3,$6D(a3)
	move.b	4(a0),d3				;move Chk/Hnd byte into d3
	lsr.b	#4,d3
	move.w	#8,(TempWord2).w
	jsr	(AttributeCalc).l
	add.b	(PPBonus+2).w,d3
	bsr.w	ClampNibble
	move.b	d3,$76(a3)
	bclr	#3,4(a3)
	move.b	4(a0),$77(a3)
	andi.b	#1,$77(a3)
	eori.b	#1,$77(a3)
	bne.w	.3
	bset	#3,4(a3)
.3
	move.b	4(a0),d3
	tst.w	$34(a3)
	bne.w	.4
	move.b	5(a0),d3
	lsr.b	#3,d3
.4
	andi.b	#$FE,d3
	or.b	d3,$77(a3)
	clr.b	$75(a3)
	tst.w	$34(a3)
	beq.w	.5
	move.b	7(a0),d3
	andi.b	#$F,d3
	cmp.b	#6,d3
	ble.w	.5
	subq.w	#6,d3
	move.b	d3,$75(a3)
.5
	move.b	5(a0),d3				;move Pas/Agr byte into d3
	lsr.b	#4,d3
	move.w	#$A,(TempWord2).w
	jsr	(AttributeCalc).l
	add.b	(PPBonus).w,d3
	add.b	(PPBonus+1).w,d3
	add.b	(PPBonus+3).w,d3
	bsr.w	ClampNibble
	move.b	d3,$72(a3)
	move.b	5(a0),d3
	andi.b	#$F,d3
	move.w	#$B,(TempWord2).w
	jsr	(AttributeCalc).l
	add.b	(PPBonus).w,d3
	add.b	(PPBonus+1).w,d3
	add.b	(PPBonus+3).w,d3
	bsr.w	ClampNibble
	move.b	d3,$6E(a3)
	move.b	6(a0),d3
	lsr.b	#4,d3
	move.w	#$C,(TempWord2).w
	jsr	(AttributeCalc).l
	move.b	d3,$73(a3)
	move.b	6(a0),d3
	andi.b	#$F,d3
	move.w	#$D,(TempWord2).w
	jsr	(AttributeCalc).l
	add.b	(PPBonus+2).w,d3
	add.b	(PPBonus+2).w,d3
	bsr.w	ClampNibble
	move.b	d3,$71(a3)
	move.b	7(a0),d3				;move Pas/Agr byte into d3
	lsr.b	#4,d3
	move.w	#$E,(TempWord2).w
	jsr	(AttributeCalc).l
	add.b	(PPBonus).w,d3
	add.b	(PPBonus+3).w,d3
	bsr.w	ClampNibble
	move.b	d3,$6F(a3)
	move.b	7(a0),d3
	andi.b	#$F,d3
	cmp.b	#6,d3
	ble.w	.7
	subq.b	#6,d3
.7
	move.w	#$F,(TempWord2).w
	jsr	(AttributeCalc).l
	move.b	d3,$74(a3)
	andi.b	#$F,$74(a3)
	rts

ClampNibble							;Clamp byte d3 to 0-$1E. Called by setplayer
	tst.b	d3						;test if d3 is zero or higher
	bpl.w	.pos
	clr.w	d3						;if negative, clear
.pos
	cmp.b	#$1E,d3					;compare upper limit
	ble.w	.withinlimits
	move.w	#$1E,d3					;if higher, set to 1E
.withinlimits
	rts

