;	The faceoff: input, the faceoff window, keeping the spot inside the rink, and the assignment
;	routines that run the players and the puck. The assignment bytes are what the listing
;	left undecoded.

faceoffinput						;The faceoff player (assignment $17): store the dpad pull (fodir1 /
									;fodir2) and start the faceoff
									;SPA (SPAfaceoff with B, else SPAfaceoffr)
	btst	#6,(sflags5).w
	beq.w	.1
	rts
.1
	move.w	assnum(a3),d4
	cmpi.b	#$17,asslist(a3,d4.w)
	bne.w	rtss7
	movea.w	#(fodir1-M68K_RAM),a0	;faceoff direction of puck control variable
	btst	#pfgoal,pflags(a3)
	beq.w	.2						;branch if bottom goal
	movea.w	#(fodir2-M68K_RAM),a0
.2
	move.w	d0,(a0)
	btst	#pf2aip,pflags2(a3)
	bne.w	rtss7
	btst	#4,d1					;test for b button press
	beq.w	.3
	move.w	#SPAfaceoff,d1
	bset	#pf2aip,pflags2(a3)		;set anim in progress
	jmp	SetSPA
.3
	move.w	#SPAfaceoffr,d1
	jmp	SetSPA

assfaceoff							;Assignment: wait for the faceoff to end (sflags2 bit 0), then assexit.
									;puckfaceoff2
	btst	#pfalock,pflags(a3)
	bne.w	.1
	btst	#0,(sflags2).w
	beq.w	.2
.1
	rts
GoAssExit	equ	*			;Jump to assexit (the assfaceoff branches end here)
.2
	jmp	(assexit).l

assfaceoffpl						;Assignment: the faceoff player
	btst	#pfalock,pflags(a3)
	bne.w	.6
	btst	#sf2faceoff,(sflags2).w
	beq.w	.5
	bclr	#pfna,pflags(a3)
	beq.w	.1
	clr.w	temp1(a3)
.1
	movea.l	#fofdata2,a0
	btst	#pfteam,pflags(a3)
	beq.w	.2
	addq.w	#4,a0
.2
	move.w	SPAnum(a3),d0
	lsr.w	#2,d0
	addq.w	#1,d0
	btst	#0,handed(a3)
	bne.w	.3
	addq.w	#3,d0
.3
	move.w	d0,(a0)
	btst	#pfjoycon,pflags(a3)
	bne.w	.6
	bset	#pf2aip,pflags2(a3)
	bne.w	.6
	move.w	#SPAfaceoff,d1
	cmpi.w	#$12,($FFFFB79E).w
	bls.w	.4
	moveq	#8,d0
	jsr	(randomd0).l
	tst.w	d0
	beq.w	.4
	move.w	#SPAfaceoffr,d1
.4
	bset	#pf2aip,pflags2(a3)
	jmp	(SetSPA).l
.5
	move.b	#$14,nopuck(a3)
	bra.w	GoAssExit
.6
	rts

puckfaceoff							;Puck assignment: the faceoff set up
	st	(DumpPassSc).w
	st	(LastCarrierHome).w
	st	(LastCarrierAway).w
	bclr	#4,(sflags8).w
	btst	#0,(gmode2).w
	beq.w	.1
	clr.w	(puckvx).w
	clr.w	(puckvy).w
	move.w	#$1E,d0
	jmp	(assreplace).l
.1
	bclr	#pfna,pflags(a3)
	beq.w	WaitForFaceoffLineChanges
	bclr	#0,(sflags8).w
	beq.w	.2
	clr.w	(fox).w
	clr.w	(foy).w
.2
	bclr	#7,(sflags7).w
	clr.l	(padcont).w
	clr.l	(padcont+4).w
	clr.l	(padcont+8).w
	bclr	#6,(sflags7).w
	bclr	#2,(sflags7).w
	bset	#2,(sflags12).w
	jsr	(chkFgtBit1ShotsLead).l
	tst.w	(faceoffanim).w
	bmi.w	.3
	move.w	(faceoffanim).w,d0
	bra.w	.4
