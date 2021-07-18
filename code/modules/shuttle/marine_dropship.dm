// marine dropships
/obj/docking_port/stationary/marine_dropship
	name = "dropship landing zone"
	id = "dropship"
	dir = SOUTH
	dwidth = 5
	dheight = 10
	width = 11
	height = 21


/obj/docking_port/stationary/marine_dropship/on_crash()
	for(var/i in GLOB.apcs_list) //break APCs
		var/obj/machinery/power/apc/A = i
		if(!is_mainship_level(A.z))
			continue
		if(prob(A.crash_break_probability))
			A.overload_lighting()
			A.set_broken()
		CHECK_TICK

	for(var/i in GLOB.alive_living_list) //knock down mobs
		var/mob/living/M = i
		if(!is_mainship_level(M.z))
			continue
		if(M.buckled)
			to_chat(M, "<span class='warning'>You are jolted against [M.buckled]!</span>")
			shake_camera(M, 3, 1)
		else
			to_chat(M, "<span class='warning'>The floor jolts under your feet!</span>")
			shake_camera(M, 10, 1)
			M.Paralyze(60)
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
		T.empty(/turf/open/floor/plating)

	/*
	explosion(front, 2, 4, 7, 0)
	explosion(rear, 3, 5, 8, 0)
	explosion(left, 3, 5, 8, 0)
	explosion(right, 3, 5, 8, 0)*/

/obj/docking_port/stationary/marine_dropship/crash_target
	name = "dropshipcrash"
	id = "dropshipcrash"

/obj/docking_port/stationary/marine_dropship/crash_target/Initialize()
	. = ..()
	SSshuttle.crash_targets += src

/obj/docking_port/stationary/marine_dropship/lz1
	name = "Landing Zone One"
	id = "lz1"

/obj/docking_port/stationary/marine_dropship/lz1/prison
	name = "LZ1: Main Hangar"

/obj/docking_port/stationary/marine_dropship/lz2
	name = "Landing Zone Two"
	id = "lz2"

/obj/docking_port/stationary/marine_dropship/lz2/prison
	name = "LZ2: Civ Residence Hangar"

/obj/docking_port/stationary/marine_dropship/hangar/one
	name = "Shipside 'Alamo' Hangar Pad"
	id = "alamo"
	roundstart_template = /datum/map_template/shuttle/dropship_one

/obj/docking_port/stationary/marine_dropship/hangar/rebel
	name = "Shipside 'Triumph' Hangar Pad"
	id = "triumph"
	roundstart_template = /datum/map_template/shuttle/dropship_three

/obj/docking_port/stationary/marine_dropship/hangar/two
	name = "Shipside 'Normandy' Hangar Pad"
	id = "normandy"
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

/obj/docking_port/mobile/marine_dropship/register()
	. = ..()
	SSshuttle.dropships += src

/obj/docking_port/mobile/marine_dropship/enterTransit()
	. = ..()
	if(!.) // it failed in parent
		return
	// pull the shuttle from datum/source, and state info from the shuttle itself
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_DROPSHIP_TRANSIT)

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

/obj/docking_port/mobile/marine_dropship/Destroy(force)
	. = ..()
	if(force)
		SSshuttle.dropships -= src

/obj/docking_port/mobile/marine_dropship/initiate_docking(obj/docking_port/stationary/new_dock, movement_direction, force=FALSE)
	if(crashing)
		force = TRUE

	return ..()

/obj/docking_port/mobile/marine_dropship/one
	name = "Alamo"
	id = "alamo"
	control_flags = SHUTTLE_MARINE_PRIMARY_DROPSHIP

/obj/docking_port/mobile/marine_dropship/two
	name = "Normandy"
	id = "normandy"
	control_flags = SHUTTLE_MARINE_PRIMARY_DROPSHIP
	callTime = 28 SECONDS //smaller shuttle go whoosh
	rechargeTime = 1.5 MINUTES
	dheight = 6
	dwidth = 4
	height = 13
	width = 9

