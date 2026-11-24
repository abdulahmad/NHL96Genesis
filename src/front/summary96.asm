;	The pause-menu summaries: roster, scoring, penalties, the periods,
;	the game, the shootout shooters and the record holders.

VBlank_SpriteFade					;VBint for the period summary and the awards screen: the sprite table when
									;dfok is set, then cramfade unless dfng
	movem.l	d0-d7/a0-a6,-(sp)
	btst	#dfng,(disflags).w
	bne.w	.nograph
	bclr	#dfok,(disflags).w
	beq.w	.fade
	jsr	(DumpSpriteTable).l
.fade
	jsr	(cramfade).l
.nograph
	addq.w	#1,(Vcount).w
	jsr	(p_music_vblank).l
	movem.l	(sp)+,d0-d7/a0-a6
	rte

ClearMenuBox						;Blank the pause menu box (big font rows) and its corners before a submenu
									;is drawn
	jsr	(printsmallz).l
	String	$F8,7,1,$A,6,' ',$FD,$1D,' ',$FC,$14,$FD,$A,' ',$FD,$1D,' '
	jsr	(printbigcurz).l
	String	$F8,4,1,$B,6,$F9,1
	move.w	#7,d0
.loop
	jsr	(printbigcurz).l
	String	'                  ',$FD,$B,$FA,2
	dbf	d0,.loop
	rts

TeamRosterScreen					;Pause menu Team Roster
	move.l	a2,-(sp)
	move.w	(HomeTeam).w,-(sp)
	move.w	(VisTeam).w,-(sp)
	btst	#6,(sflags11).w
	beq.w	.1
	clr.w	(HomeTeam).w
	bsr.w	ReloadHomeTeamStruct
	bra.w	.2
.1
	btst	#7,(GameFlags).w
	beq.w	.2
	btst	#4,(sflags12).w
	bne.w	.2
	clr.w	(HomeTeam).w
	move.b	(SeasonTeam).w,(HomeTeam+1).w
	bsr.w	ReloadHomeTeamStruct
.2
	bsr.w	SetupRosterScreenVideo
	move.w	#$18,(palcount).w
	bclr	#2,(disflags).w
	clr.w	(DispAttribCtr).w
	clr.w	(PListRows).w
.loop
	bsr.w	DrawRosterTeamLogo
	jsr	(SetMenuScroll).l
	move.w	#$64,(palcount).w
	move.w	#$2500,sr
	jsr	(SetMenuScroll).l
.loop2
	jsr	(printsmallz).l
	String	$FF,1,$FD,2,$FC,$11
	moveq	#$24,d0
	moveq	#9,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	jsr	(SetMenuScroll).l
	bsr.w	FillGoalieIndexList
	jsr	(SetMenuScroll).l
	bsr.w	ResetGoalieScrolling
	jsr	(SetMenuScroll).l
	bsr.w	DrawRosterRow
	jsr	(SetMenuScroll).l
	move.w	#$2500,sr
RosterInputLoop	equ	*	;Roster screen main loop: read the pad
	jsr	(vcountwait).l
	jsr	(SetMenuScroll).l
	jsr	(ReadMenuJoy).l
	jsr	(ProcessInputWithRepeat).l
	move.w	#1,d0
	btst	#1,d1
	bne.w	RosterScrollDown
	btst	#3,d1
	bne.w	RosterScrollUp
	btst	#6,(sflags11).w
	beq.w	.4
	btst	#4,d1
	beq.w	.4
	addq.w	#1,(HomeTeam).w
	cmpi.w	#$1A,(HomeTeam).w
	bne.w	.3
	clr.w	(HomeTeam).w
.3
	bsr.w	ReloadHomeTeamStruct
	bra.w	.loop
.4
	move.w	#$FFFF,d0
	btst	#0,d1
	bne.w	RosterScrollDown
	btst	#2,d1
	bne.w	RosterScrollUp
	btst	#5,d1
	bne.w	.9
	btst	#6,d1
	beq.w	.8
	btst	#6,(sflags11).w
	beq.w	.6
	subq.w	#1,(HomeTeam).w
	bpl.w	.5
	move.w	#$19,(HomeTeam).w
.5
	bsr.w	ReloadHomeTeamStruct
	bra.w	.loop
.6
	btst	#4,(sflags12).w
	bne.w	.7
	btst	#7,(GameFlags).w
	bne.w	RosterInputLoop
.7
	bra.w	.10
.8
	btst	#7,d1
	bne.w	.12
	bra.w	RosterInputLoop
.9
	eori.w	#1,(PListRows).w
	bra.w	.loop2
.10
	cmpa.l	#$FFFFC726,a2
	beq.w	.11
	suba.w	#$39E,a2
	bra.w	.loop
.11
	adda.w	#$39E,a2
	bra.w	.loop
.12
	move.w	(sp)+,(VisTeam).w
	move.w	(sp)+,(HomeTeam).w
	movea.l	(sp)+,a2
	btst	#7,(GameFlags).w
	beq.w	.13
	move.l	#SeasonMenuScreen,(NextScreenPtr).w
	bra.w	.14
.13
	btst	#6,(sflags11).w
	bne.w	.14
.14
	bclr	#5,(sflags12).w
	rts
FillGoalieIndexList					;Fill CalTeam with the goalie indexes 0 .. count-1
	tst.w	(PListRows).w
	beq.w	.1
	jsr	(GetGoalieCount).l
	subq.w	#1,d0
	clr.w	d1
	movea.l	#CalTeam,a0
.loop
	move.b	d1,(a0)+
	addq.w	#1,d1
	dbf	d0,.loop
	rts
.1
	move.w	$28(a2),d7
	movea.l	#CalTeam,a0
	movea.l	#$FFFFD162,a1
	jsr	(GetPlayerCount).l
	move.w	d0,d2
	jsr	(GetGoalieCount).l
	sub.w	d0,d2
	subq.w	#1,d2
	movem.l	d2/a0-a1,-(sp)
	move.w	d0,d1
.loop2
	move.w	d1,d0
	jsr	(GetPositionSlot).l
	tst.w	d0
	beq.w	.2
	move.b	d0,(a1)+
	move.b	d1,(a0)+
.2
	addq.w	#1,d1
	dbf	d2,.loop2
	movem.l	(sp)+,d2/a0-a1
.loop3
	move.w	d2,d3
	subq.w	#1,d3
	movea.l	#CalTeam,a0
	movea.l	#$FFFFD162,a1
	st	d6
.loop4
	move.b	(a1),d0
	cmp.b	1(a1),d0
	ble.w	.3
	clr.w	d6
	move.b	1(a1),d1
	move.b	d0,1(a1)
	move.b	d1,(a1)
	move.b	(a0),d0
	move.b	1(a0),d1
	move.b	d1,(a0)
	move.b	d0,1(a0)
.3
	addq.w	#1,a0
	addq.w	#1,a1
	dbf	d3,.loop4
	tst.w	d6
	beq.s	.loop3
	rts
ResetGoalieScrolling				;Reset the scroll counters to the goalie count
	tst.w	(PListRows).w
	beq.w	.1
	jsr	(GetGoalieCount).l
	subq.w	#1,d0
	move.w	d0,(screentimer).w
	move.w	d0,(VertLineScrolling).w
	clr.w	(DispAttribCtr).w
	rts
.1
	jsr	(GetGoalieCount).l
	move.w	d0,d1
	jsr	(GetPlayerCount).l
	sub.w	d1,d0
	subq.w	#1,d0
	move.w	d0,(screentimer).w
	move.w	#8,(VertLineScrolling).w
	clr.w	(DispAttribCtr).w
	rts
RosterScrollDown	equ	*	;Roster screen: scroll down by one row and redraw
	bsr.w	RosterMoveCursor
	bra.w	RosterInputLoop
RosterMoveCursor					;Move the roster cursor by d0 rows and redraw
	add.w	(VertLineScrolling).w,d0
	cmp.w	#8,d0
	blt.w	.1
	cmp.w	(screentimer).w,d0
	bgt.w	.1
	move.w	d0,(VertLineScrolling).w
	subq.w	#8,d0
	bsr.w	DrawRosterRow
	move.w	#$2500,sr
.1
	rts
RosterScrollUp	equ	*	;Roster screen: scroll up and redraw
	add.w	(DispAttribCtr).w,d0
	bmi.w	RosterInputLoop
	move.w	d0,(DispAttribCtr).w
	bsr.w	DrawRosterRow
	move.w	#$2500,sr
	bra.w	RosterInputLoop
DrawRosterRow						;Print one row of the roster screen
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),$17,$E
.loop
	movea.l	#PAttribColumns,a1
	tst.w	(PListRows).w
	beq.w	.1
	movea.l	#GAttribColumns,a1
.1
	move.w	(DispAttribCtr).w,d0
	bra.w	.2
.loop2
	adda.w	(a1),a1
	addq.w	#4,a1
.2
	tst.w	(a1)
	dbmi	d0,.loop2
	bpl.w	.3
	subq.w	#1,(DispAttribCtr).w
	bra.s	.loop
.3
	jsr	(printbig).l
	move.l	(a1),d4
	movea.w	#(CalTeam-M68K_RAM),a3
	move.w	(VertLineScrolling).w,d2
	subq.w	#8,d2
	bpl.w	.4
	clr.w	d2
.4
	move.w	(screentimer).w,d1
	cmp.w	#8,d1
	bls.w	.5
	moveq	#8,d1
.5
	move.w	#$10,(printy).w
.loop3
	jsr	(printsmallz).l
	String	$FE,7,$FD,2,$FA,1,'                         ',$FD,2
	clr.w	d0
	move.b	(a3,d2.w),d0
	jsr	(GetNameandAttrib).l
	addq.w	#1,d2
	dbf	d1,.loop3
	rts
