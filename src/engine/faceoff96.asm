;	The faceoff. faceoffinput stores the dpad pull and starts the faceoff. DrawFaceoffWindow
;	draws the window and limitfo keeps the spot inside the rink. The assignment routines
;	(assfaceoff, assfaceoffpl, puckfaceoff, puckfaceoff2) and Endfaceoff are the bytes the
;	listing does not decode.

faceoffinput	;The faceoff player (assignment $17): store the dpad pull (fodir1 / fodir2) and start the faceoff
	;SPA (SPA2126 with B, else SPA2150)
	btst	#6,(sflags5).w
	beq.w	.1
	rts
.1
	move.w	assnum(a3),d4
	cmpi.b	#$17,asslist(a3,d4.w)
	bne.w	rtss7
	movea.w	#(fodir1-M68K_RAM),a0	;faceoff direction of puck control variable
	btst	#pfgoal,pflags(a3)
	beq.w	.2	;branch if bottom goal
	movea.w	#(fodir2-M68K_RAM),a0
.2
	move.w	d0,(a0)
	btst	#pf2aip,pflags2(a3)
	bne.w	rtss7
	btst	#4,d1	;test for b button press
	beq.w	.3
	move.w	#SPA2126,d1
	bset	#pf2aip,pflags2(a3)	;set anim in progress
	jmp	SetSPA
.3
	move.w	#SPA2150,d1
	jmp	SetSPA

assfaceoff	;Assignment: wait for the faceoff to end (sflags2 bit 0), then assexit. Not decoded in the
	;listing: kept as bytes, as the faceoff routines up to puckfaceoff2
	dc.b	$08,$2B,$00,$05,$00,$62,$66,$00,$00,$0C,$08,$38,$00,$00,$C3,$3C
	dc.b	$67,$00,$00,$04,$4E,$75,$4E,$F9,$00,$01,$A3,$BE

assfaceoffpl	;Assignment: the faceoff player
	dc.b	$08,$2B,$00,$05,$00,$62,$66,$00,$00,$8C,$08,$38,$00,$00,$C3,$3C
	dc.b	$67,$00,$00,$78,$08,$AB,$00,$01,$00,$62,$67,$00,$00,$06,$42,$6B
	dc.b	$00,$40,$20,$7C,$FF,$FF,$BD,$BE,$08,$2B,$00,$06,$00,$62,$67,$00
	dc.b	$00,$04,$58,$48,$30,$2B,$00,$5A,$E4,$48,$52,$40,$08,$2B,$00,$00
	dc.b	$00,$77,$66,$00,$00,$04,$56,$40,$30,$80,$08,$2B,$00,$03,$00,$62
	dc.b	$66,$00,$00,$42,$08,$EB,$00,$01,$00,$63,$66,$00,$00,$38,$32,$3C
	dc.b	$21,$26,$0C,$78,$00,$12,$B7,$9E,$63,$00,$00,$14,$70,$08,$4E,$B9
	dc.b	$00,$01,$B0,$A6,$4A,$40,$67,$00,$00,$06,$32,$3C,$21,$50,$08,$EB
	dc.b	$00,$01,$00,$63,$4E,$F9,$00,$01,$A6,$14,$17,$7C,$00,$14,$00,$5E
	dc.b	$60,$00,$FF,$68,$4E,$75

