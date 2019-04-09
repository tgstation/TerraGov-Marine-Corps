/datum/admins/proc/set_view_range()
	set category = "Fun"
	set name = "Set View Range"

	if(!check_rights(R_FUN))
		return

	if(usr.client.view != world.view)
		usr.client.change_view(world.view)
		return

	var/newview = input("Select view range:", "Change View Range", 7) as null|num
	if(!newview || newview == usr.client.view)
		return

	usr.client.change_view(newview)

	log_admin("[key_name(usr)] changed their view range to [usr.client.view].")
	message_admins("[ADMIN_TPMONTY(usr)] changed their view range to [usr.client.view].")


/datum/admins/proc/emp()
	set category = "Fun"
	set name = "EM Pulse"

	if(!check_rights(R_FUN))
		return

	var/heavy = input("Range of heavy pulse.", text("Input")) as num|null
	if(heavy < 0)
		return

	var/light = input("Range of light pulse.", text("Input")) as num|null
	if(light < 0)
		return

	empulse(usr, heavy, light)

	log_admin("[key_name(usr)] created an EM Pulse ([heavy], [light]) at [AREACOORD(usr.loc)].")
	message_admins("[ADMIN_TPMONTY(usr)] created an EM Pulse ([heavy], [light]) at [ADMIN_VERBOSEJMP(usr.loc)].")


/datum/admins/proc/queen_report()
	set category = "Fun"
	set name = "Queen Mother Report"

	if(!check_rights(R_FUN))
		return

	var/customname = input("What do you want it to be called?.",, "Queen Mother Psychic Directive")
	var/input = input("This should be a message from the ruler of the Xenomorph race.",, "") as message|null
	if(!input || !customname)
		return

	var/msg = "<br><h2 class='alert'>[customname]</h2><br><span class='warning'>[input]</span><br><br>"

	for(var/mob/M in GLOB.player_list)
		if(isxeno(M) || isobserver(M))
			to_chat(M, msg)

	log_admin("[key_name(usr)] created a Queen Mother report: [input]")
	message_admins("[ADMIN_TPMONTY(usr)] created a Queen Mother report.")


/datum/admins/proc/hive_status()
	set category = "Fun"
	set name = "Hive Status"
	set desc = "Check the status of the hive."

	if(!check_rights(R_FUN))
		return

	if(!SSticker)
		return

	check_hive_status()

	log_admin("[key_name(usr)] checked the hive status.")


/datum/admins/proc/ai_report()
	set category = "Fun"
	set name = "AI Report"

	if(!check_rights(R_FUN))
		return

	var/input = input("This should be a message from the ship's AI.",, "") as message|null
	if(!input)
		return

	if(alert(usr, "Do you want to use the ship AI to say the message or a global marine announcement?",, "Ship", "Global") == "Ship")
		if(!ai_system.Announce(input))
			return
	else
		command_announcement.Announce(input, MAIN_AI_SYSTEM, new_sound = 'sound/misc/interference.ogg')

	if(alert(usr, "Do you want to print out a paper at the communications consoles?",, "Yes", "No") == "Yes")
		for(var/obj/machinery/computer/communications/C in GLOB.machines)
			if(!(C.machine_stat & (BROKEN|NOPOWER)))
				var/obj/item/paper/P = new /obj/item/paper(C.loc)
				P.name = "'[MAIN_AI_SYSTEM] Update.'"
				P.info = input
				P.update_icon()
				C.messagetitle.Add("[MAIN_AI_SYSTEM] Update")
				C.messagetext.Add(P.info)

	log_admin("[key_name(usr)] has created an AI report: [input]")
	message_admins("[ADMIN_TPMONTY(usr)] has created an AI report: [input]")


/datum/admins/proc/command_report()
	set category = "Fun"
	set name = "Command Report"

	if(!check_rights(R_FUN))
		return


	var/customname = input("Pick a title for the report.", "Title", "TGMC Update") as text|null
	var/input = input("Please enter anything you want. Anything. Serious.", "What?", "") as message|null

	if(!input || !customname)
		return

	if(alert(usr, "Do you want to print out a paper at the communications consoles?",, "Yes", "No") == "Yes")
		for(var/obj/machinery/computer/communications/C in GLOB.machines)
			if(!(C.machine_stat & (BROKEN|NOPOWER)))
				var/obj/item/paper/P = new /obj/item/paper(C.loc)
				P.name = "'[CONFIG_GET(string/ship_name)] Update.'"
				P.info = input
				P.update_icon()
				C.messagetitle.Add("[CONFIG_GET(string/ship_name)] Update")
				C.messagetext.Add(P.info)

	switch(alert("Should this be announced to the general population?", "Announce", "Yes", "No", "Cancel"))
		if("Yes")
			command_announcement.Announce(input, customname, new_sound = 'sound/AI/commandreport.ogg', admin = TRUE);
		if("No")
			command_announcement.Announce("<span class='warning'>New update available at all communication consoles.</span>", customname, new_sound = 'sound/AI/commandreport.ogg', admin = TRUE)
		if("Cancel")
			return

	log_admin("[key_name(usr)] has created a command report: [input]")
	message_admins("[ADMIN_TPMONTY(usr)] has created a command report.")


