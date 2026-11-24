;	The screen and the printers. Palette fades, the pads, dma, the graphics
;	decompressor, and printsmall, print and printbig.

remap								;Write d0 chars at a0 to vram d1, each pixel through the colour map at a1.
									;Reached from DecompressGraphics
	move.w	(disflags).w,-(sp)
	bset	#dfng,(disflags).w
	movem.l	d0-d4/a0-a2,-(sp)
	exg	d1,d0
	movea.l	a0,a2
	bsr.w	Vmaddr
	subq.w	#1,d1
.1
	moveq	#3,d0
	move.w	(a2)+,d2
	clr.w	d3
.11
	move.w	d2,d4
	andi.w	#$F,d4
	lsr.w	#1,d4
	move.b	(a1,d4.w),d4
	btst	#0,d2
	bne.w	.lo
	lsr.w	#4,d4
.lo
	andi.w	#$F,d4
	or.b	d4,d3
	ror.w	#4,d3
	ror.w	#4,d2
	dbf	d0,.11
	move.w	d3,(a0)
	dbf	d1,.1
	movem.l	(sp)+,d0-d4/a0-a2
	move.w	(sp)+,(disflags).w
	rts

forceblack							;Fade the screen to black and wait for it
	movem.l	d0/a0,-(sp)
	movea.w	#(palfadenew-M68K_RAM),a0
	moveq	#$1F,d0
.0
	move.l	(a0),-(sp)
	clr.l	(a0)+
	dbf	d0,.0
	move.w	#$18,(palcount).w
	bsr.w	forcefade
	moveq	#$1F,d0
.1
	move.l	(sp)+,-(a0)
	dbf	d0,.1
	movem.l	(sp)+,d0/a0
	rts

forceblack2							;Forceblack with palcount $64 (one step,
									;CopyPaletteToCRAM). Nothing calls it.
	movem.l	d0/a0,-(sp)
	movea.w	#(palfadenew-M68K_RAM),a0
	moveq	#$1F,d0
.loop
	move.l	(a0),-(sp)
	clr.l	(a0)+
	dbf	d0,.loop
	move.w	#$64,(palcount).w
	bsr.w	forcefade
	moveq	#$1F,d0
.loop2
	move.l	(sp)+,-(a0)
	dbf	d0,.loop2
	movem.l	(sp)+,d0/a0
	rts

forcefade							;Run the palette fade to the end: VBint = vb2 (fades only), interrupts on,
									;wait for palcount to go negative
	move	sr,-(sp)
	move.l	(VBint).w,-(sp)
	move.w	(disflags).w,-(sp)
	bclr	#dfng,(disflags).w
	move.l	#vb2,(VBint).l
	move	#$2500,sr
.1
	tst.w	(palcount).w
	bpl.s	.1
	move.w	(sp)+,(disflags).w
	move.l	(sp)+,(VBint).w
	move	(sp)+,sr
	rts

cramfade							;Step the palette fade (palcount) and copy the palette to cram. Called
									;from the vblank handlers.
	tst.w	(palcount).w
	bmi.w	rtss2
	cmpi.w	#$64,(palcount).w
	beq.w	CopyPaletteToCRAM
	subq.w	#1,(palcount).w
	bmi.w	rtss2
	clr.l	d0
	move.w	(palcount).w,d0
	cmp.w	#$18,d0
	bgt.w	rtss2
	divu.w	#3,d0
	swap	d0
	asl.w	#2,d0
	moveq	#2,d3
	asl.w	d0,d3
	moveq	#$E,d5
	asl.w	d0,d5
	move.w	d5,d4
	not.w	d4
	movea.l	#palfadenew,a1
	movea.l	#Vdata,a0
	clr.w	d6
.loop
	move.w	d3,d2
	move.w	d6,d0
	swap	d0
	move.w	#$20,d0
	move.l	d0,4(a0)
	move.w	(a0),d7
	move.w	d7,d0
	and.w	d5,d0
	move.w	(a1)+,d1
	and.w	d5,d1
	cmp.w	d1,d0
	beq.w	.2
	blt.w	.1
	neg.w	d2
.1
	add.w	d2,d0
	and.w	d4,d7
	or.w	d0,d7
	move.l	#$C000,d0
	move.b	d6,d0
	swap	d0
	move.l	d0,4(a0)
	move.w	d7,(a0)
.2
	addq.w	#2,d6
	cmp.w	#$80,d6
	bne.s	.loop
	rts

CopyPaletteToCRAM					;Copy all 64 palfadenew colours to colour ram
									;(dfng set), then palcount = -1
	movem.l	d0/a0-a1,-(sp)
	move.w	(disflags).w,-(sp)
	bset	#dfng,(disflags).w
	movea.w	#(palfadenew-M68K_RAM),a1
	movea.l	#Vdata,a0
	move.l	#$C0000000,4(a0)		;cram write, address 0
	moveq	#$1F,d0
.0
	move.l	(a1)+,(a0)
	dbf	d0,.0
	st	(palcount).w
	move.w	(sp)+,(disflags).w
	movem.l	(sp)+,d0/a0-a1
	rts

randomd0s							;d0 = random number from -d0 to d0-1 (randomd0(d0*2) - d0)
	move.w	d0,-(sp)
	asl.w	#1,d0
	bsr.w	randomd0
	sub.w	(sp)+,d0
	rts

randomd0							;d0 = random number 0 to d0-1 (seed * $BB40E62D + 1)
	movem.l	d0-d2,-(sp)
	move.w	(seed+2).w,d0
	move.w	d0,d1
	move.w	(seed).w,d2
	mulu.w	#$E62D,d0
	mulu.w	#$BB40,d1
	mulu.w	#$E62D,d2
	add.w	d2,d1
	swap	d0
	add.w	d1,d0
	swap	d0
	addq.l	#1,d0
	move.l	d0,(seed).w
	asr.l	#8,d0
	mulu.w	2(sp),d0
	swap	d0
	addq.w	#4,sp
	movem.l	(sp)+,d1-d2
	rts

Sroot								;d0 = square root of d0 (long). Small values by odd subtraction, else
									;Newton steps, else a binary search
	tst.l	d0
	beq.w	rtss2
	cmp.l	#$640,d0				;#40^2
	bhi.w	.m2
	move.l	d1,-(sp)
	moveq	#-1,d1
.0
	addq.w	#2,d1
	sub.w	d1,d0
	bcc.s	.0
	lsr.w	#1,d1
	move.w	d1,d0
	move.l	(sp)+,d1
	rts
