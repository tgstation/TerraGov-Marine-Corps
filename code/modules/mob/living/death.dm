/mob/living/on_death()
	dizziness = 0
	jitteriness = 0
	reset_perspective(null)

	GLOB.alive_living_list -= src

	return ..()
