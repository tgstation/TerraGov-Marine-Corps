//supposedly the fastest way to do this according to https://gist.github.com/Giacom/be635398926bb463b42a
#define RANGE_TURFS(RADIUS, CENTER) \
	block( \
		locate(max(CENTER.x-(RADIUS),1),          max(CENTER.y-(RADIUS),1),          CENTER.z), \
		locate(min(CENTER.x+(RADIUS),world.maxx), min(CENTER.y+(RADIUS),world.maxy), CENTER.z) \
	)

/proc/get_area_name(atom/X, format_text = FALSE)
	var/area/A = isarea(X) ? X : get_area(X)
	if(!A)
		return
	return format_text ? format_text(A.name) : A.name


/proc/get_adjacent_open_turfs(atom/center)
	. = list()
	for(var/i in GLOB.cardinals)
		var/turf/open/T = get_step(center, i)
		if(!istype(T))
			continue
		. += T

/**
 * Get a bounding box of a list of atoms.
 *
 * Arguments:
 * - atoms - List of atoms. Can accept output of view() and range() procs.
 *
 * Returns: list(x1, y1, x2, y2)
 */
/proc/get_bbox_of_atoms(list/atoms)
	var/list/list_x = list()
	var/list/list_y = list()
	for(var/_a in atoms)
		var/atom/a = _a
		list_x += a.x
		list_y += a.y
	return list(
		min(list_x),
		min(list_y),
		max(list_x),
		max(list_y))


/proc/trange(rad = 0, turf/centre = null) //alternative to range (ONLY processes turfs and thus less intensive)
	if(!centre)
		return

	var/turf/x1y1 = locate(((centre.x - rad) < 1 ? 1 : centre.x - rad), ((centre.y-rad) < 1 ? 1 : centre.y - rad), centre.z)
	var/turf/x2y2 = locate(((centre.x + rad) > world.maxx ? world.maxx : centre.x + rad), ((centre.y + rad) > world.maxy ? world.maxy : centre.y + rad), centre.z)
	return block(x1y1, x2y2)


/proc/get_mobs_in_radio_ranges(list/obj/item/radio/radios)
	set background = TRUE

	. = list()
	// Returns a list of mobs who can hear any of the radios given in @radios
	var/list/speaker_coverage = list()
	for(var/obj/item/radio/R in radios)
		if(!R)
			continue

		var/turf/speaker = get_turf(R)
		if(!speaker)
			continue

		for(var/turf/T in get_hear(R.canhear_range,speaker))
			speaker_coverage[T] = T


	// Try to find all the players who can hear the message
	for(var/i = 1; i <= GLOB.player_list.len; i++)
		var/mob/M = GLOB.player_list[i]
		if(M)
			var/turf/ear = get_turf(M)
			if(ear)
				// Ghostship is magic: Ghosts can hear radio chatter from anywhere
				if(speaker_coverage[ear] || (isobserver(M) && M.client?.prefs?.toggles_chat & CHAT_GHOSTRADIO))
					. |= M		// Since we're already looping through mobs, why bother using |= ? This only slows things down.


// Same as above but for alien candidates.
/proc/get_alien_candidate()
	var/mob/dead/observer/picked

	for(var/i in GLOB.observer_list)
		var/mob/dead/observer/O = i
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
		if(O.mind?.current && isclientedaghost(O.mind.current))
			continue

		if(!picked)
			picked = O
			continue

		if(GLOB.key_to_time_of_death[O.key] < GLOB.key_to_time_of_death[picked.key])
			picked = O

	return picked


/proc/convert_k2c(temp)
	return ((temp - T0C))


/// Removes an image from a client's `.images`. Useful as a callback.
/proc/remove_image_from_client(image/image, client/remove_from)
	remove_from?.images -= image

/proc/remove_images_from_clients(image/I, list/show_to)
	for(var/client/C in show_to)
		C.images -= I


/proc/flick_overlay(image/I, list/show_to, duration)
	for(var/client/C in show_to)
		C.images += I
	addtimer(CALLBACK(GLOBAL_PROC, /proc/remove_images_from_clients, I, show_to), duration, TIMER_CLIENT_TIME)


/proc/flick_overlay_view(image/I, atom/target, duration) //wrapper for the above, flicks to everyone who can see the target atom
	var/list/viewing = list()
	for(var/m in viewers(target))
		var/mob/M = m
		if(M.client)
			viewing += M.client
	flick_overlay(I, viewing, duration)


/proc/window_flash(client/C, ignorepref = FALSE)
	if(ismob(C))
		var/mob/M = C
		C = M.client
	if(!C?.prefs.windowflashing && !ignorepref)
		return
	winset(C, "mainwindow", "flash=5")


// Like view but bypasses luminosity check
/proc/get_hear(range, atom/source)
	var/lum = source.luminosity
	source.luminosity = 6

	. = view(range, source)
	source.luminosity = lum

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
