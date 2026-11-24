;	Back to the game from a menu.

ReturnToGame						;Back to the game after a menu: restart the sound driver,
									;RestoreGameScreen, the window registers,
									;setvideo, team struct $30 bit 0 from bit 1 for both teams, then fade in
	jsr	(forceblack).l
	jsr	(stop_current_song).l		;stop the song
	move.w	#9,d0					;restart the sound driver as Begin does
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
	move	#$2700,sr
	jsr	(RestoreGameScreen).l
	movea.l	#Vdata,a0
	move.w	#$9100,4(a0)
	move.w	#$9200,4(a0)
	bclr	#sfpz,(sflags).w
	jsr	(setvideo).l
	movea.l	#tmstruct+$30,a0
	btst	#1,(a0)
	beq.w	.0
	bset	#0,(a0)
.0
	adda.l	#$39E,a0
	btst	#1,(a0)
	beq.w	.1
	bset	#0,(a0)
.1
	move.w	#$18,(palcount).w
	bclr	#5,(sflags11).w
	beq.w	.wait
	move.w	#$FFFF,(palcount).w
.wait
	tst.w	(palcount).w
	bpl.s	.wait
	move.w	(Vcount).w,(OldVcount).w
	rts

RestoreGameScreen					;Rebuild the game screen: the vdp maps, palettes, vram, framer, fonts,
									;energy bar and EASN tiles, the face off screen (disflags bit 4) or the
									;ref tiles, the home team graphics and the replay icon
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	#$FFFFFFFF,(padcont).w
	move.l	#$FFFFFFFF,(padcont+4).w
	move.l	#$FFFFFFFF,(padcont+8).w
	clr.w	(printfontset).w
	move.l	#VBlank,(VBint).w
	bset	#df32c,(disflags).w
	move.w	#$C000,(VmMAP2).w
	move.w	#6,(Map2col).w
	move.w	#$DC00,(VSPRITES).w
	move.w	#$E000,(VmMAP1).w
	move.w	#6,(Map1col).w
	move.w	#$F000,(VmMAP3).w
	move.w	#5,(Map3col).w
	move.w	#$FC00,(VSCRLPM).w
	movea.w	#(palfadenew-M68K_RAM),a0
	moveq	#$1F,d1
.clrpal
	clr.l	(a0)+
	dbf	d1,.clrpal
	jsr	(setplayercolors).l
	jsr	(setupIceRinkPal).l
	jsr	(setVram_0).l
	jsr	(ClearOldFrames).l
	move.w	#$800,d0
	move.w	(VmMAP1).w,d1
	move.w	#$7FF,d2
	jsr	(DoFill).l
	move.w	(framercset).w,d4
	jsr	(AddFramer).l
	move.w	(gamefontchars).w,d4
	jsr	(LoadSmallFont).l
	jsr	(LoadBigFonts).l
	move.w	(energybarchars).w,d4
	movea.l	#EnergyBarMap+8,a2
	jsr	(DecompressGraphicsPlain).l
	move.w	(animchars).w,d4
	movea.l	#CrowdSprites+8,a2
	jsr	(DecompressGraphicsPlain).l
	jsr	(setupEASNmap).l
	jsr	(DumpPadSprites).l
	btst	#4,(disflags).w
	beq.w	.ref
	btst	#sf2replay,(sflags2).w
	bne.w	.ref
	move.w	(ExtraChars).w,d4
	movea.l	#FaceOffMap+8,a2
	jsr	(DecompressGraphicsPlain).l
	move.w	d4,(faceoffvrcset).w
	movea.l	#FaceOffSprites+8,a2
	jsr	(DecompressGraphicsPlain).l
	jsr	(DrawFaceoffWindow).l
	bra.w	.rink
.ref
	move.w	(ExtraChars).w,d4
	btst	#sf2replay,(sflags2).w
	beq.w	.2
	movea.l	#ReplayBannerMap+8,a2
	bra.w	.load
