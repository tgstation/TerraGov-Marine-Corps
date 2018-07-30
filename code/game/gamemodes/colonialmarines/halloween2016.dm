#define EVENT_MAJOR_INTERVAL 	3000 // 5 minutes
#define EVENT_MINOR_INTERVAL 	900 // 1.5 minutes
#define FOG_DELAY_INTERVAL		6000 // 8 minutes
#define BATTLEFIELD_END			36000 // 60 minutes
#define MAX_BLOOD_ATTUNED		5
#define BATTLEFIELD_DEBUG		0

#if BATTLEFIELD_DEBUG
/mob/living/verb/test_major_spooky()
	set name = "Debug Major Event"
	set category = "Battlefield Debug"

	var/datum/game_mode/colonialmarines_halloween_2016/CM = ticker.mode
	var/shuffle1 = input("Select which role to spawn.","1-20") as num
	var/shuffle2 = input("Select which sub-role to spawn.","1-2") as num
	CM.handle_event_major_spooky(shuffle1,shuffle2)
	world << "<span class='debug'>Major event triggered.</span>"

/mob/living/verb/test_minor_spooky()
	set name = "Debug Minor Event"
	set category = "Battlefield Debug"

	var/datum/game_mode/colonialmarines_halloween_2016/CM = ticker.mode
	var/shuffle1 = input("Select which event to play.","1-20") as num
	var/shuffle2 = input("Select which sub event to play.","1-20") as num
	CM.handle_event_minor_spooky(shuffle1,shuffle2)
	world << "<span class='debug'>Minor event triggered.</span>"

/mob/living/verb/test_battle_spawn()
	set name = "Debug Character Spawn"
	set category = "Battlefield Debug"

	var/datum/game_mode/colonialmarines_halloween_2016/CM = ticker.mode

	var/role = input("Select which role to spawn.","Roles") in list("Corporate Liaison","Commander","Squad Leader","Squad Specialist","Squad Smartgunner","Squad Engineer","Squad Medic","Squad Marine")
	if(!role) return
	if(alert("Do you want to be a PMC or Marine?","Preference","Marine","PMC") == "PMC") CM.merc_starting_num = 1
	else CM.merc_starting_num = 0
	var/shuffle1 = input("Select which role to spawn as.","1-20") as num
	var/shuffle2 = input("Select which equipment to spawn with.","1-20") as num
	CM.spawn_battlefield_player(src,role,shuffle1,shuffle2)

#endif
#undef BATTLEFIELD_DEBUG
/datum/game_mode/colonialmarines_halloween_2016
	name = "Nightmare on LV-624"
	config_tag = "Nightmare on LV-624"
	required_players 		= 2 //Need at least one player, but really we need 2.
	latejoin_larva_drop		= 0
	flags_round_type		= MODE_PREDATOR|MODE_NO_LATEJOIN
	role_instruction		= 1
	roles_for_mode = list(/datum/job/marine/standard/equipped,
							/datum/job/marine/medic/equipped,
							/datum/job/marine/engineer/equipped,
							/datum/job/marine/specialist/equipped,
							/datum/job/marine/leader/equipped,
							/datum/job/civilian/liaison/nightmare,
							/datum/job/command/commander/nightmare
							)
	var/lobby_time 			= 0
	var/event_time_major	= FOG_DELAY_INTERVAL
	var/event_time_minor	= EVENT_MINOR_INTERVAL
	var/total_attuned		= MAX_BLOOD_ATTUNED
	var/obj/item/device/omega_array/mcguffin
	var/obj/effect/blocker/fog/fog_blockers[]
	var/turf/marine_spawns[]
	var/turf/pmc_spawns[]
	var/turf/horror_spawns[]
	var/turf/jason_spawns[]
	var/obj/effect/step_trigger/jason/jason_triggers[]
	var/special_spawns[] = list("Jason","Skywalker","Robocop","Rambo","Dutch","Mcclane")

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/* Pre-pre-startup */
/datum/game_mode/colonialmarines_halloween_2016/can_start()
	initialize_special_clamps()
	//initialize_starting_predator_list()
	var/ready_players = num_players() // Get all players that have "Ready" selected
	if(ready_players < required_players)
		world << "<span class='round_setup'>Not enough players to start the game. Aborting.</span>"
		return
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
	world << "<span class='round_setup'>Declaring spawn locations...</span>"

	var/obj/effect/landmark/L
	var/obj/effect/step_trigger/attunement/R
	var/obj/effect/step_trigger/jason/J
	var/obj/effect/blocker/fog/F
	fog_blockers 		= new
	horror_spawns		= new
	pmc_spawns	 		= new
	marine_spawns	 	= new
	jason_spawns		= new
	jason_triggers		= new
	var/turf/blood_idol_spawns[]	= new
	var/turf/pmc_supplies[] 		= new
	var/turf/marine_supplies[] 		= new

	world << "<span class='round_setup'>Attuning blood shrines...</span>"
	//This will set up the various blood attuners to correspond to blood type.
	var/blood_types[] 		= HUMAN_BLOODTYPES
	var/blood_attuners[] 	= new
	var/blood_chosen[]
	var/i
	var/e
	var/t
	for(t = 0, ++t<6)
		i = 0
		e = t == 5 ? 5 : 3
		blood_chosen = new
		if(t == 5) blood_types = HUMAN_BLOODTYPES
		while(++i < e) blood_chosen += pick(blood_types)
		blood_attuners["blood attunement [t]"] = blood_chosen

	world << "<span class='round_setup'>Setting up the mist...</span>"
	//Get all the fog effects in the world.
	for(F in effect_list) fog_blockers += F

	world << "<span class='round_setup'>Generating spawn locations...</span>"
	//Set up landmarks.
	for(L in landmarks_list)
		switch(L.name)
			if("marine start") marine_spawns += L.loc
			if("pmc start") pmc_spawns += L.loc
			if("horror start")
				horror_spawns += L.loc
			if("jason start") jason_spawns += L.loc
			if("jason trigger")
				J = new /obj/effect/step_trigger/jason(L.loc)
				jason_triggers += J
			if("omega control")
				var/obj/item/device/omega_array/control/C = new(L.loc)
				mcguffin = C
			if("marine supplies") marine_supplies += L.loc
			if("pmc supplies") pmc_supplies += L.loc
			if("blood attunement 1","blood attunement 2","blood attunement 3","blood attunement 4","blood attunement 5")
				R = new(L.loc)
				R.b_type = blood_attuners[L.name]
			if("blood idol")
				blood_idol_spawns += L.loc
			else L = null //So we are not deleting all landmarks that still may exist, like observer spawn.
		cdel(L)

	world << "<span class='round_setup'>Generating treasures...</span>"

	if(blood_idol_spawns.len)
		var/turf/T = pick(blood_idol_spawns)
		var/mob/living/simple_animal/hostile/mimic/crate/M = new(T)
		new /obj/item/vampiric(M)
		blood_idol_spawns -= T
		for(T in blood_idol_spawns) //Spawn some empty crates.
			new /obj/structure/closet/crate(T)
			blood_idol_spawns -= T

	world << "<span class='round_setup'>Generating supplies...</span>"
	//Generate supplies.
	create_pmc_supplies(pmc_supplies)
	create_marine_supplies(marine_supplies)

	return 1

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/* Post-setup */
//This happens after create_character, so our mob SHOULD be valid and built by now, but without job data.
//We move it later with transform_survivor but they might flicker at any start_loc spawn landmark effects then disappear.
//Xenos and survivors should not spawn anywhere until we transform them.
/datum/game_mode/colonialmarines_halloween_2016/post_setup()
	set waitfor = 0

	var/datum/hive_status/hive = hive_datum[XENO_HIVE_NORMAL]
	hive.slashing_allowed = 1
	lobby_time = world.time
	//initialize_post_predator_list()

	world << "<span class='round_setup'>Shuffling playable parties...</span>"
	var/mob/M
	var/temp_player_list[] = new
	for(var/i in player_list) temp_player_list += i
	while(temp_player_list.len)
		M = pick(temp_player_list) //We randomzie it a bit.
		temp_player_list -= M
		spawn_battlefield_player(M)

	defer_powernet_rebuild = 2

	sleep (100)
	command_announcement.Announce("An automated distress signal has been received from archaeology site Lazarus Landing, on border world LV-624. Beginning playback.", "[MAIN_SHIP_NAME]")
	world << 'sound/misc/eventhorizon_shiplog.ogg'

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

//This is processed each tick, but check_win is only checked 5 ticks, so we don't go crazy with scanning for mobs.
/datum/game_mode/colonialmarines_halloween_2016/process()

	if(--round_started > 0) return
	if(!round_finished && ++round_checkwin >= 5)
		if(world.time >= (FOG_DELAY_INTERVAL + lobby_time) && fog_blockers.len)
			world << "<span class='boldnotice'>The sickly fog surrounding the area is receding!</span>"
			var/obj/O
			for(O in fog_blockers)
				fog_blockers -= O
				cdel(O)
		if(world.time <= FOG_DELAY_INTERVAL && world.time >= (event_time_minor + lobby_time) )
			handle_event_minor_spooky()
			event_time_minor = world.time + EVENT_MINOR_INTERVAL
		if(world.time >= (event_time_major + lobby_time))
			handle_event_major_spooky()
			event_time_major = world.time + EVENT_MAJOR_INTERVAL
		/*
		 * Note : Find something else to send for next halloween
		if(!total_attuned)
			total_attuned--
			world << "<span class='event_announcement'>All the blood seals are broken! He comes!</span>"
		 */

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
		if(mcguffin && mcguffin.loc) round_finished 											= MODE_BATTLEFIELD_W_MAJOR
		else round_finished 																	= MODE_BATTLEFIELD_W_MINOR
	else if(num_marines && !num_pmcs)
		if(!mcguffin || !mcguffin.loc) round_finished 											= MODE_BATTLEFIELD_M_MAJOR
		else round_finished 																	= MODE_BATTLEFIELD_M_MINOR
	else if(!num_marines && !num_pmcs)	round_finished  										= MODE_BATTLEFIELD_DRAW_DEATH
	else if((world.time > BATTLEFIELD_END + lobby_time))
		if(mcguffin && mcguffin.loc) round_finished												= MODE_BATTLEFIELD_W_MAJOR
		else round_finished 																	= MODE_BATTLEFIELD_DRAW_STALEMATE
	else if(EvacuationAuthority.dest_status == NUKE_EXPLOSION_FINISHED) round_finished 			= MODE_GENERIC_DRAW_NUKE