SetupRosterScreenVideo				;Set the VBint handler, scroll and map addresses for the roster screen and
									;load its graphics
	move.l	a2,-(sp)
	bset	#5,(sflags12).w
	move.l	#VBlank_Menus,(VBint).w
	bclr	#dfok,(disflags).w
	bset	#dfng,(disflags).w
	bclr	#df32c,(disflags).w
	move.w	#0,(VSCRLPM).w
	move.w	#$B800,(VSPRITES).w
	move.w	#$B800,(VmMAP3).w
	move.w	#5,(Map3col1).w
	move.w	#$C000,(VmMAP2).w
	move.w	#6,(Map2col).w
	move.w	#$E000,(VmMAP1).w
	move.w	#6,(Map1col).w
	move.w	#0,d0
	bset	#5,(disflags).w
	jsr	(setVram).l
	bclr	#5,(disflags).w
	jsr	(orjoy).l
	move.w	#1,d4
	movea.l	#TeamRosterSprites,a1
	jsr	(LoadScreenSprite).l
	move.w	d4,(smallfontchars).w
	movea.l	#RosterFont+8,a2
	jsr	(DecompressGraphicsPlain).l
	move.w	d4,(smallfont2chars).w
	movea.l	#SmallFontMap2+8,a2
	jsr	(DecompressGraphicsPlain).l
	move.l	#RosterFont,(smallfontptr).w
	move.w	d4,(BigFontchars).w
	movea.l	#BigFontMap4+8,a2
	jsr	(DecompressGraphicsPlain).l
	bset	#2,(sflags11).w
	jsr	(printsmallz).l
	String	$FF,1,$FD,0,$FC
	moveq	#$28,d0
	moveq	#$1C,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),0,0
	movea.l	#TeamRosterBgMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	moveq	#$28,d2
	moveq	#$1C,d3
	moveq	#8,d5
	jsr	(dobitmap).l
	movea.l	(sp),a2
	move.w	d4,(awardlogochars).w
	bsr.w	DrawRosterTeamLogo
	move.w	(awardlogochars).w,d4
	addi.w	#$A0,d4
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),$B,1
	movea.l	#TeamRosterTitleMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	move.w	(a1),d2
	move.w	2(a1),d3
	moveq	#8,d5
	jsr	(dobitmap).l
	jsr	(printcurz).l
	String	$8F,$18,7,'start-exit',$8F,$16,8,'c-goalie/player',$8F,$15,9,'[]-scroll ratings',$8F,$15,9,'{}-scroll players'
	btst	#6,(sflags11).w
	bne.w	.1
	btst	#4,(sflags12).w
	bne.w	.2
	btst	#7,(GameFlags).w
	bne.w	.3
	bra.w	.2
.1
	jsr	(printcurz).l
	String	$8F,$14,$A,'a/b-change teams'
	bra.w	.3
.2
	jsr	(printcurz).l
	String	$8F,$16,$A,'a-change teams'
.3
	jsr	(printbigz).l
	String	$F8,4,1,3,$E,'#  player'
	jsr	(printz).l
	String	$FE,0,0
	movea.l	#IceBgMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	moveq	#$40,d2
	moveq	#$1C,d3
	moveq	#1,d5
	jsr	(dobitmap).l
	movea.l	#TeamRosterSprites,a0
	jsr	(DrawScreenSprite).l
	bsr.w	CopyStatsPalette
	movea.l	(sp)+,a2
	rts
DrawRosterTeamLogo					;Draw the logo of the team at Xvel(a2) on the roster screen
	move.w	(awardlogochars).w,d4
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),1,4
	move.w	$28(a2),d7
	moveq	#2,d5
	jmp	(DrawTeamLogoD7).l
ReloadHomeTeamStruct				;Reload tmstruct from the home team, clear the attribute deltas and
									;restoreteams
	movea.l	#tmstruct,a2
	move.w	(HomeTeam).w,$28(a2)
	movea.l	#$77E,a0
	move.w	(HomeTeam).w,d0
	asl.w	#2,d0
	movea.l	(a0,d0.w),a0
	move.l	a0,$1E(a2)
	jsr	(ClearAttribDeltas).l
	move.l	a2,-(sp)
	jsr	(restoreteams).l
	movea.l	(sp)+,a2
	rts

ScoringSummaryScreen				;Pause menu Scoring Summary
	clr.w	(VertLineScrolling).w
	bsr.w	GoalTypeScreenInit
	move.w	#$18,(palcount).w
	bclr	#2,(disflags).w
.loop
	bsr.w	DrawScoringRow
	move.w	#$2500,sr
.loop2
	jsr	(vcountwait).l
	jsr	(SetMenuScroll).l
	jsr	(ReadMenuJoy).l
	jsr	(ProcessInputWithRepeat).l
	btst	#7,d1
	bne.w	.2
	btst	#0,d1
	beq.w	.1
	tst.w	(VertLineScrolling).w
	beq.s	.loop2
	subq.w	#6,(VertLineScrolling).w
	bra.s	.loop
.1
	btst	#1,d1
	beq.s	.loop2
	cmpi.w	#$18,(ScoreSumbytes).w
	blt.s	.loop2
	move.w	(VertLineScrolling).w,d3
	addi.w	#$18,d3
	cmp.w	(ScoreSumbytes).w,d3
	bge.s	.loop2
	addq.w	#6,(VertLineScrolling).w
	bra.s	.loop
.2
	rts
DrawScoringRow						;Print one row of the scoring summary
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(printz).l
	String	$8F,2,$A
	move.w	#$24,d0
	move.w	#$F,d1
	move.l	#$7FF,d2
	jsr	(eraser).l
	move.w	(VertLineScrolling).w,d3
	jsr	(printsmallz).l
	String	$F8,7,1,4,$A
.loop
	cmp.w	(ScoreSumbytes).w,d3
	bge.w	ScoringSummaryScrollMark
	jsr	(printsmallz).l
	String	$FE,7,$FD,3
	movea.w	#(ScoreSum-M68K_RAM),a0
	move.w	(a0,d3.w),d0
	jsr	(FormatAndPrintTime).l		;print it
	movea.w	#(tmstruct-M68K_RAM),a2
	btst	#7,2(a0,d3.w)
	beq.w	.1
	adda.w	#$39E,a2
	;team chosen
.1
	movea.l	$1E(a2),a1				;team data -> team name string
	adda.w	4(a1),a1
	adda.w	(a1),a1
	move.w	#$E,(printx).w
	jsr	(printsmall).l
	move.w	#$23,(printx).w
	lea	GoalTypeTbl(pc),a1
	move.b	2(a0,d3.w),d0
	andi.w	#$7F,d0					;strip the away bit -> string index
	jsr	(PrintSmallListItem).l		;print the type
	move.w	#$12,(printx).w
	move.b	3(a0,d3.w),d0
	move.w	(printy).w,-(sp)
	bsr.w	PrintScorerName
	jsr	(printsmallz).l
	String	$FE,5,$FD,$13
	move.b	4(a0,d3.w),d0
	bsr.w	PrintScorerName
	move.w	#$13,(printx).w
	move.b	5(a0,d3.w),d0			;second assist, falls into PrintScorerName
	move.w	d0,-(sp)
	bsr.w	PrintScorerName
	move.w	(sp)+,d0
	tst.w	d0
	move.w	(sp)+,(printy).w
	addq.w	#4,(printy).w
	addq.w	#6,d3
	cmpi.w	#$17,(printy).w
	bgt.w	ScoringSummaryScrollMark
	bra.w	.loop
PrintScorerName						;Print the scorer name d0 (or nothing when negative) and move to the next
									;row
	ext.w	d0
	bmi.w	.next
	jsr	(FormatPlayerNumInitial).l
	jsr	(printcur).l
.next
	addq.w	#1,(printy).w
	rts
ScoringSummaryScrollMark	equ	*	;Scoring summary: print the more marker when scrolled and continue with the row setup
	tst.w	(VertLineScrolling).w
	beq.w	.2
	jsr	(printcurz).l
	String	$8F,2,$B,'{'
.2
	move.w	(VertLineScrolling).w,d3
	addi.w	#$18,d3
	cmp.w	(ScoreSumbytes).w,d3
	bge.w	.3
	jsr	(printcurz).l
	String	$8F,2,$18,'}'
.3
	movem.l	(sp)+,d0-d7/a0-a6
	rts

GoalTypeTbl							;ScoreSum byte 2 and $7F: SH2, SH, even, PP, PP2
	String	'SH2'
	String	'SH'
	String	' '
	String	'PP'
	String	'PP2'
GoalTypeScreenInit					;Set up the planes and VBlank handler of the goal types screen
	move.l	a2,-(sp)
	bset	#5,(sflags12).w
	move.l	#VBlank_Menus,(VBint).w
	bclr	#dfok,(disflags).w
	bset	#dfng,(disflags).w
	bclr	#df32c,(disflags).w
	move.w	#0,(VSCRLPM).w
	move.w	#$B800,(VSPRITES).w
	move.w	#$B800,(VmMAP3).w
	move.w	#5,(Map3col1).w
	move.w	#$C000,(VmMAP2).w
	move.w	#6,(Map2col).w
	move.w	#$E000,(VmMAP1).w
	move.w	#6,(Map1col).w
	move.w	#0,d0					;fade to color
	bset	#5,(disflags).w
	jsr	(setVram).l
	bclr	#5,(disflags).w
	jsr	(orjoy).l
	move.w	#1,d4
	movea.l	#SummarySprites,a1
	jsr	(LoadScreenSprite).l
	move.w	d4,(smallfontchars).w
	movea.l	#RosterFont+8,a2
	jsr	(DecompressGraphicsPlain).l
	move.w	d4,(smallfont2chars).w
	movea.l	#SmallFontMap2+8,a2
	jsr	(DecompressGraphicsPlain).l
	move.l	#RosterFont,(smallfontptr).w
	move.w	d4,(BigFontchars).w
	movea.l	#BigFontMap4+8,a2
	jsr	(DecompressGraphicsPlain).l
	bset	#2,(sflags11).w
	jsr	(printsmallz).l
	String	$FF,1,$FD,0,$FC
	moveq	#$28,d0
	moveq	#$1C,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),0,0
	movea.l	#SummaryBgMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	moveq	#$28,d2
	moveq	#$1C,d3
	moveq	#8,d5
	jsr	(dobitmap).l
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),$B,1
	movea.l	#ScoringTitleMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	move.w	(a1),d2
	move.w	2(a1),d3
	moveq	#8,d5
	jsr	(dobitmap).l
	jsr	(printz).l
	String	$FE,0,0
	movea.l	#IceBgMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	moveq	#$40,d2
	moveq	#$1C,d3
	moveq	#1,d5
	jsr	(dobitmap).l
	move.w	(VisTeam).w,d7
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),1,5
	jsr	(DrawSetupTeamBlock).l
	addi.w	#$20,d4
	move.w	(HomeTeam).w,d7
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),$17,5
	jsr	(DrawSetupTeamBlock).l
	addi.w	#$20,d4
	move.w	(smallfontchars).w,-(sp)
	move.w	(smallfont2chars).w,(smallfontchars).w
	jsr	(printcurz).l
	String	$8F,$C,$1A,'{}-scroll list'
	move.w	(sp)+,(smallfontchars).w
	jsr	(printbigz).l
	String	$F8,4,1,3,8,'per time  team  goals/assist   p/s'
	movea.l	#SummarySprites,a0
	jsr	(DrawScreenSprite).l
	bsr.w	PStatsPalette
	movea.l	(sp)+,a2
	rts

