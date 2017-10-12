//This file deals with distress beacons. It randomizes between a number of different types when activated.
//There's also an admin commmand which lets you set one to your liking.



/proc/spawn_merc_gun(var/atom/M,var/sidearm = 0)
	if(!M) return

	var/atom/spawnloc = M

	var/list/merc_sidearms = list(
		/obj/item/weapon/gun/revolver/small = /obj/item/ammo_magazine/revolver/small,
		/obj/item/weapon/gun/pistol/heavy = /obj/item/ammo_magazine/pistol/heavy,
		/obj/item/weapon/gun/pistol/m1911 = /obj/item/ammo_magazine/pistol/m1911,
		/obj/item/weapon/gun/pistol/kt42 = /obj/item/ammo_magazine/pistol/automatic,
		/obj/item/weapon/gun/pistol/holdout = /obj/item/ammo_magazine/pistol/holdout,
		/obj/item/weapon/gun/pistol/highpower = /obj/item/ammo_magazine/pistol/highpower,
		/obj/item/weapon/gun/smg/mp7 = /obj/item/ammo_magazine/smg/mp7,
		/obj/item/weapon/gun/smg/skorpion = /obj/item/ammo_magazine/smg/skorpion,
		/obj/item/weapon/gun/smg/uzi = /obj/item/ammo_magazine/smg/uzi,
		/obj/item/weapon/gun/smg/uzi = /obj/item/ammo_magazine/smg/uzi/extended)

	var/list/merc_firearms = list(
		/obj/item/weapon/gun/shotgun/merc = /obj/item/ammo_magazine/shotgun,
		/obj/item/weapon/gun/shotgun/combat = /obj/item/ammo_magazine/shotgun,
		/obj/item/weapon/gun/shotgun/double = /obj/item/ammo_magazine/shotgun/buckshot,
		/obj/item/weapon/gun/shotgun/pump/cmb = /obj/item/ammo_magazine/shotgun/incendiary,
		/obj/item/weapon/gun/rifle/mar40 = /obj/item/ammo_magazine/rifle/mar40,
		/obj/item/weapon/gun/rifle/mar40/carbine = /obj/item/ammo_magazine/rifle/mar40,
		/obj/item/weapon/gun/rifle/m41aMK1 = /obj/item/ammo_magazine/rifle/m41aMK1,
		/obj/item/weapon/gun/smg/p90 = /obj/item/ammo_magazine/smg/p90,
		/obj/item/weapon/gun/smg/uzi = /obj/item/ammo_magazine/smg/uzi/extended)

	var/gunpath = sidearm? pick(merc_sidearms) : pick(merc_firearms)
	var/ammopath = sidearm? merc_sidearms[gunpath] : merc_firearms[gunpath]
	var/obj/item/weapon/gun/gun

	if(gunpath)
		gun = new gunpath(spawnloc)
		if(ishuman(spawnloc))
			var/mob/living/carbon/human/H = spawnloc
			H.equip_to_slot_or_del(gun, sidearm? WEAR_L_HAND : WEAR_R_HAND)
			if(ammopath && H.back && istype(H.back,/obj/item/weapon/storage))
				new ammopath(H.back)
				new ammopath(H.back)
				new ammopath(H.back)
				new ammopath(H.back)
		else
			if(ammopath)
				spawnloc = get_turf(spawnloc)
				new ammopath(spawnloc)
				new ammopath(spawnloc)
				new ammopath(spawnloc)

	return 1

/proc/spawn_rebel_gun(var/atom/M,var/sidearm = 0)
	if(!M) return
	var/atom/spawnloc = M

	var/list/rebel_firearms = list(
		/obj/item/weapon/gun/shotgun/merc = /obj/item/ammo_magazine/shotgun,
		/obj/item/weapon/gun/shotgun/double = /obj/item/ammo_magazine/shotgun/buckshot,
		/obj/item/weapon/gun/shotgun/double = /obj/item/ammo_magazine/shotgun/buckshot,
		/obj/item/weapon/gun/shotgun/double = /obj/item/ammo_magazine/shotgun/buckshot,
		/obj/item/weapon/gun/shotgun/double = /obj/item/ammo_magazine/shotgun/buckshot,
		/obj/item/weapon/gun/shotgun/double = /obj/item/ammo_magazine/shotgun/buckshot,
		/obj/item/weapon/gun/shotgun/pump/cmb = /obj/item/ammo_magazine/shotgun/incendiary,
		/obj/item/weapon/gun/shotgun/pump/cmb = /obj/item/ammo_magazine/shotgun/incendiary,
		/obj/item/weapon/gun/rifle/mar40 = /obj/item/ammo_magazine/rifle/mar40,
		/obj/item/weapon/gun/rifle/mar40/carbine = /obj/item/ammo_magazine/rifle/mar40,
		/obj/item/weapon/gun/rifle/mar40/carbine = /obj/item/ammo_magazine/rifle/mar40,
		/obj/item/weapon/gun/rifle/mar40/carbine = /obj/item/ammo_magazine/rifle/mar40,
		/obj/item/weapon/gun/smg/uzi = /obj/item/ammo_magazine/smg/uzi/extended,
		/obj/item/weapon/gun/smg/uzi = /obj/item/ammo_magazine/smg/uzi/extended,
		/obj/item/weapon/gun/revolver/small = /obj/item/ammo_magazine/revolver/small,
		/obj/item/weapon/gun/revolver/small = /obj/item/ammo_magazine/revolver/small,
		/obj/item/weapon/gun/revolver/small = /obj/item/ammo_magazine/revolver/small,
		/obj/item/weapon/gun/pistol/heavy = /obj/item/ammo_magazine/pistol/heavy,
		/obj/item/weapon/gun/pistol/kt42 = /obj/item/ammo_magazine/pistol/automatic,
		/obj/item/weapon/gun/pistol/holdout = /obj/item/ammo_magazine/pistol/holdout,
		/obj/item/weapon/gun/pistol/highpower = /obj/item/ammo_magazine/pistol/highpower,
		/obj/item/weapon/gun/smg/mp7 = /obj/item/ammo_magazine/smg/mp7,
		/obj/item/weapon/gun/smg/skorpion = /obj/item/ammo_magazine/smg/skorpion,
		/obj/item/weapon/gun/smg/skorpion/upp = /obj/item/ammo_magazine/smg/skorpion,
		/obj/item/weapon/gun/shotgun/double/sawn = /obj/item/ammo_magazine/shotgun/incendiary,
		/obj/item/weapon/gun/shotgun/double/sawn = /obj/item/ammo_magazine/shotgun/buckshot,
		/obj/item/weapon/gun/revolver/cmb = /obj/item/ammo_magazine/revolver/cmb,
		/obj/item/weapon/gun/revolver/cmb = /obj/item/ammo_magazine/revolver/cmb,
		/obj/item/weapon/gun/pistol/c99 = /obj/item/ammo_magazine/pistol/c99,
		/obj/item/weapon/gun/pistol/vp70 = /obj/item/ammo_magazine/pistol/vp70
		)


	var/list/rebel_sidearms = list(
		/obj/item/weapon/storage/large_holster/katana/full = null,
		/obj/item/weapon/storage/large_holster/katana/full = null,
		/obj/item/weapon/storage/large_holster/katana/full = null,
		/obj/item/weapon/storage/large_holster/machete/full = null,
		/obj/item/weapon/combat_knife = null,
		/obj/item/weapon/grenade/explosive/stick = null,
		/obj/item/weapon/grenade/explosive/stick = null,
		/obj/item/weapon/grenade/explosive/stick = null,
		/obj/item/weapon/combat_knife/upp = null,
		/obj/item/weapon/gun/pistol/holdout = /obj/item/ammo_magazine/pistol/holdout,
		/obj/item/weapon/gun/pistol/holdout = /obj/item/ammo_magazine/pistol/holdout,
		/obj/item/weapon/gun/revolver/cmb = /obj/item/ammo_magazine/revolver/cmb,
		/obj/item/weapon/gun/revolver/small = /obj/item/ammo_magazine/revolver/small,
		/obj/item/weapon/reagent_containers/spray/pepper = null,
		/obj/item/weapon/reagent_containers/spray/pepper = null,
		/obj/item/clothing/tie/storage/webbing = null,
		/obj/item/clothing/tie/storage/webbing = null,
		/obj/item/weapon/storage/belt/marine = null,
		/obj/item/weapon/storage/pill_bottle/tramadol = null,
		/obj/item/weapon/grenade/phosphorus = null,
		/obj/item/clothing/glasses/welding = null,
		/obj/item/weapon/reagent_containers/ld50_syringe/choral = null,
		/obj/item/weapon/storage/firstaid/regular = null,
		/obj/item/weapon/reagent_containers/pill/cyanide = null,
		/obj/item/device/megaphone = null,
		/obj/item/weapon/storage/belt/utility/full = null,
		/obj/item/weapon/storage/belt/utility/full = null,
		/obj/item/weapon/storage/bible = null,
		/obj/item/weapon/scalpel = null,
		/obj/item/weapon/scalpel = null,
		/obj/item/weapon/baseballbat = null,
		/obj/item/weapon/baseballbat = null,
		/obj/item/weapon/baseballbat = null,
		/obj/item/weapon/baseballbat/metal = null,
		/obj/item/weapon/grenade/empgrenade = null,
		/obj/item/weapon/grenade/smokebomb = null,
		/obj/item/weapon/grenade/smokebomb = null,
		/obj/item/weapon/grenade/smokebomb = null,
		/obj/item/weapon/grenade/phosphorus/upp = null,
		/obj/item/weapon/hatchet = null,
		/obj/item/weapon/hatchet = null,
		/obj/item/weapon/hatchet = null,
		/obj/item/weapon/storage/box/MRE = null,
		/obj/item/clothing/mask/fluff/balaclava = null,
		/obj/item/clothing/glasses/night/m42_night_goggles/upp = null,
		/obj/item/weapon/storage/box/handcuffs = null,
		/obj/item/weapon/storage/pill_bottle/happy = null,
		/obj/item/weapon/twohanded/fireaxe = null,
		/obj/item/weapon/twohanded/spear = null
		)

	var/gunpath = sidearm? pick(rebel_sidearms) : pick(rebel_firearms)
	var/ammopath = sidearm? rebel_sidearms[gunpath] : rebel_firearms[gunpath]
	var/obj/item/weapon/gun/gun

	if(gunpath)
		gun = new gunpath(spawnloc)
		if(ishuman(spawnloc))
			var/mob/living/carbon/human/H = spawnloc
			H.equip_to_slot_or_del(gun, sidearm? WEAR_L_HAND : WEAR_R_HAND)
			if(ammopath && H.back && istype(H.back,/obj/item/weapon/storage) && ammopath != null)
				new ammopath(H.back)
				new ammopath(H.back)
				new ammopath(H.back)
				new ammopath(H.back)
		else
			if(ammopath != null)
				spawnloc = get_turf(spawnloc)
				new ammopath(spawnloc)
				new ammopath(spawnloc)
				new ammopath(spawnloc)


	return 1