puckfaceoff	;Puck assignment: the faceoff set up
	dc.b	$50,$F8,$D2,$38,$50,$F8,$D2,$3A,$50,$F8,$D2,$3C,$08,$B8,$00,$04
	dc.b	$C3,$4C,$08,$38,$00,$00,$C3,$48,$67,$00,$00,$14,$42,$78,$B7,$86
	dc.b	$42,$78,$B7,$88,$30,$3C,$00,$1E,$4E,$F9,$00,$01,$A3,$DA,$08,$AB
	dc.b	$00,$01,$00,$62,$67,$00,$02,$9A,$08,$B8,$00,$00,$C3,$4C,$67,$00
	dc.b	$00,$0A,$42,$78,$BF,$E2,$42,$78,$BF,$E4,$08,$B8,$00,$07,$C3,$4A
	dc.b	$42,$B8,$BE,$AE,$42,$B8,$BE,$B2,$42,$B8,$BE,$B6,$08,$B8,$00,$06
	dc.b	$C3,$4A,$08,$B8,$00,$02,$C3,$4A,$08,$F8,$00,$02,$C3,$56,$4E,$B9
	dc.b	$00,$1D,$90,$E2,$4A,$78,$D4,$7E,$6B,$00,$00,$0A,$30,$38,$D4,$7E
	dc.b	$60,$00,$00,$0E,$4E,$B9,$00,$1D,$90,$94,$4A,$40,$6B,$00,$00,$08
	dc.b	$4E,$B9,$00,$1D,$8A,$B4,$08,$B8,$00,$01,$C3,$46,$08,$B8,$00,$01
	dc.b	$C3,$48,$4A,$78,$C4,$BE,$67,$00,$02,$C8,$08,$38,$00,$06,$C3,$38
	dc.b	$66,$00,$02,$BE,$0C,$78,$00,$03,$C4,$BC,$66,$00,$00,$14,$30,$38
	dc.b	$C7,$32,$B0,$78,$CA,$D0,$67,$00,$00,$08,$4E,$F9,$00,$01,$4B,$DC
	dc.b	$08,$38,$00,$03,$C3,$38,$66,$00,$02,$9E,$30,$38,$C4,$C2,$E2,$40
	dc.b	$B0,$78,$C4,$BE,$63,$00,$00,$42,$0C,$78,$00,$3C,$C4,$BE,$6D,$00
	dc.b	$00,$38,$08,$B8,$00,$07,$C3,$3E,$67,$00,$00,$2E,$08,$38,$00,$00
	dc.b	$C3,$38,$67,$00,$00,$24,$08,$38,$00,$06,$C3,$4C,$66,$00,$00,$1A
	dc.b	$31,$F8,$C3,$A0,$D4,$8C,$31,$FC,$00,$02,$D4,$8E,$4E,$B9,$00,$08
	dc.b	$86,$88,$08,$F8,$00,$04,$C3,$4C,$4E,$B9,$00,$01,$97,$EA,$50,$EB
	dc.b	$00,$40,$50,$EB,$00,$42,$4A,$78,$D2,$64,$66,$00,$01,$94,$08,$B8
	dc.b	$00,$01,$C7,$56,$08,$B8,$00,$01,$CA,$F4,$30,$7C,$B0,$5E,$70,$0B
	dc.b	$08,$A8,$00,$03,$00,$63,$D0,$FC,$00,$80,$51,$C8,$FF,$F4,$30,$38
	dc.b	$C3,$90,$80,$78,$C3,$92,$67,$00,$00,$3A,$08,$38,$00,$07,$C3,$3A
	dc.b	$67,$00,$00,$30,$4E,$B9,$00,$01,$AF,$52,$08,$F8,$00,$06,$C3,$3A
	dc.b	$4E,$B9,$00,$01,$D0,$1E,$31,$FC,$00,$18,$BD,$3C,$4A,$78,$D2,$64
	dc.b	$66,$00,$00,$10,$08,$38,$00,$04,$C3,$4A,$67,$00,$00,$06,$42,$78
	dc.b	$BD,$3C,$30,$38,$C3,$84,$6B,$00,$00,$0A,$B0,$7C,$00,$06,$6D,$00
	dc.b	$00,$2E,$30,$38,$C3,$86,$6B,$00,$00,$0A,$B0,$7C,$00,$06,$6D,$00
	dc.b	$00,$1E,$30,$38,$C3,$88,$6B,$00,$00,$0A,$B0,$7C,$00,$06,$6D,$00
	dc.b	$00,$0E,$30,$38,$C3,$8A,$B0,$7C,$00,$06,$6C,$00,$00,$0C,$4A,$40
	dc.b	$6B,$00,$00,$06,$61,$00,$00,$9C,$30,$38,$C3,$84,$B0,$7C,$00,$06
	dc.b	$6C,$00,$00,$26,$30,$38,$C3,$86,$B0,$7C,$00,$06,$6C,$00,$00,$1A
	dc.b	$30,$38,$C3,$88,$B0,$7C,$00,$06,$6C,$00,$00,$0E,$30,$38,$C3,$8A
	dc.b	$B0,$7C,$00,$06,$6D,$00,$00,$0C,$4A,$40,$6B,$00,$00,$06,$61,$00
	dc.b	$00,$62,$32,$7C,$C7,$26,$45,$E9,$03,$9E,$70,$02,$4E,$B9,$00,$00
	dc.b	$9D,$0C,$60,$00,$00,$9C