.2
	movea.l	#RefsMap+8,a2
	btst	#4,(sflags9).w
	beq.w	.load
	movea.l	#RefMap2+8,a2
.load
	jsr	(DecompressGraphicsPlain).l
.rink
	move.w	(disflags).w,-(sp)
	bset	#dfng,(disflags).w
	move.w	#$7D0,(Oldrow).w
	clr.w	d4
	move.w	d4,(rinkvrcset).w
	movea.l	#Rinktilelist+8,a2
	jsr	(DecompressGraphicsPlain).l
	jsr	(LoadHomeTeamGfx).l
	btst	#sf2replay,(sflags2).w
	beq.w	.0
	jsr	(LoadReplayIcon).l
.0
	jsr	(setplayercolors).l
	jsr	(setupIceRinkPal).l
	move.w	(sp)+,(disflags).w
	bclr	#dfok,(disflags).w
	bclr	#dfng,(disflags).w
	move	#$2300,sr
	jsr	(SprSort).l
	move.w	(Vcount).w,d0
.wait
	cmp.w	(Vcount).w,d0
	beq.s	.wait
	bset	#dfclock,(disflags).w
	jsr	(printscores1).l
	bset	#7,(sflags11).w
	btst	#sf2replay,(sflags2).w
	bne.w	.6
	move.w	#$64,(palcount).w
.6
	movem.l	(sp)+,d0-d7/a0-a6
	rts

ClearOldFrames						;Oldframe = -1 for the 16 sort objects, the 4 sso and the 8 pads, so
									;addframe2 sends their tiles again
	movem.l	d0-d1/a0-a3,-(sp)
	movea.l	#SortCords,a0
	move.w	#$80,d0
	move.w	#$F,d1
.sort
	st	8(a0)
	adda.w	d0,a0
	dbf	d1,.sort
	movea.l	#$FFFFBEBA,a0
	move.w	#$14,d0
	move.w	#3,d1
.sso
	st	8(a0)
	adda.w	d0,a0
	dbf	d1,.sso
	movea.l	#$FFFFBDCA,a0
	move.w	#$1C,d0
	move.w	#7,d1
.pads
	st	8(a0)
	adda.w	d0,a0
	dbf	d1,.pads
	movem.l	(sp)+,d0-d1/a0-a3
	rts

PauseScreenDraw						;Draw the pause screen: its own VBint, the background, period name, clock,
									;team names, scores, shots and penalties
	move.l	a2,-(sp)
	jsr	(stop_current_song).l
	move.w	#$2700,sr
	move.l	#VBlank_SpriteFade,(VBint).l
	bclr	#dfok,(disflags).w
	bset	#dfng,(disflags).w
	bclr	#df32c,(disflags).w
	move.w	#0,(VSCRLPM).w
	move.w	#$B800,(VSPRITES).w
	move.w	#$B800,(VmMAP3).w
	move.w	#5,(Map3col).w
	move.w	#$C000,(VmMAP2).w
	move.w	#6,(Map2col).w
	move.w	#$E000,(VmMAP1).w
	move.w	#6,(Map1col).w
	move.w	#0,d0
	bset	#5,(disflags).w
	jsr	(setVram).l
	bclr	#5,(disflags).w
	move.w	(VSCRLPM).w,d0
	jsr	(Vmaddr).l
	move.w	#0,(a0)
	move.w	#0,d0
	move.w	d0,(a0)
	jsr	(orjoy).l
	move.w	#1,d4
	movea.l	#PauseSprites,a1
	jsr	(LoadScreenSprite).l
	move.w	d4,(smallfontchars).w
	movea.l	#RosterFont+8,a2
	jsr	(DecompressGraphicsPlain).l
	move.l	#RosterFont,(smallfontptr).w
	move.w	d4,(bigfont1chars).w
	movea.l	#BigFontMap+8,a2
	jsr	(DecompressGraphicsPlain).l
	bclr	#2,(sflags11).w
	move.w	d4,(BigFontchars).w
	movea.l	#BigFontMap3+8,a2
	jsr	(DecompressGraphicsPlain).l
	move.w	d4,(BigFontchars+2).w
	movea.l	#DigitFontMap+8,a2
	jsr	(DecompressGraphicsPlain).l
	jsr	(printsmallz).l
	String	$FF,1,$FD,0,$FC
	moveq	#$28,d0
	moveq	#$1C,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),0,0
	movea.l	#PauseBgBitmap,a0
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
	String	-(TXPRI+TXMAP1),4,4
	movea.l	#SmallLogoPtrs,a0
	move.w	(VisTeam).w,d0
	asl.w	#2,d0
	movea.l	(a0,d0.w),a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	moveq	#5,d2
	moveq	#5,d3
	moveq	#4,d5
	jsr	(dobitmap).l
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),$1F,4
	movea.l	#SmallLogoPtrs,a0
	move.w	(HomeTeam).w,d0
	asl.w	#2,d0
	movea.l	(a0,d0.w),a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	moveq	#5,d2
	moveq	#5,d3
	moveq	#4,d5
	jsr	(dobitmap).l
	jsr	(printz).l
	String	$FE,0,0
	movea.l	#PauseRinkMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	moveq	#$28,d2
	moveq	#$1C,d3
	moveq	#3,d5
	jsr	(dobitmap).l
	move.w	(gsp).w,d0
	movea.l	#FoxBannerMap,a0
	btst	#0,d0
	bne.w	.1
	movea.l	#HockeyNewsBannerMap,a0
