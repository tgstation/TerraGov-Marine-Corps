//This file deals with distress beacons. It randomizes between a number of different types when activated.
//There's also an admin commmand which lets you set one to your liking.




//basic persistent gamemode stuff.
/datum/game_mode
	var/list/datum/emergency_call/all_calls = list() //initialized at round start and stores the datums.
	var/datum/emergency_call/picked_call = null //Which distress call is currently active
	var/has_called_emergency = 0
	var/distress_cooldown = 0
	var/waiting_for_candidates = 0

//The distress call parent. Cannot be called itself due to "name" being a filtered target.
/datum/emergency_call
	var/name = "name"
	var/mob_max = 3
	var/mob_min = 3
	var/dispatch_message = "An encrypted signal has been received from a nearby vessel. Stand by." //Msg to display when starting
	var/arrival_message = "" //Msg to display about when the shuttle arrives
	var/objectives //Txt of objectives to display to joined. Todo: make this into objective notes
	var/probability = 0 //Chance of it occuring. Total must equal 100%
	var/hostility //For ERTs who are either hostile or friendly by random chance.
	var/list/datum/mind/members = list() //Currently-joined members.
	var/list/datum/mind/candidates = list() //Potential candidates for enlisting.
//	var/waiting_for_candidates = 0 //Are we waiting on people to join?
	var/role_needed = BE_RESPONDER //Obsolete
	var/name_of_spawn = "Distress" //If we want to set up different spawn locations
	var/mob/living/carbon/leader = null //Who's leading these miscreants
	var/medics = 0
	var/heavies = 0
	var/max_medics = 1
	var/max_heavies = 1
	var/shuttle_id = "Distress"
	var/auto_shuttle_launch = FALSE


/datum/game_mode/proc/initialize_emergency_calls()
	if(all_calls.len) //It's already been set up.
		return

	var/list/total_calls = typesof(/datum/emergency_call)
	if(!total_calls.len)
		world << "\red \b Error setting up emergency calls, no datums found."
		return 0
	for(var/S in total_calls)
		var/datum/emergency_call/C= new S()
		if(!C)	continue
		if(C.name == "name") continue //The default parent, don't add it
		all_calls += C

//Randomizes and chooses a call datum.
/datum/game_mode/proc/get_random_call()
	var/chance = rand(1,100)
	var/add_prob = 0
	var/datum/emergency_call/chosen_call

	for(var/datum/emergency_call/E in all_calls) //Loop through all potential candidates
		if(chance >= E.probability + add_prob) //Tally up probabilities till we find which one we landed on
			add_prob += E.probability
			continue
		chosen_call = E //Our random chance found one.
		E.hostility = pick(75;0,25;1)
		break

	if(!istype(chosen_call))
		world << "\red Something went wrong with emergency calls. Tell a coder!"
		return null
	else
		return chosen_call

/datum/emergency_call/proc/show_join_message()
	if(!mob_max || !ticker || !ticker.mode) //Just a supply drop, don't bother.
		return

//	var/list/datum/mind/possible_joiners = ticker.mode.get_players_for_role(role_needed) //Default role_needed is BE_RESPONDER
	for(var/mob/dead/observer/M in player_list)
		if(M.client)
			M << "\n<font size='3'><span class='attack'>An emergency beacon has been activated. Use the <B>Ghost > Join Response Team</b> verb to join!</span>"
			M << "<span class='attack'>You cannot join if you have Ghosted recently.</span>\n"

/datum/game_mode/proc/activate_distress()
	picked_call = get_random_call()
	if(!istype(picked_call, /datum/emergency_call)) //Something went horribly wrong
		return
	if(ticker && ticker.mode && ticker.mode.waiting_for_candidates) //It's already been activated
		return
	picked_call.activate()
	return

/mob/dead/observer/verb/JoinResponseTeam()
	set name = "Join Response Team"
	set category = "Ghost"
	set desc = "Join an ongoing distress call response. You must be ghosted to do this."

	if(jobban_isbanned(usr, "Syndicate") || jobban_isbanned(usr, "Emergency Response Team"))
		usr << "<span class='danger'>You are jobbanned from the emergency reponse team!</span>"
		return
	if(!ticker || !ticker.mode || isnull(ticker.mode.picked_call))
		usr << "<span class='warning'>No distress beacons are active. You will be notified if this changes.</span>"
		return

	var/datum/emergency_call/distress = ticker.mode.picked_call //Just to simplify things a bit
	if(!istype(distress) || !distress.mob_max)
		usr << "<span class='warning'>The emergency response team is already full!</span>"
		return
	var/deathtime = world.time - usr.timeofdeath

	if(deathtime < 600) //Nice try, ghosting right after the announcement
		usr << "<span class='warning'>You ghosted too recently.</span>"
		return

	if(!ticker.mode.waiting_for_candidates)
		usr << "<span class='warning'>The emergency response team has already been selected.</span>"
		return

	if(!usr.mind) //How? Give them a new one anyway.
		usr.mind = new /datum/mind(usr.key)
		usr.mind.active = 1
		usr.mind.current = usr
	if(usr.mind.key != usr.key) usr.mind.key = usr.key //Sigh. This can happen when admin-switching people into afking people, leading to runtime errors for a clientless key.

	if(!usr.client || !usr.mind) return //Somehow
	if(usr.mind in distress.candidates)
		usr << "<span class='warning'>You are already a candidate for this emergency response team.</span>"
		return

	if(distress.add_candidate(usr))
		usr << "<span class='boldnotice'>You are now a candidate in the emergency response team! If there are enough candidates, you may be picked to be part of the team.</span>"
	else
		usr << "<span class='warning'>You did not get enlisted in the response team. Better luck next time!</span>"

