/mob/new_player
	invisibility = INVISIBILITY_MAXIMUM
	stat = DEAD
	density = FALSE
	canmove = FALSE
	anchored = TRUE
	var/datum/job/assigned_role
	var/datum/squad/assigned_squad
	var/mob/living/new_character
	var/ready = FALSE
	var/spawning = FALSE


/mob/new_player/Initialize()
	if(length(GLOB.newplayer_start))
		var/turf/spawn_loc = get_turf(pick(GLOB.newplayer_start))
		forceMove(spawn_loc)
	else
		forceMove(locate(1, 1, 1))
	lastarea = get_area(loc)
	GLOB.new_player_list += src
	return ..()


/mob/new_player/Destroy()
	if(ready)
		GLOB.ready_players -= src
	GLOB.new_player_list -= src
	assigned_role = null
	assigned_squad = null
	new_character = null
	return ..()


/mob/new_player/proc/new_player_panel()

	if(SSticker?.mode?.mode_new_player_panel(src))
		return

	var/output = "<div align='center'>"
	output += "<br><i>You are part of the <b>TerraGov Marine Corps</b>, a military branch of the TerraGov council.</i>"
	output +="<hr>"
	output += "<p><a href='byond://?src=[REF(src)];lobby_choice=show_preferences'>Setup Character</A> | <a href='byond://?src=[REF(src)];lobby_choice=lore'>Background</A><br><br><a href='byond://?src=[REF(src)];lobby_choice=observe'>Observe</A></p>"
	output +="<hr>"
	output += "<center><p>Current character: <b>[client ? client.prefs.real_name : "Unknown User"]</b></p>"

	if(!SSticker?.mode || SSticker.current_state <= GAME_STATE_PREGAME)
		output += "<p>\[ [ready? "<b>Ready</b>":"<a href='byond://?src=\ref[src];lobby_choice=ready'>Ready</a>"] | [ready? "<a href='byond://?src=[REF(src)];lobby_choice=ready'>Not Ready</a>":"<b>Not Ready</b>"] \]</p>"
	else
		output += "<a href='byond://?src=[REF(src)];lobby_choice=manifest'>View the Crew Manifest</A><br>"
		output += "<p><a href='byond://?src=[REF(src)];lobby_choice=late_join'>Join the Game!</A></p>"

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

	var/datum/browser/popup = new(src, "playersetup", "<div align='center'>Welcome to TGMC[SSmapping?.configs ? " - [SSmapping.configs[SHIP_MAP].map_name]" : ""]</div>", 300, 375)
	popup.set_window_options("can_close=0")
	popup.set_content(output)
	popup.open(FALSE)

/mob/new_player/Stat()
	. = ..()

	if(!SSticker)
		return

	if(statpanel("Status"))
		stat("Game Mode:", "[GLOB.master_mode]")

		if(SSticker.current_state == GAME_STATE_PREGAME)
			stat("Time To Start:", "[SSticker.time_left > 0 ? SSticker.GetTimeLeft() : "(DELAYED)"]")
			stat("Players: [length(GLOB.player_list)]", "Players Ready: [length(GLOB.ready_players)]")
			for(var/i in GLOB.player_list)
				if(isnewplayer(i))
					var/mob/new_player/N = i
					stat("[N.client?.holder?.fakekey ? N.client.holder.fakekey : N.key]", N.ready ? "Playing" : "")
				else if(isobserver(i))
					var/mob/dead/observer/O = i
					stat("[O.client?.holder?.fakekey ? O.client.holder.fakekey : O.key]", "Observing")