/datum/admins/proc/narrate_global()
	set category = "Fun"
	set name = "Global Narrate"

	if(!check_rights(R_FUN))
		return

	var/msg = input("Enter the text you wish to appear to everyone.", "Global Narrate") as text

	if(!msg)
		return

	to_chat(world, "[msg]")

	log_admin("GlobalNarrate: [key_name(usr)] : [msg]")
	message_admins("[ADMIN_TPMONTY(usr)] used Global Narrate: [msg]")


/datum/admins/proc/narage_direct(var/mob/M in GLOB.mob_list)
	set category = null
	set name = "Direct Narrate"

	if(!check_rights(R_FUN))
		return

	var/msg = input("Enter the text you wish to appear to your target.", "Direct Narrate") as text
	if(!msg)
		return

	to_chat(M, "[msg]")

	log_admin("DirectNarrate: [key_name(usr)] to [key_name(M)]: [msg]")
	message_admins("[ADMIN_TPMONTY(usr)] used Direct Narrate on [ADMIN_TPMONTY(M)]: [msg]")


/datum/admins/proc/subtle_message(var/mob/M in GLOB.player_list)
	set category = null
	set name = "Subtle Message"

	if(!check_rights(R_FUN|R_MENTOR))
		return

	var/msg = input("Subtle PM to [key_name(M)]:", "Subtle Message", "") as text

	if(!M?.client || !msg)
		return

	if(check_rights(R_ADMIN, FALSE))
		msg = noscript(msg)
	else
		msg = sanitize(msg)

	to_chat(M, "<b>You hear a voice in your head... [msg]</b>")

	admin_ticket_log(M, "[key_name_admin(usr)] used Subtle Message: [sanitize(msg)]")
	log_admin("SubtleMessage: [key_name(usr)] to [key_name(M)]: [msg]")
	message_admins("[ADMIN_TPMONTY(usr)] used Subtle Message on [ADMIN_TPMONTY(M)]: [msg]")


/datum/admins/proc/subtle_message_panel()
	set category = "Fun"
	set name = "Subtle Message Mob"

	if(!check_rights(R_FUN|R_MENTOR))
		return

	var/mob/M
	switch(input("Message by:", "Subtle Message") as null|anything in list("Key", "Mob"))
		if("Key")
			var/client/C = input("Please, select a key.", "Subtle Message") as null|anything in sortKey(GLOB.clients)
			if(!C)
				return
			M = C.mob
		if("Mob")
			var/mob/N = input("Please, select a mob.", "Subtle Message") as null|anything in sortNames(GLOB.player_list)
			if(!N)
				return
			M = N
		else
			return

	var/msg = input("Subtle PM to [key_name(M)]:", "Subtle Message", "") as text

	if(!M?.client || !msg)
		return

	if(check_rights(R_ADMIN, FALSE))
		msg = noscript(msg)
	else
		msg = sanitize(msg)

	to_chat(M, "<b>You hear a voice in your head... [msg]</b>")

	admin_ticket_log(M, "[key_name_admin(usr)] used Subtle Message: [sanitize(msg)]")
	log_admin("SubtleMessage: [key_name(usr)] to [key_name(M)]: [msg]")
	message_admins("[ADMIN_TPMONTY(usr)] used Subtle Message on [ADMIN_TPMONTY(M)]: [msg]")


/datum/admins/proc/award_medal()
	set category = "Fun"
	set name = "Award a Medal"

	if(!check_rights(R_FUN))
		return

	give_medal_award()


/datum/admins/proc/custom_info()
	set category = "Fun"
	set name = "Change Custom Info"

	if(!check_rights(R_FUN))
		return

	switch(input("Do you want to change or clear the custom info?", "Custom Info") as null|anything in list("Change", "Clear"))
		if("Change")
			GLOB.custom_info = input(usr, "Set the custom information players get on joining or via the OOC tab.", "Custom Info", GLOB.custom_info) as message|null

			GLOB.custom_info = noscript(GLOB.custom_info)

			if(!GLOB.custom_info)
				return

			to_chat(world, "<h1 class='alert'>Custom Information</h1>")
			to_chat(world, "<span class='alert'>[GLOB.custom_info]</span>")

			log_admin("[key_name(usr)] has changed the custom event text: [GLOB.custom_info]")
			message_admins("[ADMIN_TPMONTY(usr)] has changed the custom event text.")
		if("Clear")
			GLOB.custom_info = null
			log_admin("[key_name(usr)] has cleared the custom info.")
			message_admins("[ADMIN_TPMONTY(usr)] has cleared the custom info.")


/client/verb/custom_info()
	set category = "OOC"
	set name = "Custom Info"

	if(!GLOB.custom_info)
		to_chat(src, "<span class='notice'>There currently is no custom information set.</span>")
		return

	to_chat(src, "<h1 class='alert'>Custom Information</h1>")
	to_chat(src, "<span class='alert'>[GLOB.custom_info]</span>")


