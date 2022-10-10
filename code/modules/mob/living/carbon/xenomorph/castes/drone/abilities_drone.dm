/datum/action/xeno_action/activable/corrosive_acid/drone
	name = "Corrosive Acid"
	plasma_cost = 75
	acid_type = /obj/effect/xenomorph/acid/weak

/datum/action/xeno_action/activable/transfer_plasma/drone
	plasma_transfer_amount = PLASMA_TRANSFER_AMOUNT * 2

/datum/action/xeno_action/create_jelly/slow
	cooldown_timer = 45 SECONDS

// ***************************************
// *********** Essence Link
// ***************************************
/datum/action/xeno_action/activable/essence_link
	name = "Essence Link"
	action_icon_state = "healing_infusion"
	mechanics_text = "Link to a xenomorph. This changes some of your abilities, and grants them and you both various bonuses."
	cooldown_timer = 1
	plasma_cost = 0
	target_flags = XABB_MOB_TARGET
	keybind_signal = COMSIG_XENOABILITY_ESSENCE_LINK
	alternate_keybind_signal = COMSIG_XENOABILITY_ESSENCE_LINK_REMOVE
	/// Time it takes for the link to form.
	var/link_delay = 3 SECONDS
	/// Used to determine whether there is an existing Essence Link or not. Also allows access to its vars.
	var/datum/status_effect/stacking/essence_link/existing_link
	/// If there is an existing link, this var will contain the link's target.
	var/mob/living/carbon/xenomorph/linked_target
	/// Used to determine whether Enhancement is already active or not. Also allows access to its vars.
	var/datum/status_effect/drone_enhancement/existing_enhancement

/datum/action/xeno_action/activable/essence_link/can_use_ability(mob/living/carbon/xenomorph/target, silent = FALSE, override_flags)
	var/mob/living/carbon/xenomorph/X = owner
	existing_link = X.has_status_effect(STATUS_EFFECT_XENO_ESSENCE_LINK)
	if(existing_link)
		linked_target = existing_link.link_target
		existing_enhancement = linked_target.has_status_effect(STATUS_EFFECT_XENO_ENHANCEMENT)
	. = ..()
	if(!.)
		return FALSE
	if(!isxeno(target) || target.hive.hivenumber != X.hive.hivenumber)
		return FALSE
	if(!X.Adjacent(target))
		X.balloon_alert(X, "Not adjacent")
		return FALSE
	if(!existing_link && HAS_TRAIT(target, TRAIT_ESSENCE_LINKED))
		target.balloon_alert(X, "She is already linked")
		return FALSE
	if(existing_link && target != linked_target)
		target.balloon_alert(X, "Not our linked sister")
		return FALSE
	return TRUE

/datum/action/xeno_action/activable/essence_link/use_ability(atom/target)
	var/mob/living/carbon/xenomorph/X = owner
	if(existing_link && existing_link.stacks < 3)
		target.balloon_alert(X, "Attuning...")
		if(!do_after(X, link_delay, TRUE, target, BUSY_ICON_FRIENDLY, BUSY_ICON_FRIENDLY))
			X.balloon_alert(X, "Attunement cancelled")
			return
		existing_link.add_stacks(1)
	if(!existing_link)
		target.balloon_alert(X, "Linking...")
		if(!do_after(X, link_delay, TRUE, target, BUSY_ICON_FRIENDLY, BUSY_ICON_FRIENDLY))
			X.balloon_alert(X, "Link cancelled")
			return
		var/essence_link = X.apply_status_effect(STATUS_EFFECT_XENO_ESSENCE_LINK, 1, target)
		RegisterSignal(essence_link, COMSIG_XENO_ESSENCE_LINK_REMOVED, .proc/end_ability)
		existing_link = X.has_status_effect(STATUS_EFFECT_XENO_ESSENCE_LINK)
		target.balloon_alert(target, "Essence Link established")
	target.balloon_alert(X, "Attunement: [existing_link.stacks]/[existing_link.max_stacks]")
	return succeed_activate()

/datum/action/xeno_action/activable/essence_link/alternate_action_activate()
	var/mob/living/carbon/xenomorph/X = owner
	existing_link = X.has_status_effect(STATUS_EFFECT_XENO_ESSENCE_LINK)
	if(!existing_link)
		X.balloon_alert(X, "No link to cancel")
		return
	end_ability()
	return COMSIG_KB_ACTIVATED

/datum/action/xeno_action/activable/essence_link/proc/end_ability()
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/X = owner
	linked_target = existing_link.link_target
	existing_enhancement = linked_target.has_status_effect(STATUS_EFFECT_XENO_ENHANCEMENT)
	if(existing_enhancement)
		linked_target.remove_status_effect(STATUS_EFFECT_XENO_ENHANCEMENT)
		SEND_SIGNAL(X, COMSIG_XENO_ENHANCEMENT_REMOVED)
	X.remove_status_effect(STATUS_EFFECT_XENO_ESSENCE_LINK)
	UnregisterSignal(X, COMSIG_XENO_ESSENCE_LINK_REMOVED)
	add_cooldown()

