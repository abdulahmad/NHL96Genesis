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
	dc.l	NYIslanders				;13 NYI
	dc.l	NYRangers				;14 NYR
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
	Player	'Guy Hebert',	3164,3232,0000,3233
	Player	'Mikhail Shtalenkov',	3563,2222,0000,2223
	Player	'Patrik Carnback',	2172,2322,0422,2421
	Player	'Stephan Lebeau',	4753,3433,1744,4231
	Player	'Steve Rucchin',	2092,2323,1223,3331
	Player	'Mike Sillinger',	1273,3222,2732,4531
	Player	'Joe Sacco',	1484,3223,3533,3327
	Player	'Bob Corkum',	19A3,3333,4533,3422
	Player	'Todd Krygier',	2552,4232,2832,3222
	Player	'Tim Sweeney',	0873,2333,1633,3221
	Player	'Valeri Karpov',	1144,4323,1432,2332
	Player	'Todd Ewen',	36B1,1212,3512,231A
	Player	'Paul Kariya',	0944,5423,2244,3442
	Player	'Shaun VanAllen',	2293,3322,2442,3643
	Player	'Garry Valk',	1872,2233,3633,3321
	Player	'Peter Douris',	1683,3234,2322,2321
	Player	'Oleg Tverdovsky',	1054,4423,2642,3541
	Player	'David Williams',	0482,2222,2522,2324
	Player	'Dave Karpa',	1582,2232,3B22,3329
	Player	'Bobby Dollas',	02A3,2343,3222,3321
	Player	'Robert Dirk',	05A2,1142,5621,3123
	Player	'Randy Ladouceur',	29B3,2141,3421,4118
	Player	'Tom Kurvers',	2483,3424,2631,4431
	Player	'Don McSween',	0682,1223,2622,2222
	dc.w	2						;end of the player list: an empty String
.tn									;City
	String	'Anaheim'
.ta									;Abbreviation
	String	'ANH'
.tm									;Nickname
	String	'Mighty Ducks'
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
	Player	'Blaine Lacher',	3184,4434,0020,4444
	Player	'Vincent Riendeau',	3763,3222,0050,2222
	Player	'Adam Oates',	1275,4653,3554,5661
	Player	'Bryan Smolinski',	2004,4434,2333,3234
	Player	'Jozef Stumpel',	2252,2322,1533,3431
	Player	'Cam Neely',	08A3,3645,4B45,4245
	Player	'Stephen Heinze',	2363,4333,3732,3232
	Player	'Mariusz Czerkawski',	1972,3422,1343,3331
	Player	'Marc Potvin',	2981,2112,3512,312A
	Player	'Glen Murray',	4402,3323,2333,3323
	Player	'Ted Donato',	2143,4343,2433,3331
	Player	'Stephen Leach',	2763,2334,3933,4235
	Player	'Mats Naslund',	2643,3322,1432,3542
	Player	'Dave Reid',	1793,3243,3624,4422
	Player	'Brent Hughes',	1862,2332,3433,4139
	Player	'Mikko Makela',	4274,3322,0832,3331
	Player	'Ray Bourque',	77A5,4555,4265,6451
	Player	'John Gruden',	3663,2233,3222,3232
	Player	'David Shaw',	3492,2242,3722,4225
	Player	'Jamie Huscroft',	2881,2122,3712,321A
	Player	'Don Sweeney',	3244,3343,4431,4442
	Player	'Alexei Kasatonov',	0694,3233,3232,3531
	Player	'Jon Rohloff',	38A3,2234,3322,3138
	Player	'Al Iafrate',	43B4,3446,4A32,3243
	dc.w	2
.tn
	String	'Boston'
.ta
	String	'BOS'
.tm
	String	'Bruins'
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
	Player	'Dominik Hasek',	3946,4454,0030,6666
	Player	'Robb Stauber',	3562,3443,0030,3333
	Player	'Pat LaFontaine',	1655,4644,2944,4452
	Player	'Dale Hawerchuk',	1066,4544,2643,4551
	Player	'Derek Plante',	2644,4433,2443,3541
	Player	'Dave Hannan',	1462,2232,2622,2533
	Player	'Bob Sweeney',	2093,2353,3733,4431
	Player	'Alexnder Mogilny',	8976,6634,1454,4251
	Player	'Donald Audette',	2854,4434,2534,3132
	Player	'Wayne Presley',	1863,3343,3733,3223
	Player	'Yuri Khmylev',	1374,3443,3533,4331
	Player	'Craig Simpson',	1783,4444,2B34,3531
	Player	'Brad May',	2794,2223,4632,322B
	Player	'Viktor Gordiouk',	0954,3312,1342,3431
	Player	'Rob Ray',	32A2,2121,3222,212B
	Player	'Scott Pearson',	3393,3132,3632,3423
	Player	'Jason Dawe',	4383,4323,2233,3237
	Player	'Alexei Zhitnik',	4465,4433,3642,4541
	Player	'Doug Bodger',	08A4,3342,2631,4531
	Player	'Craig Muni',	0592,2142,4621,4524
	Player	'Doug Houda',	0672,2122,3921,2224
	Player	'Garry Galley',	0373,3342,3431,3541
	Player	'Richard Smehlik',	42A3,2344,3232,3338
	Player	'Charlie Huddy',	22A3,2243,3432,3534
	dc.w	2
.tn
	String	'Buffalo'
.ta
	String	'BUF'
