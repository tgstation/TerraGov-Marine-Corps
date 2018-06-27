/*
How this works:
jobs.dm contains the job defines that work on that level only. Things like equipping a character, creating IDs, and so forth, are handled there.
Role Authority handles the creation and assignment of roles. Roles can be things like regular marines, PMC response teams, aliens, and so forth.
Role Authority creates two master lists on New(), one for every role defined in the game, by path, and one only for roles that should appear
at round start, by name. The title of a role is important and is a unique identifier. Two roles can share the same title, but it's really
the same role, just with different equipment, spawn conditions, or something along those lines. The title is there to tell the job ban system
which roles to ban, and it does so through the roles_by_name master list.

When a round starts, the roles are assigned based on the round, from another list. This is done to make sure that both the master list of roles
by name can be kept for things like job bans, while the round may add or remove roles as needed.If you need to equip a mob for a job, always
use roles_by_path as it is an accurate account of every specific role path (with specific equipment).
*/
var/global/datum/authority/branch/role/RoleAuthority

#define GET_RANDOM_JOB 0
#define BE_ASSISTANT 1
#define RETURN_TO_LOBBY 2

/datum/authority/branch/role
	name = "Role Authority"

	var/roles_by_path[] //Master list generated when role aithority is created, listing every role by path, including variable roles. Great for manually equipping with.
	var/roles_by_name[] //Master list generated when role authority is created, listing every default role by name, including those that may not be regularly selected.
	var/roles_for_mode[] //Derived list of roles only for the game mode, generated when the round starts.
	var/roles_whitelist[] //Associated list of lists, by ckey. Checks to see if a person is whitelisted for a specific role.

	var/unassigned_players[]
	var/squads[]

 //#define FACTION_TO_JOIN "Marines"
	//Whenever the controller is created, we want to set up the basic role lists.
	New()
		var/roles_all[] = typesof(/datum/job) - list( //We want to prune all the parent types that are only variable holders.
												/datum/job,
												/datum/job/pmc,
												/datum/job/command,
												/datum/job/civilian,
												/datum/job/logistics,
												/datum/job/logistics/tech,
												/datum/job/marine,
												/datum/job/pmc/elite_responder)
		var/squads_all[] = typesof(/datum/squad) - /datum/squad

		if(!roles_all.len)
			world << "<span class='debug'>Error setting up jobs, no job datums found.</span>"
			log_debug("Error setting up jobs, no job datums found.")
			return //No real reason this should be length zero, so we'll just return instead.

		if(!squads_all.len)
			world << "<span class='debug'>Error setting up squads, no squad datums found.</span>"
			log_debug("Error setting up squads, no squad datums found.")
			return

		roles_by_path 	= new
		roles_by_name 	= new
		roles_for_mode  = new
		roles_whitelist = new
		squads 			= new

		var/L[] = new
		var/datum/job/J
		var/datum/squad/S
		var/i

		for(i in roles_all) //Setting up our roles.
			J = new i

			if(!J.title) //In case you forget to subtract one of those variable holder jobs.
				world << "<span class='debug'>Error setting up jobs, blank title job: [J.type].</span>"
				log_debug("Error setting up jobs, blank title job: [J.type].")
				continue

			roles_by_path[J.type] = J
			if(J.flags_startup_parameters & ROLE_ADD_TO_DEFAULT) roles_by_name[J.title] = J
			if(J.flags_startup_parameters & ROLE_ADD_TO_MODE) roles_for_mode[J.title] = J

		//	if(J.faction == FACTION_TO_JOIN)  //TODO Initialize non-faction jobs? //TODO Do we really need this?

		//TODO Come up with some dynamic method of doing this.
		for(i in ROLES_REGULAR_ALL) //We're going to re-arrange the list for mode to look better, starting with the officers.
			J = roles_for_mode[i]
			if(J) L[J.title] = J
		roles_for_mode = L

		for(i in squads_all) //Setting up our squads.
			S = new i()
			squads += S

		load_whitelist()

