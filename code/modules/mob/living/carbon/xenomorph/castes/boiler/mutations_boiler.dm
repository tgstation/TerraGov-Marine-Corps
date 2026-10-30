//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/staggered_panic
	name = "Staggered Panic"
	desc = "If you are staggered while carrying 7/5/3 stored globs, adjacent tiles will be sprayed with stunning acid. This recharges once you reach full health."
	/// For the first structure, the increased amount of stored globs that the owner needs to have in order to gain its effect.
	var/globs_initial = 9
	/// For each structure, the increased amount of stored globs that the owner needs to have in order to gain its effect.
	var/globs_per_structure = -2
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
	if(can_be_activated || (health < xenomorph_owner.maxHealth))
		return
	can_be_activated = TRUE

/// If it is ready to activate and reaches the threshold, do the acid effect.
/datum/mutation_upgrade/shell/staggered_panic/proc/on_staggered(datum/source, amount, ignore_canstun)
	if(!can_be_activated || xenomorph_owner.stat != CONSCIOUS)
		return
	if(get_globs(get_total_structures()) > (xenomorph_owner.corrosive_ammo + xenomorph_owner.neurotoxin_ammo))
		return
	var/turf/current_turf = get_turf(xenomorph_owner)
	for(var/turf/acid_tile AS in RANGE_TURFS(acid_radius, current_turf))
		if(!line_of_sight(current_turf, acid_tile))
			continue
		xenomorph_spray(acid_tile, 6 SECONDS, 16, xenomorph_owner, TRUE, TRUE)
	can_be_activated = FALSE
	xenomorph_owner.emote("hiss")

/// Returns the amount of stored globs that the owner needs to have in order to gain its effect.
/datum/mutation_upgrade/shell/staggered_panic/proc/get_globs(structure_count)
	return globs_initial + (globs_per_structure * structure_count)

/datum/mutation_upgrade/shell/thick_containment
	name = "Thick Containment"
	desc = "Having excess globs no longer causes you to glow, but will instead slow you down by 0.15/0.1/0.05 for each excess glob."
	/// For each structure, the amount of slowdown per excess stored glob.
	var/slowdown_initial = 0.2
	/// For each structure, the increased amount of slowdown per excess stored glob.
	var/slowdown_per_structure = -0.05

/datum/mutation_upgrade/shell/thick_containment/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Having excess globs no longer causes you to glow, but will instead slow you down by [get_slowdown(new_amount)] for each excess glob."

/datum/mutation_upgrade/shell/thick_containment/on_mutation_enabled()
	xenomorph_owner.glob_luminosity_slowing += get_slowdown(0)
	return ..()

/datum/mutation_upgrade/shell/thick_containment/on_mutation_disabled()
	xenomorph_owner.glob_luminosity_slowing -= get_slowdown(0)
	return ..()

/datum/mutation_upgrade/shell/thick_containment/on_structure_update(previous_amount, new_amount)
	xenomorph_owner.glob_luminosity_slowing += get_slowdown(new_amount - previous_amount, FALSE)
	xenomorph_owner.update_ammo_glow()
	return ..()

/// Returns the amount of slowdown per excess stored glob.
/datum/mutation_upgrade/shell/thick_containment/proc/get_slowdown(structure_count, include_initial = TRUE)
	return (include_initial ? slowdown_initial : 0) + (slowdown_per_structure * structure_count)

/datum/mutation_upgrade/shell/dim_containment
	name = "Dim Containment"
	desc = "The threshold for having excess globs is increased by 1/2/3."
	/// For each structure, the amount to increase the excess glob threshold by.
	var/glob_per_structure = 1

/datum/mutation_upgrade/shell/dim_containment/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "The threshold for having excess globs is increased by [get_globs(new_amount)]."

/datum/mutation_upgrade/shell/dim_containment/on_structure_update(previous_amount, new_amount)
	xenomorph_owner.glob_luminosity_threshold += get_globs(new_amount - previous_amount)
	xenomorph_owner.update_ammo_glow()
	return ..()

/// Returns the amount to increase the excess glob threshold by.
/datum/mutation_upgrade/shell/dim_containment/proc/get_globs(structure_count)
	return glob_per_structure * structure_count

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/gaseous_spray
	name = "Gaseous Spray"
	desc = "If you have 7/5/3 stored globs, your acid spray also leaves a trail of non-opaque gas of your selected glob type."
	/// For the first structure, the increased amount of stored globs that the owner needs to have in order to gain its effect.
	var/globs_initial = 9
	/// For each structure, the increased amount of stored globs that the owner needs to have in order to gain its effect.
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
	spray_ability.gaseous_spray_threshold += get_globs(new_amount - previous_amount, FALSE)

/// Returns the amount of stored globs that the owner needs to have in order to gain its effect.
/datum/mutation_upgrade/spur/gaseous_spray/proc/get_globs(structure_count, include_initial = TRUE)
	return (include_initial ? globs_initial : 0) + (globs_per_structure * structure_count)

