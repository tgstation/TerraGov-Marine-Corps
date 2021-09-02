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
	else if(do_actions)
		to_chat(src, span_warning("You are still in the process of standing up."))
		return
	else if(do_mob(src, src, 2 SECONDS, ignore_flags = (IGNORE_LOC_CHANGE|IGNORE_HAND)))
		get_up()

/mob/living/proc/get_up()
	if(!incapacitated(TRUE))
		set_resting(FALSE, FALSE)
	else
		to_chat(src, span_notice("You fail to get up."))

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
	else
		REMOVE_TRAIT(src, TRAIT_FLOORED, RESTING_TRAIT)
		if(!silent)
			to_chat(src, span_notice("You get up."))
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

/mob/living/verb/take_ssd_mob
	set category = "OOC"
	set name = "Try to take SSD mob"

	var/list/mob/living/free_ssd_mobs = list()
	for(var/mob/living/ssd_mob AS in GLOB.ssd_living_mobs)
		if(is_centcom_level(ssd_mob.z))
			continue
		if(ssd_mob.afk_status == MOB_RECENTLY_DISCONNECTED)
			continue
		free_ssd_mobs += ssd_mob

	if(!free_ssd_mobs.len)
		to_chat(src, span_warning("There aren't any available already living xenomorphs. You can try waiting for a larva to burst if you have the preference enabled."))
		return FALSE

	var/mob/living/new_mob = tgui_input_list(src, null, "Available Mobs", free_ssd_mobs)
	if(!istype(new_mob) || !client)
		return FALSE

	if(new_mob.stat == DEAD)
		to_chat(src, span_warning("You cannot join if the mob is dead."))
		return FALSE

	if(new_mob.client)
		to_chat(src, span_warning("That mob has been occupied."))
		return FALSE

	if(new_mob.afk_status == MOB_RECENTLY_DISCONNECTED) //We do not want to occupy them if they've only been gone for a little bit.
		to_chat(src, span_warning("That player hasn't been away long enough. Please wait [round(timeleft(new_mob.afk_timer_id) * 0.1)] second\s longer."))
		return FALSE

	if(is_banned_from(ckey, new_mob?.job.title))
		to_chat(src, span_warning("You are jobbaned from the [new_mob?.job.title] role."))
		return

	transfer_mob(new_mob)

/mob/living/verb/point_to(atom/A in view(client.view, loc))
	set name = "Point To"
	set category = "Object"

	if(!isturf(loc))
		return FALSE

	if(!(A in view(client.view, loc))) //Target is no longer visible to us.
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
