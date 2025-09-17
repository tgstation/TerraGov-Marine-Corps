//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/upfront_evasion
	name = "Upfront Evasion"
	desc = "Evasion is now 1/2/3 seconds longer, but no longer can auto-refresh."
	conflicting_mutation_types = list(
		/datum/mutation_upgrade/shell/ingrained_evasion
	)

	/// For each structure, the amount of seconds that is added to Evasion's starting duration.
	var/duration_per_structure = 1

/datum/mutation_upgrade/shell/upfront_evasion/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Evasion is now [get_duration(new_amount)] seconds longer, but no longer can auto-refresh."

/datum/mutation_upgrade/shell/upfront_evasion/on_mutation_enabled()
	var/datum/action/ability/xeno_action/evasion/evasion = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/evasion]
	if(!evasion)
		return
	evasion.auto_evasion_togglable = FALSE
	if(evasion.auto_evasion) // Turning it off and giving them the notification it happened.
		evasion.alternate_action_activate()
	return ..()

/datum/mutation_upgrade/shell/upfront_evasion/on_mutation_disabled()
	var/datum/action/ability/xeno_action/evasion/evasion = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/evasion]
	if(!evasion)
		return
	evasion.auto_evasion_togglable = initial(evasion.auto_evasion_togglable)
	if(!evasion.auto_evasion) // Turning it on (since most Runners like auto-evasion) and giving them the notification it happened.
		evasion.alternate_action_activate()
	return ..()

/datum/mutation_upgrade/shell/upfront_evasion/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/xeno_action/evasion/evasion = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/evasion]
	if(!evasion)
		return
	evasion.evasion_starting_duration += get_duration(new_amount - previous_amount)

/// Returns the amount of seconds that is added to Evasion's starting duration.
/datum/mutation_upgrade/shell/upfront_evasion/proc/get_duration(structure_count)
	return duration_per_structure * structure_count

/datum/mutation_upgrade/shell/borrowed_time
	name = "Borrowed Time"
	desc = "Your critical threshold is decreased by 100. While you have negative health, you are slowed, staggered and cannot slash attack. If you have negative health for more than 2/3/4s, your critical threshold is increased back until you reach full health."
	/// For the first structure, the amount of deciseconds that they can keep the critical threshold once they get negative health.
	var/duration_initial = 1 SECONDS
	/// For each structure, the amount of deciseconds that they can keep the critical threshold once they get negative health.
	var/duration_per_structure = 1 SECONDS
	/// Has the critical threshold been increased already?
	var/critical_threshold_boosted = FALSE
	/// The amount to decrease the critical threshold for.
	var/critical_threshold_amount = 100
	/// The timer that will reverse the critical threshold.
	var/critical_threshold_timer
	/// The movement speed modifier to apply while they have negative health.
	var/movement_speed_modifier = 0.9

/datum/mutation_upgrade/shell/borrowed_time/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Your critical threshold is decreased by [critical_threshold_amount]. While you have negative health, you are slowed, staggered and cannot slash attack. If you have negative health for more than [get_duration(new_amount) * 0.1] seconds, your critical threshold is increased back until you reach full health."

/datum/mutation_upgrade/shell/borrowed_time/on_mutation_enabled()
	RegisterSignal(xenomorph_owner, COMSIG_LIVING_UPDATE_HEALTH, PROC_REF(on_health_update))
	if(!critical_threshold_boosted && xenomorph_owner.health >= xenomorph_owner.maxHealth)
		toggle(TRUE)
	return ..()

/datum/mutation_upgrade/shell/borrowed_time/on_mutation_disabled()
	UnregisterSignal(xenomorph_owner, COMSIG_LIVING_UPDATE_HEALTH)
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
			xenomorph_owner.balloon_alert(xenomorph_owner, "Borrowed time ready!");
		xenomorph_owner.health_threshold_crit -= critical_threshold_amount
		return
	xenomorph_owner.health_threshold_crit += critical_threshold_amount

