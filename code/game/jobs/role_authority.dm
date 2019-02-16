/*
How this works:
Role Authority handles the creation and assignment of roles. What is a role? Currently all roles are handled through job datums. If a gamemode requires
non-human roles to be spawned, it implements a separate logic that handles minds differently so they are not affected by this.
Role Authority creates some master lists on New() depending on what we want to use them for.
The title of a role is important and is a unique identifier. Two roles can share the same title, but it's really
the same role, just with different equipment, spawn conditions, or something along those lines. The title is there to tell the job ban system
which roles to ban, and it does so through the roles_by_name master list.

When a round starts, the roles are assigned based on the round, from another list. This is done to make sure that both the master list of roles
by name can be kept for things like job bans, while the round may add or remove roles as needed.If you need to equip a mob for a job, always
use roles_by_equipment or roles_by_equipment_paths as it is an accurate account of every specific role path (with specific equipment).
*/
var/global/datum/authority/branch/role/RoleAuthority


#define GET_RANDOM_JOB 0
#define BE_MARINE 1
#define RETURN_TO_LOBBY 2


/datum/authority/branch/role
	name = "Role Authority"

	var/list/roles_by_path = list() //ALL roles by their path.
	var/list/roles_by_name = list() //ALL roles by their name.
	var/list/roles_by_name_paths = list() //Same index as above, useful for easily picking from it.
	var/list/roles_by_equipment = list() //Only those roles that contain equipment. Defined by the job datum `equipment` variable.
	var/list/roles_by_equipment_paths = list() //Same index as above, useful for easily picking from it.
	var/list/roles_for_mode = list() //Derived list of roles only for the game mode, generated when the round starts.
	var/list/roles_whitelist = list() //Associated list of lists, by ckey. Checks to see if a person is whitelisted for a specific role.

	var/list/unassigned_players = list()
	var/list/squads = list() //The squads themselves.
	var/list/squads_names = list() //Same index as above, useful for searching and picking.


/datum/authority/branch/role/New()
	var/list/roles_all = subtypesof(/datum/job)
	var/list/squads_all = subtypesof(/datum/squad)

	if(!length(roles_all))
		log_game("ERROR: No job datums found.")
		message_admins("ERROR: No job datums found.")
		return

	if(!length(squads_all))
		log_game("ERROR: No squad datums found.")
		message_admins("ERROR: No squad datums found.")
		return

	roles_by_path 	         = new
	roles_by_name 	         = new
	roles_by_name_paths      = new
	roles_by_equipment 	     = new
	roles_by_equipment_paths = new
	roles_for_mode           = new
	roles_whitelist          = new
	squads 			         = new
	squads_names             = new

	var/list/L = new
	var/datum/job/J
	var/datum/squad/S

	for(var/i in roles_all) //Setting up our roles.
		J = new i

		roles_by_path[J.type] = J


		if(J.flags_startup_parameters & ROLE_ADD_TO_MODE)
			if(J.title)
				roles_for_mode[J.title] = J

		if(J.flags_startup_parameters & ROLE_ADD_TO_DEFAULT)
			if(J.title)
				roles_by_name[J.title] = J
				roles_by_name_paths[J.type] = J
			if(J.equipment)
				if(J.title)
					roles_by_equipment[J.title] = J
					roles_by_equipment_paths[J.type] = J
				else if(J.disp_title)
					roles_by_equipment[J.disp_title] = J
					roles_by_equipment_paths[J.type] = J
				


/*
Unless a gamemode re-defines the jobs for that specific mode, this assures the preference menu will only contain the "default" roles, also
sorts them out by their department.
*/

	for(var/i in ROLES_REGULAR_ALL)
		J = roles_for_mode[i]
		if(!J)
			continue
		L[J.title] = J

	roles_for_mode = L


	for(var/i in squads_all) //Setting up our squads.
		S = new i()
		squads += S
		squads_names[S.name] = S

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
		if(!i)
			continue
		i = trim(i)
		if(!length(i))
			continue
		else if(copytext(i, 1, 2) == "#")
			continue

		P = text2list(i, "+")
		if(!P.len)
			continue
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


