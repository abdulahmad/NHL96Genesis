;	The demo and the pause menu. demoread reads a pad during a demo and can start the pause.
;	Pausemode draws the pause screen and runs the menu until it ends.

demoread	;In a demo (no pad on a team): start on a pad starts the pause, any other button ends the demo
	tst.w	(cont1team).w
	bne.w	rtsdemo
	tst.w	(cont2team).w
	bne.w	rtsdemo
	tst.w	(cont3team).w
	bne.w	rtsdemo
	tst.w	(cont4team).w
	bne.w	rtsdemo
	jsr	(ReadJoy1).l
	btst	#7,d1
	beq.w	.0
	jmp	startpause1
.0
	bsr.w	EndDemoOnPress
	jsr	(ReadJoy2).l
	btst	#7,d1
	beq.w	.1
	jmp	startpause2
.1
	tst.w	(FourWayPlay).w
	beq.w	EndDemoOnPress
	jsr	(ReadJoy3).l
	btst	#7,d1
	beq.w	.2
	jmp	startpause3
.2
	bsr.w	EndDemoOnPress
	jsr	(ReadJoy4).l
	btst	#7,d1
	beq.w	EndDemoOnPress
	jmp	startpause4

EndDemoOnPress	;A button d1 ends the demo: demoflag, then back to the title (ExitToOpening)
	tst.w	d1
	beq.w	rtsdemo
	st	(demoflag).w
	move.w	#$64,(setuphome).w
	move.w	#$64,(setupvis).w
	jmp	ExitToOpening

rtsdemo
	rts

startpause	;Pause on (sfpz)
	bset	#0,(sflags).w
	rts

startpause1	;Pause initiated by cont 1
	clr.w	(menupadnum).w
	bra.s	startpause

startpause2	;Pause initiated by cont 2
	move.w	#1,(menupadnum).w
	bra.s	startpause

startpause3	;Pause initiated by cont 3 (4 way play)
	move.w	#2,(menupadnum).w
	bra.s	startpause

startpause4	;Pause initiated by cont 4 (4 way play)
	move.w	#3,(menupadnum).w
	bra.s	startpause

Pausemode	;Game is in pause mode now: restart the sound driver, run the pause menu (HandleMenuInput) until it ends,
	;then restart the sound driver again
	jsr	(forceblack).l
	move.w	d0,-(sp)
	move.w	(vcount).w,d0
.loop
	cmp.w	(vcount).w,d0
	beq.s	.loop
	move.w	(sp)+,d0
	jsr	(SoundOff).l
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
	move.w	#0,d1
	jsr	(SoundCmd).l
	move.w	(sflags).w,-(sp)
	bsr.w	seta2
	jsr	(SetMenuPadSide).l
	movea.l	#PauseMenu,a0
	lea	SetupPauseScreen(pc),a1
	btst	#0,(gmode2).w
	beq.w	.0
	movea.l	#ShootoutPauseMenu,a0
	bra.w	.1
.0
	btst	#2,$30(a2)
	beq.w	.1
	movea.l	#PauseMenuNoTimeout,a0
.1
	bsr.w	InitMenuState
.2
	bsr.w	vcountwait
	bsr.w	ReadMenuJoy
	jsr	(ProcessInputWithRepeat).l
	bsr.w	HandleMenuInput
	bne.s	.2
	jsr	(forceblack).l
	move.w	(sp)+,(sflags).w
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
	jmp	ReturnToGame
	;After Pausemode: code that nothing in the listing reaches.
	;Code the listing does not decode: kept as bytes
	dc.b	$4E,$B9,$00,$01,$D0,$1E,$4E,$B9,$00,$08,$85,$FC,$30,$3C,$00,$09
	dc.b	$4E,$B9,$00,$08,$83,$9E,$30,$3C,$00,$00,$32,$3C,$1B,$24,$20,$7C
	dc.b	$00,$02,$55,$00,$4E,$B9,$00,$08,$83,$9E,$30,$3C,$00,$06,$42,$41
	dc.b	$20,$7C,$00,$02,$70,$26,$4E,$B9,$00,$08,$83,$9E,$30,$3C,$00,$07
	dc.b	$32,$3C,$00,$01,$4E,$B9,$00,$08,$83,$9E,$20,$7C,$00,$C0,$00,$00
	dc.b	$31,$7C,$91,$00,$00,$04,$31,$7C,$92,$00,$00,$04,$08,$F8,$00,$03
	dc.b	$BF,$B2,$08,$B8,$00,$00,$C3,$3A,$4E,$B9,$00,$01,$D0,$62,$4E,$B9
	dc.b	$00,$02,$03,$4A,$31,$FC,$00,$18,$BD,$3C,$4A,$78,$BD,$3C,$6A,$FA
	dc.b	$31,$F8,$B0,$52,$B0,$54,$4E,$75

