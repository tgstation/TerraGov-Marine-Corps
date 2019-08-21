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
			M.knock_down(3)
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

	explosion(front, 0, 4, 8, 0)
	explosion(rear, 2, 5, 9, 0)
	explosion(left, 2, 5, 9, 0)
	explosion(right, 2, 5, 9, 0)

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
	name = "Main Hangar"

/obj/docking_port/stationary/marine_dropship/lz2
	name = "Landing Zone Two"
	id = "lz2"

/obj/docking_port/stationary/marine_dropship/lz2/prison
	name = "Civ Residence Hangar"

/obj/docking_port/stationary/marine_dropship/hangar/one
	name = "Theseus Hangar Pad One"
	id = "alamo"
	roundstart_template = /datum/map_template/shuttle/dropship/one

/obj/docking_port/stationary/marine_dropship/hangar/two
	name = "Theseus Hangar Pad Two"
	id = "normandy"
	roundstart_template = /datum/map_template/shuttle/dropship/two

#define HIJACK_STATE_NORMAL 0
#define HIJACK_STATE_CALLED_DOWN 1
#define HIJACK_STATE_CRASHING 2

#define LOCKDOWN_TIME 10 MINUTES

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


	var/list/equipments = list()
	var/list/installed_equipment = list()
	var/list/selected_equipment = list()

	var/hijack_state = HIJACK_STATE_NORMAL

/obj/docking_port/mobile/marine_dropship/register()
	. = ..()
	SSshuttle.dropships += src


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

/obj/docking_port/mobile/marine_dropship/on_ignition()
	playsound(return_center_turf(), 'sound/effects/engine_startup.ogg', 60, 0)

/obj/docking_port/mobile/marine_dropship/on_prearrival()
	playsound(return_center_turf(), 'sound/effects/engine_landing.ogg', 60, 0)
	if(destination)
		playsound(destination.return_center_turf(), 'sound/effects/engine_landing.ogg', 60, 0)


/obj/docking_port/mobile/marine_dropship/initiate_docking(obj/docking_port/stationary/new_dock, movement_direction, force=FALSE)
	if(crashing)
		force = TRUE

	. = ..()

/obj/docking_port/mobile/marine_dropship/one
	id = "alamo"

/obj/docking_port/mobile/marine_dropship/two
	id = "normandy"

// queen calldown

/obj/docking_port/mobile/marine_dropship/afterShuttleMove(turf/oldT, rotation)
	. = ..()
	if(hijack_state != HIJACK_STATE_CALLED_DOWN)
		return
	unlock_all()

/obj/docking_port/mobile/marine_dropship/onTransitZ(old_z, new_z)
	. = ..()
	if(hijack_state != HIJACK_STATE_CALLED_DOWN)
		return
	if(is_ground_level(new_z))
		addtimer(CALLBACK(src, .proc/reset_hijack), LOCKDOWN_TIME)
	else if(is_mainship_level(new_z))
		addtimer(CALLBACK(src, .proc/reset_hijack), 30 SECONDS)

/obj/docking_port/mobile/marine_dropship/proc/reset_hijack()
	if(hijack_state == HIJACK_STATE_CALLED_DOWN)
		hijack_state = HIJACK_STATE_NORMAL

/obj/docking_port/mobile/marine_dropship/proc/summon_dropship_to(obj/docking_port/stationary/S)
	mode = SHUTTLE_IDLE
	timer = 0
	destination = null
	hijack_state = HIJACK_STATE_CALLED_DOWN
	request(S)

/obj/docking_port/mobile/marine_dropship/on_prearrival()
	. = ..()
	if(hijack_state == HIJACK_STATE_CRASHING)
		priority_announce("DROPSHIP ON COLLISION COURSE. CRASH IMMINENT." , "EMERGENCY", sound = 'sound/AI/dropship_emergency.ogg')

/mob/living/carbon/xenomorph/proc/calldown_dropship()
	set category = "Alien"
	set name = "Call Down Dropship"
	set desc = "Call down the dropship to the closest LZ"

	if(!SSticker?.mode)
		to_chat(src, "<span class='warning'>This power doesn't work in this gamemode.</span>")

	if(hive.living_xeno_ruler != src)
		to_chat(src, "<span class='warning'>Only the ruler of the hive may attempt this.</span>")
		return

	var/datum/game_mode/D = SSticker.mode

	if(!D.can_summon_dropship(src))
		return

	to_chat(src, "<span class='warning'>You begin calling down the shuttle.</span>")
	if(!do_after(src, 80, FALSE, null, BUSY_ICON_DANGER, BUSY_ICON_DANGER))
		to_chat(src, "<span class='warning'>You stop.</span>")
		return

	var/obj/docking_port/stationary/port = D.summon_dropship(src)
	if(!port)
		to_chat(src, "<span class='warning'>Something went wrong.</span>")
		return

	hive?.xeno_message("[src] has summoned down the metal bird to [port], gather to her now!")

