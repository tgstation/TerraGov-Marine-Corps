/obj/docking_port/stationary/shuttle/minidropship
	name = "Minidropship hangar pad"
	id = SHUTTLE_MINI
	roundstart_template = null

/obj/docking_port/mobile/marine_dropship/minidropship
	name = "Tadpole"
	id = SHUTTLE_MINI
	dwidth = 0
	dheight = 0
	width = 7
	height = 9
	rechargeTime = 0

/obj/machinery/computer/camera_advanced/shuttle_docker/flyable
	name = "Tadpole navigation computer"
	desc = "Used to designate a precise transit location for the Tadpole."
	icon_state = "shuttlecomputer"
	screen_overlay = "shuttlecomputer_screen"
	req_access = list(ACCESS_MARINE_SHUTTLE)
	density = FALSE
	interaction_flags = INTERACT_OBJ_UI
	resistance_flags = RESIST_ALL
	shuttleId = SHUTTLE_MINI
	lock_override = CAMERA_LOCK_GROUND
	shuttlePortId = "minidropship_custom"
	open_prompt = FALSE
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
	var/origin_port_id = SHUTTLE_MINI
	/// The user of the ui
	var/mob/living/ui_user
	/// How long before you can launch tadpole after a landing
	var/launching_delay = 10 SECONDS
	///Minimap for use while in landing cam mode
	var/datum/action/minimap/marine/external/tadmap

/obj/machinery/computer/camera_advanced/shuttle_docker/flyable/Initialize(mapload)
	..()
	start_processing()
	set_light(3,3, LIGHT_COLOR_RED)
	update_offsets()
	land_action = new
	tadmap = new
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/camera_advanced/shuttle_docker/flyable/Destroy()
	QDEL_NULL(land_action)
	QDEL_NULL(tadmap)
	return ..()

/obj/machinery/computer/camera_advanced/shuttle_docker/flyable/setDir(newdir)
	. = ..()
	update_offsets()

/obj/machinery/computer/camera_advanced/shuttle_docker/flyable/proc/update_offsets()
	switch(dir)
		if(NORTH)
			pixel_y = -12
			pixel_x = 0
			layer = ABOVE_MOB_LAYER
		if(SOUTH)
			pixel_y = 12
			pixel_x = 0
			layer = BELOW_OBJ_LAYER	//Appear below every other item and object so it can look cluttered if there are items on the tile
		if(EAST)
			pixel_y = 0
			pixel_x = -12
			layer = UPPER_ITEM_LAYER
		if(WEST)
			pixel_y = 0
			pixel_x = 12
			layer = UPPER_ITEM_LAYER

/obj/machinery/computer/camera_advanced/shuttle_docker/flyable/CreateEye()
	. = ..()
	tadmap.override_locator(eyeobj)

/obj/machinery/computer/camera_advanced/shuttle_docker/flyable/LateInitialize()
	assign_shuttle()

/obj/machinery/computer/camera_advanced/shuttle_docker/flyable/give_actions(mob/living/user)
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

/obj/machinery/computer/camera_advanced/shuttle_docker/flyable/shuttle_arrived()
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
/obj/machinery/computer/camera_advanced/shuttle_docker/flyable/proc/take_off(remote_controlled)
	assign_shuttle()

	#ifndef TESTING
	if(!(shuttle_port.shuttle_flags & GAMEMODE_IMMUNE) && world.time < SSticker.round_start_time + SSticker.mode.deploy_time_lock)
		if(!remote_controlled)
			to_chat(ui_user, span_warning("The mothership is too far away from the theatre of operation, we cannot take off."))
		return
	#endif

	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_TADPOLE_LAUNCHING))
		if(!remote_controlled)
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
/obj/machinery/computer/camera_advanced/shuttle_docker/flyable/proc/return_to_ship()
	assign_shuttle()
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
/obj/machinery/computer/camera_advanced/shuttle_docker/flyable/proc/toggle_nvg()
	if(!check_hovering_spot(eyeobj?.loc))
		to_chat(ui_user, span_warning("Can not toggle night vision mode in caves"))
		return
	nvg_vision_mode = !nvg_vision_mode

