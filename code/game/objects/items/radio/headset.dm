// Used for translating channels to tokens on examination
GLOBAL_LIST_INIT(channel_tokens, list(
	RADIO_CHANNEL_REQUISITIONS = RADIO_TOKEN_REQUISITIONS,
	RADIO_CHANNEL_COMMAND = RADIO_TOKEN_COMMAND,
	RADIO_CHANNEL_MEDICAL = RADIO_TOKEN_MEDICAL,
	RADIO_CHANNEL_ENGINEERING = RADIO_TOKEN_ENGINEERING,
	RADIO_CHANNEL_CAS = RADIO_TOKEN_CAS,
	RADIO_CHANNEL_ALPHA = RADIO_TOKEN_ALPHA,
	RADIO_CHANNEL_BRAVO = RADIO_TOKEN_BRAVO,
	RADIO_CHANNEL_CHARLIE = RADIO_TOKEN_CHARLIE,
	RADIO_CHANNEL_DELTA = RADIO_TOKEN_DELTA
))


/obj/item/radio/headset
	name = "radio headset"
	desc = "An updated, modular intercom that fits over the head. Takes encryption keys."
	icon_state = "headset"
	item_state = "headset"
	materials = list(/datum/material/metal = 75)
	subspace_transmission = TRUE
	canhear_range = 0 // can't hear headsets from very far away

	flags_equip_slot = ITEM_SLOT_EARS
	var/obj/item/encryptionkey/keyslot2 = null


/obj/item/radio/headset/Initialize()
	. = ..()
	if(keyslot)
		keyslot = new keyslot(src)
	if(keyslot2)
		keyslot2 = new keyslot2(src)
	recalculateChannels()


/obj/item/radio/headset/Destroy()
	if(keyslot2)
		QDEL_NULL(keyslot2)
	return ..()


/obj/item/radio/headset/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(isscrewdriver(I))
		if(keyslot || keyslot2)
			for(var/ch_name in channels)
				SSradio.remove_object(src, GLOB.radiochannels[ch_name])
				secure_radio_connections[ch_name] = null

			var/turf/T = get_turf(user)
			if(T)
				if(keyslot)
					keyslot.forceMove(T)
					keyslot = null
				if(keyslot2)
					keyslot2.forceMove(T)
					keyslot2 = null

			recalculateChannels()
			to_chat(user, span_notice("You pop out the encryption keys in the headset."))

		else
			to_chat(user, span_warning("This headset doesn't have any unique encryption keys!  How useless..."))

	else if(istype(I, /obj/item/encryptionkey))
		if(keyslot && keyslot2)
			to_chat(user, span_warning("The headset can't hold another key!"))
			return

		if(!keyslot)
			if(!user.transferItemToLoc(I, src))
				return
			keyslot = I

		else
			if(!user.transferItemToLoc(I, src))
				return
			keyslot2 = I

			I.forceMove(src)
			keyslot2 = I

		recalculateChannels()


/obj/item/radio/headset/examine(mob/user)
	. = ..()
	if(loc == user)
		// construction of frequency description
		var/list/avail_chans = list("Use [RADIO_KEY_COMMON] for the currently tuned frequency")
		if(length(channels))
			for(var/i in 1 to length(channels))
				if(i == 1)
					if(channels[i] in GLOB.channel_tokens)
						avail_chans += "use [MODE_TOKEN_DEPARTMENT] or [GLOB.channel_tokens[channels[i]]] for [lowertext(channels[i])]"
					else
						avail_chans += "use [MODE_TOKEN_DEPARTMENT] for [lowertext(channels[i])]"
				else
					avail_chans += "use [GLOB.channel_tokens[channels[i]]] for [lowertext(channels[i])]"
		. += "<span class='notice'>A small screen on the headset displays the following available frequencies:\n[english_list(avail_chans)]."

		if(command)
			. += span_info("Alt-click to toggle the high-volume mode.")
	else
		. += span_notice("A small screen on the headset flashes, it's too small to read without holding or wearing the headset.")


/obj/item/radio/headset/recalculateChannels()
	. = ..()
	if(keyslot2)
		for(var/ch_name in keyslot2.channels)
			if(!(ch_name in channels))
				channels[ch_name] = keyslot2.channels[ch_name]

	for(var/ch_name in channels)
		secure_radio_connections[ch_name] = add_radio(src, GLOB.radiochannels[ch_name])


/obj/item/radio/headset/talk_into(mob/living/M, message, channel, list/spans, datum/language/language)
	if(!listening)
		return ITALICS | REDUCE_RANGE
	return ..()


/obj/item/radio/headset/AltClick(mob/living/user)
	if(!istype(user) || !Adjacent(user) || user.incapacitated())
		return

	if(command)
		use_command = !use_command
		to_chat(user, span_notice("You toggle high-volume mode [use_command ? "on" : "off"]."))


/obj/item/radio/headset/can_receive(freq, level)
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		if(H.wear_ear == src)
			return ..()
	else if(issilicon(loc))
		return ..()
	return FALSE


