var/global/datum/controller/gameticker/ticker

#define GAME_STATE_PREGAME		1
#define GAME_STATE_SETTING_UP	2
#define GAME_STATE_PLAYING		3
#define GAME_STATE_FINISHED		4


/datum/controller/gameticker
	var/const/restart_timeout = 600
	var/current_state = GAME_STATE_PREGAME

	var/hide_mode = 0
	var/datum/game_mode/mode = null
	var/post_game = 0
	var/event_time = null
	var/event = 0

	var/login_music			// music played in pregame lobby

	var/list/datum/mind/minds = list()//The people in the game. Used for objective tracking.

	var/Bible_icon_state	// icon_state the chaplain has chosen for his bible
	var/Bible_item_state	// item_state the chaplain has chosen for his bible
	var/Bible_name			// name of the bible
	var/Bible_deity_name

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
	'sound/music/title1.ogg',
	'sound/music/title2.ogg',
	'sound/music/title3.ogg',
	'sound/music/clown.ogg')

	do
		pregame_timeleft = 180
		to_chat(world, "<B><FONT color='blue'>Welcome to the pre-game lobby of Colonial Marines!</FONT></B>")
		to_chat(world, "Please, setup your character and select ready. Game will start in [pregame_timeleft] seconds")
		while(current_state == GAME_STATE_PREGAME)
			for(var/i=0, i<10, i++)
				sleep(1)
				vote.process()
			if(going)
				pregame_timeleft--
			if(pregame_timeleft == config.vote_autogamemode_timeleft)
				if(!vote.time_remaining)
					vote.autogamemode()	//Quit calling this over and over and over and over.
					while(vote.time_remaining)
						for(var/i=0, i<10, i++)
							sleep(1)
							vote.process()
			if(pregame_timeleft <= 0)
				current_state = GAME_STATE_SETTING_UP
	while (!setup())


/datum/controller/gameticker/proc/setup()
	//Create and announce mode
	if(master_mode=="secret")
		src.hide_mode = 1
	var/list/datum/game_mode/runnable_modes
	if((master_mode=="random") || (master_mode=="secret"))
		runnable_modes = config.get_runnable_modes()
		if (runnable_modes.len==0)
			current_state = GAME_STATE_PREGAME
			to_chat(world, "<B>Unable to choose playable game mode.</B> Reverting to pre-game lobby.")
			return 0
		if(secret_force_mode != "secret")
			var/datum/game_mode/M = config.pick_mode(secret_force_mode)
			if(M.can_start())
				src.mode = config.pick_mode(secret_force_mode)
		RoleAuthority.reset_roles()
		if(!src.mode)
			src.mode = pickweight(runnable_modes)
		if(src.mode)
			var/mtype = src.mode.type
			src.mode = new mtype
	else
		src.mode = config.pick_mode(master_mode)
	if (!src.mode.can_start())
		to_chat(world, "<B>Unable to start [mode.name].</B> Not enough players, [mode.required_players] players needed. Reverting to pre-game lobby.")
		cdel(mode)
		mode = null
		current_state = GAME_STATE_PREGAME
		RoleAuthority.reset_roles()
		return 0

	var/can_continue = src.mode.pre_setup()//Setup special modes
	if(!can_continue)
		cdel(mode)
		mode = null
		current_state = GAME_STATE_PREGAME
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
		src.mode.announce()

	//Configure mode and assign player to special mode stuff
	RoleAuthority.setup_candidates_and_roles() //Distribute jobs
	create_characters() //Create player characters and transfer them
	collect_minds()
	equip_characters()
	data_core.manifest()
	spawn(2)
		mode.initialize_emergency_calls()


	current_state = GAME_STATE_PLAYING

	callHook("roundstart")

	//here to initialize the random events nicely at round start
	setup_economy()

	shuttle_controller.setup_shuttle_docks()

	spawn(0)//Forking here so we dont have to wait for this to finish
		mode.post_setup()
		//Cleanup some stuff
		for(var/obj/effect/landmark/start/S in landmarks_list)
			//Deleting Startpoints but we need the ai point to AI-ize people later
			if (S.name != "AI")
				cdel(S)
		to_chat(world, "<FONT color='blue'><B>Enjoy the game!</B></FONT>")
		//world << sound('sound/AI/welcome.ogg') // Skie
		//Holiday Round-start stuff	~Carn
		Holiday_Game_Start()

	//start_events() //handles random events and space dust.
	//new random event system is handled from the MC.

	if(config.autooocmute)
		to_chat(world, "\red <B>The OOC channel has been globally disabled due to round start!</B>")
		ooc_allowed = !( ooc_allowed )

