;	The line editor.

LineEditor							;The line editor screen for team a2
	bset	#0,$30(a2)
	bsr.w	SetupLineEditorVideo
	move.w	#$18,(palcount).w
	bclr	#2,(disflags).w
	clr.w	(DispAttribCtr).w
	clr.w	(PlayerScrollCtr).w
	move.w	#1,(setupvalues).w
LineEditorHelp	equ	*	;Print the help line of the line editor
	jsr	(printsmallz).l
	String	$FE,4,$FF,1,$FD,0,$FC
	moveq	#$28,d0
	moveq	#$E,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	st	(PushWidthBuf2+8).w
LineEditorLoop	equ	*	;Line editor main loop: draw the screen and read the pad
	bsr.w	DrawLineEditorBackdrop
	bsr.w	DrawLineIcons
	move.w	#$2500,sr
.loop
	jsr	(vcountwait).l				;per frame: d1 = pressed buttons with auto repeat (Rev B has no wrapper)
	jsr	(SetMenuScroll).l			;per frame: d1 = pressed buttons with auto repeat
	jsr	(ReadMenuJoy).l
	jsr	(ProcessInputWithRepeat).l
	btst	#7,d1					;start: exit menu
	bne.w	LineCursorHelp
	btst	#5,d1					;C: pick a player for this slot
	bne.w	.3
	moveq	#1,d0					;down: next slot
	btst	#1,d1
	bne.w	.move
	moveq	#-$1,d0					;up: previous slot
	btst	#0,d1
	bne.w	.move
	moveq	#8,d0					;right: next line (8 slots per line)
	btst	#3,d1
	bne.w	.move
	moveq	#-$8,d0					;left: previous line
	btst	#2,d1
	beq.s	.loop
.move
	add.w	(setupvalues).w,d0		;d0 = tentative new slot
	tst.w	(OptLine).w
	beq.w	.set
	cmp.w	#1,d0
	blt.s	.loop					;OptLine set: only slots 1-5
	cmp.w	#5,d0
	bgt.s	.loop
.set
	lea	LineCursorTable(pc),a0		;table is indexed by slot + 8
	move.b	8(a0,d0.w),(setupvalues+1).w	;wrap/skip through the table
	move.w	sr,-(sp)
	bsr.w	DrawLineIcons
	move.w	(sp)+,sr
	bra.s	.loop
.3
	jsr	(GetGoalieCount).l
	move.w	d0,d1
	jsr	(GetPlayerCount).l
	sub.w	d1,d0					;d0 = candidates, d1 = first roster index
	subq.w	#1,d0					;count - 1 for dbf
	move.w	d0,(screentimer).w		;last candidate row (also the dbf count)
	clr.w	(PlayerScrollCtr).w
	clr.w	(VertLineScrolling).w
	movea.w	#(CalTeam-M68K_RAM),a0
	clr.w	d2
.fill
	move.b	d1,(a0,d2.w)			;Satt[d2] = roster index d1
	cmp.w	d1,d6					;player now in the slot?
	bne.w	.nc
	move.w	d2,(VertLineScrolling).w	;start the cursor on him
.nc
	addq.w	#1,d1					;next candidate
	addq.w	#1,d2
	dbf	d0,.fill
	move.w	sr,-(sp)
	move.l	a2,-(sp)
	bsr.w	ClearLineEditorTop
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
	jsr	(printbigz).l
	String	$F8,4,1,3,2,'(select player)'
	clr.w	d0
	bsr.w	LineEditorMoveCursor
	move.w	(sp)+,sr
.loop3
	move.w	#$2500,sr
	jsr	(vcountwait).l				;picker input loop
	jsr	(SetMenuScroll).l			;picker input loop
	jsr	(ReadMenuJoy).l
	jsr	(ProcessInputWithRepeat).l
	btst	#7,d1					;start: back to slot cursor
	bne.w	LineEditorLoop
	btst	#5,d1					;C: take this player
	bne.w	LineEditorSetSlot
	moveq	#1,d0
	btst	#1,d1					;down
	bne.w	.6
	btst	#3,d1					;right: next attribute page
	bne.w	.horz
	moveq	#-$1,d0
	btst	#0,d1					;up
	bne.w	.6
	btst	#2,d1					;left: previous attribute page
	bne.w	.horz
	bra.s	.loop3
