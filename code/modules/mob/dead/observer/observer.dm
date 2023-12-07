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
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	dextrous = TRUE
	status_flags = GODMODE | INCORPOREAL

	initial_language_holder = /datum/language_holder/universal
	var/atom/movable/following = null
	var/datum/orbit_menu/orbit_menu
	var/mob/observetarget = null	//The target mob that the ghost is observing. Used as a reference in logout()


	//We store copies of the ghost display preferences locally so they can be referred to even if no client is connected.
	//If there's a bug with changing your ghost settings, it's probably related to this.
	var/ghost_others = GHOST_OTHERS_DEFAULT_OPTION
	var/image/ghostimage_default = null //this mobs ghost image without accessories and dirs
	var/image/ghostimage_simple = null //this mob with the simple white ghost sprite

	var/updatedir = TRUE	//Do we have to update our dir as the ghost moves around?
	var/lastsetting = null	//Stores the last setting that ghost_others was set to, for a little more efficiency when we update ghost images. Null means no update is necessary

	var/inquisitive_ghost = FALSE
	///A weakref to the original corpse of the observer
	var/datum/weakref/can_reenter_corpse
	var/started_as_observer //This variable is set to 1 when you enter the game as an observer.
							//If you died in the game and are a ghsot - this will remain as null.
							//Note that this is not a reliable way to determine if admins started as observers, since they change mobs a lot.

	var/ghost_medhud = FALSE
	var/ghost_sechud = FALSE
	var/ghost_squadhud = FALSE
	var/ghost_xenohud = FALSE
	var/ghost_orderhud = FALSE
	///If you can see things only ghosts see, like other ghosts
	var/ghost_vision = TRUE
	var/ghost_orbit = GHOST_ORBIT_CIRCLE

/mob/dead/observer/Initialize(mapload)
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

	abstract_move(T)

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

	QDEL_NULL(orbit_menu)
	GLOB.observer_list -= src //"wait isnt this done in logout?" Yes it is but because this is clients thats unreliable so we do it again here
	SSmobs.dead_players_by_zlevel[z] -= src

	return ..()

/mob/dead/observer/proc/observer_z_changed(datum/source, old_z, new_z)
	SIGNAL_HANDLER
	SSmobs.dead_players_by_zlevel[old_z] -= src
	SSmobs.dead_players_by_zlevel[new_z] += src

/mob/dead/observer/update_icon(new_form)
	if(client) //We update our preferences in case they changed right before update_icon was called.
		ghost_others = client.prefs.ghost_others

	if(new_form && started_as_observer)
		icon_state = new_form
		if(icon_state in GLOB.ghost_forms_with_directions_list)
			ghostimage_default.icon_state = new_form + "_nodir" //if this icon has dirs, the default ghostimage must use its nodir version or clients with the preference set to default sprites only will see the dirs
		else
			ghostimage_default.icon_state = new_form


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
		A.abstract_move(T)
		return

	else if(href_list["claim"])
		var/mob/living/target = locate(href_list["claim"]) in GLOB.offered_mob_list
		if(!istype(target))
			to_chat(usr, span_warning("Invalid target."))
			return

		target.take_over(src)

	else if(href_list["join_ert"])
		if(!isobserver(usr))
			return
		var/mob/dead/observer/A = usr

		A.JoinResponseTeam()
		return

	else if(href_list["join_larva"])
		if(!isobserver(usr))
			return
		var/mob/dead/observer/ghost = usr

		var/datum/hive_status/normal/HS = GLOB.hive_datums[XENO_HIVE_NORMAL]
		if(LAZYFIND(HS.candidates, ghost.client))
			to_chat(ghost, span_warning("You are already in the queue to become a Xenomorph."))
			return

		switch(tgui_alert(ghost, "What would you like to do?", "Burrowed larva source available", list("Join as Larva", "Cancel"), 0))
			if("Join as Larva")
				SSticker.mode.attempt_to_join_as_larva(ghost.client)
		return

	else if(href_list["preference"])
		if(!client?.prefs)
			return
		stack_trace("This code path is no longer valid, migrate this to new TGUI prefs")
		return

	else if(href_list["track_xeno_name"])
		var/xeno_name = href_list["track_xeno_name"]
		for(var/Y in GLOB.hive_datums[XENO_HIVE_NORMAL].get_all_xenos())
			var/mob/living/carbon/xenomorph/X = Y
			if(isnum(X.nicknumber))
				if(num2text(X.nicknumber) != xeno_name)
					continue
			else
				if(X.nicknumber != xeno_name)
					continue
			ManualFollow(X)
			break

	else if(href_list["track_silo_number"])
		var/silo_number = href_list["track_silo_number"]
		for(var/obj/structure/xeno/silo/resin_silo in GLOB.xeno_resin_silos_by_hive[XENO_HIVE_NORMAL])
			if(num2text(resin_silo.number_silo) == silo_number)
				var/mob/dead/observer/ghost = usr
				ghost.abstract_move(resin_silo.loc)
				break

