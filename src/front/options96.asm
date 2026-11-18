;	The game options screen. New in 96.

OptionsScreen						;The game options screen: play mode, rosters, period length, goalies, user
									;records, penalties, line changes, fighting and skill level
									;(OptionsMenuList; left / right change OptionVars). Start saves them
									;(WriteOptions) and sets the play mode (SetPlayMode); transactions go to
									;PlayoffMenuScreen. Left alone (carddelay) it puts the options back to the
									;defaults
	move.w	#$15,(skillspeed).w
	move.w	#$1D,(skillspeedpal).w
	move.w	(HVcount).l,(seed).w
	move.w	(HVcount).l,(seed+2).w
	clr.w	(optanimframe).w
	clr.w	(optanimdelay).w
	st	(demoflag).w
	jsr	(ReadPassData).l
	movea.l	#pwddatabuffer,a3
	jsr	(ReadPassBits).l
	move.w	(gamelevel).w,d0
	or.w	(bosgames).w,d0
	beq.w	.0
	jsr	(MakeTree).l
.0
	jsr	(ReadSeasonHeader).l
	bclr	#1,(sflags13).w
	btst	#1,(SeasonFlags).w
	beq.w	.1
	btst	#3,(SeasonFlags).w
	bne.w	.1
	bset	#1,(sflags13).w
.1
	bsr.w	ReadOptions
	cmpi.w	#4,(OptPlayMode).w
	bne.w	.2
	btst	#1,(sflags13).w
	bne.w	.2
	tst.b	(SeasonTeam).w
	bpl.w	.2
	clr.w	(OptPlayMode).w
.2
	cmpi.w	#1,(OptPlayMode).w
	bne.w	.3
	move.w	(gamelevel).w,d0
	or.w	(bosgames).w,d0
	bne.w	.3
	clr.w	(OptPlayMode).w
.3
	bclr	#1,(sflags7).w
	bsr.w	ClearGameRAM
	clr.w	(carddelay).w
	bsr.w	OptionsMenuInit
	bsr.w	OptionsScreenSetup
	movea.l	#MainMenuSprites,a0
	jsr	(DrawScreenSprite).l
	jsr	(PStatsPalette).l
	move.w	#$18,(palcount).w
	bclr	#dfng,(disflags).w
.4
	bsr.w	OptionsMenuDraw
	move	#$2500,sr
.frame
	move.w	(Vcount).w,d0
.loop2
	cmp.w	(Vcount).w,d0
	beq.s	.loop2
	jsr	(SetMenuScroll).l
	addq.w	#1,(carddelay).w
	cmpi.w	#$2A30,(carddelay).w
	bge.w	.16
	move.w	(optanimdelay).w,d0
	addq.w	#1,d0
	cmp.w	#8,d0
	blt.w	.5
	bsr.w	OptionsAnimFrame
	addq.w	#1,(optanimframe).w
	andi.w	#7,(optanimframe).w
	clr.w	d0
.5
	move.w	d0,(optanimdelay).w
	jsr	(FindHeldMenuPad).l
	jsr	(ProcessInputWithRepeat).l
	tst.w	d1
	beq.w	.6
	clr.w	(carddelay).w
.6
	move.b	d1,(OptPad).w
	btst	#7,d1
	bne.w	.17
	btst	#1,d1
	beq.w	.up
	cmpi.w	#8,(menuitem).w
	beq.s	.frame
	cmpi.w	#7,(OptPlayMode).w
	beq.s	.frame
	cmpi.w	#4,(OptPlayMode).w
	beq.w	.frame
	cmpi.w	#5,(OptPlayMode).w
	beq.w	.frame
.7
	addq.w	#1,(menuitem).w
	cmpi.w	#1,(menuitem).w
	bne.w	.8
	cmpi.w	#1,(OptPlayMode).w
	beq.s	.7
	cmpi.w	#2,(OptPlayMode).w
	beq.s	.7
	cmpi.w	#3,(OptPlayMode).w
	beq.s	.7
	cmpi.w	#7,(menuitem).w
	bne.w	*+4
