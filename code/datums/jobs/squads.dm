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

GLOBAL_LIST_EMPTY(glovemarkings)
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
	var/image/gloves = image('icons/mob/hands.dmi',icon_state = "std-gloves")
	gloves.color = color
	GLOB.glovemarkings[type] = gloves
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


/datum/squad/proc/insert_into_squad(mob/living/carbon/human/H, give_radio = FALSE)
	if(!usable)
		return FALSE

	if(!(H.job in GLOB.jobs_marines))
		return FALSE

	var/obj/item/card/id/C = H.get_idcard()
	if(!istype(C))
		return FALSE

	if(H.assigned_squad)
		CRASH("attempted to insert marine [H] into squad while already having one")

	switch(H.job)
		if(SQUAD_MARINE)
			pass()
		if(SQUAD_ENGINEER)
			num_engineers++
			C.claimedgear = FALSE
		if(SQUAD_CORPSMAN)
			num_medics++
			C.claimedgear = FALSE
		if(SQUAD_SPECIALIST)
			num_specialists++
		if(SQUAD_SMARTGUNNER)
			num_smartgun++
		if(SQUAD_LEADER)
			num_leaders++
			if(!squad_leader)
				squad_leader = H
				SSdirection.set_leader(tracking_id, H)
				SSdirection.start_tracking("marine-sl", H)
		else
			return FALSE

	var/obj/item/radio/headset/mainship/headset = H.wear_ear
	if(give_radio && !istype(headset))
		if(H.wear_ear)
			H.dropItemToGround(H.wear_ear)
		headset = new()
		H.equip_to_slot_or_del(headset, SLOT_EARS)

	if(istype(headset))
		headset.set_frequency(radio_freq)
		headset.recalculateChannels()
		if(headset.sl_direction && H != squad_leader)
			SSdirection.start_tracking(tracking_id, H)

	for(var/i in GLOB.datacore.general)
		var/datum/data/record/R = i
		if(R.fields["name"] == H.real_name)
			R.fields["squad"] = name
			break

	C.access += access
	C.assignment = "[name] [H.mind.assigned_role]"
	C.assigned_fireteam = 0
	C.update_label()

	count++
	marines_list += H
	H.assigned_squad = src
	H.hud_set_squad()
	H.update_action_buttons()
	H.update_inv_head()
	H.update_inv_wear_suit()
	log_manifest("[key_name(H)] has been assigned as [name] [H.mind.assigned_role].")
	return TRUE


/datum/squad/proc/remove_from_squad(mob/living/carbon/human/H)
	if(!usable)
		return FALSE

	if(!(H.job in GLOB.jobs_marines))
		return FALSE

	if(!H.assigned_squad)
		return FALSE

	if(H.assigned_squad != src)
		CRASH("attempted to remove marine [H] from squad [name] while being a member of squad [H.assigned_squad.name]")

	var/obj/item/card/id/C = H.get_idcard()
	if(!istype(C))
		return FALSE

	if(H == squad_leader)
		demote_leader()
	else
		SSdirection.stop_tracking(tracking_id, H)

	switch(H.job)
		if(SQUAD_ENGINEER)
			num_engineers--
		if(SQUAD_CORPSMAN)
			num_medics--
		if(SQUAD_SPECIALIST)
			num_specialists--
		if(SQUAD_SMARTGUNNER)
			num_smartgun--
		if(SQUAD_LEADER)
			num_leaders--

	var/obj/item/radio/headset/mainship/headset = H.wear_ear
	if(istype(headset))
		headset.set_frequency(initial(headset.frequency))

	for(var/i in GLOB.datacore.general)
		var/datum/data/record/R = i
		if(R.fields["name"] == H.real_name)
			R.fields["squad"] = null
			break

	C.access -= access
	C.assignment = H.job
	C.update_label()

	count--
	marines_list -= H

	H.assigned_squad = null
	H.hud_set_squad()
	H.update_action_buttons()
	H.update_inv_head()
	H.update_inv_wear_suit()
	return TRUE


