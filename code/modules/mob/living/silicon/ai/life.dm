/mob/living/silicon/ai/Life(seconds_per_tick, times_fired)

	if(notransform) //If we're dead or set to notransform don't bother processing life
		return

	if(stat == DEAD)
		SSmobs.stop_processing(src)
		return

	updatehealth()

	interactee?.check_eye(src)


/mob/living/silicon/ai/update_stat()
	. = ..()

	if(status_flags & GODMODE)
		return

	if(stat != DEAD)
		if(health <= get_death_threshold())
			death()
		else if(stat == UNCONSCIOUS)
			set_stat(CONSCIOUS)


/mob/living/silicon/ai/updatehealth()
	if(status_flags & GODMODE)
		return

	health = 100 - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss()

	update_stat()
