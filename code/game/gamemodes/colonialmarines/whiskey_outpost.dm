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
			command_announcement.Announce("This is Commander Anderson speaking from the USS Alistoun. We've heard the Sulaco's distress beacon, but we need you to hold Whiskey Outpost for an hour before the marine force is equipped and ready. We're sending UD-22 Navajo gunships to assist in your defense.", "USS Alistoun")

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
			W.name = "[M.real_name]'s ID Card"
			W.access = get_all_accesses()
			W.assignment = "Ground Commander"
			W.paygrade = "O2"
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
			W.name = "[M.real_name]'s ID Card"
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
			W.name = "[M.real_name]'s ID Card"
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
					H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/gun/machete/full(H), WEAR_L_HAND)

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
				world << sound(pick('sound/voice/alien_distantroar_3.ogg', 'sound/voice/alien_roar_small.ogg', 'sound/voice/xenos_roaring.ogg', 'sound/voice/alien_roar_large.ogg', 'sound/voice/alien_queen_died.ogg', 'sound/voice/4_xeno_roars.ogg'))

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
					world << sound('sound/effects/explosionfar.ogg')
					sleep(5)
					world << sound('sound/effects/explosionfar.ogg')
					sleep(5)
					world << sound('sound/effects/explosionfar.ogg')
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
						/mob/living/carbon/Xenomorph/Spitter)

		if(5)//Reset the spawns	so we don't drown in xenos again.
			spawn_xeno_num = (count_humans() * 0.5) //Reset

		if(6)//Tier II more common
			spawnxeno += list(/mob/living/carbon/Xenomorph/Hunter,
						/mob/living/carbon/Xenomorph/Spitter)

		if(8)
			spawn_next_wave += 220 //Slow down now, strong castes introduced next wave
			spawn_xeno_num = 0

			spawnxeno -= list(/mob/living/carbon/Xenomorph/Runner,
						/mob/living/carbon/Xenomorph/Runner,
						/mob/living/carbon/Xenomorph/Sentinel)

		if(9)//Ravager and Praetorian Added, Tier II more common, Tier I less common
			spawn_next_wave -= 110 //Speed it up again. After the period of grace.
			spawn_xeno_num = count_humans()
			spawnxeno += list(/mob/living/carbon/Xenomorph/Hunter/mature,
						/mob/living/carbon/Xenomorph/Hunter/mature,
						/mob/living/carbon/Xenomorph/Spitter/mature,
						/mob/living/carbon/Xenomorph/Runner/mature,
						/mob/living/carbon/Xenomorph/Runner/mature,
						/mob/living/carbon/Xenomorph/Drone/mature)

			spawnxeno -= list(/mob/living/carbon/Xenomorph/Sentinel)

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
			spawn_next_wave = count_humans() * 3 //rip and tear.
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


////////////////////////////////////////////////////////////////////////////////////

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

/////////////////////////////////////////
// Whiskey Outpost V2 Standard Edition //
/////////////////////////////////////////


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

	New()
		if(dir != NORTH)
			layer = 5
		else
			layer = 3

	Crossed(atom/movable/O)
		..()
		if(istype(O,/mob/living/carbon/Xenomorph/Crusher))
			var/mob/living/carbon/Xenomorph/M = O
			if(!M.stat)
				visible_message("<span class='danger'>[O] steamrolls through the [src]!</span>")
				destroy()

	update_icon()
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

//////////////////////////////////////////////////////////////
// Laser Designator

/obj/item/device/laz_designator
	name = "Laser Designator" // Make sure they know this will kill people in the desc below.
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


//////////////////////////////////////////////////////////////
//Mounted MG, Replacment for the current jury rig code.

// First thing we need is the ammo drum for this thing.
/obj/item/m56d_ammo
	name = "M56D drum magazine (10x28mm Caseless)"
	desc = "A box of 700, 10x28mm caseless tungsten rounds for the M56D mounted smartgun system. Just click the M56D with this to reload it."
	w_class = 4
	icon = 'icons/turf/whiskeyoutpost.dmi'
	icon_state = "ammo_drum"

