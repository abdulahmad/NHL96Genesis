;	The line editor exit menus.

LineMenu1							;The line editor exit menus
	String	CC_SetAttribute,$06,CC_SetFont,$01
	String	CC_SetAttribute,$04,CC_SetFont,$01
	String	'       Exit       '
	dc.l	rtss2
	String	'Set Original lines'
	dc.l	SetOriginalLines
	String	'  Save Team Line  '
	dc.l	SaveTeamLine
	String	'  Load Team Line  '
	dc.l	LoadTeamLine
	String	CC_ListEnd

LineMenu2
	String	CC_SetAttribute,$06,CC_SetFont,$01
	String	CC_SetAttribute,$04,CC_SetFont,$01
	String	'       Exit       '
	dc.l	rtss2
	String	'Set Original lines'
	dc.l	SetOriginalLines
	String	'  Save Team Line  '
	dc.l	SaveTeamLine
	String	CC_ListEnd
