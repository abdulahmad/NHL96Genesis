;	*** ANONYMIZED: the player names and team nicknames are placeholders. ***
;	Players are P001 ... P624, nicknames N01 ... N26. The real ones are NHLPA / NHL licensed
;	data and are not in this repository.

;	Each Player row and each nickname String has a placeholder of the same length as the
;	real text (the Player macro writes the row length, so it must not change). The ratings
;	after a name are unchanged.

;	This file does not assemble into the real game by itself and is not included directly:
;	it needs the original ROM.

;	tools/extractAssets96.js reads the names from your ROM into Extracted/PlayerNames.txt
;	and Extracted/TeamNicknames.txt (one per line, in the order they appear below).

;	tools/prebuild.js (run by every build) copies this file to output/names/teamdata96.asm
;	with the real names put back, and nhl96.asm includes that copy.

;	Keep the placeholder lengths when editing a name or adding a player.
;
;	Team data. TeamList points to one record per team, and the playoff seeds follow the teams.
;	96 has no All-Star teams: the two All-Star slots of TeamList point to Boston and Montreal.
;	VBjsr, the vertical blank vector's jump through VBint, sits in front of the team data.

VBjsr								;Vertical blank interrupt (level 6), jumps through the VBint RAM vector
	move.l	(VBint).l,-(sp)			;push handler address
	rts								;and "return" into it

TeamList							;Team number = index (ANH 0 ... WPG 25, then the All-Star slots ASE 26 and
									;ASW 27)
	dc.l	Anaheim					;0 ANH
	dc.l	Boston					;1 BOS
	dc.l	Buffalo					;2 BUF
	dc.l	Calgary					;3 CGY
	dc.l	Chicago					;4 CHI
	dc.l	Dallas					;5 DAL
	dc.l	Detroit					;6 DET
	dc.l	Edmonton				;7 EDM
	dc.l	Florida					;8 FLA
	dc.l	Hartford				;9 HFD
	dc.l	LosAngeles				;10 LA
	dc.l	Montreal				;11 MTL
	dc.l	NewJersey				;12 NJ
	dc.l	NewYorkI				;13 NYI
	dc.l	NewYorkR				;14 NYR
	dc.l	Ottawa					;15 OTW
	dc.l	Philadelphia			;16 PHI
	dc.l	Pittsburgh				;17 PIT
	dc.l	Quebec					;18 QUE
	dc.l	SanJose					;19 SJ
	dc.l	StLouis					;20 STL
	dc.l	TampaBay				;21 TB
	dc.l	Toronto					;22 TOR
	dc.l	Vancouver				;23 VAN
	dc.l	Washington				;24 WSH
	dc.l	Winnipeg				;25 WPG
	dc.l	Boston					;26 ASE slot
	dc.l	Montreal				;27 ASW slot

NumofTeams	=	(*-TeamList)/4
Playerdata	=	0
Palettedata	=	2
Teamname	=	4
LineSets	=	6
ScoutReport	=	8
GoalieOdds	=	10

;------------------------
; Team block: 6 offset words (the equates above), .pad home and visitor palettes (16 colours each, incbin
; <team>h96 / <team>v96), .sr (4 bytes of bonuses), .godds (starting goalie weights), .ls lines of 8
; player numbers (1 = first .pld entry), .pld players ended by an empty String, then 4 Strings: city,
; abbreviation, nickname, arena, then .pos.
; .pos: one nibble per player in .pld order, the player's slot in .ls order (0 G, 1 LD, 2 RD, 3 LW, 4 C, 5
; RW), padded with $F nibbles (Toronto has no pad).
; Blocks are in ROM order: Dallas sits between LA and MTL, and WSH comes before WPG.
;------------------------
;------------------------
; .sr: 4 bytes, byte 3 is never read. byte 0: scoring odds of simulated games (SetScore): bits 4-6 = offense
; row, bits 0-2 = defense row of the weights table; byte 1: high nibble = penalty kill deficit, low nibble =
; power play bonus; byte 2: high nibble = home bonus, low nibble = visitor bonus (negated)
;q - scoring odds offense row (bits 4-6)
;r - scoring odds defense row (bits 0-2)
;e - penalty kill deficit
;b - power play bonus

;h - home bonus
;v - visitor bonus
;x - not read
;x - not read
; Player ratings (Player macro: name, then 16 nibbles unwl,sodp,chga,eytm)
;u - uniform # x10
;n - uniform # x1
;w - weight
;l - leg power
;s - speed
;o - offensive awareness
;d - defensive awareness
;p - shot power / NA for goalie
;c - checking strength / NA
;h - shooting hand / glove hand
;g - stickhandling / glove left saves
;a - shooting accuracy / glove right saves
;e - endurance / stick right saves
;y - shot/pass decision / stick left saves
;t - passing accuracy / consistency
;m - aggressiveness (PIM) / NA
;------------------------

Anaheim								;ANH
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.godds-.0
.pad
	incbin	..\Extracted\NHL96\Graphics\Pals\ANHh96.pal
	incbin	..\Extracted\NHL96\Graphics\Pals\ANHv96.pal
.sr
;		qreb,hvxx
	dc.w	$0000,$0000
.godds
	dc.b	193,0
.ls									;8 lines of 8 player numbers
;		-G,LD,RD,LW,-C,RW,XA,00
	dc.b	01,20,17,13,04,07,11,00	;line 1 Sc1
	dc.b	01,20,23,13,03,07,06,00	;line 2 Sc2
	dc.b	01,21,17,14,04,08,11,00	;line 3 Chk
	dc.b	01,22,18,15,05,09,11,00	;line 4 PP1
	dc.b	01,23,17,13,04,08,06,00	;line 5 PP2
	dc.b	01,20,18,14,03,07,11,00	;line 6 PK1
	dc.b	01,21,17,13,04,11,06,00	;line 7 PK2
	dc.b	01,20,23,10,09,11,06,00	;line 8
.pld								;roster, ended by an empty String
;										unwl,sodp,chga,eytm
	Player	'P001______',	3164,3232,0000,3233
	Player	'P002______________',	3563,2222,0000,2223
	Player	'P003___________',	2172,2322,0422,2421
	Player	'P004__________',	4753,3433,1744,4231
	Player	'P005_________',	2092,2323,1223,3331
	Player	'P006__________',	1273,3222,2732,4531
	Player	'P007_____',	1484,3223,3533,3327
	Player	'P008______',	19A3,3333,4533,3422
	Player	'P009________',	2552,4232,2832,3222
	Player	'P010_______',	0873,2333,1633,3221
	Player	'P011_________',	1144,4323,1432,2332
	Player	'P012_____',	36B1,1212,3512,231A
	Player	'P013_______',	0944,5423,2244,3442
	Player	'P014__________',	2293,3322,2442,3643
	Player	'P015______',	1872,2233,3633,3321
	Player	'P016________',	1683,3234,2322,2321
	Player	'P017___________',	1054,4423,2642,3541
	Player	'P018__________',	0482,2222,2522,2324
	Player	'P019______',	1582,2232,3B22,3329
	Player	'P020________',	02A3,2343,3222,3321
	Player	'P021_______',	05A2,1142,5621,3123
	Player	'P022___________',	29B3,2141,3421,4118
	Player	'P023_______',	2483,3424,2631,4431
	Player	'P024_______',	0682,1223,2622,2222
	dc.w	2						;end of the player list: an empty String
.tn									;City
	String	'Anaheim'
.ta									;Abbreviation
	String	'ANH'
.tm									;Nickname
	String	'N01_________'
.ar									;Arena
	String	'Arrowhead Pond Of Anaheim'
.pos								;Position slot of each player
	dc.b	$00,$44,$44,$55,$55,$55,$33,$33,$22,$21,$11,$11,$FF,$FF

Boston								;BOS
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.godds-.0
.pad
	incbin	..\Extracted\NHL96\Graphics\Pals\BOSh96.pal
	incbin	..\Extracted\NHL96\Graphics\Pals\BOSv96.pal
.sr
	dc.w	$0000,$0000
.godds
	dc.b	193,0
.ls
	dc.b	01,24,17,11,03,06,07,00
	dc.b	01,21,17,11,03,06,07,00
	dc.b	01,22,18,12,04,07,13,00
	dc.b	01,23,19,13,05,08,16,00
	dc.b	01,24,17,11,03,06,13,00
	dc.b	01,23,19,13,04,08,16,00
	dc.b	01,21,17,14,03,05,07,00
	dc.b	01,22,19,11,04,07,05,00
.pld
	Player	'P025_________',	3184,4434,0020,4444
	Player	'P026____________',	3763,3222,0050,2222
	Player	'P027______',	1275,4653,3554,5661
	Player	'P028___________',	2004,4434,2333,3234
	Player	'P029_________',	2252,2322,1533,3431
	Player	'P030_____',	08A3,3645,4B45,4245
	Player	'P031__________',	2363,4333,3732,3232
	Player	'P032______________',	1972,3422,1343,3331
	Player	'P033_______',	2981,2112,3512,312A
	Player	'P034_______',	4402,3323,2333,3323
	Player	'P035______',	2143,4343,2433,3331
	Player	'P036_________',	2763,2334,3933,4235
	Player	'P037________',	2643,3322,1432,3542
	Player	'P038_____',	1793,3243,3624,4422
	Player	'P039________',	1862,2332,3433,4139
	Player	'P040________',	4274,3322,0832,3331
	Player	'P041_______',	77A5,4555,4265,6451
	Player	'P042_______',	3663,2233,3222,3232
	Player	'P043______',	3492,2242,3722,4225
	Player	'P044__________',	2881,2122,3712,321A
	Player	'P045_______',	3244,3343,4431,4442
	Player	'P046____________',	0694,3233,3232,3531
	Player	'P047_______',	38A3,2234,3322,3138
	Player	'P048______',	43B4,3446,4A32,3243
	dc.w	2
