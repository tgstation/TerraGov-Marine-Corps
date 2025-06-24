ADMIN_VERB(set_view_range, R_FUN, "Set View Range", "Sets custom view range for yourself", ADMIN_CATEGORY_FUN)

	if(user.view_size.get_client_view_size() != user.view_size.default)
		user.view_size.reset_to_default()
		return

	var/newview = input(user, "Select view range:", "Change View Range", 7) as null|num
	if(!newview)
		return

	newview = VIEW_NUM_TO_STRING(newview)
	if(newview == user.view)
		return

	user.view_size.set_view_radius_to(newview)

	log_admin("[key_name(user)] changed their view range to [user.view].")
	message_admins("[ADMIN_TPMONTY(user.mob)] changed their view range to [user.view].")

ADMIN_VERB(emp, R_FUN, "EM Pulse", "Release an EMP of your size of choice", ADMIN_CATEGORY_FUN)
	var/heavy = input(user, "Range of heavy pulse.", "EM Pulse") as num|null
	if(isnull(heavy))
		return

	var/light = input(user,"Range of light pulse.", "EM Pulse") as num|null
	if(isnull(light))
		return

	heavy = clamp(heavy, 0, 10000)
	light = clamp(light, 0, 10000)

	empulse(user.mob, heavy, light)

	log_admin("[key_name(user,)] created an EM Pulse ([heavy], [light]) at [AREACOORD(user.mob)].")
	message_admins("[ADMIN_TPMONTY(user.mob)] created an EM Pulse ([heavy], [light]) at [ADMIN_VERBOSEJMP(user.mob)].")

ADMIN_VERB(queen_report, R_FUN, "Queen Mother Report", "Play a Queen mother report to xenos.", ADMIN_CATEGORY_FUN)
	var/customname = tgui_input_text(user, "What do you want the title of this report to be?", "Report Title", "Queen Mother Directive", encode = FALSE)
	var/input = tgui_input_text(user, "This should be a message from the ruler of the Xenomorph race.", "Queen Mother Report", "", multiline = TRUE, encode = FALSE)
	if(!input || !customname)
		return


	for(var/i in (GLOB.xeno_mob_list + GLOB.observer_list))
		var/mob/M = i
		to_chat(M, assemble_alert(
			title = customname,
			message = input,
			color_override = "purple"
		))

	log_admin("[key_name(user)] created a Queen Mother report: [input]")
	message_admins("[ADMIN_TPMONTY(user.mob)] created a Queen Mother report.")

ADMIN_VERB(rouny_all, R_FUN, "Toggle Glob Xeno Rouny", "Toggle all living xenos into rouny versions of themselves", ADMIN_CATEGORY_FUN)
	for(var/mob/living/carbon/xenomorph/xenotorouny in GLOB.xeno_mob_list)
		if(!isliving(xenotorouny))
			return
		xenotorouny.xeno_flags ^= XENO_ROUNY
	log_admin("[key_name(user)] toggled global rounification")
	message_admins("[ADMIN_TPMONTY(user.mob)] toggled global rounification.")


ADMIN_VERB(hive_status, R_FUN, "Check Hive Status", "Check the status of the hive.", ADMIN_CATEGORY_FUN)
	if(!SSticker)
		return

	check_hive_status(user.mob)

	log_admin("[key_name(user)] checked the hive status.")
	message_admins("[key_name_admin(user)] checked the hive status.")

ADMIN_VERB(ai_report, R_FUN, "AI Report", "Create an AI report to players", ADMIN_CATEGORY_FUN)
	var/customname = tgui_input_text(user, "What do you want the AI to be called?.", "AI Report", "AI", encode = FALSE)
	var/input = tgui_input_text(user, "This should be a message from the ship's AI.", "AI Report", multiline = TRUE, encode = FALSE)
	if(!input || !customname)
		return

	var/paper
	switch(tgui_alert(user, "Do you want to print out a paper at the communications consoles?", "AI Report", list("Yes", "No", "Cancel")))
		if("Yes")
			paper = TRUE
		if("No")
			paper = FALSE
		else
			return

	priority_announce(input, customname, sound = "sound/misc/interference.ogg")

	if(paper)
		print_command_report(input, "[customname] Update", announce = FALSE)

	log_admin("[key_name(user)] has created an AI report: [input]")
	message_admins("[ADMIN_TPMONTY(user.mob)] has created an AI report: [input]")

ADMIN_VERB(command_report, R_FUN, "Command Report", "Create a custom command report", ADMIN_CATEGORY_FUN)
	var/customname = tgui_input_text(user, "Pick a title for the report.", "Title", "TGMC Update", encode = FALSE)
	if(!customname)
		return
	var/customsubtitle = tgui_input_text(user, "Pick a subtitle for the report.", "Subtitle", "", encode = FALSE)
	var/input = tgui_input_text(user, "Please enter anything you want. Anything. Serious.", "What?", "", multiline = TRUE, encode = FALSE)
	if(!input)
		return
	var/override = tgui_input_list(user, "Pick a color for the report.", "Color", FACTION_ALERT_COLORS - "default", default = "blue")

	if(tgui_alert(user, "Do you want to print out a paper at the communications consoles?", null, list("Yes", "No")) == "Yes")
		print_command_report(input, "[SSmapping.configs[SHIP_MAP].map_name] Update", announce = FALSE)

	switch(tgui_alert(user, "Should this be announced to the general population?", "Announce", list("Yes", "No", "Cancel")))
		if("Yes")
			priority_announce(input, customname, customsubtitle, sound = 'sound/AI/commandreport.ogg', color_override = override);
		if("No")
			priority_announce("New update available at all communication consoles.", "Classified Transmission Received", type = ANNOUNCEMENT_PRIORITY, sound = 'sound/AI/commandreport.ogg')
		else
			return

	log_admin("[key_name(user)] has created a command report: [input]")
	message_admins("[ADMIN_TPMONTY(user.mob)] has created a command report.")

ADMIN_VERB(narrate_global, R_FUN, "Global Narrate", "Directly send text to everyone", ADMIN_CATEGORY_FUN)
	var/msg = tgui_input_text(user, "Enter the text you wish to appear to everyone.", "Global Narrate", multiline = TRUE , encode = FALSE)

	if(!msg)
		return

	to_chat(world, msg)

	log_admin("GlobalNarrate: [key_name(user)] : [msg]")
	message_admins("[ADMIN_TPMONTY(user.mob)] used Global Narrate: [msg]")

