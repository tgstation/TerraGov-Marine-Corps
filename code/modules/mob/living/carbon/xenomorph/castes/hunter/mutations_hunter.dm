//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/fleeting_mirage
	name = "Fleeting Mirage"
	desc = "Upon reaching 25/40/55% health, a mirage will appear and run away from you. That mirage takes priority when mirage swapping."
	/// For the first structure, the maximum health threshold that the owner must be reach / be below of in order for the Illusion will appear.
	var/health_threshold_initial = 0.1
	/// For each structure, the maximum health threshold that the owner must be reach / be below of in order for the Illusion will appear.
	var/health_threshold_per_structure = 0.15
	/// If the effect can be activated.
	var/can_be_activated = FALSE
	/// The timer ID of the timer that will delete the mirage.
	var/mirage_timer_id

/datum/mutation_upgrade/shell/fleeting_mirage/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Upon reaching [PERCENT(get_threshold(new_amount))]% health, a mirage will appear and run away from you. That mirage takes priority when mirage swapping."

/datum/mutation_upgrade/shell/fleeting_mirage/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/xeno_action/mirage/mirage_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/mirage]
	if(!mirage_ability)
		return
	RegisterSignal(xenomorph_owner, COMSIG_LIVING_UPDATE_HEALTH, PROC_REF(on_update_health))
	if(xenomorph_owner.health >= xenomorph_owner.maxHealth)
		can_be_activated = TRUE

/datum/mutation_upgrade/shell/fleeting_mirage/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/xeno_action/mirage/mirage_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/mirage]
	if(!mirage_ability)
		return
	UnregisterSignal(xenomorph_owner, COMSIG_LIVING_UPDATE_HEALTH)
	can_be_activated = FALSE
	QDEL_NULL(mirage_ability.prioritized_illusion)
	if(mirage_timer_id)
		deltimer(mirage_timer_id)
		mirage_timer_id = null

/// If their health is under the threshold, activate it if possible. If it is full, let them activate it next time.
/datum/mutation_upgrade/shell/fleeting_mirage/proc/on_update_health(datum/source)
	var/health = (xenomorph_owner.status_flags & GODMODE) ? xenomorph_owner.maxHealth : (xenomorph_owner.maxHealth - xenomorph_owner.getFireLoss() - xenomorph_owner.getBruteLoss())
	if(health <= xenomorph_owner.get_death_threshold())
		return
	if(!can_be_activated)
		if(xenomorph_owner.health >= xenomorph_owner.maxHealth)
			can_be_activated = TRUE
		return
	if(health > xenomorph_owner.maxHealth * get_threshold(get_total_structures()) || mirage_timer_id)
		return
	can_be_activated = FALSE
	var/datum/action/ability/xeno_action/mirage/mirage_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/mirage]
	if(!mirage_ability)
		return
	mirage_ability.prioritized_illusion = new(xenomorph_owner.loc, xenomorph_owner, xenomorph_owner, 10 SECONDS, /datum/ai_behavior/xeno/fleeing_illusion)
	mirage_timer_id = addtimer(CALLBACK(src, PROC_REF(remove_illusion)), 10 SECONDS)

/// Deletes the illusion.
/datum/mutation_upgrade/shell/fleeting_mirage/proc/remove_illusion()
	var/datum/action/ability/xeno_action/mirage/mirage_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/mirage]
	if(!mirage_ability)
		return
	QDEL_NULL(mirage_ability.prioritized_illusion)
	if(mirage_timer_id)
		deltimer(mirage_timer_id)
		mirage_timer_id = null

/// Returns the maximum health threshold that the owner must be reach / be below of in order for the Illusion will appear.
/datum/mutation_upgrade/shell/fleeting_mirage/proc/get_threshold(structure_count, include_initial = TRUE)
	return (include_initial ? health_threshold_initial : 0) + (health_threshold_per_structure * structure_count)

/datum/mutation_upgrade/shell/splitting_mirage
	name = "Splitting Mirage"
	desc = "Mirage will instead cause your slashes to create an illusion for the next 12/14/16 seconds. These illusions disappear when the time is up."
	conflicting_mutation_types = list(
		/datum/mutation_upgrade/veil/mirage_flood
	)
	/// For each structure, the amount of deciseconds to increase Mirage's illusion lifespan by.
	var/length_per_structure = 2 SECONDS

/datum/mutation_upgrade/shell/splitting_mirage/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Mirage will instead cause your slashes to create an illusion for the next [(HUNTER_MIRAGE_ILLUSION_LIFETIME + get_length(new_amount)) / 10] seconds. These illusions disappear when the time is up."

