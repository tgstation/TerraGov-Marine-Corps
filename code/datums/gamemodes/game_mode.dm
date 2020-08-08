/datum/game_mode
	var/name = ""
	var/config_tag = null
	var/votable = TRUE
	var/probability = 0
	var/required_players = 0
	var/squads_max_number = 4

	var/round_finished
	var/list/round_end_states = list()
	var/list/valid_job_types = list()

	var/round_time_fog
	var/flags_round_type = NONE
	var/flags_landmarks = NONE

	var/distress_cancelled = FALSE

	var/deploy_time_lock = 15 MINUTES

//Distress call variables.
	var/list/datum/emergency_call/all_calls = list() //initialized at round start and stores the datums.
	var/datum/emergency_call/picked_call = null //Which distress call is currently active
	var/on_distress_cooldown = FALSE
	var/waiting_for_candidates = FALSE


/datum/game_mode/New()
	initialize_emergency_calls()


/datum/game_mode/proc/announce()
	return TRUE


/datum/game_mode/proc/can_start(bypass_checks = FALSE)
	if(!(config_tag in SSmapping.configs[GROUND_MAP].gamemodes) && !bypass_checks)
		log_world("attempted to start [src.type] on "+SSmapping.configs[GROUND_MAP].map_name+" which doesn't support it.")
		// start a gamemode vote, in theory this should never happen.
		addtimer(CALLBACK(SSvote, /datum/controller/subsystem/vote.proc/initiate_vote, "gamemode", "SERVER"), 10 SECONDS)
		return FALSE
	if(length(GLOB.ready_players) < required_players && !bypass_checks)
		to_chat(world, "<b>Unable to start [name].</b> Not enough players, [required_players] players needed.")
		return FALSE
	if(!set_valid_job_types() && !bypass_checks)
		return FALSE
	if(!set_valid_squads() && !bypass_checks)
		return FALSE
	return TRUE


/datum/game_mode/proc/pre_setup()
	if(flags_landmarks & MODE_LANDMARK_SPAWN_XENO_TUNNELS)
		setup_xeno_tunnels()

	if(flags_landmarks & MODE_LANDMARK_SPAWN_MAP_ITEM)
		spawn_map_items()

	setup_blockers()
	GLOB.balance.Initialize()

	GLOB.landmarks_round_start = shuffle(GLOB.landmarks_round_start)
	var/obj/effect/landmark/L
	while(GLOB.landmarks_round_start.len)
		L = GLOB.landmarks_round_start[GLOB.landmarks_round_start.len]
		GLOB.landmarks_round_start.len--
		L.after_round_start()

	return TRUE

/datum/game_mode/proc/setup()
	SSjob.DivideOccupations()
	create_characters()
	reset_squads()
	spawn_characters()
	transfer_characters()
	return TRUE


/datum/game_mode/proc/post_setup()
	addtimer(CALLBACK(src, .proc/display_roundstart_logout_report), ROUNDSTART_LOGOUT_REPORT_TIME)
	if(!SSdbcore.Connect())
		return
	var/sql
	if(SSticker.mode)
		sql += "game_mode = '[SSticker.mode]'"
	if(GLOB.revdata.originmastercommit)
		if(sql)
			sql += ", "
		sql += "commit_hash = '[GLOB.revdata.originmastercommit]'"
	if(sql)
		var/datum/DBQuery/query_round_game_mode = SSdbcore.NewQuery("UPDATE [format_table_name("round")] SET [sql] WHERE id = [GLOB.round_id]")
		query_round_game_mode.Execute()
		qdel(query_round_game_mode)

/datum/game_mode/proc/new_player_topic(mob/new_player/NP, href, list/href_list)
	return FALSE


/datum/game_mode/process()
	return TRUE


/datum/game_mode/proc/create_characters()
	for(var/i in GLOB.new_player_list)
		var/mob/new_player/player = i
		if(player.ready)
			player.create_character()
		else
			player.new_player_panel()
		CHECK_TICK


/datum/game_mode/proc/spawn_characters()
	for(var/i in GLOB.new_player_list)
		var/mob/new_player/player = i
		if(!player.assigned_role)
			continue
		SSjob.spawn_character(player)
		CHECK_TICK


