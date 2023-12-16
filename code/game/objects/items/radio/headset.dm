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
	item_icons = list(
		slot_l_hand_str = 'icons/mob/inhands/clothing/ears_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/clothing/ears_right.dmi',
	)
	item_state = "headset"
	subspace_transmission = TRUE
	canhear_range = 0 // can't hear headsets from very far away

	flags_equip_slot = ITEM_SLOT_EARS
	var/obj/item/encryptionkey/keyslot2 = null


/obj/item/radio/headset/Initialize(mapload)
	if(keyslot)
		keyslot = new keyslot(src)
	if(keyslot2)
		keyslot2 = new keyslot2(src)
	. = ..()
	possibly_deactivate_in_loc()

/obj/item/radio/headset/proc/possibly_deactivate_in_loc()
	if(ismob(loc))
		set_listening(should_be_listening)
	else
		set_listening(FALSE, actual_setting = FALSE)

/obj/item/radio/headset/Moved(atom/OldLoc, Dir)
	. = ..()
	possibly_deactivate_in_loc()

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
			balloon_alert_to_viewers("pops out keys")

		else
			balloon_alert(user, "No keys to remove")

	else if(istype(I, /obj/item/encryptionkey))
		if(keyslot && keyslot2)
			balloon_alert(user, "Can't, headset is full")
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
				LAZYSET(channels, ch_name, keyslot2.channels[ch_name])

	for(var/ch_name in channels)
		secure_radio_connections[ch_name] = add_radio(src, GLOB.radiochannels[ch_name])

	/// only headsets autoupdate squads cuz im lazy and dont want to redo this proc
	if(keyslot?.custom_squad_factions || keyslot2?.custom_squad_factions)
		for(var/key in GLOB.custom_squad_radio_freqs)
			var/datum/squad/custom_squad = GLOB.custom_squad_radio_freqs[key]
			if(!(keyslot.custom_squad_factions & ENCRYPT_CUSTOM_TERRAGOV) && !(keyslot.custom_squad_factions & ENCRYPT_CUSTOM_TERRAGOV) && custom_squad.faction == FACTION_TERRAGOV)
				continue
			if(!(keyslot.custom_squad_factions & ENCRYPT_CUSTOM_SOM) && !(keyslot.custom_squad_factions & ENCRYPT_CUSTOM_SOM) && custom_squad.faction == FACTION_SOM)
				continue
			channels[custom_squad.name] = TRUE
			secure_radio_connections[custom_squad.name] = add_radio(src, custom_squad.radio_freq)

/obj/item/radio/headset/AltClick(mob/living/user)
	if(!istype(user) || !Adjacent(user) || user.incapacitated())
		return

	if(command)
		use_command = !use_command
		balloon_alert(user, "toggles loud mode")

/obj/item/radio/headset/attack_self(mob/living/user)
	if(!istype(user) || !Adjacent(user) || user.incapacitated())
		return
	channels[RADIO_CHANNEL_REQUISITIONS] = !channels[RADIO_CHANNEL_REQUISITIONS]
	balloon_alert(user, "toggles supply comms [channels[RADIO_CHANNEL_REQUISITIONS] ? "on" : "off"].")

/obj/item/radio/headset/vendor_equip(mob/user)
	..()
	return user.equip_to_appropriate_slot(src)

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
	///The faction this headset belongs to. Used for hudtype, minimap and safety protocol
	var/faction = FACTION_TERRAGOV
	///The type of minimap this headset gives access to
	var/datum/action/minimap/minimap_type = /datum/action/minimap/marine

/obj/item/radio/headset/mainship/Initialize(mapload)
	. = ..()
	if(faction == FACTION_SOM)
		camera = new /obj/machinery/camera/headset/som(src)
	else
		camera = new /obj/machinery/camera/headset(src)

/obj/item/radio/headset/mainship/equipped(mob/living/carbon/human/user, slot)
	if(slot == SLOT_EARS)
		if(faction && (faction != user.faction) && user.faction != FACTION_NEUTRAL)
			safety_protocol(user)
			return
		wearer = user
		squadhud = GLOB.huds[GLOB.faction_to_data_hud[faction]]
		enable_squadhud()
		RegisterSignals(user, list(COMSIG_MOB_REVIVE, COMSIG_MOB_DEATH, COMSIG_HUMAN_SET_UNDEFIBBABLE), PROC_REF(update_minimap_icon))
	if(camera)
		camera.c_tag = user.name
		if(user.assigned_squad)
			camera.network |= lowertext(user.assigned_squad.name)
	possibly_deactivate_in_loc()
	return ..()

///Explodes the headset if you put on an enemy's headset
/obj/item/radio/headset/mainship/proc/safety_protocol(mob/living/carbon/human/user)
	balloon_alert_to_viewers("Explodes")
	playsound(user, 'sound/effects/explosion_micro1.ogg', 50, 1)
	if(wearer)
		wearer.ex_act(EXPLODE_LIGHT)
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
	balloon_alert(wearer, "toggles squad HUD on")
	playsound(loc, 'sound/machines/click.ogg', 15, 0, 1)