/datum/mutation_upgrade/shell/splitting_mirage/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/xeno_action/mirage/mirage_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/mirage]
	if(!mirage_ability)
		return
	mirage_ability.illusion_count -= initial(mirage_ability.illusion_count)
	mirage_ability.illusion_on_slash = TRUE
	if(length(mirage_ability.illusions)) // Ability is currently active.
		mirage_ability.register_on_slash()

/datum/mutation_upgrade/shell/splitting_mirage/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/xeno_action/mirage/mirage_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/mirage]
	if(!mirage_ability)
		return
	mirage_ability.illusion_count += initial(mirage_ability.illusion_count)
	mirage_ability.illusion_on_slash = FALSE
	if(length(mirage_ability.illusions)) // Ability is currently active.
		mirage_ability.unregister_on_slash()

/datum/mutation_upgrade/shell/splitting_mirage/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/xeno_action/mirage/mirage_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/mirage]
	if(!mirage_ability)
		return
	mirage_ability.illusion_life_time += get_length(new_amount - previous_amount)

/// Returns the amount of deciseconds to increase Mirage's illusion lifespan by.
/datum/mutation_upgrade/shell/splitting_mirage/proc/get_length(structure_count)
	return length_per_structure * structure_count

/datum/mutation_upgrade/shell/cloaking_mirage
	name = "Cloaking Mirage"
	desc = "Mirage will instead creates cloaking gas for 12/14/16 seconds in a radius of 2."
	conflicting_mutation_types = list(
		/datum/mutation_upgrade/veil/mirage_flood
	)
	/// For each structure, the amount of deciseconds to increase Mirage's smoke duration by.
	var/length_per_structure = 2 SECONDS

/datum/mutation_upgrade/shell/cloaking_mirage/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Mirage will instead creates cloaking gas for [(HUNTER_MIRAGE_ILLUSION_LIFETIME + get_length(new_amount)) / 10] seconds in a radius of 2."

/datum/mutation_upgrade/shell/cloaking_mirage/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/xeno_action/mirage/mirage_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/mirage]
	if(!mirage_ability)
		return
	mirage_ability.illusion_count -= initial(mirage_ability.illusion_count)
	mirage_ability.cloaking_gas = TRUE

/datum/mutation_upgrade/shell/cloaking_mirage/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/xeno_action/mirage/mirage_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/mirage]
	if(!mirage_ability)
		return
	mirage_ability.illusion_count += initial(mirage_ability.illusion_count)
	mirage_ability.cloaking_gas = FALSE

/datum/mutation_upgrade/shell/cloaking_mirage/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/xeno_action/mirage/mirage_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/mirage]
	if(!mirage_ability)
		return
	mirage_ability.illusion_life_time += get_length(new_amount - previous_amount)

/// Returns the amount of deciseconds to increase Mirage's illusion lifespan by.
/datum/mutation_upgrade/shell/cloaking_mirage/proc/get_length(structure_count)
	return length_per_structure * structure_count

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/debilitating_strike
	name = "Debilitating Strike"
	desc = "Stealth's sneak attack no longer stuns. 1.25/1.5/1.75x of your slash damage is added onto sneak attack instead."
	conflicting_mutation_types = list(
		/datum/mutation_upgrade/veil/faceblind
	)
	/// For the first structure, the multiplier to add as additional damage when Sneak Attack was successfully used on living beings.
	var/damage_multiplier_initial = 1
	/// For each structure, the multiplier to add as additional damage when Sneak Attack was successfully used on living beings.
	var/damage_multiplier_per_structure = 0.25

/datum/mutation_upgrade/spur/debilitating_strike/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Stealth's sneak attack no longer stuns. [get_multiplier(new_amount)]x of your slash damage is added onto sneak attack instead."

/datum/mutation_upgrade/spur/debilitating_strike/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/xeno_action/stealth/stealth_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/stealth]
	if(!stealth_ability)
		return
	stealth_ability.bonus_stealth_damage_multiplier += get_multiplier(0)
	stealth_ability.sneak_attack_stun_duration -= initial(stealth_ability.sneak_attack_stun_duration)

/datum/mutation_upgrade/spur/debilitating_strike/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/xeno_action/stealth/stealth_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/stealth]
	if(!stealth_ability)
		return
	stealth_ability.bonus_stealth_damage_multiplier -= get_multiplier(0)
	stealth_ability.sneak_attack_stun_duration += initial(stealth_ability.sneak_attack_stun_duration)

/datum/mutation_upgrade/spur/debilitating_strike/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/xeno_action/stealth/stealth_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/stealth]
	if(!stealth_ability)
		return
	stealth_ability.bonus_stealth_damage_multiplier += get_multiplier(new_amount - previous_amount, FALSE)

