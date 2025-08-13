/mob/new_player
	invisibility = INVISIBILITY_ABSTRACT
	lighting_cutoff = LIGHTING_CUTOFF_FULLBRIGHT
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


/mob/new_player/Initialize(mapload)
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

/mob/new_player/get_status_tab_items()
	. = ..()

	if(!SSticker)
		return

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

		if("Take SSD Mob")
			take_ssd_mob()

		if("late_join")
			attempt_late_join(href_list["override"])

		if("manifest")
			view_manifest()

		if("xenomanifest")
			view_xeno_manifest()

		if("lore")
			view_lore()

		if("marines")
			view_marines()

		if("aliens")
			view_aliens()

		if("som")
			view_som()

		if("SelectedJob")
			if(!SSticker)
				return
			if(!GLOB.enter_allowed)
				to_chat(usr, span_warning("Spawning currently disabled."))
				return
			var/datum/job/job_datum = locate(href_list["job_selected"])
			if(!isxenosjob(job_datum) && (SSmonitor.gamestate == SHUTTERS_CLOSED || (SSmonitor.gamestate == GROUNDSIDE && SSmonitor.current_state <= XENOS_LOSING)))
				var/datum/job/xeno_job = SSjob.GetJobType(/datum/job/xenomorph)
				if((xeno_job.total_positions-xeno_job.current_positions) > length(GLOB.alive_xeno_list_hive[XENO_HIVE_NORMAL]) * TOO_MUCH_BURROWED_PROPORTION)
					if(tgui_alert(src, "There is a lack of xeno players on this round, unbalanced rounds are unfun for everyone. Are you sure you want to play as a marine? ", "Warning : the game is unbalanced", list("Yes", "No")) != "Yes")
						return
			if(isxenosjob(job_datum))
				if(XENODEATHTIME_CHECK(usr))
					if(check_other_rights(usr.client, R_ADMIN, FALSE))
						if(tgui_alert(usr, "Your xeno respawn timer is not finished, though as an admin you can bypass it. Do you want to continue?", "Join Game", list("Yes", "No")) != "Yes")
							XENODEATHTIME_MESSAGE(usr)
							return
			else
				if(DEATHTIME_CHECK(usr))
					if(check_other_rights(usr.client, R_ADMIN, FALSE))
						if(tgui_alert(usr, "Your respawn timer is not finished, though as an admin you can bypass it. Do you want to continue?", "Join Game", list("Yes", "No")) != "Yes")
							DEATHTIME_MESSAGE(usr)
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
		handle_playeR_POLLSing()
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
	. = "\nYou will have to wait at least [SSticker.mode?.respawn_time * 0.1 / 60] minutes before being able to respawn as a marine!"
	var/datum/hive_status/normal_hive = GLOB.hive_datums[XENO_HIVE_NORMAL]
	if(!normal_hive)
		return
	if(length(normal_hive.candidates) <= 2)
		return
	. += " There are [length(normal_hive.candidates)] people in the larva queue."