/obj/item/radio/headset/attack_self(mob/living/user)
	if(!istype(user) || !Adjacent(user) || user.incapacitated())
		return
	channels[RADIO_CHANNEL_REQUISITIONS] = !channels[RADIO_CHANNEL_REQUISITIONS]
	to_chat(user, span_notice("You toggle supply comms [channels[RADIO_CHANNEL_REQUISITIONS] ? "on" : "off"]."))


/obj/item/radio/headset/survivor
	freqlock = TRUE
	frequency = FREQ_CIV_GENERAL


//MARINE HEADSETS
/obj/item/radio/headset/mainship
	name = "marine radio headset"
	desc = "A standard military radio headset."
	icon_state = "cargo_headset"
	item_state = "headset"
	frequency = FREQ_COMMON
	flags_atom = CONDUCT | PREVENT_CONTENTS_EXPLOSION
	freerange = TRUE
	var/obj/machinery/camera/camera
	var/datum/atom_hud/squadhud = null
	var/mob/living/carbon/human/wearer = null
	var/headset_hud_on = FALSE
	var/sl_direction = FALSE
	/// Which hud this headset gives access too
	var/hud_type = DATA_HUD_SQUAD_TERRAGOV
	///The type of minimap this headset gives access to
	var/datum/action/minimap/minimap_type = /datum/action/minimap/marine

/obj/item/radio/headset/mainship/Initialize()
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/item/radio/headset/mainship/LateInitialize(mapload)
	. = ..()
	camera = new /obj/machinery/camera/headset(src)


/obj/item/radio/headset/mainship/equipped(mob/living/carbon/human/user, slot)
	if(slot == SLOT_EARS)
		if(GLOB.faction_to_data_hud[user.faction] != hud_type && user.faction != FACTION_NEUTRAL)
			safety_protocol(user)
		wearer = user
		squadhud = GLOB.huds[hud_type]
		enable_squadhud()
		RegisterSignal(user, COMSIG_MOB_REVIVE, .proc/update_minimap_icon)
		RegisterSignal(user, COMSIG_MOB_DEATH, .proc/set_dead_on_minimap)
		RegisterSignal(user, COMSIG_HUMAN_SET_UNDEFIBBABLE, .proc/set_undefibbable_on_minimap)
	if(camera)
		camera.c_tag = user.name
		if(user.assigned_squad)
			camera.network |= lowertext(user.assigned_squad.name)
	return ..()

/// Make the headset lose its keysloy
/obj/item/radio/headset/mainship/proc/safety_protocol(mob/living/carbon/human/user)
	to_chat(user, span_warning("[src] violently buzzes and explodes in your face as its tampering mechanisms are triggered!"))
	playsound(user, 'sound/effects/explosion_small1.ogg', 50, 1)
	user.ex_act(EXPLODE_LIGHT)
	qdel(src)

/obj/item/radio/headset/mainship/dropped(mob/living/carbon/human/user)
	if(istype(user) && headset_hud_on)
		disable_squadhud()
		squadhud.remove_hud_from(user)
		user.hud_used.SL_locator.alpha = 0
		wearer = null
		squadhud = null
	if(camera)
		camera.c_tag = "Unknown"
		if(user.assigned_squad)
			camera.network -= lowertext(user.assigned_squad.name)
	UnregisterSignal(user, list(COMSIG_MOB_DEATH, COMSIG_HUMAN_SET_UNDEFIBBABLE, COMSIG_MOB_REVIVE))
	return ..()


/obj/item/radio/headset/mainship/Destroy()
	if(wearer)
		if(headset_hud_on && wearer.wear_ear == src)
			squadhud.remove_hud_from(wearer)
			wearer.SL_directional = null
			if(wearer.assigned_squad)
				SSdirection.stop_tracking(wearer.assigned_squad.tracking_id, wearer)
		wearer = null
	squadhud = null
	headset_hud_on = FALSE
	sl_direction = null
	QDEL_NULL(camera)
	return ..()


/obj/item/radio/headset/mainship/proc/enable_squadhud()
	squadhud.add_hud_to(wearer)
	headset_hud_on = TRUE
	if(!camera.status)
		camera.toggle_cam(null, FALSE)
	if(wearer.mind && wearer.assigned_squad && !sl_direction)
		enable_sl_direction()
	add_minimap()
	to_chat(wearer, span_notice("You toggle the Squad HUD on."))
	playsound(loc, 'sound/machines/click.ogg', 15, 0, 1)


/obj/item/radio/headset/mainship/proc/disable_squadhud()
	squadhud.remove_hud_from(wearer)
	headset_hud_on = FALSE
	if(camera.status)
		camera.toggle_cam(null, FALSE)
	if(sl_direction)
		disable_sl_direction()
	remove_minimap()
	to_chat(wearer, span_notice("You toggle the Squad HUD off."))
	playsound(loc, 'sound/machines/click.ogg', 15, 0, 1)

/obj/item/radio/headset/mainship/proc/add_minimap()
	remove_minimap()
	var/datum/action/minimap/mini = new minimap_type
	mini.give_action(wearer)
	INVOKE_NEXT_TICK(src, .proc/update_minimap_icon) //Mobs are spawned inside nullspace sometimes so this is to avoid that hijinks

