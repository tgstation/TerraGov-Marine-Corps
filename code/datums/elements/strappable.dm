/datum/element/strappable/Attach(datum/target)
	. = ..()
	if(!isitem(target))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_CLICK_ALT, PROC_REF(on_alt_click))
	ADD_TRAIT(target, TRAIT_STRAPPABLE, STRAPPABLE_ITEM_TRAIT)

/datum/element/strappable/Detach(datum/source, ...)
	. = ..()
	UnregisterSignal(source, COMSIG_CLICK_ALT)
	REMOVE_TRAIT(source, TRAIT_STRAPPABLE, STRAPPABLE_ITEM_TRAIT)

/datum/element/strappable/proc/on_alt_click(datum/source, mob/user)
	SIGNAL_HANDLER
	var/obj/item/item_source = source
	if(!item_source.can_interact(user) || !ishuman(user) || !(user.l_hand == source || user.r_hand == source))
		return
	TOGGLE_BITFIELD(item_source.flags_item, NODROP)
	item_source.balloon_alert(user, "[CHECK_BITFIELD(item_source.flags_item, NODROP) ? "Tightened" : "Loosened"] strap.")
