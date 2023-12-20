#define PERSONAL_LAST_ROUND "personal last round"
#define SERVER_LAST_ROUND "server last round"

GLOBAL_VAR(common_report) //Contains common part of roundend report

/datum/game_mode
	var/name = ""
	var/config_tag = null
	var/votable = TRUE
	var/required_players = 0
	var/maximum_players = INFINITY
	var/squads_max_number = 4

	var/round_finished
	var/list/round_end_states = list()
	var/list/valid_job_types = list()
	var/list/job_points_needed_by_job_type = list()

	var/round_time_fog
	var/flags_round_type = NONE
	var/flags_xeno_abilities = NONE

	///Determines whether rounds with the gamemode will be factored in when it comes to persistency
	var/allow_persistence_save = TRUE

	var/distress_cancelled = FALSE

	var/deploy_time_lock = 15 MINUTES
	///The respawn time for marines
	var/respawn_time = 30 MINUTES
	//The respawn time for Xenomorphs
	var/xenorespawn_time = 5 MINUTES
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
	///What factions are used in this gamemode, typically TGMC and xenos
	var/list/factions = list(FACTION_TERRAGOV, FACTION_ALIEN)

//Distress call variables.
	var/list/datum/emergency_call/all_calls = list() //initialized at round start and stores the datums.
	var/datum/emergency_call/picked_call = null //Which distress call is currently active
	var/on_distress_cooldown = FALSE
	var/waiting_for_candidates = FALSE
	/// Ponderation rate of silos output. 1 is normal, 2 is twice
	var/silo_scaling = 1

	///If the gamemode has a whitelist of valid ship maps. Whitelist overrides the blacklist
	var/list/whitelist_ship_maps
	///If the gamemode has a blacklist of disallowed ship maps
	var/list/blacklist_ship_maps = list(MAP_COMBAT_PATROL_BASE, MAP_ITERON)
	///If the gamemode has a whitelist of valid ground maps. Whitelist overrides the blacklist
	var/list/whitelist_ground_maps
	///If the gamemode has a blacklist of disallowed ground maps
	var/list/blacklist_ground_maps = list(MAP_DELTA_STATION, MAP_PRISON_STATION, MAP_LV_624, MAP_WHISKEY_OUTPOST, MAP_OSCAR_OUTPOST, MAP_FORT_PHOBOS)
	///if fun tads are enabled by default
	var/enable_fun_tads = FALSE


/datum/game_mode/New()
	initialize_emergency_calls()


/datum/game_mode/proc/announce()
	return TRUE


/datum/game_mode/proc/can_start(bypass_checks = FALSE)
	if(!(config_tag in SSmapping.configs[GROUND_MAP].gamemodes) && !bypass_checks)
		log_world("attempted to start [src.type] on "+SSmapping.configs[GROUND_MAP].map_name+" which doesn't support it.")
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


/datum/game_mode/proc/pre_setup()
	setup_blockers()
	GLOB.balance.Initialize()
	RegisterSignal(SSdcs, COMSIG_GLOB_MOB_GET_STATUS_TAB_ITEMS, PROC_REF(get_status_tab_items))

	GLOB.landmarks_round_start = shuffle(GLOB.landmarks_round_start)
	var/obj/effect/landmark/L
	while(length(GLOB.landmarks_round_start))
		L = GLOB.landmarks_round_start[length(GLOB.landmarks_round_start)]
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

///Gamemode setup run after the game has started
/datum/game_mode/proc/post_setup()
	addtimer(CALLBACK(src, PROC_REF(display_roundstart_logout_report)), ROUNDSTART_LOGOUT_REPORT_TIME)
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
		living.client.init_verbs()
		living.notransform = TRUE
		log_manifest(living.ckey, living.mind, living)
		livings += living

	if(length(livings))
		addtimer(CALLBACK(src, PROC_REF(release_characters), livings), 1 SECONDS, TIMER_CLIENT_TIME)

/datum/game_mode/proc/release_characters(list/livings)
	for(var/I in livings)
		var/mob/living/L = I
		L.notransform = FALSE


/datum/game_mode/proc/check_finished()
	if(SSevacuation.dest_status == NUKE_EXPLOSION_FINISHED)
		return TRUE


