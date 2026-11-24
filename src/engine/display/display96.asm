;	The picture. VBlank runs the frame, setvideo builds the dma list, and the
;	crowd, the referee and the sprites are drawn here.

VBlank								;The game vertical blank handler (VBint): the dma list, sprites, scroll,
									;palette fade, pads.
	movem.l	d0-d7/a0-a6,-(sp)
	btst	#dfng,(disflags).w		;dfng: don't touch the vdp
	bne.w	.2
	bclr	#dfok,(disflags).w
	beq.w	.1
	bsr.w	DumpSprites
.1
	bsr.w	cramfade
.2
	btst	#sfpz,(sflags).w
	bne.w	.loop
	btst	#2,(gmode2).w
	bne.w	.3
	btst	#gmclock,(gmode).w		;gmclock: game clock stopped
	bne.w	.loop
.3
	btst	#1,(gmode2).w			;penalty shot / shootout clock
	bne.w	.7
	tst.w	(gameclock).w
	beq.w	.loop
	subi.w	#jiffy,(gameclock+2).w	;jiffy
	bcc.w	.loop
	bset	#dfclock,(disflags).w
	subq.w	#1,(gameclock).w
	addq.w	#1,(ChkCnt2).w
	tst.w	(gsp).w
	beq.w	.4
	cmpi.w	#$28,(ChkCnt2).w
	blt.w	.6
	bra.w	.5
.4
	cmpi.w	#$14,(ChkCnt2).w
	blt.w	.6
.5
	clr.w	(ChkCnt2).w
	tst.w	(ChkCnt).w
	beq.w	.6
	subq.w	#1,(ChkCnt).w
.6
	cmpi.w	#$3D,(gameclock).w		;61
	bgt.w	.loop
	cmpi.w	#$3C,(gameclock).w		;60
	blt.w	.loop
	move.w	#SFXbeep2,-(sp)			;SFXbeep2, played when gameclock reaches 60
	jsr	(sfx).l						;jsr (94: bsr.w)
.loop
	addq.w	#1,(Vcount).w
	jsr	(p_music_vblank).l
	movem.l	(sp)+,d0-d7/a0-a6
	rte
.7
	tst.w	(shootoutclock).w
	beq.s	.loop
	subi.w	#$AAA,(shootoutclock+2).w
	bcc.s	.loop
	bset	#dfclock,(disflags).w
	btst	#7,(gmode2).w
	bne.s	.loop
	subq.w	#1,(shootoutclock).w
	bra.s	.loop

vb2									;The vertical blank handler for fades only (forcefade, EASportsScreen).
	movem.l	d0-d7/a0-a6,-(sp)
	btst	#dfng,(disflags).w
	bne.w	.1
	bsr.w	cramfade
.1
	addq.w	#1,(Vcount).w
	jsr	(p_music_vblank).l
	movem.l	(sp)+,d0-d7/a0-a6

IRQ7								;Unused interrupts: return
	rte

DumpSprites							;Dma the sprite attribute table (Satt) to vram.
									;Scroll first, then the dma list
	bsr.w	SetScroll2
DumpSprites2						;Transfer the sprite table, then the dma list
	movea.w	#(Satt-M68K_RAM),a0
	move.w	(Sattsize).w,d0
	move.w	(VSPRITES).w,d1
	bsr.w	DoDMA

dodmalist							;Transfer data from the dma list
	movea.l	(DMAlistend).w,a6
	cmpa.l	#DMAList,a6
	beq.w	rtss2
.0
	move.w	-(a6),d1
	move.w	-(a6),d0
	movea.l	-(a6),a0
	bsr.w	DoDMA
	cmpa.l	#DMAList,a6
	bne.s	.0
	rts

DumpSpriteTable						;Dma the sprite attribute table and return
	movea.w	#(Satt-M68K_RAM),a0
	move.w	(Sattsize).w,d0
	move.w	(VSPRITES).w,d1
	bsr.w	DoDMA
	rts

SetScroll2							;Write Hscroll / Vscroll to the vdp
	move.w	(VSCRLPM).w,d0
	addq.w	#2,d0
	bsr.w	Vmaddr
	move.w	(Hscroll).w,(a0)
	move.l	#VSRAM_W+(2<<16),Vctrl-Vdata(a0)
	move.w	(Vscroll).w,(a0)
	rts

setvideo							;This is not vblank code but sets up ram for vblank transfers. Called once
									;per game frame (DoGameFrame,
									;Pausemode, ...).
	movem.l	d0-d7/a0-a6,-(sp)
.p
	btst	#dfok,(disflags).w		;dfok: wait for vblank to take the last frame
	bne.s	.p
	movea.w	#(DMAList-M68K_RAM),a5	;dma transfer list
	bsr.w	updatescroll
	movea.w	#(Satt-M68K_RAM),a6
	moveq	#1,d6
	bsr.w	checkfo
	bsr.w	checksso
	bsr.w	setsortcords
	bsr.w	setffo
	bsr.w	JumpToShowClock
	jsr	(AddArenaAnimSprite).l
	bsr.w	showcrowd
	jsr	(showref).l
	jsr	(UpdateCrowdMeter).l
	cmpa.w	#$C066,a6				;no sprites: one blank sprite
	bne.w	.n
	clr.l	(a6)+
	clr.l	(a6)+
.n
	clr.b	-5(a6)					;end sprite list
	move.l	a6,d0
	subi.l	#$FFFFC066,d0
	lsr.w	#1,d0					;words
	move.w	d0,(Sattsize).w
	move.l	a5,(DMAlistend).w
	bset	#dfok,(disflags).w		;dfok
	movem.l	(sp)+,d0-d7/a0-a6
	rts

updatescroll						;Scroll the rink window: Hscroll / Vscroll from Hpos / Vpos
	btst	#sfhor,(sflags).w
	bne.w	rtss2
	moveq	#-64,d0
	sub.w	(Hpos).w,d0
	move.w	(Vpos).w,d1
	move.w	d0,(Hscroll).w
	move.w	d1,(Vscroll).w
	neg.w	(Vscroll).w
	move.w	(Oldrow).w,d4
	asr.w	#3,d1
	move.w	d1,(Oldrow).w
	moveq	#$1F,d3					;max lines to update
	cmp.w	d4,d1
	beq.w	rtss2
	movea.l	#Rinktilelist,a0
	btst	#4,(sflags4).w
	beq.w	.0
	movea.l	#RevRinkTilelist,a0
	bra.w	.1
