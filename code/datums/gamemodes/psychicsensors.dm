#define SENSORS_NEEDED 5

/datum/game_mode/infestation/distress/psy_sensors
	name = "Psychic Sensors"
	config_tag = "Psychic Sensors"
	flags_round_type = MODE_LZ_SHUTTERS|MODE_TWO_FACTIONS|MODE_HUMAN_ONLY|MODE_XENO_OPFOR
	silo_scaling = 2
	factions = list(FACTION_TERRAGOV, FACTION_XENO)

/datum/game_mode/infestation/distress/psy_sensors/post_setup()
	. = ..()
	for(var/turf/T AS in GLOB.sensor_towers_patrol)
		new /obj/structure/sensor_tower_patrol(T)

/datum/game_mode/infestation/distress/psy_sensors/get_joinable_factions(should_look_balance)
	if(should_look_balance)
		if(length(GLOB.alive_human_list_faction[FACTION_TERRAGOV]) > length(GLOB.alive_human_list_faction[FACTION_XENO]) * MAX_UNBALANCED_RATIO_TWO_HUMAN_FACTIONS)
			return list(FACTION_XENO)
		if(length(GLOB.alive_human_list_faction[FACTION_XENO]) > length(GLOB.alive_human_list_faction[FACTION_TERRAGOV]) * MAX_UNBALANCED_RATIO_TWO_HUMAN_FACTIONS)
			return list(FACTION_TERRAGOV)
	return list(FACTION_TERRAGOV, FACTION_XENO)

/datum/game_mode/infestation/distress/psy_sensors/announce()
	to_chat(world, "<b>The current game mode is - Psychic Sensors!</b>")
	to_chat(world, "<b>Xeno</b>")

/datum/game_mode/infestation/distress/psy_sensors/game_end_countdown()
	if(game_timer == SENSOR_CAP_TIMER_PAUSED)
		return "Timer paused, tower activation in progress"
	return ..()

//End game checks
/datum/game_mode/infestation/distress/psy_sensors/check_finished()
	if(round_finished)
		return TRUE

	if(max_time_reached)
		message_admins("Round finished: [MODE_INFESTATION_X_MAJOR]")
		round_finished = MODE_INFESTATION_X_MAJOR
		return TRUE

	if(sensors_activated >= SENSORS_NEEDED)
		message_admins("Round finished: [MODE_INFESTATION_M_MAJOR]")
		round_finished = MODE_INFESTATION_M_MAJOR
		return TRUE

/datum/game_mode/infestation/distress/psy_sensors/siloless_hive_collapse()
	return

/datum/game_mode/infestation/distress/psy_sensors/get_siloless_collapse_countdown()
	return