ADMIN_VERB_AND_CONTEXT_MENU(narrate_direct, R_FUN, "Direct Narrate", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_MAIN, mob/M in GLOB.mob_list)
	var/msg = tgui_input_text(user, "Enter the text you wish to appear to your target.", "Direct Narrate", multiline = TRUE, encode = FALSE)
	if(!msg)
		return

	to_chat(M, "[msg]")

	log_admin("DirectNarrate: [key_name(user)] to [key_name(M)]: [msg]")
	message_admins("[ADMIN_TPMONTY(user.mob)] used Direct Narrate on [ADMIN_TPMONTY(M)]: [msg]")

ADMIN_VERB_AND_CONTEXT_MENU(subtle_message, R_FUN|R_MENTOR, "Subtle Message", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_FUN, mob/M in GLOB.mob_list)
	var/msg = tgui_input_text(user, "Subtle PM to [key_name(M)]:", "Subtle Message", "", multiline = TRUE, encode = FALSE)

	if(!M?.client || !msg)
		return

	if(check_rights(R_ADMIN, FALSE))
		msg = noscript(msg)
	else
		msg = sanitize(msg)

	M.balloon_alert(M, "You hear a voice")
	to_chat(M, "<b>You hear a voice in your head... [msg]</b>")

	admin_ticket_log(M, "[key_name_admin(user)] used Subtle Message: [sanitize(msg)]")
	log_admin("SubtleMessage: [key_name(user)] to [key_name(M)]: [msg]")
	message_admins("[ADMIN_TPMONTY(user.mob)] used Subtle Message on [ADMIN_TPMONTY(M)]: [msg]")

ADMIN_VERB(award_medal, R_FUN, "Award a Medal", "Award a medal to a marine player", ADMIN_CATEGORY_FUN)
	give_medal_award()

ADMIN_VERB(custom_info, R_FUN, "Change Custom Info", "Set a custom info to show to everyone and new joining players", ADMIN_CATEGORY_FUN)
	var/new_info = tgui_input_text(user, "Set the custom information players get on joining or via the OOC tab.", "Custom info", GLOB.custom_info, multiline = TRUE, encode = FALSE)
	new_info = noscript(new_info)
	if(isnull(new_info) || GLOB.custom_info == new_info)
		return

	if(!new_info)
		log_admin("[key_name(user)] has cleared the custom info.")
		message_admins("[ADMIN_TPMONTY(user.mob)] has cleared the custom info.")
		return

	GLOB.custom_info = new_info

	to_chat(world, assemble_alert(
		title = "Custom Information",
		subtitle = "An admin set custom information for this round.",
		message = GLOB.custom_info,
		color_override = "red"
	))
	SEND_SOUND(src, sound('sound/misc/adm_announce.ogg'))

	log_admin("[key_name(user)] has changed the custom event text: [GLOB.custom_info]")
	message_admins("[ADMIN_TPMONTY(user.mob)] has changed the custom event text.")


/client/verb/custom_info()
	set category = "OOC"
	set name = "Custom Info"

	if(!GLOB.custom_info)
		to_chat(src, span_notice("There currently is no custom information set."))
		return

	to_chat(src, assemble_alert(
		title = "Custom Information",
		subtitle = "An admin set custom information for this round.",
		message = GLOB.custom_info,
		color_override = "red"
	))
	SEND_SOUND(src, sound('sound/misc/adm_announce.ogg'))

ADMIN_VERB(sound_file, R_SOUND, "Play Imported Sound", "Play a sound imported from anywhere on your computer.", ADMIN_CATEGORY_FUN, S as sound)
	var/heard_midi = 0
	var/sound/uploaded_sound = sound(S, repeat = 0, wait = 1, channel = CHANNEL_MIDI)
	uploaded_sound.priority = 250


	var/style = tgui_alert(user, "Play sound globally or locally?", "Play Imported Sound", list("Global", "Local", "Cancel"))
	switch(style)
		if("Global")
			for(var/i in GLOB.clients)
				var/client/C = i
				if(C.prefs.toggles_sound & SOUND_MIDI)
					SEND_SOUND(C, uploaded_sound)
					heard_midi++
		if("Local")
			playsound(get_turf(user.mob), uploaded_sound, 50, 0)
			for(var/mob/M in view())
				heard_midi++
		else
			return

	log_admin("[key_name(user)] played sound '[S]' for [heard_midi] player(s). [length(GLOB.clients) - heard_midi] player(s) [style == "Global" ? "have disabled admin midis" : "were out of view"].")
	message_admins("[ADMIN_TPMONTY(user.mob)] played sound '[S]' for [heard_midi] player(s). [length(GLOB.clients) - heard_midi] player(s) [style == "Global" ? "have disabled admin midis" : "were out of view"].")


GLOBAL_VAR_INIT(web_sound_cooldown, 0)

