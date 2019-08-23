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

	var/heavy = input("Range of heavy pulse.", "EM Pulse") as num|null
	if(isnull(heavy))
		return

	var/light = input("Range of light pulse.", "EM Pulse") as num|null
	if(isnull(light))
		return

	heavy = CLAMP(heavy, 0, 10000)
	light = CLAMP(light, 0, 10000)

	empulse(usr, heavy, light)

	log_admin("[key_name(usr)] created an EM Pulse ([heavy], [light]) at [AREACOORD(usr.loc)].")
	message_admins("[ADMIN_TPMONTY(usr)] created an EM Pulse ([heavy], [light]) at [ADMIN_VERBOSEJMP(usr.loc)].")


/datum/admins/proc/queen_report()
	set category = "Fun"
	set name = "Queen Mother Report"

	if(!check_rights(R_FUN))
		return

	var/customname = input("What do you want it to be called?.", "Queen Mother Report", "Queen Mother")
	var/input = input("This should be a message from the ruler of the Xenomorph race.", "Queen Mother Report", "") as message|null
	if(!input || !customname)
		return

	var/msg = "<br><h2 class='alert'>[customname]</h2><br><span class='warning'>[input]</span><br><br>"

	for(var/i in (GLOB.xeno_mob_list + GLOB.observer_list))
		var/mob/M = i
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

	var/customname = input("What do you want the AI to be called?.", "AI Report", "AI") as text|null
	var/input = input("This should be a message from the ship's AI.", "AI Report") as message|null
	if(!input || !customname)
		return

	var/paper
	switch(alert(usr, "Do you want to print out a paper at the communications consoles?", "AI Report", "Yes", "No", "Cancel"))
		if("Yes")
			paper = TRUE
		if("Cancel")
			return

	priority_announce(input, customname, sound = "sound/misc/interference.ogg")

	if(paper)
		print_command_report(input, "[customname] Update", announce = FALSE)

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
		print_command_report(input, "[SSmapping.configs[SHIP_MAP].map_name] Update", announce = FALSE)

	switch(alert("Should this be announced to the general population?", "Announce", "Yes", "No", "Cancel"))
		if("Yes")
			priority_announce(input, customname, sound = 'sound/AI/commandreport.ogg');
		if("No")
			priority_announce("New update available at all communication consoles.", type = ANNOUNCEMENT_COMMAND, sound = 'sound/AI/commandreport.ogg')
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

	to_chat(world, msg)

	log_admin("GlobalNarrate: [key_name(usr)] : [msg]")
	message_admins("[ADMIN_TPMONTY(usr)] used Global Narrate: [msg]")


/datum/admins/proc/narage_direct(mob/M in GLOB.mob_list)
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


/datum/admins/proc/subtle_message(mob/M in GLOB.player_list)
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

	var/new_info = input(usr, "Set the custom information players get on joining or via the OOC tab.", "Custom Info", GLOB.custom_info) as message|null
	new_info = noscript(new_info)
	if(isnull(new_info) || GLOB.custom_info == new_info)
		return

	if(!new_info)
		log_admin("[key_name(usr)] has cleared the custom info.")
		message_admins("[ADMIN_TPMONTY(usr)] has cleared the custom info.")
		return

	GLOB.custom_info = new_info

	to_chat(world, "<h1 class='alert'>Custom Information</h1>")
	to_chat(world, "<span class='alert'>[GLOB.custom_info]</span>")

	log_admin("[key_name(usr)] has changed the custom event text: [GLOB.custom_info]")
	message_admins("[ADMIN_TPMONTY(usr)] has changed the custom event text.")


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
			if((C.prefs.toggles_sound & SOUND_MIDI) && C.chatOutput?.working && C.chatOutput.loaded)
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
		if(!C?.chatOutput.loaded || !C.chatOutput.working)
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
		SSticker.mode.picked_call.reset()
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

	var/max = input("What should the maximum amount of mobs be?", "Max Mobs", SSticker.mode.picked_call.mob_max) as null|num
	if(!max || max < 1)
		return

	SSticker.mode.picked_call.mob_max = max

	var/min = input("What should the minimum amount of mobs be?", "Min Mobs", SSticker.mode.picked_call.mob_min) as null|num
	if(!min || min < 1)
		return

	SSticker.mode.picked_call.mob_min = min

	var/is_announcing = TRUE
	if(alert(usr, "Would you like to announce the distress beacon to the server population? This will reveal the distress beacon to all players.", "Announce distress beacon?", "Yes", "No") != "Yes")
		is_announcing = FALSE

	SSticker.mode.picked_call.activate(is_announcing)

	log_admin("[key_name(usr)] called a [choice == "Randomize" ? "randomized ":""]distress beacon: [SSticker.mode.picked_call.name]. Min: [min], Max: [max].")
	message_admins("[ADMIN_TPMONTY(usr)] called a [choice == "Randomize" ? "randomized ":""]distress beacon: [SSticker.mode.picked_call.name] Min: [min], Max: [max].")


