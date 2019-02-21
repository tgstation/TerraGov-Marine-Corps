/*
  GAMEMODES (by Rastaf0)

  In the new mode system all special roles are fully supported.
  You can have proper wizards/traitors/changelings/cultists during any mode.
  Only two things really depends on gamemode:
  1. Starting roles, equipment and preparations
  2. Conditions of finishing the round.

 */


/datum/game_mode
	var/name = ""
	var/config_tag = null
	var/intercept_hacked = FALSE
	var/votable = TRUE
	var/probability = 0
	var/list/datum/mind/modePlayer = new
	var/list/restricted_jobs = list()	// Jobs it doesn't make sense to be.  I.E chaplain or AI cultist
	var/list/protected_jobs = list()	// Jobs that can't be traitors because
	var/required_players = 0
	var/required_players_secret = 0 //Minimum number of players for that game mode to be chose in Secret
	var/required_enemies = 0
	var/recommended_enemies = 0
	var/newscaster_announcements = null
	var/ert_disabled = FALSE


/datum/game_mode/proc/announce()
	return FALSE


/datum/game_mode/proc/can_start()
	var/players = ready_players()

	if(GLOB.master_mode == "secret" && players >= required_players_secret)
		return TRUE
	else if(players >= required_players)
		return TRUE
	else
		return FALSE


/datum/game_mode/proc/pre_setup()
	if(flags_landmarks & MODE_LANDMARK_SPAWN_XENO_TUNNELS)
		setup_xeno_tunnels()

	if(flags_landmarks & MODE_LANDMARK_SPAWN_MAP_ITEM)
		spawn_map_items()

	if(flags_round_type & MODE_FOG_ACTIVATED)
		spawn_fog_blockers()

	var/obj/effect/landmark/L
	while(GLOB.landmarks_round_start.len)
		L = GLOB.landmarks_round_start[GLOB.landmarks_round_start.len]
		GLOB.landmarks_round_start.len--
		L.after_round_start()
	return FALSE


/datum/game_mode/proc/post_setup()
	spawn(ROUNDSTART_LOGOUT_REPORT_TIME)
		display_roundstart_logout_report()
	return TRUE


/datum/game_mode/process()
	return FALSE


/datum/game_mode/proc/check_finished()
	if(EvacuationAuthority.dest_status == NUKE_EXPLOSION_FINISHED)
		return TRUE


/datum/game_mode/proc/cleanup()
	return FALSE


/datum/game_mode/proc/declare_completion()
	var/clients = 0
	var/surviving_humans = 0
	var/surviving_total = 0
	var/ghosts = 0
	var/escaped_humans = 0
	var/escaped_total = 0
	var/escaped_on_pod_1 = 0
	var/escaped_on_pod_2 = 0
	var/escaped_on_pod_3 = 0
	var/escaped_on_pod_5 = 0
	var/escaped_on_shuttle = 0

	var/list/area/escape_locations = list(/area/shuttle/escape/centcom, /area/shuttle/escape_pod1/centcom, /area/shuttle/escape_pod2/centcom, /area/shuttle/escape_pod3/centcom, /area/shuttle/escape_pod5/centcom)

	for(var/mob/M in GLOB.player_list)
		if(M.client)
			clients++
			if(ishuman(M))
				if(!M.stat)
					surviving_humans++
					if(M.loc && M.loc.loc && M.loc.loc.type in escape_locations)
						escaped_humans++
			if(!M.stat)
				surviving_total++
				if(M.loc && M.loc.loc && M.loc.loc.type in escape_locations)
					escaped_total++

				if(M.loc && M.loc.loc && M.loc.loc.type == /area/shuttle/escape/centcom)
					escaped_on_shuttle++

				if(M.loc && M.loc.loc && M.loc.loc.type == /area/shuttle/escape_pod1/centcom)
					escaped_on_pod_1++
				if(M.loc && M.loc.loc && M.loc.loc.type == /area/shuttle/escape_pod2/centcom)
					escaped_on_pod_2++
				if(M.loc && M.loc.loc && M.loc.loc.type == /area/shuttle/escape_pod3/centcom)
					escaped_on_pod_3++
				if(M.loc && M.loc.loc && M.loc.loc.type == /area/shuttle/escape_pod5/centcom)
					escaped_on_pod_5++

			if(isobserver(M))
				ghosts++

	if(clients > 0)
		feedback_set("round_end_clients",clients)
	if(ghosts > 0)
		feedback_set("round_end_ghosts",ghosts)
	if(surviving_humans > 0)
		feedback_set("survived_human",surviving_humans)
	if(surviving_total > 0)
		feedback_set("survived_total",surviving_total)
	if(escaped_humans > 0)
		feedback_set("escaped_human",escaped_humans)
	if(escaped_total > 0)
		feedback_set("escaped_total",escaped_total)
	if(escaped_on_shuttle > 0)
		feedback_set("escaped_on_shuttle",escaped_on_shuttle)
	if(escaped_on_pod_1 > 0)
		feedback_set("escaped_on_pod_1",escaped_on_pod_1)
	if(escaped_on_pod_2 > 0)
		feedback_set("escaped_on_pod_2",escaped_on_pod_2)
	if(escaped_on_pod_3 > 0)
		feedback_set("escaped_on_pod_3",escaped_on_pod_3)
	if(escaped_on_pod_5 > 0)
		feedback_set("escaped_on_pod_5",escaped_on_pod_5)

	return FALSE