// Now we need a box for this.
/obj/item/weapon/storage/box/m56d_hmg
	name = "\improper M56D crate"
	desc = "A large wooden case for the M56D Heavy Machinegun, with the tools to boot."
	icon = 'icons/turf/whiskeyoutpost.dmi'
	icon_state = "M56D_case" // I guess a placeholder? Not actually going to show up ingame for now.
	w_class = 5
	storage_slots = 5
	can_hold = list()

	New()
		..()
		spawn(1)
			new /obj/item/device/m56d_gun(src) //gun itself
			new /obj/item/m56d_ammo(src) //ammo for the gun
			new /obj/item/device/m56d_post(src) //post for the gun
			new /obj/item/weapon/wrench(src) //wrench to hold it down into the ground
			new /obj/item/weapon/screwdriver(src) //screw the gun onto the post.

// The actual gun itself.
/obj/item/device/m56d_gun
	name = "\improper M56D Mounted Smartgun"
	desc = "The top half of a M56D Machinegun post. However it ain't much use without the tripod."
	unacidable = 1
	w_class = 5
	icon = 'icons/turf/whiskeyoutpost.dmi'
	icon_state = "M56D_gun_e"
	var/rounds = 0 // How many rounds are in the weapon. This is useful if we break down our guns.

	New()
		update_icon()

/obj/item/device/m56d_gun/examine(mob/user as mob) //Let us see how much ammo we got in this thing.
	..()
	if(rounds)
		usr << "It has [rounds] out of 700 rounds."
	else
		usr << "It seems to be lacking a ammo drum."

/obj/item/device/m56d_gun/update_icon() //Lets generate the icon based on how much ammo it has.
	if(!rounds)
		icon_state = "M56D_gun_e"
	else
		icon_state = "M56D_gun"
	return

/obj/item/device/m56d_gun/attackby(var/obj/item/O as obj, mob/user as mob)
	if(!ishuman(user))
		return

	if(isnull(O))
		return

	if(istype(O,/obj/item/m56d_ammo)) //lets equip it with ammo
		if(!rounds)
			rounds = 700
			del(O)
			update_icon()
			return
		else
			usr << "The M56D already has a ammo drum mounted on it!"
		return

/obj/item/device/m56d_post //Adding this because I was fucken stupid and put a obj/machinery in a box. Realized I couldn't take it out
	name = "\improper M56D folded mount"
	desc = "The folded, foldable tripod mount for the M56D."
	unacidable = 1
	w_class = 5
	icon = 'icons/turf/whiskeyoutpost.dmi'
	icon_state = "folded_mount"

/obj/item/device/m56d_post/MouseDrop(over_object, src_location, over_location) //Drag the tripod so it opens up.
	if(!ishuman(usr)) return
	var/mob/living/carbon/human/user = usr //this is us
	if((over_object == user && (in_range(src, user) || locate(src) in user))) //Make sure its on ourselves
		new /obj/machinery/m56d_post(src.loc)
		del(src)
		return


//The mount for the weapon.
/obj/machinery/m56d_post
	name = "\improper M56D mount"
	desc = "A foldable tripod mount for the M56D, provides stability to the M56D."
	icon = 'icons/turf/whiskeyoutpost.dmi'
	icon_state = "M56D_mount"
	anchored = 0
	density = 1
	layer = 3.4
	var/gun_mounted = 0 //Has the gun been mounted?
	var/gun_rounds = 0 //Did the gun come with any ammo?
	var/screwed_in = 0 // Is it screwed onto the mount? Won't ever be 1 considering the step it goes to 1 generates the MG.

/obj/machinery/m56d_post/examine(mob/user as mob)
	..()
	if(!anchored)
		usr << "It must be <B>wrenched</b> to the floor."
	if(!gun_mounted)
		usr << "The <b>M56D Mounted Smartgun</b> is not yet mounted."
	if(!screwed_in)
		usr << "The M56D isn't screwed into the mount. Use a <b>screwdriver</b> to finish the job."