/datum/admins/proc/object_sound(atom/O as obj)
	set category = null
	set name = "Object Sound"

	if(!check_rights(R_FUN))
		return

	if(!O)
		return

	var/message = input("What do you want the message to be?", "Object Sound") as text|null
	if(!message)
		return

	var/method = input("What do you want the verb to be? Make sure to include s if applicable.", "Object Sound") as text|null
	if(!method)
		return

	O.audible_message("<b>[O]</b> [method], \"[message]\"")
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

	var/choice = input("What size explosion would you like to produce?", "Drop Bomb") as null|anything in list("CANCEL", "Small Bomb", "Medium Bomb", "Big Bomb", "Custom Bomb")
	switch(choice)
		if("CANCEL")
			return
		if("Small Bomb")
			explosion(usr.loc, 1, 2, 3, 3)
		if("Medium Bomb")
			explosion(usr.loc, 2, 3, 4, 4)
		if("Big Bomb")
			explosion(usr.loc, 3, 5, 7, 5)
		if("Custom Bomb")
			var/devastation_range = input("Devastation range (in tiles):", "Drop Bomb") as null|num
			var/heavy_impact_range = input("Heavy impact range (in tiles):", "Drop Bomb") as null|num
			var/light_impact_range = input("Light impact range (in tiles):", "Drop Bomb") as null|num
			var/flash_range = input("Flash range (in tiles):", "Drop Bomb") as null|num
			if(isnull(devastation_range) || isnull(heavy_impact_range) || isnull(light_impact_range) || isnull(flash_range))
				return
			devastation_range = CLAMP(devastation_range, -1, 10000)
			heavy_impact_range = CLAMP(heavy_impact_range, -1, 10000)
			light_impact_range = CLAMP(light_impact_range, -1, 10000)
			flash_range = CLAMP(flash_range, -1, 10000)
			explosion(usr.loc, devastation_range, heavy_impact_range, light_impact_range, flash_range)
		else
			return

	log_admin("[key_name(usr)] dropped a bomb at [AREACOORD(usr.loc)].")
	message_admins("[ADMIN_TPMONTY(usr)] dropped a bomb at [ADMIN_VERBOSEJMP(usr.loc)].")


/datum/admins/proc/change_security_level()
	set category = "Fun"
	set name = "Set Security Level"

	if(!check_rights(R_FUN))
		return

	var/sec_level = input(usr, "It's currently code [GLOB.marine_main_ship.get_security_level()]. Choose the new security level.", "Set Security Level") as null|anything in (list("green", "blue", "red", "delta") - GLOB.marine_main_ship.get_security_level())
	if(!sec_level)
		return

	if(alert("Switch from code [GLOB.marine_main_ship.get_security_level()] to code [sec_level]?", "Set Security Level", "Yes", "No") != "Yes")
		return

	GLOB.marine_main_ship.set_security_level(sec_level)

	log_admin("[key_name(usr)] changed the security level to code [sec_level].")
	message_admins("[ADMIN_TPMONTY(usr)] changed the security level to code [sec_level].")


