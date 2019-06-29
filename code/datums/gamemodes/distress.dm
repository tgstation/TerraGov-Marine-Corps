/datum/game_mode/distress
	name = "Distress Signal"
	config_tag = "Distress Signal"
	required_players = 2
	flags_round_type = MODE_INFESTATION|MODE_FOG_ACTIVATED
	flags_landmarks = MODE_LANDMARK_SPAWN_XENO_TUNNELS|MODE_LANDMARK_SPAWN_MAP_ITEM

	var/list/survivors = list()

	var/xeno_required_num 	  = 1
	var/xeno_starting_num 	  = 0
	var/surv_starting_num 	  = 0
	var/marine_starting_num   = 0

	var/bioscan_current_interval = 45 MINUTES
	var/bioscan_ongoing_interval = 20 MINUTES

	var/list/xenomorphs = list()
	var/latejoin_tally		= 0
	var/latejoin_larva_drop = 0
	var/queen_death_countdown = 0


/datum/game_mode/distress/announce()
	to_chat(world, "<span class='round_header'>The current map is - [SSmapping.configs[GROUND_MAP].map_name]!</span>")


/datum/game_mode/distress/can_start()
	. = ..()
	initialize_scales()
	var/found_queen = initialize_queen()
	var/found_xenos = initialize_xenomorphs()
	if(!found_queen && !found_xenos)
		return FALSE
	initialize_survivor()
	return TRUE


/datum/game_mode/distress/pre_setup()
	. = ..()
	var/number_of_xenos = length(xenomorphs)
	for(var/i in xenomorphs)
		var/datum/mind/M = i
		if(M.assigned_role == ROLE_XENO_QUEEN)
			transform_queen(M, number_of_xenos)
		else
			transform_xeno(M)

	for(var/i in survivors)
		var/datum/mind/M = i
		transform_survivor(M)

	scale_gear()

	addtimer(CALLBACK(SSticker.mode, .proc/map_announce), 5 SECONDS)


/datum/game_mode/distress/proc/map_announce()
	if(!SSmapping.configs[GROUND_MAP].announce_text)
		return

	priority_announce(SSmapping.configs[GROUND_MAP].announce_text, "[CONFIG_GET(string/ship_name)]")


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

	to_chat(world, "<span class='round_body'>Thus ends the story of the brave men and women of the [CONFIG_GET(string/ship_name)] and their struggle on [SSmapping.configs[GROUND_MAP].map_name].</span>")
	var/musical_track
	switch(round_finished)
		if(MODE_INFESTATION_X_MAJOR)
			musical_track = pick('sound/theme/sad_loss1.ogg','sound/theme/sad_loss2.ogg')
		if(MODE_INFESTATION_M_MAJOR)
			musical_track = pick('sound/theme/winning_triumph1.ogg','sound/theme/winning_triumph2.ogg')
		if(MODE_INFESTATION_X_MINOR)
			musical_track = pick('sound/theme/neutral_melancholy1.ogg','sound/theme/neutral_melancholy2.ogg')
		if(MODE_INFESTATION_M_MINOR)
			musical_track = pick('sound/theme/neutral_hopeful1.ogg','sound/theme/neutral_hopeful2.ogg')
		if(MODE_INFESTATION_DRAW_DEATH)
			musical_track = pick('sound/theme/nuclear_detonation1.ogg','sound/theme/nuclear_detonation2.ogg') //This one is unlikely to play.

	SEND_SOUND(world, musical_track)

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



/datum/game_mode/distress/proc/initialize_xenomorphs()
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


/datum/game_mode/distress/proc/initialize_queen()
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

/datum/game_mode/distress/proc/transform_xeno(datum/mind/M)
	var/mob/living/carbon/xenomorph/larva/X = new (pick(GLOB.xeno_spawn))

	if(isnewplayer(M.current))
		var/mob/new_player/N = M.current
		N.close_spawn_windows()

	M.transfer_to(X, TRUE)

	to_chat(X, "<B>You are now an alien!</B>")
	to_chat(X, "<B>Your job is to spread the hive and protect the Queen. If there's no Queen, you can become the Queen yourself by evolving into a drone.</B>")
	to_chat(X, "Talk in Hivemind using <strong>;</strong>, <strong>.a</strong>, or <strong>,a</strong> (e.g. ';My life for the queen!')")

	X.update_icons()


