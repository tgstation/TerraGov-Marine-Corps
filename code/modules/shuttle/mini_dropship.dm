/obj/docking_port/stationary/marine_dropship/minidropship
	name = "Minidropship hangar pad"
	id = "minidropship"
	roundstart_template = /datum/map_template/shuttle/minidropship

/obj/docking_port/mobile/marine_dropship/minidropship
	name = "Tadpole"
	id = "minidropship"
	dwidth = 0
	dheight = 0
	width = 7
	height = 9
	callTime = 15 SECONDS
	rechargeTime = 3 MINUTES

/obj/machinery/computer/camera_advanced/shuttle_docker/minidropship
	name = "Tadpole navigation computer"
	desc = "Used to designate a precise transit location for the Tadpole."
	icon_state = "maptable"
	resistance_flags = UNACIDABLE|INDESTRUCTIBLE
	req_one_access = list(ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LEADER)
	shuttleId = "minidropship"
	lock_override = CAMERA_LOCK_GROUND
	shuttlePortId = "minidropship_custom"
	view_range = "26x26"
	x_offset = 0
	y_offset = 0
	designate_time = 100

// No lockable side or rear doors
/obj/machinery/computer/shuttle/minidropship
	resistance_flags = UNACIDABLE|INDESTRUCTIBLE
	req_one_access = list(ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LEADER)
	shuttleId = "minidropship"
	possible_destinations = "minidropship;minidropship_custom"

/obj/machinery/computer/dropship_weapons/minidropship
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "cameras"
	name = "\improper 'Tadpole' weapons controls"
	shuttle_tag = "minidropship"
	req_access = list(ACCESS_MARINE_DROPSHIP)
