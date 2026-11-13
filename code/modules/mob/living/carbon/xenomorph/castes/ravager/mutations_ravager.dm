//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/little_more
	name = "Little More"
	desc = "Endure further decreases your critical and death threshold by 40."
	/// The amount to change the death/critical threshold given by Endure while it is active.
	var/threshold_change = -40

/datum/mutation_upgrade/shell/little_more/on_mutation_enabled()
	var/datum/action/ability/xeno_action/endure/endure_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/endure]
	if(!endure_ability)
		return
	endure_ability.endure_threshold += threshold_change

/datum/mutation_upgrade/shell/little_more/on_mutation_disabled()
	var/datum/action/ability/xeno_action/endure/endure_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/endure]
	if(!endure_ability)
		return
	endure_ability.endure_threshold -= threshold_change

/datum/mutation_upgrade/shell/keep_going
	name = "Keep Going"
	desc = "Endure lasts 80% as long, but duration-increasing slashes is now available during normal Rage."
	/// The multiplier to add to Endure's duration.
	var/multiplier = -0.2

/datum/mutation_upgrade/shell/keep_going/on_mutation_enabled()
	var/datum/action/ability/xeno_action/endure/endure_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/endure]
	if(!endure_ability)
		return
	var/datum/action/ability/xeno_action/rage/rage_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/rage]
	if(!rage_ability)
		return
	endure_ability.endure_duration += initial(endure_ability.endure_duration) * multiplier
	rage_ability.extends_via_normal_rage = TRUE

/datum/mutation_upgrade/shell/keep_going/on_mutation_disabled()
	var/datum/action/ability/xeno_action/endure/endure_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/endure]
	if(!endure_ability)
		return
	var/datum/action/ability/xeno_action/rage/rage_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/rage]
	if(!rage_ability)
		return
	endure_ability.endure_duration -= initial(endure_ability.endure_duration) * multiplier
	rage_ability.extends_via_normal_rage = FALSE

/datum/mutation_upgrade/shell/inward_focus
	name = "Inward Focus"
	desc = "Endure no longer grants stagger immunity nor can be activated while staggered. Endure grants 15 all soft armor while active."
	/// The amount of all soft armor that Endure should give while active.
	var/armor = 15

/datum/mutation_upgrade/shell/inward_focus/on_mutation_enabled()
	var/datum/action/ability/xeno_action/endure/endure_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/endure]
	if(!endure_ability)
		return
	endure_ability.use_state_flags &= ~ABILITY_USE_STAGGERED
	endure_ability.endure_stagger_immunity = FALSE
	endure_ability.endure_armor += armor
	update_stagger_armor()

/datum/mutation_upgrade/shell/inward_focus/on_mutation_disabled()
	var/datum/action/ability/xeno_action/endure/endure_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/endure]
	if(!endure_ability)
		return
	endure_ability.use_state_flags |= ABILITY_USE_STAGGERED
	endure_ability.endure_stagger_immunity = TRUE
	endure_ability.endure_armor -= armor
	update_stagger_armor()

/// Updates stagger immunity and armor if they have Endure active.
/datum/mutation_upgrade/shell/inward_focus/proc/update_stagger_armor()
	var/datum/action/ability/xeno_action/endure/endure_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/endure]
	if(!endure_ability)
		return
	if(endure_ability.attached_armor)
		xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.detachArmor(endure_ability.attached_armor)
		endure_ability.attached_armor = null
	if(!endure_ability.endure_timer)
		return
	if(endure_ability.endure_armor)
		var/total_armor = endure_ability.endure_armor
		endure_ability.attached_armor = new(total_armor, total_armor, total_armor, total_armor, total_armor, total_armor, total_armor, total_armor)
		xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.attachArmor(endure_ability.attached_armor)
	if(endure_ability.endure_stagger_immunity)
		ADD_TRAIT(xenomorph_owner, TRAIT_STAGGERIMMUNE, ENDURE_TRAIT)
	else
		REMOVE_TRAIT(xenomorph_owner, TRAIT_STAGGERIMMUNE, ENDURE_TRAIT)

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/deep_slash
	name = "Deep Slash"
	desc = "Ravage now has an additional 15 armor penetration."
	/// The amount of armor penetration that all slash attacks caused by Ravage to have.
	var/ap = 15

/datum/mutation_upgrade/spur/deep_slash/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/ravage/ravage_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/ravage]
	if(!ravage_ability)
		return
	ravage_ability.armor_penetration += ap

/datum/mutation_upgrade/spur/deep_slash/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/ravage/ravage_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/ravage]
	if(!ravage_ability)
		return
	ravage_ability.armor_penetration -= ap

/datum/mutation_upgrade/spur/super_cut
	name = "Super Cut"
	desc = "Ravage now slashes in all directions, but has a cast time of 0.4 seconds."
	/// The amount of deciseconds to add to Ravage's cast time.
	var/time = 0.4 SECONDS

/datum/mutation_upgrade/spur/super_cut/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/ravage/ravage_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/ravage]
	if(!ravage_ability)
		return
	ravage_ability.cast_time += time
	ravage_ability.aoe = TRUE

/datum/mutation_upgrade/spur/super_cut/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/ravage/ravage_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/ravage]
	if(!ravage_ability)
		return
	ravage_ability.cast_time -= time
	ravage_ability.aoe = FALSE

/datum/mutation_upgrade/spur/onslaught
	name = "Onslaught"
	desc = "Eviscerating Charge's cooldown duration is set to 15% of its original value, but it no longer stuns."
	/// The multiplier to add to Eviscerating Charge's cooldown duration.
	var/multiplier_initial = -0.85