/datum/squad/proc/demote_leader()
	if(!squad_leader)
		CRASH("attempted to remove squad leader from squad [name] while not having one set")

	SSdirection.clear_leader(tracking_id)
	SSdirection.stop_tracking("marine-sl", squad_leader)

	//Handle aSL skill level and radio
	if(squad_leader.job != SQUAD_LEADER)
		squad_leader.skills.setRating(leadership = SKILL_LEAD_NOVICE)
		if(squad_leader.mind)
			var/datum/job/J = SSjob.GetJob(squad_leader.mind.assigned_role)
			squad_leader.mind.comm_title = J.comm_title
		if(istype(squad_leader.wear_ear, /obj/item/radio/headset/mainship/marine))
			var/obj/item/radio/headset/mainship/marine/R = squad_leader.wear_ear
			R.recalculateChannels()
			R.use_command = FALSE
		var/obj/item/card/id/ID = squad_leader.get_idcard()
		if(istype(ID))
			ID.access -= list(ACCESS_MARINE_LEADER, ACCESS_MARINE_DROPSHIP)

	to_chat(squad_leader, "<font size='3' color='blue'>You're no longer the Squad Leader for [src]!</font>")
	var/mob/living/carbon/human/H = squad_leader
	squad_leader = null
	H.update_action_buttons()
	H.hud_set_squad()
	H.update_inv_head()
	H.update_inv_wear_suit()


/datum/squad/proc/promote_leader(mob/living/carbon/human/H)
	if(squad_leader)
		CRASH("attempted to promote [H] to squad leader of [src] while having one set - [squad_leader]")

	squad_leader = H
	SSdirection.set_leader(tracking_id, H)
	SSdirection.start_tracking("marine-sl", H)

	//Handle aSL skill level and radio
	if(squad_leader.job != SQUAD_LEADER)
		squad_leader.skills.setRating(leadership = SKILL_LEAD_TRAINED)
		if(squad_leader.mind)
			squad_leader.mind.comm_title = "aSL"
		var/obj/item/card/id/ID = squad_leader.get_idcard()
		if(istype(ID))
			ID.access += list(ACCESS_MARINE_LEADER, ACCESS_MARINE_DROPSHIP)

	if(istype(squad_leader.wear_ear, /obj/item/radio/headset/mainship/marine))
		var/obj/item/radio/headset/mainship/marine/R = squad_leader.wear_ear
		R.channels[RADIO_CHANNEL_COMMAND] = TRUE
		R.secure_radio_connections[RADIO_CHANNEL_COMMAND] = add_radio(R, GLOB.radiochannels[RADIO_CHANNEL_COMMAND])
		R.use_command = TRUE

	squad_leader.hud_set_squad()
	squad_leader.update_action_buttons()
	squad_leader.update_inv_head()
	squad_leader.update_inv_wear_suit()
	to_chat(squad_leader, "<font size='3' color='blue'>You're now the Squad Leader for [src]!</font>")


/datum/squad/proc/format_message(message, mob/living/carbon/human/sender)
	var/nametext = ""
	var/text = copytext(sanitize(message), 1, MAX_MESSAGE_LEN)
	if(ishuman(sender))
		var/obj/item/card/id/ID = sender.get_idcard()
		nametext = "[ID?.rank] [sender.name] transmits: "
		text = "<font size='3'><b>[text]<b></font>"
	return "[nametext][text]"


/datum/squad/proc/message_squad(message, mob/living/carbon/human/sender)
	var/text = "<span class='notice'><B>\[Overwatch\]:</b> [format_message(message, sender)]</span>"
	for(var/i in marines_list)
		var/mob/living/L = i
		message_member(L, text, sender)


/datum/squad/proc/message_leader(message, mob/living/carbon/human/sender)
	if(!squad_leader || squad_leader.stat != CONSCIOUS || !squad_leader.client)
		return FALSE
	return message_member(squad_leader, "<span class='notice'><B>\[SL Overwatch\]:</b> [format_message(message, sender)]</span>", sender)


/datum/squad/proc/message_member(mob/living/target, message, mob/living/carbon/human/sender)
	if(!target.client)
		return
	if(sender)
		target.playsound_local(target, 'sound/effects/radiostatic.ogg')
	to_chat(target, message)
	return TRUE


/datum/squad/proc/check_entry(rank)
	if(!usable)
		return FALSE
	switch(rank)
		if(SQUAD_MARINE)
			return TRUE
		if(SQUAD_ENGINEER)
			if(num_engineers >= max_engineers)
				return FALSE
			return TRUE
		if(SQUAD_CORPSMAN)
			if(num_medics >= max_medics)
				return FALSE
			return TRUE
		if(SQUAD_SMARTGUNNER)
			if(num_smartgun >= max_smartgun)
				return FALSE
			return TRUE
		if(SQUAD_SPECIALIST)
			if(num_specialists >= max_specialists)
				return FALSE
			return TRUE
		if(SQUAD_LEADER)
			if(num_leaders >= max_leaders)
				return FALSE
			return TRUE
		else
			return FALSE


