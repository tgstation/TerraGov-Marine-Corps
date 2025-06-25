//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/little_more
	name = "Little More"
	desc = "Endure's critical and death threshold is increased by 20/35/50."
	/// For the first structure, the amount of critical/death threshold to give.
	var/threshold_initial = 5
	/// For each structure, the amount of critical/death threshold to give.
	var/threshold_per_structure = 15

/datum/mutation_upgrade/shell/little_more/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Endure's critical and death threshold is increased by [get_threshold(new_amount)]."

/datum/mutation_upgrade/shell/little_more/on_mutation_enabled()
	var/datum/action/ability/xeno_action/endure/endure = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/endure]
	if(!endure)
		return FALSE
	endure.endure_threshold += get_threshold(0)
	return ..()

/datum/mutation_upgrade/shell/little_more/on_mutation_disabled()
	var/datum/action/ability/xeno_action/endure/endure = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/endure]
	if(!endure)
		return FALSE
	endure.endure_threshold -= get_threshold(0)
	return ..()

/datum/mutation_upgrade/shell/little_more/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/xeno_action/endure/endure = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/endure]
	if(!endure)
		return
	endure.endure_threshold += get_threshold(new_amount - previous_amount)

/// Returns the amount of critical/death threshold that the mutation should be giving.
/datum/mutation_upgrade/shell/little_more/proc/get_threshold(structure_count, include_initial = TRUE)
	return (include_initial ? threshold_initial : 0) + (threshold_per_structure * structure_count)

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/deep_slash
	name = "Deep Slash"
	desc = "Ravage's armor penetration is increased by 10/15/20."
	/// For the first structure, the amount of armor penetration to give.
	var/ap_initial = 5
	/// For each structure, the amount of armor penetration to give.
	var/ap_per_structure = 5

/datum/mutation_upgrade/spur/deep_slash/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Ravage's armor penetration is increased by 10/15/20."

/datum/mutation_upgrade/spur/deep_slash/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/ravage/ravage = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/ravage]
	if(!ravage)
		return FALSE
	ravage.armor_penetration += get_ap(0)
	return ..()

/datum/mutation_upgrade/spur/deep_slash/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/ravage/ravage = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/ravage]
	if(!ravage)
		return FALSE
	ravage.armor_penetration -= get_ap(0)
	return ..()

/datum/mutation_upgrade/spur/deep_slash/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/ravage/ravage = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/ravage]
	if(!ravage)
		return
	ravage.armor_penetration += get_ap(new_amount - previous_amount)

/// Returns the amount of armor penetration that the mutation should be giving.
/datum/mutation_upgrade/spur/deep_slash/proc/get_ap(structure_count, include_initial = TRUE)
	return (include_initial ? ap_initial : 0) + (ap_per_structure * structure_count)


//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/recurring_rage
	name = "Recurring Rage"
	desc = "Rage will automatically attempt to activate when your health reaches the minimum required threshold. Rage's cooldown is 90/80/70% of its original cooldown."
	/// For each structure, the multiplier to increase the cooldown by.
	var/cooldown_multiplier_per_structure = -0.1

/datum/mutation_upgrade/veil/recurring_rage/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Rage will automatically attempt to activate when your health reaches the minimum required threshold. Rage's cooldown is [PERCENT(1 - get_multiplier(new_amount))]% of its original cooldown."

/datum/mutation_upgrade/veil/recurring_rage/on_mutation_enabled()
	var/datum/action/ability/xeno_action/rage/rage = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/rage]
	if(!rage)
		return FALSE
	RegisterSignals(xenomorph_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE), PROC_REF(on_damage))
	return ..()

/datum/mutation_upgrade/shell/borrowed_time/on_mutation_disabled()

	return ..()

/datum/mutation_upgrade/veil/recurring_rage/on_mutation_disabled()
	var/datum/action/ability/xeno_action/rage/rage = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/rage]
	if(!rage)
		return FALSE
	UnregisterSignal(xenomorph_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE))
	return ..()

/datum/mutation_upgrade/veil/recurring_rage/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/xeno_action/rage/rage = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/rage]
	if(!rage)
		return FALSE
	rage.cooldown_duration += initial(rage.cooldown_duration) * get_multiplier(new_amount - previous_amount)

/// Returns the multiplier that the mutation should be adding to the ability's cooldown.
/datum/mutation_upgrade/veil/recurring_rage/proc/get_multiplier(structure_count)
	return cooldown_multiplier_per_structure * structure_count

/// Checks on the next tick if anything needs to be done with their new health since it is possible the health is inaccurate (because there can be other modifiers).
/datum/mutation_upgrade/veil/recurring_rage/proc/on_damage(datum/source, amount, list/amount_mod)
	SIGNAL_HANDLER
	INVOKE_NEXT_TICK(src, PROC_REF(check_current_health))

/// Checks if Rage can be activated. If so, activate it.
/datum/mutation_upgrade/veil/recurring_rage/proc/check_current_health()
	var/datum/action/ability/xeno_action/rage/rage = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/rage]
	if(!rage?.can_use_action(silent = TRUE))
		return
	rage.action_activate()
