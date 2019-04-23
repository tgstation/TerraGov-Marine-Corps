
/*
	apply_damage(a,b,c)
	args
	a:damage - How much damage to take
	b:damage_type - What type of damage to take, brute, burn
	c:def_zone - Where to take the damage if its brute or burn
	Returns
	standard 0 if fail
*/
/mob/living/proc/apply_damage(var/damage = 0,var/damagetype = BRUTE, var/def_zone = null, var/blocked = 0, var/used_weapon = null, var/sharp = 0, var/edge = 0)
	if(blocked >= 1) //total negation
		return 0

	if(blocked)
		damage *= CLAMP(1-blocked,0.00,1.00) //Percentage reduction

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
		if(HALLOSS)
			adjustHalLoss(damage)
	updatehealth()
	return TRUE


/mob/living/proc/apply_damages(var/brute = 0, var/burn = 0, var/tox = 0, var/oxy = 0, var/clone = 0, var/halloss = 0, var/def_zone = null, var/blocked = 0)
	if(blocked >= 1) //Complete negation/100% reduction
		return FALSE
	if(brute)
		apply_damage(brute, BRUTE, def_zone, blocked)
	if(burn)
		apply_damage(burn, BURN, def_zone, blocked)
	if(tox)
		apply_damage(tox, TOX, def_zone, blocked)
	if(oxy)
		apply_damage(oxy, OXY, def_zone, blocked)
	if(clone)
		apply_damage(clone, CLONE, def_zone, blocked)
	if(halloss)
		apply_damage(halloss, HALLOSS, def_zone, blocked)
	return TRUE



/mob/living/proc/apply_effect(var/effect = 0,var/effecttype = STUN, var/blocked = 0)
	if(!effect || (blocked >= 2))	return 0
	switch(effecttype)
		if(STUN)
			Stun(effect/(blocked+1))
		if(WEAKEN)
			KnockDown(effect/(blocked+1))
		if(PARALYZE)
			KnockOut(effect/(blocked+1))
		if(AGONY)
			adjustHalLoss(effect/blocked+1)
		if(IRRADIATE)
			var/rad_protection = getarmor(null, "rad")/100
			radiation += max((1-rad_protection)*effect/(blocked+1),0)//Rads auto check armor
		if(STUTTER)
			if(status_flags & CANSTUN) // stun is usually associated with stutter
				stuttering = max(stuttering,(effect/(blocked+1)))
		if(EYE_BLUR)
			blur_eyes(effect/(blocked+1))
		if(DROWSY)
			drowsyness = max(drowsyness,(effect/(blocked+1)))
	updatehealth()
	return 1


/mob/living/proc/apply_effects(var/stun = 0, var/weaken = 0, var/paralyze = 0, var/irradiate = 0, var/stutter = 0, var/eyeblur = 0, var/drowsy = 0, var/agony = 0, var/blocked = 0)
	if(blocked >= 2)	return 0
	if(stun)		apply_effect(stun, STUN, blocked)
	if(weaken)		apply_effect(weaken, WEAKEN, blocked)
	if(paralyze)	apply_effect(paralyze, PARALYZE, blocked)
	if(irradiate)	apply_effect(irradiate, IRRADIATE, blocked)
	if(stutter)		apply_effect(stutter, STUTTER, blocked)
	if(eyeblur)		apply_effect(eyeblur, EYE_BLUR, blocked)
	if(drowsy)		apply_effect(drowsy, DROWSY, blocked)
	if(agony)		apply_effect(agony, AGONY, blocked)
	return 1
