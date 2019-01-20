/client/proc/toggle_view_range()
	set category = "Fun"
	set name = "Change View Range"
	set desc = "switches between 1x and custom views"

	if(view == world.view)
		var/newview = input("Select view range:", "Change View Range", 7) in list(1,2,3,4,5,6,7,8,9,10,11,12,13,14,21,28,35,50,128)
		if(newview && newview != view)
			change_view(newview)
	else
		change_view(world.view)

	log_admin("[key_name(usr)] changed their view range to [view].")
	//message_admins("<span class='notice'> [key_name_admin(usr)] changed their view range to [view].</span>", 1)	//why? removed by order of XSI

	feedback_add_details("admin_verb","CVRA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_attack_log(mob/M as mob in mob_list)
	set category = "Fun"
	set name = "Attack Log"

	to_chat(usr, text("<span class='danger'>Attack Log for []</span>", mob))
	show_individual_logging_panel(M)
	feedback_add_details("admin_verb","ATTL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/everyone_random()
	set category = "Fun"
	set name = "Make Everyone Random"
	set desc = "Make everyone have a random appearance. You can only use this before rounds!"

	if(!check_rights(R_FUN))	return

	if (ticker && ticker.mode)
		to_chat(usr, "Nope you can't do this, the game's already started. This only works before rounds!")
		return

	if(ticker.random_players)
		ticker.random_players = 0
		message_admins("Admin [key_name_admin(usr)] has disabled \"Everyone is Special\" mode.", 1)
		to_chat(usr, "Disabled.")
		return


	var/notifyplayers = alert(src, "Do you want to notify the players?", "Options", "Yes", "No", "Cancel")
	if(notifyplayers == "Cancel")
		return

	log_admin("Admin [key_name(src)] has forced the players to have random appearances.")
	message_admins("Admin [key_name_admin(usr)] has forced the players to have random appearances.", 1)

	if(notifyplayers == "Yes")
		to_chat(world, "<span class='boldnotice'>Admin [usr.key] has forced the players to have completely random identities!</span>")

	to_chat(usr, "<i>Remember: you can always disable the randomness by using the verb again, assuming the round hasn't started yet</i>.")

	ticker.random_players = 1
	feedback_add_details("admin_verb","MER") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/cmd_admin_gib_self()
	set name = "Gib Self"
	set category = "Fun"

	var/confirm = alert(src, "You sure?", "Confirm", "Yes", "No")
	if(confirm == "Yes")
		if (istype(mob, /mob/dead/observer)) // so they don't spam gibs everywhere
			return
		else
			mob.gib()

		log_admin("[key_name(usr)] used gibself.")
		message_admins("<span class='notice'> [key_name_admin(usr)] used gibself.</span>", 1)
		feedback_add_details("admin_verb","GIBS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_gib(mob/M as mob in mob_list)
	set category = "Fun"
	set name = "Gib"

	if(!check_rights(R_ADMIN|R_FUN))	return

	var/confirm = alert(src, "You sure?", "Confirm", "Yes", "No")
	if(confirm != "Yes") return
	//Due to the delay here its easy for something to have happened to the mob
	if(!M)	return

	log_admin("[key_name(usr)] has gibbed [key_name(M)]")
	message_admins("[key_name_admin(usr)] has gibbed [key_name_admin(M)]", 1)

	if(istype(M, /mob/dead/observer))
		gibs(M.loc, M.viruses)
		return

	M.gib()
	feedback_add_details("admin_verb","GIB") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/cmd_admin_emp(atom/O as obj|mob|turf in world)
	set category = "Fun"
	set name = "EM Pulse"

	if(!check_rights(R_DEBUG|R_FUN))	return

	var/heavy = input("Range of heavy pulse.", text("Input"))  as num|null
	if(heavy == null) return
	var/light = input("Range of light pulse.", text("Input"))  as num|null
	if(light == null) return

	if (heavy || light)

		empulse(O, heavy, light)
		log_admin("[key_name(usr)] created an EM Pulse ([heavy],[light]) at ([O.x],[O.y],[O.z])")
		message_admins("[key_name_admin(usr)] created an EM PUlse ([heavy],[light]) at ([O.x],[O.y],[O.z])", 1)
		feedback_add_details("admin_verb","EMP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/cmd_admin_explosion(atom/O as obj|mob|turf in world)
	set category = "Fun"
	set name = "Explosion"

	if(!check_rights(R_DEBUG|R_FUN))	return

	var/devastation = input("Range of total devastation. -1 to none", text("Input"))  as num|null
	if(devastation == null) return
	var/heavy = input("Range of heavy impact. -1 to none", text("Input"))  as num|null
	if(heavy == null) return
	var/light = input("Range of light impact. -1 to none", text("Input"))  as num|null
	if(light == null) return
	var/flash = input("Range of flash. -1 to none", text("Input"))  as num|null
	if(flash == null) return

	if ((devastation != -1) || (heavy != -1) || (light != -1) || (flash != -1))
		if ((devastation > 20) || (heavy > 20) || (light > 20))
			if (alert(src, "Are you sure you want to do this? It will laaag.", "Confirmation", "Yes", "No") == "No")
				return

		explosion(O, devastation, heavy, light, flash)
		log_admin("[key_name(usr)] created an explosion ([devastation],[heavy],[light],[flash]) at ([O.x],[O.y],[O.z])")
		message_admins("[key_name_admin(usr)] created an explosion ([devastation],[heavy],[light],[flash]) at ([O.x],[O.y],[O.z])", 1)
		feedback_add_details("admin_verb","EXPL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/cmd_admin_xeno_report()
	set category = "Fun"
	set name = "Create Queen Mother Report"
	set desc = "Basically a MOTHER report, but only for Xenos"
	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return
	var/input = input(usr, "This should be a message from the ruler of the Xenomorph race.", "What?", "") as message|null
	var/customname = "Queen Mother Psychic Directive"
	if(!input) return FALSE

	var/data = "<h1>[customname]</h1><br><br><br><span class='warning'>[input]<br><br></span>"

	for(var/mob/M in player_list)
		if(isXeno(M) || isobserver(M))
			to_chat(M, data)

	log_admin("[key_name(src)] has created a Queen Mother report: [input]")
	message_admins("[key_name_admin(src)] has created a Queen Mother report", 1)
	feedback_add_details("admin_verb","QMR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/show_hive_status()
	set name = "Show Hive Status"
	set desc = "Check the status of the hive."
	set category = "Fun"
	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return

	check_hive_status()


/client/proc/cmd_admin_create_AI_report()
	set category = "Fun"
	set name = "Create AI Report"
	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return
	var/input = input(usr, "This should be a message from the ship's AI.  Check with online staff before you send this. Do not use html.", "What?", "") as message|null
	if(!input) return FALSE
	if(ai_system.Announce(input))

		for (var/obj/machinery/computer/communications/C in machines)
			if(! (C.stat & (BROKEN|NOPOWER) ) )
				var/obj/item/paper/P = new /obj/item/paper( C.loc )
				P.name = "'[MAIN_AI_SYSTEM] Update.'"
				P.info = input
				P.update_icon()
				C.messagetitle.Add("[MAIN_AI_SYSTEM] Update")
				C.messagetext.Add(P.info)

		log_admin("[key_name(src)] has created an AI report: [input]")
		message_admins("[key_name_admin(src)] has created an AI report: [input]", 1)
		feedback_add_details("admin_verb","CCR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	else
		to_chat(usr, "<span class='warning'>[MAIN_AI_SYSTEM] is not responding. It may be offline or destroyed.</span>")


/client/proc/cmd_admin_create_centcom_report()
	set category = "Fun"
	set name = "Create Command Report"
	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return
	var/input = input(usr, "Please enter anything you want. Anything. Serious.", "What?", "") as message|null
	var/customname = input(usr, "Pick a title for the report.", "Title") as text|null
	if(!input)
		return
	if(!customname)
		customname = "TGMC Update"
	for (var/obj/machinery/computer/communications/C in machines)
		if(! (C.stat & (BROKEN|NOPOWER) ) )
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

	log_admin("[key_name(src)] has created a command report: [input]")
	message_admins("[key_name_admin(src)] has created a command report", 1)
	feedback_add_details("admin_verb","CCR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/respawn_character()
	set category = "Fun"
	set name = "Respawn Character"
	set desc = "Respawn a person that has been gibbed/dusted/killed. They must be a ghost for this to work and preferably should not have a body to go back into."
	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return
	var/input = ckey(input(src, "Please specify which key will be respawned.", "Key", ""))
	if(!input)
		return

	var/mob/dead/observer/G_found
	for(var/mob/dead/observer/G in player_list)
		if(G.ckey == input)
			G_found = G
			break

	if(!G_found)//If a ghost was not found.
		to_chat(usr, "<font color='red'>There is no active key like that in the game or the person is not currently a ghost.</font>")
		return

	if(G_found.mind && !G_found.mind.active)	//mind isn't currently in use by someone/something

		//check if they were a monkey
		if(findtext(G_found.real_name,"monkey"))
			if(alert("This character appears to have been a monkey. Would you like to respawn them as such?",,"Yes","No")=="Yes")
				var/mob/living/carbon/monkey/new_monkey = new(pick(latejoin))
				G_found.mind.transfer_to(new_monkey)	//be careful when doing stuff like this! I've already checked the mind isn't in use
				new_monkey.key = G_found.key
				if(new_monkey.client) new_monkey.client.change_view(world.view)
				to_chat(new_monkey, "You have been fully respawned. Enjoy the game.")
				message_admins("<span class='notice'> [key_name_admin(usr)] has respawned [new_monkey.key] as a filthy xeno.</span>", 1)
				return	//all done. The ghost is auto-deleted

	//Ok, it's not a monkey. So, spawn a human.
	var/mob/living/carbon/human/new_character = new(pick(latejoin))//The mob being spawned.

	var/datum/data/record/record_found			//Referenced to later to either randomize or not randomize the character.
	if(G_found.mind && !G_found.mind.active)	//mind isn't currently in use by someone/something
		/*Try and locate a record for the person being respawned through data_core.
		This isn't an exact science but it does the trick more often than not.*/
		var/id = md5("[G_found.real_name][G_found.mind.assigned_role]")
		for(var/datum/data/record/t in data_core.locked)
			if(t.fields["id"]==id)
				record_found = t//We shall now reference the record.
				break

	if(record_found)//If they have a record we can determine a few things.
		new_character.real_name = record_found.fields["name"]
		new_character.gender = record_found.fields["sex"]
		new_character.age = record_found.fields["age"]
		new_character.b_type = record_found.fields["b_type"]
	else
		new_character.gender = pick(MALE,FEMALE)
		var/datum/preferences/A = new()
		A.randomize_appearance_for(new_character)
		new_character.real_name = G_found.real_name

	if(!new_character.real_name)
		if(new_character.gender == MALE)
			new_character.real_name = capitalize(pick(first_names_male)) + " " + capitalize(pick(last_names))
		else
			new_character.real_name = capitalize(pick(first_names_female)) + " " + capitalize(pick(last_names))
	new_character.name = new_character.real_name

	if(G_found.mind && !G_found.mind.active)
		G_found.mind.transfer_to(new_character)	//be careful when doing stuff like this! I've already checked the mind isn't in use
		new_character.mind.special_verbs = list()
	else
		new_character.mind_initialize()
	if(!new_character.mind.assigned_role)	new_character.mind.assigned_role = "Assistant"//If they somehow got a null assigned role.


	//DNA
	if(record_found)//Pull up their name from database records if they did have a mind.
		new_character.dna = new()//Let's first give them a new DNA.
		new_character.dna.unique_enzymes = record_found.fields["b_dna"]//Enzymes are based on real name but we'll use the record for conformity.

		// I HATE BYOND.  HATE.  HATE. - N3X
		var/list/newSE= record_found.fields["enzymes"]
		var/list/newUI = record_found.fields["identity"]
		new_character.dna.SE = newSE.Copy() //This is the default of enzymes so I think it's safe to go with.
		new_character.dna.UpdateSE()
		new_character.UpdateAppearance(newUI.Copy())//Now we configure their appearance based on their unique identity, same as with a DNA machine or somesuch.
	else//If they have no records, we just do a random DNA for them, based on their random appearance/savefile.
		new_character.dna.ready_dna(new_character)

	new_character.key = G_found.key
	if(new_character.client) new_character.client.change_view(world.view)

	/*
	The code below functions with the assumption that the mob is already a traitor if they have a special role.
	So all it does is re-equip the mob with powers and/or items. Or not, if they have no special role.
	If they don't have a mind, they obviously don't have a special role.
	*/

	//Two variables to properly announce later on.
	var/admin = key_name_admin(src)
	var/player_key = G_found.key

	//Now for special roles and equipment.
	switch(new_character.mind.special_role)
		if("traitor")
			ticker.mode.equip_traitor(new_character)

	RoleAuthority.equip_role(new_character, RoleAuthority.roles_for_mode[new_character.mind.assigned_role], pick(latejoin))//Or we simply equip them.
	//Announces the character on all the systems, based on the record.
	if(!issilicon(new_character))//If they are not a cyborg/AI.
		if(!record_found&&new_character.mind.assigned_role!="MODE")//If there are no records for them. If they have a record, this info is already in there. MODE people are not announced anyway.
			//Power to the user!
			if(alert(new_character,"Warning: No data core entry detected. Would you like to announce the arrival of this character by adding them to various databases, such as medical records?",,"No","Yes")=="Yes")
				data_core.manifest_inject(new_character)

			if(alert(new_character,"Would you like an active AI to announce this character?",,"No","Yes")=="Yes")
				call(/mob/new_player/proc/AnnounceArrival)(new_character, new_character.mind.assigned_role)

	message_admins("<span class='notice'> [admin] has respawned [player_key] as [new_character.real_name].</span>", 1)

	to_chat(new_character, "You have been fully respawned. Enjoy the game.")

	feedback_add_details("admin_verb","RSPCH") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return new_character

/client/proc/cmd_admin_godmode(mob/M as mob in mob_list)
	set category = "Fun"
	set name = "Godmode"
	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return
	M.status_flags ^= GODMODE
	to_chat(usr, "<span class='notice'> Toggled [(M.status_flags & GODMODE) ? "ON" : "OFF"]</span>")

	log_admin("[key_name(usr)] has toggled [key_name(M)]'s nodamage to [(M.status_flags & GODMODE) ? "On" : "Off"]")
	message_admins("[key_name_admin(usr)] has toggled [key_name_admin(M)]'s nodamage to [(M.status_flags & GODMODE) ? "On" : "Off"]", 1)
	feedback_add_details("admin_verb","GOD") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/cmd_admin_world_narrate() // Allows administrators to fluff events a little easier -- TLE
	set category = "Fun"
	set name = "Narrate - Global"

	if (!holder)
		to_chat(src, "Only administrators may use this command.")
		return

	var/msg = input("Message:", text("Enter the text you wish to appear to everyone:")) as text

	if(!msg)
		return
	to_chat(world, "[msg]")
	log_admin("GlobalNarrate: [key_name(usr)] : [msg]")
	message_admins("<span class='boldnotice'> GlobalNarrate: [key_name_admin(usr)] : [msg]<BR></span>", 1)
	feedback_add_details("admin_verb","GLN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_direct_narrate(var/mob/M)	// Targetted narrate -- TLE
	set category = "Fun"
	set name = "Narrate - Direct"

	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return

	if(!M)
		M = input("Direct narrate to who?", "Active Players") as null|anything in get_mob_with_client_list()

	if(!M)
		return

	var/msg = input("Message:", text("Enter the text you wish to appear to your target:")) as text

	if( !msg )
		return

	to_chat(M, msg)
	log_admin("DirectNarrate: [key_name(usr)] to ([M.name]/[M.key]): [msg]")
	message_admins("<span class='boldnotice'> DirectNarrate: [key_name(usr)] to ([M.name]/[M.key]): [msg]<BR></span>", 1)
	feedback_add_details("admin_verb","DIRN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/cmd_admin_subtle_message(mob/M as mob in mob_list)
	set category = "Fun"
	set name = "Subtle Message"

	if(!ismob(M))
		return
	if(!check_rights(R_ADMIN|R_MENTOR))
		to_chat(src, "Only staff members may use this command.")
		return

	var/msg = input("Message:", text("Subtle PM to [M.key]")) as text

	if(!msg)
		return

	if(usr?.client?.holder)
		to_chat(M, "\bold You hear a voice in your head... \italic [msg]")

	log_admin("SubtlePM: [key_name(usr)] -> [key_name(M)] : [msg]")
	message_admins("<span class='boldnotice'> SubtleMessage: [key_name_admin(usr)] -> [key_name_admin(M)] : [msg]</span>", 1)
	feedback_add_details("admin_verb","SMS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_drop_everything(mob/M as mob in mob_list)
	set category = "Fun"
	set name = "Drop Everything"
	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return

	var/confirm = alert(src, "Make [M] drop everything?", "Message", "Yes", "No")
	if(confirm != "Yes")
		return

	for(var/obj/item/W in M)
		if(istype(W,/obj/item/alien_embryo)) continue
		M.dropItemToGround(W)

	log_admin("[key_name(usr)] made [key_name(M)] drop everything!")
	message_admins("[key_name_admin(usr)] made [key_name_admin(M)] drop everything!", 1)
	feedback_add_details("admin_verb","DEVR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/check_round_statistics()
	set category = "Fun"
	set name = "Round Statistics"
	if(!check_rights(R_ADMIN))	return

	debug_variables(round_statistics)


/client/proc/award_medal()
	set category = "Fun"
	set name = "Award a Medal"
	if(!check_rights(R_ADMIN))	return

	give_medal_award()

/proc/get_all_humans()
	if(!check_rights(R_ADMIN))	return

	for(var/client/C in clients)
		if(isobserver(C.mob) || C.mob.stat == DEAD)
			continue
		if(ishuman(C.mob))
			C.mob.loc = get_turf(usr)

/proc/get_all_xenos()
	if(!check_rights(R_ADMIN))	return

	for(var/client/C in clients)
		if(isobserver(C.mob) || C.mob.stat == DEAD)
			continue
		if(isXeno(C.mob))
			C.mob.loc = get_turf(usr)

/proc/get_all()
	if(!check_rights(R_ADMIN))	return

	for(var/client/C in clients)
		if(isobserver(C.mob) || C.mob.stat == DEAD)
			continue
		C.mob.loc = get_turf(usr)

/proc/rejuv_all()
	if(!check_rights(R_ADMIN))	return

	for(var/client/C in clients)
		if(!isliving(C.mob))
			continue
		var/mob/living/M = C.mob
		M.rejuvenate()


// verb for admins to set custom event
/client/proc/cmd_admin_change_custom_event()
	set category = "Fun"
	set name = "Change Custom Event"

	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return

	var/input = input(usr, "Enter the description of the custom event. Be descriptive. To cancel the event, make this blank or hit cancel.", "Custom Event", custom_event_msg) as message|null
	if(!input || input == "")
		custom_event_msg = null
		log_admin("[usr.key] has cleared the custom event text.")
		message_admins("[key_name_admin(usr)] has cleared the custom event text.")
		return

	log_admin("[usr.key] has changed the custom event text.")
	message_admins("[key_name_admin(usr)] has changed the custom event text.")

	custom_event_msg = input

	to_chat(world, "<h1 class='alert'>Custom Event</h1>")
	to_chat(world, "<h2 class='alert'>A custom event is starting. OOC Info:</h2>")
	to_chat(world, "<span class='alert'>[html_encode(custom_event_msg)]</span>")
	to_chat(world, "<br>")

// normal verb for players to view info
/client/verb/cmd_view_custom_event()
	set category = "OOC"
	set name = "Custom Event Info"

	if(!custom_event_msg || custom_event_msg == "")
		to_chat(src, "There currently is no known custom event taking place.")
		to_chat(src, "Keep in mind: it is possible that an admin has not properly set this.")
		return

	to_chat(src, "<h1 class='alert'>Custom Event</h1>")
	to_chat(src, "<h2 class='alert'>A custom event is taking place. OOC Info:</h2>")
	to_chat(src, "<span class='alert'>[html_encode(custom_event_msg)]</span>")
	to_chat(src, "<br>")

/client/proc/play_imported_sound(S as sound)
	var/midi_warning = ""
	set category = "Fun"
	set name = "Play Imported Sound"
	set desc = "Play a sound imported from anywhere on your computer."
	if(!check_rights(R_SOUND))	return

	if(midi_playing)
		to_chat(usr, "No. An Admin already played a midi recently.")
		return

	var/sound/uploaded_sound = sound(S, repeat = 0, wait = 1, channel = 777)
	uploaded_sound.priority = 250

	switch( alert("Play sound globally or locally?", "Sound", "Global", "Local", "Cancel") )
		if("Global")
			for(var/mob/M in player_list)
				if(M.client.prefs.toggles_sound & SOUND_MIDI)
					M << uploaded_sound
					heard_midi++
		if("Local")
			playsound(get_turf(src.mob), uploaded_sound, 50, 0)
			for(var/mob/M in view())
				heard_midi++
		if("Cancel")
			return

	log_admin("[key_name(src)] played sound `[S]` for [heard_midi] player(s). [clients.len - heard_midi] player(s) have disabled admin midis.")
	message_admins("[key_name_admin(src)] played sound `[S]` for [heard_midi] player(s). [clients.len - heard_midi] player(s) have disabled admin midis.", 1)
	feedback_add_details("admin_verb","PCS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	// A 30 sec timer used to show Admins how many players are silencing the sound after it starts - see preferences_toggles.dm
	var/midi_playing_timer = 300 // Should match with the midi_silenced spawn() in preferences_toggles.dm
	midi_playing = 1
	spawn(midi_playing_timer)
		midi_playing = 0
		if(heard_midi == 0)
			message_admins("No-one heard the midi")
			total_silenced = 0
			return
		if((total_silenced / heard_midi) != 0)
			midi_warning = " <span style='color: red'>[round((total_silenced / heard_midi) * 100)]% of players don't want to hear it, and likely more if the midi is longer than 30 seconds.</span>"
		message_admins("'Silence Current Midi' usage reporting 30-sec timer has expired. [total_silenced] player(s) silenced the midi in the first 30 seconds out of [heard_midi] total player(s) that have 'Play Admin Midis' enabled.[midi_warning]")
		heard_midi = 0
		total_silenced = 0



/client/proc/play_sound_from_list()
	set category = "Fun"
	set name = "Play Sound From List"
	set desc = "Play a sound already in the project from a pre-made list."
	if(!check_rights(R_SOUND))	return

	var/list/sounds = file2list("sound/soundlist.txt");
	sounds += "--CANCEL--"

	var/melody = input("Select a sound to play", "Sound list", "--CANCEL--") in sounds

	if(melody == "--CANCEL--")	return

	play_imported_sound(melody)
	feedback_add_details("admin_verb","PDS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/datum/admins/proc/announce()
	set category = "Fun"
	set name = "Announce"
	set desc= "Announce your desires to the world."

	if(!check_rights(0))
		return

	var/message = input("Global message to send:", "Admin Announce") as message|null

	if(!message)
		return

	if(!check_rights(R_SERVER,0))
		message = adminscrub(message,500)

	to_chat(world, "<span class='notice'> <b>[usr.client.holder.fakekey ? "Administrator" : usr.key] Announces:</b>\n \t [message]</span>")
	log_admin("Announce: [key_name(usr)] : [message]")
	feedback_add_details("admin_verb","A") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/datum/admins/proc/admin_force_distress()
	set category = "Fun"
	set name = "Distress Beacon"
	set desc = "Call a distress beacon. This should not be done if the shuttle's already been called."

	if(!ticker?.mode)
		to_chat(src, "<span class='warning'>Please wait for the round to begin first.</span>")
		return

	if(!check_rights(R_ADMIN))
		to_chat(src, "<span class='warning'>Insufficient permissions.</span>")
		return

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
		if(L?.name)
			list_of_calls += L.name

	list_of_calls += "Randomize"

	var/choice = input("Which distress do you want to call?") as null|anything in list_of_calls
	if(!choice)
		return

	if(choice == "Randomize")
		ticker.mode.picked_call	= ticker.mode.get_random_call()
	else
		for(var/datum/emergency_call/C in ticker.mode.all_calls)
			if(C?.name == choice)
				ticker.mode.picked_call = C
				break

	if(!istype(ticker.mode.picked_call))
		return

	var/is_announcing = TRUE
	var/announce = alert(src, "Would you like to announce the distress beacon to the server population? This will reveal the distress beacon to all players.", "Announce distress beacon?", "Yes", "No")
	if(announce == "No")
		is_announcing = FALSE

	ticker.mode.picked_call.activate(is_announcing)

	feedback_add_details("admin_verb","DISTR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] admin-called a [choice == "Randomize" ? "randomized ":""]distress beacon: [ticker.mode.picked_call.name]")
	message_admins("<span class='notice'> [key_name_admin(usr)] admin-called a [choice == "Randomize" ? "randomized ":""]distress beacon: [ticker.mode.picked_call.name]</span>", 1)


/datum/admins/proc/admin_force_ERT_shuttle()
	set category = "Fun"
	set name = "Force ERT Shuttle"
	set desc = "Force Launch the ERT Shuttle."

	if (!ticker  || !ticker.mode) return
	if(!check_rights(R_ADMIN))	return

	var/tag = input("Which ERT shuttle should be force launched?", "Select an ERT Shuttle:") as null|anything in list("Distress", "Distress_PMC", "Distress_UPP", "Distress_Big")
	if(!tag) return

	var/datum/shuttle/ferry/ert/shuttle = shuttle_controller.shuttles[tag]
	if(!shuttle || !istype(shuttle))
		message_admins("Warning: Distress shuttle not found. Aborting.")
		return

	if(shuttle.location) //in start zone in admin z level
		var/dock_id
		var/dock_list = list("Port", "Starboard", "Aft")
		if(shuttle.use_umbilical)
			dock_list = list("Port Hangar", "Starboard Hangar")
		var/dock_name = input("Where on the [MAIN_SHIP_NAME] should the shuttle dock?", "Select a docking zone:") as null|anything in dock_list
		switch(dock_name)
			if("Port") dock_id = /area/shuttle/distress/arrive_2
			if("Starboard") dock_id = /area/shuttle/distress/arrive_1
			if("Aft") dock_id = /area/shuttle/distress/arrive_3
			if("Port Hangar") dock_id = /area/shuttle/distress/arrive_s_hangar
			if("Starboard Hangar") dock_id = /area/shuttle/distress/arrive_n_hangar
			else return
		for(var/datum/shuttle/ferry/ert/F in shuttle_controller.process_shuttles)
			if(F != shuttle)
				//other ERT shuttles already docked on almayer or about to be
				if(!F.location || F.moving_status != SHUTTLE_IDLE)
					if(F.area_station.type == dock_id)
						message_admins("Warning: That docking zone is already taken by another shuttle. Aborting.")
						return

		for(var/area/A in all_areas)
			if(A.type == dock_id)
				shuttle.area_station = A
				break


	if(!shuttle.can_launch())
		message_admins("Warning: Unable to launch this Distress shuttle at this moment. Aborting.")
		return

	shuttle.launch()

	feedback_add_details("admin_verb","LNCHERTSHTL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] force launched a distress shuttle ([tag])")
	message_admins("<span class='notice'> [key_name_admin(usr)] force launched a distress shuttle ([tag])</span>", 1)


/client/proc/make_sound(var/obj/O in object_list) // -- TLE
	set category = "Special Verbs"
	set name = "Make Sound"
	set desc = "Display a message to everyone who can hear the target"
	if(O)
		var/message = input("What do you want the message to be?", "Make Sound") as text|null
		if(!message)
			return
		for (var/mob/V in hearers(O))
			V.show_message(message, 2)
		log_admin("[key_name(usr)] made [O] at [O.x], [O.y], [O.z]. make a sound")
		message_admins("<span class='notice'> [key_name_admin(usr)] made [O] at [O.x], [O.y], [O.z]. make a sound</span>", 1)
		feedback_add_details("admin_verb","MS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/togglebuildmodeself()
	set name = "Toggle Build Mode Self"
	set category = "Fun"
	if(src.mob)
		togglebuildmode(src.mob)
	feedback_add_details("admin_verb","TBMS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/object_talk(var/msg as text) // -- TLE
	set category = "Special Verbs"
	set name = "Object Say"
	set desc = "Display a message to everyone who can hear the target"
	if(mob.control_object)
		if(!msg)
			return
		for (var/mob/V in hearers(mob.control_object))
			V.show_message("<b>[mob.control_object.name]</b> says: \"" + msg + "\"", 2)
	feedback_add_details("admin_verb","OT") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/drop_bomb() // Some admin dickery that can probably be done better -- TLE
	set category = "Fun"
	set name = "Drop Bomb"
	set desc = "Cause an explosion of varying strength at your location."

	var/turf/epicenter = mob.loc
	var/list/choices = list("CANCEL", "Small Bomb", "Medium Bomb", "Big Bomb", "Custom Bomb")
	var/choice = input("What size explosion would you like to produce?") in choices
	switch(choice)
		if("CANCEL")
			return 0
		if("Small Bomb")
			explosion(epicenter, 1, 2, 3, 3)
		if("Medium Bomb")
			explosion(epicenter, 2, 3, 4, 4)
		if("Big Bomb")
			explosion(epicenter, 3, 5, 7, 5)
		if("Custom Bomb")
			var/devastation_range = input("Devastation range (in tiles):") as num
			var/heavy_impact_range = input("Heavy impact range (in tiles):") as num
			var/light_impact_range = input("Light impact range (in tiles):") as num
			var/flash_range = input("Flash range (in tiles):") as num
			explosion(epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range)
	message_admins("<span class='notice'> [ckey] used 'Drop Bomb' at [epicenter.loc].</span>")
	feedback_add_details("admin_verb","DB") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/give_spell(mob/T as mob in mob_list) // -- Urist
	set category = "Fun"
	set name = "Give Spell"
	set desc = "Gives a spell to a mob."
	var/list/spell_names = list()
	for(var/v in spells)
	//	"/obj/effect/proc_holder/spell/" 30 symbols ~Intercross21
		spell_names.Add(copytext("[v]", 31, 0))
	var/S = input("Choose the spell to give to that guy", "ABRAKADABRA") as null|anything in spell_names
	if(!S) return
	var/path = text2path("/obj/effect/proc_holder/spell/[S]")
	T.spell_list += new path
	feedback_add_details("admin_verb","GS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] gave [key_name(T)] the spell [S].")
	message_admins("<span class='notice'> [key_name_admin(usr)] gave [key_name(T)] the spell [S].</span>", 1)

/client/proc/give_disease(mob/T as mob in mob_list) // -- Giacom
	set category = "Fun"
	set name = "Give Disease (old)"
	set desc = "Gives a (tg-style) Disease to a mob."
	var/list/disease_names = list()
	for(var/v in diseases)
	//	"/datum/disease/" 15 symbols ~Intercross
		disease_names.Add(copytext("[v]", 16, 0))
	var/datum/disease/D = input("Choose the disease to give to that guy", "ACHOO") as null|anything in disease_names
	if(!D) return
	var/path = text2path("/datum/disease/[D]")
	T.contract_disease(new path, 1)
	feedback_add_details("admin_verb","GD") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] gave [key_name(T)] the disease [D].")
	message_admins("<span class='notice'> [key_name_admin(usr)] gave [key_name(T)] the disease [D].</span>", 1)

/client/proc/set_ooc_color_self()
	set category = "Fun"
	set name = "OOC Text Color - Self"
	if(!holder && !donator)	return
	var/new_ooccolor = input(src, "Please select your OOC colour.", "OOC colour") as color|null
	if(new_ooccolor)
		prefs.ooccolor = new_ooccolor
		prefs.save_preferences()
	feedback_add_details("admin_verb","OC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/editappear(mob/living/carbon/human/M as mob in mob_list)
	set name = "Edit Appearance"
	set category = "Fun"

	if(!check_rights(R_FUN))	return

	if(!istype(M, /mob/living/carbon/human))
		to_chat(usr, "<span class='warning'>You can only do this to humans!</span>")
		return
	switch(alert("Are you sure you wish to edit this mob's appearance? Skrell, Unathi, Vox and Tajaran can result in unintended consequences.",,"Yes","No"))
		if("No")
			return
	var/new_facial = input("Please select facial hair color.", "Character Generation") as color
	if(new_facial)
		M.r_facial = hex2num(copytext(new_facial, 2, 4))
		M.g_facial = hex2num(copytext(new_facial, 4, 6))
		M.b_facial = hex2num(copytext(new_facial, 6, 8))

	var/new_hair = input("Please select hair color.", "Character Generation") as color
	if(new_facial)
		M.r_hair = hex2num(copytext(new_hair, 2, 4))
		M.g_hair = hex2num(copytext(new_hair, 4, 6))
		M.b_hair = hex2num(copytext(new_hair, 6, 8))

	var/new_eyes = input("Please select eye color.", "Character Generation") as color
	if(new_eyes)
		M.r_eyes = hex2num(copytext(new_eyes, 2, 4))
		M.g_eyes = hex2num(copytext(new_eyes, 4, 6))
		M.b_eyes = hex2num(copytext(new_eyes, 6, 8))

	var/new_skin = input("Please select body color. This is for Tajaran, Unathi, and Skrell only!", "Character Generation") as color
	if(new_skin)
		M.r_skin = hex2num(copytext(new_skin, 2, 4))
		M.g_skin = hex2num(copytext(new_skin, 4, 6))
		M.b_skin = hex2num(copytext(new_skin, 6, 8))


	// hair
	var/new_hstyle = input(usr, "Select a hair style", "Grooming")  as null|anything in hair_styles_list
	if(new_hstyle)
		M.h_style = new_hstyle

	// facial hair
	var/new_fstyle = input(usr, "Select a facial hair style", "Grooming")  as null|anything in facial_hair_styles_list
	if(new_fstyle)
		M.f_style = new_fstyle

	var/new_gender = alert(usr, "Please select gender.", "Character Generation", "Male", "Female")
	if (new_gender)
		if(new_gender == "Male")
			M.gender = MALE
		else
			M.gender = FEMALE
	M.update_hair()
	M.update_body()
	M.check_dna(M)


/client/proc/change_security_level()
	set name = "Set Security Level"
	set desc = "Sets the station security level"
	set category = "Fun"

	if(!check_rights(R_ADMIN))	return
	var sec_level = input(usr, "It's currently code [get_security_level()].", "Select Security Level")  as null|anything in (list("green","blue","red","delta")-get_security_level())
	if(sec_level && alert("Switch from code [get_security_level()] to code [sec_level]?","Change security level?","Yes","No") == "Yes")
		set_security_level(sec_level)
		log_admin("[key_name(usr)] changed the security level to code [sec_level].")


/client/proc/cmd_admin_animalize(var/mob/M in mob_list)
	set category = "Fun"
	set name = "Make Simple Animal"

	if(!ticker)
		alert("Wait until the game starts")
		return

	if(!M.gc_destroyed)
		alert("That mob doesn't seem to exist, close the panel and try again.")
		return

	if(istype(M, /mob/new_player))
		alert("The mob must not be a new_player.")
		return

	log_admin("[key_name(src)] has animalized [M.key].")
	spawn(10)
		M.Animalize()

/client/proc/cmd_admin_alienize(var/mob/M in mob_list)
	set category = "Fun"
	set name = "Make Alien"

	if(!ticker)
		alert("Wait until the game starts")
		return

	if(M.gc_destroyed)
		alert("That mob doesn't seem to exist, close the panel and try again.")
		return

	if(ishuman(M))
		log_admin("[key_name(src)] has alienized [M.key].")
		spawn(10)
			M:Alienize()
			feedback_add_details("admin_verb","MKAL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		log_admin("[key_name(usr)] made [key_name(M)] into an alien.")
		message_admins("<span class='notice'> [key_name_admin(usr)] made [key_name(M)] into an alien.</span>", 1)
	else
		alert("Invalid mob")




/client/proc/cmd_admin_robotize(var/mob/M in mob_list)
	set category = "Fun"
	set name = "Make Robot"

	if(!ticker)
		alert("Wait until the game starts")
		return

	if(M.gc_destroyed)
		alert("That mob doesn't seem to exist, close the panel and try again.")
		return

	if(istype(M, /mob/living/carbon/human))
		log_admin("[key_name(src)] has robotized [M.key].")
		spawn(10)
			M:Robotize()

	else
		alert("Invalid mob")

