/datum/game_mode
	var/list/datum/mind/aliens = list()
	var/list/datum/mind/survivors = list()
	var/queen_death_timer = 0
	var/list/datum/mind/predators = list()
	var/list/datum/mind/hellhounds = list()
	var/pred_keys = list()

/datum/game_mode/colonialmarines
	name = "colonial marines"
	config_tag = "colonialmarines"
	required_players = 1
	var/checkwin_counter = 0
	var/finished = 0
	var/humansurvivors = 0
	var/aliensurvivors = 0
	var/numaliens = 0
	var/numsurvivors = 0
	var/has_started_timer = 5 //This is a simple timer so we don't accidently check win conditions right in post-game
	var/pred_chance = 5 //1 in <x>
	var/is_pred_round = 0
	var/numpreds = 0


/* Pre-pre-startup */
//We have to be really careful that we don't pick() from null lists.
//So use list.len as much as possible before a pick() for logic checks.
/datum/game_mode/colonialmarines/can_start()

	// Alien number scales to player number (preferred). Swap these to test solo.
	var/readyplayers = num_players()

	numaliens = Clamp((readyplayers/5), 1, 14) //(n, minimum, maximum)
	var/list/datum/mind/possible_aliens = get_players_for_role(BE_ALIEN)
	var/list/datum/mind/possible_survivors = get_players_for_role(BE_SURVIVOR)
	var/list/datum/mind/possible_predators = get_whitelisted_predators()


	if(possible_aliens.len==0)
		world << "<h2 style=\"color:red\">Not enough players have chosen 'Be alien' in their character setup. Aborting.</h2>"
		return 0

	if(round(rand(1,pred_chance)) == 1) //Just make sure we have enough.
		is_pred_round = 1
		while(numpreds < 3)
			if(!possible_predators.len)
				break
			else
				var/datum/mind/new_pred = pick(possible_predators)
				possible_predators -= new_pred
				predators += new_pred
				numpreds--
				new_pred.assigned_role = "MODE"
				new_pred.special_role = "Predator"
	else
		is_pred_round = 0


	for(var/datum/mind/A in possible_aliens) //We have to clean out the predators who've been picked already.
		if(A.assigned_role == "MODE")
			possible_aliens -= A

	while(numaliens > 0)
		if(!possible_aliens.len) //Ran out of aliens! Abort!
			numaliens = 0
		else
			var/datum/mind/new_alien = pick(possible_aliens)
			if(numaliens > 0 && !new_alien) //We ran out of total alien candidates!
				numaliens = 0
			else
				aliens += new_alien
				possible_aliens -= new_alien
				numaliens--

	if(!aliens.len) //Our list is empty! This shouldn't EVER happen. Abort!
		world << "<h2 style=\"color:red\">Something is messed up with the alien generator - no alien candidates found. Aborting.</h2>"
		return 0

	for(var/datum/mind/A in aliens)
		A.assigned_role = "MODE"
		A.special_role = "Alien"

	// Handle Survivors
	//First make sure we have ANY candidates. There might be none.
	if(possible_survivors.len)
		for(var/datum/mind/X in possible_survivors) //Strip out any xenos first so we don't double-dip.
			if(X.assigned_role == "MODE")
				possible_survivors -= X

		numsurvivors = Clamp((readyplayers/7), 0, 3) //(n, minimum, maximum)
		if(possible_survivors.len) //We may have stripped out all the contendors, so check again.
			while(numsurvivors > 0)
				if(!possible_survivors.len) //Ran out of candidates! Can't have a null pick(), so just stick with what we have.
					numsurvivors = 0
				else
					var/datum/mind/new_survivor = pick(possible_survivors)
					if(numsurvivors > 0 && !new_survivor) //We ran out of survivors!
						numsurvivors = 0
					else
						survivors += new_survivor
						possible_survivors -= new_survivor
						numsurvivors--

	//Unlike the alien list, survivor lists CAN be empty. It's really unlikely though
	if(survivors.len)
		for(var/datum/mind/S in survivors)
			if(S.assigned_role != "MODE") //Make sure it's not already here.
				S.assigned_role = "MODE"
				S.special_role = "Survivor"

	return 1

