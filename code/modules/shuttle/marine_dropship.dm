// marine dropships
/obj/docking_port/stationary/shuttle
	name = "dropship landing zone"
	id = "shuttle"
	dir = SOUTH
	dwidth = 5
	dheight = 10
	width = 11
	height = 21

/obj/docking_port/stationary/shuttle/Initialize()
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/docking_port/stationary/shuttle/LateInitialize()
	for(var/obj/machinery/landinglight/light AS in GLOB.landing_lights)
		if(light.id == id)
			light.linked_port = src

/obj/docking_port/stationary/shuttle/on_crash()
	for(var/obj/machinery/power/apc/A AS in GLOB.apcs_list) //break APCs
		if(!is_mainship_level(A.z))
			continue
		if(prob(A.crash_break_probability))
			A.overload_lighting()
			A.set_broken()
		for(var/obj/effect/soundplayer/deltaplayer/alarmplayer AS in GLOB.ship_alarms)
			alarmplayer.loop_sound.stop(alarmplayer)	//quiet the delta klaxon alarms
		CHECK_TICK

	for(var/i in GLOB.alive_living_list) //knock down mobs
		var/mob/living/M = i
		if(!is_mainship_level(M.z))
			continue
		if(M.buckled)
			to_chat(M, span_warning("You are jolted against [M.buckled]!"))
			shake_camera(M, 3, 1)
		else
			to_chat(M, span_warning("The floor jolts under your feet!"))
			shake_camera(M, 10, 1)
			M.Paralyze(6 SECONDS)
		CHECK_TICK

	for(var/i in GLOB.ai_list)
		var/mob/living/silicon/ai/AI = i
		AI.anchored = FALSE
		CHECK_TICK

	GLOB.enter_allowed = FALSE //No joining after dropship crash

	//clear areas around the shuttle with explosions
	var/turf/C = return_center_turf()

	var/cos = 1
	var/sin = 0
	switch(dir)
		if(WEST)
			cos = 0
			sin = 1
		if(SOUTH)
			cos = -1
			sin = 0
		if(EAST)
			cos = 0
			sin = -1

	var/updown = (round(width/2))*sin + (round(height/2))*cos
	var/leftright = (round(width/2))*cos - (round(height/2))*sin

	var/turf/front = locate(C.x, C.y - updown, C.z)
	var/turf/rear = locate(C.x, C.y + updown, C.z)
	var/turf/left = locate(C.x - leftright, C.y, C.z)
	var/turf/right = locate(C.x + leftright, C.y, C.z)

	for(var/turf/T in range(3, rear)+range(3, left)+range(3, right)+range(2, front))
		T.empty(/turf/open/floor/plating, ignore_typecache = typecacheof(/mob))

	SSmonitor.process_human_positions()
	SSevacuation.initial_human_on_ship = SSmonitor.human_on_ship

/obj/docking_port/stationary/shuttle/crash_target
	name = "dropshipcrash"
	id = "dropshipcrash"

/obj/docking_port/stationary/shuttle/crash_target/Initialize(mapload)
	. = ..()
	SSshuttle.crash_targets += src

/obj/docking_port/stationary/shuttle/lz1
	name = "Landing Zone One"
	id = DOCKING_PORT_LZ1

/obj/docking_port/stationary/shuttle/lz1/Initialize(mapload)
	. = ..()
	var/area/area = get_area(src)
	area.area_flags |= MARINE_BASE

/obj/docking_port/stationary/shuttle/lz1/prison
	name = "LZ1: Main Hangar"

/obj/docking_port/stationary/shuttle/lz2
	name = "Landing Zone Two"
	id = DOCKING_PORT_LZ2

/obj/docking_port/stationary/shuttle/lz2/prison
	name = "LZ2: Civ Residence Hangar"

/obj/docking_port/stationary/shuttle/dropship
	name = "Shipside 'Alamo' Hangar Pad"
	id = SHUTTLE_DROPSHIP
	roundstart_template = /datum/map_template/shuttle/flyable/dropship

/obj/docking_port/stationary/shuttle/dropship_alt
	name = "Shipside 'Normandy' Hangar Pad"
	id = SHUTTLE_NORMANDY
	roundstart_template = /datum/map_template/shuttle/dropship_two
	dheight = 6
	dwidth = 4
	height = 13
	width = 9

