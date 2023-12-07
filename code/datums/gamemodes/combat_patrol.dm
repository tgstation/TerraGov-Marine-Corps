/datum/game_mode/hvh/combat_patrol
	name = "Combat Patrol"
	config_tag = "Combat Patrol"
	flags_round_type = MODE_LATE_OPENING_SHUTTER_TIMER|MODE_TWO_HUMAN_FACTIONS|MODE_HUMAN_ONLY
	shutters_drop_time = 3 MINUTES
	whitelist_ship_maps = list(MAP_COMBAT_PATROL_BASE)
	blacklist_ship_maps = null
	blacklist_ground_maps = list(MAP_WHISKEY_OUTPOST, MAP_OSCAR_OUTPOST, MAP_FORT_PHOBOS)
	bioscan_interval = 3 MINUTES
	/// Timer used to calculate how long till round ends
	var/game_timer
	///The length of time until round ends.
	var/max_game_time = 35 MINUTES
	/// Timer used to calculate how long till next respawn wave
	var/wave_timer
	///The length of time until next respawn wave.
	var/wave_timer_length = 5 MINUTES
	///Whether the max game time has been reached
	var/max_time_reached = FALSE
	///Delay from shutter drop until game timer starts
	var/game_timer_delay = 5 MINUTES

/datum/game_mode/hvh/combat_patrol/announce()
	to_chat(world, "<b>The current game mode is - Combat Patrol!</b>")
	to_chat(world, "<b>The TGMC and SOM both lay claim to this planet. Across contested areas, small combat patrols frequently clash in their bid to enforce their respective claims. Seek and destroy any hostiles you encounter, good hunting!</b>")

/datum/game_mode/hvh/combat_patrol/setup_blockers()
	. = ..()
	//Starts the round timer when the game starts proper
	var/datum/game_mode/hvh/combat_patrol/D = SSticker.mode
	addtimer(CALLBACK(D, TYPE_PROC_REF(/datum/game_mode/hvh/combat_patrol, set_game_timer)), SSticker.round_start_time + shutters_drop_time + game_timer_delay) //game cannot end until at least 5 minutes after shutter drop
	addtimer(CALLBACK(D, TYPE_PROC_REF(/datum/game_mode/hvh/combat_patrol, respawn_wave)), SSticker.round_start_time + shutters_drop_time) //starts wave respawn on shutter drop and begins timer
	addtimer(CALLBACK(D, TYPE_PROC_REF(/datum/game_mode/hvh/combat_patrol, intro_sequence)), SSticker.round_start_time + shutters_drop_time - 10 SECONDS) //starts intro sequence 10 seconds before shutter drop
	TIMER_COOLDOWN_START(src, COOLDOWN_BIOSCAN, SSticker.round_start_time + shutters_drop_time + bioscan_interval)

/datum/game_mode/hvh/combat_patrol/intro_sequence()
	var/op_name_tgmc = GLOB.operation_namepool[/datum/operation_namepool].get_random_name()
	var/op_name_som = GLOB.operation_namepool[/datum/operation_namepool].get_random_name()
	for(var/mob/living/carbon/human/human AS in GLOB.alive_human_list)
		if(human.faction == FACTION_TERRAGOV)
			human.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:left valign='top'><u>[op_name_tgmc]</u></span><br>" + "[SSmapping.configs[GROUND_MAP].map_name]<br>" + "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")] [stationTimestamp("hh:mm")]<br>" + "Territorial Defense Force Platoon<br>" + "[human.job.title], [human]<br>", /atom/movable/screen/text/screen_text/picture/tdf)
		else
			human.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:left valign='top'><u>[op_name_som]</u></span><br>" + "[SSmapping.configs[GROUND_MAP].map_name]<br>" + "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")] [stationTimestamp("hh:mm")]<br>" + "Shokk Infantry Platoon<br>" + "[human.job.title], [human]<br>", /atom/movable/screen/text/screen_text/picture/shokk)

/datum/game_mode/hvh/combat_patrol/game_end_countdown()
	if(!game_timer)
		return
	var/eta = timeleft(game_timer) * 0.1
	if(eta > 0)
		return "[(eta / 60) % 60]:[add_leading(num2text(eta % 60), 2, "0")]"
	else
		return "Patrol finished"

/datum/game_mode/hvh/combat_patrol/wave_countdown()
	if(!wave_timer)
		return
	var/eta = timeleft(wave_timer) * 0.1
	if(eta > 0)
		return "[(eta / 60) % 60]:[add_leading(num2text(eta % 60), 2, "0")]"

/datum/game_mode/hvh/combat_patrol/process()
	if(round_finished)
		return PROCESS_KILL

	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_BIOSCAN) || bioscan_interval == 0)
		return
	announce_bioscans_marine_som()

