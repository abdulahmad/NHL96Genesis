;	Fighting, new in 96. checkfight starts a fight when two players hit hard enough;
;	startfight and SetInst set the two of them up, fightinput reads their pads, and
;	assfight and assfwatch run the fighters and the players around them. The assignment
;	bytes are what the listing left undecoded.

checkfight	;Look for the start of a fight between players a2 and a3 (impact $A or more on both, no
	;animation lock, no goalie, no faceoff): SetInst both ways, then startfight for both and the other
	;players watch (assignment $15)
	tst.w	(OptFighting).w
	bne.w	.5
	btst	#5,(GameFlags).w
	bne.w	rtsfight
	tst.w	(gsp).w
	beq.w	rtsfight
	cmpi.w	#$A,impact(a3)
	blt.w	rtsfight
	cmpi.w	#$A,impact(a2)
	blt.w	rtsfight
	btst	#5,pflags(a3)
	bne.w	rtsfight
	btst	#5,pflags(a2)
	bne.w	rtsfight
	btst	#4,pflags2(a3)
	bne.w	rtsfight
	btst	#4,pflags2(a2)
	bne.w	rtsfight
	tst.w	position(a3)
	beq.w	rtsfight
	tst.w	position(a2)
	beq.w	rtsfight
	btst	#0,(gmode).w
	bne.w	rtsfight
	btst	#0,(puck_pflags2).w
	bne.w	rtsfight
	cmpi.w	#$10A,Ypos(a3)
	bgt.w	rtsfight
	cmpi.w	#$10A,Ypos(a3)
	bgt.w	rtsfight
	movem.l	d0-d4/a0-a3,-(sp)
	movea.w	#(puckx-M68K_RAM),a0
	move.w	assnum(a0),d0
	cmpi.b	#$1B,asslist(a0,d0.w)
	beq.w	.4
	move.w	(ChkCnt).w,d0
	cmp.w	#$64,d0
	blt.w	.4
	bsr.w	SetInst
	exg	a2,a3
	bsr.w	SetInst
	exg	a2,a3
	btst	#0,pflags2(a3)
	beq.w	.4
	clr.w	(ChkCnt).w
	moveq	#$1B,d0
	movea.w	#(tmstruct+$130-M68K_RAM),a0
.0
	clr.b	$39E(a0)
	clr.b	(a0)+
	dbf	d0,.0
	addi.w	#$3E8,(crowdlevel).w
	addi.w	#$23,(CwdExciteLvl).w
	clr.w	(word_FFDCEA).w
	clr.l	(dword_FFDCE0).w
	clr.l	(dword_FFDCE4).w
	bclr	#1,(sflags10).w
	bclr	#2,(sflags10).w
	bclr	#2,(sflags).w
	bclr	#3,(sflags).w
	move.w	SCnum(a3),(puckc).w
	move.w	Ypos(a3),d1
	add.w	Ypos(a2),d1
	asr.w	#1,d1
	move.w	d1,(yc1).w
	bset	#2,(sflags2).w
	bset	#6,(sflags).w
	moveq	#2,d1
	move.w	(a3),d0
	cmp.w	(a2),d0
	blt.w	.1
	eori.w	#7,d1
.1
	move.w	d1,facedir(a3)
	eori.w	#7,d1
	move.w	d1,facedir(a2)
	move.l	a3,-(sp)
	bsr.w	startfight
	exg	a2,a3
	bsr.w	startfight
	movea.w	#(SortCords-M68K_RAM),a3
	move.l	#$15,d0
	moveq	#$B,d1
.2
	btst	#0,pflags2(a3)
	bne.w	.3
	tst.w	position(a3)	;check if goalie
	beq.w	.3
	btst	#2,pflags2(a3)
	bne.w	.3
	movem.w	d0,-(sp)
	move.w	assnum(a3),d0
	cmpi.b	#$D,asslist(a3,d0.w)
	movem.w	(sp)+,d0
	beq.w	.3
	jsr	(assinsert).l
.3
	adda.w	#$80,a3
	dbf	d1,.2
	movea.w	#(puckx-M68K_RAM),a3
	bset	#0,pflags2(a3)
	move.l	#$1A,d0
	jsr	(assinsert).l
	st	(collflag).w
	movea.l	(sp)+,a3
.4
	movem.l	(sp)+,d0-d4/a0-a3
.5
	rts

