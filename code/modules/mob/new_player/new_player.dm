/mob/new_player
	var/ready = FALSE
	var/spawning = FALSE
	universal_speak = TRUE

	invisibility = INVISIBILITY_MAXIMUM

	stat = DEAD

	density = FALSE
	canmove = FALSE
	anchored = TRUE

	var/mob/living/new_character	//for instant transfer once the round is set up


/mob/new_player/Initialize()
	GLOB.total_players++
	return ..()


/mob/new_player/Destroy()
	GLOB.total_players--
	return ..()


/mob/new_player/proc/version_check()
	if(client.byond_version < world.byond_version)
		to_chat(client, "<span class='warning'>Your version of Byond differs from the server (v[world.byond_version].[world.byond_build]). You may experience graphical glitches, crashes, or other errors. You will be disconnected until your version matches or exceeds the server version.<br> \
		Direct Download (Windows Installer): http://www.byond.com/download/build/[world.byond_version]/[world.byond_version].[world.byond_build]_byond.exe <br> \
		Other versions (search for [world.byond_build] or higher): http://www.byond.com/download/build/[world.byond_version]</span>")

		qdel(client)


/mob/new_player/proc/new_player_panel()
	var/output = "<div align='center'>"
	output += "<p><a href='byond://?src=[REF(src)];lobby_choice=show_preferences'>Setup Character</A></p>"

	if(!SSticker?.mode || SSticker.current_state <= GAME_STATE_PREGAME)
		output += "<p>\[ [ready? "<b>Ready</b>":"<a href='byond://?src=\ref[src];lobby_choice=ready'>Ready</a>"] | [ready? "<a href='byond://?src=[REF(src)];lobby_choice=ready'>Not Ready</a>":"<b>Not Ready</b>"] \]</p>"

	else
		output += "<a href='byond://?src=[REF(src)];lobby_choice=manifest'>View the Crew Manifest</A><br><br>"
		output += "<p><a href='byond://?src=[REF(src)];lobby_choice=late_join'>Join the TGMC!</A></p>"
		if(isdistress(SSticker.mode))
			output += "<p><a href='byond://?src=[REF(src)];lobby_choice=late_join_xeno'>Join the Hive!</A></p>"

	output += "<p><a href='byond://?src=[REF(src)];lobby_choice=observe'>Observe</A></p>"

	if(!IsGuestKey(key))
		if(SSdbcore.Connect())
			var/isadmin = FALSE
			if(check_rights(R_ADMIN, FALSE))
				isadmin = TRUE
			var/datum/DBQuery/query_get_new_polls = SSdbcore.NewQuery("SELECT id FROM [format_table_name("poll_question")] WHERE [(isadmin ? "" : "adminonly = false AND")] Now() BETWEEN starttime AND endtime AND id NOT IN (SELECT pollid FROM [format_table_name("poll_vote")] WHERE ckey = \"[sanitizeSQL(ckey)]\") AND id NOT IN (SELECT pollid FROM [format_table_name("poll_textreply")] WHERE ckey = \"[sanitizeSQL(ckey)]\")")
			if(query_get_new_polls.Execute())
				var/newpoll = FALSE
				if(query_get_new_polls.NextRow())
					newpoll = TRUE

				if(newpoll)
					output += "<p><b><a href='byond://?src=[REF(src)];showpoll=1'>Show Player Polls</A> (NEW!)</b></p>"
				else
					output += "<p><a href='byond://?src=[REF(src)];showpoll=1'>Show Player Polls</A></p>"
			qdel(query_get_new_polls)
			if(QDELETED(src))
				return

	output += "</div>"

	var/datum/browser/popup = new(src, "playersetup", "<div align='center'>New Player Options</div>", 240, 300)
	popup.set_window_options("can_close=0")
	popup.set_content(output)
	popup.open(FALSE)


