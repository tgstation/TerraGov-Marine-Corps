/datum/game_mode/hvh/campaign
	name = "Campaign"
	config_tag = "Campaign"
	flags_round_type = MODE_TWO_HUMAN_FACTIONS|MODE_HUMAN_ONLY
	whitelist_ship_maps = list(MAP_ITERON)
	whitelist_ground_maps = list(MAP_FORT_PHOBOS)
	bioscan_interval = 3 MINUTES
	valid_job_types = list(
		/datum/job/terragov/command/captain/campaign = 1,
		/datum/job/terragov/command/staffofficer/campaign = 2,
		/datum/job/terragov/command/fieldcommander/campaign = 1,
		/datum/job/terragov/squad/engineer = 4,
		/datum/job/terragov/squad/corpsman = 8,
		/datum/job/terragov/squad/smartgunner = 4,
		/datum/job/terragov/squad/leader = 4,
		/datum/job/terragov/squad/standard = -1,
		/datum/job/som/command/commander = 1,
		/datum/job/som/command/staffofficer = 2,
		/datum/job/som/command/fieldcommander = 1,
		/datum/job/som/squad/leader = 4,
		/datum/job/som/squad/veteran = 2,
		/datum/job/som/squad/engineer = 4,
		/datum/job/som/squad/medic = 8,
		/datum/job/som/squad/standard = -1,
	)
	///The current mission type being played
	var/datum/campaign_mission/current_mission
	///campaign stats organised by faction
	var/list/datum/faction_stats/stat_list = list()
	///List of death times by key. Used for respawn time
	var/list/player_death_times = list()

/datum/game_mode/hvh/campaign/announce()
	to_chat(world, "<b>The current game mode is - Campaign!</b>")
	to_chat(world, "<b>The fringe world of Palmaria is undergoing significant upheaval, with large portions of the population threatening to succeed from TerraGov. With the population on the brink of civil war, \
	both TerraGov Marine Corp and the Sons of Mars forces are looking to intervene.")
	to_chat(world, "<b>Fight for your faction across the planet, the campaign for Palmaria starts now!</b>")
	to_chat(world, "<b>WIP, report bugs on the github!</b>")

/datum/game_mode/hvh/campaign/pre_setup()
	. = ..()
	for(var/faction in factions)
		stat_list[faction] = new /datum/faction_stats(faction)
	RegisterSignal(SSdcs, COMSIG_LIVING_JOB_SET, PROC_REF(register_faction_member))
	RegisterSignals(SSdcs, list(COMSIG_GLOB_MOB_DEATH, COMSIG_MOB_GHOSTIZE), PROC_REF(set_death_time))
	RegisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_MISSION_ENDED, PROC_REF(cut_death_list_timer))
	addtimer(CALLBACK(SSticker.mode, TYPE_PROC_REF(/datum/game_mode/hvh/campaign, intro_sequence)), SSticker.round_start_time + 1 MINUTES)

/datum/game_mode/hvh/campaign/post_setup()
	. = ..()
	for(var/obj/effect/landmark/patrol_point/exit_point AS in GLOB.patrol_point_list) //som 'ship' map is now ground, but this ensures we clean up exit points if this changes in the future
		qdel(exit_point)
	load_new_mission(new /datum/campaign_mission/tdm/first_mission(factions[1])) //this is the 'roundstart' mission

	for(var/i in stat_list)
		var/datum/faction_stats/selected_faction = stat_list[i]
		addtimer(CALLBACK(selected_faction, TYPE_PROC_REF(/datum/faction_stats, choose_faction_leader)), 90 SECONDS)

/datum/game_mode/hvh/campaign/player_respawn(mob/respawnee)
	if(!respawnee?.client)
		return

	if(!(respawnee.faction in factions) && (current_mission?.mission_state == MISSION_STATE_ACTIVE))
		return respawnee.respawn()

	var/respawn_delay = CAMPAIGN_RESPAWN_TIME + stat_list[respawnee.faction]?.respawn_delay_modifier
	if((player_death_times[respawnee.key] + respawn_delay) > world.time)
		to_chat(respawnee, "<span class='warning'>Respawn timer has [round((player_death_times[respawnee.key] + respawn_delay - world.time) / 10)] seconds remaining.<spawn>")
		return

	attempt_attrition_respawn(respawnee)