.tn
	String	'Boston'
.ta
	String	'BOS'
.tm
	String	'N02___'
.ar
	String	'Boston Garden'
.pos
	dc.b	$00,$44,$45,$55,$55,$33,$33,$33,$22,$22,$11,$11,$FF,$FF

Buffalo								;BUF
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.godds-.0
.pad
	incbin	..\Extracted\NHL96\Graphics\Pals\BUFh96.pal
	incbin	..\Extracted\NHL96\Graphics\Pals\BUFv96.pal
.sr
	dc.w	$0000,$0000
.godds
	dc.b	193,0
.ls
	dc.b	01,22,18,04,03,08,11,00
	dc.b	01,22,18,11,03,08,04,00
	dc.b	01,23,19,12,04,09,07,00
	dc.b	01,24,20,13,05,10,04,00
	dc.b	01,19,18,11,03,08,04,00
	dc.b	01,23,22,12,04,09,03,00
	dc.b	01,22,18,12,04,03,07,00
	dc.b	01,24,20,08,07,03,04,00
.pld
	Player	'P049_________',	3946,4454,0030,6666
	Player	'P050________',	3562,3443,0030,3333
	Player	'P051__________',	1655,4644,2944,4452
	Player	'P052__________',	1066,4544,2643,4551
	Player	'P053________',	2644,4433,2443,3541
	Player	'P054_______',	1462,2232,2622,2533
	Player	'P055_______',	2093,2353,3733,4431
	Player	'P056____________',	8976,6634,1454,4251
	Player	'P057__________',	2854,4434,2534,3132
	Player	'P058_________',	1863,3343,3733,3223
	Player	'P059________',	1374,3443,3533,4331
	Player	'P060_________',	1783,4444,2B34,3531
	Player	'P061____',	2794,2223,4632,322B
	Player	'P062___________',	0954,3312,1342,3431
	Player	'P063___',	32A2,2121,3222,212B
	Player	'P064_________',	3393,3132,3632,3423
	Player	'P065______',	4383,4323,2233,3237
	Player	'P066__________',	4465,4433,3642,4541
	Player	'P067_______',	08A4,3342,2631,4531
	Player	'P068______',	0592,2142,4621,4524
	Player	'P069______',	0672,2122,3921,2224
	Player	'P070________',	0373,3342,3431,3541
	Player	'P071___________',	42A3,2344,3232,3338
	Player	'P072_________',	22A3,2243,3432,3534
	dc.w	2
.tn
	String	'Buffalo'
.ta
	String	'BUF'
.tm
	String	'N03___'
.ar
	String	'Memorial Auditorium'
.pos
	dc.b	$00,$44,$44,$45,$55,$33,$33,$33,$32,$22,$21,$11,$FF,$FF

Calgary								;CGY
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.godds-.0
.pad
	incbin	..\Extracted\NHL96\Graphics\Pals\CGYh96.pal
	incbin	..\Extracted\NHL96\Graphics\Pals\CGYv96.pal
.sr
	dc.w	$0000,$0000
.godds
	dc.b	193,0
.ls
	dc.b	01,22,18,14,03,09,04,00
	dc.b	01,22,18,14,03,09,04,00
	dc.b	01,23,19,15,04,10,05,00
	dc.b	01,24,20,16,05,11,06,00
	dc.b	01,22,20,14,03,09,07,00
	dc.b	01,19,18,15,04,10,08,00
	dc.b	01,22,18,09,03,04,08,00
	dc.b	01,23,19,15,05,04,08,00
.pld
	Player	'P073_______',	3734,4323,0000,3444
	Player	'P074__________',	3163,3212,0030,2232
	Player	'P075__________',	2584,3544,3644,4241
	Player	'P076__________',	2664,4424,2244,3342
	Player	'P077_____',	29B3,2253,5523,4426
	Player	'P078_______',	1162,2243,3B33,4532
	Player	'P079____',	1762,3332,1333,3431
	Player	'P080____________',	9254,4423,2432,3541
	Player	'P081__________',	1435,5444,4544,4344
	Player	'P082______________',	1664,4423,2633,3341
	Player	'P083________',	2282,2212,3723,232A
	Player	'P084__________',	1571,1222,3322,3129
	Player	'P085___________',	2343,5222,1932,2221
	Player	'P086________',	1073,4544,4A35,534B
	Player	'P087________',	1374,3434,2234,3231
	Player	'P088______',	1292,2222,3423,3229
	Player	'P089_________',	3263,4322,1632,3431
	Player	'P090________',	0665,5533,2643,4551
	Player	'P091___________',	33A5,4434,3442,5431
	Player	'P092_________',	0595,3333,3732,3541
	Player	'P093______',	0473,2242,3922,3332
	Player	'P094__________',	2193,3444,3432,4441
	Player	'P095_______',	0393,4142,3821,3422
	Player	'P096________',	1873,3142,3831,3533
	dc.w	2
.tn
	String	'Calgary'
.ta
	String	'CGY'
.tm
	String	'N04___'
.ar
	String	'Olympic Saddledome'
.pos
	dc.b	$00,$44,$44,$44,$55,$55,$53,$33,$32,$22,$21,$11,$FF,$FF

Chicago								;CHI
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.godds-.0
.pad
	incbin	..\Extracted\NHL96\Graphics\Pals\CHIh96.pal
	incbin	..\Extracted\NHL96\Graphics\Pals\CHIv96.pal
.sr
	dc.w	$0000,$0000
.godds
	dc.b	193,0
.ls
	dc.b	01,22,18,09,03,08,07,00
	dc.b	01,21,18,13,03,08,07,00
	dc.b	01,22,19,14,04,09,06,00
	dc.b	01,23,20,15,05,10,12,00
	dc.b	01,22,18,13,03,08,14,00
	dc.b	01,21,19,15,04,09,16,00
	dc.b	01,21,18,09,03,04,12,00
	dc.b	01,22,19,10,04,12,11,00
.pld
	Player	'P097______',	3066,4565,0020,5565
	Player	'P098________',	3152,3112,0010,2233
	Player	'P099__________',	2745,5545,4544,5356
	Player	'P100___________',	9263,3543,2744,4452
	Player	'P101________',	1263,2353,4733,5435
	Player	'P102_______',	1172,3332,3732,3532
	Player	'P103________',	1855,3423,1543,3641
	Player	'P104_______',	1064,5434,1233,4531
	Player	'P105______',	1774,5434,3234,4342
	Player	'P106_______',	3384,3353,4732,4232
	Player	'P107_______',	1591,1121,2511,211A
	Player	'P108_______',	24B3,3223,4622,212C
	Player	'P109__________',	44A3,4324,3233,4239
	Player	'P110_________',	3263,3343,3634,3432
	Player	'P111_____________',	2544,4414,1443,2231
	Player	'P112________',	1993,4223,3433,3322
	Player	'P113_____',	55A2,3322,2232,2322
	Player	'P114_________',	0774,4465,4742,554A
	Player	'P115_________',	02A3,4333,3632,4331
	Player	'P116_________',	0694,4132,4521,3433
	Player	'P117_______',	05B4,4353,4622,5245
	Player	'P118______',	2075,4444,4642,5541
	Player	'P119_______',	0853,3132,5821,322A
	Player	'P120________',	0492,3212,3422,1221
	dc.w	2
.tn
	String	'Chicago'
.ta
	String	'CHI'
.tm
	String	'N05_______'
.ar
	String	'United Center'
.pos
	dc.b	$00,$44,$44,$45,$55,$55,$33,$33,$32,$22,$11,$11,$FF,$FF

Detroit								;DET
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.godds-.0
.pad
	incbin	..\Extracted\NHL96\Graphics\Pals\DETh96.pal
	incbin	..\Extracted\NHL96\Graphics\Pals\DETv96.pal
.sr
	dc.w	$0000,$0000
.godds
	dc.b	193,0
.ls
	dc.b	01,21,22,04,03,08,05,00
	dc.b	01,21,18,13,03,08,06,00
	dc.b	01,22,19,14,04,09,07,00
	dc.b	01,23,20,15,05,10,11,00
	dc.b	01,21,20,13,03,08,04,00
	dc.b	01,22,19,05,04,09,03,00
	dc.b	01,21,18,10,03,04,05,00
	dc.b	01,22,19,15,04,03,05,00
