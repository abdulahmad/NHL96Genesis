;	The sound driver, the Z80 program, the sound bank and the sound calls.
;	newcheck, the check sound, is at the end.

p_music_vblank						;Read the pads (ReadJoyData), then SoundCmd 1: the sound driver's vblank
									;update. Called from the vblank handlers.
									;Code the listing does not decode: kept as bytes
	dc.b	$61,$00,$FD,$9E,$30,$3C,$00,$01,$4E,$B9,$00,$08,$83,$9E,$4E,$75

SndDriver							;Sound driver entry (SoundCmd). d0 = command 0-$12 through SndJumpTable;
									;carry set and d0 = 1 for a bad command
	dc.w	$0C40,$0013				;cmpi.w #$13,d0 (the build turns cmpi.w #,d0 into cmp.w)
	bcc.s	.0
	move.l	a6,-(sp)
	lea	SndJumpTable(pc),a6
	andi.l	#$FFFF,d0
	lsl.l	#2,d0
	adda.l	d0,a6
	jsr	(a6)
	movea.l	(sp)+,a6
	rts
.0
	move.w	#1,d0
	ori	#1,ccr
	rts

SndJumpTable						;The command handlers: 0 SndLoadZ80, 1 SndUpdate, 2 off, 3 on, 4
									;SndStartSeq, 5 SndStopSeq, 6 SndSetBank,
									;7 SndLoadList, 8 SndFreeBlocks, 9 SndResetBlocks, $A SndQueueZ80Cmd, $B
									;SndReadBlock, $C SndWriteBlock, $D SndPauseZ80, $E SndResumeZ80, $F
									;SndStopAll, $10 SndSongControl, $11 SndFindSong, $12 SndSendZ80
	bra.w	SndLoadZ80
	bra.w	SndUpdate
	bra.w	SndDriverOff
	bra.w	SndDriverOn
	bra.w	SndStartSeq
	bra.w	SndStopSeq
	bra.w	SndSetBank
	bra.w	SndLoadList
	bra.w	SndFreeBlocks
	bra.w	SndResetBlocks
	bra.w	SndQueueZ80Cmd
	bra.w	SndReadBlock
	bra.w	SndWriteBlock
	bra.w	SndPauseZ80
	bra.w	SndResumeZ80
	bra.w	SndStopAll
	bra.w	SndSongControl
	bra.w	SndFindSong
	bra.w	SndSendZ80

SndDriverOn							;Command 3: the driver on (SndDrvRAM = $1234).
									;Code the listing does not decode: kept as bytes
	dc.b	$2F,$08,$41,$F9,$FF,$FF,$FD,$FC,$30,$BC,$12,$34,$20,$5F,$42,$40
	dc.b	$4E,$75

SndDriverOff						;Command 2: the driver off (SndDrvRAM = 0).
									;Code the listing does not decode: kept as bytes
	dc.b	$2F,$08,$41,$F9,$FF,$FF,$FD,$FC,$42,$50,$20,$5F,$42,$40,$4E,$75

SndLoadZ80							;Command 0: copy the Z80 program a0 (d1 bytes; it must start with JP
									;$00xx) to Z80 RAM, reset the Z80, wait
									;for it to set Z80_RAM+$4F, clear the song slots and notes, and turn the
									;driver on. Carry set and d0 = 6 for a bad program.
									;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$40,$E0,$40,$E7,$46,$FC,$27,$00,$33,$FC,$01,$00,$00,$A1
	dc.b	$11,$00,$33,$FC,$01,$00,$00,$A1,$12,$00,$0C,$10,$00,$C3,$66,$12
	dc.b	$43,$F9,$00,$A0,$00,$00,$04,$41,$00,$01,$12,$D8,$51,$C9,$FF,$FC
	dc.b	$60,$08,$30,$3C,$00,$06,$60,$00,$00,$E2,$33,$FC,$00,$00,$00,$A1
	dc.b	$12,$00,$33,$FC,$00,$00,$00,$A1,$11,$00,$30,$3C,$01,$F4,$51,$C8
	dc.b	$FF,$FE,$33,$FC,$01,$00,$00,$A1,$12,$00,$61,$00,$0F,$5C,$0C,$39
	dc.b	$00,$FF,$00,$A0,$00,$4F,$67,$0E,$61,$00,$0F,$62,$30,$3C,$13,$88
	dc.b	$51,$C8,$FF,$FE,$60,$E4,$61,$00,$0F,$54,$41,$F9,$FF,$FF,$FF,$DC
	dc.b	$30,$3C,$00,$03,$20,$FC,$FF,$FF,$FF,$FF,$51,$C8,$FF,$F8,$41,$F9
	dc.b	$FF,$FF,$FD,$FE,$30,$3C,$00,$07,$20,$FC,$FF,$FF,$FF,$FF,$51,$C8
	dc.b	$FF,$F8,$41,$F9,$FF,$FF,$FE,$1E,$30,$3C,$00,$07,$20,$FC,$00,$00
	dc.b	$00,$00,$51,$C8,$FF,$F8,$41,$F9,$FF,$FF,$FE,$3E,$30,$3C,$00,$07
	dc.b	$30,$FC,$FF,$FF,$51,$C8,$FF,$FA,$41,$F9,$FF,$FF,$FE,$7E,$30,$3C
	dc.b	$00,$07,$20,$FC,$00,$00,$00,$00,$51,$C8,$FF,$F8,$61,$00,$09,$18
	dc.b	$41,$F9,$FF,$FF,$FF,$4E,$30,$3C,$00,$1F,$42,$98,$51,$C8,$FF,$FC
	dc.b	$41,$F9,$FF,$FF,$FF,$CE,$42,$50,$41,$F9,$FF,$FF,$FF,$D0,$42,$50
	dc.b	$41,$F9,$FF,$FF,$FD,$FC,$30,$BC,$12,$34,$41,$F9,$FF,$FF,$FF,$4C
	dc.b	$42,$50,$02,$3C,$00,$FE,$42,$40,$60,$04,$00,$3C,$00,$01,$46,$DF
	dc.b	$4C,$DF,$07,$02,$4E,$75

