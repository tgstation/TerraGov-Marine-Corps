
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
	var/max_engineers = 3 //maximum # of engineers allowed in squad
	var/max_medics = 4 //Ditto, squad medics
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
	var/supply_cooldown = 0 //Cooldown for supply drops
	var/primary_objective = null //Text strings
	var/secondary_objective = null
	var/obj/item/device/squad_beacon/sbeacon = null
	var/obj/item/device/squad_beacon/bomb/bbeacon = null
	var/obj/structure/supply_drop/drop_pad = null

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
	if(!M.mind.assigned_role) return 0//Not yet
	if(M.assigned_squad) return 0 //already in a squad

	var/obj/item/card/id/C = null
	C = M.wear_id
	if(!C) C = M.get_active_hand()
	if(!istype(C)) return 0//Abort, no ID found

	switch(M.mind.assigned_role)
		if("Squad Engineer")
			num_engineers++
			C.claimedgear = 0
		if("Squad Medic")
			num_medics++
			C.claimedgear = 0
		if("Squad Specialist") num_specialists++
		if("Squad Smartgunner") num_smartgun++
		if("Squad Leader")
			if(squad_leader && (!squad_leader.mind || squad_leader.mind.assigned_role != "Squad Leader")) //field promoted SL
				demote_squad_leader() //replaced by the real one
			squad_leader = M
			if(M.mind.assigned_role == "Squad Leader") //field promoted SL don't count as real ones
				num_leaders++

	src.count++ //Add up the tally. This is important in even squad distribution.

	if(M.mind.assigned_role != "Squad Marine")
		log_admin("[key_name(M)] has been assigned as [name] [M.mind.assigned_role]") // we don't want to spam squad marines but the others are useful

	marines_list += M
	M.assigned_squad = src //Add them to the squad

	var/c_oldass = C.assignment
	C.access += src.access //Add their squad access to their ID
	C.assignment = "[name] [c_oldass]"
	C.name = "[C.registered_name]'s ID Card ([C.assignment])"
	return 1


//proc used by the overwatch console to transfer marine to another squad
/datum/squad/proc/remove_marine_from_squad(mob/living/carbon/human/M)
	if(!M.mind) return 0
	if(!M.assigned_squad) return //not assigned to a squad
	var/obj/item/card/id/C
	C = M.wear_id
	if(!istype(C)) return 0//Abort, no ID found

	C.access -= src.access
	C.assignment = M.mind.assigned_role
	C.name = "[C.registered_name]'s ID Card ([C.assignment])"

	count--
	marines_list -= M

	if(M.assigned_squad.squad_leader == M)
		if(M.mind.assigned_role != "Squad Leader") //a field promoted SL, not a real one
			demote_squad_leader()
		else
			M.assigned_squad.squad_leader = null

	M.assigned_squad = null

	switch(M.mind.assigned_role)
		if("Squad Engineer") num_engineers--
		if("Squad Medic") num_medics--
		if("Squad Specialist") num_specialists--
		if("Squad Smartgunner") num_smartgun--
		if("Squad Leader") num_leaders--





/datum/squad/proc/demote_squad_leader(leader_killed)
	var/mob/living/carbon/human/old_lead = squad_leader
	squad_leader = null
	if(old_lead.mind)
		switch(old_lead.mind.assigned_role)
			if("Squad Specialist")
				old_lead.mind.role_comm_title = "Sgt"
				if(old_lead.mind.cm_skills)
					old_lead.mind.cm_skills.leadership = SKILL_LEAD_BEGINNER
			if("Squad Engineer")
				old_lead.mind.role_comm_title = "Cpl"
				if(old_lead.mind.cm_skills)
					old_lead.mind.cm_skills.leadership = SKILL_LEAD_BEGINNER
			if("Squad Medic")
				old_lead.mind.role_comm_title = "Cpl"
				if(old_lead.mind.cm_skills)
					old_lead.mind.cm_skills.leadership = SKILL_LEAD_BEGINNER
			if("Squad Smartgunner")
				if(old_lead.mind.cm_skills)
					old_lead.mind.cm_skills.leadership = SKILL_LEAD_BEGINNER
				old_lead.mind.role_comm_title = "LCpl"
			if("Squad Leader")
				if(!leader_killed)
					if(old_lead.mind.cm_skills)
						old_lead.mind.cm_skills.leadership = SKILL_LEAD_NOVICE
					old_lead.mind.role_comm_title = "Mar"
			else
				old_lead.mind.role_comm_title = "Mar"
				if(old_lead.mind.cm_skills)
					old_lead.mind.cm_skills.leadership = SKILL_LEAD_NOVICE

	if(!old_lead.mind || old_lead.mind.assigned_role != "Squad Leader" || !leader_killed)
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
		if(istype(old_lead.wear_id, /obj/item/card/id))
			var/obj/item/card/id/ID = old_lead.wear_id
			ID.access -= ACCESS_MARINE_LEADER
	old_lead.hud_set_squad()
	old_lead.update_inv_head() //updating marine helmet leader overlays
	old_lead.update_inv_wear_suit()
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