SetFaceoffComputerLine	;Line changes on and team d0 not on a pad: CompLine, SetPersonel
	dc.b	$4A,$78,$D2,$64,$66,$00,$00,$44,$08,$38,$00,$04,$C3,$4A,$66,$00
	dc.b	$00,$22,$B0,$78,$C3,$90,$67,$00,$00,$32,$B0,$78,$C3,$92,$67,$00
	dc.b	$00,$2A,$B0,$78,$C3,$94,$67,$00,$00,$22,$B0,$78,$C3,$96,$67,$00
	dc.b	$00,$1A,$4E,$B9,$00,$01,$98,$68,$4E,$B9,$00,$01,$FB,$52,$4E,$B9
	dc.b	$00,$01,$D0,$62,$31,$FC,$27,$10,$C3,$68,$4E,$75

StartFaceoffLineChange	;Player d0 (sort object) opens the line change box
	dc.b	$C5,$4B,$EF,$40,$36,$7C,$B0,$5E,$D6,$C0,$08,$AB,$00,$03,$00,$63
	dc.b	$2F,$0A,$4E,$B9,$00,$00,$EC,$30,$24,$5F,$08,$2B,$00,$03,$00,$63
	dc.b	$67,$00,$00,$28,$08,$2B,$00,$06,$00,$62,$67,$00,$00,$12,$35,$7C
	dc.b	$01,$68,$00,$42,$35,$6B,$00,$52,$00,$46,$60,$00,$00,$0E,$35,$7C
	dc.b	$02,$58,$00,$40,$35,$6B,$00,$52,$00,$44,$C5,$4B

rtsfaceoff	;The shared rts of the faceoff routines
	dc.b	$4E,$75

WaitForFaceoffLineChanges	;Run both line change timers; when both are done set the home computer line
	dc.b	$30,$3C,$00,$40,$4E,$B9,$00,$00,$9D,$E6,$30,$3C,$00,$42,$4E,$B9
	dc.b	$00,$00,$9D,$E6,$4A,$6B,$00,$40,$6A,$96,$4A,$6B,$00,$42,$6A,$90
	dc.b	$34,$7C,$C7,$26,$43,$EA,$03,$9E,$70,$01,$4E,$B9,$00,$00,$9D,$0C
	dc.b	$31,$FC,$FF,$FF,$D4,$88,$30,$3C,$00,$1C,$4E,$F9,$00,$01,$A3,$DA

UpdateFaceoffLineChangeTimer	;Line change timer d0 (temp1 / temp2 of the puck)
	dc.b	$4A,$73,$00,$00,$6B,$00,$FF,$6A,$32,$33,$00,$04,$EF,$41,$30,$7C
	dc.b	$B0,$5E,$34,$7C,$C7,$26,$08,$30,$00,$06,$10,$62,$67,$00,$00,$06
	dc.b	$D4,$FC,$03,$9E,$08,$30,$00,$03,$10,$63,$66,$00,$00,$0A,$50,$F3
	dc.b	$00,$00,$60,$00,$4E,$54,$9F,$73,$00,$00,$6A,$00,$FF,$34,$2F,$0B
	dc.b	$47,$F0,$10,$00,$08,$2B,$00,$03,$00,$63,$67,$00,$00,$10,$42,$42
	dc.b	$4E,$B9,$00,$00,$EE,$92,$4E,$B9,$00,$00,$EC,$6E,$26,$5F,$4E,$75
	dc.b	$4E,$F9,$00,$02,$15,$DC,$4E,$F9,$00,$01,$C7,$84