/mob/new_player/proc/late_choices()
	var/list/dat = list("<div class='notice'>Round Duration: [DisplayTimeText(world.time - SSticker.round_start_time)]</div>")
	if(!GLOB.enter_allowed)
		dat += "<div class='notice red'>You may no longer join the round.</div><br>"
	var/forced_faction
	if(SSticker.mode.round_type_flags & MODE_TWO_HUMAN_FACTIONS)
		if(faction in SSticker.mode.get_joinable_factions(FALSE))
			forced_faction = faction
		else
			forced_faction = tgui_input_list(src, "What faction do you want to join", "Faction choice", SSticker.mode.get_joinable_factions(TRUE))
			if(!forced_faction)
				return
	dat += "<div class='latejoin-container' style='width: 100%'>"
	for(var/cat in SSjob.active_joinable_occupations_by_category)
		var/list/category = SSjob.active_joinable_occupations_by_category[cat]
		var/datum/job/job_datum = category[1] //use the color of the first job in the category (the department head) as the category color
		dat += "<fieldset class='latejoin' style='border-color: [job_datum.selection_color]'>"
		dat += "<legend align='center' style='color: [job_datum.selection_color]'>[job_datum.job_category]</legend>"
		var/list/dept_dat = list()
		for(var/job in category)
			job_datum = job
			if(!IsJobAvailable(job_datum, TRUE, forced_faction))
				continue
			var/command_bold = ""
			if(job_datum.job_flags & JOB_FLAG_BOLD_NAME_ON_SELECTION)
				command_bold = " command"
			var/position_amount
			if(job_datum.job_flags & JOB_FLAG_HIDE_CURRENT_POSITIONS)
				position_amount = "?"
			else if(job_datum.job_flags & JOB_FLAG_SHOW_OPEN_POSITIONS)
				position_amount = "[job_datum.total_positions - job_datum.current_positions] open positions"
			else
				position_amount = job_datum.current_positions
			dept_dat += "<a class='job[command_bold]' href='byond://?src=[REF(src)];lobby_choice=SelectedJob;job_selected=[REF(job_datum)]'>[job_datum.title] ([position_amount])</a>"
		if(!length(dept_dat))
			dept_dat += span_nopositions("No positions open.")
		dat += jointext(dept_dat, "")
		dat += "</fieldset><br>"
	dat += "</div>"
	var/datum/browser/popup = new(src, "latechoices", "Choose Occupation", 680, 580)
	popup.add_stylesheet("latechoices", 'html/browser/latechoices.css')
	popup.set_content(jointext(dat, ""))
	popup.open(FALSE)


/mob/new_player/proc/view_manifest()
	var/dat = GLOB.datacore.get_manifest(ooc = TRUE)

	var/datum/browser/popup = new(src, "manifest", "<div align='center'>Game Manifest</div>", 400, 420)
	popup.set_content(dat)
	popup.open(FALSE)

/// Proc for lobby button "View Hive Leaders" to see current leader/queen status.
/mob/new_player/proc/view_xeno_manifest()
	var/dat = GLOB.datacore.get_xeno_manifest()

	var/datum/browser/popup = new(src, "xenomanifest", "<div align='center'>Xeno Manifest</div>", 400, 420)
	popup.set_content(dat)
	popup.open(FALSE)

/mob/new_player/proc/view_lore()
	var/output = "<div align='center'>"
	output += "<a href='byond://?src=[REF(src)];lobby_choice=marines'>Nine Tailed Fox</A><br><br><a href='byond://?src=[REF(src)];lobby_choice=aliens'>Xenomorph Hive</A><br><br><a href='byond://?src=[REF(src)];lobby_choice=som'>Sons of Mars</A>"
	output += "</div>"

	var/datum/browser/popup = new(src, "lore", "<div align='center'>Current Year: [GAME_YEAR]</div>", 240, 300)
	popup.set_content(output)
	popup.open(FALSE)

/mob/new_player/proc/view_marines()
	var/output = "<div align='center'>"
	output += "<p><i>The <b>Nine Tailed Fox'</b> Ninetails Corporation, private security, data gathering, investigation, rnd, and cybernetics development specialized company first founded by Elizabeth Decker to work as a counterintel for another corp then developed itself to be on its own, it naturally clashed with the Japanese syndicate of the time due sharing their intel with the justice force until the unhinged leader who was soon to be executed, broke out of prison and in the following days planted a nuclear explosive in the sewers in the city centre where almost all that is living there are corporate citizens. The attack went unnoticed as a false intel indicated a bioweapon of sorts stashed away outside the city, most likely fabricated by the same group. The violent destruction of heart of the city caused so many deaths and Ninetails tower to be destroyed along with many other buildings. During the rebuilding times, the surviving space vessels of NTC was all that remains and the bank account, whatever it is worth. Other corps were not much different.</i></p>"
	output += "</div>"

	var/datum/browser/popup = new(src, "marines", "<div align='center'>Nine Tailed Fox</div>", 480, 280)
	popup.set_content(output)
	popup.open(FALSE)

