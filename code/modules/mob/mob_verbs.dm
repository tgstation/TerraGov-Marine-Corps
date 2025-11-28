/**
 * This is a mob verb for speed reasons (nice one BYOND).
 * See [this BYOND forum post](https://secure.byond.com/forum/?post=1326139&page=2#comment8198716)
 * for why this isnt something like `/atom/verb/examine`.
 *
 * SIGNAL FUN:
 * Produces a signal [COMSIG_MOB_EXAMINATE], for doing stuff to people who examine things,
 * like applying debilitating effects to someone who examines a specific type of atom.
 */
/mob/verb/examinate(atom/examinify as mob|obj|turf in view())
	set name = "Examine"
	set category = "IC"

	if(is_blind(src))
		to_chat(src, span_warning("Something is there, but you can't see it!"))
		return

	face_atom(examinify)
	var/list/result = examinify.examine(src) // if a tree is examined but no client is there to see it, did the tree ever really exist?
	var/atom_title = examinify.examine_title(src, thats = TRUE)

	if(length(result))
		for(var/i in 1 to (length(result) - 1))
			if(result[i] != EXAMINE_SECTION_BREAK)
				result[i] += "\n"
			else
				// remove repeated <hr's> and ones on the ends.
				if((i == 1) || (i == length(result)) || (result[i - 1] == EXAMINE_SECTION_BREAK))
					result.Cut(i, i + 1)
					i--

	var/result_combined = (atom_title ? fieldset_block(atom_title, jointext(result, ""), examinify.boxed_message_style) : custom_boxed_message(examinify.boxed_message_style, jointext(result, "")))

	to_chat(src, span_infoplain(result_combined))
	SEND_SIGNAL(src, COMSIG_MOB_EXAMINATE, examinify)

/mob/verb/mode()
	set name = "Activate Held Object"
	set category = "IC.Object"
	set src = usr

	if(next_move > world.time)
		return

	if(incapacitated())
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
	if(SSticker.mode?.round_type_flags & MODE_TWO_HUMAN_FACTIONS)
		M.faction = faction
	if(!client)
		qdel(M)
		return

	M.key = key


/// This is only available to mobs once they join EORD.
/mob/proc/eord_respawn()
	set name = "EORD Respawn"
	set category = "OOC"

	var/mob/living/liver
	if(isliving(usr))
		liver = usr
		if(liver.health >= liver.get_crit_threshold())
			to_chat(src, "You can only use this when you're dead or crit.")
			return

	if(usr)
		do_eord_respawn(usr)

/**
 * Grabs a mob, if it's human, check uniform, if it has one just stops there, otherwise proceeds. if it's not human, creates a human mob and transfers the mind there. Proceeds to outfit either result with the loadout of various factions.
 * 7% chance to be a separate rare strong or funny faction. Tiny additional 2% chance if that procs to be a deathsquad!
 * SOM and TG loadouts are handled differently, taking subtypes from the HvH loadout sets.
 */
