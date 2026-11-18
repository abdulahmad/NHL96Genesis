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
	btst	#0,$77(a3)				;check hand of goalie
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
	cmp.w	#$1CA,d1
	bne.w	.8
	andi.w	#3,d3
	beq.w	.8
	cmpi.b	#$B,$74(a3)
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
									;Code the listing does not decode: kept as bytes
	dc.b	$08,$2B,$00,$03,$00,$62,$66,$00,$25,$38,$08,$38,$00,$00,$C3,$38
	dc.b	$66,$00,$25,$2E,$61,$00,$EF,$1A,$08,$AB,$00,$01,$00,$62,$67,$00
	dc.b	$00,$06,$42,$6B,$00,$40,$9F,$2B,$00,$40,$6A,$00,$00,$66,$10,$2B
	dc.b	$00,$6C,$67,$00,$00,$0E,$08,$38,$00,$06,$C3,$4A,$67,$00,$00,$04
	dc.b	$53,$00,$E4,$08,$17,$40,$00,$40,$4A,$78,$B7,$BE,$6A,$00,$24,$F2
	dc.b	$4A,$78,$B7,$88,$08,$2B,$00,$07,$00,$62,$67,$00,$00,$06,$0A,$3C
	dc.b	$00,$08,$6B,$00,$24,$DC,$32,$7C,$C7,$26,$45,$E9,$03,$9E,$08,$2B
	dc.b	$00,$06,$00,$62,$67,$00,$00,$04,$C3,$4A,$0C,$A9,$00,$00,$0E,$10
	dc.b	$00,$2A,$6D,$00,$24,$BC,$0C,$AA,$00,$00,$06,$40,$00,$2A,$6D,$00
	dc.b	$24,$B0,$60,$00,$23,$38

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
	cmp.w	$14(a0),d1				;compare Ypos of a0 player to d1 (Ypos puckc)
	bge.w	.9						;branch if d1 greater than or equal
	tst.w	$34(a0)					;check if goalie
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
									;Code the listing does not decode: kept as bytes
	dc.b	$08,$B8,$00,$02,$C3,$44,$66,$00,$00,$08,$08,$AB,$00,$01,$00,$64
	dc.b	$30,$38,$B7,$BE,$B0,$6B,$00,$52,$66,$00,$23,$12,$08,$38,$00,$02
	dc.b	$C3,$40,$67,$00,$00,$0C,$0C,$78,$00,$01,$C3,$7E,$6E,$00,$02,$A4
	dc.b	$08,$2B,$00,$01,$00,$64,$66,$00,$00,$22,$08,$38,$00,$02,$C3,$40
	dc.b	$66,$00,$00,$18,$4E,$B9,$00,$01,$7F,$7A,$67,$00,$00,$0E,$30,$3C
	dc.b	$00,$21,$61,$00,$22,$F4,$60,$00,$00,$02,$08,$2B,$00,$05,$00,$62
	dc.b	$66,$00,$77,$56,$08,$38,$00,$02,$C3,$40,$66,$00,$00,$0C,$08,$38
	dc.b	$00,$00,$C3,$38,$66,$00,$F2,$16,$08,$2B,$00,$03,$00,$62,$66,$00
	dc.b	$22,$AC,$08,$AB,$00,$01,$00,$62,$67,$00,$00,$84,$2F,$08,$20,$7C
	dc.b	$FF,$FF,$D2,$3A,$08,$2B,$00,$06,$00,$62,$67,$00,$00,$08,$20,$7C
	dc.b	$FF,$FF,$D2,$3C,$30,$AB,$00,$52,$20,$5F,$08,$2B,$00,$01,$00,$64
	dc.b	$67,$00,$00,$0C,$3F,$3C,$00,$01,$4E,$B9,$00,$08,$84,$70,$08,$2B
	dc.b	$00,$01,$00,$64,$67,$00,$00,$30,$48,$E7,$00,$20,$24,$7C,$FF,$FF
	dc.b	$C7,$26,$08,$2B,$00,$06,$00,$62,$67,$00,$00,$08,$24,$7C,$FF,$FF
	dc.b	$CA,$C4,$52,$6A,$03,$92,$06,$78,$00,$14,$B8,$B8,$06,$78,$00,$C8
	dc.b	$B8,$B2,$4C,$DF,$04,$00,$42,$6B,$00,$40,$37,$7C,$00,$08,$00,$42
	dc.b	$30,$39,$00,$C0,$00,$08,$02,$40,$00,$03,$37,$40,$00,$44,$9F,$2B
	dc.b	$00,$40,$6A,$00,$00,$AC,$17,$6B,$00,$6B,$00,$40,$4E,$B9,$00,$1D
	dc.b	$93,$52,$6B,$00,$00,$14,$08,$38,$00,$06,$C3,$4A,$67,$00,$00,$0E
	dc.b	$4A,$2B,$00,$40,$67,$00,$00,$06,$53,$2B,$00,$40,$08,$38,$00,$02
	dc.b	$C3,$40,$66,$00,$00,$68,$08,$38,$00,$00,$C3,$48,$66,$00,$00,$5E
	dc.b	$4E,$B9,$00,$01,$87,$D4,$61,$00,$01,$A4,$08,$38,$00,$00,$C3,$48
	dc.b	$66,$00,$00,$4A,$08,$38,$00,$02,$C3,$40,$66,$00,$00,$40,$08,$2B
	dc.b	$00,$01,$00,$64,$66,$00,$00,$2E,$30,$3C,$00,$01,$08,$2B,$00,$06
	dc.b	$00,$62,$67,$00,$00,$06,$30,$3C,$00,$02,$B0,$78,$C3,$90,$67,$00
	dc.b	$00,$14,$B0,$78,$C3,$92,$67,$00,$00,$0C,$08,$38,$00,$01,$B0,$53
	dc.b	$66,$00,$00,$1A,$61,$00,$01,$F6,$60,$00,$00,$12,$4E,$B9,$00,$1D
	dc.b	$8C,$F6,$66,$00,$00,$0C,$4E,$B9,$00,$00,$F4,$66,$61,$00,$03,$98
	dc.b	$70,$06,$D0,$6B,$00,$44,$41,$FA,$01,$0C,$08,$38,$00,$07,$C3,$3C
	dc.b	$67,$00,$00,$06,$30,$2B,$00,$34,$E5,$40,$32,$30,$00,$02,$30,$30
	dc.b	$00,$00,$08,$38,$00,$02,$C3,$40,$66,$00,$00,$0C,$08,$38,$00,$00
	dc.b	$C3,$48,$67,$00,$00,$12,$4E,$B9,$00,$1D,$8C,$6E,$0C,$38,$00,$80
	dc.b	$D8,$18,$67,$00,$00,$CE,$08,$2B,$00,$07,$00,$62,$66,$00,$00,$06
	dc.b	$44,$40,$44,$41,$41,$FA,$00,$1E,$08,$38,$00,$02,$C3,$40,$66,$00
	dc.b	$00,$0C,$08,$38,$00,$00,$C3,$48,$67,$00,$00,$06,$41,$FA,$00,$A4
	dc.b	$60,$00,$1D,$8C,$48,$80,$14,$2B,$00,$28,$48,$82,$D4,$78,$B7,$5E
	dc.b	$16,$2B,$00,$2A,$48,$83,$D6,$78,$B7,$72,$42,$78,$BF,$18,$78,$05
	dc.b	$30,$7C,$B0,$5E,$0C,$6B,$00,$06,$00,$52,$6C,$00,$00,$06,$D0,$FC
	dc.b	$03,$00,$12,$28,$00,$28,$48,$81,$D2,$50,$92,$42,$B2,$7C,$00,$14
	dc.b	$6E,$00,$00,$58,$B2,$7C,$FF,$EC,$6D,$00,$00,$50,$12,$28,$00,$2A
	dc.b	$48,$81,$D2,$68,$00,$14,$92,$43,$B2,$7C,$00,$14,$6E,$00,$00,$3C
	dc.b	$B2,$7C,$FF,$EC,$6D,$00,$00,$34,$52,$78,$BF,$18,$30,$13,$90,$50
	dc.b	$32,$2B,$00,$14,$92,$68,$00,$14,$61,$00,$20,$B2,$32,$2B,$00,$54
	dc.b	$0A,$41,$00,$04,$B2,$40,$66,$00,$00,$12,$32,$39,$00,$C0,$00,$08
	dc.b	$02,$41,$00,$01,$D0,$41,$02,$40,$00,$07,$D0,$FC,$00,$80,$51,$CC
	dc.b	$FF,$92,$4E,$75,$FF,$9C,$FF,$EC,$00,$64,$FF,$EC,$FF,$88,$00,$28
	dc.b	$00,$14,$00,$28,$00,$78,$00,$28,$FF,$EC,$00,$28,$FF,$D8,$01,$06
	dc.b	$00,$00,$00,$F2,$00,$14,$00,$FC,$00,$1E,$00,$FC,$08,$38,$00,$04
	dc.b	$C3,$4A,$66,$00,$74,$B4,$30,$38,$B7,$72,$08,$2B,$00,$07,$00,$62
	dc.b	$66,$00,$00,$04,$44,$40,$4A,$40,$6B,$00,$74,$9E,$B0,$7C,$00,$76
	dc.b	$6E,$00,$74,$96,$30,$39,$00,$C0,$00,$08,$02,$40,$00,$03,$66,$00
	dc.b	$74,$88,$08,$2B,$00,$03,$00,$63,$66,$00,$74,$7E,$34,$7C,$C7,$26
	dc.b	$43,$EA,$03,$9E,$08,$2B,$00,$06,$00,$62,$67,$00,$00,$04,$C5,$49
	dc.b	$61,$00,$4D,$FA,$B0,$7C,$0C,$00,$62,$00,$74,$5E,$61,$00,$14,$78
	dc.b	$61,$00,$77,$5E,$61,$00,$4C,$6A,$4E,$F9,$00,$00,$F4,$66

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
	;Code the listing does not decode: kept as bytes
	dc.b	$61,$D0,$66,$00,$00,$50,$4A,$78,$BF,$18,$67,$00,$00,$48,$30,$39
	dc.b	$00,$C0,$00,$08,$02,$40,$00,$03,$66,$00,$00,$3A,$30,$3C,$00,$76
	dc.b	$08,$2B,$00,$07,$00,$62,$67,$00,$00,$12,$30,$3C,$FF,$8A,$B0,$6B
	dc.b	$00,$14,$6D,$00,$00,$1A,$60,$00,$00,$0A,$B0,$6B,$00,$14,$6E,$00
	dc.b	$00,$0E,$08,$F8,$00,$03,$C3,$44,$4E,$F9,$00,$00,$F8,$F6,$4E,$F9
	dc.b	$00,$00,$F4,$66,$08,$2B,$00,$01,$00,$64,$67,$00,$00,$42,$30,$3C
	dc.b	$00,$1E,$4E,$B9,$00,$01,$B0,$A6,$06,$40,$00,$82,$B0,$78,$B7,$72
	dc.b	$6D,$00,$00,$10,$44,$40,$B0,$78,$B7,$72,$6E,$00,$00,$06,$60,$00
	dc.b	$00,$1E,$30,$3C,$00,$02,$4E,$B9,$00,$01,$B0,$9A,$D0,$6B,$00,$54
	dc.b	$02,$40,$00,$07,$37,$40,$00,$54,$4E,$F9,$00,$00,$F4,$66,$78,$20
	dc.b	$42,$41,$12,$2B,$00,$71,$E2,$49,$98,$01,$E9,$44,$32,$3C,$01,$1E
	dc.b	$08,$2B,$00,$07,$00,$62,$66,$00,$00,$04,$44,$41,$92,$78,$B7,$72
	dc.b	$30,$38,$B7,$5E,$44,$40,$48,$A7,$C0,$00,$C1,$C0,$C3,$C1,$D2,$80
	dc.b	$B2,$BC,$00,$00,$27,$10,$4C,$9F,$00,$03,$62,$00,$00,$74,$E8,$4C
	dc.b	$61,$00,$1E,$DE,$3A,$00,$76,$05,$32,$7C,$B0,$5E,$0C,$6B,$00,$06
	dc.b	$00,$52,$6C,$00,$00,$06,$D2,$FC,$03,$00,$4A,$69,$00,$34,$67,$00
	dc.b	$00,$2A,$08,$29,$00,$05,$00,$62,$66,$00,$00,$20,$30,$11,$90,$78
	dc.b	$B7,$5E,$32,$29,$00,$14,$92,$78,$B7,$72,$61,$00,$1E,$A4,$B0,$45
	dc.b	$66,$00,$00,$26,$E3,$44,$60,$00,$00,$20,$0C,$51,$00,$13,$6E,$00
	dc.b	$00,$16,$0C,$51,$FF,$ED,$6D,$00,$00,$0E,$08,$29,$00,$01,$00,$63
	dc.b	$67,$00,$00,$06,$42,$43,$78,$01,$D2,$FC,$00,$80,$51,$CB,$FF,$AC
	dc.b	$30,$04,$61,$00,$2B,$24,$08,$2B,$00,$00,$00,$71,$67,$00,$00,$0E
	dc.b	$B0,$7C,$00,$07,$6E,$00,$72,$B6,$60,$00,$00,$22,$0C,$78,$00,$51
	dc.b	$B7,$5E,$6E,$00,$00,$10,$0C,$78,$FF,$AF,$B7,$5E,$6D,$00,$00,$06
	dc.b	$04,$40,$00,$0A,$B0,$7C,$00,$08,$6E,$00,$72,$92,$30,$38,$B7,$72
	dc.b	$08,$2B,$00,$07,$00,$62,$66,$00,$00,$04,$44,$40,$4A,$40,$6B,$00
	dc.b	$72,$7C,$32,$3C,$01,$1E,$92,$40,$6B,$00,$72,$72,$08,$38,$00,$07
	dc.b	$C3,$3C,$66,$00,$72,$68,$60,$00,$FE,$CA,$4A,$78,$BF,$18,$66,$00
	dc.b	$00,$14,$70,$10,$D0,$2B,$00,$71,$61,$00,$2A,$AE,$B0,$7C,$00,$0C
	dc.b	$6E,$00,$72,$4A,$70,$06,$61,$00,$2A,$A0,$0C,$6B,$00,$06,$00,$52
	dc.b	$6D,$00,$00,$04,$5C,$40,$4A,$6B,$00,$34,$67,$00,$00,$2A,$0C,$78
	dc.b	$00,$28,$B7,$5E,$6E,$00,$00,$20,$0C,$78,$FF,$D8,$B7,$5E,$6D,$00
	dc.b	$00,$16,$0C,$78,$00,$E2,$B7,$72,$6E,$00,$72,$12,$0C,$78,$FF,$1E
	dc.b	$B7,$72,$6D,$00,$72,$08,$B0,$6B,$00,$52,$67,$00,$72,$00,$EF,$40
	dc.b	$30,$7C,$B0,$5E,$D0,$C0,$4A,$68,$00,$34,$6F,$00,$71,$F0,$08,$28
	dc.b	$00,$02,$00,$63,$66,$00,$71,$E6,$08,$28,$00,$05,$00,$62,$66,$00
	dc.b	$71,$DC,$30,$28,$00,$14,$32,$2B,$00,$14,$08,$2B,$00,$07,$00,$62
	dc.b	$66,$00,$00,$06,$44,$40,$44,$41,$08,$38,$00,$05,$C3,$38,$67,$00
	dc.b	$00,$18,$48,$A7,$C0,$00,$04,$40,$00,$76,$04,$41,$00,$76,$B1,$41
	dc.b	$4C,$9F,$00,$03,$6B,$00,$71,$A6,$B0,$7C,$00,$76,$6E,$00,$00,$0C
	dc.b	$90,$41,$B0,$7C,$FF,$F1,$6D,$00,$71,$94,$30,$10,$90,$78,$B7,$5E
	dc.b	$32,$28,$00,$14,$92,$78,$B7,$72,$48,$A7,$C0,$00,$61,$00,$1D,$22
	dc.b	$31,$C0,$BF,$0E,$4C,$9F,$00,$06,$C3,$C1,$C5,$C2,$D4,$81,$76,$05
	dc.b	$32,$7C,$B0,$5E,$0C,$6B,$00,$06,$00,$52,$6C,$00,$00,$06,$D2,$FC
	dc.b	$03,$00,$30,$11,$90,$78,$B7,$5E,$32,$29,$00,$14,$92,$78,$B7,$72
	dc.b	$48,$A7,$C0,$00,$C1,$C0,$C3,$C1,$D2,$80,$B2,$82,$4C,$9F,$00,$03
	dc.b	$62,$00,$00,$0E,$61,$00,$1C,$DA,$B0,$78,$BF,$0E,$67,$00,$71,$2E
	dc.b	$D2,$FC,$00,$80,$51,$CB,$FF,$CC,$4E,$B9,$00,$00,$F8,$F6,$4A,$6B
	dc.b	$00,$34,$67,$00,$71,$18,$58,$4F,$60,$00,$1C,$86

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
									;Code the listing does not decode: kept as bytes
	dc.b	$08,$B8,$00,$02,$C3,$44,$66,$00,$00,$08,$08,$AB,$00,$01,$00,$64
	dc.b	$30,$2B,$00,$52,$B0,$78,$B7,$BE,$66,$00,$00,$2C,$08,$2B,$00,$01
	dc.b	$00,$64,$66,$00,$00,$22,$08,$38,$00,$02,$C3,$40,$66,$00,$00,$18
	dc.b	$4E,$B9,$00,$01,$7F,$7A,$67,$00,$00,$0E,$30,$3C,$00,$22,$61,$00
	dc.b	$1B,$00,$60,$00,$00,$02,$08,$AB,$00,$01,$00,$62,$67,$00,$00,$7A
	dc.b	$2F,$08,$20,$7C,$FF,$FF,$D2,$3A,$08,$2B,$00,$06,$00,$62,$67,$00
	dc.b	$00,$08,$20,$7C,$FF,$FF,$D2,$3C,$30,$AB,$00,$52,$20,$5F,$08,$2B
	dc.b	$00,$01,$00,$64,$67,$00,$00,$0C,$3F,$3C,$00,$01,$4E,$B9,$00,$08
	dc.b	$84,$70,$08,$2B,$00,$01,$00,$64,$67,$00,$00,$30,$48,$E7,$00,$20
	dc.b	$24,$7C,$FF,$FF,$C7,$26,$08,$2B,$00,$06,$00,$62,$67,$00,$00,$08
	dc.b	$24,$7C,$FF,$FF,$CA,$C4,$52,$6A,$03,$92,$06,$78,$00,$14,$B8,$B8
	dc.b	$06,$78,$00,$C8,$B8,$B2,$4C,$DF,$04,$00,$42,$6B,$00,$44,$37,$7C
	dc.b	$00,$08,$00,$42,$42,$6B,$00,$40,$4A,$78,$B7,$BE,$6B,$00,$00,$20
	dc.b	$2F,$08,$20,$7C,$FF,$FF,$D2,$3A,$0C,$78,$00,$05,$B7,$BE,$6F,$00
	dc.b	$00,$08,$20,$7C,$FF,$FF,$D2,$3C,$30,$B8,$B7,$BE,$20,$5F,$32,$2B
	dc.b	$00,$52,$B2,$78,$B7,$BE,$66,$00,$00,$18,$4A,$6B,$00,$34,$67,$00
	dc.b	$EC,$24,$70,$10,$08,$2B,$00,$03,$00,$62,$67,$00,$1A,$2A,$4E,$75
	dc.b	$9F,$2B,$00,$40,$6A,$00,$01,$9C,$17,$6B,$00,$6B,$00,$40,$4E,$B9
	dc.b	$00,$1D,$93,$52,$6B,$00,$00,$14,$08,$38,$00,$06,$C3,$4A,$67,$00
	dc.b	$00,$0E,$4A,$2B,$00,$40,$67,$00,$00,$06,$53,$2B,$00,$40,$08,$38
	dc.b	$00,$05,$C3,$46,$67,$00,$00,$3A,$32,$38,$B7,$BE,$B2,$7C,$00,$05
	dc.b	$6E,$00,$00,$26,$08,$2B,$00,$06,$00,$62,$67,$00,$00,$24,$12,$2B
	dc.b	$00,$40,$48,$81,$E2,$41,$17,$41,$00,$40,$66,$00,$00,$14,$17,$7C
	dc.b	$00,$01,$00,$40,$60,$00,$00,$0A,$08,$2B,$00,$06,$00,$62,$67,$DE
	dc.b	$42,$AA,$00,$2A,$32,$38,$B7,$BE,$6B,$00,$00,$1C,$EF,$41,$32,$7C
	dc.b	$B0,$5E,$D2,$C1,$10,$29,$00,$62,$12,$2B,$00,$62,$B1,$01,$08,$01
	dc.b	$00,$06,$67,$00,$00,$84,$74,$FF,$78,$05,$30,$6A,$00,$22,$4A,$68
	dc.b	$00,$34,$6F,$00,$00,$62,$4A,$28,$00,$5E,$66,$00,$00,$5A,$08,$28
	dc.b	$00,$02,$00,$63,$66,$00,$00,$50,$30,$28,$00,$52,$B0,$78,$D2,$3E
	dc.b	$67,$00,$00,$44,$30,$28,$00,$36,$0C,$30,$00,$13,$00,$38,$67,$00
	dc.b	$00,$36,$2F,$08,$61,$00,$19,$D8,$D0,$50,$90,$78,$B7,$5E,$D2,$68
	dc.b	$00,$14,$92,$78,$B7,$72,$36,$38,$B7,$86,$EC,$43,$90,$43,$36,$38
	dc.b	$B7,$88,$EC,$43,$92,$43,$C1,$C0,$C3,$C1,$D0,$81,$B0,$82,$62,$00
	dc.b	$00,$06,$24,$00,$32,$48,$D0,$FC,$00,$80,$51,$CC,$FF,$92,$4A,$82
	dc.b	$6B,$00,$00,$3E,$25,$42,$00,$2A,$B6,$C9,$67,$00,$00,$34,$08,$38
	dc.b	$00,$00,$C3,$38,$66,$00,$00,$2A,$08,$29,$00,$02,$00,$63,$66,$00
	dc.b	$00,$20,$08,$29,$00,$03,$00,$64,$66,$00,$00,$16,$C3,$4B,$08,$AB
	dc.b	$00,$00,$00,$62,$70,$11,$61,$00,$18,$DE,$C3,$4B,$60,$00,$18,$C6
	dc.b	$08,$2B,$00,$05,$00,$62,$66,$00,$6D,$48,$72,$02,$B4,$7C,$01,$90
	dc.b	$62,$00,$00,$0E,$55,$41,$0C,$6B,$00,$02,$00,$34,$63,$00,$00,$34
	dc.b	$08,$38,$00,$05,$C3,$3C,$67,$00,$00,$0E,$55,$41,$61,$00,$F8,$E8
	dc.b	$66,$00,$00,$04,$58,$41,$30,$3C,$00,$28,$90,$2B,$00,$76,$E3,$60
	dc.b	$61,$00,$25,$6A,$B0,$7C,$00,$02,$62,$00,$00,$08,$37,$7C,$00,$F0
	dc.b	$00,$44,$08,$2B,$00,$05,$00,$62,$66,$00,$6C,$F6,$08,$38,$00,$02
	dc.b	$C3,$40,$67,$00,$00,$0C,$08,$38,$00,$05,$C3,$40,$67,$00,$00,$0C
	dc.b	$08,$38,$00,$00,$C3,$38,$66,$00,$E7,$AC,$08,$2B,$00,$03,$00,$62
	dc.b	$66,$00,$6C,$CE,$08,$2A,$00,$02,$00,$30,$66,$00,$00,$A0,$4A,$78
	dc.b	$B7,$BE,$6B,$00,$01,$A0,$4A,$6B,$00,$34,$67,$00,$00,$84,$48,$E7
	dc.b	$80,$80,$20,$7C,$FF,$FF,$B0,$5E,$30,$38,$B7,$BE,$EF,$40,$D0,$C0
	dc.b	$4A,$68,$00,$34,$66,$00,$00,$18,$4C,$DF,$01,$01,$42,$40,$42,$41
	dc.b	$41,$FA,$6C,$8E,$4E,$F9,$00,$01,$A0,$50,$60,$00,$00,$1A,$30,$38
	dc.b	$B7,$86,$80,$78,$B7,$88,$4C,$DF,$01,$01,$66,$00,$00,$0A,$61,$00
	dc.b	$01,$58,$60,$00,$01,$50,$48,$A7,$80,$00,$30,$13,$90,$78,$B7,$5E
	dc.b	$6A,$00,$00,$04,$44,$40,$B0,$7C,$00,$3C,$4C,$9F,$00,$01,$6E,$00
	dc.b	$01,$34,$48,$A7,$80,$00,$30,$2B,$00,$14,$90,$78,$B7,$72,$6A,$00
	dc.b	$00,$04,$44,$40,$B0,$7C,$00,$3C,$4C,$9F,$00,$01,$6E,$00,$01,$16
	dc.b	$9F,$6B,$00,$44,$6A,$00,$01,$0E,$42,$6B,$00,$44,$61,$00,$15,$E8
	dc.b	$48,$A7,$C0,$00,$44,$40,$44,$41,$06,$41,$01,$0A,$08,$2B,$00,$07
	dc.b	$00,$62,$67,$00,$00,$06,$04,$41,$02,$14,$E2,$40,$E2,$41,$D0,$5F
	dc.b	$D2,$5F,$08,$2A,$00,$02,$00,$30,$67,$00,$00,$28,$08,$2B,$00,$07
	dc.b	$00,$62,$67,$00,$00,$12,$B2,$7C,$00,$71,$6D,$00,$00,$16,$32,$3C
	dc.b	$00,$62,$60,$00,$00,$0E,$B2,$7C,$FF,$8F,$6E,$00,$00,$06,$32,$3C
	dc.b	$FF,$9E,$08,$38,$00,$05,$C3,$46,$67,$00,$00,$32,$11,$EB,$00,$6A
	dc.b	$BF,$52,$5C,$2B,$00,$6A,$54,$2B,$00,$6A,$0C,$2B,$00,$1E,$00,$6A
	dc.b	$6F,$00,$00,$08,$17,$7C,$00,$1E,$00,$6A,$41,$FA,$6B,$A4,$61,$00
	dc.b	$13,$A6,$17,$78,$BF,$52,$00,$6A,$60,$00,$00,$0A,$41,$FA,$6B,$92
	dc.b	$61,$00,$13,$94,$08,$38,$00,$05,$C3,$46,$67,$00,$00,$34,$30,$38
	dc.b	$B7,$72,$34,$2B,$00,$14,$4A,$40,$6A,$00,$00,$06,$44,$40,$44,$42
	dc.b	$94,$40,$B4,$7C,$00,$0A,$6D,$00,$00,$16,$30,$13,$90,$78,$B7,$5E
	dc.b	$6A,$00,$00,$04,$44,$40,$B0,$7C,$00,$0F,$6D,$00,$00,$04,$4E,$75
	dc.b	$08,$38,$00,$05,$C3,$46,$67,$00,$00,$30,$10,$2B,$00,$76,$48,$80
	dc.b	$48,$E7,$80,$10,$D0,$00,$B0,$3C,$00,$1E,$6D,$00,$00,$06,$10,$3C
	dc.b	$00,$1E,$17,$40,$00,$76,$61,$00,$00,$10,$4C,$DF,$08,$01,$17,$40
	dc.b	$00,$76,$4E,$75,$61,$00,$15,$1A

