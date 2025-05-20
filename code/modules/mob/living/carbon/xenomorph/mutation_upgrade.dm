/datum/mutation_upgrade
	/// The name that is displayed in the TGUI.
	var/name
	/// The description that is displayed in the TGUI.
	var/desc
	/// The category slot that this upgrade takes. This prevents the owner from buying additional mutation that have the same category.
	var/category
	/// The structure that needs to exist for a successful purchase.
	var/required_structure
	/// The status effect given upon successful purchase.
	var/datum/status_effect/status_effect
	/// The xenomorph owner of this mutation upgrade.
	var/mob/living/carbon/xenomorph/xenomorph_owner

/// Sets up the owner, applies the status effect for having the mutation, registers various signals, and then updates with current structure count.
/datum/mutation_upgrade/New(mob/living/carbon/xenomorph/new_xeno_owner)
	..()
	xenomorph_owner = new_xeno_owner
	xenomorph_owner.apply_status_effect(status_effect)
	switch(required_structure)
		if(MUTATION_SHELL)
			RegisterSignal(SSdcs, COMSIG_MUTATION_CHAMBER_SHELL, PROC_REF(on_structure_update))
		if(MUTATION_SPUR)
			RegisterSignal(SSdcs, COMSIG_MUTATION_CHAMBER_SPUR, PROC_REF(on_structure_update))
		if(MUTATION_VEIL)
			RegisterSignal(SSdcs, COMSIG_MUTATION_CHAMBER_VEIL, PROC_REF(on_structure_update))
	RegisterSignal(xenomorph_owner, COMSIG_XENOMORPH_ABILITY_ON_UPGRADE, TYPE_PROC_REF(/datum/mutation_upgrade, on_xenomorph_upgrade))
	on_structure_update(null, 0, get_total_structures())

/// Removes the status effect for having the mutation, unregisters various signals, and then updates with zero structures.
/datum/mutation_upgrade/Destroy(force, ...)
	xenomorph_owner.remove_status_effect(status_effect)
	switch(required_structure)
		if(MUTATION_SHELL)
			UnregisterSignal(SSdcs, COMSIG_MUTATION_CHAMBER_SHELL)
		if(MUTATION_SPUR)
			UnregisterSignal(SSdcs, COMSIG_MUTATION_CHAMBER_SPUR)
		if(MUTATION_VEIL)
			UnregisterSignal(SSdcs, COMSIG_MUTATION_CHAMBER_VEIL)
	UnregisterSignal(xenomorph_owner, COMSIG_XENOMORPH_ABILITY_ON_UPGRADE)
	on_structure_update(null, get_total_structures(), 0)
	return ..()

/// Called whenever the mutation is created/deleted or when the amount of buildings has changed.
/datum/mutation_upgrade/proc/on_structure_update(datum/source, previous_amount, new_amount)
	SIGNAL_HANDLER
	if(previous_amount == new_amount)
		return FALSE
	return TRUE

/// Called whenever the xenomorph owner is upgraded (e.g. normal to primordial).
/datum/mutation_upgrade/proc/on_xenomorph_upgrade()
	return TRUE

/// Gets the total amount of buildings for the mutation.
/datum/mutation_upgrade/proc/get_total_structures()
	if(!xenomorph_owner || !required_structure)
		return 0
	switch(required_structure)
		if(MUTATION_SHELL)
			return length(xenomorph_owner.hive.shell_chambers)
		if(MUTATION_SPUR)
			return length(xenomorph_owner.hive.spur_chambers)
		if(MUTATION_VEIL)
			return length(xenomorph_owner.hive.veil_chambers)

/**
 * Shell Mutations
 */
/datum/mutation_upgrade/shell
	category = MUTATION_SHELL
	required_structure = MUTATION_SHELL
	status_effect = STATUS_EFFECT_MUTATION_SHELL

// Defender
/datum/mutation_upgrade/shell/carapace_waxing
	name = "Carapace Waxing"
	desc = "Regenerate Skin additionally reduces various debuffs by 1/2/3 stacks or 2/4/6 seconds."
	/// The beginning amount of the debuff removal (at zero structures)
	var/beginning_amount = 0
	/// The additional amount of the debuff removal for each structure.
	var/amount_per_structure = 1

