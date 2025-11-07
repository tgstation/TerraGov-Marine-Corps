// marine dropships
/obj/docking_port/stationary/marine_dropship
	name = "dropship landing zone"
	id = "dropship"
	dir = SOUTH
	dwidth = 5
	dheight = 10
	width = 11
	height = 21

/obj/docking_port/stationary/marine_dropship/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/docking_port/stationary/marine_dropship/LateInitialize()
	for(var/obj/machinery/landinglight/light AS in GLOB.landing_lights)
		if(light.id == id)
			light.linked_port = src

/obj/docking_port/stationary/marine_dropship/on_crash()
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

/obj/docking_port/stationary/marine_dropship/crash_target
	name = "dropshipcrash"
	id = "dropshipcrash"

/obj/docking_port/stationary/marine_dropship/crash_target/Initialize(mapload)
	. = ..()
	SSshuttle.crash_targets += src

/obj/docking_port/stationary/marine_dropship/lz1
	name = "Landing Zone One"
	id = "lz1"

/obj/docking_port/stationary/marine_dropship/lz1/Initialize(mapload)
	. = ..()
	var/area/area = get_area(src)
	area.area_flags |= MARINE_BASE

/obj/docking_port/stationary/marine_dropship/lz1/prison
	name = "LZ1: Main Hangar"

/obj/docking_port/stationary/marine_dropship/lz2
	name = "Landing Zone Two"
	id = "lz2"

/obj/docking_port/stationary/marine_dropship/lz2/Initialize(mapload)
	. = ..()
	var/area/area = get_area(src)
	area.area_flags |= MARINE_BASE

/obj/docking_port/stationary/marine_dropship/lz2/prison
	name = "LZ2: Civ Residence Hangar"

/obj/docking_port/stationary/marine_dropship/hangar/one
	name = "Shipside 'Alamo' Hangar Pad"
	id = SHUTTLE_ALAMO
	roundstart_template = /datum/map_template/shuttle/dropship_one

/obj/docking_port/stationary/marine_dropship/hangar/two
	name = "Shipside 'Normandy' Hangar Pad"
	id = SHUTTLE_NORMANDY
	roundstart_template = /datum/map_template/shuttle/dropship_two
	dheight = 6
	dwidth = 4
	height = 13
	width = 9

#define HIJACK_STATE_NORMAL "hijack_state_normal"
#define HIJACK_STATE_CALLED_DOWN "hijack_state_called_down"
#define HIJACK_STATE_CRASHING "hijack_state_crashing"
#define HIJACK_STATE_UNLOCKED "hijack_state_unlocked"

#define LOCKDOWN_TIME 6 MINUTES
#define GROUND_LOCKDOWN_TIME 3 MINUTES

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

/obj/docking_port/mobile/marine_dropship/register()
	. = ..()
	SSshuttle.dropships += src

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
			human.play_screen_text(HUD_ANNOUNCEMENT_FORMATTING(op_name, "[SSmapping.configs[GROUND_MAP].map_name]<br>[GAME_YEAR]-[time2text(world.realtime, "MM-DD")] [stationTimestamp("hh:mm")]<br>36th Marine LRPRR Platoon<br>[human.job.title], [human]", LEFT_ALIGN_TEXT), /atom/movable/screen/text/screen_text/picture)

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

/obj/docking_port/mobile/marine_dropship/Destroy(force)
	. = ..()
	if(force)
		SSshuttle.dropships -= src

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
	id = SHUTTLE_ALAMO
	control_flags = SHUTTLE_MARINE_PRIMARY_DROPSHIP

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

/obj/docking_port/mobile/marine_dropship/proc/reset_hijack()
	if(hijack_state == HIJACK_STATE_CALLED_DOWN || hijack_state == HIJACK_STATE_UNLOCKED)
		set_hijack_state(HIJACK_STATE_NORMAL)
		silicon_lock_airlocks(FALSE)

/obj/docking_port/mobile/marine_dropship/proc/summon_dropship_to(obj/docking_port/stationary/S)
	if(hijack_state != HIJACK_STATE_NORMAL)
		return
	unlock_all()
	do_start_hijack_timer()
	switch(mode)
		if(SHUTTLE_IDLE)
			set_hijack_state(HIJACK_STATE_CALLED_DOWN)
			request_to(S)
		if(SHUTTLE_RECHARGING)
			set_hijack_state(HIJACK_STATE_CALLED_DOWN)
			playsound(loc,'sound/effects/alert.ogg', 50)
			addtimer(CALLBACK(src, PROC_REF(request_to), S), 15 SECONDS)

/obj/docking_port/mobile/marine_dropship/proc/do_start_hijack_timer(hijack_time = LOCKDOWN_TIME)
	addtimer(CALLBACK(src, PROC_REF(reset_hijack)), hijack_time)

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
	if(hijack_state == HIJACK_STATE_CALLED_DOWN)
		return "Control integrity compromised"
	else if(hijack_state == HIJACK_STATE_UNLOCKED)
		return "Remote control compromised"
	return ..() + (timeleft(cycle_timer) ? (" Automatic cycle : [round(timeleft(cycle_timer) / 10 + 20, 1)] seconds before departure towards [previous.name]") : "")


/obj/docking_port/mobile/marine_dropship/can_move_topic(mob/user)
	if(hijack_state != HIJACK_STATE_NORMAL)
		to_chat(user, span_warning("Control integrity compromised!"))
		return FALSE
	return ..()


