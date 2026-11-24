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
	;loop
.loop2
	move.w	(Vcount).w,d0			;wait until d7 frames have passed
	sub.w	(OldVcount).w,d0		;frames since the last
	cmp.w	d0,d7					;enough?
	bhi.s	.loop2
	move.w	(Vcount).w,(OldVcount).w	;new frame count
	tst.w	(OptPad+2).w			;icon showing?
	bmi.w	.1
	sub.w	d7,(OptPad+2).w
	bpl.w	.1
	clr.w	(OptPad+2).w
	jsr	(EraseReplayIcon).l
	;icon timer handled
.1
	movem.l	d0/a3,-(sp)
	movea.l	#SortCords+(12*SCstruct),a3
	move.w	#1,oldframe(a3)
	movea.l	#SortCords+(13*SCstruct),a3
	move.w	#1,oldframe(a3)
	movem.l	(sp)+,d0/a3
	moveq	#1,d7					;1 frame
	bsr.w	ReadMenuJoy				;read the paused pad
	btst	#0,(sflags5).w			;slow mode?
	beq.w	.2
	andi.w	#$FFF0,d0				;direction bits only
	ori.w	#8,d0					;no direction
	andi.w	#$FFF0,d1
	andi.w	#$FFF0,d3
	;positions rounded in slow mode
.2
	movea.w	#$BE56,a5
	btst	#5,(sflags3).w			;tracking an object?
	beq.w	.3
	move.w	d1,d5
	andi.w	#$F,d5					;new d-pad press?
	beq.w	.12
	;not tracking, or a new d-pad press: manual camera
.3
	btst	#3,d0					;no direction?
	bne.w	.12
	cmpi.w	#$FF60,(a5)				;X past the left?
	bgt.w	.4
	move.w	#0,(a5)					;centre
	bra.w	.4
.4
	cmpi.w	#$FEB0,$14(a5)
	bgt.w	.5
	move.w	#0,$14(a5)				;centre
	;Y inside the rink
.5
	bset	#sfscrl,(sflags).w		;manual scrolling is on
	bne.w	.6						;scrolling?
	move.w	(Hpos).w,(a5)			;first frame: camera starts at the screen
	move.w	(Vpos).w,$14(a5)
	;camera on manual
.6
	move.w	d0,d5					;d5 = d-pad direction
	andi.w	#7,d5					;direction
	eori.w	#4,d5					;opposite
	movea.w	#(SortCords-M68K_RAM),a1
	st	d3							;no object to skip
	bclr	#5,(sflags3).w
	beq.w	.7						;was not tracking
	move.w	$16(a5),d3				;skip the object tracked now
	;search start, skipping the tracked object
.7
	move.w	(a5),d0					;camera position d0/d1: search 12 players
	move.w	$14(a5),d1
	moveq	#$B,d2
	move.l	#$100,d4				;nearest distance squared so far
	movem.w	d0-d1,-(sp)				;save the camera position
	;each player
.loop3
	cmp.w	SCnum(a1),d3			;loop over the 12 players, skipping the tracked one
	beq.w	.8						;tracked object?
	movem.w	(sp),d0-d1				;camera position
	sub.w	(a1),d0
	sub.w	Ypos(a1),d1
	jsr	(vtoa).l					;direction to object
	btst	#3,d0					;no direction?
	bne.w	.8
	sub.w	d5,d0					;minus the pad direction
	addq.w	#1,d0
	andi.w	#7,d0
	cmp.w	#2,d0					;within 45 degrees?
	bhi.w	.8						;not within 45 degrees of the d-pad
	movem.w	(sp),d0-d1				;camera position
	sub.w	(a1),d0
	sub.w	Ypos(a1),d1
	muls.w	d0,d0
	muls.w	d1,d1
	add.l	d1,d0					;distance squared
	cmp.l	#$4,d0					;too close?
	bls.w	.8						;too close
	cmp.l	d4,d0					;closer?
	bhi.w	.8
	move.l	d0,d4					;closest so far
	move.w	SCnum(a1),$16(a5)
	bset	#5,(sflags3).w
	;next player
.8
	adda.w	#SCstruct,a1
	dbf	d2,.loop3					;loop
	addq.w	#4,sp					;drop the camera position
	btst	#5,(sflags3).w			;tracking?
	beq.w	.9						;nothing found: scroll by hand
	move.w	$16(a5),d0
	asl.w	#7,d0					;* SCstruct
	movea.w	#(SortCords-M68K_RAM),a3
	adda.w	d0,a3
	moveq	#4,d4					;4 pads
	bsr.w	setpads					;set the pads
	bsr.w	UpdateCameraPos
	jsr	(setvideo).l
	bra.w	.loop2
	;sf3track clear
.9
	bset	#sfscrl,(sflags).w		;no object found: scroll the camera by hand
	eori.w	#4,d5					;opposite
	asl.w	#2,d5
	lea	.table(pc),a0
	move.w	(a0,d5.w),d0
	add.w	(a5),d0					;plus the camera X
	cmp.w	#$96,d0
	bgt.w	.10
	cmp.w	#$FF6A,d0
	blt.w	.10
	move.w	d0,(a5)
	;X step taken (or out of range)
