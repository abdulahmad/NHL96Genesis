;	Instant replay. ReplayMode plays a replay back. updatereplay records one frame
;	of the players, the puck and the camera. ReadMenuJoy reads the menu pad.

ReplayMode							;Instant replay play-back control and display code.
									;Pause menu INSTANT REPLAY.
	bclr	#0,(sflags5).w
	bsr.w	forceblack
	jsr	(stop_current_song).l
	move.w	#9,d0
	jsr	(SoundCmd).l
	move.w	#0,d0
	move.w	#$1B24,d1
	movea.l	#Z80Program,a0
	jsr	(SoundCmd).l
	move.w	#6,d0
	clr.w	d1
	movea.l	#SoundBanks,a0
	jsr	(SoundCmd).l
	move.w	#7,d0
	move.w	#1,d1
	jsr	(SoundCmd).l
	move.w	(disflags).w,-(sp)
	bset	#3,(sflags2).w
	bclr	#4,(sflags4).w
	jsr	(RestoreGameScreen).l
	jsr	(ShowReplayIcon).l
	bclr	#5,(sflags).w
	bclr	#5,(sflags3).w
	st	($FFFFBE6C).w
	movea.l	(recbpr).w,a4
.loop
	bsr.w	suba4
	tst.w	d7
	bne.s	.loop
	jsr	(SprSort).l
	jsr	(setvideo).l
	bclr	#1,(sflags3).w
	clr.l	(padcont).w
	clr.l	(padcont+4).w
	clr.l	(padcont+8).w
	move.w	#$18,(palcount).w
	moveq	#1,d7
