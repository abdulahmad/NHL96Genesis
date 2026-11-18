;	Player names. GetPlayerName writes a number, a first name and a last name,
;	and the other formatters shorten that.

GetPlayerName						;a1 = mesarea "NN First Last" (getname) for player TempPlOffset (bit 15
									;set: away team)
	movem.l	d0/a2,-(sp)
	movea.w	#(tmstruct-M68K_RAM),a2
	move.w	(TempPlOffset).w,d0
	bpl.w	.0
	andi.w	#$FF,d0
	adda.w	#$39E,a2
.0
	bsr.w	getname
	movem.l	(sp)+,d0/a2
	rts

getname								;a1 = mesarea "NN First Last" for player d0 of team struct a2.
	movem.l	d0-d3/d7-a0/a2-a3,-(sp)
	move.w	$28(a2),d7
	jsr	(GetJerseyNumber).l
	jsr	(GetPlayerNamePointer).l
	move.l	a0,-(sp)
	movea.w	#(mesarea-M68K_RAM),a3
	move.w	#4,(a3)
	lea	2(a3),a1
	adda.w	(a0),a0
	move.w	(jerseynum).w,d0
	bsr.w	ConvertByteToDigits
	bsr.w	appendz
	String	$20
	movea.l	(sp)+,a1
	bsr.w	appstring
	movea.w	#(mesarea-M68K_RAM),a1
	movem.l	(sp)+,d0-d3/d7-a0/a2-a3
	rts

GetPlayerNumInitial					;GetPlayerName with FormatPlayerNumInitial ("NN F. Last")
	movem.l	d0/a2,-(sp)
	movea.w	#(tmstruct-M68K_RAM),a2
	move.w	(TempPlOffset).w,d0
	bpl.w	.0
	andi.w	#$FF,d0
	adda.w	#$39E,a2
.0
	bsr.w	FormatPlayerNumInitial
	movem.l	(sp)+,d0/a2
	rts

FormatPlayerNumInitialShort			;a1 = mesarea string "NN F.Last" for player d0 of team a2, built in
									;TextBuffer.
	movem.l	d0-d3/d7/a0/a2,-(sp)
	move.w	Xvel(a2),d7
	jsr	(GetJerseyNumber).l
	jsr	(GetPlayerNamePointer).l
	move.l	a0,-(sp)
	movea.w	#(TextBuffer-M68K_RAM),a1
	adda.w	(a0),a0
	move.w	(jerseynum).w,d0
	bsr.w	ConvertByteToDigits
	move.b	#$20,(a1)+
	movea.l	(sp)+,a0
	move.w	(a0)+,d0
	lea	-$2(a0,d0.w),a2
	move.b	(a0)+,(a1)+
	move.b	#$2E,(a1)+
.loop
	cmpi.b	#$20,(a0)+
	bne.s	.loop
.loop2
	move.b	(a0)+,(a1)+
	cmpa.l	a0,a2
	bne.s	.loop2
	bsr.w	FinalizeTextBuffer
	movem.l	(sp)+,d0-d3/d7/a0/a2
	rts

FormatPlayerNumInitial				;a1 = mesarea string "NN F. Last" for player d0 of team a2, built in
									;TextBuffer. Called from PenaltyShotBox
									;and others
	movem.l	d0-d3/d7-a0/a2,-(sp)
	move.w	$28(a2),d7
	jsr	(GetJerseyNumber).l
	jsr	(GetPlayerNamePointer).l
	move.l	a0,-(sp)
	movea.w	#(TextBuffer-M68K_RAM),a1
	adda.w	(a0),a0
	move.w	(jerseynum).w,d0
	bsr.w	ConvertByteToDigits
	move.b	#$20,(a1)+
	movea.l	(sp)+,a0
	move.w	(a0)+,d0
	lea	-2(a0,d0.w),a2
	move.b	(a0)+,(a1)+
	move.w	#$2E20,(a1)+
.skipfirst
	cmpi.b	#$20,(a0)+
	bne.s	.skipfirst
.copy
	move.b	(a0)+,(a1)+
	cmpa.l	a0,a2
	bne.s	.copy
	bsr.w	FinalizeTextBuffer
	movem.l	(sp)+,d0-d3/d7-a0/a2
	rts

GetPlayerNumLast					;GetPlayerName with FormatPlayerName ("NN Last").
	movem.l	d0/a2,-(sp)
	movea.w	#(tmstruct-M68K_RAM),a2
	move.w	(TempPlOffset).w,d0
	bpl.w	.1
	andi.w	#$FF,d0
	adda.w	#$39E,a2
.1
	bsr.w	FormatPlayerName
	movem.l	(sp)+,d0/a2
	rts

FormatPlayerName					;a1 = mesarea string "NN Last" for player d0 of team a2, built in
									;TextBuffer. Called from ShowGoalBox and
									;others
	movem.l	d0-d3/d7-a0/a2,-(sp)
	move.w	$28(a2),d7
	jsr	(GetJerseyNumber).l
	jsr	(GetPlayerNamePointer).l
	move.l	a0,-(sp)
	movea.w	#(TextBuffer-M68K_RAM),a1
	adda.w	(a0),a0
	move.w	(jerseynum).w,d0
	bsr.w	ConvertByteToDigits
	move.b	#$20,(a1)+
	movea.l	(sp)+,a0
	move.w	(a0)+,d0
	lea	-2(a0,d0.w),a2
.skip
	cmpi.b	#$20,(a0)+
	bne.s	.skip
.copy
	move.b	(a0)+,(a1)+
	cmpa.l	a0,a2
	bne.s	.copy
	bsr.w	FinalizeTextBuffer
	movem.l	(sp)+,d0-d3/d7-a0/a2
	rts

