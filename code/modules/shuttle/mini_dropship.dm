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

/obj/machinery/computer/camera_advanced/shuttle_docker/minidropship
	name = "Tadpole navigation computer"
	desc = "Used to designate a precise transit location for the Tadpole."
	icon_state = "shuttlecomputer"
	req_one_access = list(ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LEADER)
	interaction_flags = INTERACT_MACHINE_TGUI
	shuttleId = "minidropship"
	lock_override = CAMERA_LOCK_GROUND
	shuttlePortId = "minidropship_custom"
	view_range = "26x26"
	x_offset = 0
	y_offset = 0
	open_prompt = FALSE
	/// Action of landing to a custom zone
	var/datum/action/innate/shuttledocker_land/land_action = new
	/// Amount of fuel remaining to hover
	var/fuel_left = 60
	/// The maximum fuel the dropship can hold
	var/fuel_max = 60
	/// The current flying state of the shuttle
	var/fly_state = SHUTTLE_ON_SHIP
	/// The next flying state of the shuttle
	var/next_fly_state = SHUTTLE_ON_SHIP
	/// The flying state we will have when reaching our destination
	var/destination_fly_state = SHUTTLE_ON_SHIP
	/// If the next destination is a transit
	var/to_transit = TRUE
	/// The id of the stationary docking port on the ship
	var/origin_port_id = "minidropship"
	/// The user of the ui
	var/mob/living/ui_user


/obj/machinery/computer/camera_advanced/shuttle_docker/minidropship/Initialize(mapload)
	. = ..()
	start_processing()
	set_light(3,3)

/obj/machinery/computer/camera_advanced/shuttle_docker/minidropship/process()
	if(fly_state == SHUTTLE_IN_ATMOSPHERE && destination_fly_state != SHUTTLE_ON_SHIP)
		fuel_left--
		if(fuel_left <= 0)
			return_to_ship()
		return
	if(fly_state == SHUTTLE_ON_SHIP && fuel_left < fuel_max)
		fuel_left++

/obj/machinery/computer/camera_advanced/shuttle_docker/minidropship/give_actions(mob/living/user)
	if(!user)
		if(!current_user)
			return
		user = current_user

	for(var/V in actions)
		var/datum/action/A = V
		A.remove_action(user)
	actions.Cut()
	
	if(off_action)
		off_action.target = user
		off_action.give_action(user)
		actions += off_action

	if(fly_state != SHUTTLE_IN_ATMOSPHERE)
		return
	
	if(rotate_action)
		rotate_action.target = user
		rotate_action.give_action(user)
		actions += rotate_action

	if(land_action)
		land_action.target = user
		land_action.give_action(user)
		actions += land_action

/obj/machinery/computer/camera_advanced/shuttle_docker/minidropship/shuttle_arrived()
	if(fly_state == next_fly_state)
		return
	fly_state = next_fly_state
	if(to_transit)
		to_transit = FALSE
		next_fly_state = destination_fly_state
		return
	give_actions()
	if(fly_state == SHUTTLE_IN_ATMOSPHERE)
		open_prompt = TRUE
		if(ui_user?.Adjacent(src))
			open_prompt(ui_user)
		return

///The action of taking off and sending the shuttle to the atmosphere
/obj/machinery/computer/camera_advanced/shuttle_docker/minidropship/proc/take_off()
	shuttle_port = SSshuttle.getShuttle(shuttleId)
	shuttle_port.shuttle = src
	if(fly_state == SHUTTLE_ON_GROUND)
		next_fly_state = SHUTTLE_IN_ATMOSPHERE
		shuttle_port.callTime = SHUTTLE_TAKEOFF_GROUND_CALLTIME
	else
		to_transit = TRUE
		shuttle_port.callTime = SHUTTLE_TAKEOFF_SHIP_CALLTIME
		next_fly_state = SHUTTLE_IN_SPACE
		destination_fly_state = SHUTTLE_IN_ATMOSPHERE
	SSshuttle.moveShuttleToTransit(shuttleId, TRUE)

///The action of sending the shuttle back to its shuttle port on main ship
/obj/machinery/computer/camera_advanced/shuttle_docker/minidropship/proc/return_to_ship()
	shuttle_port = SSshuttle.getShuttle(shuttleId)
	shuttle_port.shuttle = src
	to_transit = TRUE
	next_fly_state = SHUTTLE_IN_SPACE
	destination_fly_state = SHUTTLE_ON_SHIP
	if(!origin_port_id)
		return
	open_prompt = FALSE
	remove_eye_control(ui_user)
	SSshuttle.moveShuttle(shuttleId, origin_port_id, TRUE)

/obj/machinery/computer/camera_advanced/shuttle_docker/minidropship/ui_state(mob/user)
	return GLOB.dropship_state

/obj/machinery/computer/camera_advanced/shuttle_docker/minidropship/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui_user = user
		ui = new(user, src, "Minidropship", name)
		ui.open()

/obj/machinery/computer/camera_advanced/shuttle_docker/minidropship/ui_data(mob/user)
	. = list()
	.["fuel_left"] = fuel_left
	.["fuel_max"] = fuel_max
	.["fly_state"] = fly_state
	.["take_off_locked"] = !(fly_state == SHUTTLE_ON_GROUND || fly_state == SHUTTLE_ON_SHIP)
	.["return_to_ship_locked"] = (fly_state != SHUTTLE_IN_ATMOSPHERE)

/obj/machinery/computer/camera_advanced/shuttle_docker/minidropship/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	switch(action)
		if("take_off")
			take_off()
		if("return_to_ship")
			return_to_ship()

/datum/action/innate/shuttledocker_land
	name = "Land"
	action_icon = 'icons/mecha/actions_mecha.dmi'
	action_icon_state = "land"

/datum/action/innate/shuttledocker_land/Activate()
	if(QDELETED(target) || !isliving(target))
		return
	var/mob/living/C = target
	var/mob/camera/aiEye/remote/remote_eye = C.remote_control
	var/obj/machinery/computer/camera_advanced/shuttle_docker/minidropship/origin = remote_eye.origin
	if(!origin.placeLandingSpot(target))
		return
	origin.shuttle_port.callTime = SHUTTLE_LANDING_CALLTIME
	origin.next_fly_state = SHUTTLE_ON_GROUND
	origin.open_prompt = FALSE
	origin.remove_eye_control(origin.ui_user)
	SSshuttle.moveShuttleQuickToDock(origin.shuttleId, origin.my_port.id)
