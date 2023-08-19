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
	var/datum/action/innate/droppod_camera_off/off_action
	var/datum/action/innate/droppod_destination/destination_action
	var/datum/action/innate/start_droppod/launch_action
	var/list/actions
	var/view_range = "5x5"
	var/list/z_lock = list()
	var/mob/camera/aiEye/remote/droppod/eyeobj
	var/mob/living/current_camera_user

/obj/structure/droppod/Initialize()
	. = ..()
	off_action = new
	destination_action = new
	launch_action = new
	actions = list()
	z_lock |= SSmapping.levels_by_trait(ZTRAIT_GROUND)
	RegisterSignal(SSdcs, COMSIG_GLOB_DROPSHIP_HIJACKED, PROC_REF(disable_launching))
	RegisterSignal(SSdcs, list(COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE, COMSIG_GLOB_OPEN_TIMED_SHUTTERS_XENO_HIVEMIND, COMSIG_GLOB_OPEN_SHUTTERS_EARLY, COMSIG_GLOB_TADPOLE_LAUNCHED), PROC_REF(allow_drop))
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

	current_camera_user?.unset_interaction()
	if(eyeobj)
		qdel(eyeobj)
	QDEL_LIST(actions)

	return ..()

/obj/structure/droppod/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("camera_mode")
			open_camera(ui.user, GLOB.minidropship_start_loc)
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
			checklanding(ui.user)
		if("launch")
			launchpod(ui.user)
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
	if(drop_state != DROPPOD_READY)
		to_chat(user, span_notice("The droppod has already landed!"))
		return

	if(occupant != null)
		ui_interact(user)
		if(occupant != user)
			to_chat(user, span_notice("The droppod is already occupied!"))
		return

	put_mob(user, user)

/obj/structure/droppod/attackby(obj/item/I, mob/user, params)
	var/obj/item/grab/G = I

	if(ismob(G.grabbed_thing))
		var/mob/M = G.grabbed_thing
		put_mob(M, user)
		return

	. = ..()

/obj/structure/droppod/attack_alien(mob/living/carbon/xenomorph/X, damage_amount, damage_type, damage_flag, effects, armor_penetration, isrightclick)
	if(drop_state != DROPPOD_READY)
		. = ..()
		return
	if(!occupant)
		to_chat(X, span_xenowarning("There is nothing of interest in there."))
		return
	if(X.status_flags & INCORPOREAL || X.do_actions)
		return
	visible_message(span_warning("[X] begins to pry the [src]'s cover!"), 3)
	playsound(src,'sound/effects/metal_creaking.ogg', 25, 1)
	if(!do_after(X, 2 SECONDS))
		return
	playsound(loc, 'sound/effects/metal_creaking.ogg', 25, 1)
	exitpod()

/obj/structure/droppod/verb/eject()
	set src in oview(1)
	set category = "Object"
	set name = "Eject occupant"
	exitpod()

/obj/structure/droppod/MouseDrop_T(mob/M, mob/user)
	if(!isliving(M) || !ishuman(user))
		return
	put_mob(M, user)

/obj/structure/droppod/proc/put_mob(mob/M, mob/living/user)
	if(drop_state != DROPPOD_READY)
		to_chat(user, span_notice("The droppod has already landed!"))
		return

	if(!do_after(M, entertime, TRUE, src))
		return

	if(occupant != null)
		to_chat(user, span_notice("The droppod is already occupied!"))
		return

	if(!ishuman(M))
		to_chat(user, span_warning("There is no way [src] will accept [M]!"))
		return

	if(user.do_actions || M.do_actions || !do_after(user, entertime, TRUE, src, BUSY_ICON_GENERIC))
		return

	ui_interact(user)
	M.stop_pulling()

	occupant = M
	RegisterSignal(M, list(COMSIG_MOB_DEATH, COMSIG_PARENT_QDELETING), PROC_REF(exitpod))
	M.forceMove(src)
	userimg = image(M)
	userimg.layer = DOOR_CLOSED_LAYER
	userimg.pixel_y = 5
	add_overlay(userimg)
	for(var/obj/O in src)
		qdel(O)

