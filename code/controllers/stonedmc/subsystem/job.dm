SUBSYSTEM_DEF(job)
	name = "Jobs"
	init_order = INIT_ORDER_JOBS
	flags = SS_NO_FIRE

	var/list/occupations = list()		//List of all jobs.
	var/list/name_occupations = list()	//Dict of all jobs, keys are titles.
	var/list/type_occupations = list()	//Dict of all jobs, keys are types.

	var/list/squads = list()			//List of squads.

	var/list/unassigned = list()		//Players who need jobs.
	var/initial_players_to_assign = 0 	//Used for checking against population caps.

	var/list/prioritized_jobs = list()
	var/list/latejoin_trackers = list()	//Don't read this list, use GetLateJoinTurfs() instead.

	var/overflow_role = "Squad Marine"


/datum/controller/subsystem/job/Initialize(timeofday)
	if(!length(occupations))
		SetupOccupations()
	return ..()


/datum/controller/subsystem/job/proc/SetupOccupations()
	occupations = list()
	squads = list()
	var/list/all_jobs = subtypesof(/datum/job)
	var/list/all_squads = subtypesof(/datum/squad)
	if(!length(all_jobs))
		to_chat(world, "<span class='boldnotice'>Error setting up jobs, no job datums found</span>")
		return FALSE

	for(var/J in all_jobs)
		var/datum/job/job = new J()
		if(!job)
			continue
		occupations += job
		name_occupations[job.title] = job
		type_occupations[J] = job

	for(var/S in all_squads)
		var/datum/squad/squad = new S()
		if(!squad)
			continue
		squads[squad.name] = squad
	return TRUE


/datum/controller/subsystem/job/proc/GetJob(rank)
	if(!length(occupations))
		SetupOccupations()
	return name_occupations[rank]


/datum/controller/subsystem/job/proc/GetJobType(jobtype)
	if(!length(occupations))
		SetupOccupations()
	return type_occupations[jobtype]


/datum/controller/subsystem/job/proc/AssignRole(mob/new_player/player, rank, latejoin = FALSE)
	JobDebug("Running AR, Player: [player], Rank: [rank], LJ: [latejoin]")
	if(player?.mind && rank)
		var/datum/job/job = GetJob(rank)
		if(!job)
			return FALSE
		if(jobban_isbanned(player, rank) || QDELETED(player))
			return FALSE
		if(!job.player_old_enough(player.client))
			return FALSE
		if(rank in JOBS_MARINES)
			if(handle_squad(player, rank, latejoin))
				JobDebug("Successfuly assigned marine role to a squad. Player: [player.key] Rank: [rank]")
			else
				JobDebug("Failed to assign marine role to a squad. Player: [player.key] Rank: [rank]")
				return FALSE
		var/position_limit = job.total_positions
		if(!latejoin)
			position_limit = job.spawn_positions
		JobDebug("Player: [player] is now Rank: [rank], JCP:[job.current_positions], JPL:[position_limit]")
		player.mind.assigned_role = rank
		unassigned -= player
		job.current_positions++
		return TRUE
	JobDebug("AR has failed, Player: [player], Rank: [rank]")
	return FALSE


/datum/controller/subsystem/job/proc/FindOccupationCandidates(datum/job/job, level, flag)
	JobDebug("Running FOC, Job: [job], Level: [level], Flag: [flag]")
	var/list/candidates = list()
	for(var/mob/new_player/player in unassigned)
		if(jobban_isbanned(player, job.title) || QDELETED(player))
			JobDebug("FOC isbanned failed, Player: [player]")
			continue
		if(!job.player_old_enough(player.client))
			JobDebug("FOC player not old enough, Player: [player]")
			continue
		if(flag && (!(flag in player.client.prefs.be_special)))
			JobDebug("FOC flag failed, Player: [player], Flag: [flag], ")
			continue
		if(player.client.prefs.GetJobDepartment(job, level) & job.flag)
			JobDebug("FOC pass, Player: [player], Level:[level]")
			candidates += player
	return candidates


/datum/controller/subsystem/job/proc/GiveRandomJob(mob/new_player/player)
	JobDebug("GRJ Giving random job, Player: [player]")
	. = FALSE
	for(var/datum/job/job in shuffle(occupations))
		if(!job)
			continue

		if(jobban_isbanned(player, job.title) || QDELETED(player))
			if(QDELETED(player))
				JobDebug("GRJ isbanned failed, Player deleted")
				break
			JobDebug("GRJ isbanned failed, Player: [player], Job: [job.title]")
			continue

		if(!job.player_old_enough(player.client))
			JobDebug("GRJ player not old enough, Player: [player]")
			continue

		if((job.current_positions < job.spawn_positions) || job.spawn_positions == -1)
			JobDebug("GRJ Random job given, Player: [player], Job: [job]")
			if(AssignRole(player, job.title))
				return TRUE


