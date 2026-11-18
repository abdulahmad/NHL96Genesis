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
.2
	jmp	(assexit).l

assfaceoffpl						;Assignment: the faceoff player
; Code kept as bytes (decoded by decode_code.py).
	dc.b	$08,$2B,$00,$05,$00,$62,$66,$00,$00,$8C,$08,$38,$00,$00,$C3,$3C
	dc.b	$67,$00,$00,$78,$08,$AB,$00,$01,$00,$62,$67,$00,$00,$06,$42,$6B
	dc.b	$00,$40,$20,$7C,$FF,$FF,$BD,$BE,$08,$2B,$00,$06,$00,$62,$67,$00
	dc.b	$00,$04,$58,$48,$30,$2B,$00,$5A,$E4,$48,$52,$40,$08,$2B,$00,$00
	dc.b	$00,$77,$66,$00,$00,$04,$56,$40,$30,$80,$08,$2B,$00,$03,$00,$62
	dc.b	$66,$00,$00,$42,$08,$EB,$00,$01,$00,$63,$66,$00,$00,$38,$32,$3C
	dc.b	$21,$26,$0C,$78,$00,$12,$B7,$9E,$63,$00,$00,$14,$70,$08,$4E,$B9
	dc.b	$00,$01,$B0,$A6,$4A,$40,$67,$00,$00,$06,$32,$3C,$21,$50,$08,$EB
	dc.b	$00,$01,$00,$63,$4E,$F9,$00,$01,$A6,$14,$17,$7C,$00,$14,$00,$5E
	dc.b	$60,$00,$FF,$68,$4E,$75

puckfaceoff							;Puck assignment: the faceoff set up
; Code kept as bytes (decoded by decode_code.py).
	dc.b	$50,$F8,$D2,$38,$50,$F8,$D2,$3A,$50,$F8,$D2,$3C,$08,$B8,$00,$04
	dc.b	$C3,$4C,$08,$38,$00,$00,$C3,$48,$67,$00,$00,$14,$42,$78,$B7,$86
	dc.b	$42,$78,$B7,$88,$30,$3C,$00,$1E,$4E,$F9,$00,$01,$A3,$DA,$08,$AB
	dc.b	$00,$01,$00,$62,$67,$00,$02,$9A,$08,$B8,$00,$00,$C3,$4C,$67,$00
	dc.b	$00,$0A,$42,$78,$BF,$E2,$42,$78,$BF,$E4,$08,$B8,$00,$07,$C3,$4A
	dc.b	$42,$B8,$BE,$AE,$42,$B8,$BE,$B2,$42,$B8,$BE,$B6,$08,$B8,$00,$06
	dc.b	$C3,$4A,$08,$B8,$00,$02,$C3,$4A,$08,$F8,$00,$02,$C3,$56,$4E,$B9
	dc.b	$00,$1D,$90,$E2,$4A,$78,$D4,$7E,$6B,$00,$00,$0A,$30,$38,$D4,$7E
	dc.b	$60,$00,$00,$0E,$4E,$B9,$00,$1D,$90,$94,$4A,$40,$6B,$00,$00,$08
	dc.b	$4E,$B9,$00,$1D,$8A,$B4,$08,$B8,$00,$01,$C3,$46,$08,$B8,$00,$01
	dc.b	$C3,$48,$4A,$78,$C4,$BE,$67,$00,$02,$C8,$08,$38,$00,$06,$C3,$38
	dc.b	$66,$00,$02,$BE,$0C,$78,$00,$03,$C4,$BC,$66,$00,$00,$14,$30,$38
	dc.b	$C7,$32,$B0,$78,$CA,$D0,$67,$00,$00,$08,$4E,$F9,$00,$01,$4B,$DC
	dc.b	$08,$38,$00,$03,$C3,$38,$66,$00,$02,$9E,$30,$38,$C4,$C2,$E2,$40
	dc.b	$B0,$78,$C4,$BE,$63,$00,$00,$42,$0C,$78,$00,$3C,$C4,$BE,$6D,$00
	dc.b	$00,$38,$08,$B8,$00,$07,$C3,$3E,$67,$00,$00,$2E,$08,$38,$00,$00
	dc.b	$C3,$38,$67,$00,$00,$24,$08,$38,$00,$06,$C3,$4C,$66,$00,$00,$1A
	dc.b	$31,$F8,$C3,$A0,$D4,$8C,$31,$FC,$00,$02,$D4,$8E,$4E,$B9,$00,$08
	dc.b	$86,$88,$08,$F8,$00,$04,$C3,$4C,$4E,$B9,$00,$01,$97,$EA,$50,$EB
	dc.b	$00,$40,$50,$EB,$00,$42,$4A,$78,$D2,$64,$66,$00,$01,$94,$08,$B8
	dc.b	$00,$01,$C7,$56,$08,$B8,$00,$01,$CA,$F4,$30,$7C,$B0,$5E,$70,$0B
	dc.b	$08,$A8,$00,$03,$00,$63,$D0,$FC,$00,$80,$51,$C8,$FF,$F4,$30,$38
	dc.b	$C3,$90,$80,$78,$C3,$92,$67,$00,$00,$3A,$08,$38,$00,$07,$C3,$3A
	dc.b	$67,$00,$00,$30,$4E,$B9,$00,$01,$AF,$52,$08,$F8,$00,$06,$C3,$3A
	dc.b	$4E,$B9,$00,$01,$D0,$1E,$31,$FC,$00,$18,$BD,$3C,$4A,$78,$D2,$64
	dc.b	$66,$00,$00,$10,$08,$38,$00,$04,$C3,$4A,$67,$00,$00,$06,$42,$78
	dc.b	$BD,$3C,$30,$38,$C3,$84,$6B,$00,$00,$0A,$B0,$7C,$00,$06,$6D,$00
	dc.b	$00,$2E,$30,$38,$C3,$86,$6B,$00,$00,$0A,$B0,$7C,$00,$06,$6D,$00
	dc.b	$00,$1E,$30,$38,$C3,$88,$6B,$00,$00,$0A,$B0,$7C,$00,$06,$6D,$00
	dc.b	$00,$0E,$30,$38,$C3,$8A,$B0,$7C,$00,$06,$6C,$00,$00,$0C,$4A,$40
	dc.b	$6B,$00,$00,$06,$61,$00,$00,$9C,$30,$38,$C3,$84,$B0,$7C,$00,$06
	dc.b	$6C,$00,$00,$26,$30,$38,$C3,$86,$B0,$7C,$00,$06,$6C,$00,$00,$1A
	dc.b	$30,$38,$C3,$88,$B0,$7C,$00,$06,$6C,$00,$00,$0E,$30,$38,$C3,$8A
	dc.b	$B0,$7C,$00,$06,$6D,$00,$00,$0C,$4A,$40,$6B,$00,$00,$06,$61,$00
	dc.b	$00,$62,$32,$7C,$C7,$26,$45,$E9,$03,$9E,$70,$02,$4E,$B9,$00,$00
	dc.b	$9D,$0C,$60,$00,$00,$9C

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
; Code kept as bytes (decoded by decode_code.py).
	dc.b	$30,$3C,$00,$40,$4E,$B9,$00,$00,$9D,$E6,$30,$3C,$00,$42,$4E,$B9
	dc.b	$00,$00,$9D,$E6,$4A,$6B,$00,$40,$6A,$96,$4A,$6B,$00,$42,$6A,$90
	dc.b	$34,$7C,$C7,$26,$43,$EA,$03,$9E,$70,$01,$4E,$B9,$00,$00,$9D,$0C
	dc.b	$31,$FC,$FF,$FF,$D4,$88,$30,$3C,$00,$1C,$4E,$F9,$00,$01,$A3,$DA

