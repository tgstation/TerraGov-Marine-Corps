/datum/game_mode/hvh/campaign
	name = "Campaign"
	config_tag = "Campaign"
	round_type_flags = MODE_TWO_HUMAN_FACTIONS|MODE_HUMAN_ONLY
	whitelist_ship_maps = list(MAP_ITERON)
	whitelist_ground_maps = list(MAP_FORT_PHOBOS)
	bioscan_interval = 3 MINUTES
	valid_job_types = list(
		/datum/job/terragov/squad/standard = -1,
		/datum/job/terragov/squad/corpsman = 8,
		/datum/job/terragov/squad/engineer = 4,
		/datum/job/terragov/squad/smartgunner = 4,
		/datum/job/terragov/squad/leader = 4,
		/datum/job/terragov/command/fieldcommander/campaign = 1,
		/datum/job/terragov/command/staffofficer/campaign = 2,
		/datum/job/terragov/command/captain/campaign = 1,
		/datum/job/som/squad/standard = -1,
		/datum/job/som/squad/medic = 8,
		/datum/job/som/squad/engineer = 4,
		/datum/job/som/squad/veteran = 4,
		/datum/job/som/squad/leader = 4,
		/datum/job/som/command/fieldcommander = 1,
		/datum/job/som/command/staffofficer = 2,
		/datum/job/som/command/commander = 1,
	)
	///The current mission type being played
	var/datum/campaign_mission/current_mission
	///campaign stats organised by faction
	var/list/datum/faction_stats/stat_list = list()
	///List of death times by ckey. Used for respawn time
	var/list/player_death_times = list()
	///List of timers to auto open the respawn window
	var/list/respawn_timers = list()

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
	RegisterSignals(SSdcs, list(COMSIG_GLOB_PLAYER_ROUNDSTART_SPAWNED, COMSIG_GLOB_PLAYER_LATE_SPAWNED), PROC_REF(register_faction_member))
	RegisterSignals(SSdcs, list(COMSIG_GLOB_MOB_DEATH, COMSIG_MOB_GHOSTIZE), PROC_REF(set_death_time))
	RegisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_MISSION_ENDED, PROC_REF(end_mission))
	addtimer(CALLBACK(SSticker.mode, TYPE_PROC_REF(/datum/game_mode/hvh/campaign, intro_sequence)), SSticker.round_start_time + 1 MINUTES)

/datum/game_mode/hvh/campaign/post_setup()
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(scale_loadouts)) //load_new_mission delays other proc calls in this proc both before and after it for whatever reason
	for(var/obj/effect/landmark/patrol_point/exit_point AS in GLOB.patrol_point_list) //som 'ship' map is now ground, but this ensures we clean up exit points if this changes in the future
		qdel(exit_point)
	load_new_mission(new /datum/campaign_mission/tdm/first_mission(factions[1])) //this is the 'roundstart' mission

	for(var/i in stat_list)
		var/datum/faction_stats/selected_faction = stat_list[i]
		addtimer(CALLBACK(selected_faction, TYPE_PROC_REF(/datum/faction_stats, choose_faction_leader)), 90 SECONDS)

/datum/game_mode/hvh/campaign/get_map_color_variant()
	return current_mission?.map_armor_color

/datum/game_mode/hvh/campaign/player_respawn(mob/respawnee)
	if(!respawnee?.client)
		return

	if(!(respawnee.faction in factions) && (current_mission?.mission_state == MISSION_STATE_ACTIVE))
		return respawnee.respawn()

	var/respawn_delay = CAMPAIGN_RESPAWN_TIME + stat_list[respawnee.faction]?.respawn_delay_modifier
	if((player_death_times[respawnee.ckey] + respawn_delay) > world.time)
		to_chat(respawnee, span_warning("Respawn timer has [round((player_death_times[respawnee.ckey] + respawn_delay - world.time) / 10)] seconds remaining."))
		return

	attempt_attrition_respawn(respawnee)

