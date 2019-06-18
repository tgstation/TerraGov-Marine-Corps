GLOBAL_LIST_EMPTY(ghost_images_default) //this is a list of the default (non-accessorized, non-dir) images of the ghosts themselves
GLOBAL_LIST_EMPTY(ghost_images_simple) //this is a list of all ghost images as the simple white ghost


GLOBAL_VAR_INIT(observer_default_invisibility, INVISIBILITY_OBSERVER)


/mob/dead/observer
	name = "ghost"
	desc = "It's a g-g-g-g-ghooooost!"
	icon = 'icons/mob/mob.dmi'
	icon_state = "ghost"
	layer = GHOST_LAYER
	stat = DEAD
	density = FALSE
	see_invisible = SEE_INVISIBLE_OBSERVER
	see_in_dark = 100
	invisibility = INVISIBILITY_OBSERVER
	sight = SEE_TURFS|SEE_MOBS|SEE_OBJS|SEE_SELF
	hud_type = /datum/hud/ghost
	var/lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE

	initial_language_holder = /datum/language_holder/universal
	var/atom/movable/following = null
	var/mob/observetarget = null	//The target mob that the ghost is observing. Used as a reference in logout()


	//We store copies of the ghost display preferences locally so they can be referred to even if no client is connected.
	//If there's a bug with changing your ghost settings, it's probably related to this.
	var/ghost_others = GHOST_OTHERS_DEFAULT_OPTION
	var/image/ghostimage_default = null //this mobs ghost image without accessories and dirs
	var/image/ghostimage_simple = null //this mob with the simple white ghost sprite

	var/updatedir = TRUE	//Do we have to update our dir as the ghost moves around?
	var/lastsetting = null	//Stores the last setting that ghost_others was set to, for a little more efficiency when we update ghost images. Null means no update is necessary

	var/inquisitive_ghost = FALSE
	var/can_reenter_corpse = FALSE
	var/started_as_observer //This variable is set to 1 when you enter the game as an observer.
							//If you died in the game and are a ghsot - this will remain as null.
							//Note that this is not a reliable way to determine if admins started as observers, since they change mobs a lot.

	var/ghost_medhud = FALSE
	var/ghost_sechud = FALSE
	var/ghost_squadhud = FALSE
	var/ghost_xenohud = FALSE
	var/ghost_orderhud = FALSE
	var/ghost_vision = TRUE
	var/ghost_orbit = GHOST_ORBIT_CIRCLE


/mob/dead/observer/Initialize()
	invisibility = GLOB.observer_default_invisibility

	if(icon_state in GLOB.ghost_forms_with_directions_list)
		ghostimage_default = image(icon, src, icon_state + "_nodir")
	else
		ghostimage_default = image(icon, src, icon_state)
	ghostimage_default.override = TRUE
	GLOB.ghost_images_default |= ghostimage_default

	ghostimage_simple = image(icon, src, "ghost_nodir")
	ghostimage_simple.override = TRUE
	GLOB.ghost_images_simple |= ghostimage_simple

	updateallghostimages()

	var/turf/T
	var/mob/body = loc
	if(ismob(body))
		T = get_turf(body)				//Where is the body located?

		gender = body.gender
		if(body.mind?.name)
			name = body.mind.name
		else
			if(body.real_name)
				name = body.real_name
			else
				name = random_unique_name(gender)

		mind = body.mind	//we don't transfer the mind but we keep a reference to it.

	update_icon()

	if(!T)
		T = pick(GLOB.latejoin)

	forceMove(T)

	if(!name)
		name = random_unique_name(gender)
	real_name = name

	animate(src, pixel_y = 2, time = 10, loop = -1)

	grant_all_languages()

	return ..()


/mob/dead/observer/Destroy()
	GLOB.ghost_images_default -= ghostimage_default
	QDEL_NULL(ghostimage_default)

	GLOB.ghost_images_simple -= ghostimage_simple
	QDEL_NULL(ghostimage_simple)

	updateallghostimages()

	return ..()