#define ALIVE_HUMANS_FOR_CALLDOWN 0.1

/datum/game_mode/proc/can_summon_dropship(mob/user)
	if(user.action_busy)
		return FALSE
	if(SSticker.round_start_time + SHUTTLE_HIJACK_LOCK > world.time)
		to_chat(user, "<span class='warning'>It's too early to call it. We must wait [DisplayTimeText(SSticker.round_start_time + SHUTTLE_HIJACK_LOCK - world.time, 1)].</span>")
		return FALSE
	var/obj/docking_port/mobile/marine_dropship/D
	for(var/k in SSshuttle.dropships)
		var/obj/docking_port/mobile/M = k
		if(M.id == "alamo")
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
			to_chat(user, "<span class='warning'>We can't call the bird from here!</span>")
			return FALSE
		if(locked_sides < 3)
			to_chat(user, "<span class='warning'>At least one side is still unlocked!</span>")
			return FALSE
		to_chat(user, "<span class='warning'>We begin overriding the shuttle lockdown. This will take a while...</span>")
		if(!do_after(user, 60 SECONDS, FALSE, null, BUSY_ICON_DANGER, BUSY_ICON_DANGER))
			to_chat(user, "<span class='warning'>We cease overriding the shuttle lockdown.</span>")
			return FALSE
		if(!is_ground_level(D.z))
			to_chat(user, "<span class='warning'>The bird has left meanwhile, try again.</span>")
			return FALSE
		D.hijack_state = HIJACK_STATE_CALLED_DOWN
		D.unlock_all()
		to_chat(user, "<span class='warning'>We have overriden the shuttle lockdown!</span>")
		playsound(user, "alien_roar", 50)
		return FALSE
	if(D.hijack_state != HIJACK_STATE_NORMAL)
		to_chat(user, "<span class='warning'>The bird's mind is already tampered with!</span>")
		return FALSE
	var/humans_on_ground = 0
	for(var/i in GLOB.alive_human_list)
		var/mob/living/carbon/human/H = i
		if(isnestedhost(H))
			continue
		if(is_ground_level(H.z))
			humans_on_ground++
	if((humans_on_ground/length(GLOB.alive_human_list)) > ALIVE_HUMANS_FOR_CALLDOWN)
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
		if(M.id == "alamo")
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
	possible_destinations = "lz1;lz2;alamo;normandy"

/obj/machinery/computer/shuttle/marine_dropship/attack_alien(mob/living/carbon/xenomorph/X)
	if(!(X.xeno_caste.caste_flags & CASTE_IS_INTELLIGENT))
		return
	if(SSticker.round_start_time + SHUTTLE_HIJACK_LOCK > world.time)
		to_chat(X, "<span class='xenowarning'>It's too early to do this!</span>")
		return
	var/obj/docking_port/mobile/marine_dropship/M = SSshuttle.getShuttle(shuttleId)
	var/dat = "Status: [M ? M.getStatusText() : "*Missing*"]<br><br>"
	if(M)
		dat += "<A href='?src=[REF(src)];hijack=1'>Launch to [SSmapping.configs[SHIP_MAP].map_name]</A><br>"
		M.hijack_state = HIJACK_STATE_CALLED_DOWN
		M.unlock_all()
	dat += "<a href='?src=[REF(X)];mach_close=computer'>Close</a>"
	var/datum/browser/popup = new(X, "computer", M ? M.name : "shuttle", 300, 200)
	popup.set_content("<center>[dat]</center>")
	popup.set_title_image(X.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()

/obj/machinery/computer/shuttle/marine_dropship/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 0)
	var/obj/docking_port/mobile/marine_dropship/shuttle = SSshuttle.getShuttle(shuttleId)
	if(!shuttle)
		WARNING("[src] could not find shuttle [shuttleId] from SSshuttle")
		return 
	
	if(!allowed(user))
		to_chat(user, "<span class='warning'>Access Denied!</span>")
		return

	var/list/data = list()
	data["on_flyby"] = shuttle.mode == SHUTTLE_CALL
	data["shuttle_mode"] = shuttle.mode
	data["hijack_state"] = shuttle.hijack_state
	data["ship_status"] = shuttle.getStatusText()

	var/list/options = params2list(possible_destinations)
	var/list/valid_destionations = list()
	for(var/obj/docking_port/stationary/S in SSshuttle.stationary)
		if(!options.Find(S.id))
			continue
		if(!shuttle.check_dock(S, silent=TRUE))
			continue
		valid_destionations += list(list("name" = S.name, "id" = S.id))
	data["destinations"] = valid_destionations

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)	
	if (!ui)	
		ui = new(user, src, ui_key, "dropship_pilot_console.tmpl", "Pilot Control", 500, 600)	
		ui.set_initial_data(data)	
		ui.open()	
		ui.set_auto_update(1)