startfight	;Start the fight for player a3 against a2: AddPenalty2 $2E, setd0player, assignment $14,
	;push a3 back by facing, the fight SPA and Pencntdwn $140
	move.w	SCnum(a2),impactp(a3)
	move.w	#$2E,d0
	jsr	(AddPenalty2).l
	move.w	#$140,(Pencntdwn).w
	clr.w	(word_FFDCDE).w
	move.w	SCnum(a3),d0
	jsr	(setd0player).l
	move.l	#$14,d0
	jsr	(assinsert).l
	bclr	#3,attribute(a3)
	move.w	#$FC00,d1
	cmpi.w	#2,facedir(a3)
	beq.w	.0
	bset	#3,attribute(a3)
	neg.w	d1
.0
	move.w	d1,Xvel(a3)
	bset	#2,pflags2(a3)
	bclr	#1,pflags2(a3)
	bset	#5,pflags2(a3)
	bclr	#5,pflags(a3)
	move.w	#SPAfight,d1
	jmp	SetSPA

SetInst	;Both a3 and a2 need fight rating ($75) 1 or more: then pflags2 bit 0 (fighting) on both;
	;Z clear when a3 was already fighting
	cmpi.b	#1,$75(a3)
	blt.w	rtsfight
	cmpi.b	#1,$75(a2)
	blt.w	rtsfight
	clr.w	d1
	move.b	$67(a2),d1
	movea.w	#(tmstruct-M68K_RAM),a0
	btst	#6,pflags(a2)
	beq.w	.tm
	adda.w	#$39E,a0
.tm
	adda.w	d1,a0
	move.b	$130(a0),d1
	asl.b	#1,d1
	neg.b	d1
	addi.b	#$10,d1
	cmp.b	$75(a2),d1
	bset	#0,pflags2(a2)
	bset	#0,pflags2(a3)
	bne.w	rtsfight
	rts
	;Not decoded in the listing and not referenced from it: kept as bytes
	dc.b	$4A,$78,$D2,$62,$67,$00,$00,$60,$30,$39,$00,$C0,$00,$08,$02,$40
	dc.b	$00,$03,$66,$00,$00,$52,$28,$4B,$70,$05,$36,$7C,$B0,$5E,$08,$2C
	dc.b	$00,$06,$00,$62,$67,$00,$00,$06,$D6,$FC,$03,$00,$B8,$CB,$67,$00
	dc.b	$00,$2C,$4A,$6B,$00,$34,$6F,$00,$00,$24,$08,$2B,$00,$04,$00,$63
	dc.b	$66,$00,$00,$1A,$08,$2B,$00,$02,$00,$63,$66,$00,$00,$10,$30,$3C
	dc.b	$00,$2A,$4E,$B9,$00,$01,$C1,$D2,$26,$4C,$4E,$75,$D6,$FC,$00,$80
	dc.b	$51,$C8,$FF,$CA,$26,$4C

rtsfight	;The shared rts of the fight routines
	rts