/mob/living/carbon/xenomorph/proc/hijack()
	set category = "Alien"
	set name = "Hijack Dropship"
	set desc = "Call down the dropship to the closest LZ or unlock the doors"

	if(!SSticker?.mode)
		to_chat(src, span_warning("This power doesn't work in this gamemode."))

	if(!(hive.hive_flags & HIVE_CAN_HIJACK))
		to_chat(src, span_warning("Our hive lacks the psychic prowess to hijack the bird."))
		return

	var/datum/game_mode/D = SSticker.mode

	if(!D.can_summon_dropship(src))
		return

	to_chat(src, span_warning("You begin calling down the shuttle."))
	if(!do_after(src, 80, IGNORE_HELD_ITEM, null, BUSY_ICON_DANGER, BUSY_ICON_DANGER))
		to_chat(src, span_warning("You stop."))
		return

	if(!D.can_summon_dropship(src))
		return

	D.announce_bioscans()

	var/obj/docking_port/stationary/port = D.summon_dropship(src)
	if(!port)
		to_chat(src, span_warning("Something went wrong."))
		return
	message_admins("[ADMIN_TPMONTY(src)] has summoned the dropship")
	log_admin("[key_name(src)] has summoned the dropship")
	hive?.xeno_message("[src] has summoned down the metal bird to [port], gather to her now!")
	priority_announce("Unknown external interference with dropship control. Shutting down autopilot.", "Critical Dropship Alert", type = ANNOUNCEMENT_PRIORITY, color_override = "red")


#define ALIVE_HUMANS_FOR_CALLDOWN 0.1

/datum/game_mode/proc/can_summon_dropship(mob/user)
	if(user.do_actions)
		user.balloon_alert(user, span_warning("Busy"))
		return FALSE
	if(SSticker.round_start_time + SHUTTLE_HIJACK_LOCK > world.time)
		to_chat(user, span_warning("It's too early to call it. We must wait [DisplayTimeText(SSticker.round_start_time + SHUTTLE_HIJACK_LOCK - world.time, 1)]."))
		return FALSE
	if(!is_ground_level(user.z))
		to_chat(user, span_warning("We can't call the bird from here!"))
		return FALSE
	var/obj/docking_port/mobile/marine_dropship/D
	for(var/k in SSshuttle.dropships)
		var/obj/docking_port/mobile/M = k
		if(M.control_flags & SHUTTLE_MARINE_PRIMARY_DROPSHIP)
			D = M
	if(is_ground_level(D.z))
		var/locked_sides = 0
		for(var/obj/machinery/door/airlock/dropship_hatch/DH AS in D.left_airlocks)
			if(!DH.locked)
				continue
			locked_sides++
			break
		for(var/obj/machinery/door/airlock/dropship_hatch/DH AS in D.right_airlocks)
			if(!DH.locked)
				continue
			locked_sides++
			break
		for(var/obj/machinery/door/airlock/dropship_hatch/DH AS in D.rear_airlocks)
			if(!DH.locked)
				continue
			locked_sides++
			break
		if(!locked_sides)
			to_chat(user, span_warning("The bird is already on the ground, open and vulnerable."))
			return FALSE
		if(locked_sides < 3 && !isdropshiparea(get_area(user)))
			to_chat(user, span_warning("At least one side is still unlocked!"))
			return FALSE
		to_chat(user, span_xenodanger("We crack open the metal bird's shell."))
		if(D.hijack_state != HIJACK_STATE_NORMAL)
			return FALSE
		to_chat(user, span_warning("We begin overriding the shuttle lockdown. This will take a while..."))
		if(!do_after(user, 30 SECONDS, IGNORE_HELD_ITEM, null, BUSY_ICON_DANGER, BUSY_ICON_DANGER))
			to_chat(user, span_warning("We cease overriding the shuttle lockdown."))
			return FALSE
		if(!is_ground_level(D.z))
			to_chat(user, span_warning("The bird has left meanwhile, try again."))
			return FALSE
		D.unlock_all()
		if(D.mode != SHUTTLE_IGNITING)
			D.set_hijack_state(HIJACK_STATE_UNLOCKED)
			D.do_start_hijack_timer(GROUND_LOCKDOWN_TIME)
			to_chat(user, span_warning("We were unable to prevent the bird from flying as it is already taking off."))
		D.silicon_lock_airlocks(TRUE)
		to_chat(user, span_warning("We have overriden the shuttle lockdown!"))
		playsound(user, SFX_ALIEN_ROAR, 50)
		priority_announce("Alamo lockdown protocol compromised. Interference preventing remote control.", "Dropship Lock Alert", type = ANNOUNCEMENT_PRIORITY, color_override = "red")
		return FALSE
	if(D.mode != SHUTTLE_IDLE && D.mode != SHUTTLE_RECHARGING)
		to_chat(user, span_warning("The bird's mind is currently active. We need to wait until it's more vulnerable..."))
		return FALSE
	var/humans_on_ground = 0
	for(var/i in SSmapping.levels_by_trait(ZTRAIT_GROUND))
		for(var/m in GLOB.humans_by_zlevel["[i]"])
			var/mob/living/carbon/human/H = m
			if(isnestedhost(H))
				continue
			if(H.faction == FACTION_XENO)
				continue
			humans_on_ground++
	if(length(GLOB.alive_human_list) && ((humans_on_ground / length(GLOB.alive_human_list)) > ALIVE_HUMANS_FOR_CALLDOWN))
		to_chat(user, span_warning("There's too many tallhosts still on the ground. They interfere with our psychic field. We must dispatch them before we are able to do this."))
		return FALSE
	return TRUE