/// If their health is negative, activate it if possible. If it is full, let them activate it next time.
/datum/mutation_upgrade/shell/borrowed_time/proc/on_health_update(datum/source)
	SIGNAL_HANDLER
	var/health = (xenomorph_owner.status_flags & GODMODE) ? xenomorph_owner.maxHealth : (xenomorph_owner.maxHealth - xenomorph_owner.getFireLoss() - xenomorph_owner.getBruteLoss())
	if(health <= xenomorph_owner.get_death_threshold())
		return // They're dead (and possibly gibbed) immediately after the signal is processed.
	if(!critical_threshold_boosted)
		if(health >= xenomorph_owner.maxHealth)
			toggle()
		return
	if(critical_threshold_timer || health > xenomorph_owner.get_crit_threshold() + critical_threshold_amount)
		return
	ADD_TRAIT(xenomorph_owner, TRAIT_HANDS_BLOCKED, MUTATION_TRAIT)
	xenomorph_owner.add_movespeed_modifier(MOVESPEED_ID_RUNNER_BORROWED_TIME, TRUE, 0, NONE, TRUE, movement_speed_modifier)
	var/borrowed_time_length = get_duration(get_total_structures())
	xenomorph_owner.Stagger(borrowed_time_length)
	critical_threshold_timer = addtimer(CALLBACK(src, PROC_REF(reverse_critical_threshold)), borrowed_time_length, TIMER_UNIQUE|TIMER_STOPPABLE)
	INVOKE_ASYNC(xenomorph_owner, TYPE_PROC_REF(/mob, emote), "roar")
	xenomorph_owner.balloon_alert(xenomorph_owner, "On borrowed time!");

/// Effectively removes the effects of this mutation ands its active effect.
/datum/mutation_upgrade/shell/borrowed_time/proc/reverse_critical_threshold()
	toggle()
	REMOVE_TRAIT(xenomorph_owner, TRAIT_HANDS_BLOCKED, MUTATION_TRAIT)
	xenomorph_owner.remove_movespeed_modifier(MOVESPEED_ID_RUNNER_BORROWED_TIME)
	deltimer(critical_threshold_timer)
	critical_threshold_timer = null
	xenomorph_owner.updatehealth()

/// Returns the amount of deciseconds that they can keep the critical threshold once they get negative health.
/datum/mutation_upgrade/shell/borrowed_time/proc/get_duration(structure_count, include_initial = TRUE)
	return (include_initial ? duration_initial : 0) + (duration_per_structure * structure_count)

/datum/mutation_upgrade/shell/ingrained_evasion
	name = "Ingrained Evasion"
	desc = "You lose the ability, Evasion. You have a 30/40/50% to dodge projectiles with similar conditions as Evasion. Highly accurate projectiles will reduce your dodge chance."
	conflicting_mutation_types = list(
		/datum/mutation_upgrade/shell/upfront_evasion,
		/datum/mutation_upgrade/veil/passing_glance
	)
	/// After this amount of time since their last move, they will no longer dodge projectiles.
	var/movement_leniency = 0.5 SECONDS
	/// For the first structure, the chance of dodging a projectile or thrown object.
	var/chance_initial = 20
	/// For each structure, the chance of dodging a projectile or thrown object.
	var/chance_per_structure = 10
	/// If a projectile's accuracy is above this value, then the dodge chance is decreased by each point above it.
	var/accuracy_reduction_threshold = 75

/datum/mutation_upgrade/shell/ingrained_evasion/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "You lose the ability, Evasion. You have a [get_chance(new_amount)]% to dodge projectiles with similar conditions as Evasion. Highly accurate projectiles will reduce your dodge chance."

