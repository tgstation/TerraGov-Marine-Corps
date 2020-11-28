/mob/living/carbon/xenomorph/UnarmedAttack(atom/A, proximity_flag)
	if(lying_angle)
		return FALSE

	if(xeno_caste)
		changeNext_move(xeno_caste.attack_delay)
	else
		changeNext_move(CLICK_CD_MELEE)

	var/atom/S = A.handle_barriers(src)
	S.attack_alien(src)
	GLOB.round_statistics.xeno_unarmed_attacks++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "xeno_unarmed_attacks")


/atom/proc/attack_alien(mob/living/carbon/xenomorph/X)
	return


/mob/living/carbon/xenomorph/larva/UnarmedAttack(atom/A, proximity_flag)
	if(lying_angle)
		return FALSE

	A.attack_larva(src)

/atom/proc/attack_larva(mob/living/carbon/xenomorph/larva/L)
	return



/mob/living/carbon/xenomorph/hivemind/UnarmedAttack(atom/A, proximity_flag)
	A.attack_hivemind(src)

/atom/proc/attack_hivemind(mob/living/carbon/xenomorph/hivemind/attacker)
	return
