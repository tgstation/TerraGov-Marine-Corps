/datum/component/climbable
	dupe_mode = COMPONENT_DUPE_UNIQUE
	///Typecast parent
	var/atom/movable/am_parent
	///How long it takes to climb parent
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
	RegisterSignal(parent, COMSIG_MOUSEDROPPED_ONTO, PROC_REF(on_mousedrop))
	RegisterSignal(parent, COMSIG_ATOM_CHECK_CLIMBABLE, PROC_REF(check_climbable))
	RegisterSignal(parent, COMSIG_ATOM_TRY_CLIMBABLE, PROC_REF(try_climb))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/component/climbable/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_MOUSEDROPPED_ONTO,
		COMSIG_ATOM_CHECK_CLIMBABLE,
		COMSIG_ATOM_TRY_CLIMBABLE,
		COMSIG_ATOM_EXAMINE,
	))

///Handles climbing on click drag
/datum/component/climbable/proc/on_mousedrop(datum/source, atom/dropping, mob/user, params)
	SIGNAL_HANDLER
	if(!isliving(user))
		return
	if(dropping != user) //todo: helping someone else climb something would actually be cool
		return
	var/turf/click_turf
	if(!params)
		click_turf = get_turf(am_parent)
	else
		var/list/modifiers = params2list(params)
		if(!user.client)
			click_turf = params2turf(modifiers["screen-loc"], get_turf(user), null)
		else
			click_turf = params2turf(modifiers["screen-loc"], get_turf(user.client.eye), user.client)
	INVOKE_ASYNC(src, PROC_REF(do_climb), user, click_turf)

///Performs the climb, if able
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
	if(!am_parent.can_interact(user)) //todo: out of current scope but can_interact is cursed for this usage as it checks dexterity
		return

	var/turf/destination_turf = clicked_turf ? clicked_turf : am_parent.loc
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

///Tries to climb parent, used via parent proc calls instead of directly in the component
/datum/component/climbable/proc/try_climb(datum/source, mob/user)
	SIGNAL_HANDLER
	if(am_parent.bound_width <= 32 && am_parent.bound_height <= 32)
		INVOKE_ASYNC(src, PROC_REF(do_climb), user)
		return

	var/turf/climb_turf
	var/turf/facing_turf = get_step(user, am_parent) //we try the most logical turf first since the fixed order of locs will give undesirably results otherwise
	if((facing_turf in am_parent.locs) && user.Adjacent(facing_turf))
		climb_turf = facing_turf
	else
		for(var/turf/candi AS in am_parent.locs)
			if(candi == facing_turf)
				continue
			if(!user.Adjacent(candi))
				continue
			climb_turf = candi
			break
	INVOKE_ASYNC(src, PROC_REF(do_climb), user, climb_turf)

///Checks if user can climb parent
/datum/component/climbable/proc/check_climbable(atom/source, mob/user)
	SIGNAL_HANDLER
	if(!can_climb(user))
		return
	return COMPONENT_MOVABLE_CAN_CLIMB

///Adds to the parent's examine text
/datum/component/climbable/proc/on_examine(datum/source, mob/user, list/details)
	SIGNAL_HANDLER
	details += span_notice("You can climb ontop of this.")


//The two procs below allow us to utilise the component outside normal scenarios, such as NPC usage

///Returns true if user can climb src
/atom/proc/check_climb(mob/user)
	if(!isliving(user))
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_ATOM_CHECK_CLIMBABLE, user) & COMPONENT_MOVABLE_CAN_CLIMB)
		return TRUE

///Tries to climb src, if the component is attached
/atom/proc/try_climb(mob/user)
	if(!check_climb(user))
		return
	SEND_SIGNAL(src, COMSIG_ATOM_TRY_CLIMBABLE, user)
	return TRUE