/mob/new_player/Topic(href, href_list[])
	. = ..()
	if(.)
		return
	if(!client)
		return

	if(src != usr)
		return

	if(SSticker?.mode?.new_player_topic(src, href, href_list))
		return // Delegate to the gamemode to handle if they want to

	//Determines Relevent Population Cap
	var/relevant_cap
	var/hpc = CONFIG_GET(number/hard_popcap)
	var/epc = CONFIG_GET(number/extreme_popcap)
	if(hpc && epc)
		relevant_cap = min(hpc, epc)
	else
		relevant_cap = max(hpc, epc)

	switch(href_list["lobby_choice"])
		if("show_preferences")
			client.prefs.ShowChoices(src)


		if("ready")
			if(!SSticker || SSticker.current_state <= GAME_STATE_PREGAME)
				ready = !ready
				if(ready)
					GLOB.ready_players += src
				else
					GLOB.ready_players -= src
			new_player_panel()


		if("refresh")
			src << browse(null, "window=playersetup")
			new_player_panel()


		if("observe")
			if(!SSticker || SSticker.current_state == GAME_STATE_STARTUP)
				to_chat(src, "<span class='warning'>The game is still setting up, please try again later.</span>")
				return
			if(alert("Are you sure you wish to observe?[SSticker.mode?.observe_respawn_message()]", "Observe", "Yes", "No") == "Yes")
				if(!client)
					return TRUE
				var/mob/dead/observer/observer = new()

				spawning = TRUE
				observer.started_as_observer = TRUE

				close_spawn_windows()

				var/failed = FALSE

				if(length(GLOB.latejoin))
					var/i = pick(GLOB.latejoin)
					var/turf/T = get_turf(i)
					if(!T)
						CRASH("Invalid latejoin spawn location type")

					to_chat(src, "<span class='notice'>Now teleporting.</span>")
					observer.forceMove(T)
				else
					failed = TRUE

				if(failed)
					to_chat(src, "<span class='danger'>Could not locate an observer spawn point. Use the Teleport verb to jump.</span>")

				observer.timeofdeath = world.time

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

			if(SSticker.mode.flags_round_type & MODE_NO_LATEJOIN)
				to_chat(src, "<span class='warning'>Sorry, you cannot late join during [SSticker.mode.name]. You have to start at the beginning of the round. You may observe or try to join as an alien, if possible.</span>")
				return

			if(href_list["override"])
				LateChoices()
				return

			if(length(SSticker.queued_players) || (relevant_cap && living_player_count() >= relevant_cap && !(check_rights(R_ADMIN, FALSE) || GLOB.deadmins[ckey])))
				to_chat(usr, "<span class='danger'>[CONFIG_GET(string/hard_popcap_message)]</span>")

				var/queue_position = SSticker.queued_players.Find(usr)
				if(queue_position == 1)
					to_chat(usr, "<span class='notice'>You are next in line to join the game. You will be notified when a slot opens up.</span>")
				else if(queue_position)
					to_chat(usr, "<span class='notice'>There are [queue_position - 1] players in front of you in the queue to join the game.</span>")
				else
					SSticker.queued_players += usr
					to_chat(usr, "<span class='notice'>You have been added to the queue to join the game. Your position in queue is [length(SSticker.queued_players)].</span>")
				return
			LateChoices()

		if("manifest")
			ViewManifest()

		if("lore")
			ViewLore()

		if("marines")
			ViewMarines()

		if("aliens")
			ViewAliens()

		if("SelectedJob")
			if(!SSticker)
				return
			if(!GLOB.enter_allowed)
				to_chat(usr, "<span class='warning'>Spawning currently disabled, please observe.</span>")
				return
			var/datum/job/job_datum = locate(href_list["job_selected"])
			if(!SSticker.mode.CanLateSpawn(src, job_datum)) // Try to assigns job to new player
				return
			SSticker.mode.LateSpawn(src)


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

/datum/game_mode/proc/observe_respawn_message()
	return "\nYou might have to wait a certain time to respawn or be unable to, depending on the game mode!"

/datum/game_mode/infestation/observe_respawn_message()
	return "\nYou will have to wait at least [GLOB.respawntime * 0.1] or [GLOB.xenorespawntime * 0.1] seconds before being able to respawn as a marine or alien, respectively!"

/mob/new_player/proc/LateChoices()
	var/list/dat = list("<div class='notice'>Round Duration: [DisplayTimeText(world.time - SSticker.round_start_time)]</div>")
	if(!GLOB.enter_allowed)
		dat += "<div class='notice red'>You may no longer join the round.</div><br>"
	dat += "<div class='latejoin-container' style='width: 100%'>"
	for(var/cat in SSjob.active_joinable_occupations_by_category)
		var/list/category = SSjob.active_joinable_occupations_by_category[cat]
		var/datum/job/job_datum = category[1] //use the color of the first job in the category (the department head) as the category color
		dat += "<fieldset class='latejoin' style='border-color: [job_datum.selection_color]'>"
		dat += "<legend align='center' style='color: [job_datum.selection_color]'>[job_datum.job_category]</legend>"
		var/list/dept_dat = list()
		for(var/job in category)
			job_datum = job
			if(!IsJobAvailable(job_datum, TRUE))
				continue
			var/command_bold = ""
			if(job_datum.job_flags & JOB_FLAG_BOLD_NAME_ON_SELECTION)
				command_bold = " command"
			dept_dat += "<a class='job[command_bold]' href='byond://?src=[REF(src)];lobby_choice=SelectedJob;job_selected=[REF(job_datum)]'>[job_datum.title] ([job_datum.job_flags & JOB_FLAG_HIDE_CURRENT_POSITIONS ? "?" : job_datum.current_positions])</a>"
		if(!length(dept_dat))
			dept_dat += "<span class='nopositions'>No positions open.</span>"
		dat += jointext(dept_dat, "")
		dat += "</fieldset><br>"
	dat += "</div>"
	var/datum/browser/popup = new(src, "latechoices", "Choose Occupation", 680, 580)
	popup.add_stylesheet("latechoices", 'html/browser/latechoices.css')
	popup.set_content(jointext(dat, ""))
	popup.open(FALSE)


