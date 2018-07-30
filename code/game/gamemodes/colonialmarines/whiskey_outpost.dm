/datum/game_mode/whiskey_outpost
	name = "Whiskey Outpost"
	config_tag = "Whiskey Outpost"
	required_players 		= 0
	recommended_enemies 	= 0 //Leaving this relic code incase we want to do some extra things with it in the future.
	xeno_bypass_timer 		= 1
	role_instruction		= 1
	roles_for_mode = list(/datum/job/marine/standard/equipped,
					/datum/job/marine/medic/equipped,
					/datum/job/marine/engineer/equipped,
					/datum/job/marine/specialist/equipped,
					/datum/job/marine/smartgunner/equipped,
					/datum/job/marine/leader/equipped,
					/datum/job/civilian/doctor,
					/datum/job/command/commander,
					/datum/job/logistics/tech/maint,
					/datum/job/command/police,
					/datum/job/civilian/synthetic
					)

	flags_round_type	= MODE_NO_LATEJOIN
	latejoin_larva_drop = 0 //You never know

	//var/mob/living/carbon/human/Commander //If there is no Commander, marines wont get any supplies
	//No longer relevant to the game mode, since supply drops are getting changed.
	var/checkwin_counter = 0
	var/finished = 0
	var/has_started_timer = 10 //This is a simple timer so we don't accidently check win conditions right in post-game

	var/spawn_next_wave = 1200 //Spawn first batch at ~15 minutes //200
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

	for(L in landmarks_list)
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
	world << "<span class='round_body'>It is the year 2181 on the planet LV-624, five years before the arrival of the USS Almayer and the 7th 'Falling Falcons' Battalion in the sector</span>"
	world << "<span class='round_body'>The 3rd 'Dust Raiders' Battalion is charged with establishing a USCM prescence in the Tychon's Rift sector</span>"
	world << "<span class='round_body'>[map_tag], one of the Dust Raider bases being established in the sector, has come under attack from unrecognized alien forces</span>"
	world << "<span class='round_body'>With casualties mounting and supplies running thin, the Dust Raiders at [map_tag] must survive for an hour to alert the rest of their battalion in the sector</span>"
	world << "<span class='round_body'>Hold out for as long as you can.</span>"
	world << sound('sound/effects/siren.ogg')

	sleep(50)
	switch(map_locale) //Switching it up.
		if(0)
			command_announcement.Announce("This is Captain Hans Naiche, commander of the 3rd Battalion 'Dust Raiders' forces here on [map_tag]. In our attempts to establish a base on this planet, several of our patrols were wiped out by hostile creatures.  We're setting up a distress call, but we need you to hold [map_tag] in order for our engineers to set up the relay. We're prepping several M402 mortar units to provide fire support. If they overrun your positon, we will be wiped out with no way to call for help. Hold the line or we all die.", "Captain Naich, 3rd Battalion Command, [map_tag] Garrison")

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
		switch(H.mind.assigned_role)
			if("Doctor") //Only get rid of some of the stuff
				for(var/I in H.contents)
					if(istype(I,/obj/item/device/pda/medical))
						cdel(I)
					if(istype(I,/obj/item/clothing/shoes/laceup))
						cdel(I)
			if("Executive Officer") //Wipe their stuff clean. Reequip them later
				for(var/I in H.contents)
					cdel(I)
			if("Military Police")
				for(var/I in H.contents)
					cdel(I)
			if("Maintenance Tech")
				for(var/I in H.contents)
					cdel(I)
		H.loc = picked
	else //Else if we spawned as doctor or commander
		H = new(picked)

	H.key = M.key
	if(H.client) H.client.change_view(world.view)

	if(!H.mind)
		H.mind = new(H.key)

	H.nutrition = rand(325,400)

	//Squad ID and backpack are already spawned in job datum

	//COMMANDER
	var/rand_wep = rand(0,10) //Made spawns for everyone, now we can also have weighted things too!
	var/custom_message = 0 // This is if the role has a special message.
	switch(H.mind.assigned_role)
		if("Commander")
			custom_message = 1
			H.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/mcom(H), WEAR_EAR)
			H.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel(H), WEAR_BACK)
			H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/officer/command(H), WEAR_BODY)
			H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/MP/RO(H), WEAR_JACKET)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marinechief/commander(H), WEAR_FEET)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/cmberet/tan(H), WEAR_HEAD)
			H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/techofficer/commander(H), WEAR_HANDS)
			H.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel(H), WEAR_BACK)
			H.equip_to_slot_or_del(new /obj/item/weapon/claymore/mercsword/commander(H), WEAR_R_HAND)

			H.equip_to_slot_or_del(new /obj/item/storage/belt/gun/mateba/full(H), WEAR_WAIST)
			H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/heavy(H), WEAR_IN_BACK)
			H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/heavy(H), WEAR_IN_BACK)
			H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/heavy(H), WEAR_IN_BACK)

			var/obj/item/card/id/gold/W = new(H)
			W.name = "[M.real_name]'s ID Card (Ground Commander)"
			W.access = get_all_accesses()
			W.assignment = "Ground Commander"
			W.paygrade = "O3"
			W.registered_name = M.real_name
			H.equip_to_slot_or_del(W, WEAR_ID)

			sleep(40)
			if(H)
				H << "________________________"
				H << "<span class='boldnotice'>You are the Dust Raiders Commander!</span>"
				H << "Coordinate your team and prepare defenses."
				H << "Stay alive!"
				H << "Hold the outpost for one hour until the distress beacon can be broadcast to the remaining Dust Raiders!"
				H << "The local population warned you about establishing a base in the jungles of [map_tag]..."
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
			H.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/mcom(H), WEAR_EAR)
			H.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel(H), WEAR_BACK)
			H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/officer/bridge(H), WEAR_BODY)
			H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/leader(H), WEAR_JACKET)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(H), WEAR_FEET)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/beret/marine/logisticsofficer(H), WEAR_HEAD)
			H.equip_to_slot_or_del(new /obj/item/clothing/gloves/yellow(H), WEAR_HANDS)
			H.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel(H), WEAR_BACK) // Make sure we get a backpack now.

			H.equip_to_slot_or_del(new /obj/item/storage/belt/gun/m44/full(H), WEAR_WAIST)
			H.equip_to_slot_or_del(new /obj/item/weapon/gun/shotgun/combat(H), WEAR_R_HAND)
			H.equip_to_slot_or_del(new /obj/item/ammo_magazine/shotgun(H), WEAR_IN_BACK)
			H.equip_to_slot_or_del(new /obj/item/ammo_magazine/shotgun(H), WEAR_IN_BACK)
			H.equip_to_slot_or_del(new /obj/item/ammo_magazine/shotgun(H), WEAR_IN_BACK)
			H.equip_to_slot_or_del(new /obj/item/ammo_magazine/shotgun(H), WEAR_IN_BACK)
			H.equip_to_slot_or_del(new /obj/item/ammo_magazine/shotgun/buckshot(H), WEAR_IN_BACK)
			H.equip_to_slot_or_del(new /obj/item/ammo_magazine/shotgun/buckshot(H), WEAR_IN_BACK)
			H.equip_to_slot_or_del(new /obj/item/storage/firstaid/regular(H), WEAR_IN_BACK)

			var/obj/item/card/id/silver/W = new(H)
			W.name = "[M.real_name]'s ID Card (Honor Guard)"
			W.access = get_all_accesses()
			W.assignment = "Honor Guard"
			W.paygrade = "E9"
			W.registered_name = M.real_name
			H.equip_to_slot_or_del(W, WEAR_ID)

			sleep(40)
			if(H)
				H << "________________________"
				H << "<span class='boldnotice'>You are part of the Battalion Honor Guard!</span>"
				H << "Protect the outpost itself! Make sure the Ground Commander lives!"
				H << "Stay alive!"
				H << "This role does not know engineering or medical tasks(outside of first aid)!"
				H << "Aid your commander, you can use overwatch consoles!"
				H << "________________________"

		if("Synthetic")
			custom_message = 1
			var/obj/item/stack/sheet/metal/MET = new /obj/item/stack/sheet/metal(H)
			MET.amount = 50
			var/obj/item/stack/sheet/plasteel/PLAS = new /obj/item/stack/sheet/plasteel(H)
			PLAS.amount = 50
			var/obj/item/stack/sheet/plasteel/PLAS2 = new /obj/item/stack/sheet/plasteel(H)
			PLAS2.amount = 50
			var/obj/item/stack/sheet/plasteel/PLAS3 = new /obj/item/stack/sheet/plasteel(H)
			PLAS3.amount = 50
			var/obj/item/stack/sheet/metal/MET2 = new /obj/item/stack/sheet/metal(H)
			MET2.amount = 50
			var/obj/item/stack/sheet/metal/MET3 = new /obj/item/stack/sheet/metal(H)
			MET3.amount = 50
			H.equip_to_slot_or_del(PLAS, WEAR_IN_BACK)
			H.equip_to_slot_or_del(PLAS2, WEAR_IN_BACK)
			H.equip_to_slot_or_del(PLAS3, WEAR_IN_BACK)
			H.equip_to_slot_or_del(MET, WEAR_IN_BACK)
			H.equip_to_slot_or_del(MET2, WEAR_IN_BACK)
			H.equip_to_slot_or_del(MET3, WEAR_IN_BACK)
			H.equip_to_slot_or_del(new /obj/item/storage/box/m94(H), WEAR_IN_BACK)

			H.equip_to_slot_or_del(new /obj/item/storage/box/m94(H), WEAR_R_HAND)
			var/obj/item/card/id/W = new(H)
			W.name = "[M.real_name]'s ID Card (Outpost Synthetic)"
			W.access = get_all_accesses()
			W.assignment = "Outpost Synthetic"
			W.paygrade = "E6E"
			W.registered_name = M.real_name
			H.equip_to_slot_or_del(W, WEAR_ID)
			sleep(40)
			if(H)
				H << "________________________"
				H << "<span class='boldnotice'>You are a Dust Raiders Synthetic Unit!</span>"
				H << "Assist the humans as much as possible, only engage in combat if no other option presents itself!"
				H << "Aid your comrades!"
				H << "________________________"

		if("Maintenance Tech")
			custom_message = 1
			H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/engineer(H), WEAR_BODY)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/tech(H), WEAR_HEAD)
			H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine(H), WEAR_JACKET)
			H.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/mcom(H), WEAR_EAR)
			H.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/tech(H), WEAR_BACK)
			H.equip_to_slot_or_del(new /obj/item/storage/belt/utility/full(H), WEAR_WAIST)
			H.equip_to_slot_or_del(new /obj/item/clothing/glasses/welding(H), WEAR_EYES)
			H.equip_to_slot_or_del(new /obj/item/clothing/gloves/yellow(H), WEAR_HANDS)

			//Give this man a bone.
			var/obj/item/stack/sheet/metal/MET = new /obj/item/stack/sheet/metal(H)
			MET.amount = 50
			var/obj/item/stack/sheet/plasteel/PLAS = new /obj/item/stack/sheet/plasteel(H)
			PLAS.amount = 50
			var/obj/item/stack/sheet/plasteel/PLAS2 = new /obj/item/stack/sheet/plasteel(H)
			PLAS2.amount = 50
			var/obj/item/stack/sheet/plasteel/PLAS3 = new /obj/item/stack/sheet/plasteel(H)
			PLAS3.amount = 50
			var/obj/item/stack/sheet/metal/MET2 = new /obj/item/stack/sheet/metal(H)
			MET2.amount = 50
			var/obj/item/stack/sheet/metal/MET3 = new /obj/item/stack/sheet/metal(H)
			MET3.amount = 50
			H.equip_to_slot_or_del(PLAS, WEAR_IN_BACK)
			H.equip_to_slot_or_del(PLAS2, WEAR_IN_BACK)
			H.equip_to_slot_or_del(PLAS3, WEAR_IN_BACK)
			H.equip_to_slot_or_del(MET, WEAR_IN_BACK)
			H.equip_to_slot_or_del(MET2, WEAR_IN_BACK)
			H.equip_to_slot_or_del(MET3, WEAR_IN_BACK)
			H.equip_to_slot_or_del(new /obj/item/storage/box/m94(H), WEAR_IN_BACK)

			H.equip_to_slot_or_del(new /obj/item/storage/box/m94(H), WEAR_R_HAND)

			var/obj/item/card/id/W = new(H)
			W.name = "[M.real_name]'s ID Card (Outpost Engineer)"
			W.access = get_all_accesses()
			W.assignment = "Outpost Engineer"
			W.paygrade = "E6E"
			W.registered_name = M.real_name
			H.equip_to_slot_or_del(W, WEAR_ID)

			sleep(40)
			if(H)
				H << "________________________"
				H << "<span class='boldnotice'>You are a Dust Raiders Engineer!</span>"
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
			H.equip_to_slot_or_del(new /obj/item/map/whiskey_outpost_map(H), WEAR_IN_BACK)
			H.equip_to_slot_or_del(new /obj/item/device/laz_designator(H), WEAR_IN_BACK)

			//Belt and grenades
			var/obj/item/storage/belt/marine/B = new/obj/item/storage/belt/marine(H)
			new /obj/item/ammo_magazine/rifle/m41aMK1(B)
			new /obj/item/ammo_magazine/rifle/m41aMK1(B)
			new /obj/item/ammo_magazine/rifle/m41aMK1(B)
			new /obj/item/ammo_magazine/rifle/m41aMK1(B)
			new /obj/item/explosive/grenade/incendiary(B)
			new /obj/item/explosive/grenade/incendiary(B)
			H.equip_to_slot_or_del(B, WEAR_WAIST)

		//DOCTORS
		if("Doctor") //Then, the doctors
			custom_message = 1
			H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat(H), WEAR_JACKET)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(H), WEAR_FEET)
			H.equip_to_slot_or_del(new /obj/item/device/flashlight/pen(H), WEAR_J_STORE)
			H.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/doc(H), WEAR_EAR)

		//HUD GLASSES (NEEDED)
			H.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/health(H), WEAR_EYES) // added for doctors to see.

		//Combat Lifesaver belt
			H.equip_to_slot_or_del(new /obj/item/storage/belt/combatLifesaver(H), WEAR_WAIST)

		//Advanced Meds
			H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/peridaxon(H), WEAR_L_STORE)
			H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/peridaxon(H), WEAR_R_STORE)

		//Give them some information
			sleep(40)
			if(H)
				H << "________________________"
				H << "<span class='boldnotice'>You are the WO Doctor!</span>"
				H << "Gear up, prepare the medbay and keep your temmates alive."
				H << "Motion trackers have detected movement from local creatures, and they are heading towards the outpost!"
				H << "Hold the outpost for one hour until the signal can be established!"
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
			H.equip_to_slot_or_del(new /obj/item/storage/box/m94(H), WEAR_IN_BACK)
			H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary(H), WEAR_IN_BACK)

			//Utility Belt
			H.equip_to_slot_or_del(new /obj/item/storage/belt/utility/full(H), WEAR_WAIST)

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
			H.equip_to_slot_or_del(new /obj/item/storage/firstaid/regular(H), WEAR_IN_BACK)
			H.equip_to_slot_or_del(new /obj/item/storage/firstaid/adv(H), WEAR_IN_BACK)
			H.equip_to_slot_or_del(new /obj/item/device/defibrillator(H), WEAR_IN_BACK)

			//Medical encryption key
			H.equip_to_slot_or_del(new /obj/item/device/encryptionkey/med(H), WEAR_L_HAND)

			//Combat Lifesaver belt
			H.equip_to_slot_or_del(new /obj/item/storage/belt/combatLifesaver(H), WEAR_WAIST)

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
		//SQUAD SMARTGUNNER
		if("Squad Smartgunner")
			H.equip_to_slot_or_del(new /obj/item/clothing/under/marine(H), WEAR_BODY)
			H.equip_to_slot_or_del(new /obj/item/clothing/tie/storage/webbing(H), WEAR_IN_BACK)

			//Backup SMG Weapon
			H.equip_to_slot_or_del(new /obj/item/storage/large_holster/m39/full(H), WEAR_WAIST)
			H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m39(H), WEAR_IN_BACK)
			H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m39(H), WEAR_IN_BACK)
			H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m39(H), WEAR_IN_BACK)
			H.equip_to_slot_or_del(new /obj/item/storage/box/m56_system, WEAR_R_HAND)

		//SQUAD SPECIALIST
		if("Squad Specialist")
			H.equip_to_slot_or_del(new /obj/item/clothing/under/marine(H), WEAR_BODY)
			H.equip_to_slot_or_del(new /obj/item/clothing/tie/storage/webbing(H), WEAR_IN_BACK)

			//Backup SMG Weapon
			H.equip_to_slot_or_del(new /obj/item/storage/large_holster/m39/full(H), WEAR_WAIST)
			H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m39(H), WEAR_IN_BACK)
			H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m39(H), WEAR_IN_BACK)
			H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m39(H), WEAR_IN_BACK)
			H.equip_to_slot_or_del(new /obj/item/spec_kit, WEAR_R_HAND)

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

					var/obj/item/storage/belt/marine/C = new/obj/item/storage/belt/marine(H)
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

					var/obj/item/storage/belt/marine/D = new/obj/item/storage/belt/marine(H)
					new /obj/item/explosive/grenade/frag(D)
					new /obj/item/explosive/grenade/frag(D)
					new /obj/item/explosive/grenade/frag(D)
					new /obj/item/explosive/grenade/frag(D)
					new /obj/item/explosive/grenade/incendiary(D)
					new /obj/item/explosive/grenade/incendiary(D)
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
					var/obj/item/storage/belt/marine/D = new/obj/item/storage/belt/marine(H)
					new /obj/item/storage/box/m94(D)
					new /obj/item/storage/box/m94(D)
					new /obj/item/storage/box/m94(D)
					H.equip_to_slot_or_del(D, WEAR_WAIST)

		//Every Squad Starts with this:
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94(H), WEAR_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/weapon/combat_knife(H), WEAR_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(H), WEAR_FEET)

		//Find their squad
	if(H.assigned_squad)
		var/squad = H.assigned_squad.color
		var/leader = H.assigned_squad.squad_leader == H

			//Squad Gloves and radio headsets
		switch(squad)
			if(1)//Alpha
					//Radio
				if(leader)
					H.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/alpha/lead(H), WEAR_EAR)
				else
					H.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/alpha(H), WEAR_EAR)
					//Gloves
				if(H.mind.assigned_role != "Squad Engineer")
					H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/alpha(H), WEAR_HANDS)
				else
					H.equip_to_slot_or_del(new /obj/item/clothing/gloves/yellow(H), WEAR_HANDS)

			if(2)//Bravo
					//Radio
				if(leader)
					H.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/bravo/lead(H), WEAR_EAR)
				else
					H.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/bravo(H), WEAR_EAR)
					//Gloves
				if(H.mind.assigned_role != "Squad Engineer")
					H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/bravo(H), WEAR_HANDS)
				else
					H.equip_to_slot_or_del(new /obj/item/clothing/gloves/yellow(H), WEAR_HANDS)

			if(3)//Charlie
					//Radio
				if(leader)
					H.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/charlie/lead(H), WEAR_EAR)
				else
					H.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/charlie(H), WEAR_EAR)
					//Gloves
				if(H.mind.assigned_role != "Squad Engineer")
					H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/charlie(H), WEAR_HANDS)
				else
					H.equip_to_slot_or_del(new /obj/item/clothing/gloves/yellow(H), WEAR_HANDS)

			if(4)//Delta
				//Radio
				if(leader)
					H.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/delta/lead(H), WEAR_EAR)
				else
					H.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/marine/delta(H), WEAR_EAR)
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
		H << "Hold the outpost for one hour until the signal can be established!"
		H << "Ensure the Dust Raiders don't lose their foothold on [map_tag] so you can alert the main forces."
		H << "________________________"

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
					command_announcement.Announce("We're tracking the creatures that wiped out our patrols heading towards your outpost.. Stand-by while we attempt to establish a signal with the USS Alistoun to alert them of these creatures.", "Captain Naich, 3rd Battalion Command, [map_tag] Garrison")
				if(8)
					command_announcement.Announce("Captain Naiche speaking, we've been unsuccessful in establishing offworld communication for the moment. We're prepping our M402 mortars to destroy the inbound xeno force on the main road. Standby for fire support.", "Captain Naich, 3rd Battalion Command, [map_tag] Garrison")
				if(9)
					world << sound('sound/voice/alien_queen_command.ogg')
					command_announcement.Announce("Our garrison forces are reaching seventy percent casualties, we are losing our grip on [map_tag]. It appears that vanguard of the hostile force is still approaching, and most of the other Dust Raider platoons have been shattered. We're counting on you to keep holding.", "Captain Naich, 3rd Battalion Command, [map_tag] Garrison")
				if(12)
					command_announcement.Announce("This is Captain Naiche, we are picking up large signatures inbound, we'll see what we can do to delay them.", "Captain Naich, 3rd Battalion Command, LV-624")
				if(14)
					command_announcement.Announce("This is Captain Naiche, we've established our distress beacon for the USS Alistoun and the remaining Dust Raiders. Hold on for a bit longer while we trasmit our coordinates!", "Captain Naich, 3rd Battalion Command, [map_tag] Garrison")


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
			wave_ticks_passed -= 200 //Wait 20 ticks and try again
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
	var/datum/hive_status/hive = hive_datum[XENO_HIVE_NORMAL]
	if(hive.slashing_allowed != 1)
		hive.slashing_allowed = 1 //Allows harm intent for aliens

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
			spawn_next_wave = 600
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
			spawnxeno += list(/mob/living/carbon/Xenomorph/Lurker,
						/mob/living/carbon/Xenomorph/Spitter)

			spawnxeno -= list(/mob/living/carbon/Xenomorph/Runner,
						/mob/living/carbon/Xenomorph/Runner,
						/mob/living/carbon/Xenomorph/Runner)

		if(4)//Tier II more common
			spawnxeno += list(/mob/living/carbon/Xenomorph/Lurker,
						/mob/living/carbon/Xenomorph/Drone,
						/mob/living/carbon/Xenomorph/Spitter)

		if(5)//Reset the spawns	so we don't drown in xenos again.
			spawn_xeno_num = (count_humans() * 0.5) //Reset

		if(6)//Tier II more common
			spawnxeno += list(/mob/living/carbon/Xenomorph/Lurker,
						/mob/living/carbon/Xenomorph/Spitter)

		if(7)
			spawn_xeno_num = 0

		if(8)
			spawn_next_wave += 1000 //Slow down now, strong castes introduced next wave
			spawn_xeno_num = count_humans()

			spawnxeno -= list(/mob/living/carbon/Xenomorph/Runner,
						/mob/living/carbon/Xenomorph/Runner,
						/mob/living/carbon/Xenomorph/Sentinel)

		if(9)//Ravager and Praetorian Added, Tier II more common, Tier I less common
			spawn_next_wave -= 1000 //Speed it up again. After the period of grace.
			spawnxeno += list(/mob/living/carbon/Xenomorph/Lurker/mature,
						/mob/living/carbon/Xenomorph/Lurker/mature,
						/mob/living/carbon/Xenomorph/Spitter/mature,
						/mob/living/carbon/Xenomorph/Runner/mature,
						/mob/living/carbon/Xenomorph/Runner/mature,
						/mob/living/carbon/Xenomorph/Drone/mature)

			spawnxeno -= list(/mob/living/carbon/Xenomorph/Sentinel)

		if(10)
			spawn_next_wave += 7000
			spawn_xeno_num = count_humans()

		if(11)
			spawnxeno += list(/mob/living/carbon/Xenomorph/Lurker/elite,
						/mob/living/carbon/Xenomorph/Lurker/elite,
						/mob/living/carbon/Xenomorph/Spitter/elite,
						/mob/living/carbon/Xenomorph/Runner/elite,
						/mob/living/carbon/Xenomorph/Runner/elite,
						/mob/living/carbon/Xenomorph/Drone/elite)

			spawnxeno -= list(/mob/living/carbon/Xenomorph/Lurker/mature,
						/mob/living/carbon/Xenomorph/Lurker/mature,
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
						/mob/living/carbon/Xenomorph/Lurker/ancient,
						/mob/living/carbon/Xenomorph/Spitter/ancient,
						/mob/living/carbon/Xenomorph/Praetorian/ancient)

			spawnxeno -= list(/mob/living/carbon/Xenomorph/Crusher,
						/mob/living/carbon/Xenomorph/Lurker/mature,
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
							spawnxeno += list(/mob/living/carbon/Xenomorph/Lurker/ancient,
										/mob/living/carbon/Xenomorph/Spitter/ancient)

				if(6)//Runner madness
					spawn_next_wave += 500//Slow down the next wave
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
					spawn_next_wave += 700//Slow down the next wave
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
					spawn_next_wave += 1200//Slow down the next wave
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
				X.plasma_stored = X.plasma_max
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
				X.plasma_stored = X.plasma_max
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
			if(istype(X) && X.stat != DEAD && X.z != 0 && !istype(X.loc,/turf/open/space)) // If they're connected/unghosted and alive and not debrained
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
		world << "<span class='round_header'>The Xenos have succesfully defended their hive from colonization.</span>"
		world << "<span class='round_body'>Well done, you've secured LV-624 for the hive!</span>"
		world << "<span class='round_body'>It will be another five years before the USCM returns to the Tychon's Rift sector, with the arrival of the 7th 'Falling Falcons' Battalion and the USS Almayer.</span>"
		world << "<span class='round_body'>The xenomorph hive on LV-624 remains unthreatened until then..</span>"
		world << sound('sound/misc/Game_Over_Man.ogg')

		if(round_stats) // Logging to data/logs/round_stats.log
			round_stats << "Marines remaining: [count_humans()]\nRound time: [duration2text()][log_end]\nBig Winner:)"

	else if(finished == 2)
		feedback_set_details("round_end_result","Marines Won")
		world << "<span class='round_header'>Against the onslaught, the marines have survived.</span>"
		world << "<span class='round_body'>The signal rings out to the USS Alistoun, and Dust Raiders stationed elsewhere in Tychon's Rift begin to converge on LV-624.</span>"
		world << "<span class='round_body'>Eventually, the Dust Raiders secure LV-624 and the entire Tychon's Rift sector in 2182, pacifiying it and establishing peace in the sector for decades to come.</span>"
		world << "<span class='round_body'>The USS Almayer and the 7th 'Falling Falcons' Battalion are never sent to the sector and are spared their fate in 2186.</span>"
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
				randomitems = list(/obj/item/storage/box/m94,
								/obj/item/storage/box/m94,
								/obj/item/storage/box/m94,
								/obj/item/storage/box/m94,
								/obj/item/storage/box/m94,
								/obj/item/storage/box/m94,
								/obj/item/storage/box/m94,
								/obj/item/storage/box/m94,
								/obj/machinery/floodlight)

			if(11 to 13) //6% Chance to drop this !FUN! junk.
				crate = new /obj/structure/closet/crate/secure/gear(T)
				choosemax = rand(5,10)
				randomitems = list(/obj/item/facepaint/green,
									/obj/item/facepaint/brown,
									/obj/item/facepaint/black,
									/obj/item/facepaint/sniper,
									/obj/item/storage/box/bodybags,
									/obj/item/storage/fancy/cigarettes/lucky_strikes,
									/obj/item/storage/fancy/cigarettes/lucky_strikes,
									/obj/item/storage/fancy/cigarettes/dromedaryco,
									/obj/item/storage/fancy/cigarettes/dromedaryco,
									/obj/item/tool/lighter/random,
									/obj/item/tool/lighter/random)

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
				spawnitems = list(/obj/item/reagent_container/blood/APlus,
								/obj/item/reagent_container/blood/APlus,
								/obj/item/reagent_container/blood/AMinus,
								/obj/item/reagent_container/blood/AMinus,
								/obj/item/reagent_container/blood/BPlus,
								/obj/item/reagent_container/blood/BPlus,
								/obj/item/reagent_container/blood/BMinus,
								/obj/item/reagent_container/blood/BMinus,
								/obj/item/reagent_container/blood/OPlus,
								/obj/item/reagent_container/blood/OMinus,
								/obj/item/reagent_container/blood/empty,
								/obj/item/reagent_container/blood/empty)

			if(21 to 25)//Advanced meds Crate 10%
				crate = new /obj/structure/closet/crate/medical(T)
				spawnitems = list(/obj/item/storage/firstaid/fire,
								/obj/item/storage/firstaid/regular,
								/obj/item/storage/firstaid/toxin,
								/obj/item/storage/firstaid/o2,
								/obj/item/storage/firstaid/adv,
								/obj/item/bodybag/cryobag,
								/obj/item/bodybag/cryobag,
								/obj/item/reagent_container/hypospray/autoinjector/quickclot,
								/obj/item/reagent_container/hypospray/autoinjector/quickclot,
								/obj/item/reagent_container/hypospray/autoinjector/quickclot,
								/obj/item/storage/belt/combatLifesaver,
								/obj/item/clothing/glasses/hud/health,
								/obj/item/clothing/glasses/hud/health,
								/obj/item/device/defibrillator,
								/obj/item/storage/pill_bottle/peridaxon,
								/obj/item/storage/pill_bottle/imidazoline,
								/obj/item/storage/pill_bottle/alkysine)

			if(26 to 30)//Random Medical Items 10% as well. Made the list have less small junk
				crate = new /obj/structure/closet/crate/medical(T)
				choosemax = rand(10,15)
				randomitems = list(/obj/item/storage/firstaid/fire,
								/obj/item/storage/firstaid/regular,
								/obj/item/storage/firstaid/toxin,
								/obj/item/storage/firstaid/o2,
								/obj/item/storage/firstaid/adv,
								/obj/item/storage/belt/combatLifesaver,
								/obj/item/storage/pill_bottle/tramadol,
								/obj/item/storage/pill_bottle/tramadol,
								/obj/item/storage/pill_bottle/spaceacillin,
								/obj/item/storage/pill_bottle/antitox,
								/obj/item/storage/pill_bottle/kelotane,
								/obj/item/stack/medical/splint,
								/obj/item/stack/medical/splint,
								/obj/item/reagent_container/hypospray/autoinjector/tricord,
								/obj/item/reagent_container/hypospray/autoinjector/tricord,
								/obj/item/reagent_container/hypospray/autoinjector/tricord,
								/obj/item/reagent_container/hypospray/autoinjector/quickclot,
								/obj/item/reagent_container/hypospray/autoinjector/dexP,
								/obj/item/reagent_container/hypospray/autoinjector/Bicard,
								/obj/item/reagent_container/hypospray/autoinjector/Kelo)

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
								/obj/item/attachable/verticalgrip,
								/obj/item/attachable/angledgrip,
								/obj/item/attachable/gyro,
								/obj/item/attachable/bipod,
								/obj/item/attachable/attached_gun/shotgun,
								/obj/item/attachable/attached_gun/flamer,
								/obj/item/attachable/burstfire_assembly)

			if(41 to 45)//Sentry gun drop. 10%
				crate = new /obj/structure/closet/crate/secure/weapon(T)
				spawnitems = list(/obj/item/storage/box/sentry,
								/obj/item/storage/box/sentry,
								/obj/item/storage/box/sentry,
								/obj/item/storage/box/sentry)

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
					playsound(loc, 'sound/effects/meteorimpact.ogg', 25, 1)
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

	playsound(src,'sound/machines/click.ogg', 15, 1)

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

	playsound(src,'sound/machines/click.ogg', 15, 1)

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
		cdel(lasertarget)
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
			cdel(lasertarget)
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
	playsound(src, 'sound/machines/twobeep.ogg', 15, 1)
	user << "You activate the [src]. Now toss it, the supplies will arrive in a moment!"
	sleep(100) //10 seconds should be enough.
	var/turf/T = get_turf(src) //Make sure we get the turf we're tossing this on.
	drop_supplies(T, supply_drop)
	playsound(src,'sound/effects/bamf.ogg', 50, 1)
	cdel(src)
	return

