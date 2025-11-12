/datum/action/ability/activable/xeno/corrosive_acid/drone
	name = "Corrosive Acid"
	ability_cost = 75
	acid_type = /obj/effect/xenomorph/acid/weak

/datum/action/ability/activable/xeno/transfer_plasma/drone
	plasma_transfer_amount = PLASMA_TRANSFER_AMOUNT * 2

/datum/action/ability/xeno_action/create_jelly/slow
	cooldown_duration = 45 SECONDS

// ***************************************
// *********** Essence Link
// ***************************************
/datum/action/ability/activable/xeno/essence_link
	name = "Essence Link"
	action_icon_state = "essence_link_0"
	action_icon = 'icons/Xeno/actions/drone.dmi'
	desc = "Link to a xenomorph. This changes some of your abilities, and grants them and you both various bonuses."
	cooldown_duration = 5 SECONDS
	ability_cost = 0
	target_flags = ABILITY_MOB_TARGET
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_ESSENCE_LINK,
		KEYBINDING_ALTERNATE = COMSIG_XENOABILITY_ESSENCE_LINK_REMOVE,
	)
	use_state_flags = ABILITY_USE_LYING

	/// Used to determine whether there is an existing Essence Link or not. Also allows access to its vars.
	var/datum/status_effect/stacking/essence_link/existing_link
	/// The target of an existing link, if applicable.
	var/mob/living/carbon/xenomorph/linked_target
	/// Time it takes for the attunement levels to increase.
	var/attunement_cooldown = 60 SECONDS
	/// A percentage of health to restore to the owner whenever the linked target deals slash damage.
	var/lifesteal_percentage = 0
	/// The additive amount to increase melee damage modifier to the survivor if the link ends due to death.
	var/revenge_modifier = 0
	/// The percentage of max health healed to the linked target (and dealt to owner) if it was disconnected via alternative action.
	var/disconnection_heal_percentage = 0

/datum/action/ability/activable/xeno/essence_link/can_use_ability(mob/living/carbon/xenomorph/target, silent = FALSE, override_flags)
	if(!isxeno(target) || target.get_xeno_hivenumber() != xeno_owner.get_xeno_hivenumber())
		return FALSE
	if(!xeno_owner.Adjacent(target))
		xeno_owner.balloon_alert(xeno_owner, "not adjacent!")
		return FALSE
	if(target.tier == XENO_TIER_ZERO || target.tier == XENO_TIER_MINION)
		target.balloon_alert(xeno_owner, "we can't link to her!")
		return FALSE
	if(HAS_TRAIT(xeno_owner, TRAIT_ESSENCE_LINKED))
		target.balloon_alert(xeno_owner, "we're already linked!")
		return FALSE
	if(HAS_TRAIT(target, TRAIT_ESSENCE_LINKED))
		target.balloon_alert(xeno_owner, "she's already linked!")
		return FALSE
	return ..()

/datum/action/ability/activable/xeno/essence_link/use_ability(atom/target)
	if(!HAS_TRAIT(xeno_owner, TRAIT_ESSENCE_LINKED))
		target.balloon_alert(xeno_owner, "linking...")
		if(!do_after(xeno_owner, DRONE_ESSENCE_LINK_WINDUP, NONE, target, BUSY_ICON_FRIENDLY, BUSY_ICON_FRIENDLY))
			xeno_owner.balloon_alert(xeno_owner, "link cancelled!")
			return
		xeno_owner.apply_status_effect(STATUS_EFFECT_XENO_ESSENCE_LINK, 1, target, lifesteal_percentage, revenge_modifier)
		existing_link = xeno_owner.has_status_effect(STATUS_EFFECT_XENO_ESSENCE_LINK)
		linked_target = target
		target.balloon_alert(target, "essence link established")
	succeed_activate()

/datum/action/ability/activable/xeno/essence_link/alternate_action_activate()
	if(!HAS_TRAIT(xeno_owner, TRAIT_ESSENCE_LINKED))
		xeno_owner.balloon_alert(xeno_owner, "no link to cancel!")
		return
	end_ability(TRUE)
	return COMSIG_KB_ACTIVATED

