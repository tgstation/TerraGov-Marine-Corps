// ***************************************
// *********** Drain blood
// ***************************************
/datum/action/xeno_action/activable/drain
	name = "Drain"
	action_icon_state = "drain"
	mechanics_text = "Hold a marine and drain some of their blood if successful."
	ability_name = "drain"
	cooldown_timer = 15 SECONDS
	plasma_cost = 0

/datum/action/xeno_action/activable/drain/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return
	if(!iscarbon(A))
		return FALSE
	if(!A.can_sting())
		to_chat(owner, span_xenowarning("This won't do!"))
		return FALSE
	var/mob/living/carbon/xenomorph/X = owner
	if(X.plasma_stored >= X.xeno_caste.plasma_max)
		to_chat(X, span_xenowarning("No need, we feel sated for now..."))
		return FALSE
	if(get_dist(X, A) > 1)
		to_chat(X, span_xenowarning("It is outside of our reach! We need to be closer!"))
		return FALSE
	return TRUE

/datum/action/xeno_action/activable/drain/use_ability(mob/living/carbon/A)
	var/mob/living/carbon/xenomorph/X = owner
	X.do_attack_animation(A, ATTACK_EFFECT_GRAB)
	X.emote("roar")
	A.drop_all_held_items()
	X.visible_message(A, span_danger("The [X] grabs [A]!"))
	A.SetImmobilized(2 SECONDS)
	if(!do_after(X, 2 SECONDS, TRUE, A, BUSY_ICON_HOSTILE, ignore_turf_checks = FALSE))
		to_chat(X, span_xenowarning("Our meal is interrupted!"))
		succeed_activate()
		add_cooldown()
		return
	X.do_attack_animation(A, ATTACK_EFFECT_REDSTAB)
	A.emote("scream")
	A.drop_all_held_items()
	X.visible_message(A, span_danger("The [X] stabs its tail into [A]!"))
	A.apply_damage(damage = 20, damagetype = BRUTE, def_zone = BODY_ZONE_HEAD, blocked = 0, sharp = TRUE, edge = FALSE, updating_health = TRUE)
	playsound(A, "alien_claw_flesh", 25, TRUE)
	X.gain_plasma(X.xeno_caste.drain_plasma_gain)
	succeed_activate()
	add_cooldown()

// ***************************************
// *********** Rejuvenate/Transfusion
// ***************************************
/datum/action/xeno_action/activable/rejuvenate
	name = "Rejuvenate/Transfusion"
	action_icon_state = "Rejuvenate"
	mechanics_text = "When used on self, drains blood and restores health over time. When used on another xenomorph, costs blood and restores some of their health. When used on a dead human, you heal gradually."
	ability_name = "rejuvenate"
	cooldown_timer = 2 SECONDS
	plasma_cost = 0
	use_state_flags = XACT_TARGET_SELF
	///Cost of using ability on an ally
	var/ally_plasma_cost = 20
	///Cost of using ability on self
	var/self_plasma_cost = 200
	///Duration of rejuvenation buff on self
	var/self_rejuvenation_duration = 5 SECONDS

/datum/action/xeno_action/activable/rejuvenate/can_use_ability(atom/target, silent = FALSE, override_flags) //it is set up to only return true on specific xeno or human targets
	. = ..()
	if(!.)
		return
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(H.stat != DEAD)
			to_chat(owner, span_notice("We can only use still, dead hosts to heal."))
			return FALSE
		else if(get_dist(owner, H) > 1)
			to_chat(owner, span_notice("We need to be next to our meal."))
			return FALSE
		return TRUE
	if(isxeno(target))
		var/mob/living/carbon/xenomorph/gorger/X = owner
		if(X == target)
			if(!COOLDOWN_CHECK(X, rejuvenate_self_cooldown))
				to_chat(X, span_notice("We need another [round(COOLDOWN_TIMELEFT(X, rejuvenate_self_cooldown) / 10)] seconds before we can revitalize ourselves."))
				return FALSE
			if(X.plasma_stored < self_plasma_cost)
				to_chat(X, span_notice("We need [self_plasma_cost - X.plasma_stored]u more blood to revitalize ourselves."))
				return FALSE
		else
			if(!X.line_of_sight(target) || get_dist(X, target) > 2)
				to_chat(X, span_notice("It is beyond our reach, we must be close and our way clear."))
				return FALSE
			if(X.plasma_stored < ally_plasma_cost)
				to_chat(X, span_notice("We need [ally_plasma_cost - X.plasma_stored]u more blood to restore a sister."))
				return FALSE
			if(isdead(target))
				to_chat(X, span_notice("We can only help living sisters."))
				return FALSE
			if(!do_mob(X, target, 1 SECONDS, BUSY_ICON_FRIENDLY, BUSY_ICON_MEDICAL))
				return FALSE
		return TRUE
	to_chat(owner, span_notice("We can only drain or restore familiar biological lifeforms."))
	return FALSE

/datum/action/xeno_action/activable/rejuvenate/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner
	if(ishuman(A))
		var/mob/living/carbon/human/target = A
		while(X.health < X.maxHealth && do_after(X, 2 SECONDS, TRUE, A, BUSY_ICON_HOSTILE))
			X.heal_wounds(1.1, TRUE)
			X.adjust_sunder(-1.5)
			target.blood_volume -= 2
		to_chat(X, span_notice("We feel fully restored."))
	else if(A == X)
		X.use_plasma(self_plasma_cost)
		X.apply_status_effect(/datum/status_effect/xeno_rejuvenate, self_rejuvenation_duration)
		COOLDOWN_START(X, rejuvenate_self_cooldown, 20 SECONDS)
		to_chat(X, span_notice("We tap into our reserves for nourishment."))
	else
		X.use_plasma(ally_plasma_cost)
		var/mob/living/carbon/xenomorph/target_xeno = A
		target_xeno.adjustBruteLoss(-target_xeno.maxHealth*0.3)
		target_xeno.adjustFireLoss(-target_xeno.maxHealth*0.3)
	succeed_activate()
	add_cooldown()

// ***************************************
// *********** Carnage
// ***************************************
/datum/action/xeno_action/activable/carnage
	name = "Carnage"
	action_icon_state = "Carnage"
	mechanics_text = "For a while your attacks drain blood and heal you. During Feast you also heal nearby allies."
	ability_name = "carnage"
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
	action_icon_state = "Feast"
	mechanics_text = "Use a large amount of blood to get into a state of rejuvenation. During this time you use a small amount of blood and heal. You can cancel this early."
	ability_name = "feast"
	cooldown_timer = 180 SECONDS
	plasma_cost = 100

/datum/action/xeno_action/activable/feast/can_use_ability(atom/target, silent, override_flags)
	. = ..()
	var/mob/living/carbon/xenomorph/X = owner
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
	X.apply_status_effect(/datum/status_effect/xeno_feast, 200 SECONDS, X.xeno_caste.feast_plasma_drain)
	succeed_activate()
	add_cooldown()
