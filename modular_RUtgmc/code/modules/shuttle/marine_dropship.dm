/obj/docking_port/stationary/marine_dropship/hangar/one
	name = "Shipside 'Normandy' Hangar Pad"
	id = SHUTTLE_NORMANDY
	roundstart_template = /datum/map_template/shuttle/dropship_one

/obj/docking_port/stationary/marine_dropship/hangar/two
	name = "Shipside 'Alamo' Hangar Pad"
	id = SHUTTLE_ALAMO
	roundstart_template = /datum/map_template/shuttle/dropship_two
	dheight = 6
	dwidth = 4
	height = 13
	width = 9

/obj/docking_port/mobile/marine_dropship/one
	name = "Normandy"
	id = SHUTTLE_NORMANDY
	control_flags = SHUTTLE_MARINE_PRIMARY_DROPSHIP

/obj/docking_port/mobile/marine_dropship/two
	name = "Alamo"
	id = SHUTTLE_ALAMO
	control_flags = SHUTTLE_MARINE_PRIMARY_DROPSHIP
	callTime = 28 SECONDS //smaller shuttle go whoosh
	rechargeTime = 1.5 MINUTES
	dheight = 6
	dwidth = 4
	height = 13
	width = 9

/obj/machinery/computer/shuttle/shuttle_control/dropship
	name = "\improper 'Normandy' dropship console"
	desc = "The remote controls for the 'Normandy' Dropship. Named after a department in France, noteworthy for the famous naval invasion of Normandy on the 6th of June 1944, a bloody but decisive victory in World War II and the campaign for the Liberation of France."
	shuttleId = SHUTTLE_NORMANDY
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "shuttle"
	resistance_flags = RESIST_ALL
	req_one_access = list(ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LEADER) // TLs can only operate the remote console
	possible_destinations = "lz1;lz2;alamo"
	compatible_control_flags = SHUTTLE_MARINE_PRIMARY_DROPSHIP


/obj/machinery/computer/shuttle/shuttle_control/dropship/two
	name = "\improper 'Alamo' dropship console"
	desc = "The remote controls for the 'Alamo' Dropship. Named after the Alamo Mission, stage of the Battle of the Alamo in the United States' state of Texas in the Spring of 1836. The defenders held to the last, encouraging other Texans to rally to the flag."
	shuttleId = SHUTTLE_ALAMO
	possible_destinations = "lz1;lz2;normandy;alamo"
