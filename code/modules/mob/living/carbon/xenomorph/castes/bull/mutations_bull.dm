//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/unstoppable
	name = "Unstoppable"
	desc = "Charging will grant you complete stagger immunity if you reach the maximum number of steps minus 2."
	/// The amount of steps below the maximum that needs to be reached in order to gain stagger immunity.
	var/steps = 2

/datum/mutation_upgrade/shell/unstoppable/on_mutation_enabled()
	var/datum/action/ability/xeno_action/ready_charge/bull_charge/charge_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/ready_charge/bull_charge]
	if(!charge_ability)
		return
	charge_ability.stagger_immunity_steps += steps

/datum/mutation_upgrade/shell/unstoppable/on_mutation_disabled()
	var/datum/action/ability/xeno_action/ready_charge/bull_charge/charge_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/ready_charge/bull_charge]
	if(!charge_ability)
		return
	charge_ability.stagger_immunity_steps -= steps

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/speed_demon
	name = "Speed Demon"
	desc = "Charging costs twice as much plasma. The speed multiplier per step is increased by 0.04."
	/// The amount to increase the speed per step.
	var/additional_speed_per_step = 0.04

/datum/mutation_upgrade/spur/speed_demon/on_mutation_enabled()
	var/datum/action/ability/xeno_action/ready_charge/bull_charge/charge_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/ready_charge/bull_charge]
	if(!charge_ability)
		return
	charge_ability.plasma_use_multiplier *= 2
	charge_ability.speed_per_step += additional_speed_per_step

/datum/mutation_upgrade/spur/speed_demon/on_mutation_disabled()
	var/datum/action/ability/xeno_action/ready_charge/bull_charge/charge_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/ready_charge/bull_charge]
	if(!charge_ability)
		return
	charge_ability.plasma_use_multiplier /= 2
	charge_ability.speed_per_step -= additional_speed_per_step

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/railgun
	name = "Railgun"
	desc = "Charge's maximum steps is increased by 8."
	/// The amount to increase the maximum step count by.
	var/steps = 8

/datum/mutation_upgrade/veil/railgun/on_mutation_enabled()
	var/datum/action/ability/xeno_action/ready_charge/bull_charge/charge_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/ready_charge/bull_charge]
	if(!charge_ability)
		return
	charge_ability.max_steps_buildup += steps

/datum/mutation_upgrade/veil/railgun/on_mutation_disabled()
	var/datum/action/ability/xeno_action/ready_charge/bull_charge/charge_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/ready_charge/bull_charge]
	if(!charge_ability)
		return
	charge_ability.max_steps_buildup -= steps
