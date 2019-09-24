/datum/game_mode
	var/name = ""
	var/config_tag = null
	var/votable = TRUE
	var/probability = 0
	var/required_players = 0

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

	// Xeno round start conditions
	var/xeno_required_num = 1 // Number of xenos required to start
	var/xeno_starting_num // Number of xenos given at start
	var/list/xenomorphs = list()

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

	setup_blockers()

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


/datum/game_mode/proc/get_players_for_role(role, override_jobbans = FALSE)
	var/list/candidates = list()

	var/roletext
	switch(role)
		if(BE_DEATHMATCH)
			roletext = "End of Round Deathmatch"
		if(BE_ALIEN)
			roletext = ROLE_XENOMORPH
		if(BE_ALIEN_UNREVIVABLE)
			roletext = "[ROLE_XENOMORPH] when unrevivable"
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
		else if(is_banned_from(player.ckey, roletext))
			continue
		candidates += player.mind

	//Shuffle the players list so that it becomes ping-independent.
	candidates = shuffle(candidates)

	return candidates


/datum/game_mode/proc/initialize_xeno_leader()
	var/list/possible_queens = get_players_for_role(BE_QUEEN)
	if(!length(possible_queens))
		return FALSE

	var/found = FALSE
	for(var/i in possible_queens)
		var/datum/mind/new_queen = i
		if(new_queen.assigned_role || is_banned_from(new_queen.current?.ckey, ROLE_XENO_QUEEN))
			continue
		if(queen_age_check(new_queen.current?.client))
			continue
		new_queen.assigned_role = ROLE_XENO_QUEEN
		xenomorphs += new_queen
		found = TRUE
		break

	return found


/datum/game_mode/proc/initialize_xenomorphs()
	var/list/possible_xenomorphs = get_players_for_role(BE_ALIEN)
	if(length(possible_xenomorphs) < xeno_required_num)
		return FALSE

	for(var/i in possible_xenomorphs)
		var/datum/mind/new_xeno = i
		if(new_xeno.assigned_role || is_banned_from(new_xeno.current?.ckey, ROLE_XENOMORPH))
			continue
		new_xeno.assigned_role = ROLE_XENOMORPH
		xenomorphs += new_xeno
		possible_xenomorphs -= new_xeno
		if(length(xenomorphs) >= xeno_starting_num)
			break

	if(!length(xenomorphs))
		return FALSE

	xeno_required_num = CONFIG_GET(number/min_xenos)

	if(length(xenomorphs) < xeno_required_num)
		for(var/i = 1 to xeno_starting_num - length(xenomorphs))
			new /mob/living/carbon/xenomorph/larva(pick(GLOB.xeno_spawn))

	else if(length(xenomorphs) < xeno_starting_num)
		var/datum/hive_status/normal/HN = GLOB.hive_datums[XENO_HIVE_NORMAL]
		HN.stored_larva += xeno_starting_num - length(xenomorphs)

	return TRUE


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
	switch(SSmapping.configs[GROUND_MAP].map_name) // doing the switch first makes this a tiny bit quicker which for round setup is more important than pretty code
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


