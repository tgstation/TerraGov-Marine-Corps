#define LINKIFY_READY(string, value) "<a href='byond://?src=[REF(src)];ready=[value]'>[string]</a>"
GLOBAL_LIST_INIT(roleplay_readme, world.file2list("strings/rt/rp_prompt.txt"))

/mob/dead/new_player
	var/ready = 0
	var/spawning = 0//Referenced when you want to delete the new_player later on in the code.
	var/topjob = "Hero!"
	flags_1 = NONE

	invisibility = INVISIBILITY_ABSTRACT

//	hud_type = /datum/hud/new_player

	density = FALSE
	stat = DEAD
	hud_possible = list()

	var/mob/living/new_character	//for instant transfer once the round is set up

	//Used to make sure someone doesn't get spammed with messages if they're ineligible for roles
	var/ineligible_for_roles = FALSE

	var/brohand

/mob/dead/new_player/Initialize()
//	if(client && SSticker.state == GAME_STATE_STARTUP)
//		var/obj/screen/splash/S = new(client, TRUE, TRUE)
//		S.Fade(TRUE)

	if(length(GLOB.newplayer_start))
		forceMove(pick(GLOB.newplayer_start))
	else
		forceMove(locate(1,1,1))

	ComponentInitialize()

	. = ..()

	GLOB.new_player_list += src

/mob/dead/new_player/Destroy()
	GLOB.new_player_list -= src
	return ..()


///Say verb
/mob/dead/new_player/say_verb(message as text)
	set name = "Say"
	set category = "IC"
	set hidden = 1

#ifdef MATURESERVER

	if(message)
		if(client)
			if(GLOB.ooc_allowed)
				client.ooc(message)
			else
				client.lobbyooc(message)

#endif

/mob/dead/new_player/prepare_huds()
	return

/mob/dead/new_player/proc/new_player_panel()
/*
	var/output = "<center>"
	if(SSticker.current_state <= GAME_STATE_PREGAME)
		switch(ready)
			if(PLAYER_NOT_READY)
				output += "<p>[LINKIFY_READY("READY", PLAYER_READY_TO_PLAY)] | <b>UNREADY</b></p>"
			if(PLAYER_READY_TO_PLAY)
				output += "<p><b>READY</b> | [LINKIFY_READY("UNREADY", PLAYER_NOT_READY)]</p>"
			if(PLAYER_READY_TO_OBSERVE)
				output += "<p>[LINKIFY_READY("READY", PLAYER_READY_TO_PLAY)]</p>"
				output += "<p>[LINKIFY_READY("UNREADY", PLAYER_NOT_READY)]</p>"
	else
//		output += "<p><a href='byond://?src=[REF(src)];manifest=1'>View the Crew Manifest</a></p>"
//		output += "<p><a href='byond://?src=[REF(src)];manifest=1'>FOLK</a></p>"
		output += "<p><a href='byond://?src=[REF(src)];late_join=1'>LATEJOIN</a></p>"
	output += "<p><a href='byond://?src=[REF(src)];show_preferences=1'>CHARACTER</a></p>"

//	output += "<p><a href='byond://?src=[REF(src)];show_options=1'>OPTIONS</a></p>"

	output += "<p><a href='byond://?src=[REF(src)];show_keybinds=1'>KEYBINDS</a></p>"

	if(!IsGuestKey(src.key))
		if (SSdbcore.Connect())
			var/isadmin = 0
			if(src.client && src.client.holder)
				isadmin = 1
			var/datum/DBQuery/query_get_new_polls = SSdbcore.NewQuery("SELECT id FROM [format_table_name("poll_question")] WHERE [(isadmin ? "" : "adminonly = false AND")] Now() BETWEEN starttime AND endtime AND id NOT IN (SELECT pollid FROM [format_table_name("poll_vote")] WHERE ckey = \"[sanitizeSQL(ckey)]\") AND id NOT IN (SELECT pollid FROM [format_table_name("poll_textreply")] WHERE ckey = \"[sanitizeSQL(ckey)]\")")
			var/rs = REF(src)
			if(query_get_new_polls.Execute())
				var/newpoll = 0
				if(query_get_new_polls.NextRow())
					newpoll = 1

				if(newpoll)
					output += "<p><b><a href='byond://?src=[rs];showpoll=1'>Show Player Polls</A> (NEW!)</b></p>"
				else
					output += "<p><a href='byond://?src=[rs];showpoll=1'>Show Player Polls</A></p>"
			qdel(query_get_new_polls)
			if(QDELETED(src))
				return

	output += "</center>"

	//src << browse(output,"window=playersetup;size=210x240;can_close=0")
	var/datum/browser/popup = new(src, "playersetup", "<div align='center'>LOBBY MENU</div>", 250, 200)
	popup.set_window_options("can_close=0")
	popup.set_content(output)
	popup.open(FALSE)*/
	if(client)
		if(client.prefs)
			client.prefs.ShowChoices(src, 4)

