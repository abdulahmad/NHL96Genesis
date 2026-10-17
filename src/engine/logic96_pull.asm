;	The computer goalie pull. ChkGoalies pulls him on a delayed penalty, and CPgoalie
;	pulls him late in a game the computer is losing. The puck checks follow.

ChkGoalies	;A computer team down with its goalie in: pull him on a delayed penalty, else CPgoalie
	btst	#0,(gmode).w	;check if clock running
	bne.w	rtss2
	movea.w	#(tmstruct-M68K_RAM),a2
	lea	$39E(a2),a1
	moveq	#1,d0
	bsr.w	.chkgoalie
	moveq	#2,d0
	exg	a1,a2
.chkgoalie
	tst.w	$26(a2)	;check for goalie
	bmi.w	rtss2
	move.w	(puckc).w,d1	;move puck carrier SCnum into d1
	bmi.w	rtss2
	subq.w	#6,d1
	cmpa.w	#(tmstruct-M68K_RAM),a2
	beq.w	.chkpen
	not.w	d1	;makes d1 negative if away team
.chkpen
	tst.w	d1
	bpl.w	rtss2
	btst	#3,(gmode).w	;#gmpendel - delayed penalty called
	beq.w	.nopen
	st	$26(a2)	;sets to FFFF (no goalie)
	bra.w	setpersonel
.nopen
	cmp.w	(cont1team).w,d0
	beq.w	rtss2
	cmp.w	(cont2team).w,d0
	beq.w	rtss2
	move.w	(pucky).w,d1
	bra.w	CPgoalie

ReturnGoalies	;If the computer pulled its goalie, see if it should return him.
	;Code the listing does not decode: kept as bytes
	dc.b	$34,$7C,$C7,$26,$43,$EA,$03,$9E,$70,$01,$61,$00,$00,$06,$70,$02
	dc.b	$C3,$4A,$0C,$6A,$FF,$FF,$00,$26,$67,$00,$60,$46,$42,$2A,$00,$26
	dc.b	$B0,$78,$C3,$90,$67,$00,$60,$3A,$B0,$78,$C3,$92,$67,$00,$60,$32
	dc.b	$32,$38,$BF,$E4

CPgoalie	;See if the computer should pull its goalie: third period, behind by 1, a minute left, the puck in the
	;other end
	cmpi.w	#2,(gsp).w	;check if 3rd period
	bne.w	rtss2
	move.w	$C(a1),d0	;tmscore
	sub.w	$C(a2),d0
	bmi.w	rtss2
	cmp.w	#1,d0
	bne.w	rtss2
	cmpi.w	#$3C,(gameclock).w	;#60
	bgt.w	rtss2
	move.l	a0,-(sp)
	movea.w	$22(a2),a0	;moves a player struct address into a0
	btst	#7,$62(a0)	;#pfgoal
	movea.l	(sp)+,a0
	bne.w	.0
	neg.w	d1	;if shooting on bottom goal, make d1 negative
.0
	tst.w	d1
	bmi.w	rtss2
	st	$26(a2)	;set to FFFF (no goalie)
	bra.w	setpersonel

