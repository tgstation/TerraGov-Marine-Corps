/*
This is a collection of procs related to CM and spawning aliens/predators/survivors. With this centralized system,
you can spawn them at round start in any game mode. You can also add additional categories, and they will be supported
at round start with no conflict. Individual game modes may override these settings to have their own unique
spawns for the various factions. It's also a bit more robust with some added parameters. For example, if xeno_required_num
is 0, you don't need aliens at the start of the game. If aliens are required for win conditions, tick it to 1 or more.

This is a basic outline of how things should function in code.
You can see a working example in the Colonial Marines game mode.

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

/datum/game_mode
	var/datum/mind/xenomorphs[] = list() //These are our basic lists to keep track of who is in the game.
	var/datum/mind/survivors[] = list()
	var/datum/mind/predators[] = list()
	var/datum/mind/hellhounds[] = list() //Hellhound spawning is not supported at round start.
	var/pred_keys[] = list() //People who are playing predators, we can later reference who was a predator during the round.

	var/xeno_required_num 	= 0 //We need at least one. You can turn this off in case we don't care if we spawn or don't spawn xenos.
	var/xeno_starting_num 	= 0 //To clamp starting xenos.
	var/xeno_bypass_timer 	= 0 //Bypass the five minute timer before respawning.
	var/xeno_queen_timer  	= 0 //How long ago did the queen die?
	var/xeno_queen_deaths 	= 0 //How many times the alien queen died.
	var/surv_starting_num 	= 0 //To clamp starting survivors.
	var/merc_starting_num 	= 0 //PMC clamp.
	var/pred_current_num 	= 0 //How many are there now?
	var/pred_maximum_num 	= 3 //How many are possible per round? Does not count elders.
	var/pred_round_chance 	= 20 //%

	//Some gameplay variables.
	var/round_checkwin 		= 0
	var/round_finished
	var/round_started  		= 5 //This is a simple timer so we don't accidently check win conditions right in post-game
	var/round_fog[]				//List of the fog locations.
	var/round_time_lobby 		//Base time for the lobby, for fog dispersal.
	var/round_time_fog 			//Variance time for fog dispersal, done during pre-setup.
	var/monkey_amount		= 0 //How many monkeys do we spawn on this map ?
	var/list/monkey_types	= list() //What type of monkeys do we spawn

	//Role Authority set up.
	var/role_instruction 	= 0 // 1 is to replace, 2 is to add, 3 is to remove.
	var/roles_for_mode[] //Won't have a list if the instruction is set to 0.

	//Bioscan related.
	var/bioscan_current_interval = 36000
	var/bioscan_ongoing_interval = 18000

	var/flags_round_type = NOFLAGS

//===================================================\\

				//GAME MODE INITIATLIZE\\

//===================================================\\

datum/game_mode/proc/initialize_special_clamps()
	var/ready_players = num_players() // Get all players that have "Ready" selected
	xeno_starting_num = Clamp((ready_players/5), xeno_required_num, INFINITY) //(n, minimum, maximum)
	surv_starting_num = Clamp((ready_players/7), 0, 3)
	merc_starting_num = Clamp((ready_players/3), 1, INFINITY)

//===================================================\\

				//PREDATOR INITIATLIZE\\

//===================================================\\

#define DEBUG_PREDATOR_INITIALIZE 0

#if DEBUG_PREDATOR_INITIALIZE
/mob/verb/adjust_predator_round()
	set name = "Adjust Predator Round"
	set category = "Debug"
	set desc = "Adjust the number of predators present in a predator round."

	if(!ticker || !ticker.mode)
		src << "<span class='warning'>The game hasn't started yet!</span?"
		return

	ticker.mode.pred_maximum_num = input(src,"What is the new maximum number of predators?","Input:",3) as num|null
	ticker.mode.pred_current_num = input(src,"What is the new current number of predators?","Input:",0) as num|null
#endif

/datum/game_mode/proc/initialize_predator(mob/living/carbon/human/new_predator)
	predators += new_predator.mind //Add them to the proper list.
	pred_keys += new_predator.ckey //Add their key.
	if(!(RoleAuthority.roles_whitelist[new_predator.ckey] & (WHITELIST_YAUTJA_ELITE|WHITELIST_YAUTJA_ELDER))) pred_current_num++ //If they are not an elder, tick up the max.

/datum/game_mode/proc/initialize_starting_predator_list()
	if(prob(pred_round_chance)) //First we want to determine if it's actually a predator round.
		flags_round_type |= MODE_PREDATOR //It is now a predator round.
		var/L[] = get_whitelisted_predators() //Grabs whitelisted preds who are ready at game start.
		var/datum/mind/M
		var/i //Our iterator for the maximum amount of pred spots available. The actual number is changed later on.
		while(L.len && i < pred_maximum_num)
			M = pick(L)
			if(!istype(M)) continue
			L -= M
			M.assigned_role = "MODE" //So they are not chosen later for another role.
			predators += M
			if(!(RoleAuthority.roles_whitelist[M.current.ckey] & (WHITELIST_YAUTJA_ELITE|WHITELIST_YAUTJA_ELDER))) i++

/datum/game_mode/proc/initialize_post_predator_list() //TO DO: Possibly clean this using tranfer_to.
	var/temp_pred_list[] = predators //We don't want to use the actual predator list as it will be overriden.
	predators = list() //Empty it. The temporary minds we used aren't going to be used much longer.
	for(var/datum/mind/new_pred in temp_pred_list)
		if(!istype(new_pred)) continue
		attempt_to_join_as_predator(new_pred.current)

/datum/game_mode/proc/force_predator_spawn() //Forces the spawn.
	var/possible_predators[] = get_whitelisted_predators(0) //0 = not care about ready state
	var/i = pred_maximum_num
	var/datum/mind/new_pred
	while(i > 0)
		if(!possible_predators.len) break
		new_pred = pick(possible_predators)
		if(!istype(new_pred)) continue
		attempt_to_join_as_predator(new_pred.current) //It may fail, if it does we just keep going.
		possible_predators -= new_pred //Remove from list.
		i--

/datum/game_mode/proc/get_whitelisted_predators(readied = 1)
	// Assemble a list of active players who are whitelisted.
	var/players[] = new

	var/mob/new_player/new_pred
	for(var/mob/player in player_list)
		if(!player.client) continue //No client. DCed.
		if(isYautja(player)) continue //Already a predator. Might be dead, who knows.
		if(readied) //Ready check for new players.
			new_pred = player
			if(!istype(new_pred)) continue //Have to be a new player here.
			if(!new_pred.ready) continue //Have to be ready.
		else
			if(!istype(player,/mob/dead)) continue //Otherwise we just want to grab the ghosts.

		if(RoleAuthority.roles_whitelist[player.ckey] & WHITELIST_PREDATOR)  //Are they whitelisted?
			if(!player.client.prefs)
				player.client.prefs = new /datum/preferences(player.client) //Somehow they don't have one.

			if(player.client.prefs.be_special & BE_PREDATOR) //Are their prefs turned on?
				if(!player.mind) //They have to have a key if they have a client.
					player.mind_initialize() //Will work on ghosts too, but won't add them to active minds.
				players += player.mind
	return players

/datum/game_mode/proc/attempt_to_join_as_predator(mob/pred_candidate)
	var/mob/living/carbon/human/new_predator = transform_predator(pred_candidate) //Initialized and ready.
	if(!new_predator) return

	log_admin("[new_predator.key], became a new Yautja, [new_predator.real_name].")
	message_admins("([new_predator.key]) joined as Yautja, [new_predator.real_name].")

	if(pred_candidate) pred_candidate.loc = null //Nullspace it for garbage collection later.

/datum/game_mode/proc/check_predator_late_join(mob/pred_candidate, show_warning = 1)

	if(!(RoleAuthority.roles_whitelist[pred_candidate.ckey] & WHITELIST_PREDATOR))
		if(show_warning) pred_candidate << "<span class='warning'>You are not whitelisted! You may apply on the forums to be whitelisted as a predator.</span>"
		return

	if(!(flags_round_type & MODE_PREDATOR))
		if(show_warning) pred_candidate << "<span class='warning'>There is no Hunt this round! Maybe the next one.</span>"
		return

	if(pred_candidate.ckey in pred_keys)
		if(show_warning) pred_candidate << "<span class='warning'>You already were a Yautja! Give someone else a chance.</span>"
		return

	if(!(RoleAuthority.roles_whitelist[pred_candidate.ckey] & WHITELIST_YAUTJA_ELDER))
		if(pred_current_num >= pred_maximum_num)
			if(show_warning) pred_candidate << "<span class='warning'>Only [pred_maximum_num] predators may spawn per round, but Elders are excluded.</span>"
			return

	return 1

/datum/game_mode/proc/transform_predator(mob/pred_candidate)
	if(!pred_candidate.client) //Something went wrong.
		message_admins("<span class='warning'><b>Warning</b>: null client in transform_predator.</span>")
		log_debug("Null client in transform_predator.")
		return

	var/mob/living/carbon/human/new_predator

	new_predator = new(RoleAuthority.roles_whitelist[pred_candidate.ckey] & WHITELIST_YAUTJA_ELDER ? pick(pred_elder_spawn) : pick(pred_spawn))
	new_predator.set_species("Yautja")

	new_predator.mind_initialize()
	new_predator.mind.assigned_role = "MODE"
	new_predator.mind.special_role = "Predator"
	new_predator.key = pred_candidate.key
	new_predator.mind.key = new_predator.key
	if(new_predator.client) new_predator.client.view = world.view

	if(!new_predator.client.prefs) new_predator.client.prefs = new /datum/preferences(new_predator.client) //Let's give them one.
	//They should have these set, but it's possible they don't have them.
	new_predator.real_name = new_predator.client.prefs.predator_name
	new_predator.gender = new_predator.client.prefs.predator_gender
	new_predator.age = new_predator.client.prefs.predator_age

	if(!new_predator.real_name || new_predator.real_name == "Undefined") //In case they don't have a name set or no prefs, there's a name.
		new_predator.real_name = "Le'pro"
		spawn(9)
			new_predator << "<span class='warning'>You forgot to set your name in your preferences. Please do so next time.</span>"

	var/armor_number = new_predator.client.prefs.predator_armor_type
	var/boot_number = new_predator.client.prefs.predator_boot_type
	var/mask_number = new_predator.client.prefs.predator_mask_type

	new_predator.equip_to_slot_or_del(new /obj/item/clothing/shoes/yautja(new_predator, boot_number), WEAR_FEET)
	if(RoleAuthority.roles_whitelist[new_predator.ckey] & WHITELIST_YAUTJA_ELDER)
		new_predator.real_name = "Elder [new_predator.real_name]"
		new_predator.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/yautja(new_predator, armor_number, 1), WEAR_JACKET)
		new_predator.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/yautja(new_predator, mask_number, 1), WEAR_FACE)
		new_predator.equip_to_slot_or_del(new /obj/item/clothing/cape/eldercape(new_predator, armor_number), WEAR_BACK)

		spawn(10)
			new_predator << "<span class='notice'><B> Welcome Elder!</B></span>"
			new_predator << "<span class='notice'>You are responsible for the well-being of your pupils. Hunting is secondary in priority.</span>"
			new_predator << "<span class='notice'>That does not mean you can't go out and show the youngsters how it's done.</span>"
			new_predator << "<span class='notice'>You come equipped as an Elder should, with a bonus glaive and heavy armor.</span>"
	else
		new_predator.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/yautja(new_predator, armor_number), WEAR_JACKET)
		new_predator.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/yautja(new_predator, mask_number), WEAR_FACE)

		spawn(12)
			new_predator << "<span class='notice'>You are <B>Yautja</b>, a great and noble predator!</span>"
			new_predator << "<span class='notice'>Your job is to first study your opponents. A hunt cannot commence unless intelligence is gathered.</span>"
			new_predator << "<span class='notice'>Hunt at your discretion, yet be observant rather than violent.</span>"
			new_predator << "<span class='notice'>And above all, listen to your Elders!</span>"

	new_predator.update_icons()
	initialize_predator(new_predator)
	return new_predator

#undef DEBUG_PREDATOR_INITIALIZE

//===================================================\\

			//XENOMORPH INITIATLIZE\\

//===================================================\\

//If we are selecting xenomorphs, we NEED them to play the round. This is the expected behavior.
//If this is an optional behavior, just override this proc or make an override here.
/datum/game_mode/proc/initialize_starting_xenomorph_list()
	var/list/datum/mind/possible_xenomorphs = get_players_for_role(BE_ALIEN)
	if(possible_xenomorphs.len < xeno_required_num) //We don't have enough aliens.
		world << "<h2 style=\"color:red\">Not enough players have chosen to be a xenomorph in their character setup. <b>Aborting</b>.</h2>"
		return

	//Minds are not transferred at this point, so we have to clean out those who may be already picked to play.
	for(var/datum/mind/A in possible_xenomorphs)
		if(A.assigned_role == "MODE")
			possible_xenomorphs -= A

	var/i = xeno_starting_num
	var/datum/mind/new_xeno
	var/turf/larvae_spawn
	while(i > 0) //While we can still pick someone for the role.
		if(possible_xenomorphs.len) //We still have candidates
			new_xeno = pick(possible_xenomorphs)
			if(!new_xeno) break  //Looks like we didn't get anyone. Back out.
			new_xeno.assigned_role = "MODE"
			new_xeno.special_role = "Xenomorph"
			possible_xenomorphs -= new_xeno
			xenomorphs += new_xeno
		else //Out of candidates, spawn in empty larvas directly
			larvae_spawn = xeno_spawn.len ? pick(xeno_spawn) : pick(xeno_spawn_ice_colony) // Hack to fix an ice colony run time. We need to make sure spawn locations are always normalized.
			new /mob/living/carbon/Xenomorph/Larva(larvae_spawn)
		i--

	/*
	Our list is empty. This can happen if we had someone ready as alien and predator, and predators are picked first.
	So they may have been removed from the list, oh well.
	*/
	if(xenomorphs.len < xeno_required_num)
		world << "<h2 style=\"color:red\">Could not find any candidates after initial alien list pass. <b>Aborting</b>.</h2>"
		return

	return 1

