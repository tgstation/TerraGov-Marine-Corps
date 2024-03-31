// traitors, bandits, pro thieves, werewolves, vampires, demons, cultists
/*

/datum/game_mode/chaosmode
	name = "chaosmode"
	config_tag = "chaosmode"
	report_type = "chaosmode"
	false_report_weight = 0
	required_players = 0
	required_enemies = 0
	recommended_enemies = 0
	enemy_minimum_age = 0

	announce_span = "danger"
	announce_text = "The"

	var/allmig = FALSE
	var/roguefight = FALSE
	var/redscore = 0
	var/greenscore = 0

	var/list/allantags = list()

	var/datum/team/roguecultists

	var/list/datum/mind/villains = list()
	var/list/datum/mind/vampires = list()
	var/list/datum/mind/werewolves = list()
	var/list/datum/mind/bandits = list()

	var/list/datum/mind/pre_villains = list()
	var/list/datum/mind/pre_werewolves = list()
	var/list/datum/mind/pre_vampires = list()
	var/list/datum/mind/pre_bandits = list()
	var/list/datum/mind/pre_delfs = list()
	var/list/datum/mind/pre_rebels = list()

	var/banditcontrib = 0
	var/banditgoal = 1
	var/delfcontrib = 0
	var/delfgoal = 1

	var/skeletons = FALSE

	var/headrebdecree = FALSE

	var/check_for_lord = TRUE
	var/next_check_lord = 0
	var/missing_lord_time = FALSE
	var/roundvoteend = FALSE
	var/ttime

/datum/game_mode/chaosmode/proc/reset_skeletons()
	skeletons = FALSE

/datum/game_mode/chaosmode/check_finished()
	ttime = world.time - SSticker.round_start_time
	if(roguefight)
		if(ttime >= 30 MINUTES)
			return TRUE
		if((redscore >= 100) || (greenscore >= 100))
			return TRUE
		return FALSE

	if(allmig)
		return FALSE
/*		if(ttime >= 99 MINUTES)
			for(var/mob/living/carbon/human/H in GLOB.human_list)
				if(H.stat != DEAD)
					if(H.allmig_reward && H.key)
						H.adjust_triumphs(H.allmig_reward)
						H.allmig_reward = 0
			return TRUE
		return FALSE*/

	if(ttime >= GLOB.round_timer)
		if(roundvoteend)
			if(ttime >= (GLOB.round_timer + 15 MINUTES) )
				for(var/mob/living/carbon/human/H in GLOB.human_list)
					if(H.stat != DEAD)
						if(H.allmig_reward)
							H.adjust_triumphs(H.allmig_reward)
							H.allmig_reward = 0
				return TRUE
		else
			if(!SSvote.mode)
				SSvote.initiate_vote("endround", pick("Zlod", "Sun King", "Gaia", "Moon Queen", "Aeon", "Gemini", "Aries"))
//	if(SSshuttle.emergency && (SSshuttle.emergency.mode == SHUTTLE_ENDGAME))
//		return TRUE

	if(headrebdecree)
		return TRUE

	check_for_lord()

	if(ttime > 180 MINUTES) //3 hour cutoff
		return TRUE

/datum/game_mode/chaosmode/proc/check_for_lord()
	if(world.time < next_check_lord)
		return
	next_check_lord = world.time + 1 MINUTES
	var/lord_found = FALSE
	var/lord_dead = FALSE
	for(var/mob/living/carbon/human/H in GLOB.human_list)
		if(H.mind)
			if((H.job == "King" || H.job == "Queen") && (SSticker.rulermob == H))
				lord_found = TRUE
				if(H.stat == DEAD)
					lord_dead = TRUE
				else
					if(lord_dead)
						lord_dead = FALSE
					break
	if(lord_dead || !lord_found)
		if(!missing_lord_time)
			missing_lord_time = world.time
		if(world.time > missing_lord_time + 10 MINUTES)
			missing_lord_time = world.time
			addomen("nolord")
		return FALSE
	else
		return TRUE


/datum/game_mode/chaosmode/pre_setup()
	if(allmig || roguefight)
		return TRUE
	for(var/A in GLOB.special_roles_rogue)
		allantags |= get_players_for_role(A)

	pick_bandits()

	return TRUE

/datum/game_mode/proc/after_DO()
	return

/datum/game_mode/chaosmode/after_DO()
	if(allmig || roguefight)
		return TRUE

	var/list/modez_random = list(1,2,3)
	modez_random = shuffle(modez_random)
	for(var/i in modez_random)
		switch(i)
			if(1)
				if(prob(14))
					pick_rebels()
			if(2)
				var/amdt = max(round(num_players() / 3),1)
				for(var/j in 1 to amdt)
					if(prob(50))
						pick_vampires()
						pick_werewolves()
					else
						pick_werewolves()
						pick_vampires()
			if(3)
				if(prob(30))
					pick_maniac()

	return TRUE

