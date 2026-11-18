;	The crowd meter, the hot and cold players, the team records and the
;	attribute weights.

PuckOnAttackHalf					;d0 = 1 when the puck is on the half of the goal player a3 shoots at, else
									;0 (the code after the bra is never
									;used). Called from doinput and asspassrec
	movem.w	d0-d1,-(sp)
	btst	#3,(GameFlags).w
	bne.w	.0
	move.w	(pucky).w,d0
	btst	#pfgoal,pflags(a3)		;pfgoal - check which goal shooting at
	bne.w	.cont					;branch if top goal
	neg.w	d0
.cont
	tst.w	d0						;check if d0 is 0
	bpl.w	.0						;branch if higher
	bra.w	.playerabovetopgoalline
	;In PuckOnAttackHalf after its bra: code nothing reaches.
	move.w	(passdir).w,d0
	addq.w	#4,d0
	andi.w	#7,d0
	move.w	$54(a3),d1
	cmp.w	d0,d1
	bra.w	PuckOnAttackHalfYes
	dc.w	$6700,$0038,$5241,$0241,$0007,$B240,$6700,$002C
	dc.w	$5241,$0241,$0007,$B240,$6700,$0020,$5741,$0241
	dc.w	$0007,$B240,$6700,$0014,$5341,$0241,$0007,$6700
	dc.w	$000A
.playerabovetopgoalline
	move.w	#0,d0
	bra.w	.1
PuckOnAttackHalfYes	equ	*			;Result 1: the puck is on the attack half
.0
	move.w	#1,d0
.1
	movem.w	(sp)+,d0-d1
	rts

onetimershot						;Do the one-timer: a pass with GameFlags bit 3, else a shot; offsides,
									;icing, assists and the crowd
	btst	#3,(GameFlags).w
	beq.w	.6
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(onetimerplayer).w,d0
	cmp.w	(c1playernum).w,d0
	beq.w	.1
	cmp.w	(c2playernum).w,d0
	beq.w	.2
	cmp.w	(c3playernum).w,d0
	beq.w	.3
	cmp.w	(c4playernum).w,d0
	beq.w	.4
.loop
	move.w	facedir(a3),(passdir).w
	andi.w	#7,(passdir).w
	bset	#4,(GameFlags).w
	bra.w	.5
.1
	jsr	(ReadJoy1).l
.loop2
	btst	#3,d0
	bne.s	.loop
	move.w	d0,(passdir).w
	bra.w	.5
.2
	jsr	(ReadJoy2).l
	bra.s	.loop2
.3
	jsr	(ReadJoy3).l
	bra.s	.loop2
.4
	jsr	(ReadJoy4).l
	bra.s	.loop2
.5
	jsr	(dopass).l
	bclr	#4,(GameFlags).w
	movem.l	(sp)+,d0-d7/a0-a6
	bra.w	.7
.6
	move.w	#4,(passdir).w
	jsr	(doshot).l
.7
	movem.l	d0/a0,-(sp)
	movea.l	#tmstruct,a0			;Home Stats
	btst	#pfteam,pflags(a3)		;check if home or away
	beq.w	.8						;branch if home
	lea	$39E(a0),a0
.8
	move.w	SCnum(a3),d0
	addq.w	#1,$14(a0)
	movem.l	d0/a0-a3,-(sp)
	exg	a2,a3
	jsr	(a2offsides).l
	movem.l	(sp)+,d0/a0-a3
	exg	a2,a3
	jsr	(ArmIcing).l
	exg	a2,a3
	;team struct chosen
	clr.w	d0
	move.b	weight(a3),d0
	move.w	$1A(a0),$1C(a0)			;move assist 1 player to assist 2
	move.w	$18(a0),$1A(a0)			;move last player to touch puck to assist 1
	move.w	d0,$18(a0)				;move d0 into player touching puck
	bset	#7,(sflags8).w			;set bit 7
	addi.w	#$96,(Crowdlevel).w		;add to Crowdlevel
	addi.w	#$A,(CwdExciteLvl).w	;add to Excite Level
	btst	#3,(GameFlags).w
	beq.w	.9
	bra.w	.10
