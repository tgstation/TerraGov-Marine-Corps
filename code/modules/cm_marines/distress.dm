//This file deals with distress beacons. It randomizes between a number of different types when activated.
//There's also an admin commmand which lets you set one to your liking.

//basic persistent gamemode stuff.
/datum/game_mode
	var/list/datum/emergency_call/all_calls = list() //initialized at round start and stores the datums.
	var/datum/emergency_call/picked_call = null //Which distress call is currently active
	var/has_called_emergency = 0
	var/distress_cooldown = 0
	var/waiting_for_candidates = 0

//The distress call parent. Cannot be called itself due to "name" being a filtered target.
/datum/emergency_call
	var/name = "name"
	var/mob_max = 0
	var/dispatch_message = "An encrypted signal has been received from a nearby vessel. Stand by." //Msg to display when starting
	var/arrival_message = "" //Msg to display about when the shuttle arrives
	var/objectives //Txt of objectives to display to joined. Todo: make this into objective notes
	var/probability = 0 //Chance of it occuring. Total must equal 100%
	var/list/datum/mind/members = list() //Currently-joined members.
	var/list/datum/mind/candidates = list() //Potential candidates for enlisting.
//	var/waiting_for_candidates = 0 //Are we waiting on people to join?
	var/role_needed = BE_RESPONDER //Obsolete
	var/name_of_spawn = "Distress" //If we want to set up different spawn locations
	var/mob/living/carbon/leader = null //Who's leading these miscreants

//Weyland Yutani commandos. Friendly to USCM, hostile to xenos.
/datum/emergency_call/pmc
	name = "Commandos"
	mob_max = 6
	arrival_message = "USS Sulaco, this is USCSS Royce responding to your distress call. We are boarding. Any hostile actions will be met with lethal force."
	objectives = "Secure the Corporate Liason and the Sulaco Commander, and eliminate any hostile threats. Do not damage W-Y property."
	probability = 40

//Supply drop. Just docks and has a crapload of stuff inside.
/datum/emergency_call/supplies
	name = "Supply Drop"
	mob_max = 0
	arrival_message = "Weyland Yutani Automated Supply Drop 334-Q signal received. Docking procedures have commenced."
	probability = 5

//Randomly-equipped mercenaries. Neutral to Weyland Yutani.
/datum/emergency_call/mercs
	name = "Mercenaries"
	mob_max = 5
	arrival_message = "USS Sulaco, this is mercenary vessel MC-98 responding to your distress call. Prepare for boarding."
	objectives = "Help or hinder the crew of the Sulaco. Take what you want as payment. Do what your Captain says. Ensure your survival at all costs."
	probability = 20

//Xeeenoooooossss
/datum/emergency_call/xenos
	name = "Xenomorphs"
	mob_max = 6
	arrival_message = "USS Sulaco, this is USS Vriess respond-- #&...*#&^#.. signal.. oh god, they're in the vent---... Priority Warning: Signal lost."
	objectives = "Screeee! FoRr tHe HIvE!"
	probability = 15
	role_needed = BE_ALIEN

//Russian 'iron bear' mercenaries. Hostile to everyone.
/datum/emergency_call/bears
	name = "Iron Bears"
	mob_max = 4
	arrival_message = "Incoming Transmission: 'Vrag korabl'! Podgotovka k posadke i smerti!'"
	objectives = "Kill everything that moves. Blow up everything that doesn't. Listen to your superior officers. Help or hinder the Sulaco crew at your officer's discretion."
	probability = 15

//Terrified pizza delivery
/datum/emergency_call/pizza
	name = "Pizza Delivery"
	mob_max = 1
	arrival_message = "Incoming Transmission: 'That'll be.. sixteen orders of cheesy fries, eight large double topping pizzas, nine bottles of Four Loko.. hello? Is anyone on this ship? Your pizzas are getting cold.'"
	objectives = "Make sure you get a tip!"
	probability = 5


/datum/game_mode/proc/initialize_emergency_calls()
	if(all_calls.len) //It's already been set up.
		return

	var/list/total_calls = typesof(/datum/emergency_call)
	if(!total_calls.len)
		world << "\red \b Error setting up emergency calls, no datums found."
		return 0
	for(var/S in total_calls)
		var/datum/emergency_call/C= new S()
		if(!C)	continue
		if(C.name == "name") continue //The default parent, don't add it
		all_calls += C

//Randomizes and chooses a call datum.
/datum/game_mode/proc/get_random_call()
	var/chance = rand(1,100)
	var/add_prob = 0
	var/datum/emergency_call/chosen_call

	for(var/datum/emergency_call/E in all_calls) //Loop through all potential candidates
		if(chance >= E.probability + add_prob) //Tally up probabilities till we find which one we landed on
			add_prob += E.probability
			continue
		chosen_call = E //Our random chance found one.
		break

	if(!istype(chosen_call))
		world << "\red Something went wrong with emergency calls. Tell a coder!"
		return null
	else
		return chosen_call

/datum/emergency_call/proc/show_join_message()
	if(!mob_max || !ticker || !ticker.mode) //Just a supply drop, don't bother.
		return

//	var/list/datum/mind/possible_joiners = ticker.mode.get_players_for_role(role_needed) //Default role_needed is BE_RESPONDER
	for(var/mob/dead/observer/M in player_list)
		if(M.client)
			M << "<font size='3'>\red An emergency beacon has been activated. Use the <B>Join Response Team</b> verb, <B>IC tab</b>, to join!</font>"
			M << "\red You cannot join if you have been ghosted for less than a few minutes though."

