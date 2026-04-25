//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/acid_release
	name = "Acid Release"
	desc = "Upon entering critical, release stunning acid in a radius of 2/3/4 tiles. This resets upon reaching full health."
	/// For the first structure, the radius in which stunning acid is created.
	var/radius_initial = 1
	/// For each structure, the additional radius in which stunning acid is created.
	var/radius_per_structure = 1
	/// If the effect can be activated.
	var/can_be_activated = FALSE

/datum/mutation_upgrade/shell/acid_release/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Upon entering critical, release stunning acid in a radius of [get_radius(new_amount)] tiles. This resets upon reaching full health."

/datum/mutation_upgrade/shell/acid_release/on_mutation_enabled()
	RegisterSignals(xenomorph_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE), PROC_REF(on_damage))
	RegisterSignal(xenomorph_owner, COMSIG_MOB_STAT_CHANGED, PROC_REF(on_stat_changed))
	if(xenomorph_owner.health >= xenomorph_owner.maxHealth)
		can_be_activated = TRUE
	return ..()

/datum/mutation_upgrade/shell/acid_release/on_mutation_disabled()
	UnregisterSignal(xenomorph_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE, COMSIG_MOB_STAT_CHANGED))
	can_be_activated = FALSE
	return ..()

/// If it isn't ready to activate and they have full health, make it ready to activate.
/datum/mutation_upgrade/shell/acid_release/proc/on_damage(datum/source, amount, list/amount_mod)
	SIGNAL_HANDLER
	if(!can_be_activated && xenomorph_owner.health >= xenomorph_owner.maxHealth)
		can_be_activated = TRUE

/// Cover the area around them with stunning acid upon entering critical if it is ready to activate.
/datum/mutation_upgrade/shell/acid_release/proc/on_stat_changed(datum/source, old_stat, new_stat)
	if(!isturf(xenomorph_owner.loc) || new_stat != UNCONSCIOUS)
		return
	var/turf/current_turf = xenomorph_owner.loc
	for(var/turf/acid_tile AS in RANGE_TURFS(get_radius(get_total_structures()), current_turf))
		if(!line_of_sight(current_turf, acid_tile))
			continue
		xenomorph_spray(acid_tile, 6 SECONDS, 16, xenomorph_owner, TRUE, TRUE)
	can_be_activated = FALSE

/// Returns the radius for how far the acid will be spawned.
/datum/mutation_upgrade/shell/acid_release/proc/get_radius(structure_count, include_initial = TRUE)
	return (include_initial ? radius_initial : 0) + (radius_per_structure * structure_count)

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/fully_acid
	name = "Fully Acid"
	desc = "All of your stash damage is burn damage and is now checked against acid. You inflict 1/2/3 additional melting acid stacks."
	/// For each structure, the additional stacks of melting acid.
	var/stacks_per_structure = 1

/datum/mutation_upgrade/spur/fully_acid/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "All of your stash damage is burn damage and is now checked against acid. You inflict [get_stacks(new_amount)] additional melting acid stacks."

/datum/mutation_upgrade/spur/fully_acid/on_mutation_enabled()
	if(!isxenomelter(xenomorph_owner))
		return
	var/mob/living/carbon/xenomorph/runner/melter/melter_owner = xenomorph_owner
	melter_owner.second_damage_type = BURN
	melter_owner.second_damage_armor = ACID
	return ..()

/datum/mutation_upgrade/spur/fully_acid/on_mutation_disabled()
	if(!isxenomelter(xenomorph_owner))
		return
	var/mob/living/carbon/xenomorph/runner/melter/melter_owner = xenomorph_owner
	melter_owner.second_damage_type = initial(melter_owner.second_damage_type)
	melter_owner.second_damage_armor = initial(melter_owner.second_damage_armor)
	return ..()

/datum/mutation_upgrade/spur/fully_acid/on_structure_update(previous_amount, new_amount)
	if(!isxenomelter(xenomorph_owner))
		return
	var/mob/living/carbon/xenomorph/runner/melter/melter_owner = xenomorph_owner
	melter_owner.applied_acid_stacks += get_stacks(new_amount - previous_amount)
	return ..()

/// Returns the amount of stacks of melting acid that will be given.
/datum/mutation_upgrade/spur/fully_acid/proc/get_stacks(structure_count)
	return stacks_per_structure * structure_count

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/acid_reserves
	name = "Acid Reserves"
	desc = "Corrosive Acid is now applied 50/75/100% faster."
	/// For the first structure, the percentage to speed up Corrosive Acid by.
	var/speedup_initial = 0.25
	/// For each structure, the additional percentage to speed up Corrosive Acid by.
	var/speedup_per_structure = 0.25

/datum/mutation_upgrade/veil/acid_reserves/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Corrosive Acid is now applied [PERCENT(get_speedup(new_amount))]% faster."

/datum/mutation_upgrade/veil/acid_reserves/on_structure_update(previous_amount, new_amount)
	var/datum/action/ability/activable/xeno/corrosive_acid/melter/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/corrosive_acid/melter]
	if(!ability)
		return
	if(previous_amount)
		ability.acid_speed_multiplier *= 1 + get_speedup(previous_amount) // First, we reverse...
	if(new_amount)
		ability.acid_speed_multiplier /= 1 + get_speedup(new_amount) // ... then we re-apply because math is hard!
	return ..()

/// Returns the percentage used to speed up Corrosive Acid by.
/datum/mutation_upgrade/veil/acid_reserves/proc/get_speedup(structure_count)
	return speedup_initial + (speedup_per_structure * structure_count)

