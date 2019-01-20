/client/proc/restart()
	set category = "Server"
	set name = "Restart"
	set desc = "Restarts the server."
	set waitfor = FALSE

	if(!check_rights(R_SERVER))
		return

	if(alert("Restart the game world?", "Restart", "Yes", "No") != "Yes")
		return

	to_chat(world, "<span class='danger'>Restarting world!</span><br><span class='notice'>Initiated by: [key_name(usr)]</span>")
	log_admin("[key_name(usr)] initiated a restart.")

	sleep(50)
	world.Reboot()

/client/proc/toggle_ooc()
	set category = "Server"
	set name = "Toggle OOC"
	set desc = "Toggles OOC for non-admins."

	if(!check_rights(R_SERVER))
		return

	ooc_allowed = !(ooc_allowed)

	if(ooc_allowed)
		to_chat(world, "<B>The OOC channel has been globally enabled!</B>")
	else
		to_chat(world, "<B>The OOC channel has been globally disabled!</B>")

	log_admin("[key_name(usr)] toggled OOC.")
	message_admins("[key_name_admin(usr)] toggled OOC.")


/client/proc/toggle_deadchat()
	set category = "Server"
	set name = "Toggle Deadchat"
	set desc = "Toggles deadchat for non-admins."

	if(!check_rights(R_SERVER))
		return

	dsay_allowed = !( dsay_allowed )
	if(dsay_allowed)
		to_chat(world, "<B>Deadchat has been globally enabled!</B>")
	else
		to_chat(world, "<B>Deadchat has been globally disabled!</B>")
	log_admin("[key_name(usr)] toggled deadchat.")
	message_admins("[key_name_admin(usr)] toggled deadchat.", 1)
	feedback_add_details("admin_verb","TDSAY") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc


