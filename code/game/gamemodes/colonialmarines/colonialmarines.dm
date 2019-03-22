/datum/game_mode/colonialmarines
	name = "Distress Signal"
	config_tag = "Distress Signal"
	required_players = 1
	xeno_required_num = 1
	flags_round_type = MODE_INFESTATION|MODE_FOG_ACTIVATED
	flags_landmarks = MODE_LANDMARK_SPAWN_XENO_TUNNELS|MODE_LANDMARK_SPAWN_MAP_ITEM


/datum/game_mode/colonialmarines/can_start()
	initialize_special_clamps()
	var/found_queen = initialize_starting_queen_list()
	var/found_xenos = initialize_starting_xenomorph_list()
	if(!found_queen && !found_xenos)
		return FALSE
	initialize_starting_survivor_list()
	latejoin_larva_drop = CONFIG_GET(number/latejoin_larva_required_num)
	return TRUE


/datum/game_mode/colonialmarines/announce()
	to_chat(world, "<span class='round_header'>The current map is - [SSmapping.config.map_name]!</span>")

////////////////////////////////////////////////////////////////////////////////////////
//Temporary, until we sort this out properly.
/obj/effect/landmark/lv624
	icon = 'icons/misc/mark.dmi'

/obj/effect/landmark/lv624/fog_blocker
	name = "fog blocker"
	icon_state = "spawn_event"

/obj/effect/landmark/lv624/fog_blocker/Initialize()
	. = ..()
	GLOB.fog_blocker_locations += loc
	flags_atom |= INITIALIZED
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/xeno_tunnel
	name = "xeno tunnel"
	icon_state = "spawn_event"

/obj/effect/landmark/xeno_tunnel/Initialize()
	. = ..()
	GLOB.xeno_tunnel_landmarks += src

/obj/effect/landmark/xeno_tunnel/Destroy()
	GLOB.xeno_tunnel_landmarks -= src
	return ..()

////////////////////////////////////////////////////////////////////////////////////////
/datum/game_mode/colonialmarines/send_intercept()
	return TRUE


/datum/game_mode/colonialmarines/pre_setup()
	. = ..()

	if(!GLOB.fog_blockers.len)
		flags_round_type &= ~MODE_FOG_ACTIVATED
	else
		round_time_fog = rand(-2500,2500)

	return TRUE


/datum/game_mode/colonialmarines/post_setup()
	. = ..()
	initialize_post_queen_list()
	initialize_post_xenomorph_list()
	initialize_post_survivor_list()
	initialize_post_marine_gear_list()

	round_time_lobby = world.time
	defer_powernet_rebuild = 2 //Build powernets a little bit later, it lags pretty hard.

	addtimer(CALLBACK(SSticker.mode, .proc/map_announce), 5 SECONDS)



/datum/game_mode/colonialmarines/proc/map_announce()
	switch(SSmapping.config.map_name)
		if(MAP_LV_624)
			command_announcement.Announce("An automated distress signal has been received from archaeology site Lazarus Landing, on border world LV-624. A response team from the [CONFIG_GET(string/ship_name)] will be dispatched shortly to investigate.", "[CONFIG_GET(string/ship_name)]")
		if(MAP_ICE_COLONY)
			command_announcement.Announce("An automated distress signal has been received from archaeology site \"Shiva's Snowball\", on border ice world \"Ifrit\". A response team from the [CONFIG_GET(string/ship_name)] will be dispatched shortly to investigate.", "[CONFIG_GET(string/ship_name)]")
		if(MAP_BIG_RED)
			command_announcement.Announce("We've lost contact with the Nanotrasen's research facility, [SSmapping.config.map_name]. The [CONFIG_GET(string/ship_name)] has been dispatched to assist.", "[CONFIG_GET(string/ship_name)]")
		if(MAP_PRISON_STATION)
			command_announcement.Announce("An automated distress signal has been received from maximum-security prison \"Fiorina Orbital Penitentiary\". A response team from the [CONFIG_GET(string/ship_name)] will be dispatched shortly to investigate.", "[CONFIG_GET(string/ship_name)]")


