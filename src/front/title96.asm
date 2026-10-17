;	The opening screens. New in 96.

TitleScreen	;Title screen: the picture TitleScreenImg and song 0, until start or the time runs out
	move	#$2700,sr
	move.w	(VDP_CNTR).l,(seed).w
	move.w	(VDP_CNTR).l,(seed+2).w
	bset	#5,(sflags12).w
	move.l	#VBlank_Menus,(vbint).w
	bclr	#0,(disflags).w
	bclr	#1,(disflags).w
	move.w	#5,(Map3col1).w
	move.w	#$A000,(VmMap2).w
	move.w	#7,(Map2col1).w
	move.w	#$C000,(VmMap1).w
	move.w	#7,(Map1col1).w
	move.w	#$F000,(VmMap3).w
	move.w	#$F800,(VSPRITES).w
	move.w	#$FC00,(VSCRLPM).w
	move.w	#0,d0
	jsr	(setVram).l
	jsr	(printz).l
	String	$FF,$00,$00
	moveq	#$28,d0
	moveq	#$1C,d1
	move.l	#$7FF,d2
	jsr	(eraser).l
	jsr	(printz).l
	String	$FE,$00,$00
	moveq	#$28,d0
	moveq	#$1C,d1
	move.l	#$7FF,d2
	jsr	(eraser).l
	move.w	#1,d4
	jsr	(printz).l
	String	$FE,$00,$00
	movea.l	#TitleScreenImg,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	move.w	(a1),d2
	move.w	2(a1),d3
	move.w	#$F,d5
	jsr	(dobitmap).l
	move	#$2500,sr
	bclr	#2,(disflags).w
	move.w	#0,-(sp)
	jsr	(song).l
	move.w	#$18,(palcount).w
	move.w	#$384,(carddelay).w
.0
	bsr.w	TitleWaitFrame
	subq.w	#1,(carddelay).w
	bmi.w	.1
	jsr	(FindHeldMenuPad).l
	btst	#7,d1
	beq.s	.0
.1
	rts

VBlank_LineScroll	;A vblank handler nothing sets: the line scroll table (SortCords), Vscroll, cramfade, vcount, the music
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$FF,$FE,$08,$38,$00,$02,$BF,$B2,$66,$00,$00,$2C,$30,$7C
	dc.b	$B0,$5E,$32,$38,$B0,$00,$30,$3C,$01,$C0,$4E,$B9,$00,$01,$B3,$EC
	dc.b	$20,$7C,$00,$C0,$00,$00,$21,$7C,$40,$00,$00,$10,$00,$04,$30,$B8
	dc.b	$BD,$36,$4E,$B9,$00,$01,$AF,$D6,$52,$78,$B0,$52,$4E,$B9,$00,$02
	dc.b	$44,$86,$4C,$DF,$7F,$FF,$4E,$73

TitleWaitFrame	;TitleScreen: wait for the next frame (vcount)
	move.w	(vcount).w,d0
.loop
	cmp.w	(vcount).w,d0
	beq.s	.loop
	rts

CreditsScreen	;The legal and credits pages (CreditsList) over three pictures; start skips after the first page
	move	#$2700,sr
	move.w	(VDP_CNTR).l,(seed).w
	move.w	(VDP_CNTR).l,(seed+2).w
	bset	#5,(sflags12).w
	move.l	#VBlank_Menus,(vbint).w
	bclr	#0,(disflags).w
	bclr	#1,(disflags).w
	move.w	#5,(Map3col1).w
	move.w	#$A000,(VmMap2).w
	move.w	#7,(Map2col1).w
	move.w	#$C000,(VmMap1).w
	move.w	#7,(Map1col1).w
	move.w	#$F000,(VmMap3).w
	move.w	#$F800,(VSPRITES).w
	move.w	#$FC00,(VSCRLPM).w
	move.w	#0,d0
	jsr	(setVram).l
	jsr	(printz).l
	String	$FF,$00,$00
	moveq	#$28,d0
	moveq	#$1C,d1
	move.l	#$7FF,d2
	jsr	(eraser).l
	jsr	(printz).l
	String	$FE,$00,$00
	moveq	#$28,d0
	moveq	#$1C,d1
	move.l	#$7FF,d2
	jsr	(eraser).l
	move.w	#1,d4
	move.w	d4,(smallfontchars).w
	movea.l	#RosterFont+8,a2
	jsr	(DecompressGraphicsPlain).l
	move.l	#RosterFont,(smallfontptr).w
	jsr	(printz).l
	String	$FE,$00,$00
	movea.l	#CreditsBgMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	move.w	(a1),d2
	move.w	2(a1),d3
	moveq	#$F,d5
	jsr	(dobitmap).l
	jsr	(printz).l
	String	$FF,$01,$0E
	movea.l	#NHLShieldMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	move.w	(a1),d2
	move.w	2(a1),d3
	moveq	#0,d5
	jsr	(dobitmap).l
	jsr	(printz).l
	String	$FF,$02,$00
	movea.l	#NHLPALogoMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	move.w	(a1),d2
	move.w	2(a1),d3
	moveq	#0,d5
	jsr	(dobitmap).l
	move	#$2500,sr
	bclr	#2,(disflags).w
	move.w	#$18,(palcount).w
	clr.w	(DispAttribCtr).w
	clr.w	(VertLineScrolling).w
	move.l	#$5732,(setupvalues).w
	bsr.w	PrintCreditsPage
