/obj/item/device/radio/headset
	name = "radio headset"
	desc = "An updated, modular intercom that fits over the head. Takes encryption keys"
	icon_state = "headset"
	item_state = "headset"
	matter = list("metal" = 75)
	subspace_transmission = 1
	canhear_range = 0 // can't hear headsets from very far away

	flags_equip_slot = ITEM_SLOT_EARS
	var/translate_binary = 0
	var/translate_hive = 0
	var/obj/item/device/encryptionkey/keyslot1 = null
	var/obj/item/device/encryptionkey/keyslot2 = null
	var/obj/item/device/encryptionkey/keyslot3 = null
	maxf = 1489

/obj/item/device/radio/headset/New()
	..()
	recalculateChannels()

/obj/item/device/radio/headset/handle_message_mode(mob/living/M as mob, message, channel)
	if (channel == "special")
		if (translate_binary)
			var/datum/language/binary = GLOB.all_languages["Robot Talk"]
			binary.broadcast(M, message)
		if (translate_hive)
			var/datum/language/hivemind = GLOB.all_languages["Hivemind"]
			hivemind.broadcast(M, message)
		return null

	return ..()

/obj/item/device/radio/headset/receive_range(freq, level, aiOverride = 0)
	if (aiOverride)
		return ..(freq, level)
	if(ishuman(src.loc))
		var/mob/living/carbon/human/H = src.loc
		if(H.wear_ear == src)
			return ..(freq, level)
	return -1

/obj/item/device/radio/headset/attackby(obj/item/W as obj, mob/user as mob)
//	..()
	user.set_interaction(src)
	if (!( isscrewdriver(W) || (istype(W, /obj/item/device/encryptionkey/ ))))
		return

	if(isscrewdriver(W))
		if(keyslot1 || keyslot2 || keyslot3)


			for(var/ch_name in channels)
				radio_controller.remove_object(src, radiochannels[ch_name])
				secure_radio_connections[ch_name] = null


			if(keyslot1)
				var/turf/T = get_turf(user)
				if(T)
					keyslot1.loc = T
					keyslot1 = null



			if(keyslot2)
				var/turf/T = get_turf(user)
				if(T)
					keyslot2.loc = T
					keyslot2 = null

			if(keyslot3)
				var/turf/T = get_turf(user)
				if(T)
					keyslot3.loc = T
					keyslot3 = null

			recalculateChannels()
			to_chat(user, "You pop out the encryption keys in the headset!")

		else
			to_chat(user, "This headset doesn't have any encryption keys!  How useless...")

	if(istype(W, /obj/item/device/encryptionkey/))
		if(keyslot1 && keyslot2 && keyslot3)
			to_chat(user, "The headset can't hold another key!")
			return

		if(!keyslot1)
			if(user.drop_held_item())
				W.forceMove(src)
				keyslot1 = W


		if(!keyslot2)
			if(user.drop_held_item())
				W.forceMove(src)
				keyslot2 = W
		else
			if(user.drop_held_item())
				W.forceMove(src)
				keyslot3 = W


		recalculateChannels()

	return


/obj/item/device/radio/headset/proc/recalculateChannels()
	src.channels = list()
	src.translate_binary = 0
	src.translate_hive = 0
	src.syndie = 0

	if(keyslot1)
		for(var/ch_name in keyslot1.channels)
			if(ch_name in src.channels)
				continue
			src.channels += ch_name
			src.channels[ch_name] = keyslot1.channels[ch_name]

		if(keyslot1.translate_binary)
			src.translate_binary = 1

		if(keyslot1.translate_hive)
			src.translate_hive = 1

		if(keyslot1.syndie)
			src.syndie = 1

	if(keyslot2)
		for(var/ch_name in keyslot2.channels)
			if(ch_name in src.channels)
				continue
			src.channels += ch_name
			src.channels[ch_name] = keyslot2.channels[ch_name]

		if(keyslot2.translate_binary)
			src.translate_binary = 1

		if(keyslot2.translate_hive)
			src.translate_hive = 1

		if(keyslot2.syndie)
			src.syndie = 1

	if(keyslot3)
		for(var/ch_name in keyslot3.channels)
			if(ch_name in src.channels)
				continue
			src.channels += ch_name
			src.channels[ch_name] = keyslot3.channels[ch_name]

		if(keyslot3.translate_binary)
			src.translate_binary = 1

		if(keyslot3.translate_hive)
			src.translate_hive = 1

		if(keyslot3.syndie)
			src.syndie = 1


	for (var/ch_name in channels)
		if(!radio_controller)
			sleep(30) // Waiting for the radio_controller to be created.
		if(!radio_controller)
			src.name = "broken radio headset"
			return

		secure_radio_connections[ch_name] = radio_controller.add_object(src, radiochannels[ch_name],  RADIO_CHAT)




