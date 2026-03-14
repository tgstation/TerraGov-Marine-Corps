/datum/game_mode/hvh/combat_patrol/sensor_capture/free_for_all
	name = "Free for all"
	config_tag = "Free for all"
	round_type_flags = MODE_LATE_OPENING_SHUTTER_TIMER|MODE_TWO_HUMAN_FACTIONS|MODE_XENO_SPAWN_PROTECT|MODE_INFESTATION
	xeno_abilities_flags = ABILITY_CRASH

/datum/game_mode/hvh/combat_patrol/sensor_capture/free_for_all/announce()
	to_chat(world, "<b>The current game mode is - Free for all!</b>")
	to_chat(world, "<b>SOM and Terragov forces are fighting for control of this sector and an alien threat has emerged, capture the sensor towers for your team.</b>")

/datum/game_mode/hvh/combat_patrol/sensor_capture/free_for_all/get_deploy_point_message(mob/living/user)
	. = "Capture as many sensor towers as possible, deny them to the other team."
