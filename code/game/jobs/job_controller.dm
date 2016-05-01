var/global/datum/controller/occupations/job_master
var/list/survivorjobs = list("Scientist", "Station Engineer", "Medical Doctor", "Cargo Technician", "Botanist", "Chef", "Assistant", "Clown")
var/list/headsurvivorjobs = list("Chief Medical Officer", "Chief Engineer", "Research Director")

#define GET_RANDOM_JOB 0
#define BE_ASSISTANT 1
#define RETURN_TO_LOBBY 2

/datum/controller/occupations
		//List of all jobs
	var/list/occupations = list()
		//Players who need jobs
	var/list/unassigned = list()
		//Debug info
	var/list/job_debug = list()
	var/list/squads = list()


	proc/SetupOccupations(var/faction = "Station")
		occupations = list()
		squads = list()
		var/list/all_jobs = typesof(/datum/job)
		if(!all_jobs.len)
			world << "\red \b Error setting up jobs, no job datums found"
			return 0
		for(var/J in all_jobs)
			var/datum/job/job = new J()
			if(!job)	continue
			if(job.faction != faction)	continue
			// if(job.title in get_marine_jobs())
			occupations += job

		var/list/all_squads = typesof(/datum/squad)
		if(!all_squads.len)
			world << "\red \b Error setting up squads, no squad datums found"
			return 0
		for(var/S in all_squads)
			var/datum/squad/squad = new S()
			if(!squad)	continue
			if(!squad.usable) continue
			squads += squad

		return 1


	proc/Debug(var/text)
		if(!Debug2)	return 0
		job_debug.Add(text)
		return 1


	proc/GetJob(var/rank)
		if(!rank)	return null
		for(var/datum/job/J in occupations)
			if(!J)	continue
			if(J.title == rank)	return J
		return null

	proc/GetPlayerAltTitle(mob/new_player/player, rank)
		return player.client.prefs.GetPlayerAltTitle(GetJob(rank))

	proc/AssignRole(var/mob/new_player/player, var/rank, var/latejoin = 0)
		if(player && player.mind && rank)
			var/datum/job/job = GetJob(rank)
			if(!job)	return 0
			if(jobban_isbanned(player, rank))	return 0
			if(!job.player_old_enough(player.client)) return 0
			var/position_limit = job.total_positions
			if(!latejoin)
				position_limit = job.spawn_positions
			if((job.current_positions < position_limit) || position_limit == -1)
				player.mind.assigned_role = rank
				player.mind.role_alt_title = GetPlayerAltTitle(player, rank)
				player.mind.role_comm_title = job.comm_title
				unassigned -= player
				job.current_positions++
				return 1
		return 0

	proc/FreeRole(var/rank)	//making additional slot on the fly
		var/datum/job/job = GetJob(rank)
		if(job && job.current_positions >= job.total_positions && job.total_positions != -1)
			job.total_positions++
			return 1
		return 0

	proc/FindOccupationCandidates(datum/job/job, level, flag)
		var/list/candidates = list()
		for(var/mob/new_player/player in unassigned)
			if(jobban_isbanned(player, job.title))
				continue
			if(!job.player_old_enough(player.client))
				continue
			if(flag && (!player.client.prefs.be_special & flag))
				continue
			if(player.client.prefs.GetJobDepartment(job, level) & job.flag)
				candidates += player
		return candidates

	proc/GiveRandomJob(var/mob/new_player/player)
		for(var/datum/job/job in shuffle(occupations))
			if(!job)
				continue

			if(prob(85))
				AssignRole(player,"Squad Marine") //Fuck it.
				continue

			if(job in command_positions) //If you want a command position, select it!
				continue

			if(jobban_isbanned(player, job.title))
				continue

			if(!job.player_old_enough(player.client))
				continue

			if((job.current_positions < job.spawn_positions) || job.spawn_positions == -1)
				AssignRole(player, job.title)
				unassigned -= player
				break

	proc/ResetOccupations()
		for(var/mob/new_player/player in player_list)
			if((player) && (player.mind))
				player.mind.assigned_role = null
				player.mind.special_role = null
		SetupOccupations()
		unassigned = list()
		return


	///This proc is called before the level loop of DivideOccupations() and will try to select a head, ignoring ALL non-head preferences for every level until it locates a head or runs out of levels to check
	proc/FillHeadPosition()
		for(var/level = 1 to 3)
			for(var/command_position in command_positions)
				var/datum/job/job = GetJob(command_position)
				if(!job)	continue
				var/list/candidates = FindOccupationCandidates(job, level)
				if(!candidates.len)	continue

				// Build a weighted list, weight by age.
				var/list/weightedCandidates = list()

				// Different head positions have different good ages.
				var/good_age_minimal = 25
				var/good_age_maximal = 90
				if(command_position == "Commander")
					good_age_minimal = 30
					good_age_maximal = 200 // Old geezer captains ftw

				for(var/mob/V in candidates)
					// Log-out during round-start? What a bad boy, no head position for you!
					if(!V.client) continue
					var/age = V.client.prefs.age
					switch(age)
						if(good_age_minimal - 10 to good_age_minimal)
							weightedCandidates[V] = 3 // Still a bit young.
						if(good_age_minimal to good_age_minimal + 10)
							weightedCandidates[V] = 6 // Better.
						if(good_age_minimal + 10 to good_age_maximal - 10)
							weightedCandidates[V] = 10 // Great.
						if(good_age_maximal - 10 to good_age_maximal)
							weightedCandidates[V] = 6 // Still good.
						if(good_age_maximal to good_age_maximal + 10)
							weightedCandidates[V] = 6 // Bit old, don't you think?
						if(good_age_maximal to good_age_maximal + 50)
							weightedCandidates[V] = 3 // Geezer.
						else
							// If there's ABSOLUTELY NOBODY ELSE
							if(candidates.len == 1) weightedCandidates[V] = 1


				var/mob/new_player/candidate = pickweight(weightedCandidates)
				if(AssignRole(candidate, command_position))
					return 1
		return 0


	///This proc is called at the start of the level loop of DivideOccupations() and will cause head jobs to be checked before any other jobs of the same level
	proc/CheckHeadPositions(var/level)
		for(var/command_position in command_positions)
			var/datum/job/job = GetJob(command_position)
			if(!job)	continue
			var/list/candidates = FindOccupationCandidates(job, level)
			if(!candidates.len)	continue
			var/mob/new_player/candidate = pick(candidates)
			AssignRole(candidate, command_position)
		return


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
				unassigned = shuffle(unassigned)
				for(var/mob/new_player/player in unassigned)
					if(jobban_isbanned(player, "AI"))	continue
					if(AssignRole(player, "AI"))
						ai_selected++
						break
			if(ai_selected)	return 1
			return 0


