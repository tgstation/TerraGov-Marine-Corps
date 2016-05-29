/datum/game_mode/whiskey_outpost
	name = "Whiskey Outpost"
	config_tag = "Whiskey Outpost"
	required_players = 1
	recommended_enemies = 5 //Force doctors and commander if no one wants them

	var/mob/living/carbon/human/Commander //If there is no Commander, marines wont get any supplies

	var/checkwin_counter = 0
	var/finished = 0
	var/has_started_timer = 5 //This is a simple timer so we don't accidently check win conditions right in post-game

	var/spawn_next_wave = 200 //Spawn first batch at ~15 minutes //200
	var/xeno_wave = 0 //Which wave is it
	var/spawn_xeno_num = 25 //How many to spawn per wave //First wave is big, cus runners.

	var/wave_ticks_passed = 0 //Timer for xeno waves

	var/list/players = list()

	var/list/turf/marine_spawns = list()
	var/list/turf/xeno_spawns_1 = list()
	var/list/turf/xeno_spawns_2 = list()
	var/list/turf/xeno_spawns_3 = list()
	var/list/turf/xeno_spawns_4 = list()
	var/list/turf/xeno_spawns_all = list()
	var/list/turf/supply_spawns = list()


	var/next_supply = 0 //At which wave does the next supply drop come?

	var/ticks_passed = 0

	//Who to spawn and how often which caste spawns
		//The more entires with same path, the more chances there are to pick it
			//This will get populated with spawn_xenos() proc
	var/list/spawnxeno = list()

/datum/game_mode/whiskey_outpost/announce()
	return 1

/datum/game_mode/whiskey_outpost/send_intercept()
	return 1

/datum/game_mode/whiskey_outpost/pre_setup()
	slashing_allowed = 1 //Allows harm intent for aliens

	var/obj/effect/landmark/L

	for(L in world)
		if(L.name == "whiskey_outpost_marine")
			marine_spawns += L.loc
		if(L.name == "whiskey_outpost_xeno_1")
			xeno_spawns_1 += L.loc
			xeno_spawns_all += L.loc
		if(L.name == "whiskey_outpost_xeno_2")
			xeno_spawns_2 += L.loc
			xeno_spawns_all += L.loc
		if(L.name == "whiskey_outpost_xeno_3")
			xeno_spawns_3 += L.loc
			xeno_spawns_all += L.loc
		if(L.name == "whiskey_outpost_xeno_4")
			xeno_spawns_4 += L.loc
			xeno_spawns_all += L.loc
		if(L.name == "whiskey_outpost_supply")
			supply_spawns += L.loc

	//Ehh, setting special roles is done in spawn_player()
	var/list/possible_roles = get_players_for_role(BE_WO_ROLE) //Grab people who want to be speshul
	var/docs_max = 4



	//Setup possible roles list
	if(possible_roles.len)
		//DEBUG
		world << "possible_roles:"
		for(var/datum/mind/S in possible_roles)
			world << "[S]"
		world << "________________"
		//Commanders
		for(var/datum/mind/S in possible_roles)
			if(S && S.assigned_role != "ROLE" && !S.special_role) //Make sure it's not already here.
				S.assigned_role = "ROLE"
				S.special_role = "WO_COM"
				world << "[S] as WO_COM"
				break

		//Doctors
		for(var/datum/mind/S in possible_roles)
			if(S && S.assigned_role != "ROLE" && !S.special_role) //Make sure it's not already here.
				S.assigned_role = "ROLE"
				S.special_role = "WO_DOC"
				world << "[S] as WO_DOC"
				docs_max--
				if(!docs_max)
					break

	//Setup Marines
	for(var/mob/new_player/player in player_list)
		if(player && player.ready)
			if(player.mind)
				if(!player.mind.special_role)
					player.mind.assigned_role = "ROLE"
			else
				if(player.client)
					player.mind = new(player.key)
	return 1

/datum/game_mode/whiskey_outpost/post_setup()
	var/mob/M

	for(M in mob_list)
		if(M.client && istype(M,/mob/living/carbon/human))
			players += M
			spawn_player(M)

	spawn(10)
		world << "<B>The current game mode is - WHISKEY OUTPOST!</B>"
		world << "Marines are sent in to defend the outpost on this hostile planet"
		world << "They need to hold it for one hour until main forces arrive"
		world << sound('sound/effects/siren.ogg')

