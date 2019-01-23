/datum/admins/proc/set_view_range()
	set category = "Fun"
	set name = "Set View Range"

	if(!check_rights(R_FUN))
		return

	if(usr.client.view == world.view)
		var/newview = input("Select view range:", "Change View Range", 7) as null|num
		if(newview && newview != owner.view)
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

	if(!owner.mob || istype(owner.mob, /mob/dead/observer))
		return

	if(alert(usr, "Are you sure?",, "Yes", "No") != "Yes")
		return

	if(!owner.mob || istype(owner.mob, /mob/dead/observer))
		return

	owner.mob.gib()

	log_admin("[key_name(usr)] has gibbed themselves.")
	message_admins("[ADMIN_TPMONTY(usr)] has gibbed themselves.")


/datum/admins/proc/gib(mob/living/M as mob in mob_list)
	set category = "Fun"
	set name = "Gib"

	if(!check_rights(R_FUN))
		return

	if(alert(src, "Are you sure?",, "Yes", "No") != "Yes")
		return

	if(!M)
		return

	M.gib()

	log_admin("[key_name(usr)] has gibbed [key_name(M)].")
	message_admins("[ADMIN_TPMONTY(usr)] has gibbed [ADMIN_TPMONTY(M)].")


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

	var/input = input(usr, "This should be a message from the ruler of the Xenomorph race.",, "") as message|null
	var/customname = input(usr, "What do you want it to be called?.",, "Queen Mother Psychic Directive") as message|null

	if(!input || !customname)
		return FALSE

	var/msg = "<h1>[customname]</h1><br><br><br><span class='warning'>[input]<br><br></span>"

	for(var/mob/M in player_list)
		if(isXeno(M) || isobserver(M))
			to_chat(M, msg)

	log_admin("[key_name(usr)] created a Queen Mother report: [input]")
	message_admins("[ADMIN_TPMONTY(usr)] created a Queen Mother report.")


/datum/admins/proc/hive_status()
	set category = "Fun"
	set name = "Show Hive Status"
	set desc = "Check the status of the hive."

	if(!check_rights(R_FUN))
		return

	check_hive_status()

	log_admin("[key_name(usr)] checked the hive status.")
	message_admins("[ADMIN_TPMONTY(usr)] checked the hive status.")


/datum/admins/proc/ai_report()
	set category = "Fun"
	set name = "AI Report"

	if(!check_rights(R_FUN))
		return

	var/input = input(usr, "This should be a message from the ship's AI.",, "") as message|null
	if(!input)
		return

	if(!ai_system.Announce(input))
		return

	for(var/obj/machinery/computer/communications/C in machines)
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

	var/input = input(usr, "Please enter anything you want. Anything. Serious.", "What?", "") as message|null
	var/customname = input(usr, "Pick a title for the report.", "Title") as text|null

	if(!input)
		return

	if(!customname)
		customname = "TGMC Update"

	for(var/obj/machinery/computer/communications/C in machines)
		if(!(C.stat & (BROKEN|NOPOWER)))
			var/obj/item/paper/P = new /obj/item/paper( C.loc )
			P.name = "'[command_name()] Update.'"
			P.info = input
			P.update_icon()
			C.messagetitle.Add("[command_name()] Update")
			C.messagetext.Add(P.info)

	switch(alert("Should this be announced to the general population?",,"Yes","No"))
		if("Yes")
			command_announcement.Announce(input, customname, new_sound = 'sound/AI/commandreport.ogg');
		if("No")
			command_announcement.Announce("<span class='warning'> New update available at all communication consoles.</span>", customname, new_sound = 'sound/AI/commandreport.ogg')

	log_admin("[key_name(usr)] has created a command report: [input]")
	message_admins("[ADMIN_TPMONTY(usr)] has created a command report.")


/datum/admins/proc/narrate_global()
	set category = "Fun"
	set name = "Global Narrate"

	if(!check_rights(R_FUN))
		return

	var/msg = input("Message:", text("Enter the text you wish to appear to everyone:")) as text

	if(!msg)
		return

	to_chat(world, "[msg]")

	log_admin("[key_name(usr)] used Global Narrate: [msg]")
	message_admins("[ADMIN_TPMONTY(usr)] used Global Narrate: [msg]")


/datum/admins/proc/narage_direct(var/mob/M)
	set category = "Fun"
	set name = "Direct Narrate"

	if(!check_rights(R_FUN))
		return

	if(!M)
		M = input("Direct narrate to who?", "Active Players") as null|anything in get_mob_with_client_list()

	var/msg = input("Message:", text("Enter the text you wish to appear to your target:")) as text

	if(!msg || !M)
		return

	to_chat(M, msg)

	log_admin("DirectNarrate: [key_name(usr)] to [key_name(M)]: [msg]")
	message_admins("[ADMIN_TPMONTY(usr)] used Direct Narrate on [ADMIN_TPMONTY(M)]: [msg]")


