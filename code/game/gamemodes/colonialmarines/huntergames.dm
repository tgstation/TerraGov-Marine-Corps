#define HUNTER_LOOTBOX  pick(\
								150; list(/obj/item/stack/medical/advanced/ointment, \
										/obj/item/stack/medical/advanced/bruise_pack, \
										/obj/item/storage/belt/combatLifesaver), \
								125; list(/obj/item/weapon/yautja_chain, \
										 /obj/item/weapon/yautja_knife, \
										 /obj/item/weapon/yautja_scythe, \
										 /obj/item/legcuffs/yautja, \
										 /obj/item/legcuffs/yautja), \
								100; list(/obj/item/weapon/twohanded/glaive, \
										/obj/item/clothing/mask/gas/yautja, \
										/obj/item/clothing/suit/armor/yautja, \
										/obj/item/clothing/shoes/yautja), \
								75; list(/obj/item/clothing/glasses/night, \
										/obj/item/storage/backpack/holding, \
										/obj/item/storage/belt/grenade, \
										/obj/item/weapon/gun/flamer), \
								75; list(/obj/item/weapon/gun/revolver/mateba/admiral,\
										/obj/item/ammo_magazine/revolver/mateba,\
										/obj/item/ammo_magazine/revolver/mateba,\
										/obj/item/clothing/mask/balaclava/tactical),\
								50; list(/obj/item/weapon/combistick, \
										/obj/item/clothing/mask/gas/yautja, \
										/obj/item/clothing/suit/armor/yautja/full, \
										/obj/item/clothing/shoes/yautja), \
								50; list(/obj/item/clothing/under/marine/veteran/PMC/commando, \
										/obj/item/clothing/suit/storage/marine/veteran/PMC/commando, \
										/obj/item/clothing/gloves/marine/veteran/PMC/commando, \
										/obj/item/clothing/shoes/veteran/PMC/commando, \
										/obj/item/clothing/head/helmet/marine/veteran/PMC/commando), \
								50; list(/obj/item/weapon/shield/energy, \
										/obj/item/weapon/energy/axe, \
										/obj/item/clothing/under/gladiator, \
										/obj/item/clothing/head/helmet/gladiator))

#define HUNTER_GOOD_ITEM  pick(\
								200; /obj/item/weapon/claymore/mercsword/machete, \
								170; /obj/item/clothing/suit/armor/vest/security, \
								165; /obj/item/clothing/head/helmet/riot, \
								160; /obj/item/clothing/gloves/marine/veteran/PMC, \
								150; /obj/item/weapon/claymore/mercsword, \
								125; /obj/item/weapon/twohanded/fireaxe, \
								100; /obj/item/storage/backpack/commando, \
								100; /obj/item/storage/backpack/yautja, \
								100; /obj/item/storage/belt/knifepouch, \
								100; /obj/item/storage/belt/utility/full, \
								100; /obj/item/clothing/tie/storage/webbing, \
								100; /obj/item/weapon/claymore, \
								100; /obj/item/weapon/katana, \
								100; /obj/item/weapon/harpoon/yautja, \
								100; /obj/item/device/binoculars, \
								100; /obj/item/explosive/grenade/frag, \
								100; /obj/item/explosive/grenade/incendiary, \
								75; /obj/item/storage/box/wy_mre, \
								50; /obj/item/device/flash, \
								50; /obj/item/explosive/plastique, \
								50; /obj/item/weapon/shield/riot, \
								50; /obj/item/storage/firstaid/regular, \
								50; /obj/item/storage/firstaid/fire, \
								25; /obj/item/explosive/grenade/flashbang, \
								25; /obj/item/legcuffs/yautja)

