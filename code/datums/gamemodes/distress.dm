/datum/game_mode/distress
	name = "Distress Signal"
	config_tag = "Distress Signal"
	required_players = 2
	flags_round_type = MODE_INFESTATION|MODE_FOG_ACTIVATED
	flags_landmarks = MODE_LANDMARK_SPAWN_XENO_TUNNELS|MODE_LANDMARK_SPAWN_MAP_ITEM

	round_end_states = list(MODE_INFESTATION_X_MAJOR, MODE_INFESTATION_M_MAJOR, MODE_INFESTATION_X_MINOR, MODE_INFESTATION_M_MINOR, MODE_INFESTATION_DRAW_DEATH)
	

	var/list/survivors = list()

	var/surv_starting_num 	  = 0
	var/marine_starting_num   = 0

	var/bioscan_current_interval = 45 MINUTES
	var/bioscan_ongoing_interval = 20 MINUTES

	var/latejoin_tally		= 0
	var/latejoin_larva_drop = 0
	var/queen_death_countdown = 0


/datum/game_mode/distress/announce()
	to_chat(world, "<span class='round_header'>The current map is - [SSmapping.configs[GROUND_MAP].map_name]!</span>")


/datum/game_mode/distress/can_start()
	. = ..()
	initialize_scales()
	var/found_queen = initialize_xeno_leader()
	var/found_xenos = initialize_xenomorphs()
	if(!found_queen && !found_xenos)
		return FALSE
	initialize_survivor()
	return TRUE


/datum/game_mode/distress/pre_setup()
	. = ..()
	var/number_of_xenos = length(xenomorphs)
	var/datum/hive_status/normal/HN = GLOB.hive_datums[XENO_HIVE_NORMAL]
	for(var/i in xenomorphs)
		var/datum/mind/M = i
		if(M.assigned_role == ROLE_XENO_QUEEN)
			transform_ruler(M, number_of_xenos > HN.xenos_per_queen)
		else
			transform_xeno(M)

	for(var/i in survivors)
		var/datum/mind/M = i
		transform_survivor(M)

	scale_gear()

	addtimer(CALLBACK(SSticker.mode, .proc/map_announce), 5 SECONDS)


/datum/game_mode/distress/post_setup()
	. = ..()
	addtimer(CALLBACK(src, .proc/announce_bioscans, FALSE, 1), rand(30 SECONDS, 1 MINUTES)) //First scan shows no location but more precise numbers.


/datum/game_mode/distress/proc/map_announce()
	if(!SSmapping.configs[GROUND_MAP].announce_text)
		return

	priority_announce(SSmapping.configs[GROUND_MAP].announce_text, SSmapping.configs[SHIP_MAP].map_name)


/datum/game_mode/distress/process()
	if(round_finished)
		return FALSE

	//Automated bioscan / Queen Mother message
	if(world.time > bioscan_current_interval)
		announce_bioscans()
		var/total[] = count_humans_and_xenos()
		var/marines = total[1]
		var/xenos = total[2]
		var/bioscan_scaling_factor = xenos / max(marines, 1)
		bioscan_scaling_factor = max(bioscan_scaling_factor, 0.25)
		bioscan_scaling_factor = min(bioscan_scaling_factor, 1.5)
		bioscan_current_interval += bioscan_ongoing_interval * bioscan_scaling_factor


/datum/game_mode/distress/check_finished()
	if(round_finished)
		return TRUE

	if(world.time < (SSticker.round_start_time + 5 SECONDS))
		return FALSE

	var/living_player_list[] = count_humans_and_xenos()
	var/num_humans = living_player_list[1]
	var/num_xenos = living_player_list[2]

	if(SSevacuation.dest_status == NUKE_EXPLOSION_FINISHED)
		message_admins("Round finished: [MODE_GENERIC_DRAW_NUKE]")
		round_finished = MODE_GENERIC_DRAW_NUKE
	else if(!num_humans && num_xenos)
		message_admins("Round finished: [MODE_INFESTATION_X_MAJOR]")
		round_finished = MODE_INFESTATION_X_MAJOR
	else if(num_humans && !num_xenos)
		message_admins("Round finished: [MODE_INFESTATION_M_MAJOR]")
		round_finished = MODE_INFESTATION_M_MAJOR
	else if(!num_humans && !num_xenos)
		message_admins("Round finished: [MODE_INFESTATION_DRAW_DEATH]")
		round_finished = MODE_INFESTATION_DRAW_DEATH

	return FALSE


