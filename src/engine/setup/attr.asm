;	Roster attribute columns for the skaters and the goalies.

PAttribColumns						;Skater attribute columns. String header, then a long: high word = mask of
									;rating nibbles to average, low word = attribjmp offset (0 status, 2
									;energy, 4 handed, 6 weight, $A rating). A negative word ends the list
	String	'     Status    ]'
	dc.w	$0000,$0

PAttribOverall						;The Overall entry; PAttribOverallMask is read
	String	'[   Overall    ]'

PAttribOverallMask					;player attribute screen: overall rating label mask
	dc.w	$1FBA,$A
	String	'[   Energy     ]'
	dc.w	$0000,$2
	String	'[   Agility    ]'
PAttribSpeed			;Player attribute label row: Speed (mask, count, text)
	dc.w	$1000,$A
	String	'[    Speed     ]'
PAttribHanded			;Player attribute label row: Handed
	dc.w	$0800,$A
	String	'[   Handed     ]'
	dc.w	$0040,$4
	String	'[Off. Awareness]'
PAttribDefAwareness			;Player attribute label row: Defensive awareness
	dc.w	$0400,$A
	String	'[Def. Awareness]'
PAttribShotPower			;Player attribute label row: Shot power
	dc.w	$0200,$A
	String	'[  Shot Power  ]'
PAttribShotAccuracy			;Player attribute label row: Shot accuracy
	dc.w	$0100,$A
	String	'[Shot  Accuracy]'
PAttribPassAccuracy			;Player attribute label row: Pass accuracy
	dc.w	$0010,$A
	String	'[Pass  Accuracy]'
PAttribStickHandling			;Player attribute label row: Stick handling
	dc.w	$0002,$A
	String	'[Stick Handling]'
PAttribWeight			;Player attribute label row: Weight
	dc.w	$0020,$A
	String	'[    Weight    ]'
PAttribEndurance			;Player attribute label row: Endurance
	dc.w	$2000,$6
	String	'[  Endurance   ]'
PAttribAggressiveness			;Player attribute label row: Aggressiveness
	dc.w	$0008,$A
	String	'[Aggressiveness]'

PAttribAggressMask					;The Aggressiveness entry
	dc.w	$0001,$A
	String	'[   Checking    '
PAttribChecking			;Player attribute label row: Checking
	dc.w	$0080,$A
	dc.w	-1

GAttribColumns						;Goalie attribute columns, same format as PAttribColumns
	String	'     Status    ]'
	dc.w	$0000,$0

GAttribOverall						;The Overall entry; GAttribOverallMask is read
	String	'[   Overall    ]'

GAttribOverallMask					;goalie attribute screen: overall rating label mask
	dc.w	$130F,$A
	String	'[   Agility    ]'
GAttribSpeed			;Goalie attribute label row: Speed
	dc.w	$1000,$A
	String	'[    Speed     ]'
	dc.w	$0800,$A
	String	'[  Glove Hand  ]'
	dc.w	$0040,$4
	String	'[Def. Awareness]'
GAttribOffAwareness			;Goalie attribute label row: Offensive awareness
	dc.w	$0200,$A
	String	'[Off. Awareness]'
	dc.w	$0400,$A
	String	'[ Puck Control ]'
GAttribStickRight			;Goalie attribute label row: Stick right
	dc.w	$0100,$A
	String	'[ Stick  Right ]'
GAttribStickLeft			;Goalie attribute label row: Stick left
	dc.w	$0008,$A
	String	'[  Stick Left  ]'
GAttribGloveRight			;Goalie attribute label row: Glove right
	dc.w	$0004,$A
	String	'[ Glove  Right ]'
GAttribGloveLeft			;Goalie attribute label row: Glove left
	dc.w	$0002,$A
	String	'[  Glove Left  ]'
GAttribWeight			;Goalie attribute label row: Weight
	dc.w	$0001,$A
	String	'[    Weight     '
	dc.w	$2000,$6
	dc.w	-1
