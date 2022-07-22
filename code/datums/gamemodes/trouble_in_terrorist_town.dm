/datum/game_mode/trouble_in_terrorist_town
	name = "Trouble in Terrorist Town"
	config_tag = "Trouble in Terrorist Town"
	flags_round_type = MODE_NO_JOB_DISTRIBUTION

/datum/game_mode/trouble_in_terrorist_town/create_characters()
	for(var/mob/new_player/player AS in GLOB.new_player_list)
		if(!player.ready)
			continue
		var/obj/effect/landmark/start/job/survivor/picked_spawn_job = pick_n_take(GLOB.survivor_spawn)
		player.assigned_role = new picked_spawn_job.job
		player.create_character()
		CHECK_TICK