PenaltySummaryScreen				;Pause menu Penalty Summary
	clr.w	(VertLineScrolling).w
	bsr.w	SetupPenaltySummaryVideo
	move.w	#$18,(palcount).w
	bclr	#2,(disflags).w
.loop
	bsr.w	DrawPenaltyRows
	move.w	#$2500,sr
.loop2
	jsr	(vcountwait).l
	jsr	(SetMenuScroll).l
	jsr	(ReadMenuJoy).l
	jsr	(ProcessInputWithRepeat).l
	btst	#7,d1
	bne.w	.2
	btst	#0,d1
	beq.w	.1
	tst.w	(VertLineScrolling).w
	beq.s	.loop2
	subq.w	#4,(VertLineScrolling).w
	bra.s	.loop
.1
	btst	#1,d1
	beq.s	.loop2
	cmpi.w	#$14,(PenSumLength).w
	blt.s	.loop2
	move.w	(VertLineScrolling).w,d3
	addi.w	#$14,d3
	cmp.w	(PenSumLength).w,d3
	bge.s	.loop2
	addq.w	#4,(VertLineScrolling).w
	bra.s	.loop
.2
	rts
SetupPenaltySummaryVideo			;Set the VBint handler, scroll and map addresses for the penalty summary
									;and load its graphics
	move.l	a2,-(sp)
	bset	#5,(sflags12).w
	move.l	#VBlank_Menus,(VBint).w
	bclr	#dfok,(disflags).w
	bset	#dfng,(disflags).w
	bclr	#df32c,(disflags).w
	move.w	#0,(VSCRLPM).w
	move.w	#$B800,(VSPRITES).w
	move.w	#$B800,(VmMAP3).w
	move.w	#5,(Map3col1).w
	move.w	#$C000,(VmMAP2).w
	move.w	#6,(Map2col).w
	move.w	#$E000,(VmMAP1).w
	move.w	#6,(Map1col).w
	move.w	#0,d0					;fade to color
	bset	#5,(disflags).w
	jsr	(setVram).l
	bclr	#5,(disflags).w
	jsr	(orjoy).l
	move.w	#1,d4
	movea.l	#SummarySprites,a1
	jsr	(LoadScreenSprite).l
	move.w	d4,(smallfontchars).w
	movea.l	#RosterFont+8,a2
	jsr	(DecompressGraphicsPlain).l
	move.w	d4,(smallfont2chars).w
	movea.l	#SmallFontMap2+8,a2
	jsr	(DecompressGraphicsPlain).l
	move.l	#RosterFont,(smallfontptr).w
	move.w	d4,(BigFontchars).w
	movea.l	#BigFontMap4+8,a2
	jsr	(DecompressGraphicsPlain).l
	bset	#2,(sflags11).w
	jsr	(printsmallz).l
	String	$FF,1,$FD,0,$FC
	moveq	#$28,d0
	moveq	#$1C,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),0,0
	movea.l	#SummaryBgMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	moveq	#$28,d2
	moveq	#$1C,d3
	moveq	#8,d5
	jsr	(dobitmap).l
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),$B,1
	movea.l	#PenaltiesTitleMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	move.w	(a1),d2
	move.w	2(a1),d3
	moveq	#8,d5
	jsr	(dobitmap).l
	jsr	(printz).l
	String	$FE,0,0
	movea.l	#IceBgMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	moveq	#$40,d2
	moveq	#$1C,d3
	moveq	#1,d5
	jsr	(dobitmap).l
	move.w	(VisTeam).w,d7
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),1,5
	jsr	(DrawSetupTeamBlock).l
	addi.w	#$20,d4
	move.w	(HomeTeam).w,d7
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),$17,5
	jsr	(DrawSetupTeamBlock).l
	addi.w	#$20,d4
	move.w	(smallfontchars).w,-(sp)
	move.w	(smallfont2chars).w,(smallfontchars).w
	jsr	(printcurz).l
	String	$8F,$C,$1A,'{}-scroll list'
	move.w	(sp)+,(smallfontchars).w
	jsr	(printbigz).l
	String	$F8,4,1,3,8,'per time  team player/penalty  mins'
	movea.l	#SummarySprites,a0
	jsr	(DrawScreenSprite).l
	bsr.w	PStatsPalette
	movea.l	(sp)+,a2
	rts
DrawPenaltyRows						;Print the rows of the penalty summary
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(printz).l
	String	$8F,2,$B
	move.w	#$24,d0
	move.w	#$E,d1
	move.l	#$7FF,d2
	jsr	(eraser).l
	move.w	(VertLineScrolling).w,d3
	jsr	(printsmallz).l
	String	$F8,7,1,3,$B
.loop
	cmp.w	(PenSumLength).w,d3
	bge.w	.2
	jsr	(printsmallz).l
	String	$FE,7,$FD,3
	movea.w	#(PenSum-M68K_RAM),a0
	move.w	(a0,d3.w),d0
	jsr	(FormatAndPrintTime).l
	movea.w	#(tmstruct-M68K_RAM),a2
	btst	#7,2(a0,d3.w)
	beq.w	.1
	adda.w	#$39E,a2
.1
	movea.l	$1E(a2),a1
	adda.w	4(a1),a1
	adda.w	(a1),a1
	move.w	#$F,(printx).w
	jsr	(printcur).l
	move.b	2(a0,d3.w),d0
	andi.w	#$7F,d0
	movea.l	#Penaltylist,a3
	adda.w	(a3,d0.w),a3
	clr.w	d0
	move.b	penmins(a3),d0
	jsr	(PushNumber).l
	move.w	#$23,(printx).w
	jsr	(printcur).l
	move.w	#$13,(printx).w
	clr.w	d0
	move.b	3(a0,d3.w),d0
	jsr	(FormatPlayerNumInitialShort).l
	jsr	(printcur).l
	addq.w	#1,(printy).w
	move.w	#$13,(printx).w
	jsr	(printsmallz).l
	String	$FE,5
	lea	penname(a3),a1
	jsr	(printcur).l
	addq.w	#2,(printy).w
	addq.w	#4,d3
	cmpi.w	#$18,(printy).w
	bgt.w	.2
	bra.w	.loop
.2
	tst.w	(VertLineScrolling).w
	beq.w	.3
	jsr	(printcurz).l
	String	$8F,2,$B,'{'
.3
	move.w	(VertLineScrolling).w,d3
	addi.w	#$14,d3
	cmp.w	(PenSumLength).w,d3
	bge.w	.4
	jsr	(printcurz).l
	String	$8F,2,$18,'}'
.4
	movem.l	(sp)+,d0-d7/a0-a6
	rts

PeriodStatsScreen					;Pause menu Period Stats
	clr.w	(shootoutteam+4).w
	bsr.w	SetupPeriodStatsVideo
	move.w	#$18,(palcount).w
	bclr	#2,(disflags).w
.loop
	bsr.w	DrawPeriodStatsHeader
	move.w	#$2500,sr
.loop2
	jsr	(vcountwait).l
	jsr	(SetMenuScroll).l
	jsr	(ReadMenuJoy).l
	jsr	(ProcessInputWithRepeat).l
	btst	#7,d1
	bne.w	.2
	btst	#3,d1
	bne.w	.1
	btst	#2,d1
	bne.w	.1
	bra.s	.loop2
.1
	eori.w	#1,(shootoutteam+4).w
	bra.s	.loop
.2
	rts
DrawPeriodStatsHeader				;Print the heading of the period stats screen
	jsr	(printbigz).l
	String	$F8,4,1,$12,$E
	bset	#2,(sflags11).w
	movea.l	#PeriodGoalsTxt,a1
	btst	#0,(shootoutteam+5).w
	beq.w	.1
	movea.l	#PeriodShotsTxt,a1
.1
	jsr	(printbig).l
	bclr	#2,(sflags11).w
	movea.l	#AwShots,a2
	move.w	#7,(printx).w
	bsr.w	PeriodStatsTeam
	movea.l	#tmstruct,a2
	move.w	#$1E,(printx).w
	bsr.w	PeriodStatsTeam
	rts

PeriodGoalsTxt						;PeriodStatsScreen caption while it shows goals
	String	'goals'

PeriodShotsTxt						;PeriodStatsScreen caption while it shows shots
	String	'shots'

PeriodStatsTeam						;PeriodStatsScreen per team: goals or shots by
									;period up to the current one
	lea	$37C(a2),a0
	tst.w	(shootoutteam+4).w
	beq.w	.1
	lea	$384(a2),a0