/obj/docking_port/mobile/marine_dropship
	name = "marine dropship"
	dir = SOUTH
	dwidth = 5
	dheight = 10
	width = 11
	height = 21
	ignitionTime = 10 SECONDS
	callTime = 38 SECONDS // same as old transit time with flight optimisation
	rechargeTime = 2 MINUTES
	prearrivalTime = 12 SECONDS
	var/list/left_airlocks = list()
	var/list/right_airlocks = list()
	var/list/rear_airlocks = list()
	var/obj/docking_port/stationary/hijack_request
	var/list/equipments = list()
	var/hijack_state = HIJACK_STATE_NORMAL
	///If the automatic cycle system is activated
	var/automatic_cycle_on = FALSE
	///How long will the shuttle wait to launch again if the automatic mode is on. In seconds
	var/time_between_cycle = 0
	///The timer to launch the dropship in automatic mode
	var/cycle_timer
	///If first landing is false intro sequence wont play
	var/static/first_landing = TRUE
	///If this dropship can play the takeoff announcement
	var/takeoff_alarm_locked = FALSE

/obj/docking_port/mobile/marine_dropship/enterTransit()
	. = ..()
	if(!.) // it failed in parent
		return
	// pull the shuttle from datum/source, and state info from the shuttle itself
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_DROPSHIP_TRANSIT)
	takeoff_alarm_locked = FALSE // Allow the alarm to be used again
	if(first_landing)
		first_landing = FALSE
		var/op_name = GLOB.operation_namepool[/datum/operation_namepool].get_random_name()
		for(var/mob/living/carbon/human/human AS in GLOB.alive_human_list)
			if(human.faction != FACTION_TERRAGOV)
				return
			human.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:left valign='top'><u>[op_name]</u></span><br>" + "[SSmapping.configs[GROUND_MAP].map_name]<br>" + "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")] [stationTimestamp("hh:mm")]<br>" + "36th Marine LRPRR Platoon<br>" + "[human.job.title], [human]", /atom/movable/screen/text/screen_text/picture)

/obj/docking_port/mobile/marine_dropship/proc/lockdown_all()
	lockdown_airlocks("rear")
	lockdown_airlocks("left")
	lockdown_airlocks("right")

/obj/docking_port/mobile/marine_dropship/proc/lockdown_airlocks(side)
	if(hijack_state != HIJACK_STATE_NORMAL)
		return
	switch(side)
		if("left")
			for(var/i in left_airlocks)
				var/obj/machinery/door/airlock/dropship_hatch/D = i
				D.lockdown()
		if("right")
			for(var/i in right_airlocks)
				var/obj/machinery/door/airlock/dropship_hatch/D = i
				D.lockdown()
		if("rear")
			for(var/i in rear_airlocks)
				var/obj/machinery/door/airlock/multi_tile/mainship/dropshiprear/D = i
				D.lockdown()

/obj/docking_port/mobile/marine_dropship/proc/unlock_all()
	unlock_airlocks("rear")
	unlock_airlocks("left")
	unlock_airlocks("right")

/obj/docking_port/mobile/marine_dropship/proc/unlock_airlocks(side)
	switch(side)
		if("left")
			for(var/i in left_airlocks)
				var/obj/machinery/door/airlock/dropship_hatch/D = i
				D.release()
		if("right")
			for(var/i in right_airlocks)
				var/obj/machinery/door/airlock/dropship_hatch/D = i
				D.release()
		if("rear")
			for(var/i in rear_airlocks)
				var/obj/machinery/door/airlock/multi_tile/mainship/dropshiprear/D = i
				D.release()

///This proc locks and unlocks the AI control over the dropship doors.
/obj/docking_port/mobile/marine_dropship/proc/silicon_lock_airlocks(should_lock = TRUE)
	for(var/obj/machinery/door/airlock/dropship_hatch/D AS in left_airlocks)
		D.aiControlDisabled = should_lock
	for(var/obj/machinery/door/airlock/dropship_hatch/D AS in right_airlocks)
		D.aiControlDisabled = should_lock
	for(var/obj/machinery/door/airlock/multi_tile/mainship/dropshiprear/D AS in rear_airlocks)
		D.aiControlDisabled = should_lock

