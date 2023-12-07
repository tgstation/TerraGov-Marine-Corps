/datum/squad
	var/name = ""
	/// custom squad only: allows users to set a description for the squad
	var/desc = ""
	var/id = NO_SQUAD
	var/tracking_id = null // for use with SSdirection
	var/color = 0 //Color for helmets, etc.
	var/list/access = list() //Which special access do we grant them

	var/current_positions = list(
		SQUAD_MARINE = 0,
		SQUAD_ENGINEER = 0,
		SQUAD_CORPSMAN = 0,
		SQUAD_SMARTGUNNER = 0,
		SQUAD_LEADER = 0,
		SQUAD_ROBOT = 0, //for campaign
	)
	var/max_positions = list(
		SQUAD_MARINE = -1,
		SQUAD_LEADER = 1)

	var/list/marines_list = list() // list of humans in that squad.

	var/radio_freq = 1461
	var/mob/living/carbon/human/squad_leader
	var/mob/living/carbon/human/overwatch_officer

	var/primary_objective = null //Text strings
	var/secondary_objective = null

	var/list/squad_laser_targets = list()
	///Faction of that squad
	var/faction = FACTION_TERRAGOV


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

//SOM squads
/datum/squad/zulu
	name = "Zulu"
	id = ZULU_SQUAD
	color = "#FF6A00"
	access = list(ACCESS_MARINE_ALPHA) //No unique SOM access yet
	radio_freq = FREQ_ZULU
	faction = FACTION_SOM
	current_positions = list(
		SOM_SQUAD_MARINE = 0,
		SOM_SQUAD_VETERAN = 0,
		SOM_SQUAD_CORPSMAN = 0,
		SOM_SQUAD_ENGINEER = 0,
		SOM_SQUAD_LEADER = 0,
)
	max_positions = list(
		SOM_SQUAD_MARINE = -1,
		SOM_SQUAD_LEADER = 1,
)

/datum/squad/yankee
	name = "Yankee"
	id = YANKEE_SQUAD
	color = "#009999"
	access = list(ACCESS_MARINE_BRAVO)
	radio_freq = FREQ_YANKEE
	faction = FACTION_SOM
	current_positions = list(
		SOM_SQUAD_MARINE = 0,
		SOM_SQUAD_VETERAN = 0,
		SOM_SQUAD_CORPSMAN = 0,
		SOM_SQUAD_ENGINEER = 0,
		SOM_SQUAD_LEADER = 0,
)
	max_positions = list(
		SOM_SQUAD_MARINE = -1,
		SOM_SQUAD_LEADER = 1,
)

/datum/squad/xray
	name = "Xray"
	id = XRAY_SQUAD
	color = "#008000"
	access = list(ACCESS_MARINE_CHARLIE)
	radio_freq = FREQ_XRAY
	faction = FACTION_SOM
	current_positions = list(
		SOM_SQUAD_MARINE = 0,
		SOM_SQUAD_VETERAN = 0,
		SOM_SQUAD_CORPSMAN = 0,
		SOM_SQUAD_ENGINEER = 0,
		SOM_SQUAD_LEADER = 0,
)
	max_positions = list(
		SOM_SQUAD_MARINE = -1,
		SOM_SQUAD_LEADER = 1,
)

/datum/squad/whiskey
	name = "Whiskey"
	id = WHISKEY_SQUAD
	color = "#CC00CC"
	access = list(ACCESS_MARINE_DELTA)
	radio_freq = FREQ_WHISKEY
	faction = FACTION_SOM
	current_positions = list(
		SOM_SQUAD_MARINE = 0,
		SOM_SQUAD_VETERAN = 0,
		SOM_SQUAD_CORPSMAN = 0,
		SOM_SQUAD_ENGINEER = 0,
		SOM_SQUAD_LEADER = 0,
)
	max_positions = list(
		SOM_SQUAD_MARINE = -1,
		SOM_SQUAD_LEADER = 1,
)

/datum/squad/New(set_color, set_name)
	if(set_color)
		color = set_color
	if(set_name)
		name = set_name

	..()

	tracking_id = SSdirection.init_squad(name, squad_leader)

	for(var/state in GLOB.playable_squad_icons)
		var/icon/top = icon('icons/UI_icons/map_blips.dmi', state, frame = 1)
		top.Blend(color, ICON_MULTIPLY)
		var/icon/bottom = icon('icons/UI_icons/map_blips.dmi', "squad_underlay", frame = 1)
		top.Blend(bottom, ICON_UNDERLAY)

		var/icon_state = lowertext(name) + "_" + state
		GLOB.minimap_icons[icon_state] = icon2base64(top)

