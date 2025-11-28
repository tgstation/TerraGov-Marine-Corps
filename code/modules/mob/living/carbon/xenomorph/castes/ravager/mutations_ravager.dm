//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/little_more
	name = "Little More"
	desc = "Endure further decreases your critical and death threshold by 30/40/50."
	/// For the first structure, the amount to increase the death/critical threshold given by Endure while it is active.
	var/threshold_initial = -20
	/// For each structure, the amount to increase the death/critical threshold given by Endure while it is active.
	var/threshold_per_structure = -10

/datum/mutation_upgrade/shell/little_more/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Endure further decreases your critical and death threshold by [-get_threshold(new_amount)]."

/datum/mutation_upgrade/shell/little_more/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/xeno_action/endure/endure_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/endure]
	if(!endure_ability)
		return
	endure_ability.endure_threshold += get_threshold(0)

/datum/mutation_upgrade/shell/little_more/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/xeno_action/endure/endure_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/endure]
	if(!endure_ability)
		return
	endure_ability.endure_threshold -= get_threshold(0)

/datum/mutation_upgrade/shell/little_more/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/xeno_action/endure/endure_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/endure]
	if(!endure_ability)
		return
	endure_ability.endure_threshold += get_threshold(new_amount - previous_amount, FALSE)

/// Returns the amount to increase the death/critical threshold given by Endure while it is active.
/datum/mutation_upgrade/shell/little_more/proc/get_threshold(structure_count, include_initial = TRUE)
	return (include_initial ? threshold_initial : 0) + (threshold_per_structure * structure_count)

/datum/mutation_upgrade/shell/keep_going
	name = "Keep Going"
	desc = "Endure lasts 70/80/90% as long, but duration-increasing slashes is now available during normal Rage."
	/// For the first structure, the multiplier to add to Endure's duration.
	var/multiplier_initial = -0.4
	/// For each structure, the additional multiplier to add to Endure's duration.
	var/multiplier_per_structure = 0.1

/datum/mutation_upgrade/shell/keep_going/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Endure lasts [PERCENT(1 + get_multiplier(new_amount))]% as long, but duration-increasing slashes is now available during normal Rage."

/datum/mutation_upgrade/shell/keep_going/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/xeno_action/endure/endure_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/endure]
	if(!endure_ability)
		return
	var/datum/action/ability/xeno_action/rage/rage_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/rage]
	if(!rage_ability)
		return
	endure_ability.endure_duration += initial(endure_ability.endure_duration) * get_multiplier(0)
	rage_ability.extends_via_normal_rage = TRUE

/datum/mutation_upgrade/shell/keep_going/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/xeno_action/endure/endure_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/endure]
	if(!endure_ability)
		return
	var/datum/action/ability/xeno_action/rage/rage_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/rage]
	if(!rage_ability)
		return
	endure_ability.endure_duration -= initial(endure_ability.endure_duration) * get_multiplier(0)
	rage_ability.extends_via_normal_rage = FALSE

/datum/mutation_upgrade/shell/keep_going/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/xeno_action/endure/endure_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/endure]
	if(!endure_ability)
		return
	endure_ability.endure_duration += initial(endure_ability.endure_duration) * get_multiplier(new_amount - previous_amount, FALSE)

/// Returns the multiplier to add to Endure's duration.
/datum/mutation_upgrade/shell/keep_going/proc/get_multiplier(structure_count, include_initial = TRUE)
	return (include_initial ? multiplier_initial : 0) + (multiplier_per_structure * structure_count)

/datum/mutation_upgrade/shell/inward_focus
	name = "Inward Focus"
	desc = "Endure no longer grants stagger immunity nor can be activated while staggered. Endure grants 10/15/20 all soft armor while active."
	/// For the first structure, the amount of all soft armor that Endure should give while active.
	var/armor_initial = 5
	/// For each structure, the additional amount of all soft armor that Endure should give while active.
	var/armor_per_structure = 5

/datum/mutation_upgrade/shell/inward_focus/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Endure no longer grants stagger immunity nor can be activated while staggered. Endure grants [get_armor(new_amount)] all soft armor while active."

/datum/mutation_upgrade/shell/inward_focus/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/xeno_action/endure/endure_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/endure]
	if(!endure_ability)
		return
	endure_ability.use_state_flags &= ~ABILITY_USE_STAGGERED
	endure_ability.endure_stagger_immunity = FALSE
	endure_ability.endure_armor += get_armor(0)
	if(endure_ability.endure_timer)
		REMOVE_TRAIT(xenomorph_owner, TRAIT_STAGGERIMMUNE, ENDURE_TRAIT)

