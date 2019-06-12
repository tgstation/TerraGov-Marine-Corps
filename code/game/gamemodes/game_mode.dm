/datum/game_mode
	var/name = ""
	var/config_tag = null
	var/votable = TRUE
	var/probability = 0
	var/required_players = 0

	var/round_finished

	var/round_time_fog
	var/flags_round_type = NONE
	var/flags_landmarks = NONE

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

	GLOB.landmarks_round_start = shuffle(GLOB.landmarks_round_start)
	var/obj/effect/landmark/L
	while(GLOB.landmarks_round_start.len)
		L = GLOB.landmarks_round_start[GLOB.landmarks_round_start.len]
		GLOB.landmarks_round_start.len--
		L.after_round_start()

	return TRUE

/datum/game_mode/proc/setup()
	SSjob.DivideOccupations() 
	create_characters() //Create player characters
	collect_minds()
	reset_squads()
	equip_characters()

	transfer_characters()	//transfer keys to the new mobs

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
		if(player.ready && player.mind)
			GLOB.joined_player_list += player.ckey
			player.create_character(FALSE)
		else
			player.new_player_panel()
		CHECK_TICK


/datum/game_mode/proc/collect_minds()
	for(var/i in GLOB.new_player_list)
		var/mob/new_player/P = i
		if(P.new_character && P.new_character.mind)
			SSticker.minds += P.new_character.mind
		CHECK_TICK


/datum/game_mode/proc/equip_characters()
	var/captainless = TRUE
	for(var/i in GLOB.new_player_list)
		var/mob/new_player/N = i
		var/mob/living/carbon/human/player = N.new_character
		if(!istype(player) || !player?.mind.assigned_role)
			continue
		var/datum/job/J = SSjob.GetJob(player.mind.assigned_role)
		if(istype(J, /datum/job/command/captain))
			captainless = FALSE
		if(player.mind.assigned_role)
			SSjob.EquipRank(N, player.mind.assigned_role, 0)
		CHECK_TICK
	if(captainless)
		for(var/i in GLOB.new_player_list)
			var/mob/new_player/N = i
			if(N.new_character)
				to_chat(N, "Marine Captain position not forced on anyone.")
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
		addtimer(CALLBACK(src, .proc/release_characters, livings), 3 SECONDS, TIMER_CLIENT_TIME)


/datum/game_mode/proc/release_characters(list/livings)
	for(var/I in livings)
		var/mob/living/L = I
		L.notransform = FALSE


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
	for(var/i in GLOB.new_player_list)
		var/mob/new_player/player = i
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
			var/mob/living/carbon/xenomorph/X = L
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
		var/mob/living/carbon/xenomorph/X = i
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

