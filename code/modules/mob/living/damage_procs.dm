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
/mob/living/proc/apply_damage(damage = 0, damagetype = BRUTE, def_zone, blocked = 0, sharp = FALSE, edge = FALSE, updating_health = FALSE, penetration, mob/living/attacker)
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
/mob/living/proc/apply_damages(brute = 0, burn = 0, tox = 0, oxy = 0, clone = 0, def_zone = null, blocked = 0, sharp = FALSE, edge = FALSE, updating_health = FALSE, penetration, mob/living/attacker)
	if(brute)
		apply_damage(brute, BRUTE, def_zone, blocked, sharp, edge, FALSE, penetration, attacker)
	if(burn)
		apply_damage(burn, BURN, def_zone, blocked, sharp, edge, FALSE, penetration, attacker)
	if(tox)
		apply_damage(tox, TOX, def_zone, blocked, sharp, edge, FALSE, penetration, attacker)
	if(oxy)
		apply_damage(oxy, OXY, def_zone, blocked, sharp, edge, FALSE, penetration, attacker)
	if(clone)
		apply_damage(clone, CLONE, def_zone, blocked, sharp, edge, FALSE, penetration, attacker)
	if(updating_health)
		updatehealth()
	return TRUE


/**
 * Applies the specified effect
 *
 * Arguments:
 * * effect: the amount of effect, duration for some, amount for others
 * * effect_type: the type of effect to apply
 * * updating_health: should we call the updatehealth proc?
 */
/mob/living/proc/apply_effect(effect = 0, effect_type = EFFECT_STUN, updating_health = FALSE)
	if(status_flags & GODMODE)
		return FALSE
	if(effect <= 0)
		return FALSE

	switch(effect_type)
		if(EFFECT_STUN)
			Stun(effect)
		if(EFFECT_KNOCKDOWN)
			Knockdown(effect)
		if(EFFECT_PARALYZE)
			Paralyze(effect)
		if(EFFECT_UNCONSCIOUS)
			Unconscious(effect)
		if(EFFECT_STAGGER)
			Stagger(effect)
		if(EFFECT_STAMLOSS)
			adjustStaminaLoss(effect)
		if(EFFECT_STUTTER)
			if(status_flags & CANSTUN) // stun is usually associated with stutter
				set_timed_status_effect(effect, /datum/status_effect/speech/stutter, only_if_higher = TRUE)
		if(EFFECT_EYE_BLUR)
			blur_eyes(effect)
		if(EFFECT_DROWSY)
			adjustDrowsyness(effect)
	if(updating_health)
		updatehealth()
	return TRUE

///Applies multiple negative effects to a mob
/mob/living/proc/apply_effects(stun = 0, paralyze = 0, unconscious = 0, stagger = 0, stamloss = 0, stutter = 0, eye_blur = 0, drowsy = 0, updating_health = FALSE)
	if(stun)
		apply_effect(stun, EFFECT_STUN)
	if(paralyze)
		apply_effect(paralyze, EFFECT_PARALYZE)
	if(unconscious)
		apply_effect(unconscious, EFFECT_UNCONSCIOUS)
	if(stagger)
		apply_effect(stagger, EFFECT_STAGGER)
	if(stamloss)
		apply_effect(stamloss, EFFECT_STAMLOSS)
	if(stutter)
		apply_effect(stutter, EFFECT_STAMLOSS)
	if(eye_blur)
		apply_effect(eye_blur, EFFECT_EYE_BLUR)
	if(drowsy)
		apply_effect(drowsy, EFFECT_DROWSY)
	if(updating_health)
		updatehealth()
	return TRUE
