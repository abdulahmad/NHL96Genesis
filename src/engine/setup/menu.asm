;	The default menu choices for the setup screens, and the vblank that runs
;	them.

VBlank_SetOptions					;The vertical blank handler of the setup screens.
	movem.l	d0-d7/a0-a6,-(sp)
	btst	#dfng,(disflags).w
	bne.w	.2
	bclr	#dfok,(disflags).w
	beq.w	.1
	bsr.w	DumpSprites2
.1
	bsr.w	cramfade
.2
	addq.w	#1,(Vcount).w
	jsr	(p_music_vblank).l
	movem.l	(sp)+,d0-d7/a0-a6
	rte

DefaultMenus						;Set the default menu choices (defmenuoptions)
	st	(demoflag).w
	movea.l	#$FFFFD254,a0
	movea.l	#defmenuoptions,a1
	move.w	#8,d0
.loop
	move.w	(a1)+,(a0)+
	dbf	d0,.loop
	rts

defmenuoptions						;DefaultMenus: the default options
	dc.b	$00,$00,$00,$01,$00,$0B,$00,$0A,$00,$01,$00,$00,$00,$01,$00,$00
	dc.b	$00,$01