/datum/game_mode/proc/initialize_post_xenomorph_list()
	for(var/datum/mind/new_xeno in xenomorphs) //Build and move the xenos.
		transform_xeno(new_xeno)

/datum/game_mode/proc/check_xeno_late_join(mob/xeno_candidate)
	if(jobban_isbanned(xeno_candidate, "Alien")) // User is jobbanned
		xeno_candidate << "<span class='warning'>You are banned from playing aliens and cannot spawn as a xenomorph.</span>"
		return
	return 1

/datum/game_mode/proc/attempt_to_join_as_xeno(mob/xeno_candidate, instant_join = 0)
	var/available_xenos[] = list()
	var/available_xenos_non_ssd[] = list()

	for(var/mob/A in living_mob_list)
		if(isXeno(A) && !A.client)
			if(A.away_timer >= 300) available_xenos_non_ssd += A
			available_xenos += A

	if(!available_xenos.len || (instant_join && !available_xenos_non_ssd.len))
		xeno_candidate << "<span class='warning'>There aren't any available xenomorphs. Check back later!</span>"
		return

	var/mob/living/carbon/Xenomorph/new_xeno
	if(!instant_join)
		new_xeno = input("Available Xenomorphs") as null|anything in available_xenos
		if (!istype(new_xeno) || !xeno_candidate) return //It could be null, it could be "cancel" or whatever that isn't a xenomorph.

		if(!(new_xeno in living_mob_list) || new_xeno.stat == DEAD)
			xeno_candidate << "<span class='warning'>You cannot join if the xenomorph is dead.</span>"
			return

		if(new_xeno.client)
			xeno_candidate << "<span class='warning'>That xenomorph has been occupied.</span>"
			return

		if(!xeno_bypass_timer)
			var/deathtime = world.time - xeno_candidate.timeofdeath
			var/deathtimeminutes = round(deathtime / 600)
			var/deathtimeseconds = round((deathtime - deathtimeminutes * 600) / 10,1)
			if(deathtime < 3000 && ( !xeno_candidate.client.holder || !(xeno_candidate.client.holder.rights & R_ADMIN)) )
				xeno_candidate << "<span class='warning'>You have been dead for [deathtimeminutes >= 1 ? "[deathtimeminutes] minute\s and " : ""][deathtimeseconds] second\s.</span>"
				xeno_candidate << "<span class='warning'>You must wait 5 minutes before rejoining the game!</span>"
				return
			if(new_xeno.away_timer < 300) //We do not want to occupy them if they've only been gone for a little bit.
				xeno_candidate << "<span class='warning'>That player hasn't been away long enough. Please wait [300 - new_xeno.away_timer] second\s longer.</span>"
				return

		if(alert(xeno_candidate, "Everything checks out. Are you sure you want to transfer yourself into [new_xeno]?", "Confirm Transfer", "Yes", "No") == "Yes")
			if(new_xeno.client || !(new_xeno in living_mob_list) || new_xeno.stat == DEAD || !xeno_candidate) // Do it again, just in case
				xeno_candidate << "<span class='warning'>That xenomorph can no longer be controlled. Please try another.</span>"
				return
		else return
	else new_xeno = pick(available_xenos_non_ssd) //Just picks something at random.
	return new_xeno