CompLine	;The computer picks a line for team a2 (a1 = other team).
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$E0,$80,$70,$03,$32,$2A,$00,$24,$92,$69,$00,$24,$67,$00
	dc.b	$00,$2A,$6A,$00,$00,$04,$54,$40,$3F,$00,$61,$00,$39,$18,$32,$00
	dc.b	$30,$17,$52,$40,$61,$00,$39,$0E,$B2,$40,$6C,$00,$00,$04,$52,$57
	dc.b	$35,$5F,$00,$16,$4C,$DF,$01,$07,$4E,$75,$B4,$FC,$C7,$26,$66,$00
	dc.b	$00,$72,$72,$02,$41,$FA,$00,$42,$0C,$78,$00,$02,$C4,$BC,$66,$00
	dc.b	$00,$1A,$34,$2A,$00,$0C,$B4,$69,$00,$0C,$67,$00,$00,$0E,$D0,$FC
	dc.b	$00,$0E,$6E,$00,$00,$06,$D0,$FC,$00,$0E,$32,$29,$00,$16,$E3,$41
	dc.b	$30,$30,$10,$00,$61,$00,$38,$BE,$B0,$7C,$0C,$00,$63,$00,$00,$34
	dc.b	$35,$70,$10,$00,$00,$16,$60,$AC,$00,$00,$00,$01,$00,$02,$00,$00
	dc.b	$00,$01,$00,$00,$00,$01,$00,$02,$00,$00,$00,$01,$00,$02,$00,$00
	dc.b	$00,$02,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$01,$00,$00
	dc.b	$00,$01,$72,$02,$41,$FA,$00,$36,$0C,$78,$00,$02,$C4,$BC,$66,$00
	dc.b	$00,$16,$34,$2A,$00,$0C,$B4,$69,$00,$0C,$67,$00,$00,$0A,$5C,$48
	dc.b	$6E,$00,$00,$04,$5C,$48,$30,$18,$61,$00,$38,$5A,$B0,$7C,$0C,$00
	dc.b	$52,$C9,$FF,$F4,$35,$60,$00,$16,$60,$00,$FF,$4A,$00,$00,$00,$01
	dc.b	$00,$02,$00,$00,$00,$02,$00,$01,$00,$00,$00,$01,$00,$00

AssignPads	;Give each pad on a team a player.
	;Code the listing does not decode: kept as bytes
	dc.b	$31,$FC,$FF,$FF,$C3,$84,$31,$FC,$FF,$FF,$C3,$86,$31,$FC,$FF,$FF
	dc.b	$C3,$88,$31,$FC,$FF,$FF,$C3,$8A,$4A,$78,$C3,$90,$67,$00,$00,$5E
	dc.b	$08,$38,$00,$03,$C3,$4E,$67,$00,$00,$4C,$0C,$78,$00,$01,$C3,$90
	dc.b	$67,$00,$00,$0E,$4A,$78,$C3,$9A,$66,$00,$00,$3A,$67,$00,$00,$0A
	dc.b	$4A,$78,$C3,$98,$66,$00,$00,$2E,$48,$E7,$80,$90,$30,$3C,$00,$05
	dc.b	$0C,$78,$00,$01,$C3,$90,$67,$00,$00,$06,$30,$3C,$00,$0B,$4E,$B9
	dc.b	$00,$01,$68,$B8,$42,$44,$4E,$B9,$00,$01,$6C,$52,$4C,$DF,$09,$01
	dc.b	$60,$00,$00,$0A,$42,$44,$4E,$B9,$00,$01,$6A,$46,$4A,$78,$C3,$92
	dc.b	$67,$00,$00,$60,$08,$38,$00,$03,$C3,$4E,$67,$00,$00,$4E,$0C,$78
	dc.b	$00,$02,$C3,$92,$67,$00,$00,$0E,$4A,$78,$C3,$98,$66,$00,$00,$3C
	dc.b	$60,$00,$00,$0A,$4A,$78,$C3,$9A,$66,$00,$00,$30,$48,$E7,$80,$90
	dc.b	$30,$3C,$00,$0B,$0C,$78,$00,$02,$C3,$92,$67,$00,$00,$06,$30,$3C
	dc.b	$00,$05,$4E,$B9,$00,$01,$68,$B8,$38,$3C,$00,$02,$4E,$B9,$00,$01
	dc.b	$6C,$5C,$4C,$DF,$09,$01,$60,$00,$00,$0A,$78,$02,$4E,$B9,$00,$01
	dc.b	$6A,$46,$4A,$78,$C3,$94,$67,$00,$00,$60,$08,$38,$00,$03,$C3,$4E
	dc.b	$67,$00,$00,$4E,$0C,$78,$00,$02,$C3,$94,$67,$00,$00,$0E,$4A,$78
	dc.b	$C3,$98,$66,$00,$00,$3C,$60,$00,$00,$0A,$4A,$78,$C3,$9A,$66,$00
	dc.b	$00,$30,$48,$E7,$80,$90,$30,$3C,$00,$0B,$0C,$78,$00,$02,$C3,$94
	dc.b	$67,$00,$00,$06,$30,$3C,$00,$05,$4E,$B9,$00,$01,$68,$B8,$38,$3C
	dc.b	$00,$04,$4E,$B9,$00,$01,$6C,$68,$4C,$DF,$09,$01,$60,$00,$00,$0A
	dc.b	$78,$04,$4E,$B9,$00,$01,$6A,$46,$4A,$78,$C3,$96,$67,$00,$00,$60
	dc.b	$08,$38,$00,$03,$C3,$4E,$67,$00,$00,$4E,$0C,$78,$00,$02,$C3,$96
	dc.b	$67,$00,$00,$0E,$4A,$78,$C3,$98,$66,$00,$00,$3C,$60,$00,$00,$0A
	dc.b	$4A,$78,$C3,$9A,$66,$00,$00,$30,$48,$E7,$80,$90,$30,$3C,$00,$0B
	dc.b	$0C,$78,$00,$02,$C3,$96,$67,$00,$00,$06,$30,$3C,$00,$05,$4E,$B9
	dc.b	$00,$01,$68,$B8,$38,$3C,$00,$06,$4E,$B9,$00,$01,$6C,$74,$4C,$DF
	dc.b	$09,$01,$60,$00,$00,$0A,$78,$06,$4E,$B9,$00,$01,$6A,$46,$4E,$75