/mob/dead/new_player/Topic(href, href_list[])
	if(src != usr)
		return 0

	if(!client)
		return 0

	//Determines Relevent Population Cap
	var/relevant_cap
	var/hpc = CONFIG_GET(number/hard_popcap)
	var/epc = CONFIG_GET(number/extreme_popcap)
	if(hpc && epc)
		relevant_cap = min(hpc, epc)
	else
		relevant_cap = max(hpc, epc)

	if(href_list["show_preferences"])
		client.prefs.ShowChoices(src, 4)
		return 1

	if(href_list["show_options"])
		client.prefs.ShowChoices(src, 1)
		return 1

	if(href_list["show_keybinds"])
		client.prefs.ShowChoices(src, 3)
		return 1

	if(href_list["sethand"])
		if(brohand == href_list["sethand"])
			brohand = null
			to_chat(src, "<span class='boldwarning'>Your Hand is REJECTED, sire.</span>")
			return 1
		brohand = href_list["sethand"]
		to_chat(src, "<span class='boldnotice'>Your Hand is selected, sire.</span>")
		return 1

	if(href_list["ready"])
		var/tready = text2num(href_list["ready"])
		//Avoid updating ready if we're after PREGAME (they should use latejoin instead)
		//This is likely not an actual issue but I don't have time to prove that this
		//no longer is required
		if(tready == PLAYER_NOT_READY)
			if(SSticker.job_change_locked)
				return
		if(SSticker.current_state <= GAME_STATE_PREGAME)
			if(ready != tready)
				ready = tready
		//if it's post initialisation and they're trying to observe we do the needful
		if(!SSticker.current_state < GAME_STATE_PREGAME && tready == PLAYER_READY_TO_OBSERVE)
			ready = tready
			make_me_an_observer()
			return

	if(href_list["refresh"])
		winshow(src, "preferencess_window", FALSE)
		src << browse(null, "window=preferences_browser")
//		src << browse(null, "window=playersetup") //closes the player setup window
		new_player_panel()

//	if(href_list["rpprompt"])
//		do_rp_prompt()
//		return

	if(href_list["late_join"])
		if(!SSticker?.IsRoundInProgress())
			to_chat(usr, "<span class='boldwarning'>The game is starting. You cannot join yet.</span>")
			return

		if(href_list["late_join"] == "override")
			LateChoices()
			return
/*#ifdef MATURESERVER
		if(key && (world.time < GLOB.respawntimes[key] + RESPAWNTIME))
			to_chat(usr, "<span class='warning'>I can return in [GLOB.respawntimes[key] + RESPAWNTIME - world.time].</span>")
			return
#else*/


		var/timetojoin = 5 MINUTES
#ifdef ALLOWPLAY
		timetojoin = 1 SECONDS
#endif
#ifdef TESTSERVER
		timetojoin = 0
