/datum/game_mode
	var/name = ""
	var/config_tag = null
	var/votable = TRUE
	var/probability = 0
	var/required_players = 0

	var/round_finished

	var/round_time_fog
	var/flags_round_type = NOFLAGS
	var/flags_landmarks = NOFLAGS

	var/distress_cancelled = FALSE


/datum/game_mode/New()
	initialize_emergency_calls()


/datum/game_mode/proc/announce()
	return TRUE


/datum/game_mode/proc/can_start()
	if(GLOB.ready_players < required_players)
		return FALSE
	return TRUE


/datum/game_mode/proc/pre_setup()
	if(flags_landmarks & MODE_LANDMARK_SPAWN_XENO_TUNNELS)
		setup_xeno_tunnels()

	if(flags_landmarks & MODE_LANDMARK_SPAWN_MAP_ITEM)
		spawn_map_items()

	if(flags_round_type & MODE_FOG_ACTIVATED)
		spawn_fog_blockers()
		addtimer(CALLBACK(src, .proc/disperse_fog), FOG_DELAY_INTERVAL + SSticker.round_start_time + rand(-2500, 2500))

	var/obj/effect/landmark/L
	while(GLOB.landmarks_round_start.len)
		L = GLOB.landmarks_round_start[GLOB.landmarks_round_start.len]
		GLOB.landmarks_round_start.len--
		L.after_round_start()

	return TRUE


/datum/game_mode/proc/post_setup()
	spawn(ROUNDSTART_LOGOUT_REPORT_TIME)
		display_roundstart_logout_report()
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


/datum/game_mode/process()
	return TRUE


/datum/game_mode/proc/check_finished()
	if(SSevacuation.dest_status == NUKE_EXPLOSION_FINISHED)
		return TRUE


/datum/game_mode/proc/declare_completion()
	SSdbcore.SetRoundEnd()
	end_of_round_deathmatch()
	return TRUE


/datum/game_mode/proc/get_players_for_role(role, override_jobbans = FALSE)
	var/list/candidates = list()

	var/roletext
	switch(role)
		if(BE_DEATHMATCH)
			roletext = "End of Round Deathmatch"
		if(BE_ALIEN)
			roletext = ROLE_XENOMORPH
		if(BE_QUEEN)
			roletext = ROLE_XENO_QUEEN
		if(BE_SURVIVOR)
			roletext = ROLE_SURVIVOR
		if(BE_SQUAD_STRICT)
			roletext = "Prefer squad over role"

	//Assemble a list of active players without jobbans.
	for(var/mob/new_player/player in GLOB.player_list)
		if(!(player.client?.prefs?.be_special & role) || !player.ready)
			continue
		else if(jobban_isbanned(player, roletext) || is_banned_from(player.ckey, roletext))
			continue	
		log_game("[key_name(player)] had [roletext] enabled, so we are drafting them.")
		candidates += player.mind

	//Shuffle the players list so that it becomes ping-independent.
	candidates = shuffle(candidates)

	return candidates


/datum/game_mode/proc/display_roundstart_logout_report()
	var/msg = "<hr><span class='notice'><b>Roundstart logout report</b></span><br>"
	for(var/mob/living/L in GLOB.mob_living_list)
		if(L.ckey && L.client)
			continue

		else if(L.ckey)
			msg += "<b>[ADMIN_TPMONTY(L)]</b> the [L.job] (<b>Disconnected</b>)<br>"

		else if(L.client)
			if(L.client.inactivity >= (ROUNDSTART_LOGOUT_REPORT_TIME / 2))
				msg += "<b>[ADMIN_TPMONTY(L)]</b> the [L.job] (<b>Connected, Inactive</b>)<br>"
			else if(L.stat)
				if(L.suiciding)
					msg += "<b>[ADMIN_TPMONTY(L)]</b> the [L.job] (<b>Suicide</b>)<br>"
				else if(L.stat == UNCONSCIOUS)
					msg += "<b>[ADMIN_TPMONTY(L)]</b> the [L.job] (Dying)<br>"
				else if(L.stat == DEAD)
					msg += "<b>[ADMIN_TPMONTY(L)]</b> the [L.job] (Dead)<br>"

	for(var/mob/dead/observer/D in GLOB.dead_mob_list)
		if(!isliving(D.mind?.current))
			continue
		var/mob/living/L = D.mind.current
		if(L.stat == DEAD)
			if(L.suiciding)
				msg += "<b>[ADMIN_TPMONTY(L)]</b> the [L.job] (<b>Suicide</b>)<br>"
			else
				msg += "<b>[ADMIN_TPMONTY(L)]</b> the [L.job] (Dead)<br>"
		else if(!D.can_reenter_corpse)
			msg += "<b>[ADMIN_TPMONTY(L)]</b> the [L.job] (<b>Ghosted</b>)<br>"
				

	msg += "<hr>"

	for(var/i in GLOB.clients)
		var/client/C = i
		if(!check_other_rights(C, R_ADMIN, FALSE))
			continue
		to_chat(C, msg)