.8
	cmpi.w	#6,(OptPlayMode).w
	bne.w	.4
	cmpi.w	#3,(menuitem).w
	bne.w	.9
	addq.w	#5,(menuitem).w
	bra.w	.4
.9
	cmpi.w	#2,(menuitem).w
	bne.w	.10
	addq.w	#1,(menuitem).w
.10
	cmpi.w	#4,(menuitem).w
	bne.w	.4
	addq.w	#4,(menuitem).w
	bra.w	.4
.up
	btst	#ubut,d1				;ubut
	beq.w	.14
	tst.w	(menuitem).w
	beq.w	.frame
	subq.w	#1,(menuitem).w
	cmpi.w	#1,(menuitem).w
	bne.w	.12
	cmpi.w	#1,(OptPlayMode).w
	beq.w	.11
	cmpi.w	#2,(OptPlayMode).w
	beq.w	.11
	cmpi.w	#3,(OptPlayMode).w
	bne.w	.12
.11
	clr.w	(menuitem).w
.12
	cmpi.w	#7,(menuitem).w
	bne.w	*+4
.13
	cmpi.w	#6,(OptPlayMode).w
	bne.w	.4
.37
	cmpi.w	#3,(menuitem).w
	bne.w	.prev
	bra.w	.4
.prev
	cmpi.w	#1,(menuitem).w
	beq.w	.4
	tst.w	(menuitem).w
	beq.w	.4
	subq.w	#1,(menuitem).w
	bra.s	.37
.14
	btst	#2,d1
	beq.w	.15
	movea.l	#OptionVars,a0
	move.w	(menuitem).w,d0
	asl.w	#2,d0
	movea.l	(a0,d0.w),a0
	subq.w	#1,(a0)
	bra.w	.4
.15
	btst	#3,d1
	beq.w	.frame
	movea.l	#OptionVars,a0
	move.w	(menuitem).w,d0
	asl.w	#2,d0
	movea.l	(a0,d0.w),a0
	addq.w	#1,(a0)
	bra.w	.4
.16
	clr.w	(demoflag).w
	clr.w	(OptPlayMode).w
	clr.w	(OptRosters).w
	clr.w	(Optperlen).w
	move.w	#1,(OptGoalie).w
	clr.w	(OptUserRec).w
	move.w	#2,(OptPen).w
	clr.w	(OptLine).w
	move.w	#1,(OptFighting).w
	move.w	#1,(OptSkill).w
	bra.w	.18
.17
	move.w	#4,(OptNOP).w
	bsr.w	WriteOptions
	cmpi.w	#7,(OptPlayMode).w
	bne.w	.18
	jsr	(PlayoffMenuScreen).l
	bra.w	OptionsScreen
.18
	bsr.w	SetPlayMode
	btst	#7,(GameFlags).w
	beq.w	.19
	jsr	(ReadSeasonHeader).l
	btst	#2,(SeasonFlags).w
	beq.w	.19
	jsr	(ReadPassData).l
	jsr	(ReadPassBits).l
	tst.w	(WinBits).w
	bne.w	.19
	tst.w	(bosgames).w
	bne.w	.19
	jmp	NewPO
.19
	jsr	(MakeTree).l
	rts

OptionVars							;OptionsScreen: the option of each menu row
	dc.l	OptPlayMode,OptRosters,Optperlen,OptGoalie,OptUserRec
	dc.l	OptPen,OptLine,OptFighting,OptSkill

OptionsMenuDraw						;OptionsScreen: draw the menu (PrintMenuList2)
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(PrintMenuList2).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