/datum/mutation_upgrade/spur/hip_fire
	name = "Hip Fire"
	desc = "Bombard's preparation and firing cast delay is set to 50/40/30% of their original value. You lose Long Range Sight."
	conflicting_mutation_types = list(
		/datum/mutation_upgrade/veil/binoculars
	)
	/// For the first structure, the multiplier to add to Bombard's cooldown duration.
	var/multiplier_initial = -0.4
	/// For each structure, the multiplier to add to Bombard's cooldown duration.
	var/multiplier_per_structure = -0.1

/datum/mutation_upgrade/spur/hip_fire/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Bombard's preparation and firing cast delay is set to [PERCENT(1 + get_multiplier(new_amount))]% of their original value. You lose Long Range Sight."

/datum/mutation_upgrade/spur/hip_fire/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/activable/xeno/bombard/bombard_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/bombard]
	if(!bombard_ability)
		return
	var/datum/action/ability/xeno_action/toggle_long_range/range_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toggle_long_range]
	if(range_ability)
		range_ability.remove_action(xenomorph_owner)
	bombard_ability.prepare_length += initial(bombard_ability.prepare_length) * get_multiplier(0)
	bombard_ability.fire_length += initial(bombard_ability.fire_length) * get_multiplier(0)
	return ..()

/datum/mutation_upgrade/spur/hip_fire/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/bombard/bombard_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/bombard]
	if(!bombard_ability)
		return
	var/datum/action/ability/xeno_action/toggle_long_range/range_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toggle_long_range]
	range_ability.give_action(xenomorph_owner)
	bombard_ability.prepare_length -= initial(bombard_ability.prepare_length) * get_multiplier(0)
	bombard_ability.fire_length -= initial(bombard_ability.fire_length) * get_multiplier(0)
	return ..()

/datum/mutation_upgrade/spur/hip_fire/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/bombard/bombard_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/bombard]
	if(!bombard_ability)
		return
	bombard_ability.prepare_length += initial(bombard_ability.prepare_length) * get_multiplier(new_amount - previous_amount, FALSE)
	bombard_ability.fire_length += initial(bombard_ability.fire_length) * get_multiplier(new_amount - previous_amount, FALSE)

/datum/mutation_upgrade/spur/hip_fire/on_xenomorph_upgrade()
	var/datum/action/ability/xeno_action/toggle_long_range/range_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toggle_long_range]
	if(range_ability)
		range_ability.remove_action(xenomorph_owner) // Since upgrading give abilities that are missing, we have to remove it again.

/// Returns the multiplier to add to Bombard's cooldown duration.
/datum/mutation_upgrade/spur/hip_fire/proc/get_multiplier(structure_count, include_initial = TRUE)
	return (include_initial ? multiplier_initial : 0) + (multiplier_per_structure * structure_count)

/datum/mutation_upgrade/spur/rapid_fire
	name = "Rapid Fire"
	desc = "Your normal globs are replaced with fast globs. Fast globs are twice as fast, but the gas is transparent, smaller, and dissipates in two seconds. If a fast glob is used, Bombard's cooldown to 50/40/30% of its original value."
	/// For the first structure, the multiplier to add to Bombard's cooldown duration if the fast glob variants were used.
	var/multiplier_initial = -0.4
	/// For each structure, the multiplier to add to Bombard's cooldown duration if the fast glob variants were used.
	var/multiplier_per_structure = -0.1

/datum/mutation_upgrade/spur/rapid_fire/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Your normal globs are replaced with fast globs. Fast globs are twice as fast, but the gas is transparent, smaller, and dissipates in two seconds. If a fast glob is used, Bombard's cooldown to [PERCENT(1 + get_multiplier(new_amount))]% of its original value."

/datum/mutation_upgrade/spur/rapid_fire/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/xeno_action/toggle_bomb/toggle_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toggle_bomb]
	if(!toggle_ability)
		return
	var/datum/action/ability/activable/xeno/bombard/bombard_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/bombard]
	if(!bombard_ability)
		return
	toggle_ability.fast_gas = TRUE
	bombard_ability.fast_cooldown_multiplier += get_multiplier(0)

/datum/mutation_upgrade/spur/rapid_fire/on_mutation_disabled()
	var/datum/action/ability/xeno_action/toggle_bomb/toggle_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toggle_bomb]
	if(!toggle_ability)
		return
	var/datum/action/ability/activable/xeno/bombard/bombard_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/bombard]
	if(!bombard_ability)
		return
	toggle_ability.fast_gas = initial(toggle_ability.fast_gas)
	bombard_ability.fast_cooldown_multiplier -= get_multiplier(0)
	return ..()

/datum/mutation_upgrade/spur/rapid_fire/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/xeno_action/toggle_bomb/toggle_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toggle_bomb]
	if(!toggle_ability)
		return
	var/datum/action/ability/activable/xeno/bombard/bombard_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/bombard]
	if(!bombard_ability)
		return
	bombard_ability.fast_cooldown_multiplier += get_multiplier(new_amount - previous_amount, FALSE)
	toggle_ability.reset_selectable_glob_typepath_list()