///////////////////////////////
//Checks if the round is over//
///////////////////////////////
/datum/game_mode/colonialmarines_halloween_2016/check_finished()
	if(round_finished) return 1

//////////////////////////////////////////////////////////////////////
//Announces the end of the game with all relevant information stated//
//////////////////////////////////////////////////////////////////////
///datum/game_mode/colonialmarines_halloween_2016/declare_completion()
//	. = declare_completion_round()

///////////////////////////////////
//Support items and other doodads//
//////////////////////////////////
/obj/effect/landmark/battlefield
	name = "battlefield"
	icon = 'icons/misc/mark.dmi'

/obj/effect/landmark/battlefield/attune
	icon_state = "spawn_event"
/obj/effect/landmark/battlefield/attune/spawn_blood_attunement1
	name = "blood attunement 1"
/obj/effect/landmark/battlefield/attune/spawn_blood_attunement2
	name = "blood attunement 2"
/obj/effect/landmark/battlefield/attune/spawn_blood_attunement3
	name = "blood attunement 3"
/obj/effect/landmark/battlefield/attune/spawn_blood_attunement4
	name = "blood attunement 4"
/obj/effect/landmark/battlefield/attune/spawn_blood_attunement5
	name = "blood attunement 5"
/obj/effect/landmark/battlefield/jason_trigger
	name = "jason trigger"
	icon_state = "spawn_event"

/obj/effect/landmark/battlefield/spawn_marine
	name = "marine start"
	icon_state = "spawn_mob1"
/obj/effect/landmark/battlefield/spawn_pmc
	name = "pmc start"
	icon_state = "spawn_mob2"
/obj/effect/landmark/battlefield/spawn_horrors
	name = "horror start"
	icon_state = "spawn_mob3"

/obj/effect/landmark/battlefield/spawn_jason
	name = "jason start"
	icon_state = "spawn_mob3"

/obj/effect/landmark/battlefield/spawn_mcguffin
	name = "omega control"
	icon_state = "spawn_goal"

/obj/effect/landmark/battlefield/spawn_blood_idol
	name = "blood idol"
	icon_state = "spawn_obj"
/obj/effect/landmark/battlefield/spawn_marine_supplies
	name = "marine supplies"
	icon_state = "spawn_obj"
/obj/effect/landmark/battlefield/spawn_pmc_supplies
	name = "pmc supplies"
	icon_state = "spawn_obj"

/obj/item/device/omega_array
	name = "omega wave destablization array"
	desc = "It's hard to say just what this thing is, but the eggheads at W-Y central must have some reason for creating it."
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
	if(health <= 0)
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
	unacidable = 1

	New()
		..()
		dir  = pick(CARDINAL_DIRS)

	attack_hand(mob/M)
		M << "<span class='notice'>You peer through the fog, but it's impossible to tell what's on the other side...</span>"

	attack_alien(M)
		return attack_hand(M)


/obj/effect/step_trigger/jason/Trigger(mob/living/M)
	if(istype(M) && M.stat != DEAD && (!M.mind || !M.mind.special_role || M.mind.special_role == "PMC"))
		if(ticker && ticker.mode && ticker.mode.type == /datum/game_mode/colonialmarines_halloween_2016)
			var/datum/game_mode/colonialmarines_halloween_2016/T = ticker.mode
			if("Jason" in T.special_spawns) //We do not want to trigger multiple instances of this.
				T.special_spawns -= "Jason" //First one blocks any further atempts.
				var/obj/effect/step_trigger/jason/J
				for(J in T.jason_triggers)
					T.jason_triggers -= J
					cdel(J)
				T.jason_triggers = null
				T.handle_event_major_spooky(0,0,1)

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
				visible_message("<span class='danger'>[M] is torn limb from limb by an unseen force!</span>","<span class='userdanger'>YOU ARE TORN LIMB FROM LIMB!</span>")
				if(!M.stat) M.emote("scream")
				M.gib()
			if(2)
				visible_message("<span class='danger'>[M] is burned alive by some unseen flame!</span>","<span class='userdanger'>YOU ARE ROASTED ALIVE!</span>")
				M.adjust_fire_stacks(rand(6,11))
				M.IgniteMob()
				if(!M.stat) M.emote("scream")
				var/i = 0
				while(++i < 6)
					M.apply_damage(50,BURN,pick(DEFENSE_ZONES_LIVING))
		playsound(src, 'sound/voice/scream_horror1.ogg', 50, 1)

/obj/effect/rune/attunement
	l_color = "#ff0000"
	luminosity = 5

	Dispose()
		. = ..()
		SetLuminosity(0)
		if(ticker && ticker.mode && ticker.mode.type == /datum/game_mode/colonialmarines_halloween_2016)
			var/datum/game_mode/colonialmarines_halloween_2016/T = ticker.mode
			world << "<span class='event_announcement'>A blood seal has broken! [--T.total_attuned ? T.total_attuned : "None"] remain!</span>"

/obj/effect/rune/attunement/attack_hand(mob/living/user) //Special snowflake rune, do not steal 2016.
	user << "<span class='notice'>You touch the rune, feeling it glow beneath your fingertip. It feels warm, somehow pleasant. The rune soon fades and disappears, as you feel a new sense of understanding about the world.</span>"
	user.dna.SetSEState(pick(HULKBLOCK,XRAYBLOCK,FIREBLOCK,TELEBLOCK,NOBREATHBLOCK,REMOTEVIEWBLOCK), 1)
	domutcheck(user,null,MUTCHK_FORCED)
	user.update_mutations()
	cdel(src)

/datum/game_mode/colonialmarines_halloween_2016/proc/spawn_battlefield_player(mob/M,given_role,shuffle_override1,shuffle_override2)
	var/mob/living/carbon/human/H
	var/turf/picked
	var/obj/item/card/id/ID
	var/obj/item/I
	var/shuffle1 = shuffle_override1? shuffle_override1 : rand(1,20)
	var/shuffle2 = shuffle_override2? shuffle_override2 : rand(1,20)

	if(istype(M,/mob/living/carbon/human)) //If we started on Sulaco as squad marine
		if(isYautja(M)) return
		H = M
	else return //If they are not human, they should not be using this proc.

	H.nutrition = rand(325,400)

	//Squad ID and backpack are already spawned in job datum
	given_role = given_role? given_role : H.mind.assigned_role
	switch(given_role) //These guys are assigned outside of everyone else.
		if("Corporate Liaison") //Lead the way, corporate drone!
			if(H.wear_id) ID.access = get_antagonist_pmc_access()//They should have one of these.
			H.mind.special_role = "PMC"
			H.loc = pick(pmc_spawns)
			spawn(40)
				if(H)
					H << "________________________"
					H << "\red <b>You are the [H.mind.assigned_role]!<b>"
					H << "It was just a regular day in the office when the higher up decided to send you in to this hot mess. If only you called in sick that day..."
					H << "The W-Y mercs were hired to protect some important science experiment, and W-Y expects you to keep them in line."
					H << "These are hardened killers, and you write on paper for a living. It won't be easy, that's for damn sure."
					H << "Best to let the mercs do the killing and the dying, but <b>remind them who pays the bills.</b>"
					H << "________________________"
			return
		if("Commander")
			H.loc = pick(marine_spawns)
			spawn(40)
				if(H)
					H << "________________________"
					H << "\red <b>You are the [H.mind.assigned_role]!<b>"
					H << "What the hell did you do to get assigned on this mission? Maybe someone is looking to bump you off for a promotion. Regardless..."
					H << "The marines need a leader to inspire them and lead them to victory. You'll settle for telling them which side of the gun the bullets come from."
					H << "You are a vet, a real badass in your day, but now you're in the thick of it with the grunts. You're plenty sure they are going to die in droves."
					H << "Come hell or high water, <b>you are going to be there for them</b>."
					H << "________________________"
			return

	var/random_primary = 1

	I = H.wear_id
	if(I) H.drop_inv_item_on_ground(I) //Remove it for now, so it doesn't get deleted.
	if(H.contents.len) //We want to get rid of all their items. Everything is generated on the fly during the game mode.
		for(var/i in H.contents)
			if(istype(i,/obj/item))
				H.temp_drop_inv_item(i)
				cdel(i)
	if(I) H.equip_to_slot_or_del(ID, WEAR_ID) //Put it back on.

	//PMC. We want to set up these guys first.
	if(merc_starting_num-- > 0)
		if(pmc_spawns.len) picked = pick(pmc_spawns)

		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/PMC(H), WEAR_EAR)