/datum/mutation_upgrade/shell/inward_focus/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/xeno_action/endure/endure_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/endure]
	if(!endure_ability)
		return
	endure_ability.use_state_flags |= ABILITY_USE_STAGGERED
	endure_ability.endure_stagger_immunity = TRUE
	endure_ability.endure_armor -= get_armor(0)
	if(endure_ability.endure_timer)
		ADD_TRAIT(xenomorph_owner, TRAIT_STAGGERIMMUNE, ENDURE_TRAIT)

/datum/mutation_upgrade/shell/inward_focus/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/xeno_action/endure/endure_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/endure]
	if(!endure_ability)
		return
	endure_ability.endure_armor += get_armor(new_amount - previous_amount, FALSE)
	if(endure_ability.attached_armor)
		xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.detachArmor(endure_ability.attached_armor)
		endure_ability.attached_armor = null
	if(endure_ability.endure_timer && endure_ability.endure_armor)
		var/total_armor = endure_ability.endure_armor
		endure_ability.attached_armor = new(total_armor, total_armor, total_armor, total_armor, total_armor, total_armor, total_armor, total_armor)
		xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.attachArmor(endure_ability.attached_armor)

/// Returns the amount of all soft armor that Endure should give while active.
/datum/mutation_upgrade/shell/inward_focus/proc/get_armor(structure_count, include_initial = TRUE)
	return (include_initial ? armor_initial : 0) + (armor_per_structure * structure_count)

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/deep_slash
	name = "Deep Slash"
	desc = "Ravage now has an additional 10/15/20 armor penetration."
	/// For the first structure, the amount of armor penetration that all slash attacks caused by Ravage to have.
	var/ap_initial = 5
	/// For each structure, the amount of armor penetration that all slash attacks caused by Ravage to have.
	var/ap_per_structure = 5

/datum/mutation_upgrade/spur/deep_slash/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Ravage now has an additional [get_ap(new_amount)] armor penetration."

/datum/mutation_upgrade/spur/deep_slash/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/activable/xeno/ravage/ravage_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/ravage]
	if(!ravage_ability)
		return
	ravage_ability.armor_penetration += get_ap(0)

/datum/mutation_upgrade/spur/deep_slash/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/ravage/ravage_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/ravage]
	if(!ravage_ability)
		return
	ravage_ability.armor_penetration -= get_ap(0)

/datum/mutation_upgrade/spur/deep_slash/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/ravage/ravage_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/ravage]
	if(!ravage_ability)
		return
	ravage_ability.armor_penetration += get_ap(new_amount - previous_amount, FALSE)

/// Returns the amount of armor penetration that all slash attacks during Ravage will have.
/datum/mutation_upgrade/spur/deep_slash/proc/get_ap(structure_count, include_initial = TRUE)
	return (include_initial ? ap_initial : 0) + (ap_per_structure * structure_count)

/datum/mutation_upgrade/spur/super_cut
	name = "Super Cut"
	desc = "Ravage now slashes in all directions, but has a cast time of 0.6/0.4/0.2 seconds."
	/// For the first structure, the amount of deciseconds to add to Ravage's cast time.
	var/time_initial = 0.8 SECONDS
	/// For each structure, the additional amount of deciseconds to add to Ravage's cast time.
	var/time_per_structure = -0.2 SECONDS

/datum/mutation_upgrade/spur/super_cut/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Ravage now slashes in all directions, but has a cast time of [get_time(new_amount) / 10] seconds."

/datum/mutation_upgrade/spur/super_cut/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/activable/xeno/ravage/ravage_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/ravage]
	if(!ravage_ability)
		return
	ravage_ability.cast_time += get_time(0)
	ravage_ability.aoe = TRUE

/datum/mutation_upgrade/spur/super_cut/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/ravage/ravage_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/ravage]
	if(!ravage_ability)
		return
	ravage_ability.cast_time -= get_time(0)
	ravage_ability.aoe = FALSE

/datum/mutation_upgrade/spur/super_cut/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/ravage/ravage_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/ravage]
	if(!ravage_ability)
		return
	ravage_ability.cast_time += get_time(new_amount - previous_amount, FALSE)

/// Returns the amount of deciseconds to add to Ravage's cast time.
/datum/mutation_upgrade/spur/super_cut/proc/get_time(structure_count, include_initial = TRUE)
	return (include_initial ? time_initial : 0) + (time_per_structure * structure_count)

/datum/mutation_upgrade/spur/onslaught
	name = "Onslaught"
	desc = "Eviscerating Charge's cooldown duration is set to 20/15/10% of its original value, but it no longer stuns."
	/// For the first structure, the multiplier to add to Eviscerating Charge's cooldown duration.
	var/multiplier_initial = -0.75
	/// For each structure, the additional multiplier to add to Eviscerating Charge's cooldown duration.
	var/multiplier_per_structure = -0.05

