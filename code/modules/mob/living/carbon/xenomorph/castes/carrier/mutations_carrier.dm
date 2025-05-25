//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/shared_jelly
	name = "Shared Jelly"
	desc = "If you are under the effect of resin jelly, all thrown huggers gain fire immunity. Each thrown hugger reduce the duration of the effect by 3/2/1s."

/datum/mutation_upgrade/shell/together_in_claws/on_structure_update(datum/source, previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/throw_hugger/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/throw_hugger]
	if(!ability)
		return FALSE
	ability.fire_immunity_transfer += (new_amount - previous_amount) * 1 SECONDS

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/leapfrog
	name = "Leapfrog"
	desc = "Thrown huggers can now leap 1 tile at a time. All activation times are 0.8/0.7/0.6x of their original value, but will never be faster than 0.5s."
	/// The leap range modified to bring it down to 1. Used to add back range when the mutation is removed.
	var/leap_range_modified = 0
	/// The beginning multiplier to decrease (at zero structures)
	var/beginning_damage_multiplier = 0.1
	/// The additional multiplier to decrease by for each structure.
	var/damage_multiplier_per_structure = 0.1

/datum/mutation_upgrade/spur/leapfrog/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/throw_hugger/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/throw_hugger]
	if(!ability)
		return FALSE
	leap_range_modified = (ability.leapping_range - 1)
	ability.leapping_range -= leap_range_modified
	ability.activation_time_multiplier -= beginning_damage_multiplier
	return ..()

/datum/mutation_upgrade/spur/leapfrog/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/throw_hugger/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/throw_hugger]
	if(!ability)
		return FALSE
	ability.leapping_range += leap_range_modified
	leap_range_modified = 0
	ability.activation_time_multiplier += beginning_damage_multiplier
	return ..()

/datum/mutation_upgrade/spur/leapfrog/on_structure_update(datum/source, previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/throw_hugger/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/throw_hugger]
	if(!ability)
		return FALSE
	ability.activation_time_multiplier -= (new_amount - previous_amount) * damage_multiplier_per_structure

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/oviposition
	name = "Oviposition"
	desc = "Egg Lay now creates eggs with your selected type of hugger inside. It costs 0.5/0.4/0.3x as much plasma and its cooldown is reduced by 50%. You lose the ability, Spawn Huggers."

/datum/mutation_upgrade/veil/life_for_life
	name = "Life for Life"
	desc = "Spawn Facehugger's cooldown is now 3s shorter and costs zero plasma, but causes you to take 50/40/30 damage for each use."