/mob/dead/observer/update_icon(new_form)
	if(client) //We update our preferences in case they changed right before update_icon was called.
		ghost_others = client.prefs.ghost_others

	if(new_form && started_as_observer)
		icon_state = new_form
		if(icon_state in GLOB.ghost_forms_with_directions_list)
			ghostimage_default.icon_state = new_form + "_nodir" //if this icon has dirs, the default ghostimage must use its nodir version or clients with the preference set to default sprites only will see the dirs
		else
			ghostimage_default.icon_state = new_form


/mob/dead/observer/sync_lighting_plane_alpha()
	if(!hud_used)
		return

	var/obj/screen/plane_master/lighting/L = hud_used.plane_masters["[LIGHTING_PLANE]"]
	if(!L)
		return

	L.alpha = lighting_alpha


/mob/dead/observer/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if(href_list["reentercorpse"])
		if(!isobserver(usr))
			return
		var/mob/dead/observer/A = usr
		A.reenter_corpse()


	else if(href_list["track"])
		var/mob/target = locate(href_list["track"]) in GLOB.mob_list
		if(istype(target))
			ManualFollow(target)
			return
		else
			var/atom/movable/AM = locate(href_list["track"])
			ManualFollow(AM)
			return


	else if(href_list["jump"])
		var/x = text2num(href_list["x"])
		var/y = text2num(href_list["y"])
		var/z = text2num(href_list["z"])

		if(x == 0 && y == 0 && z == 0)
			return

		var/turf/T = locate(x, y, z)
		if(!T)
			return

		var/mob/dead/observer/A = usr
		A.forceMove(T)
		return

	else if(href_list["claim"])
		var/mob/living/target = locate(href_list["claim"]) in GLOB.mob_list
		if(!istype(target))
			to_chat(usr, "<span class='warning'>Invalid target.</span>")
			return

		target.take_over(src)

	else if(href_list["join_ert"])
		if(!isobserver(usr))
			return
		var/mob/dead/observer/A = usr

		A.JoinResponseTeam()
		return

	else if(href_list["preference"])
		if(!client?.prefs)
			return
		client.prefs.process_link(src, href_list)


/mob/dead/CanPass(atom/movable/mover, turf/target)
	return TRUE


/mob/proc/ghostize(can_reenter_corpse = TRUE)
	if(!key || isaghost(src))
		return FALSE
	var/mob/dead/observer/ghost = new(src)
	var/turf/T = get_turf(src)

	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		ghost.icon = H.stand_icon
		ghost.overlays = H.overlays_standing
		ghost.underlays = H.underlays_standing
	else
		ghost.icon = icon
		ghost.icon_state = icon_state
		ghost.overlays = overlays

	ghost.gender = gender

	if(mind?.name)
		ghost.real_name = mind.name

	else if(real_name)
		ghost.real_name = real_name

	else if(gender == MALE)
		ghost.real_name = capitalize(pick(GLOB.first_names_male)) + " " + capitalize(pick(GLOB.last_names))

	else
		ghost.real_name = capitalize(pick(GLOB.first_names_female)) + " " + capitalize(pick(GLOB.last_names))

	ghost.name = ghost.real_name

	if(mind)
		ghost.mind = mind

	if(!T)
		T = pick(GLOB.latejoin)

	ghost.loc = T

	if(!name)
		ghost.name = capitalize(pick(GLOB.first_names_male)) + " " + capitalize(pick(GLOB.last_names))

	if(!can_reenter_corpse)
		set_away_time()
		ghost.mind?.current = ghost
		// if you ghost while alive your current mob is now your ghost
		// aghosting is invoked with can_reenter_corpse = TRUE so this won't mess with aghosting

	ghost.alpha = 127

	ghost.can_reenter_corpse = can_reenter_corpse
	ghost.timeofdeath = timeofdeath
	ghost.key = key

	return ghost


/mob/proc/set_away_time(new_away)
	return