/datum/game_mode/proc/declare_completion()
	to_chat(world, span_round_body("Thus ends the story of the brave men and women of the [SSmapping.configs[SHIP_MAP].map_name] and their struggle on [SSmapping.configs[GROUND_MAP].map_name]."))
	log_game("The round has ended.")
	SSdbcore.SetRoundEnd()
	if(time_between_round)
		SSpersistence.last_modes_round_date[name] = world.realtime
	//Collects persistence features
	if(allow_persistence_save)
		SSpersistence.CollectData()
	display_report()
	addtimer(CALLBACK(src, PROC_REF(end_of_round_deathmatch)), ROUNDEND_EORG_DELAY)
	//end_of_round_deathmatch()
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
/datum/game_mode/proc/announce_bioscans(show_locations = TRUE, delta = 2, ai_operator = FALSE, announce_humans = TRUE, announce_xenos = TRUE, send_fax = TRUE)
	return

/datum/game_mode/proc/setup_blockers()
	set waitfor = FALSE

	if(flags_round_type & MODE_LATE_OPENING_SHUTTER_TIMER)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(send_global_signal), COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE), SSticker.round_start_time + shutters_drop_time)
			//Called late because there used to be shutters opened earlier. To re-add them just copy the logic.

	if(flags_round_type & MODE_XENO_SPAWN_PROTECT)
		var/turf/T
		while(length(GLOB.xeno_spawn_protection_locations))
			T = GLOB.xeno_spawn_protection_locations[length(GLOB.xeno_spawn_protection_locations)]
			GLOB.xeno_spawn_protection_locations.len--
			new /obj/effect/forcefield/fog(T)
			stoplag()

///respawns the player, overrides verb respawn behavior as required
/datum/game_mode/proc/player_respawn(mob/respawnee)
	respawnee.respawn()

/datum/game_mode/proc/grant_eord_respawn(datum/dcs, mob/source)
	SIGNAL_HANDLER
	add_verb(source, /mob/proc/eord_respawn)

/datum/game_mode/proc/end_of_round_deathmatch()
	RegisterSignal(SSdcs, COMSIG_GLOB_MOB_LOGIN, PROC_REF(grant_eord_respawn)) // New mobs can now respawn into EORD
	var/list/spawns = GLOB.deathmatch.Copy()

	CONFIG_SET(flag/allow_synthetic_gun_use, TRUE)

	if(!length(spawns))
		to_chat(world, "<br><br><h1>[span_danger("End of Round Deathmatch initialization failed, please do not grief.")]</h1><br><br>")
		return

	for(var/i in GLOB.player_list)
		var/mob/M = i
		add_verb(M, /mob/proc/eord_respawn)
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

		if(isxeno(M))
			var/mob/living/carbon/xenomorph/X = M
			X.transfer_to_hive(pick(XENO_HIVE_NORMAL, XENO_HIVE_CORRUPTED, XENO_HIVE_ALPHA, XENO_HIVE_BETA, XENO_HIVE_ZETA))
			INVOKE_ASYNC(X, TYPE_PROC_REF(/atom/movable, forceMove), picked)

		else if(ishuman(M))
			var/mob/living/carbon/human/H = M
			do_eord_respawn(H)

		M.on_eord(picked)
		to_chat(M, "<br><br><h1>[span_danger("Fight for your life!")]</h1><br><br>")
		CHECK_TICK

	for(var/obj/effect/landmark/eord_roomba/landmark in GLOB.eord_roomba_spawns)
		new /obj/machinery/bot/roomba/valhalla/eord(get_turf(landmark))

/datum/game_mode/proc/orphan_hivemind_collapse()
	return

/datum/game_mode/proc/get_hivemind_collapse_countdown()
	return

///Provides the amount of time left before the game ends, used for the stat panel
/datum/game_mode/proc/game_end_countdown()
	return

///Provides the amount of time left before the next respawn wave, used for the stat panel
/datum/game_mode/proc/wave_countdown()
	return