/datum/game_mode/proc/activate_distress()
	picked_call = get_random_call()
	if(!istype(picked_call,/datum/emergency_call)) //Something went horribly wrong
		return
	if(ticker && ticker.mode && ticker.mode.waiting_for_candidates) //It's already been activated
		return
	picked_call.activate()
	return

/client/verb/JoinResponseTeam()
	set name = "Join Response Team"
	set category = "IC"
	set desc = "Join an ongoing distress call response. You must be ghosted to do this."

	if(istype(usr,/mob/dead) || istype(usr,/mob/new_player))
		if(jobban_isbanned(usr, "Syndicate") || jobban_isbanned(usr, "Military Police"))
			usr << "<font color=red><b>You are jobbanned from the emergency reponse team!"
			return
		if(!ticker || !ticker.mode || isnull(ticker.mode.picked_call))
			usr << "No distress beacons are active. You will be notified if this changes."
			return

		var/datum/emergency_call/distress = ticker.mode.picked_call //Just to simplify things a bit
		if(!istype(distress) || !distress.mob_max)
			usr << "The emergency response team is already full!"
			return
		var/deathtime = world.time - usr.timeofdeath

		if(deathtime < 600) //Nice try, ghosting right after the announcement
			usr << "You ghosted too recently."
			return

		if(!ticker.mode.waiting_for_candidates)
			usr << "The distress beacon is already active. Better luck next time!"
			return

		if(isnull(usr.mind)) //How? Give them a new one anyway.
			usr.mind = new /datum/mind(usr.key)
			usr.mind.active = 1
			usr.mind.current = usr

		if(!usr.client || !usr.mind) return //Somehow
		if(usr.mind in distress.candidates)
			usr << "You already joined, just be patient."
			return

		if(distress.add_candidate(usr))
			usr << "<B>You are enlisted in the emergency response team! If the team is full after 60 seconds you will be transferred in.</b>"
		else
			usr << "You did not get enlisted in the response team. Better luck next time!"
		return
	else
		usr << "You need to be an observer or new player to use this."
	return

/datum/emergency_call/proc/activate()
	if(!ticker || !ticker.mode) //Something horribly wrong with the gamemode ticker
		return

	if(ticker.mode.has_called_emergency) //It's already been called.
		return

	if(mob_max > 0)
		ticker.mode.waiting_for_candidates = 1
	show_join_message() //Show our potential candidates the message to let them join.
	message_admins("Distress beacon: '[src.name]' activated. Looking for candidates.", 1)
	command_announcement.Announce("A distress beacon has been launched from the USS Sulaco.", "Priority Alert")
	spawn(600) //If after 60 seconds we aren't full, abort
		if(candidates.len < mob_max)
			message_admins("Aborting distress beacon, not enough candidates: found [candidates.len].", 1)
			ticker.mode.waiting_for_candidates = 0
			ticker.mode.has_called_emergency = 0
			members = null
			members = list() //Empty the members list.
			candidates = null
			candidates = list()
			command_announcement.Announce("The distress signal got no response.", "Distress Beacon")
			ticker.mode.distress_cooldown = 1
			ticker.mode.picked_call = null
			spawn(1200)
				ticker.mode.distress_cooldown = 0
		else //we got enough!
			//Trim down the list
			var/list/datum/mind/picked_candidates = list()
			if(mob_max > 0)
				for(var/i = 1 to mob_max)
					if(!candidates.len) break//We ran out of candidates, maybe they alienized. Use what we have.
					var/datum/mind/M = pick(candidates) //Get a random candidate, then remove it from the candidates list.
					if(istype(M.current,/mob/living/carbon/Xenomorph) && !M.current.stat)
						candidates.Remove(M) //Strip them from the list, they aren't dead anymore.
						if(!candidates.len) break //NO picking from empty lists
						M = pick(candidates)
					if(!istype(M))//Something went horrifically wrong
						candidates.Remove(M)
						if(!candidates.len) break //No empty lists!!
						M = pick(candidates) //Lets try this again
					picked_candidates.Add(M)
					candidates.Remove(M)
				spawn(3)//Wait for all the above to be done
					if(candidates.len)
						for(var/datum/mind/I in candidates)
							if(I.current)
								I.current << "You didn't get selected to join the distress team. Better luck next time!"
						spawn(1)
							candidates = null //Blank out the candidates list for next time.
							candidates = list()

			command_announcement.Announce(dispatch_message, "Distress Beacon")
			message_admins("Distress beacon: [src.name] finalized, setting up candidates.", 1)
			var/datum/shuttle/ferry/shuttle = shuttle_controller.shuttles["Distress"]
			if(!shuttle || !istype(shuttle))
				message_admins("Warning: Distress shuttle not found. Aborting.")
				return
			spawn_items()
			shuttle.launch()
			if(picked_candidates.len)
				for(var/datum/mind/M in picked_candidates)
					members += M
					create_member(M)

			spawn(1000) //After 100 seconds, send the arrival message. Should be about the right time they make it there.
				command_announcement.Announce(arrival_message, "Docked")

			spawn(2400)
				shuttle.launch() //Get that fucker back

/datum/emergency_call/proc/add_candidate(var/mob/M)
	if(!M.client) return 0//Not connected
	if(M.mind && M.mind in candidates) return 0//Already there.
	if(istype(M,/mob/living/carbon/Xenomorph) && !M.stat) return 0//Something went wrong
	if(M.mind)
		candidates += M.mind
	return 1

