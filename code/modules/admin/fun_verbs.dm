/datum/admins/proc/set_view_range()
	set category = "Fun"
	set name = "Set View Range"

	if(!check_rights(R_FUN))
		return

	if(usr.client.view == world.view)
		var/newview = input("Select view range:", "Change View Range", 7) as null|num
		if(newview && newview != usr.client.view)
			usr.client.change_view(newview)
	else
		usr.client.change_view(world.view)

	log_admin("[key_name(usr)] changed their view range to [usr.client.view].")
	message_admins("[ADMIN_TPMONTY(usr)] changed their view range to [usr.client.view].")


/datum/admins/proc/gib_self()
	set name = "Gib Self"
	set category = "Fun"

	if(!check_rights(R_FUN))
		return

	if(istype(usr, /mob/dead/observer))
		return

	if(alert(usr, "Are you sure you want to gib yourself?", "Warning" , "Yes", "No") != "Yes")
		return

	if(!usr || istype(usr, /mob/dead/observer))
		return

	usr.gib()

	log_admin("[key_name(usr)] has gibbed themselves.")
	message_admins("[ADMIN_TPMONTY(usr)] has gibbed themselves.")


/datum/admins/proc/gib()
	set category = "Fun"
	set name = "Gib"

	if(!check_rights(R_FUN))
		return

	var/selection = input("Please, select a mob!", "Get Mob", null, null) as null|anything in sortmobs(GLOB.mob_living_list)
	if(!selection)
		return

	var/mob/living/M = selection

	if(alert(usr, "Are you sure you want to gib [M]?", "Warning", "Yes", "No") != "Yes")
		return

	log_admin("[key_name(usr)] has gibbed [key_name(M)].")
	message_admins("[ADMIN_TPMONTY(usr)] has gibbed [ADMIN_TPMONTY(M)].")

	M.gib()


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

	var/input = input("This should be a message from the ruler of the Xenomorph race.",, "") as message|null
	var/customname = input("What do you want it to be called?.",, "Queen Mother Psychic Directive")

	if(!input || !customname)
		return FALSE

	var/msg = "<h1>[customname]</h1><br><br><br><span class='warning'>[input]<br><br></span>"

	for(var/mob/M in GLOB.player_list)
		if(isxeno(M) || isobserver(M))
			to_chat(M, msg)

	log_admin("[key_name(usr)] created a Queen Mother report: [input]")
	message_admins("[ADMIN_TPMONTY(usr)] created a Queen Mother report.")


/datum/admins/proc/hive_status()
	set category = "Fun"
	set name = "Check Hive Status"
	set desc = "Check the status of the hive."

	if(!check_rights(R_FUN))
		return

	if(!ticker)
		return

	check_hive_status()

	log_admin("[key_name(usr)] checked the hive status.")
	message_admins("[ADMIN_TPMONTY(usr)] checked the hive status.")


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
		command_announcement.Announce(input, MAIN_AI_SYSTEM, new_sound = 'sound/misc/notice2.ogg')

	if(alert(usr, "Do you want to print out a paper at the communications consoles?",, "Yes", "No") == "Yes")
		for(var/obj/machinery/computer/communications/C in GLOB.machines)
			if(!(C.stat & (BROKEN|NOPOWER)))
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
			if(!(C.stat & (BROKEN|NOPOWER)))
				var/obj/item/paper/P = new /obj/item/paper(C.loc)
				P.name = "'[command_name()] Update.'"
				P.info = input
				P.update_icon()
				C.messagetitle.Add("[command_name()] Update")
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


/datum/admins/proc/narage_direct(var/mob/M)
	set category = "Fun"
	set name = "Direct Narrate"

	if(!check_rights(R_FUN))
		return

	var/msg = input("Enter the text you wish to appear to your target.", "Direct Narrate") as text
	if(!msg)
		return

	to_chat(M, "[msg]")

	log_admin("DirectNarrate: [key_name(usr)] to [key_name(M)]: [msg]")
	message_admins("[ADMIN_TPMONTY(usr)] used Direct Narrate on [ADMIN_TPMONTY(M)]: [msg]")


/datum/admins/proc/subtle_message(var/mob/M in GLOB.mob_list)
	set category = "Fun"
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


