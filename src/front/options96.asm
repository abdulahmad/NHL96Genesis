;	The game options screen. New in 96.

OptionsScreen	;The game options screen: play mode, rosters, period length, goalies, user records, penalties, line
	;changes, fighting and skill level (OptionsMenuList; left / right change OptionVars). Start saves them
	;(WriteOptions) and sets the play mode (SetPlayMode); transactions go to PlayoffMenuScreen. Left alone
	;(carddelay) it puts the options back to the defaults
	move.w	#$15,(skillspeed).w
	move.w	#$1D,(skillspeedpal).w
	move.w	(VDP_CNTR).l,(seed).w
	move.w	(VDP_CNTR).l,(seed+2).w
	clr.w	(optanimframe).w
	clr.w	(optanimdelay).w
	st	(demoflag).w
	jsr	(ReadPassData).l
	movea.l	#pwddatabuffer,a3
	jsr	(ReadPassBits).l
	move.w	(gamelevel).w,d0
	or.w	(bosgames).w,d0
	beq.w	.0
	jsr	(maketree).l
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
	tst.b	(dword_FFDD82+2).w
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
	bclr	#2,(disflags).w
.4
	bsr.w	OptionsMenuDraw
	move	#$2500,sr
.frame
	move.w	(vcount).w,d0
.loop2
	cmp.w	(vcount).w,d0
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
	move.b	d1,(byte_FFDCA6).w
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
	btst	#0,d1	;ubut
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
	clr.w	(OptPerlen).w
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
	jsr	(maketree).l
	rts

OptionVars	;OptionsScreen: the option of each menu row
	dc.l	OptPlayMode,OptRosters,OptPerlen,OptGoalie,OptUserRec
	dc.l	OptPen,OptLine,OptFighting,OptSkill

OptionsMenuDraw	;OptionsScreen: draw the menu (PrintMenuList2)
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(PrintMenuList2).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

OptionsScreenSetup	;OptionsScreen: vram, fonts, the screen bitmaps and the row labels
	bset	#5,(sflags12).w
	move.l	#VBlank_Menus,(vbint).w
	bclr	#0,(disflags).w
	bset	#2,(disflags).w
	bclr	#1,(disflags).w
	move.w	#0,(VSCRLPM).w
	move.w	#$B400,(VSPRITES).w
	move.w	#$B800,(VmMap3).w
	move.w	#5,(Map3col1).w
	move.w	#$C000,(VmMap2).w
	move.w	#6,(Map2col1).w
	move.w	#$E000,(VmMap1).w
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
	move.w	d4,(word_FFB8C4).w
	movea.l	#PuckAnimMap+8,a2
	jsr	(DecompressGraphicsPlain).l
	jsr	(printsmallz).l
	String	$FF,$01,$FD,$00,$FC
	moveq	#$28,d0
	moveq	#$1C,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	jsr	(printz).l
	String	$BF,$00,$00
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
	String	$BF,$0B,$01
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
	String	$FE,$00,$00
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

ClearGameRAM	;Clear the shootout words, both team structs, PenBuf and the game flags
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
	clr.w	(word_FFD300).w
	clr.w	(word_FFD310).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts

OptionsMenuInit	;OptionsScreen: menulist = OptionsMenuList, item 0
	move.l	#OptionsMenuList,(menulist).l
	clr.w	(menuitem).w
	clr.w	(menuitem+2).w
	move.w	#9,(menurows).w
	move.w	#$13,(menux).w
	move.w	#9,(menuy).w
	rts

OptionsMenuList	;The options menu: each item routine keeps its option in range and returns its text in a1
	String	$FE,$07,$F9
	String	$FE,$05,$F9
	dc.l	PlayModeItem,RostersItem,PerLenItem,GoalieItem,UserRecItem
	dc.l	PenaltyItem,LineItem,FightingItem,SkillItem,-1

