;	The create-player screen and the created-player list.

CreatePlayer						;The create player screen (roster menu item Create Players) Code the
	movem.l	d0-d7/a0-a6,-(sp)
	bclr	#6,(sflags12).w
	bclr	#7,(sflags13).w
	clr.w	d0
	move.b	(SaveRAM+$1BB9).l,d0
	cmp.w	#$14,d0
	blt.w	CreatePlayerInit
	bset	#7,(sflags13).w

.redraw								;Redraw the create screen: reset the field row and the mode, read and draw
									;the name list
CreatePlayerInit	equ	*
	clr.w	(NameEntryMode).w
	clr.w	(NameEntryMode+2).w
	clr.w	(carddelay).w
	bsr.w	SetupCreateScreenVideo
	movea.l	#CreateSprites,a0
	jsr	(DrawScreenSprite).l
	jsr	(PStatsPalette).l
	move.w	#$18,(palcount).w
	bclr	#2,(disflags).w
	bsr.w	ReadCreatedPlayers
	tst.w	($FFFF55F0).l
	bne.w	.1
	bset	#6,(sflags12).w
	move.w	#1,($FFFF55F0).l
	bra.w	.3
.1
	clr.w	(namelogarrows).w
	move.w	#1,(namelogsel).w
	move.w	($FFFF55F0).l,d0
	subq.w	#1,d0
	move.w	d0,($FFFF55F8).l
	subq.w	#2,d0
	bpl.w	.2
	clr.w	d0
.2
	move.w	d0,($FFFF55F4).l
	move.w	($FFFF55F8).l,d0
	addq.w	#1,d0
	move.w	d0,(namelogsel).w
	movea.l	#NameEntryBuf,a1
	bsr.w	GetCreateName
	bsr.w	ReadSavedNameFromSRAM
.3
	bsr.w	DrawNameEntryPrompt
	clr.w	d4
	clr.w	(NameEntryMode).w
	clr.w	(NameEntryMode+2).w
	clr.w	d0
	bra.w	NameEntryMoveColumn
CreatePlayerLoop	equ	*
	bsr.w	DrawNameEntryScreen
	move.w	#$2500,sr
CreatePlayerWaitPad	equ	*
	move.w	(Vcount).w,d0
.loop
	cmp.w	(Vcount).w,d0
	beq.s	.loop
	jsr	(SetMenuScroll).l
	jsr	(FindHeldMenuPad).l
	jsr	(ProcessInputWithRepeat).l
	tst.w	d1
	beq.s	CreatePlayerWaitPad
	btst	#7,(sflags13).w
	bne.w	.4
	btst	#6,(sflags12).w
	beq.w	.5
.4
	btst	#7,d1
	beq.s	CreatePlayerWaitPad
	bra.w	CreateNameDoneReturn
.5
	tst.w	(NameEntryMode).w
	bne.w	.7
	move.w	#1,d0
	btst	#1,d1
	bne.w	CreateListMove
	move.w	#$FFFF,d0
	btst	#0,d1
	bne.w	CreateListMove
	btst	#6,d1
	beq.w	.6
	clr.w	d4
	clr.w	d5
	bsr.w	ToggleNameEntryCase
	clr.w	d0
	bra.w	CreateListMove
.6
	btst	#4,d1
	bne.w	CreateNameDoneReturn
	bra.w	CreatePlayerLoop
.7
	movea.l	#CreateFieldJumps,a0
	move.w	(NameEntryMode+2).w,d0
	asl.w	#2,d0
	movea.l	(a0,d0.w),a0
	jmp	(a0)

CreateFieldJumps	equ	*			;Create player: the table of field routines
.fieldjumps							;Field routine of each create row, then: next field, after the last one
									;finish the name
	dc.l	.namefield,.posfield,.handfield,.weightfield,.jerseyfield
CreatePlayerNextEntry	equ	*
	addq.w	#1,(NameEntryMode+2).w
	cmpi.w	#5,(NameEntryMode+2).w
	blt.w	CreatePlayerLoop
	jmp	(CreateNameDone).l

.posfield							;Position field: left / right change the position slot 0-5 Code the
	btst	#7,d1
	bne.s	CreatePlayerNextEntry
	btst	#4,d1
	bne.w	CreateNameDoneReturn
	btst	#2,d1
	beq.w	.8
	move.b	($FFFF5608).l,d0
	ext.w	d0
	subq.w	#1,d0
	bmi.w	CreatePlayerWaitPad
	move.b	d0,($FFFF5608).l
	bra.w	CreatePlayerLoop
.8
	btst	#3,d1
	beq.w	CreatePlayerWaitPad
	move.b	($FFFF5608).l,d0
	ext.w	d0
	addq.w	#1,d0
	cmp.w	#5,d0
	bgt.w	CreatePlayerWaitPad
	move.b	d0,($FFFF5608).l
	bra.w	CreatePlayerLoop

.handfield							;Hand field: left / right toggle the shooting hand Code the listing does
	btst	#7,d1
	bne.s	CreatePlayerNextEntry
	btst	#4,d1
	bne.w	CreateNameDoneReturn
	btst	#2,d1
	beq.w	.9
.loop2
	eori.b	#1,($FFFF5604).l
	bra.w	CreatePlayerLoop
.9
	btst	#3,d1
	beq.w	CreatePlayerWaitPad
	bra.s	.loop2

.weightfield						;Weight field: left / right change the weight
	btst	#7,d1
	bne.w	CreatePlayerNextEntry
	btst	#4,d1
	bne.w	CreateNameDoneReturn
	btst	#2,d1
	beq.w	.10
	move.b	($FFFF5601).l,d0
	lsr.w	#4,d0
	andi.w	#$F,d0
	beq.w	CreatePlayerWaitPad
	subq.b	#1,d0
.loop3
	lsl.b	#4,d0
	andi.w	#$F0,d0
	andi.b	#$F,($FFFF5601).l
	or.b	d0,($FFFF5601).l
	bra.w	CreatePlayerLoop
.10
	btst	#3,d1
	beq.w	CreatePlayerWaitPad
	move.b	($FFFF5601).l,d0
	lsr.w	#4,d0
	andi.w	#$F,d0
	cmp.w	#$F,d0
	beq.w	CreatePlayerWaitPad
	addq.b	#1,d0
	bra.s	.loop3

.jerseyfield						;Jersey field: left / right change the BCD jersey number Code the listing
	btst	#7,d1
	bne.w	CreatePlayerNextEntry
	btst	#4,d1
	bne.w	CreateNameDoneReturn
	btst	#2,d1
	beq.w	.12
	move.b	($FFFF5600).l,d0
	beq.w	CreatePlayerWaitPad
	move.b	d0,d1
	andi.w	#$F,d1
	bne.w	.11
	subi.b	#$10,d0
	ori.b	#9,d0
	bra.w	.loop4
.11
	subq.b	#1,d0
.loop4
	move.b	d0,($FFFF5600).l
	bra.w	CreatePlayerLoop
.12
	btst	#3,d1
	beq.w	CreatePlayerWaitPad
	move.b	($FFFF5600).l,d0
	cmp.b	#$99,d0
	beq.w	CreatePlayerWaitPad
	move.b	d0,d1
	andi.w	#$F,d1
	cmp.b	#9,d1
	bne.w	.13
	addi.b	#$10,d0
	andi.b	#$F0,d0
	bra.s	.loop4
.13
	addq.b	#1,d0
	bra.s	.loop4

.namefield							;Name field: the pads edit the name (grid), start checks it
									;(BuildEnteredName) and goes to the next field
	moveq	#-$1,d0
	btst	#7,d1
	beq.w	.15
	bsr.w	BuildEnteredName
	bmi.w	.14
	bsr.w	FindGridLetterMsg2
	jsr	(printsmallz).l
	String	$FE,7,$FF,1,$FD,$18,$FC,$13,'[]-selection',$FD,$18,$FA,1,'start=next'
	bra.w	CreatePlayerNextEntry
.14
	bsr.w	FindGridLetterMsg1
	jsr	(printsmallz).l
	String	$FE,7,$FF,1,$FD,$18,$FC,$13,'bad name entry.',$FD,$18,$FA,1,'any button',$FD,$18,$FA,1,'to continue.'
.loop5
	bsr.w	WaitMenuFrame
	jsr	(FindHeldMenuPad).l
	jsr	(ProcessInputWithRepeat).l
	tst.w	d1
	beq.s	.loop5
	bsr.w	FindGridLetterMsg1
	bsr.w	FindGridLetterMsg3
	bra.w	CreatePlayerLoop
.15
	btst	#6,d1
	bne.w	NameEntryMoveColumn
	neg.w	d0
	btst	#5,d1
	bne.w	NameEntryMoveColumn
	btst	#3,d1
	bne.w	CreateListMoveDraw
	neg.w	d0
	btst	#2,d1
	bne.w	CreateListMoveDraw
	moveq	#$A,d0
	btst	#1,d1
	bne.w	CreateListMoveDraw
	neg.w	d0
	btst	#0,d1
	bne.w	CreateListMoveDraw
	btst	#4,d1
	beq.w	CreatePlayerLoop
	bra.w	CreateNameDoneReturn

CreateListMove						;CreatePlayer: move in the name list
	add.w	d0,(namelogsel).w
	move.w	(namelogsel).w,d1
	cmp.w	($FFFF55F0).l,d1
	ble.w	.1
	sub.w	d0,(namelogsel).w
.1
	tst.w	(namelogsel).w
	bne.w	.2
	sub.w	d0,(namelogsel).w
.2
	move.w	(namelogsel).w,d0
	subq.w	#1,d0
	cmp.w	($FFFF55F4).l,d0
	bge.w	.3
	subq.w	#1,($FFFF55F4).l
	subq.w	#1,($FFFF55F8).l
	bsr.w	DrawNameEntryPrompt
.3
	cmp.w	($FFFF55F8).l,d0
	ble.w	.4
	addq.w	#1,($FFFF55F4).l
	addq.w	#1,($FFFF55F8).l
	bsr.w	DrawNameEntryPrompt
.4
	movea.l	#NameEntryBuf,a1
	bsr.w	GetCreateName
	bsr.w	ReadSavedNameFromSRAM
	tst.w	(NameEntryMode).w
	bne.w	.5
	bra.w	CreatePlayerLoop
.5
	jsr	(printcurz).l
	String	$8F,1,$C
	add.w	d4,(printx).w
	jsr	(printcurz).l
	String	' '
	bsr.w	FixFirstLetter
	move.w	d4,d0
	neg.w	d0
	bra.w	NameEntryMoveColumn
NameEntryMoveColumn	equ	*
	add.w	d4,d0
	cmp.w	#$11,d0
	bhi.w	CreatePlayerLoop
	move.w	d0,d4
	movea.l	#NameEntryBuf,a0
	clr.w	d0
	cmpi.b	#$2D,(a0,d4.w)
	beq.w	CreateListMoveDraw
	move.b	(a0,d4.w),d0
	ext.w	d0
	bsr.w	FindGridLetter
	sub.w	d5,d0
CreateListMoveDraw	equ	*	;Redraw the grid letters after a cursor move
	add.w	d5,d0
	cmp.w	#$1D,d0
	bhi.w	CreatePlayerLoop
	move.w	d0,-(sp)
	bsr.w	PositionGridCursor
	jsr	(printsmallz).l
	String	$FE,7
	moveq	#1,d2
	bsr.w	PrintGridLetter
	move.w	(sp)+,d5
	bsr.w	PositionGridCursor
	tst.w	(NameEntryMode).w
	beq.w	.6
.6
	bsr.w	PrintGridLetter
	movea.l	#NameEntryBuf,a0
	movea.l	#CreateLetterGrid,a1
	move.b	(a1,d5.w),d0
	move.b	d0,(a0,d4.w)
	bra.w	CreatePlayerLoop

CreateNameDone						;All fields done: SaveCreateName (fail: redraw), InitCreateRecord, the
									;checksum, then ModifyRatings
	bsr.w	SaveCreateName
	bmi.w	.1
	bsr.w	InitCreateRecord
	bclr	#6,(GameFlags).w
	jsr	(MakeSRAMChecksum).l
	jmp	(ModifyRatings).l
.1
	jmp	(CreatePlayerInit).l
CreateNameDoneReturn	equ	*	;Restore the registers and return
	movem.l	(sp)+,d0-d7/a0-a6
CreateNameDoneExit	equ	*	;Shared return of CreateNameDone
	rts
ToggleNameEntryCase	equ	*	;Toggle the upper / lower case of the name entry and redraw the letter grid
	movem.l	d0-d7/a0-a6,-(sp)
	bchg	#0,(NameEntryMode+1).w
	bne.w	.2
	bsr.w	DrawLetterGrid
.loop
	movem.l	(sp)+,d0-d7/a0-a6
	rts
.2
	movea.l	#NameEntryBuf,a1
	bsr.w	GetCreateName
	bra.s	.loop

PrintGridLetter						;If grid mode, print letter d5 of the grid table (cursor letter) Code the
	tst.w	(NameEntryMode).w
	beq.s	CreateNameDoneExit
	movea.l	#CalTeam,a1
	move.w	#4,(a1)
	move.b	#0,3(a1)
	movea.l	#CreateLetterGrid,a0
	move.b	(a0,d5.w),d0
	move.b	d0,2(a1)
	jmp	(printcur).l
PositionGridCursor	equ	*	;Print the grid cursor at the letter d5
	jsr	(printcurz).l
	String	$AF,$1A,$F
	move.w	d5,d0
	ext.l	d0
	divu.w	#$A,d0
	add.w	d0,(printy).w
	swap	d0
	add.w	d0,(printx).w
	moveq	#1,d0
	moveq	#1,d1
	rts

FixFirstLetter						;Normalize first letter of name buffer to a
									;letter grid char (unknown -> A)
	movem.l	d0-d4/a0-a6,-(sp)
	move.b	(NameEntryBuf).w,d0
	bsr.w	FindGridLetter
	cmp.w	#$1E,d0
	blt.w	.1
	clr.w	d5
	bra.w	.2
