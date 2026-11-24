;	Team graphics pointers. TeamBlockPtrs, TeamLogoPtrs and SmallLogoPtrs are one long per team.
;	VBlank_Menus is the front-end vertical blank handler, kept as bytes. rtsPlayoffOver is an rts.

TeamBlockPtrs						;The setup team block bitmap of each team, a long pointer per team
									;(DrawSetupTeamBlock)
	dc.l	TeamBlockANH,TeamBlockBOS,TeamBlockBUF,TeamBlockCGY
	dc.l	TeamBlockCHI,TeamBlockDAL,TeamBlockDET,TeamBlockEDM
	dc.l	TeamBlockFLA,TeamBlockHFD,TeamBlockLA,TeamBlockMTL
	dc.l	TeamBlockNJ,TeamBlockNYI,TeamBlockNYR,TeamBlockOTW
	dc.l	TeamBlockPHI,TeamBlockPIT,TeamBlockQUE,TeamBlockSJ
	dc.l	TeamBlockSTL,TeamBlockTB,TeamBlockTOR,TeamBlockVAN
	dc.l	TeamBlockWSH,TeamBlockWPG,TeamBlockWSH,TeamBlockWSH

TeamLogoPtrs						;The team logo bitmap of each team, a long pointer per team
									;(DrawTeamLogoD7)
	dc.l	TeamLogoANH,TeamLogoBOS,TeamLogoBUF,TeamLogoCGY
	dc.l	TeamLogoCHI,TeamLogoDAL,TeamLogoDET,TeamLogoEDM
	dc.l	TeamLogoFLA,TeamLogoHFD,TeamLogoLA,TeamLogoMTL
	dc.l	TeamLogoNJ,TeamLogoNYI,TeamLogoNYR,TeamLogoOTW
	dc.l	TeamLogoPHI,TeamLogoPIT,TeamLogoQUE,TeamLogoSJ
	dc.l	TeamLogoSTL,TeamLogoTB,TeamLogoTOR,TeamLogoVAN
	dc.l	TeamLogoWSH,TeamLogoWPG,TeamLogoCHI,TeamLogoCHI

SmallLogoPtrs						;The small team logo of each team, a long pointer per team (read by
									;StanleyCupScreen)
	dc.l	SmallLogoANH,SmallLogoBOS,SmallLogoBUF,SmallLogoCGY
	dc.l	SmallLogoCHI,SmallLogoDAL,SmallLogoDET,SmallLogoEDM
	dc.l	SmallLogoFLA,SmallLogoHFD,SmallLogoLA,SmallLogoMTL
	dc.l	SmallLogoNJ,SmallLogoNYI,SmallLogoNYR,SmallLogoOTW
	dc.l	SmallLogoPHI,SmallLogoPIT,SmallLogoQUE,SmallLogoSJ
	dc.l	SmallLogoSTL,SmallLogoTB,SmallLogoTOR,SmallLogoVAN
	dc.l	SmallLogoWSH,SmallLogoWPG

VBlank_Menus						;The front-end VBint (most menu screens): sprites (dfok), cramfade, the
									;menu background scroll, the music
	movem.l	d0-d7/a0-a6,-(sp)
	btst	#dfng,(disflags).w
	bne.w	.2
	bclr	#dfok,(disflags).w
	beq.w	.1
	jsr	(DumpSpriteTable).l
.1
	jsr	(cramfade).l
.2
	addq.w	#1,(Vcount).w
	bsr.w	SeasonMenuCountGoalie
	jsr	(p_music_vblank).l
	movem.l	(sp)+,d0-d7/a0-a6
	rte
SeasonMenuListByDay	equ	*
SeasonMenuListByDay	equ	*
	move.l	#$1313A,(menulist).l
	tst.w	(SeasonDay).w
	bne.w	.3
	move.l	#$13076,(menulist).l
.3
	btst	#0,(SeasonDay+2).w
	beq.w	.5
	btst	#2,(SeasonDay+2).w
	beq.w	.4
	move.l	#$13212,(menulist).l
	bra.w	.5
.4
	move.l	#$132D6,(menulist).l
.5
	btst	#1,(SeasonDay+2).w
	beq.w	.6
	move.l	#$12EA2,(menulist).l