.tm
	String	'Sabres'
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
	Player	'Trevor Kidd',	3734,4323,0000,3444
	Player	'Rick Tabaracci',	3163,3212,0030,2232
	Player	'Joe Nieuwendyk',	2584,3544,3644,4241
	Player	'Robert Reichel',	2664,4424,2244,3342
	Player	'Joel Otto',	29B3,2253,5523,4426
	Player	'Kelly Kisio',	1162,2243,3B33,4532
	Player	'Wes Walz',	1762,3332,1333,3431
	Player	'Michael Nylander',	9254,4423,2432,3541
	Player	'Theoren Fleury',	1435,5444,4544,4344
	Player	'Nikolai Borshevsky',	1664,4423,2633,3341
	Player	'Ronnie Stern',	2282,2212,3723,232A
	Player	'Sandy McCarthy',	1571,1222,3322,3129
	Player	'Sheldon Kennedy',	2343,5222,1932,2221
	Player	'Gary Roberts',	1073,4544,4A35,534B
	Player	'German Titov',	1374,3434,2234,3231
	Player	'Paul Kruse',	1292,2222,3423,3229
	Player	'Mike Sullivan',	3263,4322,1632,3431
	Player	'Phil Housley',	0665,5533,2643,4551
	Player	'Zarley Zalapski',	33A5,4434,3442,5431
	Player	'James Patrick',	0595,3333,3732,3541
	Player	'Kevin Dahl',	0473,2242,3922,3332
	Player	'Steve Chiasson',	2193,3444,3432,4441
	Player	'Frank Musil',	0393,4142,3821,3422
	Player	'Trent Yawney',	1873,3142,3831,3533
	dc.w	2
.tn
	String	'Calgary'
.ta
	String	'CGY'
.tm
	String	'Flames'
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
	Player	'Ed Belfour',	3066,4565,0020,5565
	Player	'Jeff Hackett',	3152,3112,0010,2233
	Player	'Jeremy Roenick',	2745,5545,4544,5356
	Player	'Bernie Nicholls',	9263,3543,2744,4452
	Player	'Brent Sutter',	1263,2353,4733,5435
	Player	'Jeff Shantz',	1172,3332,3732,3532
	Player	'Denis Savard',	1855,3423,1543,3641
	Player	'Tony Amonte',	1064,5434,1233,4531
	Player	'Joe Murphy',	1774,5434,3234,4342
	Player	'Dirk Graham',	3384,3353,4732,4232
	Player	'Jim Cummins',	1591,1121,2511,211A
	Player	'Bob Probert',	24B3,3223,4622,212C
	Player	'Patrick Poulin',	44A3,4324,3233,4239
	Player	'Murray Craven',	3263,3343,3634,3432
	Player	'Sergei Krivokrasv',	2544,4414,1443,2231
	Player	'Brent Grieve',	1993,4223,3433,3322
	Player	'Eric Daze',	55A2,3322,2232,2322
	Player	'Chris Chelios',	0774,4465,4742,554A
	Player	'Eric Weinrich',	02A3,4333,3632,4331
	Player	'Gerald Diduck',	0694,4132,4521,3433
	Player	'Steve Smith',	05B4,4353,4622,5245
	Player	'Gary Suter',	2075,4444,4642,5541
	Player	'Cam Russell',	0853,3132,5821,322A
	Player	'Keith Carney',	0492,3212,3422,1221
	dc.w	2
.tn
	String	'Chicago'
.ta
	String	'CHI'
.tm
	String	'Blackhawks'
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
	Player	'Mike Vernon',	2944,4444,0030,4454
	Player	'Chris Osgood',	3034,3343,0010,3344
	Player	'Sergei Fedorov',	9176,6554,2265,5451
	Player	'Steve Yzerman',	1965,5544,1753,5551
	Player	'Keith Primeau',	55B2,4433,3235,3335
	Player	'Greg Johnson',	2363,3322,2232,3321
	Player	'Kris Draper',	3373,4242,2232,4431
	Player	'Dino Ciccarelli',	2255,3525,2534,4349
	Player	'Ray Sheppard',	2662,2514,1535,3131
	Player	'Doug Brown',	1763,3242,3734,4332
	Player	'Martin Lapointe',	2092,1322,2522,2322
	Player	'Darren McCarty',	25A2,2233,4522,432B
	Player	'Vachslav Kozlov',	1354,3423,1244,3231
	Player	'Bob Errey',	2165,4242,4632,4222
	Player	'Shawn Burr',	1162,2242,3233,3423
	Player	'Mike Krushelski',	1893,3342,3833,3322
	Player	'Stu Grimson',	32B1,1021,2211,211B
	Player	'Bob Rouse',	03A3,3142,4B21,4224
	Player	'Vladimir Konstantov',	1664,4243,4331,4433
	Player	'Mark Howe',	0463,2333,2A31,2632
	Player	'Paul Coffey',	7796,5534,2652,5562
	Player	'Nicklas Lidstrom',	0554,3444,2232,4541
	Player	'Terry Carkner',	02A1,2132,3621,3529
	Player	'Vachslav Fetisov',	44A3,3333,2432,3431
	dc.w	2
.tn
	String	'Detroit'
.ta
	String	'DET'
.tm
	String	'Red Wings'
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
	Player	'Bill Ranford',	3045,4435,0020,4455
	Player	'Fred Brathwaite',	3152,2222,0010,1222
	Player	'Jason Arnott',	0784,4434,3534,4348
	Player	'Doug Weight',	3963,3433,2242,3541
	Player	'Todd Marchant',	2674,5323,1434,3331
	Player	'Micah Aivazoff',	1272,2222,2223,3321
	Player	'Dean McAmmond',	3773,5233,2222,3421
	Player	'Kelly Buchberger',	16A3,3242,4222,3326
	Player	'David Oliver',	2064,4433,1333,3534
	Player	'Kirk Maltby',	1873,2232,3522,4325
	Player	'Shayne Corson',	0993,3444,4633,4336
	Player	'Mike Stapleton',	2563,4222,2522,3231
	Player	'Scott Thornton',	1793,3242,3622,3429
	Player	'Louie DeBrusk',	29C1,1212,3622,1119
	Player	'Igor Kravchuk',	2195,3334,3632,4331
	Player	'Jiri Slegr',	2894,4332,2231,4433
	Player	'Fredrik Olausson',	1594,4434,1732,3541
	Player	'Gord Mark',	06A1,2022,2711,2323
	Player	'Dean Kennedy',	3292,2032,5510,4226
	Player	'Ryan McGill',	3492,2132,3521,3325
	Player	'Bryan Marchment',	2483,3242,4821,3426
	Player	'Boris Mironov',	0274,3312,1532,3534
	Player	'Luke Richardson',	22B3,3132,4620,332A
	Player	'Ken Sutton',	4083,2242,1822,3233
	dc.w	2