SndUpdate							;Command 1, once a frame: note timers (SndUpdateNotes), sample streaming
									;(SndStreamZ80), then step the 8 song
									;slots: wait out each slot's delay, then send its events ($9x note on, $Bx
									;controller, $Cx program, $Ex pitch bend) to the Z80 until the next delay.
									;Controller $75 loops the song; status $FF ends it. Code the listing does
									;not decode: kept as bytes
	dc.b	$48,$E7,$FF,$FE,$41,$F9,$FF,$FF,$FF,$4C,$06,$50,$00,$01,$0C,$50
	dc.b	$00,$01,$66,$00,$03,$4C,$41,$F9,$FF,$FF,$FD,$FC,$0C,$50,$12,$34
	dc.b	$66,$00,$03,$3E,$61,$00,$0E,$20,$61,$00,$09,$58,$61,$00,$09,$D0
	dc.b	$41,$F9,$FF,$FF,$FF,$40,$30,$BC,$00,$00,$4D,$F9,$FF,$FF,$FD,$FE
	dc.b	$4B,$F9,$FF,$FF,$FE,$1E,$49,$F9,$FF,$FF,$FE,$4E,$47,$F9,$FF,$FF
	dc.b	$FE,$5E,$45,$F9,$FF,$FF,$FE,$6E,$43,$F9,$FF,$FF,$FE,$7E,$3C,$39
	dc.b	$FF,$FF,$FF,$40,$E3,$4E,$3E,$06,$E3,$4F,$0C,$B6,$FF,$FF,$FF,$FF
	dc.b	$70,$00,$67,$00,$02,$DA,$4A,$74,$60,$00,$67,$42,$32,$33,$60,$00
	dc.b	$D2,$72,$60,$00,$34,$01,$02,$42,$00,$FF,$E0,$49,$D2,$71,$70,$00
	dc.b	$33,$BC,$00,$00,$70,$00,$B2,$74,$60,$00,$64,$12,$36,$34,$60,$00
	dc.b	$96,$41,$39,$83,$60,$00,$35,$82,$60,$00,$60,$00,$02,$A2,$92,$74
	dc.b	$60,$00,$E1,$49,$82,$42,$35,$81,$60,$00,$42,$74,$60,$00,$20,$76
	dc.b	$70,$00,$2A,$35,$70,$00,$4A,$30,$58,$00,$6A,$08,$06,$85,$00,$00
	dc.b	$00,$01,$60,$F2,$06,$85,$00,$00,$00,$01,$4A,$30,$58,$00,$6A,$0C
	dc.b	$13,$B0,$58,$00,$70,$02,$06,$85,$00,$00,$00,$01,$10,$31,$70,$02
	dc.b	$02,$00,$00,$F0,$0C,$00,$00,$90,$66,$00,$00,$8C,$30,$39,$FF,$FF
	dc.b	$FF,$40,$E1,$48,$E9,$48,$10,$30,$58,$01,$48,$40,$10,$30,$58,$00
	dc.b	$E1,$48,$10,$31,$70,$02,$61,$00,$03,$BE,$4A,$40,$67,$0A,$06,$71
	dc.b	$00,$01,$70,$00,$60,$00,$02,$28,$14,$30,$58,$00,$E1,$4A,$42,$80
	dc.b	$06,$85,$00,$00,$00,$01,$06,$85,$00,$00,$00,$01,$EF,$88,$12,$30
	dc.b	$58,$00,$02,$01,$00,$7F,$80,$01,$08,$30,$00,$07,$58,$00,$66,$E6
	dc.b	$06,$85,$00,$00,$00,$01,$E1,$88,$36,$33,$60,$00,$B0,$43,$64,$06
	dc.b	$30,$3C,$00,$01,$60,$02,$80,$C3,$48,$40,$30,$02,$32,$39,$FF,$FF
	dc.b	$FF,$40,$E9,$49,$10,$31,$70,$02,$02,$00,$00,$0F,$80,$01,$61,$00
	dc.b	$07,$D4,$60,$00,$01,$9C,$0C,$00,$00,$B0,$66,$00,$01,$18,$0C,$30
	dc.b	$00,$12,$58,$00,$66,$04,$60,$00,$00,$D6,$0C,$30,$00,$75,$58,$00
	dc.b	$66,$36,$42,$80,$10,$30,$58,$01,$E3,$88,$06,$80,$00,$00,$00,$02
	dc.b	$42,$81,$12,$30,$08,$00,$E1,$89,$12,$30,$08,$01,$42,$80,$10,$10
	dc.b	$E1,$88,$10,$28,$00,$01,$E3,$88,$06,$80,$00,$00,$00,$02,$D2,$80
	dc.b	$2B,$81,$70,$00,$60,$00,$FE,$88,$0C,$30,$00,$77,$58,$00,$66,$56
	dc.b	$41,$F9,$FF,$FF,$FE,$9E,$42,$80,$30,$39,$FF,$FF,$FF,$40,$E5,$88
	dc.b	$D1,$C0,$20,$05,$06,$80,$00,$00,$00,$02,$20,$80,$42,$80,$20,$76
	dc.b	$70,$00,$10,$30,$58,$01,$E3,$88,$06,$80,$00,$00,$00,$02,$42,$81
	dc.b	$12,$30,$08,$00,$E1,$89,$12,$30,$08,$01,$42,$80,$10,$10,$E1,$88
	dc.b	$10,$28,$00,$01,$E3,$88,$06,$80,$00,$00,$00,$02,$D2,$80,$2B,$81
	dc.b	$70,$00,$60,$00,$FE,$2A,$0C,$30,$00,$78,$58,$00,$66,$30,$41,$F9
	dc.b	$FF,$FF,$FE,$9E,$42,$80,$30,$39,$FF,$FF,$FF,$40,$E5,$88,$D1,$C0
	dc.b	$0C,$90,$FF,$FF,$FF,$FF,$66,$0C,$2D,$BC,$FF,$FF,$FF,$FF,$70,$00
	dc.b	$60,$00,$00,$EC,$2A,$10,$20,$76,$70,$00,$60,$00,$00,$B4,$30,$39
	dc.b	$FF,$FF,$FF,$40,$E1,$48,$E9,$48,$10,$30,$58,$01,$48,$40,$10,$30
	dc.b	$58,$00,$E1,$48,$10,$31,$70,$02,$61,$00,$02,$4C,$4A,$40,$67,$0A
	dc.b	$06,$71,$00,$01,$70,$00,$60,$00,$00,$B6,$06,$85,$00,$00,$00,$02
	dc.b	$60,$00,$00,$7E,$0C,$00,$00,$C0,$66,$30,$30,$39,$FF,$FF,$FF,$40
	dc.b	$E1,$48,$E9,$48,$48,$40,$10,$30,$58,$00,$E1,$48,$10,$31,$70,$02
	dc.b	$61,$00,$02,$14,$4A,$40,$67,$0A,$06,$71,$00,$01,$70,$00,$60,$00
	dc.b	$00,$7E,$06,$85,$00,$00,$00,$01,$60,$46,$0C,$00,$00,$E0,$66,$2E
	dc.b	$30,$39,$FF,$FF,$FF,$40,$E1,$48,$E9,$48,$48,$40,$10,$30,$58,$00
	dc.b	$E1,$48,$10,$31,$70,$02,$61,$00,$01,$DE,$4A,$40,$67,$08,$06,$71
	dc.b	$00,$01,$70,$00,$60,$48,$06,$85,$00,$00,$00,$01,$60,$12,$0C,$31
	dc.b	$00,$FF,$70,$02,$66,$0A,$2D,$BC,$FF,$FF,$FF,$FF,$70,$00,$60,$2E
	dc.b	$2B,$85,$70,$00,$42,$82,$EF,$8A,$12,$30,$58,$00,$02,$01,$00,$7F
	dc.b	$84,$01,$08,$30,$00,$07,$58,$00,$67,$08,$06,$85,$00,$00,$00,$01
	dc.b	$60,$E4,$39,$82,$60,$00,$4A,$42,$66,$04,$60,$00,$FD,$12,$41,$F9
	dc.b	$FF,$FF,$FF,$40,$06,$50,$00,$01,$0C,$50,$00,$07,$6D,$00,$FD,$00
	dc.b	$41,$F9,$FF,$FF,$FF,$4C,$04,$50,$00,$01,$02,$3C,$00,$FE,$4C,$DF
	dc.b	$7F,$FF,$4E,$75

SndStartSeq							;Command 4: play song d1 (bank item type 3) in the first free slot, with
									;d2-d4 (d4 = tempo). Carry set for no
									;free slot (d0 = 7) or no such song.
									;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$78,$C0,$41,$F9,$FF,$FF,$FD,$FC,$31,$41,$01,$D8,$31,$42
	dc.b	$01,$DA,$31,$43,$01,$DC,$31,$44,$01,$DE,$0C,$44,$00,$00,$66,$08
	dc.b	$30,$3C,$00,$05,$60,$00,$00,$D0,$43,$F9,$FF,$FF,$FD,$FE,$42,$40
	dc.b	$0C,$99,$FF,$FF,$FF,$FF,$67,$12,$06,$40,$00,$01,$0C,$40,$00,$07
	dc.b	$66,$EE,$30,$3C,$00,$07,$60,$00,$00,$AE,$31,$40,$01,$D6,$3F,$01
	dc.b	$E1,$48,$E9,$48,$48,$40,$30,$3C,$01,$FF,$22,$00,$61,$00,$0A,$2A
	dc.b	$32,$1F,$30,$3C,$00,$03,$61,$00,$07,$82,$65,$00,$00,$8A,$42,$81
	dc.b	$12,$10,$E1,$49,$12,$28,$00,$01,$E3,$49,$06,$41,$00,$02,$43,$F9
	dc.b	$FF,$FF,$FD,$FC,$3F,$29,$00,$00,$33,$7C,$00,$00,$00,$00,$30,$29
	dc.b	$01,$D6,$E5,$48,$23,$88,$00,$02,$23,$81,$00,$22,$41,$F9,$FF,$FF
	dc.b	$FE,$7E,$21,$BC,$00,$00,$00,$00,$00,$00,$41,$F9,$FF,$FF,$FE,$9E
	dc.b	$21,$BC,$FF,$FF,$FF,$FF,$00,$00,$30,$29,$01,$D6,$E3,$48,$33,$A9
	dc.b	$01,$DE,$00,$62,$33,$BC,$00,$00,$00,$52,$33,$BC,$00,$00,$00,$72
	dc.b	$33,$A9,$01,$D8,$00,$42,$30,$29,$01,$D6,$E1,$48,$E9,$48,$80,$69
	dc.b	$01,$DC,$48,$40,$30,$3C,$10,$B0,$22,$00,$61,$00,$09,$9C,$33,$5F
	dc.b	$00,$00,$42,$40,$60,$04,$00,$3C,$00,$01,$4C,$DF,$03,$1E,$4E,$75

SndStopSeq							;Command 5: stop the slot playing song id d1 and release its notes. Carry
									;set and d0 = 3 when none plays it.
									;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$60,$80,$41,$F9,$FF,$FF,$FE,$3E,$42,$40,$B2,$58,$67,$14
	dc.b	$06,$40,$00,$01,$0C,$40,$00,$07,$66,$F2,$30,$3C,$00,$03,$00,$3C
	dc.b	$00,$01,$60,$38,$41,$F9,$FF,$FF,$FD,$FC,$31,$40,$01,$D6,$E3,$48
	dc.b	$41,$F9,$FF,$FF,$FE,$3E,$31,$BC,$FF,$FF,$00,$00,$E3,$48,$41,$F9
	dc.b	$FF,$FF,$FD,$FE,$21,$BC,$FF,$FF,$FF,$FF,$00,$00,$41,$F9,$FF,$FF
	dc.b	$FD,$FC,$30,$28,$01,$D6,$61,$00,$04,$3E,$42,$40,$4C,$DF,$01,$06
	dc.b	$4E,$75

SndPutZ80Cmd						;Queue the 4 byte Z80 command d0 (Z80_RAM+$D + 4 * count, count at +$C,
									;waits while +$B is busy). d0 = -1 when
									;it is full.
									;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$40,$80,$41,$F9,$FF,$FF,$FD,$FC,$3F,$28,$00,$00,$31,$7C
	dc.b	$00,$00,$00,$00,$61,$00,$09,$A6,$41,$F9,$00,$A0,$00,$0B,$4A,$10
	dc.b	$67,$14,$33,$FC,$00,$00,$00,$A1,$11,$00,$32,$3C,$00,$64,$04,$41
	dc.b	$00,$01,$66,$FA,$60,$DE,$D1,$FC,$00,$00,$00,$01,$0C,$10,$00,$10
	dc.b	$6D,$06,$30,$3C,$FF,$FF,$60,$26,$42,$41,$12,$10,$E5,$49,$11,$80
	dc.b	$10,$01,$E0,$48,$11,$80,$10,$02,$48,$40,$11,$80,$10,$03,$E0,$48
	dc.b	$11,$80,$10,$04,$12,$10,$06,$01,$00,$01,$10,$81,$42,$40,$61,$00
	dc.b	$09,$60,$41,$F9,$FF,$FF,$FD,$FC,$31,$5F,$00,$00,$4C,$DF,$01,$02
	dc.b	$4E,$75