/mob/living/set_away_time(new_away = world.time)
	away_time = new_away //Generic way to handle away time, currently unused.


/mob/living/carbon/xenomorph/set_away_time(new_away = -XENO_AFK_TIMER)
	away_time = new_away //Xenos who force-ghost can be immediately taken by observers.
	handle_afk_takeover()


/mob/dead/observer/Move(atom/newloc, direct)
	if(updatedir)
		setDir(direct)//only update dir if we actually need it, so overlays won't spin on base sprites that don't have directions of their own
	var/oldloc = loc

	if(newloc)
		forceMove(newloc)
	else
		forceMove(get_turf(src))  //Get out of closets and such as a ghost
		if((direct & NORTH) && y < world.maxy)
			y++
		else if((direct & SOUTH) && y > 1)
			y--
		if((direct & EAST) && x < world.maxx)
			x++
		else if((direct & WEST) && x > 1)
			x--

	Moved(oldloc, direct)


/mob/dead/observer/can_use_hands()
	return FALSE


/mob/dead/observer/Stat()
	. = ..()

	if(statpanel("Stats"))
		if(SSticker.current_state == GAME_STATE_PREGAME)
			stat("Time To Start:", "[SSticker.time_left > 0 ? SSticker.GetTimeLeft() : "(DELAYED)"]")
			stat("Players: [length(GLOB.player_list)]", "Players Ready: [GLOB.ready_players]")
			for(var/i in GLOB.player_list)
				if(isnewplayer(i))
					var/mob/new_player/N = i
					stat("[N.client?.holder?.fakekey ? N.client.holder.fakekey : N.key]", N.ready ? "Playing" : "")
				else if(isobserver(i))
					var/mob/dead/observer/O = i
					stat("[O.client?.holder?.fakekey ? O.client.holder.fakekey : O.key]", "Observing")
		var/eta_status = SSevacuation?.get_status_panel_eta()
		if(eta_status)
			stat("Evacuation in:", eta_status)
		if(SSticker?.mode)
			var/countdown = SSticker.mode.get_queen_countdown()
			if(countdown)
				stat("Queen Re-Check:", countdown)


/mob/dead/observer/verb/reenter_corpse()
	set category = "Ghost"
	set name = "Re-enter Corpse"

	if(!client)
		return FALSE

	if(!mind || QDELETED(mind.current))
		to_chat(src, "<span class='warning'>You have no body.</span>")
		return FALSE


	if(!can_reenter_corpse)
		to_chat(src, "<span class='warning'>You cannot re-enter your body.</span>")
		return FALSE

	if(mind.current.key && !isaghost(mind.current))
		to_chat(src, "<span class='warning'>Another consciousness is in your body...It is resisting you.</span>")
		return FALSE

	mind.transfer_to(mind.current, TRUE)
	return TRUE