/obj/machinery/computer/camera_advanced/shuttle_docker/flyable/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, armor_penetration = xeno_attacker.xeno_caste.melee_ap, isrightclick = FALSE)
	if(machine_stat & BROKEN)
		return
	if(xeno_attacker.status_flags & INCORPOREAL)
		return

	xeno_sabotage(xeno_attacker)

///Handle what happens when a xenomorph clicks this console
/obj/machinery/computer/camera_advanced/shuttle_docker/flyable/proc/xeno_sabotage(mob/living/carbon/xenomorph/saboteur)
	saboteur.visible_message("[saboteur] begins to slash delicately at the computer",
	"We start slashing delicately at the computer. This will take a while.")
	if(!do_after(saboteur, 10 SECONDS, NONE, src, BUSY_ICON_DANGER, BUSY_ICON_HOSTILE))
		return

	visible_message("The inner wiring is visible, it can be slashed!")
	saboteur.visible_message("[saboteur] continue to slash at the computer",
	"We continue slashing at the computer. If we stop now we will have to start all over again.")
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	if(!do_after(saboteur, 10 SECONDS, NONE, src, BUSY_ICON_DANGER, BUSY_ICON_HOSTILE))
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

/obj/machinery/computer/camera_advanced/shuttle_docker/flyable/can_interact(mob/user)
	if(machine_stat & BROKEN)
		to_chat(user, span_warning("The [src] blinks and lets out a crackling noise. Its broken!"))
		return
	return ..()

/obj/machinery/computer/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return
	if(!istype(I,/obj/item/circuitboard/tadpole))
		return
	var/repair_time = 30 SECONDS
	if(!(machine_stat & BROKEN))
		to_chat(user,span_notice("The circuits don't need replacing"))
		return
	playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
	if(user.skills.getRating(SKILL_ENGINEER) < SKILL_ENGINEER_EXPERT)
		user.visible_message(span_notice("[user] fumbles around figuring out how to replace the electronics."),
		span_notice("You fumble around figuring out how to replace the electronics."))
		repair_time += 5 SECONDS * ( SKILL_ENGINEER_EXPERT - user.skills.getRating(SKILL_ENGINEER) )
		if(!do_after(user, repair_time, NONE, src, BUSY_ICON_UNSKILLED))
			return
	else
		user.visible_message(span_notice("[user] begins replacing the electronics"),
		span_notice("You begin replacing the electronics"))
		if(!do_after(user,repair_time,NONE,src,BUSY_ICON_GENERIC))
			return
	user.visible_message(span_notice("[user] replaces the electronics."),
	span_notice("You replace the electronics"))
	playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
	repair()
	qdel(I)

/obj/machinery/computer/camera_advanced/shuttle_docker/flyable/ui_state(mob/user)
	return GLOB.dropship_state

/obj/machinery/computer/camera_advanced/shuttle_docker/flyable/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(ui_user)
		return

	if(!ui)
		ui_user = user
		RegisterSignals(ui_user, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED), PROC_REF(user_moved))
		ui = new(user, src, "Minidropship", name)
		ui.open()

/obj/machinery/computer/camera_advanced/shuttle_docker/flyable/ui_close(mob/user)
	. = ..()
	if(!ui_user)
		return

	clean_ui_user()

///Check if the user is still next to the shuttle computer
/obj/machinery/computer/camera_advanced/shuttle_docker/flyable/proc/user_moved(datum/source)
	SIGNAL_HANDLER
	if(!ui_user || ui_user.Adjacent(src))
		return

	clean_ui_user()

///Handle removing the user from the camera and closing the UI
/obj/machinery/computer/camera_advanced/shuttle_docker/flyable/proc/clean_ui_user()
	if(!ui_user)
		return

	//Prevents a runtime because close_user_uis() below will eventually call this proc again
	var/old_user = ui_user
	ui_user = null
	SStgui.close_user_uis(old_user, src) //Close the tadpole UI
	remove_eye_control(old_user) //Boot the user out of the camera system
	UnregisterSignal(old_user, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED))

/obj/machinery/computer/camera_advanced/shuttle_docker/flyable/ui_data(mob/user)
	. = list()
	if(!shuttle_port)
		assign_shuttle()
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