/datum/game_mode/distress/declare_completion()
	. = ..()
	to_chat(world, "<span class='round_header'>|Round Complete|</span>")

	to_chat(world, "<span class='round_body'>Thus ends the story of the brave men and women of the [SSmapping.configs[SHIP_MAP].map_name] and their struggle on [SSmapping.configs[GROUND_MAP].map_name].</span>")
	var/xeno_track
	var/human_track
	switch(round_finished)
		if(MODE_INFESTATION_X_MAJOR)
			xeno_track = pick('sound/theme/winning_triumph1.ogg','sound/theme/winning_triumph2.ogg')
			human_track = pick('sound/theme/sad_loss1.ogg','sound/theme/sad_loss2.ogg')
		if(MODE_INFESTATION_M_MAJOR)
			xeno_track = pick('sound/theme/sad_loss1.ogg','sound/theme/sad_loss2.ogg')
			human_track = pick('sound/theme/winning_triumph1.ogg','sound/theme/winning_triumph2.ogg')
		if(MODE_INFESTATION_X_MINOR)
			xeno_track = pick('sound/theme/neutral_hopeful1.ogg','sound/theme/neutral_hopeful2.ogg')
			human_track = pick('sound/theme/neutral_melancholy1.ogg','sound/theme/neutral_melancholy2.ogg')
		if(MODE_INFESTATION_M_MINOR)
			xeno_track = pick('sound/theme/neutral_melancholy1.ogg','sound/theme/neutral_melancholy2.ogg')
			human_track = pick('sound/theme/neutral_hopeful1.ogg','sound/theme/neutral_hopeful2.ogg')
		if(MODE_INFESTATION_DRAW_DEATH)
			xeno_track = pick('sound/theme/nuclear_detonation1.ogg','sound/theme/nuclear_detonation2.ogg') 
			human_track = pick('sound/theme/nuclear_detonation1.ogg','sound/theme/nuclear_detonation2.ogg')

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

		SEND_SOUND(M, pick('sound/misc/gone_to_plaid.ogg', 'sound/misc/good_is_dumb.ogg', 'sound/misc/hardon.ogg', 'sound/misc/surrounded_by_assholes.ogg', 'sound/misc/outstanding_marines.ogg', 'sound/misc/asses_kicked.ogg'))

	log_game("[round_finished]\nGame mode: [name]\nRound time: [duration2text()]\nEnd round player population: [length(GLOB.clients)]\nTotal xenos spawned: [GLOB.round_statistics.total_xenos_created]\nTotal humans spawned: [GLOB.round_statistics.total_humans_created]")

	announce_xenomorphs()
	announce_survivors()
	announce_medal_awards()
	announce_round_stats()


/datum/game_mode/distress/proc/initialize_scales()
	latejoin_larva_drop = CONFIG_GET(number/latejoin_larva_required_num)
	xeno_starting_num = max(round(GLOB.ready_players / (CONFIG_GET(number/xeno_number) + CONFIG_GET(number/xeno_coefficient) * GLOB.ready_players)), xeno_required_num)
	surv_starting_num = CLAMP((round(GLOB.ready_players / CONFIG_GET(number/survivor_coefficient))), 0, 8)
	marine_starting_num = GLOB.ready_players - xeno_starting_num - surv_starting_num

	var/current_smartgunners = 0
	var/maximum_smartgunners = CLAMP(GLOB.ready_players / CONFIG_GET(number/smartgunner_coefficient), 1, 4)
	var/current_specialists = 0
	var/maximum_specialists = CLAMP(GLOB.ready_players / CONFIG_GET(number/specialist_coefficient), 1, 4)

	var/datum/job/SG = SSjob.GetJobType(/datum/job/marine/smartgunner)
	SG.total_positions = maximum_smartgunners

	var/datum/job/SP = SSjob.GetJobType(/datum/job/marine/specialist)
	SP.total_positions = maximum_specialists

	for(var/i in SSjob.squads)
		var/datum/squad/S = SSjob.squads[i]
		if(current_specialists >= maximum_specialists)
			S.max_specialists = 0
		else
			S.max_specialists = 1
			current_specialists++
		if(current_smartgunners >= maximum_smartgunners)
			S.max_smartgun = 0
		else
			S.max_smartgun = 1
			current_smartgunners++