/obj/item/device/whiskey_supply_beacon/verb/switch_supplies()
	set category = "Weapons"
	set name = "Change Ammo Drop"
	set desc = "This will change the supplies that drop."
	set src in usr

	playsound(src,'sound/machines/click.ogg', 15, 1)

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
			spawnitems = list(/obj/item/storage/box/explosive_mines,
							/obj/item/storage/box/explosive_mines,
							/obj/item/storage/box/explosive_mines,
							/obj/item/storage/belt/grenade,
							/obj/item/storage/belt/grenade,
							/obj/item/storage/belt/grenade,
							/obj/item/storage/belt/grenade)
	crate.storage_capacity = 60
	for(var/path in spawnitems)
		new path(crate)

/*LANDMARK SPAWNS*/

//Yes, I know that for landmarks you only need the name for it to work. This is for ease of access when spawning in the landmarks for events.
/obj/effect/landmark/whiskey_outpost
	icon_state = "x3"
	invisibility = 0

/obj/effect/landmark/whiskey_outpost/marine_spawn
	name = "whiskey_outpost_marine"

/obj/effect/landmark/whiskey_outpost/supplydrops
	name = "whiskey_outpost_supply"
	icon_state = "x2"

/obj/effect/landmark/whiskey_outpost/xenospawn
	name = "whiskey_outpost_xeno_1"
	icon_state = "x"

