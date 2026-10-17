;	The create-player screen and the created-player list.

CreatePlayer	;The create player screen (roster menu item Create Players)
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$FF,$FE,$08,$B8,$00,$06,$C3,$56,$08,$B8,$00,$07,$C3,$58
	dc.b	$42,$40,$10,$39,$00,$20,$1B,$B9,$B0,$7C,$00,$14,$6D,$00,$00,$08
	dc.b	$08,$F8,$00,$07,$C3,$58

.redraw	;Redraw the create screen: reset the field row and the mode, read and draw the name list
	;Code the listing does not decode: kept as bytes
	dc.b	$42,$78,$D4,$84,$42,$78,$D4,$86,$42,$78,$D3,$12,$61,$00,$09,$D0
	dc.b	$20,$7C,$00,$19,$4C,$48,$4E,$B9,$00,$01,$21,$8A,$4E,$B9,$00,$1D
	dc.b	$BB,$92,$31,$FC,$00,$18,$BD,$3C,$08,$B8,$00,$02,$BF,$B2,$61,$00
	dc.b	$0B,$52,$4A,$79,$FF,$FF,$55,$F0,$66,$00,$00,$14,$08,$F8,$00,$06
	dc.b	$C3,$56,$33,$FC,$00,$01,$FF,$FF,$55,$F0,$60,$00,$00,$42,$42,$78
	dc.b	$D3,$C4,$31,$FC,$00,$01,$D3,$C2,$30,$39,$FF,$FF,$55,$F0,$53,$40
	dc.b	$33,$C0,$FF,$FF,$55,$F8,$55,$40,$6A,$00,$00,$04,$42,$40,$33,$C0
	dc.b	$FF,$FF,$55,$F4,$30,$39,$FF,$FF,$55,$F8,$52,$40,$31,$C0,$D3,$C2
	dc.b	$22,$7C,$FF,$FF,$D3,$AC,$61,$00,$09,$00,$61,$00,$08,$82,$61,$00
	dc.b	$05,$E2,$42,$44,$42,$78,$D4,$84,$42,$78,$D4,$86,$42,$40,$60,$00
	dc.b	$03,$A0,$61,$00,$0B,$DA,$46,$FC,$25,$00,$30,$38,$B0,$52,$B0,$78
	dc.b	$B0,$52,$67,$FA,$4E,$B9,$00,$01,$26,$40,$4E,$B9,$00,$01,$B2,$82
	dc.b	$4E,$B9,$00,$01,$B3,$20,$4A,$41,$67,$E0,$08,$38,$00,$07,$C3,$58
	dc.b	$66,$00,$00,$0C,$08,$38,$00,$06,$C3,$56,$67,$00,$00,$0C,$08,$01
	dc.b	$00,$07,$67,$C6,$60,$00,$03,$F2,$4A,$78,$D4,$84,$66,$00,$00,$3C
	dc.b	$30,$3C,$00,$01,$08,$01,$00,$01,$66,$00,$02,$AA,$30,$3C,$FF,$FF
	dc.b	$08,$01,$00,$00,$66,$00,$02,$9E,$08,$01,$00,$06,$67,$00,$00,$10
	dc.b	$42,$44,$42,$45,$61,$00,$03,$C8,$42,$40,$60,$00,$02,$88,$08,$01
	dc.b	$00,$04,$66,$00,$03,$B4,$60,$00,$FF,$7A,$20,$7C,$00,$1D,$DA,$78
	dc.b	$30,$38,$D4,$86,$E5,$40,$20,$70,$00,$00,$4E,$D0

.fieldjumps	;Field routine of each create row, then: next field, after the last one finish the name
	dc.l	.namefield,.posfield,.handfield,.weightfield,.jerseyfield
	dc.b	$52,$78,$D4,$86,$0C,$78,$00,$05,$D4,$86,$6D,$00,$FF,$46,$4E,$F9
	dc.b	$00,$1D,$DD,$F0

.posfield	;Position field: left / right change the position slot 0-5
	;Code the listing does not decode: kept as bytes
	dc.b	$08,$01,$00,$07,$66,$E6,$08,$01,$00,$04,$66,$00,$03,$68,$08,$01
	dc.b	$00,$02,$67,$00,$00,$1A,$10,$39,$FF,$FF,$56,$08,$48,$80,$53,$40
	dc.b	$6B,$00,$FF,$24,$13,$C0,$FF,$FF,$56,$08,$60,$00,$FF,$12,$08,$01
	dc.b	$00,$03,$67,$00,$FF,$12,$10,$39,$FF,$FF,$56,$08,$48,$80,$52,$40
	dc.b	$B0,$7C,$00,$05,$6E,$00,$FF,$00,$13,$C0,$FF,$FF,$56,$08,$60,$00
	dc.b	$FE,$EE

.handfield	;Hand field: left / right toggle the shooting hand
	;Code the listing does not decode: kept as bytes
	dc.b	$08,$01,$00,$07,$66,$94,$08,$01,$00,$04,$66,$00,$03,$16,$08,$01
	dc.b	$00,$02,$67,$00,$00,$0E,$0A,$39,$00,$01,$FF,$FF,$56,$04,$60,$00
	dc.b	$FE,$CC,$08,$01,$00,$03,$67,$00,$FE,$CC,$60,$EA

.weightfield	;Weight field: left / right change the weight
	;Code the listing does not decode: kept as bytes
	dc.b	$08,$01,$00,$07,$66,$00,$FF,$68,$08,$01,$00,$04,$66,$00,$02,$E8
	dc.b	$08,$01,$00,$02,$67,$00,$00,$2C,$10,$39,$FF,$FF,$56,$01,$E8,$48
	dc.b	$02,$40,$00,$0F,$67,$00,$FE,$A2,$53,$00,$E9,$08,$02,$40,$00,$F0
	dc.b	$02,$39,$00,$0F,$FF,$FF,$56,$01,$81,$39,$FF,$FF,$56,$01,$60,$00
	dc.b	$FE,$80,$08,$01,$00,$03,$67,$00,$FE,$80,$10,$39,$FF,$FF,$56,$01
	dc.b	$E8,$48,$02,$40,$00,$0F,$B0,$7C,$00,$0F,$67,$00,$FE,$6C,$52,$00
	dc.b	$60,$C8

.jerseyfield	;Jersey field: left / right change the BCD jersey number
	;Code the listing does not decode: kept as bytes
	dc.b	$08,$01,$00,$07,$66,$00,$FF,$06,$08,$01,$00,$04,$66,$00,$02,$86
	dc.b	$08,$01,$00,$02,$67,$00,$00,$2E,$10,$39,$FF,$FF,$56,$00,$67,$00
	dc.b	$FE,$46,$12,$00,$02,$41,$00,$0F,$66,$00,$00,$0E,$04,$00,$00,$10
	dc.b	$00,$00,$00,$09,$60,$00,$00,$04,$53,$00,$13,$C0,$FF,$FF,$56,$00
	dc.b	$60,$00,$FE,$1C,$08,$01,$00,$03,$67,$00,$FE,$1C,$10,$39,$FF,$FF
	dc.b	$56,$00,$B0,$3C,$00,$99,$67,$00,$FE,$0E,$12,$00,$02,$41,$00,$0F
	dc.b	$B2,$3C,$00,$09,$66,$00,$00,$0C,$06,$00,$00,$10,$02,$00,$00,$F0
	dc.b	$60,$C8,$52,$00,$60,$C4

.namefield	;Name field: the pads edit the name (grid), start checks it (BuildEnteredName) and goes to the next field
	;Code the listing does not decode: kept as bytes
	dc.b	$70,$FF,$08,$01,$00,$07,$67,$00,$00,$9E,$61,$00,$0C,$B8,$6B,$00
	dc.b	$00,$34,$61,$00,$02,$FA,$4E,$B9,$00,$01,$BA,$2E,$00,$24,$FE,$07
	dc.b	$FF,$01,$FD,$18,$FC,$13,$5B,$5D,$2D,$73,$65,$6C,$65,$63,$74,$69
	dc.b	$6F,$6E,$FD,$18,$FA,$01,$73,$74,$61,$72,$74,$3D,$6E,$65,$78,$74
	dc.b	$60,$00,$FE,$54,$61,$00,$02,$A8,$4E,$B9,$00,$01,$BA,$2E,$00,$38
	dc.b	$FE,$07,$FF,$01,$FD,$18,$FC,$13,$62,$61,$64,$20,$6E,$61,$6D,$65
	dc.b	$20,$65,$6E,$74,$72,$79,$2E,$FD,$18,$FA,$01,$61,$6E,$79,$20,$62
	dc.b	$75,$74,$74,$6F,$6E,$FD,$18,$FA,$01,$74,$6F,$20,$63,$6F,$6E,$74
	dc.b	$69,$6E,$75,$65,$2E,$00,$61,$00,$F0,$0C,$4E,$B9,$00,$01,$B2,$82
	dc.b	$4E,$B9,$00,$01,$B3,$20,$4A,$41,$67,$EC,$61,$00,$02,$52,$61,$00
	dc.b	$02,$8E,$60,$00,$FD,$44,$08,$01,$00,$06,$66,$00,$00,$DA,$44,$40
	dc.b	$08,$01,$00,$05,$66,$00,$00,$D0,$08,$01,$00,$03,$66,$00,$00,$F2
	dc.b	$44,$40,$08,$01,$00,$02,$66,$00,$00,$E8,$70,$0A,$08,$01,$00,$01
	dc.b	$66,$00,$00,$DE,$44,$40,$08,$01,$00,$00,$66,$00,$00,$D4,$08,$01
	dc.b	$00,$04,$67,$00,$FD,$04,$60,$00,$01,$36

CreateListMove	;CreatePlayer: move in the name list
	;Code the listing does not decode: kept as bytes
	dc.b	$D1,$78,$D3,$C2,$32,$38,$D3,$C2,$B2,$79,$FF,$FF,$55,$F0,$6F,$00
	dc.b	$00,$06,$91,$78,$D3,$C2,$4A,$78,$D3,$C2,$66,$00,$00,$06,$91,$78
	dc.b	$D3,$C2,$30,$38,$D3,$C2,$53,$40,$B0,$79,$FF,$FF,$55,$F4,$6C,$00
	dc.b	$00,$12,$53,$79,$FF,$FF,$55,$F4,$53,$79,$FF,$FF,$55,$F8,$61,$00
	dc.b	$02,$8E,$B0,$79,$FF,$FF,$55,$F8,$6F,$00,$00,$12,$52,$79,$FF,$FF
	dc.b	$55,$F4,$52,$79,$FF,$FF,$55,$F8,$61,$00,$02,$74,$22,$7C,$FF,$FF
	dc.b	$D3,$AC,$61,$00,$05,$80,$61,$00,$05,$02,$4A,$78,$D4,$84,$66,$00
	dc.b	$00,$06,$60,$00,$FC,$8A,$4E,$B9,$00,$01,$BC,$72,$00,$06,$8F,$01
	dc.b	$0C,$00,$D9,$78,$B0,$40,$4E,$B9,$00,$01,$BC,$72,$00,$04,$20,$00
	dc.b	$61,$00,$01,$1A,$30,$04,$44,$40,$60,$00,$00,$02,$D0,$44,$B0,$7C
	dc.b	$00,$11,$62,$00,$FC,$5A,$38,$00,$20,$7C,$FF,$FF,$D3,$AC,$42,$40
	dc.b	$0C,$30,$00,$2D,$40,$00,$67,$00,$00,$0E,$10,$30,$40,$00,$48,$80
	dc.b	$61,$00,$01,$18,$90,$45,$D0,$45,$B0,$7C,$00,$1D,$62,$00,$FC,$30
	dc.b	$3F,$00,$61,$00,$00,$B4,$4E,$B9,$00,$01,$BA,$2E,$00,$04,$FE,$07
	dc.b	$74,$01,$61,$00,$00,$7A,$3A,$1F,$61,$00,$00,$9E,$4A,$78,$D4,$84
	dc.b	$67,$00,$00,$02,$61,$00,$00,$68,$20,$7C,$FF,$FF,$D3,$AC,$22,$7C
	dc.b	$00,$1E,$6B,$04,$10,$31,$50,$00,$11,$80,$40,$00,$60,$00,$FB,$F0

CreateNameDone	;All fields done: SaveCreateName (fail: redraw), InitCreateRecord, the checksum, then ModifyRatings
	;Code the listing does not decode: kept as bytes
	dc.b	$61,$00,$09,$82,$6B,$00,$00,$18,$61,$00,$0B,$92,$08,$B8,$00,$06
	dc.b	$C3,$50,$4E,$B9,$00,$02,$41,$AA,$4E,$F9,$00,$1D,$EA,$5A,$4E,$F9
	dc.b	$00,$1D,$D9,$3C,$4C,$DF,$7F,$FF,$4E,$75,$48,$E7,$FF,$FE,$08,$78
	dc.b	$00,$00,$D4,$85,$66,$00,$00,$0C,$61,$00,$01,$42,$4C,$DF,$7F,$FF
	dc.b	$4E,$75,$22,$7C,$FF,$FF,$D3,$AC,$61,$00,$04,$8A,$60,$EE

PrintGridLetter	;If grid mode, print letter d5 of the grid table (cursor letter)
	;Code the listing does not decode: kept as bytes
	dc.b	$4A,$78,$D4,$84,$67,$D4,$22,$7C,$FF,$FF,$D1,$30,$32,$BC,$00,$04
	dc.b	$13,$7C,$00,$00,$00,$03,$20,$7C,$00,$1E,$6B,$04,$10,$30,$50,$00
	dc.b	$13,$40,$00,$02,$4E,$F9,$00,$01,$BC,$84,$4E,$B9,$00,$01,$BC,$72
	dc.b	$00,$06,$AF,$1A,$0F,$00,$30,$05,$48,$C0,$80,$FC,$00,$0A,$D1,$78
	dc.b	$B0,$42,$48,$40,$D1,$78,$B0,$40,$70,$01,$72,$01,$4E,$75

FixFirstLetter	;Normalize first letter of name buffer to a letter grid char (unknown -> A)
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$F8,$FE,$10,$38,$D3,$AC,$61,$00,$00,$24,$B0,$7C,$00,$1E
	dc.b	$6D,$00,$00,$08,$42,$45,$60,$00,$00,$10,$3A,$00,$20,$7C,$00,$1E
	dc.b	$6B,$04,$11,$F0,$50,$00,$D3,$AC,$4C,$DF,$7F,$1F,$4E,$75

FindGridLetter	;Find char d0 in letter grid table, return index in d0 ($1E if not found)
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$70,$FE,$20,$7C,$00,$1E,$6B,$04,$12,$00,$42,$40,$36,$3C
	dc.b	$00,$1E,$B2,$30,$00,$00,$67,$00,$00,$0C,$52,$40,$51,$CB,$FF,$F4
	dc.b	$30,$3C,$00,$1E,$4C,$DF,$7F,$0E,$4E,$75,$4E,$B9,$00,$01,$BB,$8E
	dc.b	$00,$06,$8F,$17,$13,$00,$30,$3C,$00,$10,$32,$3C,$00,$04,$34,$3C
	dc.b	$07,$FF,$4E,$B9,$00,$01,$B9,$76,$4E,$75,$4E,$B9,$00,$01,$BB,$8E
	dc.b	$00,$06,$8F,$17,$0D,$00,$30,$3C,$00,$10,$32,$3C,$00,$0A,$34,$3C
	dc.b	$07,$FF,$4E,$B9,$00,$01,$B9,$76,$4E,$75,$4E,$B9,$00,$01,$BA,$2E
	dc.b	$00,$40,$FE,$07,$FF,$01,$FD,$18,$FC,$13,$61,$3D,$67,$6F,$20,$62
	dc.b	$61,$63,$6B,$FD,$18,$FA,$01,$62,$3D,$63,$61,$6E,$63,$65,$6C,$FD
	dc.b	$18,$FA,$01,$63,$3D,$65,$6E,$74,$65,$72,$20,$6C,$65,$74,$74,$65
	dc.b	$72,$FD,$18,$FA,$01,$73,$74,$61,$72,$74,$3D,$64,$6F,$6E,$65,$00
	dc.b	$4E,$75,$61,$B6,$4E,$B9,$00,$01,$BC,$72,$00,$06,$8F,$1A,$0F,$00
	dc.b	$20,$7C,$00,$1E,$6B,$04,$70,$02,$72,$09,$22,$7C,$FF,$FF,$BF,$F2
	dc.b	$32,$FC,$00,$0C,$12,$D8,$51,$C9,$FF,$FC,$32,$7C,$BF,$F2,$4E,$B9
	dc.b	$00,$01,$BC,$84,$52,$78,$B0,$42,$04,$78,$00,$0A,$B0,$40,$51,$C8
	dc.b	$FF,$D8,$4E,$75,$48,$E7,$FF,$FE,$08,$38,$00,$07,$C3,$58,$66,$00
	dc.b	$00,$56,$08,$38,$00,$06,$C3,$56,$67,$00,$00,$96,$4E,$B9,$00,$01
	dc.b	$BC,$72,$00,$40,$8F,$13,$06,$6D,$61,$78,$69,$6D,$75,$6D,$20,$6E
	dc.b	$75,$6D,$62,$65,$72,$20,$6F,$66,$8F,$12,$07,$63,$72,$65,$61,$74
	dc.b	$65,$64,$20,$70,$6C,$61,$79,$65,$72,$73,$2E,$8F,$11,$08,$70,$72
	dc.b	$65,$73,$73,$20,$73,$74,$61,$72,$74,$20,$74,$6F,$20,$65,$78,$69
	dc.b	$74,$2E,$60,$00,$00,$AC,$4E,$B9,$00,$01,$BC,$72,$00,$40,$8F,$13
	dc.b	$06,$6D,$61,$78,$69,$6D,$75,$6D,$20,$6E,$75,$6D,$62,$65,$72,$20
	dc.b	$6F,$66,$8F,$12,$07,$66,$72,$65,$65,$20,$61,$67,$65,$6E,$74,$73
	dc.b	$2E,$20,$20,$20,$20,$8F,$11,$08,$70,$72,$65,$73,$73,$20,$73,$74
	dc.b	$61,$72,$74,$20,$74,$6F,$20,$65,$78,$69,$74,$2E

