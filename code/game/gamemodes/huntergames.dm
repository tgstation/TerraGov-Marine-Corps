#define HUNTER_LOOTBOX  pick(\
								150; list(/obj/item/stack/medical/advanced/ointment, \
										/obj/item/stack/medical/advanced/bruise_pack, \
										/obj/item/storage/belt/combatLifesaver), \
								75; list(/obj/item/clothing/glasses/night, \
										/obj/item/storage/backpack/holding, \
										/obj/item/storage/belt/grenade, \
										/obj/item/weapon/gun/flamer), \
								75; list(/obj/item/weapon/gun/revolver/mateba/admiral,\
										/obj/item/ammo_magazine/revolver/mateba,\
										/obj/item/ammo_magazine/revolver/mateba,\
										/obj/item/clothing/mask/balaclava/tactical),\
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


/datum/game_mode/huntergames
	name = "Hunter Games"
	config_tag = "Hunter Games"
	required_players = 1
	flags_round_type = MODE_NO_LATEJOIN
	flags_landmarks = MODE_LANDMARK_RANDOM_ITEMS

	var/last_count
	var/list/spawn_points
	var/supply_votes[]


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
	. = ..()
	spawn_points = GLOB.huntergames_primary_spawns.Copy()
	var/mob/M
	for(M in GLOB.mob_list)
		if(M.client && ishuman(M))
			var/mob/living/carbon/human/H = M
			spawn_contestant(H)

	CONFIG_SET(flag/remove_gun_restrictions, TRUE) //This will allow anyone to use cool guns.

	SEND_SOUND(world, 'sound/effects/siren.ogg')


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

	H.nutrition = 300

	var/hunter_body = pick(HUNTER_BODY)
	var/hunter_feet = pick(HUNTER_FEET)

	H.equip_to_slot_or_del(new hunter_body(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new hunter_feet(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/flashlight/flare(H), SLOT_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/general(H), SLOT_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar(H), SLOT_IN_R_POUCH)

	to_chat(H, "<h2>Kill everyone. Become the last man standing.</h2>")
	to_chat(H, "<h4>Use the flare in your pocket to light the way!</h4>")
	to_chat(H, "<h4>Use the crowbar in your pouch to open the way!</h4>")

	return TRUE


/datum/game_mode/huntergames/proc/count_humans()
	var/human_count = 0

	for(var/i in GLOB.alive_human_list)
		var/mob/living/carbon/human/H = i
		if(H.stat != CONSCIOUS)
			continue
		if(istype(get_area(H), /area/centcom) || istype(get_area(H), /area/tdome))
			continue
		human_count++

	return human_count

///////////////////////////////
//Checks if the round is over//
///////////////////////////////
/datum/game_mode/huntergames/check_finished()
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


//////////////////////////////////////////////////////////////////////
//Announces the end of the game with all relevant information stated//
//////////////////////////////////////////////////////////////////////
/datum/game_mode/huntergames/declare_completion()
	var/mob/living/carbon/winner = null

	for(var/mob/living/carbon/human/Q in GLOB.alive_human_list)
		if(istype(Q) && Q.stat == 0 && !istype(get_area(Q.loc), /area/centcom) && !istype(get_area(Q.loc), /area/tdome))
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
