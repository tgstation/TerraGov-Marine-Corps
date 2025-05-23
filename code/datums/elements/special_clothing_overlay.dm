/**
 * # Special_clothing_overlay element
 *
 * Handles special clothing overlays for humans that cannot use the standing overlays system
 * Example uses include the use of emissives and similar
 *
 * primarily functions through child overrides to specify what should be applied when,
 * see the Attach and [/datum/element/special_clothing_overlay/proc/get_overlay_icon()] (get_overlay_icon)
 * procs for details
 */
/datum/element/special_clothing_overlay
	argument_hash_start_idx = 2
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH_ON_HOST_DESTROY
	///The image/icon/mutable_appearance we arre going to be applying to here
	var/overlay_to_apply
	///when this layer is updated on the wearer, overlay_to_apply will be applied/removed with it
	var/target_layer

//override the args for this to create the desired overlay
/datum/element/special_clothing_overlay/Attach(datum/target, applytarget)
	. = ..()
	if(!isclothing(target)|| !applytarget)
		return ELEMENT_INCOMPATIBLE
	if(!overlay_to_apply)
		target_layer = applytarget
		overlay_to_apply = get_overlay_icon(target)
		if(!overlay_to_apply)
			return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_ITEM_EQUIPPED_TO_SLOT, PROC_REF(equipped))

/datum/element/special_clothing_overlay/Detach(datum/source, force)
	. = ..()
	UnregisterSignal(source, COMSIG_ITEM_EQUIPPED_TO_SLOT)

/**
 * Fetches the special overlay we are going to be applying
 */
/datum/element/special_clothing_overlay/proc/get_overlay_icon(obj/item/clothing/target)
	CRASH("UNIMPLEMENTED OVERLAY GOTTEN")

/**
 * Called on owner equip, sets it up to update the wearers icon
 */
/datum/element/special_clothing_overlay/proc/equipped(obj/item/source, mob/equipper, slot)
	SIGNAL_HANDLER
	RegisterSignal(equipper, COMSIG_HUMAN_APPLY_OVERLAY, PROC_REF(add_as_overlay))
	RegisterSignal(equipper, COMSIG_HUMAN_REMOVE_OVERLAY, PROC_REF(remove_as_overlay))
	RegisterSignals(source, list(COMSIG_ITEM_EQUIPPED_NOT_IN_SLOT, COMSIG_ITEM_DROPPED), PROC_REF(dropped))

/**
 * Signal handler for adding the overlay to the wearer
 */
/datum/element/special_clothing_overlay/proc/add_as_overlay(mob/source, cache_index, list/overlays)
	SIGNAL_HANDLER
	if(cache_index == target_layer)
		overlays += overlay_to_apply

/**
 * Signal handler for removing the overlay from the  wearer
 */
/datum/element/special_clothing_overlay/proc/remove_as_overlay(mob/source, cache_index, list/overlays)
	SIGNAL_HANDLER
	if(cache_index == target_layer)
		overlays += overlay_to_apply

/**
 * Signal handler for when the owner is taken off
 */
/datum/element/special_clothing_overlay/proc/dropped(datum/source, mob/equipper)
	SIGNAL_HANDLER
	UnregisterSignal(source, list(COMSIG_ITEM_EQUIPPED_NOT_IN_SLOT, COMSIG_ITEM_DROPPED))
	UnregisterSignal(equipper, list(COMSIG_HUMAN_APPLY_OVERLAY, COMSIG_HUMAN_REMOVE_OVERLAY))

/**
 * Adds an emissive greyscale overlay to the wearer as the helmets visor
 */
/datum/element/special_clothing_overlay/modular_helmet_visor
	///greyscale icon we fetch to make worn icon with
	var/icon/special_icon
	///Icon_state to use for the emissive
	var/visor_icon_state

/datum/element/special_clothing_overlay/modular_helmet_visor/Attach(datum/target, applytarget, icon_state, icon)
	if(!special_icon || !visor_icon_state)
		visor_icon_state = icon_state
		special_icon = icon
	return ..()

/datum/element/special_clothing_overlay/modular_helmet_visor/get_overlay_icon(obj/item/clothing/target)
	return emissive_appearance(special_icon, visor_icon_state, target)