.m2
	movem.l	d1-d4,-(sp)
	moveq	#9,d3					;max number of reps
	move.w	#$8000,d1
	cmp.l	#$F00000,d0
	bhi.w	.big
	move.l	d0,d1
	lsr.l	#8,d1
	addq.w	#2,d1
.top
	move.w	d1,d2
	move.l	d0,d1
	divu.w	d2,d1
	add.w	d2,d1
	lsr.w	#1,d1
	cmp.w	d1,d2
	dbeq	d3,.top
.done
	move.w	d1,d0
	movem.l	(sp)+,d1-d4
	rts
.big
	moveq	#0,d1
	moveq	#-1,d2
.bs
	move.w	d1,d3
	add.w	d2,d3
	roxr.w	#1,d3
	cmp.w	d3,d1
	beq.s	.done
	move.w	d3,d4
	mulu.w	d3,d3
	cmp.l	d3,d0
	bcc.w	.lo
	move.w	d4,d2
	bra.s	.bs
.lo
	move.w	d4,d1
	bra.s	.bs

waitx								;Wait -d0 frames, or until a button on any pad
									;(waitxpad = the buttons held)
	clr.w	(waitxpad).w
	neg.w	d0
	move.w	d0,(Vcount).w
.0
	bsr.w	ReadJoy1
	move.w	d3,(waitxpad).w
	tst.w	d1
	bne.w	rtss2
	bsr.w	ReadJoy2
	or.w	d3,(waitxpad).w
	tst.w	d1
	bne.w	rtss2
	tst.w	(FourWayPlay).w
	beq.w	.1
	bsr.w	ReadJoy3
	or.w	d3,(waitxpad).w
	tst.w	d1
	bne.w	rtss2
	bsr.w	ReadJoy4
	or.w	d3,(waitxpad).w
	tst.w	d1
	bne.w	rtss2
.1
	move.w	(Vcount).w,d0
.2
	cmp.w	(Vcount).w,d0
	beq.s	.2
	tst.w	d0
	bmi.s	.0
	rts
	;After waitx: a waitx for the pads on a team; nothing in the listing reaches it.
	movem.l	d4-d7/a0-a3,-(sp)
	neg.w	d0
	move.w	d0,(Vcount).w
.loop
	moveq	#1,d7
	clr.w	(CrowdPeak+2).w
	bclr	#1,(sflags).w
	bsr.w	ReadJoy1
	bsr.w	ProcessInputWithRepeat
	tst.w	d1						;any press?
	bne.w	.3
	clr.w	(CrowdPeak+2).w
	bset	#1,(sflags).w
	bsr.w	ReadJoy2
	bsr.w	ProcessInputWithRepeat
	tst.w	d1						;any press?
	bne.w	.3
	tst.w	(FourWayPlay).w			;four way?
	beq.w	.6
	bclr	#1,(sflags).w
	move.w	#3,(CrowdPeak+2).w
	bsr.w	ReadJoy3
	bsr.w	ProcessInputWithRepeat
	tst.w	d1						;any press?
	bne.w	.3
	tst.w	(FourWayPlay).w			;four way?
	beq.w	.6
	bset	#1,(sflags).w
	move.w	#4,(CrowdPeak+2).w
	bsr.w	ReadJoy4
	bsr.w	ProcessInputWithRepeat
	tst.w	d1						;any press?
	beq.w	.6
	;a button: run the menu
.3
	move.w	(Vcount).w,d0			;frame counter
	cmp.w	#$FF88,d0				;more than $78 frames left?
	blt.w	.4
	moveq	#-$78,d0
.4
	movem.w	d0,-(sp)
	jsr	(HandleMenuInput).l			;4EB8: target below $8000
	bne.w	.5						;menu did not end the screen: carry on waiting
	addq.w	#2,sp					;drop it
	bset	#7,d1					;tell the caller the menu ended it
	bra.w	.7
	;menu left the screen up
.5
	move.w	(sp)+,(Vcount).w
	;redraw and keep waiting
.6
	bsr.w	setvideo
	move.w	(Vcount).w,d0			;frame counter
	;loop
.loop2
	cmp.w	(Vcount).w,d0			;wait for the next vblank
	beq.s	.loop2					;wait for a new frame
	tst.w	d0						;time left?
	bmi.w	.loop
	;exit: restore the registers
.7
	movem.l	(sp)+,d4-d7/a0-a3
	rts
.loop3
	move.w	(Vcount).w,d0			;frame counter
	;loop
.loop4
	cmp.w	(Vcount).w,d0
	beq.s	.loop4					;wait for a new frame
	bsr.w	orjoy					;read the pads
	beq.s	.loop3					;no new press: wait again
	rts

FindHeldMenuPad						;menupadnum = the first pad (1-4, 3 and 4 with
									;FourWayPlay) with buttons held
	clr.w	(menupadnum).w
	bsr.w	ReadJoy1
	tst.w	d3
	bne.w	.0
	move.w	#1,(menupadnum).w
	bsr.w	ReadJoy2
	tst.w	d3
	bne.w	.0
	tst.w	(FourWayPlay).w
	beq.w	.0
	move.w	#2,(menupadnum).w
	bsr.w	ReadJoy3
	tst.w	d3
	bne.w	.0
	move.w	#3,(menupadnum).w
	bsr.w	ReadJoy4
.0
	rts

orjoy								;The new presses of pads 1 and 2 in d1 (orjoy4way with FourWayPlay)
	tst.w	(FourWayPlay).w
	bne.w	orjoy4way
	bsr.w	ReadJoy1
	move.w	d1,-(sp)
	bsr.w	ReadJoy2
	or.w	(sp)+,d1
	rts

orjoy4way							;orjoy for pads 1-4
	bsr.w	ReadJoy1
	move.w	d1,-(sp)
	bsr.w	ReadJoy2
	move.w	d1,-(sp)
	bsr.w	ReadJoy3
	move.w	d1,-(sp)
	bsr.w	ReadJoy4
	or.w	(sp)+,d1
	or.w	(sp)+,d1
	or.w	(sp)+,d1
	rts

nodiag								;Diagonal presses are ignored: clear the directions of d1 when d3 holds
									;more than one
	movem.l	d0/d4-d5,-(sp)
	moveq	#3,d4
	move.w	d3,d0
	andi.w	#$F,d0
	beq.w	.ok
.0
	clr.w	d5
	bset	d4,d5
	cmp.w	d5,d0
	dbeq	d4,.0
	beq.w	.ok
	andi.w	#$FFF0,d1
.ok
	movem.l	(sp)+,d0/d4-d5
	rts

