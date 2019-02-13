var/global/datum/controller/gameticker/ticker

#define GAME_STATE_PREGAME		1
#define GAME_STATE_SETTING_UP	2
#define GAME_STATE_PLAYING		3
#define GAME_STATE_FINISHED		4


/datum/controller/gameticker
	var/const/restart_timeout = 2 MINUTES
	var/current_state = GAME_STATE_PREGAME

	var/hide_mode = 0
	var/datum/game_mode/mode = null
	var/post_game = 0
	var/event_time = null
	var/event = 0

	var/login_music

	var/list/datum/mind/minds = list()//The people in the game. Used for objective tracking.

	var/random_players = 0 	// if set to nonzero, ALL players who latejoin or declare-ready join will have random appearances/genders

	var/list/syndicate_coalition = list() // list of traitor-compatible factions
	var/list/factions = list()			  // list of all factions
	var/list/availablefactions = list()	  // list of factions with openings

	var/pregame_timeleft = 0

	var/delay_end = 0	//if set to nonzero, the round will not restart on it's own

	var/triai = 0//Global holder for Triumvirate

	var/round_end_announced = 0 // Spam Prevention. Announce round end only once.
	var/datum/mind/liaison = null

/datum/controller/gameticker/proc/pregame()

	login_music = pick(
	'sound/music/SpaceHero.ogg',
	'sound/music/ManOfWar.ogg',
	'sound/music/PraiseTheLord.ogg',
	'sound/music/BloodUponTheRisers.ogg',
	'sound/music/DawsonChristian.ogg')

	do
		pregame_timeleft = 180
		to_chat(world, "<B><FONT color='blue'>Welcome to the pre-game lobby of TerraGov Marine Corps!</FONT></B>")
		to_chat(world, "Please, setup your character and select ready. Game will start in [pregame_timeleft] seconds")
		while(current_state == GAME_STATE_PREGAME)
			for(var/i=0, i<10, i++)
				sleep(1)
				vote.process()
			if(going)
				pregame_timeleft--
			if(pregame_timeleft == CONFIG_GET(number/vote_autogamemode_timeleft))
				if(!vote.time_remaining)
					vote.autogamemode()	//Quit calling this over and over and over and over.
					while(vote.time_remaining)
						for(var/i=0, i<10, i++)
							sleep(1)
							vote.process()
			if(pregame_timeleft <= 0)
				current_state = GAME_STATE_SETTING_UP
				Master.SetRunLevel(RUNLEVEL_SETUP)
	while(!setup())


/datum/controller/gameticker/proc/setup()
	if(master_mode == "secret")
		hide_mode = TRUE

	var/list/datum/game_mode/runnable_modes
	if((master_mode=="random") || (master_mode=="secret"))

		runnable_modes = config.modes
		if(runnable_modes.len==0)
			current_state = GAME_STATE_PREGAME
			Master.SetRunLevel(RUNLEVEL_LOBBY)
			to_chat(world, "<B>Unable to choose playable game mode.</B> Reverting to pre-game lobby.")
			return FALSE

		if(secret_force_mode != "secret")
			var/datum/game_mode/M = config.pick_mode(secret_force_mode)
			if(M.can_start())
				mode = config.pick_mode(secret_force_mode)
		RoleAuthority.reset_roles()

		if(!mode)
			mode = pickweight(runnable_modes)

		if(mode)
			var/mtype = mode.type
			mode = new mtype
	else
		mode = config.pick_mode(master_mode)


	if(!mode.can_start()) //The mode can't start, reset everything to it's default state.
		to_chat(world, "<B>Unable to start [mode.name].</B> Not enough players, [mode.required_players] players needed. Reverting to pre-game lobby.")
		qdel(mode)
		mode = null
		current_state = GAME_STATE_PREGAME
		Master.SetRunLevel(RUNLEVEL_LOBBY)
		RoleAuthority.reset_roles()
		return FALSE

	var/can_continue = src.mode.pre_setup()//Setup special modes
	if(!can_continue)
		qdel(mode)
		mode = null
		current_state = GAME_STATE_PREGAME
		Master.SetRunLevel(RUNLEVEL_LOBBY)
		to_chat(world, "<B>Error setting up [master_mode].</B> Reverting to pre-game lobby.")
		RoleAuthority.reset_roles()
		return 0

	if(hide_mode)
		var/list/modes = new
		for (var/datum/game_mode/M in runnable_modes)
			modes+=M.name
		modes = sortList(modes)
		to_chat(world, "<B>The current game mode is - Secret!</B>")
		to_chat(world, "<B>Possibilities:</B> [english_list(modes)]")
	else
		mode.announce()

	//Configure mode and assign player to special mode stuff
	RoleAuthority.setup_candidates_and_roles() //Distribute jobs

	create_characters() //Create player characters and transfer them
	collect_minds()
	equip_characters()

	data_core.manifest()
	spawn(2)
		mode.initialize_emergency_calls()


	current_state = GAME_STATE_PLAYING
	Master.SetRunLevel(RUNLEVEL_GAME)

	callHook("roundstart")

	setup_economy()

	shuttle_controller.setup_shuttle_docks()

	spawn(0)
		mode.post_setup()

		for(var/obj/effect/landmark/start/S in GLOB.landmarks_list)
			if(S.name != "AI")
				qdel(S)

		to_chat(world, "<span class='notice'><b>Enjoy the game!</b></span>")
		Holiday_Game_Start()

	if(CONFIG_GET(flag/autooocmute))
		to_chat(world, "<span class='danger'>The OOC channel has been globally disabled due to round start!</span>")
		GLOB.ooc_allowed = FALSE

	supply_controller.process()

	return TRUE