/proc/do_eord_respawn(mob/respawner)

	var/spawn_location = pick(GLOB.deathmatch)
	var/mob/living/carbon/human/eord_body
	if(ishuman(respawner) && !is_centcom_level(respawner.z)) // Wont take
		eord_body = respawner
		eord_body.forceMove(spawn_location)
		eord_body.revive()
		if(eord_body.w_uniform)
			return
	else
		eord_body = new(spawn_location)
		respawner.mind.transfer_to(eord_body, TRUE)
		eord_body.revive()

	eord_body.mind.bypass_ff = TRUE

	// List of base choosable factions, taken job is a subtype of these.
	var/list/static/base_faction_list = list(
		/datum/job/clf,
		/datum/job/freelancer,
		/datum/job/pmc,
		/datum/job/special_forces,
		/datum/job/icc,
	)

	// List of HvH factions - these are handled differently, using the quick loadout outfits.
	var/list/static/hvh_faction_list = list(/datum/job/som, /datum/job/terragov)
	// List of rare factions, not common because they're funny in moderation / stronk.
	var/list/static/rare_faction_list = list(/datum/job/sectoid, /datum/job/imperial, /datum/job/skeleton)


	var/total_list = base_faction_list + hvh_faction_list

	if(prob(7))
		total_list = rare_faction_list
		if(prob(2))
			total_list = list(/datum/job/deathsquad) // JACKPOT

	var/datum/job/result = pick(total_list)
	if(result in hvh_faction_list)
		var/is_som = FALSE
		if(result == /datum/job/som)
			is_som = TRUE
		var/job_type
		var/list/possible_outfits
		switch(rand(100))
			if(1 to 40)
				// Standard
				possible_outfits = is_som ? subtypesof(/datum/outfit/quick/som/marine) : subtypesof(/datum/outfit/quick/tgmc/marine)
				job_type = is_som ? SSjob.GetJobType(/datum/job/som/squad/standard) : SSjob.GetJobType(/datum/job/terragov/squad/standard)
			if(41 to 55)
				// Engineer
				possible_outfits = is_som ? subtypesof(/datum/outfit/quick/som/engineer) : subtypesof(/datum/outfit/quick/tgmc/engineer)
				job_type = is_som ? SSjob.GetJobType(/datum/job/som/squad/engineer) : SSjob.GetJobType(/datum/job/terragov/squad/engineer)
			if(56 to 70)
				// Corpsman
				possible_outfits = is_som ? subtypesof(/datum/outfit/quick/som/medic) : subtypesof(/datum/outfit/quick/tgmc/corpsman)
				job_type = is_som ? SSjob.GetJobType(/datum/job/som/squad/medic) : SSjob.GetJobType(/datum/job/terragov/squad/corpsman)
			if(70 to 85)
				// Specialist
				possible_outfits = is_som ? subtypesof(/datum/outfit/quick/som/veteran) : subtypesof(/datum/outfit/quick/tgmc/smartgunner)
				job_type = is_som ? SSjob.GetJobType(/datum/job/som/squad/veteran) : SSjob.GetJobType(/datum/job/terragov/squad/smartgunner)
			else
				// Squad Leader
				possible_outfits = is_som ? subtypesof(/datum/outfit/quick/som/squad_leader) : subtypesof(/datum/outfit/quick/tgmc/leader)
				job_type = is_som ? SSjob.GetJobType(/datum/job/som/squad/leader) : SSjob.GetJobType(/datum/job/terragov/squad/leader)

		var/datum/job/J = job_type
		eord_body.apply_assigned_role_to_spawn(J)

		var/datum/outfit/quick/picked_outfit = pick(possible_outfits)
		picked_outfit = new picked_outfit
		picked_outfit.equip(eord_body, visualsOnly = FALSE)
	else
		result = pick(subtypesof(result))
		var/datum/job/J = SSjob.GetJobType(result)
		eord_body.apply_assigned_role_to_spawn(J)

	eord_body.regenerate_icons()

	to_chat(eord_body, "<br><br><h1>[span_danger("Fight for your life (again), try not to die this time!")]</h1><br><br>")


/mob/verb/cancel_camera()
	set name = "Cancel Camera View"
	set category = "IC.Object"
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

/mob/verb/point_to(atom/pointed_atom as mob|obj|turf in view())
	set name = "Point To"
	set category = "IC.Object"

	if(client && !(pointed_atom in view(client.view, src)))
		return FALSE
	if(!pointed_atom.mouse_opacity)
		return FALSE
	if(TIMER_COOLDOWN_RUNNING(src, COOLDOWN_POINT))
		return FALSE
	if(incapacitated())
		return FALSE

	TIMER_COOLDOWN_START(src, COOLDOWN_POINT, 1 SECONDS)
	point_to_atom(pointed_atom)
	return TRUE
