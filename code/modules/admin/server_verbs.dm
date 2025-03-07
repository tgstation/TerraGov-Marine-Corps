ADMIN_VERB(restart, R_SERVER, "Restart", "Restarts the server after a short pause.", ADMIN_CATEGORY_SERVER)
	if(SSticker.admin_delay_notice && alert(user, "Are you sure? An admin has already delayed the round end for the following reason: [SSticker.admin_delay_notice]", "Confirmation", "Yes", "No") != "Yes")
		return

	if(alert(user, "Restart the game world?", "Restart", "Yes", "No") != "Yes")
		return

	var/message = FALSE
	if(CONFIG_GET(string/restart_message))
		switch(alert(user, "Send the new round message?", "Message", "Yes", "No", "Cancel"))
			if("Yes")
				message = TRUE
			if("Cancel")
				return

	to_chat(world, span_danger("Restarting world!</span> <span class='notice'>Initiated by: [user.ckey]"))

	log_admin("[key_name(user)] initiated a restart.")
	message_admins("[ADMIN_TPMONTY(user.mob)] initiated a restart.")

	spawn(50)
		world.Reboot(message)

// todo I don't think this works. update to tgsv6 api please
ADMIN_VERB(shutdown_server, R_SERVER, "Shutdown Server", "Shuts the server down.", ADMIN_CATEGORY_SERVER)
	var/static/shuttingdown = null
	var/static/timeouts = list()
	var/waitforroundend = FALSE
	if(!CONFIG_GET(flag/allow_shutdown))
		to_chat(usr, span_danger("This has not been enabled by the server operator."))
		return

	if(shuttingdown)
		if(alert("Are you use you want to cancel the shutdown initiated by [shuttingdown]?", "Cancel the shutdown?", "No", "Yes, Cancel the shutdown", "No.") != "Yes, Cancel the shutdown")
			return
		message_admins("[ADMIN_TPMONTY(user.mob)] Cancelled the server shutdown that [shuttingdown] started.")
		timeouts[shuttingdown] = world.time
		shuttingdown = FALSE
		return

	if(timeouts[user.ckey] && timeouts[user.ckey] + 2 MINUTES > world.time)
		to_chat(user, span_danger("You must wait 2 minutes after your shutdown attempt is aborted before you can try again."))
		return

	if(alert("Are you sure you want to shutdown the server? Only somebody with remote access to the server can turn it back on.", "Shutdown Server?", "Cancel", "Shutdown Server", "Cancel.") != "Shutdown Server")
		return

	if(!SSticker)
		if(alert("The game ticker does not exist, normal checks will be bypassed.", "Continue Shutting Down Server?", "Cancel", "Continue Shutting Down Server", "Cancel.") != "Continue Shutting Down Server")
			return
	else
		var/required_state_message = "The server must be in either pre-game and the start must be delayed or already started with the end delayed to shutdown the server."
		if((SSticker.current_state == GAME_STATE_PREGAME && SSticker.time_left > 0) || (SSticker.current_state != GAME_STATE_PREGAME && !SSticker.delay_end))
			to_chat(user, span_danger("[required_state_message] The round start/end is not delayed."))
			return
		if (SSticker.current_state == GAME_STATE_PLAYING || SSticker.current_state == GAME_STATE_SETTING_UP)
			if(alert("The round is currently in progress, continue with shutdown?", "Continue Shutting Down Server?", "Cancel", "Continue Shutting Down Server", "Cancel.") != "Continue Shutting Down Server")
				return
			waitforroundend = TRUE

	to_chat(user, span_danger("Alert: Delayed confirmation required. You will be asked to confirm again in 30 seconds."))
	message_admins("[ADMIN_TPMONTY(user.mob)] initiated the shutdown process. You may abort this by pressing the shutdown server button again.")
	shuttingdown = user.ckey

	sleep(30 SECONDS)

	if(!shuttingdown || shuttingdown != user.ckey)
		return

	if(!user)
		message_admins("[ADMIN_TPMONTY(user.mob)] left the server before they could finish confirming they wanted to shutdown the server.")
		shuttingdown = null
		return

	if(alert("ARE YOU SURE YOU WANT TO SHUTDOWN THE SERVER? ONLY SOMEBODY WITH REMOTE ACCESS TO THE SERVER CAN TURN IT BACK ON.", "Shutdown Server?", "Cancel", "Yes! Shutdown The Server!", "Cancel.") != "Yes! Shutdown The Server!")
		message_admins("[ADMIN_TPMONTY(user.mob)] decided against shutting down the server.")
		shuttingdown = null
		return
	to_chat(world, span_danger("Server shutting down [waitforroundend ? "after this round" : "in 30 seconds!"]</span> <span class='notice'>Initiated by: [usr.key]"))
	message_admins("[ADMIN_TPMONTY(user.mob)] is shutting down the server[waitforroundend ? " after this round" : ""]. You may abort this by pressing the shutdown server button again within 30 seconds.")

	sleep(31 SECONDS) //to give the admins that final second to hit the confirm button on the cancel prompt.
	if(!shuttingdown)
		to_chat(world, span_notice("Server shutdown was aborted"))
		return

	if(shuttingdown != user.ckey) //somebody cancelled but then somebody started again.
		return

	to_chat(world, span_danger("Server shutting down[waitforroundend ? " after this round. " : ""].</span> <span class='notice'>Initiated by: [shuttingdown]"))
	log_admin("Server shutting down[waitforroundend ? " after this round" : ""]. Initiated by: [shuttingdown]")
	if(GLOB.tgs)
		var/datum/tgs_api/TA = GLOB.tgs
		var/tgs3_path = CONFIG_GET(string/tgs3_commandline_path)
		if(fexists(tgs3_path))
			var/instancename = TA.InstanceName()
			if(instancename)
				shell("[tgs3_path] --instance [instancename] dd stop --graceful") //this tells tgstation-server to ignore us shutting down
				if (waitforroundend)
					message_admins("tgstation-server has been ordered to shutdown the server after the current round. The server shutdown can no longer be cancelled.")
			else
				var/msg = "WARNING: Couldn't find tgstation-server3 instancename, server might restart after shutdown."
				message_admins(msg)
				log_admin(msg)
		else
			var/msg = "WARNING: Couldn't find tgstation-server3 command line interface, server will very likely restart after shutdown."
			message_admins(msg)
			log_admin(msg)
	else
		var/msg = "WARNING: Couldn't find tgstation-server3 api object, server could restart after shutdown, but it will very likely be just fine"
		message_admins(msg)
		log_admin(msg)
	if (waitforroundend)
		return
	sleep(world.tick_lag) //so messages can get sent to players.
	qdel(world) //there are a few ways to shutdown the server, but this is by far my favorite

