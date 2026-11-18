;	The pause menu pad side.

SetMenuPadSide						;sflags bit 1 set when the team of pad menupadnum is above 1, else
									;cleared. Called from ManualGoalieMenu and
									;PrintMenuItem
	movem.l	d0/a0-a1,-(sp)
	movea.l	#padteams,a0
	move.w	(menupadnum).w,d0
	asl.w	#2,d0
	movea.l	(a0,d0.w),a0
	cmpi.w	#1,(a0)
	movem.l	(sp)+,d0/a0-a1
	ble.w	.0
	bset	#1,(sflags).w
	bra.w	.exit
.0
	bclr	#1,(sflags).w
.exit
	rts

padteams							;The team word of each pad: cont1team ... cont4team
	dc.b	$FF,$FF,$C3,$90,$FF,$FF,$C3,$92,$FF,$FF,$C3,$94,$FF,$FF,$C3,$96
	dc.b	$08,$38,$00,$03,$C3,$3A,$66,$00,$00,$2E,$48,$E7,$A0,$80,$10,$2B
	dc.b	$00,$62,$12,$38,$C3,$64,$B3,$00,$08,$00,$00,$06,$67,$00,$00,$44
	dc.b	$60,$00,$00,$38,$08,$38,$00,$03,$C3,$3A,$67,$00,$00,$3A,$4A,$78
	dc.b	$B7,$BE,$6B,$00,$00,$32,$48,$E7,$A0,$80,$20,$7C,$FF,$FF,$B0,$5E
	dc.b	$30,$38,$B7,$BE,$EF,$40,$D0,$C0,$10,$28,$00,$62,$14,$2B,$00,$62
	dc.b	$B5,$00,$08,$00,$00,$06,$67,$00,$00,$0A,$32,$3C,$09,$9A,$60,$00
	dc.b	$00,$02,$4C,$DF,$01,$05,$4E,$75