#endif
		var/datum/game_mode/chaosmode/C = SSticker.mode
		if(istype(C))
			if(C.allmig || C.roguefight)
				timetojoin = 0
		if(SSticker.round_start_time)
			if(world.time < SSticker.round_start_time + timetojoin)
				var/ttime = round((SSticker.round_start_time + timetojoin - world.time) / 10)
				var/list/choicez = list("Not yet.", "You cannot join yet.", "It won't work yet.", "Please be patient.", "Try again later.", "Late-joining is not yet possible.")
				to_chat(usr, "<span class='warning'>[pick(choicez)] ([ttime]).</span>")
				return

		var/plevel = 0
		if(ismob(usr))
			var/mob/user = usr
			if(user.client)
				plevel = user.client.patreonlevel()
		if(!IsPatreon(ckey))
			if(SSticker.queued_players.len || (relevant_cap && living_player_count() >= relevant_cap && !(ckey(key) in GLOB.admin_datums) && plevel < 1))
				to_chat(usr, "<span class='danger'>[CONFIG_GET(string/hard_popcap_message)]</span>")

				var/queue_position = SSticker.queued_players.Find(usr)
				if(queue_position == 1)
					to_chat(usr, "<span class='notice'>Thou art next in line to join the game. You will be notified when a slot opens up.</span>")
				else if(queue_position)
					to_chat(usr, "<span class='notice'>Thou art [queue_position-1] players in front of you in the queue to join the game.</span>")
				else
					SSticker.queued_players += usr
					to_chat(usr, "<span class='notice'>Thou have been added to the queue to join the game. Your position in queue is [SSticker.queued_players.len].</span>")
				return
		LateChoices()

	if(href_list["manifest"])
		ViewManifest()

	if(href_list["SelectedJob"])
		if(!SSticker?.IsRoundInProgress())
			to_chat(usr, "<span class='danger'>The round is either not ready, or has already finished...</span>")
			return

		if(!GLOB.enter_allowed)
			to_chat(usr, "<span class='notice'>There is a lock on entering the game!</span>")
			return

		if(SSticker.queued_players.len && !(ckey(key) in GLOB.admin_datums))
			if((living_player_count() >= relevant_cap) || (src != SSticker.queued_players[1]))
				to_chat(usr, "<span class='warning'>Server is full.</span>")
				return

		AttemptLateSpawn(href_list["SelectedJob"])
		return

	if(!ready && href_list["preference"])
		if(client)
			client.prefs.process_link(src, href_list)
	else if(!href_list["late_join"])
		new_player_panel()

	if(href_list["showpoll"])
		handle_player_polling()
		return

	if(href_list["viewpoll"])
		var/datum/poll_question/poll = locate(href_list["viewpoll"]) in GLOB.polls
		poll_player(poll)

	if(href_list["votepollref"])
		var/datum/poll_question/poll = locate(href_list["votepollref"]) in GLOB.polls
		vote_on_poll_handler(poll, href_list)



/mob/dead/new_player/verb/do_rp_prompt()
	set name = "Lore Primer"
	set category = "Memory"
	var/list/dat = list()
	dat += GLOB.roleplay_readme
	if(dat)
		var/datum/browser/popup = new(src, "Primer", "BLACKSTONE", 460, 550)
		popup.set_content(dat.Join())
		popup.open()

//When you cop out of the round (NB: this HAS A SLEEP FOR PLAYER INPUT IN IT)
/mob/dead/new_player/proc/make_me_an_observer()
	if(QDELETED(src) || !src.client)
		ready = PLAYER_NOT_READY
		return FALSE

	var/this_is_like_playing_right = alert(src,"Are you sure you wish to observe? You will not be able to play this round!","Player Setup","Yes","No")

	if(QDELETED(src) || !src.client || this_is_like_playing_right != "Yes")
		ready = PLAYER_NOT_READY
		src << browse(null, "window=playersetup") //closes the player setup window
		new_player_panel()
		return FALSE

	var/mob/dead/observer/observer = new()
	spawning = TRUE

	observer.started_as_observer = TRUE
	close_spawn_windows()
	var/obj/effect/landmark/observer_start/O = locate(/obj/effect/landmark/observer_start) in GLOB.landmarks_list
	to_chat(src, "<span class='notice'>Now teleporting.</span>")
	if (O)
		observer.forceMove(O.loc)
	else
		to_chat(src, "<span class='notice'>Teleporting failed. Ahelp an admin please</span>")
		stack_trace("There's no freaking observer landmark available on this map or you're making observers before the map is initialised")
	observer.key = key
	observer.client = client
	observer.set_ghost_appearance()
	if(observer.client && observer.client.prefs)
		observer.real_name = observer.client.prefs.real_name
		observer.name = observer.real_name
	observer.update_icon()
	observer.stop_sound_channel(CHANNEL_LOBBYMUSIC)
	QDEL_NULL(mind)
	qdel(src)
	return TRUE

