;	The 4 way play adaptor. Detect4WayPlay looks for an EA 4 Way Play on port 2 and
;	sets FourWayPlay. ReadJoySwapPad1-4 are the unused pad readers, left as bytes.

Detect4WayPlay						;Detect the 4 way play adaptor (EA 4 Way Play) on port 2:
									;FourWayPlay = 1 when found
	move.w	#0,(IO_Z80RES).l
	move.b	#$40,(IO_CT1_CTRL+1).l
	move.b	#$43,(IO_CT2_CTRL+1).l
	nop
	move.b	#$7C,(IO_CT2_DATA+1).l
	nop
	move.b	#$7F,(IO_CT2_CTRL+1).l
	nop
	move.b	#$7C,(IO_CT2_DATA+1).l
	nop
	move.b	(IO_CT1_DATA+1).l,d0
	andi.b	#3,d0
	cmp.b	#0,d0
	bne.s	.0
	move.w	#1,(FourWayPlay).w
	bra.s	.1
.0
	move.w	#0,(FourWayPlay).w
	move.b	#$40,(IO_CT2_CTRL+1).l
.1
	move.w	#$100,(IO_Z80RES).l
	rts

ReadJoySwapPad1						;Unreferenced. Read 4 way play pad 1. Not decoded in the listing: kept as
									;bytes
	dc.b	$13,$FC,$00,$00,$00,$A1,$00,$05,$31,$F8,$BF,$32,$BF,$2E,$4E,$B9
	dc.b	$00,$01,$B3,$48,$31,$F8,$BF,$2E,$BF,$32,$4E,$75

ReadJoySwapPad2						;Unreferenced. The same for pad 2
	dc.b	$13,$FC,$00,$10,$00,$A1,$00,$05,$31,$F8,$BF,$34,$BF,$2E,$4E,$B9
	dc.b	$00,$01,$B3,$48,$31,$F8,$BF,$2E,$BF,$34,$4E,$75

ReadJoySwapPad3						;Unreferenced. The same for pad 3
	dc.b	$13,$FC,$00,$20,$00,$A1,$00,$05,$31,$F8,$BF,$36,$BF,$2E,$4E,$B9
	dc.b	$00,$01,$B3,$48,$31,$F8,$BF,$2E,$BF,$36,$4E,$75

ReadJoySwapPad4						;Unreferenced. The same for pad 4
	dc.b	$13,$FC,$00,$30,$00,$A1,$00,$05,$31,$F8,$BF,$38,$BF,$2E,$4E,$B9
	dc.b	$00,$01,$B3,$48,$31,$F8,$BF,$2E,$BF,$38,$4E,$75

