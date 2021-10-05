
/mob/living/Login()
	. = ..()
	//Mind updates
	mind_initialize()	//updates the mind (or creates and initializes one if one doesn't exist)
	mind.active = 1		//indicates that the mind is currently synced with a client

	if(pipes_shown && pipes_shown.len) //ventcrawling, need to reapply pipe vision
		var/obj/machinery/atmospherics/A = loc
		if(istype(A)) //a sanity check just to be safe
			remove_ventcrawl()
			add_ventcrawl(A)
	var/datum/action/toggle_rightclick/rclick = new
	rclick.give_action(src)
	LAZYREMOVE(GLOB.ssd_living_mobs, src)
	set_afk_status(MOB_CONNECTED)