/datum/authority/branch/role/proc/load_whitelist(filename = "config/role_whitelist.txt")
	var/L[] = file2list(filename)
	var/P[]
	var/W[] = new //We want a temporary whitelist list, in case we need to reload.

	var/i
	var/r
	var/ckey
	var/role
	for(i in L)
		if(!i)	continue
		i = trim(i)
		if(!length(i)) continue
		else if (copytext(i, 1, 2) == "#") continue

		P = text2list(i, "+")
		if(!P.len) continue
		ckey = ckey(P[1]) //Converting their key to canonical form. ckey() does this by stripping all spaces, underscores and converting to lower case.

		role = NOFLAGS
		r = 1
		while(++r <= P.len)
			switch(ckey(P[r]))
				if("yautja","predator","pred","unblooded") 			role |= WHITELIST_YAUTJA_UNBLOODED
				if("yautjablooded","bloodedpredator","blooded") 	role |= WHITELIST_YAUTJA_BLOODED
				if("yautjaelite","elitepredator","elite")			role |= WHITELIST_YAUTJA_ELITE
				if("yautjaelder","elderpredator","elder")			role |= WHITELIST_YAUTJA_ELDER
				if("commander","co") 								role |= WHITELIST_COMMANDER
				if("synthetic","synth") 							role |= WHITELIST_SYNTHETIC
				if("arcturian","snowflake") 						role |= WHITELIST_ARCTURIAN
				if("all","everything") 								role |= WHITELIST_ALL

		W[ckey] = role

	roles_whitelist = W

//#undef FACTION_TO_JOIN

 /*
 Consolidated into a better collection of procs. It was also calling too many loops, and I tried to fix that as well.
 I hope it's easier to tell what the heck this proc is even doing, unlike previously.
 */


/datum/authority/branch/role/proc/setup_candidates_and_roles()
	//===============================================================\\
	//PART I: Initializing starting lists and such.

	if(!roles_for_mode || !roles_for_mode.len) return //Can't start if this doesn't exist.

	var/datum/job/J
	var/i
	//var/roles_special[]	= new   //TODO Make this a reality.
	var/datum/game_mode/G = ticker.mode
	switch(G.role_instruction)
		if(1) //Replacing the entire list.
			roles_for_mode = new
			for(i in G.roles_for_mode)
				J = roles_by_path[i]
				roles_for_mode[J.title] = J
		if(2) //Adding a role, or multiple roles, to the list.
			for(i in G.roles_for_mode)
				J = roles_by_path[i]
				roles_for_mode[J.title] = J
		if(3) //Subtracting from the list.
			for(i in G.roles_for_mode)
				J = roles_by_path[i]
				roles_for_mode -= J.title

	var/roles_command[] = roles_for_mode & ROLES_COMMAND //If we have a special mode list, we only want that which is on the list.
	var/roles_regular[] = roles_for_mode - roles_command //Two different lists, since we always want to check command first when we loop.
	if(roles_command.len) roles_command = shuffle(roles_command, 1) //Shuffle our job lists for when we begin the loop.
	if(roles_regular.len) roles_regular = shuffle(roles_regular, 1) //Should always have some, but who knows.
	//In the future, any regular role that has infinite spawn slots should be removed as well.

	/*===============================================================*/

	//===============================================================\\
	//PART II: Setting up our player variables and lists, to see if we have anyone to destribute.

	unassigned_players  = new
	var/mob/new_player/M


	var/good_age_min = 20//Best command candidates are in the 25 to 40 range.
	var/good_age_max = 50

	for(i in player_list) //Get all players who are ready.
		M = i
		if(istype(M) && M.ready && M.mind && !M.mind.assigned_role)
			//TODO, check if mobs are already spawned as human before this triggers.
			switch(M.client.prefs.age) //We need a weighted list for command positions.
				if(good_age_min - 5 to good_age_min - 1)	unassigned_players[M] = 35 //Too young.
				if(good_age_min     to good_age_min + 4)	unassigned_players[M] = 65 //Acceptable.
				if(good_age_min + 5 to good_age_max - 10) 	unassigned_players[M] = 100 //Perfect match.
				if(good_age_max - 9 to good_age_max + 5) 	unassigned_players[M] = 65 //Acceptable.
				if(good_age_max + 6 to good_age_max + 10) 	unassigned_players[M] = 35 //Too old.
				else 										unassigned_players[M] = 15 //Least chance.

	if(!unassigned_players.len) //If we don't have any players, the round can't start.
		unassigned_players = null
		return
	unassigned_players = shuffle(unassigned_players, 1) //Shuffle the players.

	/*===============================================================*/

