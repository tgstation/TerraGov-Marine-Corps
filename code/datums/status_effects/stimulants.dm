/datum/status_effect/stacking/stimulant
	tick_interval = 2 SECONDS
	alert_type = null
	max_stacks = 150
	stack_threshold = 70

// ***************************************
// *********** Drop
// ***************************************
/datum/status_effect/stacking/stimulant/drop
	id = "drop stimulant"

/datum/status_effect/stacking/stimulant/drop/on_apply()
	if(!ishuman(owner))
		return FALSE
	var/mob/living/carbon/human/human_owner = owner
	human_owner.adjust_mob_accuracy(20)
	human_owner.adjust_mob_scatter(-5)

	human_owner.overlay_fullscreen("drop", /atom/movable/screen/fullscreen/stimulant/drop)

	return TRUE

/datum/status_effect/stacking/stimulant/drop/on_remove()
	if(!ishuman(owner))
		return FALSE
	var/mob/living/carbon/human/human_owner = owner
	human_owner.adjust_mob_accuracy(-20)
	human_owner.adjust_mob_scatter(5)

	human_owner.clear_fullscreen("drop")
	owner.balloon_alert(owner, "You feel the world turn grey")

	return ..()

/datum/status_effect/stacking/stimulant/drop/tick()
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

	return ..()

// ***************************************
// *********** Exile
// ***************************************
/datum/status_effect/stacking/stimulant/exile
	id = "exile stimulant"

/datum/status_effect/stacking/stimulant/exile/on_apply()
	if(!ishuman(owner))
		return FALSE
	var/mob/living/carbon/human/human_owner = owner
	ADD_TRAIT(human_owner, TRAIT_PAIN_IMMUNE, "exile stimulant")
	human_owner.health_threshold_crit -=35
	human_owner.adjust_mob_accuracy(15)
	human_owner.adjust_mob_scatter(3)

	human_owner.overlay_fullscreen("exile", /atom/movable/screen/fullscreen/bloodlust)

	return TRUE

/datum/status_effect/stacking/stimulant/exile/on_remove()
	if(!ishuman(owner))
		return FALSE
	var/mob/living/carbon/human/human_owner = owner
	REMOVE_TRAIT(human_owner, TRAIT_PAIN_IMMUNE, "exile stimulant")
	human_owner.health_threshold_crit +=35
	human_owner.adjust_mob_accuracy(-15)
	human_owner.adjust_mob_scatter(-3)

	human_owner.clear_fullscreen("exile")
	owner.balloon_alert(owner, "You feel the rage fade")

	return ..()

/datum/status_effect/stacking/stimulant/exile/tick()
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

	return ..()

// ***************************************
// *********** Crash
// ***************************************
/datum/status_effect/stacking/stimulant/crash
	id = "crash stimulant"

/datum/status_effect/stacking/stimulant/crash/on_apply()
	if(!ishuman(owner))
		return FALSE

	var/mob/living/carbon/human/human_owner = owner
	human_owner.add_movespeed_modifier(MOVESPEED_ID_CRASH_STIM, TRUE, 0, NONE, TRUE, -0.5)
	human_owner.adjust_mob_accuracy(20)
	human_owner.adjust_mob_scatter(6)

	human_owner.overlay_fullscreen("crash", /atom/movable/screen/fullscreen/stimulant/crash)

	return TRUE

/datum/status_effect/stacking/stimulant/crash/on_remove()
	if(!ishuman(owner))
		return FALSE
	var/mob/living/carbon/human/human_owner = owner
	human_owner.remove_movespeed_modifier(MOVESPEED_ID_CRASH_STIM)
	human_owner.adjust_mob_accuracy(-20)
	human_owner.adjust_mob_scatter(-6)

	human_owner.clear_fullscreen("crash")
	owner.balloon_alert(owner, "The world slows down")

	return ..()

/datum/status_effect/stacking/stimulant/crash/tick()
	if(!ishuman(owner))
		return FALSE
	if(owner.stat == DEAD)
		return FALSE

	var/mob/living/carbon/human/human_owner = owner
	if(human_owner.getStaminaLoss() > -10)
		var/datum/internal_organ/heart/heart = human_owner.internal_organs_by_name["heart"]
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

	return ..()


//temp until I put this somewhere proper

/obj/item/stimulant
	icon = 'icons/obj/items/syringe.dmi'
	icon_state = ""
	var/datum/status_effect/stacking/stimulant/stim_type
	var/stim_stacks = 60
	var/stim_message

/obj/item/stimulant/attack_self(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/carbon_user = user
	carbon_user.apply_status_effect(stim_type, stim_stacks)
	carbon_user.balloon_alert(carbon_user, stim_message)
	qdel(src)

/obj/item/stimulant/drop
	name = "drop booster"
	desc = "Drop pushes the user into a heightened state of neural activity, greatly improving hand eye co-ordination but making them more sensitive to pain. Also known to cause severe paranoia and hallucinations, at higher doses."
	icon_state = "drop"
	stim_type = STATUS_EFFECT_STIMULANT_DROP
	stim_message = "You can suddenly feel everything!"

/obj/item/stimulant/exile
	name = "exile booster"
	desc = "Exile inhibits several key receptors in the brain, triggering a state of extreme aggression and dumbness to pain, allowing the user to continue operating with the most greivous of injuries. Exile does not actually prevent any damage however, and can gradually lead to neural degeneration."
	icon_state = "exile"
	stim_type = STATUS_EFFECT_STIMULANT_EXILE
	stim_message = "You feel the urge for violence!"

/obj/item/stimulant/crash
	name = "crash booster"
	desc = "Crash hyperstimulates the users nervous system and triggers a rapid metabolic acceleration. This serves to boost the users agility, although it also makes user notoriously twitchy, and can strain the heart."
	icon_state = "crash"
	stim_type = STATUS_EFFECT_STIMULANT_CRASH
	stim_message = "You feel the need for speed!"
