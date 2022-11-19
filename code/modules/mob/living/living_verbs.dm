/mob/living/verb/resist()
	set name = "Resist"
	set category = "IC"

	do_resist()


/mob/living/proc/lay_down()
	set name = "Rest"
	set category = "IC"

	if(!resting)
		if(is_ventcrawling)
			return FALSE
		set_resting(TRUE, FALSE)
	else if(do_actions)
		to_chat(src, span_warning("You are still in the process of standing up."))
		return
	else if(do_mob(src, src, 2 SECONDS, ignore_flags = (IGNORE_LOC_CHANGE|IGNORE_HAND)))
		get_up()

/mob/living/proc/get_up()
	set_resting(FALSE, FALSE)

/mob/living/proc/set_resting(rest, silent = TRUE)
	if(status_flags & INCORPOREAL)
		return
	if(rest == resting)
		return
	. = resting
	resting = rest
	if(resting)
		ADD_TRAIT(src, TRAIT_FLOORED, RESTING_TRAIT)
		if(!silent)
			to_chat(src, span_notice("You are now resting."))
		SEND_SIGNAL(src, COMSIG_XENOMORPH_REST)
	else
		REMOVE_TRAIT(src, TRAIT_FLOORED, RESTING_TRAIT)
		if(!silent)
			to_chat(src, span_notice("You get up."))
		SEND_SIGNAL(src, COMSIG_XENOMORPH_UNREST)
	update_resting()


/mob/living/proc/update_resting()
	hud_used?.rest_icon?.update_icon(src)


/mob/living/verb/ghost()
	set category = "OOC"
	set name = "Ghost"

	if(stat == DEAD)
		ghostize(TRUE)
		return

	if(tgui_alert(src, "Are you sure you want to ghost?\n(You are alive. If you ghost, you won't be able to return to your body. You can't change your mind so choose wisely!)", "Ghost", list("Yes", "No")) != "Yes")
		return

	set_resting(TRUE)
	log_game("[key_name(usr)] has ghosted at [AREACOORD(usr)].")
	message_admins("[ADMIN_TPMONTY(usr)] has ghosted.")
	ghostize(FALSE)

/mob/living/verb/point_to(atom/A)
	set name = "Point To"
	set category = "Object"

	if(!isturf(loc))
		return FALSE

	if(!A.mouse_opacity) //Can't click it? can't point at it.
		return FALSE

	if(incapacitated() || HAS_TRAIT(src, TRAIT_FAKEDEATH)) //Incapacitated, can't point.
		return FALSE

	var/tile = get_turf(A)
	if(!tile)
		return FALSE

	if(next_move > world.time)
		return FALSE

	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_POINT))
		return FALSE

	next_move = world.time + 2

	point_to_atom(A, tile)
	return TRUE