/mob/proc/ghostize(can_reenter_corpse = TRUE, aghosting = FALSE)
	if(!key || isaghost(src))
		return FALSE
	SEND_SIGNAL(SSdcs, COMSIG_MOB_GHOSTIZE, src, can_reenter_corpse)
	var/mob/dead/observer/ghost = new(src)
	var/turf/T = get_turf(src)

	if(client)
		animate(client, pixel_x = 0, pixel_y = 0)

	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		ghost.icon = H.stand_icon
		ghost.overlays = H.overlays_standing
		ghost.underlays = H.underlays_standing
	else
		ghost.icon = icon
		ghost.icon_state = icon_state
		ghost.overlays = overlays

	if(mind?.name)
		ghost.real_name = mind.name
	else if(real_name)
		ghost.real_name = real_name
	else
		ghost.real_name = GLOB.namepool[/datum/namepool].get_random_name(gender)

	ghost.name = ghost.real_name
	ghost.gender = gender
	ghost.alpha = 127
	ghost.can_reenter_corpse = can_reenter_corpse ? WEAKREF(src) : null
	ghost.mind = mind
	mind = null
	ghost.key = key
	ghost.client?.init_verbs()
	ghost.mind?.current = ghost
	ghost.faction = faction

	if(!T)
		T = SAFEPICK(GLOB.latejoin)
	if(!T)
		stack_trace("no latejoin landmark detected")

	ghost.abstract_move(T)

	return ghost

/mob/living/ghostize(can_reenter_corpse = TRUE, aghosting = FALSE)
	if(aghosting)
		set_afk_status(MOB_AGHOSTED)
	reset_perspective()
	. = ..()
	if(!. || can_reenter_corpse)
		return
	var/mob/ghost = .
	GLOB.key_to_time_of_death[ghost.key] = world.time
	if(!aghosting && job?.job_flags & (JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE))//Only some jobs cost you your respawn timer.
		GLOB.key_to_time_of_role_death[ghost.key] = world.time

/mob/living/carbon/xenomorph/ghostize(can_reenter_corpse = TRUE, aghosting = FALSE)
	. = ..()
	if(!. || can_reenter_corpse || aghosting)
		return
	var/mob/ghost = .
	if(tier != XENO_TIER_MINION && hivenumber == XENO_HIVE_NORMAL)
		GLOB.key_to_time_of_xeno_death[ghost.key] = world.time //If you ghost as a xeno that is not a minion, sets respawn timer


/mob/dead/observer/Move(atom/newloc, direct)
	if(updatedir)
		setDir(direct)//only update dir if we actually need it, so overlays won't spin on base sprites that don't have directions of their own

	if(newloc)
		abstract_move(newloc)
		update_parallax_contents()
	else
		abstract_move(get_turf(src))  //Get out of closets and such as a ghost
		if((direct & NORTH) && y < world.maxy)
			y++
		else if((direct & SOUTH) && y > 1)
			y--
		if((direct & EAST) && x < world.maxx)
			x++
		else if((direct & WEST) && x > 1)
			x--



/mob/dead/observer/can_use_hands()
	return FALSE