/datum/game_mode/proc/transfer_characters()
	var/list/livings = list()
	for(var/i in GLOB.new_player_list)
		var/mob/new_player/player = i
		var/mob/living = player.transfer_character()
		if(!living)
			continue

		qdel(player)
		living.notransform = TRUE
		livings += living

	if(length(livings))
		addtimer(CALLBACK(src, .proc/release_characters, livings), 1 SECONDS, TIMER_CLIENT_TIME)


/datum/game_mode/proc/release_characters(list/livings)
	for(var/I in livings)
		var/mob/living/L = I
		L.notransform = FALSE


/datum/game_mode/proc/check_finished()
	if(SSevacuation.dest_status == NUKE_EXPLOSION_FINISHED)
		return TRUE


/datum/game_mode/proc/declare_completion()
	log_game("The round has ended.")
	SSdbcore.SetRoundEnd()
	end_of_round_deathmatch()
	return TRUE


/datum/game_mode/proc/display_roundstart_logout_report()
	var/msg = "<hr><span class='notice'><b>Roundstart logout report</b></span><br>"
	for(var/mob/living/L in GLOB.mob_living_list)
		if(L.ckey && L.client)
			continue

		else if(L.ckey)
			msg += "<b>[ADMIN_TPMONTY(L)]</b> the [L.job.title] (<b>Disconnected</b>)<br>"

		else if(L.client)
			if(L.client.inactivity >= (ROUNDSTART_LOGOUT_REPORT_TIME / 2))
				msg += "<b>[ADMIN_TPMONTY(L)]</b> the [L.job.title] (<b>Connected, Inactive</b>)<br>"
			else if(L.stat)
				if(L.suiciding)
					msg += "<b>[ADMIN_TPMONTY(L)]</b> the [L.job.title] (<b>Suicide</b>)<br>"
				else if(L.stat == UNCONSCIOUS)
					msg += "<b>[ADMIN_TPMONTY(L)]</b> the [L.job.title] (Dying)<br>"
				else if(L.stat == DEAD)
					msg += "<b>[ADMIN_TPMONTY(L)]</b> the [L.job.title] (Dead)<br>"

	for(var/mob/dead/observer/D in GLOB.dead_mob_list)
		if(!isliving(D.mind?.current))
			continue
		var/mob/living/L = D.mind.current
		if(L.stat == DEAD)
			if(L.suiciding)
				msg += "<b>[ADMIN_TPMONTY(L)]</b> the [L.job.title] (<b>Suicide</b>)<br>"
			else
				msg += "<b>[ADMIN_TPMONTY(L)]</b> the [L.job.title] (Dead)<br>"
		else if(!D.can_reenter_corpse)
			msg += "<b>[ADMIN_TPMONTY(L)]</b> the [L.job.title] (<b>Ghosted</b>)<br>"


	msg += "<hr>"

	for(var/i in GLOB.clients)
		var/client/C = i
		if(!check_other_rights(C, R_ADMIN, FALSE))
			continue
		to_chat(C, msg)


/datum/game_mode/proc/spawn_map_items()
	return

GLOBAL_LIST_INIT(bioscan_locations, list(
	ZTRAIT_MARINE_MAIN_SHIP,
	ZTRAIT_GROUND,
	ZTRAIT_RESERVED,
))

// make sure you don't turn 0 into a false positive
#define BIOSCAN_DELTA(count, delta) count ? max(0, count + rand(-delta, delta)) : 0

#define BIOSCAN_LOCATION(show_locations, location) (show_locations && location ? ", including one in [hostLocationP]":"")

/datum/game_mode/proc/announce_bioscans(show_locations = TRUE, delta = 2, announce_humans = TRUE, announce_xenos = TRUE, send_fax = TRUE)
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
[numHostsShip] human\s on the ship."
[numHostsTransit] human\s in transit.
[numXenosTransit] xeno\s in transit.</span>"})

	message_admins("Bioscan - Humans: [numHostsPlanet] on the planet[hostLocationP ? ". Location:[hostLocationP]":""]. [numHostsShipr] on the ship.[hostLocationS ? " Location: [hostLocationS].":""]. [numHostsTransitr] in transit.")
	message_admins("Bioscan - Xenos: [numXenosPlanetr] on the planet[numXenosPlanetr > 0 && xenoLocationP ? ". Location:[xenoLocationP]":""]. [numXenosShip] on the ship.[xenoLocationS ? " Location: [xenoLocationS].":""] [numXenosTransitr] in transit.")

