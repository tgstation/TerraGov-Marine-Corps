#define HUNTER_BEST_ITEM  pick(\
								75; list(/obj/item/clothing/glasses/night, /obj/item/storage/backpack/holding, /obj/item/storage/belt/grenade, /obj/item/weapon/gun/flamer), \
								100; list(/obj/item/weapon/twohanded/glaive, /obj/item/clothing/mask/gas/yautja, /obj/item/clothing/suit/armor/yautja,/obj/item/clothing/shoes/yautja), \
								50; list(/obj/item/weapon/combistick, /obj/item/clothing/mask/gas/yautja, /obj/item/clothing/suit/armor/yautja/full,/obj/item/clothing/shoes/yautja), \
								150; list(/obj/item/stack/medical/advanced/ointment, /obj/item/stack/medical/advanced/bruise_pack, /obj/item/storage/belt/combatLifesaver), \
								50; list(/obj/item/clothing/under/marine/veteran/PMC/commando, /obj/item/clothing/suit/storage/marine/veteran/PMC/commando, /obj/item/clothing/gloves/marine/veteran/PMC/commando, /obj/item/clothing/shoes/veteran/PMC/commando, /obj/item/clothing/head/helmet/marine/veteran/PMC/commando), \
								125; list(/obj/item/weapon/yautja_chain, /obj/item/weapon/yautja_knife, /obj/item/weapon/yautja_scythe, /obj/item/legcuffs/yautja, /obj/item/legcuffs/yautja), \
								75; list(/obj/item/weapon/gun/revolver/mateba/admiral, /obj/item/ammo_magazine/revolver/mateba, /obj/item/ammo_magazine/revolver/mateba, /obj/item/clothing/mask/balaclava/tactical), \
								50; list(/obj/item/weapon/shield/energy, /obj/item/weapon/energy/axe, /obj/item/clothing/under/gladiator, /obj/item/clothing/head/helmet/gladiator) \
								)

#define HUNTER_GOOD_ITEM  pick(\
								50; /obj/item/weapon/shield/riot, \
								100; /obj/item/weapon/claymore, \
								100; /obj/item/weapon/katana, \
								100; /obj/item/weapon/harpoon/yautja, \
								150; /obj/item/weapon/claymore/mercsword, \
								200; /obj/item/weapon/claymore/mercsword/machete, \
								125; /obj/item/weapon/twohanded/fireaxe, \
\
								100; /obj/item/device/binoculars, \
\
								50; /obj/item/device/flash, \
								25; /obj/item/explosive/grenade/flashbang, \
								25; /obj/item/legcuffs/yautja, \
								50; /obj/item/explosive/plastique, \
								100; /obj/item/explosive/grenade/frag, \
								100; /obj/item/explosive/grenade/incendiary, \
\
								170; /obj/item/clothing/suit/armor/vest/security, \
								165; /obj/item/clothing/head/helmet/riot, \
								160; /obj/item/clothing/gloves/marine/veteran/PMC, \
\
								50; /obj/item/storage/firstaid/regular, \
								50; /obj/item/storage/firstaid/fire, \
								75; /obj/item/storage/box/wy_mre, \
\
								100; /obj/item/storage/backpack/commando, \
								100; /obj/item/storage/backpack/yautja, \
								100; /obj/item/storage/belt/knifepouch, \
								100; /obj/item/storage/belt/utility/full, \
								100; /obj/item/clothing/tie/storage/webbing, \
								)

#define HUNTER_OKAY_ITEM  pick(\
								300; /obj/item/tool/crowbar, \
								200; /obj/item/weapon/baseballbat, \
								100; /obj/item/weapon/baseballbat/metal, \
								100; /obj/item/weapon/butterfly, \
								300; /obj/item/tool/hatchet, \
								100; /obj/item/tool/scythe, \
								100; /obj/item/tool/kitchen/knife/butcher, \
								50; /obj/item/weapon/katana/replica, \
								100; /obj/item/weapon/harpoon, \
								75; /obj/item/weapon/combat_knife, \
								200; /obj/item/weapon/throwing_knife, \
								400; /obj/item/weapon/twohanded/spear, \
