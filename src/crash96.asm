;	The exception screen. Address error, illegal instruction and divide by zero
;	print the pc and hang.

AdrErr	;Vector 3: "Address Error", the access address and the pc (crash)
	move	#$2700,sr
	jsr	(printcurz).l
	String	$BD,$00,$00,'Address Error'
	move.l	$A(sp),d0
	move.l	2(sp),d1
	bra.w	crash

InvOpCode	;Vector 4: "Illegal Instruction" and the pc (crash)
	move	#$2700,sr
	bsr.w	printcurz
	String	$BD,$00,$00,'Illegal Instruction'
	move.l	2(sp),d0
	move.l	d0,d1
	bra.w	crash

DivBy0	;Vector 5: "Division by zero" and the pc, falls into crash
	move	#$2700,sr
	bsr.w	printcurz
	String	$BD,$00,$00,'Division by zero'
	move.l	2(sp),d0
	move.l	d0,d1

crash	;Print d1 then d0 as hex, set the vdp up, copy 8 longs from the Rinktilelist palette + $20 to cram $20 and
	;hang. Branched to from AdrErr and InvOpCode, falls in from DivBy0
	movea.w	#(mesarea-M68K_RAM),a0
	move.w	#$18,(a0)+
	move.b	#$BD,(a0)+
	move.b	#0,(a0)+
.0
	move.b	#2,(a0)+
	move.l	d1,-(sp)
.1
	bsr.w	.ri
	move.b	#$BD,(a0)+
	move.b	#0,(a0)+
	move.b	#4,(a0)+
	move.l	(sp)+,d0
.2
	bsr.w	.ri
	movea.w	#(mesarea-M68K_RAM),a1
.3
	jsr	(printcur).l
	movea.l	#Vdata,a0
.4
	move.w	#$9100,4(a0)
	move.w	#$9206,4(a0)
	move.w	#$8F02,4(a0)
	move.l	#$C0200000,4(a0)
	movea.l	#Rinktilelist,a1
	adda.l	(a1),a1
.5
	adda.w	#$20,a1
	moveq	#7,d0
.6
	move.l	(a1)+,(a0)
	dbf	d0,.6
.7
	bra.w	.7
.ri
	moveq	#7,d2
.8
	rol.l	#4,d0
	move.w	d0,d1
	andi.w	#$F,d1
	addi.w	#$30,d1
	cmp.w	#$39,d1
	ble.w	.9
	addq.w	#7,d1
.9
	move.b	d1,(a0)+
	dbf	d2,.8
	rts