.1
	clr.w	($FFFFD468).w
	move.w	#$10,(printy).w
	bsr.w	PeriodStatsPrintTotal
	cmpi.w	#1,(gsp).w
	blt.w	.2
	move.w	#$12,(printy).w
	bsr.w	PeriodStatsPrintTotal
	cmpi.w	#2,(gsp).w
	blt.w	.2
	move.w	#$14,(printy).w
	bsr.w	PeriodStatsPrintTotal
	cmpi.w	#3,(gsp).w
	blt.w	.2
	btst	#1,(sflags7).w
	beq.w	.2
	move.w	#$16,(printy).w
	bsr.w	PeriodStatsPrintTotal
.2
	move.w	#$18,(printy).w
	jsr	(printbigz).l
	String	'   '
	subq.w	#3,(printx).w
	move.w	($FFFFD468).w,d0
	move.w	#2,d1
	cmp.w	#$64,d0
	blt.w	.3
	move.w	#3,d1
.3
	jsr	(PushNumberWidth).l
	jmp	(printbig).l
PeriodStatsPrintTotal				;Print a team total of the period stats with the big font and add it to the
									;running sum
	move.w	(printx).w,-(sp)
	move.w	(a0)+,d0
	add.w	d0,($FFFFD468).w
	jsr	(printbigz).l
	String	'   '
	subq.w	#3,(printx).w
	move.w	#2,d1
	cmp.w	#$64,d0
	blt.w	.next
	move.w	#3,d1
.next
	jsr	(PushNumberWidth).l
	jsr	(printbig).l
	move.w	(sp)+,(printx).w
	rts
SetupPeriodStatsVideo	equ	*	;Set the VBint handler, scroll and map addresses for the period stats screen and load its graphics
	move.l	a2,-(sp)
	bset	#5,(sflags12).w
	move.l	#VBlank_Menus,(VBint).w
	bclr	#dfok,(disflags).w
	bset	#dfng,(disflags).w
	bclr	#df32c,(disflags).w
	move.w	#0,(VSCRLPM).w
	move.w	#$B800,(VSPRITES).w
	move.w	#$B800,(VmMAP3).w
	move.w	#5,(Map3col1).w
	move.w	#$C000,(VmMAP2).w
	move.w	#6,(Map2col).w
	move.w	#$E000,(VmMAP1).w
	move.w	#6,(Map1col).w
	move.w	#0,d0					;fade to color
	bset	#5,(disflags).w
	jsr	(setVram).l
	bclr	#5,(disflags).w
	jsr	(orjoy).l
	move.w	#1,d4
	movea.l	#SelectTeamSprites,a1
	jsr	(LoadScreenSprite).l
	move.w	d4,(printbigchars).w
	movea.l	#BigFontMap2+8,a2
	jsr	(DecompressGraphicsPlain).l
	bclr	#2,(sflags11).w
	move.w	d4,(BigFontchars).w
	movea.l	#BigFontMap4+8,a2
	jsr	(DecompressGraphicsPlain).l
	jsr	(printsmallz).l
	String	$FF,1,$FD,0,$FC
	moveq	#$28,d0
	moveq	#$1C,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),0,0
	movea.l	#PeriodStatsMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	moveq	#$28,d2
	moveq	#$1C,d3
	moveq	#8,d5
	jsr	(dobitmap).l
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),$B,1
	movea.l	#PeriodStatsTitleMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	move.w	(a1),d2
	move.w	2(a1),d3
	moveq	#8,d5
	jsr	(dobitmap).l
	jsr	(printz).l
	String	$FE,0,0
	movea.l	#IceBgMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	moveq	#$40,d2
	moveq	#$1C,d3
	moveq	#1,d5
	jsr	(dobitmap).l
	move.w	(VisTeam).w,d7
	move.w	#2,d5
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),2,4
	jsr	(DrawTeamLogoD7).l
	move.w	(HomeTeam).w,d7
	clr.w	d5
	jsr	(printz).l
	String	$8F,$16,4
	jsr	(DrawTeamLogoD7).l
	jsr	(printbigz).l
	String	$F8,4,1,$F,$10,'1st period',$FD,$F,$FC,$12,'2nd period',$FD,$F,$FC,$14,'3rd period',$FD,$10,$FC,$16,'overtime',$FD,$11,$FC,$18,'totals'
	movea.l	#SelectTeamSprites,a0
	jsr	(DrawScreenSprite).l
	movea.l	(sp)+,a2
	rts

StatsReport							;Pause menu Game Stats Code the listing does
	clr.w	(VertLineScrolling).w
	move.w	#$10,(DispAttribCtr).w
	tst.w	(OptPen).w
	bne.w	.1
	move.w	#$C,(DispAttribCtr).w
.1
	bset	#5,(sflags12).w
	bsr.w	TeamStatScreenInit
	move.w	#$18,(palcount).w
	bclr	#2,(disflags).w
.loop
	bsr.w	DrawStatsReportHeader
	move.w	#$2500,sr
.loop2
	jsr	(vcountwait).l
	jsr	(SetMenuScroll).l
	jsr	(ReadMenuJoy).l
	jsr	(ProcessInputWithRepeat).l
	btst	#7,d1
	bne.w	.3
	btst	#0,d1
	beq.w	.2
	tst.w	(VertLineScrolling).w
	beq.s	.loop2
	subq.w	#1,(VertLineScrolling).w
	bra.s	.loop
.2
	btst	#1,d1
	beq.s	.loop2
	move.w	(VertLineScrolling).w,d3
	addq.w	#7,d3
	cmp.w	(DispAttribCtr).w,d3
	bge.s	.loop2
	addq.w	#1,(VertLineScrolling).w
	bra.s	.loop
.3
	rts
DrawStatsReportHeader				;Print the heading of the stats report
	move.w	sr,-(sp)
	jsr	(printz).l
	String	$8F,2,9
	move.w	#$24,d0
	move.w	#$E,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	tst.w	(VertLineScrolling).w
	beq.w	.1
	jsr	(printbigz).l
	String	$F8,4,1,2,9,'('
.1
	move.w	(VertLineScrolling).w,d3
	addq.w	#7,d3
	cmp.w	(DispAttribCtr).w,d3
	bge.w	.2
	jsr	(printbigz).l
	String	$F8,4,1,2,$15,')'
.2
	jsr	(printbigz).l
	String	$F8,4,1,0,9
	move.w	#6,d6
	lea	TeamStatTextTbl(pc),a1
	tst.w	(OptPen).w
	bne.w	.3
	lea	TeamStatTextTblNoPen(pc),a1
.3
	move.w	(VertLineScrolling).w,d3
	bra.w	.4
.loop
	adda.w	(a1),a1
	addq.w	#4,a1
.4
	dbf	d3,.loop
.loop2
	move.w	(a1),d0
	lsr.w	#1,d0
	neg.w	d0
	addi.w	#$15,d0
	move.w	d0,(printx).w
	jsr	(printbig).l
	movea.l	a1,a0
	move.w	#$21,(printx).w
	movea.w	#(tmstruct-M68K_RAM),a2
	bsr.w	PrintStatValue
	move.w	#9,(printx).w
	lea	$39E(a2),a2
	bsr.w	PrintStatValue
	lea	tssize(a0),a1
	addq.w	#2,(printy).w
.loop3
	dbf	d6,.loop2
	move.w	(sp)+,sr
	rts
	adda.w	(a1),a1
	addq.w	#4,a1
	bra.s	.loop3
PrintStatValue						;Print one value of the stats report (number, time or percentage by column
									;type)
	movea.w	#(mesarea-M68K_RAM),a3
	move.w	#2,(a3)
	cmpi.w	#$FFFE,(a0)
	bne.w	.1
	move.w	#$14,d0
	move.w	(a2,d0.w),d0
	mulu.w	#$64,d0
	move.w	#$12,d1
	move.w	(a2,d1.w),d1
	beq.w	.2
	divu.w	d1,d0
	bra.w	.2
.1
	cmpi.w	#$FFFF,(a0)				;shooting percentage row
	bne.w	.3
	move.w	#$C,d0
	move.w	(a2,d0.w),d0
	mulu.w	#$64,d0
	move.w	#0,d1
	move.w	(a2,d1.w),d1
	beq.w	.2
	divu.w	d1,d0
.2
	jsr	(PushNumber).l
	jsr	(appstring).l
	jsr	(appendz).l
	String	'%'
	bra.w	.7
.3
	move.w	(a0),d0
	move.w	(a2,d0.w),d0
	cmpi.w	#$38C,(a0)
	bne.w	.4
	bsr.w	StatsPushTime
	bra.w	.6
.4
	cmpi.w	#$A,(a0)
	beq.w	.5
	bsr.w	StatsPushNumber
.5
	cmpi.w	#$A,(a0)
	bne.w	.6
	bsr.w	StatsPushTime
.6
	jsr	(appstring).l
	move.w	tsoff2(a0),d0
	bmi.w	.7
	jsr	(appendz).l
	String	'/'
	move.w	(a2,d0.w),d0
	jsr	(PushNumber).l
	jsr	(appstring).l
.7
	movea.w	a3,a1
	move.w	(a1),d0
	lsr.w	#1,d0
	sub.w	d0,(printx).w
	jmp	(printbig).l
StatsPushNumber						;Jump to PushNumber
	jmp	(PushNumber).l
StatsPushTime						;Jump to PushTime
	jmp	(PushTime).l

