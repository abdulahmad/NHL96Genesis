;	The crowd meter, the hot and cold players, the team records and the
;	attribute weights.

PuckOnAttackHalf	;d0 = 1 when the puck is on the half of the goal player a3 shoots at, else 0 (the code after the bra is never
	;used). Called from doinput and asspassrec
	movem.w	d0-d1,-(sp)
	btst	#3,(GameFlags).w
	bne.w	.0
	move.w	(pucky).w,d0
	btst	#7,pflags(a3)	;pfgoal - check which goal shooting at
	bne.w	.cont	;branch if top goal
	neg.w	d0
.cont
	tst.w	d0	;check if d0 is 0
	bpl.w	.0	;branch if higher
	bra.w	.playerabovetopgoalline
	;In PuckOnAttackHalf after its bra: code nothing reaches.
	;Code the listing does not decode: kept as bytes
	dc.b	$30,$38,$BF,$0E,$58,$40,$02,$40,$00,$07,$32,$2B,$00,$54,$B2,$40
	dc.b	$60,$00,$00,$3C,$67,$00,$00,$38,$52,$41,$02,$41,$00,$07,$B2,$40
	dc.b	$67,$00,$00,$2C,$52,$41,$02,$41,$00,$07,$B2,$40,$67,$00,$00,$20
	dc.b	$57,$41,$02,$41,$00,$07,$B2,$40,$67,$00,$00,$14,$53,$41,$02,$41
	dc.b	$00,$07,$67,$00,$00,$0A
.playerabovetopgoalline
	move.w	#0,d0
	bra.w	.1
.0
	move.w	#1,d0
.1
	movem.w	(sp)+,d0-d1
	rts

onetimershot	;Do the one-timer: a pass with GameFlags bit 3, else a shot; offsides, icing, assists and the crowd
	;Code the listing does not decode: kept as bytes
	dc.b	$08,$38,$00,$03,$C3,$50,$67,$00,$00,$80,$48,$E7,$FF,$FE,$30,$38
	dc.b	$BF,$A6,$B0,$78,$C3,$84,$67,$00,$00,$30,$B0,$78,$C3,$86,$67,$00
	dc.b	$00,$3C,$B0,$78,$C3,$88,$67,$00,$00,$3C,$B0,$78,$C3,$8A,$67,$00
	dc.b	$00,$3C,$31,$EB,$00,$54,$BF,$0E,$02,$78,$00,$07,$BF,$0E,$08,$F8
	dc.b	$00,$04,$C3,$50,$60,$00,$00,$2E,$4E,$B9,$00,$01,$B3,$48,$08,$00
	dc.b	$00,$03,$66,$DE,$31,$C0,$BF,$0E,$60,$00,$00,$1A,$4E,$B9,$00,$01
	dc.b	$B3,$60,$60,$EA,$4E,$B9,$00,$01,$B3,$78,$60,$E2,$4E,$B9,$00,$01
	dc.b	$B3,$90,$60,$DA,$4E,$B9,$00,$00,$F8,$F6,$08,$B8,$00,$04,$C3,$50
	dc.b	$4C,$DF,$7F,$FF,$60,$00,$00,$0E,$31,$FC,$00,$04,$BF,$0E,$4E,$B9
	dc.b	$00,$00,$F5,$F8,$48,$E7,$80,$80,$20,$7C,$FF,$FF,$C7,$26,$08,$2B
	dc.b	$00,$06,$00,$62,$67,$00,$00,$06,$41,$E8,$03,$9E,$30,$2B,$00,$52
	dc.b	$52,$68,$00,$14,$48,$E7,$80,$F0,$C5,$4B,$4E,$B9,$00,$01,$9D,$4C
	dc.b	$4C,$DF,$0F,$01,$C5,$4B,$4E,$B9,$00,$01,$9E,$6E,$C5,$4B,$42,$40
	dc.b	$10,$2B,$00,$67,$31,$68,$00,$1A,$00,$1C,$31,$68,$00,$18,$00,$1A
	dc.b	$31,$40,$00,$18,$08,$F8,$00,$07,$C3,$4C,$06,$78,$00,$96,$B8,$B2
	dc.b	$06,$78,$00,$0A,$B8,$B8,$08,$38,$00,$03,$C3,$50,$67,$00,$00,$06
	dc.b	$60,$00,$00,$06,$52,$68,$03,$96,$4C,$DF,$01,$01,$08,$F8,$00,$00
	dc.b	$BF,$B0,$08,$38,$00,$03,$C3,$50,$66,$00,$00,$0E,$08,$EB,$00,$01
	dc.b	$00,$63,$08,$F8,$00,$01,$C3,$46,$4E,$75

CheckOneTimerFacing	;Findhittype on direction d0 (the angle to the goal), d0 kept. The Z flag picks the one-timer animation in
	;setonetimeranim.
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$A7,$80,$00,$4E,$B9,$00,$01,$6D,$36,$4C,$9F,$00,$01,$4E,$75
	dc.b	$4E,$75

InitCrowdMeter	;The crowd meter start threshold CrowdRecord = $50. Called from StartGame
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(HomeTeam).w,d1
	ext.l	d1
	movea.l	#ThreeStars,a0
	move.w	#$50,d0
	move.w	d0,(CrowdRecord).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts

UpdateCrowdMeter	;The crowd meter, every frame (setvideo): sflags5 bit 7 sets when CwdExciteLvl passes the threshold from
	;CrowdRecord and clears when it drops; while set, every $14 frames CurCrowdMeter = sqrt(4 * CwdExciteLvl) + $41,
	;the peak in CrowdPeak
	btst	#7,(sflags).w	;gmclock: clock stopped
	bne.w	.0
	btst	#0,(gmode2).w
	bne.w	.0
	btst	#0,(sflags3).w
	bne.w	.ex
	btst	#7,(sflags5).w	;sf2faceoff- check for faceoff
	bne.w	.2	;branch if faceoff
	tst.w	(crowdnoisedelay).w
	beq.w	.1
	subq.w	#1,(crowdnoisedelay).w
	bpl.w	.0
	clr.w	(crowdnoisedelay).w
.ex
	rts
.1
	move.w	(CrowdRecord).w,d0
	move.w	d0,(CrowdAvg).w
	subi.w	#$B,(CrowdAvg).w
	subi.w	#$49,d0
	muls.w	d0,d0
	asr.l	#2,d0
	addq.w	#6,d0
	cmp.w	(CwdExciteLvl).w,d0
	bgt.w	.0
	bset	#7,(sflags5).w
	rts
.2
	move.w	(CrowdAvg).w,d0
	subi.w	#$41,d0
	muls.w	d0,d0
	asr.l	#2,d0
	cmp.w	(CwdExciteLvl).w,d0
	blt.w	.3
	bclr	#7,(sflags5).w