/datum/game_mode/proc/announce_medal_awards()
	if(!length(GLOB.medal_awards))
		return

	var/list/parts = list()

	for(var/recipient in GLOB.medal_awards)
		var/datum/recipient_awards/RA = GLOB.medal_awards[recipient]
		for(var/i in 1 to length(RA.medal_names))
			parts += "<br><b>[RA.recipient_rank] [recipient]</b> is awarded [RA.posthumous[i] ? "posthumously " : ""]the [span_boldnotice("[RA.medal_names[i]]")]: \'<i>[RA.medal_citations[i]]</i>\'."

	if(length(parts))
		return "<div class='panel stationborder'>[parts.Join("<br>")]</div>"
	else
		return ""



/datum/game_mode/proc/announce_round_stats()
	var/list/parts = list({"[span_round_body("The end of round statistics are:")]<br>
		<br>There were [GLOB.round_statistics.total_projectiles_fired[FACTION_TERRAGOV]] total projectiles fired.
		<br>[GLOB.round_statistics.total_projectile_hits[FACTION_TERRAGOV] ? GLOB.round_statistics.total_projectile_hits[FACTION_TERRAGOV] : "No"] projectiles managed to hit marines. For a [(GLOB.round_statistics.total_projectile_hits[FACTION_TERRAGOV] / max(GLOB.round_statistics.total_projectiles_fired[FACTION_TERRAGOV], 1)) * 100]% friendly fire rate!"})
	if(GLOB.round_statistics.total_projectile_hits[FACTION_XENO])
		parts += "[GLOB.round_statistics.total_projectile_hits[FACTION_XENO]] projectiles managed to hit xenomorphs. For a [(GLOB.round_statistics.total_projectile_hits[FACTION_XENO] / max(GLOB.round_statistics.total_projectiles_fired[FACTION_TERRAGOV], 1)) * 100]% accuracy total!"
	if(GLOB.round_statistics.grenades_thrown)
		parts += "[GLOB.round_statistics.grenades_thrown] total grenades exploding."
	else
		parts += "No grenades exploded."
	if(GLOB.round_statistics.mortar_shells_fired)
		parts += "[GLOB.round_statistics.mortar_shells_fired] mortar shells were fired."
	if(GLOB.round_statistics.howitzer_shells_fired)
		parts += "[GLOB.round_statistics.howitzer_shells_fired] howitzer shells were fired."
	if(GLOB.round_statistics.rocket_shells_fired)
		parts += "[GLOB.round_statistics.rocket_shells_fired] rocket artillery shells were fired."
	if(GLOB.round_statistics.total_human_deaths[FACTION_TERRAGOV])
		parts += "[GLOB.round_statistics.total_human_deaths[FACTION_TERRAGOV]] people were killed, among which [GLOB.round_statistics.total_human_revives[FACTION_TERRAGOV]] were revived and [GLOB.round_statistics.total_human_respawns] respawned. For a [(GLOB.round_statistics.total_human_revives[FACTION_TERRAGOV] / max(GLOB.round_statistics.total_human_deaths[FACTION_TERRAGOV], 1)) * 100]% revival rate and a [(GLOB.round_statistics.total_human_respawns / max(GLOB.round_statistics.total_human_deaths[FACTION_TERRAGOV], 1)) * 100]% respawn rate."
	if(SSevacuation.human_escaped)
		parts += "[SSevacuation.human_escaped] marines manage to evacuate, among [SSevacuation.initial_human_on_ship] that were on ship when xenomorphs arrived."
	if(GLOB.round_statistics.now_pregnant)
		parts += "[GLOB.round_statistics.now_pregnant] people infected among which [GLOB.round_statistics.total_larva_burst] burst. For a [(GLOB.round_statistics.total_larva_burst / max(GLOB.round_statistics.now_pregnant, 1)) * 100]% successful delivery rate!"
	if(length(GLOB.round_statistics.workout_counts))
		for(var/faction in GLOB.round_statistics.workout_counts)
			parts += "The [faction] faction did [GLOB.round_statistics.workout_counts[faction]] workout sets."
	if(GLOB.round_statistics.queen_screech)
		parts += "[GLOB.round_statistics.queen_screech] Queen screeches."
	if(GLOB.round_statistics.warrior_lunges)
		parts += "[GLOB.round_statistics.warrior_lunges] Warriors lunges."
	if(GLOB.round_statistics.crusher_stomp_victims)
		parts += "[GLOB.round_statistics.crusher_stomp_victims] people stomped by crushers."
	if(GLOB.round_statistics.praetorian_spray_direct_hits)
		parts += "[GLOB.round_statistics.praetorian_spray_direct_hits] people hit directly by Praetorian acid spray."
	if(GLOB.round_statistics.weeds_planted)
		parts += "[GLOB.round_statistics.weeds_planted] weed nodes planted."
	if(GLOB.round_statistics.weeds_destroyed)
		parts += "[GLOB.round_statistics.weeds_destroyed] weed tiles removed."
	if(GLOB.round_statistics.trap_holes)
		parts += "[GLOB.round_statistics.trap_holes] holes for acid and huggers were made."
	if(GLOB.round_statistics.sentinel_drain_stings)
		parts += "[GLOB.round_statistics.sentinel_drain_stings] number of times sentinel drain sting was used."
	if(GLOB.round_statistics.sentinel_neurotoxin_stings)
		parts += "[GLOB.round_statistics.sentinel_neurotoxin_stings] number of times neurotoxin sting was used."
	if(GLOB.round_statistics.ozelomelyn_stings)
		parts += "[GLOB.round_statistics.ozelomelyn_stings] number of times ozelomelyn sting was used."
	if(GLOB.round_statistics.defiler_defiler_stings)
		parts += "[GLOB.round_statistics.defiler_defiler_stings] number of times Defilers stung."
	if(GLOB.round_statistics.defiler_neurogas_uses)
		parts += "[GLOB.round_statistics.defiler_neurogas_uses] number of times Defilers vented neurogas."
	if(GLOB.round_statistics.defiler_reagent_slashes)
		parts += "[GLOB.round_statistics.defiler_reagent_slashes] number of times Defilers struck an enemy with their reagent slash."
	if(GLOB.round_statistics.xeno_unarmed_attacks && GLOB.round_statistics.xeno_bump_attacks)
		parts += "[GLOB.round_statistics.xeno_bump_attacks] bump attacks, which made up [(GLOB.round_statistics.xeno_bump_attacks / GLOB.round_statistics.xeno_unarmed_attacks) * 100]% of all attacks ([GLOB.round_statistics.xeno_unarmed_attacks])."
	if(GLOB.round_statistics.xeno_rally_hive)
		parts += "[GLOB.round_statistics.xeno_rally_hive] number of times xeno leaders rallied the hive."
	if(GLOB.round_statistics.hivelord_healing_infusions)
		parts += "[GLOB.round_statistics.hivelord_healing_infusions] number of times Hivelords used Healing Infusion."
	if(GLOB.round_statistics.spitter_acid_sprays)
		parts += "[GLOB.round_statistics.spitter_acid_sprays] number of times Spitters spewed an Acid Spray."
	if(GLOB.round_statistics.spitter_scatter_spits)
		parts += "[GLOB.round_statistics.spitter_scatter_spits] number of times Spitters horked up scatter spits."
	if(GLOB.round_statistics.ravager_endures)
		parts += "[GLOB.round_statistics.ravager_endures] number of times Ravagers used Endure."
	if(GLOB.round_statistics.bull_crush_hit)
		parts += "[GLOB.round_statistics.bull_crush_hit] number of times Bulls crushed marines."
	if(GLOB.round_statistics.bull_gore_hit)
		parts += "[GLOB.round_statistics.bull_gore_hit] number of times Bulls gored marines."
	if(GLOB.round_statistics.bull_headbutt_hit)
		parts += "[GLOB.round_statistics.bull_headbutt_hit] number of times Bulls headbutted marines."
	if(GLOB.round_statistics.hunter_marks)
		parts += "[GLOB.round_statistics.hunter_marks] number of times Hunters marked a target for death."
	if(GLOB.round_statistics.ravager_rages)
		parts += "[GLOB.round_statistics.ravager_rages] number of times Ravagers raged."
	if(GLOB.round_statistics.hunter_silence_targets)
		parts += "[GLOB.round_statistics.hunter_silence_targets] number of targets silenced by Hunters."
	if(GLOB.round_statistics.larva_from_psydrain)
		parts += "[GLOB.round_statistics.larva_from_psydrain] larvas came from psydrain."
	if(GLOB.round_statistics.larva_from_silo)
		parts += "[GLOB.round_statistics.larva_from_silo] larvas came from silos."
	if(GLOB.round_statistics.larva_from_cocoon)
		parts += "[GLOB.round_statistics.larva_from_cocoon] larvas came from cocoons."
	if(GLOB.round_statistics.larva_from_marine_spawning)
		parts += "[GLOB.round_statistics.larva_from_marine_spawning] larvas came from marine spawning."
	if(GLOB.round_statistics.larva_from_siloing_body)
		parts += "[GLOB.round_statistics.larva_from_siloing_body] larvas came from siloing bodies."
	if(GLOB.round_statistics.psy_crushes)
		parts += "[GLOB.round_statistics.psy_crushes] number of times Warlocks used Psychic Crush."
	if(GLOB.round_statistics.psy_blasts)
		parts += "[GLOB.round_statistics.psy_blasts] number of times Warlocks used Psychic Blast."
	if(GLOB.round_statistics.psy_lances)
		parts += "[GLOB.round_statistics.psy_lances] number of times Warlocks used Psychic Lance."
	if(GLOB.round_statistics.psy_shields)
		parts += "[GLOB.round_statistics.psy_shields] number of times Warlocks used Psychic Shield."
	if(GLOB.round_statistics.psy_shield_blasts)
		parts += "[GLOB.round_statistics.psy_shield_blasts] number of times Warlocks detonated a Psychic Shield."
	if(GLOB.round_statistics.points_from_mining)
		parts += "[GLOB.round_statistics.points_from_mining] requisitions points gained from mining."
	if(GLOB.round_statistics.points_from_research)
		parts += "[GLOB.round_statistics.points_from_research] requisitions points gained from research."
	if(length(GLOB.round_statistics.req_items_produced))
		parts += "Requisitions produced: "
		for(var/atom/movable/path AS in GLOB.round_statistics.req_items_produced)
			parts += "[GLOB.round_statistics.req_items_produced[path]] [initial(path.name)]"
			if(path == GLOB.round_statistics.req_items_produced[length(GLOB.round_statistics.req_items_produced)]) //last element
				parts += "."
			else
				parts += ","

	if(length(parts))
		return "<div class='panel stationborder'>[parts.Join("<br>")]</div>"
	else
		return ""


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

/datum/game_mode/proc/CanLateSpawn(mob/new_player/NP, datum/job/job)
	if(!isnewplayer(NP))
		return FALSE
	if(!NP.IsJobAvailable(job, TRUE))
		to_chat(usr, "<span class='warning'>Selected job is not available.<spawn>")
		return FALSE
	if(!SSticker || SSticker.current_state != GAME_STATE_PLAYING)
		to_chat(usr, "<span class='warning'>The round is either not ready, or has already finished!<spawn>")
		return FALSE
	if(!GLOB.enter_allowed || (!GLOB.xeno_enter_allowed && istype(job, /datum/job/xenomorph)))
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
	player.mind.transfer_to(player.new_character, TRUE)
	log_manifest(player.new_character.ckey, player.new_character.mind, player.new_character, latejoin = TRUE)
	var/datum/job/job = player.assigned_role
	job.on_late_spawn(player.new_character)
	player.new_character.client?.init_verbs()
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
	for(var/job_type in job_points_needed_by_job_type)
		if(!(job_type in subtypesof(/datum/job)))
			stack_trace("Invalid job type in job_points_needed_by_job_type. Current mode : [name], Invalid type: [job_type]")
			continue
		var/datum/job/scaled_job = SSjob.GetJobType(job_type)
		scaled_job.job_points_needed = job_points_needed_by_job_type[job_type]
	return TRUE

/datum/game_mode/proc/scale_squad_jobs()
	var/datum/job/scaled_job = SSjob.GetJobType(/datum/job/terragov/squad/leader)
	scaled_job.total_positions = length(SSjob.active_squads[FACTION_TERRAGOV])

///Return the list of joinable factions, with regards with the current round balance
/datum/game_mode/proc/get_joinable_factions(should_look_balance)
	return

/datum/game_mode/proc/display_report()
	GLOB.common_report = build_roundend_report()
	log_roundend_report()
	for(var/client/C in GLOB.clients)
		show_roundend_report(C)
		give_show_report_button(C)
		CHECK_TICK

/datum/game_mode/proc/build_roundend_report()
	var/list/parts = list()

	parts += antag_report()

	parts += announce_round_stats()
	parts += announce_xenomorphs()
	CHECK_TICK

	//Medals
	parts += announce_medal_awards()

	list_clear_nulls(parts)

	return parts.Join()

/datum/game_mode/proc/show_roundend_report(client/C, report_type = null)
	var/datum/browser/roundend_report = new(C, "roundend")
	roundend_report.width = 800
	roundend_report.height = 600
	var/content
	var/filename = C.roundend_report_file()
	if(report_type == PERSONAL_LAST_ROUND) //Look at this player's last round
		content = file2text(filename)
	else if(report_type == SERVER_LAST_ROUND) //Look at the last round that this server has seen
		content = file2text("data/server_last_roundend_report.html")
	else //report_type is null, so make a new report based on the current round and show that to the player
		var/list/report_parts = list(personal_report(C), GLOB.common_report)
		content = report_parts.Join()
		fdel(filename)
		text2file(content, filename)

	roundend_report.set_content(content)
	roundend_report.stylesheets = list()
	roundend_report.add_stylesheet("roundend", 'html/browser/roundend.css')
	roundend_report.add_stylesheet("font-awesome", 'html/font-awesome/css/all.min.css')
	roundend_report.open(FALSE)

///displays personalized round end data to each client listing survival status
/datum/game_mode/proc/personal_report(client/C, popcount)
	var/list/parts = list()
	var/mob/M = C.mob
	//Always display that the round ended
	parts += span_round_header("<span class='body' style=font-size:20px;text-align:center valign='top'>Round Complete:[round_finished]</span>")
	if(M.mind && !isnewplayer(M))
		if(M.stat != DEAD && !isbrain(M))
			if(ishuman(M))
				var/turf/current_turf = get_turf(M)
				if(!is_mainship_level(current_turf.z) && (round_finished == MODE_INFESTATION_X_MINOR))
					parts += "<div class='panel stationborder'>"
					parts += "<span class='marooned'>You managed to survive, but were marooned on [SSmapping.configs[GROUND_MAP].map_name]...</span>"
				else if(!is_mainship_level(current_turf.z) && (round_finished == MODE_INFESTATION_X_MAJOR))
					parts += "<div class='panel stationborder'>"
					parts += "<span class='marooned'>You managed to survive, but were marooned on [SSmapping.configs[GROUND_MAP].map_name]...</span>"
				else
					parts += "<div class='panel greenborder'>"
					parts += span_greentext("You managed to survive the events on [SSmapping.configs[GROUND_MAP].map_name] as [M.real_name].")
			else
				parts += "<div class='panel greenborder'>"
				parts += span_greentext("You managed to survive the events on [SSmapping.configs[GROUND_MAP].map_name] as [M.real_name].")

		else
			parts += "<div class='panel redborder'>"
			parts += span_redtext("You did not survive the events on [SSmapping.configs[GROUND_MAP].map_name]...")
		if(GLOB.personal_statistics_list[C.ckey])
			var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[C.ckey]
			parts += personal_statistics.compose_report()
	else
		parts += "<div class='panel stationborder'>"
	parts += "<br>"
	parts += "</div>"

	return parts.Join()

/datum/game_mode/proc/log_roundend_report()
	var/roundend_file = file("[GLOB.log_directory]/round_end_data.html")
	var/list/parts = list()
	parts += "<div class='panel stationborder'>"
	parts += "</div>"
	parts += GLOB.common_report

	var/content = parts.Join()
	//Log the rendered HTML in the round log directory
	fdel(roundend_file)
	WRITE_FILE(roundend_file, content)
	//Place a copy in the root folder, to be overwritten each round.
	roundend_file = file("data/server_last_roundend_report.html")
	fdel(roundend_file)
	WRITE_FILE(roundend_file, content)

/datum/game_mode/proc/give_show_report_button(client/C)
	var/datum/action/report/R = new
	C.player_details.player_actions += R
	R.give_action(C.mob)
	to_chat(C,"<span class='infoplain'><a href='?src=[REF(R)];report=1'>Show roundend report again</a></span>")

/datum/action/report
	name = "Show roundend report"
	action_icon_state = "end_round"

/datum/action/report/action_activate()
	if(owner && GLOB.common_report && SSticker.current_state == GAME_STATE_FINISHED)
		var/datum/game_mode/A = SSticker.mode
		A.show_roundend_report(owner.client, PERSONAL_LAST_ROUND)

/client/proc/roundend_report_file()
	return "data/[ckey].html"

/datum/game_mode/proc/announce_xenomorphs()
	var/list/parts = list()
	var/datum/hive_status/normal/HN = GLOB.hive_datums[XENO_HIVE_NORMAL]
	if(!HN.living_xeno_ruler)
		return

	parts += span_round_body("The surviving xenomorph ruler was:<br>[HN.living_xeno_ruler.key] as [span_boldnotice("[HN.living_xeno_ruler]")]")

	if(length(parts))
		return "<div class='panel stationborder'>[parts.Join("<br>")]</div>"
	else
		return ""

/datum/game_mode/proc/gather_antag_data()
	for(var/datum/antagonist/A in GLOB.antagonists)
		if(!A.owner)
			continue
		var/list/antag_info = list()
		antag_info["key"] = A.owner.key
		antag_info["name"] = A.owner.name
		antag_info["antagonist_type"] = A.type
		antag_info["antagonist_name"] = A.name //For auto and custom roles
		antag_info["objectives"] = list()
		if(length(A.objectives))
			for(var/datum/objective/O in A.objectives)
				var/result = O.check_completion() ? "SUCCESS" : "FAIL"
				antag_info["objectives"] += list(list("objective_type"=O.type,"text"=O.explanation_text,"result"=result))
		SSblackbox.record_feedback("associative", "antagonists", 1, antag_info)

/proc/printobjectives(list/objectives)
	if(!objectives || !length(objectives))
		return
	var/list/objective_parts = list()
	var/count = 1
	for(var/datum/objective/objective in objectives)
		if(objective.check_completion())
			objective_parts += "<b>[objective.objective_name] #[count]</b>: [objective.explanation_text] [span_greentext("Success!")]"
		else
			objective_parts += "<b>[objective.objective_name] #[count]</b>: [objective.explanation_text] [span_redtext("Fail.")]"
		count++
	return objective_parts.Join("<br>")

/proc/printplayer(datum/mind/ply, fleecheck)
	var/text = "<b>[ply.key]</b> was <b>[ply.name]</b> and"
	if(ply.current)
		if(ply.current.stat == DEAD)
			text += " [span_redtext("died")]"
		else
			text += " [span_greentext("survived")]"
		if(fleecheck)
			var/turf/T = get_turf(ply.current)
			if(!T || !is_station_level(T.z))
				text += " while [span_redtext("fleeing the station")]"
		if(ply.current.real_name != ply.name)
			text += " as <b>[ply.current.real_name]</b>"
	else
		text += " [span_redtext("had their body destroyed")]"
	return text

/datum/game_mode/proc/antag_report()
	var/list/result = list()
	var/list/all_antagonists = list()
	for(var/datum/antagonist/A in GLOB.antagonists)
		if(!A.owner)
			continue
		all_antagonists |= A
	var/currrent_category
	var/datum/antagonist/previous_category
	sortTim(all_antagonists, GLOBAL_PROC_REF(cmp_antag_category))
	for(var/datum/antagonist/A in all_antagonists)
		if(!A.show_in_roundend)
			continue
		if(A.roundend_category != currrent_category)
			if(previous_category)
				result += previous_category.roundend_report_footer()
				result += "</div>"
			result += "<div class='panel redborder'>"
			result += A.roundend_report_header()
			currrent_category = A.roundend_category
			previous_category = A
		result += A.roundend_report()
		result += "<br><br>"
		CHECK_TICK
	if(length(all_antagonists))
		var/datum/antagonist/last = all_antagonists[length(all_antagonists)]
		result += last.roundend_report_footer()
		result += "</div>"
	return result.Join()

/proc/cmp_antag_category(datum/antagonist/A,datum/antagonist/B)
	return sorttext(B.roundend_category,A.roundend_category)

///Generates nuke disk consoles from a list of valid locations
/datum/game_mode/proc/generate_nuke_disk_spawners()
	if(!length(SSmapping.configs[GROUND_MAP].disk_sets))
		CRASH("Map Json invalid for generating nuke disks on this map - set up at least one disk set in it. Have you tried \"basic\", assuming only one disk set exists?")
	var/chosen_disk_set = pickweight(SSmapping.configs[GROUND_MAP].disk_sets)
	var/list/viable_disks = list()
	var/list/forced_disks = list()
	for(var/obj/structure/nuke_disk_candidate/candidate AS in GLOB.nuke_disk_spawn_locs)
		if(chosen_disk_set in candidate.set_associations)
			if(chosen_disk_set in candidate.force_for_sets)
				forced_disks += candidate
			else
				viable_disks += candidate
	if((length(viable_disks) + length(forced_disks)) < length(GLOB.nuke_disk_generator_types)) //Lets in maps with > 3 disks for a given set and just behaves like the previous rng in that case.
		CRASH("Warning: Current map has too few nuke disk generators to correctly generate disks for set \">[chosen_disk_set]<\". Make sure both generators and json are set up correctly.")
	if(length(forced_disks) > length(GLOB.nuke_disk_generator_types))
		CRASH("Warning: Current map has too many forced disks for the current set type \">[chosen_disk_set]<\". Amount is [length(forced_disks)]. Please revisit your disk candidates.")
	for(var/obj/machinery/computer/nuke_disk_generator AS in GLOB.nuke_disk_generator_types)
		var/spawn_loc
		if(length(forced_disks))
			spawn_loc = pick_n_take(forced_disks)
		else
			spawn_loc = pick_n_take(viable_disks)
		new nuke_disk_generator(get_turf(spawn_loc))
		qdel(spawn_loc)

/// Add gamemode related items to statpanel
/datum/game_mode/proc/get_status_tab_items(datum/dcs, mob/source, list/items)
	SIGNAL_HANDLER
	var/patrol_end_countdown = game_end_countdown()
	if(patrol_end_countdown)
		items += "Round End timer: [patrol_end_countdown]"
	var/patrol_wave_countdown = wave_countdown()
	if(patrol_wave_countdown)
		items += "Respawn wave timer: [patrol_wave_countdown]"

	if (isobserver(source) || isxeno(source))
		handle_collapse_timer(dcs, source, items)

	if (source.can_wait_in_larva_queue())
		handle_larva_timer(dcs, source, items)
		handle_xeno_respawn_timer(dcs, source, items)

/// Displays the orphan hivemind collapse timer, if applicable
/datum/game_mode/proc/handle_collapse_timer(datum/dcs, mob/source, list/items)
	if (isxeno(source))
		var/mob/living/carbon/xenomorph/xeno = source
		if(xeno.hivenumber != XENO_HIVE_NORMAL)
			return // Don't show for non-normal hives
	var/rulerless_countdown = get_hivemind_collapse_countdown()
	if(rulerless_countdown)
		items += "Orphan hivemind collapse timer: [rulerless_countdown]"

/// Displays your position in the larva queue and how many burrowed larva there are, if applicable
/datum/game_mode/proc/handle_larva_timer(datum/dcs, mob/source, list/items)
	if(!(flags_round_type & MODE_INFESTATION))
		return
	var/larva_position = SEND_SIGNAL(source.client, COMSIG_CLIENT_GET_LARVA_QUEUE_POSITION)
	if (larva_position) // If non-zero, we're in queue
		items += "Position in larva candidate queue: [larva_position]"

	var/datum/job/xeno_job = SSjob.GetJobType(/datum/job/xenomorph)
	var/stored_larva = xeno_job.total_positions - xeno_job.current_positions
	if(stored_larva)
		items += "Burrowed larva: [stored_larva]"

/// Displays your xeno respawn timer, if applicable
/datum/game_mode/proc/handle_xeno_respawn_timer(datum/dcs, mob/source, list/items)
	if(GLOB.respawn_allowed)
		var/status_value = ((GLOB.key_to_time_of_xeno_death[source.key] ? GLOB.key_to_time_of_xeno_death[source.key] : -INFINITY)  + SSticker.mode?.xenorespawn_time - world.time) * 0.1 //If xeno_death is null, use -INFINITY
		if(status_value <= 0)
			items += "Xeno respawn timer: READY"
		else
			items += "Xeno respawn timer: [(status_value / 60) % 60]:[add_leading(num2text(status_value % 60), 2, "0")]"