/*
	//===============================================================\\
	Gathering feedback about the roles chosen.

	var/level1 = 0 //high
	var/level2 = 0 //medium
	var/level3 = 0 //low
	var/level4 = 0 //never
	var/level5 = 0 //banned
	var/level6 = 0 //account too young
	var/feedback
	var/l = 0

	for(i in occupations_by_name)
		J = occupations_by_name[i]
		feedback = "|[J.title]|"

		for(m in unassigned_players)
			M = m
			if(jobban_isbanned(M, J.title))
				level5++
				continue
			if(!J.player_old_enough(M.client))
				level6++
				continue
			if(player.client.prefs.GetJobDepartment(job, 1) & J.flag) level1++
			else if(player.client.prefs.GetJobDepartment(job, 2) & J.flag) level2++
			else if(player.client.prefs.GetJobDepartment(job, 3) & J.flag) level3++
			else level4++ //not selected

		feedback += "HIGH=[level1]|MEDIUM=[level2]|LOW=[level3]|NEVER=[level4]|BANNED=[level5]|YOUNG=[level6]|-"
		feedback_add_details("job_preferences",feedback)


*/

	//===============================================================\\
	//PART III: Here we're doing the main body of the loop and assigning everyone.

	var/l = 0 //levels

	while(++l < 4) //Three macro loops, from high to low.
		assign_initial_roles(l, roles_command, 1) //Do command positions first.
		roles_regular = assign_initial_roles(l, roles_regular) //The regular positions. We keep our unassigned pool between calls.

	for(i in unassigned_players)
		M = i
		switch(M.client.prefs.alternate_option)
			if(GET_RANDOM_JOB) 	roles_regular = assign_random_role(M, roles_regular) //We want to keep the list between assignments.
			if(BE_ASSISTANT)	assign_role(M, roles_for_mode["Squad Marine"]) //Should always be available, in all game modes, as a candidate. Even if it may not be a marine.
			if(RETURN_TO_LOBBY) M.ready = 0
		unassigned_players -= M
	if(unassigned_players.len)
		world << "<span class='debug'>Error setting up jobs, unassigned_players still has players left. Length of: [unassigned_players.len].</span>"
		log_debug("Error setting up jobs, unassigned_players still has players left. Length of: [unassigned_players.len].")

	unassigned_players = null

	/*===============================================================*/

/*
It is possible that after looping through everyone, no one is assigned a command position
despite having it selected. This is going to be rare, but it can still happen.
After much thought, I believe this is intended behavior, because even if a player
wants to play a command position, but their character doesn't fit the guidelines, more suited
candidates should have a better shot at it first. Should that fail, they can still late join.
More or less the point of this system, and it will safeguard new players from getting command
roles willy nilly.
*/

/datum/authority/branch/role/proc/assign_initial_roles(l, list/roles_to_iterate, weighted)
	. = roles_to_iterate
	if(roles_to_iterate.len && unassigned_players.len)
		var/j
		var/m
		var/datum/job/J
		var/mob/new_player/M
		//var/P

		for(j in roles_to_iterate)
			J = roles_to_iterate[j]
			if(!istype(J)) //Shouldn't happen, but who knows.
				world << "<span class='debug'>Error setting up jobs, no job datum set for: [j].</span>"
				log_debug("Error setting up jobs, no job datum set for: [j].")
				continue

			for(m in unassigned_players)
				M = m
				if( !(M.client.prefs.GetJobDepartment(J, l) & J.flag) ) continue //If they don't want the job. //TODO Change the name of the prefs proc?
				//P = weighted && !(J.flags_startup_parameters & ROLE_WHITELISTED) ? unassigned_players[M] : 100 //Whitelists have no age requirement.
				//if(prob(P) && assign_role(M, J))
				if(assign_role(M, J))
					unassigned_players -= M
					if(J.current_positions >= J.spawn_positions)
						roles_to_iterate -= j //Remove the position, since we no longer need it.
						break //Maximum position is reached?
			if(!unassigned_players.len) break //No players left to assign? Break.