ADMIN_VERB(toggle_ooc, R_SERVER, "Toggle OOC", "Toggles OOC for non-admins.", ADMIN_CATEGORY_SERVER)
	GLOB.ooc_allowed = !GLOB.ooc_allowed

	if(GLOB.ooc_allowed)
		to_chat(world, span_boldnotice("The OOC channel has been globally enabled!"))
	else
		to_chat(world, span_boldnotice("The OOC channel has been globally disabled!"))

	log_admin("[key_name(user)] [GLOB.ooc_allowed ? "enabled" : "disabled"] OOC.")
	message_admins("[ADMIN_TPMONTY(user.mob)] [GLOB.ooc_allowed ? "enabled" : "disabled"] OOC.")

ADMIN_VERB(toggle_looc, R_SERVER, "Toggle LOOC", "Toggles LOOC for non-admins.", ADMIN_CATEGORY_SERVER)
	if(CONFIG_GET(flag/looc_enabled))
		CONFIG_SET(flag/looc_enabled, FALSE)
		to_chat(world, span_boldnotice("LOOC channel has been disabled!"))
	else
		CONFIG_SET(flag/looc_enabled, TRUE)
		to_chat(world, span_boldnotice("LOOC channel has been enabled!"))

	log_admin("[key_name(user)] has [CONFIG_GET(flag/looc_enabled) ? "enabled" : "disabled"] LOOC.")
	message_admins("[ADMIN_TPMONTY(user.mob)] has [CONFIG_GET(flag/looc_enabled) ? "enabled" : "disabled"] LOOC.")

ADMIN_VERB(toggle_deadchat, R_SERVER, "Toggle Deadchat", "Toggles deadchat for non-admins.", ADMIN_CATEGORY_SERVER)
	GLOB.dsay_allowed = !GLOB.dsay_allowed

	if(GLOB.dsay_allowed)
		to_chat(world, span_boldnotice("Deadchat has been globally enabled!"))
	else
		to_chat(world, span_boldnotice("Deadchat has been globally disabled!"))

	log_admin("[key_name(user)] [GLOB.dsay_allowed ? "enabled" : "disabled"] deadchat.")
	message_admins("[ADMIN_TPMONTY(user.mob)] [GLOB.dsay_allowed ? "enabled" : "disabled"] deadchat.")

