/mob/living/on_death()
	dizziness = 0
	jitteriness = 0
	reset_perspective(null)
	smokecloak_off()

	GLOB.alive_living_list -= src
	LAZYREMOVE(GLOB.ssd_living_mobs, src)
	if(job?.job_flags & (JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE))//Only some jobs cost you your respawn timer.
		GLOB.key_to_time_of_death[key] = world.time
	return ..()