.horz
	add.w	(DispAttribCtr).w,d0	;change attribute page (not below 0)
	bmi.s	.loop3
	move.w	d0,(DispAttribCtr).w
	bsr.w	PrintAttribHeader
	bra.s	.loop3
.6
	bsr.w	LineEditorMoveCursor
	bra.s	.loop3
LineEditorMoveCursor				;Line editor: move the cursor row by d0 and rescroll the player list
	add.w	(VertLineScrolling).w,d0	;Cursor row 0..screentimer
	bmi.w	.3
	cmp.w	(screentimer).w,d0
	bgt.w	.3
	move.w	d0,(VertLineScrolling).w
	cmp.w	(PlayerScrollCtr).w,d0	;PlayerScrollCtr = first shown row
	bgt.w	.1
	move.w	d0,(PlayerScrollCtr).w	;Cursor above the window
.1
	subq.w	#4,d0
	cmp.w	(PlayerScrollCtr).w,d0
	ble.w	.2
	move.w	d0,(PlayerScrollCtr).w
.2
	bra.w	PrintAttribHeader
.3
	rts
LineEditorSetSlot	equ	*	;Line editor: put the chosen player into the line slot and redraw
	movea.w	#(CalTeam-M68K_RAM),a3
	adda.w	(VertLineScrolling).w,a3
	move.b	(a3),d0
	addq.b	#1,d0					;SetLineSlot wants 1 based
	move.w	(setupvalues).w,d2
	bsr.w	SetLineSlot
	bra.w	LineEditorLoop

PrintAttribHeader					;Player list column header (PAttribColumns page DispAttribCtr), then 6
									;rows of names, selected row highlighted
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),$17,2
.loop
	movea.l	#PAttribColumns,a1
	move.w	(DispAttribCtr).w,d0
	bra.w	.1
.loop2
	adda.w	(a1),a1
	addq.w	#4,a1
.1
	tst.w	(a1)
	dbmi	d0,.loop2
	bpl.w	.2
	subq.w	#1,(DispAttribCtr).w
	bra.s	.loop
.2
	jsr	(printbig).l
	move.l	(a1),d4
	movea.w	#(CalTeam-M68K_RAM),a3
	move.w	(PlayerScrollCtr).w,d2
	move.w	(screentimer).w,d1
	sub.w	d2,d1
	cmp.w	#4,d1
	bls.w	.3
	moveq	#4,d1
.3
	move.w	#4,(printy).w
.loop3
	jsr	(printsmallz).l
	String	$FE,7,$FD,2,$FA,1,'                         ',$FD,2
	cmp.w	(VertLineScrolling).w,d2
	bne.w	.4
	jsr	(printsmallz).l
	String	$FE,6
.4
	clr.w	d0
	move.b	(a3,d2.w),d0
	jsr	(GetNameandAttrib).l
	addq.w	#1,d2
	dbf	d1,.loop3
	rts

DrawLineIcons						;Draw the line icons for the cursor's line, then the selected player box
	moveq	#6,d5
	lea	LineIconSlotTable(pc),a0
	move.w	(setupvalues).w,d0
	lsr.w	#3,d0
	adda.w	d0,a0
	tst.w	(OptLine).w
	beq.w	.1
	subq.w	#1,a0
.1
	move.b	(a0),d0
	cmp.b	(PushWidthBuf2+8).w,d0
	beq.w	.loop
	move.b	d0,(PushWidthBuf2+8).w
	bsr.w	DrawLineIconLabel
.loop
	btst	d5,(PushWidthBuf2+8).w
	beq.w	.2
	bsr.w	DrawLineIcon
.2
	dbf	d5,.loop
	jsr	(printbigz).l
	String	$F8,4,1,$15,$C,'                '
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),$1E,$C
	move.w	d6,d0
	jsr	(FormatPlayerName).l
	move.w	(a1),d0
	lsr.w	#1,d0
	sub.w	d0,(printx).w
	jsr	(printbig).l
	rts
	dc.b	$01
