// marine dropships
/obj/docking_port/stationary/marine_dropship
	name = "marine dropship"
	dir = SOUTH
	dwidth = 5
	width = 11
	height = 21

/obj/docking_port/stationary/marine_dropship/hangar/one
	id = "alamo"
	roundstart_template = /datum/map_template/shuttle/dropship/one

/obj/docking_port/stationary/marine_dropship/hangar/two
	id = "normandy"
	roundstart_template = /datum/map_template/shuttle/dropship/two

/obj/docking_port/mobile/marine_dropship
	name = "marine dropship"
	dir = SOUTH
	dwidth = 5
	width = 11
	height = 21

/obj/docking_port/mobile/marine_dropship/one
	id = "alamo"

/obj/docking_port/mobile/marine_dropship/two
	id = "normandy"

// ************************************************	//
//													//
// 			dropship specific objs and turfs		//
//													//
// ************************************************	//

// half-tile structure pieces
/obj/structure/dropship_piece
	icon = 'icons/obj/structures/dropship_structures.dmi'
	density = TRUE
	unacidable = TRUE
	opacity = TRUE

/obj/structure/dropship_piece/ex_act(severity)
	return

/obj/structure/dropship_piece/one
	name = "\improper Alamo"

/obj/structure/dropship_piece/one/front
	icon_state = "brown_front"
	opacity = FALSE

/obj/structure/dropship_piece/one/front/right
	icon_state = "brown_fr"

/obj/structure/dropship_piece/one/front/left
	icon_state = "brown_fl"


/obj/structure/dropship_piece/one/cockpit/left
	icon_state = "brown_cockpit_fl"

/obj/structure/dropship_piece/one/cockpit/right
	icon_state = "brown_cockpit_fr"

// control computer
/obj/machinery/computer/shuttle/marine_dropship
	icon = 'icons/Marine/shuttle-parts.dmi'
	icon_state = "console"
	unacidable = TRUE
	exproof = TRUE
	req_one_access = list(ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LEADER) // TLs can only operate the remote console

/obj/machinery/computer/shuttle/marine_dropship/one
	name = "\improper 'Alamo' flight controls"
	desc = "The flight controls for the 'Alamo' Dropship. Named after the Alamo Mission, stage of the Battle of the Alamo in the United States' state of Texas in the Spring of 1836. The defenders held to the last, encouraging other Texians to rally to the flag."

/obj/machinery/computer/shuttle/marine_dropship/two
	name = "\improper 'Normandy' flight controls"
	desc = "The flight controls for the 'Normandy' Dropship. Named after a department in France, noteworthy for the famous naval invasion of Normandy on the 6th of June 1944, a bloody but decisive victory in World War II and the campaign for the Liberation of France."


/obj/machinery/computer/shuttle_control
	name = "shuttle control console"
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "shuttle"

//Dropship control console

/obj/machinery/computer/shuttle_control/dropship1
	name = "\improper 'Alamo' dropship console"
	desc = "The remote controls for the 'Alamo' Dropship. Named after the Alamo Mission, stage of the Battle of the Alamo in the United States' state of Texas in the Spring of 1836. The defenders held to the last, encouraging other Texans to rally to the flag."
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "shuttle"

	unacidable = 1
	exproof = 1
	req_one_access = list(ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LEADER) // TLs can only operate the remote console

/obj/machinery/computer/shuttle_control/dropship1/onboard
	name = "\improper 'Alamo' flight controls"
	desc = "The flight controls for the 'Alamo' Dropship. Named after the Alamo Mission, stage of the Battle of the Alamo in the United States' state of Texas in the Spring of 1836. The defenders held to the last, encouraging other Texians to rally to the flag."
	icon = 'icons/Marine/shuttle-parts.dmi'
	icon_state = "console"
	req_access = list(ACCESS_MARINE_DROPSHIP)

/obj/machinery/computer/shuttle_control/dropship2
	name = "\improper 'Normandy' dropship console"
	desc = "The remote controls for the 'Normandy' Dropship. Named after a department in France, noteworthy for the famous naval invasion of Normandy on the 6th of June 1944, a bloody but decisive victory in World War II and the campaign for the Liberation of France."
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "shuttle"
	unacidable = 1
	exproof = 1
	req_one_access = list(ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LEADER)

/obj/machinery/computer/shuttle_control/dropship2/onboard
	name = "\improper 'Normandy' flight controls"
	desc = "The flight controls for the 'Normandy' Dropship. Named after a department in France, noteworthy for the famous naval invasion of Normandy on the 6th of June 1944, a bloody but decisive victory in World War II and the campaign for the Liberation of France."
	icon = 'icons/Marine/shuttle-parts.dmi'
	icon_state = "console"
	req_access = list(ACCESS_MARINE_DROPSHIP)

/obj/machinery/computer/shuttle_control/almayer/hangar
	name = "Elevator Console"
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "supply"
