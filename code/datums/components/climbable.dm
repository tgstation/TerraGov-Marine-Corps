/datum/component/climbable
	dupe_mode = COMPONENT_DUPE_UNIQUE
	///Typecast parent
	var/atom/movable/am_parent
	///The thing we actually check to climb, usually parent
	var/atom/movable/climb_target //this is needed solely due to vehicle hitboxes, god I hate them
	///How long it takes to climb parent
	var/climb_delay

/datum/component/climbable/Initialize(_climb_delay = 1 SECONDS)
	if(!ismovable(parent) || _climb_delay <= 0)
		return COMPONENT_INCOMPATIBLE
	am_parent = parent
	climb_target = am_parent.get_climb_target()
	climb_delay = _climb_delay


/datum/component/climbable/Destroy(force, silent)
	am_parent = null
	climb_target = null
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
	if(!isliving(dropping))
		return
	if(!isliving(user))
		return
	var/helper
	if(dropping != user)
		var/mob/living/living_dropping = dropping
		if(user.mob_size < living_dropping.mob_size)
			return
		helper = user
	var/turf/click_turf = find_climb_turf(user, params)
	if(!click_turf) //how did you do this?
		return

	INVOKE_ASYNC(src, PROC_REF(do_climb), dropping, click_turf, helper)

///Performs the climb, if able
///helper is the one triggering the climb, if the climber is not doing it themselves
/datum/component/climbable/proc/do_climb(mob/living/climber, turf/destination_turf, mob/living/helper)
	if(climber.do_actions || helper?.do_actions || !can_climb(climber, destination_turf, helper))
		return

	if(helper)
		climber.visible_message(span_warning("[helper] starts helping [climber] [climb_target.atom_flags & ON_BORDER ? "climb over" : "climb onto"] \the [am_parent]!"))
	else
		climber.visible_message(span_warning("[climber] starts [climb_target.atom_flags & ON_BORDER ? "leaping over" : "climbing onto"] \the [am_parent]!"))

	ADD_TRAIT(climber, TRAIT_IS_CLIMBING, REF(climb_target))
	if(helper)
		var/climber_turf = get_turf(climber)
		//help your buddies over faster than climbing yourself
		if(!do_after(helper, climb_delay * 0.5, IGNORE_HELD_ITEM, am_parent, BUSY_ICON_GENERIC, extra_checks = CALLBACK(src, PROC_REF(climber_can_climb), climber, climber_turf)))
			REMOVE_TRAIT(climber, TRAIT_IS_CLIMBING, REF(climb_target))
			return
	else if(!do_after(climber, climb_delay, IGNORE_HELD_ITEM, am_parent, BUSY_ICON_GENERIC))
		REMOVE_TRAIT(climber, TRAIT_IS_CLIMBING, REF(climb_target))
		return
	REMOVE_TRAIT(climber, TRAIT_IS_CLIMBING, REF(climb_target))
	if(!can_climb(climber, destination_turf, helper))
		return

	for(var/buckled in climber.buckled_mobs)
		climber.unbuckle_mob(buckled)

	climber.forceMove(destination_turf)

	if(helper)
		climber.visible_message(span_warning("[helper] helps [climber] [climb_target.atom_flags & ON_BORDER ? "over" : "onto"] \the [am_parent]!"))
	else
		climber.visible_message(span_warning("[climber] [climb_target.atom_flags & ON_BORDER ? "leaps over" : "climbs onto"] \the [am_parent]!"))

///Checks if the climber has moved during the do_after
/datum/component/climbable/proc/climber_can_climb(mob/living/climber, turf/climber_turf)
	if(climber.loc != climber_turf)
		return FALSE
	if(climber.do_actions)
		return FALSE
	return TRUE

///Checks to see if a mob can climb onto, or over this object, or can be helped onto it by someone else
/datum/component/climbable/proc/can_climb(mob/living/climber, turf/destination_turf, mob/living/helper)
	if(!helper)
		helper = climber

	if(!climb_target.can_interact(helper)) //todo: out of current scope but can_interact is cursed for this usage as it checks dexterity
		return

	var/turf/origin_turf = get_turf(helper)
	if(!istype(destination_turf) || !istype(origin_turf))
		return
	if(destination_turf.density)
		return
	if(!helper.Adjacent(destination_turf))
		return

	if((climb_target.atom_flags & ON_BORDER))
		//for border objects specifically we need to either be on its turf, or the turf in front of it, depending which way we're going
		var/valid_climb_turf = (destination_turf == am_parent.loc) ? get_step(am_parent, am_parent.dir) : am_parent.loc
		if(helper.loc != valid_climb_turf)
			to_chat(helper, span_warning("You need to be up against [am_parent] to leap over."))
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
		if(AM.density && (!(AM.atom_flags & ON_BORDER) || AM.dir & get_dir(destination_turf, climber)))
			to_chat(helper, span_warning("There's \a [AM.name] in the way."))
			return

	for(var/atom/movable/AM AS in origin_turf.contents)
		if(isstructure(AM))
			var/obj/structure/structure = AM
			if(structure.allow_pass_flags & PASS_WALKOVER)
				continue
		if(AM.density && (AM.atom_flags & ON_BORDER) && AM.dir & get_dir(climber, destination_turf))
			to_chat(helper, span_warning("There's \a [AM.name] in the way."))
			return

	return destination_turf

///Tries to find the most appropriate turf to climb onto, mostly relevant for multitile atoms
/datum/component/climbable/proc/find_climb_turf(mob/user, params)
	if(!climb_target.loc)
		return

	//We assume there are no cursed multitile border objects for this
	if((climb_target.atom_flags & ON_BORDER) && (user.loc == climb_target.loc))
		return get_step(climb_target, climb_target.dir)

	if(length(climb_target.locs) == 1)
		return climb_target.loc

	//For multitile objects, we allow the player to specify what turf they want to climb onto, provided it's in reach
	if(params)
		var/list/modifiers = params2list(params)
		var/param_turf = params2turf(modifiers["screen-loc"], get_turf(user.client.eye), user.client)
		if(param_turf && user.Adjacent(param_turf))
			return param_turf

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

