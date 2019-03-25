/mob/dead/observer/click(var/atom/A, var/list/mods)
	. = ..()
	if(.)
		return TRUE

	if(world.time <= next_move)
		return TRUE

	if(mods["ctrl"] && mods["middle"])
		if(can_reenter_corpse && mind?.current)
			if(A == mind.current || (mind.current in A))
				reenter_corpse()

		else if(ismob(A) && A != src)
			ManualFollow(A)

		else
			unfollow()
			loc = get_turf(A)

		return TRUE

	next_move = world.time + 8

	if(!mods["shift"])
		A.attack_ghost(src)

	return TRUE


/atom/proc/attack_ghost(mob/dead/observer/user)
	if(!user.client || !user.inquisitive_ghost)
		return
	examine(user)


/obj/structure/ladder/attack_ghost(mob/user as mob)
	if(up && down)
		switch( alert("Go up or down the ladder?", "Ladder", "Up", "Down", "Cancel") )
			if("Up")
				user.loc = get_turf(up)
			if("Down")
				user.loc = get_turf(down)
			if("Cancel")
				return

	else if(up)
		user.loc = get_turf(up)

	else if(down)
		user.loc = get_turf(down)