.3
	jsr	(PickFaceoffDirection).l
	tst.w	d0
	bmi.w	.5
.4
	jsr	(SetFaceoffAnim).l
.5
	bclr	#1,(sflags6).w
	bclr	#1,(gmode2).w
	tst.w	(gameclock).w
	beq.w	GoPeriodOver
	btst	#6,(gmode).w
	bne.w	GoPeriodOver
	cmpi.w	#3,(gsp).w
	bne.w	.6
	move.w	(HmGoals).w,d0
	cmp.w	(AwGoals).w,d0
	beq.w	.6
	jmp	(clockcontPuckAssignments).l
.6
	btst	#gmpendel,(gmode).w
	bne.w	GoStop4Pen
	move.w	(PerTimeTotal).w,d0
	asr.w	#1,d0
	cmp.w	(gameclock).w,d0
	bls.w	.7
	cmpi.w	#$3C,(gameclock).w
	blt.w	.7
	bclr	#sf3fosong,(sflags3).w
	beq.w	.7
	btst	#gmclock,(gmode).w
	beq.w	.7
	btst	#6,(sflags8).w
	bne.w	.7
	move.w	(HomeTeam).w,(HmTeam).w
	move.w	#2,(SongIndex).w
	jsr	(ChooseSong).l
	bset	#4,(sflags8).w
.7
	jsr	(ReturnGoalies).l
	st	temp1(a3)
	st	temp2(a3)
	tst.w	(OptLine).w
	bne.w	WaitForFaceoffLineChanges
	bclr	#tmflcm,(HomeTmFlags).w
	bclr	#tmflcm,(AwayTmFlags).w
	movea.w	#(SortCords-M68K_RAM),a0
	moveq	#$B,d0
.loop
	bclr	#pf2lcm,pflags2(a0)
	adda.w	#SCstruct,a0
	dbf	d0,.loop
	move.w	(cont1team).w,d0
	or.w	(cont2team).w,d0
	beq.w	.8
	btst	#7,(sflags).w
	beq.w	.8
	jsr	(forceblack).l
	bset	#6,(sflags).w
	jsr	(ClrHor).l
	move.w	#$18,(palcount).w
	tst.w	(OptLine).w
	bne.w	.8
	btst	#4,(sflags7).w
	beq.w	.8
	clr.w	(palcount).w
.8
	move.w	(c1playernum).w,d0
	bmi.w	.9
	cmp.w	#6,d0
	blt.w	.12
.9
	move.w	(c2playernum).w,d0
	bmi.w	.10
	cmp.w	#6,d0
	blt.w	.12
.10
	move.w	(c3playernum).w,d0
	bmi.w	.11
	cmp.w	#6,d0
	blt.w	.12
.11
	move.w	(c4playernum).w,d0
	cmp.w	#6,d0
	bge.w	.13
.12
	tst.w	d0
	bmi.w	.13
	bsr.w	StartFaceoffLineChange
.13
	move.w	(c1playernum).w,d0
	cmp.w	#6,d0
	bge.w	.14
	move.w	(c2playernum).w,d0
	cmp.w	#6,d0
	bge.w	.14
	move.w	(c3playernum).w,d0
	cmp.w	#6,d0
	bge.w	.14
	move.w	(c4playernum).w,d0
	cmp.w	#6,d0
	blt.w	.15
.14
	tst.w	d0
	bmi.w	.15
	bsr.w	StartFaceoffLineChange
.15
	movea.w	#(tmstruct-M68K_RAM),a1
	lea	$39E(a1),a2
	moveq	#2,d0
	jsr	(SetFaceoffComputerLine).l
	bra.w	WaitForFaceoffLineChanges

SetFaceoffComputerLine				;Line changes on and team d0 not on a pad: CompLine, SetPersonel
	tst.w	(OptLine).w
	bne.w	.2
	btst	#4,(sflags7).w
	bne.w	.1
	cmp.w	(cont1team).w,d0
	beq.w	.2
	cmp.w	(cont2team).w,d0
	beq.w	.2
	cmp.w	(cont3team).w,d0
	beq.w	.2
	cmp.w	(cont4team).w,d0
	beq.w	.2