.1
	move.w	d0,d5
	movea.l	#CreateLetterGrid,a0
	move.b	(a0,d5.w),(NameEntryBuf).w
.2
	movem.l	(sp)+,d0-d4/a0-a6
	rts

FindGridLetter						;Find char d0 in letter grid table, return index in d0 ($1E if not found)
	movem.l	d1-d3/a0-a6,-(sp)
	movea.l	#CreateLetterGrid,a0
	move.b	d0,d1
	clr.w	d0
	move.w	#$1E,d3
.loop
	cmp.b	(a0,d0.w),d1
	beq.w	.1
	addq.w	#1,d0
	dbf	d3,.loop
	move.w	#$1E,d0
.1
	movem.l	(sp)+,d1-d3/a0-a6
	rts
FindGridLetterMsg1	equ	*	;Print the first create player message and clear its line
	jsr	(printz).l
	String	$8F,$17,$13
	move.w	#$10,d0
	move.w	#4,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	rts
FindGridLetterMsg2	equ	*	;Print the second create player message and clear its line
FindGridLetterMsg2	equ	*	;Print the second create player message and clear its line
	jsr	(printz).l
	String	$8F,$17,$D
	move.w	#$10,d0
	move.w	#$A,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	rts
FindGridLetterMsg3	equ	*	;Print the third create player message
	dc.w	$4EB9,$0001,$BA2E,$0040,$FE07,$FF01,$FD18,$FC13
	dc.w	$613D,$676F,$2062,$6163,$6BFD,$18FA,$0162,$3D63
	dc.w	$616E,$6365,$6CFD,$18FA,$0163,$3D65,$6E74,$6572
	dc.w	$206C,$6574,$7465,$72FD,$18FA,$0173,$7461,$7274
	dc.w	$3D64,$6F6E,$6500,$4E75
DrawLetterGrid	equ	*	;Draw the letter grid of the name entry screen
	dc.w	$61B6,$4EB9,$0001,$BC72,$0006,$8F1A,$0F00,$207C
	dc.w	$001E,$6B04,$7002,$7209,$227C,$FFFF,$BFF2,$32FC
	dc.w	$000C,$12D8,$51C9,$FFFC,$327C,$BFF2,$4EB9,$0001
	dc.w	$BC84,$5278,$B042,$0478,$000A,$B040,$51C8,$FFD8
	dc.w	$4E75
DrawNameEntryPrompt	equ	*	;Print the prompt lines of the name entry screen
	dc.w	$48E7,$FFFE,$0838,$0007,$C358,$6600,$0056,$0838
	dc.w	$0006,$C356,$6700,$0096,$4EB9,$0001,$BC72,$0040
	dc.w	$8F13,$066D,$6178,$696D,$756D,$206E,$756D,$6265
	dc.w	$7220,$6F66,$8F12,$0763,$7265,$6174,$6564,$2070
	dc.w	$6C61,$7965,$7273,$2E8F,$1108,$7072,$6573,$7320
	dc.w	$7374,$6172,$7420,$746F,$2065,$7869,$742E,$6000
	dc.w	$00AC,$4EB9,$0001,$BC72,$0040,$8F13,$066D,$6178
	dc.w	$696D,$756D,$206E,$756D,$6265,$7220,$6F66,$8F12
	dc.w	$0766,$7265,$6520,$6167,$656E,$7473,$2E20,SPAturnl
	dc.w	$208F,$1108,$7072,$6573,$7320,$7374,$6172,$7420
	dc.w	$746F,$2065,$7869,$742E

DrawCreateList						;Draw list of up to 6 player names starting at player CreateListTop Code
	bra.w	.1
	dc.w	$3F38,$D3C0,$3F38,$D3C2,$4EB9,$0001,$BC72,$0006
	dc.w	$8F13,$0600,$3E3C,$0003,$BE79,$FFFF,$55F0,$6D00
	dc.w	$0008,$3E39,$FFFF,$55F0,$5347,$31F9,$FFFF,$55F4
	dc.w	$D3C2,$5278,$D3C2,$227C,$FFFF,$BF54,$6100,$022C
	dc.w	$3F38,$B040,$6100,$00E0,$31DF,$B040,$5278,$B042
	dc.w	$5278,$D3C2,$51CF,$FFE6,$31DF,$D3C2,$31DF,$D3C0
.1
	movem.l	(sp)+,d0-d7/a0-a6
	rts
DrawCreateListMarkers	equ	*	;Draw the markers of the created player list
	movem.l	d0-d7/a0-a6,-(sp)
	btst	#6,(sflags12).w
	bne.w	MoveListMarkersDraw
	btst	#7,(sflags13).w

MoveListMarkers						;Move selection arrows to the current list row if it changed Code the
	bne.w	MoveListMarkersDraw
	move.w	(namelogsel).w,d0
	cmp.w	(namelogarrows).w,d0
	beq.w	MoveListMarkersDraw
	movea.l	#ListMarkersOff,a1
	bsr.w	MoveNameLogArrows
	movea.l	#ListMarkers,a1
	bsr.w	MoveNameLogArrows
MoveListMarkersDraw	equ	*	;Draw the arrow markers of the created player list
	movem.l	(sp)+,d0-d7/a0-a6
	rts
MoveNameLogArrows					;Move the arrows of the saved names list
	tst.w	(namelogarrows).w
	beq.w	.next2
	jsr	(printcurz).l
	String	$8F,$13,6
	move.w	(namelogarrows).w,d0
	subq.w	#1,d0
	sub.w	($FFFF55F4).l,d0
	add.w	d0,(printy).w
	move.l	a1,-(sp)
	movea.l	(sp)+,a1
	adda.w	(a1),a1
	move.w	#$26,(printx).w
	jsr	(printcur).l
.next2
	move.w	(namelogsel).w,(namelogarrows).w
	rts

