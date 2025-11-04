/mob/living/carbon/xenomorph/UnarmedAttack(atom/A, has_proximity, modifiers)
	if(lying_angle)
		return FALSE
	if(isclosedturf(get_turf(src)) && !iswallturf(A))	//If we are on a closed turf (e.g. in a wall) we can't attack anything, except walls (or well, resin walls really) so we can't make ourselves be stuck.
		balloon_alert(src, "unreachable!")
		return FALSE
	if(!(isopenturf(A) || istype(A, /obj/alien/weeds))) //We don't care about open turfs; they don't trigger our melee click cooldown
		changeNext_move(xeno_caste ? xeno_caste.attack_delay : CLICK_CD_MELEE)
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		return
	if(isxeno(A))
		var/mob/living/carbon/xenomorph/X = A
		if(get_xeno_hivenumber() != X.get_xeno_hivenumber())
			X.apply_status_effect(/datum/status_effect/nohealthregen, 10 SECONDS)

	var/atom/S = A.handle_barriers(src)
	S.attack_alien(src, xeno_caste.melee_damage * xeno_melee_damage_modifier, isrightclick = islist(modifiers) ? modifiers["right"] : FALSE)
	GLOB.round_statistics.xeno_unarmed_attacks++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "xeno_unarmed_attacks")

/mob/living/carbon/xenomorph/proc/xeno_slash(atom/A, has_proximity, modifiers, check)
	if(check)
		if(!slash_checks())
			return FALSE
	if(!(isopenturf(A) || istype(A, /obj/alien/weeds))) //We don't care about open turfs; they don't trigger our melee click cooldown
		changeNext_move(xeno_caste ? xeno_caste.attack_delay : CLICK_CD_MELEE)
	var/atom/S = A.handle_barriers(src)
	GLOB.round_statistics.xeno_unarmed_attacks++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "xeno_unarmed_attacks")
	S.attack_alien(src, xeno_caste.melee_damage * xeno_melee_damage_modifier, isrightclick = islist(modifiers) ? modifiers["right"] : FALSE)

/mob/living/carbon/xenomorph/proc/slash_checks(atom/A)
	if(lying_angle)
		return FALSE
	if(isclosedturf(get_turf(src)) && !iswallturf(A))    //If we are on a closed turf (e.g. in a wall) we can't attack anything, except walls (or well, resin walls really) so we can't make ourselves be stuck.
		balloon_alert(src, "Cannot reach")
		return FALSE
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		return FALSE
	return TRUE

/atom/proc/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage * xeno_attacker.xeno_melee_damage_modifier, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, armor_penetration = xeno_attacker.xeno_caste.melee_ap, isrightclick = FALSE)
	return

/turf/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage * xeno_attacker.xeno_melee_damage_modifier, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, armor_penetration = xeno_attacker.xeno_caste.melee_ap, isrightclick = FALSE)
	SEND_SIGNAL(src, COMSIG_XENOMORPH_ATTACK_TURF, xeno_attacker)

/mob/living/carbon/xenomorph/larva/UnarmedAttack(atom/A, has_proximity, modifiers)
	if(lying_angle)
		return FALSE
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		return FALSE

	A.attack_larva(src)

/atom/proc/attack_larva(mob/living/carbon/xenomorph/larva/L)
	return



/mob/living/carbon/xenomorph/hivemind/UnarmedAttack(atom/A, has_proximity, modifiers)
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		return
	A.attack_hivemind(src)

/atom/proc/attack_hivemind(mob/living/carbon/xenomorph/hivemind/attacker)
	return