.pld
	Player	'P121_______',	2944,4444,0030,4454
	Player	'P122________',	3034,3343,0010,3344
	Player	'P123__________',	9176,6554,2265,5451
	Player	'P124_________',	1965,5544,1753,5551
	Player	'P125_________',	55B2,4433,3235,3335
	Player	'P126________',	2363,3322,2232,3321
	Player	'P127_______',	3373,4242,2232,4431
	Player	'P128___________',	2255,3525,2534,4349
	Player	'P129________',	2662,2514,1535,3131
	Player	'P130______',	1763,3242,3734,4332
	Player	'P131___________',	2092,1322,2522,2322
	Player	'P132__________',	25A2,2233,4522,432B
	Player	'P133___________',	1354,3423,1244,3231
	Player	'P134_____',	2165,4242,4632,4222
	Player	'P135______',	1162,2242,3233,3423
	Player	'P136___________',	1893,3342,3833,3322
	Player	'P137_______',	32B1,1021,2211,211B
	Player	'P138_____',	03A3,3142,4B21,4224
	Player	'P139_______________',	1664,4243,4331,4433
	Player	'P140_____',	0463,2333,2A31,2632
	Player	'P141_______',	7796,5534,2652,5562
	Player	'P142____________',	0554,3444,2232,4541
	Player	'P143_________',	02A1,2132,3621,3529
	Player	'P144____________',	44A3,3333,2432,3431
	dc.w	2
.tn
	String	'Detroit'
.ta
	String	'DET'
.tm
	String	'N06______'
.ar
	String	'Joe Louis Sports Arena'
.pos
	dc.b	$00,$44,$44,$45,$55,$55,$33,$33,$32,$22,$11,$11,$FF,$FF

Edmonton							;EDM
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.godds-.0
.pad
	incbin	..\Extracted\NHL96\Graphics\Pals\EDMh96.pal
	incbin	..\Extracted\NHL96\Graphics\Pals\EDMv96.pal
.sr
	dc.w	$0000,$0000
.godds
	dc.b	193,0
.ls
	dc.b	01,22,15,11,03,09,06,00
	dc.b	01,21,15,11,03,08,06,00
	dc.b	01,22,16,12,04,09,07,00
	dc.b	01,23,17,13,05,10,06,00
	dc.b	01,22,17,11,03,09,06,00
	dc.b	01,23,15,12,04,15,07,00
	dc.b	01,22,15,08,05,04,10,00
	dc.b	01,23,16,13,03,04,17,00
.pld
	Player	'P145________',	3045,4435,0020,4455
	Player	'P146___________',	3152,2222,0010,1222
	Player	'P147________',	0784,4434,3534,4348
	Player	'P148_______',	3963,3433,2242,3541
	Player	'P149_________',	2674,5323,1434,3331
	Player	'P150__________',	1272,2222,2223,3321
	Player	'P151_________',	3773,5233,2222,3421
	Player	'P152____________',	16A3,3242,4222,3326
	Player	'P153________',	2064,4433,1333,3534
	Player	'P154_______',	1873,2232,3522,4325
	Player	'P155_________',	0993,3444,4633,4336
	Player	'P156__________',	2563,4222,2522,3231
	Player	'P157__________',	1793,3242,3622,3429
	Player	'P158_________',	29C1,1212,3622,1119
	Player	'P159_________',	2195,3334,3632,4331
	Player	'P160______',	2894,4332,2231,4433
	Player	'P161____________',	1594,4434,1732,3541
	Player	'P162_____',	06A1,2022,2711,2323
	Player	'P163________',	3292,2032,5510,4226
	Player	'P164_______',	3492,2132,3521,3325
	Player	'P165___________',	2483,3242,4821,3426
	Player	'P166_________',	0274,3312,1532,3534
	Player	'P167___________',	22B3,3132,4620,332A
	Player	'P168______',	4083,2242,1822,3233
	dc.w	2
.tn
	String	'Edmonton'
.ta
	String	'EDM'
.tm
	String	'N07___'
.ar
	String	'Northlands Coliseum'
.pos
	dc.b	$00,$44,$44,$45,$55,$33,$33,$22,$22,$22,$11,$11,$FF,$FF

Florida								;FLA
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.godds-.0
.pad
	incbin	..\Extracted\NHL96\Graphics\Pals\FLAh96.pal
	incbin	..\Extracted\NHL96\Graphics\Pals\FLAv96.pal
.sr
	dc.w	$0000,$0000
.godds
	dc.b	193,0
.ls
	dc.b	01,24,17,15,06,10,09,00
	dc.b	01,21,17,11,03,07,06,00
	dc.b	01,22,18,12,04,08,06,00
	dc.b	01,23,19,13,05,09,06,00
	dc.b	01,22,17,11,05,07,06,00
	dc.b	01,24,18,15,03,10,06,00
	dc.b	01,21,17,12,04,10,11,00
	dc.b	01,22,18,09,06,10,11,00
.pld
	Player	'P169___________',	3454,3454,0010,4455
	Player	'P170___________',	3073,3223,0010,4434
	Player	'P171______',	1453,3433,2333,3431
	Player	'P172___________',	2084,3252,4633,4435
	Player	'P173__________',	2653,4433,2744,3241
	Player	'P174__________',	4494,5223,2633,3222
	Player	'P175__________',	2793,2324,4923,3226
	Player	'P176_____',	1292,2333,2733,3321
	Player	'P177__________',	2184,4233,3532,4438
	Player	'P178________',	2292,3424,1734,3231
	Player	'P179______',	1082,3333,3623,3232
	Player	'P180______',	1872,2343,3422,3336
	Player	'P181___________',	2963,3322,2232,3431
	Player	'P182________',	1162,2233,2423,2228
	Player	'P183__________',	1974,3323,1632,3431
	Player	'P184___________',	1593,4242,3023,4222
	Player	'P185_______',	0585,4324,2333,3447
	Player	'P186_______',	02A2,2133,3322,3324
	Player	'P187________',	1682,2133,3921,3226
	Player	'P188_______',	0472,2132,3721,3233
	Player	'P189_______',	2594,3132,3432,3425
	Player	'P190_________',	0783,3323,2642,4541
	Player	'P191_____',	0392,2132,5521,342A
	Player	'P192___________',	2853,3322,2432,3531
	dc.w	2
.tn
	String	'Florida'
.ta
	String	'FLA'
.tm
	String	'N08_____'
.ar
	String	'Miami Arena'
.pos
	dc.b	$00,$44,$44,$55,$55,$33,$33,$33,$22,$22,$11,$11,$FF,$FF

Hartford							;HFD
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.godds-.0
.pad
	incbin	..\Extracted\NHL96\Graphics\Pals\HFDh96.pal
	incbin	..\Extracted\NHL96\Graphics\Pals\HFDv96.pal
.sr
	dc.w	$0000,$0000
.godds
	dc.b	193,0
.ls
	dc.b	01,19,16,15,05,07,03,00
	dc.b	01,19,16,12,03,07,06,00
	dc.b	01,20,17,13,04,08,06,00
	dc.b	01,21,18,14,05,09,06,00
	dc.b	01,19,16,13,03,07,06,00
	dc.b	01,20,18,12,05,15,06,00
	dc.b	01,19,16,09,05,06,07,00
	dc.b	01,21,17,12,06,07,08,00
.pld
	Player	'P193______',	01A4,3423,0040,4455
	Player	'P194______',	3542,3322,0010,2222
	Player	'P195__________',	2173,3442,2643,4641
	Player	'P196_____________',	1153,3332,2432,5432
	Player	'P197___________',	8964,5435,1833,4231
	Player	'P198_________',	22B2,2243,4623,4326
	Player	'P199_____',	1374,4232,3642,3537
	Player	'P200_______',	12B2,2222,3723,2234
	Player	'P201___________',	2694,3244,5432,4316
	Player	'P202_______',	2781,1111,2911,321B
	Player	'P203_______',	52B1,2233,2B22,3322
	Player	'P204_______',	1853,4343,2633,3231
	Player	'P205___________',	0864,5434,2234,4232
	Player	'P206________',	3394,4213,1534,4331
	Player	'P207________',	2884,5323,1532,3131
	Player	'P208_________',	4473,3433,3233,3338
	Player	'P209_____',	0673,3234,4822,4338
	Player	'P210___________',	0494,3343,2732,3333
	Player	'P211_______',	2085,4443,3442,4431
	Player	'P212_______',	07A4,3233,1431,2332
	Player	'P213__________',	1082,2142,3230,3432
	Player	'P214_____________',	05A2,3232,3622,3511
	Player	'P215___________',	06B2,2132,4421,242B
	Player	'P216_______',	2362,2233,3621,3322
	dc.w	2
.tn
	String	'Hartford'
.ta
	String	'HFD'
.tm
	String	'N09____'
.ar
	String	'Hartford Civic Center'
.pos
	dc.b	$00,$44,$44,$55,$55,$53,$33,$32,$22,$11,$11,$11,$FF,$FF

LosAngeles							;LA
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.godds-.0
.pad
	incbin	..\Extracted\NHL96\Graphics\Pals\LAh96.pal
	incbin	..\Extracted\NHL96\Graphics\Pals\LAv96.pal
.sr
	dc.w	$0000,$0000
.godds
	dc.b	193,0
