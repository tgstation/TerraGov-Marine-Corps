/datum/element/strappable/Attach(datum/target)
	. = ..()
	if(!isitem(target))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_CLICK_ALT, PROC_REF(on_alt_click))
	ADD_TRAIT(target, TRAIT_STRAPPABLE, STRAPPABLE_ITEM_TRAIT)

/datum/element/strappable/Detach(datum/source, ...)
	. = ..()
	UnregisterSignal(source, list(COMSIG_CLICK_ALT, COMSIG_ITEM_UNEQUIPPED))
	REMOVE_TRAIT(source, TRAIT_STRAPPABLE, STRAPPABLE_ITEM_TRAIT)

///Toggles strap state
/datum/element/strappable/proc/on_alt_click(datum/source, mob/user)
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
		item_source.balloon_alert(user, "Tightened strap")
	else
		UnregisterSignal(item_source, COMSIG_ITEM_UNEQUIPPED)
		REMOVE_TRAIT(item_source, TRAIT_NODROP, STRAPPABLE_ITEM_TRAIT)
		item_source.balloon_alert(user, "Loosened strap")

///Unstraps if the target is somehow forcefully unequipped
/datum/element/strappable/proc/on_unequip(obj/item/item_source, mob/unequipper, slot)
	SIGNAL_HANDLER
	UnregisterSignal(item_source, COMSIG_ITEM_UNEQUIPPED)
	REMOVE_TRAIT(item_source, TRAIT_NODROP, STRAPPABLE_ITEM_TRAIT)