/datum/emergency_call/proc/get_spawn_point(var/is_for_items = 0)
	var/list/spawn_list = list()

	for(var/obj/effect/landmark/L in landmarks_list)
		if(is_for_items && L.name == "[name_of_spawn]Item")
			spawn_list += L
		else
			if(L.name == name_of_spawn) //Default is "Distress"
				spawn_list += L

	if(!spawn_list.len) //Empty list somehow
		return null

	var/turf/spawn_loc	= get_turf(pick(spawn_list))
	if(!istype(spawn_loc))
		return null

	return spawn_loc


/datum/emergency_call/proc/create_member(var/datum/mind/M) //This is the parent, each type spawns its own variety.
	return

/datum/emergency_call/pmc/create_member(var/datum/mind/M)
	var/turf/spawn_loc = get_spawn_point()
	var/mob/original = M.current

	if(!istype(spawn_loc)) return //Didn't find a useable spawn point.

	var/mob/living/carbon/human/mob = new(spawn_loc)
	mob.gender = pick(MALE,FEMALE)
	var/datum/preferences/A = new()
	A.randomize_appearance_for(mob)
	if(mob.gender == MALE)
		mob.real_name = "PMC [pick(first_names_male)] [pick(last_names)]"
	else
		mob.real_name = "PMC [pick(first_names_female)] [pick(last_names)]"
	mob.name = mob.real_name
	mob.age = rand(17,45)
	mob.dna.ready_dna(mob)

	mob.key = M.key
//	M.transfer_to(mob)


	mob.mind.assigned_role = "PMC"
	ticker.mode.traitors += mob.mind
	spawn(0)
		if(!leader)       //First one spawned is always the leader.
			leader = mob
			spawn_officer(mob)
			mob.mind.special_role = "MODE"
			mob.mind.assigned_role = "PMC Leader"
			mob << "<font size='3'>\red You are the PMC Commando leader!</font>"
			mob << "<B> You must lead the PMCs to victory against any and all hostile threats.</b>"
			mob << "<B> Ensure no damage is incurred against Weyland Yutani.</b>"
		else
			mob.mind.special_role = "MODE"
			if(prob(35)) //Randomize the heavy commandos and standard PMCs.
				spawn_standard(mob)
				mob << "<font size='3'>\red You are a Weyland Yutani Commando!</font>"
			else
				if(prob(50))
					spawn_heavy(mob)
					mob << "<font size='3'>\red You are a Weyland Yutani Heavy Commando!</font>"
				else
					spawn_gunner(mob)
					mob << "<font size='3'>\red You are a Weyland Yutani Heavy Smartgunner!</font>"
	spawn(10)
		M << "<B>Objectives:</b> [objectives]"

	if(original)
		del(original)
	return


/datum/emergency_call/pmc/proc/spawn_standard(var/mob/M)
	if(!M || !istype(M)) return

	M.equip_to_slot_or_del(new /obj/item/device/radio/headset/syndicate/PMC(M), slot_l_ear)
	M.equip_to_slot_or_del(new /obj/item/clothing/under/marine_jumpsuit/PMC(M), slot_w_uniform)
	M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/PMCarmor(M), slot_wear_suit)
	M.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(M), slot_gloves)
	M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/PMC(M), slot_head)
	M.equip_to_slot_or_del(new /obj/item/weapon/melee/baton(M), slot_belt)
	M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(M), slot_back)
	M.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine, slot_shoes)
	M.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/automatic/m39/PMC(M), slot_r_hand)
	M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMCmask(M), slot_wear_mask)
	M.equip_to_slot_or_del(new /obj/item/weapon/tank/emergency_oxygen/engi(M.back), slot_in_backpack)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/m39(M.back), slot_in_backpack)
	M.equip_to_slot_or_del(new /obj/item/weapon/grenade/explosive/PMC(M.back), slot_in_backpack)
	M.equip_to_slot_or_del(new /obj/item/device/flashlight(M.back), slot_in_backpack)
	M.equip_to_slot_or_del(new /obj/item/weapon/handcuffs(M.back), slot_in_backpack)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/m39(M), slot_l_store)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/m39(M), slot_r_store)

	var/obj/item/weapon/card/id/W = new(src)
	W.assignment = "PMC Standard"
	W.registered_name = M.real_name
	W.name = "[M.real_name]'s ID Card ([W.assignment])"
	W.icon_state = "centcom"
	W.access = get_all_accesses()
	W.access += get_all_centcom_access()
	M.equip_to_slot_or_del(W, slot_wear_id)

/datum/emergency_call/pmc/proc/spawn_officer(var/mob/M)
	if(!M || !istype(M)) return

	M.equip_to_slot_or_del(new /obj/item/device/radio/headset/syndicate/PMC(M), slot_l_ear)
	M.equip_to_slot_or_del(new /obj/item/clothing/under/marine_jumpsuit/PMC/leader(M), slot_w_uniform)
	M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/PMCarmor/leader(M), slot_wear_suit)
	M.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(M), slot_gloves)
	M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/PMC/leader(M), slot_head)
	M.equip_to_slot_or_del(new /obj/item/weapon/melee/baton(M), slot_belt)
	M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(M), slot_back)
	M.equip_to_slot_or_del(new /obj/item/clothing/shoes/laceup(M), slot_shoes)
	M.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/automatic/m39/PMC(M), slot_r_hand)
	M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMCmask/leader(M), slot_wear_mask)
	M.equip_to_slot_or_del(new /obj/item/weapon/tank/emergency_oxygen/engi(M.back), slot_in_backpack)
	M.equip_to_slot_or_del(new /obj/item/device/flashlight(M.back), slot_in_backpack)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/VP78 (M.back), slot_in_backpack)
	M.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/VP78(M.back), slot_in_backpack)

	var/obj/item/weapon/card/id/W = new(src)
	W.assignment = "Weyland-Yutani Officer"
	W.registered_name = M.real_name
	W.name = "[M.real_name]'s ID Card ([W.assignment])"
	W.icon_state = "centcom"
	W.access = get_all_accesses()
	W.access += get_all_centcom_access()
	M.equip_to_slot_or_del(W, slot_wear_id)

