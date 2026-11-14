//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/zoomies
	name = "Zoomies"
	desc = "Agility gives an additional 0.6 more speed, but decreases your armor by an additional 20."
	/// The amount to modify the speed by.
	var/speed_change = -0.6 // Negative = faster. Positive = slower.
	/// The amount to modify the armor by.
	var/armor_change = -20

/datum/mutation_upgrade/shell/zoomies/on_mutation_enabled()
	var/datum/action/ability/xeno_action/toggle_agility/agility_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toggle_agility]
	if(!agility_ability)
		return
	agility_ability.speed_modifier += speed_change
	agility_ability.armor_modifier += armor_change
	update_speed_armor()

/datum/mutation_upgrade/shell/zoomies/on_mutation_disabled()
	var/datum/action/ability/xeno_action/toggle_agility/agility_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toggle_agility]
	if(!agility_ability)
		return
	agility_ability.speed_modifier -= speed_change
	agility_ability.armor_modifier -= armor_change
	update_speed_armor()

/// Updates the owner's speed and armor if their agility is active.
/datum/mutation_upgrade/shell/zoomies/proc/update_speed_armor()
	var/datum/action/ability/xeno_action/toggle_agility/agility_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toggle_agility]
	if(!agility_ability.toggled)
		return
	xenomorph_owner.add_movespeed_modifier(MOVESPEED_ID_WARRIOR_AGILITY, TRUE, 0, NONE, TRUE, agility_ability.speed_modifier) // We override it, so no need to remove first.
	xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.detachArmor(agility_ability.attached_armor)
	agility_ability.attached_armor = new(agility_ability.armor_modifier, agility_ability.armor_modifier, agility_ability.armor_modifier, agility_ability.armor_modifier, agility_ability.armor_modifier, agility_ability.armor_modifier, agility_ability.armor_modifier, agility_ability.armor_modifier)
	xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.attachArmor(agility_ability.attached_armor)

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/enhanced_strength
	name = "Enhanced Strength"
	desc = "Fling and Grapple Toss can now sends your target 2 tiles further."
	/// The amount to increase the range by.
	var/range = 2

/datum/mutation_upgrade/spur/enhanced_strength/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/warrior/fling/fling_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/warrior/fling]
	if(!fling_ability)
		return
	var/datum/action/ability/activable/xeno/warrior/grapple_toss/toss_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/warrior/grapple_toss]
	if(!toss_ability)
		return
	fling_ability.starting_fling_distance += range
	toss_ability.starting_toss_distance += range

/datum/mutation_upgrade/spur/enhanced_strength/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/warrior/fling/fling_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/warrior/fling]
	if(!fling_ability)
		return
	var/datum/action/ability/activable/xeno/warrior/grapple_toss/toss_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/warrior/grapple_toss]
	if(!toss_ability)
		return
	fling_ability.starting_fling_distance -= range
	toss_ability.starting_toss_distance -= range

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/friendly_toss
	name = "Friendly Toss"
	desc = "Fling and Grapple Toss's cooldown is set to 25% of its original cooldown if it was used on allies."
	/// The amount to increase both abilities' cooldown multiplier if it was used on an allied xenomorph.
	var/cooldown_multiplier = -0.75

/datum/mutation_upgrade/veil/friendly_toss/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/warrior/fling/fling_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/warrior/fling]
	if(!fling_ability)
		return
	var/datum/action/ability/activable/xeno/warrior/grapple_toss/toss_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/warrior/grapple_toss]
	if(!toss_ability)
		return
	fling_ability.ally_cooldown_multiplier += cooldown_multiplier
	toss_ability.ally_cooldown_multiplier += cooldown_multiplier

/datum/mutation_upgrade/veil/friendly_toss/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/warrior/fling/fling_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/warrior/fling]
	if(!fling_ability)
		return
	var/datum/action/ability/activable/xeno/warrior/grapple_toss/toss_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/warrior/grapple_toss]
	if(!toss_ability)
		return
	fling_ability.ally_cooldown_multiplier -= cooldown_multiplier
	toss_ability.ally_cooldown_multiplier -= cooldown_multiplier