.3
	sub.w	d7,(CwdChkCntr).w
	bpl.w	.0
	move.w	#$14,(CwdChkCntr).w
	addq.w	#1,(CwdChkCnt).w
	move.w	(CwdExciteLvl).w,d0
	ext.l	d0
	asl.w	#2,d0
	jsr	(sroot).l
	addi.w	#$41,d0
	move.w	d0,(CurCrowdMeter).w
	cmp.w	(CrowdPeak).w,d0
	ble.w	.4
	move.w	d0,(CrowdPeak).w
.4
	move.w	(CurCrowdMeter).w,d0
	cmp.w	(CrowdRecord).w,d0
	blt.w	.5
	bra.w	*+4
.5
	movem.l	d0-d7/a0-a6,-(sp)
	movem.l	(sp)+,d0-d7/a0-a6
.0
	rts

stopfast	;Stop, keeping the animation: Xvel / Yvel toward 0 by $7D0 a frame (stopna2 with a bigger step)
	tst.w	Xvel(a3)
	bpl.w	.xp
	addi.w	#$7D0,Xvel(a3)
	bmi.w	.y
	clr.w	Xvel(a3)
.xp
	subi.w	#$7D0,Xvel(a3)
	bpl.w	.y
	clr.w	Xvel(a3)
.y
	tst.w	Yvel(a3)
	bpl.w	.yp
	addi.w	#$7D0,Yvel(a3)
	bmi.w	.end
	clr.w	Yvel(a3)
.yp
	subi.w	#$7D0,Yvel(a3)
	bpl.w	.end
	clr.w	Yvel(a3)
.end
	rts

checkcornercoll	;Corner circles and side walls for object a3 at d2 / d3 (wcradiusx / wcradiusy); a hit goes to end boards $128
	bclr	#4,pflags3(a3)	;wall collision bit
	move.w	#$96,d4
	sub.w	(wcradiusx).w,d4
	move.w	#$148,d5
	sub.w	(wcradiusy).w,d5
	movem.w	d2-d5,-(sp)
	neg.w	d4
	neg.w	d5
	addi.w	#$40,d4	;radius
	addi.w	#$40,d5
	cmp.w	d5,d3
	bgt.w	.ctc
	cmp.w	d4,d2
	blt.w	.circle
	neg.w	d4
	cmp.w	d4,d2
	bgt.w	.circle
	bra.w	.2
.ctc
	neg.w	d5
	cmp.w	d5,d3
	blt.w	.2
	cmp.w	d4,d2
	blt.w	.circle
	neg.w	d4
	cmp.w	d4,d2
	bgt.w	.circle
	bra.w	.2
.circle
	sub.w	d4,d2
	sub.w	d5,d3
	move.w	d3,d0	;cos0 = dy/r
	move.w	d2,d1	;sin0 = -dx/r
	neg.w	d1
	muls.w	d3,d3
	muls.w	d2,d2
	add.l	d2,d3	;dist from dot
	cmp.l	#$1000,d3
	bls.w	.2
	exg	d0,d3
	jsr	(sroot).l
	exg	d0,d3
	ext.l	d0
	asl.l	#8,d0
	divs.w	d3,d0
	ext.l	d1
	asl.l	#8,d1
	divs.w	d3,d1
	bsr.w	cornercollb
.2
	movem.w	(sp)+,d2-d5
	move.w	$4E(a3),d0
	or.w	$50(a3),d0
	bne.w	.rtss3
	move.w	#$100,d0	;now check side walls
	clr.w	d1
	cmp.w	d5,d3
	bge.w	cornercollb
	neg.w	d5
	neg.w	d0
	cmp.w	d5,d3
	ble.w	cornercollb
	exg	d0,d1
	cmp.w	d4,d2
	bge.w	cornercollb
	neg.w	d4
	neg.w	d1
	cmp.w	d4,d2
	ble.w	cornercollb
.rtss3
	rts

cornercollb	;Straight to wallcollb
	jmp	wallcollb

Create_HotCold_Table	;Fill the hot / cold table at $1A4 of team struct a0 with random values
	movem.l	d0-d7,-(sp)
	move.w	#$1BF,d1	;$1C0 values
.0
	move.w	#9,d0	;sets RNG limit (-9 - +8)
	jsr	(randomd0s).l
	move.l	a0,-(sp)
	adda.l	#$1BC,a0
	move.b	d0,(a0,d1.w)
	movea.l	(sp)+,a0
	dbf	d1,.0
	movem.l	(sp)+,d0-d7
	rts
	dc.b	$4A,$43,$6A,$00,$00,$06,$42,$43,$4E,$75,$B6,$7C,$00,$64,$6F,$00
	dc.b	$00,$06,$36,$3C,$00,$64,$4E,$75

AttributeCalc	;Attribute d3 of player a3 * 5 plus his hot / cold value / 3 limited to 0 ... $1E
	movem.l	d0-d2/a1,-(sp)
	move.w	(TempWord2).w,d1
	movea.l	#tmstruct,a1	;Start of Home Team struct
	btst	#6,pflags(a3)
	beq.w	.attribmath
	adda.l	#$39E,a1
.attribmath
	clr.w	d1
	move.b	$67(a3),d1
	asl.w	#4,d1	;shifts d1 4 bits left, moving the values over 1 nibble
	adda.l	#$1BC,a1
	move.b	(a1,d1.w),d1
	ext.w	d1	;sign-extend word. Ex: F5 (-5) -> FFF5
	ext.l	d1	;sign-extend long word. Ex: FFF5 -> FFFFFFF5
	divs.w	#3,d1	;Signed-Div D1 by 3 (FFFFFFF5 / 3, or -5 / 3 = -1r2, or FFFEFFFF
	move.w	d3,-(sp)	;push d3 onto stack
	asl.w	#2,d3	;shift left 2 bits (mult. by 4)
	add.w	(sp)+,d3	;Pop off d3 value and add to d3 (attrib X 5)
	add.w	d1,d3	;add d1 (H/C value) to d3
	bmi.w	.LowerLimit
	cmp.w	#$1E,d3
	blt.w	.MaskAttribMathResult
	move.w	#$1E,d3
	bra.w	.MaskAttribMathResult
.LowerLimit
	clr.w	d3	;if below lower limit (0), set to 0
.MaskAttribMathResult
	andi.w	#$FF,d3
	movem.l	(sp)+,d0-d2/a1
	rts

NextHomeHotPlayer	;d1 = the next home hot player (homehotidx, homehotplayer).
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$80,$80,$20,$7C,$FF,$FF,$BF,$98,$30,$38,$BF,$90,$D0,$40
	dc.b	$32,$30,$00,$00,$0C,$78,$00,$00,$BF,$90,$6C,$00,$00,$06,$52,$78
	dc.b	$BF,$90,$4C,$DF,$01,$01,$22,$7C,$FF,$FF,$C7,$26,$4E,$75

