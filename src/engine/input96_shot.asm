;	The shot and the pass. shotdiradj aims the shot, SetShotMode and ShotMode wind up, and
;	doshot releases it. setpassmode, dopass and passtoa0 send the puck to a teammate.

shotdiradj	;Adjust the shot direction by the pad and the shooter
	btst	#3,pflags3(a3)	;check if shooting one timer
	bne.w	.0	;jump if shooting one timer
	btst	#3,pflags(a3)
	bne.w	.2
.0
	moveq	#8,d0
	moveq	#5,d1
	movea.w	#(SortCords-SCstruct-M68K_RAM),a0	;SC Struct start - 80
	btst	#6,pflags(a3)
	bne.w	.g
	adda.w	#$300,a0
.g
	adda.w	#$80,a0
	tst.w	position(a0)
	dbeq	d1,.g
	bne.w	.setpassdir
	move.b	Xvel(a0),d0
	ext.w	d0	;sign extend d0
	asr.w	#1,d0	;divide by 2
	add.w	(a0),d0	;Xpos
	sub.w	(puckx).w,d0	;sub puckx from d0
	move.b	Yvel(a0),d1
	ext.w	d1	;sign extend d1
	asr.w	#1,d1	;divide by 2
	add.w	Ypos(a0),d1
	sub.w	(pucky).w,d1	;sub pucky from d1
	movem.w	d0-d1,-(sp)	;push to stack
	muls.w	d0,d0	;square d0
	muls.w	d1,d1	;square d1
	add.l	d1,d0	;add d1 to d0
	addq.l	#1,d0	;add 1 to d0
	jsr	(sroot).l
	move.w	d0,d2	;move result into d2
	movem.w	(sp)+,d0-d1	;pop from stack (distance x and y from G to puck)
	moveq	#$12,d3	;post?
	move.w	#$11E,d4
	btst	#7,pflags(a3)
	bne.w	.chkposts
	neg.w	d4	;negate if bottom goal
.chkposts
	movem.w	d3-d4,-(sp)	;push to stack
	bsr.w	shotdirmath
	move.w	d4,d5
	movem.w	(sp)+,d3-d4	;pop from stack
	neg.w	d3	;negate d3 (other post)
	bsr.w	shotdirmath
	add.w	d5,d4	;add results to d4
	clr.w	d0	;clear d0
	cmp.w	#$2C,d4	;2C - right X edge of crease
	bgt.w	.setpassdir
	cmp.w	#$FFD4,d4	;-$2C, the left X edge of the crease
	blt.w	.setpassdir
	btst	#7,pflags(a3)
	beq.w	.passdir
	neg.w	d4	;negate d4
.passdir
	moveq	#2,d0	;move 2 into d0
	tst.w	d4	;check if d4 is 0
	bpl.w	.setpassdir
	moveq	#6,d0	;move 6 into d0
.setpassdir
	move.w	d0,(passdir).w	;will be 0,2,6, or 8 (no goalie)
	btst	#2,(BA_PS_flags).w
	bne.w	.1
	btst	#0,(gmode2).w	;check if shootout
	beq.w	.2
.1
	jsr	(PSandSOpassdir).l
.2
	rts

shotdirmath
	sub.w	(puckx).w,d3
	sub.w	(pucky).w,d4
	muls.w	d0,d4
	muls.w	d1,d3
	sub.l	d3,d4
	divs.w	d2,d4
	rts
	;Not decoded in the listing and not referenced from it: kept as bytes
	dc.b	$58,$4F,$30,$38,$B7,$72,$08,$2B,$00,$07,$00,$62,$66,$00,$00,$04
	dc.b	$44,$40,$32,$3C,$01,$1E,$92,$40,$E6,$49,$B2,$7C,$00,$14,$6D,$00
	dc.b	$00,$04,$72,$14,$37,$41,$00,$42,$70,$12,$4E,$F9,$00,$01,$A3,$DA

SetShotMode	;Start the shot mode (C button)
	btst	#2,(BA_PS_flags).w	;check for PS or SO
	beq.w	.0
	btst	#0,(GameFlags).w
	bne.w	.0
	bclr	#2,(gmode2).w
	bset	#5,(BA_PS_flags).w
	bne.w	rtss7
	bclr	#5,(gmode2).w
	move.w	#$64,(passmodetimer).w
.0
	move.w	#8,(passdir).w	;default shot direction
	bset	#3,(sflags).w
	clr.w	d0	;find dx/dy for shot
	move.w	#$13A,d1	;#296 = top Y boards
	btst	#7,pflags(a3)
	bne.w	.ck0
	neg.w	d1	;flip if bottom goal