.1
	jsr	(CompLine).l
	jsr	(setpersonel).l
	jsr	(printscores1).l
	move.w	#$2710,(crowdnoisedelay).w
SetFaceoffComputerLineExit	equ	*			;Shared return of SetFaceoffComputerLine
.2
	rts

StartFaceoffLineChange				;Player d0 (sort object) opens the line change box
	exg	a2,a3
	asl.w	#7,d0
	movea.w	#(SortCords-M68K_RAM),a3
	adda.w	d0,a3
	bclr	#pf2lcm,pflags2(a3)
	move.l	a2,-(sp)
	jsr	(SetLCmode).l
	movea.l	(sp)+,a2
	btst	#pf2lcm,pflags2(a3)
	beq.w	.2
	btst	#pfteam,pflags(a3)
	beq.w	.1
	move.w	#$168,temp2(a2)
	move.w	SCnum(a3),temp4(a2)
	bra.w	.2
.1
	move.w	#$258,temp1(a2)
	move.w	SCnum(a3),temp3(a2)
.2
	exg	a2,a3

rtsfaceoff							;The shared rts of the faceoff routines
	dc.b	$4E,$75

WaitForFaceoffLineChanges			;Run both line change timers; when both are done set the home computer
									;line
	move.w	#$40,d0
	jsr	(UpdateFaceoffLineChangeTimer).l
	move.w	#$42,d0
	jsr	(UpdateFaceoffLineChangeTimer).l
	tst.w	temp1(a3)
	bpl.s	SetFaceoffComputerLineExit
	tst.w	temp2(a3)
	bpl.s	SetFaceoffComputerLineExit
	movea.w	#(tmstruct-M68K_RAM),a2
	lea	$39E(a2),a1
	moveq	#1,d0
	jsr	(SetFaceoffComputerLine).l
	move.w	#$FFFF,(userblockx).w
	move.w	#$1C,d0					;puckfaceoff2
	jmp	(assreplace).l

UpdateFaceoffLineChangeTimer		;Line change timer d0 (temp1 / temp2 of the puck)
	tst.w	(a3,d0.w)
	bmi.w	SetFaceoffComputerLineExit
	move.w	4(a3,d0.w),d1
	asl.w	#7,d1
	movea.w	#(SortCords-M68K_RAM),a0
	movea.w	#(tmstruct-M68K_RAM),a2
	btst	#pfteam,$62(a0,d1.w)
	beq.w	.1
	adda.w	#$39E,a2
.1
	btst	#3,$63(a0,d1.w)
	bne.w	.2
	st	(a3,d0.w)
	bra.w	SetLCmode2
.2
	sub.w	d7,(a3,d0.w)
	bpl.w	SetFaceoffComputerLineExit
	move.l	a3,-(sp)
	lea	(a0,d1.w),a3
	btst	#pf2lcm,pflags2(a3)
	beq.w	.3
	clr.w	d2
	jsr	(lcfound).l
	jsr	(SetLCmode2).l
.3
	movea.l	(sp)+,a3
	rts
GoPeriodOver	equ	*	;Jump to PeriodOver
	jmp	(PeriodOver).l
GoStop4Pen	equ	*	;Jump to Stop4Pen
	jmp	(Stop4Pen).l

puckfaceoff2						;Puck assignment: the faceoff
	bclr	#pfna,pflags(a3)
	beq.w	.19
	bclr	#1,(sflags12).w
	bclr	#2,(BA_PS_flags).w
	bclr	#5,(BA_PS_flags).w
	bclr	#0,(sflags4).w
	bclr	#1,(sflags4).w
	bclr	#0,(sflags9).w
	bclr	#1,(sflags9).w
	bclr	#2,(sflags9).w
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(forceblack).l
	;loop
.loop
	btst	#dfok,(disflags).w
	bne.s	.loop
	bclr	#0,(sflags14).w
	move.w	sr,-(sp)
	move.w	#$3C,(holdreset).w
	tst.w	(fox).w
	bne.w	.1
	tst.w	(foy).w
	bne.w	.1
	move.w	#$FFFF,(faceoffanim).w
	bra.w	.2