/datum/mutation_upgrade/shell/ingrained_evasion/on_mutation_enabled()
	var/datum/action/ability/xeno_action/evasion/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/evasion]
	if(ability)
		ability.remove_action(xenomorph_owner)
	RegisterSignal(xenomorph_owner, COMSIG_XENO_PROJECTILE_HIT, PROC_REF(dodge_projectile))
	RegisterSignal(xenomorph_owner, COMSIG_PRE_MOVABLE_IMPACT, PROC_REF(dodge_thrown_item))
	return ..()

/datum/mutation_upgrade/shell/ingrained_evasion/on_mutation_disabled()
	var/datum/action/ability/xeno_action/evasion/ability = new()
	ability.give_action(xenomorph_owner)
	UnregisterSignal(xenomorph_owner, list(COMSIG_XENO_PROJECTILE_HIT, COMSIG_PRE_MOVABLE_IMPACT))
	return ..()

/datum/mutation_upgrade/shell/ingrained_evasion/on_xenomorph_upgrade()
	var/datum/action/ability/xeno_action/evasion/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/evasion]
	if(ability)
		ability.remove_action(xenomorph_owner) // Since upgrading give abilities that are missing, we have to remove it again.

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
	if(prob(get_chance(get_total_structures(), TRUE, proj.accuracy ? -max(0, proj.accuracy - accuracy_reduction_threshold) : 0)))
		dodge_fx(proj)
		return COMPONENT_PROJECTILE_DODGE
	return FALSE

/// Checks if they can dodge a thrown object. If they can, they do so.
/datum/mutation_upgrade/shell/ingrained_evasion/proc/dodge_thrown_item(datum/source, atom/movable/thrown_atom)
	SIGNAL_HANDLER
	if(!isobj(thrown_atom) || !can_dodge())
		return FALSE
	if(prob(get_chance(get_total_structures())))
		dodge_fx(thrown_atom)
		return COMPONENT_PRE_MOVABLE_IMPACT_DODGED
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

/// Returns the chance of dodging a projectile or thrown object. Will never be negative.
/datum/mutation_upgrade/shell/ingrained_evasion/proc/get_chance(structure_count, include_initial = TRUE, additional_chance = 0)
	return max(0, (include_initial ? chance_initial : 0) + (chance_per_structure * structure_count) + additional_chance)

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/sneak_attack
	name = "Sneak Attack"
	desc = "Pounce will slash your target for 1/1.25/1.5x damage if it was started in dim light."
	/// For the first structure, the amount to increase Pounce's dim light damage multiplier.
	var/multiplier_initial = 0.75
	/// For each structure, the amount to increase Pounce's dim light damage multiplier.
	var/multiplier_per_structure = 0.25

/datum/mutation_upgrade/spur/sneak_attack/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Pounce will slash your target for [get_multiplier(new_amount)]x damage if it was started in dim light."

/datum/mutation_upgrade/spur/sneak_attack/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/pounce/runner/pounce = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce/runner]
	if(!pounce)
		return
	pounce.dim_bonus_multiplier += get_multiplier(0)
	return ..()

/datum/mutation_upgrade/spur/sneak_attack/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/pounce/runner/pounce = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce/runner]
	if(!pounce)
		return
	pounce.dim_bonus_multiplier -= get_multiplier(0)
	return ..()

/datum/mutation_upgrade/spur/sneak_attack/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/pounce/runner/pounce = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce/runner]
	if(!pounce)
		return
	pounce.dim_bonus_multiplier += get_multiplier(new_amount - previous_amount, FALSE)

/// Returns the amount to increase Pounce's dim light damage multiplier.
/datum/mutation_upgrade/spur/sneak_attack/proc/get_multiplier(structure_count, include_initial = TRUE)
	return (include_initial ? multiplier_initial : 0) + (multiplier_per_structure * structure_count)

/datum/mutation_upgrade/spur/right_here
	name = "Right Here"
	desc = "Pounce will slash your target for 0.5/0.75/1x slash damage based on the distance traveled. Every tile beyond the first reduces the amount by 20%."
	/// For the first structure, the amount to increase Pounce's distance damage multiplier.
	var/multiplier_initial = 0.25
	/// For each structure, the amount to increase Pounce's distance damage multiplier.
	var/multiplier_per_structure = 0.25