/mob/dead/observer/verb/toggle_HUDs()
	set category = "Ghost"
	set name = "Toggle HUDs"
	set desc = "Toggles various HUDs."

	if(!client?.prefs)
		return

	var/hud_choice = input("Choose a HUD to toggle", "Toggle HUD") as null|anything in list("Medical HUD", "Security HUD", "Squad HUD", "Xeno Status HUD", "Order HUD")

	var/datum/atom_hud/H
	switch(hud_choice)
		if("Medical HUD")
			ghost_medhud = !ghost_medhud
			H = GLOB.huds[DATA_HUD_MEDICAL_OBSERVER]
			ghost_medhud ? H.add_hud_to(src) : H.remove_hud_from(src)
			client.prefs.ghost_hud ^= GHOST_HUD_MED
			client.prefs.save_preferences()
			to_chat(src, "<span class='boldnotice'>[hud_choice] [ghost_medhud ? "Enabled" : "Disabled"]</span>")
		if("Security HUD")
			ghost_sechud = !ghost_sechud
			H = GLOB.huds[DATA_HUD_SECURITY_ADVANCED]
			ghost_sechud ? H.add_hud_to(src) : H.remove_hud_from(src)
			client.prefs.ghost_hud ^= GHOST_HUD_SEC
			client.prefs.save_preferences()
			to_chat(src, "<span class='boldnotice'>[hud_choice] [ghost_sechud ? "Enabled": "Disabled"]</span>")
		if("Squad HUD")
			ghost_squadhud = !ghost_squadhud
			H = GLOB.huds[DATA_HUD_SQUAD]
			ghost_squadhud ? H.add_hud_to(src) : H.remove_hud_from(src)
			client.prefs.ghost_hud ^= GHOST_HUD_SQUAD
			client.prefs.save_preferences()
			to_chat(src, "<span class='boldnotice'>[hud_choice] [ghost_squadhud ? "Enabled": "Disabled"]</span>")
		if("Xeno Status HUD")
			ghost_xenohud = !ghost_xenohud
			H = GLOB.huds[DATA_HUD_XENO_STATUS]
			ghost_xenohud ? H.add_hud_to(src) : H.remove_hud_from(src)
			client.prefs.ghost_hud ^= GHOST_HUD_XENO
			client.prefs.save_preferences()
			to_chat(src, "<span class='boldnotice'>[hud_choice] [ghost_xenohud ? "Enabled" : "Disabled"]</span>")
		if("Order HUD")
			ghost_orderhud = !ghost_orderhud
			H = GLOB.huds[DATA_HUD_ORDER]
			ghost_orderhud ? H.add_hud_to(src) : H.remove_hud_from(src)
			client.prefs.ghost_hud ^= GHOST_HUD_ORDER
			client.prefs.save_preferences()
			to_chat(src, "<span class='boldnotice'>[hud_choice] [ghost_orderhud ? "Enabled" : "Disabled"]</span>")



/mob/dead/observer/verb/teleport(area/A in GLOB.sorted_areas)
	set category = "Ghost"
	set name = "Teleport"
	set desc = "Teleport to an area."

	if(!A)
		return

	loc = pick(get_area_turfs(A))


/mob/dead/observer/verb/follow_ghost()
	set category = "Ghost"
	set name = "Follow Ghost"

	var/list/observers = list()
	var/list/names = list()
	var/list/namecounts = list()

	for(var/mob/dead/observer/O in sortNames(GLOB.dead_mob_list))
		if(!O.client || !O.name)
			continue
		var/name = O.name
		if(name in names)
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1

		name += " (ghost)"

		observers[name] = O

	if(!length(observers))
		to_chat(usr, "<span class='warning'>There are no ghosts at the moment.</span>")
		return

	var/selected = input("Please select a Ghost:", "Follow Ghost") as null|anything in observers
	if(!selected)
		return

	var/mob/target = observers[selected]
	ManualFollow(target)


/mob/dead/observer/verb/follow_xeno()
	set category = "Ghost"
	set name = "Follow Xeno"

	var/admin = FALSE
	if(check_rights(R_ADMIN, FALSE))
		admin = TRUE

	var/list/xenos = list()
	var/list/names = list()
	var/list/namecounts = list()

	for(var/x in sortNames(GLOB.alive_xeno_list))
		var/mob/M = x
		var/name = M.name
		if(name in names)
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1

		if(M.client?.prefs?.xeno_name && M.client.prefs.xeno_name != "Undefined")
			name += " - [M.client.prefs.xeno_name]"

		if(admin)
			if(M.client && M.client.is_afk())
				name += " (AFK)"
			else if(!M.client && (M.key || M.ckey))
				name += " (DC)"

		xenos[name] = M

	if(!length(xenos))
		to_chat(usr, "<span class='warning'>There are no xenos at the moment.</span>")
		return


	var/selected = input("Please select a Xeno:", "Follow Xeno") as null|anything in xenos
	if(!selected)
		return

	var/mob/target = xenos[selected]
	ManualFollow(target)


