/datum/component/blur_protection

/datum/component/blur_protection/Initialize()
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/blur_protection/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED_TO_SLOT, PROC_REF(equipped_to_slot))
	RegisterSignals(parent, list(COMSIG_ITEM_EQUIPPED_NOT_IN_SLOT, COMSIG_ITEM_DROPPED), PROC_REF(removed_from_slot))
	RegisterSignal(parent, COMSIG_CLOTHING_MECHANICS_INFO, PROC_REF(mechanics_info))

/datum/component/blur_protection/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(COMSIG_ITEM_EQUIPPED_TO_SLOT, COMSIG_ITEM_EQUIPPED_NOT_IN_SLOT, COMSIG_ITEM_DROPPED, COMSIG_CLOTHING_MECHANICS_INFO))

/datum/component/blur_protection/proc/mechanics_info()
	SIGNAL_HANDLER
	return COMPONENT_CLOTHING_BLUR_PROTECTION

/datum/component/blur_protection/proc/equipped_to_slot(datum/source, mob/user, slot)
	SIGNAL_HANDLER
	RegisterSignal(user, COMSIG_LIVING_UPDATE_PLANE_BLUR, PROC_REF(cancel_blur))

/datum/component/blur_protection/proc/cancel_blur()
	return COMPONENT_CANCEL_BLUR

/datum/component/blur_protection/proc/removed_from_slot(datum/source, mob/user)
	SIGNAL_HANDLER
	UnregisterSignal(user, COMSIG_LIVING_UPDATE_PLANE_BLUR)
