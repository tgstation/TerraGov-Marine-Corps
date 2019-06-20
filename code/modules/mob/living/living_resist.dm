/mob/living/proc/do_resist()
	if(next_move > world.time)
		return FALSE

	if(incapacitated(TRUE))
		to_chat(src, "<span class='warning'>You can't resist in your current state.</span>")
		return FALSE

	changeNext_move(CLICK_CD_RESIST)

	SEND_SIGNAL(src, COMSIG_LIVING_DO_RESIST, src)