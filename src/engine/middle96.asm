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
									;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$F1,$A0,$3E,$2A,$00,$28,$4E,$B9,$00,$01,$02,$B8,$4E,$B9
	dc.b	$00,$01,$01,$C6,$2F,$08,$32,$7C,$BF,$F4,$D0,$D0,$30,$38,$DD,$AA
	dc.b	$61,$00,$01,$AA,$12,$FC,$00,$20,$20,$5F,$30,$18,$45,$F0,$00,$FE
	dc.b	$12,$D8,$12,$FC,$00,$2E,$0C,$18,$00,$20,$66,$FA,$12,$D8,$B5,$C8
	dc.b	$66,$FA,$61,$00,$01,$6E,$4C,$DF,$05,$8F,$4E,$75

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
									;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$80,$20,$34,$7C,$C7,$26,$30,$38,$C4,$C8,$6A,$00,$00,$0A
	dc.b	$02,$40,$00,$FF,$D4,$FC,$03,$9E,$61,$00,$00,$08,$4C,$DF,$04,$01
	dc.b	$4E,$75

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
									;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$F0,$A0,$4E,$B9,$00,$01,$01,$C6,$32,$7C,$BF,$F4,$60,$00
	dc.b	$00,$14

FormatPlayerNameShort				;a1 = mesarea string " Last" for player d0 of team a2, space padded to 12
									;characters.
									;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$F0,$A0,$4E,$B9,$00,$01,$01,$C6,$32,$7C,$BF,$F4,$12,$FC
	dc.b	$00,$20

FormatLastName						;Skip the first name, copy the last name, pad; branched to from
									;FormatPlayerNameLast.
									;Code the listing does not decode: kept as bytes
	dc.b	$30,$18,$45,$F0,$00,$FE,$0C,$18,$00,$20,$66,$FA,$12,$D8,$B5,$C8
	dc.b	$67,$00,$00,$0E,$4A,$10,$66,$F4,$60,$00,$00,$06,$12,$FC,$00,$20
	dc.b	$B2,$FC,$C0,$00,$6D,$F6,$61,$00,$00,$66,$4C,$DF,$05,$0F,$4E,$75

GetPlayerInitial					;GetPlayerName with FormatPlayerInitial ("F. Last").
									;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$80,$20,$34,$7C,$C7,$26,$30,$38,$C4,$C8,$6A,$00,$00,$0A
	dc.b	$02,$40,$00,$FF,$D4,$FC,$03,$9E,$61,$00,$00,$08,$4C,$DF,$04,$01
	dc.b	$4E,$75

FormatPlayerInitial					;a1 = mesarea "F. Last" for player d0 of team a2.
									;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$F0,$A0,$4E,$B9,$00,$01,$01,$C6,$2F,$08,$32,$7C,$BF,$F4
	dc.b	$D0,$D0,$10,$10,$20,$5F,$30,$18,$45,$F0,$00,$FE,$12,$D8,$12,$FC
	dc.b	$00,$2E,$12,$FC,$00,$20,$0C,$18,$00,$20,$66,$FA,$12,$D8,$B5,$C8
	dc.b	$66,$FA,$61,$00,$00,$08,$4C,$DF,$05,$0F,$4E,$75

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
									;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$F0,$00,$32,$7C,$C0,$58,$74,$01,$92,$42,$60,$00,$00,$06
	dc.b	$C4,$FC,$00,$0A,$51,$C9,$FF,$FA,$76,$30,$48,$C0,$80,$C2,$66,$00
	dc.b	$00,$10,$B4,$7C,$00,$01,$67,$00,$00,$08,$30,$03,$60,$00,$00,$06
	dc.b	$76,$30,$D0,$43,$12,$C0,$48,$40,$84,$FC,$00,$0A,$66,$DC,$20,$09
	dc.b	$04,$40,$C0,$56,$08,$00,$00,$00,$67,$00,$00,$06,$42,$19,$52,$40
	dc.b	$32,$7C,$C0,$56,$32,$80,$4C,$DF,$00,$0F,$4E,$75

