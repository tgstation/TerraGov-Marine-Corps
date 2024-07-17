/mob/dead/observer/Logout()
	UnregisterSignal(src, COMSIG_MOVABLE_Z_CHANGED)
	SSmobs.dead_players_by_zlevel[z] -= src

	. = ..()

	if(QDELETED(src) || (key && !isaghost(src)))
		return

	mind = null //We no longer need a reference to this mind.
	QDEL_IN(src, 1)