/obj/docking_port/mobile/marine_dropship/three
	name = "Triumph"
	id = "triumph"
	control_flags = SHUTTLE_REBEL_PRIMARY_DROPSHIP

// queen calldown

/obj/docking_port/mobile/marine_dropship/afterShuttleMove(turf/oldT, rotation)
	. = ..()
	if(hijack_state != HIJACK_STATE_CALLED_DOWN)
		return
	unlock_all()

/obj/docking_port/mobile/marine_dropship/proc/reset_hijack()
	if(hijack_state == HIJACK_STATE_CALLED_DOWN || hijack_state == HIJACK_STATE_UNLOCKED)
		set_hijack_state(HIJACK_STATE_NORMAL)

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
			addtimer(CALLBACK(src, .proc/request_to, S), 15 SECONDS)


/obj/docking_port/mobile/marine_dropship/proc/do_start_hijack_timer(hijack_time = LOCKDOWN_TIME)
	addtimer(CALLBACK(src, .proc/reset_hijack), hijack_time)


/obj/docking_port/mobile/marine_dropship/proc/request_to(obj/docking_port/stationary/S)
	set_idle()
	request(S)

/obj/docking_port/mobile/marine_dropship/proc/set_hijack_state(new_state)
	hijack_state = new_state

/obj/docking_port/mobile/marine_dropship/on_prearrival()
	. = ..()
	if(hijack_state == HIJACK_STATE_CRASHING)
		priority_announce("DROPSHIP ON COLLISION COURSE. CRASH IMMINENT." , "EMERGENCY", sound = 'sound/AI/dropship_emergency.ogg')


/obj/docking_port/mobile/marine_dropship/getStatusText()
	if(hijack_state == HIJACK_STATE_CALLED_DOWN)
		return "Control integrity compromised"
	else if(hijack_state == HIJACK_STATE_UNLOCKED)
		return "Remote control compromised"
	return ..()


/obj/docking_port/mobile/marine_dropship/can_move_topic(mob/user)
	if(hijack_state != HIJACK_STATE_NORMAL)
		to_chat(user, "<span class='warning'>Control integrity compromised!</span>")
		return FALSE
	return ..()


/mob/living/carbon/xenomorph/proc/hijack()
	set category = "Alien"
	set name = "Hijack Dropship"
	set desc = "Call down the dropship to the closest LZ or unlock the doors"

	if(!SSticker?.mode)
		to_chat(src, "<span class='warning'>This power doesn't work in this gamemode.</span>")

	if(!(hive.hive_flags & HIVE_CAN_HIJACK))
		to_chat(src, "<span class='warning'>Our hive lacks the psychic prowess to hijack the bird.</span>")
		return

	var/datum/game_mode/D = SSticker.mode

	if(!D.can_summon_dropship(src))
		return

	to_chat(src, "<span class='warning'>You begin calling down the shuttle.</span>")
	if(!do_after(src, 80, FALSE, null, BUSY_ICON_DANGER, BUSY_ICON_DANGER))
		to_chat(src, "<span class='warning'>You stop.</span>")
		return

	if(!D.can_summon_dropship(src))
		return

	D.announce_bioscans()

	var/obj/docking_port/stationary/port = D.summon_dropship(src)
	if(!port)
		to_chat(src, "<span class='warning'>Something went wrong.</span>")
		return

	hive?.xeno_message("[src] has summoned down the metal bird to [port], gather to her now!")
	priority_announce("Unknown interference with dropship control. Shutting down autopilot",  "Dropship malfunction")


#define ALIVE_HUMANS_FOR_CALLDOWN 0.1

