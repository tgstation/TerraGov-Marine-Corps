/datum/component/climbable
	dupe_mode = COMPONENT_DUPE_UNIQUE
	///Typecast parent
	var/atom/movable/am_parent
	///The thing we actually check to climb, usually parent
	var/atom/movable/climb_target //this is needed solely due to vehicle hitboxes, god I hate them
	///How long it takes to climb parent
	var/climb_delay

/datum/component/climbable/Initialize(_climb_delay = 1 SECONDS)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE
	am_parent = parent
	climb_target = am_parent.get_climb_target()
	climb_delay = _climb_delay


/datum/component/climbable/Destroy(force, silent)
	am_parent = null
	return ..()

/datum/component/climbable/RegisterWithParent()
	RegisterSignals(parent, list(COMSIG_CLICK_CTRL, COMSIG_ATOM_TRY_CLIMBABLE), PROC_REF(try_climb))
	RegisterSignal(parent, COMSIG_MOUSEDROPPED_ONTO, PROC_REF(on_mousedrop))
	RegisterSignal(parent, COMSIG_ATOM_CHECK_CLIMBABLE, PROC_REF(check_climbable))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/component/climbable/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_MOUSEDROPPED_ONTO,
		COMSIG_CLICK_CTRL,
		COMSIG_ATOM_CHECK_CLIMBABLE,
		COMSIG_ATOM_TRY_CLIMBABLE,
		COMSIG_ATOM_EXAMINE,
	))

///Tries to climb parent, used via parent proc call or ctrl click
/datum/component/climbable/proc/try_climb(datum/source, mob/user)
	SIGNAL_HANDLER
	var/climb_turf = find_climb_turf(user)
	if(!climb_turf)
		return
	INVOKE_ASYNC(src, PROC_REF(do_climb), user, climb_turf)

///Handles climbing on click drag
/datum/component/climbable/proc/on_mousedrop(datum/source, atom/dropping, mob/user, params)
	SIGNAL_HANDLER
	if(!isliving(user))
		return
	if(dropping != user) //todo: helping someone else climb something would actually be cool
		return
	var/turf/click_turf
	if(params)
		var/list/modifiers = params2list(params)
		click_turf = params2turf(modifiers["screen-loc"], get_turf(user.client.eye), user.client)
	if(!click_turf || !(click_turf in climb_target.locs) || !user.Adjacent(click_turf))
		click_turf = find_climb_turf(user)

	INVOKE_ASYNC(src, PROC_REF(do_climb), user, click_turf)

///Performs the climb, if able
/datum/component/climbable/proc/do_climb(mob/living/user, turf/destination_turf)
	if(user.do_actions || !can_climb(user, destination_turf, climb_target))
		return

	user.visible_message(span_warning("[user] starts [climb_target.atom_flags & ON_BORDER ? "leaping over" : "climbing onto"] \the [am_parent]!"))

	ADD_TRAIT(user, TRAIT_IS_CLIMBING, REF(climb_target))
	if(!do_after(user, climb_delay, IGNORE_HELD_ITEM, am_parent, BUSY_ICON_GENERIC))
		REMOVE_TRAIT(user, TRAIT_IS_CLIMBING, REF(climb_target))
		return
	REMOVE_TRAIT(user, TRAIT_IS_CLIMBING, REF(climb_target))
	if(!can_climb(user, destination_turf, climb_target))
		return

	for(var/buckled in user.buckled_mobs)
		user.unbuckle_mob(buckled)

	user.forceMove(destination_turf)
	user.visible_message(span_warning("[user] [climb_target.atom_flags & ON_BORDER ? "leaps over" : "climbs onto"] \the [am_parent]!"))

///Checks to see if a mob can climb onto, or over this object
/datum/component/climbable/proc/can_climb(mob/living/user, turf/destination_turf)
	if(!climb_target.can_interact(user)) //todo: out of current scope but can_interact is cursed for this usage as it checks dexterity
		return

	var/turf/user_turf = get_turf(user)
	if(!istype(destination_turf) || !istype(user_turf))
		return
	if(!user.Adjacent(destination_turf))
		return

	if((climb_target.atom_flags & ON_BORDER))
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
		if(AM == climb_target)
			continue
		if(isstructure(AM))
			var/obj/structure/structure = AM
			if(structure.allow_pass_flags & PASS_WALKOVER)
				continue
		if(AM.density && (!(AM.atom_flags & ON_BORDER) || AM.dir & get_dir(destination_turf, user)))
			to_chat(user, span_warning("There's \a [AM.name] in the way."))
			return

	for(var/atom/movable/AM AS in user_turf.contents)
		if(isstructure(AM))
			var/obj/structure/structure = AM
			if(structure.allow_pass_flags & PASS_WALKOVER)
				continue
		if(AM.density && (AM.atom_flags & ON_BORDER) && AM.dir & get_dir(user, destination_turf))
			to_chat(user, span_warning("There's \a [AM.name] in the way."))
			return

	return destination_turf

///Tries to find the most appropriate turf to climb onto, mostly relevant for multitile atoms
/datum/component/climbable/proc/find_climb_turf(mob/user)
	if(!climb_target.loc)
		return
	if(length(climb_target.locs) == 1)
		return climb_target.loc

	var/climb_turf
	//we try the most logical turf first since the fixed order of locs may give undesirable results otherwise
	var/facing_turf = get_step_towards(user, am_parent)
	if((facing_turf in climb_target.locs) && user.Adjacent(facing_turf))
		climb_turf = facing_turf
	else
		for(var/turf/candi AS in climb_target.locs)
			if(candi == facing_turf)
				continue
			if(!user.Adjacent(candi))
				continue
			climb_turf = candi
			break
	return climb_turf

///Adds to the parent's examine text
/datum/component/climbable/proc/on_examine(datum/source, mob/user, list/details)
	SIGNAL_HANDLER
	details += span_notice("You can climb ontop of this.")

//The procs below allow us to utilise the component outside normal scenarios, such as NPC usage

///Checks if user can climb parent
/datum/component/climbable/proc/check_climbable(atom/source, mob/user)
	SIGNAL_HANDLER
	if(!can_climb(user, find_climb_turf(user)))
		return
	return COMPONENT_MOVABLE_CAN_CLIMB

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

///Returns the thing to climb, normally src
/atom/proc/get_climb_target()
	return src

/obj/vehicle/get_climb_target()
	//this horrible proc only exists because of stinky multitile vehicles and hitboxes
	if(hitbox)
		return hitbox
	return src

