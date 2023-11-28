/datum/strippable_item/mob_item_slot/head
	key = STRIPPABLE_ITEM_HEAD
	item_slot = ITEM_SLOT_HEAD

/datum/strippable_item/mob_item_slot/back
	key = STRIPPABLE_ITEM_BACK
	item_slot = ITEM_SLOT_BACK

/datum/strippable_item/mob_item_slot/mask
	key = STRIPPABLE_ITEM_MASK
	item_slot = ITEM_SLOT_MASK

/datum/strippable_item/mob_item_slot/handcuffs
	key = STRIPPABLE_ITEM_HANDCUFFS
	item_slot = ITEM_SLOT_HANDCUFF

/datum/strippable_item/mob_item_slot/handcuffs/should_show(atom/source, mob/user)
	if(!iscarbon(source))
		return FALSE

	var/mob/living/carbon/carbon_source = source
	return !isnull(carbon_source.handcuffed)

// You shouldn't be able to equip things to handcuff slots.
/datum/strippable_item/mob_item_slot/handcuffs/try_equip(atom/source, obj/item/equipping, mob/user)
	return FALSE

/// A strippable item for a hand
/datum/strippable_item/hand
	/// Which hand?
	var/hand_index

/datum/strippable_item/hand/get_item(atom/source)
	if(!ismob(source))
		return null

	var/mob/mob_source = source
	return mob_source.get_item_for_held_index(hand_index)

/datum/strippable_item/hand/try_equip(atom/source, obj/item/equipping, mob/user)
	. = ..()
	if(!.)
		return FALSE

	if(!ismob(source))
		return FALSE

	var/mob/mob_source = source

	if(!mob_source.can_put_in_hand(equipping, hand_index))
		to_chat(src, "<span class='warning'>\The [equipping] doesn't fit in that place!</span>")
		return FALSE

	return TRUE

/datum/strippable_item/hand/start_equip(atom/source, obj/item/equipping, mob/user)
	. = ..()
	if(!.)
		return

	if(!ismob(source))
		return FALSE

	var/mob/mob_source = source

	if(!do_after(user, equipping.equip_delay_other, NONE, source, BUSY_ICON_FRIENDLY))
		return FALSE

	if(!mob_source.can_put_in_hand(equipping, hand_index))
		return FALSE

	if(!user.temporarilyRemoveItemFromInventory(equipping))
		return FALSE

	return TRUE

/datum/strippable_item/hand/finish_equip(atom/source, obj/item/equipping, mob/user)
	if(!iscarbon(source))
		return FALSE

	var/mob/mob_source = source
	mob_source.put_in_hand(equipping, hand_index)

/datum/strippable_item/hand/start_unequip(atom/source, mob/user)
	. = ..()
	if(!.)
		return

	return start_unequip_mob(get_item(source), source, user)

/datum/strippable_item/hand/finish_unequip(atom/source, mob/user)
	var/obj/item/item = get_item(source)
	if(isnull(item))
		return FALSE

	if(!ismob(source))
		return FALSE

	return finish_unequip_mob(item, source, user)



/datum/strippable_item/hand/left
	key = STRIPPABLE_ITEM_LHAND
	hand_index = 1

/datum/strippable_item/hand/left/get_alternate_action(atom/source, mob/user)
	return get_strippable_alternate_action_strap(get_item(source), source)

/datum/strippable_item/hand/left/alternate_action(atom/source, mob/user)
	return strippable_alternate_action_strap(get_item(source), source, user)

/datum/strippable_item/hand/right
	key = STRIPPABLE_ITEM_RHAND
	hand_index = 2

/datum/strippable_item/hand/right/get_alternate_action(atom/source, mob/user)
	return get_strippable_alternate_action_strap(get_item(source), source)

/datum/strippable_item/hand/right/alternate_action(atom/source, mob/user)
	return strippable_alternate_action_strap(get_item(source), source, user)

/// Getter proc for the alternate action for removing nodrop traits from items with straps
/datum/strippable_item/proc/get_strippable_alternate_action_strap(obj/item/item, atom/source)
	if(HAS_TRAIT_FROM(item, TRAIT_NODROP, STRAPPABLE_ITEM_TRAIT))
		return "loosen_strap"
	else
		return "tighten_strap"

/// The proc that actually does the alternate action
/datum/strippable_item/proc/strippable_alternate_action_strap(obj/item/item, atom/source, mob/user)
	if(!HAS_TRAIT(item, TRAIT_STRAPPABLE))
		return

	var/strapped = HAS_TRAIT_FROM(item, TRAIT_NODROP, STRAPPABLE_ITEM_TRAIT)
	user.balloon_alert_to_viewers("[strapped ? "Loosening" : "Tightening"] strap...")

	if(!do_after(user, 3 SECONDS, NONE, source, BUSY_ICON_FRIENDLY))
		return

	if(!strapped)
		ADD_TRAIT(item, TRAIT_NODROP, STRAPPABLE_ITEM_TRAIT)
		user.balloon_alert_to_viewers("Tightened strap")
	else
		REMOVE_TRAIT(item, TRAIT_NODROP, STRAPPABLE_ITEM_TRAIT)
		user.balloon_alert_to_viewers("Loosened strap")
