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
	var/mob/living/carbon/leader = null
	var/shuttle_id = "distress"
	var/obj/docking_port/mobile/ert/shuttle
	var/auto_shuttle_launch = FALSE //Useful for xenos that can't interact with the shuttle console.
	var/medics = 0
	var/max_medics = 1
	var/candidate_timer
	var/cooldown_timer

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

	for(var/i in GLOB.observer_list)
		var/mob/dead/observer/M = i
		to_chat(M, "<br><font size='3'><span class='attack'>An emergency beacon has been activated. Use the <B>Ghost > <a href='byond://?src=[REF(M)];join_ert=1'>Join Response Team</a></b> verb to join!</span></font><br>")
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

/datum/emergency_call/proc/reset()
	if(candidate_timer)
		deltimer(candidate_timer)
		candidate_timer = null
	if(cooldown_timer)
		deltimer(cooldown_timer)
		cooldown_timer = null
	members = list()
	candidates = list()
	SSticker.mode.waiting_for_candidates = FALSE
	SSticker.mode.on_distress_cooldown = FALSE
	message_admins("Distress beacon: [name] has been reset.")

/datum/emergency_call/proc/activate(announce = TRUE)
	if(!SSticker?.mode) //Something horribly wrong with the gamemode SSticker
		message_admins("Distress beacon: [name] attempted to activate but no gamemode exists")
		return FALSE

	if(SSticker.mode.on_distress_cooldown) //It's already been called.
		message_admins("Distress beacon: [name] attempted to activate but distress is on cooldown")
		return FALSE

	if(mob_max > 0)
		SSticker.mode.waiting_for_candidates = TRUE

	show_join_message() //Show our potential candidates the message to let them join.
	message_admins("Distress beacon: '[name]' activated. Looking for candidates.")

	if(announce)
		priority_announce("A distress beacon has been launched from the [CONFIG_GET(string/ship_name)].", "Priority Alert", sound = 'sound/AI/distressbeacon.ogg')

	SSticker.mode.on_distress_cooldown = TRUE

	candidate_timer = addtimer(CALLBACK(src, .do_activate, announce), 1 MINUTES)

/datum/emergency_call/proc/do_activate(announce = TRUE)
	candidate_timer = null
	SSticker.mode.waiting_for_candidates = FALSE

	var/list/valid_candidates = list()

	for(var/i in candidates)
		var/datum/mind/M = i
		if(!istype(M)) // invalid
			continue
		if(M.current) //If they still have a body
			if(!isaghost(M.current) && M.current.stat != DEAD) // and not dead or admin ghosting,
				to_chat(M.current, "<span class='warning'>You didn't get selected to join the distress team because you aren't dead.</span>")
				continue
		if(name == "Xenomorphs" && is_banned_from(M.current.ckey, ROLE_XENOMORPH))
			if(M.current)
				to_chat(M.current, "<span class='warning'>You didn't get selected to join the distress team because you are jobbanned from Xenomorph.</span>")
			continue
		valid_candidates += M

	message_admins("Distress beacon: [name] got [length(candidates)] candidates, [length(valid_candidates)] of them were valid.")

	if(length(valid_candidates) < mob_min)
		message_admins("Aborting distress beacon [name], not enough candidates. Found: [length(valid_candidates)]. Minimum required: [mob_min].")
		SSticker.mode.waiting_for_candidates = FALSE
		members = list() //Empty the members list.
		candidates = list()

		if(announce)
			priority_announce("The distress signal has not received a response, the launch tubes are now recalibrating.", "Distress Beacon")

		SSticker.mode.picked_call = null
		SSticker.mode.on_distress_cooldown = TRUE

		cooldown_timer = addtimer(CALLBACK(src, .reset), COOLDOWN_COMM_REQUEST)
		return

	var/datum/mind/picked_candidates = list()
	if(length(valid_candidates) > mob_max)
		for(var/i in 1 to mob_max)
			if(!length(valid_candidates)) //We ran out of candidates.
				break
			picked_candidates += pick_n_take(valid_candidates) //Get a random candidate, then remove it from the candidates list.

		for(var/datum/mind/M in valid_candidates)
			if(M.current)
				to_chat(M.current, "<span class='warning'>You didn't get selected to join the distress team. Better luck next time!</span>")
		message_admins("Distress beacon: [length(valid_candidates)] valid candidates were not selected.")
	else
		picked_candidates = valid_candidates // save some time
		message_admins("Distress beacon: All valid candidates were selected.")

	if(announce)
		priority_announce(dispatch_message, "Distress Beacon", sound = 'sound/AI/distressreceived.ogg')

	message_admins("Distress beacon: [name] finalized, starting spawns.")

	// begin loading the shuttle
	if(!SSmapping.shuttle_templates[shuttle_id])
		message_admins("Distress beacon: [name] couldn't find a valid shuttle template")
		CRASH("ert called with invalid shuttle_id")
		return
	var/datum/map_template/shuttle/S = SSmapping.shuttle_templates[shuttle_id]

	var/obj/docking_port/stationary/L = SSshuttle.getDock("distress_loading")
	if(!L)
		message_admins("Distress beacon: [name] couldn't find a distress beacon loading dock")
		CRASH("no distress loading port defined")

	if(L.get_docked())
		message_admins("Distress beacon: [name] tried to load while something was hogging the distress beacon loading dock")
		CRASH("trying to load an ert when one is currently being loaded")

	shuttle = SSshuttle.action_load(S, L)

	if(!istype(shuttle))
		message_admins("Distress beacon: [name] couldn't load a shuttle template")
		CRASH("ert shuttle failed to load")

	spawn_items()

	if(length(picked_candidates) && mob_min > 0)
		max_medics = max(round(length(picked_candidates) * 0.25), 1)
		for(var/i in picked_candidates)
			var/datum/mind/M = i
			members += M
			create_member(M)
	else
		message_admins("ERROR: No picked candidates, aborting.")
		shuttle.intoTheSunset() // delete
		return

	if(auto_shuttle_launch)
		if(!shuttle.auto_launch())
			shuttle.intoTheSunset()
			message_admins("Distress beacon: [name] couldn't find a valid target to autolaunch")
			CRASH("can't find a valid place to autolaunch ert shuttle towards")

	message_admins("Distress beacon: [name] finished spawning.")

	candidates = list() //Blank out the candidates list for next time.

	cooldown_timer = addtimer(CALLBACK(src, .reset), COOLDOWN_COMM_REQUEST)

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


/datum/emergency_call/proc/get_spawn_point(is_for_items)
	var/obj/effect/landmark/L
	if(is_for_items)
		L = pick(shuttle?.item_spawns)
	else
		L = pick(shuttle?.mob_spawns)
	if(L)
		return get_turf(L)

/datum/emergency_call/proc/create_member(datum/mind/M) //Overriden in each distress call file.
	return


/datum/emergency_call/proc/spawn_items() //Allows us to spawn various things around the shuttle.
	return


/datum/emergency_call/proc/print_backstory(mob/living/carbon/human/M)
	return