/mob/dead/observer/get_status_tab_items()
	. = ..()

	if(SSticker.current_state == GAME_STATE_PREGAME)
		. += "Time To Start: [SSticker.time_left > 0 ? SSticker.GetTimeLeft() : "(DELAYED)"]"
		. += "Players: [length(GLOB.player_list)]"
		. += "Players Ready: [length(GLOB.ready_players)]"
		for(var/i in GLOB.player_list)
			if(isnewplayer(i))
				var/mob/new_player/N = i
				. += "[N.client?.holder?.fakekey ? N.client.holder.fakekey : N.key][N.ready ? " Playing" : ""]"
			else if(isobserver(i))
				var/mob/dead/observer/O = i
				. += "[O.client?.holder?.fakekey ? O.client.holder.fakekey : O.key] Observing"
	var/status_value = SSevacuation?.get_status_panel_eta()
	if(status_value)
		. += "Evacuation in: [status_value]"
	if(GLOB.respawn_allowed)
		status_value = (GLOB.key_to_time_of_role_death[key] + SSticker.mode?.respawn_time - world.time) * 0.1
		if(status_value <= 0)
			. += "Respawn timer: READY"
		else
			. += "Respawn timer: [(status_value / 60) % 60]:[add_leading(num2text(status_value % 60), 2, "0")]"

/mob/dead/observer/verb/reenter_corpse()
	set category = "Ghost"
	set name = "Re-enter Corpse"

	if(!client)
		return FALSE

	if(isnull(can_reenter_corpse))
		to_chat(src, span_warning("You cannot re-enter your body."))
		return FALSE

	var/mob/old_mob = can_reenter_corpse.resolve()

	if(!mind || QDELETED(old_mob))
		to_chat(src, span_warning("You have no body."))
		return FALSE

	if(old_mob.key)
		to_chat(src, span_warning("Another consciousness is in your body...It is resisting you."))
		return FALSE

	client.view_size.set_default(get_screen_size(client.prefs.widescreenpref))//Let's reset so people can't become allseeing gods
	mind.transfer_to(old_mob, TRUE)
	return TRUE

/mob/dead/observer/verb/toggle_HUDs()
	set category = "Ghost"
	set name = "Toggle HUDs"
	set desc = "Toggles various HUDs."

	if(!client?.prefs)
		return

	var/hud_choice = tgui_input_list(usr, "Choose a HUD to toggle", "Toggle HUD", list("Medical HUD", "Security HUD", "Squad HUD", "Xeno Status HUD", "Order HUD"))

	var/datum/atom_hud/H
	switch(hud_choice)
		if("Medical HUD")
			ghost_medhud = !ghost_medhud
			H = GLOB.huds[DATA_HUD_MEDICAL_OBSERVER]
			ghost_medhud ? H.add_hud_to(src) : H.remove_hud_from(src)
			client.prefs.ghost_hud ^= GHOST_HUD_MED
			client.prefs.save_preferences()
			to_chat(src, span_boldnotice("[hud_choice] [ghost_medhud ? "Enabled" : "Disabled"]"))
		if("Security HUD")
			ghost_sechud = !ghost_sechud
			H = GLOB.huds[DATA_HUD_SECURITY_ADVANCED]
			ghost_sechud ? H.add_hud_to(src) : H.remove_hud_from(src)
			client.prefs.ghost_hud ^= GHOST_HUD_SEC
			client.prefs.save_preferences()
			to_chat(src, span_boldnotice("[hud_choice] [ghost_sechud ? "Enabled": "Disabled"]"))
		if("Squad HUD")
			ghost_squadhud = !ghost_squadhud
			H = GLOB.huds[DATA_HUD_SQUAD_TERRAGOV]
			ghost_squadhud ? H.add_hud_to(src) : H.remove_hud_from(src)
			H = GLOB.huds[DATA_HUD_SQUAD_SOM]
			ghost_squadhud ? H.add_hud_to(src) : H.remove_hud_from(src)
			client.prefs.ghost_hud ^= GHOST_HUD_SQUAD
			client.prefs.save_preferences()
			to_chat(src, span_boldnotice("[hud_choice] [ghost_squadhud ? "Enabled": "Disabled"]"))
		if("Xeno Status HUD")
			ghost_xenohud = !ghost_xenohud
			H = GLOB.huds[DATA_HUD_XENO_STATUS]
			ghost_xenohud ? H.add_hud_to(src) : H.remove_hud_from(src)
			client.prefs.ghost_hud ^= GHOST_HUD_XENO
			client.prefs.save_preferences()
			to_chat(src, span_boldnotice("[hud_choice] [ghost_xenohud ? "Enabled" : "Disabled"]"))
		if("Order HUD")
			ghost_orderhud = !ghost_orderhud
			H = GLOB.huds[DATA_HUD_ORDER]
			ghost_orderhud ? H.add_hud_to(src) : H.remove_hud_from(src)
			client.prefs.ghost_hud ^= GHOST_HUD_ORDER
			client.prefs.save_preferences()
			to_chat(src, span_boldnotice("[hud_choice] [ghost_orderhud ? "Enabled" : "Disabled"]"))