ADMIN_VERB(toggle_deadooc, R_SERVER, "Toggle Dead OOC", "Toggles OOC for dead non-admins.", ADMIN_CATEGORY_SERVER)
	GLOB.dooc_allowed = !GLOB.dooc_allowed

	if(GLOB.dooc_allowed)
		to_chat(world, span_boldnotice("Dead player OOC has been globally enabled!"))
	else
		to_chat(world, span_boldnotice("Dead player OOC has been globally disabled!"))

	log_admin("[key_name(user)] [GLOB.dooc_allowed ? "enabled" : "disabled"] dead player OOC.")
	message_admins("[ADMIN_TPMONTY(user.mob)] [GLOB.dooc_allowed ? "enabled" : "disabled"] dead player OOC.")

ADMIN_VERB(start, R_SERVER, "Start Round", "Starts the round early.", ADMIN_CATEGORY_SERVER)
	if(SSticker.current_state != GAME_STATE_STARTUP && SSticker.current_state != GAME_STATE_PREGAME)
		to_chat(user, span_warning("The round has already started."))
		return

	if(SSticker.start_immediately)
		SSticker.start_immediately = FALSE
		log_admin("[key_name(user)] has cancelled the early round start.")
		message_admins("[ADMIN_TPMONTY(user.mob)] has cancelled the early round start.")
		return

	var/msg = "has started the round early."
	if(SSticker.setup_failed)
		if(tgui_alert(user, "Previous setup failed. Would you like to try again, bypassing the checks? Win condition checking will also be paused.", "Start Round", list("Yes", "No"),  0) != "Yes")
			return
		msg += " Bypassing roundstart checks."
		SSticker.bypass_checks = TRUE
		SSticker.roundend_check_paused = TRUE

	else if(tgui_alert(user, "Are you sure you want to start the round early?", "Start Round", list("Yes", "No"), 0) != "Yes")
		return

	if(SSticker.current_state == GAME_STATE_STARTUP)
		msg += " The round is still setting up, but the round will be started as soon as possible. You may abort this by trying to start early again."

	SSticker.start_immediately = TRUE
	log_admin("[key_name(user)] [msg]")
	message_admins("[ADMIN_TPMONTY(user.mob)] [msg]")

ADMIN_VERB(toggle_join, R_SERVER, "Toggle Joining", "Players can still log into the server, but marines won't be able to join the game as a new mob.", ADMIN_CATEGORY_SERVER)
	GLOB.enter_allowed = !GLOB.enter_allowed

	if(GLOB.enter_allowed)
		to_chat(world, span_boldnotice("New players may now join the game."))
	else
		to_chat(world, span_boldnotice("New players may no longer join the game."))

	log_admin("[key_name(user)] [GLOB.enter_allowed ? "enabled" : "disabled"] new player joining.")
	message_admins("[ADMIN_TPMONTY(user.mob)] [GLOB.enter_allowed ? "enabled" : "disabled"] new player joining.")

ADMIN_VERB(toggle_respawn, R_SERVER, "Toggle Respawn", "Allows players to respawn.", ADMIN_CATEGORY_SERVER)
	GLOB.respawn_allowed = !GLOB.respawn_allowed

	if(GLOB.respawn_allowed)
		to_chat(world, span_boldnotice("You may now respawn."))
	else
		to_chat(world, span_boldnotice("You may no longer respawn."))

	log_admin("[key_name(user)] [GLOB.respawn_allowed ? "enabled" : "disabled"] respawning.")
	message_admins("[ADMIN_TPMONTY(user.mob)] [GLOB.respawn_allowed ? "enabled" : "disabled"] respawning.")

ADMIN_VERB(set_respawn_time, R_SERVER, "Set Respawn Timer", "Sets the global respawn timer.", ADMIN_CATEGORY_SERVER)
	var/time = tgui_input_number(user, "How many ticks should the timer be?")
	if(time < 0)
		return

	SSticker.mode?.respawn_time = time

	log_admin("[key_name(user)] set the respawn time to [SSticker.mode?.respawn_time * 0.1] seconds.")
	message_admins("[ADMIN_TPMONTY(user.mob)] set the respawn time to [SSticker.mode?.respawn_time * 0.1] seconds.")

