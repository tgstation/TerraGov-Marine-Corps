/datum/game_mode/whiskey_outpost
	name = "Whiskey Outpost"
	config_tag = "Whiskey Outpost"
	required_players 		= 1
	recommended_enemies 	= 6 //Force doctors and commander if no one wants them
	xeno_bypass_timer 		= 1
	role_instruction		= 1
	roles_for_mode = list(/datum/job/marine/standard/equipped,
					/datum/job/marine/medic/equipped,
					/datum/job/marine/engineer/equipped,
					/datum/job/marine/specialist/equipped,
					/datum/job/marine/leader/equipped
					)

	flags_round_type	= MODE_NO_LATEJOIN

	var/mob/living/carbon/human/Commander //If there is no Commander, marines wont get any supplies

	var/checkwin_counter = 0
	var/finished = 0
	var/has_started_timer = 5 //This is a simple timer so we don't accidently check win conditions right in post-game

	var/spawn_next_wave = 200 //Spawn first batch at ~15 minutes //200
	var/xeno_wave = 0 //Which wave is it
	var/spawn_xeno_num = 30 //How many to spawn per wave //First wave is big, cus runners.

	var/wave_ticks_passed = 0 //Timer for xeno waves

	var/next_xeno_cleanup = 2 //At which wave does it move all dead xenos to centcomm to prevent client lag

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
	var/lobby_time = 0 //Lobby time does not count for marine 1h win condition
	var/wave_times_delayed = 0 //How many time was the current wave delayed due to pop limit?
	//Who to spawn and how often which caste spawns
		//The more entires with same path, the more chances there are to pick it
			//This will get populated with spawn_xenos() proc
	var/list/spawnxeno = list()

/datum/game_mode/whiskey_outpost/announce()
	return 1

/datum/game_mode/whiskey_outpost/send_intercept()
	return 1

/datum/game_mode/whiskey_outpost/pre_setup()
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
	var/docs_free = 5

	//Setup possible roles list
	if(possible_roles.len)
		//Commanders
		for(var/datum/mind/S in possible_roles)
			if(S && S.assigned_role != "MODE" && !S.special_role) //Make sure it's not already here.
				S.assigned_role = "MODE"
				S.special_role = "WO_COM"
				break

		//Doctors
		for(var/datum/mind/S in possible_roles)
			if(S && S.assigned_role != "MODE" && !S.special_role) //Make sure it's not already here.
				S.assigned_role = "MODE"
				S.special_role = "WO_DOC"
				docs_free--
				if(!docs_free)
					break

	return 1