/obj/item/radio/headset/mainship/proc/update_minimap_icon()
	SIGNAL_HANDLER
	SSminimaps.remove_marker(wearer)
	if(!wearer.job || !wearer.job.minimap_icon)
		return
	var/marker_flags = initial(minimap_type.marker_flags)
	if(wearer.job?.job_flags & JOB_FLAG_ALWAYS_VISIBLE_ON_MINIMAP || wearer.stat == DEAD) //We show to all marines if we have this flag, separated by faction
		if(hud_type == DATA_HUD_SQUAD_TERRAGOV)
			marker_flags = MINIMAP_FLAG_MARINE
		else if(hud_type == DATA_HUD_SQUAD_REBEL)
			marker_flags = MINIMAP_FLAG_MARINE_REBEL
		else if(hud_type == DATA_HUD_SQUAD_SOM)
			marker_flags = MINIMAP_FLAG_MARINE_SOM
		else if(hud_type == DATA_HUD_SQUAD_IMP)
			marker_flags = MINIMAP_FLAG_MARINE_IMP
	if(HAS_TRAIT(wearer, TRAIT_UNDEFIBBABLE))
		SSminimaps.add_marker(wearer, wearer.z, marker_flags, "undefibbable")
		return
	if(wearer.stat == DEAD)
		SSminimaps.add_marker(wearer, wearer.z, marker_flags, "defibbable")
		return
	if(wearer.assigned_squad)
		SSminimaps.add_marker(wearer, wearer.z, marker_flags, lowertext(wearer.assigned_squad.name)+"_"+wearer.job.minimap_icon)
		return
	SSminimaps.add_marker(wearer, wearer.z, marker_flags, wearer.job.minimap_icon)

///Change the minimap icon to a dead icon
/obj/item/radio/headset/mainship/proc/set_dead_on_minimap()
	SIGNAL_HANDLER
	SSminimaps.remove_marker(wearer)
	if(!wearer.job || !wearer.job.minimap_icon)
		return
	var/marker_flags
	if(hud_type == DATA_HUD_SQUAD_TERRAGOV)
		marker_flags = MINIMAP_FLAG_MARINE
	else if(hud_type == DATA_HUD_SQUAD_REBEL)
		marker_flags = MINIMAP_FLAG_MARINE_REBEL
	else if(hud_type == DATA_HUD_SQUAD_SOM)
		marker_flags = MINIMAP_FLAG_MARINE_SOM
	else if(hud_type == DATA_HUD_SQUAD_IMP)
		marker_flags = MINIMAP_FLAG_MARINE_IMP
	SSminimaps.add_marker(wearer, wearer.z, marker_flags, "defibbable")

///Change the minimap icon to a undefibbable icon
/obj/item/radio/headset/mainship/proc/set_undefibbable_on_minimap()
	SIGNAL_HANDLER
	SSminimaps.remove_marker(wearer)
	if(!wearer.job || !wearer.job.minimap_icon)
		return
	var/marker_flags
	if(hud_type == DATA_HUD_SQUAD_TERRAGOV)
		marker_flags = MINIMAP_FLAG_MARINE
	else if(hud_type == DATA_HUD_SQUAD_REBEL)
		marker_flags = MINIMAP_FLAG_MARINE_REBEL
	else if(hud_type == DATA_HUD_SQUAD_SOM)
		marker_flags = MINIMAP_FLAG_MARINE_SOM
	else if(hud_type == DATA_HUD_SQUAD_IMP)
		marker_flags = MINIMAP_FLAG_MARINE_IMP
	SSminimaps.add_marker(wearer, wearer.z, marker_flags, "undefibbable")

///Remove all action of type minimap from the wearer, and make him disappear from the minimap
/obj/item/radio/headset/mainship/proc/remove_minimap()
	SSminimaps.remove_marker(wearer)
	for(var/datum/action/action AS in wearer.actions)
		if(istype(action, /datum/action/minimap))
			action.remove_action(wearer)

/obj/item/radio/headset/mainship/proc/enable_sl_direction()
	if(!headset_hud_on)
		to_chat(wearer, span_warning("You need to turn the HUD on first!"))
		return

	if(wearer.mind && wearer.assigned_squad && wearer.hud_used?.SL_locator)
		wearer.hud_used.SL_locator.alpha = 128
		if(wearer.assigned_squad.squad_leader == wearer)
			SSdirection.set_leader(wearer.assigned_squad.tracking_id, wearer)
			SSdirection.start_tracking(TRACKING_ID_MARINE_COMMANDER, wearer)
		else
			SSdirection.start_tracking(wearer.assigned_squad.tracking_id, wearer)

	sl_direction = TRUE
	to_chat(wearer, span_notice("You toggle the SL directional display on."))
	playsound(loc, 'sound/machines/click.ogg', 15, 0, 1)


/obj/item/radio/headset/mainship/proc/disable_sl_direction()
	if(!wearer.assigned_squad)
		return

	if(wearer.mind && wearer.hud_used?.SL_locator)
		wearer.hud_used.SL_locator.alpha = 0

	if(wearer.assigned_squad.squad_leader == wearer)
		SSdirection.clear_leader(wearer.assigned_squad.tracking_id)
		SSdirection.stop_tracking(TRACKING_ID_MARINE_COMMANDER, wearer)
	else
		SSdirection.stop_tracking(wearer.assigned_squad.tracking_id, wearer)

	sl_direction = FALSE
	to_chat(wearer, span_notice("You toggle the SL directional display off."))
	playsound(loc, 'sound/machines/click.ogg', 15, 0, TRUE)