/datum/game_mode/chaosmode/proc/pick_bandits()
	//BANDITS
	banditgoal = rand(200,400)
	restricted_jobs = list("King",
	"Queen",
	"Merchant",
	"Priest")
	var/num_bandits = 0
	if(num_players() >= 10)
		num_bandits = CLAMP(round(num_players() / 2), 1, 5)
		banditgoal += (num_bandits * rand(200,400))
#ifdef TESTSERVER
	num_bandits = 999
#endif
	if(num_bandits)
		antag_candidates = get_players_for_role(ROLE_BANDIT, pre_do=TRUE) //pre_do checks for their preferences since they don't have a job yet
		for(var/i = 0, i < num_bandits, ++i)
			var/datum/mind/bandito = pick_n_take(antag_candidates)
			var/found = FALSE
			for(var/M in allantags)
				if(M == bandito)
					found = TRUE
					allantags -= M
					break
			if(!found)
				continue
			pre_bandits += bandito
			bandito.assigned_role = "Bandit"
			bandito.special_role = "Bandit"
			testing("[key_name(bandito)] has been selected as a bandit")
			log_game("[key_name(bandito)] has been selected as a bandit")
	for(var/antag in pre_bandits)
		GLOB.pre_setup_antags |= antag
	restricted_jobs = list()

/datum/game_mode/chaosmode/proc/pick_rebels()
	restricted_jobs = list() //handled after picking
	var/num_rebels = 0
	if(num_players() >= 10)
		num_rebels = CLAMP(round(num_players() / 3), 1, 3)
	if(num_rebels)
		antag_candidates = get_players_for_role(ROLE_PREBEL)
		if(antag_candidates.len)
			for(var/i = 0, i < num_rebels, ++i)
				var/datum/mind/rebelguy = pick_n_take(antag_candidates)
				if(!rebelguy)
					continue
				var/blockme = FALSE
				if(!(rebelguy in allantags))
					blockme = TRUE
				if(rebelguy.assigned_role in GLOB.garrison_positions)
					blockme = TRUE
				if(rebelguy.assigned_role in GLOB.noble_positions)
					blockme = TRUE
				if(rebelguy.assigned_role in GLOB.youngfolk_positions)
					blockme = TRUE
				if(rebelguy.assigned_role in GLOB.church_positions)
					blockme = TRUE
				if(rebelguy.assigned_role in GLOB.serf_positions)
					blockme = TRUE
				if(blockme)
					continue
				allantags -= rebelguy
				pre_rebels += rebelguy
				rebelguy.special_role = "Peasant Rebel"
				testing("[key_name(rebelguy)] has been selected as a Peasant Rebel")
				log_game("[key_name(rebelguy)] has been selected as a Peasant Rebel")
	for(var/antag in pre_rebels)
		GLOB.pre_setup_antags |= antag
	restricted_jobs = list()

/datum/game_mode/chaosmode/proc/pick_maniac()
	restricted_jobs = list("King",
	"Queen",
	"Prisoner",
	"Dungeoneer",
	"Witch Hunter",
	"Confessor",
	"Town Guard",
	"Castle Guard",
	"Veteran",
	"Acolyte",
	"Cleric",
	"Sheriff")
	antag_candidates = get_players_for_role(ROLE_NBEAST)
	var/datum/mind/villain = pick_n_take(antag_candidates)
	if(villain)
		var/blockme = FALSE
		if(!(villain in allantags))
			blockme = TRUE
		if(villain.assigned_role in GLOB.youngfolk_positions)
			blockme = TRUE
		if(villain.current)
			if(villain.current.gender == FEMALE)
				blockme = TRUE
		if(blockme)
			return
		allantags -= villain
		pre_villains += villain
		villain.special_role = "maniac"
		villain.restricted_roles = restricted_jobs.Copy()
		testing("[key_name(villain)] has been selected as the [villain.special_role]")
		log_game("[key_name(villain)] has been selected as the [villain.special_role]")
	for(var/antag in pre_villains)
		GLOB.pre_setup_antags |= antag
	restricted_jobs = list()

/datum/game_mode/chaosmode/proc/pick_vampires()
	restricted_jobs = list("Acolyte","Priest","Adventurer","Confessor","Town Guard","Veteran","Castle Guard","Sheriff")
/*	var/num_vampires = rand(1,3)
#ifdef TESTSERVER
	num_vampires = 100
#endif*/
	antag_candidates = get_players_for_role(ROLE_NBEAST)
	if(antag_candidates.len)
		var/datum/mind/vampire = pick(antag_candidates)
		var/blockme = FALSE
		if(!(vampire in allantags))
			blockme = TRUE
		if(vampire.assigned_role in GLOB.youngfolk_positions)
			blockme = TRUE
		if(blockme)
			return
		allantags -= vampire
		pre_vampires += vampire
		vampire.special_role = "vampire"
		vampire.restricted_roles = restricted_jobs.Copy()
		testing("[key_name(vampire)] has been selected as a VAMPIRE")
		log_game("[key_name(vampire)] has been selected as a [vampire.special_role]")
		antag_candidates.Remove(vampire)
	for(var/antag in pre_vampires)
		GLOB.pre_setup_antags |= antag
	restricted_jobs = list()