// summon dropship to closest lz to A
/datum/game_mode/proc/summon_dropship(atom/A)
	var/list/lzs = list()
	for(var/i in SSshuttle.stationary)
		var/obj/docking_port/stationary/S = i
		if(S.z != A.z)
			continue
		if(S.id == "lz1" || S.id == "lz2")
			lzs[S] = get_dist(S, A)
	if(!length(lzs))
		stack_trace("couldn't find any lzs to call down the dropship to")
		return FALSE
	var/obj/docking_port/stationary/closest = lzs[1]
	for(var/j in lzs)
		if(lzs[j] < lzs[closest])
			closest = j
	var/obj/docking_port/mobile/marine_dropship/D
	for(var/k in SSshuttle.dropships)
		var/obj/docking_port/mobile/M = k
		if(M.control_flags & SHUTTLE_MARINE_PRIMARY_DROPSHIP)
			D = M
	D.summon_dropship_to(closest)
	return closest

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
	req_one_access = list(ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LEADER) // TLs can only operate the remote console
	possible_destinations = "lz1;lz2;alamo"
	opacity = FALSE

/obj/machinery/computer/shuttle/marine_dropship/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, armor_penetration = xeno_attacker.xeno_caste.melee_ap, isrightclick = FALSE)
	var/datum/game_mode/infestation/infestation_mode = SSticker.mode //Minor QOL, any xeno can check the console after a leader hijacks
	if(!(xeno_attacker.xeno_caste.caste_flags & CASTE_IS_INTELLIGENT) && (infestation_mode.round_stage != INFESTATION_MARINE_CRASHING))
		return
	if(xeno_attacker.hive.living_xeno_ruler != xeno_attacker) //If we aren't the actual hive leader, prevent us from controling alamo
		to_chat(xeno_attacker, span_xenowarning("We must be the hive leader!"))
		return
	#ifndef TESTING
	if(SSticker.round_start_time + SHUTTLE_HIJACK_LOCK > world.time)
		to_chat(xeno_attacker, span_xenowarning("It's too early to do this!"))
		return
	#endif
	var/obj/docking_port/mobile/marine_dropship/shuttle = SSshuttle.getShuttle(shuttleId)
	if(shuttle.hijack_state != HIJACK_STATE_CALLED_DOWN && shuttle.hijack_state != HIJACK_STATE_CRASHING) //Process of corrupting the controls
		to_chat(xeno_attacker, span_xenowarning("We corrupt the bird's controls, unlocking the doors and preventing it from flying."))
		SEND_GLOBAL_SIGNAL(COMSIG_GLOB_DROPSHIP_CONTROLS_CORRUPTED, src)
		shuttle.set_idle()
		shuttle.set_hijack_state(HIJACK_STATE_CALLED_DOWN)
		shuttle.do_start_hijack_timer()
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
	data["hijack_disabled"] = data["shuttle_hijacked"] || !(SSticker.mode.round_type_flags & MODE_HIJACK_POSSIBLE) // Disable if already hijacking or hijacking not allowed.


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

	var/list/options = valid_destinations()
	var/list/valid_destinations = list()
	for(var/obj/docking_port/stationary/S in SSshuttle.stationary)
		if(!options.Find(S.id))
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
			var/datum/game_mode/infestation/infestation_mode = SSticker.mode
			if(!istype(infestation_mode) || infestation_mode.round_stage == INFESTATION_MARINE_CRASHING)
				return
			if(!(infestation_mode.round_type_flags & MODE_HIJACK_POSSIBLE))
				to_chat(usr, span_warning("Hijacking is not possible."))
				return
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
			var/obj/docking_port/stationary/marine_dropship/crash_target/CT = pick(SSshuttle.crash_targets)
			if(!CT)
				return
			if(SSmonitor.gamestate == SHIPSIDE)
				to_chat(xeno, span_xenowarning("The shuttle is already at the ship!"))
				return

			do_hijack(shuttle, CT, xeno)

		if("abduct")
			var/datum/game_mode/infestation/infestation_mode = SSticker.mode
			if(!istype(infestation_mode))
				return
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

/obj/machinery/computer/shuttle/marine_dropship/proc/do_hijack(obj/docking_port/mobile/marine_dropship/crashing_dropship, obj/docking_port/stationary/marine_dropship/crash_target/crash_target, mob/living/carbon/xenomorph/user)
	var/datum/game_mode/infestation/infestation_mode = SSticker.mode
	if(!istype(infestation_mode))
		return
	infestation_mode.round_stage = INFESTATION_MARINE_CRASHING
	crashing_dropship.set_hijack_state(HIJACK_STATE_CRASHING)
	crashing_dropship.callTime = 120 * (GLOB.current_orbit/3) SECONDS
	crashing_dropship.crashing = TRUE
	crashing_dropship.unlock_all()
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_DROPSHIP_HIJACKED)
	priority_announce("Unscheduled dropship departure detected from operational area. Hijack likely.", title = "Critical Dropship Alert", type = ANNOUNCEMENT_PRIORITY, sound = 'sound/AI/hijack.ogg', color_override = "red")
	to_chat(user, span_danger("A loud alarm erupts from [src]! The fleshy hosts must know that you can access it!"))
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
	possible_destinations = "lz1;lz2;alamo"