/datum/emergency_call/pmc/proc/spawn_heavy(var/mob/M)
	if(!M || !istype(M)) return

	M.equip_to_slot_or_del(new /obj/item/device/radio/headset/syndicate/PMC(M), slot_l_ear)
	M.equip_to_slot_or_del(new /obj/item/clothing/glasses/m42_goggles	(M), slot_glasses)
	M.equip_to_slot_or_del(new /obj/item/clothing/under/marine_jumpsuit/PMC/commando(M), slot_w_uniform)
	M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/PMCarmor/commando(M), slot_wear_suit)
	M.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(M), slot_gloves)
	M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/PMC/commando(M), slot_head)
	M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(M), slot_back)
	M.equip_to_slot_or_del(new /obj/item/clothing/shoes/PMC(M), slot_shoes)
	M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMCmask/leader(M), slot_wear_mask)
	M.equip_to_slot_or_del(new /obj/item/weapon/tank/emergency_oxygen/engi(M.back), slot_in_backpack)
	M.equip_to_slot_or_del(new /obj/item/weapon/grenade/explosive/PMC(M.back), slot_in_backpack)
	M.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/VP78(M.back), slot_in_backpack)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/VP78 (M.back), slot_in_backpack)
	if(prob(30))
		M.equip_to_slot_or_del(new /obj/item/ammo_magazine/m39(M), slot_l_store)
		M.equip_to_slot_or_del(new /obj/item/ammo_magazine/m39(M), slot_r_store)
		M.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/automatic/m39/PMC(M), slot_r_hand)
	else
		if(prob(30))
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/m42c(M), slot_l_store)
			M.equip_to_slot_or_del(new /obj/item/ammo_magazine/m42c(M), slot_r_store)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/M42C(M), slot_r_hand)
		else


	var/obj/item/weapon/card/id/W = new(src)
	W.assignment = "PMC Elite"
	W.registered_name = M.real_name
	W.name = "[M.real_name]'s ID Card ([W.assignment])"
	W.icon_state = "centcom"
	W.access = get_all_accesses()
	W.access += get_all_centcom_access()
	M.equip_to_slot_or_del(W, slot_wear_id)

/datum/emergency_call/pmc/proc/spawn_gunner(var/mob/M)
	if(!M || !istype(M)) return

	M.equip_to_slot_or_del(new /obj/item/device/radio/headset/syndicate/PMC(M), slot_l_ear)
	M.equip_to_slot_or_del(new /obj/item/clothing/glasses/m42_goggles	(M), slot_glasses)
	M.equip_to_slot_or_del(new /obj/item/clothing/under/marine_jumpsuit/PMC/commando(M), slot_w_uniform)
	M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine_smartgun_armor/heavypmc(M), slot_wear_suit)
	M.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(M), slot_gloves)
	M.equip_to_slot_or_del(new /obj/item/smartgun_powerpack(M), slot_back)
	M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/PMC/heavypmc(M), slot_head)
	M.equip_to_slot_or_del(new /obj/item/clothing/shoes/PMC(M), slot_shoes)
	M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMCmask/leader(M), slot_wear_mask)
	M.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/VP78(M), slot_l_store)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/VP78 (M), slot_r_store)
	M.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/M56_Smartgun(M), slot_r_hand)

	var/obj/item/weapon/card/id/W = new(src)
	W.assignment = "PMC Gunner"
	W.registered_name = M.real_name
	W.name = "[M.real_name]'s ID Card ([W.assignment])"
	W.icon_state = "centcom"
	W.access = get_all_accesses()
	W.access += get_all_centcom_access()
	M.equip_to_slot_or_del(W, slot_wear_id)

/datum/emergency_call/pmc/proc/spawn_xenoborg(var/mob/M) //Deferred for now. Just keep it in mind
	return

/datum/emergency_call/xenos/create_member(var/datum/mind/M)
	var/turf/spawn_loc = get_spawn_point()
	var/mob/original = M.current

	if(!istype(spawn_loc)) return //Didn't find a useable spawn point.
	var/chance = rand(0,2)
	var/mob/living/carbon/Xenomorph/new_xeno
	if(chance == 0)
		new_xeno = new /mob/living/carbon/Xenomorph/Hunter(spawn_loc)
	else if(chance == 1)
		new_xeno = new /mob/living/carbon/Xenomorph/Spitter(spawn_loc)
	else
		new_xeno = new /mob/living/carbon/Xenomorph/Drone(spawn_loc)

	new_xeno.jelly = 1
	new_xeno.key  = M.key

	if(original) //Just to be sure.
		del(original)

