//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/acid_release
	name = "Acid Release"
	desc = "Upon entering critical, release stunning acid in a radius of 3 tiles. This resets upon reaching full health."
	/// The radius in which stunning acid is created.
	var/radius = 3
	/// If the effect can be activated.
	var/can_be_activated = FALSE

/datum/mutation_upgrade/shell/acid_release/on_mutation_enabled()
	RegisterSignals(xenomorph_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE), PROC_REF(on_damage))
	RegisterSignal(xenomorph_owner, COMSIG_MOB_STAT_CHANGED, PROC_REF(on_stat_changed))
	if(xenomorph_owner.health >= xenomorph_owner.maxHealth)
		can_be_activated = TRUE

/datum/mutation_upgrade/shell/acid_release/on_mutation_disabled()
	UnregisterSignal(xenomorph_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE, COMSIG_MOB_STAT_CHANGED))
	can_be_activated = FALSE

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
	for(var/turf/acid_tile AS in RANGE_TURFS(radius, current_turf))
		if(!line_of_sight(current_turf, acid_tile))
			continue
		xenomorph_spray(acid_tile, 6 SECONDS, 16, xenomorph_owner, TRUE, TRUE)
	can_be_activated = FALSE

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/fully_acid
	name = "Fully Acid"
	desc = "All of your stash damage is burn damage and is now checked against acid. You inflict 2 additional melting acid stacks."
	/// The additional stacks of melting acid.
	var/stacks = 2

/datum/mutation_upgrade/spur/fully_acid/on_mutation_enabled()
	if(!isxenomelter(xenomorph_owner))
		return
	var/mob/living/carbon/xenomorph/runner/melter/melter_owner = xenomorph_owner
	melter_owner.second_damage_type = BURN
	melter_owner.second_damage_armor = ACID
	melter_owner.applied_acid_stacks += stacks

/datum/mutation_upgrade/spur/fully_acid/on_mutation_disabled()
	if(!isxenomelter(xenomorph_owner))
		return
	var/mob/living/carbon/xenomorph/runner/melter/melter_owner = xenomorph_owner
	melter_owner.second_damage_type = initial(melter_owner.second_damage_type)
	melter_owner.second_damage_armor = initial(melter_owner.second_damage_armor)
	melter_owner.applied_acid_stacks += stacks

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/acid_reserves
	name = "Acid Reserves"
	desc = "Corrosive Acid is now applied 75% faster."
	/// The percentage to speed up Corrosive Acid by.
	var/speedup = 0.75

/datum/mutation_upgrade/veil/acid_reserves/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/corrosive_acid/melter/acid_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/corrosive_acid/melter]
	if(!acid_ability)
		return
	acid_ability.acid_speed_multiplier /= (1 + speedup)

/datum/mutation_upgrade/veil/acid_reserves/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/corrosive_acid/melter/acid_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/corrosive_acid/melter]
	if(!acid_ability)
		return
	acid_ability.acid_speed_multiplier *= (1 + speedup)