.ls
	dc.b	01,21,16,12,03,08,07,00
	dc.b	01,20,16,12,03,07,06,00
	dc.b	01,21,17,13,04,08,07,00
	dc.b	01,22,18,14,05,09,08,00
	dc.b	01,20,16,12,03,07,09,00
	dc.b	01,21,17,13,04,08,03,00
	dc.b	01,20,16,14,03,04,07,00
	dc.b	01,21,17,08,05,04,03,00
.pld
	Player	'P217________',	3264,2344,0020,3333
	Player	'P218______',	3174,2353,0130,2244
	Player	'P219_________',	9946,4643,1464,5561
	Player	'P220_______',	1363,3322,1533,3541
	Player	'P221________',	1572,2232,2A23,2331
	Player	'P222______',	1252,3333,2622,3332
	Player	'P223________',	9293,3434,4734,333B
	Player	'P224________',	2164,5443,3934,3334
	Player	'P225______',	1992,2343,3734,3121
	Player	'P226_______',	0892,2222,3521,3225
	Player	'P227________',	55A1,1112,2911,222A
	Player	'P228______',	1784,3434,2743,4441
	Player	'P229_____',	0753,3423,1634,3131
	Player	'P230__________',	4473,2333,3833,3331
	Player	'P231________',	2883,3333,3433,3223
	Player	'P232_____',	04A4,4444,4732,4343
	Player	'P233________',	2483,3333,3732,2434
	Player	'P234_________',	06B2,2223,3421,2329
	Player	'P235____________',	2673,3313,2732,3441
	Player	'P236__________',	33C2,2233,4522,523B
	Player	'P237________',	2594,3323,3432,3431
	Player	'P238_______',	2983,3312,2432,2531
	Player	'P239__________',	0373,3322,2632,2431
	Player	'P240_____',	7773,3322,2432,2432
	dc.w	2
.tn
	String	'Los Angeles'
.ta
	String	'LA'
.tm
	String	'N10__'
.ar
	String	'Great Western Forum'
.pos
	dc.b	$00,$44,$44,$55,$55,$53,$33,$32,$22,$21,$11,$11,$FF,$FF

Dallas								;DAL
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.godds-.0
.pad
	incbin	..\Extracted\NHL96\Graphics\Pals\DALh96.pal
	incbin	..\Extracted\NHL96\Graphics\Pals\DALv96.pal
.sr
	dc.w	$0000,$0000
.godds
	dc.b	193,0
.ls
	dc.b	01,22,17,13,03,09,04,00
	dc.b	01,21,17,13,03,08,04,00
	dc.b	01,22,18,14,04,09,05,00
	dc.b	01,23,19,15,05,10,06,00
	dc.b	01,19,17,13,03,08,04,00
	dc.b	01,22,18,14,04,09,03,00
	dc.b	01,21,17,16,09,04,03,00
	dc.b	01,22,18,10,03,04,05,00
.pld
	Player	'P241_________',	3463,3233,0010,3333
	Player	'P242_____',	3543,3323,0030,3333
	Player	'P243_______',	0975,5645,2444,5341
	Player	'P244________',	0643,5422,1933,3431
	Player	'P245_______',	1662,2243,3723,3334
	Player	'P246_______',	1063,4323,4523,2235
	Player	'P247_______',	2593,3243,4623,4335
	Player	'P248_______',	2293,3324,2523,3223
	Player	'P249______',	2374,4433,2633,4231
	Player	'P250_______',	2172,2241,3722,3323
	Player	'P251________',	2792,2221,4922,222A
	Player	'P252________',	3942,2332,3523,3222
	Player	'P253_______',	1564,4433,2434,4242
	Player	'P254_________',	1164,4332,3633,4331
	Player	'P255_______',	1794,3343,4632,3222
	Player	'P256___________',	4164,3333,3823,2231
	Player	'P257_________',	04B3,3444,5532,4246
	Player	'P258__________',	14A3,3243,3432,3138
	Player	'P259_________',	1294,3332,3632,2431
	Player	'P260_________',	4381,2112,3511,221A
	Player	'P261________',	03C2,2142,4220,3325
	Player	'P262__________',	0293,2234,4631,4329
	Player	'P263_______',	0584,3232,3231,3348
	Player	'P264______',	1872,2132,3821,3122
	dc.w	2
.tn
	String	'Dallas'
.ta
	String	'DAL'
.tm
	String	'N11__'
.ar
	String	'Reunion Arena'
.pos
	dc.b	$00,$44,$44,$45,$55,$55,$33,$33,$22,$22,$11,$11,$FF,$FF

Montreal							;MTL
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.godds-.0
.pad
	incbin	..\Extracted\NHL96\Graphics\Pals\MTLh96.pal
	incbin	..\Extracted\NHL96\Graphics\Pals\MTLv96.pal
.sr
	dc.w	$0000,$0000
.godds
	dc.b	193,0
.ls
	dc.b	01,23,19,12,03,06,05,00
	dc.b	01,22,19,12,03,06,04,00
	dc.b	01,23,20,13,04,07,05,00
	dc.b	01,24,21,14,05,08,06,00
	dc.b	01,23,19,12,03,06,04,00
	dc.b	01,24,20,13,05,07,06,00
	dc.b	01,22,19,12,05,04,03,00
	dc.b	01,23,20,07,03,04,05,00
.pld
	Player	'P265_______',	3366,4455,0000,6566
	Player	'P266_______',	0122,3232,0010,2222
	Player	'P267__________',	7795,4524,0444,4541
	Player	'P268________',	4963,4323,2433,3121
	Player	'P269_____',	1754,3242,2432,3321
	Player	'P270_______',	0865,4534,2245,4342
	Player	'P271______',	1253,4342,4533,4234
	Player	'P272_______',	1834,4323,0532,2331
	Player	'P273_______',	0643,2232,1232,3331
	Player	'P274____________',	3081,2224,3522,3229
	Player	'P275____',	3182,2212,3322,1421
	Player	'P276______________',	2564,4524,1054,3451
	Player	'P277_________',	2384,4424,2734,4231
	Player	'P278_________',	2264,3322,2632,2421
	Player	'P279__________',	2072,3222,2622,3422
	Player	'P280_________',	3261,1112,3622,1318
	Player	'P281___________',	3591,1122,3422,2129
	Player	'P282_________',	36D1,2122,2412,3028
	Player	'P283_____________',	38A4,3434,2432,3331
	Player	'P284_____________',	4354,3433,2933,3433
	Player	'P285_________',	34A2,2223,2731,2331
	Player	'P286________',	2493,2233,4322,322A
	Player	'P287_______',	2964,4334,3632,4432
	Player	'P288___________',	4864,3332,1632,3431
	dc.w	2
.tn
	String	'Montreal'
.ta
	String	'MTL'
.tm
	String	'N12______'
.ar
	String	'Montreal Forum'
.pos
	dc.b	$00,$44,$45,$55,$55,$53,$33,$33,$33,$22,$21,$11,$FF,$FF

NewJersey							;NJ
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.godds-.0
.pad
	incbin	..\Extracted\NHL96\Graphics\Pals\NJh96.pal
	incbin	..\Extracted\NHL96\Graphics\Pals\NJv96.pal
.sr
	dc.w	$0000,$0000
.godds
	dc.b	193,0
.ls
	dc.b	01,21,18,16,04,09,03,00
	dc.b	01,21,18,15,03,09,04,00
	dc.b	01,22,19,12,04,10,05,00
	dc.b	01,23,20,16,05,11,04,00
	dc.b	01,22,18,15,03,09,04,00
	dc.b	01,23,21,11,04,10,03,00
	dc.b	01,22,19,09,05,04,03,00
	dc.b	01,21,18,10,16,04,03,00
.pld
	Player	'P289__________',	3075,3344,0020,5556
	Player	'P290_________',	3124,4443,0030,4443
	Player	'P291_______',	0943,3353,2642,4442
	Player	'P292_________',	1464,4323,2643,3431
	Player	'P293_________',	1973,2242,2831,3433
	Player	'P294____',	1173,4322,1B32,3431
	Player	'P295_______',	16A2,3235,3322,3222
	Player	'P296_________',	1853,3333,2432,3431
	Player	'P297___________',	4494,5435,2735,4231
	Player	'P298__________',	22B3,4344,4532,4339
	Player	'P299_______',	1293,5335,3324,3229
	Player	'P300________',	1593,3544,3333,4223
	Player	'P301_______',	2073,3333,3522,4234
	Player	'P302_______',	2163,3233,4723,322B
	Player	'P303____________',	2564,4433,1644,3431
	Player	'P304_______',	1794,5232,3532,4323
	Player	'P305_______',	08A2,2323,2212,1128
	Player	'P306____________',	2794,4433,2442,3542
	Player	'P307_______',	03A3,2151,5221,4126
	Player	'P308__________',	0763,3222,2522,3324
	Player	'P309_________',	04B4,4354,5233,544A
	Player	'P310________',	2364,3342,3432,4332
	Player	'P311_________',	0673,2232,2231,3331
	Player	'P312__________',	0583,3122,2421,3321
	Player	'P313__________',	2992,2332,2632,3331
	dc.w	2
.tn
	String	'New Jersey'
.ta
	String	'NJ'
.tm
	String	'N13___'
.ar
	String	'Byrne Meadowlands Arena'
.pos
	dc.b	$00,$44,$44,$44,$55,$55,$55,$33,$32,$22,$11,$11,$1F,$FF