\
								250; /obj/item/device/flashlight/flare, \
								75; /obj/item/device/flashlight, \
								75; /obj/item/device/flashlight/combat, \
\
								25; /obj/item/bananapeel, \
								25; /obj/item/tool/soap, \
\
								75; /obj/item/stack/medical/bruise_pack, \
								75; /obj/item/stack/medical/ointment, \
								75; /obj/item/reagent_container/food/snacks/donkpocket, \
\
								100; /obj/item/cell/high, \
								100; /obj/item/tool/wirecutters, \
								100; /obj/item/tool/weldingtool, \
								100; /obj/item/tool/wrench, \
								100; /obj/item/device/multitool, \
								75; /obj/item/storage/pill_bottle/tramadol, \
								50; /obj/item/explosive/grenade/smokebomb, \
								50; /obj/item/explosive/grenade/empgrenade, \
								100; /obj/item/storage/backpack, \
								100; /obj/item/storage/backpack/cultpack, \
								100; /obj/item/storage/backpack/satchel, \
								75; /obj/item/clothing/gloves/brown, \
								100; /obj/item/clothing/suit/storage/CMB \
								)

var/waiting_for_drop_votes = 0

//Digging through this is a pain. I'm leaving it mostly alone until a full rework takes place.

/datum/game_mode/huntergames
	name = "Hunter Games"
	config_tag = "Hunter Games"
	required_players = 1
	flags_round_type	= MODE_NO_LATEJOIN
	latejoin_larva_drop = 0 //You never know

	var/checkwin_counter = 0
	var/finished = 0
	var/dropoff_timer = 800 //10 minutes.
	var/last_drop = 0
	var/last_tally
	var/contestants[]
	var/primary_spawns[]
	var/secondary_spawns[]
	var/supply_votes[]
	var/crap_spawns[]
	var/good_spawns[]

	var/ticks_passed = 0
	var/drops_disabled = 0

/obj/effect/step_trigger/hell_hound_blocker/Trigger(mob/living/carbon/hellhound/H)
	if(istype(H)) H.gib() //No mercy.

/datum/game_mode/huntergames/announce()
	r_TRU

/datum/game_mode/huntergames/send_intercept()
	r_TRU

/datum/game_mode/huntergames/pre_setup()
	primary_spawns = list()
	secondary_spawns = list()
	crap_spawns = list()
	good_spawns = list()
	supply_votes = list()

	for(var/obj/effect/landmark/L in landmarks_list)
		switch(L.name)
			if("hunter_primary")
				primary_spawns += L.loc
				cdel(L)
			if("hunter_secondary")
				secondary_spawns += L.loc
				cdel(L)
			if("crap_item")
				crap_spawns += L.loc
				place_drop(L.loc, "crap")
				cdel(L)
			if("good_item")
				good_spawns += L.loc
				place_drop(L.loc, "good")
				cdel(L)
			if("block_hellhound")
				new /obj/effect/step_trigger/hell_hound_blocker(L.loc)
				cdel(L)
			if("fog blocker")
				cdel(L)
			if("xeno tunnel")
				cdel(L)

	for(var/obj/item/weapon/gun/G in item_list) cdel(G) //No guns or ammo allowed.
	for(var/obj/item/ammo_magazine/M in item_list) cdel(M)

	for(var/mob/new_player/player in player_list)
		if(player && player.ready)
			if(player.mind)
				player.mind.assigned_role = "ROLE"
			else
				if(player.client)
					player.mind = new(player.key)
	r_TRU