.ck0
	sub.w	(a3),d0	;Sub Xpos of player from d0. d0 starts as 0 (middle of rink in X)
	sub.w	Ypos(a3),d1	;Sub Ypos of player from Y boards
	jsr	(vtoa).l
	move.w	#$F,(passspeed).w
	move.w	#$11BA,d1
	btst	#0,(GameFlags).w
	beq.w	.13
	move.w	#$2E40,d1
.13
	jsr	(sub_16D36).l
	beq.w	.4
	move.w	#$FB6,d1
	btst	#0,(GameFlags).w
	beq.w	.3
	move.w	#$2F72,d1
.3
	move.w	#$F,(passspeed).w
.4
	jmp	SetSPA

ShotMode	;Shot mode: wind up, then doshot
	cmpi.w	#$1C,SPAnum(a3)
	bge.w	prepshot	;end of animation so shoot
	btst	#3,d0	;checks dpad for direction
	bne.w	.ss0
	andi.w	#7,d0	;pass the first 3 bits of d0
	move.w	d0,(passdir).w	;set shot direction
.ss0
	cmpi.w	#$10,SPAnum(a3)
	bge.w	.end
	add.w	d7,(passspeed).w
	cmpi.w	#$C,SPAnum(a3)
	bne.w	.checkcbut
	addq.w	#1,(passspeed).w
.checkcbut
	btst	#5,d2	;5 = #cbut
	beq.w	.end
	neg.w	SPAnum(a3)	;end windup and swing through
	addi.w	#$1C,SPAnum(a3)
.end
	rts

prepshot
	bclr	#4,(sflags5).w
	move.w	#$B,d0
	btst	#6,pflags(a3)
	beq.w	.33
	move.w	#5,d0	;opponent is home
.33
	jsr	(FindGoalie).l
	tst.w	d0
	bmi.w	.nogoalie
	movem.l	a0,-(sp)
	asl.w	#7,d0
	movea.l	#SortCords,a0
	cmpi.w	#$440,SPA(a0,d0.w)
	beq.w	.0
	cmpi.w	#$3E6,SPA(a0,d0.w)
.0
	movem.l	(sp)+,a0
	bne.w	.3
.nogoalie
	cmpi.w	#1,(passdir).w
	ble.w	.dir017
	cmpi.w	#7,(passdir).w
	bne.w	.3
.dir017
	move.w	(pucky).w,d0
	btst	#7,pflags(a3)
	bne.w	.cmppuck
	neg.w	d0	;flips d0 for compare calc
.cmppuck
	cmp.w	#$D8,d0	;compares location of puck
	blt.w	.3
	bset	#4,(sflags5).w	;set flag for in-close top shelf shooting
.3
	bra.w	*+4

doshot	;Shoot the puck
	movem.l	d0-d7/a0-a3,-(sp)
	bclr	#0,(GameFlags).w
	beq.w	.0
	bclr	#3,(sflags).w
	bra.w	.4
.0
	move.b	pflags(a3),(byte_FFC364).w
	bclr	#4,(gmode2).w
	btst	#1,pflags3(a3)	;check if player on breakaway
	beq.w	.cont
	bset	#4,(gmode2).w	;set if breakaway
.cont
	bsr.w	shotdiradj
	move.w	#5,-(sp)	;#SFXshotwiff - sound effect
	move.w	SCnum(a3),(shotplayer).w
	bclr	#3,(sflags).w
	bset	#5,pflags(a3)
	btst	#3,pflags3(a3)	;check if shooting one timer
	bne.w	.2
	move.w	(puckc).w,d0	;puck carrier SCnum into d0
	cmp.w	SCnum(a3),d0	;is player puck carrier?
	bne.w	.3
.2
	move.w	#$18,(sp)	;#SFXshotfh
	bset	#4,(sflags2).w
	cmpi.w	#$FB6,SPA(a3)
	bne.w	.nbh
	move.w	#$14,(sp)	;#SFXshotbh
	move.w	(passspeed).w,d0
	lsr.w	#2,d0	;sub 25% for backhand shots
	sub.w	d0,(passspeed).w
.nbh
	btst	#3,pflags3(a3)	;check if shooting one timer
	beq.w	.cont2
	movem.l	d0-d1,-(sp)	;push d0-d1 on stack
	move.w	#$1F,d0	;1F into d0 - one timer min speed
	move.w	d0,(passspeed).w	;make passspeed start with a higher value
	movem.l	(sp)+,d0-d1	;Pop off stack d0-d1