/datum/mutation_upgrade/spur/onslaught/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Eviscerating Charge's cooldown duration is set to [PERCENT(1 + get_multiplier(new_amount))]% of its original value, but it no longer stuns."

/datum/mutation_upgrade/spur/onslaught/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/activable/xeno/charge/charge_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/charge]
	if(!charge_ability)
		return
	charge_ability.cooldown_duration += initial(charge_ability.cooldown_duration) * get_multiplier(0)
	charge_ability.paralyze_duration -= initial(charge_ability.paralyze_duration)

/datum/mutation_upgrade/spur/onslaught/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/charge/charge_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/charge]
	if(!charge_ability)
		return
	charge_ability.cooldown_duration -= initial(charge_ability.cooldown_duration) * get_multiplier(0)
	charge_ability.paralyze_duration += initial(charge_ability.paralyze_duration)

/datum/mutation_upgrade/spur/onslaught/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/charge/charge_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/charge]
	if(!charge_ability)
		return
	charge_ability.cooldown_duration += initial(charge_ability.cooldown_duration) * get_multiplier(new_amount - previous_amount, FALSE)

/// Returns the multiplier to add to Eviscerating Charge's cooldown duration.
/datum/mutation_upgrade/spur/onslaught/proc/get_multiplier(structure_count, include_initial = TRUE)
	return (include_initial ? multiplier_initial : 0) + (multiplier_per_structure * structure_count)

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/recurring_rage
	name = "Recurring Rage"
	desc = "Rage will automatically attempt to activate when your health reaches the minimum required threshold. Rage's cooldown duration is set to 60/50/40% of its original value."
	/// For the first structure, the multiplier of Rage's initial cooldown to add to the ability.
	var/multiplier_initial = -0.3
	/// For each structure, the additional multiplier of Rage's initial cooldown to add to the ability.
	var/multiplier_per_structure = -0.1

/datum/mutation_upgrade/veil/recurring_rage/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Rage will automatically attempt to activate when your health reaches the minimum required threshold. Rage's cooldown duration is [PERCENT(1 + get_multiplier(new_amount))]% of its original value."

/datum/mutation_upgrade/veil/recurring_rage/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/xeno_action/rage/rage_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/rage]
	if(!rage_ability)
		return
	rage_ability.cooldown_duration += initial(rage_ability.cooldown_duration) * get_multiplier(0)
	RegisterSignal(xenomorph_owner, list(COMSIG_LIVING_UPDATE_HEALTH), PROC_REF(on_update_health))

/datum/mutation_upgrade/veil/recurring_rage/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/xeno_action/rage/rage_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/rage]
	if(!rage_ability)
		return
	rage_ability.cooldown_duration -= initial(rage_ability.cooldown_duration) * get_multiplier(0)
	UnregisterSignal(xenomorph_owner, COMSIG_LIVING_UPDATE_HEALTH)

/datum/mutation_upgrade/veil/recurring_rage/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/xeno_action/rage/rage_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/rage]
	if(!rage_ability)
		return
	rage_ability.cooldown_duration += initial(rage_ability.cooldown_duration) * get_multiplier(new_amount - previous_amount, FALSE)

/// Returns the multiplier of Rage's initial cooldown to add to the ability.
/datum/mutation_upgrade/veil/recurring_rage/proc/get_multiplier(structure_count, include_initial = TRUE)
	return (include_initial ? multiplier_initial : 0) + (multiplier_per_structure * structure_count)

/// Checks if Rage can be activated. If so, activate it.
/datum/mutation_upgrade/veil/recurring_rage/proc/on_update_health()
	SIGNAL_HANDLER
	var/health = (xenomorph_owner.status_flags & GODMODE) ? xenomorph_owner.maxHealth : (xenomorph_owner.maxHealth - xenomorph_owner.getFireLoss() - xenomorph_owner.getBruteLoss())
	if(health <= xenomorph_owner.get_death_threshold())
		return
	var/datum/action/ability/xeno_action/rage/rage_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/rage]
	if(!rage_ability)
		return
	if(!rage_ability.action_cooldown_finished() || !rage_ability.can_use_action(silent = TRUE))
		return
	rage_ability.action_activate()

/datum/mutation_upgrade/veil/fight_in_flames
	name = "Fight in Flames"
	desc = "You lose 70 fire armor. The plasma gain from stepping into fire is now also given for being on fire. This plasma gain is increased by 200/250/300."
	/// For the first structure, the bonus amount of plasma when they are damaged from being on fire.
	var/plasma_initial = 150
	/// For each structure, the additional bonus amount of plasma when they are damaged from being on fire.
	var/plasma_per_structure = 50
	/// The attached soft armor, if any.
	var/datum/armor/attached_armor