/proc/get_job_unavailable_error_message(retval, jobtitle)
	switch(retval)
		if(JOB_AVAILABLE)
			return "[jobtitle] is available."
		if(JOB_UNAVAILABLE_GENERIC)
			return "[jobtitle] is unavailable."
		if(JOB_UNAVAILABLE_BANNED)
			return "You are currently banned from [jobtitle]."
		if(JOB_UNAVAILABLE_PLAYTIME)
			return "You do not have enough relevant playtime for [jobtitle]."
		if(JOB_UNAVAILABLE_ACCOUNTAGE)
			return "Your account is not old enough for [jobtitle]."
		if(JOB_UNAVAILABLE_SLOTFULL)
			return "[jobtitle] is already filled to capacity."
		if(JOB_UNAVAILABLE_RACE)
			return "[jobtitle] is not meant for your kind."
		if(JOB_UNAVAILABLE_PATRON)
			return "[jobtitle] requires more faith."
		if(JOB_UNAVAILABLE_LASTCLASS)
			return "You have played [jobtitle] recently."
		if(JOB_UNAVAILABLE_ADVENTURER_COOLDOWN)
			if(usr?.ckey && (usr?.ckey in GLOB.adventurer_cooldowns))
				var/cooldown_time = GLOB.adventurer_cooldowns[usr.ckey]
				var/cooldown_duration = 15 MINUTES
				var/remaining_time = round((cooldown_time + cooldown_duration - world.time) / 10)
				return "You must wait [remaining_time] seconds before playing as an Adventurer again."
	return "Error: Unknown job availability."

//used for latejoining
/mob/dead/new_player/proc/IsJobUnavailable(rank, latejoin = FALSE)
	if(istype(SSticker.mode, /datum/game_mode/chaosmode))
		var/datum/game_mode/chaosmode/C = SSticker.mode
		if(C.skeletons)
			if(rank != "Skeleton")
				return JOB_UNAVAILABLE_GENERIC
			else
				return JOB_AVAILABLE
		else
			if(rank == "Skeleton")
				return JOB_UNAVAILABLE_GENERIC
		if(C.deathknightspawn)
			if(rank != "Death Knight")
				return JOB_UNAVAILABLE_GENERIC
			else
				return JOB_AVAILABLE
		else
			if(rank == "Death Knight")
				return JOB_UNAVAILABLE_GENERIC

	// Check if the player is on cooldown for the Adventurer role
	if(rank == "Adventurer")
		if(client?.ckey in GLOB.adventurer_cooldowns)
			var/cooldown_time = GLOB.adventurer_cooldowns[ckey]
			var/cooldown_duration = 15 MINUTES
			if(world.time < cooldown_time + cooldown_duration)
				return JOB_UNAVAILABLE_ADVENTURER_COOLDOWN

	var/datum/job/job = SSjob.GetJob(rank)
	if(!job)
		return JOB_UNAVAILABLE_GENERIC
	if((job.current_positions >= job.total_positions) && job.total_positions != -1)
		if(job.title == "Assistant")
			if(isnum(client.player_age) && client.player_age <= 14) //Newbies can always be assistants
				return JOB_AVAILABLE
			for(var/datum/job/J in SSjob.occupations)
				if(J && J.current_positions < J.total_positions && J.title != job.title)
					return JOB_UNAVAILABLE_SLOTFULL
		else
			return JOB_UNAVAILABLE_SLOTFULL