assfight	;Assignment $14: the fighter. Not decoded in the listing: kept as bytes, with the rest of the
	;fight code it calls
	dc.b	$08,$2B,$00,$05,$00,$62,$66,$F6,$4A,$78,$C3,$E8,$6A,$00,$00,$08
	dc.b	$4E,$F9,$00,$01,$73,$1E,$08,$AB,$00,$01,$00,$62,$67,$00,$00,$30
	dc.b	$08,$B8,$00,$07,$C3,$56,$42,$40,$10,$2B,$00,$75,$D0,$40,$56,$40
	dc.b	$37,$40,$00,$44,$42,$6B,$00,$42,$37,$7C,$FF,$FF,$00,$46,$0C,$6B
	dc.b	$00,$02,$00,$54,$66,$00,$00,$08,$37,$7C,$00,$5A,$00,$46,$9F,$6B
	dc.b	$00,$46,$64,$00,$00,$06,$61,$00,$06,$E6,$4A,$6B,$00,$44,$6B,$9E
	dc.b	$30,$2B,$00,$2E,$EF,$40,$30,$7C,$B0,$5E,$D0,$C0,$30,$13,$D0,$50
	dc.b	$E2,$40,$31,$C0,$BF,$DC,$08,$2B,$00,$03,$00,$62,$66,$00,$00,$E6
	dc.b	$08,$EB,$00,$01,$00,$63,$66,$00,$00,$DC,$0C,$6B,$30,$A4,$00,$58
	dc.b	$66,$00,$00,$1A,$0C,$78,$03,$E8,$BF,$16,$66,$00,$00,$0C,$0C,$78
	dc.b	$03,$E8,$BF,$14,$67,$00,$00,$06,$61,$00,$06,$36,$08,$38,$00,$01
	dc.b	$C3,$52,$66,$00,$01,$52,$4A,$6B,$00,$58,$66,$00,$00,$0C,$32,$3C
	dc.b	$30,$E6,$4E,$B9,$00,$01,$A6,$14,$30,$13,$90,$50,$32,$2B,$00,$28
	dc.b	$E0,$41,$D0,$41,$32,$28,$00,$28,$E0,$41,$90,$41,$B0,$7C,$00,$16
	dc.b	$6E,$00,$00,$82,$B0,$7C,$FF,$EA,$6D,$00,$00,$7A,$0C,$78,$03,$E8
	dc.b	$BF,$14,$67,$00,$00,$70,$0C,$78,$03,$E8,$BF,$16,$67,$00,$00,$66
	dc.b	$32,$13,$92,$50,$6A,$00,$00,$04,$44,$41,$30,$38,$DC,$EA,$53,$40
	dc.b	$31,$C0,$DC,$EA,$6A,$00,$00,$4E,$30,$3C,$00,$01,$4E,$B9,$00,$01
	dc.b	$B0,$A6,$31,$C0,$DC,$EA,$70,$08,$4E,$B9,$00,$01,$B0,$A6,$B0,$7C
	dc.b	$00,$01,$63,$00,$00,$06,$02,$40,$00,$01,$E3,$40,$60,$00,$00,$18
	dc.b	$70,$08,$4E,$B9,$00,$01,$B0,$A6,$B0,$7C,$00,$02,$63,$00,$00,$06
	dc.b	$02,$40,$00,$01,$E3,$40,$43,$FA,$00,$A8,$32,$31,$00,$00,$4E,$B9
	dc.b	$00,$01,$A6,$14,$61,$00,$01,$20,$08,$38,$00,$01,$C3,$52,$66,$00
	dc.b	$00,$78,$0C,$6B,$30,$A4,$00,$58,$67,$00,$00,$34,$0C,$6B,$31,$28
	dc.b	$00,$58,$67,$00,$00,$2A,$08,$2B,$00,$03,$00,$62,$66,$00,$00,$20
	dc.b	$30,$38,$BF,$DC,$06,$40,$00,$0A,$0C,$6B,$00,$02,$00,$54,$66,$00
	dc.b	$00,$06,$04,$40,$00,$14,$90,$53,$EB,$40,$D1,$6B,$00,$28,$32,$38
	dc.b	$BF,$DE,$92,$6B,$00,$14,$E1,$41,$B2,$7C,$10,$00,$6D,$00,$00,$06
	dc.b	$32,$3C,$10,$00,$B2,$7C,$F0,$00,$6E,$00,$00,$06,$32,$3C,$F0,$00
	dc.b	$37,$41,$00,$2A,$4A,$6B,$00,$58,$66,$00,$00,$0C,$32,$3C,$30,$E6
	dc.b	$4E,$B9,$00,$01,$A6,$14,$4E,$75,$61,$00,$00,$4A,$4A,$6B,$00,$58
	dc.b	$66,$00,$00,$0C,$32,$3C,$31,$BC,$4E,$B9,$00,$01,$A6,$14,$4E,$75
	dc.b	$32,$8C,$32,$C6,$32,$8C,$61,$00,$00,$2C,$70,$08,$4E,$B9,$00,$01
	dc.b	$B0,$A6,$02,$40,$00,$03,$E3,$40,$43,$FA,$00,$12,$32,$31,$00,$00
	dc.b	$4E,$B9,$00,$01,$A6,$14,$61,$00,$00,$5E,$4E,$75,$32,$52,$33,$3A
	dc.b	$32,$52,$33,$3A,$42,$6B,$00,$2A,$42,$6B,$00,$28,$48,$E7,$80,$00
	dc.b	$30,$13,$90,$50,$B0,$7C,$00,$18,$6E,$00,$00,$10,$B0,$7C,$FF,$E8
	dc.b	$6D,$00,$00,$08,$4C,$DF,$00,$01,$4E,$75,$EB,$40,$0C,$6B,$00,$02
	dc.b	$00,$54,$67,$00,$00,$0E,$4A,$40,$6B,$00,$00,$10,$44,$40,$60,$00
	dc.b	$00,$0A,$4A,$40,$6A,$00,$00,$04,$44,$40,$37,$40,$00,$28,$44,$40
	dc.b	$31,$40,$00,$28,$60,$CE,$48,$E7,$80,$F0,$30,$2B,$00,$06,$B0,$6B
	dc.b	$00,$08,$67,$00,$01,$0A,$08,$38,$00,$01,$C3,$52,$66,$00,$01,$06
	dc.b	$B0,$7C,$05,$EA,$67,$00,$02,$64,$08,$28,$00,$03,$00,$62,$67,$00
	dc.b	$00,$2E,$08,$2B,$00,$03,$00,$62,$67,$00,$00,$24,$0C,$68,$00,$02
	dc.b	$00,$54,$67,$00,$00,$10,$08,$38,$00,$01,$DC,$EC,$66,$00,$00,$D0
	dc.b	$60,$00,$00,$0C,$08,$38,$00,$00,$DC,$EC,$66,$00,$00,$C2,$0C,$68
	dc.b	$33,$74,$00,$58,$67,$00,$00,$B8,$0C,$68,$33,$AE,$00,$58,$67,$00
	dc.b	$00,$AE,$0C,$68,$33,$E8,$00,$58,$67,$00,$00,$A4,$0C,$68,$34,$22
	dc.b	$00,$58,$67,$00,$00,$9A,$0C,$68,$34,$5C,$00,$58,$67,$00,$00,$90
	dc.b	$0C,$68,$34,$96,$00,$58,$67,$00,$00,$86,$30,$13,$90,$50,$B0,$7C
	dc.b	$00,$16,$6E,$00,$00,$7A,$B0,$7C,$FF,$EA,$6D,$00,$00,$72,$4A,$40
	dc.b	$6A,$00,$00,$04,$44,$40,$B0,$7C,$00,$08,$6D,$00,$00,$62,$30,$2B
	dc.b	$00,$14,$90,$68,$00,$14,$B0,$7C,$00,$08,$6E,$00,$00,$52,$B0,$7C
	dc.b	$FF,$F8,$6D,$00,$00,$4A,$0C,$78,$03,$E8,$BF,$14,$67,$00,$00,$40
	dc.b	$0C,$78,$03,$E8,$BF,$16,$67,$00,$00,$36,$30,$2B,$00,$06,$B0,$7C
	dc.b	$05,$F6,$67,$00,$02,$26,$B0,$7C,$05,$FA,$67,$00,$02,$1E,$B0,$7C
	dc.b	$06,$06,$67,$00,$02,$68,$B0,$7C,$06,$0A,$67,$00,$02,$60,$B0,$7C
	dc.b	$06,$13,$67,$00,$01,$CA,$B0,$7C,$06,$17,$67,$00,$01,$C2,$4C,$DF
	dc.b	$0F,$01,$4E,$75,$08,$38,$00,$02,$C3,$52,$67,$00,$00,$32,$30,$38
	dc.b	$DC,$E8,$B0,$6B,$00,$52,$66,$00,$00,$26,$32,$3C,$36,$66,$4E,$B9
	dc.b	$00,$01,$A6,$14,$32,$3C,$36,$9C,$C1,$4B,$4E,$B9,$00,$01,$A6,$14
	dc.b	$61,$00,$02,$94,$31,$FC,$00,$B4,$C3,$E8,$60,$00,$02,$E0,$0C,$68
	dc.b	$35,$0A,$00,$58,$67,$B8,$0C,$68,$35,$44,$00,$58,$67,$B0,$0C,$68
	dc.b	$35,$7E,$00,$58,$67,$A8,$0C,$68,$35,$B8,$00,$58,$67,$A0,$0C,$68
	dc.b	$35,$F2,$00,$58,$67,$98,$0C,$68,$36,$2C,$00,$58,$67,$90,$30,$13
	dc.b	$90,$50,$B0,$7C,$00,$1E,$6E,$86,$B0,$7C,$FF,$E2,$6D,$80,$30,$2B
	dc.b	$00,$06,$B0,$7C,$06,$1D,$67,$00,$00,$1E,$B0,$7C,$06,$21,$67,$00
	dc.b	$00,$16,$B0,$7C,$06,$2E,$67,$00,$00,$60,$B0,$7C,$06,$32,$67,$00
	dc.b	$00,$58,$60,$00,$FF,$5A,$C1,$4B,$61,$00,$00,$A0,$08,$EB,$00,$01
	dc.b	$00,$63,$53,$6B,$00,$44,$6B,$00,$02,$58,$48,$E7,$80,$80,$20,$7C
	dc.b	$00,$00,$BE,$18,$30,$3C,$00,$64,$4E,$B9,$00,$01,$B0,$A6,$02,$40
	dc.b	$00,$03,$D0,$40,$32,$30,$00,$00,$4C,$DF,$01,$01,$4E,$B9,$00,$01
	dc.b	$A6,$14,$3F,$3C,$00,$09,$4E,$B9,$00,$08,$84,$70,$60,$00,$FF,$10
	dc.b	$35,$0A,$35,$44,$35,$7E,$35,$0A,$C1,$4B,$61,$00,$00,$4E,$08,$EB
	dc.b	$00,$01,$00,$63,$53,$6B,$00,$44,$6B,$00,$02,$06,$48,$E7,$80,$80
	dc.b	$20,$7C,$00,$00,$BE,$6A,$30,$3C,$00,$64,$4E,$B9,$00,$01,$B0,$A6
	dc.b	$02,$40,$00,$03,$D0,$40,$32,$30,$00,$00,$4C,$DF,$01,$01,$4E,$B9
	dc.b	$00,$01,$A6,$14,$3F,$3C,$00,$0A,$4E,$B9,$00,$08,$84,$70,$60,$00
	dc.b	$FE,$BE,$35,$B8,$35,$F2,$36,$2C,$35,$B8,$06,$78,$00,$50,$B8,$B2
	dc.b	$06,$78,$00,$0A,$B8,$B8,$30,$3C,$00,$03,$0C,$6B,$00,$02,$00,$54
	dc.b	$66,$00,$00,$04,$44,$40,$D1,$53,$4E,$75,$08,$AB,$00,$05,$00,$63
	dc.b	$30,$38,$BF,$DC,$B0,$7C,$00,$5A,$6D,$00,$00,$04,$70,$5A,$B0,$7C
	dc.b	$FF,$A6,$6E,$00,$00,$04,$70,$A6,$E4,$40,$66,$00,$00,$04,$52,$40
	dc.b	$48,$E7,$00,$80,$20,$7C,$FF,$FF,$BF,$14,$0C,$6B,$00,$02,$00,$54
	dc.b	$67,$00,$00,$08,$20,$7C,$FF,$FF,$BF,$16,$10,$80,$30,$38,$BF,$DE
	dc.b	$E4,$40,$11,$40,$00,$01,$4C,$DF,$01,$00,$60,$00,$FE,$42,$30,$13
	dc.b	$90,$50,$B0,$7C,$00,$1E,$6E,$00,$FE,$36,$B0,$7C,$FF,$E2,$6D,$00
	dc.b	$FE,$2E,$08,$F8,$00,$01,$C3,$52,$08,$EB,$00,$02,$00,$62,$08,$E8
	dc.b	$00,$02,$00,$62,$C1,$4B,$08,$EB,$00,$01,$00,$63,$32,$3C,$31,$F6
	dc.b	$4E,$B9,$00,$01,$A6,$14,$60,$00,$FE,$06,$C1,$4B,$61,$00,$00,$A0
	dc.b	$08,$EB,$00,$01,$00,$63,$53,$6B,$00,$44,$6B,$00,$01,$04,$48,$E7
	dc.b	$80,$80,$20,$7C,$00,$00,$BF,$6C,$30,$3C,$00,$64,$4E,$B9,$00,$01
	dc.b	$B0,$A6,$02,$40,$00,$03,$D0,$40,$32,$30,$00,$00,$4C,$DF,$01,$01
	dc.b	$4E,$B9,$00,$01,$A6,$14,$3F,$3C,$00,$09,$4E,$B9,$00,$08,$84,$70
	dc.b	$60,$00,$FD,$BC,$33,$74,$33,$AE,$33,$E8,$33,$74,$C1,$4B,$61,$00
	dc.b	$00,$4E,$08,$EB,$00,$01,$00,$63,$53,$6B,$00,$44,$6B,$00,$00,$B2
	dc.b	$48,$E7,$80,$80,$20,$7C,$00,$00,$BF,$BE,$30,$3C,$00,$64,$4E,$B9
	dc.b	$00,$01,$B0,$A6,$02,$40,$00,$03,$D0,$40,$32,$30,$00,$00,$4C,$DF
	dc.b	$01,$01,$4E,$B9,$00,$01,$A6,$14,$3F,$3C,$00,$0A,$4E,$B9,$00,$08
	dc.b	$84,$70,$60,$00,$FD,$6A,$34,$22,$34,$5C,$34,$96,$34,$22,$06,$78
	dc.b	$00,$50,$B8,$B2,$06,$78,$00,$0A,$B8,$B8,$70,$05,$D0,$68,$00,$44
	dc.b	$C0,$FC,$00,$00,$0C,$6B,$00,$02,$00,$54,$66,$00,$00,$04,$44,$40
	dc.b	$D1,$6B,$00,$28,$4E,$75,$48,$E7,$00,$40,$32,$7C,$C3,$A4,$54,$49
	dc.b	$0C,$11,$00,$26,$66,$F8,$10,$29,$00,$01,$02,$40,$00,$0F,$B0,$68
	dc.b	$00,$52,$66,$EA,$12,$BC,$00,$28,$4C,$DF,$02,$00,$3F,$3C,$00,$09
	dc.b	$4E,$B9,$00,$08,$84,$70,$31,$FC,$00,$3C,$C3,$E8,$31,$7C,$FF,$FF
	dc.b	$00,$44,$06,$78,$02,$58,$B8,$B2,$06,$78,$00,$1E,$B8,$B8,$4E,$75
	dc.b	$61,$B4,$32,$3C,$36,$D2,$4E,$B9,$00,$01,$A6,$14,$34,$7C,$C7,$26
	dc.b	$3F,$3C,$00,$0B,$08,$2B,$00,$06,$00,$62,$66,$00,$00,$0A,$45,$EA
	dc.b	$03,$9E,$3E,$BC,$00,$0C,$4E,$B9,$00,$08,$85,$86,$60,$00,$FC,$C0