/datum/admins/proc/drop_everything()
	set category = "Fun"
	set name = "Drop Everything"

	if(!check_rights(R_FUN))
		return

	var/selection = input("Please, select a mob!", "Get Mob", null, null) as null|anything in sortmobs(GLOB.human_mob_list)
	if(!selection)
		return

	var/mob/living/carbon/human/H = selection

	if(alert(usr, "Make [H] drop everything?", "Warning", "Yes", "No") != "Yes")
		return

	for(var/obj/item/W in H)
		if(istype(W, /obj/item/alien_embryo))
			continue
		H.dropItemToGround(W)

	log_admin("[key_name(usr)] made [key_name(H)] drop everything.")
	message_admins("[ADMIN_TPMONTY(usr)] made [ADMIN_TPMONTY(H)] drop everything.")


/datum/admins/proc/award_medal()
	set category = "Fun"
	set name = "Award a Medal"

	if(!check_rights(R_FUN))
		return

	give_medal_award()


/datum/admins/proc/custom_info()
	set category = "Fun"
	set name = "Change Custom Event"

	if(!check_rights(R_FUN))
		return

	switch(input("Do you want to change or clear the custom event info?") as null|anything in list("Change", "Clear", "Cancel"))
		if("Change")
			custom_event_msg = input(usr, "Set the custom information players get on joining or via the OOC tab.",, custom_event_msg) as message|null

			custom_event_msg = noscript(custom_event_msg)

			if(!custom_event_msg)
				return

			to_chat(world, "<h1 class='alert'>Custom Information</h1>")
			to_chat(world, "<span class='alert'>[custom_event_msg]</span>")

			log_admin("[key_name(usr)] has changed the custom event text: [custom_event_msg]")
			message_admins("[ADMIN_TPMONTY(usr)] has changed the custom event text.")
		if("Clear")
			custom_event_msg = null
			log_admin("[key_name(usr)] has cleared the custom info.")
			message_admins("[ADMIN_TPMONTY(usr)] has cleared the custom info.")


/client/verb/custom_info()
	set category = "OOC"
	set name = "Custom Info"

	if(!custom_event_msg || custom_event_msg == "")
		to_chat(src, "<span class='notice'>There currently is no known custom information set.</span>")
		return

	to_chat(src, "<h1 class='alert'>Custom Information</h1>")
	to_chat(src, "<span class='alert'>[custom_event_msg]</span>")


/datum/admins/proc/sound_file(S as sound)
	set category = "Fun"
	set name = "Play Imported Sound"
	set desc = "Play a sound imported from anywhere on your computer."

	if(!check_rights(R_SOUND))
		return

	var/sound/uploaded_sound = sound(S, repeat = 0, wait = 1, channel = 777)
	uploaded_sound.priority = 250


	var/style = alert("Play sound globally or locally?", "Sound", "Global", "Local", "Cancel")
	switch(style)
		if("Global")
			for(var/mob/M in GLOB.player_list)
				if(M.client.prefs.toggles_sound & SOUND_MIDI)
					M << uploaded_sound
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
	var/pitch
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
				var/title = "[data["title"]]"
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
				C.chatOutput.sendMusic(web_sound_url, pitch)
				if(show)
					to_chat(C, "<span class='boldnotice'>An admin played: [show]</span>")

		log_admin("[key_name(usr)] played web sound: [web_sound_input] - [title] - [style]")
		message_admins("[ADMIN_TPMONTY(usr)] played web sound: [web_sound_input] - [title] - [style]")


/datum/admins/proc/sound_stop()
	set category = "Fun"
	set name = "Stop All Playing Sounds"

	if(!check_rights(R_SOUND))
		return

	log_admin("[key_name(usr)] stopped all currently playing sounds.")
	message_admins("[ADMIN_TPMONTY(usr)] stopped all currently playing sounds.")
	for(var/mob/M in GLOB.player_list)
		if(M.client)
			SEND_SOUND(M, sound(null))
			var/client/C = M.client
			if(C?.chatOutput && !C.chatOutput.broken && C.chatOutput.loaded)
				C.chatOutput.stopMusic()


/datum/admins/proc/announce()
	set category = "Fun"
	set name = "Announce"
	set desc = "Announce your desires to the world."

	if(!check_rights(R_FUN))
		return

	var/message = input("Global message to send:", "Admin Announce") as message|null

	message = noscript(message)

	if(!message)
		return

	log_admin("AdminAnnounce: [key_name(usr)] : [message]")
	message_admins("[ADMIN_TPMONTY(usr)] Announces:")
	to_chat(world, "<span class='notice'><b>[usr.client.holder.fakekey ? "Administrator" : "[usr.client.key] ([usr.client.holder.rank])"] Announces:</b>\n [message]</span>")