/datum/admins/proc/sound_file(S as sound)
	set category = "Fun"
	set name = "Play Imported Sound"
	set desc = "Play a sound imported from anywhere on your computer."

	if(!check_rights(R_SOUND))
		return

	var/heard_midi = 0
	var/sound/uploaded_sound = sound(S, repeat = 0, wait = 1, channel = 777)
	uploaded_sound.priority = 250


	var/style = alert("Play sound globally or locally?", "Play Imported Sound", "Global", "Local", "Cancel")
	switch(style)
		if("Global")
			for(var/i in GLOB.clients)
				var/client/C = i
				if(C.prefs.toggles_sound & SOUND_MIDI)
					SEND_SOUND(C, uploaded_sound)
					heard_midi++
		if("Local")
			playsound(get_turf(usr), uploaded_sound, 50, 0)
			for(var/mob/M in view())
				heard_midi++
		if("Cancel")
			return

	log_admin("[key_name(usr)] played sound '[S]' for [heard_midi] player(s). [length(GLOB.clients) - heard_midi] player(s) [style == "Global" ? "have disabled admin midis" : "were out of view"].")
	message_admins("[ADMIN_TPMONTY(usr)] played sound '[S]' for [heard_midi] player(s). [length(GLOB.clients) - heard_midi] player(s) [style == "Global" ? "have disabled admin midis" : "were out of view"].")


/datum/admins/proc/sound_web()
	set category = "Fun"
	set name = "Play Internet Sound"

	if(!check_rights(R_SOUND))
		return

	var/ytdl = CONFIG_GET(string/invoke_youtubedl)
	if(!ytdl)
		to_chat(usr, "<span class='warning'>Youtube-dl was not configured, action unavailable.</span>")
		return

	var/web_sound_input = input("Enter content URL (supported sites only)", "Play Internet Sound via youtube-dl") as text|null
	if(!istext(web_sound_input))
		return

	var/web_sound_url = ""
	var/list/music_extra_data = list()
	var/title
	var/show = FALSE
	if(length(web_sound_input))
		web_sound_input = trim(web_sound_input)
		if(findtext(web_sound_input, ":") && !findtext(web_sound_input, GLOB.is_http_protocol))
			to_chat(usr, "<span class='warning'>Non-http(s) URIs are not allowed.</span>")
			to_chat(usr, "<span class='warning'>For youtube-dl shortcuts like ytsearch: please use the appropriate full url from the website.</span>")
			return
		var/shell_scrubbed_input = shell_url_scrub(web_sound_input)
		var/list/output = world.shelleo("[ytdl] --format \"bestaudio\[ext=mp3]/best\[ext=mp4]\[height<=360]/bestaudio\[ext=m4a]/bestaudio\[ext=aac]\" --dump-single-json --no-playlist -- \"[shell_scrubbed_input]\"")
		var/errorlevel = output[SHELLEO_ERRORLEVEL]
		var/stdout = output[SHELLEO_STDOUT]
		var/stderr = output[SHELLEO_STDERR]
		if(!errorlevel)
			var/list/data
			try
				data = json_decode(stdout)
			catch(var/exception/e)
				to_chat(usr, "<span class='warning'>Youtube-dl JSON parsing FAILED: [e]: [stdout]</span>")
				return
			if(data["url"])
				web_sound_url = data["url"]
				title = "[data["title"]]"
				music_extra_data["start"] = data["start_time"]
				music_extra_data["end"] = data["end_time"]
				var/res = alert(usr, "Show the title of and link to this song to the players?\n[title]",, "Yes", "No", "Cancel")
				switch(res)
					if("Yes")
						if(data["webpage_url"])
							show = "<a href=\"[data["webpage_url"]]\">[title]</a>"
					if("Cancel")
						return
		else
			to_chat(usr, "<span class='warning'>Youtube-dl URL retrieval FAILED: [stderr]</span>")

		if(web_sound_url && !findtext(web_sound_url, GLOB.is_http_protocol))
			to_chat(usr, "<span class='warning'>BLOCKED: Content URL not using http(s) protocol</span>")
			to_chat(usr, "<span class='warning'>The media provider returned a content URL that isn't using the HTTP or HTTPS protocol</span>")
			return

		var/lst
		var/style = input("Do you want to play this globally or to the xenos/marines?") as null|anything in list("Globally", "Xenos", "Marines", "Locally")
		switch(style)
			if("Globally")
				lst = GLOB.mob_list
			if("Xenos")
				lst = GLOB.xeno_mob_list + GLOB.dead_mob_list
			if("Marines")
				lst = GLOB.human_mob_list + GLOB.dead_mob_list
			if("Locally")
				lst = viewers(usr.client.view, usr)

		if(!lst)
			return

		for(var/m in lst)
			var/mob/M = m
			var/client/C = M.client
			if(!C?.prefs)
				continue
			if((C.prefs.toggles_sound & SOUND_MIDI) && C.chatOutput && !C.chatOutput.broken && C.chatOutput.loaded)
				C.chatOutput.sendMusic(web_sound_url, music_extra_data)
				if(show)
					to_chat(C, "<span class='boldnotice'>An admin played: [show]</span>")

		log_admin("[key_name(usr)] played web sound: [web_sound_input] - [title] - [style]")
		message_admins("[ADMIN_TPMONTY(usr)] played web sound: [web_sound_input] - [title] - [style]")


