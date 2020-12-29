/datum/component/powerloader_connected
	var/obj/vehicle/powerloader/linked_powerloader

/datum/component/powerloader_connected/Initialize(powerloader)
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	linked_powerloader = powerloader
	var/obj/item/parent_item = parent
	parent_item.flags_item |= ITEM_ABSTRACT
	RegisterSignal(parent_item, COMSIG_ITEM_DROPPED, .proc/on_drop)
	RegisterSignal(parent_item, COMSIG_OBJ_DECONSTRUCT, .proc/on_deconstruct)

/datum/component/powerloader_connected/Destroy(force, silent)
	var/obj/item/parent_item = parent
	parent_item.flags_item &= ~ITEM_ABSTRACT
	return ..()

/datum/component/powerloader_connected/proc/on_drop(datum/source, mob/living/user)
	SIGNAL_HANDLER
	var/obj/item/parent_item = parent
	if(!linked_powerloader)
		qdel(parent_item)
		return
	parent_item.forceMove(linked_powerloader)
	for(var/m in linked_powerloader.buckled_mobs)
		if(m != user)
			continue
		linked_powerloader.unbuckle_mob(user)
		break

/datum/component/powerloader_connected/proc/on_deconstruct()
	SIGNAL_HANDLER
	linked_powerloader.deconstruct(FALSE)
