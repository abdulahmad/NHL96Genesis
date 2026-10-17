;	User name entry and the name log.

NameEntryScreen	;Name entry screen for pad slot a5: the name log, then edit or pick a name with the pad
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	#$EDE,d0
	moveq	#$70,d1
	movea.l	#setupvalues,a0
	jsr	(ReadSRAM).l
	bsr.w	NameEntryGfx
	bsr.w	PrintNameLogRecords
	movea.l	#NameEntrySprites,a0
	jsr	(DrawScreenSprite).l
	jsr	(ReadNameLog).l
	clr.w	(namelogarrows).w
	move.w	#1,(namelogsel).w
	clr.w	d0
	bsr.w	SkipOtherUserName
	movea.l	#NameEntryBuf,a1
	bsr.w	GetLogName
	bsr.w	PrintNameLog
	move.w	#$18,(palcount).w
	bclr	#2,(disflags).w
	clr.w	d4
	bsr.w	SyncLetterCursor
	bsr.w	PrintNameCursor
	bsr.w	LetterGridPos
	move.w	#1,(NameEntryMode).w
	bsr.w	.6
	clr.w	d0
	bra.w	.18
.loop
	bsr.w	GetNameLength
	jsr	(printz).l
	String	$8F,$04,$14
	tst.w	(NameEntryMode).w
	beq.w	.0
	movea.l	#NameEntryBuf,a1
	bsr.w	PrintNameField
	bsr.w	PrintNamePrompt
	bra.w	.1
.0
	move.w	(namelogsel).w,d0
	cmp.w	(namelogarrows).w,d0
	beq.w	.1
	bsr.w	PrintNameLog
.1
	move	#$2500,sr
.frame
	move.w	(vcount).w,d0
.loop2
	cmp.w	(vcount).w,d0
	beq.s	.loop2
	jsr	(SetMenuScroll).l
	cmpa.l	#pad1user,a5
	beq.w	.2
	cmpa.l	#pad2user,a5
	beq.w	.8
	cmpa.l	#pad3user,a5
	beq.w	.10
	jsr	(ReadJoy4).l
	jsr	(ProcessInputWithRepeat).l
	tst.w	d1
	beq.s	.frame
	bra.w	.3
.10
	jsr	(ReadJoy3).l
	jsr	(ProcessInputWithRepeat).l
	tst.w	d1
	beq.s	.frame
	bra.w	.3
.8
	jsr	(ReadJoy2).l
	jsr	(ProcessInputWithRepeat).l
	tst.w	d1
	beq.s	.frame
	bra.w	.3
.2
	jsr	(ReadJoy1).l
	jsr	(ProcessInputWithRepeat).l
	tst.w	d1
	beq.s	.frame
.3
	btst	#7,d1
	bne.w	.nameEntryExit
	tst.w	(NameEntryMode).w
	bne.w	.11
	move.w	#1,d0
	btst	#1,d1
	bne.w	.13
	move.w	#$FFFF,d0
	btst	#0,d1
	bne.w	.13
	btst	#4,d1
	beq.w	.loop
	bsr.w	.6
	clr.w	d0
	bra.w	.13
.11
	moveq	#-1,d0
	btst	#6,d1
	bne.w	.18
	neg.w	d0
	btst	#5,d1
	bne.w	.18
	btst	#3,d1
	bne.w	.19
	neg.w	d0
	btst	#2,d1
	bne.w	.19
	moveq	#$A,d0
	btst	#1,d1
	bne.w	.19
	neg.w	d0
	btst	#0,d1
	bne.w	.19
	btst	#4,d1
	beq.w	.loop
	bsr.w	.6
	bra.w	.loop
.13
	add.w	d0,(namelogsel).w
.loop4
	cmpi.w	#7,(namelogsel).w
	ble.w	.15
	move.w	#1,(namelogsel).w
.15
	tst.w	(namelogsel).w
	bne.w	.16
	move.w	#7,(namelogsel).w