TeamStatTextTbl						;Label, then the team struct stat offset and the second offset ($FFFF
									;none)
	dc.b	$00,$08,$53,$63,$6F,$72,$65,$00,$00,$0C,$FF,$FF,$00,$08,$53,$68
	dc.b	$6F,$74,$73,$00,$00,$00,$FF,$FF,$00,$0E,$53,$68,$6F,$6F,$74,$69
	dc.b	$6E,$67,$20,$50,$63,$74,$FF,$FF,$FF,$FF,$00,$0C,$50,$6F,$77,$65
	dc.b	$72,$20,$50,$6C,$61,$79,$00,$02,$00,$04,$00,$0C,$50,$50,$20,$4D
	dc.b	$69,$6E,$75,$74,$65,$73,$03,$8C,$FF,$FF,$00,$0A,$50,$50,$20,$53
	dc.b	$68,$6F,$74,$73,$03,$8E,$FF,$FF,$00,$0A,$53,$48,$20,$47,$6F,$61
	dc.b	$6C,$73,$03,$90,$FF,$FF,$00,$0C,$42,$72,$65,$61,$6B,$61,$77,$61
	dc.b	$79,$73,$03,$94,$03,$92,$00,$0C,$4F,$6E,$65,$2D,$54,$69,$6D,$65
	dc.b	$72,$73,$03,$98,$03,$96,$00,$10,$50,$65,$6E,$61,$6C,$74,$79,$20
	dc.b	$53,$68,$6F,$74,$73,$00,$03,$9C,$03,$9A,$00,$0E,$46,$61,$63,$65
	dc.b	$6F,$66,$66,$73,$20,$57,$6F,$6E,$00,$0E,$FF,$FF,$00,$0E,$42,$6F
	dc.b	$64,$79,$20,$43,$68,$65,$63,$6B,$73,$00,$00,$10,$FF,$FF,$00,$0C
	dc.b	$50,$65,$6E,$61,$6C,$74,$69,$65,$73,$00,$00,$06,$00,$08,$00,$0E
	dc.b	$41,$74,$74,$61,$63,$6B,$20,$5A,$6F,$6E,$65,$00,$00,$0A,$FF,$FF
	dc.b	$00,$0A,$50,$61,$73,$73,$69,$6E,$67,$00,$00,$14,$00,$12,$00,$0E
	dc.b	$70,$61,$73,$73,$69,$6E,$67,$20,$70,$63,$74,$00,$FF,$FE,$FF,$FE

TeamStatTextTblNoPen				;The rows without the power play ones, used when penalties are off
	dc.b	$00,$08,$53,$63,$6F,$72,$65,$00,$00,$0C,$FF,$FF,$00,$08,$53,$68
	dc.b	$6F,$74,$73,$00,$00,$00,$FF,$FF,$00,$0E,$53,$68,$6F,$6F,$74,$69
	dc.b	$6E,$67,$20,$50,$63,$74,$FF,$FF,$FF,$FF,$00,$0C,$42,$72,$65,$61
	dc.b	$6B,$61,$77,$61,$79,$73,$03,$94,$03,$92,$00,$0C,$4F,$6E,$65,$2D
	dc.b	$54,$69,$6D,$65,$72,$73,$03,$98,$03,$96,$00,$10,$50,$65,$6E,$61
	dc.b	$6C,$74,$79,$20,$53,$68,$6F,$74,$73,$00,$03,$9C,$03,$9A,$00,$0E
	dc.b	$46,$61,$63,$65,$6F,$66,$66,$73,$20,$57,$6F,$6E,$00,$0E,$FF,$FF
	dc.b	$00,$0E,$42,$6F,$64,$79,$20,$43,$68,$65,$63,$6B,$73,$00,$00,$10
	dc.b	$FF,$FF,$00,$0C,$50,$65,$6E,$61,$6C,$74,$69,$65,$73,$00,$00,$06
	dc.b	$00,$08,$00,$0E,$41,$74,$74,$61,$63,$6B,$20,$5A,$6F,$6E,$65,$00
	dc.b	$00,$0A,$FF,$FF,$00,$0A,$50,$61,$73,$73,$69,$6E,$67,$00,$00,$14
	dc.b	$00,$12,$00,$0E,$70,$61,$73,$73,$69,$6E,$67,$20,$70,$63,$74,$00
	dc.b	$FF,$FE,$FF,$FE
TeamStatScreenInit					;Set up the planes and VBlank handler of the team stats screen
	move.l	a2,-(sp)
	bset	#5,(sflags12).w
	move.l	#VBlank_Menus,(VBint).w
	bclr	#dfok,(disflags).w
	bset	#dfng,(disflags).w
	bclr	#df32c,(disflags).w
	move.w	#0,(VSCRLPM).w
	move.w	#$B800,(VSPRITES).w
	move.w	#$B800,(VmMAP3).w
	move.w	#5,(Map3col1).w
	move.w	#$C000,(VmMAP2).w
	move.w	#6,(Map2col).w
	move.w	#$E000,(VmMAP1).w
	move.w	#6,(Map1col).w
	move.w	#0,d0					;fade to color
	bset	#5,(disflags).w
	jsr	(setVram).l
	bclr	#5,(disflags).w
	jsr	(orjoy).l
	move.w	#1,d4
	movea.l	#GameStatsSprites,a1
	jsr	(LoadScreenSprite).l
	move.w	d4,(smallfont2chars).w
	movea.l	#SmallFontMap2+8,a2
	jsr	(DecompressGraphicsPlain).l
	move.l	#RosterFont,(smallfontptr).w
	move.w	d4,(bigfont1chars).w
	movea.l	#BigFontMap2+8,a2
	jsr	(DecompressGraphicsPlain).l
	bclr	#2,(sflags11).w
	jsr	(printsmallz).l
	String	$FF,1,$FD,0,$FC
	moveq	#$28,d0
	moveq	#$1C,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),0,0
	movea.l	#GameStatsBgMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	moveq	#$28,d2
	moveq	#$1C,d3
	moveq	#8,d5
	jsr	(dobitmap).l
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),$B,1
	movea.l	#GameStatsTitleMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	move.w	(a1),d2
	move.w	2(a1),d3
	moveq	#8,d5
	jsr	(dobitmap).l
	jsr	(printz).l
	String	$FE,0,0
	movea.l	#IceBgMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	moveq	#$40,d2
	moveq	#$1C,d3
	moveq	#1,d5
	jsr	(dobitmap).l
	move.w	(VisTeam).w,d7
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),1,5
	jsr	(DrawSetupTeamBlock).l
	addi.w	#$20,d4
	move.w	(HomeTeam).w,d7
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),$17,5
	jsr	(DrawSetupTeamBlock).l
	addi.w	#$20,d4
	move.w	(smallfontchars).w,-(sp)
	move.w	(smallfont2chars).w,(smallfontchars).w
	jsr	(printcurz).l
	String	$8F,$C,$1A,'{}-scroll list'
	move.w	(sp)+,(smallfontchars).w
	movea.l	#GameStatsSprites,a0
	jsr	(DrawScreenSprite).l
	movea.l	(sp)+,a2
	rts

ShootoutShooters					;The shootout shooters screen
	btst	#0,(gmode2).w
	beq.w	.1
	bsr.w	SetupShootersVideo
	move.w	#$18,(palcount).w
	bclr	#2,(disflags).w
	clr.w	(DispAttribCtr).w
	clr.w	(PlayerScrollCtr).w
	bsr.w	DrawShooterName
	move.w	#0,(setupvalues).w
ShootersLoop	equ	*	;Shooters list main loop: read the pad
	bsr.w	DrawShootersBackdrop
	bsr.w	DrawShooterRow
	bsr.w	DrawShootersTitle
	move.w	#$2500,sr
ShootersReadPad	equ	*
	jsr	(vcountwait).l
	jsr	(SetMenuScroll).l
	jsr	(ReadMenuJoy).l
	jsr	(ProcessInputWithRepeat).l
	btst	#7,d1
	bne.w	.1
	move.w	#1,d0
	btst	#1,d1
	bne.w	ShootersMove
	move.w	#$FFFF,d0
	btst	#0,d1
	bne.w	ShootersMove
	move.w	#0,d0
	btst	#2,d1
	bne.w	ShootersPick
	move.w	#5,d0
	btst	#3,d1
	bne.w	ShootersPick
	btst	#5,d1
	bne.w	.2
	bra.s	ShootersReadPad
.1
	rts
.2
	movea.l	#shootoutround+2,a0
	cmpa.l	#tmstruct,a2
	beq.w	.3
	movea.l	#homeshootnum+2,a0
	;shooter list chosen
.3
	move.w	(setupvalues).w,d0
	asl.w	#1,d0					;word per slot
	move.w	(a0,d0.w),d6			;current shooter
	jsr	(GetGoalieCount).l
	move.w	d0,d1
	jsr	(GetPlayerCount).l
	sub.w	d1,d0
	subq.w	#1,d0
	cmpi.w	#5,(setupvalues).w		;goalie slot?
	bne.w	.4
	move.w	d1,d0
	subq.w	#1,d0					;last goalie
	clr.w	d1						;goalies come first
	;candidate range set
.4
	move.w	d0,(screentimer).w
	clr.w	(PlayerScrollCtr).w		;scroll to the top
	clr.w	(VertLineScrolling).w	;cursor on row 0
	movea.w	#(CalTeam-M68K_RAM),a0
	clr.w	d2
	;list each candidate
.loop
	move.b	d1,(a0,d2.w)			;row = roster index
	cmp.w	d1,d6					;current shooter?
	bne.w	.5
	move.w	d2,(VertLineScrolling).w	;cursor starts on him
	;not the current shooter
.5
	addq.w	#1,d1					;next roster index
	addq.w	#1,d2
	dbf	d0,.loop					;next candidate
	move.w	sr,-(sp)
	move.l	a2,-(sp)
	bsr.w	ClearShootersBackdrop
	move.w	#1,d4
	movea.l	#LineEditorSprites,a1
	jsr	(LoadScreenSprite).l
	movea.l	#LineEditorSprites,a0
	jsr	(DrawScreenSprite).l
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),0,0
	movea.l	#LineEditorBgMap,a1
	adda.l	4(a1),a1
	movea.l	#$772,a2
	clr.w	d0
	clr.w	d1
	move.w	#$28,d2
	move.w	#$E,d3
	move.w	(ReplayIconChars+4).w,d4
	moveq	#0,d5
	jsr	(dobitmap).l
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),$A,$B
	movea.l	#EditLinesTitleMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	movea.l	#$772,a2
	move.w	(a1),d2
	move.w	2(a1),d3
	moveq	#0,d5
	move.w	(ReplayIconChars+6).w,d4
	jsr	(dobitmap).l
	movea.l	(sp)+,a2
	bset	#2,(sflags11).w
	jsr	(printbigz).l
	String	$F8,4,1,3,2,'(select player)'
	clr.w	d0
	bsr.w	ShootersMoveCursor
	move.w	(sp)+,sr