/// Ends the ability, removing signals and buffs.
/datum/action/ability/activable/xeno/essence_link/proc/end_ability(was_manually_disconnected = FALSE)
	var/datum/action/ability/xeno_action/enhancement/enhancement_action = xeno_owner.actions_by_path[/datum/action/ability/xeno_action/enhancement]
	enhancement_action?.end_ability()
	if(was_manually_disconnected && existing_link.stacks)
		var/health_to_heal = linked_target.maxHealth * disconnection_heal_percentage * existing_link.stacks
		var/leftover_healing = health_to_heal
		HEAL_XENO_DAMAGE(linked_target, leftover_healing, TRUE)
		xeno_owner.adjustBruteLoss(health_to_heal - leftover_healing, TRUE)
	xeno_owner.remove_status_effect(STATUS_EFFECT_XENO_ESSENCE_LINK)
	existing_link = null
	linked_target = null
	add_cooldown()

/datum/action/ability/activable/xeno/essence_link/update_button_icon()
	action_icon_state = "essence_link_[existing_link ? (existing_link.stacks) : (0)]"
	return ..()

// ***************************************
// *********** Acidic Salve
// ***************************************
/datum/action/ability/activable/xeno/psychic_cure/acidic_salve
	name = "Acidic Salve"
	action_icon_state = "heal_xeno"
	action_icon = 'icons/Xeno/actions/drone.dmi'
	desc = "Apply a minor heal to the target. If applied to a linked sister, it will also apply a regenerative buff. Additionally, if that linked sister is near death, the heal's potency is increased."
	cooldown_duration = 5 SECONDS
	ability_cost = 150
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_ACIDIC_SALVE,
	)
	heal_range = DRONE_HEAL_RANGE
	target_flags = ABILITY_MOB_TARGET
	/// Should cast time / do_after be ignored if the target meets the health threshold?
	var/bypass_cast_time_on_threshold = FALSE
	/// The max health threshold the target needs to be under to qualify for bonus healing. Target must be connected to the owner with Essence Link with 1+ stacks.
	var/bonus_healing_threshold = 0.1
	/// The additional multiplier of healing if they meet the health threshold.
	var/bonus_healing_additive_multiplier = 2

/datum/action/ability/activable/xeno/psychic_cure/acidic_salve/use_ability(atom/target)
	if(xeno_owner.do_actions)
		return FALSE
	var/mob/living/living_target = target
	if((!bypass_cast_time_on_threshold || (living_target.health > (living_target.maxHealth * bonus_healing_threshold))))
		if(!do_after(xeno_owner, 1 SECONDS, NONE, target, BUSY_ICON_FRIENDLY, BUSY_ICON_MEDICAL))
			return FALSE
	xeno_owner.visible_message(span_xenowarning("\the [xeno_owner] vomits acid over [target], mending their wounds!"))
	owner.changeNext_move(CLICK_CD_RANGE)
	salve_healing(target)
	succeed_activate()
	add_cooldown()
	if(owner.client)
		var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[owner.ckey]
		personal_statistics.heals++