/proc/spawn_slavic_gun(var/atom/M,var/sidearm = 0)
	if(!M) return

	var/atom/spawnloc = M

	var/list/rus_sidearms = list(
		/obj/item/weapon/gun/revolver/upp = /obj/item/ammo_magazine/revolver/upp,
		/obj/item/weapon/gun/revolver/mateba = /obj/item/ammo_magazine/revolver/mateba,
		/obj/item/weapon/gun/pistol/c99 = /obj/item/ammo_magazine/pistol/c99,
		/obj/item/weapon/gun/pistol/c99/russian = /obj/item/ammo_magazine/pistol/c99,
		/obj/item/weapon/gun/pistol/kt42 = /obj/item/ammo_magazine/pistol/automatic,
		/obj/item/weapon/gun/smg/ppsh = /obj/item/ammo_magazine/smg/ppsh,
		/obj/item/weapon/gun/smg/ppsh = /obj/item/ammo_magazine/smg/ppsh/extended)

	var/list/rus_firearms = list(/obj/item/weapon/gun/rifle/mar40,
		/obj/item/weapon/gun/rifle/mar40 = /obj/item/ammo_magazine/rifle/mar40,
		/obj/item/weapon/gun/rifle/mar40 = /obj/item/ammo_magazine/rifle/mar40/extended,
		/obj/item/weapon/gun/rifle/mar40/carbine = /obj/item/ammo_magazine/rifle/mar40,
		/obj/item/weapon/gun/smg/ppsh = /obj/item/ammo_magazine/smg/ppsh/extended,
		/obj/item/weapon/gun/rifle/sniper/svd = /obj/item/ammo_magazine/rifle/sniper/svd)

	var/gunpath = sidearm? pick(rus_sidearms) : pick(rus_firearms)
	var/ammopath = sidearm? rus_sidearms[gunpath] : rus_firearms[gunpath]
	var/obj/item/weapon/gun/gun

	if(gunpath)
		gun = new gunpath(spawnloc)
		if(ishuman(spawnloc))
			var/mob/living/carbon/human/H = spawnloc
			H.equip_to_slot_or_del(gun, sidearm? WEAR_L_HAND : WEAR_R_HAND)
			if(ammopath && H.back && istype(H.back,/obj/item/weapon/storage))
				new ammopath(H.back)
				new ammopath(H.back)
		else
			if(ammopath)
				spawnloc = get_turf(spawnloc)
				new ammopath(spawnloc)
				new ammopath(spawnloc)

	return 1

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
	var/mob_max = 3
	var/mob_min = 3
	var/dispatch_message = "An encrypted signal has been received from a nearby vessel. Stand by." //Msg to display when starting
	var/arrival_message = "" //Msg to display about when the shuttle arrives
	var/objectives //Txt of objectives to display to joined. Todo: make this into objective notes
	var/probability = 0 //Chance of it occuring. Total must equal 100%
	var/hostility //For ERTs who are either hostile or friendly by random chance.
	var/list/datum/mind/members = list() //Currently-joined members.
	var/list/datum/mind/candidates = list() //Potential candidates for enlisting.
//	var/waiting_for_candidates = 0 //Are we waiting on people to join?
	var/role_needed = BE_RESPONDER //Obsolete
	var/name_of_spawn = "Distress" //If we want to set up different spawn locations
	var/mob/living/carbon/leader = null //Who's leading these miscreants
	var/medics = 0
	var/heavies = 0
	var/max_medics = 1
	var/max_heavies = 1

//Weyland Yutani commandos. Friendly to USCM, hostile to xenos.
/datum/emergency_call/pmc
	name = "Weyland-Yutani PMC (Squad)"
	mob_max = 6
	probability = 25

	New()
		..()
		arrival_message = "[MAIN_SHIP_NAME], this is USCSS Royce responding to your distress call. We are boarding. Any hostile actions will be met with lethal force."
		objectives = "Secure the Corporate Liaison and the [MAIN_SHIP_NAME] Commander, and eliminate any hostile threats. Do not damage W-Y property."

//Randomly-equipped mercenaries. May be friendly or hostile to the USCM, hostile to xenos.
/datum/emergency_call/mercs
	name = "Freelancers (Squad)"
	mob_max = 8
	probability = 25

	New()
		..()
		arrival_message = "[MAIN_SHIP_NAME], this is Freelancer shuttle MC-98 responding to your distress call. Prepare for boarding."
		objectives = "Help the crew of the [MAIN_SHIP_NAME] in exchange for payment, and choose your payment well. Do what your Captain says. Ensure your survival at all costs."

//Colonial Liberation Front
/datum/emergency_call/clf
	name = "Colonial Liberation Front (Squad)"
	mob_max = 10
	arrival_message = "Incoming Transmission: 'Attention, you are tresspassing on our soverign territory. Expect no forgiveness.'"
	objectives = "Assault the USCM, and sabotage as much as you can. Ensure any survivors escape in your custody."
	probability = 20

//UPP Strike Team
/datum/emergency_call/upp
	name = "UPP Naval Infantry (Squad)"
	mob_max = 7
	probability = 10

	New()
		..()
		arrival_message = "T*is i* UP* d^sp^*ch`. STr*&e teaM, #*u are cLe*% for a*pr*%^h. Pr*mE a*l wE*p^ns )0r c|*$e @u*r*r$ c0m&*t."
		objectives = "Eliminate the UA Forces to ensure the UPP prescence in this sector is continued. Listen to your superior officers and take over the [MAIN_SHIP_NAME] at all costs."


//Xenomorphs, hostile to everyone.
/datum/emergency_call/xenos
	name = "Xenomorphs (Squad)"
	mob_max = 7
	probability = 10
	role_needed = BE_ALIEN

	New()
		..()
		arrival_message = "[MAIN_SHIP_NAME], this is USS Vriess respond-- #&...*#&^#.. signal.. oh god, they're in the vent---... Priority Warning: Signal lost."
		objectives = "For the Empress!"

/datum/emergency_call/pmc/platoon
	name = "Weyland-Yutani PMC (Platoon)"
	mob_min = 8
	mob_max = 25
	probability = 0

/datum/emergency_call/mercs/platoon
	name = "Freelancers (Platoon)"
	mob_min = 8
	mob_max = 30
	probability = 0
	max_medics = 3

/datum/emergency_call/clf/platoon
	name = "Colonial Liberation Front (Platoon)"
	mob_min = 8
	mob_max = 35
	probability = 0
	max_medics = 2

/datum/emergency_call/upp/platoon
	name = "UPP Naval Infantry (Platoon)"
	mob_min = 8
	mob_max = 30
	probability = 0
	max_medics = 2
	max_heavies = 2

/datum/emergency_call/xenos/platoon
	name = "Xenomorphs (Platoon)"
	mob_min = 8
	mob_max = 30
	probability = 0


//Supply drop. Just docks and has a crapload of stuff inside.
/datum/emergency_call/supplies
	name = "Supply Drop"
	mob_max = 0
	mob_min = 0
	arrival_message = "Weyland Yutani Automated Supply Drop 334-Q signal received. Docking procedures have commenced."
	probability = 5

/datum/emergency_call/upp_commando
	name = "UPP Commandos"
	mob_max = 6
	probability = 0
	objectives = "Stealthily assault the ship. Use your silenced weapons, tranquilizers, and night vision to get the advantage on the enemy. Take out the power systems, comms and engine. Stick together and keep a low profile."

//Deathsquad Commandos
/datum/emergency_call/death
	name = "Weyland Deathsquad"
	mob_max = 8
	mob_min = 5
	arrival_message = "Intercepted Transmission: '!`2*%slau#*jer t*h$em a!l%. le&*ve n(o^ w&*nes%6es.*v$e %#d ou^'"
	objectives = "Wipe out everything. Ensure there are no traces of the infestation or any witnesses."
	probability = 0