.cont2
	clr.w	d0
	move.b	$6D(a3),d0
	lsr.b	#1,d0	;divide by 2
	movea.l	a3,a0	;move a3 address into a0
	jsr	(makepde).l	;scale d0 based on energy level
	addi.w	#$14,d0	;add 14 to d0
	mulu.w	(passspeed).w,d0	;shot speed ranged by energy level
	mulu.w	#$5249,d0
	swap	d0	;swaps the upper and lower words of d0
	move.w	d0,(passspeed).w	;move d0 into passspeed
	btst	#0,$6D(a3)
	beq.w	.even
	asr.w	#4,d0	;divide by 16
	add.w	(passspeed).w,d0	;add passspeed to d0
.even
	lsr.w	#4,d0	;divide by 16 (d0 is passspeed)
	neg.w	d0	;negative
	addq.w	#3,d0	;add 3 to d0
	bpl.w	.nbh2
	clr.w	d0	;clear if negative
.nbh2
	add.w	d0,(sp)	;add to stack current value (Shot SFX)
	st	(puckc).w	;clear puck carrier
	move.b	#$10,nopuck(a3)	;5E = nopuck - no puck collision till 0
	move.w	SCnum(a3),(lastplayer).w
	move.w	#$11E,d1
	btst	#7,pflags(a3)
	bne.w	.7
	neg.w	d1	;flip d1 if shooting down
.7
	move.w	(passdir).w,d2	;passdir into d2
	asl.w	#2,d2	;mult by 4
	lea	unk_F874(pc),a0	;table of shot directions
	move.w	(a0,d2.w),d0
	move.w	2(a0,d2.w),d2	;z offset
	sub.w	(puckx).w,d0
	sub.w	(pucky).w,d1
	movem.w	d0-d2,-(sp)	;push d0-d2(dx,dy,z offset) on stack
	muls.w	d0,d0
	muls.w	d1,d1
	add.l	d1,d0
	jsr	(sroot).l
	tst.w	d0	;distance in pix to goal
	bne.w	.8
	addq.w	#1,d0
.8
	move.w	d0,d3	;straight line distance from puck to spot aiming for with passdir
	btst	#4,(gmode).w
	bne.w	.perf
	cmp.w	#$C8,d3	;C8 = 200 decimal
	bhi.w	.notperf
	jsr	(ReadGoaliePulled).l	;checks if shooting team's G pulled
	bmi.w	.perf
	btst	#0,(gmode2).w	;check if shootout
	bne.w	.perf
	moveq	#$10,d0	;start value for ShA calc
	add.b	$6E(a3),d0	;shotacc(a3)
	jsr	(randomd0).l
	cmp.w	#$E,d0	;chance of perfect shot
	bgt.w	.perf
.notperf
	clr.w	d0
	move.b	$6E(a3),d0
	lsr.w	#1,d0	;divide by 2
	move.b	d0,-(sp)	;push on stack
	move.w	(passspeed).w,d0	;move passspeed into d0
	lsr.w	#4,d0	;divide by 16
	sub.b	(sp)+,d0	;shotacc(a3) / 2
	addi.b	#$10,d0	;add $10 to d0
	mulu.w	d3,d0	;mult straight line distance with d0
	lsr.w	#6,d0	;shot accuracy adjust - divide by 64
	cmp.w	#$FA,d3	;250 pixels straight line distance
	bhi.w	.10
	lsr.w	#1,d0	;extra shot accuracy adjust
.10
	cmp.w	#$96,d0
	blt.w	.11
	move.w	#$96,d0
.11
	move.w	d0,-(sp)	;push adjusting value on stack
	jsr	(randomd0s).l
	asr.w	#2,d0
	add.w	d0,2(sp)	;add result to x diff
	move.w	(sp),d0	;move adjusting value into d0
	cmp.w	#$3C,d0	;compare to $3C (max adjustment in Y)
	bls.w	.lessx
	moveq	#$3C,d0
	move.w	d0,(sp)
.lessx
	tst.w	4(sp)
	bpl.w	.13
	lsr.w	#1,d0
.13
	jsr	(randomd0s).l
	asr.w	#2,d0
	add.w	d0,4(sp)	;add to y diff
	move.w	(sp)+,d0	;pop adj value
	lsr.w	#1,d0	;divide by 2
	jsr	(randomd0).l
	asr.w	#2,d0
	add.w	d0,4(sp)	;add to Z diff
.perf
	move.w	(passspeed).w,d2	;shot speed
	muls.w	#$44,d2	;1024/15
	muls.w	(sp)+,d2	;mult by x dist
	divs.w	d3,d2	;divide d2 by straight line distance
	move.w	d2,(puckvx).w	;move into puckvx
	move.w	(passspeed).w,d2
	muls.w	#$44,d2	;1024/15
	muls.w	(sp)+,d2	;mult by y dist
	divs.w	d3,d2	;divide d2 by straight line distance
	move.w	d2,(puckvy).w	;move into puckvy
	move.w	#$8000,d1	;this is the highest negative puckvy possible
	btst	#7,pflags(a3)
	beq.w	.15
	clr.w	d1