/datum/authority/branch/role/proc/assign_random_role(mob/new_player/M, list/roles_to_iterate) //In case we want to pass on a list.
	. = roles_to_iterate
	if(roles_to_iterate.len)
		var/datum/job/J
		var/i = 0
		var/j
		while(++i < 3) //Get two passes.
			if(!roles_to_iterate.len || prob(65)) break //Base chance to become a marine when being assigned randomly, or there are no roles available.
			j = pick(roles_to_iterate)
			J = roles_to_iterate[j]

			if(!istype(J))
				world << "<span class='debug'>Error setting up jobs, no job datum set for: [j].</span>"
				log_debug("Error setting up jobs, no job datum set for: [j].")
				continue

			if(assign_role(M, J)) //Check to see if they can actually get it.
				if(J.current_positions >= J.spawn_positions) roles_to_iterate -= j
				return roles_to_iterate

	//If they fail the two passes, or no regular roles are available, they become a marine regardless.
	assign_role(M,roles_for_mode["Squad Marine"])

/datum/authority/branch/role/proc/assign_role(mob/new_player/M, datum/job/J, latejoin=0)
	if(ismob(M) && M.mind && istype(J))
		if(check_role_entry(M, J, latejoin))
			M.mind.assigned_role 		= J.title
			M.mind.set_cm_skills(J.skills_type)
			M.mind.special_role 		= J.special_role
			M.mind.role_alt_title 		= J.get_alternative_title(M)
			M.mind.role_comm_title 		= J.comm_title
			J.current_positions++
			//world << "[J.title]: [J.current_positions] current positions filled." //TODO DEBUG
			return 1

/datum/authority/branch/role/proc/check_role_entry(mob/new_player/M, datum/job/J, latejoin=0)
	if(jobban_isbanned(M, J.title)) return //TODO standardize this
	if(!J.player_old_enough(M.client)) return
	if(J.flags_startup_parameters & ROLE_WHITELISTED && !(roles_whitelist[M.ckey] & J.flags_whitelist)) return
	if(J.total_positions != -1 && J.get_total_positions(latejoin) <= J.current_positions) return
	return 1

/datum/authority/branch/role/proc/free_role(datum/job/J, latejoin = 1) //Want to make sure it's a job, and nothing like a MODE or special role.
	if(istype(J) && J.total_positions != -1 && J.get_total_positions(latejoin) <= J.current_positions)
		J.current_positions--
		return 1

//I'm not entirely sure why this proc exists. //TODO Figure this out.
/datum/authority/branch/role/proc/reset_roles()
	var/mob/new_player/M
	var/i
	for(i in player_list)
		M = i
		if(istype(M) && M.mind)
			M.mind.assigned_role = null
			M.mind.special_role = null
	//setup_roles() //TODO Why is this here?



/*
	proc/FillAIPosition()
		var/ai_selected = 0
		var/datum/job/job = GetJob("AI")
		if(!job)	return 0
		if((job.title == "AI") && (config) && (!config.allow_ai))	return 0

		for(var/i = job.total_positions, i > 0, i--)
			for(var/level = 1 to 3)
				var/list/candidates = list()
				if(ticker.mode.name == "AI malfunction")//Make sure they want to malf if its malf
//					candidates = FindOccupationCandidates(job, level, BE_MALF)
				else
					candidates = FindOccupationCandidates(job, level)
				if(candidates.len)
					var/mob/new_player/candidate = pick(candidates)
					if(AssignRole(candidate, "AI"))
						ai_selected++
						break
			//Malf NEEDS an AI so force one if we didn't get a player who wanted it
			if((ticker.mode.name == "AI malfunction")&&(!ai_selected))
				unassigned_players = shuffle(unassigned_players)
				for(var/mob/new_player/player in unassigned_players)
					if(jobban_isbanned(player, "AI"))	continue
					if(AssignRole(player, "AI"))
						ai_selected++
						break
			if(ai_selected)	return 1
			return 0
*/

