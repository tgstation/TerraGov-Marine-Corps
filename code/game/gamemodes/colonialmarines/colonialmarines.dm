/datum/game_mode/colonialmarines
	name = "Distress Signal"
	config_tag = "Distress Signal"
	required_players = 1
	xeno_required_num = 1
	flags_round_type = MODE_INFESTATION|MODE_FOG_ACTIVATED


/datum/game_mode/colonialmarines/can_start()
	initialize_special_clamps()
	initialize_starting_predator_list()
	var/found_queen = initialize_starting_queen_list()
	var/found_xenos = initialize_starting_xenomorph_list()
	if(!found_queen && !found_xenos)
		return FALSE
	initialize_starting_survivor_list()
	latejoin_larva_drop = CONFIG_GET(number/latejoin_larva_required_num)
	return TRUE


/datum/game_mode/colonialmarines/announce()
	to_chat(world, "<span class='round_header'>The current map is - [map_tag]!</span>")


/datum/game_mode/colonialmarines/send_intercept()
	return TRUE


/datum/game_mode/colonialmarines/pre_setup()
	round_fog = new
	var/xeno_tunnels[] = new
	var/map_items[] = new
	var/obj/effect/blocker/fog/F
	for(var/obj/effect/landmark/L in GLOB.landmarks_list)
		switch(L.name)
			if("hunter_primary")
				qdel(L)
			if("hunter_secondary")
				qdel(L)
			if("crap_item")
				qdel(L)
			if("good_item")
				qdel(L)
			if("block_hellhound")
				qdel(L)
			if("fog blocker")
				F = new(L.loc)
				round_fog += F
				qdel(L)
			if("xeno tunnel")
				xeno_tunnels += L.loc
				qdel(L)
			if("map item")
				map_items += L.loc
				qdel(L)

	for(var/turf/T in map_items)
		map_items -= T
		switch(map_tag)
			if(MAP_LV_624)
				new /obj/item/map/lazarus_landing_map(T)
			if(MAP_ICE_COLONY)
				new /obj/item/map/ice_colony_map(T)
			if(MAP_BIG_RED)
				new /obj/item/map/big_red_map(T)
			if(MAP_PRISON_STATION)
				new /obj/item/map/FOP_map(T)

	if(!length(round_fog))
		round_fog = null //No blockers?
	else
		round_time_fog = rand(-2500, 2500)
		flags_round_type |= MODE_FOG_ACTIVATED
	var/obj/structure/tunnel/T
	var/i = 0
	var/turf/t
	while(length(xeno_tunnels) && i++ < 3)
		t = pick(xeno_tunnels)
		xeno_tunnels -= t
		T = new(t)
		T.id = "hole[i]"

	return TRUE


/datum/game_mode/colonialmarines/post_setup()
	initialize_post_predator_list()
	initialize_post_queen_list()
	initialize_post_xenomorph_list()
	initialize_post_survivor_list()
	initialize_post_marine_gear_list()

	round_time_lobby = world.time
	defer_powernet_rebuild = 2 //Build powernets a little bit later, it lags pretty hard.

	spawn(50)
		switch(map_tag)
			if(MAP_LV_624)
				command_announcement.Announce("An automated distress signal has been received from archaeology site Lazarus Landing, on border world LV-624. A response team from the [MAIN_SHIP_NAME] will be dispatched shortly to investigate.", "[MAIN_SHIP_NAME]")
			if(MAP_ICE_COLONY)
				command_announcement.Announce("An automated distress signal has been received from archaeology site \"Shiva's Snowball\", on border ice world \"Ifrit\". A response team from the [MAIN_SHIP_NAME] will be dispatched shortly to investigate.", "[MAIN_SHIP_NAME]")
			if(MAP_BIG_RED)
				command_announcement.Announce("We've lost contact with the Nanotrasen's research facility, [map_tag]. The [MAIN_SHIP_NAME] has been dispatched to assist.", "[MAIN_SHIP_NAME]")
			if(MAP_PRISON_STATION)
				command_announcement.Announce("An automated distress signal has been received from maximum-security prison \"Fiorina Orbital Penitentiary\". A response team from the [MAIN_SHIP_NAME] will be dispatched shortly to investigate.", "[MAIN_SHIP_NAME]")


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
			var/total[] = ticker.mode.count_humans_and_xenos()
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
	var/living_player_list[] = count_humans_and_xenos(EvacuationAuthority.get_affected_zlevels())
	var/num_humans = living_player_list[1]
	var/num_xenos = living_player_list[2]

	if(EvacuationAuthority.dest_status == NUKE_EXPLOSION_FINISHED)
		round_finished = MODE_GENERIC_DRAW_NUKE //Nuke went off, ending the round.
	else if(EvacuationAuthority.dest_status < NUKE_EXPLOSION_IN_PROGRESS)
		//If the nuke ISN'T in progress. We do not want to end the round before it detonates.
		if(!num_humans && num_xenos) //No humans remain alive.
			if(EvacuationAuthority.evac_status > EVACUATION_STATUS_STANDING_BY)
				round_finished = MODE_INFESTATION_X_MINOR //Evacuation successfully took place. //TODO Find out if anyone made it on.
			else
				round_finished = MODE_INFESTATION_X_MAJOR //Evacuation did not take place. Everyone died.
		else if(num_humans && !num_xenos)
			if(EvacuationAuthority.evac_status > EVACUATION_STATUS_STANDING_BY)
				round_finished = MODE_INFESTATION_M_MINOR //Evacuation successfully took place.
			else
				round_finished = MODE_INFESTATION_M_MAJOR //Humans destroyed the xenomorphs.
		else if(!num_humans && !num_xenos)
			round_finished = MODE_INFESTATION_DRAW_DEATH //Both were somehow destroyed.


/datum/game_mode/colonialmarines/check_queen_status(queen_time)
	var/datum/hive_status/hive = hive_datum[XENO_HIVE_NORMAL]
	hive.xeno_queen_timer = queen_time
	if(!(flags_round_type & MODE_INFESTATION))
		return
	if(!round_finished && !hive.living_xeno_queen)
		round_finished = MODE_INFESTATION_M_MINOR


/datum/game_mode/colonialmarines/check_finished()
	if(round_finished)
		return TRUE


/datum/game_mode/colonialmarines/declare_completion()
	to_chat(world, "<span class='round_header'>|Round Complete|</span>")
	feedback_set_details("round_end_result",round_finished)

	to_chat(world, "<span class='round_body'>Thus ends the story of the brave men and women of the [MAIN_SHIP_NAME] and their struggle on [map_tag].</span>")
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

	to_chat(world, musical_track)

	log_game("[round_finished]\nGame mode: [name]\nRound time: [duration2text()]\nEnd round player population: [GLOB.clients.len]\nTotal xenos spawned: [round_statistics.total_xenos_created]\nTotal Preds spawned: [predators.len]\nTotal humans spawned: [round_statistics.total_humans_created]")

	declare_completion_announce_individual()
	declare_completion_announce_predators()
	declare_completion_announce_xenomorphs()
	declare_completion_announce_survivors()
	declare_completion_announce_medal_awards()
	declare_completion_announce_round_stats()
	end_of_round_deathmatch()
	return TRUE