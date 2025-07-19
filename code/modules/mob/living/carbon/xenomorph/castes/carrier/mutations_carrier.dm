//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/shared_jelly
	name = "Shared Jelly"
	desc = "If you are under the effect of Resin Jelly, all thrown huggers gain fire immunity. Each thrown hugger reduce the duration of the effect by 3/2/1 seconds."
	/// For the first structure, the length in deciseconds that Throw Facehugger will decrease the owner's Resin Jelly Coating status effect by.
	var/length_initial = 4 SECONDS
	/// For each structure, the length in deciseconds that Throw Facehugger will decrease the owner's Resin Jelly Coating status effect by.
	var/length_per_structure = -1 SECONDS

/datum/mutation_upgrade/shell/shared_jelly/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "If you are under the effect of Resin Jelly, all thrown huggers gain fire immunity. Each thrown hugger reduce the duration of the effect by [get_length(new_amount) / 10] seconds."

/datum/mutation_upgrade/shell/shared_jelly/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/throw_hugger/hugger_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/throw_hugger]
	if(!hugger_ability)
		return
	hugger_ability.fire_immunity_transfer += get_length(0)
	return ..()

/datum/mutation_upgrade/shell/shared_jelly/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/throw_hugger/hugger_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/throw_hugger]
	if(!hugger_ability)
		return
	hugger_ability.fire_immunity_transfer -= get_length(0)

/datum/mutation_upgrade/shell/shared_jelly/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/throw_hugger/hugger_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/throw_hugger]
	if(!hugger_ability)
		return
	hugger_ability.fire_immunity_transfer += get_length(new_amount - previous_amount, FALSE)

/// Returns the length in deciseconds that Throw Facehugger will decrease the owner's Resin Jelly Coating status effect by.
/datum/mutation_upgrade/shell/shared_jelly/proc/get_length(structure_count, include_initial = TRUE)
	return (include_initial ? length_initial : 0) + (length_per_structure * structure_count)

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/leapfrog
	name = "Leapfrog"
	desc = "Thrown huggers can now leap 1 tile at a time. All activation times are 0.8/0.7/0.6x of their original value, but will never be faster than 0.5s."
	/// The leap range modified to bring it down to 1. This is used to add back range if the mutation is removed.
	var/leap_range_modified = 0
	/// For the first structure, the multiplier to add towards the various activation times that thrown facehuggers via Throw Facehugger will have.
	var/multiplier_initial = -0.1
	/// For each structure, the multiplier to add towards the various activation times that thrown facehuggers via Throw Facehugger will have.
	var/multiplier_per_structure = -0.1

/datum/mutation_upgrade/spur/leapfrog/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Thrown huggers can now leap 1 tile at a time. All activation times are [1 + get_multiplier(new_amount)]x of their original value, but will never be faster than 0.5s."

/datum/mutation_upgrade/spur/leapfrog/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/activable/xeno/throw_hugger/hugger_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/throw_hugger]
	if(!hugger_ability)
		return
	leap_range_modified = (hugger_ability.leapping_range - 1)
	hugger_ability.leapping_range -= leap_range_modified
	hugger_ability.activation_time_multiplier += get_multiplier(0)

/datum/mutation_upgrade/spur/leapfrog/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/throw_hugger/hugger_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/throw_hugger]
	if(!hugger_ability)
		return
	hugger_ability.leapping_range += leap_range_modified
	leap_range_modified = 0
	hugger_ability.activation_time_multiplier -= get_multiplier(0)

/datum/mutation_upgrade/spur/leapfrog/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/throw_hugger/hugger_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/throw_hugger]
	if(!hugger_ability)
		return
	hugger_ability.activation_time_multiplier += get_multiplier(new_amount - previous_amount, FALSE)

/// Returns the multiplier to add towards the various activation times that thrown facehuggers via Throw Facehugger will have.
/datum/mutation_upgrade/spur/leapfrog/proc/get_multiplier(structure_count, include_initial = TRUE)
	return (include_initial ? multiplier_initial : 0) + (multiplier_per_structure * structure_count)

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/oviposition
	name = "Oviposition"
	desc = "Egg Lay now creates eggs with your selected type of hugger inside. The plasma cost is set to 50/40/30% of its their original value and its cooldown is set to 50% of its original value. You lose the ability, Spawn Huggers."
	/// For the first structure, the multiplier that will be added to the ability cost of Egg Lay.
	var/multiplier_initial = -0.4
	/// For each structure, the multiplier that will be added to the ability cost of Egg Lay.
	var/multiplier_per_structure = -0.1