ADMIN_VERB(end_round, R_SERVER, "End Round", "Immediately ends the round, be very careful", ADMIN_CATEGORY_SERVER)
	if(!SSticker?.mode)
		return

	if(tgui_alert(user, "Are you sure you want to end the round?", "End Round", list("Yes", "No"), 0) != "Yes")
		return

	var/winstate = tgui_input_list(user, "What do you want the round end state to be?", "End Round", list("Custom", "Admin Intervention") + SSticker.mode.round_end_states, timeout = 0)
	if(!winstate)
		return

	if(winstate == "Custom")
		winstate = tgui_input_text(user, "Please enter a custom round end state.", "End Round", timeout = 0)
		if(!winstate)
			return

	SSticker.force_ending = TRUE
	SSticker.mode.round_finished = winstate

	log_admin("[key_name(user)] has made the round end early - [winstate].")
	message_admins("[ADMIN_TPMONTY(user.mob)] has made the round end early - [winstate].")

ADMIN_VERB(delay_start, R_SERVER, "Delay Round Start", "Delay the start of the round", ADMIN_CATEGORY_SERVER)
	if(!SSticker)
		return

	var/newtime = input(user, "Set a new time in seconds. Set -1 for indefinite delay.", "Set Delay", round(SSticker.GetTimeLeft())) as num|null
	if(SSticker.current_state > GAME_STATE_PREGAME)
		return
	if(isnull(newtime))
		return

	newtime = newtime * 10
	SSticker.SetTimeLeft(newtime)
	if(newtime < 0)
		to_chat(world, span_boldnotice("The game start has been delayed."))
		log_admin("[key_name(user)] delayed the round start.")
		message_admins("[ADMIN_TPMONTY(user.mob)] delayed the round start.")
	else
		to_chat(world, span_boldnotice("The game will start in [DisplayTimeText(newtime)]."))
		log_admin("[key_name(user)] set the pre-game delay to [DisplayTimeText(newtime)].")
		message_admins("[ADMIN_TPMONTY(user.mob)] set the pre-game delay to [DisplayTimeText(newtime)].")

ADMIN_VERB(delay_end, R_SERVER, "Delay Round End", "Delay the round end", ADMIN_CATEGORY_SERVER)
	if(!SSticker)
		return

	if(SSticker.admin_delay_notice)
		if(alert(user, "Do you want to remove the round end delay?", "Delay Round End", "Yes", "No") != "Yes")
			return
		SSticker.admin_delay_notice = null
	else
		var/reason = input(user, "Enter a reason for delaying the round end", "Round Delay Reason") as null|text
		if(!reason)
			return
		if(SSticker.admin_delay_notice)
			to_chat(user, span_warning("Someone already delayed the round end meanwhile."))
			return
		SSticker.admin_delay_notice = reason

	SSticker.delay_end = !SSticker.delay_end

	log_admin("[key_name(user)] [SSticker.delay_end ? "delayed the round-end[SSticker.admin_delay_notice ? " for reason: [SSticker.admin_delay_notice]" : ""]" : "made the round end normally"].")
	message_admins("<hr><h4>[ADMIN_TPMONTY(user.mob)] [SSticker.delay_end ? "delayed the round-end[SSticker.admin_delay_notice ? " for reason: [SSticker.admin_delay_notice]" : ""]" : "made the round end normally"].</h4><hr>")

ADMIN_VERB(toggle_gun_restrictions, R_FUN, "Toggle Gun Restrictions", "Toggle restriction on MP guns", ADMIN_CATEGORY_FUN)
	if(!config)
		return

	if(CONFIG_GET(flag/remove_gun_restrictions)) // todo kill me we dont have MPs
		CONFIG_SET(flag/remove_gun_restrictions, FALSE)
	else
		CONFIG_SET(flag/remove_gun_restrictions, TRUE)

	log_admin("[key_name(user)] has [CONFIG_GET(flag/remove_gun_restrictions) ? "enabled" : "disabled"] gun restrictions.")
	message_admins("[ADMIN_TPMONTY(user.mob)] has [CONFIG_GET(flag/remove_gun_restrictions) ? "enabled" : "disabled"] gun restrictions.")