/datum/controller/gameticker/proc/create_characters()
	for(var/mob/new_player/player in GLOB.player_list)
		if(!player?.ready || !player.mind?.assigned_role)
			continue
		player.create_character()
		qdel(player)


/datum/controller/gameticker/proc/collect_minds()
	for(var/mob/living/player in GLOB.player_list)
		if(player.mind)
			ticker.minds += player.mind


/datum/controller/gameticker/proc/equip_characters()
	var/captainless = TRUE

	if(mode && istype(mode, /datum/game_mode/huntergames))
		return

	for(var/player in GLOB.player_list)
		var/mob/living/carbon/human/H = player
		if(istype(H) && H.mind?.assigned_role)
			if(H.mind.assigned_role == "Captain")
				captainless = FALSE
			if(H.mind.assigned_role != "MODE")
				RoleAuthority.equip_role(player, RoleAuthority.roles_by_name[H.mind.assigned_role])
				UpdateFactionList(H)
				EquipCustomItems(H)

	if(captainless)
		for(var/mob/M in GLOB.player_list)
			if(!isnewplayer(M))
				to_chat(M, "Captain position not forced on anyone.")


/datum/controller/gameticker/process()
	if(current_state != GAME_STATE_PLAYING)
		return FALSE

	mode.process()

	var/game_finished = FALSE
	var/mode_finished = FALSE

	if(CONFIG_GET(flag/continous_rounds))
		if(EvacuationAuthority.dest_status == NUKE_EXPLOSION_FINISHED)
			game_finished = TRUE
		mode_finished = (!post_game && mode.check_finished())
	else
		game_finished = mode.check_finished()
		mode_finished = game_finished

	if(!EvacuationAuthority.dest_status != NUKE_EXPLOSION_IN_PROGRESS && game_finished && (mode_finished || post_game))
		current_state = GAME_STATE_FINISHED

		spawn(1)
			declare_completion()

		spawn(50)
			callHook("roundend")

			if(EvacuationAuthority.dest_status == NUKE_EXPLOSION_FINISHED)
				feedback_set_details("end_proper","nuke")
			else
				feedback_set_details("end_proper","proper completion")

			if(CONFIG_GET(flag/autooocmute) && !GLOB.ooc_allowed)
				to_chat(world, "<span class='warning'><b>The OOC channel has been globally enabled due to round end!</b></span>")
				GLOB.ooc_allowed = TRUE

			CONFIG_SET(flag/allow_synthetic_gun_use, TRUE)

			if(blackbox)
				blackbox.save_all_data_to_sql()

			if(!delay_end)
				sleep(restart_timeout)
				if(!delay_end)
					world.Reboot()
				else
					to_chat(world, "<hr>")
					to_chat(world, "<span class='centerbold'><b>An admin has delayed the round end.</b></span>")
					to_chat(world, "<hr>")
			else
				to_chat(world, "<hr>")
				to_chat(world, "<span class='centerbold'><b>An admin has delayed the round end.</b></span>")
				to_chat(world, "<hr>")

	else if(mode_finished)
		post_game = TRUE

		mode.cleanup()

		spawn(50)
			if(!round_end_announced) // Spam Prevention. Now it should announce only once.
				to_chat(world, "<span class='warning'><b>The round has ended!</b></span>")
				round_end_announced = TRUE

	return TRUE


/datum/controller/gameticker/proc/declare_completion()
	for(var/mob/living/silicon/ai/aiPlayer in GLOB.ai_list)
		if(aiPlayer.stat != DEAD)
			to_chat(world, "<b>[aiPlayer.name] (Played by: [aiPlayer.key])'s laws at the end of the round were:</b>")
		else
			to_chat(world, "<b>[aiPlayer.name] (Played by: [aiPlayer.key])'s laws when it was deactivated were:</b>")
		aiPlayer.show_laws(TRUE)

		if(aiPlayer.connected_robots.len)
			var/robolist = "<b>The AI's loyal minions were:</b> "
			for(var/mob/living/silicon/robot/robo in aiPlayer.connected_robots)
				robolist += "[robo.name][robo.stat ? " (Deactivated) (Played by: [robo.key]), " : " (Played by: [robo.key]), "]"
			to_chat(world, "[robolist]")

	var/dronecount = 0

	for(var/mob/living/silicon/robot/robo in GLOB.silicon_mobs)
		if(ismaintdrone(robo))
			dronecount++
			continue

		if(!robo.connected_ai)
			if(robo.stat != DEAD)
				to_chat(world, "<b>[robo.name] (Played by: [robo.key]) survived as an AI-less borg! Its laws were:</b>")
			else
				to_chat(world, "<b>[robo.name] (Played by: [robo.key]) was unable to survive the rigors of being a cyborg without an AI. Its laws were:</b>")

			robo.show_laws(TRUE)

	if(dronecount)
		to_chat(world, "<b>There [dronecount > 1 ? "were" : "was"] [dronecount] industrious maintenance [dronecount > 1 ? "drones" : "drone"] at the end of this round.")

	mode.declare_completion()


	//Print a list of antagonists to the server log
	var/list/total_antagonists = list()
	for(var/datum/mind/Mind in minds)
		var/temprole = Mind.special_role
		if(temprole)
			if(temprole in total_antagonists)
				total_antagonists[temprole] += ", [Mind.name]([Mind.key])"
			else
				total_antagonists.Add(temprole)
				total_antagonists[temprole] += ": [Mind.name]([Mind.key])"

	log_game("Antagonists at round end were:")
	for(var/i in total_antagonists)
		log_game("[i]s[total_antagonists[i]].")

	return TRUE