/datum/game_mode/whiskey_outpost/proc/spawn_player(var/mob/M)

	var/mob/living/carbon/human/H
	var/turf/picked

	if(marine_spawns.len)
		picked = pick(marine_spawns)
	else
		message_admins("There were no spawn points available for a player...")

	if(!picked || isnull(picked)) //???
		message_admins("Warning, null picked spawn in spawn_player")
		return 0

	if(istype(M,/mob/living/carbon/human)) //somehow?
		H = M
		if(H.contents.len)
			for(var/I in H.contents)
				del(I)
		H.loc = picked
	else
		H = new(picked)

	H.key = M.key

	if(!H.mind)
		H.mind = new(H.key)

	H.nutrition = rand(325,400)

	if(H.mind.special_role == "WO_COM") //First, the commander
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/mcom(H), slot_l_ear)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/marinesatchel(H), slot_back)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/officer/command(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/MP/RO(H), slot_wear_suit)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marinechief/commander(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/clothing/head/cmberet/tan(H), slot_head)
		H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/techofficer/commander(H), slot_gloves)

		H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/heavy(H), slot_belt)
		H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/heavy(H), slot_in_backpack)
		H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/heavy(H), slot_in_backpack)
		H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/heavy(H), slot_in_backpack)
		Commander = H //Make him the Commander

		var/obj/item/weapon/card/id/gold/W = new(H)
		W.name = "[M.real_name]'s ID Card"
		W.access = list()
		W.assignment = "Commander"
		W.registered_name = M.real_name
		H.equip_to_slot_or_del(W, slot_wear_id)

		spawn(40)
			if(H)
				H << "________________________"
				H << "\red <b>You are the Commander!<b>"
				H << "Coordinate your team and prepare defenses."
				H << "Motion trackers have detected movement from local creatures, and they are heading towards the outpost!"
				H << "Stay alive! If you die, supplies will stop arriving."
				H << "Hold the outpost for one hour until the main force arrives!"
				H << "________________________"
		spawn(240) //So they can see it
			if(H)
				H << "\red <b>THIS IS A CRITICAL ROLE<b>"
				H << "\red If you kill yourself or leave the server without notifying admins, you will be banned."


	else if(H.mind.special_role == "WO_DOC") //Then, the doctors
		switch(H.backbag)
			if(2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/medic(H), slot_back)
			if(3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel_med(H), slot_back)
			if(4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/medical/green(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/head/surgery/green(H), slot_head)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/device/flashlight/pen(H), slot_s_store)
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_med(H), slot_l_ear)

		var/obj/item/weapon/card/id/W = new(H)
		W.name = "[M.real_name]'s ID Card"
		W.access = list()
		W.assignment = "Doctor"
		W.registered_name = M.real_name
		H.equip_to_slot_or_del(W, slot_wear_id)

		//Give them some information
		spawn(40)
			if(H)
				H << "________________________"
				H << "\red <b>You are the WO Doctor!<b>"
				H << "Gear up, prepare the medbay and keep your temmates alive."
				H << "Motion trackers have detected movement from local creatures, and they are heading towards the outpost!"
				H << "Hold the outpost for one hour until the main force arrives!"
				H << "________________________"
		spawn(240) //So they can see it
			if(H)
				H << "\red <b>THIS IS A CRITICAL ROLE<b>"
				H << "\red If you kill yourself or leave the server without notifying admins, you will be banned."

	else
		//Standard Marine
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/marine(H), slot_back)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/marine_jumpsuit(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine(H), slot_head)
		H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine(H), slot_wear_suit)
		H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/alpha(H), slot_gloves)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/device/radio/marine(H), slot_l_ear)

		var/obj/item/weapon/card/id/W = new(H)
		W.name = "[M.real_name]'s ID Card"
		W.access = list()
		W.assignment = "Marine"
		W.registered_name = M.real_name
		H.equip_to_slot_or_del(W, slot_wear_id)

		var/randwep = rand(0,2)
		switch(randwep)
			if(0)
				H.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/m41a(H), slot_s_store)
				H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle(H), slot_in_backpack)
				H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle(H), slot_in_backpack)
				H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle(H), slot_in_backpack)
			if(1)
				H.equip_to_slot_or_del(new /obj/item/weapon/gun/shotgun/pump(H), slot_s_store)
				H.equip_to_slot_or_del(new /obj/item/ammo_magazine/shotgun(H), slot_in_backpack)
				H.equip_to_slot_or_del(new /obj/item/ammo_magazine/shotgun(H), slot_in_backpack)
				H.equip_to_slot_or_del(new /obj/item/ammo_magazine/shotgun(H), slot_in_backpack)
			if(2)
				H.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/m39(H), slot_s_store)
				H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m39(H), slot_in_backpack)
				H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m39(H), slot_in_backpack)
				H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m39(H), slot_in_backpack)

		//Give them some information
		spawn(40)
			if(H)
				H << "________________________"
				H << "\red <b>You are the Marine!<b>"
				H << "Gear up, prepare defenses, work as a team. Protect your doctors and commander!"
				H << "Motion trackers have detected movement from local creatures, and they are heading towards the outpost!"
				H << "Hold the outpost for one hour until the main force arrives!"
				H << "________________________"

	H.equip_to_slot_or_del(new /obj/item/device/flashlight/flare(H), slot_l_store)
	H.equip_to_slot_or_del(new /obj/item/device/flashlight(H), slot_r_store)

	H.update_icons()

	return 1

/datum/game_mode/whiskey_outpost/process()
	checkwin_counter++
	ticks_passed++
	wave_ticks_passed++
//	world << "Time: [world.time] - Tick: [ticks_passed]"

	//XENO AND SUPPLY DROPS SPAWNER
	if(wave_ticks_passed >= spawn_next_wave)
		world << "___________________________"
//		world << "Time: [world.time]"
		world << "wave_ticks_passed: [wave_ticks_passed]"
		world << "count_xenos: [count_xenos()]"
		world << "spawn_xeno_num: [spawn_xeno_num]"
		world << "xeno_wave: [xeno_wave]"

		if(count_xenos() < 50)//Checks braindead too, so we don't overpopulate!
			wave_ticks_passed = 0

			if(spawn_next_wave > 60) //100
				spawn_next_wave -= 20 //50 //Spawns faster and faster
			spawn_xenos(spawn_xeno_num)

			if(spawn_xeno_num < 40)
				spawn_xeno_num ++
			world << "spawn_next_wave: [spawn_next_wave]"

			//SUPPLY SPAWNER
			if(xeno_wave == next_supply)
				if(Commander && Commander.stat != DEAD)
					for(var/turf/S in supply_spawns)
						var/turf/picked_med = pick(supply_spawns)
						place_drop(picked_med,"med")
						supply_spawns -= picked_med

						var/turf/picked_wep = pick(supply_spawns)
						place_drop(picked_wep,"wep")
						supply_spawns -= picked_wep

						var/turf/picked_sup = pick(supply_spawns)
						place_drop(picked_sup,"sup")
						supply_spawns -= picked_sup

						supply_spawns += list(picked_med,picked_wep,picked_sup)

						break //Place only 3

					switch(xeno_wave)
						if(0 to 11)
							next_supply++
						if(12 to 18)
							next_supply += 2
						else
							next_supply += 3
				else if(Commander)
					world << "\red Commander ([Commander]) is dead, so no supplies will arrive!"
				else
					world << "\red Commander could not be found. He probably exploded into bits..."

			xeno_wave++
		else
			wave_ticks_passed -= 15 //Wait 15 ticks and try again



