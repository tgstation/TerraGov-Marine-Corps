// ***************************************
// *********** Drain blood
// ***************************************
/datum/action/xeno_action/activable/drain
	name = "Drain"
	action_icon_state = "drain"
	mechanics_text = "Hold a marine and drain some of their blood if successful."
	cooldown_timer = 15 SECONDS
	plasma_cost = 0
	target_flags = XABB_MOB_TARGET

/datum/action/xeno_action/activable/drain/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return
	if(!iscarbon(A))
		return FALSE
	if(!A.can_sting())
		if(!silent)
			to_chat(owner, span_xenowarning("We can't drain this!"))
		return FALSE
	var/mob/living/carbon/xenomorph/X = owner
	if(X.plasma_stored >= X.xeno_caste.plasma_max)
		if(!silent)
			to_chat(X, span_xenowarning("No need, we feel sated for now..."))
		return FALSE
	if(!X.Adjacent(A))
		if(!silent)
			to_chat(X, span_xenowarning("It is outside of our reach! We need to be closer!"))
		return FALSE

/datum/action/xeno_action/activable/drain/use_ability(mob/living/carbon/A)
	var/mob/living/carbon/xenomorph/X = owner
	X.face_atom(A)
	X.emote("roar")
	A.drop_all_held_items()
	X.do_attack_animation(A, ATTACK_EFFECT_REDSTAB)
	X.visible_message(A, span_danger("The [X] stabs its tail into [A]!"))
	playsound(A, "alien_claw_flesh", 25, TRUE)
	A.emote("scream")
	A.apply_damage(damage = 20, damagetype = BRUTE, def_zone = BODY_ZONE_HEAD, blocked = 0, sharp = TRUE, edge = FALSE, updating_health = TRUE)
	A.ParalyzeNoChain(0.5 SECONDS)
	A.blur_eyes(1)
	X.gain_plasma(X.xeno_caste.drain_plasma_gain)
	succeed_activate()
	add_cooldown()

#define REJUVENATE_ALLY "rejuvenate_ally_cooldown"

// ***************************************
// *********** Rejuvenate/Transfusion
// ***************************************
/datum/action/xeno_action/activable/rejuvenate
	name = "Rejuvenate/Transfusion"
	action_icon_state = "rejuvenation"
	mechanics_text = "When used on self, drains blood and restores health over time. When used on another xenomorph, costs blood and restores some of their health. When used on a dead human, you heal gradually."
	cooldown_timer = 20 SECONDS
	plasma_cost = 0
	use_state_flags = XACT_TARGET_SELF
	target_flags = XABB_MOB_TARGET

/datum/action/xeno_action/activable/rejuvenate/can_use_ability(atom/target, silent = FALSE, override_flags) //it is set up to only return true on specific xeno or human targets
	. = ..()
	if(owner.do_actions)
		return FALSE

	if(ishuman(target) && !issynth(target))
		var/mob/living/carbon/human/H = target
		if(H.stat != DEAD || !HAS_TRAIT(H, TRAIT_UNDEFIBBABLE))
			if(!silent)
				to_chat(owner, span_notice("We can only use still, fully dead hosts to heal."))
			return FALSE
		if(H.blood_volume < GORGER_REJUVENATE_BLOOD_DRAIN)
			if(!silent)
				to_chat(owner, span_notice("Our meal has no blood... How sad!"))
			return FALSE
		if(!owner.Adjacent(target))
			if(!silent)
				to_chat(owner, span_notice("We need to be next to our meal."))
			return FALSE
		return TRUE

	if(!isxeno(target))
		if(!silent)
			to_chat(owner, span_notice("We can only drain or restore familiar biological lifeforms."))
		return FALSE

	var/mob/living/carbon/xenomorph/X = owner
	if(X != target)
		if(TIMER_COOLDOWN_CHECK(X, REJUVENATE_ALLY))
			if(!silent)
				to_chat(X, span_notice("We need [GORGER_REJUVENATE_SELF_COST - X.plasma_stored]u more blood to revitalize ourselves."))
			return FALSE
		if(!X.line_of_sight(target) || get_dist(X, target) > 2)
			if(!silent)
				to_chat(X, span_notice("It is beyond our reach, we must be close and our way must be clear."))
			return FALSE
		if(X.plasma_stored < GORGER_REJUVENATE_ALLY_COST)
			if(!silent)
				to_chat(X, span_notice("We need [GORGER_REJUVENATE_ALLY_COST - X.plasma_stored]u more blood to restore a sister."))
			return FALSE
		if(isdead(target))
			if(!silent)
				to_chat(X, span_notice("We can only help living sisters."))
			return FALSE
		if(!do_mob(X, target, 1 SECONDS, BUSY_ICON_FRIENDLY, BUSY_ICON_MEDICAL))
			return FALSE
		return TRUE

