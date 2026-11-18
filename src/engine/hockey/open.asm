;	Between periods and back to the title. IntermissionStart ends a period,
;	Opening runs the title, and EASportsScreen is the logo.

PeriodOver							;End of period: next period, overtime or game over (gsp 4); forceblack,
									;then into IntermissionStart
	addq.w	#1,(gsp).w
	bchg	#gmdir,(gmode).w
	cmpi.w	#3,(gsp).w
	blt.w	.2
	beq.w	.1
	move.w	#3,(gsp).w
	tst.w	(OptPlayMode).w
	bne.w	.1
	move.w	#4,(gsp).w
.1
	move.w	(HmGoals).w,d0
	sub.w	(AwGoals).w,d0
	beq.w	.2
	move.w	#4,(gsp).w
.2
	bsr.w	forceblack

IntermissionStart					;The end of a period: ResetClock, restart the sound driver, Intermission,
									;then GameOver or StartPer
	jsr	(ResetClock).l
	move.w	d0,-(sp)
	move.w	(Vcount).w,d0
.vb
	cmp.w	(Vcount).w,d0
	beq.s	.vb						;wait for the next vblank
	jsr	(SoundOff).l
	move.w	d0,-(sp)
	move.w	(Vcount).w,d0
.loop
	cmp.w	(Vcount).w,d0
	beq.s	.loop					;wait for the next vblank
	move.w	(sp)+,d0
	jsr	(stop_current_song).l		;stop the song
	move.w	#9,d0					;restart the sound driver as Begin does
	jsr	(SoundCmd).l
	move.w	#0,d0					;command 0: load the Z80 program
	move.w	#$1B24,d1
	movea.l	#Z80Program,a0
	jsr	(SoundCmd).l
	move.w	#6,d0
	clr.w	d1
	movea.l	#SoundBanks,a0
	jsr	(SoundCmd).l
	move.w	#7,d0
	move.w	#0,d1
	jsr	(SoundCmd).l
	bsr.w	UpdateScores
	cmpi.w	#4,(gsp).w				;check if cont playoffs
	bne.w	.4
	bsr.w	AddPlayoffTeamStats
.4
	bsr.w	Intermission
	cmpi.w	#4,(gsp).w
	beq.w	.0						;finished playoffs
	bset	#5,(sflags11).w
	jsr	(ReturnToGame).l
	jmp	StartPer
.0
	bsr.w	EncodePW
	jsr	(rtsPlayoffOver).l
	tst.w	(OptPlayMode).w
	beq.w	.checkadjust
	bclr	#1,(sflags).w
	jsr	(PlayoffStatsMenu).l
.checkadjust
	btst	#7,(GameFlags).w
	bne.w	.1
	jsr	(PlayoffScreen).l
.1
	jmp	*+6

ExitToOpening						;Back to the title (Opening2)
	bra.w	Opening2

Opening								;Title screen, then into Opening2
	bsr.w	KillCrowd
	jsr	(stop_current_song).l		;stop the song
	move.w	#9,d0					;restart the sound driver as Begin does
	jsr	(SoundCmd).l
	move.w	#0,d0					;command 0: load the Z80 program
	move.w	#$1B24,d1
	movea.l	#Z80Program,a0
	jsr	(SoundCmd).l
	move.w	#6,d0
	clr.w	d1
	movea.l	#SoundBanks,a0
	jsr	(SoundCmd).l
	move.w	#7,d0
	move.w	#0,d1
	jsr	(SoundCmd).l
	jsr	(CreditsScreen).l
	jsr	(TitleScreen).l
	bra.w	OpeningClear

Opening2							;Restart the sound, reset the stack and clear the variables, then the main
									;menu and the season flow
	jsr	(stop_current_song).l		;stop the song
	move.w	#9,d0					;restart the sound driver as Begin does
	jsr	(SoundCmd).l
	move.w	#0,d0					;command 0: load the Z80 program
	move.w	#$1B24,d1
	movea.l	#Z80Program,a0
	jsr	(SoundCmd).l
	move.w	#6,d0
	clr.w	d1
	movea.l	#SoundBanks,a0
	jsr	(SoundCmd).l
	move.w	#7,d0
	move.w	#0,d1
	jsr	(SoundCmd).l
	bsr.w	KillCrowd
	btst	#7,(GameFlags).w
	beq.w	.0
	btst	#6,(sflags10).w
	bne.w	.0
	move.w	#3,-(sp)
	jsr	(song).l
	bra.w	OpeningClear
