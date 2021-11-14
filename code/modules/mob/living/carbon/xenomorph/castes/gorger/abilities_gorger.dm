/////////////////////////////////
// Devour
/////////////////////////////////
/datum/action/xeno_action/activable/devour
	name = "Devour"
	action_icon_state = "regurgitate"
	mechanics_text = "Devour your victim to be able to carry it faster."
	use_state_flags = XACT_USE_STAGGERED|XACT_USE_FORTIFIED|XACT_USE_CRESTED //can't use while staggered, defender fortified or crest down
	keybind_signal = COMSIG_XENOABILITY_REGURGITATE
	plasma_cost = 0
	target_flags = XABB_MOB_TARGET
	keybind_signal = COMSIG_XENOABILITY_DEVOUR

/datum/action/xeno_action/activable/devour/can_use_ability(atom/target, silent, override_flags)
	. = ..()
	if(!.)
		return
	if(!ishuman(target) || issynth(target))
		if(!silent)
			to_chat(owner, span_warning("That wouldn't taste very good."))
		return FALSE
	var/mob/living/carbon/human/victim = target
	if(owner.do_actions) //can't use if busy
		return FALSE
	if(!owner.Adjacent(victim)) //checks if owner next to target
		return FALSE
	if(!HAS_TRAIT(victim, TRAIT_UNDEFIBBABLE))
		if(!silent)
			to_chat(owner, span_warning("This creature is struggling too much for us to devour it."))
		return FALSE
	if(victim.buckled)
		if(!silent)
			to_chat(owner, span_warning("[victim] is buckled to something."))
		return FALSE
	var/mob/living/carbon/xenomorph/owner_xeno = owner
	if(owner_xeno.on_fire)
		if(!silent)
			to_chat(owner_xeno, span_warning("We're too busy being on fire to do this!"))
		return FALSE
	for(var/obj/effect/forcefield/fog in range(1, owner_xeno))
		if(!silent)
			to_chat(owner_xeno, span_warning("We are too close to the fog."))
		return FALSE

/datum/action/xeno_action/activable/devour/action_activate()
	. = ..()
	var/mob/living/carbon/xenomorph/owner_xeno = owner
	if(!owner_xeno.eaten_mob)
		return

	var/channel = SSsounds.random_available_channel()
	playsound(owner_xeno, 'sound/vore/escape.ogg', 40, channel = channel)
	if(!do_after(owner_xeno, 3 SECONDS, FALSE, null, BUSY_ICON_DANGER))
		to_chat(owner, span_warning("We moved too soon!"))
		owner_xeno.stop_sound_channel(channel)
		return
	owner_xeno.eject_victim()

/datum/action/xeno_action/activable/devour/use_ability(atom/target)
	var/mob/living/carbon/human/victim = target
	var/mob/living/carbon/xenomorph/owner_xeno = owner
	owner_xeno.face_atom(victim)
	owner_xeno.visible_message(span_danger("[owner_xeno] starts to devour [victim]!"), span_danger("We start to devour [victim]!"), null, 5)
	succeed_activate()
	var/channel = SSsounds.random_available_channel()
	playsound(owner_xeno, 'sound/vore/struggle.ogg', 40, channel = channel)
	if(!do_after(owner_xeno, 7 SECONDS, FALSE, victim, BUSY_ICON_DANGER, extra_checks = CALLBACK(owner, /mob.proc/break_do_after_checks, list("health" = owner_xeno.health))))
		to_chat(owner, span_warning("We stop devouring \the [victim]. They probably tasted gross anyways."))
		owner_xeno.stop_sound_channel(channel)
		return
	owner.visible_message(span_warning("[owner_xeno] devours [victim]!"), span_warning("We devour [victim]!"), null, 5)
	victim.forceMove(owner_xeno)
	owner_xeno.eaten_mob = victim
	add_cooldown()

/datum/action/xeno_action/activable/devour/ai_should_use(atom/target)
	return FALSE

