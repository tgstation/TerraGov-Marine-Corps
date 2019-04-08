GLOBAL_LIST_INIT(exp_jobsmap, list(
	EXP_TYPE_REGULAR_ALL = list("titles" = JOBS_REGULAR_ALL),
	EXP_TYPE_COMMAND = list("titles" = JOBS_COMMAND),
	EXP_TYPE_ENGINEERING = list("titles" = JOBS_ENGINEERING),
	EXP_TYPE_MEDICAL = list("titles" = JOBS_MEDICAL),
	EXP_TYPE_MARINES = list("titles" = JOBS_MARINES),
	EXP_TYPE_REQUISITIONS = list("titles" = JOBS_REQUISITIONS),
	EXP_TYPE_POLICE = list("titles" = JOBS_POLICE)
))

GLOBAL_LIST_INIT(exp_specialmap, list(
	EXP_TYPE_LIVING = list(),
	EXP_TYPE_SPECIAL = list(ROLE_SURVIVOR, ROLE_XENOMORPH, ROLE_XENO_QUEEN),
	EXP_TYPE_GHOST = list()
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

	var/list/head_announce = null
	var/faction = "None"

	var/flag = NOFLAGS
	var/department_flag = NOFLAGS
	var/prefflag = NOFLAGS

	var/spawn_positions = 0
	var/total_positions = 0
	var/current_positions = 0

	var/supervisors = ""
	var/selection_color = "#ffffff"

	var/req_admin_notify

	var/minimal_player_age = 0
	var/exp_requirements = 0
	var/exp_type = ""
	var/exp_type_department = ""

	var/outfit = null
	var/skills_type = null

	var/display_order = JOB_DISPLAY_ORDER_DEFAULT


/datum/job/proc/after_spawn(mob/living/L, mob/M, latejoin = FALSE) //do actions on L but send messages to M as the key may not have been transferred_yet
	if(!ishuman(L))
		return
	var/mob/living/carbon/human/H = L
	var/obj/item/card/id/C = H.wear_id
	if(istype(C) && H.mind?.initial_account)
		C.associated_account_number = H.mind.initial_account.account_number


/datum/job/proc/announce(mob/living/carbon/human/H)
	if(head_announce)
		announce_head(H, head_announce)


/datum/job/proc/override_latejoin_spawn(mob/living/carbon/human/H)		//Return TRUE to force latejoining to not automatically place the person in latejoin shuttle/whatever.
	return FALSE


//Used for a special check of whether to allow a client to latejoin as this job.
/datum/job/proc/special_check_latejoin(client/C)
	return TRUE


//Don't override this unless the job transforms into a non-human (Silicons do this for example)
/datum/job/proc/equip(mob/living/carbon/human/H, visualsOnly = FALSE, announce = TRUE, latejoin = FALSE, datum/outfit/outfit_override = null, client/preference_source)
	if(!H)
		return FALSE

	if(H.mind)
		var/datum/skills/L = new skills_type
		H.mind.cm_skills = L
		H.mind.comm_title = comm_title

	H.job = title
	H.faction = faction

	if(outfit_override || outfit)
		H.equipOutfit(outfit_override ? outfit_override : outfit, visualsOnly)

	if(!visualsOnly && announce)
		announce(H)


/datum/job/proc/get_access()
	if(!config)	//Needed for robots.
		return minimal_access.Copy()

	. = list()

	if(CONFIG_GET(flag/jobs_have_minimal_access))
		. = minimal_access.Copy()
	else
		. = access.Copy()


/datum/job/proc/announce_head(var/mob/living/carbon/human/H, var/channels) //tells the given channel that the given mob is the new department head. See communications.dm for valid channels.
	return FALSE
	//if(H && GLOB.announcement_systems.len)
		//timer because these should come after the captain announcement
		//SSticker.OnRoundstart(CALLBACK(GLOBAL_PROC, .proc/addtimer, CALLBACK(pick(GLOB.announcement_systems), /obj/machinery/announcement_system/proc/announce, "NEWHEAD", H.real_name, H.job, channels), 1))


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
	if(!isnum(C.player_age))
		return FALSE //This is only a number if the db connection is established, otherwise it is text: "Requires database", meaning these restrictions cannot be enforced
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
	to_chat(M, "<b>Prefix your message with ; to speak on the default radio channel. To see other prefixes, look closely at your headset.</b>")


/datum/outfit/job
	var/jobtype


/datum/outfit/job/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	return


/datum/outfit/job/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	handle_id(H)


/datum/outfit/job/proc/handle_id(mob/living/carbon/human/H)
	var/datum/job/J = SSjob.GetJobType(jobtype)
	if(!J)
		J = SSjob.GetJob(H.job)

	var/obj/item/card/id/C = H.wear_id
	if(istype(C))
		C.access = J.get_access()
		shuffle_inplace(C.access) // Shuffle access list to make NTNet passkeys less predictable
		C.registered_name = H.real_name
		C.assignment = J.title
		C.rank = J.title
		C.paygrade = J.paygrade
		C.update_label()
		H.sec_hud_set_ID()

		if(H.mind?.initial_account)
			C.associated_account_number = H.mind.initial_account.account_number

	H.name = H.get_visible_name()
	H.hud_set_squad()
	H.update_action_buttons()


/proc/guest_jobbans(var/job)
	return (job in JOBS_COMMAND)