/obj/docking_port/mobile/marine_dropship/initiate_docking(obj/docking_port/stationary/new_dock, movement_direction, force=FALSE)
	if(crashing)
		force = TRUE

	if(automatic_cycle_on && destination == new_dock)
		if(cycle_timer)
			deltimer(cycle_timer)
		cycle_timer = addtimer(CALLBACK(src, PROC_REF(prepare_going_to_previous_destination)), rechargeTime + time_between_cycle SECONDS - 20 SECONDS, TIMER_STOPPABLE)
	for(var/obj/machinery/landinglight/light AS in GLOB.landing_lights)
		if(light.linked_port == destination)
			light.turn_off()
	return ..()

///Announce that the dropship will departure soon
/obj/docking_port/mobile/marine_dropship/proc/prepare_going_to_previous_destination()
	if(hijack_state != HIJACK_STATE_NORMAL)
		return
	cycle_timer = addtimer(CALLBACK(src, PROC_REF(go_to_previous_destination)), 20 SECONDS, TIMER_STOPPABLE)
	priority_announce("The Alamo will depart towards [previous.name] in 20 seconds.", "Dropship Automatic Departure", color_override = "grey", playing_sound = FALSE)

///Send the dropship to its previous dock
/obj/docking_port/mobile/marine_dropship/proc/go_to_previous_destination()
	SSshuttle.moveShuttle(id, previous.id, TRUE)

/obj/docking_port/mobile/marine_dropship/one
	name = "Alamo"
	id = SHUTTLE_DROPSHIP
	control_flags = SHUTTLE_MARINE_PRIMARY_DROPSHIP
	callTime = 30 SECONDS
	rechargeTime = 5 SECONDS
	prearrivalTime = 10 SECONDS

/obj/docking_port/mobile/marine_dropship/two
	name = "Normandy"
	id = SHUTTLE_NORMANDY
	control_flags = SHUTTLE_MARINE_PRIMARY_DROPSHIP
	callTime = 28 SECONDS //smaller shuttle go whoosh
	rechargeTime = 1.5 MINUTES
	dheight = 6
	dwidth = 4
	height = 13
	width = 9

// queen calldown

/obj/docking_port/mobile/marine_dropship/afterShuttleMove(turf/oldT, rotation)
	. = ..()
	if(hijack_state != HIJACK_STATE_CALLED_DOWN)
		return
	unlock_all()

///Start the countdown for how long until control of the dropship is returned to the marines
/obj/docking_port/mobile/marine_dropship/proc/start_hijack_timer(hijack_time = 6 MINUTES)
	addtimer(CALLBACK(src, PROC_REF(reset_hijack)), hijack_time)

///Process for resetting a ship to it's normal non-hijacked state
/obj/docking_port/mobile/marine_dropship/proc/reset_hijack()
	if(hijack_state == HIJACK_STATE_CRASHING)
		return

	set_hijack_state(HIJACK_STATE_NORMAL)
	silicon_lock_airlocks(FALSE)
	priority_announce(
		"Dropship control integrity restored.",
		"Dropship Hijack Reset",
		type = ANNOUNCEMENT_PRIORITY,
		color_override = "green")
	xeno_message("Our hive has lost control of the metal bird.")
	if(shuttle_computer)
		SStgui.close_uis(shuttle_computer)	//Close any open UIs on the console to make xenos have to re-corrupt

/obj/docking_port/mobile/marine_dropship/proc/request_to(obj/docking_port/stationary/S)
	set_idle()
	request(S)

/obj/docking_port/mobile/marine_dropship/proc/set_hijack_state(new_state)
	hijack_state = new_state
	deltimer(cycle_timer)

/obj/docking_port/mobile/marine_dropship/on_prearrival()
	. = ..()
	if(hijack_state == HIJACK_STATE_CRASHING)
		priority_announce("DROPSHIP ON COLLISION COURSE. CRASH IMMINENT.", "EMERGENCY", sound = 'sound/AI/dropship_emergency.ogg', color_override = "red")
	for(var/obj/machinery/landinglight/light AS in GLOB.landing_lights)
		if(light.linked_port == destination)
			light.turn_on()