/datum/game_mode/proc/announce_bioscans(show_locations = TRUE, delta = 2, announce_humans = TRUE, announce_xenos = TRUE)
	var/list/xenoLocationsP = list()
	var/list/xenoLocationsS = list()
	var/list/hostLocationsP = list()
	var/list/hostLocationsS = list()
	var/numHostsPlanet	= 0
	var/numHostsShip	= 0
	var/numXenosPlanet	= 0
	var/numXenosShip	= 0
	var/numLarvaPlanet  = 0
	var/numLarvaShip    = 0

	for(var/i in GLOB.alive_xeno_list)
		var/mob/living/carbon/xenomorph/X = i
		var/area/A = get_area(X)
		if(is_ground_level(A?.z))
			if(isxenolarva(X))
				numLarvaPlanet++
			numXenosPlanet++
			xenoLocationsP += A
		else if(is_mainship_level(A?.z))
			if(isxenolarva(X))
				numLarvaShip++
			numXenosShip++
			xenoLocationsS += A

	for(var/i in GLOB.alive_human_list)
		var/mob/living/carbon/human/H = i
		var/area/A = get_area(H)
		if(is_ground_level(A?.z))
			numHostsPlanet++
			hostLocationsP += A
		else if(is_mainship_level(A?.z))
			numHostsShip++
			hostLocationsS += A


	//Adjust the randomness there so everyone gets the same thing
	var/numHostsShipr = max(0, numHostsShip + rand(-delta, delta))
	var/numXenosPlanetr = max(0, numXenosPlanet + rand(-delta, delta))
	var/hostLocationP
	var/hostLocationS

	if(length(hostLocationsP))
		hostLocationP = pick(hostLocationsP)

	if(length(hostLocationsS))
		hostLocationS = pick(hostLocationsS)

	var/sound/S = sound(get_sfx("queen"), channel = CHANNEL_ANNOUNCEMENTS, volume = 50)
	if(announce_xenos)
		for(var/i in GLOB.alive_xeno_list)
			var/mob/M = i
			SEND_SOUND(M, S)
			to_chat(M, "<span class='xenoannounce'>The Queen Mother reaches into your mind from worlds away.</span>")
			to_chat(M, "<span class='xenoannounce'>To my children and their Queen. I sense [numHostsShipr ? "approximately [numHostsShipr]":"no"] host[numHostsShipr > 1 ? "s":""] in the metal hive[show_locations && hostLocationS ? ", including one in [hostLocationS]":""] and [numHostsPlanet ? "[numHostsPlanet]":"none"] scattered elsewhere[show_locations && hostLocationP ? ", including one in [hostLocationP]":""].</span>")

	var/xenoLocationP
	var/xenoLocationS

	if(length(xenoLocationsP))
		xenoLocationP = pick(xenoLocationsP)

	if(length(xenoLocationsS))
		xenoLocationS = pick(xenoLocationsS)

	var/name = "[MAIN_AI_SYSTEM] Bioscan Status"
	var/input = {"Bioscan complete.

Sensors indicate [numXenosShip ? "[numXenosShip]" : "no"] unknown lifeform signature[numXenosShip > 1 ? "s":""] present on the ship[show_locations && xenoLocationS ? " including one in [xenoLocationS]" : ""] and [numXenosPlanetr ? "approximately [numXenosPlanetr]":"no"] signature[numXenosPlanetr > 1 ? "s":""] located elsewhere[show_locations && xenoLocationP ? ", including one in [xenoLocationP]":""]."}

	if(announce_humans)
		priority_announce(input, name, sound = 'sound/AI/bioscan.ogg')

	log_game("Bioscan. Humans: [numHostsPlanet] on the planet[hostLocationP ? " Location:[hostLocationP]":""] and [numHostsShip] on the ship.[hostLocationS ? " Location: [hostLocationS].":""] Xenos: [numXenosPlanetr] on the planet and [numXenosShip] on the ship[xenoLocationP ? " Location:[xenoLocationP]":""].")

	for(var/i in GLOB.observer_list)
		var/mob/M = i
		to_chat(M, "<h2 class='alert'>Detailed Information</h2>")
		to_chat(M, {"<span class='alert'>[numXenosPlanet] xeno\s on the planet, including [numLarvaPlanet] larva.
[numXenosShip] xeno\s on the ship, including [numLarvaShip] larva.
[numHostsPlanet] human\s on the planet.
[numHostsShip] human\s on the ship.</span>"})

	message_admins("Bioscan - Humans: [numHostsPlanet] on the planet[hostLocationP ? ". Location:[hostLocationP]":""]. [numHostsShipr] on the ship.[hostLocationS ? " Location: [hostLocationS].":""]")
	message_admins("Bioscan - Xenos: [numXenosPlanetr] on the planet[numXenosPlanetr > 0 && xenoLocationP ? ". Location:[xenoLocationP]":""]. [numXenosShip] on the ship.[xenoLocationS ? " Location: [xenoLocationS].":""]")


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
	if(flags_round_type & MODE_FOG_ACTIVATED)
		var/turf/T
		while(GLOB.fog_blocker_locations.len)
			T = GLOB.fog_blocker_locations[GLOB.fog_blocker_locations.len]
			GLOB.fog_blocker_locations.len--
			new /obj/effect/forcefield/fog(T)
		addtimer(CALLBACK(src, .proc/remove_fog), FOG_DELAY_INTERVAL + SSticker.round_start_time + rand(-5 MINUTES, 5 MINUTES))

		addtimer(CALLBACK(GLOBAL_PROC, .proc/send_global_signal, COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE), SSticker.round_start_time + 40 MINUTES)
			//Called late because there used to be shutters opened earlier. To re-add them just copy the logic.


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
				var/job = pick(/datum/job/clf/leader, /datum/job/upp/commando/leader, /datum/job/freelancer/leader)
				var/datum/job/J = SSjob.GetJobType(job)
				J.assign_equip(H)
				H.regenerate_icons()

		to_chat(L, "<br><br><h1><span class='danger'>Fight for your life!</span></h1><br><br>")
		CHECK_TICK


/datum/game_mode/distress/proc/transform_survivor(datum/mind/M)
	var/mob/living/carbon/human/H = new (pick(GLOB.surv_spawn))

	if(isnewplayer(M.current))
		var/mob/new_player/N = M.current
		N.close_spawn_windows()

	M.transfer_to(H, TRUE)
	H.client.prefs.copy_to(H)

	var/survivor_job = pick(subtypesof(/datum/job/survivor))
	var/datum/job/J = new survivor_job

	J.assign_equip(H)

	H.mind.assigned_role = "Survivor"

	if(SSmapping.configs[GROUND_MAP].map_name == MAP_ICE_COLONY)
		H.equip_to_slot_or_del(new /obj/item/clothing/head/ushanka(H), SLOT_HEAD)
		H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/snow_suit(H), SLOT_WEAR_SUIT)
		H.equip_to_slot_or_del(new /obj/item/clothing/mask/rebreather(H), SLOT_WEAR_MASK)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/snow(H), SLOT_SHOES)
		H.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(H), SLOT_GLOVES)

	var/weapons = pick(SURVIVOR_WEAPONS)
	var/obj/item/weapon/W = weapons[1]
	var/obj/item/ammo_magazine/A = weapons[2]
	H.equip_to_slot_or_del(new /obj/item/storage/belt/gun/m44/full(H), SLOT_BELT)
	H.put_in_hands(new W(H))
	H.equip_to_slot_or_del(new A(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new A(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new A(H), SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/welding(H), SLOT_GLASSES)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/tools/full(H), SLOT_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/survival/full(H), SLOT_L_STORE)

	to_chat(H, "<h2>You are a survivor!</h2>")
	switch(SSmapping.configs[GROUND_MAP].map_name)
		if(MAP_PRISON_STATION)
			to_chat(H, "<span class='notice'>You are a survivor of the attack on Fiorina Orbital Penitentiary. You worked or lived on the prison station, and managed to avoid the alien attacks.. until now.</span>")
		if(MAP_ICE_COLONY)
			to_chat(H, "<span class='notice'>You are a survivor of the attack on the ice habitat. You worked or lived on the colony, and managed to avoid the alien attacks.. until now.</span>")
		if(MAP_BIG_RED)
			to_chat(H, "<span class='notice'>You are a survivor of the attack on the colony. You worked or lived in the archaeology colony, and managed to avoid the alien attacks...until now.</span>")
		if(MAP_LV_624)
			to_chat(H, "<span class='notice'>You are a survivor of the attack on the colony. You suspected something was wrong and tried to warn others, but it was too late...</span>")
		else
			to_chat(H, "<span class='notice'>Through a miracle you managed to survive the attack. But are you truly safe now?</span>")



/datum/game_mode/proc/transform_xeno(datum/mind/M, list/xeno_spawn = GLOB.xeno_spawn)
	var/mob/living/carbon/xenomorph/larva/X = new (pick(GLOB.xeno_spawn))

	if(isnewplayer(M.current))
		var/mob/new_player/N = M.current
		N.close_spawn_windows()

	M.transfer_to(X, TRUE)

	to_chat(X, "<B>You are now an alien!</B>")
	to_chat(X, "<B>Your job is to spread the hive and protect the Queen. If there's no Queen, you can become the Queen yourself by evolving into a drone.</B>")
	to_chat(X, "Talk in Hivemind using <strong>;</strong>, <strong>.a</strong>, or <strong>,a</strong> (e.g. ';My life for the queen!')")

	X.update_icons()


/datum/game_mode/proc/transform_ruler(datum/mind/M, queen = FALSE, list/xeno_spawn = GLOB.xeno_spawn)
	var/mob/living/carbon/xenomorph/X
	if(queen)
		X = new /mob/living/carbon/xenomorph/queen(pick(GLOB.xeno_spawn))
	else
		X = new /mob/living/carbon/xenomorph/shrike(pick(GLOB.xeno_spawn))

	if(isnewplayer(M.current))
		var/mob/new_player/N = M.current
		N.close_spawn_windows()

	M.transfer_to(X, TRUE)

	to_chat(X, "<B>You are now the alien ruler!</B>")
	to_chat(X, "<B>Your job is to spread the hive.</B>")
	to_chat(X, "Talk in Hivemind using <strong>;</strong>, <strong>.a</strong>, or <strong>,a</strong> (e.g. ';My life for the hive!')")

	X.update_icons()


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
	if(GLOB.round_statistics.ravager_ravage_victims)
		dat += "[GLOB.round_statistics.ravager_ravage_victims] ravaged victims. Damn, Ravagers!"
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
	if(GLOB.round_statistics.defiler_defiler_stings)
		dat += "[GLOB.round_statistics.defiler_defiler_stings] number of times Defilers stung."
	if(GLOB.round_statistics.defiler_neurogas_uses)
		dat += "[GLOB.round_statistics.defiler_neurogas_uses] number of times Defilers vented neurogas."
	var/output = jointext(dat, "<br>")
	for(var/mob/player in GLOB.player_list)
		if(player?.client?.prefs?.toggles_chat & CHAT_STATISTICS)
			to_chat(player, output)


/datum/game_mode/proc/count_humans_and_xenos(list/z_levels = SSmapping.levels_by_any_trait(list(ZTRAIT_MARINE_MAIN_SHIP, ZTRAIT_GROUND, ZTRAIT_RESERVED)), count_ssd = FALSE)
	var/num_humans = 0
	var/num_xenos = 0

	for(var/i in GLOB.alive_human_list)
		var/mob/living/carbon/human/H = i
		if(!H.client && !count_ssd)
			continue
		if(H.status_flags & XENO_HOST)
			continue
		if(!(H.z in z_levels) || isspaceturf(H.loc))
			continue
		num_humans++

	for(var/i in GLOB.alive_xeno_list)
		var/mob/living/carbon/xenomorph/X = i
		if(!X.client && !count_ssd)
			continue
		if((!(X.z in z_levels) && !X.is_ventcrawling) || isspaceturf(X.loc))
			continue
		num_xenos++

	return list(num_humans, num_xenos)


/datum/game_mode/proc/remove_fog()
	set waitfor = FALSE

	DISABLE_BITFIELD(flags_round_type, MODE_FOG_ACTIVATED)

	for(var/i in GLOB.fog_blockers)
		qdel(i)
		stoplag(1)


/datum/game_mode/proc/mode_new_player_panel(mob/new_player/NP)

	var/output = "<div align='center'>"
	output += "<p><a href='byond://?src=[REF(NP)];lobby_choice=show_preferences'>Setup Character</A></p>"

	if(SSticker.current_state <= GAME_STATE_PREGAME)
		output += "<p>\[ [NP.ready? "<b>Ready</b>":"<a href='byond://?src=\ref[src];lobby_choice=ready'>Ready</a>"] | [NP.ready? "<a href='byond://?src=[REF(NP)];lobby_choice=ready'>Not Ready</a>":"<b>Not Ready</b>"] \]</p>"
	else
		output += "<a href='byond://?src=[REF(NP)];lobby_choice=manifest'>View the Crew Manifest</A><br><br>"
		output += "<p><a href='byond://?src=[REF(NP)];lobby_choice=late_join'>Join the TGMC!</A></p>"

	output += "<p><a href='byond://?src=[REF(NP)];lobby_choice=observe'>Observe</A></p>"

	output += append_player_votes_link(NP)
	output += "</div>"

	var/datum/browser/popup = new(NP, "playersetup", "<div align='center'>New Player Options</div>", 240, 300)
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


/datum/game_mode/proc/CanLateSpawn(mob/M, rank)
	if(!isnewplayer(M))
		return FALSE
	var/mob/new_player/NP = M
	if(!NP.IsJobAvailable(rank, TRUE))
		to_chat(usr, "<span class='warning'>Selected job is not available.<spawn>")
		return FALSE
	if(!SSticker || SSticker.current_state != GAME_STATE_PLAYING)
		to_chat(usr, "<span class='warning'>The round is either not ready, or has already finished!<spawn>")
		return FALSE
	if(!GLOB.enter_allowed)
		to_chat(usr, "<span class='warning'>Spawning currently disabled, please observe.<spawn>")
		return FALSE
	if(!SSjob.AssignRole(NP, rank, TRUE))
		to_chat(usr, "<span class='warning'>Failed to assign selected role.<spawn>")
		return FALSE

	return TRUE


/datum/game_mode/proc/AttemptLateSpawn(mob/new_player/NP, rank)
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

	if(!DEATHTIME_CHECK(xeno_candidate))
		DEATHTIME_MESSAGE(xeno_candidate)
		return FALSE

	if(new_xeno.afk_timer_id) //We do not want to occupy them if they've only been gone for a little bit.
		to_chat(xeno_candidate, "<span class='warning'>That player hasn't been away long enough. Please wait [round(timeleft(new_xeno.afk_timer_id) * 0.1)] second\s longer.</span>")
		return FALSE

	return new_xeno