/// Returns the multiplier to add as additional damage when Sneak Attack was successfully used on living beings.
/datum/mutation_upgrade/spur/debilitating_strike/proc/get_multiplier(structure_count, include_initial = TRUE)
	return (include_initial ? damage_multiplier_initial : 0) + (damage_multiplier_per_structure * structure_count)

/datum/mutation_upgrade/spur/ambush
	name = "Ambush"
	desc = "Stealth's movement cost is 300% of its original value. While at the maximum stealth power, your next sneak attack has an additional 15/22.5/30 AP."
	/// For the first structure, the amount of AP that a maximum powered stealth will get.
	var/ap_initial = 7.5
	/// For each structure, the additional amount of AP that a maximum powered stealth will get.
	var/ap_per_structure = 7.5

/datum/mutation_upgrade/spur/ambush/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return  "Stealth's movement cost is 300% of its original value. While at the maximum stealth power, your next sneak attack has an additional [get_ap(new_amount)] AP."

/datum/mutation_upgrade/spur/ambush/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/xeno_action/stealth/stealth_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/stealth]
	if(!stealth_ability)
		return
	stealth_ability.movement_cost_multiplier += 2 // 100% -> 300%
	stealth_ability.bonus_maximum_stealth_ap += get_ap(0)

/datum/mutation_upgrade/spur/ambush/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/xeno_action/stealth/stealth_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/stealth]
	if(!stealth_ability)
		return
	stealth_ability.movement_cost_multiplier -= 2 // 300% -> 100%
	stealth_ability.bonus_maximum_stealth_ap -= get_ap(0)

/datum/mutation_upgrade/spur/ambush/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/xeno_action/stealth/stealth_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/stealth]
	if(!stealth_ability)
		return
	stealth_ability.bonus_maximum_stealth_ap += get_ap(new_amount - previous_amount, FALSE)

/// Returns the amount of AP that a maximum powered stealth will get.
/datum/mutation_upgrade/spur/ambush/proc/get_ap(structure_count, include_initial = TRUE)
	return (include_initial ? ap_initial : 0) + (ap_per_structure * structure_count)

/datum/mutation_upgrade/spur/maul
	name = "Maul"
	desc = "Pounce no longer stuns, but now slashes your target which can trigger sneak attack. Pounce's cooldown is set to 60/50/40% of its original value."
	/// For the first structure, the multiplier of Pounce's cooldown duration to add to it.
	var/multiplier_initial = -0.3
	/// For each structure, the additional multiplier of Pounce's cooldown duration to add to it.
	var/multiplier_per_structure = -0.1

/datum/mutation_upgrade/spur/maul/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/activable/xeno/pounce/pounce_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce]
	if(!pounce_ability)
		return
	pounce_ability.cooldown_duration += initial(pounce_ability.cooldown_duration) * get_multiplier(0)
	pounce_ability.stun_duration -= initial(pounce_ability.stun_duration)
	pounce_ability.self_immobilize_duration -= initial(pounce_ability.self_immobilize_duration)
	pounce_ability.attack_on_pounce = TRUE

/datum/mutation_upgrade/spur/maul/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/pounce/pounce_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce]
	if(!pounce_ability)
		return
	pounce_ability.cooldown_duration -= initial(pounce_ability.cooldown_duration) * get_multiplier(0)
	pounce_ability.stun_duration += initial(pounce_ability.stun_duration)
	pounce_ability.self_immobilize_duration += initial(pounce_ability.self_immobilize_duration)
	pounce_ability.attack_on_pounce = FALSE

/datum/mutation_upgrade/spur/maul/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/pounce/pounce_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce]
	if(!pounce_ability)
		return
	pounce_ability.cooldown_duration += initial(pounce_ability.cooldown_duration) * get_multiplier(new_amount - previous_amount, FALSE)

/// Returns the amount of AP that a maximum powered stealth will get.
/datum/mutation_upgrade/spur/maul/proc/get_multiplier(structure_count, include_initial = TRUE)
	return (include_initial ? multiplier_initial : 0) + (multiplier_per_structure * structure_count)

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/one_target
	name = "One Target"
	desc = "The effects of Silence against your Hunter's Mark target last 2.5/2.75/3x as long."
	/// For the first structure, the multiplier to add to Silence's effectiveness against the Hunter's Mark target.
	var/multiplier_initial = 0.75
	/// For each structure, the multiplier to add to Silence's effectiveness against the Hunter's Mark target.
	var/multiplier_per_structure = 0.25

