//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/stone_armor
	name = "Stone Armor"
	desc = "Allies that are in range of Petrify are granted 10 armor for the duration of it."
	/// The amount of armor to grant to viewing xenomorphs during Petrify.
	var/armor = 10

/datum/mutation_upgrade/shell/stone_armor/on_mutation_enabled()
	var/datum/action/ability/xeno_action/petrify/petrify_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/petrify]
	if(!petrify_ability)
		return
	petrify_ability.petrify_armor += armor

/datum/mutation_upgrade/shell/stone_armor/on_mutation_disabled()
	var/datum/action/ability/xeno_action/petrify/petrify_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/petrify]
	if(!petrify_ability)
		return
	petrify_ability.petrify_armor -= armor

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/minion_king
	name = "Minion King"
	desc = "Psychic Summon only affects minions. Once Psychic Summon is completed, the summoned gain a 10% melee damage increase for 30 seconds."
	/// The flat amount to increase the melee damage multiplier that Psychic Summon gives to the summoned.
	var/amount = 0.1

/datum/mutation_upgrade/spur/minion_king/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/xeno_action/psychic_summon/summon_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/psychic_summon]
	if(!summon_ability)
		return
	summon_ability.minions_only = TRUE
	summon_ability.flat_damage_multiplier += amount

/datum/mutation_upgrade/spur/minion_king/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/xeno_action/psychic_summon/summon_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/psychic_summon]
	if(!summon_ability)
		return
	summon_ability.minions_only = initial(summon_ability.minions_only)
	summon_ability.flat_damage_multiplier -= amount

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/widefall
	name = "Widefall"
	desc = "Nightfall's range is increased by 2 tiles and its cooldown is increased by 10 seconds."
	/// The amount of deciseconds to increase Nightfall's cooldown by.
	var/cooldown_increase = 10 SECONDS
	/// The amount to increase Nightfall's range by.
	var/range_increase = 2

/datum/mutation_upgrade/veil/widefall/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/activable/xeno/nightfall/nightfall_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/nightfall]
	if(!nightfall_ability)
		return
	nightfall_ability.cooldown_duration += cooldown_increase
	nightfall_ability.range += range_increase

/datum/mutation_upgrade/veil/widefall/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/nightfall/nightfall_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/nightfall]
	if(!nightfall_ability)
		return
	nightfall_ability.cooldown_duration -= cooldown_increase
	nightfall_ability.range -= range_increase

/datum/mutation_upgrade/veil/flarefall
	name = "Flarefall"
	desc = "Nightfall's range is decreased by 5 tiles. Nightfall will cause flares in its affected radius to lose 80% of their remaining duration."
	/// The amount to increase Nightfall's range by.
	var/range_increase = -5
	/// The multiplier of a flare's remaining duration to increase by if it was affected by Nightfall.
	var/flare_fuel_multiplier = -0.8

/datum/mutation_upgrade/veil/flarefall/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/activable/xeno/nightfall/nightfall_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/nightfall]
	if(!nightfall_ability)
		return
	nightfall_ability.range += range_increase
	nightfall_ability.flare_fuel_multiplier += flare_fuel_multiplier

/datum/mutation_upgrade/veil/flarefall/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/nightfall/nightfall_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/nightfall]
	if(!nightfall_ability)
		return
	nightfall_ability.range -= range_increase
	nightfall_ability.flare_fuel_multiplier -= flare_fuel_multiplier
