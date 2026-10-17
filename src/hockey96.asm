;	The cold start and the game loop. Begin clears RAM and goes to the title. StartGame and
;	StartPer start a game and a period. Gameloop and DoGameFrame run a frame: the crowd, the
;	clock, and the bench.

Begin	;Cold start, entered from Start. Clear RAM, init sound and menus, go to the title screen
	move	#$2700,sr	;interrupts off
	movea.w	#(Stack-M68K_RAM),sp
	movea.w	#(VSCRLPM-M68K_RAM),a0
.0
	clr.l	(a0)+
	cmpa.w	#$DDC6,a0
	blt.s	.0
	clr.w	(PALflag).w
	move.w	(VDP_CTRL).l,d0
	andi.w	#1,d0
	move.w	d0,(PalMode).w
	beq.w	.1
	bset	#0,(PALflag).w
.1
	move.w	#$FFFF,(PlayingSong).w
	move.w	#0,d0
	move.w	#$1B24,d1
	movea.l	#Z80Program,a0
	jsr	(SoundCmd).l
	move.w	#9,d0	;command 9
	jsr	(SoundCmd).l
	move.w	#6,d0	;command 6: the sound data
	clr.w	d1
	movea.l	#SoundBanks,a0
	jsr	(SoundCmd).l
	move.w	#7,d0
	move.w	#0,d1
	jsr	(SoundCmd).l
	jsr	(SoundOff).l
	jsr	(KillCrowd).l
	jsr	(Detect4WayPlay).l
	jsr	(EASportsScreen).l
	jsr	(InitSaveRAM).l
	jsr	(HiScoreScreen).l
	jsr	(DefaultMenus).l
	move.w	(OptLine).w,(TmpOptLine2).w
	move.w	(OptPlayMode).w,(TempOptPlayMode).w
	jsr	(orjoy).l
	jmp	Opening

StartGame	;Reset game state for a new game, then start the first period
	move.l	#VBlank,(vbint).l
	clr.w	(RefStep).w
	bclr	#5,(GameFlags).w
	st	(byte_FFD474).w
	jsr	(ReadJoy1).l
	cmp.b	#$E0,d3
	bne.w	.0
	move.w	#3,(OptPerlen).w
.0
	clr.b	(gmode).w
	cmpi.w	#1,(OptPen).w
	bne.w	.1
	bset	#5,(gmode).w
.1
	cmpi.w	#1,(OptPlayMode).w
	ble.w	.2
	bsr.w	sub_14804
.2
	jsr	(clearTeamStats).l
	btst	#0,(gmode2).w
	beq.w	.3
	move.l	a0,-(sp)
	movea.l	#tmstruct,a0
	jsr	(Create_HotCold_Table).l
	movea.l	#AwShots,a0
	jsr	(Create_HotCold_Table).l
	movea.l	(sp)+,a0
.3
	clr.w	(ScoreSumbytes).w
	clr.w	(PenSumLength).w
	clr.w	(gsp).w
	clr.w	(ChkCnt).w
	bsr.w	restoreteams
	jsr	(stop_current_song).l	;stop the song
	move.w	#9,d0	;restart the sound driver as Begin does
	jsr	(SoundCmd).l
	move.w	#0,d0	;command 0: load the Z80 program
	move.w	#$1B24,d1
	movea.l	#Z80Program,a0
	jsr	(SoundCmd).l
	move.w	#6,d0
	clr.w	d1
	movea.l	#SoundBanks,a0
	jsr	(SoundCmd).l
	move.w	#7,d0
	move.w	#1,d1
	jsr	(SoundCmd).l
	move.b	#$E7,(VDP_PSG).l
	move.b	#$C8,(VDP_PSG).l
	move.b	#1,(VDP_PSG).l
	jsr	(InitScores).l
	jsr	(setupice).l
	jsr	(InitCrowdMeter).l
	jmp	IntermissionStart