.tn
	String	'Edmonton'
.ta
	String	'EDM'
.tm
	String	'Oilers'
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
	Player	'John Vanbiesbrk',	3454,3454,0010,4455
	Player	'Mark Fitzpatrik',	3073,3223,0010,4434
	Player	'Stu Barnes',	1453,3433,2333,3431
	Player	'Brian Skrudland',	2084,3252,4633,4435
	Player	'Jesse Belanger',	2653,4433,2744,3241
	Player	'Rob Niedrmayer',	4494,5223,2633,3222
	Player	'Scott Mellanby',	2793,2324,4923,3226
	Player	'Jody Hull',	1292,2333,2733,3321
	Player	'Tom Fitzgerald',	2184,4233,3532,4438
	Player	'Bob Kudelski',	2292,3424,1734,3231
	Player	'Dave Lowry',	1082,3333,3623,3232
	Player	'Mike Hough',	1872,2343,3422,3336
	Player	'Johan Garpenlov',	2963,3322,2232,3431
	Player	'Bill Lindsay',	1162,2233,2423,2228
	Player	'Andrei Lomakin',	1974,3323,1632,3431
	Player	'Gaetan Duchesne',	1593,4242,3023,4222
	Player	'Gord Murphy',	0585,4324,2333,3447
	Player	'Joe Cirella',	02A2,2133,3322,3324
	Player	'Randy Moller',	1682,2133,3921,3226
	Player	'Keith Brown',	0472,2132,3721,3233
	Player	'Geoff Smith',	2594,3132,3432,3425
	Player	'Brian Benning',	0783,3323,2642,4541
	Player	'Paul Laus',	0392,2132,5521,342A
	Player	'Magnus Svensson',	2853,3322,2432,3531
	dc.w	2
.tn
	String	'Florida'
.ta
	String	'FLA'
.tm
	String	'Panthers'
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
	Player	'Sean Burke',	01A4,3423,0040,4455
	Player	'Jeff Reese',	3542,3322,0010,2222
	Player	'Andrew Cassels',	2173,3442,2643,4641
	Player	'Andrei Nikolishin',	1153,3332,2432,5432
	Player	'Darren Turcotte',	8964,5435,1833,4231
	Player	'Mark Janssens',	22B2,2243,4623,4326
	Player	'Ted Drury',	1374,4232,3642,3537
	Player	'Steven Rice',	12B2,2222,3723,2234
	Player	'Jocelyn Lemieux',	2694,3244,5432,4316
	Player	'Kelly Chase',	2781,1111,2911,321B
	Player	'Jim Sandlak',	52B1,2233,2B22,3322
	Player	'Robert Kron',	1853,4343,2633,3231
	Player	'Geoff Sanderson',	0864,5434,2234,4232
	Player	'Jimmy Carson',	3394,4213,1534,4331
	Player	'Paul Ranheim',	2884,5323,1532,3131
	Player	'Chris Pronger',	4473,3433,3233,3338
	Player	'Adam Burt',	0673,3234,4822,4338
	Player	'Frantsek Kucera',	0494,3343,2732,3333
	Player	'Glen Wesley',	2085,4443,3442,4431
	Player	'Brian Glynn',	07A4,3233,1431,2332
	Player	'Brad McCrimmon',	1082,2142,3230,3432
	Player	'Alexnder Godynyuk',	05A2,3232,3622,3511
	Player	'Glen Feathrston',	06B2,2132,4421,242B
	Player	'Marek Malik',	2362,2233,3621,3322
	dc.w	2
.tn
	String	'Hartford'
.ta
	String	'HFD'
.tm
	String	'Whalers'
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
	Player	'Kelly Hrudey',	3264,2344,0020,3333
	Player	'Grant Fuhr',	3174,2353,0130,2244
	Player	'Wayne Gretzky',	9946,4643,1464,5561
	Player	'Robert Lang',	1363,3322,1533,3541
	Player	'Pat Conacher',	1572,2232,2A23,2331
	Player	'Kevin Todd',	1252,3333,2622,3332
	Player	'Rick Tocchet',	9293,3434,4734,333B
	Player	'Tony Granato',	2164,5443,3934,3334
	Player	'John Druce',	1992,2343,3734,3121
	Player	'Kevin Brown',	0892,2222,3521,3225
	Player	'Troy Crowder',	55A1,1112,2911,222A
	Player	'Jari Kurri',	1784,3434,2743,4441
	Player	'Dan Quinn',	0753,3423,1634,3131
	Player	'Randy Burridge',	4473,2333,3833,3331
	Player	'Eric Lacroix',	2883,3333,3433,3223
	Player	'Rob Blake',	04A4,4444,4732,4343
	Player	'Michel Petit',	2483,3333,3732,2434
	Player	'Sean ODonnell',	06B2,2223,3421,2329
	Player	'Philippe Boucher',	2673,3313,2732,3441
	Player	'Marty McSorley',	33C2,2233,4522,523B
	Player	'Darryl Sydor',	2594,3323,3432,3431
	Player	'Chris Snell',	2983,3312,2432,2531
	Player	'Denis Tsygurov',	0373,3322,2632,2431
	Player	'Rob Cowie',	7773,3322,2432,2432
	dc.w	2
