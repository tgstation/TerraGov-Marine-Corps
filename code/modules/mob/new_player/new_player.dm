/mob/new_player
	invisibility = INVISIBILITY_MAXIMUM
	stat = DEAD
	density = FALSE
	canmove = FALSE
	anchored = TRUE
	hud_type = /datum/hud/new_player
	var/datum/job/assigned_role
	var/datum/squad/assigned_squad
	var/mob/living/new_character
	var/ready = FALSE
	var/spawning = FALSE
	///The job we tried to join but were warned it would cause an unbalance. It's saved for later use
	var/datum/job/saved_job


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


/mob/new_player/proc/check_playerpolls()
	var/output
	if (SSdbcore.Connect())
		var/isadmin = FALSE
		if(client?.holder)
			isadmin = TRUE
		var/datum/db_query/query_get_new_polls = SSdbcore.NewQuery({"
			SELECT id FROM [format_table_name("poll_question")]
			WHERE (adminonly = 0 OR :isadmin = 1)
			AND Now() BETWEEN starttime AND endtime
			AND deleted = 0
			AND id NOT IN (
				SELECT pollid FROM [format_table_name("poll_vote")]
				WHERE ckey = :ckey
				AND deleted = 0
			)
			AND id NOT IN (
				SELECT pollid FROM [format_table_name("poll_textreply")]
				WHERE ckey = :ckey
				AND deleted = 0
			)
		"}, list("isadmin" = isadmin, "ckey" = ckey))
		if(!query_get_new_polls.Execute())
			qdel(query_get_new_polls)
			return
		if(query_get_new_polls.NextRow())
			output = TRUE
		else
			output = FALSE
		qdel(query_get_new_polls)
		if(QDELETED(src))
			return null
		return output

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

	switch(href_list["lobby_choice"])
		if("show_preferences")
			client.prefs.ShowChoices(src)


		if("ready")
			toggle_ready()


		if("refresh")
			src << browse(null, "window=playersetup")


		if("observe")
			try_to_observe()


		if("late_join")
			attempt_late_join(href_list["override"])

		if("manifest")
			view_manifest()

		if("lore")
			view_lore()

		if("marines")
			view_marines()

		if("aliens")
			view_aliens()

		if("SelectedJob")
			if(!SSticker)
				return
			if(!GLOB.enter_allowed)
				to_chat(usr, "<span class='warning'>Spawning currently disabled, please observe.</span>")
				return
			var/datum/job/job_datum = locate(href_list["job_selected"])
			if(!isxenosjob(job_datum) && (SSmonitor.current_state == XENOS_LOSING || SSmonitor.current_state == XENOS_DELAYING))
				var/datum/job/xeno_job = SSjob.GetJobType(/datum/job/xenomorph)
				if((xeno_job.total_positions-xeno_job.current_positions) >= 3)
					if(tgui_alert(src, "There is a lack of xenos players on this round, unbalanced rounds are unfun for everyone. Are you sure you want to play as a marine? ", "Warning : the game is unbalanced", list("Yes", "No")) == "No")
						return
			if(!SSticker.mode.CanLateSpawn(src, job_datum)) // Try to assigns job to new player
				return
			SSticker.mode.LateSpawn(src)
		
		if("continue_join")
			DIRECT_OUTPUT(usr, browse(null, "window=xenosunbalanced"))
			if(!saved_job)
				return	
			if(!SSticker.mode.CanLateSpawn(src, saved_job)) // Try to assigns job to new player
				return
			SSticker.mode.LateSpawn(src)
		
		if("reconsider")
			DIRECT_OUTPUT(usr, browse(null, "window=xenosunbalanced"))

	if(href_list["showpoll"])
		handle_playeR_DBRANKSing()
		return

	if(href_list["viewpoll"])
		var/datum/poll_question/poll = locate(href_list["viewpoll"]) in GLOB.polls
		poll_player(poll)

	if(href_list["votepollref"])
		var/datum/poll_question/poll = locate(href_list["votepollref"]) in GLOB.polls
		vote_on_poll_handler(poll, href_list)

/datum/game_mode/proc/observe_respawn_message()
	return "\nYou might have to wait a certain time to respawn or be unable to, depending on the game mode!"

/datum/game_mode/infestation/observe_respawn_message()
	return "\nYou will have to wait at least [GLOB.respawntime * 0.1] or [GLOB.xenorespawntime * 0.1] seconds before being able to respawn as a marine or alien, respectively!"

/mob/new_player/proc/late_choices()
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


/mob/new_player/proc/view_manifest()
	var/dat = GLOB.datacore.get_manifest(ooc = TRUE)

	var/datum/browser/popup = new(src, "manifest", "<div align='center'>Crew Manifest</div>", 400, 420)
	popup.set_content(dat)
	popup.open(FALSE)

/mob/new_player/proc/view_lore()
	var/output = "<div align='center'>"
	output += "<a href='byond://?src=[REF(src)];lobby_choice=marines'>TerraGov Marine Corps</A><br><br><a href='byond://?src=[REF(src)];lobby_choice=aliens'>Xenomorph Hive</A>"
	output += "</div>"

	var/datum/browser/popup = new(src, "lore", "<div align='center'>Current Year: [GAME_YEAR]</div>", 240, 300)
	popup.set_content(output)
	popup.open(FALSE)

/mob/new_player/proc/view_marines()
	var/output = "<div align='center'>"
	output += "<p><i>The <b>TerraGov Marine Corps'</b> mission is to enforce space law for the purpose of defending Terra's orbit as well as other solar colonies around the galaxy under the conflict of the Independent Colonial Confederation and the intelligent xenomorph threat. \nThe TGMC is composed by willing men and women from all kinds of social strata, hailing from all across the TerraGov systems. \nAs the vessel approaches to the ordered location on space, the cryostasis pods deactivate and awake you from your long-term stasis. Knowing that it's one of those days again, you hope that you'll make this out alive...</i></p>"
	output += "</div>"

	var/datum/browser/popup = new(src, "marines", "<div align='center'>TerraGov Marine Corps</div>", 480, 280)
	popup.set_content(output)
	popup.open(FALSE)

/mob/new_player/proc/view_aliens()
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

/mob/new_player/proc/try_to_observe()
	if(!SSticker || SSticker.current_state == GAME_STATE_STARTUP)
		to_chat(src, "<span class='warning'>The game is still setting up, please try again later.</span>")
		return
	if(tgui_alert(src, "Are you sure you wish to observe?[SSticker.mode?.observe_respawn_message()]", "Observe", list("Yes", "No")) != "Yes")
		return
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
		species = GLOB.roundstart_species[DEFAULT_SPECIES]
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

///Toggles the new players ready state
/mob/new_player/proc/toggle_ready()
	if(SSticker?.current_state > GAME_STATE_PREGAME)
		to_chat(src, "<span class='warning'>The round has already started.</span>")
		return
	ready = !ready
	if(ready)
		GLOB.ready_players += src
	else
		GLOB.ready_players -= src
	to_chat(src, "<span class='warning'>You are now [ready? "" : "not "] ready.</span>")

///Attempts to latejoin the player
/mob/new_player/proc/attempt_late_join(queue_override = FALSE)
	if(!SSticker?.mode || SSticker.current_state != GAME_STATE_PLAYING)
		to_chat(src, "<span class='warning'>The round is either not ready, or has already finished.</span>")
		return

	if(SSticker.mode.flags_round_type & MODE_NO_LATEJOIN)
		to_chat(src, "<span class='warning'>Sorry, you cannot late join during [SSticker.mode.name]. You have to start at the beginning of the round. You may observe or try to join as an alien, if possible.</span>")
		return

	if(queue_override)
		late_choices()
		return
	var/relevant_cap
	var/hpc = CONFIG_GET(number/hard_popcap)
	var/epc = CONFIG_GET(number/extreme_popcap)
	if(hpc && epc)
		relevant_cap = min(hpc, epc)
	else
		relevant_cap = max(hpc, epc)

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
	late_choices()