.1
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),$C,$17
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	moveq	#$10,d2
	moveq	#3,d3
	moveq	#0,d5
	jsr	(dobitmap).l
	jsr	(printbigcurz).l
	String	$F8,4,1,$F,4,$F9,2
	move.w	(gsp).w,d0
	movea.l	#PeriodText,a1
	jsr	(SkipStrings).l
	jsr	(printbigcur).l
	jsr	(printbigcurz).l
	String	$F8,4,1,$11,2,$F9,1
	move.w	(gameclock).w,d0
	ext.l	d0
	divu.w	#$258,d0				;tens of minutes (600 seconds)
	move.l	d0,-(sp)
	tst.w	d0
	bne.w	.2
	addq.w	#1,(printx).w
	bra.w	.3
.2
	bsr.w	PrintDigit
.3
	move.l	(sp)+,d0
	swap	d0
	ext.l	d0
	divu.w	#$3C,d0					;minutes
	move.l	d0,-(sp)
	bsr.w	PrintDigit
	move.l	(sp)+,d0
	swap	d0
	ext.l	d0
	addq.w	#1,(printx).w
	divu.w	#$A,d0					;tens of seconds
	move.l	d0,-(sp)
	bsr.w	PrintDigit
	move.l	(sp)+,d0
	swap	d0
	ext.l	d0
	bsr.w	PrintDigit
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),8,2
	movea.l	#$77E,a1
	move.w	(VisTeam).w,d0
	asl.w	#2,d0
	movea.l	(a1,d0.w),a1
	adda.w	4(a1),a1
	adda.w	(a1),a1
	adda.w	(a1),a1
	move.w	(a1),d0
	subq.w	#2,d0
	asr.w	#1,d0
	sub.w	d0,(printx).w
	move.w	(bigfont1chars).w,(printbigchars).w
	move.l	#BigFontMap,(bigfontptr).w
	jsr	(printbigcur).l
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),$1F,2
	movea.l	#$77E,a1
	move.w	(HomeTeam).w,d0
	asl.w	#2,d0
	movea.l	(a1,d0.w),a1
	adda.w	4(a1),a1
	adda.w	(a1),a1
	adda.w	(a1),a1
	move.w	(a1),d0
	subq.w	#2,d0
	asr.w	#1,d0
	sub.w	d0,(printx).w
	move.w	(bigfont1chars).w,(printbigchars).w
	move.l	#BigFontMap,(bigfontptr).w
	jsr	(printbigcur).l
	jsr	(printbigcurz).l
	String	$F8,4,1,5,9,$F9,3
	movea.l	#AwGoals,a1
	move.w	(a1),d0
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printbigcur).l
	jsr	(printbigcurz).l
	String	$F8,4,1,' ',9,$F9,3
	movea.l	#HmGoals,a1
	move.w	(a1),d0
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printbigcur).l
	movea.l	#AwShots,a1
	jsr	(printz).l
	String	$8F,5,$14
	move.w	(a1),d0
	move.w	#3,d1
	jsr	(PushNumberWidth).l
	jsr	(printcur).l
	movea.l	#tmstruct,a1
	jsr	(printz).l
	String	$8F,' ',$14
	move.w	(a1),d0
	move.w	#3,d1
	jsr	(PushNumberWidth).l
	jsr	(printcur).l
	jsr	(printz).l
	String	$8F,$1E,$E
	movea.w	#(tmstruct-M68K_RAM),a2
	bsr.w	PauseScreenDrawBench
	jsr	(printz).l
	String	$8F,3,$E
	movea.w	#(AwShots-M68K_RAM),a2
	bsr.w	PauseScreenDrawBench
	bsr.w	ClearMenuBox
	movea.l	#PauseSprites,a0
	jsr	(DrawScreenSprite).l
	bclr	#2,(disflags).w
	move.w	#$2500,sr
	move.w	#1,-(sp)
	jsr	(song).l
	movea.l	(sp)+,a2
	rts
