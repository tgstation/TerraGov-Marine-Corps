/mob/living/silicon/ai/Life()
	if(stat == DEAD)
		SSmobs.stop_processing(src)
		return

	updatehealth()

	interactee?.check_eye(src)

	// Handle EMP-stun
	handle_stunned()


/mob/living/silicon/ai/update_stat()
	. = ..()

	if(status_flags & GODMODE)
		return

	if(stat != DEAD)
		if(health <= get_death_threshold())
			death()
		else if(stat == UNCONSCIOUS)
			stat = CONSCIOUS


/mob/living/silicon/ai/updatehealth()
	if(status_flags & GODMODE)
		return

	health = 100 - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss()

	update_stat()