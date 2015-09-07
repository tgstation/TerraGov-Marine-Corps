
//This datum keeps track of individual squads. New squads can be added without any problem but to give them
//access you must add them individually to access.dm with the other squads. Just look for "access_alpha" and add the new one

//Note: some important procs are held by the job controller, in job_controller.dm.
//In particular, get_lowest_squad() and randomize_squad()


/datum/squad
	var/name = "Empty Squad"  //Name of the squad
	var/max_positions = -1 //Maximum number allowed in a squad. Defaults to infinite
	var/color = 0 //Color for helmets, etc.
	var/list/access = list() //Which special access do we grant them
	var/usable = 0	 //Is it a valid squad?
	var/no_random_spawn = 0 //Stop players from spawning into the squad
	var/max_engineers = 2 //maximum # of engineers allowed in squad
	var/max_medics = 2 //Ditto, squad medics
	var/max_specialists = 1
	var/num_specialists = 0
	var/max_leaders = 1
	var/num_leaders = 0
	var/radio_freq = 1461 //Squad radio headset frequency.
	//vvv Do not set these in squad defines
	var/mob/living/carbon/human/squad_leader = null //Who currently leads it.
	var/num_engineers = 0
	var/num_medics = 0
	var/count = 0 //Current # in the squad
	var/list/current_squads = list()

	var/mob/living/carbon/human/overwatch_officer = null //Who's overwatching this squad?
	var/supply_timer = 0 //Timer for supply drops
	var/bomb_timer = 0 //Timer for orbital bombardment
	var/primary_objective = null //Text strings
	var/secondary_objective = null
	var/obj/item/device/squad_beacon/sbeacon = null
	var/obj/item/device/squad_beacon/bomb/bbeacon = null
	var/obj/item/effect/drop_pad = null
	//^^^

/datum/squad/alpha
	name = "Alpha"
	color = 1
	access = list(access_squad_alpha)
	usable = 1
	radio_freq = ALPHA_FREQ

/datum/squad/bravo
	name = "Bravo"
	color = 2
	access = list(access_squad_bravo)
	usable = 1
	radio_freq = BRAVO_FREQ

/datum/squad/charlie
	name = "Charlie"
	color = 3
	access = list(access_squad_charlie)
	usable = 1
	radio_freq = CHARLIE_FREQ

/datum/squad/delta
	name = "Delta"
	color = 4
	access = list(access_squad_delta)
	usable = 1
	radio_freq = DELTA_FREQ


//Straight-up insert a marine into a squad.
//This sets their ID, increments the total count, and so on. Everything else is done in job_controller.dm.
//So it does not check if the squad is too full already, or randomize it, etc.
/datum/squad/proc/put_marine_in_squad(var/mob/living/carbon/human/M)
	if(!M || !istype(M,/mob/living/carbon/human)) return 0//Logic
	if(!src.usable) return 0
	if(!M.mind) return 0
	if(!M.mind.assigned_role || M.mind.assigned_squad) return 0//Not yet

	var/obj/item/weapon/card/id/C = null
	C = M.wear_id
	if(!C) C = M.get_active_hand()
	if(!C) return 0//Abort, no ID found

	if(M.mind.assigned_role == "Squad Engineer") src.num_engineers++
	if(M.mind.assigned_role == "Squad Medic") src.num_medics++
	if(M.mind.assigned_role == "Squad Specialist") src.num_specialists++
	if(M.mind.assigned_role == "Squad Leader") //If more than one leader are somehow added, it will replace the old with new.
		src.squad_leader = M
		src.num_leaders++

	src.count++ //Add up the tally. This is important in even squad distribution.

	M.mind.assigned_squad = src //Add them to the squad
	var/c_oldass = C.assignment
	C.access += src.access //Add their squad access to their ID
	C.assignment = "[src.name] [c_oldass]"
	C.name = "[C.registered_name]'s ID Card ([C.assignment])"
	return 1

//Not a safe proc. Returns null if squads or jobs aren't set up.
//Mostly used in the marine squad console in marine_consoles.dm.
/proc/get_squad_by_name(var/text)
	if(!job_master || job_master.squads.len == 0)
		return null

	for(var/datum/squad/S in job_master.squads)
		if(S.name == text)
			return S

	return null

//Slightly different, returns the squad itself via the ID.
/proc/get_squad_data_from_card(var/mob/living/carbon/human/H)
	if(!istype(H))	return null

	var/text = null
	var/obj/item/device/pda/I = H.wear_id
	var/obj/item/weapon/card/id/card = null

	if(I && istype(I))
		if(I.id)
			card = I.id
	else
		card = H.wear_id

	if(!card || !istype(card))
		return null

	if(findtext(card.assignment, "Alpha")) text = "Alpha"
	if(findtext(card.assignment, "Bravo")) text = "Bravo"
	if(findtext(card.assignment, "Charlie")) text = "Charlie"
	if(findtext(card.assignment, "Delta")) text = "Delta"

	return get_squad_by_name(text)

//These are to handle the tick timers on the supply drops, so they aren't reset if Overwatch changes squads.
/datum/squad/proc/handle_stimer(var/ticks)
	supply_timer = 1
	spawn(ticks)
		supply_timer = 0
	return

/datum/squad/proc/handle_btimer(var/ticks)
	bomb_timer = 1
	spawn(ticks)
		bomb_timer = 0
	return

/proc/get_squad_from_card(var/mob/living/carbon/human/H)
	if(!istype(H))	return 0

	var/squad = 0
	var/obj/item/device/pda/I = H.wear_id
	var/obj/item/weapon/card/id/card = null

	if(I && istype(I))
		if(I.id)
			card = I.id
	else
		card = H.wear_id

	if(!card || !istype(card))
		return 0

	if(findtext(card.assignment, "Alpha"))
		squad = 1 //Returns the card's numeric squad so we can pull the armor colors.
		if(H.mind)
			H.mind.assigned_squad = get_squad_by_name("Alpha") //Sets their assigned squad so Overwatch can grab it.
	else if(findtext(card.assignment, "Bravo"))
		squad = 2
		if(H.mind)
			H.mind.assigned_squad = get_squad_by_name("Bravo")
	else if(findtext(card.assignment, "Charlie"))
		squad = 3
		if(H.mind)
			H.mind.assigned_squad = get_squad_by_name("Charlie")
	else if(findtext(card.assignment, "Delta"))
		squad = 4
		if(H.mind)
			H.mind.assigned_squad = get_squad_by_name("Delta")
	else
		return 0

	return squad

/proc/is_leader_from_card(var/mob/living/carbon/human/H)
	if(!istype(H)) return 0

	var/obj/item/device/pda/I = H.wear_id
	var/obj/item/weapon/card/id/card = null

	if(I && istype(I))
		if(I.id)
			card = I.id
	else
		card = H.wear_id

	if(!card || !istype(card))
		return 0

	if(findtext(card.assignment, "Leader"))
		return 1

	return 0
