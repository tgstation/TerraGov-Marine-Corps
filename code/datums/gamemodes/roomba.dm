#define SENSORS_NEEDED 5

/datum/game_mode/combat_patrol/roomba_race
	name = "Roomba Race"
	config_tag = "Roomba Race"
	wave_timer_length = 2 MINUTES
	max_game_time = 999 MINUTES
	game_timer_delay = 1 MINUTES
	blacklist_ground_maps = null
	whitelist_ground_maps = list(MAP_ROOMBA_STADIUM)

/datum/game_mode/combat_patrol/roomba_race/announce()
	to_chat(world, "<b>The current game mode is - Roomba Race!</b>")
	to_chat(world, "<b>The SOM and TerraGov has decided to bet the war on a roomba race, whoever wins this race will decide the fate of the war.</b>")