loc_C068
	movem.l	d0-d3,-(sp)
	clr.w	Xvel(a3)
	addq.w	#1,(word_FFDCDE).w
	move.w	#SPA3128,d1
	jsr	(SetSPA).l
	cmpi.w	#2,(word_FFDCDE).w
	beq.w	.0
	move.w	#$140,(Pencntdwn).w
	bra.w	.1
.0
	bsr.w	SetFightingMajors
	bset	#5,(GameFlags).w
.1
	movem.l	(sp)+,d0-d3
	rts

ClearMessageLine	;Clear the message line
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),0,1,0
	moveq	#$28,d0
	moveq	#5,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts
	;Not decoded in the listing: kept as bytes
	dc.b	$48,$E7,$F0,$F8,$34,$7C,$C7,$26,$4E,$B9,$00,$00,$EE,$C4,$D4,$FC
	dc.b	$03,$9E,$4E,$B9,$00,$00,$EE,$C4,$4E,$B9,$00,$02,$2E,$58,$30,$7C
	dc.b	$C3,$A6,$42,$42,$4A,$58,$66,$FC,$10,$28,$FF,$FD,$42,$03,$61,$00
	dc.b	$00,$70,$44,$03,$10,$28,$FF,$FB,$61,$00,$00,$66,$4E,$B9,$00,$01
	dc.b	$BB,$8E,$00,$06,$BF,$0F,$01,$00,$30,$02,$E2,$4A,$95,$78,$B0,$40
	dc.b	$72,$05,$4E,$B9,$00,$01,$B9,$B0,$31,$FC,$00,$02,$B0,$42,$4A,$03
	dc.b	$6B,$00,$00,$08,$31,$FC,$00,$04,$B0,$42,$10,$28,$FF,$FD,$61,$00
	dc.b	$00,$30,$4E,$B9,$00,$01,$BB,$A0,$0A,$78,$00,$06,$B0,$42,$10,$28
	dc.b	$FF,$FB,$61,$00,$00,$1C,$4E,$B9,$00,$01,$BB,$A0,$4E,$B9,$00,$01
	dc.b	$BB,$8E,$00,$08,$BF,$0F,$03,$76,$73,$00,$4C,$DF,$1F,$0F,$4E,$75
	dc.b	$32,$7C,$B0,$5E,$02,$40,$00,$0F,$EF,$40,$D6,$31,$00,$75,$34,$7C
	dc.b	$C7,$26,$08,$31,$00,$06,$00,$62,$67,$00,$00,$06,$D4,$FC,$03,$9E
	dc.b	$10,$31,$00,$67,$48,$80,$4E,$B9,$00,$02,$2E,$92,$36,$49,$4E,$B9
	dc.b	$00,$01,$BE,$78,$00,$04,$20,$00,$22,$6A,$00,$1E,$D2,$E9,$00,$04
	dc.b	$D2,$D1,$4E,$B9,$00,$01,$BE,$80,$B4,$53,$6E,$00,$00,$04,$34,$13
	dc.b	$32,$4B,$30,$11,$E2,$48,$44,$40,$06,$40,$00,$10,$31,$C0,$B0,$40
	dc.b	$4E,$75

