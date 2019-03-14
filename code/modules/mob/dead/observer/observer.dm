/mob/dead/observer
	name = "ghost"
	desc = "It's a g-g-g-g-ghooooost!"
	icon = 'icons/mob/mob.dmi'
	icon_state = "ghost"
	stat = DEAD
	density = FALSE
	canmove = FALSE
	anchored = TRUE
	invisibility = INVISIBILITY_OBSERVER
	alpha = 127
	layer = ABOVE_FLY_LAYER


	var/can_reenter_corpse = FALSE
	var/datum/hud/living/carbon/hud = null
	var/started_as_observer //This variable is set to 1 when you enter the game as an observer.
							//If you died in the game and are a ghsot - this will remain as null.
							//Note that this is not a reliable way to determine if admins started as observers, since they change mobs a lot.
	var/ghost_medhud = FALSE
	var/ghost_sechud = FALSE
	var/ghost_squadhud = FALSE
	var/ghost_xenohud = FALSE

	universal_speak = TRUE
	var/atom/movable/following = null

	var/voted_this_drop = FALSE


/mob/dead/observer/Initialize()
	sight |= SEE_TURFS|SEE_MOBS|SEE_OBJS|SEE_SELF
	see_invisible = SEE_INVISIBLE_OBSERVER
	see_in_dark = 100

	stat = DEAD

	Login()

	return ..()

/mob/dead/observer/Destroy()
	unfollow()
	. = ..()

/mob/dead/observer/Topic(href, href_list)
	if(href_list["reentercorpse"])
		if(!isobserver(usr))
			return
		var/mob/dead/observer/A = usr
		A.reenter_corpse()


	else if(href_list["track"])
		var/mob/target = locate(href_list["track"]) in GLOB.mob_list
		if(!target)
			return
		ManualFollow(target)


	else if(href_list["claim"])
		var/mob/living/target = locate(href_list["claim"]) in GLOB.mob_list
		if(!istype(target))
			to_chat(usr, "<span class='warning'>Invalid target.</span>")
			return
		if(!mind)
			to_chat(usr, "<span class='warning'>You don't have a mind.</span>")
			return
		if(target.taken || target.key || target.ckey)
			to_chat(usr, "<span class='warning'>That mob has already been taken.</span>")
			return
		if(target.job && (is_banned_from(ckey, target.job) || jobban_isbanned(src, target.job)))
			to_chat(usr, "<span class='warning'>You are jobbanned from that job.</span>")
			return

		target.taken = TRUE

		log_admin("[key_name(usr)] has taken [key_name_admin(target)].")
		message_admins("[ADMIN_TPMONTY(usr)] has taken [ADMIN_TPMONTY(target)].")

		mind.transfer_to(target, TRUE)
		target.fully_replace_character_name(real_name, target.real_name)
		if(target.job)
			var/datum/job/J = SSjob.name_occupations[target.job]
			var/datum/outfit/job/O = new J.outfit
			var/datum/skills/L = new J.skills_type
			target.mind.cm_skills = L
			target.mind.comm_title = J.comm_title

			SSjob.AssignRole(target, target.job)
			O.post_equip(target)


	else if(href_list["preference"])
		if(!client?.prefs)
			return
		client.prefs.process_link(src, href_list)


/mob/dead/CanPass(atom/movable/mover, turf/target)
	return TRUE


/mob/dead/observer/Life()
	. = ..()
	if(!loc)
		return FALSE
	if(!client)
		return FALSE
	return TRUE


/mob/proc/ghostize(var/can_reenter_corpse = TRUE)
	if(!key)
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
	else
		if(real_name)
			ghost.real_name = real_name
		else
			if(gender == MALE)
				ghost.real_name = capitalize(pick(first_names_male)) + " " + capitalize(pick(last_names))
			else
				ghost.real_name = capitalize(pick(first_names_female)) + " " + capitalize(pick(last_names))

	ghost.name = ghost.real_name

	if(mind)
		ghost.mind = mind

	if(!T)
		T = pick(GLOB.latejoin)

	ghost.loc = T

	if(!name)
		ghost.name = capitalize(pick(first_names_male)) + " " + capitalize(pick(last_names))

	if(!can_reenter_corpse)
		away_timer = 5 MINUTES

	if(ghost.client)
		ghost.client.change_view(world.view)
		ghost.client.pixel_x = 0
		ghost.client.pixel_y = 0

	ghost.alpha = 127

	ghost.can_reenter_corpse = can_reenter_corpse
	ghost.timeofdeath = timeofdeath
	ghost.key = key

	return ghost


