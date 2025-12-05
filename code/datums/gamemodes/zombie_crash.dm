/datum/game_mode/infestation/crash/zombie
	name = "Zombie Crash"
	config_tag = "Zombie Crash"
	round_type_flags = NONE
	xeno_abilities_flags = ABILITY_CRASH
	required_players = 1
	valid_job_types = list(
		/datum/job/terragov/squad/standard = -1,
		/datum/job/terragov/squad/engineer = 3,
		/datum/job/terragov/squad/corpsman = 1,
		/datum/job/terragov/squad/smartgunner = 1,
		/datum/job/terragov/squad/leader = 1,
		/datum/job/terragov/medical/professor = 1,
		/datum/job/terragov/silicon/synthetic = 1,
		/datum/job/terragov/command/fieldcommander = 1,
	)
	job_points_needed_by_job_type = list(
		/datum/job/terragov/squad/smartgunner = 20,
		/datum/job/terragov/squad/corpsman = 5,
		/datum/job/terragov/squad/engineer = 5,
	)
	blacklist_ground_maps = list(MAP_BIG_RED, MAP_DELTA_STATION, MAP_LV_624, MAP_WHISKEY_OUTPOST, MAP_OSCAR_OUTPOST, MAP_FORT_PHOBOS, MAP_CHIGUSA, MAP_LAVA_OUTPOST, MAP_CORSAT, MAP_KUTJEVO_REFINERY, MAP_BLUESUMMERS)

/datum/game_mode/infestation/crash/zombie/can_start(bypass_checks = FALSE)
	if((!(config_tag in SSmapping.configs[GROUND_MAP].gamemodes) || (SSmapping.configs[GROUND_MAP].map_name in blacklist_ground_maps)) && !bypass_checks)
		log_world("attempted to start [name] on "+SSmapping.configs[GROUND_MAP].map_name+" which doesn't support it.")
		to_chat(world, "<b>Unable to start [name].</b> [SSmapping.configs[GROUND_MAP].map_name] isn't supported on [name].")
		// start a gamemode vote, in theory this should never happen.
		addtimer(CALLBACK(SSvote, TYPE_PROC_REF(/datum/controller/subsystem/vote, initiate_vote), "gamemode", "SERVER"), 10 SECONDS)
		return FALSE
	if(length(GLOB.ready_players) < required_players && !bypass_checks)
		to_chat(world, "<b>Unable to start [name].</b> Not enough players, [required_players] players needed.")
		return FALSE
	if(!set_valid_job_types() && !bypass_checks)
		return FALSE
	if(!set_valid_squads() && !bypass_checks)
		return FALSE
	return TRUE

/datum/game_mode/infestation/crash/zombie/post_setup()
	. = ..()
	for(var/obj/effect/landmark/corpsespawner/corpse AS in GLOB.corpse_landmarks_list)
		corpse.create_zombie()

	for(var/i in GLOB.zombie_spawner_turfs)
		new /obj/effect/ai_node/spawner/zombie(i)

	for(var/i in GLOB.xeno_resin_silo_turfs)
		new /obj/effect/ai_node/spawner/zombie(i)
	addtimer(CALLBACK(src, PROC_REF(balance_scales)), 1 SECONDS)
	RegisterSignal(SSdcs, COMSIG_GLOB_ZOMBIE_TUNNEL_DESTROYED, PROC_REF(check_finished))

/datum/game_mode/infestation/crash/zombie/on_nuke_started(datum/source, obj/machinery/nuclearbomb/nuke)
	return

///Counts humans and zombies not in valhalla
/datum/game_mode/infestation/crash/zombie/proc/count_humans_and_zombies(list/z_levels = SSmapping.levels_by_any_trait(list(ZTRAIT_MARINE_MAIN_SHIP, ZTRAIT_GROUND, ZTRAIT_RESERVED)), count_flags)
	var/num_humans = 0
	var/num_zombies = 0

	for(var/z in z_levels)
		for(var/mob/living/carbon/human/H  in GLOB.humans_by_zlevel["[z]"])
			if(!istype(H)) // Small fix?
				continue
			if(H.faction == FACTION_ZOMBIE)
				num_zombies++
				continue
			if(count_flags & COUNT_IGNORE_HUMAN_SSD && !H.client && H.afk_status == MOB_DISCONNECTED)
				continue
			if(H.status_flags & XENO_HOST)
				continue
			if(isspaceturf(H.loc))
				continue
			num_humans++
	return list(num_humans, num_zombies)

/datum/game_mode/infestation/crash/zombie/balance_scales()
	if(GLOB.zombie_spawners == 0)
		return

	var/list/living_player_list = count_humans_and_zombies(count_flags = COUNT_IGNORE_HUMAN_SSD)
	var/num_humans = living_player_list[1]
	var/num_zombies = living_player_list[2]
	if(num_zombies * 0.125 >= num_humans) // if there's too much zombies, don't spawn even more
		for(var/obj/effect/ai_node/spawner/zombie/spawner AS in GLOB.zombie_spawners)
			if(!spawner.threat_warning)
				SSspawning.spawnerdata[spawner].max_allowed_mobs = 0
				spawner.maxamount = 0
		return
	for(var/obj/effect/ai_node/spawner/zombie/spawner AS in GLOB.zombie_spawners)
		if(!spawner.threat_warning)
			var/new_spawn_cap = round(num_humans * 8 / length(GLOB.zombie_spawners))
			SSspawning.spawnerdata[spawner].max_allowed_mobs = new_spawn_cap
			spawner.maxamount = new_spawn_cap

