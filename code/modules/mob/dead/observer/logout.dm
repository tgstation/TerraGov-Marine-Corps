/mob/dead/observer/Logout()
	. = ..()
	spawn(0)
		if(src && (!key || copytext(key, 1, 2) == "@"))	//we've transferred to another mob. This ghost should be deleted.
			qdel(src)