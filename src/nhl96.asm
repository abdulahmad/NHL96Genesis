;	Top level of the ROM build. It includes the equates and then every module in ROM order, and
;	each file assembles right after the one before it. Only this file sets the start address. The include comments are the ROM map.

	include	inc\ports.inc		;IO_* / VDP_* ports. Equates only
	include	inc\equals.inc		;VDP status bits. Equates only
	include	ram96.asm				;RAM map. Equates only
	include	externs96.asm			;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac		;String, Player and the other data macros

	org	0							;the ROM starts at 0. Without an org SNASM writes a short, misaligned bin
	include	main96.asm				; $000000  code
	include	..\output\obj\names\teamdata96.asm	; $000776  VBjsr, TeamList and the team blocks, playoffseats
	include	front\credits96.asm			; $0056F0  Credits, CreditsPages
	include	frames96.asm			; $005F96  SPAlist and the sprite animation tables
	include	srambits96.asm			; $0096E8  save RAM bit fields
	include	engine\faceoff96.asm	; $0099CA  faceoffs
	include	engine\input\input96.asm		; $00A4DC  pad input
	include	engine\goal\goal96.asm		; $00B04E  controller setup screen
	include	engine\fourway96.asm	; $00B5C8  4 way play adaptor
	include	engine\fight96.asm		; $00B6A0  fighting
	include	engine\logic\logic96.asm		; $00C548  assignment table, penalty texts
	include	engine\lines\lines96.asm		; $00EC30  line change box
	include	engine\lines\set.asm	; $00EF00  team lines
	include	engine\input\shot.asm	; $00F374  shot and pass
	include	front\trade\trade96.asm		; $0100C0  roster names
	include	front\season\sim.asm	; $01091A  season game simulation
	include	front\season\season96.asm		; $010CB2  season and save screens
	include	teamgfx96.asm			; $012BFE  team graphics pointers
	include	front\schedule96.asm			; $013558  season schedule
	include	front\awards\awards96.asm		; $013EA0  playoff seeding
	include	engine\pause\list.asm	; $0143FE  menu lists
	include	engine\hockey\hockey96.asm			; $01464C  cold start and game loop
	include	engine\pause\pause96.asm		; $014CC8  demo and pause menu
	include	engine\setup\setup96.asm		; $0151FA  roster attribute columns
	include	engine\pause\menu.asm	; $015490  pause-menu entries
	include	engine\players\count.asm	; $015774  team counts
	include	engine\replay\replay96.asm		; $01581C  instant replay
	include	engine\control\control96.asm			; $0162F0  player frame update
	include	engine\logic\ass.asm	; $016DAE  assignment entries
	include	engine\logic\puck.asm	; $017C06  puck assignments
	include	front\shootout\shootout96.asm	; $019018  penalty shot and shootout
	include	engine\logic\pull.asm	; $019782  goalie pull
	include	engine\logic\vec.asm	; $019F3E  puck vectors
	include	engine\skate\skate96.asm		; $01A614  skating
	include	engine\video\video96.asm		; $01AF00  screen and print
	include	engine\penalty\penalty96.asm	; $01BF94  penalties
	include	engine\lines\bar.asm	; $01D14E  line energy
	include	engine\hockey\inter.asm		; $01D3CE  intermission
	include	engine\collide\collide96.asm	; $01D7FE  collisions
	include	engine\players\players96.asm	; $01FB52  on the ice
	include	engine\display\display96.asm			; $0201DC  picture
	include	engine\control\team.asm		; $021482  team setup
	include	engine\hockey\open.asm		; $0215DC  title and periods
	include	engine\setup\menu.asm	; $021B52  default menus
	include	engine\playoff\playoff96.asm	; $021BB0  playoff tree
	include	engine\goal\box.asm	; $022820  goal box
	include	engine\middle\middle96.asm		; $022E70  player names
	include	engine\crash96.asm				; $023144  exceptions
	include	engine\display\crowd.asm		; $023248  crowd frames
	include	engine\middle\ascii.asm	; $0232C8  big font chars
	include	engine\lines\list.asm	; $023342  line names
	include	engine\setup\pos.asm	; $023370  position names
	include	engine\middle\per.asm	; $023384  period names
	include	engine\video\size.asm	; $0233AC  sprite sizes
	include	engine\players\sub.asm	; $0233BC  line slots
	include	engine\setup\attr.asm	; $02342E  attribute columns
	include	engine\pause\items.asm	; $0236B0  pause menus
	include	engine\lines\menu.asm	; $023E54  line menus
	include	sram96.asm				; $023F1C  save RAM
	include	engine\video\pad.asm	; $024226  pads
	include	engine\logic\do.asm	; $024380  assignment
	include	engine\video\font.asm	; $0243A0  fonts
	include	engine\logic\crease.asm	; $02441E  crease
	include	engine\pause\play.asm	; $02447E  resume game
	include	sound\sound96.asm				; $024486  sound
	include	front\scout\scout96.asm		; $08880A  scout text
	include	graphics96.asm			; $08F2C6  graphics
	include	engine\logic\timer.asm	; $1D6622  one-timer
	include	engine\logic\onetimer.asm	; $1D6B66  one-timer shot
	include	engine\display\meter.asm	; $1D6D22  crowd meter
	include	engine\collide\corner.asm	; $1D6E0E  corner collision
	include	engine\players\attr.asm	; $1D6F24  attribute calc
	include	front\scout\hotcold.asm	; $1D6FC6  hot and cold players
	include	engine\collide\wall.asm	; $1D72F6  wall collision
	include	engine\logic\slot.asm	; $1D733C  slot bit
	include	graphics96_logopal.asm	; $1D7390  logo palettes
	include	engine\middle\string.asm	; $1D7A90  string copy
	include	front\records\io.asm	; $1D7B08  team records
	include	engine\middle\names.asm	; $1D7D62  name appending, attribute weights
	include	front\shootout\path.asm	; $1D7FA6  shootout
	include	engine\middle\teamgfx.asm	; $1D8E5C  replay icon, team graphics
	include	engine\goal\print.asm	; $1D8EF6  goal and assist counts
	include	engine\skate\board.asm	; $1D8F66  board fall
	include	front\injury\fight.asm	; $1D9062  fight bytes
	include	front\title\hiscore.asm	; $1D9114  hi-score screen
	include	engine\logic\shotpass.asm	; $1D920A  shot and pass prep
	include	engine\middle\goalie.asm	; $1D9352  goalie pulled
	include	engine\logic\onetimerend.asm	; $1D9376  one-timer end
	include	graphics96_logopal2.asm	; $1D93C8  logo palettes
	include	engine\penalty\song.asm	; $1D9748  lead song, penalty clear
	include	engine\pause\pad.asm	; $1D9844  pause pad side
	include	engine\replay\block.asm	; $1D98EE  can block
	include	front\season\stand.asm	; $1D9CC6  standings
	include	front\season\menu.asm	; $1DA6C0  season menu
	include	front\trade\edit.asm	; $1DC03C  trades
	include	front\create96.asm		; $1DD916  create player
	include	front\options96.asm		; $1E0DDE  options
	include	front\stats\stats96.asm		; $1E1B18  line editor
	include	engine\pause\return.asm	; $1E2688  return to game
	include	front\summary96.asm		; $1E2E76  pause summaries
	include	front\stats\list.asm	; $1E55BA  player stats
	include	front\records\records96.asm		; $1E646C  name entry
	include	engine\playoff\tree.asm	; $1E700A  playoff tree screen
	include	engine\middle\clock.asm	; $1E7664  clock
	include	front\awards\show.asm	; $1E7AC4  awards
	include	front\injury\injury96.asm		; $1E8794  injuries
	include	front\title\title96.asm		; $1E889C  opening screens
	include	checksum96.asm			; $1E9028  checksum
	dcb.b	$200000-*,$FF			;fill to the 2 MB ROM end
