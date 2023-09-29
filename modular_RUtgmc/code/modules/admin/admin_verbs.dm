/datum/admins/proc/unforbid()
	set category = "Admin"
	set name = "Unforbid"

	if(!check_rights(R_ADMIN))
		return

	if(GLOB.hive_datums[XENO_HIVE_NORMAL])
		GLOB.hive_datums[XENO_HIVE_NORMAL].unforbid_all_castes(TRUE)
		log_game("[key_name(usr)] unforbid all castes in [GLOB.hive_datums[XENO_HIVE_NORMAL].name] hive")
		message_admins("[ADMIN_TPMONTY(usr)] unforbid all castes in [GLOB.hive_datums[XENO_HIVE_NORMAL].name] hive")
	else
		log_game("[key_name(usr)] failed to unforbid")
		message_admins("[ADMIN_TPMONTY(usr)] failed to unforbid")

/datum/admins/proc/military_policeman()
	set category = "Debug"
	set name = "Military Policeman"

	if(!check_rights(R_FUN))
		return

	var/mob/M = usr
	var/mob/living/carbon/human/H
	var/spatial = FALSE
	if(ishuman(M))
		H = M
		var/datum/job/J = H.job
		spatial = istype(J, /datum/job/terragov/command/military_police)

	if(spatial)
		log_admin("[key_name(M)] stopped being a debug military policeman.")
		message_admins("[ADMIN_TPMONTY(M)] stopped being a debug military policeman.")
		qdel(M)
	else
		H = new(get_turf(M))
		M.client.prefs.copy_to(H)
		M.mind.transfer_to(H, TRUE)
		var/datum/job/J = SSjob.GetJobType(/datum/job/terragov/command/military_police)
		H.apply_assigned_role_to_spawn(J)
		qdel(M)

		log_admin("[key_name(H)] became a debug military policeman.")
		message_admins("[ADMIN_TPMONTY(H)] became a debug military policeman.")