/datum/squad/Destroy(force, ...)
	for(var/mob/living/carbon/human/squaddie AS in marines_list)
		remove_from_squad(squaddie)
	GLOB.custom_squad_radio_freqs -= "[radio_freq]"
	SSjob.active_squads[faction] -= src
	SSjob.squads -= id
	return ..()


/datum/squad/proc/get_all_members()
	return marines_list


/datum/squad/proc/get_total_members()
	return length(marines_list)


/datum/squad/proc/insert_into_squad(mob/living/carbon/human/new_squaddie, give_radio = FALSE)
	if(!(new_squaddie.job in SSjob.active_occupations))
		CRASH("attempted to insert marine [new_squaddie] from squad [name] while having job [isnull(new_squaddie.job) ? "null" : new_squaddie.job.title]")

	var/obj/item/card/id/idcard = new_squaddie.get_idcard()
	if(!istype(idcard))
		return FALSE

	if(new_squaddie.assigned_squad)
		CRASH("attempted to insert marine [new_squaddie] into squad while already having one")

	if(!(new_squaddie.job.title in current_positions))
		CRASH("Attempted to insert [new_squaddie.job.title] into squad [name]")

	current_positions[new_squaddie.job.title]++

	if((ismarineleaderjob(new_squaddie.job) || issommarineleaderjob(new_squaddie.job)) && !squad_leader)
		squad_leader = new_squaddie
		SSdirection.set_leader(tracking_id, new_squaddie)
		SSdirection.start_tracking(faction == FACTION_SOM ? TRACKING_ID_SOM_COMMANDER : TRACKING_ID_MARINE_COMMANDER, new_squaddie)

	var/obj/item/radio/headset/mainship/headset = new_squaddie.wear_ear
	if(give_radio && !istype(headset))
		if(new_squaddie.wear_ear)
			new_squaddie.dropItemToGround(new_squaddie.wear_ear)
		headset = new()
		new_squaddie.equip_to_slot_or_del(headset, SLOT_EARS)

	if(istype(headset))
		headset.set_frequency(radio_freq)
		headset.recalculateChannels()
		headset.add_minimap()
		if(headset.sl_direction && new_squaddie != squad_leader)
			SSdirection.start_tracking(tracking_id, new_squaddie)

	for(var/datum/data/record/sheet AS in GLOB.datacore.general)
		if(sheet.fields["name"] == new_squaddie.real_name)
			sheet.fields["squad"] = name
			break

	idcard.access += access
	idcard.assignment = "[name] [new_squaddie.job.title]"
	idcard.assigned_fireteam = 0
	idcard.update_label()

	marines_list += new_squaddie
	new_squaddie.assigned_squad = src
	new_squaddie.hud_set_job(faction)
	new_squaddie.update_action_buttons()
	new_squaddie.update_inv_head()
	new_squaddie.update_inv_wear_suit()
	return TRUE


/datum/squad/proc/remove_from_squad(mob/living/carbon/human/leaving_squaddie)
	if(!(leaving_squaddie.job in SSjob.active_occupations))
		CRASH("attempted to remove marine [leaving_squaddie] from squad [name] while having job [isnull(leaving_squaddie.job) ? "null" : leaving_squaddie.job.title]")

	if(!leaving_squaddie.assigned_squad)
		return FALSE

	if(leaving_squaddie.assigned_squad != src)
		CRASH("attempted to remove marine [leaving_squaddie] from squad [name] while being a member of squad [leaving_squaddie.assigned_squad.name]")

	var/obj/item/card/id/id_card = leaving_squaddie.get_idcard()
	if(!istype(id_card))
		return FALSE

	if(leaving_squaddie == squad_leader)
		demote_leader()
	else
		SSdirection.stop_tracking(tracking_id, leaving_squaddie)

	if(leaving_squaddie.job.title in current_positions)
		current_positions[leaving_squaddie.job.title]--
	else
		stack_trace("Removed [leaving_squaddie.job.title] from squad [name] somehow")

	var/obj/item/radio/headset/mainship/headset = leaving_squaddie.wear_ear
	if(istype(headset))
		headset.remove_minimap()
		headset.set_frequency(initial(headset.frequency))

	for(var/datum/data/record/sheet AS in GLOB.datacore.general)
		if(sheet.fields["name"] == leaving_squaddie.real_name)
			sheet.fields["squad"] = null
			break

	id_card.access -= access
	id_card.assignment = leaving_squaddie.job.title
	id_card.update_label()

	marines_list -= leaving_squaddie

	leaving_squaddie.assigned_squad = null
	leaving_squaddie.hud_set_job(faction)
	leaving_squaddie.update_action_buttons()
	leaving_squaddie.update_inv_head()
	leaving_squaddie.update_inv_wear_suit()
	return TRUE