/datum/game_mode/infestation/crash/zombie/get_adjusted_jobworth_list(list/jobworth_list)
	return jobworth_list

/datum/game_mode/infestation/crash/zombie/check_finished(force_end)
	if(round_finished)
		return TRUE

	if(!shuttle_landed && !force_end)
		return FALSE

	if(!length(GLOB.zombie_spawners))
		message_admins("Round finished: [MODE_INFESTATION_M_MAJOR]") //marines destroyed all zombie spawners
		round_finished = MODE_INFESTATION_M_MAJOR
		return TRUE

	var/list/living_player_list = count_humans_and_xenos(count_flags = COUNT_IGNORE_HUMAN_SSD| COUNT_GREENOS_TOWARDS_MARINES )
	var/num_humans = living_player_list[1]
	if(num_humans && planet_nuked == INFESTATION_NUKE_NONE && marines_evac == CRASH_EVAC_NONE && !force_end)
		return FALSE

	switch(planet_nuked)
		if(INFESTATION_NUKE_NONE)
			if(!num_humans)
				message_admins("Round finished: [MODE_ZOMBIE_Z_MAJOR]") //zombies wiped out ALL the marines
				round_finished = MODE_ZOMBIE_Z_MAJOR
				return TRUE
			if(marines_evac == CRASH_EVAC_COMPLETED || (!length(GLOB.active_nuke_list) && marines_evac != CRASH_EVAC_NONE))
				message_admins("Round finished: [MODE_ZOMBIE_Z_MINOR]") //marines evaced without a nuke
				round_finished = MODE_ZOMBIE_Z_MINOR
				return TRUE

		if(INFESTATION_NUKE_COMPLETED)
			if(marines_evac == CRASH_EVAC_NONE)
				message_admins("Round finished: [MODE_INFESTATION_M_MINOR]") //marines nuked the planet but didn't evac
				round_finished = MODE_INFESTATION_M_MINOR
				return TRUE
			message_admins("Round finished: [MODE_INFESTATION_M_MAJOR]") //marines nuked the planet and managed to evac
			round_finished = MODE_INFESTATION_M_MAJOR
			return TRUE

		if(INFESTATION_NUKE_COMPLETED_SHIPSIDE, INFESTATION_NUKE_COMPLETED_OTHER)
			message_admins("Round finished: [MODE_GENERIC_DRAW_NUKE]") //marines nuked themselves somehow
			round_finished = MODE_GENERIC_DRAW_NUKE
			return TRUE
	return FALSE

/datum/game_mode/infestation/crash/zombie/announce()
	to_chat(world, span_round_header("The current map is - [SSmapping.configs[GROUND_MAP].map_name]!"))
	priority_announce("Scheduled for landing in T-10 Minutes. Prepare for landing. Phrenetic reports about an unidentified disease rapidly spreading throughout the site were received before it went silent. Your mission is to contain and destroy the source of the contagion by any means necessary, including use of the on-site nuclear device. Bio-warfare protocols active. Detonation Protocol Active, planet disposable. Marines disposable.",
	title = "Mission classification: TOP SECRET",
	type = ANNOUNCEMENT_PRIORITY,
	color_override = "red")
	playsound(shuttle, 'sound/machines/warning-buzzer.ogg', 75, 0, 30)
	balance_scales()

/datum/game_mode/infestation/crash/zombie/end_round_fluff()
	. = ..()
	if(round_finished == MODE_INFESTATION_M_MAJOR  || round_finished == MODE_INFESTATION_M_MINOR || round_finished == MODE_INFESTATION_DRAW_DEATH)
		return

	var/sound/human_track = sound(pick('sound/theme/zombies_loss.ogg', 'sound/theme/sad_loss2.ogg'))
	var/sound/zombie_track = sound(pick('sound/theme/neutral_melancholy1.ogg', 'sound/theme/neutral_melancholy2.ogg'))
	var/sound/ghost_track = zombie_track

	zombie_track.channel = CHANNEL_CINEMATIC
	human_track.channel = CHANNEL_CINEMATIC
	ghost_track.channel = CHANNEL_CINEMATIC

	for(var/mob/hearer AS in GLOB.player_list)
		if(hearer.client?.prefs?.toggles_sound & SOUND_NOENDOFROUND)
			continue
		switch(hearer.faction)
			if(FACTION_ZOMBIE)
				SEND_SOUND(hearer, zombie_track)
			if(FACTION_TERRAGOV)
				SEND_SOUND(hearer, human_track)
			else
				SEND_SOUND(hearer, ghost_track)