puckfaceoff2	;Puck assignment: the faceoff
	dc.b	$08,$AB,$00,$01,$00,$62,$67,$00,$03,$DE,$08,$B8,$00,$01,$C3,$56
	dc.b	$08,$B8,$00,$02,$C3,$40,$08,$B8,$00,$05,$C3,$40,$08,$B8,$00,$00
	dc.b	$C3,$42,$08,$B8,$00,$01,$C3,$42,$08,$B8,$00,$00,$C3,$4E,$08,$B8
	dc.b	$00,$01,$C3,$4E,$08,$B8,$00,$02,$C3,$4E,$48,$E7,$FF,$FE,$4E,$B9
	dc.b	$00,$01,$AF,$52,$08,$38,$00,$00,$BF,$B2,$66,$F8,$08,$B8,$00,$00
	dc.b	$C3,$5A,$40,$E7,$31,$FC,$00,$3C,$D2,$E0,$4A,$78,$BF,$E2,$66,$00
	dc.b	$00,$14,$4A,$78,$BF,$E4,$66,$00,$00,$0C,$31,$FC,$FF,$FF,$D4,$7E
	dc.b	$60,$00,$00,$06,$46,$FC,$27,$00,$0C,$78,$02,$58,$B8,$B2,$63,$00
	dc.b	$00,$08,$31,$FC,$02,$58,$B8,$B2,$08,$F8,$00,$03,$BF,$B2,$08,$B8
	dc.b	$00,$00,$C3,$3A,$08,$B8,$00,$00,$C3,$3E,$31,$FC,$03,$E8,$BF,$16
	dc.b	$31,$FC,$03,$E8,$BF,$14,$42,$38,$BF,$BA,$50,$F8,$C4,$46,$50,$F8
	dc.b	$BF,$1C,$50,$F8,$BF,$20,$08,$B8,$00,$01,$C3,$3C,$08,$F8,$00,$00
	dc.b	$C3,$3C,$08,$F8,$00,$02,$C3,$3C,$50,$F8,$BF,$12,$50,$F8,$BF,$A6
	dc.b	$08,$F8,$00,$04,$BF,$B2,$08,$B8,$00,$04,$C3,$4E,$4E,$B9,$00,$01
	dc.b	$D0,$1E,$31,$FC,$27,$10,$C3,$68,$42,$78,$BD,$2E,$42,$78,$BD,$32
	dc.b	$31,$F8,$BF,$E2,$B7,$5E,$31,$F8,$BF,$E4,$B7,$72,$50,$F8,$B7,$76
	dc.b	$42,$78,$B7,$86,$42,$78,$B7,$88,$42,$78,$B7,$8A,$50,$F8,$B7,$BE
	dc.b	$30,$7C,$B6,$5E,$42,$68,$00,$28,$42,$68,$00,$2A,$42,$50,$31,$7C
	dc.b	$01,$22,$00,$14,$D0,$FC,$00,$80,$42,$68,$00,$28,$42,$68,$00,$2A
	dc.b	$42,$50,$31,$7C,$FE,$DE,$00,$14,$30,$7C,$B7,$DE,$31,$7C,$02,$99
	dc.b	$00,$06,$42,$68,$00,$58,$42,$68,$00,$04,$42,$78,$B7,$62,$08,$B8
	dc.b	$00,$06,$C3,$3A,$78,$64,$4E,$B9,$00,$01,$67,$9A,$51,$CC,$FF,$F8
	dc.b	$31,$FC,$00,$3C,$BF,$E0,$4E,$B9,$00,$01,$FD,$F4,$34,$7C,$C7,$26
	dc.b	$4E,$B9,$00,$01,$FB,$52,$4E,$B9,$00,$01,$FD,$82,$D4,$FC,$03,$9E
	dc.b	$4E,$B9,$00,$01,$FB,$52,$4E,$B9,$00,$01,$FD,$82,$4E,$B9,$00,$02
	dc.b	$14,$30,$2F,$0B,$36,$7C,$B0,$5E,$74,$0B,$36,$BC,$FF,$10,$42,$6B
	dc.b	$00,$14,$42,$6B,$00,$06,$32,$2B,$00,$34,$6B,$00,$00,$FE,$67,$00
	dc.b	$00,$4C,$20,$3C,$00,$00,$00,$16,$B2,$7C,$00,$04,$66,$00,$00,$38
	dc.b	$34,$7C,$C7,$26,$08,$2B,$00,$06,$00,$62,$67,$00,$00,$06,$D4,$FC
	dc.b	$03,$9E,$42,$6A,$00,$18,$15,$6B,$00,$67,$00,$19,$08,$B8,$00,$07
	dc.b	$C3,$4C,$50,$EA,$00,$1A,$50,$EA,$00,$1C,$08,$AA,$00,$03,$00,$30
	dc.b	$20,$3C,$00,$00,$00,$17,$4E,$B9,$00,$01,$A3,$D0,$38,$38,$C7,$4A
	dc.b	$08,$2B,$00,$06,$00,$62,$67,$00,$00,$06,$38,$38,$CA,$E8,$44,$44
	dc.b	$5C,$44,$E7,$44,$22,$7C,$00,$00,$A2,$6C,$D2,$C4,$18,$31,$10,$00
	dc.b	$E5,$44,$22,$7C,$00,$00,$A2,$84,$30,$31,$40,$00,$32,$31,$40,$02
	dc.b	$08,$2B,$00,$07,$00,$62,$66,$00,$00,$06,$44,$40,$44,$41,$4A,$6B
	dc.b	$00,$34,$67,$00,$00,$2C,$B8,$7C,$00,$08,$6E,$00,$00,$1C,$36,$38
	dc.b	$BF,$E2,$B1,$43,$6A,$00,$00,$0A,$36,$38,$BF,$E4,$E6,$43,$92,$43
	dc.b	$36,$38,$BF,$E2,$E4,$43,$90,$43,$D0,$78,$BF,$E2,$D2,$78,$BF,$E4
	dc.b	$36,$80,$37,$41,$00,$14,$42,$6B,$00,$28,$42,$6B,$00,$2A,$90,$78
	dc.b	$B7,$5E,$92,$78,$B7,$72,$44,$40,$44,$41,$4E,$B9,$00,$01,$A3,$EE
	dc.b	$37,$40,$00,$54,$08,$AB,$00,$02,$00,$63,$08,$AB,$00,$05,$00,$62
	dc.b	$32,$3C,$08,$56,$4E,$B9,$00,$01,$A6,$14,$D6,$FC,$00,$80,$51,$CA
	dc.b	$FE,$EA,$4E,$B9,$00,$02,$13,$AE,$26,$5F,$4E,$B9,$00,$01,$99,$66
	dc.b	$38,$38,$B0,$3A,$24,$7C,$00,$09,$1D,$4E,$4E,$B9,$00,$01,$B7,$30
	dc.b	$31,$C4,$B0,$26,$24,$7C,$00,$13,$BC,$B8,$4E,$B9,$00,$01,$B7,$30
	dc.b	$31,$FC,$FF,$FF,$D4,$74,$08,$38,$00,$00,$C3,$4A,$67,$00,$00,$10
	dc.b	$30,$38,$D4,$7E,$6B,$00,$00,$08,$4E,$B9,$00,$1D,$8A,$86,$61,$00
	dc.b	$01,$4E,$30,$3C,$00,$78,$4E,$B9,$00,$01,$B0,$A6,$06,$40,$01,$2C
	dc.b	$0C,$78,$00,$00,$D4,$74,$67,$00,$00,$2A,$0C,$78,$00,$01,$D4,$74
	dc.b	$67,$00,$00,$20,$0C,$78,$00,$05,$D4,$74,$67,$00,$00,$16,$0C,$78
	dc.b	$00,$04,$D4,$74,$67,$00,$00,$0C,$0C,$78,$00,$02,$D4,$74,$66,$00
	dc.b	$00,$0E,$B0,$7C,$01,$86,$6E,$00,$00,$06,$30,$3C,$01,$86,$37,$40
	dc.b	$00,$40,$31,$FC,$00,$18,$BD,$3C,$20,$7C,$FF,$FF,$BD,$BE,$30,$BC
	dc.b	$00,$01,$31,$7C,$80,$00,$00,$02,$31,$7C,$00,$04,$00,$04,$31,$7C
	dc.b	$A8,$00,$00,$06,$31,$7C,$00,$07,$00,$08,$31,$7C,$80,$00,$00,$0A
	dc.b	$08,$38,$00,$01,$C3,$38,$66,$00,$00,$0E,$0A,$68,$08,$00,$00,$02
	dc.b	$0A,$68,$08,$00,$00,$06,$31,$FC,$FF,$FF,$BF,$E6,$31,$FC,$FF,$FF
	dc.b	$BF,$E8,$4E,$B9,$00,$1D,$97,$48,$08,$B8,$00,$06,$C3,$4C,$66,$00
	dc.b	$00,$0C,$08,$B8,$00,$04,$C3,$4C,$67,$00,$00,$12,$08,$B8,$00,$04
	dc.b	$C3,$4C,$3F,$38,$D4,$8A,$4E,$B9,$00,$08,$85,$86,$31,$FC,$00,$78
	dc.b	$C3,$A4,$4E,$B9,$00,$1E,$78,$C4,$31,$FC,$00,$18,$BD,$3C,$46,$DF
	dc.b	$4C,$DF,$7F,$FF,$4E,$75,$53,$78,$C3,$A4,$66,$00,$00,$14,$4E,$B9
	dc.b	$00,$1E,$7A,$78,$08,$B8,$00,$02,$C3,$56,$08,$F8,$00,$03,$C3,$56
	dc.b	$53,$6B,$00,$40,$6A,$00,$00,$0E,$4E,$B9,$00,$1D,$8A,$C0,$4E,$F9
	dc.b	$00,$00,$A3,$DC,$4E,$F9,$00,$01,$9B,$16