/datum/mutation_upgrade/shell/carapace_waxing/on_structure_update(datum/source, previous_amount, new_amount)
	if(!..())
		return
	var/datum/action/ability/xeno_action/regenerate_skin/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/regenerate_skin]
	if(!ability)
		return
	ability.debuff_amount_to_remove += (new_amount - previous_amount)

/datum/mutation_upgrade/shell/brittle_upclose
	name = "Brittle Upclose"
	desc = "You can no longer be staggered by projectiles and gain 5/7.5/10 bullet armor. However, you lose 30/35/40 melee armor."

/datum/mutation_upgrade/shell/brittle_upclose/on_structure_update(datum/source, previous_amount, new_amount)
	if(!..())
		return
	if(previous_amount && !new_amount)
		xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.modifyRating(25, -2.5)
		REMOVE_TRAIT(xenomorph_owner, TRAIT_STAGGER_RESISTANT, TRAIT_MUTATION)
	if(new_amount && !previous_amount)
		xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.modifyRating(-25, 2.5)
		ADD_TRAIT(xenomorph_owner, TRAIT_STAGGER_RESISTANT, TRAIT_MUTATION)
	var/difference = new_amount - previous_amount
	xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.modifyRating(difference * -5, difference * 2.5)

/datum/mutation_upgrade/shell/carapace_regrowth
	name = "Carapace Regrowth"
	desc = "Regenerate Skin additionally recovers 50/60/70% of your maximum health, but will reduce all of your armor values by 30 for 6 seconds."
	/// The beginning percentage of the health to heal (at zero structures)
	var/beginning_percentage = 0.4
	/// The additional percentage of the health to heal for each structure.
	var/percentage_per_structure = 0.1

/datum/mutation_upgrade/shell/carapace_regrowth/on_structure_update(datum/source, previous_amount, new_amount)
	if(!..())
		return
	var/datum/action/ability/xeno_action/regenerate_skin/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/regenerate_skin]
	if(!ability)
		return
	if(previous_amount && !new_amount)
		ability.percentage_to_heal -= beginning_percentage
		ability.should_apply_temp_debuff = FALSE
	if(new_amount && !previous_amount)
		ability.percentage_to_heal += beginning_percentage
		ability.should_apply_temp_debuff = TRUE
	ability.percentage_to_heal += (new_amount - previous_amount) * percentage_per_structure

// Runner
/datum/mutation_upgrade/shell/upfront_evasion
	name = "Upfront Evasion"
	desc = "Evasion starts off 1/2/3s longer, but it no longer refreshes from dodging projectiles."

/datum/mutation_upgrade/shell/upfront_evasion/on_structure_update(datum/source, previous_amount, new_amount)
	if(!..())
		return
	var/datum/action/ability/xeno_action/evasion/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/evasion]
	if(!ability)
		return
	ability.refresh_disabled = new_amount ? TRUE : FALSE
	if(new_amount && ability.auto_evasion)
		ability.alternate_action_activate() // Auto Evasion's whole point is to re-activate the ability when Evasion refreshes. If it never refreshes, then there is no use in Auto Evasion.
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

/datum/mutation_upgrade/shell/borrowed_time/on_structure_update(datum/source, previous_amount, new_amount)
	if(!..())
		return
	if(!new_amount)
		if(critical_threshold_timer)
			reverse_critical_threshold()
		else if(critical_threshold_boosted)
			toggle()
		UnregisterSignal(xenomorph_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE))
		return
	if(!previous_amount)
		RegisterSignals(xenomorph_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE), PROC_REF(on_damage))
		if(!critical_threshold_boosted && xenomorph_owner.health >= xenomorph_owner.maxHealth)
			toggle(TRUE)

/// Increases or decreases the critical threshold amount for the owner.
/datum/mutation_upgrade/shell/borrowed_time/proc/toggle(silent = FALSE)
	critical_threshold_boosted = !critical_threshold_boosted
	if(critical_threshold_boosted)
		to_chat(xenomorph_owner, span_notice("You feel like you recovered from being on Borrowed Time."))
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
	// Has the Evasion ability already been removed?
	var/already_removed_ability = FALSE
	/// After this amount of time since their last move, they will no longer evade projectiles.
	var/movement_leniency = 0.5 SECONDS
	/// The chance of evasion occurring.
	var/base_evasion = 20
	/// The additional chance of evasion occurring for each structure.
	var/structure_evasion = 10
	/// If a projectile's accuracy is above this value, then evasion chance is decreased by each point above it.
	var/accuracy_reduction_requirement = 100

