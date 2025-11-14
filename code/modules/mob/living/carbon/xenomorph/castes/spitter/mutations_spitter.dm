//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/acid_sweat
	name = "Acid Sweat"
	desc = "If you are on fire, consume 20/15/10 plasma to extinguish yourself and any fire under you. This only can occur every 1 second."
	/// For the first structure, the amount of plasma consumed.
	var/cost_initial = 25
	/// For each structure, the additional amount of plasma consumed.
	var/cost_per_structure = -5
	/// The ID of a timer that will check if the owner needs to be re-extinguished.
	var/timer_id
	/// How long is the timer?
	var/timer_length = 1 SECONDS

/datum/mutation_upgrade/shell/acid_sweat/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "If you are on fire, consume [get_cost(new_amount)] plasma to extinguish yourself and any fire under you. This only can occur every [timer_length * 0.1] second."

/datum/mutation_upgrade/shell/acid_sweat/on_mutation_enabled()
	RegisterSignal(xenomorph_owner, COMSIG_LIVING_IGNITED, PROC_REF(on_ignited))
	try_extinguish()
	return ..()

/datum/mutation_upgrade/shell/acid_sweat/on_mutation_disabled()
	UnregisterSignal(xenomorph_owner, COMSIG_LIVING_IGNITED)
	if(timer_id)
		deltimer(timer_id)
		timer_id = null
	return ..()

/// Extinguishes the owner and qdel all fires underneath them if possible.
/datum/mutation_upgrade/shell/acid_sweat/proc/try_extinguish(timed_extinguished = FALSE)
	if(timer_id)
		if(!timed_extinguished)
			return
		deltimer(timer_id)
		timer_id = null
	if(!xenomorph_owner.on_fire)
		return
	var/plasma_cost = get_cost(get_total_structures())
	if(xenomorph_owner.plasma_stored < plasma_cost)
		return
	xenomorph_owner.use_plasma(plasma_cost)
	xenomorph_owner.ExtinguishMob()
	for(var/obj/fire/fire_in_turf in get_turf(xenomorph_owner))
		qdel(fire_in_turf)
	if(timer_length) // To re-extinguish them if they were set on fire while the timer is active.
		timer_id = addtimer(CALLBACK(src, PROC_REF(try_extinguish), TRUE), timer_length, TIMER_STOPPABLE|TIMER_UNIQUE)

/// Immediately after being set on fire, tries to extinguishes the owner and qdel all fires underneath them if possible.
/datum/mutation_upgrade/shell/acid_sweat/proc/on_ignited(datum/source, fire_stacks)
	SIGNAL_HANDLER
	try_extinguish()

/// Returns the amount of plasma that will be used.
/datum/mutation_upgrade/shell/acid_sweat/proc/get_cost(structure_count)
	return cost_initial + (cost_per_structure * structure_count)

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/hit_and_run
	name = "Hit and Run"
	desc = "Scatter Spit's cast time is 60/40/20% of its original amount. It no longer deals bonus damage."
	/// For the first structure, the multiplier used to add to Scatter Spit's cast time.
	var/cast_multiplier_initial = -0.2
	/// For each structure, the multiplier used to add to Scatter Spit's cast time.
	var/cast_multiplier_per_structure = -0.2

/datum/mutation_upgrade/spur/hit_and_run/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Scatter Spit cast time is [PERCENT(1 + get_cast_multiplier(new_amount))]% of its original amount. It no longer deals bonus damage."

/datum/mutation_upgrade/spur/hit_and_run/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/scatter_spit/scatter_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/scatter_spit]
	if(!scatter_ability)
		return
	scatter_ability.cast_time += initial(scatter_ability.cast_time) * get_cast_multiplier(0)
	scatter_ability.should_get_upgrade_bonus = FALSE
	return ..()

/datum/mutation_upgrade/spur/hit_and_run/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/scatter_spit/scatter_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/scatter_spit]
	if(!scatter_ability)
		return
	scatter_ability.cast_time -= initial(scatter_ability.cast_time) * get_cast_multiplier(0)
	scatter_ability.should_get_upgrade_bonus = initial(scatter_ability.should_get_upgrade_bonus)
	return ..()

/datum/mutation_upgrade/spur/hit_and_run/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/scatter_spit/scatter_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/scatter_spit]
	if(!scatter_ability)
		return
	scatter_ability.cast_time += initial(scatter_ability.cast_time) * get_cast_multiplier(new_amount - previous_amount, FALSE)

/// Returns the amount to multiply the Scatter Spit's initial cast time which will then be used to increase it.
/datum/mutation_upgrade/spur/hit_and_run/proc/get_cast_multiplier(structure_count, include_initial = TRUE)
	return (include_initial ? cast_multiplier_initial : 0) + (cast_multiplier_per_structure * structure_count)

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/wet_claws
	name = "Wet Claws"
	desc = "Slashing humans will reduce their fire stacks by 1/2/3."
	/// For each structure, the amount of fire stacks to add.
	var/stacks_per_structure = -1

/datum/mutation_upgrade/veil/wet_claws/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Slashing humans will reduce their fire stacks by [-get_stacks(new_amount)]."

/datum/mutation_upgrade/veil/wet_claws/on_mutation_enabled()
	RegisterSignal(xenomorph_owner, COMSIG_XENOMORPH_POSTATTACK_LIVING, PROC_REF(on_postattack_living))

/datum/mutation_upgrade/veil/wet_claws/on_mutation_disabled()
	UnregisterSignal(xenomorph_owner, COMSIG_XENOMORPH_POSTATTACK_LIVING)

/// Adjusts fire stacks of the hit target by a variable amount.
/datum/mutation_upgrade/veil/wet_claws/proc/on_postattack_living(mob/living/carbon/xenomorph/source, mob/living/target, damage)
	SIGNAL_HANDLER
	if(!target.on_fire)
		return
	target.adjust_fire_stacks(get_stacks(get_total_structures()))

/// Returns the amount to multiply the Scatter Spit's initial cast time which will then be used to increase it.
/datum/mutation_upgrade/veil/wet_claws/proc/get_stacks(structure_count)
	return stacks_per_structure * structure_count
