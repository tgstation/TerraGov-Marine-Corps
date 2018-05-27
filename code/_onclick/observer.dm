/client/var/inquisitive_ghost = 1
/mob/dead/observer/verb/toggle_inquisition() // warning: unexpected inquisition
	set name = "Toggle Inquisitiveness"
	set desc = "Sets whether your ghost examines everything on click by default"
	set category = "Ghost"
	if(!client) return
	client.inquisitive_ghost = !client.inquisitive_ghost
	if(client.inquisitive_ghost)
		src << "\blue You will now examine everything you click on."
	else
		src << "\blue You will no longer examine things you click on."

/mob/dead/observer/click(var/atom/A, var/list/mods)
	if (..())
		return 1

	if (mods["ctrl"] && mods["middle"])
		if(can_reenter_corpse && mind && mind.current)
			if(A == mind.current || (mind.current in A)) // double click your corpse or whatever holds it
				reenter_corpse()						// (cloning scanner, body bag, closet, mech, etc)
				return 1								// seems legit.

		// Things you might plausibly want to follow
		if((ismob(A) && A != src) || istype(A,/obj/machinery/bot) || istype(A,/obj/machinery/singularity))
			ManualFollow(A)

		// Otherwise jump
		else
			following = null
			loc = get_turf(A)

		return 1

	if(world.time <= next_move)
		return 1

	next_move = world.time + 8
	// You are responsible for checking config.ghost_interaction when you override this function
	// Not all of them require checking, see below
	if(!mods["shift"])
		A.attack_ghost(src)
	return 1

// Oh by the way this didn't work with old click code which is why clicking shit didn't spam you
/atom/proc/attack_ghost(mob/dead/observer/user)
	if(user.client && user.client.inquisitive_ghost)
		examine(user)

// ---------------------------------------
// And here are some good things for free:
// Now you can click through portals, wormholes, gateways, and teleporters while observing. -Sayu

/obj/machinery/teleport/hub/attack_ghost(mob/user as mob)
	var/atom/l = loc
	var/obj/machinery/computer/teleporter/com = locate(/obj/machinery/computer/teleporter, locate(l.x - 2, l.y, l.z))
	if(com && com.locked)
		user.loc = get_turf(com.locked)

/obj/effect/portal/attack_ghost(mob/user as mob)
	if(target)
		user.loc = get_turf(target)

/obj/machinery/gateway/centerstation/attack_ghost(mob/user as mob)
	if(awaygate)
		user.loc = awaygate.loc
	else
		user << "[src] has no destination."

/obj/machinery/gateway/centeraway/attack_ghost(mob/user as mob)
	if(stationgate)
		user.loc = stationgate.loc
	else
		user << "[src] has no destination."

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

// -------------------------------------------
// This was supposed to be used by adminghosts
// I think it is a *terrible* idea
// but I'm leaving it here anyway
// commented out, of course.
/*
/atom/proc/attack_admin(mob/user as mob)
	if(!user || !user.client || !user.client.holder)
		return
	attack_hand(user)

*/

/* This allows Observers to click on disconnected Larva and become them, but not all Larva are clickable due to hiding
/mob/living/carbon/Xenomorph/Larva/attack_ghost(mob/user as mob)
	if(!istype(src, /mob/living/carbon/Xenomorph/Larva))
		return

	// if(src.key || src.mind || !src.client.is_afk())
	if(src.client)
		return

	if(!can_mind_transfer) //away_timer is not high enough. Number below should match number in mob.dm.
		user << "That player hasn't been away long enough. Please wait [60 - away_timer] more seconds."
		return

	if (alert(user, "Are you sure you want to transfer yourself into this Alien Larva?", "Confirmation", "Yes", "No") == "Yes")
		src.client = user.client
		return*/