/*		switch(given_role)
			if("Squad Leader") //Well equipped, great weapons overall.
				H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/PMC/leader(H), WEAR_BODY)
				H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/veteran/PMC/leader(H), WEAR_JACKET)
				H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/PMC/leader(H), WEAR_HEAD)
				H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMC/leader(H), WEAR_FACE)
				H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(H), WEAR_HANDS)
				H.equip_to_slot_or_del(new /obj/item/clothing/shoes/veteran/PMC(H), WEAR_FEET)
				H.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel(H), WEAR_BACK)

				H.equip_to_slot_or_del(new /obj/item/weapon/gun/shotgun/combat(H), WEAR_J_STORE)
				H.equip_to_slot_or_del(new /obj/item/ammo_magazine/shotgun(H), WEAR_IN_BACK)
				H.equip_to_slot_or_del(new /obj/item/ammo_magazine/shotgun/buckshot(H), WEAR_IN_BACK)
				H.equip_to_slot_or_del(new /obj/item/ammo_magazine/shotgun/incendiary(H), WEAR_IN_BACK)
				H.equip_to_slot_or_del(new /obj/item/weapon/baton(H.back), WEAR_IN_BACK)
				H.equip_to_slot_or_del(new /obj/item/device/flashlight(H.back), WEAR_IN_BACK)
				H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/vp78(H), WEAR_WAIST)
				H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp78(H), WEAR_R_STORE)
				H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp78(H.back), WEAR_IN_BACK)
				H.equip_to_slot_or_del(new /obj/item/device/binoculars(H), WEAR_L_STORE)
				H.equip_to_slot_or_del(new /obj/item/explosive/grenade/frag/PMC(H.back), WEAR_IN_BACK)
				H.mind.assigned_role = "PMC Officer"
				random_primary = !random_primary

			if("Squad Specialist")
				random_primary = !random_primary
				switch(shuffle1)
					if(1 to 11) //Smartgunner. Most common. Deadly, but slow.
						H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/PMC(H), WEAR_BODY)
						H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/smartgunner/veteran/PMC(H), WEAR_JACKET)
						H.equip_to_slot_or_del(new /obj/item/clothing/shoes/veteran/PMC(H), WEAR_FEET)
						H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(H), WEAR_HANDS)
						H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/PMC/gunner(H), WEAR_HEAD)
						H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMC/leader(H), WEAR_FACE)
						H.equip_to_slot_or_del(new /obj/item/smartgun_powerpack/snow(H), WEAR_BACK)
						H.equip_to_slot_or_del(new /obj/item/clothing/glasses/night/m56_goggles(H), WEAR_EYES)

						H.equip_to_slot_or_del(new /obj/item/weapon/gun/smartgun/dirty(H.wear_suit), WEAR_J_STORE)
						H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/vp70(H), WEAR_WAIST)
						H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70(H), WEAR_L_STORE)
						H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70(H), WEAR_R_STORE)
						H.mind.assigned_role = "PMC Gunner"

					if(12 to 15) //Sniper option. Uncommon, but incredibly deadly at range.
						H.equip_to_slot_or_del(new /obj/item/clothing/glasses/m42_goggles(H), WEAR_EYES)
						H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/PMC(H), WEAR_BODY)
						H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/veteran/PMC/sniper(H), WEAR_JACKET)
						H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/PMC/sniper(H), WEAR_HEAD)
						H.equip_to_slot_or_del(new /obj/item/clothing/shoes/veteran/PMC(H), WEAR_FEET)
						H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(H), WEAR_HANDS)

						H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/vp70(H), WEAR_WAIST)
						H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70(H), WEAR_R_STORE)
						H.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/sniper/elite(H), WEAR_J_STORE)
						H.equip_to_slot_or_del(new /obj/item/ammo_magazine/sniper/elite(H), WEAR_L_STORE)
						H.mind.assigned_role = "PMC Sharpshooter"*/
/*
					if(16 to 18) //Glass cannon option. Awesome rifle, but stripped down everything. And a katana, because why not?
						H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/PMC(H), WEAR_BODY)
						H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/veteran/PMC(H), WEAR_JACKET)
						H.equip_to_slot_or_del(new /obj/item/clothing/shoes/veteran/PMC(H), WEAR_FEET)

						H.equip_to_slot_or_del(new /obj/item/weapon/katana(H), WEAR_BACK)
						H.equip_to_slot_or_del(new /obj/item/storage/belt/knifepouch(H), WEAR_WAIST)
						H.equip_to_slot_or_del(new /obj/item/device/flashlight(H), WEAR_R_HAND)
						H.equip_to_slot_or_del(new /obj/item/device/binoculars(H), WEAR_L_STORE)
						H.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/m41a/elite(H), WEAR_J_STORE)
						H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap(H), WEAR_R_STORE)
						H.mind.assigned_role = "PMC Ninja"*/
/*
					else //The armor option, random primary, amazing armor. Carries explosives.
						H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/PMC/commando(H), WEAR_BODY)
						H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/veteran/PMC/commando(H), WEAR_JACKET)
						H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC/commando(H), WEAR_HANDS)
						H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/PMC/commando(H), WEAR_HEAD)
						H.equip_to_slot_or_del(new /obj/item/storage/backpack/commando(H), WEAR_BACK)
						H.equip_to_slot_or_del(new /obj/item/clothing/shoes/veteran/PMC/commando(H), WEAR_FEET)
						H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMC(H), WEAR_FACE)
						H.equip_to_slot_or_del(new /obj/item/storage/belt/grenade(H), WEAR_WAIST)

						H.equip_to_slot_or_del(new /obj/item/explosive/plastique(H.back), WEAR_IN_BACK)
						H.equip_to_slot_or_del(new /obj/item/explosive/plastique(H.back), WEAR_IN_BACK)
						H.equip_to_slot_or_del(new /obj/item/storage/firstaid/regular(H.back), WEAR_IN_BACK)
						H.equip_to_slot_or_del(new /obj/item/reagent_container/hypospray/autoinjector/quickclot(H.back), WEAR_IN_BACK)
						H.equip_to_slot_or_del(new /obj/item/device/flashlight(H.back), WEAR_IN_BACK)
						H.mind.assigned_role = "PMC Commando"
						random_primary = !random_primary

			else
				switch(given_role)

					if("Squad Engineer")
						H.equip_to_slot_or_del(new /obj/item/clothing/glasses/welding(H), WEAR_EYES)
						H.equip_to_slot_or_del(new /obj/item/clothing/gloves/yellow(H), WEAR_HANDS)
						H.equip_to_slot_or_del(new /obj/item/storage/belt/utility/full(H), WEAR_WAIST)
						H.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel/eng(H), WEAR_BACK)
						H.equip_to_slot_or_del(new /obj/item/explosive/plastique(H), WEAR_L_STORE)
						var/obj/item/stack/sheet/plasteel/P = new /obj/item/stack/sheet/plasteel(H.back)
						P.amount = 30
						H.equip_to_slot_or_del(P, WEAR_IN_BACK)
						H.equip_to_slot_or_del(new /obj/item/explosive/grenade/frag/PMC(H.back), WEAR_IN_BACK)
						H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary(H.back), WEAR_IN_BACK)
						H.mind.assigned_role = "PMC Mechanic" */
					/*if("Squad Medic")
						H.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/health(H), WEAR_EYES)
						H.equip_to_slot_or_del(new /obj/item/clothing/gloves/latex(H), WEAR_HANDS)
						H.equip_to_slot_or_del(new /obj/item/storage/belt/combatLifesaver(H), WEAR_WAIST)
						H.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel/med(H), WEAR_BACK)
					//	H.equip_to_slot_or_del(new /obj/item/reagent_container/hypospray/autoinjector/quickclot(H), WEAR_L_STORE)
						H.equip_to_slot_or_del(new /obj/item/reagent_container/hypospray/autoinjector/Oxycodone(H), WEAR_L_STORE)
						H.equip_to_slot_or_del(new /obj/item/storage/firstaid/regular(H.back), WEAR_IN_BACK)
						H.equip_to_slot_or_del(new /obj/item/storage/firstaid/adv(H.back), WEAR_IN_BACK)
						H.equip_to_slot_or_del(new /obj/item/device/defibrillator(H.back), WEAR_IN_BACK)
						H.equip_to_slot_or_del(new /obj/item/bodybag(H.back), WEAR_IN_BACK)
						H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/inaprovaline(H.back), WEAR_IN_BACK)
						H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/tramadol(H.back), WEAR_IN_BACK)
						H.mind.assigned_role = "PMC Triage" */
				/*	else
						H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(H), WEAR_HANDS)
						if(prob(60)) //Chance of secondary for combat troops.
							H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/vp70(H), WEAR_WAIST)
							H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70(H), WEAR_L_STORE)
						else if (prob(35))
							H.equip_to_slot_or_del(new /obj/item/storage/belt/knifepouch(H), WEAR_WAIST)
						H.mind.assigned_role = "PMC Standard"
				H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/PMC(H), WEAR_BODY)
				H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/veteran/PMC(H), WEAR_JACKET)
				if(prob(65)) H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/PMC(H), WEAR_HEAD)
				if(prob(65)) H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMC(H), WEAR_FACE)
				H.equip_to_slot_or_del(new /obj/item/clothing/shoes/veteran/PMC(H), WEAR_FEET) */