.loop2
	move.w	#$2500,sr
	jsr	(vcountwait).l
	;loop
	jsr	(SetMenuScroll).l
	jsr	(ReadMenuJoy).l
	jsr	(ProcessInputWithRepeat).l
	btst	#7,d1
	bne.w	ShootersLoop			;start: back to the shooters
	btst	#5,d1
	bne.w	ShootersSelectPlayer
	moveq	#1,d0					;down / right: +1
	btst	#1,d1
	bne.w	.7
	btst	#3,d1
	bne.w	.6
	moveq	#-$1,d0					;up / left: -1
	btst	#0,d1
	bne.w	.7
	btst	#2,d1
	bne.w	.6
	bra.s	.loop2
	;bit 3 of d1 set or bit 2 of d1 set
.6
	add.w	(DispAttribCtr).w,d0
	bmi.s	.loop2					;before the first page: ignore
	move.w	d0,(DispAttribCtr).w
	;(not branched to)
	bsr.w	PrintShooterList
	;(not branched to)
	bra.s	.loop2
.7
	bsr.w	ShootersMoveCursor
	bra.s	.loop2
ShootersMoveCursor					;Shootout shooters list: move the cursor row by d0 and rescroll
	;up / down: move the cursor
	add.w	(VertLineScrolling).w,d0
	bmi.w	.3						;above the first: ignore
	cmp.w	(screentimer).w,d0
	bgt.w	.3						;past the last: ignore
	;(not branched to)
	move.w	d0,(VertLineScrolling).w
	cmp.w	(PlayerScrollCtr).w,d0	;above the rows shown?
	bgt.w	.1
	move.w	d0,(PlayerScrollCtr).w
.1
	subq.w	#4,d0
	cmp.w	(PlayerScrollCtr).w,d0	;below the rows shown?
	ble.w	.2
	move.w	d0,(PlayerScrollCtr).w
	;cursor inside the rows shown: redraw
.2
	bsr.w	PrintShooterList
.3
	rts
ShootersSelectPlayer	equ	*	;Shooters list: put the chosen shooter into the round slot and redraw
	movea.w	#(CalTeam-M68K_RAM),a3
	adda.w	(VertLineScrolling).w,a3
	clr.w	d0
	move.b	(a3),d0
	move.w	(setupvalues).w,d2
	movea.l	#shootoutround+2,a0
	cmpa.l	#tmstruct,a2
	beq.w	.4
	movea.l	#homeshootnum+2,a0
	;shooter list chosen
.4
	asl.w	#1,d2					;word per slot
	move.w	d0,(a0,d2.w)			;store the pick
	bra.w	ShootersLoop

PrintShooterList					;Shootout shooters: the player list rows
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),$17,2
.loop
	movea.l	#PAttribOverall,a1
	cmpi.w	#5,(setupvalues).w
	bne.w	.1
	movea.l	#GAttribOverall,a1
.1
	move.w	(DispAttribCtr).w,d0
	bra.w	.2
.loop2
	adda.w	(a1),a1
	addq.w	#4,a1
.2
	tst.w	(a1)
	dbmi	d0,.loop2
	bpl.w	.3
	subq.w	#1,(DispAttribCtr).w
	bra.s	.loop
.3
	cmpa.l	#$23444,a1
	bne.w	.4
	movea.l	#ShooterOverallTxt,a1
.4
	cmpa.l	#$235A6,a1
	bne.w	.5
	movea.l	#ShooterOverallTxt2,a1
.5
	jsr	(printbig).l
	move.l	(a1),d4
	movea.w	#(CalTeam-M68K_RAM),a3
	move.w	(PlayerScrollCtr).w,d2
	move.w	(screentimer).w,d1
	sub.w	d2,d1
	cmp.w	#4,d1
	bls.w	.6
	moveq	#4,d1
.6
	move.w	#4,(printy).w
.loop3
	jsr	(printsmallz).l
	String	$FE,7,$FD,2,$FA,1,'                         ',$FD,2
	cmp.w	(VertLineScrolling).w,d2
	bne.w	.7
	jsr	(printsmallz).l
	String	$FE,6
.7
	clr.w	d0
	move.b	(a3,d2.w),d0
	jsr	(GetNameandAttrib).l
	addq.w	#1,d2
	dbf	d1,.loop3
	rts

ShooterOverallTxt					;PrintShooterList heading, then the attribute long (d4)
	dc.b	$00,$12,$20,$20,$20,$20,$4F,$76,$65,$72,$61,$6C,$6C,$20,$20,$20
	dc.b	$20,$5D,$1F,$3A,$00,$0A

ShooterOverallTxt2					;The same for goalies
	dc.b	$00,$12,$20,$20,$20,$20,$4F,$76,$65,$72,$61,$6C,$6C,$20,$20,$20
	dc.b	$20,$5D,$1B,$0F,$00,$0A

ShootersPick						;Shootout shooters: C on a slot
	cmp.w	(setupvalues).w,d0
	beq.w	ShootersReadPad
	bra.w	ShootersMoveRedraw

ShootersMove						;Shootout shooters: move the slot cursor
	cmpi.w	#5,(setupvalues).w
	beq.w	ShootersReadPad
	add.w	(setupvalues).w,d0
	bmi.w	.1
	cmp.w	#5,d0
	blt.w	ShootersMoveRedraw
	clr.w	d0
	bra.w	ShootersMoveRedraw
.1
	move.w	#4,d0
ShootersMoveRedraw	equ	*	;Redraw the shooter rows after a move
	move.w	d0,(setupvalues).w
	bsr.w	DrawShooterRow
	bsr.w	DrawShootersTitle
	bra.w	ShootersReadPad
DrawShootersBackdrop	equ	*	;Draw the background of the shooter list
	bsr.w	ClearShootersBackdrop
	movem.l	d0-d5/a0-a2,-(sp)
	move.l	a2,-(sp)
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),0,0
	movea.l	#LineEditorBgMap2,a1
	adda.l	4(a1),a1
	movea.w	#$772,a2
	clr.w	d0
	clr.w	d1
	move.w	#$28,d2
	move.w	#$E,d3
	move.w	(ReplayIconChars+2).w,d4
	moveq	#0,d5
	jsr	(dobitmap).l
	move.w	(ReplayIconChars+6).w,d4
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),$B,1
	movea.l	#ShootoutSetupTitleMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	movea.l	#$772,a2
	move.w	(a1),d2
	move.w	2(a1),d3
	moveq	#0,d5
	jsr	(dobitmap).l
	move.w	(awardlogochars).w,d4
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),1,4
	movea.l	(sp),a2
	move.w	$28(a2),d7
	moveq	#2,d5
	jsr	(DrawTeamLogoD7).l
	move.w	#1,d4
	movea.l	#LineEditorSprites2,a1
	jsr	(LoadScreenSprite).l
	movea.l	#LineEditorSprites2,a0
	jsr	(DrawScreenSprite).l
	jsr	(printcurz).l
	String	$8F,$18,8,'start-exit',$8F,$14,9,'[]-players/goalie'
	movea.l	(sp)+,a2
	movem.l	(sp)+,d0-d5/a0-a2
	rts
ClearShootersBackdrop	equ	*	;Clear the background of the shooter list
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),0,0
	moveq	#$28,d0
	moveq	#$E,d1
	move.w	#$7FF,d2
	jmp	(eraser).l
DrawShooterName	equ	*	;Print a shooter name with the small font
	jsr	(printsmallz).l
	String	$FE,4,$FF,1,$FD,0,$FC,$A
	bset	#2,(sflags11).w
	jsr	(printbigz).l
	String	$FD,6,$FC,$F,'Shooters',$FE,7
	bclr	#2,(sflags11).w
	jsr	(printsmallz).l
	String	$FD,4,$FC,$12,'1. '
	jsr	(printsmallz).l
	String	$FD,4,$FC,$13,'2. '
	jsr	(printsmallz).l
	String	$FD,4,$FC,$14,'3. '
	jsr	(printsmallz).l
	String	$FD,4,$FC,$15,'4. '
	jsr	(printsmallz).l
	String	$FD,4,$FC,$16,'5. '
	bset	#2,(sflags11).w
	jsr	(printbigz).l
	String	$FE,4,$FD,$18,$FC,$F,'Goalie',$FE,7
	bclr	#2,(sflags11).w
	rts
DrawShootersTitle					;Print the title of the shooter list
	bset	#2,(sflags11).w
	jsr	(printbigz).l
	String	$F8,4,1,$15,$C,'                '
	jsr	(printsmallz).l
	String	$F8,4,1,$1E,$C
	movea.l	#shootoutround+2,a1
	cmpa.l	#$FFFFC726,a2
	beq.w	.1
	movea.l	#homeshootnum+2,a1
.1
	move.w	(setupvalues).w,d0
	asl.w	#1,d0
	move.w	(a1,d0.w),d0
	jsr	(FormatPlayerName).l
	move.w	(a1),d0
	lsr.w	#1,d0
	sub.w	d0,(printx).w
	jsr	(printbig).l
	bclr	#2,(sflags11).w
	rts
DrawShooterRow						;Print one row of the shooter list
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(printsmallz).l
	String	$FD,6,$FC,$12,$FE,7
	move.w	#0,d1
	movea.l	#shootoutround+2,a0
	cmpa.l	#tmstruct,a2
	beq.w	.loop
	movea.l	#homeshootnum+2,a0
.loop
	move.w	d1,d0
	asl.w	#1,d0
	move.w	(a0,d0.w),d0
	jsr	(FormatPlayerNameShort).l
	move.w	(printx).w,-(sp)
	cmp.w	(setupvalues).w,d1
	bne.w	.1
	jsr	(printsmallz).l
	String	$FE,6
.1
	cmp.w	#5,d1
	bne.w	.2
	move.w	#$18,(printx).w
	move.w	#$12,(printy).w