//	var/admins_number = 0
//	for(var/client/C)
//		if(C.holder)
//			admins_number++
//	if(admins_number == 0)
//		send2adminirc("Round has started with no admins online.")

	supply_controller.process() 		//Start the supply shuttle regenerating points -- TLE

	//for(var/obj/multiz/ladder/L in object_list) L.connect() //Lazy hackfix for ladders. TODO: move this to an actual controller. ~ Z

	if(config.sql_enabled)
		spawn(3000)
		statistic_cycle() // Polls population totals regularly and stores them in an SQL DB -- TLE
		for(var/obj/structure/closet/C in structure_list) //Set up special equipment for lockers and vendors, depending on gamemode
			C.select_gamemode_equipment(mode.type)
		for(var/obj/machinery/vending/V in machines)
			V.select_gamemode_equipment(mode.type)
	return 1

/datum/controller/gameticker
	proc/create_characters()
		for(var/mob/new_player/player in player_list)
			if(player && player.ready && player.mind)
				if(player.mind.assigned_role=="AI")
					player.close_spawn_windows()
					player.AIize()
				else if(!player.mind.assigned_role)
					continue
				else
					player.create_character()
					cdel(player)


	proc/collect_minds()
		for(var/mob/living/player in player_list)
			if(player.mind)
				ticker.minds += player.mind


	proc/equip_characters()
		var/captainless=1
		if(mode && istype(mode,/datum/game_mode/huntergames)) // || istype(mode,/datum/game_mode/whiskey_outpost)
			return

		var/mob/living/carbon/human/player
		var/m
		for(m in player_list)
			player = m
			if(istype(player) && player.mind && player.mind.assigned_role)
				if(player.mind.assigned_role == "Commander")
					captainless=0
				if(player.mind.assigned_role != "MODE")
					RoleAuthority.equip_role(player, RoleAuthority.roles_by_name[player.mind.assigned_role])
					UpdateFactionList(player)
					EquipCustomItems(player)
		if(captainless)
			for(var/mob/M in player_list)
				if(!istype(M,/mob/new_player))
					to_chat(M, "Marine commander position not forced on anyone.")


	proc/process()
		if(current_state != GAME_STATE_PLAYING)
			return 0

		mode.process()

		var/game_finished = 0
		var/mode_finished = 0
		if (config.continous_rounds)
			if(EvacuationAuthority.dest_status == NUKE_EXPLOSION_FINISHED) game_finished = 1
			mode_finished = (!post_game && mode.check_finished())
		else
			game_finished = (mode.check_finished() /* || (emergency_shuttle.returned() && emergency_shuttle.evac == 1)*/)
			mode_finished = game_finished

		if(!EvacuationAuthority.dest_status != NUKE_EXPLOSION_IN_PROGRESS && game_finished && (mode_finished || post_game))
			current_state = GAME_STATE_FINISHED

			spawn(1)
				declare_completion()

			spawn(50)
				callHook("roundend")

				if (EvacuationAuthority.dest_status == NUKE_EXPLOSION_FINISHED)
					feedback_set_details("end_proper","nuke")
				else
					feedback_set_details("end_proper","proper completion")

				if(config.autooocmute && !ooc_allowed)
					to_chat(world, "\red <B>The OOC channel has been globally enabled due to round end!</B>")
					ooc_allowed = 1

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

		else if (mode_finished)
			post_game = 1

			mode.cleanup()

			//call a transfer shuttle vote
			spawn(50)
				if(!round_end_announced) // Spam Prevention. Now it should announce only once.
					to_chat(world, "\red The round has ended!")
					round_end_announced = 1

		return 1

	proc/getfactionbyname(var/name)
		for(var/datum/faction/F in factions)
			if(F.name == name)
				return F