.1
	move.w	#$2700,sr
	;cap the crowd level
.2
	cmpi.w	#$258,(Crowdlevel).w
	bls.w	.3
	move.w	#$258,(Crowdlevel).w	;limit crowd level
	;crowd level set
.3
	bset	#dfclock,(disflags).w	;stop clock
	bclr	#sfpz,(sflags).w		;no pause
	bclr	#sf3llcs,(sflags3).w	;no line changes
	move.w	#$3E8,(glovecords+2).w
	move.w	#$3E8,(glovecords).w
	clr.b	(lty+2).w				;no icing
	st	(RefCnt).w					;no refs
	st	(puckcross2).w				;no goalie moves
	st	(puckcross6).w
	bclr	#sf2refref,(sflags2).w	;no ref refresh
	bset	#sf2faceoff,(sflags2).w	;face off in progress
	bset	#sf2drec,(sflags2).w	;dont record yet
	st	(passplayer).w
	st	(onetimerplayer).w
	bset	#dffaceoff,(disflags).w
	bclr	#4,(sflags9).w
	jsr	(ClrHor).l					;vertical ice rink
	move.w	#$2710,(crowdnoisedelay).w
	clr.w	(Vpos).w				;clear h/v pos
	clr.w	(Hpos).w
	move.w	(fox).w,(puckx).w		;puck on the face off spot (fox/foy)
	move.w	(foy).w,(pucky).w
	st	(puckz).w					;no visible puck
	clr.w	(puckvx).w
	clr.w	(puckvy).w
	clr.w	(puckvz).w
	st	(puckc).w					;nobody carries it
	movea.w	#(SortCords+(12*SCstruct)-M68K_RAM),a0	;reposition goal nets
	clr.w	Xvel(a0)				;Xvel
	clr.w	Yvel(a0)				;Yvel
	clr.w	(a0)					;Xpos
	move.w	#$122,Ypos(a0)
	adda.w	#SCstruct,a0			;add SCstruct to move to next goal net
	clr.w	Xvel(a0)
	clr.w	Yvel(a0)
	clr.w	(a0)
	move.w	#$FEDE,Ypos(a0)
	movea.w	#(SortCords+((puckscnum+1)*SCstruct)-M68K_RAM),a0	;move to puck shadow SCnum
	move.w	#$299,frame(a0)
	clr.w	SPA(a0)					;SPA
	clr.w	attribute(a0)			;attribute
	clr.w	(puckx+4).w				;clear puck SCnum attribute
	bclr	#sfslock,(sflags).w		;free up scrolling
	moveq	#$64,d4					;run the scroll window 101 times so it settles
	;run the scroll window 101 times so it settles
.loop2
	jsr	(checkwindow).l				;scroll to faceoff spot
	dbf	d4,.loop2
	move.w	#$3C,(yleader).w
	jsr	(ResetBench).l
	movea.w	#(tmstruct-M68K_RAM),a2	;set personnel and player data for both teams
	jsr	(setpersonel).l
	jsr	(forcepldata).l
	adda.w	#$39E,a2
	jsr	(setpersonel).l
	jsr	(forcepldata).l
	jsr	(resetplstuff).l
	move.l	a3,-(sp)				;keep the puck pointer
	movea.w	#(SortCords-M68K_RAM),a3
	moveq	#$B,d2					;loop over the 12 players
	;loop over the 12 players: park them off ice, then set the faceoff spots
.loop3
	move.w	#$FF10,(a3)				;-240, Xpos
	clr.w	Ypos(a3)				;Ypos
	clr.w	frame(a3)				;frame
	move.w	position(a3),d1			;position
	bmi.w	.12						;absent
	beq.w	.6						;goalie: no assignment change
	move.l	#$16,d0					;#afaceoff - assignment faceoff
	cmp.w	#4,d1					;find the center (position 4)
	bne.w	.5
	movea.w	#(tmstruct-M68K_RAM),a2
	btst	#pfteam,pflags(a3)		;#pfgoal - what goal to score on
	beq.w	.4
	adda.w	#$39E,a2
	;clear the touches
