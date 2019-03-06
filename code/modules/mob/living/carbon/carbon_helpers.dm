/mob/living/carbon/can_use_hands()
	if(handcuffed)
		return FALSE
	if(buckled && ! istype(buckled, /obj/structure/bed/chair)) // buckling does not restrict hands
		return FALSE
	return TRUE


/mob/living/carbon/is_mob_restrained()
	if(handcuffed)
		return TRUE
	return FALSE

/mob/living/carbon/proc/need_breathe()
	if(reagents.has_reagent("lexorin") || in_stasis)
		return FALSE
	return TRUE

/mob/living/carbon/proc/do_after(mob/living/carbon/user, delay, needhand = TRUE, numticks = 5, show_busy_icon, selected_zone_check, busy_check = FALSE, stagger_check = TRUE)
	if(!istype(user) || delay <= 0)
		return FALSE

	if(busy_check && user.action_busy)
		to_chat(user, "<span class='warning'>You're already busy doing something!</span>")
		return FALSE

	if(stagger_check && stagger)
		to_chat(user, "<span class='warning'>You can't perform this action while staggered!</span>")
		return FALSE

	var/image/busy_icon
	if(show_busy_icon)
		busy_icon = get_busy_icon(show_busy_icon)
		if(busy_icon)
			user.overlays += busy_icon

	user.action_busy = TRUE

	var/cur_zone_sel
	if(selected_zone_check)
		cur_zone_sel = user.zone_selected

	var/original_loc = user.loc
	var/original_turf = get_turf(user)
	var/obj/holding = user.get_active_held_item()

	. = TRUE
	var/endtime = world.time + delay
	while(world.time < endtime)
		stoplag(1)
		if(!user || user.loc != original_loc || get_turf(user) != original_turf || user.stat || user.knocked_down || user.stunned)
			. = FALSE
			break
		if(user?.health && user.health < user.get_crit_threshold())
			. = FALSE //catching mobs below crit level but haven't had their stat var updated
			break
		if(needhand)
			if(holding)
				if(!holding.loc || user.get_active_held_item() != holding) //no longer holding the required item
					. = FALSE
					break
			else if(user.get_active_held_item()) //something in active hand when we need it to stay empty
				. = FALSE
				break

		if(selected_zone_check && cur_zone_sel != user.zone_selected) //changed the selected zone
			. = FALSE
			break

	if(user && busy_icon)
		user.overlays -= busy_icon

	user.action_busy = FALSE