.0
	adda.l	4(a0),a0
.1
	blt.w	.2
.su
	move.w	d1,d0
	neg.w	d0
	addi.w	#$1E,d0
	andi.w	#$1F,d0
	asl.w	#7,d0
	add.w	(VmMAP2).w,d0
	move.w	d0,dmavram(a5)
	move.w	#$1E,d0
	sub.w	d1,d0
	move.w	(a0),dmalen(a5)
	mulu.w	(a0),d0
	add.w	d0,d0
	lea	4(a0,d0.w),a1
	move.l	a1,(a5)
	addq.w	#8,a5
	subq.w	#1,d1
	cmp.w	d4,d1
	dbeq	d3,.su
	rts
.2
	move.w	d1,d0
	neg.w	d0
	addi.w	#$1D,d0
	andi.w	#$1F,d0
	asl.w	#7,d0
	add.w	(VmMAP2).w,d0
	move.w	d0,dmavram(a5)
	move.w	#$3D,d0
	sub.w	d1,d0
	move.w	(a0),dmalen(a5)
	mulu.w	(a0),d0
	add.w	d0,d0
	lea	4(a0,d0.w),a1
	move.l	a1,(a5)
	addq.w	#8,a5
	addq.w	#1,d1
	cmp.w	d4,d1
	dbeq	d3,.2
	rts

showref								;Ref window: when sflags2 bit 1 is set add the 8 RefRamMap rows to the dma
									;list at a5 (VmMAP1)
	bclr	#sf2refref,(sflags2).w
	beq.w	rtss2
	movea.w	#(RefRamMap-M68K_RAM),a0
	movea.w	#(VmMAP1-M68K_RAM),a1
	move.w	Map1col-VmMAP1(a1),d2
	moveq	#2,d0					;refy: Xpos on ice screen
	asl.w	d2,d0
	moveq	#2,d1
	asl.w	d2,d1
	addq.w	#2,d0
	btst	#sfhor,(sflags).w
	beq.w	.1
	addi.w	#$B,d0
.1
	asl.w	#1,d0
	add.w	(a1),d0
	moveq	#7,d2
.2
	move.l	a0,(a5)+
	move.w	#7,(a5)+
	move.w	d0,(a5)+
	adda.w	#$E,a0
	add.w	d1,d0
	dbf	d2,.2
	rts

checkfo								;Check for faceoff sprites: the fofdata2 entries (frame, flags) as sprites
	btst	#sfpz,(sflags).w
	bne.w	rtss2
	btst	#dffaceoff,(disflags).w	;face off flag
	beq.w	rtss2
	movea.w	#(fofdata2-M68K_RAM),a3
	moveq	#2,d0
.loop
	move.w	(a3),d4
	bmi.w	.next
	beq.w	.next
	btst	#3,2(a3)
	beq.w	.2
	cmp.w	#3,d4
	bgt.w	.0
	addq.w	#3,d4
	bra.w	.2
.0
	subq.w	#3,d4
.2
	movea.l	#FaceOffSprites,a2
	adda.l	4(a2),a2
	subq.w	#1,d4
	add.w	d4,d4
	move.w	2(a2,d4.w),d5
	sub.w	(a2,d4.w),d5
	lsr.w	#3,d5
	subq.w	#1,d5
	adda.w	(a2,d4.w),a2
.1
	move.w	(a2),d2
	addi.w	#$70,d2
	add.w	(fodropy).w,d2
	move.w	d2,(a6)
	move.w	6(a2),d2
	btst	#3,2(a3)
	beq.w	.5
	move.b	2(a2),d2
	andi.w	#$C,d2
	addq.w	#4,d2
	asl.w	#1,d2
	neg.w	d2
	sub.w	6(a2),d2
.5
	addi.w	#$84,d2
	add.w	(fodropx).w,d2
	move.w	d2,6(a6)
	move.b	2(a2),2(a6)
	move.b	d6,3(a6)
	move.b	4(a2),d2
	asl.w	#8,d2
	andi.w	#$FF00,d2
	or.b	2(a2),d2
	andi.w	#$F800,d2
	movem.w	d0,-(sp)
	move.b	3(a2),d0
	asl.w	#8,d0
	andi.w	#$FF00,d0
	or.b	5(a2),d0
	or.w	d0,d2
	movem.w	(sp)+,d0
	move.w	2(a3),d1
	andi.w	#$F800,d1
	eor.w	d1,d2
	add.w	(faceoffvrcset).w,d2
	move.w	d2,4(a6)
	addq.w	#1,d6
	addq.w	#8,a6
	addq.w	#8,a2
	dbf	d5,.1
	addq.w	#4,a3
.next
	dbf	d0,.loop
	rts
	;After checkfo: code that nothing in the listing reaches.
	cmp.w	#$40,d6
	bge.w	rtss2
	movem.l	d0-d5/a0,-(sp)
	adda.l	4(a0),a0
	add.w	d2,d2
	move.w	2(a0,d2.w),d4
	sub.w	(a0,d2.w),d4
	lsr.w	#3,d4
	subq.w	#1,d4
	adda.w	(a0,d2.w),a0
.loop2
	move.w	2(a0),(a6)
	add.w	d1,(a6)+
	move.b	7(a0),(a6)+
	move.b	d6,(a6)+
	move.w	6(a0),d2
	andi.w	#$F800,d2
	add.w	4(a0),d2
	add.w	d3,d2
	move.w	d2,(a6)+
	move.w	(a0),(a6)
	add.w	d0,(a6)+
	addq.w	#1,d6
	cmp.w	#$40,d6
	beq.w	.ex
	addq.w	#8,a0
	dbf	d4,.loop2
.ex
	movem.l	(sp)+,d0-d5/a0
	rts

showcrowd							;Crowd sprites: the penalty box frames per PBnum nibble (ShowCrowdPb),
									;then the Crowdframe frame
	btst	#4,(sflags4).w			;check if reverse angle replay
	bne.w	rtsShowCrowd
	movea.l	#CrowdSprites,a1
	adda.l	4(a1),a1
	move.w	(Hpos).w,d4
	move.w	(Vpos).w,d5
	clr.w	d0
	move.b	(PBnum).w,d2
	move.w	#$1C,d3
	bsr.w	ShowCrowdPb
	move.b	(PBnum).w,d2
	lsr.w	#4,d2
	move.w	#$19,d3
	bsr.w	ShowCrowdPb
	move.b	(padiconchars1+1).w,d0
	bra.w	ShowCrowdFrame

