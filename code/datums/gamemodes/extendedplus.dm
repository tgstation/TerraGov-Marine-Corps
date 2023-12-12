/datum/game_mode/infestation/extended_plus
	name = "Extended Plus"
	config_tag = "Extended Plus"
	silo_scaling = 1
	flags_round_type = MODE_INFESTATION|MODE_PSY_POINTS|MODE_PSY_POINTS_ADVANCED|MODE_HIJACK_POSSIBLE|MODE_SILO_RESPAWN|MODE_ALLOW_XENO_QUICKBUILD|MODE_SILOS_SPAWN_MINIONS
	shutters_drop_time = 3 MINUTES
	flags_xeno_abilities = ABILITY_NUCLEARWAR
	factions = list(FACTION_TERRAGOV, FACTION_SOM, FACTION_ALIEN, FACTION_CLF)
	valid_job_types = list(
		/datum/job/terragov/command/captain = 1,
		/datum/job/terragov/command/ceo = 1,
		/datum/job/terragov/command/fieldcommander = 1,
		/datum/job/terragov/command/corpseccommander = 1,
		/datum/job/terragov/command/staffofficer = 4,
		/datum/job/terragov/command/commanddoll = 4,
		/datum/job/terragov/command/pilot = 2,
		/datum/job/terragov/command/mech_pilot = 1,
		/datum/job/terragov/engineering/chief = 1,
		/datum/job/terragov/engineering/tech = 2,
		/datum/job/terragov/requisitions/officer = 2,
		/datum/job/terragov/medical/professor = 1,
		/datum/job/terragov/medical/medicalofficer = 6,
		/datum/job/terragov/security/security_officer = 8,
		/datum/job/terragov/medical/researcher = 3,
		/datum/job/terragov/civilian/liaison = 1,
		/datum/job/terragov/silicon/synthetic = 4,
		/datum/job/terragov/silicon/ai = 1,
		/datum/job/terragov/squad/engineer = 8,
		/datum/job/terragov/squad/corpsman = 8,
		/datum/job/terragov/squad/smartgunner = 4,
		/datum/job/terragov/squad/leader = 4,
		/datum/job/terragov/squad/specialist = 4,
		/datum/job/terragov/squad/standard = -1,
		/datum/job/worker/moraleofficer = -1,
		/datum/job/worker = -1,
		/datum/job/survivor/rambo = -1,
		/datum/job/other/prisoner = -1,
		/datum/job/xenomorph = 8,
		/datum/job/xenomorph/queen = 1,
		/datum/job/som/command/commander = 1,
		/datum/job/som/command/fieldcommander = 1,
		/datum/job/som/command/staffofficer = 1,
		/datum/job/som/command/pilot = 1,
		/datum/job/som/squad/medic = 2,
		/datum/job/som/squad/engineer = 1,
		/datum/job/som/squad/leader = 1,
		/datum/job/som/squad/veteran = 1,
		/datum/job/som/squad/standard = 5,
		/datum/job/clf/leader = 1,
		/datum/job/clf/specialist = 1,
		/datum/job/clf/medic = 2,
		/datum/job/clf/standard = 5,
		/datum/job/clf/breeder = -1
	)
	enable_fun_tads = TRUE
	xenorespawn_time = 15 SECONDS
	respawn_time = 15 SECONDS
	bioscan_interval = 1 HOURS


/datum/game_mode/infestation/can_start(bypass_checks = FALSE)
	. = ..()
	if(!.)
		return
	var/xeno_candidate = FALSE //Let's not guarantee there's at least one xeno.
	for(var/level = JOBS_PRIORITY_HIGH; level >= JOBS_PRIORITY_LOW; level--)
		for(var/p in GLOB.ready_players)
			var/mob/new_player/player = p
			if(player.client.prefs.job_preferences[ROLE_XENO_QUEEN] == level && SSjob.AssignRole(player, SSjob.GetJobType(/datum/job/xenomorph/queen)))
				xeno_candidate = TRUE
				break
			if(player.client.prefs.job_preferences[ROLE_XENOMORPH] == level && SSjob.AssignRole(player, SSjob.GetJobType(/datum/job/xenomorph)))
				xeno_candidate = TRUE
				break
	if(!xeno_candidate && !bypass_checks)
		xeno_candidate = TRUE


//sets NTC and SOM squads
/datum/game_mode/infestation/extended_plus/set_valid_squads()
	SSjob.active_squads[FACTION_TERRAGOV] = list()
	SSjob.active_squads[FACTION_SOM] = list()
	for(var/key in SSjob.squads)
		var/datum/squad/squad = SSjob.squads[key]
		if(squad.faction == FACTION_TERRAGOV || squad.faction == FACTION_SOM) //We only want Marine and SOM squads, future proofs if more faction squads are added
			SSjob.active_squads[squad.faction] += squad
	return TRUE

/datum/game_mode/infestation/extended_plus/announce()
	to_chat(world, "<b>The current game mode is - Extended Role-Playing!</b>")
	to_chat(world, "<b>Just have fun and role-play!</b>")

/datum/game_mode/infestation/extended_plus/check_finished()
	if(!round_finished)
		return FALSE
	return TRUE