/*
		if(random_primary)
			switch(shuffle2) //Random primary. Secondaries are either pre-selected, or random for standards.
				if(1 to 11)
					H.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/m39/elite(H), WEAR_J_STORE)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m39/ap(H), WEAR_R_STORE)
				if(12,15)
					H.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/p90(H), WEAR_J_STORE)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/p90(H), WEAR_R_STORE)
				if(16,18)
					H.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/lmg(H), WEAR_J_STORE)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/lmg(H), WEAR_R_STORE)
				else
					H.equip_to_slot_or_del(new /obj/item/weapon/gun/revolver/mateba(H), WEAR_J_STORE)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/revolver/mateba(H), WEAR_R_STORE)

		ID = H.wear_id ? H.wear_id : new(H)
		ID.assignment = H.mind.assigned_role
		ID.registered_name = H.real_name
		ID.name = "[H.real_name]'s ID Card ([ID.assignment])"
		ID.icon_state = "centcom"
		ID.access = get_antagonist_pmc_access()
		H.equip_to_slot_or_del(ID, WEAR_ID)
		H.mind.special_role = "PMC"
		H.mind.role_alt_title = H.mind.assigned_role
		H.mind.role_comm_title = "W-Y"
		spawn(40)
			if(H)
				H << "________________________"
				H << "\red <b>You are the [H.mind.assigned_role]!<b>"
				H << "We have a new mission for you. The USCM is coming to investigate one of our blacksites, and we require your services."
				H << "Make sure you keep the Colonial Marines from tampering with our equipment. It is very, very expensive, and will be hard to replace."
				H << "As usual, you will be handsomely rewarded upon completion of this mission. Should you fail, we will deny our involvement."
				H << "Hold out for an hour, and your job is finished. It goes without saying, <b>do not let us down.</b>"
				H << "________________________"*/

	//SQUADS
	else
		if(marine_spawns.len) picked = pick(marine_spawns)

		var/obj/item/clothing/tie/storage/webbing/W
		var/obj/item/clothing/under/U

		switch(given_role)
			if("Squad Leader")
				U = new /obj/item/clothing/under/marine(H)
				H.equip_to_slot_or_del(U, WEAR_BODY)
				W = new()
				W.on_attached(U, H)
				U.hastie = W

				H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/leader(H), WEAR_HEAD)
				H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/leader(H), WEAR_JACKET)
				H.equip_to_slot_or_del(new /obj/item/storage/large_holster/machete/full(H), WEAR_BACK)
				H.equip_to_slot_or_del(new /obj/item/storage/belt/gun/m44/full(H), WEAR_WAIST)

				H.equip_to_slot_or_del(new /obj/item/device/binoculars(H), WEAR_L_STORE)

			if("Squad Engineer")
				U = new /obj/item/clothing/under/marine/engineer(H)
				H.equip_to_slot_or_del(U, WEAR_BODY)
				W = new()
				W.on_attached(U, H)
				U.hastie = W

				H.equip_to_slot_or_del(new /obj/item/clothing/glasses/welding(H), WEAR_EYES)
				H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/tech(H), WEAR_HEAD)
				H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine(H), WEAR_JACKET)
				I = H.gloves
				H.temp_drop_inv_item(I)
				cdel(I)
				H.equip_to_slot_or_del(new /obj/item/clothing/gloves/yellow(H), WEAR_HANDS)
				H.equip_to_slot_or_del(new /obj/item/storage/belt/utility/full(H), WEAR_WAIST)
				if(prob(50)) H.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/tech(H), WEAR_BACK)
				else H.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel/tech(H), WEAR_BACK)
				var/obj/item/stack/sheet/metal/P = new /obj/item/stack/sheet/metal(H.back)
				P.amount = 50
				H.equip_to_slot_or_del(P, WEAR_IN_BACK)
				P = new(H.back)
				H.equip_to_slot_or_del(P, WEAR_IN_BACK)

				H.equip_to_slot_or_del(new /obj/item/explosive/plastique(H.back), WEAR_IN_BACK)
				H.equip_to_slot_or_del(new /obj/item/explosive/grenade/frag(H.back), WEAR_IN_BACK)
				H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary(H.back), WEAR_IN_BACK)
				H.equip_to_slot_or_del(new /obj/item/device/multitool(H.back), WEAR_L_STORE)
				H.equip_to_slot_or_del(new /obj/item/device/encryptionkey/engi(H), WEAR_R_STORE)

			if("Squad Medic")
				H.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/health(H), WEAR_EYES)
				U = new /obj/item/clothing/under/marine/medic(H)
				H.equip_to_slot_or_del(U, WEAR_BODY)
				W = new()
				W.on_attached(U, H)
				U.hastie = W

				H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/medic(H), WEAR_HEAD)
				H.equip_to_slot_or_del(new /obj/item/clothing/mask/surgical(H), WEAR_FACE)
				H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine(H), WEAR_JACKET)
				H.equip_to_slot_or_del(new /obj/item/storage/belt/combatLifesaver(H), WEAR_WAIST)
				H.equip_to_slot_or_del(new /obj/item/reagent_container/hypospray/autoinjector/dexP(H), WEAR_WAIST)

				if(prob(50)) H.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/medic(H), WEAR_BACK)
				else H.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel/medic(H), WEAR_BACK)

				H.equip_to_slot_or_del(new /obj/item/reagent_container/hypospray/autoinjector/tricord(H.back), WEAR_IN_BACK)
				H.equip_to_slot_or_del(new /obj/item/storage/firstaid/regular(H.back), WEAR_IN_BACK)
				H.equip_to_slot_or_del(new /obj/item/storage/firstaid/adv(H.back), WEAR_IN_BACK)
				H.equip_to_slot_or_del(new /obj/item/device/defibrillator(H.back), WEAR_IN_BACK)
				H.equip_to_slot_or_del(new /obj/item/bodybag(H.back), WEAR_IN_BACK)
				H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/inaprovaline(H.back), WEAR_IN_BACK)
				H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/tramadol(H.back), WEAR_IN_BACK)

				H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/spaceacillin(H.back), WEAR_L_STORE)
				H.equip_to_slot_or_del(new /obj/item/device/encryptionkey/med(H), WEAR_R_STORE)

			if("Squad Specialist")
				U = new /obj/item/clothing/under/marine(H)
				H.equip_to_slot_or_del(U, WEAR_BODY)
				W = new()
				W.on_attached(U, H)
				U.hastie = W
				random_primary = !random_primary
				switch(shuffle1)
					if(1 to 11) //Smartgunner. Has an okay secondary and some grenades. Same as the classic specs in Aliens.
						H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/specrag(H), WEAR_HEAD)
						H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/smartgunner(H), WEAR_JACKET)
						H.equip_to_slot_or_del(new /obj/item/smartgun_powerpack(H), WEAR_BACK)
						H.equip_to_slot_or_del(new /obj/item/clothing/glasses/night/m56_goggles(H), WEAR_EYES)

						new /obj/item/explosive/grenade/frag(W.hold)
						new /obj/item/explosive/grenade/frag/m15(W.hold)
						new /obj/item/explosive/grenade/incendiary(W.hold)

						H.equip_to_slot_or_del(new /obj/item/weapon/gun/smartgun(H), WEAR_J_STORE)
						H.equip_to_slot_or_del(new /obj/item/storage/belt/gun/m4a3/full(H), WEAR_WAIST)
						H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/incendiary(H), WEAR_L_STORE)
						H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/ap(H), WEAR_R_STORE)

					if(12 to 15) //SADAR. the most popular choice, but also pretty damn deadly.
						H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine(H), WEAR_HEAD)
						H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine(H), WEAR_JACKET)
						H.equip_to_slot_or_del(new /obj/item/storage/backpack/marine(H), WEAR_BACK)
						H.equip_to_slot_or_del(new /obj/item/storage/belt/gun/m44/full(H), WEAR_WAIST)

						new /obj/item/explosive/plastique(W.hold)
						new /obj/item/explosive/plastique(W.hold)
						new /obj/item/reagent_container/hypospray/autoinjector/tricord(W.hold)
						H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket(H.back), WEAR_IN_BACK)
						H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/ap(H.back), WEAR_IN_BACK)
						H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/ap(H.back), WEAR_IN_BACK)
						H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/wp(H.back), WEAR_IN_BACK)
						H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/wp(H.back), WEAR_IN_BACK)
						H.equip_to_slot_or_del(new /obj/item/explosive/grenade/frag(H), WEAR_L_STORE)
						H.equip_to_slot_or_del(new /obj/item/weapon/gun/launcher/rocket(H), WEAR_J_STORE)

					if(16 to 18) //Sniper. Gets the marksman kit.
						H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/durag/jungle(H), WEAR_HEAD)
						H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/sniper/jungle(H), WEAR_JACKET)
						H.equip_to_slot_or_del(new /obj/item/clothing/glasses/m42_goggles(H), WEAR_EYES)
						H.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/smock(H), WEAR_BACK)
						H.equip_to_slot_or_del(new /obj/item/storage/large_holster/m39/full(H), WEAR_WAIST)

						new /obj/item/ammo_magazine/sniper(W.hold)
						new /obj/item/ammo_magazine/sniper(W.hold)
						new /obj/item/ammo_magazine/sniper/incendiary(W.hold)
						H.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/sniper/M42A/jungle(H), WEAR_J_STORE)
						H.equip_to_slot_or_del(new /obj/item/facepaint/sniper(H.back), WEAR_IN_BACK)
						H.equip_to_slot_or_del(new /obj/item/bodybag/tarp(H.back), WEAR_IN_BACK)
						H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m39(H.back), WEAR_IN_BACK)
						H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m39(H.back), WEAR_IN_BACK)
						H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m39(H.back), WEAR_IN_BACK)
						H.equip_to_slot_or_del(new /obj/item/device/binoculars(H), WEAR_L_STORE)

					else//Armor + machete, for when you just want to really stay alive. Random primary.
						H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/specialist(H), WEAR_HEAD)
						H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/specialist(H), WEAR_JACKET)
						I = H.gloves
						H.temp_drop_inv_item(I)
						cdel(I)
						H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/specialist(H), WEAR_HANDS)
						H.equip_to_slot_or_del(new /obj/item/storage/large_holster/machete/full(H), WEAR_BACK)
						H.equip_to_slot_or_del(new /obj/item/storage/belt/grenade(H), WEAR_WAIST)

						H.equip_to_slot_or_del(new /obj/item/device/flashlight(H), WEAR_L_STORE)
						random_primary = !random_primary

			//SQUAD MARINE
			else
				H.equip_to_slot_or_del(new /obj/item/clothing/under/marine(H), WEAR_BODY)
				H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine(H), WEAR_HEAD)
				H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine(H), WEAR_JACKET)
				H.equip_to_slot_or_del(new /obj/item/storage/belt/marine(H), WEAR_WAIST)
				if(prob(65))
					H.equip_to_slot_or_del(new /obj/item/storage/backpack/marine(H), WEAR_BACK)
					if(prob(50))
						H.equip_to_slot_or_del(new /obj/item/weapon/gun/revolver/m44(H.back), WEAR_IN_BACK)
						H.equip_to_slot_or_del(new /obj/item/ammo_magazine/revolver(H), WEAR_R_STORE)
					else
						H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/m4a3(H.back), WEAR_IN_BACK)
						H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol(H), WEAR_R_STORE)

		var/obj/item/clothing/shoes/marine/B = new(H)
		H.equip_to_slot_or_del(B, WEAR_FEET)
		//Knife
		if(prob(65))
			var/obj/item/weapon/combat_knife/K = new(B)
			B.knife = K
			B.update_icon()

		//Set Random Weapon and Ammo
		U = H.w_uniform
		if(random_primary)
			switch(shuffle2)
				if(1 to 11)//M41a
					H.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/m41a(H), WEAR_J_STORE)
					if(istype(H.belt, /obj/item/storage/belt/marine))
						new /obj/item/ammo_magazine/rifle(H.belt)
						new /obj/item/ammo_magazine/rifle(H.belt)
						new /obj/item/ammo_magazine/rifle(H.belt)
					else if(W) //If they have webbing on, they have room for this.
						new /obj/item/ammo_magazine/rifle(W.hold)
						new /obj/item/ammo_magazine/rifle(W.hold)
						new /obj/item/ammo_magazine/rifle(W.hold)
					else //Too bad.
						H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle(H), WEAR_R_HAND)

				if(12 to 15)
					if(istype(H.back, /obj/item/storage/backpack/marine))
						H.equip_to_slot_or_del(new /obj/item/weapon/gun/shotgun/pump(H), WEAR_J_STORE)
						H.equip_to_slot_or_del(new /obj/item/ammo_magazine/shotgun(H.back), WEAR_IN_BACK)
					else
						H.equip_to_slot_or_del(new /obj/item/storage/large_holster/m37/full(H), WEAR_BACK)
						H.equip_to_slot_or_del(new /obj/item/ammo_magazine/shotgun(H), WEAR_R_HAND)
				if(16 to 18)
					H.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/m39(H), WEAR_J_STORE)
					if(istype(H.belt, /obj/item/storage/belt/marine))
						new /obj/item/ammo_magazine/smg/m39(H.belt)
						new /obj/item/ammo_magazine/smg/m39(H.belt)
						new /obj/item/ammo_magazine/smg/m39(H.belt)
					else if(W)
						new /obj/item/ammo_magazine/smg/m39(W.hold)
						new /obj/item/ammo_magazine/smg/m39(W.hold)
						new /obj/item/ammo_magazine/smg/m39(W.hold)
					else
						H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m39(H), WEAR_R_HAND)
				else
					H.equip_to_slot_or_del(new /obj/item/weapon/gun/flamer(H), WEAR_J_STORE)
					if(istype(H.back, /obj/item/storage/backpack/marine))
						H.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank(H.back), WEAR_IN_BACK)
						H.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank(H.back), WEAR_IN_BACK)
					else
						H.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank(H), WEAR_R_HAND)
					if(W)
						new /obj/item/explosive/grenade/phosphorus(W.hold)
						new /obj/item/explosive/grenade/phosphorus(W.hold)
						new /obj/item/explosive/grenade/phosphorus(W.hold)
					else if(H.belt)
						new /obj/item/explosive/grenade/phosphorus(H.belt)
						new /obj/item/explosive/grenade/phosphorus(H.belt)
						new /obj/item/explosive/grenade/phosphorus(H.belt)
		//Give them some information
		spawn(40)
			if(H)
				H << "________________________"
				H << "\red <b>You are the [H.mind.assigned_role]!<b>"
				H << "Gear up, maggot! You have been dropped off in this God-forsaken place to complete some wetworks for Uncle Sam! Not even your mother knows that you're here!"
				H << "Some W-Y mercs are camping out north of the colony, and they got some doo-hickie doomsday device they are planning to use. Make sure they don't!"
				H << "Wipe them out and destroy their tech! The [MAIN_SHIP_NAME] will maintain radio silence for the duration of the mission!"
				H << "You've got an hour. And watch out... That colony ain't right, it ain't right at all. <b>DISMISSED!</b>"
				H << "________________________"

	H.loc = picked

	return H

