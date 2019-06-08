/obj/effect/portal
	name = "portal"
	desc = "Looks unstable. Best to test it with the clown."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "portal"
	density = TRUE
	var/failchance = 5
	var/obj/item/target = null
	var/creator = null
	anchored = TRUE

/obj/effect/portal/Bumped(mob/M as mob|obj)
	spawn(0)
		src.teleport(M)
		return
	return

/obj/effect/portal/Crossed(AM as mob|obj)
	spawn(0)
		src.teleport(AM)
		return
	return

/obj/effect/portal/attack_hand(mob/user as mob)
	spawn(0)
		src.teleport(user)
		return
	return

/obj/effect/portal/New()
	spawn(300)
		qdel(src)
		return
	return

/obj/effect/portal/proc/teleport(atom/movable/M as mob|obj)
	if(istype(M, /obj/effect)) //sparks don't teleport
		return
	if (icon_state == "portal1")
		return
	if (!( target ))
		qdel(src)
		return
	if (ismovableatom(M))
		if(prob(failchance)) //oh dear a problem, put em in deep space
			src.icon_state = "portal1"
			do_teleport(M, locate(rand(5, world.maxx - 5), rand(5, world.maxy -5), 3), 0)
		else
			do_teleport(M, target, 1) ///You will appear adjacent to the beacon