/datum/admins/proc/sound_stop()
	set category = "Fun"
	set name = "Stop Regular Sounds"

	if(!check_rights(R_SOUND))
		return

	for(var/mob/M in GLOB.player_list)
		if(M.client)
			SEND_SOUND(M, sound(null))

	log_admin("[key_name(usr)] stopped regular sounds.")
	message_admins("[ADMIN_TPMONTY(usr)] stopped regular sounds.")


/datum/admins/proc/music_stop()
	set category = "Fun"
	set name = "Stop Playing Music"

	if(!check_rights(R_SOUND))
		return

	for(var/i in GLOB.clients)
		var/client/C = i
		if(!C?.chatOutput.loaded || C.chatOutput.broken)
			continue	
		C.chatOutput.stopMusic()


	log_admin("[key_name(usr)] stopped the currently playing music.")
	message_admins("[ADMIN_TPMONTY(usr)] stopped the currently playing music.")


/datum/admins/proc/announce()
	set category = "Fun"
	set name = "Admin Announce"

	if(!check_rights(R_FUN))
		return

	var/message = input("Global message to send:", "Admin Announce") as message|null

	message = noscript(message)

	if(!message)
		return

	log_admin("Announce: [key_name(usr)] : [message]")
	message_admins("[ADMIN_TPMONTY(usr)] Announces:")
	to_chat(world, "<span class='notice'><b>[usr.client.holder.fakekey ? "Administrator" : "[usr.client.key] ([usr.client.holder.rank])"] Announces:</b>\n [message]</span>")


/datum/admins/proc/force_distress()
	set category = "Fun"
	set name = "Distress Beacon"
	set desc = "Call a distress beacon manually."

	if(!check_rights(R_FUN))
		return

	if(!SSticker?.mode)
		to_chat(src, "<span class='warning'>Please wait for the round to begin first.</span>")

	if(SSticker.mode.waiting_for_candidates)
		to_chat(src, "<span class='warning'>Please wait for the current beacon to be finalized.</span>")
		return

	if(SSticker.mode.picked_call)
		SSticker.mode.picked_call.members = list()
		SSticker.mode.picked_call.candidates = list()
		SSticker.mode.waiting_for_candidates = FALSE
		SSticker.mode.on_distress_cooldown = FALSE
		SSticker.mode.picked_call = null

	var/list/list_of_calls = list()
	for(var/datum/emergency_call/L in SSticker.mode.all_calls)
		if(L.name)
			list_of_calls += L.name

	list_of_calls += "Randomize"

	var/choice = input("Which distress do you want to call?") as null|anything in list_of_calls
	if(!choice)
		return

	if(choice == "Randomize")
		SSticker.mode.picked_call	= SSticker.mode.get_random_call()
	else
		for(var/datum/emergency_call/C in SSticker.mode.all_calls)
			if(C.name == choice)
				SSticker.mode.picked_call = C
				break

	if(!istype(SSticker.mode.picked_call))
		return

	var/max = input("What should the maximum amount of mobs be?", "Max Mobs", 20) as null|num
	if(!max || max < 1)
		return

	SSticker.mode.picked_call.mob_max = max

	var/min = input("What should the minimum amount of mobs be?", "Min Mobs", 1) as null|num
	if(!min || min < 1)
		return

	SSticker.mode.picked_call.mob_min = min

	var/is_announcing = TRUE
	if(alert(usr, "Would you like to announce the distress beacon to the server population? This will reveal the distress beacon to all players.", "Announce distress beacon?", "Yes", "No") != "Yes")
		is_announcing = FALSE

	SSticker.mode.picked_call.activate(is_announcing)

	log_admin("[key_name(usr)] called a [choice == "Randomize" ? "randomized ":""]distress beacon: [SSticker.mode.picked_call.name]. Min: [min], Max: [max].")
	message_admins("[ADMIN_TPMONTY(usr)] called a [choice == "Randomize" ? "randomized ":""]distress beacon: [SSticker.mode.picked_call.name] Min: [min], Max: [max].")


/datum/admins/proc/force_dropship()
	set category = "Fun"
	set name = "Force Dropship"
	set desc = "Force a dropship to launch"

	var/tag = input("Which dropship should be force launched?", "Select a dropship:") as null|anything in list("Dropship 1", "Dropship 2")
	if(!tag)
		return

	var/crash = FALSE
	switch(alert("Would you like to force a crash?", , "Yes", "No", "Cancel"))
		if("Yes")
			crash = TRUE
		if("No")
			crash = FALSE
		else
			return

	var/datum/shuttle/ferry/marine/dropship = shuttle_controller.shuttles[CONFIG_GET(string/ship_name) + " " + tag]

	if(!dropship)
		return

	if(crash && dropship.location != 1)
		switch(alert("Error: Shuttle is on the ground. Proceed with standard launch anyways?", , "Yes", "No"))
			if("Yes")
				dropship.process_state = WAIT_LAUNCH
			if("No")
				return
	else if(crash)
		dropship.process_state = FORCE_CRASH
	else
		dropship.process_state = WAIT_LAUNCH

	log_admin("[key_name(usr)] force launched [tag][crash ? " making it crash" : ""].")
	message_admins("[ADMIN_TPMONTY(usr)] force launched [tag][crash ? " making it crash" : ""].")