/mob/dead/observer/proc/unfollow()
	if(following?.followers)
		following.followers -= src
	following = null


/mob/dead/observer/Move(NewLoc, direct)
	unfollow()
	setDir(direct)
	if(NewLoc)
		loc = NewLoc
		return
	loc = get_turf(src)
	if((direct & NORTH) && y < world.maxy)
		y++
	else if((direct & SOUTH) && y > 1)
		y--
	if((direct & EAST) && x < world.maxx)
		x++
	else if((direct & WEST) && x > 1)
		x--


/mob/dead/observer/examine(mob/user)
	to_chat(user, desc)


/mob/dead/observer/can_use_hands()
	return FALSE


/mob/dead/observer/Stat()
	. = ..()

	if(statpanel("Stats"))
		if(EvacuationAuthority)
			var/eta_status = EvacuationAuthority.get_status_panel_eta()
			if(eta_status)
				stat(null, eta_status)
		if(SSticker?.mode)
			var/countdown = SSticker.mode.get_queen_countdown()
			if(countdown)
				stat("Queen Re-Check:", countdown)


/mob/dead/observer/verb/reenter_corpse()
	set category = "Ghost"
	set name = "Re-enter Corpse"

	if(!client)
		return FALSE

	if(!mind?.current || mind.current.gc_destroyed || !can_reenter_corpse)
		to_chat(src, "<span class='warning'>You have no body.</span>")
		return FALSE

	if(mind.current.key && copytext(mind.current.key, 1, 2) != "@")
		to_chat(usr, "<span class='warning'>Another consciousness is in your body...It is resisting you.</span>")
		return FALSE

	mind.current.key = key
	if(mind.current.client)
		mind.current.client.change_view(world.view)
	return TRUE


/mob/dead/observer/verb/toggle_HUDs()
	set category = "Ghost"
	set name = "Toggle HUDs"
	set desc = "Toggles various HUDs."

	if(!client?.prefs)
		return

	var/hud_choice = input("Choose a HUD to toggle", "Toggle HUD") as null|anything in list("Medical HUD", "Security HUD", "Squad HUD", "Xeno Status HUD")

	var/datum/mob_hud/H
	switch(hud_choice)
		if("Medical HUD")
			ghost_medhud = !ghost_medhud
			H = huds[MOB_HUD_MEDICAL_OBSERVER]
			ghost_medhud ? H.add_hud_to(src) : H.remove_hud_from(src)
			client.prefs.ghost_hud ^= GHOST_HUD_MED
			client.prefs.save_preferences()
			to_chat(src, "<span class='boldnotice'>[hud_choice] [ghost_medhud ? "Enabled" : "Disabled"]</span>")
		if("Security HUD")
			ghost_sechud = !ghost_sechud
			H = huds[MOB_HUD_SECURITY_ADVANCED]
			ghost_sechud ? H.add_hud_to(src) : H.remove_hud_from(src)
			client.prefs.ghost_hud ^= GHOST_HUD_SEC
			client.prefs.save_preferences()
			to_chat(src, "<span class='boldnotice'>[hud_choice] [ghost_sechud ? "Enabled": "Disabled"]</span>")
		if("Squad HUD")
			ghost_squadhud = !ghost_squadhud
			H = huds[MOB_HUD_SQUAD]
			ghost_squadhud ? H.add_hud_to(src) : H.remove_hud_from(src)
			client.prefs.ghost_hud ^= GHOST_HUD_SQUAD
			client.prefs.save_preferences()
			to_chat(src, "<span class='boldnotice'>[hud_choice] [ghost_squadhud ? "Enabled": "Disabled"]</span>")
		if("Xeno Status HUD")
			ghost_xenohud = !ghost_xenohud
			H = huds[MOB_HUD_XENO_STATUS]
			ghost_xenohud ? H.add_hud_to(src) : H.remove_hud_from(src)
			client.prefs.ghost_hud ^= GHOST_HUD_XENO
			client.prefs.save_preferences()
			to_chat(src, "<span class='boldnotice'>[hud_choice] [ghost_xenohud ? "Enabled" : "Disabled"]</span>")


