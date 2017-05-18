/datum/game_mode/whiskey_outpost
	name = "Whiskey Outpost"
	config_tag = "Whiskey Outpost"
	required_players 		= 1
	recommended_enemies 	= 0 //Leaving this relic code incase we want to do some extra things with it in the future.
	xeno_bypass_timer 		= 1
	role_instruction		= 1
	roles_for_mode = list(/datum/job/marine/standard/equipped, //Added Doctor and XO to the list.
					/datum/job/marine/medic/equipped,
					/datum/job/marine/engineer/equipped,
					/datum/job/marine/specialist/equipped,
					/datum/job/marine/leader/equipped,
					/datum/job/civilian/doctor,
					/datum/job/command/executive,
					/datum/job/logistics/tech/maint,
					/datum/job/command/police
					)

	flags_round_type	= MODE_NO_LATEJOIN

	//var/mob/living/carbon/human/Commander //If there is no Commander, marines wont get any supplies
	//No longer relevant to the game mode, since supply drops are getting changed.
	var/checkwin_counter = 0
	var/finished = 0
	var/has_started_timer = 10 //This is a simple timer so we don't accidently check win conditions right in post-game

	var/spawn_next_wave = 200 //Spawn first batch at ~15 minutes //200
	var/xeno_wave = 1 //Which wave is it
	var/spawn_xeno_num = 20 //How many to spawn per wave //First wave is big, cus runners.

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


	var/next_supply = 1 //At which wave does the next supply drop come?

	var/ticks_passed = 0
	var/lobby_time = 0 //Lobby time does not count for marine 1h win condition
	var/wave_times_delayed = 0 //How many time was the current wave delayed due to pop limit?
	//Who to spawn and how often which caste spawns
		//The more entires with same path, the more chances there are to pick it
			//This will get populated with spawn_xenos() proc
	var/list/spawnxeno = list()

	var/map_locale = 0 // 0 is Jungle Whiskey Outpost, 1 is Big Red Whiskey Outpost, 2 is Ice Colony Whiskey Outpost, 3 is space

/datum/game_mode/whiskey_outpost/announce()
	return 1

/datum/game_mode/whiskey_outpost/send_intercept()
	return 1

/datum/game_mode/whiskey_outpost/pre_setup()
	var/obj/effect/landmark/L

	for(L in world)
		switch(L.name)
			if("whiskey_outpost_marine")
				marine_spawns += L.loc
			if("whiskey_outpost_xeno_1")
				xeno_spawns_1 += L.loc
				xeno_spawns_all += L.loc
			if("whiskey_outpost_xeno_2")
				xeno_spawns_2 += L.loc
				xeno_spawns_all += L.loc
			if("whiskey_outpost_xeno_3")
				xeno_spawns_3 += L.loc
				xeno_spawns_all += L.loc
			if("whiskey_outpost_xeno_4")
				xeno_spawns_4 += L.loc
				xeno_spawns_all += L.loc
			if("whiskey_outpost_supply")
				supply_spawns += L.loc

		// Lets set up what colony we're at.
			if("whiskey_outpost_big_red")
				map_locale = 1
			if("whiskey_outpost_ice_colony")
				map_locale = 2
			if("whiskey_outpost_space_station")
				map_locale = 3
	return 1

/datum/game_mode/whiskey_outpost/post_setup()
	set waitfor = 0
	lobby_time = world.time
	var/mob/M

	if(config) config.remove_gun_restrictions = 1

	for(M in mob_list)
		if(M.client && istype(M,/mob/living/carbon/human))
			players += M
			spawn_player(M)

	sleep(10)
	world << "<span class='round_header'>The current game mode is - WHISKEY OUTPOST!</span>"
	world << "<span class='round_body'>Marines have to defend the outpost on this hostile planet</span>"
	world << "<span class='round_body'>They need to hold it for one hour until main forces arrive</span>"
	world << sound('sound/effects/siren.ogg')

	sleep(50)
	switch(map_locale) //Switching it up.
		if(0)
			command_announcement.Announce("This is Commander Anderson speaking from the USS Alistoun. We've heard the [MAIN_SHIP_NAME]'s distress beacon, but we need you to hold Whiskey Outpost for an hour before the marine force is equipped and ready. We're sending UD-22 Navajo gunships to assist in your defense.", "USS Alistoun")