UpdateFaceoffLineChangeTimer		;Line change timer d0 (temp1 / temp2 of the puck)
; Code kept as bytes (decoded by decode_code.py).
	dc.b	$4A,$73,$00,$00,$6B,$00,$FF,$6A,$32,$33,$00,$04,$EF,$41,$30,$7C
	dc.b	$B0,$5E,$34,$7C,$C7,$26,$08,$30,$00,$06,$10,$62,$67,$00,$00,$06
	dc.b	$D4,$FC,$03,$9E,$08,$30,$00,$03,$10,$63,$66,$00,$00,$0A,$50,$F3
	dc.b	$00,$00,$60,$00,$4E,$54,$9F,$73,$00,$00,$6A,$00,$FF,$34,$2F,$0B
	dc.b	$47,$F0,$10,$00,$08,$2B,$00,$03,$00,$63,$67,$00,$00,$10,$42,$42
	dc.b	$4E,$B9,$00,$00,$EE,$92,$4E,$B9,$00,$00,$EC,$6E,$26,$5F,$4E,$75
	dc.b	$4E,$F9,$00,$02,$15,$DC,$4E,$F9,$00,$01,$C7,$84

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
	clr.w	$28(a0)					;Xvel
	clr.w	$2A(a0)					;Yvel
	clr.w	(a0)					;Xpos
	move.w	#$122,$14(a0)
	adda.w	#SCstruct,a0			;add SCstruct to move to next goal net
	clr.w	$28(a0)
	clr.w	$2A(a0)
	clr.w	(a0)
	move.w	#$FEDE,$14(a0)
	movea.w	#(SortCords+((puckscnum+1)*SCstruct)-M68K_RAM),a0	;move to puck shadow SCnum
	move.w	#$299,6(a0)
	clr.w	$58(a0)					;SPA
	clr.w	4(a0)					;attribute
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
	move.b	weight(a3),$19(a2)
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

