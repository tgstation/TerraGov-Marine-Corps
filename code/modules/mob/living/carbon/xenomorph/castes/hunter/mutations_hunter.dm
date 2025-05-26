//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/fleeting_mirage
	name = "Fleeting Mirage"
	desc = "Upon reaching 25/40/55% health, a mirage will appear on a random side of you and run away from you. That mirage takes priority when mirage swapping."
	var/ready = FALSE
	var/timer_id

/datum/mutation_upgrade/shell/fleeting_mirage/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/xeno_action/mirage/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/mirage]
	if(!ability)
		return FALSE
	RegisterSignals(xenomorph_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE), PROC_REF(on_damage))
	if(xenomorph_owner.health >= xenomorph_owner.maxHealth)
		ready = TRUE
	return ..()

/datum/mutation_upgrade/shell/fleeting_mirage/on_mutation_disabled()
	var/datum/action/ability/xeno_action/mirage/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/mirage]
	if(!ability)
		return FALSE
	UnregisterSignal(xenomorph_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE, COMSIG_MOB_STAT_CHANGED))
	ready = FALSE
	if(ability.prioritized_illusion)
		qdel(ability.prioritized_illusion)
		ability.prioritized_illusion = null
		if(timer_id)
			deltimer(timer_id)
			timer_id = null
	return ..()

/// Checks on the next tick if anything needs to be done with their new health since it is possible the health is inaccurate (because there can be other modifiers).
/datum/mutation_upgrade/shell/fleeting_mirage/proc/on_damage(datum/source, amount, list/amount_mod)
	SIGNAL_HANDLER
	INVOKE_NEXT_TICK(src, PROC_REF(check_current_health))

/// If their health is under the threshold, activate it if possible. If it is full, let them activate it next time.
/datum/mutation_upgrade/shell/fleeting_mirage/proc/check_current_health()
	if(!ready && xenomorph_owner.health >= xenomorph_owner.maxHealth)
		ready = TRUE
		return
	var/threshold = xenomorph_owner.maxHealth * min(0.1 + (0.15 * get_total_structures()), 0.7)
	if(!ready || xenomorph_owner.health > threshold || timer_id)
		return
	ready = FALSE
	var/datum/action/ability/xeno_action/mirage/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/mirage]
	if(!ability)
		return
	ability.prioritized_illusion = new /mob/illusion/xeno/fleeing(xenomorph_owner.loc, xenomorph_owner, xenomorph_owner, 240 SECONDS)
	timer_id = addtimer(CALLBACK(src, PROC_REF(remove_illusion)), 240 SECONDS)

/// Checks on the next tick if anything needs to be done with their new health since it is possible the health is inaccurate (because there can be other modifiers).
/datum/mutation_upgrade/shell/fleeting_mirage/proc/remove_illusion()
	var/datum/action/ability/xeno_action/mirage/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/mirage]
	if(!ability)
		return
	qdel(ability.prioritized_illusion)
	ability.prioritized_illusion = null
	if(timer_id)
		deltimer(timer_id)
		timer_id = null

//*********************//
//         Spur        //
//*********************//

//*********************//
//         Veil        //
//*********************//
