//CM HALLOWEEN GAME MODE

/datum/game_mode/Halloween
	// name = "Colonial Marines Halloween"
	// config_tag = "Colonial Marines Halloween"
	required_players = 1
	var/checkwin_counter = 0
	var/finished = 0
	var/humansurvivors = 0
	var/aliensurvivors = 0
	var/numaliens = 0
	var/numsurvivors = 0
	var/has_started_timer = 5 //This is a simple timer so we don't accidently check win conditions right in post-game


/* Pre-pre-startup */
//We have to be really careful that we don't pick() from null lists.
//So use list.len as much as possible before a pick() for logic checks.
/datum/game_mode/Halloween/can_start()

	// Alien number scales to player number (preferred). Swap these to test solo.
	var/readyplayers = num_players()

	numaliens = Clamp((readyplayers/5), 1, 14) //(n, minimum, maximum)
	var/list/datum/mind/possible_aliens = get_players_for_role(BE_ALIEN)

	if(possible_aliens.len==0)
		world << "<h2 style=\"color:red\">Not enough players have chosen 'Be alien' in their character setup. Aborting.</h2>"
		return 0

	while(numaliens > 0)
		if(!possible_aliens.len) //Ran out of aliens! Abort!
			numaliens = 0
		else
			var/datum/mind/new_alien = pick(possible_aliens)
			if(numaliens > 0 && !new_alien) //We ran out of total alien candidates!
				numaliens = 0
			else
				xenomorphs += new_alien
				possible_aliens -= new_alien
				numaliens--

	if(!xenomorphs.len) //Our list is empty! This shouldn't EVER happen. Abort!
		world << "<h2 style=\"color:red\">Something is messed up with the alien generator - no alien candidates found. Aborting.</h2>"
		return 0

	for(var/datum/mind/A in xenomorphs)
		A.assigned_role = "MODE"
		A.special_role = "Alien"



	//Unlike the alien list, survivor lists CAN be empty. It's really unlikely though
	if(survivors.len)
		for(var/datum/mind/S in survivors)
			if(S.assigned_role != "MODE") //Make sure it's not already here.
				S.assigned_role = "MODE"
				S.special_role = "Survivor"

	return 1

/datum/game_mode/Halloween/announce()
	world << "<B>The current game mode is - Colonial Marines Halloween! SpooOOOoooky!!!</B>"

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/* Pre-setup */
//We can ignore this for now, we don't want to do anything before characters are set up.
/datum/game_mode/Halloween/pre_setup()
	return 1

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/* Post-setup */
//This happens after create_character, so our mob SHOULD be valid and built by now, but without job data.
//We move it later with transform_survivor but they might flicker at any start_loc spawn landmark effects then disappear.
//Xenos and survivors should not spawn anywhere until we transform them.
/datum/game_mode/Halloween/post_setup()

	for(var/datum/mind/alien in xenomorphs) //Build and move the xenos.
		transform_xeno(alien)

	for(var/datum/mind/survivor in survivors) //Build and move to the survivors.
		transform_survivor(survivor)

	defer_powernet_rebuild = 2 //Build powernets a little bit later, it lags pretty hard.

	spawn (50)
		command_announcement.Announce("An admiral at Centcom has inherited an old manor from his great uncle.  There hasn't been any contact for some time, so the marines have been deployed to investigate...", "[MAIN_SHIP_NAME]")


/datum/game_mode/Halloween/transform_xeno(var/datum/mind/ghost)

	var/mob/living/carbon/Xenomorph/Larva/new_xeno = new(pick(xeno_spawn_HH))
	new_xeno.amount_grown = 100
	var/mob/original = ghost.current

	ghost.transfer_to(new_xeno)

	new_xeno << "<B>You are now an alien!</B>"
	new_xeno << "<B>Your job is to spread the hive and protect the Queen. You can become the Queen yourself by evolving into a drone.</B>"
	new_xeno << "Use say :a to talk to the hive."

	new_xeno.update_icons()

	if(original) //Just to be sure.
		del(original)

//Start the Survivor players. This must go post-setup so we already have a body.
/datum/game_mode/Halloween/transform_survivor(var/datum/mind/ghost)

	var/mob/living/carbon/human/H = ghost.current

	H.loc = pick(surv_spawn)

	//Damage them for realism purposes
	H.take_limb_damage(rand(0,15), rand(0,15))

