/datum/component/stun_mitigation
	var/mob/living/affected
	///Percentage chance to mitigate a hardstun
	var/datum/armor/cover
	///Any special behavior flags
	var/shield_flags = NONE
	///The slots in which the parent can be in for the component to apply
	var/slot_flags = SLOT_L_HAND|SLOT_R_HAND
	///Whether the component is currently active
	var/active = TRUE


/datum/component/stun_mitigation/Initialize(shield_flags, slot_override, shield_cover = list(MELEE = 100, BULLET = 100, LASER = 100, ENERGY = 100, BOMB = 100, BIO = 100, FIRE = 100, ACID = 100))
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	var/obj/item/parent_item = parent

	if(slot_override)
		slot_flags = slot_override

	if(shield_flags & SHIELD_TOGGLE)
		RegisterSignal(parent, COMSIG_ITEM_TOGGLE_ACTIVE, PROC_REF(toggle_shield))
		active = parent_item.active

	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(shield_equipped))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(shield_dropped))

	if(active && ismob(parent_item.loc))
		var/mob/holder_mob = parent_item.loc
		shield_equipped(parent, holder_mob, holder_mob.get_equipped_slot(parent))

	if(islist(shield_cover))
		cover = getArmor(arglist(shield_cover))
	else if(istype(shield_cover, /datum/armor))
		cover = shield_cover
	else
		cover = getArmor()
		stack_trace("Invalid type found in cover during /datum/component/stun_mitigation Initialize()")


/datum/component/stun_mitigation/Destroy()
	shield_detach_from_user()
	cover = null
	return ..()

///Toggles the mitigation on or off when already equipped
/datum/component/stun_mitigation/proc/toggle_shield/(datum/source, new_state)
	SIGNAL_HANDLER
	if(active == new_state)
		return

	active = new_state

	if(!affected)
		return

	if(active)
		activate_with_user()
	else
		deactivate_with_user()

///Signal handler for equipping the shield to a slot
/datum/component/stun_mitigation/proc/shield_equipped(datum/source, mob/living/user, slot)
	SIGNAL_HANDLER
	if(!(slot_flags & slot))
		shield_detach_from_user()
		return
	shield_affect_user(user)

///Signal handler for dropping the shield
/datum/component/stun_mitigation/proc/shield_dropped(datum/source, mob/user)
	SIGNAL_HANDLER
	shield_detach_from_user()

///Handles the shield setting up for a user, and activating if applicable
/datum/component/stun_mitigation/proc/shield_affect_user(mob/living/user)
	if(affected)
		if(affected == user)
			return //Already active
		shield_detach_from_user() //changing affected
	affected = user
	if(active)
		activate_with_user()

///Actually activates the mitigation effect
/datum/component/stun_mitigation/proc/activate_with_user()
	RegisterSignals(affected, list(COMSIG_LIVING_PROJECTILE_STUN, COMSIG_LIVING_JETPACK_STUN), PROC_REF(on_attack_stun_mitigation))

///Actually deactivates the mitigation effect
/datum/component/stun_mitigation/proc/deactivate_with_user()
	UnregisterSignal(affected, COMSIG_LIVING_PROJECTILE_STUN)

///Handles removing the mitigation from a user
/datum/component/stun_mitigation/proc/shield_detach_from_user()
	if(!affected)
		return
	SEND_SIGNAL(affected, COMSIG_MOB_SHIELD_DETACH)
	deactivate_with_user()
	affected = null

///attempts to convert incoming hard stuns to soft stuns
/datum/component/stun_mitigation/proc/on_attack_stun_mitigation(datum/source, list/incoming_stuns, damage_type, penetration)
	SIGNAL_HANDLER

	var/max_hardstun = max(incoming_stuns[1], incoming_stuns[2]) //stun and weaken
	if(!max_hardstun)
		return FALSE

	var/obj/item/parent_item = parent
	var/mitigation_prob = cover.getRating(damage_type) * (100 - penetration) * 0.01 //pen reduction is a % instead of flat like armor

	if(mitigation_prob <= 0)
		return FALSE

	if(parent_item.obj_integrity <= parent_item.integrity_failure)
		return FALSE

	if(affected.IsSleeping() || affected.IsUnconscious() || affected.IsAdminSleeping())
		return FALSE

	if(affected.IsStun() || affected.IsKnockdown() || affected.IsParalyzed())
		mitigation_prob *= 0.5

	if(iscarbon(affected))
		var/mob/living/carbon/C = affected
		if(C.IsStaggered())
			mitigation_prob *= 0.4

	if(!prob(mitigation_prob))
		return FALSE

	incoming_stuns[1] = 0
	incoming_stuns[2] = 0
	incoming_stuns[3] += max_hardstun //stagger
	incoming_stuns[4] += max_hardstun //slowdown
	to_chat(affected, span_avoidharm("\The [parent_item.name] absorbs the impact!"))
	return TRUE