/obj/docking_port/mobile/marine_dropship/getStatusText()
	if(hijack_state)
		return "Control integrity compromised"
	return ..() + (timeleft(cycle_timer) ? (" Automatic cycle : [round(timeleft(cycle_timer) / 10 + 20, 1)] seconds before departure towards [previous.name]") : "")


/obj/docking_port/mobile/marine_dropship/can_move_topic(mob/user)
	if(hijack_state != HIJACK_STATE_NORMAL)
		to_chat(user, span_warning("Control integrity compromised!"))
		return FALSE
	return ..()

// ************************************************	//
//													//
// 			dropship specific objs and turfs		//
//													//
// ************************************************	//

// control computer
/obj/machinery/computer/shuttle/marine_dropship
	icon_state = "dropship_console"
	screen_overlay = "dropship_console_emissive"
	resistance_flags = RESIST_ALL
	req_one_access = list(ACCESS_MARINE_SHUTTLE, ACCESS_MARINE_LEADER) // TLs can only operate the remote console
	possible_destinations = list(DOCKING_PORT_LZ1, DOCKING_PORT_LZ2, SHUTTLE_DROPSHIP)
	opacity = FALSE

/obj/machinery/computer/shuttle/marine_dropship/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, armor_penetration = xeno_attacker.xeno_caste.melee_ap, isrightclick = FALSE)
	var/datum/game_mode/infestation/infestation_mode = SSticker.mode //Minor QOL, any xeno can check the console after a leader hijacks
	if(!(xeno_attacker.xeno_caste.caste_flags & CASTE_IS_INTELLIGENT) && (infestation_mode.round_stage != INFESTATION_MARINE_CRASHING))
		return
	var/obj/docking_port/mobile/marine_dropship/shuttle = SSshuttle.getShuttle(shuttleId)
	if(shuttle.hijack_state != HIJACK_STATE_CALLED_DOWN && shuttle.hijack_state != HIJACK_STATE_CRASHING) //Process of corrupting the controls
		to_chat(xeno_attacker, span_xenowarning("We corrupt the bird's controls, unlocking the doors and preventing it from flying."))
		SEND_GLOBAL_SIGNAL(COMSIG_GLOB_DROPSHIP_CONTROLS_CORRUPTED, src)
		shuttle.set_idle()
		shuttle.set_hijack_state(HIJACK_STATE_CALLED_DOWN)
		shuttle.start_hijack_timer()
		shuttle.unlock_all()
	interact(xeno_attacker) //Open the UI

/obj/machinery/computer/shuttle/marine_dropship/ui_state(mob/user)
	return GLOB.alamo_state

/obj/machinery/computer/shuttle/marine_dropship/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "MarineDropship", name)
		ui.open()

/obj/machinery/computer/shuttle/marine_dropship/ui_static_data(mob/user)
	var/obj/docking_port/mobile/marine_dropship/shuttle = SSshuttle.getShuttle(shuttleId)
	var/list/static_data = list()
	static_data["current_map"] = SSmapping.configs[SHIP_MAP].map_name
	static_data["ship_name"] = shuttle

	return static_data

