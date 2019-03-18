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
							/obj/item/clothing/shoes/marinechief/captain,\
							/obj/item/clothing/shoes/laceup,\
							/obj/item/clothing/shoes/jackboots)

var/waiting_for_drop_votes = 0

/obj/effect/landmark/huntergames_primary_spawn/Initialize()
	. = ..()
	GLOB.huntergames_primary_spawns += loc
	flags_atom |= INITIALIZED
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/huntergames_secondary_spawn/Initialize()
	. = ..()
	GLOB.huntergames_secondary_spawns += loc
	flags_atom |= INITIALIZED
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/hell_hound_blocker/Initialize()
	. = ..()
	GLOB.landmarks_round_start += src

/obj/effect/landmark/hell_hound_blocker/Destroy()
	GLOB.landmarks_round_start -= src
	return ..()

/obj/effect/landmark/hell_hound_blocker/after_round_start(flags_round_type=NOFLAGS,flags_landmarks=NOFLAGS)
	if(flags_landmarks & MODE_LANDMARK_HELLHOUND_BLOCKER)
		new /obj/effect/step_trigger/hell_hound_blocker(loc)
	qdel(src)

/datum/game_mode/huntergames
	name = "Hunter Games"
	config_tag = "Hunter Games"
	required_players = 1
	flags_round_type = MODE_NO_LATEJOIN
	flags_landmarks = MODE_LANDMARK_RANDOM_ITEMS|MODE_LANDMARK_HELLHOUND_BLOCKER

	var/last_count
	var/list/spawn_points
	var/supply_votes[]

/obj/effect/step_trigger/hell_hound_blocker/Trigger(mob/living/carbon/hellhound/H)
	if(istype(H))
		H.gib() //No mercy.

/datum/game_mode/huntergames/announce()
	return TRUE

/datum/game_mode/huntergames/send_intercept()
	return TRUE

/datum/game_mode/huntergames/pre_setup()
	. = ..()
	supply_votes = list()

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
	spawn_points = GLOB.huntergames_primary_spawns.Copy()
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

	if(spawn_points.len)
		picked = pick(spawn_points)
		spawn_points -= picked
	else
		if(GLOB.huntergames_secondary_spawns.len)
			picked = pick(GLOB.huntergames_secondary_spawns)
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
		to_chat(world, "<span class='round_header'>We have a winner! >> [winner.real_name] << defeated all enemies!</span>")
		to_chat(world, "<FONT size = 3><B>Well done, your tale of survival will live on in legend!</B></FONT>")
		log_game("Humans remaining: [count_humans()]\nRound time: [duration2text()]\nBig Winner: [winner.real_name]")
	else if(round_finished == 2)
		to_chat(world, "<span class='round_header'>NOBODY WON!?</span>")
		to_chat(world, "<FONT size = 3><B>'Somehow you stupid humans managed to even fuck up killing yourselves. Well done.'</B></FONT>")
		world << 'sound/misc/sadtrombone.ogg'
		log_game("Humans remaining: [count_humans()]\nRound time: [duration2text()]")
	else
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

/datum/game_mode/huntergames/proc/regenerate_spawns()
	spawn_points = GLOB.huntergames_primary_spawns.Copy()

#undef HUNTER_BODY
#undef HUNTER_FEET