/datum/game_mode/proc/can_summon_dropship(mob/user)
	if(SSticker.round_start_time + SHUTTLE_HIJACK_LOCK > world.time)
		to_chat(user, "<span class='warning'>It's too early to call it. We must wait [DisplayTimeText(SSticker.round_start_time + SHUTTLE_HIJACK_LOCK - world.time, 1)].</span>")
		return FALSE
	if(!is_ground_level(user.z))
		to_chat(user, "<span class='warning'>We can't call the bird from here!</span>")
		return FALSE
	var/obj/docking_port/mobile/marine_dropship/D
	for(var/k in SSshuttle.dropships)
		var/obj/docking_port/mobile/M = k
		if(M.control_flags & SHUTTLE_MARINE_PRIMARY_DROPSHIP)
			D = M
	if(is_ground_level(D.z))
		var/locked_sides = 0
		for(var/i in D.left_airlocks)
			var/obj/machinery/door/airlock/dropship_hatch/DH = i
			if(!DH.locked)
				continue
			locked_sides++
			break
		for(var/i in D.right_airlocks)
			var/obj/machinery/door/airlock/dropship_hatch/DH = i
			if(!DH.locked)
				continue
			locked_sides++
			break
		for(var/i in D.rear_airlocks)
			var/obj/machinery/door/airlock/multi_tile/mainship/dropshiprear/DH = i
			if(!DH.locked)
				continue
			locked_sides++
			break
		if(!locked_sides)
			to_chat(user, "<span class='warning'>The bird is already on the ground, open and vulnerable.</span>")
			return FALSE
		if(locked_sides < 3 && !isdropshiparea(get_area(user)))
			to_chat(user, "<span class='warning'>At least one side is still unlocked!</span>")
			return FALSE
		to_chat(user, "<span class='xenodanger'>We crack open the metal bird's shell.</span>")
		if(D.hijack_state != HIJACK_STATE_NORMAL)
			return FALSE
		if(user.do_actions)
			return FALSE
		to_chat(user, "<span class='warning'>We begin overriding the shuttle lockdown. This will take a while...</span>")
		if(!do_after(user, 30 SECONDS, FALSE, null, BUSY_ICON_DANGER, BUSY_ICON_DANGER))
			to_chat(user, "<span class='warning'>We cease overriding the shuttle lockdown.</span>")
			return FALSE
		if(!is_ground_level(D.z))
			to_chat(user, "<span class='warning'>The bird has left meanwhile, try again.</span>")
			return FALSE
		D.unlock_all()
		D.set_hijack_state(HIJACK_STATE_UNLOCKED)
		D.do_start_hijack_timer(GROUND_LOCKDOWN_TIME)
		to_chat(user, "<span class='warning'>We have overriden the shuttle lockdown!</span>")
		playsound(user, "alien_roar", 50)
		priority_announce("Alamo lockdown protocol compromised. Interference preventing remote control", "Dropship Lock Alert")
		return FALSE
	if(D.hijack_state == HIJACK_STATE_CALLED_DOWN)
		to_chat(user, "<span class='warning'>The bird's mind is already tampered with!</span>")
		return FALSE
	if(D.mode != SHUTTLE_IDLE && D.mode != SHUTTLE_RECHARGING)
		to_chat(user, "<span class='warning'>The bird's mind is currently active. We need to wait until it's more vulnerable...</span>")
		return FALSE
	var/humans_on_ground = 0
	for(var/i in SSmapping.levels_by_trait(ZTRAIT_GROUND))
		for(var/m in GLOB.humans_by_zlevel["[i]"])
			var/mob/living/carbon/human/H = m
			if(isnestedhost(H))
				continue
			humans_on_ground++
	if(length(GLOB.alive_human_list) && ((humans_on_ground / length(GLOB.alive_human_list)) > ALIVE_HUMANS_FOR_CALLDOWN))
		to_chat(user, "<span class='warning'>There's too many tallhosts still on the ground. They interfere with our psychic field. We must dispatch them before we are able to do this.</span>")
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
	icon = 'icons/Marine/shuttle-parts.dmi'
	icon_state = "console"
	resistance_flags = UNACIDABLE|INDESTRUCTIBLE
	req_one_access = list(ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LEADER) // TLs can only operate the remote console
	possible_destinations = "lz1;lz2;alamo"