ShowCrowdPb							;Crowd frames for the penalty box: d2 = the count (PBnum nibble, at most
									;3), d3 = the first frame
	andi.w	#$F,d2
	cmp.w	#3,d2
	bls.w	.0
	moveq	#3,d2
.0
	bra.w	.2
.1
	move.w	d3,d0
	add.w	d2,d0
	bsr.w	ShowCrowdFrame
.2
	dbf	d2,.1
	rts

ShowCrowdFrame						;Crowd frame d0 (0 = none): its sprites in view as sprite table entries at
									;a6 (at most $40)
	ext.w	d0
	beq.w	rtss2
	cmp.w	#$40,d6
	bge.w	rtss2
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

rtsShowCrowd						;Shared rts of showcrowd and ShowCrowdFrame
	rts

JumpToShowClock						;setvideo enters showclock here
	jmp	showclock
	;After JumpToShowClock: code that only its own branches reach.
	btst	#sfhor,(sflags).w		;sfhor
	beq.w	showclockVertical
	btst	#0,(gmode2).w			;shootout
	bne.w	.3
	move.l	a1,-(sp)
	jsr	(printz).l
	String	$BE,$D,5
	move.w	(gameclock).w,d0
	ext.l	d0
	divu.w	#$258,d0				;tens of minutes (600 seconds)
	move.l	d0,-(sp)
	tst.w	d0
	bne.w	.1
	addq.w	#1,(printx).w
	bra.w	.2
.1
	jsr	(showclockPrint).l
.2
	move.l	(sp)+,d0
	swap	d0
	ext.l	d0
	divu.w	#$3C,d0					;minutes
	move.l	d0,-(sp)
	jsr	(showclockPrint).l
	move.l	(sp)+,d0
	swap	d0
	ext.l	d0
	addq.w	#2,(printx).w
	divu.w	#$A,d0					;tens of seconds
	move.l	d0,-(sp)
	jsr	(showclockPrint).l
	move.l	(sp)+,d0
	swap	d0
	ext.l	d0
	jsr	(showclockPrint).l
	movea.l	(sp)+,a1
	jsr	(printz).l
	String	$BD,$D,5
.3
	rts

showclockPrint	equ	*			;Print the clock digit string
.digit								;A clock digit for the dead clock code above (.digits) Code the listing
	movea.l	#$207C0,a1
	asl.w	#2,d0
	adda.w	d0,a1
	jsr	(print).l
	rts

.digits								;.digit: the digit chars
	dc.w	$0004,$3000,$0004,$3100,$0004,$3200,$0004,SPAfpunchfinal
	dc.w	$0004,$3400,$0004,$3500,$0004,$3600,$0004,$3700
	dc.w	$0004,$3800,$0004,$3900
showclockVertical					;Draw the clock when the display flag is set
	bclr	#3,(disflags).w
	beq.w	rtss2
	btst	#3,(sflags2).w
	bne.w	rtss2
	cmpi.w	#4,(gsp).w
	beq.w	rtss2
	movea.w	#$BFC6,a0
	movea.l	#SmallFontMap,a1
	adda.l	4(a1),a1
	move.w	$78(a1),d0
	add.w	(smallfontchars).w,d0
	ori.w	#$8000,d0
	move.w	d0,(lty+8).w
	move.w	(gameclock).w,d0
	btst	#1,(gmode2).w
	beq.w	.next
	move.w	(shootoutclock).w,d0
.next
	ext.l	d0
	divu.w	#$A,d0
	bsr.w	ClockDigitChar
	divu.w	#6,d0
	bsr.w	ClockDigitChar
	subq.w	#2,a0
	divu.w	#$A,d0
	bsr.w	ClockDigitChar
	swap	d0
	tst.l	d0
	bne.w	.next2
	moveq	#-$10,d0
	swap	d0
.next2
	bsr.w	ClockDigitChar
	move.l	a0,(a5)+
	move.w	#5,(a5)+
	movea.w	#(VmMAP1-M68K_RAM),a1
	moveq	#$18,d0
	moveq	#3,d2
	btst	#7,(sflags).w
	beq.w	.next3
	movea.w	#(VmMAP2-M68K_RAM),a1
	moveq	#5,d0
	moveq	#$D,d2
.next3
	move.w	Map1col-VmMAP1(a1),d1
	asl.w	d1,d0
	add.w	d2,d0
	asl.w	#1,d0
	add.w	(a1),d0
	move.w	d0,(a5)+
	rts

ClockDigitChar						;Next digit of d0 (divu remainder) as a
									;small-font clock char word to -(a0)
	swap	d0
	asl.w	#1,d0
	move.w	$64(a1,d0.w),d0
	add.w	(smallfontchars).w,d0
	ori.w	#$8000,d0
	move.w	d0,-(a0)
	swap	d0
	ext.l	d0
	rts

checksso							;Do graphics for sso structure: arrows for the players when they are off
									;screen. Called from setvideo. a5 =
									;dma list, a6 = sprite table, d6 = link counter. Returns on the horizontal
									;rink. Pads 3 and 4 when cont3team / cont4team. Falls into .ca for the
									;last one
	btst	#4,(sflags9).w
	bne.w	rtss2
	movea.w	#(Joy1Struct-M68K_RAM),a0
	movea.w	#(sso-M68K_RAM),a3
	move.w	#$72E,d3				;SPFarrow, the first arrow frame
	bsr.w	.ca
	adda.w	#$1C,a0					;ffosize
	adda.w	#ssosize,a3				;ssosize
	move.w	#$731,d3
	bsr.w	.ca
	tst.w	(cont3team).w
	beq.w	rtss2
	movea.w	#(Joy3Struct-M68K_RAM),a0
	adda.w	#$14,a3
	move.w	#$734,d3
	bsr.w	.ca
	tst.w	(cont4team).w
	beq.w	rtss2
	movea.w	#(Joy4Struct-M68K_RAM),a0
	adda.w	#$14,a3
	move.w	#$737,d3
.ca
	tst.w	Zpos(a0)
	bmi.w	rtss2
	st	frame(a3)
	move.w	(a0),d0
	btst	#0,(gmode2).w
	bne.w	.0
	btst	#sf2replay,(sflags2).w
	bne.w	.0
	btst	#2,(BA_PS_flags).w
	beq.w	.7
