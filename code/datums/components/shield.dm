#define SHIELD_TOGGLE (1<<0) //Can be toggled on and off.
#define SHIELD_PURE_BLOCKING (1<<1) //Only runs a percentage chance to block, and doesn't interact in other ways.
#define SHIELD_PARENT_INTEGRITY (1<<2) //Transfers damage to parent's integrity.

/datum/component/shield
	var/mob/living/affected
	var/datum/callback/intercept_damage_cb
	var/datum/callback/transfer_damage_cb
	var/datum/armor/armor
	var/datum/armor/cover = list("melee" = 80, "bullet" = 100, "laser" = 100, "energy" = 100, "bomb" = 80, "bio" = 30, "rad" = 0, "fire" = 80, "acid" = 80) //Percentage damage it intercepts.
	var/datum/armor/hardness //Minimum damage to affect the shield
	var/shield_flags = NONE
	var/slot_flags = SLOT_L_HAND|SLOT_R_HAND
	var/layer = 50
	var/active = TRUE


/datum/component/shield/Initialize(shield_flags, new_cover)
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	var/obj/item/parent_item = parent
	if(shield_flags & SHIELD_TOGGLE)
		RegisterSignal(parent, COMSIG_ITEM_TOGGLE_ACTIVE, .proc/toggle_shield)
		active = parent_item.active
	if(active)
		RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/shield_equipped)
		RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/shield_dropped)
		if(ismob(parent_item.loc))
			shield_init(parent_item.loc)
	
	setup_callbacks(shield_flags)

	armor = parent_item.armor

	if(!isnull(new_cover))
		cover = new_cover
	if(islist(cover))
		cover = getArmor(arglist(cover))
	else
		cover = getArmor()

	if(islist(hardness))
		hardness = getArmor(arglist(hardness))
	else if(!hardness)
		hardness = getArmor()


/datum/component/shield/Destroy()
	shield_detatch_from_user()
	armor = null
	cover = null
	hardness = null
	QDEL_NULL(intercept_damage_cb)
	if(transfer_damage_cb)
		QDEL_NULL(transfer_damage_cb)
	return ..()

/datum/component/shield/proc/setup_callbacks(shield_flags)
	if(shield_flags & SHIELD_PURE_BLOCKING)
		intercept_damage_cb = CALLBACK(src, .proc/item_pure_block_chance)
	else
		intercept_damage_cb = CALLBACK(src, .proc/item_intercept_attack)
	if(shield_flags & SHIELD_PARENT_INTEGRITY)
		transfer_damage_cb = CALLBACK(src, .proc/transfer_damage_to_parent)

/datum/component/shield/proc/shield_init(mob/holder_mob) // If we confess our sins (like this proc), he is faithful and just and will forgive us our sins and purify us from all unrighteousness.
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
		else if(parent == holder_carbon.legcuffed)
			slot = SLOT_LEGCUFFED
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

/datum/component/shield/proc/toggle_shield/(datum/source, new_state)
	if(active == new_state)
		return
	active = new_state
	if(active)
		RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/shield_equipped)
		RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/shield_dropped)
		if(affected)
			activate_with_user()
		return
	if(affected)
		deactivate_with_user()
	UnregisterSignal(parent, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))

/datum/component/shield/proc/shield_equipped(datum/source, mob/living/user, slot)
	if(!(slot_flags & slot))
		shield_detatch_from_user()
		return
	shield_affect_user(user)

/datum/component/shield/proc/shield_dropped(datum/source, mob/user)
	shield_detatch_from_user()

/datum/component/shield/proc/shield_affect_user(mob/living/user)
	if(affected)
		if(affected == user)
			return //Already active
		shield_detatch_from_user()
	affected = user
	if(active)
		activate_with_user()

/datum/component/shield/proc/activate_with_user()
	RegisterSignal(affected, COMSIG_SHIELDSCALL_HUMAN_ATTACKEDBY, .proc/on_attack_cb_shields_call)

/datum/component/shield/proc/deactivate_with_user()
	UnregisterSignal(affected, COMSIG_SHIELDSCALL_HUMAN_ATTACKEDBY)

/datum/component/shield/proc/shield_detatch_from_user()
	if(!affected)
		return
	deactivate_with_user()
	affected = null

/datum/component/shield/proc/on_attack_cb_shields_call(datum/source, list/affecting_shields, dam_type)
	var/damage_cover = cover.getRating(dam_type)
	if(damage_cover <= 0)
		return
	affecting_shields[intercept_damage_cb] = layer

/datum/component/shield/proc/item_intercept_attack(attack_type, incoming_damage, damage_type, silent)
	var/obj/item/parent_item = parent
	switch(attack_type)
		if(COMBAT_TOUCH_ATTACK)
			if(!prob(cover.getRating(damage_type)))
				return FALSE //Bypassed the shield.
			incoming_damage *= (100 - armor.getRating(damage_type)) * 0.01
			return prob(50 - round(incoming_damage / 3))
		if(COMBAT_MELEE_ATTACK, COMBAT_PROJ_ATTACK)
			var/absorbing_damage = (incoming_damage * cover.getRating(damage_type)) * 0.01
			if(!absorbing_damage)
				return incoming_damage //We are transparent to this kind of damage.
			. = incoming_damage - absorbing_damage
			absorbing_damage -= hardness.getRating(damage_type)
			if(absorbing_damage <= 0)
				if(!silent)
					to_chat(world, "<span class='avoidharm'>\The [parent_item.name] [. ? "softens" : "soaks"] the damage!</span>")
				return
			absorbing_damage *= (100 - armor.getRating(damage_type)) * 0.01
			if(absorbing_damage <= 0)
				if(!silent)
					to_chat(world, "<span class='avoidharm'>\The [parent_item.name] [. ? "softens" : "soaks"] the damage!</span>")
				return
			if(transfer_damage_cb)
				return transfer_damage_cb.Invoke(absorbing_damage, ., silent)