//This reserves a player a spot in the squad by using a mind variable.
//It is necessary so that they can smoothly reroll a squad role in case of the strict preference.
/datum/squad/proc/assign_initial(mob/M, rank, latejoin = FALSE)
	switch(rank)
		if(SQUAD_MARINE)
			M.mind.assigned_squad = src
			return TRUE
		if(SQUAD_ENGINEER)
			M.mind.assigned_squad = src
			if(!latejoin)
				num_engineers++
			return TRUE
		if(SQUAD_CORPSMAN)
			M.mind.assigned_squad = src
			if(!latejoin)
				num_medics++
			return TRUE
		if(SQUAD_SMARTGUNNER)
			M.mind.assigned_squad = src
			if(!latejoin)
				num_smartgun++
			return TRUE
		if(SQUAD_SPECIALIST)
			M.mind.assigned_squad = src
			if(!latejoin)
				num_specialists++
			return TRUE
		if(SQUAD_LEADER)
			M.mind.assigned_squad = src
			if(!latejoin)
				num_leaders++
			return TRUE
		else
			return FALSE


//A generic proc for handling the initial squad role assignment in SSjob
/proc/handle_initial_squad(mob/M, rank, latejoin = FALSE)
	var/strict = M.client.prefs.be_special && (M.client.prefs.be_special & BE_SQUAD_STRICT)
	var/datum/squad/P = SSjob.active_squads[M.client.prefs.preferred_squad]
	var/datum/squad/R = SSjob.active_squads[pick(SSjob.active_squads)]
	switch(rank)
		if(SQUAD_MARINE)
			return P?.assign_initial(M, rank, latejoin) || R.assign_initial(M, rank, latejoin)
		if(SQUAD_ENGINEER)
			for(var/i in shuffle(SSjob.active_squads))
				var/datum/squad/S = SSjob.active_squads[i]
				if(!S.check_entry(rank))
					continue
				if(P && P == S && S.assign_initial(M, rank, latejoin))
					return TRUE
			if(strict && !latejoin)
				return FALSE
			for(var/i in shuffle(SSjob.active_squads))
				var/datum/squad/S = SSjob.active_squads[i]
				if(!S.check_entry(rank))
					continue
				else if(S.assign_initial(M, rank, latejoin))
					return TRUE
		if(SQUAD_CORPSMAN)
			for(var/i in shuffle(SSjob.active_squads))
				var/datum/squad/S = SSjob.active_squads[i]
				if(!S.check_entry(rank))
					continue
				if(P && P == S && S.assign_initial(M, rank, latejoin))
					return TRUE
			if(strict && !latejoin)
				return FALSE
			for(var/i in shuffle(SSjob.active_squads))
				var/datum/squad/S = SSjob.active_squads[i]
				if(!S.check_entry(rank))
					continue
				else if(S.assign_initial(M, rank, latejoin))
					return TRUE
		if(SQUAD_SMARTGUNNER)
			for(var/i in shuffle(SSjob.active_squads))
				var/datum/squad/S = SSjob.active_squads[i]
				if(!S.check_entry(rank))
					continue
				if(P && P == S && S.assign_initial(M, rank, latejoin))
					return TRUE
			if(strict && !latejoin)
				return FALSE
			for(var/i in shuffle(SSjob.active_squads))
				var/datum/squad/S = SSjob.active_squads[i]
				if(!S.check_entry(rank, latejoin))
					continue
				else if(S.assign_initial(M, rank, latejoin))
					return TRUE
		if(SQUAD_SPECIALIST)
			for(var/i in shuffle(SSjob.active_squads))
				var/datum/squad/S = SSjob.active_squads[i]
				if(!S.check_entry(rank))
					continue
				if(P && P == S && S.assign_initial(M, rank, latejoin))
					return TRUE
			if(strict && !latejoin)
				return FALSE
			for(var/i in shuffle(SSjob.active_squads))
				var/datum/squad/S = SSjob.active_squads[i]
				if(!S.check_entry(rank))
					continue
				else if(S.assign_initial(M, rank, latejoin))
					return TRUE
		if(SQUAD_LEADER)
			for(var/i in shuffle(SSjob.active_squads))
				var/datum/squad/S = SSjob.active_squads[i]
				if(!S.check_entry(rank))
					continue
				if(P && P == S && S.assign_initial(M, rank, latejoin))
					return TRUE
			if(strict && !latejoin)
				return FALSE
			for(var/i in shuffle(SSjob.active_squads))
				var/datum/squad/S = SSjob.active_squads[i]
				if(!S.check_entry(rank))
					continue
				else if(S.assign_initial(M, rank, latejoin))
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
