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


/datum/admins/proc/delay_start()
	set category = "Server"
	set name = "Delay Round-Start"
	set desc = "Delay the game start."

	if(!check_rights(R_SERVER))
		return

	if(!SSticker)
		return

	var/newtime = input("Set a new time in seconds. Set -1 for indefinite delay.", "Set Delay", round(SSticker.GetTimeLeft())) as num|null
	if(SSticker.current_state > GAME_STATE_PREGAME)
		return
	if(isnull(newtime))
		return

	newtime = newtime*10
	SSticker.SetTimeLeft(newtime)
	if(newtime < 0)
		going = FALSE
		to_chat(world, "<span class='boldnotice'>The game start has been delayed.</span>")
		log_admin("[key_name(usr)] delayed the round start.")
		message_admins("[ADMIN_TPMONTY(usr)] delayed the round start.")
	else
		going = TRUE
		to_chat(world, "<span class='boldnotice'>The game will start in [DisplayTimeText(newtime)].</span>")
		log_admin("[key_name(usr)] set the pre-game delay to [DisplayTimeText(newtime)].")
		message_admins("[ADMIN_TPMONTY(usr)] set the pre-game delay to [DisplayTimeText(newtime)].")


/datum/admins/proc/delay_end()
	set category = "Server"
	set name = "Delay Round-End"
	set desc = "Delay the game end."


	SSticker.delay_end = !SSticker.delay_end

	log_admin("[key_name(usr)] [SSticker.delay_end ? "delayed the round-end" : "made the round end normally"].")
	message_admins("[ADMIN_TPMONTY(usr)] [SSticker.delay_end ? "delayed the round-end" : "made the round end normally"].")


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