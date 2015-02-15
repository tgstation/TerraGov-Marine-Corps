
/datum/game_mode
	var/list/datum/mind/aliens = list()
	var/list/datum/mind/marines = list()
	var/list/datum/mind/survivors = list()

/datum/game_mode/colonialmarines
	name = "colonial marines"
	config_tag = "colonialmarines"
	required_players = 1
	var/checkwin_counter = 0
	var/finished = 0
	var/humansurvivors = 0
	var/aliensurvivors = 0
	

/* Pre-pre-startup */
/datum/game_mode/colonialmarines/can_start()

	if(!..())
		return 0
	
	var/list/datum/mind/possible_survivors = get_players_for_role(BE_SURVIVOR)
	var/list/datum/mind/possible_aliens = get_players_for_role(BE_ALIEN)
	var/numaliens = 0
	var/numsurvivors = 0
	var/n_players = num_players()
	
/* Un-comment this to debug stuff
	if(possible_survivors.len < 1)
		world << "<B>\red No survivors available</B>"
		return 0
	if(surv_spawn.len == 0)
		world << "<B>\red A starting location for survivors could not be found.</B>"
		return 0 
	if(xeno_spawn.len == 0)
		world << "<B>\red A starting location for aliens could not be found.</B>"
		return 0
*/

	//Check if anyone wants to be an alien. If not, restart the lobby countdown
	if(possible_aliens.len < 1)
		world << "<h2 style=\"color:red\">Not enough players have chosen 'Be alien' in their character setup. Aborting.</h2>"
		return 0
 
 	//Alien number scales to player number
	numaliens = Clamp((n_players/5), 2, 6) //(n, minimum, maximum)
	
	if(possible_aliens.len < numaliens)
		numaliens = possible_aliens.len

	while(numaliens > 0)
		var/datum/mind/new_alien = pick(possible_aliens)
		aliens += new_alien
		possible_aliens -= new_alien //So it doesn't pick the same guy each time
		numaliens--

	//Survivor number scales to player number
	numsurvivors = Clamp((n_players/5), 0, 3) //(n, minimum, maximum)
	
	if(possible_survivors.len < numsurvivors)
		numsurvivors = possible_survivors.len

	while(numsurvivors > 0)
		var/datum/mind/new_surv = pick(possible_survivors)
		survivors += new_surv
		possible_survivors -= new_surv //So it doesn't pick the same guy each time
		numsurvivors--

	//Assign alien and survivor roles
	for(var/datum/mind/alien_mind in aliens)
		alien_mind.assigned_role = "MODE" 	//So they aren't chosen for other jobs
		alien_mind.special_role = "Drone" 	//So they actually have a special role

	for(var/datum/mind/surv_mind in survivors)
		surv_mind.assigned_role = "Survivor"
		surv_mind.special_role = "Survivor"

	return 1

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/* Pre-setup */
/datum/game_mode/colonialmarines/pre_setup()
	//Spawn aliens
	for(var/datum/mind/alien_mind in aliens)
		alien_mind.current.loc = pick(xeno_spawn)
	//Spawn survivors
	for(var/datum/mind/surv_mind in survivors)
		surv_mind.current.loc = pick(surv_spawn)
	spawn (50)
	command_announcement.Announce("Distress signal received from the NSS Nostromo. A response team from NMV Sulaco will be dispatched shortly to investigate.", "NMV Sulaco")	
	return 1

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/* Post-setup */
/datum/game_mode/colonialmarines/post_setup()
	defer_powernet_rebuild = 2
	for(var/datum/mind/alien in aliens)
		transform_player(alien.current)
	for(var/datum/mind/alien in survivors)
		transform_player2(alien.current)
	for(var/mob/living/carbon/human/marine in mob_list)
		if(marine.stat != 2 && marine.mind)
			marines += marine.mind
	tell_story()

//Start the Alien players
/datum/game_mode/proc/transform_player(mob/living/carbon/human/H)

	//Transform alien players into only Drones by calling the "Alienize2" proc in modules/mob/transform_procs.dm
	H.Alienize2()
	
	//Give them some information
	H.client << "<h2>You are an alien!</h2>"
	H.client << "<h2>Use Say \":a <message>\" to communicate with other aliens.</h2>"
	return 1