/mob/dead/observer/verb/teleport(area/A in GLOB.sorted_areas)
	set category = "Ghost"
	set name = "Teleport"
	set desc = "Teleport to an area."

	if(!A)
		return

	abstract_move(pick(get_area_turfs(A)))
	update_parallax_contents()


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
		to_chat(usr, span_warning("There are no ghosts at the moment."))
		return

	var/selected = tgui_input_list(usr, "Please select a Ghost:", "Follow Ghost", observers)
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
		var/mob/living/carbon/xenomorph/X = x
		var/name = X.name
		if(name in names)
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1


		if((X.client && X.client?.is_afk()) || (!X.client && (X.key || X.ckey)))
			if(isaghost(X))
				if(admin)
					name += " (AGHOSTED)"
			else
				switch(X.afk_status)
					if(MOB_RECENTLY_DISCONNECTED)
						name += " (Away)"
					if(MOB_DISCONNECTED)
						name += " (DC)"

		xenos[name] = X

	if(!length(xenos))
		to_chat(usr, span_warning("There are no xenos at the moment."))
		return


	var/selected = tgui_input_list(usr, "Please select a Xeno:", "Follow Xeno", xenos)
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
		var/mob/living/carbon/human/H = x
		if(!ishumanbasic(H) && !issynth(H) || istype(H, /mob/living/carbon/human/dummy) || !H.name)
			continue
		var/name = H.name
		if(name in names)
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1
		if(H.real_name && H.real_name != H.name)
			name += " as ([H.real_name])"
		if(issynth(H))
			name += " - Synth"
		else if(issurvivorjob(H.job))
			name += " - Survivor"
		else if(H.faction != "TerraGov")
			name += " - [H.faction]"
		if((H.client && H.client.is_afk()) || (!H.client && (H.key || H.ckey)))
			if(isaghost(H))
				if(admin)
					name += " (AGHOSTED)"
			else
				switch(H.afk_status)
					if(MOB_RECENTLY_DISCONNECTED)
						name += " (Away)"
					if(MOB_DISCONNECTED)
						name += " (DC)"

		humans[name] = H

	if(!length(humans))
		to_chat(usr, span_warning("There are no living humans at the moment."))
		return

	var/selected = tgui_input_list(usr, "Please select a Living Human:", "Follow Living Human", humans)
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
		to_chat(usr, span_warning("There are no dead mobs at the moment."))
		return

	var/selected = tgui_input_list(usr, "Please select a Dead Mob:", "Follow Dead", dead)
	if(!selected)
		return

	var/mob/target = dead[selected]
	ManualFollow(target)


/mob/dead/observer/verb/follow()
	set category = "Ghost"
	set name = "Follow"

	if(!orbit_menu)
		orbit_menu = new(src)
	orbit_menu.ui_interact(src)