/obj/machinery/computer/shuttle/marine_dropship/ui_data(mob/user)
	var/obj/docking_port/mobile/marine_dropship/shuttle = SSshuttle.getShuttle(shuttleId)
	if(!shuttle)
		WARNING("[src] could not find shuttle [shuttleId] from SSshuttle")
		return

	var/list/data = list()
	data["is_xeno"] = isxeno(user)
	data["on_flyby"] = shuttle.mode == SHUTTLE_CALL
	data["dest_select"] = !(shuttle.mode == SHUTTLE_CALL || shuttle.mode == SHUTTLE_IDLE)
	data["hijack_state"] = shuttle.hijack_state != HIJACK_STATE_CALLED_DOWN
	data["ship_status"] = shuttle.getStatusText()
	data["automatic_cycle_on"] = shuttle.automatic_cycle_on
	data["time_between_cycle"] = shuttle.time_between_cycle

	var/datum/game_mode/infestation/infestation_mode = SSticker.mode
	if(istype(infestation_mode))
		data["shuttle_hijacked"] = (infestation_mode.round_stage == INFESTATION_MARINE_CRASHING) //If we hijacked, our capture button greys out

	var/locked = 0
	var/reardoor = 0
	for(var/i in shuttle.rear_airlocks)
		var/obj/machinery/door/airlock/A = i
		if(A.locked && A.density)
			reardoor++
	if(!reardoor)
		data["rear"] = 0
	else if(reardoor==length(shuttle.rear_airlocks))
		data["rear"] = 2
		locked++
	else
		data["rear"] = 1

	var/leftdoor = 0
	for(var/i in shuttle.left_airlocks)
		var/obj/machinery/door/airlock/A = i
		if(A.locked && A.density)
			leftdoor++
	if(!leftdoor)
		data["left"] = 0
	else if(leftdoor==length(shuttle.left_airlocks))
		data["left"] = 2
		locked++
	else
		data["left"] = 1

	var/rightdoor = 0
	for(var/i in shuttle.right_airlocks)
		var/obj/machinery/door/airlock/A = i
		if(A.locked && A.density)
			rightdoor++
	if(!rightdoor)
		data["right"] = 0
	else if(rightdoor==length(shuttle.right_airlocks))
		data["right"] = 2
		locked++
	else
		data["right"] = 1

	if(locked == 3)
		data["lockdown"] = 2
	else if(!locked)
		data["lockdown"] = 0
	else
		data["lockdown"] = 1

	var/list/valid_destinations = list()
	for(var/obj/docking_port/stationary/S in SSshuttle.stationary)
		if(!possible_destinations.Find(S.id))
			continue
		if(!shuttle.check_dock(S, silent=TRUE))
			continue
		valid_destinations += list(list("name" = S.name, "id" = S.id))
	data["destinations"] = valid_destinations

	return data

/obj/machinery/computer/shuttle/marine_dropship/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/obj/docking_port/mobile/marine_dropship/shuttle = SSshuttle.getShuttle(shuttleId)
	if(!shuttle)
		return
	if(shuttle.hijack_state == HIJACK_STATE_CALLED_DOWN && ishuman(usr))
		return

	switch(action)
		if("move")
			Topic(null, list("move" = params["move"]))
			return
		if("lockdown")
			shuttle.lockdown_all()
			. = TRUE
		if("release")
			shuttle.unlock_all()
			. = TRUE
		if("lock")
			shuttle.lockdown_airlocks(params["lock"])
			. = TRUE
		if("unlock")
			shuttle.unlock_airlocks(params["unlock"])
			. = TRUE
		if("automation_on")
			shuttle.automatic_cycle_on = params["automation_on"]
			if(!shuttle.automatic_cycle_on)
				deltimer(shuttle.cycle_timer)
		if("cycle_time_change")
			shuttle.time_between_cycle = params["cycle_time_change"]
		if("signal_departure")
			// Weird cases where the alarm shouldn't be used.
			switch(shuttle.mode)
				if(SHUTTLE_RECHARGING)
					to_chat(usr, span_warning("The dropship is recharging."))
					return
				if(SHUTTLE_CALL)
					to_chat(usr, span_warning("The dropship is in flight."))
					return
				if(SHUTTLE_IGNITING)
					to_chat(usr, span_warning("The dropship is about to take off."))
					return
				if(SHUTTLE_PREARRIVAL)
					to_chat(usr, span_warning("The dropship is about to land."))
					return

			// It's too early to launch it.
			#ifndef TESTING
			if(!(shuttle.shuttle_flags & GAMEMODE_IMMUNE) && world.time < SSticker.round_start_time + SSticker.mode.deploy_time_lock)
				to_chat(usr, span_warning("It's too early to use the alarm right now."))
				return TRUE
			#endif

			// Prevent spamming the alarm.
			if(shuttle.takeoff_alarm_locked)
				to_chat(usr, span_boldwarning("The dropship takeoff alarm is locked. To unlock it, the dropship must be cycled."))
				return

			priority_announce(
				type = ANNOUNCEMENT_PRIORITY,
				title = "Dropship Takeoff Imminent",
				message = "[usr.real_name] has signalled that the Alamo will take off soon.",
				sound = 'sound/misc/ds_signalled_alarm.ogg',
				channel_override = SSsounds.random_available_channel(), // Probably important enough to avoid interruption?
				color_override = "yellow"
			)
			to_chat(usr, span_warning("You slam your palm on the alarm button, locking it until the dropship lands again."))
			shuttle.takeoff_alarm_locked = TRUE
		//These are actions for the Xeno dropship UI
		if("hijack")
			var/mob/living/carbon/xenomorph/xeno = usr
			if(!(xeno.hive.hive_flags & HIVE_CAN_HIJACK))
				to_chat(xeno, span_warning("Our hive lacks the psychic prowess to hijack the bird."))
				return
			if(shuttle.mode == SHUTTLE_RECHARGING)
				to_chat(xeno, span_xenowarning("The bird is still cooling down."))
				return
			if(shuttle.mode != SHUTTLE_IDLE)
				to_chat(xeno, span_xenowarning("We can't do that right now."))
				return
			var/confirm = tgui_alert(usr, "Would you like to hijack the metal bird?", "Hijack the bird?", list("Yes", "No"))
			if(confirm != "Yes")
				return
			var/obj/docking_port/stationary/shuttle/crash_target/CT = pick(SSshuttle.crash_targets)
			if(!CT)
				return
			do_hijack(shuttle, CT, xeno)
		if("abduct")
			var/datum/game_mode/infestation/infestation_mode = SSticker.mode
			if(infestation_mode.round_stage == INFESTATION_MARINE_CRASHING)
				message_admins("[usr] tried to capture the shuttle after it was already hijacked, possible use of exploits.")
				return
			var/groundside_humans = length(GLOB.humans_by_zlevel["[z]"])
			if(groundside_humans > 5)
				to_chat(usr, span_xenowarning("There is still prey left to hunt!"))
				return
			var/confirm = tgui_alert(usr, "Would you like to capture the metal bird?\n THIS WILL END THE ROUND", "Capture the ship?", list( "Yes", "No"))
			if(confirm != "Yes")
				return
			groundside_humans = length(GLOB.humans_by_zlevel["[z]"])
			if(groundside_humans > 5)
				to_chat(usr, span_xenowarning("There is still prey left to hunt!"))
				return

			priority_announce("The Alamo has been captured! Losing their main mean of accessing the ground, the marines have no choice but to retreat.", title = "Alamo Captured", color_override = "orange")
			infestation_mode.round_stage = INFESTATION_DROPSHIP_CAPTURED_XENOS
			return