SndUploadBlock						;Copy d1 bytes from a0 to free Z80 RAM as block d0 (the 42 six byte
									;entries at Z80_RAM+$100). Carry set: no
									;room (d0 = 4), already there (d0 = 3) or no free entry (d0 = 7).
									;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$60,$C0,$43,$F9,$FF,$FF,$FD,$FC,$3F,$11,$32,$BC,$00,$00
	dc.b	$61,$00,$09,$28,$14,$39,$00,$A0,$00,$05,$E1,$4A,$14,$39,$00,$A0
	dc.b	$00,$06,$D4,$41,$0C,$42,$1F,$00,$65,$18,$61,$00,$09,$22,$43,$F9
	dc.b	$FF,$FF,$FD,$FC,$32,$9F,$30,$3C,$00,$04,$00,$3C,$00,$01,$60,$00
	dc.b	$00,$D6,$43,$F9,$00,$A0,$01,$00,$34,$3C,$00,$29,$0C,$11,$00,$00
	dc.b	$66,$1E,$B0,$29,$00,$01,$66,$18,$61,$00,$08,$F4,$43,$F9,$FF,$FF
	dc.b	$FD,$FC,$32,$9F,$30,$3C,$00,$03,$00,$3C,$00,$01,$60,$00,$00,$A8
	dc.b	$D3,$FC,$00,$00,$00,$06,$51,$CA,$FF,$D4,$43,$F9,$00,$A0,$01,$00
	dc.b	$34,$3C,$00,$29,$0C,$11,$00,$FF,$67,$22,$D3,$FC,$00,$00,$00,$06
	dc.b	$51,$CA,$FF,$F2,$61,$00,$08,$B8,$43,$F9,$FF,$FF,$FD,$FC,$32,$9F
	dc.b	$30,$3C,$00,$07,$00,$3C,$00,$01,$60,$00,$00,$6C,$12,$BC,$00,$00
	dc.b	$13,$40,$00,$01,$34,$01,$13,$42,$00,$03,$E0,$4A,$13,$42,$00,$02
	dc.b	$14,$39,$00,$A0,$00,$05,$13,$42,$00,$04,$14,$39,$00,$A0,$00,$06
	dc.b	$13,$42,$00,$05,$43,$F9,$00,$A0,$00,$00,$42,$82,$14,$39,$00,$A0
	dc.b	$00,$05,$E1,$4A,$14,$39,$00,$A0,$00,$06,$04,$41,$00,$01,$13,$98
	dc.b	$20,$00,$06,$42,$00,$01,$51,$C9,$FF,$F6,$13,$C2,$00,$A0,$00,$06
	dc.b	$E0,$4A,$13,$C2,$00,$A0,$00,$05,$61,$00,$08,$44,$43,$F9,$FF,$FF
	dc.b	$FD,$FC,$32,$9F,$42,$40,$4C,$DF,$03,$06,$4E,$75

SndReadBlock						;Command $B: copy Z80 block d1 to a0. Carry set and d0 = 3 when there is
									;no such block.
									;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$70,$C0,$43,$F9,$FF,$FF,$FD,$FC,$3F,$11,$32,$BC,$00,$00
	dc.b	$61,$00,$08,$0C,$43,$F9,$00,$A0,$01,$00,$34,$3C,$00,$29,$0C,$11
	dc.b	$00,$00,$66,$06,$B2,$29,$00,$01,$67,$22,$D3,$FC,$00,$00,$00,$06
	dc.b	$51,$CA,$FF,$EC,$61,$00,$07,$FC,$43,$F9,$FF,$FF,$FD,$FC,$32,$9F
	dc.b	$30,$3C,$00,$03,$00,$3C,$00,$01,$60,$00,$00,$3A,$14,$29,$00,$03
	dc.b	$E1,$4A,$14,$29,$00,$02,$04,$42,$00,$01,$16,$29,$00,$04,$E1,$4B
	dc.b	$16,$29,$00,$05,$43,$F9,$00,$A0,$00,$00,$10,$F1,$30,$00,$06,$43
	dc.b	$00,$01,$51,$CA,$FF,$F6,$61,$00,$07,$BA,$43,$F9,$FF,$FF,$FD,$FC
	dc.b	$32,$9F,$42,$40,$4C,$DF,$03,$0E,$4E,$75

SndWriteBlock						;Command $C: copy a0 over Z80 block d1. Carry set and d0 = 3 when there is
									;no such block.
									;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$70,$C0,$43,$F9,$FF,$FF,$FD,$FC,$3F,$11,$32,$BC,$00,$00
	dc.b	$61,$00,$07,$82,$43,$F9,$00,$A0,$01,$00,$34,$3C,$00,$29,$0C,$11
	dc.b	$00,$00,$66,$06,$B2,$29,$00,$01,$67,$22,$D3,$FC,$00,$00,$00,$06
	dc.b	$51,$CA,$FF,$EC,$61,$00,$07,$72,$43,$F9,$FF,$FF,$FD,$FC,$32,$9F
	dc.b	$30,$3C,$00,$03,$00,$3C,$00,$01,$60,$00,$00,$3A,$14,$29,$00,$03
	dc.b	$E1,$4A,$14,$29,$00,$02,$04,$42,$00,$01,$16,$29,$00,$04,$E1,$4B
	dc.b	$16,$29,$00,$05,$43,$F9,$00,$A0,$00,$00,$13,$98,$30,$00,$06,$43
	dc.b	$00,$01,$51,$CA,$FF,$F6,$61,$00,$07,$30,$43,$F9,$FF,$FF,$FD,$FC
	dc.b	$32,$9F,$42,$40,$4C,$DF,$03,$0E,$4E,$75

SndPauseZ80							;Command $D: Z80_RAM+$50 = $FF (pause).
									;Code the listing does not decode: kept as bytes
	dc.b	$2F,$08,$41,$F9,$FF,$FF,$FD,$FC,$3F,$10,$30,$BC,$00,$00,$08,$39
	dc.b	$00,$08,$00,$A1,$11,$00,$66,$0E,$13,$FC,$00,$FF,$00,$A0,$00,$50
	dc.b	$30,$9F,$20,$5F,$4E,$75,$61,$00,$06,$E2,$13,$FC,$00,$FF,$00,$A0
	dc.b	$00,$50,$61,$00,$06,$EA,$30,$9F,$20,$5F,$4E,$75

SndResumeZ80						;Command $E: Z80_RAM+$50 = 0 (resume).
									;Code the listing does not decode: kept as bytes
	dc.b	$2F,$08,$41,$F9,$FF,$FF,$FD,$FC,$3F,$10,$30,$BC,$00,$00,$08,$39
	dc.b	$00,$08,$00,$A1,$11,$00,$66,$0E,$13,$FC,$00,$00,$00,$A0,$00,$50
	dc.b	$30,$9F,$20,$5F,$4E,$75,$61,$00,$06,$A6,$13,$FC,$00,$00,$00,$A0
	dc.b	$00,$50,$61,$00,$06,$AE,$30,$9F,$20,$5F,$4E,$75

SndStopAll							;Command $F (SoundOff): free every song slot, send Z80 command $FF and
									;clear the notes.
									;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$80,$C0,$41,$F9,$FF,$FF,$FD,$FC,$3F,$10,$30,$BC,$00,$00
	dc.b	$43,$F9,$FF,$FF,$FD,$FE,$30,$3C,$00,$07,$22,$FC,$FF,$FF,$FF,$FF
	dc.b	$51,$C8,$FF,$F8,$30,$3C,$00,$FF,$61,$00,$FC,$AC,$61,$00,$00,$A2
	dc.b	$30,$9F,$4C,$DF,$03,$01,$4E,$75

SndSongControl						;Command $10: Z80 command $10B0 with d2 for each slot that plays song d1.
									;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$70,$C0,$41,$F9,$FF,$FF,$FE,$3E,$43,$F9,$FF,$FF,$FD,$FE
	dc.b	$42,$43,$0C,$91,$FF,$FF,$FF,$FF,$67,$16,$B2,$50,$66,$12,$30,$03
	dc.b	$E1,$48,$E9,$48,$10,$02,$48,$40,$30,$3C,$10,$B0,$61,$00,$FC,$70
	dc.b	$D1,$FC,$00,$00,$00,$02,$D3,$FC,$00,$00,$00,$04,$06,$43,$00,$01
	dc.b	$0C,$43,$00,$07,$66,$CC,$42,$40,$4C,$DF,$03,$0E,$4E,$75