/datum/game_mode/proc/transfer_xeno(mob/xeno_candidate, mob/new_xeno)
	new_xeno.ghostize(0) //Make sure they're not getting a free respawn.
	new_xeno.key = xeno_candidate.key
	if(new_xeno.client) new_xeno.client.view = world.view
	message_admins("[new_xeno.key] has joined as [new_xeno].")
	log_admin("[new_xeno.key] has joined as [new_xeno].")
	if(xeno_candidate) xeno_candidate.loc = null

/datum/game_mode/proc/transform_xeno(datum/mind/ghost_mind)
	var/mob/original = ghost_mind.current
	var/mob/living/carbon/Xenomorph/new_xeno
	var/is_queen = FALSE
	if(!living_xeno_queen && original && original.client && original.client.prefs && (original.client.prefs.be_special & BE_QUEEN) && !jobban_isbanned(original, "Queen"))
		new_xeno = new /mob/living/carbon/Xenomorph/Queen (pick(xeno_spawn))
		is_queen = TRUE
	else
		new_xeno = new /mob/living/carbon/Xenomorph/Larva(pick(xeno_spawn))
	ghost_mind.transfer_to(new_xeno) //The mind is fine, since we already labeled them as a xeno. Away they go.
	ghost_mind.name = ghost_mind.current.name

	if(is_queen)
		new_xeno << "<B>You are now the alien queen!</B>"
		new_xeno << "<B>Your job is to spread the hive.</B>"
		new_xeno << "Talk in Hivemind using <strong>:a</strong> (e.g. ':aMy life for the queen!')"
	else
		new_xeno << "<B>You are now an alien!</B>"
		new_xeno << "<B>Your job is to spread the hive and protect the Queen. If there's no Queen, you can become the Queen yourself by evolving into a drone.</B>"
		new_xeno << "Talk in Hivemind using <strong>:a</strong> (e.g. ':aMy life for the queen!')"

	new_xeno.update_icons()

	if(original) cdel(original) //Just to be sure.