OptionsScreenSetup					;OptionsScreen: vram, fonts, the screen bitmaps and the row labels
	bset	#5,(sflags12).w
	move.l	#VBlank_Menus,(VBint).w
	bclr	#dfok,(disflags).w
	bset	#dfng,(disflags).w
	bclr	#df32c,(disflags).w
	move.w	#0,(VSCRLPM).w
	move.w	#$B400,(VSPRITES).w
	move.w	#$B800,(VmMAP3).w
	move.w	#5,(Map3col1).w
	move.w	#$C000,(VmMAP2).w
	move.w	#6,(Map2col1).w
	move.w	#$E000,(VmMAP1).w
	move.w	#6,(Map1col1).w
	move.w	#0,d0
	bset	#5,(disflags).w
	jsr	(setVram).l
	bclr	#5,(disflags).w
	jsr	(orjoy).l
	move.w	#1,d4
	movea.l	#MainMenuSprites,a1
	jsr	(LoadScreenSprite).l
	move.w	d4,(smallfontchars).w
	movea.l	#RosterFont+8,a2
	jsr	(DecompressGraphicsPlain).l
	move.w	d4,(smallfont2chars).w
	movea.l	#SmallFontMap2+8,a2
	jsr	(DecompressGraphicsPlain).l
	move.l	#RosterFont,(smallfontptr).w
	move.w	d4,(puckanimchars).w
	movea.l	#PuckAnimMap+8,a2
	jsr	(DecompressGraphicsPlain).l
	jsr	(printsmallz).l
	String	CC_SetMap,$01,CC_SetX,$00,CC_SetY
	moveq	#$28,d0
	moveq	#$1C,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	jsr	(printz).l
	String	CC_Font1Pri,$00,$00
	movea.l	#MainMenuBgMap,a0
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
	String	CC_Font1Pri,$0B,$01
	movea.l	#MainMenuTitleMap,a0
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
	String	CC_Font2,$00,$00
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
	jsr	(printcurz).l
	String	<$8F,$03,$09>,'Play mode:',<$8F,$03,$0B>,'rosters:',<$8F,$03,$0D>,'period length:',<$8F,$03,$0F>,'goalies:',<$8F,$03,$11>,'user records:',<$8F,$03,$13>,'penalties:',<$8F,$03,$15>,'line changes:',<$8F,$03,$17>,'fighting:',<$8F,$03,$19>,'skill level:'
	move	#$2500,sr
	rts

ClearGameRAM						;Clear the shootout words, both team structs, PenBuf and the game flags
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#$FFFFD432,a0
	moveq	#$12,d0
.shoot
	clr.w	(a0)+
	dbf	d0,.shoot
	movea.l	#tmstruct,a0
	move.w	#$39D,d0
.loop
	clr.w	(a0)+
	dbf	d0,.loop
	movea.l	#PenBuf,a0
	moveq	#$4E,d0
.4
	clr.w	(a0)+
	dbf	d0,.4
	clr.w	(BA_PS_flags).w
	clr.w	(sflags4).w
	clr.w	(sflags6).w
	clr.w	(gmode2).w
	clr.w	(SetupSpare).w
	clr.w	(SetupSpare16).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts

OptionsMenuInit						;OptionsScreen: menulist = OptionsMenuList, item 0
	move.l	#OptionsMenuList,(menulist).l
	clr.w	(menuitem).w
	clr.w	(menuitem+2).w
	move.w	#9,(menurows).w
	move.w	#$13,(menux).w
	move.w	#9,(menuy).w
	rts

OptionsMenuList						;The options menu: each item routine keeps its option in range and returns
									;its text in a1
	String	CC_SetAttribute,$07,CC_SetFont
	String	CC_SetAttribute,$05,CC_SetFont
	dc.l	PlayModeItem,RostersItem,PerLenItem,GoalieItem,UserRecItem
	dc.l	PenaltyItem,LineItem,FightingItem,SkillItem,-1

SkillItem							;Options menu row: skill level
	cmpi.w	#4,(OptPlayMode).w
	beq.w	PerLenItemNA
	cmpi.w	#5,(OptPlayMode).w
	beq.w	PerLenItemNA
	cmpi.w	#7,(OptPlayMode).w
	bge.w	PerLenItemNA
	move.w	(OptSkill).w,d0
	cmp.w	#2,d0
	ble.w	.1
	clr.w	d0
.1
	tst.w	d0
	bpl.w	.2
	move.w	#2,d0
.2
	move.w	d0,(OptSkill).w
	movea.l	#SkillText,a1
	jsr	(SkipStrings).l
	rts

FightingItem						;Options menu row: fighting
	cmpi.w	#4,(OptPlayMode).w
	beq.w	PerLenItemNA
	cmpi.w	#5,(OptPlayMode).w
	beq.w	PerLenItemNA
	cmpi.w	#6,(OptPlayMode).w
	bge.w	PerLenItemNA
	move.w	(OptFighting).w,d0
	cmp.w	#1,d0
	ble.w	.1
	clr.w	d0
