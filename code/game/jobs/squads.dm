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

	var/obj/item/squad_beacon/sbeacon = null
	var/obj/structure/supply_drop/drop_pad = null

	var/list/squad_orbital_beacons = list()
	var/list/squad_laser_targets = list()


/datum/squad/alpha
	name = "Alpha"
	id = ALPHA_SQUAD
	color = "#e61919" // rgb(230,25,25)
	access = list(ACCESS_MARINE_ALPHA)
	usable = TRUE
	radio_freq = FREQ_ALPHA


/datum/squad/bravo
	name = "Bravo"
	id = BRAVO_SQUAD
	color = "#ffc32d" // rgb(255,195,45)
	access = list(ACCESS_MARINE_BRAVO)
	usable = 1
	radio_freq = FREQ_BRAVO


/datum/squad/charlie
	name = "Charlie"
	id = CHARLIE_SQUAD
	color = "#c864c8" // rgb(200,100,200)
	access = list(ACCESS_MARINE_CHARLIE)
	usable = TRUE
	radio_freq = FREQ_CHARLIE

/datum/squad/delta
	name = "Delta"
	id = DELTA_SQUAD
	color = "#4148c8" // rgb(65,72,200)
	access = list(ACCESS_MARINE_DELTA)
	usable = TRUE
	radio_freq = FREQ_DELTA

GLOBAL_LIST_EMPTY(armormarkings)
GLOBAL_LIST_EMPTY(armormarkings_sl)
GLOBAL_LIST_EMPTY(helmetmarkings)
GLOBAL_LIST_EMPTY(helmetmarkings_sl)

/datum/squad/New()
	. = ..()
	var/image/armor = image('icons/mob/suit_1.dmi',icon_state = "std-armor")
	var/image/armorsl = image('icons/mob/suit_1.dmi',icon_state = "sql-armor")
	armor.color = color
	armorsl.color = color
	GLOB.armormarkings[type] = armor
	GLOB.armormarkings_sl[type] = armorsl

	var/image/helmet = image('icons/mob/head_1.dmi',icon_state = "std-helmet")
	var/image/helmetsl = image('icons/mob/head_1.dmi',icon_state = "sql-helmet")
	helmet.color = color
	helmetsl.color = color
	GLOB.helmetmarkings[type] = helmet
	GLOB.helmetmarkings_sl[type] = helmetsl

	tracking_id = SSdirection.init_squad(src)

/datum/squad/proc/get_all_members()
	return marines_list

/datum/squad/proc/get_total_members()
	return length(marines_list)

/datum/squad/proc/put_marine_in_squad(mob/living/carbon/human/H)
	if(!istype(H))
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
		if("Squad Corpsman")
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
			SSdirection.set_leader(tracking_id, H)
			SSdirection.start_tracking("marine-sl", H)
			if(H.mind.assigned_role == "Squad Leader") //field promoted SL don't count as real ones
				num_leaders++

	count++ //Add up the tally. This is important in even squad distribution.

	log_game("[key_name(H)] has been assigned as [name] [H.mind.assigned_role]")

	marines_list += H
	H.assigned_squad = src //Add them to the squad

	if(istype(H.wear_ear, /obj/item/radio/headset/almayer)) // they've been transferred
		var/obj/item/radio/headset/almayer/headset = H.wear_ear
		if(headset.sl_direction && H.assigned_squad.squad_leader != H)
			SSdirection.start_tracking(tracking_id, H)

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
	C.update_label()

	count--
	marines_list -= H

	SSdirection.stop_tracking(tracking_id, H) // covers squad transfers

	if(H.assigned_squad.squad_leader == H)
		if(H.mind.assigned_role != "Squad Leader") //a field promoted SL, not a real one
			demote_squad_leader()
		else
			H.assigned_squad.squad_leader = null
			SSdirection.clear_leader(tracking_id)
			SSdirection.stop_tracking("marine-sl", H)

	H.assigned_squad = null

	switch(H.mind.assigned_role)
		if("Squad Engineer")
			num_engineers--
		if("Squad Corpsman")
			num_medics--
		if("Squad Specialist")
			num_specialists--
		if("Squad Smartgunner")
			num_smartgun--
		if("Squad Leader")
			num_leaders--