.apl	;Faceoff positions of the players by line slot
	dc.b	0,1,2,3,4,5,6,0
	dc.b	0,1,5,3,4,2,0,0
	dc.b	0,3,5,1,4,0,0,0
.ptab	;Faceoff x / y offsets
	dc.w	0,$FEF0,$FFDD,$FFCE,$23,$FFCE,$FFCE,$FFF6
	dc.w	0,$FFF1,$32,$FFF6,0,$FFC4

DrawFaceoffWindow	;Draw the faceoff window (FaceOffMap) at x $36 or $BE
	;y $5C, and with line changes on the two line names (linelist)
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),0,0,0
	moveq	#$36,d0
	tst.w	(fox).w
	bpl.w	.setx
	move.w	#$BE,d0
.setx
	move.w	d0,(fodropx).w
	subi.w	#$2E,d0
	asr.w	#3,d0
	move.w	d0,(printx).w
	moveq	#$5C,d0
	move.w	d0,(fodropy).w
	subi.w	#$44,d0
	asr.w	#3,d0
	move.w	d0,(printy).w
	move.w	(ExtraChars).w,d4
	movea.l	#FaceOffMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	moveq	#$C,d2
	moveq	#9,d3
	moveq	#0,d5
	bset	#0,(sflags6).w
	jsr	(dobitmap).l
	bclr	#0,(sflags6).w
	tst.w	(OptLine).w
	bne.w	.exit
	jsr	(printsmallz).l
	String	CC_AddY,$A,CC_SetAttribute,4
	moveq	#$C,d0
	moveq	#3,d1
	jsr	(Framer).l
	move.w	(tmstruct+tmline).w,d0
	move.w	(AwShots+tmline).w,d1
	btst	#gmdir,(gmode).w
	bne.w	.0
	exg	d0,d1
