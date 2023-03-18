#define DROPPOD_READY 1
#define DROPPOD_ACTIVE 2
#define DROPPOD_LANDED 3
GLOBAL_LIST_INIT(blocked_droppod_tiles, typecacheof(list(/turf/open/space/transit, /turf/open/space, /turf/open/ground/empty, /turf/open/beach/sea, /turf/open/lavaland/lava))) // Don't drop at these tiles.

///Time drop pod spends in the transit z, mostly for visual flavor
#define DROPPOD_TRANSIT_TIME 10 SECONDS
///radius of dispersion for leader pods
#define LEADER_POD_DISPERSION 5

///base marine drop pod. can be controlled by an attached [/obj/structure/droppod/leader] or [/obj/machinery/computer/droppod_control]
/obj/structure/droppod
	name = "\improper TGMC Zeus orbital drop pod"
	desc = "A menacing metal hunk of steel that is used by the TGMC for quick tactical redeployment."
	icon = 'icons/obj/structures/droppod.dmi'
	icon_state = "singlepod"
	density = TRUE
	anchored = TRUE
	layer = ABOVE_OBJ_LAYER
	resistance_flags = XENO_DAMAGEABLE
	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 70, ENERGY = 100, BOMB = 70, BIO = 100, FIRE = 0, ACID = 0)
	max_integrity = 50
	flags_atom = PREVENT_CONTENTS_EXPLOSION
	coverage = 75
	buckle_flags = CAN_BUCKLE|BUCKLE_PREVENTS_PULL
	//todo make these just use a turf?
	///X target coordinate
	var/target_x = 1
	///Y target coordinate
	var/target_y = 1
	///Current drop pod status: shipside = ready, active = mid-drop, landed = planetside
	var/drop_state = DROPPOD_READY
	///Whether launch is allowed. for things like disabling during hijack phase
	var/launch_allowed = TRUE
	///If true, you can launch the droppod before drop pod delay
	var/operation_started = FALSE
	///3x3 transit reservation for immersion as if flying through space
	var/datum/turf_reservation/reserved_area
	///Action to actually launch the drop pod
	var/list/datum/action/innate/interaction_actions
	///after the pod finishes it's travelhow long it spends falling
	var/falltime = 0.6 SECONDS

/obj/structure/droppod/Initialize()
	. = ..()
	interaction_actions = list()
	interaction_actions += new /datum/action/innate/set_drop_target(src)
	interaction_actions += new /datum/action/innate/launch_droppod(src)
	RegisterSignal(SSdcs, COMSIG_GLOB_DROPSHIP_HIJACKED, .proc/disable_launching)
	RegisterSignal(SSdcs, list(COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE, COMSIG_GLOB_OPEN_TIMED_SHUTTERS_XENO_HIVEMIND, COMSIG_GLOB_OPEN_SHUTTERS_EARLY, COMSIG_GLOB_TADPOLE_LAUNCHED), .proc/allow_drop)
	GLOB.droppod_list += src
	update_icon()

/obj/structure/droppod/Destroy()
	for(var/atom/movable/ejectee AS in contents) // dump them out, just in case no mobs det deleted
		ejectee.forceMove(loc)
	QDEL_NULL(reserved_area)
	QDEL_LIST(interaction_actions)
	GLOB.droppod_list -= src // todo should be active pods only for iterative checks
	return ..()

///Disables launching upon dropship hijack
/obj/structure/droppod/proc/disable_launching()
	SIGNAL_HANDLER
	launch_allowed = FALSE
	UnregisterSignal(SSdcs, COMSIG_GLOB_DROPSHIP_HIJACKED)

///Allow this droppod to ignore dropdelay
/obj/structure/droppod/proc/allow_drop()
	SIGNAL_HANDLER
	operation_started = TRUE
	UnregisterSignal(SSdcs, list(COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE, COMSIG_GLOB_OPEN_TIMED_SHUTTERS_XENO_HIVEMIND, COMSIG_GLOB_OPEN_SHUTTERS_EARLY, COMSIG_GLOB_TADPOLE_LAUNCHED))

/obj/structure/droppod/update_icon_state()
	. = ..()
	if(drop_state == DROPPOD_ACTIVE)
		icon_state = initial(icon_state)
		return
	icon_state = initial(icon_state) + "_open"

/obj/structure/droppod/user_buckle_mob(mob/living/M, mob/user, check_loc = TRUE)
	if(!in_range(user, src) || !in_range(M, src))
		return FALSE
	return ..(M, user, FALSE)

/obj/structure/droppod/buckle_mob(mob/living/buckling_mob, force, check_loc, lying_buckle, hands_needed, target_hands_needed, silent)
	if(drop_state != DROPPOD_READY)
		if(!silent)
			balloon_alert(buckling_mob, "Already used")
		return FALSE
	. = ..()
	if(!.)
		return
	for(var/datum/action/innate/action AS in interaction_actions)
		action.give_action(buckling_mob)
	buckling_mob.pixel_y = 7