/datum/game_mode/proc/spawn_map_items()
	var/turf/T
	switch(SSmapping.config.map_name) // doing the switch first makes this a tiny bit quicker which for round setup is more important than pretty code
		if(MAP_LV_624)
			while(GLOB.map_items.len)
				T = GLOB.map_items[GLOB.map_items.len]
				GLOB.map_items.len--
				new /obj/item/map/lazarus_landing_map(T)

		if(MAP_ICE_COLONY)
			while(GLOB.map_items.len)
				T = GLOB.map_items[GLOB.map_items.len]
				GLOB.map_items.len--
				new /obj/item/map/ice_colony_map(T)

		if(MAP_BIG_RED)
			while(GLOB.map_items.len)
				T = GLOB.map_items[GLOB.map_items.len]
				GLOB.map_items.len--
				new /obj/item/map/big_red_map(T)

		if(MAP_PRISON_STATION)
			while(GLOB.map_items.len)
				T = GLOB.map_items[GLOB.map_items.len]
				GLOB.map_items.len--
				new /obj/item/map/FOP_map(T)


/datum/game_mode/proc/setup_xeno_tunnels()
	var/obj/structure/tunnel/T
	var/i = 0
	var/turf/t
	while(length(GLOB.xeno_tunnel_landmarks) && i++ < MAX_TUNNELS_PER_MAP)
		t = pick(GLOB.xeno_tunnel_landmarks)
		GLOB.xeno_tunnel_landmarks -= t
		T = new (t)
		T.id = "hole[i]"
		for(var/x in GLOB.xeno_tunnels)
			var/obj/structure/tunnel/TO = x
			if(TO.id != T.id || T == TO || TO.other)
				continue
			TO.other = T
			T.other = TO


/datum/game_mode/proc/spawn_fog_blockers()
	var/turf/T
	while(GLOB.fog_blocker_locations.len)
		T = GLOB.fog_blocker_locations[GLOB.fog_blocker_locations.len]
		GLOB.fog_blocker_locations.len--
		new /obj/effect/forcefield/fog(T)


/datum/game_mode/proc/end_of_round_deathmatch()
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

		var/mob/living/L
		if(!isliving(M))
			L = new /mob/living/carbon/human
		else
			L = M

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
			to_chat(L, "<br><br><h1><span class='danger'>Failed to find a valid location for End of Round Deathmatch. Please do not grief.</span></h1><br><br>")
			continue

		if(!L.mind)
			M.mind.transfer_to(L, TRUE)
			
		L.mind.bypass_ff = TRUE
		L.forceMove(picked)
		L.revive()

		if(isxeno(L))
			var/mob/living/carbon/Xenomorph/X = L
			X.transfer_to_hive(pick(XENO_HIVE_NORMAL, XENO_HIVE_CORRUPTED, XENO_HIVE_ALPHA, XENO_HIVE_BETA, XENO_HIVE_ZETA))

		else if(ishuman(L))
			var/mob/living/carbon/human/H = L
			if(!H.w_uniform)
				var/job = pick(/datum/job/clf/leader, /datum/job/upp/commando/leader, /datum/job/freelancer/leader)
				var/datum/job/J = new job
				J.equip(H)
				H.regenerate_icons()

		to_chat(L, "<br><br><h1><span class='danger'>Fight for your life!</span></h1><br><br>")


/datum/game_mode/proc/check_queen_status(queen_time)
	return