/datum/emergency_call/mercs/create_member(var/datum/mind/M)
	var/turf/spawn_loc = get_spawn_point()
	var/mob/original = M.current

	if(!istype(spawn_loc)) return //Didn't find a useable spawn point.

	var/mob/living/carbon/human/mob = new(spawn_loc)
	mob.gender = pick(MALE,FEMALE)
	var/datum/preferences/A = new()
	A.randomize_appearance_for(mob)
	if(mob.gender == MALE)
		mob.real_name = "[pick(first_names_male)] [pick(last_names)]"
	else
		mob.real_name = "[pick(first_names_female)] [pick(last_names)]"
	mob.name = mob.real_name
	mob.age = rand(17,45)
	mob.dna.ready_dna(mob)
	mob.key = M.key
	mob.mind.assigned_role = "MODE"
	mob.mind.special_role = "Mercenary"
	ticker.mode.traitors += mob.mind
	spawn(0)
		if(!leader)       //First one spawned is always the leader.
			leader = mob
			spawn_captain(mob)
			mob << "<font size='3'>\red You are the Mercenary captain!</font>"
			mob << "<B> You must lead the mercs to victory against any and all hostile threats.</b>"
		else
			spawn_mercenary(mob)
			mob << "<font size='3'>\red You are a Space Mercenary!</font>"

	spawn(10)
		M << "<B>Objectives:</b> [objectives]"

	if(original)
		del(original)
	return

/datum/emergency_call/mercs/proc/spawn_captain(var/mob/M)
	if(!M || !istype(M)) return

	M.equip_to_slot_or_del(new /obj/item/device/radio/headset/syndicate(M), slot_l_ear)
	M.equip_to_slot_or_del(new /obj/item/clothing/under/captain_fly(M), slot_w_uniform)
	M.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/bulletproof(M), slot_wear_suit)
	M.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(M), slot_gloves)
	M.equip_to_slot_or_del(new /obj/item/clothing/head/caphat(M), slot_head)
	M.equip_to_slot_or_del(new /obj/item/weapon/melee/baton(M), slot_belt)
	M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(M), slot_back)
	M.equip_to_slot_or_del(new /obj/item/weapon/tank/emergency_oxygen/engi(M.back), slot_in_backpack)
	M.equip_to_slot_or_del(new /obj/item/device/flashlight(M.back), slot_in_backpack)
	M.equip_to_slot_or_del(new /obj/item/clothing/shoes/laceup(M), slot_shoes)

	M.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/deagle(M), slot_r_hand)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/a50(M), slot_l_store)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/a50(M.back), slot_in_backpack)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/a50(M.back), slot_in_backpack)


	var/obj/item/weapon/card/id/W = new(src)
	W.assignment = "Captain"
	W.registered_name = M.real_name
	W.name = "[M.real_name]'s ID Card ([W.assignment])"
	W.icon_state = "centcom"
	W.access = get_all_accesses()
	M.equip_to_slot_or_del(W, slot_wear_id)

/datum/emergency_call/mercs/proc/spawn_mercenary(var/mob/M)
	if(!M || !istype(M)) return

	M.equip_to_slot_or_del(new /obj/item/device/radio/headset/syndicate(M), slot_l_ear)
	if(prob(50))
		M.equip_to_slot_or_del(new /obj/item/clothing/under/chameleon(M), slot_w_uniform)
	else
		M.equip_to_slot_or_del(new /obj/item/clothing/under/syndicate(M), slot_w_uniform)
	if(prob(50))
		M.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/bulletproof(M), slot_wear_suit)
	else
		if(prob(50))
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/bomber(M), slot_wear_suit)
		else
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/armor(M), slot_wear_suit)
	if(prob(50))
		M.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(M), slot_gloves)
	else
		M.equip_to_slot_or_del(new /obj/item/clothing/gloves/yellow(M), slot_gloves)
	if(prob(30))
		M.equip_to_slot_or_del(new /obj/item/clothing/head/welding(M), slot_head)
	else
		if(prob(30))
			M.equip_to_slot_or_del(new /obj/item/clothing/head/bowler(M), slot_head)
		else
			if(prob(30))
				M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet(M), slot_head)
			else
				M.equip_to_slot_or_del(new /obj/item/clothing/head/hardhat(M), slot_head)

	M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(M), slot_back)
	M.equip_to_slot_or_del(new /obj/item/weapon/tank/emergency_oxygen/engi(M.back), slot_in_backpack)
	M.equip_to_slot_or_del(new /obj/item/device/flashlight(M.back), slot_in_backpack)
	if(prob(75))
		M.equip_to_slot_or_del(new /obj/item/clothing/shoes/leather(M), slot_shoes)
	else
		M.equip_to_slot_or_del(new /obj/item/clothing/shoes/magboots(M), slot_shoes)

	var/rand_gun = rand(0,5)
	if(rand_gun == 0)
		M.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/shotgun/pump/combat(M), slot_r_hand)
		M.equip_to_slot_or_del(new /obj/item/ammo_casing/shotgun(M), slot_l_store)
		M.equip_to_slot_or_del(new /obj/item/ammo_casing/shotgun(M.back), slot_in_backpack)
	else if(rand_gun == 1)
		M.equip_to_slot_or_del(new /obj/item/weapon/gun/launcher/crossbow(M), slot_r_hand)
		M.equip_to_slot_or_del(new /obj/item/weapon/arrow(M), slot_l_store)
		M.equip_to_slot_or_del(new /obj/item/weapon/arrow(M), slot_r_store)
		M.equip_to_slot_or_del(new /obj/item/weapon/arrow(M.back), slot_in_backpack)
	else if(rand_gun == 2)
		M.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/automatic/mini_uzi(M), slot_r_hand)
		M.equip_to_slot_or_del(new /obj/item/ammo_magazine/c45m(M), slot_l_store)
		M.equip_to_slot_or_del(new /obj/item/ammo_magazine/c45m(M.back), slot_in_backpack)
	else if(rand_gun == 3)
		M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/laser(M), slot_r_hand)
	else
		M.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/automatic/mar20, slot_r_hand)
		M.equip_to_slot_or_del(new /obj/item/ammo_magazine/a12mm(M), slot_l_store)
		M.equip_to_slot_or_del(new /obj/item/ammo_magazine/a12mm(M.back), slot_in_backpack)
		M.equip_to_slot_or_del(new /obj/item/ammo_magazine/a12mm(M.back), slot_in_backpack)