sub_14804
	move.l	#$E68,d0
	moveq	#$66,d1
	jsr	(ClearSRAMBytes).l
	jsr	(MakeSRAMChecksum).l
	rts

restoreteams	;Both teams: no players in the penalty box, every roster player on the bench
	movea.w	#(tmstruct-M68K_RAM),a2
	bsr.w	.r
	adda.w	#$39E,a2
.r
	move.w	#6,tmap(a2)	;tmap: no players in pen. box
	moveq	#$36,d0	;(maxros-1)*2
.1
	move.w	#$FFFE,$6C(a2,d0.w)
	subq.w	#2,d0
	bpl.s	.1
	rts

ResetClock	;gameclock = PerTimeTotal = the period length (GetPeriodTime; overtime by OptPlayMode), clock stopped (gmclock)
	bsr.w	GetPeriodTime	;d0 = period length in seconds
	cmpi.w	#3,(gsp).w
	blt.w	.2
	tst.w	(OptPlayMode).w
	bne.w	.0
	move.w	#$12C,d0	;OptPlayMode 0 overtime is always 5:00
	bra.w	.2
.0
	cmpi.w	#3,(OptPlayMode).w
	bgt.w	.1
	move.w	#$4B0,d0
	bra.w	.2
.1
	btst	#7,(GameFlags).w
	beq.w	.2
	btst	#2,(SeasonFlags).w
	beq.w	.2
	move.w	#$4B0,d0
.2
	move.w	d0,(gameclock).w
	move.w	d0,(PerTimeTotal).w
	move.w	d0,(periodendtime).w
	asr.w	#1,d0
	jsr	(randomd0).l
	sub.w	d0,(periodendtime).w
	bset	#0,(gmode).w
	rts

GetPeriodTime	;Return d0 = period length in seconds for the period length option
	move.w	(OptPerlen).w,d0
	asl.w	#1,d0
	lea	.times(pc),a0
	move.w	(a0,d0.w),d0
	rts
.times
	dc.w	$12C,$258,$4B0,$1E

StartPer	;Start a period: reset stack, rink and clock, face off, run the game loop
	cmpi.w	#3,(gsp).w
	bne.w	.0
	bset	#1,(sflags7).w
	bset	#5,(GameFlags).w
.0
	st	(byte_FFD47E).w
	movea.w	#(Stack-M68K_RAM),sp
	jsr	(SoundOff).l
	jsr	(setupice).l
	bsr.w	ResetClock
	ori.l	#$F00000,(PadControlBits).w
	st	(c1playernum).w
	st	(c2playernum).w
	st	(c3playernum).w
	st	(c4playernum).w
	movea.w	#(puckx-M68K_RAM),a3
	clr.w	(fox).w
	clr.w	(foy).w
	btst	#0,(gmode2).w
	beq.w	.1
	move.w	#$1E,d0
	move.w	#8,(BA_Skater_Offset).w
	move.w	#$B,(BA_Goalie_SCnum).w
	bra.w	.ass
.1
	jsr	(stop_current_song).l
	move.w	#9,d0
	jsr	(SoundCmd).l
	move.w	#0,d0
	move.w	#$1B24,d1
	movea.l	#Z80Program,a0
	jsr	(SoundCmd).l
	move.w	#6,d0
	clr.w	d1
	movea.l	#SoundBanks,a0
	jsr	(SoundCmd).l
	move.w	#7,d0
	move.w	#1,d1
	jsr	(SoundCmd).l
	moveq	#$1B,d0