NewYorkI							;NYI
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.godds-.0
.pad
	incbin	..\Extracted\NHL96\Graphics\Pals\NYIh96.pal
	incbin	..\Extracted\NHL96\Graphics\Pals\NYIv96.pal
.sr
	dc.w	$0000,$0000
.godds
	dc.b	193,0
.ls
	dc.b	01,20,17,13,03,08,04,00
	dc.b	01,20,23,13,03,08,04,00
	dc.b	01,21,17,14,04,09,03,00
	dc.b	01,22,18,15,05,10,04,00
	dc.b	01,20,21,13,03,15,04,00
	dc.b	01,23,20,10,04,09,03,00
	dc.b	01,20,23,13,07,04,03,00
	dc.b	01,21,18,08,05,04,03,00
.pld
	Player	'P314____________',	3033,3342,0020,3232
	Player	'P315__________',	2973,3222,0000,2222
	Player	'P316________',	3264,4435,4434,423A
	Player	'P317_______',	2063,4434,2634,4233
	Player	'P318_________',	1843,5342,2533,3321
	Player	'P319______',	1062,3322,1432,2431
	Player	'P320______',	1463,3242,4732,4344
	Player	'P321___________',	2683,2442,4B32,4545
	Player	'P322__________',	6844,3322,1432,3431
	Player	'P323_________',	7593,2223,4522,2228
	Player	'P324_______',	1282,1011,3511,211A
	Player	'P325_________',	15B2,2231,3923,2422
	Player	'P326_______',	0994,4444,3233,4543
	Player	'P327________',	3982,3323,3532,3532
	Player	'P328______',	2793,2414,0234,3221
	Player	'P329__________',	0962,2223,2422,3221
	Player	'P330_____',	0283,2423,2732,3541
	Player	'P331_________',	4794,2123,3622,2123
	Player	'P332________',	0652,2122,3521,3222
	Player	'P333_____________',	7274,4444,3432,4344
	Player	'P334__________',	0783,3343,3632,4541
	Player	'P335________',	37A2,2222,3422,2422
	Player	'P336_____________',	1174,3233,5632,2338
	Player	'P337_________',	24A2,2133,3622,3223
	dc.w	2
.tn
	String	'New York'
.ta
	String	'NYI'
.tm
	String	'N14______'
.ar
	String	'Nassau Coliseum'
.pos
	dc.b	$00,$44,$44,$45,$55,$55,$33,$33,$22,$21,$11,$11,$FF,$FF

NewYorkR							;NYR
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.godds-.0
.pad
	incbin	..\Extracted\NHL96\Graphics\Pals\NYRh96.pal
	incbin	..\Extracted\NHL96\Graphics\Pals\NYRv96.pal
.sr
	dc.w	$0000,$0000
.godds
	dc.b	193,0
.ls
	dc.b	01,21,18,08,03,04,05,00
	dc.b	01,21,17,11,03,07,04,00
	dc.b	01,22,18,12,04,08,05,00
	dc.b	01,23,19,13,05,09,04,00
	dc.b	01,21,18,11,03,08,04,00
	dc.b	01,22,19,04,05,09,06,00
	dc.b	01,21,17,11,03,04,05,00
	dc.b	01,22,18,08,09,04,05,00
.pld
	Player	'P338________',	3576,3343,0000,5666
	Player	'P339_______',	3053,3533,0000,3332
	Player	'P340________',	1195,4543,4453,5455
	Player	'P341__________',	2776,5435,2264,4351
	Player	'P342_______',	1054,5424,1433,4441
	Player	'P343____________',	2274,4333,2532,3431
	Player	'P344_______',	1773,4434,3134,4244
	Player	'P345________',	2874,4464,4034,5342
	Player	'P346________',	1673,3444,3534,4433
	Player	'P347______',	2682,2132,3721,232C
	Player	'P348_______',	0994,4433,5033,4236
	Player	'P349____________',	3283,3242,4232,3334
	Player	'P350____________',	1364,3353,3434,6431
	Player	'P351__________',	1582,2133,4211,333A
	Player	'P352________',	1982,2222,3423,3218
	Player	'P353________',	2092,2242,3622,4322
	Player	'P354__________',	23B2,2243,5321,423A
	Player	'P355________',	2175,4544,3552,3551
	Player	'P356__________',	2563,3332,3532,3332
	Player	'P357________',	2982,2232,3322,3324
	Player	'P358________',	0266,3543,2252,5451
	Player	'P359______',	0483,2242,3431,3434
	Player	'P360_____',	24A2,2132,4421,2426
	Player	'P361____________',	0583,2132,4222,4334
	dc.w	2
.tn
	String	'New York'
.ta
	String	'NYR'
.tm
	String	'N15____'
.ar
	String	'Madison Square Garden'
.pos
	dc.b	$00,$44,$44,$55,$55,$33,$33,$33,$22,$22,$11,$11,$FF,$FF

Ottawa								;OTW
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.godds-.0
.pad
	incbin	..\Extracted\NHL96\Graphics\Pals\OTWh96.pal
	incbin	..\Extracted\NHL96\Graphics\Pals\OTWv96.pal
.sr
	dc.w	$0000,$0000
.godds
	dc.b	193,0
.ls
	dc.b	01,23,18,04,03,10,05,00
	dc.b	01,21,18,14,03,09,04,00
	dc.b	01,22,19,15,04,10,05,00
	dc.b	01,23,20,16,05,11,04,00
	dc.b	01,21,18,14,03,05,04,00
	dc.b	01,23,22,11,04,10,05,00
	dc.b	01,22,19,16,10,03,04,00
	dc.b	01,23,18,15,03,04,05,00
.pld
	Player	'P362_______',	3143,3333,0030,3333
	Player	'P363__________',	3042,2112,0020,2121
	Player	'P364_________',	1995,4524,2354,3351
	Player	'P365___________',	9154,4314,2043,3441
	Player	'P366______',	7692,2314,2443,3231
	Player	'P367__________',	0753,3303,1733,2331
	Player	'P368_________',	1773,2222,3623,3231
	Player	'P369________',	2692,2212,2522,3323
	Player	'P370________',	1063,4322,3733,4231
	Player	'P371_________',	8253,4423,1443,3441
	Player	'P372___________',	1573,2323,1833,3221
	Player	'P373_______',	2562,3313,1733,3323
	Player	'P374_________',	7863,3233,1432,3231
	Player	'P375___________',	6194,4324,0C32,3121
	Player	'P376____________',	0752,3232,3822,3439
	Player	'P377________',	2983,4232,3622,5329
	Player	'P378_________',	1872,2123,2422,2216
	Player	'P379_____',	0383,3232,3522,3432
	Player	'P380___________',	0683,2142,3421,3321
	Player	'P381_______',	2192,1122,4811,341A
	Player	'P382____',	0282,3122,2621,3422
	Player	'P383_________',	0593,3223,3821,3323
	Player	'P384_______',	9474,3222,2432,3437
	Player	'P385_____________',	2471,3223,2621,3321
	dc.w	2
.tn
	String	'Ottawa'
.ta
	String	'OTW'
.tm
	String	'N16_____'
.ar
	String	'Ottawa Civic Center'
.pos
	dc.b	$00,$44,$44,$44,$55,$55,$53,$33,$32,$22,$11,$11,$FF,$FF

Philadelphia						;PHI
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.godds-.0
.pad
	incbin	..\Extracted\NHL96\Graphics\Pals\PHIh96.pal
	incbin	..\Extracted\NHL96\Graphics\Pals\PHIv96.pal
.sr
	dc.w	$0000,$0000
.godds
	dc.b	193,0
.ls
	dc.b	01,21,18,14,03,10,04,00
	dc.b	01,21,18,14,03,10,04,00
	dc.b	01,22,19,15,04,11,05,00
	dc.b	01,23,20,16,05,12,06,00
	dc.b	01,21,18,14,03,10,04,00
	dc.b	01,23,19,15,04,11,03,00
	dc.b	01,22,19,04,03,05,06,00
	dc.b	01,21,18,11,05,04,03,00
.pld
	Player	'P386_______',	2773,3443,0040,3322
	Player	'P387___________',	3363,3333,0010,3232
	Player	'P388________',	88C4,4656,6756,526A
	Player	'P389__________',	1794,4444,3234,6542
	Player	'P390___________',	1483,3352,4432,5333
	Player	'P391______',	0973,3232,3932,3423
	Player	'P392__________',	2253,3212,1533,2331
	Player	'P393________',	2582,3322,2432,2431
	Player	'P394___________',	4473,4333,2632,4231
	Player	'P395________',	10B3,4435,4435,3233
	Player	'P396________',	1174,4343,2733,4132
	Player	'P397_______',	1883,3333,2923,3223
	Player	'P398______',	2191,1131,2511,211C
	Player	'P399__________',	1974,3534,4245,5442
	Player	'P400__________',	4583,2422,2432,3431
	Player	'P401__________',	1273,3313,2432,3231
	Player	'P402_________',	08C1,2112,4611,221A
	Player	'P403______________',	0275,4343,3332,4432
	Player	'P404___________',	3794,3354,4733,4331
	Player	'P405_______',	2073,2122,2421,3237
	Player	'P406________',	2354,4243,3821,4534
	Player	'P407________',	0553,2243,3422,3222
	Player	'P408_________',	06B3,3332,2422,2431
	Player	'P409________',	2493,2222,2432,2434
	dc.w	2
