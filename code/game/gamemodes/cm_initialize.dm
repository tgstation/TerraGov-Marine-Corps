/*
This is a collection of procs related to CM and spawning aliens/predators/survivors. With this centralized system,
you can spawn them at round start in any game mode. You can also add additional categories, and they will be supported
at round start with no conflict. Individual game modes may override these settings to have their own unique
spawns for the various factions. It's also a bit more robust with some added parameters. For example, if xeno_required_num
is 0, you don't need aliens at the start of the game. If aliens are required for win conditions, tick it to 1 or more.

This is a basic outline of how things should function in code.
You can see a working example in the TerraGov Marine Corps game mode.

	//Minds are not transferred/made at this point, so we have to check for them so we don't double dip.
	can_start() //This should have the following in order:
		initialize_special_clamps()
		initialize_starting_predator_list()
		if(!initialize_starting_xenomorph_list()) //If we don't have the right amount of xenos, we can't start.
			return
		initialize_starting_survivor_list()

		return 1

	pre_setup()
		//Other things can take place, such as game mode specific setups.

		return 1

	post_setup()
		initialize_post_xenomorph_list()
		initialize_post_survivor_list()
		initialize_post_predator_list()

		return 1


//Flags defined in setup.dm
MODE_INFESTATION
MODE_PREDATOR

Additional game mode variables.
*/
#define XENO_STARTING_COEF 5.5
#define MERC_STARTING_COEF 3
#define SURVIVOR_STARTING_COEF 15

#define SURVIVOR_WEAPONS list(\
				list(/obj/item/weapon/gun/smg/mp7, /obj/item/ammo_magazine/smg/mp7),\
				list(/obj/item/weapon/gun/shotgun/double/sawn, /obj/item/ammo_magazine/shotgun/flechette),\
				list(/obj/item/weapon/gun/smg/uzi, /obj/item/ammo_magazine/smg/uzi),\
				list(/obj/item/weapon/gun/smg/mp5, /obj/item/ammo_magazine/smg/mp5),\
				list(/obj/item/weapon/gun/rifle/m16, /obj/item/ammo_magazine/rifle/m16),\
				list(/obj/item/weapon/gun/shotgun/pump/bolt, /obj/item/ammo_magazine/rifle/bolt))

/datum/game_mode
	var/datum/mind/xenomorphs[] = list() //These are our basic lists to keep track of who is in the game.
	var/datum/mind/queens[] = list() //List of queens
	var/datum/mind/survivors[] = list()
	var/datum/mind/predators[] = list()
	var/datum/mind/queen
	var/datum/mind/hellhounds[] = list() //Hellhound spawning is not supported at round start.
	var/pred_keys[] = list() //People who are playing predators, we can later reference who was a predator during the round.

	var/xeno_required_num 	= 0 //We need at least one. You can turn this off in case we don't care if we spawn or don't spawn xenos.
	var/xeno_starting_num 	= 0 //To clamp starting xenos.
	var/xeno_bypass_timer 	= 0 //Bypass the five minute timer before respawning.
	var/queen_death_countdown = 0
	var/surv_starting_num 	= 0 //To clamp starting survivors.
	var/merc_starting_num 	= 0 //PMC clamp.
	var/marine_starting_num = 0 //number of players not in something special
	var/pred_current_num 	= 0 //How many are there now?
	var/pred_maximum_num 	= 4 //How many are possible per round? Does not count elders.
	var/pred_round_chance 	= 0 //%

	//Some gameplay variables.
	var/round_checkwin 		= 0
	var/round_finished
	var/round_started  		= 5 //This is a simple timer so we don't accidently check win conditions right in post-game
	var/round_time_lobby 		//Base time for the lobby, for fog dispersal.
	var/round_time_fog 			//Variance time for fog dispersal, done during pre-setup.
	var/latejoin_tally		= 0 //How many people latejoined Marines
	var/latejoin_larva_drop = LATEJOIN_LARVA_DISABLED //A larva will spawn in once the latejoin marine tally reaches this level. If set to 0, no latejoin larva drop

	var/stored_larva = 0

	//Bioscan related.
	var/bioscan_current_interval = 45 MINUTES
	var/bioscan_ongoing_interval = 20 MINUTES

	var/flags_round_type = NOFLAGS
	var/flags_landmarks = NOFLAGS

//===================================================\\

				//GAME MODE INITIATLIZE\\

//===================================================\\

datum/game_mode/proc/initialize_special_clamps()
	var/ready_players = ready_players() // Get all players that have "Ready" selected
	xeno_starting_num = max((round(ready_players / CONFIG_GET(number/xeno_coefficient))), xeno_required_num)
	surv_starting_num = CLAMP((round(ready_players / CONFIG_GET(number/survivor_coefficient))), 0, 8)
	merc_starting_num = max((round(ready_players / MERC_STARTING_COEF)), 1)
	marine_starting_num = ready_players - xeno_starting_num - surv_starting_num - merc_starting_num
	for(var/datum/squad/sq in SSjob.squads)
		if(sq)
			sq.max_engineers = engi_slot_formula(marine_starting_num)
			sq.max_medics = medic_slot_formula(marine_starting_num)

//===================================================\\

			//XENOMORPH INITIATLIZE\\

//===================================================\\