//Blank colonist ERT for admin stuff.
/datum/emergency_call/colonist
	name = "Colonists"
	mob_max = 8
	mob_min = 1
	arrival_message = "Incoming Transmission: 'This is the *static*. We are *static*.'"
	objectives = "Follow the orders given to you."
	probability = 0

//Terrified pizza delivery
/datum/emergency_call/pizza
	name = "Pizza Delivery"
	mob_max = 1
	mob_min = 1
	arrival_message = "Incoming Transmission: 'That'll be.. sixteen orders of cheesy fries, eight large double topping pizzas, nine bottles of Four Loko.. hello? Is anyone on this ship? Your pizzas are getting cold.'"
	objectives = "Make sure you get a tip!"
	probability = 5



/*
/datum/emergency_call/xenoborgs
	name = "Xenoborgs"
	mob_max = 2
	arrival_message = "Incoming Transmission: 'Under Weyland-Yutani Contract order 88-19 subset 3.4, we have dispatched a squad of research prototypes to your location. Please stand by for boarding.'"
	objectives = "Do whatever Weyland Yutani needs you to do."
	probability = 0
*/
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
		E.hostility = pick(75;0,25;1)
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
			M << "<font size='3'><span class='attack'>An emergency beacon has been activated. Use the <B>Join Response Team</b> verb, <B>IC tab</b>, to join!</span>"
			M << "<span class='attack'>You cannot join if you have been ghosted for less than a few minutes.</span>"

/datum/game_mode/proc/activate_distress()
	picked_call = get_random_call()
	if(!istype(picked_call, /datum/emergency_call)) //Something went horribly wrong
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
		if(jobban_isbanned(usr, "Syndicate") || jobban_isbanned(usr, "Emergency Response Team"))
			usr << "<span class='danger'>You are jobbanned from the emergency reponse team!</span>"
			return
		if(!ticker || !ticker.mode || isnull(ticker.mode.picked_call))
			usr << "<span class='warning'>No distress beacons are active. You will be notified if this changes.</span>"
			return

		var/datum/emergency_call/distress = ticker.mode.picked_call //Just to simplify things a bit
		if(!istype(distress) || !distress.mob_max)
			usr << "<span class='warning'>The emergency response team is already full!</span>"
			return
		var/deathtime = world.time - usr.timeofdeath

		if(deathtime < 600) //Nice try, ghosting right after the announcement
			usr << "<span class='warning'>You ghosted too recently.</span>"
			return

		if(!ticker.mode.waiting_for_candidates)
			usr << "<span class='warning'>The emergency response team has already been selected.</span>"
			return

		if(!usr.mind) //How? Give them a new one anyway.
			usr.mind = new /datum/mind(usr.key)
			usr.mind.active = 1
			usr.mind.current = usr
		if(usr.mind.key != usr.key) usr.mind.key = usr.key //Sigh. This can happen when admin-switching people into afking people, leading to runtime errors for a clientless key.

		if(!usr.client || !usr.mind) return //Somehow
		if(usr.mind in distress.candidates)
			usr << "<span class='warning'>You are already a candidate for this emergency response team.</span>"
			return

		if(distress.add_candidate(usr))
			usr << "<span class='boldnotice'>You are now a candidate in the emergency response team! If there are enough candidates, you may be picked to be part of the team.</span>"
		else
			usr << "<span class='warning'>You did not get enlisted in the response team. Better luck next time!</span>"
		return
	else
		usr << "<span class='warning'>You need to be an observer or new player to use this.</span>"
	return

/datum/emergency_call/proc/activate(var/announce = 1)
	if(!ticker || !ticker.mode) //Something horribly wrong with the gamemode ticker
		return

	if(ticker.mode.has_called_emergency) //It's already been called.
		return

	if(mob_max > 0)
		ticker.mode.waiting_for_candidates = 1
	show_join_message() //Show our potential candidates the message to let them join.
	message_admins("Distress beacon: '[name]' activated. Looking for candidates.", 1)

	if (announce)
		command_announcement.Announce("A distress beacon has been launched from the [MAIN_SHIP_NAME].", "Priority Alert", new_sound='sound/AI/distressbeacon.ogg')

	ticker.mode.has_called_emergency = 1
	spawn(600) //If after 60 seconds we aren't full, abort
		if(candidates.len < mob_min)
			message_admins("Aborting distress beacon, not enough candidates: found [candidates.len].", 1)
			ticker.mode.waiting_for_candidates = 0
			ticker.mode.has_called_emergency = 0
			members = list() //Empty the members list.
			candidates = list()

			if (announce)
				command_announcement.Announce("The distress signal has not received a response, the launch tubes are now recalibrating.", "Distress Beacon")

			ticker.mode.distress_cooldown = 1
			ticker.mode.picked_call = null
			spawn(1200)
				ticker.mode.distress_cooldown = 0
		else //We've got enough!
			//Trim down the list
			var/list/datum/mind/picked_candidates = list()
			if(mob_max > 0)
				for(var/i = 1 to mob_max)
					if(!candidates.len) break//We ran out of candidates, maybe they alienized. Use what we have.
					var/datum/mind/M = pick(candidates) //Get a random candidate, then remove it from the candidates list.
					if(istype(M.current,/mob/living/carbon/Xenomorph))
						candidates.Remove(M) //Strip them from the list, they aren't dead anymore.
						if(!candidates.len) break //NO picking from empty lists
						M = pick(candidates)
					if(!istype(M))//Something went horrifically wrong
						candidates.Remove(M)
						if(!candidates.len) break //No empty lists!!
						M = pick(candidates) //Lets try this again
					picked_candidates.Add(M)
					candidates.Remove(M)
				spawn(3) //Wait for all the above to be done
					if(candidates.len)
						for(var/datum/mind/I in candidates)
							if(I.current)
								I.current << "<span class='warning'>You didn't get selected to join the distress team. Better luck next time!</span>"

			if (announce)
				command_announcement.Announce(dispatch_message, "Distress Beacon", new_sound='sound/AI/distressreceived.ogg') //Announcement that the Distress Beacon has been answered, does not hint towards the chosen ERT

			message_admins("Distress beacon: [src.name] finalized, setting up candidates.", 1)
			var/datum/shuttle/ferry/shuttle = shuttle_controller.shuttles["Distress"]
			if(!shuttle || !istype(shuttle))
				message_admins("Warning: Distress shuttle not found. Aborting.")
				return
			sleep(1)
			spawn_items()
			sleep(1)
			shuttle.launch()
			if(picked_candidates.len)
				var/i = 0
				for(var/datum/mind/M in picked_candidates)
					members += M
					i++
					if(i > mob_max) break //Some logic. Hopefully this will never happen..
					spawn(1 + i)
						create_member(M)
			candidates = null //Blank out the candidates list for next time.
			candidates = list()
			/*
			 * Commented because we can't have nice things
			spawn(1100) //After 100 seconds, send the arrival message. Should be about the right time they make it there.
				command_announcement.Announce(arrival_message, "Docked")
			 */

			spawn(5200)
				shuttle.launch() //Get that fucker back. TODO: Check for occupants.

/datum/emergency_call/proc/add_candidate(var/mob/M)
	if(!M.client) return 0//Not connected
	if(M.mind && M.mind in candidates) return 0//Already there.
	if(istype(M,/mob/living/carbon/Xenomorph) && !M.stat) return 0//Something went wrong
	if(M.mind)
		candidates += M.mind
	else
		if(M.key)
			M.mind = new /datum/mind(M.key)
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

/datum/emergency_call/proc/print_backstory_pmc(var/mob/living/carbon/human/M)
	M << "<B>You were born [pick(75;"in Europe", 15;"in Asia", 10;"on Mars")] to a [pick(75;"well-off", 15;"well-established", 10;"average")] family.</b>"
	M << "<B>Joining the ranks of Weyland Yutani has proven to be very profitable for you.</b>"
	M << "<B>While you are officially an employee, much of your work is off the books. You work as a skilled mercenary.</b>"
	M << "<B>You are [pick(50;"unaware of the xenomorph threat", 15;"acutely aware of the xenomorph threat", 10;"well-informed of the xenomorph threat")]</b>"
	M << ""
	M << ""
	M << "<B>You are part of  Weyland Yutani Task Force Oberon that arrived in 2182 following the UA withdrawl of the Tychon's Rift sector.</b>"
	M << "<B>Task-force Oberon is stationed aboard the USCSS Royce, a powerful Weyland-Yutani cruiser that patrols the outer edges of Tychon's Rift. </b>"
	M << "<B>Under the directive of Weyland-Yutani board member Johan Almric, you act as private security for Weyland Yutani science teams.</b>"
	M << "<B>The USCSS Royce contains a crew of roughly two hundred PMCs, and one hundred scientists and support personnel.</b>"
	M << ""
	M << ""
	M << "<B>Ensure no damage is incurred against Weyland Yutani. Make sure the CL is safe.</b>"
	M << "<B>Deny Weyland-Yutani's involvement and do not trust the UA/USCM forces.</b>"