/mob/dead/observer/verb/follow_human()
	set category = "Ghost"
	set name = "Follow Living Human"

	var/admin = FALSE
	if(check_rights(R_ADMIN, FALSE))
		admin = TRUE

	var/list/humans = list()
	var/list/names = list()
	var/list/namecounts = list()
	for(var/x in sortNames(GLOB.alive_human_list))
		var/mob/M = x
		if(!ishumanbasic(M) && !issynth(M) || istype(M, /mob/living/carbon/human/dummy) || !M.name)
			continue
		var/name = M.name
		if(name in names)
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1
		if(M.real_name && M.real_name != M.name)
			name += " as ([M.real_name])"
		if(issynth(M))
			name += " - Synth"
		if(admin)
			if(M.client && M.client.is_afk())
				name += " (AFK)"
			else if(!M.client && (M.key || M.ckey))
				if(isaghost(M))
					name += " (AGHOSTED)"
				else
					name += " (DC)"


		humans[name] = M

	if(!length(humans))
		to_chat(usr, "<span class='warning'>There are no living humans at the moment.</span>")
		return

	var/selected = input("Please select a Living Human:", "Follow Living Human") as null|anything in humans
	if(!selected)
		return

	var/mob/target = humans[selected]
	ManualFollow(target)


/mob/dead/observer/verb/follow_dead()
	set category = "Ghost"
	set name = "Follow Dead"

	var/list/dead = list()
	var/list/names = list()
	var/list/namecounts = list()

	for(var/x in sortNames(GLOB.dead_mob_list))
		var/mob/M = x
		if(isobserver(M) || isnewplayer(M) || !M.name)
			continue
		var/name = M.name
		if(name in names)
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1

		name += " (dead)"

		dead[name] = M

	if(!length(dead))
		to_chat(usr, "<span class='warning'>There are no dead mobs at the moment.</span>")
		return

	var/selected = input("Please select a Dead Mob:", "Follow Dead") as null|anything in dead
	if(!selected)
		return

	var/mob/target = dead[selected]
	ManualFollow(target)


/mob/dead/observer/verb/follow()
	set category = "Ghost"
	set name = "Follow"

	var/list/mobs = list()
	var/list/names = list()
	var/list/namecounts = list()

	for(var/x in sortNames(GLOB.mob_list - GLOB.dead_mob_list - GLOB.alive_xeno_list))
		var/mob/M = x
		if(isobserver(M) || isnewplayer(M) || ishumanbasic(M) || !M.name)
			continue
		var/name = M.name
		if(name in names)
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1

		mobs[name] = M

	if(!length(mobs))
		to_chat(usr, "<span class='warning'>There are no mobs at the moment.</span>")
		return

	var/selected = input("Please select a Mob:", "Follow Mob") as null|anything in mobs
	if(!selected)
		return

	var/mob/target = mobs[selected]
	ManualFollow(target)


/mob/dead/observer/verb/offered_mobs()
	set category = "Ghost"
	set name = "Take Offered Mob"

	if(!length(GLOB.offered_mob_list))
		to_chat(src, "<span class='warning'>There are currently no mobs being offered.</span>")
		return

	var/mob/living/L = input("Choose which mob you want to take over.", "Offered Mob") as null|anything in sortNames(GLOB.offered_mob_list)
	if(isnull(L))
		return

	if(!istype(L))
		to_chat(src, "<span class='warning'>Mob already taken.</span>")
		return

	switch(alert("Take over mob named: [L.real_name][L.job ? " | Job: [L.job]" : ""]", "Offered Mob", "Yes", "No", "Follow"))
		if("Yes")
			L.take_over(src)
		if("Follow")
			ManualFollow(L)