.0
	move.w	d0,-(sp)
	tst.w	d0
	bpl.w	.2
	neg.w	d0
.2
	cmp.w	#$B4,d0
	blt.w	.6
	move.w	(sp)+,d0
	rts
.6
	move.w	(sp)+,d0
.7
	move.w	Ypos(a0),d1
	btst	#sfhor,(sflags).w
	beq.w	.10
	exg	d0,d1
	neg.w	d0
	subi.w	#$C5,d1
	bra.w	.11
.10
	sub.w	(Hpos).w,d0
	sub.w	(Vpos).w,d1
.11
	clr.w	d2
	cmp.w	#$74,d0					;xoff = 116
	blt.w	.8
	bset	#3,d2
.8
	cmp.w	#$FF8C,d0				;-.xoff
	bgt.w	.1
	bset	#2,d2
.1
	cmp.w	#$64,d1					;yoff = 100
	blt.w	.9
	bset	#0,d2
.9
	cmp.w	#$FF9C,d1				;-.yoff
	bgt.w	.3
	bset	#1,d2
.3
	tst.w	d2
	beq.w	rtss2
	movea.l	#jdtab,a1
	move.b	(a1,d2.w),d2
	asl.w	#3,d2
	movea.l	#.tab,a1
	move.w	(a1,d2.w),d4
	beq.w	.4
	move.w	d4,d0
.4
	addi.w	#$100,d0				;128+128
	move.w	d0,(a3)
	move.w	2(a1,d2.w),d4
	beq.w	.5
	move.w	d4,d1
.5
	neg.w	d1
	addi.w	#$F0,d1					;112+128
	move.w	d1,2(a3)
	add.w	attribute(a1,d2.w),d3
	move.w	d3,frame(a3)
	move.w	frame(a1,d2.w),attribute(a3)
	bra.w	addframe2

.tab								;x spot, y spot, frame add, attribute per direction
	dc.b	$00,$00,$00,$64,$00,$00,$00,$00,$00,$74,$00,$64,$00,$01,$00,$00
	dc.b	$00,$74,$00,$00,$00,$02,$00,$00,$00,$74,$FF,$9C,$00,$01,$10,$00
	dc.b	$00,$00,$FF,$9C,$00,$00,$10,$00,$FF,$8C,$FF,$9C,$00,$01,$18,$00
	dc.b	$FF,$8C,$00,$00,$00,$02,$08,$00,$FF,$8C,$00,$64,$00,$01,$08,$00

setsortcords						;Setup sort cord graphics: addframe for the 16 objects in OOlist order. a5
									;= dmalist, a6 = sprite attribute
									;table, d6 = link counter
	movea.w	#(OOlist-M68K_RAM),a4	;move OOlist into a4
	move.w	#$F,d0					;sortobj-1 (15 dec)
.top
	clr.w	d1
	move.b	(a4)+,d1				;move next sortcord into d1
	asl.w	#6,d1					;mult by 64
	movea.w	#(SortCords-M68K_RAM),a3	;Sort Cord struct start into a3
	adda.w	d1,a3					;add offset to next struct
	move.b	4(a3),-(sp)
	cmpi.w	#SPAboxwallleft,$58(a3)
	beq.w	.0
	cmpi.w	#SPAboardmidl,$58(a3)
	bne.w	.1
.0
	bclr	#3,4(a3)
.1
	bsr.w	addframe
	move.b	(sp)+,4(a3)
	dbf	d0,.top
	rts

setffo								;Called from setvideo
	bsr.w	SetGloveAndSetupPad
	move.w	#7,d0					;ffo obj -1
	movea.w	#(pads-M68K_RAM),a3		;move start of struct into a3
.top
	movea.w	a6,a0
	bsr.w	addframe
	cmpa.w	a6,a0
	beq.w	.next
	move.w	padxoff(a3),d1
	add.w	d1,6(a0)
	add.w	d1,$E(a0)
.next
	adda.w	#$1C,a3					;move to next struct
	dbf	d0,.top
	rts

SetGloveAndSetupPad					;The setup pad (glovecords+2 at $3E8: none) and the glove (glovecords),
									;then uppads
	movea.w	#(SetupPadStruct-M68K_RAM),a0
	st	$18(a0)
	cmpi.w	#$3E8,(glovecords+2).w
	beq.w	.0
	move.b	(glovecords+2).w,d0
	move.b	(glovecords+2+1).w,d1
	ext.w	d0
	asl.w	#2,d0
	move.w	d0,(a0)
	ext.w	d1
	asl.w	#2,d1
	move.w	d1,$14(a0)
	clr.w	$18(a0)
.0
	movea.w	#(glovestruct-M68K_RAM),a0
	st	$18(a0)
	cmpi.w	#$3E8,(glovecords).w
	beq.w	uppads
	move.b	(glovecords).w,d0
	move.b	(glovecords+1).w,d1
	ext.w	d0
	asl.w	#2,d0
	move.w	d0,(a0)
	ext.w	d1
	asl.w	#2,d1
	move.w	d1,$14(a0)
	clr.w	$18(a0)

uppads								;Update the 6 pad objects and queue new pad labels (QueuePadLabel). The
									;pad players come from the
									;PadControlBits nibbles ($E = no change, $F = none).
	move.w	#5,d4
	movea.w	#(pads-M68K_RAM),a0
	movea.w	#(padcont-M68K_RAM),a1
	movea.w	#(SortCords-M68K_RAM),a2
	move.l	(PadControlBits).w,d3
.nibble
	move.w	d3,d0
	andi.w	#$F,d0
	move.w	#$F,d1
	cmp.w	#$E,d0
	beq.w	.chg
	st	$18(a0)
	cmp.w	#$F,d0
	beq.w	.next
	asl.w	#7,d0
	move.w	(a2,d0.w),(a0)
	move.w	$14(a2,d0.w),$14(a0)
	clr.w	$18(a0)
	move.b	$35(a2,d0.w),d1			;position+1
	asl.w	#8,d1
	move.b	$70(a2,d0.w),d1			;rostnum
.chg
	cmp.w	(a1),d1
	beq.w	.next
	move.w	d1,(a1)
	bsr.w	QueuePadLabel
.next
	lsr.l	#4,d3
	adda.w	#$1C,a0
	addq.w	#2,a1
	dbf	d4,.nibble
	rts