/datum/emergency_call/proc/print_backstory_upp(var/mob/living/carbon/human/M)
	M << ""
	M << "<B>You grew up in relativly simple family in [pick(75;"Eurasia", 25;"a famished UPP colony")] with few belongings or luxuries. </B>"
	M << "<B>The family you grew up with were [pick(50;"getting by", 25;"impoverished", 25;"starving")] and you were one of [pick(10;"two", 20;"three", 20;"four", 30;"five", 20;"six")] children.</B>"
	M << "<B>You come from a long line of [pick(40;"crop-harvesters", 20;"soldiers", 20;"factory workers", 5;"scientists", 15;"engineers")], and quickly enlisted to improve your living conditions.</B>"
	M << ""
	M << ""
	M << "<B>Following your enlistment UPP military at the age of 17 you were assigned to the 17th 'Smoldering Sons' battalion (six hundred strong) under the command of Colonel Ganbaatar. </B>"
	M << "<B>You were shipped off with the battalion to one of the UPP's most remote territories, a gas giant designated MV-35 in the Anglo-Japanese Arm, in the Tychon's Rift sector.  </B>"
	M << ""
	M << ""
	M << "<B>For the past 14 months, you and the rest of the Smoldering Sons have been stationed at MV-35's only facility, the helium refinery, Altai Station. </B>"
	M << "<B>As MV-35 and Altai Station are the only UPP-held zones in the Tychon's Rift sector for many lightyears, you have spent most of your military career holed up in crammed quarters in near darkness, waiting for supply shipments and transport escort deployments.</B>"
	//M << "<B>you have spent most of your military career holed up in crammed quarters in near darkness, waiting for supply shipments and transport escort deployments.</B>"
	M << ""
	M << ""
	M << "<B>With the recent arrival of the enemy USCM battalion the 'Falling Falcons' and their flagship, the [MAIN_SHIP_NAME], the UPP has felt threatened in the sector. </B>"
	M << "<B>In an effort to protect the vunerable MV-35 from the emproaching UA/USCM imperialists, the leadership of your battalion has opted this the best opportunity to strike at the Falling Falcons to catch them off guard. </B>"
	M << ""
	M << ""
	M << "<font size='3'>\red Glory to Colonel Ganbaatar.</font>"
	M << "<font size='3'>\red Glory to the Smoldering Sons.</font>"
	M << "<font size='3'>\red Glory to the UPP.</font>"
	M << ""
	M << ""
	M << "\blue Use say :3 <text> to speak in your native tongue."
	M << "\blue This allows you to speak privately with your fellow UPP allies."
	M << "\blue Utilize it with your radio to prevent enemy radio interceptions."


/datum/emergency_call/proc/print_backstory_clf(var/mob/living/carbon/human/mob)
	mob << "<B>You grew up [pick(5;"on the UA prison station", 10;"in the LV-624 jungle", 25;"on the farms of LV-771", 25;"in the slums of LV-221", 20;"the red wastes of LV-361", 15;"the icy tundra of LV-571")] to a [pick(50;"poor", 15;"well-off", 35;"average")] family.</B>"
	mob << "<B>As a native of the Tychon's Rift sector, you joined the CLF because [pick(20;"the Dust Raiders killed someone close to you in 2181", 20;"you harbor a strong hatred of the United Americas", 10;"you are a wanted criminal in the United Americas", 5;"have UPP sympathies and want to see the UA driven out of the secor", 10;"you believe the USCM occupation will hurt your quality of life", 5;"are a violent person and want to kill someone for the sake of killing", 20;"want the Tychon's Rift to be free from outsiders", 10;"your militia was absorbed into the CLF")] and are considered a terrorist by the UA.</B>"

	mob << "<B>The Tychon's Rift sector has largely enjoyed its indepdendence..</B>"
	mob << "<B>Though technically part of the United American frontier, many colonists in the Tychon's Rift have enjoyed their freedoms.</B>"
	mob << ""
	mob << "<B>In 2181, however, the United Americas moved the USCM Battalion, the 'Dust Raiders', and the battalion flagship, the USS Alistoun, to the Tychon's Rift sector. </B>"
	mob << "<B>The Dust Raiders responded with deadly force, scattering many of the colonists who attempted to fight their occupation.</B>"
	mob << "<B>The Dust Raiders and their flagship, the USS Alistoun eventually withdrew from the sector by the end of the year.</font></B>"
	mob << "<B> "
	mob << "<B>With the Tychon's Rift sector existing in relative isolation from United America oversight for the last five years, many colonists have considered themselves free from governmental rule.</B>"
	mob << ""
	mob << "<B>The year is now 2186.</B>"
	mob << "<B>The arrival of the USCM Battalion, the Falling Falcons, and their flagship, the USS Almayer, have reaffirmed that the United Americas considers Tychon's Rift part of their holdings.</B>"
	mob << "<B>It is up to you and your fellow colonists to make them realize their trespasses. This sector is no longer theirs.</B>"

/datum/emergency_call/proc/print_backstory_freelancers(var/mob/living/carbon/human/mob)
	mob << "<B> You started off in Tychon's Rift system as a colonist seeking work at one of the established colonies.</b>"
	mob << "<B> The withdrawl of United American forces in the early 2180s, the system fell into disarray.</b>"
	mob << "<B> Taking up arms as a mercenary, the Freelancers have become a powerful force of order in the system.</b>"
	mob << "<B> While they are motivated primarily by money, many colonists see the Freelancers as the main forces of order in Tychon's Rift.</b>"

/datum/emergency_call/proc/create_member(var/datum/mind/M) //This is the parent, each type spawns its own variety.
	return

/datum/emergency_call/pmc/create_member(var/datum/mind/M)
	var/turf/spawn_loc = get_spawn_point()
	var/mob/original = M.current

	if(!istype(spawn_loc)) return //Didn't find a useable spawn point.

	var/mob/living/carbon/human/mob = new(spawn_loc)
	mob.gender = MALE
	var/list/first_names_mb = list("Owen","Luka","Nelson","Branson", "Tyson", "Leo", "Bryant", "Kobe", "Rohan", "Riley", "Aidan", "Watase","Egawa","Hisakawa","Koide")
	var/list/last_names_mb = list("Bates","Shaw","Hansen","Black", "Chambers", "Hall", "Gibson", "Weiss", "Waller", "Burton", "Bakin", "Rohan", "Naomichi", "Yakumo", "Yosai")
	var/datum/preferences/A = new()
	A.randomize_appearance_for(mob)


	mob.real_name = "PMC [pick(first_names_mb)] [pick(last_names_mb)]"
	mob.name = mob.real_name
	mob.age = rand(25,35)
	mob.dna.ready_dna(mob)
	mob.h_style = "Shaved Head"
	mob.f_style = "5 O'clock Shadow"
	mob.r_hair = 25
	mob.g_hair = 25
	mob.b_hair = 35
	mob.s_tone = rand(0,35)
	mob.key = M.key
	if(mob.client) mob.client.view = world.view

//	M.transfer_to(mob)
	mob.mind.skills_list = list("cqc"=SKILL_CQC_MASTER,"endurance"=0,"engineer"=SKILL_ENGINEER_METAL,"firearms"=SKILL_FIREARMS_TRAINED,
		"smartgun"=SKILL_SMART_TRAINED,"heavy_weapons"=SKILL_HEAVY_TRAINED,"leadership"=SKILL_LEAD_NOVICE,"medical"=SKILL_MEDICAL_MEDIC,
		"melee_weapons"=SKILL_MELEE_TRAINED,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_TRAINED,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)


	mob.mind.assigned_role = "PMC"
	ticker.mode.traitors += mob.mind
	spawn(0)
		if(!leader)       //First one spawned is always the leader.
			leader = mob
			spawn_officer(mob)
			mob.mind.special_role = "MODE"
			mob.mind.assigned_role = "PMC Leader"
			print_backstory_pmc(mob)
		else
			mob.mind.special_role = "MODE"
			if(prob(55)) //Randomize the heavy commandos and standard PMCs.
				spawn_standard(mob)
				mob << "<font size='3'>\red You are a Weyland Yutani mercenary!</font>"
				print_backstory_pmc(mob)
			else
				if(prob(30))
					spawn_heavy(mob)
					mob << "<font size='3'>\red You are a Weyland Yutani sniper!</font>"
					print_backstory_pmc(mob)
				else
					spawn_gunner(mob)
					mob << "<font size='3'>\red You are a Weyland Yutani heavy gunner!</font>"
					print_backstory_pmc(mob)

	spawn(10)
		M << "<B>Objectives:</b> [objectives]"

	if(original)
		cdel(original)
	return


/datum/emergency_call/pmc/proc/spawn_standard(mob/M)
	if(!istype(M)) return

	M.arm_equipment(M, "Weyland-Yutani PMC (Standard)")

/datum/emergency_call/pmc/proc/spawn_officer(mob/M)
	if(!istype(M)) return

	M.arm_equipment(M, "Weyland-Yutani PMC (Leader)")

/datum/emergency_call/pmc/proc/spawn_gunner(mob/M)
	if(!istype(M)) return

	M.arm_equipment(M, "Weyland-Yutani PMC (Gunner)")

/datum/emergency_call/pmc/proc/spawn_heavy(mob/M)
	if(!istype(M)) return

	M.arm_equipment(M, "Weyland-Yutani PMC (Sniper)")

/datum/emergency_call/pmc/proc/spawn_xenoborg(var/mob/M) //Deferred for now. Just keep it in mind
	return

