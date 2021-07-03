/datum/game_mode/infestation
	round_end_states = list(MODE_INFESTATION_X_MAJOR, MODE_INFESTATION_M_MAJOR, MODE_INFESTATION_X_MINOR, MODE_INFESTATION_M_MINOR, MODE_INFESTATION_DRAW_DEATH)
	/// If we are shipside or groundside
	var/round_stage = INFESTATION_MARINE_DEPLOYMENT
	/// Timer used to calculate how long till the hive collapse due to no ruler
	var/orphan_hive_timer
	/// Time between two bioscan
	var/bioscan_interval = 15 MINUTES

/datum/game_mode/infestation/post_setup()
	. = ..()
	TIMER_COOLDOWN_START(src, COOLDOWN_BIOSCAN, bioscan_interval)
	for(var/i in GLOB.xeno_weed_node_turfs)
		new /obj/effect/alien/weeds/node(i)
	for(var/turf/T AS in GLOB.xeno_resin_wall_turfs)
		T.ChangeTurf(/turf/closed/wall/resin, T.type)
	for(var/i in GLOB.xeno_resin_door_turfs)
		new /obj/structure/mineral_door/resin(i)

/datum/game_mode/infestation/scale_roles()
	. = ..()
	if(!.)
		return
	var/datum/job/scaled_job = SSjob.GetJobType(/datum/job/terragov/squad/smartgunner)
	scaled_job.job_points_needed  = 20 //For every 10 marine late joins, 1 extra SG

/datum/game_mode/infestation/process()
	if(round_finished)
		return PROCESS_KILL

	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_BIOSCAN) || bioscan_interval == 0)
		return
	announce_bioscans()

// make sure you don't turn 0 into a false positive
#define BIOSCAN_DELTA(count, delta) count ? max(0, count + rand(-delta, delta)) : 0

#define BIOSCAN_LOCATION(show_locations, location) (show_locations && location ? ", including one in [hostLocationP]":"")