QueuePadLabel						;Queue the 3 character label of a pad object. d1 = label code: bits 7-4
									;and 3-0 are digits ($F = blank), bits
									;10-8 index ButtonLabelCharTable (none while sflags7 bit 7 is set). a0 =
									;pad object, a5 = dma list. Falls into RenderSmallFontChar for the last
									;char
	lea	ButtonLabelCharTable(pc),a4
	clr.w	padxoff(a0)				;x offset (setffo adds it to the sprites)
	move.w	d1,d2
	lsr.w	#4,d2
	andi.w	#$F,d2
	bne.w	.hi
	move.w	#$FFF0,d2				;' '-'0': blank leading zero
	subq.w	#4,padxoff(a0)
.hi
	addi.w	#$30,d2
	clr.w	d0
	bsr.w	RenderSmallFontChar
	move.w	d1,d2
	andi.w	#$F,d2
	cmp.w	#$F,d2
	bne.w	.lo
	move.w	#$FFF0,d2				;$F: blank
.lo
	addi.w	#$30,d2
	moveq	#1,d0
	bsr.w	RenderSmallFontChar
	move.w	d1,d2
	btst	#7,(sflags7).w
	beq.w	.0
	clr.w	d2
.0
	lsr.w	#8,d2
	andi.w	#7,d2
	bne.w	.btn
	addq.w	#4,padxoff(a0)
.btn
	move.b	(a4,d2.w),d2
	moveq	#2,d0

RenderSmallFontChar					;Dma one small font tile to the object's chars. d2 = ascii char, d0 = char
									;slot, a0 = object
	movea.l	#SmallFontMap,a3
	adda.l	4(a3),a3
	add.w	d2,d2
	move.w	4(a3,d2.w),d2
	andi.w	#$7FF,d2
	asl.w	#5,d2					;32 bytes per tile
	movea.l	#SmallFontMap,a3
	lea	$A(a3,d2.w),a3
	move.l	a3,(a5)+
	move.w	#$10,(a5)+				;words to transfer
	add.w	$12(a0),d0
	asl.w	#5,d0
	move.w	d0,(a5)+
	rts

ButtonLabelCharTable				;Third label character by bits 10-8 of the label code
	dc.b	' DDLCRX',$FF

addframe							;a3 = sort cord object. Project it with find3d, then addframe2. a5 = dma
									;trans, a6 = sprite attribute table.
									;Called from setsortcords
	movem.l	d0-d2,-(sp)
	move.w	(a3),d0					;Xpos into d0
	move.w	Ypos(a3),d1				;Ypos into d1
	move.w	Zpos(a3),d2				;Zpos into d2
	bmi.w	.0						;exit if Zpos minus
	bsr.w	find3d					;get position on screen
	cmp.w	#osflag,d1				;#osflag into d1
	beq.w	.0						;exit if Sort Cord is off screen
	bsr.w	addframe2
.0
	movem.l	(sp)+,d0-d2
	rts

addframe2							;d0/d1 = x/y coord on screen, a3 = object, a5 = dma trans, a6 = sprite
									;attribute table, d6 = link counter.
									;Queue the sprite tiles of the frame and write its sprites
	move.w	attribute(a3),-(sp)
	movem.l	d0-d5/a0-a2,-(sp)
	move.w	frame(a3),d4
	bmi.w	.9
	beq.w	.9
	andi.w	#$F800,d4
	eor.w	d4,attribute(a3)
	move.w	frame(a3),d4
	andi.w	#$7FF,d4
	movea.l	#Sprites,a2
	adda.l	attribute(a2),a2
	asl.w	#1,d4
	cmp.w	(a2),d4
	bge.w	.9
	move.w	2(a2,d4.w),d5
	sub.w	(a2,d4.w),d5
	lsr.w	#3,d5
	subq.w	#1,d5
	clr.l	d3
	move.w	(a2,d4.w),d3
	adda.l	d3,a2
	clr.w	d3
	clr.w	d4
.0
	move.w	d0,-(sp)
	move.w	frame(a3),d0
	andi.w	#$7FF,d0
	cmp.w	8(a3),d0
	beq.w	.5
	tst.w	d5
	bne.w	.1
	move.w	d0,8(a3)
.1
	movem.w	d0-d4,-(sp)
	move.w	2(a2),d2
	andi.w	#$F000,d2
	lsr.w	#1,d2
	move.w	d2,-(sp)
	move.w	attribute(a2),d2
	andi.w	#$7FF,d2
	or.w	(sp)+,d2
	clr.w	d4
	move.b	2(a2),d4
	andi.w	#$F,d4
	movea.l	#sizetab,a0
	move.b	(a0,d4.w),d4
	btst	#0,(sflags12).w
	beq.w	.2
	cmp.w	#1,d4
	beq.w	.3
.2
	cmp.w	8(sp),d4
	bgt.w	.3
	cmp.w	4(sp),d2
	blt.w	.3
	move.w	4(sp),d0
	add.w	8(sp),d0
	sub.w	d2,d0
	sub.w	d4,d0
	bmi.w	.3
	movem.w	(sp)+,d0-d1
	addq.w	#6,sp
	bra.w	.4
.3
	add.w	8(sp),d3
	movem.w	(sp)+,d0-d1
	addq.w	#6,sp
	movem.w	d0-d4,-(sp)
	add.w	$12(a3),d3
	ext.l	d2
	asl.l	#5,d2
	movem.l	d0/a2,-(sp)
	movea.l	#Sprites,a2
	move.l	a2,d0
	addi.l	#$A,d0
	add.l	d0,d2
	movem.l	(sp)+,d0/a2
	asl.w	#4,d4
	asl.w	#5,d3
	move.l	d2,(a5)+
	move.w	d4,(a5)+
	move.w	d3,(a5)+
	movem.w	(sp)+,d0-d4
.4
	move.b	d3,$A(a3,d5.w)
.5
	move.w	(sp)+,d0
	movem.w	d0-d2,-(sp)
	move.w	(a2),d2
	btst	#4,attribute(a3)
	beq.w	.6
	move.b	2(a2),d2
	andi.w	#3,d2
	addq.w	#1,d2
	asl.w	#3,d2
	neg.w	d2
	sub.w	(a2),d2