SndFindSong							;Command $11: carry clear and d0 = d2 when a slot plays song d1, else
									;carry set and d0 = 3.
									;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$60,$C0,$41,$F9,$FF,$FF,$FE,$3E,$43,$F9,$FF,$FF,$FD,$FE
	dc.b	$42,$42,$0C,$91,$FF,$FF,$FF,$FF,$66,$0C,$B2,$50,$66,$08,$30,$02
	dc.b	$02,$3C,$00,$FE,$60,$1E,$D1,$FC,$00,$00,$00,$02,$D3,$FC,$00,$00
	dc.b	$00,$04,$06,$42,$00,$01,$0C,$42,$00,$07,$66,$D6,$30,$3C,$00,$03
	dc.b	$00,$3C,$00,$01,$4C,$DF,$03,$06,$4E,$75

SndClearNotes						;No notes: SndNoteCount 0, SndNotes all -1.
									;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$C0,$C0,$41,$F9,$FF,$FF,$FD,$FC,$3F,$28,$00,$00,$31,$7C
	dc.b	$00,$00,$00,$00,$31,$7C,$00,$00,$01,$42,$43,$F9,$FF,$FF,$FE,$BE
	dc.b	$32,$3C,$00,$1F,$20,$3C,$FF,$FF,$FF,$FF,$22,$C0,$51,$C9,$FF,$FC
	dc.b	$31,$5F,$00,$00,$4C,$DF,$03,$03,$4E,$75

SndReleaseNotes						;Set the timer of every note of slot d0 to 1 (released next frame).
									;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$E0,$C0,$41,$F9,$FF,$FF,$FD,$FC,$3F,$28,$00,$00,$31,$7C
	dc.b	$00,$00,$00,$00,$43,$F9,$FF,$FF,$FE,$BE,$32,$28,$01,$42,$42,$42
	dc.b	$0C,$41,$00,$00,$67,$1A,$14,$29,$00,$03,$E8,$0A,$B4,$40,$66,$04
	dc.b	$32,$BC,$00,$01,$D3,$FC,$00,$00,$00,$04,$04,$41,$00,$01,$60,$E0
	dc.b	$31,$5F,$00,$00,$4C,$DF,$03,$07,$4E,$75

SndAddNote							;Add note d0 (timer word, then the note) to SndNotes.
									;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$C0,$80,$41,$F9,$FF,$FF,$FD,$FC,$32,$28,$01,$42,$E5,$49
	dc.b	$41,$F9,$FF,$FF,$FE,$BE,$21,$80,$10,$00,$41,$F9,$FF,$FF,$FD,$FC
	dc.b	$06,$68,$00,$01,$01,$42,$42,$40,$4C,$DF,$01,$03,$4E,$75

SndUpdateNotes						;Count down the note timers; at 0 send the note off ($8x) and remove the
									;note.
									;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$C0,$E0,$45,$F9,$FF,$FF,$FD,$FC,$0C,$6A,$00,$00,$01,$42
	dc.b	$67,$64,$41,$F9,$FF,$FF,$FE,$BE,$0C,$50,$FF,$FF,$67,$58,$04,$50
	dc.b	$00,$01,$66,$4C,$10,$28,$00,$03,$02,$00,$00,$F0,$E1,$48,$48,$40
	dc.b	$30,$28,$00,$02,$02,$00,$00,$0F,$00,$00,$00,$80,$61,$00,$FB,$16
	dc.b	$4A,$40,$67,$06,$06,$50,$00,$01,$60,$26,$43,$F9,$FF,$FF,$FE,$BE
	dc.b	$30,$39,$FF,$FF,$FF,$3E,$04,$40,$00,$01,$E5,$48,$20,$B1,$00,$00
	dc.b	$23,$BC,$FF,$FF,$FF,$FF,$00,$00,$04,$6A,$00,$01,$01,$42,$60,$A8
	dc.b	$D0,$FC,$00,$04,$60,$A2,$4C,$DF,$07,$03,$4E,$75

SndStreamZ80						;Answer the Z80's sample request (Z80_RAM+$4D: 1 start sample Z80_RAM+$4E,
									;2 / 3 next 256 bytes) by copying
									;from the sample (bank item type 1) to the Z80 buffer, looping or ending
									;it.
									;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$60,$80,$61,$00,$04,$8E,$4A,$39,$00,$A0,$00,$4D,$67,$00
	dc.b	$01,$3E,$0C,$39,$00,$01,$00,$A0,$00,$4D,$66,$70,$42,$41,$12,$39
	dc.b	$00,$A0,$00,$4E,$30,$3C,$00,$01,$61,$00,$01,$36,$65,$00,$01,$20
	dc.b	$B1,$FC,$FF,$FF,$FF,$FF,$67,$00,$01,$16,$43,$F9,$FF,$FF,$FD,$FC
	dc.b	$23,$48,$01,$46,$10,$10,$B0,$10,$66,$FA,$E1,$48,$D1,$FC,$00,$00
	dc.b	$00,$01,$10,$10,$B0,$10,$66,$FA,$33,$40,$01,$4E,$D1,$FC,$00,$00
	dc.b	$00,$01,$20,$69,$01,$46,$D1,$FC,$00,$00,$00,$02,$23,$48,$01,$4A
	dc.b	$42,$80,$10,$39,$00,$A0,$00,$07,$E1,$48,$10,$39,$00,$A0,$00,$08
	dc.b	$06,$80,$00,$A0,$00,$00,$22,$40,$60,$00,$00,$6A,$0C,$39,$00,$02
	dc.b	$00,$A0,$00,$4D,$66,$2A,$20,$79,$FF,$FF,$FF,$46,$B1,$FC,$00,$00
	dc.b	$00,$00,$67,$00,$00,$AA,$42,$80,$10,$39,$00,$A0,$00,$07,$E1,$48
	dc.b	$10,$39,$00,$A0,$00,$08,$06,$80,$00,$A0,$00,$00,$22,$40,$60,$34
	dc.b	$0C,$39,$00,$03,$00,$A0,$00,$4D,$66,$00,$00,$84,$20,$79,$FF,$FF
	dc.b	$FF,$46,$B1,$FC,$00,$00,$00,$00,$67,$00,$00,$74,$42,$80,$10,$39
	dc.b	$00,$A0,$00,$09,$E1,$48,$10,$39,$00,$A0,$00,$0A,$06,$80,$00,$A0
	dc.b	$00,$00,$22,$40,$32,$3C,$00,$FF,$12,$D8,$57,$C9,$FF,$FC,$67,$10
	dc.b	$43,$F9,$FF,$FF,$FD,$FC,$06,$A9,$00,$00,$01,$00,$01,$4A,$60,$3E
	dc.b	$93,$FC,$00,$00,$00,$01,$42,$80,$30,$39,$FF,$FF,$FF,$4A,$0C,$40
	dc.b	$FF,$FF,$67,$1C,$12,$BC,$00,$FF,$43,$F9,$FF,$FF,$FD,$FC,$20,$69
	dc.b	$01,$46,$D1,$FC,$00,$00,$00,$02,$D1,$C0,$23,$48,$01,$4A,$60,$0E
	dc.b	$43,$F9,$FF,$FF,$FD,$FC,$23,$7C,$00,$00,$00,$00,$01,$4A,$13,$FC
	dc.b	$00,$00,$00,$A0,$00,$4D,$61,$00,$03,$50,$4C,$DF,$01,$06,$4E,$75

SndFindBankItem						;Find bank item type d0, id d1 in the 4 banks (SndBanks): a0 = its data,
									;d0 = its size. Carry set and d0 = 3
									;when there is none.
									;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$78,$60,$43,$F9,$FF,$FF,$FF,$DC,$34,$3C,$00,$03,$0C,$91
	dc.b	$FF,$FF,$FF,$FF,$67,$00,$00,$50,$20,$51,$24,$48,$42,$83,$16,$18
	dc.b	$E1,$4B,$16,$18,$28,$03,$E5,$4C,$D5,$C4,$D5,$FC,$00,$00,$00,$02
	dc.b	$B0,$10,$66,$18,$B2,$28,$00,$01,$66,$12,$10,$28,$00,$02,$E1,$48
	dc.b	$10,$28,$00,$03,$20,$4A,$02,$3C,$00,$FE,$60,$2C,$42,$84,$18,$28
	dc.b	$00,$02,$E1,$4C,$18,$28,$00,$03,$D5,$C4,$D1,$FC,$00,$00,$00,$04
	dc.b	$04,$43,$00,$01,$66,$CA,$D3,$FC,$00,$00,$00,$04,$51,$CA,$FF,$A0
	dc.b	$30,$3C,$00,$03,$00,$3C,$00,$01,$4C,$DF,$06,$1E,$4E,$75

SndSetBank							;Command 6: bank d1 (0-3) is at a0; tell the Z80 too (Z80_RAM+$51). Carry
									;set and d0 = 3 for d1 above 3.
									;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$40,$60,$0C,$41,$00,$04,$65,$0A,$30,$3C,$00,$03,$00,$3C
	dc.b	$00,$01,$60,$42,$E5,$49,$43,$F9,$FF,$FF,$FF,$DC,$23,$88,$10,$00
	dc.b	$43,$F9,$FF,$FF,$FD,$FC,$3F,$11,$32,$BC,$00,$00,$61,$00,$02,$88
	dc.b	$45,$F9,$00,$A0,$00,$51,$20,$08,$15,$80,$10,$00,$E0,$88,$15,$80
	dc.b	$10,$01,$E0,$88,$15,$80,$10,$02,$E0,$88,$15,$80,$10,$03,$61,$00
	dc.b	$02,$7A,$32,$9F,$42,$40,$4C,$DF,$06,$02,$4E,$75

