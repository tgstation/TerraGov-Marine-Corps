//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

/mob/new_player
	var/ready = 0
	var/spawning = 0//Referenced when you want to delete the new_player later on in the code.
	var/totalPlayers = 0		 //Player counts for the Lobby tab
	var/totalPlayersReady = 0
	universal_speak = 1

	invisibility = 101

	density = 0
	stat = 2
	canmove = 0

	anchored = 1	//  don't get pushed around

	New()
		mob_list += src

	proc/version_check()
		if((client.byond_version < world.byond_version) || ((client.byond_version == world.byond_version) && (client.byond_build < world.byond_build)))
			client << "<span class='warning'>Your version of Byond differs from the server (v[world.byond_version].[world.byond_build]). You may experience graphical glitches, crashes, or other errors. You will be disconnected until your version matches or exceeds the server version.<br> \
			Direct Download (Windows Installer): http://www.byond.com/download/build/[world.byond_version]/[world.byond_version].[world.byond_build]_byond.exe <br> \
			Other versions (search for [world.byond_build] or higher): http://www.byond.com/download/build/[world.byond_version]</span>"

			cdel(client)

	verb/new_player_panel()
		set src = usr
		new_player_panel_proc()


	proc/new_player_panel_proc()
		var/output = "<div align='center'><B>New Player Options</B>"
		output +="<hr>"
		output += "<p><a href='byond://?src=\ref[src];lobby_choice=show_preferences'>Setup Character</A></p>"

		if(!ticker || !ticker.mode || ticker.current_state <= GAME_STATE_PREGAME)
			output += "<p>\[ [ready? "<b>Ready</b>":"<a href='byond://?src=\ref[src];lobby_choice=ready'>Ready</a>"] | [ready? "<a href='byond://?src=\ref[src];lobby_choice=ready'>Not Ready</a>":"<b>Not Ready</b>"] \]</p>"

		else
			output += "<a href='byond://?src=\ref[src];lobby_choice=manifest'>View the Crew Manifest</A><br><br>"
			output += "<p><a href='byond://?src=\ref[src];lobby_choice=late_join'>Join the USCM!</A></p>"
			output += "<p><a href='byond://?src=\ref[src];lobby_choice=late_join_xeno'>Join the Hive!</A></p>"
			if(ticker.mode.flags_round_type & MODE_PREDATOR)
				if(ticker.mode.check_predator_late_join(src,0)) output += "<p><a href='byond://?src=\ref[src];lobby_choice=late_join_pred'>Join the Hunt!</A></p>"

		output += "<p><a href='byond://?src=\ref[src];lobby_choice=observe'>Observe</A></p>"

		if(!IsGuestKey(src.key))
			establish_db_connection()

			if(dbcon.IsConnected())
				var/isadmin = 0
				if(src.client && src.client.holder)
					isadmin = 1
				var/DBQuery/query = dbcon.NewQuery("SELECT id FROM erro_poll_question WHERE [(isadmin ? "" : "adminonly = false AND")] Now() BETWEEN starttime AND endtime AND id NOT IN (SELECT pollid FROM erro_poll_vote WHERE ckey = \"[ckey]\") AND id NOT IN (SELECT pollid FROM erro_poll_textreply WHERE ckey = \"[ckey]\")")
				query.Execute()
				var/newpoll = 0
				while(query.NextRow())
					newpoll = 1
					break

				output += "<p><b><a href='byond://?src=\ref[src];lobby_choice=showpoll'>Show Player Polls</A>[newpoll?" (NEW!)":""]</b></p>"

		output += "</div>"

		src << browse(output,"window=playersetup;size=240x300;can_close=0")
		return

	Stat()
		if (!..())
			return 0

		stat("Map:", "[map_tag]")
		if(ticker.hide_mode)
			stat("Game Mode:", "Colonial Marines")
		else
			if(ticker.hide_mode == 0)
				stat("Game Mode:", "[master_mode]") // Old setting for showing the game mode

		if(ticker.current_state == GAME_STATE_PREGAME)
			stat("Time To Start:", "[ticker.pregame_timeleft][going ? "" : " (DELAYED)"]")
			stat("Players: [totalPlayers]", "Players Ready: [totalPlayersReady]")
			totalPlayers = 0
			totalPlayersReady = 0
			for(var/mob/new_player/player in player_list)
				stat("[player.key]", (player.ready)?("(Playing)"):(null))
				totalPlayers++
				if(player.ready)totalPlayersReady++

		return 1


	Topic(href, href_list[])
		if(!client)	return
		switch(href_list["lobby_choice"])
			if("show_preferences")
				client.prefs.ShowChoices(src)
				return 1

			if("ready")
				if(!ticker || ticker.current_state <= GAME_STATE_PREGAME) // Make sure we don't ready up after the round has started
					ready = !ready
				new_player_panel_proc()

			if("refresh")
				src << browse(null, "window=playersetup") //closes the player setup window
				new_player_panel_proc()

			if("observe")

				if(alert(src,"Are you sure you wish to observe? You will have to wait at least 5 minutes before being able to respawn!","Player Setup","Yes","No") == "Yes")
					if(!client)	return 1
					var/mob/dead/observer/observer = new()

					spawning = 1

					observer.started_as_observer = 1
					close_spawn_windows()
					var/obj/O = locate("landmark*Observer-Start")
					if(istype(O))
						src << "<span class='notice'>Now teleporting.</span>"
						observer.loc = O.loc
					else
						src << "<span class='danger'>Could not locate an observer spawn point. Use the Teleport verb to jump to the station map.</span>"
					observer.timeofdeath = world.time // Set the time of death so that the respawn timer works correctly.

					client.prefs.update_preview_icon()
					observer.icon = client.prefs.preview_icon
					observer.alpha = 127

					if(client.prefs.be_random_name)
						client.prefs.real_name = random_name(client.prefs.gender)
					observer.real_name = client.prefs.real_name
					observer.name = observer.real_name
	//				if(!client.holder && !config.antag_hud_allowed)           // For new ghosts we remove the verb from even showing up if it's not allowed.
	//					observer.verbs -= /mob/dead/observer/verb/toggle_antagHUD        // Poor guys, don't know what they are missing!
					observer.key = key
					if(observer.client) observer.client.change_view(world.view)
					cdel(src)

					return 1

			if("late_join")

				if(!ticker || ticker.current_state != GAME_STATE_PLAYING || !ticker.mode)
					src << "<span class='warning'>The round is either not ready, or has already finished...</span>"
					return

				if(ticker.mode.flags_round_type	& MODE_NO_LATEJOIN)
					src << "<span class='warning'>Sorry, you cannot late join during [ticker.mode.name]. You have to start at the beginning of the round. You may observe or try to join as an alien, if possible.</span>"
					return

				if(client.prefs.species != "Human")
					if(!is_alien_whitelisted(src, client.prefs.species) && config.usealienwhitelist)
						src << alert("You are currently not whitelisted to play [client.prefs.species].")
						return

					var/datum/species/S = all_species[client.prefs.species]
					if(!(S.flags & IS_WHITELISTED))
						src << alert("Your current species,[client.prefs.species], is not available for play on the station.")
						return

				LateChoices()

			if("late_join_xeno")
				if(!ticker || ticker.current_state != GAME_STATE_PLAYING || !ticker.mode)
					src << "<span class='warning'>The round is either not ready, or has already finished...</span>"
					return

				if(alert(src,"Are you sure you want to attempt joining as a xenomorph?","Confirmation","Yes","No") == "Yes" )
					if(ticker.mode.check_xeno_late_join(src))
						var/mob/new_xeno = ticker.mode.attempt_to_join_as_xeno(src, 0)
						if(new_xeno)
							close_spawn_windows(new_xeno)
							ticker.mode.transfer_xeno(src, new_xeno)

			if("late_join_pred")
				if(!ticker || ticker.current_state != GAME_STATE_PLAYING || !ticker.mode)
					src << "<span class='warning'>The round is either not ready, or has already finished...</span>"
					return

				if(alert(src,"Are you sure you want to attempt joining as a predator?","Confirmation","Yes","No") == "Yes" )
					if(ticker.mode.check_predator_late_join(src,0))
						close_spawn_windows()
						ticker.mode.attempt_to_join_as_predator(src)
					else
						src << "<span class='warning'>You are no longer able to join as predator.</span>"
						new_player_panel()

			if("manifest")
				ViewManifest()

			if("SelectedJob")

				if(!enter_allowed)
					usr << "<span class='warning'>There is an administrative lock on entering the game!</span>"
					return

				if(client.prefs.species != "Human")
					if(!is_alien_whitelisted(src, client.prefs.species) && config.usealienwhitelist)
						src << alert("You are currently not whitelisted to play [client.prefs.species].")
						return 0

					var/datum/species/S = all_species[client.prefs.species]
					if(!(S.flags & IS_WHITELISTED))
						src << alert("Your current species,[client.prefs.species], is not available for play on the station.")
						return 0

				AttemptLateSpawn(href_list["job_selected"],client.prefs.spawnpoint)
				return


			if("showpoll")
				handle_player_polling()
				return

			else
				if(!ready && href_list["preference"])
					if(client) client.prefs.process_link(src, href_list)
				else new_player_panel()

				/*
		else if(!href_list["late_join"])

		if("privacy_poll")
			establish_db_connection()
			if(!dbcon.IsConnected())
				return
			var/voted = 0

			//First check if the person has not voted yet.
			var/DBQuery/query = dbcon.NewQuery("SELECT * FROM erro_privacy WHERE ckey='[src.ckey]'")
			query.Execute()
			while(query.NextRow())
				voted = 1
				break

			//This is a safety switch, so only valid options pass through
			var/option = "UNKNOWN"
			switch(href_list["privacy_poll"])
				if("signed")
					option = "SIGNED"
				if("anonymous")
					option = "ANONYMOUS"
				if("nostats")
					option = "NOSTATS"
				if("later")
					usr << browse(null,"window=privacypoll")
					return
				if("abstain")
					option = "ABSTAIN"

			if(option == "UNKNOWN")
				return

			if(!voted)
				var/sql = "INSERT INTO erro_privacy VALUES (null, Now(), '[src.ckey]', '[option]')"
				var/DBQuery/query_insert = dbcon.NewQuery(sql)
				query_insert.Execute()
				usr << "<b>Thank you for your vote!</b>"
				usr << browse(null,"window=privacypoll")


		if("pollid")

			var/pollid = href_list["pollid"]
			if(istext(pollid))
				pollid = text2num(pollid)
			if(isnum(pollid))
				src.poll_player(pollid)
			return


		if(href_list["votepollid"] && href_list["votetype"])
			var/pollid = text2num(href_list["votepollid"])
			var/votetype = href_list["votetype"]
			switch(votetype)
				if("OPTION")
					var/optionid = text2num(href_list["voteoptionid"])
					vote_on_poll(pollid, optionid)
				if("TEXT")
					var/replytext = href_list["replytext"]
					log_text_poll_reply(pollid, replytext)
				if("NUMVAL")
					var/id_min = text2num(href_list["minid"])
					var/id_max = text2num(href_list["maxid"])

					if( (id_max - id_min) > 100 )	//Basic exploit prevention
						usr << "The option ID difference is too big. Please contact administration or the database admin."
						return

					for(var/optionid = id_min; optionid <= id_max; optionid++)
						if(!isnull(href_list["o[optionid]"]))	//Test if this optionid was replied to
							var/rating
							if(href_list["o[optionid]"] == "abstain")
								rating = null
							else
								rating = text2num(href_list["o[optionid]"])
								if(!isnum(rating))
									return

							vote_on_numval_poll(pollid, optionid, rating)
				if("MULTICHOICE")
					var/id_min = text2num(href_list["minoptionid"])
					var/id_max = text2num(href_list["maxoptionid"])

					if( (id_max - id_min) > 100 )	//Basic exploit prevention
						usr << "The option ID difference is too big. Please contact administration or the database admin."
						return

					for(var/optionid = id_min; optionid <= id_max; optionid++)
						if(!isnull(href_list["option_[optionid]"]))	//Test if this optionid was selected
							vote_on_poll(pollid, optionid, 1)
			*/

	proc/AttemptLateSpawn(rank, spawning_at)
		if (src != usr)
			return
		if(!ticker || ticker.current_state != GAME_STATE_PLAYING)
			usr << "<span class='warning'>The round is either not ready, or has already finished!<spawn>"
			return
		if(!enter_allowed)
			usr << "<span class='warning'>There is an administrative lock on entering the game!<spawn>"
			return
		if(!RoleAuthority.assign_role(src, RoleAuthority.roles_for_mode[rank], 1))
			src << alert("[rank] is not available. Please try another.")
			return

		spawning = 1
		close_spawn_windows()

		var/datum/spawnpoint/S //We need to find a spawn location for them.
		var/turf/T
		if(spawning_at) S = spawntypes[spawning_at]
		if(istype(S)) 	T = pick(S.turfs)
		else 			T = pick(latejoin)

		var/mob/living/carbon/human/character = create_character()	//creates the human and transfers vars and mind
		RoleAuthority.equip_role(character, RoleAuthority.roles_for_mode[rank], T)
		UpdateFactionList(character)
		EquipCustomItems(character)

		ticker.mode.latespawn(character)
		data_core.manifest_inject(character)
		ticker.minds += character.mind//Cyborgs and AIs handle this in the transform proc.	//TODO!!!!! ~Carn
		ticker.mode.latejoin_tally++

		for(var/datum/squad/sq in RoleAuthority.squads)
			if(sq)
				sq.max_engineers = engi_slot_formula(clients.len)
				sq.max_medics = medic_slot_formula(clients.len)

		if(ticker.mode.latejoin_larva_drop && ticker.mode.latejoin_tally >= ticker.mode.latejoin_larva_drop)
			ticker.mode.latejoin_tally -= ticker.mode.latejoin_larva_drop
			ticker.mode.stored_larva++

		cdel(src)

	proc/AnnounceArrival(var/mob/living/carbon/human/character, var/rank, var/join_message)
		if (ticker.current_state == GAME_STATE_PLAYING)
			var/obj/item/device/radio/intercom/a = new /obj/item/device/radio/intercom(null)// BS12 EDIT Arrivals Announcement Computer, rather than the AI.
			if(character.mind.role_alt_title) rank = character.mind.role_alt_title
			a.autosay("[character.real_name],[rank ? " [rank]," : " visitor," ] [join_message ? join_message : "has arrived on the station"].", "Arrivals Announcement Computer")
			cdel(a)

	proc/LateChoices()
		var/mills = world.time // 1/10 of a second, not real milliseconds but whatever
		//var/secs = ((mills % 36000) % 600) / 10 //Not really needed, but I'll leave it here for refrence.. or something
		var/mins = (mills % 36000) / 600
		var/hours = mills / 36000

		var/dat = "<html><body><center>"
		dat += "Round Duration: [round(hours)]h [round(mins)]m<br>"

		if(EvacuationAuthority)
			switch(EvacuationAuthority.evac_status)
				if(EVACUATION_STATUS_INITIATING) dat += "<font color='red'><b>The [MAIN_SHIP_NAME] is being evacuated.</b></font><br>"
				if(EVACUATION_STATUS_COMPLETE) dat += "<font color='red'>The [MAIN_SHIP_NAME] has undergone evacuation.</font><br>"

		dat += "Choose from the following open positions:<br>"
		var/datum/job/J
		var/i
		for(i in RoleAuthority.roles_for_mode)
			J = RoleAuthority.roles_for_mode[i]
			if(!RoleAuthority.check_role_entry(src, J, 1)) continue
			var/active = 0
			// Only players with the job assigned and AFK for less than 10 minutes count as active
			for(var/mob/M in player_list)
				if(M.mind && M.client && M.mind.assigned_role == J.title && M.client.inactivity <= 10 * 60 * 10)
					active++
			dat += "<a href='byond://?src=\ref[src];lobby_choice=SelectedJob;job_selected=[J.title]'>[J.disp_title] ([J.current_positions]) (Active: [active])</a><br>"

		dat += "</center>"
		src << browse(dat, "window=latechoices;size=300x640;can_close=1")


	proc/create_character()
		spawning = 1
		close_spawn_windows()

		var/mob/living/carbon/human/new_character

		var/datum/species/chosen_species
		if(client.prefs.species)
			chosen_species = all_species[client.prefs.species]
		if(chosen_species)
			// Have to recheck admin due to no usr at roundstart. Latejoins are fine though.
			if(is_species_whitelisted(chosen_species) || has_admin_rights())
				new_character = new(loc, client.prefs.species)

		if(!new_character)
			new_character = new(loc)

		new_character.lastarea = get_area(loc)

		var/datum/language/chosen_language
		if(client.prefs.language)
			chosen_language = all_languages["[client.prefs.language]"]
		if(chosen_language)
			if(is_alien_whitelisted(src, client.prefs.language) || !config.usealienwhitelist || !(chosen_language.flags & WHITELISTED) || (new_character.species && (chosen_language.name in new_character.species.secondary_langs)))
				new_character.add_language("[client.prefs.language]")

		if(ticker.random_players)
			new_character.gender = pick(MALE, FEMALE)
			client.prefs.real_name = random_name(new_character.gender)
			client.prefs.randomize_appearance_for(new_character)
		else
			client.prefs.copy_to(new_character)

		if(mind)
			mind.active = 0					//we wish to transfer the key manually
			mind.original = new_character
			mind.transfer_to(new_character)					//won't transfer key since the mind is not active

		new_character.name = real_name
		new_character.dna.ready_dna(new_character)

		if(client.prefs.disabilities)
			// Set defer to 1 if you add more crap here so it only recalculates struc_enzymes once. - N3X
			new_character.dna.SetSEState(GLASSESBLOCK,1,0)
			new_character.disabilities |= NEARSIGHTED

		// And uncomment this, too.
		//new_character.dna.UpdateSE()

		// Do the initial caching of the player's body icons.
		new_character.regenerate_icons()

		new_character.key = key		//Manually transfer the key to log them in
		if(new_character.client) new_character.client.change_view(world.view)

		return new_character

	proc/ViewManifest()
		var/dat = "<html><body>"
		dat += "<h4>Crew Manifest:</h4>"
		dat += data_core.get_manifest(OOC = 1)

		src << browse(dat, "window=manifest;size=400x420;can_close=1")

	Move()
		return 0

	proc/close_spawn_windows()
		src << browse(null, "window=latechoices") //closes late choices window
		src << browse(null, "window=playersetup") //closes the player setup window
		src << sound(null, repeat = 0, wait = 0, volume = 85, channel = 1) // Stops lobby music.

	proc/has_admin_rights()
		return client.holder.rights & R_ADMIN

	proc/is_species_whitelisted(datum/species/S)
		if(!S) return 1
		return is_alien_whitelisted(src, S.name) || !config.usealienwhitelist || !(S.flags & IS_WHITELISTED)

/mob/new_player/get_species()
	var/datum/species/chosen_species
	if(client.prefs.species)
		chosen_species = all_species[client.prefs.species]

	if(!chosen_species)
		return "Human"

	if(is_species_whitelisted(chosen_species) || has_admin_rights())
		return chosen_species.name

	return "Human"

/mob/new_player/get_gender()
	if(!client || !client.prefs) ..()
	return client.prefs.gender

/mob/new_player/is_ready()
	return ready && ..()

/mob/new_player/hear_say(var/message, var/verb = "says", var/datum/language/language = null, var/alt_name = "",var/italics = 0, var/mob/speaker = null)
	return

/mob/new_player/hear_radio(var/message, var/verb="says", var/datum/language/language=null, var/part_a, var/part_b, var/mob/speaker = null, var/hard_to_hear = 0)
	return