.15
	eor.w	d2,d1	;EOR - checking to see if exceeding maximum puckvy
	bpl.w	.16
	move.w	#$3810,(puckvy).w	;move into puckvy
	btst	#7,pflags(a3)
	bne.w	.16
	move.w	#$C7F0,(puckvy).w	;move into puckvy (shooting on bottom net)
.16
	move.w	(sp)+,d1	;pix height in goal
	beq.w	.3
	mulu.w	(passspeed).w,d1
	mulu.w	#$44,d1	;1024/15
	divu.w	d3,d1	;d3 = distance in pix to goal
	mulu.w	#$B33,d3	;(1024*42)/15
	divu.w	(passspeed).w,d3	;divide by passspeed
	add.w	d1,d3
	cmp.w	#$1800,d3
	bls.w	.1
	move.w	#$1800,d3	;set max puckvz
.1
	move.w	d3,(puckvz).w
	bclr	#4,(sflags5).w
	beq.w	.3
	btst	#3,pflags3(a3)
	bne.w	.3
	jsr	(puckvzadj).l
.3
	jsr	(sfx).l
.4
	movem.l	(sp)+,d0-d7/a0-a3
	rts

unk_F874
	dc.b	$00,$00,$00,$0C,$00,$10,$00,$0C,$00,$10,$00,$06,$00,$10,$00,$00
	dc.b	$00,$00,$00,$00,$FF,$F0,$00,$00,$FF,$F0,$00,$06,$FF,$F0,$00,$0C
	dc.b	$00,$00,$00,$06

setpassmode	;Start the pass mode (B button)
	move.w	facedir(a3),(passdir).w
	andi.w	#7,(passdir).w
	btst	#2,(BA_PS_flags).w
	beq.w	.0
	bclr	#2,(gmode2).w
	bset	#5,(BA_PS_flags).w
	bne.w	rtss7
	bclr	#5,(gmode2).w
	move.w	#$64,(passmodetimer).w
.0
	bset	#2,(sflags).w	;#sfspdir - set pass dir mode

rtss	;The shared rts of setpassmode and passmode
	rts

passmode
	btst	#4,d2	;has b button changed?
	bne.w	dopass	;yes
	btst	#3,(sflags5).w
	bne.w	dopass
	btst	#3,d0	;look for dpad
	bne.s	rtss
	andi.w	#7,d0	;pass first 3 bits of d0
	move.w	d0,(passdir).w	;new pass dir
	bset	#3,d0

dopass	;Pass the puck
	movem.l	d0-d5/a0-a1,-(sp)
	bclr	#2,(sflags).w
	st	(puckc).w	;player is not puck handler anymore
	move.b	#$10,nopuck(a3)	;$5E = nopuck
	move.w	SCnum(a3),(lastplayer).w
	btst	#1,(GameFlags).w
	beq.w	.0
	addq.b	#8,nopuck(a3)
.0
	bclr	#3,(sflags5).w
	beq.w	.noot
	jsr	(OneTimerTarget).l
	move.w	#9,(onetimerheight).w
	btst	#2,(sflags6).w
	beq.w	.1
	move.w	#$20,(onetimerheight).w
.1
	jsr	(OneTimerPass).l
	bra.w	.8
.noot
	moveq	#8,d0	;moves 8 into d0
	tst.w	position(a3)	;checks if goalie
	beq.w	.calc
	move.b	$6F(a3),d0
.calc
	asl.w	#2,d0	;d0 = passacc for player, 8 for goalie
	asr.w	#1,d0
	addi.w	#$A0,d0
	move.w	d0,(passspeed).w	;Passspeed = PassAcc (0 to 30 decimal) * 2 + A0 (160 decimal)
	btst	#0,$6F(a3)
	beq.w	.4
	asr.w	#4,d0	;divide d0 by 16
	add.w	d0,(passspeed).w	;add d0 to passspeed
.4
	moveq	#-1,d4
	moveq	#5,d3	;Set total number of players (6 total, set to 5)
	movea.w	#(SortCords-M68K_RAM),a1	;start of the home players on ice
	cmpi.w	#6,SCnum(a3)	;compares 6 to offset 52 from a3 (current player with puck) to check if player is away team or home team
	blt.w	.5
	adda.w	#$300,a1
	btst	#2,(BA_PS_flags).w
	bne.w	.7
