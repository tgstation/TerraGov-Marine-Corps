/datum/game_mode/roguewar/proc/get_team()

/*

/datum/game_mode/roguewar
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

/datum/game_mode/chaosmode/proc/reset_skeletons()
	skeletons = FALSE

/datum/game_mode/chaosmode/check_finished()
	//end the round at day 3 midnight
	var/ttime = world.time - SSticker.round_start_time
	if(roguefight)
		if(ttime >= 30 MINUTES)
			return TRUE
		if((redscore >= 100) || (greenscore >= 100))
			return TRUE
		return FALSE

	if(allmig)
		if(ttime >= 99 MINUTES)
			for(var/mob/living/carbon/human/H in GLOB.human_list)
				if(!H.stat)
					if(H.allmig_reward && H.key)
						H.adjust_triumphs(H.allmig_reward)
						H.allmig_reward = 0
			return TRUE
		return FALSE

	if(ttime >= GLOB.round_timer)
		if(roundvoteend)
			return TRUE
		if(!SSvote.mode)
			SSvote.initiate_vote("endround", pick("Zlod", "Sun King", "Gaia", "Aeon", "Gemini", "Aries"))
//	if(SSshuttle.emergency && (SSshuttle.emergency.mode == SHUTTLE_ENDGAME))
//		return TRUE
	if(headrebdecree)
		return TRUE

	check_for_lord()

/datum/game_mode/chaosmode/proc/check_for_lord()
	if(world.time < next_check_lord)
		return
	next_check_lord = world.time + 1 MINUTES
	var/lord_found = FALSE
	var/lord_dead = FALSE
	for(var/mob/living/carbon/human/H in GLOB.human_list)
		if(H.mind)
			if(H.job == "Lord")
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
		testing("getplayersforroleall")
		allantags |= get_players_for_role(A)

	//BANDITS
	banditgoal = rand(200,400)
	restricted_jobs = list("Lord",
	"Knight",
	"Merchant",
	"Gatemaster",
	"Sheriff",
	"Witch Hunter",
	"Village Elder",
	"Town Guard")
	var/num_bandits = 0
	if(num_players() >= 10)
		num_bandits = CLAMP(round(num_players() / 10), 1, 4)
		banditgoal += (num_bandits * rand(200,400))
#ifdef TESTSERVER
	num_bandits = 8
#endif
	if(num_bandits)
		for(var/i = 0, i < num_bandits, ++i)
			antag_candidates = get_players_for_role(ROLE_BANDIT)
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
		GLOB.pre_setup_antags += antag
	restricted_jobs = list()

	return TRUE

/datum/game_mode/proc/after_DO()
	return

/datum/game_mode/chaosmode/after_DO()
	if(allmig || roguefight)
		testing("gamemode 1")
		return TRUE
	testing("gamemode 2")

	var/list/modez_random = list(1,2,3)
	modez_random = shuffle(modez_random)
	for(var/i in modez_random)
		switch(i)
			if(1)
				pick_rebels()
			if(2)
				if(prob(50))
					pick_vampires()
					pick_werewolves()
				else
					pick_werewolves()
					pick_vampires()
			if(3)
				pick_maniac()


	return TRUE

/datum/game_mode/chaosmode/proc/pick_rebels()
#ifdef TESTSERVER
	var/proab = 100
#else
	var/proab = 12
#endif
	if(prob(proab))
		restricted_jobs = list() //handled after picking
		var/num_rebels = 0
		if(num_players() >= 10)
			num_rebels = CLAMP(round(num_players() / 10), 1, 3)
#ifdef TESTSERVER
		num_rebels = 8
#endif
		if(num_rebels)
			antag_candidates = get_players_for_role(ROLE_PREBEL)
			if(antag_candidates.len)
				for(var/i = 0, i < num_rebels, ++i)
					var/datum/mind/rebelguy = pick_n_take(antag_candidates)
					if(!rebelguy)
						continue
					var/found = FALSE
					for(var/M in allantags)
						if(M == rebelguy)
							found = TRUE
							break
					if(rebelguy.assigned_role in GLOB.garrison_positions)
						found = FALSE
					if(rebelguy.assigned_role in GLOB.noble_positions)
						found = FALSE
					if(rebelguy.assigned_role in GLOB.youngfolk_positions)
						found = FALSE
					if(rebelguy.assigned_role in GLOB.church_positions)
						found = FALSE
					if(rebelguy.assigned_role in GLOB.serf_positions)
						found = FALSE
					if(!found)
						continue
					allantags -= rebelguy
					pre_rebels += rebelguy
					rebelguy.special_role = "Peasant Rebel"
					testing("[key_name(rebelguy)] has been selected as a Peasant Rebel")
					log_game("[key_name(rebelguy)] has been selected as a Peasant Rebel")
		for(var/antag in pre_rebels)
			GLOB.pre_setup_antags += antag
		restricted_jobs = list()

/datum/game_mode/chaosmode/proc/pick_maniac()
	restricted_jobs = list("Lord",
	"Prisoner",
	"Dungeoneer",
	"Witch Hunter",
	"Shepherd",
	"Monk",
	"Cleric",
	"Sheriff")
	var/proab
#ifdef TESTSERVER
	proab = 100
#else
	proab = 10 //35?
#endif
	if(prob(proab))
		antag_candidates = get_players_for_role(ROLE_VILLAIN)
		var/datum/mind/villain = pick_n_take(antag_candidates)
		if(villain)
			var/found = FALSE
			for(var/M in allantags)
				if(M == villain)
					found = TRUE
			if(villain.assigned_role in GLOB.youngfolk_positions)
				found = FALSE
			if(villain.current)
				if(villain.current.gender == FEMALE)
					if(villain.assigned_role != "Concubine")
						found = FALSE
			if(found)
				allantags -= villain
				pre_villains += villain
				villain.special_role = "maniac"
				villain.restricted_roles = restricted_jobs.Copy()
				testing("[key_name(villain)] has been selected as the [villain.special_role]")
				log_game("[key_name(villain)] has been selected as the [villain.special_role]")
				antag_candidates.Remove(villain)
	for(var/antag in pre_villains)
		GLOB.pre_setup_antags += antag
	restricted_jobs = list()

/datum/game_mode/chaosmode/proc/pick_vampires()
	restricted_jobs = list("Monk","Priest","Witch Hunter","Shepherd")
	var/num_vampires = rand(1,3)
#ifdef TESTSERVER
	num_vampires = 100
#endif
	antag_candidates = get_players_for_role(ROLE_VAMPIRE)
	if(antag_candidates.len)
		testing("[antag_candidates.len] len for vampire")
		for(var/j = 0, j < num_vampires, j++)
			var/datum/mind/vampire = antag_pick(antag_candidates)
			var/found = FALSE
			for(var/M in allantags)
				if(M == vampire)
					found = TRUE
					allantags -= M
					break
			if(vampire.assigned_role in GLOB.youngfolk_positions)
				found = FALSE
			if(!found)
				continue
			pre_vampires += vampire
			vampire.special_role = "vampire"
			vampire.restricted_roles = restricted_jobs.Copy()
			testing("[key_name(vampire)] has been selected as a VAMPIRE")
			log_game("[key_name(vampire)] has been selected as a [vampire.special_role]")
			antag_candidates.Remove(vampire)
	for(var/antag in pre_vampires)
		GLOB.pre_setup_antags += antag
	restricted_jobs = list()

/datum/game_mode/chaosmode/proc/pick_werewolves()
	restricted_jobs = list("Prisoner","Knight","Witch Hunter","Shepherd")
	var/num_werewolves = rand(1,3)
#ifdef TESTSERVER
	num_werewolves = 100
#endif
	antag_candidates = get_players_for_role(ROLE_WEREWOLF)
	if(antag_candidates.len)
		for(var/j = 0, j < num_werewolves, j++)
			var/datum/mind/werewolf = antag_pick(antag_candidates)
			var/found = FALSE
			for(var/M in allantags)
				if(M == werewolf)
					found = TRUE
					allantags -= M
					break
			if(werewolf.assigned_role in GLOB.youngfolk_positions)
				found = FALSE
			if(!found)
				continue
			pre_werewolves += werewolf
			werewolf.special_role = "werewolf"
			werewolf.restricted_roles = restricted_jobs.Copy()
			testing("[key_name(werewolf)] has been selected as a WEREWOLF")
			log_game("[key_name(werewolf)] has been selected as a [werewolf.special_role]")
			antag_candidates.Remove(werewolf)
	for(var/antag in pre_werewolves)
		GLOB.pre_setup_antags += antag
	restricted_jobs = list()

/datum/game_mode/chaosmode/post_setup()
	set waitfor = FALSE
///////////////// VILLAINS
	for(var/datum/mind/traitor in pre_villains)
		var/datum/antagonist/new_antag = new /datum/antagonist/villain()
		addtimer(CALLBACK(traitor, /datum/mind.proc/add_antag_datum, new_antag), rand(10,100))
		GLOB.pre_setup_antags -= traitor

///////////////// WWOLF
	for(var/datum/mind/werewolf in pre_werewolves)
		var/datum/antagonist/new_antag = new /datum/antagonist/werewolf()
		addtimer(CALLBACK(werewolf, /datum/mind.proc/add_antag_datum, new_antag), rand(10,100))
		GLOB.pre_setup_antags -= werewolf

///////////////// VAMPIRES
	for(var/datum/mind/vampire in pre_vampires)
		var/datum/antagonist/new_antag = new /datum/antagonist/vampire()
		addtimer(CALLBACK(vampire, /datum/mind.proc/add_antag_datum, new_antag), rand(10,100))
		GLOB.pre_setup_antags -= vampire

///////////////// BANDIT
	for(var/datum/mind/bandito in pre_bandits)
		var/datum/antagonist/new_antag = new /datum/antagonist/bandit()
		bandito.add_antag_datum(new_antag)
		GLOB.pre_setup_antags -= bandito

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
	if((SSticker.mode.villains.len + pre_villains.len) >= num_villains) //Upper cap for number of latejoin antagonists
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
	var/list/vampires = list()
	var/list/werewolves = list()
	for(var/mob/living/player in GLOB.player_list)
		if(player.mind)
			if(player.stat != DEAD)
				if(isbrain(player)) //also technically dead
					continue
				var/area/A = get_area(player)
				if(is_type_in_typecache(A, GLOB.roguetown_areas_typecache))
					var/datum/antagonist/D = player.mind.has_antag_datum(/datum/antagonist/werewolf)
					if(D && D.increase_votepwr)
						werewolves += player
						continue
					D = player.mind.has_antag_datum(/datum/antagonist/vampire)
					if(D && D.increase_votepwr)
						vampires += player
						continue
	if(vampires.len)
		if(werewolves.len)
			return "vampire"
	if(werewolves.len)
		if(vampires.len)
			return "werewolf"*/