//	if(job.title == "Adventurer" && latejoin)
//		for(var/datum/job/J in SSjob.occupations)
//			if(J && J.total_positions && J.current_positions < 1 && J.title != job.title && (IsJobUnavailable(J.title))
//				return JOB_UNAVAILABLE_GENERIC //we can't play adventurer if there isn't 1 of every other job that we can play
	if(is_banned_from(ckey, rank))
		return JOB_UNAVAILABLE_BANNED
	if((!job.bypass_jobban) && (client.blacklisted()))
		return JOB_UNAVAILABLE_GENERIC
	if(CONFIG_GET(flag/usewhitelist))
		if(job.whitelist_req && (!client.whitelisted()))
			return JOB_UNAVAILABLE_GENERIC
	if(QDELETED(src))
		return JOB_UNAVAILABLE_GENERIC
	if(!job.player_old_enough(client))
		return JOB_UNAVAILABLE_ACCOUNTAGE
	if(job.required_playtime_remaining(client))
		return JOB_UNAVAILABLE_PLAYTIME
	if(latejoin && !job.special_check_latejoin(client))
		return JOB_UNAVAILABLE_GENERIC
	if(!(client.prefs.pref_species.name in job.allowed_races))
		return JOB_UNAVAILABLE_RACE
	if(!(client.prefs.selected_patron.name in job.allowed_patrons))
		return JOB_UNAVAILABLE_PATRON
	if(job.plevel_req > client.patreonlevel())
		testing("PATREONLEVEL [client.patreonlevel()] req [job.plevel_req]")
		return JOB_UNAVAILABLE_GENERIC
	if(get_playerquality(ckey) < job.min_pq)
		return JOB_UNAVAILABLE_GENERIC
	if(!(client.prefs.gender in job.allowed_sexes))
		return JOB_UNAVAILABLE_RACE
	if(!(client.prefs.age in job.allowed_ages))
		return JOB_UNAVAILABLE_RACE
	if((client.prefs.lastclass == job.title) && !job.bypass_lastclass)
		return JOB_UNAVAILABLE_GENERIC
	if(istype(SSticker.mode, /datum/game_mode/roguewar))
		var/datum/game_mode/roguewar/W = SSticker.mode
		if(W.get_team(ckey))
			if(W.get_team(ckey) != job.faction)
				return JOB_UNAVAILABLE_GENERIC
	return JOB_AVAILABLE

/mob/dead/new_player/proc/AttemptLateSpawn(rank)
	var/error = IsJobUnavailable(rank)
	if(error != JOB_AVAILABLE)
		to_chat(src, "<span class='warning'>[get_job_unavailable_error_message(error, rank)]</span>")
		return FALSE

	if(SSticker.late_join_disabled)
		alert(src, "Something went bad.")
		return FALSE
/*
	var/arrivals_docked = TRUE
	if(SSshuttle.arrivals)
		close_spawn_windows()	//In case we get held up
		if(SSshuttle.arrivals.damaged && CONFIG_GET(flag/arrivals_shuttle_require_safe_latejoin))
			src << alert("WEIRD!")
			return FALSE

		if(CONFIG_GET(flag/arrivals_shuttle_require_undocked))
			SSshuttle.arrivals.RequireUndocked(src)
		arrivals_docked = SSshuttle.arrivals.mode != SHUTTLE_CALL
*/

	//Remove the player from the join queue if he was in one and reset the timer
	SSticker.queued_players -= src
	SSticker.queue_delay = 4

	testing("basedtest 1")

	SSjob.AssignRole(src, rank, 1)
	testing("basedtest 2")
	var/mob/living/character = create_character(TRUE)	//creates the human and transfers vars and mind
	testing("basedtest 3")
	character.islatejoin = TRUE
	var/equip = SSjob.EquipRank(character, rank, TRUE)
	testing("basedtest 4")

	if(isliving(equip))	//Borgs get borged in the equip, so we need to make sure we handle the new mob.
		character = equip

	var/datum/job/job = SSjob.GetJob(rank)
	testing("basedtest 5")

	if(job && !job.override_latejoin_spawn(character))
		testing("basedtest 6")
		SSjob.SendToLateJoin(character)
		testing("basedtest 7")