.16
	bsr.w	SkipOtherUserName
	beq.s	.loop4
	movea.l	#NameEntryBuf,a1
	bsr.w	GetLogName
	tst.w	(NameEntryMode).w
	bne.w	.4
	jsr	(NameEntryHelp).l
	bra.w	.loop
.4
	jsr	(printcurz).l
	String	$8F,$03,$15
	add.w	d4,(printx).w
	jsr	(printcurz).l
	String	'   '
	bsr.w	LetterGridPos
	bsr.w	PrintCurLetter
	bsr.w	SyncLetterCursor
	move.w	d4,d0
	neg.w	d0
	bra.w	*+4
.18
	add.w	d4,d0
	cmp.w	#8,d0
	bhi.w	.loop
	move.w	d0,d4
	bsr.w	PrintNameCursor
	movea.l	#NameEntryBuf,a0
	clr.w	d0
	cmpi.b	#$2D,(a0,d4.w)
	beq.w	.19
	move.b	(a0,d4.w),d0
	ext.w	d0
	bsr.w	FindLetter
	sub.w	d5,d0
.19
	add.w	d5,d0
	cmp.w	#$1D,d0
	bhi.w	.loop
	move.w	d0,-(sp)
	bsr.w	LetterGridPos
	bsr.w	PrintCurLetter
	move.w	(sp)+,d5
	bsr.w	LetterGridPos
	move.w	(smallfontchars).w,-(sp)
	tst.w	(NameEntryMode).w
	beq.w	.5
	move.w	(smallfont2chars).w,(smallfontchars).w
.5
	bsr.w	PrintCurLetter
	move.w	(sp)+,(smallfontchars).w
	jsr	(printsmallz).l
	String	$FE,$07
	movea.l	#NameEntryBuf,a0
	movea.l	#CreateLetterGrid,a1
	move.b	(a1,d5.w),d0
	move.b	d0,(a0,d4.w)
	bra.w	.loop
.nameEntryExit
	bsr.w	StoreUserName
	movem.l	(sp)+,d0-d7/a0-a6
	rts
.6
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(printz).l
	String	$8F,$01,$11
	move.w	#$15,d0
	move.w	#7,d1
	move.w	#$7FF,d2	;blank char
	jsr	(eraser).l
	jsr	(printz).l
	String	$8F,$17,$0D
	move.w	#$10,d0
	move.w	#$B,d1
	move.w	#$7FF,d2	;blank char
	jsr	(eraser).l
	bchg	#0,(NameEntryMode+1).w
	bne.w	.20
	jsr	(printz).l
	String	$8F,$1A,$0F
	movea.l	#CreateLetterGrid,a0
	moveq	#2,d0
.7
	moveq	#9,d1
	movea.l	#mesarea,a1
	move.w	#$C,(a1)+
.9
	move.b	(a0)+,(a1)+
	dbf	d1,.9
	movea.w	#(mesarea-M68K_RAM),a1
	jsr	(printcur).l
	addq.w	#1,(printy).w
	subi.w	#$A,(printx).w
	dbf	d0,.7
	jsr	(printcurz).l
	String	$8F,$17,$13,'{}[]=new letter'
	move.w	#$17,(printx).w
	addq.w	#1,(printy).w
	move.w	(printx).w,-(sp)
	jsr	(printcurz).l
	String	'C=enter letter'
	move.w	(sp),(printx).w
	addq.w	#1,(printy).w
	jsr	(printcurz).l
	String	'A=go back'
	move.w	(sp),(printx).w
	addq.w	#1,(printy).w
	jsr	(printcurz).l
	String	'B=cancel'
	move.w	(sp)+,(printx).w
.12
	addq.w	#1,(printy).w
.14
	jsr	(printcurz).l
	String	'START=done'
.17
	movem.l	(sp)+,d0-d7/a0-a6
	rts
.20
	movea.l	#NameEntryBuf,a1
	bsr.w	GetLogName
.21
	jsr	(printz).l
	String	$8F,$01,$11
	move.w	#$15,d0
	move.w	#7,d1