/datum/emergency_call/xenos/create_member(var/datum/mind/M)
	var/turf/spawn_loc = get_spawn_point()
	var/mob/original = M.current

	if(!istype(spawn_loc)) return //Didn't find a useable spawn point.
	var/chance = rand(0,3)
	var/mob/living/carbon/Xenomorph/new_xeno
	if(!leader)
		new_xeno = new /mob/living/carbon/Xenomorph/Ravager(spawn_loc)
		leader = new_xeno
	else if(chance == 0)
		new_xeno = new /mob/living/carbon/Xenomorph/Drone/elite(spawn_loc)
	else if(chance == 1)
		new_xeno = new /mob/living/carbon/Xenomorph/Spitter/mature(spawn_loc)
	else
		new_xeno = new /mob/living/carbon/Xenomorph/Hunter/mature(spawn_loc)
	new_xeno.key  = M.key

	if(original) //Just to be sure.
		cdel(original)
	return

/datum/emergency_call/mercs/create_member(var/datum/mind/M, hostile)
	var/turf/spawn_loc = get_spawn_point()
	var/mob/original = M.current

	if(!istype(spawn_loc)) return //Didn't find a useable spawn point.

	var/mob/living/carbon/human/mob = new(spawn_loc)
	mob.gender = pick(80;MALE,20;FEMALE)
	var/datum/preferences/A = new()
	A.randomize_appearance_for(mob)
	var/list/first_names_mcol = list("Alan","Jack","Bil","Jonathan","John","Shiro","Gareth","Clark","Sam", "Lionel", "Aaron", "Charlie", "Scott", "Winston", "Aidan", "Ellis", "Mason", "Wesley", "Nicholas", "Calvin", "Nishikawa", "Hiroto", "Chiba", "Ouchi", "Furuse", "Takagi", "Oba", "Kishimoto")
	var/list/first_names_fcol = list("Emma", "Adelynn", "Mary", "Halie", "Chelsea", "Lexie", "Arya", "Alicia", "Selah", "Amber", "Heather", "Myra", "Heidi", "Charlotte", "Oliva", "Lydia", "Tia", "Riko", "Ari", "Machida", "Ueki", "Mihara", "Noda")
	var/list/last_names_col = list("Hawkins","Rickshaw","Elliot","Billard","Cooper","Fox", "Barlow", "Barrows", "Stewart", "Morgan", "Green", "Stone", "Burr", "Hunt", "Yuko", "Gesshin", "Takanibu", "Tetsuzan", "Tomomi", "Bokkai", "Takesi")
	if(mob.gender == MALE)
		mob.real_name = "[pick(first_names_mcol)] [pick(last_names_col)]"
		mob.f_style = "5 O'clock Shadow"
	else
		mob.real_name = "[pick(first_names_fcol)] [pick(last_names_col)]"
	mob.name = mob.real_name
	mob.age = rand(20,45)
	mob.dna.ready_dna(mob)
	mob.r_hair = 25
	mob.g_hair = 25
	mob.b_hair = 35
	mob.s_tone = rand(0,120)
	mob.key = M.key
	if(mob.client) mob.client.view = world.view
	mob.mind.assigned_role = "MODE"
	mob.mind.special_role = "Mercenary"
	ticker.mode.traitors += mob.mind
	mob.mind.skills_list = list("cqc"=SKILL_CQC_MASTER,"endurance"=0,"engineer"=SKILL_ENGINEER_METAL,"firearms"=SKILL_FIREARMS_TRAINED,
		"smartgun"=SKILL_SMART_TRAINED,"heavy_weapons"=SKILL_HEAVY_TRAINED,"leadership"=SKILL_LEAD_NOVICE,"medical"=SKILL_MEDICAL_MEDIC,
		"melee_weapons"=SKILL_MELEE_TRAINED,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_TRAINED,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)
	spawn(0)
		if(!leader)       //First one spawned is always the leader.
			leader = mob
			spawn_captain(mob)
			mob << "<font size='3'>\red You are the Freelancer leader!</font>"
			print_backstory_freelancers(mob)
			if(hostility)
				mob << "<B> Despite this, you have been tasked to ransack the [MAIN_SHIP_NAME] and kill anyone who gets in your way.</b>"
				mob << "<B> Any UPP, CLF or WY forces also responding are to be considered neutral parties unless proven hostile.</b>"
			else
				mob << "<B> To this end, you have been contacted by Weyland-Yutani of the USCSS Royce to assist the [MAIN_SHIP_NAME]..</b>"
				mob << "<B> Ensure they are not destroyed.</b>"
		else if(medics < max_medics)
			spawn_medic(mob)
			medics++
			mob << "<font size='3'>\red You are a Freelancer medic!</font>"
			print_backstory_freelancers(mob)
			if(hostility)
				mob << "<B> Despite this, you have been tasked to ransack the [MAIN_SHIP_NAME] and kill anyone who gets in your way.</b>"
				mob << "<B> Any UPP, CLF or WY forces also responding are to be considered neutral parties unless proven hostile.</b>"
			else
				mob << "<B> To this end, you have been contacted by Weyland-Yutani of the USCSS Royce to assist the [MAIN_SHIP_NAME]..</b>"
				mob << "<B> Ensure they are not destroyed.</b>"
		else
			spawn_mercenary(mob)
			mob << "<font size='3'>\red You are a Freelancer mercenary!</font>"
			print_backstory_freelancers(mob)
			if(hostility)
				mob << "<B> Despite this, you have been tasked to ransack the [MAIN_SHIP_NAME] and kill anyone who gets in your way.</b>"
				mob << "<B> Any UPP, CLF or WY forces also responding are to be considered neutral parties unless proven hostile.</b>"
			else
				mob << "<B> To this end, you have been contacted by Weyland-Yutani of the USCSS Royce to assist the [MAIN_SHIP_NAME]..</b>"
				mob << "<B> Ensure they are not destroyed.</b>"

	spawn(10)
		M << "<B>Objectives:</b> [objectives]"

	if(original)
		cdel(original)
	return

/datum/emergency_call/mercs/proc/spawn_captain(var/mob/M)
	if(!M || !istype(M)) return

	M.arm_equipment(M, "Freelancer (Leader)")

/datum/emergency_call/mercs/proc/spawn_mercenary(var/mob/M)
	if(!M || !istype(M)) return

	M.arm_equipment(M, "Freelancer (Standard)")

/datum/emergency_call/mercs/proc/spawn_medic(var/mob/M)
	if(!M || !istype(M)) return
	M.arm_equipment(M, "Freelancer (Medic)")
	medics++

///////////////////UPP///////////////////////////

/datum/emergency_call/upp/create_member(var/datum/mind/M)
	var/turf/spawn_loc = get_spawn_point()
	var/mob/original = M.current

	if(!istype(spawn_loc)) return //Didn't find a useable spawn point.

	var/mob/living/carbon/human/mob = new(spawn_loc)
	mob.gender = pick(85;MALE,15;FEMALE)
	var/datum/preferences/A = new()
	A.randomize_appearance_for(mob)
	var/list/first_names_mr = list("Badai","Mongkeemur","Alexei","Andrei","Artyom","Viktor","Xangai","Ivan","Choban","Oleg", "Dayan", "Taghi", "Batu", "Arik", "Orda", "Ghazan", "Bala", "Gao", "Zhan", "Ren", "Hou", "Serafim", "Luca")
	var/list/first_names_fr = list("Altani","Cirina","Anastasiya","Saran","Wei","Oksana","Ren","Svena","Tatyana","Yaroslava", "Miruna", "Flori", "Lucia", "Anica")
	var/list/last_names_r = list("Azarov","Bogdanov","Barsukov","Golovin","Davydov","Khan","Noica","Barbu","Zhukov","Ivanov","Mihai","Kasputin","Belov","Melnikov", "Vasilevsky", "Proca", "Zaituc", "Arcos", "Kubat", "Kral", "Volf")

	if(mob.gender == MALE)
		mob.real_name = "[pick(first_names_mr)] [pick(last_names_r)]"
		mob.f_style = "5 O'clock Shadow"
	else
		mob.real_name = "[pick(first_names_fr)] [pick(last_names_r)]"

	mob.name = mob.real_name
	mob.age = rand(17,35)
	mob.h_style = "Shaved Head"
	mob.r_hair = 15
	mob.g_hair = 15
	mob.b_hair = 25
	mob.r_eyes = 139
	mob.g_eyes = 62
	mob.b_eyes = 19
	mob.dna.ready_dna(mob)
	mob.s_tone = rand(0,40)
	mob.key = M.key
	if(mob.client) mob.client.view = world.view
	mob.mind.assigned_role = "MODE"
	mob.mind.special_role = "UPP"
	ticker.mode.traitors += mob.mind
	mob.mind.skills_list = list("cqc"=SKILL_CQC_MASTER,"endurance"=0,"engineer"=SKILL_ENGINEER_METAL,"firearms"=SKILL_FIREARMS_TRAINED,
		"smartgun"=SKILL_SMART_TRAINED,"heavy_weapons"=SKILL_HEAVY_TRAINED,"leadership"=SKILL_LEAD_NOVICE,"medical"=SKILL_MEDICAL_MEDIC,
		"melee_weapons"=SKILL_MELEE_TRAINED,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_TRAINED,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)
	spawn(0)
		if(!leader)       //First one spawned is always the leader.
			leader = mob
			spawn_officer(mob)
			mob.remove_language("Sol Common")
			mob << "<font size='3'>\red You are an officer of the Union of Progressive People, a powerful socialist state that rivals the United Americas. </B>"
			print_backstory_upp(mob)
		else if(medics < max_medics)
			mob << "<font size='3'>\red You are a medic of the Union of Progressive People, a powerful socialist state that rivals the United Americas. </B>"
			spawn_medic(mob)
			print_backstory_upp(mob)
			medics++
		else if(heavies < max_heavies)
			mob << "<font size='3'>\red You are a soldier of the Union of Progressive People, a powerful socialist state that rivals the United Americas. </B>"
			spawn_heavy(mob)
			print_backstory_upp(mob)
			heavies++
		else
			mob << "<font size='3'>\red You are a soldier of the Union of Progressive People, a powerful socialist state that rivals the United Americas. </B>"
			spawn_standard(mob)
			print_backstory_upp(mob)

	spawn(10)
		M << "<B>Objectives:</b> [objectives]"

	mob.add_language("Russian")

	if(original)
		cdel(original)
	return