//Start the Survivor players
/datum/game_mode/proc/transform_player2(mob/living/carbon/human/H)

	//Damage them for realism purposes
	H.take_organ_damage(rand(1,25), rand(1,25))
	
	//Equip them
	H.equip_to_slot_or_del(new /obj/item/clothing/under/color/grey(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), slot_shoes)

	//Give them some information
	H.client << "<h2>You are a survivor!</h2>"
	H.client << "\blue You were a crew member on the Nostromo. Your crew was wiped out by an alien infestation. You should try to locate and help other survivors (if there are any other than you.)"
	return 1

var/list/survivorstory = list("You watched your friend {name}'s chest burst and an alien larva come out. You tried to capture it but it escaped through the vents. ", "{name} was attacked by a facehugging alien, which impregnated them with an alien lifeform. {name}'s chest burst and a larva emerged and escaped through the vents", "You watched {name} get the alien lifeform's acid on them, melting away their flesh. You can still hear the screams... ", "The Head of Security, {name}, made an announcement that the aliens killed the Captain and Head of Personnel, and that all crew should hide and wait for rescue." )
var/list/survivorstorymulti = list("You were separated from your friend, {surv}. You hope they're still alive. ", "You were having some drinks at the bar with {surv} and {name} when an alien crawled out of the vent and dragged {name} away. You and {surv} split up to find help. ")
var/list/toldstory = list()
/datum/game_mode/colonialmarines/proc/tell_story()
	for(var/datum/mind/surv in survivors)
		if(!(surv.name in toldstory))
			var/story
			var/mob/living/carbon/human/OH
			var/mob/living/carbon/human/H = surv.current
			var/list/otherplayers = survivors
			for(var/datum/mind/surv2 in otherplayers)
				if(surv == surv2)
					otherplayers.Remove(surv2)
			var/randomname = random_name(FEMALE)
			if(prob(50))
				randomname = random_name(MALE)
			if(length(survivors) > 1)
				if(length(toldstory) == length(survivors) - 1 || length(otherplayers) == 0)
					story = pick(survivorstory)
					survivorstory.Remove(story)
				else
					story = pick(survivorstorymulti)
					survivorstorymulti.Remove(story)
					OH = pick(otherplayers)
			else
				story = pick(survivorstory)
				survivorstory.Remove(story)
			story = replacetext(story, "{name}", "[randomname]")
			if(istype(OH))
				toldstory.Add(OH.name)
				OH << replacetext(story, "{surv}", "[H.name]")
				H << replacetext(story, "{surv}", "[OH.name]")

			toldstory.Add(H.name)

/datum/game_mode/colonialmarines/process()
	//Reset the survivor count to zero per process call.
	humansurvivors = 0
	aliensurvivors = 0

	//For each survivor, add one to the count. Should work accurately enough.
	for(var/mob/living/carbon/human/H in living_mob_list)
		if(H) //Prevent any runtime errors
			if(H.client && H.status_flags & XENO_HOST && H.stat != DEAD) // If they're connected/unghosted and alive and not debrained
				humansurvivors += 1 //Add them to the amount of people who're alive.
	for(var/mob/living/carbon/alien/A in living_mob_list)
		if(A) //Prevent any runtime errors
			if(A.client && A.stat != DEAD) // If they're connected/unghosted and alive and not debrained
				aliensurvivors += 1

	//Debug messages, remove when not needed.
	//log_debug("there are [aliensurvivors] aliens left.")
	//log_debug("there are [humansurvivors] humans left.")

	checkwin_counter++
	if(checkwin_counter >= 5)
		if(!finished)
			ticker.mode.check_win()
		checkwin_counter = 0
	return 0

///////////////////////////
//Checks to see who won///
//////////////////////////
/datum/game_mode/colonialmarines/check_win()
	if(check_alien_victory())
		finished = 1
	else if(check_marine_victory())
		finished = 2
	if(check_nosurvivors_victory())
		finished = 3
	else if(check_survivors_victory())
		finished = 4
	else if(check_nuclear_victory())
		finished = 5