/obj/machinery/computer/shuttle/marine_dropship/proc/do_hijack(obj/docking_port/mobile/marine_dropship/crashing_dropship, obj/docking_port/stationary/shuttle/crash_target/crash_target, mob/living/carbon/xenomorph/user)
	crashing_dropship.set_hijack_state(HIJACK_STATE_CRASHING)
	if(SSticker.mode?.round_type_flags & MODE_HIJACK_POSSIBLE)
		var/datum/game_mode/infestation/infestation_mode = SSticker.mode
		infestation_mode.round_stage = INFESTATION_MARINE_CRASHING
	crashing_dropship.callTime = 120 * (GLOB.current_orbit/3) SECONDS
	crashing_dropship.crashing = TRUE
	crashing_dropship.unlock_all()
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_DROPSHIP_HIJACKED)
	priority_announce("Unscheduled dropship departure detected from operational area. Hijack likely.", title = "Critical Dropship Alert", type = ANNOUNCEMENT_PRIORITY, sound = 'sound/AI/hijack.ogg', color_override = "red")
	to_chat(user, span_danger("A loud alarm erupts from [src]! The fleshy hosts must know that you can access it!"))
	GLOB.hive_datums[XENO_HIVE_NORMAL].special_build_points = 25 //resets special build points
	user.hive.on_shuttle_hijack(crashing_dropship)
	playsound(src, 'sound/misc/queen_alarm.ogg')
	crashing_dropship.silicon_lock_airlocks(TRUE)
	SSevacuation.scuttle_flags &= ~FLAGS_SDEVAC_TIMELOCK
	switch(SSshuttle.moveShuttleToDock(shuttleId, crash_target, TRUE))
		if(0)
			visible_message("Shuttle departing. Please stand away from the doors.")
		if(1)
			to_chat(user, span_warning("Invalid shuttle requested. This shouldn't happen, please report it."))
			CRASH("moveShuttleToDock() returned 1.")
		else
			to_chat(user, span_warning("ERROR. This shouldn't happen, please report it."))
			CRASH("moveShuttleToDock() returned a non-zero-nor-one value.")

