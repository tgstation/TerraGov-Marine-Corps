
/mob/living/Login()
	. = ..()
	//Mind updates
	mind_initialize()	//updates the mind (or creates and initializes one if one doesn't exist)
	mind.active = 1		//indicates that the mind is currently synced with a client

	var/turf/mob_turf = get_turf(src)
	if(isturf(mob_turf))
		update_z(mob_turf.z)

	if(HAS_TRAIT(src, TRAIT_MOVE_VENTCRAWLING))  //If we are in a vent, fetch a fresh vent map
		update_pipe_vision()

	LAZYREMOVE(GLOB.ssd_living_mobs, src)
	set_afk_status(MOB_CONNECTED)

	update_fov_client()
