/datum/admins/proc/restart()
	set category = "Server"
	set name = "Restart"
	set desc = "Restarts the server after a short pause."

	if(!check_rights(R_SERVER))
		return

	if(SSticker.admin_delay_notice && alert(usr, "Are you sure? An admin has already delayed the round end for the following reason: [SSticker.admin_delay_notice]", "Confirmation", "Yes", "No") != "Yes")
		return

	if(alert("Restart the game world?", "Restart", "Yes", "No") != "Yes")
		return

	var/message = FALSE
	if(CONFIG_GET(string/restart_message))
		switch(alert("Send the new round message?", "Message", "Yes", "No", "Cancel"))
			if("Yes")
				message = TRUE
			if("Cancel")
				return

	to_chat(world, "<span class='danger'>Restarting world!</span> <span class='notice'>Initiated by: [usr.key]</span>")

	log_admin("[key_name(usr)] initiated a restart.")
	message_admins("[ADMIN_TPMONTY(usr)] initiated a restart.")

	spawn(50)
		world.Reboot(message)


/datum/admins/proc/shutdown_server()
	set category = "Server"
	set name = "Shutdown Server"
	set desc = "Shuts the server down."

	var/static/shuttingdown = null
	var/static/timeouts = list()
	var/waitforroundend = FALSE
	if(!CONFIG_GET(flag/allow_shutdown))
		to_chat(usr, "<span class='danger'>This has not been enabled by the server operator.</span>")
		return

	if(!check_rights(R_SERVER))
		return

	if(shuttingdown)
		if(alert("Are you use you want to cancel the shutdown initiated by [shuttingdown]?", "Cancel the shutdown?", "No", "Yes, Cancel the shutdown", "No.") != "Yes, Cancel the shutdown")
			return
		message_admins("[ADMIN_TPMONTY(usr)] Cancelled the server shutdown that [shuttingdown] started.")
		timeouts[shuttingdown] = world.time
		shuttingdown = FALSE
		return

	if(timeouts[usr.ckey] && timeouts[usr.ckey] + 2 MINUTES > world.time)
		to_chat(usr, "<span class='danger'>You must wait 2 minutes after your shutdown attempt is aborted before you can try again.</span>")
		return

	if(alert("Are you sure you want to shutdown the server? Only somebody with remote access to the server can turn it back on.", "Shutdown Server?", "Cancel", "Shutdown Server", "Cancel.") != "Shutdown Server")
		return

	if(!SSticker)
		if(alert("The game ticker does not exist, normal checks will be bypassed.", "Continue Shutting Down Server?", "Cancel", "Continue Shutting Down Server", "Cancel.") != "Continue Shutting Down Server")
			return
	else
		var/required_state_message = "The server must be in either pre-game and the start must be delayed or already started with the end delayed to shutdown the server."
		if((SSticker.current_state == GAME_STATE_PREGAME && SSticker.time_left > 0) || (SSticker.current_state != GAME_STATE_PREGAME && !SSticker.delay_end))
			to_chat(usr, "<span class='danger'>[required_state_message] The round start/end is not delayed.</span>")
			return
		if (SSticker.current_state == GAME_STATE_PLAYING || SSticker.current_state == GAME_STATE_SETTING_UP)
			#ifdef TGS_V3_API
			if(alert("The round is currently in progress, continue with shutdown?", "Continue Shutting Down Server?", "Cancel", "Continue Shutting Down Server", "Cancel.") != "Continue Shutting Down Server")
				return
			waitforroundend = TRUE
			#else
			to_chat(usr, "<span class='danger'>Restarting during the round requires the server toolkit. No server toolkit detected. Please end the round and try again.</span>")
			return
			#endif

	to_chat(usr, "<span class='danger'>Alert: Delayed confirmation required. You will be asked to confirm again in 30 seconds.</span>")
	message_admins("[ADMIN_TPMONTY(usr)] initiated the shutdown process. You may abort this by pressing the shutdown server button again.")
	shuttingdown = usr.ckey

	sleep(30 SECONDS)

	if(!shuttingdown || shuttingdown != usr.ckey)
		return

	if(!usr?.client)
		message_admins("[ADMIN_TPMONTY(usr)] left the server before they could finish confirming they wanted to shutdown the server.")
		shuttingdown = null
		return

	if(alert("ARE YOU SURE YOU WANT TO SHUTDOWN THE SERVER? ONLY SOMEBODY WITH REMOTE ACCESS TO THE SERVER CAN TURN IT BACK ON.", "Shutdown Server?", "Cancel", "Yes! Shutdown The Server!", "Cancel.") != "Yes! Shutdown The Server!")
		message_admins("[ADMIN_TPMONTY(usr)] decided against shutting down the server.")
		shuttingdown = null
		return
	to_chat(world, "<span class='danger'>Server shutting down [waitforroundend ? "after this round" : "in 30 seconds!"]</span> <span class='notice'>Initiated by: [usr.key]</span>")
	message_admins("[ADMIN_TPMONTY(usr)] is shutting down the server[waitforroundend ? " after this round" : ""]. You may abort this by pressing the shutdown server button again within 30 seconds.")

	sleep(31 SECONDS) //to give the admins that final second to hit the confirm button on the cancel prompt.

	if(!shuttingdown)
		to_chat(world, "<span class='notice'>Server shutdown was aborted</span>")
		return

	if(shuttingdown != usr.ckey) //somebody cancelled but then somebody started again.
		return

	to_chat(world, "<span class='danger'>Server shutting down[waitforroundend ? " after this round. " : ""].</span> <span class='notice'>Initiated by: [shuttingdown]</span>")
	log_admin("Server shutting down[waitforroundend ? " after this round" : ""]. Initiated by: [shuttingdown]")

