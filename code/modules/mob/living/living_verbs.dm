/mob/living/verb/resist()
	set name = "Resist"
	set category = "IC"

	do_resist()

///Handles trying to toggle resting state
/mob/living/proc/toggle_resting()
	if(incapacitated(TRUE))
		return

	if(!resting)
		if(is_ventcrawling)
			return FALSE
		set_resting(TRUE, FALSE)
		return
	if(do_actions)
		balloon_alert(src, "Busy!")
		return
	get_up()

///Handles getting up, doing a basic check before relaying it to the actual proc that does it
/mob/living/proc/get_up()
	if(!incapacitated(TRUE))
		set_resting(FALSE, FALSE)
	else
		to_chat(src, span_notice("You fail to get up."))

///Actually handles toggling the resting state
/mob/living/proc/set_resting(rest, silent = TRUE)
	if(status_flags & INCORPOREAL)
		return
	if(rest == resting)
		return
	. = resting
	resting = rest
	if(resting)
		ADD_TRAIT(src, TRAIT_FLOORED, RESTING_TRAIT)
		if(!silent)
			to_chat(src, span_notice("You are now resting."))
		SEND_SIGNAL(src, COMSIG_XENOMORPH_REST)
	else
		REMOVE_TRAIT(src, TRAIT_FLOORED, RESTING_TRAIT)
		if(!silent)
			to_chat(src, span_notice("You get up."))
		SEND_SIGNAL(src, COMSIG_XENOMORPH_UNREST)
	hud_used?.rest_icon?.update_icon()


/mob/living/verb/ghost()
	set category = "OOC"
	set name = "Ghost"

	// Gamemode disallowed handler - START
	if((!SSticker.mode || CHECK_BITFIELD(SSticker.mode.round_type_flags, MODE_NO_GHOSTS)))
		if(client && check_rights_for(client, R_ADMIN))
			switch(tgui_input_list(src, "Ghosting in this game mode would normally send you to the lobby, but since you are an admin you can bypass this.  What do you wish to do?", "Ghost", list("Ghost", "AGhost", "Return to lobby"), "AGhost"))
				if("Ghost")
					set_resting(TRUE)
					log_game("[key_name(usr)] has ghosted at [AREACOORD(usr)], using their admin powers to bypass the fact the gamemode does not allow it.")
					message_admins("[ADMIN_TPMONTY(usr)] has ghosted, using their admin powers to bypass the fact the gamemode does not allow it.")
					ghostize(FALSE)
					return
				if("AGhost")
					var/mob/dead/observer/ghost = ghostize(TRUE, TRUE)
					log_admin("[key_name(ghost)] admin ghosted at [AREACOORD(ghost)].")
					if(stat != DEAD)
						message_admins("[ADMIN_TPMONTY(ghost)] admin ghosted.")
					return
				if("Return to lobby")
					set_resting(TRUE)
					log_game("[key_name(usr)] has ghosted at [AREACOORD(usr)], sending them to the title screen.")
					message_admins("[ADMIN_TPMONTY(usr)] has ghosted, sending them to the title screen.")
					ghostize(FALSE, FALSE, TRUE)
					return
			return
		if(tgui_alert(src, "Ghosting is not allowed in this game mode, so this will return you to the lobby instead. Your respawn timer will still apply. Continue?", "Return to lobby", list("Yes", "No")) != "Yes")
			return
		log_game("[key_name(usr)] has ghosted at [AREACOORD(usr)], sending them to the title screen.")
		message_admins("[ADMIN_TPMONTY(usr)] has ghosted, sending them to the title screen.")

		ghostize(FALSE)
		return
	// Gamemode disallowed handler - END

	if(stat == DEAD || isxenohivemind(src) || iszombie(src))
		log_game("[key_name(usr)] has ghosted at [AREACOORD(usr)].")
		message_admins("[ADMIN_TPMONTY(usr)] has ghosted.")
		ghostize(TRUE)
	else
		to_chat(usr, "Not dead yet.")
		log_game("[key_name(usr)] tried to ghost while alive at [AREACOORD(usr)].")
		message_admins("[ADMIN_TPMONTY(usr)] tried to ghost while alive.")
		return

	//if(tgui_alert(src, "Are you sure you want to ghost?\n(You are alive. If you ghost, you won't be able to return to your body. You can't change your mind so choose wisely!)", "Ghost", list("Yes", "No")) != "Yes")
	//	return

	set_resting(TRUE)
	log_game("[key_name(usr)] has ghosted at [AREACOORD(usr)].")
	message_admins("[ADMIN_TPMONTY(usr)] has ghosted.")
	ghostize(FALSE)

/mob/living/point_to(atom/pointed_atom as mob|obj|turf in view(client.view, src))
	if(!..())
		return FALSE
	if(HAS_TRAIT(src, TRAIT_FAKEDEATH))
		return FALSE
	visible_message(span_infoplain("[span_name("[src]")] points at [pointed_atom]."), span_notice("You point at [pointed_atom]."))
