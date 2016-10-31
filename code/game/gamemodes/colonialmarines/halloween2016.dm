//Created in about 8 hours. Kill me.

/datum/game_mode/colonialmarines_halloween_2016
	name = "Nightmare on LV-624"
	config_tag = "Nightmare on LV-624"
	required_players 		= 2 //Need at least one player, but really we need 2.
	forbid_late_joining 	= 1
	var/lobby_time 			= 0
	var/obj/item/device/omega_array/mcguffin
	var/fog_blockers[]
	var/turf/marine_spawns[]
	var/turf/pmc_spawns[]
	var/pmc_starting_num

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/* Pre-pre-startup */
/datum/game_mode/colonialmarines_halloween_2016/can_start()
	initialize_starting_predator_list()
	var/ready_players = num_players() // Get all players that have "Ready" selected
	if(ready_players < required_players)
		world << "<h2 style=\"color:red\">Not enough players to start the game. <b>Aborting</b>.</h2>"
		return
	pmc_starting_num = Clamp((ready_players/3), 1, INFINITY) //(n, minimum, maximum)
	return 1

/datum/game_mode/colonialmarines_halloween_2016/announce()
	world << "<span class='round_header'>The current game mode is - Nightmare on LV-624!</span>"
	world << 'sound/misc/surrounded_by_assholes.ogg'

/datum/game_mode/colonialmarines_halloween_2016/send_intercept()
	return 1

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/* Pre-setup */
//We can ignore this for now, we don't want to do anything before characters are set up.
/datum/game_mode/colonialmarines_halloween_2016/pre_setup()
	fog_blockers = list()
	for(var/obj/effect/blocker/fog/F in world) fog_blockers+=F

	var/blood_attuners[] = list("O-","O+","A-","A+","B-","B+","AB-","AB+")
	var/b_type[] = list()
	var/i = 0
	while(++i < 3)
		var/blood_type = pick(blood_attuners)
		b_type += blood_type
		blood_attuners -= blood_type

	var/obj/effect/step_trigger/attunement/attune
	for(var/obj/effect/landmark/battlefield/spawn_blood_attunement1/A in world)
		attune = new(A.loc)
		attune.b_type = b_type
		cdel(A)

	b_type = list()
	i = 0
	while(++i < 3)
		var/blood_type = pick(blood_attuners)
		b_type += blood_type
		blood_attuners -= blood_type

	for(var/obj/effect/landmark/battlefield/spawn_blood_attunement2/A in world)
		attune = new(A.loc)
		attune.b_type = b_type
		cdel(A)

	b_type = list()
	i = 0
	while(++i < 3)
		var/blood_type = pick(blood_attuners)
		b_type += blood_type
		blood_attuners -= blood_type

	for(var/obj/effect/landmark/battlefield/spawn_blood_attunement3/A in world)
		attune = new(A.loc)
		attune.b_type = b_type
		cdel(A)

	b_type = list()
	i = 0
	while(++i < 3)
		var/blood_type = pick(blood_attuners)
		b_type += blood_type
		blood_attuners -= blood_type

	for(var/obj/effect/landmark/battlefield/spawn_blood_attunement4/A in world)
		attune = new(A.loc)
		attune.b_type = b_type
		cdel(A)

	blood_attuners = list("O-","O+","A-","A+","B-","B+","AB-","AB+")
	b_type = list()
	i = 0
	while(++i < 5)
		var/blood_type = pick(blood_attuners)
		b_type += blood_type
		blood_attuners -= blood_type

	for(var/obj/effect/landmark/battlefield/spawn_blood_attunement5/A in world)
		attune = new(A.loc)
		attune.b_type = b_type
		cdel(A)

	for(var/obj/effect/landmark/battlefield/spawn_mcguffin/A in world)
		var/obj/item/device/omega_array/control/C = new(A.loc)
		mcguffin = C
		cdel(A)

	pmc_spawns = list()
	for(var/obj/effect/landmark/battlefield/spawn_pmc/L in world)
		pmc_spawns += L.loc
		cdel(L)

	marine_spawns = list()
	for(var/obj/effect/landmark/battlefield/spawn_marine/L in world)
		marine_spawns += L.loc
		cdel(L)

	var/turf/pmc_supplies[] = list()
	for(var/obj/effect/landmark/battlefield/spawn_pmc_supplies/L in world)
		pmc_supplies += L.loc
		cdel(L)
	create_pmc_supplies(pmc_supplies)

	var/turf/marine_supplies[] = list()
	for(var/obj/effect/landmark/battlefield/spawn_marine_supplies/L in world)
		marine_supplies += L.loc
		cdel(L)
	create_marine_supplies(marine_supplies)

	return 1

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/* Post-setup */
//This happens after create_character, so our mob SHOULD be valid and built by now, but without job data.
//We move it later with transform_survivor but they might flicker at any start_loc spawn landmark effects then disappear.
//Xenos and survivors should not spawn anywhere until we transform them.
/datum/game_mode/colonialmarines_halloween_2016/post_setup()
	if(config) config.remove_gun_restrictions = 1
	lobby_time = world.time
	initialize_post_predator_list()

	var/mob/M
	var/temp_player_list[] = list()
	for(var/i in player_list) temp_player_list += i
	while(temp_player_list.len)
		M = pick(temp_player_list) //We randomzie it a bit.
		temp_player_list -= M
		spawn_player(M)

	defer_powernet_rebuild = 2 //Build powernets a little bit later, it lags pretty hard.

	spawn (50)
		command_announcement.Announce("An automated distress signal has been received from archaeology site Lazarus Landing, on border world LV-624. Beginning playback.", "USS Sulaco")
		world << 'sound/misc/eventhorizon_shiplog.ogg'

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

//This is processed each tick, but check_win is only checked 5 ticks, so we don't go crazy with scanning for mobs.
/datum/game_mode/colonialmarines_halloween_2016/process()
	if(--round_started > 0) return //Initial countdown, just to be safe, so that everyone has a chance to spawn before we check anything.
	if(!round_finished && ++round_checkwin >= 5)
		if(world.time >= (900 + lobby_time) && fog_blockers.len)
			world << "<span class='boldnotice'>The sickly fog surrounding the area is receding!</span>"
			for(var/obj/F in fog_blockers)
				fog_blockers -= F
				cdel(F)
		check_win()
		round_checkwin = 0