//		if(!arrivals_docked)
		var/obj/screen/splash/Spl = new(character.client, TRUE)
		Spl.Fade(TRUE)
//			character.playsound_local(get_turf(character), 'sound/blank.ogg', 25)

		character.update_parallax_teleport()

	SSticker.minds += character.mind

	var/mob/living/carbon/human/humanc
	if(ishuman(character))
		humanc = character	//Let's retypecast the var to be human,
/*
	if(humanc)	//These procs all expect humans
		GLOB.data_core.manifest_inject(humanc)
		if(SSshuttle.arrivals)
			SSshuttle.arrivals.QueueAnnounce(humanc, rank)
		else
			AnnounceArrival(humanc, rank)
		AddEmploymentContract(humanc)
		if(GLOB.highlander)
			to_chat(humanc, "<span class='danger'><i>THERE CAN BE ONLY ONE!!!</i></span>")
			humanc.make_scottish()

		if(GLOB.summon_guns_triggered)
			give_guns(humanc)
		if(GLOB.summon_magic_triggered)
			give_magic(humanc)
		if(GLOB.curse_of_madness_triggered)
			give_madness(humanc, GLOB.curse_of_madness_triggered)
*/
	GLOB.joined_player_list += character.ckey
/*
	if(CONFIG_GET(flag/allow_latejoin_antagonists) && humanc)	//Borgs aren't allowed to be antags. Will need to be tweaked if we get true latejoin ais.
		if(SSshuttle.emergency)
			switch(SSshuttle.emergency.mode)
				if(SHUTTLE_RECALL, SHUTTLE_IDLE)
					SSticker.mode.make_antag_chance(humanc)
				if(SHUTTLE_CALL)
					if(SSshuttle.emergency.timeLeft(1) > initial(SSshuttle.emergencyCallTime)*0.5)
						SSticker.mode.make_antag_chance(humanc)

	if(humanc && CONFIG_GET(flag/roundstart_traits))
		SSquirks.AssignQuirks(humanc, humanc.client, TRUE)*/
	if(humanc)
		var/fakekey = character.ckey
		if(ckey in GLOB.anonymize)
			fakekey = get_fake_key(character.ckey)
		GLOB.character_list[character.mobid] = "[fakekey] was [character.real_name] ([rank])<BR>"
		GLOB.character_ckey_list[character.real_name] = character.ckey
		log_character("[character.ckey] ([fakekey]) - [character.real_name] - [rank]")
	if(GLOB.respawncounts[character.ckey])
		var/AN = GLOB.respawncounts[character.ckey]
		AN++
		GLOB.respawncounts[character.ckey] = AN
	else
		GLOB.respawncounts[character.ckey] = 1
//	add_roundplayed(character.ckey)
	log_manifest(character.mind.key,character.mind,character,latejoin = TRUE)

/mob/dead/new_player/proc/AddEmploymentContract(mob/living/carbon/human/employee)
	//TODO:  figure out a way to exclude wizards/nukeops/demons from this.
	for(var/C in GLOB.employmentCabinets)
		var/obj/structure/filingcabinet/employment/employmentCabinet = C
		if(!employmentCabinet.virgin)
			employmentCabinet.addFile(employee)