.4
	clr.w	Zpos(a2)
	move.b	pnum(a3),$19(a2)
	bclr	#7,(sflags8).w
	st	$1A(a2)						;clear last player to touch puck (assist 1)
	st	OldXpos(a2)					;clear second last player to touch puck (assist 2)
	bclr	#3,limpact(a2)
	move.l	#$17,d0					;#afaceoffpl - faceoff player assignment
	;player position
.5
	jsr	(assinsert).l
	;d4 = active players of this player's team
.6
	move.w	($FFFFC74A).w,d4		;tmap = active players on ice (4-6). (tmap).w
	btst	#pfteam,pflags(a3)		;#pfteam - 0=home 1=away
	beq.w	.7
	move.w	($FFFFCAE8).w,d4		;(tmsize).w
	;players to place
.7
	neg.w	d4						;d4 = 6 - active players: formation row
	addq.w	#6,d4					;6 - active players
	asl.w	#3,d4					;8 bytes per row of .apl
	movea.l	#$A26C,a1
	adda.w	d4,a1					;row for this team size ...
	move.b	(a1,d1.w),d4
	asl.w	#2,d4
	movea.l	#$A284,a1
	move.w	(a1,d4.w),d0
	move.w	2(a1,d4.w),d1
	btst	#pfgoal,pflags(a3)		;#pfgoal - 0=bottom, 1=top
	bne.w	.8
	neg.w	d0						;mirror for the team shooting the other way
	neg.w	d1
	;coordinates for his end
.8
	tst.w	position(a3)			;check for goalie
	beq.w	.11
	cmp.w	#8,d4
	bgt.w	.10						;slots above 2 are not shifted by the spot
	move.w	(fox).w,d3
	eor.w	d0,d3
	bpl.w	.9						;fox and slot x on the same side
	move.w	(foy).w,d3
	asr.w	#3,d3
	sub.w	d3,d1					;opposite side: also pull y toward the spot
	;pull the slot x toward the faceoff spot
.9
	move.w	(fox).w,d3				;pull x toward the spot by fox/4
	asr.w	#2,d3
	sub.w	d3,d0
	;set the position
.10
	add.w	(fox).w,d0
	add.w	(foy).w,d1
	;place the player at the slot plus the spot
.11
	move.w	d0,(a3)					;Xpos
	move.w	d1,Ypos(a3)				;Ypos
	clr.w	Xvel(a3)				;Xvel
	clr.w	Yvel(a3)				;Yvel
	sub.w	(puckx).w,d0
	sub.w	(pucky).w,d1
	neg.w	d0
	neg.w	d1
	jsr	(vtoa).l					;face the direction from the puck to the player
	move.w	d0,facedir(a3)			;facedir
	bclr	#pf2unav,pflags2(a3)	;#pf2unav
	bclr	#pfalock,pflags(a3)		;#pfalock
	move.w	#SPAglide,d1
	jsr	(SetSPA).l					;glide animation
	;next player
.12
	adda.w	#$80,a3					;#Scstruct
	dbf	d2,.loop3
	jsr	(SprSort).l
	movea.l	(sp)+,a3
	jsr	(AssignPads).l
	move.w	(ExtraChars).w,d4
	movea.l	#$91D4E,a2
	jsr	(DecompressGraphicsPlain).l
	move.w	d4,(faceoffvrcset).w
	movea.l	#$13BCB8,a2
	jsr	(DecompressGraphicsPlain).l
	move.w	#$FFFF,(arenaanim).w
	btst	#0,(sflags7).w
	beq.w	.13
	move.w	(faceoffanim).w,d0
	bmi.w	.13
	jsr	(StartArenaAnim).l
	;draw the faceoff window
