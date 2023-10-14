#define SENSORS_NEEDED 5

/datum/game_mode/hvh/combat_patrol/sensor_capture
	name = "Sensor Capture"
	config_tag = "Sensor Capture"
	wave_timer_length = 2 MINUTES
	max_game_time = 10 MINUTES
	blacklist_ground_maps = list(MAP_WHISKEY_OUTPOST, MAP_OSCAR_OUTPOST, MAP_FORT_PHOBOS)
	game_timer_delay = 0
	///The amount of activated sensor towers in sensor capture
	var/sensors_activated = 0

/datum/game_mode/hvh/combat_patrol/sensor_capture/post_setup()
	. = ..()
	for(var/turf/T AS in GLOB.sensor_towers)
		new /obj/structure/sensor_tower(T)

/datum/game_mode/hvh/combat_patrol/sensor_capture/announce()
	to_chat(world, "<b>The current game mode is - Sensor Capture!</b>")
	to_chat(world, "<b>The SOM have launched an invasion to this sector. TerraGov and SOM forces fight over the sensor towers around the sector.</b>")

/datum/game_mode/hvh/combat_patrol/sensor_capture/game_end_countdown()
	if(game_timer == SENSOR_CAP_TIMER_PAUSED)
		return "Timer paused, tower activation in progress"
	return ..()

//End game checks
/datum/game_mode/hvh/combat_patrol/sensor_capture/check_finished()
	if(round_finished)
		return TRUE

	if(max_time_reached)
		message_admins("Round finished: [MODE_COMBAT_PATROL_SOM_MAJOR]")
		round_finished = MODE_COMBAT_PATROL_SOM_MAJOR
		return TRUE

	if(sensors_activated >= SENSORS_NEEDED)
		message_admins("Round finished: [MODE_COMBAT_PATROL_MARINE_MAJOR]")
		round_finished = MODE_COMBAT_PATROL_MARINE_MAJOR
		return TRUE

/datum/game_mode/hvh/combat_patrol/sensor_capture/get_status_tab_items(datum/dcs, mob/source, list/items)
	. = ..()
	items += "Activated Sensor Towers: [sensors_activated]"