NextAwayHotPlayer	;The same for the away team (awayhotidx, awayhotplayer).
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$80,$80,$20,$7C,$FF,$FF,$BF,$96,$30,$38,$BF,$8E,$D0,$40
	dc.b	$32,$30,$00,$00,$0C,$78,$00,$00,$BF,$8E,$6C,$00,$00,$06,$52,$78
	dc.b	$BF,$8E,$4C,$DF,$01,$01,$22,$7C,$FF,$FF,$CA,$C4,$4E,$75,$4E,$75

BuildHotColdLists	;The hot / cold player lists of both teams (SortHotColdStarters, CopyHottestPlayer, CopyColdestPlayer).
	;Code the listing does not decode: kept as bytes
	dc.b	$42,$78,$BF,$8E,$42,$78,$BF,$90,$48,$E7,$FF,$FE,$20,$7C,$FF,$FF
	dc.b	$C7,$26,$61,$00,$00,$3A,$20,$7C,$FF,$FF,$BF,$98,$61,$00,$01,$20
	dc.b	$20,$7C,$FF,$FF,$BF,$9C,$61,$00,$01,$36,$20,$7C,$FF,$FF,$CA,$C4
	dc.b	$61,$00,$00,$1C,$20,$7C,$FF,$FF,$BF,$96,$61,$00,$01,$02,$20,$7C
	dc.b	$FF,$FF,$BF,$9A,$61,$00,$01,$18,$4C,$DF,$7F,$FF,$4E,$75,$48,$E7
	dc.b	$FF,$FE,$24,$48,$D5,$FC,$00,$00,$01,$BC,$3F,$07,$3E,$28,$00,$28
	dc.b	$4E,$B9,$00,$00,$EF,$02,$3E,$1F,$22,$7C,$FF,$FF,$BF,$54,$30,$3C
	dc.b	$00,$05,$12,$18,$53,$01,$12,$C1,$48,$81,$E9,$41,$42,$11,$56,$41
	dc.b	$3E,$3C,$00,$03,$42,$42,$14,$32,$10,$00,$BE,$3C,$00,$09,$67,$00
	dc.b	$00,$0C,$BE,$3C,$00,$0D,$67,$00,$00,$04,$D5,$11,$52,$41,$52,$47
	dc.b	$BE,$3C,$00,$10,$66,$DE,$4A,$19,$51,$C8,$FF,$C8,$22,$7C,$FF,$FF
	dc.b	$BF,$54,$42,$41,$30,$3C,$00,$04,$1C,$29,$00,$03,$BC,$29,$00,$01
	dc.b	$6F,$00,$00,$0E,$50,$C1,$34,$29,$00,$02,$33,$51,$00,$02,$32,$82
	dc.b	$4A,$59,$51,$C8,$FF,$E4,$4A,$41,$66,$D2,$4C,$DF,$7F,$FF,$4E,$75

NextHomeColdPlayer	;d1 = the next home cold player (homecoldidx, homecoldplayer).
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$80,$80,$20,$7C,$FF,$FF,$BF,$9C,$30,$38,$BF,$94,$D0,$40
	dc.b	$32,$30,$00,$00,$0C,$78,$00,$00,$BF,$94,$6C,$00,$00,$06,$52,$78
	dc.b	$BF,$94,$4C,$DF,$01,$01,$22,$7C,$FF,$FF,$C7,$26,$4E,$75

NextAwayColdPlayer	;The same for the away team (awaycoldidx, awaycoldplayer).
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$80,$80,$20,$7C,$FF,$FF,$BF,$9A,$30,$38,$BF,$92,$D0,$40
	dc.b	$32,$30,$00,$00,$0C,$78,$00,$00,$BF,$92,$6C,$00,$00,$06,$52,$78
	dc.b	$BF,$92,$4C,$DF,$01,$01,$22,$7C,$FF,$FF,$CA,$C4,$4E,$75,$4E,$75

CopyHottestPlayer	;Copy the hottest player of TempBuffer to the list a0.
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$C0,$C0,$22,$7C,$FF,$FF,$BF,$54,$30,$3C,$00,$00,$42,$18
	dc.b	$12,$11,$10,$C1,$4A,$59,$51,$C8,$FF,$F6,$4C,$DF,$03,$03,$4E,$75

CopyColdestPlayer	;Copy the coldest player of TempBuffer to the list a0.
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$80,$C0,$22,$7C,$FF,$FF,$BF,$5E,$30,$3C,$00,$00,$42,$18
	dc.b	$10,$D1,$4A,$61,$51,$C8,$FF,$F8,$4C,$DF,$03,$01,$4E,$75

CompareHotColdTotals	;Compare the hot / cold totals of the teams (GetHotColdTotal): d0 = $22 / $23 (the better team, awayhotter)
	;when they differ enough, else -1.
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$7F,$FE,$20,$7C,$FF,$FF,$C7,$26,$61,$00,$00,$5A,$31,$C1
	dc.b	$BF,$46,$20,$7C,$FF,$FF,$CA,$C4,$61,$00,$00,$4C,$31,$C1,$BF,$48
	dc.b	$32,$38,$BF,$46,$34,$38,$BF,$48,$94,$41,$31,$FC,$00,$00,$BF,$86
	dc.b	$4A,$42,$6B,$00,$00,$08,$31,$FC,$00,$01,$BF,$86,$4A,$42,$6A,$00
	dc.b	$00,$04,$44,$42,$30,$3C,$FF,$FF,$B4,$7C,$00,$5E,$6D,$00,$00,$12
	dc.b	$30,$3C,$00,$22,$B4,$7C,$00,$BD,$6D,$00,$00,$06,$30,$3C,$00,$23
	dc.b	$4C,$DF,$7F,$FE,$4E,$75

GetHotColdTotal	;d1 = the hot / cold total of the starters of team a0 (SortHotColdStarters, TempBuffer).
	;Code the listing does not decode: kept as bytes
	dc.b	$61,$00,$FE,$6A,$30,$3C,$00,$06,$20,$7C,$FF,$FF,$BF,$54,$42,$41
	dc.b	$14,$28,$00,$01,$48,$82,$D2,$42,$4A,$58,$51,$C8,$FF,$F4,$4E,$75
	dc.b	$4E,$75,$4E,$75,$48,$E7,$FF,$00,$08,$B8,$00,$00,$D3,$00,$67,$00
	dc.b	$00,$A2,$08,$B8,$00,$06,$D3,$00,$08,$B8,$00,$07,$D3,$00,$4E,$B9
	dc.b	$00,$01,$BB,$8E,$00,$06,$EF,$00,$00,$00,$31,$FC,$00,$05,$B0,$42
	dc.b	$70,$08,$72,$08,$34,$3C,$07,$FF,$08,$38,$00,$01,$D3,$00,$67,$00
	dc.b	$00,$3C,$31,$FC,$00,$03,$B0,$40,$4E,$B9,$00,$01,$B9,$76,$4E,$B9
	dc.b	$00,$01,$BB,$8E,$00,$06,$FF,$00,$00,$00,$31,$FC,$00,$0B,$B0,$40
	dc.b	$31,$FC,$00,$05,$B0,$42,$30,$3C,$00,$19,$32,$3C,$00,$08,$34,$3C
	dc.b	$07,$FF,$4E,$B9,$00,$01,$B9,$76,$60,$00,$00,$38,$31,$FC,$00,$1C
	dc.b	$B0,$40,$4E,$B9,$00,$01,$B9,$76,$4E,$B9,$00,$01,$BB,$8E,$00,$06
	dc.b	$FF,$00,$00,$00,$31,$FC,$00,$03,$B0,$40,$31,$FC,$00,$05,$B0,$42
	dc.b	$30,$3C,$00,$19,$32,$3C,$00,$08,$34,$3C,$07,$FF,$4E,$B9,$00,$01
	dc.b	$B9,$76,$4C,$DF,$00,$FF,$4E,$75,$31,$FC,$00,$AA,$D3,$0E,$08,$38
	dc.b	$00,$05,$D3,$00,$67,$00,$00,$08,$31,$FC,$00,$53,$D3,$0E,$4E,$75