/datum/authority/branch/role/proc/equip_role(mob/living/M, datum/job/J, turf/late_join)
	if(!istype(M) || !istype(J)) return

	J.equip(M) //Equip them with the base job gear.

	//If they didn't join late, we want to move them to the start position for their role.
	if(late_join) M.loc = late_join //If they late joined, we passed on the location from the parent proc.
	else //If they didn't, we need to find a suitable spawn location for them.
		var/i
		var/obj/effect/landmark/L //To iterate.
		var/obj/effect/landmark/S //Starting mark.
		for(i in landmarks_list)
			L = i
			if(L.name == J.title && !locate(/mob/living) in L.loc)
				S = L
				break
		if(!S) S = locate("start*[J.title]") //Old type spawn.
		if(istype(S) && istype(S.loc, /turf)) M.loc = S.loc
		else
			world << "<span class='debug'>Error setting up character. No spawn location could be found.</span>"
			log_debug("Error setting up character. No spawn location could be found.")

	if(ishuman(M))
		var/mob/living/carbon/H = M
		J.equip_preference_gear(H) //After we move them, we want to equip anything else they should have.
		H.job = J.title //TODO Why is this a mob variable at all?

		//Give them an account in the database.
		var/datum/money_account/A = create_account(H.real_name, rand(50,500)*10, null)
		if(H.mind)
			var/remembered_info = ""
			remembered_info += "<b>Your account number is:</b> #[A.account_number]<br>"
			remembered_info += "<b>Your account pin is:</b> [A.remote_access_pin]<br>"
			remembered_info += "<b>Your account funds are:</b> $[A.money]<br>"

			if(A.transaction_log.len)
				var/datum/transaction/T = A.transaction_log[1]
				remembered_info += "<b>Your account was created:</b> [T.time], [T.date] at [T.source_terminal]<br>"
			H.mind.store_memory(remembered_info)
			H.mind.initial_account = A

			// If they're head, give them the account info for their department
			if(J.head_position)
				remembered_info = ""
				var/datum/money_account/department_account = department_accounts[J.department]

				if(department_account)
					remembered_info += "<b>Your department's account number is:</b> #[department_account.account_number]<br>"
					remembered_info += "<b>Your department's account pin is:</b> [department_account.remote_access_pin]<br>"
					remembered_info += "<b>Your department's account funds are:</b> $[department_account.money]<br>"

				H.mind.store_memory(remembered_info)

		/*var/alt_title
		if(H.mind)
			H.mind.assigned_role = J.title
			alt_title = H.mind.role_alt_title*/ //TODO What is this for again?

		J.equip_identification(H, J)

		if(J.flags_startup_parameters & ROLE_ADD_TO_SQUAD) //Are we a muhreen? Randomize our squad. This should go AFTER IDs. //TODO Robust this later.
			randomize_squad(H)

		J.announce_entry_message(H, A) //Tell them their spawn info.
		J.generate_entry_conditions(H) //Do any other thing that relates to their spawn.

		H.sec_hud_set_ID()
		H.sec_hud_set_implants()
		H.hud_set_special_role()
		H.hud_set_squad()

	return 1

//Find which squad has the least population. If all 4 squads are equal it should just use a random one
/datum/authority/branch/role/proc/get_lowest_squad(mob/living/carbon/human/H)
	if(!squads.len) //Something went wrong, our squads aren't set up.
		world << "Warning, something messed up in get_lowest_squad(). No squads set up!"
		return null


	//we make a list of squad that is randomized so alpha isn't always lowest squad.
	var/list/squads_copy = squads.Copy()
	var/list/mixed_squads = list()
	for(var/i= 1 to squads_copy.len)
		mixed_squads += pick_n_take(squads_copy)

	var/datum/squad/lowest = pick(squads)

	var/datum/pref_squad_name
	if(H && H.client && H.client.prefs.preferred_squad && H.client.prefs.preferred_squad != "None")
		pref_squad_name = H.client.prefs.preferred_squad

	for(var/datum/squad/L in squads)
		if(L.usable)
			if(pref_squad_name && L.name == pref_squad_name)
				lowest = L
				break


	if(!lowest)
		world << "Warning! Bug in get_random_squad()!"
		return null

	var/lowest_count = lowest.count
	var/current_count = 0

	if(!pref_squad_name)
		//Loop through squads.
		for(var/datum/squad/S in mixed_squads)
			if(!S)
				world << "Warning: Null squad in get_lowest_squad. Call a coder!"
				break //null squad somehow, let's just abort
			current_count = S.count //Grab our current squad's #
			if(current_count >= (lowest_count - 2)) //Current squad count is not much lower than the chosen one. Skip it.
				continue
			lowest_count = current_count //We found a winner! This squad is much lower than our default. Make it the new default.
			lowest = S //'Select' this squad.

	return lowest //Return whichever squad won the competition.

