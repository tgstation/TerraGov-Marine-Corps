//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/advance_away
	name = "Advance Away"
	desc = "Upon using Advance, you move -0.1/-0.2/-0.3 faster for 6 seconds."
	/// For each structure, the amount to apply as a movement speed modifier. Positive is slower. Negative is faster.
	var/speed_per_structure = -0.1

/datum/mutation_upgrade/shell/advance_away/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Upon using Advance, you move [get_speed(new_amount)] faster for 6 seconds."

/datum/mutation_upgrade/shell/advance_away/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/oppressor/advance/advance_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/oppressor/advance]
	if(!advance_ability)
		return
	advance_ability.movement_speed_modifier += get_speed(new_amount - previous_amount)

/// Returns the amount to apply as a movement speed modifier. Positive is slower. Negative is faster.
/datum/mutation_upgrade/shell/advance_away/proc/get_speed(structure_count)
	return  speed_per_structure * structure_count

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/wall_bang
	name = "Wall Bang"
	desc = "Dislocate, Advance, and Tail Lash now causes thrown humans that hit a wall to take damage equal to 50/75/100% of your slash damage."
	/// For the first structure, the percentage of the owner's slash damage to deal to humans that hit a wall.
	var/percentage_initial = 0.25
	/// For each structure, the percentage of the owner's slash damage to deal to humans that hit a wall.
	var/percentage_per_structure = 0.25

/datum/mutation_upgrade/spur/wall_bang/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Dislocate, Advance, and Tail Lash now causes thrown humans that hit a wall to take damage equal to [PERCENT(get_percentage(new_amount))]% of your slash damage."

/datum/mutation_upgrade/spur/wall_bang/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/activable/xeno/oppressor/dislocate/dislocate_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/oppressor/dislocate]
	if(!dislocate_ability)
		return
	var/datum/action/ability/activable/xeno/oppressor/tail_lash/tail_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/oppressor/tail_lash]
	if(!tail_ability)
		return
	var/datum/action/ability/activable/xeno/oppressor/advance/advance_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/oppressor/advance]
	if(!advance_ability)
		return
	dislocate_ability.wallbang_multiplier += get_percentage(0)
	tail_ability.wallbang_multiplier += get_percentage(0)
	advance_ability.wallbang_multiplier += get_percentage(0)

/datum/mutation_upgrade/spur/wall_bang/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/oppressor/dislocate/dislocate_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/oppressor/dislocate]
	if(!dislocate_ability)
		return
	var/datum/action/ability/activable/xeno/oppressor/tail_lash/tail_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/oppressor/tail_lash]
	if(!tail_ability)
		return
	var/datum/action/ability/activable/xeno/oppressor/advance/advance_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/oppressor/advance]
	if(!advance_ability)
		return
	dislocate_ability.wallbang_multiplier -= get_percentage(0)
	tail_ability.wallbang_multiplier -= get_percentage(0)
	advance_ability.wallbang_multiplier -= get_percentage(0)

/datum/mutation_upgrade/spur/wall_bang/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/oppressor/dislocate/dislocate_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/oppressor/dislocate]
	if(!dislocate_ability)
		return
	var/datum/action/ability/activable/xeno/oppressor/tail_lash/tail_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/oppressor/tail_lash]
	if(!tail_ability)
		return
	var/datum/action/ability/activable/xeno/oppressor/advance/advance_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/oppressor/advance]
	if(!advance_ability)
		return
	var/amount = get_percentage(new_amount - previous_amount, FALSE)
	dislocate_ability.wallbang_multiplier += amount
	tail_ability.wallbang_multiplier += amount
	advance_ability.wallbang_multiplier += amount

/// Returns the amount to set Spray Acid Circle's range to.
/datum/mutation_upgrade/spur/wall_bang/proc/get_percentage(structure_count, include_initial = TRUE)
	return (include_initial ? percentage_initial : 0) + (percentage_per_structure * structure_count)

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/low_charge
	name = "Low Charge"
	desc = "Advance's cast time is 60/50/40% of its original value, but it stuns for half as long and flings humans away half the distance."
	/// For the first structure, the multiplier of Advance's initial cast time to add to it.
	var/multiplier_initial = -0.3
	/// For each structure, the multiplier of Advance's initial cast time to add to it.
	var/multiplier_per_structure = -0.1

/datum/mutation_upgrade/veil/low_charge/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Advance's cast time is [PERCENT(1 + get_multiplier(new_amount))]% of its original value, but it stuns for half as long and flings humans away half the distance."

/datum/mutation_upgrade/veil/low_charge/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/activable/xeno/oppressor/advance/advance_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/oppressor/advance]
	if(!advance_ability)
		return
	advance_ability.cast_time += initial(advance_ability.cast_time) * get_multiplier(0)
	advance_ability.throw_range /= 2
	advance_ability.paralyze_duration /= 2

/datum/mutation_upgrade/veil/low_charge/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/oppressor/advance/advance_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/oppressor/advance]
	if(!advance_ability)
		return
	advance_ability.cast_time -= initial(advance_ability.cast_time) * get_multiplier(0)
	advance_ability.throw_range *= 2
	advance_ability.paralyze_duration *= 2

/datum/mutation_upgrade/veil/low_charge/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/oppressor/advance/advance_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/oppressor/advance]
	if(!advance_ability)
		return
	advance_ability.cast_time += initial(advance_ability.cast_time) * get_multiplier(new_amount - previous_amount, FALSE)

/// Returns the multiplier of Advance's initial cast time to add to it.
/datum/mutation_upgrade/veil/low_charge/proc/get_multiplier(structure_count, include_initial = TRUE)
	return (include_initial ? multiplier_initial : 0) + (multiplier_per_structure * structure_count)
