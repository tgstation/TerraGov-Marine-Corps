/datum/status_effect/stacking/stimulant
	tick_interval = 2 SECONDS
	alert_type = null
	delay_before_decay = 30 SECONDS
	max_stacks = 100
	stack_threshold = 50

// ***************************************
// *********** Drop
// ***************************************
/datum/status_effect/stacking/stimulant/drop
	id = "drop stimulant"

/datum/status_effect/stacking/stimulant/drop/on_apply()
	if(!iscarbon(owner))
		return FALSE
	var/mob/living/carbon/carbon_owner = owner
	carbon_owner.adjust_mob_accuracy(20)
	carbon_owner.adjust_mob_scatter(-5)

	carbon_owner.overlay_fullscreen("drop", /atom/movable/screen/fullscreen/stimulant/drop)

	return TRUE

/datum/status_effect/stacking/stimulant/drop/on_remove()
	if(!iscarbon(owner))
		return FALSE
	var/mob/living/carbon/carbon_owner = owner
	carbon_owner.adjust_mob_accuracy(-20)
	carbon_owner.adjust_mob_scatter(5)

	carbon_owner.clear_fullscreen("drop")
	owner.balloon_alert(owner, "You feel the world turn grey")

	return ..()

/datum/status_effect/stacking/stimulant/drop/tick()
	if(!iscarbon(owner))
		return FALSE
	var/mob/living/carbon/carbon_owner = owner
	if(carbon_owner.traumatic_shock * 1.3 > carbon_owner.shock_stage)
		carbon_owner.adjustShock_Stage(carbon_owner.traumatic_shock * 1.3)

	if(prob(7))
		carbon_owner.emote(pick("twitch","drool"))
	return ..()

// ***************************************
// *********** Exile
// ***************************************
/datum/status_effect/stacking/stimulant/exile
	id = "exile stimulant"

/datum/status_effect/stacking/stimulant/exile/on_apply()
	if(!iscarbon(owner))
		return FALSE
	var/mob/living/carbon/carbon_owner = owner
	ADD_TRAIT(carbon_owner, TRAIT_PAIN_IMMUNE, "exile stimulant")
	carbon_owner.health_threshold_crit -=35
	carbon_owner.adjust_mob_accuracy(15)
	carbon_owner.adjust_mob_scatter(3)

	carbon_owner.overlay_fullscreen("exile", /atom/movable/screen/fullscreen/bloodlust)

	return TRUE

/datum/status_effect/stacking/stimulant/exile/on_remove()
	if(!iscarbon(owner))
		return FALSE
	var/mob/living/carbon/carbon_owner = owner
	REMOVE_TRAIT(carbon_owner, TRAIT_PAIN_IMMUNE, "exile stimulant")
	carbon_owner.health_threshold_crit +=35
	carbon_owner.adjust_mob_accuracy(-15)
	carbon_owner.adjust_mob_scatter(-3)

	carbon_owner.clear_fullscreen("exile")
	owner.balloon_alert(owner, "You feel the rage fade")

	return ..()

/datum/status_effect/stacking/stimulant/exile/tick()
	if(!iscarbon(owner))
		return FALSE
	var/mob/living/carbon/carbon_owner = owner
	carbon_owner.adjustStaminaLoss(-5)
	carbon_owner.jitter(3)

	if(prob(10))
		carbon_owner.emote("gasp")
		carbon_owner.Losebreath(3)
		carbon_owner.adjustBrainLoss(1)
	else if(prob(7))
		carbon_owner.emote(pick("twitch","drool","stare", "scream"))
	return ..()

//temp until I put this somewhere proper

/obj/item/stimulant
	icon = 'icons/obj/items/syringe.dmi'
	icon_state = ""
	var/datum/status_effect/stacking/stimulant/stim_type
	var/stim_stacks = 45
	var/stim_message

/obj/item/stimulant/attack_self(mob/user)
	if(!iscarbon(user))
		return
	var/mob/living/carbon/carbon_user = user
	carbon_user.apply_status_effect(stim_type, stim_stacks)
	carbon_user.balloon_alert(carbon_user, stim_message)
	qdel(src)

/obj/item/stimulant/drop
	name = "drop booster"
	desc = "Drop pushes the user into a heightened state of neural activity, greatly improving hand eye co-ordination but making them more sensitive to pain."
	icon_state = "borghypo"
	stim_type = STATUS_EFFECT_STIMULANT_DROP
	stim_message = "You can suddenly feel everything!"

/obj/item/stimulant/exile
	name = "exile booster"
	desc = "Exile inhibits several key receptors in the brain, triggering a state of extreme aggression and dumbness to pain, allowing the user to continue operating with the most greivous of injuries. Exile does not actually prevent any damage however, and can gradually lead to neural degeneration."
	icon_state = "borghypo"
	stim_type = STATUS_EFFECT_STIMULANT_EXILE
	stim_message = "You feel the urge for violence!"
