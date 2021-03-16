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
	height = 8

/obj/machinery/computer/camera_advanced/shuttle_docker/minidropship
	name = "Tadpole navigation computer"
	desc = "Used to designate a precise transit location for the Tadpole."
	icon_state = "shuttlecomputer"
	resistance_flags = UNACIDABLE|INDESTRUCTIBLE
	density = FALSE
	req_one_access = list(ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LEADER)
	shuttleId = "minidropship"
	lock_override = CAMERA_LOCK_GROUND
	shuttlePortId = "minidropship_custom"
	view_range = "26x26"
	x_offset = 0
	y_offset = 0
	origin_port_id = "minidropship"
	/// Amount of fuel remaining to hover
	var/fuel_left = 100
	/// The maximum fuel the dropship can hold
	var/max_fuel = 100

/obj/machinery/computer/camera_advanced/shuttle_docker/minidropship/Initialize(mapload)
	. = ..()
	start_processing()

/obj/machinery/computer/camera_advanced/shuttle_docker/minidropship/process()
	if(fly_state == SHUTTLE_IN_ATMOSPHERE)
		fuel_left--
		if(fuel_left <= 0)
			to_transit = TRUE
			next_fly_state = SHUTTLE_ON_SHIP
			SSshuttle.moveShuttle(shuttleId, origin_port_id, TRUE)
		return
	if(fly_state == SHUTTLE_ON_SHIP && fuel_left < max_fuel)
		fuel_left++
