//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/advance_away
	name = "Advance Away"
	desc = "Upon using Advance, you move -0.2 faster for 6 seconds."
	/// The amount to apply as a movement speed modifier. Positive is slower. Negative is faster.
	var/speed = -0.2

/datum/mutation_upgrade/shell/advance_away/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/oppressor/advance/advance_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/oppressor/advance]
	if(!advance_ability)
		return
	advance_ability.movement_speed_modifier += speed

/datum/mutation_upgrade/shell/advance_away/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/oppressor/advance/advance_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/oppressor/advance]
	if(!advance_ability)
		return
	advance_ability.movement_speed_modifier -= speed

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/wall_bang
	name = "Wall Bang"
	desc = "Dislocate, Advance, and Tail Lash now causes thrown humans that hit a wall to take damage equal to 75% of your slash damage."
	/// The percentage of the owner's slash damage to deal to humans that hit a wall.
	var/percentage = 0.75

/datum/mutation_upgrade/spur/wall_bang/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/oppressor/dislocate/dislocate_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/oppressor/dislocate]
	if(!dislocate_ability)
		return
	var/datum/action/ability/activable/xeno/oppressor/tail_lash/tail_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/oppressor/tail_lash]
	if(!tail_ability)
		return
	var/datum/action/ability/activable/xeno/oppressor/advance/advance_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/oppressor/advance]
	if(!advance_ability)
		return
	dislocate_ability.wallbang_multiplier += percentage
	tail_ability.wallbang_multiplier += percentage
	advance_ability.wallbang_multiplier += percentage

/datum/mutation_upgrade/spur/wall_bang/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/oppressor/dislocate/dislocate_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/oppressor/dislocate]
	if(!dislocate_ability)
		return
	var/datum/action/ability/activable/xeno/oppressor/tail_lash/tail_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/oppressor/tail_lash]
	if(!tail_ability)
		return
	var/datum/action/ability/activable/xeno/oppressor/advance/advance_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/oppressor/advance]
	if(!advance_ability)
		return
	dislocate_ability.wallbang_multiplier -= percentage
	tail_ability.wallbang_multiplier -= percentage
	advance_ability.wallbang_multiplier -= percentage

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/low_charge
	name = "Low Charge"
	desc = "Advance's cast time is 50% of its original value, but it stuns for half as long and flings humans away half the distance."
	/// The multiplier of Advance's initial cast time to add to it.
	var/multiplier = -0.5

/datum/mutation_upgrade/veil/low_charge/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/activable/xeno/oppressor/advance/advance_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/oppressor/advance]
	if(!advance_ability)
		return
	advance_ability.cast_time += initial(advance_ability.cast_time) * multiplier
	advance_ability.throw_range /= 2
	advance_ability.paralyze_duration /= 2

/datum/mutation_upgrade/veil/low_charge/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/oppressor/advance/advance_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/oppressor/advance]
	if(!advance_ability)
		return
	advance_ability.cast_time -= initial(advance_ability.cast_time) * multiplier
	advance_ability.throw_range *= 2
	advance_ability.paralyze_duration *= 2
