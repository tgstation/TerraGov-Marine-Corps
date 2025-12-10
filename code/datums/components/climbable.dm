/*!
 * Component for fuel storage objects
 */

/datum/component/climbable
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/atom/movable/am_parent
	var/climb_delay

/datum/component/climbable/Initialize(_climb_delay = 1 SECONDS)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE
	am_parent = parent
	climb_delay = _climb_delay


/datum/component/climbable/Destroy(force, silent)
	am_parent = null
	return ..()

/datum/component/climbable/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOUSEDROPPED_ONTO, PROC_REF(attempt_climb))
	RegisterSignal(parent, COMSIG_MOVABLE_CHECK_CLIMBABLE, PROC_REF(check_climbable))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/component/climbable/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_MOUSEDROPPED_ONTO,
		COMSIG_MOVABLE_CHECK_CLIMBABLE,
		COMSIG_ATOM_EXAMINE,
	))

///Attempts to climb onto, or past parent
/datum/component/climbable/proc/attempt_climb(atom/source, atom/dropping, mob/user, params)
	SIGNAL_HANDLER
	if(!isliving(user))
		return
	if(dropping != user) //maybe change this actually
		return
	var/list/modifiers = params2list(params)
	var/turf/click_turf
	if(!user.client)
		click_turf = params2turf(modifiers["screen-loc"], get_turf(user), null)
	else
		click_turf = params2turf(modifiers["screen-loc"], get_turf(user.client.eye), user.client)
	INVOKE_ASYNC(src, PROC_REF(do_climb), user, click_turf)

/datum/component/climbable/proc/do_climb(mob/living/user, turf/clicked_turf)
	if(user.do_actions || !can_climb(user, clicked_turf))
		return

	user.visible_message(span_warning("[user] starts [am_parent.atom_flags & ON_BORDER ? "leaping over" : "climbing onto"] \the [am_parent]!"))

	ADD_TRAIT(user, TRAIT_IS_CLIMBING, REF(am_parent))
	if(!do_after(user, climb_delay, IGNORE_HELD_ITEM, am_parent, BUSY_ICON_GENERIC))
		REMOVE_TRAIT(user, TRAIT_IS_CLIMBING, REF(am_parent))
		return
	REMOVE_TRAIT(user, TRAIT_IS_CLIMBING, REF(am_parent))

	var/turf/destination_turf = can_climb(user, clicked_turf)
	if(!istype(destination_turf))
		return

	for(var/buckled in user.buckled_mobs)
		user.unbuckle_mob(buckled)

	user.forceMove(destination_turf)
	user.visible_message(span_warning("[user] [am_parent.atom_flags & ON_BORDER ? "leaps over" : "climbs onto"] \the [am_parent]!"))

///Checks to see if a mob can climb onto, or over this object
/datum/component/climbable/proc/can_climb(mob/living/user, turf/clicked_turf)
	if(!am_parent.can_interact(user)) //this is cursed because it requires dexterity
		return

	//var/turf/destination_turf = am_parent.loc
	var/turf/destination_turf = clicked_turf
	var/turf/user_turf = get_turf(user)
	if(!istype(destination_turf) || !istype(user_turf))
		return
	if(!user.Adjacent(destination_turf))
		return

	if((am_parent.atom_flags & ON_BORDER))
		if(user_turf != destination_turf && user_turf != get_step(destination_turf, am_parent.dir))
			to_chat(user, span_warning("You need to be up against [am_parent] to leap over."))
			return
		if(user_turf == destination_turf)
			destination_turf = get_step(destination_turf, am_parent.dir) //we're moving from the objects turf to the one its facing

	if(destination_turf.density)
		return

	for(var/atom/movable/AM AS in destination_turf.contents)
		if(AM == am_parent)
			continue
		if(isstructure(AM))
			var/obj/structure/structure = AM
			if(structure.allow_pass_flags & PASS_WALKOVER)
				continue
		if(AM.density && (!(AM.atom_flags & ON_BORDER) || AM.dir & get_dir(am_parent, user)))
			to_chat(user, span_warning("There's \a [AM.name] in the way."))
			return

	for(var/atom/movable/AM AS in user_turf.contents)
		if(isstructure(AM))
			var/obj/structure/structure = AM
			if(structure.allow_pass_flags & PASS_WALKOVER)
				continue
		if(AM.density && (AM.atom_flags & ON_BORDER) && AM.dir & get_dir(user, am_parent))
			to_chat(user, span_warning("There's \a [AM.name] in the way."))
			return

	return destination_turf

///Shows remaining fuel on examine
/datum/component/climbable/proc/on_examine(datum/source, mob/user, list/details)
	SIGNAL_HANDLER
	details += span_notice("You can climb ontop of this.")

/datum/component/climbable/proc/check_climbable(atom/source)
	SIGNAL_HANDLER
	return COMPONENT_MOVABLE_CAN_CLIMB

/atom/proc/can_climb()
	if(SEND_SIGNAL(src, COMSIG_MOVABLE_CHECK_CLIMBABLE) & COMPONENT_MOVABLE_CAN_CLIMB)
		return TRUE