#undef BIOSCAN_DELTA
#undef BIOSCAN_LOCATION

/datum/game_mode/proc/setup_xeno_tunnels()
	var/i = 0
	while(length(GLOB.xeno_tunnel_landmarks) && i++ < MAX_TUNNELS_PER_MAP)
		var/obj/structure/tunnel/ONE
		var/obj/effect/landmark/xeno_tunnel/L
		var/turf/T
		L = pick(GLOB.xeno_tunnel_landmarks)
		GLOB.xeno_tunnel_landmarks -= L
		T = L.loc
		ONE = new(T)
		ONE.id = "hole[i]"
		for(var/x in GLOB.xeno_tunnels)
			var/obj/structure/tunnel/TWO = x
			if(ONE.id != TWO.id || ONE == TWO || ONE.other || TWO.other)
				continue
			ONE.other = TWO
			TWO.other = ONE


/datum/game_mode/proc/setup_blockers()
	set waitfor = FALSE
	if(flags_round_type & MODE_FOG_ACTIVATED)
		var/turf/T
		while(GLOB.fog_blocker_locations.len)
			T = GLOB.fog_blocker_locations[GLOB.fog_blocker_locations.len]
			GLOB.fog_blocker_locations.len--
			new /obj/effect/forcefield/fog(T)
			stoplag()
		addtimer(CALLBACK(src, .proc/remove_fog), FOG_DELAY_INTERVAL + SSticker.round_start_time + rand(-5 MINUTES, 5 MINUTES))

	if(flags_round_type & MODE_LZ_SHUTTERS)
		addtimer(CALLBACK(GLOBAL_PROC, .proc/send_global_signal, COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE), SSticker.round_start_time + 40 MINUTES)
			//Called late because there used to be shutters opened earlier. To re-add them just copy the logic.

	if(flags_round_type & MODE_XENO_SPAWN_PROTECT)
		var/turf/T
		while(GLOB.xeno_spawn_protection_locations.len)
			T = GLOB.xeno_spawn_protection_locations[GLOB.xeno_spawn_protection_locations.len]
			GLOB.xeno_spawn_protection_locations.len--
			new /obj/effect/forcefield/fog(T)
			stoplag()


/datum/game_mode/proc/grant_eord_respawn(datum/dcs, mob/source)
	source.verbs += /mob/proc/eord_respawn

/datum/game_mode/proc/end_of_round_deathmatch()
	RegisterSignal(SSdcs, COMSIG_GLOB_MOB_LOGIN, .proc/grant_eord_respawn) // New mobs can now respawn into EORD
	var/list/spawns = GLOB.deathmatch.Copy()

	CONFIG_SET(flag/allow_synthetic_gun_use, TRUE)

	if(!length(spawns))
		to_chat(world, "<br><br><h1><span class='danger'>End of Round Deathmatch initialization failed, please do not grief.</span></h1><br><br>")
		return

	for(var/i in GLOB.player_list)
		var/mob/M = i
		if(isnewplayer(M))
			continue
		if(!(M.client?.prefs?.be_special & BE_DEATHMATCH))
			continue
		if(!M.mind) //This proc is too important to prevent one admin shenanigan from runtiming it entirely
			to_chat(M, "<br><br><h1><span class='danger'>You don't have a mind, if you believe this is not intended, please report it.</span></h1><br><br>")
			continue

		var/turf/picked
		if(length(spawns))
			picked = pick(spawns)
			spawns -= picked
		else
			spawns = GLOB.deathmatch.Copy()

			if(!length(spawns))
				to_chat(world, "<br><br><h1><span class='danger'>End of Round Deathmatch initialization failed, please do not grief.</span></h1><br><br>")
				return

			picked = pick(spawns)
			spawns -= picked

		if(!picked)
			to_chat(M, "<br><br><h1><span class='danger'>Failed to find a valid location for End of Round Deathmatch. Please do not grief.</span></h1><br><br>")
			continue

		var/mob/living/L
		if(!isliving(M) || isAI(M))
			L = new /mob/living/carbon/human(picked)
			M.mind.transfer_to(L, TRUE)
		else
			L = M
			INVOKE_ASYNC(L, /atom/movable/.proc/forceMove, picked)

		L.mind.bypass_ff = TRUE
		L.revive()

		if(isxeno(L))
			var/mob/living/carbon/xenomorph/X = L
			X.transfer_to_hive(pick(XENO_HIVE_NORMAL, XENO_HIVE_CORRUPTED, XENO_HIVE_ALPHA, XENO_HIVE_BETA, XENO_HIVE_ZETA))

		else if(ishuman(L))
			var/mob/living/carbon/human/H = L
			if(!H.w_uniform)
				var/job = pick(/datum/job/clf/leader, /datum/job/freelancer/leader, /datum/job/upp/leader, /datum/job/som/leader, /datum/job/pmc/leader, /datum/job/freelancer/standard, /datum/job/som/standard, /datum/job/clf/standard)
				var/datum/job/J = SSjob.GetJobType(job)
				H.apply_assigned_role_to_spawn(J)
				H.regenerate_icons()

		to_chat(L, "<br><br><h1><span class='danger'>Fight for your life!</span></h1><br><br>")
		CHECK_TICK