.13
	bsr.w	DrawFaceoffWindow
	;drop time
	move.w	#$78,d0					;random time before the puck drop
	jsr	(randomd0).l				;0-$77
	addi.w	#$12C,d0
	cmpi.w	#0,(arenaanim).w
	beq.w	.14
	cmpi.w	#1,(arenaanim).w
	beq.w	.14
	cmpi.w	#5,(arenaanim).w
	beq.w	.14
	cmpi.w	#4,(arenaanim).w
	beq.w	.14
	cmpi.w	#2,(arenaanim).w
	bne.w	.15
.14
	cmp.w	#$186,d0
	bgt.w	.15
	move.w	#$186,d0
	;set the drop time
.15
	move.w	d0,temp1(a3)			;time for puck drop
	move.w	#$18,(palcount).w
	movea.l	#fofdata2,a0			;second half of the big face off sprite data
	move.w	#1,(a0)
	move.w	#$8000,2(a0)
	move.w	#4,4(a0)
	move.w	#$A800,6(a0)
	move.w	#7,8(a0)				;frame of ref
	move.w	#$8000,$A(a0)
	btst	#gmdir,(gmode).w		;#gmdir - 0 = home team goes up
	bne.w	.16
	eori.w	#$800,2(a0)				;flip attribute bit $800 (two of the sprites) when gmdir is clear
	eori.w	#$800,6(a0)
	;draw the faceoff sprites
.16
	move.w	#$FFFF,(fodir1).w		;-1
	move.w	#$FFFF,(fodir2).w		;-1
	jsr	(LeadSong).l
	bclr	#6,(sflags8).w
	bne.w	.17
	bclr	#4,(sflags8).w
	beq.w	.18
	;play the queued song
.17
	bclr	#4,(sflags8).w
	move.w	(SongNum).w,-(sp)
	jsr	(song).l
.18
	move.w	#$78,(VisTeam+2).w
	jsr	(ShowBigScore).l
	move.w	#$18,(palcount).w
	move.w	(sp)+,sr
	movem.l	(sp)+,d0-d7/a0-a6
	rts
.19
	subq.w	#1,(VisTeam+2).w
	bne.w	.20
	jsr	(ClearBigScore).l
	bclr	#2,(sflags12).w
	bset	#3,(sflags12).w
	;pfna was clear
.20
	subq.w	#1,temp1(a3)
	bpl.w	.21
	jsr	(EndArenaAnim).l
	jmp	(Endfaceoff).l
.21
	jmp	(updatefaceoff).l
.apl								;Faceoff positions of the players by line slot
	dc.b	0,1,2,3,4,5,6,0
	dc.b	0,1,5,3,4,2,0,0
	dc.b	0,3,5,1,4,0,0,0
.ptab								;Faceoff x / y offsets
	dc.w	0,$FEF0,$FFDD,$FFCE,$23,$FFCE,$FFCE,$FFF6
	dc.w	0,$FFF1,$32,$FFF6,0,$FFC4

DrawFaceoffWindow					;Draw the faceoff window (FaceOffMap) at x $36 or $BE y $5C, and with line
									;changes on the two line names (linelist)
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),0,0,0
	moveq	#$36,d0
	tst.w	(fox).w
	bpl.w	.setx
	move.w	#$BE,d0
.setx
	move.w	d0,(fodropx).w
	subi.w	#$2E,d0
	asr.w	#3,d0
	move.w	d0,(printx).w
	moveq	#$5C,d0
	move.w	d0,(fodropy).w
	subi.w	#$44,d0
	asr.w	#3,d0
	move.w	d0,(printy).w
	move.w	(ExtraChars).w,d4
	movea.l	#FaceOffMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	moveq	#$C,d2
	moveq	#9,d3
	moveq	#0,d5
	bset	#0,(sflags6).w
	jsr	(dobitmap).l
	bclr	#0,(sflags6).w
	tst.w	(OptLine).w
	bne.w	.exit
	jsr	(printsmallz).l
	String	CC_AddY,$A,CC_SetAttribute,4
	moveq	#$C,d0
	moveq	#3,d1
	jsr	(Framer).l
	move.w	(tmstruct+tmline).w,d0
	move.w	(AwShots+tmline).w,d1
	btst	#gmdir,(gmode).w
	bne.w	.0
	exg	d0,d1
