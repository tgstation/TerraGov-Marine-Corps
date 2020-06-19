GLOBAL_LIST_INIT(exp_jobsmap, list(
	EXP_TYPE_REGULAR_ALL = list("titles" = GLOB.jobs_regular_all),
	EXP_TYPE_COMMAND = list("titles" = GLOB.jobs_command),
	EXP_TYPE_ENGINEERING = list("titles" = GLOB.jobs_engineering),
	EXP_TYPE_MEDICAL = list("titles" = GLOB.jobs_medical),
	EXP_TYPE_MARINES = list("titles" = GLOB.jobs_marines),
	EXP_TYPE_REQUISITIONS = list("titles" = GLOB.jobs_requisitions),
))

GLOBAL_LIST_INIT(exp_specialmap, list(
	EXP_TYPE_LIVING = list(),
	EXP_TYPE_GHOST = list(),
	EXP_TYPE_ADMIN = list()
))
GLOBAL_PROTECT(exp_jobsmap)
GLOBAL_PROTECT(exp_specialmap)


/datum/job
	var/title = ""
	var/paygrade = ""
	var/comm_title = ""

	var/list/minimal_access = list()
	var/list/access = list()

	var/department_head = list()

	var/faction = FACTION_NEUTRAL

	var/total_positions = 0
	var/current_positions = 0
	var/max_positions = INFINITY //How many positions can be dynamically assigned.
	var/job_points = 0 //Points assigned dynamically to open new positions.
	var/job_points_needed  = INFINITY

	var/supervisors = ""
	var/selection_color = "#ffffff"
	var/job_category = JOB_CAT_UNASSIGNED

	var/req_admin_notify

	var/minimal_player_age = 0
	var/exp_requirements = 0
	var/exp_type = ""
	var/exp_type_department = ""

	var/datum/outfit/job/outfit
	var/skills_type = /datum/skills

	var/display_order = JOB_DISPLAY_ORDER_DEFAULT
	var/job_flags = NONE

	var/list/jobworth = list() //Associative list of indexes increased when someone joins as this job.

/datum/job/New()
	if(outfit)
		if(!ispath(outfit, /datum/outfit))
			stack_trace("Job created with an invalid outfit parameter ([outfit])")
		else
			outfit = new outfit //Can be improved to reference a singleton.


/datum/job/proc/after_spawn(mob/living/L, mob/M, latejoin = FALSE) //do actions on L but send messages to M as the key may not have been transferred_yet
	if(!ishuman(L))
		return

	if(job_flags & JOB_FLAG_PROVIDES_BANK_ACCOUNT)
		var/datum/money_account/bank_account = create_account(L.real_name, rand(50, 500) * 10)
		var/list/remembered_info = list()
		remembered_info += "<b>Your account number is:</b> #[bank_account.account_number]"
		remembered_info += "<b>Your account pin is:</b> [bank_account.remote_access_pin]"
		remembered_info += "<b>Your account funds are:</b> $[bank_account.money]"
		if(length(bank_account.transaction_log))
			var/datum/transaction/transaction_datum = bank_account.transaction_log[1]
			remembered_info += "<b>Your account was created:</b> [transaction_datum.time], [transaction_datum.date] at [transaction_datum.source_terminal]"
		M.mind.store_memory(remembered_info.Join("<br>"))
		M.mind.initial_account = bank_account

		var/mob/living/carbon/human/H = L
		var/obj/item/card/id/C = H.wear_id
		if(istype(C))
			C.associated_account_number = bank_account.account_number


/datum/job/proc/announce(mob/living/announced_mob)
	return


//Used for a special check of whether to allow a client to latejoin as this job.
/datum/job/proc/special_check_latejoin(client/C)
	return TRUE


/datum/job/proc/equip_dummy(mob/living/carbon/human/dummy/mannequin, datum/outfit/outfit_override = null, client/preference_source)
	if(!mannequin)
		CRASH("equip_dummy called without a mannequin")

	mannequin.equipOutfit(outfit_override || outfit, TRUE)


