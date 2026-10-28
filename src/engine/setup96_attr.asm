;	Roster attribute columns for the skaters and the goalies.

PAttribColumns						;Skater attribute columns. String header, then a long: high word = mask of
									;rating nibbles to average, low word = attribjmp offset (0 status, 2
									;energy, 4 handed, 6 weight, $A rating). A negative word ends the list
	String	'     Status    ]'
	dc.w	$0000,$0

PAttribOverall						;The Overall entry; PAttribOverallMask is read
	String	'[   Overall    ]'

PAttribOverallMask
	dc.w	$1FBA,$A
	String	'[   Energy     ]'
	dc.w	$0000,$2
	String	'[   Agility    ]'
	dc.w	$1000,$A
	String	'[    Speed     ]'
	dc.w	$0800,$A
	String	'[   Handed     ]'
	dc.w	$0040,$4
	String	'[Off. Awareness]'
	dc.w	$0400,$A
	String	'[Def. Awareness]'
	dc.w	$0200,$A
	String	'[  Shot Power  ]'
	dc.w	$0100,$A
	String	'[Shot  Accuracy]'
	dc.w	$0010,$A
	String	'[Pass  Accuracy]'
	dc.w	$0002,$A
	String	'[Stick Handling]'
	dc.w	$0020,$A
	String	'[    Weight    ]'
	dc.w	$2000,$6
	String	'[  Endurance   ]'
	dc.w	$0008,$A
	String	'[Aggressiveness]'

PAttribAggressMask					;The Aggressiveness entry
	dc.w	$0001,$A
	String	'[   Checking    '
	dc.w	$0080,$A
	dc.w	-1

GAttribColumns						;Goalie attribute columns, same format as PAttribColumns
	String	'     Status    ]'
	dc.w	$0000,$0

GAttribOverall						;The Overall entry; GAttribOverallMask is read
	String	'[   Overall    ]'

GAttribOverallMask
	dc.w	$130F,$A
	String	'[   Agility    ]'
	dc.w	$1000,$A
	String	'[    Speed     ]'
	dc.w	$0800,$A
	String	'[  Glove Hand  ]'
	dc.w	$0040,$4
	String	'[Def. Awareness]'
	dc.w	$0200,$A
	String	'[Off. Awareness]'
	dc.w	$0400,$A
	String	'[ Puck Control ]'
	dc.w	$0100,$A
	String	'[ Stick  Right ]'
	dc.w	$0008,$A
	String	'[  Stick Left  ]'
	dc.w	$0004,$A
	String	'[ Glove  Right ]'
	dc.w	$0002,$A
	String	'[  Glove Left  ]'
	dc.w	$0001,$A
	String	'[    Weight     '
	dc.w	$2000,$6
	dc.w	-1
