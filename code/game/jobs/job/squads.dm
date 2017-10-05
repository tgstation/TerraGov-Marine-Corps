
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
	var/max_smartgun = 1
	var/num_smartgun = 0
	var/max_leaders = 1
	var/num_leaders = 0
	var/radio_freq = 1461 //Squad radio headset frequency.
	//vvv Do not set these in squad defines
	var/mob/living/carbon/human/squad_leader = null //Who currently leads it.
	var/num_engineers = 0
	var/num_medics = 0
	var/count = 0 //Current # in the squad
	var/list/marines_list = list() // list of mobs (or name, not always a mob ref) in that squad.

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
	access = list(ACCESS_MARINE_ALPHA)
	usable = 1
	radio_freq = ALPHA_FREQ

/datum/squad/bravo
	name = "Bravo"
	color = 2
	access = list(ACCESS_MARINE_BRAVO)
	usable = 1
	radio_freq = BRAVO_FREQ

/datum/squad/charlie
	name = "Charlie"
	color = 3
	access = list(ACCESS_MARINE_CHARLIE)
	usable = 1
	radio_freq = CHARLIE_FREQ

/datum/squad/delta
	name = "Delta"
	color = 4
	access = list(ACCESS_MARINE_DELTA)
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

	switch(M.mind.assigned_role)
		if("Squad Engineer") num_engineers++
		if("Squad Medic") num_medics++
		if("Squad Specialist") num_specialists++
		if("Squad Smartgunner") num_smartgun++
		if("Squad Leader")
			if(squad_leader && (!squad_leader.mind || squad_leader.mind.previous_squad_role)) //field promoted SL
				demote_squad_leader() //replaced by the real one
			squad_leader = M
			if(!M.mind.previous_squad_role) //field promoted SL don't count as real ones
				num_leaders++

	src.count++ //Add up the tally. This is important in even squad distribution.

	marines_list += M

	M.mind.assigned_squad = src //Add them to the squad
	var/c_oldass = C.assignment
	C.access += src.access //Add their squad access to their ID
	C.assignment = "[name] [c_oldass]"
	C.name = "[C.registered_name]'s ID Card ([C.assignment])"
	return 1


//proc used by the overwatch console to transfer marine to another squad
/datum/squad/proc/remove_marine_from_squad(mob/living/carbon/human/M)
	if(!M.mind || !M.mind.assigned_squad) return 0
	M.mind.assigned_squad = null
	count--
	marines_list -= M
	switch(M.mind.assigned_role)
		if("Squad Engineer") num_engineers--
		if("Squad Medic") num_medics--
		if("Squad Specialist") num_specialists--
		if("Squad Smartgunner") num_smartgun--
		if("Squad Leader")
			squad_leader = null
			if(!M.mind.previous_squad_role)//not a field promoted SL, a real one
				num_leaders--
	var/obj/item/weapon/card/id/ID = M.wear_id
	if(istype(ID))
		ID.access -= src.access
		ID.assignment = M.mind.assigned_role
		ID.name = "[ID.registered_name]'s ID Card ([ID.assignment])"


/datum/squad/proc/demote_squad_leader()
	var/mob/living/carbon/human/old_lead = squad_leader
	squad_leader = null
	var/new_role = "Squad Marine"
	if(old_lead.mind)
		if(old_lead.mind.previous_squad_role)//field promoted SL
			new_role = old_lead.mind.previous_squad_role //we get back our old role
			old_lead.mind.previous_squad_role = null
		old_lead.mind.assigned_role = new_role
		old_lead.mind.skills_list["leadership"] = SKILL_LEAD_BEGINNER
		switch(new_role)
			if("Squad Specialist") old_lead.mind.role_comm_title = "Sgt"
			if("Squad Engineer") old_lead.mind.role_comm_title = "Cpl"
			if("Squad Medic") old_lead.mind.role_comm_title = "Cpl"
			if("Squad Smartgunner") old_lead.mind.role_comm_title = "LCpl"
			else old_lead.mind.role_comm_title = "Mar"

	if(istype(old_lead.wear_ear, /obj/item/device/radio/headset/almayer/marine))
		var/obj/item/device/radio/headset/almayer/marine/R = old_lead.wear_ear
		if(istype(R.keyslot1, /obj/item/device/encryptionkey/squadlead))
			cdel(R.keyslot1)
			R.keyslot1 = null
		else if(istype(R.keyslot2, /obj/item/device/encryptionkey/squadlead))
			cdel(R.keyslot2)
			R.keyslot2 = null
		else if(istype(R.keyslot3, /obj/item/device/encryptionkey/squadlead))
			cdel(R.keyslot3)
			R.keyslot3 = null
		R.recalculateChannels()
	if(istype(old_lead.wear_id, /obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/ID = old_lead.wear_id
		ID.access -= ACCESS_MARINE_LEADER
		ID.rank = new_role
		ID.assignment = "[src] [new_role]"
		ID.name = "[ID.registered_name]'s ID Card ([ID.assignment])"
	old_lead.hud_set_squad()
	old_lead.sec_hud_set_ID()
	old_lead << "<font size='3' color='blue'>You're no longer the Squad Leader for [src]!</font>"


//Not a safe proc. Returns null if squads or jobs aren't set up.
//Mostly used in the marine squad console in marine_consoles.dm.
/proc/get_squad_by_name(var/text)
	if(!RoleAuthority || RoleAuthority.squads.len == 0)
		return null

	var/datum/squad/S
	for(S in RoleAuthority.squads)
		if(S.name == text)
			return S

	return null


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