//	check_shuttle()
	..()

///////////////////////////////
//Checks if the round is over//
///////////////////////////////
/datum/game_mode/colonialmarines/check_finished()
	if(finished != 0)
		return 1
	else
		return 0


	//////////////////////////
//Checks for alien victory//
//////////////////////////
/*datum/game_mode/colonialmarines/proc/check_alien_victory()
	for(var/mob/living/carbon/alien/A in living_mob_list)
		var/turf/Terf = get_turf(A)
		if((A) && (A.stat != 2) && (humansurvivors < 1) && Terf && (Terf.z == 2))
			return 1
		else
			return 0*/
datum/game_mode/colonialmarines/proc/check_alien_victory()
	if(aliensurvivors > 0 && humansurvivors < 1)
		return 1
	else
		return 0

///////////////////////////////
//Check for a neutral victory//
///////////////////////////////
/datum/game_mode/colonialmarines/proc/check_nosurvivors_victory()
	if(humansurvivors < 1 && aliensurvivors < 1)
		return 1
	else
		return 0

///////////////////////////////
//Checks for a marine victory//
///////////////////////////////
/*datum/game_mode/colonialmarines/proc/check_marine_victory()
	for(var/mob/living/carbon/human/H in living_mob_list)
		var/turf/Terf = get_turf(H)
		if((H) && (H.stat != 2) && (aliensurvivors < 1) && Terf && (Terf.z == 2))
			return 1
		else
			return 0
			*/
/datum/game_mode/colonialmarines/proc/check_marine_victory()
	if(aliensurvivors < 1 && humansurvivors > 0)
		return 1
	else
		return 0

///////////////////////////////////////////////
//Check for a survivors victory (Alien minor)//
///////////////////////////////////////////////
/datum/game_mode/colonialmarines/proc/check_survivors_victory()
	if(emergency_shuttle.returned())
		return 1
	else
		return 0

//////////////////////////////////////
//Check for a nuclear victory (Draw)//
//////////////////////////////////////

/datum/game_mode/colonialmarines/proc/check_nuclear_victory()
	if(station_was_nuked)
		return 1
	else
		return 0


//////////////////////////////////////////////////////////////////////
//Announces the end of the game with all relavent information stated//
//////////////////////////////////////////////////////////////////////
/datum/game_mode/colonialmarines/declare_completion()
	if(finished == 1)
		feedback_set_details("round_end_result","alien major victory - marine incursion fails")
		world << "\red <FONT size = 3><B>The aliens have successfully wiped out the marines and will live to spread the infestation!</B></FONT>"
	else if(finished == 2)
		feedback_set_details("round_end_result","marine major victory - xenomorph infestation eradicated")
		world << "\red <FONT size = 3><B>The marines managed to wipe out the aliens and stop the infestation!</B></FONT>"
	else if(finished == 3)
		feedback_set_details("round_end_result","marine minor victory - infestation stopped at a great cost")
		world << "\red <FONT size = 3><B>Both the marines and the aliens have been terminated. At least the infestation has been eradicated!</B></FONT>"
	else if(finished == 4)
		feedback_set_details("round_end_result","alien minor victory - infestation survives")
		world << "\red <FONT size = 3><B>The station has been evacuated... but the infestation remains!</B></FONT>"
	else if(finished == 5)
		feedback_set_details("round_end_result","draw - the station has been nuked")
		world << "\red <FONT size = 3><B>The station has blown by a nuclear fission device... there are no winners!</B></FONT>"

	..()
	return 1

/datum/game_mode/proc/auto_declare_completion_colonialmarines()
	if( aliens.len || (ticker && istype(ticker.mode,/datum/game_mode/colonialmarines)) )
		var/text = "<FONT size = 2><B>The aliens were:</B></FONT>"
		for(var/mob/living/A in mob_list)
			if(A.mind && A.mind.assigned_role)
				if(A.mind.assigned_role == "Alien")
					var/mob/M = A.mind.current
					if(M)
						text += "<br>[M.key] was [M.name] ("
						if(M.stat == DEAD)
							text += "died"
						else
							text += "survived"
					else
						text += "body destroyed"
					text += ")"
		world << text