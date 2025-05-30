//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/acid_sweat
	name = "Acid Sweat"
	desc = "If you are on fire, consume 20/15/10 plasma to extinguish yourself and any fire under you. This only can occur every 1 second."
	/// For the first structure, the amount of plasma consumed.
	var/plasma_initial = 25
	/// For each structure, the additional amount of plasma consumed.
	var/plasma_per_structure = -5
	/// Timer ID for a proc that revokes the armor given when it times out.
	var/timer_id
	/// How long is the cooldown?
	var/timer_length = 1 SECONDS
	/// Can this be activated?
	var/ready = FALSE

/datum/mutation_upgrade/shell/acid_sweat/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "If you are on fire, consume [plasma_initial + (plasma_per_structure * new_amount)] plasma to extinguish yourself and any fire under you. This only can occur every [timer_length / 10] second."

/datum/mutation_upgrade/shell/acid_sweat/on_mutation_enabled()
	RegisterSignal(xenomorph_owner, COMSIG_LIVING_IGNITED, PROC_REF(try_extinguish))
	try_extinguish()
	return ..()

/datum/mutation_upgrade/shell/acid_sweat/on_mutation_disabled()
	UnregisterSignal(xenomorph_owner, COMSIG_LIVING_IGNITED)
	if(timer_id)
		deltimer(timer_id)
		timer_id = null
	return ..()

/// Extinguishes the owner and qdel all fires underneath them if possible.
/datum/mutation_upgrade/shell/acid_sweat/proc/try_extinguish()
	if(!xenomorph_owner.on_fire || timer_id)
		return
	var/plasma_cost = plasma_initial + (get_total_structures() * plasma_per_structure)
	if(xenomorph_owner.plasma_stored < plasma_cost)
		return
	xenomorph_owner.use_plasma(plasma_cost)
	xenomorph_owner.ExtinguishMob()
	for(var/obj/fire/fire_in_turf in get_turf(xenomorph_owner))
		qdel(fire_in_turf)
	if(timer_length)
		timer_id = addtimer(CALLBACK(src, PROC_REF(try_extinguish)), timer_length, TIMER_STOPPABLE|TIMER_UNIQUE)

/// Immediately after being set on fire, tries to extinguishes the owner and qdel all fires underneath them if possible.
/datum/mutation_upgrade/shell/acid_sweat/proc/on_ignited(datum/source, fire_stacks)
	SIGNAL_HANDLER
	try_extinguish()

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/hit_and_run
	name = "Hit and Run"
	desc = "Scatter Spit takes 40/60/80% less time to cast. It deals 50% of its original damage."
	/// For the first structure, the multiplier used to increase the cast time by.
	var/cast_time_multiplier_initial = -0.2
	/// For each structure, the additional multiplier used to increase the cast time by.
	var/cast_time_multiplier_per_structure = -0.2
	/// The multiplier used to increase the damage by.
	var/damage_multiplier = -0.5

/datum/mutation_upgrade/spur/hit_and_run/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Scatter Spit takes [(cast_time_multiplier_initial + (cast_time_multiplier_per_structure * new_amount)) * -100]% less time to cast. It deals [1 - (damage_multiplier * -100)]% of its original damage."

/datum/mutation_upgrade/spur/hit_and_run/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/scatter_spit/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/scatter_spit]
	if(!ability)
		return FALSE
	ability.cast_time += initial(ability.cast_time) * cast_time_multiplier_initial
	var/datum/ammo/xeno/acid/heavy/scatter/scatter_spit = GLOB.ammo_list[/datum/ammo/xeno/acid/heavy/scatter]
	ability.bonus_damage += scatter_spit.damage * damage_multiplier
	return ..()

/datum/mutation_upgrade/spur/hit_and_run/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/scatter_spit/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/scatter_spit]
	if(!ability)
		return FALSE
	ability.cast_time -= initial(ability.cast_time) * cast_time_multiplier_initial
	var/datum/ammo/xeno/acid/heavy/scatter/scatter_spit = GLOB.ammo_list[/datum/ammo/xeno/acid/heavy/scatter]
	ability.bonus_damage -= scatter_spit.damage * damage_multiplier
	return ..()

/datum/mutation_upgrade/spur/hit_and_run/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/scatter_spit/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/scatter_spit]
	if(!ability)
		return FALSE
	ability.cast_time += initial(ability.cast_time) * (new_amount - previous_amount) * cast_time_multiplier_per_structure

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/wet_claws
	name = "Wet Claws"
	desc = "Slashing humans will reduce their fire stacks by 1/2/3."
	/// For each structure, the amount of fire stacks to add.
	var/fire_stack_per_structure = -1

/datum/mutation_upgrade/veil/wet_claws/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Slashing humans will reduce their fire stacks by [(fire_stack_per_structure * new_amount) * -1]."

/datum/mutation_upgrade/veil/wet_claws/on_mutation_enabled()
	RegisterSignal(xenomorph_owner, COMSIG_XENOMORPH_POSTATTACK_LIVING, PROC_REF(on_postattack_living))

/datum/mutation_upgrade/veil/wet_claws/on_mutation_disabled()
	UnregisterSignal(xenomorph_owner, COMSIG_XENOMORPH_POSTATTACK_LIVING)

/// Adjusts fire stacks of the hit target by a variable amount.
/datum/mutation_upgrade/veil/wet_claws/proc/on_postattack_living(mob/living/carbon/xenomorph/source, mob/living/target, damage)
	SIGNAL_HANDLER
	if(!target.on_fire)
		return
	target.adjust_fire_stacks(fire_stack_per_structure * get_total_structures())
