/obj/docking_port/mobile/escape_pod
	name = "escape pod"
	dir = WEST
	dwidth = 2
	width = 5
	height = 4
	launch_status = UNLAUNCHED
	ignitionTime = 8 SECONDS
	var/can_launch = FALSE

	var/list/doors = list()
	var/list/cryopods = list()
	var/max_capacity // set this to override determining capacity by number of cryopods

/obj/docking_port/mobile/escape_pod/escape_shuttle
	name = "escape shuttle"
	dir = EAST
	dwidth = 3
	width = 7
	height = 9

/obj/docking_port/mobile/escape_pod/register()
	. = ..()
	SSshuttle.escape_pods += src

/obj/docking_port/mobile/escape_pod/Destroy(force)
	if(force)
		SSshuttle.escape_pods -= src
	. = ..()

/obj/docking_port/mobile/escape_pod/proc/check_capacity()
	var/mobs = 0
	var/capacity = 0
	for(var/t in return_turfs())
		var/turf/T = t
		for(var/mob/living/M in T.GetAllContents())
			mobs++
		for(var/obj/machinery/cryopod/evacuation/E in T.GetAllContents())
			capacity++
	if(max_capacity)
		capacity = max_capacity
	return mobs <= capacity

/obj/docking_port/mobile/escape_pod/proc/launch(manual = FALSE)
	if(!can_launch || launch_status == NOLAUNCH)
		return
	close_all_doors()
	if(!check_capacity())
		playsound(return_center_turf(),'sound/effects/alert.ogg', 25, 1)
		addtimer(CALLBACK(src, .proc/explode), 4 SECONDS, TIMER_UNIQUE)
		can_launch = FALSE
		return
	playsound(return_center_turf(),'sound/effects/escape_pod_warmup.ogg', 25, 1)
	if(manual)
		launch_status = EARLY_LAUNCHED
	else
		launch_status = ENDGAME_LAUNCHED
	addtimer(CALLBACK(src, .proc/do_launch), ignitionTime, TIMER_UNIQUE)

/obj/docking_port/mobile/escape_pod/proc/explode()
	var/turf/T = return_center_turf()
	var/average_dimension = (width+height)*0.25
	explosion(T, 0, 0, average_dimension, average_dimension)
	launch_status = NOLAUNCH
	open_all_doors()
	SSshuttle.escape_pods -= src // no longer a valid pod

/obj/docking_port/mobile/escape_pod/proc/prep_for_launch()
	open_all_doors()
	can_launch = TRUE

/obj/docking_port/mobile/escape_pod/proc/open_all_doors()
	for(var/obj/machinery/door/airlock/evacuation/D in doors)
		INVOKE_ASYNC(D, /obj/machinery/door/airlock/evacuation/.proc/force_open)

/obj/docking_port/mobile/escape_pod/proc/unprep_for_launch()
	// dont close the door it might trap someone inside
	can_launch = FALSE
	open_all_doors()

/obj/docking_port/mobile/escape_pod/proc/close_all_doors()
	for(var/obj/machinery/door/airlock/evacuation/D in doors)
		INVOKE_ASYNC(D, /obj/machinery/door/airlock/evacuation/.proc/force_close)

/obj/docking_port/mobile/escape_pod/proc/do_launch()
	if(!can_launch)
		return
	playsound(return_center_turf(),'sound/effects/escape_pod_launch.ogg', 25, 1)
	intoTheSunset()

/obj/docking_port/stationary/escape_pod
	name = "escape pod"
	dir = EAST
	dwidth = 2
	width = 5
	height = 4

	roundstart_template = /datum/map_template/shuttle/escape_pod

/obj/docking_port/stationary/escape_pod/escape_shuttle
	name = "escape shuttle"
	id = "escape hangar"
	dir = EAST
	dwidth = 3
	width = 7
	height = 9

	roundstart_template = /datum/map_template/shuttle/escape_shuttle

/obj/docking_port/stationary/escape_pod/right
	dir = WEST

/obj/docking_port/stationary/escape_pod/up
	dir = SOUTH

/obj/docking_port/stationary/escape_pod/down
	dir = NORTH

/obj/machinery/computer/shuttle/escape_pod
	name = "escape pod controller"
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "airlock_control_standby"
	power_channel = ENVIRON
	density = FALSE

/obj/machinery/computer/shuttle/escape_pod/escape_shuttle
	name = "escape shuttle controller"

/obj/machinery/computer/shuttle/escape_pod/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "EscapePod")
		ui.open()

/obj/machinery/computer/shuttle/escape_pod/ui_data(mob/user)
	. = ..()
	var/obj/docking_port/mobile/escape_pod/M = SSshuttle.getShuttle(shuttleId)
	var/list/data = list()
	data["can_launch"] = M.can_launch

	return data

/obj/machinery/computer/shuttle/escape_pod/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	if(action == "launch")
		var/obj/docking_port/mobile/escape_pod/M = SSshuttle.getShuttle(shuttleId)
		if(!M)
			return

		if(!M.can_launch)
			to_chat(usr, span_warning("Evacuation is not enabled!"))
			return

		to_chat(usr, span_highdanger("You slam your fist down on the launch button!"))
		M.launch(TRUE)

//=========================================================================================
//================================Evacuation Sleeper=======================================
//=========================================================================================