wallcollduringcheck	;During a check, a skater a2 (not a goalie) near the wall: test the wall at his position with his size + $17.
	;Called from CCStart and FallDown
	tst.w	$34(a2)
	beq.w	.end
	movem.l	d0-d7,-(sp)
	move.w	(a2),d2	;Xpos of checking player
	move.w	Ypos(a2),d3
	move.w	$4A(a2),(wcradiusx).w
	addi.w	#$17,(wcradiusx).l	;add $17 to wcradiusx
	move.w	$4C(a2),(wcradiusy).w
	addi.w	#$17,(wcradiusy).l	;add $17 to wcradiusy
	movem.l	a0-a6,-(sp)
	exg	a2,a3	;swap a2 and a3
	jsr	(checkcornercoll).l
	exg	a2,a3	;swap a2 and a3
	movem.l	(sp)+,a0-a6
	movem.l	(sp)+,d0-d7
.end
	rts

setSlotBit	;sflags6 bit 5 (the slot) = the puck carrier is in the slot
	bclr	#5,(sflags6).w	;clears Slot Bit
	tst.w	(puckc).w
	bmi.w	.x	;exit if no puckc
	movem.l	d0/a0,-(sp)
	movea.l	#SortCords,a0	;start of SCStructs
	move.w	(puckc).w,d0	;move puckc SCnum into d0
	asl.w	#7,d0	;mult by 128 decimal
	adda.w	d0,a0	;move to start of puckc SCstruct
	move.w	Ypos(a0),d0	;Ypos
	btst	#7,pflags(a0)	;pfgoal - which goal shooting at
	bne.w	.checkpos	;jump if top goal
	neg.w	d0	;negative d0
.checkpos
	cmp.w	#$76,d0	;compare to blueline
	blt.w	.restore	;branch if not in off zone
	cmpi.w	#$51,(a0)	;compare X position to $47
	bgt.w	.restore	;branch if greater than 47
	cmpi.w	#$FFAF,(a0)	;compare X position to -$47
	blt.w	.restore	;branch if less than -47
	bset	#5,(sflags6).w	;set bit
.restore
	movem.l	(sp)+,d0/a0
.x
	rts