SndLoadList							;Command 7: upload the patches (types 0 and 4) of load list d1 (bank item
									;type $B, pairs ended by $FF) to the
									;Z80.
									;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$40,$C0,$30,$3C,$00,$0B,$61,$00,$FF,$1C,$65,$00,$00,$40
	dc.b	$22,$48,$0C,$11,$00,$FF,$66,$04,$42,$40,$60,$32,$42,$40,$10,$11
	dc.b	$42,$41,$12,$29,$00,$01,$61,$00,$FE,$FE,$65,$22,$0C,$11,$00,$00
	dc.b	$67,$06,$0C,$11,$00,$04,$66,$0E,$32,$00,$42,$40,$10,$29,$00,$01
	dc.b	$61,$00,$F8,$DE,$65,$08,$D3,$FC,$00,$00,$00,$02,$60,$C4,$4C,$DF
	dc.b	$03,$02,$4E,$75

SndFreeBlocks						;Command 8: free the Z80 blocks of list a0 (word pairs ended by -1) and
									;move the blocks after them down.
									;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$70,$E0,$43,$F9,$FF,$FF,$FD,$FC,$3F,$11,$32,$BC,$00,$00
	dc.b	$61,$00,$01,$F4,$0C,$50,$FF,$FF,$67,$00,$00,$E8,$43,$F9,$00,$A0
	dc.b	$01,$00,$30,$10,$32,$28,$00,$02,$34,$3C,$00,$29,$B0,$11,$66,$06
	dc.b	$B2,$29,$00,$01,$67,$0E,$D3,$FC,$00,$00,$00,$06,$51,$CA,$FF,$EE
	dc.b	$60,$00,$00,$B6,$10,$29,$00,$02,$E1,$48,$10,$29,$00,$03,$42,$41
	dc.b	$12,$29,$00,$04,$E1,$49,$12,$29,$00,$05,$34,$01,$D4,$40,$45,$F9
	dc.b	$00,$A0,$00,$00,$0C,$42,$1F,$00,$67,$10,$15,$B2,$20,$00,$10,$00
	dc.b	$06,$42,$00,$01,$06,$41,$00,$01,$60,$EA,$42,$41,$12,$29,$00,$04
	dc.b	$E1,$49,$12,$29,$00,$05,$12,$BC,$00,$FF,$13,$7C,$00,$FF,$00,$01
	dc.b	$13,$7C,$00,$FF,$00,$02,$13,$7C,$00,$FF,$00,$03,$13,$7C,$00,$FF
	dc.b	$00,$04,$13,$7C,$00,$FF,$00,$05,$43,$F9,$00,$A0,$01,$00,$34,$3C
	dc.b	$00,$29,$0C,$11,$00,$FF,$67,$1C,$42,$43,$16,$29,$00,$04,$E1,$4B
	dc.b	$16,$29,$00,$05,$B6,$41,$65,$0C,$96,$40,$13,$43,$00,$05,$E0,$4B
	dc.b	$13,$43,$00,$04,$D3,$FC,$00,$00,$00,$06,$51,$CA,$FF,$D6,$43,$F9
	dc.b	$00,$A0,$00,$05,$42,$41,$12,$11,$E1,$49,$12,$29,$00,$01,$92,$40
	dc.b	$13,$41,$00,$01,$E0,$49,$12,$81,$D1,$FC,$00,$00,$00,$04,$60,$00
	dc.b	$FF,$14,$61,$00,$01,$16,$43,$F9,$FF,$FF,$FD,$FC,$32,$9F,$42,$40
	dc.b	$4C,$DF,$07,$0E,$4E,$75

SndResetBlocks						;Command 9: free all Z80 blocks (Z80_RAM+$100 all $FF, free pointer back
									;to the start at Z80_RAM+3).
									;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$00,$C0,$41,$F9,$FF,$FF,$FD,$FC,$3F,$10,$30,$BC,$00,$00
	dc.b	$61,$00,$00,$DE,$41,$F9,$00,$A0,$01,$00,$30,$3C,$00,$FB,$10,$FC
	dc.b	$00,$FF,$51,$C8,$FF,$FA,$41,$F9,$00,$A0,$00,$03,$43,$F9,$00,$A0
	dc.b	$00,$05,$12,$D8,$12,$90,$61,$00,$00,$CC,$41,$F9,$FF,$FF,$FD,$FC
	dc.b	$30,$9F,$42,$40,$4C,$DF,$03,$00,$4E,$75

SndSendZ80							;Command $12: queue Z80 command d1 with interrupts off.
									;Code the listing does not decode: kept as bytes
	dc.b	$40,$E7,$46,$FC,$27,$00,$20,$01,$61,$00,$F6,$E0,$46,$DF,$4E,$75

SndQueueZ80Cmd						;Command $A: put Z80 command d1 in a free entry of the command queue (sent
									;by SndFlushZ80Queue).
									;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$60,$80,$41,$F9,$FF,$FF,$FF,$4E,$30,$39,$FF,$FF,$FF,$CE
	dc.b	$34,$3C,$00,$1F,$08,$F0,$00,$07,$00,$03,$66,$10,$21,$81,$00,$00
	dc.b	$41,$F9,$FF,$FF,$FF,$CE,$30,$80,$42,$40,$60,$18,$06,$40,$00,$04
	dc.b	$0C,$40,$00,$80,$65,$02,$42,$40,$51,$CA,$FF,$DA,$30,$3C,$00,$07
	dc.b	$00,$3C,$00,$01,$4C,$DF,$01,$06,$4E,$75

SndFlushZ80Queue					;Send the queued Z80 commands (SndPutZ80Cmd) and clear their entries.
									;Called from SndUpdate.
									;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$C0,$80,$41,$F9,$FF,$FF,$FF,$4E,$32,$39,$FF,$FF,$FF,$D0
	dc.b	$0C,$B0,$00,$00,$00,$00,$10,$00,$67,$24,$0C,$B0,$00,$00,$00,$80
	dc.b	$10,$00,$67,$1A,$20,$30,$10,$00,$61,$00,$F6,$66,$42,$B0,$10,$00
	dc.b	$06,$41,$00,$04,$0C,$41,$00,$80,$65,$D6,$42,$41,$60,$D2,$41,$F9
	dc.b	$FF,$FF,$FF,$D0,$30,$81,$4C,$DF,$01,$03,$4E,$75

Z80BusRequest						;Stop the Z80 and wait for the bus.
									;Code the listing does not decode: kept as bytes
	dc.b	$33,$FC,$01,$00,$00,$A1,$11,$00,$08,$39,$00,$00,$00,$A1,$11,$00
	dc.b	$66,$F6,$4E,$75

Z80BusRelease						;Give the bus back to the Z80.
									;Code the listing does not decode: kept as bytes
	dc.b	$33,$FC,$00,$00,$00,$A1,$11,$00,$4E,$75

Z80Program							;The Z80 sound program. Starts JP $0533
	incbin	..\Extracted\NHL96\Sound\z80_snd_drv96.bin

