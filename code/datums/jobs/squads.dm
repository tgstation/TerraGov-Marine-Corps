/datum/squad
	var/name = ""
	var/id = NO_SQUAD
	var/tracking_id = null // for use with SSdirection
	var/color = 0 //Color for helmets, etc.
	var/list/access = list() //Which special access do we grant them

	var/current_positions = list(
		/datum/job/terragov/squad/standard = 0,
		/datum/job/terragov/squad/engineer = 0,
		/datum/job/terragov/squad/corpsman = 0,
		/datum/job/terragov/squad/smartgunner = 0,
		/datum/job/terragov/squad/specialist = 0,
		/datum/job/terragov/squad/leader = 0)
	var/max_positions = list(
		/datum/job/terragov/squad/standard = -1,
		/datum/job/terragov/squad/leader = 1)

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
	radio_freq = FREQ_ALPHA


/datum/squad/bravo
	name = "Bravo"
	id = BRAVO_SQUAD
	color = "#ffc32d" // rgb(255,195,45)
	access = list(ACCESS_MARINE_BRAVO)
	radio_freq = FREQ_BRAVO


/datum/squad/charlie
	name = "Charlie"
	id = CHARLIE_SQUAD
	color = "#c864c8" // rgb(200,100,200)
	access = list(ACCESS_MARINE_CHARLIE)
	radio_freq = FREQ_CHARLIE

/datum/squad/delta
	name = "Delta"
	id = DELTA_SQUAD
	color = "#4148c8" // rgb(65,72,200)
	access = list(ACCESS_MARINE_DELTA)
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
	if(!(H.job in SSjob.active_occupations))
		CRASH("attempted to insert marine [H] from squad [name] while having job [isnull(H.job) ? "null" : H.job.title]")

	var/obj/item/card/id/C = H.get_idcard()
	if(!istype(C))
		return FALSE

	if(H.assigned_squad)
		CRASH("attempted to insert marine [H] into squad while already having one")

	if(!(H.job.type in current_positions))
		CRASH("Attempted to insert [H.job.type] into squad [name]")

	current_positions[H.job.type]++

	if(ismarineleaderjob(H.job) && !squad_leader)
		squad_leader = H
		SSdirection.set_leader(tracking_id, H)
		SSdirection.start_tracking("marine-sl", H)

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
	C.assignment = "[name] [H.job.title]"
	C.assigned_fireteam = 0
	C.update_label()

	marines_list += H
	H.assigned_squad = src
	H.hud_set_squad()
	H.update_action_buttons()
	H.update_inv_head()
	H.update_inv_wear_suit()
	log_manifest("[key_name(H)] has been assigned as [name] [H.job.title].")
	return TRUE


/datum/squad/proc/remove_from_squad(mob/living/carbon/human/H)
	if(!(H.job in SSjob.active_occupations))
		CRASH("attempted to remove marine [H] from squad [name] while having job [isnull(H.job) ? "null" : H.job.title]")

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

	if(H.job.type in current_positions)
		current_positions[H.job.type]--
	else
		stack_trace("Removed [H.job.type] from squad [name] somehow")

	var/obj/item/radio/headset/mainship/headset = H.wear_ear
	if(istype(headset))
		headset.set_frequency(initial(headset.frequency))

	for(var/i in GLOB.datacore.general)
		var/datum/data/record/R = i
		if(R.fields["name"] == H.real_name)
			R.fields["squad"] = null
			break

	C.access -= access
	C.assignment = H.job.title
	C.update_label()

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
	if(!ismarineleaderjob(squad_leader.job))
		squad_leader.skills.setRating(leadership = SKILL_LEAD_NOVICE)
		if(squad_leader.mind)
			var/datum/job/J = squad_leader.job
			squad_leader.comm_title = J.comm_title
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
	if(!ismarineleaderjob(squad_leader.job))
		squad_leader.skills.setRating(leadership = SKILL_LEAD_TRAINED)
		squad_leader.comm_title = "aSL"
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
	var/text = copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN)
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


/datum/squad/proc/check_entry(datum/job/job)
	if(!(job.type in current_positions))
		CRASH("Attempted to insert [job.type] into squad [name]")
	if(job.type in max_positions) //There's special behavior defined for it.
		if(max_positions[job.type] == -1)
			return TRUE
		if(current_positions[job.type] >= max_positions[job.type])
			return FALSE
		return TRUE
	if(current_positions[job.type] >= SQUAD_MAX_POSITIONS(job.total_positions))
		return FALSE
	return TRUE


