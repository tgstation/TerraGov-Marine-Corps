//The base setup for HvH gamemodes, not for actual use
/datum/game_mode/hvh
	name = "HvH base mode"
	round_type_flags = MODE_LATE_OPENING_SHUTTER_TIMER|MODE_TWO_HUMAN_FACTIONS|MODE_HUMAN_ONLY
	shutters_drop_time = 3 MINUTES
	xeno_abilities_flags = ABILITY_CRASH
	factions = list(FACTION_TERRAGOV, FACTION_SOM)
	valid_job_types = list(
		/datum/job/terragov/squad/engineer = 8,
		/datum/job/terragov/squad/corpsman = 8,
		/datum/job/terragov/squad/smartgunner = 4,
		/datum/job/terragov/squad/leader = 4,
		/datum/job/terragov/squad/standard = -1,
		/datum/job/som/squad/leader = 4,
		/datum/job/som/squad/veteran = 4,
		/datum/job/som/squad/engineer = 8,
		/datum/job/som/squad/medic = 8,
		/datum/job/som/squad/standard = -1,
	)
	job_points_needed_by_job_type = list(
		/datum/job/terragov/squad/smartgunner = 5,
		/datum/job/som/squad/veteran = 5,
	)
	/// Time between two bioscan
	var/bioscan_interval = 3 MINUTES

/datum/game_mode/hvh/setup()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_HVH_DEPLOY_POINT_ACTIVATED, PROC_REF(deploy_point_activated))

/datum/game_mode/hvh/post_setup()
	. = ..()
	for(var/z_num in SSmapping.levels_by_any_trait(list(ZTRAIT_MARINE_MAIN_SHIP, ZTRAIT_GROUND)))
		set_z_lighting(z_num)

//sets TGMC and SOM squads
/datum/game_mode/hvh/set_valid_squads()
	SSjob.active_squads[FACTION_TERRAGOV] = list()
	SSjob.active_squads[FACTION_SOM] = list()
	for(var/key in SSjob.squads)
		var/datum/squad/squad = SSjob.squads[key]
		if(squad.faction == FACTION_TERRAGOV || squad.faction == FACTION_SOM) //We only want Marine and SOM squads, future proofs if more faction squads are added
			SSjob.active_squads[squad.faction] += squad
	return TRUE

/datum/game_mode/hvh/get_joinable_factions(should_look_balance)
	if(should_look_balance)
		if(length(GLOB.alive_human_list_faction[FACTION_TERRAGOV]) > length(GLOB.alive_human_list_faction[FACTION_SOM]) * MAX_UNBALANCED_RATIO_TWO_HUMAN_FACTIONS)
			return list(FACTION_SOM)
		if(length(GLOB.alive_human_list_faction[FACTION_SOM]) > length(GLOB.alive_human_list_faction[FACTION_TERRAGOV]) * MAX_UNBALANCED_RATIO_TWO_HUMAN_FACTIONS)
			return list(FACTION_TERRAGOV)
	return list(FACTION_TERRAGOV, FACTION_SOM)

