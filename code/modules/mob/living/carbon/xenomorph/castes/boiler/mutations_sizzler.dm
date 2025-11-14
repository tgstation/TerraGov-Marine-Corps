//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/gaseous_trail
	name = "Gaseous Trail"
	desc = "Steam Rush leaves a trail of opaque gas behind you. The gas lasts for 2/4/6 seconds."
	/// For each structure, the duration in deciseconds that the gas from Steam Rush will last.
	var/duration_per_structure = 2 SECONDS

/datum/mutation_upgrade/shell/gaseous_trail/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Steam Rush leaves a trail of opaque gas behind you. The gas lasts for [get_duration(new_amount) * 0.1] seconds."

/datum/mutation_upgrade/shell/gaseous_trail/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/xeno_action/steam_rush/rush_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/steam_rush]
	if(!rush_ability)
		return
	var/previous_duration = rush_ability.gas_trail_duration
	rush_ability.gas_trail_duration += get_duration(new_amount - previous_amount)
	if(!rush_ability.active)
		return
	if(previous_duration && !rush_ability.gas_trail_duration)
		rush_ability.UnregisterSignal(rush_ability.xeno_owner, COMSIG_MOVABLE_MOVED)
	if(!previous_duration && rush_ability.gas_trail_duration)
		rush_ability.RegisterSignal(rush_ability.xeno_owner, COMSIG_MOVABLE_MOVED, TYPE_PROC_REF(/datum/action/ability/xeno_action/steam_rush, on_movement))

/// Returns the duration in deciseconds that the gas from Steam Rush will last.
/datum/mutation_upgrade/shell/gaseous_trail/proc/get_duration(structure_count)
	return duration_per_structure * structure_count

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/neurotoxin_swap
	name = "Neurotoxin Swap"
	desc = "Smokescreen Spit does stamina damage and emits Neurotoxin instead. Smokescreen Spit's plasma cost is 200/150/100% of its original cost."
	/// For the first structure, the multiplier to add to Smokescreen Spit's ability cost.
	var/cost_multiplier_initial = 1.5
	/// For each structure, the multiplier to add to Smokescreen Spit's ability cost.
	var/cost_multiplier_per_structure = -0.5
	/// The ammo type used to replace Smokescreen Spit with.
	var/datum/ammo/xeno/smokescreen_spit_ammotype = /datum/ammo/xeno/acid/airburst/heavy/neurotoxin

/datum/mutation_upgrade/spur/neurotoxin_swap/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Smokescreen Spit does stamina damage and emits Neurotoxin instead. Smokescreen Spit's plasma cost is [PERCENT(1 + get_cost_multiplier(new_amount))]% of its original cost."

/datum/mutation_upgrade/spur/neurotoxin_swap/on_mutation_enabled()
	var/datum/action/ability/xeno_action/smokescreen_spit/smokescreen_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/smokescreen_spit]
	if(!smokescreen_ability)
		return
	smokescreen_ability.ammo_type = smokescreen_spit_ammotype
	smokescreen_ability.ability_cost += initial(smokescreen_ability.ability_cost) * get_cost_multiplier(0)
	return ..()

/datum/mutation_upgrade/spur/neurotoxin_swap/on_mutation_disabled()
	var/datum/action/ability/xeno_action/smokescreen_spit/smokescreen_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/smokescreen_spit]
	if(!smokescreen_ability)
		return
	smokescreen_ability.ammo_type = initial(smokescreen_ability.ammo_type)
	smokescreen_ability.ability_cost -= initial(smokescreen_ability.ability_cost) * get_cost_multiplier(0)
	return ..()

/datum/mutation_upgrade/spur/neurotoxin_swap/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/xeno_action/smokescreen_spit/smokescreen_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/smokescreen_spit]
	if(!smokescreen_ability)
		return
	smokescreen_ability.ability_cost += initial(smokescreen_ability.ability_cost) * get_cost_multiplier(new_amount - previous_amount, FALSE)

/// Returns the multiplier to add to Smokescreen Spit's ability cost.
/datum/mutation_upgrade/spur/neurotoxin_swap/proc/get_cost_multiplier(structure_count, include_initial = TRUE)
	return (include_initial ? cost_multiplier_initial : 0) + (cost_multiplier_per_structure * structure_count)

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/fast_acid
	name = "Fast Acid"
	desc = "Corrosive Acid is now applied 20/35/50% faster."
	/// For the first structure, the percentage to speed up Corrosive Acid by.
	var/speedup_initial = 0.05
	/// For each structure, the additional percentage to speed up Corrosive Acid by.
	var/speedup_per_structure = 0.15

/datum/mutation_upgrade/veil/fast_acid/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Corrosive Acid is now applied [PERCENT(get_speedup(new_amount))]% faster."

/datum/mutation_upgrade/veil/fast_acid/on_structure_update(previous_amount, new_amount)
	var/datum/action/ability/activable/xeno/corrosive_acid/strong/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/corrosive_acid/strong]
	if(!ability)
		return
	if(previous_amount)
		ability.acid_speed_multiplier *= 1 + get_speedup(previous_amount) // First, we reverse...
	if(new_amount)
		ability.acid_speed_multiplier /= 1 + get_speedup(new_amount) // ... then we re-apply because math is hard!
	return ..()

/// Returns the percentage used to speed up Corrosive Acid by.
/datum/mutation_upgrade/veil/fast_acid/proc/get_speedup(structure_count)
	return speedup_initial + (speedup_per_structure * structure_count)