.ass
	jsr	(assreplace).l
	bset	#2,(sflags2).w
	bclr	#4,(sflags).w
	move.w	#$FFFF,(lastsfx).w
	move.l	#M68K_RAM,(recbpr).w
	move.w	(vcount).w,(oldvcount).w
	bsr.w	DoGameFrame
	move.w	#$FFFF,(palcount).w
	bsr.w	DoGameFrame
	move.w	(gamelevel).w,d0
	asl.w	#4,d0
	move.w	d0,(CwdExciteLvl).w
	clr.w	(CurCrowdMeter).w
	move.w	(HomeTeam).w,(HmTeam).w
	move.w	#0,(SongIndex).w
	jsr	(ChooseSong).l
	move.w	(SongNum).w,-(sp)
	jsr	(song).l
	cmpi.w	#2,(gsp).w
	bge.w	Gameloop
	bset	#7,(sflags3).w

Gameloop	;Main loop for game
	bsr.w	DoGameFrame
	bsr.w	demoread
	btst	#0,(sflags).w
	beq.s	Gameloop
	bsr.w	Pausemode
	bra.s	Gameloop

DoGameFrame	;Wait for at least one vblank, then run one frame of game logic
	move.w	(vcount).w,d7
	sub.w	(oldvcount).w,d7
	beq.s	DoGameFrame
	move.w	(vcount).w,(oldvcount).w
	bsr.w	DoFrameUpdates
	btst	#6,(sflags3).w
	beq.w	.0
	jsr	(sub_FD14).l
	jsr	(sub_FFD0).l
.0
	bsr.w	updateplayers
	tst.w	(songdelay).w
	beq.w	.1
	bmi.w	.1
	subq.w	#1,(songdelay).w
	bne.w	.1
	jsr	(stop_current_song).l
	move.w	(delayedsong).w,-(sp)
	jsr	(song).l
.1
	jsr	(setSlotBit).l
	bsr.w	checkwindow
	bsr.w	updatereplay
	jmp	setvideo

DoFrameUpdates	;The frame updates of DoGameFrame: the new puck carrier check, the crowd, the clock, and once a second
	;(lldisp) the slower updates
	move.w	(lastpuckc).w,d0
	cmp.w	(puckc).w,d0
	beq.w	.0
	bclr	#0,(GameFlags).w
	bclr	#1,(GameFlags).w
.0
	move.w	(puckc).w,(lastpuckc).w
	tst.w	(puckc).w
	bmi.w	.1
	st	(word_FFD238).w
.1
	jsr	(PenaltyManager).l
	bsr.w	updatecrowdf
	jsr	(RunArenaAnim).l
	jsr	(updatesound).l
	bsr.w	clockcont
	btst	#7,(sflags).w
	bne.w	rtss8
	sub.w	d7,(lldisp).w
	bpl.w	rtss8
	addi.w	#$18,(lldisp).w
	bsr.w	ChkGoalies
	jsr	(UpdateCwdExcite).l
	jsr	(CheckLateGameSong).l
	bsr.w	RestoreBenchEnergy
	bsr.w	CheckInjury
	jmp	updatepwrplay

CheckInjury	;The injury message when its timer (InjCntDown) runs out (ShowInjuryBox)
	subq.w	#1,(InjCntDown).w
	bne.w	rtss8
	jmp	ShowInjuryBox

RestoreBenchEnergy	;Unless OptLine: every bench player of both teams gets 9 energy, up to $1000
	tst.w	(OptLine).w
	bne.w	.ex
	movea.w	#(tmstruct-M68K_RAM),a2
	bsr.w	.notinprog
	lea	$39E(a2),a2
.notinprog
	moveq	#$36,d0
.b0
	cmpi.w	#$FFFE,$6C(a2,d0.w)
	bne.w	.next
	addi.w	#9,tmpde(a2,d0.w)
	cmpi.w	#$1000,tmpde(a2,d0.w)
	blt.w	.next
	move.w	#$1000,tmpde(a2,d0.w)
.next
	subq.w	#2,d0
	bpl.s	.b0
.ex
	rts

updatecrowdf	;Every game loop, d7 = elapsed frames: the crowd level falls (faster when loud); every crowdcnt frames
	;the next crowd frame
	cmpi.w	#$15E,(crowdlevel).w
	blt.w	.dec
	subq.w	#3,(crowdlevel).w
