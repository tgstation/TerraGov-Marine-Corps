//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/upfront_evasion
	name = "Upfront Evasion"
	desc = "Evasion is now 1/2/3 seconds longer, but no longer can auto-refresh."
	/// For each structure, the amount of seconds to increase Evasion by.
	var/evasion_length_per_structure = 1

/datum/mutation_upgrade/shell/upfront_evasion/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Evasion is now [new_amount * evasion_length_per_structure] seconds longer, but no longer can auto-refresh."

/datum/mutation_upgrade/shell/upfront_evasion/on_mutation_enabled()
	var/datum/action/ability/xeno_action/evasion/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/evasion]
	if(!ability)
		return FALSE
	ability.refresh_disabled = TRUE
	if(ability.auto_evasion)
		ability.alternate_action_activate()
	return ..()

/datum/mutation_upgrade/shell/upfront_evasion/on_mutation_disabled()
	var/datum/action/ability/xeno_action/evasion/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/evasion]
	if(!ability)
		return FALSE
	ability.refresh_disabled = FALSE
	return ..()

/datum/mutation_upgrade/shell/upfront_evasion/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/xeno_action/evasion/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/evasion]
	if(!ability)
		return FALSE
	ability.evasion_starting_duration += (new_amount - previous_amount) * evasion_length_per_structure

/datum/mutation_upgrade/shell/borrowed_time
	name = "Borrowed Time"
	desc = "Your critical threshold is decreased by 100. While you have negative health, you are staggered and cannot slash attack. If you have negative health for more than 2/3/4s, your critical threshold is increased back until you reach full health."
	/// For the first structure, the amount of time that they can have negative health.
	var/time_increase_initial = 1 SECONDS
	/// For each structure, the additional amount of time that they can have negative health.
	var/time_increase_per_structure = 1 SECONDS
	/// Has the critical threshold been increased already?
	var/critical_threshold_boosted = FALSE
	/// The amount to decrease the critical threshold for.
	var/critical_threshold_amount = 100
	/// The timer that will reverse the critical threshold.
	var/critical_threshold_timer

/datum/mutation_upgrade/shell/borrowed_time/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Your critical threshold is decreased by [critical_threshold_amount]. While you have negative health, you are staggered and cannot slash attack. If you have negative health for more than [(time_increase_initial + (time_increase_per_structure * new_amount)) * 0.1] seconds, your critical threshold is increased back until you reach full health."

/datum/mutation_upgrade/shell/borrowed_time/on_mutation_enabled()
	RegisterSignals(xenomorph_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE), PROC_REF(on_damage))
	if(!critical_threshold_boosted && xenomorph_owner.health >= xenomorph_owner.maxHealth)
		toggle(TRUE)
	return ..()

/datum/mutation_upgrade/shell/borrowed_time/on_mutation_disabled()
	UnregisterSignal(xenomorph_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE))
	if(critical_threshold_timer)
		reverse_critical_threshold()
	else if(critical_threshold_boosted)
		toggle()
	return ..()

/// Increases or decreases the critical threshold amount for the owner.
/datum/mutation_upgrade/shell/borrowed_time/proc/toggle(silent = FALSE)
	critical_threshold_boosted = !critical_threshold_boosted
	if(critical_threshold_boosted)
		if(!silent)
			to_chat(xenomorph_owner, span_notice("You feel like you're ready to be on Borrowed Time."))
		xenomorph_owner.health_threshold_crit -= critical_threshold_amount
		return
	xenomorph_owner.health_threshold_crit += critical_threshold_amount

/// Checks on the next tick if anything needs to be done with their new health since it is possible the health is inaccurate (because there can be other modifiers).
/datum/mutation_upgrade/shell/borrowed_time/proc/on_damage(datum/source, amount, list/amount_mod)
	SIGNAL_HANDLER
	INVOKE_NEXT_TICK(src, PROC_REF(check_current_health))