/datum/controller/gameticker/proc/declare_completion()
/* 	to_chat(world, "<br><br><br><font size=3><b>The round has ended.</b></font>")
	for(var/mob/Player in player_list)
		if(Player.mind && !isnewplayer(Player))
			if(Player.stat != DEAD)
				var/turf/playerTurf = get_turf(Player)
				if(emergency_shuttle.departed && emergency_shuttle.evac)
					if(playerTurf.z != 2)
						to_chat(Player, "<font color='blue'><b>You managed to survive, but were marooned on [station_name()] as [Player.real_name]...</b></font>")
					else
						to_chat(Player, "<font color='green'><b>You managed to survive the events on [station_name()] as [Player.real_name].</b></font>")
				else if(playerTurf.z == 2)
					to_chat(Player, "<font color='green'><b>You successfully underwent crew transfer after events on [station_name()] as [Player.real_name].</b></font>")
				else if(issilicon(Player))
					to_chat(Player, "<font color='green'><b>You remain operational after the events on [station_name()] as [Player.real_name].</b></font>")
				else
					to_chat(Player, "<font color='blue'><b>You missed the crew transfer after the events on [station_name()] as [Player.real_name].</b></font>")
			else
				if(istype(Player,/mob/dead/observer))
					var/mob/dead/observer/O = Player
					if(!O.started_as_observer)
						to_chat(Player, "<font color='red'><b>You did not survive the events on [station_name()]...</b></font>")
				else
					to_chat(Player, "<font color='red'><b>You did not survive the events on [station_name()]...</b></font>")
	to_chat(world, "<br>") */

	for (var/mob/living/silicon/ai/aiPlayer in mob_list)
		if (aiPlayer.stat != 2)
			to_chat(world, "<b>[aiPlayer.name] (Played by: [aiPlayer.key])'s laws at the end of the round were:</b>")
		else
			to_chat(world, "<b>[aiPlayer.name] (Played by: [aiPlayer.key])'s laws when it was deactivated were:</b>")
		aiPlayer.show_laws(1)

		if (aiPlayer.connected_robots.len)
			var/robolist = "<b>The AI's loyal minions were:</b> "
			for(var/mob/living/silicon/robot/robo in aiPlayer.connected_robots)
				robolist += "[robo.name][robo.stat?" (Deactivated) (Played by: [robo.key]), ":" (Played by: [robo.key]), "]"
			to_chat(world, "[robolist]")

	var/dronecount = 0

	for (var/mob/living/silicon/robot/robo in mob_list)

		if(istype(robo,/mob/living/silicon/robot/drone))
			dronecount++
			continue

		if (!robo.connected_ai)
			if (robo.stat != 2)
				to_chat(world, "<b>[robo.name] (Played by: [robo.key]) survived as an AI-less borg! Its laws were:</b>")
			else
				to_chat(world, "<b>[robo.name] (Played by: [robo.key]) was unable to survive the rigors of being a cyborg without an AI. Its laws were:</b>")

			if(robo) //How the hell do we lose robo between here and the world messages directly above this?
				robo.laws.show_laws(world)

	if(dronecount)
		to_chat(world, "<b>There [dronecount>1 ? "were" : "was"] [dronecount] industrious maintenance [dronecount>1 ? "drones" : "drone"] at the end of this round.")

	mode.declare_completion()//To declare normal completion.

	//calls auto_declare_completion_* for all modes
	for(var/handler in typesof(/datum/game_mode/proc))
		if (findtext("[handler]","auto_declare_completion_"))
			call(mode, handler)()

	//Print a list of antagonists to the server log
	var/list/total_antagonists = list()
	//Look into all mobs in the world, dead or alive
	for(var/datum/mind/Mind in minds)
		var/temprole = Mind.special_role
		if(temprole)							//if they are an antagonist of some sort.
			if(temprole in total_antagonists)	//If the role exists already, add the name to it
				total_antagonists[temprole] += ", [Mind.name]([Mind.key])"
			else
				total_antagonists.Add(temprole) //If the role doesnt exist in the list, create it and add the mob
				total_antagonists[temprole] += ": [Mind.name]([Mind.key])"

	//Now print them all into the log!
	log_game("Antagonists at round end were...")
	for(var/i in total_antagonists)
		log_game("[i]s[total_antagonists[i]].")

	return 1