/datum/admins/proc/force_ert_shuttle()
	set category = "Fun"
	set name = "Force ERT Shuttle"
	set desc = "Force Launch the ERT Shuttle."

	if(!check_rights(R_FUN))
		return

	if(!SSticker?.mode)
		return

	var/tag = input("Which ERT shuttle should be force launched?", "Select an ERT Shuttle:") as null|anything in list("Distress", "Distress_PMC", "Distress_UPP", "Distress_Big")
	if(!tag)
		return

	var/datum/shuttle/ferry/ert/shuttle = shuttle_controller.shuttles[tag]
	if(!shuttle || !istype(shuttle))
		return

	if(!shuttle.location)
		return

	var/dock_id
	var/dock_list = list("Port", "Starboard", "Aft")
	if(shuttle.use_umbilical)
		dock_list = list("Port Hangar", "Starboard Hangar")
	var/dock_name = input("Where on the [CONFIG_GET(string/ship_name)] should the shuttle dock?", "Select a docking zone:") as null|anything in dock_list
	switch(dock_name)
		if("Port")
			dock_id = /area/shuttle/distress/arrive_2
		if("Starboard")
			dock_id = /area/shuttle/distress/arrive_1
		if("Aft")
			dock_id = /area/shuttle/distress/arrive_3
		if("Port Hangar")
			dock_id = /area/shuttle/distress/arrive_s_hangar
		if("Starboard Hangar")
			dock_id = /area/shuttle/distress/arrive_n_hangar
		else
			return

	for(var/datum/shuttle/ferry/ert/F in shuttle_controller.process_shuttles)
		if(F != shuttle)
			if(!F.location || F.moving_status != SHUTTLE_IDLE)
				if(F.area_station.type == dock_id)
					to_chat(usr, "<span class='warning'>That docking zone is already taken by another shuttle. Aborting.</span>")
					return

	for(var/area/A in all_areas)
		if(A.type == dock_id)
			shuttle.area_station = A
			break


	if(!shuttle.can_launch())
		to_chat(usr, "<span class='warning'>Unable to launch this distress shuttle at this moment. Aborting.</span>")
		return

	shuttle.launch()

	log_admin("[key_name(usr)] force launched a distress shuttle: [tag] to [dock_name].")
	message_admins("[ADMIN_TPMONTY(usr)] force launched a distress shuttle: [tag] to: [dock_name].")


/datum/admins/proc/object_sound(atom/O as obj in world)
	set category = null
	set name = "Object Sound"

	if(!check_rights(R_FUN))
		return

	if(!O)
		return

	var/message = input("What do you want the message to be?") as text|null
	if(!message)
		return

	var/method = input("What do you want the verb to be? Make sure to include s.") as text|null
	if(!method)
		return

	for(var/mob/V in hearers(O))
		V.show_message("<b>[O.name]</b> [method], \"[message]\"", 2)
	if(usr.control_object)
		usr.show_message("<b>[O.name]</b> [method], \"[message]\"", 2)

	log_admin("[key_name(usr)] forced [O] ([O.type]) to: [method] [message]")
	message_admins("[ADMIN_TPMONTY(usr)] forced [O] ([O.type]) to: [method] [message]")


/datum/admins/proc/drop_bomb()
	set category = "Fun"
	set name = "Drop Bomb"
	set desc = "Cause an explosion of varying strength at your location."

	if(!check_rights(R_FUN))
		return

	var/mob/M = usr

	var/list/choices = list("CANCEL", "Small Bomb", "Medium Bomb", "Big Bomb", "Custom Bomb")
	var/choice = input("What size explosion would you like to produce?") in choices
	switch(choice)
		if("CANCEL")
			return
		if("Small Bomb")
			explosion(M.loc, 1, 2, 3, 3)
		if("Medium Bomb")
			explosion(M.loc, 2, 3, 4, 4)
		if("Big Bomb")
			explosion(M.loc, 3, 5, 7, 5)
		if("Custom Bomb")
			var/devastation_range = input("Devastation range (in tiles):") as null|num
			var/heavy_impact_range = input("Heavy impact range (in tiles):") as null|num
			var/light_impact_range = input("Light impact range (in tiles):") as null|num
			var/flash_range = input("Flash range (in tiles):") as null|num
			if(isnull(devastation_range) || isnull(heavy_impact_range) || isnull(light_impact_range) || isnull(flash_range))
				return
			explosion(M.loc, devastation_range, heavy_impact_range, light_impact_range, flash_range)

	log_admin("[key_name(usr)] dropped a bomb at [AREACOORD(M.loc)].")
	message_admins("[ADMIN_TPMONTY(usr)] dropped a bomb at [ADMIN_VERBOSEJMP(M.loc)].")


/datum/admins/proc/change_security_level()
	set category = "Fun"
	set name = "Set Security Level"

	if(!check_rights(R_FUN))
		return

	var/sec_level = input(usr, "It's currently code [get_security_level()].", "Select Security Level")  as null|anything in (list("green", "blue", "red", "delta") - get_security_level())
	if(!sec_level || alert("Switch from code [get_security_level()] to code [sec_level]?", "Change security level?", "Yes", "No") != "Yes")
		return

	set_security_level(sec_level)

	log_admin("[key_name(usr)] changed the security level to code [sec_level].")
	message_admins("[ADMIN_TPMONTY(usr)] changed the security level to code [sec_level].")