/datum/game_mode/colonialmarines_halloween_2016/proc/handle_event_minor_spooky(shuffle_override1,shuffle_override2)
	set waitfor = 0

	var/shuffle1 = shuffle_override1? shuffle_override1 : rand(1,20)
	var/shuffle2 = shuffle_override2? shuffle_override2 : rand(1,20)

	switch(shuffle1)
		if(1 to 10)
			for(var/mob/M in player_list)
				if(prob(23) && M.stat != DEAD && ishuman(M) && !isYautja(M) && M.mind && (!M.mind.special_role || M.mind.special_role == "PMC"))
					switch(shuffle2)
						if(1 to 11)
							var/phrases[] = list( //The edgiest lyrics in the universe.
								"Sanguis bibimus...",
								"Corpus edibus...",
								"Sanguis bibimus...",
								"Corpus edibus...",
								"Rolle corpus...",
								"Satani...",
								"Ave, ave...",
								"Ave, ave versus Christus...",
								"Ave, ave versus Christus...",
								"Ave Satani...",
								"Satani, Satani, Satani...",
								"Ave, ave Satani...")
							var/dat
							switch(rand(1,5))
								if(1) dat = "<span class='notice'>You hear a male voice in your head, like it's coming from somewhere nearby.</span> "
								if(2) dat = "<span class='notice'>You hear a female chant. You cannot tell where it is coming from.</span> "
								if(3) dat = "<span class='notice'>There is a weird buzzing in your head, like someone is talking...</span> "
								if(4) dat = "<span class='notice'>Did someone say something? Who was that talking just now?</span> "
								if(5) dat = "<span class='notice'>Something is calling you, just around the corner. Who is that?</span> "
							dat += pick("<span class='rose'>[pick(phrases)]</span>")
							M << dat
						if(12 to 16)
							var/spooky_sounds[] = list(
								'sound/hallucinations/behind_you1.ogg',
								'sound/hallucinations/behind_you2.ogg',
								'sound/hallucinations/far_noise.ogg',
								'sound/hallucinations/growl1.ogg',
								'sound/hallucinations/growl2.ogg',
								'sound/hallucinations/growl3.ogg',
								'sound/hallucinations/i_see_you1.ogg',
								'sound/hallucinations/i_see_you2.ogg',
								'sound/hallucinations/im_here1.ogg',
								'sound/hallucinations/im_here2.ogg',
								'sound/hallucinations/look_up1.ogg',
								'sound/hallucinations/look_up2.ogg',
								'sound/hallucinations/over_here1.ogg',
								'sound/hallucinations/over_here2.ogg',
								'sound/hallucinations/over_here3.ogg',
								'sound/hallucinations/turn_around1.ogg',
								'sound/hallucinations/turn_around2.ogg',
								'sound/hallucinations/veryfar_noise.ogg',
								'sound/hallucinations/wail.ogg')
							M << pick(spooky_sounds)
						else
							var/mob/living/carbon/human/H = M
							H.hallucination += 60
		if(11 to 16)
			//Going to create some spooky imagery here.
			//sleep(300)
		else
			for(var/area/A in all_areas)
				if(A.z == 1 && A.requires_power)
					for(var/obj/machinery/light/L in A)
						if(prob(75)) L.flicker(10)
						else if(prob(5)) L.broken()