assfwatch	;Assignment $15: a player watching the fight. Not decoded in the listing: kept as bytes
	dc.b	$08,$2B,$00,$05,$00,$62,$66,$00,$F7,$B6,$08,$2B,$00,$03,$00,$62
	dc.b	$66,$00,$F7,$AC,$08,$AB,$00,$01,$00,$62,$67,$00,$00,$06,$42,$6B
	dc.b	$00,$40,$9F,$6B,$00,$40,$6A,$00,$00,$64,$06,$6B,$00,$3C,$00,$40
	dc.b	$30,$13,$90,$78,$BF,$DC,$32,$2B,$00,$14,$92,$78,$BF,$DE,$48,$A7
	dc.b	$C0,$00,$C1,$C0,$C3,$C1,$D0,$81,$4E,$B9,$00,$01,$B0,$DE,$34,$00
	dc.b	$66,$00,$00,$04,$74,$01,$4C,$9F,$00,$03,$C1,$FC,$00,$50,$81,$C2
	dc.b	$D0,$78,$BF,$DC,$36,$3C,$00,$8C,$B0,$43,$6D,$00,$00,$04,$30,$03
	dc.b	$44,$43,$B0,$43,$6E,$00,$00,$04,$30,$03,$37,$40,$00,$44,$C3,$FC
	dc.b	$00,$50,$83,$C2,$D2,$78,$BF,$DE,$37,$41,$00,$46,$30,$2B,$00,$44
	dc.b	$32,$2B,$00,$46,$41,$FA,$F7,$28,$4E,$B9,$00,$01,$A0,$50,$4E,$F9
	dc.b	$00,$01,$8D,$32

