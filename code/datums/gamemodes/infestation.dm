/datum/game_mode/infestation
	round_end_states = list(MODE_INFESTATION_X_MAJOR, MODE_INFESTATION_M_MAJOR, MODE_INFESTATION_X_MINOR, MODE_INFESTATION_M_MINOR, MODE_INFESTATION_DRAW_DEATH)
	job_points_needed_by_job_type = list(
		/datum/job/terragov/squad/smartgunner = 20,
		/datum/job/terragov/squad/corpsman = 10,
		/datum/job/terragov/squad/engineer = 10,
	)
	/// If we are shipside or groundside
	var/round_stage = INFESTATION_MARINE_DEPLOYMENT
	/// Timer used to calculate how long till the hive collapse due to no ruler
	var/orphan_hive_timer
	/// Time between two bioscan
	var/bioscan_interval = 15 MINUTES
	/// State of the nuke
	var/planet_nuked = INFESTATION_NUKE_NONE
	/**
	 * Assoc list showing how many xenos are needed by caste.
	 * [caste datum] = [amount of xenos needed]
	 */
	var/list/evo_requirements = list(
		/datum/xeno_caste/queen = 8,
	)

/datum/game_mode/infestation/post_setup()
	. = ..()
	if(bioscan_interval)
		TIMER_COOLDOWN_START(src, COOLDOWN_BIOSCAN, bioscan_interval)
	var/weed_type
	for(var/turf/T in GLOB.xeno_weed_node_turfs)
		weed_type = pickweight(GLOB.weed_prob_list)
		new weed_type(T)
	for(var/turf/T AS in GLOB.xeno_resin_wall_turfs)
		T.ChangeTurf(/turf/closed/wall/resin/regenerating, T.type)
	for(var/i in GLOB.xeno_resin_door_turfs)
		new /obj/structure/mineral_door/resin(i)
	for(var/i in GLOB.xeno_tunnel_spawn_turfs)
		var/obj/structure/xeno/tunnel/new_tunnel = new /obj/structure/xeno/tunnel(i, XENO_HIVE_NORMAL)
		new_tunnel.name = "[get_area_name(new_tunnel)] tunnel"
		new_tunnel.tunnel_desc = "["[get_area_name(new_tunnel)]"] (X: [new_tunnel.x], Y: [new_tunnel.y])"
	for(var/i in GLOB.xeno_jelly_pod_turfs)
		new /obj/structure/xeno/resin_jelly_pod(i, XENO_HIVE_NORMAL)

	// Apply Evolution Xeno Population Locks:
	for(var/datum/xeno_caste/caste AS in evo_requirements)
		GLOB.xeno_caste_datums[caste][XENO_UPGRADE_BASETYPE].evolve_min_xenos = evo_requirements[caste]

/datum/game_mode/infestation/process()
	if(round_finished)
		return PROCESS_KILL

	if(TIMER_COOLDOWN_RUNNING(src, COOLDOWN_BIOSCAN) || bioscan_interval == 0)
		return
	announce_bioscans(GLOB.current_orbit)

// make sure you don't turn 0 into a false positive
#define BIOSCAN_DELTA(count, delta) count ? max(0, count + rand(-delta, delta)) : 0

#define BIOSCAN_LOCATION(show_locations, location) ((show_locations && location) ? ", including one in [location]" : "")

#define AI_SCAN_DELAY 15 SECONDS