//===================================================\\

			//SURVIVOR INITIATLIZE\\

//===================================================\\

//We don't actually need survivors to play, so long as aliens are present.
/datum/game_mode/proc/initialize_starting_survivor_list()
	var/list/datum/mind/possible_survivors = get_players_for_role(BE_SURVIVOR)
	if(possible_survivors.len) //We have some, it looks like.
		for(var/datum/mind/A in possible_survivors) //Strip out any xenos first so we don't double-dip.
			if(A.assigned_role == "MODE")
				possible_survivors -= A

		if(possible_survivors.len) //We may have stripped out all the contendors, so check again.
			var/i = surv_starting_num
			var/datum/mind/new_survivor
			while(i > 0)
				if(!possible_survivors.len) break  //Ran out of candidates! Can't have a null pick(), so just stick with what we have.
				new_survivor = pick(possible_survivors)
				if(!new_survivor) break  //We ran out of survivors!
				new_survivor.assigned_role = "MODE"
				new_survivor.special_role = "Survivor"
				possible_survivors -= new_survivor
				survivors += new_survivor
				i--

/datum/game_mode/proc/initialize_post_survivor_list()
	for(var/datum/mind/survivor in survivors)
		transform_survivor(survivor)
	tell_survivor_story()

//Start the Survivor players. This must go post-setup so we already have a body.
//No need to transfer their mind as they begin as a human.
/datum/game_mode/proc/transform_survivor(var/datum/mind/ghost)
	var/mob/living/carbon/human/new_survivor = ghost.current

	new_survivor.loc = pick(surv_spawn)

	//Damage them for realism purposes
	new_survivor.take_organ_damage(rand(0,15), rand(0,15))

	//Give them proper jobs and stuff here later
	var/random_job = rand(0,10)
	switch(random_job)
		if(0) //assistant
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/under/colonist(new_survivor), WEAR_BODY)
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(new_survivor), WEAR_FEET)
			new_survivor.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel/norm(new_survivor), WEAR_BACK)
			ghost.skills_list = list("cqc"=SKILL_CQC_WEAK,"endurance"=0,"engineer"=SKILL_ENGINEER_DEFAULT,"firearms"=SKILL_FIREARMS_UNTRAINED,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_DEFAULT,"leadership"=SKILL_LEAD_DEFAULT,"medical"=SKILL_MEDICAL_DEFAULT,"melee_weapons"=SKILL_MELEE_WEAK,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_UNTRAINED,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)

		if(1) //civilian in pajamas
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/under/pj/red(new_survivor), WEAR_BODY)
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(new_survivor), WEAR_FEET)
			ghost.skills_list = list("cqc"=SKILL_CQC_WEAK,"endurance"=0,"engineer"=SKILL_ENGINEER_DEFAULT,"firearms"=SKILL_FIREARMS_UNTRAINED,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_DEFAULT,"leadership"=SKILL_LEAD_DEFAULT,"medical"=SKILL_MEDICAL_DEFAULT,"melee_weapons"=SKILL_MELEE_WEAK,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_UNTRAINED,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)

		if(2) //Scientist
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/under/colonist(new_survivor), WEAR_BODY)
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat(new_survivor), WEAR_JACKET)
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(new_survivor), WEAR_FEET)
			new_survivor.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel/tox(new_survivor), WEAR_BACK)
			ghost.skills_list = list("cqc"=SKILL_CQC_WEAK,"endurance"=0,"engineer"=SKILL_ENGINEER_DEFAULT,"firearms"=SKILL_FIREARMS_UNTRAINED,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_DEFAULT,"leadership"=SKILL_LEAD_DEFAULT,"medical"=SKILL_MEDICAL_MEDIC,"melee_weapons"=SKILL_MELEE_WEAK,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_UNTRAINED,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)

		if(3) //Doctor
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/under/colonist(new_survivor), WEAR_BODY)
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat(new_survivor), WEAR_JACKET)
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(new_survivor), WEAR_FEET)
			new_survivor.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/medical(new_survivor), WEAR_L_HAND)
			new_survivor.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel/med(new_survivor), WEAR_BACK)
			ghost.skills_list = list("cqc"=SKILL_CQC_WEAK,"endurance"=0,"engineer"=SKILL_ENGINEER_DEFAULT,"firearms"=SKILL_FIREARMS_UNTRAINED,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_DEFAULT,"leadership"=SKILL_LEAD_DEFAULT,"medical"=SKILL_MEDICAL_SURGERY,"melee_weapons"=SKILL_MELEE_WEAK,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_UNTRAINED,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)

		if(4) //Chef!
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/under/colonist(new_survivor), WEAR_BODY)
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/suit/chef(new_survivor), WEAR_JACKET)
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(new_survivor), WEAR_FEET)
			new_survivor.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel/norm(new_survivor), WEAR_BACK)
			new_survivor.equip_to_slot_or_del(new /obj/item/weapon/kitchen/rollingpin(new_survivor), WEAR_L_HAND)
			ghost.skills_list = list("cqc"=SKILL_CQC_WEAK,"endurance"=0,"engineer"=SKILL_ENGINEER_DEFAULT,"firearms"=SKILL_FIREARMS_UNTRAINED,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_DEFAULT,"leadership"=SKILL_LEAD_DEFAULT,"medical"=SKILL_MEDICAL_DEFAULT,"melee_weapons"=SKILL_MELEE_TRAINED,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_UNTRAINED,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)

		if(5) //Botanist
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/under/colonist(new_survivor), WEAR_BODY)
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/suit/apron(new_survivor), WEAR_JACKET)
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(new_survivor), WEAR_FEET)
			new_survivor.equip_to_slot_or_del(new /obj/item/weapon/hatchet(new_survivor), WEAR_L_HAND)
			ghost.skills_list = list("cqc"=SKILL_CQC_WEAK,"endurance"=0,"engineer"=SKILL_ENGINEER_DEFAULT,"firearms"=SKILL_FIREARMS_UNTRAINED,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_DEFAULT,"leadership"=SKILL_LEAD_DEFAULT,"medical"=SKILL_MEDICAL_DEFAULT,"melee_weapons"=SKILL_MELEE_WEAK,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_UNTRAINED,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)

		if(6)//Atmos
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/under/colonist(new_survivor), WEAR_BODY)
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(new_survivor), WEAR_FEET)
			new_survivor.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/utility/atmostech(new_survivor), WEAR_L_HAND)
			ghost.skills_list = list("cqc"=SKILL_CQC_WEAK,"endurance"=0,"engineer"=SKILL_ENGINEER_ENGI,"firearms"=SKILL_FIREARMS_UNTRAINED,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_DEFAULT,"leadership"=SKILL_LEAD_DEFAULT,"medical"=SKILL_MEDICAL_DEFAULT,"melee_weapons"=SKILL_MELEE_WEAK,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_UNTRAINED,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)

		if(7) //Chaplain
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/under/rank/chaplain(new_survivor), WEAR_BODY)
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(new_survivor), WEAR_FEET)
			new_survivor.equip_to_slot_or_del(new /obj/item/weapon/storage/bible/booze(new_survivor), WEAR_L_HAND)
			new_survivor.equip_to_slot_or_del(new /obj/item/weapon/gun/shotgun/double/sawn(new_survivor), WEAR_WAIST)
			new_survivor.equip_to_slot_or_del(new /obj/item/ammo_magazine/shotgun/buckshot(new_survivor), WEAR_R_HAND)
			ghost.skills_list = list("cqc"=SKILL_CQC_WEAK,"endurance"=0,"engineer"=SKILL_ENGINEER_DEFAULT,"firearms"=SKILL_FIREARMS_UNTRAINED,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_DEFAULT,"leadership"=SKILL_LEAD_DEFAULT,"medical"=SKILL_MEDICAL_DEFAULT,"melee_weapons"=SKILL_MELEE_WEAK,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_UNTRAINED,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)

		if(8) //Miner
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/under/rank/miner(new_survivor), WEAR_BODY)
			new_survivor.equip_to_slot_or_del(new /obj/item/weapon/pickaxe(new_survivor), WEAR_L_HAND)
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(new_survivor), WEAR_FEET)
			ghost.skills_list = list("cqc"=SKILL_CQC_WEAK,"endurance"=0,"engineer"=SKILL_ENGINEER_DEFAULT,"firearms"=SKILL_FIREARMS_UNTRAINED,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_DEFAULT,"leadership"=SKILL_LEAD_DEFAULT,"medical"=SKILL_MEDICAL_DEFAULT,"melee_weapons"=SKILL_MELEE_TRAINED,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_UNTRAINED,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_TRAINED)

		if(9) //Corporate guy
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/under/liaison_suit(new_survivor), WEAR_BODY)
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/suit/wcoat(new_survivor), WEAR_JACKET)
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(new_survivor), WEAR_FEET)
			new_survivor.equip_to_slot_or_del(new /obj/item/weapon/storage/briefcase(new_survivor), WEAR_L_HAND)
			new_survivor.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/vp70(new_survivor), WEAR_WAIST)
			ghost.skills_list = list("cqc"=SKILL_CQC_WEAK,"endurance"=0,"engineer"=SKILL_ENGINEER_DEFAULT,"firearms"=SKILL_FIREARMS_UNTRAINED,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_DEFAULT,"leadership"=SKILL_LEAD_DEFAULT,"medical"=SKILL_MEDICAL_DEFAULT,"melee_weapons"=SKILL_MELEE_WEAK,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_UNTRAINED,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)

		if(10) //Colonial Marshal
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/CMB(new_survivor), WEAR_JACKET)
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/under/CM_uniform(new_survivor), WEAR_BODY)
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/shoes/jackboots(new_survivor), WEAR_FEET)
			new_survivor.equip_to_slot_or_del(new /obj/item/weapon/gun/revolver/cmb(new_survivor), WEAR_L_HAND)
			ghost.skills_list = list("cqc"=SKILL_CQC_MP,"endurance"=0,"engineer"=SKILL_ENGINEER_DEFAULT,"firearms"=SKILL_FIREARMS_DEFAULT,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_DEFAULT,"leadership"=SKILL_LEAD_DEFAULT,"medical"=SKILL_MEDICAL_DEFAULT,"melee_weapons"=SKILL_MELEE_DEFAULT,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_DEFAULT,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)


	var/random_weap = rand(0,4)
	switch(random_weap)
		if(0)
			new_survivor.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/holdout(new_survivor), WEAR_WAIST)
		if(1)
			new_survivor.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/b92fs(new_survivor), WEAR_WAIST)
		if(2)
			new_survivor.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/kt42(new_survivor), WEAR_WAIST)
		if(3)
			new_survivor.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/uzi(new_survivor), WEAR_WAIST)
		if(4)
			new_survivor.equip_to_slot_or_del(new /obj/item/weapon/gun/revolver/small(new_survivor), WEAR_WAIST)


	var/random_gear = rand(0,20) //WEAR_L_HAND and slot_r/l_store are taken above.
	switch(random_gear)
		if(0)
			new_survivor.equip_to_slot_or_del(new /obj/item/device/camera/fluff/oldcamera(new_survivor), WEAR_R_HAND)
		if(1)
			new_survivor.equip_to_slot_or_del(new /obj/item/weapon/crowbar(new_survivor), WEAR_R_HAND)
		if(2)
			new_survivor.equip_to_slot_or_del(new /obj/item/device/flashlight/flare(new_survivor), WEAR_R_HAND)
		if(3)
			new_survivor.equip_to_slot_or_del(new /obj/item/weapon/wrench(new_survivor), WEAR_R_HAND)
		if(4)
			new_survivor.equip_to_slot_or_del(new /obj/item/weapon/surgicaldrill(new_survivor), WEAR_R_HAND)
		if(5)
			new_survivor.equip_to_slot_or_del(new /obj/item/stack/medical/bruise_pack(new_survivor), WEAR_R_HAND)
		if(6)
			new_survivor.equip_to_slot_or_del(new /obj/item/weapon/butterfly/switchblade(new_survivor), WEAR_R_HAND)
		if(7)
			new_survivor.equip_to_slot_or_del(new /obj/item/weapon/kitchenknife(new_survivor), WEAR_R_HAND)
		if(8)
			new_survivor.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/food/snacks/lemoncakeslice(new_survivor), WEAR_R_HAND)
		if(9)
			new_survivor.equip_to_slot_or_del(new /obj/item/clothing/head/hardhat/dblue(new_survivor), WEAR_R_HAND)
		if(10)
			new_survivor.equip_to_slot_or_del(new /obj/item/weapon/weldingtool/largetank(new_survivor), WEAR_R_HAND)

	new_survivor.equip_to_slot_or_del(new /obj/item/device/flashlight(new_survivor), WEAR_R_STORE)
	new_survivor.equip_to_slot_or_del(new /obj/item/weapon/storage/pouch/survival/full(new_survivor), WEAR_L_STORE)

	new_survivor.update_icons()

	//Give them some information
	spawn(4)
		new_survivor << "<h2>You are a survivor!</h2>"
		new_survivor << "\blue You are a survivor of the attack on the colony. You worked or lived in the archaeology colony, and managed to avoid the alien attacks...until now."
		new_survivor << "\blue You are fully aware of the xenomorph threat and are able to use this knowledge as you see fit."
		new_survivor << "\blue You are NOT aware of the marines or their intentions, and lingering around arrival zones will get you survivor-banned."
	return 1