/obj/machinery/computer/shuttle/marine_dropship/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(!(X.xeno_caste.caste_flags & CASTE_IS_INTELLIGENT))
		return
	if(SSticker.round_start_time + SHUTTLE_HIJACK_LOCK > world.time)
		to_chat(X, "<span class='xenowarning'>It's too early to do this!</span>")
		return
	var/obj/docking_port/mobile/marine_dropship/M = SSshuttle.getShuttle(shuttleId)
	var/dat = "Status: [M ? M.getStatusText() : "*Missing*"]<br><br>"
	if(M)
		dat += "<A href='?src=[REF(src)];hijack=1'>Launch to [SSmapping.configs[SHIP_MAP].map_name]</A><br>"
		M.unlock_all()
		dat += "<A href='?src=[REF(src)];abduct=1'>Capture the [M]</A><br>"
		if(M.hijack_state != HIJACK_STATE_CALLED_DOWN)
			M.hijack_state = HIJACK_STATE_CALLED_DOWN
			M.do_start_hijack_timer()

	var/datum/browser/popup = new(X, "computer", M ? M.name : "shuttle", 300, 200)
	popup.set_content("<center>[dat]</center>")
	popup.open()


/obj/machinery/computer/shuttle/marine_dropship/can_interact(mob/user)
	. = ..()

	if(isxeno(user))
		var/mob/living/carbon/xenomorph/X = user
		if(!(X.xeno_caste.caste_flags & CASTE_IS_INTELLIGENT))
			return FALSE

	else if(!allowed(user))
		return FALSE

	return TRUE

/obj/machinery/computer/shuttle/marine_dropship/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "MarineDropship", name)
		ui.open()

/obj/machinery/computer/shuttle/marine_dropship/ui_data(mob/user)
	var/obj/docking_port/mobile/marine_dropship/shuttle = SSshuttle.getShuttle(shuttleId)
	if(!shuttle)
		WARNING("[src] could not find shuttle [shuttleId] from SSshuttle")
		return

	. = list()
	.["on_flyby"] = shuttle.mode == SHUTTLE_CALL
	.["dest_select"] = !(shuttle.mode == SHUTTLE_CALL || shuttle.mode == SHUTTLE_IDLE)
	.["hijack_state"] = shuttle.hijack_state != HIJACK_STATE_CALLED_DOWN
	.["ship_status"] = shuttle.getStatusText()

	var/locked = 0
	var/reardoor = 0
	for(var/i in shuttle.rear_airlocks)
		var/obj/machinery/door/airlock/A = i
		if(A.locked && A.density)
			reardoor++
	if(!reardoor)
		.["rear"] = 0
	else if(reardoor==length(shuttle.rear_airlocks))
		.["rear"] = 2
		locked++
	else
		.["rear"] = 1

	var/leftdoor = 0
	for(var/i in shuttle.left_airlocks)
		var/obj/machinery/door/airlock/A = i
		if(A.locked && A.density)
			leftdoor++
	if(!leftdoor)
		.["left"] = 0
	else if(leftdoor==length(shuttle.left_airlocks))
		.["left"] = 2
		locked++
	else
		.["left"] = 1

	var/rightdoor = 0
	for(var/i in shuttle.right_airlocks)
		var/obj/machinery/door/airlock/A = i
		if(A.locked && A.density)
			rightdoor++
	if(!rightdoor)
		.["right"] = 0
	else if(rightdoor==length(shuttle.right_airlocks))
		.["right"] = 2
		locked++
	else
		.["right"] = 1

	if(locked == 3)
		.["lockdown"] = 2
	else if(!locked)
		.["lockdown"] = 0
	else
		.["lockdown"] = 1

	var/list/options = valid_destinations()
	var/list/valid_destinations = list()
	for(var/obj/docking_port/stationary/S in SSshuttle.stationary)
		if(!options.Find(S.id))
			continue
		if(!shuttle.check_dock(S, silent=TRUE))
			continue
		valid_destinations += list(list("name" = S.name, "id" = S.id))
	.["destinations"] = valid_destinations