/datum/emergency_call/upp/proc/spawn_standard(var/mob/M)
	if(!M || !istype(M)) return

	M.arm_equipment(M, "UPP Soldier (Standard)")

/datum/emergency_call/upp/proc/spawn_heavy(var/mob/M)
	if(!M || !istype(M)) return

	M.arm_equipment(M, "UPP Soldier (Heavy)")

/datum/emergency_call/upp/proc/spawn_medic(var/mob/M)
	if(!M || !istype(M)) return

	M.arm_equipment(M, "UPP Soldier (Medic)")

/datum/emergency_call/upp/proc/spawn_officer(var/mob/M)
	if(!M || !istype(M)) return

	M.arm_equipment(M, "UPP Soldier (Leader)")

//UPP COMMANDOS

/datum/emergency_call/upp_commando/create_member(var/datum/mind/M)
	var/turf/spawn_loc = get_spawn_point()
	var/mob/original = M.current

	if(!istype(spawn_loc)) return //Didn't find a useable spawn point.

	var/mob/living/carbon/human/mob = new(spawn_loc)
	mob.gender = pick(90;MALE,10;FEMALE)
	var/datum/preferences/A = new()
	A.randomize_appearance_for(mob)
	var/list/first_names_mr = list("Badai","Mongkeemur","Alexei","Andrei","Artyom","Viktor","Xangai","Ivan","Choban","Oleg", "Dayan", "Taghi", "Batu", "Arik", "Orda", "Ghazan", "Bala", "Gao", "Zhan", "Ren", "Hou", "Serafim", "Luca")
	var/list/first_names_fr = list("Altani","Cirina","Anastasiya","Saran","Wei","Oksana","Ren","Svena","Tatyana","Yaroslava", "Miruna", "Flori", "Lucia", "Anica")
	var/list/last_names_r = list("Azarov","Bogdanov","Barsukov","Golovin","Davydov","Khan","Noica","Barbu","Zhukov","Ivanov","Mihai","Kasputin","Belov","Melnikov", "Vasilevsky", "Proca", "Zaituc", "Arcos", "Kubat", "Kral", "Volf")

	if(mob.gender == MALE)
		mob.real_name = "[pick(first_names_mr)] [pick(last_names_r)]"
		mob.f_style = "7 O'clock Shadow"
	else
		mob.real_name = "[pick(first_names_fr)] [pick(last_names_r)]"

	mob.name = mob.real_name
	mob.age = rand(25,35)
	mob.h_style = "Shaved Head"
	mob.r_hair = 15
	mob.g_hair = 15
	mob.b_hair = 25
	mob.r_eyes = 139
	mob.g_eyes = 62
	mob.b_eyes = 19
	mob.dna.ready_dna(mob)
	mob.s_tone = rand(0,40)
	mob.key = M.key
	if(mob.client) mob.client.view = world.view
	mob.mind.assigned_role = "MODE"
	mob.mind.special_role = "UPP"
	ticker.mode.traitors += mob.mind
	mob.mind.skills_list = list("cqc"=SKILL_CQC_MASTER,"endurance"=0,"engineer"=SKILL_ENGINEER_METAL,"firearms"=SKILL_FIREARMS_TRAINED,
		"smartgun"=SKILL_SMART_TRAINED,"heavy_weapons"=SKILL_HEAVY_TRAINED,"leadership"=SKILL_LEAD_NOVICE,"medical"=SKILL_MEDICAL_MEDIC,
		"melee_weapons"=SKILL_MELEE_TRAINED,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_TRAINED,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)
	spawn(0)
		if(!leader)       //First one spawned is always the leader.
			leader = mob
			spawn_officer(mob)
			mob.remove_language("Sol Common")
			mob << "<font size='3'>\red You are a commando officer of the Union of Progressive People, a powerful socialist state that rivals the United Americas. </B>"
			print_backstory_upp(mob)
		else if(medics < max_medics)
			mob << "<font size='3'>\red You are a commando medic of the Union of Progressive People, a powerful socialist state that rivals the United Americas. </B>"
			spawn_medic(mob)
			print_backstory_upp(mob)
			medics++
		else
			mob << "<font size='3'>\red You are a commando of the Union of Progressive People, a powerful socialist state that rivals the United Americas. </B>"
			spawn_standard(mob)
			print_backstory_upp(mob)

	spawn(10)
		M << "<B>Objectives:</b> [objectives]"

	mob.add_language("Russian")

	if(original)
		cdel(original)
	return


/datum/emergency_call/upp_commando/proc/spawn_standard(var/mob/M)
	if(!M || !istype(M)) return

	M.arm_equipment(M, "UPP Commando (Standard)")

/datum/emergency_call/upp_commando/proc/spawn_medic(var/mob/M)
	if(!M || !istype(M)) return

	M.arm_equipment(M, "UPP Commando (Medic)")

/datum/emergency_call/upp_commando/proc/spawn_officer(var/mob/M)
	if(!M || !istype(M)) return

	M.arm_equipment(M, "UPP Commando (Leader)")


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
	if(mob.client) mob.client.view = world.view
	mob.mind.assigned_role = "MODE"
	mob.mind.special_role = "Pizza"
	ticker.mode.traitors += mob.mind
	mob.mind.skills_list = list("cqc"=SKILL_CQC_MASTER,"endurance"=0,"engineer"=SKILL_ENGINEER_METAL,"firearms"=SKILL_FIREARMS_TRAINED,
		"smartgun"=SKILL_SMART_TRAINED,"heavy_weapons"=SKILL_HEAVY_TRAINED,"leadership"=SKILL_LEAD_NOVICE,"medical"=SKILL_MEDICAL_MEDIC,
		"melee_weapons"=SKILL_MELEE_TRAINED,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_TRAINED,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)
	spawn(0)
		spawn_pizza(mob)
		var/pizzatxt = pick("Discount Pizza","Pizza Kingdom","Papa Pizza")
		mob << "<font size='3'>\red You are a pizza deliverer! Your employer is the [pizzatxt] Corporation.</font>"
		mob << "Your job is to deliver your pizzas. You're PRETTY sure this is the right place.."
	spawn(10)
		M << "<B>Objectives:</b> [objectives]"

	if(original)
		cdel(original)
	return