ProcessInputWithRepeat				;nodiag, then key repeat on d1-d3: the held buttons again every 4 frames
	bsr.s	nodiag
	tst.w	d3
	beq.w	rtss2
	tst.w	d2
	bne.w	.0
	subq.w	#1,(repeatdelayframes).w
	bpl.w	rtss2
	move.w	#4,(repeatdelayframes).w
	move.w	d3,d1
	rts
.0
	move.w	#$F,(repeatdelayframes).w
	rts

ReadJoy1							;d1 = the new presses of pad 1, d3 the buttons held (lj1)
	move.b	(pad4way1).w,d0
	bsr.w	ReadJoy
	move.w	(lj1).w,d2
	move.w	d1,(lj1).w
	move.w	d1,d3
	eor.w	d1,d2
	and.w	d2,d1
	rts

ReadJoy2							;The same for pad 2 (lj2)
	move.b	(pad4way2).w,d0
	bsr.w	ReadJoy
	move.w	(lj2).w,d2
	move.w	d1,(lj2).w
	move.w	d1,d3
	eor.w	d1,d2
	and.w	d2,d1
	rts

ReadJoy3							;The same for pad 3 (lj3)
	move.b	(pad4way3).w,d0
	bsr.w	ReadJoy
	move.w	(lj3).w,d2
	move.w	d1,(lj3).w
	move.w	d1,d3
	eor.w	d1,d2
	and.w	d2,d1
	rts

ReadJoy4							;The same for pad 4 (lj4)
	move.b	(pad4way4).w,d0
	bsr.w	ReadJoy
	move.w	(lj4).w,d2
	move.w	d1,(lj4).w
	move.w	d1,d3
	eor.w	d1,d2
	and.w	d2,d1
	rts

ReadJoy								;d0 = pad byte: buttons to the high nibble, direction 0-8 (jdtab) in the
									;low nibble, d1 = the buttons
	not.b	d0
	clr.w	d1
	move.b	d0,d1
	move.w	d1,-(sp)
	andi.w	#$F0,d0
	andi.w	#$F,d1
	movea.l	#jdtab,a0
	move.b	(a0,d1.w),d1
	or.w	d1,d0
	move.w	(sp)+,d1
	rts

jdtab								;ReadJoy: pad directions to the directions 0-7, 8 for none
	dc.b	8,0,4,8,6,7,5,8,2,1,3,8,8,8,8,8

DoDMApro							;DoDMA protected from vblank (dfng set)
	move.w	(disflags).w,-(sp)
	bset	#dfng,(disflags).w
	bsr.w	DoDMA
	move.w	(sp)+,(disflags).w
	rts

DoDMA								;Dma d0 words from a0 to vram d1 (two transfers when the source crosses a
									;64K boundary), the sound driver paused
	movem.l	d2/a1,-(sp)
	move.w	d0,-(sp)
	move.w	#$D,d0
	jsr	(SoundCmd).l
	move.w	(sp)+,d0
	move.w	d0,d2
	add.w	d2,d2
	add.w	a0,d2
	bcc.w	.nd
	beq.w	.nd
	lsr.w	#1,d2					;do 2 transers if source address crosses 64k boundary
	sub.w	d2,d0
	move.w	d0,-(sp)
	bsr.w	.dd
	move.w	(sp)+,d0
	add.w	d0,d0
	add.w	d0,d1
	adda.w	d0,a0
	move.w	d2,d0
	bra.w	.nd
.dd
	movem.l	d2/a1,-(sp)
.nd
	lea	(Vctrl).l,a1
	move.w	#$8154,(a1)
	move.w	#$8F02,(a1)
	move.w	#$9300,d2
	move.b	d0,d2
	move.w	d2,(a1)
	move.w	#$9400,d2
	lsr.w	#8,d0
	move.b	d0,d2
	move.w	d2,(a1)
	move.l	a0,d0
	lsr.l	#1,d0
	move.w	#$9500,d2
	move.b	d0,d2
	move.w	d2,(a1)
	lsr.l	#8,d0
	move.w	#$9600,d2
	move.b	d0,d2
	move.w	d2,(a1)
	lsr.l	#8,d0
	andi.b	#$7F,d0
	move.w	#$9700,d2
	move.b	d0,d2
	move.w	d2,(a1)
	clr.l	d0
	move.w	d1,d0
	asl.l	#2,d0
	lsr.w	#2,d0
	ori.l	#$804000,d0
	move.l	d0,(dmaram).w
	move.w	(dmaram+2).w,(a1)
	move.w	(dmaram).w,(a1)
	bsr.w	WaitDMA
	move.w	#$8164,(a1)
	move.w	d0,-(sp)
	move.w	#$E,d0
	jsr	(SoundCmd).l
	move.w	(sp)+,d0
	movem.l	(sp)+,d2/a1
	rts

DoDMA_nd2							;Vram to vram copy by dma, protected from vblank.
	movem.l	d0-d3/a1,-(sp)
	move.w	(disflags).w,-(sp)
	bset	#dfng,(disflags).w
	lea	(Vctrl).l,a1
	move.w	#VDPR_MODE2+$54,(a1)
	move.w	#VDPR_AUTOINC+$01,(a1)
	move.w	#$9300,d3
	move.b	d0,d3
	move.w	d3,(a1)
	move.w	#$9400,d3
	lsr.w	#8,d0
	move.b	d0,d3
	move.w	d3,(a1)
	move.w	#$9500,d3
	move.b	d2,d3
	move.w	d3,(a1)
	move.w	#$9600,d3
	lsr.w	#8,d2
	move.b	d2,d3
	move.w	d3,(a1)
	move.w	#VDPR_DMASRCH+$C0,(a1)
	clr.l	d0
	move.w	d1,d0
	asl.l	#2,d0
	lsr.w	#2,d0
	swap	d0
	ori.w	#$C0,d0
	move.l	d0,(dmaram).w
	move.w	d0,-(sp)
	move.w	#$D,d0
	jsr	(SoundCmd).l
	move.w	(sp)+,d0
	move.w	(dmaram).w,(a1)
	move.w	(dmaram+2).w,(a1)
	bsr.w	WaitDMA
	move.w	#VDPR_MODE2+$64,(a1)
	move.w	#VDPR_AUTOINC+$02,(a1)
	move.w	#$E,d0
	jsr	(SoundCmd).l
	move.w	(sp)+,(disflags).w
	movem.l	(sp)+,d0-d3/a1
	rts

DoFill								;Fill d0 bytes of vram at d1 with the word d2
	movem.l	d3/a1,-(sp)
	movea.l	#Vdata,a1
	andi.l	#$FFFF,d1
	asl.l	#2,d1
	lsr.w	#2,d1
	ori.w	#$4000,d1
	swap	d1
	move.l	d1,4(a1)
	move.w	d2,d3
	swap	d3
	move.w	d2,d3
	lsr.w	#1,d0
	subq.w	#1,d0