.top
; Code kept as bytes (decoded by decode_code.py).
	dc.b	$30,$38,$B0,$52,$90,$78,$B0,$54,$BE,$40,$62,$F4,$31,$F8,$B0,$52
	dc.b	$B0,$54,$4A,$78,$DC,$A8,$6B,$00,$00,$14,$9F,$78,$DC,$A8,$6A,$00
	dc.b	$00,$0C,$42,$78,$DC,$A8,$4E,$B9,$00,$01,$5D,$2A,$48,$E7,$80,$10
	dc.b	$26,$7C,$FF,$FF,$B6,$5E,$37,$7C,$00,$01,$00,$08,$26,$7C,$FF,$FF
	dc.b	$B6,$DE,$37,$7C,$00,$01,$00,$08,$4C,$DF,$08,$01,$7E,$01,$61,$00
	dc.b	$03,$C0,$08,$38,$00,$00,$C3,$44,$67,$00,$00,$12,$02,$40,$FF,$F0
	dc.b	$00,$40,$00,$08,$02,$41,$FF,$F0,$02,$43,$FF,$F0,$3A,$7C,$BE,$56
	dc.b	$08,$38,$00,$05,$C3,$3E,$67,$00,$00,$0C,$3A,$01,$02,$45,$00,$0F
	dc.b	$67,$00,$01,$88,$08,$00,$00,$03,$66,$00,$01,$80,$0C,$55,$FF,$60
	dc.b	$6E,$00,$00,$0A,$3A,$BC,$00,$00,$60,$00,$00,$02,$0C,$6D,$FE,$B0
	dc.b	$00,$14,$6E,$00,$00,$08,$3B,$7C,$00,$00,$00,$14,$08,$F8,$00,$05
	dc.b	$C3,$3A,$66,$00,$00,$0C,$3A,$B8,$BD,$32,$3B,$78,$BD,$2E,$00,$14
	dc.b	$3A,$00,$02,$45,$00,$07,$0A,$45,$00,$04,$32,$7C,$B0,$5E,$50,$C3
	dc.b	$08,$B8,$00,$05,$C3,$3E,$67,$00,$00,$06,$36,$2D,$00,$16,$30,$15
	dc.b	$32,$2D,$00,$14,$74,$0B,$28,$3C,$00,$00,$01,$00,$48,$A7,$C0,$00
	dc.b	$B6,$69,$00,$52,$67,$00,$00,$58,$4C,$97,$00,$03,$90,$51,$92,$69
	dc.b	$00,$14,$4E,$B9,$00,$01,$A3,$EE,$08,$00,$00,$03,$66,$00,$00,$40
	dc.b	$90,$45,$52,$40,$02,$40,$00,$07,$B0,$7C,$00,$02,$62,$00,$00,$30
	dc.b	$4C,$97,$00,$03,$90,$51,$92,$69,$00,$14,$C1,$C0,$C3,$C1,$D0,$81
	dc.b	$B0,$BC,$00,$00,$00,$04,$63,$00,$00,$16,$B0,$84,$62,$00,$00,$10
	dc.b	$28,$00,$3B,$69,$00,$52,$00,$16,$08,$F8,$00,$05,$C3,$3E,$D2,$FC
	dc.b	$00,$80,$51,$CA,$FF,$9C,$58,$4F,$08,$38,$00,$05,$C3,$3E,$67,$00
	dc.b	$00,$22,$30,$2D,$00,$16,$EF,$40,$36,$7C,$B0,$5E,$D6,$C0,$78,$04
	dc.b	$61,$00,$13,$30,$61,$00,$04,$BC,$4E,$B9,$00,$02,$03,$4A,$60,$00
	dc.b	$FE,$80,$08,$F8,$00,$05,$C3,$3A,$0A,$45,$00,$04,$E5,$45,$41,$FA
	dc.b	$00,$5A,$30,$30,$50,$00,$D0,$55,$B0,$7C,$00,$96,$6E,$00,$00,$0C
	dc.b	$B0,$7C,$FF,$6A,$6D,$00,$00,$04,$3A,$80,$32,$30,$50,$02,$D2,$6D
	dc.b	$00,$14,$B2,$7C,$01,$3C,$6E,$00,$00,$0E,$B2,$7C,$FE,$C4,$6D,$00
	dc.b	$00,$06,$3B,$41,$00,$14,$36,$4D,$42,$6D,$00,$18,$02,$B8,$00,$0F
	dc.b	$FF,$FF,$BE,$AA,$00,$B8,$00,$E0,$00,$00,$BE,$AA,$61,$00,$04,$54
	dc.b	$4E,$B9,$00,$02,$03,$4A,$60,$00,$FE,$18,$00,$00,$00,$02,$00,$02
	dc.b	$00,$02,$00,$02,$00,$00,$00,$02,$FF,$FE,$00,$00,$FF,$FE,$FF,$FE
	dc.b	$FF,$FE,$FF,$FE,$00,$00,$FF,$FE,$00,$02,$50,$ED,$00,$18,$08,$01
	dc.b	$00,$05,$67,$00,$00,$12,$08,$38,$00,$00,$C3,$44,$66,$00,$00,$08
	dc.b	$08,$78,$00,$01,$C3,$3E,$08,$03,$00,$06,$67,$00,$00,$30,$08,$38
	dc.b	$00,$00,$C3,$44,$66,$00,$00,$26,$61,$00,$02,$DE,$61,$00,$02,$DA
	dc.b	$61,$00,$02,$D6,$61,$00,$02,$D2,$4E,$B9,$00,$02,$13,$AE,$4E,$B9
	dc.b	$00,$02,$03,$4A,$7E,$01,$08,$B8,$00,$01,$C3,$3E,$08,$38,$00,$00
	dc.b	$C3,$44,$66,$00,$00,$52,$08,$03,$00,$04,$67,$00,$00,$4A,$08,$03
	dc.b	$00,$06,$67,$00,$00,$2A,$08,$B8,$00,$05,$C3,$3E,$08,$B8,$00,$05
	dc.b	$C3,$3A,$2F,$00,$20,$38,$BE,$AA,$02,$80,$00,$0F,$FF,$FF,$00,$80
	dc.b	$00,$E0,$00,$00,$21,$C0,$BE,$AA,$20,$1F,$60,$00,$FD,$64,$61,$00
	dc.b	$02,$AA,$4E,$B9,$00,$02,$13,$AE,$4E,$B9,$00,$02,$03,$4A,$E3,$47
	dc.b	$08,$B8,$00,$01,$C3,$3E,$08,$38,$00,$01,$C3,$3E,$67,$00,$00,$1A
	dc.b	$50,$F8,$C0,$64,$61,$00,$02,$84,$3F,$38,$C0,$64,$4E,$B9,$00,$08
	dc.b	$84,$70,$4E,$B9,$00,$02,$13,$AE,$4E,$B9,$00,$02,$03,$4A,$08,$38
	dc.b	$00,$00,$C3,$44,$66,$00,$00,$24,$08,$01,$00,$07,$67,$00,$FD,$12
	dc.b	$4E,$B9,$00,$01,$5D,$48,$08,$B8,$00,$01,$C3,$3E,$08,$F8,$00,$00
	dc.b	$C3,$44,$66,$00,$00,$06,$60,$00,$FC,$F8,$08,$01,$00,$07,$66,$00
	dc.b	$00,$40,$08,$01,$00,$06,$66,$00,$00,$32,$08,$01,$00,$04,$66,$00
	dc.b	$00,$3A,$08,$01,$00,$05,$67,$00,$FC,$D8,$08,$F8,$00,$06,$C3,$42
	dc.b	$08,$B8,$00,$00,$C3,$44,$4E,$B9,$00,$01,$5D,$C2,$61,$00,$02,$0C
	dc.b	$4E,$B9,$00,$02,$13,$AE,$60,$00,$FC,$B8,$4E,$F9,$00,$01,$58,$C8
	dc.b	$42,$78,$CF,$FE,$08,$F8,$00,$01,$C3,$44,$61,$00,$53,$2E,$00,$B8
	dc.b	$F0,$00,$00,$00,$BE,$AA,$08,$B8,$00,$05,$C3,$3A,$28,$78,$B0,$4E
	dc.b	$08,$B8,$00,$04,$C3,$42,$61,$00,$03,$30,$4E,$B9,$00,$02,$13,$AE
	dc.b	$08,$B8,$00,$03,$C3,$3C,$31,$DF,$BF,$B2,$4E,$B9,$00,$01,$54,$D8
	dc.b	$4E,$B9,$00,$02,$10,$B0,$4E,$B9,$00,$02,$10,$C2,$4E,$B9,$00,$02
	dc.b	$10,$D0,$4E,$B9,$00,$02,$10,$EC,$31,$FC,$FF,$FF,$D2,$A2,$30,$3C
	dc.b	$00,$00,$32,$3C,$1B,$24,$20,$7C,$00,$02,$55,$00,$4E,$B9,$00,$08
	dc.b	$83,$9E,$30,$3C,$00,$09,$4E,$B9,$00,$08,$83,$9E,$30,$3C,$00,$06
	dc.b	$42,$41,$20,$7C,$00,$02,$70,$26,$4E,$B9,$00,$08,$83,$9E,$30,$3C
	dc.b	$00,$07,$32,$3C,$00,$00,$4E,$B9,$00,$08,$83,$9E,$08,$38,$00,$04
	dc.b	$BF,$B2,$67,$00,$00,$0E,$4E,$B9,$00,$02,$11,$08,$4E,$B9,$00,$02
	dc.b	$10,$FA,$4E,$B9,$00,$02,$03,$4A,$31,$FC,$00,$18,$BD,$3C,$4E,$75

