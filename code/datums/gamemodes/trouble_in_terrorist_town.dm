/datum/game_mode/trouble_in_terrorist_town
	name = "Trouble in Terrorist Town"
	config_tag = "Trouble in Terrorist Town"
	flags_round_type = MODE_NO_JOB_DISTRIBUTION

//todo fix crew monitor

/datum/game_mode/trouble_in_terrorist_town/create_characters()
	for(var/mob/new_player/player AS in GLOB.new_player_list)
		if(!player.ready)
			continue
		var/obj/effect/landmark/start/job/survivor/picked_spawn_job = pick_n_take(GLOB.survivor_spawn)
		player.assigned_role = new picked_spawn_job.job
		player.create_character()
		CHECK_TICK

/datum/game_mode/trouble_in_terrorist_town/pre_setup()
	. = ..()
	for(var/area/area_to_lit AS in GLOB.sorted_areas)
		var/turf/first_turf = area_to_lit.contents[1]
		if(first_turf.z != 2)
			continue
		switch(area_to_lit.ceiling)
			if(CEILING_NONE to CEILING_GLASS)
				area_to_lit.set_base_lighting(COLOR_WHITE, 255)
			if(CEILING_METAL)
				area_to_lit.set_base_lighting(COLOR_WHITE, 150)
			if(CEILING_UNDERGROUND to CEILING_UNDERGROUND_METAL)
				area_to_lit.set_base_lighting(COLOR_WHITE, 50)

