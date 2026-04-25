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
	///List of death times by ckey. Used for respawn time
	var/list/player_death_times = list()

	/// Timer used to calculate how long till next respawn wave
	var/wave_timer
	///The length of time until next respawn wave.
	var/wave_timer_length = 5 MINUTES

/datum/game_mode/hvh/pre_setup()
	. = ..()
	RegisterSignals(SSdcs, list(COMSIG_GLOB_MOB_DEATH, COMSIG_MOB_GHOSTIZE), PROC_REF(record_death))

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
	return factions

/datum/game_mode/hvh/player_respawn(mob/respawnee)
	if(!respawnee?.client)
		return
	//If you're in a non-aligned faction, you can respawn normally. Specifically before the death time check so to avoid trapping players in misc factions
	if(!(respawnee.faction in factions))
		return respawnee.respawn()

	if(respawnee.ckey in player_death_times)
		to_chat(respawnee, span_warning("Respawn timer has [round(timeleft(wave_timer) * 0.1)] seconds remaining."))
		//note that wave respawns are not actually triggered by default at the game_mode/hvh level
		return

	attempt_respawn(respawnee)

/datum/game_mode/hvh/Topic(href, href_list[])
	switch(href_list["gamemode_choice"])
		if("SelectedJob")
			if(!SSticker)
				return
			var/mob/candidate = locate(href_list["player"])
			if(!candidate?.client)
				return

			if(!GLOB.enter_allowed)
				to_chat(candidate, span_warning("Spawning currently disabled, please observe."))
				return

			var/mob/new_player/ready_candidate = new()
			candidate.client.screen.Cut()
			candidate.mind.transfer_to(ready_candidate)

			var/datum/job/job_datum = locate(href_list["job_selected"])

			if(!do_respawn(ready_candidate, job_datum))
				ready_candidate.mind.transfer_to(candidate)
				ready_candidate?.client?.screen?.Cut()
				qdel(ready_candidate)
				return

			var/mob/living/carbon/human/human_current = candidate
			//The player might be a brain or some other unusual circumstance
			if(isobserver(candidate))
				var/mob/dead/observer/observer_candidate = candidate
				if(!isnull(observer_candidate.can_reenter_corpse))
					human_current = observer_candidate.can_reenter_corpse.resolve()
				qdel(candidate)
			if(!ishuman(human_current))
				return
			human_current.set_undefibbable(TRUE)

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

///Records the players death time for respawn time purposes
/datum/game_mode/hvh/proc/record_death(datum/source, mob/living/carbon/player, override = FALSE) //todo:change name later
	SIGNAL_HANDLER
	if(override)
		return FALSE//ghosting out of a corpse won't count
	if(!istype(player))
		return FALSE
	if(!(player.faction in factions))
		return FALSE
	player_death_times[player.ckey] = world.time
	return TRUE

///Allows all the dead to respawn together
/datum/game_mode/hvh/proc/respawn_wave()
	wave_timer = addtimer(CALLBACK(src, PROC_REF(respawn_wave)), wave_timer_length, TIMER_STOPPABLE)

	var/respawn_list = player_death_times.Copy()
	player_death_times.Cut()
	for(var/key in respawn_list)
		auto_attempt_respawn(key)


	for(var/i in GLOB.observer_list)
		var/mob/dead/observer/M = i
		GLOB.key_to_time_of_role_death[M.key] -= respawn_time
		M.playsound_local(M, 'sound/ambience/votestart.ogg', 75, 1)
		M.play_screen_text(HUD_ANNOUNCEMENT_FORMATTING("RESPAWN WAVE AVAILABLE", "YOU CAN NOW RESPAWN.", CENTER_ALIGN_TEXT), /atom/movable/screen/text/screen_text/command_order)
		to_chat(M, "<br><font size='3'>[span_attack("Reinforcements are gathering to join the fight, you can now respawn to join a fresh patrol!")]</font><br>")

///Auto pops up the respawn window
/datum/game_mode/hvh/proc/auto_attempt_respawn(respawnee_ckey)
	for(var/mob/player AS in GLOB.player_list)
		if(player.ckey != respawnee_ckey)
			continue
		if(isliving(player) && player.stat != DEAD)
			return
		player_respawn(player)
		return

