/obj/docking_port/mobile/escape_pod
	name = "escape pod"
	dir = WEST
	dwidth = 2
	width = 5
	height = 4

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

//=========================================================================================
//================================Evacuation Sleeper=======================================
//=========================================================================================

/obj/machinery/cryopod/evacuation
	stat = MACHINE_DO_NOT_PROCESS
	unacidable = 1
	time_till_despawn = 6000000 //near infinite so despawn never occurs.
	var/being_forced = 0 //Simple variable to prevent sound spam.
	var/datum/computer/file/embedded_program/docking/simple/escape_pod/evacuation_program

	ex_act(severity) return FALSE

	attackby(obj/item/grab/G, mob/user)
		if(istype(G))
			if(being_forced)
				to_chat(user, "<span class='warning'>There's something forcing it open!</span>")
				return FALSE

			if(occupant)
				to_chat(user, "<span class='warning'>There is someone in there already!</span>")
				return FALSE

			//if(evacuation_program.dock_state < STATE_READY)
			//	to_chat(user, "<span class='warning'>The cryo pod is not responding to commands!</span>")
			//	return FALSE

			var/mob/living/carbon/human/M = G.grabbed_thing
			if(!istype(M)) return FALSE

			visible_message("<span class='warning'>[user] starts putting [M.name] into the cryo pod.</span>", 3)

			if(do_after(user, 20, TRUE, 5, BUSY_ICON_GENERIC))
				if(!M || !G || !G.grabbed_thing || !G.grabbed_thing.loc || G.grabbed_thing != M) return FALSE
				move_mob_inside(M)

	eject()
		set name = "Eject Pod"
		set category = "Object"
		set src in oview(1)

		if(!occupant || !usr.stat || usr.is_mob_restrained()) return FALSE

		if(occupant) //Once you're in, you cannot exit, and outside forces cannot eject you.
			//The occupant is actually automatically ejected once the evac is canceled.
			if(occupant != usr) to_chat(usr, "<span class='warning'>You are unable to eject the occupant unless the evacuation is canceled.</span>")

		add_fingerprint(usr)

	go_out() //When the system ejects the occupant.
		if(occupant)
			occupant.forceMove(get_turf(src))
			occupant.in_stasis = FALSE
			occupant = null
			icon_state = orient_right ? "body_scanner_0-r" : "body_scanner_0"

	move_inside()
		set name = "Enter Pod"
		set category = "Object"
		set src in oview(1)

		var/mob/living/carbon/human/user = usr

		if(!istype(user) || user.stat || user.is_mob_restrained()) return FALSE

		if(being_forced)
			to_chat(user, "<span class='warning'>You can't enter when it's being forced open!</span>")
			return FALSE

		if(occupant)
			to_chat(user, "<span class='warning'>The cryogenic pod is already in use! You will need to find another.</span>")
			return FALSE

		//if(evacuation_program.dock_state < STATE_READY)
		//	to_chat(user, "<span class='warning'>The cryo pod is not responding to commands!</span>")
		//	return FALSE

		visible_message("<span class='warning'>[user] starts climbing into the cryo pod.</span>", 3)

		if(do_after(user, 20, FALSE, 5, BUSY_ICON_GENERIC))
			user.stop_pulling()
			move_mob_inside(user)

	attack_alien(mob/living/carbon/Xenomorph/user)
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
	heat_proof = 1
	unacidable = 1

/obj/machinery/door/airlock/evacuation/Initialize()
	. = ..()
	lock()

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