ListMarkers							;Row markers ] and [
	String	']'
	String	'['

ListMarkersOff						;Blanks over the row markers
	String	' '
	String	' '

CountNameLength						;Count name length of name buffer NameEntryBuf into NameEntryLen Code the
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#$11,d3
	movea.l	#NameEntryBuf,a0
	clr.w	(NameEntryLen).w
.loop
	cmpi.b	#$2D,(a0)
	bne.w	.1
	tst.b	(a0)+
	bra.w	.2
.1
	tst.b	(a0)+
	beq.w	.3
	addq.w	#1,(NameEntryLen).w
.2
	dbf	d3,.loop
.3
	movem.l	(sp)+,d0-d7/a0-a6
	rts

PrintEditName						;Print 18-char name from a1 with - padding, highlight cursor char d4 in
									;grid mode
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(NameEntryLen).w,-(sp)
	move.w	#$12,(NameEntryLen).w
	movea.l	#CalTeam,a0
	move.w	(NameEntryLen).w,d0
	move.w	#0,d3
	move.w	#$16,(a0)+
.loop
	cmp.w	#8,d3
	bne.w	.1
	move.b	#$20,(a0)+
.1
	move.b	(a1,d3.w),d1
	cmp.w	(NameEntryLen).w,d3
	blt.w	.2
	move.b	#$2D,d1
.2
	cmp.b	#$20,d1
	bne.w	.3
	move.b	#$2D,d1
.3
	move.b	d1,(a0)+
	addq.w	#1,d3
	cmp.w	#$12,d3
	blt.s	.loop
	movea.l	#CalTeam,a1
	move.b	#$20,$15(a1)
	move.w	(printx).w,d7
	move.l	a1,-(sp)
	jsr	(printcur).l
	movea.l	(sp)+,a1
	tst.w	(NameEntryMode).w
	beq.w	.6
	adda.w	d4,a1
	cmp.w	#8,d4
	blt.w	.4
	addq.w	#1,a1
.4
	addq.w	#2,a1
	movea.l	#TempLegSpd+2,a0
	move.w	#4,(a0)
	move.b	(a1),2(a0)
	clr.b	3(a0)
	movea.l	a0,a1
	jsr	(printsmallz).l
	String	$FE,7
	add.w	d4,d7
	cmp.w	#8,d4
	blt.w	.5
	addq.w	#1,d7
.5
	move.w	d7,(printx).w
	jsr	(printsmall).l
	jsr	(printsmallz).l
	String	$FE,5
.6
	move.w	(sp)+,(NameEntryLen).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts
ReadSavedNameFromSRAM	equ	*			;Read the saved name selected in the log from save RAM
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(namelogsel).w,d1
	subq.w	#1,d1
	add.w	d1,d1
	movea.l	#$FFFF4E20,a0
	move.w	(a0,d1.w),d1
	bmi.w	.7
	andi.w	#$FF,d1
	asl.w	#5,d1
	ext.l	d1
	move.l	#$12CE,d0
	add.l	d1,d0
	moveq	#$20,d1
	movea.l	#$FFFF5600,a0
	jsr	(ReadSRAM).l
	movea.l	#$FFFF5600,a0
	adda.w	(a0),a0
	cmpa.l	#$FFFF5600,a0
	beq.w	.loop2
	move.l	(a0),($FFFF5600).l
	move.l	4(a0),($FFFF5604).l
	move.b	8(a0),($FFFF5608).l
.loop2
	movem.l	(sp)+,d0-d7/a0-a6
	rts
.7
	clr.l	($FFFF5600).l
	clr.l	($FFFF5604).l
	clr.b	($FFFF5608).l
	bra.s	.loop2

GetCreateName						;Copy player name (CreateListRow-1)*18 from M68K_RAM to a1, 0->-, length
									;to NameEntryLen
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#M68K_RAM,a0
	move.w	(namelogsel).w,d2
	subq.w	#1,d2
	mulu.w	#$12,d2
	move.w	#0,(NameEntryLen).w
	move.w	#$11,d3
.loop
	move.b	(a0,d2.w),d0
	beq.w	.1
	bra.w	.2
.1
	move.b	#$2D,d0
	subq.w	#1,(NameEntryLen).w
	move.b	d0,(a1)+
	bra.w	.4
.2
	cmp.b	#$2D,d0
	bne.w	.3
	move.b	#$20,d0
.3
	move.b	d0,(a1)+
.4
	addq.w	#1,(NameEntryLen).w
	addq.w	#1,d2
	dbf	d3,.loop
	movem.l	(sp)+,d0-d7/a0-a6
	rts
SetupCreateScreenVideo	equ	*	;Set the VBint handler, scroll and map addresses for the create player screen and load its graphics
	bset	#5,(sflags12).w
	move.l	#VBlank_Menus,(VBint).w
	bclr	#dfok,(disflags).w
	bset	#dfng,(disflags).w
	bclr	#df32c,(disflags).w
	move.w	#0,(VSCRLPM).w
	move.w	#$B400,(VSPRITES).w
	move.w	#$B800,(VmMAP3).w
	move.w	#5,(Map3col1).w
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
	movea.l	#CreateSprites,a1
	jsr	(LoadScreenSprite).l
	move.w	d4,(smallfontchars).w
	movea.l	#RosterFont+8,a2
	jsr	(DecompressGraphicsPlain).l
	move.w	d4,(smallfont2chars).w
	movea.l	#SmallFontMap2+8,a2
	jsr	(DecompressGraphicsPlain).l
	move.l	#RosterFont,(smallfontptr).w
	jsr	(printsmallz).l
	String	$FF,1,$FD,0,$FC
	moveq	#$28,d0
	moveq	#$1C,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	jsr	(printcurz).l
	String	-(TXPRI+TXMAP1),0,0
	movea.l	#CreateBgMap,a0
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
	String	-(TXPRI+TXMAP1),$B,1
	movea.l	#CreateTitleMap,a0
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
	String	$FE,0,0
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
	move.w	(smallfontchars).w,-(sp)
	move.w	(smallfont2chars).w,(smallfontchars).w
	btst	#7,(sflags13).w
	bne.w	.5
	btst	#6,(sflags12).w
	beq.w	.6
.5
	jsr	(printcurz).l
	String	$8F,3,7,'START-EXIT'
	bra.w	.7
.6
	jsr	(printcurz).l
	String	$8F,3,7,'A-edit slot',$8F,3,8,'B-cancel'
.7
	move.w	(sp)+,(smallfontchars).w
	move.w	#$2500,sr
	rts

ReadCreatedPlayers					;Read the created players from save RAM into name records and ids Code the
	movem.l	d0-d7/a0-a6,-(sp)
	clr.w	($FFFF55F0).l
	movea.l	#LeaderIds,a0
	move.l	#$DB4,d0
	moveq	#$28,d1
	jsr	(ReadSRAM).l
	move.w	#$14,d6
	movea.l	#$FFFF4E20,a3
	movea.l	#M68K_RAM,a2
	move.w	#$FFFF,d5
	bra.w	.1
.loop
	tst.w	(a0)+
	bmi.w	.1
	move.w	-$2(a0),d0
	andi.w	#$1F00,d0
	cmp.w	#$1E00,d0
	bne.w	.1
	move.w	-$2(a0),d0
	jsr	(GetCreatedName).l
	bsr.w	FormatNameRecord
	adda.w	#$12,a2
	move.w	-$2(a0),d0
	move.w	d0,(a3)+
	addq.w	#1,($FFFF55F0).l
.1
	addq.w	#1,d5
	dbf	d6,.loop
	cmpi.w	#$14,($FFFF55F0).l
	bge.w	.2
	move.w	(SaveRAM+$2A9C).l,d0
	andi.w	#$FF,d0
	cmp.b	#$13,d0
	bge.w	.2
	move.w	#$11,d0
.loop2
	move.b	#0,(a2)+
	dbf	d0,.loop2
	move.w	#$8000,(a3)
	addq.w	#1,($FFFF55F0).l
.2
	movem.l	(sp)+,d0-d7/a0-a6
	rts

FormatNameRecord					;Format name string at a1 into an 18-byte record at a2: first name padded
									;to 8 and last name to 10 with dashes
	movem.l	d0-d7/a1-a2,-(sp)
	move.w	(a1)+,d7
	subq.w	#3,d7
	move.w	#7,d6
.loop
	cmpi.b	#$20,(a1)
	beq.w	.1
	move.b	(a1)+,d0
	move.b	d0,(a2)+
	subq.w	#1,d7
	dbf	d6,.loop
.1
	tst.w	d6
	bmi.w	.2
.loop2
	move.b	#$2D,(a2)+
	dbf	d6,.loop2
.2
	addq.w	#1,a1
	subq.w	#1,d7
	move.w	#9,d6
.loop3
	move.b	(a1)+,d0
	move.b	d0,(a2)+
	subq.w	#1,d6
	dbf	d7,.loop3
	tst.w	d6
	bmi.w	.3
.loop4
	move.b	#$2D,(a2)+
	dbf	d6,.loop4
.3
	movem.l	(sp)+,d0-d7/a1-a2
	rts
DrawNameEntryScreen	equ	*	;Draw the name entry screen
	bsr.w	CountNameLength
	jsr	(printcurz).l
	String	$8F,$14,5
	tst.w	(NameEntryMode).w
	beq.w	.4
	jsr	(printcurz).l
	String	$8F,1,$C
	move.w	#0,d0
	bsr.w	FormatNameRecordMark
	jsr	(printcurz).l
	String	'Full Name:'
	move.w	#1,(printx).w
	addq.w	#1,(printy).w
	movea.l	#NameEntryBuf,a1
	bsr.w	PrintEditName
	move.w	#1,(printx).w
	addq.w	#2,(printy).w
	move.w	#1,d0
	bsr.w	FormatNameRecordMark
	jsr	(printsmallz).l
	String	$F9,0,'position:',$FD,$E
	move.b	($FFFF5608).l,d0
	ext.w	d0
	movea.l	#PosText,a1
	jsr	(SkipStrings).l
	jsr	(printcur).l
	move.w	#1,(printx).w
	addq.w	#2,(printy).w
	move.w	#2,d0
	bsr.w	FormatNameRecordMark
	jsr	(printsmallz).l
	String	'handedness:',$FD,$E
	move.b	($FFFF5604).l,d0
	andi.w	#1,d0
	movea.l	#HandNames,a1
	jsr	(SkipStrings).l
	jsr	(printcur).l
	move.w	#1,(printx).w
	addq.w	#2,(printy).w
	move.w	#3,d0
	bsr.w	FormatNameRecordMark
	jsr	(printsmallz).l
	String	'weight:',$FD,$E,'   ',$FD,$E
	move.b	($FFFF5601).l,d0
	lsr.w	#4,d0
	andi.w	#$F,d0
	jsr	(RatingToWeight).l
	jsr	(PushNumber).l
	jsr	(printcur).l
	move.w	#1,(printx).w
	addq.w	#2,(printy).w
	move.w	#4,d0
	bsr.w	FormatNameRecordMark
	jsr	(printsmallz).l
	String	'Uniform #:',$FD,$E,'  ',$FD,$E
	move.b	($FFFF5600).l,d0
	move.w	d0,d1
	andi.w	#$F,d1
	move.w	d1,-(sp)
	lsr.w	#4,d0
	andi.w	#$F,d0
	mulu.w	#$A,d0
	add.w	(sp)+,d0
	jsr	(PushNumber).l
	jsr	(printcur).l
	rts
FormatNameRecordMark	equ	*	;Print the marker of the selected name record and redraw the list markers
	jsr	(printsmallz).l
	String	$FE,7
	cmp.w	(NameEntryMode+2).w,d0
	bne.w	.4
	jsr	(printsmallz).l
	String	$FE,5
.4
	bsr.w	DrawCreateListMarkers
	rts

PosText								;Position texts (code96_04 and the create player screen)
	String	'G '
	String	'LD'
	String	'RD'
	String	'LW'
	String	'C '
	String	'RW'

HandNames							;Shooting hand texts
	String	'LEFT '
	String	'RIGHT'

SaveCreateName						;Save entered name to the created-player record (new or existing); invalid
									;name -> message; d0=0 ok/-1
	movem.l	d0-d7/a0-a6,-(sp)
	bsr.w	BuildEnteredName
	bmi.w	SaveNameError
	move.w	(namelogsel).w,d0
	subq.w	#1,d0
	add.w	d0,d0
	movea.l	#$FFFF4E20,a0
	tst.w	(a0,d0.w)
	bmi.w	SaveNewName
	movem.l	d1-d3/a1,-(sp)
	movea.l	#$201B68,a1
	move.w	#0,d2
.loop
	move.w	(a1,d2.w),d3
	andi.w	#$FF,d3
	lsl.w	#8,d3
	move.w	2(a1,d2.w),d1
	andi.w	#$FF,d1
	or.w	d1,d3
	cmp.w	(a0,d0.w),d3
	beq.w	.1
	addq.w	#4,d2
	cmp.w	#$50,d2
	blt.s	.loop
	clr.w	d2
.1
	asr.w	#2,d2
	move.w	d2,($FFFF55FC).l
	movem.l	(sp)+,d1-d3/a1
	move.w	(a0,d0.w),d1
	andi.w	#$FF,d1
	move.w	d1,($FFFF55FE).l
	asl.w	#5,d1
	add.w	d1,d1
	movea.l	#$20259C,a0
	adda.w	d1,a0
	bsr.w	CopyNameWords
	bra.w	SaveNewNameDone

CopyNameWords						;Copy the length-prefixed name at StatWork into a0 as words Code the
	movea.l	#TempLegSpd+2,a1
	move.w	(a1),d0
	subq.w	#1,d0
	clr.w	d1
.loop
	move.b	(a1)+,d1
	move.w	d1,(a0)+
	dbf	d0,.loop
	rts

SaveNewName							;SaveCreateName, new player: take a free SRCreatedPlayers slot, store the
									;name and add it to the free agent
									;list
	bsr.w	CheckCreatedPlayerLimit
	bmi.w	.5
	movea.l	#$20259C,a0
	clr.w	d6
	move.w	#$13,d5
.loop
	tst.b	1(a0)
	bne.w	.1
	tst.b	3(a0)
	beq.w	.2
.1
	adda.l	#$40,a0
	addq.w	#1,d6
	dbf	d5,.loop
	bra.w	.5
.2
	bsr.s	CopyNameWords
	addq.b	#1,(SaveRAM+$2A9D).l
	movea.l	#$201B68,a0
	move.w	(SaveRAM+$1BB8).l,d0
	andi.w	#$FF,d0
	cmp.b	#$14,d0
	bge.w	.4
	clr.w	($FFFF55FC).l
.loop2
	tst.b	1(a0)
	bmi.w	.3
	addq.l	#4,a0
	addq.w	#1,($FFFF55FC).l
	bra.s	.loop2
.3
	move.b	d6,3(a0)
	andi.w	#$FF,d6
	move.w	d6,($FFFF55FE).l
	move.b	#$1E,1(a0)
	addq.w	#1,(SaveRAM+$1BB8).l
SaveNewNameDone	equ	*
	bra.w	SaveNameErrorExit
.4
	bra.w	SaveNameError
.5
	bra.w	SaveNameError

SaveNameError						;SaveCreateName: back to font 0, d0 = -1
	jsr	(printsmallz).l
	String	$F9
	move.w	#$FFFF,d0
	bra.w	.1
SaveNameErrorExit	equ	*
	clr.w	d0
.1
	movem.l	(sp)+,d0-d7/a0-a6
	rts

BuildEnteredName					;Build the entered name (from NameEntryBuf, spaces/dashes dropped, space
									;after first name) as a length-word
									;string at StatWork and check it has a first and last name; d0 = 0 ok, -1
									;invalid
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#pstatscat,a0
	movea.l	#NameEntryBuf,a1
	move.w	(NameEntryLen).w,d0
	subq.w	#1,d0
	clr.w	d5
	clr.w	d6
.loop
	cmp.w	#8,d6
	bne.w	.1
	move.b	#$20,(a0)+
	addq.w	#1,d5
.1
	move.b	(a1)+,d1
	cmp.b	#$20,d1
	beq.w	.2
	cmp.b	#$2D,d1
	beq.w	.2
	move.b	d1,(a0)+
	addq.w	#1,d5
.2
	addq.w	#1,d6
	dbf	d0,.loop
	btst	#0,d5
	beq.w	.3
	move.b	#0,(a0)
	addq.w	#1,d5
.3
	addq.w	#2,d5
	move.w	d5,(TempLegSpd+2).w
	cmp.w	#6,d5
	blt.w	.6
	movea.l	#TempLegSpd+2,a0
	adda.w	(a0),a0
	move.b	-(a0),d0
	tst.b	d0
	bne.w	.4
	move.b	-(a0),d0
.4
	cmp.b	#$20,d0
	beq.w	.6
	movea.w	#(pstatscat-2-M68K_RAM),a0
	move.w	(a0)+,d0
	subq.w	#1,d0
.loop2
	cmpi.b	#$20,(a0)+
	beq.w	.5
	dbf	d0,.loop2
	bra.w	.6
.5
	clr.w	d0
	bra.w	.7
.6
	move.w	#$FFFF,d0
.7
	movem.l	(sp)+,d0-d7/a0-a6
	rts
CheckCreatedPlayerLimit	equ	*	;d0 = -1 when the created player count ($202A9D) has reached $14
	movem.w	d0,-(sp)
	clr.w	d0
	move.b	(SaveRAM+$2A9D).l,d0
	cmp.b	#$14,d0
	blt.w	.8
	move.w	#$FFFF,d0
	bra.w	.9
.8
	move.w	#1,d0
.9
	movem.w	(sp)+,d0
	rts

NewCreateRecord						;Same as InitCreateRecord but with bit 2 of sflags8 set (skips the read)
	bset	#2,(sflags8).w
	bra.w	InitCreateRecord2

InitCreateRecord					;Read the create record for CreateIndex from save RAM.
									;NewCreateRecord skips that read
	bclr	#2,(sflags8).w

InitCreateRecord2					;InitCreateRecord without the bclr (NewCreateRecord enters here) Code the
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#CreatePoints+2,a0
	clr.l	d0
	move.w	($FFFF55FE).l,d0
	asl.w	#5,d0
	ext.l	d0
	addi.l	#$12CE,d0
	moveq	#$20,d1
	movem.l	d0-d1/a0,-(sp)
	btst	#2,(sflags8).w
	bne.w	.1
	jsr	(ReadSRAM).l
.1
	movea.l	#CreateRecordTail2,a1
	tst.b	($FFFF5608).l
	bne.w	.2
	movea.l	#CreateRecordTail1,a1
.2
	adda.w	(a0),a0
	move.w	#7,d0
.loop
	move.b	(a1)+,(a0)+
	dbf	d0,.loop
	tst.b	($FFFF5608).l
	beq.w	.3
	move.w	#5,d0
	jsr	(randomd0).l
	add.b	d0,-(a0)
.3
	movea.l	#CreatePoints+2,a0
	adda.w	(a0),a0
	move.b	($FFFF5600).l,(a0)
	move.b	($FFFF5601).l,d0
	andi.w	#$F0,d0
	andi.b	#$F,1(a0)
	or.b	d0,1(a0)
	move.b	($FFFF5608).l,8(a0)
	move.b	($FFFF5604).l,d0
	andi.w	#1,d0
	andi.b	#$FE,4(a0)
	or.b	d0,4(a0)
	movem.l	(sp)+,d0-d1/a0
	jsr	(WriteSRAM).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

CreateRecordTail1					;8 byte record tail (record byte $1F clear)
	dc.b	$20,$82,$22,$22,$00,$00,$22,$22

CreateRecordTail2					;8 byte record tail (record byte $1F set)
	dc.b	$20,$82,$22,$22,$22,$22,$22,$27

ModifyRatings						;Modify Ratings screen: up / down pick a rating, A / B lower / raise it
									;(EditField), start commits the player
	bsr.w	CreateRatingsGfx
	movea.l	#CreateRatingsSprites,a0
	jsr	(DrawScreenSprite).l
	jsr	(PStatsPalette).l
	move.w	#$18,(palcount).w
	bclr	#2,(disflags).w
	bsr.w	ClearAttribDeltas
	bsr.w	LoadCreateTemplate
	bsr.w	SetPointsPool
	bsr.w	DrawRatingsHeader
	clr.w	($FFFF7532).l
.loop
	bsr.w	DrawAllFields
	move.w	#$2500,sr
.loop2
	move.w	(Vcount).w,d0
.loop3
	cmp.w	(Vcount).w,d0
	beq.s	.loop3
	jsr	(SetMenuScroll).l
	jsr	(FindHeldMenuPad).l
	jsr	(ProcessInputWithRepeat).l
	tst.w	d1
	beq.s	.loop2
	btst	#7,d1
	beq.w	.1
	jsr	(CommitCreatedPlayer).l
	bra.w	.8
.1
	btst	#0,d1
	beq.w	.3
	tst.w	($FFFF7532).l
	bne.w	.2
	bsr.w	LastFieldRow
	move.w	d4,($FFFF7532).l
	bra.s	.loop
.2
	subq.w	#1,($FFFF7532).l
	bra.s	.loop
.3
	btst	#1,d1
	beq.w	.5
	bsr.w	LastFieldRow
	cmp.w	($FFFF7532).l,d4
	ble.w	.4
	addq.w	#1,($FFFF7532).l
	bra.s	.loop
.4
	clr.w	($FFFF7532).l
	bra.w	.loop
.5
	btst	#6,d1
	beq.w	.6
	move.w	#$FFFF,d0
	bsr.w	CallFieldEditor
	bra.w	.loop
.6
	btst	#4,d1
	beq.w	.7
	move.w	#1,d0
	bsr.w	CallFieldEditor
	bra.w	.loop
.7
	bra.w	.loop2
.8
	movem.l	(sp)+,d0-d7/a0-a6
	rts
DrawRatingsHeader					;Print the headings of the ratings screen
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(printcurz).l
	String	$8F,7,6,'First:',$8F,8,7,'Last:'
	movea.l	#TextBuffer,a0
	movea.l	#CreatePoints+4,a1
	move.w	#2,(mesarea).w
.loop
	move.b	(a1)+,d0
	cmp.b	#$20,d0
	beq.w	.1
	move.b	d0,(a0)+
	addq.w	#1,(mesarea).w
	bra.s	.loop
.1
	clr.b	(a0)
	addq.w	#1,(mesarea).w
	andi.w	#$FFFE,(mesarea).w
	movea.l	#mesarea,a1
	jsr	(printcurz).l
	String	$8F,$D,6
	jsr	(printcur).l
	movea.l	#TextBuffer,a0
	movea.l	#CreatePoints+4,a1
	move.w	#2,(mesarea).w
	move.w	(CreatePoints+2).l,d6
	subq.w	#3,d6
.loop2
	move.b	(a1)+,d0
	subq.w	#1,d6
	cmp.b	#$20,d0
	bne.s	.loop2
.loop3
	move.b	(a1)+,(a0)+
	addq.w	#1,(mesarea).w
	dbf	d6,.loop3
	clr.b	(a0)
	addq.w	#1,(mesarea).w
	andi.w	#$FFFE,(mesarea).w
	movea.l	#mesarea,a1
	jsr	(printcurz).l
	String	$8F,$D,7
	jsr	(printcur).l
	jsr	(printcurz).l
	String	$8F,9,8,'pos:'
	movea.l	#CreatePoints+2,a1
	adda.w	(a1),a1
	move.b	8(a1),d0
	ext.w	d0
	move.l	a1,-(sp)
	movea.l	#PosText,a1
	jsr	(SkipStrings).l
	jsr	(printcur).l
	jsr	(printcurz).l
	String	$8F,$1C,8,'hand:'
	movea.l	(sp),a1
	move.b	4(a1),d0
	andi.w	#1,d0
	movea.l	#HandNames,a1
	jsr	(SkipStrings).l
	jsr	(printcur).l
	jsr	(printcurz).l
	String	$8F,$1A,7,'weight:'
	movea.l	(sp),a1
	move.b	1(a1),d0
	lsr.w	#4,d0
	andi.w	#$F,d0
	jsr	(RatingToWeight).l
	jsr	(PushNumber).l
	jsr	(printcur).l
	jsr	(printcurz).l
	String	$8F,$1A,6,'number:'
	movea.l	(sp)+,a1
	move.b	(a1),d0
	move.w	d0,d1
	andi.w	#$F,d1
	move.w	d1,-(sp)
	lsr.w	#4,d0
	andi.w	#$F,d0
	mulu.w	#$A,d0
	add.w	(sp)+,d0
	jsr	(PushNumber).l
	jsr	(printcur).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts
DrawAllFields						;Draw every rating field and the two column heads
	movem.l	d0-d7/a0-a6,-(sp)
	clr.w	d7
	bsr.w	LastFieldRow
.loop
	bsr.w	DrawField
	addq.w	#1,d7
	cmp.w	d4,d7
	ble.s	.loop
	bsr.w	DrawFieldsHeaderLeft
	bsr.w	DrawFieldsHeaderRight
	movem.l	(sp)+,d0-d7/a0-a6
	rts
DrawFieldsHeaderLeft				;Print the left column heading of the fields
	jsr	(printsmallz).l
	String	$FE,7,$FD,$1B,$FC,$10,'OVERALL',$FD,$1D,$FC,$11
	movea.l	#CreatePoints+2,a0
	adda.w	(a0),a0
	addq.w	#8,a0
	movea.l	#$FFFFC8F2,a4
	movea.l	#OvrGoalWgtList2,a6
	move.l	(GAttribOverallMask).l,d4
	tst.w	($FFFF7534).l
	beq.w	.1
	movea.l	#OvrPlayerWgtList2,a6
	move.l	(PAttribOverallMask).l,d4
.1
	jsr	(CalcAttribRating).l
	mulu.w	#$64,d0
	divu.w	d1,d0
	jsr	(SoftClampCoord).l
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	rts
DrawFieldsHeaderRight				;Print the right column heading of the fields
	jsr	(printsmallz).l
	String	$FE,7,$FD,$17,$FC,$D,'Points remaining',$FD,$1D,$FC,$E
	move.w	(CreatePoints).l,d0
	move.w	#3,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	rts
DrawRatingValue	equ	*	;Draw the value of rating field d7 (skater or goalie field list)
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#SkaterFieldList,a0
	tst.w	($FFFF7534).l
	bne.w	.1
	movea.l	#GoalieFieldList,a0
.1
	move.w	d7,d0
	asl.w	#2,d0
	movea.l	(a0,d0.w),a0
	movea.l	#CreatePoints+2,a2
	adda.w	(a2),a2
	jsr	(a0)
	movem.l	(sp)+,d0-d7/a0-a6
	rts

FieldSpeed							;Create player field: Speed
	bsr.w	HandTextRight
	bsr.w	FieldPrintSetup
	move.l	(PAttribHanded).l,d4
	jsr	(CalcAttribRating).l
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	bra.w	HandTextLeft

FieldPrintSetup						;Set print target a4 / a0 and the number print table a6 for a field value
	movea.l	#$FFFFC8F2,a4
	movea.l	a2,a0
	addq.w	#8,a0
	movea.l	#AttribWgtList2,a6
	rts

FieldAgility						;Create player field: Agility
	bsr.w	HandTextRight
	bsr.s	FieldPrintSetup
	move.l	(PAttribSpeed).l,d4
	jsr	(CalcAttribRating).l
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	bra.w	HandTextLeft

FieldEndurance						;Create player field: Endurance
	bsr.w	HandTextRight
	bsr.s	FieldPrintSetup
	move.l	(PAttribAggressiveness).l,d4
	jsr	(CalcAttribRating).l
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	bra.w	HandTextLeft

FieldOffAware						;Create player field: OffAware
	bsr.w	HandTextRight
	bsr.s	FieldPrintSetup
	move.l	(PAttribDefAwareness).l,d4
	jsr	(CalcAttribRating).l
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	bra.w	HandTextLeft

FieldDefAware						;Create player field: DefAware
	bsr.w	HandTextRight
	bsr.w	FieldPrintSetup
	move.l	(PAttribShotPower).l,d4
	jsr	(CalcAttribRating).l
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	bra.w	HandTextLeft

FieldStickhandling					;Create player field: Stickhandling
	bsr.w	HandTextRight
	bsr.w	FieldPrintSetup
	move.l	(PAttribWeight).l,d4
	jsr	(CalcAttribRating).l
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	bra.w	HandTextLeft

FieldWeight							;Create player field: Weight
	bsr.w	HandTextRight
	bsr.w	FieldPrintSetup
	move.l	(PAttribEndurance).l,d4
	jsr	(CalcAttribRating).l
	asl.w	#3,d0
	addi.w	#$8C,d0
	move.w	#3,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	bra.w	HandTextLeft

FieldShotPower						;Create player field: ShotPower
	bsr.w	HandTextRight
	bsr.w	FieldPrintSetup
	move.l	(PAttribShotAccuracy).l,d4
	jsr	(CalcAttribRating).l
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	bra.w	HandTextLeft

FieldShotAcc						;Create player field: ShotAcc
	bsr.w	HandTextRight
	bsr.w	FieldPrintSetup
	move.l	(PAttribPassAccuracy).l,d4
	jsr	(CalcAttribRating).l
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	bra.w	HandTextLeft

FieldPassAcc						;Create player field: PassAcc
	bsr.w	HandTextRight
	bsr.w	FieldPrintSetup
	move.l	(PAttribStickHandling).l,d4
	jsr	(CalcAttribRating).l
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	bra.w	HandTextLeft

FieldChecking						;Create player field: Checking
	bsr.w	HandTextRight
	bsr.w	FieldPrintSetup
	move.l	(PAttribChecking).l,d4
	jsr	(CalcAttribRating).l
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	bra.w	HandTextLeft

FieldJersey							;Create player field: Jersey
	bsr.w	HandTextRight
	clr.w	d4
	move.b	(a2),d4
	lsr.w	#4,d4
	mulu.w	#$A,d4
	move.b	(a2),d0
	andi.b	#$F,d0
	add.b	d4,d0
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	bra.w	HandTextLeft

FieldGAgility						;Create player field: GAgility
	bsr.w	HandTextRight
	bsr.w	FieldPrintSetup
	move.l	(GAttribSpeed).l,d4
	jsr	(CalcAttribRating).l
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	bra.w	HandTextLeft

FieldGDefAware						;Create player field: GDefAware
	bsr.w	HandTextRight
	bsr.w	FieldPrintSetup
	move.l	(GAttribOffAwareness).l,d4
	jsr	(CalcAttribRating).l
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	bra.w	HandTextLeft

FieldGPuckCtrl						;Create player field: GPuckCtrl
	bsr.w	HandTextRight
	bsr.w	FieldPrintSetup
	move.l	(GAttribStickRight).l,d4
	jsr	(CalcAttribRating).l
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	bra.w	HandTextLeft

FieldGStickR						;Create player field: GStickR
	bsr.w	HandTextRight
	bsr.w	FieldPrintSetup
	move.l	(GAttribStickLeft).l,d4
	jsr	(CalcAttribRating).l
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	bra.w	HandTextLeft

FieldGStickL						;Create player field: GStickL
	bsr.w	HandTextRight
	bsr.w	FieldPrintSetup
	move.l	(GAttribGloveRight).l,d4
	jsr	(CalcAttribRating).l
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	bra.w	HandTextLeft

FieldGGloveR						;Create player field: GGloveR
	bsr.w	HandTextRight
	bsr.w	FieldPrintSetup
	move.l	(GAttribGloveLeft).l,d4
	jsr	(CalcAttribRating).l
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	bra.w	HandTextLeft

FieldGGloveL						;Create player field: GGloveL
	bsr.w	HandTextRight
	bsr.w	FieldPrintSetup
	move.l	(GAttribWeight).l,d4
	jsr	(CalcAttribRating).l
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	bra.w	HandTextLeft

FieldHand							;Create player field: Hand
	bsr.w	HandTextRight
	move.b	4(a2),d0
	andi.w	#1,d0
	movea.l	#HandText,a1
	jsr	(PrintSmallListItem).l
	bra.w	HandTextLeft

HandText							;FieldHand: the hand letters
	String	'L'
	String	'R'
HandTextLeft	equ	*	;Print the left hand text (low confidence)
	jsr	(printsmallz).l
	String	$FE,7
	rts
HandTextRight	equ	*	;Print the right hand text (low confidence)
	jsr	(printsmallz).l
	String	$FE,7
	cmp.w	($FFFF7532).l,d7
	bne.w	.1
	jsr	(printsmallz).l
	String	$FE,5
.1
	rts

SkaterFieldList						;The field routine of each skater rating row
	dc.l	FieldAgility,FieldSpeed,FieldOffAware,FieldDefAware,FieldShotPower,FieldChecking
	dc.l	FieldStickhandling,FieldShotAcc,FieldEndurance,FieldPassAcc

GoalieFieldList						;The field routine of each goalie rating row
	dc.l	FieldGAgility,FieldSpeed,FieldOffAware,FieldGDefAware,FieldGPuckCtrl,FieldGStickR
	dc.l	FieldGStickL,FieldGGloveR,FieldGGloveL

DrawField							;Draw one create player field: label then value, all registers saved Code
	movem.l	d0-d7/a0-a6,-(sp)
	bsr.w	DrawFieldLabel
	bsr.w	DrawRatingValue
	movem.l	(sp)+,d0-d7/a0-a6
	rts
DrawFieldLabel						;Print the label of field d7 (skater or goalie list) and its marker
	movem.l	d0-d1/a0-a1,-(sp)
	movea.l	#SkaterSkillLabels,a1
	tst.w	($FFFF7534).l
	bne.w	.1
	movea.l	#GoalieSkillLabels,a1
.1
	move.w	d7,d0
	movem.l	d0/a1,-(sp)
	jsr	(printsmallz).l
	String	$FE,7
	cmp.w	($FFFF7532).l,d7
	bne.w	.2
	jsr	(printsmallz).l
	String	$FE,5
.2
	movem.l	(sp)+,d0/a1
	jsr	(SkipStrings).l
	jsr	(printsmall).l
	movem.l	(sp)+,d0-d1/a0-a1
	rts

SkaterSkillLabels					;The skater rating labels
	String	CC_SetX,$02,CC_SetY,$0D,'Agility',CC_SetX,$13
	String	CC_SetX,$02,CC_SetY,$0E,'Speed',CC_SetX,$13
	String	CC_SetX,$02,CC_SetY,$0F,'Off.Awareness',CC_SetX,$13
	String	CC_SetX,$02,CC_SetY,$10,'Def.Awareness',CC_SetX,$13
	String	CC_SetX,$02,CC_SetY,$11,'Shot Power',CC_SetX,$13
	String	CC_SetX,$02,CC_SetY,$12,'Checking Ability',CC_SetX,$13
	String	CC_SetX,$02,CC_SetY,$13,'Stick Handling',CC_SetX,$13
	String	CC_SetX,$02,CC_SetY,$14,'Shot Accuracy',CC_SetX,$13
	String	CC_SetX,$02,CC_SetY,$15,'Endurance',CC_SetX,$13
	String	CC_SetX,$02,CC_SetY,$16,'Pass Accuracy',CC_SetX,$13

GoalieSkillLabels					;The goalie rating labels
	String	CC_SetX,$02,CC_SetY,$0D,'Agility',CC_SetX,$13
	String	CC_SetX,$02,CC_SetY,$0E,'Speed',CC_SetX,$13
	String	CC_SetX,$02,CC_SetY,$0F,'Off.Awareness',CC_SetX,$13
	String	CC_SetX,$02,CC_SetY,$10,'Def.Awareness',CC_SetX,$13
	String	CC_SetX,$02,CC_SetY,$11,'Puck Control',CC_SetX,$13
	String	CC_SetX,$02,CC_SetY,$12,'Stick Right',CC_SetX,$13
	String	CC_SetX,$02,CC_SetY,$13,'Stick Left',CC_SetX,$13
	String	CC_SetX,$02,CC_SetY,$14,'Glove Right',CC_SetX,$13
	String	CC_SetX,$02,CC_SetY,$15,'Glove Left',CC_SetX,$13

LastFieldRow						;d4 = the last row index for the player type (CreateType) Code the listing
	movem.l	d6/a0,-(sp)
	move.w	#8,d4
	tst.w	($FFFF7534).l
	beq.w	EditField
	move.w	#9,d4

EditField							;Run the edit routine of the cursor row
									;(CreateCursorY) for the player type
	movem.l	(sp)+,d6/a0
	rts
CallFieldEditor	equ	*			;Call the edit routine of the selected field (skater or goalie list)
	movea.l	#GoalieEditList,a0
	tst.w	($FFFF7534).l
	beq.w	.1
	movea.l	#SkaterEditList,a0
.1
	move.w	($FFFF7532).l,d1
	asl.w	#2,d1
	movea.l	(a0,d1.w),a0
	jsr	(a0)
	rts

GoalieEditList						;The edit routine of each goalie rating row
	dc.l	EditGAgility,EditSpeed,EditOffAware,EditGDefAware,EditGPuckCtrl,EditGStickR
	dc.l	EditGStickL,EditGGloveR,EditGGloveL

SkaterEditList						;The edit routine of each skater rating row
	dc.l	EditAgility,EditSpeed,EditOffAware,EditDefAware,EditShotPower,EditChecking
	dc.l	EditStickhandling,EditShotAcc,EditEndurance,EditPassAcc

EditGAgility						;Create player edit: GAgility
	move.l	(GAttribSpeed).l,d4

AdjustAttrib						;Adjust attribute selected by d4 bit by d0, paying from points pool
									;CreatePoints
	move.w	(CreatePoints).l,d1
	move.w	d1,(TempPlOffset).w
	move.w	d0,d2
	neg.w	d2
	add.w	d2,d1
	bmi.w	.4
	move.w	d1,(CreatePoints).l
	movea.l	#$FFFFC8E2,a0
	swap	d4
.loop
	btst	#$F,d4
	bne.w	.1
	addq.w	#1,a0
	asl.w	#1,d4
	bra.s	.loop
.1
	tst.w	d0
	bpl.w	.2
	movem.w	d2-d3,-(sp)
	move.b	(a0),d2
	cmp.b	#0,d2
	movem.w	(sp)+,d2-d3
	ble.w	.3
.2
	add.b	d0,(a0)
	bra.w	.4
.3
	move.w	(TempPlOffset).w,(CreatePoints).l
AdjustAttribExit	equ	*
.4
	rts

EditGDefAware						;Create player edit: GDefAware
	move.l	(GAttribOffAwareness).l,d4
	bra.s	AdjustAttrib

EditGPuckCtrl						;Create player edit: GPuckCtrl
	move.l	(GAttribStickRight).l,d4
	bra.s	AdjustAttrib

EditWeight							;Create player edit: Weight
	movea.l	#CreatePoints+2,a0
	adda.w	(a0),a0
	clr.w	d1
	move.b	1(a0),d1
	lsr.w	#4,d1
	andi.w	#$F,d1
	add.w	d0,d1
	bmi.s	AdjustAttribExit
	cmp.w	#$F,d1
	bgt.s	AdjustAttribExit
	lsl.w	#4,d1
	move.b	1(a0),d0
	andi.w	#$F,d0
	or.w	d1,d0
	move.b	d0,1(a0)
	rts

EditGStickR							;Create player edit: GStickR
	move.l	(GAttribStickLeft).l,d4
	bra.w	AdjustAttrib

EditGStickL							;Create player edit: GStickL
	move.l	(GAttribGloveRight).l,d4
	bra.w	AdjustAttrib

EditGGloveR							;Create player edit: GGloveR
	move.l	(GAttribGloveLeft).l,d4
	bra.w	AdjustAttrib

EditGGloveL							;Create player edit: GGloveL
	move.l	(GAttribWeight).l,d4
	bra.w	AdjustAttrib

EditHand							;Create player edit: Hand
	movea.l	#CreatePoints+2,a0
	adda.w	(a0),a0
	eori.b	#1,4(a0)
	rts

EditJersey							;Create player edit: Jersey
	movea.l	#CreatePoints+2,a0
	adda.w	(a0),a0
	clr.w	d1
	move.b	(a0),d1
	andi.w	#$F,d1
	clr.w	d2
	move.b	(a0),d2
	lsr.w	#4,d2
	mulu.w	#$A,d2
	add.w	d2,d1
	add.b	d1,d0
	bpl.w	.1
	move.w	#$63,d0
.1
	tst.b	d0
	bne.w	.2
	move.w	#$63,d0
.2
	cmp.b	#$63,d0
	ble.w	.3
	move.w	#1,d0
.3
	tst.b	d0
	bne.w	.4
	move.w	#1,d0
.4
	andi.l	#$FF,d0
	divu.w	#$A,d0
	move.w	d0,d1
	lsl.w	#4,d1
	swap	d0
	or.b	d0,d1
	move.b	d1,(a0)
	rts

EditSpeed							;Create player edit: Speed
	move.l	(PAttribHanded).l,d4
	bra.w	AdjustAttrib

EditAgility							;Create player edit: Agility
	move.l	(PAttribSpeed).l,d4
	bra.w	AdjustAttrib

EditEndurance						;Create player edit: Endurance
	move.l	(PAttribAggressiveness).l,d4
	bra.w	AdjustAttrib

EditOffAware						;Create player edit: OffAware
	move.l	(PAttribDefAwareness).l,d4
	bra.w	AdjustAttrib

EditDefAware						;Create player edit: DefAware
	move.l	(PAttribShotPower).l,d4
	bra.w	AdjustAttrib

EditStickhandling					;Create player edit: Stickhandling
	move.l	(PAttribWeight).l,d4
	bra.w	AdjustAttrib

EditShotPower						;Create player edit: ShotPower
	move.l	(PAttribShotAccuracy).l,d4
	bra.w	AdjustAttrib

EditShotAcc							;Create player edit: ShotAcc
	move.l	(PAttribPassAccuracy).l,d4
	bra.w	AdjustAttrib

EditPassAcc							;Create player edit: PassAcc
	move.l	(PAttribStickHandling).l,d4
	bra.w	AdjustAttrib

EditChecking						;Create player edit: Checking
	move.l	(PAttribChecking).l,d4
	bra.w	AdjustAttrib

EditNone							;Create player edit: nothing
	rts

ClearAttribDeltas					;Clear 16-byte attribute buffer AttribDeltas
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#$FFFFC8E2,a0
	move.w	#3,d0
.loop
	clr.l	(a0)+
	dbf	d0,.loop
	movem.l	(sp)+,d0-d7/a0-a6
	rts

LoadCreateTemplate					;Copy 32-word player template (index CreateIndex) from SRCreatedPlayers
									;into byte record CreateRecord, set
									;CreateType from last byte
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#$1F,d0
	movea.l	#$20259C,a0
	move.w	($FFFF55FE).l,d1
	asl.w	#5,d1
	add.w	d1,d1
	adda.w	d1,a0
	movea.l	#CreatePoints+2,a1
.loop
	move.w	(a0)+,d2
	move.b	d2,(a1)+
	dbf	d0,.loop
	clr.w	($FFFF7534).l
	movea.l	#CreatePoints+2,a1
	adda.w	(a1),a1
	move.b	8(a1),($FFFF7535).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

SetPointsPool						;CreatePoints for a goalie or a skater
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#$1E0,(CreatePoints).l
	tst.w	($FFFF7534).l
	beq.w	.1
	move.w	#$1C2,(CreatePoints).l
.1
	movem.l	(sp)+,d0-d7/a0-a6
	rts

CommitCreatedPlayer					;Commit the created player: the attribute deltas into the record
									;(CommitAttribJumps), then save RAM
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#CreatePoints+2,a0
	adda.w	(a0),a0
	movea.l	#$FFFFC8E2,a2
	move.w	#$F,d0
.loop
	move.w	d0,d1
	lsr.w	#1,d1
	movem.l	d1/a0,-(sp)
	clr.w	d2
	clr.w	d3
	move.b	(a0,d1.w),d3
	move.b	(a2,d0.w),d2
	btst	#0,d0
	bne.w	.1
	lsr.w	#4,d3
.1
	andi.w	#$F,d3
	movea.l	#CommitAttribJumps,a1
	move.w	d0,d1
	asl.w	#2,d1
	movea.l	(a1,d1.w),a1
	jsr	(a1)
	movem.l	(sp)+,d1/a0
	move.b	(a0,d1.w),d2
	btst	#0,d0
	bne.w	.2
	andi.w	#$F,d2
	lsl.w	#4,d3
	andi.w	#$F0,d3
	bra.w	.3
.2
	andi.w	#$F0,d2
	andi.w	#$F,d3
.3
	or.w	d3,d2
	move.b	d2,(a0,d1.w)
	dbf	d0,.loop
	movea.l	#CreatePoints+2,a0
	clr.l	d0
	move.w	($FFFF55FE).l,d0
	asl.w	#5,d0
	ext.l	d0
	addi.l	#$12CE,d0
	moveq	#$20,d1
	jsr	(WriteSRAM).l
	bclr	#6,(GameFlags).w
	jsr	(MakeSRAMChecksum).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

CommitAttribJumps					;CommitCreatedPlayer: the routine of each attribute
	dc.l	CommitNone1,CommitNone1,CommitNone2,CrScale,CrScale,CrScale
	dc.l	CrScale,CrScale,CrScale,CrScaleEven,CrScaleLookup,CrScale
	dc.l	CrScale,CrScale,CrScale,CrScale

CrScale								;d3 += d2/14 (signed)
	ext.l	d2
	divs.w	#$E,d2
	add.w	d2,d3
	rts

CommitNone1							;Nothing to commit
	rts

CommitNone2							;Nothing to commit
	rts

CrScaleEven							;Scale even part of d3 via CrScale, keep low bit of d3 Code the listing
	move.w	d3,-(sp)
	andi.w	#$FE,d3
	jsr	(CrScale).l
	move.w	d3,d2
	move.w	(sp)+,d3
	andi.w	#1,d3
	andi.w	#$FE,d2
	or.w	d2,d3
	rts

CrScaleLookup						;CrScale
	bsr.s	CrScale
	rts

CreateRatingsGfx					;Set up the create player ratings screen: vram, fonts, the bitmaps and the
									;help lines
	bset	#5,(sflags12).w
	move.l	#$12D46,(VBint).w
	bclr	#dfok,(disflags).w
	bset	#dfng,(disflags).w
	bclr	#df32c,(disflags).w
	move.w	#0,(VSCRLPM).w
	move.w	#$B400,(VSPRITES).w
	move.w	#$B800,(VmMAP3).w
	move.w	#5,(Map3col1).w
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
	movea.l	#CreateRatingsSprites,a1
	jsr	(LoadScreenSprite).l
	move.w	d4,(smallfontchars).w
	movea.l	#$179170,a2
	jsr	(DecompressGraphicsPlain).l
	move.w	d4,(smallfont2chars).w
	movea.l	#$17A16C,a2
	jsr	(DecompressGraphicsPlain).l
	move.l	#$179168,(smallfontptr).w
	jsr	(printsmallz).l
	String	$FF,1,$FD,0,$FC
	moveq	#$28,d0
	moveq	#$1C,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	jsr	(printcurz).l
	String	-(TXPRI+TXMAP1),0,0
	movea.l	#CreateRatingsBgMap,a0
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
	String	-(TXPRI+TXMAP1),$B,1
	movea.l	#CreateTitleMap,a0
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
	move.w	(smallfontchars).w,-(sp)
	move.w	(smallfont2chars).w,(smallfontchars).w
	jsr	(printcurz).l
	String	$8F,$C,$1A,'{}-select rating'
	move.w	(sp)+,(smallfontchars).w
	jsr	(printcurz).l
	String	$8F,$1A,$13,'a=decrease',$8F,$1A,$14,'b=increase',$8F,$1A,$15,'start=done'
	move.w	#$2500,sr
	rts

CalcAttribRating					;The rating sum of CalcAttrib: d0 / d1 = weighted sum of the attributes in
									;d4 bits (weights a6), d1 the maximum. With AttribWgtList (create player)
									;it clamps the attribute to 0-$63 and adjusts CreatePoints
	clr.w	(attribsum).w
	clr.w	(attribcount).w
	clr.w	d0
	clr.w	d1
	moveq	#$F,d2
	swap	d4
.bit
	btst	d2,d4
	beq.w	.next
	move.w	d2,d3
	lsr.w	#1,d3
	neg.w	d3
	move.b	-1(a0,d3.w),d3
	btst	#0,d2
	beq.w	.1
	lsr.w	#4,d3
.1
	andi.w	#$F,d3
	cmp.w	#$D,d2
	bne.w	.0
	bra.w	.add
.0
	tst.w	d2
	bne.w	.2
	cmp.b	#6,d3
	ble.w	.2
	subq.b	#6,d3
.2
	cmp.w	#5,d2
	bne.w	*+4
.3
	cmp.w	#6,d2
	beq.w	.add
	movem.l	d5-d7,-(sp)
	move.b	(a6,d2.w),d5
	ext.w	d5
	cmp.w	#2,d5
	beq.w	.5
	move.w	d3,-(sp)
	subq.w	#2,d5
.attribadd
	add.w	(sp),d3
	dbf	d5,.attribadd
	asr.w	#1,d3
	tst.w	(sp)+
.5
	movem.l	(sp)+,d5-d7
	cmpa.l	#AttribWgtList2,a6
	beq.w	.create
	neg.w	d2
	move.w	d7,-(sp)
	move.b	-1(a4,d2.w),d7
	ext.w	d7
	add.w	d7,(attribsum).w
	addq.w	#1,(attribcount).w
	move.w	(sp)+,d7
	neg.w	d2
	bra.w	.add
.create
	move.w	d3,-(sp)
	asl.w	#4,d3
	add.w	(sp),d3
	add.w	(sp)+,d3
	neg.w	d2
	add.b	-1(a4,d2.w),d3
	bpl.w	.chkmax
	clr.b	d3
	addq.b	#1,-1(a4,d2.w)
	subq.w	#1,(CreatePoints).l
.chkmax
	cmp.b	#$63,d3
	ble.w	.pos
	move.b	#$63,d3
	subq.b	#1,-1(a4,d2.w)
	addq.w	#1,(CreatePoints).l
.pos
	neg.w	d2
.add
	add.w	d3,d0
	addi.w	#$64,d1
.next
	dbf	d2,.bit
	cmpa.l	#AttribWgtList2,a6
	beq.w	.11
	move.w	#$64,d1
	movem.l	d6-d7,-(sp)
	move.w	(attribsum).w,d6
	ext.l	d6
	move.w	(attribcount).w,d7
	divs.w	d7,d6
	add.w	d6,d0
	movem.l	(sp)+,d6-d7
.11
	cmp.w	d1,d0
	blt.w	.4
	move.w	d0,d1
	subq.w	#1,d0
.4
	bsr.w	MinOverallRating
	rts

MinOverallRating					;For an overall rating (d4 = PAttribOverallMask or GAttribOverallMask): d0
									;at least (d1 + 3) / 4
	cmp.l	(PAttribOverallMask).l,d4
	beq.w	.0
	cmp.l	(GAttribOverallMask).l,d4
	bne.w	.2
.0
	movem.l	d1,-(sp)
	addq.w	#3,d1
	asr.w	#2,d1
	cmp.w	d1,d0
	bge.w	.1
	move.w	d1,d0
.1
	movem.l	(sp)+,d1
.2
	rts

OvrPlayerWgtList2					;Skater attribute weights for the overall rating (CalcAttribRating)
	dc.b	$02,$02,$02,$02,$04,$06,$02,$04,$02,$04,$06,$06,$04,$02,$02,$02

OvrGoalWgtList2						;Goalie attribute weights
	dc.b	$02,$02,$02,$02,$02,$02,$02,$02,$09,$09,$02,$02,$09,$02,$02,$02

AttribWgtList2						;Single attribute weights (create player)
	dc.b	$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02

ClearFreeAgentStats					;Clear the saved stat words of the free agent slots in save RAM
	movem.l	d0-d1/a0,-(sp)
	move.l	#$DE6,d0
	moveq	#$78,d1
	jsr	(ClearSRAMBytes).l
	movem.l	(sp)+,d0-d1/a0
	rts

ClearCreatedPlayers					;Clear the created players list at M68K_RAM+$DB4 (20 x $8000 + 0
									;terminator)
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#M68K_RAM+$DB4,a0
	move.w	#$13,d6
.loop
	move.w	#$8000,(a0)+
	dbf	d6,.loop
	move.b	#0,(M68K_RAM+$DDC).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

DeleteCreatedPlayer					;Delete created player #TempWord1: remove it from the save RAM records,
									;roster list and team lines
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#$1C,d7
	bset	#6,(GameFlags).w
	move.w	(TempWord1).w,d0
	andi.w	#$FF,d0
	movem.w	d0/d7,-(sp)
	jsr	(GetCreatedId).l
	move.w	d0,(a2)+
	movem.w	(sp)+,d0/d7
	jsr	(GetJerseyNumber).l
	move.w	(jerseynum).w,(a2)+
	movea.l	#CalTeam,a0
	jsr	(ReadCreateList).l
	move.w	(TempWord1).w,d0
	andi.w	#$FF,d0
	add.w	d0,d0
	cmp.w	#$26,d0
	bne.w	.1
	move.w	#$8000,(StandingsOrder+8).w
	bra.w	.2
.1
	move.w	#$26,d3
.loop
	move.w	2(a0,d0.w),d1
	move.w	d1,(a0,d0.w)
	addq.w	#2,d0
	cmp.w	d3,d0
	blt.s	.loop
	move.w	#$8000,(a0,d0.w)
.2
	move.w	d0,-(sp)
	move.w	#$28,d0
	subq.b	#1,(a0,d0.w)
	move.w	(sp)+,d0
	jsr	(WriteCreateList).l
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#$201BCC,a0
	move.w	(TempWord1).w,d0
	andi.w	#$FF,d0
	mulu.w	#$C,d0
	adda.l	d0,a0
	move.l	a0,-(sp)
	move.w	#2,d2
.loop2
	move.b	1(a0),(a2)+
	move.b	3(a0),(a2)+
	addq.w	#4,a0
	dbf	d2,.loop2
	movea.l	(sp)+,a0
	move.w	(TempWord1).w,d0
	andi.w	#$FF,d0
.loop3
	cmp.w	#$13,d0
	beq.w	.3
	move.l	$C(a0),(a0)
	move.l	$10(a0),4(a0)
	move.l	$14(a0),8(a0)
	adda.w	#$C,a0
	addq.w	#1,d0
	bra.s	.loop3
.3
	addq.w	#6,a2
	clr.w	d7
	moveq	#3,d2
	moveq	#$14,d3
	move.l	#$6EE8,d1
	jsr	(DeleteStatSlot).l
	movem.l	(sp)+,d0-d7/a0-a6
	jsr	(MakeSRAMChecksum).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

GetCreatedId						;The player id word of created entry d0
	movem.l	d1-d7/a0-a6,-(sp)
	movea.l	#$201B68,a0
	add.w	d0,d0
	add.w	d0,d0
	adda.w	d0,a0
	move.w	2(a0),d0
	andi.w	#$FF,d0
	move.w	(a0),d7
	lsl.w	#8,d7
	andi.w	#$FF00,d7
	or.w	d7,d0
	movem.l	(sp)+,d1-d7/a0-a6
	rts

ReadCreateList						;Read the created players list from save RAM
	movem.l	d0-d1,-(sp)
	move.l	#$DB4,d0
	moveq	#$29,d1
	jsr	(ReadSRAM).l
	movem.l	(sp)+,d0-d1
	rts

WriteCreateList						;Write the created players list to save RAM
	movem.l	d0-d1,-(sp)
	move.l	#$DB4,d0
	moveq	#$29,d1
	jsr	(WriteSRAM).l
	movem.l	(sp)+,d0-d1
	rts

SignFreeAgents						;The sign free agents screen (roster menu item Sign Free Agents) Code the
	jsr	(forceblack).l
	bsr.w	SetupFreeAgentsVideo
	movea.l	#SignPlayersSprites,a0
	jsr	(DrawScreenSprite).l
	jsr	(PStatsPalette2).l
	bsr.w	DrawFreeAgentStartExit
	move.w	#3,d0
	movea.l	#$FFFFC8E2,a0
.loop
	clr.l	(a0)+
	dbf	d0,.loop
	clr.w	(homelogochars).l
	clr.w	(TeamSelectRedraw).l
	bsr.w	DrawFreeAgentTeamHeader
	move.w	#$18,(palcount).w
	bclr	#2,(disflags).w
.loop2
	bsr.w	TestFreeAgentFlag
	beq.w	DrawFreeAgentsClearD0
	move.w	(homelogochars).l,d7
	jsr	(CheckTeamLines).l
	clr.w	(pstatsblockchars).l
	move.w	(SaveRAM+$1BB8).l,d0
	subq.b	#1,d0
	andi.w	#$FF,d0
	cmp.w	#9,d0
	ble.w	.1
	move.w	#9,d0
.1
	move.w	d0,(pstatscount).l
	movea.l	#$FFFF3A98,a0
	bsr.w	BuildFreeAgentList
	bsr.w	FillFreeAgentList
	move.w	#$FFFF,($FFFFD014).w
SignFreeAgentsRedraw	equ	*	;Redraw the free agent screen and wait for the next frame
	jsr	(WaitMenuFrame).l
	bsr.w	DrawFreeAgentTeamHeader
	jsr	(WaitMenuFrame).l
	bsr.w	DrawFreeAgents
	bsr.w	FreeAgentArrows
	move.w	#$2500,sr
	bra.w	.loop4
.loop3
	cmpi.w	#$FFFF,($FFFFD014).w
	beq.w	.loop4
	jsr	(WaitMenuFrame).l
	bsr.w	DrawFreeAgentTeamHeader
	jsr	(WaitMenuFrame).l
	bsr.w	DrawFreeAgents
	jsr	(WaitMenuFrame).l
	bsr.w	FreeAgentArrows
.loop4
	move.w	#$FFFF,($FFFFD014).w
	bsr.w	ReadFreeAgentPads
	tst.w	d1
	beq.w	DrawFreeAgentsExit
	btst	#0,d1
	beq.w	.3
	tst.w	(TeamSelectRedraw).l
	beq.w	.2
	subq.w	#1,(TeamSelectRedraw).l
	bra.s	SignFreeAgentsRedraw
.2
	tst.w	(pstatsblockchars).l
	beq.s	.loop4
	subq.w	#1,(pstatsblockchars).l
	subq.w	#1,(pstatscount).l
	bra.w	SignFreeAgentsRedraw
.3
	btst	#1,d1
	beq.w	.5
	move.w	(TeamSelectRedraw).l,d0
	add.w	(pstatsblockchars).l,d0
	cmp.w	(pstatscount).l,d0
	beq.w	.4
	addq.w	#1,(TeamSelectRedraw).l
	bra.w	SignFreeAgentsRedraw
.4
	move.w	(SaveRAM+$1BB8).l,d0
	andi.w	#$FF,d0
	subq.w	#1,d0
	cmp.w	(pstatscount).l,d0
	ble.s	.loop4
	addq.w	#1,(pstatsblockchars).l
	addq.w	#1,(pstatscount).l
	bra.w	SignFreeAgentsRedraw
.5
	btst	#4,d1
	beq.w	.6
	addq.w	#1,(homelogochars).l
	cmpi.w	#$1A,(homelogochars).l
	blt.w	SignFreeAgentsRedraw
	clr.w	(homelogochars).l
	bra.w	SignFreeAgentsRedraw
.6
	btst	#6,d1
	beq.w	.7
	subq.w	#1,(homelogochars).l
	bpl.w	SignFreeAgentsRedraw
	move.w	#$19,(homelogochars).l
	bra.w	SignFreeAgentsRedraw
.7
	btst	#7,d1
	bne.w	DrawFreeAgentsExit
	btst	#5,d1
	beq.w	.13
	move.w	(homelogochars).l,d7
	movea.l	#$FFFF4E20,a0
	move.w	(pstatsblockchars).l,d0
	add.w	(TeamSelectRedraw).l,d0
	add.w	d0,d0
	move.w	(a0,d0.w),d0
	movem.w	d7,-(sp)
	move.w	#$1C,d7
	andi.w	#$FF,d0
	jsr	(GetPositionSlot).l
	move.w	d0,(recwins).w
	tst.w	d0
	movem.w	(sp)+,d7
	bne.w	.8
	bsr.w	CompareGoalieCountToThree
	beq.w	DrawFreeAgentCursor
	bne.w	.9
.8
	jsr	(GetPlayerCountD7).l
	move.w	d0,-(sp)
	jsr	(GetGoalieCountD7).l
	sub.w	(sp)+,d0
	neg.w	d0
	cmp.w	#$18,d0
	beq.w	DrawFreeAgentCursor
.9
	movea.l	#$FFFF4E20,a0
	move.w	(pstatsblockchars).l,d0
	add.w	(TeamSelectRedraw).l,d0
	add.w	d0,d0
	move.w	(a0,d0.w),d0
	move.w	d0,(TempWord1).w
	move.w	#$1C,d7
	move.w	(TempWord1).w,d0
	jsr	(GetJerseyNumber).l
	move.b	(jerseynum+1).w,(TempWord1).w
	movea.l	#nameentryvis+2,a2
	move.w	(TempWord1).w,-(sp)
	bclr	#6,(GameFlags).w
	jsr	(DeleteCreatedPlayer).l
	move.w	(sp)+,(TempWord1).w
	move.w	(homelogochars).l,(TempMaxSpd).w
	move.w	(recwins).w,d0
	move.w	d0,(vislogochars).l
	move.w	(homelogochars).l,d7
	tst.w	d0
	beq.w	.10
	jsr	(GetPlayerCountD7).l
	bra.w	.11
.10
	jsr	(GetGoalieCountD7).l
.11
	move.w	(vislogochars).l,d1
	lsl.w	#8,d1
	or.w	d1,d0
	move.w	d0,(TempWord2).w
	move.w	(homelogochars).l,(TempMaxSpd).w
	movea.l	#nameentryvis+2,a2
	move.w	(TempWord1).w,-(sp)
	move.w	(TempWord2).w,-(sp)
	move.w	(TempMaxSpd).w,-(sp)
	jsr	(InsertTradedPlayer).l
	move.w	(sp)+,(TempMaxSpd).w
	move.w	(sp)+,(TempWord2).w
	move.w	(sp)+,(TempWord1).w
	bclr	#6,(GameFlags).w
	jsr	(MakeSRAMChecksum).l
	bsr.w	EraseFreeAgentBoxes
	tst.w	(TeamSelectRedraw).l
	beq.w	.12
	subq.w	#1,(TeamSelectRedraw).l
.12
	bra.w	.loop2
.13
	bra.w	.loop3
CompareGoalieCountToThree			;d0 = goalie count of the team; flags from cmp #3
	jsr	(GetGoalieCountD7).l
	cmp.w	#3,d0
	rts

FreeAgentArrows						;Draw scroll up/down arrows for the list
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(printsmallz).l
	String	$FE,7
	move.w	(pstatsblockchars).l,d0
	add.w	(TeamSelectRedraw).l,d0
	beq.w	.1
	jsr	(printsmallz).l
	String	$FD,2,$FC,$10,'{'
	bra.w	.2
.1
	jsr	(printsmallz).l
	String	$FD,2,$FC,$10,' '
.2
	move.w	(TeamSelectRedraw).l,d1
	add.w	(pstatsblockchars).l,d1
	move.w	(SaveRAM+$1BB8).l,d0
	andi.w	#$FF,d0
	subq.w	#1,d0
	cmp.w	d0,d1
	bge.w	.3
	jsr	(printsmallz).l
	String	$FD,2,$FC,$19,'}'
	bra.w	.4
.3
	jsr	(printsmallz).l
	String	$FD,2,$FC,$19,' '
.4
	jsr	(printsmallz).l
	String	$FE,7
	movem.l	(sp)+,d0-d7/a0-a6
	rts
DrawFreeAgentCursor	equ	*	;Draw the free agent screen cursor
	bsr.w	BuildFreeAgentListHeader
	jsr	(printsmallz).l
	String	$FE,7,$FD,$18,$FC,6,'VIOLATION OF',$FD,$17,$FA,1,'ROSTER RULES'
	bsr.w	ReadFreeAgentPads
	bsr.w	DrawFreeAgentStartExit
	bra.w	SignFreeAgentsRedraw

DrawFreeAgents						;Draw visible free agent rows (pos, name, rating) Code the listing does
	move.w	(TeamSelectRedraw).l,d5
	movea.l	#pstatsblockchars,a5
	movea.l	#$FFFF3A98,a4
	movea.l	#$FFFF4E20,a3
	move.w	#$10,(printy).w
	move.w	#$1C,d7
	move.w	(printy).w,-(sp)
	jsr	(printz).l
	String	$8F,0,0
	move.w	(sp)+,(printy).w
	clr.w	d6
	move.w	(a5),d0
	asl.w	#1,d0
	ext.l	d0
	adda.l	d0,a4
	adda.l	d0,a3
.loop
	jsr	(printsmallz).l
	String	$FD,2,'               ',$FB,2,'               '
	move.w	#3,(printx).w
	jsr	(printsmallz).l
	String	$FE,7
	cmp.w	d5,d6
	bne.w	.1
	jsr	(printsmallz).l
	String	$FE,6
.1
	move.w	(a3),d0
	move.w	#$1C,d7
	jsr	(FormatPlayerNameD7).l
	jsr	(printcur).l
	move.w	#$16,(printx).w
	movea.l	#PositionLetters,a1
	move.w	#$1C,d7
	move.w	(a3)+,d0
	jsr	(GetPositionSlot).l
	move.w	d0,(vislogochars).l
	jsr	(SkipStrings).l
	jsr	(printcur).l
	move.w	#$1F,(printx).w
	move.w	(a4),d0
	jsr	(GetCreatedName).l
	adda.w	(a1),a1
	addq.w	#8,a1
	movea.l	a1,a0
	movem.l	a4,-(sp)
	movea.l	#$FFFFC8F2,a4
	movea.l	#OvrGoalWgtList2,a6
	move.l	(GAttribOverallMask).l,d4
	tst.w	(vislogochars).l
	beq.w	.2
	movea.l	#OvrPlayerWgtList2,a6
	move.l	(PAttribOverallMask).l,d4
.2
	jsr	(CalcAttribRating).l
	movem.l	(sp)+,a4
	mulu.w	#$64,d0
	divu.w	d1,d0
	jsr	(SoftClampCoord).l
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printcur).l
	addq.l	#2,a4
	addq.w	#1,(printy).w
	addq.w	#1,d6
	move.w	(pstatsblockchars).l,d0
	add.w	d6,d0
	cmp.w	(pstatscount).l,d0
	ble.w	.loop
	rts
