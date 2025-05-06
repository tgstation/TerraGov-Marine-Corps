/datum/component/shield
	///Shielded mob
	var/mob/living/affected
	///Callback to block damage entirely
	var/datum/callback/intercept_damage_cb
	///Callback to transfer damage to the shield
	var/datum/callback/transfer_damage_cb
	/// Percentage damage The shield intercepts.
	var/datum/armor/cover
	///Behavior flags
	var/shield_flags = NONE
	///What slots the parent item provides its shield effects in
	var/slot_flags = list(SLOT_L_HAND, SLOT_R_HAND)
	///Shield priority layer
	var/layer = 50
	///Is the shield currently active
	var/active = TRUE


/datum/component/shield/Initialize(shield_flags, shield_cover = list(MELEE = 80, BULLET = 100, LASER = 100, ENERGY = 100, BOMB = 80, BIO = 30, FIRE = 80, ACID = 80))
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	var/obj/item/parent_item = parent

	if(shield_flags & SHIELD_TOGGLE)
		RegisterSignal(parent, COMSIG_ITEM_TOGGLE_ACTIVE, PROC_REF(toggle_shield))
		active = parent_item.active

	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(shield_equipped))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(shield_dropped))

	if(active && ismob(parent_item.loc))
		var/mob/holder_mob = parent_item.loc
		shield_equipped(parent, holder_mob, holder_mob.get_equipped_slot(parent))

	setup_callbacks(shield_flags)

	if(islist(shield_cover))
		cover = getArmor(arglist(shield_cover))
	else if(istype(shield_cover, /datum/armor))
		cover = shield_cover
	else
		cover = getArmor()
		stack_trace("Invalid type found in cover during /datum/component/shield Initialize()")


/datum/component/shield/Destroy()
	shield_detach_from_user()
	cover = null
	intercept_damage_cb = null
	transfer_damage_cb = null
	return ..()

///Sets up the correct callbacks based on flagged behavior
/datum/component/shield/proc/setup_callbacks(shield_flags)
	if(shield_flags & SHIELD_PURE_BLOCKING)
		intercept_damage_cb = CALLBACK(src, PROC_REF(item_pure_block_chance))
	else
		intercept_damage_cb = CALLBACK(src, PROC_REF(item_intercept_attack))
	if(shield_flags & SHIELD_PARENT_INTEGRITY)
		transfer_damage_cb = CALLBACK(src, PROC_REF(transfer_damage_to_parent))

///Toggles the mitigation on or off when already equipped
/datum/component/shield/proc/toggle_shield(datum/source, new_state)
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

///Handles equipping the shield
/datum/component/shield/proc/shield_equipped(datum/source, mob/living/user, slot)
	SIGNAL_HANDLER
	if(!(slot in slot_flags))
		shield_detach_from_user()
		return
	shield_affect_user(user)

	var/obj/item/parent_item = parent //Apply in-hand slowdowns.
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/human_user = user
	if(parent_item.slowdown) //todo: make this less smelly, I have no idea why this is on the shield component, and could likely cause unintended double slowdown
		human_user.add_movespeed_modifier(parent_item.type, TRUE, 0, ((parent_item.item_flags & IMPEDE_JETPACK) ? SLOWDOWN_IMPEDE_JETPACK : NONE), TRUE, parent_item.slowdown)

///Handles unequipping the shield
/datum/component/shield/proc/shield_dropped(datum/source, mob/user)
	SIGNAL_HANDLER
	shield_detach_from_user()

	var/obj/item/parent_item = parent //Apply in-hand slowdowns.
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/human_user = user
	if(parent_item.slowdown)
		human_user.remove_movespeed_modifier(parent.type)

///Toggles shield effects for the user
/datum/component/shield/proc/shield_affect_user(mob/living/user)
	if(affected)
		if(affected == user)
			return //Already active
		shield_detach_from_user()
	affected = user
	if(active)
		activate_with_user()

///Detaches shield from the user
/datum/component/shield/proc/shield_detach_from_user()
	if(!affected)
		return
	SEND_SIGNAL(affected, COMSIG_MOB_SHIELD_DETACH)
	deactivate_with_user()
	affected = null

///Activates shield effects
/datum/component/shield/proc/activate_with_user()
	RegisterSignal(affected, COMSIG_LIVING_SHIELDCALL, PROC_REF(on_attack_cb_shields_call))

///Deactivates shield effects
/datum/component/shield/proc/deactivate_with_user()
	UnregisterSignal(affected, COMSIG_LIVING_SHIELDCALL)

///Signal handler for incoming damage, directs to the right callback proc
/datum/component/shield/proc/on_attack_cb_shields_call(datum/source, list/affecting_shields, dam_type)
	SIGNAL_HANDLER
	if(cover.getRating(dam_type) <= 0)
		return
	affecting_shields[intercept_damage_cb] = layer

///Calculates a modifier to the shield coverage based on user or parent conditions
/datum/component/shield/proc/get_shield_status_modifier()
	var/obj/item/parent_item = parent
	var/shield_status_modifier = 1

	if(parent_item.obj_integrity <= parent_item.integrity_failure)
		return 0

	if(affected.IsSleeping() || affected.IsUnconscious() || affected.IsAdminSleeping()) //We don't do jack if we're literally KOed/sleeping/paralyzed.
		return 0

	if(affected.IsStun() || affected.IsKnockdown() || affected.IsParalyzed()) //Halve shield cover if we're paralyzed or stunned
		shield_status_modifier *= 0.5

	if(iscarbon(affected))
		var/mob/living/carbon/C = affected
		if(C.IsStaggered()) //Lesser penalty to shield cover for being staggered.
			shield_status_modifier *= 0.75

	return shield_status_modifier

