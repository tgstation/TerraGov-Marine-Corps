/datum/squad
	var/name = ""
	var/id = NO_SQUAD
	var/tracking_id = null // for use with SSdirection
	var/color = 0 //Color for helmets, etc.
	var/list/access = list() //Which special access do we grant them
	var/usable = FALSE	 //Is it a valid squad?

	var/max_positions = -1 //Maximum number allowed in a squad. Defaults to infinite

	var/max_engineers = 3
	var/max_medics = 4
	var/max_smartgun = 1
	var/max_specialists = 1
	var/max_leaders = 1

	var/num_engineers = 0
	var/num_medics = 0
	var/num_specialists = 0
	var/num_smartgun = 0
	var/num_leaders = 0

	var/count = 0 //Current # in the squad
	var/list/marines_list = list() // list of humans in that squad.
	var/list/gibbed_marines_list = list() // List of the names of the gibbed humans associated with roles.

	var/radio_freq = 1461
	var/mob/living/carbon/human/squad_leader
	var/mob/living/carbon/human/overwatch_officer

	var/supply_cooldown = 0 //Cooldown for supply drops
	var/primary_objective = null //Text strings
	var/secondary_objective = null

	var/obj/item/device/squad_beacon/sbeacon = null
	var/obj/structure/supply_drop/drop_pad = null

	var/list/squad_orbital_beacons = list()
	var/list/squad_laser_targets = list()


/datum/squad/alpha
	name = "Alpha"
	id = ALPHA_SQUAD
	tracking_id = TRACK_ALPHA_SQUAD
	color = 1
	access = list(ACCESS_MARINE_ALPHA)
	usable = TRUE
	radio_freq = ALPHA_FREQ


/datum/squad/bravo
	name = "Bravo"
	id = BRAVO_SQUAD
	tracking_id = TRACK_BRAVO_SQUAD
	color = 2
	access = list(ACCESS_MARINE_BRAVO)
	usable = 1
	radio_freq = BRAVO_FREQ


/datum/squad/charlie
	name = "Charlie"
	id = CHARLIE_SQUAD
	tracking_id = TRACK_CHARLIE_SQUAD
	color = 3
	access = list(ACCESS_MARINE_CHARLIE)
	usable = TRUE
	radio_freq = CHARLIE_FREQ

/datum/squad/delta
	name = "Delta"
	id = DELTA_SQUAD
	tracking_id = TRACK_DELTA_SQUAD
	color = 4
	access = list(ACCESS_MARINE_DELTA)
	usable = TRUE
	radio_freq = DELTA_FREQ


/datum/squad/proc/put_marine_in_squad(var/mob/living/carbon/human/H)
	if(!H || !istype(H,/mob/living/carbon/human))
		return FALSE
	if(!usable)
		return FALSE
	if(!H.mind?.assigned_role)
		return FALSE
	if(H.assigned_squad)
		return FALSE

	var/obj/item/card/id/C = null

	C = H.wear_id
	if(!C)
		C = H.get_active_held_item()
	if(!istype(C))
		return FALSE

	switch(H.mind.assigned_role)
		if("Squad Engineer")
			num_engineers++
			C.claimedgear = 0
		if("Squad Medic")
			num_medics++
			C.claimedgear = 0
		if("Squad Specialist")
			num_specialists++
		if("Squad Smartgunner")
			num_smartgun++
		if("Squad Leader")
			if(squad_leader && (!squad_leader.mind || squad_leader.mind.assigned_role != "Squad Leader")) //field promoted SL
				demote_squad_leader() //replaced by the real one
			squad_leader = H
			SET_TRACK_LEADER(tracking_id, H)
			if(H.mind.assigned_role == "Squad Leader") //field promoted SL don't count as real ones
				num_leaders++

	count++ //Add up the tally. This is important in even squad distribution.

	log_game("[key_name(H)] has been assigned as [name] [H.mind.assigned_role]")

	marines_list += H
	H.assigned_squad = src //Add them to the squad

	if(istype(H.wear_ear, /obj/item/device/radio/headset/almayer)) // they've been transferred
		var/obj/item/device/radio/headset/almayer/headset = H.wear_ear
		if(headset.sl_direction)
			START_TRACK_LEADER(src, H)

	var/c_oldass = C.assignment
	C.access += access //Add their squad access to their ID
	C.assignment = "[name] [c_oldass]"
	C.name = "[C.registered_name]'s ID Card ([C.assignment])"
	return TRUE