LineIconSlotTable	equ	*	;Table of one byte per line slot, indexed from the line editor cursor (OptLine moves the index by one)
	dc.b	$07,$07,$07,$18,$18,$60,$60
DrawLineIcon						;Draw the icon of line d5 at its LineIconPosTable position
	moveq	#6,d0
	mulu.w	d5,d0
	lea	LineIconPosTable(pc),a0
	adda.w	d0,a0
	tst.w	(OptLine).w
	beq.w	.1
	subq.w	#6,a0
.1
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),0,0
	move.w	(a0),(printx).w
	move.w	lipy(a0),(printy).w
	subq.w	#3,(printy).w
	addq.w	#2,(printx).w
	move.w	d5,d0
	movea.l	#linelist,a1
	jsr	(SkipStrings).l
	bset	#2,(sflags11).w
	jsr	(printbig).l
	jsr	(printbigz).l
	String	' Line'
	jsr	(printsmallz).l
	String	$FE,7,$FF,1
	move.w	(a0),(printx).w
	move.w	d5,d4
	asl.w	#3,d4
	addq.w	#1,d4
	move.w	lipy(a0),(printy).w
	subq.w	#1,(printy).w
	move.w	lipslots(a0),d3
	lea	$184(a2),a3
.loop
	move.w	(a0),(printx).w
	jsr	(printsmallz).l
	String	$FA,1,$FE,7
	clr.w	d0
	move.b	(a3,d4.w),d0
	subq.w	#1,d0
	jsr	(FormatLineName).l
	cmp.w	(setupvalues).w,d4
	bne.w	.2
	move.w	d0,d6
	move.w	(printa).w,d7
	jsr	(printsmallz).l
	String	$FE,6
.2
	jsr	(printsmall).l
	jsr	(printsmallz).l
	String	$FE,7
	addq.w	#1,d4
	dbf	d3,.loop
	rts
DrawLineIconLabel					;Print the label under a line icon
	jsr	(printsmallz).l
	String	$FF,1,$FD,2,$FC,$11
	moveq	#$24,d0
	moveq	#7,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	jsr	(printbigz).l
	String	$F8,4,1,5,$F,'                                '
	move.w	(LineIconPosTable+lipy).l,(printy).l
	move.w	(LineIconPosTable).l,(printx).l
	tst.w	(OptLine).w
	beq.w	.1
	move.w	(LineIconPlayerBoxPos).l,(printx).l
.1
	jsr	(printsmallz).l
	String	$FE,7,$FB,$FD,$FA,0,'LD',$FB,$FE,$FA,1,'RD',$FB,$FE,$FA,1,'LW',$FB,$FE,$FA,1,'C ',$FB,$FE,$FA,1,'RW'
	rts
DrawLineEditorBackdrop	equ	*	;Clear the top of the line editor and draw its background map
	bsr.w	ClearLineEditorTop
	movem.l	d0-d5/a0-a2,-(sp)
	move.l	a2,-(sp)
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),0,0
	movea.l	#LineEditorBgMap2,a1
	adda.l	4(a1),a1
	movea.l	#$772,a2
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
	cmpi.w	#1,(OptLine).w
	beq.w	.2
	jsr	(printcurz).l
	String	$8F,$18,7,'start-exit',$8F,$16,8,'[]-select line'
.2
	movea.l	(sp)+,a2
	movem.l	(sp)+,d0-d5/a0-a2
	rts

ClearLineEditorTop					;Erase the top of map 2
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),0,0
	moveq	#$28,d0
	moveq	#$E,d1
	move.w	#$7FF,d2
	jmp	(eraser).l

ClearMenuFlags						;Clear palfadenew+$5A and palfadenew+$7A
	clr.w	($FFFFBD98).w
	clr.w	($FFFFBDB8).w
	rts
LineIconPlayerBoxPos			;Position of the player box of each line icon (x, y, count)
	dc.w	$0010,$0012,$0004

LineIconPosTable					;Line icons x, y, slot count - 1
	dc.b	$00,$05,$00,$12,$00,$04,$00,$10,$00,$12,$00,$04,$00,$1B,$00,$12
	dc.b	$00,$04,$00,$05,$00,$12,$00,$04,$00,$10,$00,$12,$00,$04,$00,$05
	dc.b	$00,$12,$00,$03,$00,$10,$00,$12,$00,$03,$FF,$FF

