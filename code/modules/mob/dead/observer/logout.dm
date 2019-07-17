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

	if(QDELETED(src) || (key && !isaghost(src)))
		return

	QDEL_IN(src, 2)