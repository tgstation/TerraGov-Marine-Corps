//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/staggered_panic
	name = "Staggered Panic"
	desc = "If you are staggered while carrying 5 stored globs, adjacent tiles will be sprayed with stunning acid. This recharges once you reach full health."
	/// The amount of stored globs that the owner needs to have in order to gain its effect.
	var/globs = 5
	/// The radius of the acid.
	var/acid_radius = 1
	/// Can this be activated?
	var/can_be_activated = FALSE

/datum/mutation_upgrade/shell/staggered_panic/on_mutation_enabled()
	RegisterSignal(xenomorph_owner, COMSIG_LIVING_UPDATE_HEALTH, PROC_REF(on_update_health))
	RegisterSignal(xenomorph_owner, COMSIG_LIVING_STATUS_STAGGER, PROC_REF(on_staggered))
	can_be_activated = (xenomorph_owner.health >= xenomorph_owner.maxHealth)

/datum/mutation_upgrade/shell/staggered_panic/on_mutation_disabled()
	UnregisterSignal(xenomorph_owner, list(COMSIG_LIVING_UPDATE_HEALTH, COMSIG_LIVING_STATUS_STAGGER))
	can_be_activated = FALSE

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
	if(globs > (xenomorph_owner.corrosive_ammo + xenomorph_owner.neurotoxin_ammo))
		return
	var/turf/current_turf = get_turf(xenomorph_owner)
	for(var/turf/acid_tile AS in RANGE_TURFS(acid_radius, current_turf))
		if(!line_of_sight(current_turf, acid_tile))
			continue
		xenomorph_spray(acid_tile, 6 SECONDS, 16, xenomorph_owner, TRUE, TRUE)
	can_be_activated = FALSE
	xenomorph_owner.emote("hiss")

/datum/mutation_upgrade/shell/thick_containment
	name = "Thick Containment"
	desc = "Having excess globs no longer causes you to glow, but will instead slow you down by 0.1 for each excess glob."
	/// The amount of slowdown per excess stored glob.
	var/slowdown = 0.1

/datum/mutation_upgrade/shell/thick_containment/on_mutation_enabled()
	xenomorph_owner.glob_luminosity_slowing += slowdown
	xenomorph_owner.update_ammo_glow()

/datum/mutation_upgrade/shell/thick_containment/on_mutation_disabled()
	xenomorph_owner.glob_luminosity_slowing -= slowdown
	xenomorph_owner.update_ammo_glow()

/datum/mutation_upgrade/shell/dim_containment
	name = "Dim Containment"
	desc = "The threshold for having excess globs is increased by 2."
	/// The amount to increase the excess glob threshold by.
	var/globs_threshold_increase = 2

/datum/mutation_upgrade/shell/dim_containment/on_mutation_enabled()
	xenomorph_owner.glob_luminosity_threshold += globs_threshold_increase
	xenomorph_owner.update_ammo_glow()

/datum/mutation_upgrade/shell/dim_containment/on_mutation_disabled()
	xenomorph_owner.glob_luminosity_threshold -= globs_threshold_increase
	xenomorph_owner.update_ammo_glow()

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/gaseous_spray
	name = "Gaseous Spray"
	desc = "While you have 3 stored globs, your acid spray also leaves a trail of non-opaque gas of your selected glob type."
	/// The amount of stored globs that the owner needs to have in order to gain its effect.
	var/globs_threshold = 3

/datum/mutation_upgrade/spur/gaseous_spray/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/spray_acid/line/boiler/spray_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/spray_acid/line/boiler]
	if(!spray_ability)
		return
	spray_ability.gaseous_spray_threshold += globs_threshold

/datum/mutation_upgrade/spur/gaseous_spray/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/spray_acid/line/boiler/spray_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/spray_acid/line/boiler]
	if(!spray_ability)
		return
	spray_ability.gaseous_spray_threshold -= globs_threshold

/datum/mutation_upgrade/spur/hip_fire
	name = "Hip Fire"
	desc = "Bombard's preparation and firing cast delay is set to 40% of their original value. You lose Long Range Sight."
	/// The ability to be given back if the mutation is disabled.
	var/datum/action/ability/activable/xeno/bombard/removed_ability
	/// The multiplier of Bombard's initial preparation and firing cast delay to add.
	var/multiplier = 0.4

/datum/mutation_upgrade/spur/hip_fire/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/bombard/bombard_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/bombard]
	if(!bombard_ability)
		bombard_ability.prepare_length += initial(bombard_ability.prepare_length) * multiplier
		bombard_ability.fire_length += initial(bombard_ability.fire_length) * multiplier
	var/datum/action/ability/xeno_action/toggle_long_range/range_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toggle_long_range]
	if(range_ability)
		removed_ability = range_ability
		removed_ability.remove_action(xenomorph_owner)

/datum/mutation_upgrade/spur/hip_fire/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/bombard/bombard_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/bombard]
	if(bombard_ability)
		bombard_ability.prepare_length -= initial(bombard_ability.prepare_length) * multiplier
		bombard_ability.fire_length -= initial(bombard_ability.fire_length) * multiplier
	if(removed_ability)
		removed_ability.give_action(xenomorph_owner)
		removed_ability = null

