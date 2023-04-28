/**
	Returns a number after taking into account both soft and hard armor for the specified damage type, usually damage

	Arguments
	* Damage_amount: The original unmodified damage
	* armor_type: The type of armor by which the damage will be modified
	* penetration: How much the damage source might bypass the armour value (optional)
	* def_zone: What part of the body we want to check the armor of (optional)

	Hard armor reduces penetration by a flat amount, and sunder in the case of xenos
	Penetration reduces soft armor by a flat amount.
	Damage cannot go into the negative, or exceed the original amount.
*/
/mob/living/proc/modify_by_armor(damage_amount, armor_type, penetration, def_zone)
	penetration = max(0, penetration - get_hard_armor(armor_type, def_zone))
	return clamp((damage_amount * (1 - ((get_soft_armor(armor_type, def_zone) - penetration) * 0.01))), 0, damage_amount)

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
	effect {int} how much of an effect to apply
	effecttype {enum} which affect to apply
	blocked {int} an amount of the effect that is blocked
	updating_health {boolean} if we should update health [/mob/living/updatehealth]
*/
/mob/living/proc/apply_effect(effect = 0, effecttype = STUN, blocked = 0, updating_health = FALSE)
	if(status_flags & GODMODE)
		return FALSE
	if(!effect || (blocked >= 2))
		return FALSE
	switch(effecttype)
		if(STUN)
			Stun(effect/(blocked+1) * 20) // TODO: replace these * 20 with proper amounts in apply_effect() calls
		if(WEAKEN)
			Paralyze(effect/(blocked+1) * 20)
		if(PARALYZE)
			Unconscious(effect/(blocked+1) * 20)
		if(AGONY)
			adjustStaminaLoss(effect/(blocked+1))
		if(STUTTER)
			if(status_flags & CANSTUN) // stun is usually associated with stutter
				set_timed_status_effect(effect/(blocked+1), /datum/status_effect/speech/stutter, only_if_higher = TRUE)
		if(EYE_BLUR)
			blur_eyes(effect/(blocked+1))
		if(DROWSY)
			adjustDrowsyness(effect / (blocked + 1))
	if(updating_health)
		updatehealth()
	return TRUE


/mob/living/proc/apply_effects(stun = 0, weaken = 0, paralyze = 0, stutter = 0, eyeblur = 0, drowsy = 0, agony = 0, blocked = 0, updating_health = FALSE)
	if(blocked >= 2)
		return FALSE
	if(stun)
		apply_effect(stun, STUN, blocked)
	if(weaken)
		apply_effect(weaken, WEAKEN, blocked)
	if(paralyze)
		apply_effect(paralyze, PARALYZE, blocked)
	if(stutter)
		apply_effect(stutter, STUTTER, blocked)
	if(eyeblur)
		apply_effect(eyeblur, EYE_BLUR, blocked)
	if(drowsy)
		apply_effect(drowsy, DROWSY, blocked)
	if(agony)
		apply_effect(agony, AGONY, blocked)
	if(updating_health)
		updatehealth()
	return TRUE