/obj/machinery/computer/shuttle/marine_dropship/one
	name = "\improper 'Alamo' flight controls"
	desc = "The flight controls for the 'Alamo' Dropship. Named after the Alamo Mission, stage of the Battle of the Alamo in the United States' state of Texas in the Spring of 1836. The defenders held to the last, encouraging other Texians to rally to the flag."

/obj/machinery/computer/shuttle/marine_dropship/one/Initialize(mapload)
	. = ..()
	for(var/trait in SSmapping.configs[SHIP_MAP].environment_traits)
		if(ZTRAIT_DOUBLE_SHIPS in trait)
			possible_destinations.Remove(DOCKING_PORT_LZ1)

/obj/machinery/computer/shuttle/marine_dropship/two
	name = "\improper 'Normandy' flight controls"
	desc = "The flight controls for the 'Normandy' Dropship. Named after a department in France, noteworthy for the famous naval invasion of Normandy on the 6th of June 1944, a bloody but decisive victory in World War II and the campaign for the Liberation of France."
	icon_state = "dropship_console2"
	screen_overlay = "dropship_console2_emissive"
	possible_destinations = list(DOCKING_PORT_LZ1, DOCKING_PORT_LZ2, SHUTTLE_DROPSHIP, SHUTTLE_NORMANDY)

/obj/machinery/door/poddoor/shutters/transit/afterShuttleMove(turf/oldT, list/movement_force, shuttle_dir, shuttle_preferred_direction, move_dir, rotation)
	. = ..()
	if(SSmapping.level_has_any_trait(z, list(ZTRAIT_MARINE_MAIN_SHIP, ZTRAIT_GROUND)))
		open()
	else
		close()

/turf/open/shuttle/dropship/floor
	icon_state = "rasputin15"

/obj/machinery/door/poddoor/shutters/transit/nonsmoothing
	smoothing_groups = null

/turf/open/shuttle/dropship/floor/alt
	icon_state = "rasputin14"

/turf/open/shuttle/dropship/floor/corners
	icon_state = "rasputin16"

/turf/open/shuttle/dropship/floor/out
	icon_state = "rasputin17"

/obj/machinery/door/airlock/multi_tile/mainship/dropshiprear/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override)
	. = ..()
	if(!istype(port, /obj/docking_port/mobile/marine_dropship))
		return
	var/obj/docking_port/mobile/marine_dropship/D = port
	D.rear_airlocks += src

/obj/machinery/door/airlock/dropship_hatch/left/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override)
	. = ..()
	if(!istype(port, /obj/docking_port/mobile/marine_dropship))
		return
	var/obj/docking_port/mobile/marine_dropship/D = port
	D.left_airlocks += src

/obj/machinery/door/airlock/dropship_hatch/right/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override)
	. = ..()
	if(!istype(port, /obj/docking_port/mobile/marine_dropship))
		return
	var/obj/docking_port/mobile/marine_dropship/D = port
	D.right_airlocks += src

/obj/machinery/door_control/dropship
	var/obj/docking_port/mobile/marine_dropship/D
	req_one_access = list(ACCESS_MARINE_BRIG, ACCESS_MARINE_SHUTTLE)
	pixel_y = -19
	name = "Dropship Lockdown"

/obj/machinery/door_control/dropship/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override)
	. = ..()
	D = port

/obj/machinery/door_control/dropship/attack_hand(mob/living/user)
	. = ..()
	if(isxeno(user))
		return
	if(!is_operational())
		to_chat(user, span_warning("[src] doesn't seem to be working."))
		return

	if(!allowed(user))
		to_chat(user, span_warning("Access Denied"))
		flick("doorctrl-denied",src)
		return

	use_power(5)
	pressed = TRUE
	update_icon()

	D.lockdown_all()

	addtimer(CALLBACK(src, PROC_REF(unpress)), 15, TIMER_OVERRIDE|TIMER_UNIQUE)