.tn
	String	'Philadelphia'
.ta
	String	'PHI'
.tm
	String	'N17___'
.ar
	String	'Spectrum'
.pos
	dc.b	$00,$44,$44,$44,$45,$55,$53,$33,$32,$22,$11,$11,$FF,$FF

Pittsburgh							;PIT
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.godds-.0
.pad
	incbin	..\Extracted\NHL96\Graphics\Pals\PITh96.pal
	incbin	..\Extracted\NHL96\Graphics\Pals\PITv96.pal
.sr
	dc.w	$0000,$0000
.godds
	dc.b	193,0
.ls
	dc.b	01,20,16,12,03,09,08,00
	dc.b	01,20,16,12,03,09,08,00
	dc.b	01,21,17,13,04,10,08,00
	dc.b	01,22,18,14,05,11,08,00
	dc.b	01,21,16,12,09,11,08,00
	dc.b	01,20,18,13,03,10,08,00
	dc.b	01,20,16,09,03,08,04,00
	dc.b	01,22,17,14,07,08,05,00
.pld
	Player	'P410________',	35A4,4554,0140,4444
	Player	'P411_______',	3183,3333,0020,3333
	Player	'P412_______',	1094,3553,4243,5551
	Player	'P413_______',	1174,3433,2734,4549
	Player	'P414_______',	1283,3242,4732,3333
	Player	'P415______',	0983,3322,1232,2532
	Player	'P416_______',	1683,4242,3422,4334
	Player	'P417_________',	66A5,4635,2966,3461
	Player	'P418________',	68A5,4644,4465,6551
	Player	'P419___________',	1794,4535,2633,4133
	Player	'P420______',	0764,3443,2535,4331
	Player	'P421__________',	2074,4535,2236,5241
	Player	'P422_________',	25B3,3525,3435,424A
	Player	'P423___________',	1573,4434,1234,4231
	Player	'P424__________',	2964,3222,2432,2421
	Player	'P425________',	55A4,3554,3333,5551
	Player	'P426____________',	28E2,2144,4531,4233
	Player	'P427________',	23A3,3323,3332,344B
	Player	'P428____________',	06A2,2132,3722,3221
	Player	'P429__________',	0584,4243,5430,4534
	Player	'P430________',	0473,3323,2632,3541
	Player	'P431________',	2263,3423,2632,4531
	Player	'P432___________',	18B3,2132,4421,3229
	Player	'P433____________',	3291,2133,4820,3324
	dc.w	2
.tn
	String	'Pittsburgh'
.ta
	String	'PIT'
.tm
	String	'N18_____'
.ar
	String	'Civic Arena'
.pos
	dc.b	$00,$44,$44,$44,$55,$53,$33,$32,$22,$21,$11,$11,$FF,$FF

Quebec								;QUE
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.godds-.0
.pad
	incbin	..\Extracted\NHL96\Graphics\Pals\QUEh96.pal
	incbin	..\Extracted\NHL96\Graphics\Pals\QUEv96.pal
.sr
	dc.w	$0000,$0000
.godds
	dc.b	193,0
.ls
	dc.b	01,20,17,13,03,09,04,00
	dc.b	01,20,17,12,03,08,04,00
	dc.b	01,21,18,13,04,09,05,00
	dc.b	01,22,19,14,05,10,06,00
	dc.b	01,17,03,09,04,08,05,00
	dc.b	01,20,10,12,05,13,06,00
	dc.b	01,20,18,10,05,03,06,00
	dc.b	01,21,19,13,03,05,06,00
.pld
	Player	'P434____________',	4155,3324,0020,5555
	Player	'P435__________',	3554,3333,0010,4343
	Player	'P436_____',	1964,3644,2455,5461
	Player	'P437__________',	2164,4433,2243,3561
	Player	'P438______',	0974,3443,4434,3346
	Player	'P439______',	2844,3232,3423,3323
	Player	'P440___________',	4753,4342,4832,3423
	Player	'P441____________',	5133,4433,3644,4331
	Player	'P442______',	1183,4425,4735,423A
	Player	'P443_______',	4873,5445,1534,3432
	Player	'P444_________',	1443,3422,1532,2331
	Player	'P445________',	1783,3436,4A34,424B
	Player	'P446___________',	1384,4425,2744,4451
	Player	'P447__________',	1873,3433,3534,3443
	Player	'P448_______',	12D2,1222,3811,212A
	Player	'P449___________',	2553,3323,1842,3531
	Player	'P450_____',	04C3,2334,3732,4132
	Player	'P451____________',	0293,3232,3221,4531
	Player	'P452______',	5284,3332,3931,3434
	Player	'P453_____________',	0793,4342,3633,5431
	Player	'P454_________',	0682,3332,2832,3431
	Player	'P455_______',	2982,2143,3422,3438
	Player	'P456__________',	0563,3333,2432,3431
	Player	'P457___________',	2253,3312,1432,2431
	dc.w	2
.tn
	String	'Quebec'
.ta
	String	'QUE'
.tm
	String	'N19______'
.ar
	String	'Colisee de Quebec'
.pos
	dc.b	$00,$44,$44,$45,$55,$53,$33,$33,$22,$21,$11,$11,$FF,$FF

SanJose								;SJ
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.godds-.0
.pad
	incbin	..\Extracted\NHL96\Graphics\Pals\SJh96.pal
	incbin	..\Extracted\NHL96\Graphics\Pals\SJv96.pal
.sr
	dc.w	$0000,$0000
.godds
	dc.b	193,0
.ls
	dc.b	01,19,17,10,04,07,05,00
	dc.b	01,19,16,12,03,07,05,00
	dc.b	01,20,17,13,04,08,06,00
	dc.b	01,21,18,10,05,09,06,00
	dc.b	01,19,17,05,04,08,06,00
	dc.b	01,20,16,12,03,07,06,00
	dc.b	01,19,16,07,03,04,05,00
	dc.b	01,20,18,09,04,05,06,00
.pld
	Player	'P458_______',	3254,3443,0020,3434
	Player	'P459_________',	3143,3323,0010,3233
	Player	'P460________',	3963,4423,2444,3241
	Player	'P461________',	1574,3543,1453,4661
	Player	'P462_________',	0744,3433,1633,3241
	Player	'P463_______',	1373,3333,3433,3331
	Player	'P464______',	2284,3434,3434,5341
	Player	'P465_______',	1774,4323,1733,4231
	Player	'P466________',	0874,4343,2533,4331
	Player	'P467__________',	2465,4433,1243,3452
	Player	'P468_________',	4263,4222,3522,2332
	Player	'P469_______',	1442,3323,1534,3431
	Player	'P470_________',	47B2,3313,2742,3341
	Player	'P471__________',	23B3,2132,3532,3337
	Player	'P472_______',	3691,2222,3512,412A
	Player	'P473_______',	4083,2232,3432,3332
	Player	'P474________',	4144,4323,2532,2433
	Player	'P475____',	0473,2133,4922,322A
	Player	'P476___________',	0674,4434,2234,4342
	Player	'P477____',	0291,2132,3A22,3229
	Player	'P478_________',	38B3,3234,2422,3121
	Player	'P479_______',	0373,2322,0432,2541
	Player	'P480___________',	2663,3322,1432,3331
	Player	'P481________',	44A1,1111,2411,211A
	dc.w	2
.tn
	String	'San Jose'
.ta
	String	'SJ'
.tm
	String	'N20___'
.ar
	String	'San Jose Arena'
.pos
	dc.b	$00,$44,$44,$55,$55,$53,$33,$32,$22,$11,$11,$11,$FF,$FF

StLouis								;STL
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.godds-.0
.pad
	incbin	..\Extracted\NHL96\Graphics\Pals\STLh96.pal
	incbin	..\Extracted\NHL96\Graphics\Pals\STLv96.pal
.sr
	dc.w	$0000,$0000
.godds
	dc.b	193,0
.ls
	dc.b	01,19,18,14,09,13,10,00
	dc.b	01,22,18,13,03,09,10,00
	dc.b	01,23,19,14,04,10,11,00
	dc.b	01,24,20,15,05,11,06,00
	dc.b	01,23,18,14,04,09,06,00
	dc.b	01,19,20,13,03,10,04,00
	dc.b	01,22,18,13,09,04,05,00
	dc.b	01,19,20,14,05,06,07,00
