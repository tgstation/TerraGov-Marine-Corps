/// Slippery component, for making anything slippery. Of course.
/datum/component/slippery
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// How long the slip keeps you stunned.
	var/stun_time = 0
	/// How long we're knocked down/paralyzed for
	var/paralyze_time = 0
	/// Does this care if we're running or not?
	var/run_only = FALSE
	/// Does this override noslip shoes?
	var/override_noslip = FALSE
	/// How many steps we slide upon slip
	var/slide_steps = 0
	/// A proc callback to call on slip.
	var/datum/callback/callback
	/// If parent is an item, this is the person currently holding/wearing the parent (or the parent if no one is holding it)
	var/mob/living/holder
	/// Whitelist of item slots the parent can be equipped in that make the holder slippery. If null or empty, it will always make the holder slippery.
	var/list/slot_whitelist = list(ITEM_SLOT_OCLOTHING, ITEM_SLOT_ICLOTHING, ITEM_SLOT_GLOVES, ITEM_SLOT_FEET, ITEM_SLOT_HEAD, ITEM_SLOT_MASK, ITEM_SLOT_BELT)
	/// What we give to connect_loc by default, makes slippable mobs moving over us slip
	var/static/list/default_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(Slip),
	)

	/// What we give to connect_loc if we're an item and get equipped by a mob. makes slippable mobs moving over our holder slip
	var/static/list/holder_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(Slip_on_wearer),
	)

	/// The connect_loc_behalf component for the holder_connections list.
	var/datum/weakref/holder_connect_loc_behalf

/datum/component/slippery/Initialize(stun_time, paralyze_time, datum/callback/callback, run_only, override_noslip, slide_steps, slot_whitelist)
	src.stun_time = max(stun_time, 0)
	src.paralyze_time = max(paralyze_time, 0)
	src.callback = callback
	src.run_only = run_only
	src.override_noslip = override_noslip
	src.slide_steps = slide_steps
	if(slot_whitelist)
		src.slot_whitelist = slot_whitelist

	add_connect_loc_behalf_to_parent()
	if(ismovable(parent))
		if(isitem(parent))
			RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
			RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))
	else
		RegisterSignal(parent, COMSIG_ATOM_ENTERED, PROC_REF(Slip))

/datum/component/slippery/proc/add_connect_loc_behalf_to_parent()
	if(ismovable(parent))
		AddComponent(/datum/component/connect_loc_behalf, parent, default_connections)

/datum/component/slippery/InheritComponent(datum/component/slippery/component, i_am_original, stun_time, paralyze_time, datum/callback/callback, run_only, override_noslip, slide_steps, slot_whitelist)
	if(component)
		stun_time = component.stun_time
		paralyze_time = component.paralyze_time
		callback = component.callback
		run_only = component.run_only
		override_noslip = component.override_noslip
		slide_steps = component.slide_steps
		slot_whitelist = component.slot_whitelist

	src.stun_time = max(stun_time, 0)
	src.paralyze_time = max(paralyze_time, 0)
	src.callback = callback
	src.run_only = run_only
	src.override_noslip = override_noslip
	src.slide_steps = slide_steps
	if(slot_whitelist)
		src.slot_whitelist = slot_whitelist
/*
 * The proc that does the sliping. Invokes the slip callback we have set.
 *
 * source - the source of the signal
 * AM - the atom/movable that is being slipped.
 */
/datum/component/slippery/proc/Slip(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER
	if(!isliving(arrived) || !isatom(parent))
		return
	var/mob/living/victim = arrived
	var/atom/parent_source = parent
	if(!(victim.pass_flags & HOVERING) && parent_source.can_slip() && victim.slip(parent, stun_time, paralyze_time, run_only, override_noslip, slide_steps) && callback)
		callback.Invoke(victim)

/*
 * Gets called when COMSIG_ITEM_EQUIPPED is sent to parent.
 * This proc register slip signals to the equipper.
 * If we have a slot whitelist, we only register the signals if the slot is valid (ex: clown PDA only slips in ID or belt slot).
 *
 * source - the source of the signal
 * equipper - the mob we're equipping the slippery thing to
 * slot - the slot we're equipping the slippery thing to on the equipper.
 */
/datum/component/slippery/proc/on_equip(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER

	if((!LAZYLEN(slot_whitelist) || (slot in slot_whitelist)) && isliving(equipper))
		holder = equipper
		qdel(GetComponent(/datum/component/connect_loc_behalf))
		AddComponent(/datum/component/connect_loc_behalf, holder, holder_connections)
		RegisterSignal(holder, COMSIG_QDELETING, PROC_REF(holder_deleted))

/*
 * Detects if the holder mob is deleted.
 * If our holder mob is the holder set in this component, we null it.
 *
 * source - the source of the signal
 * possible_holder - the mob being deleted.
 */
/datum/component/slippery/proc/holder_deleted(datum/source, datum/possible_holder)
	SIGNAL_HANDLER

	if(possible_holder == holder)
		holder = null

/*
 * Gets called when COMSIG_ITEM_DROPPED is sent to parent.
 * Makes our holder mob un-slippery.
 *
 * source - the source of the signal
 * user - the mob that was formerly wearing our slippery item.
 */
/datum/component/slippery/proc/on_drop(datum/source, mob/user)
	SIGNAL_HANDLER

	UnregisterSignal(user, COMSIG_QDELETING)

	qdel(GetComponent(/datum/component/connect_loc_behalf))
	add_connect_loc_behalf_to_parent()

	holder = null

/*
 * The slip proc, but for equipped items.
 * Slips the person who crossed us if we're lying down and unbuckled.
 *
 * source - the source of the signal
 * AM - the atom/movable that slipped on us.
 */
/datum/component/slippery/proc/Slip_on_wearer(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(!holder.lying_angle && !holder.buckled)
		Slip(source, arrived)

/datum/component/slippery/UnregisterFromParent()
	. = ..()
	qdel(GetComponent(/datum/component/connect_loc_behalf))