/proc/web_sound(mob/user, input, credit)
	if(!check_rights(R_SOUND))
		return
	var/ytdl = CONFIG_GET(string/invoke_youtubedl)
	if(!ytdl)
		to_chat(user, span_boldwarning("yt-dlp was not configured, action unavailable"), confidential = TRUE) //Check config.txt for the INVOKE_YOUTUBEDL value
		return
	var/list/music_extra_data = list()
	var/duration = 0
	var/web_sound_url = ""
	var/stop_web_sounds = FALSE
	if(istext(input))
		var/shell_scrubbed_input = shell_url_scrub(input)
		var/list/output = world.shelleo("[ytdl] --geo-bypass --format \"bestaudio\[ext=mp3]/best\[ext=mp4]\[height <= 360]/bestaudio\[ext=m4a]/bestaudio\[ext=aac]\" --dump-single-json --no-playlist -- \"[shell_scrubbed_input]\"")
		var/errorlevel = output[SHELLEO_ERRORLEVEL]
		var/stdout = output[SHELLEO_STDOUT]
		var/stderr = output[SHELLEO_STDERR]
		if(errorlevel)
			to_chat(user, span_boldwarning("yt-dlp URL retrieval FAILED:"), confidential = TRUE)
			to_chat(user, span_warning("[stderr]"), confidential = TRUE)
			return
		var/list/data
		try
			data = json_decode(stdout)
		catch(var/exception/e)
			to_chat(user, span_boldwarning("yt-dlp JSON parsing FAILED:"), confidential = TRUE)
			to_chat(user, span_warning("[e]: [stdout]"), confidential = TRUE)
			return
		if (data["url"])
			web_sound_url = data["url"]
		var/title = "[data["title"]]"
		var/webpage_url = title
		if (data["webpage_url"])
			webpage_url = "<a href=\"[data["webpage_url"]]\">[title]</a>"
		music_extra_data["duration"] = DisplayTimeText(data["duration"] * 1 SECONDS)
		music_extra_data["link"] = data["webpage_url"]
		music_extra_data["artist"] = data["artist"]
		music_extra_data["upload_date"] = data["upload_date"]
		music_extra_data["album"] = data["album"]
		duration = data["duration"] * 1 SECONDS
		if (duration > 10 MINUTES)
			if((tgui_alert(user, "This song is over 10 minutes long. Are you sure you want to play it?", "Length Warning!", list("No", "Yes", "Cancel")) != "Yes"))
				return
		var/res = tgui_alert(user, "Show the title of and link to this song to the players?\n[title]", "Show Info?", list("Yes", "No", "Cancel"))
		switch(res)
			if("Yes")
				music_extra_data["title"] = data["title"]
			if("No")
				music_extra_data["link"] = "Song Link Hidden"
				music_extra_data["title"] = "Song Title Hidden"
				music_extra_data["artist"] = "Song Artist Hidden"
				music_extra_data["upload_date"] = "Song Upload Date Hidden"
				music_extra_data["album"] = "Song Album Hidden"
			if("Cancel", null)
				return
		var/anon = tgui_alert(user, "Display who played the song?", "Credit Yourself?", list("Yes", "No", "Cancel"))
		switch(anon)
			if("Yes")
				if(res == "Yes")
					to_chat(world, span_boldannounce("[user.key] played: [webpage_url]"), confidential = TRUE)
				else
					to_chat(world, span_boldannounce("[user.key] played a sound"), confidential = TRUE)
			if("No")
				if(res == "Yes")
					to_chat(world, span_boldannounce("An admin played: [webpage_url]"), confidential = TRUE)
			if("Cancel", null)
				return
		if(credit)
			to_chat(world, span_boldannounce(credit), confidential = TRUE)
		SSblackbox.record_feedback("nested tally", "played_url", 1, list("[user.ckey]", "[input]"))
		log_admin("[key_name(user)] played web sound: [input]")
		message_admins("[key_name(user)] played web sound: [input]")
	else
		//pressed ok with blank
		log_admin("[key_name(user)] stopped web sounds.")

		message_admins("[key_name(user)] stopped web sounds.")
		web_sound_url = null
		stop_web_sounds = TRUE
	if(web_sound_url && !findtext(web_sound_url, GLOB.is_http_protocol))
		tgui_alert(user, "The media provider returned a content URL that isn't using the HTTP or HTTPS protocol. This is a security risk and the sound will not be played.", "Security Risk", list("OK"))
		to_chat(user, span_boldwarning("BLOCKED: Content URL not using HTTP(S) Protocol!"), confidential = TRUE)

		return
	if(web_sound_url || stop_web_sounds)
		for(var/m in GLOB.player_list)
			var/mob/M = m
			var/client/C = M.client
			if(C.prefs.toggles_sound & SOUND_MIDI)
				// Stops playing lobby music and admin loaded music automatically.
				SEND_SOUND(C, sound(null, channel = CHANNEL_LOBBYMUSIC))
				SEND_SOUND(C, sound(null, channel = CHANNEL_ADMIN))
				if(!stop_web_sounds)
					C.tgui_panel?.play_music(web_sound_url, music_extra_data)
				else
					C.tgui_panel?.stop_music()

	CLIENT_COOLDOWN_START(GLOB, web_sound_cooldown, duration)

	BLACKBOX_LOG_ADMIN_VERB("Play Internet Sound")

ADMIN_VERB_CUSTOM_EXIST_CHECK(play_web_sound)
	return !!CONFIG_GET(string/invoke_youtubedl)

ADMIN_VERB(play_web_sound, R_SOUND, "Play Internet Sound", "Play a given internet sound to all players.", ADMIN_CATEGORY_FUN)
	if(!CLIENT_COOLDOWN_FINISHED(GLOB, web_sound_cooldown))
		if(tgui_alert(user, "Someone else is already playing an Internet sound! It has [DisplayTimeText(CLIENT_COOLDOWN_TIMELEFT(GLOB, web_sound_cooldown), 1)] remaining. \
		Would you like to override?", "Musicalis Interruptus", list("No","Yes")) != "Yes")
			return

	var/web_sound_input = tgui_input_text(user, "Enter content URL (supported sites only, leave blank to stop playing)", "Play Internet Sound", null)

	if(length(web_sound_input))
		web_sound_input = trim(web_sound_input)
		if(findtext(web_sound_input, ":") && !findtext(web_sound_input, GLOB.is_http_protocol))
			to_chat(user, span_boldwarning("Non-http(s) URIs are not allowed."), confidential = TRUE)
			to_chat(user, span_warning("For youtube-dl shortcuts like ytsearch: please use the appropriate full URL from the website."), confidential = TRUE)
			return
		web_sound(user.mob, web_sound_input)
	else
		web_sound(user.mob, null)

ADMIN_VERB(sound_stop, R_SOUND, "Stop Regular Sounds", "Stop all sounds currently playing.", ADMIN_CATEGORY_FUN)
	for(var/mob/M in GLOB.player_list)
		if(M.client)
			SEND_SOUND(M, sound(null))

	log_admin("[key_name(user)] stopped regular sounds.")
	message_admins("[ADMIN_TPMONTY(user.mob)] stopped regular sounds.")

ADMIN_VERB(music_stop, R_SOUND, "Stop Playing Music", "Stop currently playing internet sound.", ADMIN_CATEGORY_FUN)
	for(var/i in GLOB.clients)
		var/client/C = i
		C?.tgui_panel?.stop_music()


	log_admin("[key_name(user)] stopped the currently playing music.")
	message_admins("[ADMIN_TPMONTY(user.mob)] stopped the currently playing music.")

ADMIN_VERB(announce, R_FUN, "Admin Announce", "Do an admin announcement to all players.", ADMIN_CATEGORY_FUN)
	var/message = tgui_input_text(user, "Global message to send:", "Admin Announce", multiline = TRUE, encode = FALSE)

	message = noscript(message)

	if(!message)
		return

	log_admin("Announce: [key_name(user)] : [message]")
	message_admins("[ADMIN_TPMONTY(user.mob)] Announces:")
	send_ooc_announcement(message, "From [user.holder.fakekey ? "Administrator" : user.ckey]", style = OOC_ALERT_ADMIN)