/** Proc DivideOccupations
 *  fills var "assigned_role" for all ready players.
 *  This proc must not have any side effect besides of modifying "assigned_role".
 **/
	proc/DivideOccupations()
		//Setup new player list and get the jobs list
		SetupOccupations()

		//Holder for Triumvirate is stored in the ticker, this just processes it
	//	if(ticker)
			//for(var/datum/job/ai/A in occupations)
			//	if(ticker.triai)
				//	A.spawn_positions = 3

		//Get the players who are ready
		for(var/mob/new_player/player in player_list)
			if(player.ready && player.mind && !player.mind.assigned_role)
				unassigned += player

		if(unassigned.len == 0)	return 0

		//Shuffle players and jobs
		unassigned = shuffle(unassigned)

		HandleFeedbackGathering()

		//Select one head
		FillHeadPosition()

		//Check for an AI
		FillAIPosition()


		// New job giving system by Donkie
		// This will cause lots of more loops, but since it's only done once it shouldn't really matter much at all.
		// Hopefully this will add more randomness and fairness to job giving.

		// Loop through all levels from high to low
		var/list/shuffledoccupations = shuffle(occupations)
		for(var/level = 1 to 3)
			//Check the head jobs first each level
			CheckHeadPositions(level)

			// Loop through all unassigned players
			for(var/mob/new_player/player in unassigned)

				// Loop through all jobs
				for(var/datum/job/job in shuffledoccupations) // SHUFFLE ME BABY
					if(!job)
						continue

					if(jobban_isbanned(player, job.title))
						continue

					if(!job.player_old_enough(player.client))
						continue

					// If the player wants that job on this level, then try give it to him.
					if(player.client.prefs.GetJobDepartment(job, level) & job.flag)

						// If the job isn't filled
						if((job.current_positions < job.spawn_positions) || job.spawn_positions == -1)
							AssignRole(player, job.title)
							unassigned -= player
							break

		// Hand out random jobs to the people who didn't get any in the last check
		// Also makes sure that they got their preference correct
		for(var/mob/new_player/player in unassigned)
			if(player.client.prefs.alternate_option == GET_RANDOM_JOB)
				GiveRandomJob(player)

		for(var/mob/new_player/player in unassigned)
			if(player.client.prefs.alternate_option == BE_ASSISTANT) //We're just stealing the define
				AssignRole(player, "Squad Marine")

		//For ones returning to lobby
		for(var/mob/new_player/player in unassigned)
			if(player.client.prefs.alternate_option == RETURN_TO_LOBBY)
				player.ready = 0
				unassigned -= player
		return 1


	proc/EquipRank(var/mob/living/carbon/human/H, var/rank, var/joined_late = 0)

		if(!H)	return 0

		var/datum/job/job = GetJob(rank)
		var/list/spawn_in_storage = list()

		if(job)
			if(job.title == "Corporate Liaison" && ticker && H.mind)
				ticker.liaison = H.mind

			//Equip custom gear loadout.
			if(H.client.prefs.gear && H.client.prefs.gear.len && job.title != "Cyborg" && job.title != "AI")

				for(var/thing in H.client.prefs.gear)
					var/datum/gear/G = gear_datums[thing]
					if(G)
						var/permitted
						if(G.allowed_roles)
							for(var/job_name in G.allowed_roles)
								if(job.title == job_name)
									permitted = 1
						else
							permitted = 1

						if(G.whitelisted && !is_alien_whitelisted(H, G.whitelisted))
							permitted = 0

						if(!permitted)
							H << "\red Your current job or whitelist status does not permit you to spawn with [thing]!"
							continue

						if(G.slot)
							H.equip_to_slot_or_del(new G.path(H), G.slot)
							H << "\blue Equipping you with [thing]!"

						else
							spawn_in_storage += thing


			//Equip job items.
			job.equip(H)
		else
			return

		H.job = rank

		if(!joined_late)
			var/obj/S = null
			for(var/obj/effect/landmark/start/sloc in landmarks_list)
				if(sloc.name != rank)	continue
				if(locate(/mob/living) in sloc.loc)	continue
				S = sloc
				break
			if(!S)
				S = locate("start*[rank]") // use old stype
			if(istype(S, /obj/effect/landmark/start) && istype(S.loc, /turf))
				H.loc = S.loc
			// Moving wheelchair if they have one
			if(H.buckled && istype(H.buckled, /obj/structure/stool/bed/chair/wheelchair))
				H.buckled.loc = H.loc
				H.buckled.dir = H.dir

		//give them an account in the station database
		var/datum/money_account/M = create_account(H.real_name, rand(50,500)*10, null)
		if(H.mind)
			var/remembered_info = ""
			remembered_info += "<b>Your account number is:</b> #[M.account_number]<br>"
			remembered_info += "<b>Your account pin is:</b> [M.remote_access_pin]<br>"
			remembered_info += "<b>Your account funds are:</b> $[M.money]<br>"

			if(M.transaction_log.len)
				var/datum/transaction/T = M.transaction_log[1]
				remembered_info += "<b>Your account was created:</b> [T.time], [T.date] at [T.source_terminal]<br>"
			H.mind.store_memory(remembered_info)

			H.mind.initial_account = M

		// If they're head, give them the account info for their department
		if(H.mind && job.head_position)
			var/remembered_info = ""
			var/datum/money_account/department_account = department_accounts[job.department]

			if(department_account)
				remembered_info += "<b>Your department's account number is:</b> #[department_account.account_number]<br>"
				remembered_info += "<b>Your department's account pin is:</b> [department_account.remote_access_pin]<br>"
				remembered_info += "<b>Your department's account funds are:</b> $[department_account.money]<br>"

			H.mind.store_memory(remembered_info)

		spawn(0)
			H << "\blue<b>Your account number is: [M.account_number], your account pin is: [M.remote_access_pin]</b>"

		var/alt_title = null
		if(H.mind)
			H.mind.assigned_role = rank
			alt_title = H.mind.role_alt_title

			switch(rank)
				if("Cyborg")
					H.Robotize()
					return 1
				if("AI","Clown")	//don't need bag preference stuff!
				else
					/*
					switch(H.backbag) //Fuck backpacks for now, just get one from your locker.
						if(1)
							H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
						if(2)
							var/obj/item/weapon/storage/backpack/BPK = new/obj/item/weapon/storage/backpack(H)
							new /obj/item/weapon/storage/box/survival(BPK)
							H.equip_to_slot_or_del(BPK, slot_back,1)
						if(3)
							var/obj/item/weapon/storage/backpack/BPK = new/obj/item/weapon/storage/backpack/satchel_norm(H)
							new /obj/item/weapon/storage/box/survival(BPK)
							H.equip_to_slot_or_del(BPK, slot_back,1)
						if(4)
							var/obj/item/weapon/storage/backpack/BPK = new/obj/item/weapon/storage/backpack/satchel(H)
							new /obj/item/weapon/storage/box/survival(BPK)
							H.equip_to_slot_or_del(BPK, slot_back,1)
					*/

					//Deferred item spawning.
					if(spawn_in_storage && spawn_in_storage.len)
						var/obj/item/weapon/storage/B
						for(var/obj/item/weapon/storage/S in H.contents)
							B = S
							break

						if(!isnull(B))
							for(var/thing in spawn_in_storage)
								H << "\blue Placing [thing] in your [B]!"
								var/datum/gear/G = gear_datums[thing]
								new G.path(B)
						else
							H << "\red Failed to locate a storage object on your mob, either you spawned with no arms and no backpack or this is a bug."

		//TODO: Generalize this by-species
		if(H.species)
			if(H.species.name == "Tajara" || H.species.name == "Unathi")
				H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(H),slot_shoes,1)
			else if(H.species.name == "Vox")
				H.equip_to_slot_or_del(new /obj/item/clothing/mask/breath(H), slot_wear_mask)
				if(!H.r_hand)
					H.equip_to_slot_or_del(new /obj/item/weapon/tank/nitrogen(H), slot_r_hand)
					H.internal = H.r_hand
				else if (!H.l_hand)
					H.equip_to_slot_or_del(new /obj/item/weapon/tank/nitrogen(H), slot_l_hand)
					H.internal = H.l_hand
				H.internals.icon_state = "internal1"

		if(istype(H)) //give humans wheelchairs, if they need them.
			var/datum/organ/external/l_foot = H.get_organ("l_foot")
			var/datum/organ/external/r_foot = H.get_organ("r_foot")
			if((!l_foot || l_foot.status & ORGAN_DESTROYED) && (!r_foot || r_foot.status & ORGAN_DESTROYED))
				var/obj/structure/stool/bed/chair/wheelchair/W = new /obj/structure/stool/bed/chair/wheelchair(H.loc)
				H.buckled = W
				H.update_canmove()
				W.dir = H.dir
				W.buckled_mob = H
				W.add_fingerprint(H)

		H << "<B>You are the [alt_title ? alt_title : rank].</B>"
		H << "<b>As the [alt_title ? alt_title : rank] you answer directly to [job.supervisors]. Special circumstances may change this.</b>"
		H << "<b>To speak on your department's radio channel use :h. For the use of other channels, examine your headset.</b>"
		if(job.req_admin_notify)
			H << "<b>You are playing a job that is important for Game Progression. If you have to disconnect, please notify the admins via adminhelp.</b>"

		spawnId(H, rank, alt_title)
