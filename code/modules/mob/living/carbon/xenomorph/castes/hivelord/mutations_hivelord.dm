//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/hardened_travel
	name = "Hardened Travel"
	desc = "Resin Walk now grants 10/15/20 armor in all categories. You cannot regenerate plasma while it is active."
	/// For the first structure, the amount of armor that Resin Walk should be granting.
	var/armor_initial = 5
	/// For each structure, the amount of armor that Resin Walk should be granting.
	var/armor_per_structure = 5

/datum/mutation_upgrade/shell/hardened_travel/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "While Resin Walk is active, you gain [get_armor(new_amount)] armor in all categories. During this time, you cannot regenerate plasma."

/datum/mutation_upgrade/shell/hardened_travel/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/xeno_action/toggle_speed/speed_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toggle_speed]
	if(!speed_ability)
		return
	speed_ability.set_plasma(FALSE)
	speed_ability.set_armor(speed_ability.armor_amount + get_armor(0))

/datum/mutation_upgrade/shell/hardened_travel/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/xeno_action/toggle_speed/speed_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toggle_speed]
	if(!speed_ability)
		return
	speed_ability.set_plasma(initial(speed_ability.can_plasma_regenerate))
	speed_ability.set_armor(speed_ability.armor_amount - get_armor(0))

/datum/mutation_upgrade/shell/hardened_travel/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/xeno_action/toggle_speed/speed_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toggle_speed]
	if(!speed_ability)
		return
	speed_ability.set_armor(speed_ability.armor_amount + get_armor(new_amount - previous_amount, FALSE))

/// Returns the amount of armor that Resin Walk should be granting.
/datum/mutation_upgrade/shell/hardened_travel/proc/get_armor(structure_count, include_initial = TRUE)
	return (include_initial ? armor_initial : 0) + (armor_per_structure * structure_count)

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/rejuvenating_build
	name = "Rejuvenating Build"
	desc = "You heal 1/2/3% of your maximum health whenever you successfully use Secrete Resin."
	/// For each structure, the percentage of maximum health that will be healed when a structure is built via Secrete Resin.
	var/percentage_per_structure = 0.01

/datum/mutation_upgrade/spur/rejuvenating_build/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "You heal [PERCENT(get_percentage(new_amount))]% of your maximum health whenever you successfully use Secrete Resin."

/datum/mutation_upgrade/spur/rejuvenating_build/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/secrete_resin/hivelord/resin_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/secrete_resin/hivelord]
	if(!resin_ability)
		return
	resin_ability.heal_percentage += get_percentage(new_amount - previous_amount)

/// Returns the percentage of maximum health that will be healed when a structure is built via Secrete Resin.
/datum/mutation_upgrade/spur/rejuvenating_build/proc/get_percentage(structure_count)
	return percentage_per_structure * structure_count

//*********************//
//         Veil        //
//*********************//

/datum/mutation_upgrade/veil/protective_light
	name = "Protective Light"
	desc = "Healing Infusion now also applies the effects of resin jelly for 15 seconds. The plasma cost is now 2x/1.75x/1.5x of the original cost."
	/// For the first structure, the multiplier that will added to the ability cost of Healing Infusion.
	var/multiplier_initial = 1.25
	/// For each structure, the multiplier that will added to the ability cost of Healing Infusion.
	var/multiplier_per_structure = -0.25
	/// The length in deciseconds of the Resin Jelly applied status effect.
	var/resin_jelly_length = 15 SECONDS

/datum/mutation_upgrade/veil/protective_light/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Healing Infusion now also applies the effects of resin jelly for [resin_jelly_length / 10] seconds. The plasma cost is now [1 + get_multiplier(new_amount)]x of the original cost."

/datum/mutation_upgrade/veil/protective_light/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/activable/xeno/healing_infusion/healing_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/healing_infusion]
	if(!healing_ability)
		return
	healing_ability.resin_jelly_duration += resin_jelly_length
	healing_ability.ability_cost += initial(healing_ability.ability_cost) * get_multiplier(0)

/datum/mutation_upgrade/veil/protective_light/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/healing_infusion/healing_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/healing_infusion]
	if(!healing_ability)
		return
	healing_ability.resin_jelly_duration -= resin_jelly_length
	healing_ability.ability_cost -= initial(healing_ability.ability_cost) * get_multiplier(0)

/datum/mutation_upgrade/veil/protective_light/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/healing_infusion/healing_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/healing_infusion]
	if(!healing_ability)
		return
	healing_ability.ability_cost += get_multiplier(new_amount - previous_amount, FALSE)

/// Returns the multiplier that will added to the ability cost of Healing Infusion.
/datum/mutation_upgrade/veil/protective_light/proc/get_multiplier(structure_count, include_initial = TRUE)
	return (include_initial ? multiplier_initial : 0) + (multiplier_per_structure * structure_count)
