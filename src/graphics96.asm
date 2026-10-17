;	The pictures. A map is one file: the 8-byte header, the tiles, the palette
;	and the map. The tiles start eight bytes in.

NHLShieldMap	;The NHL shield logo on the trademark and credits pages (CreditsScreen)
	incbin	..\Extracted\NHL96\Graphics\NHLShieldMap.map.jim

NHLPALogoMap	;The NHLPA logo on the trademark and credits pages (CreditsScreen)
	incbin	..\Extracted\NHL96\Graphics\NHLPALogoMap.map.jim

CreditsBgMap	;The background of the trademark and credits pages (CreditsScreen)
	incbin	..\Extracted\NHL96\Graphics\CreditsBgMap.map.jim

Framermap	;The Framermap map (Framer); +8 the framer tiles
	incbin	..\Extracted\NHL96\Graphics\Framermap.map.jim

FaceOffMap	;The face-off map; +8 the tiles
	incbin	..\Extracted\NHL96\Graphics\FaceOffMap.map.jim

Rinktilelist	;The ice rink map; Rinktilelist+8 = the rink tiles
	incbin	..\Extracted\NHL96\Graphics\Rinktilelist.map.jim

RefTiles	;The RefTiles map (the ref window)
	incbin	..\Extracted\NHL96\Graphics\RefTiles.map.jim

RefTilesHor	;The RefTilesHor map (the ref window, horizontal rink)
	incbin	..\Extracted\NHL96\Graphics\RefTilesHor.map.jim

Sprites	;The sprite header: the offsets of the palette and of frameSprData (data96_06), then the tile count
	incbin	..\Extracted\NHL96\Graphics\Sprites.bin

Spritetiles	;The sprite tiles (continued in data96_06)
	incbin	..\Extracted\NHL96\Graphics\Spritetiles.bin