.22
	move.w	#$7FF,d2
	jsr	(eraser).l
.23
	jsr	(printz).l
	String	$8F,$1A,$0F
	move.w	#$A,d0
	move.w	#3,d1
.24
	move.w	#$7FF,d2
.25
	jsr	(eraser).l
	bsr.w	NameEntryHelp
	bra.s	.17

NameEntryHelp	;Name entry: name log key help text
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(printcurz).l
	String	$8F,$03,$13,'{}=select name'
	jsr	(printcurz).l
	String	$8F,$03,$14,'b=enter/edit name'
	jsr	(printcurz).l
	String	$8F,$03,$15,'start=use name'
	movem.l	(sp)+,d0-d7/a0-a6
	rts

PrintNamePrompt	;Name entry: print EnterNameTxt for an empty name log slot namelogsel, else SelectNameTxt
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(namelogsel).w,d0
	mulu.w	#$A,d0
	movea.l	#namelog,a0
	movea.l	#EnterNameTxt,a1
	tst.b	(a0,d0.w)
	beq.w	.1
.0
	movea.l	#SelectNameTxt,a1
.1
	jsr	(printcur).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

SyncLetterCursor	;Name entry: grid cursor d5 = grid index of the current letter (FindLetter), 0 if not in the grid
	movem.l	d0-d4/a0-a6,-(sp)
	move.b	(NameEntryBuf).w,d0
	bsr.w	FindLetter
.3
	cmp.w	#$1E,d0
.4
	blt.w	.1
	clr.w	d5
.0
	bra.w	.2
.1
	move.w	d0,d5
	movea.l	#CreateLetterGrid,a0
	move.b	(a0,d5.w),(NameEntryBuf).w
.2
	movem.l	(sp)+,d0-d4/a0-a6
	rts

FindLetter	;d0 = index of letter d0 in the letter grid, $1E when not found
	movem.l	d1-d3/a0-a6,-(sp)
	movea.l	#CreateLetterGrid,a0
	move.b	d0,d1
	clr.w	d0
	move.w	#$1E,d3
.0
	cmp.b	(a0,d0.w),d1
	beq.w	.x
	addq.w	#1,d0
	dbf	d3,.0
	move.w	#$1E,d0
.x
	movem.l	(sp)+,d1-d3/a0-a6
	rts

PrintNameCursor	;Name entry: position the name cursor, " < " with NameEntryMode set
	jsr	(printz).l
	String	$8F,$03,$15
	add.w	d4,(printx).w
	tst.w	(NameEntryMode).w
	beq.w	rtsNameCursor
	jsr	(printcurz).l
	String	' < '

rtsNameCursor	;Shared rts of PrintNameCursor
	rts

PrintCurLetter	;Name entry: print grid letter d5 when the cursor is on
	tst.w	(NameEntryMode).w
	beq.s	rtsNameCursor
	movea.l	#ThreeStars,a1
	move.w	#4,(a1)
	move.b	#0,3(a1)
	movea.l	#CreateLetterGrid,a0
	move.b	(a0,d5.w),d0
	move.b	d0,2(a1)
	jmp	printcur

LetterGridPos	;Name entry: printx / printy of grid letter d5 (10 a row)
	jsr	(printz).l
	String	$8F,$1A,$0F
	move.w	d5,d0
	ext.l	d0
	divu.w	#$A,d0
	add.w	d0,(printy).w
	swap	d0
	add.w	d0,(printx).w
	rts

EnterNameTxt	;Name entry prompt for an empty name log slot
	String	$8F,$01,$12,'  Enter new name: '

SelectNameTxt	;Name entry prompt for a used name log slot
	String	$8F,$01,$12,'Select or replace:'

PrintNameLog	;Name entry: print the 7-row name log list
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(NameEntryLen).w,-(sp)
	move.w	(namelogsel).w,-(sp)
	move.w	(namelogsel).w,d6
	jsr	(printcurz).l
	String	$8F,$01,$0A
	move.w	#6,d7
	move.w	#1,(namelogsel).w
	movea.l	#$FFFFBF54,a1