updatefaceoff	;Faceoff drop countdown: the fofdata frame from temp1; at 0 erase the faceoff box at fodropx / fodropy
	;Code the listing does not decode: kept as bytes
	dc.b	$30,$2B,$00,$40,$67,$00,$00,$1A,$5C,$40,$E6,$48,$B0,$7C,$00,$02
	dc.b	$6E,$00,$5D,$22,$44,$40,$06,$40,$00,$0A,$31,$C0,$BD,$C6,$4E,$75
	dc.b	$08,$B8,$00,$04,$BF,$B2,$61,$00,$20,$50,$00,$06,$BF,$00,$00,$00
	dc.b	$30,$38,$B0,$4A,$04,$40,$00,$2E,$E6,$40,$31,$C0,$B0,$40,$70,$64
	dc.b	$30,$38,$B0,$4C,$04,$40,$00,$44,$E6,$40,$31,$C0,$B0,$42,$70,$0C
	dc.b	$72,$0D,$34,$3C,$07,$FF,$60,$00,$1E,$08

pucknorm	;asstab entry: the puck: follow the carrier, icing / offsides checks.
	;Code the listing does not decode: kept as bytes
	dc.b	$08,$38,$00,$02,$C3,$40,$67,$00,$00,$06,$61,$00,$FB,$16,$08,$AB
	dc.b	$00,$01,$00,$62,$67,$00,$00,$0C,$42,$6B,$00,$40,$37,$7C,$00,$78
	dc.b	$00,$42,$32,$7C,$BF,$1A,$9F,$69,$00,$02,$9F,$69,$00,$06,$9F,$6B
	dc.b	$00,$40,$6A,$00,$00,$0A,$5A,$6B,$00,$40,$61,$00,$04,$22,$30,$38
	dc.b	$B7,$BE,$6B,$00,$00,$36,$EF,$40,$34,$7C,$B0,$5E,$D4,$C0,$61,$00
	dc.b	$01,$E2,$2F,$0A,$61,$00,$08,$92,$D0,$52,$90,$53,$E4,$40,$D1,$53
	dc.b	$D2,$6A,$00,$14,$92,$6B,$00,$14,$E4,$41,$D3,$6B,$00,$14,$37,$6A
	dc.b	$00,$28,$00,$28,$37,$6A,$00,$2A,$00,$2A,$4E,$B9,$00,$01,$9E,$B2
	dc.b	$4E,$B9,$00,$01,$9C,$50,$08,$38,$00,$00,$C3,$38,$66,$00,$00,$3A
	dc.b	$4A,$78,$B7,$BE,$6A,$00,$00,$2C,$30,$13,$B0,$6B,$00,$1C,$66,$00
	dc.b	$00,$22,$30,$2B,$00,$14,$B0,$6B,$00,$20,$66,$00,$00,$16,$70,$06
	dc.b	$53,$6B,$00,$42,$6A,$00,$00,$08,$4E,$B9,$00,$01,$C1,$D2,$60,$00
	dc.b	$00,$08,$37,$7C,$00,$78,$00,$42,$4A,$2B,$00,$2C,$66,$00,$53,$BC
	dc.b	$4A,$6B,$00,$18,$66,$00,$53,$B4,$61,$00,$02,$CA,$60,$00,$53,$AC

