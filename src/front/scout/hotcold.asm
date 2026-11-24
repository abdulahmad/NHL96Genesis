;	The hot and cold player lists.

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
	move.w	tmteam(a0),d7
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