///////////////////////////
//Checks to see who won///
//////////////////////////
/datum/game_mode/colonialmarines_halloween_2016/check_win()
	var/living_player_list[] = count_marines_and_pmcs()
	var/num_marines = living_player_list[1]
	var/num_pmcs = living_player_list[2]

	if(!num_marines && num_pmcs)
		if(mcguffin && mcguffin.loc) round_finished 	= MODE_BATTLEFIELD_W_MAJOR
		else round_finished 							= MODE_BATTLEFIELD_W_MINOR
	else if(num_marines && !num_pmcs)
		if(!mcguffin || !mcguffin.loc) round_finished 	= MODE_BATTLEFIELD_M_MAJOR
		else round_finished 							= MODE_BATTLEFIELD_M_MINOR
	else if(!num_marines && !num_pmcs)	round_finished  = MODE_BATTLEFIELD_DRAW_DEATH
	else if((world.time > 36000 + lobby_time)) //An hour later, we don't have a clear winner.
		if(mcguffin && mcguffin.loc) round_finished		= MODE_BATTLEFIELD_W_MAJOR
		else round_finished 							= MODE_BATTLEFIELD_DRAW_STALEMATE
	else if(station_was_nuked) round_finished 			= MODE_GENERIC_DRAW_NUKE

///////////////////////////////
//Checks if the round is over//
///////////////////////////////
/datum/game_mode/colonialmarines_halloween_2016/check_finished()
	if(round_finished) return 1

//////////////////////////////////////////////////////////////////////
//Announces the end of the game with all relevant information stated//
//////////////////////////////////////////////////////////////////////
/datum/game_mode/colonialmarines_halloween_2016/declare_completion()
	. = declare_completion_infestation()

///////////////////////////////////
//Support items and other doodads//
//////////////////////////////////
/obj/effect/landmark/battlefield
	name = "battlefield"

/obj/effect/landmark/battlefield/spawn_blood_attunement1
	name = "blood attunement 1"
/obj/effect/landmark/battlefield/spawn_blood_attunement2
	name = "blood attunement 2"
/obj/effect/landmark/battlefield/spawn_blood_attunement3
	name = "blood attunement 3"
/obj/effect/landmark/battlefield/spawn_blood_attunement4
	name = "blood attunement 4"
/obj/effect/landmark/battlefield/spawn_blood_attunement5
	name = "blood attunement 5"

/obj/effect/landmark/battlefield/spawn_marine
	name = "marine start"
	icon_state = "x"
/obj/effect/landmark/battlefield/spawn_pmc
	name = "pmc start"
	icon_state = "x"
/obj/effect/landmark/battlefield/spawn_mcguffin
	name = "objective"
	icon_state = "x3"
/obj/effect/landmark/battlefield/spawn_marine_supplies
	name = "marine supplies"
/obj/effect/landmark/battlefield/spawn_pmc_supplies
	name = "pmc supplies"


/obj/item/device/omega_array
	name = "Omega Wave Destablization Array"
	desc = "It's hard to say just what this thing is, but the eggheads at W-Y central must have some reason for creating it."
	icon = 'icons/obj/device.dmi'
	icon_state = "omega_control"
	anchored = 1
	density = 1
	health = 500

	attack_hand(mob/M)
		M << "<span class='warning'>You don't know what this thing could do if you mess with it. Better to leave it alone.</span>"

	bullet_act(obj/item/projectile/P)
		bullet_ping(P)
		if(P.ammo.flags_ammo_behavior & (AMMO_ENERGY|AMMO_ROCKET|AMMO_XENO_ACID)) health -= P.damage
		else health -= round(P.damage/5)
		update_health()
		return 1

	ex_act(force)
		health -= 100*force*2
		update_health()

/obj/item/device/omega_array/proc/update_health()
	if (health <= 0)
		visible_message("<span class='warning'>[src] sparks and begins to violently shake!</span>")
		destroy()

/obj/item/device/omega_array/proc/destroy()
	if(ticker && ticker.mode && ticker.mode.type == /datum/game_mode/colonialmarines_halloween_2016)
		var/datum/game_mode/colonialmarines_halloween_2016/M = ticker.mode
		M.mcguffin = null
	var/detonate_location = get_turf(src)
	cdel(src)
	explosion(detonate_location,2,3,4)

/obj/item/device/omega_array/control
	New()
		..()
		var/obj/item/device/omega_array/array/A = new(locate(x+1,y,z))
		A = new(locate(x-1,y,z))
		A.icon_state = "omega_array_r"

/obj/item/device/omega_array/array
	icon_state = "omega_array_l"

/obj/effect/blocker/fog
	name = "dense fog"
	desc = "It looks way too dangerous to traverse. Best wait until it has cleared up."
	icon = 'icons/effects/effects.dmi'
	icon_state = "smoke"
	anchored = 1
	density = 1
	opacity = 1

	New()
		..()
		dir  = pick(CARDINAL_DIRS)

	attack_hand(mob/M)
		M << "<span class='notice'>You peer through the fog, but it's impossible to tell what's on the other side...</span>"

/turf/unsimulated/floor/gm/river/poison
	New()
		..()
		overlays += image("icon"='icons/effects/effects.dmi',"icon_state"="greenglow","layer"=MOB_LAYER+0.1)

	Entered(mob/living/M)
		..()
		if(istype(M)) M.apply_damage(55,TOX)

/obj/effect/step_trigger/attunement
	var/b_type[] //The blood, it speaks to all.

/obj/effect/step_trigger/attunement/Trigger(mob/living/M)
	if(istype(M) && M.stat != DEAD)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(b_type.len && H.b_type in b_type)
				H << "<span class='notice'>You feel a sudden sense of relief wash over you...</span>"
				return

		switch(rand(1,3))
			if(1)
				visible_message("<span class='danger'>[M] is being torn limb from limb by an unseen force!</span>","<span class='userdanger'>YOU ARE BEING TORN LIMB FROM LIMB!</span>")
				if(!M.stat) M.emote("scream")
				M.gib()
			if(2)
				visible_message("<span class='danger'>[M] is being burned alive by some unseen flame!</span>","<span class='userdanger'>YOU ARE BEING ROASTED ALIVE!</span>")
				M.adjust_fire_stacks(rand(6,11))
				M.IgniteMob()
				if(!M.stat) M.emote("scream")
				var/i = 0
				while(++i < 6)
					M.apply_damage(50,BURN,pick(DEFENSE_ZONES_LIVING))
		playsound(src, 'sound/effects/eventhorizon_scream.ogg', 120, 1)

