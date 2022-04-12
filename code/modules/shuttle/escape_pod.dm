/obj/docking_port/mobile/escape_pod
	name = "escape pod"
	dir = WEST
	dwidth = 2
	width = 5
	height = 4
	launch_status = UNLAUNCHED
	ignitionTime = 10 SECONDS
	var/can_launch = FALSE

	var/list/doors = list()
	var/list/cryopods = list()

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

/obj/docking_port/mobile/escape_pod/proc/count_escaped_humans()
	for(var/turf/T AS in return_turfs())
		for(var/mob/living/carbon/human/marine in T.GetAllContents())
			if(marine.stat == DEAD)
				continue
			SSevacuation.human_escaped++

/obj/docking_port/mobile/escape_pod/proc/launch(manual = FALSE)
	if(!can_launch || launch_status == NOLAUNCH)
		return
	playsound(return_center_turf(),'sound/effects/escape_pod_warmup.ogg', 25, 1)
	if(manual)
		launch_status = EARLY_LAUNCHED
	else
		launch_status = ENDGAME_LAUNCHED
	addtimer(CALLBACK(src, .proc/do_launch), ignitionTime, TIMER_UNIQUE)

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
	count_escaped_humans()
	SSshuttle.moveShuttleToTransit(id, TRUE)

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

/obj/machinery/cryopod/evacuation/climb_in(mob/living/carbon/user, mob/helper)
	. = ..()
	user.ghostize(FALSE)

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
	unlock(TRUE)
	open()
	lock(TRUE)

/obj/machinery/door/airlock/evacuation/proc/force_close()
	if(density)
		return
	unlock(TRUE)
	close()
	lock(TRUE)

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