/datum/game_mode/distress/proc/initialize_survivor()
	var/list/possible_survivors = get_players_for_role(BE_SURVIVOR)
	if(!length(possible_survivors))
		return FALSE

	for(var/i in possible_survivors)
		var/datum/mind/new_survivor = i
		if(new_survivor.assigned_role || is_banned_from(new_survivor.current?.ckey, ROLE_SURVIVOR))
			continue
		new_survivor.assigned_role = "Survivor"
		survivors += new_survivor
		if(length(survivors) >= surv_starting_num)
			break

	if(!length(survivors))
		return FALSE

	return TRUE


/datum/game_mode/distress/proc/scale_gear()
	var/marine_pop_size = 0

	for(var/i in GLOB.alive_human_list)
		var/mob/living/carbon/human/H = i
		if(ismarine(H))
			marine_pop_size++

	var/scale = max(marine_pop_size / MARINE_GEAR_SCALING, 1) //This gives a decimal value representing a scaling multiplier. Cannot go below 1

	//Set up attachment vendor contents related to Marine count
	for(var/X in GLOB.attachment_vendors)
		var/obj/machinery/vending/attachments/A = X

		//Forcefully reset the product list
		A.product_records = list()

		A.products = list(
					/obj/item/attachable/suppressor = round(scale * 14),
					/obj/item/attachable/bayonet = round(scale * 14),
					/obj/item/attachable/compensator = round(scale * 10),
					/obj/item/attachable/extended_barrel = round(scale * 10),
					/obj/item/attachable/heavy_barrel = round(scale * 4),

					/obj/item/attachable/scope = round(scale * 4),
					/obj/item/attachable/scope/mini = round(scale * 4),
					/obj/item/attachable/flashlight = round(scale * 14),
					/obj/item/attachable/reddot = round(scale * 14),
					/obj/item/attachable/magnetic_harness = round(scale * 10),
					/obj/item/attachable/quickfire = round(scale * 3),

					/obj/item/attachable/verticalgrip = round(scale * 14),
					/obj/item/attachable/angledgrip = round(scale * 14),
					/obj/item/attachable/lasersight = round(scale * 14),
					/obj/item/attachable/gyro = round(scale * 4),
					/obj/item/attachable/bipod = round(scale * 8),
					/obj/item/attachable/burstfire_assembly = round(scale * 4),

					/obj/item/attachable/stock/shotgun = round(scale * 4),
					/obj/item/attachable/stock/rifle = round(scale * 4) ,
					/obj/item/attachable/stock/revolver = round(scale * 4),
					/obj/item/attachable/stock/smg = round(scale * 4) ,
					/obj/item/attachable/stock/tactical = round(scale * 3),

					/obj/item/attachable/attached_gun/grenade = round(scale * 10),
					/obj/item/attachable/attached_gun/shotgun = round(scale * 4),
					/obj/item/attachable/attached_gun/flamer = round(scale * 4)
					)

		//Rebuild the vendor's inventory to make our changes apply
		A.build_inventory(A.products)

	for(var/X in GLOB.cargo_ammo_vendors)
		var/obj/machinery/vending/marine/cargo_ammo/CA = X

		//Forcefully reset the product list
		CA.product_records = list()

		CA.products = list(
						/obj/item/ammobox/m4a3 = round(scale * 3),
						/obj/item/ammo_magazine/pistol = round(scale * 20),
						/obj/item/ammobox/m4a3ap = round(scale * 1),
						/obj/item/ammo_magazine/pistol/ap = round(scale * 5),
						/obj/item/ammobox/m4a3ext = round(scale * 1),
						/obj/item/ammo_magazine/pistol/extended = round(scale * 10),
						/obj/item/ammo_magazine/pistol/incendiary = round(scale * 5),
						/obj/item/ammo_magazine/pistol/m1911 = round(scale * 10),
						/obj/item/ammo_magazine/revolver = round(scale * 20),
						/obj/item/ammo_magazine/revolver/marksman = round(scale * 5),
						/obj/item/ammo_magazine/revolver/heavy = round(scale * 5),
						/obj/item/ammobox/m39 = round(scale * 3),
						/obj/item/ammo_magazine/smg/m39 = round(scale * 15),
						/obj/item/ammobox/m39ap = round(scale * 1),
						/obj/item/ammo_magazine/smg/m39/ap = round(scale * 5),
						/obj/item/ammobox/m39ext = round(scale * 1),
						/obj/item/ammo_magazine/smg/m39/extended = round(scale * 5),
						/obj/item/ammobox = round(scale * 3),
						/obj/item/ammo_magazine/rifle = round(scale * 15),
						/obj/item/ammobox/ap = round (scale * 1),
						/obj/item/ammo_magazine/rifle/ap = round(scale * 5),
						/obj/item/ammobox/ext = round(scale * 1),
						/obj/item/ammo_magazine/rifle/extended = round(scale * 5),
						/obj/item/cell/lasgun/M43 = round(scale * 30),
						/obj/item/cell/lasgun/M43/highcap = round(scale * 5),
						/obj/item/ammo_magazine/shotgunbox = round(scale * 3),
						/obj/item/ammo_magazine/shotgun = round(scale * 10),
						/obj/item/ammo_magazine/shotgunbox/buckshot = round(scale * 3),
						/obj/item/ammo_magazine/shotgun/buckshot = round(scale * 10),
						/obj/item/ammo_magazine/shotgunbox/flechette = round(scale * 3),
						/obj/item/ammo_magazine/shotgun/flechette = round(scale * 15),
						/obj/item/smartgun_powerpack = round(scale * 2)
						)

		CA.contraband = list(
						/obj/item/ammo_magazine/flamer_tank = round(scale * 5),
						/obj/item/ammo_magazine/pistol/vp70 = round(scale * 10),
						/obj/item/ammo_magazine/smg/ppsh/ = round(scale * 20),
						/obj/item/ammo_magazine/smg/ppsh/extended = round(scale * 5),
						/obj/item/ammo_magazine/rifle/bolt = round(scale * 10),
						)

		CA.build_inventory(CA.products)


	for(var/X in GLOB.cargo_guns_vendors)
		var/obj/machinery/vending/marine/cargo_guns/CG = X

		//Forcefully reset the product list
		CG.product_records = list()

		CG.products = list(
						/obj/item/storage/backpack/marine/standard = round(scale * 15),
						/obj/item/storage/backpack/marine/satchel = round(scale * 15),
						/obj/item/storage/large_holster/machete/full = round(scale * 10),
						/obj/item/storage/large_holster/m37 = round(scale * 10),
						/obj/item/storage/belt/marine = round(scale * 15),
						/obj/item/storage/belt/shotgun = round(scale * 10),
						/obj/item/storage/belt/grenade = round(scale * 5),
						/obj/item/storage/belt/gun/m4a3 = round(scale * 10),
						/obj/item/storage/belt/gun/m44 = round(scale * 5),
						/obj/item/storage/large_holster/m39 = round(scale * 5),
						/obj/item/clothing/tie/storage/webbing = round(scale * 5),
						/obj/item/clothing/tie/storage/brown_vest = round(scale * 5),
						/obj/item/clothing/tie/storage/white_vest/medic = round(scale * 5),
						/obj/item/clothing/tie/holster = round(scale * 5),
						/obj/item/storage/pouch/general/medium = round(scale * 5),
						/obj/item/storage/pouch/general/large = round(scale * 2),
						/obj/item/storage/pouch/construction = round(scale * 5),
						/obj/item/storage/pouch/tools = round(scale * 5),
						/obj/item/storage/pouch/explosive = round(scale * 5),
						/obj/item/storage/pouch/syringe = round(scale * 5),
						/obj/item/storage/pouch/medical = round(scale * 5),
						/obj/item/storage/pouch/medkit = round(scale * 5),
						/obj/item/storage/pouch/magazine = round(scale * 5),
						/obj/item/storage/pouch/magazine/large = round(scale * 2),
						/obj/item/storage/pouch/flare/full = round(scale * 5),
						/obj/item/storage/pouch/firstaid/full = round(scale * 5),
						/obj/item/storage/pouch/pistol = round(scale * 10),
						/obj/item/storage/pouch/magazine/pistol = round(scale * 10),
						/obj/item/storage/pouch/magazine/pistol/large = round(scale * 5),
						/obj/item/storage/pouch/shotgun = round(scale * 10),
						/obj/item/weapon/gun/pistol/m4a3 = round(scale * 20),
						/obj/item/weapon/gun/pistol/m1911 = round(scale * 5),
						/obj/item/weapon/gun/revolver/m44 = round(scale * 10),
						/obj/item/weapon/gun/smg/m39 = round(scale * 15),
						/obj/item/weapon/gun/rifle/m41a = round(scale * 20),
						/obj/item/weapon/gun/shotgun/pump = round(scale * 10),
						/obj/item/weapon/gun/energy/lasgun/M43 = round(scale * 10),
						/obj/item/explosive/mine = round(scale * 2),
						/obj/item/explosive/grenade/frag/m15 = round(scale * 2),
						/obj/item/explosive/grenade/incendiary = round(scale * 4),
						/obj/item/explosive/grenade/smokebomb = round(scale * 5),
						/obj/item/explosive/grenade/cloakbomb = round(scale * 4),
						/obj/item/storage/box/nade_box = round(scale * 2),
						/obj/item/storage/box/m94 = round(scale * 30),
						/obj/item/flashlight/combat = round(scale * 5),
						/obj/item/clothing/mask/gas = round(scale * 10)
						)

		CG.contraband = list(
						/obj/item/storage/box/nade_box/HIDP = round(scale * 1),
						/obj/item/storage/box/nade_box/M15 = round(scale * 1),
						/obj/item/weapon/gun/flamer = round(scale * 2),
						/obj/item/weapon/gun/pistol/vp70 = round(scale * 2),
						/obj/item/weapon/gun/smg/ppsh = round(scale * 2),
						/obj/item/weapon/gun/shotgun/double = round(scale * 2),
						/obj/item/weapon/gun/shotgun/pump/ksg = round(scale * 2),
						/obj/item/weapon/gun/shotgun/pump/bolt = round(scale * 2)
						)

		CG.build_inventory(CG.products)



	for(var/obj/machinery/vending/marine/M in GLOB.marine_vendors)

		//Forcefully reset the product list
		M.product_records = list()

		M.products = list(
						/obj/item/weapon/gun/pistol/m4a3 = round(scale * 30),
						/obj/item/weapon/gun/revolver/m44 = round(scale * 25),
						/obj/item/weapon/gun/smg/m39 = round(scale * 30),
						/obj/item/weapon/gun/rifle/m41a = round(scale * 30),
						/obj/item/weapon/gun/shotgun/pump = round(scale * 15),
						/obj/item/weapon/gun/energy/lasgun/M43 = round(scale * 15),

						/obj/item/ammo_magazine/pistol = round(scale * 30),
						/obj/item/ammo_magazine/revolver = round(scale * 20),
						/obj/item/ammo_magazine/smg/m39 = round(scale * 30),
						/obj/item/ammo_magazine/rifle = round(scale * 25),
						/obj/item/ammo_magazine/shotgun = round(scale * 10),
						/obj/item/ammo_magazine/shotgun/buckshot = round(scale * 10),
						/obj/item/ammo_magazine/shotgun/flechette = round(scale * 10),
						/obj/item/cell/lasgun/M43 = round(scale * 25),

						/obj/item/weapon/combat_knife = round(scale * 30),
						/obj/item/weapon/throwing_knife = round(scale * 10),
						/obj/item/storage/box/m94 = round(scale * 10),

						/obj/item/attachable/flashlight = round(scale * 25),
						/obj/item/attachable/bayonet = round(scale * 25)
						)

		M.contraband =   list(/obj/item/ammo_magazine/revolver/marksman = round(scale * 2),
							/obj/item/ammo_magazine/pistol/ap = round(scale * 2),
							/obj/item/ammo_magazine/smg/m39/ap = round(scale * 2)
							)

		//Rebuild the vendor's inventory to make our changes apply
		M.build_inventory(M.products)
		M.build_inventory(M.contraband, TRUE)


	//Scale the amount of cargo points through a direct multiplier
	SSpoints.scale_supply_points(scale)