/// Heals the target and gives them a regenerative buff, if applicable.
/datum/action/ability/activable/xeno/psychic_cure/acidic_salve/proc/salve_healing(mob/living/carbon/xenomorph/target)
	var/datum/action/ability/activable/xeno/essence_link/essence_link_action = owner.actions_by_path[/datum/action/ability/activable/xeno/essence_link]
	var/heal_multiplier = 1
	if(essence_link_action.existing_link?.link_target == target)
		target.apply_status_effect(STATUS_EFFECT_XENO_SALVE_REGEN)
		if(essence_link_action.existing_link.stacks > 0 && (target.health <= (target.maxHealth * bonus_healing_threshold)))
			heal_multiplier += bonus_healing_additive_multiplier
	playsound(target, SFX_ALIEN_DROOL, 25)
	new /obj/effect/temp_visual/telekinesis(get_turf(target))
	var/heal_amount = (DRONE_BASE_SALVE_HEAL + target.recovery_aura * target.maxHealth * 0.01) * heal_multiplier
	var/leftover_healing = heal_amount
	HEAL_XENO_DAMAGE(target, leftover_healing, FALSE)
	var/sunder_change = target.adjust_sunder(-heal_amount / 10)
	GLOB.round_statistics.drone_acidic_salve += (heal_amount - leftover_healing)
	GLOB.round_statistics.drone_acidic_salve_sunder += -sunder_change
	if(heal_multiplier > 1) // A signal depends on the above heals, so this has to be done here.
		playsound(target,'sound/effects/magic.ogg', 75, 1)
		essence_link_action.existing_link.add_stacks(-1)

// ***************************************
// *********** Enhancement
// ***************************************
/datum/action/ability/xeno_action/enhancement
	name = "Enhancement"
	action_icon_state = "enhancement"
	action_icon = 'icons/Xeno/actions/drone.dmi'
	desc = "Apply an enhancement to the linked xeno, increasing their capabilities beyond their limits."
	cooldown_duration = 120 SECONDS
	ability_cost = 0
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_ENHANCEMENT,
	)
	use_state_flags = ABILITY_USE_BUCKLED
	/// References Essence Link and its vars.
	var/datum/action/ability/activable/xeno/essence_link/essence_link_action //todo: All this link stuff is handled in a stinky way
	/// Used to determine whether Enhancement is already active or not. Also allows access to its vars.
	var/datum/status_effect/drone_enhancement/existing_enhancement
	/// Damage bonus given by this ability.
	var/damage_multiplier = 1.15
	/// Speed bonus given by this ability.
	var/speed_addition = -0.4

/datum/action/ability/xeno_action/enhancement/New(Target)
	. = ..()
	INVOKE_NEXT_TICK(src, PROC_REF(link_essence_action))

/datum/action/ability/xeno_action/enhancement/can_use_action(silent, override_flags, selecting)
	if(existing_enhancement)
		return TRUE
	if(!HAS_TRAIT(owner, TRAIT_ESSENCE_LINKED))
		return FALSE
	if(!essence_link_action.existing_link.was_within_range)
		return FALSE
	if(essence_link_action.existing_link.stacks < essence_link_action.existing_link.max_stacks)
		return FALSE
	return ..()

/datum/action/ability/xeno_action/enhancement/action_activate()
	if(existing_enhancement)
		end_ability()
		return succeed_activate()
	essence_link_action.existing_link.add_stacks(-1)
	essence_link_action.linked_target.apply_status_effect(STATUS_EFFECT_XENO_ENHANCEMENT, owner)
	existing_enhancement = essence_link_action.linked_target.has_status_effect(STATUS_EFFECT_XENO_ENHANCEMENT)
	succeed_activate()

///Links this action to
/datum/action/ability/xeno_action/enhancement/proc/link_essence_action()
	if(essence_link_action)
		return
	essence_link_action = xeno_owner.actions_by_path[/datum/action/ability/activable/xeno/essence_link]
	if(!essence_link_action)
		CRASH("[type] loaded with a drone_enhancement to link to")
	RegisterSignal(essence_link_action, COMSIG_QDELETING, PROC_REF(unlink_essence_action))

///Signal proc to delink essence_link. Should only happen when the owner is being deleted to begin with
/datum/action/ability/xeno_action/enhancement/proc/unlink_essence_action()
	SIGNAL_HANDLER
	essence_link_action = null

/// Ends the ability if the Enhancement buff is removed.
/datum/action/ability/xeno_action/enhancement/proc/end_ability()
	if(existing_enhancement)
		essence_link_action.linked_target.remove_status_effect(STATUS_EFFECT_XENO_ENHANCEMENT)
		existing_enhancement = null
		add_cooldown()