ADMIN_VERB(force_distress, R_FUN, "Distress Beacon", "Call a distress beacon manually.", ADMIN_CATEGORY_FUN)
	if(!SSticker?.mode)
		to_chat(user, span_warning("Please wait for the round to begin first."))

	if(SSticker.mode.waiting_for_candidates)
		to_chat(user, span_warning("Please wait for the current beacon to be finalized."))
		return

	if(SSticker.mode.picked_call)
		SSticker.mode.picked_call.reset()
		SSticker.mode.picked_call = null

	var/list/list_of_calls = list()
	for(var/datum/emergency_call/L in SSticker.mode.all_calls)
		if(L.name)
			list_of_calls += L.name

	list_of_calls += "Randomize"

	var/choice = tgui_input_list(user, "Which distress do you want to call?", null, list_of_calls)
	if(!choice)
		return

	if(choice == "Randomize")
		SSticker.mode.picked_call = SSticker.mode.get_random_call()
	else
		for(var/datum/emergency_call/C in SSticker.mode.all_calls)
			if(C.name == choice)
				SSticker.mode.picked_call = C
				break

	if(!istype(SSticker.mode.picked_call))
		return

	var/max = tgui_input_number(user, "What should the maximum amount of mobs be?", "Max mobs", SSticker.mode.picked_call.mob_max)
	if(!max || max < 1)
		return

	SSticker.mode.picked_call.mob_max = max

	var/min = tgui_input_number(user, "What should the minimum amount of mobs be?", "Min Mobs", SSticker.mode.picked_call.mob_min)
	if(!min || min < 1)
		min = 0

	SSticker.mode.picked_call.mob_min = min

	var/is_announcing = TRUE
	if(tgui_alert(user, "Would you like to announce the distress beacon to the server population? This will reveal the distress beacon to all players.", "Announce distress beacon?", list("Yes", "No")) != "Yes")
		is_announcing = FALSE

	SSticker.mode.picked_call.activate(is_announcing)

	log_admin("[key_name(user)] called a [choice == "Randomize" ? "randomized ":""]distress beacon: [SSticker.mode.picked_call.name]. Min: [min], Max: [max].")
	message_admins("[ADMIN_TPMONTY(user.mob)] called a [choice == "Randomize" ? "randomized ":""]distress beacon: [SSticker.mode.picked_call.name] Min: [min], Max: [max].")

ADMIN_VERB(drop_bomb, R_FUN, "Drop Bomb", "Cause an explosion of varying strength at your location.", ADMIN_CATEGORY_FUN)
	var/choice = tgui_input_list(user, "What size explosion would you like to produce?", "Drop Bomb", list("CANCEL", "CAS: Widow Maker", "CAS: Banshee", "CAS: Keeper", "CAS: Fatty", "CAS: Napalm", "Small Bomb", "Medium Bomb", "Big Bomb", "Maxcap", "Custom Bomb"))
	switch(choice)
		if("CAS: Widow Maker")
			playsound(user.mob.loc, 'sound/machines/hydraulics_2.ogg', 70, TRUE)
			new /obj/effect/overlay/temp/blinking_laser (user.mob.loc)
			addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(delayed_detonate_bomb), get_turf(user.mob.loc), 2, 4, 6, 0, 0, 0, 3), 1 SECONDS)
		if("CAS: Banshee")
			playsound(user.mob.loc, 'sound/machines/hydraulics_2.ogg', 70, TRUE)
			new /obj/effect/overlay/temp/blinking_laser (user.mob.loc)
			addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(delayed_detonate_bomb), get_turf(user.mob.loc), 2, 4, 7, 6, 7, 0, 3), 1 SECONDS)
		if("CAS: Keeper")
			playsound(user.mob.loc, 'sound/machines/hydraulics_2.ogg', 70, TRUE)
			new /obj/effect/overlay/temp/blinking_laser (user.mob.loc)
			addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(delayed_detonate_bomb), get_turf(user.mob.loc), 4, 5, 5, 6, 0, 0, 3), 1 SECONDS)
		if("CAS: Fatty")
			playsound(user.mob.loc, 'sound/machines/hydraulics_2.ogg', 70, TRUE)
			new /obj/effect/overlay/temp/blinking_laser (user.mob.loc)
			addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(delayed_detonate_bomb_fatty), get_turf(user.mob.loc)), 1 SECONDS)
		if("CAS: Napalm")
			playsound(user.mob.loc, 'sound/machines/hydraulics_2.ogg', 70, TRUE)
			new /obj/effect/overlay/temp/blinking_laser (user.mob.loc)
			addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(delayed_detonate_bomb_napalm), get_turf(user.mob.loc)), 1 SECONDS)
		if("Small Bomb")
			explosion(user.mob.loc, 1, 2, 3, 0, 3, explosion_cause=key_name_admin(user))
		if("Medium Bomb")
			explosion(user.mob.loc, 2, 3, 4, 0, 4, explosion_cause=key_name_admin(user))
		if("Big Bomb")
			explosion(user.mob.loc, 3, 5, 7, 0, 5, explosion_cause=key_name_admin(user))
		if("Maxcap")
			explosion(user.mob.loc, GLOB.MAX_EX_DEVESTATION_RANGE, GLOB.MAX_EX_HEAVY_RANGE, GLOB.MAX_EX_LIGHT_RANGE, 0, GLOB.MAX_EX_FLASH_RANGE)
		if("Custom Bomb")
			var/input_devastation_range = input("Devastation range (in tiles):", "Drop Bomb") as null|num
			var/input_heavy_impact_range = input("Heavy impact range (in tiles):", "Drop Bomb") as null|num
			var/input_light_impact_range = input("Light impact range (in tiles):", "Drop Bomb") as null|num
			var/input_flash_range = input("Flash range (in tiles):", "Drop Bomb") as null|num
			var/input_flame_range = input("Flame range (in tiles):", "Drop Bomb") as null|num
			var/input_throw_range = input("Throw range (in tiles):", "Drop Bomb") as null|num
			if(input_devastation_range < 1 && input_heavy_impact_range < 1 && input_light_impact_range < 1 && input_flash_range < 1 && input_flame_range < 1 && input_throw_range < 1)
				return
			var/world_max = max(world.maxy, world.maxy)
			input_devastation_range = clamp(input_devastation_range, 0, world_max)
			input_heavy_impact_range = clamp(input_heavy_impact_range, 0, world_max)
			input_light_impact_range = clamp(input_light_impact_range, 0, world_max)
			input_flash_range = clamp(input_flash_range, 0, world_max)
			input_flame_range = clamp(input_flame_range, 0, world_max)
			switch(tgui_alert(user, "Deploy payload?", "DIR: [input_devastation_range] | HIR: [input_heavy_impact_range] | LIR: [input_light_impact_range] | FshR: [input_flash_range] | FlmR: [input_flame_range] | ThR: [input_throw_range]", list("Launch!", "Cancel")))
				if("Launch!")
					explosion(user.mob.loc, input_devastation_range, input_heavy_impact_range, input_light_impact_range, 0, input_flash_range, input_flame_range, input_throw_range, explosion_cause=key_name_admin(user))
				else
					return
			choice = "[choice] ([input_devastation_range], [input_heavy_impact_range], [input_light_impact_range], 0, [input_flash_range], [input_flame_range])" //For better logging.
		else
			return

	log_admin("[key_name(user)] dropped a [choice] at [AREACOORD(user.mob)].")
	message_admins("[ADMIN_TPMONTY(user.mob)] dropped a [choice] at [ADMIN_VERBOSEJMP(user.mob)].")

