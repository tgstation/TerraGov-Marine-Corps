/datum/game_mode
	var/name = ""
	var/config_tag = null
	var/votable = TRUE
	var/required_players = 0
	var/maximum_players = INFINITY
	var/squads_max_number = 4
	///Determines whether rounds with the gamemode will be factored in when it comes to persistency
	var/allow_persistence_save = TRUE

	var/round_finished
	var/list/round_end_states = list()
	var/list/valid_job_types = list()

	var/round_time_fog
	var/flags_round_type = NONE
	var/flags_landmarks = NONE
	var/flags_xeno_abilities = NONE

	var/distress_cancelled = FALSE

	var/deploy_time_lock = 15 MINUTES
	///The respawn time for marines
	var/respawn_time = 30 MINUTES
	///How many points do you need to win in a point gamemode
	var/win_points_needed = 0
	///The points per faction, assoc list
	var/list/points_per_faction
	/// When are the shutters dropping
	var/shutters_drop_time = 30 MINUTES
	///Time before becoming a zombie when going undefibbable
	var/zombie_transformation_time = 30 SECONDS
	/** The time between two rounds of this gamemode. If it's zero, this mode i always votable.
	 * It an integer in ticks, set in config. If it's 8 HOURS, it means that it will be votable again 8 hours
	 * after the end of the last round with the gamemode type
	 */
	var/time_between_round = 0

//Distress call variables.
	var/list/datum/emergency_call/all_calls = list() //initialized at round start and stores the datums.
	var/datum/emergency_call/picked_call = null //Which distress call is currently active
	var/on_distress_cooldown = FALSE
	var/waiting_for_candidates = FALSE
	/// Ponderation rate of silos output. 1 is normal, 2 is twice
	var/silo_scaling = 1


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
	if(flags_landmarks & MODE_LANDMARK_SPAWN_SPECIFIC_SHUTTLE_CONSOLE)
		for(var/turf/T AS in GLOB.lz1_shuttle_console_turfs_list)
			new /obj/machinery/computer/shuttle/shuttle_control/dropship/rebel(T)
		for(var/turf/T AS in GLOB.lz2_shuttle_console_turfs_list)
			new /obj/machinery/computer/shuttle/shuttle_control/dropship/loyalist(T)
	else
		for(var/turf/T AS in GLOB.lz1_shuttle_console_turfs_list + GLOB.lz2_shuttle_console_turfs_list)
			new /obj/machinery/computer/shuttle/shuttle_control/dropship(T)

	setup_blockers()
	GLOB.balance.Initialize()

	GLOB.landmarks_round_start = shuffle(GLOB.landmarks_round_start)
	var/atom/movable/effect/landmark/L
	while(GLOB.landmarks_round_start.len)
		L = GLOB.landmarks_round_start[GLOB.landmarks_round_start.len]
		GLOB.landmarks_round_start.len--
		L.after_round_start()

	return TRUE

/datum/game_mode/proc/setup()
	SHOULD_CALL_PARENT(TRUE)
	SSjob.DivideOccupations()
	create_characters()
	spawn_characters()
	transfer_characters()
	SSpoints.prepare_supply_packs_list(CHECK_BITFIELD(flags_round_type, MODE_HUMAN_ONLY))
	SSpoints.dropship_points = 0
	SSpoints.supply_points[FACTION_TERRAGOV] = 0

	for(var/hivenum in GLOB.hive_datums)
		var/datum/hive_status/hive = GLOB.hive_datums[hivenum]
		hive.purchases.setup_upgrades()
	return TRUE


/datum/game_mode/proc/post_setup()
	addtimer(CALLBACK(src, .proc/display_roundstart_logout_report), ROUNDSTART_LOGOUT_REPORT_TIME)
	if(flags_round_type & MODE_SILO_RESPAWN)
		var/datum/hive_status/normal/HN = GLOB.hive_datums[XENO_HIVE_NORMAL]
		HN.RegisterSignal(SSdcs, list(COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE, COMSIG_GLOB_OPEN_SHUTTERS_EARLY), /datum/hive_status/normal.proc/set_siloless_collapse_timer)
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
		var/datum/db_query/query_round_game_mode = SSdbcore.NewQuery("UPDATE [format_table_name("round")] SET [sql] WHERE id = :roundid", list("roundid" = GLOB.round_id))
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
	if(time_between_round)
		SSpersistence.last_modes_round_date[name] = world.realtime
	//Collects persistence features
	if(allow_persistence_save)
		SSpersistence.CollectData()
	end_of_round_deathmatch()
	return TRUE


