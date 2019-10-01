// Used for translating channels to tokens on examination
GLOBAL_LIST_INIT(channel_tokens, list(
	RADIO_CHANNEL_REQUISITIONS = RADIO_TOKEN_REQUISITIONS,
	RADIO_CHANNEL_COMMAND = RADIO_TOKEN_COMMAND,
	RADIO_CHANNEL_MEDICAL = RADIO_TOKEN_MEDICAL,
	RADIO_CHANNEL_ENGINEERING = RADIO_TOKEN_ENGINEERING,
	RADIO_CHANNEL_POLICE = RADIO_TOKEN_POLICE,
	RADIO_CHANNEL_ALPHA = RADIO_TOKEN_ALPHA,
	RADIO_CHANNEL_BRAVO = RADIO_TOKEN_BRAVO,
	RADIO_CHANNEL_CHARLIE = RADIO_TOKEN_CHARLIE,
	RADIO_CHANNEL_DELTA = RADIO_TOKEN_DELTA
))


/obj/item/radio/headset
	name = "radio headset"
	desc = "An updated, modular intercom that fits over the head. Takes encryption keys"
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
			to_chat(user, "<span class='notice'>You pop out the encryption keys in the headset.</span>")

		else
			to_chat(user, "<span class='warning'>This headset doesn't have any unique encryption keys!  How useless...</span>")

	else if(istype(I, /obj/item/encryptionkey))
		if(keyslot && keyslot2)
			to_chat(user, "<span class='warning'>The headset can't hold another key!</span>")
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
		to_chat(user, "<span class='notice'>A small screen on the headset displays the following available frequencies:\n[english_list(avail_chans)].")

		if(command)
			to_chat(user, "<span class='info'>Alt-click to toggle the high-volume mode.</span>")
	else
		to_chat(user, "<span class='notice'>A small screen on the headset flashes, it's too small to read without holding or wearing the headset.</span>")


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
		to_chat(user, "<span class='notice'>You toggle high-volume mode [use_command ? "on" : "off"].</span>")


/obj/item/radio/headset/can_receive(freq, level)
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		if(H.wear_ear == src)
			return ..()
	else if(issilicon(loc))
		return ..()
	return FALSE


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
	var/obj/machinery/camera/camera
	var/datum/atom_hud/squadhud = null
	var/mob/living/carbon/human/wearer = null
	var/headset_hud_on = FALSE
	var/sl_direction = FALSE


/obj/item/radio/headset/mainship/Initialize()
	. = ..()
	camera = new /obj/machinery/camera/headset(src)


/obj/item/radio/headset/mainship/equipped(mob/living/carbon/human/user, slot)
	if(slot == SLOT_EARS)
		wearer = user
		squadhud = GLOB.huds[DATA_HUD_SQUAD]
		enable_squadhud()
	if(camera)
		camera.c_tag = user.name
	return ..()


/obj/item/radio/headset/mainship/dropped(mob/living/carbon/human/user)
	if(istype(user) && headset_hud_on)
		if(user.wear_ear == src) //dropped() is called before the inventory reference is update.
			disable_squadhud()
			squadhud.remove_hud_from(user)
			user.hud_used.SL_locator.alpha = 0
			wearer = null
			squadhud = null
	if(camera)
		camera.c_tag = "Unknown"
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
	if(wearer.mind && wearer.assigned_squad && !sl_direction)
		enable_sl_direction()
	to_chat(wearer, "<span class='notice'>You toggle the Squad HUD on.</span>")
	playsound(loc, 'sound/machines/click.ogg', 15, 0, 1)


/obj/item/radio/headset/mainship/proc/disable_squadhud()
	squadhud.remove_hud_from(wearer)
	headset_hud_on = FALSE
	if(sl_direction)
		disable_sl_direction()
	to_chat(wearer, "<span class='notice'>You toggle the Squad HUD off.</span>")
	playsound(loc, 'sound/machines/click.ogg', 15, 0, 1)


/obj/item/radio/headset/mainship/proc/enable_sl_direction()
	if(!headset_hud_on)
		to_chat(wearer, "<span class='warning'>You need to turn the HUD on first!</span>")
		return

	if(wearer.mind && wearer.assigned_squad && wearer.hud_used?.SL_locator)
		wearer.hud_used.SL_locator.alpha = 128
		if(wearer.assigned_squad.squad_leader == wearer)
			SSdirection.set_leader(wearer.assigned_squad.tracking_id, wearer)
			SSdirection.start_tracking("marine-sl", wearer)
		else
			SSdirection.start_tracking(wearer.assigned_squad.tracking_id, wearer)

	sl_direction = TRUE
	to_chat(wearer, "<span class='notice'>You toggle the SL directional display on.</span>")
	playsound(loc, 'sound/machines/click.ogg', 15, 0, 1)
	