/proc/delayed_detonate_bomb(turf/impact, input_devastation_range, input_heavy_impact_range, input_light_impact_range, input_flash_range, input_flame_range, input_throw_range, ceiling_debris)
	if(ceiling_debris)
		impact.ceiling_debris_check(ceiling_debris)
	explosion(impact, input_devastation_range, input_heavy_impact_range, input_light_impact_range, 0, input_flash_range, input_flame_range, input_throw_range, explosion_cause="delayed admin explosion")

/proc/delayed_detonate_bomb_fatty(turf/impact)
	impact.ceiling_debris_check(2)
	explosion(impact, 2, 3, 4, explosion_cause="delayed admin fatty")
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(delayed_detonate_bomb_fatty_final), impact), 3 SECONDS)

/proc/delayed_detonate_bomb_fatty_final(turf/impact)
	var/list/impact_coords = list(list(-3,3),list(0,4),list(3,3),list(-4,0),list(4,0),list(-3,-3),list(0,-4), list(3,-3))
	for(var/i in 1 to 8)
		var/list/coords = impact_coords[i]
		var/turf/detonation_target = locate(impact.x+coords[1],impact.y+coords[2],impact.z)
		detonation_target.ceiling_debris_check(2)
		explosion(detonation_target, 2, 3, 4, adminlog = FALSE, explosion_cause="delayed admin decondary bombs")

/proc/delayed_detonate_bomb_napalm(turf/impact)
	impact.ceiling_debris_check(3)
	explosion(impact, 2, 3, 4, 0, 6, explosion_cause="delayed admin napalm")
	flame_radius(5, impact, 30, 60)

ADMIN_VERB(drop_dynex_bomb, R_FUN, "Drop DynEx Bomb", "Cause an explosion of varying strength at your location.", ADMIN_CATEGORY_FUN)
	var/ex_power = input(user, "Explosive Power:") as null|num
	var/turf/epicenter = user.mob.loc
	if(ex_power && epicenter)
		dyn_explosion(epicenter, ex_power)
		message_admins("[ADMIN_LOOKUPFLW(user.mob)] creating an admin explosion of power [ex_power] at [epicenter.loc].")
		log_admin("[key_name(user)] created a admin explosion of power [ex_power] at [epicenter.loc].")

ADMIN_VERB(change_security_level, R_FUN, "Set Security Level", "Set the security level of the ship", ADMIN_CATEGORY_FUN)
	var/sec_level = tgui_input_list(user, "Security level is currently [SSsecurity_level.get_current_level_as_text()]. Choose the new security level.", "Set Security Level", SSsecurity_level.available_levels - SSsecurity_level.get_current_level_as_text())
	if(!sec_level)
		return

	if(tgui_alert(user, "Switch from [SSsecurity_level.get_current_level_as_text()] to [sec_level]?", "Set Security Level", list("Yes", "No")) != "Yes")
		return

	SSsecurity_level.set_level(sec_level, TRUE)

	log_admin("[key_name(user)] changed the security level to [sec_level].")
	message_admins("[ADMIN_TPMONTY(user.mob)] changed the security level to [sec_level].")

ADMIN_VERB_ONLY_CONTEXT_MENU(rank_and_equipment, R_FUN, "Rank and Equipment", mob/living/carbon/human/H in GLOB.human_mob_list)
	var/dat = "<br>"
	var/obj/item/card/id/C = H.wear_id

	if(!H.mind)
		dat += "No mind! <a href='byond://?src=[REF(user.holder)];[HrefToken()];rank=createmind;mob=[REF(H)]'>Create</a><br>"
		dat += "Take-over job: [H.job ? H.job.title : "None"] <a href='byond://?src=[REF(user.holder)];[HrefToken()];rank=rank;mob=[REF(H)]'>Edit</a><br>"
		if(ismarinejob(H.job))
			dat += "Squad: [H.assigned_squad] <a href='byond://?src=[REF(user.holder)];[HrefToken()];rank=squad;mob=[REF(H)]'>Edit</a><br>"
	else
		dat += "Job: [H.job ? H.job.title : "Unassigned"] <a href='byond://?src=[REF(user.holder)];[HrefToken()];rank=rank;mob=[REF(H)]'>Edit</a> "
		dat += "<a href='byond://?src=[REF(user.holder)];[HrefToken()];rank=rank;doequip=1;mob=[REF(H)]'>Edit and Equip</a> "
		dat += "<a href='byond://?src=[REF(user.holder)];[HrefToken()];rank=rank;doset=1;mob=[REF(H)]'>Edit and Set</a><br>"
		dat += "<br>"
		dat += "Skillset: [H.skills.name] <a href='byond://?src=[REF(user.holder)];[HrefToken()];rank=skills;mob=[REF(H)]'>Edit</a><br>"
		dat += "Comms title: [H.comm_title] <a href='byond://?src=[REF(user.holder)];[HrefToken()];rank=commstitle;mob=[REF(H)]'>Edit</a><br>"
		if(ismarinejob(H.job))
			dat += "Squad: [H.assigned_squad] <a href='byond://?src=[REF(user.holder)];[HrefToken()];rank=squad;mob=[REF(H)]'>Edit</a><br>"
	if(istype(C))
		dat += "<br>"
		dat += "Chat title: [get_paygrades(C.paygrade, FALSE, H.gender)] <a href='byond://?src=[REF(user.holder)];[HrefToken()];rank=chattitle;mob=[REF(H)];id=[REF(C)]'>Edit</a><br>"
		dat += "ID title: [C.assignment] <a href='byond://?src=[REF(user.holder)];[HrefToken()];rank=idtitle;mob=[REF(H)];id=[REF(C)]'>Edit</a><br>"
		dat += "ID name: [C.registered_name] <a href='byond://?src=[REF(user.holder)];[HrefToken()];rank=idname;mob=[REF(H)];id=[REF(C)]'>Edit</a><br>"
		dat += "Access: [get_access_job_name(C)] <a href='byond://?src=[REF(user.holder)];[HrefToken()];rank=access;mob=[REF(H)];id=[REF(C)]'>Edit</a><br>"
	else
		dat += "No ID! <a href='byond://?src=[REF(user.holder)];[HrefToken()];rank=createid;mob=[REF(H)]'>Give ID</a><br>"

	dat += "<br>"
	dat += "<a href='byond://?src=[REF(user.holder)];[HrefToken()];rank=equipment;mob=[REF(H)]'>Select Equipment</a>"


	var/datum/browser/browser = new(user.mob, "edit_rank_[key_name(H)]", "<div align='center'>Edit Rank [key_name(H)]</div>", 400, 350)
	browser.set_content(dat)
	browser.open(FALSE)

