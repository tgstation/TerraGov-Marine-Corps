/client/verb/toggle_statistics()
	set category = "Preferences"
	set name = "Toggle Statistics"

	prefs.toggles_chat ^= CHAT_STATISTICS
	prefs.save_preferences()

	to_chat(src, span_notice("At the end of the round you will [(prefs.toggles_chat & CHAT_STATISTICS) ? "see all statistics" : "not see any statistics"]."))


/client/verb/toggle_ghost_ears()
	set category = "Preferences"
	set name = "Toggle Ghost Ears"

	prefs.toggles_chat ^= CHAT_GHOSTEARS
	prefs.save_preferences()

	to_chat(src, span_notice("As a ghost, you will now [(prefs.toggles_chat & CHAT_GHOSTEARS) ? "see all speech in the world" : "only see speech from nearby mobs"]."))

/client/verb/middle_mousetoggle()
	set name = "Toggle Middle/Shift Clicking"
	set category = "Preferences"

	prefs.toggles_gameplay ^= MIDDLESHIFTCLICKING
	prefs.save_preferences()

	to_chat(src, span_notice("The selected special ability will now be activated with [(prefs.toggles_gameplay & MIDDLESHIFTCLICKING) ? "middle button" : "shift"] clicking."))

	prefs.save_preferences()


/client/verb/toggle_ghost_sight()
	set category = "Preferences"
	set name = "Toggle Ghost Sight"

	prefs.toggles_chat ^= CHAT_GHOSTSIGHT
	prefs.save_preferences()

	to_chat(src, span_notice("As a ghost, you will now [(prefs.toggles_chat & CHAT_GHOSTSIGHT) ? "see all emotes in the world" : "only see emotes from nearby mobs"]."))


/client/verb/toggle_ghost_radio()
	set category = "Preferences"
	set name = "Toggle Ghost Radio"

	prefs.toggles_chat ^= CHAT_GHOSTRADIO
	prefs.save_preferences()

	to_chat(src, span_notice("As a ghost, you will now [(prefs.toggles_chat & CHAT_GHOSTRADIO) ? "hear all radio chat in the world" : "only hear from nearby speakers"]."))


/client/proc/toggle_ghost_speaker()
	set category = "Preferences"
	set name = "Toggle Speakers"

	prefs.toggles_chat ^= CHAT_RADIO
	prefs.save_preferences()

	to_chat(usr, span_notice("You will [(prefs.toggles_chat & CHAT_RADIO) ? "now" : "no longer"] see radio chatter from radios or speakers."))


/client/verb/toggle_ghost_hivemind()
	set category = "Preferences"
	set name = "Toggle Ghost Hivemind"

	prefs.toggles_chat ^= CHAT_GHOSTHIVEMIND
	prefs.save_preferences()

	to_chat(src, span_notice("As a ghost, you will [(prefs.toggles_chat & CHAT_GHOSTHIVEMIND) ? "now see chatter from the Xenomorph Hivemind" : "no longer see chatter from the Xenomorph Hivemind"]."))


/client/verb/toggle_deadchat_self()
	set category = "Preferences"
	set name = "Toggle  Deadchat"

	prefs.toggles_chat ^= CHAT_DEAD
	prefs.save_preferences()

	to_chat(src, span_notice("You will [(prefs.toggles_chat & CHAT_DEAD) ? "now" : "no longer"] see deadchat."))


/client/verb/toggle_admin_music()
	set category = "Preferences"
	set name = "Toggle Admin Music"

	prefs.toggles_sound ^= SOUND_MIDI
	prefs.save_preferences()

	to_chat(src, span_notice("You will [(prefs.toggles_sound & SOUND_MIDI) ? "now" : "no longer"] hear admin music."))

/client/verb/toggle_radial_medical()
	set category = "Preferences"
	set name = "Toggle Radial Medical Wheel"

	prefs.toggles_gameplay ^= RADIAL_MEDICAL
	prefs.save_preferences()

	to_chat(src, span_notice("You will [(prefs.toggles_gameplay & RADIAL_MEDICAL) ? "now" : "no longer"] use the radial menu for medical purposes."))

/client/verb/toggle_radial_stacks()
	set category = "Preferences"
	set name = "Toggle Radial Stacks Wheel"

	prefs.toggles_gameplay ^= RADIAL_STACKS
	prefs.save_preferences()

	to_chat(src, span_notice("You will [(prefs.toggles_gameplay & RADIAL_STACKS) ? "now" : "no longer"] use the radial menu when interacting with material stacks."))

