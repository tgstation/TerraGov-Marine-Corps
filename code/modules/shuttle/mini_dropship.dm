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
	density = FALSE
	interaction_flags = INTERACT_MACHINE_TGUI
	resistance_flags = RESIST_ALL
	shuttleId = "minidropship"
	lock_override = CAMERA_LOCK_GROUND
	shuttlePortId = "minidropship_custom"
	view_range = "26x26"
	x_offset = 0
	y_offset = 0
	open_prompt = FALSE
	/// Action of landing to a custom zone
	var/datum/action/innate/shuttledocker_land/land_action
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
	/// Sound loop when the shuttle is hovering in atmosphere
	var/datum/looping_sound/shuttle_still_flight/shuttle_still_sound

/obj/machinery/computer/camera_advanced/shuttle_docker/minidropship/Initialize(mapload)
	. = ..()
	start_processing()
	set_light(3,3)
	land_action = new
	shuttle_still_sound = new(list(src), FALSE)
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/camera_advanced/shuttle_docker/minidropship/LateInitialize()
	. = ..()
	shuttle_port = SSshuttle.getShuttle(shuttleId)

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

	for(var/datum/action/action_from_shuttle_docker AS in actions)
		action_from_shuttle_docker.remove_action(user)
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
	if(fly_state == SHUTTLE_IN_SPACE)
		set_transit_turf(FALSE)
	if(to_transit)
		to_transit = FALSE
		next_fly_state = destination_fly_state
		return
	give_actions()
	if(fly_state != SHUTTLE_IN_ATMOSPHERE)
		shuttle_still_sound.stop()
		return
	set_transit_turf(TRUE)
	open_prompt = TRUE
	shuttle_still_sound.start()
	if(ui_user?.Adjacent(src))
		open_prompt(ui_user)


///Change the icons of the space turf in the transit
/obj/machinery/computer/camera_advanced/shuttle_docker/minidropship/proc/set_transit_turf(in_atmos = FALSE)
	shuttle_port.assigned_transit.reserved_area.set_turf_type(in_atmos ? /turf/open/space/transit/atmos : /turf/open/space/transit)


///The action of taking off and sending the shuttle to the atmosphere
/obj/machinery/computer/camera_advanced/shuttle_docker/minidropship/proc/take_off()
	shuttle_port = SSshuttle.getShuttle(shuttleId)
	/*if(!(shuttle_port.shuttle_flags & GAMEMODE_IMMUNE) && world.time < SSticker.round_start_time + SSticker.mode.deploy_time_lock)
		to_chat(ui_user, "<span class='warning'>The engines are still refueling.</span>")
		return*/
	shuttle_port.shuttle_computer = src
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
	shuttle_port.shuttle_computer = src
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
		if(ui_user)
			UnregisterSignal(ui_user, COMSIG_PARENT_QDELETING)
		ui_user = user
		RegisterSignal(ui_user, COMSIG_PARENT_QDELETING, .proc/clean_ui_user)
		ui = new(user, src, "Minidropship", name)
		ui.open()

/obj/machinery/computer/camera_advanced/shuttle_docker/minidropship/proc/clean_ui_user()
	UnregisterSignal(ui_user, COMSIG_PARENT_QDELETING)
	ui_user = null

/obj/machinery/computer/camera_advanced/shuttle_docker/minidropship/ui_data(mob/user)
	. = list()
	if(!shuttle_port)
		shuttle_port = SSshuttle.getShuttle(shuttleId)
	.["fuel_left"] = fuel_left
	.["fuel_max"] = fuel_max
	.["fly_state"] = fly_state
	.["take_off_locked"] = ( !(fly_state == SHUTTLE_ON_GROUND || fly_state == SHUTTLE_ON_SHIP) || shuttle_port?.mode != SHUTTLE_IDLE)
	.["return_to_ship_locked"] = (fly_state != SHUTTLE_IN_ATMOSPHERE)
	var/obj/docking_port/mobile/marine_dropship/shuttle = shuttle_port
	.["equipment_data"] = list()
	var/element_nbr = 1
	for(var/X in shuttle?.equipments)
		var/obj/structure/dropship_equipment/E = X
		.["equipment_data"] += list(list("name"= sanitize(copytext(E.name,1,MAX_MESSAGE_LEN)), "eqp_tag" = element_nbr, "is_weapon" = (E.dropship_equipment_flags & IS_WEAPON), "is_interactable" = (E.dropship_equipment_flags & IS_INTERACTABLE)))
		element_nbr++


/obj/machinery/computer/camera_advanced/shuttle_docker/minidropship/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	switch(action)
		if("take_off")
			take_off()
		if("return_to_ship")
			return_to_ship()
		if("equip_interact")
			var/base_tag = text2num(params["equip_interact"])
			var/obj/docking_port/mobile/marine_dropship/shuttle = shuttle_port
			var/obj/structure/dropship_equipment/E = shuttle.equipments[base_tag]
			E.linked_console = src
			E.equipment_interact(usr)
/datum/action/innate/shuttledocker_land
	name = "Land"
	action_icon = 'icons/mecha/actions_mecha.dmi'
	action_icon_state = "land"

/datum/action/innate/shuttledocker_land/Activate()
	var/mob/C = target
	var/mob/camera/aiEye/remote/remote_eye = C.remote_control
	var/obj/machinery/computer/camera_advanced/shuttle_docker/minidropship/origin = remote_eye.origin
	if(!origin.placeLandingSpot(target))
		return
	origin.shuttle_port.callTime = SHUTTLE_LANDING_CALLTIME
	origin.next_fly_state = SHUTTLE_ON_GROUND
	origin.open_prompt = FALSE
	origin.remove_eye_control(origin.ui_user)
	origin.shuttle_port.set_mode(SHUTTLE_CALL)
	SSshuttle.moveShuttleToDock(origin.shuttleId, origin.my_port, TRUE)