/datum/mutation_upgrade/spur/onslaught/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/charge/charge_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/charge]
	if(!charge_ability)
		return
	charge_ability.cooldown_duration += initial(charge_ability.cooldown_duration) * multiplier_initial
	charge_ability.paralyze_duration -= initial(charge_ability.paralyze_duration)

/datum/mutation_upgrade/spur/onslaught/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/charge/charge_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/charge]
	if(!charge_ability)
		return
	charge_ability.cooldown_duration -= initial(charge_ability.cooldown_duration) * multiplier_initial
	charge_ability.paralyze_duration += initial(charge_ability.paralyze_duration)

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/recurring_rage
	name = "Recurring Rage"
	desc = "Rage will automatically attempt to activate when your health reaches the minimum required threshold. Rage's cooldown duration is set to 50% of its original value."
	/// The multiplier of Rage's initial cooldown to add to the ability.
	var/multiplier_initial = -0.5

/datum/mutation_upgrade/veil/recurring_rage/on_mutation_enabled()
	RegisterSignal(xenomorph_owner, list(COMSIG_LIVING_UPDATE_HEALTH), PROC_REF(on_update_health))
	var/datum/action/ability/xeno_action/rage/rage_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/rage]
	if(!rage_ability)
		return
	rage_ability.cooldown_duration += initial(rage_ability.cooldown_duration) * multiplier_initial

/datum/mutation_upgrade/veil/recurring_rage/on_mutation_disabled()
	UnregisterSignal(xenomorph_owner, COMSIG_LIVING_UPDATE_HEALTH)
	var/datum/action/ability/xeno_action/rage/rage_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/rage]
	if(!rage_ability)
		return
	rage_ability.cooldown_duration -= initial(rage_ability.cooldown_duration) * multiplier_initial


/// Checks if Rage can be activated. If so, activate it.
/datum/mutation_upgrade/veil/recurring_rage/proc/on_update_health()
	SIGNAL_HANDLER
	var/health = (xenomorph_owner.status_flags & GODMODE) ? xenomorph_owner.maxHealth : (xenomorph_owner.maxHealth - xenomorph_owner.getFireLoss() - xenomorph_owner.getBruteLoss())
	if(health <= xenomorph_owner.get_death_threshold())
		return
	var/datum/action/ability/xeno_action/rage/rage_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/rage]
	if(!rage_ability || !rage_ability.action_cooldown_finished() || !rage_ability.can_use_action(silent = TRUE))
		return
	rage_ability.action_activate()

/datum/mutation_upgrade/veil/fight_in_flames
	name = "Fight in Flames"
	desc = "You lose 70 fire armor. The plasma gain from stepping into fire is now also given for being on fire. This plasma gain is increased by 250."
	/// The bonus amount of plasma when they are damaged from being on fire.
	var/plasma_restored = 250
	/// The attached soft armor, if any.
	var/datum/armor/attached_armor

/datum/mutation_upgrade/veil/fight_in_flames/on_mutation_enabled()
	if(!isxenoravager(xenomorph_owner))
		return
	RegisterSignal(xenomorph_owner, COMSIG_LIVING_HANDLE_FIRE, PROC_REF(on_handle_fire))
	attached_armor = getArmor(fire = -70)
	xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.attachArmor(attached_armor)
	var/mob/living/carbon/xenomorph/ravager/ravager_owner = xenomorph_owner
	ravager_owner.plasma_gain_from_fire += plasma_restored

/datum/mutation_upgrade/veil/fight_in_flames/on_mutation_disabled()
	if(!isxenoravager(xenomorph_owner))
		return
	UnregisterSignal(xenomorph_owner, COMSIG_LIVING_HANDLE_FIRE)
	var/mob/living/carbon/xenomorph/ravager/ravager_owner = xenomorph_owner
	ravager_owner.plasma_gain_from_fire -= plasma_restored
	xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.detachArmor(attached_armor)
	attached_armor = null

/// Gives plasma for taking damage from being on fire (different from being stepping into fire).
/datum/mutation_upgrade/veil/fight_in_flames/proc/on_handle_fire(datum/source)
	if(!isxenoravager(xenomorph_owner) || TIMER_COOLDOWN_RUNNING(xenomorph_owner, COOLDOWN_RAVAGER_FLAMER_ACT))
		return FALSE
	var/mob/living/carbon/xenomorph/ravager/ravager_owner = xenomorph_owner
	ravager_owner.gain_plasma(ravager_owner.plasma_gain_from_fire)
	TIMER_COOLDOWN_START(ravager_owner, COOLDOWN_RAVAGER_FLAMER_ACT, 1 SECONDS)

/datum/mutation_upgrade/veil/bloody_endure
	name = "Bloody Endure"
	desc = "Endure now costs health to activate, but will consume plasma first. This damage is non-lethal. Endure's cooldown duration is set to 60% of its original value."
	/// The multiplier of Endure's initial cooldown to add to the ability.
	var/multiplier = -0.4

/datum/mutation_upgrade/veil/bloody_endure/on_mutation_enabled()
	var/datum/action/ability/xeno_action/endure/endure_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/endure]
	if(!endure_ability)
		return
	endure_ability.cooldown_duration += initial(endure_ability.cooldown_duration) * multiplier
	endure_ability.use_state_flags |= ABILITY_IGNORE_PLASMA
	endure_ability.uses_health_as_necessary = TRUE

/datum/mutation_upgrade/veil/bloody_endure/on_mutation_disabled()
	var/datum/action/ability/xeno_action/endure/endure_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/endure]
	if(!endure_ability)
		return
	endure_ability.cooldown_duration -= initial(endure_ability.cooldown_duration) * multiplier
	endure_ability.use_state_flags &= ~ABILITY_IGNORE_PLASMA
	endure_ability.uses_health_as_necessary = initial(endure_ability.uses_health_as_necessary)