ADMIN_VERB(toggle_synthetic_restrictions, R_FUN, "Toggle Synthetic Restrictions", "Enabling this will allow synthetics to use weapons.", ADMIN_CATEGORY_FUN)
	if(!config) // todo this config is useless
		return

	if(CONFIG_GET(flag/allow_synthetic_gun_use))
		CONFIG_SET(flag/allow_synthetic_gun_use, FALSE)
	else
		CONFIG_SET(flag/allow_synthetic_gun_use, TRUE)

	log_admin("[key_name(user)] has [CONFIG_GET(flag/allow_synthetic_gun_use) ? "enabled" : "disabled"] synthetic weapon use.")
	message_admins("[ADMIN_TPMONTY(user.mob)] has [CONFIG_GET(flag/allow_synthetic_gun_use) ? "enabled" : "disabled"] synthetic weapon use.")

ADMIN_VERB(reload_admins, R_SERVER, "Reload Admins", "Manually load all admins from the .txt", ADMIN_CATEGORY_SERVER)
	if(alert(user, "Are you sure you want to reload admins?", "Reload admins", "No", "Yes") != "Yes")
		return

	load_admins()

	log_admin("[key_name(user)] manually reloaded admins.")
	message_admins("[ADMIN_TPMONTY(user.mob)] manually reloaded admins.")

ADMIN_VERB(reload_configuration, R_SERVER, "Reload Configuration", "Reloads the configuration from the default path on the disk, wiping any in-round modifications.", ADMIN_CATEGORY_SERVER)
	if(tgui_alert(user, "Are you absolutely sure you want to reload the configuration from the default path on the disk, wiping any in-round modifications?", "Really reset?", list("No", "Yes")) != "Yes")
		return
	config.admin_reload()

ADMIN_VERB(change_ground_map, R_SERVER, "Change Ground Map", "Change Ground Map for the next round.", ADMIN_CATEGORY_SERVER)
	var/list/maprotatechoices = list()
	for(var/map in config.maplist[GROUND_MAP])
		var/datum/map_config/VM = config.maplist[GROUND_MAP][map]
		var/mapname = VM.map_name
		if(VM == config.defaultmaps[GROUND_MAP])
			mapname += " (Default)"

		if(VM.config_min_users > 0 || VM.config_max_users > 0)
			mapname += " \["
			if(VM.config_min_users > 0)
				mapname += "[VM.config_min_users]"
			else
				mapname += "0"
			mapname += "-"
			if(VM.config_max_users > 0)
				mapname += "[VM.config_max_users]"
			else
				mapname += "inf"
			mapname += "\]"

		maprotatechoices[mapname] = VM

	var/chosenmap = tgui_input_list(user, "Choose a ground map to change to", "Change Ground Map", maprotatechoices, timeout = 0)
	if(!chosenmap)
		return

	var/datum/map_config/VM = maprotatechoices[chosenmap]
	if(!SSmapping.changemap(VM, GROUND_MAP))
		to_chat(user, span_warning("Failed to change the ground map."))
		return

	log_admin("[key_name(user)] changed the map to [VM.map_name].")
	message_admins("[ADMIN_TPMONTY(user.mob)] changed the map to [VM.map_name].")

ADMIN_VERB(change_ship_map, R_SERVER, "Change Ship Map", "Change Ship Map for the next round.", ADMIN_CATEGORY_SERVER)
	var/list/maprotatechoices = list()
	for(var/map in config.maplist[SHIP_MAP])
		var/datum/map_config/VM = config.maplist[SHIP_MAP][map]
		var/mapname = VM.map_name
		if(VM == config.defaultmaps[SHIP_MAP])
			mapname += " (Default)"

		if(VM.config_min_users > 0 || VM.config_max_users > 0)
			mapname += " \["
			if(VM.config_min_users > 0)
				mapname += "[VM.config_min_users]"
			else
				mapname += "0"
			mapname += "-"
			if(VM.config_max_users > 0)
				mapname += "[VM.config_max_users]"
			else
				mapname += "inf"
			mapname += "\]"

		maprotatechoices[mapname] = VM

	var/chosenmap = tgui_input_list(user, "Choose a ship map to change to", "Change Ship Map", maprotatechoices, timeout = 0)
	if(!chosenmap)
		return

	var/datum/map_config/VM = maprotatechoices[chosenmap]
	if(!SSmapping.changemap(VM, SHIP_MAP))
		to_chat(user, span_warning("Failed to change the ship map."))
		return

	log_admin("[key_name(user)] changed the ship map to [VM.map_name].")
	message_admins("[ADMIN_TPMONTY(user.mob)] changed the ship map to [VM.map_name].")