/mob/dead/new_player/proc/LateChoices()
	var/list/dat = list("<div class='notice' style='font-style: normal; font-size: 14px; margin-bottom: 2px; padding-bottom: 0px'>Round Duration: [DisplayTimeText(world.time - SSticker.round_start_time, 1)]</div>")
	if(SSshuttle.emergency)
		switch(SSshuttle.emergency.mode)
			if(SHUTTLE_ESCAPE)
				dat += "<div class='notice red'>The last boat has left Roguetown.</div><br>"
	for(var/datum/job/prioritized_job in SSjob.prioritized_jobs)
		if(prioritized_job.current_positions >= prioritized_job.total_positions)
			SSjob.prioritized_jobs -= prioritized_job
	dat += "<table><tr><td valign='top'>"
	var/column_counter = 0

	var/list/omegalist = list(GLOB.noble_positions) + list(GLOB.garrison_positions) + list(GLOB.church_positions) + list(GLOB.serf_positions) + list(GLOB.peasant_positions) + list(GLOB.youngfolk_positions)

	if(istype(SSticker.mode, /datum/game_mode/chaosmode))
		var/datum/game_mode/chaosmode/C = SSticker.mode
		if(C.allmig)
			omegalist = list(GLOB.allmig_positions)
	if(istype(SSticker.mode, /datum/game_mode/roguewar))
		omegalist = list(GLOB.roguewar_positions)

	for(var/list/category in omegalist)
		if(!SSjob.name_occupations[category[1]])
			testing("HELP NO THING FOUND FOR [category[1]]")
			continue
		
		var/list/available_jobs = list()
		for(var/job in category)
			var/datum/job/job_datum = SSjob.name_occupations[job]
			// Make sure adventurer jobs always appear on list, even if unavailable
			if(job_datum && (IsJobUnavailable(job_datum.title, TRUE) == JOB_AVAILABLE || job_datum.title == "Adventurer"))
				available_jobs += job

		if (length(available_jobs))
			var/cat_color = SSjob.name_occupations[category[1]].selection_color //use the color of the first job in the category (the department head) as the category color
			var/cat_name = ""
			switch (SSjob.name_occupations[category[1]].department_flag)
				if (NOBLEMEN)
					cat_name = "Nobles"
				if (GARRISON)
					cat_name = "Garrison"
				if (CHURCHMEN)
					cat_name = "Churchmen"
				if (SERFS)
					cat_name = "Serfs"
				if (PEASANTS)
					cat_name = "Peasants"
				if (YOUNGFOLK)
					cat_name = "Youngfolk"

			dat += "<fieldset style='width: 185px; border: 2px solid [cat_color]; display: inline'>"
			dat += "<legend align='center' style='font-weight: bold; color: [cat_color]'>[cat_name]</legend>"
			var/datum/game_mode/chaosmode/C = SSticker.mode
			if(istype(C))
				if(C.skeletons)
					dat += "<a class='job command' href='byond://?src=[REF(src)];SelectedJob=skeleton'>BECOME AN EVIL SKELETON</a>"
					dat += "</fieldset><br>"
					column_counter++
					if(column_counter > 0 && (column_counter % 3 == 0))
						dat += "</td><td valign='top'>"
					break
				if(C.deathknightspawn)
					dat += "<a class='job command' href='byond://?src=[REF(src)];SelectedJob=Death Knight'>JOIN THE VAMPIRE LORD AS A DEATH KNIGHT</a>"
					dat += "</fieldset><br>"
					column_counter++
					if(column_counter > 0 && (column_counter % 3 == 0))
						dat += "</td><td valign='top'>"
					break
			
			for(var/job in available_jobs)
				var/datum/job/job_datum = SSjob.name_occupations[job]
				if(job_datum)
					var/command_bold = ""
					if(job in GLOB.noble_positions)
						command_bold = " command"
					var/used_name = job_datum.title
					if(client.prefs.gender == FEMALE && job_datum.f_title)
						used_name = job_datum.f_title
					if(job_datum in SSjob.prioritized_jobs)
						dat += "<a class='job[command_bold]' href='byond://?src=[REF(src)];SelectedJob=[job_datum.title]'><span class='priority'>[used_name] ([job_datum.current_positions])</span></a>"
					else
						dat += "<a class='job[command_bold]' href='byond://?src=[REF(src)];SelectedJob=[job_datum.title]'>[used_name] ([job_datum.current_positions])</a>"

			dat += "</fieldset><br>"
			column_counter++
			if(column_counter > 0 && (column_counter % 3 == 0))
				dat += "</td><td valign='top'>"
	dat += "</td></tr></table></center>"
	dat += "</div></div>"
	var/datum/browser/popup = new(src, "latechoices", "Choose Class", 680, 580)
	popup.add_stylesheet("playeroptions", 'html/browser/playeroptions.css')
	popup.set_content(jointext(dat, ""))
	popup.open(FALSE) // 0 is passed to open so that it doesn't use the onclose() proc

