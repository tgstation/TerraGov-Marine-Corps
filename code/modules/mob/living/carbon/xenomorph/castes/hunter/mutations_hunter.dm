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
	ability.prioritized_illusion = new /mob/illusion/xeno/fleeing(xenomorph_owner.loc, xenomorph_owner, xenomorph_owner, 10 SECONDS)
	timer_id = addtimer(CALLBACK(src, PROC_REF(remove_illusion)), 10 SECONDS)

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
/datum/mutation_upgrade/spur/debilitating_strike
	name = "Debilitating Strike"
	desc = "Stealth's sneak attack no longer stuns. 1.25/1.5/1.75x of your slash damage is added onto sneak attack instead."

/datum/mutation_upgrade/spur/debilitating_strike/on_mutation_enabled()
	var/datum/action/ability/xeno_action/stealth/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/stealth]
	if(!ability)
		return FALSE
	ability.bonus_stealth_damage_multiplier += 1
	return ..()

/datum/mutation_upgrade/spur/debilitating_strike/on_mutation_disabled()
	var/datum/action/ability/xeno_action/stealth/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/stealth]
	if(!ability)
		return FALSE
	ability.bonus_stealth_damage_multiplier -= 1
	return ..()

/datum/mutation_upgrade/spur/debilitating_strike/on_structure_update(datum/source, previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/xeno_action/stealth/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/stealth]
	if(!ability)
		return FALSE
	ability.bonus_stealth_damage_multiplier += (new_amount - previous_amount) * 0.25

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/one_target
	name = "One Target"
	desc = "The effects of Silence against your Hunter's Mark target last 2.5/2.75/3x as long."

/datum/mutation_upgrade/veil/one_target/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/silence/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/silence]
	if(!ability)
		return FALSE
	ability.hunter_mark_multiplier += 0.75
	return ..()

/datum/mutation_upgrade/veil/one_target/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/silence/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/silence]
	if(!ability)
		return FALSE
	ability.hunter_mark_multiplier -= 0.75
	return ..()

/datum/mutation_upgrade/veil/one_target/on_structure_update(datum/source, previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/silence/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/silence]
	if(!ability)
		return FALSE
	ability.hunter_mark_multiplier += (new_amount - previous_amount) * 0.25