SkillItem	;Options menu row: skill level
	;Code the listing does not decode: kept as bytes
	dc.b	$0C,$78,$00,$04,$D2,$54,$67,$00,$01,$B2,$0C,$78,$00,$05,$D2,$54
	dc.b	$67,$00,$01,$A8,$0C,$78,$00,$07,$D2,$54,$6C,$00,$01,$9E,$30,$38
	dc.b	$D2,$68,$B0,$7C,$00,$02,$6F,$00,$00,$04,$42,$40,$4A,$40,$6A,$00
	dc.b	$00,$06,$30,$3C,$00,$02,$31,$C0,$D2,$68,$22,$7C,$00,$1E,$18,$38
	dc.b	$4E,$B9,$00,$01,$D7,$F2,$4E,$75

FightingItem	;Options menu row: fighting
	;Code the listing does not decode: kept as bytes
	dc.b	$0C,$78,$00,$04,$D2,$54,$67,$00,$01,$6A,$0C,$78,$00,$05,$D2,$54
	dc.b	$67,$00,$01,$60,$0C,$78,$00,$06,$D2,$54,$6C,$00,$01,$56,$30,$38
	dc.b	$D2,$66,$B0,$7C,$00,$01,$6F,$00,$00,$04,$42,$40,$4A,$40,$6A,$00
	dc.b	$00,$06,$30,$3C,$00,$01,$31,$C0,$D2,$66,$22,$7C,$00,$1E,$18,$10
	dc.b	$4E,$B9,$00,$01,$D7,$F2,$4E,$75

LineItem	;Options menu row: line changes
	;Code the listing does not decode: kept as bytes
	dc.b	$0C,$78,$00,$04,$D2,$54,$67,$00,$01,$22,$0C,$78,$00,$05,$D2,$54
	dc.b	$67,$00,$01,$18,$0C,$78,$00,$06,$D2,$54,$6C,$00,$01,$0E,$30,$38
	dc.b	$D2,$64,$B0,$7C,$00,$02,$6F,$00,$00,$04,$42,$40,$4A,$40,$6A,$00
	dc.b	$00,$06,$30,$3C,$00,$02,$31,$C0,$D2,$64,$22,$7C,$00,$1E,$17,$D4
	dc.b	$4E,$B9,$00,$01,$D7,$F2,$4E,$75

PenaltyItem	;Options menu row: penalties
	;Code the listing does not decode: kept as bytes
	dc.b	$0C,$78,$00,$04,$D2,$54,$67,$00,$00,$DA,$0C,$78,$00,$05,$D2,$54
	dc.b	$67,$00,$00,$D0,$0C,$78,$00,$06,$D2,$54,$6C,$00,$00,$C6,$30,$38
	dc.b	$D2,$62,$B0,$7C,$00,$02,$6F,$00,$00,$04,$42,$40,$4A,$40,$6A,$00
	dc.b	$00,$06,$30,$3C,$00,$02,$31,$C0,$D2,$62,$22,$7C,$00,$1E,$17,$98
	dc.b	$4E,$B9,$00,$01,$D7,$F2,$4E,$75

UserRecItem	;Options menu row: user records
	;Code the listing does not decode: kept as bytes
	dc.b	$0C,$78,$00,$04,$D2,$54,$67,$00,$00,$92,$0C,$78,$00,$05,$D2,$54
	dc.b	$67,$00,$00,$88,$0C,$78,$00,$06,$D2,$54,$6C,$00,$00,$7E,$30,$38
	dc.b	$D2,$60,$B0,$7C,$00,$01,$6F,$00,$00,$04,$42,$40,$4A,$40,$6A,$00
	dc.b	$00,$06,$30,$3C,$00,$01,$31,$C0,$D2,$60,$22,$7C,$00,$1E,$17,$70
	dc.b	$4E,$B9,$00,$01,$D7,$F2,$4E,$75

