;	Menu lists. PrintMenuList and PrintMenuList2 draw the shown rows of a menu, with the scroll marks.

PrintMenuList	;Print the shown rows of the menu list (menulist) with the scroll marks.
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$FF,$FE,$26,$78,$D0,$02,$28,$4B,$D8,$D4,$42,$47,$20,$78
	dc.b	$D0,$02,$D0,$D0,$D0,$D0,$4A,$68,$00,$02,$6B,$00,$00,$0A,$52,$47
	dc.b	$D0,$D0,$58,$48,$60,$F0,$30,$38,$CF,$FE,$6A,$00,$00,$08,$42,$78
	dc.b	$CF,$FE,$42,$40,$B0,$47,$6D,$00,$00,$0A,$30,$07,$53,$40,$31,$C0
	dc.b	$CF,$FE,$32,$38,$D0,$00,$D2,$78,$D0,$0A,$B2,$78,$CF,$FE,$6E,$00
	dc.b	$00,$08,$52,$78,$D0,$00,$60,$EA,$32,$38,$D0,$00,$B2,$78,$CF,$FE
	dc.b	$6F,$00,$00,$08,$53,$78,$D0,$00,$60,$EE,$30,$38,$D0,$00,$20,$78
	dc.b	$D0,$02,$D0,$D0,$D0,$D0,$30,$38,$D0,$00,$60,$00,$00,$06,$D0,$D0
	dc.b	$58,$48,$51,$C8,$FF,$FA,$31,$F8,$B0,$3C,$B0,$40,$31,$F8,$B0,$3E
	dc.b	$B0,$42,$30,$38,$D0,$0A,$B0,$47,$6F,$00,$00,$04,$30,$07,$42,$41
	dc.b	$60,$00,$00,$3C,$34,$01,$D4,$78,$D0,$00,$22,$4B,$B4,$78,$CF,$FE
	dc.b	$66,$00,$00,$0E,$22,$4C,$2F,$08,$D0,$D0,$21,$D0,$D0,$0C,$20,$5F
	dc.b	$4E,$B9,$00,$01,$BA,$40,$22,$48,$4E,$B9,$00,$01,$BA,$40,$31,$F8
	dc.b	$B0,$3C,$B0,$40,$52,$78,$B0,$42,$D0,$D0,$58,$48,$52,$41,$51,$C8
	dc.b	$FF,$C4,$30,$38,$B0,$3C,$55,$40,$31,$C0,$B0,$40,$31,$F8,$B0,$3E
	dc.b	$B0,$42,$22,$7C,$00,$01,$45,$48,$4A,$78,$D0,$00,$67,$00,$00,$08
	dc.b	$22,$7C,$00,$01,$45,$4E,$4E,$B9,$00,$01,$BA,$40,$30,$38,$B0,$3C
	dc.b	$55,$40,$31,$C0,$B0,$40,$30,$38,$B0,$3E,$D0,$78,$D0,$0A,$53,$40
	dc.b	$31,$C0,$B0,$42,$22,$7C,$00,$01,$45,$48,$30,$38,$D0,$00,$D0,$78
	dc.b	$D0,$0A,$B0,$47,$6C,$00,$00,$08,$22,$7C,$00,$01,$45,$54,$4E,$B9
	dc.b	$00,$01,$BA,$40,$4C,$DF,$7F,$FF,$4E,$75

ScrollClearTxt	;Scroll marks for PrintMenuList
	String	$F9,$00,$20
ScrollUpTxt
	String	$F9,$00,$7B
ScrollDownTxt
	String	$F9,$00,$7D

PrintMenuList2	;Print the shown rows of the menu list (menulist): each item through its routine, the selected item
	;with the highlight
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
	String	$F9,$00,$20
	String	$F9,$00,$7B
	String	$F9,$00,$7D

