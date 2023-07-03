/mob/living/carbon/xenomorph/Logout()
	. = ..()
	UnregisterSignal(SSdcs, COMSIG_GLOB_NUKE_START)