.6
	add.w	d2,d1
	move.w	d1,(a6)
	move.w	frame(a2),d2
	btst	#3,attribute(a3)
	beq.w	.7
	move.b	2(a2),d2
	andi.w	#$C,d2
	addq.w	#4,d2
	asl.w	#1,d2
	neg.w	d2
	sub.w	frame(a2),d2
.7
	add.w	d2,d0
	move.w	d0,frame(a6)
	move.b	2(a2),2(a6)
	move.b	d6,3(a6)
	move.b	attribute(a2),d2
	andi.w	#$F8,d2
	lsl.w	#8,d2
	move.b	2(a2),d2
	move.w	attribute(a3),d0
	eor.w	d0,d2
	andi.w	#$F800,d2
	btst	#0,5(a3)
	beq.w	.8
	btst	#$E,d2
	beq.w	.8
	bset	#$D,d2
.8
	or.b	$A(a3,d5.w),d2
	add.w	$12(a3),d2
	move.w	d2,attribute(a6)
	movem.w	(sp)+,d0-d2
	addq.w	#1,d6
	addq.w	#8,a6
	addq.w	#8,a2
	dbf	d5,.0
.9
	movem.l	(sp)+,d0-d5/a0-a2
	move.w	(sp)+,attribute(a3)
	rts

find3d								;Input: d0 = xfield, d1 = yfield, d2 = height off field. Output: d0 =
									;xscreen, d1 = yscreen (the horizontal
									;rink with sflags bit 7)
	btst	#sfhor,(sflags).w
	beq.w	.0
	exg	d0,d1
	neg.w	d0
	subi.w	#$C5,d1
	bra.w	.1
.0
	sub.w	(Hpos).w,d0
	sub.w	(Vpos).w,d1
.1
	cmp.w	#$90,d0
	bgt.w	.offscr
	cmp.w	#$FF70,d0
	blt.w	.offscr
	addi.w	#$100,d0
	add.w	d2,d1
	asr.w	#1,d2
	add.w	d2,d1
	cmp.w	#$90,d1
	bgt.w	.offscr
	cmp.w	#$FF70,d1
	blt.w	.offscr
	neg.w	d1
	addi.w	#$F0,d1
	rts
.offscr
	move.w	#$4E20,d1
	rts

KillCrowd							;Silence the crowd noise (psg)
	move.b	#$E7,(Asound).l
	move.b	#$DF,(Asound).l
	move.b	#$C8,(Asound).l
	move.b	#1,(Asound).l
	move.b	#$FF,(Asound).l
	rts

setupice							;Set all variables, send non purgeable graphics, build sprite frame lists
									;for ice rink
	movem.l	d0-d7/a0-a6,-(sp)
	bset	#df32c,(disflags).w
	move.w	#$C000,(VmMAP2).w
	move.w	#6,(Map2col).w
	move.w	#$DC00,(VSPRITES).w
	move.w	#$E000,(VmMAP1).w
	move.w	#6,(Map1col).w
	move.w	#$F000,(VmMAP3).w
	move.w	#5,(Map3col).w
	move.w	#$FC00,(VSCRLPM).w
	moveq	#0,d0
	bsr.w	setVram
	bclr	#sfpz,(sflags).w
	move.w	(disflags).w,-(sp)
	bset	#dfng,(disflags).w
	clr.w	(Hpos).w
	clr.w	(Vpos).w
	move.w	#$7D0,(Oldrow).w
	st	(Zamx).w
	move.w	#$800,d0
	move.w	(VmMAP1).w,d1
	move.w	#$7FF,d2
	bsr.w	DoFill
	clr.w	d4
	move.w	d4,(rinkvrcset).w
	movea.l	#Rinktilelist+8,a2
	btst	#4,(sflags4).w
	beq.w	*+4
.1
	bsr.w	DecompressGraphicsPlain
	jsr	(LoadHomeTeamGfx).l
	jsr	(LoadReplayIcon).l
	move.w	d4,(EASNcset).w
	bsr.w	setupEASNmap
	move.w	d4,(energybarchars).w
	movea.l	#EnergyBarMap+8,a2
	bsr.w	DecompressGraphicsPlain
	move.w	d4,(animchars).w
	jsr	(LoadCrowdFrames).l
	move.w	d4,(spritechars).w
	bsr.w	defaultsprites
	bsr.w	setupIceRinkPal
	bsr.w	AddFramer
	move.w	d4,(gamefontchars).w
	jsr	(LoadSmallFont).l
	jsr	(LoadBigFonts).l
	move.w	d4,(ExtraChars).w
	btst	#gmdir,(gmode).w
	beq.w	.2
	movea.w	#(SortCords-M68K_RAM),a3
	moveq	#$B,d0
.0
	bchg	#7,$62(a3)
	adda.w	#$80,a3
	dbf	d0,.0
.2
	bsr.w	setplayercolors
	move.l	#$FFFFFFFF,(PadControlBits).w
	clr.l	(padcont).w
	clr.l	(padcont+4).w
	clr.l	(padcont+8).w
	st	(c1playernum).w
	st	(c2playernum).w
	st	(c3playernum).w
	st	(c4playernum).w
	bsr.w	DumpPadSprites
	move.w	(sp)+,(disflags).w
	move.l	#VBlank,(VBint).w
	bclr	#dfok,(disflags).w
	bclr	#dfng,(disflags).w
	move	#$2300,sr
	movem.l	(sp)+,d0-d7/a0-a6
	rts
	movem.l	d0-d7/a0-a6,-(sp)
	bsr.w	forceblack
	bclr	#sfpz,(sflags).w
	move.w	(disflags).w,-(sp)
	bset	#dfng,(disflags).w
	clr.w	(Hpos).w
	clr.w	(Vpos).w
	move.w	#$7D0,(Oldrow).w		;2000
	st	(Zamx).w
	move.w	(spritechars).w,d4		;sprite char start from setupice
	bsr.w	defaultsprites
	bsr.w	setupIceRinkPal			;transfer pal 0&1
	btst	#gmdir,(gmode).w
	beq.w	.gok
	movea.w	#(SortCords-M68K_RAM),a3
	moveq	#$B,d0					;12 players
.l01
	bchg	#pfgoal,$62(a3)			;gmdir set: swap pfgoal on all 12 players
	adda.w	#SCstruct,a3
	dbf	d0,.l01