/obj/structure/droppod/unbuckle_mob(mob/living/buckled_mob, force)
	. = ..()
	if(!.)
		return
	for(var/datum/action/innate/action AS in interaction_actions)
		action.remove_action(buckled_mob)
	buckled_mob.pixel_y = initial(buckled_mob.pixel_y)

///sets target of this drop pod and notifies the user if it's a valid target
/obj/structure/droppod/proc/set_target(new_x, new_y)
	target_x = new_x
	target_y = new_y
	var/mob/notified_user = LAZYACCESS(buckled_mobs, 1)
	if(notified_user)
		. = checklanding(notified_user)
		if(.)
			balloon_alert(notified_user, "Coordinates updated")

///returns boolean if the currently set target/optionally passed turf are valid to drop to
/obj/structure/droppod/proc/checklanding(mob/user, optional_turf)
	var/turf/target = optional_turf ? optional_turf : locate(target_x, target_y, 2)
	if(target.density)
		if(user)
			balloon_alert(user, "Dense area")
		return FALSE
	if(is_type_in_typecache(target, GLOB.blocked_droppod_tiles))
		if(user)
			balloon_alert(user, "Hazardous zone")
		return FALSE
	var/area/targetarea = get_area(target)
	if(targetarea.flags_area & NO_DROPPOD) // Thou shall not pass!
		if(user)
			balloon_alert(user, "Invalid area")
		return FALSE
	if(!targetarea.outside)
		if(user)
			balloon_alert(user, "Roofed area")
		return FALSE
	if(targetarea.ceiling > CEILING_METAL)
		if(user)
			balloon_alert(user, "Area underground")
		return FALSE
	for(var/atom/movable/object AS in target.contents)
		if(object.density)
			if(user)
				balloon_alert(user, "Dense object detected")
			return FALSE
	return TRUE

///attempts to launch the drop pod at it's currently set coordinates. commanded_drop is TRUE when the drop is being requested by a command drop pod
/obj/structure/droppod/proc/launchpod(mob/user, commanded_drop = FALSE)
	if(!LAZYLEN(buckled_mobs))
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

	for(var/mob/podder AS in buckled_mobs)
		podder.forceMove(src)

	var/turf/target = locate(target_x, target_y, 2)
	log_game("[key_name(user)] launched pod [src] at [AREACOORD(target)]")
	deadchat_broadcast(" has been launched", src, turf_target = target)
	for(var/mob/living/silicon/ai/AI AS in GLOB.ai_list)
		to_chat(AI, span_notice("[user] has launched [src] towards [target.loc] at X:[target_x] Y:[target_y]"))
	reserved_area = SSmapping.RequestBlockReservation(3,3)

	drop_state = DROPPOD_ACTIVE
	update_icon()
	playsound(src, 'sound/effects/escape_pod_launch.ogg', 70)
	playsound(src, 'sound/effects/droppod_launch.ogg', 70)
	addtimer(CALLBACK(src, .proc/finish_drop, user), DROPPOD_TRANSIT_TIME)
	forceMove(pick(reserved_area.reserved_turfs))
	new /area/arrival(loc)	//adds a safezone so we dont suffocate on the way down, cleaned up with reserved turfs

/// Moves the droppod into its target turf, which it updates if needed
/obj/structure/droppod/proc/finish_drop(mob/user)
	var/turf/targetturf = locate(target_x, target_y, 2)
	for(var/a in targetturf.contents)
		var/atom/target = a
		if(target.density)	//if theres something dense in the turf try to recalculate a new turf
			to_chat(user, span_warning("[icon2html(src, user)] WARNING! TARGET ZONE OCCUPIED! EVADING!"))
			balloon_alert(user, "EVADING")
			var/turf/T0 = locate(target_x + 2,target_y + 2,2)
			var/turf/T1 = locate(target_x - 2,target_y - 2,2)
			var/list/block = block(T0,T1) - targetturf
			for(var/t in block)//Randomly selects a free turf in a 5x5 block around the target
				var/turf/attemptdrop = t
				if(!attemptdrop.density && !is_type_in_typecache(attemptdrop, GLOB.blocked_droppod_tiles))
					targetturf = attemptdrop
					break
			if(targetturf.density)//We tried and failed, revert to the old one, which has a new dense obj but is at least not dense
				to_chat(user, span_warning("[icon2html(src, user)] RECALCULATION FAILED!"))
				targetturf = locate(target_x, target_y,2)
			break

	forceMove(targetturf)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_DROPPOD_LANDED, targetturf)
	pixel_y = 500
	animate(src, pixel_y = initial(pixel_y), time = falltime, easing = LINEAR_EASING)
	addtimer(CALLBACK(src, .proc/dodrop, targetturf, user), falltime)

///Do the stuff when it "hits the ground"
/obj/structure/droppod/proc/dodrop(turf/targetturf, mob/user)
	deadchat_broadcast(" has landed at [get_area(targetturf)]!", src, user)
	explosion(targetturf,-1,-1,2,-1)
	playsound(targetturf, 'sound/effects/droppod_impact.ogg', 100)
	QDEL_NULL(reserved_area)
	addtimer(CALLBACK(src, .proc/completedrop, user), 7) //dramatic effect

