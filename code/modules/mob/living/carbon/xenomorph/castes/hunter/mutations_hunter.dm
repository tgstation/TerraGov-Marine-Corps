//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/fleeting_mirage
	name = "Fleeting Mirage"
	desc = "Upon reaching 40% health, a mirage will appear and run away from you. That mirage takes priority when mirage swapping."
	///The maximum health threshold that the owner must be reach / be below of in order for the Illusion will appear.
	var/health_threshold = 0.4
	/// If the effect can be activated.
	var/can_be_activated = FALSE
	/// The timer ID of the timer that will delete the mirage.
	var/mirage_timer_id

/datum/mutation_upgrade/shell/fleeting_mirage/on_mutation_enabled()
	var/datum/action/ability/xeno_action/mirage/mirage_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/mirage]
	if(!mirage_ability)
		return
	RegisterSignal(xenomorph_owner, COMSIG_LIVING_UPDATE_HEALTH, PROC_REF(on_update_health))
	if(xenomorph_owner.health >= xenomorph_owner.maxHealth)
		can_be_activated = TRUE

/datum/mutation_upgrade/shell/fleeting_mirage/on_mutation_disabled()
	var/datum/action/ability/xeno_action/mirage/mirage_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/mirage]
	if(!mirage_ability)
		return
	UnregisterSignal(xenomorph_owner, COMSIG_LIVING_UPDATE_HEALTH)
	can_be_activated = FALSE
	QDEL_NULL(mirage_ability.prioritized_illusion)
	if(mirage_timer_id)
		deltimer(mirage_timer_id)
		mirage_timer_id = null

/// If their health is under the threshold, activate it if possible. If it is full, let them activate it next time.
/datum/mutation_upgrade/shell/fleeting_mirage/proc/on_update_health(datum/source)
	var/health = (xenomorph_owner.status_flags & GODMODE) ? xenomorph_owner.maxHealth : (xenomorph_owner.maxHealth - xenomorph_owner.getFireLoss() - xenomorph_owner.getBruteLoss())
	if(health <= xenomorph_owner.get_death_threshold())
		return
	if(!can_be_activated)
		if(xenomorph_owner.health >= xenomorph_owner.maxHealth)
			can_be_activated = TRUE
		return
	if((health > xenomorph_owner.maxHealth * health_threshold) || mirage_timer_id)
		return
	can_be_activated = FALSE
	var/datum/action/ability/xeno_action/mirage/mirage_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/mirage]
	if(!mirage_ability)
		return
	mirage_ability.prioritized_illusion = new(xenomorph_owner.loc, xenomorph_owner, xenomorph_owner, 10 SECONDS, /datum/ai_behavior/xeno/fleeing_illusion)
	mirage_timer_id = addtimer(CALLBACK(src, PROC_REF(remove_illusion)), 10 SECONDS)

/// Deletes the illusion.
/datum/mutation_upgrade/shell/fleeting_mirage/proc/remove_illusion()
	var/datum/action/ability/xeno_action/mirage/mirage_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/mirage]
	if(!mirage_ability)
		return
	QDEL_NULL(mirage_ability.prioritized_illusion)
	if(mirage_timer_id)
		deltimer(mirage_timer_id)
		mirage_timer_id = null

/datum/mutation_upgrade/shell/splitting_mirage
	name = "Splitting Mirage"
	desc = "Mirage will instead cause your slashes to create an illusion for the next 14 seconds. These illusions disappear when the time is up."
	conflicting_mutation_types = list(
		/datum/mutation_upgrade/veil/mirage_flood
	)
	/// The amount of deciseconds to increase Mirage's illusion lifespan by.
	var/duration_increase = 4 SECONDS

/datum/mutation_upgrade/shell/splitting_mirage/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/xeno_action/mirage/mirage_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/mirage]
	if(!mirage_ability)
		return
	mirage_ability.illusion_life_time += duration_increase
	mirage_ability.illusion_count -= initial(mirage_ability.illusion_count)
	mirage_ability.illusion_on_slash = TRUE
	if(length(mirage_ability.illusions)) // Ability is currently active.
		mirage_ability.register_on_slash()