.tn
	String	'Los Angeles'
.ta
	String	'LA'
.tm
	String	'Kings'
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
	Player	'Darcy Wakaluk',	3463,3233,0010,3333
	Player	'Andy Moog',	3543,3323,0030,3333
	Player	'Mike Modano',	0975,5645,2444,5341
	Player	'Corey Millen',	0643,5422,1933,3431
	Player	'Dean Evason',	1662,2243,3723,3334
	Player	'Todd Harvey',	1063,4323,4523,2235
	Player	'Peter Zezel',	2593,3243,4623,4335
	Player	'Trent Klatt',	2293,3324,2523,3223
	Player	'Greg Adams',	2374,4433,2633,4231
	Player	'Paul Broten',	2172,2241,3722,3323
	Player	'Shane Churla',	2792,2221,4922,222A
	Player	'Mike Kennedy',	3942,2332,3523,3222
	Player	'Dave Gagner',	1564,4433,2434,4242
	Player	'Mike Donnelly',	1164,4332,3633,4331
	Player	'Mike McPhee',	1794,3343,4632,3222
	Player	'Brent Gilchrist',	4164,3333,3823,2231
	Player	'Kevin Hatcher',	04B3,3444,5532,4246
	Player	'Paul Cavallini',	14A3,3243,3432,3138
	Player	'Grant Ledyard',	1294,3332,3632,2431
	Player	'Gord Donnelly',	4381,2112,3511,221A
	Player	'Craig Ludwig',	03C2,2142,4220,3325
	Player	'Derian Hatcher',	0293,2234,4631,4329
	Player	'Doug Zmolek',	0584,3232,3231,3348
	Player	'Mike Lalor',	1872,2132,3821,3122
	dc.w	2
.tn
	String	'Dallas'
.ta
	String	'DAL'
.tm
	String	'Stars'
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
	Player	'Patrick Roy',	3366,4455,0000,6566
	Player	'Ron Tugnutt',	0122,3232,0010,2222
	Player	'Pierre Turgeon',	7795,4524,0444,4541
	Player	'Brian Savage',	4963,4323,2433,3121
	Player	'Mark Lamb',	1754,3242,2432,3321
	Player	'Mark Recchi',	0865,4534,2245,4342
	Player	'Mike Keane',	1253,4342,4533,4234
	Player	'Valeri Bure',	1834,4323,0532,2331
	Player	'Oleg Petrov',	0643,2232,1232,3331
	Player	'Turner Stevenson',	3081,2224,3522,3229
	Player	'Ed Ronan',	3182,2212,3322,1421
	Player	'Vincent Damphousse',	2564,4524,1054,3451
	Player	'Brian Bellows',	2384,4424,2734,4231
	Player	'Benoit Brunet',	2264,3322,2632,2421
	Player	'Pierre Sevigny',	2072,3222,2622,3422
	Player	'Mario Roberge',	3261,1112,3622,1318
	Player	'Donald Brashear',	3591,1122,3422,2129
	Player	'Gerry Fleming',	36D1,2122,2412,3028
	Player	'Vladimir Malakhov',	38A4,3434,2432,3331
	Player	'Patrice Brisebois',	4354,3433,2933,3433
	Player	'Peter Popovic',	34A2,2223,2731,2331
	Player	'Lyle Odelein',	2493,2233,4322,322A
	Player	'Yves Racine',	2964,4334,3632,4432
	Player	'J.J. Daigneault',	4864,3332,1632,3431
	dc.w	2
.tn
	String	'Montreal'
.ta
	String	'MTL'
.tm
	String	'Canadiens'
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
	Player	'Martin Brodeur',	3075,3344,0020,5556
	Player	'Chris Terreri',	3124,4443,0030,4443
	Player	'Neal Broten',	0943,3353,2642,4442
	Player	'Brian Rolston',	1464,4323,2643,3431
	Player	'Bob Carpenter',	1973,2242,2831,3433
	Player	'Jim Dowd',	1173,4322,1B32,3431
	Player	'Bobby Holik',	16A2,3235,3322,3222
	Player	'Sergei Brylin',	1853,3333,2432,3431
	Player	'Stephane Richer',	4494,5435,2735,4231
	Player	'Claude Lemieux',	22B3,4344,4532,4339
	Player	'Bill Guerin',	1293,5335,3324,3229
	Player	'John MacLean',	1593,3544,3333,4223
	Player	'Danton Cole',	2073,3333,3522,4234
	Player	'Randy McKay',	2163,3233,4723,322B
	Player	'Valeri Zelepukin',	2564,4433,1644,3431
	Player	'Tom Chorske',	1794,5232,3532,4323
	Player	'Mike Peluso',	08A2,2323,2212,1128
	Player	'Scott Niedrmayer',	2794,4433,2442,3542
	Player	'Ken Daneyko',	03A3,2151,5221,4126
	Player	'Chris McAlpine',	0763,3222,2522,3324
	Player	'Scott Stevens',	04B4,4354,5233,544A
	Player	'Bruce Driver',	2364,3342,3432,4332
	Player	'Tommy Albelin',	0673,2232,2231,3331
	Player	'Jaroslav Modry',	0583,3122,2421,3321
	Player	'Shawn Chambers',	2992,2332,2632,3331
	dc.w	2
.tn
	String	'New Jersey'
.ta
	String	'NJ'
.tm
	String	'Devils'
.ar
	String	'Byrne Meadowlands Arena'
