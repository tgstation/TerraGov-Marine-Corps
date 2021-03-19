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
	resistance_flags = INDESTRUCTIBLE
	req_one_access = list(ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LEADER)
	interaction_flags = INTERACT_MACHINE_TGUI
	shuttleId = "minidropship"
	lock_override = CAMERA_LOCK_GROUND
	shuttlePortId = "minidropship_custom"
	view_range = "26x26"
	x_offset = 0
	y_offset = 0
	origin_port_id = "minidropship"
	open_prompt = FALSE
	/// Amount of fuel remaining to hover
	var/fuel_left = 100
	/// The maximum fuel the dropship can hold
	var/fuel_max = 100

/obj/machinery/computer/camera_advanced/shuttle_docker/minidropship/Initialize(mapload)
	. = ..()
	start_processing()

/obj/machinery/computer/camera_advanced/shuttle_docker/minidropship/process()
	if(fly_state == SHUTTLE_IN_ATMOSPHERE)
		fuel_left--
		if(fuel_left <= 0)
			return_to_ship()
		return
	if(fly_state == SHUTTLE_ON_SHIP && fuel_left < fuel_max)
		fuel_left++

/obj/machinery/computer/camera_advanced/shuttle_docker/minidropship/proc/take_off()
	shuttle_port = SSshuttle.getShuttle(shuttleId)
	shuttle_port.shuttle = src
	if(fly_state == SHUTTLE_ON_GROUND)
		to_transit = TRUE
		next_fly_state = SHUTTLE_IN_ATMOSPHERE
		shuttle_port.callTime = SHUTTLE_TAKEOFF_GROUND_CALLTIME
	else
		shuttle_port.callTime = SHUTTLE_TAKEOFF_SHIP_CALLTIME
		next_fly_state = SHUTTLE_IN_SPACE
		destination_fly_state = SHUTTLE_IN_ATMOSPHERE
	SSshuttle.moveShuttleToTransit(shuttleId, TRUE)

/obj/machinery/computer/camera_advanced/shuttle_docker/minidropship/proc/return_to_ship()
	shuttle_port = SSshuttle.getShuttle(shuttleId)
	shuttle_port.shuttle = src
	to_transit = TRUE
	next_fly_state = SHUTTLE_IN_SPACE
	destination_fly_state = SHUTTLE_ON_SHIP
	if(!origin_port_id)
		return
	SSshuttle.moveShuttle(shuttleId, origin_port_id, TRUE)

/obj/machinery/computer/camera_advanced/shuttle_docker/minidropship/ui_state(mob/user)
	return GLOB.always_state

/obj/machinery/computer/camera_advanced/shuttle_docker/minidropship/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui_user = user
		ui = new(user, src, "Minidropship", name)
		ui.open()

/obj/machinery/computer/camera_advanced/shuttle_docker/minidropship/ui_data(mob/user)
	. = ..()
	. = list()
	.["fuel_left"] = fuel_left
	.["fuel_max"] = fuel_max
	.["fly_state"] = fly_state
	.["take_off_locked"] = (fly_state == SHUTTLE_IN_ATMOSPHERE || next_fly_state == SHUTTLE_IN_ATMOSPHERE)
	.["return_to_ship_locked"] = (fly_state != SHUTTLE_IN_ATMOSPHERE)

/obj/machinery/computer/camera_advanced/shuttle_docker/minidropship/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	switch(action)
		if("take_off")
			take_off()
		if("return_to_ship")
			return_to_ship()
	