//		H.equip_to_slot_or_del(new /obj/item/device/radio/headset(H), slot_l_ear)

		if(job.is_squad_job) //Are we a muhreen? Randomize our squad. This should go AFTER IDs.
			if(H.mind && !H.mind.assigned_squad)
				randomize_squad(H)

		if(H.mind.assigned_squad)//Marines start hungry.
			H.nutrition = rand(60,250) //WHERES ME DONK POCKETS

		//Gives glasses to the vision impaired
		if(H.disabilities & NEARSIGHTED)
			var/equipped = H.equip_to_slot_or_del(new /obj/item/clothing/glasses/regular(H), slot_glasses)
			if(equipped != 1)
				var/obj/item/clothing/glasses/G = H.glasses
				G.prescription = 1
//		H.update_icons()

		H.hud_updateflag |= (1 << ID_HUD)
		H.hud_updateflag |= (1 << IMPLOYAL_HUD)
		H.hud_updateflag |= (1 << SPECIALROLE_HUD)
		return 1

//Find which squad has the least population. If all 4 squads are equal it should just use the first one (alpha)
	proc/get_lowest_squad()
		if(!squads.len) //Something went wrong, our squads aren't set up.
			world << "Warning, something messed up in get_lowest_squad(). No squads set up!"
			return null

		var/current_count = 0
		var/datum/squad/lowest = null
		for(var/datum/squad/L in squads) //This is kinda stupid, but whatever. We need a default squad.
			if(L)
				lowest = L
				break

		if(!lowest)
			world << "Warning! Bug in get_random_squad()!"
			return null

		var/lowest_count = lowest.count

		//Loop through squads.
		for(var/datum/squad/S in squads)
			if(!S)
				world << "Warning: Null squad in get_lowest_squad. Call a coder!"
				break //null squad somehow, let's just abort
			current_count = S.count //Grab our current squad's #
			if(current_count >= lowest_count) //Current squad is bigger or the same as our value. Skip it.
				continue
			lowest_count = current_count //We found a winner! This squad is lower than our default. Make it the new default.
			lowest = S //'Select' this squad.

		return lowest //Return whichever squad won the competition.