/obj/effect/rune/attunement/attack_hand(mob/living/user) //Special snowflake rune, do not steal 2016.
	user << "<span class='notice'>You touch the rune, feeling it glow beneath your fingertip. It feels warm, somehow pleasant. The rune soon fades and disappears, as you feel a new sense of understanding about the world.</span>"
	user.mutations |= pick(TK,COLD_RESISTANCE,XRAY,HULK)
	user.mutations |= pick(LASER,HEAL,SHADOW,SCREAM)
	user.mutations |= pick(REPROCESSOR,SHOCKWAVE,REGENERATION)
	cdel(src)

/datum/game_mode/colonialmarines_halloween_2016/proc/spawn_player(mob/M)

	var/mob/living/carbon/human/H
	var/turf/picked


	if(istype(M,/mob/living/carbon/human)) //If We started on Sulaco as squad marine
		if(isYautja(M)) return
		H = M
		if(H.contents.len)
			for(var/I in H.contents)//Delete the cryo uniform
				if(istype(I,/obj/item/clothing/under/marine/underoos)) del(I)

	H.key = M.key
	if(!H.mind) H.mind = new(H.key)
	H.nutrition = rand(325,400)

	//Squad ID and backpack are already spawned in job datum

	//PMC. We want to set up these guys first.
	if(pmc_starting_num-- > 0)
		if(pmc_spawns.len) picked = pick(pmc_spawns)
		if(H.contents.len)
			for(var/I in H.contents)
				if(istype(I,/obj/item)) del(I)

		switch(H.mind.assigned_role)
			if("Squad Leader")
				H.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/PMC(H), slot_l_ear)
				H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/PMC/leader(H), slot_w_uniform)
				H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/veteran/PMC/leader(H), slot_wear_suit)
				H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(H), slot_gloves)
				H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/PMC/leader(H), slot_head)
				H.equip_to_slot_or_del(new /obj/item/clothing/shoes/veteran/PMC(H), slot_shoes)
				H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMC/leader(H), slot_wear_mask)
				H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
				H.equip_to_slot_or_del(new /obj/item/weapon/melee/baton(H.back), slot_in_backpack)

				H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/vp70(H), slot_belt)
				H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp78(H.back), slot_r_store)
				H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp78(H.back), slot_in_backpack)

				H.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/m41a/elite(H), slot_r_hand)
				H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap(H), slot_l_store)
				H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap(H.back), slot_in_backpack)
				H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap(H.back), slot_in_backpack)

				var/obj/item/weapon/card/id/W = new(src)
				W.assignment = "PMC Officer"
				W.registered_name = H.real_name
				W.name = "[H.real_name]'s ID Card ([W.assignment])"
				W.icon_state = "centcom"
				W.access = get_all_accesses()
				W.access += get_all_centcom_access()
				H.equip_to_slot_or_del(W, slot_wear_id)
				H.mind.assigned_role = "PMC Leader"
			if("Squad Engineer")
				H.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/PMC(H), slot_l_ear)
				H.equip_to_slot_or_del(new /obj/item/clothing/glasses/night/m56_goggles(H), slot_glasses)
				H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/PMC(H), slot_w_uniform)
				H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/smartgunner/veteran/PMC(H), slot_wear_suit)
				H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(H), slot_gloves)
				H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/PMC/gunner(H), slot_head)
				H.equip_to_slot_or_del(new /obj/item/clothing/shoes/veteran/PMC(H), slot_shoes)
				H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMC/leader(H), slot_wear_mask)
				H.equip_to_slot_or_del(new /obj/item/smartgun_powerpack/snow(H), slot_back)
				H.equip_to_slot_or_del(new /obj/item/weapon/gun/smartgun/dirty(H), slot_r_hand)

				H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/vp70(H), slot_belt)
				H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70(H), slot_l_store)
				H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70(H), slot_r_store)

				var/obj/item/weapon/card/id/W = new(src)
				W.assignment = "PMC Specialist"
				W.registered_name = H.real_name
				W.name = "[H.real_name]'s ID Card ([W.assignment])"
				W.icon_state = "centcom"
				W.access = get_all_accesses()
				W.access += get_all_centcom_access()
				H.equip_to_slot_or_del(W, slot_wear_id)
				H.mind.assigned_role = "PMC Gunner"
			if("Squad Medic")
				H.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/PMC(H), slot_l_ear)
				H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/PMC(H), slot_w_uniform)
				H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/veteran/PMC/sniper(H), slot_wear_suit)
				H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(H), slot_gloves)
				H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/PMC/sniper(H), slot_head)
				H.equip_to_slot_or_del(new /obj/item/clothing/shoes/veteran/PMC(H), slot_shoes)
				H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/vp70(H), slot_belt)
				H.equip_to_slot_or_del(new /obj/item/clothing/glasses/m42_goggles(H), slot_glasses)

				H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
				H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70(H.back), slot_r_store)
				H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70(H.back), slot_in_backpack)

				H.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/sniper/elite(H), slot_r_hand)
				H.equip_to_slot_or_del(new /obj/item/ammo_magazine/sniper/elite(H), slot_l_store)
				H.equip_to_slot_or_del(new /obj/item/ammo_magazine/sniper/elite(H.back), slot_in_backpack)
				H.equip_to_slot_or_del(new /obj/item/ammo_magazine/sniper/elite(H.back), slot_in_backpack)

				var/obj/item/weapon/card/id/W = new(src)
				W.assignment = "PMC Sniper"
				W.registered_name = H.real_name
				W.name = "[H.real_name]'s ID Card ([W.assignment])"
				W.icon_state = "centcom"
				W.access = get_all_accesses()
				W.access += get_all_centcom_access()
				H.equip_to_slot_or_del(W, slot_wear_id)
				H.mind.assigned_role = "PMC Sniper"
			if("Squad Specialist")
				H.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/commando(H), slot_l_ear)
				H.equip_to_slot_or_del(new /obj/item/clothing/glasses/m42_goggles	(H), slot_glasses)
				H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/PMC/commando(H), slot_w_uniform)
				H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/veteran/PMC/commando(H), slot_wear_suit)
				H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC/commando(H), slot_gloves)
				H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/PMC/commando(H), slot_head)
				H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/commando(H), slot_back)
				H.equip_to_slot_or_del(new /obj/item/clothing/shoes/veteran/PMC/commando(H), slot_shoes)
				H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMC(H), slot_wear_mask)
				H.equip_to_slot_or_del(new /obj/item/weapon/tank/emergency_oxygen/engi(H.back), slot_in_backpack)
				H.equip_to_slot_or_del(new /obj/item/weapon/grenade/incendiary(H), slot_l_store)
				H.equip_to_slot_or_del(new /obj/item/weapon/plastique(H), slot_r_store)
				H.equip_to_slot_or_del(new /obj/item/weapon/gun/revolver/mateba(H), slot_belt)
				H.equip_to_slot_or_del(new /obj/item/ammo_magazine/revolver/mateba(H.back), slot_in_backpack)
				H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap(H.back), slot_in_backpack)
				H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap(H.back), slot_in_backpack)
				H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap(H.back), slot_in_backpack)
				H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap(H.back), slot_in_backpack)
				H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap(H.back), slot_in_backpack)
				H.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/m41a/elite(H), slot_s_store)

				var/obj/item/weapon/card/id/W = new(src)
				W.assignment = "PMC Commando"
				W.registered_name = H.real_name
				W.name = "[H.real_name]'s ID Card ([W.assignment])"
				W.icon_state = "centcom"
				W.access = get_all_accesses()
				W.access += get_all_centcom_access()
				H.equip_to_slot_or_del(W, slot_wear_id)
				H.mind.assigned_role = "PMC Commando"
			else
				H.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/PMC(H), slot_l_ear)
				H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/PMC(H), slot_w_uniform)
				H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/veteran/PMC(H), slot_wear_suit)
				H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(H), slot_gloves)
				H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/PMC(H), slot_head)
				H.equip_to_slot_or_del(new /obj/item/clothing/shoes/veteran/PMC(H), slot_shoes)
				H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMC(H), slot_wear_mask)

				H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
				H.equip_to_slot_or_del(new /obj/item/weapon/grenade/explosive/PMC(H.back), slot_in_backpack)
				H.equip_to_slot_or_del(new /obj/item/device/flashlight(H.back), slot_in_backpack)
				H.equip_to_slot_or_del(new /obj/item/weapon/melee/baton(H.back), slot_in_backpack)
				H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/vp70(H), slot_belt)
				H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70(H), slot_r_store)
				H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70(H.back), slot_in_backpack)

				H.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/m39/elite(H), slot_r_hand)
				H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m39/ap(H), slot_l_store)
				H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m39/ap(H.back), slot_in_backpack)
				H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m39/ap(H.back), slot_in_backpack)
				var/obj/item/weapon/card/id/W = new(src)
				W.assignment = "PMC Standard"
				W.registered_name = H.real_name
				W.name = "[H.real_name]'s ID Card ([W.assignment])"
				W.icon_state = "centcom"
				W.access = get_all_accesses()
				W.access += get_all_centcom_access()
				H.equip_to_slot_or_del(W, slot_wear_id)
				H.mind.assigned_role = "PMC"
		ticker.mode.traitors += H.mind
		H.mind.special_role = "PMC"
		spawn(40)
			if(H)
				H << "________________________"
				H << "\red <b>You are the [H.mind.assigned_role]!<b>"
				H << "We have a new mission for you. The USCM is coming to investigate one of our blacksites, and we require your services."
				H << "Make sure you keep the Colonial Marines from tampering with our equipment. It is very, very expensive, and will be hard to replace."
				H << "As usual, you will be handsomely rewarded upon completion of this mission. Should you fail, we will deny our involvement."
				H << "Hold out for an hour, and your job is finished. It goes without saying, <b>do not let us down.</b>"
				H << "________________________"

	//SQUADS
	else
		if(marine_spawns.len) picked = pick(marine_spawns)
		var/randwep = 1 //Specialists spawn with their own random weapon

		switch(H.mind.assigned_role)
			//SQUAD LEADER
			if("Squad Leader")
				H.equip_to_slot_or_del(new /obj/item/clothing/under/marine(H), slot_w_uniform)
				H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/leader(H), slot_head)
				H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/leader(H), slot_wear_suit)

				//SPESHUL EQUIPMENT
				//Machete
				H.equip_to_slot_or_del(new /obj/item/weapon/claymore/mercsword/machete(H), slot_r_hand)

				//Binos, webbing and bomb beacons in backpack
				H.equip_to_slot_or_del(new /obj/item/device/squad_beacon/bomb(H), slot_in_backpack)
				H.equip_to_slot_or_del(new /obj/item/device/squad_beacon/bomb(H), slot_in_backpack)
				H.equip_to_slot_or_del(new /obj/item/device/binoculars(H), slot_in_backpack)
				H.equip_to_slot_or_del(new /obj/item/clothing/tie/storage/webbing(H), slot_in_backpack)

				//Belt and grenades
				var/obj/item/weapon/storage/belt/marine/B = new/obj/item/weapon/storage/belt/marine(H)
				new /obj/item/weapon/grenade/explosive(B)
				new /obj/item/weapon/grenade/explosive(B)
				new /obj/item/weapon/grenade/explosive(B)
				new /obj/item/weapon/grenade/incendiary(B)
				new /obj/item/weapon/grenade/incendiary(B)
				H.equip_to_slot_or_del(B, slot_belt)


			//SQUAD ENGINEER
			else if("Squad Engineer")
				H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/engineer(H), slot_w_uniform)
				H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/tech(H), slot_head)
				H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine(H), slot_wear_suit)

				//SPESHUL EQUIPMENT
				//Metal, webbing, grenades in backpack
				var/obj/item/stack/sheet/metal/MET = new /obj/item/stack/sheet/metal(H)
				MET.amount = 50
				H.equip_to_slot_or_del(MET, slot_in_backpack)
				H.equip_to_slot_or_del(new /obj/item/weapon/grenade/explosive(H), slot_in_backpack)
				H.equip_to_slot_or_del(new /obj/item/weapon/grenade/incendiary(H), slot_in_backpack)
				H.equip_to_slot_or_del(new /obj/item/clothing/tie/storage/webbing(H), slot_in_backpack)

				//Utility Belt
				H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/utility/full(H), slot_belt)

				//Welding Glasses
				H.equip_to_slot_or_del(new /obj/item/clothing/glasses/welding(H), slot_glasses)

			//SQUAD MEDIC
			else if("Squad Medic")
				H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/medic(H), slot_w_uniform)
				H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/medic(H), slot_head)
				H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine(H), slot_wear_suit)

				//SPESHUL EQUIPMENT
				//Defibs, webbing, first aid, adv aid in backpack
				H.equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid/regular(H), slot_in_backpack)
				H.equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid/adv(H), slot_in_backpack)
				H.equip_to_slot_or_del(new /obj/item/clothing/tie/storage/webbing(H), slot_in_backpack)
				H.equip_to_slot_or_del(new /obj/item/weapon/melee/defibrillator(H), slot_in_backpack)

				//Medical encryption key
				H.equip_to_slot_or_del(new /obj/item/device/encryptionkey/headset_med(H), slot_l_hand)

				//Combat Lifesaver belt
				H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/medical/combatLifesaver(H), slot_belt)

				//Med Hud
				H.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/health(H), slot_glasses)

			//SQUAD SPECIALIST
			else if("Squad Specialist")
				randwep = 0
				var/type = rand(0,14)

				switch(type) //Scaled based on player feedback
					if(0 to 4)//Smartgun
						H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/m56_system(H), slot_r_hand)
						H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine(H), slot_head)

					if(5 to 8)//Sniper
						H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/m42c_system(H), slot_r_hand)

					if(9 to 11)//SADAR
						H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/rocket_system(H), slot_r_hand)

						H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine(H), slot_head)
						H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine(H), slot_wear_suit)

					if(12 to 13)//Flamethrower
						H.equip_to_slot_or_del(new /obj/item/weapon/flamethrower/full(H), slot_s_store)
						H.equip_to_slot_or_del(new /obj/item/weapon/tank/phoron/m240(H), slot_in_backpack)
						H.equip_to_slot_or_del(new /obj/item/weapon/tank/phoron/m240(H), slot_in_backpack)
						H.equip_to_slot_or_del(new /obj/item/weapon/tank/phoron/m240(H), slot_in_backpack)

						H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine(H), slot_head)
						H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine(H), slot_wear_suit)


					if(14)//Grenade Launcher
						H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/grenade_system(H), slot_r_hand)

						H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine(H), slot_head)
						H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine(H), slot_wear_suit)

				H.equip_to_slot_or_del(new /obj/item/clothing/under/marine(H), slot_w_uniform)

				//SPESHUL EQUIPMENT
				//Webbing
				H.equip_to_slot_or_del(new /obj/item/clothing/tie/storage/webbing(H), slot_in_backpack)

				//Backup SMG Weapon
				H.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/m39(H), slot_belt)
				H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m39(H), slot_in_backpack)
				H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m39(H), slot_in_backpack)
				H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m39(H), slot_in_backpack)

			//SQUAD MARINE
			else
				H.equip_to_slot_or_del(new /obj/item/clothing/under/marine(H), slot_w_uniform)
				H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine(H), slot_head)
				H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine(H), slot_wear_suit)
				H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/marine(H), slot_belt)

		//Every Squad Starts with this:
		H.equip_to_slot_or_del(new /obj/item/device/flashlight/flare(H), slot_l_store)
		H.equip_to_slot_or_del(new /obj/item/device/flashlight(H), slot_r_store)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(H), slot_shoes)
		//Knife
		if(prob(25))
			H.equip_to_slot_or_del(new /obj/item/weapon/combat_knife(H), slot_l_hand)




		//Find their squad
		var/squad = get_squad_from_card(H)
		var/leader = is_leader_from_card(H)

		//Squad Gloves and radio headsets
		switch(squad)
			if(1)//Alpha
					//Radio
				if(leader)
					H.equip_to_slot_or_del(new /obj/item/device/radio/headset/malphal(H), slot_l_ear)
				else
					H.equip_to_slot_or_del(new /obj/item/device/radio/headset/malpha(H), slot_l_ear)
					//Gloves
				if(H.mind.assigned_role != "Squad Engineer")
					H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/alpha(H), slot_gloves)
				else
					H.equip_to_slot_or_del(new /obj/item/clothing/gloves/yellow(H), slot_gloves)

			if(2)//Bravo
					//Radio
				if(leader)
					H.equip_to_slot_or_del(new /obj/item/device/radio/headset/mbravol(H), slot_l_ear)
				else
					H.equip_to_slot_or_del(new /obj/item/device/radio/headset/mbravo(H), slot_l_ear)
					//Gloves
				if(H.mind.assigned_role != "Squad Engineer")
					H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/bravo(H), slot_gloves)
				else
					H.equip_to_slot_or_del(new /obj/item/clothing/gloves/yellow(H), slot_gloves)

			if(3)//Charlie
					//Radio
				if(leader)
					H.equip_to_slot_or_del(new /obj/item/device/radio/headset/mcharliel(H), slot_l_ear)
				else
					H.equip_to_slot_or_del(new /obj/item/device/radio/headset/mcharlie(H), slot_l_ear)
					//Gloves
				if(H.mind.assigned_role != "Squad Engineer")
					H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/charlie(H), slot_gloves)
				else
					H.equip_to_slot_or_del(new /obj/item/clothing/gloves/yellow(H), slot_gloves)

			if(4)//Delta
					//Radio
				if(leader)
					H.equip_to_slot_or_del(new /obj/item/device/radio/headset/mdeltal(H), slot_l_ear)
				else
					H.equip_to_slot_or_del(new /obj/item/device/radio/headset/mdelta(H), slot_l_ear)
					//Gloves
				if(H.mind.assigned_role != "Squad Engineer")
					H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/delta(H), slot_gloves)
				else
					H.equip_to_slot_or_del(new /obj/item/clothing/gloves/yellow(H), slot_gloves)

		//Set Random Weapon and Ammo
		if(randwep)
			var/rand_wep = rand(0,2)
			switch(rand_wep)
				if(0)//M41a
					H.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/m41a(H), slot_s_store)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle(H), slot_in_backpack)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle(H), slot_in_backpack)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle(H), slot_in_backpack)
				if(1)//Combat Shotgun
					H.equip_to_slot_or_del(new /obj/item/weapon/gun/shotgun/combat(H), slot_s_store)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/shotgun(H), slot_in_backpack)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/shotgun(H), slot_in_backpack)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/shotgun(H), slot_in_backpack)
				if(2)//SMG
					H.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/m39(H), slot_s_store)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m39(H), slot_in_backpack)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m39(H), slot_in_backpack)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m39(H), slot_in_backpack)
		//Give them some information
		spawn(40)
			if(H)
				H << "________________________"
				H << "\red <b>You are the [H.mind.assigned_role]!<b>"
				H << "Gear up, maggot! You have been dropped off in this God-forsaken place to complete some wetworks for Uncle Sam! Not even your mother knows that you're here!"
				H << "Some W-Y mercs are camping out north of the colony, and they got some doo-hickie doomsday device they are planning to use. Make sure they don't!"
				H << "Wipe them out and destroy their tech! The Sulaco will maintain radio silence for the duration of the mission!"
				H << "You've got an hour. And watch out... That colony ain't right, it ain't right at all. <b>DISMISSED!</b>"
				H << "________________________"
	//Finally, update all icons
	H.update_icons()
	H.loc = picked

	return 1