/datum/mutation_upgrade/veil/oviposition/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Egg Lay now creates eggs with your selected type of hugger inside. The plasma cost is set to [PERCENT(1 + get_multiplier(new_amount))]% of its their original value and its cooldown is set to 50% of its original value. You lose the ability, Spawn Huggers."

/datum/mutation_upgrade/veil/oviposition/on_mutation_enabled()
	var/datum/action/ability/xeno_action/lay_egg/egg_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/lay_egg]
	if(!egg_ability)
		return
	var/datum/action/ability/xeno_action/spawn_hugger/spawn_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/spawn_hugger]
	if(spawn_ability)
		spawn_ability.remove_action(xenomorph_owner)
	egg_ability.use_selected_hugger = TRUE
	egg_ability.cooldown_duration -= initial(egg_ability.cooldown_duration) * 0.5
	egg_ability.ability_cost += initial(egg_ability.ability_cost) * get_multiplier(0)
	return ..()

/datum/mutation_upgrade/veil/oviposition/on_mutation_disabled()
	var/datum/action/ability/xeno_action/lay_egg/egg_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/lay_egg]
	if(!egg_ability)
		return
	var/datum/action/ability/xeno_action/spawn_hugger/spawn_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/spawn_hugger]
	if(!spawn_ability)
		spawn_ability = new()
		spawn_ability.give_action(xenomorph_owner)
	egg_ability.use_selected_hugger = initial(egg_ability.use_selected_hugger)
	egg_ability.cooldown_duration += initial(egg_ability.cooldown_duration) * 0.5
	egg_ability.ability_cost -= initial(egg_ability.ability_cost) * get_multiplier(0)
	return ..()

/datum/mutation_upgrade/veil/oviposition/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/xeno_action/lay_egg/egg_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/lay_egg]
	if(!egg_ability)
		return
	egg_ability.ability_cost += initial(egg_ability.ability_cost) * get_multiplier(new_amount - previous_amount, FALSE)

/datum/mutation_upgrade/veil/oviposition/on_xenomorph_upgrade()
	var/datum/action/ability/xeno_action/spawn_hugger/spawn_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/spawn_hugger]
	if(spawn_ability)
		spawn_ability.remove_action(xenomorph_owner)

/// Returns the multiplier that will be added to the ability cost of Egg Lay.
/datum/mutation_upgrade/veil/oviposition/proc/get_multiplier(structure_count, include_initial = TRUE)
	return (include_initial ? multiplier_initial : 0) + (multiplier_per_structure * structure_count)

/datum/mutation_upgrade/veil/life_for_life
	name = "Life for Life"
	desc = "Spawn Facehugger's cooldown is set to 70% of its original value and costs zero plasma, but will deal 50/40/30 true damage to you."
	/// For the first structure, the amount of damage.
	var/damage_initial = 60
	/// For each structure, the additional amount of damage.
	var/damage_per_structure = -10

/datum/mutation_upgrade/veil/life_for_life/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Spawn Facehugger's cooldown is set to 70% of its original value and costs zero plasma, but will deal [get_damage(new_amount)] true damage to you."

/datum/mutation_upgrade/veil/life_for_life/on_mutation_enabled()
	var/datum/action/ability/xeno_action/spawn_hugger/hugger_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/spawn_hugger]
	if(!hugger_ability)
		return FALSE
	hugger_ability.ability_cost -= initial(hugger_ability.ability_cost)
	hugger_ability.cooldown_duration -= initial(hugger_ability.cooldown_duration) * 0.3
	hugger_ability.health_cost += get_damage(0)
	return ..()

/datum/mutation_upgrade/veil/life_for_life/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/xeno_action/spawn_hugger/hugger_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/spawn_hugger]
	if(!hugger_ability)
		return
	hugger_ability.ability_cost += initial(hugger_ability.ability_cost)
	hugger_ability.cooldown_duration += initial(hugger_ability.cooldown_duration) * 0.3
	hugger_ability.health_cost -= get_damage(0)

/datum/mutation_upgrade/veil/life_for_life/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/xeno_action/spawn_hugger/hugger_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/spawn_hugger]
	if(!hugger_ability)
		return
	hugger_ability.health_cost += get_damage(new_amount - previous_amount, FALSE)

/// Returns the multiplier that will be added to the ability cost of Egg Lay.
/datum/mutation_upgrade/veil/life_for_life/proc/get_damage(structure_count, include_initial = TRUE)
	return (include_initial ? damage_initial : 0) + (damage_per_structure * structure_count)
