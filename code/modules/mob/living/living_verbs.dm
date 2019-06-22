/mob/living/verb/resist()
	set name = "Resist"
	set category = "IC"
	
	if(next_move > world.time)
		return

	do_resist()


/mob/living/proc/lay_down()
	set name = "Rest"
	set category = "IC"

	if(incapacitated(TRUE))
		return

	if(!resting)
		if(is_ventcrawling)
			return FALSE
		set_resting(TRUE, FALSE)
	else if(action_busy)
		to_chat(src, "<span class='warning'>You are still in the process of standing up.</span>")
		return
	else if(do_mob(src, src, 2 SECONDS, uninterruptible = TRUE))
		get_up()

/mob/living/proc/get_up()
	if(!incapacitated(TRUE))
		set_resting(FALSE, FALSE)
	else
		to_chat(src, "<span class='notice'>You fail to get up.</span>")

/mob/living/proc/set_resting(rest, silent = TRUE)
	if(!silent)
		if(rest)
			to_chat(src, "<span class='notice'>You are now resting.</span>")
		else
			to_chat(src, "<span class='notice'>You get up.</span>")
	resting = rest
	update_resting()

/mob/living/proc/update_resting()
	hud_used?.rest_icon?.update_icon(src)
	update_canmove()

/mob/living/verb/ghost()
	set category = "OOC"
	set name = "Ghost"

	if(stat == DEAD)
		ghostize(TRUE)
		return

	if(alert(src, "Are you -sure- you want to ghost?\n(You are alive. If you ghost, you won't be able to return to your body. You can't change your mind so choose wisely!)", "Are you sure you want to ghost?", "Ghost", "Stay in body") != "Ghost")
		return

	set_resting(TRUE)
	log_game("[key_name(usr)] has ghosted.")
	message_admins("[ADMIN_TPMONTY(usr)] has ghosted.")
	var/mob/dead/observer/ghost = ghostize(FALSE)
	if(ghost)
		ghost.timeofdeath = world.time


/mob/living/verb/point_to(atom/A in view(client.view + client.get_offset(), loc))
	set name = "Point To"
	set category = "Object"

	if(!isturf(loc))
		return FALSE

	if(!(A in view(client.view + client.get_offset(), loc))) //Target is no longer visible to us.
		return FALSE

	if(!A.mouse_opacity) //Can't click it? can't point at it.
		return FALSE

	if(incapacitated() || (status_flags & FAKEDEATH)) //Incapacitated, can't point.
		return FALSE

	var/tile = get_turf(A)
	if(!tile)
		return FALSE

	if(next_move > world.time)
		return FALSE

	if(recently_pointed_to > world.time)
		return FALSE

	next_move = world.time + 2

	point_to_atom(A, tile)
	return TRUE