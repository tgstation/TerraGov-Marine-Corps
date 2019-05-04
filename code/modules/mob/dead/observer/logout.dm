/mob/dead/observer/Logout()
	. = ..()
	GLOB.observer_list -= src
	spawn(0)
		if(src && (!key || isaghost(src)))	//we've transferred to another mob. This ghost should be deleted.
			qdel(src)