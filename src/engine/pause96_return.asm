;	Back to the game from a menu.

ReturnToGame	;Back to the game after a menu: restart the sound driver, RestoreGameScreen, the window registers,
	;setvideo, team struct $30 bit 0 from bit 1 for both teams, then fade in
	jsr	(forceblack).l
	jsr	(stop_current_song).l	;stop the song
	move.w	#9,d0	;restart the sound driver as Begin does
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
	movea.l	#VDP_DATA,a0
	move.w	#$9100,4(a0)
	move.w	#$9200,4(a0)
	bclr	#0,(sflags).w
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
	move.w	(vcount).w,(oldvcount).w
	rts

RestoreGameScreen	;Rebuild the game screen: the vdp maps, palettes, vram, framer, fonts, energy bar and EASN tiles,
	;the face off screen (disflags bit 4) or the ref tiles, the home team graphics and the replay icon
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	#$FFFFFFFF,(padcont).w
	move.l	#$FFFFFFFF,(padcont+4).w
	move.l	#$FFFFFFFF,(padcont+8).w
	clr.w	(printfontset).w
	move.l	#VBlank,(vbint).w
	bset	#1,(disflags).w
	move.w	#$C000,(VmMap2).w
	move.w	#6,(Map2col1).w
	move.w	#$DC00,(VSPRITES).w
	move.w	#$E000,(VmMap1).w
	move.w	#6,(Map1col1).w
	move.w	#$F000,(VmMap3).w
	move.w	#5,(Map3col1).w
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
	move.w	(VmMap1).w,d1
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
	movea.l	#CrowdFrameList+8,a2
	jsr	(DecompressGraphicsPlain).l
	jsr	(setupEASNmap).l
	jsr	(DumpPadSprites).l
	btst	#4,(disflags).w
	beq.w	.ref
	btst	#3,(sflags2).w
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
	btst	#3,(sflags2).w
	beq.w	.2
	movea.l	#ReplayBannerMap+8,a2
	bra.w	.load
.2
	movea.l	#RefTiles+8,a2
	btst	#4,(sflags9).w
	beq.w	.load
	movea.l	#RefTilesHor+8,a2
.load
	jsr	(DecompressGraphicsPlain).l
.rink
	move.w	(disflags).w,-(sp)
	bset	#2,(disflags).w
	move.w	#$7D0,(Oldrow).w
	clr.w	d4
	move.w	d4,(rinkvrcset).w
	movea.l	#Rinktilelist+8,a2
	jsr	(DecompressGraphicsPlain).l
	jsr	(LoadHomeTeamGfx).l
	btst	#3,(sflags2).w
	beq.w	.0
	jsr	(LoadReplayIcon).l
.0
	jsr	(setplayercolors).l
	jsr	(setupIceRinkPal).l
	move.w	(sp)+,(disflags).w
	bclr	#0,(disflags).w
	bclr	#2,(disflags).w
	move	#$2300,sr
	jsr	(SprSort).l
	move.w	(vcount).w,d0
.wait
	cmp.w	(vcount).w,d0
	beq.s	.wait
	bset	#3,(disflags).w
	jsr	(printscores1).l
	bset	#7,(sflags11).w
	btst	#3,(sflags2).w
	bne.w	.6
	move.w	#$64,(palcount).w
.6
	movem.l	(sp)+,d0-d7/a0-a6
	rts

ClearOldFrames	;Oldframe = -1 for the 16 sort objects, the 4 sso and the 8 pads, so addframe2 sends their tiles again
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