/mob/dead/observer/verb/offered_mobs()
	set category = "Ghost"
	set name = "Take Offered Mob"

	if(!length(GLOB.offered_mob_list))
		to_chat(src, span_warning("There are currently no mobs being offered."))
		return

	var/mob/living/L = tgui_input_list(usr, "Choose which mob you want to take over.", "Offered Mob", sortNames(GLOB.offered_mob_list))
	if(isnull(L))
		return

	if(!istype(L))
		to_chat(src, span_warning("Mob already taken."))
		return

	if(isxeno(L))
		var/mob/living/carbon/xenomorph/offered_xenomorph = L
		if(offered_xenomorph.tier != XENO_TIER_MINION && XENODEATHTIME_CHECK(src))
			XENODEATHTIME_MESSAGE(src)
			return

	switch(tgui_alert(usr, "Take over mob named: [L.real_name][L.job ? " | Job: [L.job]" : ""]", "Offered Mob", list("Yes", "No", "Follow")))
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

	orbit(target, orbitsize, FALSE, 20, rot_seg)


/mob/dead/observer/orbit()
	setDir(SOUTH)//reset dir so the right directional sprites show up
	return ..()


/mob/dead/observer/stop_orbit(datum/component/orbiter/orbits)
	. = ..()
	pixel_y = 0
	animate(src, pixel_y = 2, time = 10, loop = -1)


/mob/dead/observer/verb/toggle_zoom()
	set category = "Ghost"
	set name = "Toggle Zoom"

	if(!client)
		return

	if(client.view != CONFIG_GET(string/default_view))
		client.view_size.reset_to_default()
	else
		client.view_size.set_view_radius_to(12.5)


/mob/dead/observer/verb/add_view_range(input as num)
	set name = "Add View Range"
	set hidden = TRUE
	if(input)
		client.rescale_view(input, 15, 21)


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

	to_chat(src, span_notice("You [(ghost_vision ? "now" : "no longer")] have ghost vision."))


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

	check_hive_status(usr)


/mob/dead/observer/verb/view_manifest()
	set category = "Ghost"
	set name = "View Crew Manifest"

	var/dat = GLOB.datacore.get_manifest()

	var/datum/browser/popup = new(src, "manifest", "<div align='center'>Crew Manifest</div>", 370, 420)
	popup.set_content(dat)
	popup.open(FALSE)

/mob/dead/observer/verb/observe()
	set name = "Observe"
	set category = "Ghost"

	reset_perspective(null)

	var/mob/target = tgui_input_list(usr, "Please select a mob:", "Observe", GLOB.mob_living_list)
	if(!target)
		return

	do_observe(target)

///makes the ghost see the target hud and sets the eye at the target.
/mob/dead/observer/proc/do_observe(mob/target)
	if(!client || !target || !isliving(target))
		return

	client.eye = target

	if(!target.hud_used)
		return

	client.screen = list()
	LAZYINITLIST(target.observers)
	target.observers |= src
	target.hud_used.show_hud(target.hud_used.hud_version, src)
	observetarget = target
	RegisterSignal(observetarget, COMSIG_QDELETING, PROC_REF(clean_observetarget))

///Signal handler to clean the observedtarget
/mob/dead/observer/proc/clean_observetarget()
	SIGNAL_HANDLER
	if(observetarget?.observers)
		observetarget.observers -= src
		UNSETEMPTY(observetarget.observers)
	if(observetarget)
		UnregisterSignal(observetarget, COMSIG_QDELETING)
	observetarget = null

/mob/dead/observer/verb/dnr()
	set category = "Ghost"
	set name = "Do Not Revive"
	set desc = "Noone will be able to revive you."

	if(!isnull(can_reenter_corpse) && tgui_alert(usr, "Are you sure? You won't be able to get revived.", "Confirmation", list("Yes", "No")) == "Yes")
		var/mob/living/carbon/human/human_current = can_reenter_corpse.resolve()
		if(istype(human_current))
			human_current.set_undefibbable(TRUE)

		can_reenter_corpse = null
		to_chat(usr, span_notice("You can no longer be revived."))
		return

	to_chat(usr, span_warning("You already can't be revived."))


/mob/dead/observer/verb/toggle_inquisition()
	set category = "Ghost"
	set name = "Toggle Inquisitiveness"
	set desc = "Sets whether your ghost examines everything on click by default"

	inquisitive_ghost = !inquisitive_ghost

	if(inquisitive_ghost)
		to_chat(src, span_notice("You will now examine everything you click on."))
	else
		to_chat(src, span_notice("You will no longer examine things you click on."))