/obj/item/radio/headset/mainship/verb/configure_squadhud()
	set name = "Configure Headset HUD"
	set category = "Object"
	set src in usr

	if(!can_interact(usr))
		return FALSE

	interact(usr)


/obj/item/radio/headset/mainship/can_interact(mob/user)
	. = ..()
	if(!.)
		return FALSE

	if(!wearer)
		return FALSE

	return TRUE



/obj/item/radio/headset/mainship/interact(mob/user)
	. = ..()
	if(.)
		return

	var/dat = {"
	<b><A href='?src=\ref[src];headset_hud_on=1'>Squad HUD: [headset_hud_on ? "On" : "Off"]</A></b><BR>
	<BR>
	<b><A href='?src=\ref[src];sl_direction=1'>Squad Leader Directional Indicator: [sl_direction ? "On" : "Off"]</A></b><BR>
	<BR>"}

	var/datum/browser/popup = new(user, "radio")
	popup.set_content(dat)
	popup.open()


/obj/item/radio/headset/mainship/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["headset_hud_on"])
		if(headset_hud_on)
			disable_squadhud()
		else
			enable_squadhud()

	if(href_list["sl_direction"])
		if(sl_direction)
			disable_sl_direction()
		else
			enable_sl_direction()

	updateUsrDialog()


/obj/item/radio/headset/mainship/st
	name = "technician radio headset"
	icon_state = "eng_headset"
	keyslot = /obj/item/encryptionkey/general
	keyslot2 = /obj/item/encryptionkey/engi

/obj/item/radio/headset/mainship/st/rebel
	frequency = FREQ_COMMON_REBEL
	keyslot = /obj/item/encryptionkey/general/rebel
	keyslot2 = /obj/item/encryptionkey/engi/rebel
	hud_type = DATA_HUD_SQUAD_REBEL
	minimap_type = /datum/action/minimap/marine/rebel

/obj/item/radio/headset/mainship/res
	name = "research radio headset"
	icon_state = "med_headset"
	keyslot = /obj/item/encryptionkey/med
	minimap_type = /datum/action/minimap/researcher

/obj/item/radio/headset/mainship/doc
	name = "medical radio headset"
	icon_state = "med_headset"
	keyslot = /obj/item/encryptionkey/med

/obj/item/radio/headset/mainship/doc/rebel
	frequency = FREQ_COMMON_REBEL
	keyslot = /obj/item/encryptionkey/med/rebel
	hud_type = DATA_HUD_SQUAD_REBEL
	minimap_type = /datum/action/minimap/marine/rebel

/obj/item/radio/headset/mainship/ct
	name = "supply radio headset"
	icon_state = "cargo_headset"
	keyslot = /obj/item/encryptionkey/general

/obj/item/radio/headset/mainship/ct/rebel
	frequency = FREQ_COMMON_REBEL
	keyslot = /obj/item/encryptionkey/general/rebel
	hud_type = DATA_HUD_SQUAD_REBEL
	minimap_type = /datum/action/minimap/marine/rebel

/obj/item/radio/headset/mainship/mcom
	name = "marine command radio headset"
	icon_state = "com_headset_alt"
	keyslot = /obj/item/encryptionkey/mcom
	use_command = TRUE
	command = TRUE

/obj/item/radio/headset/mainship/mcom/rebel
	frequency = FREQ_COMMON_REBEL
	keyslot = /obj/item/encryptionkey/mcom/rebel
	hud_type = DATA_HUD_SQUAD_REBEL
	minimap_type = /datum/action/minimap/marine/rebel

/obj/item/radio/headset/mainship/mcom/silicon
	name = "silicon radio"
	keyslot = /obj/item/encryptionkey/mcom/ai

/obj/item/radio/headset/mainship/mcom/silicon/rebel
	frequency = FREQ_COMMON_REBEL
	keyslot = /obj/item/encryptionkey/mcom/ai/rebel
	hud_type = DATA_HUD_SQUAD_REBEL
	minimap_type = /datum/action/minimap/marine/rebel

/obj/item/radio/headset/mainship/marine
	keyslot = /obj/item/encryptionkey/general

/obj/item/radio/headset/mainship/marine/rebel
	frequency = FREQ_COMMON_REBEL
	keyslot = /obj/item/encryptionkey/general/rebel
	hud_type = DATA_HUD_SQUAD_REBEL
	minimap_type = /datum/action/minimap/marine/rebel

/obj/item/radio/headset/mainship/marine/Initialize(mapload, datum/squad/squad, rank)
	if(squad)
		icon_state = "headset_marine_[lowertext(squad.name)]"
		var/dat = "marine [lowertext(squad.name)]"
		frequency = squad.radio_freq
		if(ispath(rank, /datum/job/terragov/squad/leader))
			dat += " leader"
			keyslot2 = squad.faction == FACTION_TERRAGOV ? /obj/item/encryptionkey/squadlead : /obj/item/encryptionkey/squadlead/rebel
			use_command = TRUE
			command = TRUE
		else if(ispath(rank, /datum/job/terragov/squad/engineer))
			dat += " engineer"
			keyslot2 = squad.faction == FACTION_TERRAGOV ? /obj/item/encryptionkey/engi : /obj/item/encryptionkey/engi/rebel
		else if(ispath(rank, /datum/job/terragov/squad/corpsman))
			dat += " corpsman"
			keyslot2 = squad.faction == FACTION_TERRAGOV ? /obj/item/encryptionkey/med : /obj/item/encryptionkey/med/rebel
		name = dat + " radio headset"
	return ..()