/obj/machinery/m56d_post/attackby(var/obj/item/O as obj, mob/user as mob)
	if(!ishuman(user)) //first make sure theres no funkiness
		return

	if(isnull(O))
		return

	if(istype(O,/obj/item/weapon/wrench)) //lets anchor it to the ground.
		if(anchored) //lets make it so we can turn it when we have it on the ground, a nice feature from the actual sentry
			playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
			user.visible_message("[user] rotates the [src].","You rotate the [src].")
			switch(dir)
				if(NORTH)
					dir = EAST
				if(EAST)
					dir = SOUTH
				if(SOUTH)
					dir = WEST
				if(WEST)
					dir = NORTH
		else
			if(locate(/obj/machinery/marine_turret || /obj/machinery/m56d_hmg) in src.loc) // make sure we're not stacking MGs or something
				user << "There's already a turret or m56d here. Drag the frame off first."
				return

			user << "You begin wrenching [src] into place.."
			if(do_after(user,20))
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
				user.visible_message("\blue [user] anchors [src] into place.","\blue You anchor [src] into place.")
				anchored = 1
		return
	if(istype(O,/obj/item/device/m56d_gun)) //lets mount the MG onto the mount.
		var/obj/item/device/m56d_gun/MG = O
		if(!anchored)
			user << "The post must be anchored! Use a wrench!" // you tool
			return
		user << "You begin mounting the M56D.."
		if(do_after(user,30))
			playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
			user.visible_message("\blue [user] installs [O] into place.","\blue You install [O] into place.")
			gun_mounted = 1
			gun_rounds = MG.rounds
			if(!gun_rounds)
				icon_state = "M56D_e"
			else
				icon_state = "M56D" // otherwise we're a empty gun on a mount.
			user.drop_from_inventory(O)
			del(O)
			return

	if(istype(O,/obj/item/weapon/screwdriver))
		if(!anchored)
			user << "The post must be anchored! Use a wrench!"
			return
		if(!gun_mounted)
			user << "There isn't a M56D even mounted on this. Mount the M56D onto the mount first!"
			return
		user << "You're securing the M56D into place"
		if(do_after(user,30))
			playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
			user.visible_message("\blue [user] screws the M56D into the mount.","\blue You finalize the M56D mounted smartgun system.")
			var/obj/machinery/m56d_hmg/G = new(src.loc) //Here comes our new turret.
			G.visible_message("\icon[G] <B>[G] is now complete!</B>") //finished it for everyone to
			G.dir = src.dir //make sure we face the right direction
			G.rounds = src.gun_rounds //Inherent the amount of ammo we had.
			del(src)
			return
	return ..()

// The actual Machinegun itself, going to borrow some stuff from current sentry code to make sure it functions. Also because they're similiar.
/obj/machinery/m56d_hmg
	name = "\improper M56D mounted smartgun"
	desc = "A deployable, mounted smartgun. While it is capable of taking the same rounds as the M56, it fires specialized tungsten rounds for increased armor penetration.<span class='notice'> !!DANGER: M56D DOES NOT HAVE IFF FEATURES!!</span>"
	icon = 'icons/turf/whiskeyoutpost.dmi'
	icon_state = "M56D"
	anchored = 1
	unacidable = 1 //stop the xeno me(l)ta.
	density = 1
	layer = 3.5
	use_power = 0
	flags_atom = RELAY_CLICK
	var/rounds = 0 //Have it be empty upon spawn.
	var/rounds_max = 700
	var/fire_delay = 2 //Gotta have rounds down quick.
	var/last_fired = 0
	var/burst_fire = 0 //0 is non-burst mode, 1 is burst.
	var/safety = 0 //Weapon safety, 0 is weapons hot, 1 is safe.
	var/health = 200
	var/health_max = 200 //Why not just give it sentry-tier health for now.
	var/atom/target = null // required for shooting at things.
	var/datum/ammo/bullet/machinegun/ammo = /datum/ammo/bullet/machinegun
	var/obj/item/projectile/in_chamber = null
	var/locked = 0 //1 means its locked inplace (this will be for sandbag MGs)
	var/is_bursting = 0.
	var/icon_full = "M56D" // Put this system in for other MGs or just other mounted weapons in general, future proofing.
	var/icon_empty = "M56D_e" //Empty

	New()
		ammo = ammo_list[ammo] //dunno how this works but just sliding this in from sentry-code.
		update_icon()

	Del() //Make sure we pick up our trash.
		if(operator && operator.machine)
			operator.machine = null
			operator = null
		if(operator)
			operator = null
		SetLuminosity(0)
		processing_objects.Remove(src)
		..()