/// If their health is negative, activate it if possible. If it is full, let them activate it next time.
/datum/mutation_upgrade/shell/borrowed_time/proc/check_current_health()
	if(critical_threshold_boosted && !critical_threshold_timer && xenomorph_owner.health <= xenomorph_owner.health_threshold_crit + critical_threshold_amount)
		ADD_TRAIT(xenomorph_owner, TRAIT_HANDS_BLOCKED, TRAIT_MUTATION)
		var/borrowed_time_length = time_increase_initial + (time_increase_per_structure * get_total_structures())
		xenomorph_owner.Stagger(borrowed_time_length)
		critical_threshold_timer = addtimer(CALLBACK(src, PROC_REF(reverse_critical_threshold)), borrowed_time_length, TIMER_UNIQUE|TIMER_STOPPABLE)
		xenomorph_owner.emote("roar")
		to_chat(xenomorph_owner, span_warning("You feel like you're on Borrowed Time!"))
		return
	if(!critical_threshold_boosted && xenomorph_owner.health >= xenomorph_owner.maxHealth)
		toggle()

/// Effectively removes the effects of this mutation ands its active effect.
/datum/mutation_upgrade/shell/borrowed_time/proc/reverse_critical_threshold()
	toggle()
	REMOVE_TRAIT(xenomorph_owner, TRAIT_HANDS_BLOCKED, TRAIT_MUTATION)
	deltimer(critical_threshold_timer)
	critical_threshold_timer = null
	xenomorph_owner.updatehealth()

/datum/mutation_upgrade/shell/ingrained_evasion
	name = "Ingrained Evasion"
	desc = "You lose the ability, Evasion. You have a 30/40/50% to dodge projectiles with similar conditions as Evasion. Highly accurate projectiles will reduce your dodge chance."
	/// After this amount of time since their last move, they will no longer evade projectiles.
	var/movement_leniency = 0.5 SECONDS
	/// For the first structure, the chance of Evasion occurring.
	var/evasion_chance_initial = 20
	/// For each structure, the additional chance of Evasion occurring.
	var/evasion_chance_per_structure = 10
	/// If a projectile's accuracy is above this value, then evasion chance is decreased by each point above it.
	var/accuracy_reduction_requirement = 100

/datum/mutation_upgrade/shell/ingrained_evasion/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "You lose the ability, Evasion. You have a [evasion_chance_initial + (evasion_chance_per_structure * new_amount)]% to dodge projectiles with similar conditions as Evasion. Highly accurate projectiles will reduce your dodge chance."

/datum/mutation_upgrade/shell/ingrained_evasion/on_mutation_enabled()
	var/datum/action/ability/xeno_action/evasion/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/evasion]
	if(ability)
		ability.remove_action(xenomorph_owner)
	RegisterSignal(xenomorph_owner, COMSIG_XENO_PROJECTILE_HIT, PROC_REF(dodge_projectile))
	RegisterSignal(xenomorph_owner, COMSIG_LIVING_PRE_THROW_IMPACT, PROC_REF(dodge_thrown_item))
	return ..()

/datum/mutation_upgrade/shell/ingrained_evasion/on_mutation_disabled()
	var/datum/action/ability/xeno_action/evasion/ability = new()
	ability.give_action(xenomorph_owner)
	UnregisterSignal(xenomorph_owner, list(COMSIG_XENO_PROJECTILE_HIT, COMSIG_LIVING_PRE_THROW_IMPACT))
	return ..()

/datum/mutation_upgrade/shell/ingrained_evasion/on_xenomorph_upgrade()
	var/datum/action/ability/xeno_action/evasion/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/evasion]
	if(ability)
		ability.remove_action(xenomorph_owner) // Because upgrading give abilities that are missing.