SetupPauseScreen	;Draw routine for the pause menu: the pause screen, then KillCrowd.
	;Code the listing does not decode: kept as bytes
	dc.b	$4E,$B9,$00,$1E,$29,$70,$4E,$B9,$00,$02,$0E,$28

seta2	;Set a2 to the team struct of the pause pad (menupadnum: cont1team ... cont4team)
	movea.l	#tmstruct,a2
	tst.w	(menupadnum).w
	beq.w	.seta20
	cmpi.w	#1,(menupadnum).w
	beq.w	.1
	cmpi.w	#2,(menupadnum).w
	beq.w	.0
	cmpi.w	#1,(cont4team).w
	bra.w	.seta21
.0
	cmpi.w	#1,(cont3team).w
	bra.w	.seta21
.1
	cmpi.w	#1,(cont2team).w
	bra.w	.seta21
.seta20
	cmpi.w	#1,(cont1team).w
.seta21
	beq.w	.x
	adda.w	#$39E,a2
.x
	rts

InitMenuState	;Start a menu: a0 = item list, a1 = screen draw routine; selection and first shown item 0. Falls into
	;DrawMenuScreen
	move.l	a0,(menulist).w
	move.l	a1,(menudraw).w
	clr.w	(menuitem).w
	clr.w	(menuitem+2).w

DrawMenuScreen	;Call the draw routine, print the items (UpdateMenuSelection), palcount $18
	movea.l	(menudraw).w,a0
	jsr	(a0)
	bsr.w	UpdateMenuSelection
	move.w	#$18,(palcount).w
	rts

SetMenuPrintX	;printx = 5, 9 with disflags bit 1 clear
	move.w	#5,(printx).w
	btst	#1,(disflags).w
	bne.w	rtss8
	addq.w	#4,(printx).w
	rts

HandleMenuInput	;Pause menu pad d1: up / down move the selection, C runs the item handler; start returns with the
	;zero flag set to end the menu
	btst	#7,d1
	bne.w	.2
	btst	#1,d1
	beq.w	.up
	addq.w	#1,(menuitem).w
	bra.w	UpdateMenuSelection
.up
	btst	#0,d1
	beq.w	.sel
	subq.w	#1,(menuitem).w
	bra.w	UpdateMenuSelection
.sel
	btst	#5,d1
	beq.w	.2
	bsr.w	seta2
	move.w	(menuitem).w,d0
	movea.l	(menulist).w,a0
	adda.w	(a0),a0
	adda.w	(a0),a0
	bra.w	.9
.next
	addq.w	#4,a0
.9
	adda.w	(a0),a0
	dbf	d0,.next
	movea.l	(a0),a0
	move.l	a0,-(sp)
	bset	#4,(sflags12).w
	jsr	(a0)
	bclr	#4,(sflags12).w
	movea.l	(sp)+,a0
	bclr	#1,(sflags5).w
	bne.w	.1
	cmpa.l	#TimeoutMenu,a0
	beq.w	.0
	cmpa.l	#SelectGoalieMenu,a0
	beq.w	.0
	cmpa.l	#ManualGoalieMenu,a0
	bne.w	.11
.0
	bsr.w	UpdateMenuSelection
	bra.w	.1
.11
	bsr.w	DrawMenuScreen
.1
	tst.w	(menuitem).w
	rts