/datum/mutation_upgrade/veil/fight_in_flames/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "You lose 70 fire armor. The plasma gain from stepping into fire is now also given for being on fire. This plasma gain is increased by [get_plasma(new_amount)]."

/datum/mutation_upgrade/veil/fight_in_flames/on_mutation_enabled()
	. = ..()
	if(!isxenoravager(xenomorph_owner))
		return
	RegisterSignal(xenomorph_owner, COMSIG_LIVING_HANDLE_FIRE, PROC_REF(on_handle_fire))
	attached_armor = getArmor(fire = -70)
	xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.attachArmor(attached_armor)
	var/mob/living/carbon/xenomorph/ravager/ravager_owner = xenomorph_owner
	ravager_owner.plasma_gain_from_fire += get_plasma(0)

/datum/mutation_upgrade/veil/fight_in_flames/on_mutation_disabled()
	. = ..()
	if(!isxenoravager(xenomorph_owner))
		return
	UnregisterSignal(xenomorph_owner, COMSIG_LIVING_HANDLE_FIRE)
	var/mob/living/carbon/xenomorph/ravager/ravager_owner = xenomorph_owner
	ravager_owner.plasma_gain_from_fire -= get_plasma(0)
	xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.detachArmor(attached_armor)
	attached_armor = null

/datum/mutation_upgrade/veil/fight_in_flames/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!isxenoravager(xenomorph_owner))
		return
	var/mob/living/carbon/xenomorph/ravager/ravager_owner = xenomorph_owner
	ravager_owner.plasma_gain_from_fire += get_plasma(new_amount - previous_amount, FALSE)

/// Returns the bonus amount of plasma when they are damaged from being on fire.
/datum/mutation_upgrade/veil/fight_in_flames/proc/get_plasma(structure_count, include_initial = TRUE)
	return (include_initial ? plasma_initial : 0) + (plasma_per_structure * structure_count)

/// Gives plasma for taking damage from being on fire (different from being stepping into fire).
/datum/mutation_upgrade/veil/fight_in_flames/proc/on_handle_fire(datum/source)
	if(!isxenoravager(xenomorph_owner) || TIMER_COOLDOWN_RUNNING(xenomorph_owner, COOLDOWN_RAVAGER_FLAMER_ACT))
		return FALSE
	var/mob/living/carbon/xenomorph/ravager/ravager_owner = xenomorph_owner
	ravager_owner.gain_plasma(ravager_owner.plasma_gain_from_fire)
	TIMER_COOLDOWN_START(ravager_owner, COOLDOWN_RAVAGER_FLAMER_ACT, 1 SECONDS)

/datum/mutation_upgrade/veil/bloody_endure
	name = "Bloody Endure"
	desc = "Endure now costs health to activate, but will consume plasma first. This damage is non-lethal. Endure's cooldown duration is set to 70/60/50% of its original value."
	/// For the first structure, the multiplier of Endure's initial cooldown to add to the ability.
	var/multiplier_initial = -0.2
	/// For each structure, the additional multiplier of Endure's initial cooldown to add to the ability.
	var/multiplier_per_structure = -0.1

/datum/mutation_upgrade/veil/bloody_endure/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Endure now costs health to activate, but will consume plasma first. This damage is non-lethal. Endure's cooldown duration is set to [PERCENT(1 + get_multiplier(new_amount))]% of its original value."

/datum/mutation_upgrade/veil/bloody_endure/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/xeno_action/endure/endure_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/endure]
	if(!endure_ability)
		return
	endure_ability.cooldown_duration += initial(endure_ability.cooldown_duration) * get_multiplier(0)
	endure_ability.use_state_flags |= ABILITY_IGNORE_PLASMA
	endure_ability.uses_health_as_necessary = TRUE

/datum/mutation_upgrade/veil/bloody_endure/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/xeno_action/endure/endure_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/endure]
	if(!endure_ability)
		return
	endure_ability.cooldown_duration -= initial(endure_ability.cooldown_duration) * get_multiplier(0)
	endure_ability.use_state_flags &= ~ABILITY_IGNORE_PLASMA
	endure_ability.uses_health_as_necessary = initial(endure_ability.uses_health_as_necessary)

/datum/mutation_upgrade/veil/bloody_endure/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/xeno_action/endure/endure_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/endure]
	if(!endure_ability)
		return
	endure_ability.cooldown_duration += initial(endure_ability.cooldown_duration) * get_multiplier(new_amount - previous_amount, FALSE)

/// Returns the multiplier of Endure's initial cooldown to add to the ability.
/datum/mutation_upgrade/veil/bloody_endure/proc/get_multiplier(structure_count, include_initial = TRUE)
	return (include_initial ? multiplier_initial : 0) + (multiplier_per_structure * structure_count)