/datum/squad/proc/demote_leader()
	if(!squad_leader)
		CRASH("attempted to remove squad leader from squad [name] while not having one set")

	SSdirection.clear_leader(tracking_id)
	SSdirection.stop_tracking(TRACKING_ID_MARINE_COMMANDER, squad_leader)
	SSdirection.stop_tracking(TRACKING_ID_SOM_COMMANDER, squad_leader)

	//Handle aSL skill level and radio
	if(!ismarineleaderjob(squad_leader.job) && !issommarineleaderjob(squad_leader.job))
		squad_leader.set_skills(squad_leader.skills.setRating(leadership = SKILL_LEAD_NOVICE))
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
	H.hud_set_job(faction)
	H.update_inv_head()
	H.update_inv_wear_suit()


/datum/squad/proc/promote_leader(mob/living/carbon/human/H)
	if(squad_leader)
		CRASH("attempted to promote [H] to squad leader of [src] while having one set - [squad_leader]")

	squad_leader = H
	SSdirection.set_leader(tracking_id, H)
	SSdirection.start_tracking(faction == FACTION_SOM ? TRACKING_ID_SOM_COMMANDER : TRACKING_ID_MARINE_COMMANDER, H)

	//Handle aSL skill level and radio
	if(!ismarineleaderjob(squad_leader.job) && !issommarineleaderjob(squad_leader.job))
		squad_leader.set_skills(squad_leader.skills.setRating(leadership = SKILL_LEAD_TRAINED))
		squad_leader.comm_title = "aSL"
		var/obj/item/card/id/ID = squad_leader.get_idcard()
		if(istype(ID))
			ID.access += list(ACCESS_MARINE_LEADER, ACCESS_MARINE_DROPSHIP)

	if(istype(squad_leader.wear_ear, /obj/item/radio/headset/mainship/marine))
		var/obj/item/radio/headset/mainship/marine/R = squad_leader.wear_ear
		R.channels[RADIO_CHANNEL_COMMAND] = TRUE
		R.secure_radio_connections[RADIO_CHANNEL_COMMAND] = add_radio(R, GLOB.radiochannels[RADIO_CHANNEL_COMMAND])
		R.use_command = TRUE

	squad_leader.hud_set_job(faction)
	squad_leader.update_action_buttons()
	squad_leader.update_inv_head()
	squad_leader.update_inv_wear_suit()
	to_chat(squad_leader, "<font size='3' color='blue'>You're now the Squad Leader for [src]!</font>")


/datum/squad/proc/format_message(message, mob/living/carbon/human/sender)
	var/nametext = ""
	var/text = copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN)
	if(ishuman(sender))
		var/obj/item/card/id/ID = sender.get_idcard()
		nametext = "[ID?.rank] [sender.real_name] transmits: "
		text = "<font size='3'><b>[text]<b></font>"
	return "[nametext][text]"


/datum/squad/proc/message_squad(message, mob/living/carbon/human/sender)
	if(is_ic_filtered(message) || NON_ASCII_CHECK(message))
		to_chat(sender, span_boldnotice("Message invalid. Check your message does not contain filtered words or characters."))
		return

	var/header = "AUTOMATED CIC NOTICE:"
	if(sender)
		header = "CIC SQUAD MESSAGE FROM [sender.real_name]:"

	for(var/mob/living/marine AS in marines_list)
		marine.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:center valign='top'><u>[header]</u></span><br>" + message, /atom/movable/screen/text/screen_text/command_order)

/datum/squad/proc/check_entry(datum/job/job)
	if(!(job.title in current_positions))
		CRASH("Attempted to insert [job.title] into squad [name]")
	if(job.title in max_positions) //There's special behavior defined for it.
		if(max_positions[job.title] == -1)
			return TRUE
		if(current_positions[job.title] >= max_positions[job.title])
			return FALSE
		return TRUE
	if(current_positions[job.title] >= SQUAD_MAX_POSITIONS(job.total_positions))
		return FALSE
	return TRUE


//This reserves a player a spot in the squad by using a mind variable.
//It is necessary so that they can smoothly reroll a squad role in case of the strict preference.
/datum/squad/proc/assign_initial(mob/new_player/player, datum/job/job, latejoin = FALSE)
	if(!(job.title in current_positions))
		CRASH("Attempted to insert [job.title] into squad [name]")
	if(!latejoin)
		current_positions[job.title]++
	player.assigned_squad = src
	return TRUE