/obj/machinery/computer/shuttle/marine_dropship/one/Initialize(mapload)
	. = ..()
	for(var/trait in SSmapping.configs[SHIP_MAP].environment_traits)
		if(ZTRAIT_DOUBLE_SHIPS in trait)
			possible_destinations = "lz2;alamo"

/obj/machinery/computer/shuttle/marine_dropship/two
	name = "\improper 'Normandy' flight controls"
	desc = "The flight controls for the 'Normandy' Dropship. Named after a department in France, noteworthy for the famous naval invasion of Normandy on the 6th of June 1944, a bloody but decisive victory in World War II and the campaign for the Liberation of France."
	icon_state = "dropship_console2"
	screen_overlay = "dropship_console2_emissive"
	possible_destinations = "lz1;lz2;alamo;normandy"

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
	req_one_access = list(ACCESS_MARINE_BRIG, ACCESS_MARINE_DROPSHIP)
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

// half-tile structure pieces
/obj/structure/dropship_piece
	icon = 'icons/obj/structures/dropship_structures.dmi'
	density = TRUE
	resistance_flags = RESIST_ALL
	opacity = TRUE
	allow_pass_flags = PASS_PROJECTILE|PASS_AIR
	explosion_block = EXPLOSION_BLOCK_PROC

/obj/structure/dropship_piece/GetExplosionBlock(explosion_dir)
	if(!density)
		return 0
	if(opacity)
		return 2
	if(allow_pass_flags & PASS_GLASS)
		return 2
	return 0

/obj/structure/dropship_piece/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_SPARKS, -40, 8, 1)

/obj/structure/dropship_piece/ex_act(severity)
	return

/obj/structure/dropship_piece/beforeShuttleMove(turf/newT, rotation, move_mode, obj/docking_port/mobile/moving_dock)
	. = ..()
	if(. & MOVE_AREA)
		ENABLE_BITFIELD(., MOVE_CONTENTS)
		DISABLE_BITFIELD(., MOVE_TURF)

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


/obj/structure/dropship_piece/one/weapon
	opacity = FALSE

/obj/structure/dropship_piece/one/weapon/leftleft
	icon_state = "brown_weapon_ll"

/obj/structure/dropship_piece/one/weapon/leftright
	icon_state = "brown_weapon_lr"

/obj/structure/dropship_piece/one/weapon/rightleft
	icon_state = "brown_weapon_rl"

/obj/structure/dropship_piece/one/weapon/rightright
	icon_state = "brown_weapon_rr"


/obj/structure/dropship_piece/one/wing
	opacity = FALSE

/obj/structure/dropship_piece/one/wing/left/top
	icon_state = "brown_wing_lt"

/obj/structure/dropship_piece/one/wing/left/bottom
	icon_state = "brown_wing_lb"

/obj/structure/dropship_piece/one/wing/right/top
	icon_state = "brown_wing_rt"

/obj/structure/dropship_piece/one/wing/right/bottom
	icon_state = "brown_wing_rb"


/obj/structure/dropship_piece/one/corner/middleleft
	icon_state = "brown_middle_lc"

/obj/structure/dropship_piece/one/corner/middleright
	icon_state = "brown_middle_rc"

/obj/structure/dropship_piece/one/corner/rearleft
	icon_state = "brown_rear_lc"

/obj/structure/dropship_piece/one/corner/rearright
	icon_state = "brown_rear_rc"


/obj/structure/dropship_piece/one/engine
	opacity = FALSE

/obj/structure/dropship_piece/one/engine/lefttop
	icon_state = "brown_engine_lt"

/obj/structure/dropship_piece/one/engine/righttop
	icon_state = "brown_engine_rt"

/obj/structure/dropship_piece/one/engine/leftbottom
	icon_state = "brown_engine_lb"

/obj/structure/dropship_piece/one/engine/rightbottom
	icon_state = "brown_engine_rb"

/obj/structure/dropship_piece/one/rearwing/lefttop
	icon_state = "brown_rearwing_lt"

/obj/structure/dropship_piece/one/rearwing/righttop
	icon_state = "brown_rearwing_rt"

/obj/structure/dropship_piece/one/rearwing/leftbottom
	icon_state = "brown_rearwing_lb"

/obj/structure/dropship_piece/one/rearwing/rightbottom
	icon_state = "brown_rearwing_rb"

/obj/structure/dropship_piece/one/rearwing/leftlbottom
	icon_state = "brown_rearwing_llb"
	opacity = FALSE
	allow_pass_flags = PASSABLE

/obj/structure/dropship_piece/one/rearwing/rightrbottom
	icon_state = "brown_rearwing_rrb"
	opacity = FALSE
	allow_pass_flags = PASSABLE

/obj/structure/dropship_piece/one/rearwing/leftllbottom
	icon_state = "brown_rearwing_lllb"
	opacity = FALSE
	allow_pass_flags = PASSABLE

/obj/structure/dropship_piece/one/rearwing/rightrrbottom
	icon_state = "brown_rearwing_rrrb"
	opacity = FALSE
	allow_pass_flags = PASSABLE