/obj/effect/landmark/whiskey_outpost/xenospawn/two
	name = "whiskey_outpost_xeno_2"

/obj/effect/landmark/whiskey_outpost/xenospawn/three
	name = "whiskey_outpost_xeno_3"

/obj/effect/landmark/whiskey_outpost/xenospawn/four
	name = "whiskey_outpost_xeno_4"


//Landmarks to spawn in more landmarks. Would you like redundancy on your redundancy?
//But in seriousness, this is for admins to spawn in, so they only need to spawn in 4-8 things, instead of 200+, making the delay for round start much shorter for players.
/obj/effect/landmark/wo_spawners
	name = "landmark spawner"
	var/obj/effect/landmark/Landmark = null //The landmarks we'll spawn in
	var/range = 3 //The range we'll spawn these in at.
	invisibility = 0

/obj/effect/landmark/wo_spawners/New()
	..()
	var/num
	for(var/turf/open/O in range(range))
		new Landmark(O)
		num ++
	sleep(5)
	message_admins("[num] [src]\s were spawned in at [loc.loc.name] ([loc.x],[loc.y],[loc.z]). (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[loc.x];Y=[loc.y];Z=[loc.z]'>JMP</a>)")
	cdel()

/obj/effect/landmark/wo_spawners/marines
	name = "marine spawner"
	Landmark = /obj/effect/landmark/whiskey_outpost/marine_spawn
//Keep in mind that this is for ALL marines; spawn in a few of these around.

/obj/effect/landmark/wo_spawners/supplydrops
	name = "supply drop location"
	Landmark = /obj/effect/landmark/whiskey_outpost/supplydrops
	range = 2

/obj/effect/landmark/wo_spawners/xenospawn
	name = "xeno location 1 spawn point"
	Landmark = /obj/effect/landmark/whiskey_outpost/xenospawn

/obj/effect/landmark/wo_spawners/xenospawn2
	name = "xeno location 2 spawn point"
	Landmark = /obj/effect/landmark/whiskey_outpost/xenospawn/two

/obj/effect/landmark/wo_spawners/xenospawn3
	name = "xeno location 3 spawn point"
	Landmark = /obj/effect/landmark/whiskey_outpost/xenospawn/three

/obj/effect/landmark/wo_spawners/xenospawn4
	name = "xeno location 4 spawn point"
	Landmark = /obj/effect/landmark/whiskey_outpost/xenospawn/four
