//*********************//
//        Shell        //
//*********************//

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/circular_acid
	name = "Circular Acid"
	desc = "Acid Spray now creates acid in a circle around you in a radius of 2/3/4 tiles."
	/// For each structure, the additional range to increase the circular Acid Spray by.
	var/range_initial = 1
	/// For each structure, the additional range to increase the circular Acid Spray by.
	var/range_per_structure = 1

/datum/mutation_upgrade/spur/circular_acid/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Acid Spray now creates acid in a circle around you in a radius of [range_initial + (range_per_structure * new_amount)] tiles."

/datum/mutation_upgrade/spur/circular_acid/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/spray_acid/cone/cone_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/spray_acid/cone]
	if(cone_ability)
		cone_ability.remove_action(xenomorph_owner)
	var/datum/action/ability/activable/xeno/spray_acid/cone/circle/circle_ability = new()
	circle_ability.give_action(xenomorph_owner)
	circle_ability.range += range_initial
	return ..()

/datum/mutation_upgrade/spur/circular_acid/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/spray_acid/cone/circle/circle_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/spray_acid/cone/circle]
	if(circle_ability)
		circle_ability.remove_action(xenomorph_owner)
	var/datum/action/ability/activable/xeno/spray_acid/cone/cone_ability = new()
	cone_ability.give_action(xenomorph_owner)
	return ..()

/datum/mutation_upgrade/spur/circular_acid/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/spray_acid/cone/circle/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/spray_acid/cone/circle]
	if(!ability)
		return
	ability.range += (new_amount - previous_amount) * range_per_structure

/datum/mutation_upgrade/spur/circular_acid/on_xenomorph_upgrade()
	var/datum/action/ability/activable/xeno/spray_acid/cone/cone_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/spray_acid/cone]
	if(cone_ability)
		cone_ability.remove_action(xenomorph_owner)
	var/datum/action/ability/activable/xeno/spray_acid/cone/circle/circle_ability = new()
	circle_ability.give_action(xenomorph_owner)
	circle_ability.range += range_initial + (range_per_structure * get_total_structures())

//*********************//
//         Veil        //
//*********************//
