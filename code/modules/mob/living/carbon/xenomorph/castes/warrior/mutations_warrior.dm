//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/zoomies
	name = "Zoomies"
	desc = "Agility grants 0.3/0.6/0.9 more speed, but decreases your armor by 10/20/30."
	/// For each structure, the additional amount to modify the speed by.
	var/speed_per_structure = -0.3
	/// For each structure, the additional amount to increase the armor by.
	var/armor_per_structure = -10

/datum/mutation_upgrade/shell/zoomies/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Agility grants an additional [speed_per_structure * new_amount * -1] speed, but decreases your armor by [armor_per_structure * new_amount * -1]."

/datum/mutation_upgrade/shell/zoomies/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/xeno_action/toggle_agility/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toggle_agility]
	if(!ability)
		return FALSE
	ability.speed_modifier += (new_amount - previous_amount) * speed_per_structure
	ability.armor_modifier += (new_amount - previous_amount) * armor_per_structure
	if(ability.toggled)
		xenomorph_owner.remove_movespeed_modifier(MOVESPEED_ID_WARRIOR_AGILITY)
		xenomorph_owner.add_movespeed_modifier(MOVESPEED_ID_WARRIOR_AGILITY, TRUE, 0, NONE, TRUE, ability.speed_modifier)
		xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.detachArmor(ability.attached_armor)
		ability.attached_armor = new()
		ability.attached_armor.modifyAllRatings(WARRIOR_AGILITY_ARMOR_MODIFIER)
		xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.attachArmor(ability.attached_armor)

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/enhanced_strength
	name = "Enhanced Strength"
	desc = "Lunge, Fling, Grapple Toss all can go 1/2/3 tiles further."
	/// For each structure, the additional amount to increase the range by.
	var/range_per_structure = 1

/datum/mutation_upgrade/spur/enhanced_strength/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Lunge, Fling, Grapple Toss all can go [range_per_structure * new_amount] tiles further."

/datum/action/ability/activable/xeno/warrior/lunge
/datum/action/ability/activable/xeno/warrior/fling
/datum/action/ability/activable/xeno/warrior/grapple_toss

/datum/mutation_upgrade/spur/enhanced_strength/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/warrior/lunge/lunge_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/warrior/lunge]
	if(!lunge_ability)
		return FALSE
	var/datum/action/ability/activable/xeno/warrior/fling/fling_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/warrior/fling]
	if(!fling_ability)
		return FALSE
	var/datum/action/ability/activable/xeno/warrior/grapple_toss/toss_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/warrior/grapple_toss]
	if(!toss_ability)
		return FALSE
	lunge_ability.starting_lunge_distance += (new_amount - previous_amount) * range_per_structure
	fling_ability.starting_fling_distance += (new_amount - previous_amount) * range_per_structure
	toss_ability.starting_toss_distance += (new_amount - previous_amount) * range_per_structure

//*********************//
//         Veil        //
//*********************//

/datum/mutation_upgrade/spur/friendly_toss
	name = "Friendly Toss"
	desc = "Fling and Grapple Toss's cooldown is reduced by 60/75/90% if it was used on allies."
	/// For the first structure, the percentage of the cooldown to reduce by.
	var/cooldown_reduction_initial = 0.45
	/// For each structure, the additional percentage of the cooldown to reduce by.
	var/cooldown_reduction_per_structure = 0.15

/datum/mutation_upgrade/spur/friendly_toss/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Fling and Grapple Toss's cooldown is reduced by [(cooldown_reduction_initial + (cooldown_reduction_per_structure * new_amount)) * 100]% if it was used on allies."

/datum/mutation_upgrade/spur/friendly_toss/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/warrior/fling/fling_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/warrior/fling]
	if(!fling_ability)
		return FALSE
	var/datum/action/ability/activable/xeno/warrior/grapple_toss/toss_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/warrior/grapple_toss]
	if(!toss_ability)
		return FALSE
	fling_ability.friendly_cooldown_reduction_percentage += cooldown_reduction_initial
	toss_ability.friendly_cooldown_reduction_percentage += cooldown_reduction_initial
	return ..()

/datum/mutation_upgrade/spur/friendly_toss/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/warrior/fling/fling_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/warrior/fling]
	if(!fling_ability)
		return FALSE
	var/datum/action/ability/activable/xeno/warrior/grapple_toss/toss_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/warrior/grapple_toss]
	if(!toss_ability)
		return FALSE
	fling_ability.friendly_cooldown_reduction_percentage -= cooldown_reduction_initial
	toss_ability.friendly_cooldown_reduction_percentage -= cooldown_reduction_initial
	return ..()

/datum/mutation_upgrade/spur/friendly_toss/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/warrior/fling/fling_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/warrior/fling]
	if(!fling_ability)
		return FALSE
	var/datum/action/ability/activable/xeno/warrior/grapple_toss/toss_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/warrior/grapple_toss]
	if(!toss_ability)
		return FALSE
	fling_ability.friendly_cooldown_reduction_percentage += (new_amount - previous_amount) * cooldown_reduction_per_structure
	toss_ability.friendly_cooldown_reduction_percentage += (new_amount - previous_amount) * cooldown_reduction_per_structure
