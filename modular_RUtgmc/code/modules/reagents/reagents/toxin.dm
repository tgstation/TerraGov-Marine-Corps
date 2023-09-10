/datum/reagent/medicine/xenojelly
	name = "Resin jelly juice"
	description = "Jelly used by xenos to stabilize the hosts."
	color = "#500f4d"
	taste_description = "glue and grape"
	scannable = TRUE
	custom_metabolism = REAGENTS_METABOLISM * 0.5
	effect_str = 2

/datum/reagent/medicine/xenojelly/on_mob_add(mob/living/L, metabolism)
	ADD_TRAIT(L, TRAIT_IGNORE_SUFFOCATION, REAGENT_TRAIT(src))
	L.reagents.remove_all_type(/datum/reagent/medicine/spaceacillin, 30, 1, 1)

/datum/reagent/medicine/xenojelly/on_mob_life(mob/living/L, metabolism)
	var/mob/living/carbon/human/H = L
	L.adjustDrowsyness(6)
	L.reagent_shock_modifier -= PAIN_REDUCTION_MEDIUM
	if(CHECK_BITFIELD(L.restrained_flags, RESTRAINED_XENO_NEST))
		L.reagents.remove_all_type(/datum/reagent/toxin, 3*effect_str, 0, 1)
		if(TIMER_COOLDOWN_CHECK(L, name) || L.stat == DEAD)
			return
		if(L.health < -85)
			to_chat(L, span_userdanger("You feel a weird sensation from the nest jelly!"))
			L.adjustOxyLoss(-L.getOxyLoss())
			L.adjustOxyLoss(-2*effect_str)
			L.adjustBruteLoss(-L.getBruteLoss(TRUE) * 0.40)
			L.adjustFireLoss(-L.getFireLoss(TRUE) * 0.40)
			L.adjustToxLoss(-10)
			TIMER_COOLDOWN_START(L, name, 120 SECONDS)
		if(L.health <= 0)
			L.adjustOxyLoss(-L.getOxyLoss())
			L.adjustOxyLoss(-2*effect_str)
			L.heal_limb_damage(2*effect_str, 2*effect_str)
			L.adjustToxLoss(-5)
		if(L.health < 20 && L.health > 0)
			L.adjustOxyLoss(-2*effect_str)
			L.heal_limb_damage(0.5, 0.5)
			L.adjustToxLoss(-2)
		for(var/datum/limb/X in H.limbs)
			for(var/datum/wound/internal_bleeding/W in X.wounds)
				W.damage = max(0, W.damage - (effect_str))
	else
		if(L.health < 20)
			L.adjustOxyLoss(-1*effect_str)
			L.heal_limb_damage(0.25, 0.25)
			L.adjustToxLoss(-1)
	return ..()

/datum/reagent/medicine/xenojelly/on_mob_delete(mob/living/L, metabolism)
	REMOVE_TRAIT(L, TRAIT_IGNORE_SUFFOCATION, REAGENT_TRAIT(src))
	return ..()