/datum/emergency_call/pizza/proc/spawn_pizza(var/mob/M)
	if(!M || !istype(M)) return

	M.equip_to_slot_or_del(new /obj/item/clothing/under/pizza(M), WEAR_BODY)
	M.equip_to_slot_or_del(new /obj/item/clothing/head/soft/red(M), WEAR_HEAD)
	M.equip_to_slot_or_del(new /obj/item/clothing/shoes/red(M), WEAR_FEET)
	M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(M), WEAR_BACK)
	M.equip_to_slot_or_del(new /obj/item/pizzabox/margherita(M), WEAR_R_HAND)
	M.equip_to_slot_or_del(new /obj/item/device/radio(M), WEAR_R_STORE)
	M.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/food/drinks/cans/dr_gibb(M), WEAR_L_STORE)
	M.equip_to_slot_or_del(new /obj/item/device/flashlight(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/pizzabox/vegetable(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/pizzabox/mushroom(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/pizzabox/meat(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/food/drinks/cans/dr_gibb(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/food/drinks/cans/thirteenloko(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/holdout(M.back), WEAR_IN_BACK)

	var/obj/item/weapon/card/id/W = new(src)
	W.assignment = "Pizza Deliverer"
	W.registered_name = M.real_name
	W.name = "[M.real_name]'s ID Card ([W.assignment])"
	W.icon_state = "centcom"
	W.access = get_freelancer_access()
	M.equip_to_slot_or_del(W, WEAR_ID)

//Spawn various items around the shuttle area thing.
/datum/emergency_call/proc/spawn_items()
	return

/datum/emergency_call/pmc/spawn_items()
	var/turf/drop_spawn
	var/choice

	for(var/i = 0 to 0) //Spawns up to 3 random things.
		if(prob(20)) continue
		choice = (rand(1,8) - round(i/2)) //Decreasing values, rarer stuff goes at the end.
		if(choice < 0) choice = 0
		drop_spawn = get_spawn_point(1)
		if(istype(drop_spawn))
			switch(choice)
				if(0)
					new /obj/item/weapon/gun/smg/m39/elite(drop_spawn)
					new /obj/item/weapon/gun/smg/m39/elite(drop_spawn)
					new /obj/item/ammo_magazine/smg/m39/ap
					new /obj/item/ammo_magazine/smg/m39/ap
					continue
				if(1)
					new /obj/item/weapon/gun/smg/m39/elite(drop_spawn)
					new /obj/item/weapon/gun/smg/m39/elite(drop_spawn)
					new /obj/item/ammo_magazine/smg/m39/ap
					new /obj/item/ammo_magazine/smg/m39/ap
					continue
				if(2)
					new /obj/item/weapon/gun/flamer(drop_spawn)
					new /obj/item/weapon/gun/flamer(drop_spawn)
					new /obj/item/weapon/gun/flamer(drop_spawn)
					continue
				if(3)
					new /obj/item/weapon/plastique(drop_spawn)
					new /obj/item/weapon/plastique(drop_spawn)
					new /obj/item/weapon/plastique(drop_spawn)
					continue
				if(4)
					new /obj/item/weapon/gun/rifle/m41a/elite(drop_spawn)
					new /obj/item/weapon/gun/rifle/m41a/elite(drop_spawn)
					new /obj/item/ammo_magazine/rifle/incendiary
					new /obj/item/ammo_magazine/rifle/incendiary
					continue
				if(5)
					new /obj/item/weapon/gun/launcher/m92(drop_spawn)
					new /obj/item/weapon/grenade/explosive/PMC(drop_spawn)
					new /obj/item/weapon/grenade/explosive/PMC(drop_spawn)
					new /obj/item/weapon/grenade/explosive/PMC(drop_spawn)
					continue
				if(6)
					new /obj/item/weapon/grenade/explosive/PMC(drop_spawn)
					new /obj/item/weapon/gun/flamer(drop_spawn)
					continue
				if(7)
					new /obj/item/weapon/grenade/explosive/PMC(drop_spawn)
					new /obj/item/weapon/grenade/explosive/PMC(drop_spawn)
					new /obj/item/weapon/grenade/explosive/PMC(drop_spawn)
					new /obj/item/weapon/gun/flamer(drop_spawn)
					continue
	return

/datum/emergency_call/supplies/spawn_items()
	var/turf/drop_spawn
	var/choice

	for(var/i = 1 to 3) //Spawns up to 3 random things.
		if(prob(20)) continue
		choice = (rand(1,8) - round(i/2)) //Decreasing values, rarer stuff goes at the end.
		if(choice < 0) choice = 0
		drop_spawn = get_spawn_point(1)
		if(istype(drop_spawn))
			switch(choice)
				if(0)
					new /obj/item/weapon/gun/pistol/m4a3(drop_spawn)
					new /obj/item/weapon/gun/pistol/m1911(drop_spawn)
					new /obj/item/ammo_magazine/pistol/extended(drop_spawn)
					new /obj/item/ammo_magazine/pistol/extended(drop_spawn)
					new /obj/item/ammo_magazine/pistol/ap(drop_spawn)
					new /obj/item/ammo_magazine/pistol/incendiary(drop_spawn)
				if(1)
					new /obj/item/weapon/gun/smg/m39(drop_spawn)
					new /obj/item/weapon/gun/smg/m39(drop_spawn)
					new /obj/item/ammo_magazine/smg/m39/extended(drop_spawn)
					new /obj/item/ammo_magazine/smg/m39/extended(drop_spawn)
					new /obj/item/ammo_magazine/smg/m39/ap(drop_spawn)
					new /obj/item/ammo_magazine/smg/m39/ap(drop_spawn)
				if(2)
					new /obj/item/weapon/gun/flamer(drop_spawn)
					new /obj/item/weapon/gun/flamer(drop_spawn)
					new /obj/item/weapon/gun/flamer(drop_spawn)
				if(3)
					new /obj/item/weapon/plastique(drop_spawn)
					new /obj/item/weapon/plastique(drop_spawn)
					new /obj/item/weapon/plastique(drop_spawn)
					new /obj/item/weapon/grenade/explosive/PMC(drop_spawn)
					new /obj/item/weapon/grenade/explosive/PMC(drop_spawn)
					new /obj/item/weapon/grenade/explosive/PMC(drop_spawn)
				if(4)
					new /obj/item/weapon/gun/rifle/m41a(drop_spawn)
					new /obj/item/weapon/gun/rifle/m41a(drop_spawn)
					new /obj/item/ammo_magazine/rifle/extended(drop_spawn)
					new /obj/item/ammo_magazine/rifle/extended(drop_spawn)
					new /obj/item/ammo_magazine/rifle/incendiary(drop_spawn)
					new /obj/item/ammo_magazine/rifle/incendiary(drop_spawn)
					new /obj/item/ammo_magazine/rifle/ap(drop_spawn)
					new /obj/item/ammo_magazine/rifle/ap(drop_spawn)
				if(5)
					new /obj/item/weapon/gun/shotgun/combat(drop_spawn)
					new /obj/item/weapon/gun/shotgun/combat(drop_spawn)
					new /obj/item/ammo_magazine/shotgun/incendiary(drop_spawn)
					new /obj/item/ammo_magazine/shotgun/incendiary(drop_spawn)
				if(6)
					new /obj/item/weapon/gun/rifle/m41a/scoped(drop_spawn)
					new /obj/item/weapon/gun/rifle/m41a/scoped(drop_spawn)
					new /obj/item/ammo_magazine/rifle/marksman(drop_spawn)
					new /obj/item/ammo_magazine/rifle/marksman(drop_spawn)
				if(7)
					new /obj/item/weapon/gun/rifle/lmg(drop_spawn)
					new /obj/item/weapon/gun/rifle/lmg(drop_spawn)
					new /obj/item/ammo_magazine/rifle/lmg(drop_spawn)
					new /obj/item/ammo_magazine/rifle/lmg(drop_spawn)

/*
/datum/emergency_call/upp/spawn_items()
	var/turf/drop_spawn
	var/choice

	for(var/i = 0 to 0) //Spawns up to 3 random things.Disabled
		if(prob(10)) continue
		choice = (rand(1,8) - round(i/2)) //Decreasing values, rarer stuff goes at the end.
		if(choice < 0) choice = 0
		drop_spawn = get_spawn_point(1)
		if(istype(drop_spawn))
			switch(choice)
				if(0)
					new/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka(drop_spawn)
					new/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka(drop_spawn)
					//new /obj/item/weapon/storage/box/rocket_system(drop_spawn)
					continue
				if(1)
					new /obj/item/weapon/gun/flamer(drop_spawn)
					new/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka(drop_spawn)
					continue
				if(2)
					new /obj/item/weapon/reagent_containers/hypospray/tricordrazine(drop_spawn)
					new /obj/item/weapon/shield/riot(drop_spawn)
					new /obj/item/weapon/reagent_containers/food/drinks/bottle/vodka(drop_spawn)
					continue
				if(3)
					new /obj/item/weapon/plastique(drop_spawn)
					new /obj/item/weapon/plastique(drop_spawn)
					new /obj/item/weapon/plastique(drop_spawn)
					continue
				if(4)
					new/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka(drop_spawn)
					new /obj/item/weapon/shield/riot(drop_spawn)
					continue
				if(5)
					new /obj/item/weapon/grenade/explosive(drop_spawn)
					new /obj/item/weapon/grenade/explosive(drop_spawn)
					new /obj/item/weapon/grenade/explosive(drop_spawn)
					//new /obj/item/weapon/storage/box/rocket_system(drop_spawn)
					continue
				if(6)
					new/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka(drop_spawn)
					new /obj/item/weapon/gun/flamer(drop_spawn)
					continue
				if(7)
					new/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka(drop_spawn)
					//new /obj/item/weapon/storage/box/rocket_system(drop_spawn)
					continue
*/
/datum/emergency_call/colonist/create_member(datum/mind/M) //Blank ERT with only basic items.
	var/turf/T = get_spawn_point()
	var/mob/original = M.current

	if(!istype(T)) r_FAL

	var/mob/living/carbon/human/H = new(T)
	H.gender = pick(MALE, FEMALE)
	var/datum/preferences/A = new
	A.randomize_appearance_for(H)
	H.real_name = capitalize(pick(H.gender == MALE ? first_names_male : first_names_female)) + " " + capitalize(pick(last_names))
	H.name = H.real_name
	H.age = rand(21,45)
	H.dna.ready_dna(H)
	H.key = M.key
	if(H.client) H.client.view = world.view
	H.mind.assigned_role = "Colonist"
	H.mind.special_role = "MODE"
	ticker.mode.traitors += H.mind
	H.mind.skills_list = null //no restriction
	H.equip_to_slot_or_del(new /obj/item/clothing/under/colonist(H), WEAR_BODY)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(H), WEAR_FEET)
	H.equip_to_slot(new /obj/item/weapon/combat_knife(H), WEAR_L_STORE)
	H.equip_to_slot(new /obj/item/device/flashlight(H), WEAR_R_STORE)

	spawn(20)
		if(H && H.loc)
			H << "<span class='role_header'>You are a colonist!</span>"
			H << "<span class='role_body'>You have been put into the game by a staff member. Please follow all staff instructions.</span>"

	if(original && original.loc) cdel(original)

/datum/emergency_call/clf/create_member(var/datum/mind/M)
	var/turf/spawn_loc = get_spawn_point()
	var/mob/original = M.current

	if(!istype(spawn_loc)) return //Didn't find a useable spawn point.

	var/mob/living/carbon/human/mob = new(spawn_loc)
	mob.gender = pick(65;MALE, 35;FEMALE)
	var/list/first_names_mreb = list("Alan","Jack","Bil","Jonathan","John","Shiro","Gareth","Clark","Sam", "Lionel", "Aaron", "Charlie", "Scott", "Winston", "Aidan", "Ellis", "Mason", "Wesley", "Nicholas", "Calvin", "Nishikawa", "Hiroto", "Chiba", "Ouchi", "Furuse", "Takagi", "Oba", "Kishimoto")
	var/list/first_names_freb = list("Emma", "Adelynn", "Mary", "Halie", "Chelsea", "Lexie", "Arya", "Alicia", "Selah", "Amber", "Heather", "Myra", "Heidi", "Charlotte", "Oliva", "Lydia", "Tia", "Riko", "Ari", "Machida", "Ueki", "Mihara", "Noda")
	var/list/last_names_reb = list("Hawkins","Rickshaw","Elliot","Billard","Cooper","Fox", "Barlow", "Barrows", "Stewart", "Morgan", "Green", "Stone", "Burr", "Hunt", "Yuko", "Gesshin", "Takanibu", "Tetsuzan", "Tomomi", "Bokkai", "Takesi")
	if(mob.gender == MALE)
		mob.real_name = "[pick(first_names_mreb)] [pick(last_names_reb)]"
	else
		mob.real_name = "[pick(first_names_freb)] [pick(last_names_reb)]"
	mob.name = mob.real_name
	mob.age = rand(17,45)
	mob.dna.ready_dna(mob)
	mob.key = M.key
	if(mob.client) mob.client.view = world.view
	mob.mind.assigned_role = "MODE"
	mob.mind.special_role = "CLF"
	ticker.mode.traitors += mob.mind
	mob.r_hair = 25
	mob.g_hair = 25
	mob.b_hair = 35
	mob.r_eyes = 139
	mob.g_eyes = 62
	mob.b_eyes = 19
	mob.s_tone = rand(0,90)
	mob.mind.skills_list = list("cqc"=SKILL_CQC_MASTER,"endurance"=0,"engineer"=SKILL_ENGINEER_METAL,"firearms"=SKILL_FIREARMS_TRAINED,
		"smartgun"=SKILL_SMART_TRAINED,"heavy_weapons"=SKILL_HEAVY_TRAINED,"leadership"=SKILL_LEAD_NOVICE,"medical"=SKILL_MEDICAL_MEDIC,
		"melee_weapons"=SKILL_MELEE_TRAINED,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_TRAINED,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)
	spawn(0)
		if(!leader)       //First one spawned is always the leader.
			mob << "<font size='4'>\red You are a leader of the local resistance group, the Colonial Liberation Front."
			spawn_officer(mob)
			print_backstory_clf(mob)
			leader = mob
		else if(medics < max_medics)
			mob << "<font size='4'>\red You are a medic of the local resistance group, the Colonial Liberation Front."
			spawn_medic(mob)
			print_backstory_clf(mob)
			medics++
		else
			mob << "<font size='4'>\red You are a member of the local resistance group, the Colonial Liberation Front."
			spawn_standard(mob)
			print_backstory_clf(mob)

	spawn(10)
		M << "<B>Objectives:</b> [objectives]"

	if(original)
		cdel(original)
	return


/datum/emergency_call/clf/proc/spawn_standard(var/mob/M)
	if(!M || !istype(M)) return

	M.arm_equipment(M, "CLF Fighter (Standard)")

/datum/emergency_call/clf/proc/spawn_medic(var/mob/M)
	if(!M || !istype(M)) return

	M.arm_equipment(M, "CLF Fighter (Medic)")

/datum/emergency_call/clf/proc/spawn_officer(var/mob/M)
	if(!M || !istype(M)) return

	M.arm_equipment(M, "CLF Fighter (Leader)")

// DEATH SQUAD--------------------------------------------------------------------------------
/datum/emergency_call/death/create_member(var/datum/mind/M)
	var/turf/spawn_loc = get_spawn_point()
	var/mob/original = M.current

	if(!istype(spawn_loc)) return //Didn't find a useable spawn point.

	var/mob/living/carbon/human/mob = new(spawn_loc)
	mob.gender = pick(MALE)
	//var/datum/preferences/A = new()
	//A.randomize_appearance_for(mob)
	var/list/first_names_mr = list("Alpha","Beta","Delta","Gamma","Epsilon","Omega","Zeta","Theta","Lambda","Sigma")
	if(mob.gender == MALE)
		mob.real_name = "[pick(first_names_mr)]"
	else
		mob.real_name = "[pick(first_names_mr)]"
	mob.name = mob.real_name
	mob.age = rand(17,45)
	mob.dna.ready_dna(mob)
	mob.key = M.key
	if(mob.client) mob.client.view = world.view
	mob.mind.assigned_role = "MODE"
	mob.mind.special_role = "DEATH SQUAD"
	ticker.mode.traitors += mob.mind
	mob.mind.skills_list = list("cqc"=SKILL_CQC_MASTER,"endurance"=0,"engineer"=SKILL_ENGINEER_METAL,"firearms"=SKILL_FIREARMS_TRAINED,
		"smartgun"=SKILL_SMART_TRAINED,"heavy_weapons"=SKILL_HEAVY_TRAINED,"leadership"=SKILL_LEAD_NOVICE,"medical"=SKILL_MEDICAL_MEDIC,
		"melee_weapons"=SKILL_MELEE_TRAINED,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_TRAINED,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)
	spawn(0)
		if(!leader)       //First one spawned is always the leader.
			leader = mob
			spawn_officer(mob)
			mob << "<font size='3'>\red You are the Death Squad Leader!</font>"
			mob << "<B> You must clear out any traces of the infestation and it's survivors..</b>"
			mob << "<B> Follow any orders directly from Weyland-Yutani!</b>"
		else
			spawn_standard(mob)
			mob << "<font size='3'>\red You are a Death Squad Commando!!</font>"
			mob << "<B> You must clear out any traces of the infestation and it's survivors..</b>"
			mob << "<B> Follow any orders directly from Weyland-Yutani!</b>"

	spawn(10)
		M << "<B>Objectives:</b> [objectives]"

	if(original)
		cdel(original)
	return


/datum/emergency_call/death/proc/spawn_standard(var/mob/M)
	if(!M || !istype(M)) return
	M.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/commando(M), WEAR_EAR)
	M.equip_to_slot_or_del(new /obj/item/clothing/glasses/m42_goggles	(M), WEAR_EYES)
	M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/PMC/commando(M), WEAR_BODY)
	M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/veteran/PMC/commando(M), WEAR_JACKET)
	M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC/commando(M), WEAR_HANDS)
	M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/PMC/commando(M), WEAR_HEAD)
	M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/commando(M), WEAR_BACK)
	M.equip_to_slot_or_del(new /obj/item/clothing/shoes/veteran/PMC/commando(M), WEAR_FEET)
	M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMC(M), WEAR_FACE)
	M.equip_to_slot_or_del(new /obj/item/weapon/tank/emergency_oxygen/engi(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/weapon/grenade/incendiary(M), WEAR_L_STORE)
	M.equip_to_slot_or_del(new /obj/item/weapon/plastique(M), WEAR_R_STORE)
	M.equip_to_slot_or_del(new /obj/item/weapon/gun/revolver/mateba(M), WEAR_WAIST)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/revolver/mateba(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/m41a/elite(M), WEAR_J_STORE)

	var/obj/item/weapon/card/id/W = new(src)
	W.assignment = "Deathsquad"
	W.registered_name = M.real_name
	W.name = "[M.real_name]'s ID Card ([W.assignment])"
	W.icon_state = "centcom"
	W.access = get_antagonist_pmc_access()
	M.equip_to_slot_or_del(W, WEAR_ID)

/datum/emergency_call/death/proc/spawn_officer(var/mob/M)
	if(!M || !istype(M)) return

	M.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/commando(M), WEAR_EAR)
	M.equip_to_slot_or_del(new /obj/item/clothing/glasses/m42_goggles	(M), WEAR_EYES)
	M.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/PMC/commando(M), WEAR_BODY)
	M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/veteran/PMC/commando(M), WEAR_JACKET)
	M.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC/commando(M), WEAR_HANDS)
	M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/PMC/commando(M), WEAR_HEAD)
	M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/commando(M), WEAR_BACK)
	M.equip_to_slot_or_del(new /obj/item/clothing/shoes/veteran/PMC/commando(M), WEAR_FEET)
	M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMC/leader(M), WEAR_FACE)
	M.equip_to_slot_or_del(new /obj/item/weapon/tank/emergency_oxygen/engi(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/weapon/grenade/incendiary(M), WEAR_L_STORE)
	M.equip_to_slot_or_del(new /obj/item/weapon/plastique(M), WEAR_R_STORE)
	M.equip_to_slot_or_del(new /obj/item/weapon/gun/revolver/mateba(M), WEAR_WAIST)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/revolver/mateba(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap(M.back), WEAR_IN_BACK)
	M.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/m41a/elite(M), WEAR_J_STORE)

	var/obj/item/weapon/card/id/W = new(src)
	W.assignment = "Deathsquad Leader"
	W.registered_name = M.real_name
	W.name = "[M.real_name]'s ID Card ([W.assignment])"
	W.icon_state = "centcom"
	W.access = get_antagonist_pmc_access()
	M.equip_to_slot_or_del(W, WEAR_ID)