.2
	jsr	(printsmall).l
	jsr	(printsmallz).l
	String	$FE,7
	move.w	(sp)+,(printx).w
	addq.w	#1,(printy).w
	addq.w	#1,d1
	cmp.w	#6,d1
	blt.s	.loop
	movem.l	(sp)+,d0-d7/a0-a6
	rts
SetupShootersVideo	equ	*	;Set the VBint handler, scroll and map addresses for the shooter list and load its graphics
	move.l	a2,-(sp)
	bset	#5,(sflags12).w
	move.l	#VBlank_Menus,(VBint).w
	bclr	#dfok,(disflags).w
	bset	#dfng,(disflags).w
	bclr	#df32c,(disflags).w
	move.w	#0,(VSCRLPM).w
	move.w	#$B800,(VSPRITES).w
	move.w	#$B800,(VmMAP3).w
	move.w	#5,(Map3col1).w
	move.w	#$C000,(VmMAP2).w
	move.w	#6,(Map2col).w
	move.w	#$E000,(VmMAP1).w
	move.w	#6,(Map1col).w
	move.w	#0,d0					;fade to color
	bset	#5,(disflags).w
	jsr	(setVram).l
	bclr	#5,(disflags).w
	jsr	(orjoy).l
	move.w	#1,d4
	movea.l	#LineEditorSprites2,a1
	jsr	(LoadScreenSprite).l
	move.w	#$1E,d4
	move.w	d4,(smallfontchars).w
	movea.l	#RosterFont+8,a2
	jsr	(DecompressGraphicsPlain).l
	move.w	d4,(smallfont2chars).w
	movea.l	#SmallFontMap2+8,a2
	jsr	(DecompressGraphicsPlain).l
	move.l	#RosterFont,(smallfontptr).w
	move.w	d4,(BigFontchars).w
	movea.l	#BigFontMap4+8,a2
	jsr	(DecompressGraphicsPlain).l
	bset	#2,(sflags11).w
	jsr	(printsmallz).l
	String	$FF,1,$FD,0,$FC
	moveq	#$28,d0
	moveq	#$1C,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	move.w	d4,(ReplayIconChars+2).w
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),0,0
	movea.l	#LineEditorBgMap2,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	moveq	#$28,d2
	moveq	#$1C,d3
	moveq	#8,d5
	jsr	(dobitmap).l
	move.w	d4,(ReplayIconChars+4).w
	movea.l	#LineEditorBgMap+8,a2
	jsr	(DecompressGraphicsPlain).l
	move.w	d4,(awardlogochars).w
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),1,4
	movea.l	(sp),a2
	move.w	$28(a2),d7
	moveq	#2,d5
	jsr	(DrawTeamLogoD7).l
	move.w	d4,(ReplayIconChars+6).w
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),$B,1
	movea.l	#ShootoutSetupTitleMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	move.w	(a1),d2
	move.w	2(a1),d3
	moveq	#8,d5
	jsr	(dobitmap).l
	bsr.w	ShootersPrintLabel
	jsr	(printz).l
	String	$FE,0,0
	movea.l	#IceBgMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	moveq	#$40,d2
	moveq	#$1C,d3
	moveq	#1,d5
	jsr	(dobitmap).l
	movea.l	#LineEditorSprites2,a0
	jsr	(DrawScreenSprite).l
	bsr.w	CopyStatsPalette
	movea.l	(sp)+,a2
	rts
ShootersPrintLabel	equ	*	;Print the shooter label with the second small font
	move.w	(smallfontchars).w,-(sp)
	move.w	(smallfont2chars).w,(smallfontchars).w
	jsr	(printcurz).l
	String	$8F,7,$19,'{}[]-highlight player',$8F,$A,$1A,'c-select player'
	move.w	(sp)+,(smallfontchars).w
	rts

RecordHoldersScreen					;Pause menu Record Holders
	bsr.w	RecordsScreenInit
	move.w	#$18,(palcount).w
	bclr	#2,(disflags).w
	jsr	(ReadNameLog).l
	clr.w	(TempWord1).w
	bclr	#6,(sflags6).w
	bsr.w	ReadTeamRecords
	bset	#6,(sflags6).w
	bsr.w	ReadTeamRecords
	bsr.w	CalcWinPercents
	bsr.w	PrintRecordTitles
	bsr.w	RecHeaderSavesRow
.loop
	move.w	#$2500,sr
	jsr	(vcountwait).l
	jsr	(SetMenuScroll).l
	jsr	(ReadMenuJoy).l
	jsr	(ProcessInputWithRepeat).l
	btst	#7,d3
	beq.w	.1
	rts
.1
	tst.w	(TempWord1).w
	bne.w	.2
	btst	#6,d3
	beq.w	.2
	btst	#5,d3
	beq.w	.2
	jsr	(ClearWinRecords).l
	bsr.w	CalcWinPercents
	bsr.w	RecHeaderSavesRow
	bra.s	.loop
.2
	btst	#3,d1
	beq.w	.3
	cmpi.w	#2,(TempWord1).w
	beq.s	.loop
	bsr.w	RecHeaderSavesBox
	addq.w	#1,(TempWord1).w
	bsr.w	PrintRecordTitles
	bsr.w	RecordsChoosePage
	bra.s	.loop
.3
	btst	#2,d1
	beq.s	.loop
	tst.w	(TempWord1).w
	beq.s	.loop
	bsr.w	RecHeaderSavesBox
	subq.w	#1,(TempWord1).w
	bsr.w	PrintRecordTitles
	bsr.w	RecordsChoosePage
	bra.w	.loop
	rts								;never reached
RecordsChoosePage					;Records screen: pick the page by TempWord1
	tst.w	(TempWord1).w
	beq.w	RecHeaderSavesRow
	bra.w	RecHeaderSavesRowTotal
PrintRecordTitles					;Print the heading of the record page: wins, saves or goals
	movea.l	#RecHeaderWins,a1
	tst.w	(TempWord1).w
	beq.w	.1
	movea.l	#RecHeaderSaves,a1
	cmpi.w	#2,(TempWord1).w
	beq.w	.1
	movea.l	#RecHeaderGoals,a1
.1
	bset	#2,(sflags11).w
	jsr	(printbig).l
	rts

RecHeaderWins						;Record screen heading: name, win%, win, loss, tie
	String	CC_SetMapAndPosition,$04,$01,$05,$06,'name',CC_SetX,$10,'win% ',CC_SetX,$17,'win',CC_SetX,$1C,'loss',CC_SetX,$21,'tie'

RecHeaderGoals						;Record screen heading: name, goals, teams
	String	CC_SetMapAndPosition,$04,$01,$05,$06,'name',CC_SetX,$10,'goals',CC_SetX,$1C,'teams'

RecHeaderSaves						;Record screen heading: name, saves, teams
	String	CC_SetMapAndPosition,$04,$01,$05,$06,'name',CC_SetX,$10,'saves',CC_SetX,$1C,'teams'
RecHeaderSavesRow	equ	*	;Print the saves record header row
	movem.l	d0-d7/a0-a6,-(sp)
	bclr	#2,(sflags11).w
	jsr	(printsmallz).l
	String	$F8,4,1,3,9
	move.w	#6,d7
	movea.l	#$FFFFD402,a0
	movea.l	#$FFFFD40A,a2
	movea.l	#ThreeStars,a5
.loop
	move.w	#3,(printx).w
	move.b	(a0)+,d0
	ext.w	d0
	move.b	(a2,d0.w),d5
	asl.w	#4,d0
	move.b	$A(a5,d0.w),d4
	lsl.w	#8,d4
	move.b	$B(a5,d0.w),d4
	move.w	d4,-(sp)
	move.b	$C(a5,d0.w),d4
	lsl.w	#8,d4
	move.b	$D(a5,d0.w),d4
	move.w	d4,(recwins+4).w
	move.b	8(a5,d0.w),d4
	lsl.w	#8,d4
	move.b	9(a5,d0.w),d4
	move.w	d4,(recwins+8).w
	add.w	(recwins+4).w,d4
	sub.w	(sp),d4
	neg.w	d4
	move.w	d4,(recwins+6).w
	move.w	(sp)+,d4
	tst.w	d4
	beq.w	.1
	bsr.w	PrintRecordName
	move.w	#$10,(printx).w
	move.w	d0,-(sp)
	move.w	d5,d0
	move.w	#3,d1
	jsr	(PushNumberWidth).l
	bclr	#2,(sflags11).w
	jsr	(printbig).l
	move.w	#$17,(printx).w
	move.w	(recwins+8).w,d0
	move.w	#4,d1
	jsr	(PushNumberWidth).l
	jsr	(printbig).l
	move.w	#$1C,(printx).w
	move.w	(recwins+6).w,d0
	move.w	#4,d1
	jsr	(PushNumberWidth).l
	jsr	(printbig).l
	move.w	#$21,(printx).w
	move.w	(recwins+4).w,d0
	move.w	#3,d1
	jsr	(PushNumberWidth).l
	move.w	(sp)+,d0
	bra.w	.2
.1
	movea.l	#RecBlankTxt,a1
.2
	bclr	#2,(sflags11).w
	jsr	(printbig).l
	addq.w	#2,(printy).w
	dbf	d7,.loop
	movem.l	(sp)+,d0-d7/a0-a6
	rts
RecHeaderSavesBox	equ	*	;Print the saves record header box
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(printx).w,-(sp)
	move.w	(printy).w,-(sp)
	move.w	(printm).w,-(sp)
	bset	#2,(sflags11).w
	jsr	(printbigz).l
	String	$F8,4,1,5,6,'                               '
	jsr	(printsmallz).l
	String	$F8,7,1,2,9
	move.w	#$24,d0
	move.w	#$F,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	move.w	(sp)+,(printm).w
	move.w	(sp)+,(printy).w
	move.w	(sp)+,(printx).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts
RecHeaderSavesRowTotal	equ	*	;Print the saves record header total row
	movem.l	d0-d7/a0-a6,-(sp)
	bclr	#2,(sflags11).w
	jsr	(printsmallz).l
	String	$F8,4,1,3,9
	move.w	#6,d7
	movea.l	#$FFFFD3F2,a0
	cmpi.w	#1,(TempWord1).w
	beq.w	.3
	movea.l	#$FFFFD3FA,a0