/datum/game_mode/colonialmarines/process()
	if(--round_started > 0)
		return FALSE //Initial countdown, just to be safe, so that everyone has a chance to spawn before we check anything.

	if(!round_finished)
		for(var/datum/hive_status/hive in hive_datum)
			if(hive.xeno_queen_timer && --hive.xeno_queen_timer <= 1)
				xeno_message("The Hive is ready for a new Queen to evolve.", 3, hive.hivenumber)

		// Automated bioscan / Queen Mother message
		if(world.time > bioscan_current_interval) //If world time is greater than required bioscan time.
			announce_bioscans() //Announce the results of the bioscan to both sides.
			var/total[] = SSticker.mode.count_humans_and_xenos()
			var/marines = total[1]
			var/xenos = total[2]
			var/bioscan_scaling_factor = xenos / max(marines, 1)
			bioscan_scaling_factor = max(bioscan_scaling_factor, 0.25)
			bioscan_scaling_factor = min(bioscan_scaling_factor, 1.5) //We don't want it to take super-long
			bioscan_current_interval += bioscan_ongoing_interval * bioscan_scaling_factor //Add to the interval based on our set interval time.

		if(++round_checkwin >= 5) //Only check win conditions every 5 ticks.
			if(flags_round_type & MODE_FOG_ACTIVATED && world.time >= (FOG_DELAY_INTERVAL + round_time_lobby + round_time_fog))
				disperse_fog()//Some RNG thrown in.
			check_win()
			round_checkwin = 0


/datum/game_mode/colonialmarines/check_win()
	var/living_player_list[] = count_humans_and_xenos(SSevacuation.get_affected_zlevels())
	var/num_humans = living_player_list[1]
	var/num_xenos = living_player_list[2]

	if(SSevacuation.dest_status == NUKE_EXPLOSION_FINISHED) //Nuke went off, ending the round.
		message_admins("Round finished: [MODE_GENERIC_DRAW_NUKE]")
		round_finished = MODE_GENERIC_DRAW_NUKE
	else if(!num_humans && num_xenos)
		message_admins("Round finished: [MODE_INFESTATION_X_MAJOR]")
		round_finished = MODE_INFESTATION_X_MAJOR //No humans remain alive.
	else if(num_humans && !num_xenos)
		message_admins("Round finished: [MODE_INFESTATION_M_MAJOR]")
		round_finished = MODE_INFESTATION_M_MAJOR //Humans destroyed the xenomorphs.
	else if(!num_humans && !num_xenos)
		message_admins("Round finished: [MODE_INFESTATION_DRAW_DEATH]")
		round_finished = MODE_INFESTATION_DRAW_DEATH //Both were somehow destroyed.


/datum/game_mode/colonialmarines/check_queen_status(queen_time)
	var/datum/hive_status/hive = hive_datum[XENO_HIVE_NORMAL]
	hive.xeno_queen_timer = queen_time
	queen_death_countdown = 0
	if(!(flags_round_type & MODE_INFESTATION))
		return
	if(!round_finished && !hive.living_xeno_queen)
		round_finished = MODE_INFESTATION_M_MINOR


/datum/game_mode/colonialmarines/get_queen_countdown()
	var/eta = (queen_death_countdown - world.time) * 0.1
	if(eta > 0)
		return "[(eta / 60) % 60]:[add_zero(num2text(eta % 60), 2)]"


/datum/game_mode/colonialmarines/check_finished()
	if(round_finished)
		return TRUE


/datum/game_mode/colonialmarines/declare_completion()
	. = ..()
	to_chat(world, "<span class='round_header'>|Round Complete|</span>")

	to_chat(world, "<span class='round_body'>Thus ends the story of the brave men and women of the [CONFIG_GET(string/ship_name)] and their struggle on [SSmapping.config.map_name].</span>")
	var/musical_track
	switch(round_finished)
		if(MODE_INFESTATION_X_MAJOR)
			musical_track = pick('sound/theme/sad_loss1.ogg','sound/theme/sad_loss2.ogg')
		if(MODE_INFESTATION_M_MAJOR)
			musical_track = pick('sound/theme/winning_triumph1.ogg','sound/theme/winning_triumph2.ogg')
		if(MODE_INFESTATION_X_MINOR)
			musical_track = pick('sound/theme/neutral_melancholy1.ogg','sound/theme/neutral_melancholy2.ogg')
		if(MODE_INFESTATION_M_MINOR)
			musical_track = pick('sound/theme/neutral_hopeful1.ogg','sound/theme/neutral_hopeful2.ogg')
		if(MODE_INFESTATION_DRAW_DEATH)
			musical_track = pick('sound/theme/nuclear_detonation1.ogg','sound/theme/nuclear_detonation2.ogg') //This one is unlikely to play.

	SEND_SOUND(world, musical_track)

	log_game("[round_finished]\nGame mode: [name]\nRound time: [duration2text()]\nEnd round player population: [GLOB.clients.len]\nTotal xenos spawned: [round_statistics.total_xenos_created]\nTotal Preds spawned: [predators.len]\nTotal humans spawned: [round_statistics.total_humans_created]")

	CONFIG_SET(flag/allow_synthetic_gun_use, TRUE)

	declare_completion_announce_individual()
	declare_completion_announce_predators()
	declare_completion_announce_xenomorphs()
	declare_completion_announce_survivors()
	declare_completion_announce_medal_awards()
	declare_completion_announce_round_stats()
	end_of_round_deathmatch()
	return TRUE