/obj/machinery/computer/shuttle/marine_dropship/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	var/obj/docking_port/mobile/marine_dropship/M = SSshuttle.getShuttle(shuttleId)
	if(!M)
		return
	if(M.hijack_state == HIJACK_STATE_CALLED_DOWN)
		return

	switch(action)
		if("move")
			Topic(null, list("move" = params["move"]))
			return
		if("lockdown")
			M.lockdown_all()
			. = TRUE
		if("release")
			M.unlock_all()
			. = TRUE
		if("lock")
			M.lockdown_airlocks(params["lock"])
			. = TRUE
		if("unlock")
			M.unlock_airlocks(params["unlock"])
			. = TRUE

/obj/machinery/computer/shuttle/marine_dropship/Topic(href, href_list)
	var/obj/docking_port/mobile/marine_dropship/M = SSshuttle.getShuttle(shuttleId)
	if(!M)
		return
	if(!isxeno(usr) && M.hijack_state == HIJACK_STATE_CALLED_DOWN)
		to_chat(usr, "<span class='warning'>The shuttle isn't responding to commands.</span>")
		return
	. = ..()
	if(.)
		return
	if(M.hijack_state == HIJACK_STATE_CRASHING)
		return

	if(ishuman(usr) || isAI(usr))
		if(!allowed(usr))
			return
		if(href_list["lockdown"])

		else if(href_list["release"])

		else if(href_list["lock"])
			M.lockdown_airlocks(href_list["lock"])
		else if(href_list["unlock"])
			M.unlock_airlocks(href_list["unlock"])
		return

	if(!is_ground_level(M.z))
		return

	if(!isxeno(usr))
		return

	var/mob/living/carbon/xenomorph/X = usr

	if(href_list["hijack"])
		if(!(X.hive.hive_flags & HIVE_CAN_HIJACK))
			to_chat(X, "<span class='warning'>Our hive lacks the psychic prowess to hijack the bird.</span>")
			return
		switch(M.mode)
			if(SHUTTLE_RECHARGING)
				to_chat(X, "<span class='xenowarning'>The bird is still cooling down.</span>")
				return
			if(SHUTTLE_IDLE) //Continue.
			else
				to_chat(X, "<span class='xenowarning'>We can't do that right now.</span>")
				return
		var/obj/docking_port/stationary/marine_dropship/crash_target/CT = pick(SSshuttle.crash_targets)
		if(!CT)
			return
		do_hijack(M, CT, X)

	if(href_list["abduct"])
		var/groundside_humans
		for(var/N in GLOB.alive_human_list)
			var/mob/H = N
			if(H.z != X.z)
				continue
			groundside_humans++

		if(groundside_humans > 5)
			to_chat(X, "<span class='xenowarning'>There is still prey left to hunt!</span>")
			return

		var/confirm = tgui_alert(usr, "Would you like to capture the metal bird?\n THIS WILL END THE ROUND", "Capture the ship?", list( "Yes", "No"))
		if(confirm != "Yes")
			return
		priority_announce("The Alamo has been captured! Losing their main mean of accessing the ground, the marines have no choice but to retreat.", title = "ALAMO CAPTURED")
		var/datum/game_mode/infestation/infestation_mode = SSticker.mode
		infestation_mode.round_stage = INFESTATION_DROPSHIP_CAPTURED_XENOS
		return