SoundBanks							;Bank 0 (SndSetBank, Begin and Opening2): the item count, then 4 bytes per
									;item (type, id, size), then the
									;items in that order. Type 0 = patch (uploaded to the Z80 by a load list),
									;1 = sample (streamed), 3 = song, $B = load list (SndLoadList).
									;SndFindBankItem finds an item by type and id
	dc.w	168						;items
	SndItem	SB_SAMPLE,$00,$2143		;sample 0
	SndItem	SB_SAMPLE,$01,$227		;sample 1
	SndItem	SB_SAMPLE,$02,$20CB		;sample 2
	SndItem	SB_SAMPLE,$03,$863		;sample 3
	SndItem	SB_SAMPLE,$04,$1E13		;sample 4
	SndItem	SB_SAMPLE,$05,$F09		;sample 5
	SndItem	SB_SAMPLE,$06,$F23		;sample 6
	SndItem	SB_SAMPLE,$07,$EC3		;sample 7
	SndItem	SB_SAMPLE,$08,$10D3		;sample 8
	SndItem	SB_SAMPLE,$09,$32F		;sample 9
	SndItem	SB_SAMPLE,$0A,$353		;sample 10
	SndItem	SB_SAMPLE,$0B,$15C2		;sample 11
	SndItem	SB_SAMPLE,$0C,$1045		;sample 12
	SndItem	SB_SAMPLE,$0E,$9BC3		;sample 14
	SndItem	SB_SAMPLE,$10,$EC29		;sample 16
	SndItem	SB_SAMPLE,$11,$2528		;sample 17
	SndItem	SB_SAMPLE,$13,$57CE		;sample 19
	SndItem	SB_SAMPLE,$15,$1EC9		;sample 21
	SndItem	SB_SAMPLE,$16,$D083		;sample 22
	SndItem	SB_SAMPLE,$17,$47D0		;sample 23
	SndItem	SB_SAMPLE,$18,$1833		;sample 24
	SndItem	SB_SAMPLE,$19,$1E7B		;sample 25
	SndItem	SB_SAMPLE,$1B,$1833		;sample 27
	SndItem	SB_SAMPLE,$1D,$232		;sample 29
	SndItem	SB_SAMPLE,$2E,$5DCB		;sample 46
	SndItem	SB_SAMPLE,$5A,$B70		;sample 90
	SndItem	SB_SAMPLE,$5B,$C20		;sample 91
	SndItem	SB_SAMPLE,$5C,$9AE
	SndItem	SB_SAMPLE,$5D,$30F4
	SndItem	SB_SAMPLE,$5E,$C38
	SndItem	SB_PATCH,$00,$5			;patch 0
	SndItem	SB_PATCH,$01,$5			;patch 1
	SndItem	SB_PATCH,$02,$5			;patch 2
	SndItem	SB_PATCH,$03,$5			;patch 3
	SndItem	SB_PATCH,$04,$5			;patch 4
	SndItem	SB_PATCH,$05,$5			;patch 5
	SndItem	SB_PATCH,$06,$5			;patch 6
	SndItem	SB_PATCH,$07,$5			;patch 7
	SndItem	SB_PATCH,$08,$5			;patch 8
	SndItem	SB_PATCH,$09,$5			;patch 9
	SndItem	SB_PATCH,$0A,$5			;patch 10
	SndItem	SB_PATCH,$0B,$27		;patch 11
	SndItem	SB_PATCH,$0C,$5			;patch 12
	SndItem	SB_PATCH,$0D,$27		;patch 13
	SndItem	SB_PATCH,$0E,$27		;patch 14
	SndItem	SB_PATCH,$0F,$27		;patch 15
	SndItem	SB_PATCH,$11,$27		;patch 17
	SndItem	SB_PATCH,$12,$10		;patch 18
	SndItem	SB_PATCH,$13,$10		;patch 19
	SndItem	SB_PATCH,$14,$10		;patch 20
	SndItem	SB_PATCH,$15,$27		;patch 21
	SndItem	SB_PATCH,$16,$27		;patch 22
	SndItem	SB_PATCH,$17,$27		;patch 23
	SndItem	SB_PATCH,$19,$27		;patch 25
	SndItem	SB_PATCH,$1A,$27		;patch 26
	SndItem	SB_PATCH,$1E,$27		;patch 30
	SndItem	SB_PATCH,$1F,$27		;patch 31
	SndItem	SB_PATCH,$20,$27		;patch 32
	SndItem	SB_PATCH,$21,$27		;patch 33
	SndItem	SB_PATCH,$26,$27		;patch 38
	SndItem	SB_PATCH,$27,$27		;patch 39
	SndItem	SB_PATCH,$28,$27		;patch 40
	SndItem	SB_PATCH,$2A,$27		;patch 42
	SndItem	SB_PATCH,$2E,$5			;patch 46
	SndItem	SB_PATCH,$33,$5			;patch 51
	SndItem	SB_PATCH,$36,$5			;patch 54
	SndItem	SB_PATCH,$38,$5			;patch 56
	SndItem	SB_PATCH,$39,$5			;patch 57
	SndItem	SB_PATCH,$3B,$5			;patch 59
	SndItem	SB_PATCH,$3C,$27		;patch 60
	SndItem	SB_PATCH,$3D,$5			;patch 61
	SndItem	SB_PATCH,$3E,$27		;patch 62
	SndItem	SB_PATCH,$3F,$27		;patch 63
	SndItem	SB_PATCH,$40,$27		;patch 64
	SndItem	SB_PATCH,$41,$5			;patch 65
	SndItem	SB_PATCH,$42,$5			;patch 66
	SndItem	SB_PATCH,$43,$5			;patch 67
	SndItem	SB_PATCH,$44,$5			;patch 68
	SndItem	SB_PATCH,$45,$27		;patch 69
	SndItem	SB_PATCH,$46,$5			;patch 70
	SndItem	SB_PATCH,$47,$27		;patch 71
	SndItem	SB_PATCH,$48,$5			;patch 72
	SndItem	SB_PATCH,$49,$27		;patch 73
	SndItem	SB_PATCH,$5A,$5			;patch 90
	SndItem	SB_PATCH,$5B,$5			;patch 91
	SndItem	SB_PATCH,$5C,$5
	SndItem	SB_PATCH,$5D,$5
	SndItem	SB_PATCH,$5E,$5
	SndItem	SB_SONG,$00,$2FF2		;song 0
	SndItem	SB_SONG,$01,$19E2		;song 1
	SndItem	SB_SONG,$02,$22FA		;song 2
	SndItem	SB_SONG,$03,$1737		;song 3
	SndItem	SB_SONG,$04,$14			;song 4
	SndItem	SB_SONG,$05,$C			;song 5
	SndItem	SB_SONG,$06,$C			;song 6
	SndItem	SB_SONG,$07,$C			;song 7
	SndItem	SB_SONG,$08,$C			;song 8
	SndItem	SB_SONG,$09,$C			;song 9
	SndItem	SB_SONG,$0A,$C			;song 10
	SndItem	SB_SONG,$0B,$C			;song 11
	SndItem	SB_SONG,$0E,$C			;song 14
	SndItem	SB_SONG,$10,$C			;song 16
	SndItem	SB_SONG,$11,$C			;song 17
	SndItem	SB_SONG,$13,$C			;song 19
	SndItem	SB_SONG,$15,$C			;song 21
	SndItem	SB_SONG,$16,$63			;song 22
	SndItem	SB_SONG,$17,$54			;song 23
	SndItem	SB_SONG,$18,$C			;song 24
	SndItem	SB_SONG,$19,$C			;song 25
	SndItem	SB_SONG,$1A,$C			;song 26
	SndItem	SB_SONG,$1B,$C			;song 27
	SndItem	SB_SONG,$1C,$C			;song 28
	SndItem	SB_SONG,$1D,$C			;song 29
	SndItem	SB_SONG,$1E,$E			;song 30
	SndItem	SB_SONG,$20,$C			;song 32
	SndItem	SB_SONG,$21,$C			;song 33
	SndItem	SB_SONG,$22,$C			;song 34
	SndItem	SB_SONG,$23,$C			;song 35
	SndItem	SB_SONG,$24,$C			;song 36
	SndItem	SB_SONG,$25,$C			;song 37
	SndItem	SB_SONG,$26,$2D4		;song 38
	SndItem	SB_SONG,$27,$14			;song 39
	SndItem	SB_SONG,$28,$14			;song 40
	SndItem	SB_SONG,$29,$C			;song 41
	SndItem	SB_SONG,$2E,$14			;song 46
	SndItem	SB_SONG,$32,$1F2		;song 50
	SndItem	SB_SONG,$33,$4E4		;song 51
	SndItem	SB_SONG,$34,$254		;song 52
	SndItem	SB_SONG,$35,$2AE		;song 53
	SndItem	SB_SONG,$36,$31C		;song 54
	SndItem	SB_SONG,$37,$2A8		;song 55
	SndItem	SB_SONG,$38,$29C		;song 56
	SndItem	SB_SONG,$39,$1AC		;song 57
	SndItem	SB_SONG,$3A,$3E4		;song 58
	SndItem	SB_SONG,$3B,$244		;song 59
	SndItem	SB_SONG,$3C,$30			;song 60
	SndItem	SB_SONG,$3D,$404		;song 61
	SndItem	SB_SONG,$3E,$341		;song 62
	SndItem	SB_SONG,$3F,$208		;song 63
	SndItem	SB_SONG,$40,$27E		;song 64
	SndItem	SB_SONG,$41,$358		;song 65
	SndItem	SB_SONG,$42,$12C		;song 66
	SndItem	SB_SONG,$43,$3C4		;song 67
	SndItem	SB_SONG,$44,$20C		;song 68
	SndItem	SB_SONG,$45,$274		;song 69
	SndItem	SB_SONG,$46,$158		;song 70
	SndItem	SB_SONG,$47,$3BC		;song 71
	SndItem	SB_SONG,$48,$424		;song 72
	SndItem	SB_SONG,$49,$400		;song 73
	SndItem	SB_SONG,$4A,$315		;song 74
	SndItem	SB_SONG,$4B,$365		;song 75
	SndItem	SB_SONG,$4C,$363		;song 76
	SndItem	SB_SONG,$4D,$2C9		;song 77
	SndItem	SB_SONG,$4E,$41C		;song 78
	SndItem	SB_SONG,$4F,$48C		;song 79
	SndItem	SB_SONG,$50,$255		;song 80
	SndItem	SB_SONG,$51,$22A		;song 81
	SndItem	SB_SONG,$52,$F0			;song 82
	SndItem	SB_SONG,$53,$274		;song 83
	SndItem	SB_SONG,$54,$D4			;song 84
	SndItem	SB_SONG,$55,$429		;song 85
	SndItem	SB_SONG,$5A,$C			;song 90
	SndItem	SB_SONG,$5B,$C			;song 91
	SndItem	SB_SONG,$5C,$C
	SndItem	SB_SONG,$5D,$C
	SndItem	SB_SONG,$5E,$C
	SndItem	SB_LIST,$00,$27			;list 0
	SndItem	SB_LIST,$01,$53			;list 1

	;sample 0
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_sample_00.bin
	;sample 1
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_sample_01.bin
	;sample 2
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_sample_02.bin
	;sample 3
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_sample_03.bin
	;sample 4
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_sample_04.bin
	;sample 5
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_sample_05.bin
	;sample 6
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_sample_06.bin
	;sample 7
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_sample_07.bin
	;sample 8
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_sample_08.bin
	;sample 9
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_sample_09.bin
	;sample 10
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_sample_0A.bin
	;sample 11
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_sample_0B.bin
	;sample 12
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_sample_0C.bin
	;sample 14
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_sample_0E.bin
	;sample 16
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_sample_10.bin
	;sample 17
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_sample_11.bin
	;sample 19
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_sample_13.bin
	;sample 21
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_sample_15.bin
	;sample 22
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_sample_16.bin
	;sample 23
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_sample_17.bin
	;sample 24
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_sample_18.bin
	;sample 25
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_sample_19.bin
	;sample 27
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_sample_1B.bin
	;sample 29
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_sample_1D.bin
	;sample 46
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_sample_2E.bin
	;sample 90
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_sample_5A.bin
	;sample 91
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_sample_5B.bin
	;sample 92
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_sample_5C.bin
	;sample 93
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_sample_5D.bin
	;sample 94
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_sample_5E.bin
	;patch 0
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_00.bin
	;patch 1
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_01.bin
	;patch 2
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_02.bin
	;patch 3
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_03.bin
	;patch 4
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_04.bin
	;patch 5
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_05.bin
	;patch 6
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_06.bin
	;patch 7
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_07.bin
	;patch 8
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_08.bin
	;patch 9
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_09.bin
	;patch 10
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_0A.bin
	;patch 11
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_0B.bin
	;patch 12
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_0C.bin
	;patch 13
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_0D.bin
	;patch 14
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_0E.bin
	;patch 15
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_0F.bin
	;patch 17
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_11.bin
	;patch 18
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_12.bin
	;patch 19
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_13.bin
	;patch 20
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_14.bin
	;patch 21
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_15.bin
	;patch 22
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_16.bin
	;patch 23
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_17.bin
	;patch 25
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_19.bin
	;patch 26
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_1A.bin
	;patch 30
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_1E.bin
	;patch 31
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_1F.bin
	;patch 32
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_20.bin
	;patch 33
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_21.bin
	;patch 38
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_26.bin
	;patch 39
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_27.bin
	;patch 40
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_28.bin
	;patch 42
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_2A.bin
	;patch 46
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_2E.bin
	;patch 51
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_33.bin
	;patch 54
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_36.bin
	;patch 56
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_38.bin
	;patch 57
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_39.bin
	;patch 59
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_3B.bin
	;patch 60
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_3C.bin
	;patch 61
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_3D.bin
	;patch 62
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_3E.bin
	;patch 63
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_3F.bin
	;patch 64
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_40.bin
	;patch 65
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_41.bin
	;patch 66
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_42.bin
	;patch 67
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_43.bin
	;patch 68
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_44.bin
	;patch 69
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_45.bin
	;patch 70
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_46.bin
	;patch 71
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_47.bin
	;patch 72
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_48.bin
	;patch 73
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_49.bin
	;patch 90
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_5A.bin
	;patch 91
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_5B.bin
	;patch 92
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_5C.bin
	;patch 93
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_5D.bin
	;patch 94
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_patch_5E.bin
	;song 0
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_00.bin
	;song 1
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_01.bin
	;song 2
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_02.bin
	;song 3
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_03.bin
	;song 4
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_04.bin
	;song 5
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_05.bin
	;song 6
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_06.bin
	;song 7
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_07.bin
	;song 8
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_08.bin
	;song 9
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_09.bin
	;song 10
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_0A.bin
	;song 11
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_0B.bin
	;song 14
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_0E.bin
	;song 16
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_10.bin
	;song 17
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_11.bin
	;song 19
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_13.bin
	;song 21
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_15.bin
	;song 22
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_16.bin
	;song 23
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_17.bin
	;song 24
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_18.bin
	;song 25
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_19.bin
	;song 26
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_1A.bin
	;song 27
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_1B.bin
	;song 28
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_1C.bin
	;song 29
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_1D.bin
	;song 30
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_1E.bin
	;song 32
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_20.bin
	;song 33
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_21.bin
	;song 34
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_22.bin
	;song 35
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_23.bin
	;song 36
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_24.bin
	;song 37
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_25.bin
	;song 38
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_26.bin
	;song 39
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_27.bin
	;song 40
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_28.bin
	;song 41
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_29.bin
	;song 46
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_2E.bin
	;song 50
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_32.bin
	;song 51
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_33.bin
	;song 52
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_34.bin
	;song 53
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_35.bin
	;song 54
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_36.bin
	;song 55
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_37.bin
	;song 56
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_38.bin
	;song 57
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_39.bin
	;song 58
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_3A.bin
	;song 59
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_3B.bin
	;song 60
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_3C.bin
	;song 61
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_3D.bin
	;song 62
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_3E.bin
	;song 63
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_3F.bin
	;song 64
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_40.bin
	;song 65
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_41.bin
	;song 66
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_42.bin
	;song 67
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_43.bin
	;song 68
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_44.bin
	;song 69
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_45.bin
	;song 70
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_46.bin
	;song 71
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_47.bin
	;song 72
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_48.bin
	;song 73
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_49.bin
	;song 74
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_4A.bin
	;song 75
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_4B.bin
	;song 76
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_4C.bin
	;song 77
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_4D.bin
	;song 78
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_4E.bin
	;song 79
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_4F.bin
	;song 80
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_50.bin
	;song 81
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_51.bin
	;song 82
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_52.bin
	;song 83
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_53.bin
	;song 84
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_54.bin
	;song 85
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_55.bin
	;song 90
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_5A.bin
	;song 91
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_5B.bin
	;song 92
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_5C.bin
	;song 93
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_5D.bin
	;song 94
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_song_5E.bin
	;list 0
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_list_00.bin
	;list 1
	incbin	..\Extracted\NHL96\Sound\Bank\snd96_list_01.bin