/client/verb/toggle_lobby_music()
	set category = "Preferences"
	set name = "Toggle Lobby Music"

	prefs.toggles_sound ^= SOUND_LOBBY
	prefs.save_preferences()

	if(prefs.toggles_sound & SOUND_LOBBY)
		to_chat(src, span_notice("You will now hear music in the game lobby."))
		if(!isnewplayer(mob))
			return
		play_title_music()

	else
		to_chat(src, span_notice("You will no longer hear music in the game lobby."))
		if(!isnewplayer(mob))
			return
		mob.stop_sound_channel(CHANNEL_LOBBYMUSIC)


/client/verb/toggle_ooc_self()
	set category = "Preferences"
	set name = "Toggle  OOC"

	prefs.toggles_chat ^= CHAT_OOC
	prefs.save_preferences()

	to_chat(src, span_notice("You will [(prefs.toggles_chat & CHAT_OOC) ? "now" : "no longer"] see messages on the OOC channel."))


/client/verb/toggle_looc_self()
	set category = "Preferences"
	set name = "Toggle  LOOC"

	prefs.toggles_chat ^= CHAT_LOOC
	prefs.save_preferences()

	to_chat(src, span_notice("You will [(prefs.toggles_chat & CHAT_LOOC) ? "now" : "no longer"] see messages on the LOOC channel."))


/client/verb/toggle_ambience()
	set category = "Preferences"
	set name = "Toggle Ambience"

	prefs.toggles_sound ^= SOUND_AMBIENCE
	prefs.save_preferences()

	if(prefs.toggles_sound & SOUND_AMBIENCE)
		to_chat(src, span_notice("You will now hear ambient sounds."))
	else
		to_chat(src, span_notice("You will no longer hear ambient sounds."))
		mob.stop_sound_channel(CHANNEL_AMBIENT)
	usr.client.update_ambience_pref()


/client/verb/toggle_special(role in BE_SPECIAL_FLAGS)
	set category = "Preferences"
	set name = "Toggle Special Roles"

	var/role_flag = BE_SPECIAL_FLAGS[role]
	if(!role_flag)
		return
	prefs.be_special ^= role_flag
	prefs.save_character()

	to_chat(src, span_notice("You will [(prefs.be_special & role_flag) ? "now" : "no longer"] be considered for [role] events (where possible)."))

/client/verb/setup_character()
	set category = "Preferences"
	set name = "Game Preferences"
	set desc = "Allows you to access the Setup Character screen. Changes to your character won't take effect until next round, but other changes will."
	prefs.ShowChoices(usr)


GLOBAL_LIST_INIT(ghost_forms, list("Default" = GHOST_DEFAULT_FORM, "Ghost Ian 1" = "ghostian", "Ghost Ian 2" = "ghostian2", "Skeleton" = "skeleghost", "Red" = "ghost_red",\
							"Black" = "ghost_black", "Blue" = "ghost_blue", "Yellow" = "ghost_yellow", "Green" = "ghost_green", "Pink" = "ghost_pink", \
							"Cyan" = "ghost_cyan", "Dark Blue" = "ghost_dblue", "Dark Red" = "ghost_dred", "Dark Green" = "ghost_dgreen", \
							"Dark Cyan" = "ghost_dcyan", "Grey" = "ghost_grey", "Dark Yellow" = "ghost_dyellow", "Dark Pink" = "ghost_dpink",\
							"Purple" = "ghost_purpleswirl", "Funky" = "ghost_funkypurp", "Transparent Pink" = "ghost_pinksherbert", "Blaze it" = "ghost_blazeit",\
							"Mellow" = "ghost_mellow", "Rainbow" = "ghost_rainbow", "Camo" = "ghost_camo", "Fire" = "ghost_fire", "Cat" = "catghost"))


/client/proc/pick_form()
	var/new_form = tgui_input_list(src, "Choose your ghostly form:", "Ghost Customization", GLOB.ghost_forms)
	if(!new_form)
		return


	prefs.ghost_form = GLOB.ghost_forms[new_form]
	prefs.save_preferences()

	to_chat(src, span_notice("You will use the [new_form] ghost form when starting as an observer."))

	if(!isobserver(mob))
		return

	var/mob/dead/observer/O = mob
	O.update_icon(GLOB.ghost_forms[new_form])


GLOBAL_LIST_INIT(ghost_orbits, list(GHOST_ORBIT_CIRCLE, GHOST_ORBIT_TRIANGLE, GHOST_ORBIT_SQUARE, GHOST_ORBIT_HEXAGON, GHOST_ORBIT_PENTAGON))