/datum/admins/proc/force_distress()
	set category = "Fun"
	set name = "Distress Beacon"
	set desc = "Call a distress beacon manually."

	if(!check_rights(R_FUN))
		return

	if(!ticker?.mode)
		to_chat(src, "<span class='warning'>Please wait for the round to begin first.</span>")

	if(ticker.mode.waiting_for_candidates)
		to_chat(src, "<span class='warning'>Please wait for the current beacon to be finalized.</span>")
		return

	if(ticker.mode.picked_call)
		ticker.mode.picked_call.members = list()
		ticker.mode.picked_call.candidates = list()
		ticker.mode.waiting_for_candidates = FALSE
		ticker.mode.on_distress_cooldown = FALSE
		ticker.mode.picked_call = null

	var/list/list_of_calls = list()
	for(var/datum/emergency_call/L in ticker.mode.all_calls)
		if(L.name)
			list_of_calls += L.name

	list_of_calls += "Randomize"

	var/choice = input("Which distress do you want to call?") as null|anything in list_of_calls
	if(!choice)
		return

	if(choice == "Randomize")
		ticker.mode.picked_call	= ticker.mode.get_random_call()
	else
		for(var/datum/emergency_call/C in ticker.mode.all_calls)
			if(C.name == choice)
				ticker.mode.picked_call = C
				break

	if(!istype(ticker.mode.picked_call))
		return

	var/max = input("What should the maximum amount of mobs be?", "Max Mobs", 20) as null|num
	if(!max || max < 1)
		return

	ticker.mode.picked_call.mob_max = max

	var/min = input("What should the minimum amount of mobs be?", "Min Mobs", 1) as null|num
	if(!min || min < 1)
		return

	ticker.mode.picked_call.mob_min = min

	var/is_announcing = TRUE
	if(alert(usr, "Would you like to announce the distress beacon to the server population? This will reveal the distress beacon to all players.", "Announce distress beacon?", "Yes", "No") != "Yes")
		is_announcing = FALSE

	ticker.mode.picked_call.activate(is_announcing)

	log_admin("[key_name(usr)] called a [choice == "Randomize" ? "randomized ":""]distress beacon: [ticker.mode.picked_call.name]. Min: [min], Max: [max].")
	message_admins("[ADMIN_TPMONTY(usr)] called a [choice == "Randomize" ? "randomized ":""]distress beacon: [ticker.mode.picked_call.name] Min: [min], Max: [max].")


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

	var/datum/shuttle/ferry/marine/dropship = shuttle_controller.shuttles[MAIN_SHIP_NAME + " " + tag]

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

	if(!ticker?.mode)
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
	var/dock_name = input("Where on the [MAIN_SHIP_NAME] should the shuttle dock?", "Select a docking zone:") as null|anything in dock_list
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
	set category = "Fun"
	set name = "Object Sound"
	set desc = "Display a message to everyone who can hear the target"

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
			var/devastation_range = input("Devastation range (in tiles):") as num
			var/heavy_impact_range = input("Heavy impact range (in tiles):") as num
			var/light_impact_range = input("Light impact range (in tiles):") as num
			var/flash_range = input("Flash range (in tiles):") as num
			explosion(M.loc, devastation_range, heavy_impact_range, light_impact_range, flash_range)

	log_admin("[key_name(usr)] dropped a bomb at [AREACOORD(M.loc)].")
	message_admins("[ADMIN_TPMONTY(usr)] dropped a bomb at [ADMIN_VERBOSEJMP(M.loc)].")


/datum/admins/proc/change_security_level()
	set category = "Fun"
	set name = "Set Security Level"

	if(!check_rights(R_FUN))
		return

	var/sec_level = input(usr, "It's currently code [get_security_level()].", "Select Security Level")  as null|anything in (list("green","blue","red","delta")-get_security_level())
	if(!sec_level || alert("Switch from code [get_security_level()] to code [sec_level]?", "Change security level?", "Yes", "No") != "Yes")
		return

	set_security_level(sec_level)

	log_admin("[key_name(usr)] changed the security level to code [sec_level].")
	message_admins("[ADMIN_TPMONTY(usr)] changed the security level to code [sec_level].")