LineCursorTable						;The slot after a cursor move, indexed by slot + 8
	dc.b	$01,$01,$02,$03,$04,$05,$19,$01,$01,$01,$02,$03,$04,$05,$19,$01
	dc.b	$09,$09,$0A,$0B,$0C,$0D,$21,$01,$11,$11,$12,$13,$14,$15,$21,$01
	dc.b	$05,$19,$1A,$1B,$1C,$1D,$29,$01,$0D,$21,$22,$23,$24,$25,$31,$01
	dc.b	$1D,$29,$2A,$2B,$2C,$2C,$01,$01,$25,$31,$32,$33,$34,$34,$01,$01
	dc.b	$25,$31,$32,$33,$34,$34,$01,$01
LineCursorHelp	equ	*	;Line cursor help text
	move.w	#$18,(palcount).w
	movea.l	#$200000,a3
	move.w	$28(a2),d0
	addq.w	#1,d0
	cmp.b	1(a3),d0
	beq.w	.3
	jsr	(printcurz).l
	String	$8F,$18,6,'start-exit',$8F,$16,7,'a-default line',$8F,$16,8,'                 ',$8F,$16,9,'c-save line   '
.loop
	jsr	(vcountwait).l
	jsr	(SetMenuScroll).l
	jsr	(ReadMenuJoy).l
	btst	#7,d1
	beq.w	.1
	jmp	(ExitStatsScreen).l
.1
	btst	#6,d1
	beq.w	.2
	jsr	(SetOriginalLines).l
	bra.w	LineEditorHelp
.2
	btst	#5,d1
	beq.s	.loop
	jsr	(SaveTeamLine).l
	bra.w	LineEditorHelp
.3
	jsr	(printcurz).l
	String	$8F,$18,6,'start-exit',$8F,$16,7,'a-default line',$8F,$16,8,'b-load saved line',$8F,$16,9,'c-save line   '
.loop2
	jsr	(vcountwait).l
	jsr	(SetMenuScroll).l
	jsr	(ReadMenuJoy).l
	btst	#7,d1
	beq.w	.4
	rts
.4
	btst	#6,d1
	beq.w	.5
	jsr	(SetOriginalLines).l
	bra.w	LineEditorHelp
.5
	btst	#4,d1
	beq.w	.6
	bsr.w	LoadTeamLine
	bra.w	LineEditorHelp
.6
	btst	#5,d1
	beq.s	.loop2
	jsr	(SaveTeamLine).l
	jmp	(ExitStatsScreen).l

SetLineSlot							;Put player d0 in line slot d2 of team a2 (swap if already in that line)
	movem.l	d0-d2/a0-a1,-(sp)
	lea	$184(a2),a0
	move.w	d2,d1
	andi.w	#$FFF8,d1
	lea	(a0,d1.w),a1
	moveq	#5,d1
.loop
	cmp.b	1(a1,d1.w),d0
	dbeq	d1,.loop
	bne.w	.1
	move.b	(a0,d2.w),1(a1,d1.w)
.1
	move.b	d0,(a0,d2.w)
	movem.l	(sp)+,d0-d2/a0-a1
	rts

LoadTeamLine						;Line editor menu item Load Team Line
	movem.l	d0-d7/a0-a6,-(sp)
	tst.w	(OptLine).w
	beq.w	.1
	movea.l	#$200000,a0
	addq.w	#2,a0
	lea	$184(a2),a1
	move.b	1(a0),(a1)+
	move.b	3(a0),(a1)+
	move.b	5(a0),(a1)+
	move.b	7(a0),(a1)+
	move.b	9(a0),(a1)+
	move.b	$B(a0),(a1)+
	move.b	$D(a0),(a1)+
	move.b	$F(a0),(a1)+
	adda.w	#$10,a0
	adda.w	#$10,a0
	move.w	#$B,d0
.loop
	move.b	1(a0),(a1)+
	move.b	3(a0),(a1)+
	move.b	5(a0),(a1)+
	move.b	7(a0),(a1)+
	addq.w	#8,a0
	dbf	d0,.loop
	bra.w	.2