.pos
	dc.b	$00,$44,$44,$44,$55,$55,$55,$33,$32,$22,$11,$11,$1F,$FF

NYIslanders							;NYI
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
	Player	'Tommy Soderstrom',	3033,3342,0020,3232
	Player	'Jamie McLennan',	2973,3222,0000,2222
	Player	'Steve Thomas',	3264,4435,4434,423A
	Player	'Ray Ferraro',	2063,4434,2634,4233
	Player	'Marty McInnis',	1843,5342,2533,3321
	Player	'Kip Miller',	1062,3322,1432,2431
	Player	'Ron Sutter',	1463,3242,4732,4344
	Player	'Patrick Flatley',	2683,2442,4B32,4545
	Player	'Zigmund Palffy',	6844,3322,1432,3431
	Player	'Brett Lindros',	7593,2223,4522,2228
	Player	'Mick Vukota',	1282,1011,3511,211A
	Player	'Brad Dalgarno',	15B2,2231,3923,2422
	Player	'Kirk Muller',	0994,4444,3233,4543
	Player	'Travis Green',	3982,3323,3532,3532
	Player	'Derek King',	2793,2414,0234,3221
	Player	'Dave Chyzowski',	0962,2223,2422,3221
	Player	'Bob Beers',	0283,2423,2732,3541
	Player	'Richard Pilon',	4794,2123,3622,2123
	Player	'Chris Luongo',	0652,2122,3521,3222
	Player	'Mathieu Schneider',	7274,4444,3432,4344
	Player	'Scott Lachance',	0783,3343,3632,4541
	Player	'Dennis Vaske',	37A2,2222,3422,2422
	Player	'Darius Kasparitis',	1174,3233,5632,2338
	Player	'Brent Severyn',	24A2,2133,3622,3223
	dc.w	2
.tn
	String	'New York'
.ta
	String	'NYI'
.tm
	String	'Islanders'
.ar
	String	'Nassau Coliseum'
.pos
	dc.b	$00,$44,$44,$45,$55,$55,$33,$33,$22,$21,$11,$11,$FF,$FF

NYRangers							;NYR
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
	Player	'Mike Richter',	3576,3343,0000,5666
	Player	'Glenn Healy',	3053,3533,0000,3332
	Player	'Mark Messier',	1195,4543,4453,5455
	Player	'Alexei Kovalev',	2776,5435,2264,4351
	Player	'Petr Nedved',	1054,5424,1433,4441
	Player	'Nathan Lafayette',	2274,4333,2532,3431
	Player	'Pat Verbeek',	1773,4434,3134,4244
	Player	'Steve Larmer',	2874,4464,4034,5342
	Player	'Brian Noonan',	1673,3444,3534,4433
	Player	'Joey Kocur',	2682,2132,3721,232C
	Player	'Adam Graves',	0994,4433,5033,4236
	Player	'Stephane Matteau',	3283,3242,4232,3334
	Player	'Sergei Nemchinov',	1364,3353,3434,6431
	Player	'Darren Langdon',	1582,2133,4211,333A
	Player	'Nick Kypreos',	1982,2222,3423,3218
	Player	'Mark Osborne',	2092,2242,3622,4322
	Player	'Jeff Beukeboom',	23B2,2243,5321,423A
	Player	'Sergei Zubov',	2175,4544,3552,3551
	Player	'Alex Karpotsev',	2563,3332,3532,3332
	Player	'Joby Messier',	2982,2232,3322,3324
	Player	'Brian Leetch',	0266,3543,2252,5451
	Player	'Kevin Lowe',	0483,2242,3431,3434
	Player	'Jay Wells',	24A2,2132,4421,2426
	Player	'Mattius Norstrom',	0583,2132,4222,4334
	dc.w	2
.tn
	String	'New York'
.ta
	String	'NYR'
.tm
	String	'Rangers'
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
	Player	'Don Beaupre',	3143,3333,0030,3333
	Player	'Darrin Madeley',	3042,2112,0020,2121
	Player	'Alexei Yashin',	1995,4524,2354,3351
	Player	'Alexnder Daigle',	9154,4314,2043,3441
	Player	'Radek Bonk',	7692,2314,2443,3231
	Player	'Steve Larouche',	0753,3303,1733,2331
	Player	'Dave McLlwain',	1773,2222,3623,3231
	Player	'Scott Levins',	2692,2212,2522,3323
	Player	'Rob Gaudreau',	1063,4322,3733,4231
	Player	'Martin Straka',	8253,4423,1443,3441
	Player	'David Archibald',	1573,2323,1833,3221
	Player	'Pat Elynuik',	2562,3313,1733,3323
	Player	'Pavol Demitra',	7863,3233,1432,3231
	Player	'Sylvain Turgeon',	6194,4324,0C32,3121
	Player	'Randy Cunnyworth',	0752,3232,3822,3439
	Player	'Phil Bourque',	2983,4232,3622,5329
	Player	'Troy Mallette',	1872,2123,2422,2216
	Player	'Sean Hill',	0383,3232,3522,3432
	Player	'Chris Dahlquist',	0683,2142,3421,3321
	Player	'Dennis Vial',	2192,1122,4811,341A
	Player	'Jim Paek',	0282,3122,2621,3422
	Player	'Kerry Huffman',	0593,3223,3821,3323
	Player	'Stan Neckar',	9474,3222,2432,3437
	Player	'Daniel Laperriere',	2471,3223,2621,3321
	dc.w	2
.tn
	String	'Ottawa'
.ta
	String	'OTW'