.0
	move.w	#0,-(sp)
	jsr	(song).l

OpeningClear						;Reset the stack and clear the game variables (keeping the season data),
									;then the options or the season flow
	movea.w	#(Stack-M68K_RAM),sp
	btst	#7,(GameFlags).w
	beq.w	.3
	movea.l	#$FFFFD296,a3
	jsr	(WritePassBits).l
	jsr	(WritePassData).l
	movea.l	#$FFFF0000,a0
	movea.l	#$FFFFCF44,a1
	move.w	#$1F,d0
.1
	move.l	(a1)+,(a0)+
	dbf	d0,.1
	move.w	(gamenum).w,(a0)
	movea.w	#(VSCRLPM-M68K_RAM),a0
.0
	clr.l	(a0)+
	cmpa.w	#$D240,a0				;clear from VSCRLPM to gamevarend
	blt.s	.0
	movea.l	#$FFFF0000,a0
	movea.l	#$FFFFCF44,a1
	move.w	#$1F,d0
.pal
	move.l	(a0)+,(a1)+
	dbf	d0,.pal
	move.w	(a0),(gamenum).w
	bset	#7,(GameFlags).w
	jsr	(ReadSeasonHeader).l
	btst	#2,(SeasonFlags).w
	beq.w	.2
	jsr	(ReadPassData).l
	jsr	(MakeTree).l
	jsr	(ContinuePlayoffs).l
	btst	#1,(SeasonFlags).w
	bne.w	*+4
.2
	bra.w	.5
.3
	movea.l	#VSCRLPM,a0
.4
	clr.l	(a0)+
	cmpa.w	#$D240,a0
	blt.s	.4
	jsr	(OptionsScreen).l
.5
	bset	#5,(sflags10).w
	btst	#7,(GameFlags).w
	beq.w	.6
	btst	#6,(sflags10).w
	beq.w	.7
.6
	jsr	(TeamSelectScreen).l
	move.w	(HVcount).l,(seed).w
	move.w	(HVcount).l,(seed+2).w
	jsr	(StartNewSeason).l
.7
	btst	#7,(GameFlags).w
	beq.w	.playoffs
	jsr	(ReadSeasonHeader).l
	jsr	(LoadSeasonOptions).l
	btst	#0,(SeasonFlags).w
	beq.w	.8
	btst	#1,(SeasonFlags).w
	bne.w	.11
	btst	#2,(SeasonFlags).w
	beq.w	.11
.8
	jsr	(BuildSeasonTeamList).l
	jsr	(FindUserGame).l
	cmpa.l	#0,a2
	beq.w	.9
	jsr	(UserGamePlayed).l
	beq.w	.13
.9
	move.w	#1,(simdays).w
.10
	jsr	(SimSeasonDays).l
	bset	#1,(sflags14).w
	btst	#0,(SeasonFlags).w
	beq.s	.8
.11
	btst	#1,(SeasonFlags).w
	bne.w	.17
	btst	#2,(SeasonFlags).w
	bne.w	.12
	move.l	#SeasonMenuScreen,(NextScreenPtr).w
	jsr	(RunSeasonMenu).l
	jsr	(SetSeasonAwardWinners).l
	jsr	(NewPO).l
	btst	#1,(sflags11).w
	bne.w	.16
.12
	bra.s	.8
.13
	jsr	(SetupSeasonGame).l
	move.l	#SeasonMenuScreen,(NextScreenPtr).w
	jsr	(RunSeasonMenu).l
	btst	#0,(SeasonFlags).w
	beq.w	.14
	btst	#2,(SeasonFlags).w
	beq.s	.11
.14
	tst.w	(simdays).w
	bne.s	.10
	bclr	#5,(sflags10).w
	jsr	(TeamSelectScreen).l
