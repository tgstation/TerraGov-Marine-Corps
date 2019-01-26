/datum/admins/proc/restart()
	set category = "Server"
	set name = "Restart"
	set desc = "Restarts the server after a short pause."

	if(!check_rights(R_SERVER))
		return

	if(alert("Restart the game world?", "Restart", "Yes", "No") != "Yes")
		return

	to_chat(world, "<span class='danger'>Restarting world!</span><br><span class='notice'>Initiated by: [usr.key]</span>")

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

	ooc_allowed = !(ooc_allowed)

	if(ooc_allowed)
		to_chat(world, "<span class='boldnotice'>The OOC channel has been globally enabled!</span>")
	else
		to_chat(world, "<span class='boldnotice'>The OOC channel has been globally disabled!</span>")

	log_admin("[key_name(usr)] [ooc_allowed ? "enabled" : "disabled"] OOC.")
	message_admins("[ADMIN_TPMONTY(usr)] [ooc_allowed ? "enabled" : "disabled"] OOC.")


/datum/admins/proc/toggle_deadchat()
	set category = "Server"
	set name = "Toggle Deadchat"
	set desc = "Toggles deadchat for non-admins."

	if(!check_rights(R_SERVER))
		return

	dsay_allowed = !dsay_allowed

	if(dsay_allowed)
		to_chat(world, "<span class='boldnotice'>Deadchat has been globally enabled!</span>")
	else
		to_chat(world, "<span class='boldnotice'>Deadchat has been globally disabled!</span>")

	log_admin("[key_name(usr)] [dsay_allowed ? "enabled" : "disabled"] deadchat.")
	message_admins("[ADMIN_TPMONTY(usr)] [dsay_allowed ? "enabled" : "disabled"] deadchat.")


/datum/admins/proc/toggle_deadooc()
	set category = "Server"
	set name = "Toggle Dead OOC"
	set desc = "Toggle the ability for dead non-admins to use OOC chat."

	if(!check_rights(R_SERVER))
		return

	dooc_allowed = !dooc_allowed

	if(dsay_allowed)
		to_chat(world, "<span class='boldnotice'>Dead player OOC has been globally enabled!</span>")
	else
		to_chat(world, "<span class='boldnotice'>Dead player OOC has been globally disabled!</span>")

	log_admin("[key_name(usr)] [dooc_allowed ? "enabled" : "disabled"] dead player OOC.")
	message_admins("[ADMIN_TPMONTY(usr)] [dooc_allowed ? "enabled" : "disabled"] dead player OOC.")


/datum/admins/proc/start()
	set category = "Server"
	set name = "Start Round"
	set desc = "Starts the round early."

	if(!check_rights(R_SERVER))
		return

	if(!ticker || ticker.current_state != GAME_STATE_PREGAME)
		return

	if(alert("Are you sure you want to start the round early?", "Confirmation","Yes","No") != "Yes")
		return

	ticker.current_state = GAME_STATE_SETTING_UP

	log_admin("[key_name(usr)] has started the game early.")
	message_admins("[ADMIN_TPMONTY(usr)] has started the game early.")


/datum/admins/proc/toggle_join()
	set category = "Server"
	set name = "Toggle Joining"
	set desc = "Players can still log into the server, but marines won't be able to join the game as a new mob."

	if(!check_rights(R_SERVER))
		return

	enter_allowed = !enter_allowed

	if(enter_allowed)
		to_chat(world, "<span class='boldnotice'>New players may now join the game.</span>")
	else
		to_chat(world, "<span class='boldnotice'>New players may no longer join the game.</span>")

	log_admin("[key_name(usr)] [enter_allowed ? "enabled" : "disabled"] new player joining.")
	message_admins("[ADMIN_TPMONTY(usr)] [enter_allowed ? "enabled" : "disabled"] new player joining.")


/datum/admins/proc/toggle_respawn()
	set category = "Server"
	set name = "Toggle Respawn"
	set desc = "Allows players to respawn."

	if(!check_rights(R_SERVER))
		return

	respawn_allowed = !respawn_allowed

	if(respawn_allowed)
		to_chat(world, "<span class='boldnotice'>You may now respawn.</span>")
	else
		to_chat(world, "<span class='boldnotice'>You may no longer respawn.</span>")

	log_admin("[key_name(usr)] [respawn_allowed ? "enabled" : "disabled"] respawning.")
	message_admins("[ADMIN_TPMONTY(usr)] [respawn_allowed ? "enabled" : "disabled"] respawning.")


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

	if(!ticker?.mode)
		return

	if(alert("Are you sure you want to end the round?", "Confirmation", "Yes","No") != "Yes")
		return

	ticker.mode.round_finished = MODE_INFESTATION_M_MINOR

	log_admin("[key_name(usr)] has made the round end early.")
	message_admins("[ADMIN_TPMONTY(usr)] has made the round end early.")


/datum/admins/proc/delay()
	set category = "Server"
	set name = "Delay"
	set desc = "Delay the game start or end."

	if(!check_rights(R_SERVER))
		return

	if(!ticker)
		return

	if(ticker.current_state != GAME_STATE_PREGAME)
		ticker.delay_end = !ticker.delay_end
	else
		to_chat(world, "<hr><span class='centerbold'>The game [!going ? "game will start soon" : "start has been delayed"].</span><hr>")

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


/datum/admins/proc/adjust_weapon_mult()
	set category = "Server"
	set name = "Adjust Weapon Multipliers"
	set desc = "Adjusts the global weapons multipliers."

	if(!check_rights(R_SERVER))
		return

	if(!config)
		return

	var/accuracy = input("Select the new accuracy multiplier.", "ACCURACY MULTIPLIER", TRUE) as num
	var/damage = input("Select the new damage multiplier.", "DAMAGE MULTIPLIER", TRUE) as num

	if(accuracy < 0 || damage < 0)
		return

	CONFIG_SET(number/combat_define/proj_base_accuracy_mult, accuracy)
	CONFIG_SET(number/combat_define/proj_base_damage_mult, damage)

	log_admin("[key_name(usr)] changed global accuracy multiplier to [accuracy] and global damage multiplier to [damage].")
	message_admins("[ADMIN_TPMONTY(usr)] changed global accuracy multiplier to [accuracy] and global damage multiplier to [damage].")


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

	if(!RoleAuthority)
		return

	RoleAuthority.load_whitelist()

	log_admin("[key_name(usr)] manually reloaded the role whitelist.")
	message_admins("[ADMIN_TPMONTY(usr)] manually reloaded the role whitelist.")