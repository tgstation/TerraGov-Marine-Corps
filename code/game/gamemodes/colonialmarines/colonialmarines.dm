/datum/game_mode/colonialmarines
	name = "Distress Signal"
	config_tag = "Distress Signal"
	required_players = 1 //Need at least one player, but really we need 2.
	xeno_required_num = 1 //Need at least one xeno.
	monkey_amount = 25
	flags_round_type = MODE_INFESTATION|MODE_FOG_ACTIVATED

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/* Pre-pre-startup */
/datum/game_mode/colonialmarines/can_start()
	initialize_special_clamps()
	initialize_starting_predator_list()
	if(!initialize_starting_xenomorph_list())
		return
	initialize_starting_survivor_list()
	return 1

/datum/game_mode/colonialmarines/announce()
	world << "<span class='round_header'>The current map is - [map_tag]!</span>"

/datum/game_mode/colonialmarines/send_intercept()
	return 1

////////////////////////////////////////////////////////////////////////////////////////
//Temporary, until we sort this out properly.
/obj/effect/landmark/lv624
	icon = 'icons/misc/mark.dmi'

/obj/effect/landmark/lv624/fog_blocker
	name = "fog blocker"
	icon_state = "spawn_event"

/obj/effect/landmark/lv624/xeno_tunnel
	name = "xeno tunnel"
	icon_state = "spawn_event"

////////////////////////////////////////////////////////////////////////////////////////

/* Pre-setup */
/datum/game_mode/colonialmarines/pre_setup()
	round_fog = new
	var/xeno_tunnels[] = new
	var/monkey_spawns[] = new
	var/map_items[] = new
	var/obj/effect/blocker/fog/F
	for(var/obj/effect/landmark/L in landmarks_list)
		switch(L.name)
			if("hunter_primary")
				cdel(L)
			if("hunter_secondary")
				cdel(L)
			if("crap_item")
				cdel(L)
			if("good_item")
				cdel(L)
			if("block_hellhound")
				cdel(L)
			if("fog blocker")
				F = new(L.loc)
				round_fog += F
				cdel(L)
			if("xeno tunnel")
				xeno_tunnels += L.loc
				cdel(L)
			if("monkey_spawn")
				monkey_spawns += L.loc
				cdel(L)
			if("map item")
				map_items += L.loc
				cdel(L)

	// Spawn gamemode-specific map items
	for(var/turf/T in map_items)
		map_items -= T
		switch(map_tag)
			if(MAP_LV_624) new /obj/item/map/lazarus_landing_map(T)
			if(MAP_ICE_COLONY) new /obj/item/map/ice_colony_map(T)
			if(MAP_BIG_RED) new /obj/item/map/big_red_map(T)
			if(MAP_PRISON_STATION) new /obj/item/map/FOP_map(T)

	if(monkey_amount)
		//var/debug_tally = 0
		switch(map_tag)
			if(MAP_LV_624) monkey_types = list(/mob/living/carbon/monkey, /mob/living/carbon/monkey/tajara, /mob/living/carbon/monkey/unathi, /mob/living/carbon/monkey/skrell)
			if(MAP_ICE_COLONY) monkey_types = list(/mob/living/carbon/monkey/yiren)
			if(MAP_BIG_RED) monkey_types = list(/mob/living/carbon/monkey)
			if(MAP_PRISON_STATION) monkey_types = list(/mob/living/carbon/monkey)
		if(monkey_types.len)
			for(var/i = monkey_amount, i > 0, i--)
				var/turf/T = pick(monkey_spawns)
				monkey_spawns -= T
				var/monkey_to_spawn = pick(monkey_types)
				new monkey_to_spawn(T)
				//debug_tally++

		//message_admins("SPAWNED [debug_tally] MONKEYS") //DO NOT LEAVE THIS UNCOMMENTED, THIS IS DEV INFO ONLY

	if(!round_fog.len) round_fog = null //No blockers?
	else
		round_time_fog = rand(-2500,2500)
		flags_round_type |= MODE_FOG_ACTIVATED
	var/obj/structure/tunnel/T
	var/i = 0
	var/turf/t
	while(xeno_tunnels.len && i++ < 3)
		t = pick(xeno_tunnels)
		xeno_tunnels -= t
		T = new(t)
		T.id = "hole[i]"

	r_TRU

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/* Post-setup */
//This happens after create_character, so our mob SHOULD be valid and built by now, but without job data.
//We move it later with transform_survivor but they might flicker at any start_loc spawn landmark effects then disappear.
//Xenos and survivors should not spawn anywhere until we transform them.
/datum/game_mode/colonialmarines/post_setup()
	initialize_post_predator_list()
	initialize_post_xenomorph_list()
	initialize_post_survivor_list()
	initialize_post_marine_gear_list()

	round_time_lobby = world.time
	defer_powernet_rebuild = 2 //Build powernets a little bit later, it lags pretty hard.

	spawn (50)
		switch(map_tag)
			if(MAP_LV_624)
				command_announcement.Announce("An automated distress signal has been received from archaeology site Lazarus Landing, on border world LV-624. A response team from the [MAIN_SHIP_NAME] will be dispatched shortly to investigate.", "[MAIN_SHIP_NAME]")
			if(MAP_ICE_COLONY)
				command_announcement.Announce("An automated distress signal has been received from archaeology site \"Shiva's Snowball\", on border ice world \"Ifrit\". A response team from the [MAIN_SHIP_NAME] will be dispatched shortly to investigate.", "[MAIN_SHIP_NAME]")
			if(MAP_BIG_RED)
				command_announcement.Announce("We've lost contact with the Weyland-Yutani's research facility, [map_tag]. The [MAIN_SHIP_NAME] has been dispatched to assist.", "[MAIN_SHIP_NAME]")
			if(MAP_PRISON_STATION)
				command_announcement.Announce("An automated distress signal has been received from maximum-security prison \"Fiorina Orbital Penitentiary\". A response team from the [MAIN_SHIP_NAME] will be dispatched shortly to investigate.", "[MAIN_SHIP_NAME]")

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