/obj/item/radio/headset/mainship/marine/alpha
	name = "marine alpha radio headset"
	icon_state = "headset_marine_alpha"
	frequency = FREQ_ALPHA //default frequency is alpha squad channel, not FREQ_COMMON
	minimap_type = /datum/action/minimap/marine

/obj/item/radio/headset/mainship/marine/alpha/LateInitialize(mapload)
	. = ..()
	camera.network += list("alpha")


/obj/item/radio/headset/mainship/marine/alpha/lead
	name = "marine alpha leader radio headset"
	keyslot2 = /obj/item/encryptionkey/squadlead
	use_command = TRUE
	command = TRUE


/obj/item/radio/headset/mainship/marine/alpha/engi
	name = "marine alpha engineer radio headset"
	keyslot2 = /obj/item/encryptionkey/engi

/obj/item/radio/headset/mainship/marine/alpha/med
	name = "marine alpha corpsman radio headset"
	keyslot2 = /obj/item/encryptionkey/med



/obj/item/radio/headset/mainship/marine/bravo
	name = "marine bravo radio headset"
	icon_state = "headset_marine_bravo"
	frequency = FREQ_BRAVO
	minimap_type = /datum/action/minimap/marine

/obj/item/radio/headset/mainship/marine/bravo/LateInitialize(mapload)
	. = ..()
	camera.network += list("bravo")


/obj/item/radio/headset/mainship/marine/bravo/lead
	name = "marine bravo leader radio headset"
	keyslot2 = /obj/item/encryptionkey/squadlead
	use_command = TRUE
	command = TRUE


/obj/item/radio/headset/mainship/marine/bravo/engi
	name = "marine bravo engineer radio headset"
	keyslot2 = /obj/item/encryptionkey/engi


/obj/item/radio/headset/mainship/marine/bravo/med
	name = "marine bravo corpsman radio headset"
	keyslot2 = /obj/item/encryptionkey/med


/obj/item/radio/headset/mainship/marine/charlie
	name = "marine charlie radio headset"
	icon_state = "headset_marine_charlie"
	frequency = FREQ_CHARLIE
	minimap_type = /datum/action/minimap/marine

/obj/item/radio/headset/mainship/marine/charlie/LateInitialize(mapload)
	. = ..()
	camera.network += list("charlie")


/obj/item/radio/headset/mainship/marine/charlie/lead
	name = "marine charlie leader radio headset"
	keyslot2 = /obj/item/encryptionkey/squadlead
	use_command = TRUE
	command = TRUE


/obj/item/radio/headset/mainship/marine/charlie/engi
	name = "marine charlie engineer radio headset"
	keyslot2 = /obj/item/encryptionkey/engi


/obj/item/radio/headset/mainship/marine/charlie/med
	name = "marine charlie corpsman radio headset"
	keyslot2 = /obj/item/encryptionkey/med



/obj/item/radio/headset/mainship/marine/delta
	name = "marine delta radio headset"
	icon_state = "headset_marine_delta"
	frequency = FREQ_DELTA
	minimap_type = /datum/action/minimap/marine

/obj/item/radio/headset/mainship/marine/delta/LateInitialize(mapload)
	. = ..()
	camera.network += list("delta")


/obj/item/radio/headset/mainship/marine/delta/lead
	name = "marine delta leader radio headset"
	keyslot2 = /obj/item/encryptionkey/squadlead
	use_command = TRUE
	command = TRUE


/obj/item/radio/headset/mainship/marine/delta/engi
	name = "marine delta engineer radio headset"
	keyslot2 = /obj/item/encryptionkey/engi


/obj/item/radio/headset/mainship/marine/delta/med
	name = "marine delta corpsman radio headset"
	keyslot2 = /obj/item/encryptionkey/med

/obj/item/radio/headset/mainship/marine/generic
	name = "marine generic radio headset"
	icon_state = "headset_marine_generic"
	minimap_type = /datum/action/minimap/marine

/obj/item/radio/headset/mainship/marine/generic/cas
	name = "marine fire support specialist headset"
	icon_state = "sec_headset"
	keyslot2 = /obj/item/encryptionkey/cas

/obj/item/radio/headset/mainship/marine/rebel/alpha
	name = "marine alpha radio headset"
	icon_state = "headset_marine_alpha"
	frequency = FREQ_ALPHA_REBEL //default frequency is alpha squad channel, not FREQ_COMMON
	minimap_type = /datum/action/minimap/marine/rebel

/obj/item/radio/headset/mainship/marine/rebel/alpha/LateInitialize(mapload)
	. = ..()
	camera.network += list("alpha_rebel")