//This reserves a player a spot in the squad by using a mind variable.
//It is necessary so that they can smoothly reroll a squad role in case of the strict preference.
/datum/squad/proc/assign_initial(mob/new_player/player, datum/job/job, latejoin = FALSE)
	if(!(job.type in current_positions))
		CRASH("Attempted to insert [job.type] into squad [name]")
	if(!latejoin)
		current_positions[job.type]++
	player.assigned_squad = src
	return TRUE


//A generic proc for handling the initial squad role assignment in SSjob
/proc/handle_initial_squad(mob/new_player/player, datum/job/job, latejoin = FALSE)
	var/strict = player.client.prefs.be_special && (player.client.prefs.be_special & BE_SQUAD_STRICT)
	var/datum/squad/P = SSjob.active_squads[player.client.prefs.preferred_squad]
	var/datum/squad/R = SSjob.active_squads[pick(SSjob.active_squads)]
	switch(job.title)
		if(SQUAD_MARINE)
			return P?.assign_initial(player, job, latejoin) || R.assign_initial(player, job, latejoin)
		if(SQUAD_ENGINEER)
			for(var/i in shuffle(SSjob.active_squads))
				var/datum/squad/S = SSjob.active_squads[i]
				if(!S.check_entry(job))
					continue
				if(P && P == S && S.assign_initial(player, job, latejoin))
					return TRUE
			if(strict && !latejoin)
				return FALSE
			for(var/i in shuffle(SSjob.active_squads))
				var/datum/squad/S = SSjob.active_squads[i]
				if(!S.check_entry(job))
					continue
				else if(S.assign_initial(player, job, latejoin))
					return TRUE
		if(SQUAD_CORPSMAN)
			for(var/i in shuffle(SSjob.active_squads))
				var/datum/squad/S = SSjob.active_squads[i]
				if(!S.check_entry(job))
					continue
				if(P && P == S && S.assign_initial(player, job, latejoin))
					return TRUE
			if(strict && !latejoin)
				return FALSE
			for(var/i in shuffle(SSjob.active_squads))
				var/datum/squad/S = SSjob.active_squads[i]
				if(!S.check_entry(job))
					continue
				else if(S.assign_initial(player, job, latejoin))
					return TRUE
		if(SQUAD_SMARTGUNNER)
			for(var/i in shuffle(SSjob.active_squads))
				var/datum/squad/S = SSjob.active_squads[i]
				if(!S.check_entry(job))
					continue
				if(P && P == S && S.assign_initial(player, job, latejoin))
					return TRUE
			if(strict && !latejoin)
				return FALSE
			for(var/i in shuffle(SSjob.active_squads))
				var/datum/squad/S = SSjob.active_squads[i]
				if(!S.check_entry(job, latejoin))
					continue
				else if(S.assign_initial(player, job, latejoin))
					return TRUE
		if(SQUAD_SPECIALIST)
			for(var/i in shuffle(SSjob.active_squads))
				var/datum/squad/S = SSjob.active_squads[i]
				if(!S.check_entry(job))
					continue
				if(P && P == S && S.assign_initial(player, job, latejoin))
					return TRUE
			if(strict && !latejoin)
				return FALSE
			for(var/i in shuffle(SSjob.active_squads))
				var/datum/squad/S = SSjob.active_squads[i]
				if(!S.check_entry(job))
					continue
				else if(S.assign_initial(player, job, latejoin))
					return TRUE
		if(SQUAD_LEADER)
			for(var/i in shuffle(SSjob.active_squads))
				var/datum/squad/S = SSjob.active_squads[i]
				if(!S.check_entry(job))
					continue
				if(P && P == S && S.assign_initial(player, job, latejoin))
					return TRUE
			if(strict && !latejoin)
				return FALSE
			for(var/i in shuffle(SSjob.active_squads))
				var/datum/squad/S = SSjob.active_squads[i]
				if(!S.check_entry(job))
					continue
				else if(S.assign_initial(player, job, latejoin))
					return TRUE
	return FALSE


/proc/reset_squads()
	for(var/i in SSjob.squads)
		var/datum/squad/squad = SSjob.squads[i]
		for(var/j in squad.current_positions)
			squad.current_positions[j] = 0