///A generic proc for handling the initial squad role assignment in SSjob
/proc/handle_initial_squad(mob/new_player/player, datum/job/job, latejoin = FALSE, faction = FACTION_TERRAGOV)
	var/strict = player.client.prefs.be_special && (player.client.prefs.be_special & BE_SQUAD_STRICT)
	//List of all the faction accessible squads
	var/list/available_squads = SSjob.active_squads[faction]
	var/datum/squad/preferred_squad
	if(faction == FACTION_SOM)
		preferred_squad = LAZYACCESSASSOC(SSjob.squads_by_name, faction, player.client.prefs.preferred_squad_som)
	else
		preferred_squad = LAZYACCESSASSOC(SSjob.squads_by_name, faction, player.client.prefs.preferred_squad) //TGMC and rebels use the same squads
	if(available_squads.Find(preferred_squad) && preferred_squad?.assign_initial(player, job, latejoin))
		return TRUE
	if(strict)
		to_chat(player, span_warning("That squad is full!"))
		return FALSE
	//If our preferred squad is not available, we try every other squad
	for(var/datum/squad/squad AS in shuffle(available_squads))
		if(!squad.check_entry(job))
			continue
		if(squad.assign_initial(player, job, latejoin))
			return TRUE
	return FALSE

GLOBAL_LIST_EMPTY_TYPED(custom_squad_radio_freqs, /datum/squad)
///initializes a new custom squad. all args mandatory
/proc/create_squad(squad_name, squad_color, mob/living/carbon/human/creator)
	//Create the squad
	if(!squad_name)
		return
	if(!squad_color)
		return
	if(!ishuman(creator))
		return
	var/freq = FREQ_CUSTOM_SQUAD_MIN + 2 * length(GLOB.custom_squad_radio_freqs)
	if(freq > FREQ_CUSTOM_SQUAD_MAX)
		return

	var/new_id = lowertext(squad_name) + "_squad"
	if(SSjob.squads[new_id])
		return

	var/squad_faction = creator.faction
	var/datum/squad/new_squad = new(squad_color, squad_name)
	new_squad.id = new_id
	new_squad.access = list(ACCESS_MARINE_ALPHA, ACCESS_MARINE_BRAVO, ACCESS_MARINE_CHARLIE, ACCESS_MARINE_DELTA)
	new_squad.radio_freq = freq
	GLOB.custom_squad_radio_freqs["[freq]"] = new_squad
	var/radio_channel_name = new_squad.name
	LAZYADDASSOCSIMPLE(GLOB.radiochannels, "[radio_channel_name]", freq)
	LAZYADDASSOCSIMPLE(GLOB.reverseradiochannels, "[freq]", radio_channel_name)
	new_squad.faction = squad_faction
	if(new_squad.faction == FACTION_TERRAGOV)
		var/list/terragov_server_freqs = GLOB.telecomms_freq_listening_list[/obj/machinery/telecomms/server/presets/alpha]
		var/list/terragov_bus_freqs = GLOB.telecomms_freq_listening_list[/obj/machinery/telecomms/bus/preset_three]
		var/list/terragov_receiver_freqs = GLOB.telecomms_freq_listening_list[/obj/machinery/telecomms/receiver/preset_left]
		LAZYADDASSOCSIMPLE(terragov_server_freqs, 1, freq)
		LAZYADDASSOCSIMPLE(terragov_bus_freqs, 1, freq)
		LAZYADDASSOCSIMPLE(terragov_receiver_freqs, 1, freq)
	else
		var/list/som_server_freqs = GLOB.telecomms_freq_listening_list[/obj/machinery/telecomms/server/presets/zulu]
		var/list/som_bus_freqs = GLOB.telecomms_freq_listening_list[/obj/machinery/telecomms/bus/preset_three/som]
		var/list/som_receiver_freqs = GLOB.telecomms_freq_listening_list[/obj/machinery/telecomms/receiver/preset_left/som]
		LAZYADDASSOCSIMPLE(som_server_freqs, 1, freq)
		LAZYADDASSOCSIMPLE(som_bus_freqs, 1, freq)
		LAZYADDASSOCSIMPLE(som_receiver_freqs, 1, freq)
	SSjob.active_squads[new_squad.faction] += new_squad
	SSjob.squads[new_squad.id] = new_squad
	LAZYSET(SSjob.squads_by_name[new_squad.faction], new_squad.name, new_squad)
	creator.change_squad(new_squad.id)
	for(var/obj/item/encryptionkey/key in GLOB.custom_updating_encryptkeys)
		if(!istype(key.loc, /obj/item/radio/headset))
			continue
		var/obj/item/radio/headset/head = key.loc
		head.recalculateChannels()
	return new_squad

/// Color_hex = ui_key assoc list
GLOBAL_LIST_INIT(custom_squad_colors, list(
	COLOR_RED = "alpharadio",
	COLOR_VERY_SOFT_YELLOW = "bravoradio",
	COLOR_STRONG_MAGENTA = "charlieradio",
	COLOR_NAVY = "deltaradio",
	COLOR_PURPLE = "sciradio",
	COLOR_TAN_ORANGE = "zuluradio",
	COLOR_TEAL = "yankeeradio",
	COLOR_GREEN = "xrayradio",
	COLOR_MAGENTA = "whiskeyradio",
))
