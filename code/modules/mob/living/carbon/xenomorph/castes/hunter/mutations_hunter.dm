//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/fleeting_mirage
	name = "Fleeting Mirage"
	desc = "Upon reaching 25/40/55% health, a mirage will appear and run away from you. That mirage takes priority when mirage swapping."
	/// For the first structure, the percentage of maximum health that needs to be reached.
	var/health_threshold_initial = 0.1
	/// For each structure, the additional percentage of maximum health that needs to be reached.
	var/health_threshold_per_structure = 0.15
	/// If the effect can be activated.
	var/can_be_activated = FALSE
	/// The timer ID of the timer that will delete the mirage.
	var/mirage_timer_id

/datum/mutation_upgrade/shell/fleeting_mirage/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Upon reaching [(health_threshold_initial + (health_threshold_per_structure * new_amount)) * 100]% health, a mirage will appear and run away from you. That mirage takes priority when mirage swapping."

/datum/mutation_upgrade/shell/fleeting_mirage/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/xeno_action/mirage/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/mirage]
	if(!ability)
		return FALSE
	RegisterSignals(xenomorph_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE), PROC_REF(on_damage))
	if(xenomorph_owner.health >= xenomorph_owner.maxHealth)
		can_be_activated = TRUE
	return ..()

/datum/mutation_upgrade/shell/fleeting_mirage/on_mutation_disabled()
	var/datum/action/ability/xeno_action/mirage/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/mirage]
	if(!ability)
		return FALSE
	UnregisterSignal(xenomorph_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE, COMSIG_MOB_STAT_CHANGED))
	can_be_activated = FALSE
	if(ability.prioritized_illusion)
		qdel(ability.prioritized_illusion)
		ability.prioritized_illusion = null
		if(mirage_timer_id)
			deltimer(mirage_timer_id)
			mirage_timer_id = null
	return ..()

/// Checks on the next tick if anything needs to be done with their new health since it is possible the health is inaccurate (because there can be other modifiers).
/datum/mutation_upgrade/shell/fleeting_mirage/proc/on_damage(datum/source, amount, list/amount_mod)
	SIGNAL_HANDLER
	INVOKE_NEXT_TICK(src, PROC_REF(check_current_health))

/// If their health is under the threshold, activate it if possible. If it is full, let them activate it next time.
/datum/mutation_upgrade/shell/fleeting_mirage/proc/check_current_health()
	if(!can_be_activated && xenomorph_owner.health >= xenomorph_owner.maxHealth)
		can_be_activated = TRUE
		return
	var/threshold = xenomorph_owner.maxHealth * (health_threshold_initial + (health_threshold_per_structure * get_total_structures()))
	if(!can_be_activated || xenomorph_owner.health > threshold || mirage_timer_id)
		return
	can_be_activated = FALSE
	var/datum/action/ability/xeno_action/mirage/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/mirage]
	if(!ability)
		return
	ability.prioritized_illusion = new /mob/illusion/xeno/fleeing(xenomorph_owner.loc, xenomorph_owner, xenomorph_owner, 10 SECONDS)
	mirage_timer_id = addtimer(CALLBACK(src, PROC_REF(remove_illusion)), 10 SECONDS)

/// Checks on the next tick if anything needs to be done with their new health since it is possible the health is inaccurate (because there can be other modifiers).
/datum/mutation_upgrade/shell/fleeting_mirage/proc/remove_illusion()
	var/datum/action/ability/xeno_action/mirage/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/mirage]
	if(!ability)
		return
	qdel(ability.prioritized_illusion)
	ability.prioritized_illusion = null
	if(mirage_timer_id)
		deltimer(mirage_timer_id)
		mirage_timer_id = null

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/debilitating_strike
	name = "Debilitating Strike"
	desc = "Stealth's sneak attack no longer stuns. 1.25/1.5/1.75x of your slash damage is added onto sneak attack instead."
	/// For the first structure, the additive damage multiplier to add.
	var/additive_damage_multiplier_initial = 1
	/// For each structure, the additional additive damage multiplier to add.
	var/additive_damage_multiplier_per_structure = 0.25

/datum/mutation_upgrade/spur/debilitating_strike/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Stealth's sneak attack no longer stuns. [additive_damage_multiplier_initial + (additive_damage_multiplier_per_structure * new_amount)]x of your slash damage is added onto sneak attack instead."

/datum/mutation_upgrade/spur/debilitating_strike/on_mutation_enabled()
	var/datum/action/ability/xeno_action/stealth/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/stealth]
	if(!ability)
		return FALSE
	ability.bonus_stealth_damage_multiplier += additive_damage_multiplier_initial
	ability.sneak_attack_stun_duration -= initial(ability.sneak_attack_stun_duration)
	return ..()

/datum/mutation_upgrade/spur/debilitating_strike/on_mutation_disabled()
	var/datum/action/ability/xeno_action/stealth/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/stealth]
	if(!ability)
		return FALSE
	ability.bonus_stealth_damage_multiplier -= additive_damage_multiplier_initial
	ability.sneak_attack_stun_duration += initial(ability.sneak_attack_stun_duration)
	return ..()

/datum/mutation_upgrade/spur/debilitating_strike/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/xeno_action/stealth/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/stealth]
	if(!ability)
		return FALSE
	ability.bonus_stealth_damage_multiplier += (new_amount - previous_amount) * additive_damage_multiplier_per_structure

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/one_target
	name = "One Target"
	desc = "The effects of Silence against your Hunter's Mark target last 2.5/2.75/3x as long."
	/// For the first structure, the additive multiplier to add.
	var/additive_silence_multiplier_initial = 0.75
	/// For each structure, the additional additive multiplier to add.
	var/additive_silence_multiplier_per_structure = 0.25

/datum/mutation_upgrade/veil/one_target/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "The effects of Silence against your Hunter's Mark target last [HUNTER_SILENCE_MULTIPLIER + additive_silence_multiplier_initial + (additive_silence_multiplier_per_structure * new_amount)]x as long."

/datum/mutation_upgrade/veil/one_target/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/silence/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/silence]
	if(!ability)
		return FALSE
	ability.hunter_mark_multiplier += additive_silence_multiplier_initial
	return ..()

/datum/mutation_upgrade/veil/one_target/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/silence/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/silence]
	if(!ability)
		return FALSE
	ability.hunter_mark_multiplier -= additive_silence_multiplier_initial
	return ..()

/datum/mutation_upgrade/veil/one_target/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/silence/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/silence]
	if(!ability)
		return FALSE
	ability.hunter_mark_multiplier += (new_amount - previous_amount) * additive_silence_multiplier_per_structure