// ***************************************
// *********** Drain blood
// ***************************************
/datum/action/xeno_action/activable/drain
	name = "Drain"
	action_icon_state = "drain"
	mechanics_text = "Stagger a marine and drain some of their blood. When used on a dead human, you heal gradually and don't gain blood."
	use_state_flags = XACT_KEYBIND_USE_ABILITY
	cooldown_timer = 15 SECONDS
	plasma_cost = 0
	target_flags = XABB_MOB_TARGET
	keybind_signal = COMSIG_XENOABILITY_DRAIN

/datum/action/xeno_action/activable/drain/can_use_ability(atom/target, silent = FALSE, override_flags)
	. = ..()
	if(!ishuman(target) || issynth(target))
		if(!silent)
			to_chat(owner, span_xenowarning("We can't drain this!"))
		return FALSE

	var/mob/living/carbon/xenomorph/owner_xeno = owner
	var/mob/living/carbon/human/target_human = target
	if(!owner_xeno.Adjacent(target_human))
		if(!silent)
			to_chat(owner_xeno, span_notice("We need to be next to our meal."))
		return FALSE

	if(target_human.stat == DEAD)
		if(owner_xeno.do_actions)
			return FALSE
		if(!HAS_TRAIT(target_human, TRAIT_UNDEFIBBABLE))
			if(!silent)
				to_chat(owner_xeno, span_notice("We can only use fully dead hosts to heal."))
			return FALSE
		if(target_human.blood_volume < GORGER_REJUVENATE_BLOOD_DRAIN)
			if(!silent)
				to_chat(owner_xeno, span_notice("Our meal has no blood... How sad!"))
			return FALSE
		return TRUE

	if(!.)
		return

	if(owner_xeno.plasma_stored >= owner_xeno.xeno_caste.plasma_max)
		if(!silent)
			to_chat(owner_xeno, span_xenowarning("No need, we feel sated for now..."))
		return FALSE

/datum/action/xeno_action/activable/drain/use_ability(mob/living/carbon/target)
	var/mob/living/carbon/xenomorph/owner_xeno = owner
	if(target.stat == DEAD)
		var/mob/living/carbon/human/target_human = target
		while(owner_xeno.health < owner_xeno.maxHealth && do_after(owner_xeno, 2 SECONDS, TRUE, target_human, BUSY_ICON_HOSTILE))
			if(target_human.blood_volume < GORGER_REJUVENATE_BLOOD_DRAIN)
				to_chat(owner, span_notice("Our meal has no blood... How sad!"))
				return
			owner_xeno.heal_wounds(2.2, TRUE)
			owner_xeno.adjust_sunder(-0.5)
			target.blood_volume -= GORGER_REJUVENATE_BLOOD_DRAIN
		to_chat(owner_xeno, span_notice("We feel fully restored."))
		return
	owner_xeno.face_atom(target)
	owner_xeno.emote("roar")
	target.drop_all_held_items()
	owner_xeno.do_attack_animation(target, ATTACK_EFFECT_REDSTAB)
	owner_xeno.visible_message(target, span_danger("The [owner_xeno] stabs its tail into [target]!"))
	playsound(target, "alien_claw_flesh", 25, TRUE)
	target.emote("scream")
	target.apply_damage(damage = 20, damagetype = BRUTE, def_zone = BODY_ZONE_HEAD, blocked = 0, sharp = TRUE, edge = FALSE, updating_health = TRUE)
	target.ParalyzeNoChain(0.25 SECONDS)
	target.blur_eyes(1)
	owner_xeno.gain_plasma(owner_xeno.xeno_caste.drain_plasma_gain)
	succeed_activate()
	add_cooldown()

/datum/action/xeno_action/activable/drain/ai_should_use(atom/target)
	if(!ishuman(target))
		return FALSE
	var/mob/living/carbon/xenomorph/owner_xeno = owner
	// no draining for plasma when full-ish plasma
	if(owner_xeno.xeno_caste.plasma_max - owner_xeno.plasma_stored < owner_xeno.xeno_caste.drain_plasma_gain)
		return FALSE
	return can_use_ability(target, TRUE) ? TRUE : ..()

#define REJUVENATE_ALLY "rejuvenate_ally_cooldown"