/obj/item/radio/headset/mainship/proc/disable_squadhud()
	squadhud.remove_hud_from(wearer)
	headset_hud_on = FALSE
	if(camera.status)
		camera.toggle_cam(null, FALSE)
	if(sl_direction)
		disable_sl_direction()
	remove_minimap()
	balloon_alert(wearer, "toggles squad HUD off")
	playsound(loc, 'sound/machines/click.ogg', 15, 0, 1)

/obj/item/radio/headset/mainship/proc/add_minimap()
	remove_minimap()
	var/datum/action/minimap/mini = new minimap_type
	mini.give_action(wearer)
	INVOKE_NEXT_TICK(src, PROC_REF(update_minimap_icon)) //Mobs are spawned inside nullspace sometimes so this is to avoid that hijinks

///Updates the wearer's minimap icon
/obj/item/radio/headset/mainship/proc/update_minimap_icon()
	SIGNAL_HANDLER
	SSminimaps.remove_marker(wearer)
	if(!wearer.job || !wearer.job.minimap_icon)
		return
	var/marker_flags = initial(minimap_type.marker_flags)
	if(wearer.stat == DEAD)
		if(HAS_TRAIT(wearer, TRAIT_UNDEFIBBABLE))
			SSminimaps.add_marker(wearer, marker_flags, image('icons/UI_icons/map_blips.dmi', null, "undefibbable"))
			return
		if(!wearer.client)
			var/mob/dead/observer/ghost = wearer.get_ghost()
			if(!ghost?.can_reenter_corpse)
				SSminimaps.add_marker(wearer, marker_flags, image('icons/UI_icons/map_blips.dmi', null, "undefibbable"))
				return
		SSminimaps.add_marker(wearer, marker_flags, image('icons/UI_icons/map_blips.dmi', null, "defibbable"))
		return
	if(wearer.assigned_squad)
		var/image/underlay = image('icons/UI_icons/map_blips.dmi', null, "squad_underlay")
		var/image/overlay = image('icons/UI_icons/map_blips.dmi', null, wearer.job.minimap_icon)
		overlay.color = wearer.assigned_squad.color
		underlay.overlays += overlay
		SSminimaps.add_marker(wearer, marker_flags, underlay)
		return
	SSminimaps.add_marker(wearer, marker_flags, image('icons/UI_icons/map_blips.dmi', null, wearer.job.minimap_icon))

///Remove all action of type minimap from the wearer, and make him disappear from the minimap
/obj/item/radio/headset/mainship/proc/remove_minimap()
	SSminimaps.remove_marker(wearer)
	for(var/datum/action/action AS in wearer.actions)
		if(istype(action, /datum/action/minimap))
			action.remove_action(wearer)

/obj/item/radio/headset/mainship/proc/enable_sl_direction()
	if(!headset_hud_on)
		balloon_alert(wearer, "turn it on first")
		return

	if(wearer.mind && wearer.assigned_squad && wearer.hud_used?.SL_locator)
		wearer.hud_used.SL_locator.alpha = 128
		if(wearer.assigned_squad.squad_leader == wearer)
			SSdirection.set_leader(wearer.assigned_squad.tracking_id, wearer)
			SSdirection.start_tracking(faction == FACTION_SOM ? TRACKING_ID_SOM_COMMANDER : TRACKING_ID_MARINE_COMMANDER, wearer)
		else
			SSdirection.start_tracking(wearer.assigned_squad.tracking_id, wearer)

	sl_direction = TRUE
	balloon_alert(wearer, "toggles SL finder on")
	playsound(loc, 'sound/machines/click.ogg', 15, 0, 1)


/obj/item/radio/headset/mainship/proc/disable_sl_direction()
	if(!wearer.assigned_squad)
		return

	if(wearer.mind && wearer.hud_used?.SL_locator)
		wearer.hud_used.SL_locator.alpha = 0

	if(wearer.assigned_squad.squad_leader == wearer)
		SSdirection.clear_leader(wearer.assigned_squad.tracking_id)
		SSdirection.stop_tracking(faction == FACTION_SOM ? TRACKING_ID_SOM_COMMANDER : TRACKING_ID_MARINE_COMMANDER, wearer)
	else
		SSdirection.stop_tracking(wearer.assigned_squad.tracking_id, wearer)

	sl_direction = FALSE
	balloon_alert(wearer, "toggles SL finder off")
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
	<b><A href='?src=[text_ref(src)];headset_hud_on=1'>Squad HUD: [headset_hud_on ? "On" : "Off"]</A></b><BR>
	<BR>
	<b><A href='?src=[text_ref(src)];sl_direction=1'>Squad Leader Directional Indicator: [sl_direction ? "On" : "Off"]</A></b><BR>
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

