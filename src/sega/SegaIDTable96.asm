;	Cartridge header. It tells the console what the cartridge is: its name, copyright, titles,
;	serial number, checksum, supported controllers, memory ranges and regions.

;					Data No. Address	Description
	dc.b	'SEGA GENESIS    '		; 01	$100	Sega Genesis ID (16 bytes)
	dc.b	'(C)T-50 1995.JUL'		; 02	$110	company ID / release date (YYYY.MMM) (16 bytes)
	dc.b	'NHL ''96                                         '	;03 $120 domestic name (48 bytes)
	dc.b	'NHL ''96                                         '	;04 $150 overseas name (48
																;bytes)
ProductCode							;The serial number; the long at +$C holds the
									;checksum word (ValidationRoutine)
	dc.b	'GM T-172036-00'		; 05	$180	cartridge cat., product no., version no. (14 bytes)
	IF CHECKSUM=1					; Security check enabled
		dc.w	$DB17				; 06	$18E	ROM checksum (installed by checksum tool) (2 bytes)
	ELSE							; Security check disabled
		dc.w	$0000				; 06	$18E	ROM checksum (installed by checksum tool) (2 bytes)
	ENDIF
	dc.b	'J               '		; 07	$190	I/O peripheral info. (J=Control Pad) (16 bytes)
	dc.l	$00000000,$001FFFFF		; 08	$1A0	cartridge size (start and end address) (8 bytes). 2 MB
	dc.l	$00FF0000,$00FFFFFF		; 09	$1A8	RAM size (start and end address) (8 bytes)
	dc.b	'            '			;10 $1B0 external RAM info. (12 bytes): none listed (95 listed its backup
									;RAM here)
	dc.b	'            '			; 11	$1BC	modem info. (12 bytes)
	dc.b	'                                        '	; 12	$1C8	reserved (40 bytes)
CountryCode							;The region lock (CHECK_VDP) reads the first letter as a hex digit of
									;region bits
	dc.b	'F               '		;13	$1F0	country code for release (16 bytes). F = Japan, USA and Europe
