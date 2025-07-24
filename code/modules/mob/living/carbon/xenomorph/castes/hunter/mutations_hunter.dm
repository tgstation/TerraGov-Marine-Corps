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

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/debilitating_strike
	name = "Debilitating Strike"
	desc = "Stealth's sneak attack no longer stuns. 1.25/1.5/1.75x of your slash damage is added onto sneak attack instead."
	/// For the first structure, the multiplier to add as additional damage when Sneak Attack was successfully used on living beings.
	var/damage_multiplier_initial = 1
	/// For each structure, the multiplier to add as additional damage when Sneak Attack was successfully used on living beings.
	var/damage_multiplier_per_structure = 0.25

/datum/mutation_upgrade/spur/debilitating_strike/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Stealth's sneak attack no longer stuns. [get_multiplier(new_amount)]x of your slash damage is added onto sneak attack instead."

/datum/mutation_upgrade/spur/debilitating_strike/on_mutation_enabled()
	var/datum/action/ability/xeno_action/stealth/stealth_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/stealth]
	if(!stealth_ability)
		return
	stealth_ability.bonus_stealth_damage_multiplier += get_multiplier(0)
	stealth_ability.sneak_attack_stun_duration -= initial(stealth_ability.sneak_attack_stun_duration)
	return ..()

/datum/mutation_upgrade/spur/debilitating_strike/on_mutation_disabled()
	var/datum/action/ability/xeno_action/stealth/stealth_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/stealth]
	if(!stealth_ability)
		return
	stealth_ability.bonus_stealth_damage_multiplier -= get_multiplier(0)
	stealth_ability.sneak_attack_stun_duration += initial(stealth_ability.sneak_attack_stun_duration)
	return ..()

/datum/mutation_upgrade/spur/debilitating_strike/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/xeno_action/stealth/stealth_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/stealth]
	if(!stealth_ability)
		return
	stealth_ability.bonus_stealth_damage_multiplier += get_multiplier(new_amount - previous_amount, FALSE)

/// Returns the multiplier to add as additional damage when Sneak Attack was successfully used on living beings.
/datum/mutation_upgrade/spur/debilitating_strike/proc/get_multiplier(structure_count, include_initial = TRUE)
	return (include_initial ? damage_multiplier_initial : 0) + (damage_multiplier_per_structure * structure_count)

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
	var/datum/action/ability/activable/xeno/silence/silence_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/silence]
	if(!silence_ability)
		return
	silence_ability.hunter_mark_multiplier += get_multiplier(0)
	return ..()

/datum/mutation_upgrade/veil/one_target/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/silence/silence_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/silence]
	if(!silence_ability)
		return
	silence_ability.hunter_mark_multiplier -= get_multiplier(0)
	return ..()

/datum/mutation_upgrade/veil/one_target/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/silence/silence_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/silence]
	if(!silence_ability)
		return
	silence_ability.hunter_mark_multiplier += get_multiplier(new_amount - previous_amount, FALSE)

/// Returns the multiplier to add to Silence's effectiveness against the Hunter's Mark target.
/datum/mutation_upgrade/veil/one_target/proc/get_multiplier(structure_count, include_initial = TRUE)
	return (include_initial ? multiplier_initial : 0) + (multiplier_per_structure * structure_count)