/datum/authority/branch/role/proc/setup_candidates_and_roles()
	if(!roles_for_mode || !length(roles_for_mode))
		return

	var/datum/job/J
	var/datum/game_mode/G = SSticker.mode

	//Each gamemode can define what to do with their roles if anything special is necessary.
	switch(G.role_instruction)
		if(ROLE_MODE_REPLACE)
			roles_for_mode = new
			for(var/i in G.roles_for_mode)
				J = roles_by_path[i]
				roles_for_mode[J.title] = J
		if(ROLE_MODE_ADD)
			for(var/i in G.roles_for_mode)
				J = roles_by_path[i]
				roles_for_mode[J.title] = J
		if(ROLE_MODE_SUBTRACT)
			for(var/i in G.roles_for_mode)
				J = roles_by_path[i]
				roles_for_mode -= J.title

	var/roles[] = roles_for_mode


	if(length(roles))
		roles = shuffle(roles, 1) //Shuffle our job lists for when we begin the loop.



	//Setting up our player variables and lists, to see if we have anyone to distribute.
	unassigned_players = new
	var/mob/new_player/M

	for(var/i in GLOB.player_list) //Get all players who are ready.
		M = i
		if(istype(M) && M.ready && M.mind && !M.mind.assigned_role)
			unassigned_players += M

	if(!length(unassigned_players)) //If we don't have any players, the round can't start.
		unassigned_players = null
		return

	unassigned_players = shuffle(unassigned_players, 1) //Shuffle the players.


	for(var/l = 1 to 3) //Here we're doing the main body of the loop and assigning everyone. This is done on three macro levels.
		roles = assign_initial_roles(l, roles)

	for(var/i in unassigned_players)
		M = i
		switch(M.client.prefs.alternate_option)
			if(GET_RANDOM_JOB)
				roles = assign_random_role(M, roles) //We want to keep the list between assignments.
			if(BE_MARINE)
				assign_role(M, roles_by_name["Squad Marine"])
			if(RETURN_TO_LOBBY)
				M.ready = 0
		unassigned_players -= M

	if(length(unassigned_players))
		log_game("ERROR: There are still [length(unassigned_players)] unassigned players.")
		message_admins("ERROR: There are still [length(unassigned_players)] unassigned players.")

	unassigned_players = null

	for(var/datum/squad/S in squads)
		S.num_engineers = initial(S.num_engineers)
		S.num_medics = initial(S.num_medics)
		S.num_smartgun = initial(S.num_smartgun)
		S.num_specialists = initial(S.num_specialists)
		S.num_leaders = initial(S.num_leaders)


/datum/authority/branch/role/proc/assign_initial_roles(l, list/roles_to_iterate)
	. = roles_to_iterate

	if(length(roles_to_iterate) && length(unassigned_players))
		var/j
		var/m
		var/datum/job/J
		var/mob/new_player/M

		for(j in roles_to_iterate)
			J = roles_to_iterate[j]
			if(!istype(J))
				log_game("ERROR: No job datum found for [J] while assigning initial roles.")
				message_admins("ERROR: No job datum found for [J] while assigning initial roles.")
				continue

			for(m in unassigned_players)
				M = m
				if(!(M.client.prefs.GetJobDepartment(J, l) & J.flag)) //Check if they want this job.
					continue

				if(assign_role(M, J))
					unassigned_players -= M
					if(J.current_positions >= J.spawn_positions)
						roles_to_iterate -= j //Remove the position, since we no longer need it.
						break

			if(!length(unassigned_players))
				break