///Damage intercept calculation
/datum/component/shield/proc/item_intercept_attack(attack_type, incoming_damage, damage_type, silent, penetration)
	var/shield_status_modifier = get_shield_status_modifier()

	switch(attack_type)
		if(COMBAT_TOUCH_ATTACK) //Touch attacks return true if the associated negative effect is blocked
			if(!prob(cover.getRating(damage_type) * shield_status_modifier))
				return FALSE
			var/obj/item/parent_item = parent
			incoming_damage = parent_item.modify_by_armor(incoming_damage, damage_type, penetration)
			return prob(50 - round(incoming_damage / 3)) //Two checks for touch attacks to make it less absurdly effective, or something.
		if(COMBAT_MELEE_ATTACK, COMBAT_PROJ_ATTACK) //we return the amount of damage that bypasses the shield
			var/absorbing_damage = incoming_damage * cover.getRating(damage_type) * 0.01 * shield_status_modifier  //Determine cover ratio; this is the % of damage we actually intercept.
			if(!absorbing_damage)
				return incoming_damage
			. = incoming_damage - absorbing_damage
			if(transfer_damage_cb)
				return transfer_damage_cb.Invoke(absorbing_damage, ., damage_type, silent, penetration)

///Applies damage to parent item
/datum/component/shield/proc/transfer_damage_to_parent(return_damage, incoming_damage, damage_type, silent, penetration)
	var/obj/item/parent_item = parent
	incoming_damage = parent_item.modify_by_armor(incoming_damage, damage_type, penetration)
	if(incoming_damage > parent_item.obj_integrity)
		return_damage += incoming_damage - parent_item.obj_integrity //if we destroy the shield item, extra damage spills over
	if(!silent)
		to_chat(affected, span_avoidharm("\The [parent_item.name] [. ? "softens" : "soaks"] the damage!"))
	parent_item.take_damage(incoming_damage)
	return return_damage

///Block chance calculation
/datum/component/shield/proc/item_pure_block_chance(attack_type, incoming_damage, damage_type, silent, penetration)
	switch(attack_type)
		if(COMBAT_TOUCH_ATTACK) //Touch attacks return true if the associated negative effect is blocked
			var/shield_status_modifier = get_shield_status_modifier()
			if(!prob(cover.getRating(damage_type) * shield_status_modifier))
				return FALSE
			var/obj/item/parent_item = parent
			incoming_damage = parent_item.modify_by_armor(incoming_damage, damage_type, penetration)
			return prob(50 - round(incoming_damage / 3)) //Two checks for touch attacks to make it less absurdly effective, or something.
		if(COMBAT_MELEE_ATTACK, COMBAT_PROJ_ATTACK)
			if(prob(cover.getRating(damage_type) - penetration))
				return 0
			return incoming_damage


//Dune, Halo and energy shields.

/datum/component/shield/overhealth
	layer = 100
	cover = list(MELEE = 0, BULLET = 80, LASER = 100, ENERGY = 100, BOMB = 0, BIO = 0, FIRE = 0, ACID = 80)
	slot_flags = list(SLOT_WEAR_SUIT) //For now it only activates while worn on a single place, meaning only one active at a time. Need to handle overlays properly to allow for stacking.
	var/max_shield_integrity = 100
	var/shield_integrity = 100
	var/recharge_rate = 1 SECONDS
	var/integrity_regen = 10 //per recharge_rate
	var/recharge_cooldown = 5 SECONDS //after being hit
	var/next_recharge = 0 //world.time based
	var/shield_overlay = "shield-blue"

/datum/component/shield/overhealth/Initialize(shield_flags, shield_cover = list(MELEE = 0, BULLET = 80, LASER = 100, ENERGY = 100, BOMB = 0, BIO = 0, FIRE = 0, ACID = 80))
	if(!issuit(parent))
		return COMPONENT_INCOMPATIBLE
	return ..()

/datum/component/shield/overhealth/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()


/datum/component/shield/overhealth/setup_callbacks(shield_flags)
	intercept_damage_cb = CALLBACK(src, PROC_REF(overhealth_intercept_attack))
	transfer_damage_cb = CALLBACK(src, PROC_REF(transfer_damage_to_overhealth))

///Checks if damage should be passed to overshield
/datum/component/shield/overhealth/proc/overhealth_intercept_attack(attack_type, incoming_damage, damage_type, silent)
	switch(attack_type)
		if(COMBAT_TOUCH_ATTACK)
			return incoming_damage
		if(COMBAT_MELEE_ATTACK)
			return incoming_damage //The slow blade penetrates.
		if(COMBAT_PROJ_ATTACK)
			var/absorbing_damage = incoming_damage * cover.getRating(damage_type) * 0.01
			if(!absorbing_damage)
				return incoming_damage //We are transparent to this kind of damage.
			return transfer_damage_cb.Invoke(absorbing_damage, incoming_damage - absorbing_damage, silent)

///Calculates actual damage to the shield, returning total amount that penetrates
/datum/component/shield/overhealth/proc/transfer_damage_to_overhealth(absorbing_damage, unabsorbed_damage, silent)
	if(absorbing_damage >= shield_integrity)
		unabsorbed_damage += absorbing_damage - shield_integrity
	if(!silent)
		var/obj/item/parent_item = parent
		to_chat(affected, span_avoidharm("\The [parent_item.name] [. ? "softens" : "soaks"] the damage!"))
	damage_overhealth(absorbing_damage)
	return unabsorbed_damage

///Applies damage to overshield
/datum/component/shield/overhealth/proc/damage_overhealth(amount)
	var/datum/effect_system/spark_spread/s = new
	s.set_up(2, 1, get_turf(parent))
	s.start()
	shield_integrity = max(shield_integrity - amount, 0)
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