/datum/admins/proc/subtle_message(mob/M as mob in mob_list)
	set category = "Fun"
	set name = "Subtle Message"

	if(!check_rights(R_FUN|R_MENTOR))
		return

	var/msg = input("Message:", text("Subtle PM to [M.key]")) as text

	if(!M?.client || !msg)
		return

	to_chat(M, "You hear a voice in your head... [msg]")

	log_admin("SubtleMessage: [key_name(usr)] to [key_name(M)]: [msg]")
	message_admins("[ADMIN_TPMONTY(usr)] used Subtle Message on [ADMIN_TPMONTY(M)]: [msg]")


/datum/admins/proc/drop_everything(mob/M as mob in mob_list)
	set category = "Fun"
	set name = "Drop Everything"

	if(!check_rights(R_FUN))
		return

	if(alert(src, "Make [M] drop everything?", "Message", "Yes", "No") != "Yes")
		return

	for(var/obj/item/W in M)
		if(istype(W, /obj/item/alien_embryo))
			continue
		M.dropItemToGround(W)

	log_admin("[key_name(usr)] made [key_name(M)] drop everything.")
	message_admins("[ADMIN_TPMONTY(usr)] made [ADMIN_TPMONTY(M)] drop everything.")


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

	switch(input(usr, "Do you want to change or clear the custom event info?",, "Change", "Clear", "Cancel"))
		if("Change")
			custom_event_msg = input(usr, "Set the custom information players get on joining or via the OOC tab.",, custom_event_msg) as message|null

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

	var/midi_warning = ""

	if(midi_playing)
		to_chat(usr, "<span class='warning'>A sound was played recently. Please wait.</span>")
		return

	var/sound/uploaded_sound = sound(S, repeat = 0, wait = 1, channel = 777)
	uploaded_sound.priority = 250

	switch(alert("Play sound globally or locally?", "Sound", "Global", "Local", "Cancel"))
		if("Global")
			for(var/mob/M in player_list)
				if(M.client.prefs.toggles_sound & SOUND_MIDI)
					M << uploaded_sound
					heard_midi++
		if("Local")
			playsound(get_turf(owner.mob), uploaded_sound, 50, 0)
			for(var/mob/M in view())
				heard_midi++
		if("Cancel")
			return

	log_admin("[key_name(usr)] played sound '[S]' for [heard_midi] player(s). [clients.len - heard_midi] player(s) have disabled admin midis.")
	message_admins("[ADMIN_TPMONTY(usr)] played sound '[S]' for [heard_midi] player(s). [clients.len - heard_midi] player(s) have disabled admin midis.")

	// A 30 sec timer used to show Admins how many players are silencing the sound after it starts - see preferences_toggles.dm
	var/midi_playing_timer = 300 // Should match with the midi_silenced spawn() in preferences_toggles.dm
	midi_playing = TRUE
	spawn(midi_playing_timer)
		midi_playing = 0
		if(heard_midi == 0)
			message_admins("No-one heard the midi")
			total_silenced = 0
			return
		if((total_silenced / heard_midi) != 0)
			midi_warning = "[round((total_silenced / heard_midi) * 100)]% of players don't want to hear it, and likely more if the midi is longer than 30 seconds."
		message_admins("'Silence Current Midi' usage reporting 30-sec timer has expired. [total_silenced] player(s) silenced the midi in the first 30 seconds out of [heard_midi] total player(s) that have 'Play Admin Midis' enabled. [midi_warning]")
		heard_midi = 0
		total_silenced = 0


/datum/admins/proc/sound_list()
	set category = "Fun"
	set name = "Play Sound From List"
	set desc = "Play a sound already in the project from a pre-made list."

	if(!check_rights(R_SOUND))
		return

	var/list/sounds = file2list("sound/soundlist.txt");
	sounds += "--CANCEL--"

	var/melody = input("Select a sound to play", "Sound list", "--CANCEL--") in sounds

	if(melody == "--CANCEL--")
		return

	usr.client.holder.sound_file(melody)


/datum/admins/proc/announce()
	set category = "Fun"
	set name = "Announce"
	set desc = "Announce your desires to the world."

	if(!check_rights(R_FUN))
		return

	var/message = input("Global message to send:", "Admin Announce") as message|null

	if(!message)
		return

	log_admin("AdminAnnounce: [key_name(usr)] : [message]")
	message_admins("[ADMIN_TPMONTY(usr)] Announces:")
	to_chat(world, "<span class='notice'><b>[fakekey ? "Administrator" : owner.key] ([rank]) Announces:</b>\n [message]</span>")


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

	var/is_announcing = TRUE
	if(alert(src, "Would you like to announce the distress beacon to the server population? This will reveal the distress beacon to all players.", "Announce distress beacon?", "Yes", "No") != "Yes")
		is_announcing = FALSE

	ticker.mode.picked_call.activate(is_announcing)

	log_admin("[key_name(usr)] called a [choice == "Randomize" ? "randomized ":""]distress beacon: [ticker.mode.picked_call.name]")
	message_admins("[ADMIN_TPMONTY(usr)] called a [choice == "Randomize" ? "randomized ":""]distress beacon: [ticker.mode.picked_call.name]")


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
		to_chat(usr, "<span class='warning'>Unable to launch this Distress shuttle at this moment. Aborting.</span>")
		return

	shuttle.launch()

	log_admin("[key_name(usr)] force launched a distress shuttle: [tag] to [dock_name].")
	message_admins("[ADMIN_TPMONTY(usr)] force launched a distress shuttle: [tag] to: [dock_name].")