.2
	eori	#4,ccr
	rts

UpdateMenuSelection	;Clamp menuitem to the list, scroll menuitem+2 to show it, and print the shown items
	jsr	(printsmallz).l
	String	$FE,$04
	move.w	(menuitem).w,d0
	bpl.w	.1
	clr.w	(menuitem).w
	clr.w	d0
.1
	movea.l	(menulist).w,a0
	adda.w	(a0),a0
	adda.w	(a0),a0
	bra.w	.3
.next
	adda.w	(a0),a0
	addq.w	#4,a0
	tst.w	2(a0)
.3
	dbmi	d0,.next
	addq.w	#1,d0
	sub.w	d0,(menuitem).w
	move.w	(menuitem).w,d0
	cmp.w	(menuitem+2).w,d0
	bge.w	.4
	move.w	d0,(menuitem+2).w
.4
	subq.w	#7,d0
	cmp.w	(menuitem+2).w,d0
	ble.w	.0
	move.w	d0,(menuitem+2).w
.0
	bsr.w	SetMenuPrintX
	move.w	#6,(printy).w
	movea.l	(menulist).w,a1
	jsr	(printbigcur).l
	adda.w	(a1),a1
	move.w	(menuitem+2).w,d0
	bra.w	.7
.skip
	adda.w	(a1),a1
	addq.w	#4,a1
.7
	dbf	d0,.skip
	moveq	#7,d1
	move.w	#4,(printy).w
	bsr.w	SetMenuPrintX
	jsr	(printsmallz).l
	String	$FB,$01,$FA,$02,$20,$FB,$12,$20,$FA,$FE,$FB,$EB
	move.w	(menuitem+2).w,d0
	beq.w	.2
	jsr	(printsmallz).l
	String	$FE,$07,$FB,$01,$FA,$02,$7B,$FB,$12,$7B,$FA,$FE,$FE,$04
.2
	bsr.w	SetMenuPrintX
	jsr	(printsmallz).l
	String	$FB,$02,$FA,$02
	move.l	a1,-(sp)
	movea.l	(menulist).w,a1
	jsr	(printbigcur).l
	cmp.w	(menuitem).w,d0
	bne.w	.nosel
	jsr	(printbigcur).l
.nosel
	movea.l	(sp)+,a1
	bsr.w	PrintMenuItem
	addq.w	#1,d0
	addq.w	#4,a1
	tst.w	2(a1)
	dbmi	d1,.2
	bmi.w	.5
	bsr.w	SetMenuPrintX
	jsr	(printsmallz).l
	String	$FE,$07,$FB,$01,$FC,$14,$7D,$FB,$12,$7D,$FE,$04
	rts
.5
	bsr.w	SetMenuPrintX
	jsr	(printsmallz).l
	String	$FB,$01,$FC,$14,$20,$FB,$12,$20
	rts

PrintMenuItem	;printsmall item String a1; an item that starts with x prints MANUAL GOALIE or AUTO GOALIE
	;(goaliemode1 / goaliemode2 by the pause pad)
	cmpi.b	#$78,2(a1)
	bne.w	.0
	move.l	a1,-(sp)
	movea.l	#.11,a1
	btst	#1,(sflags).w
	beq.w	.13
	tst.w	(goaliemode2).w
	bra.w	.chkgoalie
.13
	tst.w	(goaliemode1).w
.chkgoalie
	beq.w	.print
	movea.l	#.12,a1
.print
	jsr	(printbigcur).l
	movea.l	(sp)+,a1
	adda.w	(a1),a1
	bra.w	.1
.0
	jsr	(printbigcur).l
.1
	rts
.11
	String	'  MANUAL GOALIE   '
.12
	String	'   AUTO GOALIE    '

vcountwait	;Wait for the next vblank
	move.w	d0,-(sp)
	move.w	(oldvcount).w,d0
	move.w	(oldvcount).w,d0
.wait
	cmp.w	(vcount).w,d0
	beq.s	.wait
	move.w	(oldvcount).w,(vcount).w
	move.w	(sp)+,d0
	rts