SpritePalette	;The sprite palette (the Sprites header's first offset)
	incbin	..\Extracted\NHL96\Graphics\SpritePalette.bin

frameSprData	;The sprite frame data (the Sprites header's second offset)
	incbin	..\Extracted\NHL96\Graphics\frameSprData.bin

HotList	;The hot spot byte pair of each frame (GetHot)
	incbin	..\Extracted\NHL96\Graphics\HotList.bin

HotList2	;The hot spot list of the GetHot variants
	incbin	..\Extracted\NHL96\Graphics\HotList2.bin

CrowdFrameList	;The crowd sprite frames (showcrowd); +8 the crowd tiles (animchars)
	incbin	..\Extracted\NHL96\Graphics\CrowdFrameList.map.jim

FaceOffSprites	;The face-off sprites (checkfo); +8 the tiles
	incbin	..\Extracted\NHL96\Graphics\FaceOffSprites.map.jim

EnergyBarMap	;The EnergyBarMap map
	incbin	..\Extracted\NHL96\Graphics\EnergyBarMap.map.jim

EASNmap	;The EASN logo map (EASNLogo); +8 the tiles
	incbin	..\Extracted\NHL96\Graphics\EASNmap.map.jim

EASportsMap	;The EA Sports screen map (EASportsScreen)
	incbin	..\Extracted\NHL96\Graphics\EASportsMap.map.jim

RevRinkTilelist	;The ice rink map rows of a reverse angle replay (updatescroll)
	incbin	..\Extracted\NHL96\Graphics\RevRinkTilelist.bin

ReplayIconMap	;The replay icon map (ShowReplayIcon); continued in data96_07
	incbin	..\Extracted\NHL96\Graphics\ReplayIconMap.map.jim

ReplayBannerMap	;The replay banner map (ShowReplayBanner)
	incbin	..\Extracted\NHL96\Graphics\ReplayBannerMap.map.jim

unk_1417B6	;Used by the table after RunArenaAnim (the dead arena animation): a frame offset table, not a plain picture
	incbin	..\Extracted\NHL96\Graphics\unk_1417B6.map.jim

HiScoreBgMap	;The high score screen background (HiScoreScreen)
	incbin	..\Extracted\NHL96\Graphics\HiScoreBgMap.map.jim

HiScoreImg	;The high score screen picture (HiScoreScreen)
	incbin	..\Extracted\NHL96\Graphics\HiScoreImg.map.jim

TeamBlockANH	;The setup team block bitmap of ANH (TeamBlockPtrs)
	incbin	..\Extracted\NHL96\Graphics\TeamBlockANH.map.jim

TeamBlockBOS	;The setup team block bitmap of BOS (TeamBlockPtrs)
	incbin	..\Extracted\NHL96\Graphics\TeamBlockBOS.map.jim

TeamBlockBUF	;The setup team block bitmap of BUF (TeamBlockPtrs)
	incbin	..\Extracted\NHL96\Graphics\TeamBlockBUF.map.jim

TeamBlockCGY	;The setup team block bitmap of CGY (TeamBlockPtrs)
	incbin	..\Extracted\NHL96\Graphics\TeamBlockCGY.map.jim

TeamBlockCHI	;The setup team block bitmap of CHI (TeamBlockPtrs)
	incbin	..\Extracted\NHL96\Graphics\TeamBlockCHI.map.jim

TeamBlockDAL	;The setup team block bitmap of DAL (TeamBlockPtrs)
	incbin	..\Extracted\NHL96\Graphics\TeamBlockDAL.map.jim

TeamBlockDET	;The setup team block bitmap of DET (TeamBlockPtrs)
	incbin	..\Extracted\NHL96\Graphics\TeamBlockDET.map.jim

TeamBlockEDM	;The setup team block bitmap of EDM (TeamBlockPtrs)
	incbin	..\Extracted\NHL96\Graphics\TeamBlockEDM.map.jim

TeamBlockFLA	;The setup team block bitmap of FLA (TeamBlockPtrs)
	incbin	..\Extracted\NHL96\Graphics\TeamBlockFLA.map.jim

TeamBlockHFD	;The setup team block bitmap of HFD (TeamBlockPtrs)
	incbin	..\Extracted\NHL96\Graphics\TeamBlockHFD.map.jim

TeamBlockLA	;The setup team block bitmap of LA (TeamBlockPtrs)
	incbin	..\Extracted\NHL96\Graphics\TeamBlockLA.map.jim

TeamBlockMTL	;The setup team block bitmap of MTL (TeamBlockPtrs)
	incbin	..\Extracted\NHL96\Graphics\TeamBlockMTL.map.jim

TeamBlockNJ	;The setup team block bitmap of NJ (TeamBlockPtrs)
	incbin	..\Extracted\NHL96\Graphics\TeamBlockNJ.map.jim

TeamBlockNYI	;The setup team block bitmap of NYI (TeamBlockPtrs)
	incbin	..\Extracted\NHL96\Graphics\TeamBlockNYI.map.jim

TeamBlockNYR	;The setup team block bitmap of NYR (TeamBlockPtrs)
	incbin	..\Extracted\NHL96\Graphics\TeamBlockNYR.map.jim

TeamBlockOTW	;The setup team block bitmap of OTW (TeamBlockPtrs)
	incbin	..\Extracted\NHL96\Graphics\TeamBlockOTW.map.jim

TeamBlockPHI	;The setup team block bitmap of PHI (TeamBlockPtrs)
	incbin	..\Extracted\NHL96\Graphics\TeamBlockPHI.map.jim

TeamBlockPIT	;The setup team block bitmap of PIT (TeamBlockPtrs)
	incbin	..\Extracted\NHL96\Graphics\TeamBlockPIT.map.jim

TeamBlockQUE	;The setup team block bitmap of QUE (TeamBlockPtrs)
	incbin	..\Extracted\NHL96\Graphics\TeamBlockQUE.map.jim

TeamBlockSJ	;The setup team block bitmap of SJ (TeamBlockPtrs)
	incbin	..\Extracted\NHL96\Graphics\TeamBlockSJ.map.jim

TeamBlockSTL	;The setup team block bitmap of STL (TeamBlockPtrs)
	incbin	..\Extracted\NHL96\Graphics\TeamBlockSTL.map.jim

TeamBlockTB	;The setup team block bitmap of TB (TeamBlockPtrs)
	incbin	..\Extracted\NHL96\Graphics\TeamBlockTB.map.jim

TeamBlockTOR	;The setup team block bitmap of TOR (TeamBlockPtrs)
	incbin	..\Extracted\NHL96\Graphics\TeamBlockTOR.map.jim

TeamBlockVAN	;The setup team block bitmap of VAN (TeamBlockPtrs)
	incbin	..\Extracted\NHL96\Graphics\TeamBlockVAN.map.jim

TeamBlockWSH	;The setup team block bitmap of WSH (TeamBlockPtrs)
	incbin	..\Extracted\NHL96\Graphics\TeamBlockWSH.map.jim

TeamBlockWPG	;The setup team block bitmap of WPG (TeamBlockPtrs)
	incbin	..\Extracted\NHL96\Graphics\TeamBlockWPG.map.jim

TeamLogoANH	;The team logo bitmap of ANH (TeamLogoPtrs)
	incbin	..\Extracted\NHL96\Graphics\TeamLogoANH.map.jim

TeamLogoBOS	;The team logo bitmap of BOS (TeamLogoPtrs)
	incbin	..\Extracted\NHL96\Graphics\TeamLogoBOS.map.jim

TeamLogoBUF	;The team logo bitmap of BUF (TeamLogoPtrs)
	incbin	..\Extracted\NHL96\Graphics\TeamLogoBUF.map.jim

TeamLogoCGY	;The team logo bitmap of CGY (TeamLogoPtrs)
	incbin	..\Extracted\NHL96\Graphics\TeamLogoCGY.map.jim

TeamLogoCHI	;The team logo bitmap of CHI (TeamLogoPtrs)
	incbin	..\Extracted\NHL96\Graphics\TeamLogoCHI.map.jim

TeamLogoDAL	;The team logo bitmap of DAL (TeamLogoPtrs)
	incbin	..\Extracted\NHL96\Graphics\TeamLogoDAL.map.jim

TeamLogoDET	;The team logo bitmap of DET (TeamLogoPtrs)
	incbin	..\Extracted\NHL96\Graphics\TeamLogoDET.map.jim

TeamLogoEDM	;The team logo bitmap of EDM (TeamLogoPtrs)
	incbin	..\Extracted\NHL96\Graphics\TeamLogoEDM.map.jim

TeamLogoFLA	;The team logo bitmap of FLA (TeamLogoPtrs)
	incbin	..\Extracted\NHL96\Graphics\TeamLogoFLA.map.jim

TeamLogoHFD	;The team logo bitmap of HFD (TeamLogoPtrs)
	incbin	..\Extracted\NHL96\Graphics\TeamLogoHFD.map.jim

TeamLogoLA	;The team logo bitmap of LA (TeamLogoPtrs)
	incbin	..\Extracted\NHL96\Graphics\TeamLogoLA.map.jim

TeamLogoMTL	;The team logo bitmap of MTL (TeamLogoPtrs)
	incbin	..\Extracted\NHL96\Graphics\TeamLogoMTL.map.jim

TeamLogoNJ	;The team logo bitmap of NJ (TeamLogoPtrs)
	incbin	..\Extracted\NHL96\Graphics\TeamLogoNJ.map.jim

TeamLogoNYI	;The team logo bitmap of NYI (TeamLogoPtrs)
	incbin	..\Extracted\NHL96\Graphics\TeamLogoNYI.map.jim

TeamLogoNYR	;The team logo bitmap of NYR (TeamLogoPtrs)
	incbin	..\Extracted\NHL96\Graphics\TeamLogoNYR.map.jim

TeamLogoOTW	;The team logo bitmap of OTW (TeamLogoPtrs)
	incbin	..\Extracted\NHL96\Graphics\TeamLogoOTW.map.jim

TeamLogoPHI	;The team logo bitmap of PHI (TeamLogoPtrs)
	incbin	..\Extracted\NHL96\Graphics\TeamLogoPHI.map.jim

TeamLogoPIT	;The team logo bitmap of PIT (TeamLogoPtrs)
	incbin	..\Extracted\NHL96\Graphics\TeamLogoPIT.map.jim

TeamLogoQUE	;The team logo bitmap of QUE (TeamLogoPtrs)
	incbin	..\Extracted\NHL96\Graphics\TeamLogoQUE.map.jim

TeamLogoSJ	;The team logo bitmap of SJ (TeamLogoPtrs)
	incbin	..\Extracted\NHL96\Graphics\TeamLogoSJ.map.jim

TeamLogoSTL	;The team logo bitmap of STL (TeamLogoPtrs)
	incbin	..\Extracted\NHL96\Graphics\TeamLogoSTL.map.jim

TeamLogoTB	;The team logo bitmap of TB (TeamLogoPtrs)
	incbin	..\Extracted\NHL96\Graphics\TeamLogoTB.map.jim

TeamLogoTOR	;The team logo bitmap of TOR (TeamLogoPtrs)
	incbin	..\Extracted\NHL96\Graphics\TeamLogoTOR.map.jim

TeamLogoVAN	;The team logo bitmap of VAN (TeamLogoPtrs)
	incbin	..\Extracted\NHL96\Graphics\TeamLogoVAN.map.jim

TeamLogoWSH	;The team logo bitmap of WSH (TeamLogoPtrs)
	incbin	..\Extracted\NHL96\Graphics\TeamLogoWSH.map.jim

TeamLogoWPG	;The team logo bitmap of WPG (TeamLogoPtrs)
	incbin	..\Extracted\NHL96\Graphics\TeamLogoWPG.map.jim

SmallLogoFLA	;The small team logo of FLA (SmallLogoPtrs)
	incbin	..\Extracted\NHL96\Graphics\SmallLogoFLA.map.jim

SmallLogoBUF	;The small team logo of BUF (SmallLogoPtrs)
	incbin	..\Extracted\NHL96\Graphics\SmallLogoBUF.map.jim

SmallLogoANH	;The small team logo of ANH (SmallLogoPtrs)
	incbin	..\Extracted\NHL96\Graphics\SmallLogoANH.map.jim

SmallLogoBOS	;The small team logo of BOS (SmallLogoPtrs)
	incbin	..\Extracted\NHL96\Graphics\SmallLogoBOS.map.jim

SmallLogoCGY	;The small team logo of CGY (SmallLogoPtrs)
	incbin	..\Extracted\NHL96\Graphics\SmallLogoCGY.map.jim

SmallLogoCHI	;The small team logo of CHI (SmallLogoPtrs)
	incbin	..\Extracted\NHL96\Graphics\SmallLogoCHI.map.jim

SmallLogoDAL	;The small team logo of DAL (SmallLogoPtrs)
	incbin	..\Extracted\NHL96\Graphics\SmallLogoDAL.map.jim

SmallLogoDET	;The small team logo of DET (SmallLogoPtrs)
	incbin	..\Extracted\NHL96\Graphics\SmallLogoDET.map.jim

SmallLogoEDM	;The small team logo of EDM (SmallLogoPtrs)
	incbin	..\Extracted\NHL96\Graphics\SmallLogoEDM.map.jim

SmallLogoHFD	;The small team logo of HFD (SmallLogoPtrs)
	incbin	..\Extracted\NHL96\Graphics\SmallLogoHFD.map.jim

SmallLogoLA	;The small team logo of LA (SmallLogoPtrs)
	incbin	..\Extracted\NHL96\Graphics\SmallLogoLA.map.jim

SmallLogoMTL	;The small team logo of MTL (SmallLogoPtrs)
	incbin	..\Extracted\NHL96\Graphics\SmallLogoMTL.map.jim

SmallLogoNJ	;The small team logo of NJ (SmallLogoPtrs)
	incbin	..\Extracted\NHL96\Graphics\SmallLogoNJ.map.jim

SmallLogoNYI	;The small team logo of NYI (SmallLogoPtrs)
	incbin	..\Extracted\NHL96\Graphics\SmallLogoNYI.map.jim

SmallLogoNYR	;The small team logo of NYR (SmallLogoPtrs)
	incbin	..\Extracted\NHL96\Graphics\SmallLogoNYR.map.jim

SmallLogoOTW	;The small team logo of OTW (SmallLogoPtrs)
	incbin	..\Extracted\NHL96\Graphics\SmallLogoOTW.map.jim

SmallLogoPHI	;The small team logo of PHI (SmallLogoPtrs)
	incbin	..\Extracted\NHL96\Graphics\SmallLogoPHI.map.jim

SmallLogoPIT	;The small team logo of PIT (SmallLogoPtrs)
	incbin	..\Extracted\NHL96\Graphics\SmallLogoPIT.map.jim

SmallLogoQUE	;The small team logo of QUE (SmallLogoPtrs)
	incbin	..\Extracted\NHL96\Graphics\SmallLogoQUE.map.jim

SmallLogoSJ	;The small team logo of SJ (SmallLogoPtrs)
	incbin	..\Extracted\NHL96\Graphics\SmallLogoSJ.map.jim

SmallLogoSTL	;The small team logo of STL (SmallLogoPtrs)
	incbin	..\Extracted\NHL96\Graphics\SmallLogoSTL.map.jim

SmallLogoTB	;The small team logo of TB (SmallLogoPtrs)
	incbin	..\Extracted\NHL96\Graphics\SmallLogoTB.map.jim

SmallLogoTOR	;The small team logo of TOR (SmallLogoPtrs)
	incbin	..\Extracted\NHL96\Graphics\SmallLogoTOR.map.jim

SmallLogoVAN	;The small team logo of VAN (SmallLogoPtrs)
	incbin	..\Extracted\NHL96\Graphics\SmallLogoVAN.map.jim

SmallLogoWSH	;The small team logo of WSH (SmallLogoPtrs)
	incbin	..\Extracted\NHL96\Graphics\SmallLogoWSH.map.jim

SmallLogoWPG	;The small team logo of WPG (SmallLogoPtrs)
	incbin	..\Extracted\NHL96\Graphics\SmallLogoWPG.map.jim

IceBgMap	;The plain ice background behind most menu screens on map 2
	incbin	..\Extracted\NHL96\Graphics\IceBgMap.map.jim

ControllerBgMap	;The controller setup screen background map (ControllerSetupScreen)
	incbin	..\Extracted\NHL96\Graphics\ControllerBgMap.map.jim

RosterFont	;The roster font map (smallfontptr); +8 the tiles
	incbin	..\Extracted\NHL96\Graphics\RosterFont.bin

SmallFontMap	;The small font map (print); +8 the tiles (LoadSmallFont)
	incbin	..\Extracted\NHL96\Graphics\SmallFontMap.map.jim

SmallFontMap2	;The second small font map; +8 the tiles
	incbin	..\Extracted\NHL96\Graphics\SmallFontMap2.map.jim

BigFontMap2	;The big font map (printbig, bigfontptr); +8 the tiles
	incbin	..\Extracted\NHL96\Graphics\BigFontMap2.map.jim

BigFontMap4	;The big font map printbig takes with sflags11 bit 2; +8 the tiles
	incbin	..\Extracted\NHL96\Graphics\BigFontMap4.map.jim

unk_17C2AE	;A 16-colour palette (PStatsPalette, PStatsPalette2, SaveTeamLine copy it); what it colours is not known
	incbin	..\Extracted\NHL96\Graphics\unk_17C2AE.map.jim

LeagueOptionsBgMap	;The League Options screen background
	incbin	..\Extracted\NHL96\Graphics\LeagueOptionsBgMap.map.jim

LeagueOptionsTitleMap	;The League Options title banner
	incbin	..\Extracted\NHL96\Graphics\LeagueOptionsTitleMap.map.jim

LeagueOptionsSprites	;The League Options screen sprites (a SetSframe frame list); +8 the tiles
	incbin	..\Extracted\NHL96\Graphics\LeagueOptionsSprites.map.jim

SelectTeamSeasonBgMap	;The select team screen background in a season (TeamSelectGfx)
	incbin	..\Extracted\NHL96\Graphics\SelectTeamSeasonBgMap.map.jim

SelectTeamSeasonSprites	;The select team screen sprites in a season (TeamSelectScreen); +8 the tiles
	incbin	..\Extracted\NHL96\Graphics\SelectTeamSeasonSprites.map.jim

StandingsTitleMap	;The NHL Standings title banner
	incbin	..\Extracted\NHL96\Graphics\StandingsTitleMap.map.jim

StandingsBgMap	;The NHL Standings screen background
	incbin	..\Extracted\NHL96\Graphics\StandingsBgMap.map.jim

StandingsSprites	;The NHL Standings screen sprites; +8 the tiles
	incbin	..\Extracted\NHL96\Graphics\StandingsSprites.map.jim

GameOptionsBgMap	;The Game Options screen background
	incbin	..\Extracted\NHL96\Graphics\GameOptionsBgMap.map.jim

GameOptionsTitleMap	;The Game Options title banner
	incbin	..\Extracted\NHL96\Graphics\GameOptionsTitleMap.map.jim

GameOptionsSprites	;The Game Options screen sprites; +8 the tiles
	incbin	..\Extracted\NHL96\Graphics\GameOptionsSprites.map.jim

LeadersBgMap	;The League / Playoff Leaders screen background
	incbin	..\Extracted\NHL96\Graphics\LeadersBgMap.map.jim

LeagueLeadersTitleMap	;The League Leaders title banner
	incbin	..\Extracted\NHL96\Graphics\LeagueLeadersTitleMap.map.jim

LeadersSprites	;The League / Playoff Leaders screen sprites; +8 the tiles
	incbin	..\Extracted\NHL96\Graphics\LeadersSprites.map.jim

PlayoffLeadersTitleMap	;The Playoff Leaders title banner
	incbin	..\Extracted\NHL96\Graphics\PlayoffLeadersTitleMap.map.jim

PlayerStatsBgMap	;The player stats screen background (PStatsSetup, PListSetup)
	incbin	..\Extracted\NHL96\Graphics\PlayerStatsBgMap.map.jim

SeasonStatsTitleMap	;The Season Stats title banner (PStatsSetup)
	incbin	..\Extracted\NHL96\Graphics\SeasonStatsTitleMap.map.jim

PlayerStatsSprites	;The player stats screen sprites (SeasonPlayoffStats, PlayerStatsList); +8 the tiles
	incbin	..\Extracted\NHL96\Graphics\PlayerStatsSprites.map.jim

PlayoffStatsTitleMap	;The Playoff Stats title banner (PStatsSetup, PListSetup)
	incbin	..\Extracted\NHL96\Graphics\PlayoffStatsTitleMap.map.jim

SelectTeamTitleMap	;The Select Team title banner (TeamSelectGfx)
	incbin	..\Extracted\NHL96\Graphics\SelectTeamTitleMap.map.jim

SelectTeamBgMap	;The select team screen background outside a season (TeamSelectGfx)
	incbin	..\Extracted\NHL96\Graphics\SelectTeamBgMap.map.jim

SelectTeamSprites	;The select team screen sprites outside a season (TeamSelectGfx; PeriodStatsTeam too); +8 the tiles
	incbin	..\Extracted\NHL96\Graphics\SelectTeamSprites.map.jim

TransactionsTitleMap	;The Transactions title banner (PlayoffMenuSetup)
	incbin	..\Extracted\NHL96\Graphics\TransactionsTitleMap.map.jim

TransactionsBgMap	;The Transactions (roster menu) screen background (PlayoffMenuSetup)
	incbin	..\Extracted\NHL96\Graphics\TransactionsBgMap.map.jim

TransactionsSprites	;The Transactions screen sprites (PlayoffMenuScreen); +8 the tiles
	incbin	..\Extracted\NHL96\Graphics\TransactionsSprites.map.jim

TradeTitleMap	;The Trade Players title banner
	incbin	..\Extracted\NHL96\Graphics\TradeTitleMap.map.jim

TradeBgMap	;The trade screen background
	incbin	..\Extracted\NHL96\Graphics\TradeBgMap.map.jim

TradeSprites	;The trade screen sprites (TradePlayers); +8 the tiles
	incbin	..\Extracted\NHL96\Graphics\TradeSprites.map.jim

CreateTitleMap	;The Create Player title banner
	incbin	..\Extracted\NHL96\Graphics\CreateTitleMap.map.jim

CreateBgMap	;The create player screen background (the name list)
	incbin	..\Extracted\NHL96\Graphics\CreateBgMap.map.jim

CreateSprites	;The create player screen sprites; +8 the tiles
	incbin	..\Extracted\NHL96\Graphics\CreateSprites.map.jim

CreateRatingsBgMap	;The create player ratings screen background (ModifyRatings)
	incbin	..\Extracted\NHL96\Graphics\CreateRatingsBgMap.map.jim

CreateRatingsSprites	;The create player ratings screen sprites (ModifyRatings); +8 the tiles
	incbin	..\Extracted\NHL96\Graphics\CreateRatingsSprites.map.jim

SignPlayersTitleMap	;The Sign Players title banner (SignFreeAgents)
	incbin	..\Extracted\NHL96\Graphics\SignPlayersTitleMap.map.jim

SignPlayersSprites	;The sign free agents screen sprites (SignFreeAgents); +8 the tiles
	incbin	..\Extracted\NHL96\Graphics\SignPlayersSprites.map.jim

ReleasePlayersTitleMap	;The Release Players title banner (ReleaseGfx)
	incbin	..\Extracted\NHL96\Graphics\ReleasePlayersTitleMap.map.jim

SignReleaseBgMap	;The sign free agents and release players screen background
	incbin	..\Extracted\NHL96\Graphics\SignReleaseBgMap.map.jim

ReleasePlayersSprites	;The release players screen sprites (ReleasePlayers); +8 the tiles
	incbin	..\Extracted\NHL96\Graphics\ReleasePlayersSprites.map.jim

MainMenuTitleMap	;The Main Menu title banner (OptionsScreenSetup)
	incbin	..\Extracted\NHL96\Graphics\MainMenuTitleMap.map.jim

MainMenuBgMap	;The main menu (OptionsScreen) background
	incbin	..\Extracted\NHL96\Graphics\MainMenuBgMap.map.jim

MainMenuSprites	;The main menu (OptionsScreen) sprites; +8 the tiles
	incbin	..\Extracted\NHL96\Graphics\MainMenuSprites.map.jim

EditLinesTitleMap	;The Edit Lines title banner (LineEditor)
	incbin	..\Extracted\NHL96\Graphics\EditLinesTitleMap.map.jim

LineEditorBgMap2	;The second line editor background, also behind the shootout setup (DrawLineIcons, ShootersMove)
	incbin	..\Extracted\NHL96\Graphics\LineEditorBgMap2.map.jim

LineEditorBgMap	;The line editor background (LineEditor, ShootoutShooters); +8 the tiles
	incbin	..\Extracted\NHL96\Graphics\LineEditorBgMap.map.jim

LineEditorSprites2	;The sprites drawn with LineEditorBgMap2 (DrawLineIcons, ShootersMove); +8 the tiles
	incbin	..\Extracted\NHL96\Graphics\LineEditorSprites2.map.jim

LineEditorSprites	;The line editor sprites (LineEditor, ShootoutShooters); +8 the tiles
	incbin	..\Extracted\NHL96\Graphics\LineEditorSprites.map.jim

TeamRosterBgMap	;The Team Roster screen background (TeamRosterScreen)
	incbin	..\Extracted\NHL96\Graphics\TeamRosterBgMap.map.jim

TeamRosterSprites	;The Team Roster screen sprites (TeamRosterScreen); +8 the tiles
	incbin	..\Extracted\NHL96\Graphics\TeamRosterSprites.map.jim

TeamRosterTitleMap	;The Team Roster title banner (TeamRosterScreen)
	incbin	..\Extracted\NHL96\Graphics\TeamRosterTitleMap.map.jim

SummaryBgMap	;The scoring and penalty summary background
	incbin	..\Extracted\NHL96\Graphics\SummaryBgMap.map.jim

SummarySprites	;The scoring and penalty summary sprites; +8 the tiles
	incbin	..\Extracted\NHL96\Graphics\SummarySprites.map.jim

ScoringTitleMap	;The Scoring summary title banner (ScoringSummaryScreen)
	incbin	..\Extracted\NHL96\Graphics\ScoringTitleMap.map.jim

PenaltiesTitleMap	;The Penalties summary title banner (PenaltySummaryScreen)
	incbin	..\Extracted\NHL96\Graphics\PenaltiesTitleMap.map.jim

PeriodStatsTitleMap	;The Period Stats title banner (PeriodStatsScreen)
	incbin	..\Extracted\NHL96\Graphics\PeriodStatsTitleMap.map.jim

PeriodStatsMap	;The period stats screen background (PeriodStatsScreen)
	incbin	..\Extracted\NHL96\Graphics\PeriodStatsMap.map.jim

GameStatsTitleMap	;The Game Stats title banner (GameStatisticsScreen)
	incbin	..\Extracted\NHL96\Graphics\GameStatsTitleMap.map.jim

GameStatsBgMap	;The game stats screen background (GameStatisticsScreen)
	incbin	..\Extracted\NHL96\Graphics\GameStatsBgMap.map.jim

GameStatsSprites	;The game stats screen sprites (GameStatisticsScreen); +8 the tiles
	incbin	..\Extracted\NHL96\Graphics\GameStatsSprites.map.jim

ShootoutSetupTitleMap	;The Shootout Setup title banner (ShootoutShooters)
	incbin	..\Extracted\NHL96\Graphics\ShootoutSetupTitleMap.map.jim

RecordHoldersTitleMap	;The Record Holders title banner (RecordHoldersScreen)
	incbin	..\Extracted\NHL96\Graphics\RecordHoldersTitleMap.map.jim

RecordHoldersBgMap	;The record holders screen background (RecordHoldersScreen)
	incbin	..\Extracted\NHL96\Graphics\RecordHoldersBgMap.map.jim

RecordHoldersSprites	;The record holders screen sprites (RecordHoldersScreen); +8 the tiles
	incbin	..\Extracted\NHL96\Graphics\RecordHoldersSprites.map.jim

PlayerStatsTitleMap	;The Player Stats title banner (PListSetup)
	incbin	..\Extracted\NHL96\Graphics\PlayerStatsTitleMap.map.jim

NameEntryTitleMap	;The User Entry title banner (NameEntryGfx)
	incbin	..\Extracted\NHL96\Graphics\NameEntryTitleMap.map.jim

NameEntryBgMap	;The name entry screen background (NameEntryGfx)
	incbin	..\Extracted\NHL96\Graphics\NameEntryBgMap.map.jim

NameEntrySprites	;The name entry screen sprites (NameEntryScreen); +8 the tiles
	incbin	..\Extracted\NHL96\Graphics\NameEntrySprites.map.jim

AwardsTitleMap	;The NHL Awards title banner (AwardsScreenSetup)
	incbin	..\Extracted\NHL96\Graphics\AwardsTitleMap.map.jim

AwardsBgMap	;The awards screen background (AwardsScreenSetup)
	incbin	..\Extracted\NHL96\Graphics\AwardsBgMap.map.jim

AwardsSprites	;The awards screen sprites (AwardsScreenSetup); +8 the tiles
	incbin	..\Extracted\NHL96\Graphics\AwardsSprites.map.jim

PresidentsPic	;Award picture: Presidents Trophy
	incbin	..\Extracted\NHL96\Graphics\PresidentsPic.map.jim

ArtRossPic	;Award picture: Art Ross Trophy
	incbin	..\Extracted\NHL96\Graphics\ArtRossPic.map.jim

NorrisPic	;Award picture: James Norris Trophy
	incbin	..\Extracted\NHL96\Graphics\NorrisPic.map.jim

VezinaPic	;Award picture: Vezina Trophy
	incbin	..\Extracted\NHL96\Graphics\VezinaPic.map.jim

CampbellPic	;Award picture: Clarence Campbell Bowl
	incbin	..\Extracted\NHL96\Graphics\CampbellPic.map.jim

WalesPic	;Award picture: Prince of Wales Trophy
	incbin	..\Extracted\NHL96\Graphics\WalesPic.map.jim

HartPic	;Award picture: Hart Memorial Trophy (SeasonAwards)
	incbin	..\Extracted\NHL96\Graphics\HartPic.map.jim

ConnSmythePic	;Award picture: Conn Smythe Trophy
	incbin	..\Extracted\NHL96\Graphics\ConnSmythePic.map.jim

PearsonPic	;Award picture: Lester B. Pearson Award
	incbin	..\Extracted\NHL96\Graphics\PearsonPic.map.jim

PadIconMap1	;Pad icon map 1 (PadIconMaps); +8 the tiles
	incbin	..\Extracted\NHL96\Graphics\PadIconMap1.map.jim

PadIconMap2	;Pad icon map 2 (PadIconMaps); +8 the tiles
	incbin	..\Extracted\NHL96\Graphics\PadIconMap2.map.jim

PadIconMap3	;Pad icon map 3 (PadIconMaps); +8 the tiles
	incbin	..\Extracted\NHL96\Graphics\PadIconMap3.map.jim

PadIconMap4	;Pad icon map 4 (PadIconMaps); +8 the tiles
	incbin	..\Extracted\NHL96\Graphics\PadIconMap4.map.jim

PadCursorMap	;The pad cursor map (DrawPadIcon); +8 the tiles
	incbin	..\Extracted\NHL96\Graphics\PadCursorMap.map.jim

ControllerTitleMap	;The controller setup screen title map (ControllerSetupScreen)
	incbin	..\Extracted\NHL96\Graphics\ControllerTitleMap.map.jim

ControllerFrameMap	;The controller setup screen frame on map 1 (ControllerSetupScreen)
	incbin	..\Extracted\NHL96\Graphics\ControllerFrameMap.map.jim

BigFontMap	;The big font map of printbig1 (chars bigfont1chars); +8 the tiles (LoadBigFonts)
	incbin	..\Extracted\NHL96\Graphics\BigFontMap.map.jim

BigFontMap3	;The big font map of printbig2 (chars BigFontChars); +8 the tiles (LoadBigFonts)
	incbin	..\Extracted\NHL96\Graphics\BigFontMap3.map.jim

DigitFontMap	;The big digit font printbig uses in mode 3; +8 the tiles (the pause screen)
	incbin	..\Extracted\NHL96\Graphics\DigitFontMap.map.jim

PauseRinkMap	;The pause screen rink background on map 2 (PauseScreenDraw)
	incbin	..\Extracted\NHL96\Graphics\PauseRinkMap.map.jim

PauseBgBitmap	;The pause screen board (PauseScreenDraw)
	incbin	..\Extracted\NHL96\Graphics\PauseBgBitmap.map.jim

PauseSprites	;The pause screen sprites (PauseScreenDraw); +8 the tiles
	incbin	..\Extracted\NHL96\Graphics\PauseSprites.map.jim

FoxBannerMap	;The NHL on FOX banner on the pause screen (PauseScreenDraw)
	incbin	..\Extracted\NHL96\Graphics\FoxBannerMap.map.jim

HockeyNewsBannerMap	;The Hockey News banner on the pause screen (PauseScreenDraw)
	incbin	..\Extracted\NHL96\Graphics\HockeyNewsBannerMap.map.jim

PlayoffTreeMap	;The playoff tree bracket (PlayoffScreen); +8 the tiles
	incbin	..\Extracted\NHL96\Graphics\PlayoffTreeMap.map.jim

PlayoffTreeBgMap	;The playoff tree ice background on map 2 (PlayoffScreen)
	incbin	..\Extracted\NHL96\Graphics\PlayoffTreeBgMap.map.jim

PlayoffTeamFrameMap	;The frame DrawTeamBlocks draws around the user's team in the playoff tree; +8 the tiles
	incbin	..\Extracted\NHL96\Graphics\PlayoffTeamFrameMap.map.jim

PuckAnimMap	;The spinning puck animation, 7x7 tiles a frame (OptionsAnimFrame); +8 the tiles
	incbin	..\Extracted\NHL96\Graphics\PuckAnimMap.map.jim

CupChampsMap	;The Stanley Cup champions team picture (CupChampionsScreen)
	incbin	..\Extracted\NHL96\Graphics\CupChampsMap.map.jim

CupChampsMap2	;The champions picture layer in the team palette (CupChampionsScreen)
	incbin	..\Extracted\NHL96\Graphics\CupChampsMap2.map.jim

CupChampsPals	;One palette per team for the Stanley Cup champions picture (CupChampionsScreen)
	incbin	..\Extracted\NHL96\Graphics\CupChampsPals.map.jim

unk_1CCEE8	;The sprites CupCelebration animates over the rink
	incbin	..\Extracted\NHL96\Graphics\unk_1CCEE8.map.jim

unk_1D5420	;A picture CupCelebrationSetup draws at 6,$C
	incbin	..\Extracted\NHL96\Graphics\unk_1D5420.map.jim

revframetbl	;One word per sprite frame: the frame for a reverse angle replay (RevReplayAdj)
	incbin	..\Extracted\NHL96\Graphics\revframetbl.map.jim