DrawCreateList	;Draw list of up to 6 player names starting at player CreateListTop
	;Code the listing does not decode: kept as bytes
	dc.b	$60,$00,$00,$62,$3F,$38,$D3,$C0,$3F,$38,$D3,$C2,$4E,$B9,$00,$01
	dc.b	$BC,$72,$00,$06,$8F,$13,$06,$00,$3E,$3C,$00,$03,$BE,$79,$FF,$FF
	dc.b	$55,$F0,$6D,$00,$00,$08,$3E,$39,$FF,$FF,$55,$F0,$53,$47,$31,$F9
	dc.b	$FF,$FF,$55,$F4,$D3,$C2,$52,$78,$D3,$C2,$22,$7C,$FF,$FF,$BF,$54
	dc.b	$61,$00,$02,$2C,$3F,$38,$B0,$40,$61,$00,$00,$E0,$31,$DF,$B0,$40
	dc.b	$52,$78,$B0,$42,$52,$78,$D3,$C2,$51,$CF,$FF,$E6,$31,$DF,$D3,$C2
	dc.b	$31,$DF,$D3,$C0,$4C,$DF,$7F,$FF,$4E,$75,$48,$E7,$FF,$FE,$08,$38
	dc.b	$00,$06,$C3,$56,$66,$00,$00,$2C,$08,$38,$00,$07,$C3,$58

MoveListMarkers	;Move selection arrows to the current list row if it changed
	;Code the listing does not decode: kept as bytes
	dc.b	$66,$00,$00,$22,$30,$38,$D3,$C2,$B0,$78,$D3,$C4,$67,$00,$00,$16
	dc.b	$22,$7C,$00,$1D,$E1,$44,$61,$00,$00,$12,$22,$7C,$00,$1D,$E1,$3C
	dc.b	$61,$00,$00,$08,$4C,$DF,$7F,$FF,$4E,$75,$4A,$78,$D3,$C4,$67,$00
	dc.b	$00,$30,$4E,$B9,$00,$01,$BC,$72,$00,$06,$8F,$13,$06,$00,$30,$38
	dc.b	$D3,$C4,$53,$40,$90,$79,$FF,$FF,$55,$F4,$D1,$78,$B0,$42,$2F,$09
	dc.b	$22,$5F,$D2,$D1,$31,$FC,$00,$26,$B0,$40,$4E,$B9,$00,$01,$BC,$84
	dc.b	$31,$F8,$D3,$C2,$D3,$C4,$4E,$75

