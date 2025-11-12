/datum/element/strappable/Attach(datum/target)
	. = ..()
	if(!isitem(target))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_CLICK_ALT, PROC_REF(toggle_strap))
	RegisterSignal(target, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
	RegisterSignal(target, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))
	RegisterSignals(target, list(COMSIG_AI_EQUIPPED_GUN, COMSIG_AI_EQUIPPED_MELEE), PROC_REF(ai_try_strap))
	ADD_TRAIT(target, TRAIT_STRAPPABLE, STRAPPABLE_ITEM_TRAIT)

/datum/element/strappable/Detach(datum/source, ...)
	. = ..()
	UnregisterSignal(source, list(COMSIG_CLICK_ALT, COMSIG_ITEM_UNEQUIPPED, COMSIG_AI_EQUIPPED_GUN))
	REMOVE_TRAIT(source, TRAIT_STRAPPABLE, STRAPPABLE_ITEM_TRAIT)

///Toggles strap state
/datum/element/strappable/proc/toggle_strap(datum/source, mob/user)
	SIGNAL_HANDLER
	var/obj/item/item_source = source
	if(!item_source.can_interact(user) \
		|| !ishuman(user) \
		|| !(user.l_hand == source || user.r_hand == source))
		return
	var/strapped = HAS_TRAIT_FROM(item_source, TRAIT_NODROP, STRAPPABLE_ITEM_TRAIT)
	if(!strapped)
		RegisterSignal(item_source, COMSIG_ITEM_UNEQUIPPED, PROC_REF(on_unequip))
		ADD_TRAIT(item_source, TRAIT_NODROP, STRAPPABLE_ITEM_TRAIT)
		item_source.balloon_alert(user, "tightened strap")
	else
		UnregisterSignal(item_source, COMSIG_ITEM_UNEQUIPPED)
		REMOVE_TRAIT(item_source, TRAIT_NODROP, STRAPPABLE_ITEM_TRAIT)
		item_source.balloon_alert(user, "loosened strap")

///Unstraps if the target is somehow forcefully unequipped
/datum/element/strappable/proc/on_unequip(obj/item/item_source, mob/unequipper, slot)
	SIGNAL_HANDLER
	UnregisterSignal(item_source, COMSIG_ITEM_UNEQUIPPED)
	REMOVE_TRAIT(item_source, TRAIT_NODROP, STRAPPABLE_ITEM_TRAIT)

///AI tries to toggle the strap
/datum/element/strappable/proc/ai_try_strap(datum/source, mob/user, unequip = FALSE)
	SIGNAL_HANDLER
	if(HAS_TRAIT_FROM(source, TRAIT_NODROP, STRAPPABLE_ITEM_TRAIT))
		if(!unequip)
			return
	else if(unequip)
		return
	toggle_strap(source, user)

///Called on picking up attached item
/datum/element/strappable/proc/on_equip(obj/item/item_source)
	SIGNAL_HANDLER
	UnregisterSignal(item_source.loc, COMSIG_ITEM_TOGGLE_STRAP)
	RegisterSignal(item_source.loc, COMSIG_ITEM_TOGGLE_STRAP, PROC_REF(toggle_held_strap))

///Called on dropping attached item
/datum/element/strappable/proc/on_drop(obj/item/item_source)
	SIGNAL_HANDLER
	UnregisterSignal(item_source.loc, COMSIG_ITEM_TOGGLE_STRAP)

///Called when keybind is received, calls toggle_strap() only when held item has TRAIT_STRAPPABLE
/datum/element/strappable/proc/toggle_held_strap(mob/user)
	SIGNAL_HANDLER
	var/obj/item_source = user.get_active_held_item()
	if(!HAS_TRAIT(item_source, TRAIT_STRAPPABLE))
		return
	toggle_strap(item_source, user)
