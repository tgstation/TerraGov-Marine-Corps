/// An element to add a FOV trait to the wearer, removing it when an item is unequipped, but only as long as the visor is up.
/datum/component/clothing_fov_visor
	/// What's the FOV angle of the trait we're applying to the wearer
	var/fov_angle
	/// Because of clothing code not being too good, we need keep track whether we are worn.
	var/is_worn = FALSE
	/// The current wearer
	var/mob/living/wearer

/datum/component/clothing_fov_visor/Initialize(fov_angle)
	. = ..()
	if(!isclothing(parent))
		return COMPONENT_INCOMPATIBLE
	src.fov_angle = fov_angle

// fyi does not currently support visor toggling since ours arent standardized
/datum/component/clothing_fov_visor/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))

/datum/component/clothing_fov_visor/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))
	if(wearer)
		wearer.remove_fov_trait(src, fov_angle)
		UnregisterSignal(wearer, COMSIG_QDELETING)
		wearer = null
	return ..()

/// On dropping the item, remove the FoV trait if visor was down.
/datum/component/clothing_fov_visor/proc/on_drop(datum/source, mob/living/dropper)
	SIGNAL_HANDLER
	is_worn = FALSE
	if(wearer) // Prevent any edge cases where on_drop is called with a different dropper to the one who equipped the visor.
		UnregisterSignal(wearer, COMSIG_QDELETING)
		wearer.remove_fov_trait(src, fov_angle)
		wearer = null
	dropper.remove_fov_trait(src, fov_angle)
	dropper.update_fov()

/// On equipping the item, add the FoV trait if visor isn't up.
/datum/component/clothing_fov_visor/proc/on_equip(obj/item/source, mob/living/equipper, slot)
	SIGNAL_HANDLER
	if(!(source.equip_slot_flags & slot)) //If EQUIPPED TO HANDS FOR EXAMPLE
		return
	is_worn = TRUE
	if(wearer && wearer != equipper)
		UnregisterSignal(wearer, COMSIG_QDELETING)
		wearer.remove_fov_trait(src, fov_angle)
	wearer = equipper
	RegisterSignal(wearer, COMSIG_QDELETING, PROC_REF(on_wearer_deleted))
	equipper.add_fov_trait(src, fov_angle)
	equipper.update_fov()

/datum/component/clothing_fov_visor/proc/on_wearer_deleted(datum/source)
	SIGNAL_HANDLER
	wearer.remove_fov_trait(src, fov_angle)
	wearer = null

