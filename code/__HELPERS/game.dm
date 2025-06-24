/proc/get_area_name(atom/X, format_text = FALSE)
	var/area/A = isarea(X) ? X : get_area(X)
	if(!A)
		return
	return format_text ? format_text(A.name) : A.name


/// Checks all conditions if a spot is valid for construction , will return TRUE
/proc/is_valid_for_resin_structure(turf/target, needs_support = FALSE, planned_building)
	if(!target || !istype(target))
		return ERROR_JUST_NO
	if(ispath(planned_building, /turf/closed/wall/resin) && istype(target, /turf/closed/wall/resin))
		if(planned_building != target.type)
			return NO_ERROR
	var/obj/alien/weeds/alien_weeds = locate() in target
	if(!target.check_disallow_alien_fortification(null, TRUE))
		return ERROR_NOT_ALLOWED
	if(!alien_weeds)
		return ERROR_NO_WEED
	if(!target.is_weedable())
		return ERROR_CANT_WEED
	for(var/obj/effect/forcefield/fog/F in range(1, target))
		return ERROR_FOG
	for(var/mob/living/carbon/xenomorph/blocker in target)
		if(blocker.stat != DEAD && !CHECK_BITFIELD(blocker.xeno_caste.caste_flags, CASTE_IS_BUILDER))
			return ERROR_BLOCKER
	if(!target.check_alien_construction(null, TRUE, planned_building))
		return ERROR_CONSTRUCT
	if(needs_support)
		for(var/D in GLOB.cardinals)
			var/turf/TS = get_step(target,D)
			if(!TS)
				continue
			if(TS.density || locate(/obj/structure/mineral_door/resin) in TS)
				return NO_ERROR
		return ERROR_NO_SUPPORT
	return NO_ERROR

// Same as above but for alien candidates.
/proc/get_alien_candidate()
	var/mob/dead/observer/picked

	for(var/mob/dead/observer/O AS in GLOB.observer_list)
		//Players without preferences or jobbaned players cannot be drafted.
		if(!O.key || !O.mind || !O.client?.prefs || !(O.client.prefs.be_special & (BE_ALIEN|BE_ALIEN_UNREVIVABLE)) || is_banned_from(O.ckey, ROLE_XENOMORPH))
			continue

		if(O.client.prefs.be_special & BE_ALIEN_UNREVIVABLE && !(O.client.prefs.be_special & BE_ALIEN) && ishuman(O.mind.current))
			var/mob/living/carbon/human/H = O.mind.current
			if(!HAS_TRAIT(H, TRAIT_UNDEFIBBABLE ))
				continue

		//AFK players cannot be drafted
		if(O.client.inactivity / 600 > ALIEN_SELECT_AFK_BUFFER + 5)
			continue

		//Aghosted admins don't get picked
		if(isaghost(O))
			continue

		if(!picked)
			picked = O
			continue

		if(GLOB.key_to_time_of_role_death[O.key] < GLOB.key_to_time_of_role_death[picked.key])
			picked = O

	return picked


/proc/convert_k2c(temp)
	return ((temp - T0C))


/// Removes an image from a client's `.images`. Useful as a callback.
/proc/remove_image_from_client(image/image, client/remove_from)
	remove_from?.images -= image

///Removes an image from a list of client's images
/proc/remove_images_from_clients(image/image, list/show_to)
	for(var/client/client AS in show_to)
		client?.images -= image

/proc/flick_overlay(image/I, list/show_to, duration)
	for(var/client/C AS in show_to)
		C.images += I
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(remove_images_from_clients), I, show_to), duration, TIMER_CLIENT_TIME)

///wrapper for flick_overlay(), flicks to everyone who can see the target atom
/proc/flick_overlay_view(image/image_to_show, atom/target, duration)
	var/list/viewing = list()
	for(var/mob/viewer AS in viewers(target))
		if(viewer.client)
			viewing += viewer.client
	flick_overlay(image_to_show, viewing, duration)


/proc/window_flash(client/C, ignorepref = FALSE)
	if(ismob(C))
		var/mob/M = C
		C = M.client
	if(!C?.prefs.windowflashing && !ignorepref)
		return
	winset(C, "mainwindow", "flash=5")

/proc/get_active_player_count(alive_check = FALSE, afk_check = FALSE, faction_check = FALSE, faction = FACTION_NEUTRAL)
	// Get active players who are playing in the round
	var/active_players = 0
	for(var/mob/M  in GLOB.player_list)
		if(!M?.client)
			continue
		if(alive_check && M.stat == DEAD)
			continue
		else if(afk_check && M.client.is_afk())
			continue
		else if(faction_check)
			if(faction != M.faction)
				continue
		else if(isnewplayer(M)) // exclude people in the lobby
			continue
		else if(isobserver(M)) // Ghosts are fine if they were playing once (didn't start as observers)
			var/mob/dead/observer/O = M
			if(O.started_as_observer) // Exclude people who started as observers
				continue
		active_players++
	return active_players

/proc/considered_alive(datum/mind/M, enforce_human = TRUE)
	if(M?.current)
		if(enforce_human)
			return M.current.stat != DEAD && !issilicon(M.current) && !isbrain(M.current)
		else if(isliving(M.current))
			return M.current.stat != DEAD
	return FALSE