//If we are selecting xenomorphs, we NEED them to play the round. This is the expected behavior.
//If this is an optional behavior, just override this proc or make an override here.
/datum/game_mode/proc/initialize_starting_xenomorph_list()
	var/list/datum/mind/possible_xenomorphs = get_players_for_role(BE_ALIEN)
	if(possible_xenomorphs.len < xeno_required_num) //We don't have enough aliens.
		return FALSE

	//Minds are not transferred at this point, so we have to clean out those who may be already picked to play.
	for(var/datum/mind/A in possible_xenomorphs)
		if(A.assigned_role)
			possible_xenomorphs -= A

	var/i = xeno_starting_num
	var/datum/mind/new_xeno
	var/turf/larvae_spawn
	while(i > 0) //While we can still pick someone for the role.
		if(length(possible_xenomorphs)) //We still have candidates
			new_xeno = pick(possible_xenomorphs)
			if(!new_xeno)
				break  //Looks like we didn't get anyone. Back out.
			new_xeno.assigned_role = "Xenomorph"
			xenomorphs += new_xeno
			possible_xenomorphs -= new_xeno
		else //Out of candidates, spawn in empty larvas directly
			larvae_spawn = pick(GLOB.xeno_spawn)
			new /mob/living/carbon/Xenomorph/Larva(larvae_spawn)
		i--

	/*
	Our list is empty. This can happen if we had someone ready as alien and predator, and predators are picked first.
	So they may have been removed from the list, oh well.
	*/
	if(xenomorphs.len < xeno_required_num)
		return FALSE

	return TRUE

/datum/game_mode/proc/initialize_starting_queen_list()
	var/list/datum/mind/possible_queens = get_players_for_role(BE_QUEEN)

	//Minds are not transferred at this point, so we have to clean out those who may be already picked to play.
	for(var/datum/mind/A in possible_queens)
		if(A.assigned_role)
			possible_queens -= A

	if(!length(possible_queens))
		return FALSE

	for(var/datum/mind/new_queen in possible_queens)
		if(jobban_isbanned(new_queen.current, ROLE_XENO_QUEEN) || is_banned_from(new_queen.current?.ckey, ROLE_XENO_QUEEN))
			continue
		new_queen.assigned_role = "Queen"
		queen = new_queen
		queens.Add(new_queen) //You're now on the queen list
		break

	if(!queen)
		return FALSE
	else
		return TRUE

/datum/game_mode/proc/initialize_post_xenomorph_list()
	for(var/datum/mind/new_xeno in xenomorphs) //Build and move the xenos.
		if(new_xeno == queen)
			continue
		else
			transform_xeno(new_xeno)

datum/game_mode/proc/initialize_post_queen_list()
	if(!queen)
		return FALSE
	transform_queen(queen)

/datum/game_mode/proc/check_xeno_late_join(mob/xeno_candidate)
	if(jobban_isbanned(xeno_candidate, ROLE_XENOMORPH) || is_banned_from(xeno_candidate.ckey, ROLE_XENOMORPH)) // User is jobbanned
		to_chat(xeno_candidate, "<span class='warning'>You are banned from playing aliens and cannot spawn as a xenomorph.</span>")
		return FALSE
	return TRUE

/datum/game_mode/proc/attempt_to_join_as_larva(mob/xeno_candidate)
	if(!SSticker.mode.stored_larva)
		to_chat(xeno_candidate, "<span class='warning'>There are no burrowed larvas.</span>")
		return FALSE
	var/available_queens[] = list()
	for(var/mob/A in GLOB.alive_xeno_list)
		if(!isxenoqueen(A) || is_centcom_level(A.z))
			continue
		var/mob/living/carbon/Xenomorph/Queen/Q = A
		if(Q.ovipositor && !Q.is_mob_incapacitated(TRUE))
			available_queens += Q
	if(!available_queens.len)
		to_chat(xeno_candidate, "<span class='warning'>There are no mothers with an ovipositor deployed.</span>")
		return FALSE
	var/mob/living/carbon/Xenomorph/Queen/mother = input("Available Mothers") as null|anything in available_queens
	if (!istype(mother) || !xeno_candidate || !xeno_candidate.client)
		return FALSE
	if(!SSticker.mode.stored_larva)
		to_chat(xeno_candidate, "<span class='warning'>There are no longer burrowed larvas available.</span>")
		return FALSE
	if(!mother.ovipositor || mother.is_mob_incapacitated(TRUE))
		to_chat(xeno_candidate, "<span class='warning'>Mother is not in a state to receive us.</span>")
		return FALSE
	if(!xeno_bypass_timer && !isnewplayer(xeno_candidate))
		var/deathtime = world.time - xeno_candidate.timeofdeath
		var/deathtimeminutes = round(deathtime / 600)
		var/deathtimeseconds = round((deathtime - deathtimeminutes * 600) / 10,1)
		if(deathtime < 3000 && ( !xeno_candidate.client.holder || !check_rights(xeno_candidate, R_ADMIN)))
			to_chat(xeno_candidate, "<span class='warning'>You have been dead for [deathtimeminutes >= 1 ? "[deathtimeminutes] minute\s and " : ""][deathtimeseconds] second\s.</span>")
			to_chat(xeno_candidate, "<span class='warning'>You must wait 5 minutes before rejoining the game!</span>")
			return FALSE
	return mother

