//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/upfront_evasion
	name = "Upfront Evasion"
	desc = "Evasion starts off 1/2/3s longer, but it no longer refreshes from dodging projectiles."

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

/datum/mutation_upgrade/shell/upfront_evasion/on_structure_update(datum/source, previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/xeno_action/evasion/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/evasion]
	if(!ability)
		return FALSE
	ability.evasion_starting_duration += (new_amount - previous_amount)

/datum/mutation_upgrade/shell/borrowed_time
	name = "Borrowed Time"
	desc = "Your critical threshold is increased by 100. While you have negative health, you are staggered and cannot slash attack. If you have negative health for more than 2/3/4s, your critical threshold is reverted back until you reach full health."
	/// Has the critical threshold been increased already?
	var/critical_threshold_boosted = FALSE
	/// The amount to decrease the critical threshold for.
	var/critical_threshold_amount = 100
	/// The timer that will reverse the critical threshold.
	var/critical_threshold_timer

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
		xenomorph_owner.Stagger((1 + get_total_structures()) SECONDS)
		critical_threshold_timer = addtimer(CALLBACK(src, PROC_REF(reverse_critical_threshold)), (1 + get_total_structures()) SECONDS, TIMER_UNIQUE|TIMER_STOPPABLE)
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
	/// The chance of evasion occurring.
	var/base_evasion = 20
	/// The additional chance of evasion occurring for each structure.
	var/structure_evasion = 10
	/// If a projectile's accuracy is above this value, then evasion chance is decreased by each point above it.
	var/accuracy_reduction_requirement = 100

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
	if(prob(base_evasion + (get_total_structures() * structure_evasion) - (proj.accuracy ? max(0, proj.accuracy - accuracy_reduction_requirement) : 0)))
		dodge_fx(proj)
		return COMPONENT_PROJECTILE_DODGE
	return FALSE

/// Checks if they can dodge a thrown item. If they can, they do so.
/datum/mutation_upgrade/shell/ingrained_evasion/proc/dodge_thrown_item(datum/source, atom/movable/proj)
	SIGNAL_HANDLER
	if(prob(base_evasion + (get_total_structures() * structure_evasion)))
		dodge_fx(proj)
		return COMPONENT_PRE_THROW_IMPACT_HIT
	dodge_fx(proj)
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
	/// The beginning damage multiplier (at zero structures)
	var/beginning_damage_multiplier = 0.75
	/// The additional damage multiplier for each structure.
	var/damage_multiplier_per_structure = 0.25

/datum/mutation_upgrade/spur/sneak_attack/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/pounce/runner/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce/runner]
	if(!ability)
		return FALSE
	ability.dim_bonus_multiplier += beginning_damage_multiplier
	return ..()

/datum/mutation_upgrade/spur/sneak_attack/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/pounce/runner/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce/runner]
	if(!ability)
		return FALSE
	ability.dim_bonus_multiplier -= beginning_damage_multiplier
	return ..()

/datum/mutation_upgrade/spur/sneak_attack/on_structure_update(datum/source, previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/pounce/runner/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce/runner]
	if(!ability)
		return FALSE
	ability.dim_bonus_multiplier += (new_amount - previous_amount) * damage_multiplier_per_structure

/datum/mutation_upgrade/spur/right_here
	name = "Right Here"
	desc = "Pounce will slash your target for 0.5/0.75/1x slash damage based on the distance traveled. Every tile beyond the first reduces the amount by 20%."
	/// The beginning damage multiplier (at zero structures)
	var/beginning_damage_multiplier = 0.25
	/// The additional damage multiplier for each structure.
	var/damage_multiplier_per_structure = 0.25

/datum/mutation_upgrade/spur/right_here/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/pounce/runner/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce/runner]
	if(!ability)
		return FALSE
	ability.upclose_bonus_multiplier += beginning_damage_multiplier
	return ..()

/datum/mutation_upgrade/spur/right_here/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/pounce/runner/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce/runner]
	if(!ability)
		return FALSE
	ability.upclose_bonus_multiplier -= beginning_damage_multiplier
	return ..()

/datum/mutation_upgrade/spur/right_here/on_structure_update(datum/source, previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/pounce/runner/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce/runner]
	if(!ability)
		return FALSE
	ability.upclose_bonus_multiplier += (new_amount - previous_amount) * damage_multiplier_per_structure

