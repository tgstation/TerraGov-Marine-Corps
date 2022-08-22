/datum/game_mode/combat_patrol/sensor_capture
	name = "Sensor Capture"
	config_tag = "Sensor Capture"
	flags_round_type = MODE_LZ_SHUTTERS|MODE_TWO_HUMAN_FACTIONS|MODE_HUMAN_ONLY|MODE_SOM_OPFOR|MODE_SPECIFIC_SHIP_MAP|MODE_SENSOR
	wave_timer_length = 2 MINUTES
	max_game_time = 15 MINUTES
	sensors_needed = 5

/datum/game_mode/combat_patrol/sensor_capture/post_setup()
	. = ..()
	for(var/turf/T AS in GLOB.sensor_towers_patrol_a)
		new /obj/structure/sensor_tower_patrol(T)
	for(var/turf/T AS in GLOB.sensor_towers_patrol_b)
		new /obj/structure/sensor_tower_patrol/bravo(T)
	for(var/turf/T AS in GLOB.sensor_towers_patrol_c)
		new /obj/structure/sensor_tower_patrol/charlie(T)
	for(var/turf/T AS in GLOB.sensor_towers_patrol_d)
		new /obj/structure/sensor_tower_patrol/delta(T)
	for(var/turf/T AS in GLOB.sensor_towers_patrol_e)
		new /obj/structure/sensor_tower_patrol/echo(T)

/datum/game_mode/combat_patrol/sensor_capture/announce()
	to_chat(world, "<b>The current game mode is - Sensor Capture!</b>")
	to_chat(world, "<b>The SOM have launched an invasion to this sector. TerraGov and SOM forces fight over the extrasolar communication sensor towers.</b>")

/datum/game_mode/combat_patrol/sensor_capture/setup_blockers()
	. = ..()
	//Starts the round timer when the game starts proper
	var/datum/game_mode/combat_patrol/D = SSticker.mode
	addtimer(CALLBACK(D, /datum/game_mode/combat_patrol.proc/set_game_timer), SSticker.round_start_time + shutters_drop_time) //game end timer will start ticking down on shutter drop
	addtimer(CALLBACK(D, /datum/game_mode/combat_patrol.proc/respawn_wave), SSticker.round_start_time + shutters_drop_time) //starts wave respawn on shutter drop and begins timer
	TIMER_COOLDOWN_START(src, COOLDOWN_BIOSCAN, SSticker.round_start_time + shutters_drop_time + bioscan_interval)

/datum/game_mode/combat_patrol/sensor_capture/set_game_end()
	var/datum/game_mode/combat_patrol/D = SSticker.mode
	var/current_time = timeleft(D.game_timer)
	if(current_time > 0)
		return
	max_time_reached = TRUE

//End game checks
/datum/game_mode/combat_patrol/sensor_capture/check_finished()
	if(round_finished)
		return TRUE

	if(max_time_reached)
		message_admins("Round finished: [MODE_COMBAT_PATROL_SOM_MAJOR]")
		round_finished = MODE_COMBAT_PATROL_SOM_MAJOR
		return TRUE

	if(sensors_activated >= sensors_needed)
		message_admins("Round finished: [MODE_COMBAT_PATROL_MARINE_MAJOR]")
		round_finished = MODE_COMBAT_PATROL_MARINE_MAJOR
		return TRUE