/obj/structure/dropship_piece/two
	name = "\improper Normandy"

/obj/structure/dropship_piece/two/front
	icon_state = "blue_front"
	opacity = FALSE

/obj/structure/dropship_piece/two/front/right
	icon_state = "blue_fr"

/obj/structure/dropship_piece/two/front/left
	icon_state = "blue_fl"

/obj/structure/dropship_piece/tadpole
	name = "\improper Tadpole"

/obj/structure/dropship_piece/tadpole/rearleft
	icon_state = "blue_rear_lc"

/obj/structure/dropship_piece/tadpole/rearright
	icon_state = "blue_rear_rc"

/obj/structure/dropship_piece/glassone
	icon = 'icons/turf/dropship2.dmi'
	icon_state = "shuttle_glass1"

/obj/structure/dropship_piece/glassone/tadpole
	icon_state = "shuttle_glass1"
	max_integrity = 600
	resistance_flags = XENO_DAMAGEABLE | DROPSHIP_IMMUNE
	opacity = FALSE
	allow_pass_flags = PASS_GLASS

/obj/structure/dropship_piece/glasstwo
	icon = 'icons/turf/dropship2.dmi'
	icon_state = "shuttle_glass2"

/obj/structure/dropship_piece/glasstwo/tadpole
	icon = 'icons/turf/dropship2.dmi'
	icon_state = "shuttle_glass2"
	max_integrity = 600
	resistance_flags = XENO_DAMAGEABLE | DROPSHIP_IMMUNE
	opacity = FALSE
	allow_pass_flags = PASS_GLASS

/obj/structure/dropship_piece/singlewindow/tadpole
	icon = 'icons/turf/dropship2.dmi'
	icon_state = "shuttle_single_window"
	max_integrity = 600
	allow_pass_flags = PASS_GLASS
	resistance_flags = XENO_DAMAGEABLE | DROPSHIP_IMMUNE
	opacity = FALSE

/obj/structure/dropship_piece/tadpole/cockpit
	desc = "The nose part of the tadpole, able to be destroyed."
	max_integrity = 600
	resistance_flags = XENO_DAMAGEABLE | DROPSHIP_IMMUNE
	opacity = FALSE
	layer = BELOW_OBJ_LAYER
	allow_pass_flags = NONE

/obj/structure/dropship_piece/tadpole/cockpit/left
	icon_state = "blue_cockpit_fl"

/obj/structure/dropship_piece/tadpole/cockpit/right
	icon_state = "blue_cockpit_fr"

/obj/structure/dropship_piece/tadpole/cockpit/window
	icon = 'icons/turf/dropship2.dmi'
	icon_state = "1"

/obj/structure/dropship_piece/tadpole/engine
	icon_state = "tadpole_engine"
	density = FALSE
	opacity = FALSE

/obj/structure/dropship_piece/tadpole/tadpole_nose
	icon_state = "blue_front"
	opacity = FALSE
	density = FALSE

/obj/structure/dropship_piece/tadpole/tadpole_nose/right
	icon_state = "blue_fr"

/obj/structure/dropship_piece/tadpole/tadpole_nose/left
	icon_state = "blue_fl"

/obj/structure/dropship_piece/two/cockpit/left
	icon_state = "blue_cockpit_fl"

/obj/structure/dropship_piece/two/cockpit/right
	icon_state = "blue_cockpit_fr"


/obj/structure/dropship_piece/two/weapon
	opacity = FALSE

/obj/structure/dropship_piece/two/weapon/leftleft
	icon_state = "blue_weapon_ll"

/obj/structure/dropship_piece/two/weapon/leftright
	icon_state = "blue_weapon_lr"

/obj/structure/dropship_piece/two/weapon/rightleft
	icon_state = "blue_weapon_rl"

/obj/structure/dropship_piece/two/weapon/rightright
	icon_state = "blue_weapon_rr"


/obj/structure/dropship_piece/two/wing
	opacity = FALSE

/obj/structure/dropship_piece/two/wing/left/top
	icon_state = "blue_wing_lt"

/obj/structure/dropship_piece/two/wing/left/bottom
	icon_state = "blue_wing_lb"

/obj/structure/dropship_piece/two/wing/right/top
	icon_state = "blue_wing_rt"

/obj/structure/dropship_piece/two/wing/right/bottom
	icon_state = "blue_wing_rb"


/obj/structure/dropship_piece/two/corner/middleleft
	icon_state = "blue_middle_lc"

/obj/structure/dropship_piece/two/corner/middleright
	icon_state = "blue_middle_rc"

/obj/structure/dropship_piece/two/corner/rearleft
	icon_state = "blue_rear_lc"

/obj/structure/dropship_piece/two/corner/rearright
	icon_state = "blue_rear_rc"

/obj/structure/dropship_piece/two/corner/frontleft
	icon_state = "blue_front_lc"

/obj/structure/dropship_piece/two/corner/frontright
	icon_state = "blue_front_rc"


/obj/structure/dropship_piece/two/engine
	opacity = FALSE

/obj/structure/dropship_piece/two/engine/lefttop
	icon_state = "blue_engine_lt"

/obj/structure/dropship_piece/two/engine/righttop
	icon_state = "blue_engine_rt"

/obj/structure/dropship_piece/two/engine/leftbottom
	icon_state = "blue_engine_lb"