/datum/game_mode/distress/proc/transform_queen(datum/mind/M, number_of_xenos)
	var/mob/living/carbon/xenomorph/X
	var/datum/hive_status/normal/HN = GLOB.hive_datums[XENO_HIVE_NORMAL]
	if(number_of_xenos < HN.xenos_per_queen)
		X = new /mob/living/carbon/xenomorph/shrike(pick(GLOB.xeno_spawn))
	else
		X = new /mob/living/carbon/xenomorph/queen(pick(GLOB.xeno_spawn))

	if(isnewplayer(M.current))
		var/mob/new_player/N = M.current
		N.close_spawn_windows()

	M.transfer_to(X, TRUE)

	to_chat(X, "<B>You are now the alien ruler!</B>")
	to_chat(X, "<B>Your job is to spread the hive.</B>")
	to_chat(X, "Talk in Hivemind using <strong>;</strong>, <strong>.a</strong>, or <strong>,a</strong> (e.g. ';My life for the hive!')")

	X.update_icons()


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
						/obj/item/storage/large_holster/machete/full = round(scale * 10),
						/obj/item/ammo_magazine/pistol = round(scale * 20),
						/obj/item/ammobox/m4a3 = round(scale * 3),
						/obj/item/ammo_magazine/pistol/ap = round(scale * 5),
						/obj/item/ammobox/m4a3ap = round(scale * 3),
						/obj/item/ammo_magazine/pistol/incendiary = round(scale * 2),
						/obj/item/ammo_magazine/pistol/extended = round(scale * 10),
						/obj/item/ammobox/m4a3ext = round(scale * 3),
						/obj/item/ammo_magazine/pistol/m1911 = round(scale * 10),
						/obj/item/ammo_magazine/revolver = round(scale * 20),
						/obj/item/ammo_magazine/revolver/marksman = round(scale * 5),
						/obj/item/ammobox/m39 = round(scale * 3),
						/obj/item/ammo_magazine/smg/m39 = round(scale * 15),
						/obj/item/ammobox/m39ap = round(scale * 1),
						/obj/item/ammo_magazine/smg/m39/ap = round(scale * 5),
						/obj/item/ammobox/m39ext = round(scale * 1),
						/obj/item/ammo_magazine/smg/m39/extended = round(scale * 5),
						/obj/item/ammobox = round(scale * 3),
						/obj/item/ammo_magazine/rifle = round(scale * 15),
						/obj/item/ammobox/ext = round(scale * 1),
						/obj/item/ammo_magazine/rifle/extended = round(scale * 5),
						/obj/item/ammobox/ap = round (scale * 1),
						/obj/item/ammo_magazine/rifle/ap = round(scale * 5),
						/obj/item/ammo_magazine/shotgunbox = round(scale * 3),
						/obj/item/ammo_magazine/shotgun = round(scale * 10),
						/obj/item/ammo_magazine/shotgunbox/buckshot = round(scale * 3),
						/obj/item/ammo_magazine/shotgun/buckshot = round(scale * 10),
						/obj/item/ammo_magazine/shotgunbox/flechette = round(scale * 3),
						/obj/item/ammo_magazine/shotgun/flechette = round(scale * 15),
						/obj/item/cell/lasgun/M43 = round(scale * 30),
						/obj/item/cell/lasgun/M43/highcap = round(scale * 5),
						/obj/item/smartgun_powerpack = round(scale * 2)
						)

		CA.contraband = list(
						/obj/item/ammo_magazine/smg/ppsh/ = round(scale * 20),
						/obj/item/ammo_magazine/smg/ppsh/extended = round(scale * 4),
						/obj/item/ammo_magazine/rifle/bolt = round(scale * 10),
						/obj/item/ammo_magazine/sniper = 0,
						/obj/item/ammo_magazine/sniper/incendiary = 0,
						/obj/item/ammo_magazine/sniper/flak = 0,
						/obj/item/ammo_magazine/rifle/m4ra = 0,
						/obj/item/ammo_magazine/rifle/incendiary = 0,
						/obj/item/ammo_magazine/rifle/m41aMK1 = 0,
						/obj/item/ammo_magazine/rifle/lmg = 0,
						/obj/item/ammo_magazine/pistol/hp = 0,
						/obj/item/ammo_magazine/pistol/heavy = 0,
						/obj/item/ammo_magazine/pistol/holdout = 0,
						/obj/item/ammo_magazine/pistol/highpower = 0,
						/obj/item/ammo_magazine/pistol/vp70 = 0,
						/obj/item/ammo_magazine/revolver/small = 0,
						/obj/item/ammo_magazine/revolver/cmb = 0,
						/obj/item/ammo_magazine/smg/mp7 = 0,
						/obj/item/ammo_magazine/smg/skorpion = 0,
						/obj/item/ammo_magazine/smg/uzi = 0,
						/obj/item/ammo_magazine/smg/p90 = 0
						)

		CA.build_inventory(CA.products)


	for(var/X in GLOB.cargo_guns_vendors)
		var/obj/machinery/vending/marine/cargo_guns/CG = X

		//Forcefully reset the product list
		CG.product_records = list()

		CG.products = list(
						/obj/item/storage/backpack/marine/standard = round(scale * 15),
						/obj/item/storage/belt/marine = round(scale * 15),
						/obj/item/storage/belt/shotgun = round(scale * 10),
						/obj/item/clothing/tie/storage/webbing = round(scale * 3),
						/obj/item/clothing/tie/storage/brown_vest = round(scale * 1),
						/obj/item/clothing/tie/holster = round(scale * 1),
						/obj/item/storage/belt/gun/m4a3 = round(scale * 10),
						/obj/item/storage/belt/gun/m44 = round(scale * 5),
						/obj/item/storage/large_holster/m39 = round(scale * 5),
						/obj/item/storage/pouch/general/medium = round(scale * 2),
						/obj/item/storage/pouch/construction = round(scale * 2),
						/obj/item/storage/pouch/tools = round(scale * 2),
						/obj/item/storage/pouch/explosive = round(scale * 2),
						/obj/item/storage/pouch/syringe = round(scale * 2),
						/obj/item/storage/pouch/medical = round(scale * 2),
						/obj/item/storage/pouch/medkit = round(scale * 2),
						/obj/item/storage/pouch/magazine = round(scale * 5),
						/obj/item/storage/pouch/flare/full = round(scale * 5),
						/obj/item/storage/pouch/firstaid/full = round(scale * 5),
						/obj/item/storage/pouch/pistol = round(scale * 10),
						/obj/item/storage/pouch/magazine/pistol/large = round(scale * 5),
						/obj/item/storage/pouch/shotgun = round(scale * 10),
						/obj/item/weapon/gun/pistol/m4a3 = round(scale * 20),
						/obj/item/weapon/gun/pistol/m1911 = round(scale * 2),
						/obj/item/weapon/gun/revolver/m44 = round(scale * 10),
						/obj/item/weapon/gun/smg/m39 = round(scale * 15),
						/obj/item/weapon/gun/rifle/m41a = round(scale * 20),
						/obj/item/weapon/gun/shotgun/pump = round(scale * 10),
						/obj/item/weapon/gun/energy/lasgun/M43 = round(scale * 10),
						/obj/item/explosive/mine = round(scale * 2),
						/obj/item/storage/box/nade_box = round(scale * 2),
						/obj/item/storage/box/nade_box/impact = round(scale * 2),
						/obj/item/explosive/grenade/frag/m15 = round(scale * 2),
						/obj/item/explosive/grenade/incendiary = round(scale * 4),
						/obj/item/explosive/grenade/smokebomb = round(scale * 5),
						/obj/item/explosive/grenade/cloakbomb = round(scale * 3),
						/obj/item/storage/box/m94 = round(scale * 30),
						/obj/item/flashlight/combat = round(scale * 5),
						/obj/item/clothing/mask/gas = round(scale * 10)
						)

		CG.contraband = list(
						/obj/item/weapon/gun/smg/ppsh = round(scale * 4),
						/obj/item/weapon/gun/shotgun/double = round(scale * 2),
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
			if(QDELETED(src))
				return FALSE

	output += "</div>"

	var/datum/browser/popup = new(NP, "playersetup", "<div align='center'>New Player Options</div>", 240, 300)
	popup.set_window_options("can_close=0")
	popup.set_content(output)
	popup.open(FALSE)

	return TRUE


/datum/game_mode/distress/proc/announce_bioscans(delta = 2)
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


	for(var/i in GLOB.alive_xeno_list)
		var/mob/M = i
		SEND_SOUND(M, sound(get_sfx("queen"), wait = 0, volume = 50))
		to_chat(M, "<span class='xenoannounce'>The Queen Mother reaches into your mind from worlds away.</span>")
		to_chat(M, "<span class='xenoannounce'>To my children and their Queen. I sense [numHostsShipr ? "approximately [numHostsShipr]":"no"] host[numHostsShipr > 1 ? "s":""] in the metal hive[numHostsShipr > 0 && hostLocationS ? ", including one in [hostLocationS]":""] and [numHostsPlanet ? "[numHostsPlanet]":"none"] scattered elsewhere[hostLocationP ? ", including one in [hostLocationP]":""].</span>")

	var/xenoLocationP
	var/xenoLocationS

	if(length(xenoLocationsP))
		xenoLocationP = pick(xenoLocationsP)

	if(length(xenoLocationsS))
		xenoLocationS = pick(xenoLocationsS)

	var/name = "[MAIN_AI_SYSTEM] Bioscan Status"
	var/input = {"Bioscan complete.

Sensors indicate [numXenosShip ? "[numXenosShip]" : "no"] unknown lifeform signature[numXenosShip > 1 ? "s":""] present on the ship[xenoLocationS ? " including one in [xenoLocationS]" : ""] and [numXenosPlanetr ? "approximately [numXenosPlanetr]":"no"] signature[numXenosPlanetr > 1 ? "s":""] located elsewhere[numXenosPlanetr > 0 && xenoLocationP ? ", including one in [xenoLocationP]":""]."}
	
	priority_announce(input, name, sound = 'sound/AI/bioscan.ogg')

	log_game("Bioscan. Humans: [numHostsPlanet] on the planet[hostLocationP ? " Location:[hostLocationP]":""] and [numHostsShip] on the ship.[hostLocationS ? " Location: [hostLocationS].":""] Xenos: [numXenosPlanetr] on the planet and [numXenosShip] on the ship[xenoLocationP ? " Location:[xenoLocationP]":""].")

	for(var/i in GLOB.observer_list)
		var/mob/M = i
		to_chat(M, "<h2 class='alert'>Detailed Information</h2>")
		to_chat(M, {"<span class='alert'>[numXenosPlanet] xeno\s on the planet, including [numLarvaPlanet] larva.
[numXenosShip] xeno\s on the ship, including [numLarvaShip] larva.
[numHostsPlanet] human\s on the planet.
[numHostsShip] human\s on the ship.</span>"})

	message_admins("Bioscan - Humans: [numHostsPlanet] on the planet[hostLocationP ? ". Location:[hostLocationP]":""]. [numHostsShipr] on the ship.[numHostsShipr && hostLocationS ? " Location: [hostLocationS].":""]")
	message_admins("Bioscan - Xenos: [numXenosPlanetr] on the planet[numXenosPlanetr > 0 && xenoLocationP ? ". Location:[xenoLocationP]":""]. [numXenosShip] on the ship.[xenoLocationS ? " Location: [xenoLocationS].":""]")



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