// This is the ghost's follow verb with an argument
/mob/dead/observer/proc/ManualFollow(atom/movable/target)
	if(!istype(target))
		return

	var/icon/I = icon(target.icon, target.icon_state, target.dir)

	var/orbitsize = (I.Width() + I.Height()) * 0.5
	orbitsize -= (orbitsize / world.icon_size) * (world.icon_size * 0.25)

	var/rot_seg

	switch(ghost_orbit)
		if(GHOST_ORBIT_TRIANGLE)
			rot_seg = 3
		if(GHOST_ORBIT_SQUARE)
			rot_seg = 4
		if(GHOST_ORBIT_PENTAGON)
			rot_seg = 5
		if(GHOST_ORBIT_HEXAGON)
			rot_seg = 6
		else //Circular
			rot_seg = 36

	orbit(target,orbitsize, FALSE, 20, rot_seg)


/mob/dead/observer/orbit()
	setDir(SOUTH)//reset dir so the right directional sprites show up
	return ..()


/mob/dead/observer/stop_orbit(datum/component/orbiter/orbits)
	. = ..()
	pixel_y = 0
	animate(src, pixel_y = 2, time = 10, loop = -1)


/mob/dead/observer/verb/analyze_air()
	set category = "Ghost"
	set name = "Analyze Air"

	if(!istype(loc, /turf))
		return

	var/turf/T = loc

	var/pressure = T.return_pressure()
	var/env_temperature = T.return_temperature()
	var/env_gas = T.return_gas()

	to_chat(src, "<span class='boldnotice'>Results:</span>")
	if(abs(pressure - ONE_ATMOSPHERE) < 10)
		to_chat(src, "<span class='notice'>Pressure: [round(pressure, 0.1)] kPa</span>")
	else
		to_chat(src, "<span class='warning'>Pressure: [round(pressure, 0.1)] kPa</span>")

	to_chat(src, "<span class='notice'>Gas type: [env_gas]</span>")
	to_chat(src, "<span class='notice'>Temperature: [round(env_temperature - T0C, 0.1)]&deg;C</span>")


/mob/dead/observer/verb/toggle_zoom()
	set category = "Ghost"
	set name = "Toggle Zoom"

	if(!client)
		return

	if(client.view != world.view)
		client.change_view(world.view)
	else
		client.change_view(14)