/datum/game_mode/hvh/campaign/intro_sequence()
	var/op_name_faction_one = GLOB.operation_namepool[/datum/operation_namepool].get_random_name()
	var/op_name_faction_two = GLOB.operation_namepool[/datum/operation_namepool].get_random_name()
	for(var/mob/living/carbon/human/human AS in GLOB.alive_human_list)
		if(human.faction == factions[1])
			human.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:left valign='top'><u>[op_name_faction_one]</u></span><br>" + "Fight to restore peace and order across the planet, and check the SOM threat.<br>" + "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")] [stationTimestamp("hh:mm")]<br>" + "TGMC Rapid Reaction Battalion<br>" + "[human.job.title], [human]<br>", /atom/movable/screen/text/screen_text/picture/rapid_response)
		else if(human.faction == factions[2])
			human.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:left valign='top'><u>[op_name_faction_two]</u></span><br>" + "Fight to liberate the people of Palmaria from the yoke of TerraGov oppression!<br>" + "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")] [stationTimestamp("hh:mm")]<br>" + "SOM 4th Special Assault Force<br>" + "[human.job.title], [human]<br>", /atom/movable/screen/text/screen_text/picture/saf_four)

/datum/game_mode/hvh/campaign/process()
	if(round_finished)
		return PROCESS_KILL

	if(!current_mission)
		return
	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_BIOSCAN) || bioscan_interval == 0 || current_mission.mission_state != MISSION_STATE_ACTIVE)
		return
	announce_bioscans_marine_som(ztrait = ZTRAIT_AWAY) //todo: make this faction neutral

/datum/game_mode/hvh/campaign/check_finished(game_status) //todo: add the actual logic once the persistance stuff is done
	if(round_finished)
		message_admins("check_finished called when game already over")
		return TRUE

	//placeholder/fall back win condition
	for(var/faction in factions)
		if(stat_list[faction].victory_points >= CAMPAIGN_MAX_VICTORY_POINTS)
			switch(faction)
				if(FACTION_SOM)
					round_finished = MODE_COMBAT_PATROL_SOM_MINOR
				if(FACTION_TERRAGOV)
					round_finished = MODE_COMBAT_PATROL_MARINE_MINOR
			message_admins("Round finished: [round_finished]")
			return TRUE

/datum/game_mode/hvh/campaign/declare_completion() //todo: update fluff message
	. = ..()
	to_chat(world, span_round_header("|[round_finished]|"))
	log_game("[round_finished]\nGame mode: [name]\nRound time: [duration2text()]\nEnd round player population: [length(GLOB.clients)]\nTotal TGMC spawned: [GLOB.round_statistics.total_humans_created[FACTION_TERRAGOV]]\nTotal SOM spawned: [GLOB.round_statistics.total_humans_created[FACTION_SOM]]")
	to_chat(world, span_round_body("Thus ends the story of the brave men and women of both the TGMC and SOM, and their struggle on Palmaria."))

/datum/game_mode/hvh/campaign/get_status_tab_items(datum/dcs, mob/source, list/items)
	. = ..()
	if(!current_mission)
		return

	current_mission.get_status_tab_items(source, items)
	for(var/i in stat_list)
		if((source.faction != stat_list[i].faction) && (source.faction != FACTION_NEUTRAL))
			continue
		stat_list[i].get_status_tab_items(source, items)


///sets up the newly selected mission
/datum/game_mode/hvh/campaign/proc/load_new_mission(datum/campaign_mission/new_mission)
	current_mission = new_mission
	current_mission.load_mission()
	TIMER_COOLDOWN_START(src, COOLDOWN_BIOSCAN, bioscan_interval)

//respawn stuff

///Records the players death time for respawn time purposes
/datum/game_mode/hvh/campaign/proc/set_death_time(datum/source, mob/living/carbon/human/player, override = FALSE)
	SIGNAL_HANDLER
	if(override)
		return //ghosting out of a corpse won't count
	if(!istype(player))
		return
	if(!(player.faction in factions))
		return
	player_death_times[player.key] = world.time

///Wrapper for cutting the deathlist via timer due to the players not immediately returning to base
/datum/game_mode/hvh/campaign/proc/cut_death_list_timer(datum/source)
	SIGNAL_HANDLER
	addtimer(CALLBACK(src, PROC_REF(cut_death_list)), AFTER_MISSION_TELEPORT_DELAY + 1)