/datum/game_mode/whiskey_outpost/proc/spawn_player(var/mob/M)
	set waitfor = 0 //Doing this before hand.
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
		switch(H.mind.assigned_role)
			if("Doctor") //Only get rid of some of the stuff
				for(var/I in H.contents)
					if(istype(I,/obj/item/device/pda/medical))
						del(I)
					if(istype(I,/obj/item/clothing/shoes/laceup))
						del(I)
			if("Executive Officer") //Wipe their stuff clean. Reequip them later
				for(var/I in H.contents)
					del(I)
			if("Military Police")
				for(var/I in H.contents)
					del(I)
			if("Maintenance Tech")
				for(var/I in H.contents)
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
	var/rand_wep = rand(0,10) //Made spawns for everyone, now we can also have weighted things too!
	var/custom_message = 0 // This is if the role has a special message.
	switch(H.mind.assigned_role)
		if("Executive Officer")
			custom_message = 1
			H.equip_to_slot_or_del(new /obj/item/device/radio/headset/mcom(H), WEAR_L_EAR)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/marine/satchel(H), WEAR_BACK)
			H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/officer/command(H), WEAR_BODY)
			H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/MP/RO(H), WEAR_JACKET)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marinechief/commander(H), WEAR_FEET)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/cmberet/tan(H), WEAR_HEAD)
			H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/techofficer/commander(H), WEAR_HANDS)
			H.equip_to_slot_or_del(new /obj/item/weapon/book/manual/whiskey_outpost_map(H), WEAR_R_HAND)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/marine/satchel(H), WEAR_BACK)


			H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/heavy(H), WEAR_WAIST)
			H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/heavy(H), WEAR_IN_BACK)
			H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/heavy(H), WEAR_IN_BACK)
			H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/heavy(H), WEAR_IN_BACK)

			var/obj/item/weapon/card/id/gold/W = new(H)
			W.name = "[M.real_name]'s ID Card (Ground Commander)"
			W.access = get_all_accesses()
			W.assignment = "Ground Commander"
			W.paygrade = "O3"
			W.registered_name = M.real_name
			H.equip_to_slot_or_del(W, WEAR_ID)

			sleep(40)
			if(H)
				H << "________________________"
				H << "<span class='boldnotice'>You are the Ground Commander!</span>"
				H << "Coordinate your team and prepare defenses."
				H << "Stay alive!"
				H << "Hold the outpost for one hour until the main force arrives!"
				H << "________________________"
			sleep(240) //So they can see it
			if(H)
				H << "<span class='boldnotice'>THIS IS A CRITICAL ROLE</span>"
				H << "<span class='notice'> If you kill yourself or leave the server without notifying admins, you will be banned.</span>"
		//SQUADS
		//~Art 08JAN17 Adding specialized and better loadouts to the fucken jobs
		//Complaints of lack of ammo (three mags are not enough).

		//HONOR GUARD
		if("Military Police")
			custom_message = 1
			H.equip_to_slot_or_del(new /obj/item/device/radio/headset/mcom(H), WEAR_L_EAR)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/marine/satchel(H), WEAR_BACK)
			H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/officer/logistics(H), WEAR_BODY)
			H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/leader(H), WEAR_JACKET)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(H), WEAR_FEET)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/beret/marine/logisticsofficer(H), WEAR_HEAD)
			H.equip_to_slot_or_del(new /obj/item/clothing/gloves/yellow(H), WEAR_HANDS)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/marine/satchel(H), WEAR_BACK) // Make sure we get a backpack now.

			switch(rand_wep) //Give them some additional protection for the ground commander.
				if(0 to 5) //Give them the Marksman rifle, longer range.
					H.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/m41a/scoped(H), WEAR_R_HAND)
					var/obj/item/weapon/storage/belt/marine/B = new/obj/item/weapon/storage/belt/marine(H)
					new /obj/item/ammo_magazine/rifle/marksman(B)
					new /obj/item/ammo_magazine/rifle/marksman(B)
					new /obj/item/ammo_magazine/rifle/marksman(B)
					new /obj/item/ammo_magazine/rifle/marksman(B)
					new /obj/item/ammo_magazine/rifle/marksman(B)
					new /obj/item/ammo_magazine/rifle/marksman(B)
					H.equip_to_slot_or_del(B, WEAR_WAIST)

					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/marksman(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/marksman(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/marksman(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/marksman(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/marksman(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/marksman(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid/regular(H), WEAR_IN_BACK)
				if(6 to 10) //CQC Specialist
					H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/gun/m44/full(H), WEAR_WAIST)
					H.equip_to_slot_or_del(new /obj/item/weapon/gun/shotgun/combat(H), WEAR_R_HAND)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/shotgun(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/shotgun(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/shotgun(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/shotgun(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/shotgun/buckshot(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/shotgun/buckshot(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid/regular(H), WEAR_IN_BACK)

			var/obj/item/weapon/card/id/silver/W = new(H)
			W.name = "[M.real_name]'s ID Card (Honor Guard)"
			W.access = get_all_accesses()
			W.assignment = "Honor Guard"
			W.paygrade = "E9"
			W.registered_name = M.real_name
			H.equip_to_slot_or_del(W, WEAR_ID)

			sleep(40)
			if(H)
				H << "________________________"
				H << "<span class='boldnotice'>You are part of the Honor Guard!</span>"
				H << "Protect the outpost itself! Make sure the Ground Commander lives!"
				H << "Stay alive!"
				H << "This role does not know engineering or medical tasks(outside of first aid)!"
				H << "Aid your commander, you can use overwatch consoles!"
				H << "________________________"


		if("Maintenance Tech")
			custom_message = 1
			H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/engineer(H), WEAR_BODY)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/tech(H), WEAR_HEAD)
			H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine(H), WEAR_JACKET)
			H.equip_to_slot_or_del(new /obj/item/device/radio/headset/mcom(H), WEAR_L_EAR)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/marine/tech(H), WEAR_BACK)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/utility/full(H), WEAR_WAIST)
			H.equip_to_slot_or_del(new /obj/item/clothing/glasses/welding(H), WEAR_EYES)
			H.equip_to_slot_or_del(new /obj/item/clothing/gloves/yellow(H), WEAR_HANDS)

			//Give this man a bone.
			var/obj/item/stack/sheet/metal/MET = new /obj/item/stack/sheet/metal(H)
			MET.amount = 50
			var/obj/item/stack/sheet/plasteel/PLAS = new /obj/item/stack/sheet/plasteel(H)
			PLAS.amount = 50
			var/obj/item/stack/sheet/plasteel/PLAS2 = new /obj/item/stack/sheet/plasteel(H)
			PLAS.amount = 50
			var/obj/item/stack/sheet/plasteel/PLAS3 = new /obj/item/stack/sheet/plasteel(H)
			PLAS.amount = 50
			var/obj/item/stack/sheet/metal/MET2 = new /obj/item/stack/sheet/metal(H)
			MET.amount = 50
			var/obj/item/stack/sheet/metal/MET3 = new /obj/item/stack/sheet/metal(H)
			MET.amount = 50
			H.equip_to_slot_or_del(PLAS, WEAR_IN_BACK)
			H.equip_to_slot_or_del(PLAS2, WEAR_IN_BACK)
			H.equip_to_slot_or_del(PLAS3, WEAR_IN_BACK)
			H.equip_to_slot_or_del(MET, WEAR_IN_BACK)
			H.equip_to_slot_or_del(MET2, WEAR_IN_BACK)
			H.equip_to_slot_or_del(MET3, WEAR_IN_BACK)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/m94(H), WEAR_IN_BACK)

			H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/m94(H), WEAR_R_HAND)

			var/obj/item/weapon/card/id/W = new(H)
			W.name = "[M.real_name]'s ID Card (Outpost Engineer)"
			W.access = get_all_accesses()
			W.assignment = "Outpost Engineer"
			W.paygrade = "E6E"
			W.registered_name = M.real_name
			H.equip_to_slot_or_del(W, WEAR_ID)

			sleep(40)
			if(H)
				H << "________________________"
				H << "<span class='boldnotice'>You are a Outpost Engineer!</span>"
				H << "Fortify the frontlines with the other combat engineers and make sure the outpost functions!"
				H << "Stay alive!"
				H << "This role does knows how to do engineering tasks but does not know medical!"
				H << "Aid your comrades!"
				H << "________________________"

		//SQUAD LEADER
		if("Squad Leader")
			H.equip_to_slot_or_del(new /obj/item/clothing/under/marine(H), WEAR_BODY)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/leader(H), WEAR_HEAD)
			H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/leader(H), WEAR_JACKET)

			//SPESHUL EQUIPMENT
			//Give them the Mk1 since they're getting ammo drop supplies and will need the increased ammo.
			H.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/m41aMK1(H), WEAR_R_HAND)

			//Laser Designator, Supply beacons, and the map in backpack
			H.equip_to_slot_or_del(new /obj/item/device/whiskey_supply_beacon(H), WEAR_IN_BACK)
			H.equip_to_slot_or_del(new /obj/item/device/whiskey_supply_beacon(H), WEAR_IN_BACK)
			H.equip_to_slot_or_del(new /obj/item/device/whiskey_supply_beacon(H), WEAR_IN_BACK)
			H.equip_to_slot_or_del(new /obj/item/device/whiskey_supply_beacon(H), WEAR_IN_BACK)
			H.equip_to_slot_or_del(new /obj/item/device/whiskey_supply_beacon(H), WEAR_IN_BACK)
			H.equip_to_slot_or_del(new /obj/item/weapon/book/manual/whiskey_outpost_map(H), WEAR_IN_BACK)
			H.equip_to_slot_or_del(new /obj/item/device/laz_designator(H), WEAR_IN_BACK)

			//Belt and grenades
			var/obj/item/weapon/storage/belt/marine/B = new/obj/item/weapon/storage/belt/marine(H)
			new /obj/item/ammo_magazine/rifle/m41aMK1(B)
			new /obj/item/ammo_magazine/rifle/m41aMK1(B)
			new /obj/item/ammo_magazine/rifle/m41aMK1(B)
			new /obj/item/ammo_magazine/rifle/m41aMK1(B)
			new /obj/item/weapon/grenade/incendiary(B)
			new /obj/item/weapon/grenade/incendiary(B)
			H.equip_to_slot_or_del(B, WEAR_WAIST)

		//DOCTORS
		if("Doctor") //Then, the doctors
			custom_message = 1
			H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat(H), WEAR_JACKET)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(H), WEAR_FEET)
			H.equip_to_slot_or_del(new /obj/item/device/flashlight/pen(H), WEAR_J_STORE)
			H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_med(H), WEAR_L_EAR)

		//HUD GLASSES (NEEDED)
			H.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/health(H), WEAR_EYES) // added for doctors to see.

		//Combat Lifesaver belt
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/medical/combatLifesaver(H), WEAR_WAIST)

		//Advanced Meds
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/pill_bottle/peridaxon(H), WEAR_L_STORE)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/pill_bottle/peridaxon(H), WEAR_R_STORE)

		//Give them some information
			sleep(40)
			if(H)
				H << "________________________"
				H << "<span class='boldnotice'>You are the WO Doctor!</span>"
				H << "Gear up, prepare the medbay and keep your temmates alive."
				H << "Motion trackers have detected movement from local creatures, and they are heading towards the outpost!"
				H << "Hold the outpost for one hour until the main force arrives!"
				H << "________________________"
			sleep(240) //So they can see it
			if(H)
				H << "<span class='boldnotice'>THIS IS A CRITICAL ROLE</span>"
				H << "<span class='notice'>If you kill yourself or leave the server without notifying admins, you will be banned.</span>"


		//SQUAD ENGINEER
		if("Squad Engineer")
			H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/engineer(H), WEAR_BODY)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/tech(H), WEAR_HEAD)
			H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine(H), WEAR_JACKET)

			//SPESHUL EQUIPMENT
			//Metal, webbing, grenades in backpack
			var/obj/item/stack/sheet/metal/MET = new /obj/item/stack/sheet/metal(H)
			MET.amount = 50
			H.equip_to_slot_or_del(MET, WEAR_IN_BACK)
			var/obj/item/stack/sheet/plasteel/PLAS = new /obj/item/stack/sheet/plasteel(H)
			PLAS.amount = 50
			H.equip_to_slot_or_del(PLAS, WEAR_IN_BACK)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/m94(H), WEAR_IN_BACK)
			H.equip_to_slot_or_del(new /obj/item/weapon/grenade/incendiary(H), WEAR_IN_BACK)

			//Utility Belt
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/utility/full(H), WEAR_WAIST)

			//Welding Glasses
			H.equip_to_slot_or_del(new /obj/item/clothing/glasses/welding(H), WEAR_EYES)

			switch(rand_wep) // Armaments, base sorta on lore. But also on what logical loadouts people take.
				if(0 to 5) //SMG
					H.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/m39(H), WEAR_R_HAND)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m39(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m39(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m39(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m39(H), WEAR_IN_BACK)
				if(6 to 7) //Shotgun
					H.equip_to_slot_or_del(new /obj/item/weapon/gun/shotgun/pump(H), WEAR_R_HAND)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/shotgun(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/shotgun(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/shotgun/buckshot(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/shotgun/buckshot(H), WEAR_IN_BACK)
				if(8 to 10) //M41A
					H.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/m41a(H), WEAR_R_HAND)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle(H), WEAR_IN_BACK)

		//SQUAD MEDIC
		if("Squad Medic")
			H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/medic(H), WEAR_BODY)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/medic(H), WEAR_HEAD)
			H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine(H), WEAR_JACKET)

			//SPESHUL EQUIPMENT
			//Defibs, first aid, adv aid in backpack
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid/regular(H), WEAR_IN_BACK)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid/adv(H), WEAR_IN_BACK)
			H.equip_to_slot_or_del(new /obj/item/weapon/melee/defibrillator(H), WEAR_IN_BACK)

			//Medical encryption key
			H.equip_to_slot_or_del(new /obj/item/device/encryptionkey/headset_med(H), WEAR_L_HAND)

			//Combat Lifesaver belt
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/medical/combatLifesaver(H), WEAR_WAIST)

			//Med Hud
			H.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/health(H), WEAR_EYES)

			switch(rand_wep) // Armaments, base sorta on lore. But also on what logical loadouts people take.
				if(0 to 5) //SMG
					H.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/m39(H), WEAR_R_HAND)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m39(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m39(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m39(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m39(H), WEAR_IN_BACK)
				if(6 to 10) //M41A
					H.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/m41a(H), WEAR_R_HAND)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle(H), WEAR_IN_BACK)

		//SQUAD SPECIALIST
		if("Squad Specialist")

			H.equip_to_slot_or_del(new /obj/item/clothing/under/marine(H), WEAR_BODY)

			//SPESHUL EQUIPMENT
			//Webbing
			H.equip_to_slot_or_del(new /obj/item/clothing/tie/storage/webbing(H), WEAR_IN_BACK)

			//Backup SMG Weapon
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/gun/m39/full(H), WEAR_WAIST)
			H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m39(H), WEAR_IN_BACK)
			H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m39(H), WEAR_IN_BACK)
			H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m39(H), WEAR_IN_BACK)

			switch(rand_wep) //Scaled based on player feedback (scaled again, found out people want survivability this time.
				if(0 to 3)//Smartgun
					H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/m56_system(H), WEAR_R_HAND)
					H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine(H), WEAR_HEAD)

				if(4 to 6)//Sniper
					H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/m42c_system(H), WEAR_R_HAND)

				if(7)//SADAR
					H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/rocket_system(H), WEAR_R_HAND)

					H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine(H), WEAR_HEAD)
					H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine(H), WEAR_JACKET)

				if(8)//Grenade Launcher
					H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/grenade_system(H), WEAR_R_HAND)
					H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine(H), WEAR_HEAD)
					H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine(H), WEAR_JACKET)

				if(9 to 10)//B18
					H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/heavy_armor(H), WEAR_R_HAND)
					H.equip_to_slot_or_del(new /obj/item/weapon/large_holster/machete/full(H), WEAR_L_HAND)

		//SQUAD MARINE
		else
			H.equip_to_slot_or_del(new /obj/item/clothing/under/marine(H), WEAR_BODY)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine(H), WEAR_HEAD)
			H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine(H), WEAR_JACKET)

			switch(rand_wep) // Armaments, base sorta on lore. But also on what logical loadouts people take.
				if(0 to 5) //M41A
					H.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/m41a(H), WEAR_R_HAND)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle(H), WEAR_IN_BACK)

					var/obj/item/weapon/storage/belt/marine/C = new/obj/item/weapon/storage/belt/marine(H)
					new /obj/item/ammo_magazine/rifle(C)
					new /obj/item/ammo_magazine/rifle(C)
					new /obj/item/ammo_magazine/rifle(C)
					new /obj/item/ammo_magazine/rifle(C)
					new /obj/item/ammo_magazine/rifle(C)
					new /obj/item/ammo_magazine/rifle(C)
					H.equip_to_slot_or_del(C, WEAR_WAIST)

				if(6) //Grenadier
					H.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/m41a(H), WEAR_R_HAND)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle(H), WEAR_IN_BACK)

					var/obj/item/weapon/storage/belt/marine/D = new/obj/item/weapon/storage/belt/marine(H)
					new /obj/item/weapon/grenade/explosive(D)
					new /obj/item/weapon/grenade/explosive(D)
					new /obj/item/weapon/grenade/explosive(D)
					new /obj/item/weapon/grenade/explosive(D)
					new /obj/item/weapon/grenade/incendiary(D)
					new /obj/item/weapon/grenade/incendiary(D)
					H.equip_to_slot_or_del(D, WEAR_WAIST)

				if(7 to 10) //CQC
					H.equip_to_slot_or_del(new /obj/item/weapon/gun/shotgun/pump(H), WEAR_R_HAND)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/shotgun(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/shotgun(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/shotgun(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/shotgun(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/shotgun/buckshot(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/shotgun/buckshot(H), WEAR_IN_BACK)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/shotgun/buckshot(H), WEAR_IN_BACK)

					//Grenades for this standard, which might be a horrible idea, but we'll find out.
					var/obj/item/weapon/storage/belt/marine/D = new/obj/item/weapon/storage/belt/marine(H)
					new /obj/item/weapon/storage/box/m94(D)
					new /obj/item/weapon/storage/box/m94(D)
					new /obj/item/weapon/storage/box/m94(D)
					H.equip_to_slot_or_del(D, WEAR_WAIST)

		//Every Squad Starts with this:
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/m94(H), WEAR_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/weapon/combat_knife(H), WEAR_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(H), WEAR_FEET)

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

		//Give them some information
	sleep(40)
	if(H && !custom_message)
		H << "________________________"
		H << "<span class='boldnotice'>You are the [H.mind.assigned_role]!</span>"
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
		if(count_xenos() < 50)//Checks braindead too, so we don't overpopulate! Also make sure its less than twice us in the world, so we advance waves/get more xenos the more marines survive.
			world << "<br><br>"
			world << "<br><br>"
			world << "<span class='notice'>*___________________________________*</span>" //We also then ram it down later anyways, should cut down on the lag a bit.
			world << "<span class='boldnotice'>***Whiskey Outpost Controller***</span>"
			world << "\blue <b>Wave:</b> [xeno_wave][wave_times_delayed?"|\red Times delayed: [wave_times_delayed]":""]"
			world << "<span class='notice'>*___________________________________*</span>"
			world << "<br><br>"
			world << "<br><br>"

			if(xeno_wave != (1 || 8 || 9)) // Make sure to not xeno roar over our story sounds.
				world << sound(pick('sound/voice/alien_distantroar_3.ogg','sound/voice/xenos_roaring.ogg', 'sound/voice/4_xeno_roars.ogg'))

			wave_ticks_passed = 0
			if(xeno_wave == next_xeno_cleanup)
				next_xeno_cleanup += 3 //Scedule next cleanup
				CleanXenos()

			if(spawn_next_wave > 40)
				spawn_next_wave -= 5
			spawn_xenos(spawn_xeno_num)

			if(wave_times_delayed)
				wave_times_delayed = 0

			switch(xeno_wave)
				if(1)
					command_announcement.Announce("This is the USS Alistoun, gunships are reporting that the first group of hostiles are now on your position.", "USS Alistoun")
				if(8)
					command_announcement.Announce("This is the USS Alistoun, we're sending strikecraft to destroy the inbound xeno force on the main road. Hold tight.", "USS Alistoun")
				if(9)
					world << sound('sound/voice/alien_queen_command.ogg')
					command_announcement.Announce("It appears that vanguard of the alien force is still approaching, hunker down marines we're almost there.", "USS Alistoun")
				if(12)
					command_announcement.Announce("This is the USS Alistoun, strikecraft are picking up large signatures inbound, we'll see what we can do to delay them.", "USS Alistoun")
				if(14)
					command_announcement.Announce("This is the USS Alistoun, dropships are inbound. Hold on for a bit longer!", "USS Alistoun")


			//SUPPLY SPAWNER
			if(xeno_wave == next_supply)
				for(var/turf/S in supply_spawns)

					var/turf/picked_sup = pick(supply_spawns) //ONLY ONE TYPE OF DROP NOW!
					place_drop(picked_sup,"sup") //This is just extra guns, medical supplies, junk, and some rare-r ammo.
					supply_spawns -= picked_sup
					supply_spawns += list(picked_sup)

					break //Place only 3

				switch(xeno_wave)
					if(1 to 11)
						next_supply++
					if(12 to 18)
						next_supply += 2
					else
						next_supply += 3

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

	var/humans_alive = count_humans()

	if(humans_alive > 50)
		humans_alive = 50

	if(humans_alive < 5)
		humans_alive = 5

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
		if(1)//Mostly weak runners
			spawnxeno += list(/mob/living/carbon/Xenomorph/Runner)
			spawn_xeno_num = (humans_alive * 0.5) //Reset
			spawn_next_wave = 90
			world << sound('sound/effects/siren.ogg') //Mark the first wave


		if(2)//Sentinels and drones are more common
			spawnxeno += list(/mob/living/carbon/Xenomorph/Runner,
						/mob/living/carbon/Xenomorph/Runner,
						/mob/living/carbon/Xenomorph/Runner,
						/mob/living/carbon/Xenomorph/Runner,
						/mob/living/carbon/Xenomorph/Runner,
						/mob/living/carbon/Xenomorph/Sentinel,
						/mob/living/carbon/Xenomorph/Sentinel)

			spawnxeno -= list(/mob/living/carbon/Xenomorph/Runner)


		if(3)//Tier II versions added, but rare
			spawnxeno += list(/mob/living/carbon/Xenomorph/Hunter,
						/mob/living/carbon/Xenomorph/Spitter)

			spawnxeno -= list(/mob/living/carbon/Xenomorph/Runner,
						/mob/living/carbon/Xenomorph/Runner,
						/mob/living/carbon/Xenomorph/Runner)

		if(4)//Tier II more common
			spawnxeno += list(/mob/living/carbon/Xenomorph/Hunter,
						/mob/living/carbon/Xenomorph/Drone,
						/mob/living/carbon/Xenomorph/Spitter)

		if(5)//Reset the spawns	so we don't drown in xenos again.
			spawn_xeno_num = (count_humans() * 0.5) //Reset

		if(6)//Tier II more common
			spawnxeno += list(/mob/living/carbon/Xenomorph/Hunter,
						/mob/living/carbon/Xenomorph/Spitter)

		if(7)
			spawn_xeno_num = 0

		if(8)
			spawn_next_wave += 220 //Slow down now, strong castes introduced next wave
			spawn_xeno_num = count_humans()

			spawnxeno -= list(/mob/living/carbon/Xenomorph/Runner,
						/mob/living/carbon/Xenomorph/Runner,
						/mob/living/carbon/Xenomorph/Sentinel)

		if(9)//Ravager and Praetorian Added, Tier II more common, Tier I less common
			spawn_next_wave -= 220 //Speed it up again. After the period of grace.
			spawnxeno += list(/mob/living/carbon/Xenomorph/Hunter/mature,
						/mob/living/carbon/Xenomorph/Hunter/mature,
						/mob/living/carbon/Xenomorph/Spitter/mature,
						/mob/living/carbon/Xenomorph/Runner/mature,
						/mob/living/carbon/Xenomorph/Runner/mature,
						/mob/living/carbon/Xenomorph/Drone/mature)

			spawnxeno -= list(/mob/living/carbon/Xenomorph/Sentinel)

		if(10)
			spawn_next_wave += 110
			spawn_xeno_num = count_humans()

		if(11)
			spawnxeno += list(/mob/living/carbon/Xenomorph/Hunter/elite,
						/mob/living/carbon/Xenomorph/Hunter/elite,
						/mob/living/carbon/Xenomorph/Spitter/elite,
						/mob/living/carbon/Xenomorph/Runner/elite,
						/mob/living/carbon/Xenomorph/Runner/elite,
						/mob/living/carbon/Xenomorph/Drone/elite)

			spawnxeno -= list(/mob/living/carbon/Xenomorph/Hunter/mature,
						/mob/living/carbon/Xenomorph/Hunter/mature,
						/mob/living/carbon/Xenomorph/Spitter/mature,
						/mob/living/carbon/Xenomorph/Runner/mature,
						/mob/living/carbon/Xenomorph/Runner/mature,
						/mob/living/carbon/Xenomorph/Drone/mature)

		if(12)//Boiler and Crusher Added, Ravager and Praetorian more common. Tier I less common
			spawn_next_wave = count_humans() //rip and tear.
			spawnxeno += list(/mob/living/carbon/Xenomorph/Ravager,
						/mob/living/carbon/Xenomorph/Praetorian,
						/mob/living/carbon/Xenomorph/Ravager/mature,
						/mob/living/carbon/Xenomorph/Praetorian/mature)

			spawnxeno -= list(/mob/living/carbon/Xenomorph/Sentinel,
						/mob/living/carbon/Xenomorph/Runner,
						/mob/living/carbon/Xenomorph/Runner)

		if(13)//Start the elite transition
			spawnxeno += list(/mob/living/carbon/Xenomorph/Crusher/mature,
						/mob/living/carbon/Xenomorph/Boiler,
						/mob/living/carbon/Xenomorph/Ravager/elite,
						/mob/living/carbon/Xenomorph/Runner/elite,
						/mob/living/carbon/Xenomorph/Hivelord/elite,
						/mob/living/carbon/Xenomorph/Spitter/elite,
						/mob/living/carbon/Xenomorph/Praetorian/elite)

			spawnxeno -= list(/mob/living/carbon/Xenomorph/Spitter/mature,
						/mob/living/carbon/Xenomorph/Drone/elite,
						/mob/living/carbon/Xenomorph/Hivelord)

		if(14)//Start the ancient Also keeping this spawnlist the same since its suppose to be just about get fucked in the end.
			spawn_xeno_num = 50
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
		world << "<span class='notice'>*___________________________________*</span>"
		world << "<span class='boldnotice'>***Whiskey Outpost Controller***</span>"
		world << "\blue Moved [xeno_count] Xeno remains to trash."
		world << "<span class='notice'>*___________________________________*</span>"


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
		world << "<span class='round_header'>The Xenos have succesfully defended their home planet from colonization.</span>"
		world << "<span class='round_body'>Well done, you've secured the planet for the hive!</span>"
		world << sound('sound/misc/Game_Over_Man.ogg')

		if(round_stats) // Logging to data/logs/round_stats.log
			round_stats << "Marines remaining: [count_humans()]\nRound time: [duration2text()][log_end]\nBig Winner:)"

	else if(finished == 2)
		feedback_set_details("round_end_result","Marines Won")
		world << "<span class='round_header'>Against the onslaught, the marines have survived.</span>"
		world << "<span class='round_body'>The roar of thrusters can be heard as dropships arrive. Relief has finally arrived.</span>"
		world << sound('sound/misc/hell_march.ogg')

		if(round_stats) // Logging to data/logs/round_stats.log
			round_stats << "Marines remaining: [count_humans()]\nRound time: [duration2text()][log_end]"
	else
		feedback_set_details("round_end_result","no winners")
		world << "<span class='round_header'>NOBODY WON!</span>"
		world << "<span class='round_body'>How? Don't ask me...</span>"
		world << 'sound/misc/sadtrombone.ogg'

		if(round_stats) // Logging to data/logs/round_stats.log
			round_stats << "Marines remaining: [count_humans()]\nRound time: [duration2text()][log_end]"

	return 1

/datum/game_mode/proc/auto_declare_completion_whiskey_outpost()
	return

/datum/game_mode/whiskey_outpost/proc/place_drop(var/turf/T,var/OT) //Art revamping spawns 13JAN17
	if(!istype(T)) return
	var/randpick
	var/list/randomitems = list()
	var/list/spawnitems = list()
	var/choosemax
	var/obj/structure/closet/crate/crate

	if(isnull(OT) || OT == "")
		OT = "sup" //no breaking anything.

	else if (OT == "sup")
		randpick = rand(0,50)
		switch(randpick)
			if(0 to 5)//Marine Gear 10% Chance.
				crate = new /obj/structure/closet/crate/secure/gear(T)
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
								/obj/item/device/binoculars)

			if(6 to 10)//Lights and shiet 10%
				crate = new /obj/structure/closet/crate/secure/gear(T)
				choosemax = rand(5,15)
				randomitems = list(/obj/item/weapon/storage/box/m94,
								/obj/item/weapon/storage/box/m94,
								/obj/item/weapon/storage/box/m94,
								/obj/item/weapon/storage/box/m94,
								/obj/item/weapon/storage/box/m94,
								/obj/item/weapon/storage/box/m94,
								/obj/item/weapon/storage/box/m94,
								/obj/item/weapon/storage/box/m94,
								/obj/machinery/floodlight)

			if(11 to 13) //6% Chance to drop this !FUN! junk.
				crate = new /obj/structure/closet/crate/secure/gear(T)
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
									/obj/item/weapon/flame/lighter/random)

			if(14 to 18)//Materials 10% Chance.
				crate = new /obj/structure/closet/crate/secure/gear(T)
				choosemax = rand(3,8)
				randomitems = list(/obj/item/stack/rods,
								/obj/item/stack/sheet/glass,
								/obj/item/stack/sheet/metal,
								/obj/item/stack/sheet/metal,
								/obj/item/stack/sheet/plasteel,
								/obj/item/stack/sheet/wood,
								/obj/item/stack/sheet/wood)

			if(19 to 20)//Blood Crate 4% chance
				crate = new /obj/structure/closet/crate/medical(T)
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

			if(21 to 25)//Advanced meds Crate 10%
				crate = new /obj/structure/closet/crate/medical(T)
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

			if(26 to 30)//Random Medical Items 10% as well. Made the list have less small junk
				crate = new /obj/structure/closet/crate/medical(T)
				choosemax = rand(10,15)
				randomitems = list(/obj/item/weapon/storage/firstaid/fire,
								/obj/item/weapon/storage/firstaid/regular,
								/obj/item/weapon/storage/firstaid/toxin,
								/obj/item/weapon/storage/firstaid/o2,
								/obj/item/weapon/storage/firstaid/adv,
								/obj/item/weapon/storage/belt/medical/combatLifesaver,
								/obj/item/weapon/storage/pill_bottle/tramadol,
								/obj/item/weapon/storage/pill_bottle/tramadol,
								/obj/item/weapon/storage/pill_bottle/spaceacillin,
								/obj/item/weapon/storage/pill_bottle/antitox,
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

			if(31 to 40)//Random Attachments Crate 20% because the lord commeth and said let there be attachments.
				crate = new /obj/structure/closet/crate/secure/weapon(T)
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
								/obj/item/attachable/burstfire_assembly)

			if(41 to 45)//Sentry gun drop. 10%
				crate = new /obj/structure/closet/crate/secure/weapon(T)
				spawnitems = list(/obj/item/weapon/storage/box/sentry,
								/obj/item/weapon/storage/box/sentry,
								/obj/item/weapon/storage/box/sentry,
								/obj/item/weapon/storage/box/sentry)

			if(46 to 50)//Weapon + supply beacon drop. 10%
				crate = new /obj/structure/closet/crate/secure/weapon(T)
				spawnitems = list(/obj/item/weapon/gun/rifle/m41a,
								/obj/item/weapon/gun/rifle/m41a,
								/obj/item/weapon/gun/rifle/m41a,
								/obj/item/weapon/gun/smg/m39,
								/obj/item/weapon/gun/smg/m39,
								/obj/item/weapon/gun/smg/m39,
								/obj/item/weapon/gun/shotgun/pump,
								/obj/item/weapon/gun/shotgun/pump,
								/obj/item/weapon/gun/shotgun/pump,
								/obj/item/device/whiskey_supply_beacon,
								/obj/item/device/whiskey_supply_beacon,
								/obj/item/device/whiskey_supply_beacon,
								/obj/item/device/whiskey_supply_beacon)

	crate.storage_capacity = 60

	if(randomitems.len)
		for(var/i = 0; i < choosemax; i++)
			var/path = pick(randomitems)
			var/obj/I = new path(crate)
			if(OT == "sup")
				if(I && istype(I,/obj/item/stack/sheet/mineral/phoron) || istype(I,/obj/item/stack/rods) || istype(I,/obj/item/stack/sheet/glass) || istype(I,/obj/item/stack/sheet/metal) || istype(I,/obj/item/stack/sheet/plasteel) || istype(I,/obj/item/stack/sheet/wood))
					I:amount = rand(30,50) //Give them more building materials.
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