.6
	clr.w	(menuitem).w
	clr.w	(menuitem+2).w
	move.w	#$17,(menux).w
	move.w	#7,(menuy).w
	rts
SeasonMenuListSixRows	equ	*	;Season menu: six rows; menulist by SeasonDay and the playoff flags
SeasonMenuListSixRows	equ	*	;Season menu: six rows; menulist by SeasonDay and the playoff flags
	move.w	#6,(menurows).w
	move.l	#$1313A,(menulist).l
	tst.w	(SeasonDay).w
	bne.w	.7
	move.l	#$13076,(menulist).l
.7
	btst	#2,(SeasonDay+2).w
	beq.w	.8
	move.l	#$13212,(menulist).l
	btst	#1,(SeasonDay+2).w
	beq.w	.8
	move.l	#$12EA2,(menulist).l
	bra.w	.11
.8
	move.w	(TeamSelectHome+2).l,d0
	cmp.b	(SeasonTeam+1).w,d0
	beq.w	.10
	bgt.w	.9
	move.l	#$12EA2,(menulist).l
	btst	#2,(SeasonDay+2).w
	beq.w	.10
	move.l	#$12F3E,(menulist).l
	bra.w	.10
.9
	move.l	#$12FC6,(menulist).l
.10
	btst	#0,(SeasonDay+2).w
	beq.w	.11
	btst	#2,(SeasonDay+2).w
	bne.w	.11
	move.l	#$132D6,(menulist).l