/obj/machinery/computer/camera_advanced/shuttle_docker/flyable/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
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
	var/obj/machinery/computer/camera_advanced/shuttle_docker/flyable/origin = remote_eye.origin
	if(origin.shuttle_port.mode != SHUTTLE_IDLE)
		to_chat(owner, span_warning("The shuttle is not ready to land yet!"))
		return
	if(!origin.placeLandingSpot())
		to_chat(owner, span_warning("You cannot land here."))
		return
	if(is_ground_level(origin.z)) //Safety check to prevent instant transmission
		to_chat(owner, span_warning("The shuttle can't move while docked on the planet"))
		return
	origin.shuttle_port.callTime = SHUTTLE_LANDING_CALLTIME
	origin.next_fly_state = SHUTTLE_ON_GROUND
	origin.open_prompt = FALSE
	SStgui.close_user_uis(C, origin)
	origin.shuttle_port.set_mode(SHUTTLE_CALL)
	origin.last_valid_ground_port = origin.my_port
	SSshuttle.moveShuttleToDock(origin.shuttleId, origin.my_port, TRUE)

//This should only ever be placed on a shuttle with a /mobile/marine_dropship type of docking port or there will be runtimes
/obj/machinery/computer/camera_advanced/shuttle_docker/flyable/dropship
	shuttleId = SHUTTLE_DROPSHIP
	origin_port_id = SHUTTLE_DROPSHIP
	launching_delay = 1 SECONDS
	whitelist_turfs = list(/turf/open/ground, /turf/open/floor, /turf/open/liquid/water, /turf/closed/gm)
	view_range = 2
	max_ceiling_tier = CEILING_OBSTRUCTED
	///Same as shuttle_port but used for specific procs found on /marine_dropship/; reduces a lot of var/ assignments below
	var/obj/docking_port/mobile/marine_dropship/dropship

/obj/machinery/computer/camera_advanced/shuttle_docker/flyable/dropship/assign_shuttle()
	. = ..()
	dropship = shuttle_port

/obj/machinery/computer/camera_advanced/shuttle_docker/flyable/dropship/shuttle_arrived()
	//TO DO: do an if(fly_state == GROUNDED && isLZarea()), but requires unifying all LZ areas... pain
	return ..()

/obj/machinery/computer/camera_advanced/shuttle_docker/flyable/dropship/allowed(mob/M)
	if(dropship.hijack_state)
		balloon_alert(M, "Controls locked!")
		return FALSE
	return ..()

/obj/machinery/computer/camera_advanced/shuttle_docker/flyable/dropship/xeno_sabotage(mob/living/carbon/xenomorph/saboteur)
	switch(dropship.hijack_state)
		if(HIJACK_STATE_CRASHING)	//It's already barreling towards the main ship, do nothing
			return
		if(HIJACK_STATE_CONTROLLED)
			xeno_control(saboteur)
			return

	#ifndef TESTING
	var/datum/game_mode/infestation/infestation_mode = SSticker.mode
	if(!CHECK_BITFIELD(user.xeno_caste.caste_flags, CASTE_IS_INTELLIGENT) || infestation_mode.round_stage == INFESTATION_MARINE_CRASHING)
		return
	#endif

	balloon_alert_to_viewers("Corrupting controls!", vision_distance = 20)	//Make sure everyone can see it, even those looking through scopes
	if(!do_after(saboteur, 10 SECONDS, NONE, src, BUSY_ICON_DANGER, BUSY_ICON_HOSTILE))
		return

	to_chat(saboteur, span_xenowarning("We corrupt the bird's controls, unlocking the doors and preventing it from flying."))
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_DROPSHIP_CONTROLS_CORRUPTED, src)
	dropship.set_idle()
	dropship.set_hijack_state(HIJACK_STATE_CALLED_DOWN)
	dropship.start_hijack_timer()
	dropship.unlock_all()
	xeno_control(saboteur)

