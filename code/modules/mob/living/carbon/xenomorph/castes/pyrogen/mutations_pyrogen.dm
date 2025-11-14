//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/flame_cloak
	name = "Flame Cloak"
	desc = "If you are ontop of fire, you gain 5/10/15 armor in all categories."
	/// For each structure, the armor that is given for being ontop of any fire.
	var/armor_per_structure = 5
	/// The attached armor that been given, if any.
	var/datum/armor/attached_armor
	/// The fire that granted the armor.
	var/obj/fire/armor_granting_fire

/datum/mutation_upgrade/shell/flame_cloak/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "If you are ontop of fire, you gain [get_armor(new_amount)] in all categories."

/datum/mutation_upgrade/shell/flame_cloak/on_mutation_enabled()
	. = ..()
	RegisterSignal(xenomorph_owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_movement))
	grant_armor(get_fire_in_turf(get_turf(xenomorph_owner)))

/datum/mutation_upgrade/shell/flame_cloak/on_mutation_disabled()
	UnregisterSignal(xenomorph_owner, COMSIG_MOVABLE_MOVED)
	revoke_armor()
	return ..()

/// Grants armor.
/datum/mutation_upgrade/shell/flame_cloak/proc/grant_armor(obj/fire/chosen_fire)
	if(attached_armor || !chosen_fire)
		return
	var/total_armor = get_armor(get_total_structures())
	attached_armor = getArmor(total_armor, total_armor, total_armor, total_armor, total_armor, total_armor, total_armor, total_armor)
	xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.attachArmor(attached_armor)
	set_armor_granting_fire(chosen_fire)

/// Removes armor.
/datum/mutation_upgrade/shell/flame_cloak/proc/revoke_armor()
	if(!attached_armor)
		return
	xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.detachArmor(attached_armor)
	attached_armor = null
	set_armor_granting_fire()

/// Sets signals for the chosen fire.
/datum/mutation_upgrade/shell/flame_cloak/proc/set_armor_granting_fire(obj/fire/chosen_fire)
	if(armor_granting_fire)
		UnregisterSignal(armor_granting_fire, COMSIG_QDELETING, PROC_REF(on_fire_qdel))
		armor_granting_fire = null
	if(chosen_fire)
		armor_granting_fire = chosen_fire
		RegisterSignal(armor_granting_fire, COMSIG_QDELETING, PROC_REF(on_fire_qdel))

/// Gets the longest lasting fire on a turf.
/datum/mutation_upgrade/shell/flame_cloak/proc/get_fire_in_turf(turf/turf_to_search)
	var/obj/fire/longest_lasting_fire
	for(var/obj/fire/fire_in_turf in turf_to_search)
		if(QDELING(fire_in_turf))
			continue
		if(!longest_lasting_fire)
			longest_lasting_fire = fire_in_turf
			continue
		var/current_duration = longest_lasting_fire.burn_ticks / max(1, longest_lasting_fire.burn_decay)
		var/opposing_duration = fire_in_turf.burn_ticks / max(1, fire_in_turf.burn_decay)
		if(current_duration >= opposing_duration)
			continue
		longest_lasting_fire = fire_in_turf
	return longest_lasting_fire

// Revokes / grant armor based on if their location that has a fire. Assigns a fire that will basically re-proc this if it is deleted.
/datum/mutation_upgrade/shell/flame_cloak/proc/set_armor_adjustingly()
	var/obj/fire/fire_here = get_fire_in_turf(get_turf(xenomorph_owner))
	if(!attached_armor)
		if(fire_here)
			grant_armor(fire_here)
		return
	if(!fire_here)
		revoke_armor()
		return
	set_armor_granting_fire(fire_here)

/// Called when the owner moves. Functionally revokes or grant armor if there are any fire. If they are already have armor and the new location has fire, assigns a new fire.
/datum/mutation_upgrade/shell/flame_cloak/proc/on_movement(datum/source, atom/old_loc, movement_dir, forced, list/old_locs)
	SIGNAL_HANDLER
	set_armor_adjustingly()

/// Called when the fire associated with the armor is deleted. Functionally revokes armor if fire is not found. Otherwise, assigns a new fire.
/datum/mutation_upgrade/shell/flame_cloak/proc/on_fire_qdel(datum/source, atom/old_loc, movement_dir, forced, list/old_locs)
	SIGNAL_HANDLER
	set_armor_adjustingly()

