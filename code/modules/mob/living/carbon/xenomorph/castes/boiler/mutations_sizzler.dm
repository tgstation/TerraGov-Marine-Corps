//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/gaseous_trail
	name = "Gaseous Trail"
	desc = "Steam Rush leaves a trail of opaque gas behind you. The gas lasts for 2/4/6 seconds."
	/// For each structure, the additional amount of deciseconds of the gas.
	var/deciseconds_per_structure = 2 SECONDS

/datum/mutation_upgrade/shell/gaseous_trail/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Steam Rush leaves a trail of opaque gas behind you. The gas lasts for [deciseconds_per_structure * new_amount / 10] seconds."

/datum/mutation_upgrade/shell/gaseous_trail/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/xeno_action/steam_rush/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/steam_rush]
	if(!ability)
		return FALSE
	ability.gas_trail_duration += (new_amount - previous_amount) * deciseconds_per_structure

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/neurotoxin_swap
	name = "Neurotoxin Swap"
	desc = "Smokescreen Spit does stamina damage and emits Neurotoxin instead. Smokescreen Spit costs 2/1.5/1x as much plasma."
	/// For the first structure, the multiplicative amount of the initial plasma cost to add to Smokescreen Spit.
	var/additional_cost_multiplier_initial = 1.5
	/// For each structure, the additional multiplicative amount of the initial plasma cost to add to Smokescreen Spit.
	var/additional_cost_multiplier_per_structure = -0.5
	/// The ammo type used to replace Smokescreen Spit with.
	var/datum/ammo/xeno/smokescreen_spit_ammotype = /datum/ammo/xeno/acid/airburst/heavy/neurotoxin

/datum/mutation_upgrade/spur/neurotoxin_swap/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Smokescreen Spit does stamina damage emits Neurotoxin instead. Smokescreen Spit costs [1 + additional_cost_multiplier_initial + (additional_cost_multiplier_per_structure * new_amount)]x as much plasma."

/datum/mutation_upgrade/spur/neurotoxin_swap/on_mutation_enabled()
	var/datum/action/ability/xeno_action/smokescreen_spit/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/smokescreen_spit]
	if(!ability)
		return FALSE
	ability.ammo_type = smokescreen_spit_ammotype
	ability.ability_cost += initial(ability.ability_cost) * additional_cost_multiplier_initial
	return ..()

/datum/mutation_upgrade/spur/neurotoxin_swap/on_mutation_disabled()
	var/datum/action/ability/xeno_action/smokescreen_spit/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/smokescreen_spit]
	if(!ability)
		return FALSE
	ability.ammo_type = initial(ability.ammo_type)
	ability.ability_cost -= initial(ability.ability_cost) * additional_cost_multiplier_initial
	return ..()

/datum/mutation_upgrade/spur/neurotoxin_swap/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/xeno_action/smokescreen_spit/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/smokescreen_spit]
	if(!ability)
		return FALSE
	ability.ability_cost += initial(ability.ability_cost) * (new_amount - previous_amount) * additional_cost_multiplier_initial

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/fast_acid
	name = "Fast Acid"
	desc = "Corrosive Acid is now applied 20/35/50% faster."
	/// For the first structure, the speedup of applying acid.
	var/speedup_initial = 0.05
	/// For each structure, the additional speedup of applying acid.
	var/speedup_per_structure = 0.15

/datum/mutation_upgrade/veil/fast_acid/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Corrosive Acid is now applied [speedup_initial + (speedup_per_structure * new_amount)]% faster."

/datum/mutation_upgrade/veil/fast_acid/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/corrosive_acid/strong/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/corrosive_acid/strong]
	if(!ability)
		return FALSE
	if(previous_amount)
		ability.acid_speed_multiplier *= (1 + speedup_initial + (previous_amount * speedup_per_structure)) // First, we reverse...
	if(new_amount)
		ability.acid_speed_multiplier /= (1 + speedup_initial + (new_amount * speedup_per_structure)) // ... then we re-apply because math is hard!