/mob/new_player/Stat()
	. = ..()

	if(!SSticker)
		return

	if(statpanel("Stats"))
		stat("Game Mode:", "[GLOB.master_mode]")

		if(SSticker.current_state == GAME_STATE_PREGAME)
			stat("Time To Start:", "[going ? SSticker.GetTimeLeft() : "(DELAYED)"]")
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
			new_player_panel()


		if("refresh")
			src << browse(null, "window=playersetup")
			new_player_panel()


		if("observe")
			if(!SSticker || SSticker.current_state == GAME_STATE_STARTUP)
				to_chat(src, "<span class='warning'>The game is still setting up, please try again later.</span>")
				return
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

				observer.alpha = 127

				var/datum/species/species = GLOB.all_species[client.prefs.species] || GLOB.all_species[DEFAULT_SPECIES]

				if(is_banned_from(ckey, "Appearance") || !client?.prefs)
					species = GLOB.all_species[DEFAULT_SPECIES]
					observer.real_name = species.random_name()
				else if(client.prefs)
					if(client.prefs.random_name)
						observer.real_name = species.random_name(client.prefs.gender)
					else
						observer.real_name = client.prefs.real_name
				else
					observer.real_name = species.random_name()

				observer.name = observer.real_name

				mind.transfer_to(observer, TRUE)
				qdel(src)


		if("late_join")
			if(!SSticker?.mode || SSticker.current_state != GAME_STATE_PLAYING)
				to_chat(src, "<span class='warning'>The round is either not ready, or has already finished.</span>")
				return

			if(SSticker.mode.flags_round_type	& MODE_NO_LATEJOIN)
				to_chat(src, "<span class='warning'>Sorry, you cannot late join during [SSticker.mode.name]. You have to start at the beginning of the round. You may observe or try to join as an alien, if possible.</span>")
				return

			LateChoices()


		if("late_join_xeno")
			if(!SSticker?.mode || SSticker.current_state != GAME_STATE_PLAYING)
				to_chat(src, "<span class='warning'>The round is either not ready, or has already finished.</span>")
				return

			if(jobban_isbanned(src, ROLE_XENOMORPH) || is_banned_from(ckey, ROLE_XENOMORPH))
				to_chat(src, "<span class='warning'>You are jobbaned from the [ROLE_XENOMORPH] role.</span>")
				return

			switch(alert("Would you like to try joining as a burrowed larva or as a living xenomorph?", "Select", "Burrowed Larva", "Living Xenomorph", "Cancel"))
				if("Burrowed Larva")
					if(SSticker.mode.attempt_to_join_as_larva(src))
						close_spawn_windows()
						SSticker.mode.spawn_larva(src)
				if("Living Xenomorph")
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

			AttemptLateSpawn(href_list["job_selected"])


	if(href_list["showpoll"])
		handle_player_polling()
		return

	if(href_list["pollid"])
		var/pollid = href_list["pollid"]
		if(istext(pollid))
			pollid = text2num(pollid)
		if(isnum(pollid) && ISINTEGER(pollid))
			poll_player(pollid)
		return

	if(href_list["votepollid"] && href_list["votetype"])
		var/pollid = text2num(href_list["votepollid"])
		var/votetype = href_list["votetype"]
		//lets take data from the user to decide what kind of poll this is, without validating it
		//what could go wrong
		switch(votetype)
			if(POLLTYPE_OPTION)
				var/optionid = text2num(href_list["voteoptionid"])
				if(vote_on_poll(pollid, optionid))
					to_chat(usr, "<span class='notice'>Vote successful.</span>")
				else
					to_chat(usr, "<span class='danger'>Vote failed, please try again or contact an administrator.</span>")
			if(POLLTYPE_TEXT)
				var/replytext = href_list["replytext"]
				if(log_text_poll_reply(pollid, replytext))
					to_chat(usr, "<span class='notice'>Feedback logging successful.</span>")
				else
					to_chat(usr, "<span class='danger'>Feedback logging failed, please try again or contact an administrator.</span>")
			if(POLLTYPE_RATING)
				var/id_min = text2num(href_list["minid"])
				var/id_max = text2num(href_list["maxid"])

				if((id_max - id_min) > 100)	//Basic exploit prevention
					to_chat(usr, "The option ID difference is too big. Please contact administration or the database admin.")
					return

				for(var/optionid = id_min; optionid <= id_max; optionid++)
					if(!isnull(href_list["o[optionid]"]))	//Test if this optionid was replied to
						var/rating
						if(href_list["o[optionid]"] == "abstain")
							rating = null
						else
							rating = text2num(href_list["o[optionid]"])
							if(!isnum(rating) || !ISINTEGER(rating))
								return

						if(!vote_on_numval_poll(pollid, optionid, rating))
							to_chat(usr, "<span class='danger'>Vote failed, please try again or contact an administrator.</span>")
							return
				to_chat(usr, "<span class='notice'>Vote successful.</span>")
			if(POLLTYPE_MULTI)
				var/id_min = text2num(href_list["minoptionid"])
				var/id_max = text2num(href_list["maxoptionid"])

				if((id_max - id_min) > 100)	//Basic exploit prevention
					to_chat(usr, "The option ID difference is too big. Please contact administration or the database admin.")
					return

				for(var/optionid = id_min; optionid <= id_max; optionid++)
					if(!isnull(href_list["option_[optionid]"]))	//Test if this optionid was selected
						var/i = vote_on_multi_poll(pollid, optionid)
						switch(i)
							if(0)
								continue
							if(1)
								to_chat(usr, "<span class='danger'>Vote failed, please try again or contact an administrator.</span>")
								return
							if(2)
								to_chat(usr, "<span class='danger'>Maximum replies reached.</span>")
								break
				to_chat(usr, "<span class='notice'>Vote successful.</span>")
			if(POLLTYPE_IRV)
				if(!href_list["IRVdata"])
					to_chat(src, "<span class='danger'>No ordering data found. Please try again or contact an administrator.</span>")
					return
				var/list/votelist = splittext(href_list["IRVdata"], ",")
				if(!vote_on_irv_poll(pollid, votelist))
					to_chat(src, "<span class='danger'>Vote failed, please try again or contact an administrator.</span>")
					return
				to_chat(src, "<span class='notice'>Vote successful.</span>")