#define FOG_DELAY_INTERVAL		27000 // 45 minutes
//This is processed each tick, but check_win is only checked 5 ticks, so we don't go crazy with scanning for mobs.
/datum/game_mode/colonialmarines/process()
	if(--round_started > 0) r_FAL //Initial countdown, just to be safe, so that everyone has a chance to spawn before we check anything.

	if(!round_finished)
		for(var/datum/hive_status/hive in hive_datum)
			if(hive.xeno_queen_timer && --hive.xeno_queen_timer <= 1) xeno_message("The Hive is ready for a new Queen to evolve.", 3, hive.hivenumber)

		// Automated bioscan / Queen Mother message
		if(world.time > bioscan_current_interval) //If world time is greater than required bioscan time.
			announce_bioscans() //Announce the results of the bioscan to both sides.
			bioscan_current_interval += bioscan_ongoing_interval //Add to the interval based on our set interval time.

		if(++round_checkwin >= 5) //Only check win conditions every 5 ticks.
			if(flags_round_type & MODE_FOG_ACTIVATED && world.time >= (FOG_DELAY_INTERVAL + round_time_lobby + round_time_fog)) disperse_fog()//Some RNG thrown in.
			check_win()
			round_checkwin = 0

#undef FOG_DELAY_INTERVAL

///////////////////////////
//Checks to see who won///
//////////////////////////
/datum/game_mode/colonialmarines/check_win()
	var/living_player_list[] = count_humans_and_xenos(EvacuationAuthority.get_affected_zlevels())
	var/num_humans = living_player_list[1]
	var/num_xenos = living_player_list[2]

	if(EvacuationAuthority.dest_status == NUKE_EXPLOSION_FINISHED)				round_finished = MODE_GENERIC_DRAW_NUKE //Nuke went off, ending the round.
	if(EvacuationAuthority.dest_status < NUKE_EXPLOSION_IN_PROGRESS) //If the nuke ISN'T in progress. We do not want to end the round before it detonates.
		if(!num_humans && num_xenos) //No humans remain alive.
			if(EvacuationAuthority.evac_status > EVACUATION_STATUS_STANDING_BY) round_finished = MODE_INFESTATION_X_MINOR //Evacuation successfully took place. //TODO Find out if anyone made it on.
			else																round_finished = MODE_INFESTATION_X_MAJOR //Evacuation did not take place. Everyone died.
		else if(num_humans && !num_xenos)
			if(EvacuationAuthority.evac_status > EVACUATION_STATUS_STANDING_BY) round_finished = MODE_INFESTATION_M_MINOR //Evacuation successfully took place.
			else																round_finished = MODE_INFESTATION_M_MAJOR //Humans destroyed the xenomorphs.
		else if(!num_humans && !num_xenos)										round_finished = MODE_INFESTATION_DRAW_DEATH //Both were somehow destroyed.