.1
	move.w	#$D,d0
	movea.l	#$200000,a0
	addq.w	#2,a0
	adda.w	#$10,a0
	lea	$184(a2),a1
.loop2
	move.b	1(a0),(a1)+
	move.b	3(a0),(a1)+
	move.b	5(a0),(a1)+
	move.b	7(a0),(a1)+
	addq.w	#8,a0
	dbf	d0,.loop2
.2
	movem.l	(sp)+,d0-d7/a0-a6
	rts

SaveTeamLine						;Line editor menu item Save Team Line
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#$200000,a0
	move.w	tmteam(a2),d7
	addq.w	#1,d7
	move.w	d7,(a0)+
	lea	tmlines(a2),a1
	move.b	(a1)+,1(a0)
	move.b	(a1)+,3(a0)
	move.b	(a1)+,5(a0)
	move.b	(a1)+,7(a0)
	move.b	(a1)+,9(a0)
	move.b	(a1)+,$B(a0)
	move.b	(a1)+,$D(a0)
	move.b	(a1)+,$F(a0)
	adda.w	#$10,a0
	lea	tmlines(a2),a1
	move.w	#$D,d0
.loop
	move.b	(a1)+,1(a0)
	move.b	(a1)+,3(a0)
	move.b	(a1)+,5(a0)
	move.b	(a1)+,7(a0)
	addq.w	#8,a0
	dbf	d0,.loop
	bclr	#6,(GameFlags).w
	jsr	(MakeSRAMChecksum).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts
	dc.b	$4E,$75,$01,$02,$03,$04,$05,$09,$0A,$0B,$0C,$0D,$11,$12,$13,$14
	dc.b	$15,$19,$1A,$1B,$1C,$1D,$21,$22,$23,$24,$25,$29,$2A,$2B,$2C,$31
	dc.b	$32,$33,$34,$FF
SetupLineEditorVideo	equ	*	;Set the VBint handler, scroll and map addresses for the line editor and load its graphics
	move.l	a2,-(sp)
	bset	#5,(sflags12).w
	move.l	#VBlank_Menus,(VBint).w
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
	movea.l	#EditLinesTitleMap,a0
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
	bsr.w	SaveTeamLineLabel
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
	move.w	#$2500,sr
	movea.l	(sp)+,a2
	rts
SaveTeamLineLabel	equ	*	;Print the label of a saved team line with the second small font
	move.w	(smallfontchars).w,-(sp)
	move.w	(smallfont2chars).w,(smallfontchars).w
	jsr	(printcurz).l
	String	$8F,4,$19,'{}[]-highlight player',$8F,7,$1A,'c-select player to edit'
	move.w	(sp)+,(smallfontchars).w
	rts
CopyStatsPalette	equ	*	;Copy PStatsPal to the palette buffer
	movem.l	a0-a1,-(sp)
	movea.l	#PStatsPal,a0
	movea.l	#$FFFFBD7E,a1
	move.w	#7,d0
.loop2
	move.l	(a0)+,(a1)+
	dbf	d0,.loop2
	movem.l	(sp)+,a0-a1
	rts

FormatLineName						;a1 = mesarea " Last" for player d0 of team a2, space padded, for the line
									;editor slots
	movem.l	d0-d3/a0/a2,-(sp)
	jsr	(GetPlayerNamePointer).l
	movea.w	#(TextBuffer-M68K_RAM),a1
	move.b	#$20,(a1)+				;' '
	move.w	(a0)+,d0				;string length
	lea	-$2(a0,d0.w),a2				;end of the name
.skip
	cmpi.b	#$20,(a0)+				;skip the first name
	bne.s	.skip
.copy
	move.b	(a0)+,(a1)+				;last name
	cmpa.l	a0,a2
	beq.w	.1
	tst.b	(a0)
	bne.s	.copy
	bra.w	.1
.pad
	move.b	#$20,(a1)+				;pad with spaces
.1
	cmpa.w	#$BFFF,a1
	blt.s	.pad
	jsr	(FinalizeTextBuffer).l
	movem.l	(sp)+,d0-d3/a0/a2
	rts