/obj/machinery/computer/shuttle/marine_dropship/proc/do_hijack(obj/docking_port/mobile/marine_dropship/crashing_dropship, obj/docking_port/stationary/marine_dropship/crash_target/crash_target, mob/living/carbon/xenomorph/user)
	crashing_dropship.set_hijack_state(HIJACK_STATE_CRASHING)
	if(SSticker.mode?.flags_round_type & MODE_HIJACK_POSSIBLE)
		var/datum/game_mode/infestation/infestation_mode = SSticker.mode
		infestation_mode.round_stage = INFESTATION_MARINE_CRASHING
	crashing_dropship.callTime = 120 * (GLOB.current_orbit/3) SECONDS
	crashing_dropship.crashing = TRUE
	crashing_dropship.unlock_all()
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_DROPSHIP_HIJACKED)
	priority_announce("Unscheduled dropship departure detected from operational area. Hijack likely.", "Dropship Alert", sound = 'sound/AI/hijack.ogg')
	to_chat(user, "<span class='danger'>A loud alarm erupts from [src]! The fleshy hosts must know that you can access it!</span>")
	user.hive.on_shuttle_hijack(crashing_dropship)
	playsound(src, 'sound/misc/queen_alarm.ogg')
	SSevacuation.flags_scuttle &= ~FLAGS_SDEVAC_TIMELOCK
	switch(SSshuttle.moveShuttleToDock(shuttleId, crash_target, TRUE))
		if(0)
			visible_message("Shuttle departing. Please stand away from the doors.")
		if(1)
			to_chat(user, "<span class='warning'>Invalid shuttle requested. This shouldn't happen, please report it.</span>")
			CRASH("moveShuttleToDock() returned 1.")
		else
			to_chat(user, "<span class='warning'>ERROR. This shouldn't happen, please report it.</span>")
			CRASH("moveShuttleToDock() returned a non-zero-nor-one value.")


/obj/machinery/computer/shuttle/marine_dropship/one
	name = "\improper 'Alamo' flight controls"
	desc = "The flight controls for the 'Alamo' Dropship. Named after the Alamo Mission, stage of the Battle of the Alamo in the United States' state of Texas in the Spring of 1836. The defenders held to the last, encouraging other Texians to rally to the flag."
	possible_destinations = "lz1;lz2;alamo"

/obj/machinery/computer/shuttle/marine_dropship/one/Initialize()
	. = ..()
	for(var/trait in SSmapping.configs[SHIP_MAP].environment_traits)
		if(ZTRAIT_DOUBLE_SHIPS in trait)
			possible_destinations = "lz2;alamo"

/obj/machinery/computer/shuttle/marine_dropship/two
	name = "\improper 'Normandy' flight controls"
	desc = "The flight controls for the 'Normandy' Dropship. Named after a department in France, noteworthy for the famous naval invasion of Normandy on the 6th of June 1944, a bloody but decisive victory in World War II and the campaign for the Liberation of France."
	icon_state = "console2"
	possible_destinations = "lz1;lz2;alamo;normandy"

/obj/machinery/computer/shuttle/marine_dropship/three
	name = "\improper 'Triumph' flight controls"
	desc = "The flight controls for the 'Triumph' Dropship."
	possible_destinations = "lz1;triumph"
	req_one_access = list(ACCESS_MARINE_DROPSHIP_REBEL, ACCESS_MARINE_LEADER_REBEL)

/obj/machinery/door/poddoor/shutters/transit/afterShuttleMove(turf/oldT, list/movement_force, shuttle_dir, shuttle_preferred_direction, move_dir, rotation)
	. = ..()
	if(SSmapping.level_has_any_trait(z, list(ZTRAIT_MARINE_MAIN_SHIP, ZTRAIT_GROUND)))
		open()
	else
		close()

/turf/open/shuttle/dropship/floor
	icon_state = "rasputin15"

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
		to_chat(user, "<span class='warning'>[src] doesn't seem to be working.</span>")
		return

	if(!allowed(user))
		to_chat(user, "<span class='warning'>Access Denied</span>")
		flick("doorctrl-denied",src)
		return

	use_power(5)
	pressed = TRUE
	update_icon()

	D.lockdown_all()

	addtimer(CALLBACK(src, .proc/unpress), 15, TIMER_OVERRIDE|TIMER_UNIQUE)