.tm
	String	'Senators'
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
	Player	'Ron Hextall',	2773,3443,0040,3322
	Player	'Dominic Roussel',	3363,3333,0010,3232
	Player	'Eric Lindros',	88C4,4656,6756,526A
	Player	'Rod BrindAmour',	1794,4444,3234,6542
	Player	'Craig MacTavish',	1483,3352,4432,5333
	Player	'Rob DiMaio',	0973,3232,3932,3423
	Player	'Jim Montgomery',	2253,3212,1533,2331
	Player	'Shjon Podein',	2582,3322,2432,2431
	Player	'Anatoli Semenov',	4473,4333,2632,4231
	Player	'John Leclair',	10B3,4435,4435,3233
	Player	'Kevin Dineen',	1174,4343,2733,4132
	Player	'Brent Fedyk',	1883,3333,2923,3223
	Player	'Dave Brown',	2191,1131,2511,211C
	Player	'Mikael Renberg',	1974,3534,4245,5442
	Player	'Gilbert Dionne',	4583,2422,2432,3431
	Player	'Patrick Juhlin',	1273,3313,2432,3231
	Player	'Shawn Antoski',	08C1,2112,4611,221A
	Player	'Dimitri Yushkevich',	0275,4343,3332,4432
	Player	'Eric Desjardins',	3794,3354,4733,4331
	Player	'Rob Zettler',	2073,2122,2421,3237
	Player	'Petr Svoboda',	2354,4243,3821,4534
	Player	'Kevin Haller',	0553,2243,3422,3222
	Player	'Chris Therien',	06B3,3332,2422,2431
	Player	'Karl Dykhuis',	2493,2222,2432,2434
	dc.w	2
.tn
	String	'Philadelphia'
.ta
	String	'PHI'
.tm
	String	'Flyers'
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
	Player	'Tom Barrasso',	35A4,4554,0140,4444
	Player	'Ken Wregget',	3183,3333,0020,3333
	Player	'Ron Francis',	1094,3553,4243,5551
	Player	'John Cullen',	1174,3433,2734,4549
	Player	'Troy Murray',	1283,3242,4732,3333
	Player	'Len Barrie',	0983,3322,1232,2532
	Player	'Mike Hudson',	1683,4242,3422,4334
	Player	'Mario Lemieux',	66A5,4635,2966,3461
	Player	'Jaromir Jagr',	68A5,4644,4465,6551
	Player	'Tomas Sandstrom',	1794,4535,2633,4133
	Player	'Joe Mullen',	0764,3443,2535,4331
	Player	'Luc Robitaille',	2074,4535,2236,5241
	Player	'Kevin Stevens',	25B3,3525,3435,424A
	Player	'Shawn McEachern',	1573,4434,1234,4231
	Player	'Markus Naslund',	2964,3222,2432,2421
	Player	'Larry Murphy',	55A4,3554,3333,5551
	Player	'Kjell Samuelsson',	28E2,2144,4531,4233
	Player	'Chris Joseph',	23A3,3323,3332,344B
	Player	'Drake Berehowsky',	06A2,2132,3722,3221
	Player	'Ulf Samuelsson',	0584,4243,5430,4534
	Player	'Greg Hawgood',	0473,3323,2632,3541
	Player	'Norm Maciver',	2263,3423,2632,4531
	Player	'Francois Leroux',	18B3,2132,4421,3229
	Player	'Peter Taglianeti',	3291,2133,4820,3324
	dc.w	2
.tn
	String	'Pittsburgh'
.ta
	String	'PIT'
.tm
	String	'Penguins'
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
	Player	'Jocelyn Thibault',	4155,3324,0020,5555
	Player	'Stephane Fiset',	3554,3333,0010,4343
	Player	'Joe Sakic',	1964,3644,2455,5461
	Player	'Peter Forsberg',	2164,4433,2243,3561
	Player	'Mike Ricci',	0974,3443,4434,3346
	Player	'Bob Bassen',	2844,3232,3423,3323
	Player	'Claude Lapointe',	4753,4342,4832,3423
	Player	'Andrei Kovalenko',	5133,4433,3644,4331
	Player	'Owen Nolan',	1183,4425,4735,423A
	Player	'Scott Young',	4873,5445,1534,3432
	Player	'Dwayne Norris',	1443,3422,1532,2331
	Player	'Wendel Clark',	1783,3436,4A34,424B
	Player	'Valeri Kamensky',	1384,4425,2744,4451
	Player	'Adam Deadmarsh',	1873,3433,3534,3443
	Player	'Chris Simon',	12D2,1222,3811,212A
	Player	'Martin Rucinsky',	2553,3323,1842,3531
	Player	'Uwe Krupp',	04C3,2334,3732,4132
	Player	'Sylvain Lefebvre',	0293,3232,3221,4531
	Player	'Adam Foote',	5284,3332,3931,3434
	Player	'Curtis Leschyshyn',	0793,4342,3633,5431
	Player	'Craig Wolanin',	0682,3332,2832,3431
	Player	'Steven Finn',	2982,2143,3422,3438
	Player	'Alexei Gusarov',	0563,3333,2432,3431
	Player	'Janne Laukkanen',	2253,3312,1432,2431
	dc.w	2
.tn
	String	'Quebec'
.ta
	String	'QUE'
