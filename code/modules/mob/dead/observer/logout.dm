/mob/dead/observer/Logout()
	GLOB.observer_list -= src


	. = ..()

	if(QDELETED(src) || (key && !isaghost(src)))
		return

	mind = null //We no longer need a reference to this mind.
	QDEL_IN(src, 1)