/mob/new_player/proc/AttemptLateSpawn(rank)
	if(src != usr)
		return
	if(!IsJobAvailable(rank))
		to_chat(usr, "<span class='warning'>Selected job is not available.<spawn>")
		return
	if(!SSticker || SSticker.current_state != GAME_STATE_PLAYING)
		to_chat(usr, "<span class='warning'>The round is either not ready, or has already finished!<spawn>")
		return
	if(!GLOB.enter_allowed)
		to_chat(usr, "<span class='warning'>Spawning currently disabled, please observe.<spawn>")
		return

	if(!SSjob.AssignRole(src, rank, TRUE))
		to_chat(usr, "<span class='warning'>Failed to assign selected role.<spawn>")
		return

	close_spawn_windows()
	spawning = TRUE

	var/mob/living/character = create_character(TRUE)	//creates the human and transfers vars and mind
	var/equip = SSjob.EquipRank(character, rank, TRUE)
	if(isliving(equip))	//Borgs get borged in the equip, so we need to make sure we handle the new mob.
		character = equip

	var/datum/job/job = SSjob.GetJob(rank)

	if(job && !job.override_latejoin_spawn(character))
		SSjob.SendToLateJoin(character)

	GLOB.datacore.manifest_inject(character)
	SSticker.minds += character.mind

	if(isdistress(SSticker?.mode))
		var/datum/game_mode/distress/D = SSticker.mode
		D.latejoin_tally++

		if(D.latejoin_larva_drop && D.latejoin_tally >= D.latejoin_larva_drop)
			D.latejoin_tally -= D.latejoin_larva_drop
			var/datum/hive_status/normal/HS = GLOB.hive_datums[XENO_HIVE_NORMAL]
			HS.stored_larva++

	qdel(src)


