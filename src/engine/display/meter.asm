;	The crowd meter.

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