// Checks if they can dodge at all.
/datum/mutation_upgrade/shell/ingrained_evasion/proc/can_dodge()
	if(xenomorph_owner.IsStun())
		return FALSE
	if(xenomorph_owner.IsKnockdown())
		return FALSE
	if(xenomorph_owner.IsParalyzed())
		return FALSE
	if(xenomorph_owner.IsUnconscious())
		return FALSE
	if(xenomorph_owner.IsSleeping())
		return FALSE
	if(xenomorph_owner.IsStaggered())
		return FALSE
	if(xenomorph_owner.on_fire)
		return FALSE
	if((xenomorph_owner.last_move_time < (world.time - movement_leniency)))
		return FALSE
	return TRUE

/// Checks if they can dodge a projectile. If they can, they do so.
/datum/mutation_upgrade/shell/ingrained_evasion/proc/dodge_projectile(datum/source, atom/movable/projectile/proj, cardinal_move, uncrossing)
	SIGNAL_HANDLER
	if(!can_dodge())
		return FALSE
	if(xenomorph_owner.issamexenohive(proj.firer))
		return COMPONENT_PROJECTILE_DODGE
	if(proj.ammo.ammo_behavior_flags & AMMO_FLAME) // We can't dodge literal fire.
		return FALSE
	if(proj.original_target == xenomorph_owner && proj.distance_travelled < 2) // Pointblank shot.
		return FALSE
	if(prob(evasion_chance_initial + (get_total_structures() * evasion_chance_per_structure) - (proj.accuracy ? max(0, proj.accuracy - accuracy_reduction_requirement) : 0)))
		dodge_fx(proj)
		return COMPONENT_PROJECTILE_DODGE
	return FALSE

/// Checks if they can dodge a thrown item. If they can, they do so.
/datum/mutation_upgrade/shell/ingrained_evasion/proc/dodge_thrown_item(datum/source, atom/movable/proj)
	SIGNAL_HANDLER
	if(!can_dodge())
		return FALSE
	if(prob(evasion_chance_initial + (get_total_structures() * evasion_chance_per_structure)))
		dodge_fx(proj)
		return COMPONENT_PRE_THROW_IMPACT_HIT
	return FALSE

/// Handles dodge effects and visuals.
/datum/mutation_upgrade/shell/ingrained_evasion/proc/dodge_fx(atom/movable/proj)
	xenomorph_owner.visible_message(span_warning("[xenomorph_owner] effortlessly dodges the [proj.name]!"), span_xenodanger("We effortlessly dodge the [proj.name]!"))
	xenomorph_owner.add_filter("ingrained_evasion", 2, gauss_blur_filter(5))
	addtimer(CALLBACK(xenomorph_owner, TYPE_PROC_REF(/datum, remove_filter), "ingrained_evasion"), 0.5 SECONDS)
	xenomorph_owner.do_jitter_animation(4000)
	var/turf/current_turf = get_turf(xenomorph_owner)
	playsound(current_turf, pick('sound/effects/throw.ogg','sound/effects/alien/tail_swipe1.ogg', 'sound/effects/alien/tail_swipe2.ogg'), 25, 1) //sound effects
	var/obj/effect/temp_visual/after_image/after_image
	for(var/i = 0 to 2)
		after_image = new /obj/effect/temp_visual/after_image(current_turf, xenomorph_owner)
		after_image.pixel_x = pick(randfloat(xenomorph_owner.pixel_x * 3, xenomorph_owner.pixel_x * 1.5), rand(0, xenomorph_owner.pixel_x * -1))

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/sneak_attack
	name = "Sneak Attack"
	desc = "Pounce will slash your target for 1/1.25/1.5x damage if it was started in low light."
	/// For the first structure, the additive multiplier of damage to add.
	var/damage_additive_multiplier_initial = 0.75
	/// For each structure, the additional the additive multiplier of damage to add.
	var/damage_additive_multiplier_per_structure = 0.25

/datum/mutation_upgrade/spur/sneak_attack/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Pounce will slash your target for [damage_additive_multiplier_initial + (damage_additive_multiplier_per_structure * new_amount)]x damage if it was started in low light."

/datum/mutation_upgrade/spur/sneak_attack/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/pounce/runner/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce/runner]
	if(!ability)
		return FALSE
	ability.dim_bonus_multiplier += damage_additive_multiplier_initial
	return ..()