/datum/emergency_call/bears/create_member(var/datum/mind/M)
	var/turf/spawn_loc = get_spawn_point()
	var/mob/original = M.current

	if(!istype(spawn_loc)) return //Didn't find a useable spawn point.

	var/mob/living/carbon/human/mob = new(spawn_loc)
	mob.gender = pick(MALE,FEMALE)
	var/datum/preferences/A = new()
	A.randomize_appearance_for(mob)
	var/list/first_names_mr = list("Grigory","Vladimir","Alexei","Andrei","Artyom","Viktor","Boris","Ivan","Igor","Oleg")
	var/list/first_names_fr = list("Alexandra","Anna","Anastasiya","Eva","Klara","Nikita","Olga","Svetlana","Tatyana","Yaroslava")
	var/list/last_names_r = list("Azarov","Bogdanov","Barsukov","Golovin","Davydov","Dragomirov","Yeltsin","Zhirov","Zhukov","Ivanov","Ivchenko","Kasputin","Lukyanenko","Melnikov")
	if(mob.gender == MALE)
		mob.real_name = "[pick(first_names_mr)] [pick(last_names_r)]"
	else
		mob.real_name = "[pick(first_names_fr)] [pick(last_names_r)]"
	mob.name = mob.real_name
	mob.age = rand(17,45)
	mob.dna.ready_dna(mob)
	mob.key = M.key
	mob.mind.assigned_role = "MODE"
	mob.mind.special_role = "IRON BEARS"
	ticker.mode.traitors += mob.mind
	spawn(0)
		if(!leader)       //First one spawned is always the leader.
			leader = mob
			spawn_officer(mob)
			mob << "<font size='3'>\red You are the Iron Bears leader!</font>"
			mob << "<B> You must lead the Iron Bears mercenaries to victory against any and all hostile threats.</b>"
			mob << "<B> To Hell with Weyland Yutani and the USCM! The Iron Bears run the show now!</b>"
		else
			spawn_standard(mob)
			mob << "<font size='3'>\red You are an Iron Bear mercenary!</font>"

	spawn(10)
		M << "<B>Objectives:</b> [objectives]"

	if(original)
		del(original)
	return


/datum/emergency_call/bears/proc/spawn_standard(var/mob/M)
	if(!M || !istype(M)) return

	M.equip_to_slot_or_del(new /obj/item/device/radio/headset/syndicate(M), slot_l_ear)
	M.equip_to_slot_or_del(new /obj/item/clothing/under/marine_jumpsuit/PMC/Bear(M), slot_w_uniform)
	M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/PMCarmor/Bear(M), slot_wear_suit)
	M.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(M), slot_gloves)
	M.equip_to_slot_or_del(new /obj/item/clothing/head/ushanka(M), slot_head)
	M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(M), slot_back)
	M.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(M), slot_shoes)
	M.equip_to_slot_or_del(new /obj/item/weapon/tank/emergency_oxygen/engi(M.back), slot_in_backpack)
	M.equip_to_slot_or_del(new /obj/item/weapon/grenade/explosive(M.back), slot_in_backpack)
	M.equip_to_slot_or_del(new /obj/item/device/flashlight(M.back), slot_in_backpack)
	M.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/food/drinks/bottle/vodka(M.back), slot_in_backpack)

	M.equip_to_slot_or_del(new  /obj/item/weapon/gun/projectile/automatic/mar20(M), slot_r_hand)
	M.equip_to_slot_or_del(new /obj/item/weapon/plastique(M), slot_l_store)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/mc9mm(M), slot_r_store)

	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/a12mm(M.back), slot_in_backpack)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/a12mm(M.back), slot_in_backpack)
	M.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/pistol(M), slot_in_backpack)

	var/obj/item/weapon/card/id/W = new(src)
	W.assignment = "Iron Bear"
	W.registered_name = M.real_name
	W.name = "[M.real_name]'s ID Card ([W.assignment])"
	W.icon_state = "centcom"
	W.access = get_all_accesses()
	M.equip_to_slot_or_del(W, slot_wear_id)