.1
	tst.w	d0
	bpl.w	.2
	move.w	#1,d0
.2
	move.w	d0,(OptFighting).w
	movea.l	#FightingText,a1
	jsr	(SkipStrings).l
	rts

LineItem							;Options menu row: line changes
	cmpi.w	#4,(OptPlayMode).w
	beq.w	PerLenItemNA
	cmpi.w	#5,(OptPlayMode).w
	beq.w	PerLenItemNA
	cmpi.w	#6,(OptPlayMode).w
	bge.w	PerLenItemNA
	move.w	(OptLine).w,d0
	cmp.w	#2,d0
	ble.w	.1
	clr.w	d0
.1
	tst.w	d0
	bpl.w	.2
	move.w	#2,d0
.2
	move.w	d0,(OptLine).w
	movea.l	#LineText,a1
	jsr	(SkipStrings).l
	rts

PenaltyItem							;Options menu row: penalties
	cmpi.w	#4,(OptPlayMode).w
	beq.w	PerLenItemNA
	cmpi.w	#5,(OptPlayMode).w
	beq.w	PerLenItemNA
	cmpi.w	#6,(OptPlayMode).w
	bge.w	PerLenItemNA
	move.w	(OptPen).w,d0
	cmp.w	#2,d0
	ble.w	.1
	clr.w	d0
.1
	tst.w	d0
	bpl.w	.2
	move.w	#2,d0
.2
	move.w	d0,(OptPen).w
	movea.l	#PenaltyText,a1
	jsr	(SkipStrings).l
	rts

UserRecItem							;Options menu row: user records
	cmpi.w	#4,(OptPlayMode).w
	beq.w	PerLenItemNA
	cmpi.w	#5,(OptPlayMode).w
	beq.w	PerLenItemNA
	cmpi.w	#6,(OptPlayMode).w
	bge.w	PerLenItemNA
	move.w	(OptUserRec).w,d0
	cmp.w	#1,d0
	ble.w	.1
	clr.w	d0
.1
	tst.w	d0
	bpl.w	.2
	move.w	#1,d0
.2
	move.w	d0,(OptUserRec).w
	movea.l	#UserRecText,a1
	jsr	(SkipStrings).l
	rts

GoalieItem							;Options menu row: goalies
	cmpi.w	#4,(OptPlayMode).w
	beq.w	PerLenItemNA
	cmpi.w	#5,(OptPlayMode).w
	beq.w	PerLenItemNA
	cmpi.w	#7,(OptPlayMode).w
	beq.w	PerLenItemNA
	move.w	(OptGoalie).w,d0
	cmp.w	#1,d0
	ble.w	.1
	clr.w	d0
.1
	tst.w	d0
	bpl.w	.2
	move.w	#1,d0
.2
	move.w	d0,(OptGoalie).w
	movea.l	#GoalieText,a1
	jsr	(SkipStrings).l
	rts

PerLenItem							;Options menu row: period length
	cmpi.w	#6,(OptPlayMode).w
	blt.w	.1
PerLenItemNA	equ	*			;Not applicable text item
.loop
	movea.l	#NotApplicableText,a1
	rts
.1
	cmpi.w	#4,(OptPlayMode).w
	beq.s	.loop
	cmpi.w	#5,(OptPlayMode).w
	beq.s	.loop
	cmpi.w	#4,(OptPlayMode).w
	beq.s	.loop
	move.w	(Optperlen).w,d0
	cmp.w	#3,d0
	blt.w	.2
	clr.w	d0
.2
	tst.w	d0
	bpl.w	.3
	move.w	#2,d0
.3
	move.w	d0,(Optperlen).w
	movea.l	#PerLenText,a1
	jsr	(SkipStrings).l
	rts