#ifdef TGS_V3_API
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
#endif
	if (waitforroundend)
		return
	sleep(world.tick_lag) //so messages can get sent to players.
	qdel(world) //there are a few ways to shutdown the server, but this is by far my favorite


/datum/admins/proc/toggle_ooc()
	set category = "Server"
	set name = "Toggle OOC"
	set desc = "Toggles OOC for non-admins."

	if(!check_rights(R_SERVER))
		return

	GLOB.ooc_allowed = !(GLOB.ooc_allowed)

	if(GLOB.ooc_allowed)
		to_chat(world, "<span class='boldnotice'>The OOC channel has been globally enabled!</span>")
	else
		to_chat(world, "<span class='boldnotice'>The OOC channel has been globally disabled!</span>")

	log_admin("[key_name(usr)] [GLOB.ooc_allowed ? "enabled" : "disabled"] OOC.")
	message_admins("[ADMIN_TPMONTY(usr)] [GLOB.ooc_allowed ? "enabled" : "disabled"] OOC.")


/datum/admins/proc/toggle_looc()
	set category = "Server"
	set name = "Toggle LOOC"
	set desc = "Toggles LOOC for non-admins."

	if(!check_rights(R_SERVER))
		return

	if(CONFIG_GET(flag/looc_enabled))
		CONFIG_SET(flag/looc_enabled, FALSE)
		to_chat(world, "<span class='boldnotice'>LOOC channel has been disabled!</span>")
	else
		CONFIG_SET(flag/looc_enabled, TRUE)
		to_chat(world, "<span class='boldnotice'>LOOC channel has been enabled!</span>")


	log_admin("[key_name(usr)] has [CONFIG_GET(flag/looc_enabled) ? "enabled" : "disabled"] LOOC.")
	message_admins("[ADMIN_TPMONTY(usr)] has [CONFIG_GET(flag/looc_enabled) ? "enabled" : "disabled"] LOOC.")


/datum/admins/proc/toggle_deadchat()
	set category = "Server"
	set name = "Toggle Deadchat"
	set desc = "Toggles deadchat for non-admins."

	if(!check_rights(R_SERVER))
		return

	GLOB.dsay_allowed = !GLOB.dsay_allowed

	if(GLOB.dsay_allowed)
		to_chat(world, "<span class='boldnotice'>Deadchat has been globally enabled!</span>")
	else
		to_chat(world, "<span class='boldnotice'>Deadchat has been globally disabled!</span>")

	log_admin("[key_name(usr)] [GLOB.dsay_allowed ? "enabled" : "disabled"] deadchat.")
	message_admins("[ADMIN_TPMONTY(usr)] [GLOB.dsay_allowed ? "enabled" : "disabled"] deadchat.")