ReadMenuJoy							;Read the menu pad: pad menupadnum (ReadJoy1-4)
	tst.w	(menupadnum).w
	beq.w	ReadJoy1
	cmpi.w	#1,(menupadnum).w
	beq.w	ReadJoy2
	cmpi.w	#2,(menupadnum).w
	beq.w	ReadJoy3
	bra.w	ReadJoy4

ShowReplayIcon						;Show the replay icon and start the $F0 frame replayicontimer timer.
	move.w	#$F0,(OptPad+2).w
	bsr.w	printz
	String	-(TXPRI+TXMAP1),1,1
	clr.w	d0
	clr.w	d1
	moveq	#$D,d2
	moveq	#6,d3
	move.w	(ReplayIconChars).w,d4
	move.w	#0,d5
	movea.l	#ReplayIconMap,a1
	adda.l	4(a1),a1
	movea.w	#$772,a2
	bra.w	dobitmap

EraseReplayIcon						;Erase the replay icon (replayicontimer ran out).
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),1,1
	move.w	#$D,d0
	move.w	#6,d1
	move.w	#$7FF,d2
	jmp	(eraser).l

ShowReplayBanner					;Erase the replay icon, show the replay banner and stop the
									;replayicontimer timer.
									;Code the listing does not decode: kept as bytes
	dc.b	$4E,$B9,$00,$01,$5D,$2A,$50,$F8,$DC,$A8,$61,$00,$5E,$3A,$00,$06
	dc.b	$BF,$02,$00,$00,$70,$00,$72,$00,$74,$14,$76,$08,$38,$38,$B0,$3A
	dc.b	$3A,$3C,$00,$00,$22,$7C,$00,$14,$12,$28,$D3,$E9,$00,$04,$34,$7C
	dc.b	$07,$72,$61,$00,$59,$16,$4E,$B9,$00,$01,$C1,$1A,$00,$20,$F8,$04
	dc.b	$01,$07,$01,$6F,$70,$74,$69,$6F,$6E,$73,$FD,$07,$FA,$02,$72,$65
	dc.b	$76,$65,$72,$73,$65,$20,$61,$6E,$67,$6C,$65,$00,$4E,$B9,$00,$01
	dc.b	$C1,$2C,$00,$16,$FD,$05,$FC,$05,$73,$74,$61,$72,$74,$20,$2D,$20
	dc.b	$74,$6F,$20,$67,$61,$6D,$65,$00,$4E,$75

