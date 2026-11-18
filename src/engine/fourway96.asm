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
	move.b	#0,(IO_CT2_DATA+1).l
	move.w	(pad4way4+5).w,(pad4way4+1).w
	jsr	(ReadJoy1).l
	move.w	(pad4way4+1).w,(pad4way4+5).w
	rts

ReadJoySwapPad2						;Unreferenced. The same for pad 2
	move.b	#$10,(IO_CT2_DATA+1).l
	move.w	(pad4way4+7).w,(pad4way4+1).w
	jsr	(ReadJoy1).l
	move.w	(pad4way4+1).w,(pad4way4+7).w
	rts

ReadJoySwapPad3						;Unreferenced. The same for pad 3
	move.b	#$20,(IO_CT2_DATA+1).l
	move.w	($FFFFBF36).w,(pad4way4+1).w
	jsr	(ReadJoy1).l
	move.w	(pad4way4+1).w,($FFFFBF36).w
	rts

ReadJoySwapPad4						;Unreferenced. The same for pad 4
	move.b	#$30,(IO_CT2_DATA+1).l	;4 way play: select pad
	move.w	($FFFFBF38).w,(pad4way4+1).w
	jsr	(ReadJoy1).l
	move.w	(pad4way4+1).w,($FFFFBF38).w
	rts

