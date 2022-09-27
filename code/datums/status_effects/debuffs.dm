#define TRAIT_STATUS_EFFECT(effect_id) "[effect_id]-trait"
#define BASE_HEAL_RATE -0.0125


//Largely negative status effects go here, even if they have small benificial effects
//STUN EFFECTS
/datum/status_effect/incapacitating
	tick_interval = 0
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null

/datum/status_effect/incapacitating/on_creation(mob/living/new_owner, set_duration)
	if(isnum(set_duration))
		duration = set_duration
	return ..()


//STUN
/datum/status_effect/incapacitating/stun
	id = "stun"

/datum/status_effect/incapacitating/stun/on_apply()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_INCAPACITATED, TRAIT_STATUS_EFFECT(id))
	ADD_TRAIT(owner, TRAIT_IMMOBILE, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/incapacitating/stun/on_remove()
	REMOVE_TRAIT(owner, TRAIT_INCAPACITATED, TRAIT_STATUS_EFFECT(id))
	REMOVE_TRAIT(owner, TRAIT_IMMOBILE, TRAIT_STATUS_EFFECT(id))
	return ..()

//KNOCKDOWN
/datum/status_effect/incapacitating/knockdown
	id = "knockdown"

/datum/status_effect/incapacitating/knockdown/on_apply()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_FLOORED, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/incapacitating/knockdown/on_remove()
	REMOVE_TRAIT(owner, TRAIT_FLOORED, TRAIT_STATUS_EFFECT(id))
	return ..()

//IMMOBILIZED
/datum/status_effect/incapacitating/immobilized
	id = "immobilized"

/datum/status_effect/incapacitating/immobilized/on_apply()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_IMMOBILE, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/incapacitating/immobilized/on_remove()
	REMOVE_TRAIT(owner, TRAIT_IMMOBILE, TRAIT_STATUS_EFFECT(id))
	return ..()

//PARALYZED
/datum/status_effect/incapacitating/paralyzed
	id = "paralyzed"

/datum/status_effect/incapacitating/paralyzed/on_apply()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_INCAPACITATED, TRAIT_STATUS_EFFECT(id))
	ADD_TRAIT(owner, TRAIT_IMMOBILE, TRAIT_STATUS_EFFECT(id))
	ADD_TRAIT(owner, TRAIT_FLOORED, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/incapacitating/paralyzed/on_remove()
	REMOVE_TRAIT(owner, TRAIT_INCAPACITATED, TRAIT_STATUS_EFFECT(id))
	REMOVE_TRAIT(owner, TRAIT_IMMOBILE, TRAIT_STATUS_EFFECT(id))
	REMOVE_TRAIT(owner, TRAIT_FLOORED, TRAIT_STATUS_EFFECT(id))
	return ..()

//UNCONSCIOUS
/datum/status_effect/incapacitating/unconscious
	id = "unconscious"

/datum/status_effect/incapacitating/unconscious/on_apply()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_KNOCKEDOUT, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/incapacitating/unconscious/on_remove()
	REMOVE_TRAIT(owner, TRAIT_KNOCKEDOUT, TRAIT_STATUS_EFFECT(id))
	return ..()

/datum/status_effect/incapacitating/unconscious/tick()
	if(owner.getStaminaLoss())
		owner.adjustStaminaLoss(-0.3) //reduce stamina loss by 0.3 per tick, 6 per 2 seconds

//SLEEPING
/datum/status_effect/incapacitating/sleeping
	id = "sleeping"
	alert_type = /obj/screen/alert/status_effect/asleep
	var/mob/living/carbon/carbon_owner
	var/mob/living/carbon/human/human_owner

/datum/status_effect/incapacitating/sleeping/on_creation(mob/living/new_owner)
	. = ..()
	if(.)
		if(iscarbon(owner)) //to avoid repeated istypes
			carbon_owner = owner
		if(ishuman(owner))
			human_owner = owner

/datum/status_effect/incapacitating/sleeping/Destroy()
	carbon_owner = null
	human_owner = null
	return ..()

/datum/status_effect/incapacitating/sleeping/on_apply()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_KNOCKEDOUT, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/incapacitating/sleeping/on_remove()
	REMOVE_TRAIT(owner, TRAIT_KNOCKEDOUT, TRAIT_STATUS_EFFECT(id))
	return ..()

/datum/status_effect/incapacitating/sleeping/tick()
	if(owner.maxHealth)
		var/health_ratio = owner.health / owner.maxHealth
		var/healing = BASE_HEAL_RATE //set for a base of 0.25 healed per 2-second interval asleep in a bed with covers.
		if((locate(/obj/structure/bed) in owner.loc))
			healing += (2 * BASE_HEAL_RATE)
		else if((locate(/obj/structure/table) in owner.loc))
			healing += BASE_HEAL_RATE
		for(var/obj/item/bedsheet/bedsheet in range(owner.loc,0))
			if(bedsheet.loc != owner.loc) //bedsheets in your backpack/neck don't give you comfort
				continue
			healing += BASE_HEAL_RATE
			break //Only count the first bedsheet
		if(health_ratio > -0.5)
			owner.adjustBruteLoss(healing)
			owner.adjustFireLoss(healing)
			owner.adjustToxLoss(healing * 0.5, TRUE, TRUE)
			owner.adjustStaminaLoss(healing * 100)
			owner.adjustCloneLoss(healing * health_ratio * 0.8)
	if(human_owner && human_owner.drunkenness)
		human_owner.drunkenness *= 0.997 //reduce drunkenness by 0.3% per tick, 6% per 2 seconds
	if(prob(20))
		if(carbon_owner)
			carbon_owner.handle_dreams()
		if(prob(10) && owner.health > owner.health_threshold_crit)
			owner.emote("snore")

/obj/screen/alert/status_effect/asleep
	name = "Asleep"
	desc = "You've fallen asleep. Wait a bit and you should wake up. Unless you don't, considering how helpless you are."
	icon_state = "asleep"

//ADMIN SLEEP
/datum/status_effect/incapacitating/adminsleep
	id = "adminsleep"
	alert_type = /obj/screen/alert/status_effect/adminsleep
	duration = -1

/datum/status_effect/incapacitating/adminsleep/on_apply()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_KNOCKEDOUT, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/incapacitating/adminsleep/on_remove()
	REMOVE_TRAIT(owner, TRAIT_KNOCKEDOUT, TRAIT_STATUS_EFFECT(id))
	return ..()

/obj/screen/alert/status_effect/adminsleep
	name = "Admin Slept"
	desc = "You've been slept by an Admin."
	icon_state = "asleep"

//CONFUSED
/datum/status_effect/incapacitating/confused
	id = "confused"
	alert_type = /obj/screen/alert/status_effect/confused

/obj/screen/alert/status_effect/confused
	name = "Confused"
	desc = "You're dazed and confused."
	icon_state = "asleep"

/datum/status_effect/plasmadrain
	id = "plasmadrain"

/datum/status_effect/plasmadrain/on_creation(mob/living/new_owner, set_duration)
	if(isxeno(new_owner))
		owner = new_owner
		duration = set_duration
		return ..()
	else
		CRASH("something applied plasmadrain on a nonxeno, dont do that")

/datum/status_effect/plasmadrain/tick()
	var/mob/living/carbon/xenomorph/xenoowner = owner
	if(xenoowner.plasma_stored >= 0)
		var/remove_plasma_amount = xenoowner.xeno_caste.plasma_max / 10
		xenoowner.plasma_stored -= remove_plasma_amount
		if(xenoowner.plasma_stored <= 0)
			xenoowner.plasma_stored = 0

/datum/status_effect/noplasmaregen
	id = "noplasmaregen"
	tick_interval = 2 SECONDS

/datum/status_effect/noplasmaregen/on_creation(mob/living/new_owner, set_duration)
	if(isxeno(new_owner))
		owner = new_owner
		duration = set_duration
		return ..()
	else
		CRASH("something applied noplasmaregen on a nonxeno, dont do that")

/datum/status_effect/noplasmaregen/on_apply()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_NOPLASMAREGEN, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/noplasmaregen/on_remove()
	REMOVE_TRAIT(owner, TRAIT_NOPLASMAREGEN, TRAIT_STATUS_EFFECT(id))
	return ..()

/datum/status_effect/noplasmaregen/tick()
	to_chat(owner, span_warning("You feel too weak to summon new plasma..."))

/datum/status_effect/incapacitating/harvester_slowdown
	id = "harvest_slow"
	tick_interval = 1 SECONDS
	status_type = STATUS_EFFECT_REPLACE
	var/debuff_slowdown = 2

/datum/status_effect/incapacitating/harvester_slowdown/on_apply()
	. = ..()
	if(!.)
		return
	owner.add_movespeed_modifier(MOVESPEED_ID_HARVEST_TRAM_SLOWDOWN, TRUE, 0, NONE, TRUE, debuff_slowdown)

/datum/status_effect/incapacitating/harvester_slowdown/on_remove()
	owner.remove_movespeed_modifier(MOVESPEED_ID_HARVEST_TRAM_SLOWDOWN)
	return ..()

//MUTE
/datum/status_effect/mute
	id = "mute"
	alert_type = /obj/screen/alert/status_effect/mute

/obj/screen/alert/status_effect/mute
	name = "Muted"
	desc = "You can't speak!"
	icon_state = "mute"

/datum/status_effect/mute/on_creation(mob/living/new_owner, set_duration)
	owner = new_owner
	if(set_duration) //If the duration is limited, set it
		duration = set_duration
	return ..()

/datum/status_effect/mute/on_apply()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_MUTED, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/mute/on_remove()
	REMOVE_TRAIT(owner, TRAIT_MUTED, TRAIT_STATUS_EFFECT(id))
	return ..()

/datum/status_effect/spacefreeze
	id = "spacefreeze"

/datum/status_effect/spacefreeze/on_creation(mob/living/new_owner)
	. = ..()
	to_chat(new_owner, span_danger("The cold vacuum instantly freezes you, maybe this was a bad idea?"))

/datum/status_effect/spacefreeze/tick()
	owner.adjustFireLoss(40)

///irradiated mob
/datum/status_effect/irradiated
	id = "irradiated"
	status_type = STATUS_EFFECT_REFRESH
	tick_interval = 20
	alert_type = /obj/screen/alert/status_effect/irradiated
	///Some effects only apply to carbons
	var/mob/living/carbon/carbon_owner

/datum/status_effect/irradiated/on_creation(mob/living/new_owner, set_duration)
	if(isnum(set_duration))
		duration = set_duration
	. = ..()
	if(.)
		if(iscarbon(owner))
			carbon_owner = owner

/datum/status_effect/irradiated/Destroy()
	carbon_owner = null
	return ..()

/datum/status_effect/irradiated/tick()
	var/mob/living/living_owner = owner
	//Roulette of bad things
	if(prob(15))
		living_owner.adjustCloneLoss(2)
		to_chat(living_owner, span_warning("You feel like you're burning from the inside!"))
	else
		living_owner.adjustToxLoss(3)
	if(prob(15))
		living_owner.adjust_Losebreath(5)
	if(prob(15))
		living_owner.vomit()
	if(carbon_owner && prob(15))
		var/datum/internal_organ/organ = pick(carbon_owner.internal_organs)
		if(organ)
			organ.take_damage(5)

/obj/screen/alert/status_effect/irradiated
	name = "Irradiated"
	desc = "You've been irradiated! The effects of the radiation will continue to harm you until purged from your system."
	icon_state = "radiation"