/datum/squad/proc/remove_marine_from_squad(mob/living/carbon/human/H)
	if(!H.mind)
		return FALSE

	if(!H.assigned_squad)
		return FALSE

	var/obj/item/card/id/C
	C = H.wear_id
	if(!istype(C))
		return FALSE

	C.access -= access
	C.assignment = H.mind.assigned_role
	C.name = "[C.registered_name]'s ID Card ([C.assignment])"

	count--
	marines_list -= H

	STOP_TRACK_LEADER(src, H) // covers squad transfers

	if(H.assigned_squad.squad_leader == H)
		if(H.mind.assigned_role != "Squad Leader") //a field promoted SL, not a real one
			demote_squad_leader()
		else
			H.assigned_squad.squad_leader = null
			CLEAR_TRACK_LEADER(tracking_id)

	H.assigned_squad = null

	switch(H.mind.assigned_role)
		if("Squad Engineer")
			num_engineers--
		if("Squad Medic")
			num_medics--
		if("Squad Specialist")
			num_specialists--
		if("Squad Smartgunner")
			num_smartgun--
		if("Squad Leader")
			num_leaders--


//proc used by human dispose to clean the mob from squad lists
/datum/squad/proc/clean_marine_from_squad(mob/living/carbon/human/H, wipe = FALSE)
	if(!H.assigned_squad || !(H in marines_list))
		return FALSE
	marines_list -= src
	if(!wipe)
		var/role = "unknown"
		if(H.mind?.assigned_role)
			role = H.mind.assigned_role
		gibbed_marines_list[H.name] = role
	if(squad_leader == src)
		squad_leader = null
		CLEAR_TRACK_LEADER(tracking_id)
	H.assigned_squad = null
	return TRUE


/datum/squad/proc/demote_squad_leader(leader_killed)
	var/mob/living/carbon/human/old_lead = squad_leader
	squad_leader = null
	CLEAR_TRACK_LEADER(tracking_id)
	if(old_lead.mind.assigned_role)
		if(old_lead.mind.cm_skills)
			if(old_lead.mind.assigned_role == ("Squad Specialist" || "Squad Engineer" || "Squad Medic" || "Squad Smartgunner"))
				old_lead.mind.cm_skills.leadership = SKILL_LEAD_BEGINNER

			else if(old_lead.mind == "Squad Leader")
				if(!leader_killed)
					old_lead.mind.cm_skills.leadership = SKILL_LEAD_NOVICE
			else
				old_lead.mind.cm_skills.leadership = SKILL_LEAD_NOVICE

		old_lead.update_action_buttons()

	if(!old_lead.mind || old_lead.mind.assigned_role != "Squad Leader" || !leader_killed)
		if(istype(old_lead.wear_ear, /obj/item/device/radio/headset/almayer/marine))
			var/obj/item/device/radio/headset/almayer/marine/R = old_lead.wear_ear
			if(istype(R.keyslot1, /obj/item/device/encryptionkey/squadlead))
				qdel(R.keyslot1)
				R.keyslot1 = null
			else if(istype(R.keyslot2, /obj/item/device/encryptionkey/squadlead))
				qdel(R.keyslot2)
				R.keyslot2 = null
			else if(istype(R.keyslot3, /obj/item/device/encryptionkey/squadlead))
				qdel(R.keyslot3)
				R.keyslot3 = null
			R.recalculateChannels()
		if(istype(old_lead.wear_id, /obj/item/card/id))
			var/obj/item/card/id/ID = old_lead.wear_id
			ID.access -= ACCESS_MARINE_LEADER
	old_lead.hud_set_squad()
	old_lead.update_inv_head() //updating marine helmet leader overlays
	old_lead.update_inv_wear_suit()
	to_chat(old_lead, "<font size='3' color='blue'>You're no longer the Squad Leader for [src]!</font>")


/datum/squad/proc/check_entry(rank)
	switch(rank)
		if("Squad Marine")
			return TRUE
		if("Squad Engineer")
			if(num_engineers >= max_engineers)
				return FALSE
			return TRUE
		if("Squad Medic")
			if(num_medics >= max_medics)
				return FALSE
			return TRUE
		if("Squad Smartgunner")
			if(num_smartgun >= max_smartgun)
				return FALSE
			return TRUE
		if("Squad Specialist")
			if(num_specialists >= max_specialists)
				return FALSE
			return TRUE
		if("Squad Leader")
			if(num_leaders >= max_leaders)
				return FALSE
			return TRUE
		else
			return FALSE