/datum/game_mode/proc/check_win()
	return FALSE


/datum/game_mode/proc/send_intercept()
	return FALSE


/datum/game_mode/proc/get_players_for_role(var/role, override_jobbans = 0)
	var/list/players = list()
	var/list/candidates = list()
	var/list/drafted = list()
	var/datum/mind/applicant = null

	var/roletext
	switch(role)
		if(BE_DEATHMATCH)	roletext = "End of Round Deathmatch"
		if(BE_ALIEN)		roletext = "Alien"
		if(BE_QUEEN)		roletext = "Queen"
		if(BE_SURVIVOR)		roletext = "Survivor"
		if(BE_PREDATOR)		roletext = "Predator"
		if(BE_SQUAD_STRICT)	roletext = "Prefer squad over role"

	//Assemble a list of active players without jobbans.
	for(var/mob/new_player/player in GLOB.player_list)
		if(player.client && player.ready)
			if(!jobban_isbanned(player, "Syndicate") && !jobban_isbanned(player, roletext))
				players += player

	//Shuffle the players list so that it becomes ping-independent.
	players = shuffle(players)

	//Get a list of all the people who want to be the antagonist for this round
	for(var/mob/new_player/player in players)
		if(player.client.prefs.be_special & role)
			log_game("[player.key] had [roletext] enabled, so we are drafting them.")
			candidates += player.mind
			players -= player

	//If we don't have enough antags, draft people who voted for the round.
	if(candidates.len < recommended_enemies)
		for(var/key in round_voters)
			for(var/mob/new_player/player in players)
				if(player.ckey == key)
					log_game("[player.key] voted for this round, so we are drafting them.")
					candidates += player.mind
					players -= player
					break

	//Remove candidates who want to be antagonist but have a job that precludes it
	if(restricted_jobs)
		for(var/datum/mind/player in candidates)
			for(var/job in restricted_jobs)
				if(player.assigned_role == job)
					candidates -= player

	if(candidates.len < recommended_enemies)
		for(var/mob/new_player/player in players)
			if(player.client && player.ready)
				if(!(player.client.prefs.be_special & role)) //We don't have enough people who want to be antagonist, make a seperate list of people who don't want to be one
					if(!jobban_isbanned(player, "Syndicate") && !jobban_isbanned(player, roletext)) //Nodrak/Carn: Antag Job-bans
						drafted += player.mind

	if(candidates.len < recommended_enemies && override_jobbans) //If we still don't have enough people, we're going to start drafting banned people.
		for(var/mob/new_player/player in players)
			if (player.client && player.ready)
				if(jobban_isbanned(player, "Syndicate") || jobban_isbanned(player, roletext)) //Nodrak/Carn: Antag Job-bans
					drafted += player.mind

	if(restricted_jobs)
		for(var/datum/mind/player in drafted) //Remove people who can't be an antagonist
			for(var/job in restricted_jobs)
				if(player.assigned_role == job)
					drafted -= player

	drafted = shuffle(drafted) // Will hopefully increase randomness, Donkie

	while(candidates.len < recommended_enemies) //Pick randomly just the number of people we need and add them to our list of candidates
		if(drafted.len > 0)
			applicant = pick(drafted)
			if(applicant)
				candidates += applicant
				drafted.Remove(applicant)
				to_chat(world, "<span class='warning'>[applicant.key] was force-drafted as [roletext], because there aren't enough candidates.</span>")
				log_game("[applicant.key] was force-drafted as [roletext], because there aren't enough candidates.")

		else //Not enough scrubs, ABORT ABORT ABORT
			break

	return candidates		//Returns:	The number of people who had the antagonist role set to yes, regardless of recomended_enemies, if that number is greater than recommended_enemies
							//			recommended_enemies if the number of people with that role set to yes is less than recomended_enemies,
							//			Less if there are not enough valid players in the game entirely to make recommended_enemies.