.0
	move.l	d3,(dmaram).w
	move.w	(dmaram).w,(a1)
	move.w	(dmaram+2).w,(a1)
	dbf	d0,.0
	movem.l	(sp)+,d3/a1
	rts

WaitDMA								;Wait for the vdp dma busy bit to clear
	move.w	(Vctrl).l,-(sp)
	btst	#1,1(sp)
	addq.w	#2,sp
	bne.s	WaitDMA
	rts

setVram								;Fade every colour to d0, then fall into setVram_0
	movea.w	#(palfadenew-M68K_RAM),a0
	moveq	#$3F,d1
.0
	move.w	d0,(a0)+
	dbf	d1,.0
	move.w	#$18,(palcount).w
	bsr.w	forcefade

setVram_0							;Second half of setVram without the fade: clear vram and set the VDP
									;registers from disflags
	move.w	(disflags).w,-(sp)
	bset	#dfng,(disflags).w
	VmInc	2
	clr.w	d0
	bsr.w	Vmaddr
	move.w	#$3FFF,d0
	clr.l	d1
.9
	move.l	d1,(a0)
	dbf	d0,.9
	move.w	#$8C00,d0				;8 for shadow mode
	btst	#5,(disflags).w
	beq.w	.0
	move.w	#$8C08,d0				;8 for shadow mode
.0
	btst	#df32c,(disflags).w
	bne.w	.i32
	ori.w	#$81,d0
.i32
	move.w	d0,4(a0)				;40 col mode, no interlace, normal brightness
	move.w	#$8004,4(a0)			;512 color palette enable
	move.w	#$8164,4(a0)
	move.w	#$9001,d0				;playfield is 64x32
	cmpi.w	#6,(Map1col).w
	beq.w	.i64
	move.w	#$9003,d0
.i64
	move.w	d0,4(a0)
	move.w	#$8200,d0
	move.b	(VmMAP1).w,d0
	lsr.b	#2,d0
	andi.b	#$38,d0
	move.w	d0,4(a0)
	move.w	#$8400,d0
	move.b	(VmMAP2).w,d0
	lsr.b	#5,d0
	move.w	d0,4(a0)
	move.w	#$8300,d0
	move.b	(VmMAP3).w,d0
	lsr.b	#2,d0
	andi.b	#$3E,d0
	move.w	d0,4(a0)
	move.w	#$8500,d0
	move.b	(VSPRITES).w,d0
	lsr.b	#1,d0
	move.w	d0,4(a0)
	move.w	#$8D00,d0
	move.b	(VSCRLPM).w,d0
	lsr.b	#2,d0
	move.w	d0,4(a0)
	move.w	#$9100,4(a0)			;disable plane 3 graphics
	move.w	#$9200,4(a0)			;disable plane 3 graphics
	move.w	#$8700,4(a0)			;Palette # 0 is border/transparent
	move.w	#$8B00,4(a0)			;Scroll mode (entire scroll)
	move.l	#$40000010,4(a0)		;vsram
	move.l	#0,(a0)					;playfield 1/2
	move.w	(sp)+,(disflags).w
	rts

Vmaddr								;turns a VRAM address in d0 into a VDP control word
	movea.l	#Vdata,a0
	asl.l	#2,d0
	lsr.w	#2,d0
	ori.w	#$4000,d0
	swap	d0
	andi.w	#3,d0
	move.l	d0,4(a0)
	rts

dobitmap							;Copy the palettes flagged in d5 to palfadenew, then write the map at a1
									;to the screen at printx / printy
	move.w	(printy).w,-(sp)
	move.w	(disflags).w,-(sp)
	bset	#dfng,(disflags).w
	movem.l	d0-d3/d5-d6/a0-a3,-(sp)
	move.w	d1,d6
	movea.w	#(palfadenew-M68K_RAM),a3
	bra.w	.00
.01
	move.b	(a0,d0.w),(a3,d0.w)
	dbf	d0,.01
.0
	adda.l	#$20,a0
	adda.l	#$20,a3
.00
	moveq	#$1F,d0
	lsr.w	#1,d5
	bcs.s	.01
	bne.s	.0
	move.w	(printa).w,d5
	andi.w	#$F800,d5
	move.w	$E(sp),d2
	subq.w	#1,d2
.loop2
	bsr.w	xyVmMap
	move.w	d6,d0					;y start
	mulu.w	(a1),d0					;map width
	add.w	2(sp),d0
	asl.w	#1,d0
	move.w	$A(sp),d1
	subq.w	#1,d1
.loop1
	move.w	4(a1,d0.w),d3
	add.w	d4,d3
	eor.w	d5,d3
	move.w	d3,(a0)
	addq.w	#2,d0
	dbf	d1,.loop1
	addq.w	#1,(printy).w
	addq.w	#1,d6
	dbf	d2,.loop2
	btst	#0,(sflags6).w
	bne.w	.1
	bsr.w	DecompressGraphicsPlain
.1
	movem.l	(sp)+,d0-d3/d5-d6/a0-a3
	move.w	(sp)+,(disflags).w
	move.w	(sp)+,(printy).w
	rts

DecompressGraphicsWithCallback		;DecompressGraphics, then return 8 bytes past the call (callback data)
	move.l	(sp),(callbackPtr).w
	bsr.w	DecompressGraphics
	addq.l	#8,(sp)
	rts

DecompressGraphicsPlain				;Clear callbackPtr, fall into DecompressGraphics
	clr.l	(callbackPtr).w

DecompressGraphics					;a2 = graphics data, d4 = start char
	movem.l	d0-d1/a0-a6,-(sp)
	movea.l	a2,a0
	move.w	d4,d1
	asl.w	#5,d1
	move.w	(a0)+,d0
	beq.w	.0
	bmi.w	.packed
	add.w	d0,d4
	asl.w	#4,d0
	pea	(.0).l
	tst.l	(callbackPtr).w
	beq.w	DoDMApro
	movea.l	(callbackPtr).w,a1
	bra.w	remap
.packed
	andi.w	#$7FFF,d0
	add.w	d0,d4
	bsr.w	DecompressBytecode
.0
	movem.l	(sp)+,d0-d1/a0-a6
	rts

DecompressBytecode					;Unpack a0 into the 256 byte ring buffer at ThreeStars
	movea.w	#(ThreeStars-M68K_RAM),a1
	movea.w	#(ThreeStars-M68K_RAM),a3
	movea.w	#(callbackPtr-M68K_RAM),a4
	movea.l	#remap,a5
	movea.l	#DoDMApro,a6
	movem.l	d0-d3/a0-a2,-(sp)
	move.w	d1,d3
	clr.w	d1
	clr.w	d2