PauseScreenDraw	;Draw the pause screen: its own vbint, the background, period name, clock, team names, scores, shots and
	;penalties
	;Code the listing does not decode: kept as bytes
	dc.b	$2F,$0A,$4E,$B9,$00,$08,$85,$FC,$46,$FC,$27,$00,$23,$FC,$00,$1E
	dc.b	$2E,$76,$FF,$FF,$D2,$44,$08,$B8,$00,$00,$BF,$B2,$08,$F8,$00,$02
	dc.b	$BF,$B2,$08,$B8,$00,$01,$BF,$B2,$31,$FC,$00,$00,$B0,$00,$31,$FC
	dc.b	$B8,$00,$B0,$02,$31,$FC,$B8,$00,$B0,$0C,$31,$FC,$00,$05,$B0,$0E
	dc.b	$31,$FC,$C0,$00,$B0,$08,$31,$FC,$00,$06,$B0,$0A,$31,$FC,$E0,$00
	dc.b	$B0,$04,$31,$FC,$00,$06,$B0,$06,$30,$3C,$00,$00,$08,$F8,$00,$05
	dc.b	$BF,$B2,$4E,$B9,$00,$01,$B5,$7E,$08,$B8,$00,$05,$BF,$B2,$30,$38
	dc.b	$B0,$00,$4E,$B9,$00,$01,$B6,$78,$30,$BC,$00,$00,$30,$3C,$00,$00
	dc.b	$30,$80,$4E,$B9,$00,$01,$B2,$C4,$38,$3C,$00,$01,$22,$7C,$00,$1B
	dc.b	$CB,$FA,$4E,$B9,$00,$01,$21,$7A,$31,$C4,$B0,$1C,$24,$7C,$00,$17
	dc.b	$91,$70,$4E,$B9,$00,$01,$B7,$30,$21,$FC,$00,$17,$91,$68,$BF,$8A
	dc.b	$31,$C4,$B0,$16,$24,$7C,$00,$1B,$89,$D0,$4E,$B9,$00,$01,$B7,$30
	dc.b	$08,$B8,$00,$02,$C3,$54,$31,$C4,$B0,$18,$24,$7C,$00,$1B,$94,$1E
	dc.b	$4E,$B9,$00,$01,$B7,$30,$31,$C4,$B0,$1A,$24,$7C,$00,$1B,$9E,$E0
	dc.b	$4E,$B9,$00,$01,$B7,$30,$4E,$B9,$00,$01,$BA,$2E,$00,$08,$FF,$01
	dc.b	$FD,$00,$FC,$00,$70,$28,$72,$1C,$34,$3C,$07,$FF,$4E,$B9,$00,$01
	dc.b	$B9,$76,$4E,$B9,$00,$01,$BB,$8E,$00,$06,$BF,$00,$00,$00,$20,$7C
	dc.b	$00,$1B,$BB,$EC,$22,$48,$24,$48,$D1,$DA,$D3,$DA,$42,$40,$42,$41
	dc.b	$74,$28,$76,$1C,$7A,$08,$4E,$B9,$00,$01,$B6,$92,$4E,$B9,$00,$01
	dc.b	$BB,$8E,$00,$06,$BF,$04,$04,$00,$20,$7C,$00,$01,$2C,$DE,$30,$38
	dc.b	$C3,$A2,$E5,$40,$20,$70,$00,$00,$22,$48,$24,$48,$D1,$DA,$D3,$DA
	dc.b	$42,$40,$42,$41,$74,$05,$76,$05,$7A,$04,$4E,$B9,$00,$01,$B6,$92
	dc.b	$4E,$B9,$00,$01,$BB,$8E,$00,$06,$BF,$1F,$04,$00,$20,$7C,$00,$01
	dc.b	$2C,$DE,$30,$38,$C3,$A0,$E5,$40,$20,$70,$00,$00,$22,$48,$24,$48
	dc.b	$D1,$DA,$D3,$DA,$42,$40,$42,$41,$74,$05,$76,$05,$7A,$04,$4E,$B9
	dc.b	$00,$01,$B6,$92,$4E,$B9,$00,$01,$BB,$8E,$00,$06,$FE,$00,$00,$00
	dc.b	$20,$7C,$00,$1B,$A4,$BE,$22,$48,$24,$48,$D1,$DA,$D3,$DA,$42,$40
	dc.b	$42,$41,$74,$28,$76,$1C,$7A,$03,$4E,$B9,$00,$01,$B6,$92,$30,$38
	dc.b	$C4,$BC,$20,$7C,$00,$1B,$CF,$78,$08,$00,$00,$00,$66,$00,$00,$08
	dc.b	$20,$7C,$00,$1B,$D5,$E6,$4E,$B9,$00,$01,$BB,$8E,$00,$06,$BF,$0C
	dc.b	$17,$00,$22,$48,$24,$48,$D1,$DA,$D3,$DA,$42,$40,$42,$41,$74,$10
	dc.b	$76,$03,$7A,$00,$4E,$B9,$00,$01,$B6,$92,$4E,$B9,$00,$01,$BE,$C4
	dc.b	$00,$0A,$F8,$04,$01,$0F,$04,$F9,$02,$00,$30,$38,$C4,$BC,$22,$7C
	dc.b	$00,$1E,$2D,$E8,$4E,$B9,$00,$01,$D7,$F2,$4E,$B9,$00,$01,$BE,$E8
	dc.b	$4E,$B9,$00,$01,$BE,$C4,$00,$0A,$F8,$04,$01,$11,$02,$F9,$01,$00
	dc.b	$30,$38,$C4,$BE,$48,$C0,$80,$FC,$02,$58,$2F,$00,$4A,$40,$66,$00
	dc.b	$00,$0A,$52,$78,$B0,$40,$60,$00,$00,$06,$61,$00,$02,$A8,$20,$1F
	dc.b	$48,$40,$48,$C0,$80,$FC,$00,$3C,$2F,$00,$61,$00,$02,$98,$20,$1F
	dc.b	$48,$40,$48,$C0,$52,$78,$B0,$40,$80,$FC,$00,$0A,$2F,$00,$61,$00
	dc.b	$02,$84,$20,$1F,$48,$40,$48,$C0,$61,$00,$02,$7A,$4E,$B9,$00,$01
	dc.b	$BB,$8E,$00,$06,$BF,$08,$02,$00,$22,$7C,$00,$00,$07,$7E,$30,$38
	dc.b	$C3,$A2,$E5,$40,$22,$71,$00,$00,$D2,$E9,$00,$04,$D2,$D1,$D2,$D1
	dc.b	$30,$11,$55,$40,$E2,$40,$91,$78,$B0,$40,$31,$F8,$B0,$16,$B0,$14
	dc.b	$21,$FC,$00,$1B,$89,$C8,$B0,$10,$4E,$B9,$00,$01,$BE,$E8,$4E,$B9
	dc.b	$00,$01,$BB,$8E,$00,$06,$BF,$1F,$02,$00,$22,$7C,$00,$00,$07,$7E
	dc.b	$30,$38,$C3,$A0,$E5,$40,$22,$71,$00,$00,$D2,$E9,$00,$04,$D2,$D1
	dc.b	$D2,$D1,$30,$11,$55,$40,$E2,$40,$91,$78,$B0,$40,$31,$F8,$B0,$16
	dc.b	$B0,$14,$21,$FC,$00,$1B,$89,$C8,$B0,$10,$4E,$B9,$00,$01,$BE,$E8
	dc.b	$4E,$B9,$00,$01,$BE,$C4,$00,$0A,$F8,$04,$01,$05,$09,$F9,$03,$00
	dc.b	$22,$7C,$FF,$FF,$CA,$D0,$30,$11,$32,$3C,$00,$02,$4E,$B9,$00,$01
	dc.b	$BE,$1C,$4E,$B9,$00,$01,$BE,$E8,$4E,$B9,$00,$01,$BE,$C4,$00,$0A
	dc.b	$F8,$04,$01,$20,$09,$F9,$03,$00,$22,$7C,$FF,$FF,$C7,$32,$30,$11
	dc.b	$32,$3C,$00,$02,$4E,$B9,$00,$01,$BE,$1C,$4E,$B9,$00,$01,$BE,$E8
	dc.b	$22,$7C,$FF,$FF,$CA,$C4,$4E,$B9,$00,$01,$BB,$8E,$00,$06,$8F,$05
	dc.b	$14,$00,$30,$11,$32,$3C,$00,$03,$4E,$B9,$00,$01,$BE,$1C,$4E,$B9
	dc.b	$00,$01,$BC,$84,$22,$7C,$FF,$FF,$C7,$26,$4E,$B9,$00,$01,$BB,$8E
	dc.b	$00,$06,$8F,$20,$14,$00,$30,$11,$32,$3C,$00,$03,$4E,$B9,$00,$01
	dc.b	$BE,$1C,$4E,$B9,$00,$01,$BC,$84,$4E,$B9,$00,$01,$BB,$8E,$00,$06
	dc.b	$8F,$1E,$0E,$00,$34,$7C,$C7,$26,$61,$00,$00,$3E,$4E,$B9,$00,$01
	dc.b	$BB,$8E,$00,$06,$8F,$03,$0E,$00,$34,$7C,$CA,$C4,$61,$00,$00,$2A
	dc.b	$61,$00,$01,$78,$20,$7C,$00,$1B,$CB,$FA,$4E,$B9,$00,$01,$21,$8A
	dc.b	$08,$B8,$00,$02,$BF,$B2,$46,$FC,$25,$00,$3F,$3C,$00,$01,$4E,$B9
	dc.b	$00,$08,$85,$86,$24,$5F,$4E,$75,$41,$EA,$00,$A4,$42,$40,$10,$18
	dc.b	$6B,$00,$00,$10,$08,$32,$00,$06,$00,$6C,$66,$F0,$61,$00,$00,$1E
	dc.b	$60,$EA,$41,$EA,$00,$A4,$42,$40,$10,$18,$6B,$00,$00,$6A,$08,$32
	dc.b	$00,$06,$00,$6C,$67,$F0,$61,$00,$00,$04,$60,$EA,$0C,$78,$00,$10
	dc.b	$B0,$42,$62,$00,$00,$52,$34,$32,$00,$6C,$02,$42,$07,$FF,$3E,$2A
	dc.b	$00,$28,$E2,$48,$4E,$B9,$00,$01,$01,$E6,$D2,$D1,$50,$49,$42,$40
	dc.b	$10,$29,$FF,$F8,$3F,$38,$B0,$40,$32,$7C,$BF,$F4,$4E,$B9,$00,$02
	dc.b	$30,$C4,$32,$7C,$BF,$F2,$32,$BC,$00,$04,$4E,$B9,$00,$01,$BC,$84
	dc.b	$30,$02,$4E,$B9,$00,$01,$BD,$84,$4E,$B9,$00,$01,$BC,$84,$31,$DF
	dc.b	$B0,$40,$52,$78,$B0,$42,$4E,$75

PeriodText	;PauseScreenDraw: the period names
	String	'1st period'
	String	'2nd period'
	String	'3rd period'
	String	' overtime '
	String	'          '
	String	'          '
	String	'          '

DigitText	;The digits 0-9
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

PrintDigit	;Print digit d0 (DigitText)
	;Code the listing does not decode: kept as bytes
	dc.b	$22,$7C,$00,$1E,$2E,$3C,$4E,$B9,$00,$01,$D7,$F2,$4E,$F9,$00,$01
	dc.b	$BE,$E8