/datum/game_mode/colonialmarines_halloween_2016/proc/handle_event_major_spooky(shuffle_override1,shuffle_override2,jason_override)
	set waitfor = 0

	var/mob/living/horror
	var/special_role
	var/recruit_msg
	var/entry_sound

	var/shuffle1 = shuffle_override1? shuffle_override1 : rand(1,20)
	var/shuffle2 = shuffle_override2? shuffle_override2 : rand(1,20)

	if(jason_override) shuffle1 = 5

	switch(shuffle1)
		if(1 to 4)
			var/mob/living/carbon/Xenomorph/Ravager/ravenger/R = new(pick(horror_spawns))
			horror = R
			special_role = BE_ALIEN
			recruit_msg = "terrible, fire breathing monster and haunt the living?"
			animation_teleport_spooky_in(R)
		if(5 to 15)
			var/mob/living/carbon/human/H
			var/obj/item/I
			if(jason_override) //Jason, the king of spooks. Comes with a horribly OP machete.
				H = new(pick(jason_spawns))
				H.equip_to_slot_or_del(new /obj/item/clothing/under/gimmick/jason(H), WEAR_BODY, 1)
				H.equip_to_slot_or_del(new /obj/item/clothing/mask/gimmick/jason(H), WEAR_FACE, 1)
				H.equip_to_slot_or_del(new /obj/item/clothing/shoes/jackboots(H), WEAR_FEET, 1)
				H.equip_to_slot_or_del(new /obj/item/clothing/suit/gimmick/jason(H), WEAR_JACKET, 1)
				H.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(H), WEAR_HANDS, 1)
				I = new /obj/item/weapon/claymore/mercsword/machete(H)
				H.equip_to_slot_or_del(I, WEAR_R_HAND)
				I.name = "bloody machete"
				I.desc = "The favored weapon of a supernatural psycopath."
				I.force = 80
				I.edge = 1

			else
				H = new(pick(horror_spawns))
				H.equip_to_slot_or_del(new /obj/item/clothing/under/colonist(H), WEAR_BODY, 1)

				switch(rand(1,5))
					if(1) H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat(H), WEAR_JACKET, 1)
					if(2) H.equip_to_slot_or_del(new /obj/item/clothing/suit/apron(H), WEAR_JACKET, 1)
					if(3) H.equip_to_slot_or_del(new /obj/item/clothing/suit/chef(H), WEAR_JACKET, 1)
					if(4) H.equip_to_slot_or_del(new /obj/item/clothing/suit/apron/overalls(H), WEAR_JACKET, 1)

				if(prob(50)) H.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(H), WEAR_HANDS, 1)

				switch(rand(1,4))
					if(1) H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/plaguedoctor(H), WEAR_FACE, 1)
					if(2) H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas(H), WEAR_FACE, 1)
					if(3) H.equip_to_slot_or_del(new /obj/item/clothing/head/welding, WEAR_HEAD, 1)

				switch(rand(1,4))
					if(1) H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), WEAR_FEET, 1)
					if(2) H.equip_to_slot_or_del(new /obj/item/clothing/shoes/jackboots(H), WEAR_FEET, 1)
					if(3) H.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(H), WEAR_FEET, 1)

				switch(rand(1,5))
					if(1) H.equip_to_slot_or_del(new /obj/item/tool/pickaxe(H), WEAR_R_HAND)
					if(2) H.equip_to_slot_or_del(new /obj/item/weapon/claymore/mercsword/machete(H), WEAR_R_HAND)
					if(3) H.equip_to_slot_or_del(new /obj/item/tool/kitchen/utensil/knife(H), WEAR_R_HAND)
					if(4) H.equip_to_slot_or_del(new /obj/item/tool/kitchen/knife/butcher(H), WEAR_R_HAND)
					if(5) H.equip_to_slot_or_del(new /obj/item/tool/scythe(H), WEAR_R_HAND)
			H.equip_to_slot_or_del(new /obj/item/tool/lighter(H), WEAR_L_STORE) //So they're not always stumbling in the dark. Unless the want to.

			H.set_species("Horror")
			H.dna.ready_dna(H)
			H.mind_initialize()
			H.mind.special_role = "MODE"
			H.mind.assigned_role = "Horror"
			H.sdisabilities |= MUTE //We don't want them chatting up people.
			H.dna.SetSEState(XRAYBLOCK, 1)
			domutcheck(H,null,MUTCHK_FORCED)
			H.update_mutations()
			horror = H
			special_role = BE_SURVIVOR|BE_RESPONDER
			recruit_msg = "a horror and kill the living?"
			//BE_RESPONDER
			animation_teleport_spooky_in(H)
		else
			var/mob/living/carbon/human/H = new(pick(horror_spawns))
			switch(shuffle2)
				if(1) //McClane. The weakest hero that can spawn. Limited inventory and items. Can you blame him? He's bald.
					H.equip_to_slot_or_del(new /obj/item/clothing/under/gimmick/mcclane(H), WEAR_BODY, 1)

					H.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/mp5(H), WEAR_R_HAND)
					H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/b92fs(H), WEAR_L_HAND)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/b92fs(H), WEAR_L_STORE)
					H.equip_to_slot_or_del(new /obj/item/device/radio(H), WEAR_WAIST)

					H.real_name = "John McClane" //BALD BALD BAAAALD
					H.age = 33
					H.r_eyes = 153
					H.g_eyes = 102
					H.b_eyes = 0

				if(2) //Rambo. Great weapons, and generally a badass. No armor though.
					H.equip_to_slot_or_del(new /obj/item/clothing/under/gimmick/rambo(H), WEAR_BODY, 1)
					H.equip_to_slot_or_del(new /obj/item/clothing/shoes/jackboots(H), WEAR_FEET, 1)
					H.equip_to_slot_or_del(new /obj/item/clothing/suit/gimmick/rambo(H), WEAR_JACKET, 1)
					H.equip_to_slot_or_del(new /obj/item/clothing/head/headband/rambo(H), WEAR_HEAD, 1)

					var/obj/item/I = new /obj/item/weapon/combat_knife(H)
					I.name = "survival knife"
					I.desc = "The tool to use when you want to get up close and personal. Not for the faint of heart."
					I.force = 35
					H.equip_to_slot_or_del(I, WEAR_WAIST)
					H.equip_to_slot_or_del(new /obj/item/weapon/gun/launcher/rocket(H), WEAR_BACK)

					H.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/m16(H), WEAR_R_HAND) //TODO: CHANGE
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16(H), WEAR_L_STORE)

					H.real_name = "John 'Raven' Rambo"
					H.age = 39
					H.r_eyes = 102
					H.g_eyes = 51
					H.b_eyes = 0
					H.h_style = "Shoulder-length Hair Alt"
					H.f_style = "5 O'clock Shadow"

				if(3) //Dutch. The most well-armed and powerful of the heroes in terms of offense.
					H.equip_to_slot_or_del(new /obj/item/clothing/under/gimmick/dutch(H), WEAR_BODY, 1)
					H.equip_to_slot_or_del(new /obj/item/clothing/shoes/jackboots(H), WEAR_FEET, 1)
					H.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/gimmick/dutch(H), WEAR_JACKET, 1)
					H.equip_to_slot_or_del(new /obj/item/storage/large_holster/machete/full(H), WEAR_BACK)
					H.equip_to_slot_or_del(new /obj/item/storage/belt/grenade(H), WEAR_WAIST)

					H.equip_to_slot_or_del(new /obj/item/weapon/gun/launcher/rocket/m57a4(H), WEAR_J_STORE)

					var/obj/item/weapon/gun/rifle/m16/G = new(H)
					var/obj/item/attachable/attached_gun/grenade/N = new(G)
					N.Attach(G)
					G.update_attachable(N.slot)

					H.equip_to_slot_or_del(G, WEAR_R_HAND)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16(H), WEAR_L_STORE)

					H.real_name = "Alan 'Dutch' Schaefer"
					H.age = 40
					H.r_eyes = 51
					H.g_eyes = 102
					H.b_eyes = 204
					H.h_style = "Cpl. Dietrich"
					H.f_style = "3 O'clock Shadow"
					H.r_hair = 153
					H.g_hair = 102
					H.b_hair = 51

				if(4) //Robocop. Has great armor and weapon, but otherwise doesn't have a whole lot of equipment. Hard to put down, that's for sure.
					H.equip_to_slot_or_del(new /obj/item/clothing/under/gimmick/robocop(H), WEAR_BODY, 1)
					H.equip_to_slot_or_del(new /obj/item/clothing/shoes/gimmick/robocop(H), WEAR_FEET, 1)
					H.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/gimmick/robocop(H), WEAR_JACKET, 1)
					H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/gimmick/robocop(H), WEAR_HEAD, 1)
					H.equip_to_slot_or_del(new /obj/item/clothing/gloves/gimmick/robocop(H), WEAR_HANDS, 1)

					H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/auto9(H), WEAR_J_STORE)
					H.equip_to_slot_or_del(new /obj/item/device/flashlight/(H), WEAR_WAIST)
					H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/auto9(H), WEAR_L_STORE)

					H.real_name = "RoboCop"
					H.age = 33
				if(5) //Luke. Melee-based, and isn't particularly powerful. Does come with TK since he can use the force.
					H.equip_to_slot_or_del(new /obj/item/clothing/under/gimmick/skywalker(H), WEAR_BODY, 1)
					H.equip_to_slot_or_del(new /obj/item/clothing/shoes/gimmick/skywalker(H), WEAR_FEET, 1)
					H.equip_to_slot_or_del(new /obj/item/clothing/gloves/gimmick/skywalker(H), WEAR_HANDS, 1)

					var/obj/item/weapon/energy/sword/green/LS = new(H)
					H.equip_to_slot_or_del(LS, WEAR_R_HAND)
					LS.name = "green lightsaber"
					LS.desc = "A jedi knight constructed this weapon after losing a duel with his evil father. It was actually pretty dramatic."

					H.real_name = "Luke Skywalker"
					H.age = 23
					H.r_eyes = 51
					H.g_eyes = 102
					H.b_eyes = 204
					H.h_style = "Parted"
					H.r_hair = 162
					H.g_hair = 110
					H.b_hair = 33

			H.equip_to_slot_or_del(new /obj/item/device/flashlight/(H), WEAR_R_STORE)
			H.set_species("Human Hero")
			H.mind_initialize()
			H.mind.special_role = "MODE"
			H.mind.assigned_role = "Action Hero"
			H.dna.ready_dna(H)
			switch(shuffle2) //Have to do this after DNA.
				if(3) //Dutch's robot hand.
					var/datum/limb/O = H.get_limb("r_arm")
					O.status |= LIMB_ROBOT
					O = H.get_limb("r_hand")
					O.status |= LIMB_ROBOT
				if(4) //Robocop is full on half mech.
					for(var/datum/limb/O in H.limbs)
						O.status |= LIMB_ROBOT
					for(var/datum/internal_organ/O in H.internal_organs)
						O.mechanize()
				if(5)
					var/datum/limb/O = H.get_limb("r_hand")
					O.status |= LIMB_ROBOT
					H.dna.SetSEState(TELEBLOCK, 1)
					domutcheck(H,null,MUTCHK_FORCED)
					H.update_mutations()

			H.update_body(0)
			H.update_hair()
			horror = H
			special_role = BE_SURVIVOR|BE_RESPONDER
			recruit_msg = "a hero and fight together with the remaining mortal souls?"
			animation_teleport_magic_in(H)

	var/horror_key
	var/mob/candidate_mob
	var/candidates[] = new	//list of candidate keys
	for(var/mob/dead/observer/G in player_list)
		if(G.client && !G.client.is_afk() && G.client.prefs.be_special & special_role)
			if(!G.can_reenter_corpse || !(G.mind && G.mind.current && G.mind.current.stat != DEAD)) candidates += G

	if(!candidates.len)
		cdel(horror)
		return
	candidates = shuffle(candidates)

	while(!horror_key && candidates.len)
		candidate_mob = pick(candidates)
		if(sd_Alert(candidate_mob, "Would you like to spawn as [recruit_msg]", buttons = list("Yes","No"), duration = 150) == "Yes")
			horror_key = candidate_mob.ckey
		else candidates -= candidate_mob

	if(!horror_key)
		cdel(horror)
		return

	horror.key = horror_key
	if(horror.client) horror.client.change_view(world.view)
	horror.mind.key = horror.key

	world << "<span class='event_announcement'>An otherwordly presence is reaching through the fabric of reality!</span>"
	sleep(10)
	switch(shuffle1)
		if(1 to 4) horror << "<span class='alien'>You must baptize everything in fire! The world will burn! ROAR!</span>"
		if(5 to 15) horror << "<span class='rough'>You hunger for blood of the living! Murder! Death! KILL!</span>"
		else horror << "<span class='notice'>You have been transported to who-knows where from elsewhere! Fight the horrors of this place!</span>"
	if(entry_sound) world << entry_sound

/datum/game_mode/colonialmarines_halloween_2016/proc/generate_supply_crate(turf/supply_spawn[], supply_manifest[], crate_name = "supplies", crate_desc = "A crate of supplies. Surely the contents will help, somehow.")
	var/turf/spawn_point = pick(supply_spawn)
	supply_spawn -= spawn_point // Let's get rid of it. We don't want boxes to overlap.
	var/obj/structure/closet/crate/C = new(spawn_point)
	var/item_path
	var/i
	for(item_path in supply_manifest)
		i = supply_manifest[item_path]
		while(i--) new item_path(C)
	C.name = crate_name
	C.desc = crate_desc