.tm
	String	'Nordiques'
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
	Player	'Arturs Irbe',	3254,3443,0020,3434
	Player	'Wade Flaherty',	3143,3323,0010,3233
	Player	'Jeff Friesen',	3963,4423,2444,3241
	Player	'Craig Janney',	1574,3543,1453,4661
	Player	'Igor Larionov',	0744,3433,1633,3241
	Player	'Jamie Baker',	1373,3333,3433,3331
	Player	'Ulf Dahlen',	2284,3434,3434,5341
	Player	'Pat Falloon',	1774,4323,1733,4231
	Player	'Kevin Miller',	0874,4343,2533,4331
	Player	'Sergei Makarov',	2465,4433,1243,3452
	Player	'Shean Donovan',	4263,4222,3522,2332
	Player	'Ray Whitney',	1442,3323,1534,3431
	Player	'Viktor Kozlov',	47B2,3313,2742,3341
	Player	'Andrei Nazarov',	23B3,2132,3532,3337
	Player	'Jeff Odgers',	3691,2222,3512,412A
	Player	'Mike Rathje',	4083,2232,3432,3332
	Player	'Tom Pederson',	4144,4323,2532,2433
	Player	'Jay More',	0473,2133,4922,322A
	Player	'Sandis Ozolinsh',	0674,4434,2234,4342
	Player	'Jim Kyte',	0291,2132,3A22,3229
	Player	'Michal Sykora',	38B3,3234,2422,3121
	Player	'Ilya Byakin',	0373,2322,0432,2541
	Player	'Vlastmil Kroupa',	2663,3322,1432,3331
	Player	'Shawn Cronin',	44A1,1111,2411,211A
	dc.w	2
.tn
	String	'San Jose'
.ta
	String	'SJ'
.tm
	String	'Sharks'
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
	Player	'Curtis Joseph',	3165,3464,0010,4445
	Player	'Jon Casey',	3023,3343,0010,3233
	Player	'Todd Elik',	1473,4333,2623,3231
	Player	'Adam Creighton',	20A3,2323,2633,3233
	Player	'Guy Carbonneau',	2164,2242,4731,4331
	Player	'Ian Laperriere',	2264,3323,2544,3443
	Player	'Peter Stastny',	2693,2323,2433,2441
	Player	'Philippe Bozon',	3662,2232,1431,2521
	Player	'Brett Hull',	1694,4526,2335,4241
	Player	'Glenn Anderson',	0974,4433,2433,4333
	Player	'Vitali Karamnov',	1272,2222,2632,3321
	Player	'Denis Chasse',	2763,3233,3523,3229
	Player	'Esa Tikkanen',	1094,4455,4432,3349
	Player	'Brendan Shanahan',	19A3,3545,4535,4246
	Player	'Greg Gilbert',	0762,2343,3424,4332
	Player	'Tony Twist',	18A1,1111,3410,211A
	Player	'Vitali Prokhorov',	2573,3312,1633,2331
	Player	'Al MacInnis',	0284,4446,3732,5242
	Player	'Steve Duchesne',	2884,4544,1432,4441
	Player	'Doug Lidster',	0693,2232,3532,5332
	Player	'Rick Zombo',	0483,3133,3520,3123
	Player	'Murray Baron',	34A3,3132,3621,222A
	Player	'Jeff Norton',	0565,4432,1632,4541
	Player	'Bill Houlder',	33B2,2323,2233,3331
	dc.w	2
.tn
	String	'St. Louis'
.ta
	String	'STL'
.tm
	String	'Blues'
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
	Player	'Daren Puppa',	9394,3454,0100,4444
	Player	'J.C. Bergeron',	3072,2221,0010,2121
	Player	'Brian Bradley',	1944,4434,2533,4342
	Player	'Chris Gratton',	7792,3334,4032,3449
	Player	'Alexnder Semak',	2763,2323,1543,3431
	Player	'Jason Wiemer',	0994,4222,2432,3431
	Player	'Marc Bureau',	2872,2232,2722,3331
	Player	'Petr Klima',	8575,5414,1544,4231
	Player	'John Tucker',	1492,3334,3534,4131
	Player	'Alexnder Selivanov',	2963,4423,2433,3231
	Player	'Paul Ysebaert',	1574,4343,2433,3441
	Player	'Mikael Andersson',	3462,4232,2432,4231
	Player	'Rob Zamuner',	0792,2322,2432,4438
	Player	'Ben Hankinson',	1692,2223,2521,3232
	Player	'Marc Bergevin',	2563,3232,4422,3323
	Player	'Eric Charron',	0382,2222,3421,3422
	Player	'Rudy Poeschek',	20A2,2232,3521,432A
	Player	'Adrien Plavsic',	0682,2232,2632,2431
	Player	'Roman Hamrlik',	4473,2333,4433,3235
	Player	'Cory Cross',	0492,2123,2421,3332
	Player	'Bob Halkidis',	2182,1122,3621,3229
	Player	'Chris LiPuma',	2651,2122,3411,3129
	Player	'Enrico Ciccone',	3992,1223,3412,322A
	dc.w	2
.tn
	String	'Tampa Bay'
.ta
	String	'TB'
.tm
	String	'Lightning'
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
	Player	'Felix Potvin',	2965,3364,0000,5555
	Player	'Damian Rhodes',	0153,3223,0000,4343
	Player	'Doug Gilmour',	9345,4554,3243,6542
	Player	'Mike Ridley',	0794,4433,2234,4541
	Player	'Benoit Hogue',	2874,5433,1444,4541
	Player	'Paul DiPietro',	2563,3333,2732,3321
	Player	'Terry Yake',	2663,4423,2533,3431
	Player	'Mats Sundin',	1374,5544,1555,4551
	Player	'Mike Gartner',	1175,5425,2533,5141
	Player	'Mike Craig',	0964,3314,4732,3222
	Player	'Tie Domi',	0892,3323,4332,322B
	Player	'Rich Sutter',	2063,3232,2322,4322
	Player	'Dave Andreychuk',	14B3,2534,3535,5231
	Player	'Randy Wood',	2482,4343,3233,4332
	Player	'Bill Berg',	1073,2232,4423,4223
	Player	'Kent Mandrville',	1883,3232,2422,3322
	Player	'Warren Rychel',	2173,2222,3422,212A
	Player	'Ken Baumgartnr',	2292,2022,3821,232A
	Player	'Dmitri Mironov',	1573,3433,1532,3442
	Player	'Kenny Jonsson',	1974,4334,3432,4432
	Player	'Garth Butcher',	0292,3142,5521,4236
	Player	'Todd Gill',	2363,3332,3832,4533
	Player	'Dave Ellett',	0495,4434,3432,4442
	Player	'Jamie Macoun',	3483,3244,4421,4248
	dc.w	2