fightinput	;Controller processing for fighting
	btst	#2,(sflags10).w
	beq.w	.1
	movem.w	d0,-(sp)
	move.w	(word_FFDCE8).w,d0
	cmp.w	SCnum(a3),d0
	movem.w	(sp)+,d0
	bne.w	.1
	bra.w	.2
.1
	tst.w	temp3(a3)
	bmi.w	rtsfight
	tst.w	(Pencntdwn).w
	bmi.w	rtsfight
	cmpi.w	#SPA3128,SPA(a3)
	beq.w	rtsfight
.2
	cmpi.w	#2,facedir(a3)
	beq.w	.3
	bclr	#1,(byte_FFDCEC).w
	bra.w	.4
.3
	bclr	#0,(byte_FFDCEC).w
.4
	move.w	d0,d2
	move.w	d1,-(sp)
	cmpi.w	#2,(word_FFDCDE).w
	beq.w	.5
	move.w	#$280,(fightidletimer).w
	bne.w	.8
.5
	tst.w	d1
	bne.w	.7
	tst.w	(fightidletimer).w
	beq.w	.6
	subq.w	#1,(fightidletimer).w
	bra.w	.8
.6
	bset	#7,(sflags12).w
	bne.w	.8
	move.w	#8,(Pencntdwn).w