/////////////////////////////////////////
// Whiskey Outpost V2 Standard Edition //
/////////////////////////////////////////

//////////////////////////////////////////////////////////////
// Laser Designator

/obj/item/device/laz_designator
	name = "laser designator" // Make sure they know this will kill people in the desc below.
	desc = "A laser designator, used to mark targets for airstrikes. This one comes with two modes, one for IR laser which calls in a napalm airstrike upon the position, the other being a UV laser which calculates the distance for a mortar strike. On the side there is a label that reads:<span class='notice'> !!WARNING: Deaths from use of this tool will have the user held accountable!!</span>"
	icon = 'icons/turf/whiskeyoutpost.dmi'
	icon_state = "designator_e"

	//Considering putting in power cells into the weapon to power it but for now its probably not going to happen. So we'll settle for cooldowns then.
	//laser_con is to add you to the list of laser users.
	flags_atom = FPRINT|CONDUCT
	force = 5.0
	w_class = 2.0
	throwforce = 5.0
	throw_range = 15
	throw_speed = 3
	var/atom/target = null // required for lazing at things.
	var/laz_r = 0 //Red Laser, Used to Replace the IR. 0 is not active, 1 is cool down, 2 is actively Lazing the target
	var/laz_b = 0 //Blue laser, Used to rangefind the coordinates for a mortar strike. 0 is not active, 1 is cool down, 2 is active laz.
	var/laz_mode = 0 //What laser mode we are on. If we're on 0 we're not active, 1 is IR laser, 2 is UV Laser
	var/plane_toggle = 0 //Attack plane for Airstrike 0 for E-W 1 for N-S, Mortar power for mortars.
	var/mob/living/carbon/human/FAC = null // Our lovely Forward Air Controllers
	var/lazing = 0 //ARe we using it right now?