/obj/item/radio/headset/mainship/res
	name = "research radio headset"
	icon_state = "med_headset"
	keyslot = /obj/item/encryptionkey/med
	minimap_type = /datum/action/minimap/researcher

/obj/item/radio/headset/mainship/doc
	name = "medical radio headset"
	icon_state = "med_headset"
	keyslot = /obj/item/encryptionkey/med

/obj/item/radio/headset/mainship/ct
	name = "supply radio headset"
	icon_state = "cargo_headset"
	keyslot = /obj/item/encryptionkey/general

/obj/item/radio/headset/mainship/mcom
	name = "marine command radio headset"
	icon_state = "com_headset_alt"
	keyslot = /obj/item/encryptionkey/mcom
	use_command = TRUE
	command = TRUE

/obj/item/radio/headset/mainship/mcom/som
	frequency = FREQ_SOM
	keyslot = /obj/item/encryptionkey/mcom/som
	faction = FACTION_SOM
	minimap_type = /datum/action/minimap/som

/obj/item/radio/headset/mainship/mcom/silicon
	name = "silicon radio"
	keyslot = /obj/item/encryptionkey/mcom/ai

/obj/item/radio/headset/mainship/marine
	keyslot = /obj/item/encryptionkey/general

/obj/item/radio/headset/mainship/marine/Initialize(mapload, datum/squad/squad, rank)
	if(squad)
		icon_state = "headset_marine_[lowertext(squad.name)]"
		var/dat = "marine [lowertext(squad.name)]"
		frequency = squad.radio_freq
		if(ispath(rank, /datum/job/terragov/squad/leader))
			dat += " leader"
			keyslot2 = /obj/item/encryptionkey/squadlead
			use_command = TRUE
			command = TRUE
		else if(ispath(rank, /datum/job/terragov/squad/engineer))
			dat += " engineer"
			keyslot2 = /obj/item/encryptionkey/engi
		else if(ispath(rank, /datum/job/terragov/squad/corpsman))
			dat += " corpsman"
			keyslot2 = /obj/item/encryptionkey/med
		name = dat + " radio headset"
	return ..()

/obj/item/radio/headset/mainship/marine/alpha
	name = "marine alpha radio headset"
	icon_state = "headset_marine_alpha"
	frequency = FREQ_ALPHA //default frequency is alpha squad channel, not FREQ_COMMON
	minimap_type = /datum/action/minimap/marine

/obj/item/radio/headset/mainship/marine/alpha/LateInitialize()
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

/obj/item/radio/headset/mainship/marine/bravo/LateInitialize()
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

/obj/item/radio/headset/mainship/marine/charlie/LateInitialize()
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

/obj/item/radio/headset/mainship/marine/delta/LateInitialize()
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

//Distress headsets.
/obj/item/radio/headset/distress
	name = "operative headset"
	freerange = TRUE
	frequency = FREQ_COMMON


/obj/item/radio/headset/distress/dutch
	name = "colonist headset"
	keyslot = /obj/item/encryptionkey/dutch
	frequency = FREQ_COLONIST


/obj/item/radio/headset/distress/pmc
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
	frequency = FREQ_IMPERIAL


/obj/item/radio/headset/distress/som
	name = "miners' headset"
	keyslot = /obj/item/encryptionkey/som
	frequency = FREQ_SOM


/obj/item/radio/headset/distress/sectoid
	name = "alien headset"
	keyslot = /obj/item/encryptionkey/sectoid
	frequency = FREQ_SECTOID


/obj/item/radio/headset/distress/icc
	name = "shiphands headset"
	keyslot = /obj/item/encryptionkey/icc
	frequency = FREQ_ICC

/obj/item/radio/headset/distress/echo
	name = "\improper Echo Task Force headset"
	keyslot = /obj/item/encryptionkey/echo

//SOM headsets

/obj/item/radio/headset/mainship/som
	frequency = FREQ_SOM
	keyslot = /obj/item/encryptionkey/general/som
	faction = FACTION_SOM
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

/obj/item/radio/headset/mainship/som/command
	name = "SOM command radio headset"
	icon_state = "com_headset_alt"
	keyslot = /obj/item/encryptionkey/mcom/som
	use_command = TRUE
	command = TRUE

/obj/item/radio/headset/mainship/som/zulu
	name = "SOM zulu radio headset"
	icon_state = "headset_marine_zulu"
	frequency = FREQ_ZULU

/obj/item/radio/headset/mainship/som/zulu/LateInitialize()
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

/obj/item/radio/headset/mainship/som/yankee/LateInitialize()
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

/obj/item/radio/headset/mainship/som/xray/LateInitialize()
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

/obj/item/radio/headset/mainship/som/whiskey/LateInitialize()
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