/datum/game_mode/distress/proc/announce_xenomorphs()
	if(!length(xenomorphs))
		return

	var/dat = "<span class='round_body'>The xenomorph ruler(s) were:</span>"

	for(var/i in xenomorphs)
		var/datum/mind/M = i
		if(!M?.assigned_role || M.assigned_role != ROLE_XENO_QUEEN)
			continue
		dat += "<br>[M.key] was [M.current ? M.current : "Queen"] <span class='boldnotice'>([!M?.current?.stat ? "DIED": "SURVIVED"])</span>"

	to_chat(world, dat)


/datum/game_mode/distress/proc/announce_survivors()
	if(!length(survivors))
		return

	var/dat = "<span class='round_body'>The survivors were:</span>"

	for(var/i in survivors)
		var/datum/mind/M = i
		if(!M?.assigned_role)
			continue
		dat += "<br>[M.key] was [M.name] <span class='boldnotice'>([!M?.current?.stat ? "DIED" : "SURVIVED"])</span>"

	to_chat(world, dat)

/datum/game_mode/distress/mode_new_player_panel(mob/new_player/NP)

	var/output = "<div align='center'>"
	output += "<p><a href='byond://?src=[REF(NP)];lobby_choice=show_preferences'>Setup Character</A></p>"

	if(SSticker.current_state <= GAME_STATE_PREGAME)
		output += "<p>\[ [NP.ready? "<b>Ready</b>":"<a href='byond://?src=\ref[src];lobby_choice=ready'>Ready</a>"] | [NP.ready? "<a href='byond://?src=[REF(NP)];lobby_choice=ready'>Not Ready</a>":"<b>Not Ready</b>"] \]</p>"
	else
		output += "<a href='byond://?src=[REF(NP)];lobby_choice=manifest'>View the Crew Manifest</A><br><br>"
		output += "<p><a href='byond://?src=[REF(NP)];lobby_choice=late_join'>Join the TGMC!</A></p>"
		output += "<p><a href='byond://?src=[REF(NP)];lobby_choice=late_join_xeno'>Join the Hive!</A></p>"

	output += "<p><a href='byond://?src=[REF(NP)];lobby_choice=observe'>Observe</A></p>"
	
	output += append_player_votes_link(NP)

	output += "</div>"

	var/datum/browser/popup = new(NP, "playersetup", "<div align='center'>New Player Options</div>", 240, 300)
	popup.set_window_options("can_close=0")
	popup.set_content(output)
	popup.open(FALSE)

	return TRUE


