/client/verb/toggle_statistics()
	set category = "Preferences"
	set name = "Toggle Statistics"

	prefs.toggles_chat ^= CHAT_STATISTICS
	prefs.save_preferences()

	to_chat(src, "<span class='notice'>At the end of the round you will [(prefs.toggles_chat & CHAT_STATISTICS) ? "see all statistics" : "not see any statistics"].</span>")


/client/verb/toggle_ghost_ears()
	set category = "Preferences"
	set name = "Toggle Ghost Ears"

	prefs.toggles_chat ^= CHAT_GHOSTEARS
	prefs.save_preferences()

	to_chat(src, "<span class='notice'>As a ghost, you will now [(prefs.toggles_chat & CHAT_GHOSTEARS) ? "see all speech in the world" : "only see speech from nearby mobs"].</span>")


/client/verb/toggle_ghost_sight()
	set category = "Preferences"
	set name = "Toggle Ghost Sight"

	prefs.toggles_chat ^= CHAT_GHOSTSIGHT
	prefs.save_preferences()

	to_chat(src, "<span class='notice'>As a ghost, you will now [(prefs.toggles_chat & CHAT_GHOSTSIGHT) ? "see all emotes in the world" : "only see emotes from nearby mobs"].</span>")


/client/verb/toggle_ghost_radio()
	set category = "Preferences"
	set name = "Toggle Ghost Radio"

	prefs.toggles_chat ^= CHAT_GHOSTRADIO
	prefs.save_preferences()

	to_chat(src, "<span class='notice'>As a ghost, you will now [(prefs.toggles_chat & CHAT_GHOSTRADIO) ? "hear all radio chat in the world" : "only hear from nearby speakers"].</span>")


/client/proc/toggle_ghost_speaker()
	set category = "Preferences"
	set name = "Toggle Speakers"

	prefs.toggles_chat ^= CHAT_RADIO
	prefs.save_preferences()

	to_chat(usr, "<span class='notice'>You will [(prefs.toggles_chat & CHAT_RADIO) ? "now" : "no longer"] see radio chatter from radios or speakers.</span>")


/client/verb/toggle_ghost_hivemind()
	set category = "Preferences"
	set name = "Toggle Ghost Hivemind"

	prefs.toggles_chat ^= CHAT_GHOSTHIVEMIND
	prefs.save_preferences()

	to_chat(src, "<span class='notice'>As a ghost, you will [(prefs.toggles_chat & CHAT_GHOSTHIVEMIND) ? "now see chatter from the Xenomorph Hivemind" : "no longer see chatter from the Xenomorph Hivemind"].</span>")


/client/verb/toggle_deadchat_self()
	set category = "Preferences"
	set name = "Toggle  Deadchat"

	prefs.toggles_chat ^= CHAT_DEAD
	prefs.save_preferences()

	to_chat(src, "<span class='notice'>You will [(prefs.toggles_chat & CHAT_DEAD) ? "now" : "no longer"] see deadchat.</span>")


/client/verb/toggle_lobby_music()
	set category = "Preferences"
	set name = "Toggle Lobby Music"

	prefs.toggles_sound ^= SOUND_LOBBY
	prefs.save_preferences()

	if(prefs.toggles_sound & SOUND_LOBBY)
		to_chat(src, "<span class='notice'>You will now hear music in the game lobby.</span>")
		if(!isnewplayer(mob))
			return
		playtitlemusic()
	else
		to_chat(src, "<span class='notice'>You will no longer hear music in the game lobby.</span>")
		if(!isnewplayer(mob))
			return
		src << sound(null, repeat = 0, wait = 0, volume = 85, channel = 1)


/client/verb/toggle_ooc_self()
	set category = "Preferences"
	set name = "Toggle  OOC"

	prefs.toggles_chat ^= CHAT_OOC
	prefs.save_preferences()

	to_chat(src, "<span class='notice'>You will [(prefs.toggles_chat & CHAT_OOC) ? "now" : "no longer"] see messages on the OOC channel.</span>")