// ***************************************
// *********** Acidic Salve
// ***************************************
/datum/action/xeno_action/activable/psychic_cure/acidic_salve
	name = "Acidic Salve"
	action_icon_state = "heal_xeno"
	mechanics_text = "Apply a minor heal to the target. If applied to a linked sister, it will also apply a regenerative buff. Additionally, if that linked sister is near death, the heal's potency is tripled"
	cooldown_timer = 5 SECONDS
	plasma_cost = 150
	keybind_signal = COMSIG_XENOABILITY_PSYCHIC_CURE
	heal_range = DRONE_HEAL_RANGE
	target_flags = XABB_MOB_TARGET
	/// Used to determine whether there is an existing Essence Link or not. Also allows access to its vars.
	var/datum/status_effect/stacking/essence_link/existing_link
	/// Amount of health restored by this ability.
	var/heal_amount = 50
	/// Multiplier applied to this heal when below a certain threshold.
	var/heal_multiplier = 1

/datum/action/xeno_action/activable/psychic_cure/acidic_salve/use_ability(atom/target)
	var/mob/living/carbon/xenomorph/X = owner
	existing_link = X.has_status_effect(STATUS_EFFECT_XENO_ESSENCE_LINK)
	if(X.do_actions)
		return FALSE
	if(!do_mob(X, target, 1 SECONDS, BUSY_ICON_FRIENDLY, BUSY_ICON_MEDICAL))
		return FALSE
	X.visible_message(span_xenowarning("\the [X] vomits acid over [target], mending their wounds!"))
	owner.changeNext_move(CLICK_CD_RANGE)
	salve_healing(target)
	succeed_activate()
	add_cooldown()

/// Heals the target and gives them a regenerative buff, if applicable.
/datum/action/xeno_action/activable/psychic_cure/acidic_salve/proc/salve_healing(mob/living/carbon/xenomorph/target)
	var/remaining_health = round(target.maxHealth - (target.getBruteLoss() + target.getFireLoss()))
	var/health_threshold = round(target.maxHealth / 10) // 10% of the target's maximum health
	if(existing_link && existing_link.stacks >= 1 && target == existing_link.link_target)
		target.apply_status_effect(STATUS_EFFECT_XENO_SALVE_REGEN)
		if(remaining_health <= health_threshold)
			heal_multiplier = 3
			playsound(target,'sound/effects/magic.ogg', 75, 1)
			existing_link.add_stacks(-1)
	playsound(target, "alien_drool", 25)
	new /obj/effect/temp_visual/telekinesis(get_turf(target))
	heal_amount += round((target.recovery_aura * target.maxHealth * 0.01) * heal_multiplier) // +1% max health per recovery level, up to +5%. Multiplied by heal_multiplier.
	var/heal_remainder = round(max(0, heal_amount - target.getBruteLoss()) * heal_multiplier) // Heal brute first, apply whatever's left to burns
	target.apply_healing((heal_amount), BRUTE)
	target.apply_healing((heal_remainder), FIRE, TRUE)
	target.adjust_sunder(-(heal_amount)/20)

// ***************************************
// *********** Enhancement
// ***************************************
/datum/action/xeno_action/enhancement
	name = "Enhancement"
	action_icon_state = "enhancement"
	mechanics_text = "Apply an enhancement to the linked xeno, increasing their capabilities beyond their limits."
	cooldown_timer = 60 SECONDS
	plasma_cost = 0
	keybind_signal = COMSIG_XENOABILITY_ENHANCEMENT
	/// Used to determine whether there is an existing Essence Link or not. Also allows access to its vars.
	var/datum/status_effect/stacking/essence_link/existing_link
	/// If there is an existing link, this var will contain the link's target.
	var/mob/living/carbon/xenomorph/linked_target
	/// Used to determine whether Enhancement is already active or not. Also allows access to its vars.
	var/datum/status_effect/drone_enhancement/existing_enhancement

/datum/action/xeno_action/enhancement/can_use_action()
	var/mob/living/carbon/xenomorph/X = owner
	existing_link = X.has_status_effect(STATUS_EFFECT_XENO_ESSENCE_LINK)
	if(!existing_link || existing_link.stacks < 3)
		return FALSE
	return ..()

/datum/action/xeno_action/enhancement/action_activate()
	linked_target = existing_link.link_target
	existing_enhancement = linked_target.has_status_effect(STATUS_EFFECT_XENO_ENHANCEMENT)
	if(existing_enhancement)
		end_ability(target)
		return succeed_activate()
	linked_target.apply_status_effect(STATUS_EFFECT_XENO_ENHANCEMENT, owner)
	RegisterSignal(owner, COMSIG_XENO_ENHANCEMENT_REMOVED, .proc/end_ability)
	return succeed_activate()

/datum/action/xeno_action/enhancement/proc/end_ability()
	SIGNAL_HANDLER
	UnregisterSignal(owner, COMSIG_XENO_ENHANCEMENT_REMOVED)
	linked_target.remove_status_effect(STATUS_EFFECT_XENO_ENHANCEMENT)
	add_cooldown()
