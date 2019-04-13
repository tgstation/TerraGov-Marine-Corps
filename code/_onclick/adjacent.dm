/*
	Adjacency proc for determining touch range

	This is mostly to determine if a user can enter a square for the purposes of touching something.
	Examples include reaching a square diagonally or reaching something on the other side of a glass window.

	This is calculated by looking for border items, or in the case of clicking diagonally from yourself, dense items.
	This proc will NOT notice if you are trying to attack a window on the other side of a dense object in its turf.  There is a window helper for that.

	Note that in all cases the neighbor is handled simply; this is usually the user's mob, in which case it is up to you
	to check that the mob is not inside of something
*/
/atom/proc/Adjacent(atom/neighbor) // basic inheritance, unused
	return FALSE

// Not a sane use of the function and (for now) indicative of an error elsewhere
/area/Adjacent(atom/neighbor)
	CRASH("Call to /area/Adjacent(), unimplemented proc")


/*
	Adjacency (to turf):
	* If you are in the same turf, always true
	* If you are vertically/horizontally adjacent, ensure there are no border objects
	* If you are diagonally adjacent, ensure you can pass through at least one of the mutually adjacent square.
		* Passing through in this case ignores anything with the throwpass flag, such as tables, racks, and morgue trays.
*/
/turf/Adjacent(atom/neighbor, atom/target, atom/movable/mover)
	var/turf/T0 = get_turf(neighbor)
	
	if(T0 == src) //same turf
		return TRUE
	
	if(get_dist(src, T0) > 1 || z != T0.z) //too far
		return FALSE

	// Non diagonal case
	if(T0.x == x || T0.y == y)
		// Check for border blockages
		return T0.ClickCross(get_dir(T0,src), border_only = TRUE, target_atom = target, mover = mover) && ClickCross(get_dir(src,T0), border_only = 1, target_atom = target, mover = mover)

	// Diagonal case
	var/in_dir = get_dir(T0,src) // eg. northwest (1+8) = 9 (00001001)
	var/d1 = in_dir & 3		     // eg. north	  (1+8)&3 (0000 0011) = 1 (0000 0001)
	var/d2 = in_dir & 12		 // eg. west	  (1+8)&12 (0000 1100) = 8 (0000 1000)

	for(var/d in list(d1,d2))
		if(!T0.ClickCross(d, border_only = TRUE, target_atom = target, mover = mover))
			continue // could not leave T0 in that direction

		var/turf/T1 = get_step(T0,d)
		if(!T1 || T1.density)
			continue
		if(!T1.ClickCross(get_dir(T1,src), border_only = FALSE, target_atom = target, mover = mover) || !T1.ClickCross(get_dir(T1,T0), border_only = 0, target_atom = target, mover = mover))
			continue // couldn't enter or couldn't leave T1

		if(!ClickCross(get_dir(src,T1), border_only = TRUE, target_atom = target, mover = mover))
			continue // could not enter src

		return TRUE // we don't care about our own density

	return FALSE


/*
	Adjacency (to anything else):
	* Must be on a turf
	* In the case of a multiple-tile object, all valid locations are checked for adjacency.

	Note: Multiple-tile objects are created when the bound_width and bound_height are creater than the tile size.
	This is not used in stock /tg/station currently.
*/
/atom/movable/Adjacent(atom/neighbor)
	if(neighbor == loc)
		return TRUE
	if(!isturf(loc))
		return FALSE
	if(loc.Adjacent(neighbor, target = neighbor, mover = src))
		return TRUE
	return FALSE


//Multitile special cases.
/obj/structure/Adjacent(atom/neighbor)
	if(bound_width > 32 || bound_height > 32)
		for(var/X in locs)
			var/turf/T = X
			if(T.Adjacent(neighbor, target = neighbor, mover = src))
				return TRUE
	else
		if(neighbor == loc)
			return TRUE
		if(!isturf(loc))
			return FALSE
		if(loc.Adjacent(neighbor, target = neighbor, mover = src))
			return TRUE
	return FALSE


/mob/living/silicon/decoy/Adjacent(atom/neighbor)
	for(var/X in locs)
		var/turf/T = X
		if(T.Adjacent(neighbor, target = neighbor, mover = src))
			return TRUE
	return FALSE