/datum/game_mode/whiskey_outpost/post_setup()
	lobby_time = world.time
	var/mob/M

	if(config) config.remove_gun_restrictions = 1

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

	if(istype(M,/mob/living/carbon/human)) //If We started on Sulaco as squad marine
		H = M
		if(H.contents.len)
			for(var/I in H.contents)//Delete the cryo uniform
				if(istype(I,/obj/item/clothing/under/pj/marine))
					del(I)
		H.loc = picked
	else //Else if we spawned as doctor or commander
		H = new(picked)

	H.key = M.key

	if(!H.mind)
		H.mind = new(H.key)

	H.nutrition = rand(325,400)

	//Squad ID and backpack are already spawned in job datum

	//COMMANDER
	if(H.mind.special_role == "WO_COM")
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/mcom(H), WEAR_L_EAR)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/marine/satchel(H), WEAR_BACK)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/officer/command(H), WEAR_BODY)
		H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/MP/RO(H), WEAR_JACKET)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marinechief/commander(H), WEAR_FEET)
		H.equip_to_slot_or_del(new /obj/item/clothing/head/cmberet/tan(H), WEAR_HEAD)
		H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/techofficer/commander(H), WEAR_HANDS)
		H.equip_to_slot_or_del(new /obj/item/weapon/book/manual/whiskey_outpost_map(H), WEAR_R_HAND)


		H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/heavy(H), WEAR_WAIST)
		H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/heavy(H), WEAR_IN_BACK)
		H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/heavy(H), WEAR_IN_BACK)
		H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/heavy(H), WEAR_IN_BACK)
		Commander = H //Make him the Commander

		var/obj/item/weapon/card/id/gold/W = new(H)
		W.name = "[M.real_name]'s ID Card"
		W.access = get_all_accesses()
		W.assignment = "Commander"
		W.registered_name = M.real_name
		H.equip_to_slot_or_del(W, WEAR_ID)

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

	//DOCTORS
	else if(H.mind.special_role == "WO_DOC") //Then, the doctors
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/medic(H), WEAR_BACK)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/medical/green(H), WEAR_BODY)
		H.equip_to_slot_or_del(new /obj/item/clothing/head/surgery/green(H), WEAR_HEAD)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(H), WEAR_FEET)
		H.equip_to_slot_or_del(new /obj/item/device/flashlight/pen(H), WEAR_J_STORE)
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_med(H), WEAR_L_EAR)

		//Combat Lifesaver belt
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/medical/combatLifesaver(H), WEAR_WAIST)

		//Advanced Meds
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/pill_bottle/peridaxon(H), WEAR_L_STORE)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/pill_bottle/peridaxon(H), WEAR_R_STORE)

		var/obj/item/weapon/card/id/W = new(H)
		W.name = "[M.real_name]'s ID Card"
		W.access = list(ACCESS_MARINE_CMO, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_RESEARCH, ACCESS_MARINE_BRIDGE)
		W.assignment = "Doctor"
		W.registered_name = M.real_name
		H.equip_to_slot_or_del(W, WEAR_ID)

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

	//SQUADS
	else
		var/randwep = 1 //Specialists spawn with their own random weapon


		//SQUAD LEADER
		if(H.mind.assigned_role == "Squad Leader")
			H.equip_to_slot_or_del(new /obj/item/clothing/under/marine(H), WEAR_BODY)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/leader(H), WEAR_HEAD)
			H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/leader(H), WEAR_JACKET)

			//SPESHUL EQUIPMENT
			//Machete
			H.equip_to_slot_or_del(new /obj/item/weapon/claymore/mercsword/machete(H), WEAR_R_HAND)

			//Binos, webbing and bomb beacons in backpack
			H.equip_to_slot_or_del(new /obj/item/device/squad_beacon/bomb(H), WEAR_IN_BACK)
			H.equip_to_slot_or_del(new /obj/item/device/squad_beacon/bomb(H), WEAR_IN_BACK)
			H.equip_to_slot_or_del(new /obj/item/device/binoculars(H), WEAR_IN_BACK)
			H.equip_to_slot_or_del(new /obj/item/clothing/tie/storage/webbing(H), WEAR_IN_BACK)

			//Belt and grenades
			var/obj/item/weapon/storage/belt/marine/B = new/obj/item/weapon/storage/belt/marine(H)
			new /obj/item/weapon/grenade/explosive(B)
			new /obj/item/weapon/grenade/explosive(B)
			new /obj/item/weapon/grenade/explosive(B)
			new /obj/item/weapon/grenade/incendiary(B)
			new /obj/item/weapon/grenade/incendiary(B)
			H.equip_to_slot_or_del(B, WEAR_WAIST)


		//SQUAD ENGINEER
		else if(H.mind.assigned_role == "Squad Engineer")
			H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/engineer(H), WEAR_BODY)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/tech(H), WEAR_HEAD)
			H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine(H), WEAR_JACKET)

			//SPESHUL EQUIPMENT
			//Metal, webbing, grenades in backpack
			var/obj/item/stack/sheet/metal/MET = new /obj/item/stack/sheet/metal(H)
			MET.amount = 50
			H.equip_to_slot_or_del(MET, WEAR_IN_BACK)
			H.equip_to_slot_or_del(new /obj/item/weapon/grenade/explosive(H), WEAR_IN_BACK)
			H.equip_to_slot_or_del(new /obj/item/weapon/grenade/incendiary(H), WEAR_IN_BACK)
			H.equip_to_slot_or_del(new /obj/item/clothing/tie/storage/webbing(H), WEAR_IN_BACK)


			//Utility Belt
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/utility/full(H), WEAR_WAIST)

			//Welding Glasses
			H.equip_to_slot_or_del(new /obj/item/clothing/glasses/welding(H), WEAR_EYES)

		//SQUAD MEDIC
		else if(H.mind.assigned_role == "Squad Medic")
			H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/medic(H), WEAR_BODY)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/medic(H), WEAR_HEAD)
			H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine(H), WEAR_JACKET)

			//SPESHUL EQUIPMENT
			//Defibs, webbing, first aid, adv aid in backpack
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid/regular(H), WEAR_IN_BACK)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid/adv(H), WEAR_IN_BACK)
			H.equip_to_slot_or_del(new /obj/item/clothing/tie/storage/webbing(H), WEAR_IN_BACK)
			H.equip_to_slot_or_del(new /obj/item/weapon/melee/defibrillator(H), WEAR_IN_BACK)

			//Medical encryption key
			H.equip_to_slot_or_del(new /obj/item/device/encryptionkey/headset_med(H), WEAR_L_HAND)

			//Combat Lifesaver belt
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/medical/combatLifesaver(H), WEAR_WAIST)

			//Med Hud
			H.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/health(H), WEAR_EYES)

		//SQUAD SPECIALIST
		else if(H.mind.assigned_role == "Squad Specialist")
			randwep = 0
			var/type = rand(0,14)

			switch(type) //Scaled based on player feedback
				if(0 to 4)//Smartgun
					H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/m56_system(H), WEAR_R_HAND)
					H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine(H), WEAR_HEAD)

				if(5 to 8)//Sniper
					H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/m42c_system(H), WEAR_R_HAND)

				if(9 to 11)//SADAR
					H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/rocket_system(H), WEAR_R_HAND)

					H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine(H), WEAR_HEAD)
					H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine(H), WEAR_JACKET)

				if(12 to 13)//Flamethrower
					H.equip_to_slot_or_del(new /obj/item/weapon/flamethrower/full(H), WEAR_J_STORE)
					H.equip_to_slot_or_del(new /obj/item/weapon/tank/phoron/m240(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/weapon/tank/phoron/m240(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/weapon/tank/phoron/m240(H), WEAR_IN_BACK)

					H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine(H), WEAR_HEAD)
					H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine(H), WEAR_JACKET)


				if(14)//Grenade Launcher
					H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/grenade_system(H), WEAR_R_HAND)

					H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine(H), WEAR_HEAD)
					H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine(H), WEAR_JACKET)

			H.equip_to_slot_or_del(new /obj/item/clothing/under/marine(H), WEAR_BODY)

			//SPESHUL EQUIPMENT
			//Webbing
			H.equip_to_slot_or_del(new /obj/item/clothing/tie/storage/webbing(H), WEAR_IN_BACK)

			//Backup SMG Weapon
			H.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/m39(H), WEAR_WAIST)
			H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m39(H), WEAR_IN_BACK)
			H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m39(H), WEAR_IN_BACK)
			H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m39(H), WEAR_IN_BACK)

		//SQUAD MARINE
		else
			H.equip_to_slot_or_del(new /obj/item/clothing/under/marine(H), WEAR_BODY)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine(H), WEAR_HEAD)
			H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine(H), WEAR_JACKET)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/marine(H), WEAR_WAIST)

		//Every Squad Starts with this:
		H.equip_to_slot_or_del(new /obj/item/device/flashlight/flare(H), WEAR_L_STORE)
		H.equip_to_slot_or_del(new /obj/item/device/flashlight(H), WEAR_R_STORE)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(H), WEAR_FEET)
		//Knife
		if(prob(25))
			H.equip_to_slot_or_del(new /obj/item/weapon/combat_knife(H), WEAR_L_HAND)




		//Find their squad
		var/squad = get_squad_from_card(H)
		var/leader = is_leader_from_card(H)

		//Squad Gloves and radio headsets
		switch(squad)
			if(1)//Alpha
					//Radio
				if(leader)
					H.equip_to_slot_or_del(new /obj/item/device/radio/headset/malphal(H), WEAR_L_EAR)
				else
					H.equip_to_slot_or_del(new /obj/item/device/radio/headset/malpha(H), WEAR_L_EAR)
					//Gloves
				if(H.mind.assigned_role != "Squad Engineer")
					H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/alpha(H), WEAR_HANDS)
				else
					H.equip_to_slot_or_del(new /obj/item/clothing/gloves/yellow(H), WEAR_HANDS)

			if(2)//Bravo
					//Radio
				if(leader)
					H.equip_to_slot_or_del(new /obj/item/device/radio/headset/mbravol(H), WEAR_L_EAR)
				else
					H.equip_to_slot_or_del(new /obj/item/device/radio/headset/mbravo(H), WEAR_L_EAR)
					//Gloves
				if(H.mind.assigned_role != "Squad Engineer")
					H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/bravo(H), WEAR_HANDS)
				else
					H.equip_to_slot_or_del(new /obj/item/clothing/gloves/yellow(H), WEAR_HANDS)

			if(3)//Charlie
					//Radio
				if(leader)
					H.equip_to_slot_or_del(new /obj/item/device/radio/headset/mcharliel(H), WEAR_L_EAR)
				else
					H.equip_to_slot_or_del(new /obj/item/device/radio/headset/mcharlie(H), WEAR_L_EAR)
					//Gloves
				if(H.mind.assigned_role != "Squad Engineer")
					H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/charlie(H), WEAR_HANDS)
				else
					H.equip_to_slot_or_del(new /obj/item/clothing/gloves/yellow(H), WEAR_HANDS)

			if(4)//Delta
					//Radio
				if(leader)
					H.equip_to_slot_or_del(new /obj/item/device/radio/headset/mdeltal(H), WEAR_L_EAR)
				else
					H.equip_to_slot_or_del(new /obj/item/device/radio/headset/mdelta(H), WEAR_L_EAR)
					//Gloves
				if(H.mind.assigned_role != "Squad Engineer")
					H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/delta(H), WEAR_HANDS)
				else
					H.equip_to_slot_or_del(new /obj/item/clothing/gloves/yellow(H), WEAR_HANDS)

		//Set Random Weapon and Ammo
		if(randwep)
			var/rand_wep = rand(0,2)
			switch(rand_wep)
				if(0)//M41a
					H.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/m41a(H), WEAR_J_STORE)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle(H), WEAR_IN_BACK)
				if(1)//Combat Shotgun
					H.equip_to_slot_or_del(new /obj/item/weapon/gun/shotgun/combat(H), WEAR_J_STORE)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/shotgun(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/shotgun(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/shotgun(H), WEAR_IN_BACK)
				if(2)//SMG
					H.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/m39(H), WEAR_J_STORE)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m39(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m39(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m39(H), WEAR_IN_BACK)
		//Give them some information
		spawn(40)
			if(H)
				H << "________________________"
				H << "\red <b>You are the [H.mind.assigned_role]!<b>"
				H << "Gear up, prepare defenses, work as a team. Protect your doctors and commander!"
				H << "Motion trackers have detected movement from local creatures, and they are heading towards the outpost!"
				H << "Hold the outpost for one hour until the main force arrives!"
				H << "________________________"
	//Finally, update all icons
	H.update_icons()

	return 1


//PROCCESS
/datum/game_mode/whiskey_outpost/process()
	checkwin_counter++
	ticks_passed++
	wave_ticks_passed++

	//XENO AND SUPPLY DROPS SPAWNER
	if(wave_ticks_passed >= spawn_next_wave)
		if(count_xenos() < 50)//Checks braindead too, so we don't overpopulate!
			world << "\red *___________________________________*"
			world << "\red <b>***Whiskey Outpost Controller***</b>"
			world << "\blue <b>Wave:</b> [xeno_wave][wave_times_delayed?"|\red Times delayed: [wave_times_delayed]":""]"
			world << "\red *___________________________________*"

			wave_ticks_passed = 0
			if(xeno_wave == next_xeno_cleanup)
				next_xeno_cleanup += 3 //Scedule next cleanup
				CleanXenos()

			if(spawn_next_wave > 40)
				spawn_next_wave -= 5
			spawn_xenos(spawn_xeno_num)

			if(spawn_xeno_num < 50)
				spawn_xeno_num += 2

			if(wave_times_delayed)
				wave_times_delayed = 0
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
			wave_ticks_passed -= 20 //Wait 20 ticks and try again
			wave_times_delayed++

	if(has_started_timer > 0) //Initial countdown, just to be safe, so that everyone has a chance to spawn before we check anything.
		has_started_timer--

	if(checkwin_counter >= 10) //Only check win conditions every 10 ticks.
		if(!finished)
			check_win()
		checkwin_counter = 0
	return 0

//CHECK WIN
/datum/game_mode/whiskey_outpost/check_win()
	var/C = count_humans()

	if(C == 0)
		finished = 1 //Alien win
	else if(world.time > 36000 + lobby_time)//one hour or so
		finished = 2 //Marine win

//SPAWN XENOS
/datum/game_mode/whiskey_outpost/proc/spawn_xenos(var/amt = 1)
	var/spawn_this_many = amt
	var/turf/picked
	//var/xenos_spawned = 0 //Debug
	var/list/tempspawnxeno = list() //Temporarly replaces the main list
	var/list/xeno_spawn_loc = list()
	if(slashing_allowed != 1)
		slashing_allowed = 1 //Allows harm intent for aliens

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
			spawn_xeno_num = 20 //Reset
			spawn_next_wave = 90
			world << sound('sound/effects/siren.ogg') //Mark the first wave


		if(1)//Sentinels and drones are more common
			spawnxeno += list(/mob/living/carbon/Xenomorph/Runner,
						/mob/living/carbon/Xenomorph/Runner,
						/mob/living/carbon/Xenomorph/Runner/mature,
						/mob/living/carbon/Xenomorph/Runner/mature,
						/mob/living/carbon/Xenomorph/Runner/mature,
						/mob/living/carbon/Xenomorph/Sentinel,
						/mob/living/carbon/Xenomorph/Sentinel/mature,
						/mob/living/carbon/Xenomorph/Drone)


		if(3)//Tier II versions added, but rare
			spawnxeno += list(/mob/living/carbon/Xenomorph/Hunter,
						/mob/living/carbon/Xenomorph/Spitter/mature,
						/mob/living/carbon/Xenomorph/Drone/mature)

		if(4)//Tier II more common
			spawnxeno += list(/mob/living/carbon/Xenomorph/Runner/mature,
						/mob/living/carbon/Xenomorph/Hunter/mature,
						/mob/living/carbon/Xenomorph/Spitter)

		if(6)//Hivelord and Tier II more common
			spawnxeno += list(/mob/living/carbon/Xenomorph/Hunter/mature,
						/mob/living/carbon/Xenomorph/Spitter/mature,
						/mob/living/carbon/Xenomorph/Hivelord)

		if(7)
			spawn_next_wave += 110 //Slow down now, strong castes introduced next wave
			spawn_xeno_num = 20

		if(8)//Ravager and Praetorian Added, Tier II more common, Tier I less common
			spawnxeno += list(/mob/living/carbon/Xenomorph/Ravager,
						/mob/living/carbon/Xenomorph/Praetorian,
						/mob/living/carbon/Xenomorph/Hunter/elite,
						/mob/living/carbon/Xenomorph/Hunter/mature,
						/mob/living/carbon/Xenomorph/Spitter/mature)

			spawnxeno -= list(/mob/living/carbon/Xenomorph/Sentinel,
						/mob/living/carbon/Xenomorph/Drone,
						/mob/living/carbon/Xenomorph/Runner,
						/mob/living/carbon/Xenomorph/Runner)

		if(10)//Boiler and Crusher Added, Ravager and Praetorian more common. Tier I less common
			spawnxeno += list(/mob/living/carbon/Xenomorph/Crusher,
						/mob/living/carbon/Xenomorph/Boiler/mature,
						/mob/living/carbon/Xenomorph/Ravager/mature,
						/mob/living/carbon/Xenomorph/Runner/elite,
						/mob/living/carbon/Xenomorph/Runner/elite,
						/mob/living/carbon/Xenomorph/Praetorian)

			spawnxeno -= list(/mob/living/carbon/Xenomorph/Sentinel,
						/mob/living/carbon/Xenomorph/Drone/mature,
						/mob/living/carbon/Xenomorph/Runner/mature)

		if(12)//Start the elite transition
			spawnxeno += list(/mob/living/carbon/Xenomorph/Crusher/mature,
						/mob/living/carbon/Xenomorph/Boiler/elite,
						/mob/living/carbon/Xenomorph/Ravager/elite,
						/mob/living/carbon/Xenomorph/Runner/elite,
						/mob/living/carbon/Xenomorph/Hivelord/elite,
						/mob/living/carbon/Xenomorph/Spitter/elite,
						/mob/living/carbon/Xenomorph/Praetorian/elite)

			spawnxeno -= list(/mob/living/carbon/Xenomorph/Spitter/mature,
						/mob/living/carbon/Xenomorph/Drone/mature,
						/mob/living/carbon/Xenomorph/Hivelord)

		if(14)//Start the ancient
			spawnxeno += list(/mob/living/carbon/Xenomorph/Crusher/ancient,
						/mob/living/carbon/Xenomorph/Boiler/ancient,
						/mob/living/carbon/Xenomorph/Ravager/ancient,
						/mob/living/carbon/Xenomorph/Runner/ancient,
						/mob/living/carbon/Xenomorph/Hunter/ancient,
						/mob/living/carbon/Xenomorph/Spitter/ancient,
						/mob/living/carbon/Xenomorph/Praetorian/ancient)

			spawnxeno -= list(/mob/living/carbon/Xenomorph/Crusher,
						/mob/living/carbon/Xenomorph/Hunter/mature,
						/mob/living/carbon/Xenomorph/Praetorian)

		if(15 to INFINITY)
			var/random_wave = rand(0,8)
			switch(random_wave)
				if(0 to 5)//Normal list, but makes it easier to pick stronger units
					switch(random_wave)
						if(0)//Add another Ravager
							spawnxeno += list(/mob/living/carbon/Xenomorph/Ravager/ancient)
						if(1)//Add another Carrier
							spawnxeno += list(/mob/living/carbon/Xenomorph/Carrier/ancient)
						if(2)//Add another Praetorian
							spawnxeno += list(/mob/living/carbon/Xenomorph/Praetorian/ancient)
						if(3)//Add another Boiler
							spawnxeno += list(/mob/living/carbon/Xenomorph/Boiler/ancient)
						if(4)//Add another Crusher
							spawnxeno += list(/mob/living/carbon/Xenomorph/Crusher/ancient)
						if(5)//Add another Hunter and Spitter
							spawnxeno += list(/mob/living/carbon/Xenomorph/Hunter/ancient,
										/mob/living/carbon/Xenomorph/Spitter/ancient)

				if(6)//Runner madness
					spawn_next_wave += 50//Slow down the next wave
					spawn_this_many = 50//A lot of them
					tempspawnxeno = list(/mob/living/carbon/Xenomorph/Runner,
									/mob/living/carbon/Xenomorph/Runner/ancient,
									/mob/living/carbon/Xenomorph/Runner/ancient,
									/mob/living/carbon/Xenomorph/Runner/ancient,
									/mob/living/carbon/Xenomorph/Runner/ancient,
									/mob/living/carbon/Xenomorph/Runner/ancient,
									/mob/living/carbon/Xenomorph/Runner/ancient,
									/mob/living/carbon/Xenomorph/Runner/ancient,
									/mob/living/carbon/Xenomorph/Runner/ancient,
									/mob/living/carbon/Xenomorph/Runner/ancient,
									/mob/living/carbon/Xenomorph/Runner/ancient,
									/mob/living/carbon/Xenomorph/Runner/ancient,
									/mob/living/carbon/Xenomorph/Runner/ancient,
									/mob/living/carbon/Xenomorph/Ravager/ancient)

				if(7)//Spitter madness
					spawn_next_wave += 70//Slow down the next wave
					spawn_this_many =  45//A lot of them
					tempspawnxeno = list(/mob/living/carbon/Xenomorph/Sentinel/ancient,
										/mob/living/carbon/Xenomorph/Sentinel/ancient,
										/mob/living/carbon/Xenomorph/Sentinel/ancient,
										/mob/living/carbon/Xenomorph/Sentinel/ancient,
										/mob/living/carbon/Xenomorph/Sentinel/ancient,
										/mob/living/carbon/Xenomorph/Sentinel/ancient,
										/mob/living/carbon/Xenomorph/Spitter/ancient,
										/mob/living/carbon/Xenomorph/Spitter/ancient,
										/mob/living/carbon/Xenomorph/Spitter/ancient,
										/mob/living/carbon/Xenomorph/Spitter/ancient,
										/mob/living/carbon/Xenomorph/Praetorian/ancient)

				if(8)//Siege madness
					spawn_this_many = 10//A lot of them
					spawn_next_wave += 120//Slow down the next wave
					tempspawnxeno = list(/mob/living/carbon/Xenomorph/Boiler/ancient,
									/mob/living/carbon/Xenomorph/Boiler/ancient,
									/mob/living/carbon/Xenomorph/Crusher/ancient)
	var/path
	if(tempspawnxeno.len)//If temp list exists, use it
		for(var/i = 0; i < spawn_this_many; i++)
			if(xeno_spawn_loc.len)
				path = pick(tempspawnxeno)
				//xenos_spawned++ //DEBUG
				picked = pick(xeno_spawn_loc)
				var/mob/living/carbon/Xenomorph/X = new path(picked)
				X.away_timer = 300 //So ghosts can join instantly
				X.storedplasma = X.maxplasma
				X.flags_pass = 0 // Runners cannot pass trough tables

				//X.a_intent = "harm" This caused problems
				//if(istype(X,/mob/living/carbon/Xenomorph/Carrier))
				//	X:huggers_cur = 6 //Max out huggers
				break


	else //Else use the main list
		for(var/i = 0; i < spawn_this_many; i++)
			if(xeno_spawn_loc.len)
				path = pick(spawnxeno)
				//xenos_spawned++
				picked = pick(xeno_spawn_loc)
				var/mob/living/carbon/Xenomorph/X = new path(picked)
				X.away_timer = 300 //So ghosts can join instantly
				X.storedplasma = X.maxplasma
				X.flags_pass = 0 // Runners cannot pass trough tables

				//X.a_intent = "harm" This caused problems
				//if(istype(X,/mob/living/carbon/Xenomorph/Carrier))
				//	X:huggers_cur = 6 //Max out huggers

	//if(xenos_spawned)
	//	world << "Xenos_spawned: [xenos_spawned]"

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

/datum/game_mode/whiskey_outpost/proc/CleanXenos()//moves dead xenos to space
	var/xeno_count = 0
	for(var/mob/living/carbon/Xenomorph/X in dead_mob_list)
		if(X) //Prevent any runtime errors
			if(istype(X) && X.stat == DEAD && X.z != 2)
				X.loc = get_turf(locate(84,237,2)) //z.2
				xeno_count++

	if(xeno_count)
		world << "\red *___________________________________*"
		world << "\red <b>***Whiskey Outpost Controller***</b>"
		world << "\blue Moved [xeno_count] Xeno remains to trash."
		world << "\red *___________________________________*"


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
			round_stats << "Marines remaining: [count_humans()]\nRound time: [duration2text()][log_end]\nBig Winner:)"

	else if(finished == 2)
		feedback_set_details("round_end_result","Marines Won")
		world << "\red <FONT size = 4><B>The marines have succesfully defended the outpost. </B></FONT>"
		world << "<FONT size = 3><B>Well done, it is now time for real marines to take over your positions.</B></FONT>"

		if(round_stats) // Logging to data/logs/round_stats.log
			round_stats << "Marines remaining: [count_humans()]\nRound time: [duration2text()][log_end]"
	else
		feedback_set_details("round_end_result","no winners")
		world << "\red <FONT size = 4><B>NOBODY WON!</B></FONT>"
		world << "<FONT size = 3><B>How? Don't ask me...</B></FONT>"
		world << 'sound/misc/sadtrombone.ogg'

		if(round_stats) // Logging to data/logs/round_stats.log
			round_stats << "Marines remaining: [count_humans()]\nRound time: [duration2text()][log_end]"

	return 1

/datum/game_mode/proc/auto_declare_completion_whiskey_outpost()
	return

/datum/game_mode/whiskey_outpost/proc/place_drop(var/turf/T,var/OT)
	if(!istype(T)) return
	var/randpick
	var/list/randomitems = list()
	var/list/spawnitems = list()
	var/choosemax
	var/obj/structure/closet/crate/crate

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
								/obj/item/weapon/melee/defibrillator,
								/obj/item/weapon/storage/pill_bottle/peridaxon,
								/obj/item/weapon/storage/pill_bottle/imidazoline,
								/obj/item/weapon/storage/pill_bottle/alkysine)

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
								/obj/item/stack/medical/splint,
								/obj/item/stack/medical/splint,
								/obj/item/weapon/reagent_containers/hypospray/autoinjector/tricord,
								/obj/item/weapon/reagent_containers/hypospray/autoinjector/tricord,
								/obj/item/weapon/reagent_containers/hypospray/autoinjector/tricord,
								/obj/item/weapon/reagent_containers/hypospray/autoinjector/quickclot,
								/obj/item/weapon/reagent_containers/hypospray/autoinjector/dexP,
								/obj/item/weapon/reagent_containers/hypospray/autoinjector/Bicard,
								/obj/item/weapon/reagent_containers/hypospray/autoinjector/Kelo)


	else if (OT == "wep")
		crate = new /obj/structure/closet/crate/secure/weapon(T)
		randpick = rand(0,18)
		switch(randpick)
			if(0)//Specialist Crate
				spawnitems = list(/obj/item/weapon/flamethrower/full,
								/obj/item/weapon/flamethrower/full,
								/obj/item/weapon/tank/phoron/m240,
								/obj/item/weapon/tank/phoron/m240,
								/obj/item/weapon/tank/phoron/m240,
								/obj/item/weapon/tank/phoron/m240,
								/obj/item/weapon/tank/phoron/m240,
								/obj/item/ammo_magazine/sniper,
								/obj/item/ammo_magazine/sniper,
								/obj/item/ammo_magazine/sniper,
								/obj/item/ammo_magazine/sniper,
								/obj/item/ammo_magazine/sniper/incendiary,
								/obj/item/ammo_magazine/sniper/flak,
								/obj/item/sentry_ammo,
								/obj/item/sentry_ammo,
								/obj/item/smartgun_powerpack,
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


			if(1 to 2)//Random Attachments Crate
				choosemax = rand(20,30)
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
								/obj/item/attachable/burstfire_assembly)

			if(3)//Random Melee Crate
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

			if(4)//Random Explosives Items
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
									/obj/item/ammo_magazine/rocket,
									/obj/item/ammo_magazine/rocket,
									/obj/item/ammo_magazine/rocket/ap,
									/obj/item/ammo_magazine/rocket/wp,
									/obj/item/weapon/plastique)


			if(5 to 10)//Random USCM Care Package
				choosemax = rand(15,40)
				randomitems = list(/obj/item/weapon/gun/rifle/m41a,
									/obj/item/weapon/gun/rifle/m41a,
									/obj/item/weapon/gun/rifle/m41a,
									/obj/item/weapon/gun/rifle/m41a,
									/obj/item/ammo_magazine/rifle,
									/obj/item/ammo_magazine/rifle,
									/obj/item/ammo_magazine/rifle,
									/obj/item/ammo_magazine/rifle,
									/obj/item/ammo_magazine/rifle,
									/obj/item/ammo_magazine/rifle,
									/obj/item/ammo_magazine/rifle,
									/obj/item/ammo_magazine/rifle,
									/obj/item/ammo_magazine/rifle,
									/obj/item/weapon/gun/rifle/m41a/scoped,
									/obj/item/ammo_magazine/rifle/marksman,
									/obj/item/ammo_magazine/rifle/marksman,
									/obj/item/ammo_magazine/rifle/marksman,
									/obj/item/ammo_magazine/rifle/marksman,
									/obj/item/ammo_magazine/rifle/marksman,
									/obj/item/weapon/gun/rifle/lmg,
									/obj/item/ammo_magazine/rifle/lmg,
									/obj/item/ammo_magazine/rifle/lmg,
									/obj/item/ammo_magazine/rifle/lmg,
									/obj/item/ammo_magazine/rifle/lmg,
									/obj/item/ammo_magazine/rifle/lmg,
									/obj/item/weapon/gun/smg/m39,
									/obj/item/weapon/gun/smg/m39,
									/obj/item/ammo_magazine/smg/m39,
									/obj/item/ammo_magazine/smg/m39,
									/obj/item/ammo_magazine/smg/m39,
									/obj/item/ammo_magazine/smg/m39,
									/obj/item/ammo_magazine/smg/m39,
									/obj/item/ammo_magazine/shotgun,
									/obj/item/ammo_magazine/shotgun,
									/obj/item/ammo_magazine/shotgun,
									/obj/item/ammo_magazine/shotgun,
									/obj/item/ammo_magazine/shotgun,
									/obj/item/ammo_magazine/shotgun,
									/obj/item/weapon/gun/shotgun/pump,
									/obj/item/weapon/gun/shotgun/pump)

			if(11 to 14)//Random Black Market Care Package
				choosemax = rand(15,30)
				randomitems = list(/obj/item/weapon/gun/smg/ppsh,
									/obj/item/weapon/gun/smg/ppsh,
									/obj/item/ammo_magazine/smg/ppsh,
									/obj/item/ammo_magazine/smg/ppsh,
									/obj/item/ammo_magazine/smg/ppsh,
									/obj/item/ammo_magazine/smg/ppsh,
									/obj/item/weapon/gun/rifle/sniper/svd,
									/obj/item/weapon/gun/rifle/sniper/svd,
									/obj/item/ammo_magazine/rifle/sniper/svd,
									/obj/item/ammo_magazine/rifle/sniper/svd,
									/obj/item/ammo_magazine/rifle/sniper/svd,
									/obj/item/ammo_magazine/rifle/sniper/svd,
									/obj/item/ammo_magazine/rifle/sniper/svd,
									/obj/item/ammo_magazine/rifle/sniper/svd,
									/obj/item/weapon/gun/smg/skorpion,
									/obj/item/weapon/gun/smg/skorpion,
									/obj/item/ammo_magazine/smg/skorpion,
									/obj/item/ammo_magazine/smg/skorpion,
									/obj/item/ammo_magazine/smg/skorpion,
									/obj/item/ammo_magazine/smg/skorpion,
									/obj/item/weapon/gun/rifle/mar40,
									/obj/item/weapon/gun/rifle/mar40,
									/obj/item/ammo_magazine/rifle/mar40,
									/obj/item/ammo_magazine/rifle/mar40,
									/obj/item/ammo_magazine/rifle/mar40,
									/obj/item/ammo_magazine/rifle/mar40,
									/obj/item/weapon/gun/pistol/kt42,
									/obj/item/weapon/gun/pistol/kt42,
									/obj/item/ammo_magazine/pistol/automatic,
									/obj/item/ammo_magazine/pistol/automatic,
									/obj/item/ammo_magazine/pistol/automatic,
									/obj/item/ammo_magazine/pistol/automatic,
									/obj/item/ammo_magazine/pistol/automatic)

			if(15 to 17)//Random Prespace Care Package
				choosemax = rand(20,50)
				randomitems = list(/obj/item/weapon/gun/rifle/m16,
									/obj/item/weapon/gun/rifle/m16,
									/obj/item/weapon/gun/rifle/m16,
									/obj/item/weapon/gun/rifle/m16,
									/obj/item/weapon/gun/rifle/m16,
									/obj/item/weapon/gun/rifle/m16,
									/obj/item/weapon/gun/rifle/m16,
									/obj/item/weapon/gun/rifle/m16,
									/obj/item/weapon/gun/rifle/m16,
									/obj/item/ammo_magazine/rifle/m16,
									/obj/item/ammo_magazine/rifle/m16,
									/obj/item/ammo_magazine/rifle/m16,
									/obj/item/ammo_magazine/rifle/m16,
									/obj/item/ammo_magazine/rifle/m16,
									/obj/item/ammo_magazine/rifle/m16,
									/obj/item/ammo_magazine/rifle/m16,
									/obj/item/weapon/gun/smg/mp5,
									/obj/item/weapon/gun/smg/mp5,
									/obj/item/weapon/gun/smg/mp5,
									/obj/item/weapon/gun/smg/mp5,
									/obj/item/weapon/gun/smg/mp5,
									/obj/item/weapon/gun/smg/mp5,
									/obj/item/ammo_magazine/smg/mp5,
									/obj/item/ammo_magazine/smg/mp5,
									/obj/item/ammo_magazine/smg/mp5,
									/obj/item/ammo_magazine/smg/mp5,
									/obj/item/ammo_magazine/smg/mp5,
									/obj/item/weapon/gun/pistol/b92fs,
									/obj/item/weapon/gun/pistol/b92fs,
									/obj/item/weapon/gun/pistol/b92fs,
									/obj/item/weapon/gun/pistol/b92fs,
									/obj/item/weapon/gun/pistol/b92fs,
									/obj/item/weapon/gun/pistol/b92fs,
									/obj/item/ammo_magazine/pistol/b92fs,
									/obj/item/ammo_magazine/pistol/b92fs,
									/obj/item/ammo_magazine/pistol/b92fs,
									/obj/item/ammo_magazine/pistol/b92fs,
									/obj/item/ammo_magazine/pistol/b92fs,
									/obj/item/ammo_magazine/pistol/b92fs,
									/obj/item/ammo_magazine/pistol/b92fs)

			if(18)//Random Classic Drop
				choosemax = rand(10,20)
				randomitems = list(/obj/item/weapon/gun/rifle/m41aMK1,
									/obj/item/weapon/gun/rifle/m41aMK1,
									/obj/item/weapon/gun/rifle/m41aMK1,
									/obj/item/ammo_magazine/rifle/m41aMK1,
									/obj/item/ammo_magazine/rifle/m41aMK1,
									/obj/item/ammo_magazine/rifle/m41aMK1,
									/obj/item/weapon/gun/smg/p90,
									/obj/item/weapon/gun/smg/p90,
									/obj/item/weapon/gun/smg/p90,
									/obj/item/ammo_magazine/smg/p90,
									/obj/item/ammo_magazine/smg/p90,
									/obj/item/ammo_magazine/smg/p90,
									/obj/item/weapon/gun/shotgun/combat,
									/obj/item/weapon/gun/shotgun/combat,
									/obj/item/weapon/gun/shotgun/combat,
									/obj/item/ammo_magazine/shotgun/incendiary,
									/obj/item/ammo_magazine/shotgun/incendiary,
									/obj/item/ammo_magazine/shotgun/incendiary)

	else if (OT == "sup")
		randpick = rand(0,12)
		crate = new /obj/structure/closet/crate/secure/gear(T)
		switch(randpick)
			if(0 to 1)//Food
				choosemax = rand(10,40)
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

			if(2 to 4)//Marine Gear
				choosemax = rand(10,15)
				randomitems = list(/obj/item/clothing/head/helmet/marine,
								/obj/item/clothing/head/helmet/marine,
								/obj/item/clothing/head/helmet/marine,
								/obj/item/clothing/suit/storage/marine,
								/obj/item/clothing/suit/storage/marine,
								/obj/item/clothing/suit/storage/marine,
								/obj/item/clothing/head/helmet/marine/tech,
								/obj/item/clothing/head/helmet/marine/medic,
								/obj/item/clothing/under/marine/medic,
								/obj/item/clothing/under/marine/engineer,
								/obj/item/clothing/tie/storage/webbing,
								/obj/item/clothing/tie/storage/webbing,
								/obj/item/device/binoculars,
								/obj/item/device/squad_beacon/bomb)

			if(5 to 8)//Lights and shiet
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
				choosemax = rand(5,10)
				randomitems = list(/obj/item/weapon/facepaint/green,
									/obj/item/weapon/facepaint/brown,
									/obj/item/weapon/facepaint/black,
									/obj/item/weapon/facepaint/sniper,
									/obj/item/weapon/storage/box/bodybags,
									/obj/item/weapon/storage/fancy/cigarettes/lucky_strikes,
									/obj/item/weapon/storage/fancy/cigarettes/lucky_strikes,
									/obj/item/weapon/storage/fancy/cigarettes/dromedaryco,
									/obj/item/weapon/storage/fancy/cigarettes/dromedaryco,
									/obj/item/weapon/flame/lighter/random,
									/obj/item/weapon/flame/lighter/random,
									/obj/item/fluff/val_mcneil_1)

			if(10 to 12)//Materials
				choosemax = rand(3,8)
				randomitems = list(/obj/item/stack/rods,
								/obj/item/stack/sheet/glass,
								/obj/item/stack/sheet/metal,
								/obj/item/stack/sheet/metal,
								/obj/item/stack/sheet/plasteel,
								/obj/item/stack/sheet/wood,
								/obj/item/stack/sheet/wood)

	crate.storage_capacity = 60

	if(randomitems.len)
		for(var/i = 0; i < choosemax; i++)
			var/path = pick(randomitems)
			var/obj/I = new path(crate)
			if(OT == "sup")
				if(I && istype(I,/obj/item/stack/sheet/mineral/phoron) || istype(I,/obj/item/stack/rods) || istype(I,/obj/item/stack/sheet/glass) || istype(I,/obj/item/stack/sheet/metal) || istype(I,/obj/item/stack/sheet/plasteel) || istype(I,/obj/item/stack/sheet/wood))
					I:amount = rand(10,50)
				if(I && istype(I,/obj/machinery/floodlight))
					I.anchored = 0


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
	unacidable = 1
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
						X.loc = get_turf(locate(84,237,2)) //z.2
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

	ex_act(severity)
		return