ReadFreeAgentPads					;Free agents screen: wait one frame and read the pad
	move.l	#$5460,d6
.loop
	move.w	#$64,d6
	move.w	(Vcount).w,d1
	sub.w	(OldVcount).w,d1
	beq.s	.loop
	move.w	(Vcount).w,(OldVcount).w
	jsr	(SetMenuScroll).l
	jsr	(ReadJoy1).l
	jsr	(ProcessInputWithRepeat).l
	tst.w	d1
	beq.w	.1
	bra.w	.5
.1
	jsr	(ReadJoy2).l
	jsr	(ProcessInputWithRepeat).l
	tst.w	d1
	beq.w	.2
	bra.w	.5
.2
	tst.w	(FourWayPlay).w
	beq.w	.4
	jsr	(ReadJoy3).l
	jsr	(ProcessInputWithRepeat).l
	tst.w	d1
	beq.w	.3
	bra.w	.5
.3
	jsr	(ReadJoy4).l
	jsr	(ProcessInputWithRepeat).l
	tst.w	d1
	beq.w	.4
	bra.w	.5
.4
	dbf	d6,.loop
.5
	rts
DrawFreeAgentsExit	equ	*
	rts
DrawFreeAgentsClearD0	equ	*
	clr.w	d0
	bra.w	.6