/datum/game_mode/hvh/campaign/intro_sequence()
	var/op_name_faction_one = GLOB.operation_namepool[/datum/operation_namepool].get_random_name()
	var/op_name_faction_two = GLOB.operation_namepool[/datum/operation_namepool].get_random_name()
	for(var/mob/living/carbon/human/human AS in GLOB.alive_human_list)
		if(human.faction == factions[1])
			human.play_screen_text(HUD_ANNOUNCEMENT_FORMATTING(op_name_faction_one, "Fight to restore peace and order across the planet, and check the SOM threat.<br>" + "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")] [stationTimestamp("hh:mm")]<br>" + "TGMC Rapid Reaction Battalion<br>" + "[human.job.title], [human]<br>", LEFT_ALIGN_TEXT), /atom/movable/screen/text/screen_text/picture/rapid_response)
		else if(human.faction == factions[2])
			human.play_screen_text(HUD_ANNOUNCEMENT_FORMATTING(op_name_faction_two, "Fight to liberate the people of Palmaria from the yoke of TerraGov oppression!<br>" + "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")] [stationTimestamp("hh:mm")]<br>" + "SOM 4th Special Assault Force<br>" + "[human.job.title], [human]<br>", LEFT_ALIGN_TEXT), /atom/movable/screen/text/screen_text/picture/saf_four)

/datum/game_mode/hvh/campaign/process()
	if(round_finished)
		return PROCESS_KILL

	if(!current_mission)
		return
	if(TIMER_COOLDOWN_RUNNING(src, COOLDOWN_BIOSCAN) || bioscan_interval == 0 || current_mission.mission_state != MISSION_STATE_ACTIVE)
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

/datum/game_mode/hvh/campaign/declare_completion()
	. = ..()
	log_game("[round_finished]\nGame mode: [name]\nRound time: [duration2text()]\nEnd round player population: [length(GLOB.clients)]\nTotal TGMC spawned: [GLOB.round_statistics.total_humans_created[FACTION_TERRAGOV]]\nTotal SOM spawned: [GLOB.round_statistics.total_humans_created[FACTION_SOM]]")

