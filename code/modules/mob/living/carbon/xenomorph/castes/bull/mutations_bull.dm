//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/unstoppable
	name = "Unstoppable"
	desc = "Charging will grant you immunity from staggered by projectiles if you reach the maximum number of steps minus 1/2/3."

/datum/mutation_upgrade/shell/unstoppable/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/xeno_action/ready_charge/bull_charge/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/ready_charge/bull_charge]
	if(!ability)
		return FALSE
	ability.stagger_immunity_steps += (new_amount - previous_amount)

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/speed_demon
	name = "Speed Demon"
	desc = "Charging costs twice as much plasma. The speed multiplier per speed is increased by 0.02/0.04/0.06."

/datum/mutation_upgrade/spur/speed_demon/on_mutation_enabled()
	var/datum/action/ability/xeno_action/ready_charge/bull_charge/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/ready_charge/bull_charge]
	if(!ability)
		return FALSE
	ability.plasma_use_multiplier += initial(ability.plasma_use_multiplier)
	return ..()

/datum/mutation_upgrade/spur/speed_demon/on_mutation_disabled()
	var/datum/action/ability/xeno_action/ready_charge/bull_charge/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/ready_charge/bull_charge]
	if(!ability)
		return FALSE
	ability.plasma_use_multiplier -= initial(ability.plasma_use_multiplier)
	return ..()

/datum/mutation_upgrade/spur/speed_demon/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/xeno_action/ready_charge/bull_charge/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/ready_charge/bull_charge]
	if(!ability)
		return FALSE
	ability.speed_per_step += (new_amount - previous_amount) * 0.02

//*********************//
//         Veil        //
//*********************//

/datum/mutation_upgrade/veil/railgun
	name = "Railgun"
	desc = "Charging now takes 4/8/12 more steps to reach maximum charge."
	/// The additional steps for each structure.
	var/steps_per_structure = 4

/datum/mutation_upgrade/veil/railgun/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/xeno_action/ready_charge/bull_charge/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/ready_charge/bull_charge]
	if(!ability)
		return FALSE
	ability.max_steps_buildup += (new_amount - previous_amount) * steps_per_structure