//		world << "spawn_next_wave after: [spawn_next_wave]"
//		world << "spawn_xeno_num after: [spawn_xeno_num]"





	if(has_started_timer > 0) //Initial countdown, just to be safe, so that everyone has a chance to spawn before we check anything.
		has_started_timer--

	if(checkwin_counter >= 10) //Only check win conditions every 10 ticks.
		if(!finished)
			check_win()
		checkwin_counter = 0
	return 0

/datum/game_mode/whiskey_outpost/check_win()//TODO
	var/C = count_humans()

	if(C == 0)
		finished = 1
	else if(world.time > 36000)//one hour or so
		finished = 2

/datum/game_mode/whiskey_outpost/proc/spawn_xenos(var/amt = 1)
	var/spawn_this_many = amt
	var/turf/picked

	var/xenos_spawned = 0 //Debug

	var/list/tempspawnxeno = list() //Temporarly replaces the main list

	var/list/xeno_spawn_loc = list()
	var/side = rand(0,4)
		//0 - All directions
		//1-4 - List number
	switch(side)
		if(0)
			xeno_spawn_loc = xeno_spawns_all
//			world << "Loc: All"
		if(1)
			xeno_spawn_loc = xeno_spawns_1
//			world << "Loc: 1"
		if(2)
			xeno_spawn_loc = xeno_spawns_2
//			world << "Loc: 2"
		if(3)
			xeno_spawn_loc = xeno_spawns_3
//			world << "Loc: 3"
		if(4)
			xeno_spawn_loc = xeno_spawns_4
//			world << "Loc: 4"

	switch(xeno_wave)//Xeno spawn controller
		if(0)//Mostly weak runners
			spawnxeno += list(/mob/living/carbon/Xenomorph/Runner)
			spawn_xeno_num = 10 //Reset

		if(1)//Sentinels and drones are more common
			spawnxeno += list(/mob/living/carbon/Xenomorph/Runner,
						/mob/living/carbon/Xenomorph/Runner,
						/mob/living/carbon/Xenomorph/Runner,
						/mob/living/carbon/Xenomorph/Runner,
						/mob/living/carbon/Xenomorph/Runner,
						/mob/living/carbon/Xenomorph/Sentinel,
						/mob/living/carbon/Xenomorph/Sentinel,
						/mob/living/carbon/Xenomorph/Drone)


		if(3)//Tier II versions added, but rare
			spawnxeno += list(/mob/living/carbon/Xenomorph/Hunter,
						/mob/living/carbon/Xenomorph/Spitter,
						/mob/living/carbon/Xenomorph/Drone)

		if(4)//Tier II more common
			spawnxeno += list(/mob/living/carbon/Xenomorph/Runner,
						/mob/living/carbon/Xenomorph/Hunter,
						/mob/living/carbon/Xenomorph/Spitter)

		if(6)//Hivelord and Carrier added
			spawnxeno += list(/mob/living/carbon/Xenomorph/Carrier,
						/mob/living/carbon/Xenomorph/Hivelord)

		if(8)//Ravager and Praetorian Added, Tier II more common
			spawnxeno += list(/mob/living/carbon/Xenomorph/Ravager,
						/mob/living/carbon/Xenomorph/Praetorian,
						/mob/living/carbon/Xenomorph/Runner,
						/mob/living/carbon/Xenomorph/Hunter,
						/mob/living/carbon/Xenomorph/Spitter,
						/mob/living/carbon/Xenomorph/Carrier)

		if(10)//Boiler and Crusher Added, Ravager and Praetorian more common
			spawnxeno += list(/mob/living/carbon/Xenomorph/Crusher,
						/mob/living/carbon/Xenomorph/Boiler,
						/mob/living/carbon/Xenomorph/Ravager,
						/mob/living/carbon/Xenomorph/Praetorian)

		if(15 to INFINITY)
			var/random_wave = rand(0,8)
			switch(random_wave)
				if(0 to 5)//Normal list, but makes it easier to pick stronger units
					switch(random_wave)
						if(0)//Add another Ravager
							spawnxeno += list(/mob/living/carbon/Xenomorph/Ravager)
						if(1)//Add another Carrier
							spawnxeno += list(/mob/living/carbon/Xenomorph/Carrier)
						if(2)//Add another Praetorian
							spawnxeno += list(/mob/living/carbon/Xenomorph/Praetorian)
						if(3)//Add another Boiler
							spawnxeno += list(/mob/living/carbon/Xenomorph/Boiler)
						if(4)//Add another Crusher
							spawnxeno += list(/mob/living/carbon/Xenomorph/Crusher)
						if(5)//Add another Hunter and Spitter
							spawnxeno += list(/mob/living/carbon/Xenomorph/Hunter,
										/mob/living/carbon/Xenomorph/Spitter)

				if(6)//Runner madness
					spawn_next_wave += 75//Slow down the next wave //200
					spawn_this_many = 35//A lot of them
					tempspawnxeno = list(/mob/living/carbon/Xenomorph/Runner,
									/mob/living/carbon/Xenomorph/Runner,
									/mob/living/carbon/Xenomorph/Runner,
									/mob/living/carbon/Xenomorph/Runner,
									/mob/living/carbon/Xenomorph/Runner,
									/mob/living/carbon/Xenomorph/Runner,
									/mob/living/carbon/Xenomorph/Runner,
									/mob/living/carbon/Xenomorph/Runner,
									/mob/living/carbon/Xenomorph/Runner,
									/mob/living/carbon/Xenomorph/Hunter,
									/mob/living/carbon/Xenomorph/Hunter,
									/mob/living/carbon/Xenomorph/Hunter,
									/mob/living/carbon/Xenomorph/Hunter,
									/mob/living/carbon/Xenomorph/Ravager)

				if(7)//Spitter madness
					spawn_next_wave += 100//Slow down the next wave //200
					spawn_this_many =  25//A lot of them
					tempspawnxeno = list(/mob/living/carbon/Xenomorph/Sentinel,
										/mob/living/carbon/Xenomorph/Sentinel,
										/mob/living/carbon/Xenomorph/Sentinel,
										/mob/living/carbon/Xenomorph/Sentinel,
										/mob/living/carbon/Xenomorph/Sentinel,
										/mob/living/carbon/Xenomorph/Sentinel,
										/mob/living/carbon/Xenomorph/Sentinel,
										/mob/living/carbon/Xenomorph/Sentinel,
										/mob/living/carbon/Xenomorph/Sentinel,
										/mob/living/carbon/Xenomorph/Sentinel,
										/mob/living/carbon/Xenomorph/Spitter,
										/mob/living/carbon/Xenomorph/Spitter,
										/mob/living/carbon/Xenomorph/Spitter,
										/mob/living/carbon/Xenomorph/Spitter,
										/mob/living/carbon/Xenomorph/Praetorian)

				if(8)//Siege madness
					spawn_this_many = 8//A lot of them
					spawn_next_wave += 150//Slow down the next wave //300
					tempspawnxeno = list(/mob/living/carbon/Xenomorph/Boiler,
									/mob/living/carbon/Xenomorph/Boiler,
									/mob/living/carbon/Xenomorph/Crusher)
	var/path
	if(tempspawnxeno.len)//If temp list exists, use it
		for(var/i = 0; i < spawn_this_many; i++)
			if(xeno_spawn_loc.len)
				path = pick(tempspawnxeno)
				xenos_spawned++ //DEBUG
				picked = pick(xeno_spawn_loc)
				var/mob/living/carbon/Xenomorph/X = new path(picked)
				X.away_timer = 300 //So ghosts can join instantly
				X.storedplasma = X.maxplasma
				X.a_intent = "harm"
				if(istype(X,/mob/living/carbon/Xenomorph/Carrier))
					X:huggers_cur = 6 //Max out huggers
				break


	else //Else use the main list
		for(var/i = 0; i < spawn_this_many; i++)
			if(xeno_spawn_loc.len)
				path = pick(spawnxeno)
				xenos_spawned++
				picked = pick(xeno_spawn_loc)
				var/mob/living/carbon/Xenomorph/X = new path(picked)
				X.away_timer = 300 //So ghosts can join instantly
				if(istype(X,/mob/living/carbon/Xenomorph/Carrier))
					X:huggers_cur = 6 //Max out huggers

	if(xenos_spawned)
		world << "Xenos_spawned: [xenos_spawned]"

