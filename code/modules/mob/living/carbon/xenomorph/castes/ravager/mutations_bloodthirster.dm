//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/no_end
	name = "No End"
	desc = "Endure can be used in critical. It now costs 150/125/100% of its original plasma cost."
	/// For the first structure, the multiplier to add as Endure's initial ability cost to add to it.
	var/multiplier_initial = 0.75
	/// For each structure, the multiplier to add as Endure's initial ability cost to add to it.
	var/multiplier_structure = -0.25

/datum/mutation_upgrade/shell/no_end/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Endure can be used in critical. It now costs [PERCENT(1 + get_multiplier(new_amount))]% of its original plasma cost."

/datum/mutation_upgrade/shell/no_end/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/xeno_action/endure/endure_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/endure]
	if(!endure_ability)
		return
	endure_ability.use_state_flags |= (ABILITY_USE_INCAP|ABILITY_USE_LYING)
	endure_ability.ability_cost += initial(endure_ability.ability_cost) * get_multiplier(0)

/datum/mutation_upgrade/shell/no_end/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/xeno_action/endure/endure_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/endure]
	if(!endure_ability)
		return
	endure_ability.use_state_flags &= ~(ABILITY_USE_INCAP|ABILITY_USE_LYING)
	endure_ability.ability_cost -= initial(endure_ability.ability_cost) * get_multiplier(0)

/datum/mutation_upgrade/shell/no_end/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/xeno_action/endure/endure_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/endure]
	if(!endure_ability)
		return
	endure_ability.ability_cost += initial(endure_ability.ability_cost) * get_multiplier(new_amount - previous_amount, FALSE)

/// Returns the multiplier to add as Endure's initial ability cost to add to it.
/datum/mutation_upgrade/shell/no_end/proc/get_multiplier(structure_count, include_initial = TRUE)
	return (include_initial ? multiplier_initial : 0) + (multiplier_structure * structure_count)

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/early_rage
	name = "Early Rage"
	desc = "Rage can be activated at 55/60/65% maximum health. For the purposes of calculating rage power, your current health is assumed to reduced by 5/10/15% of your maximum health. This cannot go beyond the amount required for Super Rage."
	/// For each structure, the percentage of maximum health to add to Rage's activation threshold and to its rage power calculation.
	var/percentage_per_structure = 0.05

/datum/mutation_upgrade/spur/early_rage/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Rage can be activated at [PERCENT(RAVAGER_RAGE_MIN_HEALTH_THRESHOLD + get_percentage(new_amount))]% maximum health. For the purposes of calculating rage power, your current health is assumed to reduced by [PERCENT(get_percentage(new_amount))]% of your maximum health. This cannot go beyond the amount required for Super Rage."

/datum/mutation_upgrade/spur/early_rage/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/xeno_action/rage/rage_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/rage]
	if(!rage_ability)
		return
	rage_ability.minimum_health_rage_threshold += get_percentage(new_amount - previous_amount)
	rage_ability.rage_power_calculation_bonus += get_percentage(new_amount - previous_amount)

/// Returns the percentage of maximum health to add to Rage's activation threshold and to its rage power calculation.
/datum/mutation_upgrade/spur/early_rage/proc/get_percentage(structure_count)
	return percentage_per_structure * structure_count

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/safety_trap
	name = "Safety Trap"
	desc = "Endure further decreases your critical and death threshold by 50/75/100. If Endure ends while your health is under the default death threshold, you die instead."
	/// For the first structure, the amount to increase the death/critical threshold given by Endure while it is active.
	var/threshold_initial = -25
	/// For each structure, the amount to increase the death/critical threshold given by Endure while it is active.
	var/threshold_per_structure = -25

/datum/mutation_upgrade/veil/safety_trap/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Endure further decreases your critical and death threshold by [-get_threshold(new_amount)]. If Endure ends while your health is under the default death threshold, you die instead."

/datum/mutation_upgrade/veil/safety_trap/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/xeno_action/endure/endure_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/endure]
	if(!endure_ability)
		return
	endure_ability.endure_threshold += get_threshold(0)
	endure_ability.death_beyond_threshold = TRUE

/datum/mutation_upgrade/veil/safety_trap/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/xeno_action/endure/endure_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/endure]
	if(!endure_ability)
		return
	endure_ability.endure_threshold -= get_threshold(0)
	endure_ability.death_beyond_threshold = initial(endure_ability.death_beyond_threshold)

/datum/mutation_upgrade/veil/safety_trap/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/xeno_action/endure/endure_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/endure]
	if(!endure_ability)
		return
	endure_ability.endure_threshold += get_threshold(new_amount - previous_amount, FALSE)

/// Returns the amount to increase the death/critical threshold given by Endure while it is active.
/datum/mutation_upgrade/veil/safety_trap/proc/get_threshold(structure_count, include_initial = TRUE)
	return (include_initial ? threshold_initial : 0) + (threshold_per_structure * structure_count)