/datum/game_mode/colonialmarines_halloween_2016/proc/create_pmc_supplies(turf/supply_spawn[])
	var/supply_manifest[] =list(
		/obj/item/attachable/suppressor = 6,
		/obj/item/attachable/reddot = 6,
		/obj/item/explosive/grenade/smokebomb = 4,
		/obj/item/explosive/grenade/phosphorus = 4
		)
/*	generate_supply_crate(supply_spawn,supply_manifest,"special ops crate")

	supply_manifest=list(
		/obj/item/clothing/tie/holster = 4,
		/obj/item/clothing/tie/storage/brown_vest = 6,
		/obj/item/clothing/tie/storage/webbing = 4,
		/obj/item/storage/large_holster/m39 = 5
		)
	generate_supply_crate(supply_spawn,supply_manifest,"extra storage crate")*/

	supply_manifest=list(
		/obj/item/storage/box/explosive_mines/pmc = 2,
		/obj/item/explosive/grenade/frag/PMC = 6,
		/obj/item/explosive/grenade/incendiary = 4,
		/obj/item/explosive/grenade/frag/m15 = 4
		)
	generate_supply_crate(supply_spawn,supply_manifest,"\improper explosives crate (WARNING)", "A crate full of high explosives. Not a good time to have a smoke.")

	supply_manifest=list(
		/obj/item/weapon/gun/flamer = 2,
		/obj/item/ammo_magazine/flamer_tank = 6
		)
	generate_supply_crate(supply_spawn,supply_manifest,"\improper M240 Incinerator crate", "A crate containing a functional flamethrower with spare fuel tanks.")

	supply_manifest=list(
		/obj/item/ammo_magazine/rifle/extended = 3,
		/obj/item/ammo_magazine/rifle/ap = 3,
		/obj/item/ammo_magazine/pistol/vp70 = 5,
		/obj/item/ammo_magazine/revolver/mateba = 5
		)
	generate_supply_crate(supply_spawn,supply_manifest,"ammo crate (assorted)", "A crate containing all sorts of ammunition, surely something useful to be scavenged inside.")

	supply_manifest=list(
		/obj/item/ammo_magazine/smg/m39/extended = 8,
		/obj/item/ammo_magazine/smg/m39/ap = 8
		)
	generate_supply_crate(supply_spawn,supply_manifest,"ammo crate (smg)", "A crate containing SMG ammo. By the looks of it, it isn't standard issue.")

	supply_manifest=list(
		/obj/item/storage/box/wy_mre = 12
		)
	generate_supply_crate(supply_spawn,supply_manifest,"\improper W-Y MRE crate", "A crate containing Weyland-Yutani MREs. An army marches on its stomach, right?")

	supply_manifest=list(
		/obj/item/storage/firstaid/regular = 1,
		/obj/item/storage/firstaid/fire = 1,
		/obj/item/storage/firstaid/toxin = 1,
		/obj/item/storage/firstaid/o2 = 1,
		/obj/item/storage/firstaid/adv = 3,
		/obj/item/reagent_container/glass/bottle/antitoxin = 2,
		/obj/item/reagent_container/glass/bottle/inaprovaline = 2,
		/obj/item/reagent_container/glass/bottle/stoxin = 2,
		/obj/item/storage/box/syringes = 1,
		/obj/item/storage/box/autoinjectors = 1
		)
	generate_supply_crate(supply_spawn,supply_manifest,"medical crate", "A crate containing assorted medical supplies. Hopefully some of the labels should make sense.")

/datum/game_mode/colonialmarines_halloween_2016/proc/create_marine_supplies(turf/supply_spawn[])
	var/supply_manifest[]=list(
		/obj/item/attachable/scope = 2,
		/obj/item/attachable/reddot = 3,
		/obj/item/attachable/magnetic_harness = 4,
		/obj/item/attachable/quickfire = 2,
		/obj/item/attachable/suppressor = 2,
		/obj/item/attachable/bayonet = 4,
		/obj/item/attachable/extended_barrel = 2,
		/obj/item/attachable/heavy_barrel = 1,
		/obj/item/attachable/verticalgrip = 3,
		/obj/item/attachable/gyro = 2,
		/obj/item/attachable/bipod = 1,
		/obj/item/attachable/attached_gun/shotgun = 3,
		/obj/item/attachable/attached_gun/flamer = 3,
		/obj/item/attachable/burstfire_assembly = 1,
		/obj/item/attachable/stock/rifle = 3,
		/obj/item/attachable/stock/smg = 3
		)
	generate_supply_crate(supply_spawn,supply_manifest,"attachables crate (rifle)", "A crate containing assorted attachments for rifles. Unga dunga!")

	supply_manifest=list(
		/obj/item/attachable/reddot = 3,
		/obj/item/attachable/magnetic_harness = 4,
		/obj/item/attachable/quickfire = 1,
		/obj/item/attachable/suppressor = 4,
		/obj/item/attachable/extended_barrel = 2,
		/obj/item/attachable/verticalgrip = 3,
		/obj/item/attachable/burstfire_assembly = 1
		)
	generate_supply_crate(supply_spawn,supply_manifest,"attachables crate (smg)", "A crate containing assorted attachments for SMGs. Unga dunga!")

	supply_manifest=list(
		/obj/item/attachable/reddot = 3,
		/obj/item/attachable/magnetic_harness = 4,
		/obj/item/attachable/bayonet = 4,
		/obj/item/attachable/heavy_barrel = 2,
		/obj/item/attachable/compensator = 3,
		/obj/item/attachable/verticalgrip = 3,
		/obj/item/attachable/gyro = 3,
		/obj/item/attachable/stock/shotgun = 2
		)
	generate_supply_crate(supply_spawn,supply_manifest,"attachables crate (shotgun)", "A crate containing assorted attachments for shotguns. Unga dunga!")

	supply_manifest=list(
		/obj/item/attachable/scope = 1,
		/obj/item/attachable/reddot = 3,
		/obj/item/attachable/suppressor = 1,
		/obj/item/attachable/bayonet = 3,
		/obj/item/attachable/heavy_barrel = 1,
		/obj/item/attachable/compensator = 3,
		/obj/item/attachable/stock/revolver = 3
		)
	generate_supply_crate(supply_spawn,supply_manifest,"attachables crate (sidearm)", "A crate containing assorted attachments for sidearms. Unga dunga!")

/*	supply_manifest=list(
		/obj/item/storage/large_holster/m37 = 5,
		/obj/item/storage/large_holster/machete = 4,
		/obj/item/clothing/tie/storage/webbing = 4,
		/obj/item/storage/belt/gun/m44 = 5,
		/obj/item/storage/belt/gun/m4a3 = 6,
		/obj/item/storage/large_holster/m39 = 3
		)
	generate_supply_crate(supply_spawn,supply_manifest,"extra storage crate") */

	supply_manifest=list(
		/obj/item/ammo_magazine/rifle = 10,
		/obj/item/ammo_magazine/rifle/ap = 4,
		/obj/item/ammo_magazine/rifle/extended = 4
		)
	generate_supply_crate(supply_spawn,supply_manifest,"ammo crate (rifle)", "A crate containing ammunition for rifles. Can't go wrong with standard issue.")
	generate_supply_crate(supply_spawn,supply_manifest,"ammo crate (rifle)", "A crate containing ammunition for rifles. Can't go wrong with standard issue.")
	generate_supply_crate(supply_spawn,supply_manifest,"ammo crate (rifle)", "A crate containing ammunition for rifles. Can't go wrong with standard issue.")

	supply_manifest=list(
		/obj/item/ammo_magazine/smg/m39 = 10,
		/obj/item/ammo_magazine/smg/m39/ap = 4,
		/obj/item/ammo_magazine/smg/m39/extended = 4
		)
	generate_supply_crate(supply_spawn,supply_manifest,"ammo crate (smg)", "A crate containing ammunition for SMGs. Quick and deadly.")

	supply_manifest=list(
		/obj/item/ammo_magazine/shotgun = 8,
		/obj/item/ammo_magazine/shotgun/buckshot = 8,
		/obj/item/ammo_magazine/shotgun/incendiary = 2
		)
	generate_supply_crate(supply_spawn,supply_manifest,"ammo crate (shotgun)", "A crate containing ammunition for shotguns. Quite a blast.")

	supply_manifest=list(
		/obj/item/ammo_magazine/pistol = 8,
		/obj/item/ammo_magazine/pistol/extended = 4,
		/obj/item/ammo_magazine/revolver = 5,
		/obj/item/ammo_magazine/revolver/marksman = 3
		)
	generate_supply_crate(supply_spawn,supply_manifest,"ammo crate (sidearm)", "A crate containing ammunition for sidearms. Having a backup is always nice.")

	supply_manifest=list(
		/obj/item/smartgun_powerpack = 2,
		/obj/item/ammo_magazine/sniper = 2,
		/obj/item/ammo_magazine/sniper/flak = 2,
		/obj/item/ammo_magazine/sniper/incendiary = 1
		)
	generate_supply_crate(supply_spawn,supply_manifest,"specialist ammo crate", "A crate containing ammunition for specialist weapons. A special gift indeed.")

	supply_manifest=list(
		/obj/item/ammo_magazine/rifle/m4ra = 6,
		/obj/item/weapon/gun/rifle/lmg = 2,
		/obj/item/ammo_magazine/rifle/lmg = 2,
		/obj/item/weapon/gun/launcher/m92 = 1
		)
	generate_supply_crate(supply_spawn,supply_manifest,"experimental weapon crate", "A crate containing all sorts of precious, experimental gear. Fancy.")

	supply_manifest=list(
		/obj/item/ammo_magazine/rocket = 3,
		/obj/item/ammo_magazine/rocket/ap = 1,
		/obj/item/ammo_magazine/rocket/wp = 2,
		)
	generate_supply_crate(supply_spawn,supply_manifest,"explosive ammo crate", "A crate containing rockets. Better find a launcher to use those with.")

	supply_manifest=list(
		/obj/item/storage/box/explosive_mines = 3,
		/obj/item/explosive/grenade/frag = 4,
		/obj/item/explosive/grenade/incendiary = 3,
		/obj/item/explosive/grenade/frag/m15 = 3
		)
	generate_supply_crate(supply_spawn,supply_manifest,"\improper explosives crate (WARNING)", "A crate containing all sorts of explosives.")

	supply_manifest=list(
		/obj/item/storage/box/uscm_mre = 12
		)
	generate_supply_crate(supply_spawn,supply_manifest,"\improper MRE crate", "A crate containing USCM MREs. Yuck.")

	supply_manifest=list(
		/obj/item/storage/firstaid/regular = 6,
		/obj/item/storage/firstaid/fire = 2,
		/obj/item/storage/firstaid/toxin = 2,
		/obj/item/storage/firstaid/o2 = 2,
		/obj/item/storage/firstaid/adv = 1,
		/obj/item/reagent_container/glass/bottle/antitoxin = 2,
		/obj/item/reagent_container/glass/bottle/inaprovaline = 2,
		/obj/item/reagent_container/glass/bottle/stoxin = 2,
		/obj/item/storage/box/syringes = 1,
		/obj/item/storage/box/autoinjectors = 1)
	generate_supply_crate(supply_spawn,supply_manifest,"medical crate", "A crate containing assorted medical supplies. Hopefully some of the labels should make sense.")
	generate_supply_crate(supply_spawn,supply_manifest,"medical crate", "A crate containing assorted medical supplies. Hopefully some of the labels should make sense.")

	supply_manifest=list(
		/obj/item/storage/box/m94 = 5,
		/obj/item/facepaint/green = 1,
		/obj/item/facepaint/brown = 1,
		/obj/item/facepaint/black = 1
		)
	generate_supply_crate(supply_spawn,supply_manifest,"misc supplies crate", "A crate containing odds and ends. Hopefully there's something useful in here.")


