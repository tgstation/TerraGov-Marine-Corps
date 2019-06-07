/datum/game_mode/extended
	name = "Extended"
	config_tag = "Extended"
	required_players = 0


/datum/game_mode/announce()
	to_chat(world, "<b>The current game mode is - Extended Role-Playing!</b>")
	to_chat(world, "<b>Just have fun and role-play!</b>")


/datum/game_mode/extended/check_finished()
	if(!round_finished) 
		return FALSE
	return TRUE


/datum/game_mode/extended/declare_completion()
	. = ..()
	to_chat(world, "<span class='round_header'>|Round Complete|</span>")
	to_chat(world, "<span class='round_body'>Thus ends the story of the brave men and women of the [CONFIG_GET(string/ship_name)] and their struggle on [SSmapping.config.map_name].</span>")
	SEND_SOUND(world, pick('sound/theme/neutral_hopeful1.ogg','sound/theme/neutral_hopeful2.ogg'))
	
	log_game("[round_finished]\nGame mode: [name]\nRound time: [duration2text()]\nEnd round player population: [length(GLOB.clients)]\nTotal xenos spawned: [round_statistics.total_xenos_created]\nTotal humans spawned: [round_statistics.total_humans_created]")

	announce_medal_awards()
	announce_round_stats()