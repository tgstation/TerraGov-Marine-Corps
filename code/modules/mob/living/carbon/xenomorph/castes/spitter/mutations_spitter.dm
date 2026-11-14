//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/acid_sweat
	name = "Acid Sweat"
	desc = "If you are on fire, consume 15 plasma to extinguish yourself and any fire under you. This only can occur every 1 second."
	/// The amount of plasma consumed.
	var/plasma_cost = 15
	/// The ID of a timer that will check if the owner needs to be re-extinguished.
	var/timer_id
	/// How long is the timer?
	var/timer_length = 1 SECONDS

/datum/mutation_upgrade/shell/acid_sweat/on_mutation_enabled()
	RegisterSignal(xenomorph_owner, COMSIG_LIVING_IGNITED, PROC_REF(on_ignited))
	try_extinguish()

/datum/mutation_upgrade/shell/acid_sweat/on_mutation_disabled()
	UnregisterSignal(xenomorph_owner, COMSIG_LIVING_IGNITED)
	if(timer_id)
		deltimer(timer_id)
		timer_id = null

/// Extinguishes the owner and qdel all fires underneath them if possible.
/datum/mutation_upgrade/shell/acid_sweat/proc/try_extinguish(timed_extinguished = FALSE)
	if(timer_id)
		if(!timed_extinguished)
			return
		deltimer(timer_id)
		timer_id = null
	if(!xenomorph_owner.is_on_fire())
		return
	if(xenomorph_owner.plasma_stored < plasma_cost)
		return
	xenomorph_owner.use_plasma(plasma_cost)
	xenomorph_owner.extinguish_mob()
	for(var/obj/fire/fire_in_turf in get_turf(xenomorph_owner))
		qdel(fire_in_turf)
	if(timer_length) // To re-extinguish them if they were set on fire while the timer is active.
		timer_id = addtimer(CALLBACK(src, PROC_REF(try_extinguish), TRUE), timer_length, TIMER_STOPPABLE|TIMER_UNIQUE)

/// Immediately after being set on fire, tries to extinguishes the owner and qdel all fires underneath them if possible.
/datum/mutation_upgrade/shell/acid_sweat/proc/on_ignited(datum/source, fire_stacks)
	SIGNAL_HANDLER
	try_extinguish()

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/hit_and_run
	name = "Hit and Run"
	desc = "Scatter Spit's cast time is 40% of its original amount. It no longer deals bonus damage."
	/// The multiplier used to add to Scatter Spit's cast time.
	var/cast_multiplier = -0.6

/datum/mutation_upgrade/spur/hit_and_run/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/scatter_spit/scatter_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/scatter_spit]
	if(!scatter_ability)
		return
	scatter_ability.cast_time += initial(scatter_ability.cast_time) * cast_multiplier
	scatter_ability.should_get_upgrade_bonus = FALSE

/datum/mutation_upgrade/spur/hit_and_run/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/scatter_spit/scatter_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/scatter_spit]
	if(!scatter_ability)
		return
	scatter_ability.cast_time -= initial(scatter_ability.cast_time) * cast_multiplier
	scatter_ability.should_get_upgrade_bonus = initial(scatter_ability.should_get_upgrade_bonus)

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/wet_claws
	name = "Wet Claws"
	desc = "Slashing humans will reduce their fire stacks by 2."
	/// The amount of fire stacks to add.
	var/stacks = -2

/datum/mutation_upgrade/veil/wet_claws/on_mutation_enabled()
	RegisterSignal(xenomorph_owner, COMSIG_XENOMORPH_POSTATTACK_LIVING, PROC_REF(on_postattack_living))

/datum/mutation_upgrade/veil/wet_claws/on_mutation_disabled()
	UnregisterSignal(xenomorph_owner, COMSIG_XENOMORPH_POSTATTACK_LIVING)

/// Adjusts fire stacks of the hit target by a variable amount.
/datum/mutation_upgrade/veil/wet_claws/proc/on_postattack_living(mob/living/carbon/xenomorph/source, mob/living/target, damage)
	SIGNAL_HANDLER
	if(!target.is_on_fire())
		return
	target.adjust_fire_stacks(stacks)