///Give the xeno options for what to do with the shuttle
/obj/machinery/computer/camera_advanced/shuttle_docker/flyable/dropship/proc/xeno_control(mob/living/carbon/xenomorph/user)
	if(!CHECK_BITFIELD(user.xeno_caste.caste_flags, CASTE_IS_INTELLIGENT) || CHECK_BITFIELD(machine_stat, BROKEN))
		return

	var/is_shipside = SSmapping.level_trait(user.z, ZTRAIT_MARINE_MAIN_SHIP)
	var/choice = tgui_alert(user, "What next?", "Shuttle Control", list("Board Main Vessel", "Declare Victory", "Cancel"))
	switch(choice)
		if("Board Main Vessel")
			if(CHECK_BITFIELD(machine_stat, BROKEN))
				return

			hijack(user, is_shipside)

		if("Declare Victory")
			if(is_shipside)	//Can't declare victory shipside, would be too easy
				to_chat(user, span_xenowarning("This is no victory!"))
				return

			var/humans_on_ground = 0
			for(var/i in SSmapping.levels_by_trait(ZTRAIT_GROUND))
				for(var/mob/living/carbon/human/human AS in GLOB.humans_by_zlevel["[i]"])
					if(isnestedhost(human))
						continue

					if(human.faction == FACTION_XENO)
						continue

					humans_on_ground++

			if(length(GLOB.alive_human_list) && ((humans_on_ground / length(GLOB.alive_human_list)) > ALIVE_HUMANS_FOR_CALLDOWN))
				to_chat(user, span_xenowarning("There is still prey left to hunt!"))
				return

			balloon_alert_to_viewers("Declaring victory!", vision_distance = 20)
			if(!do_after(user, 30 SECONDS, NONE, src, BUSY_ICON_DANGER, BUSY_ICON_HOSTILE))
				return

			if(CHECK_BITFIELD(machine_stat, BROKEN))
				return

			priority_announce(
				"The [SHUTTLE_DROPSHIP] has been captured! Losing their main method of reaching the battlefield, the marines have no choice but to retreat.",
				"[SHUTTLE_DROPSHIP] Captured",
				color_override = "orange")
			var/datum/game_mode/infestation/infestation_mode = SSticker.mode
			infestation_mode.round_stage = INFESTATION_DROPSHIP_CAPTURED_XENOS

		else
			return

	//Break the console to prevent any funny business, it's not needed anymore anyways
	set_broken()

///Processes for sending a hijacked shuttle to the main ship
/obj/machinery/computer/camera_advanced/shuttle_docker/flyable/dropship/proc/hijack(mob/living/carbon/xenomorph/user, shipside)
	if(!dropship)
		stack_trace("No dropship found in hijack(), HOW?")
		return

	dropship.set_hijack_state(HIJACK_STATE_CRASHING)
	if(SSticker.mode?.round_type_flags & MODE_HIJACK_POSSIBLE)
		var/datum/game_mode/infestation/infestation_mode = SSticker.mode
		infestation_mode.round_stage = INFESTATION_MARINE_CRASHING

	dropship.crashing = TRUE
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_DROPSHIP_HIJACKED)
	GLOB.hive_datums[XENO_HIVE_NORMAL].special_build_points = 25 //resets special build points
	user.hive.on_shuttle_hijack(dropship)
	playsound(src, 'sound/misc/queen_alarm.ogg')
	SSevacuation.scuttle_flags &= ~FLAGS_SDEVAC_TIMELOCK

	if(shipside)	//Ooo stealthy beno, the marines have no idea
		return

	//var/time_to_crash = 120 * (GLOB.current_orbit/3) SECONDS
	var/time_to_crash = 20 SECONDS
	priority_announce(
		"Unscheduled dropship departure detected from operational area. Hijack likely.",
		"Critical Dropship Alert",
		"ETA: [time_to_crash / 10] SECONDS",
		ANNOUNCEMENT_PRIORITY,
		'sound/AI/hijack.ogg',
		color_override = "red")
	user.hive.xeno_message("The metal bird will impact the tallhost hive in [time_to_crash / 10] SECONDS!")

	if(SHUTTLE_IDLE && fly_state == SHUTTLE_ON_GROUND)
		dropship.callTime = 10 SECONDS	//Arbitrary amount of time so that the shuttle doesn't immediately go from atmosphere to space
		take_off(TRUE)	//Send the shuttle to the atmosphere first

		//Prep the shuttle for travel from the atmosphere towards the main ship
		to_transit = TRUE
		next_fly_state = SHUTTLE_IN_SPACE
		destination_fly_state = SHUTTLE_ON_SHIP
		addtimer(CALLBACK(src, PROC_REF(crash), time_to_crash - 11 SECONDS), 11 SECONDS)
		return

	//If already flying, just send it straight to the main ship
	crash(time_to_crash)