EraseReplayBanner					;Erase the area ShowReplayBanner drew.
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),2,0
	move.w	#$14,d0
	move.w	#8,d1
	move.w	#$7FF,d2
	jmp	(eraser).l

suba4								;a4 = current replay frame. Back up 1 frame and set video parameters for
									;display.
									;Code the listing does not decode: kept as bytes
	dc.b	$B9,$FC,$FF,$FF,$00,$00,$66,$00,$00,$12,$08,$38,$00,$04,$C3,$3A
	dc.b	$67,$00,$00,$18,$28,$7C,$FF,$FF,$AF,$64,$98,$FC,$00,$64,$B9,$F8
	dc.b	$B0,$4E,$66,$00,$01,$6C,$D8,$FC,$00,$64,$61,$00,$01,$64,$42,$47
	dc.b	$4E,$75,$08,$B8,$00,$06,$C3,$42,$67,$00,$00,$9E,$48,$E7,$FF,$FE
	dc.b	$08,$78,$00,$04,$C3,$42,$3F,$38,$BD,$32,$3F,$38,$BD,$2E,$61,$00
	dc.b	$51,$4C,$4E,$B9,$00,$01,$51,$E0,$4E,$B9,$00,$01,$51,$E0,$42,$78
	dc.b	$BD,$32,$42,$78,$BD,$2E,$31,$FC,$07,$D0,$BD,$30,$30,$3C,$00,$01
	dc.b	$4E,$B9,$00,$02,$03,$4A,$4E,$B9,$00,$01,$51,$E0,$51,$C8,$FF,$F2
	dc.b	$31,$DF,$BD,$2E,$31,$DF,$BD,$32,$30,$3C,$00,$01,$4E,$B9,$00,$02
	dc.b	$03,$4A,$4E,$B9,$00,$01,$51,$E0,$51,$C8,$FF,$F8,$48,$E7,$00,$80
	dc.b	$20,$7C,$FF,$FF,$B6,$5E,$31,$7C,$00,$01,$00,$08,$D0,$FC,$00,$80
	dc.b	$31,$7C,$00,$01,$00,$08,$4C,$DF,$01,$00,$61,$00,$00,$C4,$08,$38
	dc.b	$00,$05,$C3,$3A,$67,$00,$00,$02,$4E,$B9,$00,$01,$5C,$F8,$31,$FC
	dc.b	$00,$64,$BD,$3C,$4C,$DF,$7F,$FF,$42,$47,$08,$38,$00,$02,$C3,$3C
	dc.b	$67,$00,$00,$16,$48,$E7,$00,$08,$61,$00,$00,$1A,$B9,$F8,$B0,$4E
	dc.b	$4C,$DF,$10,$00,$67,$00,$04,$18,$B9,$F8,$B0,$4E,$67,$00,$04,$10
	dc.b	$61,$00,$00,$8E,$D8,$FC,$00,$64,$B9,$FC,$FF,$FF,$AF,$64,$66,$00
	dc.b	$03,$FE,$28,$7C,$FF,$FF,$00,$00,$4E,$75

