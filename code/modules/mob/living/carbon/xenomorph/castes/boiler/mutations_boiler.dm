//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/staggered_panic
	name = "Staggered Panic"
	desc = "While you have 7/6/5 stored globs, you will release stunning acid in a small radius if you get staggered. This recharges once you reach full health."
	/// For the first structure, the amount of stored globs threshold required to activate this effect.
	var/globs_initial = 8
	/// For each structure, the additional amount of stored globs threshold required to activate this effect.
	var/globs_per_structure = -1
	/// The radius of the acid.
	var/acid_radius = 2
	/// Can this be activated?
	var/can_be_activated = FALSE

/datum/mutation_upgrade/shell/staggered_panic/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "While you have [globs_initial + (globs_per_structure * new_amount)] stored globs, you will release stunning acid in a small radius if you get staggered. This recharges once you reach full health."

/datum/mutation_upgrade/shell/staggered_panic/on_mutation_enabled()
	RegisterSignals(xenomorph_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE), PROC_REF(on_damage))
	RegisterSignal(xenomorph_owner, COMSIG_LIVING_STATUS_STAGGER, PROC_REF(on_staggered))
	can_be_activated = xenomorph_owner.health >= xenomorph_owner.maxHealth
	return ..()

/datum/mutation_upgrade/shell/staggered_panic/on_mutation_disabled()
	RegisterSignals(xenomorph_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE), PROC_REF(on_damage))
	UnregisterSignal(xenomorph_owner, COMSIG_LIVING_STATUS_STAGGER)
	can_be_activated = FALSE
	return ..()

/// If it isn't ready to activate and they have full health, make it ready to activate.
/datum/mutation_upgrade/shell/staggered_panic/proc/on_damage(datum/source, amount, list/amount_mod)
	SIGNAL_HANDLER
	if(!can_be_activated && xenomorph_owner.health >= xenomorph_owner.maxHealth)
		can_be_activated = TRUE

/// If it is ready to activate and reaches the threshold, do the acid effect.
/datum/mutation_upgrade/shell/staggered_panic/proc/on_staggered(datum/source, amount, ignore_canstun)
	if(!can_be_activated || !isturf(xenomorph_owner.loc) || xenomorph_owner.stat != CONSCIOUS)
		return
	var/current_globs = xenomorph_owner.corrosive_ammo + xenomorph_owner.neuro_ammo
	var/threshold = globs_initial + (globs_per_structure * get_total_structures())
	if(threshold > current_globs)
		return
	var/turf/current_turf = xenomorph_owner.loc
	for(var/turf/acid_tile AS in RANGE_TURFS(acid_radius, current_turf))
		if(!line_of_sight(current_turf, acid_tile))
			continue
		new /obj/effect/temp_visual/acid_splatter(acid_tile)
		if(locate(/obj/effect/xenomorph/spray) in acid_tile.contents)
			continue
		new /obj/effect/xenomorph/spray(acid_tile, 6 SECONDS, 16, xenomorph_owner)
	can_be_activated = FALSE

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/gaseous_spray
	name = "Gaseous Spray"
	desc = "While you have 7/5/3 stored globs, your acid spray also leaves a trail of non-opaque gas of your selected glob type."
	/// For the first structure, the amount of stored globs threshold required to activate this effect.
	var/globs_initial = 9
	/// For each structure, the additional amount of stored globs threshold required to activate this effect.
	var/globs_per_structure = -2

/datum/mutation_upgrade/spur/gaseous_spray/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "While you have [globs_initial + (globs_per_structure * new_amount)], your acid spray also leaves a trail of non-opaque gas of your selected glob type."

/datum/mutation_upgrade/spur/gaseous_spray/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/spray_acid/line/boiler/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/spray_acid/line/boiler]
	if(!ability)
		return FALSE
	ability.globs_threshold -= globs_initial
	return ..()

/datum/mutation_upgrade/spur/gaseous_spray/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/spray_acid/line/boiler/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/spray_acid/line/boiler]
	if(!ability)
		return FALSE
	ability.globs_threshold += globs_initial
	return ..()

/datum/mutation_upgrade/spur/gaseous_spray/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/spray_acid/line/boiler/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/spray_acid/line/boiler]
	if(!ability)
		return FALSE
	ability.globs_threshold += (new_amount - previous_amount) * globs_per_structure

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/acid_trail
	name = "Acid Trail"
	desc = "While you have 7/5/3 stored globs, you create non-stunning acid whenever you move."
	/// For the first structure, the amount of stored globs threshold required to activate this effect.
	var/globs_initial = 9
	/// For each structure, the additional amount of stored globs threshold required to activate this effect.
	var/globs_per_structure = -2

/datum/mutation_upgrade/veil/acid_trail/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "While you have [globs_initial + (globs_per_structure * new_amount)], you create non-stunning acid whenever you move."

/datum/mutation_upgrade/veil/acid_trail/on_mutation_enabled()
	RegisterSignal(xenomorph_owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_movement))
	return ..()

/datum/mutation_upgrade/veil/acid_trail/on_mutation_disabled()
	UnregisterSignal(xenomorph_owner, COMSIG_MOVABLE_MOVED)
	return ..()

/datum/mutation_upgrade/veil/acid_trail/proc/on_movement(datum/source, atom/old_loc, movement_dir, forced, list/old_locs)
	if(!isturf(xenomorph_owner.loc) || xenomorph_owner.stat != CONSCIOUS)
		return
	var/current_globs =  xenomorph_owner.corrosive_ammo + xenomorph_owner.neuro_ammo
	var/threshold = globs_initial + (globs_per_structure * get_total_structures())
	if(threshold > current_globs)
		return
	var/turf/current_turf = xenomorph_owner.loc
	new /obj/effect/temp_visual/acid_splatter(current_turf)
	if(locate(/obj/effect/xenomorph/spray) in current_turf.contents)
		return
	new /obj/effect/xenomorph/spray(current_turf, 6 SECONDS, 16) // No owner = no acid_spray_act = no stun.