///completes landing a little delayed for a dramatic effect
/obj/structure/droppod/proc/completedrop(mob/user)
	drop_state = DROPPOD_LANDED
	update_icon()
	for(var/atom/movable/deployed AS in contents)
		deployed.forceMove(loc)


/obj/structure/droppod/leader
	name = "\improper TGMC Zeus command drop pod"
	desc = "A menacing metal hunk of steel that is used by the TGMC for quick tactical redeployment. This one comes with command capabilities."
	icon_state = "leaderpod"

/obj/structure/droppod/leader/buckle_mob(mob/living/buckling_mob, force, check_loc, lying_buckle, hands_needed, target_hands_needed, silent)
	. = ..()
	if(!.)
		return
	if(buckling_mob.skills.getRating(SKILL_LEADERSHIP) < SKILL_LEAD_EXPERT)
		balloon_alert(buckling_mob, "Can't use that!") // basically squad lead+ cant touch this
		return FALSE

/obj/structure/droppod/leader/set_target(new_x, new_y)
	. = ..()
	if(!.)
		return
	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_DROPPOD_TARGETTING))
		addtimer(CALLBACK(src, /atom.proc/balloon_alert, buckled_mobs[1], "Target Assignment cooldown"), 7)
		return
	// this isnt the cheapest thing in the world so lets not let players spam it
	TIMER_COOLDOWN_START(src, COOLDOWN_DROPPOD_TARGETTING, 10 SECONDS)

	var/turf/target = locate(new_x, new_y, 2)
	var/occupied_pods
	for(var/obj/structure/droppod/pod AS in GLOB.droppod_list)
		if(LAZYLEN(pod.buckled_mobs))
			occupied_pods++
	var/dispersion = max(LEADER_POD_DISPERSION, LEADER_POD_DISPERSION + ((occupied_pods - 10) / 5))
	var/turf/topright = locate(new_x + dispersion, new_y + dispersion,2)
	var/turf/bottomleft = locate(new_x - dispersion, new_y - dispersion,2)
	var/list/block = block(bottomleft, topright) - locate()
	for(var/turf/attemptdrop AS in block) // prune invalid turfs
		if(!checklanding(null, attemptdrop))
			block -= attemptdrop
	if(length(block) <= 10)
		addtimer(CALLBACK(src, /atom.proc/balloon_alert, buckled_mobs[1], "Target Assignment failed"), 7)
		return

	for(var/obj/structure/droppod/pod in GLOB.droppod_list)
		for(var/mob/user AS in pod.buckled_mobs)
			user.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:center valign='top'><u>DROP UPDATED:</u></span><br>New target: [target.loc]", /atom/movable/screen/text/screen_text/command_order)
		var/turf/newturf
		if(length(block))
			newturf = pick_n_take(block)
		else
			newturf = target // yolo drop let the evador handle it

		pod.target_x = newturf.x
		pod.target_y = newturf.y

/obj/structure/droppod/leader/launchpod(mob/user, commanded_drop = FALSE)
	#ifndef TESTING
	if(!operation_started && world.time < SSticker.round_start_time + SSticker.mode.deploy_time_lock + DROPPOD_DEPLOY_DELAY)
		to_chat(user, span_notice("Unable to launch, the ship has not yet reached the combat area."))
		return
	#endif
	if(!launch_allowed)
		to_chat(user, span_notice("Error. Ship calibration unavailable. Please %#&ç:*"))
		return
	if(commanded_drop)
		return ..()
	//todo find an alarm sound and play it here for audio confirmation?
	for(var/obj/structure/droppod/pod in GLOB.droppod_list)
		if(!LAZYLEN(pod.buckled_mobs))
			continue
		for(var/mob/dropper AS in pod.buckled_mobs)
			dropper.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:center valign='top'><u>DROP UPDATED:</u></span><br>COMMENCING MASS DEPLOYMENT", /atom/movable/screen/text/screen_text/command_order)
		var/predroptime = rand(4 SECONDS, 5 SECONDS) //Randomize it a bit so its staggered
		addtimer(CALLBACK(pod, /obj/structure/droppod/.proc/launchpod, pod.buckled_mobs[1], TRUE), predroptime)


/datum/action/innate/launch_droppod
	name = "Begin Launch"
	action_icon = 'icons/mecha/actions_mecha.dmi'
	action_icon_state = "land"

/datum/action/innate/launch_droppod/Activate()
	. = ..()
	var/obj/structure/droppod/pod = target
	pod.launchpod(owner)

/datum/action/innate/set_drop_target
	name = "Set drop pod target"
	action_icon = 'icons/mecha/actions_mecha.dmi'
	action_icon_state = "mech_zoom_on"

/datum/action/innate/set_drop_target/Activate()
	. = ..()
	//yes this is hardcoded bite me
	var/atom/movable/screen/minimap/map = SSminimaps.fetch_minimap_object(2, MINIMAP_FLAG_MARINE)
	owner.client.screen += map
	var/list/polled_coords = map.get_coords_from_click(owner)
	if(!polled_coords)
		return
	owner.client?.screen -= map
	var/obj/structure/droppod/pod = target
	pod.set_target(polled_coords[1], polled_coords[2])

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