GoalieItem	;Options menu row: goalies
	;Code the listing does not decode: kept as bytes
	dc.b	$0C,$78,$00,$04,$D2,$54,$67,$00,$00,$4A,$0C,$78,$00,$05,$D2,$54
	dc.b	$67,$00,$00,$40,$0C,$78,$00,$07,$D2,$54,$67,$00,$00,$36,$30,$38
	dc.b	$D2,$5E,$B0,$7C,$00,$01,$6F,$00,$00,$04,$42,$40,$4A,$40,$6A,$00
	dc.b	$00,$06,$30,$3C,$00,$01,$31,$C0,$D2,$5E,$22,$7C,$00,$1E,$17,$48
	dc.b	$4E,$B9,$00,$01,$D7,$F2,$4E,$75

PerLenItem	;Options menu row: period length
	;Code the listing does not decode: kept as bytes
	dc.b	$0C,$78,$00,$06,$D2,$54,$6D,$00,$00,$0A,$22,$7C,$00,$1E,$16,$CC
	dc.b	$4E,$75,$0C,$78,$00,$04,$D2,$54,$67,$F0,$0C,$78,$00,$05,$D2,$54
	dc.b	$67,$E8,$0C,$78,$00,$04,$D2,$54,$67,$E0,$30,$38,$D2,$5C,$B0,$7C
	dc.b	$00,$03,$6D,$00,$00,$04,$42,$40,$4A,$40,$6A,$00,$00,$06,$30,$3C
	dc.b	$00,$02,$31,$C0,$D2,$5C,$22,$7C,$00,$1E,$17,$0C,$4E,$B9,$00,$01
	dc.b	$D7,$F2,$4E,$75

RostersItem	;Options menu row: rosters
	;Code the listing does not decode: kept as bytes
	dc.b	$0C,$78,$00,$07,$D2,$54,$67,$AE,$0C,$78,$00,$05,$D2,$54,$67,$A6
	dc.b	$0C,$78,$00,$04,$D2,$54,$67,$9E,$0C,$78,$00,$01,$D2,$54,$67,$96
	dc.b	$0C,$78,$00,$02,$D2,$54,$67,$8E,$0C,$78,$00,$03,$D2,$54,$67,$86
	dc.b	$30,$38,$D2,$6A,$B0,$7C,$00,$01,$6F,$00,$00,$04,$42,$40,$4A,$40
	dc.b	$6A,$00,$00,$06,$30,$3C,$00,$01,$31,$C0,$D2,$6A,$22,$7C,$00,$1E
	dc.b	$16,$E4,$4E,$B9,$00,$01,$D7,$F2,$4E,$75

PlayModeItem	;Options menu row: play mode
	;Code the listing does not decode: kept as bytes
	dc.b	$30,$38,$D2,$54,$6A,$00,$00,$06,$30,$3C,$00,$07,$B0,$7C,$00,$07
	dc.b	$6F,$00,$00,$04,$42,$40,$B0,$7C,$00,$07,$66,$00,$00,$24,$08,$38
	dc.b	$00,$02,$DD,$80,$67,$00,$00,$1A,$08,$38,$00,$02,$DC,$A6,$67,$00
	dc.b	$00,$0A,$31,$FC,$00,$06,$D2,$54,$60,$C6,$42,$78,$D2,$54,$60,$C0
	dc.b	$B0,$7C,$00,$01,$66,$00,$00,$20,$32,$38,$CF,$CA,$82,$78,$CF,$C8
	dc.b	$66,$00,$00,$14,$30,$3C,$00,$02,$08,$38,$00,$02,$DC,$A6,$67,$00
	dc.b	$00,$06,$30,$3C,$00,$00,$B0,$7C,$00,$04,$66,$00,$00,$26,$08,$38
	dc.b	$00,$01,$C3,$58,$66,$00,$00,$0A,$4A,$38,$DD,$84,$6A,$00,$00,$14
	dc.b	$30,$3C,$00,$05,$08,$38,$00,$02,$DC,$A6,$67,$00,$00,$06,$30,$3C
	dc.b	$00,$03,$31,$C0,$D2,$54,$22,$7C,$00,$1E,$18,$74,$4E,$B9,$00,$01
	dc.b	$D7,$F2,$4E,$75

