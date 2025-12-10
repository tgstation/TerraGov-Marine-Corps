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
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/component/climbable/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_MOUSEDROPPED_ONTO,
		COMSIG_ATOM_EXAMINE,
	))
//////////////////////////////////////

///Attempts to climb parent
/datum/component/climbable/proc/attempt_climb(atom/source, mob/user)
	SIGNAL_HANDLER
	if(!isliving(user))
		return
	INVOKE_ASYNC(src, PROC_REF(do_climb), user)

/datum/component/climbable/proc/do_climb(mob/living/user)
	if(user.do_actions || !can_climb(user))
		return

	user.visible_message(span_warning("[user] starts [am_parent.atom_flags & ON_BORDER ? "leaping over" : "climbing onto"] \the [am_parent]!"))

	ADD_TRAIT(user, TRAIT_IS_CLIMBING, REF(am_parent))
	if(!do_after(user, climb_delay, IGNORE_HELD_ITEM, am_parent, BUSY_ICON_GENERIC))
		REMOVE_TRAIT(user, TRAIT_IS_CLIMBING, REF(am_parent))
		return
	REMOVE_TRAIT(user, TRAIT_IS_CLIMBING, REF(am_parent))

	var/turf/destination_turf = can_climb(user)
	if(!istype(destination_turf))
		return

	for(var/buckled in user.buckled_mobs)
		user.unbuckle_mob(buckled)

	user.forceMove(destination_turf)
	user.visible_message(span_warning("[user] [am_parent.atom_flags & ON_BORDER ? "leaps over" : "climbs onto"] \the [am_parent]!"))



///Attempts to climb onto, or past an object

///Checks to see if a mob can climb onto, or over this object
/datum/component/climbable/proc/can_climb(mob/living/user)
	if(!am_parent.can_interact(user)) //this is cursed because it requires dexterity
		return

	var/turf/destination_turf = am_parent.loc
	var/turf/user_turf = get_turf(user)
	if(!istype(destination_turf) || !istype(user_turf))
		return
	if(!user.Adjacent(am_parent))
		return

	if((am_parent.atom_flags & ON_BORDER))
		if(user_turf != destination_turf && user_turf != get_step(destination_turf, am_parent.dir))
			to_chat(user, span_warning("You need to be up against [am_parent] to leap over."))
			return
		if(user_turf == destination_turf)
			destination_turf = get_step(destination_turf, am_parent.dir) //we're moving from the objects turf to the one its facing

	if(destination_turf.density)
		return

	for(var/obj/object in destination_turf.contents)
		if(isstructure(object))
			var/obj/structure/structure = object
			if(structure.allow_pass_flags & PASS_WALKOVER)
				continue
		if(object.density && (!(object.atom_flags & ON_BORDER) || object.dir & get_dir(am_parent, user)))
			to_chat(user, span_warning("There's \a [object.name] in the way."))
			return

	for(var/obj/object in user_turf.contents)
		if(isstructure(object))
			var/obj/structure/structure = object
			if(structure.allow_pass_flags & PASS_WALKOVER)
				continue
		if(object.density && (object.atom_flags & ON_BORDER) && object.dir & get_dir(user, am_parent))
			to_chat(user, span_warning("There's \a [object.name] in the way."))
			return

	return destination_turf

///Shows remaining fuel on examine
/datum/component/climbable/proc/on_examine(datum/source, mob/user, list/details)
	SIGNAL_HANDLER
	details += span_notice("Is climbable.")