/datum/game_mode/colonialmarines/announce()
	world << "<B>The current game mode is - Colonial Marines!/B>"

/datum/game_mode/colonialmarines/send_intercept()
	return 1

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/* Pre-setup */
//We can ignore this for now, we don't want to do anything before characters are set up.
/datum/game_mode/colonialmarines/pre_setup()
	return 1

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/* Post-setup */
//This happens after create_character, so our mob SHOULD be valid and built by now, but without job data.
//We move it later with transform_survivor but they might flicker at any start_loc spawn landmark effects then disappear.
//Xenos and survivors should not spawn anywhere until we transform them.
/datum/game_mode/colonialmarines/post_setup()

	for(var/datum/mind/alien in aliens) //Build and move the xenos.
		transform_xeno(alien)

	for(var/datum/mind/survivor in survivors) //Build and move to the survivors.
		transform_survivor(survivor)

	for(var/datum/mind/pred in predators) //Build and move to the survivors.
		transform_predator(pred)

	defer_powernet_rebuild = 2 //Build powernets a little bit later, it lags pretty hard.

	spawn (50)
		command_announcement.Announce("An automated distress signal has been received from archaeology site Lazarus Landing, on border world LV-624. A response team from the USS Sulaco will be dispatched shortly to investigate.", "USS Sulaco")


/datum/game_mode/colonialmarines/proc/transform_xeno(var/datum/mind/ghost)

	var/mob/living/carbon/Xenomorph/Larva/new_xeno = new(pick(xeno_spawn))
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
/datum/game_mode/colonialmarines/proc/transform_survivor(var/datum/mind/ghost)

	var/mob/living/carbon/human/H = ghost.current

	H.loc = pick(surv_spawn)

	//Damage them for realism purposes
	H.take_organ_damage(rand(0,15), rand(0,15))

