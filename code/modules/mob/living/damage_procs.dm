/mob/living/get_soft_armor(armor_type, proj_def_zone)
	return soft_armor.getRating(armor_type)

/mob/living/get_hard_armor(armor_type, proj_def_zone)
	return hard_armor.getRating(armor_type)

/*
	apply_damage(a,b,c)
	args
	* Damage - How much damage to take
	* Damage_type - What type of damage to take, brute, burn
	* Def_zone - Where to take the damage if its brute or burn
	* blocked - what type of armor to check on the target. Can be overridden with a specific number
	Returns
	standard 0 if fail
*/
/mob/living/proc/apply_damage(damage = 0, damagetype = BRUTE, def_zone, blocked = 0, sharp = FALSE, edge = FALSE, updating_health = FALSE, penetration)
	if(status_flags & (GODMODE))
		return
	if(isnum(blocked))
		damage -= clamp(damage * (blocked - penetration) * 0.01, 0, damage)
	else
		damage = modify_by_armor(damage, blocked, penetration, def_zone)

	if(!damage) //no damage
		return 0

	switch(damagetype)
		if(BRUTE)
			adjustBruteLoss(damage)
		if(BURN)
			adjustFireLoss(damage)
		if(TOX)
			adjustToxLoss(damage)
		if(OXY)
			adjustOxyLoss(damage)
		if(CLONE)
			adjustCloneLoss(damage)
		if(STAMINA)
			adjustStaminaLoss(damage)
	if(updating_health)
		updatehealth()
	return damage

///Used to apply multiple types of damage to a mob at the same time
/mob/living/proc/apply_damages(brute = 0, burn = 0, tox = 0, oxy = 0, clone = 0, def_zone = null, blocked = 0, sharp = FALSE, edge = FALSE, updating_health = FALSE, penetration)
	if(brute)
		apply_damage(brute, BRUTE, def_zone, blocked, sharp, edge, FALSE, penetration)
	if(burn)
		apply_damage(burn, BURN, def_zone, blocked, sharp, edge, FALSE, penetration)
	if(tox)
		apply_damage(tox, TOX, def_zone, blocked, sharp, edge, FALSE, penetration)
	if(oxy)
		apply_damage(oxy, OXY, def_zone, blocked, sharp, edge, FALSE, penetration)
	if(clone)
		apply_damage(clone, CLONE, def_zone, blocked, sharp, edge, FALSE, penetration)
	if(updating_health)
		updatehealth()
	return TRUE


/**
Apply status effect to mob

Arguments
	*effect: duration or amount of effect
	*effecttype which affect to apply
	*updating_health if we should update health [/mob/living/updatehealth]
*/
/mob/living/proc/apply_effect(effect = 0, effecttype = STUN, updating_health = FALSE)
	if(status_flags & GODMODE)
		return FALSE
	if(effect <= 0)
		return FALSE

	switch(effecttype)
		if(STUN)
			Stun(effect)
		if(WEAKEN)
			Paralyze(effect)
		if(PARALYZE)
			Unconscious(effect)
		if(STAGGER)
			Stagger(effect)
		if(AGONY)
			adjustStaminaLoss(effect)
		if(STUTTER)
			if(status_flags & CANSTUN) // stun is usually associated with stutter
				set_timed_status_effect(effect, /datum/status_effect/speech/stutter, only_if_higher = TRUE)
		if(EYE_BLUR)
			blur_eyes(effect)
		if(DROWSY)
			adjustDrowsyness(effect)
	if(updating_health)
		updatehealth()
	return TRUE

///Applies multiple negative effects to a mob
/mob/living/proc/apply_effects(stun = 0, weaken = 0, paralyze = 0, stagger = 0,stutter = 0, eyeblur = 0, drowsy = 0, agony = 0, updating_health = FALSE)
	if(stun)
		apply_effect(stun, STUN)
	if(weaken)
		apply_effect(weaken, WEAKEN)
	if(paralyze)
		apply_effect(paralyze, PARALYZE)
	if(stagger)
		apply_effect(stagger, STAGGER)
	if(stutter)
		apply_effect(stutter, STUTTER)
	if(eyeblur)
		apply_effect(eyeblur, EYE_BLUR)
	if(drowsy)
		apply_effect(drowsy, DROWSY)
	if(agony)
		apply_effect(agony, AGONY)
	if(updating_health)
		updatehealth()
	return TRUE