UpdateCameraPos						;Camera struct a5 = object a3 x/y (negated for the reverse angle),
									;Hpos/Vpos clamped.
	movem.l	d0-d2,-(sp)
	move.w	(a3),d0
	btst	#7,(sflags4).w
	beq.w	.1
	neg.w	d0
.1
	move.w	d0,(a5)
	move.w	Ypos(a3),d1
	btst	#7,(sflags4).w
	beq.w	.2
	neg.w	d1
.2
	move.w	d1,$14(a5)
	cmp.w	#$3C,d0
	blt.w	.3
	move.w	#$3C,d0
.3
	cmp.w	#$FFC4,d0
	bgt.w	.4
	move.w	#$FFC4,d0
.4
	move.w	d0,(Hpos).w
	cmp.w	#$F8,d1
	blt.w	.5
	move.w	#$F8,d1
.5
	cmp.w	#$FF18,d1
	bgt.w	.6
	move.w	#$FF18,d1
.6
	move.w	d1,(Vpos).w
	movem.l	(sp)+,d0-d2
	rts

RevReplayAdj						;Set sflags4 bit 7 for a reverse angle replay, then fall into the frame
									;restore.
	btst	#4,(sflags4).w
	beq.w	.1
	bset	#7,(sflags4).w
.1
	movem.l	d0-d2/a0/a6,-(sp)
	movea.l	#revframetbl,a6			;reverse frame table
	movea.l	a4,a0					;frame data
	moveq	#$F,d1					;16 objects to convert (12 players/2 nets/puck/puck shadow)
	movea.w	#(SortCords-M68K_RAM),a3
	;each of the 16 objects
.loop
	move.w	2(a0),d2				;loop over the 16 objects: x from word 1
	andi.w	#$1FF,d2
	btst	#8,d2
	beq.w	.2
	ori.w	#$FE00,d2
	;X sign extended
.2
	btst	#4,(sflags4).w			;check if reverse angle
	beq.w	.3
	neg.w	d2
	;X mirrored for reverse angle
.3
	move.w	d2,(a3)					;update Xpos
	move.l	(a0),d2					;frame long
	asr.l	#3,d2
	asr.w	#6,d2
	btst	#9,d2					;negative?
	beq.w	.4
	ori.w	#$FC00,d2
	;Y sign extended
.4
	btst	#4,(sflags4).w			;check if reverse angle
	beq.w	.5
	neg.w	d2
	cmp.w	#0,d1					;check if last object (puck shadow)
	bne.w	.5
	addq.w	#2,d2					;update puck shadow Xpos
	;Y mirrored (puck shadow shifted) for reverse angle
.5
	move.w	d2,Ypos(a3)
	move.w	(a0),d2					;frame word
	asr.w	#3,d2
	andi.w	#$7FF,d2
	btst	#4,(sflags4).w			;check if reverse angle
	beq.w	.8
	asl.w	#1,d2
	move.w	(a6,d2.w),d2			;look up table to adjust d2
	subq.w	#1,d2
	cmpi.w	#$F,SCnum(a3)			;check if puck shadow
	bne.w	.6
	cmp.w	#$299,d2				;puck?
	beq.w	.6
	move.w	#$FC00,Ypos(a3)			;update Ypos of puck shadow
	;puck shadow handled
.6
	cmp.w	#1,d2					;check if frame is before frame 1 (out of range)
	blt.w	.7
	cmp.w	#$742,d2
	bge.w	.7
	bra.w	.8						;branch if valid object frame
	;d2 < 1 or d2 >= $34E
.7
	move.w	(a0),d2					;frame word
	asr.w	#3,d2
	andi.w	#$7FF,d2
	;frame number ready