/datum/game_mode/proc/spawn_larva(mob/xeno_candidate, var/mob/living/carbon/Xenomorph/Queen/mother)
	if(!xeno_candidate)
		return FALSE
	if(!SSticker.mode.stored_larva || !istype(mother))
		to_chat(xeno_candidate, "<span class='warning'>Something went awry. Can't spawn at the moment.</span>")
		log_admin("[xeno_candidate.key] has failed to join as a larva.")
		return FALSE
	var/mob/living/carbon/Xenomorph/Larva/new_xeno = new /mob/living/carbon/Xenomorph/Larva(mother.loc)
	new_xeno.visible_message("<span class='xenodanger'>A larva suddenly burrows out of the ground!</span>",
	"<span class='xenodanger'>You burrow out of the ground and awaken from your slumber. For the Hive!</span>")
	new_xeno << sound('sound/effects/xeno_newlarva.ogg')
	new_xeno.key = xeno_candidate.key
	if(new_xeno.client)
		new_xeno.client.change_view(world.view)
	to_chat(new_xeno, "<span class='xenoannounce'>You are a xenomorph larva awakened from slumber!</span>")
	new_xeno << sound('sound/effects/xeno_newlarva.ogg')
	SSticker.mode.stored_larva--
	log_admin("[new_xeno.key] has joined as [new_xeno].")

/datum/game_mode/proc/attempt_to_join_as_xeno(mob/xeno_candidate, instant_join = 0)
	var/available_xenos[] = list()
	var/available_xenos_non_ssd[] = list()

	for(var/mob/A in GLOB.alive_xeno_list)
		if(is_centcom_level(A.z))
			continue //xenos on admin z level don't count
		if(isxeno(A) && !A.client)
			if(A.away_timer >= 300) available_xenos_non_ssd += A
			available_xenos += A

	if(!available_xenos.len || (instant_join && !available_xenos_non_ssd.len))
		to_chat(xeno_candidate, "<span class='warning'>There aren't any available living xenomorphs. You can also try getting spawned as a chestburster larva by toggling your Xenomorph candidacy in Preferences -> Toggle SpecialRole Candidacy.</span>")
		// xeno_candidate.client.prefs.be_special |= BE_ALIEN
		return FALSE

	var/mob/living/carbon/Xenomorph/new_xeno
	if(instant_join)
		return pick(available_xenos_non_ssd) //Just picks something at random.

	new_xeno = input("Available Xenomorphs") as null|anything in available_xenos
	if(!istype(new_xeno) || !xeno_candidate?.client)
		return FALSE

	if(!(new_xeno in GLOB.alive_xeno_list) || new_xeno.stat == DEAD)
		to_chat(xeno_candidate, "<span class='warning'>You cannot join if the xenomorph is dead.</span>")
		return FALSE

	if(new_xeno.client)
		to_chat(xeno_candidate, "<span class='warning'>That xenomorph has been occupied.</span>")
		return FALSE

	if(!xeno_bypass_timer)
		var/deathtime = world.time - xeno_candidate.timeofdeath
		if(isnewplayer(xeno_candidate))
			deathtime = 3000 //so new players don't have to wait to latejoin as xeno in the round's first 5 mins.
		var/deathtimeminutes = round(deathtime / 600)
		var/deathtimeseconds = round((deathtime - deathtimeminutes * 600) / 10,1)
		if(deathtime < 3000)
			to_chat(xeno_candidate, "<span class='warning'>You have been dead for [deathtimeminutes >= 1 ? "[deathtimeminutes] minute\s and " : ""][deathtimeseconds] second\s.</span>")
			to_chat(xeno_candidate, "<span class='warning'>You must wait 5 minutes before rejoining the game!</span>")
			return FALSE
		if(new_xeno.away_timer < 300) //We do not want to occupy them if they've only been gone for a little bit.
			to_chat(xeno_candidate, "<span class='warning'>That player hasn't been away long enough. Please wait [300 - new_xeno.away_timer] second\s longer.</span>")
			return FALSE

	if(alert(xeno_candidate, "Everything checks out. Are you sure you want to transfer yourself into [new_xeno]?", "Confirm Transfer", "Yes", "No") == "Yes")
		if(new_xeno.client || !(new_xeno in GLOB.alive_xeno_list) || new_xeno.stat == DEAD || !xeno_candidate) // Do it again, just in case
			to_chat(xeno_candidate, "<span class='warning'>That xenomorph can no longer be controlled. Please try another.</span>")
			return FALSE
		return new_xeno
	else
		return FALSE

/datum/game_mode/proc/transfer_xeno(mob/xeno_candidate, mob/new_xeno)
	new_xeno.ghostize(0) //Make sure they're not getting a free respawn.
	new_xeno.key = xeno_candidate.key
	if(new_xeno.client) new_xeno.client.change_view(world.view)
	message_admins("[key_name(new_xeno)] has joined as [new_xeno].")
	log_admin("[ADMIN_TPMONTY(new_xeno)] has joined as [new_xeno].")
	if(isxeno(new_xeno)) //Dear lord
		var/mob/living/carbon/Xenomorph/X = new_xeno
		if(X.is_ventcrawling) X.add_ventcrawl(X.loc) //If we are in a vent, fetch a fresh vent map
	if(xeno_candidate) xeno_candidate.loc = null

/datum/game_mode/proc/transform_xeno(datum/mind/ghost_mind)
	var/mob/original = ghost_mind.current
	var/mob/living/carbon/Xenomorph/new_xeno

	new_xeno = new /mob/living/carbon/Xenomorph/Larva(pick(GLOB.xeno_spawn))
	ghost_mind.transfer_to(new_xeno) //The mind is fine, since we already labeled them as a xeno. Away they go.
	ghost_mind.name = ghost_mind.current.name

	to_chat(new_xeno, "<B>You are now an alien!</B>")
	to_chat(new_xeno, "<B>Your job is to spread the hive and protect the Queen. If there's no Queen, you can become the Queen yourself by evolving into a drone.</B>")
	to_chat(new_xeno, "Talk in Hivemind using <strong>;</strong> (e.g. ';My life for the queen!')")

	new_xeno.update_icons()

	if(original)
		qdel(original) //Just to be sure.