.6
	movem.w	d0-d2,-(sp)
	bsr.w	BuildFreeAgentListHeader
	movem.w	(sp)+,d0-d2
	movea.l	#FreeAgentMsgText,a1
	jsr	(SkipStrings).l
	jsr	(printcur).l
	bsr.w	ReadFreeAgentPads
	bra.s	DrawFreeAgentsExit

FreeAgentMsgText					;SignFreeAgents: the message when there are no free agents
	String	CC_Font1Pal3Pri,$18,$06,'No free agents.',CC_Font1Pal3Pri,$17,$07,'Press Any button',CC_Font1Pal3Pri,$16,$08,'to exit.'
	dc.b	$4E,$75

BuildFreeAgentList					;Copy the free agent list from save RAM to a work table and an index list
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(SaveRAM+$1BB8).l,d0
	andi.w	#$FF,d0
	beq.w	.1
	subq.w	#1,d0
	movea.l	#$201B68,a0
	movea.l	#$FFFF3A98,a1
	movea.l	#$FFFF4E20,a5
	clr.w	d6
.loop
	move.l	(a0)+,d1
	move.b	d1,d2
	andi.w	#$FF,d2
	swap	d1
	lsl.w	#8,d1
	or.w	d1,d2
	move.w	d2,(a1)+
	move.w	d6,(a5)+
	addq.w	#1,d6
	dbf	d0,.loop
