;	Segment build for teamgfx96.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$012BFE

; includes for stubs to replace removed code
	include	stubinc\ports.inc		;IO_* / VDP_* ports
	include	stubinc\equals.inc		;VDP status bits
	include	ram96.asm				;RAM map
	include	externs96.asm			;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac		;String

; External addresses outside, read from lst/nhl96.bin.
TeamBlockANH = $148054				;graphics96
TeamBlockBOS = $148502				;graphics96
TeamBlockBUF = $148970				;graphics96
TeamBlockCGY = $148DDE				;graphics96
TeamBlockCHI = $14928C				;graphics96
TeamBlockDAL = $14973A				;graphics96
TeamBlockDET = $149BA8				;graphics96
TeamBlockEDM = $14A016				;graphics96
TeamBlockFLA = $14A4E4				;graphics96
TeamBlockHFD = $14A952				;graphics96
TeamBlockLA = $14AE20				;graphics96
TeamBlockMTL = $14B2EE				;graphics96
TeamBlockNJ = $14B7BC				;graphics96
TeamBlockNYI = $14BC8A				;graphics96
TeamBlockNYR = $14C158				;graphics96
TeamBlockOTW = $14C626				;graphics96
TeamBlockPHI = $14CAD4				;graphics96
TeamBlockPIT = $14CFA2				;graphics96
TeamBlockQUE = $14D470				;graphics96
TeamBlockSJ = $14D8DE				;graphics96
TeamBlockSTL = $14DD6C				;graphics96
TeamBlockTB = $14E1DA				;graphics96
TeamBlockTOR = $14E6A8				;graphics96
TeamBlockVAN = $14EB56				;graphics96
TeamBlockWSH = $14F024				;graphics96
TeamBlockWPG = $14F4F2				;graphics96
TeamLogoANH = $14F9A0				;graphics96
TeamLogoBOS = $150A8E				;graphics96
TeamLogoBUF = $151B1C				;graphics96
TeamLogoCGY = $152BEA				;graphics96
TeamLogoCHI = $153CD8				;graphics96
TeamLogoDAL = $154DE6				;graphics96
TeamLogoDET = $155ED4				;graphics96
TeamLogoEDM = $156FA2				;graphics96
TeamLogoFLA = $1580B0				;graphics96
TeamLogoHFD = $15919E				;graphics96
TeamLogoLA = $15A2AC				;graphics96
TeamLogoMTL = $15B3DA				;graphics96
TeamLogoNJ = $15C508				;graphics96
TeamLogoNYI = $15D636				;graphics96
TeamLogoNYR = $15E764				;graphics96
TeamLogoOTW = $15F872				;graphics96
TeamLogoPHI = $160980				;graphics96
TeamLogoPIT = $161AAE				;graphics96
TeamLogoQUE = $162BDC				;graphics96
TeamLogoSJ = $163CAA				;graphics96
TeamLogoSTL = $164DB8				;graphics96
TeamLogoTB = $165EA6				;graphics96
TeamLogoTOR = $166FB4				;graphics96
TeamLogoVAN = $1680A2				;graphics96
TeamLogoWSH = $1691D0				;graphics96
TeamLogoWPG = $16A2FE				;graphics96
SmallLogoFLA = $16B40C				;graphics96
SmallLogoBUF = $16B78C				;graphics96
SmallLogoANH = $16BAAC				;graphics96
SmallLogoBOS = $16BDEC				;graphics96
SmallLogoCGY = $16C14C				;graphics96
SmallLogoCHI = $16C52C				;graphics96
SmallLogoDAL = $16C8CC				;graphics96
SmallLogoDET = $16CBAC				;graphics96
SmallLogoEDM = $16CEEC				;graphics96
SmallLogoHFD = $16D2CC				;graphics96
SmallLogoLA = $16D56C				;graphics96
SmallLogoMTL = $16D86C				;graphics96
SmallLogoNJ = $16DBAC				;graphics96
SmallLogoNYI = $16DF4C				;graphics96
SmallLogoNYR = $16E26C				;graphics96
SmallLogoOTW = $16E64C				;graphics96
SmallLogoPHI = $16E9CC				;graphics96
SmallLogoPIT = $16ECEC				;graphics96
SmallLogoQUE = $16F00C				;graphics96
SmallLogoSJ = $16F32C				;graphics96
SmallLogoSTL = $16F6AC				;graphics96
SmallLogoTB = $16FA0C				;graphics96
SmallLogoTOR = $16FDEC				;graphics96
SmallLogoVAN = $1700EC				;graphics96
SmallLogoWSH = $17040C				;graphics96
SmallLogoWPG = $17074C				;graphics96


; Main segment code
	include	teamgfx96.asm