/datum/game_mode/proc/latespawn(var/mob)
	return FALSE


/datum/game_mode/proc/ready_players()
	var/num = 0
	for(var/mob/new_player/P in GLOB.player_list)
		if(P.client && P.ready)
			num++
	return num


/datum/game_mode/New()
	if(!GLOB.map_tag)
		to_chat(world, "MT001: No mapping tag set, tell a coder. [GLOB.map_tag]")
	initialize_emergency_calls()


/datum/game_mode/proc/display_roundstart_logout_report()
	var/msg = "<span class='notice'><b>Roundstart logout report</b></span>\n"
	for(var/mob/living/L in GLOB.mob_living_list)

		if(L.ckey)
			var/found = 0
			for(var/client/C in GLOB.clients)
				if(C.ckey == L.ckey)
					found = 1
					break
			if(!found)
				msg += "<b>[L.name]</b> ([L.ckey]), the [L.job] (<font color='#ffcc00'><b>Disconnected</b></font>)\n"


		if(L.ckey && L.client)
			if(L.client.inactivity >= (ROUNDSTART_LOGOUT_REPORT_TIME / 2))
				msg += "<b>[L.name]</b> ([L.ckey]), the [L.job] (<font color='#ffcc00'><b>Connected, Inactive</b></font>)\n"
				continue //AFK client
			if(L.stat)
				if(L.suiciding)	//Suicider
					msg += "<b>[L.name]</b> ([L.ckey]), the [L.job] (<font color='red'><b>Suicide</b></font>)\n"
					continue //Disconnected client
				if(L.stat == UNCONSCIOUS)
					msg += "<b>[L.name]</b> ([L.ckey]), the [L.job] (Dying)\n"
					continue //Unconscious
				if(L.stat == DEAD)
					msg += "<b>[L.name]</b> ([L.ckey]), the [L.job] (Dead)\n"
					continue //Dead

			continue //Happy connected client
		for(var/mob/dead/observer/D in GLOB.dead_mob_list)
			if(D.mind && D.mind.current == L)
				if(L.stat == DEAD)
					if(L.suiciding)	//Suicider
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] (<font color='red'><b>Suicide</b></font>)\n"
						continue //Disconnected client
					else
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] (Dead)\n"
						continue //Dead mob, ghost abandoned
				else
					if(D.can_reenter_corpse)
						continue //Lolwhat
					else
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] (<font color='red'><b>Ghosted</b></font>)\n"
						continue //Ghosted while alive



	for(var/client/C in GLOB.clients)
		if(check_other_rights(C, R_ADMIN, FALSE))
			to_chat(C, msg)



/datum/game_mode/proc/printplayer(var/datum/mind/player)
	if(!player)
		return

	var/role

	if(player.assigned_role)
		role = player.assigned_role
	else
		role = "Unassigned"

	var/text = "<br><b>[player.name]</b>(<b>[player.key]</b>) as \a <b>[role]</b> ("
	if(player.current)
		if(player.current.stat == DEAD)
			text += "died"
		else
			text += "survived"
		if(player.current.real_name != player.name)
			text += " as <b>[player.current.real_name]</b>"
	else
		text += "body destroyed"
	text += ")"

	return text