/datum/game_mode/proc/mode_new_player_panel(mob/new_player/NP)

	var/output = "<div align='center'>"
	output += "<p><a href='byond://?src=[REF(NP)];lobby_choice=show_preferences'>Setup Character</A></p>"

	if(SSticker.current_state <= GAME_STATE_PREGAME)
		output += "<p>\[ [NP.ready? "<b>Ready</b>":"<a href='byond://?src=\ref[src];lobby_choice=ready'>Ready</a>"] | [NP.ready? "<a href='byond://?src=[REF(NP)];lobby_choice=ready'>Not Ready</a>":"<b>Not Ready</b>"] \]</p>"
	else
		output += "<a href='byond://?src=[REF(NP)];lobby_choice=manifest'>View the Crew Manifest</A><br><br>"
		output += "<p><a href='byond://?src=[REF(NP)];lobby_choice=late_join'>Join the TGMC!</A></p>"

	output += "<p><a href='byond://?src=[REF(NP)];lobby_choice=observe'>Observe</A></p>"

	if(!IsGuestKey(NP.key))
		if(SSdbcore.Connect())
			var/isadmin = FALSE
			if(check_rights(R_ADMIN, FALSE))
				isadmin = TRUE
			var/datum/DBQuery/query_get_new_polls = SSdbcore.NewQuery("SELECT id FROM [format_table_name("poll_question")] WHERE [(isadmin ? "" : "adminonly = false AND")] Now() BETWEEN starttime AND endtime AND id NOT IN (SELECT pollid FROM [format_table_name("poll_vote")] WHERE ckey = \"[sanitizeSQL(NP.ckey)]\") AND id NOT IN (SELECT pollid FROM [format_table_name("poll_textreply")] WHERE ckey = \"[sanitizeSQL(NP.ckey)]\")")
			if(query_get_new_polls.Execute())
				var/newpoll = FALSE
				if(query_get_new_polls.NextRow())
					newpoll = TRUE

				if(newpoll)
					output += "<p><b><a href='byond://?src=[REF(NP)];showpoll=1'>Show Player Polls</A> (NEW!)</b></p>"
				else
					output += "<p><a href='byond://?src=[REF(NP)];showpoll=1'>Show Player Polls</A></p>"
			qdel(query_get_new_polls)
			if(QDELETED(NP))
				return FALSE

	output += "</div>"

	var/datum/browser/popup = new(NP, "playersetup", "<div align='center'>New Player Options</div>", 240, 300)
	popup.set_window_options("can_close=0")
	popup.set_content(output)
	popup.open(FALSE)

	return TRUE


/datum/game_mode/proc/AttemptLateSpawn(mob/M, rank)
	if(!isnewplayer(M))
		return
	var/mob/new_player/NP = M
	if(!NP.IsJobAvailable(rank))
		to_chat(usr, "<span class='warning'>Selected job is not available.<spawn>")
		return
	if(!SSticker || SSticker.current_state != GAME_STATE_PLAYING)
		to_chat(usr, "<span class='warning'>The round is either not ready, or has already finished!<spawn>")
		return
	if(!GLOB.enter_allowed)
		to_chat(usr, "<span class='warning'>Spawning currently disabled, please observe.<spawn>")
		return

	if(!SSjob.AssignRole(NP, rank, TRUE))
		to_chat(usr, "<span class='warning'>Failed to assign selected role.<spawn>")
		return

	NP.close_spawn_windows()
	NP.spawning = TRUE

	var/mob/living/character = NP.create_character(TRUE)	//creates the human and transfers vars and mind
	var/equip = SSjob.EquipRank(character, rank, TRUE)
	if(isliving(equip))	//Borgs get borged in the equip, so we need to make sure we handle the new mob.
		character = equip

	var/datum/job/job = SSjob.GetJob(rank)

	if(job && !job.override_latejoin_spawn(character))
		SSjob.SendToLateJoin(character)

	GLOB.datacore.manifest_inject(character)
	SSticker.minds += character.mind

	handle_late_spawn(character)

	qdel(NP)


/datum/game_mode/proc/handle_late_spawn(mob/C)
	return


/datum/game_mode/proc/attempt_to_join_as_larva(mob/xeno_candidate)
	to_chat(xeno_candidate, "<span class='warning'>This is unavailable in this gamemode.</span>")
	return FALSE


/datum/game_mode/proc/spawn_larva(mob/xeno_candidate)
	to_chat(xeno_candidate, "<span class='warning'>This is unavailable in this gamemode.</span>")
	return FALSE

/datum/game_mode/proc/transfer_xeno(mob/xeno_candidate, mob/living/carbon/xenomorph/X)
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

	var/mob/living/carbon/xenomorph/new_xeno = input("Available Xenomorphs") as null|anything in available_xenos
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

	if(world.time - new_xeno.away_time < XENO_AFK_TIMER) //We do not want to occupy them if they've only been gone for a little bit.
		to_chat(xeno_candidate, "<span class='warning'>That player hasn't been away long enough. Please wait [round((new_xeno.away_time + XENO_AFK_TIMER - world.time) * 0.1)] second\s longer.</span>")
		return FALSE

	return new_xeno
