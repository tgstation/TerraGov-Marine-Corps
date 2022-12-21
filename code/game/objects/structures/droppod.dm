#define DROPPOD_READY 1
#define DROPPOD_ACTIVE 2
#define DROPPOD_LANDED 3
GLOBAL_LIST_INIT(blocked_droppod_tiles, typecacheof(list(/turf/open/space/transit, /turf/open/space, /turf/open/ground/empty, /turf/open/beach/sea, /turf/open/lavaland/lava))) // Don't drop at these tiles.

///Marine steel rain style drop pods, very cool!
/obj/structure/droppod
	name = "TGMC Zeus orbital drop pod"
	desc = "A menacing metal hunk of steel that is used by the TGMC for quick tactical redeployment."
	icon = 'icons/obj/structures/droppod.dmi'
	icon_state = "singlepod_open"
	density = TRUE
	anchored = TRUE
	layer = ABOVE_OBJ_LAYER
	resistance_flags = XENO_DAMAGEABLE
	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 70, ENERGY = 100, BOMB = 70, BIO = 100, FIRE = 0, ACID = 0)
	max_integrity = 50
	flags_atom = PREVENT_CONTENTS_EXPLOSION
	coverage = 75
	var/mob/occupant
	var/target_x = 1
	var/target_y = 1
	var/entertime = 5
	var/image/userimg
	var/drop_state = DROPPOD_READY
	var/launch_time = 10 SECONDS
	var/launch_allowed = TRUE
	///If true, you can launch the droppod before drop pod delay
	var/operation_started = FALSE
	var/datum/turf_reservation/reserved_area
	///after the pod finishes it's travelhow long it spends falling
	var/falltime = 0.6 SECONDS

/obj/structure/droppod/Initialize()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_DROPSHIP_HIJACKED, .proc/disable_launching)
	RegisterSignal(SSdcs, list(COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE, COMSIG_GLOB_OPEN_TIMED_SHUTTERS_XENO_HIVEMIND, COMSIG_GLOB_OPEN_SHUTTERS_EARLY, COMSIG_GLOB_TADPOLE_LAUNCHED), .proc/allow_drop)
	GLOB.droppod_list += src

/obj/structure/droppod/proc/disable_launching()
	SIGNAL_HANDLER
	launch_allowed = FALSE
	UnregisterSignal(SSdcs, COMSIG_GLOB_DROPSHIP_HIJACKED)

///Allow this droppod to ignore dropdelay
/obj/structure/droppod/proc/allow_drop()
	SIGNAL_HANDLER
	operation_started = TRUE
	UnregisterSignal(SSdcs, list(COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE, COMSIG_GLOB_OPEN_TIMED_SHUTTERS_XENO_HIVEMIND, COMSIG_GLOB_OPEN_SHUTTERS_EARLY, COMSIG_GLOB_TADPOLE_LAUNCHED))

/obj/structure/droppod/Destroy()
	if(occupant)
		exitpod(TRUE)
	userimg = null
	QDEL_NULL(reserved_area)
	GLOB.droppod_list -= src
	return ..()

/obj/structure/droppod/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("set_x_target")
			var/new_x = text2num(params["set_x"])
			if(!new_x)
				return
			target_x = clamp(new_x, 1, world.maxx)

		if("set_y_target")
			var/new_y = text2num(params["set_y"])
			if(!new_y)
				return
			target_y = clamp(new_y, 1, world.maxy)
		if("check_droppoint")
			checklanding(occupant)
		if("launch")
			launchpod(occupant)
		if("exitpod")
			exitpod()


/obj/structure/droppod/ui_data(mob/user)
	var/list/data = list(
		"occupant" = "Unknown User",
		"target_x" = target_x,
		"target_y" = target_y,
		"drop_state" = drop_state,
	)
	if(occupant?.name)
		data["occupant"] = occupant.name
	return data


/obj/structure/droppod/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "Droppod", "[name]")
		ui.open()

/obj/structure/droppod/attack_hand(mob/living/user)
	if(occupant)
		to_chat(user, span_notice("The droppod is already occupied!"))
		return

	if(drop_state != DROPPOD_READY)
		to_chat(user, span_notice("The droppod has already landed!"))
		return

	if(!do_after(user, entertime, TRUE, src))
		return

	if(occupant)
		to_chat(user, span_warning("Someone was faster than you!"))
		return

	occupant = user
	RegisterSignal(occupant, list(COMSIG_MOB_DEATH, COMSIG_PARENT_QDELETING), .proc/exitpod)
	user.forceMove(src)
	userimg = image(user)
	userimg.layer = DOOR_CLOSED_LAYER
	userimg.pixel_y = 5
	add_overlay(userimg)
	ui_interact(user)

/obj/structure/droppod/proc/checklanding(mob/user)
	var/turf/target = locate(target_x, target_y, 2)
	if(target.density)
		to_chat(user, span_warning("Dense landing zone detected. Invalid area."))
		return FALSE
	if(is_type_in_typecache(target, GLOB.blocked_droppod_tiles))
		to_chat(user, span_warning("Extremely lethal hazard detected on the target location. Invalid area."))
		return FALSE
	var/area/targetarea = get_area(target)
	if(targetarea.flags_area & NO_DROPPOD) // Thou shall not pass!
		to_chat(user, span_warning("Location outside mission parameters. Invalid area."))
		return FALSE
	if(!targetarea.outside)
		to_chat(user, span_warning("Cannot launch pod at a roofed area."))
		return FALSE
	for(var/x in target.contents)
		var/atom/object = x
		if(object.density)
			to_chat(user, span_warning("Dense object detected in target location. Invalid area."))
			return FALSE
	to_chat(user, span_notice("Valid area confirmed!"))
	return TRUE