/datum/emergency_call/proc/activate(announce = TRUE)
	if(!ticker || !ticker.mode) //Something horribly wrong with the gamemode ticker
		return

	if(ticker.mode.has_called_emergency) //It's already been called.
		return

	if(mob_max > 0)
		ticker.mode.waiting_for_candidates = 1
	show_join_message() //Show our potential candidates the message to let them join.
	message_admins("Distress beacon: '[name]' activated. Looking for candidates.", 1)

	if (announce)
		command_announcement.Announce("A distress beacon has been launched from the [MAIN_SHIP_NAME].", "Priority Alert", new_sound='sound/AI/distressbeacon.ogg')

	ticker.mode.has_called_emergency = 1
	spawn(600) //If after 60 seconds we aren't full, abort
		if(candidates.len < mob_min)
			message_admins("Aborting distress beacon, not enough candidates: found [candidates.len].", 1)
			ticker.mode.waiting_for_candidates = 0
			ticker.mode.has_called_emergency = 0
			members = list() //Empty the members list.
			candidates = list()

			if (announce)
				command_announcement.Announce("The distress signal has not received a response, the launch tubes are now recalibrating.", "Distress Beacon")

			ticker.mode.distress_cooldown = 1
			ticker.mode.picked_call = null
			spawn(1200)
				ticker.mode.distress_cooldown = 0
		else //We've got enough!
			//Trim down the list
			var/list/datum/mind/picked_candidates = list()
			if(mob_max > 0)
				for(var/i = 1 to mob_max)
					if(!candidates.len) break//We ran out of candidates, maybe they alienized. Use what we have.
					var/datum/mind/M = pick(candidates) //Get a random candidate, then remove it from the candidates list.
					if(istype(M.current,/mob/living/carbon/Xenomorph))
						candidates.Remove(M) //Strip them from the list, they aren't dead anymore.
						if(!candidates.len) break //NO picking from empty lists
						M = pick(candidates)
					if(!istype(M))//Something went horrifically wrong
						candidates.Remove(M)
						if(!candidates.len) break //No empty lists!!
						M = pick(candidates) //Lets try this again
					picked_candidates.Add(M)
					candidates.Remove(M)
				spawn(3) //Wait for all the above to be done
					if(candidates.len)
						for(var/datum/mind/I in candidates)
							if(I.current)
								I.current << "<span class='warning'>You didn't get selected to join the distress team. Better luck next time!</span>"

			if (announce)
				command_announcement.Announce(dispatch_message, "Distress Beacon", new_sound='sound/AI/distressreceived.ogg') //Announcement that the Distress Beacon has been answered, does not hint towards the chosen ERT

			message_admins("Distress beacon: [src.name] finalized, setting up candidates.", 1)
			var/datum/shuttle/ferry/shuttle = shuttle_controller.shuttles[shuttle_id]
			if(!shuttle || !istype(shuttle))
				message_admins("Warning: Distress shuttle not found. Aborting.")
				return
			spawn_items()

			if(auto_shuttle_launch)
				shuttle.launch()

			if(picked_candidates.len)
				var/i = 0
				for(var/datum/mind/M in picked_candidates)
					members += M
					i++
					if(i > mob_max) break //Some logic. Hopefully this will never happen..
					spawn(1 + i)
						create_member(M)
			candidates = null //Blank out the candidates list for next time.
			candidates = list()

/datum/emergency_call/proc/add_candidate(var/mob/M)
	if(!M.client) return 0//Not connected
	if(M.mind && M.mind in candidates) return 0//Already there.
	if(istype(M,/mob/living/carbon/Xenomorph) && !M.stat) return 0//Something went wrong
	if(M.mind)
		candidates += M.mind
	else
		if(M.key)
			M.mind = new /datum/mind(M.key)
			candidates += M.mind
	return 1


/datum/emergency_call/proc/get_spawn_point(is_for_items)
	var/list/spawn_list = list()

	for(var/obj/effect/landmark/L in landmarks_list)
		if(is_for_items && L.name == "[name_of_spawn]Item")
			spawn_list += L
		else
			if(L.name == name_of_spawn) //Default is "Distress"
				spawn_list += L

	if(!spawn_list.len) //Empty list somehow
		return null

	var/turf/spawn_loc	= get_turf(pick(spawn_list))
	if(!istype(spawn_loc))
		return null

	return spawn_loc



/datum/emergency_call/proc/create_member(datum/mind/M) //This is the parent, each type spawns its own variety.
	return

//Spawn various items around the shuttle area thing.
/datum/emergency_call/proc/spawn_items()
	return


/datum/emergency_call/proc/print_backstory(mob/living/carbon/human/M)
	return