/obj/item/radio/headset/mainship/marine/rebel/alpha/lead
	name = "marine alpha leader radio headset"
	keyslot2 = /obj/item/encryptionkey/squadlead/rebel
	use_command = TRUE
	command = TRUE


/obj/item/radio/headset/mainship/marine/rebel/alpha/engi
	name = "marine alpha engineer radio headset"
	keyslot2 = /obj/item/encryptionkey/engi/rebel

/obj/item/radio/headset/mainship/marine/rebel/alpha/med
	name = "marine alpha corpsman radio headset"
	keyslot2 = /obj/item/encryptionkey/med/rebel


/obj/item/radio/headset/mainship/marine/rebel/bravo
	name = "marine bravo radio headset"
	icon_state = "headset_marine_bravo"
	frequency = FREQ_BRAVO_REBEL
	minimap_type = /datum/action/minimap/marine/rebel

/obj/item/radio/headset/mainship/marine/rebel/bravo/LateInitialize(mapload)
	. = ..()
	camera.network += list("bravo_rebel")

/obj/item/radio/headset/mainship/marine/rebel/bravo/lead
	name = "marine bravo leader radio headset"
	keyslot2 = /obj/item/encryptionkey/squadlead/rebel
	use_command = TRUE
	command = TRUE


/obj/item/radio/headset/mainship/marine/rebel/bravo/engi
	name = "marine bravo engineer radio headset"
	keyslot2 = /obj/item/encryptionkey/engi/rebel


/obj/item/radio/headset/mainship/marine/rebel/bravo/med
	name = "marine bravo corpsman radio headset"
	keyslot2 = /obj/item/encryptionkey/med/rebel


/obj/item/radio/headset/mainship/marine/rebel/charlie
	name = "marine charlie radio headset"
	icon_state = "headset_marine_charlie"
	frequency = FREQ_CHARLIE_REBEL
	minimap_type = /datum/action/minimap/marine/rebel

/obj/item/radio/headset/mainship/marine/rebel/charlie/LateInitialize(mapload)
	. = ..()
	camera.network += list("charlie_rebel")

/obj/item/radio/headset/mainship/marine/rebel/charlie/lead
	name = "marine charlie leader radio headset"
	keyslot2 = /obj/item/encryptionkey/squadlead/rebel
	use_command = TRUE
	command = TRUE


/obj/item/radio/headset/mainship/marine/rebel/charlie/engi
	name = "marine charlie engineer radio headset"
	keyslot2 = /obj/item/encryptionkey/engi/rebel


/obj/item/radio/headset/mainship/marine/rebel/charlie/med
	name = "marine charlie corpsman radio headset"
	keyslot2 = /obj/item/encryptionkey/med/rebel



/obj/item/radio/headset/mainship/marine/rebel/delta
	name = "marine delta radio headset"
	icon_state = "headset_marine_delta"
	frequency = FREQ_DELTA_REBEL
	minimap_type = /datum/action/minimap/marine/rebel

/obj/item/radio/headset/mainship/marine/delta/LateInitialize(mapload)
	. = ..()
	camera.network += list("delta_rebel")


/obj/item/radio/headset/mainship/marine/rebel/delta/lead
	name = "marine delta leader radio headset"
	keyslot2 = /obj/item/encryptionkey/squadlead/rebel
	use_command = TRUE
	command = TRUE


/obj/item/radio/headset/mainship/marine/rebel/delta/engi
	name = "marine delta engineer radio headset"
	keyslot2 = /obj/item/encryptionkey/engi/rebel


/obj/item/radio/headset/mainship/marine/rebel/delta/med
	name = "marine delta corpsman radio headset"
	keyslot2 = /obj/item/encryptionkey/med/rebel

/obj/item/radio/headset/mainship/marine/rebel/generic
	name = "marine generic radio headset"
	icon_state = "headset_marine_generic"

/obj/item/radio/headset/mainship/marine/rebel/generic/cas
	name = "marine fire support specialist headset"
	icon_state = "sec_headset"
	keyslot2 = /obj/item/encryptionkey/cas/rebel

//Distress headsets.
/obj/item/radio/headset/distress
	name = "operative headset"
	freerange = TRUE
	frequency = FREQ_COMMON


/obj/item/radio/headset/distress/dutch
	name = "colonist headset"
	keyslot = /obj/item/encryptionkey/dutch
	frequency = FREQ_COLONIST


/obj/item/radio/headset/distress/PMC
	name = "contractor headset"
	keyslot = /obj/item/encryptionkey/PMC
	keyslot2 = /obj/item/encryptionkey/mcom
	frequency = FREQ_PMC


/obj/item/radio/headset/distress/usl
	name = "non-standard headset"
	keyslot = /obj/item/encryptionkey/usl
	frequency = FREQ_USL


/obj/item/radio/headset/distress/commando
	name = "commando headset"
	keyslot = /obj/item/encryptionkey/commando
	keyslot2 = /obj/item/encryptionkey/mcom
	frequency = FREQ_DEATHSQUAD


/obj/item/radio/headset/distress/imperial
	name = "imperial headset"
	keyslot = /obj/item/encryptionkey/imperial
	frequency = FREQ_IMP


/obj/item/radio/headset/distress/som
	name = "miners' headset"
	keyslot = /obj/item/encryptionkey/som
	frequency = FREQ_SOM