SoundCmd							;Send command d0 to the sound driver (SndDriver)
	jsr	(SndDriver).l
	bcc.w	.exit
	nop
.exit
	rts

UpdateCwdExcite						;Called once per second. Track peak and running total of crowd excitement,
									;then decay the level by 1
	move.w	(CwdExciteLvl).w,d0
	cmp.w	(MaxCwdExciteLvl).w,d0
	bls.w	.less
	move.w	d0,(MaxCwdExciteLvl).w	;new peak
.less
	ext.l	d0
	add.l	d0,(SumCwdExciteLvl).w	;running total
	addq.w	#1,(NumCwdExciteLvl).w	;sample count
	subq.w	#1,(CwdExciteLvl).w		;decay
	bpl.w	.ex
	clr.w	(CwdExciteLvl).w
.ex
	rts

updatesound							;Move the crowd noise volume (psg noise channel, asv) toward Crowdlevel.
									;Called from DoGameFrame
	move.w	(Crowdlevel).w,d0
	asl.w	#3,d0
	addi.w	#$400,d0
	cmp.w	#$EFF,d0
	bls.w	.ip
	move.w	#$EFF,d0
.ip
	moveq	#$28,d2
	sub.w	(asv).w,d0
	cmp.w	d2,d0
	bgt.w	.iasv
	neg.w	d2
	cmp.w	d2,d0
	bge.w	.non
.iasv
	add.w	d2,(asv).w
	bpl.w	.non
	clr.w	(asv).w
.non
	move.b	#$C8,(Asound).l
	move.b	#1,(Asound).l
	move.b	(asv).w,d0
	eori.b	#$F,d0
	ori.b	#$F0,d0
	move.b	d0,(Asound).l
	rts

CheckLateGameSong					;Called once per second. 3rd period: choose and play a song once at the
									;random trigger time set by ResetClock
	cmpi.w	#2,(gsp).w
	bne.w	.x
	btst	#gmhl,(gmode).w
	bne.w	.x
	move.w	(gameclock).w,d0
	cmp.w	(periodendtime).w,d0
	bgt.w	.x
	st	(periodendtime).w			;high byte $FF: trigger goes negative, fires once
	move.w	(HomeTeam).w,(HmTeam).w
	move.w	#5,(SongIndex).w
	jsr	(ChooseSong).l
	move.w	(SongNum).w,-(sp)
	jsr	(song).l
.x
	rts

sfx									;Play sound effect number, one word passed on stack: through SfxTable to a
									;sound driver song (command 4)
	movem.l	d0-d7/a0-a6,-(sp)
	clr.l	d0
	move.w	$40(sp),d0				;$40 = 16*4
	bpl.w	sfxplay
	movem.l	(sp)+,d0-d7/a0-a6
	move.l	(sp),2(sp)
	addq.w	#2,sp
	rts

sfxplay								;Play sound d0 ($32-$55 are songs, PlayingSong; below, SfxTable). Sound $B
									;/ $C: a nop. song branches here
	cmp.w	#$B,d0
	beq.w	.nop
	cmp.w	#$C,d0
	bne.w	.chksong
.nop
	nop
.chksong
	cmp.w	#$55,d0
	bgt.w	.done
	cmp.w	#$32,d0
	blt.w	.sfx
	move.w	d0,(PlayingSong).w
	bra.w	.play
.sfx
	movea.l	#SfxTable,a1
	tst.b	(a1,d0.w)
	bmi.w	.done
	cmpi.b	#$26,(a1,d0.w)
	bne.w	.chklast
	movem.l	d0-d4/a0-a1,-(sp)
	movea.l	#SndSeqPtr,a0
	movea.w	#(SndSeqId-M68K_RAM),a1
	move.w	#7,d4
	clr.w	d3
.slot
	cmpi.l	#$FFFFFFFF,(a0)
	beq.w	.nextslot
	cmpi.w	#$31,(a1,d3.w)
	ble.w	.nextslot
	move.w	(a1,d3.w),d1
	move.w	#5,d0
	move.w	#$FFFF,d2
	jsr	(SndDriver).l
	bra.w	.stopped