/datum/game_mode/proc/display_roundstart_logout_report()
	var/msg = "<hr>[span_notice("<b>Roundstart logout report</b>")]<br>"
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

///Annonce to everyone the number of xeno and marines on ship and ground
/datum/game_mode/proc/announce_bioscans(show_locations = TRUE, delta = 2, announce_humans = TRUE, announce_xenos = TRUE, send_fax = TRUE)
	return

/datum/game_mode/proc/setup_blockers()
	set waitfor = FALSE
	if(flags_round_type & MODE_FOG_ACTIVATED)
		var/turf/T
		while(GLOB.fog_blocker_locations.len)
			T = GLOB.fog_blocker_locations[GLOB.fog_blocker_locations.len]
			GLOB.fog_blocker_locations.len--
			new /atom/movable/effect/forcefield/fog(T)
			stoplag()
		addtimer(CALLBACK(src, .proc/remove_fog), FOG_DELAY_INTERVAL + SSticker.round_start_time + rand(-5 MINUTES, 5 MINUTES))

	if(flags_round_type & MODE_LZ_SHUTTERS)
		addtimer(CALLBACK(GLOBAL_PROC, .proc/send_global_signal, COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE), SSticker.round_start_time + shutters_drop_time)
			//Called late because there used to be shutters opened earlier. To re-add them just copy the logic.

	if(flags_round_type & MODE_XENO_SPAWN_PROTECT)
		var/turf/T
		while(GLOB.xeno_spawn_protection_locations.len)
			T = GLOB.xeno_spawn_protection_locations[GLOB.xeno_spawn_protection_locations.len]
			GLOB.xeno_spawn_protection_locations.len--
			new /atom/movable/effect/forcefield/fog(T)
			stoplag()


/datum/game_mode/proc/grant_eord_respawn(datum/dcs, mob/source)
	SIGNAL_HANDLER
	source.verbs += /mob/proc/eord_respawn

