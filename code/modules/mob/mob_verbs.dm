/mob/verb/mode()
	set name = "Activate Held Object"
	set category = "Object"
	set src = usr

	if(next_move > world.time)
		return

	if(istype(loc, /obj/vehicle/multitile/root/cm_armored))
		return

	if(hand)
		var/obj/item/W = l_hand
		if (W)
			W.attack_self(src)
			update_inv_l_hand()
	else
		var/obj/item/W = r_hand
		if (W)
			W.attack_self(src)
			update_inv_r_hand()

	if(next_move <= world.time)
		changeNext_move(CLICK_CD_FASTEST)


/mob/verb/memory()
	set name = "Notes"
	set category = "IC"
	if(mind)
		mind.show_memory(src)
	else
		to_chat(src, "The game appears to have misplaced your mind datum, so we can't show you your notes.")

/mob/verb/add_memory(msg as message)
	set name = "Add Note"
	set category = "IC"
	if(mind)
		if (world.time < memory_throttle_time)
			return
		memory_throttle_time = world.time + 5 SECONDS
		msg = copytext_char(msg, 1, MAX_MESSAGE_LEN)
		msg = sanitize(msg)

		mind.store_memory(msg)
	else
		to_chat(src, "You don't have a mind datum for some reason, so you can't add a note to it.")


/mob/verb/respawn()
	set name = "Respawn"
	set category = "OOC"

	if(!GLOB.respawn_allowed && !check_rights(R_ADMIN, FALSE))
		to_chat(usr, span_notice("Respawn is disabled."))
		return
	if(stat != DEAD)
		to_chat(usr, span_boldnotice("You must be dead to use this!"))
		return

	if(DEATHTIME_CHECK(usr))
		if(check_other_rights(usr.client, R_ADMIN, FALSE))
			if(tgui_alert(usr, "You wouldn't normally qualify for this respawn. Are you sure you want to bypass it with your admin powers?", "Bypass Respawn", list("Yes", "No"), 0) != "Yes")
				DEATHTIME_MESSAGE(usr)
				return
			var/admin_message = "[key_name(usr)] used his admin power to bypass respawn before his timer was over"
			log_admin(admin_message)
			message_admins(admin_message)
		else
			DEATHTIME_MESSAGE(usr)
			return

	to_chat(usr, span_notice("You can respawn now, enjoy your new life!<br><b>Make sure to play a different character, and please roleplay correctly.</b>"))
	GLOB.round_statistics.total_human_respawns++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "total_human_respawns")


	if(!client)
		return
	client.screen.Cut()
	if(!client)
		return

	var/mob/new_player/M = new /mob/new_player()
	if(SSticker.mode?.flags_round_type & MODE_TWO_HUMAN_FACTIONS)
		M.faction = faction
	if(!client)
		qdel(M)
		return

	M.key = key


/// This is only available to mobs once they join EORD.
/mob/proc/eord_respawn()
	set name = "EORD Respawn"
	set category = "OOC"

	if(isliving(usr))
		var/mob/living/liver = usr
		if(liver.health >= liver.health_threshold_crit)
			to_chat(src, "You can only use this when you're dead or crit.")
			return

	var/spawn_location = pick(GLOB.deathmatch)
	var/mob/living/L = new /mob/living/carbon/human(spawn_location)
	mind.transfer_to(L, TRUE)
	L.mind.bypass_ff = TRUE
	L.revive()

	var/mob/living/carbon/human/H = L
	var/job = pick(
		/datum/job/clf/leader,
		/datum/job/clf/standard,
		/datum/job/freelancer/leader,
		/datum/job/freelancer/grenadier,
		/datum/job/freelancer/standard,
		/datum/job/upp/leader,
		/datum/job/upp/heavy,
		/datum/job/upp/standard,
		/datum/job/som/ert/leader,
		/datum/job/som/ert/veteran,
		/datum/job/som/ert/standard,
		/datum/job/pmc/leader,
		/datum/job/pmc/standard,
	)
	var/datum/job/J = SSjob.GetJobType(job)
	H.apply_assigned_role_to_spawn(J)
	H.regenerate_icons()

	to_chat(L, "<br><br><h1>[span_danger("Fight for your life (again), try not to die this time!")]</h1><br><br>")


/mob/verb/cancel_camera()
	set name = "Cancel Camera View"
	set category = "Object"
	reset_perspective(null)
	unset_interaction()
	if(isliving(src))
		var/mob/living/M = src
		if(M.cameraFollow)
			M.cameraFollow = null


/mob/verb/eastface()
	SIGNAL_HANDLER
	set hidden = 1
	return facedir(EAST)


/mob/verb/westface()
	SIGNAL_HANDLER
	set hidden = 1
	return facedir(WEST)


/mob/verb/northface()
	SIGNAL_HANDLER
	set hidden = 1
	return facedir(NORTH)


/mob/verb/southface()
	SIGNAL_HANDLER
	set hidden = 1
	return facedir(SOUTH)


/mob/verb/stop_pulling1()
	set name = "Stop Pulling"
	set category = "IC"

	stop_pulling()