//proc used by human dispose to clean the mob from squad lists
/datum/squad/proc/clean_marine_from_squad(mob/living/carbon/human/H, wipe)
	if(!H.assigned_squad || !(H in marines_list))
		return FALSE
	SSdirection.stop_tracking(tracking_id, H)// failsafe
	marines_list -= src
	if(!wipe)
		var/role = "unknown"
		if(H.mind?.assigned_role)
			role = H.mind.assigned_role
		gibbed_marines_list[H.name] = role
	if(squad_leader == src)
		squad_leader = null
		SSdirection.clear_leader(tracking_id)
		SSdirection.stop_tracking("marine-sl", src)
	H.assigned_squad = null
	return TRUE


/datum/squad/proc/demote_squad_leader(leader_killed)
	var/mob/living/carbon/human/old_lead = squad_leader
	squad_leader = null
	SSdirection.clear_leader(tracking_id)
	SSdirection.stop_tracking("marine-sl", old_lead)

	if(old_lead.mind.assigned_role)
		if(old_lead.mind.cm_skills)
			if(old_lead.mind.assigned_role == ("Squad Specialist" || "Squad Engineer" || "Squad Corpsman" || "Squad Smartgunner"))
				old_lead.mind.cm_skills.leadership = SKILL_LEAD_BEGINNER

			else if(old_lead.mind == "Squad Leader")
				if(!leader_killed)
					old_lead.mind.cm_skills.leadership = SKILL_LEAD_NOVICE
			else
				old_lead.mind.cm_skills.leadership = SKILL_LEAD_NOVICE

		old_lead.update_action_buttons()

	if(!old_lead.mind || old_lead.mind.assigned_role != "Squad Leader" || !leader_killed)
		if(istype(old_lead.wear_ear, /obj/item/radio/headset/almayer/marine))
			var/obj/item/radio/headset/almayer/marine/R = old_lead.wear_ear
			if(istype(R.keyslot, /obj/item/encryptionkey/squadlead))
				qdel(R.keyslot)
				R.keyslot = null
			else if(istype(R.keyslot2, /obj/item/encryptionkey/squadlead))
				qdel(R.keyslot2)
				R.keyslot2 = null
			R.recalculateChannels()
		if(istype(old_lead.wear_id, /obj/item/card/id))
			var/obj/item/card/id/ID = old_lead.wear_id
			ID.access -= list(ACCESS_MARINE_LEADER, ACCESS_MARINE_DROPSHIP)
	old_lead.hud_set_squad()
	old_lead.update_inv_head() //updating marine helmet leader overlays
	old_lead.update_inv_wear_suit()
	to_chat(old_lead, "<font size='3' color='blue'>You're no longer the Squad Leader for [src]!</font>")

/datum/squad/proc/format_message(message, mob/living/carbon/human/sender)
	var/nametext = ""
	var/text = copytext(sanitize(message), 1, MAX_MESSAGE_LEN)
	if(ishuman(sender))
		var/obj/item/card/id/ID = sender.get_idcard()
		nametext = "[ID?.rank] [sender.name] transmits: "
		text = "<font size='3'><b>[text]<b></font>"
	return "[nametext][text]"

/datum/squad/proc/message_squad(message, mob/living/carbon/human/sender)
	var/text = "<font color='blue'><B>\[Overwatch\]:</b> [format_message(message, sender)]</font>"
	for(var/mob/living/L in marines_list)
		message_member(L, text, sender)

/datum/squad/proc/message_leader(message, mob/living/carbon/human/sender)
	if(!squad_leader || squad_leader.stat || !squad_leader.client)
		return FALSE
	return message_member(squad_leader, "<font color='blue'><B>\[SL Overwatch\]:</b> [format_message(message, sender)]</font>", sender)