/obj/item/radio/headset/mainship/proc/disable_sl_direction()
	if(wearer.mind && wearer.assigned_squad && wearer.hud_used?.SL_locator)
		wearer.hud_used.SL_locator.alpha = 0

	if(wearer?.assigned_squad?.squad_leader == wearer)
		SSdirection.clear_leader(wearer.assigned_squad.tracking_id)
		SSdirection.stop_tracking("marine-sl", wearer)
	else
		SSdirection.stop_tracking(wearer.assigned_squad.tracking_id, wearer)
	
	sl_direction = FALSE
	to_chat(wearer, "<span class='notice'>You toggle the SL directional display off.</span>")
	playsound(loc, 'sound/machines/click.ogg', 15, 0, 1)



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
	keyslot = /obj/item/encryptionkey/req
	keyslot2 = /obj/item/encryptionkey/engi

/obj/item/radio/headset/mainship/doc
	name = "medical radio headset"
	icon_state = "med_headset"
	keyslot = /obj/item/encryptionkey/med


/obj/item/radio/headset/mainship/ct
	name = "supply radio headset"
	icon_state = "cargo_headset"
	keyslot = /obj/item/encryptionkey/req


/obj/item/radio/headset/mainship/mmpo
	name = "marine master at arms radio headset"
	icon_state = "sec_headset"
	keyslot = /obj/item/encryptionkey/mmpo


/obj/item/radio/headset/mainship/cmpcom
	name = "marine command master at arms radio headset"
	icon_state = "sec_headset_alt"
	keyslot = /obj/item/encryptionkey/cmpcom
	use_command = TRUE
	command = TRUE


/obj/item/radio/headset/mainship/mcom
	name = "marine command radio headset"
	icon_state = "com_headset_alt"
	keyslot = /obj/item/encryptionkey/mcom
	use_command = TRUE
	command = TRUE


/obj/item/radio/headset/mainship/mcom/silicon
	name = "silicon radio"
	keyslot = /obj/item/encryptionkey/mcom/ai


/obj/item/radio/headset/mainship/marine
	keyslot = /obj/item/encryptionkey/general
	freerange = TRUE


/obj/item/radio/headset/mainship/marine/Initialize(mapload, squad, rank)
	if(squad)
		icon_state = "headset_marine_[lowertext(squad)]"
		var/dat = "marine [lowertext(squad)]"
		switch(squad)
			if("Alpha")
				frequency = FREQ_ALPHA
			if("Bravo")
				frequency = FREQ_BRAVO
			if("Charlie")
				frequency = FREQ_CHARLIE
			if("Delta")
				frequency = FREQ_DELTA
		switch(rank)
			if(SQUAD_LEADER)
				dat += " leader"
				keyslot2 = /obj/item/encryptionkey/squadlead
				use_command = TRUE
				command = TRUE
			if(SQUAD_ENGINEER)
				dat += " engineer"
				keyslot2 = /obj/item/encryptionkey/engi
			if(SQUAD_CORPSMAN)
				dat += " corpsman"
				keyslot2 = /obj/item/encryptionkey/med
		name = dat + " radio headset"
	return ..()


/obj/item/radio/headset/mainship/marine/alpha
	name = "marine alpha radio headset"
	icon_state = "headset_marine_alpha"
	frequency = FREQ_ALPHA //default frequency is alpha squad channel, not FREQ_COMMON


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


//Distress headsets.
/obj/item/radio/headset/distress
	name = "operative headset"
	frequency = FREQ_COMMON


/obj/item/radio/headset/distress/dutch
	name = "Dutch's Dozen headset"
	keyslot = /obj/item/encryptionkey/dutch


/obj/item/radio/headset/distress/PMC
	name = "PMC headset"
	keyslot = /obj/item/encryptionkey/PMC
	keyslot2 = /obj/item/encryptionkey/mcom


/obj/item/radio/headset/distress/wolves
	name = "Steel Wolves headset"
	frequency = FREQ_CIV_GENERAL
	keyslot = /obj/item/encryptionkey/wolves


/obj/item/radio/headset/distress/commando
	name = "Commando headset"
	keyslot = /obj/item/encryptionkey/commando
	keyslot2 = /obj/item/encryptionkey/mcom


/obj/item/radio/headset/distress/imperial
	name = "Imperial headset"
	keyslot = /obj/item/encryptionkey/imperial


/obj/item/radio/headset/distress/som
	name = "\improper Sons of Mars headset"
	keyslot = /obj/item/encryptionkey/som
