;	The pads, read every vblank.

ReadJoyData							;Read the pads every vblank. With FourWayPlay, pads 1-4 through the 4 way
									;adaptor (ReadPad4Way1 ...
									;ReadPad4Way4) to pad4way1-pad4way4, else pads 1 and 2 (ReadPad1,
									;ReadPad2).
	movem.l	d1/a0,-(sp)
	tst.w	(FourWayPlay).w
	beq.w	.1
	jsr	(ReadPad4Way1).l
	move.b	d0,(pad4way1).w
	jsr	(ReadPad4Way2).l
	move.b	d0,(pad4way2).w
	bsr.w	ReadPad4Way3
	move.b	d0,(pad4way3).w
	bsr.w	ReadPad4Way4
	move.b	d0,(pad4way4).w
	bra.w	.2
.1
	bsr.w	ReadPad1
	move.b	d0,(pad4way1).w
	bsr.w	ReadPad2
	move.b	d0,(pad4way2).w
.2
	movem.l	(sp)+,d1/a0
	rts

ReadPad4Way1						;4 way play pad 1: pause the sound driver (SoundCmd $D), select pad 1 on
									;port 2 and read it on port 1.
	move.w	d0,-(sp)
	move.w	#$D,d0
	jsr	(SoundCmd).l
	move.w	(sp)+,d0
	move.b	#$C,(IO_CT2_DATA+1).l
	bra.w	ReadPad4WayPort1

ReadPad4Way2						;4 way play pad 2, as ReadPad4Way1.
	move.w	d0,-(sp)
	move.w	#$D,d0
	jsr	(SoundCmd).l
	move.w	(sp)+,d0
	move.b	#$1C,(IO_CT2_DATA+1).l
	bra.w	ReadPad4WayPort1

ReadPad4Way3						;4 way play pad 3, as ReadPad4Way1.
	move.w	d0,-(sp)
	move.w	#$D,d0
	jsr	(SoundCmd).l
	move.w	(sp)+,d0
	move.b	#$2C,(IO_CT2_DATA+1).l
	bra.w	ReadPad4WayPort1

ReadPad4Way4						;4 way play pad 4, as ReadPad4Way1. Falls into ReadPad4WayPort1.
	move.w	d0,-(sp)
	move.w	#$D,d0
	jsr	(SoundCmd).l
	move.w	(sp)+,d0
	move.b	#$3C,(IO_CT2_DATA+1).l

ReadPad4WayPort1					;Read the pad on port 1; branched to from ReadPad4Way1 ... ReadPad4Way4.
	movem.l	d1/a0,-(sp)
	lea	(IO_CT1_DATA+1).l,a0
	bra.w	ReadPad3Button

ReadPad2							;Read pad 2 (port 2). Falls into ReadPadA0.
	movem.l	d1/a0,-(sp)
	lea	(IO_CT2_DATA+1).l,a0
	bra.w	ReadPadA0

ReadPad1							;Read pad 1 (port 1).
	movem.l	d1/a0,-(sp)
	lea	(IO_CT1_DATA+1).l,a0

ReadPadA0							;Pause the sound driver (SoundCmd $D), then ReadPad3Button.
	move.w	d0,-(sp)
	move.w	#$D,d0
	jsr	(SoundCmd).l
	move.w	(sp)+,d0

ReadPad3Button						;Read a 3 button pad at a0 (TH low, then high), resume the sound driver
									;(SoundCmd $E) and return d0 = the
									;buttons, the directions through PadDirTable.
	moveq	#0,d0
	move.b	#0,(a0)
	nop
	nop
	move.b	(a0),d0
	move.b	#$40,(a0)
	nop
	nop
	move.b	(a0),d1
	move.w	d0,-(sp)				;resume the sound driver where 94 released the Z80 bus
	move.w	#$E,d0
	jsr	(SoundCmd).l
	move.w	(sp)+,d0
	asl.b	#2,d0
	andi.b	#$C0,d0
	andi.b	#$3F,d1
	or.b	d1,d0
	not.b	d0
	not.b	d1
	andi.w	#$F,d1
	lea	PadDirTable(pc),a0
	andi.b	#$F0,d0
	or.b	(a0,d1.w),d0
	not.b	d0
	movem.l	(sp)+,d1/a0
	rts

PadDirTable							;Direction nibble table for ReadPad3Button: remaps the nibble when
									;opposite directions are pressed together
	dc.b	$00,$01,$02,$01,$04,$05,$06,$06,$08,$09,$0A,$0A,$08,$09,$0A,$00

ResetZ80Bus							;Reset the Z80 and wait for its bus.
	move.w	#$100,(IO_Z80RES).l
	move.w	#$100,(IO_Z80BUS).l
.loop
	btst	#0,(IO_Z80BUS).l
	bne.s	.loop
	rts