.playoffs
	jsr	(SetContTeams).l
	jsr	(UserNameEntry).l
	jsr	(PlayoffScreen).l
	btst	#0,(gmode2).w
	bne.w	.15
	jsr	(ScoutingReport).l
.15
	jmp	StartGame
.16
	jsr	(SeasonAwards).l
	bset	#1,(SeasonFlags).w
	bclr	#6,(GameFlags).w
	jsr	(WriteSeasonHeader).l
	bclr	#7,(GameFlags).w
	bra.w	Opening2
.17
	cmpi.w	#4,(gamelevel).w
	beq.w	.18
	bra.w	.20
.18
	btst	#3,(SeasonFlags).w
	beq.w	.19
	jsr	(CupCelebration).l
.19
	jsr	(PlayoffScreen).l
	btst	#3,(SeasonFlags).w
	beq.w	.21
.20
	move.w	#0,-(sp)
	jsr	(song).l
	jsr	(StanleyCupScreen).l
.21
	jsr	(SeasonAwards).l
	btst	#1,(sflags13).w
	bne.w	.22
	move.l	#SeasonMenuScreen,(NextScreenPtr).w
	jsr	(RunSeasonMenu).l
.22
	bclr	#7,(GameFlags).w
	bra.w	Opening2

AbortGame							;The "ABORT GAME" menu item: back to the title (Opening2).
	bclr	#4,(sflags).w
	move.w	#$FFFF,(lastsfx).w
	move.l	#$FFFF0000,(recbpr).w
	st	(demoflag).w
	jmp	(Opening2).l

EASportsScreen						;Called from Begin. Show the EA Sports screen until a button or a time out
	move.l	#vb2,(VBint).w			;vblank handler
	bclr	#df32c,(disflags).w
	move.w	#5,(Map3col1).w
	move.w	#$A000,(VmMAP2).w
	move.w	#7,(Map2col1).w
	move.w	#$C000,(VmMAP1).w
	move.w	#7,(Map1col1).w
	move.w	#$F000,(VmMAP3).w
	move.w	#$F800,(VSPRITES).w
	move.w	#$FC00,(VSCRLPM).w
	movea.w	#(palfadenew-M68K_RAM),a0
	moveq	#$1F,d1					;32 longs: all 64 colours black
.clr
	clr.l	(a0)+
	dbf	d1,.clr
	bsr.w	CopyPaletteToCRAM
	bsr.w	setVram_0
	bsr.w	printz
	String	CC_Font2,$00,$00
	movea.l	#EASportsMap,a2
	movea.l	a2,a0
	movea.l	a2,a1
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	move.w	(a1),d2
	move.w	2(a1),d3
	clr.w	d4
	moveq	#$F,d5
	bsr.w	dobitmap
	move.w	#$EEE,(palfadenew).w
	move.w	#0,(palfadenew+$E).w
	move.w	#$18,(palcount).w
	move	#$2500,sr
	move.w	#$50,(seed).w
.loop2
	moveq	#4,d0
	bsr.w	waitx
	tst.w	d1
	bne.w	.2
	subq.w	#1,(seed).w
	bpl.s	.loop2
.2
	move	#$2700,sr
	rts

UpdatePlayoffLevel					;Set pojoy from the number of players for the playoff modes.
	cmpi.w	#2,(OptPlayMode).w
	blt.w	rtss2
	cmpi.w	#4,(OptPlayMode).w
	beq.w	rtss2
	moveq	#7,d0
	tst.w	(FourWayPlay).w
	beq.w	.1
	move.w	#$B,d0					;4 way play
.1
	sub.w	(OptNOP).w,d0
	move.w	d0,(pojoy).w
	rts
	bsr.w	PrintPlayoffLevelRow
	moveq	#$C,d0
	moveq	#2,d1
	move.w	#$7FF,d2
	bra.w	eraser
PrintPlayoffLevelRow				;Print the playoff level string; for the second team set printx $1A
	bsr.w	printz
	String	-(TXPRI+TXMAP1),2,$A
	cmpa.w	#(tmstruct-M68K_RAM),a2	;home team struct?
	bne.w	rtss2
	move.w	#$1A,(printx).w
	rts