//This proc is a bit of a misnomer, since there's no actual randomization going on.
/datum/authority/branch/role/proc/randomize_squad(var/mob/living/carbon/human/H)
	if(!H || !H.mind) return

	if(!squads.len)
		H << "Something went wrong with your squad randomizer! Tell a coder!"
		return //Shit, where's our squad data

	if(H.assigned_squad) //Wait, we already have a squad. Get outta here!
		return

	//we make a list of squad that is randomized so alpha isn't always lowest squad.
	var/list/squads_copy = squads.Copy()
	var/list/mixed_squads = list()
	for(var/i= 1 to squads_copy.len)
		mixed_squads += pick_n_take(squads_copy)

	//Deal with non-standards first.
	//Non-standards are distributed regardless of squad population.
	//If the number of available positions for the job are more than max_whatever, it will break.
	//Ie. 8 squad medic jobs should be available, and total medics in squads should be 8.
	if(H.mind.assigned_role != "Squad Marine")
		var/pref_squad_name
		if(H && H.client && H.client.prefs.preferred_squad && H.client.prefs.preferred_squad != "None")
			pref_squad_name = H.client.prefs.preferred_squad

		var/datum/squad/lowest

		switch(H.mind.assigned_role)
			if("Squad Engineer")
				for(var/datum/squad/S in mixed_squads)
					if(S.usable)
						if(S.num_engineers >= S.max_engineers) continue
						if(pref_squad_name && S.name == pref_squad_name)
							S.put_marine_in_squad(H) //fav squad has a spot for us, no more searching needed.
							return

						if(!lowest)
							lowest = S
						else if(S.num_engineers < lowest.num_engineers)
							lowest = S

			if("Squad Medic")
				for(var/datum/squad/S in mixed_squads)
					if(S.usable)
						if(S.num_medics >= S.max_medics) continue
						if(pref_squad_name && S.name == pref_squad_name)
							S.put_marine_in_squad(H) //fav squad has a spot for us.
							return

						if(!lowest)
							lowest = S
						else if(S.num_medics < lowest.num_medics)
							lowest = S

			if("Squad Leader")
				for(var/datum/squad/S in mixed_squads)
					if(S.usable)
						if(S.num_leaders >= S.max_leaders) continue
						if(pref_squad_name && S.name == pref_squad_name)
							S.put_marine_in_squad(H) //fav squad has a spot for us.
							return

						if(!lowest)
							lowest = S
						else if(S.num_leaders < lowest.num_leaders)
							lowest = S

			if("Squad Specialist")
				for(var/datum/squad/S in mixed_squads)
					if(S.usable)
						if(S.num_specialists >= S.max_specialists) continue
						if(pref_squad_name && S.name == pref_squad_name)
							S.put_marine_in_squad(H) //fav squad has a spot for us.
							return

						if(!lowest)
							lowest = S
						else if(S.num_specialists < lowest.num_specialists)
							lowest = S

			if("Squad Smartgunner")
				for(var/datum/squad/S in mixed_squads)
					if(S.usable)
						if(S.num_smartgun >= S.max_smartgun) continue
						if(pref_squad_name && S.name == pref_squad_name)
							S.put_marine_in_squad(H) //fav squad has a spot for us.
							return

						if(!lowest)
							lowest = S
						else if(S.num_smartgun < lowest.num_smartgun)
							lowest = S

		if(lowest)	lowest.put_marine_in_squad(H)
		else H << "Something went badly with randomize_squad()! Tell a coder!"

	else
		//Deal with marines. They get distributed to the lowest populated squad.
		var/datum/squad/given_squad = get_lowest_squad(H)
		if(!given_squad || !istype(given_squad)) //Something went horribly wrong!
			H << "Something went wrong with randomize_squad()! Tell a coder!"
			return
		given_squad.put_marine_in_squad(H) //Found one, finish up