/mob/new_player/proc/ViewManifest()
	var/dat = GLOB.datacore.get_manifest(ooc = TRUE)

	var/datum/browser/popup = new(src, "manifest", "<div align='center'>Crew Manifest</div>", 400, 420)
	popup.set_content(dat)
	popup.open(FALSE)

/mob/new_player/proc/ViewLore()
	var/output = "<div align='center'>"
	output += "<a href='byond://?src=[REF(src)];lobby_choice=marines'>TerraGov Marine Corps</A><br><br><a href='byond://?src=[REF(src)];lobby_choice=aliens'>Xenomorph Hive</A>"
	output += "</div>"

	var/datum/browser/popup = new(src, "lore", "<div align='center'>Current Year: 2415</div>", 240, 300)
	popup.set_content(output)
	popup.open(FALSE)

/mob/new_player/proc/ViewMarines()
	var/output = "<div align='center'>"
	output += "<p><i>The <b>TerraGov Marine Corps'</b> mission is to enforce space law for the purpose of defending Terra's orbit as well as other solar colonies around the galaxy under the conflict of the Independent Colonial Confederation and the intelligent xenomorph threat. \nThe TGMC is composed by willing men and women from all kinds of social strata, hailing from all across the TerraGov systems. \nAs the vessel approaches to the ordered location on space, the cryostasis pods deactivate and awake you from your long-term stasis. Knowing that it's one of those days again, you hope that you'll make this out alive...</i></p>"
	output += "</div>"

	var/datum/browser/popup = new(src, "marines", "<div align='center'>TerraGov Marine Corps</div>", 480, 280)
	popup.set_content(output)
	popup.open(FALSE)

/mob/new_player/proc/ViewAliens()
	var/output = "<div align='center'>"
	output += "<p><i>Hailing from one of many unknown planets and other unlisted habitats, the <b>xenomorph threat</b> remains at large and still unclear. Extremely dangerous extraterrestrial lifeforms, part of the hive under the Queen Mother, had caught the TGMC and NT colonies off-guard during their discovery in 2414. \nThey are divided into castes, each with their specialized roles equivalent to a traditional squad member in a human force, thanks to the xenomorph's lifecycle. \nAfter days of ravaging the current area, a metal hive was sighted by the Queen Mother and transported you on the ground. With your intent to spread the hive is in motion, you and your fellow sisters get to work...</i></p>"
	output += "</div>"

	var/datum/browser/popup = new(src, "aliens", "<div align='center'>Xenomorph Hive</div>", 480, 280)
	popup.set_content(output)
	popup.open(FALSE)




/mob/new_player/Move()
	return FALSE


/mob/new_player/proc/close_spawn_windows(mob/user)
	if(!user)
		user = src
	DIRECT_OUTPUT(user, browse(null, "window=latechoices")) //closes late choices window
	DIRECT_OUTPUT(user, browse(null, "window=playersetup")) //closes the player setup window
	user.stop_sound_channel(CHANNEL_LOBBYMUSIC)


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


/mob/new_player/Hear()
	return


/mob/new_player/proc/create_character()
	if(!assigned_role)
		CRASH("create_character called for [key] without an assigned_role")
	spawning = TRUE
	close_spawn_windows()
	var/spawn_type = assigned_role.return_spawn_type(client.prefs)
	var/mob/living/spawning_living = new spawn_type()
	GLOB.joined_player_list += ckey

	spawning_living.on_spawn(src)

	new_character = spawning_living


/mob/living/proc/on_spawn(mob/new_player/summoner)
	return

/mob/living/carbon/human/on_spawn(mob/new_player/summoner)
	if(!is_banned_from(summoner.ckey, "Appearance") && summoner.client)
		summoner.client.prefs.copy_to(src)
	update_names_joined_list(real_name)

/mob/living/silicon/ai/on_spawn(mob/new_player/summoner)
	if(!is_banned_from(summoner.ckey, "Appearance") && summoner.client?.prefs?.ai_name)
		fully_replace_character_name(real_name, summoner.client.prefs.ai_name)
	update_names_joined_list(real_name)


/mob/new_player/proc/transfer_character()
	. = new_character
	if(.)
		mind.transfer_to(new_character, TRUE) //Manually transfer the key to log them in
		qdel(src)


/mob/new_player/proc/IsJobAvailable(datum/job/job, latejoin = FALSE)
	if(!job)
		return FALSE
	if((job.current_positions >= job.total_positions) && job.total_positions != -1)
		return FALSE
	if(is_banned_from(ckey, job.title))
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