/obj/machinery/cryopod/evacuation
	resistance_flags = RESIST_ALL
	var/being_forced = 0 //Simple variable to prevent sound spam.
	var/linked_to_shuttle = FALSE

/obj/machinery/cryopod/evacuation/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override=FALSE)
	if(linked_to_shuttle)
		return
	. = ..()
	if(istype(port, /obj/docking_port/mobile/escape_pod))
		var/obj/docking_port/mobile/escape_pod/M = port

		M.cryopods += src
		linked_to_shuttle = TRUE

/obj/machinery/cryopod/evacuation/ex_act(severity)
	return

/obj/machinery/cryopod/evacuation/attackby(obj/item/grab/G, mob/user)
	if(istype(G))
		if(being_forced)
			to_chat(user, span_warning("There's something forcing it open!"))
			return FALSE

		if(occupant)
			to_chat(user, span_warning("There is someone in there already!"))
			return FALSE

		var/mob/living/carbon/human/M = G.grabbed_thing
		if(!istype(M)) return FALSE

		visible_message(span_warning("[user] starts putting [M.name] into the cryo pod."), 3)

		if(do_after(user, 20, TRUE, M, BUSY_ICON_GENERIC) && !QDELETED(src))
			move_mob_inside(M)

/obj/machinery/cryopod/evacuation/eject()
	set name = "Eject Pod"
	set category = "Object"
	set src in oview(1)

	if(!occupant || !usr.stat || usr.restrained()) return FALSE

	if(occupant) //Once you're in, you cannot exit, and outside forces cannot eject you.
		//The occupant is actually automatically ejected once the evac is canceled.
		if(occupant != usr) to_chat(usr, span_warning("You are unable to eject the occupant unless the evacuation is canceled."))


/obj/machinery/cryopod/evacuation/go_out() //When the system ejects the occupant.
	if(occupant)
		occupant.forceMove(get_turf(src))
		REMOVE_TRAIT(occupant, TRAIT_STASIS, CRYOPOD_TRAIT)
		occupant = null
		icon_state = orient_right ? "body_scanner_0-r" : "body_scanner_0"

/obj/machinery/cryopod/evacuation/move_inside()
	set name = "Enter Pod"
	set category = "Object"
	set src in oview(1)

	var/mob/living/carbon/human/user = usr

	if(!istype(user) || user.stat || user.restrained()) return FALSE

	if(being_forced)
		to_chat(user, span_warning("You can't enter when it's being forced open!"))
		return FALSE

	if(occupant)
		to_chat(user, span_warning("The cryogenic pod is already in use! You will need to find another."))
		return FALSE

	visible_message(span_warning("[user] starts climbing into the cryo pod."), 3)

	if(do_after(user, 20, FALSE, src, BUSY_ICON_GENERIC))
		user.stop_pulling()
		move_mob_inside(user)

/obj/machinery/cryopod/evacuation/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(X.status_flags & INCORPOREAL)
		return

	if(being_forced)
		to_chat(X, span_xenowarning("It's being forced open already!"))
		return FALSE

	if(!occupant)
		to_chat(X, span_xenowarning("There is nothing of interest in there."))
		return FALSE

	being_forced = !being_forced
	visible_message(span_warning("[X] begins to pry the [src]'s cover!"), 3)
	playsound(src,'sound/effects/metal_creaking.ogg', 25, 1)
	if(do_after(X, 2 SECONDS, FALSE, src, BUSY_ICON_HOSTILE))
		go_out() //Force the occupant out.
	being_forced = !being_forced

/obj/machinery/cryopod/evacuation/proc/move_mob_inside(mob/M)
	if(occupant)
		to_chat(M, span_warning("The cryogenic pod is already in use. You will need to find another."))
		return FALSE
	M.forceMove(src)
	to_chat(M, span_notice("You feel cool air surround you as your mind goes blank and the pod locks."))
	occupant = M
	ADD_TRAIT(occupant, TRAIT_STASIS, CRYOPOD_TRAIT)
	icon_state = orient_right ? "body_scanner_1-r" : "body_scanner_1"

/obj/machinery/door/airlock/evacuation
	name = "\improper Evacuation Airlock"
	icon = 'icons/obj/doors/mainship/pod_doors.dmi'
	icon_state = "door_locked"
	resistance_flags = RESIST_ALL
	density = TRUE
	opacity = TRUE
	locked = TRUE
	var/linked_to_shuttle = FALSE

/obj/machinery/door/airlock/evacuation/proc/force_open()
	if(!density)
		return
	unlock()
	open()
	lock()

/obj/machinery/door/airlock/evacuation/proc/force_close()
	if(density)
		return
	unlock()
	close()
	lock()

/obj/machinery/door/airlock/evacuation/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override=FALSE)
	if(linked_to_shuttle)
		return
	. = ..()

	if(istype(port, /obj/docking_port/mobile/escape_pod))
		var/obj/docking_port/mobile/escape_pod/M = port

		M.doors += src
		linked_to_shuttle = TRUE


/obj/machinery/door/airlock/evacuation/can_interact(mob/user)
	return FALSE

/obj/machinery/door/airlock/evacuation/Bumped()
	return FALSE

/obj/machinery/door/airlock/evacuation/attackby()
	return FALSE

/obj/machinery/door/airlock/evacuation/attack_hand(mob/living/user)
	return TRUE

/obj/machinery/door/airlock/evacuation/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	return FALSE //Probably a better idea that these cannot be forced open.