.7
	move.w	#$280,(fightidletimer).w
.8
	btst	#3,d2
	bne.w	.19
	btst	#1,(sflags10).w
	bne.w	.19
	cmpi.w	#SPAfight,SPA(a3)
	beq.w	.13
	cmpi.w	#2,facedir(a3)
	beq.w	.12
	cmp.w	#2,d2
	bne.w	.13
.9
	cmpi.w	#2,facedir(a3)
	beq.w	.10
	bset	#1,(byte_FFDCEC).w
	bra.w	.11
.10
	bset	#0,(byte_FFDCEC).w
.11
	bra.w	.13
.12
	cmp.w	#6,d2
	beq.s	.9
.13
	cmpi.w	#SPAfight,SPA(a3)
	bne.w	.18
	movem.l	d0/a0,-(sp)
	movea.l	#SortCords,a0
	cmpi.w	#6,SCnum(a3)
	bge.w	.14
	movea.l	#SortCords+$300,a0
.14
	move.w	#5,d0
.15
	btst	#0,pflags2(a0)
	bne.w	.16
	adda.w	#$80,a0
	dbf	d0,.15
	bra.w	.17
.16
	move.w	(a3),d0
	sub.w	(a0),d0
	bpl.w	.0
	neg.w	d0
.0
	cmp.w	#$20,d0
	bgt.w	.17
	cmp.w	facedir(a3),d2
	bne.w	.17
	clr.w	d2