/obj/structure/droppod/relaymove(mob/user)
	if(user.incapacitated(TRUE) || drop_state != DROPPOD_READY)
		return
	exitpod()

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
	if(targetarea.ceiling > CEILING_METAL)
		to_chat(user, span_warning("Target location is deep underground. Invalid area."))
		return FALSE
	for(var/x in target.contents)
		var/atom/object = x
		if(object.density)
			to_chat(user, span_warning("Dense object detected in target location. Invalid area."))
			return FALSE
	to_chat(user, span_notice("Valid area confirmed!"))
	return TRUE

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
		to_chat(AI, span_notice("[occupant] has launched [src] by [user] towards [target.loc] at X:[target_x] Y:[target_y]"))
	reserved_area = SSmapping.RequestBlockReservation(3,3)

	drop_state = DROPPOD_ACTIVE
	icon_state = "singlepod"
	cut_overlays()
	remove_eye_control(current_camera_user)
	playsound(src, 'sound/effects/escape_pod_launch.ogg', 70)
	playsound(src, 'sound/effects/droppod_launch.ogg', 70)
	addtimer(CALLBACK(src, PROC_REF(finish_drop), occupant), launch_time)
	forceMove(pick(reserved_area.reserved_turfs))
	new /area/arrival(loc)	//adds a safezone so we dont suffocate on the way down, cleaned up with reserved turfs

	var/obj/effect/overlay/pod_warning/laserpod = new /obj/effect/overlay/pod_warning(target)
	laserpod.dir = target
	QDEL_IN(laserpod, launch_time)

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
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_DROPPOD_LANDED, targetturf)
	pixel_y = 500
	animate(src, pixel_y = initial(pixel_y), time = falltime, easing = LINEAR_EASING)
	addtimer(CALLBACK(src, PROC_REF(dodrop), targetturf, user), falltime)

///Do the stuff when it "hits the ground"
/obj/structure/droppod/proc/dodrop(turf/targetturf, mob/user)
	deadchat_broadcast(" has landed at [get_area(targetturf)]!", src, occupant)
	explosion(targetturf,-1,-1,2,-1)
	playsound(targetturf, 'sound/effects/droppod_impact.ogg', 100)
	QDEL_NULL(reserved_area)
	addtimer(CALLBACK(src, PROC_REF(completedrop), user), 7) //dramatic effect

///completes everything after a dramatic effect
/obj/structure/droppod/proc/completedrop(mob/user)
	icon_state = "singlepod_open"
	drop_state = DROPPOD_LANDED
	exitpod()

/obj/structure/droppod/proc/exitpod(forced = FALSE)
	SIGNAL_HANDLER
	if(!occupant)
		return
	if(eyeobj && eyeobj.eye_user == occupant)
		remove_eye_control(occupant)
	if(drop_state == DROPPOD_ACTIVE && !forced && occupant)
		to_chat(occupant, span_warning("You can't get out while the pod is in transit!"))
		return
	occupant?.forceMove(get_turf(src))
	UnregisterSignal(occupant, COMSIG_MOB_DEATH)
	occupant = null
	userimg = null
	cut_overlays()

/obj/structure/droppod/proc/give_actions(mob/living/user)
	if(!user)
		if(!occupant)
			return
		user = occupant

	if(off_action)
		off_action.target = user
		off_action.give_action(user)
		actions += off_action

	if(drop_state != DROPPOD_READY)
		return

	if(destination_action)
		destination_action.target = user
		destination_action.give_action(user)
		actions += destination_action

	if(launch_action)
		launch_action.target = user
		launch_action.give_action(user)
		actions += launch_action

/obj/structure/droppod/proc/CreateEye()
	eyeobj = new /mob/camera/aiEye/remote/droppod(null, src)
	eyeobj.origin = src

/obj/structure/droppod/proc/give_eye_control(mob/user)
	give_actions(user)
	current_camera_user = user
	eyeobj.eye_user = user
	eyeobj.name = "([src]) Camera Eye"
	user.remote_control = eyeobj
	user.reset_perspective(eyeobj)
	eyeobj.setLoc(eyeobj.loc)
	user.client.view_size.set_view_radius_to(view_range)

/obj/structure/droppod/proc/remove_eye_control(mob/living/user)
	if(!user)
		return
	if(!eyeobj)
		return
	for(var/V in actions)
		var/datum/action/A = V
		A.remove_action(user)
	actions.Cut()
	for(var/V in eyeobj.visibleCameraChunks)
		var/datum/camerachunk/C = V
		C.remove(eyeobj)
	if(user.client)
		user.reset_perspective(null)
		if(eyeobj.visible_icon && user.client)
			user.client.images -= eyeobj.user_image
	eyeobj.eye_user = null
	user.remote_control = null

	current_camera_user = null
	user.unset_interaction()
	user.client.view_size.reset_to_default()

/datum/action/innate/droppod_destination
	name = "Accept destination"
	background_icon_state = "template2"
	action_icon_state = "sniper_zoom"