/client/verb/toggle_looc_self()
	set category = "Preferences"
	set name = "Toggle  LOOC"

	prefs.toggles_chat ^= CHAT_LOOC
	prefs.save_preferences()

	to_chat(src, "<span class='notice'>You will [(prefs.toggles_chat & CHAT_LOOC) ? "now" : "no longer"] see messages on the LOOC channel.</span>")


/client/verb/toggle_ambience()
	set category = "Preferences"
	set name = "Toggle Ambience"

	prefs.toggles_sound ^= SOUND_AMBIENCE
	prefs.save_preferences()

	if(prefs.toggles_sound & SOUND_AMBIENCE)
		to_chat(src, "<span class='notice'>You will now hear ambient sounds.</span>")
	else
		to_chat(src, "<span class='notice'>You will no longer hear ambient sounds.</span>")
		src << sound(null, repeat = 0, wait = 0, volume = 0, channel = 1)
		src << sound(null, repeat = 0, wait = 0, volume = 0, channel = 2)


/client/verb/toggle_special(role in BE_SPECIAL_FLAGS)
	set category = "Preferences"
	set name = "Toggle Special Roles"

	var/role_flag = BE_SPECIAL_FLAGS[role]
	if(!role_flag)	
		return
	prefs.be_special ^= role_flag
	prefs.save_character()

	to_chat(src, "<span class='notice'>You will [(prefs.be_special & role_flag) ? "now" : "no longer"] be considered for [role] events (where possible).</span>")


/client/verb/preferred_slot()
	set category = "Preferences"
	set name = "Set Preferred Slot"

	var/slot = input("Which slot would you like to draw/equip from?", "Preferred Slot") as null|anything in list("Suit Storage", "Suit Inside", "Belt", "Back", "Boot", "Helmet", "Left Pocket", "Right Pocket", "Webbing", "Belt", "Belt Holster", "Suit Storage Holster", "Back Holster")
	switch(slot)
		if("Suit Storage")
			prefs.preferred_slot = SLOT_S_STORE
		if("Suit Inside")
			prefs.preferred_slot = SLOT_WEAR_SUIT
		if("Belt")
			prefs.preferred_slot = SLOT_BELT
		if("Back")
			prefs.preferred_slot = SLOT_BACK
		if("Boot")
			prefs.preferred_slot = SLOT_IN_BOOT
		if("Helmet")
			prefs.preferred_slot = SLOT_IN_HEAD
		if("Left Pocket")
			prefs.preferred_slot = SLOT_L_STORE
		if("Right Pocket")
			prefs.preferred_slot = SLOT_R_STORE
		if("Webbing")
			prefs.preferred_slot = SLOT_IN_ACCESSORY
		if("Belt")
			prefs.preferred_slot = SLOT_IN_BELT
		if("Belt Holster")
			prefs.preferred_slot = SLOT_IN_HOLSTER
		if("Suit Storage Holster")
			prefs.preferred_slot = SLOT_IN_S_HOLSTER
		if("Back Holster")
			prefs.preferred_slot = SLOT_IN_B_HOLSTER

	prefs.save_character()

	to_chat(src, "<span class='notice'>You will now equip/draw from the [slot] slot first.</span>")


/client/verb/typing_indicator()
	set category = "Preferences"
	set name = "Toggle Typing Indicator"
	set desc = "Toggles showing an indicator when you are typing emote or say message."

	prefs.show_typing = !prefs.show_typing
	prefs.save_preferences()

	//Clear out any existing typing indicator.
	if(!prefs.show_typing && istype(mob))
		mob.toggle_typing_indicator()

	to_chat(src, "<span class='notice'>You will [prefs.show_typing ? "now" : "no longer"] display a typing indicator.</span>")


/client/verb/setup_character()
	set category = "Preferences"
	set name = "Game Preferences"
	set desc = "Allows you to access the Setup Character screen. Changes to your character won't take effect until next round, but other changes will."
	prefs.ShowChoices(usr)