/mob/dead/observer/verb/toggle_darkness()
	set category = "Ghost"
	set name = "Toggle Darkness"

	switch(lighting_alpha)
		if(LIGHTING_PLANE_ALPHA_VISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
		if(LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
		if(LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
		else
			lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE

	update_sight()


/mob/dead/observer/verb/toggle_ghostsee()
	set category = "Ghost"
	set name = "Toggle Ghost Vision"
	set desc = "Toggles your ability to see things only ghosts can see, like other ghosts."

	ghost_vision = !ghost_vision
	update_sight()

	if(client?.prefs)
		client.prefs.ghost_vision = ghost_vision
		client.prefs.save_preferences()

	to_chat(src, "<span class='notice'>You [(ghost_vision ? "now" : "no longer")] have ghost vision.</span>")


/mob/dead/observer/update_sight()
	if(ghost_vision)
		see_invisible = SEE_INVISIBLE_OBSERVER
	else
		see_invisible = SEE_INVISIBLE_LIVING

	updateghostimages()

	return ..()


/proc/updateallghostimages()
	listclearnulls(GLOB.ghost_images_default)
	listclearnulls(GLOB.ghost_images_simple)

	for(var/mob/dead/observer/O in GLOB.player_list)
		O.updateghostimages()


/mob/dead/observer/proc/updateghostimages()
	if(!client)
		return

	if(lastsetting)
		switch(lastsetting) //checks the setting we last came from, for a little efficiency so we don't try to delete images from the client that it doesn't have anyway
			if(GHOST_OTHERS_DEFAULT_SPRITE)
				client.images -= GLOB.ghost_images_default
			if(GHOST_OTHERS_SIMPLE)
				client.images -= GLOB.ghost_images_simple
	lastsetting = client.prefs.ghost_others

	if(!ghost_vision)
		return

	if(client.prefs.ghost_others != GHOST_OTHERS_THEIR_SETTING)
		switch(client.prefs.ghost_others)
			if(GHOST_OTHERS_DEFAULT_SPRITE)
				client.images |= (GLOB.ghost_images_default - ghostimage_default)
			if(GHOST_OTHERS_SIMPLE)
				client.images |= (GLOB.ghost_images_simple - ghostimage_simple)



/mob/dead/observer/verb/hive_status()
	set category = "Ghost"
	set name = "Show Hive Status"
	set desc = "Check the status of the hive."

	check_hive_status()


/mob/dead/observer/verb/view_manifest()
	set category = "Ghost"
	set name = "View Crew Manifest"

	var/dat = GLOB.datacore.get_manifest()

	var/datum/browser/popup = new(src, "manifest", "<div align='center'>Crew Manifest</div>", 370, 420)
	popup.set_content(dat)
	popup.open(FALSE)


/mob/dead/verb/join_as_xeno()
	set category = "Ghost"
	set name = "Join as Xeno"
	set desc = "Select an alive but logged-out Xenomorph to rejoin the game."

	if(!client)
		return

	if(!SSticker?.mode || SSticker.current_state < GAME_STATE_PLAYING)
		to_chat(src, "<span class='warning'>The game hasn't started yet!</span>")
		return

	if(jobban_isbanned(src, ROLE_XENOMORPH) || is_banned_from(ckey, ROLE_XENOMORPH))
		to_chat(src, "<span class='warning'>You are jobbaned from the [ROLE_XENOMORPH] role.</span>")
		return

	var/choice = alert("Would you like to join as a larva or as a xeno?", "Join as Xeno", "Xeno", "Larva", "Cancel")
	switch(choice)
		if("Xeno")
			var/mob/new_xeno = SSticker.mode.attempt_to_join_as_xeno(src)
			if(new_xeno)
				SSticker.mode.transfer_xeno(src, new_xeno)
		if("Larva")
			if(!SSticker.mode.attempt_to_join_as_larva(src))
				return
			SSticker.mode.spawn_larva(src)


/mob/dead/observer/verb/observe()
	set name = "Observe"
	set category = "Ghost"

	reset_perspective(null)

	var/mob/target = input("Please select a mob:", "Observe", null, null) as null|anything in GLOB.mob_list
	if(!target)
		return

	if(!client)
		return

	client.eye = target

	if(!target.hud_used)
		return

	client.screen = list()
	LAZYINITLIST(target.observers)
	target.observers |= src
	target.hud_used.show_hud(target.hud_used.hud_version, src)
	observetarget = target


/mob/dead/observer/verb/dnr()
	set category = "Ghost"
	set name = "Do Not Revive"
	set desc = "Noone will be able to revive you."

	if(can_reenter_corpse && alert("Are you sure? You won't be able to get revived.", "Confirmation", "Yes", "No") == "Yes")
		can_reenter_corpse = FALSE
		to_chat(usr, "<span class='notice'>You can no longer be revived.</span>")
	else if(!can_reenter_corpse)
		to_chat(usr, "<span class='warning'>You already can't be revived.</span>")


/mob/dead/observer/verb/toggle_inquisition()
	set category = "Ghost"
	set name = "Toggle Inquisitiveness"
	set desc = "Sets whether your ghost examines everything on click by default"

	inquisitive_ghost = !inquisitive_ghost

	if(inquisitive_ghost)
		to_chat(src, "<span class='notice'>You will now examine everything you click on.</span>")
	else
		to_chat(src, "<span class='notice'>You will no longer examine things you click on.</span>")


/mob/dead/observer/reset_perspective(atom/A)
	if(client && ismob(client.eye) && client.eye != src)
		var/mob/target = client.eye
		observetarget = null
		if(target.observers)
			target.observers -= src
			UNSETEMPTY(target.observers)

	. = ..()

	if(!.)
		return

	if(!hud_used)
		return

	client.screen = list()
	hud_used.show_hud(hud_used.hud_version)


/mob/dead/observer/canUseTopic(atom/movable/AM, proximity = FALSE, dexterity = FALSE)
	return IsAdminGhost(usr)