/datum/game_mode/proc/transform_queen(datum/mind/ghost_mind)
	var/mob/original = ghost_mind.current
	var/mob/living/carbon/Xenomorph/new_queen
	var/datum/hive_status/hive = hive_datum[XENO_HIVE_NORMAL]
	if(hive.living_xeno_queen || !(original.client?.prefs?.be_special & BE_QUEEN) || jobban_isbanned(original, ROLE_XENO_QUEEN) || is_banned_from(original.ckey, ROLE_XENO_QUEEN))
		return FALSE
	new_queen = new /mob/living/carbon/Xenomorph/Queen (pick(GLOB.xeno_spawn))
	ghost_mind.transfer_to(new_queen)
	ghost_mind.name = ghost_mind.current.name
	queens.Add(ghost_mind) //You're now on the queen list

	to_chat(new_queen, "<B>You are now the alien queen!</B>")
	to_chat(new_queen, "<B>Your job is to spread the hive.</B>")
	to_chat(new_queen, "Talk in Hivemind using <strong>;</strong> (e.g. ';My life for the hive!')")

	new_queen.update_icons()

	if(original)
		qdel(original) //Just to be sure.

//===================================================\\

			//SURVIVOR INITIATLIZE\\

//===================================================\\

//We don't actually need survivors to play, so long as aliens are present.
/datum/game_mode/proc/initialize_starting_survivor_list()
	var/list/datum/mind/possible_survivors = get_players_for_role(BE_SURVIVOR)
	if(possible_survivors.len) //We have some, it looks like.
		for(var/datum/mind/A in possible_survivors) //Strip out any xenos first so we don't double-dip.
			if(A.assigned_role)
				possible_survivors -= A

		if(possible_survivors.len) //We may have stripped out all the contendors, so check again.
			var/i = surv_starting_num
			var/datum/mind/new_survivor
			while(i > 0)
				if(!length(possible_survivors))
					break  //Ran out of candidates! Can't have a null pick(), so just stick with what we have.
				new_survivor = pick(possible_survivors)
				if(!new_survivor)
					break  //We ran out of survivors!
				new_survivor.assigned_role = "Survivor"
				survivors += new_survivor
				possible_survivors -= new_survivor
				i--

/datum/game_mode/proc/initialize_post_survivor_list()
	for(var/datum/mind/survivor in survivors)
		transform_survivor(survivor)
	tell_survivor_story()

