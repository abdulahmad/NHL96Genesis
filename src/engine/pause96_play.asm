;	Leave a menu and go back to the game.

PlayGame							;The "Resume Game" / "Start Game" menu item: leave the menu (sflags5 bit
									;1).
									;Code the listing does not decode: kept as bytes
	dc.b	$08,$F8,$00,$01,$C3,$44,$4E,$75
