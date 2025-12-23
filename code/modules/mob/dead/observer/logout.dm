/mob/dead/observer/Logout()
	UnregisterSignal(src, COMSIG_MOVABLE_Z_CHANGED)
	if(!isnum(z))
		stack_trace("z [logdetails(z)] is not a number while in Logout of [logdetails(src)]")
	else
		if(z > length(SSmobs.dead_players_by_zlevel))
			stack_trace("z [logdetails(z)] is bigger than length(SSmobs.dead_players_by_zlevel)([length(SSmobs.dead_players_by_zlevel)]) while in Logout of [logdetails(src)]")
			while(length(SSmobs.dead_players_by_zlevel) < z)
				SSmobs.dead_players_by_zlevel.len++
				SSmobs.dead_players_by_zlevel[length(SSmobs.dead_players_by_zlevel)] = list()
		else
			SSmobs.dead_players_by_zlevel[z] -= src

	. = ..()

	if(QDELETED(src) || (key && !isaghost(src)))
		return

	mind = null //We no longer need a reference to this mind.
	QDEL_IN(src, 1)