#undef EVENT_MAJOR_INTERVAL
#undef EVENT_MINOR_INTERVAL
#undef FOG_DELAY_INTERVAL
#undef BATTLEFIELD_END
#undef MAX_BLOOD_ATTUNED







//a vampiric statuette, usually put into a mimic for maximum fun. Perfectly harmless until picked up.
/obj/item/vampiric
	name = "statuette"
	desc = "An odd looking statuette made up of what appears to be carved from crimson stone. It's grinning..."
	icon_state = "statuette1"
	icon = 'icons/obj/items/misc.dmi'
	var/stored_blood = 0
	var/maximum_blood = 0 //How much blood is needed before the thing despawns. 100 for right now.
	var/current_bloodcall = 0
	var/current_consume = 0
	var/interval_bloodcall = 50
	var/interval_consume = 35
	var/shadow_wights[]

	Dispose()
		. = ..()
		for(var/mob/W in shadow_wights) cdel(W)
		shadow_wights = null
		processing_objects -= src

	attack_hand(mob/M) //You dun goofed now, goofy.
		M << "<span class='danger'>The strange thing in your hand begins to move around! You suddenly get a very bad feeling about this!</span>"
		icon_state = "statuette2"
		mouse_opacity = 0 //Can't be interacted with again.
		shadow_wights = new
		processing_objects += src

/obj/item/vampiric/process()
	if(!isturf(loc))
		if(!get_teleport_loc())
			teleport(get_turf(src))
			return

	// Grab some blood from a nearby mob, if possible.
	if(world.time - current_bloodcall > interval_bloodcall)
		var/mob/L[] = new
		var/mob/M
		var/mob/living/carbon/human/H
		for(M in view(7,src))
			H = M
			if(istype(H) && prob(50) && H.stat != DEAD && H.species != "Horror") L += H
		if(L.len) bloodcall(pick(L))
		else
			get_teleport_loc()
			return

	// Suck up any blood, if possible.
	if(world.time - current_consume > interval_consume)
		var/obj/effect/decal/cleanable/blood/B = locate() in range(2,src)
		if(B)
			var/blood_absorbed
			if(istype(B, /obj/effect/decal/cleanable/blood/drip)) blood_absorbed = 0.25
			else
				blood_absorbed = 1
				playsound(loc, 'sound/effects/splat.ogg', 15, 1)
			stored_blood += blood_absorbed
			maximum_blood += blood_absorbed
			current_consume = world.time
			cdel(B,,animation_destruction_fade(B))

	switch(stored_blood)
		if(10 to INFINITY)
			stored_blood -= 10
			new /obj/effect/spider/eggcluster(pick(view(1,src)))
		if(3 to 9)
			if(prob(5))
				stored_blood -= 1
				new /mob/living/simple_animal/hostile/creature(pick(view(1,src)))
				playsound(loc, pick('sound/hallucinations/growl1.ogg','sound/hallucinations/growl2.ogg','sound/hallucinations/growl3.ogg'), 50, 1, 12)
		if(1 to 2)
			if(shadow_wights.len < 5 && prob(5))
				var/obj/effect/shadow_wight/W = new(get_turf(src))
				shadow_wights += W
				W.master_doll = src
				playsound(loc, 'sound/effects/ghost.ogg', 25, 1, 12)
				stored_blood -= 0.1
		if(0.1 to 0.9)
			if(prob(5))
				visible_message("<span class='warning'>\icon[src] [src]'s eyes glow ruby red for a moment!</span>")
				stored_blood -= 0.1

	//Check the shadow wights and auto-remove them if they get too far.
	for(var/mob/W in shadow_wights)
		if(get_dist(W, src) > 10)
			cdel(W)

	if(maximum_blood >= 100) cdel(src,,animation_destruction_long_fade(src))

/obj/item/vampiric/proc/get_teleport_loc()
	var/i = 1
	var/mob/living/carbon/human/H
	while(++i < 4)
		H = pick(player_list)
		if(istype(H) && H.stat != DEAD && H.species != "Horror")
			teleport(get_turf(H))
			return 1

/obj/item/vampiric/proc/teleport(turf/location)
	set waitfor = 0
	var/L = locate(location.x + rand(-1,1), location.y + rand(-1,1), location.z)
	location = L ? L : location
	sleep(animation_teleport_spooky_out(src)) // We need to sleep so that the animation has a chance to finish.
	loc = location
	animation_teleport_spooky_in(src)

/obj/item/vampiric/hear_talk(mob/M)
	..()
	if(ishuman(M) && world.time - current_bloodcall >= interval_bloodcall && M in view(7, src)) bloodcall(M)

/obj/item/vampiric/proc/bloodcall(mob/living/carbon/human/H)
	if(H.species != "Horror")
		playsound(loc, pick('sound/hallucinations/wail.ogg','sound/hallucinations/veryfar_noise.ogg','sound/hallucinations/far_noise.ogg'), 25, 1, 12)

		var/target = pick("chest","groin","head","l_arm","r_arm","r_leg","l_leg","l_hand","r_hand","l_foot","r_foot")
		H.apply_damage(rand(5, 10), BRUTE, target)
		H.visible_message("<span class='danger'>A stream of blood flies out of [H]!</span>","<span class='danger'>The skin on your [parse_zone(target)] feels like it's ripping apart, and a stream of blood flies out!</span>")
		var/obj/effect/decal/cleanable/blood/splatter/animated/B = new(get_turf(H))
		B.target_turf = pick(range(1, src))
		B.blood_DNA = new
		B.blood_DNA[H.dna.unique_enzymes] = H.dna.b_type
		H.blood_volume = max(0, H.blood_volume - rand(25,50))
		animation_blood_spatter(H)
	current_bloodcall = world.time

//animated blood 2 SPOOKY
/obj/effect/decal/cleanable/blood/splatter/animated
	var/turf/target_turf
	var/loc_last_process

	New()
		..()
		processing_objects += src
		loc_last_process = loc

	Dispose()
		animation_destruction_fade(src)
		. = ..()
		processing_objects -= src

/obj/effect/decal/cleanable/blood/splatter/animated/process()
	if(target_turf && loc != target_turf)
		step_towards(src,target_turf)
		if(loc == loc_last_process) target_turf = null
		loc_last_process = loc

		//Leaves drips.
		if(prob(50))
			var/obj/effect/decal/cleanable/blood/drip/D = new(get_turf(src))
			var/i = 0
			while(++i < 3)
				if(prob(50))
					D = new(get_turf(src))
					D.blood_DNA = blood_DNA
	else ..()


/obj/effect/shadow_wight
	name = "shadow wight"
	icon = 'icons/mob/mob.dmi'
	icon_state = "ghost2"
	mouse_opacity = 0
	var/obj/item/vampiric/master_doll

	Dispose()
		. = ..()
		processing_objects -= src
		if(master_doll && master_doll.loc) master_doll.shadow_wights -= src

/obj/effect/shadow_wight/New()
	animation_teleport_spooky_in(src)
	processing_objects += src

/obj/effect/shadow_wight/process()
	if(loc)
		loc = get_turf(pick(orange(1,src)))
		var/mob/living/carbon/M = locate() in loc
		if(M)
			playsound(loc, pick('sound/hallucinations/behind_you1.ogg',\
			'sound/hallucinations/behind_you2.ogg',\
			'sound/hallucinations/i_see_you1.ogg',\
			'sound/hallucinations/i_see_you2.ogg',\
			'sound/hallucinations/im_here1.ogg',\
			'sound/hallucinations/im_here2.ogg',\
			'sound/hallucinations/look_up1.ogg',\
			'sound/hallucinations/look_up2.ogg',\
			'sound/hallucinations/over_here1.ogg',\
			'sound/hallucinations/over_here2.ogg',\
			'sound/hallucinations/over_here3.ogg',\
			'sound/hallucinations/turn_around1.ogg',\
			'sound/hallucinations/turn_around2.ogg',\
			), 25, 1, 12)
			M.sleeping = max(M.sleeping,rand(5,10))
			cdel(src,,animation_destruction_fade(src))

/obj/effect/shadow_wight/Bump(atom/A)
	A << "<span class='warning'>You feel a chill run down your spine!</span>"