//This proc is a bit of a misnomer, since there's no actual randomization going on.
	proc/randomize_squad(var/mob/living/carbon/human/H)
		if(!H || !H.mind) return

		if(!squads.len)
			H << "Something went wrong with your squad randomizer! Tell a coder!"
			return //Shit, where's our squad data

		if(H.mind.assigned_squad) //Wait, we already have a squad. Get outta here!
			return

		//Deal with non-standards first.
		//Non-standards are distributed regardless of squad population.
		//If the number of available positions for the job are more than max_whatever, it will break.
		//Ie. 8 squad medic jobs should be available, and total medics in squads should be 8.
		if(H.mind.assigned_role != "Squad Marine")
			for(var/datum/squad/S in squads) //Loop through the squads to find the first one one with an empty slot.
				if(!S) break //something weird happened!

				//Check the current squad's roster. If we're full, move on to the next squad and try that one.
				if(H.mind.assigned_role == "Squad Engineer" && S.num_engineers >= S.max_engineers) continue
				if(H.mind.assigned_role == "Squad Medic" && S.num_medics >= S.max_medics) continue
				if(H.mind.assigned_role == "Squad Leader" && S.num_leaders >= S.max_leaders) continue
				if(H.mind.assigned_role == "Squad Specialist" && S.num_specialists >= S.max_specialists) continue

				S.put_marine_in_squad(H) //Found one, add them in and stop the loop.
				break
		else
			//Deal with marines. They get distributed to the lowest populated squad.
			var/datum/squad/given_squad = get_lowest_squad()
			if(!given_squad || !istype(given_squad)) //Something went horribly wrong!
				H << "Something went wrong with randomize_squad()! Tell a coder!"
				return

			given_squad.put_marine_in_squad(H) //Found one, finish up

		if(H.mind)
			if(H.mind.assigned_squad)
				H << "You have been assigned to: \b [H.mind.assigned_squad.name] squad."
				H << "Make your way to the cafeteria for some post-cryosleep chow, and then get equipped in your squad's prep room."
		return

	proc/spawnId(var/mob/living/carbon/human/H, rank, title)
		if(!H)	return 0
		var/obj/item/weapon/card/id/C = null

		var/datum/job/job = null
		for(var/datum/job/J in occupations)
			if(J.title == rank)
				job = J
				break

		if(job)
			if(job.title == "Cyborg")
				return
			else
				C = new job.idtype(H)
				C.access = job.get_access()
		else
			C = new /obj/item/weapon/card/id(H)
		if(C)
			C.registered_name = H.real_name
			C.rank = rank
			C.assignment = title ? title : rank
			C.name = "[C.registered_name]'s ID Card ([C.assignment])"

			//put the player's account number onto the ID
			if(H.mind && H.mind.initial_account)
				C.associated_account_number = H.mind.initial_account.account_number

			H.equip_to_slot_or_del(C, slot_wear_id)

