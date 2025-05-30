//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/shared_jelly
	name = "Shared Jelly"
	desc = "If you are under the effect of Resin Jelly, all thrown huggers gain fire immunity. Each thrown hugger reduce the duration of the effect by 3/2/1 seconds."
	/// For the first structure, the amount of deciseconds to decrease Resin Jelly by.
	var/fire_immunity_transfer_initial = 4 SECONDS
	/// For each structure, the additional amount of deciseconds to decrease Resin Jelly by.
	var/fire_immunity_transfer_per_structure = -1 SECONDS

/datum/mutation_upgrade/shell/shared_jelly/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "If you are under the effect of Resin Jelly, all thrown huggers gain fire immunity. Each thrown hugger reduce the duration of the effect by [fire_immunity_transfer_initial + (fire_immunity_transfer_per_structure * new_amount)] seconds."

/datum/mutation_upgrade/shell/shared_jelly/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/throw_hugger/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/throw_hugger]
	if(!ability)
		return FALSE
	ability.fire_immunity_transfer += fire_immunity_transfer_initial
	return ..()

/datum/mutation_upgrade/shell/shared_jelly/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/throw_hugger/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/throw_hugger]
	if(!ability)
		return FALSE
	ability.fire_immunity_transfer -= fire_immunity_transfer_initial
	return ..()

/datum/mutation_upgrade/shell/shared_jelly/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/throw_hugger/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/throw_hugger]
	if(!ability)
		return FALSE
	ability.fire_immunity_transfer += (new_amount - previous_amount) * fire_immunity_transfer_per_structure

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/leapfrog
	name = "Leapfrog"
	desc = "Thrown huggers can now leap 1 tile at a time. All activation times are 0.8/0.7/0.6x of their original value, but will never be faster than 0.5s."
	/// The leap range modified to bring it down to 1. Used to add back range when the mutation is removed.
	var/leap_range_modified = 0
	/// For the first structure, the amount to decrease from the multiplier of 1.
	var/time_multiplier_initial = 0.1
	/// For each structure, the additional amount to decrease from the multiplier of 1.
	var/time_multiplier_per_structure = 0.1

/datum/mutation_upgrade/spur/leapfrog/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Thrown huggers can now leap 1 tile at a time. All activation times are [1 - (time_multiplier_initial + (time_multiplier_per_structure * new_amount))]x of their original value, but will never be faster than 0.5s."

/datum/mutation_upgrade/spur/leapfrog/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/throw_hugger/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/throw_hugger]
	if(!ability)
		return FALSE
	leap_range_modified = (ability.leapping_range - 1)
	ability.leapping_range -= leap_range_modified
	ability.activation_time_multiplier -= time_multiplier_initial
	return ..()

/datum/mutation_upgrade/spur/leapfrog/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/throw_hugger/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/throw_hugger]
	if(!ability)
		return FALSE
	ability.leapping_range += leap_range_modified
	leap_range_modified = 0
	ability.activation_time_multiplier += time_multiplier_initial
	return ..()

/datum/mutation_upgrade/spur/leapfrog/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/throw_hugger/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/throw_hugger]
	if(!ability)
		return FALSE
	ability.activation_time_multiplier -= (new_amount - previous_amount) * time_multiplier_per_structure

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/oviposition
	name = "Oviposition"
	desc = "Egg Lay now creates eggs with your selected type of hugger inside. It costs 0.5/0.4/0.3x as much plasma and its cooldown is reduced by 50%. You lose the ability, Spawn Huggers."
	/// For the first structure, the percentage to reduce the ability's plasma cost.
	var/percentage_plasma_reduction_initial = 0.4
	/// For each structure, the additional percentage to reduce the ability's plasma cost.
	var/percentage_plasma_reduction_per_structure = 0.1

/datum/mutation_upgrade/veil/oviposition/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Egg Lay now creates eggs with your selected type of hugger inside. It costs [1 - (percentage_plasma_reduction_initial + (percentage_plasma_reduction_per_structure * new_amount))]x as much plasma and its cooldown is reduced by 50%. You lose the ability, Spawn Huggers."

/datum/mutation_upgrade/veil/oviposition/on_mutation_enabled()
	var/datum/action/ability/xeno_action/lay_egg/egg_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/lay_egg]
	if(!egg_ability)
		return FALSE
	var/datum/action/ability/xeno_action/spawn_hugger/spawn_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/spawn_hugger]
	if(spawn_ability)
		spawn_ability.remove_action(xenomorph_owner)
	egg_ability.use_selected_hugger = TRUE
	egg_ability.cooldown_duration /= 2
	egg_ability.ability_cost -= initial(egg_ability.ability_cost) * percentage_plasma_reduction_initial
	return ..()

/datum/mutation_upgrade/veil/oviposition/on_mutation_disabled()
	var/datum/action/ability/xeno_action/lay_egg/egg_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/lay_egg]
	if(!egg_ability)
		return FALSE
	var/datum/action/ability/xeno_action/spawn_hugger/spawn_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/spawn_hugger]
	if(!spawn_ability)
		spawn_ability = new()
		spawn_ability.give_action(xenomorph_owner)
	egg_ability.use_selected_hugger = initial(egg_ability.use_selected_hugger)
	egg_ability.cooldown_duration *= 2
	egg_ability.ability_cost += initial(egg_ability.ability_cost) * percentage_plasma_reduction_initial
	return ..()

/datum/mutation_upgrade/veil/oviposition/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/xeno_action/lay_egg/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/lay_egg]
	if(!ability)
		return FALSE
	ability.ability_cost -= (new_amount - previous_amount) * (initial(ability.ability_cost) * percentage_plasma_reduction_per_structure)

/datum/mutation_upgrade/veil/oviposition/on_xenomorph_upgrade()
	var/datum/action/ability/xeno_action/spawn_hugger/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/spawn_hugger]
	if(ability)
		ability.remove_action(xenomorph_owner)

/datum/mutation_upgrade/veil/life_for_life
	name = "Life for Life"
	desc = "Spawn Facehugger's cooldown is now 30% shorter and costs zero plasma, but causes you to take 50/40/30 true damage for each use."
	/// For the first structure, the amount of damage.
	var/damage_initial = 60
	/// For each structure, the additional amount of damage.
	var/damage_per_structure = -10

/datum/mutation_upgrade/veil/life_for_life/on_mutation_enabled()
	var/datum/action/ability/xeno_action/spawn_hugger/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/spawn_hugger]
	if(!ability)
		return FALSE
	ability.ability_cost -= initial(ability.ability_cost)
	ability.cooldown_duration -= initial(ability.cooldown_duration) * 0.3
	ability.health_cost += damage_initial
	return ..()

/datum/mutation_upgrade/veil/life_for_life/on_mutation_disabled()
	var/datum/action/ability/xeno_action/spawn_hugger/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/spawn_hugger]
	if(!ability)
		return FALSE
	ability.ability_cost += initial(ability.ability_cost)
	ability.cooldown_duration += initial(ability.cooldown_duration) * 0.3
	ability.health_cost -= damage_initial
	return ..()

/datum/mutation_upgrade/veil/life_for_life/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/xeno_action/spawn_hugger/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/spawn_hugger]
	if(!ability)
		return FALSE
	ability.health_cost -= (new_amount - previous_amount) * damage_per_structure