.0
	move.b	(a0)+,d0
	andi.w	#$F0,d0
	lsr.w	#3,d0
	lea	jump_table(pc),a2
	move.w	(a2,d0.w),d0
	jsr	(a2,d0.w)
	bra.s	.0

jump_table							;DecompressBytecode handler offsets, one per opcode high nibble
	dc.w	Opcode_CopyLiteral-jump_table	;0
	dc.w	Opcode_CopyLiteral-jump_table	;1
	dc.w	Opcode_ClearBytes-jump_table	;2
	dc.w	Opcode_Fillbytes-jump_table	;3
	dc.w	Opcode_CopyBackwardShort-jump_table	;4
	dc.w	Opcode_CopyBackwardShort-jump_table	;5
	dc.w	Opcode_CopyBackwardShort-jump_table	;6
	dc.w	Opcode_CopyBackwardShort-jump_table	;7
	dc.w	Opcode_CopyBackwardMedium-jump_table	;8
	dc.w	Opcode_CopyBackwardLong-jump_table	;9
	dc.w	Opcode_CopyBackwardExtended1-jump_table	;A
	dc.w	Opcode_CopyBackwardExtended2-jump_table	;B
	dc.w	Opcode_CopyBackwardReverseShort-jump_table	;C
	dc.w	Opcode_CopyBackwardReverseShort-jump_table	;D
	dc.w	Opcode_CopyBackwardReverseMedium-jump_table	;E
	dc.w	Opcode_CopyBackwardReverseLong-jump_table	;F

Opcode_CopyLiteral					;Opcodes 0-1, copy (low 5 bits)+1 bytes from the data.
	move.b	-$1(a0),d0
	andi.w	#$1F,d0
.loop
	move.b	(a0)+,(a1,d1.w)
	addq.b	#1,d1
	bne.w	.1
	bsr.w	FlushOutputBuffer
.1
	dbf	d0,.loop
	rts

Opcode_ClearBytes					;Opcode 2, write (low 4 bits)+1 zero bytes.
	move.b	-$1(a0),d0
	andi.w	#$F,d0
.loop
	clr.b	(a1,d1.w)
	addq.b	#1,d1
	bne.w	.1
	bsr.w	FlushOutputBuffer
.1
	dbf	d0,.loop
	rts

Opcode_Fillbytes					;Opcode 3, write the next data byte (low 4 bits)+3 times.
	move.b	-$1(a0),d0
	andi.w	#$F,d0
	addq.w	#2,d0
	move.b	(a0)+,d2
.loop
	move.b	d2,(a1,d1.w)
	addq.b	#1,d1
	bne.w	.1
	bsr.w	FlushOutputBuffer
.1
	dbf	d0,.loop
	rts

Opcode_CopyBackwardShort			;Opcodes 4-7, copy from back in the output buffer.
	move.b	-$1(a0),d0
	andi.w	#7,d0
	addq.w	#1,d0
	move.b	-$1(a0),d2
	lsr.w	#3,d2
	andi.w	#7,d2
	addq.w	#1,d2

CopyBackwardRun						;Shared copy loop, d0 = count-1, d2 = distance back.
	neg.b	d2
	add.b	d1,d2
.loop
	move.b	(a1,d2.w),(a1,d1.w)
	addq.b	#1,d2
	addq.b	#1,d1
	bne.w	.1
	bsr.w	FlushOutputBuffer
.1
	dbf	d0,.loop
	rts

Opcode_CopyBackwardMedium			;Opcode 8.
	move.b	-$1(a0),d0
	andi.w	#$F,d0
	addq.w	#2,d0
	move.b	(a0)+,d2
	bra.s	CopyBackwardRun

Opcode_CopyBackwardLong				;Opcode 9.
	move.b	(a0),d0
	asl.b	#1,d0
	move.b	-$1(a0),d0
	roxl.b	#1,d0
	andi.w	#$1F,d0
	addq.w	#2,d0
	move.b	(a0)+,d2
	andi.w	#$7F,d2
	addq.w	#1,d2
	bra.s	CopyBackwardRun

Opcode_CopyBackwardExtended1		;Opcode A.
	move.b	-$1(a0),d0
	asl.w	#8,d0
	move.b	(a0),d0
	lsr.w	#6,d0
	andi.w	#$3F,d0
	addq.w	#2,d0
	move.b	(a0)+,d2
	andi.w	#$3F,d2
	addq.w	#1,d2
	bra.s	CopyBackwardRun

Opcode_CopyBackwardExtended2		;Opcode B.
	move.b	-$1(a0),d0
	asl.w	#8,d0
	move.b	(a0),d0
	lsr.w	#5,d0
	andi.w	#$7F,d0
	addq.w	#2,d0
	move.b	(a0)+,d2
	andi.w	#$1F,d2
	addq.w	#1,d2
	bra.s	CopyBackwardRun

Opcode_CopyBackwardReverseShort		;Opcodes C-D, copy backwards through the source.
	move.b	-$1(a0),d0
	andi.w	#3,d0
	addq.w	#1,d0
	move.b	-$1(a0),d2
	lsr.w	#2,d2
	andi.w	#7,d2
	addq.w	#1,d2

CopyBackwardReverseRun				;Shared reverse copy loop.
	neg.b	d2
	add.b	d1,d2
.loop
	move.b	(a1,d2.w),(a1,d1.w)
	subq.b	#1,d2
	addq.b	#1,d1
	bne.w	.1
	bsr.w	FlushOutputBuffer
.1
	dbf	d0,.loop
	rts

Opcode_CopyBackwardReverseMedium	;Opcode E. Distance 0 is the end code.
	move.b	-$1(a0),d0
	andi.w	#$F,d0
	addq.w	#2,d0
	move.b	(a0)+,d2
	bne.s	CopyBackwardReverseRun
	tst.w	d1
	beq.w	.1
	bsr.w	FlushOutputBuffer
.1
	addq.w	#4,sp
	movem.l	(sp)+,d0-d3/a0-a2
	rts

Opcode_CopyBackwardReverseLong		;Opcode F.
	move.b	(a0),d0
	asl.b	#1,d0
	move.b	-$1(a0),d0
	roxl.b	#1,d0
	andi.w	#$1F,d0
	addq.w	#2,d0
	move.b	(a0)+,d2
	andi.w	#$7F,d2
	addq.w	#1,d2
	bra.s	CopyBackwardReverseRun

FlushOutputBuffer					;Write the full ring buffer to vram.
	movem.l	d0-d1/a0-a1,-(sp)
	move.w	d1,d0
	bne.w	.1
	move.w	#$100,d0
