/mob/living/on_death()
	dizziness = 0
	jitteriness = 0
	reset_perspective(null)
	smokecloak_off()

	GLOB.alive_living_list -= src
	LAZYREMOVE(GLOB.ssd_living_mobs, src)

	return ..()