/obj/machinery/m56d_hmg/examine(mob/user as mob) //Let us see how much ammo we got in this thing.
	..()
	if(rounds)
		usr << "It has [rounds] out of 700."
	else
		usr << "It seems be lacking ammo"

/obj/machinery/m56d_hmg/update_icon() //Lets generate the icon based on how much ammo it has.
	if(!rounds)
		icon_state = "[icon_empty]"
	else
		icon_state = "[icon_full]"
	return

/obj/machinery/m56d_hmg/attackby(var/obj/item/O as obj, mob/user as mob) //This will be how we take it apart.
	if(!ishuman(user))
		return ..()

	if(isnull(O))
		return

	if(istype(O,/obj/item/weapon/wrench)) // Let us rotate this stuff.
		if(locked)
			user << "This one is anchored in place and cannot be rotated."
			return
		else
			playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
			user.visible_message("[user] rotates the [src].","You rotate the [src].")
			switch(dir)
				if(NORTH)
					dir = EAST
				if(EAST)
					dir = SOUTH
				if(SOUTH)
					dir = WEST
				if(WEST)
					dir = NORTH
		return

	if(istype(O, /obj/item/weapon/screwdriver)) // Lets take it apart.
		if(locked)
			user << "This one cannot be disassembled."
		else
			user << "You begin disassembling the M56D mounted smartgun"
			if(do_after(user,15))
				user.visible_message("<span class='notice'> [user] disassembles [src]! </span>","<span class='notice'> You disassemble [src]!</span>")
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 75, 1)
				var/obj/item/device/m56d_gun/HMG = new(src.loc) //Here we generate our disassembled mg.
				new /obj/item/device/m56d_post(src.loc)
				HMG.rounds = src.rounds //Inherent the amount of ammo we had.
				del(src) //Now we clean up the constructed gun.
				return

	if(istype(O, /obj/item/m56d_ammo)) // RELOADING DOCTOR FREEMAN.
		if(rounds)
			usr << "There is already a ammo drum in the weapon!"
			return
		if(do_after(user,5))
			user.visible_message("<span class='notice'> [user] loads [src]! </span>","<span class='notice'> You load [src]!</span>")
			rounds = 700
			update_icon()
			user.drop_from_inventory(O)
			del(O)
			return
	return ..()

/obj/machinery/m56d_hmg/proc/update_health(var/damage) //Negative damage restores health.
	set waitfor = 0
	health -= damage
	if(health <= 0)
		var/explody = rand(0,1) //Ammo cooks off or something. Who knows.
		playsound(src.loc, 'sound/items/Welder2.ogg', 100, 1)
		sleep(10)
		if(src && src.loc)
			if(rounds && explody) // there goes the ammo magazine.
				explosion(src.loc,-1,-1,2,0)
				new /obj/machinery/m56d_post(src.loc)
				del(src)
			else
				var/obj/item/device/m56d_gun/HMG = new(src.loc)
				HMG.rounds = src.rounds //Inherent the amount of ammo we had.
				del(src)
		return

	if(health > health_max)
		health = health_max
	update_icon()

/obj/machinery/m56d_hmg/bullet_act(var/obj/item/projectile/Proj) //Nope.
	if(prob(30)) // What the fuck is this from sentry gun code. Sorta keeping it because it does make sense that this is just a gun, unlike the sentry.
		return 0

	visible_message("\The [src] is hit by the [Proj.name]!")
	update_health(round(Proj.damage / 10)) //Universal low damage to what amounts to a post with a gun.
	return 1

/obj/machinery/m56d_hmg/attack_alien(mob/living/carbon/Xenomorph/M) // Those Ayy lmaos.
	if(isXenoLarva(M)) return
	src.visible_message("<span class='notice'> [M] has slashed [src]!</span>")
	playsound(src.loc, 'sound/weapons/slice.ogg', 25, 1, -1)
	update_health(rand(M.melee_damage_lower,M.melee_damage_upper))

