SUBSYSTEM_DEF(job)
	name = "Jobs"
	init_order = INIT_ORDER_JOBS
	flags = SS_NO_FIRE
	var/ssjob_flags = NONE

	var/list/occupations = list() //List of all jobs.
	var/list/joinable_occupations = list() //List of jobs that can be joined as through the lobby.
	var/list/joinable_occupations_by_category = list()
	var/list/active_occupations = list() //Jobs in use by the game mode at roundstart.
	var/list/active_joinable_occupations = list() //Jobs currently joineable through the lobby (roundstart-only removed after).
	var/list/active_joinable_occupations_by_category = list()
	var/list/datum/job/name_occupations = list()	//Dict of all jobs, keys are titles.
	var/list/type_occupations = list()	//Dict of all jobs, keys are types.

	var/list/squads = list()			//List of potential squads.
	///Assoc list of all joinable squads, categorised by faction
	var/list/active_squads = list()
	///assoc list of squad_name_string->squad_reference for easy lookup, categorised in factions
	var/list/squads_by_name = list()

	var/list/unassigned = list()		//Players who need jobs.
	var/list/occupations_reroll //Jobs scaled up during job assignments.
	var/initial_players_assigned = 0 	//Used for checking against population caps.

	var/datum/job/overflow_role = /datum/job/terragov/squad/standard


/datum/controller/subsystem/job/Initialize()
	SetupOccupations()
	overflow_role = GetJobType(overflow_role)
	return SS_INIT_SUCCESS


/datum/controller/subsystem/job/proc/SetupOccupations()
	occupations.Cut()
	joinable_occupations.Cut()
	GLOB.jobs_command.Cut()
	squads.Cut()
	var/list/all_jobs = subtypesof(/datum/job)
	var/list/all_squads = subtypesof(/datum/squad)
	if(!length(all_jobs))
		to_chat(world, span_boldnotice("Error setting up jobs, no job datums found"))
		return FALSE

	for(var/J in all_jobs)
		var/datum/job/job = new J()
		if(!job)
			continue
		if(!job.config_check())
			continue
		if(!job.map_check())
			continue
		occupations += job
		name_occupations[job.title] = job
		type_occupations[J] = job
	sortTim(occupations, GLOBAL_PROC_REF(cmp_job_display_asc))

	for(var/j in occupations)
		var/datum/job/job = j
		if(job.job_flags & (JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE))
			joinable_occupations += job
			joinable_occupations_by_category[job.job_category] += list(job)
		if(job.job_flags & JOB_FLAG_ISCOMMAND)
			GLOB.jobs_command[job.title] = job

	for(var/S in all_squads)
		var/datum/squad/squad = new S()
		if(!squad)
			continue
		squads[squad.id] = squad
		LAZYSET(squads_by_name[squad.faction], squad.name, squad)
	return TRUE


/datum/controller/subsystem/job/proc/GetJob(rank)
	if(!length(occupations))
		CRASH("GetJob called with no occupations")
	return name_occupations[rank]


/datum/controller/subsystem/job/proc/GetJobType(jobtype)
	if(!length(occupations))
		CRASH("GetJobType called with no occupations")
	return type_occupations[jobtype]


/datum/controller/subsystem/job/proc/AssignRole(mob/new_player/player, datum/job/job, latejoin = FALSE)
	if(!job)
		JobDebug("AR job doesn't exist! Player: [player], Job: [job]")
		return FALSE
	JobDebug("Running AR, Player: [player], Job: [job.title], LJ: [latejoin]")
	if(!player.IsJobAvailable(job))
		return FALSE
	if(is_banned_from(player.ckey, job.title))
		JobDebug("AR isbanned failed, Player: [player], Job:[job.title]")
		return FALSE
	if(QDELETED(player))
		JobDebug("AR player deleted during job ban check")
		return FALSE
	if(!job.player_old_enough(player.client))
		JobDebug("AR player not old enough, Player: [player], Job:[job.title]")
		return FALSE
	if(ismarinejob(job) || issommarinejob(job))
		if(!handle_initial_squad(player, job, latejoin, job.faction))
			JobDebug("Failed to assign marine role to a squad. Player: [player.key] Job: [job.title]")
			return FALSE
		JobDebug("Successfuly assigned marine role to a squad. Player: [player.key], Job: [job.title], Squad: [player.assigned_squad]")
	if(!latejoin)
		unassigned -= player
	if(job.job_category != JOB_CAT_XENO && !GLOB.joined_player_list.Find(player.ckey))
		SSpoints.supply_points[job.faction] += SUPPLY_POINT_MARINE_SPAWN
	job.occupy_job_positions(1, GLOB.joined_player_list.Find(player.ckey))
	player.mind?.assigned_role = job
	player.assigned_role = job
	JobDebug("Player: [player] is now Job: [job.title], JCP:[job.current_positions], JPL:[job.total_positions]")
	return TRUE