/mob/new_player/proc/LateChoices()
	var/dat = "<html><body><center>"
	dat += "Round Duration: [worldtime2text()]<br>"

	if(SSevacuation)
		switch(SSevacuation.evac_status)
			if(EVACUATION_STATUS_INITIATING)
				dat += "<font color='red'><b>The [CONFIG_GET(string/ship_name)] is being evacuated.</b></font><br>"
			if(EVACUATION_STATUS_COMPLETE)
				dat += "<font color='red'>The [CONFIG_GET(string/ship_name)] has undergone evacuation.</font><br>"

	dat += "Choose from the following open positions:<br>"
	var/datum/job/J
	for(var/i in sortList(SSjob.occupations, /proc/cmp_job_display_asc))
		J = i
		if(!(J.title in JOBS_REGULAR_ALL))
			continue
		if((J.current_positions >= J.spawn_positions) && J.spawn_positions != -1)
			continue
		var/active = 0
		//Only players with the job assigned and AFK for less than 10 minutes count as active
		for(var/mob/M in GLOB.player_list)
			if(M.mind && M.client && M.mind.assigned_role == J.title && M.client.inactivity <= 10 MINUTES)
				active++
		dat += "<a href='byond://?src=\ref[src];lobby_choice=SelectedJob;job_selected=[J.title]'>[J.title] ([J.current_positions]) (Active: [active])</a><br>"

	dat += "</center>"
	var/datum/browser/popup = new(src, "latechoices", "<div align='center'>Join the TGMC</div>", 300, 640)
	popup.set_content(dat)
	popup.open(FALSE)


/mob/new_player/proc/ViewManifest()
	var/dat = GLOB.datacore.get_manifest(ooc = TRUE)

	var/datum/browser/popup = new(src, "manifest", "<div align='center'>Crew Manifest</div>", 400, 420)
	popup.set_content(dat)
	popup.open(FALSE)


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
	return chosen_species


/mob/new_player/get_gender()
	if(!client?.prefs)
		. = ..()
	return client.prefs.gender


/mob/new_player/is_ready()
	return ready && ..()


/mob/new_player/hear_say(message, verb = "says", datum/language/language = null, alt_name = "", italics = FALSE, mob/speaker = null)
	return


/mob/new_player/hear_radio(message, verb = "says", datum/language/language = null, part_a, part_b, mob/speaker = null, hard_to_hear = FALSE)
	return


/mob/new_player/proc/create_character(transfer_after)
	spawning = TRUE
	close_spawn_windows()

	var/mob/living/carbon/human/H = new(loc)


	if(!is_banned_from(ckey, "Appearance"))
		client.prefs.copy_to(H)
	if(mind)
		if(transfer_after)
			mind.late_joiner = TRUE
		mind.active = FALSE					//we wish to transfer the key manually
		mind.transfer_to(H)					//won't transfer key since the mind is not active

	. = H
	new_character = .
	if(transfer_after)
		transfer_character()


/mob/new_player/proc/transfer_character()
	. = new_character
	if(.)
		new_character.key = key		//Manually transfer the key to log them in
		new_character = null
		qdel(src)


/mob/new_player/proc/IsJobAvailable(rank, latejoin = FALSE)
	var/datum/job/job = SSjob.GetJob(rank)
	if(!job)
		return FALSE
	if((job.current_positions >= job.total_positions) && job.total_positions != -1)
		for(var/datum/job/J in SSjob.occupations)
			if(J && J.current_positions < J.total_positions && J.title != job.title)
				return FALSE
	if(jobban_isbanned(src, rank))
		return FALSE
	if(is_banned_from(ckey, rank))
		return FALSE
	if(QDELETED(src))
		return FALSE
	if(!job.player_old_enough(client))
		return FALSE
	if(job.required_playtime_remaining(client))
		return FALSE
	if(latejoin && !job.special_check_latejoin(client))
		return FALSE
	return TRUE