/datum/mutation_upgrade/shell/splitting_mirage/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/xeno_action/mirage/mirage_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/mirage]
	if(!mirage_ability)
		return
	mirage_ability.illusion_life_time -= duration_increase
	mirage_ability.illusion_count += initial(mirage_ability.illusion_count)
	mirage_ability.illusion_on_slash = FALSE
	if(length(mirage_ability.illusions)) // Ability is currently active.
		mirage_ability.unregister_on_slash()

/datum/mutation_upgrade/shell/cloaking_mirage
	name = "Cloaking Mirage"
	desc = "Mirage will instead creates cloaking gas for 14 seconds in a radius of 2."
	conflicting_mutation_types = list(
		/datum/mutation_upgrade/veil/mirage_flood
	)
	/// The amount of deciseconds to increase Mirage's smoke duration by.
	var/duration_increase = 4 SECONDS

/datum/mutation_upgrade/shell/cloaking_mirage/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/xeno_action/mirage/mirage_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/mirage]
	if(!mirage_ability)
		return
	mirage_ability.illusion_life_time += duration_increase
	mirage_ability.illusion_count -= initial(mirage_ability.illusion_count)
	mirage_ability.cloaking_gas = TRUE

/datum/mutation_upgrade/shell/cloaking_mirage/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/xeno_action/mirage/mirage_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/mirage]
	if(!mirage_ability)
		return
	mirage_ability.illusion_life_time -= duration_increase
	mirage_ability.illusion_count += initial(mirage_ability.illusion_count)
	mirage_ability.cloaking_gas = FALSE

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/debilitating_strike
	name = "Debilitating Strike"
	desc = "Stealth's sneak attack no longer stuns. 1.5x of your slash damage is added onto sneak attack instead."
	conflicting_mutation_types = list(
		/datum/mutation_upgrade/veil/faceblind
	)
	/// The multiplier to add as additional damage when Sneak Attack was successfully used on living beings.
	var/damage_multiplier = 1.5

/datum/mutation_upgrade/spur/debilitating_strike/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/xeno_action/stealth/stealth_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/stealth]
	if(!stealth_ability)
		return
	stealth_ability.bonus_stealth_damage_multiplier += damage_multiplier
	stealth_ability.sneak_attack_stun_duration -= initial(stealth_ability.sneak_attack_stun_duration)

/datum/mutation_upgrade/spur/debilitating_strike/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/xeno_action/stealth/stealth_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/stealth]
	if(!stealth_ability)
		return
	stealth_ability.bonus_stealth_damage_multiplier -= damage_multiplier
	stealth_ability.sneak_attack_stun_duration += initial(stealth_ability.sneak_attack_stun_duration)

/datum/mutation_upgrade/spur/ambush
	name = "Ambush"
	desc = "Stealth's movement cost is 300% of its original value. While at the maximum stealth power, your next sneak attack has an additional 22.5 AP."
	/// The amount of AP that a maximum powered stealth will get.
	var/ap_increase = 22.5

/datum/mutation_upgrade/spur/ambush/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/xeno_action/stealth/stealth_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/stealth]
	if(!stealth_ability)
		return
	stealth_ability.movement_cost_multiplier += 2 // 100% -> 300%
	stealth_ability.bonus_maximum_stealth_ap += ap_increase

/datum/mutation_upgrade/spur/ambush/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/xeno_action/stealth/stealth_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/stealth]
	if(!stealth_ability)
		return
	stealth_ability.movement_cost_multiplier -= 2 // 300% -> 100%
	stealth_ability.bonus_maximum_stealth_ap -= ap_increase

/datum/mutation_upgrade/spur/maul
	name = "Maul"
	desc = "Pounce no longer stuns, but now slashes your target which can trigger sneak attack. Pounce's cooldown is set to 50% of its original value."
	/// The multiplier of Pounce's cooldown duration to add to it.
	var/multiplier = -0.5

