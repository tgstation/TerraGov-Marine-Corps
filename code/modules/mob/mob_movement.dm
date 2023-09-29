/mob/CanAllowThrough(atom/movable/mover, turf/target)
	if(mover.pass_flags & PASS_MOB)
		return TRUE
	if(..())
		return TRUE
	if(lying_angle)
		return TRUE
	if(mover.throwing && !(allow_pass_flags & PASS_THROW))
		return FALSE
	if(!mover.density)
		return TRUE

/client/verb/swap_hand()
	set hidden = 1
	if(iscarbon(mob))
		mob:swap_hand()



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
	if(!mob?.control_object)
		return

	if(mob.control_object.density)
		step(mob.control_object, direct)
		if(!mob.control_object)
			return
		mob.control_object.setDir(direct)
	else
		mob.control_object.forceMove(get_step(mob.control_object, direct))

#define MOVEMENT_DELAY_BUFFER 0.75
#define MOVEMENT_DELAY_BUFFER_DELTA 1.25

/client/Move(n, direct)
	if(world.time < move_delay) //do not move anything ahead of this check please
		return FALSE
	else
		next_move_dir_add = 0
		next_move_dir_sub = 0
	var/old_move_delay = move_delay
	move_delay = world.time + world.tick_lag //this is here because Move() can now be called mutiple times per tick
	if(!mob?.loc)
		return FALSE
	if(!n || !direct)
		return FALSE
	if(mob.notransform)
		return FALSE	//This is sota the goto stop mobs from moving var
	if(mob.control_object)
		return Move_object(direct)
	if(!isliving(mob))
		return mob.Move(n, direct)
	if(mob.stat == DEAD && !HAS_TRAIT(mob, TRAIT_IS_RESURRECTING))
		mob.ghostize()
		return FALSE

	var/mob/living/L = mob  //Already checked for isliving earlier

	if(L.remote_control) //we're controlling something, our movement is relayed to it
		return L.remote_control.relaymove(L, direct)

	if(isAI(L))
		return AIMove(n, direct, L)

	//Check if you are being grabbed and if so attemps to break it
	if(SEND_SIGNAL(L, COMSIG_LIVING_DO_MOVE_RESIST) & COMSIG_LIVING_RESIST_SUCCESSFUL)
		return

	if(L.pulledby)
		if(L.incapacitated(TRUE))
			return
		else if(L.restrained(RESTRAINED_NECKGRAB))
			move_delay = world.time + 1 SECONDS //to reduce the spam
			to_chat(src, span_warning("You're restrained! You can't move!"))
			return
		else
			move_delay = world.time + 1 SECONDS
			return L.do_move_resist_grab()

	if(L.buckled)
		return L.buckled.relaymove(L, direct)

	if(!L.canmove)
		return

	if(isobj(L.loc) || ismob(L.loc))//Inside an object, tell it we moved
		var/atom/O = L.loc
		return O.relaymove(L, direct)

	var/add_delay = mob.cached_multiplicative_slowdown + mob.next_move_slowdown
	mob.next_move_slowdown = 0
	if(old_move_delay + (add_delay * MOVEMENT_DELAY_BUFFER_DELTA) + MOVEMENT_DELAY_BUFFER > world.time)
		move_delay = old_move_delay
	else
		move_delay = world.time

	L.last_move_intent = world.time + 1 SECONDS

	if(L.IsConfused())
		var/newdir = 0
		if(L.AmountConfused() > 40)
			newdir = pick(GLOB.alldirs)
		else if(prob(L.AmountConfused() * 1.5))
			newdir = angle2dir(dir2angle(direct) + pick(90, -90))
		else if(prob(L.AmountConfused() * 3))
			newdir = angle2dir(dir2angle(direct) + pick(45, -45))
		if(newdir)
			direct = newdir
			n = get_step(L, direct)

	. = ..()

	if((direct & (direct - 1)) && mob.loc == n) //moved diagonally successfully
		add_delay *= DIAG_MOVEMENT_ADDED_DELAY_MULTIPLIER
	move_delay += add_delay

#undef MOVEMENT_DELAY_BUFFER
#undef MOVEMENT_DELAY_BUFFER_DELTA

///Process_Spacemove
///Called by /client/Move()
///For moving in space
///Return 1 for movement 0 for none
/mob/proc/Process_Spacemove(check_drift = 0)

	if(!Check_Dense_Object()) //Nothing to push off of so end here
		return 0

	if(restrained()) //Check to see if we can do things
		return 0

	//Check to see if we slipped
	if(prob(Process_Spaceslipping(5)))
		to_chat(src, span_boldnotice("You slipped!"))
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
			if((istype(turf,/turf/open/floor)) && !(istype(H.shoes, /obj/item/clothing/shoes/magboots) && (H.shoes.flags_inventory & NOSLIPPING)))
				continue


		else
			if(istype(turf,/turf/open/floor)) // No one else gets a chance.
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


/mob/proc/Process_Spaceslipping(prob_slip = 5)
	//Setup slipage
	//If knocked out we might just hit it and stop.  This makes it possible to get dead bodies and such.
	if(stat)
		prob_slip = 0  // Changing this to zero to make it line up with the comment.

	prob_slip = round(prob_slip)
	return(prob_slip)


/client/proc/check_has_body_select()
	return mob?.hud_used?.zone_sel && istype(mob.hud_used.zone_sel, /atom/movable/screen/zone_sel)