////////////////////
//Art's Additions //
////////////////////

//Sandbags
/obj/structure/m_barricade/sandbags
	name = "Sandbag barricade"
	desc = "Trusted since 1914"
	icon = 'icons/turf/whiskeyoutpost.dmi'
	icon_state = "sandbag"
	density = 1
	anchored = 1.0
	layer = 5
	throwpass = 1	//You can throw objects over this, despite its density.
	climbable = 1
	flags_atom = ON_BORDER
	health = 250 //Pretty tough. Changes sprites at 300 and 150.
	unacidable = 0 //Who the fuck though unacidable barricades with 500 health was a good idea?

	Crossed(atom/movable/O)
		..()
		if(istype(O,/mob/living/carbon/Xenomorph/Crusher))
			var/mob/living/carbon/Xenomorph/M = O
			if(!M.stat)
				visible_message("<span class='danger'>[O] steamrolls through the [src]!</span>")
				destroy()

	update_icon()
		if(dir != NORTH)
			layer = 5
		icon_state = initial(icon_state)

	update_health()
		if(health < 0)
			destroy()
			return
		return

	attackby(obj/item/W as obj, mob/user as mob)
		if (!W) return

		//Otherwise, just hit it.
		if(force > 20)
			..()
			health -= W.force / 2
			update_health()
			return

		return

	destroy()
		src.visible_message("\red [src] collapses!")
		density = 0
		del(src)
		return




