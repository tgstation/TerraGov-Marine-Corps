/obj/docking_port/mobile/escape_pod
	name = "escape pod"
	dir = WEST
	dwidth = 2
	width = 5
	height = 4
	launch_status = UNLAUNCHED
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

/obj/docking_port/mobile/escape_pod/afterShuttleMove(turf/oldT, list/movement_force, shuttle_dir, shuttle_preferred_direction, move_dir, rotation)
	. = ..()
	if(launch_status == UNLAUNCHED)
		return
	intoTheSunset()

/obj/docking_port/mobile/escape_pod/proc/prep_for_launch()
	for(var/obj/machinery/door/airlock/evacuation/D in doors)
		INVOKE_ASYNC(D, /obj/machinery/door/airlock/evacuation/.proc/force_open)
	can_launch = TRUE

/obj/docking_port/mobile/escape_pod/proc/unprep_for_launch()
	// dont close the door it might trap someone inside
	can_launch = FALSE

/obj/docking_port/mobile/escape_pod/proc/auto_launch()
	if(!can_launch)
		return
	SSshuttle.request_transit_dock(src)
	mode = SHUTTLE_IGNITING
	launch_status = ENDGAME_LAUNCHED
	setTimer(ignitionTime)

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
		to_chat(H, "<span class='warning'>Evacuation is not enabled.</span>")
		return

	SSshuttle.request_transit_dock(M)
	M.mode = SHUTTLE_IGNITING
	M.launch_status = EARLY_LAUNCHED
	M.setTimer(M.ignitionTime)

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

		if(do_after(user, 20, TRUE, 5, BUSY_ICON_GENERIC))
			if(!M || !G || !G.grabbed_thing || !G.grabbed_thing.loc || G.grabbed_thing != M) return FALSE
			move_mob_inside(M)

/obj/machinery/cryopod/evacuation/eject()
	set name = "Eject Pod"
	set category = "Object"
	set src in oview(1)

	if(!occupant || !usr.stat || usr.restrained()) return FALSE

	if(occupant) //Once you're in, you cannot exit, and outside forces cannot eject you.
		//The occupant is actually automatically ejected once the evac is canceled.
		if(occupant != usr) to_chat(usr, "<span class='warning'>You are unable to eject the occupant unless the evacuation is canceled.</span>")

	add_fingerprint(usr)

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

	if(do_after(user, 20, FALSE, 5, BUSY_ICON_GENERIC))
		user.stop_pulling()
		move_mob_inside(user)

/obj/machinery/cryopod/evacuation/attack_alien(mob/living/carbon/Xenomorph/user)
	if(being_forced)
		to_chat(user, "<span class='xenowarning'>It's being forced open already!</span>")
		return FALSE

	if(!occupant)
		to_chat(user, "<span class='xenowarning'>There is nothing of interest in there.</span>")
		return FALSE

	being_forced = !being_forced
	visible_message("<span class='warning'>[user] begins to pry the [src]'s cover!</span>", 3)
	playsound(src,'sound/effects/metal_creaking.ogg', 25, 1)
	if(do_after(user, 20, FALSE, 5, BUSY_ICON_HOSTILE)) go_out() //Force the occupant out.
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
	add_fingerprint(M)
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
	return FALSE
/obj/machinery/door/airlock/evacuation/attack_alien()
	return FALSE //Probably a better idea that these cannot be forced open.
/obj/machinery/door/airlock/evacuation/attack_ai()
	return FALSE