.3
	movea.l	#ThreeStars,a2
.loop2
	move.w	#3,(printx).w
	move.b	(a0)+,d0
	ext.w	d0
	asl.w	#4,d0
	move.b	(a2,d0.w),d5
	cmpi.w	#1,(TempWord1).w
	beq.w	.4
	move.b	4(a2,d0.w),d5
.4
	tst.b	d5
	beq.w	.11
	bsr.w	PrintRecordName
	move.w	#$10,(printx).w
	move.w	d0,-(sp)
	cmpi.w	#1,(TempWord1).w
	bne.w	.5
	move.b	(a2,d0.w),d0
	bra.w	.6
.5
	move.b	4(a2,d0.w),d0
.6
	andi.w	#$FF,d0
	move.w	#3,d1
	jsr	(PushNumberWidth).l
	jsr	(printbig).l
	move.w	(sp)+,d0
	move.w	#$18,(printx).w
	movea.l	#RecHolderByTxt,a1
	movea.l	#mesarea,a3
	jsr	(CopyString).l
	move.w	d0,-(sp)
	cmpi.w	#1,(TempWord1).w
	bne.w	.7
	move.b	1(a2,d0.w),d0
	bra.w	.8
.7
	move.b	5(a2,d0.w),d0
.8
	andi.w	#$FF,d0
	movea.l	#mesarea,a1
	jsr	(AppendTeamName).l
	movea.l	#RecHolderVsTxt,a1
	movea.l	#mesarea,a3
	jsr	(appstring).l
	movea.l	#mesarea,a1
	move.w	(sp)+,d0
	cmpi.w	#1,(TempWord1).w
	bne.w	.9
	move.b	2(a2,d0.w),d0
	bra.w	.10
.9
	move.b	6(a2,d0.w),d0
.10
	andi.w	#$FF,d0
	jsr	(AppendTeamName).l
	bra.w	.12
.11
	movea.l	#RecBlankTxt,a1
.12
	bclr	#2,(sflags11).w
	jsr	(printbig).l
	addq.w	#2,(printy).w
	dbf	d7,.loop2
	movem.l	(sp)+,d0-d7/a0-a6
	rts

RecBlankTxt							;A blank record row
	String	'                                   '

RecHolderByTxt						;"by "
	String	'by '

RecHolderVsTxt						;" vs. "
	String	' vs. '

PrintRecordName						;Record Holders: print the row number and the user name Code the listing
	move.w	d7,-(sp)
	neg.w	d7
	addq.w	#7,d7
	addi.w	#$30,d7
	movea.l	#mesarea,a1
	move.w	#6,(a1)
	move.b	d7,2(a1)
	move.b	#$2E,3(a1)
	move.b	#$20,4(a1)
	move.b	#0,5(a1)
	jsr	(printbig).l
	move.w	(sp)+,d7
	move.b	-$1(a0),d2
	ext.w	d2
	movea.l	#mesarea,a1
	bclr	#7,(sflags6).w
	jsr	(AppendUserName).l
	move.b	#$20,$B(a1)
	jmp	(printbig).l

CalcWinPercents						;The win %, games and ties of the user record blocks Code the listing does
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#ThreeStars,a0
	movea.l	#$FFFFD40A,a1
	movea.l	#$FFFFD412,a6
	movea.l	#$FFFFD422,a5
	move.w	#7,d7
.loop
	move.b	8(a0),d0
	lsl.w	#8,d0
	move.b	9(a0),d0
	move.b	$A(a0),d1
	lsl.w	#8,d1
	move.b	$B(a0),d1
	move.w	d1,(a5)+
	tst.w	d1
	bne.w	.1
	clr.w	d0
	bra.w	.2
.1
	mulu.w	#$64,d0
	divu.w	d1,d0
.2
	move.b	d0,(a1)+
	move.b	$C(a0),(a6)+
	move.b	$D(a0),(a6)+
	adda.w	#$10,a0
	dbf	d7,.loop
	movea.l	#$FFFFD402,a1
	move.l	a1,-(sp)
	move.w	#1,d0
	move.w	#6,d7
.loop2
	move.b	d0,(a1)+
	addq.w	#1,d0
	dbf	d7,.loop2
	movea.l	(sp),a1
	movea.l	#$FFFFD40A,a0
	movea.l	#$FFFFD412,a6
	movea.l	#$FFFFD422,a5
.loop3
	movea.l	(sp),a1
	move.w	#5,d7
	clr.w	d6
.loop4
	move.b	(a1)+,d1
	ext.w	d1
	move.b	(a1),d2
	ext.w	d2
	move.b	(a0,d1.w),d0
	move.b	(a0,d2.w),d3
	cmp.b	d3,d0
	bgt.w	.4
	blt.w	.3
	movem.l	d1-d3,-(sp)
	add.w	d1,d1
	add.w	d2,d2
	move.w	(a6,d1.w),d0
	move.w	(a6,d2.w),d3
	cmp.w	d3,d0
	movem.l	(sp)+,d1-d3
	bgt.w	.4
	blt.w	.3
	movem.l	d1-d3,-(sp)
	add.w	d1,d1
	add.w	d2,d2
	move.w	(a5,d1.w),d0
	move.w	(a5,d2.w),d3
	cmp.w	d3,d0
	movem.l	(sp)+,d1-d3
	bge.w	.4
.3
	move.b	(a1),d0
	move.b	-$1(a1),d1
	move.b	d0,-$1(a1)
	move.b	d1,(a1)
	st	d6
.4
	dbf	d7,.loop4
	tst.w	d6
	bne.s	.loop3
	movea.l	(sp)+,a1
	movem.l	(sp)+,d0-d7/a0-a6
	rts

ReadTeamRecords						;Read the records from save RAM and sort the rows Code the listing does
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	#$ECE,d0
	move.l	#$80,d1
	movea.l	#ThreeStars,a0
	jsr	(ReadSRAM).l
	movea.l	#$FFFFD3F2,a1
	btst	#6,(sflags6).w
	beq.w	.1
	movea.l	#$FFFFD3FA,a1
.1
	move.l	a1,-(sp)
	move.w	#1,d0
	move.w	#6,d7
.loop
	move.b	d0,(a1)+
	addq.w	#1,d0
	dbf	d7,.loop
	movea.l	(sp),a1
	movea.l	#ThreeStars,a0
.loop2
	movea.l	(sp),a1
	move.w	#5,d7
	clr.w	d6
.loop3
	move.b	(a1)+,d1
	ext.w	d1
	move.b	(a1),d2
	ext.w	d2
	asl.w	#4,d1
	asl.w	#4,d2
	move.b	(a0,d1.w),d0
	move.b	(a0,d2.w),d3
	btst	#6,(sflags6).w
	beq.w	.2
	move.b	4(a0,d1.w),d0
	move.b	4(a0,d2.w),d3
.2
	cmp.b	d3,d0
	bge.w	.3
	move.b	(a1),d0
	move.b	-$1(a1),d1
	move.b	d0,-$1(a1)
	move.b	d1,(a1)
	st	d6
.3
	dbf	d7,.loop3
	tst.w	d6
	bne.s	.loop2
	movea.l	(sp)+,a1
	movem.l	(sp)+,d0-d7/a0-a6
	rts
RecordsScreenInit					;Set up the planes and VBlank handler of the team records screen
	move.l	a2,-(sp)
	bset	#5,(sflags12).w
	move.l	#VBlank_Menus,(VBint).w
	bclr	#dfok,(disflags).w
	bset	#dfng,(disflags).w
	bclr	#df32c,(disflags).w
	move.w	#0,(VSCRLPM).w
	move.w	#$B800,(VSPRITES).w
	move.w	#$B800,(VmMAP3).w
	move.w	#5,(Map3col1).w
	move.w	#$C000,(VmMAP2).w
	move.w	#6,(Map2col).w
	move.w	#$E000,(VmMAP1).w
	move.w	#6,(Map1col).w
	move.w	#0,d0					;fade to color
	bset	#5,(disflags).w
	jsr	(setVram).l
	bclr	#5,(disflags).w
	jsr	(orjoy).l
	move.w	#1,d4
	movea.l	#RecordHoldersSprites,a1
	jsr	(LoadScreenSprite).l
	move.w	d4,(smallfont2chars).w
	movea.l	#SmallFontMap2+8,a2
	jsr	(DecompressGraphicsPlain).l
	move.l	#RosterFont,(smallfontptr).w
	move.w	d4,(bigfont1chars).w
	movea.l	#BigFontMap2+8,a2
	jsr	(DecompressGraphicsPlain).l
	move.w	(bigfont1chars).w,(printbigchars).w
	move.w	d4,(BigFontchars).w
	movea.l	#BigFontMap4+8,a2
	jsr	(DecompressGraphicsPlain).l
	bset	#2,(sflags11).w
	jsr	(printsmallz).l
	String	$FF,1,$FD,0,$FC
	moveq	#$28,d0
	moveq	#$1C,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),0,0
	movea.l	#RecordHoldersBgMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	moveq	#$28,d2
	moveq	#$1C,d3
	moveq	#8,d5
	jsr	(dobitmap).l
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),$B,1
	movea.l	#RecordHoldersTitleMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	move.w	(a1),d2
	move.w	2(a1),d3
	moveq	#8,d5
	jsr	(dobitmap).l
	jsr	(printz).l
	String	$FE,0,0
	movea.l	#ControllerBgMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	moveq	#$40,d2
	moveq	#$1C,d3
	moveq	#1,d5
	jsr	(dobitmap).l
	move.w	(smallfontchars).w,-(sp)
	move.w	(smallfont2chars).w,(smallfontchars).w
	jsr	(printcurz).l
	String	$8F,7,$19,'[]-change category',$8F,6,$1A,'a+c-clear all win records'
	move.w	(sp)+,(smallfontchars).w
	movea.l	#RecordHoldersSprites,a0
	jsr	(DrawScreenSprite).l
	movea.l	(sp)+,a2
	rts

