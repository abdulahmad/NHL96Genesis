;	Top level of the ROM build. It includes the equates and then every module in ROM order, and
;	each file assembles right after the one before it. Only this file sets the start address; a
;	segment build sets its own in its stub. The include comments are the ROM map.

	include	stubinc\ports.inc		;IO_* / VDP_* ports. Equates only
	include	stubinc\equals.inc		;VDP status bits. Equates only
	include	ram96.asm				;RAM map. Equates only
	include	externs96.asm			;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac		;String, Player and the other data macros

	org	0							;the ROM starts at 0. Without an org SNASM writes a short, misaligned bin
									;(the stubs carry their own org)
	include	main96.asm				; $000000  code
	include	..\output\names\teamdata96.asm	; $000776  VBjsr, TeamList and the team blocks, playoffseats
	include	credits96.asm			; $0056F0  Credits, CreditsList
	include	frames96.asm			; $005F96  SPAlist and the sprite animation tables
	include	srambits96.asm			; $0096E8  save RAM bit fields
	include	engine\faceoff96.asm	; $0099CA  faceoffs
	include	engine\input96.asm		; $00A4DC  pad input
	include	engine\goal96.asm		; $00B04E  controller setup screen
	include	engine\fourway96.asm	; $00B5C8  4 way play adaptor
	include	engine\fight96.asm		; $00B6A0  fighting
	include	engine\logic96.asm		; $00C548  assignment table, penalty texts
	include	engine\lines96.asm		; $00EC30  line change box
	include	engine\lines96_set.asm	; $00EF00  team lines
	include	engine\input96_shot.asm	; $00F374  shot and pass
	include	front\trade96.asm		; $0100C0  roster names
	include	front\season96_sim.asm	; $01091A  season game simulation
	include	front\season96.asm		; $010CB2  season and save screens
	include	teamgfx96.asm			; $012BFE  team graphics pointers
	include	schedule96.asm			; $013558  season schedule
	include	front\awards96.asm		; $013EA0  playoff seeding
	include	engine\pause96_list.asm	; $0143FE  menu lists
	include	hockey96.asm			; $01464C  cold start and game loop
	include	engine\pause96.asm		; $014CC8  demo and pause menu
	include	engine\setup96.asm		; $0151FA  roster attribute columns
	include	engine\pause96_menu.asm	; $015490  pause-menu entries
	include	engine\players96_count.asm	; $015774  team counts
	include	engine\replay96.asm		; $01581C  instant replay
	include	control96.asm			; $0162F0  player frame update
	include	engine\logic96_ass.asm	; $016DAE  assignment entries
	include	engine\logic96_puck.asm	; $017C06  puck assignments
	include	front\shootout96.asm	; $019018  penalty shot and shootout
	include	engine\logic96_pull.asm	; $019782  goalie pull
	include	engine\logic96_vec.asm	; $019F3E  puck vectors
	include	engine\skate96.asm		; $01A614  skating
	include	engine\video96.asm		; $01AF00  screen and print
	include	engine\penalty96.asm	; $01BF94  penalties
	include	engine\lines96_bar.asm	; $01D14E  line energy
	include	hockey96_inter.asm		; $01D3CE  intermission
	include	engine\collide96.asm	; $01D7FE  collisions
	include	engine\players96.asm	; $01FB52  on the ice
	include	display96.asm			; $0201DC  picture
	include	control96_team.asm		; $021482  team setup
	include	hockey96_open.asm		; $0215DC  title and periods
	include	engine\setup96_menu.asm	; $021B52  default menus
	include	engine\playoff96.asm	; $021BB0  playoff tree
	include	engine\goal96_box.asm	; $022820  goal box
	include	engine\middle96.asm		; $022E70  player names
	include	crash96.asm				; $023144  exceptions
	include	display96_crowd.asm		; $023248  crowd frames
	include	engine\middle96_ascii.asm	; $0232C8  big font chars
	include	engine\lines96_list.asm	; $023342  line names
	include	engine\setup96_pos.asm	; $023370  position names
	include	engine\middle96_per.asm	; $023384  period names
	include	engine\video96_size.asm	; $0233AC  sprite sizes
	include	engine\players96_sub.asm	; $0233BC  line slots
	include	engine\setup96_attr.asm	; $02342E  attribute columns
	include	engine\pause96_items.asm	; $0236B0  pause menus
	include	engine\lines96_menu.asm	; $023E54  line menus
	include	sram96.asm				; $023F1C  save RAM
	include	engine\video96_pad.asm	; $024226  pads
	include	engine\logic96_do.asm	; $024380  assignment
	include	engine\video96_font.asm	; $0243A0  fonts
	include	engine\logic96_crease.asm	; $02441E  crease
	include	engine\pause96_play.asm	; $02447E  resume game
	include	sound\sound96.asm				; $024486  sound
	include	front\scout96.asm		; $08880A  scout text
	include	graphics96.asm			; $08F2C6  graphics
	include	engine\logic96_timer.asm	; $1D6622  one-timer
	include	code96_14.asm			; $1D6B66  records and attributes
	include	front\shootout96_path.asm	; $1D7FA6  shootout
	include	code96_15.asm			; $1D8E5C  loads and hi-score
	include	front\season96_stand.asm	; $1D9CC6  standings
	include	front\season96_menu.asm	; $1DA6C0  season menu
	include	front\trade96_edit.asm	; $1DC03C  trades
	include	front\create96.asm		; $1DD916  create player
	include	front\options96.asm		; $1E0DDE  options
	include	front\stats96.asm		; $1E1B18  line editor
	include	engine\pause96_return.asm	; $1E2688  return to game
	include	front\summary96.asm		; $1E2E76  pause summaries
	include	front\stats96_list.asm	; $1E55BA  player stats
	include	front\records96.asm		; $1E646C  name entry
	include	engine\playoff96_tree.asm	; $1E700A  playoff tree screen
	include	engine\middle96_clock.asm	; $1E7664  clock
	include	front\awards96_show.asm	; $1E7AC4  awards
	include	front\injury96.asm		; $1E8794  injuries
	include	front\title96.asm		; $1E889C  opening screens
	include	checksum96.asm			; $1E9028  checksum
	dcb.b	$200000-*,$FF			;fill to the 2 MB ROM end