/obj/machinery/computer/shuttle/marine_dropship/attack_ai(mob/living/silicon/ai/AI)
	return attack_hand(AI)


/obj/machinery/computer/shuttle/marine_dropship/Topic(href, href_list)
	. = ..()
	if(.)
		return
	var/obj/docking_port/mobile/marine_dropship/M = SSshuttle.getShuttle(shuttleId)
	if(!M)
		return
	if(M.hijack_state == HIJACK_STATE_CRASHING)
		return

	if(ishuman(usr) || isAI(usr))
		if(!allowed(usr))
			return
		if(M.hijack_state == HIJACK_STATE_CALLED_DOWN)
			to_chat(usr, "<span class='warning'>The shuttle isn't responding to commands.</span>")
			return
		if(href_list["lockdown"])
			M.lockdown_all()
		else if(href_list["release"])
			M.unlock_all()
		else if(href_list["lock"])
			M.lockdown_airlocks(href_list["lock"])
		else if(href_list["unlock"])
			M.unlock_airlocks(href_list["unlock"])
		return
	
	else if(!isxeno(usr))
		return
	if(!is_ground_level(M.z))
		return
	var/mob/living/carbon/xenomorph/X = usr
	if(!(X.xeno_caste.caste_flags & CASTE_IS_INTELLIGENT))
		return
	if(href_list["hijack"])
		if(X.hive.living_xeno_ruler != X)
			to_chat(X, "<span class='warning'>Only the ruler of the hive may attempt this.</span>")
			return
		if(M.mode == SHUTTLE_RECHARGING)
			to_chat(X, "<span class='xenowarning'>The birb is still cooling down.</span>")
			return
		if(M.mode != SHUTTLE_IDLE)
			to_chat(X, "<span class='xenowarning'>You can't do that right now.</span>")
			return
		var/obj/docking_port/stationary/marine_dropship/crash_target/CT = pick(SSshuttle.crash_targets)
		if(!CT)
			return
		M.callTime = 2 MINUTES
		M.crashing = TRUE
		M.hijack_state = HIJACK_STATE_CRASHING
		M.unlock_all()
		no_destination_swap = TRUE
		priority_announce("Unscheduled dropship departure detected from operational area. Hijack likely. Shutting down autopilot.", "Dropship Alert", sound = 'sound/AI/hijack.ogg')
		to_chat(X, "<span class='danger'>A loud alarm erupts from [src]! The fleshy hosts must know that you can access it!</span>")
		X.hive.xeno_message("Our Ruler has commanded the metal bird to depart for the metal hive in the sky! Rejoice!")
		playsound(src, 'sound/misc/queen_alarm.ogg')
		SSevacuation.flags_scuttle &= ~FLAGS_SDEVAC_TIMELOCK
		switch(SSshuttle.moveShuttleToDock(shuttleId, CT, 1))
			if(0)
				visible_message("Shuttle departing. Please stand away from the doors.")
			if(1)
				to_chat(X, "<span class='warning'>Invalid shuttle requested.</span>")
			else
				to_chat(X, "<span class='notice'>Unable to comply.</span>")

/obj/machinery/computer/shuttle/marine_dropship/one
	name = "\improper 'Alamo' flight controls"
	desc = "The flight controls for the 'Alamo' Dropship. Named after the Alamo Mission, stage of the Battle of the Alamo in the United States' state of Texas in the Spring of 1836. The defenders held to the last, encouraging other Texians to rally to the flag."