/datum/game_mode/proc/get_queen_countdown()
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
		<br>There were [round_statistics.total_bullets_fired] total bullets fired.
		<br>[round_statistics.total_bullet_hits_on_marines] bullets managed to hit marines. For a [(round_statistics.total_bullet_hits_on_marines / max(round_statistics.total_bullets_fired, 1)) * 100]% friendly fire rate!"})
	if(round_statistics.total_bullet_hits_on_xenos)
		dat += "[round_statistics.total_bullet_hits_on_xenos] bullets managed to hit xenomorphs. For a [(round_statistics.total_bullet_hits_on_xenos / max(round_statistics.total_bullets_fired, 1)) * 100]% accuracy total!"
	if(round_statistics.grenades_thrown)
		dat += "[round_statistics.grenades_thrown] total grenades exploding."
	else
		dat += "No grenades exploded."
	if(round_statistics.now_pregnant)
		dat += "[round_statistics.now_pregnant] people infected among which [round_statistics.total_larva_burst] burst. For a [(round_statistics.total_larva_burst / max(round_statistics.now_pregnant, 1)) * 100]% successful delivery rate!"
	if(round_statistics.queen_screech)
		dat += "[round_statistics.queen_screech] Queen screeches."
	if(round_statistics.ravager_ravage_victims)
		dat += "[round_statistics.ravager_ravage_victims] ravaged victims. Damn, Ravagers!"
	if(round_statistics.warrior_limb_rips)
		dat += "[round_statistics.warrior_limb_rips] limbs ripped off by Warriors."
	if(round_statistics.crusher_stomp_victims)
		dat += "[round_statistics.crusher_stomp_victims] people stomped by crushers."
	if(round_statistics.praetorian_spray_direct_hits)
		dat += "[round_statistics.praetorian_spray_direct_hits] people hit directly by Praetorian acid spray."
	if(round_statistics.weeds_planted)
		dat += "[round_statistics.weeds_planted] weed nodes planted."
	if(round_statistics.weeds_destroyed)
		dat += "[round_statistics.weeds_destroyed] weed tiles removed."
	if(round_statistics.carrier_traps)
		dat += "[round_statistics.carrier_traps] hidey holes for huggers were made."
	if(round_statistics.sentinel_neurotoxin_stings)
		dat += "[round_statistics.sentinel_neurotoxin_stings] number of times Sentinels stung."
	if(round_statistics.drone_salvage_plasma)
		dat += "[round_statistics.drone_salvage_plasma] number of times Drones salvaged corpses."
	if(round_statistics.defiler_defiler_stings)
		dat += "[round_statistics.defiler_defiler_stings] number of times Defilers stung."
	if(round_statistics.defiler_neurogas_uses)
		dat += "[round_statistics.defiler_neurogas_uses] number of times Defilers vented neurogas."
	var/output = jointext(dat, "<br>")
	for(var/mob/player in GLOB.player_list)
		if(player?.client?.prefs?.toggles_chat & CHAT_STATISTICS)
			to_chat(player, output)


/datum/game_mode/proc/count_humans_and_xenos(list/z_levels = SSmapping.levels_by_any_trait(list(ZTRAIT_MARINE_MAIN_SHIP, ZTRAIT_LOW_ORBIT, ZTRAIT_GROUND)))
	var/num_humans = 0
	var/num_xenos = 0

	for(var/i in GLOB.alive_human_list)
		var/mob/living/carbon/human/H = i
		if(!H.client)
			continue
		if(H.status_flags & XENO_HOST)
			continue
		if(!(H.z in z_levels) || isspaceturf(H.loc))
			continue
		num_humans++

	for(var/i in GLOB.alive_xeno_list)
		var/mob/living/carbon/Xenomorph/X = i
		if(!X.client)
			continue
		if(!(X.z in z_levels) || isspaceturf(X.loc))
			continue
		num_xenos++

	return list(num_humans, num_xenos)


/datum/game_mode/proc/disperse_fog()
	set waitfor = FALSE

	flags_round_type &= ~MODE_FOG_ACTIVATED
	for(var/i in GLOB.fog_blockers)
		qdel(i)
		sleep(1)


/datum/game_mode/proc/attempt_to_join_as_larva(mob/xeno_candidate)
	to_chat(xeno_candidate, "<span class='warning'>This is unavailable in this gamemode.</span>")
	return FALSE


/datum/game_mode/proc/spawn_larva(mob/xeno_candidate)
	to_chat(xeno_candidate, "<span class='warning'>This is unavailable in this gamemode.</span>")
	return FALSE

/datum/game_mode/proc/transfer_xeno(mob/xeno_candidate, mob/living/carbon/Xenomorph/X)
	xeno_candidate.mind.transfer_to(X, TRUE)
	message_admins("[key_name(xeno_candidate)] has joined as [ADMIN_TPMONTY(X)].")
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

	var/mob/living/carbon/Xenomorph/new_xeno = input("Available Xenomorphs") as null|anything in available_xenos
	if(!istype(new_xeno) || !xeno_candidate?.client)
		return FALSE

	if(new_xeno.stat == DEAD)
		to_chat(xeno_candidate, "<span class='warning'>You cannot join if the xenomorph is dead.</span>")
		return FALSE

	if(new_xeno.client)
		to_chat(xeno_candidate, "<span class='warning'>That xenomorph has been occupied.</span>")
		return FALSE

	if(!DEATHTIME_CHECK(xeno_candidate))
		DEATHTIME_MESSAGE(xeno_candidate)
		return FALSE

	if(new_xeno.away_timer < XENO_AFK_TIMER) //We do not want to occupy them if they've only been gone for a little bit.
		to_chat(xeno_candidate, "<span class='warning'>That player hasn't been away long enough. Please wait [XENO_AFK_TIMER - new_xeno.away_timer] second\s longer.</span>")
		return FALSE

	return new_xeno