/datum/game_mode/whiskey_outpost/proc/count_humans()
	var/human_count = 0

	for(var/mob/living/carbon/human/H in living_mob_list)
		if(H.client && istype(H) && H.stat == 0 && !istype(get_area(H.loc),/area/centcom) && !istype(get_area(H.loc),/area/tdome))
			if(H.species != "Yautja") // Preds don't count in round end.
				human_count += 1 //Add them to the amount of people who're alive.

	return human_count

/datum/game_mode/whiskey_outpost/proc/count_xenos()//Counts braindead too
	var/xeno_count = 0
	for(var/mob/living/carbon/Xenomorph/X in living_mob_list)
		if(X) //Prevent any runtime errors
			if(istype(X) && X.stat != DEAD && X.z != 0 && !istype(X.loc,/turf/space)) // If they're connected/unghosted and alive and not debrained
				xeno_count += 1 //Add them to the amount of people who're alive.

	return xeno_count

///////////////////////////////
//Checks if the round is over//
///////////////////////////////
/datum/game_mode/whiskey_outpost/check_finished()
	if(finished != 0)
		return 1

	return 0


//////////////////////////////////////////////////////////////////////
//Announces the end of the game with all relevant information stated//
//////////////////////////////////////////////////////////////////////
/datum/game_mode/whiskey_outpost/declare_completion()
	if(finished == 1)
		feedback_set_details("round_end_result","Xenos won")
		world << "\red <FONT size = 4><B>The Xenos have succesfully defended their home planet from colonization.</B></FONT>"
		world << "<FONT size = 3><B>Well done, you showed those snowflakes what war means!</B></FONT>"

		if(round_stats) // Logging to data/logs/round_stats.log
			round_stats << "Marines remaining: [count_humans()]\nRound time: [worldtime2text()][log_end]\nBig Winner:)"

	else if(finished == 2)
		feedback_set_details("round_end_result","Marines Won")
		world << "\red <FONT size = 4><B>The marines have succesfully defended the outpost. </B></FONT>"
		world << "<FONT size = 3><B>Well done, it is now time for real marines to take over your positions.</B></FONT>"

		if(round_stats) // Logging to data/logs/round_stats.log
			round_stats << "Marines remaining: [count_humans()]\nRound time: [worldtime2text()][log_end]"
	else
		feedback_set_details("round_end_result","no winners")
		world << "\red <FONT size = 4><B>NOBODY WON!</B></FONT>"
		world << "<FONT size = 3><B>How? Don't ask me...</B></FONT>"
		world << 'sound/misc/sadtrombone.ogg'

		if(round_stats) // Logging to data/logs/round_stats.log
			round_stats << "Marines remaining: [count_humans()]\nRound time: [worldtime2text()][log_end]"

	return 1

/datum/game_mode/proc/auto_declare_completion_whiskey_outpost()
	return