/datum/squad/proc/assign(mob/M, rank)
	if(!rank || !M?.mind)
		return FALSE
	switch(rank)
		if("Squad Marine")
			M.mind.assigned_squad = src
			return TRUE
		if("Squad Engineer")
			M.mind.assigned_squad = src
			num_engineers++
			return TRUE
		if("Squad Medic")
			M.mind.assigned_squad = src
			num_medics++
			return TRUE
		if("Squad Smartgunner")
			M.mind.assigned_squad = src
			num_smartgun++
			return TRUE
		if("Squad Specialist")
			M.mind.assigned_squad = src
			num_specialists++
			return TRUE
		if("Squad Leader")
			M.mind.assigned_squad = src
			num_leaders++
			return TRUE
		else
			return FALSE


/proc/handle_squad(mob/M, rank, latejoin = FALSE)
	var/strict = FALSE
	var/datum/squad/P = SSjob.squads[M.client.prefs.preferred_squad]
	var/datum/squad/R = SSjob.squads[pick(SSjob.squads)]
	if(M.client?.prefs?.be_special && (M.client.prefs.be_special & BE_SQUAD_STRICT))
		strict = TRUE
	switch(rank)
		if("Squad Marine")
			if(P && P.assign(M, rank))
				return TRUE
			else if(R.assign(M, rank))
				return TRUE
		if("Squad Engineer")
			for(var/i in shuffle(SSjob.squads))
				var/datum/squad/S = SSjob.squads[i]
				if(!S.check_entry(rank))
					continue
				if(P && P == S && S.assign(M, rank))
					return TRUE
			if(strict && !latejoin)
				return FALSE
			for(var/i in shuffle(SSjob.squads))
				var/datum/squad/S = SSjob.squads[i]
				if(!S.check_entry(rank))
					continue
				else if(S.assign(M, rank))
					return TRUE
		if("Squad Medic")
			for(var/i in shuffle(SSjob.squads))
				var/datum/squad/S = SSjob.squads[i]
				if(!S.check_entry(rank))
					continue
				if(P && P == S && S.assign(M, rank))
					return TRUE
			if(strict && !latejoin)
				return FALSE
			for(var/i in shuffle(SSjob.squads))
				var/datum/squad/S = SSjob.squads[i]
				if(!S.check_entry(rank))
					continue
				else if(S.assign(M, rank))
					return TRUE
		if("Squad Smartgunner")
			for(var/i in shuffle(SSjob.squads))
				var/datum/squad/S = SSjob.squads[i]
				if(!S.check_entry(rank))
					continue
				if(P && P == S && S.assign(M, rank))
					return TRUE
			if(strict && !latejoin)
				return FALSE
			for(var/i in shuffle(SSjob.squads))
				var/datum/squad/S = SSjob.squads[i]
				if(!S.check_entry(rank))
					continue
				else if(S.assign(M, rank))
					return TRUE
		if("Squad Specialist")
			for(var/i in shuffle(SSjob.squads))
				var/datum/squad/S = SSjob.squads[i]
				if(!S.check_entry(rank))
					continue
				if(P && P == S && S.assign(M, rank))
					return TRUE
			if(strict && !latejoin)
				return FALSE
			for(var/i in shuffle(SSjob.squads))
				var/datum/squad/S = SSjob.squads[i]
				if(!S.check_entry(rank))
					continue
				else if(S.assign(M, rank))
					return TRUE
		if("Squad Leader")
			for(var/i in shuffle(SSjob.squads))
				var/datum/squad/S = SSjob.squads[i]
				if(!S.check_entry(rank))
					continue
				if(P && P == S && S.assign(M, rank))
					return TRUE
			if(strict && !latejoin)
				return FALSE
			for(var/i in shuffle(SSjob.squads))
				var/datum/squad/S = SSjob.squads[i]
				if(!S.check_entry(rank))
					continue
				else if(S.assign(M, rank))
					return TRUE
	return FALSE


/proc/reset_squads()
	for(var/i in SSjob.squads)
		var/datum/squad/S = SSjob.squads[i]
		S.num_engineers = 0
		S.num_medics = 0
		S.num_smartgun = 0
		S.num_specialists = 0
		S.num_leaders = 0