/client/proc/pick_ghost_orbit()
	var/new_orbit = tgui_input_list(src, "Choose your ghostly orbit:", "Ghost Customization", GLOB.ghost_orbits)
	if(!new_orbit)
		return

	prefs.ghost_orbit = new_orbit
	prefs.save_preferences()

	to_chat(src, span_notice("You will use the [new_orbit] as a ghost."))

	if(!isobserver(mob))
		return

	var/mob/dead/observer/O = mob
	O.ghost_orbit = new_orbit


GLOBAL_LIST_INIT(ghost_others_options, list(GHOST_OTHERS_SIMPLE, GHOST_OTHERS_DEFAULT_SPRITE, GHOST_OTHERS_THEIR_SETTING))

/client/proc/pick_ghost_other_form()
	var/new_others = tgui_input_list(src, "Choose how you see other observers:", "Ghost Customization", GLOB.ghost_others_options)
	if(!new_others)
		return

	prefs.ghost_others = new_others
	prefs.save_preferences()

	to_chat(src, span_notice("You will now see people who started as an observer as [new_others]."))

	if(!isobserver(mob))
		return

	var/mob/dead/observer/O = mob
	O.ghost_others = new_others


/client/verb/pick_ghost_customization()
	set category = "Preferences"
	set name = "Ghost Customization"
	set desc = "Customize your ghastly appearance."


	switch(tgui_alert(src, "Which setting do you want to change?", "Ghost Customization", list("Ghost Form", "Ghost Orbit", "Ghosts of others")))
		if("Ghost Form")
			pick_form()
		if("Ghost Orbit")
			pick_ghost_orbit()
		if("Ghosts of others")
			pick_ghost_other_form()


/client/verb/toggle_deadchat_arrivalrattle()
	set category = "Preferences"
	set name = "Toggle Deadchat arrivalrattles"
	set desc = "Announces when a player spawns for the first time."

	TOGGLE_BITFIELD(prefs.toggles_deadchat, DISABLE_ARRIVALRATTLE)
	to_chat(usr, span_notice("New spawn announcements have been [(prefs.toggles_deadchat & DISABLE_ARRIVALRATTLE) ? "disabled" : "enabled"]."))


/client/verb/toggle_deadchat_deathrattle()
	set category = "Preferences"
	set name = "Toggle Deadchat deathrattles"
	set desc = "Announces when a player dies."

	TOGGLE_BITFIELD(prefs.toggles_deadchat, DISABLE_DEATHRATTLE)
	to_chat(usr, span_notice("Death announcements have been [(prefs.toggles_deadchat & DISABLE_DEATHRATTLE) ? "disabled" : "enabled"]."))


/client/verb/toggle_instrument_sound()
	set category = "Preferences"
	set name = "Toggle Instrument Sound"

	usr.client.prefs.toggles_sound ^= SOUND_INSTRUMENTS_OFF
	usr.client.prefs.save_preferences()

	to_chat(usr, span_notice("You will [(usr.client.prefs.toggles_sound & SOUND_INSTRUMENTS_OFF) ? "no longer" : "now"] hear instruments."))

/client/verb/toggle_weather_sounds()
	set category = "Preferences"
	set name = "Toggle Weather Sound"

	usr.client.prefs.toggles_sound ^= SOUND_WEATHER
	prefs.save_preferences()

	to_chat(usr, span_notice("You will [(usr.client.prefs.toggles_sound & SOUND_WEATHER) ? "no longer" : "now"] hear weather."))

/client/verb/toggle_gas_mask_sound()
	set category = "Preferences"
	set name = "Toggle Gas Mask sounds."

	usr.client.prefs.toggles_sound ^= SOUND_GAS_MASK
	usr.client.prefs.save_preferences()

	to_chat(usr, span_notice("You will [(usr.client.prefs.toggles_sound & SOUND_GAS_MASK) ? "no longer" : "now"] hear gas masks breathy noises."))


/client/verb/toggle_round_end_sounds()
	set category = "Preferences"
	set name = "Toggle round end sounds."

	usr.client.prefs.toggles_sound ^= SOUND_NOENDOFROUND
	usr.client.prefs.save_preferences()

	to_chat(usr, span_notice("You will [(usr.client.prefs.toggles_sound & SOUND_NOENDOFROUND) ? "no longer" : "now"] hear round end sounds."))

///Same thing as the character creator preference, but as a byond verb, because not everyone can reach it in tgui preference menu
/client/verb/toggle_tgui_fancy()
	set name = "Toggle TGUI Window Compability Mode"
	set category = "Preferences"

	usr.client.prefs.tgui_fancy = !usr.client.prefs.tgui_fancy
	usr.client.prefs.save_preferences()
	SStgui.update_user_uis(usr)
	to_chat(src, span_interface("TGUI compatibility mode is now [usr.client.prefs.tgui_fancy ? "dis" : "en"]abled."))
