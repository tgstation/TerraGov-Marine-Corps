/mob/new_player
	var/ready = FALSE
	var/spawning = FALSE
	universal_speak = TRUE

	invisibility = INVISIBILITY_MAXIMUM

	stat = DEAD

	density = FALSE
	canmove = FALSE
	anchored = TRUE


/mob/new_player/New()
	GLOB.mob_list += src
	GLOB.total_players++


/mob/new_player/Del()
	GLOB.mob_list -= src
	GLOB.total_players--


/mob/new_player/proc/version_check()
	if(client.byond_version < world.byond_version)
		to_chat(client, "<span class='warning'>Your version of Byond differs from the server (v[world.byond_version].[world.byond_build]). You may experience graphical glitches, crashes, or other errors. You will be disconnected until your version matches or exceeds the server version.<br> \
		Direct Download (Windows Installer): http://www.byond.com/download/build/[world.byond_version]/[world.byond_version].[world.byond_build]_byond.exe <br> \
		Other versions (search for [world.byond_build] or higher): http://www.byond.com/download/build/[world.byond_version]</span>")

		del(client)


/mob/new_player/proc/new_player_panel_proc()
	var/output = "<div align='center'><B>New Player Options</B>"
	output +="<hr>"
	output += "<p><a href='byond://?src=\ref[src];lobby_choice=show_preferences'>Setup Character</A></p>"

	if(!SSticker?.mode || SSticker.current_state <= GAME_STATE_PREGAME)
		output += "<p>\[ [ready? "<b>Ready</b>":"<a href='byond://?src=\ref[src];lobby_choice=ready'>Ready</a>"] | [ready? "<a href='byond://?src=\ref[src];lobby_choice=ready'>Not Ready</a>":"<b>Not Ready</b>"] \]</p>"

	else
		output += "<a href='byond://?src=\ref[src];lobby_choice=manifest'>View the Crew Manifest</A><br><br>"
		output += "<p><a href='byond://?src=\ref[src];lobby_choice=late_join'>Join the TGMC!</A></p>"
		output += "<p><a href='byond://?src=\ref[src];lobby_choice=late_join_xeno'>Join the Hive!</A></p>"

	output += "<p><a href='byond://?src=\ref[src];lobby_choice=observe'>Observe</A></p>"

	output += "</div>"

	src << browse(output,"window=playersetup;size=240x300;can_close=0")


/mob/new_player/Stat()
	. = ..()

	if(!SSticker)
		return

	if(statpanel("Stats"))
		if(SSticker.hide_mode)
			stat("Game Mode:", "TerraGov Marine Corps")
		else
			stat("Game Mode:", "[master_mode]")

		if(SSticker.current_state == GAME_STATE_PREGAME)
			stat("Time To Start:", "[SSticker.pregame_timeleft][going ? "" : " (DELAYED)"]")
			stat("Players: [GLOB.total_players]", "Players Ready: [GLOB.ready_players]")
			for(var/mob/new_player/player in GLOB.player_list)
				stat("[player.key]", player.ready ? "Playing" : "")