///////////////////////////////////////////////////////////////////////////////

//Stationary Machinegun
/obj/machinery/marine_turret/mg_turret
	name = "M56 Smartgun Nest"
	desc = "A M56 smartgun mounted upon a small post reinforced with sandbags to provide a small machinegun nest for all your defense purpose needs."
	on = 1
	burst_fire = 1
	fire_delay = 15
	rounds = 900
	rounds_max = 900
	icon = 'icons/turf/whiskeyoutpost.dmi'
	icon_state = "towergun"

	New()
		spark_system = new /datum/effect/effect/system/spark_spread
		spark_system.set_up(5, 0, src)
		spark_system.attach(src)
		var/obj/item/weapon/cell/super/H = new(src) //Better cells in these ones.
		cell = H
		spawn(2)
			stat = 0
			processing_objects.Add(src)
		ammo = ammo_list[ammo]

/obj/machinery/marine_turret/mg_turret/attack_hand(mob/user as mob) //Time to cut out alot of the sentry code
	src.add_fingerprint(user)

	operator = user

	var/dat = "<b>[src.name]:</b> <BR><BR>"
	dat += "--------------------<BR><BR>"
	dat += "<B>Current Rounds:</b> [rounds] / [rounds_max]<BR>"
	dat += "<B>Structural Integrity:</b> [round(health * 100 / health_max)] percent <BR>"
	dat += "--------------------<BR><BR>"
	dat += "<B><A href='?src=\ref[src];op=burst'>Burst Fire</a>:</B> "
	if(burst_fire)
		dat += "ON<BR>"
	else
		dat += "OFF<BR>	"
	dat += "--------------------<BR><BR>"
	if(manual_override)
		dat += "MANUAL OVERRIDE<BR>"
	dat += "<A href='?src=\ref[src];op=manual'>Manual Override Toggle</a><BR><BR>"
	dat += "--------------------<BR><BR>"
	dat += "<A href='?src=\ref[src];op=close'>{Close}</a><BR>"
	user.set_machine(src)
	user << browse(dat, "window=turret;size=300x400")
	onclose(user, "turret")
	return

