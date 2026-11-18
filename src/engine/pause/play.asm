;	Leave a menu and go back to the game.

PlayGame							;The "Resume Game" / "Start Game" menu item: leave the menu (sflags5 bit
									;1).
	bset	#1,(sflags5).w
	rts