/obj/item/device/radio/headset/syndicate
	origin_tech = "syndicate=3"
	keyslot1 = new /obj/item/device/encryptionkey/syndicate


/obj/item/device/radio/headset/binary
	origin_tech = "syndicate=3"
	keyslot1 = new /obj/item/device/encryptionkey/binary



/obj/item/device/radio/headset/ai_integrated //No need to care about icons, it should be hidden inside the AI anyway.
	name = "AI Subspace Transceiver"
	desc = "Integrated AI radio transceiver."
	icon = 'icons/obj/robot_component.dmi'
	icon_state = "radio"
	item_state = "headset"
	keyslot1 = new /obj/item/device/encryptionkey/ai_integrated
	var/myAi = null    // Atlantis: Reference back to the AI which has this radio.
	var/disabledAi = 0 // Atlantis: Used to manually disable AI's integrated radio via intellicard menu.

/obj/item/device/radio/headset/ai_integrated/receive_range(freq, level)
	if (disabledAi)
		return -1 //Transciever Disabled.
	return ..(freq, level, 1)

/obj/item/device/radio/headset/ert
	name = "NT Response Team headset"
	desc = "The headset of the boss's boss. Channels are as follows: :h - Response Team :c - command, :p - security, :e - engineering, :m - medical."
	icon_state = "com_headset"
	item_state = "headset"
	freerange = 1
	keyslot1 = new /obj/item/device/encryptionkey/ert




//MARINE HEADSETS

/obj/item/device/radio/headset/almayer
	name = "marine radio headset"
	desc = "A standard military radio headset."
	icon_state = "cargo_headset"
	item_state = "headset"
	frequency = PUB_FREQ
	var/obj/machinery/camera/camera
	var/datum/mob_hud/squadhud = null
	var/mob/living/carbon/human/wearer = null
	var/headset_hud_on = FALSE
	var/sl_direction = FALSE

/obj/item/device/radio/headset/almayer/New()
	. = ..()
	camera = new /obj/machinery/camera(src)
	camera.network = list("LEADER")

/obj/item/device/radio/headset/almayer/equipped(mob/living/carbon/human/user, slot)
	if(slot == SLOT_EARS)
		wearer = user
		squadhud = huds[MOB_HUD_SQUAD]
		headset_hud_on = FALSE //So we always activate on equip.
		sl_direction = FALSE
		toggle_squadhud(wearer)
	if(camera)
		camera.c_tag = user.name
	return ..()

/obj/item/device/radio/headset/almayer/dropped(mob/living/carbon/human/user)
	if(istype(user) && headset_hud_on)
		if(user.wear_ear == src) //dropped() is called before the inventory reference is update.
			squadhud.remove_hud_from(user)
			user.hud_used.SL_locator.alpha = 0
			wearer = null
			squadhud = null
	if(camera)
		camera.c_tag = "Unknown"
	return ..()


/obj/item/device/radio/headset/almayer/Destroy()
	if(wearer && headset_hud_on)
		if(wearer.wear_ear == src)
			squadhud.remove_hud_from(wearer)
			wearer.SL_directional = null
			if(wearer.assigned_squad)
				SSdirection.stop_tracking(wearer.assigned_squad.tracking_id, wearer)
			wearer = null
	squadhud = null
	headset_hud_on = FALSE
	sl_direction = null
	return ..()