/obj/machinery/m56d_hmg/proc/load_into_chamber()
	if(in_chamber) return 1 //Already set!
	if(rounds == 0)
		update_icon() //make sure the user can see the lack of ammo.
		return 0 //Out of ammo.

	in_chamber = rnew(/obj/item/projectile, loc) //New bullet!
	in_chamber.generate_bullet(ammo)
	return 1

/obj/machinery/m56d_hmg/proc/process_shot()
	set waitfor = 0

	if(isnull(target)) return //Acqure our victim.

	if(!ammo)
		update_icon() //safeguard.
		return

	if(burst_fire && target && !last_fired)
		if(rounds > 3)
			for(var/i = 1 to 3)
				is_bursting = 1
				fire_shot()
				sleep(2)
			spawn(0)
				last_fired = 1
			spawn(fire_delay)
				last_fired = 0
		else
			burst_fire = 0
		is_bursting = 0

	if(!burst_fire && target && !last_fired)
		fire_shot()

	target = null

/obj/machinery/m56d_hmg/proc/fire_shot() //Bang Bang
	if(!ammo) return //No ammo.
	if(last_fired) return //still shooting.

	if(!is_bursting)
		last_fired = 1
		spawn(fire_delay)
			last_fired = 0

	var/turf/T = get_turf(src)
	var/turf/U = get_turf(target)
	var/scatter_chance = 5
	if(burst_fire) scatter_chance = 10 //Make this sucker more accurate than the actual Sentry, gives it a better role.

	if(prob(scatter_chance))
		U = locate(U.x + rand(-1,1),U.y + rand(-1,1),U.z)

	if (!istype(T) || !istype(U))
		return

	if(load_into_chamber() == 1)
		if(istype(in_chamber,/obj/item/projectile))
			in_chamber.original = target
			in_chamber.dir = src.dir
			in_chamber.def_zone = pick("chest","chest","chest","head")
			playsound(src.loc, 'sound/weapons/gunshot_rifle.ogg', 100, 1)
			in_chamber.fire_at(U,src,null,ammo.max_range,ammo.shell_speed)
			if(target)
				var/angle = round(Get_Angle(src,target))
				muzzle_flash(angle)
			in_chamber = null
			rounds--
			if(!rounds)
				visible_message("<span class='notice'> \icon[src] The M56D beeps steadily and its ammo light blinks red. </span>")
				playsound(src.loc, 'sound/weapons/smg_empty_alarm.ogg', 50, 1)
				update_icon() //final safeguard.
	return

// New proc for MGs and stuff replaced handle_manual_fire(). Same arguements though, so alls good.
/obj/machinery/m56d_hmg/handle_click(var/mob/living/carbon/human/user, var/atom/A, var/params)
	if(!operator) return 0
	if(operator != user) return 0
	if(istype(A,/obj/screen)) return 0
	if(is_bursting) return
	if(get_dist(user,src) > 1 || user.stat)
		user.client.view = world.view
		user.machine = null
		operator = null
		return 0

	target = A
	if(!istype(target))
		return 0

	if(target.z != src.z || target.z == 0 || src.z == 0 || isnull(operator.loc) || isnull(src.loc))
		return 0

	if(get_dist(target,src.loc) > 15)
		return 0

	var/list/modifiers = params2list(params) //Only single clicks.
	if(modifiers["middle"] || modifiers["shift"] || modifiers["alt"] || modifiers["ctrl"])	return 0

		// Ok this is the issue here. We need it to be capable of firing rounds at say maybe 160*
		// So we gotta change this. We're going rely on inequalities since those are sorta better (no idea coding wise).
		// The way I'm going to do it won't allow 180* fire since shooting sideways is dumb.
		// But with this system we should be able to shoot anywhere in almost a 180* area, but not actually sideways.
/*		var/dx = target.x - x
		var/dy = target.y - y */
	var/direct

		//There might be a better way to do this, but god knows.
		//It's also 12 AM.
	var/angle = get_dir(src,target)
	if(dir == NORTH && (angle == NORTHEAST || angle == NORTHWEST || angle == NORTH))
		direct = NORTH
	if(dir == SOUTH && (angle == SOUTHEAST || angle == SOUTHWEST || angle == SOUTH))
		direct = SOUTH
	if(dir == EAST && (angle == NORTHEAST || angle == SOUTHEAST || angle == EAST))
		direct = EAST
	if(dir == WEST && (angle == NORTHWEST || angle == SOUTHWEST || angle == WEST))
		direct = WEST

	if(direct == dir && target.loc != src.loc && target.loc != operator.loc)
		process_shot()
		return 1

	return 0