/obj/item/device/laz_designator/update_icon()
	switch(laz_mode)
		if(0)
			icon_state = "designator_e"
		if(1)
			icon_state = "designator_r"
		if(2)
			icon_state = "designator_b"
	return

/obj/item/device/laz_designator/verb/switch_mode()
	set category = "Weapons"
	set name = "Change Laser Setting"
	set desc = "This will disable the laser, enable the IR laser, or enable the UV laser. IR for airstrikes and UV for Mortars"
	set src in usr

	playsound(src,'sound/machines/click.ogg', 50, 1)

	switch(laz_mode)
		if(0) //Actually adding descriptions so you can tell what the hell you've selected now.
			laz_mode = 1
			usr << "<span class='warning'>IR Laser enabled! You will now designate airstrikes!</span>"
			update_icon()
			return
		if(1)
			laz_mode = 2
			usr << "<span class='warning'>UV Laser enabled! You will now designate mortars!</span>"
			update_icon()
			return
		if(2)
			laz_mode = 0
			usr << "<span class='warning'> System offline, now this is just a pair of binoculars but heavier.</span>"
			update_icon()
			return
	return

/obj/item/device/laz_designator/verb/switch_laz()
	set category = "Weapons"
	set name = "Change Lasing Mode"
	set desc = "Will change the airstrike plane from going East/West to North/South, or if using Mortars, it'll change the warhead used on them."
	set src in usr

	playsound(src,'sound/machines/click.ogg', 50, 1)

	switch(plane_toggle)
		if(0)
			plane_toggle = 1
			usr << "<span class='warning'> Airstrike plane is now N-S! If using mortars its now HE rounds!</span>"
			return
		if(1)
			plane_toggle = 0
			usr << "<span class='warning'> Airstrike plane is now E-W! If using mortars its now concussion rounds!</span>"
			return
	return