/datum/game_mode/hvh/announce_round_stats()
	//sets up some stats which are added if applicable
	var/tgmc_survival_stat
	var/som_survival_stat
	var/tgmc_accuracy_stat
	var/som_accuracy_stat

	if(GLOB.round_statistics.total_human_deaths[FACTION_TERRAGOV])
		if(GLOB.round_statistics.total_human_revives[FACTION_TERRAGOV])
			tgmc_survival_stat = "[GLOB.round_statistics.total_human_revives[FACTION_TERRAGOV]] were revived, for a [(GLOB.round_statistics.total_human_revives[FACTION_TERRAGOV] / max(GLOB.round_statistics.total_human_deaths[FACTION_TERRAGOV], 1)) * 100]% revival rate and a [((GLOB.round_statistics.total_humans_created[FACTION_TERRAGOV] + GLOB.round_statistics.total_human_revives[FACTION_TERRAGOV] - GLOB.round_statistics.total_human_deaths[FACTION_TERRAGOV]) / GLOB.round_statistics.total_humans_created[FACTION_TERRAGOV]) * 100]% survival rate."
		else
			tgmc_survival_stat = "None were revived, for a [((GLOB.round_statistics.total_humans_created[FACTION_TERRAGOV] - GLOB.round_statistics.total_human_deaths[FACTION_TERRAGOV]) / GLOB.round_statistics.total_humans_created[FACTION_TERRAGOV]) * 100]% survival rate."
	if(GLOB.round_statistics.total_human_deaths[FACTION_SOM])
		if(GLOB.round_statistics.total_human_revives[FACTION_SOM])
			som_survival_stat = "[GLOB.round_statistics.total_human_revives[FACTION_SOM]] were revived, for a [(GLOB.round_statistics.total_human_revives[FACTION_SOM] / max(GLOB.round_statistics.total_human_deaths[FACTION_SOM], 1)) * 100]% revival rate and a [((GLOB.round_statistics.total_humans_created[FACTION_SOM] + GLOB.round_statistics.total_human_revives[FACTION_SOM] - GLOB.round_statistics.total_human_deaths[FACTION_SOM]) / GLOB.round_statistics.total_humans_created[FACTION_SOM]) * 100]% survival rate."
		else
			som_survival_stat = "None were revived, for a [((GLOB.round_statistics.total_humans_created[FACTION_SOM] - GLOB.round_statistics.total_human_deaths[FACTION_SOM]) / GLOB.round_statistics.total_humans_created[FACTION_SOM]) * 100]% survival rate."
	if(GLOB.round_statistics.total_projectile_hits[FACTION_SOM] && GLOB.round_statistics.total_projectiles_fired[FACTION_TERRAGOV])
		tgmc_accuracy_stat = ", for an accuracy of [(GLOB.round_statistics.total_projectile_hits[FACTION_SOM] / GLOB.round_statistics.total_projectiles_fired[FACTION_TERRAGOV]) * 100]%!."
	if(GLOB.round_statistics.total_projectile_hits[FACTION_TERRAGOV] && GLOB.round_statistics.total_projectiles_fired[FACTION_SOM])
		som_accuracy_stat = ", for an accuracy of [(GLOB.round_statistics.total_projectile_hits[FACTION_TERRAGOV] / GLOB.round_statistics.total_projectiles_fired[FACTION_SOM]) * 100]%!."

	var/list/dat = list({"[span_round_body("The end of round statistics are:")]<br>
		<br>[GLOB.round_statistics.total_humans_created[FACTION_TERRAGOV]] TGMC personel deployed for the patrol, and [GLOB.round_statistics.total_human_deaths[FACTION_TERRAGOV] ? GLOB.round_statistics.total_human_deaths[FACTION_TERRAGOV] : "no"] TGMC personel were killed. [tgmc_survival_stat ? tgmc_survival_stat : ""]
		<br>[GLOB.round_statistics.total_humans_created[FACTION_SOM]] SOM personel deployed for the patrol, and [GLOB.round_statistics.total_human_deaths[FACTION_SOM] ? GLOB.round_statistics.total_human_deaths[FACTION_SOM] : "no"] SOM personel were killed. [som_survival_stat ? som_survival_stat : ""]
		<br>The TGMC fired [GLOB.round_statistics.total_projectiles_fired[FACTION_TERRAGOV] ? GLOB.round_statistics.total_projectiles_fired[FACTION_TERRAGOV] : "no"] projectiles. [GLOB.round_statistics.total_projectile_hits[FACTION_SOM] ? GLOB.round_statistics.total_projectile_hits[FACTION_SOM] : "No"] projectiles managed to hit members of the SOM[tgmc_accuracy_stat ? tgmc_accuracy_stat : "."]
		<br>The SOM fired [GLOB.round_statistics.total_projectiles_fired[FACTION_SOM] ? GLOB.round_statistics.total_projectiles_fired[FACTION_SOM] : "no"] projectiles. [GLOB.round_statistics.total_projectile_hits[FACTION_TERRAGOV] ? GLOB.round_statistics.total_projectile_hits[FACTION_TERRAGOV] : "No"] projectiles managed to hit members of the TGMC[som_accuracy_stat ? som_accuracy_stat : "."]
		"})
	if(GLOB.round_statistics.grenades_thrown)
		dat += "[GLOB.round_statistics.grenades_thrown] grenades were detonated."
	else
		dat += "No grenades exploded."

	var/output = jointext(dat, "<br>")
	for(var/mob/player in GLOB.player_list)
		if(player?.client?.prefs?.toggles_chat & CHAT_STATISTICS)
			to_chat(player, output)

///plays the intro sequence if any
/datum/game_mode/hvh/proc/intro_sequence()
	return

///checks how many marines and SOM are still alive
/datum/game_mode/hvh/proc/count_humans(list/z_levels = SSmapping.levels_by_trait(ZTRAIT_GROUND), count_flags) //todo: either make this not ground exclusive, or make new Z's not away levels
	var/list/som_alive = list()
	var/list/som_dead = list()
	var/list/tgmc_alive = list()
	var/list/tgmc_dead = list()

	for(var/z in z_levels)
		//counts the live marines and SOM
		for(var/i in GLOB.humans_by_zlevel["[z]"])
			var/mob/living/carbon/human/H = i
			if(!istype(H))
				continue
			if(count_flags & COUNT_IGNORE_HUMAN_SSD && !H.client)
				continue
			if(H.faction == FACTION_SOM)
				som_alive += H
			else if(H.faction == FACTION_TERRAGOV)
				tgmc_alive += H
	//counts the dead marines and SOM
	for(var/i in GLOB.dead_human_list)
		var/mob/living/carbon/human/H = i
		if(!istype(H))
			continue
		if(H.faction == FACTION_SOM)
			som_dead += H
		else if(H.faction == FACTION_TERRAGOV)
			tgmc_dead += H

	return list(som_alive, tgmc_alive, som_dead, tgmc_dead)

// make sure you don't turn 0 into a false positive
#define BIOSCAN_DELTA(count, delta) count ? max(0, count + rand(-delta, delta)) : 0

///Annonce to everyone the number of SOM and marines on ship and ground
/datum/game_mode/hvh/proc/announce_bioscans_marine_som(show_locations = TRUE, delta = 2, announce_marines = TRUE, announce_som = TRUE, ztrait = ZTRAIT_GROUND)
	TIMER_COOLDOWN_START(src, COOLDOWN_BIOSCAN, bioscan_interval)
	//pulls the number of marines and SOM
	var/list/player_list = count_humans(SSmapping.levels_by_trait(ztrait), COUNT_IGNORE_ALIVE_SSD)
	var/list/som_list = player_list[1]
	var/list/tgmc_list = player_list[2]
	var/num_som = length(player_list[1])
	var/num_tgmc = length(player_list[2])
	var/tgmc_location
	var/som_location

	if(num_som)
		som_location = get_area(pick(player_list[1]))
	if(num_tgmc)
		tgmc_location = get_area(pick(player_list[2]))

	//Adjust the randomness there so everyone gets the same thing
	var/num_tgmc_delta = BIOSCAN_DELTA(num_tgmc, delta)
	var/num_som_delta = BIOSCAN_DELTA(num_som, delta)

	//announcement for SOM
	var/som_scan_name = "Long Range Tactical Bioscan Status"
	var/som_scan_input = {"Bioscan complete.

Sensors indicate [num_tgmc_delta || "no"] unknown lifeform signature[num_tgmc_delta > 1 ? "s":""] present in the area of operations[tgmc_location ? ", including one at: [tgmc_location]":""]"}

	if(announce_som)
		priority_announce(som_scan_input, som_scan_name, sound = 'sound/AI/bioscan.ogg', color_override = "orange", receivers = (som_list + GLOB.observer_list))

	//announcement for TGMC
	var/marine_scan_name = "Long Range Tactical Bioscan Status"
	var/marine_scan_input = {"Bioscan complete.

Sensors indicate [num_som_delta || "no"] unknown lifeform signature[num_som_delta > 1 ? "s":""] present in the area of operations[som_location ? ", including one at: [som_location]":""]"}

	if(announce_marines)
		priority_announce(marine_scan_input, marine_scan_name, sound = 'sound/AI/bioscan.ogg', color_override = "blue", receivers = (tgmc_list + GLOB.observer_list))

	log_game("Bioscan. [num_tgmc] active TGMC personnel[tgmc_location ? " Location: [tgmc_location]":""] and [num_som] active SOM personnel[som_location ? " Location: [som_location]":""]")

	for(var/i in GLOB.observer_list)
		var/mob/M = i
		to_chat(M, assemble_alert(
			title = "Detailed Bioscan",
			message = {"[num_som] SOM alive.
[num_tgmc] Marine\s alive."},
			color_override = "orange"
		))

	message_admins("Bioscan - Marines: [num_tgmc] active TGMC personnel[tgmc_location ? " .Location:[tgmc_location]":""]")
	message_admins("Bioscan - SOM: [num_som] active SOM personnel[som_location ? " .Location:[som_location]":""]")

///Messages a mob when they deploy groundside. only called if the specific gamemode register for the signal
/datum/game_mode/hvh/proc/deploy_point_activated(datum/source, mob/living/user)
	SIGNAL_HANDLER
	var/message = get_deploy_point_message(user)
	if(!message)
		return
	user.playsound_local(user, "sound/effects/CIC_order.ogg", 10, 1)
	user.play_screen_text(HUD_ANNOUNCEMENT_FORMATTING("OVERWATCH", message, LEFT_ALIGN_TEXT), GLOB.faction_to_portrait[user.faction])

///Returns a message to play to a mob when they deploy into the AO
/datum/game_mode/hvh/proc/get_deploy_point_message(mob/living/user)
	switch(user.faction)
		if(FACTION_TERRAGOV)
			. = "Stick together and achieve those objectives marines. Good luck."
		if(FACTION_SOM)
			. = "Remember your training marines, show those Terrans the strength of the SOM, glory to Mars!"

#undef BIOSCAN_DELTA