/obj/machinery/computer/shuttle/marine_dropship/two
	name = "\improper 'Normandy' flight controls"
	desc = "The flight controls for the 'Normandy' Dropship. Named after a department in France, noteworthy for the famous naval invasion of Normandy on the 6th of June 1944, a bloody but decisive victory in World War II and the campaign for the Liberation of France."


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
	resistance_flags = UNACIDABLE
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

//Dropship control console

/obj/machinery/computer/shuttle/shuttle_control
	name = "shuttle control console"
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "shuttle"


/obj/machinery/computer/shuttle/shuttle_control/Initialize()
	. = ..()
	GLOB.shuttle_controls_list += src


/obj/machinery/computer/shuttle/shuttle_control/Destroy()
	GLOB.shuttle_controls_list -= src
	return ..()


/obj/machinery/computer/shuttle/shuttle_control/ui_interact(mob/user)
	if(!allowed(user))
		to_chat(user, "<span class='warning'>Access Denied!</span>")
		return
	var/list/options = params2list(possible_destinations)
	var/obj/docking_port/mobile/M = SSshuttle.getShuttle(shuttleId)
	var/dat = "Status: [M ? M.getStatusText() : "*Missing*"]<br><br>"
	if(M)
		var/destination_found
		for(var/obj/docking_port/stationary/S in SSshuttle.stationary)
			if(!options.Find(S.id))
				continue
			if(!M.check_dock(S, silent=TRUE))
				continue
			destination_found = TRUE
			dat += "<A href='?src=[REF(src)];move=[S.id]'>Send to [S.name]</A><br>"
		if(!destination_found)
			dat += "<B>Shuttle Locked</B><br>"
	dat += "<a href='?src=[REF(user)];mach_close=computer'>Close</a>"

	var/datum/browser/popup = new(user, "computer", M ? M.name : "shuttle", 300, 200)
	popup.set_content("<center>[dat]</center>")
	popup.set_title_image(usr.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()


/obj/machinery/computer/shuttle/shuttle_control/attack_ai(mob/living/silicon/ai/AI)
	return attack_hand(AI)


/obj/machinery/computer/shuttle/shuttle_control/dropship1
	name = "\improper 'Alamo' dropship console"
	desc = "The remote controls for the 'Alamo' Dropship. Named after the Alamo Mission, stage of the Battle of the Alamo in the United States' state of Texas in the Spring of 1836. The defenders held to the last, encouraging other Texans to rally to the flag."
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "shuttle"
	resistance_flags = UNACIDABLE|INDESTRUCTIBLE
	req_one_access = list(ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LEADER) // TLs can only operate the remote console
	shuttleId = "alamo"
	possible_destinations = "lz1;lz2;alamo;normandy"


/obj/machinery/computer/shuttle/shuttle_control/dropship2
	name = "\improper 'Normandy' dropship console"
	desc = "The remote controls for the 'Normandy' Dropship. Named after a department in France, noteworthy for the famous naval invasion of Normandy on the 6th of June 1944, a bloody but decisive victory in World War II and the campaign for the Liberation of France."
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "shuttle"
	resistance_flags = UNACIDABLE|INDESTRUCTIBLE
	req_one_access = list(ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LEADER)

/obj/machinery/computer/shuttle/shuttle_control/canterbury
	name = "\improper 'Canterbury' shuttle console"
	desc = "The remote controls for the 'Canterbury' shuttle."
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "shuttle"
	resistance_flags = UNACIDABLE|INDESTRUCTIBLE
	shuttleId = "tgs_canterbury"
	possible_destinations = "canterbury_loadingdock"

/obj/machinery/computer/shuttle/shuttle_control/canterbury/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(!href_list["move"] || !iscrashgamemode(SSticker.mode))
		return
	var/datum/game_mode/crash/C = SSticker.mode

	var/nuke_set = FALSE
	for(var/i in GLOB.nuke_list)
		var/obj/machinery/nuclearbomb/bomb = i
		if(bomb.timer_enabled)
			nuke_set = TRUE
			break

	if(nuke_set && alert(usr, "Are you sure you want to launch the shuttle? Without sufficiently dealing with the threat, you will be in direct violation of your orders!", "Are you sure?", "Yes", "Cancel") != "Yes")
		return

	C.marines_evac = CRASH_EVAC_INPROGRESS
	addtimer(VARSET_CALLBACK(C, marines_evac, CRASH_EVAC_COMPLETED), 5 MINUTES)