/datum/mutation_upgrade/veil/one_target/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "The effects of Silence against your Hunter's Mark target last [HUNTER_SILENCE_MULTIPLIER + get_multiplier(new_amount)]x as long."

/datum/mutation_upgrade/veil/one_target/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/activable/xeno/silence/silence_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/silence]
	if(!silence_ability)
		return
	silence_ability.hunter_mark_multiplier += get_multiplier(0)

/datum/mutation_upgrade/veil/one_target/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/silence/silence_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/silence]
	if(!silence_ability)
		return
	silence_ability.hunter_mark_multiplier -= get_multiplier(0)

/datum/mutation_upgrade/veil/one_target/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/silence/silence_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/silence]
	if(!silence_ability)
		return
	silence_ability.hunter_mark_multiplier += get_multiplier(new_amount - previous_amount, FALSE)

/// Returns the multiplier to add to Silence's effectiveness against the Hunter's Mark target.
/datum/mutation_upgrade/veil/one_target/proc/get_multiplier(structure_count, include_initial = TRUE)
	return (include_initial ? multiplier_initial : 0) + (multiplier_per_structure * structure_count)

/datum/mutation_upgrade/veil/mirage_flood
	name = "Mirage Flood"
	desc = "Mirage creates 4 additional illusions, but the duration is reduced by 5/3/1 seconds."
	conflicting_mutation_types = list(
		/datum/mutation_upgrade/shell/splitting_mirage,
		/datum/mutation_upgrade/shell/cloaking_mirage
	)
	/// For the first structure, the amount of deciseconds to add to Mirage's illusion lifespan.
	var/duration_initial = -7 SECONDS
	/// For each structure, the additional amount of deciseconds to add to Mirage's illusion lifespan.
	var/duration_per_structure = 2 SECONDS

/datum/mutation_upgrade/veil/mirage_flood/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Mirage creates 4 additional illusions, but the duration is reduced by [get_duration(new_amount) / 10] seconds."

/datum/mutation_upgrade/veil/mirage_flood/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/xeno_action/mirage/mirage_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/mirage]
	if(!mirage_ability)
		return
	mirage_ability.illusion_count += 4
	mirage_ability.illusion_life_time += get_duration(0)

/datum/mutation_upgrade/veil/mirage_flood/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/xeno_action/mirage/mirage_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/mirage]
	if(!mirage_ability)
		return
	mirage_ability.illusion_count -= 4
	mirage_ability.illusion_life_time += get_duration(0)

/datum/mutation_upgrade/veil/mirage_flood/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/xeno_action/mirage/mirage_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/mirage]
	if(!mirage_ability)
		return
	mirage_ability.illusion_life_time += get_duration(new_amount - previous_amount, FALSE)

/datum/mutation_upgrade/veil/mirage_flood/proc/get_duration(structure_count, include_initial = TRUE)
	return (include_initial ? duration_initial : 0) + (duration_per_structure * structure_count)

/datum/mutation_upgrade/veil/faceblind
	name = "Faceblind"
	desc = "Stealth's sneak attack causes temporary blindness, but no longer stuns. Mirage's cooldown is set to 90/80/70% of its original value."
	conflicting_mutation_types = list(
		/datum/mutation_upgrade/spur/debilitating_strike
	)
	/// For each structure, the additional multiplier of Mirage's cooldown duration to add to it.
	var/multiplier_per_structure = -0.1

/datum/mutation_upgrade/veil/faceblind/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Stealth's sneak attack causes temporary blindness, but no longer stuns. Mirage's cooldown is set to [PERCENT(1 + get_multiplier(new_amount))]% of its original value."

/datum/mutation_upgrade/veil/faceblind/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/xeno_action/stealth/stealth_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/stealth]
	if(!stealth_ability)
		return
	stealth_ability.sneak_attack_stun_duration = 0 SECONDS
	stealth_ability.blinding_stacks = 2

/datum/mutation_upgrade/veil/faceblind/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/xeno_action/stealth/stealth_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/stealth]
	if(!stealth_ability)
		return
	stealth_ability.sneak_attack_stun_duration = initial(stealth_ability.sneak_attack_stun_duration)
	stealth_ability.blinding_stacks = initial(stealth_ability.blinding_stacks)

/datum/mutation_upgrade/veil/faceblind/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/xeno_action/mirage/mirage_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/mirage]
	if(!mirage_ability)
		return
	mirage_ability.cooldown_duration += initial(mirage_ability.cooldown_duration) * get_multiplier(new_amount - previous_amount)

/datum/mutation_upgrade/veil/faceblind/proc/get_multiplier(structure_count)
	return multiplier_per_structure * structure_count