/datum/game_mode/huntergames/post_setup()
	contestants = list()
	var/mob/M
	for(M in mob_list)
		if(M.client && istype(M,/mob/living/carbon/human))
			contestants += M
			spawn_contestant(M)

	if(config) config.remove_gun_restrictions = 1 //This will allow anyone to use cool guns.

	spawn(10)
		world << "<B>The current game mode is - HUNTER GAMES!</B>"
		world << "You have been dropped off on a Weyland Yutani colony overrun with alien Predators who have turned it into a game preserve.."
		world << "And you are both the hunter and the hunted!"
		world << "Be the <B>last survivor</b> and <B>win glory</B>! Fight in any way you can! Team up or be a loner, it's up to you."
		world << "Be warned though - if someone hasn't died in 3 minutes, the watching Predators get irritated!"
		world << sound('sound/effects/siren.ogg')

	spawn(1000)
		loop_package()

/datum/game_mode/huntergames/proc/spawn_contestant(var/mob/M)

	var/mob/living/carbon/human/H
	var/turf/picked

	if(primary_spawns.len)
		picked = pick(primary_spawns)
		primary_spawns -= picked
	else
		if(secondary_spawns.len)
			picked = pick(secondary_spawns)
		else
			message_admins("There were no spawn points available for a contestant..")

	if(!picked || isnull(picked)) //???
		message_admins("Warning, null picked spawn in spawn_contestant")
		return 0

	if(istype(M,/mob/living/carbon/human)) //somehow?
		H = M
		if(H.contents.len)
			for(var/I in H.contents)
				cdel(I)
		H.loc = picked
	else
		H = new(picked)

	H.key = M.key
	if(H.client) H.client.change_view(world.view)

	if(!H.mind)
		H.mind = new(H.key)

	H.mind.cm_skills = null //no restriction on what the contestants can do

	H.KnockDown(15)
	H.nutrition = 300

	var/randjob = rand(0,10)
	switch(randjob)
		if(0) //colonial marine
			if(prob(50))
				H.equip_to_slot_or_del(new /obj/item/clothing/under/marine(H), WEAR_BODY)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(H), WEAR_FEET)
		if(1) //MP
			H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/mp(H), WEAR_BODY)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(H), WEAR_FEET)
		if(2) //Commander!
			H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/officer/command(H), WEAR_BODY)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marinechief/commander(H), WEAR_FEET)
		if(3) //CL
			H.equip_to_slot_or_del(new /obj/item/clothing/under/liaison_suit(H), WEAR_BODY)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/laceup(H), WEAR_FEET)
		if(4) //PMC!
			H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/PMC(H), WEAR_BODY)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/laceup(H), WEAR_FEET)
			H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMC(H), WEAR_FACE)
		if(5) //Merc!
			if(prob(80))
				H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/dutch(H), WEAR_BODY)
			else
				H.equip_to_slot_or_del(new /obj/item/clothing/under/syndicate(H), WEAR_BODY)
			if(prob(50))
				H.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(H), WEAR_HANDS)
			else
				M.equip_to_slot_or_del(new /obj/item/clothing/gloves/yellow(H), WEAR_HANDS)
			if(prob(75))
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/leather(M), WEAR_FEET)
			else
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/magboots(M), WEAR_FEET)
		if(6)//BEARS!!
			H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/bear(H), WEAR_BODY)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(H), WEAR_FEET)
			H.remove_language("English")
			H.remove_language("Sol Common")
			H.add_language("Russian")
		if(7) //Highlander!
			H.equip_to_slot_or_del(new /obj/item/clothing/under/kilt(H), WEAR_BODY)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(H), WEAR_FEET)
		if(8) //Assassin!
			H.equip_to_slot_or_del(new /obj/item/clothing/under/syndicate(H), WEAR_BODY)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/laceup(H), WEAR_FEET)
		if(9) //Corporate guy
			H.equip_to_slot_or_del(new /obj/item/clothing/under/liaison_suit(H), WEAR_BODY)
			H.equip_to_slot_or_del(new /obj/item/clothing/suit/wcoat(H), WEAR_JACKET)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/laceup(H), WEAR_FEET)
		if(10) //Colonial Marshal
			H.equip_to_slot_or_del(new /obj/item/clothing/under/CM_uniform(H), WEAR_BODY)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/jackboots(H), WEAR_FEET)

	H.equip_to_slot_or_del(new /obj/item/device/flashlight/flare(H), WEAR_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/general(H), WEAR_R_STORE)

	//Give them some information
	spawn(4)
		H << "<h2>There can be only one!!</h2>"
		H << "Use the flare in your pocket to light the way!"
	return 1

