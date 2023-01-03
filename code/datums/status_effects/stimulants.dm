/datum/status_effect/stimulant
	tick_interval = 2 SECONDS


	status_type = STATUS_EFFECT_UNIQUE //How many of the effect can be on one mob, and what happens when you try to add another
	examine_text //If defined, this text will appear when the mob is examined - to use he, she etc. use "SUBJECTPRONOUN" and replace it in the examines themselves
	alert_type = /atom/movable/screen/alert/status_effect //the alert thrown by the status effect, contains name and description
	linked_alert = null //the alert itself, if it exists

// ***************************************
// *********** Drop
// ***************************************
/datum/status_effect/stimulant/drop
	id = "drop stimulant"

/datum/status_effect/stimulant/drop/on_apply()
	if(!ishuman(owner))
		return FALSE
	var/mob/living/carbon/human/human_owner = owner
	human_owner.adjust_mob_accuracy(20)
	human_owner.adjust_mob_scatter(-5)

	human_owner.overlay_fullscreen("drop", /atom/movable/screen/fullscreen/stimulant/drop)

	return TRUE

/datum/status_effect/stimulant/drop/on_remove()
	if(!ishuman(owner))
		return FALSE
	var/mob/living/carbon/human/human_owner = owner
	human_owner.adjust_mob_accuracy(-20)
	human_owner.adjust_mob_scatter(5)

	human_owner.clear_fullscreen("drop")
	owner.balloon_alert(owner, "You feel the world turn grey")

/datum/status_effect/stimulant/drop/tick()
	if(!ishuman(owner))
		return FALSE
	if(owner.stat == DEAD)
		return FALSE

	var/mob/living/carbon/human/human_owner = owner
	if(human_owner.traumatic_shock * 1.3 > human_owner.shock_stage)
		human_owner.adjustShock_Stage(human_owner.traumatic_shock * 1.3)

	if(prob(7))
		human_owner.emote(pick("twitch","drool"))

	if(human_owner.has_status_effect(STATUS_EFFECT_STIMULANT_CRASH))
		human_owner.adjustShock_Stage(200)
		if(prob(10))
			owner.balloon_alert(owner, "Your body burns!")
	if(human_owner.has_status_effect(STATUS_EFFECT_STIMULANT_EXILE))
		human_owner.hallucination += 10
		human_owner.adjustStaminaLoss(6)
		if(prob(10))
			owner.balloon_alert(owner, "Everything spins!")

// ***************************************
// *********** Exile
// ***************************************
/datum/status_effect/stimulant/exile
	id = "exile stimulant"

/datum/status_effect/stimulant/exile/on_apply()
	if(!ishuman(owner))
		return FALSE
	var/mob/living/carbon/human/human_owner = owner
	ADD_TRAIT(human_owner, TRAIT_PAIN_IMMUNE, "exile stimulant")
	human_owner.health_threshold_crit -=35
	human_owner.adjust_mob_accuracy(15)
	human_owner.adjust_mob_scatter(3)

	human_owner.overlay_fullscreen("exile", /atom/movable/screen/fullscreen/bloodlust)

	return TRUE

/datum/status_effect/stimulant/exile/on_remove()
	if(!ishuman(owner))
		return FALSE
	var/mob/living/carbon/human/human_owner = owner
	REMOVE_TRAIT(human_owner, TRAIT_PAIN_IMMUNE, "exile stimulant")
	human_owner.health_threshold_crit +=35
	human_owner.adjust_mob_accuracy(-15)
	human_owner.adjust_mob_scatter(-3)

	human_owner.clear_fullscreen("exile")
	owner.balloon_alert(owner, "You feel the rage fade")

/datum/status_effect/stimulant/exile/tick()
	if(!ishuman(owner))
		return FALSE
	if(owner.stat == DEAD)
		return FALSE

	var/mob/living/carbon/human/human_owner = owner
	human_owner.adjustStaminaLoss(-5)
	human_owner.jitter(3)

	if(prob(10))
		human_owner.emote("gasp")
		human_owner.Losebreath(3)
		human_owner.adjustBrainLoss(1)
	else if(prob(7))
		human_owner.emote(pick("twitch","drool","stare", "scream"))

	if(human_owner.has_status_effect(STATUS_EFFECT_STIMULANT_DROP))
		human_owner.adjustBrainLoss(2)
		human_owner.adjustStaminaLoss(3)
		if(prob(10))
			owner.balloon_alert(owner, "Your mind burns!")
	if(human_owner.has_status_effect(STATUS_EFFECT_STIMULANT_CRASH))
		human_owner.Losebreath(3)
		human_owner.adjustOxyLoss(2)
		human_owner.adjustToxLoss(3)
		if(prob(10))
			owner.balloon_alert(owner, "You can't breathe!")

// ***************************************
// *********** Crash
// ***************************************
/datum/status_effect/stimulant/crash
	id = "crash stimulant"

/datum/status_effect/stimulant/crash/on_apply()
	if(!ishuman(owner))
		return FALSE

	var/mob/living/carbon/human/human_owner = owner
	human_owner.add_movespeed_modifier(MOVESPEED_ID_CRASH_STIM, TRUE, 0, NONE, TRUE, -0.5)
	human_owner.adjust_mob_accuracy(20)
	human_owner.adjust_mob_scatter(6)

	human_owner.overlay_fullscreen("crash", /atom/movable/screen/fullscreen/stimulant/crash)

	return TRUE

/datum/status_effect/stimulant/crash/on_remove()
	if(!ishuman(owner))
		return FALSE
	var/mob/living/carbon/human/human_owner = owner
	human_owner.remove_movespeed_modifier(MOVESPEED_ID_CRASH_STIM)
	human_owner.adjust_mob_accuracy(-20)
	human_owner.adjust_mob_scatter(-6)

	human_owner.clear_fullscreen("crash")
	owner.balloon_alert(owner, "The world slows down")

/datum/status_effect/stimulant/crash/tick()
	if(!ishuman(owner))
		return FALSE
	if(owner.stat == DEAD)
		return FALSE

	var/mob/living/carbon/human/human_owner = owner
	var/datum/internal_organ/heart/heart = human_owner.internal_organs_by_name["heart"]
	if(human_owner.getStaminaLoss() > -10)
		if(heart)
			heart.take_damage(4)
			human_owner.emote("gasp")
			human_owner.Losebreath(2)

	human_owner.adjust_nutrition(-HUNGER_FACTOR)
	human_owner.adjustStaminaLoss(-3)
	human_owner.jitter(5)

	if(prob(15))
		human_owner.emote(pick("twitch","giggle"))

	if(human_owner.has_status_effect(STATUS_EFFECT_STIMULANT_DROP))
		human_owner.adjustBruteLoss(3)
		human_owner.adjustStaminaLoss(3)
		if(prob(10))
			owner.balloon_alert(owner, "You body churns!")
	if(human_owner.has_status_effect(STATUS_EFFECT_STIMULANT_EXILE))
		human_owner.adjust_bodytemperature(30, 0, 500)
		heart.take_damage(2)
		if(prob(10))
			owner.balloon_alert(owner, "Your heart is pounding!")