/datum/mutation_upgrade/spur/maul/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/pounce/pounce_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce]
	if(!pounce_ability)
		return
	pounce_ability.cooldown_duration += initial(pounce_ability.cooldown_duration) * multiplier
	pounce_ability.stun_duration -= initial(pounce_ability.stun_duration)
	pounce_ability.self_immobilize_duration -= initial(pounce_ability.self_immobilize_duration)
	pounce_ability.attack_on_pounce = TRUE

/datum/mutation_upgrade/spur/maul/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/pounce/pounce_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce]
	if(!pounce_ability)
		return
	pounce_ability.cooldown_duration -= initial(pounce_ability.cooldown_duration) * multiplier
	pounce_ability.stun_duration += initial(pounce_ability.stun_duration)
	pounce_ability.self_immobilize_duration += initial(pounce_ability.self_immobilize_duration)
	pounce_ability.attack_on_pounce = FALSE

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/one_target
	name = "One Target"
	desc = "The effects of Silence against your Hunter's Mark target last 2.75x as long."
	/// The multiplier to add to Silence's effectiveness against the Hunter's Mark target.
	var/multiplier = 1.75

/datum/mutation_upgrade/veil/one_target/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/silence/silence_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/silence]
	if(!silence_ability)
		return
	silence_ability.hunter_mark_multiplier += multiplier

/datum/mutation_upgrade/veil/one_target/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/silence/silence_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/silence]
	if(!silence_ability)
		return
	silence_ability.hunter_mark_multiplier -= multiplier

/datum/mutation_upgrade/veil/mirage_flood
	name = "Mirage Flood"
	desc = "Mirage creates 4 additional illusions, but the duration is reduced by 3 seconds."
	conflicting_mutation_types = list(
		/datum/mutation_upgrade/shell/splitting_mirage,
		/datum/mutation_upgrade/shell/cloaking_mirage
	)
	var/additional_illusions = 4
	/// The amount of deciseconds to add to Mirage's illusion lifespan.
	var/duration = -3 SECONDS

/datum/mutation_upgrade/veil/mirage_flood/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/xeno_action/mirage/mirage_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/mirage]
	if(!mirage_ability)
		return
	mirage_ability.illusion_count += additional_illusions
	mirage_ability.illusion_life_time += duration

/datum/mutation_upgrade/veil/mirage_flood/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/xeno_action/mirage/mirage_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/mirage]
	if(!mirage_ability)
		return
	mirage_ability.illusion_count -= additional_illusions
	mirage_ability.illusion_life_time -= duration

/datum/mutation_upgrade/veil/faceblind
	name = "Faceblind"
	desc = "Stealth's sneak attack causes temporary blindness, but no longer stuns. Mirage's cooldown is set to 80% of its original value."
	conflicting_mutation_types = list(
		/datum/mutation_upgrade/spur/debilitating_strike
	)
	/// The additional multiplier of Mirage's cooldown duration to add to it.
	var/multiplier = -0.2

/datum/mutation_upgrade/veil/faceblind/on_mutation_enabled()
	var/datum/action/ability/xeno_action/stealth/stealth_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/stealth]
	if(!stealth_ability)
		return
	var/datum/action/ability/xeno_action/mirage/mirage_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/mirage]
	if(!mirage_ability)
		return
	stealth_ability.sneak_attack_stun_duration = 0 SECONDS
	stealth_ability.blinding_stacks = 2
	mirage_ability.cooldown_duration -= initial(mirage_ability.cooldown_duration) * multiplier

/datum/mutation_upgrade/veil/faceblind/on_mutation_disabled()
	var/datum/action/ability/xeno_action/stealth/stealth_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/stealth]
	if(!stealth_ability)
		return
	var/datum/action/ability/xeno_action/mirage/mirage_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/mirage]
	if(!mirage_ability)
		return
	stealth_ability.sneak_attack_stun_duration = initial(stealth_ability.sneak_attack_stun_duration)
	stealth_ability.blinding_stacks = initial(stealth_ability.blinding_stacks)
	mirage_ability.cooldown_duration += initial(mirage_ability.cooldown_duration) * multiplier