/datum/admins/proc/toggle_deadooc()
	set category = "Server"
	set name = "Toggle Dead OOC"
	set desc = "Toggle the ability for dead non-admins to use OOC chat."

	if(!check_rights(R_SERVER))
		return

	GLOB.dooc_allowed = !GLOB.dooc_allowed

	if(GLOB.dooc_allowed)
		to_chat(world, "<span class='boldnotice'>Dead player OOC has been globally enabled!</span>")
	else
		to_chat(world, "<span class='boldnotice'>Dead player OOC has been globally disabled!</span>")

	log_admin("[key_name(usr)] [GLOB.dooc_allowed ? "enabled" : "disabled"] dead player OOC.")
	message_admins("[ADMIN_TPMONTY(usr)] [GLOB.dooc_allowed ? "enabled" : "disabled"] dead player OOC.")


/datum/admins/proc/start()
	set category = "Server"
	set name = "Start Round"
	set desc = "Starts the round early."

	if(!check_rights(R_SERVER))
		return

	if(SSticker.current_state != GAME_STATE_STARTUP && SSticker.current_state != GAME_STATE_PREGAME)
		to_chat(usr, "<span class='warning'>The round has already started.</span>")
		return

	if(SSticker.start_immediately)
		SSticker.start_immediately = FALSE
		log_admin("[key_name(usr)] has cancelled the early round start.")
		message_admins("[ADMIN_TPMONTY(usr)] has cancelled the early round start.")
		return

	var/msg = "has started the round early."

	if(SSticker.setup_failed)
		if(alert("Previous setup failed. Would you like to try again, bypassing the checks? Win condition checking will also be paused.", "Start Round", "Yes", "No") != "Yes")
			return
		msg += " Bypassing roundstart checks."
		SSticker.bypass_checks = TRUE
		SSticker.roundend_check_paused = TRUE

	else if(alert("Are you sure you want to start the round early?", "Start Round", "Yes", "No") == "No")
		return

	if(SSticker.current_state == GAME_STATE_STARTUP)
		msg += " The round is still setting up, but the round will be started as soon as possible. You may abort this by trying to start early again."

	SSticker.start_immediately = TRUE
	log_admin("[key_name(usr)] [msg]")
	message_admins("[ADMIN_TPMONTY(usr)] [msg]")


/datum/admins/proc/toggle_join()
	set category = "Server"
	set name = "Toggle Joining"
	set desc = "Players can still log into the server, but marines won't be able to join the game as a new mob."

	if(!check_rights(R_SERVER))
		return

	GLOB.enter_allowed = !GLOB.enter_allowed

	if(GLOB.enter_allowed)
		to_chat(world, "<span class='boldnotice'>New players may now join the game.</span>")
	else
		to_chat(world, "<span class='boldnotice'>New players may no longer join the game.</span>")

	log_admin("[key_name(usr)] [GLOB.enter_allowed ? "enabled" : "disabled"] new player joining.")
	message_admins("[ADMIN_TPMONTY(usr)] [GLOB.enter_allowed ? "enabled" : "disabled"] new player joining.")


/datum/admins/proc/toggle_respawn()
	set category = "Server"
	set name = "Toggle Respawn"
	set desc = "Allows players to respawn."

	if(!check_rights(R_SERVER))
		return

	GLOB.respawn_allowed = !GLOB.respawn_allowed

	if(GLOB.respawn_allowed)
		to_chat(world, "<span class='boldnotice'>You may now respawn.</span>")
	else
		to_chat(world, "<span class='boldnotice'>You may no longer respawn.</span>")

	log_admin("[key_name(usr)] [GLOB.respawn_allowed ? "enabled" : "disabled"] respawning.")
	message_admins("[ADMIN_TPMONTY(usr)] [GLOB.respawn_allowed ? "enabled" : "disabled"] respawning.")


/datum/admins/proc/set_respawn_time(time as num)
	set category = "Server"
	set name = "Set Respawn Timer"
	set desc = "Sets the global respawn timer."

	if(!check_rights(R_SERVER))
		return

	if(time < 0)
		return

	GLOB.respawntime = time

	log_admin("[key_name(usr)] set the respawn time to [GLOB.respawntime * 0.1] seconds.")
	message_admins("[ADMIN_TPMONTY(usr)] set the respawn time to [GLOB.respawntime * 0.1] seconds.")