/obj/machinery/m56d_hmg/proc/muzzle_flash(var/angle) // Might as well keep this too.
	if(isnull(angle)) return

	if(prob(65))
		var/layer = MOB_LAYER-0.1

		var/image/reusable/I = rnew(/image/reusable, list('icons/obj/projectiles.dmi',src,"muzzle_flash",layer))
		var/matrix/rotate = matrix() //Change the flash angle.
		rotate.Translate(0,5)
		rotate.Turn(angle)
		I.transform = rotate

		I.flick_overlay(src, 3)

/obj/machinery/m56d_hmg/MouseDrop(over_object, src_location, over_location) //Drag the MG to us to man it.
	if(!ishuman(usr)) return
	var/mob/living/carbon/human/user = usr //this is us
	src.add_fingerprint(usr)
	if((over_object == user && (in_range(src, user) || locate(src) in user))) //Make sure its on ourselves
		if(user.machine == src)
			operator = null
			visible_message("\icon[src] <span class='notice'> [user] decided to let someone else have a go </span>")
			usr << "<span class='notice'> You decided to let someone else have a go on the MG </span>"
			user.machine = null
			user.client.view = world.view
			return
		if(operator) //If there is already a operator then they're manning it.
			user << "Someone's already controlling it."
			return
		else
			if(user.machine) //Make sure we're not manning two guns at once, tentacle arms.
				usr << "You're already manning something!"
				return
			else
				operator = usr //now we are the captain.
				visible_message("\icon[src] <span class='notice'> [user] mans the M56D!</span>")
				usr << "<span class='notice'> You man the gun!</span>"
				user.machine = src
				user.client.view = 12
				return

/obj/machinery/m56d_hmg/CtrlClick(var/mob/user) //Making it possible to toggle burst fire. Perhaps have altclick be the safety on the gun?
	if(!burst_fire) //Unfortunately had to remove the fact that only the gunner could change it, handle_click sorta screws it up.
		visible_message("\icon[src] <span class='notice'> emits a audiable hard click </span>")
		playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
		burst_fire = 1
		return
	else
		visible_message("\icon[src] <span class='notice'> emits a audiable soft click </span>")
		playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
		burst_fire = 0
		return

