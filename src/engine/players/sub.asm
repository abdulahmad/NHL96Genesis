;	Who can fill a line slot, and which slots matter most.

sublist								;Substitution lists by position (goalie, LD, RD, LW, C, RW, extra
									;attacker), word offsets from sublist. Used
									;by SetPlList
	dc.w	.defl-sublist
	dc.w	.defl-sublist
	dc.w	.defr-sublist
	dc.w	.wingl-sublist
	dc.w	.center-sublist
	dc.w	.wingr-sublist
	dc.w	.center-sublist
.defl	dc.b	$01,$09,$11,$19,$21,$29,$31
	dc.b	$02,$0A,$12,$1A,$22,$2A,$32
.defr	dc.b	$02,$0A,$12,$1A,$22,$2A,$32
	dc.b	$01,$09,$11,$19,$21,$29,$31
.wingl	dc.b	$03,$0B,$13,$1B,$23,$2B,$33
	dc.b	$05,$0D,$15,$1D,$25,$2D,$35
	dc.b	$04,$0C,$14,$1C,$24,$2C,$34
.wingr	dc.b	$05,$0D,$15,$1D,$25,$2D,$35
	dc.b	$03,$0B,$13,$1B,$23,$2B,$33
	dc.b	$04,$0C,$14,$1C,$24,$2C,$34
.center	dc.b	$04,$0C,$14,$1C,$24,$2C,$34
	dc.b	$03,$0B,$13,$1B,$23,$2B,$33
	dc.b	$05,$0D,$15,$1D,$25,$2D,$35
	dc.b	-1

priolist							;Positions in order of importance. Used by SetPlList
	dc.b	$00,$01,$02,$04,$03,$05,$06
	dc.b	$FF
