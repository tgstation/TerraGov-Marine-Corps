/mob/dead/observer/Logout()
	GLOB.observer_list -= src

	if(observetarget)
		if(ismob(observetarget))
			var/mob/target = observetarget
			if(target.observers)
				target.observers -= src
				UNSETEMPTY(target.observers)
			observetarget = null

	. = ..()

	spawn(1)
		if(!QDELETED(src) && (!key || isaghost(src)))	//we've transferred to another mob. This ghost should be deleted.
			qdel(src)