///respawns the player if attrition points are available
/datum/game_mode/hvh/proc/attempt_respawn(mob/candidate)
	var/list/dat = list("<div class='notice'>Mission Duration: [DisplayTimeText(world.time - SSticker.round_start_time)]</div>")
	if(!GLOB.enter_allowed)
		dat += "<div class='notice red'>You may no longer join the round.</div><br>"
	var/forced_faction
	if(candidate.faction in SSticker.mode.get_joinable_factions(FALSE)) //update get_joinable_factions for encounter, maybe for cp as well?
		forced_faction = candidate.faction
	else
		forced_faction = tgui_input_list(candidate, "What faction do you want to join", "Faction choice", SSticker.mode.get_joinable_factions(TRUE))
		if(!forced_faction)
			return
	dat += "<div class='latejoin-container' style='width: 100%'>"
	for(var/cat in SSjob.active_joinable_occupations_by_category)
		var/list/category = SSjob.active_joinable_occupations_by_category[cat]
		var/datum/job/job_datum = category[1] //use the color of the first job in the category (the department head) as the category color
		dat += "<fieldset class='latejoin' style='border-color: [job_datum.selection_color]'>"
		dat += "<legend align='center' style='color: [job_datum.selection_color]'>[job_datum.job_category]</legend>"
		var/list/dept_dat = list()
		for(var/job in category)
			job_datum = job
			if(!IsJobAvailable(candidate, job_datum, forced_faction))
				continue
			var/command_bold = ""
			if(job_datum.job_flags & JOB_FLAG_BOLD_NAME_ON_SELECTION)
				command_bold = " command"
			var/position_amount
			if(job_datum.job_flags & JOB_FLAG_HIDE_CURRENT_POSITIONS)
				position_amount = "?"
			else if(job_datum.job_flags & JOB_FLAG_SHOW_OPEN_POSITIONS)
				position_amount = "[job_datum.total_positions - job_datum.current_positions] open positions"
			else
				position_amount = job_datum.current_positions
			dept_dat += "<a class='job[command_bold]' href='byond://?src=[REF(src)];gamemode_choice=SelectedJob;player=[REF(candidate)];job_selected=[REF(job_datum)]'>[job_datum.title] ([position_amount])</a>"
		if(!length(dept_dat))
			dept_dat += span_nopositions("No positions open.")
		dat += jointext(dept_dat, "")
		dat += "</fieldset><br>"
	dat += "</div>"
	var/datum/browser/popup = new(candidate, "latechoices", "Choose Occupation", 680, 580)
	popup.add_stylesheet("latechoices", 'html/browser/latechoices.css')
	popup.set_content(jointext(dat, ""))
	popup.open(FALSE)

///Actually respawns the player, if still able
/datum/game_mode/hvh/proc/do_respawn(mob/new_player/ready_candidate, datum/job/job_datum)
	if(!respawn_checks(ready_candidate, job_datum))
		return FALSE

	LateSpawn(ready_candidate)
	return TRUE

///Checks if the player is able to respawn
/datum/game_mode/hvh/proc/respawn_checks(mob/new_player/ready_candidate, datum/job/job_datum)
	if(!ready_candidate.IsJobAvailable(job_datum, TRUE))
		to_chat(usr, span_warning("Selected job is not available."))
		return FALSE
	if(!SSticker || SSticker.current_state != GAME_STATE_PLAYING)
		to_chat(usr,span_warning("The round is either not ready, or has already finished!"))
		return FALSE
	if(!GLOB.enter_allowed)
		to_chat(usr, span_warning("Spawning currently disabled, please observe."))
		return FALSE
	if(!SSjob.AssignRole(ready_candidate, job_datum, TRUE))
		to_chat(usr, span_warning("Failed to assign selected role."))
		return FALSE
	return TRUE

///Checks if a job is a valid option for a respawning player
/datum/game_mode/hvh/proc/IsJobAvailable(mob/candidate, datum/job/job, faction)
	if(!job)
		return FALSE
	if(job.faction != faction)
		return FALSE
	if((job.current_positions >= job.total_positions) && job.total_positions != -1)
		return FALSE
	if(is_banned_from(candidate.ckey, job.title))
		return FALSE
	if(QDELETED(candidate))
		return FALSE
	if(!job.player_old_enough(candidate.client))
		return FALSE
	if(job.required_playtime_remaining(candidate.client))
		return FALSE
	if(!job.special_check_latejoin(candidate.client))
		return FALSE
	return TRUE

#undef BIOSCAN_DELTA
