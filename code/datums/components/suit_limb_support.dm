/**
	Limb support module

	The Limb support is an armor component that can be eqiupped to add stablization to limbs:

	Parameters
	* list/supporting_limbs {string} list of body_parts that are supported by the autodoc

*/
/datum/component/suit_limb_support
	var/enabled = FALSE
	var/mob/living/carbon/wearer
	var/list/supporting_limbs = list()

/**
	Setup the default cooldown, chemicals and supported limbs
*/
/datum/component/suit_limb_support/Initialize(list/supporting_limbs)
	if(!istype(parent, /obj/item/clothing))
		return COMPONENT_INCOMPATIBLE

	if(!isnull(supporting_limbs))
		src.supporting_limbs = supporting_limbs

/**
	Cleans up any actions, and internal items used by the autodoc component
*/
/datum/component/suit_limb_support/Destroy(force, silent)
	wearer = null
	return ..()

/**
	Registers signals to enable/disable the autodoc when equipped/dropper/etc
*/
/datum/component/suit_limb_support/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, list(COMSIG_ITEM_EQUIPPED_NOT_IN_SLOT, COMSIG_ITEM_DROPPED), .proc/dropped)
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED_TO_SLOT, .proc/equipped)


/**
	Remove signals
*/
/datum/component/suit_limb_support/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(
		COMSIG_PARENT_EXAMINE,
		COMSIG_ITEM_EQUIPPED_NOT_IN_SLOT,
		COMSIG_ITEM_DROPPED,
		COMSIG_ITEM_EQUIPPED_TO_SLOT))

/**
	Specifically registers signals with the wearer to ensure we capture damage taken events
*/
/datum/component/suit_limb_support/proc/RegisterSignals(mob/user)
	RegisterSignal(user, list(COMSIG_HUMAN_LIMB_FRACTURED), .proc/update_limb_support)


/**
	Removes specific user signals
*/
/datum/component/suit_limb_support/proc/UnregisterSignals(mob/user)
	UnregisterSignal(user, list(COMSIG_HUMAN_LIMB_FRACTURED))

/**
	Disables the autodoc and removes actions when dropped
*/
/datum/component/suit_limb_support/proc/dropped(datum/source, mob/user)
	if(!ishuman(user) || !wearer) // if we didn't have a wearer, we haven't put it on yet
		return
	update_limb_support(wearer, TRUE)
	UnregisterSignals(user)
	wearer = null

/**
	Enable the autodoc and give appropriate actions
*/
/datum/component/suit_limb_support/proc/equipped(datum/source, mob/equipper, slot)
	if(!ishuman(equipper)) // requires humans to support their limbs
		return
	wearer = equipper
	RegisterSignals(wearer)
	update_limb_support(wearer, FALSE)

/**
	Updates limb support adding LIMB_STABILIZED if required
*/
/datum/component/suit_limb_support/proc/update_limb_support(mob/living/carbon/human/user, dropped = FALSE)
	for(var/datum/limb/limb in user.limbs)
		if(!supporting_limbs.Find(limb.body_part))
			continue

		if(dropped && (limb.limb_status & LIMB_STABILIZED))
			limb.limb_status &= ~LIMB_STABILIZED
			to_chat(user, "<span class='danger'>You feel the pressure from [parent] about your [limb.display_name] release, leaving it unsupported.</span>")
			playsound(parent, 'sound/machines/hiss.ogg', 15, 0, 1)
			continue

		if(!dropped && ((limb.limb_status & LIMB_BROKEN) && !(limb.limb_status & LIMB_STABILIZED)))
			limb.limb_status |= LIMB_STABILIZED
			playsound(parent, 'sound/voice/b18_fracture.ogg', 15, 0, 1)
			to_chat(user, "<span class='notice'><b>You feel [parent] constrict about your [limb.display_name], stabilizing it.</b></span>")
			playsound(parent, 'sound/machines/hydraulics_1.ogg', 15, 0, 1)