#define HUNTER_OKAY_ITEM  pick(\
								400; /obj/item/weapon/twohanded/spear, \
								300; /obj/item/tool/crowbar, \
								300; /obj/item/tool/hatchet, \
								200; /obj/item/weapon/baseballbat, \
								200; /obj/item/weapon/throwing_knife, \
								250; /obj/item/device/flashlight/flare, \
								100; /obj/item/weapon/baseballbat/metal, \
								100; /obj/item/weapon/butterfly, \
								100; /obj/item/weapon/harpoon, \
								100; /obj/item/tool/scythe, \
								100; /obj/item/tool/kitchen/knife/butcher, \
								100; /obj/item/cell/high, \
								100; /obj/item/tool/wirecutters, \
								100; /obj/item/tool/weldingtool, \
								100; /obj/item/tool/wrench, \
								100; /obj/item/device/multitool, \
								100; /obj/item/storage/backpack, \
								100; /obj/item/storage/backpack/cultpack, \
								100; /obj/item/storage/backpack/satchel, \
								100; /obj/item/clothing/suit/storage/CMB, \
								75; /obj/item/storage/pill_bottle/tramadol, \
								75; /obj/item/weapon/combat_knife, \
								75; /obj/item/device/flashlight, \
								75; /obj/item/device/flashlight/combat, \
								75; /obj/item/stack/medical/bruise_pack, \
								75; /obj/item/stack/medical/ointment, \
								75; /obj/item/reagent_container/food/snacks/donkpocket, \
								75; /obj/item/clothing/gloves/brown, \
								50; /obj/item/weapon/katana/replica, \
								50; /obj/item/explosive/grenade/smokebomb, \
								50; /obj/item/explosive/grenade/empgrenade, \
								25; /obj/item/bananapeel, \
								25; /obj/item/tool/soap)

#define HUNTER_BODY list(\
							/obj/item/clothing/under/marine,\
							/obj/item/clothing/under/marine/mp,\
							/obj/item/clothing/under/marine/officer/command,\
							/obj/item/clothing/under/liaison_suit,\
							/obj/item/clothing/under/marine/veteran/PMC,\
							/obj/item/clothing/under/marine/veteran/dutch,\
							/obj/item/clothing/under/marine/veteran/bear,\
							/obj/item/clothing/under/kilt,\
							/obj/item/clothing/under/syndicate,\
							/obj/item/clothing/under/CM_uniform)

#define HUNTER_FEET list(\
							/obj/item/clothing/shoes/marine,\
							/obj/item/clothing/shoes/marinechief/commander,\
							/obj/item/clothing/shoes/laceup,\
							/obj/item/clothing/shoes/jackboots)

var/waiting_for_drop_votes = 0



/datum/game_mode/huntergames
	name = "Hunter Games"
	config_tag = "Hunter Games"
	required_players = 1
	flags_round_type = MODE_NO_LATEJOIN

	var/last_count
	var/primary_spawns[]
	var/secondary_spawns[]
	var/supply_votes[]

/obj/effect/step_trigger/hell_hound_blocker/Trigger(mob/living/carbon/hellhound/H)
	if(istype(H))
		H.gib() //No mercy.

/datum/game_mode/huntergames/announce()
	return TRUE

/datum/game_mode/huntergames/send_intercept()
	return TRUE

/datum/game_mode/huntergames/pre_setup()
	primary_spawns = list()
	secondary_spawns = list()
	supply_votes = list()

	for(var/obj/effect/landmark/L in GLOB.landmarks_list)
		switch(L.name)
			if("hunter_primary")
				primary_spawns += L.loc
			if("hunter_secondary")
				secondary_spawns += L.loc
			if("crap_item")
				place_initial_item(L.loc, HUNTER_OKAY_ITEM)
			if("good_item")
				place_initial_item(L.loc, HUNTER_GOOD_ITEM)
			if("block_hellhound")
				new /obj/effect/step_trigger/hell_hound_blocker(L.loc)
			if("fog blocker")
				qdel(L)
			if("xeno tunnel")
				qdel(L)

	for(var/obj/item/weapon/gun/G in GLOB.item_list)
		qdel(G) //No guns or ammo allowed.
	for(var/obj/item/ammo_magazine/M in GLOB.item_list)
		qdel(M)

	for(var/mob/new_player/player in GLOB.player_list)
		if(player && player.ready)
			if(!player.mind && player.client)
				player.mind = new /datum/mind(player.key)
			player.mind.assigned_role = "ROLE"

	return TRUE