/datum/game_mode/proc/end_of_round_deathmatch()
	RegisterSignal(SSdcs, COMSIG_GLOB_MOB_LOGIN, .proc/grant_eord_respawn) // New mobs can now respawn into EORD
	var/list/spawns = GLOB.deathmatch.Copy()

	CONFIG_SET(flag/allow_synthetic_gun_use, TRUE)

	if(!length(spawns))
		to_chat(world, "<br><br><h1>[span_danger("End of Round Deathmatch initialization failed, please do not grief.")]</h1><br><br>")
		return

	for(var/i in GLOB.player_list)
		var/mob/M = i
		if(isnewplayer(M))
			continue
		if(!(M.client?.prefs?.be_special & BE_DEATHMATCH))
			continue
		if(!M.mind) //This proc is too important to prevent one admin shenanigan from runtiming it entirely
			to_chat(M, "<br><br><h1>[span_danger("You don't have a mind, if you believe this is not intended, please report it.")]</h1><br><br>")
			continue

		var/turf/picked
		if(length(spawns))
			picked = pick(spawns)
			spawns -= picked
		else
			spawns = GLOB.deathmatch.Copy()

			if(!length(spawns))
				to_chat(world, "<br><br><h1>[span_danger("End of Round Deathmatch initialization failed, please do not grief.")]</h1><br><br>")
				return

			picked = pick(spawns)
			spawns -= picked

		if(!picked)
			to_chat(M, "<br><br><h1>[span_danger("Failed to find a valid location for End of Round Deathmatch. Please do not grief.")]</h1><br><br>")
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
				var/job = pick(
					/datum/job/clf/leader,
					/datum/job/clf/standard,
					/datum/job/freelancer/leader,
					/datum/job/freelancer/grenadier,
					/datum/job/freelancer/standard,
					/datum/job/upp/leader,
					/datum/job/upp/heavy,
					/datum/job/upp/standard,
					/datum/job/som/leader,
					/datum/job/som/veteran,
					/datum/job/som/standard,
					/datum/job/pmc/leader,
					/datum/job/pmc/standard,
				)
				var/datum/job/J = SSjob.GetJobType(job)
				H.apply_assigned_role_to_spawn(J)
				H.regenerate_icons()

		to_chat(L, "<br><br><h1>[span_danger("Fight for your life!")]</h1><br><br>")
		CHECK_TICK


/datum/game_mode/proc/orphan_hivemind_collapse()
	return


/datum/game_mode/proc/get_hivemind_collapse_countdown()
	return

///handles end of the round when no silo is left
/datum/game_mode/proc/siloless_hive_collapse()
	return

///starts the timer to end the round when no silo is left
/datum/game_mode/proc/get_siloless_collapse_countdown()
	return

/datum/game_mode/proc/announce_medal_awards()
	if(!length(GLOB.medal_awards))
		return

	var/dat =  span_round_body("Medal Awards:")

	for(var/recipient in GLOB.medal_awards)
		var/datum/recipient_awards/RA = GLOB.medal_awards[recipient]
		for(var/i in 1 to length(RA.medal_names))
			dat += "<br><b>[RA.recipient_rank] [recipient]</b> is awarded [RA.posthumous[i] ? "posthumously " : ""]the [span_boldnotice("[RA.medal_names[i]]")]: \'<i>[RA.medal_citations[i]]</i>\'."

	to_chat(world, dat)


/datum/game_mode/proc/announce_round_stats()
	var/list/dat = list({"[span_round_body("The end of round statistics are:")]<br>
		<br>There were [GLOB.round_statistics.total_bullets_fired] total bullets fired.
		<br>[GLOB.round_statistics.total_bullet_hits_on_marines] bullets managed to hit marines. For a [(GLOB.round_statistics.total_bullet_hits_on_marines / max(GLOB.round_statistics.total_bullets_fired, 1)) * 100]% friendly fire rate!"})
	if(GLOB.round_statistics.total_bullet_hits_on_xenos)
		dat += "[GLOB.round_statistics.total_bullet_hits_on_xenos] bullets managed to hit xenomorphs. For a [(GLOB.round_statistics.total_bullet_hits_on_xenos / max(GLOB.round_statistics.total_bullets_fired, 1)) * 100]% accuracy total!"
	if(GLOB.round_statistics.grenades_thrown)
		dat += "[GLOB.round_statistics.grenades_thrown] total grenades exploding."
	else
		dat += "No grenades exploded."
	if(GLOB.round_statistics.total_human_deaths)
		dat += "[GLOB.round_statistics.total_human_deaths] people were killed, among which [GLOB.round_statistics.total_human_revives] were revived and [GLOB.round_statistics.total_human_respawns] respawned. For a [(GLOB.round_statistics.total_human_revives / max(GLOB.round_statistics.total_human_deaths, 1)) * 100]% revival rate and a [(GLOB.round_statistics.total_human_respawns / max(GLOB.round_statistics.total_human_deaths, 1)) * 100]% respawn rate."
	if(SSevacuation.human_escaped)
		dat += "[SSevacuation.human_escaped] marines manage to evacuate, among [SSevacuation.initial_human_on_ship] that were on ship when xenomorphs arrived."
	if(GLOB.round_statistics.now_pregnant)
		dat += "[GLOB.round_statistics.now_pregnant] people infected among which [GLOB.round_statistics.total_larva_burst] burst. For a [(GLOB.round_statistics.total_larva_burst / max(GLOB.round_statistics.now_pregnant, 1)) * 100]% successful delivery rate!"
	if(GLOB.round_statistics.queen_screech)
		dat += "[GLOB.round_statistics.queen_screech] Queen screeches."
	if(GLOB.round_statistics.warrior_lunges)
		dat += "[GLOB.round_statistics.warrior_lunges] Warriors lunges."
	if(GLOB.round_statistics.crusher_stomp_victims)
		dat += "[GLOB.round_statistics.crusher_stomp_victims] people stomped by crushers."
	if(GLOB.round_statistics.praetorian_spray_direct_hits)
		dat += "[GLOB.round_statistics.praetorian_spray_direct_hits] people hit directly by Praetorian acid spray."
	if(GLOB.round_statistics.weeds_planted)
		dat += "[GLOB.round_statistics.weeds_planted] weed nodes planted."
	if(GLOB.round_statistics.weeds_destroyed)
		dat += "[GLOB.round_statistics.weeds_destroyed] weed tiles removed."
	if(GLOB.round_statistics.trap_holes)
		dat += "[GLOB.round_statistics.trap_holes] holes for acid and huggers were made."
	if(GLOB.round_statistics.sentinel_neurotoxin_stings)
		dat += "[GLOB.round_statistics.sentinel_neurotoxin_stings] number of times neurotoxin sting was used."
	if(GLOB.round_statistics.defiler_defiler_stings)
		dat += "[GLOB.round_statistics.defiler_defiler_stings] number of times Defilers stung."
	if(GLOB.round_statistics.defiler_neurogas_uses)
		dat += "[GLOB.round_statistics.defiler_neurogas_uses] number of times Defilers vented neurogas."
	if(GLOB.round_statistics.defiler_reagent_slashes)
		dat += "[GLOB.round_statistics.defiler_reagent_slashes] number of times Defilers struck an enemy with their reagent slash."
	if(GLOB.round_statistics.xeno_unarmed_attacks && GLOB.round_statistics.xeno_bump_attacks)
		dat += "[GLOB.round_statistics.xeno_bump_attacks] bump attacks, which made up [(GLOB.round_statistics.xeno_bump_attacks / GLOB.round_statistics.xeno_unarmed_attacks) * 100]% of all attacks ([GLOB.round_statistics.xeno_unarmed_attacks])."
	if(GLOB.round_statistics.xeno_rally_hive)
		dat += "[GLOB.round_statistics.xeno_rally_hive] number of times xeno leaders rallied the hive."
	if(GLOB.round_statistics.hivelord_healing_infusions)
		dat += "[GLOB.round_statistics.hivelord_healing_infusions] number of times Hivelords used Healing Infusion."
	if(GLOB.round_statistics.spitter_acid_sprays)
		dat += "[GLOB.round_statistics.spitter_acid_sprays] number of times Spitters spewed an Acid Spray."
	if(GLOB.round_statistics.spitter_scatter_spits)
		dat += "[GLOB.round_statistics.spitter_scatter_spits] number of times Spitters horked up scatter spits."
	if(GLOB.round_statistics.ravager_endures)
		dat += "[GLOB.round_statistics.ravager_endures] number of times Ravagers used Endure."
	if(GLOB.round_statistics.hunter_marks)
		dat += "[GLOB.round_statistics.hunter_marks] number of times Hunters marked a target for death."
	if(GLOB.round_statistics.ravager_rages)
		dat += "[GLOB.round_statistics.ravager_rages] number of times Ravagers raged."
	if(GLOB.round_statistics.hunter_silence_targets)
		dat += "[GLOB.round_statistics.hunter_silence_targets] number of targets silenced by Hunters."
	if(GLOB.round_statistics.larva_from_psydrain)
		dat += "[GLOB.round_statistics.larva_from_psydrain] larvas came from psydrain."
	if(GLOB.round_statistics.larva_from_silo)
		dat += "[GLOB.round_statistics.larva_from_silo] larvas came from silos."
	if(GLOB.round_statistics.larva_from_cocoon)
		dat += "[GLOB.round_statistics.larva_from_cocoon] larvas came from cocoons."
	if(GLOB.round_statistics.larva_from_marine_spawning)
		dat += "[GLOB.round_statistics.larva_from_marine_spawning] larvas came from marine spawning."
	if(GLOB.round_statistics.larva_from_siloing_body)
		dat += "[GLOB.round_statistics.larva_from_siloing_body] larvas came from siloing bodies."
	if(GLOB.round_statistics.points_from_research)
		dat += "[GLOB.round_statistics.points_from_research] requisitions points gained from research."
	if(length(GLOB.round_statistics.req_items_produced))
		var/produced = "Requisitions produced: "
		for(var/atom/movable/path AS in GLOB.round_statistics.req_items_produced)
			produced += "[GLOB.round_statistics.req_items_produced[path]] [initial(path.name)]"
			if(path == GLOB.round_statistics.req_items_produced[length(GLOB.round_statistics.req_items_produced)]) //last element
				produced += "."
			else
				produced += ","

	var/output = jointext(dat, "<br>")
	for(var/mob/player in GLOB.player_list)
		if(player?.client?.prefs?.toggles_chat & CHAT_STATISTICS)
			to_chat(player, output)


/datum/game_mode/proc/count_humans_and_xenos(list/z_levels = SSmapping.levels_by_any_trait(list(ZTRAIT_MARINE_MAIN_SHIP, ZTRAIT_GROUND, ZTRAIT_RESERVED)), count_flags)
	var/num_humans = 0
	var/num_humans_ship = 0
	var/num_xenos = 0

	for(var/z in z_levels)
		for(var/i in GLOB.humans_by_zlevel["[z]"])
			var/mob/living/carbon/human/H = i
			if(!istype(H)) // Small fix?
				continue
			if(count_flags & COUNT_IGNORE_HUMAN_SSD && !H.client && H.afk_status == MOB_DISCONNECTED)
				continue
			if(H.status_flags & XENO_HOST)
				continue
			if(H.faction == FACTION_XENO)
				continue
			if(isspaceturf(H.loc))
				continue
			num_humans++
			if (is_mainship_level(z))
				num_humans_ship++

	for(var/z in z_levels)
		for(var/i in GLOB.hive_datums[XENO_HIVE_NORMAL].xenos_by_zlevel["[z]"])
			var/mob/living/carbon/xenomorph/X = i
			if(!istype(X)) // Small fix?
				continue
			if(count_flags & COUNT_IGNORE_XENO_SSD && !X.client && X.afk_status == MOB_DISCONNECTED)
				continue
			if(count_flags & COUNT_IGNORE_XENO_SPECIAL_AREA && is_xeno_in_forbidden_zone(X))
				continue
			if(isspaceturf(X.loc))
				continue
			if(X.xeno_caste.upgrade == XENO_UPGRADE_BASETYPE) //Ais don't count
				continue
			// Never count hivemind
			if(isxenohivemind(X))
				continue

			num_xenos++

	return list(num_humans, num_xenos, num_humans_ship)

/datum/game_mode/proc/get_total_joblarvaworth(list/z_levels = SSmapping.levels_by_any_trait(list(ZTRAIT_MARINE_MAIN_SHIP, ZTRAIT_GROUND, ZTRAIT_RESERVED)), count_flags)
	. = 0

	for(var/i in GLOB.human_mob_list)
		var/mob/living/carbon/human/H = i
		if(!H.job)
			continue
		if(H.stat == DEAD && !H.has_working_organs())
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
	if(round_stage == INFESTATION_MARINE_CRASHING)
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
	deadchat_broadcast(span_game(" has woken at [span_name("[A?.name]")]."), span_game("[span_name("[player.new_character.real_name]")] ([job.title])"), follow_target = player.new_character, message_type = DEADCHAT_ARRIVALRATTLE)
	qdel(player)

/datum/game_mode/proc/attempt_to_join_as_larva(mob/xeno_candidate)
	to_chat(xeno_candidate, span_warning("This is unavailable in this gamemode."))
	return FALSE


/datum/game_mode/proc/spawn_larva(mob/xeno_candidate)
	to_chat(xeno_candidate, span_warning("This is unavailable in this gamemode."))
	return FALSE

/datum/game_mode/proc/set_valid_job_types()
	if(!SSjob?.initialized)
		to_chat(world, span_boldnotice("Error setting up valid jobs, no job subsystem found initialized."))
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
		to_chat(world, span_boldnotice("Error, game mode has only invalid jobs assigned."))
		return FALSE
	SSjob.active_joinable_occupations = SSjob.active_occupations.Copy()
	SSjob.set_active_joinable_occupations_by_category()
	return TRUE

///If joining the job.faction will make the game too unbalanced, return FALSE
/datum/game_mode/proc/is_faction_balanced(datum/job/job)
	return TRUE

/datum/game_mode/proc/set_valid_squads()
	var/max_squad_num = min(squads_max_number, SSmapping.configs[SHIP_MAP].squads_max_num)
	SSjob.active_squads[FACTION_TERRAGOV] = list()
	if(max_squad_num == 0)
		return TRUE
	var/list/preferred_squads = list()
	for(var/key in shuffle(SSjob.squads))
		var/datum/squad/squad = SSjob.squads[key]
		if(squad.faction == FACTION_TERRAGOV)
			preferred_squads[squad.name] = 0
	if(!length(preferred_squads))
		to_chat(world, span_boldnotice("Error, no squads found."))
		return FALSE
	for(var/mob/new_player/player AS in GLOB.new_player_list)
		if(!player.ready || !player.client?.prefs?.preferred_squad)
			continue
		var/squad_choice = player.client.prefs.preferred_squad
		if(squad_choice == "None")
			continue
		if(isnull(preferred_squads[squad_choice]))
			stack_trace("[player.client] has in its prefs [squad_choice] for a squad. Not valid.")
			continue
		preferred_squads[squad_choice]++
	sortTim(preferred_squads, cmp=/proc/cmp_numeric_dsc, associative = TRUE)

	preferred_squads.len = max_squad_num
	SSjob.active_squads[FACTION_TERRAGOV] = list()
	for(var/name in preferred_squads) //Back from weight to instantiate var
		SSjob.active_squads[FACTION_TERRAGOV] += LAZYACCESSASSOC(SSjob.squads_by_name, FACTION_TERRAGOV, name)
	return TRUE


/datum/game_mode/proc/scale_roles()
	if(SSjob.ssjob_flags & SSJOB_OVERRIDE_JOBS_START)
		return FALSE
	if(length(SSjob.active_squads[FACTION_TERRAGOV]))
		scale_squad_jobs()
	return TRUE

/datum/game_mode/proc/scale_squad_jobs()
	var/datum/job/scaled_job = SSjob.GetJobType(/datum/job/terragov/squad/leader)
	scaled_job.total_positions = length(SSjob.active_squads[FACTION_TERRAGOV])

///Return the list of joinable factions, with regards with the current round balance
/datum/game_mode/proc/get_joinable_factions(should_look_balance)
	return
