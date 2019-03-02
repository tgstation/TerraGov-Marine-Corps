//This file deals with distress beacons. It randomizes between a number of different types when activated.
//There's also an admin commmand which lets you set one to your liking.

//Persistent gamemode variables.
/datum/game_mode
	var/list/datum/emergency_call/all_calls = list() //initialized at round start and stores the datums.
	var/datum/emergency_call/picked_call = null //Which distress call is currently active
	var/on_distress_cooldown = FALSE
	var/waiting_for_candidates = FALSE


//The distress call parent.
/datum/emergency_call
	var/name = ""
	var/mob_max = 10
	var/mob_min = 1
	var/dispatch_message = "An encrypted signal has been received from a nearby vessel. Stand by." //Message displayed to marines once the signal is finalized.
	var/objectives = "" //Objectives to display to the members.
	var/probability = 0 //So we can give different ERTs a different probability.
	var/list/datum/mind/members = list() //Currently-joined members.
	var/list/datum/mind/candidates = list() //Potential candidates for enlisting.
	var/name_of_spawn = "Distress" //If we want to set up different spawn locations
	var/mob/living/carbon/leader = null
	var/shuttle_id = "distress"
	var/auto_shuttle_launch = FALSE //Useful for xenos that can't interact with the shuttle console.
	var/medics = 0
	var/max_medics = 1


/datum/game_mode/proc/initialize_emergency_calls()
	if(length(all_calls)) //It's already been set up.
		return

	var/list/total_calls = typesof(/datum/emergency_call)
	if(!length(total_calls))
		log_game("ERROR: No distress Datums found.")
		message_admins("ERROR: No distress Datums found.")
		return FALSE

	for(var/x in total_calls)
		var/datum/emergency_call/D = new x()
		if(!D?.name)
			continue //The default parent, don't add it
		all_calls += D


//Randomizes and chooses a call datum.
/datum/game_mode/proc/get_random_call()
    var/datum/emergency_call/chosen_call
    var/list/valid_calls = list()

    for(var/datum/emergency_call/E in all_calls) //Loop through all potential candidates
        if(E.probability < 1) //Those that are meant to be admin-only
            continue

        valid_calls.Add(E)

        if(prob(E.probability))
            chosen_call = E
            break

    if(!istype(chosen_call))
        chosen_call = pick(valid_calls)

    return chosen_call

/datum/emergency_call/proc/show_join_message()
	if(!mob_max || !SSticker?.mode) //Not a joinable distress call.
		return

	for(var/mob/dead/observer/M in GLOB.player_list)
		if(M.client)
			to_chat(M, "<br><font size='3'><span class='attack'>An emergency beacon has been activated. Use the <B>Ghost > Join Response Team</b> verb to join!</span></font><br>")
			to_chat(M, "<span class='attack'>You cannot join if you have Ghosted before this message.</span><br>")


/datum/game_mode/proc/activate_distress()
	picked_call = get_random_call()

	if(!picked_call) //Something went horribly wrong
		return FALSE

	if(SSticker?.mode?.waiting_for_candidates) //It's already been activated
		return FALSE


	picked_call.mob_max = rand(5, 15)

	picked_call.activate()


/mob/dead/observer/verb/JoinResponseTeam()
	set name = "Join Response Team"
	set category = "Ghost"
	set desc = "Join an ongoing distress call response. You must be ghosted to do this."

	var/datum/emergency_call/distress = SSticker?.mode?.picked_call //Just to simplify things a bit

	if(jobban_isbanned(usr, ROLE_ERT) || is_banned_from(usr.ckey, ROLE_ERT))
		to_chat(usr, "<span class='danger'>You are jobbanned from the emergency reponse team!</span>")
		return

	if(!istype(distress) || !SSticker.mode.waiting_for_candidates || distress.mob_max < 1)
		to_chat(usr, "<span class='warning'>No distress beacons that need candidates are active. You will be notified if that changes.</span>")
		return

	var/deathtime = world.time - usr.timeofdeath

	if(deathtime < 600) //They have ghosted after the announcement.
		to_chat(usr, "<span class='warning'>You ghosted too recently. Try again later.</span>")
		return

	if(!usr.mind) //How? Give them a new one anyway.
		usr.mind = new /datum/mind(usr.key)
		usr.mind.active = TRUE
		usr.mind.current = usr

	if(usr.mind.key != usr.key) //This can happen when admin-switching people into afking people, leading to runtime errors for a clientless key.
		usr.mind.key = usr.key

	if(usr.mind in distress.candidates)
		to_chat(usr, "<span class='warning'>You are already a candidate for this emergency response team.</span>")
		return

	if(distress.add_candidate(usr))
		to_chat(usr, "<span class='boldnotice'>You are now a candidate in the emergency response team! If there are enough candidates, you may be picked to be part of the team.</span>")
	else
		to_chat(usr, "<span class='warning'>Something went wrong while adding you into the candidate list!</span>")


/datum/emergency_call/proc/activate(announce = TRUE)
	if(!SSticker?.mode) //Something horribly wrong with the gamemode SSticker
		return FALSE

	if(SSticker.mode.on_distress_cooldown) //It's already been called.
		return FALSE

	if(mob_max > 0)
		SSticker.mode.waiting_for_candidates = TRUE

	show_join_message() //Show our potential candidates the message to let them join.
	message_admins("Distress beacon: '[name]' activated. Looking for candidates.")

	if(announce)
		command_announcement.Announce("A distress beacon has been launched from the [CONFIG_GET(string/ship_name)].", "Priority Alert", new_sound='sound/AI/distressbeacon.ogg')

	SSticker.mode.on_distress_cooldown = TRUE

	addtimer(CALLBACK(src, .do_activate, announce), 1 MINUTES)

