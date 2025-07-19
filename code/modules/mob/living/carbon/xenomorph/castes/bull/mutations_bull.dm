//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/unstoppable
	name = "Unstoppable"
	desc = "Charging will grant you complete stagger immunity if you reach the maximum number of steps minus 1/2/3."
	/// For each structure, the amount of steps below the maximum that needs to be reached in order to gain stagger immunity.
	var/step_per_structure = 1

/datum/mutation_upgrade/shell/unstoppable/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Charging will grant you complete stagger immunity if you reach the maximum number of steps minus [get_steps(new_amount)]."

/datum/mutation_upgrade/shell/unstoppable/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/xeno_action/ready_charge/bull_charge/charge_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/ready_charge/bull_charge]
	if(!charge_ability)
		return
	charge_ability.stagger_immunity_steps += (new_amount - previous_amount) * step_per_structure

/// Returns the amount of steps below the maximum that needs to be reached in order to gain stagger immunity.
/datum/mutation_upgrade/shell/unstoppable/proc/get_steps(structure_count)
	return step_per_structure * structure_count

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/speed_demon
	name = "Speed Demon"
	desc = "Charging costs twice as much plasma. The speed multiplier per step is increased by 0.02/0.04/0.06."
	/// For each structure, the additional increase of the speed per step.
	var/speed_per_structure = 0.02

/datum/mutation_upgrade/spur/speed_demon/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Charging costs twice as much plasma. The speed multiplier per step is increased by [get_speed(new_amount)]."

/datum/mutation_upgrade/spur/speed_demon/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/xeno_action/ready_charge/bull_charge/charge_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/ready_charge/bull_charge]
	if(!charge_ability)
		return
	charge_ability.plasma_use_multiplier += initial(charge_ability.plasma_use_multiplier)
	return ..()

/datum/mutation_upgrade/spur/speed_demon/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/xeno_action/ready_charge/bull_charge/charge_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/ready_charge/bull_charge]
	if(!charge_ability)
		return
	charge_ability.plasma_use_multiplier -= initial(charge_ability.plasma_use_multiplier)

/datum/mutation_upgrade/spur/speed_demon/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/xeno_action/ready_charge/bull_charge/charge_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/ready_charge/bull_charge]
	if(!charge_ability)
		return
	charge_ability.speed_per_step += get_speed(new_amount - previous_amount)

/// Returns the amount of additional speed to add per step.
/datum/mutation_upgrade/spur/speed_demon/proc/get_speed(structure_count)
	return speed_per_structure * structure_count

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/railgun
	name = "Railgun"
	desc = "Charge's maximum steps is increased by 4/8/12."
	/// For each structure, the amount of additional steps required to reach maximum charge.
	var/steps_per_structure = 4

/datum/mutation_upgrade/veil/railgun/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Charge's maximum steps is increased by [get_steps(new_amount)]."

/datum/mutation_upgrade/veil/railgun/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/xeno_action/ready_charge/bull_charge/charge_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/ready_charge/bull_charge]
	if(!charge_ability)
		return
	charge_ability.max_steps_buildup += get_steps(new_amount - previous_amount)

/// Returns the amount of additional steps required to reach maximum charge.
/datum/mutation_upgrade/veil/railgun/proc/get_steps(structure_count)
	return steps_per_structure * structure_count
