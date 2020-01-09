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
	owner.add_immobile_flags(IMMOBILE_STATUSEFFECT_STUN)
	owner.add_hand_block_flags(HANDBLOCK_STATUSEFFECT_STUN)

/datum/status_effect/incapacitating/stun/on_remove()
	owner.remove_immobile_flags(IMMOBILE_STATUSEFFECT_STUN)
	owner.remove_hand_block_flags(HANDBLOCK_STATUSEFFECT_STUN)
	return ..()


//KNOCKDOWN
/datum/status_effect/incapacitating/knockdown
	id = "knockdown"

/datum/status_effect/incapacitating/knockdown/on_apply()
	. = ..()
	if(!.)
		return
	owner.add_lying_flags(LYING_STATUSEFFECT_KNOCKEDDOWN)

/datum/status_effect/incapacitating/knockdown/on_remove()
	owner.remove_lying_flags(LYING_STATUSEFFECT_KNOCKEDDOWN)
	return ..()


//IMMOBILIZED
/datum/status_effect/incapacitating/immobilized
	id = "immobilized"

/datum/status_effect/incapacitating/immobilized/on_apply()
	. = ..()
	if(!.)
		return
	owner.add_immobile_flags(IMMOBILE_STATUSEFFECT_IMMOBILIZED)
	owner.add_pull_block_flags(PULLBLOCK_STATUSEFFECT_IMMOBILIZED)
	owner.add_ui_block_flags(UI_STATUSEFFECT_IMMOBILIZED)

/datum/status_effect/incapacitating/immobilized/on_remove()
	owner.remove_immobile_flags(IMMOBILE_STATUSEFFECT_IMMOBILIZED)
	owner.remove_pull_block_flags(PULLBLOCK_STATUSEFFECT_IMMOBILIZED)
	owner.remove_ui_block_flags(UI_STATUSEFFECT_IMMOBILIZED)
	return ..()


//PARALYZED
/datum/status_effect/incapacitating/paralyzed
	id = "paralyzed"

/datum/status_effect/incapacitating/paralyzed/on_apply()
	. = ..()
	if(!.)
		return
	owner.add_hand_block_flags(HANDBLOCK_STATUSEFFECT_PARALYZED)
	owner.add_immobile_flags(IMMOBILE_STATUSEFFECT_PARALYZED)
	owner.add_lying_flags(LYING_STATUSEFFECT_PARALYZED)

/datum/status_effect/incapacitating/paralyzed/on_remove()
	owner.remove_hand_block_flags(HANDBLOCK_STATUSEFFECT_PARALYZED)
	owner.remove_immobile_flags(IMMOBILE_STATUSEFFECT_PARALYZED)
	owner.remove_lying_flags(LYING_STATUSEFFECT_PARALYZED)
	return ..()


//DISABLEHANDS
/datum/status_effect/incapacitating/disablehands
	id = "disablehands"

/datum/status_effect/incapacitating/disablehands/on_apply()
	. = ..()
	if(!.)
		return
	owner.add_hand_block_flags(HANDBLOCK_STATUSEFFECT_DISABLEHANDS)

/datum/status_effect/incapacitating/disablehands/on_remove()
	owner.remove_hand_block_flags(HANDBLOCK_STATUSEFFECT_DISABLEHANDS)
	return ..()


//WORMED
/datum/status_effect/incapacitating/wormed
	id = "wormed"

/datum/status_effect/incapacitating/wormed/on_apply()
	. = ..()
	if(!.)
		return
	owner.add_hand_block_flags(HANDBLOCK_STATUSEFFECT_WORMED)
	owner.add_lying_flags(LYING_STATUSEFFECT_WORMED)

/datum/status_effect/incapacitating/wormed/on_remove()
	owner.remove_hand_block_flags(HANDBLOCK_STATUSEFFECT_WORMED)
	owner.remove_lying_flags(LYING_STATUSEFFECT_WORMED)
	return ..()


//UNCONSCIOUS
/datum/status_effect/incapacitating/unconscious
	id = "unconscious"

/datum/status_effect/incapacitating/unconscious/on_apply()
	. = ..()
	if(!.)
		return
	owner.add_knockout_flags(KNOCKOUT_STATUSEFFECT_UNCONSCIOUS)

/datum/status_effect/incapacitating/unconscious/on_remove()
	owner.remove_knockout_flags(KNOCKOUT_STATUSEFFECT_UNCONSCIOUS)
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
	owner.add_knockout_flags(KNOCKOUT_STATUSEFFECT_SLEEEPING)

/datum/status_effect/incapacitating/sleeping/on_remove()
	owner.remove_knockout_flags(KNOCKOUT_STATUSEFFECT_SLEEEPING)
	return ..()

/datum/status_effect/incapacitating/sleeping/Destroy()
	carbon_owner = null
	human_owner = null
	return ..()

/datum/status_effect/incapacitating/sleeping/tick()
	if(owner.maxHealth)
		var/health_ratio = owner.health / owner.maxHealth
		var/healing = -0.2
		if((locate(/obj/structure/bed) in owner.loc))
			healing -= 0.3
		else if((locate(/obj/structure/table) in owner.loc))
			healing -= 0.1
		for(var/obj/item/bedsheet/bedsheet in range(owner.loc,0))
			if(bedsheet.loc != owner.loc) //bedsheets in your backpack/neck don't give you comfort
				continue
			healing -= 0.1
			break //Only count the first bedsheet
		if(health_ratio > 0.8)
			owner.adjustBruteLoss(healing)
			owner.adjustFireLoss(healing)
			owner.adjustToxLoss(healing * 0.5, TRUE, TRUE)
		owner.adjustStaminaLoss(healing)
	if(human_owner && human_owner.drunkenness)
		human_owner.drunkenness *= 0.997 //reduce drunkenness by 0.3% per tick, 6% per 2 seconds
	if(prob(20))
		if(carbon_owner)
			carbon_owner.handle_dreams()
		if(prob(10) && owner.stat > owner.health_threshold_hardcrit)
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
	owner.add_knockout_flags(KNOCKOUT_STATUSEFFECT_ADMINSLEEP)

/datum/status_effect/incapacitating/adminsleep/on_remove()
	owner.remove_knockout_flags(KNOCKOUT_STATUSEFFECT_ADMINSLEEP)
	return ..()

/obj/screen/alert/status_effect/adminsleep
	name = "Admin Slept"
	desc = "You've been slept by an Admin."
	icon_state = "asleep"

//CONFUSED
/datum/status_effect/confused
	id = "confused"
	alert_type = /obj/screen/alert/status_effect/confused

/obj/screen/alert/status_effect/confused
	name = "Confused"
	desc = "You're dazed and confused."
	icon_state = "asleep"
