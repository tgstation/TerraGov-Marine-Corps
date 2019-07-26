#define BREAK_LIGHT 1
#define OPEN_DOOR 2
#define GET_HEALED 3
#define MOVE_SUCCESS 1
#define MOVE_BLOCKED 0

/*
A custom Move() for the AI xenomorphs
Main feature about this is that if Move() is null for whatever reason, we can try again in different dirs or other things
Depending on what had gone wrong instead of putting all of that into the main loop and copy paste it everywhere, it's here.
*/
/proc/CustomMove(atom/movable/A, turf, direction)
	if(IsDiagonal(direction))
		var/list/sanitydir = DirectionToCardinal(direction) //Try one of the two possible movements then queue up the next
		if(!(A.Move(get_step(A, sanitydir[1]), sanitydir[1]))) //If first Move() fails, try the other cardinal dir in case the direction is diagonal
			if(!(A.Move(get_step(A, sanitydir[2]), sanitydir[2]))) //If this fails, the thing has probably become trapped, loose the target and idle move for a bit
				if(istype(A, /mob/living/carbon/Xenomorph/AI))
					var/mob/living/carbon/Xenomorph/AI/xeno = A
					xeno.RemoveTarget()
				return MOVE_BLOCKED
			else
				var/mob/living/carbon/Xenomorph/AI/xeno = A
				xeno.queuedmovement = sanitydir[1]
				return MOVE_SUCCESS //Move the other direction
		else
			var/mob/living/carbon/Xenomorph/AI/xeno = A
			xeno.queuedmovement = sanitydir[2]
			return MOVE_SUCCESS //Otherwise yay it worked
	else
		if(!(A.Move(turf, direction))) //It failed, return bad stuff because we weren't going diagonal
			return MOVE_BLOCKED
		return MOVE_SUCCESS

/*
A custom proc that looks at everything in the path of a object going from srcturf to destturf, additional parameters if you want to check for certain things
usehitchance when set to true ultilizes get_projectile_hit_chance(), meaning it will return FALSE if it cannot path through the target
It will also check for density as well as IFF built into the projectiles, don't want friendly fire happening
*/
/proc/IsClearPath(turf/srcturf, mob/living/target, usehitchance, obj/item/projectile/p)
	if(!(target in hearers(7, src))) //Target not in sight, can't shoot it
		return FALSE
	var/turf/tempturf = srcturf //We ignore the src turf as we cannot shoot it if we're on it, in addition we're doing a pah right to the target, no intelligent pathfinding around walls
	while(tempturf != get_turf(target)) //Gotta be same turf as target
		tempturf = get_step(src, get_dir(tempturf, get_turf(target)))
		for(var/mob/living/L in tempturf)
			if(L && (L != target) && (L.get_projectile_hit_chance(p))) //If it returns true there's a **chance** we could hit it, don't want to risk it
				tempturf = get_turf(target)
				return FALSE
	return TRUE

/proc/LeftAndRightOfDir(direction) //Returns the left and right dir of the input dir, used for AI stutter step and cade movement, must be sanitized to not have diagonals
	var/list/somedirs = list()
	switch(direction)
		if(NORTH)
			somedirs = list(WEST, EAST)
		if(SOUTH)
			somedirs = list(EAST, WEST)
		if(WEST)
			somedirs = list(SOUTH, NORTH)
		if(EAST)
			somedirs = list(NORTH, SOUTH)
	return(somedirs)
/*
/proc/IsDiagonal(d) //For seeing if a direction is diagonal
	if(d == 1 || d == 2 || d == 4 || d == 8) //Pretty horrible, could be definitely better
		return 0 //It's cardinal
	return 1 //It's diagonal
*/
/proc/DirectionToCardinal(d, index) //Sanitizes the input by converting it from a diagonal to cardinal if it's a diagonal, index is if you want first or second result
	var/list/possibledir = list(d, d)
	if(!(IsDiagonal(d)))
		return(possibledir)
	else
		switch(d)
			if(NORTHEAST)
				possibledir = list(NORTH, EAST)
			if(NORTHWEST)
				possibledir = list(NORTH, WEST)
			if(SOUTHEAST)
				possibledir = list(SOUTH, EAST)
			if(SOUTHWEST)
				possibledir = list(SOUTH, WEST)
		if(index)
			return(possibledir[index])
		return(possibledir)