.1
	lsr.w	#1,d0
	move.w	d3,d1
	add.w	d0,d3
	add.w	d0,d3
	movea.l	a1,a0
	tst.l	(a4)
	beq.w	.2
	movea.l	(a4),a1
	jsr	(a5)
	bra.w	.3
.2
	jsr	(a6)
.3
	movem.l	(sp)+,d0-d1/a0-a1
	rts

xyVmMap								;Set the vdp write address to printx, printy in the map at VmMAP1 + printm
	movem.l	d0-d2,-(sp)
	move.w	(printx).w,d0
	move.w	(printy).w,d1
	movea.l	#$FFFFB004,a0
	adda.w	(printm).w,a0
	move.w	2(a0),d2
	asl.w	d2,d1
	add.w	d1,d0
	asl.w	#1,d0
	add.w	(a0),d0
	bsr.w	Vmaddr
	movem.l	(sp)+,d0-d2
	rts

eraser								;Fill a d0 x d1 rectangle with char d2 at printx / printy / printm
	movem.l	d0-d2/a0,-(sp)
	move.w	(disflags).w,-(sp)
	bset	#dfng,(disflags).w
	movem.w	d0-d1,-(sp)
.0
	bsr.s	xyVmMap
	move.w	(sp),d0
	subq.w	#1,d0
.1
	move.w	d2,(a0)
	dbf	d0,.1
	addq.w	#1,(printy).w
	andi.w	#$1F,(printy).w
	subq.w	#1,2(sp)
	bne.s	.0
	addq.w	#4,sp
	move.w	(sp)+,(disflags).w
	movem.l	(sp)+,d0-d2/a0
	rts

Framer								;Draw a d0 x d1 frame at printx / printy from the framer map
	movem.l	d0-d4/a0-a1,-(sp)
	move.w	(disflags).w,-(sp)
	bset	#dfng,(disflags).w
	movem.w	d0-d1,-(sp)
	move.w	(printa).w,d2
	add.w	(framercset).w,d2
	movea.l	#FramerMap,a1
	adda.l	4(a1),a1
	addq.w	#4,a1
	clr.w	d4
	bsr.w	.tbline
	subq.w	#3,2(sp)
.mtop
	bsr.w	.tbline
	subq.w	#6,d4
	subq.w	#1,2(sp)
	bpl.s	.mtop
	addq.w	#6,d4
	bsr.w	.tbline
	addq.w	#4,sp
	move.w	(sp)+,(disflags).w
	movem.l	(sp)+,d0-d4/a0-a1
	rts
.tbline
	bsr.w	xyVmMap
	addq.w	#1,(printy).w
	bsr.w	.setter
	addq.w	#2,d4
	move.w	4(sp),d0
	subq.w	#3,d0
.tblp
	bsr.w	.setter
	dbf	d0,.tblp
	addq.w	#2,d4
	bsr.w	.setter
	addq.w	#2,d4
	rts
.setter
	move.w	(a1,d4.w),d3
	add.w	d2,d3
	move.w	d3,(a0)
	rts

printsmallz							;printsmall with the String after the call
	move.l	a1,-(sp)
	movea.l	4(sp),a1
	bsr.w	printsmall
	move.l	a1,4(sp)
	movea.l	(sp)+,a1
	rts

printsmall							;print String a1 at printx / printy with the small font chars
									;(smallfontchars, or smallfontalt with
									;sflags6 bit 3): a negative byte is a control code (ControlCodeJumpTable)
	move.w	(disflags).w,-(sp)
	bset	#dfng,(disflags).w
	movem.l	d0-d3/a0/a2-a3,-(sp)
	movea.w	#(smallfontchars-M68K_RAM),a3
	btst	#3,(sflags6).w
	beq.w	.1
	movea.w	#(smallfontalt-M68K_RAM),a3
.1
	bsr.w	xyVmMap
	move.w	(printa).w,d2
	move.w	(a1)+,d3
	subq.w	#2,d3
	bra.w	.4
.0
	move.b	(a1)+,d0
	ext.w	d0
	bgt.w	.nocom
	neg.w	d0
	asl.w	#2,d0
	movea.l	#ControlCodeJumpTable,a2
	movea.l	(a2,d0.w),a2
	jsr	(a2)
	bra.w	.4
.nocom
	cmp.b	#$40,d0
	bne.w	.noblank
	move.w	#$7FF,d0
	bra.w	.p
.noblank
	cmp.b	#$5E,d0
	beq.w	.skip
	cmp.b	#$61,d0
	blt.w	.2
	cmp.b	#$7A,d0
	bgt.w	.2
	addi.b	#-$20,d0
.2
	asl.w	#1,d0
	movea.l	#RosterFont,a2
	adda.l	4(a2),a2
	move.w	4(a2,d0.w),d0
	move.w	(printfontset).w,d1
	add.w	(a3,d1.w),d0
.p
	add.w	d2,d0
	move.w	d0,(a0)
	addq.w	#1,(printx).w
.4
	dbf	d3,.0
	movem.l	(sp)+,d0-d3/a0/a2-a3
	move.w	(sp)+,(disflags).w
	rts
.skip
	addq.w	#1,(printx).w
	bsr.w	xyVmMap
	bra.s	.4

ControlCodeJumpTable				;Printsmall control codes, indexed by -byte
	dc.l	rtss2					;0: no-op
	dc.l	ControlCode_SetMap		;-1
	dc.l	ControlCode_SetAttribute	;-2
	dc.l	ControlCode_SetX		;-3
	dc.l	ControlCode_SetY		;-4
	dc.l	ControlCode_AddX		;-5
	dc.l	ControlCode_AddY		;-6
	dc.l	ControlCode_SetFont		;-7
	dc.l	ControlCode_SetMapAndPosition	;-8

ControlCode_SetMapAndPosition		;Control code -8, next 4 bytes = attribute, map, x, y.
	bsr.w	ControlCode_SetAttribute
	bsr.w	ControlCode_SetMap
	bsr.w	ControlCode_SetX
	bra.w	ControlCode_SetY

ControlCode_SetMap					;Control code -1, next byte = map number -> printm.
	move.b	(a1)+,d0
	subq.w	#1,d3
	andi.w	#3,d0
	asl.w	#2,d0
	subq.w	#4,d0
	move.w	d0,(printm).w
	bra.w	xyVmMap

ControlCode_SetAttribute			;Control code -2, next byte = palette/priority -> printa.
	move.b	(a1)+,d2
	andi.w	#7,d2
	subq.w	#1,d3
	ror.w	#3,d2
	move.w	d2,(printa).w
	rts

