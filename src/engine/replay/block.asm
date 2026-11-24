;	CanBlock and its screen init.

CanBlock							;Ne when joystick player a3 may block the shot (SPAblock): pfalock clear,
									;sflags sfssdir set and GameFlags bit
									;2 clear (one block per shot; cleared while sfssdir is clear), a3 at y $56
									;or more toward the goal it shoots at, the puck carrier on the other team,
									;the direction (vtoa) from a3 to the puck the same as from the goal at y
									;$10B to the puck, a3 on the puck's side of x 0 and within y $B2 of it,
									;and a3 facing that direction or one next to it. d0 is restored.
	movem.l	d0-d3/a0-a2,-(sp)
	btst	#pfalock,pflags(a3)
	bne.w	.6
	btst	#sfssdir,(sflags).w
	bne.w	.1
	bclr	#3,(sflags10).w
.1
	btst	#3,(sflags10).w
	bne.w	.6
	move.w	Ypos(a3),d0
	btst	#pfgoal,pflags(a3)
	beq.w	.2
	neg.w	d0
.2
	cmp.w	#$76,d0
	blt.w	.6
	tst.w	(puckc).w
	bmi.w	.6
	movea.l	#SortCords,a0
	move.w	(puckc).w,d0
	asl.w	#7,d0
	adda.w	d0,a0
	move.b	pflags(a0),d0
	move.b	pflags(a3),d1
	eor.b	d1,d0
	btst	#pfteam,d0
	beq.w	.6
	btst	#sfssdir,(sflags).w
	beq.w	.6
	move.w	(puckx).w,d0			;d0 = direction from a3 to the puck
	sub.w	(a3),d0
	move.w	(pucky).w,d1
	sub.w	Ypos(a3),d1
	jsr	(vtoa).l
	move.w	d0,-(sp)
	move.w	(puckx).w,d0			;direction from the goal at y $10B to the puck
	move.w	#$11E,d1
	btst	#pfgoal,pflags(a3)
	beq.w	.3
	neg.w	d1
.3
	sub.w	(pucky).w,d1
	neg.w	d1
	jsr	(vtoa).l
	cmp.w	(sp)+,d0
	bne.w	.6
	movem.w	d0,-(sp)
	move.w	(a3),d1
	move.w	(puckx).w,d0
	eor.w	d0,d1
	movem.w	(sp)+,d0
	bmi.w	.6
	move.w	(pucky).w,d1
	sub.w	Ypos(a3),d1
	bpl.w	.4
	neg.w	d1
.4
	cmp.w	#$BE,d1
	bgt.w	.6
	cmp.w	facedir(a3),d0
	beq.w	.5
	addq.w	#1,d0
	andi.w	#3,d0
	cmp.w	facedir(a3),d0
	beq.w	.5
	subq.w	#2,d0
	andi.w	#3,d0
	cmp.w	facedir(a3),d0
	bne.w	.6
.5
	move.w	#1,d0
	bra.w	.7
.6
	clr.w	d0
.7
	movem.l	(sp)+,d0-d3/a0-a2
	rts
	movem.l	d0-d7/a0-a6,-(sp)
	clr.w	(carddelay).w
	bsr.w	CanBlockExit
	bsr.w	CanBlockScreenInit
	movea.l	#StandingsSprites,a0
	jsr	(DrawScreenSprite).l
	move.w	#$18,(palcount).w
	bclr	#2,(disflags).w
	clr.w	(StandingsMode).w
.loop
	bsr.w	StandingsGroups
	movea.l	#StandingsBuf,a0
	jsr	(ReadStandings).l
	bsr.w	StandingsPoints
	bsr.w	SortStandings
	bsr.w	SortStandingsHeaders
	move.w	#$2500,sr
.loop2
	move.w	(Vcount).w,d0			;frame counter
	;loop
.loop3
	cmp.w	(Vcount).w,d0
	beq.s	.loop3					;wait for a new frame
	jsr	(SetMenuScroll).l			;read the pads
	cmpi.w	#$5460,(carddelay).w
	jsr	(orjoy).l
	jsr	(ProcessInputWithRepeat).l
	tst.w	d1
	beq.w	.8
	clr.w	(carddelay).w
.8
	btst	#7,d1
	bne.w	.13
	btst	#2,d1
	beq.w	.9
	eori.w	#1,(StandingsMode).w
	bra.s	.loop
.9
	btst	#3,d1
	beq.w	.10
	eori.w	#1,(StandingsMode).w
	bra.s	.loop
.10
	btst	#0,d1
	beq.w	.11
	eori.w	#2,(StandingsMode).w
	bra.w	.loop
.11
	btst	#1,d1
	beq.w	.12
	eori.w	#2,(StandingsMode).w
	bra.w	.loop
.12
	bra.s	.loop2
.13
	move.l	#SeasonMenuScreen,(NextScreenPtr).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts
CanBlockExit	equ	*	;Shared return of CanBlock
	rts
CanBlockScreenInit					;Set up the menu screen planes and VBlank handler (low confidence)
	bset	#5,(sflags12).w
	move.l	#VBlank_Menus,(VBint).w
	bclr	#dfok,(disflags).w
	bset	#dfng,(disflags).w
	bclr	#df32c,(disflags).w
	move.w	#0,(VSCRLPM).w
	move.w	#$B400,(VmMAP3).w
	move.w	#5,(Map3col).w
	move.w	#$BC00,(VSPRITES).w
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
	movea.l	#StandingsSprites,a1
	jsr	(LoadScreenSprite).l
	move.w	d4,(smallfontchars).w
	movea.l	#SmallFontMap2+8,a2
	jsr	(DecompressGraphicsPlain).l
	subq.w	#1,d4
	move.l	#SmallFontMap2,(smallfontptr).w
	move.w	d4,(printbigchars).w
	movea.l	#BigFontMap2+8,a2
	jsr	(DecompressGraphicsPlain).l
	subi.w	#9,d4
	move.w	d4,(BigFontchars).w
	movea.l	#BigFontMap4+8,a2
	jsr	(DecompressGraphicsPlain).l
	move.w	#$19,d1
	clr.w	d2
	movea.l	#$FFFF2328,a0
	movea.l	#TeamBlockPtrs,a1
.loop
	cmp.w	#1,d2
	bne.w	.8
	move.w	d4,-(sp)
	move.w	(smallfontchars).w,d4
	addq.w	#1,d4
	move.w	d4,(a0)+
	movea.l	4(a1),a2
	addq.w	#8,a2
	jsr	(DecompressGraphicsPlain).l
	move.w	(sp)+,d4
	bra.w	.9
.8
	move.w	d4,(a0)+
	move.w	d2,d0
	asl.w	#2,d0
	movea.l	(a1,d0.w),a2
	addq.w	#8,a2
	jsr	(DecompressGraphicsPlain).l
.9
	addq.w	#1,d2
	dbf	d1,.loop
	jsr	(printsmallz).l
	String	$FF,1,$FD,0,$FC
	moveq	#$28,d0
	moveq	#$1C,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),0,0
	movea.l	#StandingsBgMap,a0
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
	movea.l	#StandingsTitleMap,a0
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
	jsr	(printcurz).l
	String	$8F,6,$1A,'{} CONFERENCE [] DIVISION'
	bset	#2,(sflags11).w
	jsr	(printbigz).l
	String	$F8,4,1,$14,8,'W',$F8,4,1,$19,8,'L',$F8,4,1,$1E,8,'T',$F8,4,1,$22,8,'PTS'
	move.w	#$2500,sr
	rts