/obj/machinery/m56d_hmg/mg_turret //Our mapbound version with stupid amounts of ammo.
	name = "M56D Smartgun Nest"
	desc = "A M56D smartgun mounted upon a small reinforced post with sandbags to provide a small machinegun nest for all your defense purpose needs.<span class='notice'>!!DANGER: M56D DOES NOT HAVE IFF FEATURES!!</span>"
	burst_fire = 1
	fire_delay = 2
	rounds = 1500
	rounds_max = 1500
	locked = 1
	flags_atom = RELAY_CLICK
	icon = 'icons/turf/whiskeyoutpost.dmi'
	icon_full = "towergun"
	icon_empty = "towergun"

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
							/obj/item/ammo_magazine/rifle,
							/obj/item/ammo_magazine/rifle,
							/obj/item/ammo_magazine/rifle,
							/obj/item/ammo_magazine/smg/m39,
							/obj/item/ammo_magazine/smg/m39,
							/obj/item/ammo_magazine/smg/m39,
							/obj/item/ammo_magazine/smg/m39,
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
	var/orient = "LEFT" // "RIGHT" changes the dir suffix to "-r"
	var/mob/living/carbon/human/occupant = null
	var/surgery_t = 0 //Surgery timer
	var/surgery = 0 //Are we operating or no? 0 for no, 1 for yes
	var/surgery_mod = 1 //What multiple to increase the surgery timer? This is used for any non-WO maps or events that are done.

	//It uses power
	use_power = 1
	idle_power_usage = 15
	active_power_usage = 450 //Capable of doing various activities

	New()
		..()
		spawn( 5 )
			if(orient == "RIGHT")
				icon_state = "sleeper_0-r"
			return
		return

	allow_drop()
		return 0

	process()
		if (stat & (NOPOWER|BROKEN))
			return

		src.updateUsrDialog()
		return

	proc/surgery_op(mob/living/carbon/M as mob)
		if(M.stat == 2)
			visible_message("[src] buzzes.")
			return
		visible_message("[src] begins to operate, loud audiable clicks lock the pod.")
		surgery = 1
		surgery_t = ((src.occupant.getFireLoss() * 15) + (src.occupant.getToxLoss() * 10) + (src.occupant.getOxyLoss() * 10) + (src.occupant.getBruteLoss() * 15)) * surgery_mod + 20
		sleep(surgery_t * 0.25) //Give our first boost of healing, mainly so they don't die instantly
		M.setOxyLoss(0) //Fix our breathing issues
		M.heal_organ_damage(25,25)
		sleep(surgery_t * 0.25) //Give our first boost of healing, mainly so they don't die instantly
		M.setOxyLoss(0) //Fix our breathing issues
		M.heal_organ_damage(25,25)
		sleep(surgery_t * 0.5) // Make sure we don't get instant heals
		M.setOxyLoss(0) //Fix our breathing issues
		M.adjustToxLoss(-20) // Help out with toxins
		M.eye_blurry = 0 //fix our eyes
		M.eye_blind = 0 //fix our eyes
		M.heal_organ_damage(25,25) // I think it caps out at like roughly 25, its really werid.
		M.heal_organ_damage(25,25)
		M.restore_all_organs()
		for(var/datum/organ/internal/I in M.internal_organs) //Fix the organs
			I.damage = 0
		for(var/datum/organ/external/O in src.occupant.organs) //Remove all the friendly fire.
			for(var/obj/S in O.implants)
				if(istype(S))
					S.loc = src.loc
					O.implants -= S
		M.UpdateDamageIcon()
		sleep(5)
		visible_message("The Med-Pod clicks and opens up revealing a healed human")
		src.go_out()
		src.icon_state = "sleeper_0"
		surgery = 0
		return
//MSD is a nerd, leaving this here for him to find later.

	verb/eject()
		set name = "Eject Med-Pod"
		set category = "Object"
		set src in oview(1)
		if(surgery)
			return
		if(usr.stat != 0)
			return
		src.go_out()
		add_fingerprint(usr)
		return

	verb/toggle_surgery()
		set name = "Enable surgery functions for the Med-Pod"
		set category = "Object"
		set src in oview(1)
		if(surgery)
			return
		if(usr.stat != 0)
			return
		src.surgery_op(src.occupant)
		add_fingerprint(usr)
		return

	verb/move_inside()
		set name = "Enter Med-Pod"
		set category = "Object"
		set src in oview(1)

		if(usr.stat != 0 || !(ishuman(usr) || ismonkey(usr)))
			return

		if(src.occupant)
			usr << "\blue <B>The sleeper is already occupied!</B>"
			return

		visible_message("[usr] starts climbing into the sleeper.", 3)
		if(do_after(usr, 20))
			if(src.occupant)
				usr << "\blue <B>The sleeper is already occupied!</B>"
				return
			usr.stop_pulling()
			usr.client.perspective = EYE_PERSPECTIVE
			usr.client.eye = src
			usr.loc = src
			update_use_power(2)
			src.occupant = usr
			src.icon_state = "sleeper_1"
			if(orient == "RIGHT")
				icon_state = "sleeper_1-r"

			for(var/obj/O in src)
				del(O)
			src.add_fingerprint(usr)
			return
		return

	proc/go_out()
		if(!src.occupant)
			return
		if(src.occupant.client)
			src.occupant.client.eye = src.occupant.client.mob
			src.occupant.client.perspective = MOB_PERSPECTIVE
		src.occupant.loc = src.loc
		src.occupant = null
		update_use_power(1)
		src.icon_state = "sleeper_0"
		if(orient == "RIGHT")
			icon_state = "sleeper_0-r"
		return

	attackby(var/obj/item/weapon/G as obj, var/mob/user as mob)
		if(istype(G, /obj/item/weapon/grab))
			if(!ismob(G:affecting))
				return

			if(src.occupant)
				user << "\blue <B>The Med-Pod is already occupied!</B>"
				return

			visible_message("[user] starts putting [G:affecting:name] into the Med-Pod.", 3)

			if(do_after(user, 20))
				if(src.occupant)
					user << "\blue <B>The Med-Pod is already occupied!</B>"
					return
				if(!G || !G:affecting) return
				var/mob/M = G:affecting
				if(M.client)
					M.client.perspective = EYE_PERSPECTIVE
					M.client.eye = src
				M.loc = src
				update_use_power(2)
				src.occupant = M
				src.icon_state = "sleeper_1"
				if(orient == "RIGHT")
					icon_state = "sleeper_1-r"

				src.add_fingerprint(user)
				del(G)
			return
		return