/obj/machinery/marine_turret/mg_turret/Topic(href, href_list)
	if(usr.stat)
		return

	var/mob/living/carbon/human/user = usr
	if(!istype(user))
		return

	if(get_dist(src.loc, user.loc) > 1)
		return

	usr.set_machine(src)
	switch(href_list["op"])
		if("burst")
			if(alert(usr,"Do you want to turn on the burst fire function? It will be much less accurate.","Burst Fire", "Yes", "No") == "Yes")
				if(burst_fire)
					usr << "It's already firing in a burst."
				else
					burst_fire = 1
					fire_delay = 15
					visible_message("\icon[src] [src] emits a audiable hard click.")
					usr << "\blue You activate the burst fire mode."
			else
				if(!burst_fire)
					usr << "It's already firing single shots."
				else
					burst_fire = 0
					fire_delay = 5
					visible_message("\icon[src] [src] emits a audiable soft click.")
					usr << "\blue You deactivate the burst fire mode."
		if("manual")
			if(alert(usr,"Are you sure you want to man the machinegun?","MAN THE GUN", "Yes", "No") == "Yes")
				if(gunner)
					usr << "Someone's already controlling it."
				else
					if(user.turret_control)
						usr << "You're already controlling one!"
					else
						gunner = usr
						visible_message("\icon[src] [usr] mans the machinegun!")
						usr << "\blue You man the turret."
						user.turret_control = src
						manual_override = 1
			else
				if(user.turret_control)
					gunner = null
					visible_message("\icon[src] [usr] leaves the machinegun!")
					usr << "\blue you decided to let someone else have a go."
					user.turret_control = null
					manual_override = 0
				else
					user << "You're not controlling this turret."
			if(stat == 2)
				stat = 0 //Weird bug goin on here
	src.attack_hand(user)
	return

