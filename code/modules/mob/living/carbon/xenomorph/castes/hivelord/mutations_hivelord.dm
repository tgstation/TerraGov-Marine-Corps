//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/hardened_travel
	name = "Hardened Travel"
	desc = "Resin Walk now grants 10/15/20 armor in all categories. You cannot regenerate plasma while it is active."

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/rejuvenating_build
	name = "Rejuvenating Build"
	desc = "You heal 1/2/3% of your maximum health when you place a resin structure."

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