/obj/structure/dropship_piece/two/engine/rightbottom
	icon_state = "blue_engine_rb"


/obj/structure/dropship_piece/two/rearwing/lefttop
	icon_state = "blue_rearwing_lt"

/obj/structure/dropship_piece/two/rearwing/righttop
	icon_state = "blue_rearwing_rt"

/obj/structure/dropship_piece/two/rearwing/leftbottom
	icon_state = "blue_rearwing_lb"

/obj/structure/dropship_piece/two/rearwing/rightbottom
	icon_state = "blue_rearwing_rb"

/obj/structure/dropship_piece/two/rearwing/leftlbottom
	icon_state = "blue_rearwing_llb"
	opacity = FALSE

/obj/structure/dropship_piece/two/rearwing/rightrbottom
	icon_state = "blue_rearwing_rrb"
	opacity = FALSE

/obj/structure/dropship_piece/two/rearwing/leftllbottom
	icon_state = "blue_rearwing_lllb"
	opacity = FALSE

/obj/structure/dropship_piece/two/rearwing/rightrrbottom
	icon_state = "blue_rearwing_rrrb"
	opacity = FALSE


/obj/structure/dropship_piece/three
	name = "\improper Triumph"

/obj/structure/dropship_piece/three/front
	icon_state = "brown_front"
	opacity = FALSE

/obj/structure/dropship_piece/three/front/right
	icon_state = "brown_fr"

/obj/structure/dropship_piece/three/front/left
	icon_state = "brown_fl"


/obj/structure/dropship_piece/three/cockpit/left
	icon_state = "brown_cockpit_fl"

/obj/structure/dropship_piece/three/cockpit/right
	icon_state = "brown_cockpit_fr"


/obj/structure/dropship_piece/three/weapon
	opacity = FALSE

/obj/structure/dropship_piece/three/weapon/leftleft
	icon_state = "brown_weapon_ll"

/obj/structure/dropship_piece/three/weapon/leftright
	icon_state = "brown_weapon_lr"

/obj/structure/dropship_piece/three/weapon/rightleft
	icon_state = "brown_weapon_rl"

/obj/structure/dropship_piece/three/weapon/rightright
	icon_state = "brown_weapon_rr"


/obj/structure/dropship_piece/three/wing
	opacity = FALSE

/obj/structure/dropship_piece/three/wing/left/top
	icon_state = "brown_wing_lt"

/obj/structure/dropship_piece/three/wing/left/bottom
	icon_state = "brown_wing_lb"

/obj/structure/dropship_piece/three/wing/right/top
	icon_state = "brown_wing_rt"

/obj/structure/dropship_piece/three/wing/right/bottom
	icon_state = "brown_wing_rb"


/obj/structure/dropship_piece/three/corner/middleleft
	icon_state = "brown_middle_lc"

/obj/structure/dropship_piece/three/corner/middleright
	icon_state = "brown_middle_rc"

/obj/structure/dropship_piece/three/corner/rearleft
	icon_state = "brown_rear_lc"

/obj/structure/dropship_piece/three/corner/rearright
	icon_state = "brown_rear_rc"


/obj/structure/dropship_piece/three/engine
	opacity = FALSE

/obj/structure/dropship_piece/three/engine/lefttop
	icon_state = "brown_engine_lt"

/obj/structure/dropship_piece/three/engine/righttop
	icon_state = "brown_engine_rt"

/obj/structure/dropship_piece/three/engine/leftbottom
	icon_state = "brown_engine_lb"

/obj/structure/dropship_piece/three/engine/rightbottom
	icon_state = "brown_engine_rb"


/obj/structure/dropship_piece/three/rearwing/lefttop
	icon_state = "brown_rearwing_lt"

/obj/structure/dropship_piece/three/rearwing/righttop
	icon_state = "brown_rearwing_rt"

/obj/structure/dropship_piece/three/rearwing/leftbottom
	icon_state = "brown_rearwing_lb"

/obj/structure/dropship_piece/three/rearwing/rightbottom
	icon_state = "brown_rearwing_rb"

/obj/structure/dropship_piece/three/rearwing/leftlbottom
	icon_state = "brown_rearwing_llb"
	opacity = FALSE

/obj/structure/dropship_piece/three/rearwing/rightrbottom
	icon_state = "brown_rearwing_rrb"
	opacity = FALSE

/obj/structure/dropship_piece/three/rearwing/leftllbottom
	icon_state = "brown_rearwing_lllb"
	opacity = FALSE

/obj/structure/dropship_piece/three/rearwing/rightrrbottom
	icon_state = "brown_rearwing_rrrb"
	opacity = FALSE

/obj/structure/dropship_piece/four/dropshipfront
	icon_state = "dropshipfrontwhite1"
	opacity = FALSE

/obj/structure/dropship_piece/four/dropshipventone
	icon_state = "dropshipvent1"

/obj/structure/dropship_piece/four/dropshipventtwo
	icon_state = "dropshipvent2"

/obj/structure/dropship_piece/four/dropshipwingtopone
	icon_state = "dropshipwingtop1"

/obj/structure/dropship_piece/four/dropshipwingtoptwo
	icon_state = "dropshipwingtop2"

/obj/structure/dropship_piece/four/dropshipventthree
	icon_state = "dropshipvent3"

/obj/structure/dropship_piece/four/dropshipventfour
	icon_state = "dropshipvent4"