.0
	bsr.w	CreditsWaitFrame
	jsr	(FindHeldMenuPad).l
	tst.w	(DispAttribCtr).w
	beq.w	.1
	btst	#7,d1
	bne.w	.5
.1
	addq.w	#1,(VertLineScrolling).w
	tst.w	(DispAttribCtr).w
	bne.w	.2
	cmpi.w	#$B4,(VertLineScrolling).w
	blt.w	.4
	bra.w	.3
.2
	cmpi.w	#$258,(VertLineScrolling).w
	blt.w	.4
.3
	clr.w	(VertLineScrolling).w
	addq.w	#1,(DispAttribCtr).w
	cmpi.w	#5,(DispAttribCtr).w
	beq.w	.5
	bsr.w	PrintCreditsPage
.4
	bra.s	.0
.5
	rts

PrintCreditsPage	;Print the CreditsList page at setupvalues, one String a row up to the empty String, then step setupvalues
	jsr	(printz).l
	String	$AF,$10,$01
	moveq	#$18,d0
	moveq	#$1B,d1
	move.l	#$7FF,d2
	jsr	(eraser).l
	movea.l	(setupvalues).w,a1
	jsr	(printsmallz).l
	String	$F8,$05,$01,$10,$01
.0
	cmpi.w	#2,(a1)
	beq.w	.1
	jsr	(printsmall).l
	jsr	(printsmallz).l
	String	$FD,$10,$FA,$01
	bra.s	.0
.1
	addq.l	#2,a1
	move.l	a1,(setupvalues).w
	rts

VBlank_LineScroll2	;A copy of VBlank_LineScroll; nothing sets it
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$FF,$FE,$08,$38,$00,$02,$BF,$B2,$66,$00,$00,$2C,$30,$7C
	dc.b	$B0,$5E,$32,$38,$B0,$00,$30,$3C,$01,$C0,$4E,$B9,$00,$01,$B3,$EC
	dc.b	$20,$7C,$00,$C0,$00,$00,$21,$7C,$40,$00,$00,$10,$00,$04,$30,$B8
	dc.b	$BD,$36,$4E,$B9,$00,$01,$AF,$D6,$52,$78,$B0,$52,$4E,$B9,$00,$02
	dc.b	$44,$86,$4C,$DF,$7F,$FF,$4E,$73

CreditsWaitFrame	;CreditsScreen: wait for the next frame (vcount)
	move.w	(vcount).w,d0
.loop
	cmp.w	(vcount).w,d0
	beq.s	.loop
	rts

CupCelebration	;The user's team won the Cup: the rink scene with the team's sprites and random crowd cheers until start
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(SoundOff).l	;stop the song
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
	bsr.w	CupCelebrationSetup
	move.w	#$B,-(sp)
	jsr	(sfx).l
	move.w	#1,(padiconchars1).w
	clr.w	(DispAttribCtr).w
	move.w	(vcount).w,d0
.loop2
	cmp.w	(vcount).w,d0
	beq.s	.loop2
	jsr	(FindHeldMenuPad).l
	btst	#7,d1
	bne.w	.3
.0
	btst	#0,(disflags).w
	bne.s	.0
	addq.w	#1,(DispAttribCtr).w
	cmpi.w	#$A,(DispAttribCtr).w
	blt.w	.1
	clr.w	(DispAttribCtr).w
	addq.w	#1,(padiconchars1).w
	cmpi.w	#$22,(padiconchars1).w
	blt.w	.1
	move.w	#$11,(padiconchars1).w
.1
	subq.w	#1,(VertLineScrolling).w
	bpl.w	.2
	move.w	#$A,d0
	jsr	(randomd0).l
	movea.l	#CupCheerDelays,a0
	add.w	d0,d0
	move.w	(a0,d0.w),(VertLineScrolling).w
	move.w	#$B,-(sp)
	jsr	(sfx).l
.2
	addq.w	#1,(padiconchars2).w
	movea.w	#(DMAList-M68K_RAM),a5
	jsr	(updatescroll).l
	jsr	(updatesound).l
	movea.w	#(Satt-M68K_RAM),a6	;sprite attribute table area
	moveq	#1,d6	;link counter
	jsr	(CupCelebrationSprites).l
	cmpa.w	#$C066,a6	;no sprites: one blank sprite
	bne.w	.n
	clr.l	(a6)+
	clr.l	(a6)+
.n
	clr.b	-5(a6)	;end sprite list
	move.l	a6,d0
	subi.l	#$FFFFC066,d0
	lsr.w	#1,d0	;words
	move.w	d0,(Sattsize).w
	move.l	a5,(DMAlistend).w
	bset	#0,(disflags).w	;dfok
	bra.w	.loop2