.9
	addq.w	#1,$396(a0)
.10
	movem.l	(sp)+,d0/a0
	bset	#0,(onetimerflags).w
	btst	#3,(GameFlags).w
	bne.w	.11
	bset	#pf2aip,pflags2(a3)
	bset	#1,(sflags6).w
.11
	rts

CheckOneTimerFacing					;Findhittype on direction d0 (the angle to the goal), d0 kept. The Z flag
									;picks the one-timer animation in
									;setonetimeranim.
	movem.w	d0,-(sp)
	jsr	(Findhittype).l
	movem.w	(sp)+,d0
	rts
	rts

InitCrowdMeter						;The crowd meter start threshold CrowdRecord = $50. Called from StartGame
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(HomeTeam).w,d1
	ext.l	d1
	movea.l	#ThreeStars,a0
	move.w	#$50,d0
	move.w	d0,(CrowdRecord).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts

UpdateCrowdMeter					;The crowd meter, every frame (setvideo): sflags5 bit 7 sets when
									;CwdExciteLvl passes the threshold from
									;CrowdRecord and clears when it drops; while set, every $14 frames
									;CurCrowdMeter = sqrt(4 * CwdExciteLvl) + $41, the peak in CrowdPeak
	btst	#sfhor,(sflags).w		;gmclock: clock stopped
	bne.w	.0
	btst	#0,(gmode2).w
	bne.w	.0
	btst	#0,(sflags3).w
	bne.w	.ex
	btst	#7,(sflags5).w			;sf2faceoff- check for faceoff
	bne.w	.2						;branch if faceoff
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
	jsr	(Sroot).l
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

stopfast							;Stop, keeping the animation: Xvel / Yvel toward 0 by $7D0 a frame
									;(stopna2 with a bigger step)
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

checkcornercoll						;Corner circles and side walls for object a3 at d2 / d3 (wcradiusx /
									;wcradiusy); a hit goes to end boards $128
	bclr	#pf3wall,pflags3(a3)	;wall collision bit
	move.w	#$96,d4
	sub.w	(wcradiusx).w,d4
	move.w	#$148,d5
	sub.w	(wcradiusy).w,d5
	movem.w	d2-d5,-(sp)
	neg.w	d4
	neg.w	d5
	addi.w	#$40,d4					;radius
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
	move.w	d3,d0					;cos0 = dy/r
	move.w	d2,d1					;sin0 = -dx/r
	neg.w	d1
	muls.w	d3,d3
	muls.w	d2,d2
	add.l	d2,d3					;dist from dot
	cmp.l	#$1000,d3
	bls.w	.2
	exg	d0,d3
	jsr	(Sroot).l
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
	move.w	#$100,d0				;now check side walls
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

cornercollb							;Straight to wallcollb
	jmp	wallcollb

Create_HotCold_Table				;Fill the hot / cold table at $1A4 of team struct a0 with random values
	movem.l	d0-d7,-(sp)
	move.w	#$1BF,d1				;$1C0 values
.0
	move.w	#9,d0					;sets RNG limit (-9 - +8)
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

AttributeCalc						;Attribute d3 of player a3 * 5 plus his hot / cold value / 3 limited to 0
									;... $1E
	movem.l	d0-d2/a1,-(sp)
	move.w	(TempWord2).w,d1
	movea.l	#tmstruct,a1			;Start of Home Team struct
	btst	#pfteam,pflags(a3)
	beq.w	.attribmath
	adda.l	#$39E,a1