/// Returns the amount of armor that should be given for being on the same turf as fire.
/datum/mutation_upgrade/shell/flame_cloak/proc/get_armor(structure_count)
	return armor_per_structure * structure_count

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/only_fire
	name = "Only Fire"
	desc = "Fire Charge deals no damage, does not consume melting fire stacks, and now pierces humans. Humans who are hit get 2/4/6 melting fire stacks."
	/// For each structure, the additional melting fire stacks to apply.
	var/stacks_per_structure = 2

/datum/mutation_upgrade/spur/only_fire/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Fire Charge deals no damage, does not consume melting fire stacks, and pierces humans. Humans who are hit get [stacks_per_structure * new_amount] melting fire stacks."

/datum/mutation_upgrade/spur/only_fire/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/charge/fire_charge/charge_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/charge/fire_charge]
	if(!charge_ability)
		return
	charge_ability.should_slash = FALSE
	charge_ability.charge_damage -= initial(charge_ability.charge_damage)
	charge_ability.stack_damage -= initial(charge_ability.stack_damage)
	charge_ability.pierces_mobs = TRUE
	return ..()

/datum/mutation_upgrade/spur/only_fire/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/charge/fire_charge/charge_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/charge/fire_charge]
	if(!charge_ability)
		return
	charge_ability.should_slash = initial(charge_ability.should_slash)
	charge_ability.charge_damage += initial(charge_ability.charge_damage)
	charge_ability.stack_damage += initial(charge_ability.stack_damage)
	charge_ability.pierces_mobs = initial(charge_ability.pierces_mobs)
	return ..()

/datum/mutation_upgrade/spur/only_fire/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/charge/fire_charge/charge_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/charge/fire_charge]
	if(!charge_ability)
		return FALSE
	charge_ability.stacks_to_add += get_stacks(new_amount - previous_amount)

/// Returns the amount of melting fire stacks that Fire Charge should inflict.
/datum/mutation_upgrade/spur/only_fire/proc/get_stacks(structure_count)
	return stacks_per_structure * structure_count

//*********************//
//         Veil        //
//*********************//

/datum/mutation_upgrade/veil/burnt_wounds
	name = "Burnt Wounds"
	desc = "Melting fire stacks you inflict causes 15/25/35% healing reduction against brute and burn."
	/// For the first structure, the percentage in which those inflicted with Melting Fire stacks will have their brute/burn healing reduced by.
	var/percentage_initial = 0.05
	/// For each structure, the percentage in which those inflicted with Melting Fire stacks will have their brute/burn healing reduced by.
	var/percentage_per_structure = 0.1

/datum/mutation_upgrade/veil/burnt_wounds/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Melting fire stacks you inflict cause [PERCENT(get_percentage(new_amount))]% healing reduction against brute and burn."

/datum/mutation_upgrade/veil/burnt_wounds/on_mutation_enabled()
	if(!isxenopyrogen(xenomorph_owner))
		return
	var/mob/living/carbon/xenomorph/pyrogen/pyrogen_owner = xenomorph_owner
	pyrogen_owner.melting_fire_healing_reduction += get_percentage(0)
	return ..()

/datum/mutation_upgrade/veil/burnt_wounds/on_mutation_disabled()
	if(!isxenopyrogen(xenomorph_owner))
		return
	var/mob/living/carbon/xenomorph/pyrogen/pyrogen_owner = xenomorph_owner
	pyrogen_owner.melting_fire_healing_reduction -= get_percentage(0)
	return ..()

/datum/mutation_upgrade/veil/burnt_wounds/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!isxenopyrogen(xenomorph_owner))
		return
	var/mob/living/carbon/xenomorph/pyrogen/pyrogen_owner = xenomorph_owner
	pyrogen_owner.melting_fire_healing_reduction += get_percentage(new_amount - previous_amount, FALSE)

/// Returns the percentage in which those inflicted with Melting Fire stacks will have their brute/burn healing reduced by.
/datum/mutation_upgrade/veil/burnt_wounds/proc/get_percentage(structure_count, include_initial = TRUE)
	return (include_initial ? percentage_initial : 0) + (percentage_per_structure * structure_count)
