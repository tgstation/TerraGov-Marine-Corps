//This file deals with distress beacons. It randomizes between a number of different types when activated.
//There's also an admin commmand which lets you set one to your liking.


//The distress call parent.
/datum/emergency_call
	var/name = ""
	var/mob_max = 10
	var/mob_min = 1
	var/dispatch_message = "An encrypted signal has been received from a nearby vessel. Stand by." //Message displayed to marines once the signal is finalized.
	var/objectives = "" //Objectives to display to the members.
	var/list/datum/mind/members = list() //Currently-joined members.
	var/list/datum/mind/candidates = list() //Potential candidates for enlisting.
	var/mob/living/carbon/leader = null
	var/shuttle_id = SHUTTLE_DISTRESS
	var/obj/docking_port/mobile/ert/shuttle
	var/auto_shuttle_launch = FALSE //Useful for xenos that can't interact with the shuttle console.
	var/medics = 0
	var/max_medics = 1
	var/candidate_timer
	var/cooldown_timer
	var/spawn_type = /mob/living/carbon/human
	///The base probability of that ERT spawning, it is changing with monitor state
	var/base_probability = 0
	/**
	 * How the current_weight change with the monitor state. A big positive number will make the current weight go down drasticly when marines are winning
	 * A small negative number will make the current weight get smaller when xenos are winning.
	 * All effects are symetric (if it goes down when marine are winning, it will go up when xeno are winning)
	 * if the alignement_factor factor is 0, it will proc a specific case
	 */
	var/alignement_factor = 0

/datum/game_mode/proc/initialize_emergency_calls()
	if(length(all_calls)) //It's already been set up.
		return

	var/list/total_calls = typesof(/datum/emergency_call)
	if(!length(total_calls))
		CRASH("No distress Datums found.")

	for(var/x in total_calls)
		var/datum/emergency_call/D = new x()
		if(!D?.name)
			continue //The default parent, don't add it
		all_calls += D


//Randomizes and chooses a call datum.
/datum/game_mode/proc/get_random_call()
	var/normalised_monitor_state = SSmonitor.current_points / XENOS_LOSING_THRESHOLD
	var/list/calls_weighted = list()
	var/total_weight = 0
	for(var/datum/emergency_call/E in all_calls) //Loop through all potential candidates
		if(E.base_probability <= 0)
			continue
		var/weight = E.get_actualised_weight(normalised_monitor_state)
		calls_weighted[E] = weight
		total_weight += weight
	var/datum/emergency_call/chosen = pickweight(calls_weighted)
	message_admins("[chosen.name] was randomly picked from all emergency calls possible with a probability of [(calls_weighted[chosen] / total_weight) * 100]")
	return chosen

/**
 * Return a new current_weight using the base probability, the Alignement factor of the ERT and the monitor state
 * monitor_state : the normalised state of the monitor. If it's equal to -1, monitor is barely in its MARINE_LOSING state.
 * A +2.5 value mean we are beyond the XENO_DELAYING state, aka marines have crushed the xenos
 */
/datum/emergency_call/proc/get_actualised_weight(monitor_state)
	var/probability_direction = (monitor_state * alignement_factor)
	if(probability_direction >= 0)
		return base_probability * (1+probability_direction)
	return base_probability / (1-probability_direction)


/datum/emergency_call/proc/show_join_message()
	if(!mob_max || !SSticker?.mode) //Not a joinable distress call.
		return

	for(var/i in GLOB.observer_list)
		var/mob/dead/observer/M = i
		to_chat(M, "<br><font size='3'>[span_attack("An emergency beacon has been activated. Use the <B>Ghost > <a href='byond://?src=[REF(M)];join_ert=1'>Join Response Team</a></b> verb to join!")]</font><br>")
		to_chat(M, "[span_attack("You cannot join if you have Ghosted before this message.")]<br>")


/datum/game_mode/proc/activate_distress(datum/emergency_call/chosen_call)
	picked_call = chosen_call || get_random_call()

	if(SSticker?.mode?.waiting_for_candidates) //It's already been activated
		return FALSE

	picked_call.mob_max = rand(5, 15)

	picked_call.activate()


/mob/dead/observer/verb/JoinResponseTeam()
	set name = "Join Response Team"
	set category = "Ghost"
	set desc = "Join an ongoing distress call response. You must be ghosted to do this."

	var/datum/emergency_call/distress = SSticker?.mode?.picked_call //Just to simplify things a bit

	if(is_banned_from(usr.ckey, ROLE_ERT))
		to_chat(usr, span_danger("You are jobbanned from the emergency reponse team!"))
		return

	if(!istype(distress) || !SSticker.mode.waiting_for_candidates || distress.mob_max < 1)
		to_chat(usr, span_warning("No distress beacons that need candidates are active. You will be notified if that changes."))
		return

	var/deathtime = world.time - GLOB.key_to_time_of_role_death[key]

	if(deathtime < 600 && !check_other_rights(usr.client, R_ADMIN, FALSE)) //They have ghosted after the announcement.
		to_chat(usr, span_warning("You ghosted too recently. Try again later."))
		return

	if(usr.mind in distress.candidates)
		to_chat(usr, span_warning("You are already a candidate for this emergency response team."))
		return

	if(distress.add_candidate(usr))
		to_chat(usr, span_boldnotice("You are now a candidate in the emergency response team! If there are enough candidates, you may be picked to be part of the team."))
	else
		to_chat(usr, span_warning("Something went wrong while adding you into the candidate list!"))

