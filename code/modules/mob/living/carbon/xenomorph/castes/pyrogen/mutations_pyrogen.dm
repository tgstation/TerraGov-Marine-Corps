//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/flame_cloak
	name = "Flame Cloak"
	desc = "If you are ontop of fire, you gain 10 armor in all categories."
	/// The armor that is given for being ontop of any fire.
	var/armor = 10
	/// The attached armor that been given, if any.
	var/datum/armor/attached_armor
	/// The fire that granted the armor.
	var/obj/fire/armor_granting_fire

/datum/mutation_upgrade/shell/flame_cloak/on_mutation_enabled()
	RegisterSignal(xenomorph_owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_movement))
	grant_armor(get_fire_in_turf(get_turf(xenomorph_owner)))

/datum/mutation_upgrade/shell/flame_cloak/on_mutation_disabled()
	UnregisterSignal(xenomorph_owner, COMSIG_MOVABLE_MOVED)
	revoke_armor()

/// Grants armor.
/datum/mutation_upgrade/shell/flame_cloak/proc/grant_armor(obj/fire/chosen_fire)
	if(attached_armor || !chosen_fire)
		return
	attached_armor = getArmor(armor, armor, armor, armor, armor, armor, armor, armor)
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

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/only_fire
	name = "Only Fire"
	desc = "Fire Charge deals no damage, does not consume melting fire stacks, and now pierces humans. Humans who are hit get 4 melting fire stacks."
	/// The additional melting fire stacks to apply.
	var/stacks = 4

/datum/mutation_upgrade/spur/only_fire/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/charge/fire_charge/charge_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/charge/fire_charge]
	if(!charge_ability)
		return
	charge_ability.should_slash = FALSE
	charge_ability.charge_damage -= initial(charge_ability.charge_damage)
	charge_ability.stack_damage -= initial(charge_ability.stack_damage)
	charge_ability.pierces_mobs = TRUE
	charge_ability.stacks_to_add += stacks

/datum/mutation_upgrade/spur/only_fire/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/charge/fire_charge/charge_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/charge/fire_charge]
	if(!charge_ability)
		return
	charge_ability.should_slash = initial(charge_ability.should_slash)
	charge_ability.charge_damage += initial(charge_ability.charge_damage)
	charge_ability.stack_damage += initial(charge_ability.stack_damage)
	charge_ability.pierces_mobs = initial(charge_ability.pierces_mobs)
	charge_ability.stacks_to_add -= stacks

//*********************//
//         Veil        //
//*********************//

/datum/mutation_upgrade/veil/burnt_wounds
	name = "Burnt Wounds"
	desc = "Melting fire stacks you inflict causes 25% healing reduction against brute and burn."
	/// The percentage in which those inflicted with Melting Fire stacks will have their brute/burn healing reduced by. 1 = 100%, 0.01 = 1%
	var/percentage = 0.25

/datum/mutation_upgrade/veil/burnt_wounds/on_mutation_enabled()
	if(!isxenopyrogen(xenomorph_owner))
		return
	var/mob/living/carbon/xenomorph/pyrogen/pyrogen_owner = xenomorph_owner
	pyrogen_owner.melting_fire_healing_reduction += percentage

/datum/mutation_upgrade/veil/burnt_wounds/on_mutation_disabled()
	if(!isxenopyrogen(xenomorph_owner))
		return
	var/mob/living/carbon/xenomorph/pyrogen/pyrogen_owner = xenomorph_owner
	pyrogen_owner.melting_fire_healing_reduction -= percentage