.pld
	Player	'P482_________',	3165,3464,0010,4445
	Player	'P483_____',	3023,3343,0010,3233
	Player	'P484_____',	1473,4333,2623,3231
	Player	'P485__________',	20A3,2323,2633,3233
	Player	'P486__________',	2164,2242,4731,4331
	Player	'P487__________',	2264,3323,2544,3443
	Player	'P488_________',	2693,2323,2433,2441
	Player	'P489__________',	3662,2232,1431,2521
	Player	'P490______',	1694,4526,2335,4241
	Player	'P491__________',	0974,4433,2433,4333
	Player	'P492___________',	1272,2222,2632,3321
	Player	'P493________',	2763,3233,3523,3229
	Player	'P494________',	1094,4455,4432,3349
	Player	'P495____________',	19A3,3545,4535,4246
	Player	'P496________',	0762,2343,3424,4332
	Player	'P497______',	18A1,1111,3410,211A
	Player	'P498____________',	2573,3312,1633,2331
	Player	'P499_______',	0284,4446,3732,5242
	Player	'P500__________',	2884,4544,1432,4441
	Player	'P501________',	0693,2232,3532,5332
	Player	'P502______',	0483,3133,3520,3123
	Player	'P503________',	34A3,3132,3621,222A
	Player	'P504_______',	0565,4432,1632,4541
	Player	'P505________',	33B2,2323,2233,3331
	dc.w	2
.tn
	String	'St. Louis'
.ta
	String	'STL'
.tm
	String	'N21__'
.ar
	String	'Kiel Center'
.pos
	dc.b	$00,$44,$44,$44,$55,$55,$33,$33,$32,$22,$21,$11,$FF,$FF

TampaBay							;TB
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.godds-.0
.pad
	incbin	..\Extracted\NHL96\Graphics\Pals\TBh96.pal
	incbin	..\Extracted\NHL96\Graphics\Pals\TBv96.pal
.sr
	dc.w	$0000,$0000
.godds
	dc.b	193,0
.ls
	dc.b	01,19,15,11,03,08,06,00
	dc.b	01,19,15,11,03,08,06,00
	dc.b	01,20,16,12,04,09,06,00
	dc.b	01,21,17,13,05,10,06,00
	dc.b	01,19,15,10,03,08,06,00
	dc.b	01,17,16,04,05,09,06,00
	dc.b	01,19,15,12,04,05,06,00
	dc.b	01,21,16,13,07,06,05,00
.pld
	Player	'P506_______',	9394,3454,0100,4444
	Player	'P507_________',	3072,2221,0010,2121
	Player	'P508_________',	1944,4434,2533,4342
	Player	'P509_________',	7792,3334,4032,3449
	Player	'P510__________',	2763,2323,1543,3431
	Player	'P511________',	0994,4222,2432,3431
	Player	'P512_______',	2872,2232,2722,3331
	Player	'P513______',	8575,5414,1544,4231
	Player	'P514_______',	1492,3334,3534,4131
	Player	'P515______________',	2963,4423,2433,3231
	Player	'P516_________',	1574,4343,2433,3441
	Player	'P517____________',	3462,4232,2432,4231
	Player	'P518_______',	0792,2322,2432,4438
	Player	'P519_________',	1692,2223,2521,3232
	Player	'P520_________',	2563,3232,4422,3323
	Player	'P521________',	0382,2222,3421,3422
	Player	'P522_________',	20A2,2232,3521,432A
	Player	'P523__________',	0682,2232,2632,2431
	Player	'P524_________',	4473,2333,4433,3235
	Player	'P525______',	0492,2123,2421,3332
	Player	'P526________',	2182,1122,3621,3229
	Player	'P527________',	2651,2122,3411,3129
	Player	'P528__________',	3992,1223,3412,322A
	dc.w	2
.tn
	String	'Tampa Bay'
.ta
	String	'TB'
.tm
	String	'N22______'
.ar
	String	'Thunderdome'
.pos
	dc.b	$00,$44,$44,$45,$55,$33,$33,$22,$22,$11,$11,$1F,$FF,$FF

Toronto								;TOR
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.godds-.0
.pad
	incbin	..\Extracted\NHL96\Graphics\Pals\TORh96.pal
	incbin	..\Extracted\NHL96\Graphics\Pals\TORv96.pal
.sr
	dc.w	$0000,$0000
.godds
	dc.b	193,0
.ls
	dc.b	01,23,20,09,03,08,05,00
	dc.b	01,22,19,13,03,08,06,00
	dc.b	01,23,20,14,04,09,07,00
	dc.b	01,24,21,15,05,10,03,00
	dc.b	01,23,19,13,03,08,04,00
	dc.b	01,22,20,14,04,09,05,00
	dc.b	01,24,21,14,03,04,05,00
	dc.b	01,22,19,08,04,05,06,00
.pld
	Player	'P529________',	2965,3364,0000,5555
	Player	'P530_________',	0153,3223,0000,4343
	Player	'P531________',	9345,4554,3243,6542
	Player	'P532_______',	0794,4433,2234,4541
	Player	'P533________',	2874,5433,1444,4541
	Player	'P534_________',	2563,3333,2732,3321
	Player	'P535______',	2663,4423,2533,3431
	Player	'P536_______',	1374,5544,1555,4551
	Player	'P537________',	1175,5425,2533,5141
	Player	'P538______',	0964,3314,4732,3222
	Player	'P539____',	0892,3323,4332,322B
	Player	'P540_______',	2063,3232,2322,4322
	Player	'P541___________',	14B3,2534,3535,5231
	Player	'P542______',	2482,4343,3233,4332
	Player	'P543_____',	1073,2232,4423,4223
	Player	'P544___________',	1883,3232,2422,3322
	Player	'P545_________',	2173,2222,3422,212A
	Player	'P546__________',	2292,2022,3821,232A
	Player	'P547__________',	1573,3433,1532,3442
	Player	'P548_________',	1974,4334,3432,4432
	Player	'P549_________',	0292,3142,5521,4236
	Player	'P550_____',	2363,3332,3832,4533
	Player	'P551_______',	0495,4434,3432,4442
	Player	'P552________',	3483,3244,4421,4248
	dc.w	2
.tn
	String	'Toronto'
.ta
	String	'TOR'
.tm
	String	'N23________'
.ar
	String	'Maple Leaf Gardens'
.pos
	dc.b	$00,$44,$44,$45,$55,$55,$33,$33,$33,$22,$21,$11

Vancouver							;VAN
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.godds-.0
.pad
	incbin	..\Extracted\NHL96\Graphics\Pals\VANh96.pal
	incbin	..\Extracted\NHL96\Graphics\Pals\VANv96.pal
.sr
	dc.w	$0000,$0000
.godds
	dc.b	193,0
.ls
	dc.b	01,22,18,07,03,08,13,00
	dc.b	01,21,18,13,03,07,10,00
	dc.b	01,22,19,14,04,08,11,00
	dc.b	01,23,20,15,05,09,12,00
	dc.b	01,22,18,13,03,07,04,00
	dc.b	01,21,19,15,04,08,05,00
	dc.b	01,23,19,08,03,05,06,00
	dc.b	01,22,18,07,04,05,06,00
.pld
	Player	'P553_______',	0165,4444,0000,4444
	Player	'P554________',	3553,3453,0000,3232
	Player	'P555_________',	1693,3444,4144,4346
	Player	'P556_________',	0755,5432,2432,4542
	Player	'P557___________',	2084,4343,3433,4441
	Player	'P558_________',	1572,2132,3621,4323
	Player	'P559__________',	0965,6434,2533,4341
	Player	'P560______',	1056,6535,1255,4251
	Player	'P561_____',	3353,3323,2733,3231
	Player	'P562______',	1992,2222,3712,222A
	Player	'P563___________',	2072,2222,2522,3323
	Player	'P564_________',	2883,3303,1633,2234
	Player	'P565___________',	1475,5444,1433,3244
	Player	'P566__________',	2383,3333,2634,3235
	Player	'P567__________',	27A4,3334,4433,3338
	Player	'P568_______',	29A3,2233,4622,332B
	Player	'P569_________',	4263,3424,1434,3233
	Player	'P570______',	2294,4445,2933,4341
	Player	'P571______________',	0263,2212,2532,2432
	Player	'P572_______',	0592,2244,3821,4229
	Player	'P573________',	0385,5222,2422,3331
	Player	'P574_______',	2175,4442,1231,4541
	Player	'P575_______',	44A2,2343,3621,4432
	Player	'P576____________',	34B3,2232,3422,3222
	dc.w	2
.tn
	String	'Vancouver'
.ta
	String	'VAN'
.tm
	String	'N24____'
.ar
	String	'General Motors Place'
.pos
	dc.b	$00,$44,$44,$55,$55,$55,$33,$33,$32,$22,$11,$11,$FF,$FF

Washington							;WSH
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.godds-.0
.pad
	incbin	..\Extracted\NHL96\Graphics\Pals\WSHh96.pal
	incbin	..\Extracted\NHL96\Graphics\Pals\WSHv96.pal
.sr
	dc.w	$0000,$0000
.godds
	dc.b	193,0
.ls
	dc.b	01,22,18,14,03,11,04,00
	dc.b	01,21,18,14,03,11,04,00
	dc.b	01,22,19,15,04,12,05,00
	dc.b	01,23,20,16,05,13,06,00
	dc.b	01,22,18,14,03,11,04,00
	dc.b	01,21,19,05,04,12,05,00
	dc.b	01,22,19,15,05,06,07,00
	dc.b	01,21,18,16,11,06,07,00