TeamLogoPalettes2	;Team logo palettes, a second set (nothing in the listing uses it)
	dc.b	$0E,$EA,$00,$00,$00,$42,$0E,$EA,$0E,$EA,$0E,$EE,$00,$00,$08,$88
	dc.b	$0A,$AA,$00,$68,$00,$8A,$00,$CE,$02,$60,$00,$40,$06,$64,$0E,$8E
	dc.b	$0E,$EA,$0E,$EA,$0E,$EA,$00,$00,$00,$42,$0E,$EE,$00,$00,$08,$88
	dc.b	$0A,$AA,$00,$68,$00,$8A,$00,$CE,$02,$60,$00,$40,$06,$64,$0E,$8E
	dc.b	$0E,$E8,$00,$00,$00,$8C,$0E,$E8,$0E,$E8,$0E,$EE,$00,$00,$0C,$8C
	dc.b	$00,$8C,$08,$88,$00,$68,$08,$46,$00,$44,$04,$22,$08,$CE,$02,$AE
	dc.b	$0E,$E8,$0E,$E8,$0E,$E8,$00,$00,$00,$8C,$0E,$EE,$00,$00,$0C,$8C
	dc.b	$00,$8C,$08,$88,$00,$68,$08,$46,$00,$44,$04,$22,$08,$CE,$02,$AE
	dc.b	$0E,$E8,$08,$22,$00,$8C,$0E,$E8,$0E,$E8,$0E,$EE,$00,$00,$0E,$C8
	dc.b	$04,$8C,$0C,$88,$00,$6C,$08,$66,$02,$68,$02,$24,$06,$20,$00,$CE
	dc.b	$0E,$E8,$0E,$E8,$0E,$E8,$08,$22,$00,$8C,$0E,$EE,$00,$00,$0E,$C8
	dc.b	$04,$8C,$0C,$88,$00,$6C,$08,$66,$02,$68,$02,$24,$06,$20,$00,$CE
	dc.b	$0E,$E8,$00,$06,$00,$8C,$0E,$E8,$0E,$E8,$0E,$EE,$00,$00,$08,$EE
	dc.b	$02,$CE,$02,$AE,$02,$6E,$00,$0C,$0E,$E8,$0E,$E8,$0E,$E8,$0E,$E8
	dc.b	$0E,$E8,$0E,$E8,$0E,$E8,$00,$06,$00,$8C,$0E,$EE,$00,$00,$08,$EE
	dc.b	$02,$CE,$02,$AE,$02,$6E,$00,$0C,$0E,$E8,$0E,$E8,$0E,$E8,$0E,$E8
	dc.b	$0E,$E8,$00,$00,$00,$06,$0E,$E8,$0E,$E8,$0E,$EE,$00,$00,$08,$EE
	dc.b	$0A,$8E,$04,$AC,$0A,$88,$04,$6C,$02,$26,$06,$44,$02,$2E,$02,$62
	dc.b	$0E,$E8,$0E,$E8,$0E,$E8,$00,$00,$00,$06,$0E,$EE,$00,$00,$08,$EE
	dc.b	$0A,$8E,$04,$AC,$0A,$88,$04,$6C,$02,$26,$06,$44,$02,$2E,$02,$62
	dc.b	$0E,$E8,$00,$00,$00,$42,$0E,$E8,$0E,$E8,$0E,$EE,$00,$00,$08,$AA
	dc.b	$06,$88,$04,$88,$04,$66,$02,$44,$02,$60,$00,$20,$0A,$CC,$00,$00
	dc.b	$0E,$E8,$0E,$E8,$0E,$E8,$00,$00,$00,$42,$0E,$EE,$00,$00,$08,$AA
	dc.b	$06,$88,$04,$88,$04,$66,$02,$44,$02,$60,$00,$20,$0A,$CC,$00,$00
	dc.b	$0E,$E8,$00,$06,$00,$06,$0E,$E8,$0E,$E8,$0E,$EE,$00,$00,$0C,$8E
	dc.b	$08,$6E,$04,$4E,$08,$2E,$02,$0E,$0E,$E8,$0E,$E8,$0E,$E8,$0E,$E8
	dc.b	$0E,$E8,$0E,$E8,$0E,$E8,$00,$06,$00,$06,$0E,$EE,$00,$00,$0C,$8E
	dc.b	$08,$6E,$04,$4E,$08,$2E,$02,$0E,$0E,$E8,$0E,$E8,$0E,$E8,$0E,$E8
	dc.b	$0E,$E8,$06,$00,$00,$4A,$0E,$E8,$0E,$E8,$0E,$EE,$00,$00,$0C,$EA
	dc.b	$0A,$8E,$08,$A8,$04,$4E,$04,$88,$00,$2E,$04,$40,$04,$00,$0E,$E8
	dc.b	$0E,$E8,$0E,$E8,$0E,$E8,$06,$00,$00,$4A,$0E,$EE,$00,$00,$0C,$EA
	dc.b	$0A,$8E,$08,$A8,$04,$4E,$04,$88,$00,$2E,$04,$40,$04,$00,$0E,$E8
	dc.b	$0E,$EA,$00,$4A,$06,$00,$0E,$EA,$0E,$EA,$0E,$EE,$00,$00,$00,$0A
	dc.b	$00,$04,$00,$46,$00,$8E,$0C,$EE,$04,$66,$04,$42,$0E,$C6,$02,$00
	dc.b	$0E,$EA,$0E,$EA,$0E,$EA,$00,$4A,$06,$00,$0E,$EE,$00,$00,$00,$0A
	dc.b	$00,$04,$00,$46,$00,$8E,$0C,$EE,$04,$66,$04,$42,$0E,$C6,$02,$00
	dc.b	$0E,$E8,$00,$42,$08,$22,$0E,$E8,$0E,$E8,$0E,$EE,$00,$00,$00,$E8
	dc.b	$04,$C4,$0A,$8A,$00,$A2,$04,$66,$06,$00,$02,$24,$0E,$E8,$0E,$E8
	dc.b	$0E,$E8,$0E,$E8,$0E,$E8,$00,$42,$08,$22,$0E,$EE,$00,$00,$00,$E8
	dc.b	$04,$C4,$0A,$8A,$00,$A2,$04,$66,$06,$00,$02,$24,$0E,$E8,$0E,$E8
	dc.b	$0E,$E8,$00,$00,$00,$00,$0E,$E8,$0E,$E8,$0E,$EE,$00,$00,$0A,$AA
	dc.b	$08,$88,$06,$66,$04,$44,$02,$22,$0C,$CC,$0E,$E8,$0E,$E8,$0E,$E8
	dc.b	$0E,$E8,$0E,$E8,$0E,$E8,$00,$00,$00,$00,$0E,$EE,$00,$00,$0A,$AA
	dc.b	$08,$88,$06,$66,$04,$44,$02,$22,$0C,$CC,$0E,$E8,$0E,$E8,$0E,$E8
	dc.b	$0E,$E8,$06,$00,$00,$06,$0E,$E8,$0E,$E8,$0E,$EE,$00,$00,$08,$8E
	dc.b	$02,$6E,$0C,$68,$00,$2E,$0A,$24,$0E,$AA,$0E,$E8,$0E,$E8,$0E,$E8
	dc.b	$0E,$E8,$0E,$E8,$0E,$E8,$06,$00,$00,$06,$0E,$EE,$00,$00,$08,$8E
	dc.b	$02,$6E,$0C,$68,$00,$2E,$0A,$24,$0E,$AA,$0E,$E8,$0E,$E8,$0E,$E8
	dc.b	$0E,$E8,$00,$20,$00,$06,$0E,$E8,$0E,$E8,$0E,$EE,$00,$00,$0A,$AA
	dc.b	$00,$0A,$08,$88,$00,$0C,$00,$22,$00,$06,$0C,$CC,$0E,$E8,$0E,$E8
	dc.b	$0E,$E8,$0E,$E8,$0E,$E8,$00,$20,$00,$06,$0E,$EE,$00,$00,$0A,$AA
	dc.b	$00,$0A,$08,$88,$00,$0C,$00,$22,$00,$06,$0C,$CC,$0E,$E8,$0E,$E8
	dc.b	$0E,$E8,$08,$22,$00,$4A,$0E,$E8,$0E,$E8,$0E,$EE,$00,$00,$0A,$A8
	dc.b	$06,$6E,$08,$64,$02,$2C,$06,$2A,$00,$08,$06,$22,$02,$22,$0A,$8E
	dc.b	$0E,$E8,$0E,$E8,$0E,$E8,$08,$22,$00,$4A,$0E,$EE,$00,$00,$0A,$A8
	dc.b	$06,$6E,$08,$64,$02,$2C,$06,$2A,$00,$08,$06,$22,$02,$22,$0A,$8E
	dc.b	$0E,$E8,$06,$00,$00,$06,$0E,$E8,$0E,$E8,$0E,$EE,$00,$00,$0A,$AA
	dc.b	$0C,$86,$00,$2E,$0C,$60,$08,$44,$04,$44,$08,$40,$00,$08,$0E,$C8
	dc.b	$0E,$E8,$0E,$E8,$0E,$E8,$06,$00,$00,$06,$0E,$EE,$00,$00,$0A,$AA
	dc.b	$0C,$86,$00,$2E,$0C,$60,$08,$44,$04,$44,$08,$40,$00,$08,$0E,$C8
	dc.b	$0E,$E8,$00,$06,$00,$6A,$0E,$E8,$0E,$E8,$0E,$EE,$00,$00,$06,$8A
	dc.b	$06,$88,$04,$66,$02,$44,$02,$2C,$02,$28,$00,$08,$0A,$AA,$00,$04
	dc.b	$0E,$E8,$0E,$E8,$0E,$E8,$00,$06,$00,$6A,$0E,$EE,$00,$00,$06,$8A
	dc.b	$06,$88,$04,$66,$02,$44,$02,$2C,$02,$28,$00,$08,$0A,$AA,$00,$04
	dc.b	$0E,$E8,$00,$00,$00,$4A,$0E,$E8,$0E,$E8,$0E,$EE,$00,$00,$0C,$CC
	dc.b	$08,$8E,$0A,$AA,$04,$6E,$00,$6E,$08,$88,$06,$66,$00,$2E,$04,$44
	dc.b	$0E,$E8,$0E,$E8,$0E,$E8,$00,$00,$00,$4A,$0E,$EE,$00,$00,$0C,$CC
	dc.b	$08,$8E,$0A,$AA,$04,$6E,$00,$6E,$08,$88,$06,$66,$00,$2E,$04,$44
	dc.b	$0E,$E8,$00,$00,$00,$8C,$0E,$E8,$0E,$E8,$0E,$EE,$00,$00,$0A,$AA
	dc.b	$08,$8A,$06,$6A,$04,$EE,$04,$64,$04,$40,$02,$CE,$02,$44,$0A,$EE
	dc.b	$0E,$E8,$0E,$E8,$0E,$E8,$00,$00,$00,$8C,$0E,$EE,$00,$00,$0A,$AA
	dc.b	$08,$8A,$06,$6A,$04,$EE,$04,$64,$04,$40,$02,$CE,$02,$44,$0A,$EE
	dc.b	$0E,$E8,$06,$00,$00,$06,$0E,$E8,$0E,$E8,$0E,$EE,$00,$00,$0C,$00
	dc.b	$00,$0E,$0E,$44,$0E,$CE,$0E,$80,$08,$8E,$0E,$E8,$0E,$E8,$0E,$E8
	dc.b	$0E,$E8,$0E,$E8,$0E,$E8,$06,$00,$00,$06,$0E,$EE,$00,$00,$0C,$00
	dc.b	$00,$0E,$0E,$44,$0E,$CE,$0E,$80,$08,$8E,$0E,$E8,$0E,$E8,$0E,$E8
	dc.b	$0E,$E8,$00,$00,$08,$60,$0E,$E8,$0E,$E8,$0E,$EE,$00,$00,$08,$60
	dc.b	$06,$42,$08,$88,$0C,$A8,$0A,$CC,$02,$AE,$00,$6E,$00,$48,$04,$6A
	dc.b	$0E,$E8,$0E,$E8,$0E,$E8,$00,$00,$08,$60,$0E,$EE,$00,$00,$08,$60
	dc.b	$06,$42,$08,$88,$0C,$A8,$0A,$CC,$02,$AE,$00,$6E,$00,$48,$04,$6A
	dc.b	$0E,$E8,$08,$22,$00,$6A,$0E,$E8,$0E,$E8,$0E,$EE,$00,$00,$06,$02
	dc.b	$02,$4C,$00,$02,$00,$26,$00,$68,$04,$28,$08,$6E,$0E,$E8,$0E,$E8
	dc.b	$0E,$E8,$0E,$E8,$0E,$E8,$08,$22,$00,$6A,$0E,$EE,$00,$00,$06,$02
	dc.b	$02,$4C,$00,$02,$00,$26,$00,$68,$04,$28,$08,$6E,$0E,$E8,$0E,$E8
	dc.b	$0E,$E8,$00,$00,$06,$00,$0E,$E8,$0E,$E8,$0E,$EE,$00,$00,$0C,$86
	dc.b	$0E,$84,$0A,$84,$0C,$44,$08,$22,$0E,$20,$06,$00,$0A,$00,$0E,$A8
	dc.b	$0E,$E8,$0E,$E8,$0E,$E8,$00,$00,$06,$00,$0E,$EE,$00,$00,$0C,$86
	dc.b	$0E,$84,$0A,$84,$0C,$44,$08,$22,$0E,$20,$06,$00,$0A,$00,$0E,$A8
	dc.b	$0E,$E8,$06,$00,$06,$00,$0E,$E8,$0E,$E8,$0E,$EE,$00,$00,$0E,$CA
	dc.b	$0A,$AA,$0C,$66,$08,$22,$0C,$CC,$0E,$E8,$0E,$E8,$0E,$E8,$0E,$E8
	dc.b	$0E,$E8,$0E,$E8,$0E,$E8,$06,$00,$06,$00,$0E,$EE,$00,$00,$0E,$CA
	dc.b	$0A,$AA,$0C,$66,$08,$22,$0C,$CC,$0E,$E8,$0E,$E8,$0E,$E8,$0E,$E8
	dc.b	$0E,$E8,$00,$00,$00,$8C,$0E,$E8,$0E,$E8,$0E,$EE,$00,$00,$00,$CE
	dc.b	$00,$6A,$00,$4E,$00,$28,$00,$22,$00,$20,$00,$8E,$08,$88,$06,$CE
	dc.b	$0E,$E8,$0E,$E8,$0E,$E8,$00,$00,$00,$8C,$0E,$EE,$00,$00,$00,$CE
	dc.b	$00,$6A,$00,$4E,$00,$28,$00,$22,$00,$20,$00,$8E,$08,$88,$06,$CE
	dc.b	$0E,$E8,$00,$06,$06,$00,$0E,$E8,$0E,$E8,$0E,$EE,$00,$00,$02,$2C
	dc.b	$0C,$86,$0E,$A8,$08,$8E,$08,$42,$0E,$E8,$0E,$E8,$0E,$E8,$0E,$E8
	dc.b	$0E,$E8,$0E,$E8,$0E,$E8,$00,$06,$06,$00,$0E,$EE,$00,$00,$02,$2C
	dc.b	$0C,$86,$0E,$A8,$08,$8E,$08,$42,$0E,$E8,$0E,$E8,$0E,$E8,$0E,$E8
	dc.b	$0E,$E8,$06,$00,$00,$06,$0E,$E8,$0E,$E8,$0E,$EE,$00,$00,$02,$2C
	dc.b	$04,$22,$0A,$AC,$06,$66,$0C,$AA,$04,$44,$06,$6E,$08,$CE,$02,$26
	dc.b	$0E,$E8,$0E,$E8,$0E,$E8,$06,$00,$00,$06,$0E,$EE,$00,$00,$02,$2C
	dc.b	$04,$22,$0A,$AC,$06,$66,$0C,$AA,$04,$44,$06,$6E,$08,$CE,$02,$26
	dc.b	$0E,$E8,$00,$00,$00,$4A,$0E,$E8,$0E,$E8,$0E,$EE,$00,$00,$06,$88
	dc.b	$04,$64,$02,$44,$02,$22,$00,$4E,$00,$0A,$00,$22,$0A,$AA,$00,$00
	dc.b	$0E,$E8,$0E,$E8,$0E,$E8,$00,$00,$00,$4A,$0E,$EE,$00,$00,$06,$88
	dc.b	$04,$64,$02,$44,$02,$22,$00,$4E,$00,$0A,$00,$22,$0A,$AA,$00,$00
	dc.b	$0E,$E8,$00,$00,$00,$4A,$0E,$E8,$0E,$E8,$0E,$EE,$00,$00,$06,$88
	dc.b	$04,$64,$02,$44,$02,$22,$00,$4E,$00,$0A,$00,$22,$0A,$AA,$00,$00
	dc.b	$0E,$E8,$0E,$E8,$0E,$E8,$00,$00,$00,$4A,$0E,$EE,$00,$00,$06,$88
	dc.b	$04,$64,$02,$44,$02,$22,$00,$4E,$00,$0A,$00,$22,$0A,$AA,$00,$00

