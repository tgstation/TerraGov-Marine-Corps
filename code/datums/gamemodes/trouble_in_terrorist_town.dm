/datum/game_mode/trouble_in_terrorist_town
	name = "Trouble in terrorist town"
	config_tag = "TTT"

/datum/game_mode/trouble_in_terrorist_town/spawn_characters()
	for(var/mob/new_player/player AS in GLOB.new_player_list)
		player.assigned_role = new /datum/job/survivor
		SSjob.spawn_character(player)
		CHECK_TICK