.gok
	bsr.w	setplayercolors			;copy both teams' palettes
	move.l	#$FFFFFFFF,(PadControlBits).w
	clr.l	(padcont).w
	clr.l	(padcont+4).w
	clr.l	(padcont+8).w
	st	(c1playernum).w
	st	(c2playernum).w
	st	(c3playernum).w
	st	(c4playernum).w
	bsr.w	setupEASNmap
	bsr.w	DumpPadSprites
	move.w	#$1C,(palcount).w		;fade in new graphics now
	move.w	(sp)+,(disflags).w
	move.l	#VBlank,(VBint).w
	bclr	#dfok,(disflags).w
	bclr	#dfng,(disflags).w
	move.w	#$2300,sr
	movem.l	(sp)+,d0-d7/a0-a6
	rts								;(its only xref is a constant, so no label)

DumpPadSprites						;The six pad sprites (addframe2), then the dma list
	movea.w	#(DMAList-M68K_RAM),a5
	movea.w	#(Satt-M68K_RAM),a6
	moveq	#1,d6
	movea.w	#(pads-M68K_RAM),a3
	clr.w	d0
	clr.w	d1
	bset	#0,(sflags12).w
	bsr.w	addframe2
	adda.w	#$1C,a3
	bsr.w	addframe2
	adda.w	#$1C,a3
	bsr.w	addframe2
	adda.w	#$1C,a3
	bsr.w	addframe2
	adda.w	#$1C,a3
	bsr.w	addframe2
	adda.w	#$1C,a3
	bsr.w	addframe2
	bclr	#0,(sflags12).w
	move.l	a5,(DMAlistend).w
	bsr.w	dodmalist
	rts

setupIceRinkPal						;Copy the rink palettes (at the Rinktilelist header) to palfadenew
	movea.l	#Rinktilelist,a0
	adda.l	(a0),a0
	moveq	#$F,d0
	movea.w	#(palfadenew-M68K_RAM),a1
.0
	move.l	(a0)+,(a1)+
	dbf	d0,.0
	rts

setupEASNmap						;Load the EASN logo tiles (EASNmap+8) at EASNcset
	move.w	(EASNcset).w,d4
	movea.l	#EASNmap+8,a2
	jmp	DecompressGraphicsPlain
	dc.b	$4E,$75

LoadEnergyBarTiles					;Decompress EnergyBarMap at energybarchars
	move.w	(energybarchars).w,d4
	movea.l	#EnergyBarMap+8,a2
	bra.w	DecompressGraphicsPlain

LoadCrowdFrames						;Decompress CrowdSprites at animchars
	move.w	(animchars).w,d4
	movea.l	#CrowdSprites+8,a2
	bra.w	DecompressGraphicsPlain

LoadRefTilesHor						;Decompress RefMap2 at ExtraChars
	move.w	(ExtraChars).w,d4
	movea.l	#RefMap2+8,a2
	bra.w	DecompressGraphicsPlain

LoadRefTiles						;Decompress RefsMap at ExtraChars
	move.w	(ExtraChars).w,d4
	movea.l	#RefsMap+8,a2
	bra.w	DecompressGraphicsPlain

LoadFaceOffSprites					;Decompress FaceOffSprites at faceoffvrcset
	move.w	(faceoffvrcset).w,d4
	movea.l	#FaceOffSprites+8,a2
	bra.w	DecompressGraphicsPlain

LoadFaceOffMap						;Decompress FaceOffMap at ExtraChars
	move.w	(ExtraChars).w,d4
	movea.l	#FaceOffMap+8,a2
	bra.w	DecompressGraphicsPlain

defaultsprites						;The screen objects (sso) from .listsso, then the pads from .listffo
	movea.l	#.listsso,a2
	movea.w	#(sso-M68K_RAM),a3
	moveq	#ssonum-1,d0			;#ssonum-1 into d0
.ssotop
	move.w	#$FFFF,8(a3)			;screen objects not locked to scroll of screen
	move.w	(a2)+,(a3)
	move.w	(a2)+,2(a3)
	move.w	(a2)+,6(a3)
	move.w	(a2)+,4(a3)
	move.w	d4,$12(a3)
	add.w	(a2)+,d4
	adda.w	#ssosize,a3				;#ssosize
	dbf	d0,.ssotop
	movea.l	#.listffo,a2
	movea.l	#$FFFFBDCA,a3			;ffo
	moveq	#ffonum-1,d0			;#ffonum-1
.ffotop
	st	8(a3)						;objects tied to screen scrolling (not players/net/puck)
	move.w	(a2)+,(a3)
	move.w	(a2)+,$14(a3)
	move.w	(a2)+,$18(a3)
	move.w	(a2)+,6(a3)
	move.w	(a2)+,4(a3)
	move.w	d4,$12(a3)
	add.w	(a2)+,d4
	adda.w	#$1C,a3					;#ffosize
	dbf	d0,.ffotop
	bra.w	defaultsprites2

.listsso							;Xcord, ycord, frame, attribute, vram char size
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$09,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$09,$00,$00,$00,$00,$00,$00,$00,$00,$00,$09,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$09

.listffo							;Xcord, ycord, zpos, frame, attribute, vram char size
	dc.b	$00,$00,$00,$00,$FF,$FF,$07,$28,$00,$00,$00,$07,$00,$00,$00,$00
	dc.b	$FF,$FF,$07,$2A,$00,$00,$00,$07,$00,$00,$00,$00,$FF,$FF,$07,$2B
	dc.b	$00,$00,$00,$07,$00,$00,$00,$00,$FF,$FF,$07,$2C,$00,$00,$00,$07
	dc.b	$00,$00,$00,$00,$FF,$FF,$07,$2D,$00,$00,$00,$07,$00,$00,$00,$00
	dc.b	$FF,$FF,$07,$29,$80,$00,$00,$07,$00,$00,$00,$00,$FF,$FF,$06,$7B
	dc.b	$08,$00,$00,$05,$00,$00,$00,$00,$FF,$FF,$06,$7B,$00,$00,$00,$05

defaultsprites2						;Objects which are tied to screen scrolling and have velocity: the 16
									;SortCords objects from .list (players,
									;puck, puck shadow, goal nets ...), the OOlist and OOlistpos; then
									;SprSort.
	clr.w	d6
	movea.w	#(OOlist-M68K_RAM),a1
	lea	.list(pc),a2
	movea.w	#(SortCords-M68K_RAM),a3
	movea.w	#(OOlistpos-M68K_RAM),a4
.0
	moveq	#$1F,d0					;$1F
	movea.w	a3,a0