/obj/item/device/laz_designator/attack_self(mob/living/carbon/human/user)
	zoom(user)
	if(!FAC)
		FAC = user
		return
	else
		FAC = null
		return



/obj/item/device/laz_designator/proc/laz(var/mob/living/carbon/human/user, var/atom/A, var/params)
	if(!FAC) return 0
	if(FAC != user) return 0
	if(istype(A,/obj/screen)) return 0
	if(user.stat)
		zoom(user)
		FAC = null
		return 0

	if(lazing)
		return 0

	target = A
	if(!istype(target))
		return 0

	if(target.z != FAC.z || target.z == 0 || FAC.z == 0 || isnull(FAC.loc))
		return 0

	var/list/modifiers = params2list(params) //Only single clicks.
	if(modifiers["middle"] || modifiers["shift"] || modifiers["alt"] || modifiers["ctrl"])	return 0

	var/turf/SS = get_turf(src) //Stand Still, not what you're thinking.
	var/turf/T = get_turf(A)

	if(!laz_mode)
		user << "<span class='warning'>The Laser Designator is currently off!</span>"
		return 0

	if(laz_r || laz_b) //Make sure we don't spam strikes
		user << "<span class='warning'>The laser is currently cooling down. Please wait roughly 10 minutes from lasing the target.</span>"
		return 0

	user << "<span class='boldnotice'> You start lasing the target area.</span>"
	message_admins("ALERT: [user] ([user.key]) IS CURRENTLY LAZING A TARGET: CURRENT MODE [laz_mode], at ([T.x],[T.y],[T.z]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>JMP</a>).") // Alert all the admins to this asshole. Added the jmp command from the explosion code.
	var/obj/effect/las_target/lasertarget = new(T.loc)
	if(laz_mode == 1 && !laz_r) // Heres our IR bomb code.
		lazing = 1
		lasertarget.icon_state = "laz_r"
		laz_r = 2
		sleep(50)
		if(SS != get_turf(src)) //Don't move.
			lazing = 0
			laz_r = 0
			return 0
		lasertarget.icon_state = "lazlock_r"
		var/offset_x = 0
		var/offset_y = 0
		if(!plane_toggle)
			offset_x = 4
		if(plane_toggle)
			offset_y = 4
		var/turf/target = locate(T.x + offset_x,T.y + offset_y,T.z) //Three napalm rockets are launched
		var/turf/target_2 = locate(T.x,T.y,T.z)
		var/turf/target_3 = locate(T.x - offset_x,T.y - offset_y,T.z)
		var/turf/target_4 = locate(T.x - (offset_x*2),T.y - (offset_y*2),T.z)
		sleep(50) //AWW YEAH
		flame_radius(3,target)
		explosion(target,  -1, 2, 3, 5)
		flame_radius(3,target_2)
		explosion(target_2,  -1, 2, 3, 5)
		flame_radius(3,target_3)
		explosion(target_3,  -1, 2, 3, 5)
		flame_radius(3,target_4)
		explosion(target_4,  -1, 2, 3, 5)
		sleep(1)
		del(lasertarget)
		lazing = 0
		laz_r = 1
		sleep(6000)
		laz_r = 0
		return
	else if(laz_mode == 2 && !laz_b) //Give them the option for mortar fire.
		lazing = 1
		lasertarget.icon_state = "laz_b"
		laz_b = 2
		sleep(50)
		if(SS != get_turf(src)) //Don't move.
			lazing = 0
			laz_b = 0
			return 0
		lasertarget.icon_state = "lazlock_b"
		var/HE_power = 0
		var/con_power = 0
		if(!plane_toggle)
			con_power = 5
			HE_power = 1
		else
			con_power = 3
			HE_power = 3
		var/turf/target = locate(T.x + rand(-2,2),T.y + rand(-2,2),T.z)
		var/turf/target_2 = locate(T.x + rand(-2,2),T.y + rand(-2,2),T.z)
		var/turf/target_3 = locate(T.x + rand(-2,2),T.y + rand(-2,2),T.z)
		if(target && istype(target))
			del(lasertarget)
			explosion(target, -1, HE_power, con_power, con_power) //Kaboom!
			sleep(rand(15,30)) //This is all better done in a for loop, but I am mad lazy
			explosion(target_2, -1, HE_power, con_power, con_power)
			sleep(rand(15,30))
			explosion(target_3, -1, HE_power, con_power, con_power)
			lazing = 0
			laz_b = 1
			sleep(6000)
			laz_b = 0
			return