//End game checks
/datum/game_mode/hvh/combat_patrol/check_finished()
	if(round_finished)
		return TRUE

	if(SSmonitor.gamestate != GROUNDSIDE || !game_timer)
		return

	///pulls the number of marines and SOM, both dead and alive
	var/list/player_list = count_humans(count_flags = COUNT_IGNORE_ALIVE_SSD)
	var/num_som = length(player_list[1])
	var/num_tgmc = length(player_list[2])
	var/num_dead_som = length(player_list[3])
	var/num_dead_marines = length(player_list[4])

	if(num_tgmc && num_som && !max_time_reached)
		return //fighting is ongoing

	//major victor for wiping out the enemy, or draw if both sides wiped simultaneously somehow
	if(!num_tgmc)
		if(!num_som)
			message_admins("Round finished: [MODE_COMBAT_PATROL_DRAW]") //everyone died at the same time, no one wins
			round_finished = MODE_COMBAT_PATROL_DRAW
			return TRUE
		message_admins("Round finished: [MODE_COMBAT_PATROL_SOM_MAJOR]") //SOM wiped out ALL the marines, SOM major victory
		round_finished = MODE_COMBAT_PATROL_SOM_MAJOR
		return TRUE

	if(!num_som)
		message_admins("Round finished: [MODE_COMBAT_PATROL_MARINE_MAJOR]") //Marines wiped out ALL the SOM, marine major victory
		round_finished = MODE_COMBAT_PATROL_MARINE_MAJOR
		return TRUE

	//minor victories for more kills or draw for equal kills
	if(num_dead_marines > num_dead_som)
		message_admins("Round finished: [MODE_COMBAT_PATROL_SOM_MINOR]") //The SOM inflicted greater casualties on the marines, SOM minor victory
		round_finished = MODE_COMBAT_PATROL_SOM_MINOR
		return TRUE
	if(num_dead_som > num_dead_marines)
		message_admins("Round finished: [MODE_COMBAT_PATROL_MARINE_MINOR]") //The marines inflicted greater casualties on the SOM, marine minor victory
		round_finished = MODE_COMBAT_PATROL_MARINE_MINOR
		return TRUE

	message_admins("Round finished: [MODE_COMBAT_PATROL_DRAW]") //equal number of kills, or any other edge cases
	round_finished = MODE_COMBAT_PATROL_DRAW
	return TRUE

/datum/game_mode/hvh/combat_patrol/declare_completion()
	. = ..()
	to_chat(world, span_round_header("|[round_finished]|"))
	log_game("[round_finished]\nGame mode: [name]\nRound time: [duration2text()]\nEnd round player population: [length(GLOB.clients)]\nTotal TGMC spawned: [GLOB.round_statistics.total_humans_created[FACTION_TERRAGOV]]\nTotal SOM spawned: [GLOB.round_statistics.total_humans_created[FACTION_SOM]]")
	to_chat(world, span_round_body("Thus ends the story of the brave men and women of both the TGMC and SOM, and their struggle on [SSmapping.configs[GROUND_MAP].map_name]."))

///round timer
/datum/game_mode/hvh/combat_patrol/proc/set_game_timer()
	if(!iscombatpatrolgamemode(SSticker.mode))
		return
	var/datum/game_mode/hvh/combat_patrol/D = SSticker.mode

	if(D.game_timer)
		return

	D.game_timer = addtimer(CALLBACK(D, TYPE_PROC_REF(/datum/game_mode/hvh/combat_patrol, set_game_end)), max_game_time, TIMER_STOPPABLE)

///Triggers the game to end
/datum/game_mode/hvh/combat_patrol/proc/set_game_end()
	max_time_reached = TRUE

///Allows all the dead to respawn together
/datum/game_mode/hvh/combat_patrol/proc/respawn_wave()
	var/datum/game_mode/hvh/combat_patrol/D = SSticker.mode
	D.wave_timer = addtimer(CALLBACK(D, TYPE_PROC_REF(/datum/game_mode/hvh/combat_patrol, respawn_wave)), wave_timer_length, TIMER_STOPPABLE)

	for(var/i in GLOB.observer_list)
		var/mob/dead/observer/M = i
		GLOB.key_to_time_of_role_death[M.key] -= respawn_time
		M.playsound_local(M, 'sound/ambience/votestart.ogg', 75, 1)
		M.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:center valign='top'><u>RESPAWN WAVE AVAILABLE</u></span><br>" + "YOU CAN NOW RESPAWN.", /atom/movable/screen/text/screen_text/command_order)
		to_chat(M, "<br><font size='3'>[span_attack("Reinforcements are gathering to join the fight, you can now respawn to join a fresh patrol!")]</font><br>")