/datum/game_mode/distress/check_queen_status(queen_time)
	var/datum/hive_status/hive = GLOB.hive_datums[XENO_HIVE_NORMAL]
	hive.xeno_queen_timer = queen_time
	queen_death_countdown = 0
	if(!(flags_round_type & MODE_INFESTATION))
		return
	if(!round_finished && !hive.living_xeno_ruler)
		round_finished = MODE_INFESTATION_M_MINOR


/datum/game_mode/distress/get_queen_countdown()
	var/eta = (queen_death_countdown - world.time) * 0.1
	if(eta > 0)
		return "[(eta / 60) % 60]:[add_zero(num2text(eta % 60), 2)]"


/datum/game_mode/distress/handle_late_spawn()
	var/datum/game_mode/distress/D = SSticker.mode
	D.latejoin_tally++

	if(D.latejoin_larva_drop && D.latejoin_tally >= D.latejoin_larva_drop)
		D.latejoin_tally -= D.latejoin_larva_drop
		var/datum/hive_status/normal/HS = GLOB.hive_datums[XENO_HIVE_NORMAL]
		HS.stored_larva++


/datum/game_mode/distress/attempt_to_join_as_larva(mob/xeno_candidate)
	var/datum/hive_status/normal/HS = GLOB.hive_datums[XENO_HIVE_NORMAL]
	return HS.attempt_to_spawn_larva(xeno_candidate)


/datum/game_mode/distress/spawn_larva(mob/xeno_candidate, mob/living/carbon/xenomorph/mother)
	var/datum/hive_status/normal/HS = GLOB.hive_datums[XENO_HIVE_NORMAL]
	return HS.spawn_larva(xeno_candidate, mother)
