/*!
 * Code for xenomorphs to summon the dropship to the ground
 */
/mob/living/carbon/xenomorph/proc/summon_dropship()
	set category = "Alien"
	set name = "Summon Dropship"
	set desc = "Call down the dropship on your location."

	if(!CHECK_BITFIELD(hive.hive_flags, HIVE_CAN_HIJACK))
		to_chat(src, span_warning("Our hive lacks the psychic prowess to hijack the bird."))
		return

	var/datum/game_mode/game_mode = SSticker.mode
	if(!game_mode?.summon_dropship(src))
		return

	game_mode.announce_bioscans()
	message_admins("[ADMIN_TPMONTY(src)] has summoned the dropship.")
	log_admin("[key_name(src)] has summoned the dropship.")
	hive?.xeno_message("[src] has summoned down the metal bird in [get_area_name(src, TRUE)], gather to her now!")

///Land the main dropship on the summoner's location
/datum/game_mode/proc/summon_dropship(mob/summoner)
	if(!is_ground_level(summoner.z))
		summoner.balloon_alert(summoner, "Can't call it from here")
		return FALSE

	var/humans_on_ground = 0
	for(var/i in SSmapping.levels_by_trait(ZTRAIT_GROUND))
		for(var/mob/living/carbon/human/human AS in GLOB.humans_by_zlevel["[i]"])
			if(isnestedhost(human))
				continue

			if(human.faction == FACTION_XENO)
				continue

			humans_on_ground++

	if(length(GLOB.alive_human_list) && ((humans_on_ground / length(GLOB.alive_human_list)) > ALIVE_HUMANS_FOR_CALLDOWN))
		to_chat(summoner, span_warning("There's too many tallhosts still on the ground. They interfere with our psychic field. We must dispatch them before we are able to do this."))
		return FALSE

	var/obj/docking_port/mobile/marine_dropship/shuttle
	for(var/obj/docking_port/mobile/marine_dropship/candidate in SSshuttle.mobile)
		if(CHECK_BITFIELD(candidate.control_flags, SHUTTLE_MARINE_PRIMARY_DROPSHIP))
			shuttle = candidate
			break

	if(!shuttle)
		stack_trace("No primary dropship found in SSshuttle's mobile list!")
		return FALSE

	if(shuttle.hijack_state != HIJACK_STATE_NORMAL)
		summoner.balloon_alert(summoner, "Already summoned")
		return FALSE

	if(shuttle.mode != SHUTTLE_IDLE && shuttle.mode != SHUTTLE_RECHARGING)
		to_chat(summoner, span_warning("The bird's mind is currently active. We need to wait until it's more vulnerable..."))
		return FALSE

	if(!shuttle.shuttle_computer)
		stack_trace("No navigation computer found on the primary dropship!")
		return FALSE

	var/obj/machinery/computer/camera_advanced/shuttle_docker/flyable/dropship/console = shuttle.shuttle_computer
	console.summon(summoner)
	return TRUE

/datum/game_mode/infestation/summon_dropship(mob/summoner)
	#ifndef TESTING
	if(round_stage != INFESTATION_MARINE_DEPLOYMENT)
		summoner.balloon_alert(summoner, "Disabled")
		return FALSE
	#endif

	return ..()
