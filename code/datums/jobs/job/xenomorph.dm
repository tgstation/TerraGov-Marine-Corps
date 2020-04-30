/datum/job/xenomorph
	job_category = JOB_CAT_XENO
	title = ROLE_XENOMORPH
	supervisors = "the hive ruler"
	selection_color = "#B2A3CC"
	display_order = JOB_DISPLAY_ORDER_XENOMORPH
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_NOHEADSET|JOB_FLAG_OVERRIDELATEJOINSPAWN|JOB_FLAG_HIDE_CURRENT_POSITIONS
	jobworth = list(/datum/job/survivor/rambo = SURVIVOR_POINTS_REGULAR)
	job_points_needed  = 10 //Redefined via config.

/datum/job/xenomorph/return_spawn_type(datum/preferences/prefs)
	return /mob/living/carbon/xenomorph/larva

/datum/job/xenomorph/radio_help_message(mob/M)
	. = ..()
	to_chat(M, "<b>Your job is to spread the hive and protect the Queen. If there's no Queen, you can become the Queen yourself by evolving into a drone.</b><br>\
	Talk in Hivemind using <strong>;</strong>, <strong>.a</strong>, or <strong>,a</strong> (e.g. ';My life for the queen!')")

/datum/job/xenomorph/handle_special_preview(client/parent)
	parent.show_character_previews(image('icons/Xeno/1x1_Xenos.dmi', icon_state = "Bloody Larva", dir = SOUTH))
	return TRUE

/datum/job/xenomorph/queen
	title = ROLE_XENO_QUEEN
	req_admin_notify = TRUE
	supervisors = "Queen mother"
	selection_color = "#8972AA"
	display_order = JOB_DISPLAY_ORDER_XENO_QUEEN
	job_flags = JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_NOHEADSET|JOB_FLAG_OVERRIDELATEJOINSPAWN|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_HIDE_CURRENT_POSITIONS
	jobworth = list(/datum/job/survivor/rambo = SURVIVOR_POINTS_REGULAR)

/datum/job/xenomorph/queen/return_spawn_type(datum/preferences/prefs)
	return /mob/living/carbon/xenomorph/shrike

/datum/job/xenomorph/queen/return_spawn_turf()
	return pick(GLOB.spawns_by_job[/datum/job/xenomorph])

/datum/job/xenomorph/queen/radio_help_message(mob/M)
	to_chat(M, "<b>You are now the alien ruler!<br>\
	Your job is to spread the hive.</b><br>\
	Talk in Hivemind using <strong>;</strong>, <strong>.a</strong>, or <strong>,a</strong> (e.g. ';My life for the hive!')")

/datum/job/xenomorph/queen/handle_special_preview(client/parent)
	parent.show_character_previews(image('icons/Xeno/1x1_Xenos.dmi', icon_state = "Larva", dir = SOUTH))
	return TRUE