.pld
	Player	'P577_____',	3065,4344,0000,5565
	Player	'P578_______',	3782,2222,0010,2121
	Player	'P579______',	9054,5533,1553,4651
	Player	'P580__________',	2083,4443,2633,3552
	Player	'P581_______',	3282,2453,4434,444A
	Player	'P582_______',	0973,2242,3823,3434
	Player	'P583_____',	1484,3323,0932,3431
	Player	'P584__________',	2342,2122,3411,3129
	Player	'P585_______',	3673,3142,4422,4324
	Player	'P586_________',	4183,3313,2332,3331
	Player	'P587________',	1264,6434,1445,4241
	Player	'P588_______',	2672,3333,4433,3135
	Player	'P589_______',	2562,2233,4522,4328
	Player	'P590_____________',	0873,3444,3534,3342
	Player	'P591________',	1084,4343,2233,4542
	Player	'P592____________',	2263,3333,3433,3333
	Player	'P593________',	2792,2212,3612,211B
	Player	'P594________',	0364,3343,3332,4533
	Player	'P595_______',	0473,2243,3622,4335
	Player	'P596_______',	2873,3223,2422,2221
	Player	'P597________',	2493,3344,5432,4426
	Player	'P598___________',	0694,4443,2432,4441
	Player	'P599______',	29A3,2242,3422,3325
	Player	'P600_______',	0592,2132,4421,4523
	dc.w	2
.tn
	String	'Washington'
.ta
	String	'WSH'
.tm
	String	'N25_____'
.ar
	String	'US Air Arena'
.pos
	dc.b	$00,$44,$44,$44,$44,$55,$53,$33,$32,$22,$11,$11,$FF,$FF

Winnipeg							;WPG
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.godds-.0
.pad
	incbin	..\Extracted\NHL96\Graphics\Pals\WPGh96.pal
	incbin	..\Extracted\NHL96\Graphics\Pals\WPGv96.pal
.sr
	dc.w	$0000,$0000
.godds
	dc.b	193,0
.ls
	dc.b	01,22,17,13,03,09,04,00
	dc.b	01,21,17,13,03,09,04,00
	dc.b	01,22,18,14,04,10,05,00
	dc.b	01,23,19,15,05,11,06,00
	dc.b	01,22,17,13,03,09,04,00
	dc.b	01,23,18,14,04,10,05,00
	dc.b	01,22,18,14,09,05,06,00
	dc.b	01,23,17,13,10,05,06,00
.pld
	Player	'P601_________',	2963,4443,0020,2222
	Player	'P602______________',	3553,3223,0000,2232
	Player	'P603__________',	1075,4544,2455,4451
	Player	'P604________',	2583,3433,2633,3551
	Player	'P605_____',	1693,2333,2833,3432
	Player	'P606________',	1572,2142,3621,4423
	Player	'P607________',	2372,2332,1233,3531
	Player	'P608_________',	3273,4322,2333,3432
	Player	'P609_________',	0865,6524,2554,5241
	Player	'P610__________',	1944,4434,2344,4442
	Player	'P611_____',	17A3,3242,4422,433A
	Player	'P612_________',	2163,2122,2632,2321
	Player	'P613_________',	0793,3444,5034,4249
	Player	'P614________',	1844,4333,2433,4432
	Player	'P615__________',	3493,2333,3423,4334
	Player	'P616_________',	7552,2223,3532,4322
	Player	'P617__________',	2775,3343,2732,4541
	Player	'P618____________',	04B2,2232,4522,4336
	Player	'P619__________',	0273,3122,3521,4635
	Player	'P620_________',	5593,2212,2432,2531
	Player	'P621__________',	2282,2111,2411,2219
	Player	'P622_______',	0393,4325,4421,433B
	Player	'P623__________',	2492,2132,3421,3223
	Player	'P624__________',	4282,2313,2332,2434
	dc.w	2
.tn
	String	'Winnipeg'
.ta
	String	'WPG'
.tm
	String	'N26_'
.ar
	String	'Winnipeg Arena'
.pos
	dc.b	$00,$44,$44,$44,$55,$55,$33,$33,$22,$22,$11,$11,$FF,$FF

playoffseats						;Playoff seeding: rows of 16 team numbers
	dc.b	TOR,DET,STL,CHI, LA,CGY,WPG,VAN, BUF,BOS,MTL,QUE, NYI,WSH,NJ,PIT
	dc.b	CGY,TOR,LA,VAN, STL,DET,DAL,CHI, NYI,BUF,TB,MTL, QUE,PIT,NYR,BOS
	dc.b	DAL,TOR,EDM,CHI, SJ,VAN,LA,DET, NJ,PIT,PHI,BUF, HFD,MTL,WSH,BOS
	dc.b	LA,TOR,EDM,DET, DAL,CHI,CGY,VAN, HFD,PIT,QUE,MTL, WSH,BOS,NJ,BUF
	dc.b	CGY,DET,SJ,TOR, DAL,VAN,EDM,CHI, QUE,BUF,NJ,PIT, HFD,MTL,PHI,BOS
	dc.b	SJ,VAN,CGY,DET, DAL,CHI,EDM,TOR, OTW,BOS,HFD,MTL, NYI,PIT,NYR,BUF
	dc.b	STL,DET,WPG,CHI, ANH,VAN,CGY,TOR, PHI,MTL,OTW,PIT, TB,BUF,NYI,BOS
	dc.b	ANH,DET,CGY,CHI, DAL,VAN,LA,TOR, NJ,BOS,QUE,PIT, PHI,MTL,NYI,BUF

	dc.b	CGY,TOR,DAL,VAN, WPG,CHI,LA,DET, OTW,PIT,HFD,BOS, FLA,MTL,WSH,BUF
	dc.b	WPG,CHI,SJ,DET, STL,VAN,CGY,TOR, NYR,BUF,PHI,BOS, QUE,MTL,HFD,PIT
	dc.b	SJ,DET,WPG,TOR, LA,VAN,CGY,CHI, PHI,MTL,QUE,BOS, NJ,PIT,NYI,BUF
	dc.b	DAL,DET,LA,CHI, SJ,TOR,STL,VAN, NYI,PIT,OTW,MTL, NYR,BUF,NJ,BOS
	dc.b	DAL,VAN,SJ,TOR, EDM,CHI,CGY,DET, QUE,BOS,NYR,BUF, OTW,MTL,PHI,PIT
	dc.b	STL,TOR,SJ,CHI, DAL,DET,EDM,VAN, NJ,MTL,NYR,PIT, OTW,BOS,HFD,BUF
	dc.b	TOR,STL,ANH,LA, WPG,CHI,SJ,VAN, WSH,NYI,NYR,MTL, PHI,BUF,TB,PIT
	dc.b	EDM,STL,DAL,LA, SJ,VAN,DET,CHI, QUE,BUF,TB,NYI, NJ,MTL,HFD,PIT

	dc.b	TOR,STL,SJ,LA, DAL,VAN,WPG,CHI, BOS,TB,OTW,BUF, NJ,MTL,QUE,PIT
	dc.b	CGY,VAN,DAL,LA, TOR,CHI,EDM,STL, HFD,NYI,NJ,BUF, OTW,MTL,BOS,PIT
	dc.b	TOR,STL,WPG,CHI, DET,VAN,EDM,LA, OTW,PIT,HFD,MTL, FLA,BUF,NYR,NYI
	dc.b	DET,VAN,DAL,LA, EDM,CHI,WPG,STL, WSH,NYI,NJ,PIT, NYR,BUF,BOS,MTL
	dc.b	EDM,STL,CGY,LA, WPG,VAN,CHI,DET, OTW,MTL,QUE,BUF, BOS,NYI,WSH,PIT
	dc.b	SJ,LA,CGY,CHI, WPG,STL,EDM,VAN, OTW,PIT,TB,MTL, QUE,NYI,NJ,BUF
	dc.b	DAL,CHI,TOR,LA, WPG,STL,SJ,VAN, OTW,MTL,PHI,BUF, NJ,FLA,QUE,PIT
	dc.b	DET,VAN,SJ,LA, TOR,STL,EDM,CHI, NJ,MTL,QUE,PIT, OTW,NYI,PHI,BUF

	dc.b	CHI,DET,EDM,STL, CGY,LA,TOR,VAN, HFD,PIT,QUE,NYI, OTW,MTL,BOS,BUF
	dc.b	DET,CHI,DAL,VAN, EDM,LA,WPG,STL, NYR,NYI,BOS,BUF, WSH,MTL,OTW,PIT
	dc.b	TOR,LA,CGY,STL, DET,VAN,SJ,CHI, HFD,BUF,OTW,NYI, NJ,PIT,BOS,MTL
	dc.b	EDM,LA,WPG,STL, CGY,CHI,DAL,VAN, QUE,NYI,TB,BUF, BOS,MTL,FLA,PIT
	dc.b	SJ,STL,ANH,VAN, CGY,CHI,DET,LA, HFD,MTL,NJ,NYI, WSH,BUF,QUE,PIT
	dc.b	TOR,CHI,WPG,VAN, DAL,LA,ANH,STL, NYR,BUF,FLA,TB, WSH,PIT,BOS,MTL
	dc.b	EDM,LA,SJ,CHI, ANH,VAN,DET,STL, NJ,MTL,OTW,BUF, TB,PIT,NYR,NYI
	dc.b	SJ,STL,DET,CHI, ANH,LA,WPG,VAN, WSH,FLA,NJ,PIT, BOS,MTL,TB,BUF