/datum/emergency_call/proc/reset()
	if(candidate_timer)
		deltimer(candidate_timer)
		candidate_timer = null
	if(cooldown_timer)
		deltimer(cooldown_timer)
		cooldown_timer = null
	members.Cut()
	candidates.Cut()
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
		priority_announce("A distress beacon has been launched from the [SSmapping.configs[SHIP_MAP].map_name].", "Priority Alert", sound = 'sound/AI/distressbeacon.ogg')

	SSticker.mode.on_distress_cooldown = TRUE

	candidate_timer = addtimer(CALLBACK(src, .proc/do_activate, announce), 1 MINUTES, TIMER_STOPPABLE)

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
				to_chat(M.current, span_warning("You didn't get selected to join the distress team because you aren't dead."))
				continue
		if(name == "Xenomorphs" && is_banned_from(ckey(M.key), ROLE_XENOMORPH))
			if(M.current)
				to_chat(M, span_warning("You didn't get selected to join the distress team because you are jobbanned from Xenomorph."))
			continue
		valid_candidates += M

	message_admins("Distress beacon: [name] got [length(candidates)] candidates, [length(valid_candidates)] of them were valid.")

	if(mob_min && length(valid_candidates) < mob_min)
		message_admins("Aborting distress beacon [name], not enough candidates. Found: [length(valid_candidates)]. Minimum required: [mob_min].")
		SSticker.mode.waiting_for_candidates = FALSE
		members.Cut() //Empty the members list.
		candidates.Cut()

		if(announce)
			priority_announce("The distress signal has not received a response, the launch tubes are now recalibrating.", "Distress Beacon")

		SSticker.mode.picked_call = null
		SSticker.mode.on_distress_cooldown = TRUE

		cooldown_timer = addtimer(CALLBACK(src, .proc/reset), COOLDOWN_COMM_REQUEST, TIMER_STOPPABLE)
		return

	var/list/datum/mind/picked_candidates = list()
	if(length(valid_candidates) > mob_max)
		for(var/i in 1 to mob_max)
			if(!length(valid_candidates)) //We ran out of candidates.
				break
			picked_candidates += pick_n_take(valid_candidates) //Get a random candidate, then remove it from the candidates list.

		for(var/datum/mind/M in valid_candidates)
			if(M.current)
				to_chat(M.current, span_warning("You didn't get selected to join the distress team. Better luck next time!"))
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
	var/datum/map_template/shuttle/S = SSmapping.shuttle_templates[shuttle_id]

	shuttle = SSshuttle.load_template_to_transit(S)
	if(!shuttle)
		message_admins("Distress beacon: shuttle loading failed")
		reset()
		return

	spawn_items()

	if(mob_min > 0)
		if(length(picked_candidates))
			max_medics = max(round(length(picked_candidates) * 0.25), 1)
			for(var/i in picked_candidates)
				var/datum/mind/candidate_mind = i
				members += candidate_mind
				create_member(candidate_mind)
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

	candidates.Cut() //Blank out the candidates list for next time.

	cooldown_timer = addtimer(CALLBACK(src, .proc/reset), COOLDOWN_COMM_REQUEST, TIMER_STOPPABLE)

/datum/emergency_call/proc/add_candidate(mob/M)
	if(!M.client)
		return FALSE  //Not connected

	if(M.mind && (M.mind in candidates))
		return FALSE  //Already there.

	if(M.stat != DEAD)
		return FALSE  //Alive, could have been drafted into xenos or something else.

	if(!M.mind) //They don't have a mind
		return FALSE

	candidates += M.mind
	return TRUE


/datum/emergency_call/proc/get_spawn_point(is_for_items)
	var/atom/movable/effect/landmark/L
	if(is_for_items)
		L = pick(shuttle?.item_spawns)
	else
		L = pick(shuttle?.mob_spawns)
	if(L)
		return get_turf(L)

/datum/emergency_call/proc/create_member(datum/mind/mind_to_assign) //Overriden in each distress call file.
	SHOULD_CALL_PARENT(TRUE)
	var/turf/spawn_loc = get_spawn_point()

	if(!istype(spawn_loc))
		CRASH("[type] failed to find a proper spawn_loc")

	return spawn_type ? new spawn_type(spawn_loc) : spawn_loc


/datum/emergency_call/proc/spawn_items() //Allows us to spawn various things around the shuttle.
	return


/datum/emergency_call/proc/print_backstory(mob/living/carbon/human/M)
	return