.0
	bsr.w	GetLogName
	move.w	(printx).w,-(sp)
	move.w	(smallfontchars).w,-(sp)
	cmp.w	(namelogsel).w,d6
	bne.w	.1
	move.w	(smallfont2chars).w,(smallfontchars).w
.1
	bsr.w	PrintNameField
	move.w	(sp)+,(smallfontchars).w
	jsr	(printsmallz).l
	String	$FE,$07
	move.w	(sp)+,(printx).w
	addq.w	#1,(printy).w
	addq.w	#1,(namelogsel).w
	dbf	d7,.0
	move.w	(sp)+,(namelogsel).w
	move.w	(sp)+,(NameEntryLen).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts

GetNameLength	;Name entry: NameEntryLen = length of the name in the entry buffer
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#9,d3
	movea.l	#NameEntryBuf,a0
	clr.w	(NameEntryLen).w
.loop
	cmpi.b	#$2D,(a0)
	beq.w	.x
	tst.b	(a0)+
	beq.w	.x
	addq.w	#1,(NameEntryLen).w
	dbf	d3,.loop
.x
	movem.l	(sp)+,d0-d7/a0-a6
	rts

PrintNameField	;Name entry: print the name field at a1 ("-" pads) and the current letter when the cursor is on
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#ThreeStars,a0
	move.w	(NameEntryLen).w,d0
	move.w	#0,d3
	move.w	#$C,(a0)+
.0
	move.b	(a1,d3.w),d1
	cmp.w	(NameEntryLen).w,d3
	blt.w	.3
	move.b	#$2D,d1
	cmp.w	#9,d3
	bne.w	.3
	move.b	#$20,d1
.3
	move.b	d1,(a0)+
	addq.w	#1,d3
	cmp.w	#9,d3
	blt.s	.0
	movea.l	#ThreeStars,a1
	move.b	#$20,$B(a1)
	jsr	(printcur).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

CreateLetterGrid	;Name entry letter grid (the create player screen uses it too)
	dc.b	$41,$42,$43,$44,$45,$46,$47,$48,$49,$4A,$4B,$4C,$4D,$4E,$4F,$50
	dc.b	$51,$52,$53,$54,$55,$56,$57,$58,$59,$5A,$2E,$31,$32,$20,$2D,$FF

GetLogName	;Copy name log entry namelogsel to a1 ("-" for blanks), NameEntryLen = its length
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#namelog,a0
	move.w	(namelogsel).w,d2
	mulu.w	#$A,d2
	move.w	#0,(NameEntryLen).w
	move.w	#9,d3
.0
	move.b	(a0,d2.w),d0
	beq.w	.1
	bra.w	.2
.1
	move.b	#$2D,d0
	subq.w	#1,(NameEntryLen).w
.2
	move.b	d0,(a1)+
	addq.w	#1,(NameEntryLen).w
	addq.w	#1,d2
	dbf	d3,.0
	movem.l	(sp)+,d0-d7/a0-a6
	rts

StoreUserName	;Name entry: store the edited name in the name log slot; if changed, save and clear its old record
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#namelog,a0
	move.w	(namelogsel).w,d0
	mulu.w	#$A,d0
	adda.w	d0,a0
	movea.l	#NameEntryBuf,a1
	move.w	#9,d4
.loop
	cmpi.b	#$2D,(a1)
	bne.w	.1
	move.b	#0,(a1)
.1
	move.b	(a1)+,d1
	cmp.b	(a0)+,d1
	bne.w	.2
	dbf	d4,.loop
	bra.w	.0
.2
	movea.l	#namelog,a0
	move.w	(namelogsel).w,d0
	mulu.w	#$A,d0
	adda.w	d0,a0
	movea.l	#NameEntryBuf,a1
	move.w	#9,d4