ControlCode_SetX					;Control code -3, next byte = printx.
	clr.w	d0
	move.b	(a1)+,d0
	subq.w	#1,d3
	move.w	d0,(printx).w
	bra.w	xyVmMap

ControlCode_SetY					;Control code -4, next byte = printy.
	clr.w	d0
	move.b	(a1)+,d0
	subq.w	#1,d3
	move.w	d0,(printy).w
	bra.w	xyVmMap

ControlCode_AddX					;Control code -5, add the next (signed) byte to printx.
	move.b	(a1)+,d0
	ext.w	d0
	subq.w	#1,d3
	add.w	d0,(printx).w
	bra.w	xyVmMap

ControlCode_AddY					;Control code -6, add the next (signed) byte to printy.
	move.b	(a1)+,d0
	ext.w	d0
	subq.w	#1,d3
	add.w	d0,(printy).w
	bra.w	xyVmMap

ControlCode_SetFont					;Control code -7, next byte = char set index.
	clr.w	d0
	move.b	(a1)+,d0
	subq.w	#1,d3					;byte used
	asl.w	#1,d0
	move.w	d0,(printfontset).w
	rts

printz								;print with the String after the call
	move.l	a1,-(sp)
	movea.l	4(sp),a1
	bsr.w	print
	move.l	a1,4(sp)
	movea.l	(sp)+,a1
	rts

print								;print String a1 at printx / printy with the font map SmallFontMap: a
									;negative byte sets printa / printm /
									;printx / printy from the next bytes, $40 a blank, $5E skips one column, lower
									;case printed as upper case
	move.w	(disflags).w,-(sp)
	bset	#dfng,(disflags).w
	movem.l	d0-d3/a0/a2,-(sp)
	bsr.w	xyVmMap
	move.w	(printa).w,d2
	move.w	(a1)+,d3
	subq.w	#2,d3
	bra.w	.4
.0
	move.b	(a1)+,d0
	beq.w	.4
	ext.w	d0
	bpl.w	.nocom
	neg.w	d0
	move.w	d0,d2
	asl.w	#8,d2
	asl.w	#1,d2
	andi.w	#$F800,d2
	move.w	d2,(printa).w
	andi.w	#3,d0
	asl.w	#2,d0
	subq.w	#4,d0
	move.w	d0,(printm).w
	move.b	(a1)+,d0
	ext.w	d0
	move.w	d0,(printx).w
	move.b	(a1)+,d1
	ext.w	d1
	move.w	d1,(printy).w
	bsr.w	xyVmMap
	subq.w	#2,d3
	bra.w	.4
.nocom
	cmp.b	#$40,d0
	bne.w	.noblank
	move.w	#$7FF,d0
	bra.w	.p
.noblank
	cmp.b	#$5E,d0
	beq.w	.skip
	cmp.b	#$61,d0
	blt.w	.1
	cmp.b	#$7A,d0
	bgt.w	.1
	addi.b	#-$20,d0
.1
	asl.w	#1,d0
	movea.l	#SmallFontMap,a2
	adda.l	4(a2),a2
	move.w	4(a2,d0.w),d0
	btst	#3,(sflags6).w
	beq.w	.2
	add.w	(smallfontalt).w,d0
	bra.w	.p
.2
	add.w	(smallfontchars).w,d0
.p
	add.w	d2,d0
	move.w	d0,(a0)
	addq.w	#1,(printx).w
.4
	dbf	d3,.0
	movem.l	(sp)+,d0-d3/a0/a2
	move.w	(sp)+,(disflags).w
	rts
.skip
	addq.w	#1,(printx).w
	bsr.w	xyVmMap
	bra.s	.4

printcurz							;printcur with the String after the call
	move.l	a1,-(sp)
	movea.l	4(sp),a1
	bsr.w	printcur
	move.l	a1,4(sp)
	movea.l	(sp)+,a1
	rts

printcur							;print with the font map at smallfontptr
	move.w	(disflags).w,-(sp)
	bset	#dfng,(disflags).w
	movem.l	d0-d3/a0/a2,-(sp)
	bsr.w	xyVmMap
	move.w	(printa).w,d2
	move.w	(a1)+,d3
	subq.w	#2,d3
	bra.w	.4
.0
	move.b	(a1)+,d0
	beq.w	.4
	ext.w	d0
	bpl.w	.nocom
	neg.w	d0
	move.w	d0,d2
	asl.w	#8,d2
	asl.w	#1,d2
	andi.w	#$F800,d2
	move.w	d2,(printa).w
	andi.w	#3,d0
	asl.w	#2,d0
	subq.w	#4,d0
	move.w	d0,(printm).w
	move.b	(a1)+,d0
	ext.w	d0
	move.w	d0,(printx).w
	move.b	(a1)+,d1
	ext.w	d1
	move.w	d1,(printy).w
	bsr.w	xyVmMap
	subq.w	#2,d3
	bra.w	.4
.nocom
	cmp.b	#$40,d0
	bne.w	.noblank
	move.w	#$7FF,d0
	bra.w	.p
.noblank
	cmp.b	#$5E,d0
	beq.w	.skip
	cmp.b	#$61,d0
	blt.w	.1
	cmp.b	#$7A,d0
	bgt.w	.1
	addi.b	#-$20,d0
.1
	asl.w	#1,d0
	movea.l	(smallfontptr).w,a2
	adda.l	4(a2),a2
	move.w	4(a2,d0.w),d0
	btst	#3,(sflags6).w
	beq.w	.2
	add.w	(smallfontalt).w,d0
	bra.w	.p
.2
	add.w	(smallfontchars).w,d0
.p
	add.w	d2,d0					;for alternate palettes
	move.w	d0,(a0)
	addq.w	#1,(printx).w
.4
	dbf	d3,.0
	movem.l	(sp)+,d0-d3/a0/a2
	move.w	(sp)+,(disflags).w
	rts
.skip
	addq.w	#1,(printx).w
	bsr.w	xyVmMap
	bra.s	.4

FormatAndPrintTime					;d0 bits 14-15 = period, bits 0-13 = seconds: print the period
									;(PeriodLabelTable) and the time.
	swap	d0
	clr.w	d0
	rol.l	#2,d0
	movea.l	#PeriodLabelTable,a1
	bsr.w	PrintSmallListItem
	addq.w	#2,(printx).w
	swap	d0
	lsr.w	#2,d0
	bsr.w	PushTime
	bra.w	printsmall

PeriodLabelTable					;String list for FormatAndPrintTime
	String	' 1'
	String	' 2'
	String	' 3'
	String	'OT'