/datum/mutation_upgrade/spur/right_here/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Pounce will slash your target for [get_multiplier(new_amount)]x slash damage based on the distance traveled. Every tile beyond the first reduces the amount by 20%."

/datum/mutation_upgrade/spur/right_here/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/pounce/runner/pounce = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce/runner]
	if(!pounce)
		return
	pounce.upclose_bonus_multiplier += get_multiplier(0)
	return ..()

/datum/mutation_upgrade/spur/right_here/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/pounce/runner/pounce = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce/runner]
	if(!pounce)
		return
	pounce.upclose_bonus_multiplier -= get_multiplier(0)
	return ..()

/datum/mutation_upgrade/spur/right_here/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/pounce/runner/pounce = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce/runner]
	if(!pounce)
		return
	pounce.upclose_bonus_multiplier += get_multiplier(new_amount - previous_amount, FALSE)

/// Returns the amount to increase Pounce's distance damage multiplier.
/datum/mutation_upgrade/spur/right_here/proc/get_multiplier(structure_count, include_initial = TRUE)
	return (include_initial ? multiplier_initial : 0) + (multiplier_per_structure * structure_count)

/datum/mutation_upgrade/spur/mutilate
	name = "Mutilate"
	desc = "Savage's plasma-to-damage conversion rate is increased by 0.05/0.1/0.15. Savage will consume all of your plasma."
	/// For each structure, the amount to increase Savage's plasma-to-damage conversion rate.
	var/conversion_rate_per_structure = 0.05

/datum/mutation_upgrade/spur/mutilate/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Savage's plasma-to-damage conversion rate is increased by [get_conversion_rate(new_amount)]. Savage will consume all of your plasma."

/datum/mutation_upgrade/spur/mutilate/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/pounce/runner/pounce = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce/runner]
	if(!pounce)
		return
	pounce.savage_plasma_conversion_rate += get_conversion_rate(new_amount - previous_amount)

/// Returns the amount to increase Savage's plasma-to-damage conversion rate.
/datum/mutation_upgrade/spur/mutilate/proc/get_conversion_rate(structure_count)
	return conversion_rate_per_structure * structure_count

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/headslam
	name = "Head Slam"
	desc = "Pounce stuns only for 25% as long. It now confuses and blurs your target's vision for 1/2/3 seconds."
	/// The amount to multiply all stun and immobilize duration by.
	var/stun_duration_multiplier = 0.25
	/// For each structure, the amount of deciseconds to confuse and the potency of blur by (divided by 5).
	var/debuff_duration_per_structure = 1 SECONDS

/datum/mutation_upgrade/veil/headslam/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Pounce stuns only for [PERCENT(stun_duration_multiplier)]% as long. It now confuses and blurs your target's vision for [get_debuff_duration(new_amount) * 0.1] seconds."

/datum/mutation_upgrade/veil/headslam/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/pounce/runner/pounce = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce/runner]
	if(!pounce)
		return
	pounce.stun_duration -= initial(pounce.stun_duration) * (1 - stun_duration_multiplier)
	pounce.self_immobilize_duration -= initial(pounce.self_immobilize_duration) * (1 - stun_duration_multiplier)
	return ..()

/datum/mutation_upgrade/veil/headslam/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/pounce/runner/pounce = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce/runner]
	if(!pounce)
		return
	pounce.stun_duration += initial(pounce.stun_duration) / (1 - stun_duration_multiplier)
	pounce.self_immobilize_duration += initial(pounce.self_immobilize_duration) * (1 - stun_duration_multiplier)
	return ..()

/datum/mutation_upgrade/veil/headslam/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/pounce/runner/pounce = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce/runner]
	if(!pounce)
		return
	pounce.savage_debuff_amount += get_debuff_duration(new_amount - previous_amount, FALSE)