.5
	cmpa.l	a1,a3	;Check to see if passing to self
	beq.w	.next
	tst.w	position(a1)	;position(a1)
	ble.w	.next
	btst	#2,pflags2(a1)	;check if player is unavailable
	bne.w	.next
	move.w	(a1),d0	;X Position of receiving player
	sub.w	(puckx).w,d0	;sub puckx from d0
	move.w	Ypos(a1),d1	;Y position of receiving player
	sub.w	(pucky).w,d1	;sub pucky from d1
	movem.w	d0-d1,-(sp)	;push to stack
	jsr	(vtoa).l
	movem.w	(sp)+,d1-d2	;pop from stack d1 is dX, d2 is dY
	sub.w	(passdir).w,d0	;sub passdir from d0
	btst	#4,(GameFlags).w
	beq.w	.2
	clr.w	d0
.2
	andi.w	#7,d0
	asl.b	#5,d0	;Multiply d0 by 32 (224 decimal is max)
	ext.w	d0	;sign extend d0 byte to d0 word
	asl.w	#3,d0	;mult d0 by 8 (700 decimal max)
	muls.w	d0,d0	;square d0 = max is 490000 decimal
	btst	#1,(GameFlags).w
	bne.w	.3
	cmp.l	#loc_10000,d0
	bhi.w	.next
.3
	muls.w	d1,d1	;square d1 (dX)
	muls.w	d2,d2	;square d2 (dY)
	add.l	d1,d2	;add together
	btst	#1,(GameFlags).w
	bne.w	.6
	add.l	d0,d2
.6
	cmp.l	d4,d2	;compare d4 to d2
	bhi.w	.next
	move.l	d2,d4	;move d2 into d4
	movea.l	a1,a0	;move a1 address into a0 (receiving player)
.next
	adda.w	#$80,a1	;Skip to next player (80 hex is length of player struct)
	dbf	d3,.5
	tst.l	d4	;check if there's a player to pass to
	bmi.w	.7
	bsr.w	passtoa0
	bra.w	.8
.7
	move.w	SCnum(a3),(word_FFD238).w
	move.w	(passdir).w,d0	;just hit puck in pass dir not to any player
	asl.w	#2,d0
	movea.l	#dirtab,a0
	move.w	2(a0,d0.w),d1	;y inc
	muls.w	(passspeed).w,d1
	moveq	#$A,d2
	asl.l	d2,d1
	divs.w	#runspeed*15,d1
	add.w	Yvel(a3),d1
	move.w	d1,(puckvy).w
	move.w	(a0,d0.w),d1
	muls.w	(passspeed).w,d1
	asl.l	d2,d1
	divs.w	#runspeed*15,d1
	add.w	Xvel(a3),d1
	move.w	d1,(puckvx).w
	move.w	#$1000,d0
	jsr	(randomd0).l
	move.w	d0,(puckvz).w
	btst	#1,(GameFlags).w
	beq.w	.8
	clr.w	(puckvz).w
	move.w	(puckvx).w,d0
	asr.w	#2,d0
	move.w	d0,(puckvx).w
	move.w	(puckvy).w,d0
	asr.w	#2,d0
	move.w	d0,(puckvy).w
.8
	bclr	#4,(GameFlags).w
	tst.w	position(a3)	;$34 = position
	bne.w	.notgoalie
	tst.w	(puckvy).w
	btst	#7,pflags(a3)
	beq.w	.g0
	bmi.w	.nvy
	bra.w	.notgoalie
.g0
	bmi.w	.notgoalie
.nvy
	neg.w	(puckvy).w	;negative velocity on puck
.notgoalie
	move.w	(puckvx).w,d0
	move.w	(puckvy).w,d1
	jsr	(vtoa).l
	move.w	#2,d1
	tst.w	position(a3)	;$34 = position
	beq.w	.9
	move.w	#$B6C,d1
	btst	#1,(GameFlags).w
	beq.w	.13
	move.w	#$A70,d1
.13
	jsr	(sub_16D36).l
	beq.w	.9
	move.w	#$B1A,d1
	btst	#1,(GameFlags).w
	beq.w	.9
	move.w	#$A70,d1
.9
	jsr	(SetSPA).l
	bset	#5,pflags(a3)
	moveq	#$C,d0
	sub.b	(puckvz).w,d0
	lsr.w	#2,d0
	andi.w	#3,d0
	addi.w	#$10,d0
	btst	#1,(GameFlags).w
	bne.w	.14
	move.w	d0,-(sp)	;#SFXpass
	jsr	(sfx).l
.14
	movem.l	(sp)+,d0-d5/a0-a1
	rts