/obj/item/device/laz_designator/afterattack(atom/A as mob|obj|turf, mob/user as mob, params) // This is actually WAY better, espically since its fucken already in the code.
	laz(user, A, params)
	return

/obj/effect/las_target
	name = "laser"
	icon = 'icons/turf/whiskeyoutpost.dmi'
	icon_state = "laz_r"
	opacity = 1
	anchored = 1
	mouse_opacity = 0
	unacidable = 1

////////////////////////////////////////////////////////////
//Supply drops for Whiskey Outpost via SLs
//These will come in the form of ammo drops. Will have probably like 5 settings? SLs will get a few of them.
//Should go: Regular ammo, Spec Rocket Ammo, Spec Smartgun ammo, Spec Sniper ammo, and then explosives (grenades for grenade spec).
//This should at least give SLs the ability to rearm their squad at the frontlines.

/obj/item/device/whiskey_supply_beacon //Whiskey Outpost Supply beacon. Might as well reuse the IR target beacon (Time to spook the fucking shit out of people.)
	name = "ASB beacon"
	desc = "Ammo Supply Beacon, it has 5 different settings for different supplies. Look at your weapons verb tab to be able to switch ammo drops."
	icon = 'icons/turf/whiskeyoutpost.dmi'
	icon_state = "ir_beacon"
	w_class = 2
	var/activated = 0
	var/icon_activated = "ir_beacon_active"
	var/supply_drop = 0 //0 = Regular ammo, 1 = Rocket, 2 = Smartgun, 3 = Sniper, 4 = Explosives + GL

/obj/item/device/whiskey_supply_beacon/attack_self(mob/user)
	if(activated)
		user << "Toss it to get supplies!"
		return

	if(!ishuman(user)) return
	if(!user.mind)
		user << "It doesn't seem to do anything for you."
		return

	if(user.z != 1)
		user << "You have to be on the ground to use this or it won't transmit."
		return

	activated = 1
	anchored = 1
	w_class = 10
	icon_state = "[icon_activated]"
	playsound(src, 'sound/machines/twobeep.ogg', 50, 1)
	user << "You activate the [src]. Now toss it, the supplies will arrive in a moment!"
	sleep(100) //10 seconds should be enough.
	var/turf/T = get_turf(src) //Make sure we get the turf we're tossing this on.
	drop_supplies(T,supply_drop)
	playsound(src,'sound/effects/bamf.ogg', 100, 1)
	del(src)
	return

