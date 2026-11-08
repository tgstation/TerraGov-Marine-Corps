//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/stone_armor
	name = "Stone Armor"
	desc = "Allies that are in range of Petrify are granted 5/10/15 armor for the duration of it."
	/// For each structure, the amount of armor to grant to viewing xenomorphs during Petrify.
	var/armor_per_structure = 5

/datum/mutation_upgrade/shell/stone_armor/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Allies that are in range of Petrify are granted [get_armor(new_amount)] armor for the duration of it."

/datum/mutation_upgrade/shell/stone_armor/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/xeno_action/petrify/petrify_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/petrify]
	if(!petrify_ability)
		return
	petrify_ability.petrify_armor += get_armor(new_amount - previous_amount)

/// Returns the amount of armor to grant to viewing xenomorphs during Petrify.
/datum/mutation_upgrade/shell/stone_armor/proc/get_armor(structure_count)
	return armor_per_structure * structure_count

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/minion_king
	name = "Minion King"
	desc = "Psychic Summon only affects minions. Once Psychic Summon is completed, the summoned gain a 0/10/20% melee damage increase for 30 seconds."
	/// For the first structure, the flat amount to increase the melee damage multiplier that Psychic Summon gives to the summoned.
	var/amount_initial = -0.1
	/// For each structure, the flat amount to increase the melee damage multiplier that Psychic Summon gives to the summoned.
	var/amount_per_structure = 0.1

/datum/mutation_upgrade/spur/minion_king/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Psychic Summon only affects minions. Upon summon completion, the summoned gain a [PERCENT(get_amount(new_amount))]% melee damage increase for 30 seconds."

/datum/mutation_upgrade/spur/minion_king/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/xeno_action/psychic_summon/summon_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/psychic_summon]
	if(!summon_ability)
		return
	summon_ability.minions_only = TRUE
	summon_ability.flat_damage_multiplier += get_amount(0)

/datum/mutation_upgrade/spur/minion_king/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/xeno_action/psychic_summon/summon_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/psychic_summon]
	if(!summon_ability)
		return
	summon_ability.minions_only = initial(summon_ability.minions_only)
	summon_ability.flat_damage_multiplier -= get_amount(0)

/datum/mutation_upgrade/spur/minion_king/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/xeno_action/psychic_summon/summon_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/psychic_summon]
	if(!summon_ability)
		return
	summon_ability.flat_damage_multiplier += get_amount(new_amount - previous_amount, FALSE)

/// Returns the flat amount to increase the melee damage multiplier that Psychic Summon gives to the summoned.
/datum/mutation_upgrade/spur/minion_king/proc/get_amount(structure_count, include_initial = TRUE)
	return (include_initial ? amount_initial : 0) + (amount_per_structure * structure_count)

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/widefall
	name = "Widefall"
	desc = "Nightfall's range is increased by 1/2/3 tiles and its cooldown is increased by 10 seconds."
	/// For the first structure, the amount of deciseconds to increase Nightfall's cooldown by.
	var/cooldown_initial = 10 SECONDS
	/// For each structure, the amount to increase Nightfall's range by.
	var/range_per_structure = 1

/datum/mutation_upgrade/veil/widefall/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Nightfall's range is increased by [get_range(new_amount)] tiles and its cooldown is increased by [cooldown_initial / 10] seconds."

/datum/mutation_upgrade/veil/widefall/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/activable/xeno/nightfall/nightfall_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/nightfall]
	if(!nightfall_ability)
		return
	nightfall_ability.cooldown_duration += cooldown_initial

/datum/mutation_upgrade/veil/widefall/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/nightfall/nightfall_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/nightfall]
	if(!nightfall_ability)
		return
	nightfall_ability.cooldown_duration += cooldown_initial

/datum/mutation_upgrade/veil/widefall/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/nightfall/nightfall_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/nightfall]
	if(!nightfall_ability)
		return
	nightfall_ability.range += get_range(new_amount - previous_amount)

/// Returns amount to increase Nightfall's range by.
/datum/mutation_upgrade/veil/widefall/proc/get_range(structure_count)
	return range_per_structure * structure_count

/datum/mutation_upgrade/veil/flarefall
	name = "Flarefall"
	desc = "Nightfall's range is decreased by 6/5/4 tiles. Nightfall will cause flares in its affected radius to lose 65/80/95% of their remaining duration."
	/// For the first structure, the amount to increase Nightfall's range by.
	var/range_initial = -7
	/// For each structure, the amount to increase Nightfall's range by.
	var/range_per_structure = 1
	/// For the first structure, the multiplier of a flare's remaining duration to increase by if it was affected by Nightfall.
	var/flare_multiplier_initial = -0.5
	/// For each structure, the multiplier of a flare's remaining duration to increase by if it was affected by Nightfall.
	var/flare_multiplier_per_structure = -0.15

/datum/mutation_upgrade/veil/flarefall/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Nightfall's range is decreased by [-get_range(new_amount)] tiles. Nightfall will cause flares in its affected radius to lose [-PERCENT(get_flare_multiplier(new_amount))]% of their remaining duration."

/datum/mutation_upgrade/veil/flarefall/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/activable/xeno/nightfall/nightfall_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/nightfall]
	if(!nightfall_ability)
		return
	nightfall_ability.range += get_range(0)
	nightfall_ability.flare_fuel_multiplier += get_flare_multiplier(0)

/datum/mutation_upgrade/veil/flarefall/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/nightfall/nightfall_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/nightfall]
	if(!nightfall_ability)
		return
	nightfall_ability.range -= get_range(0)
	nightfall_ability.flare_fuel_multiplier -= get_flare_multiplier(0)

/datum/mutation_upgrade/veil/flarefall/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/nightfall/nightfall_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/nightfall]
	if(!nightfall_ability)
		return
	nightfall_ability.range += get_range(new_amount - previous_amount, FALSE)
	nightfall_ability.flare_fuel_multiplier += get_flare_multiplier(new_amount - previous_amount, FALSE)

/// Returns the amount to increase Nightfall's range by.
/datum/mutation_upgrade/veil/flarefall/proc/get_range(structure_count, include_initial = TRUE)
	return (include_initial ? range_initial : 0) + (range_per_structure * structure_count)

/// Returns the multiplier of a flare's remaining duration to increase by if it was affected by Nightfall.
/datum/mutation_upgrade/veil/flarefall/proc/get_flare_multiplier(structure_count, include_initial = TRUE)
	return (include_initial ? flare_multiplier_initial : 0) + (flare_multiplier_per_structure * structure_count)