.8
	move.w	d2,frame(a3)
	cmp.w	#$73A,d2				;check if frame is before glass shatter frames
	blt.w	.9
	cmp.w	#$73F,d2				;check if frame is after glass shatter frames
	bge.w	.9
	btst	#4,(sflags4).w			;reverse angle?
	beq.w	.9
	move.w	#$190,Ypos(a3)			;glass Y
.9
	btst	#4,(sflags4).w
	beq.w	.10
	cmp.w	#$213,d2
	blt.w	.10
	cmp.w	#$222,d2
	bgt.w	.10
	move.w	#$190,Ypos(a3)
	;glass shatter moved for reverse angle
.10
	move.w	(a0),d2					;frame word
	asr.w	#3,d2
	andi.w	#$1800,d2				;flip bits
	andi.w	#$E7FF,attribute(a3)	;flip bits
	or.w	d2,attribute(a3)
	btst	#4,(sflags4).w			;check if reverse angle replay
	beq.w	.11
	move.w	frame(a3),d2			;move frame into d2
	cmp.w	#$5E3,d2				;check if frame is before old fight frames
	blt.w	.11
	cmp.w	#$68B,d2				;check if frame is after old fight frames
	bge.w	.11
	bchg	#3,attribute(a3)		;change X flip attribute for object
.11
	move.w	frame(a3),d2
	cmp.w	#$213,d2
	blt.w	.12
	cmp.w	#$222,d2
	bgt.w	.12
	bclr	#3,attribute(a3)
	;fight frames flipped
.12
	addq.w	#4,a0					;next object data
	adda.w	#SCstruct,a3
	dbf	d1,.loop					;loop to next object
	moveq	#5,d2					;6 pairs of players
	movea.w	#(SortCords-M68K_RAM),a3
.loop2
	move.b	(a0)+,spodds(a3)
	move.b	(a0),d0					;position byte
	andi.w	#$F,d0					;low nibble
	cmp.w	#$F,d0					;$F?
	bne.w	.13
	moveq	#-$1,d0
	;$F = no position (-1)
.13
	move.w	d0,position(a3)			;position of the first player of the pair
	adda.w	#SCstruct,a3
	move.b	(a0)+,d0
	lsr.b	#4,d0					;high nibble
	move.b	d0,spodds(a3)
	move.b	(a0),d0
	asl.b	#4,d0					;low nibble up
	or.b	d0,spodds(a3)
	move.b	(a0)+,d0				;position byte
	lsr.b	#4,d0					;high nibble
	andi.w	#$F,d0
	cmp.w	#$F,d0					;$F?
	bne.w	.14
	moveq	#-$1,d0
	;$F = no position (-1)
.14
	move.w	d0,position(a3)
	adda.w	#SCstruct,a3
	dbf	d2,.loop2					;loop
	move.b	(a0)+,d0
	ext.w	d0
	move.w	d0,(puckz).w
	move.b	(a0)+,d0
	ext.w	d0
	move.w	d0,($FFFFB7F6).w
	move.b	(a0)+,d0
	ext.w	d0
	move.w	d0,(lastsfx).w
	clr.w	d7
	move.b	(a0)+,d7				;frame delay
	move.w	(a0)+,d0
	move.w	d0,(PadControlBits+2).w
	move.w	(a0)+,(Crowdframe).w
	move.w	(a0)+,(glovecords+2).w	;crowd frame
	move.w	(a0)+,(glovecords).w
	move.b	(a0)+,(PBnum).w			;penalty box count
	clr.w	d0
	move.b	(a0)+,d0
	ori.w	#$FF00,d0
	move.w	d0,(PadControlBits).w
	btst	#sfscrl,(sflags).w		;scrolling?
	beq.w	.16
	movea.w	a5,a3
	btst	#5,(sflags3).w			;tracking an object?
	beq.w	.15						;tracking?
	clr.w	$18(a5)					;camera moving
	move.w	$16(a5),d0
	asl.w	#7,d0					;* SCstruct
	movea.w	#(SortCords-M68K_RAM),a3
	adda.w	d0,a3
	;camera follows a3
.15
	bsr.w	UpdateCameraPos			;camera position
	bra.w	.17
	;sfscrl clear