/datum/action/xeno_action/activable/rejuvenate/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner
	if(ishuman(A))
		var/mob/living/carbon/human/target = A
		while(target.blood_volume > GORGER_REJUVENATE_BLOOD_DRAIN && X.health < X.maxHealth && do_after(X, 2 SECONDS, TRUE, A, BUSY_ICON_HOSTILE))
			X.heal_wounds(2.2, TRUE)
			X.adjust_sunder(-1.5)
			target.blood_volume -= GORGER_REJUVENATE_BLOOD_DRAIN
		to_chat(X, span_notice("We feel fully restored."))
	else if(A == X)
		X.use_plasma(GORGER_REJUVENATE_SELF_COST)
		X.apply_status_effect(/datum/status_effect/xeno_rejuvenate, GORGER_REJUVENATE_SELF_DURATION)
		to_chat(X, span_notice("We tap into our reserves for nourishment."))
		add_cooldown()
	else
		X.use_plasma(GORGER_REJUVENATE_ALLY_COST)
		TIMER_COOLDOWN_START(X, REJUVENATE_ALLY, GORGER_REJUVENATE_ALLY_COOLDOWN)
		var/mob/living/carbon/xenomorph/target_xeno = A
		target_xeno.adjustBruteLoss(-target_xeno.maxHealth*0.3)
		target_xeno.adjustFireLoss(-target_xeno.maxHealth*0.3)
	succeed_activate()

#undef REJUVENATE_ALLY

// ***************************************
// *********** Carnage
// ***************************************
/datum/action/xeno_action/activable/carnage
	name = "Carnage"
	action_icon_state = "carnage"
	mechanics_text = "For a while your attacks drain blood and heal you. During Feast you also heal nearby allies."
	cooldown_timer = 40 SECONDS
	plasma_cost = 0

/datum/action/xeno_action/activable/carnage/use_ability()
	var/mob/living/carbon/xenomorph/X = owner
	X.apply_status_effect(/datum/status_effect/xeno_carnage, 20 SECONDS, X.xeno_caste.carnage_plasma_gain)
	succeed_activate()
	add_cooldown()

// ***************************************
// *********** Feast
// ***************************************

/datum/action/xeno_action/activable/feast
	name = "Feast"
	action_icon_state = "feast"
	mechanics_text = "Use a large amount of blood to get into a state of rejuvenation. During this time you use a small amount of blood and heal. You can cancel this early."
	cooldown_timer = 180 SECONDS
	plasma_cost = 100
	///Adds a cooldown to deactivation to avoid accidental cancel
	COOLDOWN_DECLARE(misclick_prevention)

/datum/action/xeno_action/activable/feast/can_use_ability(atom/target, silent, override_flags)
	. = ..()
	var/mob/living/carbon/xenomorph/X = owner

	if(!COOLDOWN_CHECK(src, misclick_prevention))
		return FALSE
	if(X.has_status_effect(STATUS_EFFECT_XENO_FEAST))
		return TRUE

/datum/action/xeno_action/activable/feast/use_ability()
	var/mob/living/carbon/xenomorph/X = owner
	if(X.has_status_effect(STATUS_EFFECT_XENO_FEAST))
		to_chat(X, span_notice("We decide to end our feast early..."))
		X.remove_status_effect(STATUS_EFFECT_XENO_FEAST)
		return

	X.emote("roar")
	X.visible_message(X, span_notice("[X] begins to overflow with vitality!"))
	X.apply_status_effect(/datum/status_effect/xeno_feast, GORGER_FEAST_DURATION, X.xeno_caste.feast_plasma_drain)
	COOLDOWN_START(src, misclick_prevention, 2 SECONDS)
	succeed_activate()
	add_cooldown()

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

/datum/action/xeno_action/activable/devour/can_use_ability(atom/A, silent, override_flags)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/xenomorph/X = owner
	if(X.eaten_mob)
		return TRUE
	if(!ishuman(A) || issynth(A))
		if(!silent)
			to_chat(owner, span_warning("That wouldn't taste very good."))
		return FALSE
	var/mob/living/carbon/human/victim = A
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
	if(X.on_fire)
		if(!silent)
			to_chat(X, span_warning("We're too busy being on fire to do this!"))
		return FALSE
	for(var/obj/effect/forcefield/fog in range(1, X))
		if(!silent)
			to_chat(X, span_warning("We are too close to the fog."))
		return FALSE

/datum/action/xeno_action/activable/devour/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner
	if(X.eaten_mob)
		var/channel = SSsounds.random_available_channel()
		playsound(X, 'sound/vore/escape.ogg', 40, channel = channel)
		if(!do_after(X, 3 SECONDS, FALSE, null, BUSY_ICON_DANGER))
			to_chat(owner, span_warning("We moved too soon!"))
			X.stop_sound_channel(channel)
			return
		X.eject_victim()
		return

	var/mob/living/carbon/human/victim = A
	X.face_atom(victim)
	X.visible_message(span_danger("[X] starts to devour [victim]!"), span_danger("We start to devour [victim]!"), null, 5)
	succeed_activate()
	var/channel = SSsounds.random_available_channel()
	playsound(X, 'sound/vore/struggle.ogg', 40, channel = channel)
	if(!do_after(X, 7 SECONDS, FALSE, victim, BUSY_ICON_DANGER, extra_checks = CALLBACK(owner, /mob.proc/break_do_after_checks, list("health" = X.health))))
		to_chat(owner, span_warning("We stop devouring \the [victim]. They probably tasted gross anyways."))
		X.stop_sound_channel(channel)
		return
	owner.visible_message(span_warning("[X] devours [victim]!"), span_warning("We devour [victim]!"), null, 5)
	victim.forceMove(X)
	X.eaten_mob = victim
	add_cooldown()