/datum/game_mode/huntergames/proc/loop_package()
	while(finished == 0)
		if(!drops_disabled)
			world << "<span class='round_body'>Your Predator capturers have decided it is time to bestow a gift upon the scurrying humans.</span>"
			world << "<span class='round_body'>One lucky contestant should prepare for a supply drop in 60 seconds.</span>"
			for(var/mob/dead/D in dead_mob_list)
				D << "<span class='round_body'>Now is your chance to vote for a supply drop beneficiary! Go to Ghost tab, Spectator Vote!</span>"
			world << sound('sound/effects/alert.ogg')
			last_drop = world.time
			waiting_for_drop_votes = 1
			sleep(600)
			if(!supply_votes.len)
				world << "<span class='round_body'>Nobody got anything! .. weird.</span>"
				waiting_for_drop_votes = 0
				supply_votes = list()
			else
				var/mob/living/carbon/human/winner = pick(supply_votes) //Way it works is, more votes = more odds of winning. But not guaranteed.
				if(istype(winner) && !winner.stat)
					world << "<span class='round_body'>The spectator and Predator votes have been tallied, and the supply drop recipient is <B>[winner.real_name]</B>! Congrats!</span>"
					world << sound('sound/effects/alert.ogg')
					world << "<span class='round_body'>The package will shortly be dropped off at: [get_area(winner.loc)].</span>"
					var/turf/drop_zone = locate(winner.x + rand(-2,2),winner.y + rand(-2,2),winner.z)
					if(istype(drop_zone))
						playsound(drop_zone,'sound/effects/bamf.ogg', 50, 1)
						place_drop(drop_zone,"god", 1)
				else
					world << "<span class='round_body'>The spectator and Predator votes have been talled, and the supply drop recipient is dead or dying<B>. Bummer.</b></span>"
					world << sound('sound/misc/sadtrombone.ogg')
				supply_votes = list()
				waiting_for_drop_votes = 0
		sleep(5000)

/datum/game_mode/huntergames/process()

	checkwin_counter++
	ticks_passed++
	if(prob(2)) dropoff_timer += ticks_passed //Increase the timer the longer the round goes on.

	if(round_started > 0) //Initial countdown, just to be safe, so that everyone has a chance to spawn before we check anything.
		round_started--

	if(checkwin_counter >= 10) //Only check win conditions every 5 ticks.
		if(!finished)
			check_win()
		checkwin_counter = 0
	return 0

/datum/game_mode/huntergames/check_win()
	var/C = count_humans()
	if(C < last_tally)
		if(last_tally - C == 1)
			world << "<span class='round_body'>A contestant has died! There are now [C] contestants remaining!</span>"
			world << sound('sound/effects/explosionfar.ogg')
		else
			var/diff = last_tally - C
			world << "<span class='round_body'>Multiple contestants have died! [diff] in fact. [C] are left!</span>"
			spawn(7) world << sound('sound/effects/explosionfar.ogg')

	last_tally = C
	if(last_tally == 1 || ismob(last_tally))
		finished = 1
	else if (last_tally < 1)
		finished = 2
	else
		finished = 0