//		H.equip_to_slot_or_del(new /obj/item/device/pda(H), slot_belt)
//		if(locate(/obj/item/device/pda,H))
//			var/obj/item/device/pda/pda = locate(/obj/item/device/pda,H)
//			pda.owner = H.real_name
//			pda.ownjob = C.assignment
//			pda.name = "PDA-[H.real_name] ([pda.ownjob])"

		return 1


	proc/LoadJobs(jobsfile) //ran during round setup, reads info from jobs.txt -- Urist
		if(!config.load_jobs_from_txt)
			return 0

		var/list/jobEntries = file2list(jobsfile)

		for(var/job in jobEntries)
			if(!job)
				continue

			job = trim(job)
			if (!length(job))
				continue

			var/pos = findtext(job, "=")
			var/name = null
			var/value = null

			if(pos)
				name = copytext(job, 1, pos)
				value = copytext(job, pos + 1)
			else
				continue

			if(name && value)
				var/datum/job/J = GetJob(name)
				if(!J)	continue
				J.total_positions = text2num(value)
				J.spawn_positions = text2num(value)
				if(name == "AI" || name == "Cyborg")//I dont like this here but it will do for now
					J.total_positions = 0

		return 1


	proc/HandleFeedbackGathering()
		for(var/datum/job/job in occupations)
			var/tmp_str = "|[job.title]|"

			var/level1 = 0 //high
			var/level2 = 0 //medium
			var/level3 = 0 //low
			var/level4 = 0 //never
			var/level5 = 0 //banned
			var/level6 = 0 //account too young
			for(var/mob/new_player/player in player_list)
				if(!(player.ready && player.mind && !player.mind.assigned_role))
					continue //This player is not ready
				if(jobban_isbanned(player, job.title))
					level5++
					continue
				if(!job.player_old_enough(player.client))
					level6++
					continue
				if(player.client.prefs.GetJobDepartment(job, 1) & job.flag)
					level1++
				else if(player.client.prefs.GetJobDepartment(job, 2) & job.flag)
					level2++
				else if(player.client.prefs.GetJobDepartment(job, 3) & job.flag)
					level3++
				else level4++ //not selected

			tmp_str += "HIGH=[level1]|MEDIUM=[level2]|LOW=[level3]|NEVER=[level4]|BANNED=[level5]|YOUNG=[level6]|-"
			feedback_add_details("job_preferences",tmp_str)