/datum/game_mode/chaosmode/proc/pick_werewolves()
	restricted_jobs = list("Acolyte","Priest","Adventurer","Confessor","Town Guard","Veteran","Castle Guard","Sheriff")
/*	var/num_werewolves = rand(1,3)
#ifdef TESTSERVER
	num_werewolves = 100
#endif*/
	antag_candidates = get_players_for_role(ROLE_NBEAST)
	if(antag_candidates.len)
		var/datum/mind/werewolf = pick(antag_candidates)
		var/blockme = FALSE
		if(!(werewolf in allantags))
			blockme = TRUE
		if(werewolf.assigned_role in GLOB.youngfolk_positions)
			blockme = TRUE
		if(blockme)
			return
		allantags -= werewolf
		pre_werewolves += werewolf
		werewolf.special_role = "werewolf"
		werewolf.restricted_roles = restricted_jobs.Copy()
		testing("[key_name(werewolf)] has been selected as a WEREWOLF")
		log_game("[key_name(werewolf)] has been selected as a [werewolf.special_role]")
		antag_candidates.Remove(werewolf)
	for(var/antag in pre_werewolves)
		GLOB.pre_setup_antags |= antag
	restricted_jobs = list()

/datum/game_mode/chaosmode/post_setup()
	set waitfor = FALSE
///////////////// VILLAINS
	for(var/datum/mind/traitor in pre_villains)
		var/datum/antagonist/new_antag = new /datum/antagonist/villain()
		addtimer(CALLBACK(traitor, /datum/mind.proc/add_antag_datum, new_antag), rand(10,100))
		GLOB.pre_setup_antags -= traitor
		villains += traitor

///////////////// WWOLF
	for(var/datum/mind/werewolf in pre_werewolves)
		var/datum/antagonist/new_antag = new /datum/antagonist/werewolf()
		addtimer(CALLBACK(werewolf, /datum/mind.proc/add_antag_datum, new_antag), rand(10,100))
		GLOB.pre_setup_antags -= werewolf
		werewolves += werewolf

///////////////// VAMPIRES
	for(var/datum/mind/vampire in pre_vampires)
		var/datum/antagonist/new_antag = new /datum/antagonist/vampire()
		addtimer(CALLBACK(vampire, /datum/mind.proc/add_antag_datum, new_antag), rand(10,100))
		GLOB.pre_setup_antags -= vampire
		vampires += vampire

///////////////// BANDIT
	for(var/datum/mind/bandito in pre_bandits)
		var/datum/antagonist/new_antag = new /datum/antagonist/bandit()
		bandito.add_antag_datum(new_antag)
		GLOB.pre_setup_antags -= bandito
		bandits += bandito

///////////////// REBELS
	for(var/datum/mind/rebelguy in pre_rebels)
		var/datum/antagonist/new_antag = new /datum/antagonist/prebel/head()
		rebelguy.add_antag_datum(new_antag)
		GLOB.pre_setup_antags -= rebelguy

	..()
	//We're not actually ready until all traitors are assigned.
	gamemode_ready = FALSE
	addtimer(VARSET_CALLBACK(src, gamemode_ready, TRUE), 101)
	return TRUE

/datum/game_mode/chaosmode/make_antag_chance(mob/living/carbon/human/character) //klatejoin
	return
//******** VILLAINS
	var/num_villains = round((num_players() * 0.30)+1, 1)
	if((villains.len + pre_villains.len) >= num_villains) //Upper cap for number of latejoin antagonists
		return
	if(ROLE_VILLAIN in character.client.prefs.be_special)
		if(!is_banned_from(character.ckey, list(ROLE_VILLAIN)) && !QDELETED(character))
			if(age_check(character.client))
				if(!(character.job in restricted_jobs))
					if(prob(66))
						add_latejoin_villain(character.mind)

/datum/game_mode/chaosmode/proc/add_latejoin_villain(datum/mind/character)
	var/datum/antagonist/villain/new_antag = new /datum/antagonist/villain()
	character.add_antag_datum(new_antag)

/datum/game_mode/chaosmode/proc/vampire_werewolf()
	var/vampyr = 0
	var/wwoelf = 0
	for(var/mob/living/carbon/human/player in GLOB.human_list)
		if(player.mind)
			if(player.stat != DEAD)
				if(isbrain(player)) //also technically dead
					continue
				if(is_in_roguetown(player))
					var/datum/antagonist/D = player.mind.has_antag_datum(/datum/antagonist/werewolf)
					if(D && D.increase_votepwr)
						wwoelf++
						continue
					D = player.mind.has_antag_datum(/datum/antagonist/vampire)
					if(D && D.increase_votepwr)
						vampyr++
						continue
	if(vampyr)
		if(!wwoelf)
			return "vampire"
	if(wwoelf)
		if(!vampyr)
			return "werewolf"
*/