.1
	clr.l	(a0)+
	dbf	d0,.1
	move.w	d6,$52(a3)
	st	8(a3)
	st	$67(a3)
	move.w	(a2)+,(a3)
	move.w	(a2)+,$14(a3)
	move.w	(a2)+,$18(a3)
	move.w	(a2)+,6(a3)
	move.w	(a2)+,4(a3)
	move.w	d4,$12(a3)
	add.w	(a2)+,d4
	move.w	(a2)+,$4A(a3)
	move.w	(a2)+,$4C(a3)
	addq.w	#1,a2
	move.b	(a2)+,$38(a3)
	addq.w	#1,a2
	move.b	(a2)+,$62(a3)
	adda.w	#$80,a3
	asl.w	#1,d6
	move.b	d6,(a1)+
	lsr.w	#1,d6
	move.w	d6,(a4)+
	addq.w	#1,d6
	cmp.w	#$10,d6
	bne.s	.0
	bra.w	SprSort

.list								;Xcord, ycord, zcord, frame, attribute, char size, radii, asslist, pflags
	dc.b	$01,$80,$00,$C0,$00,$00,$00,$01,$00,$00,$00,$14,$00,$08,$00,$04
	dc.b	$00,$00,$00,$80,$FF,$38,$FF,$9C,$00,$00,$00,$01,$00,$00,$00,$14
	dc.b	$00,$08,$00,$04,$00,$00,$00,$80,$FF,$38,$FF,$B0,$00,$00,$00,$01
	dc.b	$00,$00,$00,$14,$00,$08,$00,$04,$00,$00,$00,$80,$FF,$38,$FF,$C4
	dc.b	$00,$00,$00,$01,$00,$00,$00,$14,$00,$08,$00,$04,$00,$00,$00,$80
	dc.b	$FF,$38,$FF,$D8,$00,$00,$00,$01,$00,$00,$00,$14,$00,$08,$00,$04
	dc.b	$00,$00,$00,$80,$FF,$38,$FF,$EC,$00,$00,$00,$01,$00,$00,$00,$14
	dc.b	$00,$08,$00,$04,$00,$00,$00,$80,$00,$C0,$00,$C0,$00,$00,$00,$01
	dc.b	$00,$01,$00,$14,$00,$08,$00,$04,$00,$00,$00,$40,$FF,$38,$00,$28
	dc.b	$00,$00,$00,$01,$00,$01,$00,$14,$00,$08,$00,$04,$00,$00,$00,$40
	dc.b	$FF,$38,$00,$3C,$00,$00,$00,$01,$00,$01,$00,$14,$00,$08,$00,$04
	dc.b	$00,$00,$00,$40,$FF,$38,$00,$50,$00,$00,$00,$01,$00,$01,$00,$14
	dc.b	$00,$08,$00,$04,$00,$00,$00,$40,$FF,$38,$00,$64,$00,$00,$00,$01
	dc.b	$00,$01,$00,$14,$00,$08,$00,$04,$00,$00,$00,$40,$FF,$38,$00,$78
	dc.b	$00,$00,$00,$01,$00,$01,$00,$14,$00,$08,$00,$04,$00,$00,$00,$40
	dc.b	$00,$00,$01,$22,$00,$00,$07,$1D,$00,$00,$00,$0D,$00,$14,$00,$06
	dc.b	$00,$00,$00,$00,$00,$00,$FE,$DE,$00,$00,$07,$1C,$00,$00,$00,$11
	dc.b	$00,$14,$00,$06,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$02,$9A
	dc.b	$00,$00,$00,$01,$00,$05,$00,$05,$00,$18,$00,$01,$00,$00,$00,$00
	dc.b	$00,$00,$02,$99,$00,$00,$00,$11,$00,$03,$00,$03,$00,$19,$00,$04

SprSort								;Sort objects in struct SortObj and set corresponding tables for keeping
									;them sorted later (Ylist, OOlist,
									;OOlistpos).
	movem.l	d0-d4/a0-a2,-(sp)
	movea.l	#$FFFFB87E,a2
	movea.l	#$FFFFB85E,a1
	movea.l	#SortCords,a0
	move.w	#$F,d3					;Sortobjs -1
.loop0
	move.w	$14(a0),d4
	btst	#sfhor,(sflags).w
	beq.w	.2
	move.w	(a0),d4
.2
	move.w	d4,(a1)+
	adda.w	#$80,a0
	dbf	d3,.loop0
	movea.l	#$FFFFB85E,a1
.loop
	clr.w	d4
	movea.l	#$FFFFB89E,a0
	move.w	#$E,d3
	clr.w	d0
	clr.w	d1
.0
	move.b	(a0)+,d0
	move.b	(a0),d1
	move.w	(a1,d0.w),d2
	cmp.w	(a1,d1.w),d2
	ble.w	.1
	move.b	d0,(a0)
	move.b	d1,-1(a0)
	move.l	a0,d2
	subi.l	#$FFFFB89E,d2
	move.w	d2,(a2,d0.w)
	subq.w	#1,d2
	move.w	d2,(a2,d1.w)
	st	d4
.1
	dbf	d3,.0
	tst.w	d4
	bne.s	.loop
	movem.l	(sp)+,d0-d4/a0-a2
	rts

resetplstuff						;Reset the player variables of the sort objects.
	movem.l	d0-d2/a0-a3,-(sp)
	movea.w	#(tmstruct-M68K_RAM),a2
	bsr.w	ResetTeamPlayers
	movea.w	#(AwShots-M68K_RAM),a2
	bsr.w	ResetTeamPlayers
	movem.l	(sp)+,d0-d2/a0-a3
	rts
ResetTeamPlayers					;Clear the team offside bit and reset the six skaters of team a2 (SetSPA,
									;impact, pflags)
	bclr	#4,$30(a2)				;clear team offside bit
	moveq	#5,d2
	movea.w	$22(a2),a3				;tmsort
.loop
	clr.b	$63(a3)					;pflags2
	tst.w	$34(a3)					;check for goalie
	bmi.w	.1
	move.w	#SPAglide,d1
	bsr.w	SetSPA
	clr.w	$32(a3)					;impact
	clr.b	$5E(a3)					;nopuck
	andi.b	#$C2,$62(a3)			;2^pfteam + 2^pfgoal +2^pfna, pflags
.1
	adda.w	#SCstruct,a3			;SCstruct size
	dbf	d2,.loop
	rts

