/client/proc/restart()
	set category = "Server"
	set name = "Restart"
	set desc = "Restarts the server after a short pause."

	if(!check_rights(R_SERVER))
		return

	if(alert("Restart the game world?", "Restart", "Yes", "No") != "Yes")
		return

	to_chat(world, "<span class='danger'>Restarting world!</span><br><span class='notice'>Initiated by: [key_name(usr)]</span>")

	log_admin("[key_name(usr)] initiated a restart.")
	message_admins("[key_name_admin(usr)] initiated a restart.")

	spawn(50)
		world.Reboot()


/client/proc/toggle_ooc()
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

	log_admin("[key_name(usr)] toggled OOC.")
	message_admins("[key_name_admin(usr)] toggled OOC.")


/client/proc/toggle_deadchat()
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

	log_admin("[key_name(usr)] toggled deadchat.")
	message_admins("[key_name_admin(usr)] toggled deadchat.")


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

	log_admin("[key_name(usr)] toggled Dead OOC.")
	message_admins("[key_name_admin(usr)] toggled Dead OOC.")


/datum/admins/proc/start()
	set category = "Server"
	set name = "Start Round"
	set desc = "Start the round RIGHT NOW"

	if(!check_rights(R_SERVER))
		return

	if(!ticker)
		return

	if(ticker.current_state == GAME_STATE_PREGAME)
		ticker.current_state = GAME_STATE_SETTING_UP
		log_admin("[usr.key] has started the game.")
		message_admins("<font color='blue'>[usr.key] has started the game.</font>")
		feedback_add_details("admin_verb","SN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		return TRUE
	else
		to_chat(usr, "<font color='red'>Error: Start Now: Game has already started.</font>")
		return FALSE


/datum/admins/proc/toggle_join()
	set category = "Server"
	set name = "Toggle Joining"
	set desc = "Players can still log into the server, but Marines won't be able to join the game as a new mob."

	enter_allowed = !(enter_allowed)

	if(enter_allowed)
		to_chat(world, "<B>New players may now join the game.</B>")
	else
		to_chat(world, "<B>New players may no longer join the game.</B>")

	log_admin("[key_name(usr)] toggled new player game joining.")
	message_admins("[key_name_admin(usr)] toggled new player game joining.")


/datum/admins/proc/toggle_respawn()
	set category = "Server"
	set desc = "Respawn basically"
	set name = "Toggle Respawn"

	abandon_allowed = !( abandon_allowed )
	if(abandon_allowed)
		to_chat(world, "<B>You may now respawn.</B>")
	else
		to_chat(world, "<B>You may no longer respawn :(</B>")

	message_admins("<span class='notice'> [key_name_admin(usr)] toggled respawn to [abandon_allowed ? "On" : "Off"].</span>", 1)
	log_admin("[key_name(usr)] toggled respawn to [abandon_allowed ? "On" : "Off"].")


/datum/admins/proc/toggleatime(time as num)
	set category = "Server"
	set desc = "Sets the respawn time"
	set name = "Set Respawn Timer"

	if(time >= 0)
		respawntime = time
	else
		to_chat(usr, "The respawn time cannot be a negative number!")

	message_admins("<span class='notice'> [key_name_admin(usr)] set the respawn time to [respawntime] minutes.</span>", 1)
	log_admin("[key_name(usr)] set the respawn time to [respawntime] minutes.")


/datum/admins/proc/end_round()
	set category = "Server"
	set desc = "Immediately ends the round, be very careful"
	set name = "End Round"

	if(!check_rights(R_SERVER))
		return

	if(ticker)
		var/confirm = input("Are you sure you want to end the round?", "Are you sure:") in list("Yes", "No")
		if(confirm != "Yes") return
		ticker.mode.round_finished = MODE_INFESTATION_DRAW_DEATH
		log_admin("[key_name(usr)] has made the round end early.")
		message_admins("<span class='notice'> [key_name(usr)] has made the round end early.</span>", 1)
		for(var/client/C in admins)
			to_chat(C, "<hr>")
			to_chat(C, "<span class='centerbold'>Staff-Only Alert: <EM>[usr.key]</EM> has made the round end early")
			to_chat(C, "<hr>")

		return


/datum/admins/proc/delay()
	set category = "Server"
	set name = "Delay"
	set desc = "Delay the game start or end."

	if(!check_rights(R_SERVER))
		return

	if(!ticker || ticker.current_state != GAME_STATE_PREGAME)
		ticker.delay_end = !ticker.delay_end
		log_admin("[key_name(usr)] [ticker.delay_end ? "delayed the round end" : "has made the round end normally"].")
		message_admins("<span class='notice'> [key_name(usr)] [ticker.delay_end ? "delayed the round end" : "has made the round end normally"].</span>", 1)
		for(var/client/C in admins)
			to_chat(C, "<hr>")
			to_chat(C, "<span class='centerbold'>Staff-Only Alert: <EM>[usr.key]</EM> [ticker.delay_end ? "delayed the round end" : "has made the round end normally"]")
			to_chat(C, "<hr>")

		return //alert("Round end delayed", null, null, null, null, null)
	going = !( going )
	if (!( going ))
		to_chat(world, "<hr>")
		to_chat(world, "<span class='centerbold'>The game start has been delayed.</span>")
		to_chat(world, "<hr>")
		log_admin("[key_name(usr)] delayed the game.")
	else
		to_chat(world, "<hr>")
		to_chat(world, "<span class='centerbold'>The game will start soon!</span>")
		to_chat(world, "<hr>")
		log_admin("[key_name(usr)] removed the delay.")


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
	message_admins("[key_name_admin(usr)] has [CONFIG_GET(flag/remove_gun_restrictions) ? "enabled" : "disabled"] gun restrictions.")


/datum/admins/proc/toggle_synthetic_restrictions()
	set name = "Toggle Synthetic Restrictions"
	set category = "Server"
	set desc = "Toggling to on will allow synthetics to use weapons."

	if(!check_rights(R_SERVER))
		return

	if(!config)
		return

	if(CONFIG_GET(flag/allow_synthetic_gun_use))
		CONFIG_SET(flag/allow_synthetic_gun_use, FALSE)
	else
		CONFIG_SET(flag/allow_synthetic_gun_use, TRUE)

	log_admin("[key_name(src)] has [CONFIG_GET(flag/allow_synthetic_gun_use) ? "enabled" : "disabled"] synthetic weapon use.")
	message_admins("[key_name_admin(usr)] has [CONFIG_GET(flag/allow_synthetic_gun_use) ? "enabled" : "disabled"] synthetic weapon use.")


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

	log_admin("[key_name(usr)] changed global accuracy to [accuracy] and global damage to [damage].")
	message_admins("[key_name_admin(src)] changed global accuracy to [accuracy] and global damage to [damage].")


/datum/admins/proc/reload_admins()
	set category = "Server"
	set name = "Reload Admins"
	set desc = "Manually load all admins from the .txt"

	if(!check_rights(R_SERVER))
		return

	load_admins()

	log_admin("[key_name(src)] manually reloaded admins.")
	message_admins("[key_name_admin(usr)] manually reloaded admins.")


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
	message_admins("[key_name_admin(usr)] manually reloaded the role whitelist.")