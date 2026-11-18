;	CopyString.

CopyString							;Copy String a1 (length word first) to a3.
	movem.l	d0,-(sp)
	move.w	(a1),d0
	subq.w	#1,d0
.loop
	move.b	(a1)+,(a3)+
	dbf	d0,.loop
	movem.l	(sp)+,d0
	rts
	movem.w	d0-d6/a0,-(sp)
	move.l	a1,-(sp)				;keep the String start
	move.w	d0,d6
	addq.l	#2,a1					;leave room for the length word
	clr.w	d1
	ext.l	d0
	divu.w	#$64,d0					;hundreds digit
	tst.w	d0						;any hundreds?
	beq.w	.1						;no hundreds: no leading zero
	addi.w	#$30,d0
	move.b	d0,(a1)+
	addq.w	#1,d1
	;no hundreds digit, or it was written: now the tens
.1
	swap	d0
	ext.l	d0						;clear the high word
	divu.w	#$A,d0					;tens digit
	addi.w	#$30,d0
	cmp.b	#$30,d0					;tens 0 is skipped only for values below 10
	bne.w	.2
	cmp.w	#$A,d6					;below 10?
	blt.w	.3						;yes: no tens digit
	;tens digit wanted (non-zero, or a hundreds digit came before)
.2
	move.b	d0,(a1)+
	addq.w	#1,d1
	;value below 10, or the tens is written: now the ones
.3
	swap	d0						;ones digit from the remainder
	addi.w	#$30,d0
	move.b	d0,(a1)+
	addq.w	#1,d1
	btst	#0,d1					;odd length: pad with a 0 byte so the String stays word aligned
	beq.w	.4						;even already
	move.b	#0,(a1)+				;pad byte
	addq.w	#1,d1
	;length now even: write the length word
.4
	movea.l	(sp)+,a0
	addq.w	#2,d1					;length counts the 2-byte header
	move.w	d1,(a0)
	movem.w	(sp)+,d0-d6/a0
	rts