/datum/game_mode/hvh/campaign/end_round_fluff()
	var/announcement_body = ""
	switch(round_finished)
		if(MODE_COMBAT_PATROL_SOM_MINOR)
			announcement_body = "Brave SOM forces are reporting decisive victories against the imperialist TerraGov forces across the planet, forcing their disorganised and chaotic retreat. \
			With the planet now liberated, the Sons of Mars welcome the people of Palmaria into the light of a new day, ready to help them into a better future as brothers."
		if(MODE_COMBAT_PATROL_MARINE_MINOR)
			announcement_body = "TGMC forces have routed the terrorist SOM forces across the planet, destroying their strongholds and returning possession of stolen property to their legitimate corporate owners. \
			With the SOM threat removed, TerraGov peacekeeping forces begin to move in to ensure a rapid return to law and order, restoring stability, safety, and a guarantee of Palmaria's economic development to the benefit of all citizens."

	send_ooc_announcement(
		sender_override = "Round Concluded",
		title = round_finished,
		text = announcement_body,
		play_sound = FALSE,
		style = OOC_ALERT_GAME
	)

	var/sound/som_track
	var/sound/tgmc_track
	var/sound/ghost_track
	switch(round_finished)
		if(MODE_COMBAT_PATROL_SOM_MAJOR)
			som_track = pick('sound/theme/winning_triumph1.ogg', 'sound/theme/winning_triumph2.ogg')
			tgmc_track = pick('sound/theme/sad_loss1.ogg', 'sound/theme/sad_loss2.ogg')
			ghost_track = som_track
		if(MODE_COMBAT_PATROL_MARINE_MAJOR)
			som_track = pick('sound/theme/sad_loss1.ogg', 'sound/theme/sad_loss2.ogg')
			tgmc_track = pick('sound/theme/winning_triumph1.ogg', 'sound/theme/winning_triumph2.ogg')
			ghost_track = tgmc_track
		if(MODE_COMBAT_PATROL_SOM_MINOR)
			som_track = pick('sound/theme/winning_triumph1.ogg', 'sound/theme/winning_triumph2.ogg')
			tgmc_track = pick('sound/theme/neutral_melancholy1.ogg', 'sound/theme/neutral_melancholy2.ogg')
			ghost_track = som_track
		if(MODE_COMBAT_PATROL_MARINE_MINOR)
			som_track = pick('sound/theme/neutral_melancholy1.ogg', 'sound/theme/neutral_melancholy2.ogg')
			tgmc_track = pick('sound/theme/winning_triumph1.ogg', 'sound/theme/winning_triumph2.ogg')
			ghost_track = tgmc_track
		if(MODE_COMBAT_PATROL_DRAW)
			som_track = pick('sound/theme/neutral_hopeful1.ogg', 'sound/theme/neutral_hopeful2.ogg')
			tgmc_track = pick('sound/theme/neutral_hopeful1.ogg', 'sound/theme/neutral_hopeful2.ogg')
			ghost_track = tgmc_track

	som_track = sound(som_track, channel = CHANNEL_CINEMATIC)
	tgmc_track = sound(tgmc_track, channel = CHANNEL_CINEMATIC)
	ghost_track = sound(ghost_track, channel = CHANNEL_CINEMATIC)

	for(var/mob/hearer AS in GLOB.player_list)
		if(hearer.client?.prefs?.toggles_sound & SOUND_NOENDOFROUND)
			continue
		switch(hearer.faction)
			if(FACTION_SOM)
				SEND_SOUND(hearer, som_track)
			if(FACTION_TERRAGOV)
				SEND_SOUND(hearer, tgmc_track)
			else
				SEND_SOUND(hearer, ghost_track)

/datum/game_mode/hvh/campaign/get_status_tab_items(datum/dcs, mob/source, list/items)
	. = ..()
	if(!current_mission)
		return

	current_mission.get_status_tab_items(source, items)
	for(var/i in stat_list)
		if((source.faction != stat_list[i].faction) && (source.faction != FACTION_NEUTRAL))
			continue
		stat_list[i].get_status_tab_items(source, items)

/datum/game_mode/hvh/campaign/deploy_point_activated(datum/source, mob/living/user)
	if(!stat_list[user.faction])
		return
	current_mission.get_mission_deploy_message(user)

/datum/game_mode/hvh/campaign/ghost_verbs(mob/dead/observer/observer)
	return list(/datum/action/campaign_overview, /datum/action/campaign_loadout)

///sets up the newly selected mission
/datum/game_mode/hvh/campaign/proc/load_new_mission(datum/campaign_mission/new_mission)
	current_mission = new_mission
	addtimer(CALLBACK(src, PROC_REF(autobalance_cycle)), CAMPAIGN_AUTOBALANCE_DELAY, TIMER_CLIENT_TIME) //we autobalance teams after a short delay to account for slow respawners
	//TIMER_CLIENT_TIME as loading a new z-level messes with the timing otherwise
	for(var/faction in factions)
		for(var/player in GLOB.alive_human_list_faction[faction])
			stat_list[faction].interact(player) //gives the mission brief
	current_mission.load_mission()
	TIMER_COOLDOWN_START(src, COOLDOWN_BIOSCAN, bioscan_interval)