/obj/structure/dropship_piece/four/rearwing/lefttop
	icon_state = "white_rearwing_lt"

/obj/structure/dropship_piece/four/rearwing/righttop
	icon_state = "white_rearwing_rt"

/obj/structure/dropship_piece/four/rearwing/leftbottom
	icon_state = "white_rearwing_lb"

/obj/structure/dropship_piece/four/rearwing/rightbottom
	icon_state = "white_rearwing_rb"

//Dropship control console

/obj/machinery/computer/shuttle/shuttle_control
	name = "shuttle control console"
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "computer_small"
	screen_overlay = "shuttle"
	///Able to auto-relink to any shuttle with at least one of the flags in common if shuttleId is invalid.
	var/compatible_control_flags = NONE


/obj/machinery/computer/shuttle/shuttle_control/Initialize(mapload)
	. = ..()
	GLOB.shuttle_controls_list += src


/obj/machinery/computer/shuttle/shuttle_control/Destroy()
	GLOB.shuttle_controls_list -= src
	return ..()


/obj/machinery/computer/shuttle/shuttle_control/ui_interact(mob/user, datum/tgui/ui)
	if(!(SSshuttle.getShuttle(shuttleId)))
		RelinkShuttleId()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ShuttleControl")
		ui.open()

/obj/machinery/computer/shuttle/shuttle_control/ui_state(mob/user)
	return GLOB.access_state

/obj/machinery/computer/shuttle/shuttle_control/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	if(action != "selectDestination")
		return FALSE

	var/obj/docking_port/mobile/shuttle = SSshuttle.getShuttle(shuttleId)
	#ifndef TESTING
	if(!(shuttle.shuttle_flags & GAMEMODE_IMMUNE) && world.time < SSticker.round_start_time + SSticker.mode.deploy_time_lock)
		to_chat(usr, span_warning("The engines are still refueling."))
		return TRUE
	#endif
	if(!shuttle.can_move_topic(usr))
		return TRUE

	if(!params["destination"])
		return TRUE

	if(!(params["destination"] in valid_destinations()))
		log_admin("[key_name(usr)] may be attempting a href dock exploit on [src] with target location \"[html_encode(params["destination"])]\"")
		message_admins("[ADMIN_TPMONTY(usr)] may be attempting a href dock exploit on [src] with target location \"[html_encode(params["destination"])]\"")
		return TRUE

	var/previous_status = shuttle.mode
	log_game("[key_name(usr)] has sent the shuttle [shuttle] to [params["destination"]]")

	switch(SSshuttle.moveShuttle(shuttleId, params["destination"], 1))
		if(0)
			if(previous_status != SHUTTLE_IDLE)
				visible_message(span_notice("Destination updated, recalculating route."))
			else
				visible_message(span_notice("Shuttle departing. Please stand away from the doors."))
				for(var/mob/living/silicon/ai/AI AS in GLOB.ai_list)
					if(!AI.client)
						continue
					to_chat(AI, span_info("[src] was commanded remotely to take off."))
			return TRUE
		if(1)
			to_chat(usr, span_warning("Invalid shuttle requested."))
			return TRUE
		else
			to_chat(usr, span_notice("Unable to comply."))
			return TRUE

/obj/machinery/computer/shuttle/shuttle_control/ui_data(mob/user)
	var/list/data = list()
	var/list/options = valid_destinations()
	var/obj/docking_port/mobile/shuttle = SSshuttle.getShuttle(shuttleId)
	if(!shuttle)
		return data //empty but oh well

	data["linked_shuttle_name"] = shuttle.name
	data["shuttle_status"] = shuttle.getStatusText()
	for(var/option in options)
		for(var/obj/docking_port/stationary/S AS in SSshuttle.stationary)
			if(option != S.id)
				continue
			var/list/dataset = list()
			dataset["id"] = S.id
			dataset["name"] = S.name
			dataset["locked"] = !shuttle.check_dock(S, silent=TRUE)
			data["destinations"] += list(dataset)
	return data

/obj/machinery/computer/shuttle/shuttle_control/attack_ghost(mob/dead/observer/user)
	var/list/all_destinations = splittext(possible_destinations,";")

	if(length(all_destinations) < 2)
		return

	// Getting all valid destinations into an assoc list with "name" = "portid"
	var/list/port_assoc = list()
	for(var/destination in all_destinations)
		for(var/obj/docking_port/port AS in SSshuttle.stationary)
			if(destination != port.id)
				continue
			port_assoc["[port.name]"] = destination

	var/list/destinations = list()
	for(var/destination in port_assoc)
		destinations += destination
	var/input = tgui_input_list(user, "Choose a port to teleport to:", "Ghost Shuttle teleport", destinations, null, 0)
	if(!input)
		return
	var/obj/docking_port/mobile/target_port = SSshuttle.getDock(port_assoc[input])

	if(!target_port || QDELETED(target_port) || !target_port.loc)
		return
	user.forceMove(get_turf(target_port))