.0
	jsr	(printsmallz).l
	String	CC_AddX,1,CC_AddY,$FE
	movea.l	#linelist,a1
	jsr	(SkipStrings).l
	jsr	(print).l
	addq.w	#4,(printx).w
	move.w	d1,d0
	movea.l	#linelist,a1
	jsr	(SkipStrings).l
	jsr	(print).l
.exit
	rts

limitfo								;Limit the faceoff spot to the walls of the rink, for every player in
									;PenBuf
	movem.l	d0-d1/a0-a1,-(sp)
	movea.w	#(PenBuf-M68K_RAM),a0
.loop
	bsr.w	.lf
	addq.w	#2,a0
	tst.w	(a0)
	bne.s	.loop
	movem.l	(sp)+,d0-d1/a0-a1
	rts
.lf
	move.b	1(a0),d0
	andi.w	#$7F,d0
	asl.w	#scsize,d0				;scsize
	movea.w	#(SortCords-M68K_RAM),a1
	move.w	#$76,d1
	btst	#pfgoal,pflags(a1,d0.w)
	bne.w	.2
	neg.w	d1
	cmp.w	(foy).w,d1
	blt.w	.1
	move.w	#$FF98,(foy).w
	bra.w	.sx
.2
	cmp.w	(foy).w,d1
	bgt.w	.1
	move.w	#$68,(foy).w
.sx
	move.w	#$51,d0
	tst.w	(fox).w
	bpl.w	.0
	neg.w	d0
.0
	move.w	d0,(fox).w
.1
	rts

rtss7								;The shared rts of faceoffinput and doinput
	rts

Endfaceoff							;Drop the puck: pick the winner (.ftab) and the puck direction.
	move.w	#SFXpuckice,-(sp)
	jsr	(sfx).l
	bclr	#sf2faceoff,(sflags2).w
	move.w	#$3C,(holdreset).w
	move.w	(ExtraChars).w,d4
	movea.l	#$97E7A,a2
	jsr	(DecompressGraphicsPlain).l
	bclr	#sf2drec,(sflags2).w
	bclr	#gmclock,(gmode).w
	bclr	#pf2fight,pflags2(a3)
	clr.w	(crowdnoisedelay).w
	bset	#4,(sflags3).w
	move.w	(fodir1).w,d3
	move.w	#$800,d4
	movea.l	#$A4D6,a0
	movea.w	#(fofdata2-M68K_RAM),a1
	moveq	#$10,d2
	move.w	(a1),d1
	sub.b	-$1(a0,d1.w),d2
	move.w	4(a1),d1
	add.b	-$1(a0,d1.w),d2
	moveq	#$21,d0
	jsr	(randomd0).l
	cmp.b	d0,d2
	bls.w	.1
	addq.w	#4,a1
.1
	btst	#3,2(a1)
	beq.w	.2
	move.w	(fodir2).w,d3
	neg.w	d4
.2
	move.w	d3,d0
	btst	#3,d0
	bne.w	.3
	andi.w	#7,d0
	move.w	(HVcount).l,d1
	andi.w	#3,d1
	bne.w	.4
.3
	moveq	#5,d0
	jsr	(randomd0).l
	subq.w	#2,d0
	andi.w	#7,d0
	tst.w	d4
	bmi.w	.4
	eori.w	#4,d0
.4
	asl.w	#2,d0
	movea.l	#dirtab,a0
	move.w	(a0,d0.w),d1
	asl.w	#5,d1
	move.w	d1,Xvel(a3)
	move.w	2(a0,d0.w),d1
	asl.w	#5,d1
	add.w	d4,d1
	move.w	d1,Yvel(a3)
	move.w	#$800,d0
	jsr	(randomd0).l
	move.w	d0,Zvel(a3)
	clr.w	(puckz).w
	bclr	#pfnc,pflags(a3)
	move.l	#$18,d0
	jmp	(assreplace).l
.ftab
	dc.b	0,8,$10,0,8,$10