.10
	move.w	2(a0,d5.w),d1
	add.w	$14(a5),d1				;plus the camera Y
	cmp.w	#$13C,d1
	bgt.w	.11
	cmp.w	#$FEC4,d1
	blt.w	.11
	move.w	d1,$14(a5)
	;Y step taken (or out of range)
.11
	movea.w	a5,a3					;camera struct is the object to follow
	clr.w	$18(a5)					;camera moving
	andi.l	#$FFFFF,(PadControlBits).w
	ori.l	#$E00000,(PadControlBits).w
	bsr.w	UpdateCameraPos			;camera position
	jsr	(setvideo).l
	bra.w	.loop2
.table
	dc.w	$0000,$0002,$0002,$0002,$0002,$0000,$0002,$FFFE
	dc.w	$0000,$FFFE,$FFFE,$FFFE,$FFFE,$0000,$FFFE,$0002
	;d5 = 0 or bit 3 of d0 set
.12
	st	$18(a5)
	btst	#5,d1					;C?
	beq.w	.13
	btst	#0,(sflags5).w			;slow mode?
	bne.w	.13
	bchg	#sf3rmplay,(sflags3).w
	;C toggles play mode (not in slow mode)
.13
	btst	#6,d3					;A held?
	beq.w	.14
	btst	#0,(sflags5).w			;slow mode?
	bne.w	.14
	bsr.w	suba4					;fast rewind
	bsr.w	suba4					;back a frame
	bsr.w	suba4					;back a frame
	bsr.w	suba4					;back a frame
	jsr	(SprSort).l
	jsr	(setvideo).l
	moveq	#1,d7					;1 frame
	bclr	#sf3rmplay,(sflags3).w	;turn off play mode
	;A: back a frame, unless slow mode
.14
	btst	#0,(sflags5).w			;slow mode?
	bne.w	.16
	btst	#4,d3					;B held?
	beq.w	.16
	btst	#6,d3					;A too?
	beq.w	.15
	bclr	#5,(sflags3).w
	bclr	#sfscrl,(sflags).w		;a+b but = manual scroll off (hidden feature)
	move.l	d0,-(sp)
	move.l	(PadControlBits).w,d0
	andi.l	#$FFFFF,d0
	ori.l	#$E00000,d0
	move.l	d0,(PadControlBits).w
	move.l	(sp)+,d0
	bra.w	.loop2
	;bit 6 of d3 clear
.15
	bsr.w	suba4ToggleReplayView	;forward a frame
	jsr	(SprSort).l
	jsr	(setvideo).l
	asl.w	#1,d7					;double delay time between frames = 1/2 speed slow motion
	bclr	#sf3rmplay,(sflags3).w	;turn off play mode
	;B: forward at half speed, unless slow mode
.16
	btst	#sf3rmplay,(sflags3).w	;play mode on?
	beq.w	.17
	st	(lastsfx).w					;play mode is on = advance one frame at original speed
	bsr.w	suba4ToggleReplayView	;forward a frame
	move.w	(lastsfx).w,-(sp)		;play sound effects
	jsr	(sfx).l
	jsr	(SprSort).l
	;frame advanced or not, redraw
.17
	jsr	(setvideo).l
	btst	#0,(sflags5).w			;slow mode?
	bne.w	.18
	btst	#7,d1					;start?
	beq.w	.loop2
	jsr	(ShowReplayBanner).l
	bclr	#sf3rmplay,(sflags3).w
	bset	#0,(sflags5).w			;slow mode
	bne.w	.18
	bra.w	.loop2
	;bit 0 of sflags5 set or 0 was set
.18
	btst	#7,d1					;start?
	bne.w	.20
	btst	#6,d1					;A?
	bne.w	.19
	btst	#4,d1					;B?
	bne.w	.21
	btst	#5,d1					;C?
	beq.w	.loop2
	bset	#6,(sflags4).w			;reverse angle change
	bclr	#0,(sflags5).w			;not slow mode
	jsr	(EraseReplayBanner).l
	bsr.w	suba4ToggleReplayView	;forward a frame
	jsr	(SprSort).l
	bra.w	.loop2
	;bit 6 of d1 set
.19
	jmp	(.loop2).l
	;bit 7 of d1 set
.20
	clr.w	(menuitem).w
	bset	#1,(sflags5).w			;back to the menu
	;leave the replay
.21
	bsr.w	forceblack				;screen off
	ori.l	#$F0000000,(PadControlBits).w
	bclr	#sfscrl,(sflags).w
	movea.l	(recbpr).w,a4			;back to the current frame
	bclr	#4,(sflags4).w			;normal angle
	bsr.w	RevReplayAdjFrames		;restore the frame
	jsr	(SprSort).l
	bclr	#sf2replay,(sflags2).w
	move.w	(sp)+,(disflags).w
	jsr	(ExitStatsScreenReload).l
	jsr	(setupEASNmap).l
	jsr	(LoadEnergyBarTiles).l
	jsr	(LoadCrowdFrames).l
	jsr	(LoadRefTiles).l
	move.w	#$FFFF,(PlayingSong).w
	move.w	#0,d0
	move.w	#$1B24,d1
	movea.l	#Z80Program,a0
	jsr	(SoundCmd).l
	move.w	#9,d0
	jsr	(SoundCmd).l
	move.w	#6,d0
	clr.w	d1
	movea.l	#SoundBanks,a0
	jsr	(SoundCmd).l
	move.w	#7,d0
	move.w	#0,d1
	jsr	(SoundCmd).l
	btst	#4,(disflags).w			;faceoff showing?
	beq.w	.22
	jsr	(LoadFaceOffMap).l
	jsr	(LoadFaceOffSprites).l
	;faceoff map reloaded when it was showing