/obj/structure/droppod/verb/openui()
	set category = "Drop pod"
	set name = "Open drop pod UI"
	set desc = "Opens the drop pod UI"
	set src in view(0)
	ui_interact(usr)

/obj/structure/droppod/proc/launchpod(mob/user)
	if(!occupant)
		return
	#ifndef TESTING
	if(!operation_started && world.time < SSticker.round_start_time + SSticker.mode.deploy_time_lock + DROPPOD_DEPLOY_DELAY)
		to_chat(user, span_notice("Unable to launch, the ship has not yet reached the combat area."))
		return
	#endif
	if(!launch_allowed)
		to_chat(user, span_notice("Error. Ship calibration unavailable. Please %#&ç:*"))
		return
	if(drop_state != DROPPOD_READY)
		return
	if(!checklanding(user))
		return

	var/turf/target = locate(target_x, target_y, 2)
	log_game("[key_name(user)] launched pod [src] at [AREACOORD(target)]")
	deadchat_broadcast(" has been launched", src, turf_target = target)
	for(var/mob/living/silicon/ai/AI AS in GLOB.ai_list)
		to_chat(AI, span_notice("[user] has launched [src] towards [target.loc] at X:[target_x] Y:[target_y]"))
	reserved_area = SSmapping.RequestBlockReservation(3,3)

	drop_state = DROPPOD_ACTIVE
	icon_state = "singlepod"
	cut_overlays()
	playsound(src, 'sound/effects/escape_pod_launch.ogg', 70)
	playsound(src, 'sound/effects/droppod_launch.ogg', 70)
	addtimer(CALLBACK(src, .proc/finish_drop, user), launch_time)
	forceMove(pick(reserved_area.reserved_turfs))
	new /area/arrival(loc)	//adds a safezone so we dont suffocate on the way down, cleaned up with reserved turfs

/obj/structure/droppod/proc/finish_drop(mob/user)
	var/turf/targetturf = locate(target_x, target_y, 2)
	for(var/a in targetturf.contents)
		var/atom/target = a
		if(target.density)	//if theres something dense in the turf try to recalculate a new turf
			to_chat(occupant, span_warning("[icon2html(src,occupant)] WARNING! TARGET ZONE OCCUPIED! EVADING!"))
			var/turf/T0 = locate(target_x + 2,target_y + 2,2)
			var/turf/T1 = locate(target_x - 2,target_y - 2,2)
			var/list/block = block(T0,T1) - targetturf
			for(var/t in block)//Randomly selects a free turf in a 5x5 block around the target
				var/turf/attemptdrop = t
				if(!attemptdrop.density && !istype(get_area(targetturf), /area/space))
					targetturf = attemptdrop
					break
			if(targetturf.density)//We tried and failed, revert to the old one, which has a new dense obj but is at least not dense
				to_chat(occupant, span_warning("[icon2html(src,occupant)] RECALCULATION FAILED!"))
				targetturf = locate(target_x, target_y,2)
			break

	forceMove(targetturf)
	pixel_y = 500
	animate(src, pixel_y = initial(pixel_y), time = falltime, easing = LINEAR_EASING)
	addtimer(CALLBACK(src, .proc/dodrop, targetturf, user), falltime)

///Do the stuff when it "hits the ground"
/obj/structure/droppod/proc/dodrop(turf/targetturf, mob/user)
	deadchat_broadcast(" has landed at [get_area(targetturf)]!", src, occupant)
	explosion(targetturf,-1,-1,2,-1)
	playsound(targetturf, 'sound/effects/droppod_impact.ogg', 100)
	QDEL_NULL(reserved_area)
	addtimer(CALLBACK(src, .proc/completedrop, user), 7) //dramatic effect

///completes everything after a dramatic effect
/obj/structure/droppod/proc/completedrop(mob/user)
	icon_state = "singlepod_open"
	drop_state = DROPPOD_LANDED
	exitpod()

/obj/structure/droppod/proc/exitpod(forced = FALSE)
	SIGNAL_HANDLER
	if(!occupant)
		return
	if(drop_state == DROPPOD_ACTIVE && !forced && occupant)
		to_chat(occupant, span_warning("You can't get out while the pod is in transit!"))
		return
	occupant?.forceMove(get_turf(src))
	UnregisterSignal(occupant, COMSIG_MOB_DEATH)
	occupant = null
	userimg = null
	cut_overlays()

/obj/structure/dropprop	//Just a prop for now but if the pods are someday made movable make a requirement to have these on the turf
	name = "Zeus pod launch bay"
	desc = "A hatch in the ground wih support for a Zeus drop pod launch."
	icon = 'icons/obj/structures/droppod.dmi'
	icon_state = "launch_bay"
	density = FALSE
	anchored = TRUE
	layer = ABOVE_TURF_LAYER
	resistance_flags = INDESTRUCTIBLE

#undef DROPPOD_READY
#undef DROPPOD_ACTIVE
#undef DROPPOD_LANDED