/mob/new_player/Topic(href, href_list[])
	if(!client)
		return

	switch(href_list["lobby_choice"])
		if("show_preferences")
			client.prefs.ShowChoices(src)


		if("ready")
			if(!SSticker || SSticker.current_state <= GAME_STATE_PREGAME)
				ready = !ready
				if(ready)
					GLOB.ready_players++
				else
					GLOB.ready_players--
			new_player_panel_proc()


		if("refresh")
			src << browse(null, "window=playersetup")
			new_player_panel_proc()


		if("observe")
			if(alert("Are you sure you wish to observe?\nYou will have to wait at least 5 minutes before being able to respawn!", "Observe", "Yes", "No") == "Yes")
				if(!client)
					return TRUE
				var/mob/dead/observer/observer = new()

				spawning = TRUE
				observer.started_as_observer = TRUE

				close_spawn_windows()

				var/failed = FALSE

				if(GLOB.latejoin.len)
					var/turf/T = pick(GLOB.latejoin)
					if(T)
						to_chat(src, "<span class='notice'>Now teleporting.</span>")
						observer.forceMove(T)
					else
						failed = TRUE
				else
					failed = TRUE

				if(failed)
					to_chat(src, "<span class='danger'>Could not locate an observer spawn point. Use the Teleport verb to jump.</span>")

				observer.timeofdeath = world.time

				client.prefs.update_preview_icon()
				observer.icon = client.prefs.preview_icon
				observer.alpha = 127

				var/datum/species/species = GLOB.all_species[client.prefs.species] || GLOB.all_species[DEFAULT_SPECIES]

				if(client.prefs.be_random_name)
					client.prefs.real_name = species.random_name(client.prefs.gender)

				observer.real_name = client.prefs.real_name
				observer.name = observer.real_name
				observer.key = key

				if(observer.client)
					observer.client.change_view(world.view)
				qdel(src)


		if("late_join")
			if(!SSticker?.mode || SSticker.current_state != GAME_STATE_PLAYING)
				to_chat(src, "<span class='warning'>The round is either not ready, or has already finished.</span>")
				return

			if(SSticker.mode.flags_round_type	& MODE_NO_LATEJOIN)
				to_chat(src, "<span class='warning'>Sorry, you cannot late join during [SSticker.mode.name]. You have to start at the beginning of the round. You may observe or try to join as an alien, if possible.</span>")
				return

			if(client.prefs.species != "Human")
				if(!is_alien_whitelisted(client.prefs.species) && CONFIG_GET(flag/usealienwhitelist))
					to_chat(src, alert("You are currently not whitelisted to play [client.prefs.species]."))
					return

			LateChoices()


		if("late_join_xeno")
			if(!SSticker?.mode || SSticker.current_state != GAME_STATE_PLAYING)
				to_chat(src, "<span class='warning'>The round is either not ready, or has already finished.</span>")
				return

			switch(alert("Would you like to try joining as a burrowed larva or as a living xenomorph?", "Select", "Burrowed Larva", "Living Xenomorph", "Cancel"))
				if("Burrowed Larva")
					if(SSticker.mode.check_xeno_late_join(src))
						var/mob/living/carbon/Xenomorph/Queen/mother
						mother = SSticker.mode.attempt_to_join_as_larva(src)
						if(mother)
							close_spawn_windows()
							SSticker.mode.spawn_larva(src, mother)
				if("Living Xenomorph")
					if(SSticker.mode.check_xeno_late_join(src))
						var/mob/new_xeno = SSticker.mode.attempt_to_join_as_xeno(src, 0)
						if(new_xeno)
							close_spawn_windows(new_xeno)
							SSticker.mode.transfer_xeno(src, new_xeno)


		if("manifest")
			ViewManifest()



		if("SelectedJob")
			if(!GLOB.enter_allowed)
				to_chat(usr, "<span class='warning'>Spawning currently disabled, please observe.</span>")
				return
			if(client.prefs.species != "Human")
				if(!is_alien_whitelisted(client.prefs.species) && CONFIG_GET(flag/usealienwhitelist))
					to_chat(src, alert("You are currently not whitelisted to play [client.prefs.species]."))
					return FALSE

			AttemptLateSpawn(href_list["job_selected"],client.prefs.spawnpoint)


/mob/new_player/proc/AttemptLateSpawn(rank, spawning_at)
	if(src != usr)
		return
	if(!SSticker || SSticker.current_state != GAME_STATE_PLAYING)
		to_chat(usr, "<span class='warning'>The round is either not ready, or has already finished!<spawn>")
		return
	if(!GLOB.enter_allowed)
		to_chat(usr, "<span class='warning'>Spawning currently disabled, please observe.<spawn>")
		return
	if(!SSjob.assign_role(src, SSjob.roles_for_mode[rank], TRUE))
		to_chat(src, alert("[rank] is not available. Please try another."))
		return

	spawning = TRUE
	close_spawn_windows()

	var/datum/spawnpoint/S //We need to find a spawn location for them.
	var/turf/T
	if(spawning_at)
		S = spawntypes[spawning_at]

	if(istype(S))
		T = pick(S.turfs)
	else
		T = pick(GLOB.latejoin)

	var/mob/living/carbon/human/character = create_character()	//creates the human and transfers vars and mind
	SSjob.equip_role(character, SSjob.roles_for_mode[rank], T)
	UpdateFactionList(character)
	EquipCustomItems(character)

	SSticker.mode.latespawn(character)
	data_core.manifest_inject(character)
	SSticker.minds += character.mind//Cyborgs and AIs handle this in the transform proc.	//TODO!!!!! ~Carn
	SSticker.mode.latejoin_tally++

	for(var/datum/squad/sq in SSjob.squads)
		if(sq)
			sq.max_engineers = engi_slot_formula(GLOB.clients.len)
			sq.max_medics = medic_slot_formula(GLOB.clients.len)

	if(SSticker.mode.latejoin_larva_drop && SSticker.mode.latejoin_tally >= SSticker.mode.latejoin_larva_drop)
		SSticker.mode.latejoin_tally -= SSticker.mode.latejoin_larva_drop
		SSticker.mode.stored_larva++

	qdel(src)