/obj/item/device/whiskey_supply_beacon/verb/switch_supplies()
	set category = "Weapons"
	set name = "Change Ammo Drop"
	set desc = "This will change the supplies that drop."
	set src in usr

	playsound(src,'sound/machines/click.ogg', 50, 1)

	switch(supply_drop)
		if(0)
			supply_drop = 1
			usr << "<span class='notice'>Rocket ammo will now drop!</span>"
			return
		if(1)
			supply_drop = 2
			usr << "<span class='notice'>Smartgun ammo will now drop!</span>"
			return
		if(2)
			supply_drop = 3
			usr << "<span class='notice'>Sniper ammo will now drop!</span>"
			return
		if(3)
			supply_drop = 4
			usr << "<span class='notice'>Explosives and grenades will now drop!</span>"
			return
		if(4)
			supply_drop = 0
			usr << "<span class='notice'>10x24mm, slugs, buckshot, and 10x20mm rounds will now drop!</span>"
			return
	return

/obj/item/device/whiskey_supply_beacon/proc/drop_supplies(var/turf/T,var/SD)
	if(!istype(T)) return
	var/list/spawnitems = list()
	var/obj/structure/closet/crate/crate
	crate = new /obj/structure/closet/crate/secure/weapon(T)
	switch(SD)
		if(0) // Alright 2 mags for the SL, a few mags for M41As that people would need. M39s get some love and split the shotgun load between slugs and buckshot.
			spawnitems = list(/obj/item/ammo_magazine/rifle/m41aMK1,
							/obj/item/ammo_magazine/rifle/m41aMK1,
							/obj/item/ammo_magazine/rifle,
							/obj/item/ammo_magazine/rifle,
							/obj/item/ammo_magazine/rifle,
							/obj/item/ammo_magazine/rifle,
							/obj/item/ammo_magazine/rifle,
							/obj/item/ammo_magazine/rifle,
							/obj/item/ammo_magazine/rifle/ap,
							/obj/item/ammo_magazine/rifle/ap,
							/obj/item/ammo_magazine/rifle/ap,
							/obj/item/ammo_magazine/smg/m39,
							/obj/item/ammo_magazine/smg/m39,
							/obj/item/ammo_magazine/smg/m39,
							/obj/item/ammo_magazine/smg/m39,
							/obj/item/ammo_magazine/smg/m39/ap,
							/obj/item/ammo_magazine/smg/m39/ap,
							/obj/item/ammo_magazine/smg/m39/ap,
							/obj/item/ammo_magazine/shotgun,
							/obj/item/ammo_magazine/shotgun,
							/obj/item/ammo_magazine/shotgun/buckshot,
							/obj/item/ammo_magazine/shotgun/buckshot)
		if(1) // Six rockets should be good. Tossed in two AP rockets for possible late round fighting.
			spawnitems = list(/obj/item/ammo_magazine/rocket,
							/obj/item/ammo_magazine/rocket,
							/obj/item/ammo_magazine/rocket,
							/obj/item/ammo_magazine/rocket/ap,
							/obj/item/ammo_magazine/rocket/ap,
							/obj/item/ammo_magazine/rocket/wp)
		if(2) //4 power packs is basically 1000 extra rounds. Should last them enough.
			spawnitems = list(/obj/item/smartgun_powerpack,
							/obj/item/smartgun_powerpack,
							/obj/item/smartgun_powerpack,
							/obj/item/smartgun_powerpack)
		if(3) //Full Sniper ammo loadout.
			spawnitems = list(/obj/item/ammo_magazine/sniper,
							/obj/item/ammo_magazine/sniper,
							/obj/item/ammo_magazine/sniper,
							/obj/item/ammo_magazine/sniper,
							/obj/item/ammo_magazine/sniper/incendiary,
							/obj/item/ammo_magazine/sniper/flak)
		if(4) // Give them explosives + Grenades for the Grenade spec. Might be too many grenades, but we'll find out.
			spawnitems = list(/obj/item/weapon/storage/box/explosive_mines,
							/obj/item/weapon/storage/box/explosive_mines,
							/obj/item/weapon/storage/box/explosive_mines,
							/obj/item/weapon/storage/belt/grenade,
							/obj/item/weapon/storage/belt/grenade,
							/obj/item/weapon/storage/belt/grenade,
							/obj/item/weapon/storage/belt/grenade)
	crate.storage_capacity = 60
	for(var/path in spawnitems)
		new path(crate)

////////////////////////////////////////
// Whiskey Outpost V2 Big Red Edition //
////////////////////////////////////////


// Lets make our desert/sand edition.
/turf/unsimulated/floor/mars
	name = "dirt"
	icon = 'icons/turf/floors.dmi'
	icon_state = "mars_tile_1"

	New()
		..()
		icon_state = "mars_tile_[rand(1,5)]"

////////////////////////////////////////////////////////////

//New Update not only for this whiskey outpost but the jungle one as well.
//Autodoc
/obj/machinery/autodoc
	name = "Med-Pod"
	desc = "A fancy machine developed to be capable of operating on people. Complex machinery however, only a doctor or a medically trained offical would know how to operate one of these."
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeper_0"
	density = 1
	anchored = 1
	var/mob/living/carbon/human/occupant = null
	var/surgery_t = 0 //Surgery timer in seconds.
	var/surgery = 0 //Are we operating or no? 0 for no, 1 for yes
	var/surgery_mod = 1 //What multiple to increase the surgery timer? This is used for any non-WO maps or events that are done.

	//It uses power
	use_power = 1
	idle_power_usage = 15
	active_power_usage = 450 //Capable of doing various activities

	allow_drop()
		return 0

	process()
		updateUsrDialog()
		return

	proc/scan_occupant(mob/living/carbon/M as mob)
		surgery_t = 0
		if(M.stat == 2)
			visible_message("[src] buzzes.")
			go_out() // If dead, eject them from the start.
			return
		if(M.health <= -160)
			visible_message("[src] flashes <span class='notice'>'UNOPERABLE:CRITICAL HEALTH'</span>") //make sure the docs heal them a bit than just throw them near dead.
			go_out() //Eject them for immediate treatment.
			return
		visible_message("[src] scans the occupant.")
		var/internal_t_dam = 0 //Making these guys a bit more seperate because its a bit easier to track.
		var/implants_t_dam = 0
		var/broken_t_dam = 0
		for(var/datum/organ/internal/I in M.internal_organs)
			internal_t_dam += (I.damage * 5) // This makes massive internal organ damage be more severe to repair. 20*5 = 100, 1:40 min to repair.
		for(var/datum/organ/external/O in src.occupant.organs)
			for(var/obj/S in O.implants)
				if(istype(S))
					implants_t_dam += 20 // 20 seconds per shrapnel piece stuck inside.
			if(O.status & ORGAN_BROKEN)
				broken_t_dam += 30 //30 seconds per broken bone should be better.
		if(M.getOxyLoss() > 50) //Make sure they don't DIE in here, also starts assisted breathing instantly.
			M.setOxyLoss(rand(0,25)) //Set it to 25 to not ded.
			visible_message("[src] begins assisted breathing support.")

		//Now how to balance out the damages done. 2 seconds per brute damage, 3 seconds per burn damage. 4 for toxins (filter them out), 2 for oxy-loss.
		surgery_t += (M.getBruteLoss() + (M.getFireLoss()*2) + (M.getToxLoss()*4) + (M.getOxyLoss()*2))
		surgery_t += internal_t_dam + implants_t_dam + broken_t_dam
		surgery_t = surgery_t*surgery_mod*10 //Now make it actual seconds.
		if(surgery_t < 1200) surgery_t = 1200
		return


	proc/surgery_op(mob/living/carbon/M as mob)
		if(M.stat == 2)
			visible_message("[src] buzzes.")
			src.go_out() //kick them out too.
			return
		visible_message("[src] begins to operate, loud audiable clicks lock the pod.")
		surgery = 1
		//Give our first boost of healing, mainly so they don't die instantly
		M.setOxyLoss(0) //Fix our breathing issues
		M.heal_organ_damage(25,25)
		sleep(surgery_t * 0.5) //Fix their organs now  so it makes sense halfway through
		if(!occupant) return
		M.setOxyLoss(0) //Fix our breathing issues
		M.heal_organ_damage(25,25)
		for(var/datum/organ/internal/I in M.internal_organs) //Fix the organs
			I.damage = 0
		for(var/datum/organ/external/O in occupant.organs) //Remove all the friendly fire.
			if(istype(O, /datum/organ/external/head))
				var/datum/organ/external/head/H = O
				if(H.disfigured)	H.disfigured = 0
			for(var/obj/S in O.implants)
				if(istype(S))
					S.loc = src.loc
					O.implants -= S

		sleep(surgery_t * 0.5) // Fully heal them now.
		if(!occupant) return
		M.setOxyLoss(0) //Fix our breathing issues
		M.adjustToxLoss(-70) // Help out with toxins
		M.eye_blurry = 0 //fix our eyes
		M.eye_blind = 0 //fix our eyes
		M.heal_organ_damage(25,25) // I think it caps out at like roughly 25, its really werid.
		M.heal_organ_damage(25,25)
		M.restore_all_organs()
		M.UpdateDamageIcon()
		sleep(5)
		visible_message("The Med-Pod clicks and opens up revealing a healed human")
		go_out()
		icon_state = "sleeper_0"
		surgery = 0
		return