///Pick a random spot to crash the shuttle
/obj/machinery/computer/camera_advanced/shuttle_docker/flyable/dropship/proc/crash(time_to_crash = 10 SECONDS)
	if(!dropship)
		stack_trace("No dropship found in crash(), HOW?")
		return

	dropship.callTime = time_to_crash
	SSshuttle.moveShuttleToDock(shuttleId, pick(SSshuttle.crash_targets), TRUE)

///Handle summoning the dropship to the summoner's location; is done on the console because the process is way more complex otherwise
/obj/machinery/computer/camera_advanced/shuttle_docker/flyable/dropship/proc/summon(atom/summoner)
	SStgui.close_uis(src)
	dropship.set_hijack_state(HIJACK_STATE_CALLED_DOWN)
	playsound(summoner, SFX_ALIEN_ROAR, 50)
	playsound(dropship.loc,'sound/effects/alert.ogg', 50, sound_range = 15)	//Use docking port loc instead of the console
	dropship.start_hijack_timer()
	create_landing_port()
	my_port.forceMove(get_turf(summoner))
	my_port.setDir(summoner.dir)

	var/time_until_takeoff = dropship.timeLeft(1)
	if(time_until_takeoff)
		priority_announce(
			"Dropship compromised by foreign actor. Interference preventing remote control. Take-off in: [time_until_takeoff / 10] SECONDS",
			"Dropship Hijack Alert",
			type = ANNOUNCEMENT_PRIORITY,
			color_override = "red")
		addtimer(CALLBACK(src, PROC_REF(summon_towards)), time_until_takeoff)
		return

	priority_announce(
		"Dropship compromised by foreign actor. Interference preventing remote control. TAKE-OFF IMMINENT.",
		"Dropship Hijack Alert",
		type = ANNOUNCEMENT_PRIORITY,
		color_override = "red")
	summon_towards()

/obj/machinery/computer/camera_advanced/shuttle_docker/flyable/dropship/proc/summon_towards()
	if(!dropship)
		stack_trace("No dropship found in summon_towards(), HOW?")
		return

	//Have to account for the shuttle being either already in flight, in the main ship hangar, or already on the ground somewhere
	//Also take into account the next_fly_state because this will be called again before the shuttle actually takes off
	if((next_fly_state == SHUTTLE_ON_SHIP || next_fly_state == SHUTTLE_ON_GROUND) && (fly_state == SHUTTLE_ON_SHIP || fly_state == SHUTTLE_ON_GROUND))
		take_off(TRUE)
		//Calculate the time it takes to travel to the atmosphere; add an extra second to make sure it reaches the atmosphere
		var/time_until_takeoff = dropship.timeLeft(1) + dropship.prearrivalTime + dropship.rechargeTime + 1 SECONDS
		if(time_until_takeoff)
			addtimer(CALLBACK(src, PROC_REF(summon_towards)), time_until_takeoff)
		else
			summon_towards()
		return

	open_prompt = FALSE	//Set this here instead of in summon() because shuttle_arrived() will set this to TRUE if take_off() was called
	dropship.callTime = SHUTTLE_LANDING_CALLTIME
	next_fly_state = SHUTTLE_ON_GROUND
	dropship.set_mode(SHUTTLE_CALL)
	SSshuttle.moveShuttleToDock(shuttleId, my_port, TRUE)

/obj/item/shuttle_hijacker
	name = "hijacker"
	icon_state = "coin"
	var/mob/living/carbon/xenomorph/spawner = /mob/living/carbon/xenomorph/shrike
	var/mob/living/carbon/xenomorph/beno

/obj/item/shuttle_hijacker/attack_self(mob/user)
	beno = new spawner(locate(20, 20, 2))
	addtimer(CALLBACK(src, PROC_REF(stuff)), 10 SECONDS)

/obj/item/shuttle_hijacker/proc/stuff()
	beno.face_atom(get_step_rand(beno))
	beno.summon_dropship()
