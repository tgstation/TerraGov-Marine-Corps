//Refer to life.dm for caller

/mob/living/carbon/human/proc/handle_random_events()
	//Puke if toxloss is too high
	if(!stat)
		if(getToxLoss() >= 45 && nutrition > 20)
			vomit()

	//0.1% chance of playing a scary sound to someone who's in complete darkness
	if(isturf(loc) && rand(1, 1000) == 1)
		var/turf/currentTurf = loc
		if(!currentTurf.lighting_lumcount)
			playsound_local(src, pick(scarySounds), 50, 1, -1)

	//Not the best place to put this, but eh
	//Smoke/boiler glob processing!
	if(isturf(loc) && stat != DEAD)
		for(var/obj/effect/particle_effect/smoke/xeno_weak/X in get_turf(src))
			if(X)
				X.affect(src)
				break
		for(var/obj/effect/particle_effect/smoke/xeno_burn/Z in get_turf(src))
			if(Z)
				Z.affect(src)
				break