///Annonce to everyone the number of xeno and marines on ship and ground
/datum/game_mode/infestation/announce_bioscans(show_locations = TRUE, delta = 2, announce_humans = TRUE, announce_xenos = TRUE, send_fax = TRUE)
	TIMER_COOLDOWN_START(src, COOLDOWN_BIOSCAN, bioscan_interval)
	var/list/list/counts = list()
	var/list/list/area/locations = list()

	for(var/trait in GLOB.bioscan_locations)
		counts[trait] = list(FACTION_TERRAGOV = 0, FACTION_XENO = 0)
		locations[trait] = list(FACTION_TERRAGOV = 0, FACTION_XENO = 0)
		for(var/i in SSmapping.levels_by_trait(trait))
			counts[trait][FACTION_XENO] += length(GLOB.hive_datums[XENO_HIVE_NORMAL].xenos_by_zlevel["[i]"])
			counts[trait][FACTION_TERRAGOV] += length(GLOB.humans_by_zlevel["[i]"])
			if(length(GLOB.hive_datums[XENO_HIVE_NORMAL].xenos_by_zlevel["[i]"]))
				locations[trait][FACTION_XENO] = get_area(pick(GLOB.hive_datums[XENO_HIVE_NORMAL].xenos_by_zlevel["[i]"]))
			if(length(GLOB.humans_by_zlevel["[i]"]))
				locations[trait][FACTION_TERRAGOV] = get_area(pick(GLOB.humans_by_zlevel["[i]"]))

	var/numHostsPlanet	= counts[ZTRAIT_GROUND][FACTION_TERRAGOV]
	var/numHostsShip	= counts[ZTRAIT_MARINE_MAIN_SHIP][FACTION_TERRAGOV]
	var/numHostsTransit	= counts[ZTRAIT_RESERVED][FACTION_TERRAGOV]
	var/numXenosPlanet	= counts[ZTRAIT_GROUND][FACTION_XENO]
	var/numXenosShip	= counts[ZTRAIT_MARINE_MAIN_SHIP][FACTION_XENO]
	var/numXenosTransit	= counts[ZTRAIT_RESERVED][FACTION_XENO]
	var/hostLocationP	= locations[ZTRAIT_GROUND][FACTION_TERRAGOV]
	var/hostLocationS	= locations[ZTRAIT_MARINE_MAIN_SHIP][FACTION_TERRAGOV]
	var/xenoLocationP	= locations[ZTRAIT_GROUND][FACTION_XENO]
	var/xenoLocationS	= locations[ZTRAIT_MARINE_MAIN_SHIP][FACTION_XENO]

	//Adjust the randomness there so everyone gets the same thing
	var/numHostsShipr = BIOSCAN_DELTA(numHostsShip, delta)
	var/numXenosPlanetr = BIOSCAN_DELTA(numXenosPlanet, delta)
	var/numHostsTransitr = BIOSCAN_DELTA(numHostsTransit, delta)
	var/numXenosTransitr = BIOSCAN_DELTA(numXenosTransit, delta)

	var/sound/S = sound(get_sfx("queen"), channel = CHANNEL_ANNOUNCEMENTS, volume = 50)
	if(announce_xenos)
		for(var/i in GLOB.alive_xeno_list)
			var/mob/M = i
			SEND_SOUND(M, S)
			to_chat(M, "<span class='xenoannounce'>The Queen Mother reaches into your mind from worlds away.</span>")
			to_chat(M, "<span class='xenoannounce'>To my children and their Queen. I sense [numHostsShipr ? "approximately [numHostsShipr]":"no"] host[numHostsShipr > 1 ? "s":""] in the metal hive[BIOSCAN_LOCATION(show_locations, hostLocationS)], [numHostsPlanet || "none"] scattered elsewhere[BIOSCAN_LOCATION(show_locations, hostLocationP)] and [numHostsTransitr ? "approximately [numHostsTransitr]":"no"] host[numHostsTransitr > 1 ? "s":""] on the metal bird in transit.</span>")

	var/name = "[MAIN_AI_SYSTEM] Bioscan Status"
	var/input = {"Bioscan complete.

Sensors indicate [numXenosShip || "no"] unknown lifeform signature[numXenosShip > 1 ? "s":""] present on the ship[BIOSCAN_LOCATION(show_locations, xenoLocationS)], [numXenosPlanetr ? "approximately [numXenosPlanetr]":"no"] signature[numXenosPlanetr > 1 ? "s":""] located elsewhere[BIOSCAN_LOCATION(show_locations, xenoLocationP)] and [numXenosTransit || "no"] unknown lifeform signature[numXenosTransit > 1 ? "s":""] in transit."}

	if(announce_humans)
		priority_announce(input, name, sound = 'sound/AI/bioscan.ogg')

	if(send_fax)
		var/fax_message = generate_templated_fax("Combat Information Center", "[MAIN_AI_SYSTEM] Bioscan Status", "", input, "", MAIN_AI_SYSTEM)
		send_fax(null, null, "Combat Information Center", "[MAIN_AI_SYSTEM] Bioscan Status", fax_message, FALSE)

	log_game("Bioscan. Humans: [numHostsPlanet] on the planet[hostLocationP ? " Location:[hostLocationP]":""] and [numHostsShip] on the ship.[hostLocationS ? " Location: [hostLocationS].":""] Xenos: [numXenosPlanetr] on the planet and [numXenosShip] on the ship[xenoLocationP ? " Location:[xenoLocationP]":""] and [numXenosTransit] in transit.")

	for(var/i in GLOB.observer_list)
		var/mob/M = i
		to_chat(M, "<h2 class='alert'>Detailed Information</h2>")
		to_chat(M, {"<span class='alert'>[numXenosPlanet] xeno\s on the planet.
[numXenosShip] xeno\s on the ship.
[numHostsPlanet] human\s on the planet.
[numHostsShip] human\s on the ship.
[numHostsTransit] human\s in transit.
[numXenosTransit] xeno\s in transit.</span>"})

	message_admins("Bioscan - Humans: [numHostsPlanet] on the planet[hostLocationP ? ". Location:[hostLocationP]":""]. [numHostsShipr] on the ship.[hostLocationS ? " Location: [hostLocationS].":""]. [numHostsTransitr] in transit.")
	message_admins("Bioscan - Xenos: [numXenosPlanetr] on the planet[numXenosPlanetr > 0 && xenoLocationP ? ". Location:[xenoLocationP]":""]. [numXenosShip] on the ship.[xenoLocationS ? " Location: [xenoLocationS].":""] [numXenosTransitr] in transit.")

#undef BIOSCAN_DELTA
#undef BIOSCAN_LOCATION

/datum/game_mode/infestation/check_finished()
	if(round_finished)
		return TRUE

	if(world.time < (SSticker.round_start_time + 5 SECONDS))
		return FALSE

	var/living_player_list[] = count_humans_and_xenos(count_flags = COUNT_IGNORE_ALIVE_SSD|COUNT_IGNORE_XENO_SPECIAL_AREA)
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
			message_admins("Round finished: [MODE_INFESTATION_X_MINOR]") //marines lost the ground operation but managed to wipe out Xenos on the ship at a greater cost, minor victory
			round_finished = MODE_INFESTATION_M_MINOR
			return TRUE
		message_admins("Round finished: [MODE_INFESTATION_M_MAJOR]") //marines win big
		round_finished = MODE_INFESTATION_M_MAJOR
		return TRUE
	if(round_stage == INFESTATION_MARINE_CRASHING && !num_humans_ship)
		message_admins("Round finished: [MODE_INFESTATION_X_MAJOR]") //xenos wiped our marines, xeno major victory
		round_finished = MODE_INFESTATION_X_MAJOR
		return TRUE
	return FALSE

/datum/game_mode/infestation/declare_completion()
	. = ..()
	to_chat(world, "<span class='round_header'>|[round_finished]|</span>")
	to_chat(world, "<span class='round_body'>Thus ends the story of the brave men and women of the [SSmapping.configs[SHIP_MAP].map_name] and their struggle on [SSmapping.configs[GROUND_MAP].map_name].</span>")
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

	for(var/i in GLOB.xeno_mob_list)
		var/mob/M = i
		SEND_SOUND(M, xeno_track)

	for(var/i in GLOB.human_mob_list)
		var/mob/M = i
		SEND_SOUND(M, human_track)

	for(var/i in GLOB.observer_list)
		var/mob/M = i
		if(ishuman(M.mind.current))
			SEND_SOUND(M, human_track)
			continue

		if(isxeno(M.mind.current))
			SEND_SOUND(M, xeno_track)
			continue

		SEND_SOUND(M, ghost_track)

	log_game("[round_finished]\nGame mode: [name]\nRound time: [duration2text()]\nEnd round player population: [length(GLOB.clients)]\nTotal xenos spawned: [GLOB.round_statistics.total_xenos_created]\nTotal humans spawned: [GLOB.round_statistics.total_humans_created]")

	announce_xenomorphs()
	announce_medal_awards()
	announce_round_stats()

/// Announce to players the name of the surviving hive ruler
/datum/game_mode/infestation/proc/announce_xenomorphs()
	var/datum/hive_status/normal/HN = GLOB.hive_datums[XENO_HIVE_NORMAL]
	if(!HN.living_xeno_ruler)
		return

	var/dat = "<span class='round_body'>The surviving xenomorph ruler was:<br>[HN.living_xeno_ruler.key] as <span class='boldnotice'>[HN.living_xeno_ruler]</span></span>"

	to_chat(world, dat)

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
	addtimer(CALLBACK(SSticker.mode, .proc/map_announce), 5 SECONDS)

///Announce the next map
/datum/game_mode/infestation/proc/map_announce()
	if(!SSmapping.configs[GROUND_MAP].announce_text)
		return

	priority_announce(SSmapping.configs[GROUND_MAP].announce_text, SSmapping.configs[SHIP_MAP].map_name)


/datum/game_mode/infestation/announce()
	to_chat(world, "<span class='round_header'>The current map is - [SSmapping.configs[GROUND_MAP].map_name]!</span>")

/datum/game_mode/infestation/attempt_to_join_as_larva(mob/dead/observer/observer)
	var/datum/hive_status/normal/HS = GLOB.hive_datums[XENO_HIVE_NORMAL]
	return HS.add_to_larva_candidate_queue(observer)


/datum/game_mode/infestation/spawn_larva(mob/xeno_candidate, mob/living/carbon/xenomorph/mother)
	var/datum/hive_status/normal/HS = GLOB.hive_datums[XENO_HIVE_NORMAL]
	return HS.spawn_larva(xeno_candidate, mother)