// half-tile structure pieces
/obj/structure/dropship_piece
	icon = 'icons/obj/structures/dropship_structures.dmi'
	density = TRUE
	resistance_flags = RESIST_ALL
	opacity = TRUE

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

/obj/structure/dropship_piece/one/rearwing/rightrbottom
	icon_state = "brown_rearwing_rrb"
	opacity = FALSE

/obj/structure/dropship_piece/one/rearwing/leftllbottom
	icon_state = "brown_rearwing_lllb"
	opacity = FALSE

/obj/structure/dropship_piece/one/rearwing/rightrrbottom
	icon_state = "brown_rearwing_rrrb"
	opacity = FALSE



/obj/structure/dropship_piece/two
	name = "\improper Normandy"

/obj/structure/dropship_piece/two/front
	icon_state = "blue_front"
	opacity = FALSE

/obj/structure/dropship_piece/two/front/right
	icon_state = "blue_fr"

/obj/structure/dropship_piece/two/front/left
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


//Dropship control console

/obj/machinery/computer/shuttle/shuttle_control
	name = "shuttle control console"
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "shuttle"
	///Able to auto-relink to any shuttle with at least one of the flags in common if shuttleId is invalid.
	var/compatible_control_flags = NONE


/obj/machinery/computer/shuttle/shuttle_control/Initialize()
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

	var/obj/docking_port/mobile/M = SSshuttle.getShuttle(shuttleId)
	if(!(M.shuttle_flags & GAMEMODE_IMMUNE) && world.time < SSticker.round_start_time + SSticker.mode.deploy_time_lock)
		to_chat(usr, "<span class='warning'>The engines are still refueling.</span>")
		return TRUE

	if(!M.can_move_topic(usr))
		return TRUE

	if(!params["destination"])
		return TRUE

	if(!(params["destination"] in valid_destinations()))
		log_admin("[key_name(usr)] may be attempting a href dock exploit on [src] with target location \"[params["destination"]]\"")
		message_admins("[ADMIN_TPMONTY(usr)] may be attempting a href dock exploit on [src] with target location \"[params["destination"]]\"")
		return TRUE

	var/previous_status = M.mode
	log_game("[key_name(usr)] has sent the shuttle [M] to [params["destination"]]")

	switch(SSshuttle.moveShuttle(shuttleId, params["destination"], 1))
		if(0)
			if(previous_status != SHUTTLE_IDLE)
				visible_message("<span class='notice'>Destination updated, recalculating route.</span>")
			else
				visible_message("<span class='notice'>Shuttle departing. Please stand away from the doors.</span>")
				for(var/mob/living/silicon/ai/AI in GLOB.silicon_mobs)
					if(!AI.client)
						continue
					to_chat(AI, "<span class='info'>NOTICE - [M.name] taking off towards [params["destination"]]</span>")
			return TRUE
		if(1)
			to_chat(usr, "<span class='warning'>Invalid shuttle requested.</span>")
			return TRUE
		else
			to_chat(usr, "<span class='notice'>Unable to comply.</span>")
			return TRUE

/obj/machinery/computer/shuttle/shuttle_control/ui_data(mob/user)
	var/list/data = list()
	var/list/options = valid_destinations()
	var/obj/docking_port/mobile/M = SSshuttle.getShuttle(shuttleId)
	if(!M)
		return data //empty but oh well

	data["linked_shuttle_name"] = M.name
	data["shuttle_status"] = M.getStatusText()
	for(var/option in options)
		for(var/obj/docking_port/stationary/S AS in SSshuttle.stationary)
			if(option != S.id)
				continue
			var/list/dataset = list()
			dataset["id"] = S.id
			dataset["name"] = S.name
			dataset["locked"] = !M.check_dock(S, silent=TRUE)
			data["destinations"] += list(dataset)
	return data

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
	icon_state = "shuttle"
	resistance_flags = UNACIDABLE|INDESTRUCTIBLE
	req_one_access = list(ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LEADER) // TLs can only operate the remote console
	shuttleId = "alamo"
	possible_destinations = "lz1;lz2;alamo"
	compatible_control_flags = SHUTTLE_MARINE_PRIMARY_DROPSHIP