/datum/admins/proc/toggle_deadooc()
	set category = "Server"
	set desc = "Toggle the ability for dead people to use OOC chat"
	set name = "Toggle Dead OOC"


	dooc_allowed = !( dooc_allowed )

	log_admin("[key_name(usr)] toggled Dead OOC.")
	message_admins("[key_name_admin(usr)] toggled Dead OOC.", 1)
	feedback_add_details("admin_verb","TDOOC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/datum/admins/proc/toggletraitorscaling()
	set category = "Server"
	set desc="Toggle traitor scaling"
	set name="Toggle Traitor Scaling"
	traitor_scaling = !traitor_scaling
	log_admin("[key_name(usr)] toggled Traitor Scaling to [traitor_scaling].")
	message_admins("[key_name_admin(usr)] toggled Traitor Scaling [traitor_scaling ? "on" : "off"].", 1)
	feedback_add_details("admin_verb","TTS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/datum/admins/proc/startnow()
	set category = "Server"
	set desc = "Start the round RIGHT NOW"
	set name = "Start Now"
	if(!ticker)
		alert("Unable to start the game as it is not set up.")
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


/datum/admins/proc/togglejoin()
	set category = "Server"
	set desc="Players can still log into the server, but Marines won't be able to join the game as a new mob."
	set name="Toggle Joining"

	enter_allowed = !( enter_allowed )
	if (!( enter_allowed ))
		to_chat(world, "<B>New players may no longer join the game.</B>")
	else
		to_chat(world, "<B>New players may now join the game.</B>")
	log_admin("[key_name(usr)] toggled new player game joining.")
	message_admins("<span class='notice'> [key_name_admin(usr)] toggled new player game joining.</span>", 1)
	world.update_status()
	feedback_add_details("admin_verb","TE") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/datum/admins/proc/toggleAI()
	set category = "Server"
	set desc="People can't be AI"
	set name="Toggle AI"
	if(CONFIG_GET(flag/allow_ai))
		CONFIG_SET(flag/allow_ai, FALSE)
		to_chat(world, "<B>The AI job is no longer chooseable.</B>")
	else
		CONFIG_SET(flag/allow_ai, TRUE)
		to_chat(world, "<B>The AI job is chooseable now.</B>")
	log_admin("[key_name(usr)] toggled the AI job.")
	world.update_status()
	feedback_add_details("admin_verb","TAI") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/datum/admins/proc/toggleaban()
	set category = "Server"
	set desc = "Respawn basically"
	set name = "Toggle Respawn"

	abandon_allowed = !( abandon_allowed )
	if (abandon_allowed)
		to_chat(world, "<B>You may now respawn.</B>")
	else
		to_chat(world, "<B>You may no longer respawn :(</B>")
	message_admins("<span class='notice'> [key_name_admin(usr)] toggled respawn to [abandon_allowed ? "On" : "Off"].</span>", 1)
	log_admin("[key_name(usr)] toggled respawn to [abandon_allowed ? "On" : "Off"].")
	world.update_status()
	feedback_add_details("admin_verb","TR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/datum/admins/proc/toggleatime(time as num)
	set category = "Server"
	set desc="Sets the respawn time"
	set name="Set Respawn Timer"
	if (time >= 0)
		respawntime = time
	else
		to_chat(usr, "The respawn time cannot be a negative number!")
	message_admins("<span class='notice'> [key_name_admin(usr)] set the respawn time to [respawntime] minutes.</span>", 1)
	log_admin("[key_name(usr)] set the respawn time to [respawntime] minutes.")
	world.update_status()
	feedback_add_details("admin_verb","TRT") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/datum/admins/proc/end_round()
	set category = "Server"
	set desc="Immediately ends the round, be very careful"
	set name="End Round"

	if(!check_rights(R_SERVER))	return
	if (ticker)
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
	set desc="Delay the game start/end"
	set name="Delay"

	if(!check_rights(R_SERVER))	return
	if (!ticker || ticker.current_state != GAME_STATE_PREGAME)
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
	feedback_add_details("admin_verb","DELAY") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/adjump()
	set category = "Server"
	set desc="Toggle admin jumping"
	set name="Toggle Jump"

	if(CONFIG_GET(flag/allow_admin_jump))
		CONFIG_SET(flag/allow_admin_jump, FALSE)
		message_admins("<span class='notice'>Disabled admin jumping.</span>")
	else
		CONFIG_SET(flag/allow_admin_jump, TRUE)
		message_admins("<span class='notice'>Enabled admin jumping.</span>")

/datum/admins/proc/adspawn()
	set category = "Server"
	set desc="Toggle admin spawning"
	set name="Toggle Spawn"

	if(CONFIG_GET(flag/allow_admin_spawning))
		CONFIG_SET(flag/allow_admin_spawning, FALSE)
		message_admins("<span class='notice'>Disabled item spawning.</span>")
	else
		CONFIG_SET(flag/allow_admin_spawning, TRUE)
		message_admins("<span class='notice'>Enabled item spawning.</span>")

/datum/admins/proc/adrev()
	set category = "Server"
	set desc="Toggle admin revives"
	set name="Toggle Revive"

	if(CONFIG_GET(flag/allow_admin_rev))
		CONFIG_SET(flag/allow_admin_rev, FALSE)
		message_admins("<span class='notice'>Disabled reviving.</span>")
	else
		CONFIG_SET(flag/allow_admin_rev, TRUE)
		message_admins("<span class='notice'>Enabled reviving.</span>")

/datum/admins/proc/immreboot()
	set category = "Server"
	set desc="Reboots the server post haste"
	set name="Immediate Reboot"
	if(!usr.client.holder)	return
	if( alert("Reboot server?",,"Yes","No") == "No")
		return
	to_chat(world, "<span class='danger'>Rebooting world!</span><span class='notice'>Initiated by [usr.client.holder.fakekey ? "Admin" : usr.key]!</span>")
	log_admin("[key_name(usr)] initiated an immediate reboot.")

	feedback_set_details("end_error","immediate admin reboot - by [usr.key] [usr.client.holder.fakekey ? "(stealth)" : ""]")
	feedback_add_details("admin_verb","IR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	if(blackbox)
		blackbox.save_all_data_to_sql()

	world.Reboot()

/datum/admins/proc/toggleguests()
	set category = "Server"
	set desc="Guests can't enter"
	set name="Toggle Guest Joining"
	guests_allowed = !( guests_allowed )
	if (!( guests_allowed ))
		to_chat(world, "<B>Guests may no longer enter the game.</B>")
	else
		to_chat(world, "<B>Guests may now enter the game.</B>")
	log_admin("[key_name(usr)] toggled guests game entering [guests_allowed?"":"dis"]allowed.")
	message_admins("<span class='notice'> [key_name_admin(usr)] toggled guests game entering [guests_allowed?"":"dis"]allowed.</span>", 1)
	feedback_add_details("admin_verb","TGU") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

//Added for testing purposes. Blast from the past seeing Respawn Character. ~N
/datum/admins/proc/force_predator_round()
	set category = "Server"
	set name = "Force Predator Round"
	set desc = "Force a predator round for the round type. Only works on maps that support Predator spawns."

	if(!ticker || ticker.current_state < GAME_STATE_PLAYING || !ticker.mode)
		to_chat(usr, "<span class='warning'>The game hasn't started yet!</span>")
		return

	var/datum/game_mode/predator_round = ticker.mode

	if(!(predator_round.flags_round_type & MODE_PREDATOR))
		predator_round.flags_round_type |= MODE_PREDATOR
		to_chat(usr, "The Hunt is now enabled.")
	else
		to_chat(usr, "The Hunt is already in progress.")
		return

	feedback_add_details("admin_verb","FPRED")
	log_admin("[key_name(usr)] admin-forced a predator round.")
	message_admins("<span class='notice'> [key_name_admin(usr)] admin-forced a predator round.</span>", 1)
	return

/client/proc/toggle_random_events()
	set category = "Server"
	set name = "Toggle random events on/off"

	set desc = "Toggles random events such as meteors, black holes, blob (but not space dust) on/off"
	if(!check_rights(R_SERVER))	return

	if(!CONFIG_GET(flag/allow_random_events))
		CONFIG_SET(flag/allow_random_events, TRUE)
		to_chat(usr, "Random events enabled")
		message_admins("Admin [key_name_admin(usr)] has enabled random events.", 1)
	else
		CONFIG_SET(flag/allow_random_events, FALSE)
		to_chat(usr, "Random events disabled")
		message_admins("Admin [key_name_admin(usr)] has disabled random events.", 1)
	feedback_add_details("admin_verb","TRE") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_debug_tog_aliens()
	set category = "Server"
	set name = "Toggle Aliens"

	aliens_allowed = !aliens_allowed
	log_admin("[key_name(src)] has turned aliens [aliens_allowed ? "on" : "off"].")
	message_admins("[key_name_admin(src)] has turned aliens [aliens_allowed ? "on" : "off"].", 0)
	feedback_add_details("admin_verb","TAL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/toggle_gun_restrictions()
	set name = "Toggle Gun Restrictions"
	set category = "Server"
	set desc = "Currently only affects MP guns."

	if(!check_rights(R_SERVER))
		return

	if(config)
		if(CONFIG_GET(flag/remove_gun_restrictions))
			CONFIG_SET(flag/remove_gun_restrictions, FALSE)
		else
			CONFIG_SET(flag/remove_gun_restrictions, TRUE)

		log_admin("[key_name(usr)] has [CONFIG_GET(flag/remove_gun_restrictions) ? "enabled" : "disabled"] gun restrictions.")
		message_admins("[key_name_admin(usr)] has [CONFIG_GET(flag/remove_gun_restrictions) ? "enabled" : "disabled"] gun restrictions.")


/client/proc/toggle_synthetic_restrictions()
	set name = "Toggle Synthetic Restrictions"
	set category = "Server"
	set desc = "Toggling to on will allow synthetics to use weapons."

	if(!check_rights(R_SERVER))
		return

	if(config)
		if(CONFIG_GET(flag/allow_synthetic_gun_use))
			CONFIG_SET(flag/allow_synthetic_gun_use, FALSE)
		else
			CONFIG_SET(flag/allow_synthetic_gun_use, TRUE)

		log_admin("[key_name(src)] has [CONFIG_GET(flag/allow_synthetic_gun_use) ? "enabled" : "disabled"] synthetic weapon use.")
		message_admins("[key_name_admin(usr)] has [CONFIG_GET(flag/allow_synthetic_gun_use) ? "enabled" : "disabled"] synthetic weapon use.")


/client/proc/adjust_weapon_mult()
	set category = "Server"
	set name = "Adjust Weapon Multipliers"
	set desc = "Adjusts the global weapons multipliers."

	if(!check_rights(R_SERVER))
		return

	if(config)
		var/acc = input("Select the new accuracy multiplier.", "ACCURACY MULTIPLIER", 1) as num
		var/dam = input("Select the new damage multiplier.", "DAMAGE MULTIPLIER", 1) as num
		if(acc && dam)
			CONFIG_SET(number/combat_define/proj_base_accuracy_mult, (acc * 0.01))
			CONFIG_SET(number/combat_define/proj_base_damage_mult, (dam * 0.01))
			log_admin("Admin [key_name_admin(usr)] changed global accuracy to <b>[acc]</b> and global damage to <b>[dam]</b>.", 1)
			log_game("<b>[key_name(src)]</b> changed global accuracy to <b>[acc]</b> and global damage to <b>[dam]</b>.")


/client/proc/reload_admins()
	set name = "Reload Admins"
	set category = "Server"
	set desc = "Manually load all admins from the .txt"

	if(!check_rights(R_SERVER))
		return

	load_admins()

	log_game("[key_name(src)] manually reloaded admins.")
	message_admins("[key_name_admin(usr)] manually reloaded admins.")


/client/proc/reload_whitelist()
	set name = "Reload Whitelist"
	set category = "Server"
	set desc = "Manually load the whitelisted players from the .txt"

	if(!check_rights(R_SERVER))
		return

	if(!RoleAuthority)
		return

	RoleAuthority.load_whitelist()

	message_admins("[usr.ckey] manually reloaded the role whitelist.")
