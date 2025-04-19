// All of the patterns for xenos to use during prep

///Defined seperate bcus radial menu draws the names of the options from the name of the datum, and "buildingpattern" isnt descriptive of a 2x2 cube
/datum/buildingpattern
	///A list of strings, where each one defines a layer. All patterns start from the top left corner, where X is a wall and O is empty space.
	var/list/pattern
	///A human readable name for the pattern, such as "2 by 2 square". Displayed as a overhead message when this pattern is selected
	var/overheadmsg
	/// offsets for placing the pattern
	var/offset_x = 0
	/// offsets for placing the pattern
	var/offset_y = 0

/datum/buildingpattern/square2x2
	overheadmsg = "2 by 2 Square"
	pattern = list(
		"XX",
		"XX",
	)


/datum/buildingpattern/cross3x3
	overheadmsg = "3 by 3 Cross (+)"
	pattern = list(
		"OXO",
		"XXX",
		"OXO",
	)
	offset_x = 1
	offset_y = -1

/datum/buildingpattern/square3x3
	overheadmsg = "3 by 3 Square"
	pattern = list(
		"XXX",
		"XXX",
		"XXX",
	)
	offset_x = 1
	offset_y = -1

/datum/buildingpattern/hollow_cross3x3
	overheadmsg = "3 by 3 Hollow Cross (+)"
	pattern = list(
		"OXO",
		"XOX",
		"OXO",
	)
	offset_x = 1
	offset_y = -1