/datum/game_mode/infestation/extended_plus/declare_completion()
	. = ..()
	to_chat(world, span_round_header("|[round_finished]|"))
	var/sound/S = sound(pick('sound/theme/neutral_hopeful1.ogg','sound/theme/neutral_hopeful2.ogg'), channel = CHANNEL_CINEMATIC)
	SEND_SOUND(world, S)

	log_game("[round_finished]\nGame mode: [name]\nRound time: [duration2text()]\nEnd round player population: [length(GLOB.clients)]\nTotal xenos spawned: [GLOB.round_statistics.total_xenos_created]\nTotal humans spawned: [GLOB.round_statistics.total_humans_created]")

/datum/game_mode/infestation/extended_plus/post_setup()
	. = ..()
	if(bioscan_interval)
		TIMER_COOLDOWN_START(src, COOLDOWN_BIOSCAN, bioscan_interval)
	var/weed_type
	for(var/turf/T in GLOB.xeno_weed_node_turfs)
		weed_type = pickweight(GLOB.weed_prob_list)
		new weed_type(T)
	for(var/turf/T AS in GLOB.xeno_resin_wall_turfs)
		T.ChangeTurf(/turf/closed/wall/resin, T.type)
	for(var/i in GLOB.xeno_resin_door_turfs)
		new /obj/structure/mineral_door/resin(i)
	for(var/i in GLOB.xeno_tunnel_spawn_turfs)
		var/obj/structure/xeno/tunnel/new_tunnel = new /obj/structure/xeno/tunnel(i, XENO_HIVE_NORMAL)
		new_tunnel.name = "[get_area_name(new_tunnel)] tunnel"
		new_tunnel.tunnel_desc = "["[get_area_name(new_tunnel)]"] (X: [new_tunnel.x], Y: [new_tunnel.y])"
	for(var/i in GLOB.xeno_jelly_pod_turfs)
		new /obj/structure/xeno/resin_jelly_pod(i, XENO_HIVE_NORMAL)
	for(var/i in GLOB.xeno_resin_silo_turfs)
		new /obj/structure/xeno/pherotower(i)

	SSpoints.add_psy_points(XENO_HIVE_NORMAL, 1400)

	for(var/obj/effect/landmark/corpsespawner/corpse AS in GLOB.corpse_landmarks_list)
		corpse.create_mob()

	for(var/mob/living/carbon/xenomorph/larva/xeno in GLOB.alive_xeno_list)
		xeno.evolution_stored = xeno.xeno_caste.evolution_threshold //Immediate roundstart evo for larva.

	generate_nuke_disk_spawners()

	RegisterSignal(SSdcs, COMSIG_GLOB_NUKE_EXPLODED, PROC_REF(on_nuclear_explosion))
	RegisterSignal(SSdcs, COMSIG_GLOB_NUKE_DIFFUSED, PROC_REF(on_nuclear_diffuse))
	RegisterSignal(SSdcs, COMSIG_GLOB_NUKE_START, PROC_REF(on_nuke_started))

/datum/game_mode/infestation/extended_plus/check_finished()
	if(round_finished)
		return TRUE

	if(world.time < (SSticker.round_start_time + 5 SECONDS))
		return FALSE

	var/list/living_player_list = count_humans_and_xenos(count_flags = COUNT_IGNORE_ALIVE_SSD|COUNT_IGNORE_XENO_SPECIAL_AREA)
	var/num_xenos = living_player_list[2]
	var/num_humans_ship = living_player_list[3]

	if(SSevacuation.dest_status == NUKE_EXPLOSION_FINISHED)
		message_admins("Round finished: [MODE_GENERIC_DRAW_NUKE]") //ship blows, no one wins
		round_finished = MODE_GENERIC_DRAW_NUKE
		return TRUE

	switch(planet_nuked)
		if(INFESTATION_NUKE_COMPLETED)
			message_admins("Round finished: [MODE_INFESTATION_M_MINOR]") //marines managed to nuke the colony
			round_finished = MODE_INFESTATION_M_MINOR
			return TRUE
		if(INFESTATION_NUKE_COMPLETED_SHIPSIDE)
			message_admins("Round finished: [MODE_INFESTATION_X_MAJOR]") //marines managed to nuke their own ship
			round_finished = MODE_INFESTATION_X_MAJOR
			return TRUE
		if(INFESTATION_NUKE_COMPLETED_OTHER)
			message_admins("Round finished: [MODE_INFESTATION_X_MINOR]") //marines managed to nuke transit or something
			round_finished = MODE_INFESTATION_X_MINOR
			return TRUE

	if(!num_xenos)
		if(round_stage == INFESTATION_MARINE_CRASHING)
			message_admins("Round finished: [MODE_INFESTATION_M_MINOR]") //marines lost the ground operation but managed to wipe out Xenos on the ship at a greater cost, minor victory
			round_finished = MODE_INFESTATION_M_MINOR
			return TRUE
	if(round_stage == INFESTATION_MARINE_CRASHING && !num_humans_ship)
		if(SSevacuation.human_escaped > SSevacuation.initial_human_on_ship * 0.5)
			message_admins("Round finished: [MODE_INFESTATION_X_MINOR]") //xenos have control of the ship, but most marines managed to flee
			round_finished = MODE_INFESTATION_X_MINOR
			return
	return FALSE