.attribmath
	clr.w	d1
	move.b	$67(a3),d1
	asl.w	#4,d1					;shifts d1 4 bits left, moving the values over 1 nibble
	adda.l	#$1BC,a1
	move.b	(a1,d1.w),d1
	ext.w	d1						;sign-extend word. Ex: F5 (-5) -> FFF5
	ext.l	d1						;sign-extend long word. Ex: FFF5 -> FFFFFFF5
	divs.w	#3,d1					;Signed-Div D1 by 3 (FFFFFFF5 / 3, or -5 / 3 = -1r2, or FFFEFFFF
	move.w	d3,-(sp)				;push d3 onto stack
	asl.w	#2,d3					;shift left 2 bits (mult. by 4)
	add.w	(sp)+,d3				;Pop off d3 value and add to d3 (attrib X 5)
	add.w	d1,d3					;add d1 (H/C value) to d3
	bmi.w	.LowerLimit
	cmp.w	#$1E,d3
	blt.w	.MaskAttribMathResult
	move.w	#$1E,d3
	bra.w	.MaskAttribMathResult
.LowerLimit
	clr.w	d3						;if below lower limit (0), set to 0
.MaskAttribMathResult
	andi.w	#$FF,d3
	movem.l	(sp)+,d0-d2/a1
	rts

NextHomeHotPlayer					;d1 = the next home hot player (homehotidx, homehotplayer).
	movem.l	d0/a0,-(sp)
	movea.l	#$FFFFBF98,a0
	move.w	(smallfontptr+6).w,d0
	add.w	d0,d0
	move.w	(a0,d0.w),d1
	cmpi.w	#0,(smallfontptr+6).w
	bge.w	.1
	addq.w	#1,(smallfontptr+6).w
.1
	movem.l	(sp)+,d0/a0
	movea.l	#tmstruct,a1
	rts

NextAwayHotPlayer					;The same for the away team (awayhotidx, awayhotplayer).
	movem.l	d0/a0,-(sp)
	movea.l	#$FFFFBF96,a0
	move.w	(smallfontptr+4).w,d0
	add.w	d0,d0
	move.w	(a0,d0.w),d1			;d1 = the player
	cmpi.w	#0,(smallfontptr+4).w	;0 or more?
	bge.w	.1
	addq.w	#1,(smallfontptr+4).w
	;pop the d0/a0 saved above
.1
	movem.l	(sp)+,d0/a0
	movea.l	#AwShots,a1
	rts
	rts

BuildHotColdLists					;The hot / cold player lists of both teams (SortHotColdStarters,
									;CopyHottestPlayer, CopyColdestPlayer).
	clr.w	(smallfontptr+4).w
	clr.w	(smallfontptr+6).w
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#tmstruct,a0
	bsr.w	BuildTeamHotCold
	movea.l	#$FFFFBF98,a0
	bsr.w	CopyHottestPlayer
	movea.l	#$FFFFBF9C,a0
	bsr.w	CopyColdestPlayer
	movea.l	#AwShots,a0
	bsr.w	BuildTeamHotCold
	movea.l	#$FFFFBF96,a0
	bsr.w	CopyHottestPlayer
	movea.l	#$FFFFBF9A,a0
	bsr.w	CopyColdestPlayer
	movem.l	(sp)+,d0-d7/a0-a6
	rts
BuildTeamHotCold					;Hot and cold list of the team at a0 (GetTeamLines, one nibble each)
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	a0,a2
	adda.l	#$1BC,a2
	move.w	d7,-(sp)
	move.w	$28(a0),d7
	jsr	(GetTeamLines).l
	move.w	(sp)+,d7
	movea.l	#TempLegSpd+2,a1
	move.w	#5,d0
.loop
	move.b	(a0)+,d1
	subq.b	#1,d1
	move.b	d1,(a1)+
	ext.w	d1
	asl.w	#4,d1
	clr.b	(a1)
	addq.w	#3,d1
	move.w	#3,d7
.loop2
	clr.w	d2
	move.b	(a2,d1.w),d2
	cmp.b	#9,d7
	beq.w	.1
	cmp.b	#$D,d7
	beq.w	.1
	add.b	d2,(a1)