/datum/game_mode/colonialmarines/check_queen_status(queen_time)
	set waitfor = 0
	var/datum/hive_status/hive = hive_datum[XENO_HIVE_NORMAL]
	hive.xeno_queen_timer = queen_time
	if(!(flags_round_type & MODE_INFESTATION)) return
	xeno_queen_deaths += 1
	var/num_last_deaths = xeno_queen_deaths
	sleep(QUEEN_DEATH_COUNTDOWN)
	//We want to make sure that another queen didn't die in the interim.

	if(xeno_queen_deaths == num_last_deaths && !round_finished && !hive.living_xeno_queen ) round_finished = MODE_INFESTATION_M_MINOR

///////////////////////////////
//Checks if the round is over//
///////////////////////////////
/datum/game_mode/colonialmarines/check_finished()
	if(round_finished) return 1

//////////////////////////////////////////////////////////////////////
//Announces the end of the game with all relevant information stated//
//////////////////////////////////////////////////////////////////////
/datum/game_mode/colonialmarines/declare_completion()
	//world << "<span class='round_header'>[round_finished]</span>"
	world << "<span class='round_header'>|Round Complete|</span>"
	feedback_set_details("round_end_result",round_finished)

	world << "<span class='round_body'>Thus ends the story of the brave men and women of the [MAIN_SHIP_NAME] and their struggle on [map_tag].</span>"
	world << "<span class='round_body'>End of Round Grief (EORG) is an IMMEDIATE 3 hour ban with no warnings, see rule #3 for more details.</span>"
	var/musical_track
	switch(round_finished)
		if(MODE_INFESTATION_X_MAJOR) musical_track = pick('sound/theme/sad_loss1.ogg','sound/theme/sad_loss2.ogg')
		if(MODE_INFESTATION_M_MAJOR) musical_track = pick('sound/theme/winning_triumph1.ogg','sound/theme/winning_triumph2.ogg')
		if(MODE_INFESTATION_X_MINOR) musical_track = pick('sound/theme/neutral_melancholy1.ogg','sound/theme/neutral_melancholy2.ogg')
		if(MODE_INFESTATION_M_MINOR) musical_track = pick('sound/theme/neutral_hopeful1.ogg','sound/theme/neutral_hopeful2.ogg')
		if(MODE_INFESTATION_DRAW_DEATH) musical_track = pick('sound/theme/nuclear_detonation1.ogg','sound/theme/nuclear_detonation2.ogg') //This one is unlikely to play.
	world << musical_track

	var/dat = ""
	//if(flags_round_type & MODE_INFESTATION)
		//var/living_player_list[] = count_humans_and_xenos()
		//dat = "\nXenomorphs remaining: [living_player_list[2]]. Humans remaining: [living_player_list[1]]."
	if(round_stats) round_stats << "[round_finished][dat]\nGame mode: [name]\nRound time: [duration2text()]\nEnd round player population: [clients.len]\nTotal xenos spawned: [round_statistics.total_xenos_created]\nTotal Preds spawned: [predators.len]\nTotal humans spawned: [round_statistics.total_humans_created][log_end]" // Logging to data/logs/round_stats.log

	world << dat

	declare_completion_announce_individual()
	declare_completion_announce_predators()
	declare_completion_announce_xenomorphs()
	declare_completion_announce_survivors()
	declare_completion_announce_medal_awards()
	return 1