/datum/action/innate/droppod_destination/Activate()
	if(QDELETED(target) || !isliving(target))
		return

	var/mob/C = target
	var/mob/camera/aiEye/remote/remote_eye = C.remote_control
	var/obj/structure/droppod/origin = remote_eye.origin

	origin?.target_x = remote_eye.loc.x
	origin?.target_y = remote_eye.loc.y

	if(!origin?.checklanding(C))
		return

	origin?.remove_eye_control(target)

/datum/action/innate/droppod_camera_off
	name = "Disable Camera Mode"
	background_icon_state = "template2"
	action_icon_state = "camera_off"

/datum/action/innate/droppod_camera_off/Activate()
	var/mob/living/C = target
	var/mob/camera/aiEye/remote/remote_eye = C.remote_control
	var/obj/structure/droppod/origin = remote_eye.origin
	origin?.remove_eye_control(target)

/datum/action/innate/start_droppod
	name = "Launch Droppod"
	action_icon = 'icons/mecha/actions_mecha.dmi'
	background_icon_state = "template2"
	action_icon_state = "land"

/datum/action/innate/start_droppod/Activate()
	var/mob/living/C = target
	var/mob/camera/aiEye/remote/remote_eye = C.remote_control
	var/obj/structure/droppod/origin = remote_eye.origin

	origin?.target_x = remote_eye.loc.x
	origin?.target_y = remote_eye.loc.y

	if(origin?.checklanding(target))
		origin?.launchpod(target)

/mob/camera/aiEye/remote/droppod
	visible_icon = TRUE
	use_static = FALSE
	icon_state = "marker"
	var/nvg_vision_possible = FALSE

/mob/camera/aiEye/remote/droppod/Initialize(mapload, obj/machinery/computer/camera_advanced/origin)
	src.origin = origin
	return ..()

/mob/camera/aiEye/remote/droppod/relaymove(mob/user, direct)
	var/turf/T = get_turf(get_step(src, direct))

	if(isnull(T))
		return

	if(check_place(T) != nvg_vision_possible) //Cannot see in caves
		nvg_vision_possible = !nvg_vision_possible
		update_remote_sight(user)

	setLoc(T)

/mob/camera/aiEye/remote/droppod/update_remote_sight(mob/living/user)
	if(nvg_vision_possible)
		user.see_in_dark = 6
		user.sight = 0
		user.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
		user.sync_lighting_plane_alpha()
		return TRUE
	user.see_in_dark = 0
	user.sight = BLIND|SEE_TURFS
	user.lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
	user.sync_lighting_plane_alpha()
	return TRUE

/mob/camera/aiEye/remote/droppod/proc/check_place(turf/target)
	if(target.density)
		return FALSE
	if(is_type_in_typecache(target, GLOB.blocked_droppod_tiles))
		return FALSE
	var/area/targetarea = get_area(target)
	if(targetarea.flags_area & NO_DROPPOD) // Thou shall not pass!
		return FALSE
	if(!targetarea.outside)
		return FALSE
	if(targetarea.ceiling > CEILING_METAL)
		return FALSE
	for(var/x in target.contents)
		var/atom/object = x
		if(object.density)
			return FALSE
	return TRUE

/obj/structure/droppod/proc/open_camera(mob/user, turf/premade_camera_location)
	#ifndef TESTING
	if(!operation_started && world.time < SSticker.round_start_time + SSticker.mode.deploy_time_lock + DROPPOD_DEPLOY_DELAY)
		to_chat(user, span_notice("Unable to launch, the ship has not yet reached the combat area."))
		return
	#endif

	if(current_camera_user)
		to_chat(user, "The camera is already in use!")
		return

	var/mob/living/L = user

	if(!eyeobj)
		CreateEye()

	if(!eyeobj.eye_initialized)
		if(premade_camera_location)
			eyeobj.eye_initialized = TRUE
			give_eye_control(L)
			eyeobj.setLoc(premade_camera_location)
			return
		var/camera_location
		var/turf/myturf = get_turf(src)
		camera_location = myturf
		z_lock |= SSmapping.levels_by_trait(ZTRAIT_GROUND)
		if(length_char(z_lock) && !(myturf.z in z_lock))
			camera_location = locate(round(world.maxx / 2), round(world.maxy / 2), z_lock[1])

		if(camera_location)
			eyeobj.eye_initialized = TRUE
			give_eye_control(L)
			eyeobj.setLoc(camera_location)
		else
			user.unset_interaction()
	else
		give_eye_control(L)
		eyeobj.setLoc(eyeobj.loc)

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
