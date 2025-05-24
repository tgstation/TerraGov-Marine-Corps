//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/acid_release
	name = "Acid Release"
	desc = "Upon entering critical, release stunning acid in a radius of 2/3/4 tile radius. This resets upon reaching full health."
	/// The beginning radius of stunning acid (at zero structures)
	var/beginning_radius = 1
	/// The additional radius of stunning acid for each structure.
	var/radius_per_structure = 1
	/// If the effect can be activated.
	var/can_be_activated = FALSE

/datum/mutation_upgrade/shell/acid_release/on_mutation_enabled()
	RegisterSignals(xenomorph_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE), PROC_REF(on_damage))
	RegisterSignal(xenomorph_owner, COMSIG_MOB_STAT_CHANGED, PROC_REF(on_stat_changed))
	on_damage()
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
	for(var/turf/acid_tile AS in RANGE_TURFS(beginning_radius + (get_total_structures() * radius_per_structure), current_turf))
		if(!line_of_sight(current_turf, acid_tile))
			continue
		new /obj/effect/temp_visual/acid_splatter(acid_tile)
		if(locate(/obj/effect/xenomorph/spray) in acid_tile.contents)
			continue
		new /obj/effect/xenomorph/spray(acid_tile, 6 SECONDS, 16)
		for (var/atom/movable/atom_in_acid AS in acid_tile)
			atom_in_acid.acid_spray_act(src)
	can_be_activated = FALSE

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/fully_acid
	name = "Fully Acid"
	desc = "All of your stash damage is burn damage and is now checked against acid. You inflict 1/2/3 additional melting acid stacks."

/datum/mutation_upgrade/spur/fully_acid/on_mutation_enabled()
	if(!isxenomelter(xenomorph_owner))
		return FALSE
	var/mob/living/carbon/xenomorph/runner/melter/melter_owner = xenomorph_owner
	melter_owner.second_damage_type = BURN
	melter_owner.second_damage_armor = ACID
	return ..()

/datum/mutation_upgrade/spur/fully_acid/on_mutation_disabled()
	if(!isxenomelter(xenomorph_owner))
		return FALSE
	var/mob/living/carbon/xenomorph/runner/melter/melter_owner = xenomorph_owner
	melter_owner.second_damage_type = initial(melter_owner.second_damage_type)
	melter_owner.second_damage_armor = initial(melter_owner.second_damage_armor)
	return ..()


/datum/mutation_upgrade/spur/fully_acid/on_structure_update(datum/source, previous_amount, new_amount)
	. = ..()
	if(!. || !isxenomelter(xenomorph_owner))
		return FALSE
	var/mob/living/carbon/xenomorph/runner/melter/melter_owner = xenomorph_owner
	melter_owner.applied_acid_stacks += (new_amount - previous_amount)

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/acid_reserves
	name = "Acid Reserves"
	desc = "Corrosive Acid is now applied 50/75/100% faster."
	/// The beginning speedup of the ability application (at zero structures).
	var/beginning_speedup = 0.25
	/// The additional speedup of the ability application for each structure.
	var/radius_per_structure = 0.25

/datum/mutation_upgrade/veil/acid_reserves/on_structure_update(datum/source, previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/corrosive_acid/melter/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/corrosive_acid/melter]
	if(!ability)
		return FALSE
	if(previous_amount)
		ability.acid_speed_multiplier *= (1 + beginning_speedup + (previous_amount * 0.25)) // First, we reverse...
	if(new_amount)
		ability.acid_speed_multiplier /= (1 + beginning_speedup + (new_amount * 0.25)) // ... then we re-apply because math is hard!