/datum/mutation_upgrade/shell/ingrained_evasion/on_structure_update(datum/source, previous_amount, new_amount)
	if(!..())
		return
	if(!new_amount)
		if(already_removed_ability)
			var/datum/action/ability/xeno_action/evasion/ability = new()
			already_removed_ability = FALSE
			ability.give_action(xenomorph_owner)
		UnregisterSignal(xenomorph_owner, list(COMSIG_XENO_PROJECTILE_HIT, COMSIG_LIVING_PRE_THROW_IMPACT))
		return
	if(previous_amount)
		return
	var/datum/action/ability/xeno_action/evasion/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/evasion]
	if(ability)
		already_removed_ability = TRUE
		ability.remove_action(xenomorph_owner)
	RegisterSignal(xenomorph_owner, COMSIG_XENO_PROJECTILE_HIT, PROC_REF(dodge_projectile))
	RegisterSignal(xenomorph_owner, COMSIG_LIVING_PRE_THROW_IMPACT, PROC_REF(dodge_thrown_item))

/datum/mutation_upgrade/shell/ingrained_evasion/on_xenomorph_upgrade()
	if(!already_removed_ability)
		return
	var/datum/action/ability/xeno_action/evasion/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/evasion]
	if(ability)
		ability.remove_action(xenomorph_owner)

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

/**
 * Spur
 */
/datum/mutation_upgrade/spur
	category = MUTATION_SPUR
	required_structure = MUTATION_SPUR
	status_effect = STATUS_EFFECT_MUTATION_SPUR

// Defender
/datum/mutation_upgrade/spur/breathtaking_spin
	name = "Breathtaking Spin"
	desc = "Tail Swipe no longer stuns and deals stamina damage instead. It deals an additional 2x/2.75x/2.5x stamina damage."

/datum/mutation_upgrade/spur/breathtaking_spin/on_structure_update(datum/source, previous_amount, new_amount)
	if(!..())
		return
	var/datum/action/ability/xeno_action/tail_sweep/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/tail_sweep]
	if(!ability)
		return
	if(previous_amount && !new_amount)
		ability.brute_damage_multiplier += 1
		ability.stamina_damage_multiplier -= 2.25
		ability.paralyze_duration += 0.5 SECONDS
	if(new_amount && !previous_amount)
		ability.brute_damage_multiplier -= 1
		ability.stamina_damage_multiplier += 2.25
		ability.paralyze_duration -= 0.5 SECONDS
	ability.stamina_damage_multiplier += (new_amount - previous_amount) * 0.75

/datum/mutation_upgrade/spur/power_spin
	name = "Power Spin"
	desc = "Tail Swipe knockbacks humans one tile further and staggers them for 1/2/3s."

/datum/mutation_upgrade/spur/power_spin/on_structure_update(datum/source, previous_amount, new_amount)
	if(!..())
		return
	var/datum/action/ability/xeno_action/tail_sweep/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/tail_sweep]
	if(!ability)
		return
	if(previous_amount && !new_amount)
		ability.knockback_distance -= 1
	if(new_amount && !previous_amount)
		ability.knockback_distance += 1
	ability.stagger_duration += (new_amount - previous_amount) SECONDS

/datum/mutation_upgrade/spur/sharpening_claws
	name = "Sharpening Claws"
	desc = "For 10 sunder you have, you gain 3/6/9% additive increase in your slash damage."
	/// How many times has the melee damage modifier been increased?
	var/multiplier_so_far = 0

/datum/mutation_upgrade/spur/sharpening_claws/on_structure_update(datum/source, previous_amount, new_amount)
	if(!..())
		return
	if(previous_amount && !new_amount)
		UnregisterSignal(xenomorph_owner, COMSIG_XENOMORPH_SUNDER_CHANGE)
	if(new_amount && !previous_amount)
		RegisterSignal(xenomorph_owner, COMSIG_XENOMORPH_SUNDER_CHANGE, PROC_REF(on_sunder_change))
	xenomorph_owner.xeno_melee_damage_modifier -= multiplier_so_far * previous_amount * 0.03
	multiplier_so_far = 0
	on_sunder_change(null, 0, xenomorph_owner.sunder)