/datum/emergency_call/bears/proc/spawn_officer(var/mob/M)
	if(!M || !istype(M)) return

	M.equip_to_slot_or_del(new /obj/item/device/radio/headset/syndicate/PMC(M), slot_l_ear)
	M.equip_to_slot_or_del(new /obj/item/clothing/under/marine_jumpsuit/PMC/Bear(M), slot_w_uniform)
	M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/PMCarmor/Bear(M), slot_wear_suit)
	M.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(M), slot_gloves)
	M.equip_to_slot_or_del(new /obj/item/clothing/head/bearpelt(M), slot_head)
	M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(M), slot_back)
	M.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(M), slot_shoes)

	M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/pulse_rifle(M), slot_r_hand)
	M.equip_to_slot_or_del(new /obj/item/weapon/gun/m92(M), slot_r_hand)

	M.equip_to_slot_or_del(new /obj/item/weapon/tank/emergency_oxygen/engi(M.back), slot_in_backpack)
	M.equip_to_slot_or_del(new /obj/item/weapon/cell/super(M.back), slot_in_backpack)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/mc9mm(M.back), slot_in_backpack)
	M.equip_to_slot_or_del(new /obj/item/weapon/grenade/explosive(M.back), slot_in_backpack)
	M.equip_to_slot_or_del(new /obj/item/weapon/grenade/explosive(M.back), slot_in_backpack)
	M.equip_to_slot_or_del(new /obj/item/weapon/grenade/explosive(M.back), slot_in_backpack)
	M.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/food/drinks/bottle/vodka(M.back), slot_in_backpack)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/mc9mm(M), slot_l_store)
	M.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/pistol(M), slot_r_store)

	var/obj/item/weapon/card/id/W = new(src)
	W.assignment = "Iron Bears Sergeant"
	W.registered_name = M.real_name
	W.name = "[M.real_name]'s ID Card ([W.assignment])"
	W.icon_state = "centcom"
	W.access = get_all_accesses()
	W.access += get_all_centcom_access()
	M.equip_to_slot_or_del(W, slot_wear_id)

/datum/emergency_call/pizza/create_member(var/datum/mind/M)
	var/turf/spawn_loc = get_spawn_point()
	var/mob/original = M.current

	if(!istype(spawn_loc)) return //Didn't find a useable spawn point.

	var/mob/living/carbon/human/mob = new(spawn_loc)
	mob.gender = pick(MALE,FEMALE)
	var/datum/preferences/A = new()
	A.randomize_appearance_for(mob)
	if(mob.gender == MALE)
		mob.real_name = "[pick(first_names_male)] [pick(last_names)]"
	else
		mob.real_name = "[pick(first_names_female)] [pick(last_names)]"
	mob.name = mob.real_name
	mob.age = rand(17,45)
	mob.dna.ready_dna(mob)
	mob.key = M.key
	mob.mind.assigned_role = "MODE"
	mob.mind.special_role = "Pizza"
	ticker.mode.traitors += mob.mind
	spawn(0)
		spawn_pizza(mob)
		var/pizzatxt = pick("Pizzachimp","Pizza the Hut","Papa Donks")
		mob << "<font size='3'>\red You are a pizza deliverer! Your employer is the [pizzatxt] Corporation.</font>"
		mob << "Your job is to deliver your pizzas. You're PRETTY sure this is the right place.."
	spawn(10)
		M << "<B>Objectives:</b> [objectives]"

	if(original)
		del(original)
	return

/datum/emergency_call/pizza/proc/spawn_pizza(var/mob/M)
	if(!M || !istype(M)) return

	M.equip_to_slot_or_del(new /obj/item/clothing/under/pizza(M), slot_w_uniform)
	M.equip_to_slot_or_del(new /obj/item/clothing/head/soft/red(M), slot_head)
	M.equip_to_slot_or_del(new /obj/item/clothing/shoes/red(M), slot_shoes)
	M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(M), slot_back)
	M.equip_to_slot_or_del(new /obj/item/pizzabox/margherita(M), slot_r_hand)
	M.equip_to_slot_or_del(new /obj/item/pizzabox/margherita(M), slot_r_hand)
	M.equip_to_slot_or_del(new /obj/item/device/radio(M), slot_r_store)

	M.equip_to_slot_or_del(new /obj/item/device/flashlight(M.back), slot_in_backpack)
	M.equip_to_slot_or_del(new /obj/item/pizzabox/vegetable(M.back), slot_in_backpack)
	M.equip_to_slot_or_del(new /obj/item/pizzabox/mushroom(M.back), slot_in_backpack)
	M.equip_to_slot_or_del(new /obj/item/pizzabox/meat(M.back), slot_in_backpack)
	M.equip_to_slot_or_del(new /obj/item/weapon/storage/box/pizza(M.back), slot_in_backpack)
	M.equip_to_slot_or_del(new /obj/item/weapon/storage/box/pizza(M.back), slot_in_backpack)
	M.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/detective(M.back), slot_in_backpack)

	var/obj/item/weapon/card/id/W = new(src)
	W.assignment = "Pizzachimp Deliverer"
	W.registered_name = M.real_name
	W.name = "[M.real_name]'s ID Card ([W.assignment])"
	W.icon_state = "centcom"
	M.equip_to_slot_or_del(W, slot_wear_id)

//Spawn various items around the shuttle area thing.
/datum/emergency_call/proc/spawn_items()
	return

/datum/emergency_call/pmc/spawn_items()
	var/turf/drop_spawn
	var/choice

	for(var/i = 1 to 6) //Spawns up to 6 random things.
		if(prob(20)) continue
		choice = (rand(1,8) - round(i/2)) //Decreasing values, rarer stuff goes at the end.
		if(choice < 0) choice = 0
		drop_spawn = get_spawn_point(1)
		if(istype(drop_spawn))
			switch(choice)
				if(0)
					new /obj/item/weapon/gun/projectile/VP78(drop_spawn)
					continue
				if(1)
					new /obj/item/weapon/gun/projectile/automatic/m39/PMC(drop_spawn)
					new /obj/item/weapon/gun/projectile/automatic/m39/PMC(drop_spawn)
					continue
				if(2)
					new /obj/item/weapon/storage/box/m56_system(drop_spawn)
					continue
				if(3)
					new /obj/item/weapon/plastique(drop_spawn)
					new /obj/item/weapon/plastique(drop_spawn)
					new /obj/item/weapon/plastique(drop_spawn)
					continue
				if(4)
					new /obj/item/weapon/gun/projectile/automatic/m41(drop_spawn)
					new /obj/item/weapon/gun/projectile/automatic/m41(drop_spawn)
					new /obj/item/weapon/gun/projectile/automatic/m41(drop_spawn)
					continue
				if(5)
					new /obj/item/weapon/gun/m92(drop_spawn)
					new /obj/item/weapon/grenade/explosive/PMC(drop_spawn)
					new /obj/item/weapon/grenade/explosive/PMC(drop_spawn)
					new /obj/item/weapon/grenade/explosive/PMC(drop_spawn)
					continue
				if(6)
					new /obj/item/weapon/storage/box/m42c_system(drop_spawn)
					continue
				if(7)
					new /obj/item/weapon/storage/box/rocket_system(drop_spawn)
					continue
	return

