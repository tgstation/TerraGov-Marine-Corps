/datum/admins/proc/restart()
	set category = "Server"
	set name = "Restart"
	set desc = "Restarts the server after a short pause."

	if(!check_rights(R_SERVER))
		return

	if(alert("Restart the game world?", "Restart", "Yes", "No") != "Yes")
		return

	to_chat(world, "<span class='danger'>Restarting world!</span> <span class='notice'>Initiated by: [usr.key]</span>")

	log_admin("[key_name(usr)] initiated a restart.")
	message_admins("[ADMIN_TPMONTY(usr)] initiated a restart.")

	spawn(50)
		world.Reboot()

/datum/admins/proc/shutdown_server()
	set category = "Server"
	set name = "Shutdown Server"
	set desc = "Shuts the server down."

	var/static/shuttingdown = null
	var/static/timeouts = list()
	if (!CONFIG_GET(flag/allow_shutdown))
		to_chat(usr, "<span class='danger'>This has not been enabled by the server operator.</span>")
		return

	if (!check_rights(R_SERVER))
		return

	if (shuttingdown)
		if (alert("Are you use you want to cancel the shutdown initiated by [shuttingdown]?", "Cancel the shutdown?", "No", "Yes, Cancel the shutdown", "No.") != "Yes, Cancel the shutdown")
			return
		message_admins("[ADMIN_TPMONTY(usr)] Cancelled the server shutdown that [shuttingdown] started.")
		timeouts[shuttingdown] = world.time
		shuttingdown = FALSE
		return

	if (timeouts[usr.ckey] && timeouts[usr.ckey] + 2 MINUTES > world.time)
		to_chat(usr, "<span class='danger'>You must wait 2 minutes after your shutdown attempt is aborted before you can try again.</span>")
		return

	if (alert("Are you sure you want to shutdown the server? Only somebody with remote access to the server can turn it back on.", "Shutdown Server?", "Cancel", "Shutdown Server", "Cancel.") != "Shutdown Server")
		return

	if (!SSticker)
		if (alert("The game ticker does not exist, normal checks will be bypassed.", "Continue Shutting Down Server?", "Cancel", "Continue Shutting Down Server", "Cancel.") != "Continue Shutting Down Server")
			return
	else
		var/required_state_message = "The server must be in either pre-game or post-game and the start/end must be delayed to shutdown the server."
		if (SSticker.current_state != GAME_STATE_PREGAME && SSticker.current_state != GAME_STATE_FINISHED)
			to_chat(usr, "<span class='danger'>[required_state_message] The round is not in the lobby or endgame state.</span>")
			return
		if ((SSticker.current_state == GAME_STATE_PREGAME && going) || (SSticker.current_state == GAME_STATE_FINISHED && !SSticker.delay_end))
			to_chat(usr, "<span class='danger'>[required_state_message] The round start/end is not delayed.</span>")
			return

	to_chat(usr, "<span class='danger'>Alert: Delayed confirmation required. You will be asked to confirm again in 30 seconds.</span>")
	message_admins("[ADMIN_TPMONTY(usr)] Is considering shutting down the server. Admins with +server may abort this by pressing the shutdown server button again.")
	shuttingdown = usr.ckey

	sleep(30 SECONDS)

	if (!shuttingdown || shuttingdown != usr.ckey)
		return

	if (!usr?.client)
		message_admins("[ADMIN_TPMONTY(usr)] left the server before they could finish confirming they wanted to shutdown the server.")
		shuttingdown = null
		return

	if (alert("ARE YOU SURE YOU WANT TO SHUTDOWN THE SERVER? ONLY SOMEBODY WITH REMOTE ACCESS TO THE SERVER CAN TURN IT BACK ON.", "Shutdown Server?", "Cancel", "Yes! Shutdown The Server!", "Cancel.") != "Yes! Shutdown The Server!")
		message_admins("[ADMIN_TPMONTY(usr)] decided against shutting down the server.")
		shuttingdown = null
		return

	to_chat(world, "<span class='danger'>Server shutting down in 30 seconds!</span> <span class='notice'>Initiated by: [usr.key]</span>")
	message_admins("[ADMIN_TPMONTY(usr)] Is shutting down the server. Admins with +server may abort this by pressing the shutdown server button again within 30 seconds.")

	sleep(31 SECONDS) //to give the admins that final second to hit the confirm button on the cancel prompt.

	if (!shuttingdown)
		to_chat(world, "<span class='notice'>Server shutdown was aborted</span>")
		return

	if (shuttingdown != usr.ckey) //somebody cancelled but then somebody started again.
		return

	to_chat(world, "<span class='danger'>Server shutting down.</span> <span class='notice'>Initiated by: [shuttingdown]</span>")

	if (GLOB.tgs)
		var/datum/tgs_api/TA = GLOB.tgs
		TA.EndProcess()

	sleep(world.tick_lag)
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

	if(!config)
		return

	if(CONFIG_GET(flag/looc_enabled))
		CONFIG_SET(flag/looc_enabled, FALSE)
		to_chat(world, "<span class='boldnotice'>LOOC channel has been enabled!</span>")
	else
		CONFIG_SET(flag/looc_enabled, TRUE)
		to_chat(world, "<span class='boldnotice'>LOOC channel has been disabled!</span>")


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

	if(!SSticker || SSticker.current_state != GAME_STATE_PREGAME)
		return

	if(alert("Are you sure you want to start the round early?", "Confirmation","Yes","No") != "Yes")
		return

	SSticker.current_state = GAME_STATE_SETTING_UP

	log_admin("[key_name(usr)] has started the game early.")
	message_admins("[ADMIN_TPMONTY(usr)] has started the game early.")


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

	respawntime = time

	log_admin("[key_name(usr)] set the respawn time to [respawntime] minutes.")
	message_admins("[ADMIN_TPMONTY(usr)] set the respawn time to [respawntime] minutes.")


/datum/admins/proc/end_round()
	set category = "Server"
	set desc = "Immediately ends the round, be very careful"
	set name = "End Round"

	if(!check_rights(R_SERVER))
		return

	if(!SSticker?.mode)
		return

	if(alert("Are you sure you want to end the round?", "Confirmation", "Yes","No") != "Yes")
		return

	SSticker.mode.round_finished = MODE_INFESTATION_M_MINOR

	log_admin("[key_name(usr)] has made the round end early.")
	message_admins("[ADMIN_TPMONTY(usr)] has made the round end early.")


/datum/admins/proc/delay()
	set category = "Server"
	set name = "Delay"
	set desc = "Delay the game start or end."

	if(!check_rights(R_SERVER))
		return

	if(!SSticker)
		return

	if(SSticker.current_state != GAME_STATE_PREGAME)
		SSticker.delay_end = !SSticker.delay_end
	else
		to_chat(world, "<hr><span class='centerbold'>The game [!going ? "will start soon" : "start has been delayed"].</span><hr>")

	going = !going

	log_admin("[key_name(usr)] [!going ? "delayed the round start/end" : "made the round start/end normally"].")
	message_admins("[ADMIN_TPMONTY(usr)] [!going ? "delayed the round start/end" : "made the round start/end normally"].")


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


/datum/admins/proc/reload_whitelist()
	set category = "Server"
	set name = "Reload Whitelist"
	set desc = "Manually load the whitelisted players from the .txt"

	if(!check_rights(R_SERVER))
		return

	if(!SSjob)
		return

	SSjob.load_whitelist()

	log_admin("[key_name(usr)] manually reloaded the role whitelist.")
	message_admins("[ADMIN_TPMONTY(usr)] manually reloaded the role whitelist.")