/datum/mutation_upgrade/spur/sneak_attack/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/pounce/runner/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce/runner]
	if(!ability)
		return FALSE
	ability.dim_bonus_multiplier -= damage_additive_multiplier_initial
	return ..()

/datum/mutation_upgrade/spur/sneak_attack/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/pounce/runner/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce/runner]
	if(!ability)
		return FALSE
	ability.dim_bonus_multiplier += (new_amount - previous_amount) * damage_additive_multiplier_per_structure

/datum/mutation_upgrade/spur/right_here
	name = "Right Here"
	desc = "Pounce will slash your target for 0.5/0.75/1x slash damage based on the distance traveled. Every tile beyond the first reduces the amount by 20%."
	/// For the first structure, the additive multiplier of damage to add.
	var/damage_additive_multiplier_initial = 0.25
	/// For each structure, the additional the additive multiplier of damage to add.
	var/damage_additive_multiplier_per_structure = 0.25

/datum/mutation_upgrade/spur/right_here/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Pounce will slash your target for [damage_additive_multiplier_initial + (damage_additive_multiplier_per_structure * new_amount)]x slash damage based on the distance traveled. Every tile beyond the first reduces the amount by 20%."

/datum/mutation_upgrade/spur/right_here/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/pounce/runner/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce/runner]
	if(!ability)
		return FALSE
	ability.upclose_bonus_multiplier += damage_additive_multiplier_initial
	return ..()

/datum/mutation_upgrade/spur/right_here/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/pounce/runner/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce/runner]
	if(!ability)
		return FALSE
	ability.upclose_bonus_multiplier -= damage_additive_multiplier_initial
	return ..()

/datum/mutation_upgrade/spur/right_here/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/pounce/runner/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce/runner]
	if(!ability)
		return FALSE
	ability.upclose_bonus_multiplier += (new_amount - previous_amount) * damage_additive_multiplier_per_structure

/datum/mutation_upgrade/spur/mutilate
	name = "Mutilate"
	desc = "Savage now consumes all of your plasma. Savage deals 0.5/0.75/1x more damage."
	/// For the first structure, the additive multiplier of damage to add.
	var/damage_additive_multiplier_initial = 0.25
	/// For each structure, the additional the additive multiplier of damage to add.
	var/damage_additive_multiplier_per_structure = 0.25

/datum/mutation_upgrade/spur/mutilate/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Savage now consumes all of your plasma. Savage deals [damage_additive_multiplier_initial + (damage_additive_multiplier_per_structure * new_amount)]x more damage."

/datum/mutation_upgrade/spur/mutilate/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/pounce/runner/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce/runner]
	if(!ability)
		return FALSE
	ability.savage_damage_multiplier += damage_additive_multiplier_initial
	return ..()

/datum/mutation_upgrade/spur/mutilate/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/pounce/runner/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce/runner]
	if(!ability)
		return FALSE
	ability.savage_damage_multiplier -= damage_additive_multiplier_initial
	return ..()

/datum/mutation_upgrade/spur/mutilate/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/pounce/runner/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce/runner]
	if(!ability)
		return FALSE
	ability.savage_damage_multiplier += (new_amount - previous_amount) * damage_additive_multiplier_per_structure

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/headslam
	name = "Head Slam"
	desc = "Pounce decreases the stun duration by 75%, but now confuses and blurs your target's vision for 1/2/3 seconds."
	/// The amount to divide stun and immobilize duration by.
	var/stun_duration_divisible = 4
	/// For each structure, the additional amount of seconds to confuse and blur by.
	var/crowd_control_per_structure = 1

/datum/mutation_upgrade/veil/headslam/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Pounce decreases the stun duration by [100 - (100 / stun_duration_divisible)]%, but now confuses and blurs your target's vision for [crowd_control_per_structure * new_amount] seconds."