ChkOffsides	;Offsides.
	;Code the listing does not decode: kept as bytes
	dc.b	$08,$38,$00,$05,$C3,$38,$67,$00,$5B,$F2,$08,$38,$00,$02,$C3,$40
	dc.b	$66,$00,$5B,$E8,$32,$7C,$C7,$26,$45,$E9,$03,$9E,$61,$00,$00,$9E
	dc.b	$C3,$4A,$61,$00,$00,$98,$30,$3C,$00,$72,$B0,$6B,$00,$14,$6E,$00
	dc.b	$00,$42,$B0,$6B,$00,$20,$6F,$00,$5B,$C2,$06,$40,$00,$0A,$08,$38
	dc.b	$00,$01,$C3,$38,$67,$00,$00,$04,$C5,$49,$74,$05,$30,$6A,$00,$22
	dc.b	$4A,$68,$00,$34,$6B,$00,$00,$12,$B0,$68,$00,$14,$6C,$00,$00,$0A
	dc.b	$08,$EA,$00,$04,$00,$30,$4E,$75,$D0,$FC,$00,$80,$51,$CA,$FF,$E2
	dc.b	$4E,$75,$44,$40,$B0,$6B,$00,$14,$6D,$00,$5B,$80,$B0,$6B,$00,$20
	dc.b	$6C,$00,$5B,$78,$04,$40,$00,$0A,$08,$38,$00,$01,$C3,$38,$66,$00
	dc.b	$00,$04,$C5,$49,$74,$05,$30,$6A,$00,$22,$4A,$68,$00,$34,$6B,$00
	dc.b	$00,$12,$B0,$68,$00,$14,$6F,$00,$00,$0A,$08,$EA,$00,$04,$00,$30
	dc.b	$4E,$75,$D0,$FC,$00,$80,$51,$CA,$FF,$E2,$4E,$75,$08,$2A,$00,$04
	dc.b	$00,$30,$67,$00,$5B,$36,$30,$6A,$00,$22,$72,$05,$4A,$68,$00,$34
	dc.b	$6B,$00,$00,$12,$30,$28,$00,$14,$08,$28,$00,$07,$00,$62,$66,$00
	dc.b	$00,$04,$44,$40,$D0,$FC,$00,$80,$B0,$7C,$00,$76,$5E,$C9,$FF,$DE
	dc.b	$6E,$00,$5B,$08,$08,$AA,$00,$04,$00,$30,$4E,$75

a2offsides	;Offsides on a2 when his team is offside and the puck is past the blue line.
	;Code the listing does not decode: kept as bytes
	dc.b	$08,$38,$00,$05,$C3,$38,$67,$00,$5A,$F6,$30,$38,$B7,$72,$08,$2A
	dc.b	$00,$07,$00,$62,$66,$00,$00,$04,$44,$40,$B0,$7C,$00,$86,$6D,$00
	dc.b	$5A,$DE,$30,$7C,$C7,$26,$08,$2A,$00,$06,$00,$62,$67,$00,$00,$06
	dc.b	$D0,$FC,$03,$9E,$08,$28,$00,$04,$00,$30,$67,$00,$5A,$C2,$08,$38
	dc.b	$00,$04,$C3,$38,$66,$00,$5A,$B8,$C5,$4B,$70,$10,$4E,$B9,$00,$01
	dc.b	$C1,$92,$C5,$4B,$4E,$75