/obj/item/device/radio/headset/almayer/proc/toggle_squadhud(mob/living/carbon/human/user)
	if(headset_hud_on)
		squadhud.remove_hud_from(user)
		if(sl_direction)
			toggle_sl_direction(user)
		to_chat(user, "<span class='notice'>You toggle the Squad HUD off.</span>")
		playsound(src.loc, 'sound/machines/click.ogg', 15, 0, 1)
		headset_hud_on = FALSE
	else
		squadhud.add_hud_to(user)
		headset_hud_on = TRUE
		if(user.mind && user.assigned_squad)
			if(!sl_direction)
				toggle_sl_direction(user)
		to_chat(user, "<span class='notice'>You toggle the Squad HUD on.</span>")
		playsound(loc, 'sound/machines/click.ogg', 15, 0, 1)

/obj/item/device/radio/headset/almayer/proc/toggle_sl_direction(mob/living/carbon/human/user)
	if(!headset_hud_on)
		to_chat(user, "<span class='warning'>You need to turn the HUD on first!</span>")
		return

	if(sl_direction)
		if(user.mind && user.assigned_squad && user.hud_used?.SL_locator)
			user.hud_used.SL_locator.alpha = 0
			SSdirection.stop_tracking(user.assigned_squad.tracking_id, user)
		sl_direction = FALSE
		to_chat(user, "<span class='notice'>You toggle the SL directional display off.</span>")
		playsound(src.loc, 'sound/machines/click.ogg', 15, 0, 1)
	else
		if(user.mind && user.assigned_squad && user.hud_used?.SL_locator)
			user.hud_used.SL_locator.alpha = 128
			SSdirection.start_tracking(user.assigned_squad.tracking_id, user)
		sl_direction = TRUE
		to_chat(user, "<span class='notice'>You toggle the SL directional display on.</span>")
		playsound(src.loc, 'sound/machines/click.ogg', 15, 0, 1)


/obj/item/device/radio/headset/almayer/verb/configure_squadhud()
	set name = "Configure Headset HUD"
	set category = "Object"
	set src in usr

	if(usr.incapacitated() || usr != wearer || !ishuman(usr))
		return FALSE

	handle_interface(usr)

