//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/hardened_travel
	name = "Hardened Travel"
	desc = "Resin Walk now grants 10/15/20 armor in all categories. You cannot regenerate plasma while it is active."
	/// For the first structure, the amount of all armor to increase by.
	var/armor_initial = 5
	/// For each structure, the additional amount of all armor to increase by.
	var/armor_per_structure = 5

/datum/mutation_upgrade/shell/hardened_travel/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Resin Walk now grants [armor_initial + (armor_per_structure * new_amount)] armor in all categories. You cannot regenerate plasma while it is active."

/datum/mutation_upgrade/shell/hardened_travel/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/xeno_action/toggle_speed/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toggle_speed]
	if(!ability)
		return FALSE
	ability.stop_plasma_regeneration = TRUE
	ability.armor_amount += armor_initial
	if(!ability.speed_bonus_active)
		return
	ADD_TRAIT(xenomorph_owner, TRAIT_NOPLASMAREGEN, TRAIT_MUTATION)
	return ..()

/datum/mutation_upgrade/shell/hardened_travel/on_mutation_disabled()
	var/datum/action/ability/xeno_action/toggle_speed/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toggle_speed]
	if(!ability)
		return FALSE
	ability.stop_plasma_regeneration = FALSE
	ability.armor_amount -= armor_initial
	if(!ability.speed_bonus_active)
		return
	REMOVE_TRAIT(xenomorph_owner, TRAIT_NOPLASMAREGEN, TRAIT_MUTATION)
	return ..()

/datum/mutation_upgrade/shell/hardened_travel/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/xeno_action/toggle_speed/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toggle_speed]
	if(!ability)
		return FALSE
	ability.armor_amount += (new_amount - previous_amount) * armor_per_structure
	if(!ability.speed_bonus_active)
		return
	if(ability.attached_armor)
		xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.detachArmor(ability.attached_armor)
		ability.attached_armor = null
	if(ability.armor_amount)
		ability.attached_armor = new()
		ability.attached_armor.modifyAllRatings(ability.armor_amount)
		xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.attachArmor(ability.attached_armor)

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/rejuvenating_build
	name = "Rejuvenating Build"
	desc = "You heal 1/2/3% of your maximum health whenever you successfully use Secrete Resin."
	/// For each structure, the additional percentage of maximum health to heal by.
	var/percentage_per_structure = 0.01

/datum/mutation_upgrade/spur/rejuvenating_build/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "You heal [(percentage_per_structure * new_amount) * 100]% of your maximum health whenever you successfully use Secrete Resin."

/datum/mutation_upgrade/spur/rejuvenating_build/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/secrete_resin/hivelord/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/secrete_resin/hivelord]
	if(!ability)
		return FALSE
	ability.percentage_heal_on_use += (new_amount - previous_amount) * percentage_per_structure

//*********************//
//         Veil        //
//*********************//

/datum/mutation_upgrade/veil/protective_light
	name = "Protective Light"
	desc = "Healing Infusion now also applies the effects of resin jelly for 15s. The plasma cost is now 2x/1.75x/1.5x of the original cost."
	/// The length in deciseconds of the Resin Jelly applied status effect.
	var/resin_jelly_length = 15 SECONDS
	/// For the first structure, the multiplier to increase plasma cost by.
	var/plasma_multiplier_initial = 1.25
	/// For each structure, the additional multiplier to increase plasma cost by.
	var/plasma_multiplier_per_structure = -0.25

/datum/mutation_upgrade/veil/protective_light/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Healing Infusion now also applies the effects of resin jelly for [resin_jelly_length / 10] seconds. The plasma cost is now [1 + plasma_multiplier_initial + (plasma_multiplier_per_structure * new_amount)]x of the original cost."

/datum/mutation_upgrade/veil/protective_light/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/healing_infusion/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/healing_infusion]
	if(!ability)
		return FALSE
	ability.resin_jelly_duration += resin_jelly_length
	ability.ability_cost += initial(ability.ability_cost) * plasma_multiplier_initial
	return ..()

/datum/mutation_upgrade/veil/protective_light/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/healing_infusion/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/healing_infusion]
	if(!ability)
		return FALSE
	ability.resin_jelly_duration -= resin_jelly_length
	ability.ability_cost -= initial(ability.ability_cost) * plasma_multiplier_initial
	return ..()

/datum/mutation_upgrade/veil/protective_light/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/healing_infusion/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/healing_infusion]
	if(!ability)
		return FALSE
	ability.ability_cost += (new_amount - previous_amount) * plasma_multiplier_per_structure
	ability.name = "[initial(ability.name)] ([ability.ability_cost])"
	ability.update_button_icon()