RostersItem							;Options menu row: rosters
	cmpi.w	#7,(OptPlayMode).w
	beq.s	PerLenItemNA
	cmpi.w	#5,(OptPlayMode).w		;5?
	beq.s	PerLenItemNA
	cmpi.w	#4,(OptPlayMode).w
	beq.s	PerLenItemNA
	cmpi.w	#1,(OptPlayMode).w
	beq.s	PerLenItemNA
	cmpi.w	#2,(OptPlayMode).w
	beq.s	PerLenItemNA
	cmpi.w	#3,(OptPlayMode).w
	beq.s	PerLenItemNA
	move.w	(OptRosters).w,d0
	cmp.w	#1,d0
	ble.w	.1
	clr.w	d0
.1
	tst.w	d0
	bpl.w	.2
	move.w	#1,d0
.2
	move.w	d0,(OptRosters).w
	movea.l	#RostersText,a1
	jsr	(SkipStrings).l
	rts

PlayModeItem						;Options menu row: play mode
	move.w	(OptPlayMode).w,d0
	bpl.w	.1
	move.w	#7,d0
.1
	cmp.w	#7,d0
	ble.w	.2
	clr.w	d0
.2
	cmp.w	#7,d0
	bne.w	.4
	btst	#2,(SeasonDay+2).w
	beq.w	.4
	btst	#2,(OptPad).w
	beq.w	.3
	move.w	#6,(OptPlayMode).w
	bra.s	PlayModeItem
.3
	clr.w	(OptPlayMode).w
	bra.s	PlayModeItem
.4
	cmp.w	#1,d0
	bne.w	.5
	move.w	(gamelevel).w,d1
	or.w	(bosgames).w,d1
	bne.w	.5
	move.w	#2,d0
	btst	#2,(OptPad).w
	beq.w	.5
	move.w	#0,d0
.5
	cmp.w	#4,d0
	bne.w	.7
	btst	#1,(sflags13).w
	bne.w	.6
	tst.b	(SeasonTeam).w
	bpl.w	.7
.6
	move.w	#5,d0
	btst	#2,(OptPad).w
	beq.w	.7
	move.w	#3,d0
.7
	move.w	d0,(OptPlayMode).w
	movea.l	#PlayModeText,a1
	jsr	(SkipStrings).l
	rts

NotApplicableText					;Options menu: an option the play mode does not use
	String	CC_SetAttribute,$03,'not applicable    ',CC_SetAttribute,$07

RostersText							;Options menu: rosters
	String	'with trades       '
	String	'Regular           '

PerLenText							;Options menu: period length
	String	'5 minutes         '
	String	'10 minutes        '
	String	'20 minutes        '

GoalieText							;Options menu: goalies
	String	'Manual Control    '
	String	'Auto control      '

UserRecText							;Options menu: user records
	String	'off               '
	String	'on                '

PenaltyText							;Options menu: penalties
	String	'off               '
	String	'on, no offsides   '
	String	'on                '

LineText							;Options menu: line changes
	String	'off               '
	String	'auto              '
	String	'on                '

FightingText						;Options menu: fighting
	String	'on                '
	String	'off               '

SkillText							;Options menu: skill level
	String	'pro               '
	String	'all-star          '
	String	'rookie            '

PlayModeText						;Options menu: play mode
	String	'regular game      '
	String	'continue playoffs '
	String	'new playoffs      '
	String	'new poffs best/7  '
	String	'continue season   '
	String	'new season        '
	String	'shootout          '
	String	'transactions      '

ReadOptions							;Read the $18 option bytes from save RAM $1EC6 to OptPlayMode
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#OptPlayMode,a0
	move.l	#$1EC6,d0
	moveq	#$18,d1
	jsr	(ReadSRAM).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

WriteOptions						;Write the option bytes to save RAM $1EC6 and update the checksum
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#OptPlayMode,a0
	move.l	#$1EC6,d0
	moveq	#$18,d1
	jsr	(WriteSRAM).l
	jsr	(MakeSRAMChecksum).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

SetPlayMode							;Set the game flags for the chosen play mode: season (continue or new),
									;shootout, or else a game or the
									;playoffs
	movem.l	d0-d7/a0-a6,-(sp)
	bclr	#7,(GameFlags).w
	bclr	#6,(sflags10).w
	cmpi.w	#7,(OptPlayMode).w
	beq.w	.0
	cmpi.w	#4,(OptPlayMode).w
	beq.w	.0
	cmpi.w	#1,(OptPlayMode).w
	beq.w	.0
	cmpi.w	#2,(OptPlayMode).w
	beq.w	.0
	cmpi.w	#3,(OptPlayMode).w
	beq.w	.0
	cmpi.w	#5,(OptPlayMode).w
	bne.w	.1