/datum/game_mode/proc/tell_survivor_story()
	var/list/survivor_story = list(
								"You watched as a larva burst from the chest of your friend, {name}. You tried to capture the alien thing, but it escaped through the ventilation.",
								"{name} was attacked by a facehugging alien, which impregnated them with an alien lifeform. {name}'s chest exploded in gore as some creature escaped.",
								"You watched in horror as {name} got the alien lifeform's acid on their skin, melting away their flesh. You can still hear the screaming and panic...",
								"The Head of Security, {name}, made an announcement that the hostile lifeforms killed killed many, and that everyone should hide or stay behind closed doors.",
								"You were there when the alien lifeforms broke into the mess hall and dragged away the others. It was a terrible sight, and you have tried avoid open space since.",
								"It was horrible, as you watched your friend, {name}, get mauled by the horrible monsters. Their screams of agony hunt you in your dreams, leading to insomnia.",
								"You tried your best to hide, and you have seen the creatures travel through the underground tunnels and ventilation shafts. They seem to like the dark.",
								"When you woke up, it felt like you've slept for years. You don't recall much about your old life, except maybe your name. Just what the hell happened to you?",
								"You were on the front lines, trying to fight the aliens. You have seen them hatch more monsters from other humans, and you know better than to fight against death.",
								"You found something, something incredible. But your discovery was cut short when the monsters appeared and began taking people. Damn the beasts!",
								"{name} protected you when the aliens came. You don't know what happened to them, but that was some time ago, and you haven't seen them since. Maybe they are alive..."
								)
	var/list/survivor_multi_story = list(
										"You were separated from your friend, {surv}. You hope they're still alive...",
										"You were having some drinks at the bar with {surv} and {name} when an alien crawled out of the vent and dragged {name} away. You and {surv} split up to find help.",
										"Something spooked you when you were out with {surv}, scavenging. You took off in the opposite direction from them, and you haven't seen them since.",
										"When {name} became infected, you and {surv} argued over what to do with the afflicted. You nearly came to blows before walking away, leaving them behind.",
										"You ran into {surv} when out looking for supplies. After a tense stand off, you agreed to stay out of each other's way. They didn't seem so bad.",
										"A lunatic by the name of {name} was preaching some doomsday to anyone who would listen. {surv} was there too, and you two shared a laugh before the creatures arrived...",
										"Your last decent memory before everything went to hell is of {surv}. They were generally a good person to have around, and they helped you through tough times.",
										"When {name} called for evacuation, {surv} came with you. The aliens appeared soon after and everyone scattered. You hope your friend {surv} is alright.",
										"You remember an explosion... Then everything went dark. You can only recall {name} and {surv}, who were there. Maybe they know what really happened?",
										"The aliens took your mutual friend, {name}. {surv} helped with the rescue. When you got to the alien hive, your friend was dead. You took different passages out.",
										"You were playing basketball with {surv} when the creatures descended. You bolted in opposite directions, and actually managed to lose the monsters, somehow."
										)

	var/current_survivors[] = survivors //These are the current survivors, so we can remove them once we tell a story.
	var/story //The actual story they will get to read.
	var/random_name
	var/datum/mind/survivor
	while(current_survivors.len)
		survivor = pick(current_survivors)
		if(!istype(survivor))
			current_survivors -= survivor
			continue //Not a mind? How did this happen?

		random_name = pick(random_name(FEMALE),random_name(MALE))

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
					survivor.current <<  temp_story
					survivor.memory += temp_story //Add it to their memories.
					temp_story = "<b>Your story thus far</b>: " + replacetext(story, "{surv}", "[survivor.current.real_name]")
					another_survivor.current << temp_story
					another_survivor.memory += temp_story
		else
			if(survivor_story.len) //Shouldn't happen, but technically possible.
				story = pick(survivor_story)
				survivor_story -= story
				spawn(6)
					var/temp_story = "<b>Your story thus far</b>: " + replacetext(story, "{name}", "[random_name]")
					survivor.current << temp_story
					survivor.memory += temp_story
		current_survivors -= survivor
	return 1

