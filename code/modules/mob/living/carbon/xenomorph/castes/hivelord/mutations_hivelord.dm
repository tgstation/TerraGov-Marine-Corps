//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/hardened_travel
	name = "Hardened Travel"
	desc = "Resin Walk now grants 10/15/20 armor in all categories. You cannot regenerate plasma while it is active."

/datum/mutation_upgrade/shell/hardened_travel/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/xeno_action/toggle_speed/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toggle_speed]
	if(!ability)
		return FALSE
	ability.stop_plasma_regeneration = TRUE
	ability.armor_amount += 5
	if(!ability.speed_bonus_active)
		return
	ADD_TRAIT(xenomorph_owner, TRAIT_NOPLASMAREGEN, TRAIT_MUTATION)
	return ..()

/datum/mutation_upgrade/shell/hardened_travel/on_mutation_disabled()
	var/datum/action/ability/xeno_action/toggle_speed/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toggle_speed]
	if(!ability)
		return FALSE
	ability.stop_plasma_regeneration = FALSE
	ability.armor_amount -= 5
	if(!ability.speed_bonus_active)
		return
	REMOVE_TRAIT(xenomorph_owner, TRAIT_NOPLASMAREGEN, TRAIT_MUTATION)
	return ..()

/datum/mutation_upgrade/shell/hardened_travel/on_structure_update(datum/source, previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/xeno_action/toggle_speed/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toggle_speed]
	if(!ability)
		return FALSE
	ability.armor_amount += (new_amount - previous_amount) * 5
	if(!ability.speed_bonus_active)
		return
	if(ability.attached_armor)
		xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.detachArmor(ability.attached_armor)
		ability.attached_armor = null
	if(!ability.attached_armor && ability.armor_amount > 0)
		ability.attached_armor = new()
		ability.attached_armor.modifyAllRatings(ability.armor_amount)
		xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.attachArmor(ability.attached_armor)

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/rejuvenating_build
	name = "Rejuvenating Build"
	desc = "You heal 1/2/3% of your maximum health whenever you successfully use Secrete Resin."

/datum/mutation_upgrade/veil/rejuvenating_build/on_structure_update(datum/source, previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/secrete_resin/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/secrete_resin]
	if(!ability)
		return FALSE
	ability.percentage_heal_on_use += (new_amount - previous_amount) * 0.01

//*********************//
//         Veil        //
//*********************//

/datum/mutation_upgrade/veil/protective_light
	name = "Protective Light"
	desc = "Healing Infusion now also applies the effects of resin jelly for 15s. The plasma cost is now 2x/1.75x/1.5x of the original cost."

/datum/mutation_upgrade/veil/protective_light/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/healing_infusion/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/healing_infusion]
	if(!ability)
		return FALSE
	ability.resin_jelly_duration += 15 SECONDS
	ability.ability_cost += initial(ability.ability_cost) * 1.25
	return ..()

/datum/mutation_upgrade/veil/protective_light/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/healing_infusion/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/healing_infusion]
	if(!ability)
		return FALSE
	ability.resin_jelly_duration -= 15 SECONDS
	ability.ability_cost -= initial(ability.ability_cost) * 1.25
	return ..()

/datum/mutation_upgrade/veil/protective_light/on_structure_update(datum/source, previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/healing_infusion/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/healing_infusion]
	if(!ability)
		return FALSE
	ability.ability_cost -= (new_amount - previous_amount) * 0.25
