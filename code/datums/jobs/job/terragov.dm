/datum/job/terragov
	faction = FACTION_TERRAGOV

/datum/job/terragov/radio_help_message(mob/M)
	. = ..()
	if(CONFIG_GET(number/minimal_access_threshold))
		to_chat(M, "<span class='notice'><b>As this ship was initially staffed with a [CONFIG_GET(flag/jobs_have_minimal_access) ? "skeleton crew, additional access may" : "full crew, only the job's necessities"] have been added to the crew's ID cards.</b></span>")
