;	The line editor exit menus.

LineMenu1							;The line editor exit menus
	String	$FE,$06,$F9,$01
	String	$FE,$04,$F9,$01
	String	'       Exit       '
	dc.l	rtss2
	String	'Set Original lines'
	dc.l	SetOriginalLines
	String	'  Save Team Line  '
	dc.l	SaveTeamLine
	String	'  Load Team Line  '
	dc.l	LoadTeamLine
	String	$FF

LineMenu2
	String	$FE,$06,$F9,$01
	String	$FE,$04,$F9,$01
	String	'       Exit       '
	dc.l	rtss2
	String	'Set Original lines'
	dc.l	SetOriginalLines
	String	'  Save Team Line  '
	dc.l	SaveTeamLine
	String	$FF
