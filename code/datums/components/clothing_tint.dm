/datum/component/clothing_tint
	var/tint = TINT_NONE
	var/tint_state = TRUE
	var/mob_tinted = FALSE
	var/mob/living/tinted_mob

/datum/component/clothing_tint/Initialize(tint, tint_state)
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	if(!isnull(tint))
		src.tint = tint
	if(!isnull(tint_state))
		src.tint_state = tint_state

/datum/component/clothing_tint/Destroy(force, silent)
	remove_tint()
	tinted_mob = null
	return ..()

/datum/component/clothing_tint/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED_TO_SLOT, .proc/equipped_to_slot)
	RegisterSignal(parent, list(COMSIG_ITEM_EQUIPPED_NOT_IN_SLOT, COMSIG_ITEM_DROPPED), .proc/removed_from_slot)
	RegisterSignal(parent, COMSIG_ITEM_TOGGLE_ACTION, .proc/toggle_tint)
	RegisterSignal(parent, COMSIG_CLOTHING_MECHANICS_INFO, .proc/mechanics_info)

/datum/component/clothing_tint/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(COMSIG_ITEM_EQUIPPED_TO_SLOT, COMSIG_ITEM_EQUIPPED_NOT_IN_SLOT, COMSIG_ITEM_DROPPED, COMSIG_ITEM_TOGGLE_ACTION, COMSIG_CLOTHING_MECHANICS_INFO))

/datum/component/clothing_tint/proc/mechanics_info()
	return COMPONENT_CLOTHING_MECHANICS_TINTED

/datum/component/clothing_tint/proc/toggle_tint(datum/source, mob/user)
	if(!user)
		return
	tint_state = !tint_state
	if(tint_state)
		add_tint()
	else
		remove_tint()

/datum/component/clothing_tint/proc/add_tint()
	if(!tinted_mob || mob_tinted || !tint_state)
		return
	tinted_mob.adjust_tinttotal(tint)
	tinted_mob.update_sight()
	mob_tinted = TRUE

/datum/component/clothing_tint/proc/remove_tint()
	if(!tinted_mob || !mob_tinted)
		return
	tinted_mob.adjust_tinttotal(-tint)
	tinted_mob.update_sight()
	mob_tinted = FALSE

/datum/component/clothing_tint/proc/equipped_to_slot(datum/source, mob/user)
	tinted_mob = user
	add_tint()

/datum/component/clothing_tint/proc/removed_from_slot(datum/source, mob/user)
	remove_tint()
	tinted_mob = null