passtoa0	;Pass the puck to player a0
	st	(word_FFD238).w
	jsr	(loadTeamStruct).l
	addq.w	#1,$12(a2)	;add 1 to total pass attempts
	move.w	SCnum(a0),(passplayer).w
	move.w	(passspeed).w,d5	;passspeed = pix/sec
	asr.w	#2,d5	;divides pass speed by 4
	exg	a0,a3	;tell pass recipient to get puck - swaps a3 and a0 for assinsert
	moveq	#$13,d0
	jsr	(assinsert).l
	exg	a0,a3
	btst	#4,(sflags10).w
	beq.w	.0
	cmpi.w	#$11E,(pucky).w
	bgt.w	.13
	cmpi.w	#$FEE2,(pucky).w
	blt.w	.13
.0
	move.l	a0,-(sp)	;This routine uses passspeed and player's a0 x/y speed to determine the x/y velocity of the puck so it will meet player a0
	jsr	(GetHot).l
	add.w	(a0),d0	;Xpos
	sub.w	(puckx).w,d0
	add.w	Ypos(a0),d1
	sub.w	(pucky).w,d1
	movem.w	d0-d1,-(sp)
	movem.w	(sp),d2-d3	;pop d0-d1 off into d2-d3
	asr.w	#2,d2	;d2 divide by 4
	asr.w	#2,d3	;d3 divide by 4
	move.w	Xvel(a0),d0
	muls.w	#$F0,d0	;#(16 * 60)/4 = $F0 xpix / (1/4) sec
	swap	d0	;swap upper and lower bytes
	move.w	Yvel(a0),d1
	muls.w	#$F0,d1
	swap	d1	;swap upper and lower bytes
	movem.w	d0-d1,-(sp)	;push on stack
	muls.w	d2,d0	;d0 = (d2 = Xpos puck / 4) * d0 (x pix per 1/4 sec)
	muls.w	d3,d1	;d1 = (d3 = Ypos puck /4) * d1 (y pix per 1/4 sec)
	add.w	d1,d0	;add d1 to d0
	asl.w	#1,d0	;d0 mult by 2
	move.w	d0,d4	;j = move d0 into d4
	movem.w	(sp),d0-d1	;pop d0 and d1 off stack
	muls.w	d0,d0	;(x pix per 1/4 sec)^2
	muls.w	d1,d1	;(y pix per 1/4 sec)^2
	muls.w	d5,d5	;passspeed^2
	neg.l	d5	;negative d5
	add.l	d0,d5	;add d0 to d5
	add.l	d1,d5	;k = add d1 to d5
	muls.w	d2,d2
	muls.w	d3,d3
	add.l	d2,d3	;a^2 = add d2 to d3
	muls.w	d5,d3	;multiply k * a^2
	asl.l	#2,d3	;divide by 4
	move.w	d4,d0	;d0 = j
	muls.w	d0,d0	;j^2
	sub.l	d3,d0	;j^2 - ((k*a^2)/4)
	jsr	(sroot).l
	moveq	#1,d3	;limit infinite loop
	asr.w	#2,d5	;k divide by 4
	bne.w	.1
	moveq	#1,d5	;no div by zero
.1
	move.w	d0,d2
	neg.w	d0
	sub.w	d4,d2
	ext.l	d2
	divs.w	d5,d2
	dbpl	d3,.1
	bne.w	.2
	addq.w	#1,d2	;can't be zero
.2
	cmp.w	#$18,d2	;limit to 3 sec.
	bls.w	.3
	moveq	#$18,d2	;d2 = time in 1/8 sec to intersection
.3
	btst	#1,(GameFlags).w
	beq.w	.4
	asl.w	#2,d2
.4
	move.b	d2,(puckvz).w
	cmp.w	#$C,d2
	blt.w	.6
	move.b	#$C,(puckvz).w
.6
	btst	#1,(GameFlags).w
	beq.w	.5
	clr.w	(puckvz).w
.5
	move.w	d2,d0
	asl.w	#3,d0
	subi.w	#$A,d0
	move.b	d0,temp1(a0)	;$40 = temp1
	subq.w	#6,d0
	move.b	d0,(puckx+nopuck).w
	movem.w	(sp)+,d0-d1
	muls.w	d2,d0
	asr.l	#1,d0
	add.w	(sp)+,d0	;x distance
	move.w	(puckx).w,temp3(a0)
	add.w	d0,temp3(a0)
	muls.w	d2,d1
	asr.l	#1,d1
	add.w	(sp)+,d1	;y distance
	move.w	(pucky).w,temp4(a0)
	add.w	d1,temp4(a0)
	mulu.w	#$78,d2	;$78 = 60*2
	swap	d0
	divs.w	d2,d0
	btst	#4,(sflags10).w
	beq.w	.12
	swap	d1
	divs.w	d2,d1
	movem.w	d2,-(sp)
	move.w	(puckvx).w,d2
	eor.w	d0,d2
	movem.w	(sp)+,d2
	bmi.w	.12
	movem.w	d2,-(sp)
	move.w	(puckvy).w,d2
	eor.w	d1,d2
	movem.w	(sp)+,d2
	bmi.w	.12
	movem.w	d2-d5,-(sp)