/mob/dead/observer/verb/teleport(var/area/A in return_sorted_areas())
	set category = "Ghost"
	set name = "Teleport"
	set desc = "Teleport to an area."

	if(!A)
		return

	unfollow()
	loc = pick(get_area_turfs(A))


/mob/dead/observer/verb/follow_ghost()
	set category = "Ghost"
	set name = "Follow Ghost"

	var/list/observers = list()
	var/list/names = list()
	var/list/namecounts = list()

	for(var/mob/dead/observer/O in sortNames(GLOB.dead_mob_list))
		if(!O.client)
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


/mob/dead/observer/verb/follow_pred()
	set category = "Ghost"
	set name = "Follow Predator"

	var/list/preds = list()
	var/list/names = list()
	var/list/namecounts = list()

	for(var/x in sortNames(GLOB.human_mob_list))
		var/mob/M = x
		if(!isyautja(M))
			continue
		var/name = M.name
		if(name in names)
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1
		if(M.real_name && M.real_name != M.name)
			name += "as ([M.real_name])"
		if(M.stat == DEAD)
			name += " (dead)"

		preds[name] = M

	if(!length(preds))
		to_chat(usr, "<span class='warning'>There are no predators at the moment.</span>")
		return

	var/selected = input("Please select a Predator:", "Follow Predator") as null|anything in preds
	if(!selected)
		return

	var/mob/target = preds[selected]
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
		if(!ishumanbasic(M) && !issynth(M) || istype(M, /mob/living/carbon/human/dummy))
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
				if(copytext(M.key, 1, 2) == "@")
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
		if(isobserver(M) || isnewplayer(M))
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
		if(isobserver(M) || isnewplayer(M) || ishumanbasic(M))
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


/mob/dead/observer/proc/ManualFollow(var/atom/movable/target)
	set waitfor = FALSE

	if(target && target != src)
		if(following && following == target)
			return
		unfollow()
		target.followers += src
		following = target
		loc = target.loc
		to_chat(src, "<span class='notice'>Now following [target]</span>")
		spawn(0) //Backup
			while(target && following == target && client)
				var/turf/T = get_turf(target)
				if(!T)
					break
				// To stop the ghost flickering.
				if(loc != T)
					loc = T
				sleep(15)


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

	if(see_invisible == SEE_INVISIBLE_OBSERVER_NOLIGHTING)
		see_invisible = SEE_INVISIBLE_OBSERVER
		to_chat(src, "<span class='notice'>You can no longer see in the dark.</span>")
	else
		see_invisible = SEE_INVISIBLE_OBSERVER_NOLIGHTING
		to_chat(src, "<span class='notice'>You can now see in the dark.</span>")


/mob/dead/observer/verb/hive_status()
	set category = "Ghost"
	set name = "Show Hive Status"
	set desc = "Check the status of the hive."

	check_hive_status()


/mob/dead/observer/verb/view_manifest()
	set category = "Ghost"
	set name = "View Crew Manifest"

	var/dat = data_core.get_manifest()

	var/datum/browser/popup = new(src, "manifest", "<div align='center'>Crew Manifest</div>", 370, 420)
	popup.set_content(dat)
	popup.open(FALSE)


/mob/dead/verb/join_as_xeno()
	set category = "Ghost"
	set name = "Join as Xeno"
	set desc = "Select an alive but logged-out Xenomorph to rejoin the game."

	if(!client || !SSticker.mode.check_xeno_late_join(src))
		return

	if(!SSticker?.mode || SSticker.current_state < GAME_STATE_PLAYING)
		to_chat(src, "<span class='warning'>The game hasn't started yet!</span>")
		return

	var/choice = alert("Would you like to join as a larva or as a xeno?", "Join as Xeno", "Xeno", "Larva", "Cancel")
	switch(choice)
		if("Xeno")
			var/mob/new_xeno = SSticker.mode.attempt_to_join_as_xeno(src)
			if(new_xeno)
				SSticker.mode.transfer_xeno(src, new_xeno)
		if("Larva")
			var/mob/living/carbon/Xenomorph/Queen/mother = SSticker.mode.attempt_to_join_as_larva(src)
			if(!mother)
				return
			SSticker.mode.spawn_larva(src, mother)