.1
	movem.l	(sp)+,d0-d7/a0-a6
	rts
FillFreeAgentList	equ	*	;Fill the free agent list with the players of the free agent pool
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(SaveRAM+$1BB8).l,d5
	andi.w	#$FF,d5
	cmp.w	#2,d5
	blt.w	.3
	subq.w	#2,d5
	move.w	#$1C,d7
.loop2
	movea.l	#$FFFF3A98,a0
	movea.l	#$FFFF4E20,a1
	move.w	d5,d4
	clr.w	d6
.loop3
	move.w	(a1),d0
	jsr	(GetPositionSlot).l
	move.w	d0,-(sp)
	move.w	2(a1),d0
	jsr	(GetPositionSlot).l
	cmp.w	(sp)+,d0
	bge.w	.2
	st	d6
	move.w	(a1),d0
	move.w	2(a1),d2
	move.w	d0,2(a1)
	move.w	d2,(a1)
	move.w	(a0),d0
	move.w	2(a0),d2
	move.w	d0,2(a0)
	move.w	d2,(a0)
.2
	addq.w	#2,a0
	addq.w	#2,a1
	dbf	d4,.loop3
	tst.w	d6
	bne.s	.loop2
.3
	movem.l	(sp)+,d0-d7/a0-a6
	rts
