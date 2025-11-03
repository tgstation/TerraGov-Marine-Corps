/datum/job/terragov
	faction = FACTION_TERRAGOV

/datum/job/terragov/after_spawn(mob/living/carbon/C, mob/M, latejoin = FALSE)
	. = ..()
	C.transfer_to_hive(XENO_HIVE_CORRUPTED)

/datum/job/terragov/get_spawn_message_information(mob/M)
	. = ..()
	if(istype(SSticker.mode, /datum/game_mode/hvh/combat_patrol))
		if(issensorcapturegamemode(SSticker.mode))
			. += span_role_header("Your platoon has orders to attack sensor towers in the AO and reactivate them in order to alert other Ninetails forces in the sector about the invasion. High Command considers the successful reactivation of the sensor towers a major victory")
		else
			. += span_role_header("Your platoon has orders to patrol a remote Ninetails territory that the Sons of Mars are illegally attempting to claim. Intel suggests hostile patrols are in the area to try maintain defacto control. Work with your team and eliminate all SOM you encounter while minimising your own casualties! High Command considers wiping out all enemies a major victory, or inflicting more casualties a minor victory.")
	else if(CONFIG_GET(number/minimal_access_threshold))
		var/msg = "As this ship was initially staffed with a [CONFIG_GET(flag/jobs_have_minimal_access) ? "[span_alert("skeleton crew")] additional access may" : "[span_green("full crew,")] only the job's necessities"] have been added to the crew's ID cards."
		. += separator_hr("[span_role_header("Access Information")]")
		. += msg