/mob/dead/new_player/proc/create_character(transfer_after)
	spawning = 1
	close_spawn_windows()

	var/mob/living/carbon/human/H = new(loc)

	var/frn = CONFIG_GET(flag/force_random_names)
	if(!frn)
		frn = is_banned_from(ckey, "Appearance")
		if(QDELETED(src))
			return
	if(frn)
		client.prefs.random_character()
		client.prefs.real_name = client.prefs.pref_species.random_name(gender,1)

	var/is_antag
	if(mind in GLOB.pre_setup_antags)
		is_antag = TRUE

	client.prefs.copy_to(H, antagonist = is_antag)
	H.dna.update_dna_identity()
	if(mind)
		if(transfer_after)
			mind.late_joiner = TRUE
		mind.active = 0					//we wish to transfer the key manually
		mind.transfer_to(H)					//won't transfer key since the mind is not active

	H.name = real_name

	. = H
	new_character = .

	H.after_creation()

	if(transfer_after)
		transfer_character()
	GLOB.chosen_names += H.real_name


/mob/proc/after_creation()
	return

/mob/living/carbon/human/after_creation()
	if(dna?.species)
		dna.species.after_creation(src)
	roll_stats()

/mob/dead/new_player/proc/transfer_character()
	. = new_character
	if(.)
		new_character.key = key		//Manually transfer the key to log them in
		new_character.stop_sound_channel(CHANNEL_LOBBYMUSIC)
		var/area/joined_area = get_area(new_character.loc)
		if(joined_area)
			joined_area.on_joining_game(new_character)
		new_character = null
		qdel(src)

/mob/dead/new_player/proc/ViewManifest()
	var/dat = "<html><body>"
	dat += "<h4>Crew Manifest</h4>"
	dat += GLOB.data_core.get_manifest(OOC = 1)

	src << browse(dat, "window=manifest;size=387x420;can_close=1")

/mob/dead/new_player/Move()
	return 0


/mob/dead/new_player/proc/close_spawn_windows()

	src << browse(null, "window=latechoices") //closes late choices window
	src << browse(null, "window=playersetup") //closes the player setup window
	src << browse(null, "window=preferences") //closes job selection
	src << browse(null, "window=mob_occupation")
	src << browse(null, "window=latechoices") //closes late job selection
	winshow(src, "preferencess_window", FALSE)
	src << browse(null, "window=preferences_browser")
	src << browse(null, "window=lobby_window")
// Used to make sure that a player has a valid job preference setup, used to knock players out of eligibility for anything if their prefs don't make sense.
// A "valid job preference setup" in this situation means at least having one job set to low, or not having "return to lobby" enabled
// Prevents "antag rolling" by setting antag prefs on, all jobs to never, and "return to lobby if preferences not availible"
// Doing so would previously allow you to roll for antag, then send you back to lobby if you didn't get an antag role
// This also does some admin notification and logging as well, as well as some extra logic to make sure things don't go wrong
/mob/dead/new_player/proc/check_preferences()
	if(!client)
		return FALSE //Not sure how this would get run without the mob having a client, but let's just be safe.
	if(client.prefs.joblessrole != RETURNTOLOBBY)
		return TRUE
	// If they have antags enabled, they're potentially doing this on purpose instead of by accident. Notify admins if so.
	var/has_antags = FALSE
	if(client.prefs.be_special.len > 0)
		has_antags = TRUE
	if(client.prefs.job_preferences.len == 0)
		if(!ineligible_for_roles)
			to_chat(src, "<span class='danger'>I need to pick a class to join as.</span>")
		ineligible_for_roles = TRUE
		ready = PLAYER_NOT_READY
		if(has_antags)
			log_admin("[src.ckey] just got booted back to lobby with no jobs, but antags enabled.")
			message_admins("[src.ckey] just got booted back to lobby with no jobs enabled, but antag rolling enabled. Likely antag rolling abuse.")

		return FALSE //This is the only case someone should actually be completely blocked from antag rolling as well
	return TRUE
