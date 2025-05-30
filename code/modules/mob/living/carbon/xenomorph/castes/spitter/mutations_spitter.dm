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
	RegisterSignal(xenomorph_owner, COMSIG_LIVING_IGNITED, PROC_REF(is_set_on_fire))
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

//*********************//
//         Veil        //
//*********************//