.7
	move.w	d0,d2
	move.w	d1,d3
	move.w	(puckvx).w,d4
	move.w	(puckvy).w,d5
	tst.w	d2
	bpl.w	.8
	neg.w	d2
	neg.w	d4
.8
	cmp.w	d2,d4
	blt.w	.10
	tst.w	d3
	bpl.w	.9
	neg.w	d3
	neg.w	d5
.9
	cmp.w	d3,d5
	bgt.w	.11
.10
	move.w	d0,d2
	asr.w	#3,d2
	sub.w	d2,d0
	move.w	d1,d2
	asr.w	#3,d2
	sub.w	d2,d1
	bra.s	.7
.11
	movem.w	(sp)+,d2-d5
	move.w	d0,(puckvx).w
	move.w	d1,(puckvy).w
	bra.w	.13
.12
	move.w	d0,(puckvx).w
	swap	d1
	divs.w	d2,d1
	move.w	d1,(puckvy).w
.13
	rts

sub_FD14
	movem.l	d0-d7/a0-a5,-(sp)
	bsr.w	sub_10070
	move.w	(puckx).w,d0
	cmp.w	#$32,d0
	bgt.w	.0
	cmp.w	#$FFCE,d0
	blt.w	.1
	move.w	#1,d7
	bra.w	.2
.0
	move.w	#2,d7
	bra.w	.2
.1
	clr.w	d7
.2
	movea.l	#SortCords,a5
	move.w	(word_FFD23A).w,d6
	bmi.w	.3
	cmpi.w	#6,(word_FFC74A).w
	bne.w	.3
	bsr.w	sub_FD80
.3
	movea.l	#SortCords+$300,a5
	move.w	(word_FFD23C).w,d6
	bmi.w	.4
	cmpi.w	#6,(word_FFCAE8).w
	bne.w	.4
	bsr.w	sub_FD80
.4
	movem.l	(sp)+,d0-d7/a0-a5
	rts

sub_FD80
	move.w	d7,-(sp)
	asl.w	#7,d6
	movea.l	#SortCords,a3
	adda.w	d6,a3
	move.w	$34(a3),d6
	bmi.w	.15
	tst.b	$65(a3)
	bmi.w	.0
	clr.w	d6
	move.b	$65(a3),d6
.0
	move.w	d6,d4
	lsl.b	#2,d6
	or.b	d7,d6
	andi.w	#$1F,d6
	asl.w	#2,d6
	movea.l	#$FEAA,a0
	movea.l	(a0,d6.w),a0
	cmpa.l	#0,a0
	beq.w	.15
	movem.l	d0/d5-d7/a3/a5,-(sp)
	cmp.w	#1,d4
	bne.w	.6
	movea.l	a5,a3
	movea.l	#SortCords,a5
	asl.w	#7,d6
	adda.w	d6,a5
	move.w	#5,d6
.1
	cmpi.b	#3,$65(a3)
	beq.w	.2
	tst.b	$65(a3)
	bpl.w	.3
	cmpi.w	#3,$34(a3)
	bne.w	.3
.2
	move.w	$14(a3),d7
	bra.w	.4
.3
	adda.w	#$80,a3
	dbf	d6,.1
	bra.w	.11
.4
	move.w	$14(a5),d0
	btst	#7,$62(a5)
	bne.w	.5
	neg.w	d0
	neg.w	d7
.5
	cmp.w	d7,d0
	blt.w	.10
	bra.w	.11
.6
	cmp.w	#2,d4
	bne.w	.11
	movea.l	a5,a3
	movea.l	#SortCords,a5
	asl.w	#7,d6
	adda.w	d6,a5
	move.w	#5,d6
.7
	cmpi.b	#5,$65(a3)
	beq.w	.8
	tst.b	$65(a3)
	bpl.w	.9
	cmpi.w	#5,$34(a3)
	bne.w	.9
.8
	move.w	$14(a3),d7
	bra.s	.4
.9
	adda.w	#$80,a3
	dbf	d6,.7
	bra.w	.11
.10
	movem.l	(sp)+,d0/d5-d7/a3/a5
	bra.w	.15
.11
	movem.l	(sp)+,d0/d5-d7/a3/a5
	move.w	#5,d5
.12
	clr.w	d1
	move.b	$65(a5),d1
	bpl.w	.13
	move.w	$34(a5),d1
	bmi.w	.14
.13
	move.b	(a0,d1.w),d2
	bmi.w	.14
	move.b	d2,$65(a5)