// ***************************************
// *********** Rejuvenate/Transfusion
// ***************************************
/datum/action/xeno_action/activable/rejuvenate
	name = "Rejuvenate/Transfusion"
	action_icon_state = "rejuvenation"
	mechanics_text = "When used on self, drains blood and restores health over time. When used on another xenomorph, costs blood and restores some of their health."
	use_state_flags = XACT_TARGET_SELF
	cooldown_timer = 20 SECONDS
	plasma_cost = 0
	target_flags = XABB_MOB_TARGET
	keybind_signal = COMSIG_XENOABILITY_REJUVENATE

/datum/action/xeno_action/activable/rejuvenate/can_use_ability(atom/target, silent = FALSE, override_flags) //it is set up to only return true on specific xeno or human targets
	. = ..()
	if(!isxeno(target))
		if(!silent)
			to_chat(owner, span_notice("We can only restore familiar biological lifeforms."))
		return FALSE

	var/mob/living/carbon/xenomorph/owner_xeno = owner
	if(owner_xeno != target)
		if(TIMER_COOLDOWN_CHECK(owner_xeno, REJUVENATE_ALLY))
			if(!silent)
				to_chat(owner_xeno, span_notice("We need [GORGER_REJUVENATE_SELF_COST - owner_xeno.plasma_stored]u more blood to revitalize ourselves."))
			return FALSE
		if(!owner_xeno.line_of_sight(target) || get_dist(owner_xeno, target) > 2)
			if(!silent)
				to_chat(owner_xeno, span_notice("It is beyond our reach, we must be close and our way must be clear."))
			return FALSE
		if(owner_xeno.plasma_stored < GORGER_REJUVENATE_ALLY_COST)
			if(!silent)
				to_chat(owner_xeno, span_notice("We need [GORGER_REJUVENATE_ALLY_COST - owner_xeno.plasma_stored]u more blood to restore a sister."))
			return FALSE
		if(isdead(target))
			if(!silent)
				to_chat(owner_xeno, span_notice("We can only help living sisters."))
			return FALSE
		if(!do_mob(owner_xeno, target, 1 SECONDS, BUSY_ICON_FRIENDLY, BUSY_ICON_MEDICAL))
			return FALSE
		return TRUE

/datum/action/xeno_action/activable/rejuvenate/use_ability(atom/target)
	var/mob/living/carbon/xenomorph/owner_xeno = owner
	if(target == owner_xeno)
		owner_xeno.use_plasma(GORGER_REJUVENATE_SELF_COST)
		owner_xeno.apply_status_effect(/datum/status_effect/xeno_rejuvenate, GORGER_REJUVENATE_SELF_DURATION)
		to_chat(owner_xeno, span_notice("We tap into our reserves for nourishment."))
		add_cooldown()
	else
		owner_xeno.use_plasma(GORGER_REJUVENATE_ALLY_COST)
		TIMER_COOLDOWN_START(owner_xeno, REJUVENATE_ALLY, GORGER_REJUVENATE_ALLY_COOLDOWN)
		var/mob/living/carbon/xenomorph/target_xeno = target
		target_xeno.adjustBruteLoss(-target_xeno.maxHealth * GORGER_REJUVENATE_ALLY_PERCENTAGE)
		target_xeno.adjustFireLoss(-target_xeno.maxHealth * GORGER_REJUVENATE_ALLY_PERCENTAGE)
	succeed_activate()

/datum/action/xeno_action/activable/rejuvenate/ai_should_use(atom/target)
	// no healing non-xeno
	if(!isxeno(target))
		return FALSE
	var/mob/living/carbon/xenomorph/target_xeno = target
	if(target_xeno.get_xeno_hivenumber() != owner.get_xeno_hivenumber())
		return FALSE
	// no overhealing
	if(target_xeno.health > target_xeno.maxHealth * GORGER_REJUVENATE_ALLY_PERCENTAGE)
		return FALSE
	return can_use_ability(target, TRUE) ? TRUE : ..()

#undef REJUVENATE_ALLY