/datum/controller/subsystem/job/proc/ResetOccupations()
	JobDebug("Occupations reset.")
	for(var/mob/new_player/player in GLOB.player_list)
		if((player) && (player.mind))
			player.mind.assigned_role = null
			player.mind.special_role = null
	SetupOccupations()
	unassigned = list()
	return


/** Proc DivideOccupations
 *  fills var "assigned_role" for all ready players.
 *  This proc must not have any side effect besides of modifying "assigned_role".
 **/
/datum/controller/subsystem/job/proc/DivideOccupations()
	//Setup new player list and get the jobs list
	JobDebug("Running DO")

	//Get the players who are ready
	for(var/mob/new_player/player in GLOB.player_list)
		if(player.ready && player.mind && !player.mind.assigned_role)
			unassigned += player

	initial_players_to_assign = length(unassigned)

	JobDebug("DO, Len: [unassigned.len]")
	if(length(unassigned) == 0)
		return FALSE

	//Shuffle players and jobs
	unassigned = shuffle(unassigned)

	//People who wants to be the overflow role, sure, go on.
	JobDebug("DO, Running Overflow Check 1")
	var/datum/job/overflow = GetJob(SSjob.overflow_role)
	var/list/overflow_candidates = FindOccupationCandidates(overflow, 3)
	JobDebug("AC1, Candidates: [length(overflow_candidates)]")
	for(var/mob/new_player/player in overflow_candidates)
		JobDebug("AC1 pass, Player: [player]")
		AssignRole(player, SSjob.overflow_role)
		overflow_candidates -= player
	JobDebug("DO, AC1 end")

	//Other jobs are now checked
	JobDebug("DO, Running Standard Check")


	// New job giving system by Donkie
	// This will cause lots of more loops, but since it's only done once it shouldn't really matter much at all.
	// Hopefully this will add more randomness and fairness to job giving.

	// Loop through all levels from high to low
	var/list/shuffledoccupations = shuffle(occupations)
	for(var/level = 1 to 3)
		//Check the head jobs first each level

		// Loop through all unassigned players
		for(var/mob/new_player/player in unassigned)

			// Loop through all jobs
			for(var/datum/job/job in shuffledoccupations) // SHUFFLE ME BABY
				if(!job)
					continue

				if(jobban_isbanned(player, job.title))
					JobDebug("DO isbanned failed, Player: [player], Job:[job.title]")
					continue

				if(QDELETED(player))
					JobDebug("DO player deleted during job ban check")
					break

				if(!job.player_old_enough(player.client))
					JobDebug("DO player not old enough, Player: [player], Job:[job.title]")
					continue

				// If the player wants that job on this level, then try give it to him.
				if(player.client.prefs.GetJobDepartment(job, level) & job.flag)
					// If the job isn't filled
					if((job.current_positions < job.spawn_positions) || job.spawn_positions == -1)
						JobDebug("DO pass, Trying to assign Player: [player], Level:[level], Job:[job.title]")
						if(AssignRole(player, job.title))
							unassigned -= player
							break


	JobDebug("DO, Handling unassigned.")
	// Hand out random jobs to the people who didn't get any in the last check
	// Also makes sure that they got their preference correct
	for(var/mob/new_player/player in unassigned)
		HandleUnassigned(player)

	JobDebug("DO, Handling unrejectable unassigned")
	//Mop up people who can't leave.
	for(var/mob/new_player/player in unassigned) //Players that wanted to back out but couldn't because they're antags (can you feel the edge case?)
		if(!GiveRandomJob(player))
			AssignRole(player, SSjob.overflow_role) //If everything is already filled, make them an assistant

	return TRUE


//We couldn't find a job from prefs for this guy.
/datum/controller/subsystem/job/proc/HandleUnassigned(mob/new_player/player)
	if(player.client.prefs.alternate_option == BE_MARINE)
		if(QDELETED(player) || jobban_isbanned(player, SSjob.overflow_role))
			RejectPlayer(player)
		else
			if(!AssignRole(player, SSjob.overflow_role))
				RejectPlayer(player)
	else if(player.client.prefs.alternate_option == GET_RANDOM_JOB)
		if(!GiveRandomJob(player))
			RejectPlayer(player)
	else if(player.client.prefs.alternate_option == RETURN_TO_LOBBY)
		RejectPlayer(player)
	else //Something gone wrong if we got here.
		var/message = "DO: [player] fell through handling unassigned"
		JobDebug(message)
		log_game(message)
		message_admins(message)
		RejectPlayer(player)