/obj/item/radio/headset/distress/sectoid
	name = "alien headset"
	keyslot = /obj/item/encryptionkey/sectoid
	frequency = FREQ_SECTOID


/obj/item/radio/headset/distress/echo
	name = "\improper Echo Task Force headset"
	keyslot = /obj/item/encryptionkey/echo

//SOM headsets

/obj/item/radio/headset/mainship/som
	frequency = FREQ_SOM
	keyslot = /obj/item/encryptionkey/general/som
	hud_type = DATA_HUD_SQUAD_SOM
	minimap_type = /datum/action/minimap/som

/obj/item/radio/headset/mainship/som/Initialize(mapload, datum/squad/squad, rank)
	if(!squad)
		return ..()
	icon_state = "headset_marine_[lowertext(squad.name)]"
	var/dat = "marine [lowertext(squad.name)]"
	frequency = squad.radio_freq
	if(ispath(rank, /datum/job/som/squad/leader))
		dat += " leader"
		keyslot2 = /obj/item/encryptionkey/squadlead/som
		use_command = TRUE
		command = TRUE
	else if(ispath(rank, /datum/job/som/squad/engineer))
		dat += " engineer"
		keyslot2 = /obj/item/encryptionkey/engi/som
	else if(ispath(rank, /datum/job/som/squad/medic))
		dat += " corpsman"
		keyslot2 = /obj/item/encryptionkey/med/som
	name = dat + " radio headset"
	return ..()


/obj/item/radio/headset/mainship/som/zulu
	name = "SOM zulu radio headset"
	icon_state = "headset_marine_zulu"
	frequency = FREQ_ZULU
	minimap_type = /datum/action/minimap/som

/obj/item/radio/headset/mainship/som/zulu/LateInitialize(mapload)
	. = ..()
	camera.network += list("zulu")

/obj/item/radio/headset/mainship/som/zulu/lead
	name = "SOM zulu leader radio headset"
	keyslot2 = /obj/item/encryptionkey/squadlead/som
	use_command = TRUE
	command = TRUE

/obj/item/radio/headset/mainship/som/zulu/engi
	name = "SOM zulu engineer radio headset"
	keyslot2 = /obj/item/encryptionkey/engi/som

/obj/item/radio/headset/mainship/som/zulu/med
	name = "SOM zulu corpsman radio headset"
	keyslot2 = /obj/item/encryptionkey/med/som

/obj/item/radio/headset/mainship/som/yankee
	name = "SOM yankee radio headset"
	icon_state = "headset_marine_yankee"
	frequency = FREQ_YANKEE
	minimap_type = /datum/action/minimap/som

/obj/item/radio/headset/mainship/som/yankee/LateInitialize(mapload)
	. = ..()
	camera.network += list("yankee")

/obj/item/radio/headset/mainship/som/yankee/lead
	name = "SOM yankee leader radio headset"
	keyslot2 = /obj/item/encryptionkey/squadlead/som
	use_command = TRUE
	command = TRUE

/obj/item/radio/headset/mainship/som/yankee/engi
	name = "SOM yankee engineer radio headset"
	keyslot2 = /obj/item/encryptionkey/engi/som

/obj/item/radio/headset/mainship/som/yankee/med
	name = "SOM yankee corpsman radio headset"
	keyslot2 = /obj/item/encryptionkey/med/som

/obj/item/radio/headset/mainship/som/xray
	name = "SOM xray radio headset"
	icon_state = "headset_marine_xray"
	frequency = FREQ_XRAY
	minimap_type = /datum/action/minimap/som

/obj/item/radio/headset/mainship/som/xray/LateInitialize(mapload)
	. = ..()
	camera.network += list("xray")

/obj/item/radio/headset/mainship/som/xray/lead
	name = "SOM xray leader radio headset"
	keyslot2 = /obj/item/encryptionkey/squadlead/som
	use_command = TRUE
	command = TRUE

/obj/item/radio/headset/mainship/som/xray/engi
	name = "SOM xray engineer radio headset"
	keyslot2 = /obj/item/encryptionkey/engi/som

/obj/item/radio/headset/mainship/som/xray/med
	name = "SOM xray corpsman radio headset"
	keyslot2 = /obj/item/encryptionkey/med/som

/obj/item/radio/headset/mainship/som/whiskey
	name = "SOM whiskey radio headset"
	icon_state = "headset_marine_whiskey"
	frequency = FREQ_WHISKEY
	minimap_type = /datum/action/minimap/som

/obj/item/radio/headset/mainship/som/whiskey/LateInitialize(mapload)
	. = ..()
	camera.network += list("whiskey")

/obj/item/radio/headset/mainship/som/whiskey/lead
	name = "SOM whiskey leader radio headset"
	keyslot2 = /obj/item/encryptionkey/squadlead/som
	use_command = TRUE
	command = TRUE

/obj/item/radio/headset/mainship/som/whiskey/engi
	name = "SOM whiskey engineer radio headset"
	keyslot2 = /obj/item/encryptionkey/engi/som

/obj/item/radio/headset/mainship/som/whiskey/med
	name = "SOM whiskey corpsman radio headset"
	keyslot2 = /obj/item/encryptionkey/med/som