/datum/mutation_upgrade/spur/hip_fire/on_xenomorph_upgrade()
	var/datum/action/ability/xeno_action/toggle_long_range/range_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toggle_long_range]
	if(range_ability)
		xenomorph_owner.remove_ability(range_ability) // Upgrading gives abilities we have removed, thus we need to delete them.

/datum/mutation_upgrade/spur/rapid_fire
	name = "Rapid Fire"
	desc = "Your normal globs are replaced with fast globs. Fast globs are twice as fast, but the gas is transparent, smaller, and dissipates in two seconds. If a fast glob is used, Bombard's cooldown to 40% of its original value."
	/// The multiplier of Bombard's initial cooldown duration to add it to if a fast glob variant was used.
	var/multiplier = -0.6

/datum/mutation_upgrade/spur/rapid_fire/on_mutation_enabled()
	var/datum/action/ability/xeno_action/toggle_bomb/toggle_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toggle_bomb]
	if(!toggle_ability)
		return
	var/datum/action/ability/activable/xeno/bombard/bombard_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/bombard]
	if(!bombard_ability)
		return
	toggle_ability.fast_gas = TRUE
	bombard_ability.fast_cooldown_multiplier += multiplier

/datum/mutation_upgrade/spur/rapid_fire/on_mutation_disabled()
	var/datum/action/ability/xeno_action/toggle_bomb/toggle_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toggle_bomb]
	if(!toggle_ability)
		return
	var/datum/action/ability/activable/xeno/bombard/bombard_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/bombard]
	if(bombard_ability)
		return
	toggle_ability.fast_gas = initial(toggle_ability.fast_gas)
	bombard_ability.fast_cooldown_multiplier -= multiplier

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/acid_trail
	name = "Acid Trail"
	desc = "Whenever you move while carrying 5 stored globs, a short acid splatter is created underneath you."
	/// The amount of stored globs threshold required to activate this effect.
	var/globs_threshold = 5

/datum/mutation_upgrade/veil/acid_trail/on_mutation_enabled()
	RegisterSignal(xenomorph_owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_movement))

/datum/mutation_upgrade/veil/acid_trail/on_mutation_disabled()
	UnregisterSignal(xenomorph_owner, COMSIG_MOVABLE_MOVED)

/// Creates acid splatter underneath them if applicable.
/datum/mutation_upgrade/veil/acid_trail/proc/on_movement(datum/source, atom/old_loc, movement_dir, forced, list/old_locs)
	if(xenomorph_owner.stat != CONSCIOUS)
		return
	if(globs_threshold > (xenomorph_owner.corrosive_ammo + xenomorph_owner.neurotoxin_ammo))
		return
	xenomorph_spray(get_turf(xenomorph_owner), 2 SECONDS, 16)

/datum/mutation_upgrade/veil/chemical_mixing
	name = "Chemical Mixing"
	desc = "Bombard now has the option to shoot Ozelomelyn, Hemodile, and Sanguinal. These will consume 4 stored globs per shot."
	/// The amount of stored globs required and will be consumed to shoot these unique globs.
	var/globs = 4

/datum/mutation_upgrade/veil/chemical_mixing/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/bombard/bombard_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/bombard]
	if(!bombard_ability)
		return
	var/datum/action/ability/xeno_action/toggle_bomb/toggle_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toggle_bomb]
	if(!toggle_ability)
		return
	bombard_ability.special_glob_required += globs
	toggle_ability.unique_gas = TRUE
	toggle_ability.reset_selectable_glob_typepath_list()

/datum/mutation_upgrade/veil/chemical_mixing/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/bombard/bombard_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/bombard]
	if(!bombard_ability)
		return
	var/datum/action/ability/xeno_action/toggle_bomb/toggle_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toggle_bomb]
	if(!toggle_ability)
		return
	bombard_ability.special_glob_required -= globs
	toggle_ability.unique_gas = initial(toggle_ability.unique_gas)
	toggle_ability.reset_selectable_glob_typepath_list()

/datum/mutation_upgrade/veil/binoculars
	name = "Binoculars"
	desc = "Bombard and Long Range Sight can go 4 tiles further. The time required to use Long Range Sight is set to 250% of its original value."
	conflicting_mutation_types = list(
		/datum/mutation_upgrade/spur/hip_fire
	)
	/// The additional amount of additional range to increase Long Range Sight by.
	var/range = 4

/datum/mutation_upgrade/veil/binoculars/on_mutation_enabled()
	var/datum/action/ability/xeno_action/toggle_long_range/range_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toggle_long_range]
	if(!range_ability)
		return
	var/datum/action/ability/activable/xeno/bombard/bombard_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/bombard]
	if(!bombard_ability)
		return
	range_ability.do_after_length += initial(range_ability.do_after_length) * 1.5
	range_ability.tile_offset += range / 2
	range_ability.view_size += range
	bombard_ability.bonus_max_range += range

/datum/mutation_upgrade/veil/binoculars/on_mutation_disabled()
	var/datum/action/ability/xeno_action/toggle_long_range/range_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toggle_long_range]
	if(!range_ability)
		return
	var/datum/action/ability/activable/xeno/bombard/bombard_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/bombard]
	if(!bombard_ability)
		return
	range_ability.do_after_length -= initial(range_ability.do_after_length) * 1.5
	range_ability.tile_offset -= range / 2
	range_ability.view_size -= range
	bombard_ability.bonus_max_range += range