/mob/new_player/proc/view_aliens()
	var/output = "<div align='center'>"
	output += "<p><i>Hailing from one of many unknown planets and other unlisted habitats, the <b>xenomorph threat</b> remains at large and still unclear. Extremely dangerous extraterrestrial lifeforms, part of the hive under the Queen Mother, had caught the NTC colonies off-guard during their discovery. \nThey are divided into castes, each with their specialized roles equivalent to a traditional squad member in a human force, thanks to the xenomorph's lifecycle. \nAfter days of ravaging the current area, a metal hive was sighted by the Queen Mother and transported you on the ground. With your intent to spread the hive is in motion, you and your fellow sisters get to work...</i></p>"
	output += "</div>"

	var/datum/browser/popup = new(src, "aliens", "<div align='center'>Xenomorph Hive</div>", 480, 280)
	popup.set_content(output)
	popup.open(FALSE)

/mob/new_player/proc/view_som()
	var/output = "<div align='left'>"
	output += "<p><i>The <b>Sons of Mars</b> Syndicate-funded, small private military group with experimental weaponry that originate from a mars labor camp of phantom city that rioted and took control of the station, most of their members are either criminals from the prison or this planet's desperate colonists who thought it would be a good idea to join syndicate funded terrorists, most likely by promises of a better life or fooling them they are here to do something greater, while their only goal is fighting the corporate, even if it means earth would be left broken. - Burn it all down even if it means losing everything you got. </i></p>"
	output += "</div>"

	var/datum/browser/popup = new(src, "som", "<div align='center'>Sons of Mars</div>", 480, 430)
	popup.set_content(output)
	popup.open(FALSE)

/mob/new_player/Move(atom/newloc, direction, glide_size_override)
	return FALSE


/mob/new_player/proc/close_spawn_windows(mob/user)
	if(!user)
		user = src
	DIRECT_OUTPUT(user, browse(null, "window=latechoices")) //closes late choices window
	user.stop_sound_channel(CHANNEL_LOBBYMUSIC)


/mob/new_player/get_species()
	var/datum/species/chosen_species
	if(client.prefs.species)
		chosen_species = client.prefs.species
	if(!chosen_species)
		return "Human"
	return chosen_species


/mob/new_player/get_gender()
	if(!client?.prefs)
		return ..()
	return client.prefs.gender

/mob/new_player/proc/create_character()
	if(!assigned_role)
		CRASH("create_character called for [key] without an assigned_role")
	spawning = TRUE
	close_spawn_windows()
	var/spawn_type = assigned_role.return_spawn_type(client.prefs)
	var/mob/living/spawning_living = new spawn_type()
	GLOB.joined_player_list += ckey
	client.init_verbs()

	spawning_living.on_spawn(src)

	new_character = spawning_living


/mob/living/proc/on_spawn(mob/new_player/summoner)
	ooc_notes = summoner.ooc_notes
	ooc_notes_likes = summoner.ooc_notes_likes
	ooc_notes_dislikes = summoner.ooc_notes_dislikes
	ooc_notes_maybes = summoner.ooc_notes_maybes
	ooc_notes_favs = summoner.ooc_notes_favs
	ooc_notes_style = summoner.ooc_notes_style
	return

/mob/living/carbon/human/on_spawn(mob/new_player/summoner)
	.=..()
	if(!is_banned_from(summoner.ckey, "Appearance") && summoner.client)
		summoner.client.prefs.copy_to(src)
	update_names_joined_list(real_name)
	overlay_fullscreen_timer(0.5 SECONDS, 10, "roundstart1", /atom/movable/screen/fullscreen/black)
	overlay_fullscreen_timer(2 SECONDS, 20, "roundstart2", /atom/movable/screen/fullscreen/spawning_in)

/mob/living/silicon/ai/on_spawn(mob/new_player/summoner)
	.=..()
	if(!is_banned_from(summoner.ckey, "Appearance") && summoner.client?.prefs?.ai_name)
		fully_replace_character_name(real_name, summoner.client.prefs.ai_name)
	update_names_joined_list(real_name)
	overlay_fullscreen_timer(0.5 SECONDS, 10, "roundstart1", /atom/movable/screen/fullscreen/black)
	overlay_fullscreen_timer(2 SECONDS, 20, "roundstart2", /atom/movable/screen/fullscreen/spawning_in)

