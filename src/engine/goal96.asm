;	The controller setup screen. SetContTeams picks a team for each pad, DrawPadSetup and
;	DrawPadIcon draw the pads, and ControllerSetupScreen builds the screen. ReadAllPads reads
;	all four pads.

SetContTeams	;The controller setup screen: pick the team of each pad (cont1team ... cont4team);
	;a demo or a timeout clears all pads
	tst.w	(demoflag).w
	bmi.w	.setup
.clear
	clr.w	(cont1team).w
	clr.w	(cont2team).w
	clr.w	(cont3team).w
	clr.w	(cont4team).w
	clr.w	(OptNOP).w
	rts
.setup
	clr.w	(setupvalues).w
	clr.w	(setupvalues+2).w
	move.w	#1,(cont1team).w
	btst	#7,(GameFlags).w
	beq.w	.0
	move.w	(HomeTeam).w,d0
	cmp.b	(dword_FFDD82+2).w,d0
	beq.w	.0
	move.w	#2,(cont1team).w
.0
	cmpi.w	#1,(OptPlayMode).w
	beq.w	.1
	cmpi.w	#3,(OptPlayMode).w
	beq.w	.1
	cmpi.w	#2,(OptPlayMode).w
	bne.w	.2
.1
	move.w	(potreeteam).w,d0
	movea.l	#potree,a0
	move.b	(a0,d0.w),d0
	move.w	#1,(cont1team).w
	cmp.w	(HomeTeam).w,d0
	beq.w	.2
	move.w	#2,(cont1team).w
.2
	clr.w	(cont2team).w
	clr.w	(cont3team).w
	clr.w	(cont4team).w
	bsr.w	ControllerSetupScreen
	bsr.w	DrawPadSetup
	jsr	(vcountwait).l
	jsr	(vcountwait).l
	move.w	#$18,(palcount).w
	bclr	#2,(disflags).w
	clr.w	(carddelay).w
.frame
	move.w	(vcount).w,d0
.wait
	cmp.w	(vcount).w,d0
	beq.s	.wait
	move.w	(VSCRLPM).w,d0
	jsr	(Vmaddr).l
	move.w	#0,(a0)
	move.w	(homegoalies).w,d0
	move.w	d0,(a0)
	addq.w	#1,(homegoalies).w
	cmpi.w	#$5460,(carddelay).w
	bge.w	.clear
	bsr.w	ReadAllPads
	tst.w	(TempLegSpd).w
	beq.w	.keys
	clr.w	(carddelay).w
.keys
	btst	#7,(TempLegSpd+1).w
	bne.w	.4
	move.w	#1,d4
	tst.w	(FourWayPlay).w
	beq.w	.8
	btst	#0,(gmode2).w
	bne.w	.8
	move.w	#3,d4
.8
	movea.l	#cont1team,a0
	movea.l	#TempWord1+1,a3
.pad
	move.b	(a3),d1
	btst	#2,d1
	beq.w	.10
	move.w	(a0),d0
	cmp.w	#2,d0
	beq.w	.10
	movea.l	#ContTeamOrder1,a4
	move.b	(a4,d0.w),d0
	move.w	d0,(a0)
	move.w	(vcount).w,d0
.3
	cmp.w	(vcount).w,d0
	beq.s	.3
	bsr.w	DrawPadSetup
	bra.w	.nextpad
.10
	btst	#3,d1
	beq.w	.nextpad
	move.w	(a0),d0
	cmp.w	#1,d0
	beq.w	.nextpad
	movea.l	#ContTeamOrder2,a4
	move.b	(a4,d0.w),d0
	move.w	d0,(a0)
	bsr.w	DrawPadSetup
	bra.w	*+4
.nextpad
	addq.w	#2,a0
	addq.w	#2,a3
	dbf	d4,.pad
	bra.w	.frame
.4
	move.w	#4,(OptNOP).w
	clr.w	(padiconchars1).w
	rts

ContTeamOrder1	;Pad team order tables for SetContTeams
	dc.b	2,0,2,$FF

ContTeamOrder2
	dc.b	1,1,0,$FF

DrawPadSetup	;Draw the pads and their icons (DrawPadIcon)
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#8,(printy).w
	move.w	#1,d4
	tst.w	(FourWayPlay).w
	beq.w	.0
	btst	#0,(gmode2).w
	bne.w	.0
	move.w	#3,d4
.0
	movea.l	#cont1team,a0
	move.w	#0,d7
.loop
	move.w	(printy).w,-(sp)
	move.w	#$E,(printx).w
	tst.w	(a0)
	beq.w	.1
	move.w	#$19,(printx).w
	cmpi.w	#1,(a0)
	beq.w	.1
	move.w	#3,(printx).w
.1
	movem.l	d4/d7-a0,-(sp)
	add.w	d7,d7
	movea.l	#LineHoldFlag,a0
	move.w	(printx).w,d4
	cmp.w	(a0,d7.w),d4
	beq.w	.2
	move.w	d4,(a0,d7.w)
	movem.l	(sp)+,d4/d7-a0
	move.w	(printx).w,-(sp)
	subq.w	#1,(printy).w
	movea.l	#BlankLineTxt,a1
	bsr.w	PrintSetupStr
	addq.w	#1,(printy).w
	bsr.w	PrintSetupStr
	addq.w	#1,(printy).w
	bsr.w	PrintSetupStr
	addq.w	#1,(printy).w
	bsr.w	PrintSetupStr
	jsr	(printz).l
	String	-TXMAP1,0,0,0
	move.w	(sp)+,(printx).w
	move.w	(sp)+,(printy).w
	bsr.w	DrawPadIcon
	bra.w	.3