// ***************************************
// *********** Carnage
// ***************************************
/datum/action/xeno_action/activable/carnage
	name = "Carnage"
	action_icon_state = "carnage"
	mechanics_text = "For a while your attacks drain blood and heal you. During Feast you also heal nearby allies."
	use_state_flags = XACT_TARGET_SELF|XACT_IGNORE_SELECTED_ABILITY
	cooldown_timer = 40 SECONDS
	plasma_cost = 0
	keybind_signal = COMSIG_XENOABILITY_CARNAGE
	keybind_flags = XACT_KEYBIND_USE_ABILITY

/datum/action/xeno_action/activable/carnage/use_ability(atom/A)
	. = ..()
	var/mob/living/carbon/xenomorph/owner_xeno = owner
	owner_xeno.apply_status_effect(/datum/status_effect/xeno_carnage, 20 SECONDS, owner_xeno.xeno_caste.carnage_plasma_gain)
	add_cooldown()
	succeed_activate()

/datum/action/xeno_action/activable/carnage/ai_should_use(atom/target)
	var/mob/living/carbon/xenomorph/owner_xeno = owner
	if(owner_xeno.plasma_stored > owner_xeno.xeno_caste.plasma_max * 0.8)
		// ability is primarily used for plasma gain, so should be used even at full health
		if(owner_xeno.health > owner_xeno.maxHealth * 0.9)
			return FALSE
		return FALSE
	// nothing gained by slashing allies
	if(target.get_xeno_hivenumber() == owner_xeno.get_xeno_hivenumber())
		return FALSE

	return can_use_ability(target) ? TRUE : ..()

// ***************************************
// *********** Feast
// ***************************************

/datum/action/xeno_action/activable/feast
	name = "Feast"
	action_icon_state = "feast"
	mechanics_text = "Enter a state of rejuvenation. During this time you use a small amount of blood and heal. You can cancel this early."
	use_state_flags = XACT_IGNORE_SELECTED_ABILITY|XACT_KEYBIND_USE_ABILITY
	cooldown_timer = 180 SECONDS
	plasma_cost = 0
	keybind_signal = COMSIG_XENOABILITY_FEAST
	keybind_flags = XACT_KEYBIND_USE_ABILITY
	///Adds a cooldown to deactivation to avoid accidental cancel
	COOLDOWN_DECLARE(misclick_prevention)

/datum/action/xeno_action/activable/feast/can_use_ability(atom/target, silent, override_flags)
	. = ..()
	var/mob/living/carbon/xenomorph/owner_xeno = owner

	if(!COOLDOWN_CHECK(src, misclick_prevention))
		return FALSE
	if(owner_xeno.has_status_effect(STATUS_EFFECT_XENO_FEAST))
		return TRUE

/datum/action/xeno_action/activable/feast/use_ability(atom/A)
	. = ..()
	var/mob/living/carbon/xenomorph/owner_xeno = owner
	if(owner_xeno.has_status_effect(STATUS_EFFECT_XENO_FEAST))
		to_chat(owner_xeno, span_notice("We decide to end our feast early..."))
		owner_xeno.remove_status_effect(STATUS_EFFECT_XENO_FEAST)
		return

	owner_xeno.emote("roar")
	owner_xeno.visible_message(owner_xeno, span_notice("[owner_xeno] begins to overflow with vitality!"))
	owner_xeno.apply_status_effect(/datum/status_effect/xeno_feast, GORGER_FEAST_DURATION, owner_xeno.xeno_caste.feast_plasma_drain)
	COOLDOWN_START(src, misclick_prevention, 2 SECONDS)
	add_cooldown()
	succeed_activate()

/datum/action/xeno_action/activable/feast/ai_should_use(atom/target)
	var/mob/living/carbon/xenomorph/owner_xeno = owner
	// cancel the buff when at full health to conserve plasma, otherwise don't cancel
	if(owner_xeno.has_status_effect(STATUS_EFFECT_XENO_FEAST))
		return owner_xeno.health == owner_xeno.maxHealth
	// small damage has more efficient alternatives to be healed with
	if(owner_xeno.health > owner_xeno.maxHealth * 0.7)
		return FALSE
	// should use the ability when there is enough resource for the buff to tick a moderate amount of times
	if(owner_xeno.plasma_stored / owner_xeno.xeno_caste.feast_plasma_drain < 7)
		return FALSE

	return can_use_ability(target) ? TRUE : ..()