a2touchpuck	;Player a2 touched the puck: last touch, scorer / assist slots, offsides, icing
	dc.b	$31,$D2,$BF,$B6,$31,$EA,$00,$14,$BF,$B8
	dc.b	$31,$EA,$00,$52,$BF,$B4,$30,$7C,$C7,$26,$08,$2A,$00,$06,$00,$62
	dc.b	$67,$00,$00,$06,$41,$E8,$03,$9E,$42,$40,$10,$2A,$00,$67,$08,$2A
	dc.b	$00,$03,$00,$64,$67,$00,$00,$08,$08,$F8,$00,$07,$C3,$4C,$B0,$68
	dc.b	$00,$18,$67,$00,$00,$28,$08,$A8,$00,$03,$00,$30,$66,$00,$00,$0E
	dc.b	$31,$68,$00,$1A,$00,$1C,$31,$68,$00,$18,$00,$1A,$31,$40,$00,$18
	dc.b	$B0,$68,$00,$1C,$66,$00,$00,$06,$50,$E8,$00,$1C,$08,$B8,$00,$04
	dc.b	$C3,$3C,$61,$00,$FF,$3C,$08,$38,$00,$02,$BF,$BA,$67,$00,$00,$4E
	dc.b	$08,$38,$00,$00,$BF,$BA,$67,$00,$00,$44,$4A,$6A,$00,$34,$67,$00
	dc.b	$00,$3C,$08,$38,$00,$01,$BF,$BA,$66,$00,$00,$2A,$08,$2A,$00,$07
	dc.b	$00,$62,$67,$00,$00,$28,$42,$40,$10,$38,$BF,$BB,$EF,$40,$2F,$0B
	dc.b	$36,$7C,$B0,$5E,$D6,$C0,$30,$3C,$00,$0C,$4E,$B9,$00,$01,$C1,$92
	dc.b	$26,$5F,$4E,$75,$08,$2A,$00,$07,$00,$62,$67,$DA,$61,$00,$00,$04
	dc.b	$4E,$75

ArmIcing	;Icing start for a2: iflags cleared, icingPlayer, direction; bit 2 when shot from his own half and not short
	;handed
	;Code the listing does not decode: kept as bytes
	dc.b	$42,$38,$BF,$BA,$11,$EA,$00,$53,$BF,$BB,$30,$38,$B7,$72,$08,$2A
	dc.b	$00,$07,$00,$62,$67,$00,$00,$0A,$08,$F8,$00,$01,$BF,$BA,$44,$40
	dc.b	$6B,$00,$59,$BA,$30,$38,$C7,$4A,$90,$78,$CA,$E8,$08,$2A,$00,$06
	dc.b	$00,$62,$67,$00,$00,$04,$44,$40,$6B,$00,$59,$A2,$08,$F8,$00,$02
	dc.b	$BF,$BA,$4E,$75

puckIChk	;Icing check.
	;Code the listing does not decode: kept as bytes
	dc.b	$08,$38,$00,$02,$BF,$BA,$67,$00,$59,$90,$08,$38,$00,$00,$BF,$BA
	dc.b	$66,$00,$59,$86,$4A,$78,$B7,$BE,$6A,$00,$59,$7E,$30,$3C,$01,$1E
	dc.b	$08,$38,$00,$01,$BF,$BA,$66,$00,$00,$0E,$44,$40,$B0,$78,$B7,$72
	dc.b	$6E,$00,$00,$0C,$4E,$75,$B0,$78,$B7,$72,$6E,$00,$59,$5C,$0C,$78
	dc.b	$00,$2C,$B7,$5E,$6E,$00,$00,$14,$0C,$78,$FF,$D4,$B7,$5E,$6D,$00
	dc.b	$00,$0A,$08,$B8,$00,$02,$BF,$BA,$4E,$75,$08,$F8,$00,$00,$BF,$BA
	dc.b	$4E,$75

puckunflip	;asstab entry: stop the spinning puck.
	;Code the listing does not decode: kept as bytes
	dc.b	$0C,$6B,$00,$08,$00,$5A,$6D,$00,$00,$12,$0C,$6B,$00,$18,$00,$5A
	dc.b	$6C,$00,$00,$08,$0A,$6B,$00,$02,$00,$54,$00,$6B,$00,$04,$00,$54
	dc.b	$42,$6B,$00,$5A,$50,$EB,$00,$5C,$4E,$75