/datum/admins/proc/object_sound(var/obj/O in object_list)
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
		V.show_message("<b>[O.name]</b> [method]: [message]", 2)

	log_admin("[key_name(usr)] forced [O] ([O.type]) to: [method] [message]")
	message_admins("[ADMIN_TPMONTY(usr)] forced [O] ([O.type]) to: [method] [message]")


/datum/admins/proc/object_talk(var/msg as text)
	set category = "Fun"
	set name = "Object Say"
	set desc = "Use this to talk as an object you control."

	if(!check_rights(R_FUN))
		return

	if(!usr.control_object)
		return

	if(!msg)
		return

	for(var/mob/V in hearers(usr.control_object))
		V.show_message("<b>[usr.control_object.name]</b> says: [msg]", 2)

	log_admin("[key_name(usr)] used [usr.control_object] ([usr.control_object.type]) to say: [msg]")
	message_admins("[ADMIN_TPMONTY(usr)] used [usr.control_object] ([usr.control_object.type]) to say: [msg]")


/datum/admins/proc/drop_bomb()
	set category = "Fun"
	set name = "Drop Bomb"
	set desc = "Cause an explosion of varying strength at your location."

	if(!check_rights(R_FUN))
		return

	if(!owner.mob)
		return

	var/mob/M = owner.mob

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


/datum/admins/proc/select_rank(var/mob/living/carbon/human/H in mob_list)
	set category = "Fun"
	set name = "Select Rank"

	if(!istype(H))
		return

	var/rank_list = list("Custom") + RoleAuthority.roles_by_name

	var/newrank = input("Select new rank for [H]", "Change the mob's rank and skills") as null|anything in rank_list

	if(!newrank)
		return

	if(!H?.mind)
		return

	if(newrank != "Custom")
		H.set_everything(H, newrank)
	else
		var/newcommtitle = input("Write the custom title appearing on the comms themselves, for example: \[Command (Title)]", "Comms title") as null|text

		if(!newcommtitle)
			return
		if(!H?.mind)
			return

		H.mind.role_comm_title = newcommtitle
		var/obj/item/card/id/I = H.wear_id

		if(!istype(I) || I != H.wear_id)
			to_chat(usr, "The mob has no id card, unable to modify ID and chat title.")
		else
			var/newchattitle = input("Write the custom title appearing in all chats: Title Jane Doe says", "Chat title") as null|text

			if(!H || I != H.wear_id)
				return

			I.paygrade = newchattitle

			var/IDtitle = input("Write the custom title appearing on the ID itself: Jane Doe's ID Card (Title)", "ID title") as null|text

			if(!H || I != H.wear_id)
				return

			I.rank = IDtitle
			I.assignment = IDtitle
			I.name = "[I.registered_name]'s ID Card[IDtitle ? " ([I.assignment])" : ""]"

		if(!H.mind)
			to_chat(usr, "The mob has no mind, unable to modify skills.")

		else
			var/newskillset = input("Select a skillset", "Skill Set") as null|anything in RoleAuthority.roles_by_name

			if(!newskillset)
				return

			if(!H?.mind)
				return

			var/datum/job/J = RoleAuthority.roles_by_name[newskillset]
			H.mind.set_cm_skills(J.skills_type)


/datum/admins/proc/select_equipment(var/mob/living/carbon/human/M in mob_list)
	set category = "Fun"
	set name = "Select Equipment"

	if(!ishuman(M))
		return

	var/list/dresspacks = list("Strip") + RoleAuthority.roles_by_equipment
	var/list/paths = list("Strip") + RoleAuthority.roles_by_equipment_paths

	var/dresscode = input("Choose equipment for [M]", "Select Equipment") as null|anything in dresspacks

	if(!dresscode)
		return

	var/path = paths[dresspacks.Find(dresscode)]

	for(var/obj/item/I in M)
		if(istype(I, /obj/item/implant) || istype(I, /obj/item/card/id))
			continue
		qdel(I)

	var/datum/job/J = new path
	J.generate_equipment(M)
	M.regenerate_icons()

	log_admin("[key_name(usr)] changed the equipment of [key_name(M)] to [dresscode].")
	message_admins("[ADMIN_TPMONTY(usr)] changed the equipment of [ADMIN_TPMONTY(M)] to [dresscode].")


/datum/admins/proc/possess(obj/O as obj in object_list)
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


/datum/admins/proc/release(obj/O as obj in object_list)
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