//MSD is a nerd, leaving this here for him to find later.

	verb/eject()
		set name = "Eject Med-Pod"
		set category = "Object"
		set src in oview(1)
		if(surgery) return
		if(usr.stat != 0) return
		go_out()
		add_fingerprint(usr)
		return

	verb/manual_eject()
		set name = "Manual Eject Med-Pod"
		set category = "Object"
		set src in oview(1)
		if(surgery) surgery = 0
		go_out()
		add_fingerprint(usr)
		return

	verb/move_inside()
		set name = "Enter Med-Pod"
		set category = "Object"
		set src in oview(1)

		if(usr.stat != 0 || !(ishuman(usr) || ismonkey(usr))) return

		if(occupant)
			usr << "<span class='notice'>The sleeper is already occupied!</span>"
			return

		if(stat & (NOPOWER|BROKEN))
			usr << "<span class='notice'>The Med-Pod is non-functional!</span>"
			return

		visible_message("[usr] starts climbing into the sleeper.", 3)
		if(do_after(usr, 20, FALSE))
			if(occupant)
				usr << "<span class='notice'>The sleeper is already occupied!</span>"
				return
			usr.stop_pulling()
			usr.client.perspective = EYE_PERSPECTIVE
			usr.client.eye = src
			usr.loc = src
			update_use_power(2)
			occupant = usr
			icon_state = "sleeper_1"
			scan_occupant(occupant) // Make it scan them when they get in to set our timer.

			for(var/obj/O in src)
				del(O)
			add_fingerprint(usr)
			return
		return

	proc/go_out()
		if(!occupant) return
		occupant.forceMove(loc)
		occupant = null
		update_use_power(1)
		icon_state = "sleeper_0"
		return

	attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
		if(istype(W, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = W
			if(!ismob(G.grabbed_thing))
				return
			var/mob/M = G.grabbed_thing
			if(src.occupant)
				user << "<span class='notice'>The Med-Pod is already occupied!</span>"
				return

			if(stat & (NOPOWER|BROKEN))
				user << "<span class='notice'>The Med-Pod is non-functional!</span>"
				return

			visible_message("[user] starts putting [M] into the Med-Pod.", 3)

			if(do_after(user, 20, FALSE))
				if(src.occupant)
					user << "<span class='notice'>The Med-Pod is already occupied!</span>"
					return
				if(!G || !G.grabbed_thing) return
				M.forceMove(src)
				update_use_power(2)
				occupant = M
				icon_state = "sleeper_1"

				add_fingerprint(user)
				scan_occupant(occupant) // Make it scan them when they get in to set our timer.


/////////////////////////////////////////////////////////////

//Auto Doc console that links up to it.
/obj/machinery/autodoc_console
	name = "Med-Pod Console"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeperconsole"
	var/obj/machinery/autodoc/connected = null
	anchored = 1 //About time someone fixed this.
	density = 0

	use_power = 1
	idle_power_usage = 40

	New()
		..()
		spawn( 5 )
			connected = locate(/obj/machinery/autodoc, get_step(src, WEST))
			return
		return

	process()
		if(stat & (NOPOWER|BROKEN))
			if(icon_state != "sleeperconsole-p")
				icon_state = "sleeperconsole-p"
			return
		if(icon_state != "sleeperconsole")
			icon_state = "sleeperconsole"
		updateUsrDialog()
		return

	attack_hand(mob/user as mob)
		if(..())
			return
		var/dat = ""
		if (!src.connected || (connected.stat & (NOPOWER|BROKEN)))
			dat += "This console is not connected to a Med-Pod or the Med-Pod is non-functional."
			user << "This console seems to be powered down."
		else
			var/mob/living/occupant = connected.occupant
			dat += "<font color='blue'><B>Occupant Statistics:</B></FONT><BR>"
			if (occupant)
				var/t1
				switch(occupant.stat)
					if(0)	t1 = "Conscious"
					if(1)	t1 = "<font color='blue'>Unconscious</font>"
					if(2)	t1 = "<font color='red'>*dead*</font>"
				var/operating
				switch(connected.surgery)
					if(0) operating = "Not in surgery"
					if(1) operating = "IN SURGERY: DO NOT MANUALLY EJECT OR PATIENT HARM WILL BE CAUSED"
				dat += text("[]\tHealth %: [] ([])</FONT><BR>", (occupant.health > 50 ? "<font color='blue'>" : "<font color='red'>"), occupant.health, t1)
				if(iscarbon(occupant))
					var/mob/living/carbon/C = occupant
					dat += text("[]\t-Pulse, bpm: []</FONT><BR>", (C.pulse == PULSE_NONE || C.pulse == PULSE_THREADY ? "<font color='red'>" : "<font color='blue'>"), C.get_pulse(GETPULSE_TOOL))
				dat += text("[]\t-Brute Damage %: []</FONT><BR>", (occupant.getBruteLoss() < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.getBruteLoss())
				dat += text("[]\t-Respiratory Damage %: []</FONT><BR>", (occupant.getOxyLoss() < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.getOxyLoss())
				dat += text("[]\t-Toxin Content %: []</FONT><BR>", (occupant.getToxLoss() < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.getToxLoss())
				dat += text("[]\t-Burn Severity %: []</FONT><BR>", (occupant.getFireLoss() < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.getFireLoss())
				dat += text("<HR> Surgery Estimate: [] seconds<BR>", (connected.surgery_t * 0.1))
				dat += text("<HR> Med-Pod Status: [] ", operating)
				dat += "<HR><A href='?src=\ref[src];refresh=1'>Refresh Menu</A>"
				dat += "<HR><A href='?src=\ref[src];surgery=1'>Start Surgery</A>"
				dat += "<HR><A href='?src=\ref[src];ejectify=1'>Eject Patient</A>"
			else
				dat += "The Med-Pod is empty."
		dat += text("<BR><BR><A href='?src=\ref[];mach_close=sleeper'>Close</A>", user)
		user << browse(dat, "window=sleeper;size=400x500")
		onclose(user, "sleeper")
		return

	Topic(href, href_list)
		if(..())
			return
		if ((usr.contents.Find(src) || ((get_dist(src, usr) <= 1) && istype(src.loc, /turf))))
			usr.set_machine(src)
			if (href_list["refresh"])
				updateUsrDialog()
			if (href_list["surgery"])
				connected.surgery_op(src.connected.occupant)
				updateUsrDialog()
			if (href_list["ejectify"])
				connected.eject()
				updateUsrDialog()
			add_fingerprint(usr)
		return