/datum/game_mode/whiskey_outpost/proc/place_drop(var/turf/T,var/OT)
	if(!istype(T)) return
	var/randpick
	var/list/randomitems = list()
	var/list/spawnitems = list()
	var/choosemax
	var/crate

	if(isnull(OT) || OT == "")
		OT = "sup"

	//MEDICAL
	if(OT == "med")
		crate = new /obj/structure/closet/crate/medical(T)
		randpick = rand(0,8)
		switch(randpick)
			if(0)//Blood Crate
				spawnitems = list(/obj/item/weapon/reagent_containers/blood/APlus,
								/obj/item/weapon/reagent_containers/blood/APlus,
								/obj/item/weapon/reagent_containers/blood/AMinus,
								/obj/item/weapon/reagent_containers/blood/AMinus,
								/obj/item/weapon/reagent_containers/blood/BPlus,
								/obj/item/weapon/reagent_containers/blood/BPlus,
								/obj/item/weapon/reagent_containers/blood/BMinus,
								/obj/item/weapon/reagent_containers/blood/BMinus,
								/obj/item/weapon/reagent_containers/blood/OPlus,
								/obj/item/weapon/reagent_containers/blood/OMinus,
								/obj/item/weapon/reagent_containers/blood/empty,
								/obj/item/weapon/reagent_containers/blood/empty)

			if(1)//Advanced meds Crate
				spawnitems = list(/obj/item/weapon/storage/firstaid/fire,
								/obj/item/weapon/storage/firstaid/regular,
								/obj/item/weapon/storage/firstaid/toxin,
								/obj/item/weapon/storage/firstaid/o2,
								/obj/item/weapon/storage/firstaid/adv,
								/obj/item/bodybag/cryobag,
								/obj/item/bodybag/cryobag,
								/obj/item/weapon/reagent_containers/hypospray/autoinjector/quickclot,
								/obj/item/weapon/reagent_containers/hypospray/autoinjector/quickclot,
								/obj/item/weapon/reagent_containers/hypospray/autoinjector/quickclot,
								/obj/item/weapon/storage/belt/medical/combatLifesaver,
								/obj/item/clothing/glasses/hud/health,
								/obj/item/clothing/glasses/hud/health,
								/obj/item/weapon/melee/defibrillator)

			if(2 to 8)//Random Medical Items
				choosemax = rand(10,15)
				randomitems = list(/obj/item/weapon/storage/firstaid/fire,
								/obj/item/weapon/storage/firstaid/regular,
								/obj/item/weapon/storage/firstaid/toxin,
								/obj/item/weapon/storage/firstaid/o2,
								/obj/item/weapon/storage/firstaid/adv,
								/obj/item/stack/medical/bruise_pack,
								/obj/item/stack/medical/bruise_pack,
								/obj/item/stack/medical/bruise_pack,
								/obj/item/stack/medical/ointment,
								/obj/item/stack/medical/ointment,
								/obj/item/stack/medical/ointment,
								/obj/item/stack/medical/advanced/bruise_pack,
								/obj/item/stack/medical/advanced/bruise_pack,
								/obj/item/stack/medical/advanced/ointment,
								/obj/item/stack/medical/advanced/ointment,
								/obj/item/weapon/storage/belt/medical/combatLifesaver,
								/obj/item/weapon/storage/pill_bottle/tramadol,
								/obj/item/weapon/storage/pill_bottle/tramadol,
								/obj/item/weapon/storage/pill_bottle/tramadol,
								/obj/item/weapon/storage/pill_bottle/spaceacillin,
								/obj/item/weapon/storage/pill_bottle/spaceacillin,
								/obj/item/weapon/storage/pill_bottle/spaceacillin,
								/obj/item/weapon/storage/pill_bottle/antitox,
								/obj/item/weapon/storage/pill_bottle/antitox,
								/obj/item/weapon/storage/pill_bottle/antitox,
								/obj/item/weapon/storage/pill_bottle/kelotane,
								/obj/item/weapon/storage/pill_bottle/kelotane,
								/obj/item/weapon/storage/pill_bottle/kelotane,
								/obj/item/weapon/storage/syringe_case/oxy,
								/obj/item/weapon/storage/syringe_case/tox,
								/obj/item/weapon/storage/syringe_case/burn,
								/obj/item/weapon/storage/syringe_case/regular,
								/obj/item/device/healthanalyzer,
								/obj/item/device/healthanalyzer,
								/obj/item/device/healthanalyzer,
								/obj/item/stack/medical/splint,
								/obj/item/stack/medical/splint,
								/obj/item/weapon/reagent_containers/hypospray/autoinjector/tricord,
								/obj/item/weapon/reagent_containers/hypospray/autoinjector/tricord,
								/obj/item/weapon/reagent_containers/hypospray/autoinjector/tricord,
								/obj/item/weapon/reagent_containers/hypospray/autoinjector/quickclot,
								/obj/item/weapon/reagent_containers/hypospray/autoinjector/dexP,
								/obj/item/weapon/reagent_containers/hypospray/autoinjector/Bicard,
								/obj/item/weapon/reagent_containers/hypospray/autoinjector/Kelo,
								/obj/item/weapon/reagent_containers/blood/OMinus,
								/obj/item/weapon/reagent_containers/blood/OMinus,
								/obj/item/weapon/reagent_containers/blood/OMinus)


	else if (OT == "wep")
		crate = new /obj/structure/closet/crate/secure/weapon(T)
		randpick = rand(0,16)
		switch(randpick)
			if(0)//Specialist Crate
				spawnitems = list(/obj/item/weapon/flamethrower/full,
								/obj/item/weapon/flamethrower/full,
								/obj/item/weapon/tank/phoron/m240,
								/obj/item/weapon/tank/phoron/m240,
								/obj/item/weapon/tank/phoron/m240,
								/obj/item/ammo_magazine/sniper,
								/obj/item/ammo_magazine/sniper,
								/obj/item/ammo_magazine/sniper/incendiary,
								/obj/item/ammo_magazine/sniper/flak,
								/obj/item/sentry_ammo,
								/obj/item/sentry_ammo,
								/obj/item/smartgun_powerpack)

				var/pick_special = rand(0,6)
				switch(pick_special)
					if(0)//Heavy Armor
						spawnitems += list(/obj/item/weapon/storage/box/heavy_armor)
					if(1)//M56 System
						spawnitems += list(/obj/item/weapon/storage/box/m56_system)
					if(2)//M42c System
						spawnitems += list(/obj/item/weapon/storage/box/m42c_system)
					if(3)//Grenade System
						spawnitems += list(/obj/item/weapon/storage/box/grenade_system)
					if(4)//Rocket System
						spawnitems += list(/obj/item/weapon/storage/box/rocket_system)
					if(5)//Sentry
						spawnitems += list(/obj/item/weapon/storage/box/sentry)
					if(6)//Minigun
						spawnitems += list(/obj/item/weapon/gun/minigun,
										/obj/item/ammo_magazine/minigun,
										/obj/item/ammo_magazine/minigun,
										/obj/item/ammo_magazine/minigun)


			if(1)//Random Attachments Crate
				choosemax = rand(10,20)
				randomitems = list(/obj/item/attachable/suppressor,
								/obj/item/attachable/suppressor,
								/obj/item/attachable/reddot,
								/obj/item/attachable/reddot,
								/obj/item/attachable/scope,
								/obj/item/attachable/magnetic_harness,
								/obj/item/attachable/quickfire,
								/obj/item/attachable/bayonet,
								/obj/item/attachable/bayonet,
								/obj/item/attachable/extended_barrel,
								/obj/item/attachable/heavy_barrel,
								/obj/item/attachable/compensator,
								/obj/item/attachable/foregrip,
								/obj/item/attachable/gyro,
								/obj/item/attachable/bipod,
								/obj/item/attachable/shotgun,
								/obj/item/attachable/flamer,
								/obj/item/attachable/burstfire_assembly,
								/obj/item/attachable/compensator/revolverstock,
								/obj/item/attachable/compensator/riflestock,
								/obj/item/attachable/compensator/stock)

			if(2)//Random Melee Crate
				choosemax = rand(10,20)
				randomitems = list(/obj/item/weapon/combat_knife,
								/obj/item/weapon/combat_knife,
								/obj/item/weapon/combat_knife,
								/obj/item/weapon/combat_knife,
								/obj/item/weapon/combat_knife,
								/obj/item/weapon/combat_knife,
								/obj/item/weapon/combat_knife,
								/obj/item/weapon/combat_knife,
								/obj/item/weapon/combat_knife,
								/obj/item/weapon/combat_knife,
								/obj/item/weapon/storage/belt/knifepouch,
								/obj/item/weapon/storage/belt/knifepouch,
								/obj/item/weapon/storage/belt/knifepouch,
								/obj/item/weapon/claymore/mercsword/machete)

			if(3)//Random Explosives Items
				choosemax = rand(10,20)
				randomitems = list(/obj/item/weapon/storage/box/explosive_mines,
									/obj/item/weapon/grenade/explosive,
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
									/obj/item/weapon/grenade/incendiary,
									/obj/item/weapon/grenade/incendiary,
									/obj/item/ammo_magazine/rocket_tube,
									/obj/item/ammo_magazine/rocket_tube,
									/obj/item/ammo_magazine/rocket_tube/ap,
									/obj/item/ammo_magazine/rocket_tube/wp,
									/obj/item/weapon/plastique)


			if(4 to 5)//Random Primary Gun
				choosemax = rand(5,10)
				randomitems = list(/obj/item/weapon/gun/rifle/m41a,
									/obj/item/weapon/gun/rifle/m41a,
									/obj/item/weapon/gun/rifle/m41a,
									/obj/item/weapon/gun/rifle/m41a,
									/obj/item/weapon/gun/rifle/m41a/scoped,
									/obj/item/weapon/gun/rifle/m41a/elite,
									/obj/item/weapon/gun/rifle/mar40,
									/obj/item/weapon/gun/rifle/mar40,
									/obj/item/weapon/gun/rifle/mar40/carbine,
									/obj/item/weapon/gun/rifle/mar40/svd,
									/obj/item/weapon/gun/rifle/lmg,
									/obj/item/weapon/gun/shotgun/combat,
									/obj/item/weapon/gun/shotgun/merc,
									/obj/item/weapon/gun/shotgun/double,
									/obj/item/weapon/gun/shotgun/double/sawn,
									/obj/item/weapon/gun/shotgun/pump,
									/obj/item/weapon/gun/shotgun/pump,
									/obj/item/weapon/gun/shotgun/pump/cmb)

			if(6 to 7)//Random Secondary Gun
				choosemax = rand(10,15)
				randomitems = list(/obj/item/weapon/gun/smg/m39,
									/obj/item/weapon/gun/smg/m39,
									/obj/item/weapon/gun/smg/m39,
									/obj/item/weapon/gun/smg/m39/elite,
									/obj/item/weapon/gun/smg/mp7,
									/obj/item/weapon/gun/smg/skorpion,
									/obj/item/weapon/gun/smg/ppsh,
									/obj/item/weapon/gun/smg/uzi,
									/obj/item/weapon/gun/smg/p90,
									/obj/item/weapon/gun/pistol/m4a3,
									/obj/item/weapon/gun/pistol/m4a3,
									/obj/item/weapon/gun/pistol/m4a3,
									/obj/item/weapon/gun/pistol/heavy,
									/obj/item/weapon/gun/pistol/c99,
									/obj/item/weapon/gun/pistol/m1911,
									/obj/item/weapon/gun/pistol/kt42,
									/obj/item/weapon/gun/pistol/holdout,
									/obj/item/weapon/gun/pistol/highpower,
									/obj/item/weapon/gun/pistol/vp70,
									/obj/item/weapon/gun/pistol/vp78,
									/obj/item/weapon/gun/revolver/m44,
									/obj/item/weapon/gun/revolver/m44,
									/obj/item/weapon/gun/revolver/small,
									/obj/item/weapon/gun/revolver/upp,
									/obj/item/weapon/gun/revolver/mateba,
									/obj/item/weapon/gun/revolver/cmb)

			if(8 to 12)//Random Primary Ammo
				choosemax = rand(25,30)
				randomitems = list(/obj/item/ammo_magazine/rifle,
									/obj/item/ammo_magazine/rifle,
									/obj/item/ammo_magazine/rifle,
									/obj/item/ammo_magazine/rifle,
									/obj/item/ammo_magazine/rifle/extended,
									/obj/item/ammo_magazine/rifle/incendiary,
									/obj/item/ammo_magazine/rifle/ap,
									/obj/item/ammo_magazine/rifle/marksman,
									/obj/item/ammo_magazine/rifle/elite,
									/obj/item/ammo_magazine/rifle/mar40,
									/obj/item/ammo_magazine/rifle/mar40,
									/obj/item/ammo_magazine/rifle/mar40/extended,
									/obj/item/ammo_magazine/rifle/mar40/svd,
									/obj/item/ammo_magazine/rifle/lmg,
									/obj/item/ammo_magazine/shotgun,
									/obj/item/ammo_magazine/shotgun,
									/obj/item/ammo_magazine/shotgun/buckshot,
									/obj/item/ammo_magazine/shotgun/buckshot,
									/obj/item/ammo_magazine/shotgun/incendiary,
									/obj/item/ammo_magazine/shotgun/double,
									/obj/item/ammo_magazine/shotgun/cmb,
									/obj/item/ammo_magazine/shotgun/cmb,
									/obj/item/ammo_magazine/shotgun/buckshot/cmb,
									/obj/item/ammo_magazine/shotgun/incendiary/cmb)

			if(13 to 16)//Random Secondary Ammo
				choosemax = rand(25,30)
				randomitems = list(/obj/item/ammo_magazine/pistol,
									/obj/item/ammo_magazine/pistol,
									/obj/item/ammo_magazine/pistol,
									/obj/item/ammo_magazine/pistol/hp,
									/obj/item/ammo_magazine/pistol/ap,
									/obj/item/ammo_magazine/pistol/incendiary,
									/obj/item/ammo_magazine/pistol/extended,
									/obj/item/ammo_magazine/revolver,
									/obj/item/ammo_magazine/revolver,
									/obj/item/ammo_magazine/revolver/marksman,
									/obj/item/ammo_magazine/revolver/small,
									/obj/item/ammo_magazine/revolver/upp,
									/obj/item/ammo_magazine/revolver/mateba,
									/obj/item/ammo_magazine/pistol/heavy,
									/obj/item/ammo_magazine/pistol/c99,
									/obj/item/ammo_magazine/pistol/m1911,
									/obj/item/ammo_magazine/pistol/automatic,
									/obj/item/ammo_magazine/pistol/holdout,
									/obj/item/ammo_magazine/pistol/highpower,
									/obj/item/ammo_magazine/revolver/cmb,
									/obj/item/ammo_magazine/pistol/vp70,
									/obj/item/ammo_magazine/pistol/vp78,
									/obj/item/ammo_magazine/smg/m39,
									/obj/item/ammo_magazine/smg/m39,
									/obj/item/ammo_magazine/smg/m39,
									/obj/item/ammo_magazine/smg/m39/extended,
									/obj/item/ammo_magazine/smg/elite,
									/obj/item/ammo_magazine/smg/mp7,
									/obj/item/ammo_magazine/smg/skorpion,
									/obj/item/ammo_magazine/smg/ppsh,
									/obj/item/ammo_magazine/smg/ppsh/extended,
									/obj/item/ammo_magazine/smg/uzi,
									/obj/item/ammo_magazine/smg/p90)

	else if (OT == "sup")
		randpick = rand(0,12)
		crate = new /obj/structure/closet/crate/secure/gear(T)
		switch(randpick)
			if(0 to 1)//Food
				choosemax = rand(25,30)
				randomitems = list(/obj/item/weapon/storage/box/uscm_mre,
								/obj/item/weapon/storage/box/donkpockets,
								/obj/item/weapon/reagent_containers/food/snacks/protein_pack,
								/obj/item/weapon/reagent_containers/food/snacks/protein_pack,
								/obj/item/weapon/reagent_containers/food/snacks/mre_pack/meal1,
								/obj/item/weapon/reagent_containers/food/snacks/mre_pack/meal1,
								/obj/item/weapon/reagent_containers/food/snacks/mre_pack/meal2,
								/obj/item/weapon/reagent_containers/food/snacks/mre_pack/meal2,
								/obj/item/weapon/reagent_containers/food/snacks/mre_pack/meal3,
								/obj/item/weapon/reagent_containers/food/snacks/mre_pack/meal3,
								/obj/item/weapon/reagent_containers/food/snacks/mre_pack/meal4,
								/obj/item/weapon/reagent_containers/food/snacks/mre_pack/meal4,
								/obj/item/weapon/reagent_containers/food/snacks/mre_pack/meal5,
								/obj/item/weapon/reagent_containers/food/snacks/mre_pack/meal5,
								/obj/item/weapon/reagent_containers/food/snacks/mre_pack/meal6,
								/obj/item/weapon/reagent_containers/food/snacks/mre_pack/meal6,
								/obj/item/weapon/storage/box/wy_mre)

			if(2 to 3)//Tools
				choosemax = rand(3,6)
				randomitems = list(/obj/item/device/multitool,
								/obj/item/device/multitool,
								/obj/item/weapon/storage/toolbox/electrical,
								/obj/item/weapon/storage/toolbox/mechanical,
								/obj/item/weapon/storage/belt/utility/full,
								/obj/item/weapon/weldpack,
								/obj/item/weapon/cell/high,
								/obj/item/clothing/glasses/welding								)

			if(4 to 6)//Marine Gear
				choosemax = rand(10,15)
				randomitems = list(/obj/item/clothing/head/helmet/marine,
								/obj/item/clothing/head/helmet/marine,
								/obj/item/clothing/head/helmet/marine,
								/obj/item/weapon/storage/belt/marine,
								/obj/item/weapon/storage/belt/marine,
								/obj/item/clothing/suit/storage/marine,
								/obj/item/clothing/suit/storage/marine,
								/obj/item/clothing/suit/storage/marine,
								/obj/item/clothing/head/helmet/marine/tech,
								/obj/item/clothing/head/helmet/marine/medic,
								/obj/item/clothing/under/marine/fluff/marinemedic,
								/obj/item/clothing/under/marine/fluff/marineengineer,
								/obj/item/clothing/tie/storage/webbing,
								/obj/item/clothing/tie/storage/webbing,
								/obj/item/device/binoculars)

			if(7 to 8)//Lights and shiet
				choosemax = rand(10,20)
				randomitems = list(/obj/item/device/flashlight/flare,
								/obj/item/device/flashlight/flare,
								/obj/item/device/flashlight/flare,
								/obj/item/device/flashlight/flare,
								/obj/item/device/flashlight/flare,
								/obj/item/device/flashlight/flare,
								/obj/item/device/flashlight/flare,
								/obj/item/device/flashlight/flare,
								/obj/item/device/flashlight/flare,
								/obj/item/device/flashlight/flare,
								/obj/item/device/flashlight/combat,
								/obj/item/device/flashlight/combat,
								/obj/item/device/flashlight/combat,
								/obj/item/device/flashlight/combat,
								/obj/machinery/floodlight,
								/obj/item/weapon/storage/box/lightstick/red)

			if(9)//Crap
				choosemax = rand(2,3)
				randomitems = list(/obj/item/weapon/facepaint/green,
									/obj/item/weapon/facepaint/brown,
									/obj/item/weapon/facepaint/black,
									/obj/item/weapon/facepaint/sniper,
									/obj/item/weapon/storage/box/bodybags)

			if(10 to 12)//Materials
				choosemax = rand(3,8)
				randomitems = list(/obj/item/stack/rods,
								/obj/item/stack/sheet/glass,
								/obj/item/stack/sheet/metal,
								/obj/item/stack/sheet/metal,
								/obj/item/stack/sheet/plasteel,
								/obj/item/stack/sheet/wood,
								/obj/item/stack/sheet/wood,
								/obj/item/stack/sheet/mineral/phoron)


	if(randomitems.len)
		for(var/path in randomitems)
			path = pick(randomitems)
			var/obj/I = new path(crate)
			if(OT == "sup")
				if(I && istype(I,/obj/item/stack/sheet/mineral/phoron) || istype(I,/obj/item/stack/rods) || istype(I,/obj/item/stack/sheet/glass) || istype(I,/obj/item/stack/sheet/metal) || istype(I,/obj/item/stack/sheet/plasteel) || istype(I,/obj/item/stack/sheet/wood))
					if(istype(I,/obj/item/stack/sheet/mineral/phoron))
						I:amount = 50
					else
						I:amount = rand(10,30)
				if(I && istype(I,/obj/machinery/floodlight))
					I.anchored = 0
			choosemax--
			if(!choosemax)
				break

	else
		for(var/path in spawnitems)
			new path(crate)