/datum/mutation_upgrade/veil/headslam/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/pounce/runner/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce/runner]
	if(!ability)
		return FALSE
	ability.stun_duration -= initial(ability.stun_duration) * (1 - (1 / stun_duration_divisible))
	ability.self_immobilize_duration -= initial(ability.stun_duration) * (1 - (1 / stun_duration_divisible)) // Wouldn't it be fair to self-stun for even longer!
	return ..()

/datum/mutation_upgrade/veil/headslam/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/pounce/runner/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce/runner]
	if(!ability)
		return FALSE
	ability.stun_duration += initial(ability.stun_duration) * (1 - (1 / stun_duration_divisible))
	ability.self_immobilize_duration += initial(ability.stun_duration) * (1 - (1 / stun_duration_divisible))
	return ..()

/datum/mutation_upgrade/veil/headslam/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/pounce/runner/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce/runner]
	if(!ability)
		return FALSE
	ability.savage_debuff_amount += (new_amount - previous_amount) * crowd_control_per_structure

/datum/mutation_upgrade/veil/frenzy
	name = "Frenzy"
	desc = "Savage's damage is converted to a buff that increases all melee damage by a percentage for 7 seconds. It is a percentage of every point of damage Savage would of done multiplied by 0.5x/0.75/1x."
	/// For the first structure, the multiplier to convert Savage damage with.
	var/damage_conversion_multiplier_initial = 0.25
	/// For each structure, the additional multiplier to convert Savage damage with.
	var/damage_conversion_multiplier_per_structure = 0.25

/datum/mutation_upgrade/veil/frenzy/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Savage's damage is converted to a buff that increases all melee damage by a percentage for 7 seconds. It is a percentage of every point of damage Savage would of done multiplied by [damage_conversion_multiplier_initial + (damage_conversion_multiplier_per_structure * new_amount)]x."

/datum/mutation_upgrade/veil/frenzy/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/pounce/runner/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce/runner]
	if(!ability)
		return FALSE
	ability.savage_damage_buff_alternative += damage_conversion_multiplier_initial
	return ..()

/datum/mutation_upgrade/veil/frenzy/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/pounce/runner/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce/runner]
	if(!ability)
		return FALSE
	ability.savage_damage_buff_alternative -= damage_conversion_multiplier_initial
	return ..()

/datum/mutation_upgrade/veil/frenzy/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/pounce/runner/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce/runner]
	if(!ability)
		return FALSE
	ability.savage_damage_buff_alternative += (new_amount - previous_amount) * damage_conversion_multiplier_per_structure

/datum/mutation_upgrade/veil/passing_glance
	name = "Passing Glance"
	desc = "While Evasion is on, moving onto the same location as a standing human will confuse them for 2/3/4 seconds. This can only happens once per human."
	/// For the first structure, the amount of deciseconds of confusion to apply.
	var/length_initial = 1 SECONDS
	/// For each structure, the additional  of deciseconds of confusion to apply.
	var/length_per_structure = 1 SECONDS

/datum/mutation_upgrade/veil/passing_glance/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "While Evasion is on, moving onto the same location as a standing human will confuse them for [(length_initial + (length_per_structure * new_amount)) * 0.01] seconds. This can only happens once per human."

/datum/mutation_upgrade/veil/passing_glance/on_mutation_enabled()
	var/datum/action/ability/xeno_action/evasion/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/evasion]
	if(!ability)
		return FALSE
	ability.evasion_passthrough = TRUE
	ability.passthrough_confusion_length += length_initial
	return ..()

/datum/mutation_upgrade/veil/passing_glance/on_mutation_disabled()
	var/datum/action/ability/xeno_action/evasion/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/evasion]
	if(!ability)
		return FALSE
	ability.evasion_passthrough = FALSE
	ability.passthrough_confusion_length -= length_initial
	return ..()

/datum/mutation_upgrade/veil/passing_glance/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/xeno_action/evasion/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/evasion]
	if(!ability)
		return FALSE
	ability.passthrough_confusion_length += (new_amount - previous_amount) * length_per_structure