/datum/component/shield/proc/item_pure_block_chance(attack_type, incoming_damage, damage_type, silent)
	switch(attack_type)
		if(COMBAT_TOUCH_ATTACK)
			if(!prob(cover.getRating(damage_type)))
				return FALSE //Bypassed the shield.
			incoming_damage *= (100 - armor.getRating(damage_type)) * 0.01
			return prob(50 - round(incoming_damage / 3))
		if(COMBAT_MELEE_ATTACK, COMBAT_PROJ_ATTACK)
			if(prob(cover.getRating(damage_type)))
				return 0 //Blocked
			return incoming_damage //Went through.

/datum/component/shield/proc/transfer_damage_to_parent(incoming_damage, return_damage, silent)
	. = return_damage
	var/obj/item/parent_item = parent
	if(incoming_damage >= parent_item.obj_integrity)
		. += incoming_damage - parent_item.obj_integrity
		parent_item.take_damage(incoming_damage, armour_penetration = 100) //Armor has already been accounted for, this should destroy the parent and datum.
		return
	if(!silent)
		to_chat(world, "<span class='avoidharm'>\The [parent_item.name] [. ? "softens" : "soaks"] the damage!</span>")
	parent_item.take_damage(incoming_damage, armour_penetration = 100)


//Dune, Halo and energy shields.

/datum/component/shield/overhealth
	cover = list("melee" = 0, "bullet" = 80, "laser" = 100, "energy" = 100, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 80)
	var/max_shield_integrity = 100
	var/shield_integrity = 100
	var/recharge_rate = 1 SECONDS
	var/integrity_regen = 10 //per recharge_rate
	var/recharge_cooldown = 5 SECONDS //after being hit
	var/next_recharge = 0 //world.time based

/datum/component/shield/overhealth/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()
	
/datum/component/shield/overhealth/setup_callbacks(shield_flags)
	intercept_damage_cb = CALLBACK(src, .proc/overhealth_intercept_attack)
	transfer_damage_cb = CALLBACK(src, .proc/transfer_damage_to_overhealth)

/datum/component/shield/overhealth/proc/overhealth_intercept_attack(attack_type, incoming_damage, damage_type, silent)
	var/obj/item/parent_item = parent
	switch(attack_type)
		if(COMBAT_TOUCH_ATTACK)
			return FALSE
		if(COMBAT_MELEE_ATTACK)
			return incoming_damage //The slow blade penetrates.
		if(COMBAT_PROJ_ATTACK)
			var/absorbing_damage = (incoming_damage * cover.getRating(damage_type)) * 0.01
			if(!absorbing_damage)
				return incoming_damage //We are transparent to this kind of damage.
			. = incoming_damage - absorbing_damage
			absorbing_damage -= hardness.getRating(damage_type)
			if(absorbing_damage <= 0)
				if(!silent)
					to_chat(world, "<span class='avoidharm'>\The [parent_item.name] [. ? "softens" : "soaks"] the damage!</span>")
				return
			absorbing_damage *= (100 - armor.getRating(damage_type)) * 0.01
			if(absorbing_damage <= 0)
				if(!silent)
					to_chat(world, "<span class='avoidharm'>\The [parent_item.name] [. ? "softens" : "soaks"] the damage!</span>")
				return
			if(transfer_damage_cb)
				return transfer_damage_cb.Invoke(absorbing_damage, ., silent)

/datum/component/shield/overhealth/proc/transfer_damage_to_overhealth(incoming_damage, return_damage, silent)
	. = return_damage
	var/obj/item/parent_item = parent
	if(incoming_damage >= shield_integrity)
		. += incoming_damage - shield_integrity
		damage_overhealth(incoming_damage)
		return
	if(!silent)
		to_chat(world, "<span class='avoidharm'>\The [parent_item.name] [. ? "softens" : "soaks"] the damage!</span>")
	damage_overhealth(incoming_damage)

/datum/component/shield/overhealth/proc/damage_overhealth(amount)
	var/datum/effect_system/spark_spread/s = new
	s.set_up(2, 1, parent)
	s.start()
	shield_integrity -= max(shield_integrity - amount, 0)
	if(!shield_integrity)
		deactivate_with_user()
		return
	if(!next_recharge)
		START_PROCESSING(SSprocessing, src)
	next_recharge = max(next_recharge, world.time + recharge_cooldown)


/datum/component/shield/overhealth/process()
	if(world.time < next_recharge)
		return
	if(shield_integrity >= max_shield_integrity)
		STOP_PROCESSING(SSprocessing, src)
		next_recharge = 0
		return

	var/needs_activation = !shield_integrity
	shield_integrity = min(shield_integrity + integrity_regen, max_shield_integrity)
	next_recharge = max(next_recharge, world.time + recharge_rate)
	if(needs_activation)
		if(affected)
			activate_with_user()
		else
			active = TRUE

/datum/component/shield/overhealth/activate_with_user()
	. = ..()
	if(!shield_integrity)
		return
	var/mob/living/carbon/human/affected_human = affected
	affected_human.overlays_standing[OVERHEALTH_SHIELD_LAYER] = list(mutable_appearance('icons/effects/effects.dmi', "shield-blue", affected.layer + 0.01))
	affected_human.apply_overlay(OVERHEALTH_SHIELD_LAYER)

/datum/component/shield/overhealth/deactivate_with_user()
	var/mob/living/carbon/human/affected_human = affected
	affected_human.remove_overlay(OVERHEALTH_SHIELD_LAYER)
	return ..()