.0
	clr.w	(OptRosters).w
.1
	bclr	#4,(sflags11).w
	tst.w	(OptRosters).w
	beq.w	.fix
	bset	#4,(sflags11).w
.fix
	bsr.w	FlipUserRec
	bsr.w	SetGoalieModes
	cmpi.w	#4,(OptPlayMode).w
	bne.w	.3
	clr.w	(OptPlayMode).w
	bset	#7,(GameFlags).w
	bra.w	.5
.3
	cmpi.w	#5,(OptPlayMode).w
	bne.w	.2
	clr.w	(OptPlayMode).w
	bset	#7,(GameFlags).w
	bset	#6,(sflags10).w
	bra.w	.5
.2
	cmpi.w	#6,(OptPlayMode).w
	bne.w	.4
	move.w	#0,(OptPlayMode).w
	move.w	#1,(OptUserRec).w
	move.w	#1,(OptLine).w
	clr.w	(OptPen).w
	bset	#0,(gmode2).w
	jsr	(ShootoutInit).l
	bra.w	.5
.4
	bsr.w	SetLineOption
	bsr.w	SetPenOption
	jsr	(SetSkillLevel).l
.5
	movem.l	(sp)+,d0-d7/a0-a6
	rts

SetGoalieModes						;goaliemode1 and goaliemode2 = OptGoalie, not for a season
	cmpi.w	#4,(OptPlayMode).w
	beq.w	.0
	cmpi.w	#5,(OptPlayMode).w
	beq.w	.0
	move.w	(OptGoalie).w,(goaliemode1).w
	move.w	(OptGoalie).w,(goaliemode2).w
.0
	rts

FlipUserRec							;OptUserRec: the menu order to the game value (0 = on)
	eori.w	#1,(OptUserRec).w
	rts

SetLineOption						;OptLine: the menu order to the game value (LineOptionTbl); sflags7 bit 4
									;for menu value 1
	movea.l	#LineOptionTbl,a0
	move.w	(OptLine).w,d0
	bclr	#4,(sflags7).w
	cmp.w	#1,d0
	bne.w	.0
	bset	#4,(sflags7).w
.0
	move.b	(a0,d0.w),d0
	move.w	d0,(OptLine).w
	rts

SetPenOption						;OptPen: the menu order to the game value (PenOptionTbl)
	movea.l	#PenOptionTbl,a0
	move.w	(OptPen).w,d0
	move.b	(a0,d0.w),d0
	move.w	d0,(OptPen).w
	rts

LineOptionTbl						;SetLineOption: the game value of each line changes row
	dc.b	1,0,0

PenOptionTbl						;SetPenOption: the game value of each penalties row
	dc.b	0,2,1

SetSkillLevel						;skillspeed / skillspeedpal (PAL) by skill level OptSkill
	movea.l	#SkillLevelTbl,a0
	movea.l	#SkillLevelPalTbl,a1
	move.w	(OptSkill).w,d0
	add.w	d0,d0
	move.w	(a0,d0.w),(skillspeed).w
	move.w	(a1,d0.w),(skillspeedpal).w
	rts

SkillLevelTbl						;SetSkillLevel: skillspeed of each skill level
	dc.w	$15,$15,$14

SkillLevelPalTbl					;SetSkillLevel: skillspeedpal of each skill level
	dc.w	$1D,$1D,$1C

OptionsAnimFrame					;OptionsScreen: draw frame optanimframe of the animation (PuckAnimMap, 7 x
									;7 tiles)
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(printz).l
	String	CC_Font1Pri,$1F,$01
	move.w	(puckanimchars).w,d4
	movea.l	#PuckAnimMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	move.w	(optanimframe).w,d1
	mulu.w	#7,d1
	moveq	#7,d2
	moveq	#7,d3
	moveq	#0,d5
	movea.l	#ZeroLong,a2
	jsr	(dobitmap).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