/datum/game_mode/huntergames/post_setup()
	var/mob/M
	for(M in GLOB.mob_list)
		if(M.client && ishuman(M))
			var/mob/living/carbon/human/H = M
			spawn_contestant(H)

	CONFIG_SET(flag/remove_gun_restrictions, TRUE) //This will allow anyone to use cool guns.

	world << sound('sound/effects/siren.ogg')

	spawn(1000)
		lootbox()

/datum/game_mode/huntergames/proc/spawn_contestant(var/mob/living/carbon/H)
	var/turf/picked

	if(primary_spawns.len)
		picked = pick(primary_spawns)
		primary_spawns -= picked
	else
		if(secondary_spawns.len)
			picked = pick(secondary_spawns)
		else
			regenerate_spawns()
			spawn_contestant(H)
			return

	if(H.contents.len)
		for(var/I in H.contents)
			qdel(I)

	H.loc = picked

	if(H.client)
		H.name = H.client.prefs.real_name
		H.client.change_view(world.view)

	if(!H.mind)
		H.mind = new /datum/mind(H.key)

	H.mind.cm_skills = null //no restriction on what the contestants can do

	H.set_nutrition(NUTRITION_LEVEL_START_MIN)

	var/hunter_body = pick(HUNTER_BODY)
	var/hunter_feet = pick(HUNTER_FEET)

	H.equip_to_slot_or_del(new hunter_body(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new hunter_feet(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/device/flashlight/flare(H), SLOT_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/general(H), SLOT_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar(H), SLOT_IN_R_POUCH)

	to_chat(H, "<h2>Kill everyone. Become the last man standing.</h2>")
	to_chat(H, "<h4>Use the flare in your pocket to light the way!</h4>")
	to_chat(H, "<h4>Use the crowbar in your pouch to open the way!</h4>")

	return TRUE

/datum/game_mode/huntergames/proc/lootbox()
	while(round_finished == 0)
		to_chat(world, "<span class='round_body'>Your Predator capturers have decided it is time to bestow a gift upon the scurrying humans.</span>")
		to_chat(world, "<span class='round_body'>One lucky contestant should prepare for a supply drop in 60 seconds.</span>")
		for(var/mob/dead/D in GLOB.dead_mob_list)
			to_chat(D, "<span class='round_body'>Now is your chance to vote for a supply drop beneficiary! Go to Ghost tab, Spectator Vote!</span>")
		world << sound('sound/effects/alert.ogg')
		waiting_for_drop_votes = 1
		sleep(600)
		if(!supply_votes.len)
			to_chat(world, "<span class='round_body'>Nobody got anything! .. weird.</span>")
			waiting_for_drop_votes = 0
			supply_votes = list()
		else
			var/mob/living/carbon/human/winner = pick(supply_votes) //Way it works is, more votes = more odds of winning. But not guaranteed.
			if(istype(winner) && !winner.stat)
				to_chat(world, "<span class='round_body'>The spectator and Predator votes have been tallied, and the supply drop recipient is <B>[winner.real_name]</B>! Congrats!</span>")
				world << sound('sound/effects/alert.ogg')
				to_chat(world, "<span class='round_body'>The package will shortly be dropped off at: [get_area(winner.loc)].</span>")
				var/turf/drop_zone = locate(winner.x + rand(-2,2),winner.y + rand(-2,2),winner.z)
				if(istype(drop_zone))
					playsound(drop_zone,'sound/effects/bamf.ogg', 50, 1)
					place_lootbox(drop_zone)
			else
				to_chat(world, "<span class='round_body'>The spectator and Predator votes have been talled, and the supply drop recipient is dead or dying<B>. Bummer.</b></span>")
				world << sound('sound/misc/sadtrombone.ogg')
			supply_votes = list()
			waiting_for_drop_votes = 0
		sleep(5000)

/datum/game_mode/huntergames/process()
	if(--round_started > 0)
		return FALSE

	if(!round_finished)
		if(++round_checkwin >= 5) //Only check win conditions every 5 ticks.
			check_win()
			round_checkwin = 0

/datum/game_mode/huntergames/check_win()
	var/C = count_humans()
	if(C < last_count)
		if(last_count - C == 1)
			to_chat(world, "<span class='round_body'>A contestant has died! There are now [C] contestants remaining!</span>")
			world << sound('sound/effects/explosionfar.ogg')
		else
			var/diff = last_count - C
			to_chat(world, "<span class='round_body'>[diff] contestants have died! There are now [C] contestants remaining!</span>")
			spawn(7) world << sound('sound/effects/explosionfar.ogg')

	last_count = C
	if(last_count == 1 || ismob(last_count))
		round_finished = 1
	else if (last_count < 1)
		round_finished = 2
	else
		round_finished = 0

/datum/game_mode/huntergames/proc/count_humans()
	var/human_count = 0

	for(var/mob/living/carbon/human/H in GLOB.alive_human_list)
		if(istype(H) && H.stat == 0 && !istype(get_area(H.loc), /area/centcom) && !istype(get_area(H.loc), /area/tdome) && H.species != "Yautja")
			human_count += 1 //Add them to the amount of people who're alive.

	return human_count

///////////////////////////////
//Checks if the round is over//
///////////////////////////////
/datum/game_mode/huntergames/check_finished()
	if(round_finished)
		return TRUE
	return FALSE


//////////////////////////////////////////////////////////////////////
//Announces the end of the game with all relevant information stated//
//////////////////////////////////////////////////////////////////////
/datum/game_mode/huntergames/declare_completion()
	var/mob/living/carbon/winner = null

	for(var/mob/living/carbon/human/Q in GLOB.alive_human_list)
		if(istype(Q) && Q.stat == 0 && !isyautja(Q) && !istype(get_area(Q.loc), /area/centcom) && !istype(get_area(Q.loc), /area/tdome))
			winner = Q
			break

	if(round_finished == 1 && !isnull(winner) && istype(winner))
		feedback_set_details("round_end_result","single winner")
		to_chat(world, "<span class='round_header'>We have a winner! >> [winner.real_name] << defeated all enemies!</span>")
		to_chat(world, "<FONT size = 3><B>Well done, your tale of survival will live on in legend!</B></FONT>")
		log_game("Humans remaining: [count_humans()]\nRound time: [duration2text()]\nBig Winner: [winner.real_name]")
	else if(round_finished == 2)
		feedback_set_details("round_end_result","no winners")
		to_chat(world, "<span class='round_header'>NOBODY WON!?</span>")
		to_chat(world, "<FONT size = 3><B>'Somehow you stupid humans managed to even fuck up killing yourselves. Well done.'</B></FONT>")
		world << 'sound/misc/sadtrombone.ogg'
		log_game("Humans remaining: [count_humans()]\nRound time: [duration2text()]")
	else
		feedback_set_details("round_end_result","no winners")
		to_chat(world, "<span class='round_header'>NOBODY WON!</span>")
		to_chat(world, "<FONT size = 3><B>There was a winner, but they died before they could receive the prize!! Bummer.</B></FONT>")
		world << 'sound/misc/sadtrombone.ogg'
		log_game("Humans remaining: [count_humans()]\nRound time: [duration2text()]")

	return TRUE

/datum/game_mode/proc/auto_declare_completion_huntergames()
	return FALSE

/datum/game_mode/huntergames/proc/place_lootbox(turf/T)
	if(!istype(T))
		return FALSE

	var/atom/location = new /obj/structure/closet/crate(T)

	var/L[] = HUNTER_LOOTBOX
	for(var/item in L)
		new item(location)

/datum/game_mode/huntergames/proc/place_initial_item(turf/T, item)
	if(!istype(T))
		return FALSE

	new item(T)

/datum/game_mode/huntergames/proc/regenerate_spawns()
	for(var/obj/effect/landmark/L in GLOB.landmarks_list)
		switch(L.name)
			if("hunter_primary")
				primary_spawns += L.loc
			if("hunter_secondary")
				secondary_spawns += L.loc

#undef HUNTER_GOOD_ITEM
#undef HUNTER_OKAY_ITEM
#undef HUNTER_BODY
#undef HUNTER_FEET