//Give them proper jobs and stuff here later
	var/randjob = rand(0,10)
	switch(randjob)
		if(0) //assistant
			H.equip_to_slot_or_del(new /obj/item/clothing/under/colonist(H), slot_w_uniform)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), slot_shoes)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
		if(1) //civilian in pajamas
			H.equip_to_slot_or_del(new /obj/item/clothing/under/pj/red(H), slot_w_uniform)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), slot_shoes)
		if(2) //Scientist
			H.equip_to_slot_or_del(new /obj/item/clothing/under/colonist(H), slot_w_uniform)
			H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat(H), slot_wear_suit)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), slot_shoes)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel_tox(H), slot_back)
		if(3) //Doctor
			H.equip_to_slot_or_del(new /obj/item/clothing/under/colonist(H), slot_w_uniform)
			H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat(H), slot_wear_suit)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), slot_shoes)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/medical(H), slot_belt)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel_med(H), slot_back)
		if(4) //Chef!
			H.equip_to_slot_or_del(new /obj/item/clothing/under/colonist(H), slot_w_uniform)
			H.equip_to_slot_or_del(new /obj/item/clothing/suit/chef(H), slot_wear_suit)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), slot_shoes)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
			H.equip_to_slot_or_del(new /obj/item/weapon/kitchen/rollingpin(H), slot_l_hand)
		if(5) //Botanist
			H.equip_to_slot_or_del(new /obj/item/clothing/under/colonist(H), slot_w_uniform)
			H.equip_to_slot_or_del(new /obj/item/clothing/suit/apron(H), slot_wear_suit)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), slot_shoes)
			H.equip_to_slot_or_del(new /obj/item/weapon/hatchet(H), slot_belt)
		if(6)//Atmos
			H.equip_to_slot_or_del(new /obj/item/clothing/under/colonist(H), slot_w_uniform)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), slot_shoes)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/utility/atmostech(H), slot_belt)
		if(7) //Chaplain
			H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/chaplain(H), slot_w_uniform)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), slot_shoes)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/bible/booze(H), slot_l_hand)
		if(8) //Miner
			H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/miner(H), slot_w_uniform)
			H.equip_to_slot_or_del(new /obj/item/weapon/pickaxe(H), slot_l_hand)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), slot_shoes)
		if(9) //Corporate guy
			H.equip_to_slot_or_del(new /obj/item/clothing/under/liaison_suit(H), slot_w_uniform)
			H.equip_to_slot_or_del(new /obj/item/clothing/suit/wcoat(H), slot_wear_suit)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), slot_shoes)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/briefcase(H), slot_l_hand)
		if(10) //Colonial Marshal
			H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/CMB(H), slot_wear_suit)
			H.equip_to_slot_or_del(new /obj/item/clothing/under/CM_uniform(H), slot_w_uniform)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/jackboots(H), slot_shoes)
			H.equip_to_slot_or_del(new /obj/item/weapon/gun/revolver/cmb(H), slot_l_hand)


	var/randgear = rand(0,20) //slot_l_hand and slot_r/l_store are taken above.
	switch(randgear)
		if(0)
			H.equip_to_slot_or_del(new /obj/item/device/camera/fluff/oldcamera(H), slot_r_hand)
		if(1)
			H.equip_to_slot_or_del(new /obj/item/weapon/crowbar(H), slot_r_hand)
		if(2)
			H.equip_to_slot_or_del(new /obj/item/device/flashlight/flare(H), slot_r_hand)
		if(3)
			H.equip_to_slot_or_del(new /obj/item/weapon/wrench(H), slot_r_hand)
		if(4)
			H.equip_to_slot_or_del(new /obj/item/weapon/surgicaldrill(H), slot_r_hand)
		if(5)
			H.equip_to_slot_or_del(new /obj/item/stack/medical/bruise_pack(H), slot_r_hand)
		if(6)
			H.equip_to_slot_or_del(new /obj/item/weapon/butterfly/switchblade(H), slot_r_hand)
		if(7)
			H.equip_to_slot_or_del(new /obj/item/weapon/kitchenknife(H), slot_r_hand)
		if(8)
			H.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/food/snacks/lemoncakeslice(H), slot_r_hand)
		if(9)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/hardhat/dblue(H), slot_r_hand)
		if(10)
			H.equip_to_slot_or_del(new /obj/item/weapon/weldingtool/largetank(H), slot_r_hand)

	H.equip_to_slot_or_del(new /obj/item/device/flashlight(H), slot_r_store)
	H.equip_to_slot_or_del(new /obj/item/weapon/crowbar(H), slot_l_store)

	H.update_icons()

	//Give them some information
	spawn(4)
		H << "<h2>You are a survivor!</h2>"
		H << "\blue You are a survivor of the attack on LV-624. You worked or lived in the archaeology colony, and managed to avoid the alien attacks.. until now."
		H << "\blue You are fully aware of the xenomorph threat and are able to use this knowledge as you see fit."
		H << "\blue You are NOT aware of the marines or their intentions, and lingering around arrival zones will get you survivor-banned."
	return 1

//Deferred for now, this can wait.
/*
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
*/

//This is processed each tick, but check_win is only checked 5 ticks, so we don't go crazy with scanning for mobs.
/datum/game_mode/colonialmarines/process()

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
/datum/game_mode/colonialmarines/proc/count_humans()
	var/human_count = 0
	for(var/mob/living/carbon/human/H in living_mob_list)
		if(H) //Prevent any runtime errors
			if(H.client && istype(H) && H.stat != DEAD && !(H.status_flags & XENO_HOST) && H.z != 0 && !istype(H.loc,/turf/space) && !istype(get_area(H.loc),/area/centcom) && !istype(get_area(H.loc),/area/tdome))
				if(H.species != "Yautja") // Preds don't count in round end.
					human_count += 1 //Add them to the amount of people who're alive.
		else
			log_debug("ERROR! NULL MOB IN LIVING MOB LIST! COUNT_HUMANS()")

	return human_count

//Count up surviving xenos.
//This checks xenos that are:
//Played by a person, is not dead, is not in a closet, is not in space.
/datum/game_mode/colonialmarines/proc/count_xenos()
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
/datum/game_mode/colonialmarines/check_win()
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
/datum/game_mode/colonialmarines/check_finished()
	if(finished != 0)
		return 1

	return 0