/mob/new_player/proc/LateChoices()
	var/dat = "<html><body><center>"
	dat += "Round Duration: [worldtime2text()]<br>"

	if(EvacuationAuthority)
		switch(EvacuationAuthority.evac_status)
			if(EVACUATION_STATUS_INITIATING)
				dat += "<font color='red'><b>The [MAIN_SHIP_NAME] is being evacuated.</b></font><br>"
			if(EVACUATION_STATUS_COMPLETE)
				dat += "<font color='red'>The [MAIN_SHIP_NAME] has undergone evacuation.</font><br>"

	dat += "Choose from the following open positions:<br>"
	var/datum/job/J
	for(var/i in SSjob.roles_for_mode)
		J = SSjob.roles_for_mode[i]
		if(!SSjob.check_role_entry(src, J, 1))
			continue
		var/active = 0
		//Only players with the job assigned and AFK for less than 10 minutes count as active
		for(var/mob/M in GLOB.player_list)
			if(M.mind && M.client && M.mind.assigned_role == J.title && M.client.inactivity <= 10 * 60 * 10)
				active++
		dat += "<a href='byond://?src=\ref[src];lobby_choice=SelectedJob;job_selected=[J.title]'>[J.disp_title] ([J.current_positions]) (Active: [active])</a><br>"

	dat += "</center>"
	src << browse(dat, "window=latechoices;size=300x640;can_close=1")


/mob/new_player/proc/create_character()
	spawning = TRUE
	close_spawn_windows()

	var/mob/living/carbon/human/new_character

	var/datum/species/chosen_species
	if(client.prefs.species)
		chosen_species = GLOB.all_species[client.prefs.species]
	if(chosen_species)
		// Have to recheck admin due to no usr at roundstart. Latejoins are fine though.
		if(is_alien_whitelisted(client.prefs.species))
			new_character = new(loc, client.prefs.species)

	if(!new_character)
		new_character = new(loc)

	new_character.lastarea = get_area(loc)

	var/datum/language/chosen_language
	if(client.prefs.language)
		chosen_language = GLOB.all_languages["[client.prefs.language]"]
	if(chosen_language)
		if(is_alien_whitelisted(client.prefs.language) || !CONFIG_GET(flag/usealienwhitelist) || !(chosen_language.flags & WHITELISTED) || (new_character.species && (chosen_language.name in new_character.species.secondary_langs)))
			new_character.add_language("[client.prefs.language]")

	if(SSticker.random_players)
		new_character.gender = pick(MALE, FEMALE)
		client.prefs.real_name = chosen_species.random_name(new_character.gender)
		client.prefs.randomize_appearance_for(new_character)
	else
		client.prefs.copy_to(new_character)

	if(mind)
		mind.active = FALSE
		mind.original = new_character
		mind.transfer_to(new_character)

	new_character.name = real_name
	new_character.dna.ready_dna(new_character)

	if(client.prefs.disabilities)
		new_character.dna.SetSEState(GLASSESBLOCK, 1, 0)
		new_character.disabilities |= NEARSIGHTED

	new_character.regenerate_icons()

	new_character.key = key
	if(new_character.client)
		new_character.client.change_view(world.view)

	return new_character


/mob/new_player/proc/ViewManifest()
	var/dat = "<html><body>"
	dat += "<h4>Crew Manifest:</h4>"
	dat += data_core.get_manifest(OOC = 1)

	src << browse(dat, "window=manifest;size=400x420;can_close=1")


/mob/new_player/Move()
	return FALSE


/mob/new_player/proc/close_spawn_windows()
	src << browse(null, "window=latechoices") //closes late choices window
	src << browse(null, "window=playersetup") //closes the player setup window
	src << sound(null, repeat = 0, wait = 0, volume = 85, channel = 1) // Stops lobby music.


/mob/new_player/get_species()
	var/datum/species/chosen_species
	if(client.prefs.species)
		chosen_species = GLOB.all_species[client.prefs.species]
	if(!chosen_species)
		return "Human"

	if(is_alien_whitelisted(chosen_species))
		return chosen_species.name

	return "Human"


/mob/new_player/get_gender()
	if(!client?.prefs)
		. = ..()
	return client.prefs.gender


/mob/new_player/is_ready()
	return ready && ..()


/mob/new_player/hear_say(message, verb = "says", datum/language/language = null, alt_name = "", italics = FALSE, mob/speaker = null)
	return


/mob/new_player/hear_radio(message, verb="says", datum/language/language = null, part_a, part_b, mob/speaker = null, hard_to_hear = FALSE)
	return
