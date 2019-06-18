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
	explosion(T, -1, -1, average_dimension, average_dimension)
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

/obj/machinery/computer/shuttle/escape_pod/ui_interact(mob/user)
	var/dat = "<A href='?src=[REF(src)];launch=1'>Launch</A><br>"
	dat += "<a href='?src=[REF(user)];mach_close=computer'>Close</a>"

	var/datum/browser/popup = new(user, "computer", "escape pod", 300, 200)
	popup.set_content("<center>[dat]</center>")
	popup.set_title_image(usr.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()

/obj/machinery/computer/shuttle/escape_pod/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/H = usr
	if(H.incapacitated())
		return
	if(!href_list["launch"])
		return

	var/obj/docking_port/mobile/escape_pod/M = SSshuttle.getShuttle(shuttleId)

	if(!M)
		return
	if(!M.can_launch)
		to_chat(H, "<span class='warning'>Evacuation is not enabled!</span>")
		return

	to_chat(H, "<span class='highdanger'>You slam your fist down on the launch button!</span>")
	M.launch(TRUE)

//=========================================================================================
//================================Evacuation Sleeper=======================================
//=========================================================================================

/obj/machinery/cryopod/evacuation
	resistance_flags = UNACIDABLE
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
	return FALSE

/obj/machinery/cryopod/evacuation/attackby(obj/item/grab/G, mob/user)
	if(istype(G))
		if(being_forced)
			to_chat(user, "<span class='warning'>There's something forcing it open!</span>")
			return FALSE

		if(occupant)
			to_chat(user, "<span class='warning'>There is someone in there already!</span>")
			return FALSE

		var/mob/living/carbon/human/M = G.grabbed_thing
		if(!istype(M)) return FALSE

		visible_message("<span class='warning'>[user] starts putting [M.name] into the cryo pod.</span>", 3)

		if(do_after(user, 20, TRUE, M, BUSY_ICON_GENERIC) && !QDELETED(src))
			move_mob_inside(M)

/obj/machinery/cryopod/evacuation/eject()
	set name = "Eject Pod"
	set category = "Object"
	set src in oview(1)

	if(!occupant || !usr.stat || usr.restrained()) return FALSE

	if(occupant) //Once you're in, you cannot exit, and outside forces cannot eject you.
		//The occupant is actually automatically ejected once the evac is canceled.
		if(occupant != usr) to_chat(usr, "<span class='warning'>You are unable to eject the occupant unless the evacuation is canceled.</span>")


/obj/machinery/cryopod/evacuation/go_out() //When the system ejects the occupant.
	if(occupant)
		occupant.forceMove(get_turf(src))
		occupant.in_stasis = FALSE
		occupant = null
		icon_state = orient_right ? "body_scanner_0-r" : "body_scanner_0"

/obj/machinery/cryopod/evacuation/move_inside()
	set name = "Enter Pod"
	set category = "Object"
	set src in oview(1)

	var/mob/living/carbon/human/user = usr

	if(!istype(user) || user.stat || user.restrained()) return FALSE

	if(being_forced)
		to_chat(user, "<span class='warning'>You can't enter when it's being forced open!</span>")
		return FALSE

	if(occupant)
		to_chat(user, "<span class='warning'>The cryogenic pod is already in use! You will need to find another.</span>")
		return FALSE

	visible_message("<span class='warning'>[user] starts climbing into the cryo pod.</span>", 3)

	if(do_after(user, 20, FALSE, src, BUSY_ICON_GENERIC))
		user.stop_pulling()
		move_mob_inside(user)

/obj/machinery/cryopod/evacuation/attack_alien(mob/living/carbon/xenomorph/user)
	if(being_forced)
		to_chat(user, "<span class='xenowarning'>It's being forced open already!</span>")
		return FALSE

	if(!occupant)
		to_chat(user, "<span class='xenowarning'>There is nothing of interest in there.</span>")
		return FALSE

	being_forced = !being_forced
	visible_message("<span class='warning'>[user] begins to pry the [src]'s cover!</span>", 3)
	playsound(src,'sound/effects/metal_creaking.ogg', 25, 1)
	if(do_after(user, 20, FALSE, src, BUSY_ICON_HOSTILE))
		go_out() //Force the occupant out.
	being_forced = !being_forced

/obj/machinery/cryopod/evacuation/proc/move_mob_inside(mob/M)
	if(occupant)
		to_chat(M, "<span class='warning'>The cryogenic pod is already in use. You will need to find another.</span>")
		return FALSE
		return
	M.forceMove(src)
	to_chat(M, "<span class='notice'>You feel cool air surround you as your mind goes blank and the pod locks.</span>")
	occupant = M
	occupant.in_stasis = STASIS_IN_CRYO_CELL
	icon_state = orient_right ? "body_scanner_1-r" : "body_scanner_1"

/obj/machinery/door/airlock/evacuation
	name = "\improper Evacuation Airlock"
	icon = 'icons/obj/doors/almayer/pod_doors.dmi'
	icon_state = "door_locked"
	resistance_flags = UNACIDABLE|INDESTRUCTIBLE
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

	//Can't interact with them, mostly to prevent grief and meta.
/obj/machinery/door/airlock/evacuation/Bumped()
	return FALSE
/obj/machinery/door/airlock/evacuation/attackby()
	return FALSE
/obj/machinery/door/airlock/evacuation/attack_hand()
	return TRUE
/obj/machinery/door/airlock/evacuation/attack_alien()
	return FALSE //Probably a better idea that these cannot be forced open.
/obj/machinery/door/airlock/evacuation/attack_ai()
	return FALSE