.0
	jsr	(printsmallz).l
	String	CC_AddX,1,CC_AddY,$FE
	movea.l	#linelist,a1
	jsr	(SkipStrings).l
	jsr	(print).l
	addq.w	#4,(printx).w
	move.w	d1,d0
	movea.l	#linelist,a1
	jsr	(SkipStrings).l
	jsr	(print).l
.exit
	rts

limitfo	;Limit the faceoff spot to the walls of the rink, for every player in PenBuf
	movem.l	d0-d1/a0-a1,-(sp)
	movea.w	#(PenBuf-M68K_RAM),a0
.loop
	bsr.w	.lf
	addq.w	#2,a0
	tst.w	(a0)
	bne.s	.loop
	movem.l	(sp)+,d0-d1/a0-a1
	rts
.lf
	move.b	1(a0),d0
	andi.w	#$7F,d0
	asl.w	#scsize,d0	;scsize
	movea.w	#(SortCords-M68K_RAM),a1
	move.w	#$76,d1
	btst	#pfgoal,pflags(a1,d0.w)
	bne.w	.2
	neg.w	d1
	cmp.w	(foy).w,d1
	blt.w	.1
	move.w	#$FF98,(foy).w
	bra.w	.sx
.2
	cmp.w	(foy).w,d1
	bgt.w	.1
	move.w	#$68,(foy).w
