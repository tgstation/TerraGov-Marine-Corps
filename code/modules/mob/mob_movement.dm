/mob/CanPass(atom/movable/mover, turf/target)
	if(mover.checkpass(PASSMOB)) return 1
	if(ismob(mover))
		if(checkpass(PASSMOB))
			return 1
	return (!mover.density || !density || lying)



/client/verb/fastNorth()
	set instant = TRUE
	set hidden = TRUE
	set name = ".fastNorth"
	Move(get_step(mob, NORTH), NORTH)


/client/verb/fastSouth()
	set instant = TRUE
	set hidden = TRUE
	set name = ".fastSouth"
	Move(get_step(mob, SOUTH), SOUTH)


/client/verb/fastWest()
	set instant = TRUE
	set hidden = TRUE
	set name = ".fastWest"
	Move(get_step(mob, WEST), WEST)


/client/verb/fastEast()
	set instant = TRUE
	set hidden = TRUE
	set name = ".fastEast"
	Move(get_step(mob, EAST), EAST)


/client/Northeast()
	swap_hand()
	return


/client/Southeast()
	attack_self()
	return


/client/Southwest()
	if(iscarbon(usr))
		var/mob/living/carbon/C = usr
		C.toggle_throw_mode()
	else
		to_chat(usr, "<span class='warning'>This mob type cannot throw items.</span>")
	return


/client/Northwest()
	if(iscarbon(usr))
		var/mob/living/carbon/C = usr
		if(!C.get_active_held_item())
			to_chat(usr, "<span class='warning'>You have nothing to drop in your hand.</span>")
			return
		C.drop_held_item()
	else
		to_chat(usr, "<span class='warning'>This mob type cannot drop items.</span>")
	return

//This gets called when you press the delete button.
/client/verb/delete_key_pressed()
	set hidden = 1

	if(!usr.pulling)
		to_chat(usr, "<span class='notice'>You are not pulling anything.</span>")
		return
	usr.stop_pulling()