/datum/authority/branch/role/proc/assign_random_role(mob/new_player/M, list/roles_to_iterate) //In case we want to pass on a list.
	. = roles_to_iterate
	if(roles_to_iterate.len)
		var/datum/job/J
		var/j

		if(!length(roles_to_iterate)) //No more free roles, make them a marine.
			if(assign_role(M, roles_by_name["Squad Marine"]))
				return roles_to_iterate

		j = pick(roles_to_iterate)
		J = roles_to_iterate[j]

		if(!istype(J))
			log_game("ERROR: No job datum found for [J] while assigning random role.")
			message_admins("ERROR: No job datum found for [J] while assigning random role.")
			if(assign_role(M, roles_by_name["Squad Marine"]))
				return roles_to_iterate

		if(assign_role(M, J)) //Check to see if they can actually get it.
			if(J.current_positions >= J.spawn_positions)
				roles_to_iterate -= j
			return roles_to_iterate
		else if(assign_role(M, roles_by_name["Squad Marine"]))
			return roles_to_iterate
		else
			log_game("ERROR: Failed to assign random role to [key_name(M)].")
			message_admins("ERROR: Failed to assign random role to [ADMIN_TPMONTY(M)].")
			return roles_to_iterate
	


/datum/authority/branch/role/proc/assign_role(mob/new_player/M, datum/job/J, latejoin = 0)
	if(!ismob(M) || !M.mind || !istype(J))
		return FALSE

	if(check_role_entry(M, J, latejoin))
		M.set_everything(M, J.title)
		if(J.flags_startup_parameters & ROLE_ADD_TO_SQUAD) //Handle their squad preferences.
			if(!handle_squad(M))
				return FALSE
		J.current_positions++
		return TRUE


/datum/authority/branch/role/proc/check_role_entry(mob/new_player/M, datum/job/J, latejoin = 0)
	if(jobban_isbanned(M, J.title))
		return FALSE
	if(!J.player_old_enough(M.client))
		return FALSE
	if(J.flags_startup_parameters & ROLE_WHITELISTED && !(roles_whitelist[M.ckey] & J.flags_whitelist))
		return FALSE
	if(J.total_positions != -1 && J.get_total_positions(latejoin) <= J.current_positions)
		return FALSE
	return TRUE


/datum/authority/branch/role/proc/free_role(datum/job/J, latejoin = 1)
	if(istype(J) && J.total_positions != -1 && J.get_total_positions(latejoin) <= J.current_positions)
		J.current_positions--
		return TRUE


//This proc exists if a start of the round fails so everything can be reset before new rolls are made.
/datum/authority/branch/role/proc/reset_roles()
	var/mob/new_player/M
	var/i
	for(i in GLOB.player_list)
		M = i
		if(istype(M) && M.mind)
			M.mind.assigned_role = null
			M.mind.special_role = null


/datum/authority/branch/role/proc/equip_role(mob/living/M, datum/job/J, turf/late_join)
	if(!istype(M) || !istype(J))
		return

	//Sets their equipment to the equivalent job datum.
	J.generate_equipment(M)

	if(late_join) //If they late joined, we put them in cryo.
		M.loc = late_join
	else
		var/turf/T
		if(GLOB.marine_spawns_by_job[J.type]?.len)
			T = pick(GLOB.marine_spawns_by_job[J.type])
		if(isturf(T))
			M.forceMove(T)
		else
			log_game("ERROR: No spawn location found for player [key_name(M)], job [J].")
			message_admins("ERROR: No spawn location found for player [ADMIN_TPMONTY(M)], job [J].")

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		J.equip_preference_gear(H) //After we move them, we want to equip their special gear.

		//Give them an account in the database.
		var/datum/money_account/A = create_account(H.real_name, rand(50,500)*10, null)
		if(H.mind)
			var/remembered_info = ""
			remembered_info += "<b>Your account number is:</b> #[A.account_number]<br>"
			remembered_info += "<b>Your account pin is:</b> [A.remote_access_pin]<br>"
			remembered_info += "<b>Your account funds are:</b> $[A.money]<br>"

			if(length(A.transaction_log))
				var/datum/transaction/T = A.transaction_log[1]
				remembered_info += "<b>Your account was created:</b> [T.time], [T.date] at [T.source_terminal]<br>"
			H.mind.store_memory(remembered_info)
			H.mind.initial_account = A

		J.equip_identification(H, J)

		if(J.flags_startup_parameters & ROLE_ADD_TO_SQUAD) //Add them to their chosen squad.
			var/datum/squad/S = H.mind.assigned_squad
			S.put_marine_in_squad(H)

		J.announce_entry_message(H, A) //Tell them their spawn info.
		J.generate_entry_conditions(H) //Do any other thing that relates to their spawn.

		H.sec_hud_set_ID()
		H.sec_hud_set_implants()
		H.hud_set_special_role()
		H.hud_set_squad()

	return TRUE