/datum/job/proc/get_access()
	if(!config)	//Needed for robots.
		return minimal_access.Copy()

	. = list()

	if(CONFIG_GET(flag/jobs_have_minimal_access))
		. = minimal_access.Copy()
	else
		. = access.Copy()


//If the configuration option is set to require players to be logged as old enough to play certain jobs, then this proc checks that they are, otherwise it just returns 1
/datum/job/proc/player_old_enough(client/C)
	if(available_in_days(C) == 0)
		return TRUE	//Available in 0 days = available right now = player is old enough to play.
	return FALSE


/datum/job/proc/available_in_days(client/C)
	if(!C)
		return FALSE
	if(!CONFIG_GET(flag/use_age_restriction_for_jobs))
		return FALSE
	if(!SSdbcore.Connect())
		return FALSE //Without a database connection we can't get a player's age so we'll assume they're old enough for all jobs
	if(!isnum(minimal_player_age))
		return FALSE

	return max(0, minimal_player_age - C.player_age)


/datum/job/proc/config_check()
	return TRUE


/datum/job/proc/map_check()
	return TRUE


/datum/job/proc/radio_help_message(mob/M)
	to_chat(M, {"
<span class='role_body'>|______________________|</span>
<span class='role_header'>You are a: [title]!</span>
<span class='role_body'>As a [title] you answer to [supervisors]. Special circumstances may change this.</span>
<span class='role_body'>|______________________|</span>
"})
	if(!(job_flags & JOB_FLAG_NOHEADSET))
		to_chat(M, "<b>Prefix your message with ; to speak on the default radio channel. To see other prefixes, look closely at your headset.</b>")
	if(req_admin_notify)
		to_chat(M, "<span clas='danger'>You are playing a job that is important for game progression. If you have to disconnect, please head to hypersleep, if you can't make it there, notify the admins via adminhelp.</span>")

/datum/outfit/job
	var/jobtype


/datum/outfit/job/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	return


/datum/outfit/job/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	return


/datum/outfit/job/proc/handle_id(mob/living/carbon/human/H)
	var/datum/job/J = SSjob.GetJobType(jobtype)
	if(!J)
		J = H.job

	var/obj/item/card/id/C = H.wear_id
	if(istype(C))
		C.access = J.get_access()
		shuffle_inplace(C.access) // Shuffle access list to make NTNet passkeys less predictable
		C.registered_name = H.real_name
		C.assignment = J.title
		C.rank = J.title
		C.paygrade = J.paygrade
		C.update_label()
		if(H.mind?.initial_account) // In most cases they won't have a mind at this point.
			C.associated_account_number = H.mind.initial_account.account_number

	H.update_action_buttons()


/datum/job/proc/get_special_name(client/preference_source)
	return

/datum/job/proc/occupy_job_positions(amount)
	if(amount <= 0)
		CRASH("free_job_positions() called with amount: [amount]")
	current_positions += amount
	for(var/index in jobworth)
		var/datum/job/scaled_job = SSjob.GetJobType(index)
		if(!(scaled_job in SSjob.active_joinable_occupations))
			continue
		scaled_job.add_job_points(jobworth[index])

/datum/job/proc/free_job_positions(amount)
	if(amount <= 0)
		CRASH("free_job_positions() called with amount: [amount]")
	current_positions -= amount
	for(var/index in jobworth)
		var/datum/job/scaled_job = SSjob.GetJobType(index)
		if(!(scaled_job in SSjob.active_joinable_occupations))
			continue
		scaled_job.add_job_points(-jobworth[index])

/datum/job/proc/add_job_points(amount)
	job_points += amount
	if(total_positions >= max_positions)
		return
	if(job_points >= job_points_needed )
		job_points -= job_points_needed
		add_job_positions(1)

/datum/job/proc/add_job_positions(amount)
	if(!(job_flags & (JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE)))
		CRASH("add_job_positions called for a non-joinable job")
	if(total_positions == -1)
		CRASH("add_job_positions called with [amount] amount for a job set to overflow")
	var/previous_amount = total_positions
	total_positions += amount
	manage_job_lists(previous_amount)
	return TRUE

/datum/job/proc/remove_job_positions(amount)
	if(!(job_flags & (JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE)))
		CRASH("remove_job_positions called for a non-joinable job")
	if(total_positions == -1)
		CRASH("remove_job_positions called with [amount] amount for a job set to overflow")
	var/previous_amount = total_positions
	total_positions -= amount
	manage_job_lists(previous_amount)
	return TRUE

/datum/job/proc/set_job_positions(amount)
	if(!(job_flags & (JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE)))
		CRASH("set_job_positions called for a non-joinable job")
	var/previous_amount = total_positions
	total_positions = amount
	manage_job_lists(previous_amount)

/datum/job/proc/manage_job_lists(previous_amount)
	if(!previous_amount)
		if(total_positions)
			SSjob.add_active_occupation(src)
	else if(!total_positions)
		SSjob.remove_active_occupation(src)
	if(!SSticker.HasRoundStarted() && !(SSjob.ssjob_flags & SSJOB_OVERRIDE_JOBS_START) && previous_amount < total_positions)
		LAZYADD(SSjob.occupations_reroll, src)


// Spawning mobs.
/mob/living/proc/apply_assigned_role_to_spawn(datum/job/assigned_role, client/player, datum/squad/assigned_squad, admin_action = FALSE)
	job = assigned_role
	skills = getSkillsType(job.return_skills_type(player?.prefs))
	faction = job.faction
	job.announce(src)


/mob/living/carbon/human/apply_assigned_role_to_spawn(datum/job/assigned_role, client/player, datum/squad/assigned_squad, admin_action = FALSE)
	. = ..()
	comm_title = job.comm_title

	if(job.outfit)
		var/id_type = job.outfit.id ? job.outfit.id : /obj/item/card/id
		var/obj/item/card/id/id_card = new id_type
		if(wear_id)
			if(!admin_action)
				stack_trace("[src] had an ID when apply_outfit_to_spawn() ran")
			QDEL_NULL(wear_id)
		equip_to_slot_or_del(id_card, SLOT_WEAR_ID)
		job.outfit.handle_id(src)
		job.outfit.equip(src)

	if(job.job_flags & JOB_FLAG_ALLOWS_PREFS_GEAR)
		equip_preference_gear(player)

	if(!src.assigned_squad)
		job.equip_spawning_squad(src, assigned_squad, player)


/datum/job/proc/equip_spawning_squad(mob/living/carbon/human/new_character, datum/squad/assigned_squad, client/player)
	return

/datum/job/terragov/squad/equip_spawning_squad(mob/living/carbon/human/new_character, datum/squad/assigned_squad, client/player)
	if(!assigned_squad)
		SSjob.JobDebug("Failed to put marine role in squad. Player: [player.key] Job: [title]")
		return
	assigned_squad.insert_into_squad(new_character)


/datum/job/proc/on_late_spawn(mob/living/late_spawner)
	if(job_flags & JOB_FLAG_ADDTOMANIFEST)
		if(!ishuman(late_spawner))
			CRASH("on_late_spawn called for job with JOB_FLAG_ADDTOMANIFEST on non-human late_spawner: [late_spawner]")
		GLOB.datacore.manifest_inject(late_spawner)


/datum/job/proc/return_spawn_type(datum/preferences/prefs)
	return /mob/living/carbon/human

/datum/job/proc/return_skills_type(datum/preferences/prefs)
	return skills_type

/datum/job/proc/return_spawn_turf()
	return pick(GLOB.spawns_by_job[type])

/datum/job/proc/handle_special_preview(client/parent)
	return FALSE
