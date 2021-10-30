// ***************************************
// *********** Drain blood
// ***************************************
/datum/action/xeno_action/activable/drain
	name = "Drain"
	action_icon_state = "drain"
	mechanics_text = "Hold a marine for 2s while draining 2% of their blood."
	ability_name = "drain"
	cooldown_timer = 15 SECONDS
	plasma_cost = 50

/datum/action/xeno_action/activable/drain/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	var/mob/living/carbon/xenomorph/X = owner
	if(!.)
		return
	if(!A.can_sting())
		to_chat(owner, span_warning("This won't do!"))
		return FALSE
	if(X.blood_bank >= 100)
		to_chat(owner, span_warning("No need, we feel sated for now..."))
		return FALSE
	if(get_dist(owner, A) > 1)
		to_chat(owner, span_warning("It is outside of our reach! We need to be closer!"))
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
		to_chat(X, span_warning("Our meal is interrupted!"))
		return
	X.do_attack_animation(A, ATTACK_EFFECT_REDSTAB)
	A.emote("scream")
	A.drop_all_held_items()
	X.visible_message(A, span_danger("The [X] stabs its tail into [A]!"))
	A.apply_damage(damage = 20, damagetype = BRUTE, def_zone = BODY_ZONE_HEAD, blocked = 0, sharp = TRUE, edge = FALSE, updating_health = TRUE)
	playsound(A, "alien_claw_flesh", 25, TRUE)
	A.blood_volume -= 10
	X.blood_bank += min(10, 100 - X.blood_bank)
	to_chat(X, span_notice("Blood bank: [X.blood_bank]%"))
	succeed_activate()
	add_cooldown()

// ***************************************
// *********** Rejuvenate/Transfusion
// ***************************************
/datum/action/xeno_action/activable/rejuvenate
	name = "Rejuvenate/Transfusion"
	action_icon_state = "Rejuvenate"
	mechanics_text = "When used on self, drains 10 blood and restores 40% health over 5s. When used on another xenomorph, restores 30% of their health after 2s. When used on a dead human, you grab them and heal by draining their blood."
	ability_name = "rejuvenate"
	cooldown_timer = 2 SECONDS
	plasma_cost = 0
	use_state_flags = XACT_TARGET_SELF
	COOLDOWN_DECLARE(rejuvenate_self_cooldown)

/datum/action/xeno_action/activable/rejuvenate/can_use_ability(atom/target, silent = FALSE, override_flags) //it is set up to only return true on specific xeno or human targets
	. = ..()
	var/mob/living/carbon/xenomorph/X = owner
	if(!.)
		return
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(H.stat != DEAD)
			to_chat(X, span_notice("We can only use still, dead hosts to heal."))
			return FALSE
		else if(get_dist(X, H) > 1)
			to_chat(X, span_notice("We need to be next to our meal."))
			return FALSE
		return TRUE
	if(isxeno(target))
		if(X == target)
			if(!COOLDOWN_CHECK(X, rejuvenate_self_cooldown))
				to_chat(X, span_notice("We need another [round(COOLDOWN_TIMELEFT(X, rejuvenate_self_cooldown) / 10)] seconds before we can revitalize ourselves."))
				return FALSE
			if(X.blood_bank < 10)
				to_chat(X, span_notice("We need [10 - X.blood_bank]u more blood to revitalize ourselves."))
				return FALSE
		else
			if(!X.line_of_sight(target) || get_dist(X, target) > 2)
				to_chat(X, span_notice("It is beyond our reach, we must be close and our way clear."))
				return FALSE
			if(X.blood_bank < 5)
				to_chat(X, span_notice("We need [5 - X.blood_bank]u more blood to restore a sister."))
				return FALSE
			if(isdead(target))
				to_chat(X, span_notice("We can only help living sisters."))
				return FALSE
		return TRUE
	to_chat(X, span_notice("We can only drain or restore familiar biological lifeforms."))
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
	elese if(A == X)
		var/mob/living/carbon/xenomorph/target = A
		X.blood_bank -= 10
		to_chat(X, span_notice("Blood bank: [X.blood_bank]%"))
		to_chat(X, span_notice("We tap into our reserves for nourishment."))
		target.apply_status_effect(/datum/status_effect/xeno_rejuvenate, 5 SECONDS)
		COOLDOWN_START(src, rejuvenate_self_cooldown, 20 SECONDS)
	else
		var/mob/living/carbon/xenomorph/target = A
		if(!do_mob(X, A, 1 SECONDS, BUSY_ICON_FRIENDLY, BUSY_ICON_MEDICAL))
			return
		if(!X.line_of_sight(target) || get_dist(X, target) > 2)
			to_chat(X, span_notice("Beyond our reach..."))
			return
		target.adjustBruteLoss(-X.maxHealth*0.3)
		target.adjustFireLoss(-X.maxHealth*0.3)
		X.blood_bank -= 5
		to_chat(X, span_notice("Blood bank: [X.blood_bank]%"))
	succeed_activate()
	add_cooldown()

// ***************************************
// *********** Carnage
// ***************************************
/datum/action/xeno_action/activable/carnage
	name = "Carnage"
	action_icon_state = "Carnage"
	mechanics_text = ""
	ability_name = "carnage"
	cooldown_timer = 40 SECONDS
	plasma_cost = 100

/datum/action/xeno_action/activable/carnage/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE

/datum/action/xeno_action/activable/carnage/use_ability()
	var/mob/living/carbon/xenomorph/X = owner
	X.apply_status_effect(/datum/status_effect/xeno_carnage, 20 SECONDS)
	succeed_activate()
	add_cooldown()

// ***************************************
// *********** Feast
// ***************************************

/datum/action/xeno_action/activable/feast
	name = "Feast"
	action_icon_state = "Feast"
	mechanics_text = ""
	ability_name = "feast"
	cooldown_timer = 180 SECONDS
	plasma_cost = 0

/datum/action/xeno_action/activable/feast/can_use_ability(atom/target, silent = FALSE, override_flags)
	. = ..()
	var/mob/living/carbon/xenomorph/X = owner
	if(!.)
		return FALSE
	if(X.blood_bank < 100 && !X.has_status_effect(STATUS_EFFECT_XENO_FEAST))
		to_chat(X, span_notice("We need [100 - X.blood_bank]% more blood to feast."))
		return FALSE
	return TRUE

/datum/action/xeno_action/activable/feast/use_ability()
	var/mob/living/carbon/xenomorph/X = owner
	if(!X.has_status_effect(STATUS_EFFECT_XENO_FEAST))
		X.emote("roar")
		X.visible_message(X, span_notice("The [X] starts to overflow with vitality!"))
		X.apply_status_effect(/datum/status_effect/xeno_feast, 200 SECONDS)
		return
	else
		to_chat(X, span_notice("We decide to end our feast early..."))
		X.remove_status_effect(STATUS_EFFECT_XENO_FEAST)
	succeed_activate()
	add_cooldown()
