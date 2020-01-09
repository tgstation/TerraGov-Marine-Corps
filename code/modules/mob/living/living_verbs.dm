/mob/living/verb/resist()
	set name = "Resist"
	set category = "IC"

	if(next_move > world.time)
		return

	do_resist()


/mob/living/proc/stand()
	set name = "Stand"
	set category = "IC"

	do_stand()

/mob/living/proc/do_stand()
	if(resting == STANDING)
		return
	set_resting(STANDING, silent = FALSE)


/mob/living/proc/crawl()
	set name = "Crawl"
	set category = "IC"

	do_crawl()

/mob/living/proc/do_crawl()
	if(resting == CRAWLING)
		return
	set_resting(CRAWLING, silent = FALSE)

/mob/living/carbon/xenomorph/do_crawl()
	if(!(xeno_caste.caste_flags & CASTE_CAN_CRAWL))
		to_chat(src, "<span class='warning'>This caste is unable to crawl.</span>")
		if(resting == CRAWLING)
			set_resting(STANDING, silent = FALSE)
		return
	return ..()


/mob/living/proc/lay_down()
	set name = "Lay Down"
	set category = "IC"
	if(resting == RESTING)
		return
	set_resting(RESTING, silent = FALSE)


/mob/living/proc/rest()
	set name = "Rest"
	set category = "IC"
	do_rest()

/mob/living/proc/do_rest()
	if(resting != STANDING)
		set_resting(STANDING, silent = FALSE)
	else
		set_resting(RESTING, silent = FALSE)

/mob/living/carbon/human/do_rest()
	if(resting != STANDING)
		set_resting(STANDING, silent = FALSE)
	else
		set_resting(CRAWLING, silent = FALSE)


/mob/living/verb/ghost()
	set category = "OOC"
	set name = "Ghost"

	if(stat == DEAD)
		ghostize(TRUE)
		return

	if(alert(src, "Are you sure you want to ghost?\n(You are alive. If you ghost, you won't be able to return to your body. You can't change your mind so choose wisely!)", "Ghost", "Yes", "No") != "Yes")
		return

	set_resting(RESTING)
	log_game("[key_name(usr)] has ghosted.")
	message_admins("[ADMIN_TPMONTY(usr)] has ghosted.")
	var/mob/dead/observer/ghost = ghostize(FALSE)
	if(ghost)
		ghost.timeofdeath = world.time


/mob/living/verb/point_to(atom/A in view(client.view, loc))
	set name = "Point To"
	set category = "Object"

	if(!isturf(loc))
		return FALSE

	if(!(A in view(client.view, loc))) //Target is no longer visible to us.
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

	if(cooldowns[COOLDOWN_POINT])
		return FALSE

	next_move = world.time + 2

	point_to_atom(A, tile)
	return TRUE