.17
	movem.l	(sp)+,d0/a0
.18
	andi.w	#7,d2
	jsr	(playeracc).l
.19
	move.w	(xc1).w,d0
	addi.w	#$C,d0
	cmpi.w	#2,facedir(a3)
	bne.w	.20
	subi.w	#$18,d0
.20
	sub.w	(a3),d0
	move.w	Xvel(a3),d1
	eor.w	d0,d1
	bpl.w	.22
	tst.w	d0
	bpl.w	.21
	neg.w	d0
.21
	muls.w	Xvel(a3),d0
	asr.l	#4,d0
	sub.w	d0,Xvel(a3)
.22
	move.w	(sp)+,d1
	bset	#1,pflags2(a3)
	bne.w	rtsfight
	move.w	d1,d2
	cmpi.w	#SPAfight,SPA(a3)
	bne.w	.24
	btst	#5,d2
	bne.w	.23
	btst	#6,d2
	bne.w	.23
	btst	#4,d2
	beq.w	.25
.23
	bra.w	loc_C068
.24
	btst	#1,(sflags10).w
	bne.w	.26
	move.w	#SPAfgrab,d1
	btst	#6,d2
	bne.w	.34
	move.w	#SPAflow,d1
	btst	#4,d2
	bne.w	.34
	move.w	#SPAfhigh,d1
	btst	#5,d2
	bne.w	.34
.25
	bclr	#1,pflags2(a3)
	rts
.26
	btst	#2,(sflags10).w
	bne.w	.27
	move.w	#SPA3252,d1
	btst	#6,d2
	bne.w	.34
	move.w	#SPA333A,d1
	btst	#4,d2
	bne.w	.34
	move.w	#SPA3182,d1
	btst	#5,d2
	bne.w	.29
	bra.s	.25
.27
	tst.w	(Pencntdwn).w
	bmi.s	.25
	btst	#6,d2
	bne.w	.28
	btst	#4,d2
	bne.w	.28
	bra.s	.25
.28
	move.w	#SPA3300,d1
	bra.w	.34
.29
	movem.l	a0,-(sp)
	movea.l	#unk_FFDCE0,a0
	addq.w	#1,(a0,d4.w)
	cmpi.w	#$11,(a0,d4.w)
	movem.l	(sp)+,a0
	blt.w	.30
	bset	#2,(sflags10).w
	move.w	SCnum(a3),(word_FFDCE8).w
	bra.w	.34
.30
	movem.l	d1/a0/a3,-(sp)
	movea.l	#SortCords,a0
	move.w	#$B,d0
.31
	btst	#0,pflags2(a0)
	beq.w	.32
	cmpa.l	a0,a3
	bne.w	.33
.32
	adda.w	#$80,a0
	dbf	d0,.31
.33
	movea.l	a0,a3
	move.w	#SPA34D0,d1
	bset	#1,pflags2(a3)
	jsr	(SetSPA).l
	movem.l	(sp)+,d1/a0/a3
.34
	jmp	SetSPA

SetFightingMajors	;Both fighters' roughing minors in PenBuf become fighting majors; Pencntdwn $B40
	movem.l	a1,-(sp)
	movea.w	#(PenBuf-2-M68K_RAM),a1
.0
	addq.w	#2,a1
	cmpi.b	#$2E,(a1)
	bne.s	.0
	move.b	#$26,(a1)
.1
	addq.w	#2,a1
	cmpi.b	#$2E,(a1)
	bne.s	.1
	move.b	#$26,(a1)
	move.w	#$B40,(Pencntdwn).w
	movem.l	(sp)+,a1
	rts