/// Returns the multiplier to add to Bombard's cooldown duration if the fast glob variants were used.
/datum/mutation_upgrade/spur/rapid_fire/proc/get_multiplier(structure_count, include_initial = TRUE)
	return (include_initial ? multiplier_initial : 0) + (multiplier_per_structure * structure_count)

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
	if(get_globs(get_total_structures()) > (xenomorph_owner.corrosive_ammo + xenomorph_owner.neurotoxin_ammo))
		return
	xenomorph_spray(get_turf(xenomorph_owner), 2 SECONDS, 16)

/// Returns the amount of stored globs that the owner needs to have in order to gain its effect.
/datum/mutation_upgrade/veil/acid_trail/proc/get_globs(structure_count, include_initial = TRUE)
	return (include_initial ? globs_initial : 0) + (globs_per_structure * structure_count)

/datum/mutation_upgrade/veil/chemical_mixing
	name = "Chemical Mixing"
	desc = "Bombard now has the option to shoot Ozelomelyn, Hemodile, and Sanguinal. These will consume 6/4/2 stored globs per shot."
	/// For the first structure, the amount of stored globs required and will be consumed to shoot these unique globs.
	var/globs_initial = 8
	/// For each structure, the additional amount of stored globs required and will be consumed to shoot these unique globs.
	var/globs_per_structure = -2

/datum/mutation_upgrade/veil/chemical_mixing/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Bombard now has the option to shoot Ozelomelyn, Hemodile, and Sanguinal. These will consume [get_globs(new_amount)] stored globs per shot."

/datum/mutation_upgrade/veil/chemical_mixing/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/activable/xeno/bombard/bombard_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/bombard]
	if(!bombard_ability)
		return
	var/datum/action/ability/xeno_action/toggle_bomb/toggle_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toggle_bomb]
	if(!toggle_ability)
		return
	bombard_ability.special_glob_required += get_globs(0)
	toggle_ability.unique_gas = TRUE
	toggle_ability.reset_selectable_glob_typepath_list()

/datum/mutation_upgrade/veil/chemical_mixing/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/bombard/bombard_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/bombard]
	if(!bombard_ability)
		return
	var/datum/action/ability/xeno_action/toggle_bomb/toggle_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toggle_bomb]
	if(!toggle_ability)
		return
	bombard_ability.special_glob_required -= get_globs(0)
	toggle_ability.unique_gas = initial(toggle_ability.unique_gas)
	toggle_ability.reset_selectable_glob_typepath_list()

/datum/mutation_upgrade/veil/chemical_mixing/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/bombard/bombard_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/bombard]
	if(!bombard_ability)
		return
	bombard_ability.special_glob_required += get_globs(new_amount - previous_amount, FALSE)

/// Returns the amount of stored globs that the owner needs to have in order to gain its effect.
/datum/mutation_upgrade/veil/chemical_mixing/proc/get_globs(structure_count, include_initial = TRUE)
	return (include_initial ? globs_initial : 0) + (globs_per_structure * structure_count)


/datum/mutation_upgrade/veil/binoculars
	name = "Binoculars"
	desc = "Bombard and Long Range Sight can go 2/4/6 tiles further. The time required to use Long Range Sight is set to 250% of its original value."
	conflicting_mutation_types = list(
		/datum/mutation_upgrade/spur/hip_fire
	)

	/// For each structure, the additional amount of additional range to increase Long Range Sight by.
	var/range_per_structure = 2

/datum/mutation_upgrade/veil/binoculars/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Bombard and Long Range Sight can go [get_range(new_amount)] tiles further. The time required to use Long Range Sight is set to 250% of its original value."

/datum/mutation_upgrade/veil/binoculars/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/xeno_action/toggle_long_range/range_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toggle_long_range]
	if(!range_ability)
		return
	range_ability.do_after_length += initial(range_ability.do_after_length) * 1.5

/datum/mutation_upgrade/veil/binoculars/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/xeno_action/toggle_long_range/range_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toggle_long_range]
	if(!range_ability)
		return
	range_ability.do_after_length -= initial(range_ability.do_after_length) * 1.5

/datum/mutation_upgrade/veil/binoculars/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/xeno_action/toggle_long_range/range_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toggle_long_range]
	if(!range_ability)
		return
	var/datum/action/ability/activable/xeno/bombard/bombard_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/bombard]
	if(!bombard_ability)
		return
	range_ability.tile_offset += get_range(new_amount - previous_amount) / 2
	range_ability.view_size += get_range(new_amount - previous_amount)
	bombard_ability.bonus_max_range += get_range(new_amount - previous_amount)

/// Returns the amount of additional range to increase Bombard and Long Range Sight by.
/datum/mutation_upgrade/veil/binoculars/proc/get_range(structure_count)
	return range_per_structure * structure_count