TestFreeAgentFlag	equ	*	;Set the flags from the free agent record flag at $201BB8
	movem.w	d0,-(sp)
	move.w	(SaveRAM+$1BB8).l,d0
	tst.b	d0
	movem.w	(sp)+,d0
	rts
SetupFreeAgentsVideo	equ	*	;Set the VBint handler, scroll and map addresses for the free agents screen and load its graphics
	bset	#5,(sflags12).w
	move.l	#VBlank_Menus,(VBint).w
	bclr	#dfok,(disflags).w
	bset	#dfng,(disflags).w
	bclr	#df32c,(disflags).w
	move.w	#0,(VSCRLPM).w
	move.w	#$B800,(VSPRITES).w
	move.w	#$B800,(VmMAP3).w
	move.w	#5,(Map3col1).w
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
	movea.l	#SignPlayersSprites,a1
	jsr	(LoadScreenSprite).l
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
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),0,0
	movea.l	#SignReleaseBgMap,a0
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
	movea.l	#SignPlayersTitleMap,a0
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
	move.w	d4,($FFFF2328).l
	addi.w	#$C8,d4
	bset	#2,(sflags11).w
	jsr	(printbigz).l
	String	$F8,4,1,$15,$C,'pos',$F8,4,1,$1C,$C,'overall'
	move.w	#$2500,sr
	rts
DrawFreeAgentTeamHeader	equ	*	;Print the team heading of the free agents screen
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(homelogochars).l,d7
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),1,4
	move.w	($FFFF2328).l,d4
	move.w	#2,d5
	jsr	(DrawTeamLogoD7).l
	move.w	#$64,(palcount).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts
BuildFreeAgentListHeader	equ	*	;Print the free agent list header
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(printsmallz).l
	String	$FE,7,$FF,1,$FD,$18,$FC,6,'               ',$FD,$17,$FA,1,'                ',$FD,$16,$FA,1,'                 ',$FD,$15,$FA,1,'                 '
	movem.l	(sp)+,d0-d7/a0-a6
	rts
DrawFreeAgentStartExit	equ	*	;Print the start-exit hint of the free agents screen
	movem.l	d0-d7/a0-a6,-(sp)
	bsr.s	BuildFreeAgentListHeader
	jsr	(printcurz).l
	String	$8F,$18,6
	jsr	(printsmallz).l
	String	'start-exit',$FD,$17,$FA,1,'c-sign player',$FD,$16,$FA,1,'{}select player',$FD,$15,$FA,1,'a/b-switch teams'
	movem.l	(sp)+,d0-d7/a0-a6
	rts
EraseFreeAgentBoxes	equ	*	;Erase the two message boxes of the free agents screen
	jsr	(printz).l
	String	$8F,2,$10
	move.w	#$7FF,d2
	move.w	#$E,d0
	move.w	#$A,d1
	jsr	(eraser).l
	jsr	(printz).l
	String	$8F,$14,$10
	move.w	#$7FF,d2
	move.w	#$10,d0
	move.w	#$A,d1
	jmp	(eraser).l

ReleasePlayers						;The release player screen (roster menu item Release Player) Code the
	jsr	(forceblack).l
	jsr	(ReleaseGfx).l
	movea.l	#ReleasePlayersSprites,a0
	jsr	(DrawScreenSprite).l
	jsr	(PStatsPalette2).l
	bsr.w	DrawReleaseFooter
	clr.w	(homelogochars).l
	clr.w	(TeamSelectRedraw).l
	move.w	#0,(HomeTeam).w
	move.w	#0,(VisTeam).w
	jsr	(clearTeamStats).l
	bsr.w	DrawFreeAgentTeamHeader
	move.w	#$18,(palcount).w
	bclr	#2,(disflags).w
.loop
	move.w	(SaveRAM+$1BB8).l,d0
	andi.w	#$FF,d0
	cmp.w	#$14,d0
	bge.w	DrawReleaseRosterClearD0
	clr.w	(pstatsblockchars).l
	move.w	(homelogochars).l,d7
	jsr	(CheckTeamLines).l
	move.w	d7,(HomeTeam).w
	move.w	d7,(VisTeam).w
	jsr	(clearTeamStats).l
	jsr	(GetPlayerCountD7).l
	subq.w	#1,d0
	cmp.w	#9,d0
	ble.w	.1
	move.w	#9,d0
.1
	move.w	d0,(pstatscount).l
	movea.l	#$FFFF3A98,a0
	movea.l	#$FFFF2AF8,a1
	bsr.w	FillTradeRosterList
	bsr.w	SortReleaseList
	move.w	#$FFFF,($FFFFD014).w
ReleasePlayersWait	equ	*	;Wait for a frame and redraw the release screen
	jsr	(WaitMenuFrame).l
	bsr.w	DrawFreeAgentTeamHeader
	jsr	(WaitMenuFrame).l
	bsr.w	DrawReleaseRosterSaveSR
	bsr.w	ReleaseArrows
.loop2
	cmpi.w	#$FFFF,($FFFFD014).w
	beq.w	.loop3
	jsr	(WaitMenuFrame).l
	bsr.w	DrawFreeAgentTeamHeader
	jsr	(WaitMenuFrame).l
	bsr.w	DrawReleaseRosterSaveSR
.loop3
	move.w	#$FFFF,($FFFFD014).w
	bsr.w	ReadReleasePads
	tst.w	d1
	beq.w	DrawReleaseRosterExit
	btst	#0,d1
	beq.w	.3
	tst.w	(TeamSelectRedraw).l
	beq.w	.2
	subq.w	#1,(TeamSelectRedraw).l
	bra.s	ReleasePlayersWait
.2
	tst.w	(pstatsblockchars).l
	beq.s	.loop3
	subq.w	#1,(pstatsblockchars).l
	subq.w	#1,(pstatscount).l
	bra.s	ReleasePlayersWait
.3
	btst	#1,d1
	beq.w	.5
	move.w	(TeamSelectRedraw).l,d0
	add.w	(pstatsblockchars).l,d0
	cmp.w	(pstatscount).l,d0
	beq.w	.4
	addq.w	#1,(TeamSelectRedraw).l
	bra.w	ReleasePlayersWait
.4
	move.w	(homelogochars).l,d7
	jsr	(GetPlayerCountD7).l
	subq.w	#1,d0
	cmp.w	(pstatscount).l,d0
	ble.s	.loop3
	addq.w	#1,(pstatsblockchars).l
	addq.w	#1,(pstatscount).l
	bra.w	ReleasePlayersWait