/obj/machinery/marine_turret/mg_turret/attackby(var/obj/item/O as obj, mob/user as mob)
	if(istype(O, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = O
		if(health < 0 || stat)
			user << "It's too damaged for that, its doomed."
			return

		if(health >= health_max)
			user << "It's already in perfect condition."
			return

		if(WT.remove_fuel(0, user))
			user.visible_message("\blue [user] begins repairing damage to the [src].","\blue You begin repairing the damage to the [src].")
			if(do_after(user,50))
				user.visible_message("\blue [user] repairs the damaged [src].","\blue Your repair the [src]'s damage.")
				update_health(-50)
				playsound(src.loc, 'sound/items/Welder2.ogg', 75, 1)
		return

/obj/machinery/marine_turret/mg_turret/get_target()
	return

// Xeno spawn fixes
/* Basically making it so that xenos have evolutions be spawnable which would help alot, so this is going to be a long list
YOU MADE ME DO THIS APOP WITH YOUR BIG LIST, I SWEAR.*/

/mob/living/carbon/Xenomorph/Runner

	mature
		upgrade_name = "Mature"
		upgrade = 1
		melee_damage_lower = 15
		melee_damage_upper = 25
		health = 120
		maxHealth = 120
		storedplasma = 0
		plasma_gain = 2
		maxplasma = 150
		jellyMax = 400
		caste_desc = "A fast, four-legged terror, but weak in sustained combat. It looks a little more dangerous."
		speed = -1.5
		armor_deflection = 5
		attack_delay = -4
		tacklemin = 2
		tacklemax = 4
		tackle_chance = 50

	elite
		upgrade_name = "Elite"
		upgrade = 2
		melee_damage_lower = 20
		melee_damage_upper = 30
		health = 150
		maxHealth = 150
		storedplasma = 0
		plasma_gain = 2
		maxplasma = 200
		jellyMax = 800
		caste_desc = "A fast, four-legged terror, but weak in sustained combat. It looks pretty strong."
		speed = -1.6
		armor_deflection = 10
		attack_delay = -4
		tacklemin = 3
		tacklemax = 5
		tackle_chance = 60

	ancient
		upgrade_name = "Ancient"
		upgrade = 3
		melee_damage_lower = 25
		melee_damage_upper = 35
		health = 140
		maxHealth = 140
		storedplasma = 0
		plasma_gain = 2
		maxplasma = 200
		caste_desc = "Not what you want to run into in a dark alley. It looks fucking deadly."
		speed = -2
		armor_deflection = 10
		attack_delay = -4
		tacklemin = 3
		tacklemax = 5
		tackle_chance = 70

/mob/living/carbon/Xenomorph/Drone

	mature
		upgrade_name = "Mature"
		upgrade = 1
		melee_damage_lower = 12
		melee_damage_upper = 16
		health = 120
		maxHealth = 120
		storedplasma = 0
		maxplasma = 800
		plasma_gain = 20
		jellyMax = 1000
		caste_desc = "The workhorse of the hive. It looks a little more dangerous."
		armor_deflection = 5
		tacklemin = 3
		tacklemax = 5
		tackle_chance = 60
		speed = -0.6

	elite
		upgrade_name = "Elite"
		upgrade = 2
		melee_damage_lower = 12
		melee_damage_upper = 16
		health = 150
		maxHealth = 150
		storedplasma = 0
		maxplasma = 900
		plasma_gain = 30
		jellyMax = 1500
		caste_desc = "The workhorse of the hive. It looks a little more dangerous."
		armor_deflection = 5
		tacklemin = 3
		tacklemax = 5
		tackle_chance = 60
		speed = -0.6

	ancient
		upgrade_name = "Ancient"
		upgrade = 3
		melee_damage_lower = 20
		melee_damage_upper = 30
		health = 200
		maxHealth = 200
		storedplasma = 0
		maxplasma = 1000
		plasma_gain = 50
		caste_desc = "A very mean architect."
		armor_deflection = 15
		tacklemin = 4
		tacklemax = 6
		tackle_chance = 80
		speed = -0.6

/mob/living/carbon/Xenomorph/Carrier

	mature
		upgrade_name = "Mature"
		upgrade = 1
		melee_damage_lower = 25
		melee_damage_upper = 35
		health = 200
		maxHealth = 200
		storedplasma = 0
		maxplasma = 300
		plasma_gain = 10
		jellyMax = 1600
		caste_desc = "A portable Love transport. It looks a little more dangerous."
		armor_deflection = 10
		tacklemin = 3
		tacklemax = 4
		tackle_chance = 60
		speed = -0.4

	elite
		upgrade_name = "Elite"
		upgrade = 2
		melee_damage_lower = 30
		melee_damage_upper = 40
		health = 220
		maxHealth = 220
		storedplasma = 0
		maxplasma = 350
		plasma_gain = 12
		jellyMax = 3200
		caste_desc = "A portable Love transport. It looks pretty strong."
		armor_deflection = 15
		tacklemin = 4
		tacklemax = 5
		tackle_chance = 70
		speed = -0.4

	ancient
		upgrade_name = "Ancient"
		upgrade = 3
		melee_damage_lower = 35
		melee_damage_upper = 45
		health = 250
		maxHealth = 250
		storedplasma = 0
		maxplasma = 400
		plasma_gain = 15
		caste_desc = "It's literally crawling with 10 huggers."
		armor_deflection = 20
		tacklemin = 5
		tacklemax = 6
		tackle_chance = 75
		speed = -0.3

/mob/living/carbon/Xenomorph/Hivelord

	mature
		upgrade_name = "Mature"
		upgrade = 1
		melee_damage_lower = 15
		melee_damage_upper = 20
		health = 220
		maxHealth = 220
		storedplasma = 0
		maxplasma = 900
		plasma_gain = 40
		jellyMax = 1600
		caste_desc = "A builder of REALLY BIG hives. It looks a little more dangerous."
		armor_deflection = 10
		tacklemin = 3
		tacklemax = 5
		tackle_chance = 60
		speed = 1.4

	elite
		upgrade_name = "Elite"
		upgrade = 2
		melee_damage_lower = 15
		melee_damage_upper = 20
		health = 250
		maxHealth = 250
		storedplasma = 0
		maxplasma = 1000
		plasma_gain = 50
		jellyMax = 3200
		caste_desc = "A builder of REALLY BIG hives. It looks pretty strong."
		armor_deflection = 15
		tacklemin = 4
		tacklemax = 6
		tackle_chance = 70
		speed = 1.3

	ancient
		upgrade_name = "Ancient"
		upgrade = 3
		melee_damage_lower = 20
		melee_damage_upper = 30
		health = 300
		maxHealth = 300
		storedplasma = 0
		maxplasma = 1200
		plasma_gain = 70
		caste_desc = "An extreme construction machine. It seems to be building walls..."
		armor_deflection = 20
		tacklemin = 5
		tacklemax = 7
		tackle_chance = 80
		speed = 1.2

/mob/living/carbon/Xenomorph/Praetorian

	mature
		upgrade_name = "Mature"
		upgrade = 1
		melee_damage_lower = 20
		melee_damage_upper = 30
		health = 220
		maxHealth = 220
		storedplasma = 0
		plasma_gain = 30
		maxplasma = 900
		jellyMax = 1600
		spit_delay = 15
		caste_desc = "A giant ranged monster. It looks a little more dangerous."
		armor_deflection = 50
		tacklemin = 5
		tacklemax = 8
		tackle_chance = 75
		speed = 1.6
		spit_type = 0

	elite
		upgrade_name = "Elite"
		upgrade = 2
		melee_damage_lower = 30
		melee_damage_upper = 35
		health = 250
		maxHealth = 250
		storedplasma = 0
		plasma_gain = 40
		maxplasma = 1000
		jellyMax = 3200
		spit_delay = 10
		caste_desc = "A giant ranged monster. It looks pretty strong."
		armor_deflection = 55
		tacklemin = 6
		tacklemax = 9
		tackle_chance = 80
		speed = 1.5
		spit_type = 0

	ancient
		upgrade_name = "Ancient"
		upgrade = 3
		melee_damage_lower = 40
		melee_damage_upper = 50
		health = 270
		maxHealth = 270
		storedplasma = 0
		plasma_gain = 50
		maxplasma = 1000
		spit_delay = 0
		caste_desc = "Its mouth looks like a minigun."
		armor_deflection = 60
		tacklemin = 7
		tacklemax = 10
		tackle_chance = 85
		speed = 1.3
		spit_type = 0

/mob/living/carbon/Xenomorph/Ravager

	mature
		upgrade_name = "Mature"
		upgrade = 1
		melee_damage_lower = 50
		melee_damage_upper = 70
		health = 220
		maxHealth = 220
		storedplasma = 0
		plasma_gain = 10
		maxplasma = 150
		jellyMax = 1600
		caste_desc = "A brutal, devastating front-line attacker. It looks a little more dangerous."
		speed = -1.2
		armor_deflection = 60
		tacklemin = 4
		tacklemax = 8
		tackle_chance = 85

	elite
		upgrade_name = "Elite"
		upgrade = 2
		melee_damage_lower = 60
		melee_damage_upper = 80
		health = 250
		maxHealth = 250
		storedplasma = 0
		plasma_gain = 15
		maxplasma = 200
		jellyMax = 3200
		caste_desc = "A brutal, devastating front-line attacker. It looks pretty strong."
		speed = -1.3
		armor_deflection = 65
		tacklemin = 5
		tacklemax = 9
		tackle_chance = 90

	ancient
		upgrade_name = "Ancient"
		upgrade = 3
		melee_damage_lower = 80
		melee_damage_upper = 100
		health = 350
		maxHealth = 350
		storedplasma = 0
		plasma_gain = 15
		maxplasma = 200
		caste_desc = "As I walk through the valley of the shadow of death."
		speed = -1.1
		armor_deflection = 70
		tacklemin = 6
		tacklemax = 10
		tackle_chance = 95

/mob/living/carbon/Xenomorph/Sentinel

	mature
		upgrade_name = "Mature"
		upgrade = 1
		melee_damage_lower = 15
		melee_damage_upper = 25
		health = 150
		maxHealth = 150
		storedplasma = 0
		plasma_gain = 12
		maxplasma = 400
		jellyMax = 400
		spit_delay = 25
		caste_desc = "A ranged combat alien. It looks a little more dangerous."
		armor_deflection = 20
		tacklemin = 3
		tacklemax = 5
		tackle_chance = 60
		speed = -0.6
		spit_type = 0

	elite
		upgrade_name = "Elite"
		upgrade = 2
		melee_damage_lower = 20
		melee_damage_upper = 30
		health = 175
		maxHealth = 175
		storedplasma = 0
		plasma_gain = 15
		maxplasma = 500
		jellyMax = 800
		spit_delay = 20
		caste_desc = "A ranged combat alien. It looks pretty strong."
		armor_deflection = 20
		tacklemin = 4
		tacklemax = 6
		tackle_chance = 60
		speed = -0.6
		spit_type = 0

	ancient
		upgrade_name = "Ancient"
		upgrade = 3
		melee_damage_lower = 25
		melee_damage_upper = 35
		health = 200
		maxHealth = 200
		storedplasma = 0
		plasma_gain = 20
		maxplasma = 600
		spit_delay = 10
		caste_desc = "Neurotoxin Factory, don't let it get you."
		armor_deflection = 20
		tacklemin = 4
		tacklemax = 6
		tackle_chance = 60
		speed = -0.6
		spit_type = 0

/mob/living/carbon/Xenomorph/Spitter

	mature
		upgrade_name = "Mature"
		upgrade = 1
		melee_damage_lower = 20
		melee_damage_upper = 30
		health = 180
		maxHealth = 180
		storedplasma = 0
		plasma_gain = 25
		maxplasma = 700
		jellyMax = 800
		spit_delay = 20
		caste_desc = "A ranged damage dealer. It looks a little more dangerous."
		armor_deflection = 20
		tacklemin = 3
		tacklemax = 5
		tackle_chance = 60
		speed = 0
		spit_type = 0

	elite
		upgrade_name = "Elite"
		upgrade = 2
		melee_damage_lower = 25
		melee_damage_upper = 35
		health = 200
		maxHealth = 200
		storedplasma = 0
		plasma_gain = 30
		maxplasma = 800
		jellyMax = 1600
		spit_delay = 15
		caste_desc = "A ranged damage dealer. It looks pretty strong."
		armor_deflection = 25
		tacklemin = 4
		tacklemax = 6
		tackle_chance = 70
		speed = -0.1
		spit_type = 0

	ancient
		upgrade_name = "Ancient"
		upgrade = 3
		melee_damage_lower = 35
		melee_damage_upper = 45
		health = 250
		maxHealth = 250
		storedplasma = 0
		plasma_gain = 50
		maxplasma = 900
		spit_delay = 5
		caste_desc = "A ranged destruction machine."
		armor_deflection = 35
		tacklemin = 5
		tacklemax = 7
		tackle_chance = 75
		speed = -0.2
		spit_type = 0

/mob/living/carbon/Xenomorph/Hunter

	mature
		upgrade_name = "Mature"
		upgrade = 1
		melee_damage_lower = 25
		melee_damage_upper = 35
		health = 170
		maxHealth = 170
		storedplasma = 0
		plasma_gain = 10
		maxplasma = 150
		jellyMax = 800
		caste_desc = "A fast, powerful front line combatant. It looks a little more dangerous."
		speed = -1.4
		armor_deflection = 25
		attack_delay = -2
		tacklemin = 3
		tacklemax = 5
		tackle_chance = 60

	elite
		upgrade_name = "Elite"
		upgrade = 2
		melee_damage_lower = 35
		melee_damage_upper = 50
		health = 200
		maxHealth = 200
		storedplasma = 0
		plasma_gain = 10
		maxplasma = 200
		jellyMax = 1600
		caste_desc = "A fast, powerful front line combatant. It looks pretty strong."
		speed = -1.5
		armor_deflection = 30
		attack_delay = -3
		tacklemin = 4
		tacklemax = 6
		tackle_chance = 65

	ancient
		upgrade_name = "Ancient"
		upgrade = 3
		melee_damage_lower = 50
		melee_damage_upper = 60
		health = 250
		maxHealth = 250
		storedplasma = 0
		plasma_gain = 20
		maxplasma = 300
		caste_desc = "A completly unmatched hunter. No, not even the Yautja can match you."
		speed = -1.5
		armor_deflection = 40
		attack_delay = -3
		tacklemin = 4
		tacklemax = 6
		tackle_chance = 65

/mob/living/carbon/Xenomorph/Queen

	mature
		upgrade_name = "Mature"
		upgrade = 1
		melee_damage_lower = 40
		melee_damage_upper = 55
		health = 320
		maxHealth = 320
		storedplasma = 0
		maxplasma = 800
		plasma_gain = 40
		jellyMax = 1600
		caste_desc = "The biggest and baddest xeno. The Queen controls the hive and plants eggs."
		armor_deflection = 65
		tacklemin = 5
		tacklemax = 7
		tackle_chance = 85
		speed = 0.9

	elite
		upgrade_name = "Elite"
		upgrade = 2
		melee_damage_lower = 50
		melee_damage_upper = 60
		health = 350
		maxHealth = 350
		storedplasma = 0
		maxplasma = 900
		plasma_gain = 50
		jellyMax = 3200
		caste_desc = "The biggest and baddest xeno. The Empress controls multiple hives and planets."
		armor_deflection = 70
		tacklemin = 6
		tacklemax = 9
		tackle_chance = 90
		speed = 0.8

	ancient
		upgrade_name = "Ancient"
		upgrade = 3
		melee_damage_lower = 70
		melee_damage_upper = 90
		health = 400
		maxHealth = 400
		storedplasma = 0
		maxplasma = 1000
		plasma_gain = 50
		caste_desc = "The most perfect Xeno form imaginable."
		armor_deflection = 80
		tacklemin = 7
		tacklemax = 10
		tackle_chance = 95
		speed = 0.7

/mob/living/carbon/Xenomorph/Crusher

	mature
		upgrade_name = "Mature"
		upgrade = 1
		melee_damage_lower = 20
		melee_damage_upper = 35
		tacklemin = 4
		tacklemax = 7
		tackle_chance = 95
		health = 250
		maxHealth = 250
		storedplasma = 0
		plasma_gain = 15
		maxplasma = 300
		jellyMax = 1600
		caste_desc = "A huge tanky xenomorph. It looks a little more dangerous."
		speed = 0.5
		armor_deflection = 70

	elite
		upgrade_name = "Elite"
		upgrade = 2
		melee_damage_lower = 35
		melee_damage_upper = 45
		tacklemin = 5
		tacklemax = 9
		tackle_chance = 95
		health = 300
		maxHealth = 300
		storedplasma = 0
		plasma_gain = 30
		maxplasma = 400
		jellyMax = 3200
		caste_desc = "A huge tanky xenomorph. It looks pretty strong."
		speed = 0.1
		armor_deflection = 75

	ancient
		upgrade_name = "Ancient"
		upgrade = 3
		melee_damage_lower = 35
		melee_damage_upper = 45
		tacklemin = 5
		tacklemax = 9
		tackle_chance = 95
		health = 350
		maxHealth = 350
		storedplasma = 0
		plasma_gain = 30
		maxplasma = 400
		caste_desc = "It always has the right of way."
		speed = -0.1
		armor_deflection = 85

/mob/living/carbon/Xenomorph/Boiler

	mature
		upgrade_name = "Mature"
		upgrade = 1
		melee_damage_lower = 20
		melee_damage_upper = 25
		health = 200
		maxHealth = 200
		storedplasma = 0
		plasma_gain = 35
		maxplasma = 900
		jellyMax = 1600
		spit_delay = 30
		caste_desc = "Some sort of abomination. It looks a little more dangerous."
		armor_deflection = 30
		tacklemin = 3
		tacklemax = 5
		tackle_chance = 65
		speed = 1.0

	elite
		upgrade_name = "Elite"
		upgrade = 2
		melee_damage_lower = 30
		melee_damage_upper = 35
		health = 220
		maxHealth = 220
		storedplasma = 0
		plasma_gain = 40
		maxplasma = 1000
		jellyMax = 3200
		spit_delay = 20
		caste_desc = "Some sort of abomination. It looks pretty strong."
		armor_deflection = 35
		tacklemin = 3
		tacklemax = 5
		tackle_chance = 70
		speed = 0.9

	ancient
		upgrade_name = "Ancient"
		upgrade = 3
		melee_damage_lower = 35
		melee_damage_upper = 45
		health = 250
		maxHealth = 250
		storedplasma = 0
		plasma_gain = 50
		maxplasma = 1000
		spit_delay = 10
		caste_desc = "A devestating piece of alien artillery."
		armor_deflection = 40
		tacklemin = 4
		tacklemax = 6
		tackle_chance = 80
		speed = 0.8