//Give them proper jobs and stuff here later
	var/randjob = rand(0,9)
	switch(randjob)
		if(0) //assistant
			H.equip_to_slot_or_del(new /obj/item/clothing/under/color/grey(H), WEAR_BODY)
		if(1) //civilian in pajamas
			H.equip_to_slot_or_del(new /obj/item/clothing/under/pj/red(H), WEAR_BODY)
		if(2) //Scientist
			H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/scientist(H), WEAR_BODY)
			H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat(H), WEAR_JACKET)
		if(3) //Doctor
			H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/medical(H), WEAR_BODY)
			H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat(H), WEAR_JACKET)
		if(4) //Chef!
			H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/chef(H), WEAR_BODY)
			H.equip_to_slot_or_del(new /obj/item/clothing/suit/chef(H), WEAR_JACKET)
		if(5) //Botanist
			H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/hydroponics(H), WEAR_BODY)
			H.equip_to_slot_or_del(new /obj/item/clothing/suit/apron(H), WEAR_JACKET)
		if(6)//Atmos
			H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/atmospheric_technician(H), WEAR_BODY)
		if(7) //Chaplain
			H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/chaplain(H), WEAR_BODY)
		if(8) //Miner
			H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/miner(H), WEAR_BODY)
		if(9) //Corporate guy
			H.equip_to_slot_or_del(new /obj/item/clothing/under/liaison_suit(H), WEAR_BODY)
			H.equip_to_slot_or_del(new /obj/item/clothing/suit/wcoat(H), WEAR_JACKET)

	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), WEAR_FEET)
	H.equip_to_slot_or_del(new /obj/item/device/flashlight(H), WEAR_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/weapon/crowbar(H), WEAR_L_STORE)
	H.update_icons()

	//Give them some information
	spawn(4)
		H << "<h2>You are a survivor!</h2>"
		H << "\blue You are a survivor of the attack on LV-624. You worked or lived in the archaeology colony, and managed to avoid the alien attacks.. until now."
		H << "\blue You are fully aware of the xenomorph threat and are able to use this knowledge as you see fit."
		H << "\blue You are NOT aware of the marines or their intentions, and lingering around arrival zones will get you survivor-banned."
	return 1

//This is processed each tick, but check_win is only checked 5 ticks, so we don't go crazy with scanning for mobs.
/datum/game_mode/Halloween/process()

	if(queen_death_timer && !finished)
		queen_death_timer--
		if(queen_death_timer == 1)
			xeno_message("The Hive is ready for a new Queen to evolve.")

	checkwin_counter++

	if(has_started_timer > 0) //Initial countdown, just to be safe, so that everyone has a chance to spawn before we check anything.
		has_started_timer--

	if(checkwin_counter >= 5) //Only check win conditions every 5 ticks.
		if(!finished)
			ticker.mode.check_win()
		checkwin_counter = 0
	return 0


//Count up surviving humans.
//This checks for humans that are:
//Played by a person, is not dead, is not infected, is not in a closet/mech, and is not in space.
//It does NOT check for valid species or marines. vs. survivors.
/datum/game_mode/Halloween/proc/count_humans()
	var/human_count = 0
	for(var/mob/living/carbon/human/H in living_mob_list)
		if(H) //Prevent any runtime errors
			if(H.client && istype(H) && H.stat != DEAD && !(H.status_flags & XENO_HOST) && H.z != 0 && !istype(H.loc,/turf/space)) // If they're connected/unghosted and alive and not debrained
				if(H.species != "Yautja") // Preds don't count in round end.
					human_count += 1 //Add them to the amount of people who're alive.
		else
			log_debug("WARNING! NULL MOB IN LIVING MOB LIST! COUNT_HUMANS()")

	return human_count

//Count up surviving xenos.
//This checks xenos that are:
//Played by a person, is not dead, is not in a closet, is not in space.
/datum/game_mode/Halloween/proc/count_xenos()
	var/xeno_count = 0
	for(var/mob/living/carbon/Xenomorph/X in living_mob_list)
		if(X) //Prevent any runtime errors
			if(X.client && istype(X) && X.stat != DEAD && X.z != 0 && !istype(X.loc,/turf/space)) // If they're connected/unghosted and alive and not debrained
				xeno_count += 1 //Add them to the amount of people who're alive.
		else
			log_debug("WARNING! NULL MOB IN LIVING MOB LIST! COUNT_XENOS()")

	return xeno_count



///////////////////////////
//Checks to see who won///
//////////////////////////
/datum/game_mode/Halloween/check_win()
	if(has_started_timer) //Let's hold off on checking win conditions till everyone has spawned.
		finished = 0
		return

	//Count up our player controlled mobs.
	var/count_h = count_humans()
	var/count_x = count_xenos()

	if(count_h == 0 && count_x > 0) //No humans, some xenos
		finished = 1
	else if(count_h > 0 && count_x == 0) //Some humans, no xenos
		finished = 2
	else if(!count_h && !count_x) //No survivors!
		finished = 3
	else if(emergency_shuttle.returned()) //Emergency shuttle finished
		emergency_shuttle.evac = 1
		finished = 4
	else if(station_was_nuked) //Boom!
		finished = 5
	else
		finished = 0

	return