/obj/machinery/door/Adjacent(atom/neighbor)
	if(bound_width > 32 || bound_height > 32)
		for(var/X in locs)
			var/turf/T = X
			if(T.Adjacent(neighbor, target = neighbor, mover = src))
				return TRUE
	else
		if(neighbor == loc)
			return TRUE
		if(!isturf(loc))
			return FALSE
		if(loc.Adjacent(neighbor, target = neighbor, mover = src))
			return TRUE
	return FALSE


// This is necessary for storage items not on your person.
/obj/item/Adjacent(atom/neighbor)
	if(neighbor == loc || neighbor == loc.loc) //Item is in the neighbor or something that it holds.
		return TRUE

	if(isitem(loc)) //Special case handling.
		if(istype(loc, /obj/item/storage/internal)) //Special holders, could be contained really deep, like webbings, so let's go one step further.
			return loc.Adjacent(neighbor)
		else //Backpacks and other containers.
			if(!isturf(loc.loc)) //Item is inside an item neither held by neighbor nor in a turf. Can't access.
				return FALSE
			return loc.loc.Adjacent(neighbor, target = neighbor, mover = src)

	if(!isturf(loc)) //Default behavior.
		return FALSE
	if(loc.Adjacent(neighbor, target = neighbor, mover = src))
		return TRUE
	return FALSE


/obj/item/projectile/Adjacent(atom/neighbor) //Projectiles don't behave like regular items.
	var/turf/T = get_turf(loc)
	if(!T)
		return FALSE
	return T.Adjacent(neighbor, target = neighbor, mover = src)


/obj/item/radio/detpack/Adjacent(neighbor) //Snowflake detpacks.
	if(neighbor == loc)
		return TRUE
	var/turf/T = get_turf(loc)
	if(!T)
		return FALSE
	return T.Adjacent(neighbor, target = neighbor, mover = src)


/*
	This checks if you there is uninterrupted airspace between that turf and this one.
	This is defined as any dense ON_BORDER object, or any dense object without throwpass.
	The border_only flag allows you to not objects (for source and destination squares)
*/
/turf/proc/ClickCross(target_dir, border_only, target_atom = null, atom/movable/mover = null)
	for(var/obj/O in src)
		if((mover && O.CanPass(mover,get_step(src, target_dir))) || (!mover && !O.density))
			continue
		if(O == target_atom || O == mover || O.throwpass) //check if there's a dense object present on the turf
			continue // LETPASSTHROW is used for anything you can click through (or the firedoor special case, see above)

		if(O.flags_atom & ON_BORDER) // windows have throwpass but are on border, check them first
			if(O.dir & target_dir || O.dir & (O.dir-1)) // full tile windows are just diagonals mechanically
				return FALSE

		else if(!border_only) // dense, not on border, cannot pass over
			return FALSE
	return TRUE
/*
	Aside: throwpass does not do what I thought it did originally, and is only used for checking whether or not
	a thrown object should stop after already successfully entering a square.  Currently the throw code involved
	only seems to affect hitting mobs, because the checks performed against objects are already performed when
	entering or leaving the square.  Since throwpass isn't used on mobs, but only on objects, it is effectively
	useless.  Throwpass may later need to be removed and replaced with a passcheck (bitfield on movable atom passflags).

	Since I don't want to complicate the click code rework by messing with unrelated systems it won't be changed here.
*/

/atom/proc/handle_barriers(mob/living/M)
	for(var/obj/structure/S in M.loc)
		if(S.flags_atom & ON_BORDER && S.dir & get_dir(M,src) || S.dir&(S.dir-1))
			if(S.flags_barrier & HANDLE_BARRIER_CHANCE)
				if(S.handle_barrier_chance(M))
					return S // blocked
	for(var/obj/structure/S in loc)
		if(S.flags_atom & ON_BORDER && S.dir & get_dir(src,M) || S.dir&(S.dir-1))
			if(S.flags_barrier & HANDLE_BARRIER_CHANCE)
				if(S.handle_barrier_chance(M))
					return S // blocked
	return src // not blocked

/turf/handle_barriers(mob/living/M)
	return src