/datum/controller/subsystem/job/proc/GiveRandomJob(mob/new_player/player)
	JobDebug("GRJ Giving random job, Player: [player]")
	. = FALSE
	for(var/j in shuffle(active_joinable_occupations))
		var/datum/job/job = j
		if(job.total_positions != -1 && job.current_positions >= job.total_positions)
			continue
		JobDebug("GRJ Random job given, Player: [player], Job: [job]")
		if(AssignRole(player, job))
			return TRUE

/datum/controller/subsystem/job/proc/ResetOccupations()
	JobDebug("Occupations reset.")
	for(var/p in GLOB.new_player_list)
		var/mob/new_player/player = p
		player.assigned_role = null
		player.assigned_squad = null
	SetupOccupations()
	unassigned.Cut()


/** Proc DivideOccupations
*  fills var "assigned_role" for all ready players.
*  This proc must not have any side effect besides of modifying "assigned_role".
**/
/datum/controller/subsystem/job/proc/DivideOccupations()
	//Setup new player list and get the jobs list
	JobDebug("Running DO")
	//Get the players who are ready
	unassigned.Cut()
	occupations_reroll = null
	for(var/p in GLOB.ready_players)
		var/mob/new_player/player = p
		if(player.assigned_role)
			continue
		unassigned += player

	initial_players_assigned += length(GLOB.ready_players)

	SSticker.mode.scale_roles()

	JobDebug("DO, Len: [length(unassigned)]")
	if(!initial_players_assigned)
		clean_roundstart_occupations()
		return FALSE


	//Jobs will use the default access unless the population is below a certain level.
	var/mat = CONFIG_GET(number/minimal_access_threshold)
	if(mat)
		if(length(unassigned) > mat)
			CONFIG_SET(flag/jobs_have_minimal_access, FALSE)
		else
			CONFIG_SET(flag/jobs_have_minimal_access, TRUE)

	//Shuffle players and jobs
	unassigned = shuffle(unassigned)

	//Other jobs are now checked
	JobDebug("DO, Running Standard Check")

	// New job giving system by Donkie
	// This will cause lots of more loops, but since it's only done once it shouldn't really matter much at all.
	// Hopefully this will add more randomness and fairness to job giving.

	// Loop through all levels from high to low
	var/list/shuffledoccupations = shuffle(active_joinable_occupations)

	for(var/level = JOBS_PRIORITY_HIGH; level >= JOBS_PRIORITY_LOW; level--)
		// Loop through all unassigned players
		assign_players_to_occupations(level, shuffledoccupations)

		if(LAZYLEN(occupations_reroll)) //Jobs that were scaled up due to the assignment of other jobs.
			for(var/reroll_level = JOBS_PRIORITY_HIGH; reroll_level >= level; reroll_level--)
				assign_players_to_occupations(reroll_level, occupations_reroll)
			occupations_reroll = null

	JobDebug("DO, Handling unassigned.")
	// Hand out random jobs to the people who didn't get any in the last check
	// Also makes sure that they got their preference correct
	for(var/p in unassigned)
		HandleUnassigned(p)

	clean_roundstart_occupations()
	return TRUE


/datum/controller/subsystem/job/proc/assign_players_to_occupations(level, list/occupations_to_assign)
	var/faction_rejected
	for(var/mob/new_player/player AS in unassigned)
		if(PopcapReached())
			RejectPlayer(player)
		//Choose a faction in advance if needed
		if(SSticker.mode?.flags_round_type & MODE_TWO_HUMAN_FACTIONS) //Alternates between the two factions
			faction_rejected = faction_rejected == FACTION_TERRAGOV ? FACTION_SOM : FACTION_TERRAGOV
		// Loop through all jobs
		for(var/datum/job/job AS in occupations_to_assign)
			// If the player wants that job on this level, then try give it to him.
			if(player.client.prefs.job_preferences[job.title] != level)
				continue
			if(job.faction == faction_rejected)
				continue
			JobDebug("DO pass, Trying to assign Player: [player], Level:[level], Job:[job.title]")
			if(AssignRole(player, job))
				break


//We couldn't find a job from prefs for this guy.
/datum/controller/subsystem/job/proc/HandleUnassigned(mob/new_player/player)
	if(PopcapReached())
		RejectPlayer(player)
		return
	switch(player.client.prefs.alternate_option)
		if(BE_OVERFLOW)
			if(!AssignRole(player, overflow_role))
				RejectPlayer(player)
			return
		if(GET_RANDOM_JOB)
			if(!GiveRandomJob(player))
				RejectPlayer(player)
			return
		if(RETURN_TO_LOBBY)
			RejectPlayer(player)
			return
	//Something gone wrong if we got here.
	var/message = "DO: [player] fell through handling unassigned"
	JobDebug(message)
	message_admins(message)
	RejectPlayer(player)


/datum/controller/subsystem/job/proc/clean_roundstart_occupations()
	if(ssjob_flags & SSJOB_OVERRIDE_JOBS_START)
		return
	for(var/j in active_joinable_occupations) //Roundstart selection is over. Remove the roundstart-only jobs.
		var/datum/job/job = j
		if(job.job_flags & JOB_FLAG_LATEJOINABLE)
			continue
		job.set_job_positions(0)