ADMIN_VERB_ONLY_CONTEXT_MENU(edit_appearance, R_FUN, "Edit Appearance", mob/living/carbon/human/H in GLOB.human_mob_list)
	if(!istype(H))
		return

	var/hcolor = "#[num2hex(H.r_hair, 2)][num2hex(H.g_hair, 2)][num2hex(H.b_hair, 2)]"
	var/fcolor = "#[num2hex(H.r_facial, 2)][num2hex(H.g_facial, 2)][num2hex(H.b_facial, 2)]"
	var/ecolor = "#[num2hex(H.r_eyes, 2)][num2hex(H.g_eyes, 2)][num2hex(H.b_eyes, 2)]"
	var/bcolor = "#[num2hex(H.r_skin, 2)][num2hex(H.g_skin, 2)][num2hex(H.b_skin, 2)]"

	var/dat = "<br>"

	dat += "Hair style: [H.h_style] <a href='byond://?src=[REF(user.holder)];[HrefToken()];appearance=hairstyle;mob=[REF(H)]'>Edit</a><br>"
	dat += "Hair color: <font face='fixedsys' size='3' color='[hcolor]'><table style='display:inline;' bgcolor='[hcolor]'><tr><td>_.</td></tr></table></font> <a href='byond://?src=[REF(user.holder)];[HrefToken()];appearance=haircolor;mob=[REF(H)]'>Edit</a><br>"
	dat += "<br>"
	dat += "Facial hair style: [H.f_style] <a href='byond://?src=[REF(user.holder)];[HrefToken()];appearance=facialhairstyle;mob=[REF(H)]'>Edit</a><br>"
	dat += "Facial hair color: <font face='fixedsys' size='3' color='[fcolor]'><table style='display:inline;' bgcolor='[fcolor]'><tr><td>_.</td></tr></table></font> <a href='byond://?src=[REF(user.holder)];[HrefToken()];appearance=facialhaircolor;mob=[REF(H)]'>Edit</a><br>"
	dat += "<br>"
	dat += "Eye color: <font face='fixedsys' size='3' color='[ecolor]'><table style='display:inline;' bgcolor='[ecolor]'><tr><td>_.</td></tr></table></font> <a href='byond://?src=[REF(user.holder)];[HrefToken()];appearance=eyecolor;mob=[REF(H)]'>Edit</a><br>"
	dat += "Body color: <font face='fixedsys' size='3' color='[bcolor]'><table style='display:inline;' bgcolor='[bcolor]'><tr><td>_.</td></tr></table></font> <a href='byond://?src=[REF(user.holder)];[HrefToken()];appearance=bodycolor;mob=[REF(H)]'>Edit</a><br>"
	dat += "<br>"
	dat += "Gender: [H.gender] <a href='byond://?src=[REF(user.holder)];[HrefToken()];appearance=gender;mob=[REF(H)]'>Edit</a><br>"
	dat += "Physique: [H.physique] <a href='byond://?src=[REF(user.holder)];[HrefToken()];appearance=physique;mob=[REF(H)]'>Edit</a><br>"
	dat += "Ethnicity: [H.ethnicity] <a href='byond://?src=[REF(user.holder)];[HrefToken()];appearance=ethnicity;mob=[REF(H)]'>Edit</a><br>"
	dat += "Species: [H.species] <a href='byond://?src=[REF(user.holder)];[HrefToken()];appearance=species;mob=[REF(H)]'>Edit</a><br>"

	var/datum/browser/browser = new(user.mob, "edit_appearance_[key_name(H)]", "<div align='center'>Edit Appearance [key_name(H)]</div>")
	browser.set_content(dat)
	browser.open(FALSE)

ADMIN_VERB_ONLY_CONTEXT_MENU(offer, R_ADMIN, "Offer Mob", mob/living/L in GLOB.mob_living_list)
	if(L.client)
		if(tgui_alert(user, "This mob has a player inside, are you sure you want to proceed?", "Offer Mob", list("Yes", "No")) != "Yes")
			return
		L.ghostize(FALSE)

	else if(L in GLOB.offered_mob_list)
		switch(tgui_alert(user, "This mob has been offered, do you want to re-announce it?", "Offer Mob", list("Yes", "Remove", "Cancel")))
			if("Remove")
				GLOB.offered_mob_list -= L
				log_admin("[key_name(user)] has removed offer of [key_name_admin(L)].")
				message_admins("[ADMIN_TPMONTY(user.mob)] has removed offer of [ADMIN_TPMONTY(L)].")
				return
			if(!"Yes")
				return

	else if(tgui_alert(user, "Are you sure you want to offer this mob?", "Offer Mob", list("Yes", "No")) != "Yes")
		return

	if(!istype(L))
		to_chat(user, span_warning("Target is no longer valid."))
		return

	L.offer_mob()

	log_admin("[key_name(user)] has offered [key_name_admin(L)].")
	message_admins("[ADMIN_TPMONTY(user.mob)] has offered [ADMIN_TPMONTY(L)].")

ADMIN_VERB_ONLY_CONTEXT_MENU(xeno_panel, R_FUN, "Xeno Panel", mob/living/carbon/xenomorph/X in GLOB.xeno_mob_list)
	if(!istype(X))
		return

	var/dat = "<br>"

	dat += "Hive: [X.hive.hivenumber] <a href='byond://?src=[REF(user.holder)];[HrefToken()];xeno=hive;mob=[REF(X)]'>Edit</a><br>"
	dat += "Nicknumber: [X.nicknumber] <a href='byond://?src=[REF(user.holder)];[HrefToken()];xeno=nicknumber;mob=[REF(X)]'>Edit</a><br>"
	dat += "Upgrade Tier: [X.xeno_caste.upgrade_name] <a href='byond://?src=[REF(user.holder)];[HrefToken()];xeno=upgrade;mob=[REF(X)]'>Edit</a><br>"

	var/datum/browser/browser = new(user.mob, "xeno_panel_[key_name(X)]", "<div align='center'>Xeno Panel [key_name(X)]</div>")
	browser.set_content(dat)
	browser.open(FALSE)

ADMIN_VERB_ONLY_CONTEXT_MENU(release, R_FUN, "Release Obj", obj/OB in world)
	var/mob/M = user.mob

	if(!M.control_object)
		return

	var/obj/O = M.control_object

	var/datum/player_details/P = GLOB.player_details[M.ckey]

	M.real_name = P.played_names[length(P.played_names)]
	M.name = M.real_name

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.name = H.get_visible_name()

	M.abstract_move(get_turf(M.control_object))
	M.reset_perspective()
	M.control_object = null

	log_admin("[key_name(user)] has released [O] ([O.type]).")
	message_admins("[ADMIN_TPMONTY(user.mob)] has released [O] ([O.type]).")