/datum/admins/proc/select_rank(var/mob/living/carbon/human/H in GLOB.human_mob_list)
	set category = "Fun"
	set name = "Select Rank"

	if(!istype(H))
		return

	switch(alert("Modify the rank or give them a new one?", "Select Rank", "New Rank", "Modify", "Cancel"))
		if("New Rank")
			var/newrank = input("Select new rank for [H]", "Change the mob's rank and skills") as null|anything in sortList(RoleAuthority.roles_by_name)
			if(!newrank)
				return

			if(!H?.mind)
				return

			H.set_everything(H, newrank)
			log_admin("[key_name(usr)] has set the rank of [key_name(H)] to [newrank].")
			message_admins("[ADMIN_TPMONTY(usr)] has set the rank of [ADMIN_TPMONTY(H)] to [newrank].")
		if("Modify")
			var/obj/item/card/id/I = H.wear_id
			if(!istype(I) || I != H.wear_id)
				H.wear_id = new /obj/item/card/id(H)
			switch(input("What do you want to edit?") as null|anything in list("Comms Title - \[Engineering (Title)]", "Chat Title - Title John Doe screams!", "ID title - Jane Doe's ID Card (Title)", "Registered Name - Jane Doe's ID Card", "Skills"))
				if("Comms Title - \[Engineering (Title)]")
					var/commtitle = input("Write the custom title appearing on the comms themselves, for example: \[Command (Title)]", "Comms title") as null|text
					if(!commtitle || !H?.mind)
						return
					H.mind.role_comm_title = commtitle
				if("Chat Title - Title John Doe screams!")
					var/chattitle = input("Write the custom title appearing in all chats: Title Jane Doe screams!", "Chat title") as null|text
					if(chattitle || !H)
						return
					if(!istype(I) || I != H.wear_id)
						H.wear_id = new /obj/item/card/id(H)
					I.paygrade = chattitle
				if("ID title - Jane Doe's ID Card (Title)")
					var/idtitle = input("Write the custom title appearing on the ID itself: Jane Doe's ID Card (Title)", "ID title") as null|text
					if(!H || I != H.wear_id)
						return
					if(!istype(I) || I != H.wear_id)
						H.wear_id = new /obj/item/card/id(H)
					I.rank = idtitle
					I.assignment = idtitle
					I.name = "[I.registered_name]'s ID Card[idtitle ? " ([I.assignment])" : ""]"
				if("Registered Name - Jane Doe's ID Card")
					var/regname = input("Write the name appearing on the ID itself: Jane Doe's ID Card", "Registered Name") as null|text
					if(!H || I != H.wear_id)
						return
					if(!istype(I) || I != H.wear_id)
						H.wear_id = new /obj/item/card/id(H)
					I.registered_name = regname
					I.name = "[regname]'s ID Card ([I.assignment])"
				if("Skills")
					var/newskillset = input("Select a skillset", "Skill Set") as null|anything in RoleAuthority.roles_by_name
					if(!newskillset || !H?.mind)
						return
					var/datum/job/J = RoleAuthority.roles_by_name[newskillset]
					H.mind.set_cm_skills(J.skills_type)
				else
					return

			log_admin("[key_name(usr)] has made a custom rank/skill change for [key_name(H)].")
			message_admins("[ADMIN_TPMONTY(usr)] has made a custom rank/skill change for [ADMIN_TPMONTY(H)].")


/datum/admins/proc/select_equipment(var/mob/living/carbon/human/M in GLOB.human_mob_list)
	set category = "Fun"
	set name = "Select Equipment"

	if(!ishuman(M))
		return

	var/list/dresspacks = sortList(RoleAuthority.roles_by_equipment)

	var/dresscode = input("Choose equipment for [M]", "Select Equipment") as null|anything in dresspacks
	if(!dresscode)
		return

	for(var/obj/item/I in M)
		if(istype(I, /obj/item/implant) || istype(I, /obj/item/card/id))
			continue
		qdel(I)

	var/datum/job/J = dresspacks[dresscode]
	J.generate_equipment(M)
	M.regenerate_icons()

	log_admin("[key_name(usr)] changed the equipment of [key_name(M)] to [dresscode].")
	message_admins("[ADMIN_TPMONTY(usr)] changed the equipment of [ADMIN_TPMONTY(M)] to [dresscode].")


/datum/admins/proc/possess(obj/O as obj in GLOB.object_list)
	set category = "Object"
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


/datum/admins/proc/release(obj/O as obj in GLOB.object_list)
	set category = "Object"
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