/mob/living/carbon/xenomorph/on_spawn(mob/new_player/summoner)
	.=..()
	overlay_fullscreen_timer(0.5 SECONDS, 10, "roundstart1", /atom/movable/screen/fullscreen/black)
	overlay_fullscreen_timer(2 SECONDS, 20, "roundstart2", /atom/movable/screen/fullscreen/spawning_in)

/mob/new_player/proc/transfer_character()
	. = new_character
	if(.)
		mind.transfer_to(new_character, TRUE) //Manually transfer the key to log them in
		qdel(src)


/mob/new_player/proc/IsJobAvailable(datum/job/job, latejoin = FALSE, faction)
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
	if(faction && job.faction != faction)
		return FALSE
	return TRUE

/mob/new_player/proc/try_to_observe()
	if(!SSticker || SSticker.current_state == GAME_STATE_STARTUP)
		to_chat(src, span_warning("The game is still setting up, please try again later."))
		return
	if(client?.observe_used)
		to_chat(src,  span_warning("You seen enough, time to play."))
		return FALSE
	if(!check_other_rights(client, R_ADMIN, FALSE))
		log_game("[key_name(src)] failed to join as a ghost due to the observe disable.")
		to_chat(src, span_boldannounce("Observing is currently disabled.  Please do not get around this by joining just to ghost."))
		spawn()
			tgui_alert(src, "Observing is currently disabled.  Please do not get around this by joining just to ghost.", "Observe disabled", list("Ok"))
		return FALSE
	if(tgui_alert(src, "Are you sure you wish to observe?[SSticker.mode?.observe_respawn_message()]", "Observe", list("Yes", "No")) != "Yes")
		return
	if(!client)
		return TRUE
	var/mob/dead/observer/observer = new()
/*
	if(!check_other_rights(client, R_ADMIN, FALSE))
		observer.unobserve_timer = addtimer(CALLBACK(observer, TYPE_PROC_REF(/mob/dead/observer, observe_time_out)), 3 MINUTES, TIMER_STOPPABLE)
		to_chat(src, span_alert("You have three minutes to observe before getting sent back to the lobby. You can only do this once a round."))
*/
	spawning = TRUE
	observer.started_as_observer = TRUE

	close_spawn_windows()

	var/failed = FALSE

	if(length(GLOB.latejoin))
		var/i = pick(GLOB.latejoin)
		var/turf/T = get_turf(i)
		if(!T)
			CRASH("Invalid latejoin spawn location type")

		to_chat(src, span_notice("Now teleporting."))
		observer.abstract_move(T)
	else
		failed = TRUE

	if(failed)
		to_chat(src, span_danger("Could not locate an observer spawn point. Use the Teleport verb to jump."))

	GLOB.key_to_time_of_role_death[key] = world.time

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
	message_admins("[key_name_admin(observer)] joined as a ghost.")
	observer.client?.init_verbs()
	if(observer.client && check_rights_for(observer.client, R_ADMIN)) // no getting to know what you shouldn't unless you are an admin.
		observer.set_sight(SEE_TURFS|SEE_MOBS|SEE_OBJS)
		observer.set_invis_see(SEE_INVISIBLE_OBSERVER)
	qdel(src)

///Toggles the new players ready state
/mob/new_player/proc/toggle_ready()
	if(SSticker?.current_state > GAME_STATE_PREGAME)
		to_chat(src, span_warning("The round has already started."))
		return
	ready = !ready
	if(ready)
		GLOB.ready_players += src
	else
		GLOB.ready_players -= src
	to_chat(src, span_warning("You are now [ready? "" : "not "]ready."))

///Attempts to latejoin the player
/mob/new_player/proc/attempt_late_join(queue_override = FALSE)
	if(!SSticker?.mode || SSticker.current_state != GAME_STATE_PLAYING)
		to_chat(src, span_warning("The round is either not ready, or has already finished."))
		return

	if(SSticker.mode.round_type_flags & MODE_NO_LATEJOIN)
		to_chat(src, span_warning("Sorry, you cannot late join during [SSticker.mode.name]. You have to start at the beginning of the round. You may observe or try to join as an alien, if possible."))
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
		to_chat(usr, span_danger("[CONFIG_GET(string/hard_popcap_message)]"))

		var/queue_position = SSticker.queued_players.Find(usr)
		if(queue_position == 1)
			to_chat(usr, span_notice("You are next in line to join the game. You will be notified when a slot opens up."))
		else if(queue_position)
			to_chat(usr, span_notice("There are [queue_position - 1] players in front of you in the queue to join the game."))
		else
			SSticker.queued_players += usr
			to_chat(usr, span_notice("You have been added to the queue to join the game. Your position in queue is [length(SSticker.queued_players)]."))
		return
	late_choices()