.loop2
	move.b	(a1)+,d1
	cmp.b	#$2D,d1
	bne.w	.4
	move.b	#0,d1
.4
	move.b	d1,(a0)+
	dbf	d4,.loop2
	jsr	(WriteNameLog).l
	jsr	(ClearNameRecord).l
	jsr	(MakeSRAMChecksum).l
.0
	movea.l	#pad1user,a5
	tst.w	(nameentryvis).w
	beq.w	.3
	movea.l	#pad2user,a5
.3
	tst.b	(NameEntryBuf).w
	bne.w	.6
	clr.w	(namelogsel).w
.6
	move.w	(namelogsel).w,(a5)
	movem.l	(sp)+,d0-d7/a0-a6
	rts

ClearNameRecord	;Clear the 16-byte record of name slot namelogsel in save RAM ($ECE + slot * 16)
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	#$ECE,d0
	move.w	(namelogsel).w,d3
	asl.w	#4,d3
	ext.l	d3
	add.l	d3,d0
	moveq	#$10,d1
	movea.l	#ThreeStars,a0
	jsr	(ReadSRAM).l
	move.l	a0,-(sp)
	move.w	#$F,d3
.loop3
	clr.b	(a0)+
	dbf	d3,.loop3
	movea.l	(sp)+,a0
	jsr	(WriteSRAM).l
	jsr	(MakeSRAMChecksum).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

UserNameEntry	;With user records on (OptUserRec 0): the name entry (NameEntryScreen) for each pad in use
	tst.w	(OptUserRec).w
	bne.w	.x
	clr.w	(pad1user).w
	clr.w	(pad2user).w
	clr.w	(pad3user).w
	clr.w	(pad4user).w
	tst.w	(cont1team).w
	beq.w	.0
	move.w	(cont1team).w,(nameentryvis).w
	subq.w	#1,(nameentryvis).w
	movea.l	#pad1user,a5
	jsr	(NameEntryScreen).l
.0
	tst.w	(cont2team).w
	beq.w	.1
	move.w	(cont2team).w,(nameentryvis).w
	subq.w	#1,(nameentryvis).w
	movea.l	#pad2user,a5
	jsr	(NameEntryScreen).l
.1
	tst.w	(cont3team).w
	beq.w	.2
	move.w	(cont3team).w,(nameentryvis).w
	subq.w	#1,(nameentryvis).w
	movea.l	#pad3user,a5
	jsr	(NameEntryScreen).l
.2
	tst.w	(cont4team).w
	beq.w	.3
	move.w	(cont4team).w,(nameentryvis).w
	subq.w	#1,(nameentryvis).w
	movea.l	#pad4user,a5
	jsr	(NameEntryScreen).l
.3
	bset	#0,(sflags10).w
	move.w	#1,d0
	bsr.w	CountTeamPads
	cmp.w	#1,d2
	ble.w	.4
	bclr	#0,(sflags10).w
.4
	move.w	#2,d0
	bsr.w	CountTeamPads
	cmp.w	#1,d2
	ble.w	.x
	bclr	#0,(sflags10).w
.x
	rts

CountTeamPads	;d2 = the number of pads (cont1team ... cont4team) on team d0 (1 home, 2 away)
	clr.w	d2
	cmp.w	(cont1team).w,d0
	bne.w	.0
	addq.w	#1,d2
.0
	cmp.w	(cont2team).w,d0
	bne.w	.1
	addq.w	#1,d2
.1
	cmp.w	(cont3team).w,d0
	bne.w	.2
	addq.w	#1,d2
.2
	cmp.w	(cont4team).w,d0
	bne.w	.x
	addq.w	#1,d2
.x
	rts

SkipOtherUserName	;Step namelogsel past the name the other team's pad picked, in the direction of the word on the stack
	movem.w	d0,-(sp)
	move.w	(pad2user).w,d0
	tst.w	(nameentryvis).w
	beq.w	.0
	move.w	(pad1user).w,d0