/datum/mutation_upgrade/spur/mutilate
	name = "Mutilate"
	desc = "Savage now consumes all of your plasma. Savage damage increased by 1.5/1.75/2x."
	/// The beginning damage multiplier (at zero structures)
	var/beginning_damage_multiplier = 0.25
	/// The additional damage multiplier for each structure.
	var/damage_multiplier_per_structure = 0.25

/datum/mutation_upgrade/spur/mutilate/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/pounce/runner/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce/runner]
	if(!ability)
		return FALSE
	ability.savage_damage_multiplier += beginning_damage_multiplier
	return ..()

/datum/mutation_upgrade/spur/mutilate/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/pounce/runner/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce/runner]
	if(!ability)
		return FALSE
	ability.savage_damage_multiplier -= beginning_damage_multiplier
	return ..()

/datum/mutation_upgrade/spur/mutilate/on_structure_update(datum/source, previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/pounce/runner/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce/runner]
	if(!ability)
		return FALSE
	ability.savage_damage_multiplier += (new_amount - previous_amount) * damage_multiplier_per_structure

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/headslam
	name = "Head Slam"
	desc = "Savage decreases the stun duration significantly, but now confuses and blurs your target's vision for 1/2/3 seconds."
	/// The amount to divide stun and immobilize duration
	var/crowd_control_duration_divisible = 4

/datum/mutation_upgrade/veil/headslam/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/pounce/runner/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce/runner]
	if(!ability)
		return FALSE
	ability.stun_duration /= crowd_control_duration_divisible
	ability.immobilize_duration /= crowd_control_duration_divisible
	return ..()

/datum/mutation_upgrade/veil/headslam/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/pounce/runner/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce/runner]
	if(!ability)
		return FALSE
	ability.stun_duration *= crowd_control_duration_divisible
	ability.immobilize_duration *= crowd_control_duration_divisible
	return ..()

/datum/mutation_upgrade/veil/headslam/on_structure_update(datum/source, previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/pounce/runner/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce/runner]
	if(!ability)
		return FALSE
	ability.savage_debuff_amount += (new_amount - previous_amount)

/datum/mutation_upgrade/veil/frenzy
	name = "Frenzy"
	desc = "Savage's damage is converted to a buff that increases all melee damage by a percentage for 7s. It is a percentage of every point of damage Savage would of done multiplied by 0.5x/0.75/1x."
	/// The beginning damage multiplier (at zero structures)
	var/beginning_damage_multiplier = 0.25
	/// The additional damage multiplier for each structure.
	var/damage_multiplier_per_structure = 0.25

/datum/mutation_upgrade/veil/frenzy/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/pounce/runner/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce/runner]
	if(!ability)
		return FALSE
	ability.savage_damage_buff_alternative += beginning_damage_multiplier
	return ..()

/datum/mutation_upgrade/veil/frenzy/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/pounce/runner/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce/runner]
	if(!ability)
		return FALSE
	ability.savage_damage_buff_alternative -= beginning_damage_multiplier
	return ..()

/datum/mutation_upgrade/veil/frenzy/on_structure_update(datum/source, previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/activable/xeno/pounce/runner/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce/runner]
	if(!ability)
		return FALSE
	ability.savage_damage_buff_alternative += (new_amount - previous_amount) * damage_multiplier_per_structure

/datum/mutation_upgrade/veil/passing_glance
	name = "Passing Glance"
	desc = "While Evasion is on, moving onto the same location as a standing human will confuse them for 2/3/4s. This can only happens once per human. "
	/// The beginning length of the applied confusion (at zero structures)
	var/beginning_length = 1 SECONDS
	/// The additional length f the applied confusion for each structure.
	var/length_per_structure = 1 SECONDS

/datum/mutation_upgrade/veil/passing_glance/on_mutation_enabled()
	var/datum/action/ability/xeno_action/evasion/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/evasion]
	if(!ability)
		return FALSE
	ability.evasion_passthrough = TRUE
	ability.passthrough_confusion_length += beginning_length
	return ..()

/datum/mutation_upgrade/veil/passing_glance/on_mutation_disabled()
	var/datum/action/ability/xeno_action/evasion/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/evasion]
	if(!ability)
		return FALSE
	ability.evasion_passthrough = FALSE
	ability.passthrough_confusion_length -= beginning_length
	return ..()

/datum/mutation_upgrade/veil/passing_glance/on_structure_update(datum/source, previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/xeno_action/evasion/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/evasion]
	if(!ability)
		return FALSE
	ability.passthrough_confusion_length += (new_amount - previous_amount) * length_per_structure