///Annonce to everyone the number of xeno and marines on ship and ground
/datum/game_mode/infestation/announce_bioscans(show_locations = TRUE, delta = 2, ai_operator = FALSE, announce_humans = TRUE, announce_xenos = TRUE, send_fax = TRUE)

	if(ai_operator)
		#ifndef TESTING
		var/mob/living/silicon/ai/bioscanning_ai = usr
		if((bioscanning_ai.last_ai_bioscan + COOLDOWN_AI_BIOSCAN) > world.time)
			to_chat(bioscanning_ai, "Bioscan instruments are still recalibrating from their last use.")
			return
		bioscanning_ai.last_ai_bioscan = world.time
		to_chat(bioscanning_ai, span_warning("Scanning for hostile lifeforms..."))
		if(!do_after(usr, AI_SCAN_DELAY, NONE, usr, BUSY_ICON_GENERIC)) //initial windup time until firing begins
			bioscanning_ai.last_ai_bioscan = 0
			return

		#endif

	else
		TIMER_COOLDOWN_START(src, COOLDOWN_BIOSCAN, bioscan_interval)
	var/list/list/counts = list()
	var/list/list/area/locations = list()

	for(var/trait in GLOB.bioscan_locations)
		counts[trait] = list(FACTION_TERRAGOV = 0, FACTION_XENO = 0)
		locations[trait] = list(FACTION_TERRAGOV = 0, FACTION_XENO = 0)
		for(var/i in SSmapping.levels_by_trait(trait))
			var/list/parsed_xenos = GLOB.hive_datums[XENO_HIVE_NORMAL].xenos_by_zlevel["[i]"]?.Copy()
			for(var/mob/living/carbon/xenomorph/xeno in parsed_xenos)
				if(xeno.xeno_caste.caste_flags & CASTE_NOT_IN_BIOSCAN)
					parsed_xenos -= xeno
			counts[trait][FACTION_XENO] += length(parsed_xenos)
			counts[trait][FACTION_TERRAGOV] += length(GLOB.humans_by_zlevel["[i]"])
			if(length(GLOB.hive_datums[XENO_HIVE_NORMAL].xenos_by_zlevel["[i]"]))
				locations[trait][FACTION_XENO] = get_area(pick(GLOB.hive_datums[XENO_HIVE_NORMAL].xenos_by_zlevel["[i]"]))
			if(length(GLOB.humans_by_zlevel["[i]"]))
				locations[trait][FACTION_TERRAGOV] = get_area(pick(GLOB.humans_by_zlevel["[i]"]))

	var/numHostsPlanet = counts[ZTRAIT_GROUND][FACTION_TERRAGOV]
	var/numHostsShip = counts[ZTRAIT_MARINE_MAIN_SHIP][FACTION_TERRAGOV]
	var/numHostsTransit = counts[ZTRAIT_RESERVED][FACTION_TERRAGOV]
	var/numXenosPlanet = counts[ZTRAIT_GROUND][FACTION_XENO]
	var/numXenosShip = counts[ZTRAIT_MARINE_MAIN_SHIP][FACTION_XENO]
	var/numXenosTransit = counts[ZTRAIT_RESERVED][FACTION_XENO]
	var/host_location_planetside = locations[ZTRAIT_GROUND][FACTION_TERRAGOV]
	var/host_location_shipside = locations[ZTRAIT_MARINE_MAIN_SHIP][FACTION_TERRAGOV]
	var/xeno_location_planetside = locations[ZTRAIT_GROUND][FACTION_XENO]
	var/xeno_location_shipside = locations[ZTRAIT_MARINE_MAIN_SHIP][FACTION_XENO]

	//Adjust the randomness there so everyone gets the same thing
	var/hosts_shipside = BIOSCAN_DELTA(numHostsShip, delta)
	var/xenos_planetside = BIOSCAN_DELTA(numXenosPlanet, delta)
	var/hosts_transit = BIOSCAN_DELTA(numHostsTransit, delta)
	var/xenos_transit = BIOSCAN_DELTA(numXenosTransit, delta)

	var/sound/sound = sound(get_sfx(SFX_QUEEN), channel = CHANNEL_ANNOUNCEMENTS, volume = 50)
	if(announce_xenos)
		for(var/mob/hearer in GLOB.alive_xeno_list_hive[XENO_HIVE_NORMAL])
			SEND_SOUND(hearer, sound)
			to_chat(hearer, assemble_alert(
				title = "Queen Mother Report",
				subtitle = "The Queen Mother reaches into your mind...",

				message = "To my children and their Queen,<br>I sense [hosts_shipside ? "approximately [hosts_shipside]":"no"] \
				host[hosts_shipside > 1 ? "s":""] in the metal hive[BIOSCAN_LOCATION(show_locations, host_location_shipside)], \
				[numHostsPlanet || "none"] scattered elsewhere[BIOSCAN_LOCATION(show_locations, host_location_planetside)] and \
				[hosts_transit ? "approximately [hosts_transit]":"no"] host[hosts_transit > 1 ? "s":""] on the metal bird in transit.",

				color_override = "purple"
			))

	var/name = "[MAIN_AI_SYSTEM] Bioscan Status"

	var/input = {"Bioscan complete. Sensors indicate [numXenosShip || "no"] unknown lifeform signature[numXenosShip > 1 ? "s":""] \
	present on the ship[BIOSCAN_LOCATION(show_locations, xeno_location_shipside)], [xenos_planetside ? "approximately [xenos_planetside]":"no"] \
	signature[xenos_planetside > 1 ? "s":""] located elsewhere[BIOSCAN_LOCATION(show_locations, xeno_location_planetside)] and [numXenosTransit || "no"] \
	unknown lifeform signature[numXenosTransit > 1 ? "s":""] in transit."}

	var/ai_name = "[usr] Bioscan Status"

	if(ai_operator)
		priority_announce(input, ai_name, sound = 'sound/AI/bioscan.ogg', color_override = "grey", receivers = (GLOB.alive_human_list + GLOB.ai_list))
		log_game("Bioscan. Humans: [numHostsPlanet] on the planet\
		[host_location_planetside ? " Location:[host_location_planetside]":""] and [numHostsShip] on the ship.\
		[host_location_shipside ? " Location: [host_location_shipside].":""] \
		Xenos: [xenos_planetside] on the planet and [numXenosShip] on the ship\
		[xeno_location_planetside ? " Location:[xeno_location_planetside]":""] and [numXenosTransit] in transit.")

		switch(GLOB.current_orbit)
			if(1)
				to_chat(usr, span_warning("Signal analysis reveals excellent detail about hostile movements and numbers."))
				return
			if(3)
				to_chat(usr, span_warning("Minor corruption detected in our bioscan instruments due to ship elevation, some information about hostile activity may be incorrect."))
				return
			if(5)
				to_chat(usr, span_warning("Major corruption detected in our bioscan readings due to ship elevation, information heavily corrupted."))
		return

	if(announce_humans)
		priority_announce(input, name, sound = 'sound/AI/bioscan.ogg', color_override = "grey", receivers = (GLOB.alive_human_list + GLOB.ai_list)) // Hide this from observers, they have their own detailed alert.

	if(send_fax)
		var/fax_message = generate_templated_fax("Combat Information Center", "[MAIN_AI_SYSTEM] Bioscan Status", "", input, "", MAIN_AI_SYSTEM)
		send_fax(null, null, "Combat Information Center", "[MAIN_AI_SYSTEM] Bioscan Status", fax_message, FALSE)

	log_game("Bioscan. Humans: [numHostsPlanet] on the planet[host_location_planetside ? " Location:[host_location_planetside]":""] and [numHostsShip] on the ship.[host_location_shipside ? " Location: [host_location_shipside].":""] Xenos: [xenos_planetside] on the planet and [numXenosShip] on the ship[xeno_location_planetside ? " Location:[xeno_location_planetside]":""] and [numXenosTransit] in transit.")

	for(var/mob/hearer in GLOB.observer_list)
		to_chat(hearer, assemble_alert(
			title = "Detailed Bioscan",
			message = {"[numXenosPlanet] xeno\s on the planet.
[numXenosShip] xeno\s on the ship.
[numXenosTransit] xeno\s in transit.

[numHostsPlanet] human\s on the planet.
[numHostsShip] human\s on the ship.
[numHostsTransit] human\s in transit."},
			color_override = "purple"
		))

	message_admins("Bioscan - Humans: [numHostsPlanet] on the planet[host_location_planetside ? ". Location:[host_location_planetside]":""]. [hosts_shipside] on the ship.[host_location_shipside ? " Location: [host_location_shipside].":""]. [hosts_transit] in transit.")
	message_admins("Bioscan - Xenos: [xenos_planetside] on the planet[xenos_planetside > 0 && xeno_location_planetside ? ". Location:[xeno_location_planetside]":""]. [numXenosShip] on the ship.[xeno_location_shipside ? " Location: [xeno_location_shipside].":""] [xenos_transit] in transit.")

#undef BIOSCAN_DELTA
#undef BIOSCAN_LOCATION
#undef AI_SCAN_DELAY

/datum/game_mode/infestation/check_finished()
	if(round_finished)
		return TRUE

	if(world.time < (SSticker.round_start_time + 5 SECONDS))
		return FALSE

	var/list/living_player_list = count_humans_and_xenos(count_flags = COUNT_IGNORE_ALIVE_SSD|COUNT_IGNORE_XENO_SPECIAL_AREA)
	var/num_humans = living_player_list[1]
	var/num_xenos = living_player_list[2]
	var/num_humans_ship = living_player_list[3]

	if(SSevacuation.dest_status == NUKE_EXPLOSION_FINISHED)
		message_admins("Round finished: [MODE_GENERIC_DRAW_NUKE]") //ship blows, no one wins
		round_finished = MODE_GENERIC_DRAW_NUKE
		return TRUE

	if(round_stage == INFESTATION_DROPSHIP_CAPTURED_XENOS)
		message_admins("Round finished: [MODE_INFESTATION_X_MINOR]")
		round_finished = MODE_INFESTATION_X_MINOR
		return TRUE

	if(!num_humans)
		if(!num_xenos)
			message_admins("Round finished: [MODE_INFESTATION_DRAW_DEATH]") //everyone died at the same time, no one wins
			round_finished = MODE_INFESTATION_DRAW_DEATH
			return TRUE
		message_admins("Round finished: [MODE_INFESTATION_X_MAJOR]") //xenos wiped out ALL the marines without hijacking, xeno major victory
		round_finished = MODE_INFESTATION_X_MAJOR
		return TRUE
	if(!num_xenos)
		if(round_stage == INFESTATION_MARINE_CRASHING)
			message_admins("Round finished: [MODE_INFESTATION_M_MINOR]") //marines lost the ground operation but managed to wipe out Xenos on the ship at a greater cost, minor victory
			round_finished = MODE_INFESTATION_M_MINOR
			return TRUE
		message_admins("Round finished: [MODE_INFESTATION_M_MAJOR]") //marines win big
		round_finished = MODE_INFESTATION_M_MAJOR
		return TRUE
	if(round_stage == INFESTATION_MARINE_CRASHING && !num_humans_ship)
		if(SSevacuation.human_escaped > SSevacuation.initial_human_on_ship * 0.5)
			message_admins("Round finished: [MODE_INFESTATION_X_MINOR]") //xenos have control of the ship, but most marines managed to flee
			round_finished = MODE_INFESTATION_X_MINOR
			return
		message_admins("Round finished: [MODE_INFESTATION_X_MAJOR]") //xenos wiped our marines, xeno major victory
		round_finished = MODE_INFESTATION_X_MAJOR
		return TRUE
	return FALSE


/datum/game_mode/infestation/declare_completion()
	. = ..()
	log_game("[round_finished]\nGame mode: [name]\nRound time: [duration2text()]\nEnd round player population: [length(GLOB.clients)]\nTotal xenos spawned: [GLOB.round_statistics.total_xenos_created]\nTotal humans spawned: [GLOB.round_statistics.total_humans_created]")

/datum/game_mode/infestation/end_round_fluff()
	send_ooc_announcement(
		sender_override = "Round Concluded",
		title = round_finished,
		text = "Thus ends the story of the brave men and women of the TerraGov Marine Corps, and their struggle on [SSmapping.configs[GROUND_MAP].map_name]...",
		play_sound = FALSE,
		style = OOC_ALERT_GAME
	)

	var/sound/xeno_track
	var/sound/human_track
	var/sound/ghost_track
	switch(round_finished)
		if(MODE_INFESTATION_X_MAJOR)
			xeno_track = pick('sound/theme/winning_triumph1.ogg', 'sound/theme/winning_triumph2.ogg')
			human_track = pick('sound/theme/sad_loss1.ogg', 'sound/theme/sad_loss2.ogg')
			ghost_track = xeno_track
		if(MODE_INFESTATION_M_MAJOR)
			xeno_track = pick('sound/theme/sad_loss1.ogg', 'sound/theme/sad_loss2.ogg')
			human_track = pick('sound/theme/winning_triumph1.ogg', 'sound/theme/winning_triumph2.ogg')
			ghost_track = human_track
		if(MODE_INFESTATION_X_MINOR)
			xeno_track = pick('sound/theme/neutral_hopeful1.ogg', 'sound/theme/neutral_hopeful2.ogg')
			human_track = pick('sound/theme/neutral_melancholy1.ogg', 'sound/theme/neutral_melancholy2.ogg')
			ghost_track = xeno_track
		if(MODE_INFESTATION_M_MINOR)
			xeno_track = pick('sound/theme/neutral_melancholy1.ogg', 'sound/theme/neutral_melancholy2.ogg')
			human_track = pick('sound/theme/neutral_hopeful1.ogg', 'sound/theme/neutral_hopeful2.ogg')
			ghost_track = human_track
		if(MODE_INFESTATION_DRAW_DEATH)
			ghost_track = pick('sound/theme/nuclear_detonation1.ogg', 'sound/theme/nuclear_detonation2.ogg')
			xeno_track = ghost_track
			human_track = ghost_track

	xeno_track = sound(xeno_track)
	xeno_track.channel = CHANNEL_CINEMATIC
	human_track = sound(human_track)
	human_track.channel = CHANNEL_CINEMATIC
	ghost_track = sound(ghost_track)
	ghost_track.channel = CHANNEL_CINEMATIC

	for(var/mob/hearer in GLOB.xeno_mob_list)
		if(hearer.client?.prefs?.toggles_sound & SOUND_NOENDOFROUND)
			continue
		SEND_SOUND(hearer, xeno_track)

	for(var/mob/hearer in GLOB.human_mob_list)
		if(hearer.client?.prefs?.toggles_sound & SOUND_NOENDOFROUND)
			continue
		SEND_SOUND(hearer, human_track)

	for(var/mob/hearer in GLOB.observer_list)
		if(hearer.client?.prefs?.toggles_sound & SOUND_NOENDOFROUND)
			continue
		if(ishuman(hearer.mind.current))
			SEND_SOUND(hearer, human_track)
			continue

		if(isxeno(hearer.mind.current))
			SEND_SOUND(hearer, xeno_track)
			continue

		SEND_SOUND(hearer, ghost_track)

/datum/game_mode/infestation/can_start(bypass_checks = FALSE)
	. = ..()
	if(!.)
		return
	var/xeno_candidate = FALSE //Let's guarantee there's at least one xeno.
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
		to_chat(world, "<b>Unable to start [name].</b> No xeno candidate found.")
		return FALSE

/datum/game_mode/infestation/pre_setup()
	. = ..()
	addtimer(CALLBACK(SSticker.mode, PROC_REF(map_announce)), 5 SECONDS)

///Announce the next map
/datum/game_mode/infestation/proc/map_announce()
	if(!SSmapping.configs[GROUND_MAP].announce_text)
		return

	priority_announce(
		title = "High Command Update",
		subtitle = "Good morning, marines.",
		message = "Cryosleep disengaged by TGMC High Command.<br><br>ATTN: [SSmapping.configs[SHIP_MAP].map_name].<br>[SSmapping.configs[GROUND_MAP].announce_text]",
		sound = 'sound/AI/ares_online.ogg',
		color_override = "red"
	)


/datum/game_mode/infestation/announce()
	to_chat(world, span_round_header("The current map is - [SSmapping.configs[GROUND_MAP].map_name]!"))

/datum/game_mode/infestation/attempt_to_join_as_larva(client/waiter)
	var/datum/hive_status/normal/HS = GLOB.hive_datums[XENO_HIVE_NORMAL]
	return HS.add_to_larva_candidate_queue(waiter)


/datum/game_mode/infestation/spawn_larva(mob/xeno_candidate, mob/living/carbon/xenomorph/mother)
	var/datum/hive_status/normal/HS = GLOB.hive_datums[XENO_HIVE_NORMAL]
	return HS.spawn_larva(xeno_candidate, mother)

/datum/game_mode/infestation/proc/on_nuclear_diffuse(obj/machinery/nuclearbomb/bomb, mob/living/carbon/xenomorph/X)
	SIGNAL_HANDLER
	priority_announce("WARNING. WARNING. Planetary Nuke deactivated. WARNING. WARNING. Self destruct failed. WARNING. WARNING.", "Planetary Warhead Disengaged", type = ANNOUNCEMENT_PRIORITY)

/datum/game_mode/infestation/proc/on_nuclear_explosion(datum/source, z_level)
	SIGNAL_HANDLER
	planet_nuked = INFESTATION_NUKE_INPROGRESS
	INVOKE_ASYNC(src, PROC_REF(play_cinematic), z_level)

/datum/game_mode/infestation/proc/on_nuke_started(datum/source, obj/machinery/nuclearbomb/nuke)
	SIGNAL_HANDLER
	var/datum/hive_status/normal/HS = GLOB.hive_datums[XENO_HIVE_NORMAL]
	var/area_name = get_area_name(nuke)
	HS.xeno_message("An overwhelming wave of dread ripples throughout the hive... A nuke has been activated[area_name ? " in [area_name]":""]!")
	HS.set_all_xeno_trackers(nuke)

/datum/game_mode/infestation/proc/play_cinematic(z_level)
	GLOB.enter_allowed = FALSE
	priority_announce("DANGER. DANGER. Planetary Nuke Activated. DANGER. DANGER. Self destruct in progress. DANGER. DANGER.", "Planetary Warhead Detonation Confirmed", type = ANNOUNCEMENT_PRIORITY)
	var/sound/S = sound(pick('sound/theme/nuclear_detonation1.ogg','sound/theme/nuclear_detonation2.ogg'), channel = CHANNEL_CINEMATIC)
	SEND_SOUND(world, S)

	for(var/mob/seer in GLOB.player_list)
		if(isobserver(seer) || isnewplayer(seer))
			continue
		if(seer.z == z_level)
			shake_camera(seer, 110, 4)

	var/datum/cinematic/crash_nuke/nuke = /datum/cinematic/crash_nuke
	var/nuketime = initial(nuke.runtime) + initial(nuke.cleanup_time)
	addtimer(CALLBACK(src, PROC_REF(do_nuke_z_level), z_level), nuketime * 0.5)

	Cinematic(CINEMATIC_CRASH_NUKE, world)

/datum/game_mode/infestation/proc/do_nuke_z_level(z_level)
	if(!z_level)
		return

	if(SSmapping.level_trait(z_level, ZTRAIT_GROUND))
		planet_nuked = INFESTATION_NUKE_COMPLETED
	else if(SSmapping.level_trait(z_level, ZTRAIT_MARINE_MAIN_SHIP))
		planet_nuked = INFESTATION_NUKE_COMPLETED_SHIPSIDE
	else
		planet_nuked = INFESTATION_NUKE_COMPLETED_OTHER

	for(var/mob/living/victim in GLOB.alive_living_list)
		var/turf/victim_turf = get_turf(victim) //Sneaky people on lockers.
		if(QDELETED(victim_turf) || victim_turf.z != z_level)
			continue
		victim.adjustFireLoss(victim.maxHealth * 4)
		victim.death()
		CHECK_TICK