PauseScreenDrawBench	equ	*	;Draw the bench players of the pause screen
	lea	$A4(a2),a0
.loop
	clr.w	d0
	move.b	(a0)+,d0
	bmi.w	.4
	btst	#6,$6C(a2,d0.w)
	bne.s	.loop
	bsr.w	PauseScreenDrawName
	bra.s	.loop
.4
	lea	$A4(a2),a0
.loop2
	clr.w	d0
	move.b	(a0)+,d0
	bmi.w	.5
	btst	#6,$6C(a2,d0.w)
	beq.s	.loop2
	bsr.w	PauseScreenDrawName
	bra.s	.loop2
PauseScreenDrawName	equ	*	;Draw one player name row of the pause screen
	cmpi.w	#$10,(printy).w
	bhi.w	.5						;no room for more rows
	move.w	$6C(a2,d0.w),d2
	andi.w	#$7FF,d2				;penalty time
	move.w	$28(a2),d7
	lsr.w	#1,d0
	jsr	(GetRosterName).l
	adda.w	(a1),a1
	addq.w	#8,a1
	clr.w	d0
	move.b	-$8(a1),d0				;player number (BCD)
	move.w	(printx).w,-(sp)
	movea.w	#(TextBuffer-M68K_RAM),a1	;mesarea+2
	jsr	(ConvertByteToDigits).l		;two digits to TextBuffer
	movea.w	#(mesarea-M68K_RAM),a1
	move.w	#4,(a1)					;string length: 2 digits
	jsr	(printcur).l				;print the number
	move.w	d2,d0
	jsr	(PushTime).l				;m:ss string
	jsr	(printcur).l				;print the time next to it
	move.w	(sp)+,(printx).w
	addq.w	#1,(printy).w			;next row
.5
	rts

PeriodText							;PauseScreenDraw: the period names
	String	'1st period'
	String	'2nd period'
	String	'3rd period'
	String	' overtime '
	String	'          '
	String	'          '
	String	'          '

DigitText							;The digits 0-9
	String	$30
	String	$31
	String	$32
	String	$33
	String	$34
	String	$35
	String	$36
	String	$37
	String	$38
	String	$39

PrintDigit							;Print digit d0 (DigitText)
	movea.l	#DigitText,a1
	jsr	(SkipStrings).l
	jmp	(printbigcur).l
