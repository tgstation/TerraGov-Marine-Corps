//*********************//
//        Shell        //
//*********************//

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/minion_king
	name = "Minion King"
	desc = "Psychic Summon only affects minions. Upon summon completion, the summoned gain a 0/10/20% melee damage increase for 30 seconds."
	/// For the first structure, the amount of melee damage multiplier to add to summoned xenomorphs.
	var/melee_damage_multiplier_initial = -0.1
	/// For each structure, the additional amount of melee damage multiplier to add to summoned xenomorphs.
	var/melee_damage_multiplier_per_structure = 0.1

/datum/mutation_upgrade/spur/minion_king/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Psychic Summon only affects minions. Upon summon completion, the summoned gain a [PERCENT(melee_damage_multiplier_initial + (melee_damage_multiplier_per_structure * new_amount))]% melee damage increase for 30 seconds."

/datum/mutation_upgrade/spur/minion_king/on_mutation_enabled()
	var/datum/action/ability/xeno_action/psychic_summon/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/psychic_summon]
	if(!ability)
		return FALSE
	ability.minions_only = TRUE
	ability.damage_multiplier_boost += melee_damage_multiplier_initial
	return ..()

/datum/mutation_upgrade/spur/minion_king/on_mutation_disabled()
	var/datum/action/ability/xeno_action/psychic_summon/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/psychic_summon]
	if(!ability)
		return FALSE
	ability.minions_only = initial(ability.minions_only)
	ability.damage_multiplier_boost -= melee_damage_multiplier_initial
	return ..()

/datum/mutation_upgrade/spur/minion_king/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/xeno_action/psychic_summon/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/psychic_summon]
	if(!ability)
		return
	ability.damage_multiplier_boost += (new_amount - previous_amount) * melee_damage_multiplier_per_structure

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/widefall
	name = "Widefall"
	desc = "Nightfall's range is increased by 1/2/3 tiles and its cooldown is increased by 10 seconds."
	/// For each structure, the additional range that Nightfall will get.
	var/range_per_structure = 1
	/// The amount of deciseconds to increase Nightfall's cooldown by.
	var/cooldown_increase = 10 SECONDS

/datum/mutation_upgrade/veil/widefall/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Nightfall's range is increased by 1/2/3 tiles and its cooldown is increased by [cooldown_increase / 10] seconds."

/datum/mutation_upgrade/veil/widefall/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/nightfall/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/nightfall]
	if(!ability)
		return FALSE
	ability.cooldown_duration += cooldown_increase
	return ..()

/datum/mutation_upgrade/veil/widefall/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/nightfall/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/nightfall]
	if(!ability)
		return FALSE
	ability.cooldown_duration -= cooldown_increase
	return ..()

/datum/mutation_upgrade/veil/widefall/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/nightfall/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/nightfall]
	if(!ability)
		return
	ability.range += (new_amount - previous_amount) * range_per_structure

/datum/mutation_upgrade/veil/flarefall
	name = "Flarefall"
	desc = "Nightfall's range is decreased by 6/5/4 tiles. Nightfall will cause flares in its affected radius to lose 65/80/95% of their remaining duration."
	/// For the first structure, the range that Nightfall will get.
	var/range_initial = -8
	/// For each structure, the additional range that Nightfall will get.
	var/range_per_structure = 2
	/// For the first structure, the multiplier that Nightfall will use against flares.
	var/flare_multiplier_initial = 0.5
	/// For each structure, the additional multiplier that Nightfall will use against flares.
	var/flare_multiplier_per_structure = -0.15

/datum/mutation_upgrade/veil/flarefall/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Nightfall's range is decreased by [range_initial + (range_per_structure * new_amount)] tiles. Nightfall will cause flares in its affected radius to lose [PERCENT(1 - (flare_multiplier_initial + (flare_multiplier_per_structure * new_amount)))]% of their remaining duration."

/datum/mutation_upgrade/veil/flarefall/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/nightfall/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/nightfall]
	if(!ability)
		return FALSE
	ability.range += range_initial
	ability.flare_fuel_multiplier += flare_multiplier_initial
	return ..()

/datum/mutation_upgrade/veil/flarefall/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/nightfall/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/nightfall]
	if(!ability)
		return FALSE
	ability.range -= range_initial
	ability.flare_fuel_multiplier -= flare_multiplier_initial
	return ..()

/datum/mutation_upgrade/veil/flarefall/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/nightfall/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/nightfall]
	if(!ability)
		return
	ability.range += (new_amount - previous_amount) * range_per_structure
	ability.flare_fuel_multiplier += (new_amount - previous_amount) * flare_multiplier_per_structure


