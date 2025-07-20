//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/staggered_panic
	name = "Staggered Panic"
	desc = "If you are staggered while carrying 7/6/5 stored globs, adjacent tiles will be sprayed with stunning acid. This recharges once you reach full health."
	/// For the first structure, the amount of stored globs that the owner needs to have in order to gain its effect.
	var/globs_initial = 8
	/// For each structure, the amount of stored globs that the owner needs to have in order to gain its effect.
	var/globs_per_structure = -1
	/// The radius of the acid.
	var/acid_radius = 1
	/// Can this be activated?
	var/can_be_activated = FALSE

/datum/mutation_upgrade/shell/staggered_panic/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "If you are staggered while carrying [get_globs(new_amount)] stored globs, adjacent tiles will be sprayed with stunning acid. This recharges once you reach full health."

/datum/mutation_upgrade/shell/staggered_panic/on_mutation_enabled()
	RegisterSignal(xenomorph_owner, COMSIG_LIVING_UPDATE_HEALTH, PROC_REF(on_update_health))
	RegisterSignal(xenomorph_owner, COMSIG_LIVING_STATUS_STAGGER, PROC_REF(on_staggered))
	can_be_activated = (xenomorph_owner.health >= xenomorph_owner.maxHealth)
	return ..()

/datum/mutation_upgrade/shell/staggered_panic/on_mutation_disabled()
	UnregisterSignal(xenomorph_owner, list(COMSIG_LIVING_UPDATE_HEALTH, COMSIG_LIVING_STATUS_STAGGER))
	can_be_activated = FALSE
	return ..()

/// If it isn't ready to activate and they have full health, make it ready to activate.
/datum/mutation_upgrade/shell/staggered_panic/proc/on_update_health(datum/source)
	SIGNAL_HANDLER
	var/health = (xenomorph_owner.status_flags & GODMODE) ? xenomorph_owner.maxHealth : (xenomorph_owner.maxHealth - xenomorph_owner.getFireLoss() - xenomorph_owner.getBruteLoss())
	if(can_be_activated || (health <= xenomorph_owner.get_death_threshold()))
		return
	can_be_activated = (health >= xenomorph_owner.maxHealth)

/// If it is ready to activate and reaches the threshold, do the acid effect.
/datum/mutation_upgrade/shell/staggered_panic/proc/on_staggered(datum/source, amount, ignore_canstun)
	if(!can_be_activated || xenomorph_owner.stat != CONSCIOUS)
		return
	if(get_globs(get_total_structures()) > (xenomorph_owner.corrosive_ammo + xenomorph_owner.neuro_ammo))
		return
	var/turf/current_turf = get_turf(xenomorph_owner)
	for(var/turf/acid_tile AS in RANGE_TURFS(acid_radius, current_turf))
		if(!line_of_sight(current_turf, acid_tile))
			continue
		xenomorph_spray(acid_tile, 6 SECONDS, 16, xenomorph_owner, TRUE, TRUE)
	can_be_activated = FALSE

/// Returns the amount of stored globs that the owner needs to have in order to gain its effect.
/datum/mutation_upgrade/shell/staggered_panic/proc/get_globs(structure_count)
	return globs_initial + (globs_per_structure * structure_count)

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/gaseous_spray
	name = "Gaseous Spray"
	desc = "If you have 7/5/3 stored globs, your acid spray also leaves a trail of non-opaque gas of your selected glob type."
	/// For the first structure, the amount of stored globs that the owner needs to have in order to gain its effect.
	var/globs_initial = 9
	/// For each structure, the amount of stored globs that the owner needs to have in order to gain its effect.
	var/globs_per_structure = -2

/datum/mutation_upgrade/spur/gaseous_spray/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "While you have [get_globs(new_amount)], your acid spray also leaves a trail of non-opaque gas of your selected glob type."

/datum/mutation_upgrade/spur/gaseous_spray/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/activable/xeno/spray_acid/line/boiler/spray_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/spray_acid/line/boiler]
	if(!spray_ability)
		return
	spray_ability.gaseous_spray_threshold += get_globs(0)

/datum/mutation_upgrade/spur/gaseous_spray/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/spray_acid/line/boiler/spray_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/spray_acid/line/boiler]
	if(!spray_ability)
		return
	spray_ability.gaseous_spray_threshold -= get_globs(0)

/datum/mutation_upgrade/spur/gaseous_spray/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/spray_acid/line/boiler/spray_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/spray_acid/line/boiler]
	if(!spray_ability)
		return
	spray_ability.gaseous_spray_threshold += get_globs(new_amount - previous_amount)

/// Returns the amount of stored globs that the owner needs to have in order to gain its effect.
/datum/mutation_upgrade/spur/gaseous_spray/proc/get_globs(structure_count, include_initial = TRUE)
	return (include_initial ? globs_initial : 0) + (globs_per_structure * structure_count)

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/acid_trail
	name = "Acid Trail"
	desc = "Whenever you move while carrying 7/5/3 stored globs, a short acid splatter is created underneath you."
	/// For the first structure, the amount of stored globs threshold required to activate this effect.
	var/globs_initial = 9
	/// For each structure, the additional amount of stored globs threshold required to activate this effect.
	var/globs_per_structure = -2

/datum/mutation_upgrade/veil/acid_trail/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Whenever you move while carrying [get_globs(new_amount)] stored globs, an acid splatter is created underneath you."

/datum/mutation_upgrade/veil/acid_trail/on_mutation_enabled()
	RegisterSignal(xenomorph_owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_movement))
	return ..()

/datum/mutation_upgrade/veil/acid_trail/on_mutation_disabled()
	UnregisterSignal(xenomorph_owner, COMSIG_MOVABLE_MOVED)
	return ..()

/datum/mutation_upgrade/veil/acid_trail/proc/on_movement(datum/source, atom/old_loc, movement_dir, forced, list/old_locs)
	if(xenomorph_owner.stat != CONSCIOUS)
		return
	if(get_globs(get_total_structures()) > (xenomorph_owner.corrosive_ammo + xenomorph_owner.neuro_ammo))
		return
	xenomorph_spray(get_turf(xenomorph_owner), 2 SECONDS, 16, null, TRUE)

/// Returns the amount of stored globs that the owner needs to have in order to gain its effect.
/datum/mutation_upgrade/veil/acid_trail/proc/get_globs(structure_count, include_initial = TRUE)
	return (include_initial ? globs_initial : 0) + (globs_per_structure * structure_count)