//Start the Survivor players. This must go post-setup so we already have a body.
//No need to transfer their mind as they begin as a human.
/datum/game_mode/proc/transform_survivor(var/datum/mind/ghost)
	var/mob/living/carbon/human/H = ghost.current

	H.loc = pick(GLOB.surv_spawn)

	var/survivor_job = pick(subtypesof(/datum/job/survivor))
	var/datum/job/J = new survivor_job
	J.equip(H)

	if(SSmapping.config.map_name == MAP_ICE_COLONY)
		H.equip_to_slot_or_del(new /obj/item/clothing/head/ushanka(H), SLOT_HEAD)
		H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/snow_suit(H), SLOT_WEAR_SUIT)
		H.equip_to_slot_or_del(new /obj/item/clothing/mask/rebreather(H), SLOT_WEAR_MASK)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/snow(H), SLOT_SHOES)
		H.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(H), SLOT_GLOVES)

	H.name = H.get_visible_name()

	var/weapons = pick(SURVIVOR_WEAPONS)
	var/obj/item/weapon/W = weapons[1]
	var/obj/item/ammo_magazine/A = weapons[2]
	H.equip_to_slot_or_del(new /obj/item/storage/belt/gun/m44/full(H), SLOT_BELT)
	H.put_in_hands(new W(H))
	H.equip_to_slot_or_del(new A(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new A(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new A(H), SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/welding(H),SLOT_GLASSES)

	H.equip_to_slot_or_del(new /obj/item/storage/pouch/tools/full(H), SLOT_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/survival/full(H), SLOT_L_STORE)

	to_chat(H, "<h2>You are a survivor!</h2>")
	switch(SSmapping.config.map_name)
		if(MAP_PRISON_STATION)
			to_chat(H, "<span class='notice'>You are a survivor of the attack on Fiorina Orbital Penitentiary. You worked or lived on the prison station, and managed to avoid the alien attacks.. until now.</span>")
		if(MAP_ICE_COLONY)
			to_chat(H, "<span class='notice'>You are a survivor of the attack on the ice habitat. You worked or lived on the colony, and managed to avoid the alien attacks.. until now.</span>")
		if(MAP_BIG_RED)
			to_chat(H, "<span class='notice'>You are a survivor of the attack on the colony. You worked or lived in the archaeology colony, and managed to avoid the alien attacks...until now.</span>")
		if(MAP_LV_624)
			to_chat(H, "<span class='notice'>You are a survivor of the attack on the colony. You suspected something was wrong and tried to warn others, but it was too late...</span>")
		else
			to_chat(H, "<span class='notice'>Through a miracle you managed to survive the attack. But are you truly safe now?</span>")
	to_chat(H, "<span class='notice'> You are fully aware of the xenomorph threat and are able to use this knowledge as you see fit.</span>")

/datum/game_mode/proc/tell_survivor_story()
	var/list/survivor_story = list(
								"You watched as a larva burst from the chest of your friend, {name}. You tried to capture the alien thing, but it escaped through the ventilation.",
								"{name} was attacked by a facehugging alien, which impregnated them with an alien lifeform. {name}'s chest exploded in gore as some creature escaped.",
								"You watched in horror as {name} got the alien lifeform's acid on their skin, melting away their flesh. You can still hear the screaming and panic.",
								"The Colony Marshal, {name}, made an announcement that the hostile lifeforms killed many, and that everyone should hide or stay behind closed doors.",
								"You were there when the alien lifeforms broke into the mess hall and dragged away the others. It was a terrible sight, and you have tried avoid large open areas since.",
								"It was horrible, as you watched your friend, {name}, get mauled by the horrible monsters. Their screams of agony hunt you in your dreams, leading to insomnia.",
								"You tried your best to hide, and you have seen the creatures travel through the underground tunnels and ventilation shafts. They seem to like the dark.",
								"When you woke up, it felt like you've slept for years. You don't recall much about your old life, except maybe your name. Just what the hell happened to you?",
								"You were on the front lines, trying to fight the aliens. You have seen them hatch more monsters from other humans, and you know better than to fight against death.",
								"You found something, something incredible. But your discovery was cut short when the monsters appeared and began taking people. Damn the beasts!",
								"{name} protected you when the aliens came. You don't know what happened to them, but that was some time ago, and you haven't seen them since. Maybe they are alive."
								)
	var/list/survivor_multi_story = list(
										"You were separated from your friend, {surv}. You hope they're still alive.",
										"You were having some drinks at the bar with {surv} and {name} when an alien crawled out of the vent and dragged {name} away. You and {surv} split up to find help.",
										"Something spooked you when you were out with {surv} scavenging. You took off in the opposite direction from them, and you haven't seen them since.",
										"When {name} became infected, you and {surv} argued over what to do with the afflicted. You nearly came to blows before walking away, leaving them behind.",
										"You ran into {surv} when out looking for supplies. After a tense stand off, you agreed to stay out of each other's way. They didn't seem so bad.",
										"A lunatic by the name of {name} was preaching doomsday to anyone who would listen. {surv} was there too, and you two shared a laugh before the creatures arrived.",
										"Your last decent memory before everything went to hell is of {surv}. They were generally a good person to have around, and they helped you through tough times.",
										"When {name} called for evacuation, {surv} came with you. The aliens appeared soon after and everyone scattered. You hope your friend {surv} is alright.",
										"You remember an explosion. Then everything went dark. You can only recall {name} and {surv}, who were there. Maybe they know what really happened?",
										"The aliens took your mutual friend, {name}. {surv} helped with the rescue. When you got to the alien hive, your friend was dead. You took different passages out.",
										"You were playing basketball with {surv} when the creatures descended. You bolted in opposite directions, and actually managed to lose the monsters, somehow."
										)

	var/current_survivors[] = survivors.Copy() //These are the current survivors, so we can remove them once we tell a story.
	var/story //The actual story they will get to read.
	var/random_name
	var/datum/mind/survivor
	while(current_survivors.len)
		survivor = pick(current_survivors)
		if(!istype(survivor))
			current_survivors -= survivor
			continue //Not a mind? How did this happen?

		var/mob/living/carbon/human/current = survivor.current
		var/datum/species/species = istype(current) ? current.species : GLOB.all_species[DEFAULT_SPECIES]
		random_name = species.random_name(pick(MALE, FEMALE))

		if(current_survivors.len > 1) //If we have another survivor to pick from.
			if(survivor_multi_story.len) //Unlikely.
				var/datum/mind/another_survivor = pick(current_survivors - survivor) // We don't want them to be picked twice.
				current_survivors -= another_survivor
				if(!istype(another_survivor)) continue//If somehow this thing screwed up, we're going to run another pass.
				story = pick(survivor_multi_story)
				survivor_multi_story -= story
				story = replacetext(story, "{name}", "[random_name]")
				spawn(6)
					var/temp_story = "<b>Your story thus far</b>: " + replacetext(story, "{surv}", "[another_survivor.current.real_name]")
					to_chat(survivor.current, temp_story)
					survivor.memory += temp_story //Add it to their memories.
					temp_story = "<b>Your story thus far</b>: " + replacetext(story, "{surv}", "[survivor.current.real_name]")
					to_chat(another_survivor.current, temp_story)
					another_survivor.memory += temp_story
		else
			if(survivor_story.len) //Shouldn't happen, but technically possible.
				story = pick(survivor_story)
				survivor_story -= story
				spawn(6)
					var/temp_story = "<b>Your story thus far</b>: " + replacetext(story, "{name}", "[random_name]")
					to_chat(survivor.current, temp_story)
					survivor.memory += temp_story
		current_survivors -= survivor
	return TRUE

//===================================================\\

			//MARINE GEAR INITIATLIZE\\

//===================================================\\

//We do NOT want to initilialize the gear before everyone is properly spawned in
/datum/game_mode/proc/initialize_post_marine_gear_list()

	//We take the number of marine players, deduced from other lists, and then get a scale multiplier from it, to be used in arbitrary manners to distribute equipment
	//This might count players who ready up but get kicked back to the lobby
	var/marine_pop_size = 0

	for(var/i in GLOB.alive_human_list)
		var/mob/living/carbon/human/H = i
		if(ismarine(H))
			marine_pop_size++

	var/scale = max(marine_pop_size / MARINE_GEAR_SCALING_NORMAL, 1) //This gives a decimal value representing a scaling multiplier. Cannot go below 1

	//Set up attachment vendor contents related to Marine count
	for(var/X in GLOB.attachment_vendors)
		var/obj/machinery/vending/attachments/A = X

		//Forcefully reset the product list
		A.product_records = list()

		A.products = list(
					/obj/item/attachable/suppressor = round(scale * 14),
					/obj/item/attachable/bayonet = round(scale * 14),
					/obj/item/attachable/compensator = round(scale * 10),
					/obj/item/attachable/extended_barrel = round(scale * 10),
					/obj/item/attachable/heavy_barrel = round(scale * 4),

					/obj/item/attachable/scope = round(scale * 4),
					/obj/item/attachable/scope/mini = round(scale * 4),
					/obj/item/attachable/flashlight = round(scale * 14),
					/obj/item/attachable/reddot = round(scale * 14),
					/obj/item/attachable/magnetic_harness = round(scale * 10),
					/obj/item/attachable/quickfire = round(scale * 3),

					/obj/item/attachable/verticalgrip = round(scale * 14),
					/obj/item/attachable/angledgrip = round(scale * 14),
					/obj/item/attachable/lasersight = round(scale * 14),
					/obj/item/attachable/gyro = round(scale * 4),
					/obj/item/attachable/bipod = round(scale * 8),
					/obj/item/attachable/burstfire_assembly = round(scale * 4),

					/obj/item/attachable/stock/shotgun = round(scale * 4),
					/obj/item/attachable/stock/rifle = round(scale * 4) ,
					/obj/item/attachable/stock/revolver = round(scale * 4),
					/obj/item/attachable/stock/smg = round(scale * 4) ,
					/obj/item/attachable/stock/tactical = round(scale * 3),

					/obj/item/attachable/attached_gun/grenade = round(scale * 10),
					/obj/item/attachable/attached_gun/shotgun = round(scale * 4),
					/obj/item/attachable/attached_gun/flamer = round(scale * 4)
					)

		//Rebuild the vendor's inventory to make our changes apply
		A.build_inventory(A.products)

	for(var/X in GLOB.cargo_ammo_vendors)
		var/obj/machinery/vending/marine/cargo_ammo/CA = X

		//Forcefully reset the product list
		CA.product_records = list()

		CA.products = list(
						/obj/item/storage/large_holster/machete/full = round(scale * 10),
						/obj/item/ammo_magazine/pistol = round(scale * 20),
						/obj/item/ammobox/m4a3 = round(scale * 3),
						/obj/item/ammo_magazine/pistol/ap = round(scale * 5),
						/obj/item/ammobox/m4a3ap = round(scale * 3),
						/obj/item/ammo_magazine/pistol/incendiary = round(scale * 2),
						/obj/item/ammo_magazine/pistol/extended = round(scale * 10),
						/obj/item/ammobox/m4a3ext = round(scale * 3),
						/obj/item/ammo_magazine/pistol/m1911 = round(scale * 10),
						/obj/item/ammo_magazine/revolver = round(scale * 20),
						/obj/item/ammo_magazine/revolver/marksman = round(scale * 5),
						/obj/item/ammobox/m39 = round(scale * 3),
						/obj/item/ammo_magazine/smg/m39 = round(scale * 15),
						/obj/item/ammobox/m39ap = round(scale * 1),
						/obj/item/ammo_magazine/smg/m39/ap = round(scale * 5),
						/obj/item/ammobox/m39ext = round(scale * 1),
						/obj/item/ammo_magazine/smg/m39/extended = round(scale * 5),
						/obj/item/ammobox = round(scale * 3),
						/obj/item/ammo_magazine/rifle = round(scale * 15),
						/obj/item/ammobox/ext = round(scale * 1),
						/obj/item/ammo_magazine/rifle/extended = round(scale * 5),
						/obj/item/ammobox/ap = round (scale * 1),
						/obj/item/ammo_magazine/rifle/ap = round(scale * 5),
						/obj/item/ammo_magazine/shotgunbox = round(scale * 3),
						/obj/item/ammo_magazine/shotgun = round(scale * 10),
						/obj/item/ammo_magazine/shotgunbox/buckshot = round(scale * 3),
						/obj/item/ammo_magazine/shotgun/buckshot = round(scale * 10),
						/obj/item/ammo_magazine/shotgunbox/flechette = round(scale * 3),
						/obj/item/ammo_magazine/shotgun/flechette = round(scale * 15),
						/obj/item/cell/lasgun/M43 = round(scale * 30),
						/obj/item/cell/lasgun/M43/highcap = round(scale * 5),
						/obj/item/smartgun_powerpack = round(scale * 2)
						)

		CA.contraband = list(
						/obj/item/ammo_magazine/smg/ppsh/ = round(scale * 20),
						/obj/item/ammo_magazine/smg/ppsh/extended = round(scale * 4),
						/obj/item/ammo_magazine/rifle/bolt = round(scale * 10),
						/obj/item/ammo_magazine/sniper = 0,
						/obj/item/ammo_magazine/sniper/incendiary = 0,
						/obj/item/ammo_magazine/sniper/flak = 0,
						/obj/item/ammo_magazine/rifle/m4ra = 0,
						/obj/item/ammo_magazine/rifle/incendiary = 0,
						/obj/item/ammo_magazine/rifle/m41aMK1 = 0,
						/obj/item/ammo_magazine/rifle/lmg = 0,
						/obj/item/ammo_magazine/pistol/hp = 0,
						/obj/item/ammo_magazine/pistol/heavy = 0,
						/obj/item/ammo_magazine/pistol/holdout = 0,
						/obj/item/ammo_magazine/pistol/highpower = 0,
						/obj/item/ammo_magazine/pistol/vp70 = 0,
						/obj/item/ammo_magazine/revolver/small = 0,
						/obj/item/ammo_magazine/revolver/cmb = 0,
						/obj/item/ammo_magazine/smg/mp7 = 0,
						/obj/item/ammo_magazine/smg/skorpion = 0,
						/obj/item/ammo_magazine/smg/uzi = 0,
						/obj/item/ammo_magazine/smg/p90 = 0
						)

		CA.build_inventory(CA.products)


	for(var/X in GLOB.cargo_guns_vendors)
		var/obj/machinery/vending/marine/cargo_guns/CG = X

		//Forcefully reset the product list
		CG.product_records = list()

		CG.products = list(
						/obj/item/storage/backpack/marine/standard = round(scale * 15),
						/obj/item/storage/belt/marine = round(scale * 15),
						/obj/item/storage/belt/shotgun = round(scale * 10),
						/obj/item/clothing/tie/storage/webbing = round(scale * 3),
						/obj/item/clothing/tie/storage/brown_vest = round(scale * 1),
						/obj/item/clothing/tie/holster = round(scale * 1),
						/obj/item/storage/belt/gun/m4a3 = round(scale * 10),
						/obj/item/storage/belt/gun/m44 = round(scale * 5),
						/obj/item/storage/large_holster/m39 = round(scale * 5),
						/obj/item/storage/pouch/general/medium = round(scale * 2),
						/obj/item/storage/pouch/construction = round(scale * 2),
						/obj/item/storage/pouch/tools = round(scale * 2),
						/obj/item/storage/pouch/explosive = round(scale * 2),
						/obj/item/storage/pouch/syringe = round(scale * 2),
						/obj/item/storage/pouch/medical = round(scale * 2),
						/obj/item/storage/pouch/medkit = round(scale * 2),
						/obj/item/storage/pouch/magazine = round(scale * 5),
						/obj/item/storage/pouch/flare/full = round(scale * 5),
						/obj/item/storage/pouch/firstaid/full = round(scale * 5),
						/obj/item/storage/pouch/pistol = round(scale * 10),
						/obj/item/storage/pouch/magazine/pistol/large = round(scale * 5),
						/obj/item/storage/pouch/shotgun = round(scale * 10),
						/obj/item/weapon/gun/pistol/m4a3 = round(scale * 20),
						/obj/item/weapon/gun/pistol/m1911 = round(scale * 2),
						/obj/item/weapon/gun/revolver/m44 = round(scale * 10),
						/obj/item/weapon/gun/smg/m39 = round(scale * 15),
						/obj/item/weapon/gun/rifle/m41a = round(scale * 20),
						/obj/item/weapon/gun/shotgun/pump = round(scale * 10),
						// /obj/item/weapon/gun/shotgun/combat = round(scale * 1),
						/obj/item/weapon/gun/energy/lasgun/M43 = round(scale * 10),
						/obj/item/explosive/mine = round(scale * 2),
						/obj/item/storage/box/nade_box = round(scale * 2),
						/obj/item/explosive/grenade/frag/m15 = round(scale * 2),
						/obj/item/explosive/grenade/incendiary = round(scale * 4),
						/obj/item/explosive/grenade/smokebomb = round(scale * 5),
						/obj/item/explosive/grenade/cloakbomb = round(scale * 3),
						/obj/item/storage/box/m94 = round(scale * 30),
						/obj/item/device/flashlight/combat = round(scale * 5),
						/obj/item/clothing/mask/gas = round(scale * 10)
						)

		CG.contraband = list(
						/obj/item/weapon/gun/smg/ppsh = round(scale * 4),
						/obj/item/weapon/gun/shotgun/double = round(scale * 2),
						/obj/item/weapon/gun/shotgun/pump/bolt = round(scale * 2),
						/obj/item/weapon/gun/smg/m39/elite = 0,
						/obj/item/weapon/gun/rifle/m41aMK1 = 0,
						/obj/item/weapon/gun/rifle/m41a/elite = 0,
						/obj/item/weapon/gun/rifle/lmg = 0,
						/obj/item/explosive/grenade/frag = 0,
						/obj/item/explosive/grenade/phosphorus = 0,
						/obj/item/weapon/gun/pistol/holdout = 0,
						/obj/item/weapon/gun/pistol/heavy = 0,
						/obj/item/weapon/gun/pistol/highpower = 0,
						/obj/item/weapon/gun/pistol/vp70 = 0,
						/obj/item/weapon/gun/revolver/small = 0,
						/obj/item/weapon/gun/revolver/cmb = 0,
						/obj/item/weapon/gun/shotgun/merc = 0,
						/obj/item/weapon/gun/shotgun/pump/cmb = 0,
						/obj/item/weapon/gun/smg/mp7 = 0,
						/obj/item/weapon/gun/smg/skorpion = 0,
						/obj/item/weapon/gun/smg/uzi = 0,
						/obj/item/weapon/gun/smg/p90 = 0
						)

		CG.build_inventory(CG.products)



	for(var/obj/machinery/vending/marine/M in GLOB.marine_vendors)

		//Forcefully reset the product list
		M.product_records = list()

		M.products = list(
						/obj/item/weapon/gun/pistol/m4a3 = round(scale * 30),
						/obj/item/weapon/gun/revolver/m44 = round(scale * 25),
						/obj/item/weapon/gun/smg/m39 = round(scale * 30),
						/obj/item/weapon/gun/rifle/m41a = round(scale * 30),
						/obj/item/weapon/gun/shotgun/pump = round(scale * 15),
						/obj/item/weapon/gun/energy/lasgun/M43 = round(scale * 15),

						/obj/item/ammo_magazine/pistol = round(scale * 30),
						/obj/item/ammo_magazine/revolver = round(scale * 20),
						/obj/item/ammo_magazine/smg/m39 = round(scale * 30),
						/obj/item/ammo_magazine/rifle = round(scale * 25),
						/obj/item/ammo_magazine/rifle/ap = 0,
						/obj/item/ammo_magazine/shotgun = round(scale * 10),
						/obj/item/ammo_magazine/shotgun/buckshot = round(scale * 10),
						/obj/item/ammo_magazine/shotgun/flechette = round(scale * 10),
						/obj/item/cell/lasgun/M43 = round(scale * 25),
						/obj/item/cell/lasgun/M43/highcap = 0,

						/obj/item/weapon/combat_knife = round(scale * 30),
						/obj/item/weapon/throwing_knife = round(scale * 10),
						/obj/item/storage/box/m94 = round(scale * 10),

						/obj/item/attachable/flashlight = round(scale * 25),
						/obj/item/attachable/bayonet = round(scale * 25),

						)

		M.contraband =   list(/obj/item/ammo_magazine/revolver/marksman = round(scale * 2),
							/obj/item/ammo_magazine/pistol/ap = round(scale * 2),
							/obj/item/ammo_magazine/smg/m39/ap = round(scale * 2)
							)

		M.premium = list(/obj/item/weapon/gun/rifle/m41aMK1 = 0,
						)

		//Rebuild the vendor's inventory to make our changes apply
		M.build_inventory(M.products)
		M.build_inventory(M.contraband, 1)
		M.build_inventory(M.premium, 0, 1)

		var/products2[]
		//if(istype(src, /datum/game_mode/ice_colony)) //Literally, we are in gamemode code
		if(SSmapping.config.map_name == MAP_ICE_COLONY)
			products2 = list(
						/obj/item/clothing/mask/rebreather/scarf = round(scale * 30),
						/obj/item/clothing/mask/rebreather = round(scale * 30),
							)
		M.build_inventory(products2)

	//Scale the amount of cargo points through a direct multiplier
	supply_controller.points = round(supply_controller.points * scale)

// generic landmark setup

#define MAX_TUNNELS_PER_MAP 3

/datum/game_mode/proc/setup_xeno_tunnels()
	var/obj/structure/tunnel/T
	var/i = 0
	var/turf/t
	while(GLOB.xeno_tunnel_landmarks.len && i++ < MAX_TUNNELS_PER_MAP)
		t = pick(GLOB.xeno_tunnel_landmarks)
		GLOB.xeno_tunnel_landmarks -= t
		T = new(t)
		T.id = "hole[i]"
		for(var/x in GLOB.xeno_tunnels)
			var/obj/structure/tunnel/TO = x
			if(TO.id != T.id || T == TO || !TO.other)
				continue
			TO.other = T
			T.other = TO

/datum/game_mode/proc/spawn_map_items()
	var/turf/T
	switch(SSmapping.config.map_name) // doing the switch first makes this a tiny bit quicker which for round setup is more important than pretty code
		if(MAP_LV_624)
			while(GLOB.map_items.len)
				T = GLOB.map_items[GLOB.map_items.len]
				GLOB.map_items.len--
				new /obj/item/map/lazarus_landing_map(T)

		if(MAP_ICE_COLONY)
			while(GLOB.map_items.len)
				T = GLOB.map_items[GLOB.map_items.len]
				GLOB.map_items.len--
				new /obj/item/map/ice_colony_map(T)

		if(MAP_BIG_RED)
			while(GLOB.map_items.len)
				T = GLOB.map_items[GLOB.map_items.len]
				GLOB.map_items.len--
				new /obj/item/map/big_red_map(T)

		if(MAP_PRISON_STATION)
			while(GLOB.map_items.len)
				T = GLOB.map_items[GLOB.map_items.len]
				GLOB.map_items.len--
				new /obj/item/map/FOP_map(T)

/datum/game_mode/proc/spawn_fog_blockers()
	var/turf/T
	while(GLOB.fog_blocker_locations.len)
		T = GLOB.fog_blocker_locations[GLOB.fog_blocker_locations.len]
		GLOB.fog_blocker_locations.len--
		new /obj/effect/forcefield/fog(T)

/obj/effect/forcefield
	anchored = TRUE
	opacity = FALSE
	density = TRUE

/obj/effect/forcefield/fog
	name = "dense fog"
	desc = "It looks way too dangerous to traverse. Best wait until it has cleared up."
	icon = 'icons/effects/effects.dmi'
	icon_state = "smoke"
	opacity = TRUE

/obj/effect/forcefield/fog/Initialize()
	. = ..()
	dir  = pick(CARDINAL_DIRS)
	GLOB.fog_blockers += src

/obj/effect/forcefield/fog/Destroy()
	GLOB.fog_blockers -= src
	return ..()

/obj/effect/forcefield/fog/attack_hand(mob/M)
	to_chat(M, "<span class='notice'>You peer through the fog, but it's impossible to tell what's on the other side...</span>")

/obj/effect/forcefield/fog/attack_alien(M)
	return attack_hand(M)

/obj/effect/forcefield/fog/attack_paw(M)
	return attack_hand(M)

/obj/effect/forcefield/fog/attack_animal(M)
	return attack_hand(M)
