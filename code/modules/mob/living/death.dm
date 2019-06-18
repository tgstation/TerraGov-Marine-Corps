/mob/living/death(gibbed, deathmessage = "seizes up and falls limp...")
	if(stat == DEAD)
		return FALSE

	dizziness = 0
	jitteriness = 0
	reset_perspective(null)

	return ..()