/// Returns the amount of deciseconds to confuse and blur by.
/datum/mutation_upgrade/veil/headslam/proc/get_debuff_duration(structure_count, include_initial = TRUE)
	return debuff_duration_per_structure * structure_count

/datum/mutation_upgrade/veil/frenzy
	name = "Frenzy"
	desc = "Savage's damage is converted to a buff that increases your melee damage for 7 seconds. For each point of damage, your melee damage multiplier is increased by 0.5/0.75/1%."
	/// For the first structure, the rate in which Savage damage is converted to melee damage multiplier.
	var/conversion_rate_initial = 0.0025
	/// For each structure, the rate in which Savage damage is converted to melee damage multiplier.
	var/conversion_rate_per_structure = 0.0025

/datum/mutation_upgrade/veil/frenzy/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Savage's damage is converted to a buff that increases your melee damage for 7 seconds. For each point of damage, your melee damage multiplier is increased by [PERCENT(get_conversion_rate(new_amount))]%."

/datum/mutation_upgrade/veil/frenzy/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/pounce/runner/pounce = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce/runner]
	if(!pounce)
		return
	pounce.savage_damage_conversion_rate += get_conversion_rate(0)
	return ..()

/datum/mutation_upgrade/veil/frenzy/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/pounce/runner/pounce = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce/runner]
	if(!pounce)
		return
	pounce.savage_damage_conversion_rate -= get_conversion_rate(0)
	return ..()

/datum/mutation_upgrade/veil/frenzy/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/pounce/runner/pounce = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce/runner]
	if(!pounce)
		return
	pounce.savage_damage_conversion_rate += get_conversion_rate(new_amount - previous_amount, FALSE)

/// Returns the rate in which Savage damage is converted to melee damage multiplier.
/datum/mutation_upgrade/veil/frenzy/proc/get_conversion_rate(structure_count, include_initial = TRUE)
	return (include_initial ? conversion_rate_initial : 0) + (conversion_rate_per_structure * structure_count)

/datum/mutation_upgrade/veil/passing_glance
	name = "Passing Glance"
	desc = "While Evasion is on, moving onto the same location as a standing human will confuse them for 2/3/4 seconds. This can only happens once per human."
	conflicting_mutation_types = list(
		/datum/mutation_upgrade/shell/upfront_evasion,
	)
	/// For the first structure, the amount of deciseconds that Evasion will confuse humans who are passed through.
	var/duration_initial = 1 SECONDS
	/// For each structure, the amount of deciseconds that Evasion will confuse humans who are passed through.
	var/duration_per_structure = 1 SECONDS

/datum/mutation_upgrade/veil/passing_glance/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "While Evasion is on, moving onto the same location as a standing human will confuse them for [get_duration(new_amount) * 0.1] seconds. This can only happens once per human."

/datum/mutation_upgrade/veil/passing_glance/on_mutation_enabled()
	var/datum/action/ability/xeno_action/evasion/evasion = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/evasion]
	if(!evasion)
		return
	evasion.evasion_passthrough = TRUE
	evasion.passthrough_confusion_length += get_duration(0)
	return ..()

/datum/mutation_upgrade/veil/passing_glance/on_mutation_disabled()
	var/datum/action/ability/xeno_action/evasion/evasion = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/evasion]
	if(!evasion)
		return
	evasion.evasion_passthrough = FALSE
	evasion.passthrough_confusion_length -= get_duration(0)
	return ..()

/datum/mutation_upgrade/veil/passing_glance/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/xeno_action/evasion/evasion = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/evasion]
	if(!evasion)
		return
	evasion.passthrough_confusion_length += get_duration(new_amount - previous_amount, FALSE)

/// Returns the amount of deciseconds that Evasion will confuse humans who are passed through.
/datum/mutation_upgrade/veil/passing_glance/proc/get_duration(structure_count, include_initial = TRUE)
	return (include_initial ? duration_initial : 0) + (duration_per_structure * structure_count)