NotApplicableText	;Options menu: an option the play mode does not use
	String	$FE,$03,'not applicable    ',$FE,$07

RostersText	;Options menu: rosters
	String	'with trades       '
	String	'Regular           '

PerLenText	;Options menu: period length
	String	'5 minutes         '
	String	'10 minutes        '
	String	'20 minutes        '

GoalieText	;Options menu: goalies
	String	'Manual Control    '
	String	'Auto control      '

UserRecText	;Options menu: user records
	String	'off               '
	String	'on                '

PenaltyText	;Options menu: penalties
	String	'off               '
	String	'on, no offsides   '
	String	'on                '

LineText	;Options menu: line changes
	String	'off               '
	String	'auto              '
	String	'on                '

FightingText	;Options menu: fighting
	String	'on                '
	String	'off               '

SkillText	;Options menu: skill level
	String	'pro               '
	String	'all-star          '
	String	'rookie            '

PlayModeText	;Options menu: play mode
	String	'regular game      '
	String	'continue playoffs '
	String	'new playoffs      '
	String	'new poffs best/7  '
	String	'continue season   '
	String	'new season        '
	String	'shootout          '
	String	'transactions      '

ReadOptions	;Read the $18 option bytes from save RAM $1EC6 to OptPlayMode
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#OptPlayMode,a0
	move.l	#$1EC6,d0
	moveq	#$18,d1
	jsr	(ReadSRAM).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

WriteOptions	;Write the option bytes to save RAM $1EC6 and update the checksum
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#OptPlayMode,a0
	move.l	#$1EC6,d0
	moveq	#$18,d1
	jsr	(WriteSRAM).l
	jsr	(MakeSRAMChecksum).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

SetPlayMode	;Set the game flags for the chosen play mode: season (continue or new), shootout, or else a game or the
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

SetGoalieModes	;goaliemode1 and goaliemode2 = OptGoalie, not for a season
	cmpi.w	#4,(OptPlayMode).w
	beq.w	.0
	cmpi.w	#5,(OptPlayMode).w
	beq.w	.0
	move.w	(OptGoalie).w,(goaliemode1).w
	move.w	(OptGoalie).w,(goaliemode2).w
.0
	rts

FlipUserRec	;OptUserRec: the menu order to the game value (0 = on)
	eori.w	#1,(OptUserRec).w
	rts

SetLineOption	;OptLine: the menu order to the game value (LineOptionTbl); sflags7 bit 4 for menu value 1
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

SetPenOption	;OptPen: the menu order to the game value (PenOptionTbl)
	movea.l	#PenOptionTbl,a0
	move.w	(OptPen).w,d0
	move.b	(a0,d0.w),d0
	move.w	d0,(OptPen).w
	rts

LineOptionTbl	;SetLineOption: the game value of each line changes row
	dc.b	1,0,0

PenOptionTbl	;SetPenOption: the game value of each penalties row
	dc.b	0,2,1

SetSkillLevel	;skillspeed / skillspeedpal (PAL) by skill level OptSkill
	movea.l	#SkillLevelTbl,a0
	movea.l	#SkillLevelPalTbl,a1
	move.w	(OptSkill).w,d0
	add.w	d0,d0
	move.w	(a0,d0.w),(skillspeed).w
	move.w	(a1,d0.w),(skillspeedpal).w
	rts

SkillLevelTbl	;SetSkillLevel: skillspeed of each skill level
	dc.w	$15,$15,$14

SkillLevelPalTbl	;SetSkillLevel: skillspeedpal of each skill level
	dc.w	$1D,$1D,$1C

OptionsAnimFrame	;OptionsScreen: draw frame optanimframe of the animation (PuckAnimMap, 7 x 7 tiles)
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(printz).l
	String	$BF,$1F,$01
	move.w	(word_FFB8C4).w,d4
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
	movea.l	#$772,a2
	jsr	(dobitmap).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