PushTime							;a1 = String "M:SS" of the time d0 (seconds), built back from mesarea+30
	movea.w	#(mesarea+30-M68K_RAM),a1
	move.l	d0,-(sp)
	move.l	a1,-(sp)
	ext.l	d0
	divu.w	#$A,d0
	swap	d0
	addi.w	#$30,d0
	move.b	d0,-(a1)
	swap	d0
	ext.l	d0
	divu.w	#6,d0
	swap	d0
	addi.w	#$30,d0
	move.b	d0,-(a1)
	swap	d0
	move.b	#$3A,-(a1)
	ext.l	d0
	divu.w	#$A,d0
	swap	d0
	addi.w	#$30,d0
	move.b	d0,-(a1)
	swap	d0
	move.b	#$20,-(a1)
	tst.w	d0
	beq.w	.noz
	addi.w	#$30,d0
	move.b	d0,(a1)
.noz
	move.l	(sp)+,d0
	sub.l	a1,d0
	addq.w	#2,d0
	btst	#0,d0
	beq.w	.1
	clr.b	-(a1)
	addq.w	#1,d0
.1
	move.w	d0,-(a1)
	move.l	(sp)+,d0
	rts

PushNumber							;a1 = String of the decimal number d0, built back from PushNumberBuf.
	movea.w	#(ltack-4-M68K_RAM),a1
	move.l	d0,-(sp)
	move.l	a1,-(sp)
.loop
	ext.l	d0
	divu.w	#$A,d0
	swap	d0
	addi.w	#$30,d0
	move.b	d0,-(a1)
	swap	d0
	tst.w	d0
	bne.s	.loop
	move.l	(sp)+,d0
	sub.l	a1,d0
	addq.w	#2,d0
	btst	#0,d0
	beq.w	.1
	clr.b	-(a1)
	addq.w	#1,d0
.1
	move.w	d0,-(a1)
	move.l	(sp)+,d0
	rts

PushNumberWidth						;Right-justified number
	movem.l	d0-d3,-(sp)				;push to stack
	movea.w	#(PushWidthBuf+2-M68K_RAM),a1
	moveq	#1,d2					;move 1 into d2
	sub.w	d2,d1					;sub d2 from d1
	bra.w	.loop
.mul
	mulu.w	#$A,d2					;mult d2 by 10 dec
.loop
	dbf	d1,.mul
	moveq	#$20,d3					;move 20 into d3
.loop2
	ext.l	d0						;sign extend d0
	divu.w	d2,d0					;divide d2 into d0
	bne.w	.3
	cmp.w	#1,d2					;compare d2 to 1
	beq.w	.3
	move.w	d3,d0					;move d3 into d0
	bra.w	.put
.3
	moveq	#$30,d3					;move 48 dec into d3
	add.w	d3,d0					;add d3 to d0
.put
	move.b	d0,(a1)+				;move d0 into a1 and increment a1
	swap	d0						;swap d0 words
	divu.w	#$A,d2					;divide d2 by 10 dec
	bne.s	.loop2
	move.l	a1,d0					;move a1 into d0
	subi.w	#$C056,d0
	btst	#0,d0					;test bit 0 of d0
	beq.w	.even
	clr.b	(a1)+					;clear byte at a1 and increment
	addq.w	#1,d0					;add 1 to d0
.even
	movea.w	#(PushWidthBuf-M68K_RAM),a1
	move.w	d0,(a1)					;move d0 into a1 address location
	movem.l	(sp)+,d0-d3				;push from stack
	rts

appendz								;appstring with the String after the call
	movea.l	(sp)+,a1
	bsr.w	appstring
	jmp	(a1)

appstring							;Append String a1 to String a3 (the 0 pad byte dropped, the result padded
									;to an even length)
	movem.l	d0/a0,-(sp)
	lea	2(a3),a0
	move.w	(a3),d0
	subq.w	#3,d0
	bmi.w	.1
.0
	addq.w	#1,a0
	tst.b	(a0)
	dbeq	d0,.0
.1
	move.w	(a1)+,d0
	subq.w	#3,d0
	bmi.w	.ex
.2
	move.b	(a1)+,(a0)+
	bne.w	.3
	subq.w	#1,a0
.3
	dbf	d0,.2
	move.l	a0,d0
	btst	#0,d0
	beq.w	.4
	clr.b	(a0)+
	addq.l	#1,d0
.4
	sub.l	a3,d0
	move.w	d0,(a3)
.ex
	movem.l	(sp)+,d0/a0
	rts

printbigcurz						;printbigcur with the String after the call.
	move.l	a1,-(sp)
	movea.l	4(sp),a1
	bsr.w	printbigcur
	move.l	a1,4(sp)
	movea.l	(sp)+,a1
	rts

printbigz							;printbig with the String after the call
	move.l	a1,-(sp)
	movea.l	4(sp),a1
	bsr.w	printbig
	move.l	a1,4(sp)
	movea.l	(sp)+,a1
	rts

printbigcur							;printbigtext with the font map already at bigfontptr
	bra.w	printbigtext

printbig							;print String a1 with the big font at printx / printy: BigFontMap2,
									;BigFontMap4 with sflags11 bit 2
	move.l	#BigFontMap2,(bigfontptr).l
	btst	#2,(sflags11).w
	beq.w	printbigtext
	move.l	#BigFontMap4,(bigfontptr).l

printbigtext						;Print with the font map at bigfontptr. Lower
									;case is printed as upper case
	move.w	(disflags).w,-(sp)
	bset	#dfng,(disflags).w
	movem.l	d0-d7/a0/a2,-(sp)
	move.w	(printx).w,d4
	move.w	(printy).w,d5
	move.w	(printa).w,d6
	btst	#2,(sflags11).w
	bne.w	.3
	add.w	(printbigchars).w,d6
	bra.w	.4
.3
	add.w	(BigFontchars).w,d6
.4
	move.w	(a1)+,d3
	subq.w	#2,d3
	bra.w	.1
.0
	move.b	(a1)+,d0
	beq.w	.1
	ext.w	d0
	bpl.w	.nocom
	neg.w	d0
	asl.w	#2,d0
	movea.l	#BigControlCodeJumpTable,a2
	movea.l	(a2,d0.w),a2
	jsr	(a2)
	bra.w	.1
.nocom
	cmp.b	#$61,d0
	blt.w	.2
	cmp.b	#$7A,d0
	bgt.w	.2
	addi.b	#-$20,d0
.2
	move.w	d3,-(sp)
	bsr.w	PrintBigChar
	move.w	(sp)+,d3
.1
	dbf	d3,.0
	move.w	d4,(printx).w
	move.w	d5,(printy).w
	movem.l	(sp)+,d0-d7/a0/a2
	move.w	(sp)+,(disflags).w
	rts