//Gives the player the stuff he should have with his rank
/datum/controller/subsystem/job/proc/EquipRank(mob/M, rank, joined_late = FALSE)
	var/mob/new_player/N
	var/mob/living/H
	if(!joined_late)
		N = M
		H = N.new_character
	else
		H = M

	var/datum/job/job = GetJob(rank)

	H.job = rank

	//If we joined at roundstart we should be positioned at our workstation
	if(!joined_late && job)
		var/turf/S
		for(var/i in GLOB.marine_spawns_by_job)
			if(i != job.type)
				continue
			S = pick(GLOB.marine_spawns_by_job[i])
			break
		if(length(GLOB.jobspawn_overrides[rank]))
			S = pick(GLOB.jobspawn_overrides[rank])
		if(S)
			SendToAtom(H, S, buckle = FALSE)
		if(!S) //if there isn't a spawnpoint send them to latejoin, if there's no latejoin go yell at your mapper
			log_world("Couldn't find a round start spawn point for [rank]")
			SendToLateJoin(H)

	if(job && H.mind)
		H.mind.assigned_role = rank
		var/new_mob = job.equip(H, null, null, joined_late , null, M.client)
		if(ismob(new_mob))
			H = new_mob
			if(!joined_late)
				N.new_character = H
			else
				M = H
		if(rank in JOBS_MARINES)
			if(H.mind.assigned_squad)
				var/datum/squad/S = H.mind.assigned_squad
				S.put_marine_in_squad(H)
			else
				JobDebug("Failed to put marine role in squad. Player: [H.key] Rank: [rank]")
	if(ishuman(H))
		//Give them an account in the database.
		var/datum/money_account/A = create_account(H.real_name, rand(50,500) * 10, null)
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
	if(job)
		job.radio_help_message(M)
		if(job.req_admin_notify)
			to_chat(M, "<span clas='danger'>You are playing a job that is important for game progression. If you have to disconnect, please head to hypersleep, if you can't make it there, notify the admins via adminhelp.</span>")
	if(job && H)
		job.after_spawn(H, M, joined_late) // note: this happens before the mob has a key! M will always have a client, H might not.

	return H


/datum/controller/subsystem/job/proc/RejectPlayer(mob/new_player/player)
	if(player.mind?.special_role)
		JobDebug("Player already assigned a special role :[player]")
		unassigned -= player
		player.ready = FALSE
		return
	if(player.mind?.assigned_role)
		JobDebug("Player already assigned a role :[player]")
		player.mind.special_role = player.mind.assigned_role
		unassigned -= player
		player.ready = FALSE
		return
	JobDebug("Player rejected :[player]")
	to_chat(player, "<b>You have failed to qualify for any job you desired.</b>")
	unassigned -= player
	player.ready = FALSE


/datum/controller/subsystem/job/Recover()
	set waitfor = FALSE
	var/oldjobs = SSjob.occupations
	sleep(20)
	for(var/datum/job/J in oldjobs)
		INVOKE_ASYNC(src, .proc/RecoverJob, J)


/datum/controller/subsystem/job/proc/RecoverJob(datum/job/J)
	var/datum/job/newjob = GetJob(J.title)
	if(!istype(newjob))
		return
	newjob.total_positions = J.total_positions
	newjob.spawn_positions = J.spawn_positions
	newjob.current_positions = J.current_positions


/datum/controller/subsystem/job/proc/SendToAtom(mob/M, atom/A, buckle)
	if(buckle && isliving(M) && istype(A, /obj/structure/bed/chair))
		var/obj/structure/bed/chair/C = A
		if(C.buckle_mob(M, M))
			return
	M.forceMove(get_turf(A))


/datum/controller/subsystem/job/proc/SendToLateJoin(mob/M, buckle = TRUE)
	if(M.mind?.assigned_role && length(GLOB.jobspawn_overrides[M.mind.assigned_role])) //We're doing something special today.
		SendToAtom(M, pick(GLOB.jobspawn_overrides[M.mind.assigned_role]), FALSE)
		return

	if(length(GLOB.latejoin))
		SendToAtom(M, pick(GLOB.latejoin), buckle)
	else
		var/msg = "Unable to send mob [M] to late join!"
		message_admins(msg)
		CRASH(msg)


/datum/controller/subsystem/job/proc/JobDebug(message)
	log_manifest(message)