/datum/admins/proc/set_xenorespawn_time(time as num)
	set category = "Server"
	set name = "Set Xeno Respawn Timer"
	set desc = "Sets the global xeno respawn timer."

	if(!check_rights(R_SERVER))
		return

	if(time < 0)
		return

	GLOB.xenorespawntime = time

	log_admin("[key_name(usr)] set the xeno respawn time to [GLOB.xenorespawntime * 0.1] seconds.")
	message_admins("[ADMIN_TPMONTY(usr)] set the xeno respawn time to [GLOB.xenorespawntime * 0.1] seconds.")


/datum/admins/proc/end_round()
	set category = "Server"
	set name = "End Round"
	set desc = "Immediately ends the round, be very careful"

	if(!check_rights(R_SERVER))
		return

	if(!SSticker?.mode)
		return

	if(alert("Are you sure you want to end the round?", "End Round", "Yes", "No") != "Yes")
		return

	var/winstate = input(usr, "What do you want the round end state to be?", "End Round") as null|anything in list("Custom", "Admin Intervention") + SSticker.mode.round_end_states
	if(!winstate)
		return

	if(winstate == "Custom")
		winstate = input(usr, "Please enter a custom round end state.", "End Round") as null|text
		if(!winstate)
			return

	SSticker.force_ending = TRUE
	SSticker.mode.round_finished = winstate

	log_admin("[key_name(usr)] has made the round end early - [winstate].")
	message_admins("[ADMIN_TPMONTY(usr)] has made the round end early - [winstate].")


/datum/admins/proc/delay_start()
	set category = "Server"
	set name = "Delay Round Start"

	if(!check_rights(R_SERVER))
		return

	if(!SSticker)
		return

	var/newtime = input("Set a new time in seconds. Set -1 for indefinite delay.", "Set Delay", round(SSticker.GetTimeLeft())) as num|null
	if(SSticker.current_state > GAME_STATE_PREGAME)
		return
	if(isnull(newtime))
		return

	newtime = newtime * 10
	SSticker.SetTimeLeft(newtime)
	if(newtime < 0)
		to_chat(world, "<span class='boldnotice'>The game start has been delayed.</span>")
		log_admin("[key_name(usr)] delayed the round start.")
		message_admins("[ADMIN_TPMONTY(usr)] delayed the round start.")
	else
		to_chat(world, "<span class='boldnotice'>The game will start in [DisplayTimeText(newtime)].</span>")
		log_admin("[key_name(usr)] set the pre-game delay to [DisplayTimeText(newtime)].")
		message_admins("[ADMIN_TPMONTY(usr)] set the pre-game delay to [DisplayTimeText(newtime)].")


/datum/admins/proc/delay_end()
	set category = "Server"
	set name = "Delay Round End"

	if(!check_rights(R_SERVER))
		return

	if(!SSticker)
		return

	if(SSticker.admin_delay_notice)
		if(alert(usr, "Do you want to remove the round end delay?", "Delay Round End", "Yes", "No") != "Yes")
			return
		SSticker.admin_delay_notice = null
	else
		var/reason = input(usr, "Enter a reason for delaying the round end", "Round Delay Reason") as null|text
		if(!reason)
			return
		if(SSticker.admin_delay_notice)
			to_chat(usr, "<span class='warning'>Someone already delayed the round end meanwhile.</span>")
			return
		SSticker.admin_delay_notice = reason

	SSticker.delay_end = !SSticker.delay_end

	log_admin("[key_name(usr)] [SSticker.delay_end ? "delayed the round-end[SSticker.admin_delay_notice ? " for reason: [SSticker.admin_delay_notice]" : ""]" : "made the round end normally"].")
	message_admins("<hr><h4>[ADMIN_TPMONTY(usr)] [SSticker.delay_end ? "delayed the round-end[SSticker.admin_delay_notice ? " for reason: [SSticker.admin_delay_notice]" : ""]" : "made the round end normally"].</h4><hr>")


/datum/admins/proc/toggle_gun_restrictions()
	set name = "Toggle Gun Restrictions"
	set category = "Server"
	set desc = "Currently only affects MP guns."

	if(!check_rights(R_SERVER))
		return

	if(!config)
		return

	if(CONFIG_GET(flag/remove_gun_restrictions))
		CONFIG_SET(flag/remove_gun_restrictions, FALSE)
	else
		CONFIG_SET(flag/remove_gun_restrictions, TRUE)

	log_admin("[key_name(usr)] has [CONFIG_GET(flag/remove_gun_restrictions) ? "enabled" : "disabled"] gun restrictions.")
	message_admins("[ADMIN_TPMONTY(usr)] has [CONFIG_GET(flag/remove_gun_restrictions) ? "enabled" : "disabled"] gun restrictions.")