.22
	jsr	(setvideo).l				;horizontal interrupt on
	move.w	#$18,(palcount).w
	rts

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
	jsr	(EraseReplayIcon).l
	st	(OptPad+2).w
	bsr.w	printz
	String	-(TXPRI+TXMAP1),2,0
	moveq	#0,d0
	moveq	#0,d1
	moveq	#$14,d2
	moveq	#8,d3
	move.w	(ExtraChars).w,d4
	move.w	#0,d5
	movea.l	#ReplayBannerMap,a1
	adda.l	4(a1),a1
	movea.w	#$772,a2
	bsr.w	dobitmap
	jsr	(printbigz1).l
	String	$F8,4,1,7,1,'options',$FD,7,$FA,2,'reverse angle'
	jsr	(printbigz2).l
	String	$FD,5,$FC,5,'start - to game'
	rts

EraseReplayBanner					;Erase the area ShowReplayBanner drew.
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),2,0
	move.w	#$14,d0
	move.w	#8,d1
	move.w	#$7FF,d2
	jmp	(eraser).l

suba4								;a4 = current replay frame. Back up 1 frame and set video parameters for
									;display.
	cmpa.l	#M68K_RAM,a4
	bne.w	.1
	btst	#sfwrap,(sflags).w
	beq.w	.2
	movea.l	#replayend,a4
.1
	suba.w	#$64,a4
	cmpa.l	(recbpr).w,a4
	bne.w	RevReplayAdjFrames
	adda.w	#$64,a4
.2
	bsr.w	RevReplayAdjFrames
	clr.w	d7
	rts
suba4ToggleReplayView	equ	*
	bclr	#6,(sflags4).w
	beq.w	.4
	movem.l	d0-d7/a0-a6,-(sp)
	bchg	#4,(sflags4).w
	move.w	(Hpos).w,-(sp)
	move.w	(Vpos).w,-(sp)
	bsr.w	forceblack2
	jsr	(vcountwait).l
	jsr	(vcountwait).l
	clr.w	(Hpos).w
	clr.w	(Vpos).w
	move.w	#$7D0,(Oldrow).w
	move.w	#1,d0
.loop
	jsr	(setvideo).l
	jsr	(vcountwait).l
	dbf	d0,.loop
	move.w	(sp)+,(Vpos).w
	move.w	(sp)+,(Hpos).w
	move.w	#1,d0
	jsr	(setvideo).l
.loop2
	jsr	(vcountwait).l
	dbf	d0,.loop2
	movem.l	a0,-(sp)
	movea.l	#SortCords+(12*SCstruct),a0
	move.w	#1,oldframe(a0)
	adda.w	#SCstruct,a0
	move.w	#1,oldframe(a0)
	movem.l	(sp)+,a0
	bsr.w	RevReplayAdj
	btst	#sfscrl,(sflags).w
	beq.w	.3
.3
	jsr	(ShowReplayIcon).l
	move.w	#$64,(palcount).w
	movem.l	(sp)+,d0-d7/a0-a6
.4
	clr.w	d7
	btst	#sf2drec,(sflags2).w
	beq.w	.5
	movem.l	a4,-(sp)
	bsr.w	AdvanceReplayRecord
	cmpa.l	(recbpr).w,a4
	movem.l	(sp)+,a4
	beq.w	rtss8
.5
	cmpa.l	(recbpr).w,a4
	beq.w	rtss8
	bsr.w	RevReplayAdjFrames
AdvanceReplayRecord					;Step a4 to the next $64 byte replay record and wrap from the end of the
									;buffer to AwardIds
	adda.w	#$64,a4
	cmpa.l	#$FFFFAF64,a4
	bne.w	rtss8
	movea.l	#AwardIds,a4
	rts

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
RevReplayAdjFrames	equ	*			;Reverse replay: adjust the frame offsets of the six skaters of record a4
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
	move.b	(a0)+,rostnum(a3)
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
	move.b	d0,rostnum(a3)
	move.b	(a0),d0
	asl.b	#4,d0					;low nibble up
	or.b	d0,rostnum(a3)
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
	move.b	rostnum(a3),(a0)+
	move.w	position(a3),d0
	bpl.w	.n0
	moveq	#$F,d0
.n0
	andi.w	#$F,d0
	move.b	d0,(a0)
	adda.w	#$80,a3
	move.b	rostnum(a3),d0
	asl.w	#4,d0
	or.b	d0,(a0)+
	move.b	rostnum(a3),d0
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

