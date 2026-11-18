;	Menu lists. PrintMenuList and PrintMenuList2 draw the shown rows of a menu, with the scroll marks.

PrintMenuList						;Print the shown rows of the menu list (menulist) with the scroll marks.
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	(menulist).w,a3
	movea.l	a3,a4
	adda.w	(a4),a4
	clr.w	d7
	movea.l	(menulist).w,a0
	adda.w	(a0),a0
	adda.w	(a0),a0
.loop
	tst.w	2(a0)
	bmi.w	.1
	addq.w	#1,d7
	adda.w	(a0),a0
	addq.w	#4,a0
	bra.s	.loop
.1
	move.w	(menuitem).w,d0
	bpl.w	.2
	clr.w	(menuitem).w
	clr.w	d0
.2
	cmp.w	d7,d0
	blt.w	.loop2
	move.w	d7,d0
	subq.w	#1,d0
	move.w	d0,(menuitem).w
.loop2
	move.w	(menuitem+2).w,d1
	add.w	(menurows).w,d1
	cmp.w	(menuitem).w,d1
	bgt.w	.loop3
	addq.w	#1,(menuitem+2).w
	bra.s	.loop2
.loop3
	move.w	(menuitem+2).w,d1
	cmp.w	(menuitem).w,d1
	ble.w	.3
	subq.w	#1,(menuitem+2).w
	bra.s	.loop3
.3
	move.w	(menuitem+2).w,d0
	movea.l	(menulist).w,a0
	adda.w	(a0),a0
	adda.w	(a0),a0
	move.w	(menuitem+2).w,d0
	bra.w	.4
.loop4
	adda.w	(a0),a0
	addq.w	#4,a0
.4
	dbf	d0,.loop4
	move.w	(menux).w,(printx).w
	move.w	(menuy).w,(printy).w
	move.w	(menurows).w,d0
	cmp.w	d7,d0
	ble.w	.5
	move.w	d7,d0
.5
	clr.w	d1
	bra.w	.7
.loop5
	move.w	d1,d2
	add.w	(menuitem+2).w,d2
	movea.l	a3,a1
	cmp.w	(menuitem).w,d2
	bne.w	.6
	movea.l	a4,a1
	move.l	a0,-(sp)
	adda.w	(a0),a0
	move.l	(a0),(menurows+2).w
	movea.l	(sp)+,a0
.6
	jsr	(printsmall).l
	movea.l	a0,a1
	jsr	(printsmall).l
	move.w	(menux).w,(printx).w
	addq.w	#1,(printy).w
	adda.w	(a0),a0
	addq.w	#4,a0
	addq.w	#1,d1
.7
	dbf	d0,.loop5
	move.w	(menux).w,d0
	subq.w	#2,d0
	move.w	d0,(printx).w
	move.w	(menuy).w,(printy).w
	movea.l	#ScrollClearTxt,a1
	tst.w	(menuitem+2).w
	beq.w	.8
	movea.l	#ScrollUpTxt,a1
.8
	jsr	(printsmall).l
	move.w	(menux).w,d0
	subq.w	#2,d0
	move.w	d0,(printx).w
	move.w	(menuy).w,d0
	add.w	(menurows).w,d0
	subq.w	#1,d0
	move.w	d0,(printy).w
	movea.l	#ScrollClearTxt,a1
	move.w	(menuitem+2).w,d0
	add.w	(menurows).w,d0
	cmp.w	d7,d0
	bge.w	.9
	movea.l	#ScrollDownTxt,a1
.9
	jsr	(printsmall).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

ScrollClearTxt						;Scroll marks for PrintMenuList
	String	CC_SetFont,$00,' '
ScrollUpTxt							;scroll up arrow text
	String	CC_SetFont,$00,'{'
ScrollDownTxt
	String	CC_SetFont,$00,'}'

PrintMenuList2						;Print the shown rows of the menu list (menulist): each item through its
									;routine, the selected item with the highlight
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	(menulist).w,a3
	movea.l	a3,a4
	adda.w	(a4),a4
	clr.w	d7
	movea.l	(menulist).w,a0
	adda.w	(a0),a0
	adda.w	(a0),a0
.0
	tst.l	(a0)
	bmi.w	.get
	addq.w	#1,d7
	addq.w	#4,a0
	bra.s	.0
.get
	move.w	(menuitem).w,d0
	bpl.w	.1
	clr.w	(menuitem).w
	clr.w	d0
.1
	cmp.w	d7,d0
	blt.w	.2
	move.w	d7,d0
	subq.w	#1,d0
	move.w	d0,(menuitem).w
.2
	move.w	(menuitem+2).w,d1
	add.w	(menurows).w,d1
	cmp.w	(menuitem).w,d1
	bgt.w	.3
	addq.w	#1,(menuitem+2).w
	bra.s	.2
.3
	move.w	(menuitem+2).w,d1
	cmp.w	(menuitem).w,d1
	ble.w	.4
	subq.w	#1,(menuitem+2).w
	bra.s	.3
.4
	move.w	(menuitem+2).w,d0
	movea.l	(menulist).w,a0
	adda.w	(a0),a0
	adda.w	(a0),a0
	move.w	(menuitem+2).w,d0
	bra.w	.6
.5
	addq.w	#4,a0
.6
	dbf	d0,.5
	move.w	(menux).w,(printx).w
	move.w	(menuy).w,(printy).w
	move.w	(menurows).w,d0
	cmp.w	d7,d0
	ble.w	.7
	move.w	d7,d0
.7
	clr.w	d1
	bra.w	.10
.8
	move.w	d1,d2
	add.w	(menuitem+2).w,d2
	movea.l	a3,a1
	cmp.w	(menuitem).w,d2
	bne.w	.9
	movea.l	a4,a1
.9
	jsr	(printsmall).l
	movem.l	d0-d1/a0,-(sp)
	movea.l	(a0),a0
	jsr	(a0)
	movem.l	(sp)+,d0-d1/a0
	jsr	(printsmall).l
	move.w	(menux).w,(printx).w
	addq.w	#2,(printy).w
	addq.w	#4,a0
	addq.w	#1,d1
.10
	dbf	d0,.8
	movem.l	(sp)+,d0-d7/a0-a6
	rts
	;The same scroll marks again; nothing reads them
	String	CC_SetFont,$00,$20
	String	CC_SetFont,$00,'{'
	String	CC_SetFont,$00,'}'