check4check							;Check an opponent in front of a3.
									;Code the listing does not decode: kept as bytes
	dc.b	$4A,$6B,$00,$34,$66,$00,$00,$04,$4E,$75,$08,$2B,$00,$03,$00,$62
	dc.b	$66,$00,$00,$24,$4E,$B9,$00,$1D,$98,$EE,$67,$00,$00,$1A,$32,$3C
	dc.b	$09,$9A,$08,$F8,$00,$03,$C3,$52,$4E,$B9,$00,$01,$A6,$14,$08,$EB
	dc.b	$00,$05,$00,$62,$4E,$75,$0C,$6A,$00,$06,$00,$24,$67,$00,$00,$1C
	dc.b	$30,$2B,$00,$14,$08,$2B,$00,$07,$00,$62,$67,$00,$00,$04,$44,$40
	dc.b	$B0,$7C,$00,$76,$6C,$00,$00,$04,$4E,$75,$30,$3C,$00,$28,$4A,$78
	dc.b	$B7,$BE,$6B,$00,$00,$4C,$41,$EB,$00,$36,$D0,$D0,$54,$48,$0C,$10
	dc.b	$00,$25,$67,$E4,$0C,$10,$00,$27,$67,$DE,$0C,$10,$00,$02,$66,$00
	dc.b	$00,$30,$30,$13,$90,$78,$B7,$5E,$6A,$00,$00,$04,$44,$40,$B0,$7C
	dc.b	$00,$1E,$6E,$00,$00,$1C,$30,$2B,$00,$14,$90,$78,$B7,$72,$6A,$00
	dc.b	$00,$04,$44,$40,$B0,$7C,$00,$1E,$6E,$00,$00,$06,$60,$00,$00,$06
	dc.b	$30,$3C,$00,$28,$90,$2B,$00,$76,$4A,$78,$D2,$62,$67,$00,$00,$04
	dc.b	$E3,$40,$61,$00,$22,$B0,$34,$3C,$00,$06,$0C,$78,$00,$01,$D2,$68
	dc.b	$67,$00,$00,$14,$34,$3C,$00,$03,$0C,$78,$00,$00,$D2,$68,$67,$00
	dc.b	$00,$06,$34,$3C,$00,$01,$B0,$42,$62,$00,$6A,$2E,$74,$05,$30,$7C
	dc.b	$B0,$5E,$0C,$6B,$00,$06,$00,$52,$6C,$00,$00,$06,$D0,$FC,$03,$00
	dc.b	$4A,$68,$00,$34,$67,$00,$00,$88,$08,$28,$00,$05,$00,$62,$66,$00
	dc.b	$00,$7E,$08,$28,$00,$00,$00,$63,$66,$00,$00,$74,$30,$10,$90,$53
	dc.b	$B0,$7C,$00,$1E,$6E,$00,$00,$68,$B0,$7C,$FF,$E2,$6D,$00,$00,$60
	dc.b	$32,$28,$00,$14,$92,$6B,$00,$14,$B2,$7C,$00,$1E,$6E,$00,$00,$50
	dc.b	$B2,$7C,$FF,$E2,$6D,$00,$00,$48,$61,$00,$15,$72,$32,$2B,$00,$54
	dc.b	$B0,$41,$67,$00,$00,$1E,$52,$40,$02,$40,$00,$07,$B0,$41,$67,$00
	dc.b	$00,$0E,$55,$40,$02,$40,$00,$07,$B0,$41,$66,$00,$00,$22,$60,$00
	dc.b	$DB,$04,$08,$38,$00,$05,$C3,$46,$66,$00,$DA,$FA,$30,$39,$00,$C0
	dc.b	$00,$08,$02,$40,$00,$03,$66,$00,$DA,$7A,$60,$00,$DA,$E8,$D0,$FC
	dc.b	$00,$80,$51,$CA,$FF,$6C,$4E,$75

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
	move.b	#8,$43(a3)				;move into temp2+1
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

