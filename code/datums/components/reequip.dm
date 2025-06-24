///Component to automatically attempt to equip an item to a list of slots after it is dropped by a human
/datum/component/reequip
	//If multiple attempt to reattach, all after the first success will naturally fail so dupes are fine
	dupe_mode = COMPONENT_DUPE_ALLOWED

	///list of SLOT_* defines for equip_in_one_of_slots
	var/list/slots_to_try
	///Ticks between the object being dropped and reequipped
	var/reequip_delay = 0.3 SECONDS
	/// Are we currently trying to catch the dropped parent?
	var/active = TRUE

/datum/component/reequip/Initialize(slots, _reequip_delay, ...)
	if(!slots)
		return COMPONENT_INCOMPATIBLE
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	if(!islist(slots))
		slots = list(slots)
	slots_to_try = slots
	if(_reequip_delay)
		reequip_delay = _reequip_delay
	RegisterSignal(parent, COMSIG_ITEM_REMOVED_INVENTORY, PROC_REF(begin_reequip))
	RegisterSignal(parent, COMSIG_MOVABLE_PRE_THROW, PROC_REF(cancel_throw))

///Blocks any item with this component from being thrown
/datum/component/reequip/proc/cancel_throw(source)
	SIGNAL_HANDLER
	if(!active)
		return
	return COMPONENT_MOVABLE_BLOCK_PRE_THROW

///Just holds a delay for the reequip attempt
/datum/component/reequip/proc/begin_reequip(source, mob/user)
	SIGNAL_HANDLER
	if(!active)
		return
	addtimer(CALLBACK(src, PROC_REF(catch_wrapper), source, user), reequip_delay)

///Wrapper to ensure signals only come from One Spot
/datum/component/reequip/proc/catch_wrapper(source, mob/user)
	if(try_to_catch(parent, user))
		return
	SEND_SIGNAL(src, COMSIG_REEQUIP_FAILURE, parent, user)

///Actually equips parent if any slots in slots_to_try are available
/datum/component/reequip/proc/try_to_catch(source, mob/user)
	if(!ishuman(user) || !isitem(source))
		return
	var/obj/item/item_source = source
	if(!isturf(item_source.loc))
		return //In storage or somewhere else we shouldn't pull it from
	var/mob/living/carbon/human/h_user = user
	return h_user.equip_in_one_of_slots(parent, slots_to_try, FALSE)
