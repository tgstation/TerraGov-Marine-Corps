/datum/hive_status
	///List of facehuggers
	var/list/mob/living/carbon/xenomorph/facehugger/facehuggers = list()

/datum/hive_status/proc/can_spawn_as_hugger(mob/dead/observer/user)

	if(!user.client?.prefs || is_banned_from(user.ckey, ROLE_XENOMORPH))
		return FALSE

	if(GLOB.key_to_time_of_death[user.key] + TIME_BEFORE_TAKING_BODY > world.time && !user.started_as_observer)
		to_chat(user, span_warning("You died too recently to be able to take a new facehugger."))
		return FALSE

	if(tgui_alert(user, "Are you sure you want to be a Facehugger?", "Become a part of the Horde", list("Yes", "No")) != "Yes")
		return FALSE

	if(length(facehuggers) >= MAX_FACEHUGGERS)
		to_chat(user, span_warning("The Hive cannot support more facehuggers! Limit: <b>[length_char(facehuggers)]/[MAX_FACEHUGGERS]</b>."))
		return FALSE

	return TRUE

//Managing the number of facehuggers in the hive
/mob/living/carbon/xenomorph/facehugger/add_to_hive(datum/hive_status/HS, force)
	. = ..()

	HS.facehuggers += src

/mob/living/carbon/xenomorph/facehugger/remove_from_hive()
	var/datum/hive_status/hive_removed_from = hive

	. = ..()

	hive_removed_from.facehuggers -= src