/datum/squad/proc/message_member(mob/living/target, message, mob/living/carbon/human/sender)
	if(!target.client)
		return
	if(sender)
		SEND_SOUND(squad_leader, sound('sound/effects/radiostatic.ogg'))
	to_chat(target, message)


/datum/squad/proc/check_entry(rank)
	switch(rank)
		if("Squad Marine")
			return TRUE
		if("Squad Engineer")
			if(num_engineers >= max_engineers)
				return FALSE
			return TRUE
		if("Squad Corpsman")
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


/datum/squad/proc/assign(mob/M, rank, latejoin = FALSE)
	if(!rank || !M?.mind)
		return FALSE
	switch(rank)
		if("Squad Marine")
			M.mind.assigned_squad = src
			return TRUE
		if("Squad Engineer")
			M.mind.assigned_squad = src
			if(!latejoin)
				num_engineers++
			return TRUE
		if("Squad Corpsman")
			M.mind.assigned_squad = src
			if(!latejoin)
				num_medics++
			return TRUE
		if("Squad Smartgunner")
			M.mind.assigned_squad = src
			if(!latejoin)
				num_smartgun++
			return TRUE
		if("Squad Specialist")
			M.mind.assigned_squad = src
			if(!latejoin)
				num_specialists++
			return TRUE
		if("Squad Leader")
			M.mind.assigned_squad = src
			if(!latejoin)
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
				if(P && P == S && S.assign(M, rank, latejoin))
					return TRUE
			if(strict && !latejoin)
				return FALSE
			for(var/i in shuffle(SSjob.squads))
				var/datum/squad/S = SSjob.squads[i]
				if(!S.check_entry(rank))
					continue
				else if(S.assign(M, rank, latejoin))
					return TRUE
		if("Squad Corpsman")
			for(var/i in shuffle(SSjob.squads))
				var/datum/squad/S = SSjob.squads[i]
				if(!S.check_entry(rank))
					continue
				if(P && P == S && S.assign(M, rank, latejoin))
					return TRUE
			if(strict && !latejoin)
				return FALSE
			for(var/i in shuffle(SSjob.squads))
				var/datum/squad/S = SSjob.squads[i]
				if(!S.check_entry(rank))
					continue
				else if(S.assign(M, rank, latejoin))
					return TRUE
		if("Squad Smartgunner")
			for(var/i in shuffle(SSjob.squads))
				var/datum/squad/S = SSjob.squads[i]
				if(!S.check_entry(rank))
					continue
				if(P && P == S && S.assign(M, rank, latejoin))
					return TRUE
			if(strict && !latejoin)
				return FALSE
			for(var/i in shuffle(SSjob.squads))
				var/datum/squad/S = SSjob.squads[i]
				if(!S.check_entry(rank, latejoin))
					continue
				else if(S.assign(M, rank, latejoin))
					return TRUE
		if("Squad Specialist")
			for(var/i in shuffle(SSjob.squads))
				var/datum/squad/S = SSjob.squads[i]
				if(!S.check_entry(rank))
					continue
				if(P && P == S && S.assign(M, rank, latejoin))
					return TRUE
			if(strict && !latejoin)
				return FALSE
			for(var/i in shuffle(SSjob.squads))
				var/datum/squad/S = SSjob.squads[i]
				if(!S.check_entry(rank))
					continue
				else if(S.assign(M, rank, latejoin))
					return TRUE
		if("Squad Leader")
			for(var/i in shuffle(SSjob.squads))
				var/datum/squad/S = SSjob.squads[i]
				if(!S.check_entry(rank))
					continue
				if(P && P == S && S.assign(M, rank, latejoin))
					return TRUE
			if(strict && !latejoin)
				return FALSE
			for(var/i in shuffle(SSjob.squads))
				var/datum/squad/S = SSjob.squads[i]
				if(!S.check_entry(rank))
					continue
				else if(S.assign(M, rank, latejoin))
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