///Checks team balance and tries to correct if possible
/datum/game_mode/hvh/campaign/proc/autobalance_cycle(forced = FALSE)
	var/list/autobalance_faction_list = autobalance_check()
	if(!autobalance_faction_list)
		return

	message_admins("Campaign autobalance run: [autobalance_faction_list ? "[autobalance_faction_list[1]] has [length(GLOB.alive_human_list_faction[autobalance_faction_list[1]])] players, \
	[autobalance_faction_list[2]] has [length(GLOB.alive_human_list_faction[autobalance_faction_list[2]])] players." : "teams balanced."] \
	Forced autobalance is [forced ? "ON." : "OFF."]")

	for(var/mob/living/carbon/human/faction_member in GLOB.alive_human_list_faction[autobalance_faction_list[1]])
		if(stat_list[faction_member.faction].faction_leader == faction_member)
			continue
		INVOKE_ASYNC(src, PROC_REF(swap_player_team), faction_member, autobalance_faction_list[2], forced)

	addtimer(CALLBACK(src, PROC_REF(autobalance_bonus)), CAMPAIGN_AUTOBALANCE_DECISION_TIME + 1 SECONDS)

/** Checks team balance
 * Returns null if teams are nominally balanced
 * Returns a list with the stronger team first if they are inbalanced
 */
/datum/game_mode/hvh/campaign/proc/autobalance_check(ratio = MAX_UNBALANCED_RATIO_TWO_HUMAN_FACTIONS)
	var/team_one_count = length(GLOB.alive_human_list_faction[factions[1]])
	var/team_two_count = length(GLOB.alive_human_list_faction[factions[2]])

	if(team_one_count > team_two_count * ratio)
		return list(factions[1], factions[2])
	else if(team_two_count > team_one_count * ratio)
		return list(factions[2], factions[1])

///Actually swaps the player to the other team, unless balance has been restored
/datum/game_mode/hvh/campaign/proc/swap_player_team(mob/living/carbon/human/user, new_faction, forced = FALSE, fund_bonus = TRUE)
	if(!user.client)
		return
	if(forced)
		to_chat(user, "The teams are currently imbalanced, in favour of your team. Forced autobalance is on, so you may be swapped to the other team.")
	else if(tgui_alert(user, "The teams are currently imbalanced, in favour of your team.", "Join the other team?", list("Stay on team", "Change team"), CAMPAIGN_AUTOBALANCE_DECISION_TIME, FALSE) != "Change team")
		return
	var/list/current_ratio = autobalance_check(1)
	if(!current_ratio || current_ratio[2] == user.faction)
		to_chat(user, span_warning("Team balance already corrected."))
		return
	LAZYREMOVE(GLOB.alive_human_list_faction[user.faction], user)
	user.faction = new_faction //we set this first so the ghost's faction and subsequent job screen is correct, but it means we have to remove from the faction list above first.
	var/mob/dead/observer/ghost = user.ghostize()
	user.job.add_job_positions(1)
	qdel(user)
	var/datum/individual_stats/new_stats = stat_list[new_faction].get_player_stats(ghost)
	if(fund_bonus)
		new_stats.give_funds(max(stat_list[new_faction].accumulated_mission_reward * 0.5, 200)) //Added credits for swapping team
	player_respawn(ghost) //auto open the respawn screen

///buffs the weaker team if players don't voluntarily switch
/datum/game_mode/hvh/campaign/proc/autobalance_bonus()
	var/list/autobalance_faction_list = autobalance_check()
	if(!autobalance_faction_list)
		return

	var/autobal_num = ROUND_UP((length(GLOB.alive_human_list_faction[autobalance_faction_list[1]]) - length(GLOB.alive_human_list_faction[autobalance_faction_list[2]])) * 0.2)
	current_mission.spawn_mech(autobalance_faction_list[2], 0, 0, autobal_num, "[autobal_num] additional mechs granted for autobalance")

///Shuffles the teams forcefully
/datum/game_mode/hvh/campaign/proc/shuffle_teams()
	var/list/player_list = GLOB.player_list.Copy()
	player_list = shuffle(player_list)
	for(var/i = 1 to length(player_list))
		var/mob/player = player_list[i]
		var/new_faction_index = (i % 2) + 1
		var/new_faction = factions[new_faction_index]
		if(player.faction == new_faction)
			continue
		if(ishuman(player))
			swap_player_team(player, new_faction, TRUE, FALSE)
		else
			player.faction = new_faction

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
	player_death_times[player.ckey] = world.time
	respawn_timers[player.ckey] = addtimer(CALLBACK(src, PROC_REF(auto_attempt_respawn), player.ckey), CAMPAIGN_RESPAWN_TIME + stat_list[player.faction]?.respawn_delay_modifier + 1, TIMER_STOPPABLE)

