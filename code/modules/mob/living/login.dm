
/mob/living/Login()
	. = ..()
	//Mind updates
	mind_initialize()	//updates the mind (or creates and initializes one if one doesn't exist)
	mind.active = 1		//indicates that the mind is currently synced with a client

	var/turf/mob_turf = get_turf(src)
	if(isturf(mob_turf))
		update_z(mob_turf.z)

	if(length(pipes_shown)) //ventcrawling, need to reapply pipe vision
		var/obj/machinery/atmospherics/A = loc
		if(istype(A)) //a sanity check just to be safe
			remove_ventcrawl()
			add_ventcrawl(A)
	LAZYREMOVE(GLOB.ssd_living_mobs, src)
	set_afk_status(MOB_CONNECTED)

	update_fov_client()