//Gives the player the stuff they should have with their rank.
/datum/controller/subsystem/job/proc/spawn_character(mob/new_player/player, joined_late = FALSE)
	var/mob/living/new_character = player.new_character
	var/datum/job/job = player.assigned_role

	new_character.apply_assigned_role_to_spawn(job, player.client, player.assigned_squad)

	//If we joined at roundstart we should be positioned at our workstation
	var/turf/spawn_turf
	if(!joined_late || job.job_flags & JOB_FLAG_OVERRIDELATEJOINSPAWN)
		spawn_turf = job.return_spawn_turf()
	if(spawn_turf)
		SendToAtom(new_character, spawn_turf)
	else
		SendToLateJoin(new_character, job)

	job.radio_help_message(player)

	job.after_spawn(new_character, player, joined_late) // note: this happens before new_character has a key!

	return new_character


/datum/controller/subsystem/job/proc/PopcapReached()
	var/hpc = CONFIG_GET(number/hard_popcap)
	var/epc = CONFIG_GET(number/extreme_popcap)
	if(hpc || epc)
		var/relevent_cap = max(hpc, epc)
		if((initial_players_assigned - length(unassigned)) >= relevent_cap)
			return TRUE
	return FALSE


/datum/controller/subsystem/job/proc/RejectPlayer(mob/new_player/player)
	if(PopcapReached())
		JobDebug("Popcap overflow Check observer located, Player: [player]")
	if(player.assigned_role)
		JobDebug("Player already assigned a role :[player]")
		unassigned -= player
		player.ready = FALSE
		GLOB.ready_players -= player
		return
	JobDebug("Player rejected :[player]")
	to_chat(player, "<b>You have failed to qualify for any job you desired.</b>")
	unassigned -= player
	player.ready = FALSE
	GLOB.ready_players -= player


/datum/controller/subsystem/job/Recover()
	set waitfor = FALSE
	var/oldjobs = SSjob.occupations
	sleep(2 SECONDS)
	for(var/datum/job/J in oldjobs)
		INVOKE_ASYNC(src, PROC_REF(RecoverJob), J)


/datum/controller/subsystem/job/proc/RecoverJob(datum/job/J)
	var/datum/job/newjob = GetJob(J.title)
	if(!istype(newjob))
		return
	newjob.total_positions = J.total_positions
	newjob.current_positions = J.current_positions


/datum/controller/subsystem/job/proc/SendToAtom(mob/M, atom/A, buckle)
	var/turf/spawn_loc = get_turf(A)
	M.forceMove(spawn_loc)
	if(buckle && isliving(M))
		var/obj/structure/bed/chair/to_sit = locate() in spawn_loc
		if(!to_sit)
			CRASH("[M] SendToAtom [A] in ([spawn_loc.x], [spawn_loc.y], [spawn_loc.z]) with no chairs to buckle in.")
		to_sit.buckle_mob(M, silent = TRUE)


/datum/controller/subsystem/job/proc/SendToLateJoin(mob/M, datum/job/assigned_role)
	switch(assigned_role.faction)
		if(FACTION_SOM)
			if(length(GLOB.latejoinsom))
				SendToAtom(M, pick(GLOB.latejoinsom))
				return
		else
			if(length(GLOB.latejoin))
				SendToAtom(M, pick(GLOB.latejoin))
				return
	message_admins("Unable to send mob [M] to late join!")
	CRASH("Unable to send mob [M] to late join!")

/datum/controller/subsystem/job/proc/JobDebug(message)
	log_job_debug(message)


/datum/controller/subsystem/job/proc/set_active_joinable_occupations_by_category()
	active_joinable_occupations_by_category.Cut()
	for(var/j in active_joinable_occupations)
		var/datum/job/job = j
		active_joinable_occupations_by_category[job.job_category] += list(job)

/datum/controller/subsystem/job/proc/add_active_occupation(datum/job/occupation)
	active_joinable_occupations += occupation
	if(length(active_joinable_occupations) > 1)
		sortTim(active_joinable_occupations, GLOBAL_PROC_REF(cmp_job_display_asc))
	active_joinable_occupations_by_category[occupation.job_category] += list(occupation)
	if(length(active_joinable_occupations_by_category[occupation.job_category]) > 1)
		sortTim(active_joinable_occupations_by_category[occupation.job_category], GLOBAL_PROC_REF(cmp_job_display_asc))

/datum/controller/subsystem/job/proc/remove_active_occupation(datum/job/occupation)
	active_joinable_occupations -= occupation
	if(active_joinable_occupations_by_category[occupation.job_category])
		active_joinable_occupations_by_category[occupation.job_category] -= occupation
		if(!length(active_joinable_occupations_by_category[occupation.job_category]))
			active_joinable_occupations_by_category -= occupation.job_category