CopyString	;Copy String a1 (length word first) to a3.
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$80,$00,$30,$11,$53,$40,$16,$D9,$51,$C8,$FF,$FC,$4C,$DF
	dc.b	$00,$01,$4E,$75,$48,$A7,$FE,$80,$2F,$09,$3C,$00,$54,$89,$42,$41
	dc.b	$48,$C0,$80,$FC,$00,$64,$4A,$40,$67,$00,$00,$0A,$06,$40,$00,$30
	dc.b	$12,$C0,$52,$41,$48,$40,$48,$C0,$80,$FC,$00,$0A,$06,$40,$00,$30
	dc.b	$B0,$3C,$00,$30,$66,$00,$00,$0A,$BC,$7C,$00,$0A,$6D,$00,$00,$06
	dc.b	$12,$C0,$52,$41,$48,$40,$06,$40,$00,$30,$12,$C0,$52,$41,$08,$01
	dc.b	$00,$00,$67,$00,$00,$08,$12,$FC,$00,$00,$52,$41,$20,$5F,$54,$41
	dc.b	$30,$81,$4C,$9F,$01,$7F,$4E,$75

ReadTeamRecord	;Read the 16 byte team record block d1 ($D22 + d1 * 16) to a0 (TeamRecordIO)
	bclr	#6,(sflags6).w