/datum/admins/proc/rank_and_equipment(mob/living/carbon/human/H in GLOB.human_mob_list)
	set category = "Fun"
	set name = "Rank and Equipment"

	if(!check_rights(R_FUN))
		return

	var/dat = "<br>"
	var/obj/item/card/id/C = H.wear_id

	if(!H.mind)
		dat += "No mind! <a href='?src=[REF(usr.client.holder)];[HrefToken()];rank=createmind;mob=[REF(H)]'>Create</a><br>"
		dat += "Take-over job: [H.job ? H.job : "None"] <a href='?src=[REF(usr.client.holder)];[HrefToken()];rank=rank;mob=[REF(H)]'>Edit</a><br>"
		if(H.job in GLOB.jobs_marines)
			dat += "Squad: [H.assigned_squad] <a href='?src=[REF(usr.client.holder)];[HrefToken()];rank=squad;mob=[REF(H)]'>Edit</a><br>"
	else
		dat += "Job: [H.mind.assigned_role] <a href='?src=[REF(usr.client.holder)];[HrefToken()];rank=rank;mob=[REF(H)]'>Edit</a> "
		dat += "<a href='?src=[REF(usr.client.holder)];[HrefToken()];rank=rank;doequip=1;mob=[REF(H)]'>Edit and Equip</a> "
		dat += "<a href='?src=[REF(usr.client.holder)];[HrefToken()];rank=rank;doset=1;mob=[REF(H)]'>Edit and Set</a><br>"
		dat += "<br>"
		dat += "Skillset: [H.mind.cm_skills.name] <a href='?src=[REF(usr.client.holder)];[HrefToken()];rank=skills;mob=[REF(H)]'>Edit</a><br>"
		dat += "Comms title: [H.mind.comm_title] <a href='?src=[REF(usr.client.holder)];[HrefToken()];rank=commstitle;mob=[REF(H)]'>Edit</a><br>"
		if(H.mind.assigned_role in GLOB.jobs_marines)
			dat += "Squad: [H.assigned_squad] <a href='?src=[REF(usr.client.holder)];[HrefToken()];rank=squad;mob=[REF(H)]'>Edit</a><br>"
	if(istype(C))
		dat += "<br>"
		dat += "Chat title: [get_paygrades(C.paygrade, FALSE, H.gender)] <a href='?src=[REF(usr.client.holder)];[HrefToken()];rank=chattitle;mob=[REF(H)];id=[REF(C)]'>Edit</a><br>"
		dat += "ID title: [C.assignment] <a href='?src=[REF(usr.client.holder)];[HrefToken()];rank=idtitle;mob=[REF(H)];id=[REF(C)]'>Edit</a><br>"
		dat += "ID name: [C.registered_name] <a href='?src=[REF(usr.client.holder)];[HrefToken()];rank=idname;mob=[REF(H)];id=[REF(C)]'>Edit</a><br>"
		dat += "Access: [get_access_job_name(C)] <a href='?src=[REF(usr.client.holder)];[HrefToken()];rank=access;mob=[REF(H)];id=[REF(C)]'>Edit</a><br>"
	else
		dat += "No ID! <a href='?src=[REF(usr.client.holder)];[HrefToken()];rank=createid;mob=[REF(H)]'>Give ID</a><br>"

	dat += "<br>"
	dat += "<a href='?src=[REF(usr.client.holder)];[HrefToken()];rank=equipment;mob=[REF(H)]'>Select Equipment</a>"


	var/datum/browser/browser = new(usr, "edit_rank_[key_name(H)]", "<div align='center'>Edit Rank [key_name(H)]</div>", 400, 350)
	browser.set_content(dat)
	browser.open(FALSE)


/datum/admins/proc/outfit_manager()
	set category = "Fun"
	set name = "Outfit Manager"

	if(!check_rights(R_FUN))
		return

	var/dat = "<ul>"
	for(var/datum/outfit/O in GLOB.custom_outfits)
		var/vv = FALSE
		var/datum/outfit/varedit/VO = O
		if(istype(VO))
			vv = length(VO.vv_values)
		dat += "<li>[O.name][vv ? "(VV)" : ""]</li> <a href='?src=holder;[HrefToken()];save_outfit=1;chosen_outfit=[REF(O)]'>Save</a> <a href='?src=holder;[HrefToken()];delete_outfit=1;chosen_outfit=[REF(O)]'>Delete</a>"
	dat += "</ul>"
	dat += "<a href='?_src_=holder;[HrefToken()];create_outfit_menu=1'>Create</a><br>"
	dat += "<a href='?_src_=holder;[HrefToken()];load_outfit=1'>Load from file</a>"

	var/datum/browser/browser = new(usr, "outfitmanager", "<div align='center'>Outfit Manager</div>")
	browser.set_content(dat)
	browser.open(FALSE)