/////////////////////////////////////////////////////////////

//Auto Doc console that links up to it.
/obj/machinery/autodoc_console
	name = "Med-Pod Console"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeperconsole"
	var/obj/machinery/autodoc/connected = null
	anchored = 1 //About time someone fixed this.
	density = 0
	var/orient = "LEFT" // "RIGHT" changes the dir suffix to "-r"

	use_power = 1
	idle_power_usage = 40

	process()
		if(stat & (NOPOWER|BROKEN))
			return
		src.updateUsrDialog()
		return

	New()
		..()
		spawn( 5 )
			if(orient == "RIGHT")
				icon_state = "sleeperconsole-r"
				src.connected = locate(/obj/machinery/autodoc, get_step(src, EAST))
			else
				src.connected = locate(/obj/machinery/autodoc, get_step(src, WEST))
			return
		return

	attack_hand(mob/user as mob)
		if(..())
			return
		if(stat & (NOPOWER|BROKEN))
			return
		var/dat = ""
		if (!src.connected || (connected.stat & (NOPOWER|BROKEN)))
			dat += "This console is not connected to a Med-Pod or the Med-Pod is non-functional."
		else
			var/mob/living/occupant = src.connected.occupant
			dat += "<font color='blue'><B>Occupant Statistics:</B></FONT><BR>"
			if (occupant)
				var/surgery_t = ((src.connected.occupant.getFireLoss() * 15) + (src.connected.occupant.getToxLoss() * 10) + (src.connected.occupant.getOxyLoss() * 10) + (src.connected.occupant.getBruteLoss() * 15))
				var/t1
				switch(occupant.stat)
					if(0)
						t1 = "Conscious"
					if(1)
						t1 = "<font color='blue'>Unconscious</font>"
					if(2)
						t1 = "<font color='red'>*dead*</font>"
					else
				dat += text("[]\tHealth %: [] ([])</FONT><BR>", (occupant.health > 50 ? "<font color='blue'>" : "<font color='red'>"), occupant.health, t1)
				if(iscarbon(occupant))
					var/mob/living/carbon/C = occupant
					dat += text("[]\t-Pulse, bpm: []</FONT><BR>", (C.pulse == PULSE_NONE || C.pulse == PULSE_THREADY ? "<font color='red'>" : "<font color='blue'>"), C.get_pulse(GETPULSE_TOOL))
				dat += text("[]\t-Brute Damage %: []</FONT><BR>", (occupant.getBruteLoss() < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.getBruteLoss())
				dat += text("[]\t-Respiratory Damage %: []</FONT><BR>", (occupant.getOxyLoss() < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.getOxyLoss())
				dat += text("[]\t-Toxin Content %: []</FONT><BR>", (occupant.getToxLoss() < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.getToxLoss())
				dat += text("[]\t-Burn Severity %: []</FONT><BR>", (occupant.getFireLoss() < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.getFireLoss())
				dat += text("<HR> Surgery Estimate: [] seconds<BR>", (((surgery_t * src.connected.surgery_mod) + 20) * 0.2))
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
		if ((usr.contents.Find(src) || ((get_dist(src, usr) <= 1) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon/ai)))
			usr.set_machine(src)
			if (href_list["refresh"])
				src.updateUsrDialog()
			if (href_list["surgery"])
				src.connected.surgery_op(src.connected.occupant)
				src.updateUsrDialog()
			if (href_list["ejectify"])
				src.connected.eject()
				src.updateUsrDialog()
			src.add_fingerprint(usr)
		return
