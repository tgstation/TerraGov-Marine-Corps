//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/gaseous_trail
	name = "Gaseous Trail"
	desc = "Acid Dash leaves a trail of opaque gas behind you. The gas lasts for 4 seconds."
	/// The duration in deciseconds that the gas from Acid Dash will last.
	var/gas_duration = 4 SECONDS

/datum/mutation_upgrade/shell/gaseous_trail/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/charge/acid_dash/dash_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/charge/acid_dash]
	if(!dash_ability)
		return
	dash_ability.gas_trail_duration += gas_duration

/datum/mutation_upgrade/shell/gaseous_trail/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/charge/acid_dash/dash_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/charge/acid_dash]
	if(!dash_ability)
		return
	dash_ability.gas_trail_duration -= gas_duration

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/neurotoxin_swap
	name = "Neurotoxin Swap"
	desc = "Smokescreen Spit does stamina damage and emits Neurotoxin instead. Smokescreen Spit's plasma cost is 150% of its original cost."
	/// The multiplier of Smokescreen Spit's initial ability cost to add.
	var/multiplier = 0.5
	/// The ammo type used to replace Smokescreen Spit with.
	var/datum/ammo/xeno/smokescreen_spit_ammotype = /datum/ammo/xeno/acid/smokescreen/neurotoxin

/datum/mutation_upgrade/spur/neurotoxin_swap/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/smokescreen_spit/smokescreen_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/smokescreen_spit]
	if(!smokescreen_ability)
		return
	smokescreen_ability.ammo_type = smokescreen_spit_ammotype
	smokescreen_ability.ability_cost += initial(smokescreen_ability.ability_cost) * multiplier

/datum/mutation_upgrade/spur/neurotoxin_swap/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/smokescreen_spit/smokescreen_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/smokescreen_spit]
	if(!smokescreen_ability)
		return
	smokescreen_ability.ammo_type = initial(smokescreen_ability.ammo_type)
	smokescreen_ability.ability_cost -= initial(smokescreen_ability.ability_cost) * multiplier

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/fast_acid
	name = "Fast Acid"
	desc = "Corrosive Acid is now applied 35% faster."
	/// The percentage to speed up Corrosive Acid by.
	var/speedup = 0.35

/datum/mutation_upgrade/veil/fast_acid/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/corrosive_acid/strong/acid_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/corrosive_acid/strong]
	acid_ability?.acid_speed_multiplier /= (1 + speedup)

/datum/mutation_upgrade/veil/fast_acid/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/corrosive_acid/strong/acid_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/corrosive_acid/strong]
	acid_ability?.acid_speed_multiplier *= (1 + speedup)