/datum/admins/proc/select_rank(mob/living/carbon/human/H in GLOB.human_mob_list)
	set category = "Fun"
	set name = "Select Rank"

	if(!istype(H))
		return

	switch(alert("Modify the rank or give them a new one?", "Select Rank", "New Rank", "Modify", "Cancel"))
		if("New Rank")
			var/newrank = input("Select new rank for [H]", "Change the mob's rank and skills") as null|anything in sortList(SSjob.name_occupations)
			if(!newrank || !istype(H))
				return

			H.set_rank(newrank)

			log_admin("[key_name(usr)] has set the rank of [key_name(H)] to [newrank].")
			message_admins("[ADMIN_TPMONTY(usr)] has set the rank of [ADMIN_TPMONTY(H)] to [newrank].")

		if("Modify")
			var/obj/item/card/id/I = H.wear_id
			switch(input("What do you want to edit?") as null|anything in list("Comms Title - \[Engineering (Title)]", "Chat Title - Title John Doe screams!", "ID title - Jane Doe's ID Card (Title)", "Registered Name - Jane Doe's ID Card", "Skills"))
				if("Comms Title - \[Engineering (Title)]")
					var/commtitle = input("Write the custom title appearing in the comms: Comms Title - \[Engineering (Title)]", "Comms Title") as null|text
					if(!commtitle || !H?.mind)
						return
					H.mind.comm_title = commtitle
				if("Chat Title - Title John Doe screams!")
					var/chattitle = input("Write the custom title appearing in all chats: Title Jane Doe screams!", "Chat Title") as null|text
					if(chattitle || !H || !istype(I))
						return
					I.paygrade = chattitle
					I.update_label()
				if("ID title - Jane Doe's ID Card (Title)")
					var/idtitle = input("Write the custom title appearing on the ID itself: Jane Doe's ID Card (Title)", "ID Title") as null|text
					if(!idtitle || !H || !istype(I))
						return
					I.assignment = idtitle
					I.update_label()
				if("Registered Name - Jane Doe's ID Card")
					var/regname = input("Write the name appearing on the ID itself: Jane Doe's ID Card", "Registered Name") as null|text
					if(!H || I != H.wear_id || !istype(I))
						return
					I.registered_name = regname
					I.update_label()
				if("Skills")
					var/newskillset = input("Select a skillset", "Skill Set") as null|anything in sortList(SSjob.name_occupations)
					if(!newskillset || !H?.mind)
						return
					var/datum/job/J = SSjob.name_occupations[newskillset]
					var/datum/skills/S = new J.skills_type()
					H.mind.cm_skills = S
				else
					return

			log_admin("[key_name(usr)] has made a custom rank/skill change for [key_name(H)].")
			message_admins("[ADMIN_TPMONTY(usr)] has made a custom rank/skill change for [ADMIN_TPMONTY(H)].")


/datum/admins/proc/select_equipment(mob/living/carbon/human/H in GLOB.human_mob_list)
	set category = "Fun"
	set name = "Select Equipment"

	if(!check_rights(R_FUN))
		return

	var/dresscode = input("Please select an outfit.", "Select Equipment") as null|anything in list("{Naked}", "{Job}", "{Custom}")
	if(!dresscode)
		return

	if(dresscode == "{Job}")
		var/list/job_paths = subtypesof(/datum/outfit/job)
		var/list/job_outfits = list()
		for(var/path in job_paths)
			var/datum/outfit/O = path
			if(initial(O.can_be_admin_equipped))
				job_outfits[initial(O.name)] = path

		dresscode = input("Select job equipment", "Select Equipment") as null|anything in sortList(job_outfits)
		dresscode = job_outfits[dresscode]

	else if(dresscode == "{Custom}")
		var/list/custom_names = list()
		for(var/datum/outfit/D in GLOB.custom_outfits)
			custom_names[D.name] = D
		var/selected_name = input("Select outfit", "Select Equipment") as null|anything in sortList(custom_names)
		dresscode = custom_names[selected_name]

	if(!dresscode)
		return

	var/datum/outfit/O
	H.delete_equipment(TRUE)
	if(dresscode != "{Naked}")
		O = new dresscode
		H.equipOutfit(O, FALSE)

	H.regenerate_icons()

	log_admin("[key_name(usr)] changed the equipment of [key_name(H)] to [istype(O) ?  O.name : dresscode].")
	message_admins("[ADMIN_TPMONTY(usr)] changed the equipment of [ADMIN_TPMONTY(H)] to [istype(O) ? O.name : dresscode].")


/datum/admins/proc/change_squad(mob/living/carbon/human/H in GLOB.human_mob_list)
	set category = "Fun"
	set name = "Change Squad"

	if(!check_rights(R_FUN))
		return

	if(!istype(H) || !(H.job in JOBS_MARINES))
		return

	var/squad = input("Choose the marine's new squad.", "Change Squad") as null|anything in SSjob.squads
	if(!squad || !istype(H) || !(H.job in JOBS_MARINES))
		return

	H.change_squad(squad)

	log_admin("[key_name(src)] has changed the squad of [key_name(H)] to [squad].")
	message_admins("[ADMIN_TPMONTY(usr)] has changed the squad of [ADMIN_TPMONTY(H)] to [squad].")