///cuts the death time list at mission end
/datum/game_mode/hvh/campaign/proc/cut_death_list(datum/source)
	player_death_times.Cut()

///respawns the player if attrition points are available
/datum/game_mode/hvh/campaign/proc/attempt_attrition_respawn(mob/candidate)
	var/list/dat = list("<div class='notice'>Mission Duration: [DisplayTimeText(world.time - SSticker.round_start_time)]</div>")
	if(!GLOB.enter_allowed)
		dat += "<div class='notice red'>You may no longer join the mission.</div><br>"
	var/forced_faction
	if(candidate.faction in SSticker.mode.get_joinable_factions(FALSE))
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
			dept_dat += "<a class='job[command_bold]' href='byond://?src=[REF(src)];campaign_choice=SelectedJob;player=[REF(candidate)];job_selected=[REF(job_datum)]'>[job_datum.title] ([position_amount])</a>"
		if(!length(dept_dat))
			dept_dat += span_nopositions("No positions open.")
		dat += jointext(dept_dat, "")
		dat += "</fieldset><br>"
	dat += "</div>"
	var/datum/browser/popup = new(candidate, "latechoices", "Choose Occupation", 680, 580)
	popup.add_stylesheet("latechoices", 'html/browser/latechoices.css')
	popup.set_content(jointext(dat, ""))
	popup.open(FALSE)

/datum/game_mode/hvh/campaign/Topic(href, href_list[])
	switch(href_list["campaign_choice"])
		if("SelectedJob")
			if(!SSticker)
				return
			var/mob/candidate = locate(href_list["player"])
			if(!candidate.client)
				return

			if(!GLOB.enter_allowed)
				to_chat(candidate, span_warning("Spawning currently disabled, please observe."))
				return

			var/mob/new_player/ready_candidate = new()
			candidate.client.screen.Cut()
			candidate.mind.transfer_to(ready_candidate)

			var/datum/job/job_datum = locate(href_list["job_selected"])

			if(!attrition_respawn(ready_candidate, job_datum))
				ready_candidate.mind.transfer_to(candidate)
				ready_candidate.client.screen.Cut()
				qdel(ready_candidate)
				return
			if(isobserver(candidate))
				qdel(candidate)


///Actually respawns the player, if still able
/datum/game_mode/hvh/campaign/proc/attrition_respawn(mob/new_player/ready_candidate, datum/job/job_datum)
	if(!ready_candidate.IsJobAvailable(job_datum, TRUE))
		to_chat(usr, "<span class='warning'>Selected job is not available.<spawn>")
		return
	if(!SSticker || SSticker.current_state != GAME_STATE_PLAYING)
		to_chat(usr, "<span class='warning'>The round is either not ready, or has already finished!<spawn>")
		return
	if(!GLOB.enter_allowed)
		to_chat(usr, "<span class='warning'>Spawning currently disabled, please observe.<spawn>")
		return
	if(!SSjob.AssignRole(ready_candidate, job_datum, TRUE))
		to_chat(usr, "<span class='warning'>Failed to assign selected role.<spawn>")
		return

	if(current_mission.mission_state == MISSION_STATE_ACTIVE)
		stat_list[job_datum.faction].active_attrition_points -= job_datum.job_cost
	LateSpawn(ready_candidate)
	return TRUE

///Check which jobs are valid, to add to the job selector menu
/datum/game_mode/hvh/campaign/proc/IsJobAvailable(mob/candidate, datum/job/job, faction)
	if(!job)
		return FALSE
	if(job.faction != faction)
		return FALSE
	if((job.current_positions >= job.total_positions) && job.total_positions != -1)
		return FALSE
	if(current_mission.mission_state == MISSION_STATE_ACTIVE && (job.job_cost > stat_list[faction].active_attrition_points))
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

///Sets up newly spawned players with the campaign status verb
/datum/game_mode/hvh/campaign/proc/register_faction_member(datum/source, mob/living/carbon/human/new_member)
	SIGNAL_HANDLER
	if(!(new_member.faction in factions))
		return
	add_verb(new_member, /mob/living/proc/open_faction_stats_ui)

///Opens up the players campaign status UI
/mob/living/proc/open_faction_stats_ui()
	set name = "Campaign Status"
	set desc = "Check the status of your faction in the campaign."
	set category = "IC"

	var/datum/faction_stats/your_faction = GLOB.faction_stats_datums[faction]
	if(!your_faction)
		return
	your_faction.interact(src)
