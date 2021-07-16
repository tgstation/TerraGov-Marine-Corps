/mob/living/carbon/xenomorph/UnarmedAttack(atom/A, has_proximity, modifiers)
	if(lying_angle)
		return FALSE

	if(!isopenturf(A)) //We don't care about open turfs; they don't trigger our melee click cooldown
		changeNext_move(xeno_caste ? xeno_caste.attack_delay : CLICK_CD_MELEE)

	var/atom/S = A.handle_barriers(src)
	S.attack_alien(src, xeno_caste.melee_damage * xeno_melee_damage_modifier, isrightclick = islist(modifiers) ? modifiers["right"] : FALSE)
	GLOB.round_statistics.xeno_unarmed_attacks++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "xeno_unarmed_attacks")


/atom/proc/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	return


/mob/living/carbon/xenomorph/larva/UnarmedAttack(atom/A, has_proximity, modifiers)
	if(lying_angle)
		return FALSE

	A.attack_larva(src)

/atom/proc/attack_larva(mob/living/carbon/xenomorph/larva/L)
	return



/mob/living/carbon/xenomorph/hivemind/UnarmedAttack(atom/A, has_proximity, modifiers)
	A.attack_hivemind(src)

/atom/proc/attack_hivemind(mob/living/carbon/xenomorph/hivemind/attacker)
	return