/datum/game_mode/colonialmarines_halloween_2016/proc/create_pmc_supplies(supplies)
	var/obj/structure/closet/crate/C = new(pick(supplies))
	var/supply_manifest[]
	var/item_path

	supply_manifest=list(
		/obj/item/attachable/suppressor,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/reddot,
		/obj/item/attachable/reddot,
		/obj/item/attachable/reddot,
		/obj/item/attachable/reddot,
		/obj/item/attachable/reddot,
		/obj/item/weapon/grenade/smokebomb,
		/obj/item/weapon/grenade/smokebomb,
		/obj/item/weapon/grenade/smokebomb,
		/obj/item/weapon/grenade/smokebomb,
		/obj/item/weapon/grenade/smokebomb,
		/obj/item/weapon/grenade/smokebomb,
		/obj/item/weapon/grenade/smokebomb,
		/obj/item/weapon/grenade/smokebomb
		)
	for(item_path in supply_manifest)
		new item_path(C)
	C.name = "special ops crate"

	C = new(pick(supplies))
	supply_manifest=list(
		/obj/item/clothing/tie/holster,
		/obj/item/clothing/tie/holster,
		/obj/item/clothing/tie/holster,
		/obj/item/clothing/tie/holster,
		/obj/item/clothing/tie/storage/brown_vest,
		/obj/item/clothing/tie/storage/brown_vest,
		/obj/item/clothing/tie/storage/brown_vest,
		/obj/item/clothing/tie/storage/brown_vest,
		/obj/item/clothing/tie/storage/brown_vest,
		/obj/item/clothing/tie/storage/brown_vest,
		/obj/item/clothing/tie/storage/brown_vest,
		/obj/item/clothing/tie/storage/webbing,
		/obj/item/clothing/tie/storage/webbing,
		/obj/item/clothing/tie/storage/webbing,
		/obj/item/clothing/tie/storage/webbing,
		/obj/item/weapon/storage/belt/gun/m39,
		/obj/item/weapon/storage/belt/gun/m39,
		/obj/item/weapon/storage/belt/gun/m39,
		/obj/item/weapon/storage/belt/gun/m39,
		/obj/item/weapon/storage/belt/gun/m39,
		/obj/item/weapon/storage/belt/gun/m39
		)
	for(item_path in supply_manifest)
		new item_path(C)
	C.name = "extra storage crate"

	C = new(pick(supplies))
	supply_manifest=list(
		/obj/item/weapon/storage/box/explosive_mines,
		/obj/item/weapon/storage/box/explosive_mines,
		/obj/item/weapon/storage/box/explosive_mines,
		/obj/item/weapon/grenade/explosive/PMC,
		/obj/item/weapon/grenade/explosive/PMC,
		/obj/item/weapon/grenade/explosive/PMC,
		/obj/item/weapon/grenade/explosive/PMC,
		/obj/item/weapon/grenade/explosive/PMC,
		/obj/item/weapon/grenade/explosive/PMC,
		/obj/item/weapon/grenade/explosive/PMC,
		/obj/item/weapon/grenade/explosive/PMC,
		/obj/item/weapon/grenade/explosive/PMC,
		/obj/item/weapon/grenade/incendiary,
		/obj/item/weapon/grenade/incendiary,
		/obj/item/weapon/grenade/explosive/m40,
		/obj/item/weapon/grenade/explosive/m40
		)
	for(item_path in supply_manifest)
		new item_path(C)
	C.name = "\improper explosives crate (WARNING)"

	C = new(pick(supplies))
	supply_manifest=list(
		/obj/item/weapon/flamethrower/full,
		/obj/item/weapon/flamethrower/full,
		/obj/item/weapon/flamethrower/full,
		/obj/item/weapon/tank/phoron/m240,
		/obj/item/weapon/tank/phoron/m240,
		/obj/item/weapon/tank/phoron/m240
		)
	for(item_path in supply_manifest)
		new item_path(C)
	C.name = "\improper M240 Incinerator crate"

	C = new(pick(supplies))
	supply_manifest=list(
		/obj/item/ammo_magazine/rifle/extended,
		/obj/item/ammo_magazine/rifle/extended,
		/obj/item/ammo_magazine/rifle/extended,
		/obj/item/ammo_magazine/rifle/extended,
		/obj/item/ammo_magazine/rifle/extended,
		/obj/item/ammo_magazine/rifle/extended,
		/obj/item/ammo_magazine/rifle/extended,
		/obj/item/ammo_magazine/rifle/extended,
		/obj/item/ammo_magazine/smg/m39/extended,
		/obj/item/ammo_magazine/smg/m39/extended,
		/obj/item/ammo_magazine/smg/m39/extended,
		/obj/item/ammo_magazine/smg/m39/extended,
		/obj/item/ammo_magazine/smg/m39/extended,
		/obj/item/ammo_magazine/smg/m39/extended,
		/obj/item/ammo_magazine/smg/m39/extended,
		/obj/item/ammo_magazine/smg/m39/extended,
		/obj/item/ammo_magazine/smg/m39/extended,
		/obj/item/ammo_magazine/smg/m39/extended,
		/obj/item/ammo_magazine/smg/m39/extended,
		/obj/item/ammo_magazine/smg/m39/extended,
		/obj/item/ammo_magazine/smg/m39/extended,
		/obj/item/ammo_magazine/smg/m39/extended,
		/obj/item/ammo_magazine/pistol/vp70,
		/obj/item/ammo_magazine/pistol/vp70,
		/obj/item/ammo_magazine/pistol/vp70,
		/obj/item/ammo_magazine/pistol/vp70,
		/obj/item/ammo_magazine/pistol/vp70,
		/obj/item/ammo_magazine/revolver/mateba,
		/obj/item/ammo_magazine/revolver/mateba,
		/obj/item/ammo_magazine/revolver/mateba,
		/obj/item/ammo_magazine/revolver/mateba,
		/obj/item/ammo_magazine/revolver/mateba
		)
	for(item_path in supply_manifest)
		new item_path(C)
	C.name = "ammo crate"

	C = new(pick(supplies))
	supply_manifest=list(
		/obj/item/ammo_magazine/rifle/ap,
		/obj/item/ammo_magazine/rifle/ap,
		/obj/item/ammo_magazine/rifle/ap,
		/obj/item/ammo_magazine/rifle/ap,
		/obj/item/ammo_magazine/rifle/ap,
		/obj/item/ammo_magazine/rifle/ap,
		/obj/item/ammo_magazine/rifle/ap,
		/obj/item/ammo_magazine/rifle/ap,
		/obj/item/ammo_magazine/smg/m39/ap,
		/obj/item/ammo_magazine/smg/m39/ap,
		/obj/item/ammo_magazine/smg/m39/ap,
		/obj/item/ammo_magazine/smg/m39/ap,
		/obj/item/ammo_magazine/smg/m39/ap,
		/obj/item/ammo_magazine/smg/m39/ap,
		/obj/item/ammo_magazine/smg/m39/ap,
		/obj/item/ammo_magazine/smg/m39/ap,
		/obj/item/ammo_magazine/smg/m39/ap,
		/obj/item/ammo_magazine/smg/m39/ap,
		/obj/item/ammo_magazine/smg/m39/ap,
		/obj/item/ammo_magazine/smg/m39/ap,
		/obj/item/ammo_magazine/smg/m39/ap,
		/obj/item/ammo_magazine/smg/m39/ap,
		/obj/item/ammo_magazine/smg/m39/ap,
		/obj/item/ammo_magazine/smg/m39/ap,
		/obj/item/ammo_magazine/smg/m39/ap,
		/obj/item/ammo_magazine/smg/m39/ap,
		/obj/item/ammo_magazine/smg/m39/ap,
		/obj/item/ammo_magazine/smg/m39/ap,
		/obj/item/ammo_magazine/smg/m39/ap,
		/obj/item/ammo_magazine/smg/m39/ap,
		/obj/item/ammo_magazine/smg/m39/ap,
		/obj/item/ammo_magazine/smg/m39/ap
		)
	for(item_path in supply_manifest)
		new item_path(C)
	C.name = "armor piercing ammo crate"

	C = new(pick(supplies))
	supply_manifest=list(
		/obj/item/weapon/storage/box/explosive_mines,
		/obj/item/weapon/storage/box/explosive_mines,
		/obj/item/weapon/grenade/explosive,
		/obj/item/weapon/grenade/explosive,
		/obj/item/weapon/grenade/explosive,
		/obj/item/weapon/grenade/explosive,
		/obj/item/weapon/grenade/explosive,
		/obj/item/weapon/grenade/explosive,
		/obj/item/weapon/grenade/explosive,
		/obj/item/weapon/grenade/incendiary,
		/obj/item/weapon/grenade/incendiary,
		/obj/item/weapon/grenade/incendiary,
		/obj/item/weapon/grenade/incendiary,
		/obj/item/weapon/grenade/explosive/m40,
		/obj/item/weapon/grenade/explosive/m40,
		/obj/item/weapon/grenade/explosive/m40,
		/obj/item/weapon/grenade/explosive/m40
		)
	for(item_path in supply_manifest)
		new item_path(C)
	C.name = "\improper explosives crate (WARNING)"

	C = new(pick(supplies))
	supply_manifest=list(
		/obj/item/weapon/storage/box/wy_mre,
		/obj/item/weapon/storage/box/wy_mre,
		/obj/item/weapon/storage/box/wy_mre,
		/obj/item/weapon/storage/box/wy_mre,
		/obj/item/weapon/storage/box/wy_mre,
		/obj/item/weapon/storage/box/wy_mre,
		/obj/item/weapon/storage/box/wy_mre,
		/obj/item/weapon/storage/box/wy_mre,
		/obj/item/weapon/storage/box/wy_mre,
		/obj/item/weapon/storage/box/wy_mre,
		/obj/item/weapon/storage/box/wy_mre,
		/obj/item/weapon/storage/box/wy_mre,
		/obj/item/weapon/storage/box/wy_mre
		)
	for(item_path in supply_manifest)
		new item_path(C)
	C.name = "\improper W-Y MRE crate"

	C = new(pick(supplies))
	supply_manifest=list(
		/obj/item/weapon/storage/firstaid/regular,
		/obj/item/weapon/storage/firstaid/fire,
		/obj/item/weapon/storage/firstaid/toxin,
		/obj/item/weapon/storage/firstaid/o2,
		/obj/item/weapon/storage/firstaid/adv,
		/obj/item/weapon/storage/firstaid/adv,
		/obj/item/weapon/storage/firstaid/adv,
		/obj/item/weapon/reagent_containers/glass/bottle/antitoxin,
		/obj/item/weapon/reagent_containers/glass/bottle/inaprovaline,
		/obj/item/weapon/reagent_containers/glass/bottle/stoxin,
		/obj/item/weapon/storage/box/syringes,
		/obj/item/weapon/storage/box/autoinjectors)
	for(item_path in supply_manifest)
		new item_path(C)
	C.name = "medical crate"