FormatPlayerNameLast				;FormatPlayerNameShort without the leading space ("Last", space padded).
									;Branches into FormatLastName.
	movem.l	d0-d3/a0/a2,-(sp)
	jsr	(GetPlayerNamePointer).l
	movea.w	#(TextBuffer-M68K_RAM),a1
	bra.w	FormatLastName

FormatPlayerNameShort				;a1 = mesarea string " Last" for player d0 of team a2, space padded to 12
									;characters.
	movem.l	d0-d3/a0/a2,-(sp)
	jsr	(GetPlayerNamePointer).l
	movea.w	#(TextBuffer-M68K_RAM),a1
	move.b	#$20,(a1)+

FormatLastName						;Skip the first name, copy the last name, pad; branched to from
									;FormatPlayerNameLast.
	move.w	(a0)+,d0
	lea	-$2(a0,d0.w),a2
.loop
	cmpi.b	#$20,(a0)+
	bne.s	.loop
.loop2
	move.b	(a0)+,(a1)+
	cmpa.l	a0,a2
	beq.w	.1
	tst.b	(a0)
	bne.s	.loop2
	bra.w	.1
.loop3
	move.b	#$20,(a1)+
.1
	cmpa.w	#(TextBuffer+12-M68K_RAM),a1
	blt.s	.loop3
	bsr.w	FinalizeTextBuffer
	movem.l	(sp)+,d0-d3/a0/a2
	rts

GetPlayerInitial					;GetPlayerName with FormatPlayerInitial ("F. Last").
	movem.l	d0/a2,-(sp)
	movea.w	#(tmstruct-M68K_RAM),a2
	move.w	(TempPlOffset).w,d0
	bpl.w	.1
	andi.w	#$FF,d0
	adda.w	#$39E,a2
.1
	bsr.w	FormatPlayerInitial
	movem.l	(sp)+,d0/a2
	rts

FormatPlayerInitial					;a1 = mesarea "F. Last" for player d0 of team a2.
	movem.l	d0-d3/a0/a2,-(sp)
	jsr	(GetPlayerNamePointer).l
	move.l	a0,-(sp)
	movea.w	#(TextBuffer-M68K_RAM),a1
	adda.w	(a0),a0
	move.b	(a0),d0
	movea.l	(sp)+,a0
	move.w	(a0)+,d0
	lea	-$2(a0,d0.w),a2
	move.b	(a0)+,(a1)+
	move.b	#$2E,(a1)+
	move.b	#$20,(a1)+
.loop
	cmpi.b	#$20,(a0)+
	bne.s	.loop
.loop2
	move.b	(a0)+,(a1)+
	cmpa.l	a0,a2
	bne.s	.loop2
	bsr.w	FinalizeTextBuffer
	movem.l	(sp)+,d0-d3/a0/a2
	rts

FinalizeTextBuffer					;mesarea length word = a1 - mesarea, with a 0 pad byte when odd. Returns
									;a1 = mesarea. Called from the
									;FormatPlayerName routines
	move.w	a1,d0
	subi.w	#(mesarea-M68K_RAM),d0
	btst	#0,d0
	beq.w	.even
	clr.b	(a1)+
	addq.w	#1,d0
.even
	movea.w	#(mesarea-M68K_RAM),a1
	move.w	d0,(a1)
	rts

ConvertByteToDigits					;Converts decimal number in d0 to ascii: two ascii digits of bcd byte d0
									;to (a1)+, a leading 0 becomes a space
									;($F0 + '0')
	move.w	d0,-(sp)
	lsr.b	#4,d0
	andi.b	#$F,d0
	bne.w	.0
	move.b	#$F0,d0
.0
	addi.b	#$30,d0
	move.b	d0,(a1)+
	move.w	(sp)+,d0
	andi.w	#$F,d0
	addi.b	#$30,d0
	move.b	d0,(a1)+
	rts

PushNumberWidthZero					;PushNumberWidth with leading zeros: d0 as d1 digits to PushWidthBuf (a
									;String).
	movem.l	d0-d3,-(sp)				;push to stack
	movea.w	#(PushWidthBuf+2-M68K_RAM),a1
	moveq	#1,d2					;move 1 into d2
	sub.w	d2,d1					;sub d2 from d1
	bra.w	.1
.loop
	mulu.w	#$A,d2					;mult d2 by 10 dec
.1
	dbf	d1,.loop
	moveq	#$30,d3
.loop2
	ext.l	d0						;sign extend d0
	divu.w	d2,d0					;divide d2 into d0
	bne.w	.2
	cmp.w	#1,d2					;compare d2 to 1
	beq.w	.2
	move.w	d3,d0					;move d3 into d0
	bra.w	.3
.2
	moveq	#$30,d3					;'0'   ; move 48 dec into d3
	add.w	d3,d0					;add d3 to d0
.3
	move.b	d0,(a1)+				;move d0 into a1 and increment a1
	swap	d0						;swap d0 words
	divu.w	#$A,d2					;divide d2 by 10 dec
	bne.s	.loop2
	move.l	a1,d0					;move a1 into d0
	subi.w	#(PushWidthBuf-M68K_RAM),d0
	btst	#0,d0					;test bit 0 of d0
	beq.w	.4
	clr.b	(a1)+					;clear byte at a1 and increment
	addq.w	#1,d0					;add 1 to d0
.4
	movea.w	#(PushWidthBuf-M68K_RAM),a1
	move.w	d0,(a1)					;move d0 into a1 address location
	movem.l	(sp)+,d0-d3				;push from stack
	rts

