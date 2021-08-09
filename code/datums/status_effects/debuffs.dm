#define TRAIT_STATUS_EFFECT(effect_id) "[effect_id]-trait"

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
/datum/status_effect/confused
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
		var/remove_plasma_amount = xenoowner.xeno_caste.plasma_max / 17
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


//HEALING INFUSION buff for Hivelord
/datum/status_effect/healing_infusion
	id = "healing_infusion"
	alert_type = /obj/screen/alert/status_effect/healing_infusion
	//Buff ends whenever we run out of either health or sunder ticks, or time, whichever comes first
	///Health recovery ticks
	var/health_ticks_remaining
	///Sunder recovery ticks
	var/sunder_ticks_remaining

/datum/status_effect/healing_infusion/on_creation(mob/living/new_owner, set_duration = HIVELORD_HEALING_INFUSION_DURATION, stacks_to_apply = HIVELORD_HEALING_INFUSION_TICKS)
	if(!isxeno(new_owner))
		CRASH("something applied [id] on a nonxeno, dont do that")

	duration = set_duration
	owner = new_owner
	health_ticks_remaining = stacks_to_apply //Apply stacks
	sunder_ticks_remaining = stacks_to_apply
	return ..()


/datum/status_effect/healing_infusion/on_apply()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_HEALING_INFUSION, TRAIT_STATUS_EFFECT(id))
	owner.add_filter("hivelord_healing_infusion_outline", 3, outline_filter(1, COLOR_VERY_PALE_LIME_GREEN)) //Set our cool aura; also confirmation we have the buff
	RegisterSignal(owner, COMSIG_XENOMORPH_HEALTH_REGEN, .proc/healing_infusion_regeneration) //Register so we apply the effect whenever the target heals
	RegisterSignal(owner, COMSIG_XENOMORPH_SUNDER_REGEN, .proc/healing_infusion_sunder_regeneration) //Register so we apply the effect whenever the target heals

/datum/status_effect/healing_infusion/on_remove()
	REMOVE_TRAIT(owner, TRAIT_HEALING_INFUSION, TRAIT_STATUS_EFFECT(id))
	owner.remove_filter("hivelord_healing_infusion_outline")
	UnregisterSignal(owner, list(COMSIG_XENOMORPH_HEALTH_REGEN, COMSIG_XENOMORPH_SUNDER_REGEN))

	new /obj/effect/temp_visual/telekinesis(get_turf(owner)) //Wearing off VFX
	new /obj/effect/temp_visual/healing(get_turf(owner))

	owner.balloon_alert(owner, "Regeneration is no longer accelerated")
	owner.playsound_local(owner, 'sound/voice/hiss5.ogg', 25)

	return ..()

///Called when the target xeno regains HP via heal_wounds in life.dm
/datum/status_effect/healing_infusion/proc/healing_infusion_regeneration(mob/living/carbon/xenomorph/patient)
	SIGNAL_HANDLER

	if(!health_ticks_remaining)
		qdel(src)
		return

	health_ticks_remaining-- //Decrement health ticks

	new /obj/effect/temp_visual/healing(get_turf(patient)) //Cool SFX

	var/total_heal_amount = 6 + (patient.maxHealth * 0.03) //Base amount 6 HP plus 3% of max
	if(patient.recovery_aura)
		total_heal_amount *= (1 + patient.recovery_aura * 0.05) //Recovery aura multiplier; 5% bonus per full level

	//Healing pool has been calculated; now to decrement it
	var/brute_amount = min(patient.bruteloss, total_heal_amount)
	if(brute_amount)
		patient.adjustBruteLoss(-brute_amount, updating_health = TRUE)
		total_heal_amount = max(0, total_heal_amount - brute_amount) //Decrement from our heal pool the amount of brute healed

	if(!total_heal_amount) //no healing left, no need to continue
		return

	var/burn_amount = min(patient.fireloss, total_heal_amount)
	if(burn_amount)
		patient.adjustFireLoss(-burn_amount, updating_health = TRUE)


///Called when the target xeno regains Sunder via heal_wounds in life.dm
/datum/status_effect/healing_infusion/proc/healing_infusion_sunder_regeneration(mob/living/carbon/xenomorph/patient)
	SIGNAL_HANDLER

	if(!sunder_ticks_remaining)
		qdel(src)
		return

	if(!locate(/obj/effect/alien/weeds) in patient.loc) //Doesn't work if we're not on weeds
		return

	sunder_ticks_remaining-- //Decrement sunder ticks

	new /obj/effect/temp_visual/telekinesis(get_turf(patient)) //Visual confirmation

	patient.adjust_sunder(-1.8 * (1 + patient.recovery_aura * 0.05)) //5% bonus per rank of our recovery aura


/obj/screen/alert/status_effect/healing_infusion
	name = "Healing Infusion"
	desc = "You have accelerated natural healing."
	icon_state = "healing_infusion"

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