///////////////////////////////
//Checks if the round is over//
///////////////////////////////
/datum/game_mode/Halloween/check_finished()
	if(finished != 0)
		return 1

	return 0


//////////////////////////////////////////////////////////////////////
//Announces the end of the game with all relevant information stated//
//////////////////////////////////////////////////////////////////////
/datum/game_mode/Halloween/declare_completion()
	if(finished == 1)
		feedback_set_details("round_end_result","alien major victory - marine incursion fails")
		world << "\red <FONT size = 4><B>Alien major victory!</B></FONT>"
		world << "<FONT size = 3><B>The aliens have successfully wiped out the marines and will live to spread the infestation!</B></FONT>"
		if(prob(50))
			world << 'sound/misc/Game_Over_Man.ogg'
		else
			world << 'sound/misc/asses_kicked.ogg'
		if(round_stats) // Logging to data/logs/round_stats.log
			round_stats << "Alien major victory\nXenos Remaining: [count_xenos()]. Humans remaining: [count_humans()]\nRound time: [duration2text()][log_end]"

	else if(finished == 2)
		feedback_set_details("round_end_result","marine major victory - xenomorph infestation eradicated")
		world << "\red <FONT size = 4><B>Marines major victory!</B></FONT>"
		world << "<FONT size = 3><B>The marines managed to wipe out the aliens and stop the infestation!</B></FONT>"
		if(prob(50))
			world << 'sound/misc/hardon.ogg'
		else
			world << 'sound/misc/hell_march.ogg'
		if(round_stats) // Logging to data/logs/round_stats.log
			round_stats << "Marine major victory\nXenos Remaining: [count_xenos()]. Humans remaining: [count_humans()]\nRound time: [duration2text()][log_end]"

	else if(finished == 3)
		feedback_set_details("round_end_result","marine minor victory - infestation stopped at a great cost")
		world << "\red <FONT size = 3><B>Marine minor victory.</B></FONT>"
		world << "<FONT size = 3><B>Both the marines and the aliens have been terminated. At least the infestation has been eradicated!</B></FONT>"
		world << 'sound/misc/sadtrombone.ogg'
		if(round_stats) // Logging to data/logs/round_stats.log
			round_stats << "Marine minor victory (Both dead)\nXenos Remaining: [count_xenos()]. Humans remaining: [count_humans()]\nRound time: [duration2text()][log_end]"

	else if(finished == 4)
		feedback_set_details("round_end_result","alien minor victory - infestation survives")
		world << "\red <FONT size = 3><B>Alien minor victory.</B></FONT>"
		world << "<FONT size = 3><B>The [MAIN_SHIP_NAME] has been evacuated... but the infestation remains!</B></FONT>"
		if(round_stats) // Logging to data/logs/round_stats.log
			round_stats << "Alien minor victory (Evac)\nXenos Remaining: [count_xenos()]. Humans remaining: [count_humans()]\nRound time: [duration2text()][log_end]"

	else if(finished == 5)
		feedback_set_details("round_end_result","draw - the station has been nuked")
		world << "\red <FONT size = 3><B>Draw.</B></FONT>"
		world << "<FONT size = 3><B>The station has blown by a nuclear fission device... there are no winners!</B></FONT>"
		world << 'sound/misc/sadtrombone.ogg'
		if(round_stats) // Logging to data/logs/round_stats.log
			round_stats << "Draw (Nuke)\nXenos Remaining: [count_xenos()]. Humans remaining: [count_humans()]\nRound time: [duration2text()][log_end]"
	else
		world << "\red Whoops, something went wrong with declare_completion(), finished: [finished]. Blame the coders!"

	world << "Xenos Remaining: [count_xenos()]. Humans remaining: [count_humans()]."

	spawn(45)
		if(xenomorphs.len)
			var/text = "<FONT size = 3><B>The Queen(s) were:</B></FONT>"
			for(var/datum/mind/A in xenomorphs)
				if(A)
					var/mob/M = A.current
					if(!M)
						M = A.original

					if(M && istype(M,/mob/living/carbon/Xenomorph/Queen))
						text += "<br>[M.key] was "
						text += "[M.name] ("
						if(M.stat == DEAD)
							text += "died"
						else
							text += "survived"
						text += ")"
			world << text
		if(survivors.len)
			var/text = "<br><FONT size = 3><B>The survivors were:</B></FONT>"
			for(var/datum/mind/A in survivors)
				if(A)
					var/mob/M = A.current
					if(!M)
						M = A.original

					if(M)
						text += "<br>[M.key] was "
						text += "[M.name] ("
						if(M.stat == DEAD)
							text += "died"
						else
							text += "survived"
						text += ")"
					else
						text += "<BR>[A.key] was Unknown! (body destroyed)"

			world << text
//	..()
	return 1

/datum/game_mode/proc/auto_declare_completion_Halloween()
	return