//Imperium headsets

/obj/item/radio/headset/mainship/imp
	frequency = FREQ_IMP
	keyslot = /obj/item/encryptionkey/general/imp
	hud_type = DATA_HUD_SQUAD_IMP
	minimap_type = /datum/action/minimap/som

/obj/item/radio/headset/mainship/imp/Initialize(mapload, datum/squad/squad, rank)
	if(!squad)
		return ..()
	icon_state = "headset_marine_[lowertext(squad.name)]"
	var/dat = "guardsman [lowertext(squad.name)]"
	frequency = squad.radio_freq
	if(ispath(rank, /datum/job/imperial/squad/sergeant))
		dat += " sergeant"
		keyslot2 = /obj/item/encryptionkey/sergeant/imp
		use_command = TRUE
		command = TRUE
	else if(ispath(rank, /datum/job/imperial/squad/tech_priest))
		dat += " tech priest"
		keyslot2 = /obj/item/encryptionkey/engi/imp
	else if(ispath(rank, /datum/job/imperial/squad/skitarii))
		dat += " skitarii"
		keyslot2 = /obj/item/encryptionkey/engi/imp
	else if(ispath(rank, /datum/job/imperial/squad/medicae))
		dat += " medicae"
		keyslot2 = /obj/item/encryptionkey/med/imp
	name = dat + " radio headset"
	return ..()


/obj/item/radio/headset/mainship/imp/theta
	name = "Imperium theta radio headset"
	icon_state = "headset_marine_zulu"
	frequency = FREQ_THETA
	minimap_type = /datum/action/minimap/imp

/obj/item/radio/headset/mainship/imp/theta/LateInitialize(mapload)
	. = ..()
	camera.network += list("zulu")

/obj/item/radio/headset/mainship/imp/theta/lead
	name = "Imperium theta leader radio headset"
	keyslot2 = /obj/item/encryptionkey/sergeant/imp
	use_command = TRUE
	command = TRUE

/obj/item/radio/headset/mainship/imp/theta/engi
	name = "Imperium theta mechanicus radio headset"
	keyslot2 = /obj/item/encryptionkey/engi/imp

/obj/item/radio/headset/mainship/imp/theta/med
	name = "Imperium theta medicae radio headset"
	keyslot2 = /obj/item/encryptionkey/med/imp

/obj/item/radio/headset/mainship/imp/omega
	name = "Imperium omega radio headset"
	icon_state = "headset_marine_yankee"
	frequency = FREQ_OMEGA
	minimap_type = /datum/action/minimap/imp

/obj/item/radio/headset/mainship/imp/omega/LateInitialize(mapload)
	. = ..()
	camera.network += list("omega")

/obj/item/radio/headset/mainship/imp/omega/lead
	name = "Imperium omega leader radio headset"
	keyslot2 = /obj/item/encryptionkey/sergeant/imp
	use_command = TRUE
	command = TRUE

/obj/item/radio/headset/mainship/imp/omega/engi
	name = "Imperium omega mechanicus radio headset"
	keyslot2 = /obj/item/encryptionkey/engi/imp

/obj/item/radio/headset/mainship/imp/omega/med
	name = "Imperium omega medicae radio headset"
	keyslot2 = /obj/item/encryptionkey/med/imp

/obj/item/radio/headset/mainship/imp/gamma
	name = "Imperium gamma radio headset"
	icon_state = "headset_marine_yankee"
	frequency = FREQ_GAMMA
	minimap_type = /datum/action/minimap/imp

/obj/item/radio/headset/mainship/imp/gamma/LateInitialize(mapload)
	. = ..()
	camera.network += list("gamma")

/obj/item/radio/headset/mainship/imp/gamma/lead
	name = "Imperium gamma leader radio headset"
	keyslot2 = /obj/item/encryptionkey/sergeant/imp
	use_command = TRUE
	command = TRUE

/obj/item/radio/headset/mainship/imp/gamma/engi
	name = "Imperium gamma mechanicus radio headset"
	keyslot2 = /obj/item/encryptionkey/engi/imp

/obj/item/radio/headset/mainship/imp/gamma/med
	name = "Imperium gamma medicae radio headset"
	keyslot2 = /obj/item/encryptionkey/med/imp

/obj/item/radio/headset/mainship/imp/sigma
	name = "Imperium sigma radio headset"
	icon_state = "headset_marine_yankee"
	frequency = FREQ_SIGMA
	minimap_type = /datum/action/minimap/imp

/obj/item/radio/headset/mainship/imp/sigma/LateInitialize(mapload)
	. = ..()
	camera.network += list("sigma")

/obj/item/radio/headset/mainship/imp/sigma/lead
	name = "Imperium sigma leader radio headset"
	keyslot2 = /obj/item/encryptionkey/sergeant/imp
	use_command = TRUE
	command = TRUE

/obj/item/radio/headset/mainship/imp/sigma/engi
	name = "Imperium sigma mechanicus radio headset"
	keyslot2 = /obj/item/encryptionkey/engi/imp

/obj/item/radio/headset/mainship/imp/sigma/med
	name = "Imperium sigma medicae radio headset"
	keyslot2 = /obj/item/encryptionkey/med/imp