ADMIN_VERB_ONLY_CONTEXT_MENU(possess, R_FUN, "Possess Obj", obj/O in world)
	var/mob/M = user.mob

	M.loc = O
	M.real_name = O.name
	M.name = O.name
	M.reset_perspective()
	M.control_object = O

	log_admin("[key_name(user)] has possessed [O] ([O.type]).")
	message_admins("[ADMIN_TPMONTY(user.mob)] has possessed [O] ([O.type]).")

ADMIN_VERB_AND_CONTEXT_MENU(imaginary_friend, R_FUN|R_MENTOR, "Imaginary Friend", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_MAIN, mob/living/living_mob AS in GLOB.mob_living_list)
	if(istype(user.mob, /mob/camera/imaginary_friend))
		var/mob/camera/imaginary_friend/IF = user.mob
		IF.ghostize()
		return

	var/mob/living/friend_owner = user.holder.apicker("Select by:", "Imaginary Friend", list(APICKER_CLIENT, APICKER_LIVING))
	if(!friend_owner)
		// nothing was picked, probably canceled
		return
	user.holder.create_ifriend(friend_owner)

/// Handles actually spawning in the friend, if the rest of the checks pass
/datum/admins/proc/create_ifriend(mob/living/friend_owner, seek_confirm = FALSE)
	if(!check_rights(R_FUN|R_MENTOR))
		return
	if(!istype(friend_owner)) // living only
		to_chat(usr, span_warning("That creature can not have Imaginary Friends") )
		return
	if(seek_confirm && tgui_alert(usr, "Become Imaginary Friend of [friend_owner]?", "Confirm", list("Yes", "No")) != "Yes")
		return

	var/client/C = usr.client
	if(!isobserver(C.mob))
		if(is_mentor(C) && tgui_alert(usr, "You will be unable to return to your old body without admin help. Are you sure?", "Confirm", list("Yes", "No")) != "Yes")
			return
		SSadmin_verbs.dynamic_invoke_verb(C, /datum/admin_verb/aghost)
	var/mob/camera/imaginary_friend/IF = new(get_turf(friend_owner), friend_owner)
	C.mob.mind.transfer_to(IF)

	admin_ticket_log(friend_owner, "[key_name_admin(C)] became an imaginary friend of [key_name(friend_owner)]")
	log_admin("[key_name(IF)] started being imaginary friend of [key_name(friend_owner)].")
	message_admins("[ADMIN_TPMONTY(IF)] started being imaginary friend of [ADMIN_TPMONTY(friend_owner)].")

ADMIN_VERB(force_dropship, R_FUN, "Force Dropship", "Force a dropship to move", ADMIN_CATEGORY_DEBUG)
	if(!length(SSshuttle.dropships) && !SSshuttle.canterbury)
		return

	var/list/available_shuttles = list()
	for(var/i in SSshuttle.mobile)
		var/obj/docking_port/mobile/M = i
		available_shuttles["[M.name] ([M.id])"] = M.id

	var/answer = tgui_input_list(user, "Which shuttle do you want to move?", "Force Dropship", available_shuttles)
	var/shuttle_id = available_shuttles[answer]
	if(!shuttle_id)
		return

	var/obj/docking_port/mobile/D
	for(var/i in SSshuttle.mobile)
		var/obj/docking_port/mobile/M = i
		if(M.id == shuttle_id)
			D = M

	if(!D)
		to_chat(user, span_warning("Unable to find shuttle"))
		return

	if(D.mode != SHUTTLE_IDLE && tgui_alert(user, "[D.name] is not idle, move anyway?", "Force Dropship", list("Yes", "No")) != "Yes")
		return

	var/list/valid_docks = list()
	var/i = 1
	for(var/obj/docking_port/stationary/S in SSshuttle.stationary)
		if(istype(S, /obj/docking_port/stationary/transit))
			continue // Don't use transit destinations
		if(!D.check_dock(S, silent=TRUE))
			continue
		valid_docks["[S.name] ([i++])"] = S

	if(!length(valid_docks))
		to_chat(user, span_warning("No valid destinations found!"))
		return

	var/dock = tgui_input_list(user, "Choose the destination.", "Force Dropship", valid_docks)
	if(!dock)
		return

	var/obj/docking_port/stationary/target = valid_docks[dock]
	if(!target)
		to_chat(user, span_warning("No valid dock found!"))
		return

	var/instant = FALSE
	if(tgui_alert(user, "Do you want to move the [D.name] instantly?", "Force Dropship", list("Yes", "No")) == "Yes")
		instant = TRUE

	var/success = SSshuttle.moveShuttleToDock(D.id, target, !instant)
	switch(success)
		if(0)
			success = "successfully"
		if(1)
			success = "failing to find the shuttle"
		if(2)
			success = "failing to dock"
		else
			success = "failing somehow"

	log_admin("[key_name(user)] has moved [D.name] ([D.id]) to [target] ([target.id])[instant ? " instantly" : ""] [success].")
	message_admins("[ADMIN_TPMONTY(user.mob)] has moved [D.name] ([D.id]) to [target] ([target.id])[instant ? " instantly" : ""] [success].")

ADMIN_VERB(play_cinematic, R_FUN, "Play Cinematic", "Play a selected cinematic", ADMIN_CATEGORY_FUN)
	var/datum/cinematic/choice = tgui_input_list(user, "Choose a cinematic to play.", "Play Cinematic", subtypesof(/datum/cinematic))
	if(!choice)
		return

	Cinematic(initial(choice.id), world)

	log_admin("[key_name(user)] played the [choice] cinematic.")
	message_admins("[ADMIN_TPMONTY(user.mob)] played the [choice] cinematic.")

ADMIN_VERB(set_tip, R_FUN, "Set Tip", "Set a tip of the round", ADMIN_CATEGORY_FUN)
	var/tip = tgui_input_text(user, "Please specify your tip that you want to send to the players.", "Tip", multiline = TRUE, encode = FALSE)
	if(!tip)
		return

	SSticker.selected_tip = tip

	//If we've already tipped, then send it straight away.
	if(SSticker.tipped)
		SSticker.send_tip_of_the_round()

	log_admin("[key_name(user)] set a tip of the round: [tip]")
	message_admins("[ADMIN_TPMONTY(user.mob)] set a tip of the round.")

ADMIN_VERB(ghost_interact, R_FUN, "Ghost Interact", "Toggle ghost interact mode", ADMIN_CATEGORY_FUN)
	user.holder.ghost_interact = !user.holder.ghost_interact

	log_admin("[key_name(user)] has [user.holder.ghost_interact ? "enabled" : "disabled"] ghost interact.")
	message_admins("[ADMIN_TPMONTY(user.mob)] has [user.holder.ghost_interact ? "enabled" : "disabled"] ghost interact.")