/client/verb/swap_hand()
	set hidden = 1
	if(iscarbon(mob))
		mob:swap_hand()
	if(istype(mob,/mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = mob
		R.cycle_modules()
	return



/client/verb/attack_self()
	set hidden = 1
	if(mob)
		mob.mode()
	return


/client/verb/toggle_throw_mode()
	set hidden = 1
	if(!iscarbon(mob))
		return
	if (!mob.stat && isturf(mob.loc) && !mob.restrained())
		mob:toggle_throw_mode()
	else
		return


/client/verb/drop_item()
	set hidden = 1
	if(!iscyborg(mob))
		mob.drop_item_v()
	return


/client/Center()
	/* No 3D movement in 2D spessman game. dir 16 is Z Up
	if (isobj(mob.loc))
		var/obj/O = mob.loc
		if (mob.canmove)
			return O.relaymove(mob, 16)
	*/
	return


/client/proc/Move_object(direct)
	if(mob && mob.control_object)
		if(mob.control_object.density)
			step(mob.control_object,direct)
			if(!mob.control_object)	return
			mob.control_object.setDir(direct)
		else
			mob.control_object.loc = get_step(mob.control_object,direct)
	return


/client/Move(n, direct)
	if(mob.control_object)
		return Move_object(direct) //admins possessing object

	if(isobserver(mob) || isAI(mob))
		return mob.Move(n,direct)

	var/start_move_time = world.time
	if(next_movement > world.time)
		return

	if(mob.stat == DEAD)
		return

	// There should be a var/is_zoomed in mob code not this mess
	if(isxeno(mob))
		if(mob:is_zoomed)
			mob:zoom_out()

	// If mob moves while zoomed in with device, unzoom them.
	if(view != world.view || pixel_x || pixel_y)
		for(var/obj/item/item in mob.contents)
			if(item.zoom)
				item.zoom(mob)
				click_intercept = null
				break

	//Check if you are being grabbed and if so attemps to break it
	if(mob.pulledby)
		if(mob.incapacitated(TRUE))
			return
		else if(mob.restrained(0))
			next_movement = world.time + 20 //to reduce the spam
			to_chat(src, "<span class='warning'>You're restrained! You can't move!</span>")
			return
		else if(!mob.resist_grab(TRUE))
			return

	if(mob.buckled)
		return mob.buckled.relaymove(mob, direct)

	if(!mob.canmove)
		return

	if(isobj(mob.loc) || ismob(mob.loc))//Inside an object, tell it we moved
		var/atom/O = mob.loc
		return O.relaymove(mob, direct)

	if(isturf(mob.loc))
		mob.last_move_intent = world.time + 10
		switch(mob.m_intent)
			if(MOVE_INTENT_RUN)
				move_delay = 2 + CONFIG_GET(number/movedelay/run_delay)
			if(MOVE_INTENT_WALK)
				move_delay = 7 + CONFIG_GET(number/movedelay/walk_delay)
		move_delay += mob.movement_delay()
		//We are now going to move
		moving = 1
		glide_size = 32 / max(move_delay, tick_lag) * tick_lag

		var/mob/living/L = mob
		if(L.confused)
			step(L, pick(cardinal))
		else
			. = ..()

		moving = 0
		next_movement = start_move_time + move_delay
		return .

	return

///Process_Spacemove
///Called by /client/Move()
///For moving in space
///Return 1 for movement 0 for none
/mob/proc/Process_Spacemove(var/check_drift = 0)

	if(!Check_Dense_Object()) //Nothing to push off of so end here
		make_floating(1)
		return 0

	if(istype(src,/mob/living/carbon/human/))
		var/mob/living/carbon/human/H = src
		if(istype(H.shoes, /obj/item/clothing/shoes/magboots) && (H.shoes.flags_inventory & NOSLIPPING))  //magboots + dense_object = no floaty effect
			make_floating(0)
		else
			make_floating(1)
	else
		make_floating(1)

	if(restrained()) //Check to see if we can do things
		return 0

	//Check to see if we slipped
	if(prob(Process_Spaceslipping(5)))
		to_chat(src, "<span class='boldnotice'>You slipped!</span>")
		src.inertia_dir = src.last_move_dir
		step(src, src.inertia_dir)
		return 0
	//If not then we can reset inertia and move
	inertia_dir = 0
	return 1

/mob/proc/Check_Dense_Object() //checks for anything to push off in the vicinity. also handles magboots on gravity-less floors tiles

	var/dense_object = 0
	for(var/turf/turf in oview(1,src))
		if(istype(turf,/turf/open/space))
			continue

		if(istype(src,/mob/living/carbon/human/))  // Only humans can wear magboots, so we give them a chance to.
			var/mob/living/carbon/human/H = src
			if((istype(turf,/turf/open/floor)) && (src.lastarea.has_gravity == 0) && !(istype(H.shoes, /obj/item/clothing/shoes/magboots) && (H.shoes.flags_inventory & NOSLIPPING)))
				continue


		else
			if((istype(turf,/turf/open/floor)) && (src.lastarea && src.lastarea.has_gravity == 0)) // No one else gets a chance.
				continue



		/*
		if(istype(turf,/turf/open/floor) && (src.flags & NOGRAV))
			continue
		*/


		dense_object++
		break

	if(!dense_object && (locate(/obj/structure/lattice) in oview(1, src)))
		dense_object++

	//Lastly attempt to locate any dense objects we could push off of
	//TODO: If we implement objects drifing in space this needs to really push them
	//Due to a few issues only anchored and dense objects will now work.
	if(!dense_object)
		for(var/obj/O in oview(1, src))
			if((O) && (O.density) && (O.anchored))
				dense_object++
				break

	return dense_object


/mob/proc/Process_Spaceslipping(var/prob_slip = 5)
	//Setup slipage
	//If knocked out we might just hit it and stop.  This makes it possible to get dead bodies and such.
	if(stat)
		prob_slip = 0  // Changing this to zero to make it line up with the comment.

	prob_slip = round(prob_slip)
	return(prob_slip)