/datum/game_mode/huntergames/proc/count_humans()
	var/human_count = 0

	for(var/mob/living/carbon/human/H in living_mob_list)
		if(istype(H) && H.stat == 0 && !istype(get_area(H.loc),/area/centcom) && !istype(get_area(H.loc),/area/tdome))
			if(H.species != "Yautja") // Preds don't count in round end.
				human_count += 1 //Add them to the amount of people who're alive.

	return human_count

///////////////////////////////
//Checks if the round is over//
///////////////////////////////
/datum/game_mode/huntergames/check_finished()
	if(finished != 0)
		return 1

	return 0


//////////////////////////////////////////////////////////////////////
//Announces the end of the game with all relevant information stated//
//////////////////////////////////////////////////////////////////////
/datum/game_mode/huntergames/declare_completion()
	var/mob/living/carbon/winner = null

	for(var/mob/living/carbon/human/Q in living_mob_list)
		if(istype(Q) && Q.stat == 0 && !isYautja(Q) && !istype(get_area(Q.loc),/area/centcom) && !istype(get_area(Q.loc),/area/tdome))
			winner = Q
			break

	if(finished == 1 && !isnull(winner) && istype(winner))
		feedback_set_details("round_end_result","single winner")
		world << "\red <FONT size = 4><B>We have a winner! >> [winner.real_name] ([winner.key]) << defeated all enemies!</B></FONT>"
		world << "<FONT size = 3><B>Well done, your tale of survival will live on in legend!</B></FONT>"

		if(round_stats) // Logging to data/logs/round_stats.log
			round_stats << "Humans remaining: [count_humans()]\nRound time: [duration2text()][log_end]\nBig Winner: [winner.real_name] ([winner.key])"

	else if(finished == 2)
		feedback_set_details("round_end_result","no winners")
		world << "\red <FONT size = 4><B>NOBODY WON!?</B></FONT>"
		world << "<FONT size = 3><B>'Somehow you stupid humans managed to even fuck up killing yourselves. Well done.'</B></FONT>"
		world << 'sound/misc/sadtrombone.ogg'

		if(round_stats) // Logging to data/logs/round_stats.log
			round_stats << "Humans remaining: [count_humans()]\nRound time: [duration2text()][log_end]"
	else
		feedback_set_details("round_end_result","no winners")
		world << "\red <FONT size = 4><B>NOBODY WON!</B></FONT>"
		world << "<FONT size = 3><B>There was a winner, but they died before they could receive the prize!! Bummer.</B></FONT>"
		world << 'sound/misc/sadtrombone.ogg'

		if(round_stats) // Logging to data/logs/round_stats.log
			round_stats << "Humans remaining: [count_humans()]\nRound time: [duration2text()][log_end]"

	return 1

/datum/game_mode/proc/auto_declare_completion_huntergames()
	return

/datum/game_mode/huntergames/proc/place_drop(turf/T, OT = "crap", in_crate)
	if(!istype(T)) r_FAL

	if(OT == "good" && !in_crate && prob(15)) in_crate = 1 //Place some good drops in crates.

	var/obj_type //Object path.
	var/atom/location = in_crate ? new /obj/structure/closet/crate(T) : T //Where it's going to be placed.

	switch(OT)
		if("god")
			var/L[] = HUNTER_BEST_ITEM
			for(obj_type in L)
				new obj_type(location)
		if("good")
			obj_type = HUNTER_GOOD_ITEM
			new obj_type(location)
		else
			obj_type = HUNTER_OKAY_ITEM
			new obj_type(location)
/*
/mob/verb/debug_item_spawn()
	set name = "Debug Item Drops"
	set category = "DEBUG"

	var/i = input("Pick what to spawn in","Spawning","good") as null|anything in list("god","good","crap")
	if(i)
		switch(i)
			if("god") ticker.mode:place_drop(loc, i, 1)
			else ticker.mode:place_drop(loc, i)

*/
#undef HUNTER_BEST_ITEM
#undef HUNTER_GOOD_ITEM
#undef HUNTER_OKAY_ITEM
