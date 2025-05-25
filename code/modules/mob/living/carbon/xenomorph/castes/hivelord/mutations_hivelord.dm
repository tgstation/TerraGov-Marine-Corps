//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/hardened_travel
	name = "Hardened Travel"
	desc = "Resin Walk now grants 10/15/20 armor in all categories. You cannot regenerate plasma while it is active."

/datum/mutation_upgrade/shell/costly_travel
	name = "Costly Travel"
	desc = "Resin Walk can be used while staggered and works on non-weed. It costs 5/4/3x as much plasma to move on non-weed."

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/rejuvenating_build
	name = "Rejuvenating Build"
	desc = "You heal 1/2/3% of your maximum health when you place a resin structure."

/datum/mutation_upgrade/spur/draining_touch
	name = "Draining Touch"
	desc = "Your melee attack is now stamina damage. It is reduced by 20/10/0%."

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/plasma_tank
	name = "Plasma Tank"
	desc = "Your plasma regen limit is increased to 0.6/0.7/0.8x."

/datum/mutation_upgrade/veil/protective_light
	name = "Protective Light"
	desc = "Healing Beam now also applies the effects of resin jelly. The plasma cost is now 2x/1.75x/1.5x of the original cost."

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