/mob/dead/verb/join_as_hellhound()
	set category = "Ghost"
	set name = "Join as Hellhound"

	var/mob/L = src

	if(SSticker.current_state < GAME_STATE_PLAYING)
		to_chat(usr, "<span class='warning'>The game hasn't started yet!</span>")
		return

	var/list/hellhound_list = list()

	for(var/mob/living/carbon/hellhound/A in GLOB.alive_mob_list)
		if(istype(A) && !A.client)
			hellhound_list += A.real_name

	if(!length(hellhound_list))
		to_chat(usr, "<span class='warning'>There aren't any available Hellhounds.</span>")
		return

	var/choice = input("Pick a Hellhound:") as null|anything in hellhound_list
	if(!choice)
		return

	for(var/mob/living/carbon/hellhound/X in GLOB.alive_mob_list)
		if(choice == X.real_name)
			L = X
			break

	if(!L || L.gc_destroyed)
		to_chat(usr, "Not a valid mob!")
		return

	if(!istype(L, /mob/living/carbon/hellhound))
		to_chat(usr, "<span class='warning'>That's not a Hellhound.</span>")
		return

	if(L.stat == DEAD)
		to_chat(usr, "<span class='warning'>It's dead.</span>")
		return

	if(L.client)
		to_chat(usr, "<span class='warning'>That player is still connected.</span>")
		return

	if(alert(usr, "Everything checks out. Are you sure you want to transfer yourself into this hellhound?", "Confirmation", "Yes", "No") != "Yes")
		return

		if(L.client || L.stat == DEAD)
			to_chat(usr, "<span class='warning'>Oops. That mob can no longer be controlled. Sorry.</span>")
			return

	var/mob/ghostmob = usr.client.mob
	log_admin("[key_name(usr)] has joined as a [L].")
	message_admins("[ADMIN_TPMONTY(usr)] has joined as a [L].")
	L.ckey = usr.ckey

	L.client?.change_view(world.view)

	if(isobserver(ghostmob))
		qdel(ghostmob)


/mob/dead/observer/verb/drop_vote()
	set category = "Ghost"
	set name = "Hunter Games Vote"
	set desc = "If it's on Hunter Games gamemode, vote on who gets a supply drop!"

	if(!SSticker?.mode || SSticker.current_state < GAME_STATE_PLAYING)
		to_chat(usr, "<span class='warning'>The game hasn't started yet!</span>")
		return

	if(!istype(SSticker.mode,/datum/game_mode/huntergames))
		to_chat(usr, "Wrong game mode. You have to be observing a Hunter Games round.")
		return

	if(!waiting_for_drop_votes)
		to_chat(usr, "There's no drop vote currently in progress. Wait for a supply drop to be announced!")
		return

	if(voted_this_drop)
		to_chat(usr, "You voted for this one already. Only one please!")
		return

	var/list/mobs = GLOB.alive_mob_list
	var/target = null

	for(var/mob/living/M in mobs)
		if(!istype(M,/mob/living/carbon/human) || M.stat || isyautja(M)) mobs -= M


	target = input("Please, select a contestant!", "Cake Time", null, null) as null|anything in mobs

	if(!target)
		return

	to_chat(usr, "Your vote for [target] has been counted!")
	SSticker.mode:supply_votes += target
	voted_this_drop = TRUE
	addtimer(CALLBACK(src, .proc/reset_vote), 3 MINUTES)


/mob/dead/observer/proc/reset_vote()
	voted_this_drop = FALSE


/mob/dead/observer/verb/observe()
	set name = "Observe"
	set category = "Ghost"

	if(client.eye != client.mob)
		client.perspective = MOB_PERSPECTIVE
		client.eye = client.mob
		return

	var/mob/target = input("Please select a mob:", "Observe", null, null) as null|anything in GLOB.mob_list
	if(!target)
		return

	if(client && target)
		client.perspective = EYE_PERSPECTIVE
		client.eye = target


/mob/dead/observer/verb/dnr()
	set category = "Ghost"
	set name = "Become DNR"
	set desc = "Noone will be able to revive you."

	if(can_reenter_corpse && alert("Are you sure? You won't be able to get revived.", "Confirmation", "Yes", "No") == "Yes")
		can_reenter_corpse = FALSE
		to_chat(usr, "<span class='notice'>You can no longer be revived.</span>")
	else if(!can_reenter_corpse)
		to_chat(usr, "<span class='warning'>You already can't be revived.</span>")
