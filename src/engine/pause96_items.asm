;	The pause, pregame, intermission and game-over menus.

ShootoutPauseMenu					;Menu item lists (InitMenuState): String control entries ($F9 / $FE), then
									;each item as its String and the routine it runs, ended by String $FF. The
									;pause menu in a shootout
	String	CC_SetFont,$01
	String	CC_SetFont,$02
	String	'   RESUME GAME    '
	dc.l	PlayGame
	String	'  INSTANT REPLAY  '
	dc.l	ReplayMode
	String	'   TEAM ROSTER    '
	dc.l	TeamRosterScreen
	String	'  RECORD HOLDERS  '
	dc.l	RecordHoldersScreen
	String	'    ABORT GAME    '
	dc.l	AbortGame
	String	CC_ListEnd

PauseMenu							;The pause menu
	String	CC_SetFont,$01
	String	CC_SetFont,$02
	String	'   RESUME GAME    '
	dc.l	PlayGame
	String	'  INSTANT REPLAY  '
	dc.l	ReplayMode
	String	'  CHANGE GOALIE   '
	dc.l	SelectGoalieMenu
	String	'    EDIT LINES    '
	dc.l	LineEditor
	String	'    GAME STATS    '
	dc.l	StatsReport
	String	'   PLAYER STATS   '
	dc.l	PlayerStatsScreen
	String	' Scoring Summary  '
	dc.l	ScoringSummaryScreen
	String	' Penalty Summary  '
	dc.l	PenaltySummaryScreen
	String	'   Team Roster    '
	dc.l	TeamRosterScreen
	String	'     Timeout      '
	dc.l	TimeoutMenu
	String	'  Record Holders  '
	dc.l	RecordHoldersScreen
	String	'   Period Stats   '
	dc.l	PeriodStatsScreen
	String	'x Manual Goalie   '
	dc.l	ManualGoalieMenu
	String	'    ABORT GAME    '
	dc.l	AbortGame
	String	CC_ListEnd

PauseMenuNoTimeout					;The pause menu once the team has used its timeout (team struct $30 bit 2)
	String	CC_SetFont,$01
	String	CC_SetFont,$02
	String	'   Resume Game    '
	dc.l	PlayGame
	String	'  Instant Replay  '
	dc.l	ReplayMode
	String	'  Change Goalie   '
	dc.l	SelectGoalieMenu
	String	'    Edit Lines    '
	dc.l	LineEditor
	String	'    Game Stats    '
	dc.l	StatsReport
	String	'   Player Stats   '
	dc.l	PlayerStatsScreen
	String	' Scoring Summary  '
	dc.l	ScoringSummaryScreen
	String	' Penalty Summary  '
	dc.l	PenaltySummaryScreen
	String	'   Team Roster    '
	dc.l	TeamRosterScreen
	String	'  Record Holders  '
	dc.l	RecordHoldersScreen
	String	'   Period Stats   '
	dc.l	PeriodStatsScreen
	String	'x Manual Goalie   '
	dc.l	ManualGoalieMenu
	String	'    ABORT GAME    '
	dc.l	AbortGame
	String	CC_ListEnd

ShootoutIntermissionMenu			;The intermission menu before a shootout
	String	CC_SetFont,$01
	String	CC_SetFont,$02
	String	'  Start Shootout  '
	dc.l	rtss2
	String	'  Shootout SetUp  '
	dc.l	ShootoutShooters
	String	'   Team Roster    '
	dc.l	TeamRosterScreen
	String	'  Record Holders  '
	dc.l	RecordHoldersScreen
	String	'    ABORT GAME    '
	dc.l	AbortGame
	String	CC_ListEnd

PregameMenu							;The intermission menus by gsp (IntermissionMenus): before the game
	String	CC_SetFont,$01
	String	CC_SetFont,$02
	String	'    Start Game    '
	dc.l	PlayGame
	String	'  Change Goalie   '
	dc.l	SelectGoalieMenu
	String	'    Edit Lines    '
	dc.l	LineEditor
	String	'   Team Roster    '
	dc.l	TeamRosterScreen
	String	'  Record Holders  '
	dc.l	RecordHoldersScreen
	String	'    ABORT GAME    '
	dc.l	AbortGame
	String	CC_ListEnd

PlayoffPregameMenu					;Before a playoff game
	String	CC_SetFont,$01
	String	CC_SetFont,$02
	String	'    Start Game    '
	dc.l	PlayGame
	String	'  Change Goalie   '
	dc.l	SelectGoalieMenu
	String	'    Edit Lines    '
	dc.l	LineEditor
	String	'   Team Roster    '
	dc.l	TeamRosterScreen
	String	'  Playoff Stats   '
	dc.l	PlayoffStatsMenu
	String	'  Record Holders  '
	dc.l	RecordHoldersScreen
	String	'    ABORT GAME    '
	dc.l	AbortGame
	String	CC_ListEnd

IntermissionMenu					;Between periods
	String	CC_SetFont,$01
	String	CC_SetFont,$02
	String	'   Resume Game    '
	dc.l	PlayGame
	String	'    Game Stats    '
	dc.l	StatsReport
	String	'   Player Stats   '
	dc.l	PlayerStatsScreen
	String	' Scoring Summary  '
	dc.l	ScoringSummaryScreen
	String	' Penalty Summary  '
	dc.l	PenaltySummaryScreen
	String	'   Team Roster    '
	dc.l	TeamRosterScreen
	String	'  Change Goalie   '
	dc.l	SelectGoalieMenu
	String	'    Edit Lines    '
	dc.l	LineEditor
	String	'  Record Holders  '
	dc.l	RecordHoldersScreen
	String	'   Period Stats   '
	dc.l	PeriodStatsScreen
	String	'    ABORT GAME    '
	dc.l	AbortGame
	String	CC_ListEnd

GameOverMenu						;After the game
	String	CC_SetFont,$01
	String	CC_SetFont,$02
	String	'    quit Game     '
	dc.l	PlayGame
	String	'    Game Stats    '
	dc.l	StatsReport
	String	'   Player Stats   '
	dc.l	PlayerStatsScreen
	String	' Scoring Summary  '
	dc.l	ScoringSummaryScreen
	String	' Penalty Summary  '
	dc.l	PenaltySummaryScreen
	String	'   Team Roster    '
	dc.l	TeamRosterScreen
	String	'  Record Holders  '
	dc.l	RecordHoldersScreen
	String	'   Period Stats   '
	dc.l	PeriodStatsScreen
	String	CC_ListEnd

PlayoffGameOverMenu					;After a playoff game
	String	CC_SetFont,$01
	String	CC_SetFont,$02
	String	'    quit Game     '
	dc.l	PlayGame
	String	'    Game Stats    '
	dc.l	StatsReport
	String	'   Player Stats   '
	dc.l	PlayerStatsScreen
	String	' Scoring Summary  '
	dc.l	ScoringSummaryScreen
	String	' Penalty Summary  '
	dc.l	PenaltySummaryScreen
	String	'   Team Roster    '
	dc.l	TeamRosterScreen
	String	'  Record Holders  '
	dc.l	RecordHoldersScreen
	String	'   Period Stats   '
	dc.l	PeriodStatsScreen
	String	CC_ListEnd