//////////////////////////////////////////////////////////////////////
//Announces the end of the game with all relevant information stated//
//////////////////////////////////////////////////////////////////////
/datum/game_mode/colonialmarines/declare_completion()
	if(finished == 1)
		feedback_set_details("round_end_result","alien major victory - marine incursion fails")
		world << "\red <FONT size = 4><B>Alien major victory!</B></FONT>"
		world << "<FONT size = 3><B>The aliens have successfully wiped out the marines and will live to spread the infestation!</B></FONT>"
		if(prob(50))
			world << 'sound/misc/Game_Over_Man.ogg'
		else
			world << 'sound/misc/asses_kicked.ogg'
		if(round_stats) // Logging to data/logs/round_stats.log
			round_stats << "Alien major victory\nXenos Remaining: [count_xenos()]. Humans remaining: [count_humans()]\nRound time: [worldtime2text()][log_end]"

	else if(finished == 2)
		feedback_set_details("round_end_result","marine major victory - xenomorph infestation eradicated")
		world << "\red <FONT size = 4><B>Marines major victory!</B></FONT>"
		world << "<FONT size = 3><B>The marines managed to wipe out the aliens and stop the infestation!</B></FONT>"
		if(prob(50))
			world << 'sound/misc/hardon.ogg'
		else
			world << 'sound/misc/hell_march.ogg'
		if(round_stats) // Logging to data/logs/round_stats.log
			round_stats << "Marine major victory\nXenos Remaining: [count_xenos()]. Humans remaining: [count_humans()]\nRound time: [worldtime2text()][log_end]"

	else if(finished == 3)
		feedback_set_details("round_end_result","marine minor victory - infestation stopped at a great cost")
		world << "\red <FONT size = 3><B>Marine minor victory.</B></FONT>"
		world << "<FONT size = 3><B>Both the marines and the aliens have been terminated. At least the infestation has been eradicated!</B></FONT>"
		world << 'sound/misc/sadtrombone.ogg'
		if(round_stats) // Logging to data/logs/round_stats.log
			round_stats << "Marine minor victory (Both dead)\nXenos Remaining: [count_xenos()]. Humans remaining: [count_humans()]\nRound time: [worldtime2text()][log_end]"

	else if(finished == 4)
		feedback_set_details("round_end_result","alien minor victory - infestation survives")
		world << "\red <FONT size = 3><B>Alien minor victory.</B></FONT>"
		world << "<FONT size = 3><B>The Sulaco has been evacuated... but the infestation remains!</B></FONT>"
		if(round_stats) // Logging to data/logs/round_stats.log
			round_stats << "Alien minor victory (Evac)\nXenos Remaining: [count_xenos()]. Humans remaining: [count_humans()]\nRound time: [worldtime2text()][log_end]"

	else if(finished == 5)
		feedback_set_details("round_end_result","draw - the station has been nuked")
		world << "\red <FONT size = 3><B>Draw.</B></FONT>"
		world << "<FONT size = 3><B>The station has blown by a nuclear fission device... there are no winners!</B></FONT>"
		world << 'sound/misc/sadtrombone.ogg'
		if(round_stats) // Logging to data/logs/round_stats.log
			round_stats << "Draw (Nuke)\nXenos Remaining: [count_xenos()]. Humans remaining: [count_humans()]\nRound time: [worldtime2text()][log_end]"
	else
		world << "\red Whoops, something went wrong with declare_completion(), finished: [finished]. Blame the coders!"

	world << "Xenos Remaining: [count_xenos()]. Humans remaining: [count_humans()]."

	spawn(45)
		if(aliens.len)
			var/text = "<FONT size = 3><B>The Queen(s) were:</B></FONT>"
			for(var/datum/mind/A in aliens)
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
						text += "[M.real_name] ("
						if(M.stat == DEAD)
							text += "died"
						else
							text += "survived"
						text += ")"
					else
						text += "<BR>[A.key] was Unknown! (body destroyed)"

			world << text
		if(predators.len)
			var/text = "<br><FONT size = 3><B>The Predators were:</B></FONT>"
			for(var/datum/mind/A in predators)
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

/datum/game_mode/proc/auto_declare_completion_colonialmarines()
	return