//===================================================\\

			//MARINE GEAR INITIATLIZE\\

//===================================================\\

//We do NOT want to initilialize the gear before everyone is properly spawned in
/datum/game_mode/proc/initialize_post_marine_gear_list()

	//We take the number of marine players, deduced from other lists, and then get a scale multiplier from it, to be used in arbitrary manners to distribute equipment
	//This might count players who ready up but get kicked back to the lobby
	var/marine_pop_size = 0

	for(var/mob/M in player_list)
		if(M.stat != DEAD && M.mind && !M.mind.special_role)
			marine_pop_size++

	var/scale = max(marine_pop_size / MARINE_GEAR_SCALING_NORMAL, 1) //This gives a decimal value representing a scaling multiplier. Cannot go below 1

	//Set up attachment vendor contents related to Marine count
	for(var/X in attachment_vendors)
		var/obj/machinery/vending/attachments/A = X

		//Forcefully reset the product list
		A.product_records = list()

		A.products = list(
					/obj/item/attachable/suppressor = round(scale * 8),
					/obj/item/attachable/bayonet = round(scale * 15),
					/obj/item/attachable/compensator = round(scale * 4),
					/obj/item/attachable/extended_barrel = round(scale * 8),
					/obj/item/attachable/heavy_barrel = round(scale * 2),

					/obj/item/attachable/scope = round(scale * 1),
					/obj/item/attachable/flashlight = round(scale * 20),
					/obj/item/attachable/reddot = round(scale * 10),
					/obj/item/attachable/magnetic_harness = round(scale * 8),
					/obj/item/attachable/quickfire = round(scale * 2),

					/obj/item/attachable/foregrip = round(scale * 10),
					/obj/item/attachable/gyro = round(scale * 4),
					/obj/item/attachable/bipod = round(scale * 4),
					/obj/item/attachable/burstfire_assembly = round(scale * 2),

					/obj/item/attachable/stock/shotgun = round(scale * 3),
					/obj/item/attachable/stock/rifle = round(scale * 3) ,
					/obj/item/attachable/stock/revolver = round(scale * 3),

					/obj/item/attachable/grenade = round(scale * 5),
					/obj/item/attachable/shotgun = round(scale * 3),
					/obj/item/attachable/flamer = round(scale * 3)
					)

		//Rebuild the vendor's inventory to make our changes apply
		A.build_inventory(A.products)

	for(var/X in cargo_ammo_vendors)
		var/obj/machinery/vending/marine/cargo_ammo/CA = X

		//Forcefully reset the product list
		CA.product_records = list()

		CA.products = list(
						///obj/item/weapon/claymore/mercsword/machete = 5,
						/obj/item/weapon/storage/large_holster/machete/full = round(scale * 6),
						/obj/item/ammo_magazine/pistol = round(scale * 10),
						/obj/item/ammo_magazine/pistol/hp = 0,
						/obj/item/ammo_magazine/pistol/ap = round(scale * 3),
						/obj/item/ammo_magazine/pistol/incendiary = round(scale * 1),
						/obj/item/ammo_magazine/pistol/extended = round(scale * 1),
						/obj/item/ammo_magazine/pistol/m1911 = round(scale * 1),
						/obj/item/ammo_magazine/revolver = round(scale * 10),
						/obj/item/ammo_magazine/revolver/marksman = round(scale * 2),
						/obj/item/ammo_magazine/smg/m39 = round(scale * 10),
						/obj/item/ammo_magazine/smg/m39/ap = round(scale * 5),
						/obj/item/ammo_magazine/smg/m39/extended = round(scale * 1),
						/obj/item/ammo_magazine/rifle = round(scale * 15),
						/obj/item/ammo_magazine/rifle/extended = round(scale * 1),
						/obj/item/ammo_magazine/rifle/incendiary = round(scale * 1),
						/obj/item/ammo_magazine/rifle/ap = round(scale * 10),
						/obj/item/ammo_magazine/rifle/marksman = round(scale * 1),
						/obj/item/ammo_magazine/rifle/m41aMK1 = 0,
						/obj/item/ammo_magazine/rifle/lmg = 0,
						/obj/item/ammo_magazine/shotgun = round(scale * 8),
						/obj/item/ammo_magazine/shotgun/buckshot = round(scale * 5),
						/obj/item/ammo_magazine/sniper = round(scale * 1),
						/obj/item/ammo_magazine/sniper/incendiary = round(scale * 1),
						/obj/item/ammo_magazine/sniper/flak = round(scale * 1),
						/obj/item/smartgun_powerpack = round(scale * 1)
						)

		CA.build_inventory(CA.products)


	for(var/obj/machinery/vending/marine/M in marine_vendors)

		//Forcefully reset the product list
		M.product_records = list()

		M.products = list(
						/obj/item/weapon/gun/pistol/m4a3 = round(scale * 25),
						/obj/item/weapon/gun/revolver/m44 = round(scale * 5),
						/obj/item/weapon/gun/smg/m39 = round(scale * 20),
						/obj/item/weapon/gun/rifle/m41a = round(scale * 25),
						/obj/item/weapon/gun/shotgun/pump = round(scale * 10),

						/obj/item/ammo_magazine/pistol = round(scale * 30),
						/obj/item/ammo_magazine/revolver = round(scale * 25),
						/obj/item/ammo_magazine/smg/m39 = round(scale * 30),
						/obj/item/ammo_magazine/rifle = round(scale * 22),
						/obj/item/ammo_magazine/rifle/ap = 0,
						/obj/item/ammo_magazine/shotgun = round(scale * 8),
						/obj/item/ammo_magazine/shotgun/buckshot = round(scale * 8),

						/obj/item/weapon/combat_knife = round(scale * 20),
						/obj/item/weapon/throwing_knife = round(scale * 5),
						/obj/item/weapon/storage/box/m94 = round(scale * 5),
						/obj/item/weapon/storage/backpack/marine = round(scale * 10),
						/obj/item/weapon/storage/backpack/marine/satchel = round(scale * 10),
						/obj/item/device/radio/headset/almayer = round(scale * 5),
						/obj/item/weapon/storage/belt/marine = round(scale * 5),
						/obj/item/weapon/storage/belt/shotgun = round(scale * 3),
						/obj/item/weapon/storage/belt/knifepouch = round(scale * 5),
						/obj/item/weapon/storage/belt/gun/m4a3 = round(scale * 5),
						/obj/item/weapon/storage/large_holster/m37 = round(scale * 5),
						/obj/item/clothing/shoes/marine = round(scale * 5),
						/obj/item/clothing/under/marine = round(scale * 10),
						/obj/item/clothing/suit/storage/marine = round(scale * 10),
						/obj/item/clothing/head/helmet/marine = round(scale * 10),

						/obj/item/attachable/flashlight = round(scale * 10),
						/obj/item/attachable/bayonet = round(scale * 10),

						/obj/item/weapon/storage/pouch/general = round(scale * 10),
						/obj/item/weapon/storage/pouch/bayonet = round(scale * 10),
						/obj/item/weapon/storage/pouch/firstaid/full = round(scale * 10),
						/obj/item/weapon/storage/pouch/pistol = round(scale * 10),
						/obj/item/weapon/storage/pouch/flare/full = round(scale * 10),
						/obj/item/weapon/storage/pouch/magazine/pistol = round(scale * 10)
						)

		M.contraband =   list(/obj/item/ammo_magazine/revolver/marksman = round(scale * 2),
							/obj/item/ammo_magazine/pistol/ap = round(scale * 2),
							/obj/item/ammo_magazine/smg/m39/ap = round(scale * 1)
							)

		M.premium = list(/obj/item/weapon/gun/rifle/m41aMK1 = round(scale * 1),
						)

		//Rebuild the vendor's inventory to make our changes apply
		M.build_inventory(M.products)
		M.build_inventory(M.contraband, 1)
		M.build_inventory(M.premium, 0, 1)

		var/products2[]
		if(istype(src, /datum/game_mode/ice_colony)) //Literally, we are in gamemode code
			products2 = list(
						/obj/item/clothing/mask/rebreather/scarf = round(scale * 10),
							)
		M.build_inventory(products2)

	//Scale the amount of cargo points through a direct multiplier
	supply_controller.points = round(supply_controller.points * scale)
