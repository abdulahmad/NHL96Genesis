;	Three pause-menu entries. PlayoffStatsMenu opens the playoff stats, TimeoutMenu calls a
;	timeout, and SelectGoalieMenu changes the goalie.

PlayoffStatsMenu	;Pause menu Playoff Stats: with GameFlags bit 7 set jump to SeasonPlayoffStats, else PlayerStatsList for the team struct
	;of team potree + potreeteam
	btst	#7,(GameFlags).w
	beq.w	.0
	jmp	SeasonPlayoffStats
.0
	movem.l	a2,-(sp)
	jsr	(ReadTeamStats).l
	movea.w	#(potree-M68K_RAM),a0
	move.w	(potreeteam).w,d0
	move.b	(a0,d0.w),d0
	movea.w	#(tmstruct-M68K_RAM),a2
	cmp.w	$28(a2),d0
	beq.w	.1
	adda.w	#$39E,a2
.1
	moveq	#1,d7
	jsr	(PlayerStatsList).l
	movem.l	(sp)+,a2
	rts

ExitStatsScreen	;Leave a stats screen: forceblack, then reload the rink graphics (the entry after the forceblack)
	;Code the listing does not decode: kept as bytes
	dc.b	$61,$00,$5A,$7C,$3F,$38,$BF,$B2,$08,$F8,$00,$02,$BF,$B2,$30,$38
	dc.b	$B0,$00,$61,$00,$61,$90,$20,$BC,$00,$00,$00,$00,$30,$3C,$8D,$00
	dc.b	$10,$38,$B0,$00,$E4,$08,$31,$40,$00,$04,$31,$7C,$8C,$00,$00,$04
	dc.b	$31,$FC,$00,$05,$B0,$0E,$31,$DF,$BF,$B2,$08,$F8,$00,$01,$BF,$B2
	dc.b	$38,$38,$B0,$22,$24,$7C,$00,$09,$23,$EC,$08,$38,$00,$04,$C3,$42
	dc.b	$67,$00,$00,$02,$61,$00,$62,$06,$4E,$B9,$00,$1D,$8E,$6C,$4E,$B9
	dc.b	$00,$1D,$8E,$5C,$38,$38,$B0,$1C,$4E,$B9,$00,$02,$43,$A0,$38,$38
	dc.b	$B0,$28,$4E,$B9,$00,$01,$C1,$84,$4E,$B9,$00,$02,$10,$B0,$4E,$B9
	dc.b	$00,$02,$10,$C2,$4E,$B9,$00,$02,$10,$D0,$4E,$B9,$00,$02,$10,$9A
	dc.b	$08,$F8,$00,$07,$C3,$54,$4E,$F9,$00,$02,$15,$B2

TimeoutMenu	;Pause menu Timeout.
	;Code the listing does not decode: kept as bytes
	dc.b	$4E,$B9,$00,$1E,$2E,$AA,$53,$78,$CF,$FE,$53,$78,$D0,$00,$23,$FC
	dc.b	$00,$02,$38,$90,$FF,$FF,$D0,$02,$08,$EA,$00,$02,$00,$30,$61,$00
	dc.b	$65,$FE,$00,$06,$BF,$04,$0C,$00,$70,$16,$72,$06,$61,$00,$69,$26
	dc.b	$00,$1A,$F8,$04,$01,$0C,$06,$F9,$01,$20,$20,$20,$20,$54,$69,$6D
	dc.b	$65,$6F,$75,$74,$F8,$04,$01,$15,$08,$00,$22,$6A,$00,$1E,$D2,$E9
	dc.b	$00,$04,$30,$11,$E2,$48,$91,$78,$B0,$40,$61,$00,$69,$1C,$34,$7C
	dc.b	$C7,$26,$4E,$B9,$00,$01,$D3,$80,$D4,$FC,$03,$9E,$4E,$B9,$00,$01
	dc.b	$D3,$80,$08,$38,$00,$00,$C3,$38,$66,$00,$00,$14,$42,$78,$B0,$4A
	dc.b	$42,$78,$B0,$4C,$30,$3C,$00,$0A,$4E,$B9,$00,$01,$C1,$D2,$70,$78
	dc.b	$60,$00,$5B,$50

SelectGoalieMenu	;Pause menu Change Goalie.
	;Code the listing does not decode: kept as bytes
	dc.b	$4E,$B9,$00,$1E,$2E,$AA,$3F,$38,$CF,$FE,$3F,$38,$D0,$00,$61,$00
	dc.b	$01,$8E,$31,$C0,$D0,$00,$61,$00,$65,$72,$00,$06,$BF,$04,$0C,$00
	dc.b	$70,$18,$72,$03,$D2,$78,$D0,$00,$30,$2A,$00,$26,$6A,$00,$00,$04
	dc.b	$70,$FF,$52,$40,$31,$C0,$CF,$FE,$61,$00,$00,$6E,$61,$00,$01,$C2
	dc.b	$08,$01,$00,$07,$66,$00,$00,$34,$08,$01,$00,$05,$66,$00,$00,$2C
	dc.b	$08,$01,$00,$01,$67,$00,$00,$12,$30,$38,$CF,$FE,$52,$40,$B0,$78
	dc.b	$D0,$00,$6E,$D4,$31,$C0,$CF,$FE,$08,$01,$00,$00,$67,$CA,$53,$78
	dc.b	$CF,$FE,$6A,$C4,$42,$78,$CF,$FE,$60,$BE,$30,$38,$CF,$FE,$53,$40
	dc.b	$6A,$00,$00,$12,$08,$38,$00,$00,$C3,$3C,$67,$00,$00,$08,$31,$FC
	dc.b	$00,$0A,$B7,$9E,$35,$40,$00,$26,$4E,$B9,$00,$01,$FB,$52,$31,$DF
	dc.b	$D0,$00,$31,$DF,$CF,$FE,$4E,$75,$31,$FC,$00,$06,$B0,$42,$32,$38
	dc.b	$D0,$00,$70,$00,$31,$FC,$00,$0B,$B0,$40,$4E,$B9,$00,$01,$BE,$C4
	dc.b	$00,$08,$FE,$04,$FF,$01,$F9,$01,$B0,$78,$CF,$FE,$66,$00,$00,$10
	dc.b	$4E,$B9,$00,$01,$BE,$C4,$00,$08,$FE,$04,$FF,$01,$F9,$02,$61,$00
	dc.b	$67,$E0,$00,$14,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	dc.b	$20,$20,$20,$20,$20,$20,$4A,$40,$66,$00,$00,$20,$31,$FC,$00,$0B
	dc.b	$B0,$40,$61,$00,$67,$BC,$00,$10,$20,$20,$6E,$6F,$20,$67,$6F,$61
	dc.b	$6C,$69,$65,$20,$20,$00,$60,$00,$00,$4C,$34,$00,$53,$42,$31,$C2
	dc.b	$C4,$C8,$B5,$FC,$FF,$FF,$C7,$26,$67,$00,$00,$06,$50,$F8,$C4,$C8
	dc.b	$4E,$B9,$00,$02,$30,$4C,$31,$FC,$00,$0B,$B0,$40,$4E,$B9,$00,$01
	dc.b	$BE,$C4,$00,$04,$20,$20,$0C,$B9,$00,$1B,$89,$C8,$FF,$FF,$B0,$10
	dc.b	$66,$00,$00,$08,$08,$F8,$00,$06,$C3,$58,$61,$00,$67,$88,$08,$B8
	dc.b	$00,$06,$C3,$58,$54,$78,$B0,$42,$52,$40,$51,$C9,$FF,$48,$4E,$75