/datum/admins/proc/create_outfit()
	if(!check_rights(R_FUN))
		return

	var/dat = {"<div>Input typepaths and watch the magic happen.</div>
	<form name="outfit" action="byond://?src=[REF(usr.client.holder)];[HrefToken()]" method="get">
	<input type="hidden" name="src" value="[REF(usr.client.holder)];[HrefToken()]">
	[HrefTokenFormField()]
	<input type="hidden" name="create_outfit_finalize" value="1">
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
	</form>"}

	var/datum/browser/browser = new(usr, "create_outfit", "<div align='center'>Create Outfit</div>", 550, 600)
	browser.set_content(dat)
	browser.open()


/datum/admins/proc/edit_appearance(mob/living/carbon/human/H in GLOB.human_mob_list)
	set category = "Fun"
	set name = "Edit Appearance"

	if(!check_rights(R_FUN))
		return

	if(!istype(H))
		return

	var/hcolor = "#[num2hex(H.r_hair)][num2hex(H.g_hair)][num2hex(H.b_hair)]"
	var/fcolor = "#[num2hex(H.r_facial)][num2hex(H.g_facial)][num2hex(H.b_facial)]"
	var/ecolor = "#[num2hex(H.r_eyes)][num2hex(H.g_eyes)][num2hex(H.b_eyes)]"
	var/bcolor = "#[num2hex(H.r_skin)][num2hex(H.g_skin)][num2hex(H.b_skin)]"

	var/dat = "<br>"

	dat += "Hair style: [H.h_style] <a href='?src=[REF(usr.client.holder)];[HrefToken()];appearance=hairstyle;mob=[REF(H)]'>Edit</a><br>"
	dat += "Hair color: <font face='fixedsys' size='3' color='[hcolor]'><table style='display:inline;' bgcolor='[hcolor]'><tr><td>_.</td></tr></table></font> <a href='?src=[REF(usr.client.holder)];[HrefToken()];appearance=haircolor;mob=[REF(H)]'>Edit</a><br>"
	dat += "<br>"
	dat += "Facial hair style: [H.f_style] <a href='?src=[REF(usr.client.holder)];[HrefToken()];appearance=facialhairstyle;mob=[REF(H)]'>Edit</a><br>"
	dat += "Facial hair color: <font face='fixedsys' size='3' color='[fcolor]'><table style='display:inline;' bgcolor='[fcolor]'><tr><td>_.</td></tr></table></font> <a href='?src=[REF(usr.client.holder)];[HrefToken()];appearance=facialhaircolor;mob=[REF(H)]'>Edit</a><br>"
	dat += "<br>"
	dat += "Eye color: <font face='fixedsys' size='3' color='[ecolor]'><table style='display:inline;' bgcolor='[ecolor]'><tr><td>_.</td></tr></table></font> <a href='?src=[REF(usr.client.holder)];[HrefToken()];appearance=eyecolor;mob=[REF(H)]'>Edit</a><br>"
	dat += "Body color: <font face='fixedsys' size='3' color='[bcolor]'><table style='display:inline;' bgcolor='[bcolor]'><tr><td>_.</td></tr></table></font> <a href='?src=[REF(usr.client.holder)];[HrefToken()];appearance=bodycolor;mob=[REF(H)]'>Edit</a><br>"
	dat += "<br>"
	dat += "Gender: [H.gender] <a href='?src=[REF(usr.client.holder)];[HrefToken()];appearance=gender;mob=[REF(H)]'>Edit</a><br>"
	dat += "Ethnicity: [H.ethnicity] <a href='?src=[REF(usr.client.holder)];[HrefToken()];appearance=ethnicity;mob=[REF(H)]'>Edit</a><br>"
	dat += "Species: [H.species] <a href='?src=[REF(usr.client.holder)];[HrefToken()];appearance=species;mob=[REF(H)]'>Edit</a><br>"

	var/datum/browser/browser = new(usr, "edit_appearance_[key_name(H)]", "<div align='center'>Edit Appearance [key_name(H)]</div>")
	browser.set_content(dat)
	browser.open(FALSE)


/datum/admins/proc/offer(mob/living/L in GLOB.mob_living_list)
	set category = "Fun"
	set name = "Offer Mob"

	if(!check_rights(R_FUN))
		return

	if(L.client)
		if(alert("This mob has a player inside, are you sure you want to proceed?", "Offer Mob", "Yes", "No") != "Yes")
			return
		L.ghostize(FALSE)
		
	else if(L in GLOB.offered_mob_list)
		switch(alert("This mob has been offered, do you want to re-announce it?", "Offer Mob", "Yes", "Remove", "Cancel"))
			if("Cancel")
				return
			if("Remove")
				GLOB.offered_mob_list -= L
				log_admin("[key_name(usr)] has removed offer of [key_name_admin(L)].")
				message_admins("[ADMIN_TPMONTY(usr)] has removed offer of [ADMIN_TPMONTY(L)].")
				return

	else if(alert("Are you sure you want to offer this mob?", "Offer Mob", "Yes", "No") != "Yes")
		return

	if(!istype(L))
		to_chat(usr, "<span class='warning'>Target is no longer valid.</span>")
		return

	L.offer_mob()

	log_admin("[key_name(usr)] has offered [key_name_admin(L)].")
	message_admins("[ADMIN_TPMONTY(usr)] has offered [ADMIN_TPMONTY(L)].")


/datum/admins/proc/xeno_panel(mob/living/carbon/xenomorph/X in GLOB.xeno_mob_list)
	set category = "Fun"
	set name = "Xeno Panel"

	if(!check_rights(R_FUN))
		return

	if(!istype(X))
		return

	var/dat = "<br>"

	dat += "Hive: [X.hive.hivenumber] <a href='?src=[REF(usr.client.holder)];[HrefToken()];xeno=hive;mob=[REF(X)]'>Edit</a><br>"
	dat += "Nicknumber: [X.nicknumber] <a href='?src=[REF(usr.client.holder)];[HrefToken()];xeno=nicknumber;mob=[REF(X)]'>Edit</a><br>"
	dat += "Upgrade Tier: [X.xeno_caste.upgrade_name] <a href='?src=[REF(usr.client.holder)];[HrefToken()];xeno=upgrade;mob=[REF(X)]'>Edit</a><br>"

	var/datum/browser/browser = new(usr, "xeno_panel_[key_name(X)]", "<div align='center'>Xeno Panel [key_name(X)]</div>")
	browser.set_content(dat)
	browser.open(FALSE)



/datum/admins/proc/release(obj/OB in world)
	set category = null
	set name = "Release Obj"

	if(!check_rights(R_FUN))
		return

	var/mob/M = usr

	if(!M.control_object)
		return

	var/obj/O = M.control_object

	var/datum/player_details/P = GLOB.player_details[M.ckey]

	M.real_name = P.played_names[length(P.played_names)]
	M.name = M.real_name

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.name = H.get_visible_name()

	M.loc = get_turf(M.control_object)
	M.reset_perspective()
	M.control_object = null

	log_admin("[key_name(usr)] has released [O] ([O.type]).")
	message_admins("[ADMIN_TPMONTY(usr)] has released [O] ([O.type]).")


/datum/admins/proc/possess(obj/O in world)
	set category = null
	set name = "Possess Obj"

	if(!check_rights(R_FUN))
		return

	var/mob/M = usr

	M.loc = O
	M.real_name = O.name
	M.name = O.name
	M.reset_perspective()
	M.control_object = O

	log_admin("[key_name(usr)] has possessed [O] ([O.type]).")
	message_admins("[ADMIN_TPMONTY(usr)] has possessed [O] ([O.type]).")


/client/proc/toggle_buildmode()
	set category = "Fun"
	set name = "Toggle Build Mode"

	if(!check_rights(R_FUN))
		return

	togglebuildmode(usr)


/datum/admins/proc/imaginary_friend()
	set category = "Fun"
	set name = "Imaginary Friend"

	if(!check_rights(R_FUN|R_MENTOR))
		return

	var/client/C = usr.client

	if(istype(C.mob, /mob/camera/imaginary_friend))
		var/mob/camera/imaginary_friend/IF = C.mob
		IF.ghostize()
		return

	if(!isobserver(C.mob))
		if(is_mentor(C))
			to_chat(C, "<span class='warning'>Can only become an imaginary friend while observing.</span>")
			return
		C.holder.admin_ghost()

	var/mob/living/L = C.holder.apicker("Select by:", "Imaginary Friend", list(APICKER_CLIENT, APICKER_LIVING))
	if(!istype(L) || !isobserver(C.mob))
		return

	var/mob/camera/imaginary_friend/IF = new(get_turf(L), L)
	C.mob.mind.transfer_to(IF)

	log_admin("[key_name(IF)] started being imaginary friend of [key_name(L)].")
	message_admins("[ADMIN_TPMONTY(IF)] started being imaginary friend of [ADMIN_TPMONTY(L)].")


/datum/admins/proc/force_dropship()
	set category = "Fun"
	set name = "Force Dropship"

	if(!check_rights(R_FUN))
		return

	if(!length(SSshuttle.dropships) && !SSshuttle.canterbury)
		return

	var/list/available_shuttles = list()
	for(var/i in SSshuttle.mobile)
		var/obj/docking_port/mobile/M = i
		available_shuttles["[M.name] ([M.id])"] = M.id

	var/answer = input(usr, "Which shuttle do you want to move?", "Force Dropship") as null|anything in available_shuttles
	var/shuttle_id = available_shuttles[answer]
	if(!shuttle_id)
		return

	var/obj/docking_port/mobile/D
	for(var/i in SSshuttle.mobile)
		var/obj/docking_port/mobile/M = i
		if(M.id == shuttle_id)
			D = M

	if(!D)
		to_chat(usr, "<span class='warning'>Unable to find shuttle</span>")
		return

	if(D.mode != SHUTTLE_IDLE && alert("[D.name] is not idle, move anyway?", "Force Dropship", "Yes", "No") != "Yes")
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
		to_chat(usr, "<span class='warning'>No valid destinations found!</span>")
		return

	var/dock = input("Choose the destination.", "Force Dropship") as null|anything in valid_docks
	if(!dock)
		return

	var/obj/docking_port/stationary/target = valid_docks[dock]
	if(!target)
		return

	var/instant = FALSE
	if(alert("Do you want to move the [D.name] instantly?", "Force Dropship", "Yes", "No") == "Yes")
		instant = TRUE

	SSshuttle.moveShuttleToDock(D.id, target, !instant)

	log_admin("[key_name(usr)] has moved [D.name] ([D.id]) to [target] ([target.id])[instant ? " instantly" : ""].")
	message_admins("[ADMIN_TPMONTY(usr)] has moved [D.name] ([D.id]) to [target] ([target.id])[instant ? " instantly" : ""].")


/datum/admins/proc/play_cinematic()
	set category = "Fun"
	set name = "Play Cinematic"

	if(!check_rights(R_FUN))
		return

	var/datum/cinematic/choice = input(usr, "Choose a cinematic to play.", "Play Cinematic") as anything in subtypesof(/datum/cinematic)
	if(!choice)
		return

	Cinematic(initial(choice.id), world)

	log_admin("[key_name(usr)] played the [choice] cinematic.")
	message_admins("[ADMIN_TPMONTY(usr)] played the [choice] cinematic.")


/datum/admins/proc/set_tip()
	set category = "Fun"
	set name = "Set Tip"

	if(!check_rights(R_FUN))
		return

	var/tip = input(usr, "Please specify your tip that you want to send to the players.", "Tip") as message|null
	if(!tip)
		return

	SSticker.selected_tip = tip

	//If we've already tipped, then send it straight away.
	if(SSticker.tipped)
		SSticker.send_tip_of_the_round()

	log_admin("[key_name(usr)] set a tip of the round: [tip]")
	message_admins("[ADMIN_TPMONTY(usr)] set a tip of the round.")
