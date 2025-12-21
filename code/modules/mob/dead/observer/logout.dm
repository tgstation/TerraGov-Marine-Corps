/mob/dead/observer/Logout()
	UnregisterSignal(src, COMSIG_MOVABLE_Z_CHANGED)
	if(z in SSmobs.dead_players_by_zlevel)
		SSmobs.dead_players_by_zlevel[z] -= src
	else
		stack_trace("z [isnum(z) ? num2text(z) : logdetails(z)] not found in SSmobs.dead_players_by_zlevel while in Logout of [logdetails(src)]")

	. = ..()

	if(QDELETED(src) || (key && !isaghost(src)))
		return

	mind = null //We no longer need a reference to this mind.
	QDEL_IN(src, 1)
