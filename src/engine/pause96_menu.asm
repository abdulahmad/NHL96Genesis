;	Three pause-menu entries. PlayoffStatsMenu opens the playoff stats, TimeoutMenu calls a
;	timeout, and SelectGoalieMenu changes the goalie.

PlayoffStatsMenu					;Pause menu Playoff Stats: with GameFlags bit 7 set jump to
									;SeasonPlayoffStats, else PlayerStatsList for the team struct of team
									;potree + potreeteam
	btst	#7,(GameFlags).w
	beq.w	.0
	jmp	SeasonPlayoffStats
.0
	movem.l	a2,-(sp)
	jsr	(ReadTeamStats).l
	movea.w	#(potree-M68K_RAM),a0
	move.w	(potreeteam).w,d0
	move.b	(a0,d0.w),d0
	movea.w	#(tmstruct-M68K_RAM),a2
	cmp.w	$28(a2),d0
	beq.w	.1
	adda.w	#$39E,a2
.1
	moveq	#1,d7
	jsr	(PlayerStatsList).l
	movem.l	(sp)+,a2
	rts

ExitStatsScreen						;Leave a stats screen: forceblack, then reload the rink graphics (the
									;entry after the forceblack)
	bsr.w	forceblack
ExitStatsScreenReload	equ	*
	move.w	(disflags).w,-(sp)
	bset	#dfng,(disflags).w
	move.w	(VSCRLPM).w,d0
	bsr.w	Vmaddr
	move.l	#$0,(a0)
	move.w	#$8D00,d0				;register $D: hscroll table
	move.b	(VSCRLPM).w,d0
	lsr.b	#2,d0
	move.w	d0,4(a0)
	move.w	#VDPR_MODE4,4(a0)
	move.w	#5,(Map3col1).w
	move.w	(sp)+,(disflags).w
	bset	#df32c,(disflags).w
	move.w	(rinkvrcset).w,d4
	movea.l	#$923EC,a2
	btst	#4,(sflags4).w			;check if reverse angle replay
	beq.w	.1
.1
	bsr.w	DecompressGraphicsPlain
	jsr	(LoadHomeTeamGfx).l
	jsr	(LoadReplayIcon).l
	move.w	(smallfontchars).w,d4
	jsr	(LoadSmallFont).l
	move.w	(framercset).w,d4		;frame chars
	jsr	(AddFramer).l				;send the frame tiles
	jsr	(setupEASNmap).l
	jsr	(LoadEnergyBarTiles).l
	jsr	(LoadCrowdFrames).l
	jsr	(setupIceRinkPal).l
	bset	#7,(sflags11).w
	jmp	(setplayercolors).l

TimeoutMenu							;Pause menu Timeout.
	jsr	(ClearMenuBox).l
	subq.w	#1,(menuitem).w
	subq.w	#1,(menuitem+2).w
	move.l	#PauseMenuNoTimeout,(menulist).l	;pause menu without Timeout
	bset	#2,$30(a2)
	bsr.w	printz					;map at the box position
	String	-(TXPRI+TXMAP1),4,$C
	moveq	#$16,d0
	moveq	#6,d1
	bsr.w	printbigcurz
	String	$F8,4,1,$C,6,$F9,1,'    Timeout',$F8,4,1,$15,8
	movea.l	$1E(a2),a1				;team name, centred
	adda.w	4(a1),a1
	move.w	(a1),d0
	lsr.w	#1,d0
	sub.w	d0,(printx).w
	bsr.w	printbigcur
	movea.w	#(tmstruct-M68K_RAM),a2
	jsr	(RestoreTeamEnergy).l
	adda.w	#$39E,a2
	jsr	(RestoreTeamEnergy).l
	btst	#0,(gmode).w
	bne.w	.1
	clr.w	(fodropx).w
	clr.w	(fodropy).w
	move.w	#$A,d0
	jsr	(AddPenalty2).l
.1
	moveq	#$78,d0
	bra.w	waitx

SelectGoalieMenu					;Pause menu Change Goalie.
	jsr	(ClearMenuBox).l
	move.w	(menuitem).w,-(sp)		;save the menu state
	move.w	(menuitem+2).w,-(sp)
	bsr.w	GetGoalieCount
	move.w	d0,(menuitem+2).w
	bsr.w	printz
	String	-(TXPRI+TXMAP1),4,$C
	moveq	#$18,d0
	moveq	#3,d1
	add.w	(menuitem+2).w,d1
	move.w	$26(a2),d0
	bpl.w	.1
	moveq	#-$1,d0
.1
	addq.w	#1,d0					;row of the current goalie (0 = goalie pulled)
	move.w	d0,(menuitem).w
.loop
	bsr.w	PrintSelectGoalieItem
	bsr.w	WaitVSyncAndReadInput	;wait for a press
	btst	#7,d1
	bne.w	.done					;Start confirms
	btst	#5,d1
	bne.w	.done
	btst	#1,d1
	beq.w	.up
	move.w	(menuitem).w,d0
	addq.w	#1,d0
	cmp.w	(menuitem+2).w,d0		;past the last?
	bgt.s	.loop
	move.w	d0,(menuitem).w
.up
	btst	#0,d1					;up pressed: move the selection up
	beq.s	.loop
	subq.w	#1,(menuitem).w
	bpl.s	.loop
	clr.w	(menuitem).w			;stop at the first row
	bra.s	.loop
.done
	move.w	(menuitem).w,d0
	subq.w	#1,d0					;goalie number
	bpl.w	.set
	btst	#0,(sflags2).w
	beq.w	.set
	move.w	#$A,($FFFFB79E).w
.set
	move.w	d0,$26(a2)				;a goalie row: put him in
	jsr	(setpersonel).l
	move.w	(sp)+,(menuitem+2).w
	move.w	(sp)+,(menuitem).w
	rts
PrintSelectGoalieItem				;Pause menu Change Goalie: print the item at the cursor with the big font
	move.w	#6,(printy).w
	move.w	(menuitem+2).w,d1
	moveq	#0,d0
.loop
	move.w	#$B,(printx).w
	jsr	(printbigcurz).l
	String	$FE,4,$FF,1,$F9,1
	cmp.w	(menuitem).w,d0
	bne.w	.1
	jsr	(printbigcurz).l
	String	$FE,4,$FF,1,$F9,2
.1
	bsr.w	printbigcurz
	String	'                  '
	tst.w	d0
	bne.w	.2
	move.w	#$B,(printx).w
	bsr.w	printbigcurz
	String	'  no goalie  '
	bra.w	.5
.2
	move.w	d0,d2
	subq.w	#1,d2
	move.w	d2,(TempPlOffset).w
	cmpa.l	#tmstruct,a2
	beq.w	.3
	st	(TempPlOffset).w
.3
	jsr	(GetPlayerInitial).l
	move.w	#$B,(printx).w
	jsr	(printbigcurz).l
	String	'  '
	cmpi.l	#$1B89C8,(bigfontptr).l
	bne.w	.4
	bset	#6,(sflags13).w
.4
	bsr.w	printbigcur
	bclr	#6,(sflags13).w
.5
	addq.w	#2,(printy).w
	addq.w	#1,d0
	dbf	d1,.loop
	rts