ADMIN_VERB(run_weather, R_FUN, "Run Weather", "Triggers a weather on the z-level you choose.", ADMIN_CATEGORY_FUN)
	var/weather_type = tgui_input_list(user, "Choose a weather", "Weather", subtypesof(/datum/weather))
	if(!weather_type)
		return

	var/turf/T = get_turf(user.mob)
	var/z_level = tgui_input_number(user, "Z-Level to target?", "Z-Level", T?.z)
	if(!isnum(z_level))
		return

	SSweather.run_weather(weather_type, z_level)

	message_admins("[key_name_admin(user)] started weather of type [weather_type] on the z-level [z_level].")
	log_admin("[key_name(user)] started weather of type [weather_type] on the z-level [z_level].")

///client verb to set round end sound
ADMIN_VERB(set_round_end_sound, R_SOUND, "Set Round End Sound", "Set a sound to play when the server restarts", ADMIN_CATEGORY_FUN, S as sound)
	SSticker.SetRoundEndSound(S)

	log_admin("[key_name(user)] set the round end sound to [S]")
	message_admins("[key_name_admin(user)] set the round end sound to [S]")

ADMIN_VERB(adjust_gravity, R_FUN, "Adjust Gravity", "Adjusts gravity/jump components of all mobs.", ADMIN_CATEGORY_FUN)
	var/choice = tgui_input_list(user, "What would you like to set gravity to?", "Gravity adjustment", list("Standard gravity", "Low gravity", "John Woo", "Exceeding orbital velocity"))
	switch(choice)
		if("Standard gravity")
			to_chat(GLOB.mob_living_list, span_userdanger("You feel gravity return to normal."))
			for(var/mob/living/living_mob AS in GLOB.mob_living_list)
				living_mob.set_jump_component()
		if("Low gravity")
			to_chat(GLOB.mob_living_list, span_userdanger("You feel gravity pull gently at you."))
			for(var/mob/living/living_mob AS in GLOB.mob_living_list)
				living_mob.set_jump_component(duration = 1 SECONDS, cooldown = 1.5 SECONDS, cost = 2, height = 32, jump_pass_flags = PASS_LOW_STRUCTURE|PASS_FIRE|PASS_DEFENSIVE_STRUCTURE|PASS_TANK)
		if("John Woo")
			to_chat(GLOB.mob_living_list, span_userdanger("You feel gravity grow weak, and the urge to fly."))
			for(var/mob/living/living_mob AS in GLOB.mob_living_list)
				living_mob.set_jump_component(duration = 1 SECONDS, cooldown = 1.5 SECONDS, cost = 2, height = 48, sound = SFX_JUMP, flags = JUMP_SPIN, jump_pass_flags = HOVERING|PASS_PROJECTILE|PASS_TANK)
		if("Exceeding orbital velocity")
			to_chat(GLOB.mob_living_list, span_userdanger("You feel gravity fade to nothing. Will you even come back down?"))
			for(var/mob/living/living_mob AS in GLOB.mob_living_list)
				living_mob.set_jump_component(duration = 4 SECONDS, cooldown = 6 SECONDS, cost = 0, height = 128, sound = SFX_JUMP, flags = JUMP_SPIN, jump_pass_flags = HOVERING|PASS_PROJECTILE|PASS_TANK)
		else
			return

	log_admin("[key_name(user)] set gravity to [choice].")

ADMIN_VERB(ai_squad, R_FUN, "Spawn AI squad", "Spawns a AI squad of your choice", ADMIN_CATEGORY_FUN)
	var/squad_choice = tgui_input_list(user, "What squad would you like to spawn?", "squad choice", GLOB.ai_squad_presets)
	if(!squad_choice)
		return
	var/quantity = tgui_input_number(user, "How many mobs would you like in the squad?", title = "Squad Size", default = 5, max_value = length(GLOB.ai_squad_presets[squad_choice]), min_value = 1, timeout = 0, round_value = TRUE)
	if(!quantity)
		return
	var/turf/spawn_loc = get_turf(user.mob)
	if(!spawn_loc)
		return
	var/list/mob_list = list()
	for(var/i = 1 to quantity)
		var/mob/living/carbon/human/new_human = new()
		mob_list += new_human
		var/datum/job/new_job = SSjob.GetJob(GLOB.ai_squad_presets[squad_choice][i])
		var/squad_to_insert_into
		if(ismarinejob(new_job) || issommarinejob(new_job))
			squad_to_insert_into = pick(SSjob.active_squads[new_job.faction])
		new_human.apply_assigned_role_to_spawn(new_job, new_human.client, squad_to_insert_into, admin_action = TRUE)
		stoplag()
	for(var/mob/living/carbon/human/dude AS in mob_list)
		dude.forceMove(spawn_loc)
		dude.AddComponent(/datum/component/ai_controller, /datum/ai_behavior/human)

	message_admins("[key_name_admin(user)] spawned a [quantity] man [squad_choice] of AI humans in [AREACOORD(spawn_loc)].")
	log_admin("[key_name(user)] spawned a [quantity] man [squad_choice] of AI humans in [AREACOORD(spawn_loc)].")


ADMIN_VERB(load_lazy_template, R_FUN, "Load/Jump Lazy Template", "Loads a lazy template and/or jumps to it.", ADMIN_CATEGORY_FUN)
	var/list/choices = LAZY_TEMPLATE_KEY_LIST_ALL()
	var/choice = tgui_input_list(user, "Key?", "Lazy Loader", choices)
	var/teleport_to_template = tgui_input_list(user, "Jump to template after loading?", "Where to?", list("Yes", "No"))
	if(!choice)
		return

	choice = choices[choice]
	if(!choice)
		to_chat(user, span_warning("No template with that key found, report this!"))
		return

	var/already_loaded = LAZYACCESS(SSmapping.loaded_lazy_templates, choice)
	var/force_load = FALSE
	if(already_loaded && (tgui_alert(user, "Template already loaded.", "", list("Jump", "Load Again")) == "Load Again"))
		force_load = TRUE

	var/datum/turf_reservation/reservation = SSmapping.lazy_load_template(choice, force = force_load)
	if(!reservation)
		to_chat(user, span_boldwarning("Failed to load template!"))
		return

	if(teleport_to_template == "Yes")
		if(!isobserver(user.mob))
			SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/aghost)
		user.mob.forceMove(reservation.bottom_left_turfs[1])
		to_chat(user, span_notice("Template loaded, you have been moved to the bottom left of the reservation."))

	message_admins("[key_name_admin(user)] has loaded lazy template '[choice]'")