ListMarkers	;Row markers ] and [
	String	']'
	String	'['

ListMarkersOff	;Blanks over the row markers
	String	' '
	String	' '

CountNameLength	;Count name length of name buffer NameEntryBuf into NameEntryLen
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$FF,$FE,$36,$3C,$00,$11,$20,$7C,$FF,$FF,$D3,$AC,$42,$78
	dc.b	$D3,$C0,$0C,$10,$00,$2D,$66,$00,$00,$08,$4A,$18,$60,$00,$00,$0C
	dc.b	$4A,$18,$67,$00,$00,$0A,$52,$78,$D3,$C0,$51,$CB,$FF,$E6,$4C,$DF
	dc.b	$7F,$FF,$4E,$75

PrintEditName	;Print 18-char name from a1 with - padding, highlight cursor char d4 in grid mode
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$FF,$FE,$3F,$38,$D3,$C0,$31,$FC,$00,$12,$D3,$C0,$20,$7C
	dc.b	$FF,$FF,$D1,$30,$30,$38,$D3,$C0,$36,$3C,$00,$00,$30,$FC,$00,$16
	dc.b	$B6,$7C,$00,$08,$66,$00,$00,$06,$10,$FC,$00,$20,$12,$31,$30,$00
	dc.b	$B6,$78,$D3,$C0,$6D,$00,$00,$06,$12,$3C,$00,$2D,$B2,$3C,$00,$20
	dc.b	$66,$00,$00,$06,$12,$3C,$00,$2D,$10,$C1,$52,$43,$B6,$7C,$00,$12
	dc.b	$6D,$CE,$22,$7C,$FF,$FF,$D1,$30,$13,$7C,$00,$20,$00,$15,$3E,$38
	dc.b	$B0,$40,$2F,$09,$4E,$B9,$00,$01,$BC,$84,$22,$5F,$4A,$78,$D4,$84
	dc.b	$67,$00,$00,$4E,$D2,$C4,$B8,$7C,$00,$08,$6D,$00,$00,$04,$52,$49
	dc.b	$54,$49,$20,$7C,$FF,$FF,$BF,$54,$30,$BC,$00,$04,$11,$51,$00,$02
	dc.b	$42,$28,$00,$03,$22,$48,$4E,$B9,$00,$01,$BA,$2E,$00,$04,$FE,$07
	dc.b	$DE,$44,$B8,$7C,$00,$08,$6D,$00,$00,$04,$52,$47,$31,$C7,$B0,$40
	dc.b	$4E,$B9,$00,$01,$BA,$40,$4E,$B9,$00,$01,$BA,$2E,$00,$04,$FE,$05
	dc.b	$31,$DF,$D3,$C0,$4C,$DF,$7F,$FF,$4E,$75,$48,$E7,$FF,$FE,$32,$38
	dc.b	$D3,$C2,$53,$41,$D2,$41,$20,$7C,$FF,$FF,$4E,$20,$32,$30,$10,$00
	dc.b	$6B,$00,$00,$4E,$02,$41,$00,$FF,$EB,$41,$48,$C1,$20,$3C,$00,$00
	dc.b	$12,$CE,$D0,$81,$72,$20,$20,$7C,$FF,$FF,$56,$00,$4E,$B9,$00,$02
	dc.b	$41,$E8,$20,$7C,$FF,$FF,$56,$00,$D0,$D0,$B1,$FC,$FF,$FF,$56,$00
	dc.b	$67,$00,$00,$18,$23,$D0,$FF,$FF,$56,$00,$23,$E8,$00,$04,$FF,$FF
	dc.b	$56,$04,$13,$E8,$00,$08,$FF,$FF,$56,$08,$4C,$DF,$7F,$FF,$4E,$75
	dc.b	$42,$B9,$FF,$FF,$56,$00,$42,$B9,$FF,$FF,$56,$04,$42,$39,$FF,$FF
	dc.b	$56,$08,$60,$E6

GetCreateName	;Copy player name (CreateListRow-1)*18 from M68K_RAM to a1, 0->-, length to NameEntryLen
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$FF,$FE,$20,$7C,$FF,$FF,$00,$00,$34,$38,$D3,$C2,$53,$42
	dc.b	$C4,$FC,$00,$12,$31,$FC,$00,$00,$D3,$C0,$36,$3C,$00,$11,$10,$30
	dc.b	$20,$00,$67,$00,$00,$06,$60,$00,$00,$10,$10,$3C,$00,$2D,$53,$78
	dc.b	$D3,$C0,$12,$C0,$60,$00,$00,$10,$B0,$3C,$00,$2D,$66,$00,$00,$06
	dc.b	$10,$3C,$00,$20,$12,$C0,$52,$78,$D3,$C0,$52,$42,$51,$CB,$FF,$D0
	dc.b	$4C,$DF,$7F,$FF,$4E,$75,$08,$F8,$00,$05,$C3,$56,$21,$FC,$00,$01
	dc.b	$2D,$46,$D2,$44,$08,$B8,$00,$00,$BF,$B2,$08,$F8,$00,$02,$BF,$B2
	dc.b	$08,$B8,$00,$01,$BF,$B2,$31,$FC,$00,$00,$B0,$00,$31,$FC,$B4,$00
	dc.b	$B0,$02,$31,$FC,$B8,$00,$B0,$0C,$31,$FC,$00,$05,$B0,$0E,$31,$FC
	dc.b	$C0,$00,$B0,$08,$31,$FC,$00,$06,$B0,$0A,$31,$FC,$E0,$00,$B0,$04
	dc.b	$31,$FC,$00,$06,$B0,$06,$30,$3C,$00,$00,$08,$F8,$00,$05,$BF,$B2
	dc.b	$4E,$B9,$00,$01,$B5,$7E,$08,$B8,$00,$05,$BF,$B2,$4E,$B9,$00,$01
	dc.b	$B2,$C4,$38,$3C,$00,$01,$22,$7C,$00,$19,$4C,$48,$4E,$B9,$00,$01
	dc.b	$21,$7A,$31,$C4,$B0,$1C,$24,$7C,$00,$17,$91,$70,$4E,$B9,$00,$01
	dc.b	$B7,$30,$31,$C4,$B0,$1E,$24,$7C,$00,$17,$A1,$6C,$4E,$B9,$00,$01
	dc.b	$B7,$30,$21,$FC,$00,$17,$91,$68,$BF,$8A,$4E,$B9,$00,$01,$BA,$2E
	dc.b	$00,$08,$FF,$01,$FD,$00,$FC,$00,$70,$28,$72,$1C,$34,$3C,$07,$FF
	dc.b	$4E,$B9,$00,$01,$B9,$76,$4E,$B9,$00,$01,$BC,$72,$00,$06,$BF,$00
	dc.b	$00,$00,$20,$7C,$00,$19,$32,$1A,$22,$48,$24,$48,$D1,$DA,$D3,$DA
	dc.b	$42,$40,$42,$41,$74,$28,$76,$1C,$7A,$08,$4E,$B9,$00,$01,$B6,$92
	dc.b	$4E,$B9,$00,$01,$BC,$72,$00,$06,$BF,$0B,$01,$00,$20,$7C,$00,$19
	dc.b	$29,$FA,$22,$48,$24,$48,$D1,$DA,$D3,$DA,$42,$40,$42,$41,$34,$11
	dc.b	$36,$29,$00,$02,$7A,$08,$4E,$B9,$00,$01,$B6,$92,$4E,$B9,$00,$01
	dc.b	$BC,$72,$00,$06,$FE,$00,$00,$00,$20,$7C,$00,$17,$3C,$7A,$22,$48
	dc.b	$24,$48,$D1,$DA,$D3,$DA,$42,$40,$42,$41,$74,$40,$76,$1C,$7A,$01
	dc.b	$4E,$B9,$00,$01,$B6,$92,$3F,$38,$B0,$1C,$31,$F8,$B0,$1E,$B0,$1C
	dc.b	$08,$38,$00,$07,$C3,$58,$66,$00,$00,$0C,$08,$38,$00,$06,$C3,$56
	dc.b	$67,$00,$00,$1C,$4E,$B9,$00,$01,$BC,$72,$00,$10,$8F,$03,$07,$53
	dc.b	$54,$41,$52,$54,$2D,$45,$58,$49,$54,$00,$60,$00,$00,$24,$4E,$B9
	dc.b	$00,$01,$BC,$72,$00,$1C,$8F,$03,$07,$41,$2D,$65,$64,$69,$74,$20
	dc.b	$73,$6C,$6F,$74,$8F,$03,$08,$42,$2D,$63,$61,$6E,$63,$65,$6C,$00
	dc.b	$31,$DF,$B0,$1C,$46,$FC,$25,$00,$4E,$75

ReadCreatedPlayers	;Read the created players from save RAM into name records and ids
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$FF,$FE,$42,$79,$FF,$FF,$55,$F0,$20,$7C,$FF,$FF,$13,$88
	dc.b	$20,$3C,$00,$00,$0D,$B4,$72,$28,$4E,$B9,$00,$02,$41,$E8,$3C,$3C
	dc.b	$00,$14,$26,$7C,$FF,$FF,$4E,$20,$24,$7C,$FF,$FF,$00,$00,$3A,$3C
	dc.b	$FF,$FF,$60,$00,$00,$36,$4A,$58,$6B,$00,$00,$30,$30,$28,$FF,$FE
	dc.b	$02,$40,$1F,$00,$B0,$7C,$1E,$00,$66,$00,$00,$20,$30,$28,$FF,$FE
	dc.b	$4E,$B9,$00,$01,$01,$DC,$61,$00,$00,$52,$D4,$FC,$00,$12,$30,$28
	dc.b	$FF,$FE,$36,$C0,$52,$79,$FF,$FF,$55,$F0,$52,$45,$51,$CE,$FF,$C8
	dc.b	$0C,$79,$00,$14,$FF,$FF,$55,$F0,$6C,$00,$00,$2A,$30,$39,$00,$20
	dc.b	$2A,$9C,$02,$40,$00,$FF,$B0,$3C,$00,$13,$6C,$00,$00,$18,$30,$3C
	dc.b	$00,$11,$14,$FC,$00,$00,$51,$C8,$FF,$FA,$36,$BC,$80,$00,$52,$79
	dc.b	$FF,$FF,$55,$F0,$4C,$DF,$7F,$FF,$4E,$75

FormatNameRecord	;Format name string at a1 into an 18-byte record at a2: first name padded to 8 and last name to 10 with dashes
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$FF,$60,$3E,$19,$57,$47,$3C,$3C,$00,$07,$0C,$11,$00,$20
	dc.b	$67,$00,$00,$0C,$10,$19,$14,$C0,$53,$47,$51,$CE,$FF,$F0,$4A,$46
	dc.b	$6B,$00,$00,$0A,$14,$FC,$00,$2D,$51,$CE,$FF,$FA,$52,$49,$53,$47
	dc.b	$3C,$3C,$00,$09,$10,$19,$14,$C0,$53,$46,$51,$CF,$FF,$F8,$4A,$46
	dc.b	$6B,$00,$00,$0A,$14,$FC,$00,$2D,$51,$CE,$FF,$FA,$4C,$DF,$06,$FF
	dc.b	$4E,$75,$61,$00,$FB,$90,$4E,$B9,$00,$01,$BC,$72,$00,$06,$8F,$14
	dc.b	$05,$00,$4A,$78,$D4,$84,$67,$00,$01,$76,$4E,$B9,$00,$01,$BC,$72
	dc.b	$00,$06,$8F,$01,$0C,$00,$30,$3C,$00,$00,$61,$00,$01,$46,$4E,$B9
	dc.b	$00,$01,$BC,$72,$00,$0C,$46,$75,$6C,$6C,$20,$4E,$61,$6D,$65,$3A
	dc.b	$31,$FC,$00,$01,$B0,$40,$52,$78,$B0,$42,$22,$7C,$FF,$FF,$D3,$AC
	dc.b	$61,$00,$FB,$76,$31,$FC,$00,$01,$B0,$40,$54,$78,$B0,$42,$30,$3C
	dc.b	$00,$01,$61,$00,$01,$0E,$4E,$B9,$00,$01,$BA,$2E,$00,$10,$F9,$00
	dc.b	$70,$6F,$73,$69,$74,$69,$6F,$6E,$3A,$FD,$0E,$00,$10,$39,$FF,$FF
	dc.b	$56,$08,$48,$80,$22,$7C,$00,$1D,$E7,$4C,$4E,$B9,$00,$01,$D7,$F2
	dc.b	$4E,$B9,$00,$01,$BC,$84,$31,$FC,$00,$01,$B0,$40,$54,$78,$B0,$42
	dc.b	$30,$3C,$00,$02,$61,$00,$00,$CC,$4E,$B9,$00,$01,$BA,$2E,$00,$10
	dc.b	$68,$61,$6E,$64,$65,$64,$6E,$65,$73,$73,$3A,$FD,$0E,$00,$10,$39
	dc.b	$FF,$FF,$56,$04,$02,$40,$00,$01,$22,$7C,$00,$1D,$E7,$64,$4E,$B9
	dc.b	$00,$01,$D7,$F2,$4E,$B9,$00,$01,$BC,$84,$31,$FC,$00,$01,$B0,$40
	dc.b	$54,$78,$B0,$42,$30,$3C,$00,$03,$61,$00,$00,$88,$4E,$B9,$00,$01
	dc.b	$BA,$2E,$00,$10,$77,$65,$69,$67,$68,$74,$3A,$FD,$0E,$20,$20,$20
	dc.b	$FD,$0E,$10,$39,$FF,$FF,$56,$01,$E8,$48,$02,$40,$00,$0F,$4E,$B9
	dc.b	$00,$01,$54,$5A,$4E,$B9,$00,$01,$BD,$E8,$4E,$B9,$00,$01,$BC,$84
	dc.b	$31,$FC,$00,$01,$B0,$40,$54,$78,$B0,$42,$30,$3C,$00,$04,$61,$00
	dc.b	$00,$42,$4E,$B9,$00,$01,$BA,$2E,$00,$12,$55,$6E,$69,$66,$6F,$72
	dc.b	$6D,$20,$23,$3A,$FD,$0E,$20,$20,$FD,$0E,$10,$39,$FF,$FF,$56,$00
	dc.b	$32,$00,$02,$41,$00,$0F,$3F,$01,$E8,$48,$02,$40,$00,$0F,$C0,$FC
	dc.b	$00,$0A,$D0,$5F,$4E,$B9,$00,$01,$BD,$E8,$4E,$B9,$00,$01,$BC,$84
	dc.b	$4E,$75,$4E,$B9,$00,$01,$BA,$2E,$00,$04,$FE,$07,$B0,$78,$D4,$86
	dc.b	$66,$00,$00,$0C,$4E,$B9,$00,$01,$BA,$2E,$00,$04,$FE,$05,$61,$00
	dc.b	$F9,$78,$4E,$75

PosText	;Position texts (code96_04 and the create player screen)
	String	'G '
	String	'LD'
	String	'RD'
	String	'LW'
	String	'C '
	String	'RW'

HandNames	;Shooting hand texts
	String	'LEFT '
	String	'RIGHT'

SaveCreateName	;Save entered name to the created-player record (new or existing); invalid name -> message; d0=0 ok/-1
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$FF,$FE,$61,$00,$01,$40,$6B,$00,$01,$22,$30,$38,$D3,$C2
	dc.b	$53,$40,$D0,$40,$20,$7C,$FF,$FF,$4E,$20,$4A,$70,$00,$00,$6B,$00
	dc.b	$00,$7A,$48,$E7,$70,$40,$22,$7C,$00,$20,$1B,$68,$34,$3C,$00,$00
	dc.b	$36,$31,$20,$00,$02,$43,$00,$FF,$E1,$4B,$32,$31,$20,$02,$02,$41
	dc.b	$00,$FF,$86,$41,$B6,$70,$00,$00,$67,$00,$00,$0C,$58,$42,$B4,$7C
	dc.b	$00,$50,$6D,$DC,$42,$42,$E4,$42,$33,$C2,$FF,$FF,$55,$FC,$4C,$DF
	dc.b	$02,$0E,$32,$30,$00,$00,$02,$41,$00,$FF,$33,$C1,$FF,$FF,$55,$FE
	dc.b	$EB,$41,$D2,$41,$20,$7C,$00,$20,$25,$9C,$D0,$C1,$61,$00,$00,$06
	dc.b	$60,$00,$00,$9E

CopyNameWords	;Copy the length-prefixed name at StatWork into a0 as words
	;Code the listing does not decode: kept as bytes
	dc.b	$22,$7C,$FF,$FF,$BF,$54,$30,$11,$53,$40,$42,$41,$12,$19,$30,$C1
	dc.b	$51,$C8,$FF,$FA,$4E,$75

SaveNewName	;SaveCreateName, new player: take a free SRCreatedPlayers slot, store the name and add it to the free agent
	;list
	;Code the listing does not decode: kept as bytes
	dc.b	$61,$00,$01,$4C,$6B,$00,$00,$88,$20,$7C,$00,$20,$25,$9C,$42,$46
	dc.b	$3A,$3C,$00,$13,$4A,$28,$00,$01,$66,$00,$00,$0A,$4A,$28,$00,$03
	dc.b	$67,$00,$00,$12,$D1,$FC,$00,$00,$00,$40,$52,$46,$51,$CD,$FF,$E6
	dc.b	$60,$00,$00,$5C,$61,$B4,$52,$39,$00,$20,$2A,$9D,$20,$7C,$00,$20
	dc.b	$1B,$68,$30,$39,$00,$20,$1B,$B8,$02,$40,$00,$FF,$B0,$3C,$00,$14
	dc.b	$6C,$00,$00,$38,$42,$79,$FF,$FF,$55,$FC,$4A,$28,$00,$01,$6B,$00
	dc.b	$00,$0C,$58,$88,$52,$79,$FF,$FF,$55,$FC,$60,$EE,$11,$46,$00,$03
	dc.b	$02,$46,$00,$FF,$33,$C6,$FF,$FF,$55,$FE,$11,$7C,$00,$1E,$00,$01
	dc.b	$52,$79,$00,$20,$1B,$B8,$60,$00,$00,$1C,$60,$00,$00,$06,$60,$00
	dc.b	$00,$02

SaveNameError	;SaveCreateName: back to font 0, d0 = -1
	;Code the listing does not decode: kept as bytes
	dc.b	$4E,$B9,$00,$01,$BA,$2E,$00,$04,$F9,$00,$30,$3C,$FF,$FF,$60,$00
	dc.b	$00,$04,$42,$40,$4C,$DF,$7F,$FF,$4E,$75

BuildEnteredName	;Build the entered name (from NameEntryBuf, spaces/dashes dropped, space after first name) as a length-word
	;string at StatWork and check it has a first and last name; d0 = 0 ok, -1 invalid
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$FF,$FE,$20,$7C,$FF,$FF,$BF,$56,$22,$7C,$FF,$FF,$D3,$AC
	dc.b	$30,$38,$D3,$C0,$53,$40,$42,$45,$42,$46,$BC,$7C,$00,$08,$66,$00
	dc.b	$00,$08,$10,$FC,$00,$20,$52,$45,$12,$19,$B2,$3C,$00,$20,$67,$00
	dc.b	$00,$0E,$B2,$3C,$00,$2D,$67,$00,$00,$06,$10,$C1,$52,$45,$52,$46
	dc.b	$51,$C8,$FF,$D8,$08,$05,$00,$00,$67,$00,$00,$08,$10,$BC,$00,$00
	dc.b	$52,$45,$54,$45,$31,$C5,$BF,$54,$BA,$7C,$00,$06,$6D,$00,$00,$3A
	dc.b	$20,$7C,$FF,$FF,$BF,$54,$D0,$D0,$10,$20,$4A,$00,$66,$00,$00,$04
	dc.b	$10,$20,$B0,$3C,$00,$20,$67,$00,$00,$20,$30,$7C,$BF,$54,$30,$18
	dc.b	$53,$40,$0C,$18,$00,$20,$67,$00,$00,$0A,$51,$C8,$FF,$F6,$60,$00
	dc.b	$00,$08,$42,$40,$60,$00,$00,$06,$30,$3C,$FF,$FF,$4C,$DF,$7F,$FF
	dc.b	$4E,$75,$48,$A7,$80,$00,$42,$40,$10,$39,$00,$20,$2A,$9D,$B0,$3C
	dc.b	$00,$14,$6D,$00,$00,$0A,$30,$3C,$FF,$FF,$60,$00,$00,$06,$30,$3C
	dc.b	$00,$01,$4C,$9F,$00,$01,$4E,$75

NewCreateRecord	;Same as InitCreateRecord but with bit 2 of sflags8 set (skips the read)
	bset	#2,(sflags8).w
	bra.w	InitCreateRecord2

InitCreateRecord	;Read the create record for CreateIndex from save RAM. NewCreateRecord skips that read
	bclr	#2,(sflags8).w

InitCreateRecord2	;InitCreateRecord without the bclr (NewCreateRecord enters here)
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$FF,$FE,$20,$7C,$FF,$FF,$75,$38,$42,$80,$30,$39,$FF,$FF
	dc.b	$55,$FE,$EB,$40,$48,$C0,$06,$80,$00,$00,$12,$CE,$72,$20,$48,$E7
	dc.b	$C0,$80,$08,$38,$00,$02,$C3,$4C,$66,$00,$00,$08,$4E,$B9,$00,$02
	dc.b	$41,$E8,$22,$7C,$00,$1D,$EA,$52,$4A,$39,$FF,$FF,$56,$08,$66,$00
	dc.b	$00,$08,$22,$7C,$00,$1D,$EA,$4A,$D0,$D0,$30,$3C,$00,$07,$10,$D9
	dc.b	$51,$C8,$FF,$FC,$4A,$39,$FF,$FF,$56,$08,$67,$00,$00,$0E,$30,$3C
	dc.b	$00,$05,$4E,$B9,$00,$01,$B0,$A6,$D1,$20,$20,$7C,$FF,$FF,$75,$38
	dc.b	$D0,$D0,$10,$B9,$FF,$FF,$56,$00,$10,$39,$FF,$FF,$56,$01,$02,$40
	dc.b	$00,$F0,$02,$28,$00,$0F,$00,$01,$81,$28,$00,$01,$11,$79,$FF,$FF
	dc.b	$56,$08,$00,$08,$10,$39,$FF,$FF,$56,$04,$02,$40,$00,$01,$02,$28
	dc.b	$00,$FE,$00,$04,$81,$28,$00,$04,$4C,$DF,$01,$03,$4E,$B9,$00,$02
	dc.b	$41,$88,$4C,$DF,$7F,$FF,$4E,$75

CreateRecordTail1	;8 byte record tail (record byte $1F clear)
	dc.b	$20,$82,$22,$22,$00,$00,$22,$22

CreateRecordTail2	;8 byte record tail (record byte $1F set)
	dc.b	$20,$82,$22,$22,$22,$22,$22,$27

ModifyRatings	;Modify Ratings screen: up / down pick a rating, A / B lower / raise it (EditField), start commits the player
	;Code the listing does not decode: kept as bytes
	dc.b	$61,$00,$0C,$B0,$20,$7C,$00,$19,$69,$B4,$4E,$B9,$00,$01,$21,$8A
	dc.b	$4E,$B9,$00,$1D,$BB,$92,$31,$FC,$00,$18,$BD,$3C,$08,$B8,$00,$02
	dc.b	$BF,$B2,$61,$00,$0A,$F4,$61,$00,$0B,$0A,$61,$00,$0B,$4A,$61,$00
	dc.b	$00,$C2,$42,$79,$FF,$FF,$75,$32,$61,$00,$02,$3A,$46,$FC,$25,$00
	dc.b	$30,$38,$B0,$52,$B0,$78,$B0,$52,$67,$FA,$4E,$B9,$00,$01,$26,$40
	dc.b	$4E,$B9,$00,$01,$B2,$82,$4E,$B9,$00,$01,$B3,$20,$4A,$41,$67,$E0
	dc.b	$08,$01,$00,$07,$67,$00,$00,$0C,$4E,$B9,$00,$1D,$F5,$F4,$60,$00
	dc.b	$00,$7C,$08,$01,$00,$00,$67,$00,$00,$20,$4A,$79,$FF,$FF,$75,$32
	dc.b	$66,$00,$00,$0E,$61,$00,$08,$6C,$33,$C4,$FF,$FF,$75,$32,$60,$A8
	dc.b	$53,$79,$FF,$FF,$75,$32,$60,$A0,$08,$01,$00,$01,$67,$00,$00,$22
	dc.b	$61,$00,$08,$50,$B8,$79,$FF,$FF,$75,$32,$6F,$00,$00,$0A,$52,$79
	dc.b	$FF,$FF,$75,$32,$60,$82,$42,$79,$FF,$FF,$75,$32,$60,$00,$FF,$7A
	dc.b	$08,$01,$00,$06,$67,$00,$00,$0E,$30,$3C,$FF,$FF,$61,$00,$08,$40
	dc.b	$60,$00,$FF,$66,$08,$01,$00,$04,$67,$00,$00,$0E,$30,$3C,$00,$01
	dc.b	$61,$00,$08,$2C,$60,$00,$FF,$52,$60,$00,$FF,$56,$4C,$DF,$7F,$FF
	dc.b	$4E,$75,$48,$E7,$FF,$FE,$4E,$B9,$00,$01,$BC,$72,$00,$14,$8F,$07
	dc.b	$06,$46,$69,$72,$73,$74,$3A,$8F,$08,$07,$4C,$61,$73,$74,$3A,$00
	dc.b	$20,$7C,$FF,$FF,$BF,$F4,$22,$7C,$FF,$FF,$75,$3A,$31,$FC,$00,$02
	dc.b	$BF,$F2,$10,$19,$B0,$3C,$00,$20,$67,$00,$00,$0A,$10,$C0,$52,$78
	dc.b	$BF,$F2,$60,$EE,$42,$10,$52,$78,$BF,$F2,$02,$78,$FF,$FE,$BF,$F2
	dc.b	$22,$7C,$FF,$FF,$BF,$F2,$4E,$B9,$00,$01,$BC,$72,$00,$06,$8F,$0D
	dc.b	$06,$00,$4E,$B9,$00,$01,$BC,$84,$20,$7C,$FF,$FF,$BF,$F4,$22,$7C
	dc.b	$FF,$FF,$75,$3A,$31,$FC,$00,$02,$BF,$F2,$3C,$39,$FF,$FF,$75,$38
	dc.b	$57,$46,$10,$19,$53,$46,$B0,$3C,$00,$20,$66,$F6,$10,$D9,$52,$78
	dc.b	$BF,$F2,$51,$CE,$FF,$F8,$42,$10,$52,$78,$BF,$F2,$02,$78,$FF,$FE
	dc.b	$BF,$F2,$22,$7C,$FF,$FF,$BF,$F2,$4E,$B9,$00,$01,$BC,$72,$00,$06
	dc.b	$8F,$0D,$07,$00,$4E,$B9,$00,$01,$BC,$84,$4E,$B9,$00,$01,$BC,$72
	dc.b	$00,$0A,$8F,$09,$08,$70,$6F,$73,$3A,$00,$22,$7C,$FF,$FF,$75,$38
	dc.b	$D2,$D1,$10,$29,$00,$08,$48,$80,$2F,$09,$22,$7C,$00,$1D,$E7,$4C
	dc.b	$4E,$B9,$00,$01,$D7,$F2,$4E,$B9,$00,$01,$BC,$84,$4E,$B9,$00,$01
	dc.b	$BC,$72,$00,$0A,$8F,$1C,$08,$68,$61,$6E,$64,$3A,$22,$57,$10,$29
	dc.b	$00,$04,$02,$40,$00,$01,$22,$7C,$00,$1D,$E7,$64,$4E,$B9,$00,$01
	dc.b	$D7,$F2,$4E,$B9,$00,$01,$BC,$84,$4E,$B9,$00,$01,$BC,$72,$00,$0C
	dc.b	$8F,$1A,$07,$77,$65,$69,$67,$68,$74,$3A,$22,$57,$10,$29,$00,$01
	dc.b	$E8,$48,$02,$40,$00,$0F,$4E,$B9,$00,$01,$54,$5A,$4E,$B9,$00,$01
	dc.b	$BD,$E8,$4E,$B9,$00,$01,$BC,$84,$4E,$B9,$00,$01,$BC,$72,$00,$0C
	dc.b	$8F,$1A,$06,$6E,$75,$6D,$62,$65,$72,$3A,$22,$5F,$10,$11,$32,$00
	dc.b	$02,$41,$00,$0F,$3F,$01,$E8,$48,$02,$40,$00,$0F,$C0,$FC,$00,$0A
	dc.b	$D0,$5F,$4E,$B9,$00,$01,$BD,$E8,$4E,$B9,$00,$01,$BC,$84,$4C,$DF
	dc.b	$7F,$FF,$4E,$75,$48,$E7,$FF,$FE,$42,$47,$61,$00,$06,$76,$61,$00
	dc.b	$04,$9A,$52,$47,$BE,$44,$6F,$F6,$61,$00,$00,$0C,$61,$00,$00,$78
	dc.b	$4C,$DF,$7F,$FF,$4E,$75,$4E,$B9,$00,$01,$BA,$2E,$00,$14,$FE,$07
	dc.b	$FD,$1B,$FC,$10,$4F,$56,$45,$52,$41,$4C,$4C,$FD,$1D,$FC,$11,$00
	dc.b	$20,$7C,$FF,$FF,$75,$38,$D0,$D0,$50,$48,$28,$7C,$FF,$FF,$C8,$F2
	dc.b	$2C,$7C,$00,$1D,$F9,$FC,$28,$39,$00,$02,$35,$B8,$4A,$79,$FF,$FF
	dc.b	$75,$34,$67,$00,$00,$0E,$2C,$7C,$00,$1D,$F9,$EC,$28,$39,$00,$02
	dc.b	$34,$56,$4E,$B9,$00,$1D,$F8,$AC,$C0,$FC,$00,$64,$80,$C1,$4E,$B9
	dc.b	$00,$1D,$93,$02,$32,$3C,$00,$02,$4E,$B9,$00,$01,$BE,$1C,$4E,$B9
	dc.b	$00,$01,$BA,$40,$4E,$75,$4E,$B9,$00,$01,$BA,$2E,$00,$1C,$FE,$07
	dc.b	$FD,$17,$FC,$0D,$50,$6F,$69,$6E,$74,$73,$20,$72,$65,$6D,$61,$69
	dc.b	$6E,$69,$6E,$67,$FD,$1D,$FC,$0E,$30,$39,$FF,$FF,$75,$36,$32,$3C
	dc.b	$00,$03,$4E,$B9,$00,$01,$BE,$1C,$4E,$B9,$00,$01,$BA,$40,$4E,$75
	dc.b	$48,$E7,$FF,$FE,$20,$7C,$00,$1D,$F1,$28,$4A,$79,$FF,$FF,$75,$34
	dc.b	$66,$00,$00,$08,$20,$7C,$00,$1D,$F1,$50,$30,$07,$E5,$40,$20,$70
	dc.b	$00,$00,$24,$7C,$FF,$FF,$75,$38,$D4,$D2,$4E,$90,$4C,$DF,$7F,$FF
	dc.b	$4E,$75

FieldSpeed	;Create player field: Speed
	;Code the listing does not decode: kept as bytes
	dc.b	$61,$00,$03,$3A,$61,$00,$00,$22,$28,$39,$00,$02,$34,$98,$4E,$B9
	dc.b	$00,$1D,$F8,$AC,$32,$3C,$00,$02,$4E,$B9,$00,$01,$BE,$1C,$4E,$B9
	dc.b	$00,$01,$BA,$40,$60,$00,$03,$0A

FieldPrintSetup	;Set print target a4 / a0 and the number print table a6 for a field value
	;Code the listing does not decode: kept as bytes
	dc.b	$28,$7C,$FF,$FF,$C8,$F2,$20,$4A,$50,$48,$2C,$7C,$00,$1D,$FA,$0C
	dc.b	$4E,$75

FieldAgility	;Create player field: Agility
	;Code the listing does not decode: kept as bytes
	dc.b	$61,$00,$03,$00,$61,$E8,$28,$39,$00,$02,$34,$82,$4E,$B9,$00,$1D
	dc.b	$F8,$AC,$32,$3C,$00,$02,$4E,$B9,$00,$01,$BE,$1C,$4E,$B9,$00,$01
	dc.b	$BA,$40,$60,$00,$02,$D2

FieldEndurance	;Create player field: Endurance
	;Code the listing does not decode: kept as bytes
	dc.b	$61,$00,$02,$DA,$61,$C2,$28,$39,$00,$02,$35,$5E,$4E,$B9,$00,$1D
	dc.b	$F8,$AC,$32,$3C,$00,$02,$4E,$B9,$00,$01,$BE,$1C,$4E,$B9,$00,$01
	dc.b	$BA,$40,$60,$00,$02,$AC

FieldOffAware	;Create player field: OffAware
	;Code the listing does not decode: kept as bytes
	dc.b	$61,$00,$02,$B4,$61,$9C,$28,$39,$00,$02,$34,$C4,$4E,$B9,$00,$1D
	dc.b	$F8,$AC,$32,$3C,$00,$02,$4E,$B9,$00,$01,$BE,$1C,$4E,$B9,$00,$01
	dc.b	$BA,$40,$60,$00,$02,$86

FieldDefAware	;Create player field: DefAware
	;Code the listing does not decode: kept as bytes
	dc.b	$61,$00,$02,$8E,$61,$00,$FF,$76,$28,$39,$00,$02,$34,$DA,$4E,$B9
	dc.b	$00,$1D,$F8,$AC,$32,$3C,$00,$02,$4E,$B9,$00,$01,$BE,$1C,$4E,$B9
	dc.b	$00,$01,$BA,$40,$60,$00,$02,$5E

FieldStickhandling	;Create player field: Stickhandling
	;Code the listing does not decode: kept as bytes
	dc.b	$61,$00,$02,$66,$61,$00,$FF,$4E,$28,$39,$00,$02,$35,$32,$4E,$B9
	dc.b	$00,$1D,$F8,$AC,$32,$3C,$00,$02,$4E,$B9,$00,$01,$BE,$1C,$4E,$B9
	dc.b	$00,$01,$BA,$40,$60,$00,$02,$36

FieldWeight	;Create player field: Weight
	;Code the listing does not decode: kept as bytes
	dc.b	$61,$00,$02,$3E,$61,$00,$FF,$26,$28,$39,$00,$02,$35,$48,$4E,$B9
	dc.b	$00,$1D,$F8,$AC,$E7,$40,$06,$40,$00,$8C,$32,$3C,$00,$03,$4E,$B9
	dc.b	$00,$01,$BE,$1C,$4E,$B9,$00,$01,$BA,$40,$60,$00,$02,$08

FieldShotPower	;Create player field: ShotPower
	;Code the listing does not decode: kept as bytes
	dc.b	$61,$00,$02,$10,$61,$00,$FE,$F8,$28,$39,$00,$02,$34,$F0,$4E,$B9
	dc.b	$00,$1D,$F8,$AC,$32,$3C,$00,$02,$4E,$B9,$00,$01,$BE,$1C,$4E,$B9
	dc.b	$00,$01,$BA,$40,$60,$00,$01,$E0

FieldShotAcc	;Create player field: ShotAcc
	;Code the listing does not decode: kept as bytes
	dc.b	$61,$00,$01,$E8,$61,$00,$FE,$D0,$28,$39,$00,$02,$35,$06,$4E,$B9
	dc.b	$00,$1D,$F8,$AC,$32,$3C,$00,$02,$4E,$B9,$00,$01,$BE,$1C,$4E,$B9
	dc.b	$00,$01,$BA,$40,$60,$00,$01,$B8

FieldPassAcc	;Create player field: PassAcc
	;Code the listing does not decode: kept as bytes
	dc.b	$61,$00,$01,$C0,$61,$00,$FE,$A8,$28,$39,$00,$02,$35,$1C,$4E,$B9
	dc.b	$00,$1D,$F8,$AC,$32,$3C,$00,$02,$4E,$B9,$00,$01,$BE,$1C,$4E,$B9
	dc.b	$00,$01,$BA,$40,$60,$00,$01,$90

FieldChecking	;Create player field: Checking
	;Code the listing does not decode: kept as bytes
	dc.b	$61,$00,$01,$98,$61,$00,$FE,$80,$28,$39,$00,$02,$35,$8A,$4E,$B9
	dc.b	$00,$1D,$F8,$AC,$32,$3C,$00,$02,$4E,$B9,$00,$01,$BE,$1C,$4E,$B9

FieldBlank2	;Create player field: Blank2
	;Code the listing does not decode: kept as bytes
	dc.b	$00,$01,$BA,$40,$60,$00,$01,$68

FieldJersey	;Create player field: Jersey
	;Code the listing does not decode: kept as bytes
	dc.b	$61,$00,$01,$70,$42,$44,$18,$12,$E8,$4C,$C8,$FC,$00,$0A,$10,$12
	dc.b	$02,$00,$00,$0F,$D0,$04,$32,$3C,$00,$02,$4E,$B9,$00,$01,$BE,$1C
	dc.b	$4E,$B9,$00,$01,$BA,$40,$60,$00,$01,$3E

FieldGAgility	;Create player field: GAgility
	;Code the listing does not decode: kept as bytes
	dc.b	$61,$00,$01,$46,$61,$00,$FE,$2E,$28,$39,$00,$02,$35,$CE,$4E,$B9
	dc.b	$00,$1D,$F8,$AC,$32,$3C,$00,$02,$4E,$B9,$00,$01,$BE,$1C,$4E,$B9
	dc.b	$00,$01,$BA,$40,$60,$00,$01,$16

FieldGDefAware	;Create player field: GDefAware
	;Code the listing does not decode: kept as bytes
	dc.b	$61,$00,$01,$1E,$61,$00,$FE,$06,$28,$39,$00,$02,$36,$10,$4E,$B9
	dc.b	$00,$1D,$F8,$AC,$32,$3C,$00,$02,$4E,$B9,$00,$01,$BE,$1C,$4E,$B9
	dc.b	$00,$01,$BA,$40,$60,$00,$00,$EE

FieldGPuckCtrl	;Create player field: GPuckCtrl
	;Code the listing does not decode: kept as bytes
	dc.b	$61,$00,$00,$F6,$61,$00,$FD,$DE,$28,$39,$00,$02,$36,$3C,$4E,$B9
	dc.b	$00,$1D,$F8,$AC,$32,$3C,$00,$02,$4E,$B9,$00,$01,$BE,$1C,$4E,$B9
	dc.b	$00,$01,$BA,$40,$60,$00,$00,$C6

FieldGStickR	;Create player field: GStickR
	;Code the listing does not decode: kept as bytes
	dc.b	$61,$00,$00,$CE,$61,$00,$FD,$B6,$28,$39,$00,$02,$36,$52,$4E,$B9
	dc.b	$00,$1D,$F8,$AC,$32,$3C,$00,$02,$4E,$B9,$00,$01,$BE,$1C,$4E,$B9
	dc.b	$00,$01,$BA,$40,$60,$00,$00,$9E

FieldGStickL	;Create player field: GStickL
	;Code the listing does not decode: kept as bytes
	dc.b	$61,$00,$00,$A6,$61,$00,$FD,$8E,$28,$39,$00,$02,$36,$68,$4E,$B9
	dc.b	$00,$1D,$F8,$AC,$32,$3C,$00,$02,$4E,$B9,$00,$01,$BE,$1C,$4E,$B9
	dc.b	$00,$01,$BA,$40,$60,$00,$00,$76

FieldGGloveR	;Create player field: GGloveR
	;Code the listing does not decode: kept as bytes
	dc.b	$61,$00,$00,$7E,$61,$00,$FD,$66,$28,$39,$00,$02,$36,$7E,$4E,$B9
	dc.b	$00,$1D,$F8,$AC,$32,$3C,$00,$02,$4E,$B9,$00,$01,$BE,$1C,$4E,$B9
	dc.b	$00,$01,$BA,$40,$60,$00,$00,$4E

FieldGGloveL	;Create player field: GGloveL
	;Code the listing does not decode: kept as bytes
	dc.b	$61,$00,$00,$56,$61,$00,$FD,$3E,$28,$39,$00,$02,$36,$94,$4E,$B9
	dc.b	$00,$1D,$F8,$AC,$32,$3C,$00,$02,$4E,$B9,$00,$01,$BE,$1C,$4E,$B9
	dc.b	$00,$01,$BA,$40,$60,$00,$00,$26

FieldHand	;Create player field: Hand
	;Code the listing does not decode: kept as bytes
	dc.b	$61,$00,$00,$2E,$10,$2A,$00,$04,$02,$40,$00,$01,$22,$7C,$00,$1D
	dc.b	$F0,$F4,$4E,$B9,$00,$01,$D7,$EA,$60,$00,$00,$0A

HandText	;FieldHand: the hand letters
	String	'L'
	String	'R'
	dc.b	$4E,$B9,$00,$01,$BA,$2E,$00,$04,$FE,$07,$4E,$75,$4E,$B9,$00,$01
	dc.b	$BA,$2E,$00,$04,$FE,$07,$BE,$79,$FF,$FF,$75,$32,$66,$00,$00,$0C
	dc.b	$4E,$B9,$00,$01,$BA,$2E,$00,$04,$FE,$05,$4E,$75

SkaterFieldList	;The field routine of each skater rating row
	dc.l	FieldAgility,FieldSpeed,FieldOffAware,FieldDefAware,FieldShotPower,FieldChecking
	dc.l	FieldStickhandling,FieldShotAcc,FieldEndurance,FieldPassAcc

GoalieFieldList	;The field routine of each goalie rating row
	dc.l	FieldGAgility,FieldSpeed,FieldOffAware,FieldGDefAware,FieldGPuckCtrl,FieldGStickR
	dc.l	FieldGStickL,FieldGGloveR,FieldGGloveL

DrawField	;Draw one create player field: label then value, all registers saved
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$FF,$FE,$61,$00,$00,$0C,$61,$00,$FC,$1C,$4C,$DF,$7F,$FF
	dc.b	$4E,$75,$48,$E7,$C0,$C0,$22,$7C,$00,$1D,$F1,$DA,$4A,$79,$FF,$FF
	dc.b	$75,$34,$66,$00,$00,$08,$22,$7C,$00,$1D,$F2,$A2,$30,$07,$48,$E7
	dc.b	$80,$40,$4E,$B9,$00,$01,$BA,$2E,$00,$04,$FE,$07,$BE,$79,$FF,$FF
	dc.b	$75,$32,$66,$00,$00,$0C,$4E,$B9,$00,$01,$BA,$2E,$00,$04,$FE,$05
	dc.b	$4C,$DF,$02,$01,$4E,$B9,$00,$01,$D7,$F2,$4E,$B9,$00,$01,$BA,$40
	dc.b	$4C,$DF,$03,$03,$4E,$75

SkaterSkillLabels	;The skater rating labels
	String	$FD,$02,$FC,$0D,'Agility',$FD,$13
	String	$FD,$02,$FC,$0E,'Speed',$FD,$13
	String	$FD,$02,$FC,$0F,'Off.Awareness',$FD,$13
	String	$FD,$02,$FC,$10,'Def.Awareness',$FD,$13
	String	$FD,$02,$FC,$11,'Shot Power',$FD,$13
	String	$FD,$02,$FC,$12,'Checking Ability',$FD,$13
	String	$FD,$02,$FC,$13,'Stick Handling',$FD,$13
	String	$FD,$02,$FC,$14,'Shot Accuracy',$FD,$13
	String	$FD,$02,$FC,$15,'Endurance',$FD,$13
	String	$FD,$02,$FC,$16,'Pass Accuracy',$FD,$13

GoalieSkillLabels	;The goalie rating labels
	String	$FD,$02,$FC,$0D,'Agility',$FD,$13
	String	$FD,$02,$FC,$0E,'Speed',$FD,$13
	String	$FD,$02,$FC,$0F,'Off.Awareness',$FD,$13
	String	$FD,$02,$FC,$10,'Def.Awareness',$FD,$13
	String	$FD,$02,$FC,$11,'Puck Control',$FD,$13
	String	$FD,$02,$FC,$12,'Stick Right',$FD,$13
	String	$FD,$02,$FC,$13,'Stick Left',$FD,$13
	String	$FD,$02,$FC,$14,'Glove Right',$FD,$13
	String	$FD,$02,$FC,$15,'Glove Left',$FD,$13

LastFieldRow	;d4 = the last row index for the player type (CreateType)
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$02,$80,$38,$3C,$00,$08,$4A,$79,$FF,$FF,$75,$34,$67,$00
	dc.b	$00,$06,$38,$3C,$00,$09

EditField	;Run the edit routine of the cursor row (CreateCursorY) for the player type
	;Code the listing does not decode: kept as bytes
	dc.b	$4C,$DF,$01,$40,$4E,$75,$20,$7C,$00,$1D,$F3,$8E,$4A,$79,$FF,$FF
	dc.b	$75,$34,$67,$00,$00,$08,$20,$7C,$00,$1D,$F3,$B2,$32,$39,$FF,$FF
	dc.b	$75,$32,$E5,$41,$20,$70,$10,$00,$4E,$90,$4E,$75

GoalieEditList	;The edit routine of each goalie rating row
	dc.l	EditGAgility,EditSpeed,EditOffAware,EditGDefAware,EditGPuckCtrl,EditGStickR
	dc.l	EditGStickL,EditGGloveR,EditGGloveL

SkaterEditList	;The edit routine of each skater rating row
	dc.l	EditAgility,EditSpeed,EditOffAware,EditDefAware,EditShotPower,EditChecking
	dc.l	EditStickhandling,EditShotAcc,EditEndurance,EditPassAcc

EditGAgility	;Create player edit: GAgility
	;Code the listing does not decode: kept as bytes
	dc.b	$28,$39,$00,$02,$35,$CE

AdjustAttrib	;Adjust attribute selected by d4 bit by d0, paying from points pool CreatePoints
	;Code the listing does not decode: kept as bytes
	dc.b	$32,$39,$FF,$FF,$75,$36,$31,$C1,$C4,$C8,$34,$00,$44,$42,$D2,$42
	dc.b	$6B,$00,$00,$44,$33,$C1,$FF,$FF,$75,$36,$20,$7C,$FF,$FF,$C8,$E2
	dc.b	$48,$44,$08,$04,$00,$0F,$66,$00,$00,$08,$52,$48,$E3,$44,$60,$F2
	dc.b	$4A,$40,$6A,$00,$00,$14,$48,$A7,$30,$00,$14,$10,$B4,$3C,$00,$00
	dc.b	$4C,$9F,$00,$0C,$6F,$00,$00,$08,$D1,$10,$60,$00,$00,$0A,$33,$F8
	dc.b	$C4,$C8,$FF,$FF,$75,$36,$4E,$75

EditGDefAware	;Create player edit: GDefAware
	;Code the listing does not decode: kept as bytes
	dc.b	$28,$39,$00,$02,$36,$10,$60,$A0

EditGPuckCtrl	;Create player edit: GPuckCtrl
	;Code the listing does not decode: kept as bytes
	dc.b	$28,$39,$00,$02,$36,$3C,$60,$98

EditWeight	;Create player edit: Weight
	;Code the listing does not decode: kept as bytes
	dc.b	$20,$7C,$FF,$FF,$75,$38,$D0,$D0,$42,$41,$12,$28,$00,$01,$E8,$49
	dc.b	$02,$41,$00,$0F,$D2,$40,$6B,$D6,$B2,$7C,$00,$0F,$6E,$D0,$E9,$49
	dc.b	$10,$28,$00,$01,$02,$40,$00,$0F,$80,$41,$11,$40,$00,$01,$4E,$75

EditGStickR	;Create player edit: GStickR
	;Code the listing does not decode: kept as bytes
	dc.b	$28,$39,$00,$02,$36,$52,$60,$00,$FF,$60

EditGStickL	;Create player edit: GStickL
	;Code the listing does not decode: kept as bytes
	dc.b	$28,$39,$00,$02,$36,$68,$60,$00,$FF,$56

EditGGloveR	;Create player edit: GGloveR
	;Code the listing does not decode: kept as bytes
	dc.b	$28,$39,$00,$02,$36,$7E,$60,$00,$FF,$4C

EditGGloveL	;Create player edit: GGloveL
	;Code the listing does not decode: kept as bytes
	dc.b	$28,$39,$00,$02,$36,$94,$60,$00,$FF,$42

EditHand	;Create player edit: Hand
	;Code the listing does not decode: kept as bytes
	dc.b	$20,$7C,$FF,$FF,$75,$38,$D0,$D0,$0A,$28,$00,$01,$00,$04,$4E,$75

EditJersey	;Create player edit: Jersey
	;Code the listing does not decode: kept as bytes
	dc.b	$20,$7C,$FF,$FF,$75,$38,$D0,$D0,$42,$41,$12,$10,$02,$41,$00,$0F
	dc.b	$42,$42,$14,$10,$E8,$4A,$C4,$FC,$00,$0A,$D2,$42,$D0,$01,$6A,$00
	dc.b	$00,$06,$30,$3C,$00,$63,$4A,$00,$66,$00,$00,$06,$30,$3C,$00,$63
	dc.b	$B0,$3C,$00,$63,$6F,$00,$00,$06,$30,$3C,$00,$01,$4A,$00,$66,$00
	dc.b	$00,$06,$30,$3C,$00,$01,$02,$80,$00,$00,$00,$FF,$80,$FC,$00,$0A
	dc.b	$32,$00,$E9,$49,$48,$40,$82,$00,$10,$81,$4E,$75

EditSpeed	;Create player edit: Speed
	;Code the listing does not decode: kept as bytes
	dc.b	$28,$39,$00,$02,$34,$98,$60,$00,$FE,$CC

EditAgility	;Create player edit: Agility
	;Code the listing does not decode: kept as bytes
	dc.b	$28,$39,$00,$02,$34,$82,$60,$00,$FE,$C2

EditEndurance	;Create player edit: Endurance
	;Code the listing does not decode: kept as bytes
	dc.b	$28,$39,$00,$02,$35,$5E,$60,$00,$FE,$B8

EditOffAware	;Create player edit: OffAware
	;Code the listing does not decode: kept as bytes
	dc.b	$28,$39,$00,$02,$34,$C4,$60,$00,$FE,$AE

EditDefAware	;Create player edit: DefAware
	;Code the listing does not decode: kept as bytes
	dc.b	$28,$39,$00,$02,$34,$DA,$60,$00,$FE,$A4

EditStickhandling	;Create player edit: Stickhandling
	;Code the listing does not decode: kept as bytes
	dc.b	$28,$39,$00,$02,$35,$32,$60,$00,$FE,$9A

EditShotPower	;Create player edit: ShotPower
	;Code the listing does not decode: kept as bytes
	dc.b	$28,$39,$00,$02,$34,$F0,$60,$00,$FE,$90

EditShotAcc	;Create player edit: ShotAcc
	;Code the listing does not decode: kept as bytes
	dc.b	$28,$39,$00,$02,$35,$06,$60,$00,$FE,$86

EditPassAcc	;Create player edit: PassAcc
	;Code the listing does not decode: kept as bytes
	dc.b	$28,$39,$00,$02,$35,$1C,$60,$00,$FE,$7C

EditChecking	;Create player edit: Checking
	;Code the listing does not decode: kept as bytes
	dc.b	$28,$39,$00,$02,$35,$8A,$60,$00,$FE,$72

EditNone	;Create player edit: nothing
	;Code the listing does not decode: kept as bytes
	dc.b	$4E,$75

ClearAttribDeltas	;Clear 16-byte attribute buffer AttribDeltas
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$FF,$FE,$20,$7C,$FF,$FF,$C8,$E2,$30,$3C,$00,$03,$42,$98
	dc.b	$51,$C8,$FF,$FC,$4C,$DF,$7F,$FF,$4E,$75

LoadCreateTemplate	;Copy 32-word player template (index CreateIndex) from SRCreatedPlayers into byte record CreateRecord, set
	;CreateType from last byte
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$FF,$FE,$30,$3C,$00,$1F,$20,$7C,$00,$20,$25,$9C,$32,$39
	dc.b	$FF,$FF,$55,$FE,$EB,$41,$D2,$41,$D0,$C1,$22,$7C,$FF,$FF,$75,$38
	dc.b	$34,$18,$12,$C2,$51,$C8,$FF,$FA,$42,$79,$FF,$FF,$75,$34,$22,$7C
	dc.b	$FF,$FF,$75,$38,$D2,$D1,$13,$E9,$00,$08,$FF,$FF,$75,$35,$4C,$DF
	dc.b	$7F,$FF,$4E,$75

SetPointsPool	;CreatePoints for a goalie or a skater
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$FF,$FE,$33,$FC,$01,$E0,$FF,$FF,$75,$36,$4A,$79,$FF,$FF
	dc.b	$75,$34,$67,$00,$00,$0A,$33,$FC,$01,$C2,$FF,$FF,$75,$36,$4C,$DF
	dc.b	$7F,$FF,$4E,$75

CommitCreatedPlayer	;Commit the created player: the attribute deltas into the record (CommitAttribJumps), then save RAM
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$FF,$FE,$20,$7C,$FF,$FF,$75,$38,$D0,$D0,$24,$7C,$FF,$FF
	dc.b	$C8,$E2,$30,$3C,$00,$0F,$32,$00,$E2,$49,$48,$E7,$40,$80,$42,$42
	dc.b	$42,$43,$16,$30,$10,$00,$14,$32,$00,$00,$08,$00,$00,$00,$66,$00
	dc.b	$00,$04,$E8,$4B,$02,$43,$00,$0F,$22,$7C,$00,$1D,$F6,$9E,$32,$00
	dc.b	$E5,$41,$22,$71,$10,$00,$4E,$91,$4C,$DF,$01,$02,$14,$30,$10,$00
	dc.b	$08,$00,$00,$00,$66,$00,$00,$10,$02,$42,$00,$0F,$E9,$4B,$02,$43
	dc.b	$00,$F0,$60,$00,$00,$0A,$02,$42,$00,$F0,$02,$43,$00,$0F,$84,$43
	dc.b	$11,$82,$10,$00,$51,$C8,$FF,$A0,$20,$7C,$FF,$FF,$75,$38,$42,$80
	dc.b	$30,$39,$FF,$FF,$55,$FE,$EB,$40,$48,$C0,$06,$80,$00,$00,$12,$CE
	dc.b	$72,$20,$4E,$B9,$00,$02,$41,$88,$08,$B8,$00,$06,$C3,$50,$4E,$B9
	dc.b	$00,$02,$41,$AA,$4C,$DF,$7F,$FF,$4E,$75

CommitAttribJumps	;CommitCreatedPlayer: the routine of each attribute
	dc.l	CommitNone1,CommitNone1,CommitNone2,CrScale,CrScale,CrScale
	dc.l	CrScale,CrScale,CrScale,CrScaleEven,CrScaleLookup,CrScale
	dc.l	CrScale,CrScale,CrScale,CrScale

CrScale	;d3 += d2/14 (signed)
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$C2,$85,$FC,$00,$0E,$D6,$42,$4E,$75

CommitNone1	;Nothing to commit
	;Code the listing does not decode: kept as bytes
	dc.b	$4E,$75

CommitNone2	;Nothing to commit
	;Code the listing does not decode: kept as bytes
	dc.b	$4E,$75

CrScaleEven	;Scale even part of d3 via CrScale, keep low bit of d3
	;Code the listing does not decode: kept as bytes
	dc.b	$3F,$03,$02,$43,$00,$FE,$4E,$B9,$00,$1D,$F6,$DE,$34,$03,$36,$1F
	dc.b	$02,$43,$00,$01,$02,$42,$00,$FE,$86,$42,$4E,$75

CrScaleLookup	;CrScale
	;Code the listing does not decode: kept as bytes
	dc.b	$61,$D4,$4E,$75

CreateRatingsGfx	;Set up the create player ratings screen: vram, fonts, the bitmaps and the help lines
	;Code the listing does not decode: kept as bytes
	dc.b	$08,$F8,$00,$05,$C3,$56,$21,$FC,$00,$01,$2D,$46,$D2,$44,$08,$B8
	dc.b	$00,$00,$BF,$B2,$08,$F8,$00,$02,$BF,$B2,$08,$B8,$00,$01,$BF,$B2
	dc.b	$31,$FC,$00,$00,$B0,$00,$31,$FC,$B4,$00,$B0,$02,$31,$FC,$B8,$00
	dc.b	$B0,$0C,$31,$FC,$00,$05,$B0,$0E,$31,$FC,$C0,$00,$B0,$08,$31,$FC
	dc.b	$00,$06,$B0,$0A,$31,$FC,$E0,$00,$B0,$04,$31,$FC,$00,$06,$B0,$06
	dc.b	$30,$3C,$00,$00,$08,$F8,$00,$05,$BF,$B2,$4E,$B9,$00,$01,$B5,$7E
	dc.b	$08,$B8,$00,$05,$BF,$B2,$4E,$B9,$00,$01,$B2,$C4,$38,$3C,$00,$01
	dc.b	$22,$7C,$00,$19,$69,$B4,$4E,$B9,$00,$01,$21,$7A,$31,$C4,$B0,$1C
	dc.b	$24,$7C,$00,$17,$91,$70,$4E,$B9,$00,$01,$B7,$30,$31,$C4,$B0,$1E
	dc.b	$24,$7C,$00,$17,$A1,$6C,$4E,$B9,$00,$01,$B7,$30,$21,$FC,$00,$17
	dc.b	$91,$68,$BF,$8A,$4E,$B9,$00,$01,$BA,$2E,$00,$08,$FF,$01,$FD,$00
	dc.b	$FC,$00,$70,$28,$72,$1C,$34,$3C,$07,$FF,$4E,$B9,$00,$01,$B9,$76
	dc.b	$4E,$B9,$00,$01,$BC,$72,$00,$06,$BF,$00,$00,$00,$20,$7C,$00,$19
	dc.b	$50,$86,$22,$48,$24,$48,$D1,$DA,$D3,$DA,$42,$40,$42,$41,$74,$28
	dc.b	$76,$1C,$7A,$08,$4E,$B9,$00,$01,$B6,$92,$4E,$B9,$00,$01,$BC,$72
	dc.b	$00,$06,$BF,$0B,$01,$00,$20,$7C,$00,$19,$29,$FA,$22,$48,$24,$48
	dc.b	$D1,$DA,$D3,$DA,$42,$40,$42,$41,$34,$11,$36,$29,$00,$02,$7A,$08
	dc.b	$4E,$B9,$00,$01,$B6,$92,$4E,$B9,$00,$01,$BC,$72,$00,$06,$FE,$00
	dc.b	$00,$00,$20,$7C,$00,$17,$0B,$0C,$22,$48,$24,$48,$D1,$DA,$D3,$DA
	dc.b	$42,$40,$42,$41,$74,$40,$76,$1C,$7A,$01,$4E,$B9,$00,$01,$B6,$92
	dc.b	$3F,$38,$B0,$1C,$31,$F8,$B0,$1E,$B0,$1C,$4E,$B9,$00,$01,$BC,$72
	dc.b	$00,$16,$8F,$0C,$1A,$7B,$7D,$2D,$73,$65,$6C,$65,$63,$74,$20,$72
	dc.b	$61,$74,$69,$6E,$67,$00,$31,$DF,$B0,$1C,$4E,$B9,$00,$01,$BC,$72
	dc.b	$00,$2A,$8F,$1A,$13,$61,$3D,$64,$65,$63,$72,$65,$61,$73,$65,$8F
	dc.b	$1A,$14,$62,$3D,$69,$6E,$63,$72,$65,$61,$73,$65,$8F,$1A,$15,$73
	dc.b	$74,$61,$72,$74,$3D,$64,$6F,$6E,$65,$00,$46,$FC,$25,$00,$4E,$75

CalcAttribRating	;The rating sum of CalcAttrib: d0 / d1 = weighted sum of the attributes in d4 bits (weights a6), d1 the
	;maximum. With AttribWgtList (create player) it clamps the attribute to 0-$63 and adjusts CreatePoints
	clr.w	(attribsum).w
	clr.w	(attribcount).w
	clr.w	d0
	clr.w	d1
	moveq	#$F,d2
	swap	d4
.bit
	btst	d2,d4
	beq.w	.next
	move.w	d2,d3
	lsr.w	#1,d3
	neg.w	d3
	move.b	-1(a0,d3.w),d3
	btst	#0,d2
	beq.w	.1
	lsr.w	#4,d3
.1
	andi.w	#$F,d3
	cmp.w	#$D,d2
	bne.w	.0
	bra.w	.add
.0
	tst.w	d2
	bne.w	.2
	cmp.b	#6,d3
	ble.w	.2
	subq.b	#6,d3
.2
	cmp.w	#5,d2
	bne.w	*+4
.3
	cmp.w	#6,d2
	beq.w	.add
	movem.l	d5-d7,-(sp)
	move.b	(a6,d2.w),d5
	ext.w	d5
	cmp.w	#2,d5
	beq.w	.5
	move.w	d3,-(sp)
	subq.w	#2,d5
.attribadd
	add.w	(sp),d3
	dbf	d5,.attribadd
	asr.w	#1,d3
	tst.w	(sp)+
.5
	movem.l	(sp)+,d5-d7
	cmpa.l	#AttribWgtList2,a6
	beq.w	.create
	neg.w	d2
	move.w	d7,-(sp)
	move.b	-1(a4,d2.w),d7
	ext.w	d7
	add.w	d7,(attribsum).w
	addq.w	#1,(attribcount).w
	move.w	(sp)+,d7
	neg.w	d2
	bra.w	.add
.create
	move.w	d3,-(sp)
	asl.w	#4,d3
	add.w	(sp),d3
	add.w	(sp)+,d3
	neg.w	d2
	add.b	-1(a4,d2.w),d3
	bpl.w	.chkmax
	clr.b	d3
	addq.b	#1,-1(a4,d2.w)
	subq.w	#1,(CreatePoints).l
.chkmax
	cmp.b	#$63,d3
	ble.w	.pos
	move.b	#$63,d3
	subq.b	#1,-1(a4,d2.w)
	addq.w	#1,(CreatePoints).l
.pos
	neg.w	d2
.add
	add.w	d3,d0
	addi.w	#$64,d1
.next
	dbf	d2,.bit
	cmpa.l	#AttribWgtList2,a6
	beq.w	.11
	move.w	#$64,d1
	movem.l	d6-d7,-(sp)
	move.w	(attribsum).w,d6
	ext.l	d6
	move.w	(attribcount).w,d7
	divs.w	d7,d6
	add.w	d6,d0
	movem.l	(sp)+,d6-d7
.11
	cmp.w	d1,d0
	blt.w	.4
	move.w	d0,d1
	subq.w	#1,d0
.4
	bsr.w	MinOverallRating
	rts

MinOverallRating	;For an overall rating (d4 = PAttribOverallMask or GAttribOverallMask): d0 at least (d1 + 3) / 4
	cmp.l	(PAttribOverallMask).l,d4
	beq.w	.0
	cmp.l	(GAttribOverallMask).l,d4
	bne.w	.2
.0
	movem.l	d1,-(sp)
	addq.w	#3,d1
	asr.w	#2,d1
	cmp.w	d1,d0
	bge.w	.1
	move.w	d1,d0
.1
	movem.l	(sp)+,d1
.2
	rts

OvrPlayerWgtList2	;Skater attribute weights for the overall rating (CalcAttribRating)
	dc.b	$02,$02,$02,$02,$04,$06,$02,$04,$02,$04,$06,$06,$04,$02,$02,$02

OvrGoalWgtList2	;Goalie attribute weights
	dc.b	$02,$02,$02,$02,$02,$02,$02,$02,$09,$09,$02,$02,$09,$02,$02,$02

AttribWgtList2	;Single attribute weights (create player)
	dc.b	$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02

ClearFreeAgentStats	;Clear the saved stat words of the free agent slots in save RAM
	movem.l	d0-d1/a0,-(sp)
	move.l	#$DE6,d0
	moveq	#$78,d1
	jsr	(ClearSRAMBytes).l
	movem.l	(sp)+,d0-d1/a0
	rts

ClearCreatedPlayers	;Clear the created players list at M68K_RAM+$DB4 (20 x $8000 + 0 terminator)
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#M68K_RAM+$DB4,a0
	move.w	#$13,d6
.loop
	move.w	#$8000,(a0)+
	dbf	d6,.loop
	move.b	#0,(M68K_RAM+$DDC).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

DeleteCreatedPlayer	;Delete created player #TempWord1: remove it from the save RAM records, roster list and team lines
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$FF,$FE,$3E,$3C,$00,$1C,$08,$F8,$00,$06,$C3,$50,$30,$38
	dc.b	$BF,$46,$02,$40,$00,$FF,$48,$A7,$81,$00,$4E,$B9,$00,$1D,$FB,$54
	dc.b	$34,$C0,$4C,$9F,$00,$81,$4E,$B9,$00,$01,$02,$B8,$34,$F8,$DD,$AA
	dc.b	$20,$7C,$FF,$FF,$D1,$30,$4E,$B9,$00,$1D,$FB,$7C,$30,$38,$BF,$46
	dc.b	$02,$40,$00,$FF,$D0,$40,$B0,$7C,$00,$26,$66,$00,$00,$0C,$31,$FC
	dc.b	$80,$00,$D1,$56,$60,$00,$00,$1A,$36,$3C,$00,$26,$32,$30,$00,$02
	dc.b	$31,$81,$00,$00,$54,$40,$B0,$43,$6D,$F2,$31,$BC,$80,$00,$00,$00
	dc.b	$3F,$00,$30,$3C,$00,$28,$53,$30,$00,$00,$30,$1F,$4E,$B9,$00,$1D
	dc.b	$FB,$94,$48,$E7,$FF,$FE,$20,$7C,$00,$20,$1B,$CC,$30,$38,$BF,$46
	dc.b	$02,$40,$00,$FF,$C0,$FC,$00,$0C,$D1,$C0,$2F,$08,$34,$3C,$00,$02
	dc.b	$14,$E8,$00,$01,$14,$E8,$00,$03,$58,$48,$51,$CA,$FF,$F4,$20,$5F
	dc.b	$30,$38,$BF,$46,$02,$40,$00,$FF,$B0,$7C,$00,$13,$67,$00,$00,$1A
	dc.b	$20,$A8,$00,$0C,$21,$68,$00,$10,$00,$04,$21,$68,$00,$14,$00,$08
	dc.b	$D0,$FC,$00,$0C,$52,$40,$60,$E0,$5C,$4A,$42,$47,$74,$03,$76,$14
	dc.b	$22,$3C,$00,$00,$6E,$E8,$4E,$B9,$00,$1D,$D4,$B6,$4C,$DF,$7F,$FF
	dc.b	$4E,$B9,$00,$02,$41,$AA,$4C,$DF,$7F,$FF,$4E,$75

GetCreatedId	;The player id word of created entry d0
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$7F,$FE,$20,$7C,$00,$20,$1B,$68,$D0,$40,$D0,$40,$D0,$C0
	dc.b	$30,$28,$00,$02,$02,$40,$00,$FF,$3E,$10,$E1,$4F,$02,$47,$FF,$00
	dc.b	$80,$47,$4C,$DF,$7F,$FE,$4E,$75

ReadCreateList	;Read the created players list from save RAM
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$C0,$00,$20,$3C,$00,$00,$0D,$B4,$72,$29,$4E,$B9,$00,$02
	dc.b	$41,$E8,$4C,$DF,$00,$03,$4E,$75

WriteCreateList	;Write the created players list to save RAM
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$C0,$00,$20,$3C,$00,$00,$0D,$B4,$72,$29,$4E,$B9,$00,$02
	dc.b	$41,$88,$4C,$DF,$00,$03,$4E,$75

SignFreeAgents	;The sign free agents screen (roster menu item Sign Free Agents)
	;Code the listing does not decode: kept as bytes
	dc.b	$4E,$B9,$00,$01,$AF,$52,$61,$00,$06,$C2,$20,$7C,$00,$19,$76,$2A
	dc.b	$4E,$B9,$00,$01,$21,$8A,$4E,$B9,$00,$1E,$0D,$66,$61,$00,$08,$CE
	dc.b	$30,$3C,$00,$03,$20,$7C,$FF,$FF,$C8,$E2,$42,$98,$51,$C8,$FF,$FC
	dc.b	$42,$79,$FF,$FF,$27,$16,$42,$79,$FF,$FF,$27,$10,$61,$00,$08,$14
	dc.b	$31,$FC,$00,$18,$BD,$3C,$08,$B8,$00,$02,$BF,$B2,$61,$00,$06,$6A
	dc.b	$67,$00,$05,$50,$3E,$39,$FF,$FF,$27,$16,$4E,$B9,$00,$1E,$0D,$86
	dc.b	$42,$79,$FF,$FF,$27,$12,$30,$39,$00,$20,$1B,$B8,$53,$00,$02,$40
	dc.b	$00,$FF,$B0,$7C,$00,$09,$6F,$00,$00,$06,$30,$3C,$00,$09,$33,$C0
	dc.b	$FF,$FF,$27,$14,$20,$7C,$FF,$FF,$3A,$98,$61,$00,$05,$74,$61,$00
	dc.b	$05,$B6,$31,$FC,$FF,$FF,$D0,$14,$4E,$B9,$00,$1D,$CC,$8A,$61,$00
	dc.b	$07,$B2,$4E,$B9,$00,$1D,$CC,$8A,$61,$00,$03,$26,$61,$00,$02,$5C
	dc.b	$46,$FC,$25,$00,$60,$00,$00,$2A,$0C,$78,$FF,$FF,$D0,$14,$67,$00
	dc.b	$00,$20,$4E,$B9,$00,$1D,$CC,$8A,$61,$00,$07,$88,$4E,$B9,$00,$1D
	dc.b	$CC,$8A,$61,$00,$02,$FC,$4E,$B9,$00,$1D,$CC,$8A,$61,$00,$02,$2C
	dc.b	$31,$FC,$FF,$FF,$D0,$14,$61,$00,$04,$32,$4A,$41,$67,$00,$04,$B2
	dc.b	$08,$01,$00,$00,$67,$00,$00,$2C,$4A,$79,$FF,$FF,$27,$10,$67,$00
	dc.b	$00,$0A,$53,$79,$FF,$FF,$27,$10,$60,$8E,$4A,$79,$FF,$FF,$27,$12
	dc.b	$67,$CE,$53,$79,$FF,$FF,$27,$12,$53,$79,$FF,$FF,$27,$14,$60,$00
	dc.b	$FF,$78,$08,$01,$00,$01,$67,$00,$00,$46,$30,$39,$FF,$FF,$27,$10
	dc.b	$D0,$79,$FF,$FF,$27,$12,$B0,$79,$FF,$FF,$27,$14,$67,$00,$00,$0C
	dc.b	$52,$79,$FF,$FF,$27,$10,$60,$00,$FF,$50,$30,$39,$00,$20,$1B,$B8
	dc.b	$02,$40,$00,$FF,$53,$40,$B0,$79,$FF,$FF,$27,$14,$6F,$82,$52,$79
	dc.b	$FF,$FF,$27,$12,$52,$79,$FF,$FF,$27,$14,$60,$00,$FF,$2C,$08,$01
	dc.b	$00,$04,$67,$00,$00,$1E,$52,$79,$FF,$FF,$27,$16,$0C,$79,$00,$1A
	dc.b	$FF,$FF,$27,$16,$6D,$00,$FF,$12,$42,$79,$FF,$FF,$27,$16,$60,$00
	dc.b	$FF,$08,$08,$01,$00,$06,$67,$00,$00,$18,$53,$79,$FF,$FF,$27,$16
	dc.b	$6A,$00,$FE,$F6,$33,$FC,$00,$19,$FF,$FF,$27,$16,$60,$00,$FE,$EA
	dc.b	$08,$01,$00,$07,$66,$00,$03,$EA,$08,$01,$00,$05,$67,$00,$01,$3C
	dc.b	$3E,$39,$FF,$FF,$27,$16,$20,$7C,$FF,$FF,$4E,$20,$30,$39,$FF,$FF
	dc.b	$27,$12,$D0,$79,$FF,$FF,$27,$10,$D0,$40,$30,$30,$00,$00,$48,$A7
	dc.b	$01,$00,$3E,$3C,$00,$1C,$02,$40,$00,$FF,$4E,$B9,$00,$01,$03,$AA
	dc.b	$31,$C0,$BF,$7C,$4A,$40,$4C,$9F,$00,$80,$66,$00,$00,$0E,$61,$00
	dc.b	$00,$FE,$67,$00,$01,$92,$66,$00,$00,$1C,$4E,$B9,$00,$01,$57,$B2
	dc.b	$3F,$00,$4E,$B9,$00,$01,$57,$74,$90,$5F,$44,$40,$B0,$7C,$00,$18
	dc.b	$67,$00,$01,$74,$20,$7C,$FF,$FF,$4E,$20,$30,$39,$FF,$FF,$27,$12
	dc.b	$D0,$79,$FF,$FF,$27,$10,$D0,$40,$30,$30,$00,$00,$31,$C0,$BF,$46
	dc.b	$3E,$3C,$00,$1C,$30,$38,$BF,$46,$4E,$B9,$00,$01,$02,$B8,$11,$F8
	dc.b	$DD,$AB,$BF,$46,$24,$7C,$FF,$FF,$D3,$C8,$3F,$38,$BF,$46,$08,$B8
	dc.b	$00,$06,$C3,$50,$4E,$B9,$00,$1D,$FA,$58,$31,$DF,$BF,$46,$31,$F9
	dc.b	$FF,$FF,$27,$16,$BF,$4C,$30,$38,$BF,$7C,$33,$C0,$FF,$FF,$27,$18
	dc.b	$3E,$39,$FF,$FF,$27,$16,$4A,$40,$67,$00,$00,$0C,$4E,$B9,$00,$01
	dc.b	$57,$B2,$60,$00,$00,$08,$4E,$B9,$00,$01,$57,$74,$32,$39,$FF,$FF
	dc.b	$27,$18,$E1,$49,$80,$41,$31,$C0,$BF,$48,$31,$F9,$FF,$FF,$27,$16
	dc.b	$BF,$4C,$24,$7C,$FF,$FF,$D3,$C8,$3F,$38,$BF,$46,$3F,$38,$BF,$48
	dc.b	$3F,$38,$BF,$4C,$4E,$B9,$00,$1D,$D5,$16,$31,$DF,$BF,$4C,$31,$DF
	dc.b	$BF,$48,$31,$DF,$BF,$46,$08,$B8,$00,$06,$C3,$50,$4E,$B9,$00,$02
	dc.b	$41,$AA,$61,$00,$06,$6A,$4A,$79,$FF,$FF,$27,$10,$67,$00,$00,$08
	dc.b	$53,$79,$FF,$FF,$27,$10,$60,$00,$FD,$54,$60,$00,$FD,$BC,$4E,$B9
	dc.b	$00,$01,$57,$74,$B0,$7C,$00,$03,$4E,$75

FreeAgentArrows	;Draw scroll up/down arrows for the list
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$FF,$FE,$4E,$B9,$00,$01,$BA,$2E,$00,$04,$FE,$07,$30,$39
	dc.b	$FF,$FF,$27,$12,$D0,$79,$FF,$FF,$27,$10,$67,$00,$00,$14,$4E,$B9
	dc.b	$00,$01,$BA,$2E,$00,$08,$FD,$02,$FC,$10,$7B,$00,$60,$00,$00,$10
	dc.b	$4E,$B9,$00,$01,$BA,$2E,$00,$08,$FD,$02,$FC,$10,$20,$00,$32,$39
	dc.b	$FF,$FF,$27,$10,$D2,$79,$FF,$FF,$27,$12,$30,$39,$00,$20,$1B,$B8
	dc.b	$02,$40,$00,$FF,$53,$40,$B2,$40,$6C,$00,$00,$14,$4E,$B9,$00,$01
	dc.b	$BA,$2E,$00,$08,$FD,$02,$FC,$19,$7D,$00,$60,$00,$00,$10,$4E,$B9
	dc.b	$00,$01,$BA,$2E,$00,$08,$FD,$02,$FC,$19,$20,$00,$4E,$B9,$00,$01
	dc.b	$BA,$2E,$00,$04,$FE,$07,$4C,$DF,$7F,$FF,$4E,$75,$61,$00,$04,$EC
	dc.b	$4E,$B9,$00,$01,$BA,$2E,$00,$24,$FE,$07,$FD,$18,$FC,$06,$56,$49
	dc.b	$4F,$4C,$41,$54,$49,$4F,$4E,$20,$4F,$46,$FD,$17,$FA,$01,$52,$4F
	dc.b	$53,$54,$45,$52,$20,$52,$55,$4C,$45,$53,$61,$00,$01,$54,$61,$00
	dc.b	$05,$22,$60,$00,$FC,$CA

DrawFreeAgents	;Draw visible free agent rows (pos, name, rating)
	;Code the listing does not decode: kept as bytes
	dc.b	$3A,$39,$FF,$FF,$27,$10,$2A,$7C,$FF,$FF,$27,$12,$28,$7C,$FF,$FF
	dc.b	$3A,$98,$26,$7C,$FF,$FF,$4E,$20,$31,$FC,$00,$10,$B0,$42,$3E,$3C
	dc.b	$00,$1C,$3F,$38,$B0,$42,$4E,$B9,$00,$01,$BB,$8E,$00,$06,$8F,$00
	dc.b	$00,$00,$31,$DF,$B0,$42,$42,$46,$30,$15,$E3,$40,$48,$C0,$D9,$C0
	dc.b	$D7,$C0,$4E,$B9,$00,$01,$BA,$2E,$00,$24,$FD,$02,$20,$20,$20,$20
	dc.b	$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$FB,$02,$20,$20,$20
	dc.b	$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$31,$FC,$00,$03
	dc.b	$B0,$40,$4E,$B9,$00,$01,$BA,$2E,$00,$04,$FE,$07,$BC,$45,$66,$00
	dc.b	$00,$0C,$4E,$B9,$00,$01,$BA,$2E,$00,$04,$FE,$06,$30,$13,$3E,$3C
	dc.b	$00,$1C,$4E,$B9,$00,$01,$01,$7A,$4E,$B9,$00,$01,$BC,$84,$31,$FC
	dc.b	$00,$16,$B0,$40,$22,$7C,$00,$1D,$D8,$FE,$3E,$3C,$00,$1C,$30,$1B
	dc.b	$4E,$B9,$00,$01,$03,$AA,$33,$C0,$FF,$FF,$27,$18,$4E,$B9,$00,$01
	dc.b	$D7,$F2,$4E,$B9,$00,$01,$BC,$84,$31,$FC,$00,$1F,$B0,$40,$30,$14
	dc.b	$4E,$B9,$00,$01,$01,$DC,$D2,$D1,$50,$49,$20,$49,$48,$E7,$00,$08
	dc.b	$28,$7C,$FF,$FF,$C8,$F2,$2C,$7C,$00,$1D,$F9,$FC,$28,$39,$00,$02
	dc.b	$35,$B8,$4A,$79,$FF,$FF,$27,$18,$67,$00,$00,$0E,$2C,$7C,$00,$1D
	dc.b	$F9,$EC,$28,$39,$00,$02,$34,$56,$4E,$B9,$00,$1D,$F8,$AC,$4C,$DF
	dc.b	$10,$00,$C0,$FC,$00,$64,$80,$C1,$4E,$B9,$00,$1D,$93,$02,$32,$3C
	dc.b	$00,$02,$4E,$B9,$00,$01,$BE,$1C,$4E,$B9,$00,$01,$BC,$84,$54,$8C
	dc.b	$52,$78,$B0,$42,$52,$46,$30,$39,$FF,$FF,$27,$12,$D0,$46,$B0,$79
	dc.b	$FF,$FF,$27,$14,$6F,$00,$FE,$FC,$4E,$75,$2C,$3C,$00,$00,$54,$60
	dc.b	$3C,$3C,$00,$64,$32,$38,$B0,$52,$92,$78,$B0,$54,$67,$F2,$31,$F8
	dc.b	$B0,$52,$B0,$54,$4E,$B9,$00,$01,$26,$40,$4E,$B9,$00,$01,$B3,$48
	dc.b	$4E,$B9,$00,$01,$B3,$20,$4A,$41,$67,$00,$00,$06,$60,$00,$00,$50
	dc.b	$4E,$B9,$00,$01,$B3,$60,$4E,$B9,$00,$01,$B3,$20,$4A,$41,$67,$00
	dc.b	$00,$06,$60,$00,$00,$3A,$4A,$78,$D2,$50,$67,$00,$00,$2E,$4E,$B9
	dc.b	$00,$01,$B3,$78,$4E,$B9,$00,$01,$B3,$20,$4A,$41,$67,$00,$00,$06
	dc.b	$60,$00,$00,$1C,$4E,$B9,$00,$01,$B3,$90,$4E,$B9,$00,$01,$B3,$20
	dc.b	$4A,$41,$67,$00,$00,$06,$60,$00,$00,$06,$51,$CE,$FF,$84,$4E,$75
	dc.b	$4E,$75,$42,$40,$60,$00,$00,$02,$48,$A7,$E0,$00,$61,$00,$02,$D6
	dc.b	$4C,$9F,$00,$07,$22,$7C,$00,$1E,$01,$78,$4E,$B9,$00,$01,$D7,$F2
	dc.b	$4E,$B9,$00,$01,$BC,$84,$61,$00,$FF,$52,$60,$D4

FreeAgentMsgText	;SignFreeAgents: the message when there are no free agents
	String	$8F,$18,$06,'No free agents.',$8F,$17,$07,'Press Any button',$8F,$16,$08,'to exit.'
	dc.b	$4E,$75

BuildFreeAgentList	;Copy the free agent list from save RAM to a work table and an index list
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$FF,$FE,$30,$39,$00,$20,$1B,$B8,$02,$40,$00,$FF,$67,$00
	dc.b	$00,$30,$53,$40,$20,$7C,$00,$20,$1B,$68,$22,$7C,$FF,$FF,$3A,$98
	dc.b	$2A,$7C,$FF,$FF,$4E,$20,$42,$46,$22,$18,$14,$01,$02,$42,$00,$FF
	dc.b	$48,$41,$E1,$49,$84,$41,$32,$C2,$3A,$C6,$52,$46,$51,$C8,$FF,$EA
	dc.b	$4C,$DF,$7F,$FF,$4E,$75,$48,$E7,$FF,$FE,$3A,$39,$00,$20,$1B,$B8
	dc.b	$02,$45,$00,$FF,$BA,$7C,$00,$02,$6D,$00,$00,$58,$55,$45,$3E,$3C
	dc.b	$00,$1C,$20,$7C,$FF,$FF,$3A,$98,$22,$7C,$FF,$FF,$4E,$20,$38,$05
	dc.b	$42,$46,$30,$11,$4E,$B9,$00,$01,$03,$AA,$3F,$00,$30,$29,$00,$02
	dc.b	$4E,$B9,$00,$01,$03,$AA,$B0,$5F,$6C,$00,$00,$1C,$50,$C6,$30,$11
	dc.b	$34,$29,$00,$02,$33,$40,$00,$02,$32,$82,$30,$10,$34,$28,$00,$02
	dc.b	$31,$40,$00,$02,$30,$82,$54,$48,$54,$49,$51,$CC,$FF,$C6,$4A,$46
	dc.b	$66,$B0,$4C,$DF,$7F,$FF,$4E,$75,$48,$A7,$80,$00,$30,$39,$00,$20
	dc.b	$1B,$B8,$4A,$00,$4C,$9F,$00,$01,$4E,$75,$08,$F8,$00,$05,$C3,$56
	dc.b	$21,$FC,$00,$01,$2D,$46,$D2,$44,$08,$B8,$00,$00,$BF,$B2,$08,$F8
	dc.b	$00,$02,$BF,$B2,$08,$B8,$00,$01,$BF,$B2,$31,$FC,$00,$00,$B0,$00
	dc.b	$31,$FC,$B8,$00,$B0,$02,$31,$FC,$B8,$00,$B0,$0C,$31,$FC,$00,$05
	dc.b	$B0,$0E,$31,$FC,$C0,$00,$B0,$08,$31,$FC,$00,$06,$B0,$0A,$31,$FC
	dc.b	$E0,$00,$B0,$04,$31,$FC,$00,$06,$B0,$06,$30,$3C,$00,$00,$08,$F8
	dc.b	$00,$05,$BF,$B2,$4E,$B9,$00,$01,$B5,$7E,$08,$B8,$00,$05,$BF,$B2
	dc.b	$4E,$B9,$00,$01,$B2,$C4,$38,$3C,$00,$01,$22,$7C,$00,$19,$76,$2A
	dc.b	$4E,$B9,$00,$01,$21,$7A,$31,$C4,$B0,$1C,$24,$7C,$00,$17,$91,$70
	dc.b	$4E,$B9,$00,$01,$B7,$30,$31,$C4,$B0,$1E,$24,$7C,$00,$17,$A1,$6C
	dc.b	$4E,$B9,$00,$01,$B7,$30,$21,$FC,$00,$17,$91,$68,$BF,$8A,$31,$C4
	dc.b	$B0,$18,$24,$7C,$00,$17,$B6,$88,$4E,$B9,$00,$01,$B7,$30,$08,$F8
	dc.b	$00,$02,$C3,$54,$4E,$B9,$00,$01,$BA,$2E,$00,$08,$FF,$01,$FD,$00
	dc.b	$FC,$00,$70,$28,$72,$1C,$34,$3C,$07,$FF,$4E,$B9,$00,$01,$B9,$76
	dc.b	$4E,$B9,$00,$01,$BB,$8E,$00,$06,$BF,$00,$00,$00,$20,$7C,$00,$19
	dc.b	$82,$60,$22,$48,$24,$48,$D1,$DA,$D3,$DA,$42,$40,$42,$41,$74,$28
	dc.b	$76,$1C,$7A,$08,$4E,$B9,$00,$01,$B6,$92,$4E,$B9,$00,$01,$BB,$8E
	dc.b	$00,$06,$BF,$0B,$01,$00,$20,$7C,$00,$19,$6E,$0A,$22,$48,$24,$48
	dc.b	$D1,$DA,$D3,$DA,$42,$40,$42,$41,$34,$11,$36,$29,$00,$02,$7A,$08
	dc.b	$4E,$B9,$00,$01,$B6,$92,$4E,$B9,$00,$01,$BB,$8E,$00,$06,$FE,$00
	dc.b	$00,$00,$20,$7C,$00,$17,$3C,$7A,$22,$48,$24,$48,$D1,$DA,$D3,$DA
	dc.b	$42,$40,$42,$41,$74,$40,$76,$1C,$7A,$01,$4E,$B9,$00,$01,$B6,$92
	dc.b	$33,$C4,$FF,$FF,$23,$28,$06,$44,$00,$C8,$08,$F8,$00,$02,$C3,$54
	dc.b	$4E,$B9,$00,$01,$BE,$D6,$00,$16,$F8,$04,$01,$15,$0C,$70,$6F,$73
	dc.b	$F8,$04,$01,$1C,$0C,$6F,$76,$65,$72,$61,$6C,$6C,$46,$FC,$25,$00
	dc.b	$4E,$75,$48,$E7,$FF,$FE,$3E,$39,$FF,$FF,$27,$16,$4E,$B9,$00,$01
	dc.b	$BB,$8E,$00,$06,$BF,$01,$04,$00,$38,$39,$FF,$FF,$23,$28,$3A,$3C
	dc.b	$00,$02,$4E,$B9,$00,$01,$2B,$B2,$31,$FC,$00,$64,$BD,$3C,$4C,$DF
	dc.b	$7F,$FF,$4E,$75,$48,$E7,$FF,$FE,$4E,$B9,$00,$01,$BA,$2E,$00,$58
	dc.b	$FE,$07,$FF,$01,$FD,$18,$FC,$06,$20,$20,$20,$20,$20,$20,$20,$20
	dc.b	$20,$20,$20,$20,$20,$20,$20,$FD,$17,$FA,$01,$20,$20,$20,$20,$20
	dc.b	$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$FD,$16,$FA,$01,$20
	dc.b	$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	dc.b	$FD,$15,$FA,$01,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	dc.b	$20,$20,$20,$20,$20,$00,$4C,$DF,$7F,$FF,$4E,$75,$48,$E7,$FF,$FE
	dc.b	$61,$92,$4E,$B9,$00,$01,$BC,$72,$00,$06,$8F,$18,$06,$00,$4E,$B9
	dc.b	$00,$01,$BA,$2E,$00,$44,$73,$74,$61,$72,$74,$2D,$65,$78,$69,$74
	dc.b	$FD,$17,$FA,$01,$63,$2D,$73,$69,$67,$6E,$20,$70,$6C,$61,$79,$65
	dc.b	$72,$FD,$16,$FA,$01,$7B,$7D,$73,$65,$6C,$65,$63,$74,$20,$70,$6C
	dc.b	$61,$79,$65,$72,$FD,$15,$FA,$01,$61,$2F,$62,$2D,$73,$77,$69,$74
	dc.b	$63,$68,$20,$74,$65,$61,$6D,$73,$4C,$DF,$7F,$FF,$4E,$75,$4E,$B9
	dc.b	$00,$01,$BB,$8E,$00,$06,$8F,$02,$10,$00,$34,$3C,$07,$FF,$30,$3C
	dc.b	$00,$0E,$32,$3C,$00,$0A,$4E,$B9,$00,$01,$B9,$76,$4E,$B9,$00,$01
	dc.b	$BB,$8E,$00,$06,$8F,$14,$10,$00,$34,$3C,$07,$FF,$30,$3C,$00,$10
	dc.b	$32,$3C,$00,$0A,$4E,$F9,$00,$01,$B9,$76

ReleasePlayers	;The release player screen (roster menu item Release Player)
	;Code the listing does not decode: kept as bytes
	dc.b	$4E,$B9,$00,$01,$AF,$52,$4E,$B9,$00,$1E,$0B,$76,$20,$7C,$00,$19
	dc.b	$97,$AE,$4E,$B9,$00,$01,$21,$8A,$4E,$B9,$00,$1E,$0D,$66,$61,$00
	dc.b	$07,$A8,$42,$79,$FF,$FF,$27,$16,$42,$79,$FF,$FF,$27,$10,$31,$FC
	dc.b	$00,$00,$C3,$A0,$31,$FC,$00,$00,$C3,$A2,$4E,$B9,$00,$02,$14,$82
	dc.b	$61,$00,$FE,$86,$31,$FC,$00,$18,$BD,$3C,$08,$B8,$00,$02,$BF,$B2
	dc.b	$30,$39,$00,$20,$1B,$B8,$02,$40,$00,$FF,$B0,$7C,$00,$14,$6C,$00
	dc.b	$05,$36,$42,$79,$FF,$FF,$27,$12,$3E,$39,$FF,$FF,$27,$16,$4E,$B9
	dc.b	$00,$1E,$0D,$86,$31,$C7,$C3,$A0,$31,$C7,$C3,$A2,$4E,$B9,$00,$02
	dc.b	$14,$82,$4E,$B9,$00,$01,$57,$B2,$53,$40,$B0,$7C,$00,$09,$6F,$00
	dc.b	$00,$06,$30,$3C,$00,$09,$33,$C0,$FF,$FF,$27,$14,$20,$7C,$FF,$FF
	dc.b	$3A,$98,$22,$7C,$FF,$FF,$2A,$F8,$61,$00,$C8,$CE,$61,$00,$05,$50
	dc.b	$31,$FC,$FF,$FF,$D0,$14,$4E,$B9,$00,$1D,$CC,$8A,$61,$00,$FE,$0A
	dc.b	$4E,$B9,$00,$1D,$CC,$8A,$61,$00,$03,$48,$61,$00,$02,$7C,$0C,$78
	dc.b	$FF,$FF,$D0,$14,$67,$00,$00,$16,$4E,$B9,$00,$1D,$CC,$8A,$61,$00
	dc.b	$FD,$E8,$4E,$B9,$00,$1D,$CC,$8A,$61,$00,$03,$26,$31,$FC,$FF,$FF
	dc.b	$D0,$14,$61,$00,$04,$1A,$4A,$41,$67,$00,$04,$9A,$08,$01,$00,$00
	dc.b	$67,$00,$00,$2A,$4A,$79,$FF,$FF,$27,$10,$67,$00,$00,$0A,$53,$79
	dc.b	$FF,$FF,$27,$10,$60,$A0,$4A,$79,$FF,$FF,$27,$12,$67,$CE,$53,$79
	dc.b	$FF,$FF,$27,$12,$53,$79,$FF,$FF,$27,$14,$60,$8A,$08,$01,$00,$01
	dc.b	$67,$00,$00,$48,$30,$39,$FF,$FF,$27,$10,$D0,$79,$FF,$FF,$27,$12
	dc.b	$B0,$79,$FF,$FF,$27,$14,$67,$00,$00,$0C,$52,$79,$FF,$FF,$27,$10
	dc.b	$60,$00,$FF,$64,$3E,$39,$FF,$FF,$27,$16,$4E,$B9,$00,$01,$57,$B2
	dc.b	$53,$40,$B0,$79,$FF,$FF,$27,$14,$6F,$82,$52,$79,$FF,$FF,$27,$12
	dc.b	$52,$79,$FF,$FF,$27,$14,$60,$00,$FF,$3E,$08,$01,$00,$04,$67,$00
	dc.b	$00,$32,$42,$79,$FF,$FF,$27,$10,$42,$79,$FF,$FF,$27,$12,$33,$FC
	dc.b	$00,$09,$FF,$FF,$27,$14,$52,$79,$FF,$FF,$27,$16,$0C,$79,$00,$1A
	dc.b	$FF,$FF,$27,$16,$6D,$00,$FE,$AA,$42,$79,$FF,$FF,$27,$16,$60,$00
	dc.b	$FE,$A0,$08,$01,$00,$06,$67,$00,$00,$2C,$42,$79,$FF,$FF,$27,$10
	dc.b	$42,$79,$FF,$FF,$27,$12,$33,$FC,$00,$09,$FF,$FF,$27,$14,$53,$79
	dc.b	$FF,$FF,$27,$16,$6A,$00,$FE,$7A,$33,$FC,$00,$19,$FF,$FF,$27,$16
	dc.b	$60,$00,$FE,$6E,$08,$01,$00,$07,$66,$00,$03,$AA,$08,$01,$00,$05
	dc.b	$67,$00,$01,$46,$3E,$39,$FF,$FF,$27,$16,$4E,$B9,$00,$01,$57,$B2
	dc.b	$B0,$7C,$00,$11,$67,$00,$01,$D0,$20,$7C,$FF,$FF,$3A,$98,$30,$39
	dc.b	$FF,$FF,$27,$12,$D0,$79,$FF,$FF,$27,$10,$E5,$40,$D0,$C0,$42,$40
	dc.b	$10,$28,$00,$01,$66,$00,$00,$0C,$4E,$B9,$00,$1E,$08,$72,$67,$00
	dc.b	$01,$A6,$20,$7C,$FF,$FF,$3A,$98,$30,$39,$FF,$FF,$27,$12,$D0,$79
	dc.b	$FF,$FF,$27,$10,$E5,$40,$D0,$C0,$11,$E8,$00,$01,$BF,$46,$11,$E8
	dc.b	$00,$02,$BF,$47,$31,$F9,$FF,$FF,$27,$16,$BF,$4A,$24,$7C,$FF,$FF
	dc.b	$D3,$C8,$4E,$B9,$00,$1D,$D2,$12,$31,$F9,$FF,$FF,$27,$16,$D0,$16
	dc.b	$31,$F9,$FF,$FF,$27,$16,$D0,$1E,$20,$7C,$00,$20,$1B,$68,$42,$78
	dc.b	$BF,$50,$4A,$28,$00,$01,$6B,$00,$00,$0A,$58,$88,$52,$78,$BF,$50
	dc.b	$60,$F0,$30,$38,$D3,$C8,$02,$40,$1F,$FF,$12,$38,$BF,$46,$02,$41
	dc.b	$00,$03,$34,$3C,$00,$0D,$E5,$69,$80,$41,$32,$00,$E0,$49,$02,$41
	dc.b	$00,$FF,$30,$81,$02,$40,$00,$FF,$31,$40,$00,$02,$48,$E7,$FF,$FE
	dc.b	$30,$38,$BF,$50,$C0,$FC,$00,$0C,$20,$7C,$00,$20,$1B,$CC,$D1,$C0
	dc.b	$24,$7C,$FF,$FF,$D3,$CC,$34,$3C,$00,$02,$11,$5A,$00,$01,$11,$5A
	dc.b	$00,$03,$58,$48,$51,$CA,$FF,$F4,$5C,$4A,$3F,$38,$BF,$48,$31,$F8
	dc.b	$BF,$50,$BF,$48,$42,$47,$74,$03,$76,$14,$22,$3C,$00,$00,$6E,$E8
	dc.b	$4E,$B9,$00,$1D,$D7,$D4,$31,$DF,$BF,$48,$4C,$DF,$7F,$FF,$52,$79
	dc.b	$00,$20,$1B,$B8,$08,$B8,$00,$06,$C3,$50,$4E,$B9,$00,$02,$41,$AA
	dc.b	$61,$00,$FC,$A2,$4A,$79,$FF,$FF,$27,$10,$67,$00,$00,$08,$53,$79
	dc.b	$FF,$FF,$27,$10,$60,$00,$FD,$1A,$60,$00,$FD,$94

CheckMinGoalies	;Z if team d7 has only 2 goalies (GetGoalieCountD7), so none can be released
	;Code the listing does not decode: kept as bytes
	dc.b	$4E,$B9,$00,$01,$57,$74,$B0,$7C,$00,$02,$4E,$75

ReleaseArrows	;Draw scroll arrows ({ above / } below) beside the roster list
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$FF,$FE,$4E,$B9,$00,$01,$BA,$2E,$00,$04,$FE,$07,$30,$39
	dc.b	$FF,$FF,$27,$12,$D0,$79,$FF,$FF,$27,$10,$67,$00,$00,$14,$4E,$B9
	dc.b	$00,$01,$BA,$2E,$00,$08,$FD,$02,$FC,$10,$7B,$00,$60,$00,$00,$10
	dc.b	$4E,$B9,$00,$01,$BA,$2E,$00,$08,$FD,$02,$FC,$10,$20,$00,$32,$39
	dc.b	$FF,$FF,$27,$10,$D2,$79,$FF,$FF,$27,$12,$3E,$39,$FF,$FF,$27,$16
	dc.b	$4E,$B9,$00,$01,$57,$B2,$53,$40,$B2,$40,$6C,$00,$00,$14,$4E,$B9
	dc.b	$00,$01,$BA,$2E,$00,$08,$FD,$02,$FC,$19,$7D,$00,$60,$00,$00,$10
	dc.b	$4E,$B9,$00,$01,$BA,$2E,$00,$08,$FD,$02,$FC,$19,$20,$00,$4E,$B9
	dc.b	$00,$01,$BA,$2E,$00,$04,$FE,$07,$4C,$DF,$7F,$FF,$4E,$75,$61,$00
	dc.b	$FB,$22,$4E,$B9,$00,$01,$BA,$2E,$00,$24,$FE,$07,$FD,$18,$FC,$06
	dc.b	$56,$49,$4F,$4C,$41,$54,$49,$4F,$4E,$20,$4F,$46,$FD,$17,$FA,$01
	dc.b	$52,$4F,$53,$54,$45,$52,$20,$52,$55,$4C,$45,$53,$61,$00,$01,$08
	dc.b	$61,$00,$03,$BE,$60,$00,$FC,$A8,$40,$E7

DrawReleaseRoster	;Draw the visible roster rows (pos letter, name, rating) with highlight on cursor row
	;Code the listing does not decode: kept as bytes
	dc.b	$3A,$39,$FF,$FF,$27,$10,$2A,$7C,$FF,$FF,$27,$12,$28,$7C,$FF,$FF
	dc.b	$3A,$98,$31,$FC,$00,$10,$B0,$42,$3E,$39,$FF,$FF,$27,$16,$3F,$38
	dc.b	$B0,$42,$4E,$B9,$00,$01,$BB,$8E,$00,$06,$8F,$00,$00,$00,$31,$DF
	dc.b	$B0,$42,$42,$46,$30,$15,$E5,$40,$48,$C0,$D9,$C0,$4E,$B9,$00,$01
	dc.b	$BA,$2E,$00,$24,$FD,$02,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	dc.b	$20,$20,$20,$20,$20,$FB,$02,$20,$20,$20,$20,$20,$20,$20,$20,$20
	dc.b	$20,$20,$20,$20,$20,$20,$31,$FC,$00,$03,$B0,$40,$4E,$B9,$00,$01
	dc.b	$BA,$2E,$00,$04,$FE,$07,$BC,$45,$66,$00,$00,$0C,$4E,$B9,$00,$01
	dc.b	$BA,$2E,$00,$04,$FE,$06,$42,$40,$10,$2C,$00,$02,$4E,$B9,$00,$01
	dc.b	$01,$7A,$4E,$B9,$00,$01,$BC,$84,$31,$FC,$00,$16,$B0,$40,$22,$7C
	dc.b	$00,$1D,$D8,$FE,$42,$40,$10,$2C,$00,$01,$33,$C0,$FF,$FF,$27,$18
	dc.b	$4E,$B9,$00,$01,$D7,$F2,$4E,$B9,$00,$01,$BC,$84,$31,$FC,$00,$1F
	dc.b	$B0,$40,$42,$40,$10,$2C,$00,$03,$4E,$B9,$00,$1D,$93,$02,$32,$3C
	dc.b	$00,$02,$4E,$B9,$00,$01,$BE,$1C,$4E,$B9,$00,$01,$BC,$84,$58,$8C
	dc.b	$52,$78,$B0,$42,$52,$46,$30,$39,$FF,$FF,$27,$12,$D0,$46,$B0,$79
	dc.b	$FF,$FF,$27,$14,$6F,$00,$FF,$46,$46,$DF,$4E,$75,$2C,$3C,$00,$00
	dc.b	$54,$60,$3C,$3C,$00,$64,$32,$38,$B0,$52,$92,$78,$B0,$54,$67,$F2
	dc.b	$31,$F8,$B0,$52,$B0,$54,$4E,$B9,$00,$01,$26,$40,$4E,$B9,$00,$01
	dc.b	$B3,$48,$4E,$B9,$00,$01,$B3,$20,$4A,$41,$67,$00,$00,$06,$60,$00
	dc.b	$00,$50,$4E,$B9,$00,$01,$B3,$60,$4E,$B9,$00,$01,$B3,$20,$4A,$41
	dc.b	$67,$00,$00,$06,$60,$00,$00,$3A,$4A,$78,$D2,$50,$67,$00,$00,$2E
	dc.b	$4E,$B9,$00,$01,$B3,$78,$4E,$B9,$00,$01,$B3,$20,$4A,$41,$67,$00
	dc.b	$00,$06,$60,$00,$00,$1C,$4E,$B9,$00,$01,$B3,$90,$4E,$B9,$00,$01
	dc.b	$B3,$20,$4A,$41,$67,$00,$00,$06,$60,$00,$00,$06,$51,$CE,$FF,$84
	dc.b	$4E,$75,$4E,$75,$42,$40,$60,$00,$00,$02,$48,$A7,$E0,$00,$61,$00
	dc.b	$F9,$58,$4C,$9F,$00,$07,$22,$7C,$00,$1E,$0A,$F6,$4E,$B9,$00,$01
	dc.b	$D7,$F2,$4E,$B9,$00,$01,$BC,$84,$61,$00,$FF,$52,$60,$D4

ReleaseMsgText	;ReleasePlayers: the message when the free agent list is full
	String	$8F,$18,$06,'Free agent list',$8F,$17,$07,'is full.',$8F,$16,$08,'Press any button',$8F,$15,$09,'to exit.'
	dc.b	$48,$E7,$FF,$FE,$4E,$B9,$00,$01,$57,$B2,$55,$40,$3A,$00,$20,$7C
	dc.b	$FF,$FF,$3A,$98,$38,$05,$42,$46,$10,$28,$00,$01,$B0,$28,$00,$05
	dc.b	$6F,$00,$00,$10,$50,$C6,$20,$10,$24,$28,$00,$04,$21,$40,$00,$04
	dc.b	$20,$82,$58,$48,$51,$CC,$FF,$E2,$4A,$46,$66,$D2,$4C,$DF,$7F,$FF
	dc.b	$4E,$75

ReleaseGfx	;Release Player screen video set up: fonts, bitmaps and the pos / overall headers
	;Code the listing does not decode: kept as bytes
	dc.b	$08,$F8,$00,$05,$C3,$56,$21,$FC,$00,$01,$2D,$46,$D2,$44,$08,$B8
	dc.b	$00,$00,$BF,$B2,$08,$F8,$00,$02,$BF,$B2,$08,$B8,$00,$01,$BF,$B2
	dc.b	$31,$FC,$00,$00,$B0,$00,$31,$FC,$B8,$00,$B0,$02,$31,$FC,$B8,$00
	dc.b	$B0,$0C,$31,$FC,$00,$05,$B0,$0E,$31,$FC,$C0,$00,$B0,$08,$31,$FC
	dc.b	$00,$06,$B0,$0A,$31,$FC,$E0,$00,$B0,$04,$31,$FC,$00,$06,$B0,$06
	dc.b	$30,$3C,$00,$00,$08,$F8,$00,$05,$BF,$B2,$4E,$B9,$00,$01,$B5,$7E
	dc.b	$08,$B8,$00,$05,$BF,$B2,$4E,$B9,$00,$01,$B2,$C4,$38,$3C,$00,$01
	dc.b	$22,$7C,$00,$19,$97,$AE,$4E,$B9,$00,$01,$21,$7A,$31,$C4,$B0,$1C
	dc.b	$24,$7C,$00,$17,$91,$70,$4E,$B9,$00,$01,$B7,$30,$31,$C4,$B0,$1E
	dc.b	$24,$7C,$00,$17,$A1,$6C,$4E,$B9,$00,$01,$B7,$30,$21,$FC,$00,$17
	dc.b	$91,$68,$BF,$8A,$31,$C4,$B0,$18,$24,$7C,$00,$17,$B6,$88,$4E,$B9
	dc.b	$00,$01,$B7,$30,$08,$F8,$00,$02,$C3,$54,$4E,$B9,$00,$01,$BA,$2E
	dc.b	$00,$08,$FF,$01,$FD,$00,$FC,$00,$70,$28,$72,$1C,$34,$3C,$07,$FF
	dc.b	$4E,$B9,$00,$01,$B9,$76,$4E,$B9,$00,$01,$BB,$8E,$00,$06,$BF,$00
	dc.b	$00,$00,$20,$7C,$00,$19,$82,$60,$22,$48,$24,$48,$D1,$DA,$D3,$DA
	dc.b	$42,$40,$42,$41,$74,$28,$76,$1C,$7A,$08,$4E,$B9,$00,$01,$B6,$92
	dc.b	$4E,$B9,$00,$01,$BB,$8E,$00,$06,$BF,$0B,$01,$00,$20,$7C,$00,$19
	dc.b	$7A,$60,$22,$48,$24,$48,$D1,$DA,$D3,$DA,$42,$40,$42,$41,$34,$11
	dc.b	$36,$29,$00,$02,$7A,$08,$4E,$B9,$00,$01,$B6,$92,$4E,$B9,$00,$01
	dc.b	$BB,$8E,$00,$06,$FE,$00,$00,$00,$20,$7C,$00,$17,$3C,$7A,$22,$48
	dc.b	$24,$48,$D1,$DA,$D3,$DA,$42,$40,$42,$41,$74,$40,$76,$1C,$7A,$01
	dc.b	$4E,$B9,$00,$01,$B6,$92,$33,$C4,$FF,$FF,$23,$28,$06,$44,$00,$C8
	dc.b	$08,$F8,$00,$02,$C3,$54,$4E,$B9,$00,$01,$BE,$D6,$00,$16,$F8,$04
	dc.b	$01,$15,$0C,$70,$6F,$73,$F8,$04,$01,$1C,$0C,$6F,$76,$65,$72,$61
	dc.b	$6C,$6C,$46,$FC,$25,$00,$4E,$75,$48,$E7,$FF,$FE,$61,$00,$F7,$2C
	dc.b	$4E,$B9,$00,$01,$BC,$72,$00,$06,$8F,$18,$06,$00,$4E,$B9,$00,$01
	dc.b	$BA,$2E,$00,$48,$73,$74,$61,$72,$74,$2D,$65,$78,$69,$74,$FD,$17
	dc.b	$FA,$01,$63,$2D,$72,$65,$6C,$65,$61,$73,$65,$20,$70,$6C,$61,$79
	dc.b	$65,$72,$FD,$16,$FA,$01,$7B,$7D,$73,$65,$6C,$65,$63,$74,$20,$70
	dc.b	$6C,$61,$79,$65,$72,$FD,$15,$FA,$01,$61,$2F,$62,$2D,$73,$77,$69
	dc.b	$74,$63,$68,$20,$74,$65,$61,$6D,$73,$00,$4C,$DF,$7F,$FF,$4E,$75

PStatsPalette2	;The PStatsPalette palette to palfadenew+$40 (sign free agents and release screens)
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$00,$C0,$20,$7C,$00,$17,$C2,$AE,$22,$7C,$FF,$FF,$BD,$7E
	dc.b	$30,$3C,$00,$07,$22,$D8,$51,$C8,$FF,$FC,$4C,$DF,$03,$00,$4E,$75

sub_1E0D86	;Called from ExecuteTrade, SignFreeAgents and ReleasePlayers
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$FF,$FE,$30,$39,$00,$20,$00,$00,$53,$00,$B0,$07,$66,$00
	dc.b	$00,$06,$61,$00,$00,$2C,$30,$39,$00,$20,$18,$72,$53,$00,$B0,$07
	dc.b	$66,$00,$00,$06,$61,$00,$00,$24,$4C,$DF,$7F,$FF,$4E,$75,$48,$E7
	dc.b	$FF,$FE,$61,$00,$00,$0C,$61,$00,$00,$12,$4C,$DF,$7F,$FF,$4E,$75
	dc.b	$70,$00,$72,$41,$4E,$F9,$00,$02,$42,$08,$20,$3C,$00,$00,$0C,$39
	dc.b	$72,$41,$4E,$F9,$00,$02,$42,$08