/// Changes melee damage modifier based on the difference between old and current sunder values.
/datum/mutation_upgrade/spur/sharpening_claws/proc/on_sunder_change(datum/source, old_sunder, new_sunder)
	SIGNAL_HANDLER
	var/multiplier_difference = (FLOOR(new_sunder, 10) * 0.1) - multiplier_so_far
	if(multiplier_difference == 0)
		return
	xenomorph_owner.xeno_melee_damage_modifier += multiplier_difference * get_total_structures() * 0.03
	multiplier_so_far += multiplier_difference

// Runner
/datum/mutation_upgrade/spur/sneak_attack
	name = "Sneak Attack"
	desc = "Pounce will slash your target for 1/1.25/1.5x damage if it was started in low light."

/datum/mutation_upgrade/spur/sneak_attack/on_structure_update(datum/source, previous_amount, new_amount)
	if(!..())
		return
	var/datum/action/ability/activable/xeno/pounce/runner/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce/runner]
	if(!ability)
		return
	if(previous_amount && !new_amount)
		ability.dim_bonus_multiplier -= 0.75
	if(new_amount && !previous_amount)
		ability.dim_bonus_multiplier += 0.75
	ability.dim_bonus_multiplier += (new_amount - previous_amount) * 0.25

/datum/mutation_upgrade/spur/right_here
	name = "Right Here"
	desc = "Pounce will slash your target for 0.5/0.75/1x slash damage based on the distance traveled. Every tile beyond the first reduces the amount by 20%."

/datum/mutation_upgrade/spur/right_here/on_structure_update(datum/source, previous_amount, new_amount)
	if(!..())
		return
	var/datum/action/ability/activable/xeno/pounce/runner/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce/runner]
	if(!ability)
		return
	if(previous_amount && !new_amount)
		ability.upclose_bonus_multiplier -= 0.25
	if(new_amount && !previous_amount)
		ability.upclose_bonus_multiplier += 0.25
	ability.upclose_bonus_multiplier += (new_amount - previous_amount) * 0.25

/datum/mutation_upgrade/spur/mutilate
	name = "Mutilate"
	desc = "Savage now consumes all of your plasma. Savage damage increased by 1.5/1.75/2x."
	/// The beginning damage multiplier (at zero structures)
	var/beginning_damage_multiplier = 0.25
	/// The additional damage multiplier for each structure.
	var/damage_multiplier_per_structure = 0.25

/datum/mutation_upgrade/spur/mutilate/on_structure_update(datum/source, previous_amount, new_amount)
	if(!..())
		return
	var/datum/action/ability/activable/xeno/pounce/runner/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce/runner]
	if(!ability)
		return
	if(previous_amount && !new_amount)
		ability.savage_damage_multiplier += beginning_damage_multiplier
	if(new_amount && !previous_amount)
		ability.savage_damage_multiplier += beginning_damage_multiplier
	ability.savage_damage_multiplier += (new_amount - previous_amount) * damage_multiplier_per_structure

/**
 * Veil
 */
/datum/mutation_upgrade/veil
	category = MUTATION_VEIL
	required_structure = MUTATION_VEIL
	status_effect = STATUS_EFFECT_MUTATION_VEIL

// Defender
/datum/mutation_upgrade/veil/carapace_sweat
	name = "Carapace Sweat"
	desc = "Regenerate Skin can be used while on fire and grants fire immunity for 2/4/6 seconds. If you were on fire, you will be extinguished and set nearby humans on fire."

/datum/mutation_upgrade/veil/carapace_sweat/on_structure_update(datum/source, previous_amount, new_amount)
	if(!..())
		return

	var/datum/action/ability/xeno_action/regenerate_skin/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/regenerate_skin]
	if(!ability)
		return
	ability.fire_immunity_length += 2 * (new_amount - previous_amount) SECONDS

/datum/mutation_upgrade/veil/slow_and_steady
	name = "Slow and Steady"
	desc = "While Fortify is active, you can move at 10/20/30% of your movement speed."

