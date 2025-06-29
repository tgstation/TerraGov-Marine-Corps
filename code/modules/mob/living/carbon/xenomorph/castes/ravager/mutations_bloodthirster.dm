//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/no_end
	name = "No End"
	desc = "Endure can be used in critical. It now costs 150/125/100% of its original plasma cost."
	/// For the first structure, the percentage of the initial plasma cost to increase Endure by.
	var/plasma_cost_percentage_increase_initial = 0.75
	/// For each structure, the percentage of the initial plasma cost to increase Endure by.
	var/plasma_cost_percentage_increase_per_structure = -0.25

/datum/mutation_upgrade/shell/no_end/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Endure can be used in critical. It now costs [PERCENT(1 + plasma_cost_percentage_increase_initial + (plasma_cost_percentage_increase_per_structure * new_amount))]% of its original plasma cost."

/datum/mutation_upgrade/shell/no_end/on_mutation_enabled()
	var/datum/action/ability/xeno_action/endure/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/endure]
	if(!ability)
		return FALSE
	ability.use_state_flags |= (ABILITY_USE_INCAP|ABILITY_USE_LYING)
	ability.ability_cost += initial(ability.ability_cost) * plasma_cost_percentage_increase_initial
	return ..()

/datum/mutation_upgrade/shell/no_end/on_mutation_disabled()
	var/datum/action/ability/xeno_action/endure/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/endure]
	if(!ability)
		return FALSE
	ability.use_state_flags &= (ABILITY_USE_INCAP|ABILITY_USE_LYING)
	ability.ability_cost -= initial(ability.ability_cost) * plasma_cost_percentage_increase_initial
	return ..()

/datum/mutation_upgrade/shell/no_end/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/xeno_action/endure/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/endure]
	if(!ability)
		return FALSE
	ability.ability_cost += initial(ability.ability_cost) * plasma_cost_percentage_increase_per_structure * (new_amount - previous_amount)

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/early_rage
	name = "Early Rage"
	desc = "Rage can be activated at 55/60/65% instead of 50%. Rage Power's calculation now uses your current health subtracted by 5/10/15% of your maximum health."
	/// For each structure, the percentage to increase both of Rage's activation threshold and Rage Power's calculation.
	var/threshold_increase_per_structure = 0.05

/datum/mutation_upgrade/spur/early_rage/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Rage can be activated at [PERCENT(RAVAGER_RAGE_MIN_HEALTH_THRESHOLD + (threshold_increase_per_structure * new_amount))]% instead of [PERCENT(RAVAGER_RAGE_MIN_HEALTH_THRESHOLD)]%. Rage Power's calculation now uses your current health subtracted by [PERCENT(threshold_increase_per_structure * new_amount)]% of your maximum health."

/datum/mutation_upgrade/spur/early_rage/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/xeno_action/rage/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/rage]
	if(!ability)
		return FALSE
	ability.minimum_health_rage_threshold += threshold_increase_per_structure * (new_amount - previous_amount)
	ability.rage_power_calculation_bonus += threshold_increase_per_structure * (new_amount - previous_amount)

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/safety_trap
	name = "Safety Trap"
	desc = "Endure grants an additional 50/75/100 critical and death threshold. If your health is below your pre-Endure death threshold when it ends, you die instead."
	/// For the first structure, the amount to increase both thresholds for Endure.
	var/threshold_increase_initial = 25
	/// For each structure, the amount to increase both thresholds for Endure.
	var/threshold_increase_per_structure = 25

/datum/mutation_upgrade/veil/safety_trap/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Endure grants an additional [threshold_increase_initial + (threshold_increase_per_structure * new_amount)] critical and death threshold. If your health is below your pre-Endure death threshold when it ends, you die instead."

/datum/mutation_upgrade/veil/safety_trap/on_mutation_enabled()
	var/datum/action/ability/xeno_action/endure/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/endure]
	if(!ability)
		return FALSE
	ability.endure_threshold += threshold_increase_initial
	return ..()

/datum/mutation_upgrade/veil/safety_trap/on_mutation_disabled()
	var/datum/action/ability/xeno_action/endure/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/endure]
	if(!ability)
		return FALSE
	ability.endure_threshold -= threshold_increase_initial
	return ..()

/datum/mutation_upgrade/veil/safety_trap/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/xeno_action/endure/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/endure]
	if(!ability)
		return FALSE
	ability.endure_threshold += threshold_increase_per_structure * (new_amount - previous_amount)
