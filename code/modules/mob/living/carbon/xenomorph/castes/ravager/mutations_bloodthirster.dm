//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/no_end
	name = "No End"
	desc = "Endure can be used in critical. It now costs 125% of its original plasma cost."
	/// The multiplier to add as Endure's initial ability cost to add to it.
	var/multiplier = 0.25


/datum/mutation_upgrade/shell/no_end/on_mutation_enabled()
	var/datum/action/ability/xeno_action/endure/endure_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/endure]
	if(!endure_ability)
		return
	endure_ability.use_state_flags |= (ABILITY_USE_INCAP|ABILITY_USE_LYING)
	endure_ability.ability_cost += initial(endure_ability.ability_cost) * multiplier

/datum/mutation_upgrade/shell/no_end/on_mutation_disabled()
	var/datum/action/ability/xeno_action/endure/endure_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/endure]
	if(!endure_ability)
		return
	endure_ability.use_state_flags &= ~(ABILITY_USE_INCAP|ABILITY_USE_LYING)
	endure_ability.ability_cost -= initial(endure_ability.ability_cost) * multiplier

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/early_rage
	name = "Early Rage"
	desc = "Rage can be activated at 60% maximum health. For the purposes of calculating rage power, your current health is assumed to reduced by 10% of your maximum health. This cannot go beyond the amount required for Super Rage."
	/// Tthe percentage of maximum health to add to Rage's activation threshold and to its rage power calculation. 1 = 100%, 0.01 = 1%
	var/percentage = 0.1


/datum/mutation_upgrade/spur/early_rage/on_mutation_enabled()
	var/datum/action/ability/xeno_action/rage/rage_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/rage]
	if(!rage_ability)
		return
	rage_ability.minimum_health_rage_threshold += percentage
	rage_ability.rage_power_calculation_bonus += percentage


/datum/mutation_upgrade/spur/early_rage/on_mutation_disabled()
	var/datum/action/ability/xeno_action/rage/rage_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/rage]
	if(!rage_ability)
		return
	rage_ability.minimum_health_rage_threshold -= percentage
	rage_ability.rage_power_calculation_bonus -= percentage

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/safety_trap
	name = "Safety Trap"
	desc = "Endure further decreases your critical and death threshold by 75. If Endure ends while your health is under the default death threshold, you die instead."
	/// The amount to change the death/critical threshold given by Endure while it is active.
	var/threshold_change = -75

/datum/mutation_upgrade/veil/safety_trap/on_mutation_enabled()
	var/datum/action/ability/xeno_action/endure/endure_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/endure]
	if(!endure_ability)
		return
	endure_ability.endure_threshold += threshold_change
	endure_ability.death_beyond_threshold = TRUE

/datum/mutation_upgrade/veil/safety_trap/on_mutation_disabled()
	var/datum/action/ability/xeno_action/endure/endure_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/endure]
	if(!endure_ability)
		return
	endure_ability.endure_threshold -= threshold_change
	endure_ability.death_beyond_threshold = initial(endure_ability.death_beyond_threshold)
