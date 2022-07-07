/datum/job/terragov
	faction = FACTION_TERRAGOV

/datum/job/terragov/radio_help_message(mob/M)
	. = ..()
	if(SSticker.mode?.flags_round_type & MODE_TWO_HUMAN_FACTIONS)
		to_chat(M, span_highdanger("You are a proud member of the [faction == FACTION_TERRAGOV ? "Loyalist" : "Rebel"] faction. Kill your enemies!"))
	if(CONFIG_GET(number/minimal_access_threshold))
		var/msg = "As this ship was initially staffed with a [CONFIG_GET(flag/jobs_have_minimal_access) ? "skeleton crew, additional access may" : "full crew, only the job's necessities"] have been added to the crew's ID cards."
		to_chat(M, span_notice(msg))

/datum/job/terragov/return_spawn_type(datum/preferences/prefs)
	switch(prefs?.species)
		if("Combat Robot")
			if(GLOB.join_as_robot_allowed)
				return /mob/living/carbon/human/species/robot
			to_chat(prefs.parent, span_danger("Robot species joins are currently disabled, your species has been defaulted to Human"))
			return /mob/living/carbon/human
		if("Vatborn")
			return /mob/living/carbon/human/species/vatborn
		else
			return /mob/living/carbon/human