TeamRecordIO	;The team record block: read or write (sflags6 bit 6)
	movem.l	d0-d1/a0-a1,-(sp)
	move.l	d1,d0
	asl.w	#4,d0
	addi.l	#$ECE,d0
	moveq	#$10,d1
	btst	#6,(sflags6).w
	beq.w	.read
	jsr	(WriteSRAM).l
	bra.w	.x
.read
	jsr	(ReadSRAM).l
.x
	movem.l	(sp)+,d0-d1/a0-a1
	rts

WriteTeamRecord	;Write the team record block (TeamRecordIO)
	bset	#6,(sflags6).w
	bra.s	TeamRecordIO

WriteNameLog	;Write the user name log ($80 bytes at namelog) to save RAM SRNameLog
	bset	#6,(sflags6).w
	bra.w	NameLogIO

ReadNameLog	;Read the user name log from save RAM SRNameLog to namelog
	bclr	#6,(sflags6).w

NameLogIO	;Read or write (sflags6 bit 6) the name log
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	#$80,d1
	move.l	#$F4E,d0
	movea.l	#$FFFFD32C,a0
	btst	#6,(sflags6).w
	beq.w	.read
	jsr	(WriteSRAM).l
	bra.w	.x
.read
	jsr	(ReadSRAM).l
.x
	movem.l	(sp)+,d0-d7/a0-a6
	rts
	dc.b	$00,$00,$00,$1C,$00,$38,$00,$54,$00,$70,$00,$8C,$00,$A8,$00,$C4
	dc.b	$00,$E0,$00,$FC,$01,$18,$01,$34,$01,$50,$01,$6C,$01,$88,$01,$A4
	dc.b	$01,$C0,$01,$DC,$01,$F8,$02,$14,$02,$30,$02,$4C,$02,$68,$02,$84
	dc.b	$02,$A0,$02,$BC,$02,$D8,$02,$F4,$03,$10

UpdateRecords	;With save RAM (ValidSRAM) and user records on (OptUserRec 0), update the player records
	;(UpdatePlayerRecords), with sflags11 bit 7 the crowd records of both teams (UpdateCrowdRecord), then the team
	;record of each pad (UpdateUserRecord), then the save RAM checksum
	tst.w	(ValidSRAM).w
	bmi.w	.x
	tst.w	(OptUserRec).w
	bne.w	.x
	movem.l	d0-d7/a0-a6,-(sp)
	bsr.w	CountGoalies
	bsr.w	CountPlayers
	movea.l	#ThreeStars,a0
	move.w	(pad1user).w,d1
	ext.l	d1
	move.w	(pad2user).w,d2
	move.w	(HomeTeam).w,d3
	move.w	(VisTeam).w,d4
	movea.l	#tmstruct,a1
	movea.l	#AwShots,a2
	bsr.w	UpdateTeamRecord
	movea.l	#ThreeStars,a0
	move.w	(pad2user).w,d1
	ext.l	d1
	move.w	(pad1user).w,d2
	move.w	(VisTeam).w,d3
	move.w	(HomeTeam).w,d4
	movea.l	#AwShots,a1
	movea.l	#tmstruct,a2
	bsr.w	UpdateTeamRecord
	jsr	(MakeSRAMChecksum).l
	movem.l	(sp)+,d0-d7/a0-a6
.x
	rts

UpdateTeamRecord	;Add the game of team a1 (against a2) to team record block d1 (games, wins, ties) with sflags11 bit 7 keep the
	;biggest win and loss margins with users d3 / d4 and team d2 (WriteTeamRecord)
	movem.l	d0-d7/a0-a6,-(sp)
	bsr.w	ReadTeamRecord
	st	d7
	movem.w	d0,-(sp)
	clr.w	d0
	move.b	$A(a0),d0
	lsl.w	#8,d0
	move.b	$B(a0),d0
	cmp.w	#$2328,d0
	bge.w	.1
	addq.w	#1,d0
	move.b	d0,$B(a0)
	lsr.w	#8,d0
	move.b	d0,$A(a0)
	move.w	$C(a1),d0
	cmp.w	$C(a2),d0
	bgt.w	.0
	blt.w	.1
	clr.w	d0
	move.b	$C(a0),d0
	lsl.w	#8,d0
	move.b	$D(a0),d0
	addq.w	#1,d0
	move.b	d0,$D(a0)
	lsr.w	#8,d0
	move.b	d0,$C(a0)
	bra.w	.1
.0
	clr.w	d0
	move.b	8(a0),d0
	lsl.w	#8,d0
	move.b	9(a0),d0
	addq.w	#1,d0
	move.b	d0,9(a0)
	lsr.w	#8,d0
	move.b	d0,8(a0)
.1
	movem.w	(sp)+,d0
	movem.w	d0,-(sp)
	move.w	$C(a1),d0
	cmp.w	$C(a2),d0
	movem.w	(sp)+,d0
	ble.w	.write
	move.w	$C(a1),d5
	cmp.b	(a0),d5
	ble.w	.2
	st	d7
	move.b	d5,(a0)
	move.b	d3,1(a0)
	move.b	d4,2(a0)
	move.b	d2,3(a0)
.2
	move.w	$C(a2),d5
	move.w	(a2),d6
	sub.w	d5,d6
	cmp.b	4(a0),d6
	ble.w	.write
	st	d7
	move.b	d6,4(a0)
	move.b	d3,5(a0)
	move.b	d4,6(a0)
	move.b	d2,7(a0)
.write
	bsr.w	WriteTeamRecord
	movem.l	(sp)+,d0-d7/a0-a6
	rts

CountGoalies	;homegoalies / awaygoalies = goalies of the home / away team (GetGoalieCount)
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#tmstruct,a2
	jsr	(GetGoalieCount).l
	move.w	d0,(homegoalies).w
	movea.l	#AwShots,a2
	jsr	(GetGoalieCount).l
	move.w	d0,(awaygoalies).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts

CountPlayers	;homeplayers / awayplayers = players of the home / away team (GetPlayerCount)
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#tmstruct,a2
	jsr	(GetPlayerCount).l
	move.w	d0,(homeplayers).w
	movea.l	#AwShots,a2
	jsr	(GetPlayerCount).l
	move.w	d0,(awayplayers).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts

AppendUserName	;Append user name d2 (12 bytes of the name log at namelog, spaces for 0) to a1, or NoNameTxt when d2 is 0
	;trailing spaces trimmed (TrimSpaces).
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$F0,$F0,$24,$49,$4A,$42,$67,$00,$00,$42,$30,$3C,$00,$09
	dc.b	$42,$43,$20,$7C,$FF,$FF,$D3,$2C,$C4,$FC,$00,$0A,$D1,$C2,$12,$30
	dc.b	$30,$00,$66,$00,$00,$06,$12,$3C,$00,$20,$13,$41,$00,$02,$4A,$19
	dc.b	$52,$43,$51,$C8,$FF,$EA,$34,$BC,$00,$0C,$08,$38,$00,$07,$C3,$46
	dc.b	$67,$00,$00,$06,$61,$00,$01,$D8,$60,$00,$00,$18,$26,$49,$2F,$0B
	dc.b	$22,$7C,$00,$1D,$7D,$CA,$4E,$B9,$00,$1D,$7A,$90,$24,$5F,$61,$00
	dc.b	$01,$BE,$4C,$DF,$0F,$0F,$4E,$75,$00,$02

AppendTeamName	;Append the city name of team d0 (TeamList block Strings) to a1 (appstring).
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$80,$F0,$48,$80,$E5,$40,$20,$7C,$00,$00,$07,$7E,$20,$70
	dc.b	$00,$00,$30,$28,$00,$04,$48,$C0,$D1,$C0,$D0,$D0,$26,$49,$22,$48
	dc.b	$4E,$B9,$00,$01,$BE,$80,$4C,$DF,$0F,$01,$4E,$75

CalcAttrib	;The overall rating of player d0: his attributes weighted by OvrPlayerWgtList (skaters) or OvrGoalWgtList
	;(goalies), and by AttribWgtList. Called from getNameandAttrib and PrintOverallRating
	move.l	a6,-(sp)	;push a6 to stack
	clr.w	(attribsum).w
	clr.w	(attribcount).w
	movea.l	#AttribWgtList,a6
	cmp.l	(PAttribOverallMask).l,d4	;compare long word (1FBA000A) to d4
	bne.w	.0
	movea.l	#OvrPlayerWgtList,a6
.0
	cmp.l	(GAttribOverallMask).l,d4	;compare long word 130F000A to d4
	bne.w	.2
	movea.l	#OvrGoalWgtList,a6
.2
	movea.l	$1E(a2),a0
	lea	$1BC(a2),a4
	clr.l	d1	;clear d1
	move.w	d0,d1	;move d0 into d1. d0 is the offset of the player
	asl.w	#4,d1	;mult d1 by 16
	adda.l	d1,a4	;add d1 to a4
	adda.l	#$10,a4	;add 16 dec to a4. Move to start of Hot/Cold for player.
	movem.l	d7/a1,-(sp)
	move.w	$28(a2),d7
	jsr	(GetRosterName).l
	adda.w	(a1),a1
	addq.w	#8,a1
	movea.l	a1,a0
	movem.l	(sp)+,d7/a1
	clr.w	d0
	clr.w	d1
	moveq	#$F,d2
	swap	d4
.bit
	btst	d2,d4
	beq.w	.next
	move.w	d2,d3
	lsr.w	#1,d3
	neg.w	d3
	move.b	-1(a0,d3.w),d3
	btst	#0,d2
	beq.w	.1
	lsr.w	#4,d3
.1
	andi.w	#$F,d3
	cmp.w	#$D,d2
	bne.w	.4
	bra.w	.add
.4
	tst.w	d2
	bne.w	.3
	btst	#4,(sflags13).w
	beq.w	.6
	asr.b	#1,d3
	bra.w	.3
.6
	cmp.b	#6,d3
	ble.w	.3
	subq.b	#6,d3
.3
	cmp.w	#6,d2
	beq.w	.add
	movem.l	d5-d7,-(sp)
	move.b	(a6,d2.w),d5
	ext.w	d5
	cmp.w	#2,d5
	beq.w	.5
	move.w	d3,-(sp)
	subq.w	#2,d5
.attribadd
	add.w	(sp),d3
	dbf	d5,.attribadd
	asr.w	#1,d3
	tst.w	(sp)+
.5
	movem.l	(sp)+,d5-d7
	cmpa.l	#AttribWgtList,a6
	beq.w	.create
	neg.w	d2
	move.w	d7,-(sp)
	move.b	-1(a4,d2.w),d7
	ext.w	d7
	add.w	d7,(attribsum).w
	addq.w	#1,(attribcount).w
	move.w	(sp)+,d7
	neg.w	d2
	bra.w	.add
.create
	move.w	d3,-(sp)
	asl.w	#4,d3
	add.w	(sp),d3
	add.w	(sp)+,d3
	neg.w	d2
	add.b	-1(a4,d2.w),d3
	bpl.w	.pos
	clr.b	d3
.pos
	neg.w	d2
.add
	add.w	d3,d0
	addi.w	#$64,d1
.next
	dbf	d2,.bit
	cmpa.l	#AttribWgtList,a6
	beq.w	.11
	move.w	#$64,d1
	movem.l	d6-d7,-(sp)
	move.w	(attribsum).w,d6
	ext.l	d6
	move.w	(attribcount).w,d7
	divs.w	d7,d6
	add.w	d6,d0
	movem.l	(sp)+,d6-d7
.11
	cmp.w	d1,d0
	blt.w	.7
	move.w	d0,d1
	subq.w	#1,d0
.7
	jsr	(MinOverallRating).l
	movea.l	(sp)+,a6
	rts

OvrPlayerWgtList	;Skater attribute weights for the overall rating (CalcAttrib)
	dc.b	$02,$02,$02,$02,$04,$06,$02,$04,$02,$04,$06,$06,$04,$02,$02,$02

OvrGoalWgtList	;Goalie attribute weights
	dc.b	$02,$02,$02,$02,$02,$02,$02,$02,$09,$09,$02,$02,$09,$02,$02,$02

AttribWgtList	;Single attribute weights
	dc.b	$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02

TrimSpaces	;Trim the trailing spaces of String a2 and pad it to an even length.
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$00,$10,$26,$4A,$D6,$D2,$10,$23,$B0,$3C,$00,$20,$66,$00
	dc.b	$00,$0A,$16,$BC,$00,$00,$53,$52,$60,$EE,$52,$52,$02,$52,$00,$FE
	dc.b	$4C,$DF,$08,$00,$4E,$75