.1
	addq.w	#1,d1
	addq.w	#1,d7
	cmp.b	#$10,d7
	bne.s	.loop2
	tst.b	(a1)+
	dbf	d0,.loop
.loop3
	movea.l	#TempLegSpd+2,a1
	clr.w	d1
	move.w	#4,d0
.loop4
	move.b	3(a1),d6
	cmp.b	1(a1),d6
	ble.w	.2
	st	d1
	move.w	2(a1),d2
	move.w	(a1),2(a1)
	move.w	d2,(a1)
.2
	tst.w	(a1)+
	dbf	d0,.loop4
	tst.w	d1
	bne.s	.loop3
	movem.l	(sp)+,d0-d7/a0-a6
	rts

NextHomeColdPlayer					;d1 = the next home cold player (homecoldidx, homecoldplayer).
	movem.l	d0/a0,-(sp)
	movea.l	#$FFFFBF9C,a0
	move.w	($FFFFBF94).w,d0
	add.w	d0,d0
	move.w	(a0,d0.w),d1
	cmpi.w	#0,($FFFFBF94).w
	bge.w	.1
	addq.w	#1,($FFFFBF94).w
.1
	movem.l	(sp)+,d0/a0
	movea.l	#tmstruct,a1
	rts

NextAwayColdPlayer					;The same for the away team (awaycoldidx, awaycoldplayer).
	movem.l	d0/a0,-(sp)
	movea.l	#$FFFFBF9A,a0
	move.w	(smallfontptr+8).w,d0
	add.w	d0,d0
	move.w	(a0,d0.w),d1			;d1 = the player
	cmpi.w	#0,(smallfontptr+8).w	;0 or more?
	bge.w	.1
	addq.w	#1,(smallfontptr+8).w
	;pop the d0/a0 saved above
.1
	movem.l	(sp)+,d0/a0
	movea.l	#AwShots,a1
	rts
	rts

CopyHottestPlayer					;Copy the hottest player of TempBuffer to the list a0.
	movem.l	d0-d1/a0-a1,-(sp)
	movea.l	#TempLegSpd+2,a1
	move.w	#0,d0
.loop
	clr.b	(a0)+
	move.b	(a1),d1
	move.b	d1,(a0)+
	tst.w	(a1)+
	dbf	d0,.loop
	movem.l	(sp)+,d0-d1/a0-a1
	rts

CopyColdestPlayer					;Copy the coldest player of TempBuffer to the list a0.
	movem.l	d0/a0-a1,-(sp)
	movea.l	#pstatslast,a1
	move.w	#0,d0
.loop
	clr.b	(a0)+
	move.b	(a1),(a0)+
	tst.w	-(a1)
	dbf	d0,.loop
	movem.l	(sp)+,d0/a0-a1
	rts

CompareHotColdTotals				;Compare the hot / cold totals of the teams (GetHotColdTotal): d0 = $22 /
									;$23 (the better team, awayhotter)
									;when they differ enough, else -1.
	movem.l	d1-d7/a0-a6,-(sp)
	movea.l	#tmstruct,a0
	bsr.w	GetHotColdTotal
	move.w	d1,(TempWord1).w
	movea.l	#AwShots,a0
	bsr.w	GetHotColdTotal
	move.w	d1,(TempWord2).w
	move.w	(TempWord1).w,d1
	move.w	(TempWord2).w,d2
	sub.w	d1,d2
	move.w	#0,($FFFFBF86).w
	tst.w	d2
	bmi.w	.1
	move.w	#1,($FFFFBF86).w
.1
	tst.w	d2
	bpl.w	.2
	neg.w	d2
.2
	move.w	#$FFFF,d0
	cmp.w	#$5E,d2
	blt.w	.3
	move.w	#$22,d0
	cmp.w	#$BD,d2
	blt.w	.3
	move.w	#$23,d0
.3
	movem.l	(sp)+,d1-d7/a0-a6
	rts