.sx
	move.w	#$51,d0
	tst.w	(fox).w
	bpl.w	.0
	neg.w	d0
.0
	move.w	d0,(fox).w
.1
	rts

rtss7	;The shared rts of faceoffinput and doinput
	rts

Endfaceoff	;Drop the puck: pick the winner (.ftab) and the puck direction. Not decoded in the listing:
	;kept as bytes
	dc.b	$3F,$3C,$00,$2C,$4E,$B9,$00,$08,$84,$70,$08,$B8,$00,$00,$C3,$3C
	dc.b	$31,$FC,$00,$3C,$D2,$E0,$38,$38,$B0,$3A,$24,$7C,$00,$09,$7E,$7A
	dc.b	$4E,$B9,$00,$01,$B7,$30,$08,$B8,$00,$02,$C3,$3C,$08,$B8,$00,$00
	dc.b	$C3,$38,$08,$AB,$00,$00,$00,$63,$42,$78,$C3,$68,$08,$F8,$00,$04
	dc.b	$C3,$3E,$36,$38,$BF,$E6,$38,$3C,$08,$00,$20,$7C,$00,$00,$A4,$D6
	dc.b	$32,$7C,$BD,$BE,$74,$10,$32,$11,$94,$30,$10,$FF,$32,$29,$00,$04
	dc.b	$D4,$30,$10,$FF,$70,$21,$4E,$B9,$00,$01,$B0,$A6,$B4,$00,$63,$00
	dc.b	$00,$04,$58,$49,$08,$29,$00,$03,$00,$02,$67,$00,$00,$08,$36,$38
	dc.b	$BF,$E8,$44,$44,$30,$03,$08,$00,$00,$03,$66,$00,$00,$14,$02,$40
	dc.b	$00,$07,$32,$39,$00,$C0,$00,$08,$02,$41,$00,$03,$66,$00,$00,$1A
	dc.b	$70,$05,$4E,$B9,$00,$01,$B0,$A6,$55,$40,$02,$40,$00,$07,$4A,$44
	dc.b	$6B,$00,$00,$06,$0A,$40,$00,$04,$E5,$40,$20,$7C,$00,$01,$AE,$60
	dc.b	$32,$30,$00,$00,$EB,$41,$37,$41,$00,$28,$32,$30,$00,$02,$EB,$41
	dc.b	$D2,$44,$37,$41,$00,$2A,$30,$3C,$08,$00,$4E,$B9,$00,$01,$B0,$A6
	dc.b	$37,$40,$00,$2C,$42,$78,$B7,$76,$08,$AB,$00,$02,$00,$62,$20,$3C
	dc.b	$00,$00,$00,$18,$4E,$F9,$00,$01,$A3,$DA
.ftab
	dc.b	0,8,$10,0,8,$10