/datum/mutation_upgrade/veil/slow_and_steady/on_structure_update(datum/source, previous_amount, new_amount)
	if(!..())
		return
	var/datum/action/ability/xeno_action/fortify/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/fortify]
	if(!ability)
		return
	if(previous_amount && !new_amount)
		ability.movement_modifier -= 12
	if(new_amount && !previous_amount)
		ability.movement_modifier += 12 // Eyeballing the movement speed and hope that it is close enough in function.
	ability.movement_modifier -= 2 * (new_amount - previous_amount)

/datum/mutation_upgrade/veil/carapace_sharing
	name = "Carapace Sharing"
	desc = "Regenerate Skin additionally removes 8/16/24% sunder of a nearby friendly xenomorph. This prioritizes those with the highest sunder."

/datum/mutation_upgrade/veil/carapace_sharing/on_structure_update(datum/source, previous_amount, new_amount)
	if(!..())
		return
	var/datum/action/ability/xeno_action/regenerate_skin/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/regenerate_skin]
	if(!ability)
		return
	ability.percentage_to_unsunder_ally += (new_amount - previous_amount) * 0.08

// Runner
/datum/mutation_upgrade/veil/headslam
	name = "Head Slam"
	desc = "Savage decreases the stun duration significantly, but now confuses and blurs your target's vision for 1/2/3 seconds at maximum scaled by your remaining plasma."

/datum/mutation_upgrade/veil/headslam/on_structure_update(datum/source, previous_amount, new_amount)
	if(!..())
		return
	var/datum/action/ability/activable/xeno/pounce/runner/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce/runner]
	if(!ability)
		return
	if(previous_amount && !new_amount)
		ability.stun_duration = initial(ability.stun_duration)
		ability.immobilize_duration = initial(ability.immobilize_duration)
	if(new_amount && !previous_amount)
		ability.stun_duration = initial(ability.stun_duration) / 4
		ability.immobilize_duration = initial(ability.immobilize_duration) / 4
	ability.savage_debuff_amount += (new_amount - previous_amount)

/datum/mutation_upgrade/veil/frenzy
	name = "Frenzy"
	desc = "Savage's damage is converted to a buff that increases all melee damage by a percentage for 7s. It is a percentage of every point of damage Savage would of done multiplied by 0.5x/0.75/1x."
	/// The beginning damage multiplier (at zero structures)
	var/beginning_damage_multiplier = 0.25
	/// The additional damage multiplier for each structure.
	var/damage_multiplier_per_structure = 0.25

/datum/mutation_upgrade/veil/frenzy/on_structure_update(datum/source, previous_amount, new_amount)
	if(!..())
		return
	var/datum/action/ability/activable/xeno/pounce/runner/ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce/runner]
	if(!ability)
		return
	if(previous_amount && !new_amount)
		ability.savage_damage_buff_alternative -= beginning_damage_multiplier
	if(new_amount && !previous_amount)
		ability.savage_damage_buff_alternative += beginning_damage_multiplier
	ability.savage_damage_buff_alternative += (new_amount - previous_amount) * damage_multiplier_per_structure

/datum/mutation_upgrade/veil/passing_glance
	name = "Passing Glance"
	desc = "While Evasion is on, moving onto the same location as a standing human will confuse them for 2/3/4s. This can only happens once per human. "
	/// The beginning length of the applied confusion (at zero structures)
	var/beginning_length = 1 SECONDS
	/// The additional length f the applied confusion for each structure.
	var/length_per_structure = 1 SECONDS

/datum/mutation_upgrade/veil/passing_glance/on_structure_update(datum/source, previous_amount, new_amount)
	if(!..())
		return
	var/datum/action/ability/xeno_action/evasion/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/evasion]
	if(!ability)
		return
	if(previous_amount && !new_amount)
		ability.evasion_passthrough = FALSE
		ability.passthrough_confusion_length -= beginning_length
	if(new_amount && !previous_amount)
		ability.evasion_passthrough = TRUE
		ability.passthrough_confusion_length += beginning_length
	ability.passthrough_confusion_length += (new_amount - previous_amount) * length_per_structure


// melter crap: next_move_adjust