/datum/admins/proc/toggle_synthetic_restrictions()
	set category = "Server"
	set name = "Toggle Synthetic Restrictions"
	set desc = "Enabling this will allow synthetics to use weapons."

	if(!check_rights(R_SERVER))
		return

	if(!config)
		return

	if(CONFIG_GET(flag/allow_synthetic_gun_use))
		CONFIG_SET(flag/allow_synthetic_gun_use, FALSE)
	else
		CONFIG_SET(flag/allow_synthetic_gun_use, TRUE)

	log_admin("[key_name(src)] has [CONFIG_GET(flag/allow_synthetic_gun_use) ? "enabled" : "disabled"] synthetic weapon use.")
	message_admins("[ADMIN_TPMONTY(usr)] has [CONFIG_GET(flag/allow_synthetic_gun_use) ? "enabled" : "disabled"] synthetic weapon use.")


/datum/admins/proc/reload_admins()
	set category = "Server"
	set name = "Reload Admins"
	set desc = "Manually load all admins from the .txt"

	if(!check_rights(R_SERVER))
		return

	load_admins()

	log_admin("[key_name(src)] manually reloaded admins.")
	message_admins("[ADMIN_TPMONTY(usr)] manually reloaded admins.")


/datum/admins/proc/change_ground_map()
	set category = "Server"
	set name = "Change Ground Map"

	if(!check_rights(R_SERVER))
		return

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

	var/chosenmap = input("Choose a ground map to change to", "Change Ground Map") as null|anything in maprotatechoices
	if(!chosenmap)
		return

	var/datum/map_config/VM = maprotatechoices[chosenmap]
	if(!SSmapping.changemap(VM, GROUND_MAP))
		to_chat(usr, "<span class='warning'>Failed to change the ground map.</span>")
		return

	log_admin("[key_name(usr)] changed the map to [VM.map_name].")
	message_admins("[ADMIN_TPMONTY(usr)] changed the map to [VM.map_name].")


/datum/admins/proc/change_ship_map()
	set category = "Server"
	set name = "Change Ship Map"

	if(!check_rights(R_SERVER))
		return

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

	var/chosenmap = input("Choose a ship map to change to", "Change Ship Map") as null|anything in maprotatechoices
	if(!chosenmap)
		return

	var/datum/map_config/VM = maprotatechoices[chosenmap]
	if(!SSmapping.changemap(VM, SHIP_MAP))
		to_chat(usr, "<span class='warning'>Failed to change the ship map.</span>")
		return

	log_admin("[key_name(usr)] changed the ship map to [VM.map_name].")
	message_admins("[ADMIN_TPMONTY(usr)] changed the ship map to [VM.map_name].")


/datum/admins/proc/panic_bunker()
	set category = "Server"
	set name = "Toggle Panic Bunker"

	if(!check_rights(R_SERVER))
		return

	if(!CONFIG_GET(flag/sql_enabled))
		to_chat(usr, "<span class='adminnotice'>The Database is not enabled!</span>")
		return

	CONFIG_SET(flag/panic_bunker, !CONFIG_GET(flag/panic_bunker))

	log_admin("[key_name(usr)] has [CONFIG_GET(flag/panic_bunker) ? "enabled" : "disabled"] the panic bunker.")
	message_admins("[ADMIN_TPMONTY(usr)] has [CONFIG_GET(flag/panic_bunker) ? "enabled" : "disabled"] the panic bunker.")


/datum/admins/proc/mode_check()
	set category = "Server"
	set name = "Toggle Mode Check"

	if(!check_rights(R_SERVER))
		return

	SSticker.roundend_check_paused = !SSticker.roundend_check_paused

	log_admin("[key_name(usr)] has [SSticker.roundend_check_paused ? "disabled" : "enabled"] gamemode end condition checking.")
	message_admins("[ADMIN_TPMONTY(usr)] has [SSticker.roundend_check_paused ? "disabled" : "enabled"] gamemode end condition checking.")
