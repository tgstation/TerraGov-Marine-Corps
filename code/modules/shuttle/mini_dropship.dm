/obj/docking_port/stationary/marine_dropship/minidropship
	name = "Minidropship hangar pad"
	id = SHUTTLE_TADPOLE
	roundstart_template = null

/obj/docking_port/mobile/marine_dropship/minidropship
	name = "Tadpole"
	id = SHUTTLE_TADPOLE
	dwidth = 0
	dheight = 0
	width = 7
	height = 9
	rechargeTime = 0

/obj/machinery/computer/camera_advanced/shuttle_docker/minidropship
	name = "Tadpole navigation computer"
	desc = "Used to designate a precise transit location for the Tadpole."
	icon_state = "shuttlecomputer"
	screen_overlay = "shuttlecomputer_screen"
	req_one_access = list(ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LEADER)
	density = FALSE
	interaction_flags = INTERACT_OBJ_UI
	resistance_flags = RESIST_ALL
	shuttleId = SHUTTLE_TADPOLE
	lock_override = CAMERA_LOCK_GROUND
	shuttlePortId = "minidropship_custom"
	view_range = "26x26"
	x_offset = 0
	y_offset = 0
	open_prompt = FALSE
	nvg_vision_mode = FALSE
	/// Action of landing to a custom zone
	var/datum/action/innate/shuttledocker_land/land_action
	/// The current flying state of the shuttle
	var/fly_state = SHUTTLE_ON_SHIP
	/// The next flying state of the shuttle
	var/next_fly_state = SHUTTLE_ON_SHIP
	/// The flying state we will have when reaching our destination
	var/destination_fly_state = SHUTTLE_ON_SHIP
	/// If the next destination is a transit
	var/to_transit = TRUE
	/// The id of the stationary docking port on the ship
	var/origin_port_id = SHUTTLE_TADPOLE
	/// The user of the ui
	var/mob/living/ui_user
	/// How long before you can launch tadpole after a landing
	var/launching_delay = 10 SECONDS
	///Minimap for use while in landing cam mode
	var/datum/action/minimap/marine/external/tadmap

/obj/machinery/computer/camera_advanced/shuttle_docker/minidropship/Initialize(mapload)
	..()
	start_processing()
	set_light(3,3, LIGHT_COLOR_RED)
	land_action = new
	tadmap = new
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/camera_advanced/shuttle_docker/minidropship/Destroy()
	QDEL_NULL(land_action)
	QDEL_NULL(tadmap)
	return ..()

/obj/machinery/computer/camera_advanced/shuttle_docker/minidropship/CreateEye()
	. = ..()
	tadmap.override_locator(eyeobj)

/obj/machinery/computer/camera_advanced/shuttle_docker/minidropship/LateInitialize()
	shuttle_port = SSshuttle.getShuttle(shuttleId)

/obj/machinery/computer/camera_advanced/shuttle_docker/minidropship/give_actions(mob/living/user)
	if(!user)
		return

	for(var/datum/action/action_from_shuttle_docker AS in actions)
		action_from_shuttle_docker.remove_action(user)
	actions.Cut()

	if(off_action)
		off_action.target = user
		off_action.give_action(user)
		actions += off_action

	if(tadmap)
		tadmap.target = user
		tadmap.give_action(user)
		actions += tadmap

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
		shuttle_port.assigned_transit.reserved_area.set_turf_type(/turf/open/space/transit)
	if(to_transit)
		to_transit = FALSE
		next_fly_state = destination_fly_state
		return
	if(fly_state == SHUTTLE_ON_GROUND)
		TIMER_COOLDOWN_START(src, COOLDOWN_TADPOLE_LAUNCHING, launching_delay)
	if(fly_state != SHUTTLE_IN_ATMOSPHERE)
		return
	shuttle_port.assigned_transit.reserved_area.set_turf_type(/turf/open/space/transit/atmos)
	open_prompt = TRUE

///The action of taking off and sending the shuttle to the atmosphere
/obj/machinery/computer/camera_advanced/shuttle_docker/minidropship/proc/take_off()
	shuttle_port = SSshuttle.getShuttle(shuttleId)
	#ifndef TESTING
	if(!(shuttle_port.shuttle_flags & GAMEMODE_IMMUNE) && world.time < SSticker.round_start_time + SSticker.mode.deploy_time_lock)
		to_chat(ui_user, span_warning("The mothership is too far away from the theatre of operation, we cannot take off."))
		return
	#endif
	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_TADPOLE_LAUNCHING))
		to_chat(ui_user, span_warning("The dropship's engines are not ready yet"))
		return
	TIMER_COOLDOWN_START(src, COOLDOWN_TADPOLE_LAUNCHING, launching_delay) // To stop spamming
	shuttle_port.shuttle_computer = src
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_TADPOLE_LAUNCHED)
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
	clean_ui_user()
	SSshuttle.moveShuttle(shuttleId, origin_port_id, TRUE)