.14
	adda.w	#$80,a5
	dbf	d5,.12
.15
	move.w	(sp)+,d7
	rts
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$FF,$59,$00,$00,$FF,$59,$00,$00,$FF,$59,$00,$00,$00,$00
	dc.b	$00,$00,$FF,$60,$00,$00,$FF,$60,$00,$00,$FF,$60,$00,$00,$00,$00
	dc.b	$00,$00,$FF,$1A,$00,$00,$FF,$28,$00,$00,$FF,$21,$00,$00,$00,$00
	dc.b	$00,$00,$FF,$2F,$00,$00,$FF,$3D,$00,$00,$FF,$36,$00,$00,$00,$00
	dc.b	$00,$00,$FF,$44,$00,$00,$FF,$52,$00,$00,$FF,$4B,$00,$00,$00,$00
	dc.b	$00,$00,$FF,$2F,$00,$00,$FF,$3D,$00,$00,$FF,$36,$00,$00,$00,$00
	dc.b	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$05,$03,$04,$FF,$FF,$FF
	dc.b	$FF,$04,$03,$FF,$FF,$FF,$FF,$FF,$04,$03,$FF,$FF,$FF,$FF,$FF,$FF
	dc.b	$05,$04,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$04,$05,$03
	dc.b	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$05,$04,$FF,$FF
	dc.b	$03,$FF,$01,$FF,$FF,$FF,$FF,$FF,$05,$FF,$FF,$02,$FF,$FF,$48,$E7
	dc.b	$70,$80,$0C,$78,$00,$02,$D2,$68,$67,$00,$00,$44,$4A,$6B,$00,$34
	dc.b	$6B,$00,$00,$3C,$42,$40,$10,$2B,$00,$65,$6A,$00,$00,$06,$30,$2B
	dc.b	$00,$34,$32,$2B,$00,$36,$12,$33,$10,$38,$20,$7C,$00,$00,$FF,$C2
	dc.b	$B2,$30,$00,$00,$67,$00,$00,$18,$20,$7C,$00,$00,$FF,$C9,$B2,$30
	dc.b	$00,$00,$67,$00,$00,$0A,$10,$30,$00,$00,$60,$00,$00,$06,$30,$3C
	dc.b	$00,$00,$4C,$DF,$01,$0E,$4E,$75,$00,$01,$01,$04,$06,$04,$06,$00
	dc.b	$02,$02,$03,$05,$03,$05

sub_FFD0
	tst.w	(puckc).w
	bmi.w	locret_10054
	movem.l	d0-d4/a0-a3,-(sp)
	move.w	(puckc).w,d0
	asl.w	#7,d0	;#scsize
	movea.w	#(SortCords-M68K_RAM),a3
	adda.w	d0,a3
	movea.l	#SortCords,a0
	btst	#6,$62(a3)
	beq.w	.0
	adda.w	#$300,a0
.0
	move.w	(pucky).w,d0

loc_10000
	move.w	#$76,d1
	btst	#7,$62(a3)
.0
	beq.w	.1
	neg.w	d0
.1
	cmp.w	d1,d0
	blt.w	.2
	tst.w	$34(a3)
	bne.w	.5
	bra.w	.3
.2
	neg.w	d0
	cmp.w	d1,d0
	blt.w	.5
	move.b	$62(a3),d0
	move.b	$62(a0),d1
	eor.b	d1,d0
	btst	#6,d0
	beq.w	.5
	bra.w	.5
.3
	move.w	#5,d1
.4
	st	$65(a0)
	adda.w	#$80,a0
	dbf	d1,.4
.5
	movem.l	(sp)+,d0-d4/a0-a3

locret_10054
	rts

sub_10056
	movem.l	d1/a0,-(sp)
	move.w	#5,d1
.0
	st	$65(a0)
	adda.w	#$80,a0
	dbf	d1,.0
	movem.l	(sp)+,d1/a0
	rts

sub_10070
	movem.l	d0-d1/a0-a1,-(sp)
	movea.l	#SortCords,a0
	bsr.w	sub_1008E
	movea.l	#SortCords+$300,a0
	bsr.w	sub_1008E
	movem.l	(sp)+,d0-d1/a0-a1
	rts

sub_1008E
	movea.l	a0,a1
	clr.w	d2
	move.w	#5,d0
.0
	clr.w	d1
	move.b	$65(a0),d1
	bpl.w	.1
	move.w	$34(a0),d1
	bmi.w	.2
.1
	bset	d1,d2
	beq.w	.2
	movea.l	a1,a0
	bsr.s	sub_10056
	bra.w	.3
.2
	adda.w	#$80,a0
	dbf	d0,.0
.3
	rts

