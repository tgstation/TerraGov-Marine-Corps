//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/zoomies
	name = "Zoomies"
	desc = "Agility gives an additional 0.3/0.6/0.9 more speed, but decreases your armor by an additional 10/20/30."
	/// For each structure, the amount to modify the speed by.
	var/speed_per_structure = -0.3
	/// For each structure, the amount to increase the armor by.
	var/armor_per_structure = -10

/datum/mutation_upgrade/shell/zoomies/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Agility grants an additional [-get_speed(new_amount)] speed, but decreases your armor by an additional [-get_armor(new_amount)]."

/datum/mutation_upgrade/shell/zoomies/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/xeno_action/toggle_agility/agility_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toggle_agility]
	if(!agility_ability)
		return
	agility_ability.speed_modifier += get_speed(new_amount - previous_amount)
	agility_ability.armor_modifier += get_armor(new_amount - previous_amount)
	if(!agility_ability.toggled)
		return
	xenomorph_owner.add_movespeed_modifier(MOVESPEED_ID_WARRIOR_AGILITY, TRUE, 0, NONE, TRUE, agility_ability.speed_modifier) // We override it, so no need to remove first.
	xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.detachArmor(agility_ability.attached_armor)
	agility_ability.attached_armor = new(agility_ability.armor_modifier, agility_ability.armor_modifier, agility_ability.armor_modifier, agility_ability.armor_modifier, agility_ability.armor_modifier, agility_ability.armor_modifier, agility_ability.armor_modifier, agility_ability.armor_modifier)
	xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.attachArmor(agility_ability.attached_armor)

/// Returns the amount that Agility's speed should be modified by.
/datum/mutation_upgrade/shell/zoomies/proc/get_speed(structure_count)
	return speed_per_structure * structure_count

/// Returns the amount that Agility's armor should be modified by.
/datum/mutation_upgrade/shell/zoomies/proc/get_armor(structure_count)
	return armor_per_structure * structure_count

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/enhanced_strength
	name = "Enhanced Strength"
	desc = "Lunge can be activated from 1/2/3 additional tiles away. Fling and Grapple Toss can now sends your target 1/2/3 tiles further."
	/// For each structure, the amount to increase the range by.
	var/range_per_structure = 1

/datum/mutation_upgrade/spur/enhanced_strength/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Lunge can be activated from [get_range(new_amount)] additional tiles away. Fling and Grapple Toss can now sends your target [get_range(new_amount)] tiles further."

/datum/mutation_upgrade/spur/enhanced_strength/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/warrior/lunge/lunge_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/warrior/lunge]
	if(!lunge_ability)
		return
	var/datum/action/ability/activable/xeno/warrior/fling/fling_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/warrior/fling]
	if(!fling_ability)
		return
	var/datum/action/ability/activable/xeno/warrior/grapple_toss/toss_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/warrior/grapple_toss]
	if(!toss_ability)
		return
	lunge_ability.starting_lunge_distance += get_range(new_amount - previous_amount)
	fling_ability.starting_fling_distance += get_range(new_amount - previous_amount)
	toss_ability.starting_toss_distance += get_range(new_amount - previous_amount)

/// Returns the amount that each ability's range should be increased by.
/datum/mutation_upgrade/spur/enhanced_strength/proc/get_range(structure_count)
	return range_per_structure * structure_count

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/friendly_toss
	name = "Friendly Toss"
	desc = "Fling and Grapple Toss's cooldown is set to 40/25/10% of its original cooldown if it was used on allies."
	/// For the first structure, the amount to increase both abilities' cooldown multiplier if it was used on an allied xenomorph.
	var/cooldown_initial = -0.45
	/// For each structure, the amount to reduce increase abilities' cooldown multiplier if it was used on an allied xenomorph.
	var/cooldown_per_structure = -0.15

/datum/mutation_upgrade/veil/friendly_toss/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Fling and Grapple Toss's cooldown is set to [PERCENT(1 + get_cooldown(new_amount))]% of its original cooldown if it was used on allies."

/datum/mutation_upgrade/veil/friendly_toss/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/warrior/fling/fling_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/warrior/fling]
	if(!fling_ability)
		return
	var/datum/action/ability/activable/xeno/warrior/grapple_toss/toss_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/warrior/grapple_toss]
	if(!toss_ability)
		return
	fling_ability.ally_cooldown_multiplier += get_cooldown(0)
	toss_ability.ally_cooldown_multiplier += get_cooldown(0)
	return ..()

/datum/mutation_upgrade/veil/friendly_toss/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/warrior/fling/fling_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/warrior/fling]
	if(!fling_ability)
		return
	var/datum/action/ability/activable/xeno/warrior/grapple_toss/toss_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/warrior/grapple_toss]
	if(!toss_ability)
		return
	fling_ability.ally_cooldown_multiplier -= get_cooldown(0)
	toss_ability.ally_cooldown_multiplier -= get_cooldown(0)
	return ..()

/datum/mutation_upgrade/veil/friendly_toss/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/warrior/fling/fling_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/warrior/fling]
	if(!fling_ability)
		return
	var/datum/action/ability/activable/xeno/warrior/grapple_toss/toss_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/warrior/grapple_toss]
	if(!toss_ability)
		return
	fling_ability.ally_cooldown_multiplier += get_cooldown(new_amount - previous_amount, FALSE)
	toss_ability.ally_cooldown_multiplier += get_cooldown(new_amount - previous_amount, FALSE)

/// Returns the amount to increase both abilities' cooldown multiplier if it was used on an allied xenomorph.
/datum/mutation_upgrade/veil/friendly_toss/proc/get_cooldown(structure_count, include_initial = TRUE)
	return (include_initial ? cooldown_initial : 0) + (cooldown_per_structure * structure_count)