.0
	cmp.w	(namelogsel).w,d0
	bne.w	.2
	move.w	#1,d0
	tst.w	(sp)
	bpl.w	.1
	move.w	#$FFFF,d0
.1
	add.w	d0,(namelogsel).w
	clr.w	d0
.2
	movem.w	(sp)+,d0
	rts

NameEntryGfx	;Name entry: vram, fonts, the screen bitmaps, the pad icon (NameEntryPadIcons), the team block and the
	;heading
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
	movea.l	#NameEntrySprites,a1
	jsr	(LoadScreenSprite).l
	move.w	d4,(smallfontchars).w
	movea.l	#RosterFont+8,a2
	jsr	(DecompressGraphicsPlain).l
	move.w	d4,(smallfont2chars).w
	movea.l	#RosterFont+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$01,$23,$AB,$CE,$89,$AB,$CD,$EF	;remap table
	move.l	#RosterFont,(smallfontptr).w
	move.w	d4,(BigFontChars).w
	movea.l	#BigFontMap4+8,a2
	jsr	(DecompressGraphicsPlain).l
	bset	#2,(sflags11).w
	jsr	(printsmallz).l
	String	$FF,$01,$FD,$00,$FC
	moveq	#$28,d0
	moveq	#$1C,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	jsr	(printcurz).l
	String	$BF,$00,$00
	movea.l	#NameEntryBgMap,a0
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
	jsr	(printcurz).l
	String	$BF,$0B,$01
	movea.l	#NameEntryTitleMap,a0
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
	jsr	(printcurz).l
	String	$FE,$00,$00
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
	movea.l	a5,a0
	suba.w	#$D248,a0
	move.l	a0,d0
	movea.l	#NameEntryPadIcons,a0
	add.w	d0,d0
	movea.l	(a0,d0.w),a0
	jsr	(printz).l
	String	$BF,$1A,$09
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	moveq	#$A,d2
	moveq	#4,d3
	moveq	#2,d5
	jsr	(dobitmap).l
	jsr	(printz).l
	String	$BF,$17,$05
	move.w	(HomeTeam).w,d7
	tst.w	(nameentryvis).w
	beq.w	.0
	move.w	(VisTeam).w,d7
.0
	jsr	(DrawSetupTeamBlock).l
	jsr	(printbigz).l
	String	$F8,$04,$01,$04,$05,'name',$FD,$0C,'w   l   t'
	rts

NameEntryPadIcons	;NameEntryGfx: the pad icon map of each pad slot
	dc.l	PadIconMap1,PadIconMap2,PadIconMap3,PadIconMap4

PrintNameLogRecords	;Name entry: the record columns of the 7 name log rows (ThreeStars)
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#setupvalues,a0
	move.w	#6,d7
	jsr	(printz).l
	String	$8F,$0B,$0A
.0
	move.w	8(a0),d0
.1
	cmp.w	#$3E8,d0
	blt.w	.2
	subi.w	#$3E8,d0
	bra.s	.1
.2
	move.w	#3,d1
	jsr	(PushNumberWidth).l
	move.w	#$B,(printx).w
	jsr	(printcur).l
	move.w	$C(a0),d0
.3
	cmp.w	#$3E8,d0
	blt.w	.4
	subi.w	#$3E8,d0
	bra.s	.3
.4
	move.w	#3,d1
	jsr	(PushNumberWidth).l
	move.w	#$13,(printx).w
	jsr	(printcur).l
	move.w	$A(a0),d0
	sub.w	$C(a0),d0
	sub.w	8(a0),d0
	bpl.w	.5
	clr.w	d0
.5
	cmp.w	#$3E8,d0
	blt.w	.6
	subi.w	#$3E8,d0
	bra.s	.5
.6
	move.w	#3,d1
	jsr	(PushNumberWidth).l
	move.w	#$F,(printx).w
	jsr	(printcur).l
	adda.w	#$10,a0
	addq.w	#1,(printy).w
	dbf	d7,.0
	movem.l	(sp)+,d0-d7/a0-a6
	rts