//Whiskey Outpost Recycler Machine. Teleports objects to centcomm so it doesnt lag
/obj/machinery/wo_recycler
	icon = 'icons/obj/recycling.dmi'
	icon_state = "grinder-o0"
	var/icon_on = "grinder-o1"

	name = "Recycler"
	desc = "Instructions: Place objects you want to destroy on top of it and use the machine. Use with care"
	density = 0
	anchored = 1
	var/working = 0

	attack_hand(mob/user)
		if(inoperable(MAINT))
			return
		if(user.lying || user.stat)
			return
		if(istype(usr, /mob/living/silicon) || \
			istype(usr, /mob/living/carbon/Xenomorph) || \
			istype(usr, /mob/living/carbon/monkey))
			usr << "\red You don't have the dexterity to do this!"
			return
		if(working)
			user << "\red Wait for it to recharge first."
			return

		var/remove_max = 10
		var/turf/T = src.loc
		if(T)
			user << "\red You turn on the recycler."
			var/removed = 0
			for(var/i, i < remove_max, i++)
				for(var/obj/O in T)
					if(istype(O,/obj/structure/closet/crate))
						var/obj/structure/closet/crate/C = O
						if(C.contents.len)
							user << "\red [O] must be emptied before it can be recycled"
							continue
						new /obj/item/stack/sheet/metal(get_step(src,dir))
						O.loc = get_turf(locate(84,237,2)) //z.2
//						O.loc = get_turf(locate(30,70,1)) //z.1
						removed++
						break
					else if(istype(O,/obj/item))
						var/obj/item/I = O
						if(I.anchored)
							continue
						O.loc = get_turf(locate(84,237,2)) //z.2
//						O.loc = get_turf(locate(30,70,1)) //z.1
						removed++
						break
				for(var/mob/M in T)
					if(istype(M,/mob/living/carbon/Xenomorph))
						var/mob/living/carbon/Xenomorph/X = M
						if(!X.stat == DEAD)
							continue
						O.loc = get_turf(locate(84,237,2)) //z.2
//						X.loc = get_turf(locate(30,70,1)) //z.1
						removed++
						break
				if(removed && !working)
					playsound(loc, 'sound/effects/meteorimpact.ogg', 100, 1)
					working = 1 //Stops the sound from repeating
				if(removed >= remove_max)
					break

		working = 1
		spawn(100)
			working = 0