.3
	jsr	(forceblack).l
	jsr	(KillCrowd).l
	jsr	(SoundOff).l	;stop the song
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
	move.w	#0,d1
	jsr	(SoundCmd).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

CupCheerDelays	;CupCelebration: frames to the next crowd cheer, one picked at random
	dc.w	$E6,$E1,$EB,$D7,$DC,$F0,$FA,$D2,$F0,$F0

CupCelebrationSetup	;CupCelebration: vram, the team and rink palettes, the rink and sprite tiles, the picture
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	#$FFFFFFFF,(padcont).w
	move.l	#$FFFFFFFF,(padcont+4).w
	move.l	#$FFFFFFFF,(padcont+8).w
	jsr	(forceblack).l
	clr.w	(Vpos).w
	move.w	#$38,(Hpos).w
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
	clr.w	d1
	move.b	(dword_FFDD82+2).w,d1
	asl.w	#2,d1
	movea.l	#$77E,a2
	movea.l	(a2,d1.w),a2
	clr.w	d1
	adda.w	2(a2),a2	;Palettedata
	adda.w	d1,a2
	movea.w	#(palfadenew+$40-M68K_RAM),a1
	adda.w	d1,a1
	moveq	#7,d0
.loop
	move.l	(a2)+,(a1)+
	dbf	d0,.loop
	jsr	(setupIceRinkPal).l
	jsr	(setVram_0).l
	move.w	#$800,d0
	move.w	(VmMap1).w,d1
	move.w	#$7FF,d2
	jsr	(DoFill).l
	clr.w	d4
	move.w	d4,(rinkvrcset).w
	movea.l	#Rinktilelist+8,a2
	jsr	(DecompressGraphicsPlain).l
	move.w	d4,(animchars).w
	move.w	(animchars).w,d4
	movea.l	#unk_1CCEE8+8,a2
	jsr	(DecompressGraphicsPlain).l
	move.w	d4,(ExtraChars).w
	move.w	(ExtraChars).w,d4
	movea.l	#unk_1D5420+8,a2
	jsr	(DecompressGraphicsPlain).l
	move.w	(disflags).w,-(sp)
	bset	#2,(disflags).w
	move.w	#$7D0,(Oldrow).w
	move.w	(sp)+,(disflags).w
	bclr	#0,(disflags).w
	bclr	#2,(disflags).w
	move	#$2300,sr
	move.w	(vcount).w,d0
.loop2
	cmp.w	(vcount).w,d0
	beq.s	.loop2
	jsr	(printz).l
	String	$FF,$06,$0C
	move.w	(ExtraChars).w,d4
	movea.l	#unk_1D5420,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	moveq	#$16,d2
	moveq	#4,d3
	moveq	#8,d5
	bset	#0,(sflags6).w
	jsr	(dobitmap).l
	bclr	#0,(sflags6).w
	move.w	#$18,(palcount).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts

CupCelebrationSprites	;CupCelebration: the sprites of the current frame that are in view
	movea.l	#unk_1CCEE8,a1
	adda.l	4(a1),a1
	move.w	(Hpos).w,d4
	move.w	(Vpos).w,d5
	move.b	(padiconchars1+1).w,d0
	bra.w	*+4
.0
	ext.w	d0
	beq.w	.1
	cmp.w	#$40,d6
	bge.w	.1
	movem.l	d0-d5,-(sp)
	add.w	d0,d0
	movea.l	a1,a0
	move.w	2(a0,d0.w),d1
	sub.w	(a0,d0.w),d1
	lsr.w	#3,d1
	subq.w	#1,d1
	move.w	d1,-(sp)
	adda.w	(a0,d0.w),a0
	move.w	d4,d0
	addi.w	#$C0,d0
	move.w	d0,d1
	subi.w	#$90,d0
	addi.w	#$80,d1
	move.w	#$170,d2
	sub.w	d5,d2
	move.w	d2,d3
	subi.w	#$80,d2
	addi.w	#$70,d3
	move.w	(sp)+,d4
.loop2
	cmp.w	(a0),d2
	bgt.w	.next
	cmp.w	(a0),d3
	blt.w	.next
	cmp.w	6(a0),d0
	bgt.w	.next
	cmp.w	6(a0),d1
	blt.w	.next
	move.w	(a0),d5
	addi.w	#$70,d5
	sub.w	d2,d5
	move.w	d5,(a6)+
	move.b	2(a0),(a6)+
	andi.b	#$F,-1(a6)
	move.b	d6,(a6)+
	move.b	4(a0),d5
	andi.w	#$F8,d5
	lsl.w	#8,d5
	move.w	d5,-(sp)
	move.w	4(a0),d5
	andi.w	#$7FF,d5
	add.w	(animchars).w,d5
	or.w	(sp)+,d5
	move.w	d5,(a6)+
	move.w	6(a0),d5
	addi.w	#$70,d5
	sub.w	d0,d5
	move.w	d5,(a6)+
	addq.w	#1,d6
	cmp.w	#$40,d6
	beq.w	.x
.next
	addq.w	#8,a0
	dbf	d4,.loop2
.x
	movem.l	(sp)+,d0-d5
.1
	rts
	dc.b	$FF,$FF