/datum/emergency_call/proc/do_activate(announce = TRUE)
	if(length(candidates) < mob_min)
		message_admins("Aborting distress beacon [name], not enough candidates. Found: [length(candidates)]. Minimum required: [mob_min].")
		SSticker.mode.waiting_for_candidates = FALSE
		members = list() //Empty the members list.
		candidates = list()

		if(announce)
			command_announcement.Announce("The distress signal has not received a response, the launch tubes are now recalibrating.", "Distress Beacon")

		SSticker.mode.picked_call = null
		SSticker.mode.on_distress_cooldown = TRUE

		addtimer(CALLBACK(src, .distress_cooldown), COOLDOWN_COMM_REQUEST)
	else
		SSticker.mode.waiting_for_candidates = FALSE
		var/datum/mind/picked_candidates = list()
		if(mob_max > 0)
			for(var/i = 1 to mob_max)
				if(!length(candidates)) //We ran out of candidates.
					break
				var/datum/mind/M = pick(candidates) //Get a random candidate, then remove it from the candidates list.
				if(!istype(M)) //Something went horrifically wrong
					candidates -= M
					continue
				if(M.current?.stat != DEAD)
					candidates -= M //Strip them from the list, they aren't dead anymore.
					continue
				if(name == "Xenomorphs")
					if(!(M.current.client?.prefs?.be_special & BE_ALIEN) || is_banned_from(M.current.ckey, ROLE_XENOMORPH))
						candidates -= M
						continue
					if(M.current?.stat != DEAD)
						candidates -= M //Strip them from the list, they aren't dead anymore.
						continue
					if(name == "Xenomorphs" && is_banned_from(M.current.ckey, ROLE_XENOMORPH))
						candidates -= M
						continue
					picked_candidates += M
					candidates -= M

			if(length(candidates))
				for(var/datum/mind/M in candidates)
					if(M.current)
						to_chat(M.current, "<span class='warning'>You didn't get selected to join the distress team. Better luck next time!</span>")

		if(announce)
			command_announcement.Announce(dispatch_message, "Distress Beacon", new_sound='sound/AI/distressreceived.ogg') //Announcement that the Distress Beacon has been answered, does not hint towards the chosen ERT

		message_admins("Distress beacon: [name] finalized, setting up candidates.")

		// begin loading the shuttle
		if(!SSmapping.shuttle_templates[shuttle_id])
			CRASH("ert called with invalid shuttle_id")
			return
		var/datum/map_template/shuttle/S = SSmapping.shuttle_templates[shuttle_id]

		var/obj/docking_port/stationary/L = SSshuttle.getDock("distress_loading")
		if(!L)
			CRASH("no distress loading port defined")

		var/obj/docking_port/mobile/ert_small/ertshuttle = SSshuttle.action_load(S, L)

		if(!istype(ertshuttle))
			CRASH("ert shuttle failed to load")

		var/list/spawn_turfs = ertshuttle.return_turfs()
		
		var/list/mob_spawns = list()
		var/list/item_spawns = list()

		for(var/i in spawn_turfs)
			var/turf/T = i
			var/obj/effect/landmark/distress_item/IS = locate() in T
			if(IS)
				item_spawns += IS
			var/obj/effect/landmark/distress/MS = locate() in T
			if(MS)
				mob_spawns += MS

		spawn_items(item_spawns)

		//if(auto_shuttle_launch)
			// autolaunch here

		if(length(picked_candidates))
			max_medics = max(round(length(members) * 0.25), 1)
			for(var/datum/mind/M in picked_candidates)
				members += M
				create_member(M, mob_spawns)
		else
			message_admins("ERROR: No picked candidates, aborting.")
			return

		candidates = list() //Blank out the candidates list for next time.
		
		addtimer(CALLBACK(src, .distress_cooldown), COOLDOWN_COMM_REQUEST)

/datum/emergency_call/proc/distress_cooldown()
	SSticker.mode.on_distress_cooldown = FALSE

/datum/emergency_call/proc/add_candidate(var/mob/M)
	if(!M.client)
		return FALSE  //Not connected

	if(M.mind && M.mind in candidates)
		return FALSE  //Already there.

	if(M.stat != DEAD)
		return FALSE  //Alive, could have been drafted into xenos or something else.

	if(!M.mind) //They don't have a mind
		return FALSE

	candidates += M.mind
	return TRUE


/datum/emergency_call/proc/get_spawn_point(list/spawnpoints)
	var/obj/effect/landmark/drop_spawn = pick(spawnpoints)
	if(!istype(drop_spawn))
		CRASH("no spawn points for ert")

	return get_turf(drop_spawn)

/datum/emergency_call/proc/create_member(datum/mind/M, list/spawnpoints) //Overriden in each distress call file.
	return


/datum/emergency_call/proc/spawn_items(list/spawnpoints) //Allows us to spawn various things around the shuttle.
	return


/datum/emergency_call/proc/print_backstory(mob/living/carbon/human/M)
	return