/mob/new_player/proc/take_ssd_mob()
	if((src.key in GLOB.key_to_time_of_death) && (GLOB.key_to_time_of_death[src.key] + TIME_BEFORE_TAKING_BODY > world.time))
		to_chat(src, span_warning("You died too recently to be able to take a new mob."))
		return


	var/list/mob/living/free_ssd_mobs = GLOB.offered_mob_list
	if(GLOB.ssd_posses_allowed)
		for(var/mob/living/ssd_mob AS in GLOB.ssd_living_mobs)
			if(is_centcom_level(ssd_mob.z) || ishuman(ssd_mob) || ssd_mob.afk_status == MOB_RECENTLY_DISCONNECTED)
				continue
			free_ssd_mobs += ssd_mob

	if(!length(free_ssd_mobs))
		to_chat(src, span_warning("There aren't any available mobs."))
		return FALSE

	var/mob/living/new_mob = tgui_input_list(src, "Pick a mob", "Available Mobs", free_ssd_mobs)
	if(!istype(new_mob) || !src.client)
		return FALSE

	if(new_mob.stat == DEAD)
		to_chat(src, span_warning("You cannot join if the mob is dead."))
		return FALSE
	if(tgui_alert(src, "Are you sure you want to take " + new_mob.real_name +" ("+new_mob.job.title+")?", "Take SSD/offered mob", list("Yes", "No",)) != "Yes")
		return
	if(isxeno(new_mob))
		var/mob/living/carbon/xenomorph/ssd_xeno = new_mob
		if(ssd_xeno.tier != XENO_TIER_MINION && XENODEATHTIME_CHECK(src))
			XENODEATHTIME_MESSAGE(src)
			return

	if(HAS_TRAIT(new_mob, TRAIT_POSSESSING))
		to_chat(src, span_warning("That mob is currently possessing a different mob."))
		return FALSE

	if(new_mob.client)
		to_chat(src, span_warning("That mob has been occupied."))
		return FALSE

	if(new_mob.afk_status == MOB_RECENTLY_DISCONNECTED) //We do not want to occupy them if they've only been gone for a little bit.
		to_chat(src, span_warning("That player hasn't been away long enough. Please wait [round(timeleft(new_mob.afk_timer_id) * 0.1)] second\s longer."))
		return FALSE

	if(is_banned_from(src.ckey, new_mob?.job?.title))
		to_chat(src, span_warning("You are jobbaned from the [new_mob?.job.title] role."))
		return

	if(new_mob in GLOB.offered_mob_list)
		new_mob.take_over(src)
		return

	if(!ishuman(new_mob))
		message_admins(span_adminnotice("[src.key] took control of [new_mob.name] as [new_mob.p_they()] was ssd."))
		log_admin("[src.key] took control of [new_mob.name] as [new_mob.p_they()] was ssd.")
		new_mob.transfer_mob(src)
		return
	if(CONFIG_GET(flag/prevent_dupe_names) && GLOB.real_names_joined.Find(src.client.prefs.real_name))
		to_chat(usr, span_warning("Someone has already joined the round with this character name. Please pick another."))
		return
	message_admins(span_adminnotice("[src.key] took control of [new_mob.name] as [new_mob.p_they()] was ssd."))
	log_admin("[src.key] took control of [new_mob.name] as [new_mob.p_they()] was ssd.")
	new_mob.transfer_mob(src)
	var/mob/living/carbon/human/H = new_mob
	var/datum/job/j = H.job
	var/datum/outfit/job/o = j.outfit
	H.on_transformation()
	o.handle_id(H)