/datum/emergency_call/supplies/spawn_items()
	var/turf/drop_spawn
	var/choice

	for(var/i = 1 to 8) //Spawns up to 8 random things.
		if(prob(10)) continue
		choice = (rand(1,8) - round(i/2)) //Decreasing values, rarer stuff goes at the end.
		if(choice < 0) choice = 0
		drop_spawn = get_spawn_point(1)
		if(istype(drop_spawn))
			switch(choice)
				if(0)
					new /obj/item/weapon/gun/projectile/VP78(drop_spawn)
					new /obj/item/weapon/gun/projectile/VP78(drop_spawn)
					continue
				if(1)
					new /obj/item/weapon/gun/projectile/automatic/m39/PMC(drop_spawn)
					new /obj/item/weapon/gun/projectile/automatic/m39/PMC(drop_spawn)
					continue
				if(2)
					new /obj/item/weapon/storage/box/m56_system(drop_spawn)
					new /obj/item/weapon/grenade/explosive/PMC(drop_spawn)
					new /obj/item/weapon/grenade/explosive/PMC(drop_spawn)
					new /obj/item/weapon/grenade/explosive/PMC(drop_spawn)
					continue
				if(3)
					new /obj/item/weapon/plastique(drop_spawn)
					new /obj/item/weapon/grenade/explosive/PMC(drop_spawn)
					new /obj/item/weapon/grenade/explosive/PMC(drop_spawn)
					new /obj/item/weapon/grenade/explosive/PMC(drop_spawn)
					continue
				if(4)
					new /obj/item/weapon/gun/projectile/automatic/m41(drop_spawn)
					new /obj/item/weapon/gun/projectile/automatic/m41(drop_spawn)
					new /obj/item/weapon/gun/projectile/automatic/m41(drop_spawn)
					continue
				if(5)
					new /obj/item/weapon/gun/m92(drop_spawn)
					new /obj/item/weapon/grenade/explosive/PMC(drop_spawn)
					new /obj/item/weapon/grenade/explosive/PMC(drop_spawn)
					new /obj/item/weapon/grenade/explosive/PMC(drop_spawn)
					continue
				if(6)
					new /obj/item/weapon/storage/box/m42c_system(drop_spawn)
					continue
				if(7)
					new /obj/item/weapon/storage/box/rocket_system(drop_spawn)
					continue
	return

/datum/emergency_call/bears/spawn_items()
	var/turf/drop_spawn
	var/choice

	for(var/i = 1 to 8) //Spawns up to 8 random things.
		if(prob(10)) continue
		choice = (rand(1,8) - round(i/2)) //Decreasing values, rarer stuff goes at the end.
		if(choice < 0) choice = 0
		drop_spawn = get_spawn_point(1)
		if(istype(drop_spawn))
			switch(choice)
				if(0)
					new /obj/item/ammo_magazine/a762(drop_spawn)
					new /obj/item/ammo_magazine/a762(drop_spawn)
					new/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka(drop_spawn)
					new/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka(drop_spawn)
					continue
				if(1)
					new /obj/item/weapon/flamethrower/full(drop_spawn)
					new /obj/item/weapon/flamethrower/full(drop_spawn)
					new/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka(drop_spawn)
					continue
				if(2)
					new /obj/item/weapon/reagent_containers/hypospray/tricordrazine(drop_spawn)
					new /obj/item/weapon/shield/riot(drop_spawn)
					new/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka(drop_spawn)
					continue
				if(3)
					new /obj/item/weapon/plastique(drop_spawn)
					new /obj/item/weapon/plastique(drop_spawn)
					new /obj/item/weapon/plastique(drop_spawn)
					continue
				if(4)
					new /obj/item/weapon/shield/riot(drop_spawn)
					new /obj/item/weapon/shield/riot(drop_spawn)
					new /obj/item/weapon/gun/projectile/automatic/l6_saw(drop_spawn)
					continue
				if(5)
					new /obj/item/weapon/gun/m92(drop_spawn)
					new /obj/item/weapon/grenade/explosive/PMC(drop_spawn)
					new /obj/item/weapon/grenade/explosive/PMC(drop_spawn)
					new /obj/item/weapon/grenade/explosive/PMC(drop_spawn)
					continue
				if(6)
					new /obj/item/weapon/storage/box/grenade_system(drop_spawn)
					new /obj/item/weapon/storage/box/rocket_system(drop_spawn)
					continue
				if(7)
					new /obj/item/weapon/storage/box/rocket_system(drop_spawn)
					new /obj/item/weapon/storage/box/rocket_system(drop_spawn)
					continue
	return