/// Relinks the shuttleId in the console to a valid shuttle currently existing. Will only relink to a shuttle with a matching control_flags flag. Returns true if successfully relinked
/obj/machinery/computer/shuttle/shuttle_control/proc/RelinkShuttleId(forcedId)
	var/newId = null
	/// The preferred shuttleId to link to if it exists.
	var/preferredId = initial(shuttleId)
	var/obj/docking_port/mobile/M
	var/shuttleName = "Unknown"
	if(forcedId)
		M = SSshuttle.getShuttle(forcedId)
		if(!M)
			return FALSE
		newId = M.id
		shuttleName = M.name
	else
		M = null
		for(M AS in SSshuttle.mobile)
			if(!(M.control_flags & compatible_control_flags)) //Need at least one matching control flag
				continue
			newId = M.id
			shuttleName = M.name
			if(M.id == preferredId) //Lock selection in if we get the initial shuttleId of this console.
				break
	if(!newId)
		return FALSE //Did not relink

	if(newId == shuttleId)
		return TRUE //Did not relink but didn't have to since it is the same reference.

	shuttleId = newId
	name = "\improper '[shuttleName]' dropship console"
	desc = "The remote controls for the '[shuttleName]' Dropship."
	say("Relinked Dropship Control Console to: '[shuttleName]'")
	return TRUE //Did relink



/obj/machinery/computer/shuttle/shuttle_control/dropship
	name = "\improper 'Alamo' dropship console"
	desc = "The remote controls for the 'Alamo' Dropship. Named after the Alamo Mission, stage of the Battle of the Alamo in the United States' state of Texas in the Spring of 1836. The defenders held to the last, encouraging other Texans to rally to the flag."
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "computer_small"
	screen_overlay = "shuttle"
	resistance_flags = RESIST_ALL
	req_one_access = list(ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LEADER) // TLs can only operate the remote console
	shuttleId = SHUTTLE_ALAMO
	possible_destinations = "lz1;lz2;alamo"
	compatible_control_flags = SHUTTLE_MARINE_PRIMARY_DROPSHIP


/obj/machinery/computer/shuttle/shuttle_control/dropship/two
	name = "\improper 'Normandy' dropship console"
	desc = "The remote controls for the 'Normandy' Dropship. Named after a department in France, noteworthy for the famous naval invasion of Normandy on the 6th of June 1944, a bloody but decisive victory in World War II and the campaign for the Liberation of France."
	shuttleId = SHUTTLE_NORMANDY
	possible_destinations = "lz1;lz2;alamo;normandy"

/obj/machinery/computer/shuttle/shuttle_control/canterbury
	name = "\improper 'Canterbury' shuttle console"
	desc = "The remote controls for the 'Canterbury' shuttle."
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "computer_small"
	screen_overlay = "shuttle"
	resistance_flags = RESIST_ALL
	shuttleId = SHUTTLE_CANTERBURY
	possible_destinations = "canterbury_loadingdock"

/obj/machinery/computer/shuttle/shuttle_control/canterbury/ui_interact(mob/user)
	if(!allowed(user))
		to_chat(user, span_warning("Access Denied!"))
		return
	var/obj/docking_port/mobile/M = SSshuttle.getShuttle(shuttleId)
	var/dat = "Status: [M ? M.getStatusText() : "*Missing*"]<br><br>"
	if(M)
		dat += "<A href='byond://?src=[REF(src)];move=crash-infinite-transit'>Initiate Evacuation</A><br>"

	var/datum/browser/popup = new(user, "computer", M ? M.name : "shuttle", 300, 200)
	popup.set_content("<center>[dat]</center>")
	popup.open()


/obj/machinery/computer/shuttle/shuttle_control/canterbury/Topic(href, href_list)
	// Since we want to avoid the standard move topic, we are just gonna override everything.
	add_fingerprint(usr, "topic")
	if(!can_interact(usr))
		return TRUE
	if(isxeno(usr))
		return TRUE
	if(!allowed(usr))
		to_chat(usr, span_danger("Access denied."))
		return TRUE
	if(!href_list["move"] || !iscrashgamemode(SSticker.mode))
		to_chat(usr, span_warning("[src] is unresponsive."))
		return FALSE

	if(!length(GLOB.active_nuke_list) && tgui_alert(usr, "Are you sure you want to launch the shuttle? Without sufficiently dealing with the threat, you will be in direct violation of your orders!", "Are you sure?", list("Yes", "Cancel")) != "Yes")
		return TRUE

	log_admin("[key_name(usr)] is launching the canterbury[!length(GLOB.active_nuke_list)? " early" : ""].")
	message_admins("[ADMIN_TPMONTY(usr)] is launching the canterbury[!length(GLOB.active_nuke_list)? " early" : ""].")

	var/obj/docking_port/mobile/M = SSshuttle.getShuttle(shuttleId)
	#ifndef TESTING
	if(!(M.shuttle_flags & GAMEMODE_IMMUNE) && world.time < SSticker.round_start_time + SSticker.mode.deploy_time_lock)
		to_chat(usr, span_warning("The engines are still refueling."))
		return TRUE
	#endif
	if(!M.can_move_topic(usr))
		return TRUE

	visible_message(span_notice("Shuttle departing. Please stand away from the doors."))
	M.destination = null
	M.mode = SHUTTLE_IGNITING
	M.setTimer(M.ignitionTime)

	var/datum/game_mode/infestation/crash/C = SSticker.mode
	addtimer(VARSET_CALLBACK(C, marines_evac, CRASH_EVAC_INPROGRESS), M.ignitionTime + 10 SECONDS)
	addtimer(VARSET_CALLBACK(C, marines_evac, CRASH_EVAC_COMPLETED), 2 MINUTES)
	return TRUE