/datum/game_mode/proc/orphan_hivemind_collapse()
	return


/datum/game_mode/proc/get_hivemind_collapse_countdown()
	return


/datum/game_mode/proc/announce_medal_awards()
	if(!length(GLOB.medal_awards))
		return

	var/dat =  "<span class='round_body'>Medal Awards:</span>"

	for(var/recipient in GLOB.medal_awards)
		var/datum/recipient_awards/RA = GLOB.medal_awards[recipient]
		for(var/i in 1 to length(RA.medal_names))
			dat += "<br><b>[RA.recipient_rank] [recipient]</b> is awarded [RA.posthumous[i] ? "posthumously " : ""]the <span class='boldnotice'>[RA.medal_names[i]]</span>: \'<i>[RA.medal_citations[i]]</i>\'."

	to_chat(world, dat)


/datum/game_mode/proc/announce_round_stats()
	var/list/dat = list({"<span class='round_body'>The end of round statistics are:</span><br>
		<br>There were [GLOB.round_statistics.total_bullets_fired] total bullets fired.
		<br>[GLOB.round_statistics.total_bullet_hits_on_marines] bullets managed to hit marines. For a [(GLOB.round_statistics.total_bullet_hits_on_marines / max(GLOB.round_statistics.total_bullets_fired, 1)) * 100]% friendly fire rate!"})
	if(GLOB.round_statistics.total_bullet_hits_on_xenos)
		dat += "[GLOB.round_statistics.total_bullet_hits_on_xenos] bullets managed to hit xenomorphs. For a [(GLOB.round_statistics.total_bullet_hits_on_xenos / max(GLOB.round_statistics.total_bullets_fired, 1)) * 100]% accuracy total!"
	if(GLOB.round_statistics.grenades_thrown)
		dat += "[GLOB.round_statistics.grenades_thrown] total grenades exploding."
	else
		dat += "No grenades exploded."
	if(GLOB.round_statistics.now_pregnant)
		dat += "[GLOB.round_statistics.now_pregnant] people infected among which [GLOB.round_statistics.total_larva_burst] burst. For a [(GLOB.round_statistics.total_larva_burst / max(GLOB.round_statistics.now_pregnant, 1)) * 100]% successful delivery rate!"
	if(GLOB.round_statistics.queen_screech)
		dat += "[GLOB.round_statistics.queen_screech] Queen screeches."
	if(GLOB.round_statistics.warrior_limb_rips)
		dat += "[GLOB.round_statistics.warrior_limb_rips] limbs ripped off by Warriors."
	if(GLOB.round_statistics.crusher_stomp_victims)
		dat += "[GLOB.round_statistics.crusher_stomp_victims] people stomped by crushers."
	if(GLOB.round_statistics.praetorian_spray_direct_hits)
		dat += "[GLOB.round_statistics.praetorian_spray_direct_hits] people hit directly by Praetorian acid spray."
	if(GLOB.round_statistics.weeds_planted)
		dat += "[GLOB.round_statistics.weeds_planted] weed nodes planted."
	if(GLOB.round_statistics.weeds_destroyed)
		dat += "[GLOB.round_statistics.weeds_destroyed] weed tiles removed."
	if(GLOB.round_statistics.carrier_traps)
		dat += "[GLOB.round_statistics.carrier_traps] hidey holes for huggers were made."
	if(GLOB.round_statistics.sentinel_neurotoxin_stings)
		dat += "[GLOB.round_statistics.sentinel_neurotoxin_stings] number of times Sentinels stung."
	if(GLOB.round_statistics.drone_salvage_plasma)
		dat += "[GLOB.round_statistics.drone_salvage_plasma] number of times Drones salvaged corpses."
	if(GLOB.round_statistics.panther_neurotoxin_stings)
		dat += "[GLOB.round_statistics.panther_neurotoxin_stings] number of times Panthers stung."
	if(GLOB.round_statistics.defiler_defiler_stings)
		dat += "[GLOB.round_statistics.defiler_defiler_stings] number of times Defilers stung."
	if(GLOB.round_statistics.defiler_neurogas_uses)
		dat += "[GLOB.round_statistics.defiler_neurogas_uses] number of times Defilers vented neurogas."
	if(GLOB.round_statistics.xeno_unarmed_attacks && GLOB.round_statistics.xeno_bump_attacks)
		dat += "[GLOB.round_statistics.xeno_bump_attacks] bump attacks, which made up [(GLOB.round_statistics.xeno_bump_attacks / GLOB.round_statistics.xeno_unarmed_attacks) * 100]% of all attacks ([GLOB.round_statistics.xeno_unarmed_attacks])."

	var/output = jointext(dat, "<br>")
	for(var/mob/player in GLOB.player_list)
		if(player?.client?.prefs?.toggles_chat & CHAT_STATISTICS)
			to_chat(player, output)


/datum/game_mode/proc/count_humans_and_xenos(list/z_levels = SSmapping.levels_by_any_trait(list(ZTRAIT_MARINE_MAIN_SHIP, ZTRAIT_GROUND, ZTRAIT_RESERVED)), count_flags)
	var/num_humans = 0
	var/num_xenos = 0

	for(var/z in z_levels)
		for(var/i in GLOB.humans_by_zlevel["[z]"])
			var/mob/living/carbon/human/H = i
			if(!istype(H)) // Small fix?
				continue
			if(count_flags & COUNT_IGNORE_HUMAN_SSD && !H.client)
				continue
			if(H.status_flags & XENO_HOST)
				continue
			if(isspaceturf(H.loc))
				continue
			num_humans++

	for(var/z in z_levels)
		for(var/i in GLOB.hive_datums[XENO_HIVE_NORMAL].xenos_by_zlevel["[z]"])
			var/mob/living/carbon/xenomorph/X = i
			if(!istype(X)) // Small fix?
				continue
			if(count_flags & COUNT_IGNORE_XENO_SSD && !X.client)
				continue
			if(count_flags & COUNT_IGNORE_XENO_SPECIAL_AREA && is_xeno_in_forbidden_zone(X))
				continue
			if(isspaceturf(X.loc))
				continue

			// Never count hivemind
			if(isxenohivemind(X))
				continue

			num_xenos++

	return list(num_humans, num_xenos)

/datum/game_mode/proc/get_total_joblarvaworth(list/z_levels = SSmapping.levels_by_any_trait(list(ZTRAIT_MARINE_MAIN_SHIP, ZTRAIT_GROUND, ZTRAIT_RESERVED)), count_flags)
	. = 0

	for(var/i in GLOB.human_mob_list)
		var/mob/living/carbon/human/H = i
		if(!H.job)
			continue
		if(H.stat == DEAD && !H.is_revivable())
			continue
		if(count_flags & COUNT_IGNORE_HUMAN_SSD && !H.client)
			continue
		if(H.status_flags & XENO_HOST)
			continue
		if(!(H.z in z_levels) || isspaceturf(H.loc))
			continue
		. += H.job.jobworth[/datum/job/xenomorph]

/datum/game_mode/proc/is_xeno_in_forbidden_zone(mob/living/carbon/xenomorph/xeno)
	return FALSE

/datum/game_mode/infestation/distress/is_xeno_in_forbidden_zone(mob/living/carbon/xenomorph/xeno)
	if(round_stage == DISTRESS_DROPSHIP_CRASHED)
		return FALSE
	if(isxenoresearcharea(get_area(xeno)))
		return TRUE
	return FALSE


/datum/game_mode/proc/remove_fog()
	set waitfor = FALSE

	DISABLE_BITFIELD(flags_round_type, MODE_FOG_ACTIVATED)

	for(var/i in GLOB.fog_blockers)
		qdel(i)
		stoplag(1)


/datum/game_mode/proc/mode_new_player_panel(mob/new_player/NP)

	var/output = "<div align='center'>"
	output += "<br><i>You are part of the <b>TerraGov Marine Corps</b>, a military branch of the TerraGov council.</i>"
	output +="<hr>"
	output += "<p><a href='byond://?src=[REF(NP)];lobby_choice=show_preferences'>Setup Character</A> | <a href='byond://?src=[REF(NP)];lobby_choice=lore'>Background</A><br><br><a href='byond://?src=[REF(NP)];lobby_choice=observe'>Observe</A></p>"
	output +="<hr>"
	output += "<center><p>Current character: <b>[NP.client ? NP.client.prefs.real_name : "Unknown User"]</b></p>"

	if(SSticker.current_state <= GAME_STATE_PREGAME)
		output += "<p>\[ [NP.ready? "<b>Ready</b>":"<a href='byond://?src=\ref[src];lobby_choice=ready'>Ready</a>"] | [NP.ready? "<a href='byond://?src=[REF(NP)];lobby_choice=ready'>Not Ready</a>":"<b>Not Ready</b>"] \]</p>"
	else
		output += "<a href='byond://?src=[REF(NP)];lobby_choice=manifest'>View the Crew Manifest</A><br>"
		output += "<p><a href='byond://?src=[REF(NP)];lobby_choice=late_join'>Join the Game!</A></p>"

	output += append_player_votes_link(NP)

	output += "</div>"

	var/datum/browser/popup = new(NP, "playersetup", "<div align='center'>Welcome to TGMC[SSmapping?.configs ? " - [SSmapping.configs[SHIP_MAP].map_name]" : ""]</div>", 300, 375)
	popup.set_window_options("can_close=0")
	popup.set_content(output)
	popup.open(FALSE)

	return TRUE

/datum/game_mode/proc/append_player_votes_link(mob/new_player/NP)
	if(QDELETED(NP) || IsGuestKey(NP.key) || !SSdbcore.IsConnected())
		return "" // append nothing

	var/isadmin = check_rights(R_ADMIN, FALSE)
	var/newpoll = FALSE
	var/datum/DBQuery/query_get_new_polls = SSdbcore.NewQuery("SELECT id FROM [format_table_name("poll_question")] WHERE [(isadmin ? "" : "adminonly = false AND")] Now() BETWEEN starttime AND endtime AND id NOT IN (SELECT pollid FROM [format_table_name("poll_vote")] WHERE ckey = \"[sanitizeSQL(NP.ckey)]\") AND id NOT IN (SELECT pollid FROM [format_table_name("poll_textreply")] WHERE ckey = \"[sanitizeSQL(NP.ckey)]\")")
	if(query_get_new_polls.Execute())
		if(query_get_new_polls.NextRow())
			newpoll = TRUE
	qdel(query_get_new_polls)

	if(newpoll)
		return "<p><b><a href='byond://?src=[REF(NP)];showpoll=1'>Show Player Polls</A> (NEW!)</b></p>"
	else
		return "<p><a href='byond://?src=[REF(NP)];showpoll=1'>Show Player Polls</A></p>"


/datum/game_mode/proc/CanLateSpawn(mob/new_player/NP, datum/job/job)
	if(!isnewplayer(NP))
		return FALSE
	if(!NP.IsJobAvailable(job, TRUE))
		to_chat(usr, "<span class='warning'>Selected job is not available.<spawn>")
		return FALSE
	if(!SSticker || SSticker.current_state != GAME_STATE_PLAYING)
		to_chat(usr, "<span class='warning'>The round is either not ready, or has already finished!<spawn>")
		return FALSE
	if(!GLOB.enter_allowed)
		to_chat(usr, "<span class='warning'>Spawning currently disabled, please observe.<spawn>")
		return FALSE
	if(!NP.client.prefs.random_name)
		var/name_to_check = NP.client.prefs.real_name
		if(job.job_flags & JOB_FLAG_SPECIALNAME)
			name_to_check = job.get_special_name(NP.client)
		if(CONFIG_GET(flag/prevent_dupe_names) && GLOB.real_names_joined.Find(name_to_check))
			to_chat(usr, "<span class='warning'>Someone has already joined the round with this character name. Please pick another.<spawn>")
			return FALSE
	if(!SSjob.AssignRole(NP, job, TRUE))
		to_chat(usr, "<span class='warning'>Failed to assign selected role.<spawn>")
		return FALSE
	return TRUE


/datum/game_mode/proc/LateSpawn(mob/new_player/player)
	player.close_spawn_windows()
	player.spawning = TRUE
	player.create_character()
	SSjob.spawn_character(player, TRUE)
	player.mind.transfer_to(player.new_character)
	var/datum/job/job = player.assigned_role
	job.on_late_spawn(player.new_character)
	var/area/A = get_area(player.new_character)
	deadchat_broadcast("<span class='game'> has woken at <span class='name'>[A?.name]</span>.</span>", "<span class='game'><span class='name'>[player.new_character.real_name]</span> ([job.title])</span>", follow_target = player.new_character, message_type = DEADCHAT_ARRIVALRATTLE)
	qdel(player)

/datum/game_mode/proc/attempt_to_join_as_larva(mob/xeno_candidate)
	to_chat(xeno_candidate, "<span class='warning'>This is unavailable in this gamemode.</span>")
	return FALSE


/datum/game_mode/proc/spawn_larva(mob/xeno_candidate)
	to_chat(xeno_candidate, "<span class='warning'>This is unavailable in this gamemode.</span>")
	return FALSE

/datum/game_mode/proc/transfer_xeno(mob/xeno_candidate, mob/living/carbon/xenomorph/X)
	if(QDELETED(X))
		stack_trace("[xeno_candidate] was put into a qdeleted mob [X]")
		return
	message_admins("[key_name(xeno_candidate)] has joined as [ADMIN_TPMONTY(X)].")
	xeno_candidate.mind.transfer_to(X, TRUE)
	if(X.is_ventcrawling)  //If we are in a vent, fetch a fresh vent map
		X.add_ventcrawl(X.loc)


/datum/game_mode/proc/attempt_to_join_as_xeno(mob/xeno_candidate, instant_join = FALSE)
	var/list/available_xenos = list()
	for(var/hive in GLOB.hive_datums)
		var/datum/hive_status/HS = GLOB.hive_datums[hive]
		available_xenos += HS.get_ssd_xenos(instant_join)

	if(!available_xenos.len)
		to_chat(xeno_candidate, "<span class='warning'>There aren't any available already living xenomorphs. You can try waiting for a larva to burst if you have the preference enabled.</span>")
		return FALSE

	if(instant_join)
		return pick(available_xenos) //Just picks something at random.

	var/mob/living/carbon/xenomorph/new_xeno = input("Available Xenomorphs") as null|anything in available_xenos
	if(!istype(new_xeno) || !xeno_candidate?.client)
		return FALSE

	if(new_xeno.stat == DEAD)
		to_chat(xeno_candidate, "<span class='warning'>You cannot join if the xenomorph is dead.</span>")
		return FALSE

	if(new_xeno.client)
		to_chat(xeno_candidate, "<span class='warning'>That xenomorph has been occupied.</span>")
		return FALSE

	if(XENODEATHTIME_CHECK(xeno_candidate))
		if(check_other_rights(xeno_candidate.client, R_ADMIN, FALSE))
			if(alert(xeno_candidate, "You wouldn't normally qualify for this respawn. Are you sure you want to bypass it with your admin powers?", "Bypass Respawn", "Yes", "No") != "Yes")
				XENODEATHTIME_MESSAGE(xeno_candidate)
				return FALSE
		else
			XENODEATHTIME_MESSAGE(xeno_candidate)
			return FALSE

	if(new_xeno.afk_status == MOB_RECENTLY_DISCONNECTED) //We do not want to occupy them if they've only been gone for a little bit.
		to_chat(xeno_candidate, "<span class='warning'>That player hasn't been away long enough. Please wait [round(timeleft(new_xeno.afk_timer_id) * 0.1)] second\s longer.</span>")
		return FALSE

	return new_xeno

/datum/game_mode/proc/set_valid_job_types()
	if(!SSjob?.initialized)
		to_chat(world, "<span class='boldnotice'>Error setting up valid jobs, no job subsystem found initialized.</span>")
		CRASH("Error setting up valid jobs, no job subsystem found initialized.")
	if(SSjob.ssjob_flags & SSJOB_OVERRIDE_JOBS_START) //This allows an admin to pause the roundstart and set custom jobs for the round.
		SSjob.active_occupations = SSjob.joinable_occupations.Copy()
		SSjob.active_joinable_occupations.Cut()
		for(var/j in SSjob.joinable_occupations)
			var/datum/job/job = j
			if(!job.total_positions)
				continue
			SSjob.active_joinable_occupations += job
		SSjob.set_active_joinable_occupations_by_category()
		return TRUE
	if(!length(valid_job_types))
		SSjob.active_occupations = SSjob.joinable_occupations.Copy()
		SSjob.active_joinable_occupations = SSjob.joinable_occupations.Copy()
		SSjob.set_active_joinable_occupations_by_category()
		return TRUE
	SSjob.active_occupations.Cut()
	for(var/j in SSjob.joinable_occupations)
		var/datum/job/job = j
		if(!valid_job_types[job.type])
			job.total_positions = 0 //Assign the value directly instead of using set_job_positions(), as we are building the lists.
			continue
		job.total_positions = valid_job_types[job.type] //Same for this one, direct value assignment.
		SSjob.active_occupations += job
	if(!length(SSjob.active_occupations))
		to_chat(world, "<span class='boldnotice'>Error, game mode has only invalid jobs assigned.</span>")
		return FALSE
	SSjob.active_joinable_occupations = SSjob.active_occupations.Copy()
	SSjob.set_active_joinable_occupations_by_category()
	return TRUE

/datum/game_mode/proc/set_valid_squads()
	var/max_squad_num = min(squads_max_number, SSmapping.configs[SHIP_MAP].squads_max_num)
	if(max_squad_num >= length(SSjob.squads))
		SSjob.active_squads = SSjob.squads
		return TRUE
	if(max_squad_num == 0)
		return TRUE
	var/list/preferred_squads = shuffle(SSjob.squads)
	for(var/s in SSjob.squads)
		preferred_squads[s] = 1
	if(!length(preferred_squads))
		to_chat(world, "<span class='boldnotice'>Error, no squads found.</span>")
		return FALSE
	for(var/i in GLOB.new_player_list)
		var/mob/new_player/player = i
		if(!player.ready || !player.client?.prefs?.preferred_squad)
			continue
		var/squad_choice = player.client.prefs.preferred_squad
		if(squad_choice == "None")
			continue
		if(!preferred_squads[squad_choice])
			stack_trace("[player.client] has in its prefs [squad_choice] for a squad. Not valid.")
			continue
		preferred_squads[squad_choice]++
	sortTim(preferred_squads, cmp=/proc/cmp_numeric_dsc, associative = TRUE)

	preferred_squads.len = max_squad_num
	for(var/s in preferred_squads) //Back from weight to type.
		preferred_squads[s] = SSjob.squads[s]
	SSjob.active_squads = preferred_squads.Copy()

	return TRUE


/datum/game_mode/proc/scale_roles()
	if(SSjob.ssjob_flags & SSJOB_OVERRIDE_JOBS_START)
		return FALSE
	if(length(SSjob.active_squads))
		scale_squad_jobs()
	return TRUE

/datum/game_mode/proc/scale_squad_jobs()
	var/datum/job/scaled_job = SSjob.GetJobType(/datum/job/terragov/squad/leader)
	scaled_job.total_positions = length(SSjob.active_squads)