/client/verb/body_toggle_head()
	set name = "body-toggle-head"
	set hidden = TRUE

	if(!check_has_body_select())
		return

	var/next_in_line
	switch(mob.zone_selected)
		if(BODY_ZONE_HEAD)
			next_in_line = BODY_ZONE_PRECISE_EYES
		if(BODY_ZONE_PRECISE_EYES)
			next_in_line = BODY_ZONE_PRECISE_MOUTH
		else
			next_in_line = BODY_ZONE_HEAD

	var/atom/movable/screen/zone_sel/selector = mob.hud_used.zone_sel
	selector.set_selected_zone(next_in_line, mob)


/client/verb/body_r_arm()
	set name = "body-r-arm"
	set hidden = TRUE

	if(!check_has_body_select())
		return

	var/next_in_line
	switch(mob.zone_selected)
		if(BODY_ZONE_R_ARM)
			next_in_line = BODY_ZONE_PRECISE_R_HAND
		else
			next_in_line = BODY_ZONE_R_ARM

	var/atom/movable/screen/zone_sel/selector = mob.hud_used.zone_sel
	selector.set_selected_zone(next_in_line, mob)


/client/verb/body_chest()
	set name = "body-chest"
	set hidden = TRUE

	if(!check_has_body_select())
		return

	var/atom/movable/screen/zone_sel/selector = mob.hud_used.zone_sel
	selector.set_selected_zone(BODY_ZONE_CHEST, mob)


/client/verb/body_l_arm()
	set name = "body-l-arm"
	set hidden = TRUE

	if(!check_has_body_select())
		return

	var/next_in_line
	switch(mob.zone_selected)
		if(BODY_ZONE_L_ARM)
			next_in_line = BODY_ZONE_PRECISE_L_HAND
		else
			next_in_line = BODY_ZONE_L_ARM

	var/atom/movable/screen/zone_sel/selector = mob.hud_used.zone_sel
	selector.set_selected_zone(next_in_line, mob)


/client/verb/body_r_leg()
	set name = "body-r-leg"
	set hidden = TRUE

	if(!check_has_body_select())
		return

	var/next_in_line
	switch(mob.zone_selected)
		if(BODY_ZONE_R_LEG)
			next_in_line = BODY_ZONE_PRECISE_R_FOOT
		else
			next_in_line = BODY_ZONE_R_LEG

	var/atom/movable/screen/zone_sel/selector = mob.hud_used.zone_sel
	selector.set_selected_zone(next_in_line, mob)


/client/verb/body_groin()
	set name = "body-groin"
	set hidden = TRUE

	if(!check_has_body_select())
		return

	var/atom/movable/screen/zone_sel/selector = mob.hud_used.zone_sel
	selector.set_selected_zone(BODY_ZONE_PRECISE_GROIN, mob)


/client/verb/body_l_leg()
	set name = "body-l-leg"
	set hidden = TRUE

	if(!check_has_body_select())
		return

	var/next_in_line
	switch(mob.zone_selected)
		if(BODY_ZONE_L_LEG)
			next_in_line = BODY_ZONE_PRECISE_L_FOOT
		else
			next_in_line = BODY_ZONE_L_LEG

	var/atom/movable/screen/zone_sel/selector = mob.hud_used.zone_sel
	selector.set_selected_zone(next_in_line, mob)


/mob/proc/toggle_move_intent(new_intent)
	if(!isnull(new_intent))
		if(new_intent == m_intent)
			return FALSE
		m_intent = new_intent
	else
		if(m_intent == MOVE_INTENT_RUN)
			m_intent = MOVE_INTENT_WALK
		else
			m_intent = MOVE_INTENT_RUN

	SEND_SIGNAL(src, COMSIG_MOB_TOGGLEMOVEINTENT, m_intent)

	if(hud_used?.static_inventory)
		for(var/atom/movable/screen/mov_intent/selector in hud_used.static_inventory)
			selector.update_icon(src)

	return TRUE


/mob/living/toggle_move_intent(new_intent)
	. = ..()
	if(!.)
		return
	update_move_intent_effects()


/mob/living/carbon/human/toggle_move_intent(new_intent)
	if((m_intent == MOVE_INTENT_WALK || new_intent == MOVE_INTENT_RUN) && (staminaloss >= 0 || (species.species_flags & NO_STAMINA)))
		return
	return ..()

/mob/living/carbon/xenomorph/hivemind/toggle_move_intent(new_intent)
	return

/mob/living/proc/update_move_intent_effects()
	if(status_flags & INCORPOREAL)
		return FALSE
	switch(m_intent)
		if(MOVE_INTENT_WALK)
			add_movespeed_modifier(MOVESPEED_ID_MOB_WALK_RUN_CONFIG_SPEED, TRUE, 100, NONE, TRUE, 4 + CONFIG_GET(number/movedelay/walk_delay))
		if(MOVE_INTENT_RUN)
			add_movespeed_modifier(MOVESPEED_ID_MOB_WALK_RUN_CONFIG_SPEED, TRUE, 100, NONE, TRUE, 3 + CONFIG_GET(number/movedelay/run_delay))

/mob/proc/cadecheck()
	var/list/coords = list(list(x + 1, y, z), list(x, y + 1, z), list(x - 1, y, z), list(x, y - 1, z))
	for(var/i in coords)
		var/list/L = i
		var/turf/T = locate(L[1], L[2], L[3])
		for(var/obj/structure/barricade/B in T.contents)
			return TRUE
	return FALSE