/datum/admins/proc/create_outfit()
	set category = "Fun"
	set name = "Create Custom Outfit"

	if(!check_rights(R_FUN))
		return

	var/dat = {"
	<html><head><title>Create Outfit</title></head><body>
	<div>Input typepaths and watch the magic happen.</div>
	<form name="outfit" action="byond://?src=[REF(usr.client.holder)];[HrefToken()]" method="get">
	<input type="hidden" name="src" value="[REF(usr.client.holder)];[HrefToken()]">
	[HrefTokenFormField()]
	<table>
		<tr>
			<th>Name:</th>
			<td>
				<input type="text" name="outfit_name" value="Custom Outfit">
			</td>
		</tr>
		<tr>
			<th>Uniform:</th>
			<td>
			   <input type="text" name="outfit_uniform" value="">
			</td>
		</tr>
		<tr>
			<th>Suit:</th>
			<td>
				<input type="text" name="outfit_suit" value="">
			</td>
		</tr>
		<tr>
			<th>Back:</th>
			<td>
				<input type="text" name="outfit_back" value="">
			</td>
		</tr>
		<tr>
			<th>Belt:</th>
			<td>
				<input type="text" name="outfit_belt" value="">
			</td>
		</tr>
		<tr>
			<th>Gloves:</th>
			<td>
				<input type="text" name="outfit_gloves" value="">
			</td>
		</tr>
		<tr>
			<th>Shoes:</th>
			<td>
				<input type="text" name="outfit_shoes" value="">
			</td>
		</tr>
		<tr>
			<th>Head:</th>
			<td>
				<input type="text" name="outfit_head" value="">
			</td>
		</tr>
		<tr>
			<th>Mask:</th>
			<td>
				<input type="text" name="outfit_mask" value="">
			</td>
		</tr>
		<tr>
			<th>Ears:</th>
			<td>
				<input type="text" name="outfit_ears" value="">
			</td>
		</tr>
		<tr>
			<th>Glasses:</th>
			<td>
				<input type="text" name="outfit_glasses" value="">
			</td>
		</tr>
		<tr>
			<th>ID:</th>
			<td>
				<input type="text" name="outfit_id" value="">
			</td>
		</tr>
		<tr>
			<th>Left Pocket:</th>
			<td>
				<input type="text" name="outfit_l_pocket" value="">
			</td>
		</tr>
		<tr>
			<th>Right Pocket:</th>
			<td>
				<input type="text" name="outfit_r_pocket" value="">
			</td>
		</tr>
		<tr>
			<th>Suit Store:</th>
			<td>
				<input type="text" name="outfit_s_store" value="">
			</td>
		</tr>
		<tr>
			<th>Right Hand:</th>
			<td>
				<input type="text" name="outfit_r_hand" value="">
			</td>
		</tr>
		<tr>
			<th>Left Hand:</th>
			<td>
				<input type="text" name="outfit_l_hand" value="">
			</td>
		</tr>
	</table>
	<br>
	<input type="submit" value="Save">
	</form></body></html>
	"}

	usr << browse(dat, "window=dressup;size=550x600")


/datum/admins/proc/edit_appearance(mob/living/carbon/human/H in GLOB.human_mob_list)
	set category = "Fun"
	set name = "Edit Appearance"

	if(!check_rights(R_FUN))
		return

	if(!istype(H))
		return

	switch(input("What do you want to edit?") as null|anything in list("Hair Style", "Hair Color", "Facial Hair Style", "Facial Hair Color", "Eye Color", "Body Color", "Gender", "Ethnicity"))
		if("Hair Style")
			var/new_hstyle = input("Select a hair style") as null|anything in GLOB.hair_styles_list
			if(!new_hstyle || !istype(H))
				return
			H.h_style = new_hstyle
		if("Hair Color")
			var/new_hair = input("Select hair color.") as color
			if(!new_hair || !istype(H))
				return
			H.r_hair = hex2num(copytext(new_hair, 2, 4))
			H.g_hair = hex2num(copytext(new_hair, 4, 6))
			H.b_hair = hex2num(copytext(new_hair, 6, 8))
		if("Facial Hair Style")
			var/new_fstyle = input("Select a facial hair style")  as null|anything in GLOB.facial_hair_styles_list
			if(!new_fstyle || !istype(H))
				return
			H.f_style = new_fstyle
		if("Facial Hair Color")
			var/new_facial = input("Please select facial hair color.") as color
			if(!new_facial || !istype(H))
				return
			H.r_facial = hex2num(copytext(new_facial, 2, 4))
			H.g_facial = hex2num(copytext(new_facial, 4, 6))
			H.b_facial = hex2num(copytext(new_facial, 6, 8))
		if("Eye Color")
			var/new_eyes = input("Please select eye color.", "Character Generation") as color
			if(!new_eyes || !istype(H))
				return
			H.r_eyes = hex2num(copytext(new_eyes, 2, 4))
			H.g_eyes = hex2num(copytext(new_eyes, 4, 6))
			H.b_eyes = hex2num(copytext(new_eyes, 6, 8))
		if("Body Color")
			var/new_skin = input("Please select body color. This is for Tajaran, Unathi, and Skrell only!", "Character Generation") as color
			if(!new_skin || !istype(H))
				return
			H.r_skin = hex2num(copytext(new_skin, 2, 4))
			H.g_skin = hex2num(copytext(new_skin, 4, 6))
			H.b_skin = hex2num(copytext(new_skin, 6, 8))
		if("Gender")
			var/new_gender = alert("Please select gender.",, "Male", "Female")
			if(!new_gender || !istype(H))
				return
			if(new_gender == "Male")
				H.gender = MALE
			else
				H.gender = FEMALE
		if("Ethnicity")
			var/new_ethnicity = input("Please select the ethnicity") as null|anything in GLOB.ethnicities_list
			if(!new_ethnicity || !istype(H))
				return
			H.ethnicity = new_ethnicity
		else
			return

	H.update_hair()
	H.update_body()
	H.regenerate_icons()
	H.check_dna(H)

	log_admin("[key_name(usr)] updated the appearance of [key_name(H)].")
	message_admins("[ADMIN_TPMONTY(usr)] updated the appearance of [ADMIN_TPMONTY(H)].")


/datum/admins/proc/offer(mob/M in GLOB.mob_list)
	set category = "Fun"
	set name = "Offer Mob"

	if(!check_rights(R_FUN))
		return

	if(!isliving(M))
		return

	var/mob/living/L = M

	if(L.key || L.ckey)
		if(alert("This mob has a player inside, are you sure you want to proceed?", "Offer Mob", "Yes", "No") != "Yes")
			return
		L.ghostize(FALSE)
	else if(L in GLOB.offered_mob_list)
		switch(alert("This mob has been offered, do you want to re-announce it?", "Offer Mob", "Yes", "Remove", "Cancel"))
			if("Cancel")
				return
			if("Remove")
				GLOB.offered_mob_list -= L
				log_admin("[key_name(usr)] has removed offer of [key_name_admin(M)].")
				message_admins("[ADMIN_TPMONTY(usr)] has removed offer of [ADMIN_TPMONTY(M)].")
				return

	else if(alert("Are you sure?", "Offer Mob", "Yes", "No") != "Yes")
		return

	L.offer_mob()

	log_admin("[key_name(usr)] has offered [key_name_admin(M)].")
	message_admins("[ADMIN_TPMONTY(usr)] has offered [ADMIN_TPMONTY(M)].")


/datum/admins/proc/change_hivenumber(mob/living/carbon/Xenomorph/X in GLOB.xeno_mob_list)
	set category = "Fun"
	set name = "Change Hivenumber"
	set desc = "Set the hivenumber of a xenomorph."

	if(!check_rights(R_FUN))
		return

	if(!istype(X))
		return

	var/hivenumber_status = X.hivenumber

	var/list/namelist = list()
	for(var/Y in GLOB.hive_datums)
		var/datum/hive_status/H = GLOB.hive_datums[Y]
		namelist += H.name

	var/newhive = input(src, "Select a hive.", null, null) in namelist

	var/newhivenumber
	switch(newhive)
		if("Normal")
			newhivenumber = XENO_HIVE_NORMAL
		if("Corrupted")
			newhivenumber = XENO_HIVE_CORRUPTED
		if("Alpha")
			newhivenumber = XENO_HIVE_ALPHA
		if("Beta")
			newhivenumber = XENO_HIVE_BETA
		if("Zeta")
			newhivenumber = XENO_HIVE_ZETA
		else
			return

	if(!istype(X) || X.gc_destroyed || !SSticker || X.hivenumber != hivenumber_status)
		return

	X.transfer_to_hive(newhivenumber)

	log_admin("[key_name(src)] changed hivenumber of [X] to [newhive].")
	message_admins("[ADMIN_TPMONTY(usr)] changed hivenumber of [ADMIN_TPMONTY(X)] to [newhive].")


/datum/admins/proc/release(obj/O in GLOB.object_list)
	set category = null
	set name = "Release Obj"

	if(!check_rights(R_FUN))
		return

	var/mob/M = usr

	if(!M.control_object || !M.name_archive)
		return

	M.real_name = M.name_archive
	M.name = M.real_name

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.name = H.get_visible_name()

	M.loc = O.loc
	M.control_object = null
	M.client.eye = M

	log_admin("[key_name(usr)] has released [O] ([O.type]).")
	message_admins("[ADMIN_TPMONTY(usr)] has released [O] ([O.type]).")


/datum/admins/proc/possess(obj/O in GLOB.object_list)
	set category = null
	set name = "Possess Obj"

	if(!check_rights(R_FUN))
		return

	var/mob/M = usr

	if(!M.control_object)
		M.name_archive = M.real_name

	M.loc = O
	M.real_name = O.name
	M.name = O.name
	M.control_object = O
	M.client.eye = O

	log_admin("[key_name(usr)] has possessed [O] ([O.type]).")
	message_admins("[ADMIN_TPMONTY(usr)] has possessed [O] ([O.type]).")


/client/proc/toggle_buildmode()
	set category = "Fun"
	set name = "Toggle Build Mode"

	if(!check_rights(R_FUN))
		return

	togglebuildmode(usr)