.16
	move.w	(a0)+,(Hpos).w
	move.w	(a0)+,(Vpos).w
	btst	#4,(sflags4).w			;reverse angle?
	beq.w	.17
	neg.w	(Hpos).w
	neg.w	(Vpos).w
	jsr	(ClampReplayView).l
	;view clamped
.17
	bclr	#7,(sflags4).w			;clear the reverse flag
	movem.l	(sp)+,d0-d2/a0/a6
	rts

ClampReplayView						;Clamp Hpos to -$3C..$3C and Vpos to -$C8..$100.
	move.w	d0,-(sp)
	move.w	#$3C,d0
	cmp.w	(Hpos).w,d0
	blt.w	.1
	move.w	#$FFC4,d0
	cmp.w	(Hpos).w,d0
	ble.w	.2
.1
	move.w	d0,(Hpos).w
.2
	move.w	#$100,d0
	cmp.w	(Vpos).w,d0
	blt.w	.3
	move.w	#$FF38,d0
	cmp.w	(Vpos).w,d0
	ble.w	.4
.3
	move.w	d0,(Vpos).w
.4
	move.w	(sp)+,d0
	rts

updatereplay						;Called every frame to save replay events, d7 = elapsed frames
	btst	#gmhl,(gmode).w			;check if highlight
	bne.w	rtss8					;exit if so
	btst	#sf2drec,(sflags2).w	;check if replay record disabled
	beq.w	.0						;branch if not
	tst.w	(replaydelay).w
	beq.w	.rec
	subq.w	#1,(replaydelay).w
	bpl.w	.0
	clr.w	(replaydelay).w
	bra.w	.rec
.0
	addi.l	#$64,(recbpr).w
	cmpi.l	#replayend,(recbpr).w
	bne.w	.rec
	bset	#sfwrap,(sflags).w
	move.l	#M68K_RAM,(recbpr).w
.rec
	movea.l	(recbpr).w,a0
	moveq	#$F,d2
	movea.w	#(SortCords-M68K_RAM),a3
.top
	clr.l	(a0)
	move.w	(a3),d1
	andi.w	#$1FF,d1
	move.w	d1,2(a0)
	clr.l	d1
	move.w	Ypos(a3),d1
	asl.w	#6,d1
	asl.l	#3,d1
	or.l	d1,(a0)
	move.w	frame(a3),d1
	asl.w	#3,d1
	or.w	d1,(a0)
	move.w	attribute(a3),d1
	andi.w	#$1800,d1
	asl.w	#3,d1
	or.w	d1,(a0)
	addq.w	#4,a0
	adda.w	#$80,a3
	dbf	d2,.top
	moveq	#5,d2
	movea.w	#(SortCords-M68K_RAM),a3
.loop
	move.b	$70(a3),(a0)+
	move.w	position(a3),d0
	bpl.w	.n0
	moveq	#$F,d0
.n0
	andi.w	#$F,d0
	move.b	d0,(a0)
	adda.w	#$80,a3
	move.b	$70(a3),d0
	asl.w	#4,d0
	or.b	d0,(a0)+
	move.b	$70(a3),d0
	lsr.b	#4,d0
	move.b	d0,(a0)
	move.w	position(a3),d0
	bpl.w	.n1
	moveq	#$F,d0
.n1
	asl.w	#4,d0
	or.b	d0,(a0)+
	adda.w	#$80,a3
	dbf	d2,.loop
	move.b	(puckz+1).w,(a0)+
	move.b	(SortCords+$F*SCstruct+Zpos+1).w,(a0)+
	move.b	(lastsfx+1).w,(a0)+
	bset	#7,(lastsfx+1).w
	move.b	d7,(a0)+
	move.w	(PadControlBits+2).w,(a0)+
	move.w	(Crowdframe).w,(a0)+
	move.w	(glovecords).w,(a0)+
	move.w	(glovecords+2).w,(a0)+
	move.b	(PBnum).w,(a0)+
	move.w	d0,-(sp)
	move.w	(PadControlBits).w,d0
	move.b	d0,(a0)+
	move.w	(sp)+,d0
	move.w	(Hpos).w,(a0)+
	move.w	(Vpos).w,(a0)+

rtss8								;The shared rts of updatereplay; other routines branch to it
	rts