.tn
	String	'Toronto'
.ta
	String	'TOR'
.tm
	String	'Maple Leafs'
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
	Player	'Kirk McLean',	0165,4444,0000,4444
	Player	'Kay Whitmore',	3553,3453,0000,3232
	Player	'Trevor Linden',	1693,3444,4144,4346
	Player	'Cliff Ronning',	0755,5432,2432,4542
	Player	'Christan Ruuttu',	2084,4343,3433,4441
	Player	'John McIntyre',	1572,2132,3621,4323
	Player	'Russ Courtnall',	0965,6434,2533,4341
	Player	'Pavel Bure',	1056,6535,1255,4251
	Player	'Mike Peca',	3353,3323,2733,3231
	Player	'Tim Hunter',	1992,2222,3712,222A
	Player	'Jose Carbonneau',	2072,2222,2522,3323
	Player	'Roman Oksiuta',	2883,3303,1633,2234
	Player	'Geoff Courtnall',	1475,5444,1433,3244
	Player	'Martin Gelinas',	2383,3333,2634,3235
	Player	'Sergio Momesso',	27A4,3334,4433,3338
	Player	'Gino Odjick',	29A3,2233,4622,332B
	Player	'Josef Beranek',	4263,3424,1434,3233
	Player	'Jeff Brown',	2294,4445,2933,4341
	Player	'Yevgeny Namestnikv',	0263,2212,2532,2432
	Player	'Dana Murzyn',	0592,2244,3821,4229
	Player	'Bret Hedican',	0385,5222,2422,3331
	Player	'Jyrki Lumme',	2175,4442,1231,4541
	Player	'Dave Babych',	44A2,2343,3621,4432
	Player	'Jassen Cullimore',	34B3,2232,3422,3222
	dc.w	2
.tn
	String	'Vancouver'
.ta
	String	'VAN'
.tm
	String	'Canucks'
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
	Player	'Jim Carey',	3065,4344,0000,5565
	Player	'Olaf Kolzig',	3782,2222,0010,2121
	Player	'Joe Juneau',	9054,5533,1553,4651
	Player	'Michal Pivonka',	2083,4443,2633,3552
	Player	'Dale Hunter',	3282,2453,4434,444A
	Player	'Dave Poulin',	0973,2242,3823,3434
	Player	'Pat Peake',	1484,3323,0932,3431
	Player	'Kevin Kaminski',	2342,2122,3411,3129
	Player	'Mike Eagles',	3673,3142,4422,4324
	Player	'Jason Allison',	4183,3313,2332,3331
	Player	'Peter Bondra',	1264,6434,1445,4241
	Player	'Keith Jones',	2672,3333,4433,3135
	Player	'Rob Pearson',	2562,2233,4522,4328
	Player	'Dimitri Khristich',	0873,3444,3534,3342
	Player	'Kelly Miller',	1084,4343,2233,4542
	Player	'Steve Konowlchuk',	2263,3333,3433,3333
	Player	'Craig Berube',	2792,2212,3612,211B
	Player	'Sylvain Cote',	0364,3343,3332,4533
	Player	'Jim Johnson',	0473,2243,3622,4335
	Player	'John Slaney',	2873,3223,2422,2221
	Player	'Mark Tinordi',	2493,3344,5432,4426
	Player	'Calle Johansson',	0694,4443,2432,4441
	Player	'Joe Reekie',	29A3,2242,3422,3325
	Player	'Igor Ulanov',	0592,2132,4421,4523
	dc.w	2
.tn
	String	'Washington'
.ta
	String	'WSH'
.tm
	String	'Capitals'
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
	Player	'Tim Cheveldae',	2963,4443,0020,2222
	Player	'Nikolai Khabibulin',	3553,3223,0000,2232
	Player	'Alexei Zhamnov',	1075,4544,2455,4451
	Player	'Thomas Steen',	2583,3433,2633,3551
	Player	'Ed Olczyk',	1693,2333,2833,3432
	Player	'Randy Gilhen',	1572,2142,3621,4423
	Player	'Igor Korolev',	2372,2332,1233,3531
	Player	'Mike Eastwood',	3273,4322,2333,3432
	Player	'Teemu Selanne',	0865,6524,2554,5241
	Player	'Nelson Emerson',	1944,4434,2344,4442
	Player	'Kris King',	17A3,3242,4422,433A
	Player	'Russ Romaniuk',	2163,2122,2632,2321
	Player	'Keith Tkachuk',	0793,3444,5034,4249
	Player	'Dallas Drake',	1844,4333,2433,4432
	Player	'Darrin Shannon',	3493,2333,3423,4334
	Player	'Michal Grosek',	7552,2223,3532,4322
	Player	'Teppo Numminen',	2775,3343,2732,4541
	Player	'Stephane Quintal',	04B2,2232,4522,4336
	Player	'Neil Wilkinson',	0273,3122,3521,4635
	Player	'Arto Blomsten',	5593,2212,2432,2531
	Player	'Brent Thompson',	2282,2111,2411,2219
	Player	'Dave Manson',	0393,4325,4421,433B
	Player	'Darryl Shannon',	2492,2132,3421,3223
	Player	'Oleg Mikulchik',	4282,2313,2332,2434
	dc.w	2
.tn
	String	'Winnipeg'
.ta
	String	'WPG'
.tm
	String	'Jets'
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