.5
	btst	#4,d1
	beq.w	.6
	clr.w	(TeamSelectRedraw).l
	clr.w	(pstatsblockchars).l
	move.w	#9,(pstatscount).l
	addq.w	#1,(homelogochars).l
	cmpi.w	#$1A,(homelogochars).l
	blt.w	.loop
	clr.w	(homelogochars).l
	bra.w	.loop
.6
	btst	#6,d1
	beq.w	.7
	clr.w	(TeamSelectRedraw).l
	clr.w	(pstatsblockchars).l
	move.w	#9,(pstatscount).l
	subq.w	#1,(homelogochars).l
	bpl.w	.loop
	move.w	#$19,(homelogochars).l
	bra.w	.loop
.7
	btst	#7,d1
	bne.w	DrawReleaseRosterExit
	btst	#5,d1
	beq.w	.11
	move.w	(homelogochars).l,d7
	jsr	(GetPlayerCountD7).l
	cmp.w	#$11,d0
	beq.w	DrawReleaseCursor
	movea.l	#$FFFF3A98,a0
	move.w	(pstatsblockchars).l,d0
	add.w	(TeamSelectRedraw).l,d0
	asl.w	#2,d0
	adda.w	d0,a0
	clr.w	d0
	move.b	1(a0),d0
	bne.w	.8
	jsr	(CheckMinGoalies).l
	beq.w	DrawReleaseCursor
.8
	movea.l	#$FFFF3A98,a0
	move.w	(pstatsblockchars).l,d0
	add.w	(TeamSelectRedraw).l,d0
	asl.w	#2,d0
	adda.w	d0,a0
	move.b	1(a0),(TempWord1).w
	move.b	2(a0),(TempWord1+1).w
	move.w	(homelogochars).l,(TempRawSpd).w
	movea.l	#nameentryvis+2,a2
	jsr	(ExtractTradedPlayer).l
	move.w	(homelogochars).l,($FFFFD016).w
	move.w	(homelogochars).l,($FFFFD01E).w
	movea.l	#$201B68,a0
	clr.w	(rosterscroll).w
.loop4
	tst.b	1(a0)
	bmi.w	.9
	addq.l	#4,a0
	addq.w	#1,(rosterscroll).w
	bra.s	.loop4
.9
	move.w	(nameentryvis+2).w,d0
	andi.w	#$1FFF,d0
	move.b	(TempWord1).w,d1
	andi.w	#3,d1
	move.w	#$D,d2
	lsl.w	d2,d1
	or.w	d1,d0
	move.w	d0,d1
	lsr.w	#8,d1
	andi.w	#$FF,d1
	move.w	d1,(a0)
	andi.w	#$FF,d0
	move.w	d0,2(a0)
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(rosterscroll).w,d0
	mulu.w	#$C,d0
	movea.l	#$201BCC,a0
	adda.l	d0,a0
	movea.l	#nameentryvis+6,a2
	move.w	#2,d2
.loop5
	move.b	(a2)+,1(a0)
	move.b	(a2)+,3(a0)
	addq.w	#4,a0
	dbf	d2,.loop5
	addq.w	#6,a2
	move.w	(TempWord2).w,-(sp)
	move.w	(rosterscroll).w,(TempWord2).w
	clr.w	d7
	moveq	#3,d2
	moveq	#$14,d3
	move.l	#$6EE8,d1
	jsr	(InsertStatSlot).l
	move.w	(sp)+,(TempWord2).w
	movem.l	(sp)+,d0-d7/a0-a6
	addq.w	#1,(SaveRAM+$1BB8).l
	bclr	#6,(GameFlags).w
	jsr	(MakeSRAMChecksum).l
	bsr.w	EraseFreeAgentBoxes
	tst.w	(TeamSelectRedraw).l
	beq.w	.10
	subq.w	#1,(TeamSelectRedraw).l
.10
	bra.w	.loop
.11
	bra.w	.loop2

CheckMinGoalies						;Z if team d7 has only 2 goalies
									;(GetGoalieCountD7), so none can be released
	jsr	(GetGoalieCountD7).l
	cmp.w	#2,d0
	rts

ReleaseArrows						;Draw scroll arrows ({ above / } below) beside the roster list Code the
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(printsmallz).l
	String	$FE,7
	move.w	(pstatsblockchars).l,d0
	add.w	(TeamSelectRedraw).l,d0
	beq.w	.1
	jsr	(printsmallz).l
	String	$FD,2,$FC,$10,'{'
	bra.w	.2
.1
	jsr	(printsmallz).l
	String	$FD,2,$FC,$10,' '
.2
	move.w	(TeamSelectRedraw).l,d1
	add.w	(pstatsblockchars).l,d1
	move.w	(homelogochars).l,d7
	jsr	(GetPlayerCountD7).l
	subq.w	#1,d0
	cmp.w	d0,d1
	bge.w	.3
	jsr	(printsmallz).l
	String	$FD,2,$FC,$19,'}'
	bra.w	.4
.3
	jsr	(printsmallz).l
	String	$FD,2,$FC,$19,' '
.4
	jsr	(printsmallz).l
	String	$FE,7
	movem.l	(sp)+,d0-d7/a0-a6
	rts
DrawReleaseCursor	equ	*	;Draw the release screen cursor
	bsr.w	BuildFreeAgentListHeader
	jsr	(printsmallz).l
	String	$FE,7,$FD,$18,$FC,6,'VIOLATION OF',$FD,$17,$FA,1,'ROSTER RULES'
	bsr.w	ReadReleasePads
	bsr.w	DrawReleaseFooter
	bra.w	ReleasePlayersWait
DrawReleaseRosterSaveSR	equ	*	;Save sr, then fall into DrawReleaseRoster
	move.w	sr,-(sp)

DrawReleaseRoster					;Draw the visible roster rows (pos letter, name, rating) with highlight on
									;cursor row
	move.w	(TeamSelectRedraw).l,d5
	movea.l	#pstatsblockchars,a5
	movea.l	#$FFFF3A98,a4
	move.w	#$10,(printy).w
	move.w	(homelogochars).l,d7
	move.w	(printy).w,-(sp)
	jsr	(printz).l
	String	$8F,0,0
	move.w	(sp)+,(printy).w
	clr.w	d6
	move.w	(a5),d0
	asl.w	#2,d0
	ext.l	d0
	adda.l	d0,a4
.loop
	jsr	(printsmallz).l
	String	$FD,2,'               ',$FB,2,'               '
	move.w	#3,(printx).w
	jsr	(printsmallz).l
	String	$FE,7
	cmp.w	d5,d6
	bne.w	.1
	jsr	(printsmallz).l
	String	$FE,6
.1
	clr.w	d0
	move.b	2(a4),d0
	jsr	(FormatPlayerNameD7).l
	jsr	(printcur).l
	move.w	#$16,(printx).w
	movea.l	#PositionLetters,a1
	clr.w	d0
	move.b	1(a4),d0
	move.w	d0,(vislogochars).l
	jsr	(SkipStrings).l
	jsr	(printcur).l
	move.w	#$1F,(printx).w
	clr.w	d0
	move.b	3(a4),d0
	jsr	(SoftClampCoord).l
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printcur).l
	addq.l	#4,a4
	addq.w	#1,(printy).w
	addq.w	#1,d6
	move.w	(pstatsblockchars).l,d0
	add.w	d6,d0
	cmp.w	(pstatscount).l,d0
	ble.w	.loop
	move.w	(sp)+,sr
	rts
ReadReleasePads						;Release screen: wait one frame and read the pad
	move.l	#$5460,d6
.loop
	move.w	#$64,d6
	move.w	(Vcount).w,d1
	sub.w	(OldVcount).w,d1
	beq.s	.loop
	move.w	(Vcount).w,(OldVcount).w
	jsr	(SetMenuScroll).l
	jsr	(ReadJoy1).l
	jsr	(ProcessInputWithRepeat).l
	tst.w	d1
	beq.w	.1
	bra.w	.5
.1
	jsr	(ReadJoy2).l
	jsr	(ProcessInputWithRepeat).l
	tst.w	d1
	beq.w	.2
	bra.w	.5
.2
	tst.w	(FourWayPlay).w
	beq.w	.4
	jsr	(ReadJoy3).l
	jsr	(ProcessInputWithRepeat).l
	tst.w	d1
	beq.w	.3
	bra.w	.5
.3
	jsr	(ReadJoy4).l
	jsr	(ProcessInputWithRepeat).l
	tst.w	d1
	beq.w	.4
	bra.w	.5
.4
	dbf	d6,.loop
.5
	rts
DrawReleaseRosterExit	equ	*
	rts
DrawReleaseRosterClearD0	equ	*
	clr.w	d0
	bra.w	.6
.6
	movem.w	d0-d2,-(sp)
	bsr.w	BuildFreeAgentListHeader
	movem.w	(sp)+,d0-d2
	movea.l	#ReleaseMsgText,a1
	jsr	(SkipStrings).l
	jsr	(printcur).l
	bsr.w	ReadReleasePads
	bra.s	DrawReleaseRosterExit

ReleaseMsgText						;ReleasePlayers: the message when the free agent list is full
	String	CC_Font1Pal3Pri,$18,$06,'Free agent list',CC_Font1Pal3Pri,$17,$07,'is full.',CC_Font1Pal3Pri,$16,$08,'Press any button',CC_Font1Pal3Pri,$15,$09,'to exit.'
SortReleaseList	equ	*	;Sort the release list by position
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(GetPlayerCountD7).l
	subq.w	#2,d0
	move.w	d0,d5
.loop
	movea.l	#$FFFF3A98,a0
	move.w	d5,d4
	clr.w	d6
.loop2
	move.b	1(a0),d0
	cmp.b	5(a0),d0
	ble.w	.1
	st	d6
	move.l	(a0),d0
	move.l	4(a0),d2
	move.l	d0,4(a0)
	move.l	d2,(a0)
.1
	addq.w	#4,a0
	dbf	d4,.loop2
	tst.w	d6
	bne.s	.loop
	movem.l	(sp)+,d0-d7/a0-a6
	rts

ReleaseGfx							;Release Player screen video set up: fonts, bitmaps and the pos / overall
									;headers
	bset	#5,(sflags12).w
	move.l	#$12D46,(VBint).w
	bclr	#dfok,(disflags).w
	bset	#dfng,(disflags).w
	bclr	#df32c,(disflags).w
	move.w	#0,(VSCRLPM).w
	move.w	#$B800,(VSPRITES).w
	move.w	#$B800,(VmMAP3).w
	move.w	#5,(Map3col1).w
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
	movea.l	#ReleasePlayersSprites,a1
	jsr	(LoadScreenSprite).l
	move.w	d4,(smallfontchars).w
	movea.l	#$179170,a2
	jsr	(DecompressGraphicsPlain).l
	move.w	d4,(smallfont2chars).w
	movea.l	#$17A16C,a2
	jsr	(DecompressGraphicsPlain).l
	move.l	#$179168,(smallfontptr).w
	move.w	d4,(BigFontchars).w
	movea.l	#$17B688,a2
	jsr	(DecompressGraphicsPlain).l
	bset	#2,(sflags11).w
	jsr	(printsmallz).l
	String	$FF,1,$FD,0,$FC
	moveq	#$28,d0
	moveq	#$1C,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),0,0
	movea.l	#SignReleaseBgMap,a0
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
	movea.l	#ReleasePlayersTitleMap,a0
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
	move.w	d4,($FFFF2328).l
	addi.w	#$C8,d4
	bset	#2,(sflags11).w
	jsr	(printbigz).l
	String	$F8,4,1,$15,$C,'pos',$F8,4,1,$1C,$C,'overall'
	move.w	#$2500,sr
	rts
DrawReleaseFooter	equ	*	;Print the footer of the release screen
	movem.l	d0-d7/a0-a6,-(sp)
	bsr.w	BuildFreeAgentListHeader
	jsr	(printcurz).l
	String	$8F,$18,6
	jsr	(printsmallz).l
	String	'start-exit',$FD,$17,$FA,1,'c-release player',$FD,$16,$FA,1,'{}select player',$FD,$15,$FA,1,'a/b-switch teams'
	movem.l	(sp)+,d0-d7/a0-a6
	rts

PStatsPalette2						;The PStatsPalette palette to palfadenew+$40 (sign free agents and release
									;screens)
	movem.l	a0-a1,-(sp)
	movea.l	#PStatsPal,a0
	movea.l	#$FFFFBD7E,a1
	move.w	#7,d0
.loop
	move.l	(a0)+,(a1)+
	dbf	d0,.loop
	movem.l	(sp)+,a0-a1
	rts

CheckTeamLines						;Team d7: clear the $41-byte saved line block at 0 or $C39 if it belongs
									;to that team. Called from ExecuteTrade, SignFreeAgents and ReleasePlayers.
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(SaveRAM).l,d0
	subq.b	#1,d0
	cmp.b	d7,d0
	bne.w	.1
	bsr.w	ClearSavedLinesA
.1
	move.w	(SaveRAM+$1872).l,d0
	subq.b	#1,d0
	cmp.b	d7,d0
	bne.w	.2
	bsr.w	ClearSavedLinesB
.2
	movem.l	(sp)+,d0-d7/a0-a6
	rts
	movem.l	d0-d7/a0-a6,-(sp)
	bsr.w	ClearSavedLinesA
	bsr.w	ClearSavedLinesB
	movem.l	(sp)+,d0-d7/a0-a6
	rts
ClearSavedLinesA					;Clear $41 bytes of save RAM at 0 (ClearSRAMBytes)
	moveq	#0,d0
	moveq	#$41,d1
	jmp	(ClearSRAMBytes).l
ClearSavedLinesB					;Clear $41 bytes of save RAM at $C39 (ClearSRAMBytes)
	move.l	#$C39,d0
	moveq	#$41,d1
	jmp	(ClearSRAMBytes).l