/obj/machinery/computer/shuttle/shuttle_control/dropship/two
	name = "\improper 'Normandy' dropship console"
	desc = "The remote controls for the 'Normandy' Dropship. Named after a department in France, noteworthy for the famous naval invasion of Normandy on the 6th of June 1944, a bloody but decisive victory in World War II and the campaign for the Liberation of France."
	shuttleId = "normandy"
	possible_destinations = "lz1;lz2;alamo;normandy"

/obj/machinery/computer/shuttle/shuttle_control/dropship/rebel 
	name = "\improper 'Triumph' dropship console"
	desc = "The remote controls for the 'Triumph' Dropship."
	shuttleId = "triumph"
	possible_destinations = "lz1;triumph"
	compatible_control_flags = SHUTTLE_REBEL_PRIMARY_DROPSHIP

/obj/machinery/computer/shuttle/shuttle_control/dropship/loyalist 
	name = "\improper 'Alamo' dropship console"
	desc = "The remote controls for the 'Alamo' Dropship."
	shuttleId = "alamo"
	possible_destinations = "lz2;alamo"

/obj/machinery/computer/shuttle/shuttle_control/canterbury
	name = "\improper 'Canterbury' shuttle console"
	desc = "The remote controls for the 'Canterbury' shuttle."
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "shuttle"
	resistance_flags = UNACIDABLE|INDESTRUCTIBLE
	shuttleId = "tgs_canterbury"
	possible_destinations = "canterbury_loadingdock"

/obj/machinery/computer/shuttle/shuttle_control/canterbury/ui_interact(mob/user)
	if(!allowed(user))
		to_chat(user, "<span class='warning'>Access Denied!</span>")
		return
	var/obj/docking_port/mobile/M = SSshuttle.getShuttle(shuttleId)
	var/dat = "Status: [M ? M.getStatusText() : "*Missing*"]<br><br>"
	if(M)
		dat += "<A href='?src=[REF(src)];move=crash-infinite-transit'>Initiate Evacuation</A><br>"

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
		to_chat(usr, "<span class='danger'>Access denied.</span>")
		return TRUE
	if(!href_list["move"] || !iscrashgamemode(SSticker.mode))
		to_chat(usr, "<span class='warning'>[src] is unresponsive.</span>")
		return FALSE

	if(!length(GLOB.active_nuke_list) && tgui_alert(usr, "Are you sure you want to launch the shuttle? Without sufficiently dealing with the threat, you will be in direct violation of your orders!", "Are you sure?", list("Yes", "Cancel")) != "Yes")
		return TRUE

	log_admin("[key_name(usr)] is launching the canterbury[!length(GLOB.active_nuke_list)? " early" : ""].")
	message_admins("[ADMIN_TPMONTY(usr)] is launching the canterbury[!length(GLOB.active_nuke_list)? " early" : ""].")

	var/obj/docking_port/mobile/M = SSshuttle.getShuttle(shuttleId)
	if(!(M.shuttle_flags & GAMEMODE_IMMUNE) && world.time < SSticker.round_start_time + SSticker.mode.deploy_time_lock)
		to_chat(usr, "<span class='warning'>The engines are still refueling.</span>")
		return TRUE
	if(!M.can_move_topic(usr))
		return TRUE

	visible_message("<span class='notice'>Shuttle departing. Please stand away from the doors.</span>")
	M.destination = null
	M.mode = SHUTTLE_IGNITING
	M.setTimer(M.ignitionTime)

	var/datum/game_mode/infestation/crash/C = SSticker.mode
	addtimer(VARSET_CALLBACK(C, marines_evac, CRASH_EVAC_INPROGRESS), M.ignitionTime + 10 SECONDS)
	addtimer(VARSET_CALLBACK(C, marines_evac, CRASH_EVAC_COMPLETED), 2 MINUTES)
	return TRUE