.2
	movem.l	(sp)+,d4/d7-a0
	move.w	(sp)+,(printy).w
.3
	addq.w	#2,a0
	addq.w	#5,(printy).w
	addq.w	#1,d7
	dbf	d4,.loop
	movem.l	(sp)+,d0-d7/a0-a6
	rts

DrawPadIcon	;Draw pad icon d7 (PadIconMaps at PadIconChars), or the pad cursor (PadCursorMap,
	;padcursorchars) at printx $E
	move.w	(printx).w,-(sp)
	move.w	(printy).w,-(sp)
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#PadIconChars,a0
	move.w	d7,d0
	asl.w	#2,d0
	movea.l	(a0,d0.w),a0
	move.w	(a0),d4
	movea.l	#PadIconMaps,a0
	movea.l	(a0,d0.w),a0
	cmpi.w	#$E,(printx).w
	bne.w	.0
	movea.l	#PadCursorMap,a0
	move.w	(padcursorchars).w,d4
.0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	addq.w	#1,(printx).w
	clr.w	d1
	subq.w	#1,(printy).w
	move.w	(a1),d2
	move.w	2(a1),d3
	moveq	#0,d5
	movea.l	#ZeroLong,a2
	jsr	(dobitmap).l
	movem.l	(sp)+,d0-d7/a0-a6
	move.w	(sp)+,(printy).w
	move.w	(sp)+,(printx).w
	rts

PadIconChars	;The RAM words with the chars of each pad icon
	dc.l	padiconchars1,padiconchars2,padiconchars3,padiconchars4

PadIconMaps	;Pad icon bitmaps
	dc.l	PadIconMap1,PadIconMap2,PadIconMap3,PadIconMap4

BlankLineTxt	;A blank line
	String	CC_SetX,0,'                                        '

ControllerSetupScreen	;Build the controller setup screen: vram, fonts, the pad graphics, the screen maps
	;and the team logos of VisTeam / HomeTeam
	move.l	#VBlank_SetOptions,(vbint).l
	move	#$2500,sr
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
	bclr	#5,(disflags).w
	jsr	(setVram).l
	jsr	(orjoy).l
	move.w	#1,d4
	move.w	d4,(smallfontchars).w
	movea.l	#RosterFont+8,a2
	jsr	(DecompressGraphicsPlain).l
	move.l	#RosterFont,(smallfontptr).l
	move.w	d4,(padcursorchars).w
	movea.l	#PadCursorMap+8,a2
	jsr	(DecompressGraphicsPlain).l
	move.w	d4,(padiconchars1).w
	movea.l	#PadIconMap1+8,a2
	jsr	(DecompressGraphicsPlain).l
	move.w	d4,(padiconchars2).w
	movea.l	#PadIconMap2+8,a2
	jsr	(DecompressGraphicsPlain).l
	move.w	d4,(padiconchars3).w
	movea.l	#PadIconMap3+8,a2
	jsr	(DecompressGraphicsPlain).l
	move.w	d4,(padiconchars4).w
	movea.l	#PadIconMap4+8,a2
	jsr	(DecompressGraphicsPlain).l
	jsr	(printsmallz).l
	String	CC_SetMap,1,CC_SetX,0,CC_SetY,0
	moveq	#$28,d0
	moveq	#$1C,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),0,0,0
	movea.l	#ControllerFrameMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	moveq	#$28,d2
	moveq	#$1C,d3
	moveq	#$A,d5
	jsr	(dobitmap).l
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),$B,1,0
	movea.l	#ControllerTitleMap,a0
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
	String	-TXMAP2,0,0,0
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
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),1,4,0
	move.w	(VisTeam).w,d7
	jsr	(DrawSetupTeamBlock).l
	addi.w	#$20,d4
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),$17,4,0
	move.w	(HomeTeam).w,d7
	jsr	(DrawSetupTeamBlock).l
	addi.w	#$20,d4
	rts

PrintSetupStr	;Print String a1 (printsmallz CC_SetAttribute,5,CC_SetMap,1,CC_SetFont,0, then printsmall)
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	a1,-(sp)
	jsr	(printsmallz).l
	String	CC_SetAttribute,5,CC_SetMap,1,CC_SetFont,0
	movea.l	(sp)+,a1
	jsr	(printsmall).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

PrintSetupStrHi	;The same highlighted (CC_SetFont,1)
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	a1,-(sp)
	jsr	(printsmallz).l
	String	CC_SetAttribute,5,CC_SetMap,1,CC_SetFont,1
	movea.l	(sp)+,a1
	jsr	(printsmall).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

ReadAllPads	;Read the 4 pads into TempWord1, TempWord2, TempRawSpd and TempMaxSpd
	jsr	(ReadJoy1).l
	jsr	(nodiag).l
	move.w	d1,(TempWord1).w
	jsr	(ReadJoy2).l
	jsr	(nodiag).l
	move.w	d1,(TempWord2).w
	tst.w	(FourWayPlay).w
	beq.w	.0
	jsr	(ReadJoy3).l
	jsr	(nodiag).l
	move.w	d1,(TempRawSpd).w
	jsr	(ReadJoy4).l
	jsr	(nodiag).l
	move.w	d1,(TempMaxSpd).w
.0
	move.w	(TempWord1).w,d1
	or.w	(TempWord2).w,d1
	tst.w	(FourWayPlay).w
	beq.w	.1
	or.w	(TempRawSpd).w,d1
	or.w	(TempMaxSpd).w,d1
.1
	move.w	d1,(TempLegSpd).w
	rts