ADMIN_VERB(panic_bunker, R_SERVER, "Toggle Panic Bunker", "Toggle new players being permitted to join the server.", ADMIN_CATEGORY_SERVER)
	if(!CONFIG_GET(flag/sql_enabled))
		to_chat(user, span_adminnotice("The Database is not enabled!"))
		return

	CONFIG_SET(flag/panic_bunker, !CONFIG_GET(flag/panic_bunker))

	log_admin("[key_name(user)] has [CONFIG_GET(flag/panic_bunker) ? "enabled" : "disabled"] the panic bunker.")
	message_admins("[ADMIN_TPMONTY(user.mob)] has [CONFIG_GET(flag/panic_bunker) ? "enabled" : "disabled"] the panic bunker.")

ADMIN_VERB(mode_check, R_SERVER, "Toggle Mode Check", "Toggle checking if the round can end.", ADMIN_CATEGORY_SERVER)
	SSticker.roundend_check_paused = !SSticker.roundend_check_paused

	log_admin("[key_name(user)] has [SSticker.roundend_check_paused ? "disabled" : "enabled"] gamemode end condition checking.")
	message_admins("[ADMIN_TPMONTY(user.mob)] has [SSticker.roundend_check_paused ? "disabled" : "enabled"] gamemode end condition checking.")

ADMIN_VERB(toggle_cdn, R_SERVER, "Toggle CDN", "Toggle the Content Delivery Network for asset download.", ADMIN_CATEGORY_SERVER)
	var/static/admin_disabled_cdn_transport = null
	if (alert(usr, "Are you sure you want to toggle the CDN asset transport?", "Confirm", "Yes", "No") != "Yes")
		return
	var/current_transport = CONFIG_GET(string/asset_transport)
	if (!current_transport || current_transport == "simple")
		if (admin_disabled_cdn_transport)
			CONFIG_SET(string/asset_transport, admin_disabled_cdn_transport)
			admin_disabled_cdn_transport = null
			SSassets.OnConfigLoad()
			message_admins("[key_name_admin(user)] re-enabled the CDN asset transport")
			log_admin("[key_name(user)] re-enabled the CDN asset transport")
		else
			to_chat(user, span_adminnotice("The CDN is not enabled!"))
			if (alert(user, "The CDN asset transport is not enabled! If you having issues with assets you can also try disabling filename mutations.", "The CDN asset transport is not enabled!", "Try disabling filename mutations", "Nevermind") == "Try disabling filename mutations")
				SSassets.transport.dont_mutate_filenames = !SSassets.transport.dont_mutate_filenames
				message_admins("[key_name_admin(user)] [(SSassets.transport.dont_mutate_filenames ? "disabled" : "re-enabled")] asset filename transforms")
				log_admin("[key_name(user)] [(SSassets.transport.dont_mutate_filenames ? "disabled" : "re-enabled")] asset filename transforms")
	else
		admin_disabled_cdn_transport = current_transport
		CONFIG_SET(string/asset_transport, "simple")
		SSassets.OnConfigLoad()
		SSassets.transport.dont_mutate_filenames = TRUE
		message_admins("[key_name_admin(user)] disabled the CDN asset transport")
		log_admin("[key_name(user)] disabled the CDN asset transport")

ADMIN_VERB(toggle_valhalla, R_SERVER, "Toggle Valhalla joining", "Toggle players ability to join valhalla.", ADMIN_CATEGORY_SERVER)
	GLOB.valhalla_allowed = !GLOB.valhalla_allowed

	log_admin("[key_name(user)] [GLOB.valhalla_allowed ? "enabled" : "disabled"] valhalla joining.")
	message_admins("[ADMIN_TPMONTY(user.mob)] [GLOB.valhalla_allowed ? "enabled" : "disabled"] valhalla joining.")

ADMIN_VERB(toggle_sdd_possesion, R_SERVER, "Toggle taking over SSD mobs", "Allows players to take over SSD mobs.", ADMIN_CATEGORY_SERVER)
	GLOB.ssd_posses_allowed = !GLOB.ssd_posses_allowed

	log_admin("[key_name(user)] [GLOB.ssd_posses_allowed ? "enabled" : "disabled"] taking over SSD mobs.")
	message_admins("[ADMIN_TPMONTY(user.mob)] [GLOB.ssd_posses_allowed ? "enabled" : "disabled"] taking over SSD mobs.")