/obj/item/device/radio/headset/almayer/proc/handle_interface(mob/living/carbon/human/user, flag1)
	user.set_interaction(src)
	var/dat = {"<TT>
	<b><A href='?src=\ref[src];headset_hud_on=1'>Squad HUD: [headset_hud_on ? "On" : "Off"]</A></b><BR>
	<BR>
	<b><A href='?src=\ref[src];sl_direction=1'>Squad Leader Directional Indicator: [sl_direction ? "On" : "Off"]</A></b><BR>
	<BR>
	</TT>"}
	user << browse(dat, "window=radio")
	onclose(user, "radio")
	return

/obj/item/device/radio/headset/almayer/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if(usr.incapacitated() || usr != wearer || !ishuman(usr))
		return
	if(usr.contents.Find(src) )
		usr.set_interaction(src)
		var/mob/living/carbon/human/user = usr
		if(href_list["headset_hud_on"])
			toggle_squadhud(user)

		else if(href_list["sl_direction"])
			toggle_sl_direction(user)

		if(!master)
			if(ishuman(loc))
				handle_interface(loc)
		else
			if(ishuman(master.loc))
				handle_interface(master.loc)
	else
		usr << browse(null, "window=radio")


/obj/item/device/radio/headset/almayer/ce
	name = "chief ship engineer's headset"
	desc = "The headset of the guy who is in charge of morons. To access the engineering channel, use :e. For command, use :v."
	icon_state = "com_headset"
	keyslot1 = new /obj/item/device/encryptionkey/ce

/obj/item/device/radio/headset/almayer/cmo
	name = "chief medical officer's headset"
	desc = "The headset of the highly trained medical chief. To access the medical channel, use :m. For command, use :v."
	icon_state = "com_headset"
	keyslot1 = new /obj/item/device/encryptionkey/cmo

/obj/item/device/radio/headset/almayer/mt
	name = "engineering radio headset"
	desc = "When the engineers wish to chat like girls. To access the engineering channel, use :e. "
	icon_state = "eng_headset"
	keyslot1 = new /obj/item/device/encryptionkey/engi

/obj/item/device/radio/headset/almayer/doc
	name = "medical radio headset"
	desc = "A headset for the trained staff of the medbay. To access the medical channel, use :m."
	icon_state = "med_headset"
	keyslot1 = new /obj/item/device/encryptionkey/med

/obj/item/device/radio/headset/almayer/ct
	name = "supply radio headset"
	desc = "A headset used by the RO and his slave(s). To access the supply channel, use :u."
	icon_state = "cargo_headset"
	keyslot1 = new /obj/item/device/encryptionkey/req


/obj/item/device/radio/headset/almayer/cmpcom
	name = "marine Command Master at Arms radio headset"
	desc = "This is used by the Command Master at Arms. Channels are as follows: :v - marine command, :p - military police, :q - alpha squad, :b - bravo squad, :c - charlie squad, :d - delta squad, :m - medbay, :u - requisitions"
	icon_state = "med_headset"
	keyslot1 = new /obj/item/device/encryptionkey/cmpcom

/obj/item/device/radio/headset/almayer/mcom
	name = "marine command radio headset"
	desc = "This is used by the marine command. Channels are as follows: :v - marine command, :q - alpha squad, :b - bravo squad, :c - charlie squad, :d - delta squad, :m - medbay, :u - requisitions"
	icon_state = "med_headset"
	keyslot1 = new /obj/item/device/encryptionkey/mcom


/obj/item/device/radio/headset/almayer/mcom/ai
	keyslot1 = new /obj/item/device/encryptionkey/mcom/ai



/obj/item/device/radio/headset/almayer/marine
	keyslot3 = new /obj/item/device/encryptionkey/general

/obj/item/device/radio/headset/almayer/marine/alpha
	name = "marine alpha radio headset"
	desc = "This is used by alpha squad members. Channels are as follows: ; - Alpha squad :z - general chat."
	icon_state = "sec_headset"
	frequency = ALPHA_FREQ //default frequency is alpha squad channel, not PUB_FREQ

/obj/item/device/radio/headset/almayer/marine/alpha/lead
	name = "marine alpha leader radio headset"
	desc = "This is used by the marine alpha squad leader. Channels are as follows: ; - Alpha squad :v - marine command, :z - general chat."
	keyslot2 = new /obj/item/device/encryptionkey/squadlead

/obj/item/device/radio/headset/almayer/marine/alpha/engi
	name = "marine alpha engineer radio headset"
	desc = "This is used by the marine alpha combat engineers. Channels are as follows: ; - Alpha squad :e - engineering, :z - general chat."
	keyslot2 = new /obj/item/device/encryptionkey/engi

/obj/item/device/radio/headset/almayer/marine/alpha/med
	name = "marine alpha corpsman radio headset"
	desc = "This is used by the marine alpha combat corpsmen. Channels are as follows: ; - Alpha Squad :m - medical, :z - general chat."
	keyslot2 = new /obj/item/device/encryptionkey/med



/obj/item/device/radio/headset/almayer/marine/bravo
	name = "marine bravo radio headset"
	desc = "This is used by bravo squad members. Channels are as follows: ; - Bravo Squad :z - general chat."
	icon_state = "eng_headset"
	frequency = BRAVO_FREQ

/obj/item/device/radio/headset/almayer/marine/bravo/lead
	name = "marine bravo leader radio headset"
	desc = "This is used by the marine bravo squad leader. Channels are as follows: ; - Bravo Squad :v - marine command, :z - general chat."
	keyslot2 = new /obj/item/device/encryptionkey/squadlead

/obj/item/device/radio/headset/almayer/marine/bravo/engi
	name = "marine bravo engineer radio headset"
	desc = "This is used by the marine bravo combat engineers. Channels are as follows: ; - Bravo Squad :e - engineering, :z - general chat."
	keyslot2 = new /obj/item/device/encryptionkey/engi

/obj/item/device/radio/headset/almayer/marine/bravo/med
	name = "marine bravo corpsman radio headset"
	desc = "This is used by the marine bravo combat corpsmen. Channels are as follows: ; - Bravo Squad :m - medical, :z - general chat."
	keyslot2 = new /obj/item/device/encryptionkey/med



/obj/item/device/radio/headset/almayer/marine/charlie
	name = "marine charlie radio headset"
	desc = "This is used by charlie squad members. Channels are as follows: ; - Charlie Squad :z - general chat."
	icon_state = "charlie_headset"
	frequency = CHARLIE_FREQ

/obj/item/device/radio/headset/almayer/marine/charlie/lead
	name = "marine charlie leader radio headset"
	desc = "This is used by the marine charlie squad leader. Channels are as follows: ; - Charlie Squad :v - marine command, :z - general chat."
	keyslot2 = new /obj/item/device/encryptionkey/squadlead

/obj/item/device/radio/headset/almayer/marine/charlie/engi
	name = "marine charlie engineer radio headset"
	desc = "This is used by the marine charlie combat engineers. Channels are as follows: ; - Charlie Squad :e - engineering, :z - general chat."
	keyslot2 = new /obj/item/device/encryptionkey/engi

/obj/item/device/radio/headset/almayer/marine/charlie/med
	name = "marine charlie corpsman radio headset"
	desc = "This is used by the marine charlie combat corpsmen. Channels are as follows: ; - Charlie Squad :m - medical, :z - general chat."
	keyslot2 = new /obj/item/device/encryptionkey/med



/obj/item/device/radio/headset/almayer/marine/delta
	name = "marine delta radio headset"
	desc = "This is used by delta squad members. Channels are as follows: ; - Delta Squad :z - general chat."
	icon_state = "com_headset"
	frequency = DELTA_FREQ

/obj/item/device/radio/headset/almayer/marine/delta/lead
	name = "marine delta leader radio headset"
	desc = "This is used by the marine delta squad leader. Channels are as follows: ; - Delta Squad :v - marine command, :z - general chat."
	keyslot2 = new /obj/item/device/encryptionkey/squadlead

/obj/item/device/radio/headset/almayer/marine/delta/engi
	name = "marine delta engineer radio headset"
	desc = "This is used by the marine delta combat engineers. Channels are as follows: ; - Delta Squad :e - engineering, :z - general chat."
	keyslot2 = new /obj/item/device/encryptionkey/engi

/obj/item/device/radio/headset/almayer/marine/delta/med
	name = "marine delta corpsman radio headset"
	desc = "This is used by the marine delta combat corpsmen. Channels are as follows: ; - Delta Squad :m - medical, :z - general chat."
	keyslot2 = new /obj/item/device/encryptionkey/med



/obj/item/device/radio/headset/almayer/mmpo
	name = "marine military police radio headset"
	desc = "This is used by marine military police members. Channels are as follows: :p - military police."
	icon_state = "cargo_headset"
	keyslot1 = new /obj/item/device/encryptionkey/mmpo





//Distress headsets.

/obj/item/device/radio/headset/distress
	name = "operative headset"
	desc = "A special headset used by small groups of trained operatives. Use :h to talk on a private channel."
	frequency = PUB_FREQ

/obj/item/device/radio/headset/distress/dutch
	name = "Dutch's Dozen headset"
	keyslot1 = new /obj/item/device/encryptionkey/dutch


/obj/item/device/radio/headset/distress/PMC
	name = "PMC headset"
	keyslot1 = new /obj/item/device/encryptionkey/PMC
	keyslot2 = new /obj/item/device/encryptionkey/mcom


/obj/item/device/radio/headset/distress/bears
	name = "Iron Bear headset"
	frequency = CIV_GEN_FREQ
	keyslot1 = new /obj/item/device/encryptionkey/bears

/obj/item/device/radio/headset/distress/commando
	name = "Commando headset"
	keyslot1 = new /obj/item/device/encryptionkey/commando
	keyslot2 = new /obj/item/device/encryptionkey/mcom

/obj/item/device/radio/headset/distress/imperial
	name = "Imperial headset"
	desc = "A headset used by Imperial soldiers. Use :h to talk on a private channel."
	keyslot1 = new /obj/item/device/encryptionkey/imperial
	//frequency = IMP_FREQ
	//freerange = TRUE - this only allows MAIN freq not to fuck up