/// Toggle the vision between small nightvision and turf vision
/obj/machinery/computer/camera_advanced/shuttle_docker/minidropship/proc/toggle_nvg()
	if(!check_hovering_spot(eyeobj?.loc))
		to_chat(ui_user, span_warning("Can not toggle night vision mode in caves"))
		return
	nvg_vision_mode = !nvg_vision_mode

/obj/machinery/computer/camera_advanced/shuttle_docker/minidropship/attack_alien(mob/living/carbon/xenomorph/X, damage_amount, damage_type, damage_flag, effects, armor_penetration, isrightclick)
	. = ..()
	if(machine_stat & BROKEN)
		return
	if(X.status_flags & INCORPOREAL)
		return
	X.visible_message("[X] begins to slash delicately at the computer",
	"We start slashing delicately at the computer. This will take a while.")
	if(!do_after(X, 10 SECONDS, NONE, src, BUSY_ICON_DANGER, BUSY_ICON_HOSTILE))
		return
	visible_message("The inner wiring is visible, it can be slashed!")
	X.visible_message("[X] continue to slash at the computer",
	"We continue slashing at the computer. If we stop now we will have to start all over again.")
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	if(!do_after(X, 10 SECONDS, NONE, src, BUSY_ICON_DANGER, BUSY_ICON_HOSTILE))
		return
	visible_message("The wiring is destroyed, nobody will be able to repair this computer!")
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_MINI_DROPSHIP_DESTROYED, src)
	var/datum/effect_system/spark_spread/s2 = new /datum/effect_system/spark_spread
	s2.set_up(3, 1, src)
	s2.start()
	set_broken()
	open_prompt = FALSE
	clean_ui_user()

	if(fly_state == SHUTTLE_IN_ATMOSPHERE && last_valid_ground_port)
		visible_message("Autopilot detects loss of helm control. INITIATING EMERGENCY LANDING!")
		shuttle_port.callTime = SHUTTLE_LANDING_CALLTIME
		next_fly_state = SHUTTLE_ON_GROUND
		shuttle_port.set_mode(SHUTTLE_CALL)
		SSshuttle.moveShuttleToDock(shuttleId, last_valid_ground_port, TRUE)
		return

	if(next_fly_state == SHUTTLE_IN_ATMOSPHERE)
		shuttle_port.set_idle() // don't go up with a broken console, cencel spooling
		visible_message("Autopilot detects loss of helm control. Halting take off!")

/obj/machinery/computer/camera_advanced/shuttle_docker/minidropship/can_interact(mob/user)
	if(machine_stat & BROKEN)
		to_chat(user, span_warning("The [src] blinks and lets out a crackling noise. Its broken!"))
		return
	return ..()

/obj/machinery/computer/camera_advanced/shuttle_docker/minidropship/ui_state(mob/user)
	return GLOB.dropship_state

/obj/machinery/computer/camera_advanced/shuttle_docker/minidropship/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(ui_user)
		return

	if(!ui)
		ui_user = user
		RegisterSignals(ui_user, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED), PROC_REF(clean_ui_user))
		ui = new(user, src, "Minidropship", name)
		ui.open()

/obj/machinery/computer/camera_advanced/shuttle_docker/minidropship/ui_close(mob/user)
	. = ..()
	clean_ui_user()

/// Set ui_user to null to prevent hard del
/obj/machinery/computer/camera_advanced/shuttle_docker/minidropship/proc/clean_ui_user()
	SIGNAL_HANDLER
	if(ui_user)
		remove_eye_control(ui_user)
		UnregisterSignal(ui_user, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED))
		ui_user = null

/obj/machinery/computer/camera_advanced/shuttle_docker/minidropship/ui_data(mob/user)
	. = list()
	if(!shuttle_port)
		shuttle_port = SSshuttle.getShuttle(shuttleId)
	.["fly_state"] = fly_state
	.["take_off_locked"] = ( !(fly_state == SHUTTLE_ON_GROUND || fly_state == SHUTTLE_ON_SHIP) || shuttle_port?.mode != SHUTTLE_IDLE)
	.["return_to_ship_locked"] = (fly_state != SHUTTLE_IN_ATMOSPHERE || shuttle_port?.mode != SHUTTLE_IDLE)
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
		if("toggle_nvg")
			toggle_nvg()
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
	if(origin.shuttle_port.mode != SHUTTLE_IDLE)
		to_chat(owner, span_warning("The shuttle is not ready to land yet!"))
		return
	if(!origin.placeLandingSpot(target))
		to_chat(owner, span_warning("You cannot land here."))
		return
	origin.shuttle_port.callTime = SHUTTLE_LANDING_CALLTIME
	origin.next_fly_state = SHUTTLE_ON_GROUND
	origin.open_prompt = FALSE
	origin.clean_ui_user()
	origin.shuttle_port.set_mode(SHUTTLE_CALL)
	origin.last_valid_ground_port = origin.my_port
	SSshuttle.moveShuttleToDock(origin.shuttleId, origin.my_port, TRUE)