.nextslot
	addq.w	#4,a0
	addq.w	#2,d3
	dbf	d4,.slot
.stopped
	movem.l	(sp)+,d0-d4/a0-a1
.chklast
	cmp.w	#$B,d0
	beq.w	.lookup
	cmp.w	#$C,d0
	beq.w	.lookup
	move.w	d0,(lastsfx).w
.lookup
	move.b	(a1,d0.w),d0
.play
	ext.w	d0
	move.w	d0,d1
	move.w	#4,d0
	move.w	#$FFFF,d2
	move.w	#$7F,d3
	move.w	#$100,d4
	jsr	(SoundCmd).l
.done
	movem.l	(sp)+,d0-d7/a0-a6
	move.l	(sp),2(sp)
	addq.w	#2,sp
	rts

SfxTable							;Sound driver song for sound effects 0-$31 (sfx), $FF = none. $26 first
									;stops the songs above $31
	dc.b	$26,$1C,$1D,$17,$16,$FF,$09,$25	;sounds $00-$07
	dc.b	$04,$5A,$5B,$10,$1E,$13,$20,$0E	;sounds $08-$0F
	dc.b	$0B,$0B,$0B,$0B,$08,$08,$08,$08	;sounds $10-$17
	dc.b	$08,$08,$08,$08,$21,$23,$23,$22	;sounds $18-$1F
	dc.b	$18,$15,$15,$15,$25,$04,$04,$04	;sounds $20-$27
	dc.b	$18,$18,$18,$18,$11,$1A,$1A,$5C	;sounds $28-$2F
	dc.b	$5D,$2E					;sounds $30-$31

song								;Play song number, one word passed on stack: songs 0-3 through StartSong,
									;the rest through sfxplay
	movem.l	d0-d7/a0-a6,-(sp)
	clr.l	d0
	move.w	$40(sp),d0				;$40 = 16*4
	bmi.w	.none
	cmp.w	#$32,d0
	blt.w	.0
	cmp.w	#$55,d0
	bgt.w	.0
	jsr	(stop_current_song).l
	move.w	d0,(PlayingSong).w
.0
	cmp.w	#3,d0
	ble.w	.1
	bra.w	sfxplay
.1
	jsr	(StartSong).l
.none
	movem.l	(sp)+,d0-d7/a0-a6
	move.l	(sp),2(sp)
	addq.w	#2,sp
	rts

StartSong							;Stop the song, then song d0 (command 4, tempo $100)
	tst.w	d0
	bmi.w	.0
	movem.l	d0-d7/a0-a6,-(sp)
	bsr.w	stop_current_song
	move.w	d0,(PlayingSong).w
	move.w	d0,d1
	move.w	#4,d0
	move.w	#$FFFF,d2
	move.w	#$7F,d3
	move.w	#$100,d4
	jsr	(SoundCmd).l
	movem.l	(sp)+,d0-d7/a0-a6
.0
	rts

stop_current_song					;Stop the song in progress (PlayingSong, sound driver command 5)
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#5,d0
	move.w	(PlayingSong).w,d1
	bmi.w	.0
	move.w	#$FFFF,d2
	jsr	(SoundCmd).l
	move.w	#$FFFF,(PlayingSong).w
.0
	movem.l	(sp)+,d0-d7/a0-a6
	rts

stop_current_song2					;Unreferenced. A copy of stop_current_song that skips the saving when no
									;song plays.
									;Code the listing does not decode: kept as bytes
	dc.b	$4A,$78,$D2,$A2,$6B,$00,$00,$22,$48,$E7,$FF,$FE,$30,$3C,$00,$05
	dc.b	$32,$38,$D2,$A2,$34,$3C,$FF,$FF,$4E,$B9,$00,$08,$83,$9E,$4C,$DF
	dc.b	$7F,$FF,$31,$FC,$FF,$FF,$D2,$A2,$4E,$75

KillCrowd2							;Unreferenced. A copy of KillCrowd: silence the crowd noise (psg).
									;Code the listing does not decode: kept as bytes
	dc.b	$13,$FC,$00,$E7,$00,$C0,$00,$11,$13,$FC,$00,$DF,$00,$C0,$00,$11
	dc.b	$13,$FC,$00,$C8,$00,$C0,$00,$11,$13,$FC,$00,$01,$00,$C0,$00,$11
	dc.b	$13,$FC,$00,$FF,$00,$C0,$00,$11,$4E,$75

SoundOff							;Sound driver command $F, every song off
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#$F,d0
	bsr.w	SoundCmd
	movem.l	(sp)+,d0-d7/a0-a6
	rts

ChooseSong							;SongNum = byte SongIndex of the 6 song bytes of team HmTeam, or one of
									;the 8 of RandomSongs at random when 0;
									;$FFFF with gmode bit 4
	movem.l	d0-d1/a0-a1,-(sp)
	btst	#gmhl,(gmode).w
	beq.w	.0
	move.w	#$FFFF,d1
	bra.w	.1
.0
	bclr	#6,(sflags8).w
	movea.l	#TeamSongs,a0
	movea.l	#RandomSongs,a1
	move.w	(HmTeam).w,d0
	mulu.w	#6,d0
	add.w	(SongIndex).w,d0
	clr.w	d1
	move.b	(a0,d0.w),d1
	bne.w	.1
	move.w	#8,d0
	jsr	(randomd0).l
	andi.w	#7,d0
	move.b	(a1,d0.w),d1
.1
	ext.w	d1
	move.w	d1,(SongNum).w
	movem.l	(sp)+,d0-d1/a0-a1
	rts

TeamSongs							;6 song bytes per team (TeamList order), by
									;SongIndex. 0 = a RandomSongs song
	dc.b	$3A,$40,$49,$54,$46,$00	;0 ANH
	dc.b	$51,$42,$40,$00,$46,$51	;1 BOS
	dc.b	$33,$32,$32,$33,$46,$00	;2 BUF
	dc.b	$34,$35,$34,$35,$49,$49	;3 CGY
	dc.b	$36,$39,$37,$36,$46,$4E	;4 CHI
	dc.b	$51,$42,$42,$00,$46,$00	;5 DAL
	dc.b	$38,$3F,$39,$00,$46,$3F	;6 DET
	dc.b	$3B,$51,$51,$00,$46,$00	;7 EDM
	dc.b	$45,$48,$3C,$55,$46,$00	;8 FLA
	dc.b	$3D,$3E,$45,$3E,$46,$3D	;9 HFD
	dc.b	$3F,$3F,$39,$35,$46,$40	;10 LA
	dc.b	$3F,$55,$3F,$44,$46,$43	;11 MTL
	dc.b	$32,$37,$32,$00,$46,$38	;12 NJ
	dc.b	$32,$42,$32,$41,$46,$41	;13 NYI
	dc.b	$51,$42,$32,$00,$46,$00	;14 NYR
	dc.b	$4A,$35,$39,$52,$46,$00	;15 OTW
	dc.b	$45,$37,$45,$33,$00,$33	;16 PHI
	dc.b	$34,$45,$34,$47,$46,$47	;17 PIT
	dc.b	$48,$49,$48,$00,$46,$49	;18 QUE
	dc.b	$4A,$4A,$4B,$4C,$4D,$4E	;19 SJ
	dc.b	$50,$42,$42,$50,$46,$43	;20 STL
	dc.b	$51,$52,$52,$00,$46,$00	;21 TB
	dc.b	$34,$34,$53,$00,$46,$00	;22 TOR
	dc.b	$43,$42,$54,$00,$46,$00	;23 VAN
	dc.b	$3F,$32,$3F,$00,$46,$4A	;24 WSH
	dc.b	$32,$3F,$55,$00,$46,$00	;25 WPG
	dc.b	$51,$42,$32,$00,$46,$00	;26 ASE
	dc.b	$51,$42,$32,$00,$46,$00	;27 ASW

RandomSongs							;8 songs ChooseSong picks from at random
	dc.b	$33,$3D,$3E,$41,$33,$47,$4E,$4F

p_initialZ80						;Unreferenced. ClearAllTrackAndSFXSlots, then reset the Z80.
									;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$E0,$E0,$61,$00,$00,$42,$33,$FC,$01,$00,$00,$A1,$12,$00
	dc.b	$33,$FC,$01,$00,$00,$A1,$11,$00,$08,$39,$00,$00,$00,$A1,$11,$00
	dc.b	$66,$F6,$33,$FC,$00,$00,$00,$A1,$12,$00,$33,$FC,$00,$00,$00,$A1
	dc.b	$11,$00,$30,$3C,$01,$F4,$51,$C8,$FF,$FE,$33,$FC,$01,$00,$00,$A1
	dc.b	$12,$00,$4C,$DF,$07,$07,$4E,$75

ClearAllTrackAndSFXSlots			;PlayingSong = -1.
									;Code the listing does not decode: kept as bytes
	dc.b	$31,$FC,$FF,$FF,$D2,$A2,$4E,$75

newcheck							;Start a new check sound: one of 4 sounds
									;$1C-$1F, never the last one again
	move.l	d0,-(sp)
	moveq	#3,d0
	jsr	(randomd0).l
	addq.w	#1,d0					;1-3 sounds on from the last one
	add.w	(ltack).w,d0			;last tackle sound
	andi.w	#3,d0
	move.w	d0,(ltack).w
	addi.w	#$1C,d0					;first check sound
	move.w	d0,-(sp)
	bsr.w	sfx
	move.l	(sp)+,d0
	rts
