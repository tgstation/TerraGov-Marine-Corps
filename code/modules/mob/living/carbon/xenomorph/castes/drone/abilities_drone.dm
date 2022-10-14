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
	cooldown_timer = 5 SECONDS
	plasma_cost = 0
	target_flags = XABB_MOB_TARGET
	keybind_signal = COMSIG_XENOABILITY_ESSENCE_LINK
	alternate_keybind_signal = COMSIG_XENOABILITY_ESSENCE_LINK_REMOVE
	/// Used to determine whether there is an existing Essence Link or not. Also allows access to its vars.
	var/datum/status_effect/stacking/essence_link/existing_link
	/// The target of an existing link, if applicable.
	var/mob/living/carbon/xenomorph/linked_target
	/// Time it takes for the attunement levels to increase.
	var/attunement_cooldown = 20 SECONDS

/datum/action/xeno_action/activable/essence_link/can_use_ability(mob/living/carbon/xenomorph/target, silent = FALSE, override_flags)
	var/mob/living/carbon/xenomorph/X = owner
	if(!isxeno(target) || target.get_xeno_hivenumber() != X.get_xeno_hivenumber())
		return FALSE
	if(!X.Adjacent(target))
		X.balloon_alert(X, "Not adjacent")
		return FALSE
	if(!existing_link && HAS_TRAIT(target, TRAIT_ESSENCE_LINKED))
		target.balloon_alert(X, "She is already linked")
		return FALSE
	if(existing_link)
		target.balloon_alert(X, "We are already linked")
		return FALSE
	return ..()

/datum/action/xeno_action/activable/essence_link/use_ability(atom/target)
	var/mob/living/carbon/xenomorph/X = owner
	if(!existing_link)
		target.balloon_alert(X, "Linking...")
		if(!do_after(X, DRONE_ESSENCE_LINK_WINDUP, TRUE, target, BUSY_ICON_FRIENDLY, BUSY_ICON_FRIENDLY))
			X.balloon_alert(X, "Link cancelled")
			return
		X.apply_status_effect(STATUS_EFFECT_XENO_ESSENCE_LINK, 1, target)
		existing_link = X.has_status_effect(STATUS_EFFECT_XENO_ESSENCE_LINK)
		linked_target = target
		target.balloon_alert(target, "Essence Link established")
	succeed_activate()

/datum/action/xeno_action/activable/essence_link/alternate_action_activate()
	var/mob/living/carbon/xenomorph/X = owner
	if(!existing_link)
		X.balloon_alert(X, "No link to cancel")
		return
	end_ability()
	return COMSIG_KB_ACTIVATED

/// Ends the ability, removing signals and buffs.
/datum/action/xeno_action/activable/essence_link/proc/end_ability()
	var/mob/living/carbon/xenomorph/X = owner
	var/datum/action/xeno_action/enhancement/enhancement_action = X.actions_by_path[/datum/action/xeno_action/enhancement]
	enhancement_action.end_ability()
	X.remove_status_effect(STATUS_EFFECT_XENO_ESSENCE_LINK)
	existing_link = null
	linked_target = null
	add_cooldown()

/datum/action/xeno_action/activable/essence_link/update_button_icon()
	button.overlays.Cut()
	button.overlays += image('icons/mob/actions.dmi', button, "essence_link_[existing_link ? (existing_link.stacks) : (0)]")
	return ..()

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

/datum/action/xeno_action/activable/psychic_cure/acidic_salve/use_ability(atom/target)
	var/mob/living/carbon/xenomorph/X = owner
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
	var/datum/action/xeno_action/activable/essence_link/essence_link_action = owner.actions_by_path[/datum/action/xeno_action/activable/essence_link]
	var/remaining_health = round(target.maxHealth - (target.getBruteLoss() + target.getFireLoss()))
	var/health_threshold = round(target.maxHealth / 10) // 10% of the target's maximum health
	var/heal_multiplier = 1
	if(essence_link_action?.existing_link && target == essence_link_action?.existing_link.link_target)
		target.apply_status_effect(STATUS_EFFECT_XENO_SALVE_REGEN)
		if(essence_link_action.existing_link.stacks >= 1 && remaining_health <= health_threshold)
			heal_multiplier = 3
	playsound(target, "alien_drool", 25)
	new /obj/effect/temp_visual/telekinesis(get_turf(target))
	var/heal_amount = (DRONE_BASE_SALVE_HEAL + target.recovery_aura * target.maxHealth * 0.01) * heal_multiplier
	var/heal_remainder = max(0, heal_amount - target.getBruteLoss()) // Heal brute first, apply whatever's left to burns
	target.adjustBruteLoss(-heal_amount)
	target.adjustFireLoss(-heal_remainder, TRUE)
	target.adjust_sunder(-heal_amount/20)
	if(heal_multiplier > 1) // A signal depends on the above heals, so this has to be done here.
		playsound(target,'sound/effects/magic.ogg', 75, 1)
		essence_link_action.existing_link.add_stacks(-1)

// ***************************************
// *********** Enhancement
// ***************************************
/datum/action/xeno_action/enhancement
	name = "Enhancement"
	action_icon_state = "enhancement"
	mechanics_text = "Apply an enhancement to the linked xeno, increasing their capabilities beyond their limits."
	cooldown_timer = 120 SECONDS
	plasma_cost = 0
	keybind_signal = COMSIG_XENOABILITY_ENHANCEMENT
	/// References Essence Link and its vars.
	var/datum/action/xeno_action/activable/essence_link/essence_link_action
	/// Used to determine whether Enhancement is already active or not. Also allows access to its vars.
	var/datum/status_effect/drone_enhancement/existing_enhancement
	/// Damage bonus given by this ability.
	var/damage_multiplier = 1.1
	/// Speed bonus given by this ability.
	var/speed_addition = -0.4

/datum/action/xeno_action/enhancement/can_use_action()
	var/mob/living/carbon/xenomorph/X = owner
	essence_link_action = X.actions_by_path[/datum/action/xeno_action/activable/essence_link]
	if(!essence_link_action.existing_link || !essence_link_action.existing_link.was_within_range || essence_link_action.existing_link.stacks < 3)
		return FALSE
	return ..()

/datum/action/xeno_action/enhancement/action_activate()
	if(existing_enhancement)
		end_ability()
		return succeed_activate()
	essence_link_action.existing_link.add_stacks(-1)
	essence_link_action.linked_target.apply_status_effect(STATUS_EFFECT_XENO_ENHANCEMENT, owner)
	existing_enhancement = essence_link_action.linked_target.has_status_effect(STATUS_EFFECT_XENO_ENHANCEMENT)
	succeed_activate()

/// Ends the ability if the Enhancement buff is removed.
/datum/action/xeno_action/enhancement/proc/end_ability()
	if(existing_enhancement)
		essence_link_action.linked_target.remove_status_effect(STATUS_EFFECT_XENO_ENHANCEMENT)
		existing_enhancement = null
		add_cooldown()