/datum/game_mode/colonialmarines_halloween_2016/proc/create_marine_supplies(supplies)
	var/obj/structure/closet/crate/C = new(pick(supplies))
	var/supply_manifest[]
	var/item_path

	supply_manifest=list(
		/obj/item/attachable/scope,
		/obj/item/attachable/scope,
		/obj/item/attachable/scope,
		/obj/item/attachable/reddot,
		/obj/item/attachable/reddot,
		/obj/item/attachable/reddot,
		/obj/item/attachable/reddot,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/quickfire,
		/obj/item/attachable/quickfire,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/compensator,
		/obj/item/attachable/compensator,
		/obj/item/attachable/compensator,
		/obj/item/attachable/foregrip,
		/obj/item/attachable/gyro,
		/obj/item/attachable/bipod,
		/obj/item/attachable/shotgun,
		/obj/item/attachable/flamer,
		/obj/item/attachable/burstfire_assembly,
		/obj/item/attachable/stock/revolver,
		/obj/item/attachable/stock/revolver,
		/obj/item/attachable/stock/rifle,
		/obj/item/attachable/stock/rifle,
		/obj/item/attachable/stock/shotgun,
		/obj/item/attachable/stock/shotgun
		)
	for(item_path in supply_manifest)
		new item_path(C)
	C.name = "attachables crate"


	C = new(pick(supplies))
	supply_manifest=list(
		/obj/item/ammo_magazine/rifle,
		/obj/item/ammo_magazine/rifle,
		/obj/item/ammo_magazine/rifle,
		/obj/item/ammo_magazine/rifle,
		/obj/item/ammo_magazine/rifle,
		/obj/item/ammo_magazine/rifle,
		/obj/item/ammo_magazine/rifle,
		/obj/item/ammo_magazine/rifle,
		/obj/item/ammo_magazine/rifle,
		/obj/item/ammo_magazine/rifle,
		/obj/item/ammo_magazine/rifle,
		/obj/item/ammo_magazine/rifle,
		/obj/item/ammo_magazine/rifle,
		/obj/item/ammo_magazine/rifle,
		/obj/item/ammo_magazine/rifle,
		/obj/item/ammo_magazine/rifle,
		/obj/item/ammo_magazine/rifle,
		/obj/item/ammo_magazine/rifle,
		/obj/item/ammo_magazine/rifle,
		/obj/item/ammo_magazine/rifle,
		/obj/item/ammo_magazine/pistol,
		/obj/item/ammo_magazine/pistol,
		/obj/item/ammo_magazine/smg/m39,
		/obj/item/ammo_magazine/smg/m39,
		/obj/item/ammo_magazine/smg/m39,
		/obj/item/ammo_magazine/smg/m39,
		/obj/item/ammo_magazine/smg/m39,
		/obj/item/ammo_magazine/smg/m39,
		/obj/item/ammo_magazine/smg/m39,
		/obj/item/ammo_magazine/smg/m39,
		/obj/item/ammo_magazine/revolver,
		/obj/item/ammo_magazine/revolver,
		/obj/item/ammo_magazine/revolver,
		/obj/item/ammo_magazine/revolver,
		/obj/item/ammo_magazine/revolver,
		/obj/item/ammo_magazine/revolver,
		/obj/item/ammo_magazine/revolver,
		/obj/item/ammo_magazine/revolver,
		/obj/item/ammo_magazine/shotgun,
		/obj/item/ammo_magazine/shotgun/buckshot,
		/obj/item/ammo_magazine/shotgun,
		/obj/item/ammo_magazine/shotgun/buckshot,
		/obj/item/ammo_magazine/shotgun,
		/obj/item/ammo_magazine/shotgun/buckshot,
		/obj/item/ammo_magazine/shotgun,
		/obj/item/ammo_magazine/shotgun/buckshot
		)
	for(item_path in supply_manifest)
		new item_path(C)
	C.name = "ammo crate"

	C = new(pick(supplies))
	supply_manifest=list(
		/obj/item/smartgun_powerpack,
		/obj/item/smartgun_powerpack,
		/obj/item/ammo_magazine/sniper,
		/obj/item/ammo_magazine/sniper,
		/obj/item/ammo_magazine/sniper/flak,
		/obj/item/ammo_magazine/sniper/flak,
		/obj/item/ammo_magazine/sniper/incendiary
		)
	for(item_path in supply_manifest)
		new item_path(C)
	C.name = "specialist ammo crate"

	C = new(pick(supplies))
	supply_manifest=list(
		/obj/item/ammo_magazine/rocket,
		/obj/item/ammo_magazine/rocket,
		/obj/item/ammo_magazine/rocket/ap,
		/obj/item/ammo_magazine/rocket/wp,
		)
	for(item_path in supply_manifest)
		new item_path(C)
	C.name = "explosive ammo crate"


	C = new(pick(supplies))
	supply_manifest=list(
		/obj/item/weapon/storage/box/uscm_mre,
		/obj/item/weapon/storage/box/uscm_mre,
		/obj/item/weapon/storage/box/uscm_mre,
		/obj/item/weapon/storage/box/uscm_mre,
		/obj/item/weapon/storage/box/uscm_mre,
		/obj/item/weapon/storage/box/uscm_mre,
		/obj/item/weapon/storage/box/uscm_mre,
		/obj/item/weapon/storage/box/uscm_mre,
		/obj/item/weapon/storage/box/uscm_mre,
		/obj/item/weapon/storage/box/uscm_mre,
		/obj/item/weapon/storage/box/uscm_mre,
		/obj/item/weapon/storage/box/uscm_mre,
		/obj/item/weapon/storage/box/uscm_mre,
		/obj/item/weapon/storage/box/uscm_mre,
		/obj/item/weapon/storage/box/uscm_mre,
		/obj/item/weapon/storage/box/uscm_mre,
		/obj/item/weapon/storage/box/uscm_mre
		)
	for(item_path in supply_manifest)
		new item_path(C)
	C.name = "\improper MRE crate"

	C = new(pick(supplies))
	supply_manifest=list(
		/obj/item/weapon/storage/firstaid/regular,
		/obj/item/weapon/storage/firstaid/regular,
		/obj/item/weapon/storage/firstaid/regular,
		/obj/item/weapon/storage/firstaid/regular,
		/obj/item/weapon/storage/firstaid/fire,
		/obj/item/weapon/storage/firstaid/fire,
		/obj/item/weapon/storage/firstaid/toxin,
		/obj/item/weapon/storage/firstaid/toxin,
		/obj/item/weapon/storage/firstaid/o2,
		/obj/item/weapon/storage/firstaid/adv,
		/obj/item/weapon/storage/firstaid/adv,
		/obj/item/weapon/reagent_containers/glass/bottle/antitoxin,
		/obj/item/weapon/reagent_containers/glass/bottle/inaprovaline,
		/obj/item/weapon/reagent_containers/glass/bottle/stoxin,
		/obj/item/weapon/storage/box/syringes,
		/obj/item/weapon/storage/box/autoinjectors)
	for(item_path in supply_manifest)
		new item_path(C)
	C.name = "medical crate"