GetHotColdTotal						;d1 = the hot / cold total of the starters of team a0
									;(SortHotColdStarters, TempBuffer).
	bsr.w	BuildTeamHotCold
	move.w	#6,d0
	movea.l	#TempLegSpd+2,a0
	clr.w	d1
.loop
	move.b	1(a0),d2
	ext.w	d2
	add.w	d2,d1
	tst.w	(a0)+
	dbf	d0,.loop
	rts
	rts
	rts
	movem.l	d0-d7,-(sp)
	bclr	#0,(SetupSpare).w		;card up?
	beq.w	.2
	bclr	#6,(SetupSpare).w		;no visitors block
	bclr	#7,(SetupSpare).w		;no home block
	jsr	(printz).l					;map at the card
	String	$EF,0,0
	move.w	#5,(printy).w
	moveq	#8,d0
	moveq	#8,d1
	move.w	#$7FF,d2				;blank char
	btst	#1,(SetupSpare).w		;visitors side?
	beq.w	.1
	move.w	#3,(printx).w
	jsr	(eraser).l
	jsr	(printz).l					;map at the text
	String	$FF,0,0
	move.w	#$B,(printx).w
	move.w	#5,(printy).w
	move.w	#$19,d0
	move.w	#8,d1
	;(not branched to)
	move.w	#$7FF,d2				;blank char
	jsr	(eraser).l
	bra.w	.2
	;bit 1 of setupcardflags clear
.1
	move.w	#$1C,(printx).w
	jsr	(eraser).l
	jsr	(printz).l					;map at the text
	String	$FF,0,0
	move.w	#3,(printx).w
	move.w	#5,(printy).w
	move.w	#$19,d0
	move.w	#8,d1
	move.w	#$7FF,d2				;blank char
	jsr	(eraser).l
	;exit: restore the registers
.2
	movem.l	(sp)+,d0-d7
	rts
	move.w	#$AA,($FFFFD30E).w
	btst	#5,(SetupSpare).w
	beq.w	.3
	move.w	#$53,($FFFFD30E).w
.3
	rts

wallcollduringcheck					;During a check, a skater a2 (not a goalie) near the wall: test the wall
									;at his position with his size + $17.
									;Called from CCStart and FallDown
	tst.w	$34(a2)
	beq.w	.end
	movem.l	d0-d7,-(sp)
	move.w	(a2),d2					;Xpos of checking player
	move.w	Ypos(a2),d3
	move.w	$4A(a2),(wcradiusx).w
	addi.w	#$17,(wcradiusx).l		;add $17 to wcradiusx
	move.w	$4C(a2),(wcradiusy).w
	addi.w	#$17,(wcradiusy).l		;add $17 to wcradiusy
	movem.l	a0-a6,-(sp)
	exg	a2,a3						;swap a2 and a3
	jsr	(checkcornercoll).l
	exg	a2,a3						;swap a2 and a3
	movem.l	(sp)+,a0-a6
	movem.l	(sp)+,d0-d7
.end
	rts

setSlotBit							;sflags6 bit 5 (the slot) = the puck carrier is in the slot
	bclr	#5,(sflags6).w			;clears Slot Bit
	tst.w	(puckc).w
	bmi.w	.x						;exit if no puckc
	movem.l	d0/a0,-(sp)
	movea.l	#SortCords,a0			;start of SCStructs
	move.w	(puckc).w,d0			;move puckc SCnum into d0
	asl.w	#7,d0					;mult by 128 decimal
	adda.w	d0,a0					;move to start of puckc SCstruct
	move.w	Ypos(a0),d0				;Ypos
	btst	#pfgoal,pflags(a0)		;pfgoal - which goal shooting at
	bne.w	.checkpos				;jump if top goal
	neg.w	d0						;negative d0