/datum/authority/branch/role/proc/handle_squad(var/mob/new_player/M)
	if(!M?.mind)
		return FALSE

	var/datum/squad/R = squads_names[pick(squads_names)]
	var/datum/squad/P
	var/strict = FALSE

	if(M.client?.prefs?.preferred_squad && M.client.prefs.preferred_squad != "None")
		P = squads_names[M.client.prefs.preferred_squad]

	if(M.client?.prefs?.be_special & BE_SQUAD_STRICT)
		strict = TRUE

	switch(M.mind.assigned_role)
		if("Squad Marine") //Always put squad marines in their preferred squad if possible.
			if(P)
				M.mind.assigned_squad = P
			else
				M.mind.assigned_squad = R
			return TRUE

		if("Squad Engineer")
			for(var/datum/squad/S in shuffle(squads))
				if(S.num_engineers >= S.max_engineers)
					continue

				if(P && P == S)
					M.mind.assigned_squad = P
					S.num_engineers++
					return TRUE

			if(strict)
				return FALSE
					
			for(var/datum/squad/S in shuffle(squads))
				if(S.num_engineers >= S.max_engineers)
					continue

				else
					M.mind.assigned_squad = S
					S.num_engineers++
					return TRUE

			return FALSE

		if("Squad Medic")
			for(var/datum/squad/S in shuffle(squads))
				if(S.num_medics >= S.max_medics)
					continue

				if(P && P == S)
					M.mind.assigned_squad = P
					S.num_medics++
					return TRUE

			if(strict)
				return FALSE
					
			for(var/datum/squad/S in shuffle(squads))
				if(S.num_medics >= S.max_medics)
					continue
				else
					M.mind.assigned_squad = S
					S.num_medics++
					return TRUE
						
			return FALSE

		if("Squad Smartgunner")
			for(var/datum/squad/S in shuffle(squads))
				if(S.num_smartgun >= S.max_smartgun)
					continue

				if(P && P == S)
					M.mind.assigned_squad = P
					S.num_smartgun++
					return TRUE

			if(strict)
				return FALSE
					
			for(var/datum/squad/S in shuffle(squads))
				if(S.num_smartgun >= S.max_smartgun)
					continue
				else
					M.mind.assigned_squad = S
					S.num_smartgun++
					return TRUE
						
			return FALSE

		if("Squad Specialist")
			for(var/datum/squad/S in shuffle(squads))
				if(S.num_specialists >= S.max_specialists)
					continue

				if(P && P == S)
					M.mind.assigned_squad = P
					S.num_specialists++
					return TRUE

			if(strict)
				return FALSE
					
			for(var/datum/squad/S in shuffle(squads))
				if(S.num_specialists >= S.max_specialists)
					continue
				else
					M.mind.assigned_squad = S
					S.num_specialists++
					return TRUE
						
			return FALSE

		if("Squad Leader")
			for(var/datum/squad/S in shuffle(squads))
				if(S.num_leaders >= S.max_leaders)
					continue

				if(P && P == S)
					M.mind.assigned_squad = P
					S.num_leaders++
					return TRUE

			if(strict)
				return FALSE
					
			for(var/datum/squad/S in shuffle(squads))
				if(S.num_leaders >= S.max_leaders)
					continue
				else
					M.mind.assigned_squad = S
					S.num_leaders++
					return TRUE
						
			return FALSE

	log_game("ERROR: Could not assign squad for [key_name(M)].")
	message_admins("ERROR: Could not assign squad for [ADMIN_TPMONTY(M)].")
	return FALSE