/mob/dead/observer/verb/join_valhalla()
	set name = "Join Valhalla"
	set category = "Ghost"

	if(is_banned_from(ckey, ROLE_VALHALLA))
		to_chat(usr, span_notice("You are banned from Valhalla!"))
		return

	if(!GLOB.valhalla_allowed)
		to_chat(usr, span_notice("Valhalla is currently disabled!"))
		return

	if(stat != DEAD)
		to_chat(usr, span_boldnotice("You must be dead to use this!"))
		return

	var/choice = tgui_input_list(usr, "You are about to embark to the ghastly walls of Valhalla. Xenomorph or Marine?", "Join Valhalla", list("Xenomorph", "Marine"))

	if(!choice)
		return

	if(choice == "Xenomorph")
		var/mob/living/carbon/xenomorph/xeno_choice = tgui_input_list(usr, "You are about to embark to the ghastly walls of Valhalla. What xenomorph would you like to have?", "Join Valhalla", GLOB.all_xeno_types)
		if(!xeno_choice)
			return
		log_game("[key_name(usr)] has joined Valhalla as a Xenomorph.")
		var/mob/living/carbon/xenomorph/new_xeno = new xeno_choice(pick(GLOB.spawns_by_job[/datum/job/fallen/xenomorph]))
		new_xeno.transfer_to_hive(XENO_HIVE_FALLEN)
		ADD_TRAIT(new_xeno, TRAIT_VALHALLA_XENO, VALHALLA_TRAIT)
		var/datum/job/xallhala_job = SSjob.GetJobType(/datum/job/fallen/xenomorph)
		new_xeno.apply_assigned_role_to_spawn(xallhala_job)
		SSpoints.xeno_points_by_hive[XENO_HIVE_FALLEN] = 10000
		mind.transfer_to(new_xeno, TRUE)
		xallhala_job.after_spawn(new_xeno)
		return

	var/datum/job/valhalla_job = tgui_input_list(usr, "You are about to embark to the ghastly walls of Valhalla. What job would you like to have?", "Join Valhalla", GLOB.jobs_fallen_marine)
	if(!valhalla_job)
		return

	valhalla_job = SSjob.GetJobType(valhalla_job)
	var/spawn_type = valhalla_job.return_spawn_type(client.prefs)
	var/mob/living/carbon/human/new_fallen = new spawn_type(pick(GLOB.spawns_by_job[/datum/job/fallen/marine]))

	log_game("[key_name(usr)] has joined Valhalla as a Marine.")
	client.prefs.copy_to(new_fallen)
	new_fallen.apply_assigned_role_to_spawn(valhalla_job)
	mind.transfer_to(new_fallen, TRUE)
	valhalla_job.after_spawn(new_fallen)

/mob/dead/observer/reset_perspective(atom/A)
	clean_observetarget()
	. = ..()

	if(!.)
		return

	if(!hud_used)
		return

	client.screen = list()
	hud_used.show_hud(hud_used.hud_version)


/mob/dead/observer/get_photo_description(obj/item/camera/camera)
	if(!invisibility || camera.see_ghosts)
		return "You can also see a g-g-g-g-ghooooost!"

/mob/dead/observer/incapacitated(ignore_restrained, restrained_flags)
	return FALSE


/mob/dead/observer/can_interact_with(datum/D)
	return (D == src || IsAdminGhost(src))

//this is called when a ghost is drag clicked to something.
/mob/dead/observer/MouseDrop(atom/over)
	if(!usr || !over)
		return
	if (isobserver(usr) && usr.client.holder && (isliving(over) || iscameramob(over)) )
		if (usr.client.holder.cmd_ghost_drag(src,over))
			return

	return ..()

/mob/dead/observer/point_to(atom/pointed_atom)
	if(!..())
		return FALSE
	visible_message(span_deadsay("[span_name("[src]")] points at [pointed_atom]."))

/mob/dead/observer/CtrlShiftClickOn(mob/dead/observer/target_ghost)
	if(!istype(target_ghost))
		return
	if(!check_rights(R_SPAWN))
		return

	if(src == target_ghost)
		client.holder.spatial_agent()
	else
		target_ghost.change_mob_type(/mob/living/carbon/human, delete_old_mob = TRUE)