.checkpos
	cmp.w	#$76,d0					;compare to blueline
	blt.w	.restore				;branch if not in off zone
	cmpi.w	#$51,(a0)				;compare X position to $47
	bgt.w	.restore				;branch if greater than 47
	cmpi.w	#$FFAF,(a0)				;compare X position to -$47
	blt.w	.restore				;branch if less than -47
	bset	#5,(sflags6).w			;set bit
.restore
	movem.l	(sp)+,d0/a0
.x
	rts

TeamLogoPalettes2					;Team logo palettes, a second set (nothing in the listing uses it)
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

CopyString							;Copy String a1 (length word first) to a3.
	movem.l	d0,-(sp)
	move.w	(a1),d0
	subq.w	#1,d0
.loop
	move.b	(a1)+,(a3)+
	dbf	d0,.loop
	movem.l	(sp)+,d0
	rts
	movem.w	d0-d6/a0,-(sp)
	move.l	a1,-(sp)				;keep the String start
	move.w	d0,d6
	addq.l	#2,a1					;leave room for the length word
	clr.w	d1
	ext.l	d0
	divu.w	#$64,d0					;hundreds digit
	tst.w	d0						;any hundreds?
	beq.w	.1						;no hundreds: no leading zero
	addi.w	#$30,d0
	move.b	d0,(a1)+
	addq.w	#1,d1
	;no hundreds digit, or it was written: now the tens
.1
	swap	d0
	ext.l	d0						;clear the high word
	divu.w	#$A,d0					;tens digit
	addi.w	#$30,d0
	cmp.b	#$30,d0					;tens 0 is skipped only for values below 10
	bne.w	.2
	cmp.w	#$A,d6					;below 10?
	blt.w	.3						;yes: no tens digit
	;tens digit wanted (non-zero, or a hundreds digit came before)
.2
	move.b	d0,(a1)+
	addq.w	#1,d1
	;value below 10, or the tens is written: now the ones
.3
	swap	d0						;ones digit from the remainder
	addi.w	#$30,d0
	move.b	d0,(a1)+
	addq.w	#1,d1
	btst	#0,d1					;odd length: pad with a 0 byte so the String stays word aligned
	beq.w	.4						;even already
	move.b	#0,(a1)+				;pad byte
	addq.w	#1,d1
	;length now even: write the length word
.4
	movea.l	(sp)+,a0
	addq.w	#2,d1					;length counts the 2-byte header
	move.w	d1,(a0)
	movem.w	(sp)+,d0-d6/a0
	rts

ReadTeamRecord						;Read the 16 byte team record block d1 ($D22 + d1 * 16) to a0
									;(TeamRecordIO)
	bclr	#6,(sflags6).w

TeamRecordIO						;The team record block: read or write (sflags6 bit 6)
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

WriteTeamRecord						;Write the team record block (TeamRecordIO)
	bset	#6,(sflags6).w
	bra.s	TeamRecordIO

WriteNameLog						;Write the user name log ($80 bytes at namelog) to save RAM SRNameLog
	bset	#6,(sflags6).w
	bra.w	NameLogIO

ReadNameLog							;Read the user name log from save RAM SRNameLog to namelog
	bclr	#6,(sflags6).w

NameLogIO							;Read or write (sflags6 bit 6) the name log
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

UpdateRecords						;With save RAM (ValidSRAM) and user records on (OptUserRec 0), update the
									;player records (UpdatePlayerRecords), with sflags11 bit 7 the crowd
									;records of both teams (UpdateCrowdRecord), then the team record of each
									;pad (UpdateUserRecord), then the save RAM checksum
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

UpdateTeamRecord					;Add the game of team a1 (against a2) to team record block d1 (games,
									;wins, ties) with sflags11 bit 7 keep the
									;biggest win and loss margins with users d3 / d4 and team d2
									;(WriteTeamRecord)
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

CountGoalies						;homegoalies / awaygoalies = goalies of the home / away team
									;(GetGoalieCount)
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#tmstruct,a2
	jsr	(GetGoalieCount).l
	move.w	d0,(homegoalies).w
	movea.l	#AwShots,a2
	jsr	(GetGoalieCount).l
	move.w	d0,(awaygoalies).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts

CountPlayers						;homeplayers / awayplayers = players of the home / away team
									;(GetPlayerCount)
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#tmstruct,a2
	jsr	(GetPlayerCount).l
	move.w	d0,(homeplayers).w
	movea.l	#AwShots,a2
	jsr	(GetPlayerCount).l
	move.w	d0,(awayplayers).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts

AppendUserName						;Append user name d2 (12 bytes of the name log at namelog, spaces for 0)
									;to a1, or NoNameTxt when d2 is 0
									;trailing spaces trimmed (TrimSpaces).
	movem.l	d0-d3/a0-a3,-(sp)
	movea.l	a1,a2
	tst.w	d2
	beq.w	.3
	move.w	#9,d0
	clr.w	d3
	movea.l	#namelog,a0
	mulu.w	#$A,d2
	adda.l	d2,a0
.loop
	move.b	(a0,d3.w),d1
	bne.w	.1
	move.b	#$20,d1
.1
	move.b	d1,2(a1)
	tst.b	(a1)+
	addq.w	#1,d3
	dbf	d0,.loop
	move.w	#$C,(a2)
	btst	#7,(sflags6).w
	beq.w	.2
	bsr.w	TrimSpaces
.2
	bra.w	.4
.3
	movea.l	a1,a3
	move.l	a3,-(sp)
	movea.l	#$1D7DCA,a1
	jsr	(CopyString).l
	movea.l	(sp)+,a2
	bsr.w	TrimSpaces
.4
	movem.l	(sp)+,d0-d3/a0-a3
	rts
	dc.w	$0002

AppendTeamName						;Append the city name of team d0 (TeamList block Strings) to a1
									;(appstring).
	movem.l	d0/a0-a3,-(sp)
	ext.w	d0
	asl.w	#2,d0
	movea.l	#$77E,a0
	movea.l	(a0,d0.w),a0
	move.w	4(a0),d0
	ext.l	d0
	adda.l	d0,a0
	adda.w	(a0),a0
	movea.l	a1,a3
	movea.l	a0,a1
	jsr	(appstring).l
	movem.l	(sp)+,d0/a0-a3
	rts

CalcAttrib							;The overall rating of player d0: his attributes weighted by
									;OvrPlayerWgtList (skaters) or OvrGoalWgtList
									;(goalies), and by AttribWgtList. Called from getNameandAttrib and
									;PrintOverallRating
	move.l	a6,-(sp)				;push a6 to stack
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
	clr.l	d1						;clear d1
	move.w	d0,d1					;move d0 into d1. d0 is the offset of the player
	asl.w	#4,d1					;mult d1 by 16
	adda.l	d1,a4					;add d1 to a4
	adda.l	#$10,a4					;add 16 dec to a4. Move to start of Hot/Cold for player.
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

OvrPlayerWgtList					;Skater attribute weights for the overall rating (CalcAttrib)
	dc.b	$02,$02,$02,$02,$04,$06,$02,$04,$02,$04,$06,$06,$04,$02,$02,$02

OvrGoalWgtList						;Goalie attribute weights
	dc.b	$02,$02,$02,$02,$02,$02,$02,$02,$09,$09,$02,$02,$09,$02,$02,$02

AttribWgtList						;Single attribute weights
	dc.b	$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02

TrimSpaces							;Trim the trailing spaces of String a2 and pad it to an even length.
	movem.l	a3,-(sp)
	movea.l	a2,a3
	adda.w	(a2),a3
.loop
	move.b	-(a3),d0
	cmp.b	#$20,d0
	bne.w	.1
	move.b	#0,(a3)
	subq.w	#1,(a2)
	bra.s	.loop
.1
	addq.w	#1,(a2)
	andi.w	#$FE,(a2)
	movem.l	(sp)+,a3
	rts