.11
	jsr	(PrintMenuList).l
	rts
	dc.w	$0006,$FE07,$F900,$0006,$FE07,$F901,$0010,$4E48
	dc.w	$4C20,$5354,$414E,$4449,$4E47,$5320,$0001,$3502
	dc.w	$0010,$5445,$414D,$2052,$4F53,$5445,$5220,$2020
	dc.w	$0001,$350E,$0010,$504C,$4159,$4552,$2053,$5441
	dc.w	$5453,$2020,$0001,$353E,$0010,$4C45,$4147,$5545
	dc.w	$204C,$4541,$4445,$5253,$0001,$3526,$0010,$5452
	dc.w	$414E,$5341,$4354,$494F,$4E53,$2020,$0001,$354A
	dc.w	$0010,$4741,$4D45,$204F,$5054,$494F,$4E53,$2020
	dc.w	$0001,$351A,$0010,$4558,$4954,$2053,$4541,$534F
	dc.w	$4E20,$2020,$0001,$34BE,$0004,$FF00,$0006,$FE07
	dc.w	$F900,$0006,$FE07,$F901,$0010,$4E48,$4C20,$5354
	dc.w	$414E,$4449,$4E47,$5320,$0001,$3502,$0010,$5445
	dc.w	$414D,$2052,$4F53,$5445,$5220,$2020,$0001,$350E
	dc.w	$0010,$504C,$4159,$4552,$2053,$5441,$5453,$2020
	dc.w	$0001,$353E,$0010,$4C45,$4147,$5545,$204C,$4541
	dc.w	$4445,$5253,$0001,$3526,$0010,$4741,$4D45,$204F
	dc.w	$5054,$494F,$4E53,$2020,$0001,$351A,$0010,$4558
	dc.w	$4954,$2053,$4541,$534F,$4E20,$2020,$0001,$34BE
	dc.w	$0004,$FF00,$0006,$FE07,$F900,$0006,$FE07,$F901
	dc.w	$0010,$5349,$4D55,$4C41,$5445,$2047,$414D,$4520
	dc.w	$0001,$33FE,$0010,$4E48,$4C20,$5354,$414E,$4449
	dc.w	$4E47,$5320,$0001,$3502,$0010,$5445,$414D,$2052
	dc.w	$4F53,$5445,$5220,$2020,$0001,$350E,$0010,$504C
	dc.w	$4159,$4552,$2053,$5441,$5453,$2020,$0001,$353E
	dc.w	$0010,$4C45,$4147,$5545,$204C,$4541,$4445,$5253
	dc.w	$0001,$3526,$0010,$5452,$414E,$5341,$4354,$494F
	dc.w	$4E53,$2020,$0001,$354A,$0010,$4741,$4D45,$204F
	dc.w	$5054,$494F,$4E53,$2020,$0001,$351A,$0010,$4558
	dc.w	$4954,$2053,$4541,$534F,$4E20,$2020,$0001,$34BE
	dc.w	$0004,$FF00,$0006,$FE07,$F900,$0006,$FE07,$F901
	dc.w	$0010,$504C,$4159,$2047,$414D,$4520,$2020,$2020
	dc.w	$0001,$33E4,$0010,$5349,$4D55,$4C41,$5445,$2047
	dc.w	$414D,$4520,$0001,$33FE,$0010,$4E48,$4C20,$5354
	dc.w	$414E,$4449,$4E47,$5320,$0001,$3502,$0010,$5445
	dc.w	$414D,$2052,$4F53,$5445,$5220,$2020,$0001,$350E
	dc.w	$0010,$504C,$4159,$4552,$2053,$5441,$5453,$2020
	dc.w	$0001,$353E,$0010,$4C45,$4147,$5545,$204C,$4541
	dc.w	$4445,$5253,$0001,$3526,$0010,$5452,$414E,$5341
	dc.w	$4354,$494F,$4E53,$2020,$0001,$354A,$0010,$4741
	dc.w	$4D45,$204F,$5054,$494F,$4E53,$2020,$0001,$351A
	dc.w	$0010,$4558,$4954,$2053,$4541,$534F,$4E20,$2020
	dc.w	$0001,$34BE,$0004,$FF00,$0006,$FE07,$F900,$0006
	dc.w	$FE07,$F901,$0010,$504C,$4159,$2047,$414D,$4520
	dc.w	$2020,$2020,$0001,$33E4,$0010,$5349,$4D55,$4C41
	dc.w	$5445,$2047,$414D,$4520,$0001,$33FE,$0010,$4E48
	dc.w	$4C20,$5354,$414E,$4449,$4E47,$5320,$0001,$3502
	dc.w	$0010,$5445,$414D,$2052,$4F53,$5445,$5220,$2020
	dc.w	$0001,$350E,$0010,$504C,$4159,$4552,$2053,$5441
	dc.w	$5453,$2020,$0001,$353E,$0010,$4C45,$4147,$5545
	dc.w	$204C,$4541,$4445,$5253,$0001,$3526,$0010,$5452
	dc.w	$414E,$5341,$4354,$494F,$4E53,$2020,$0001,$354A
	dc.w	$0010,$454E,$4420,$5345,$4153,$4F4E,$204E,$4F57
	dc.w	$0001,$34CC,$0010,$4741,$4D45,$204F,$5054,$494F
	dc.w	$4E53,$2020,$0001,$351A,$0010,$4558,$4954,$2053
	dc.w	$4541,$534F,$4E20,$2020,$0001,$34BE,$0004,$FF00
	dc.w	$0006,$FE07,$F900,$0006,$FE07,$F901,$0010,$504C
	dc.w	$4159,$2047,$414D,$4520,$2020,$2020,$0001,$33E4
	dc.w	$0010,$5349,$4D55,$4C41,$5445,$2047,$414D,$4520
	dc.w	$0001,$33FE,$0010,$4E48,$4C20,$5354,$414E,$4449
	dc.w	$4E47,$5320,$0001,$3502,$0010,$5445,$414D,$2052
	dc.w	$4F53,$5445,$5220,$2020,$0001,$350E,$0010,$504C
	dc.w	$4159,$4552,$2053,$5441,$5453,$2020,$0001,$353E
	dc.w	$0010,$4C45,$4147,$5545,$204C,$4541,$4445,$5253
	dc.w	$0001,$3526,$0010,$4741,$4D45,$204F,$5054,$494F
	dc.w	$4E53,$2020,$0001,$351A,$0010,$504C,$4159,$4F46
	dc.w	$4620,$5452,$4545,$2020,$0001,$3532,$0010,$4558
	dc.w	$4954,$2053,$4541,$534F,$4E20,$2020,$0001,$34BE
	dc.w	$0004,$FF00,$0006,$FE07,$F900,$0006,$FE07,$F901
	dc.w	$0010,$4245,$4749,$4E20,$504C,$4159,$4F46,$4653
	dc.w	$0001,$3354,$0010,$4E48,$4C20,$5354,$414E,$4449
	dc.w	$4E47,$5320,$0001,$3502,$0010,$504C,$4159,$4552
	dc.w	$2053,$5441,$5453,$2020,$0001,$353E,$0010,$4C45
	dc.w	$4147,$5545,$204C,$4541,$4445,$5253,$0001,$3526
	dc.w	$0010,$4558,$4954,$2053,$4541,$534F,$4E20,$2020
	dc.w	$0001,$34BE,$0004,$FF00,$21FC,$0001,$22A4,$DDAC
	dc.w	$4E75,$4EB9,$0001,$BA2E,$0008,$FF01,$FD15,$FC07
	dc.w	$303C,$0010,$323C,$0006,$343C,$07FF,$0042,$8000
	dc.w	$4EB9,$0001,$B976,$4EB9,$0001,$BA2E,$0066,$FE07
	dc.w	$F900,$FD15,$FC07,$2020,$2020,$2020,$2020,$2020
	dc.w	$2020,$FD15,$FA01,$2020,$504C,$4541,$5345,$2057
	dc.w	$4149,$5420,$2020,$FD15,$FA02,$3C3C,$3C3C,$3C3C
	dc.w	$4E4F,$5445,$3C3C,$3C3C,$3C3C,$FD15,$FA01,$5245
	dc.w	$5345,$5420,$5749,$4C4C,$2043,$4155,$5345,$FD15
	dc.w	$FA01,$4441,$5441,$2043,$4F52,$5255,$5054,$494F
	dc.w	$4E20,$4278,$DDB0,$4EB9,$0001,$149E,$4EB9,$0001
	dc.w	$14B8,$21FC,$0000,$0772,$DDAC,$4E75,$3039,$FFFF
	dc.w	$2722,$E740,$207C,$FFFF,$2726,$3030,$0002,$9078
	dc.w	$DD7E,$5240,$31C0,$DDB0,$4EB9,$0001,$BA2E,$0008
	dc.w	$FF01,$FD15,$FC07,$303C,$0010,$323C,$0006,$343C
	dc.w	$07FF,$0042,$8000,$4EB9,$0001,$B976,$4EB9,$0001
	dc.w	$BA2E,$006A,$FE07,$F900,$FD15,$FC07,$4741,$4D45
	dc.w	$2053,$494D,$554C,$4154,$494F,$4E20,$FD15,$FA01
	dc.w	$2020,$504C,$4541,$5345,$2057,$4149,$5420,$2020
	dc.w	$FD15,$FA02,$3C3C,$3C3C,$3C3C,$4E4F,$5445,$3C3C
	dc.w	$3C3C,$3C3C,$FD15,$FA01,$5245,$5345,$5420,$5749
	dc.w	$4C4C,$2043,$4155,$5345,$FD15,$FA01,$4441,$5441
	dc.w	$2043,$4F52,$5255,$5054,$494F,$4E20,$08B8,$0005
	dc.w	$C356,$21FC,$0000,$0772,$DDAC,$4E75,$08B8,$0007
	dc.w	$C350,$4EF9,$0002,$174A,$4E75,$08F8,$0000,$DD80
	dc.w	$08F8,$0000,$DD80,$08B8,$0001,$DD80,$08B8,$0002
	dc.w	$DD80,$6100,$DF98,$4278,$DDB0,$08B8,$0006,$C350
	dc.w	$4EB9,$0002,$41AA,$21FC,$0000,$0772,$DDAC,$4E75
	dc.w	$23FC,$001D,$99FA,$FFFF,$DDAC,$4E75,$23FC,$001E
	dc.w	$2EFC,$FFFF,$DDAC,$4E75,$23FC,$001D,$A050,$FFFF
	dc.w	$DDAC,$4E75,$23FC,$001D,$A722,$FFFF,$DDAC,$4E75
	dc.w	$23FC,$001E,$700A,$FFFF,$DDAC,$4E75,$23FC,$001D
	dc.w	$B020,$FFFF,$DDAC,$4E75,$23FC,$001D,$BBB2,$FFFF
	dc.w	$DDAC,$4E75

rtsPlayoffOver						;Empty return after EncodePW when the playoffs are over
	rts

