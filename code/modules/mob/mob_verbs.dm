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
		to_chat(usr, "<span class='notice'>Respawn is disabled. This is the default state, you can usually rejoin the round as a human only via ERT.</span>")
		return
	if(stat != DEAD)
		to_chat(usr, "<span class='boldnotice'>You must be dead to use this!</span>")
		return

	if(DEATHTIME_CHECK(usr))
		if(check_other_rights(usr.client, R_ADMIN, FALSE))
			if(alert(usr, "You wouldn't normally qualify for this respawn. Are you sure you want to bypass it with your admin powers?", "Bypass Respawn", "Yes", "No") != "Yes")
				DEATHTIME_MESSAGE(usr)
				return
		else
			DEATHTIME_MESSAGE(usr)
			return

	to_chat(usr, "<span class='notice'>You can respawn now, enjoy your new life!<br><b>Make sure to play a different character, and please roleplay correctly.</b></span>")

	if(!client)
		return
	client.screen.Cut()
	if(!client)
		return

	var/mob/new_player/M = new /mob/new_player()
	if(!client)
		qdel(M)
		return

	M.key = key


/// This is only available to mobs once they join EORD.
/mob/proc/eord_respawn()
	set name = "EORD Respawn"
	set category = "OOC"

	if(stat != DEAD)
		to_chat(src, "You can only use this when you're dead.")
		return

	var/list/spawn_types = pick(
		500 ; /mob/living/carbon/human,
		/mob/living/carbon/xenomorph/runner,
		/mob/living/carbon/xenomorph/hunter,
		/mob/living/carbon/xenomorph/spitter,
		/mob/living/carbon/xenomorph/defender,
		/mob/living/carbon/xenomorph/warrior,
	)
	var/spawn_location = pick(GLOB.deathmatch)
	var/mob/living/L = new spawn_types(spawn_location)
	mind.transfer_to(L, TRUE)
	L.mind.bypass_ff = TRUE
	L.revive()

	if(isxeno(L))
		var/mob/living/carbon/xenomorph/X = L
		X.transfer_to_hive(pick(XENO_HIVE_NORMAL, XENO_HIVE_CORRUPTED, XENO_HIVE_ALPHA, XENO_HIVE_BETA, XENO_HIVE_ZETA))

	else if(ishuman(L))
		var/mob/living/carbon/human/H = L
		var/job = pick(/datum/job/clf/leader, /datum/job/freelancer/leader, /datum/job/upp/leader, /datum/job/som/leader, /datum/job/pmc/leader, /datum/job/freelancer/standard, /datum/job/som/standard, /datum/job/clf/standard)
		var/datum/job/J = SSjob.GetJobType(job)
		H.apply_assigned_role_to_spawn(J)
		H.regenerate_icons()

	to_chat(L, "<br><br><h1><span class='danger'>Fight for your life (again), try not to die this time!</span></h1><br><br>")


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
	set hidden = 1
	return facedir(EAST)


/mob/verb/westface()
	set hidden = 1
	return facedir(WEST)


/mob/verb/northface()
	set hidden = 1
	return facedir(NORTH)


/mob/verb/southface()
	set hidden = 1
	return facedir(SOUTH)


/mob/verb/stop_pulling1()
	set name = "Stop Pulling"
	set category = "IC"

	stop_pulling()