///Auto pops up the respawn window
/datum/game_mode/hvh/campaign/proc/auto_attempt_respawn(respawnee_ckey)
	for(var/mob/player AS in GLOB.player_list)
		if(player.ckey != respawnee_ckey)
			continue
		respawn_timers[respawnee_ckey] = null
		if(isliving(player) && player.stat != DEAD)
			return
		player_respawn(player)
		return

///Handles post mission cleanup
/datum/game_mode/hvh/campaign/proc/end_mission(datum/source)
	SIGNAL_HANDLER
	addtimer(CALLBACK(src, PROC_REF(cut_death_list)), AFTER_MISSION_TELEPORT_DELAY + 1)
	scale_loadouts()

///Limited loadout quantities scale by pop
/datum/game_mode/hvh/campaign/proc/scale_loadouts(pop_override)
	if(!isnum(pop_override))
		pop_override = length(GLOB.clients)
	var/loadout_ratio = clamp((pop_override - CAMPAIGN_LOADOUT_POP_MIN) / (CAMPAIGN_LOADOUT_POP_MAX - CAMPAIGN_LOADOUT_POP_MIN), 0, 1)
	for(var/job in GLOB.campaign_loadout_items_by_role)
		for(var/datum/loadout_item/loadout_item AS in GLOB.campaign_loadout_items_by_role[job])
			if(loadout_item.quantity == -1)
				continue
			loadout_item.quantity = floor(LERP(initial(loadout_item.quantity), initial(loadout_item.quantity) * CAMPAIGN_LOADOUT_MULT_MAX, loadout_ratio))

///cuts the death time and respawn_timers list at mission end
/datum/game_mode/hvh/campaign/proc/cut_death_list(datum/source)
	player_death_times.Cut()
	for(var/ckey in respawn_timers)
		auto_attempt_respawn(ckey) //Faction datum doesn't pop up for ghosts
		deltimer(respawn_timers[ckey])
	respawn_timers.Cut()

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
			if(!candidate?.client)
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
				ready_candidate?.client?.screen?.Cut()
				qdel(ready_candidate)
				return

			var/mob/living/carbon/human/human_current
			if(isobserver(candidate))
				var/mob/dead/observer/observer_candidate = candidate
				if(!isnull(observer_candidate.can_reenter_corpse))
					human_current = observer_candidate.can_reenter_corpse.resolve()
				qdel(candidate)
			else if(ishuman(candidate))
				human_current = candidate
			if(human_current)
				human_current.set_undefibbable(TRUE)


///Actually respawns the player, if still able
/datum/game_mode/hvh/campaign/proc/attrition_respawn(mob/new_player/ready_candidate, datum/job/job_datum)
	if(!ready_candidate.IsJobAvailable(job_datum, TRUE))
		to_chat(usr, span_warning("Selected job is not available."))
		return
	if(!SSticker || SSticker.current_state != GAME_STATE_PLAYING)
		to_chat(usr,span_warning("The round is either not ready, or has already finished!"))
		return
	if(!GLOB.enter_allowed)
		to_chat(usr, span_warning("Spawning currently disabled, please observe."))
		return
	if(!SSjob.AssignRole(ready_candidate, job_datum, TRUE))
		to_chat(usr, span_warning("Failed to assign selected role."))
		return

	if(current_mission.mission_state == MISSION_STATE_ACTIVE)
		if(stat_list[job_datum.faction].active_attrition_points < job_datum.job_cost)
			to_chat(usr, span_warning("Unable to spawn. Insufficient attrition."))
			return
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

	var/datum/action/campaign_overview/overview = new
	overview.give_action(new_member)
