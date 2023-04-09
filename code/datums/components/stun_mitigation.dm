/datum/component/stun_mitigation
	var/mob/living/affected
	/// Percentage damage The shield intercepts.
	var/datum/armor/cover
	var/shield_flags = NONE
	var/slot_flags = SLOT_L_HAND|SLOT_R_HAND
	var/layer = 50
	var/active = TRUE


/datum/component/stun_mitigation/Initialize(shield_flags, shield_cover = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 50, BIO = 50, FIRE = 50, ACID = 50))
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	var/obj/item/parent_item = parent
	if(shield_flags & SHIELD_TOGGLE)
		RegisterSignal(parent, COMSIG_ITEM_TOGGLE_ACTIVE, PROC_REF(toggle_shield))
		active = parent_item.active
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(shield_equipped))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(shield_dropped))
	if(active)
		if(ismob(parent_item.loc))
			shield_init(parent_item.loc)

	if(islist(shield_cover))
		cover = getArmor(arglist(shield_cover))
	else if(istype(shield_cover, /datum/armor))
		cover = shield_cover
	else
		cover = getArmor()
		stack_trace("Invalid type found in cover during /datum/component/stun_mitigation Initialize()")


/datum/component/stun_mitigation/Destroy()
	shield_detatch_from_user()
	cover = null
	return ..()

/datum/component/stun_mitigation/proc/shield_init(mob/holder_mob) // If we confess our sins (like this proc), he is faithful and just and will forgive us our sins and purify us from all unrighteousness.
	var/slot
	if(parent == holder_mob.l_hand)
		slot = SLOT_L_HAND
	else if(parent == holder_mob.r_hand)
		slot = SLOT_R_HAND
	else if(parent == holder_mob.wear_mask)
		slot = SLOT_WEAR_MASK
	else if(iscarbon(holder_mob))
		var/mob/living/carbon/holder_carbon = holder_mob
		if(parent == holder_carbon.handcuffed)
			slot = SLOT_HANDCUFFED
		else if(parent == holder_carbon.back)
			slot = SLOT_BACK
		else if(ishuman(holder_mob))
			var/mob/living/carbon/human/holder_human = holder_mob
			if(parent == holder_human.wear_suit)
				slot = SLOT_WEAR_SUIT
			else if(parent == holder_human.w_uniform)
				slot = SLOT_W_UNIFORM
			else if(parent == holder_human.shoes)
				slot = SLOT_SHOES
			else if(parent == holder_human.belt)
				slot = SLOT_BELT
			else if(parent == holder_human.gloves)
				slot = SLOT_GLOVES
			else if(parent == holder_human.glasses)
				slot = SLOT_GLASSES
			else if(parent == holder_human.head)
				slot = SLOT_HEAD
			else if(parent == holder_human.wear_ear)
				slot = SLOT_EARS
			else if(parent == holder_human.wear_id)
				slot = SLOT_WEAR_ID
			else if(parent == holder_human.r_store)
				slot = SLOT_R_STORE
			else if(parent == holder_human.l_store)
				slot = SLOT_L_STORE
			else if(parent == holder_human.s_store)
				slot = SLOT_S_STORE
	shield_equipped(parent, holder_mob, slot)

//this should ONLY apply for where affected is in place... i.e. wielding and unwielding.
/datum/component/stun_mitigation/proc/toggle_shield/(datum/source, new_state)
	SIGNAL_HANDLER
	if(active == new_state)
		return
	active = new_state
	if(active)
		RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(shield_equipped))
		RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(shield_dropped))
		if(affected)
			affected.balloon_alert_to_viewers("toggle_shield, on") //debugging
			activate_with_user()
		return
	if(affected)
		affected.balloon_alert_to_viewers("toggle_shield, off") //debugging
		deactivate_with_user()
	UnregisterSignal(parent, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))

/datum/component/stun_mitigation/proc/shield_equipped(datum/source, mob/living/user, slot)
	SIGNAL_HANDLER
	if(!(slot_flags & slot))
		shield_detatch_from_user()
		return
	shield_affect_user(user)

/datum/component/stun_mitigation/proc/shield_dropped(datum/source, mob/user)
	SIGNAL_HANDLER
	shield_detatch_from_user()

/datum/component/stun_mitigation/proc/shield_affect_user(mob/living/user)
	if(affected)
		if(affected == user)
			return //Already active
		shield_detatch_from_user()
	affected = user
	affected.balloon_alert_to_viewers("shield_affect_user") //debugging
	if(active)
		activate_with_user()

/datum/component/stun_mitigation/proc/activate_with_user()
	RegisterSignal(affected, COMSIG_LIVING_STUN_MITIGATION, PROC_REF(on_attack_stun_mitigation))

/datum/component/stun_mitigation/proc/deactivate_with_user()
	UnregisterSignal(affected, COMSIG_LIVING_STUN_MITIGATION)

/datum/component/stun_mitigation/proc/shield_detatch_from_user()
	if(!affected)
		return
	SEND_SIGNAL(affected, COMSIG_MOB_SHIELD_DETATCH)
	deactivate_with_user()
	affected = null

///attempts to convert incoming hard stuns to soft stuns
/datum/component/stun_mitigation/proc/on_attack_stun_mitigation(datum/source, list/incoming_stuns, damage_type, penetration)
	SIGNAL_HANDLER
	var/obj/item/parent_item = parent
	var/mitigation_prob = cover.getRating(damage_type) - penetration
	var/status_cover_modifier = 1

	if(mitigation_prob <= 0)
		affected.balloon_alert_to_viewers("[mitigation_prob] too low") //debugging
		return

	if(parent_item.obj_integrity <= parent_item.integrity_failure)
		affected.balloon_alert_to_viewers("low integrity") //debugging
		return

	if(affected.IsSleeping() || affected.IsUnconscious() || affected.IsAdminSleeping())
		affected.balloon_alert_to_viewers("sleepy") //debugging
		return

	if(affected.IsStun() || affected.IsKnockdown() || affected.IsParalyzed())
		status_cover_modifier *= 0.5

	if(iscarbon(affected))
		var/mob/living/carbon/C = affected
		if(C.stagger)
			status_cover_modifier *= 0.50 //being staggered and stunned is a bad day

	mitigation_prob *= status_cover_modifier
	affected.balloon_alert_to_viewers("[mitigation_prob]") //debugging

	if(!prob(mitigation_prob))
		return

	var/max_hardstun = max(incoming_stuns[1], incoming_stuns[2], incoming_stuns[5]) //stun, weaken and knockback
	incoming_stuns[3] += max_hardstun //stagger
	incoming_stuns[4] += max_hardstun //slowdown
	incoming_stuns[1] = 0
	incoming_stuns[2] = 0
	incoming_stuns[5] = 0
	to_chat(affected, span_avoidharm("\The [parent_item.name] absorbs the impact!"))