.dec
	sub.w	d7,(crowdlevel).w
	bpl.w	.1
	clr.w	(crowdlevel).w
.1
	sub.w	d7,(crowdcnt).w
	bpl.w	.2
	move.w	(crowdlevel).w,d0
	lsr.w	#1,d0
	cmp.w	#$7F,d0
	bls.w	.0
	moveq	#$7F,d0
.0
	andi.w	#$60,d0
	addq.w	#2,(crowdtblidx).w
	andi.w	#$1E,(crowdtblidx).w
	add.w	(crowdtblidx).w,d0
	movea.l	#CrowdFrameTbl,a0
	move.b	(a0,d0.w),(crowdframe+1).w
	clr.w	d1
	move.b	1(a0,d0.w),d1
	move.w	(VDP_CNTR).l,d2
	and.w	d1,d2
	add.w	d2,d1
	move.w	d1,(crowdcnt).w
.2
	clr.b	(crowdframe).w
	cmpi.w	#$118,(crowdlevel).w
	bls.w	rtss8
	move.w	(VDP_CNTR).l,d0
	andi.w	#$7F,d0
	cmp.w	#$13,d0
	blt.w	rtss8
	cmp.w	#$19,d0
	bgt.w	rtss8
	move.b	d0,(crowdframe).w
	rts

clockcont	;At the end of the period clock (gameclock 0): the horn, then the end of period or game assignments
	btst	#0,(gmode).w
	bne.w	rtss8
	tst.w	(gameclock).w
	bne.w	rtss8
	bset	#3,(disflags).w
	jsr	(stop_current_song).l
	move.w	#4,-(sp)
	jsr	(sfx).l
	bsr.w	LockScroll
	movea.w	#(puckx-M68K_RAM),a3
	moveq	#$18,d0
	jsr	(assinsert).l
	cmpi.w	#2,(gsp).w
	blt.w	.1
	moveq	#7,d0
	movea.w	#(SortCords-M68K_RAM),a3
	cmpi.w	#3,(gamelevel).w
	bne.w	.t3
	cmpi.w	#7,(bosgames).w
	beq.w	.0
	moveq	#$10,d3
	mulu.w	(gamenum).w,d3
	movea.w	#(gsstruct-M68K_RAM),a0
	adda.w	d3,a0
	clr.w	d3
	btst	#0,$E(a0)
	beq.w	.nf
	eori.w	#2,d3
.nf
	move.w	(HmGoals).w,d1
	sub.w	(AwGoals).w,d1
	bpl.w	.ns1
	eori.w	#2,d3
.ns1
	cmpi.w	#3,4(a0,d3.w)
	bne.w	.t3
.0
	moveq	#8,d0
	moveq	#$B,d2
.4
	bclr	#3,$62(a3)
	adda.w	#$80,a3
	dbf	d2,.4
	movea.w	#(SortCords-M68K_RAM),a3
.t3
	moveq	#5,d2
	move.w	(HmGoals).w,d1
	sub.w	(AwGoals).w,d1
	beq.w	.1
	bpl.w	.t2
	adda.w	#$300,a3
.t2
	tst.w	$34(a3)
	ble.w	.n2
	jsr	(assinsert).l
	moveq	#7,d0
.n2
	adda.w	#$80,a3
	dbf	d2,.t2
.eog
	jsr	(ClearPenaltyBuffer).l
	addi.w	#$3E8,(crowdlevel).w
	bset	#0,(gmode).w
	bset	#6,(gmode).w
	jsr	(ClearPenalties).l
	move.w	#4,d0
	jmp	AddPenalty2
.1
	cmpi.w	#3,(gsp).w
	bne.w	.eop_ex
	tst.w	(OptPlayMode).w
	beq.s	.eog
.eop_ex
	move.w	#2,d0
	jmp	AddPenalty2

