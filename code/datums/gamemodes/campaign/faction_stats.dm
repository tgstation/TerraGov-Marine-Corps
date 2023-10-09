///Default assets a faction starts with
GLOBAL_LIST_INIT(campaign_default_assets, list(
	FACTION_TERRAGOV = list(
		/datum/campaign_reward/mech/light,
		/datum/campaign_reward/bonus_job/freelancer,
		/datum/campaign_reward/bonus_job/pmc,
		/datum/campaign_reward/bonus_job/combat_robots,
		/datum/campaign_reward/fire_support/mortar,
		/datum/campaign_reward/droppod_refresh,
		/datum/campaign_reward/droppod_enabled,
	),
	FACTION_SOM = list(
		/datum/campaign_reward/mech/light/som,
		/datum/campaign_reward/bonus_job/colonial_militia,
		/datum/campaign_reward/bonus_job/icc,
		/datum/campaign_reward/fire_support/som_mortar,
		/datum/campaign_reward/teleporter_charges,
		/datum/campaign_reward/teleporter_enabled,
	),
))
///Default assets a faction can purchase
GLOBAL_LIST_INIT(campaign_default_purchasable_assets, list(
	FACTION_TERRAGOV = list(
		/datum/campaign_reward/fire_support,
		/datum/campaign_reward/fire_support/mortar,
		/datum/campaign_reward/droppod_refresh,
		/datum/campaign_reward/droppod_enabled,
		/datum/campaign_reward/equipment/medkit_basic,
		/datum/campaign_reward/equipment/materials_pack,
		/datum/campaign_reward/equipment/ballistic_tgmc,
		/datum/campaign_reward/equipment/lasers,
		/datum/campaign_reward/equipment/smart_guns,
		/datum/campaign_reward/equipment/shotguns_tgmc,
		/datum/campaign_reward/equipment/scout_rifle,
		/datum/campaign_reward/equipment/heavy_armour_tgmc,
		/datum/campaign_reward/equipment/shields_tgmc,
		/datum/campaign_reward/equipment/grenades_tgmc,
		/datum/campaign_reward/equipment/at_mines,
		/datum/campaign_reward/equipment/tac_bino_tgmc,
	),
	FACTION_SOM = list(
		/datum/campaign_reward/fire_support/som_cas,
		/datum/campaign_reward/fire_support/som_mortar,
		/datum/campaign_reward/teleporter_charges,
		/datum/campaign_reward/teleporter_enabled,
		/datum/campaign_reward/equipment/medkit_basic/som,
		/datum/campaign_reward/equipment/materials_pack,
		/datum/campaign_reward/equipment/ballistic_som,
		/datum/campaign_reward/equipment/shotguns_som,
		/datum/campaign_reward/equipment/volkite,
		/datum/campaign_reward/equipment/heavy_armour_som,
		/datum/campaign_reward/equipment/shields_som,
		/datum/campaign_reward/equipment/grenades_som,
		/datum/campaign_reward/equipment/at_mines,
		/datum/campaign_reward/equipment/tac_bino_som,
	),
))
///The weighted potential mission pool by faction
GLOBAL_LIST_INIT(campaign_mission_pool, list(
	FACTION_TERRAGOV = list(
		/datum/campaign_mission/tdm = 10,
		/datum/campaign_mission/destroy_mission/fire_support_raid = 15,
		/datum/campaign_mission/capture_mission = 15,
		/datum/campaign_mission/tdm/mech_wars = 12,
		/datum/campaign_mission/destroy_mission/supply_raid = 15,
	),
	FACTION_SOM = list(
		/datum/campaign_mission/tdm/lv624 = 10,
		/datum/campaign_mission/destroy_mission/fire_support_raid/som = 15,
		/datum/campaign_mission/capture_mission = 15,
		/datum/campaign_mission/tdm/mech_wars/som = 12,
		/datum/campaign_mission/destroy_mission/supply_raid/som = 15,
	),
))

/datum/faction_stats
	interaction_flags = INTERACT_UI_INTERACT
	///The faction associated with these stats
	var/faction
	///The decision maker for this leader
	var/mob/faction_leader
	///Victory points earned by this faction
	var/victory_points = 0
	///Dictates how many respawns this faction has access to overall
	var/total_attrition_points = 30
	///How many attrition points have been dedicated to the current mission
	var/active_attrition_points = 0
	///Multiplier on the passive attrition point gain for this faction
	var/attrition_gain_multiplier = 1
	///Future missions this faction can currently choose from
	var/list/datum/campaign_mission/available_missions = list()
	///Missions this faction has succesfully completed
	var/list/datum/campaign_mission/finished_missions = list()
	///List of all rewards the faction has earnt this campaign
	var/list/datum/campaign_reward/faction_rewards = list()
	///List of all rewards the faction can currently purchase
	var/list/datum/campaign_reward/purchasable_rewards = list()
	///Any special behavior flags for the faction
	var/stats_flags = NONE
	///Portrait used for general screen text notifications
	var/atom/movable/screen/text/screen_text/picture/faction_portrait

/datum/faction_stats/New(new_faction)
	. = ..()
	faction = new_faction
	GLOB.faction_stats_datums[faction] = src
	for(var/asset in GLOB.campaign_default_assets[faction])
		add_reward(asset)
	for(var/asset in GLOB.campaign_default_purchasable_assets[faction])
		purchasable_rewards += asset
	for(var/i = 1 to CAMPAIGN_STANDARD_MISSION_QUANTITY)
		generate_new_mission()
	RegisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_MISSION_ENDED, PROC_REF(mission_end))

	faction_portrait = GLOB.faction_to_portrait[faction] ? GLOB.faction_to_portrait[faction] : /atom/movable/screen/text/screen_text/picture/potrait/unknown

/datum/faction_stats/Destroy(force, ...)
	GLOB.faction_stats_datums -= faction
	return ..()

///Randomly adds a new mission to the available pool
/datum/faction_stats/proc/generate_new_mission()
	if(!length(GLOB.campaign_mission_pool[faction]) || (length(available_missions) >= CAMPAIGN_STANDARD_MISSION_QUANTITY))
		return
	var/datum/campaign_mission/selected_mission = pickweight(GLOB.campaign_mission_pool[faction])
	add_new_mission(selected_mission)
	GLOB.campaign_mission_pool[faction] -= selected_mission

///Adds a mission to the available mission pool
/datum/faction_stats/proc/add_new_mission(datum/campaign_mission/new_mission)
	available_missions[new_mission] = new new_mission(faction)

///Returns the faction's leader, selecting one if none is available
/datum/faction_stats/proc/get_selector()
	if(!faction_leader || faction_leader.stat != CONSCIOUS || !(faction_leader.client))
		choose_faction_leader()

	return faction_leader

///Elects a new faction leader
/datum/faction_stats/proc/choose_faction_leader()
	faction_leader = null
	var/list/possible_candidates = GLOB.alive_human_list_faction[faction]
	if(!length(possible_candidates))
		return //army of ghosts

	var/list/ranks = GLOB.ranked_jobs_by_faction[faction]
	if(ranks)
		var/list/senior_rank_list = list()
		for(var/senior_rank in ranks)
			for(var/mob/living/carbon/human/candidate AS in possible_candidates)
				if(candidate.job.title != senior_rank)
					continue
				senior_rank_list += candidate
			if(!length(senior_rank_list))
				senior_rank_list.Cut()
				continue
			faction_leader = pick(senior_rank_list)
			break

	if(!faction_leader)
		faction_leader = pick(possible_candidates)


	for(var/mob/living/carbon/human/human AS in possible_candidates)
		human.playsound_local(null, 'sound/effects/CIC_order.ogg', 30, 1)
		human.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:left valign='top'><u>OVERWATCH</u></span><br>" + "[faction_leader] has been promoted to the role of faction commander", faction_portrait)
	to_chat(faction_leader, span_highdanger("You have been promoted to the role of commander for your faction. It is your responsibility to determine your side's course of action, and how to best utilise the resources at your disposal."))

///Adds a new reward to the faction for use
/datum/faction_stats/proc/add_reward(datum/campaign_reward/new_reward)
	if(faction_rewards[new_reward]) //todo: should passive/instant rewards reproc? probably
		var/datum/campaign_reward/existing_reward = faction_rewards[new_reward]
		existing_reward.uses += initial(existing_reward.uses)
		existing_reward.reward_flags &= ~REWARD_CONSUMED
	else
		faction_rewards[new_reward] = new new_reward(src)

///handles post mission wrap up for the faction
/datum/faction_stats/proc/mission_end(datum/source, winning_faction)
	SIGNAL_HANDLER
	if(faction == winning_faction)
		stats_flags |= MISSION_SELECTION_ALLOWED
	else
		stats_flags &= ~MISSION_SELECTION_ALLOWED

	total_attrition_points += round(length(GLOB.clients) * 0.5 * attrition_gain_multiplier)
	generate_new_mission()
	addtimer(CALLBACK(src, PROC_REF(return_to_base)), AFTER_MISSION_TELEPORT_DELAY)
	addtimer(CALLBACK(src, PROC_REF(get_selector)), AFTER_MISSION_LEADER_DELAY) //if the leader died, we load a new one after a bit to give respawns some time

///Returns all faction members back to base after the mission is completed
/datum/faction_stats/proc/return_to_base()
	for(var/mob/living/carbon/human/human_mob AS in GLOB.alive_human_list_faction[faction])
		if(!human_mob.job.job_cost) //asset based roles are one use
			human_mob.ghostize()
			qdel(human_mob)
			continue
		human_mob.revive(TRUE)
		human_mob.overlay_fullscreen_timer(0.5 SECONDS, 10, "roundstart1", /atom/movable/screen/fullscreen/black)
		human_mob.overlay_fullscreen_timer(2 SECONDS, 20, "roundstart2", /atom/movable/screen/fullscreen/spawning_in)
		human_mob.forceMove(pick(GLOB.spawns_by_job[human_mob.job.type]))

///Generates status tab info for the mission
/datum/faction_stats/proc/get_status_tab_items(mob/source, list/items)
	var/datum/game_mode/hvh/campaign/current_mode = SSticker.mode
	if(current_mode?.current_mission.mission_state == MISSION_STATE_ACTIVE)
		if(!active_attrition_points)
			items += "[faction] respawns not available:"
			items += "Attrition expended"
		else
			items += "[faction] respawns available:"
			items += "Attrition remaining: [active_attrition_points]"
	else
		items += "[faction] respawns freely available until next mission starts"
	items += ""

//UI stuff//

/datum/faction_stats/ui_interact(mob/living/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(ui)
		return
	ui = new(user, src, "CampaignMenu")
	ui.open()

/datum/faction_stats/ui_state(mob/user)
	return GLOB.conscious_state

/datum/faction_stats/ui_data(mob/living/user)
	. = ..()
	var/datum/game_mode/hvh/campaign/current_mode = SSticker.mode
	if(!istype(current_mode))
		CRASH("campaign_mission loaded without campaign game mode")

	var/list/data = list()
	var/ui_theme
	switch(faction)
		if(FACTION_SOM)
			ui_theme = "som"
		else
			ui_theme = "ntos"
	data["ui_theme"] = ui_theme

	var/list/current_mission_data = list()
	var/datum/campaign_mission/current_mission = current_mode.current_mission
	current_mission_data["name"] = current_mission.name
	current_mission_data["map_name"] = current_mission.map_name
	current_mission_data["starting_faction"] = current_mission.starting_faction
	current_mission_data["hostile_faction"] = current_mission.hostile_faction
	current_mission_data["winning_faction"] = current_mission.winning_faction
	current_mission_data["outcome"] = current_mission.outcome
	current_mission_data["objective_description"] = (faction == current_mission.starting_faction ? current_mission.starting_faction_objective_description : current_mission.hostile_faction_objective_description)
	current_mission_data["mission_brief"] = (faction == current_mission.starting_faction ? current_mission.starting_faction_mission_brief : current_mission.hostile_faction_mission_brief)
	current_mission_data["mission_rewards"] = (faction == current_mission.starting_faction ? current_mission.starting_faction_additional_rewards : current_mission.hostile_faction_additional_rewards)
	current_mission_data["vp_major_reward"] = (faction == current_mission.starting_faction ? current_mission.victory_point_rewards[MISSION_OUTCOME_MAJOR_VICTORY][1] : current_mission.victory_point_rewards[MISSION_OUTCOME_MAJOR_LOSS][2])
	current_mission_data["vp_minor_reward"] = (faction == current_mission.starting_faction ? current_mission.victory_point_rewards[MISSION_OUTCOME_MINOR_VICTORY][1] : current_mission.victory_point_rewards[MISSION_OUTCOME_MINOR_LOSS][2])
	current_mission_data["ap_major_reward"] = (faction == current_mission.starting_faction ? current_mission.attrition_point_rewards[MISSION_OUTCOME_MAJOR_VICTORY][1] : current_mission.attrition_point_rewards[MISSION_OUTCOME_MAJOR_LOSS][2])
	current_mission_data["ap_minor_reward"] = (faction == current_mission.starting_faction ? current_mission.attrition_point_rewards[MISSION_OUTCOME_MINOR_VICTORY][1] : current_mission.attrition_point_rewards[MISSION_OUTCOME_MINOR_LOSS][2])
	data["current_mission"] = current_mission_data

	var/list/available_missions_data = list()
	for(var/i in available_missions)
		var/datum/campaign_mission/potential_mission = available_missions[i]
		var/list/mission_data = list()
		mission_data["typepath"] = "[potential_mission.type]"
		mission_data["name"] = potential_mission.name
		mission_data["map_name"] = potential_mission.map_name
		mission_data["objective_description"] = potential_mission.starting_faction_objective_description
		mission_data["mission_brief"] = potential_mission.starting_faction_mission_brief
		mission_data["mission_rewards"] = potential_mission.starting_faction_additional_rewards
		mission_data["vp_major_reward"] = (faction == potential_mission.starting_faction ? potential_mission.victory_point_rewards[MISSION_OUTCOME_MAJOR_VICTORY][1] : potential_mission.victory_point_rewards[MISSION_OUTCOME_MAJOR_LOSS][2])
		mission_data["vp_minor_reward"] = (faction == potential_mission.starting_faction ? potential_mission.victory_point_rewards[MISSION_OUTCOME_MINOR_VICTORY][1] : potential_mission.victory_point_rewards[MISSION_OUTCOME_MINOR_LOSS][2])
		mission_data["ap_major_reward"] = (faction == potential_mission.starting_faction ? potential_mission.attrition_point_rewards[MISSION_OUTCOME_MAJOR_VICTORY][1] : potential_mission.attrition_point_rewards[MISSION_OUTCOME_MAJOR_LOSS][2])
		mission_data["ap_minor_reward"] = (faction == potential_mission.starting_faction ? potential_mission.attrition_point_rewards[MISSION_OUTCOME_MINOR_VICTORY][1] : potential_mission.attrition_point_rewards[MISSION_OUTCOME_MINOR_LOSS][2])
		mission_data["mission_icon"] = potential_mission.mission_icon
		mission_data["mission_critical"] = !!(potential_mission.mission_flags & MISSION_CRITICAL)
		available_missions_data += list(mission_data)
	data["available_missions"] = available_missions_data

	var/list/finished_missions_data = list()
	for(var/datum/campaign_mission/finished_mission AS in finished_missions)
		var/list/mission_data = list()
		mission_data["name"] = finished_mission.name
		mission_data["map_name"] = finished_mission.map_name
		mission_data["starting_faction"] = finished_mission.starting_faction
		mission_data["hostile_faction"] = finished_mission.hostile_faction
		mission_data["winning_faction"] = finished_mission.winning_faction
		mission_data["outcome"] = finished_mission.outcome
		mission_data["objective_description"] = (faction == finished_mission.starting_faction ? finished_mission.starting_faction_objective_description : finished_mission.hostile_faction_objective_description)
		mission_data["mission_brief"] = (faction == finished_mission.starting_faction ? finished_mission.starting_faction_mission_brief : finished_mission.hostile_faction_mission_brief)
		mission_data["mission_rewards"] = (faction == finished_mission.starting_faction ? finished_mission.starting_faction_additional_rewards : finished_mission.hostile_faction_additional_rewards)
		finished_missions_data += list(mission_data)
	data["finished_missions"] = finished_missions_data

	var/list/faction_rewards_data = list()
	for(var/i in faction_rewards)
		var/datum/campaign_reward/reward = faction_rewards[i]
		var/list/reward_data = list()
		reward_data["name"] = reward.name
		reward_data["type"] = "[reward.type]"
		reward_data["desc"] = reward.desc
		reward_data["detailed_desc"] = reward.detailed_desc
		reward_data["uses_remaining"] = reward.uses
		reward_data["uses_original"] = initial(reward.uses)
		reward_data["icon"] = (reward.ui_icon)
		reward_data["currently_active"] = !!(reward.reward_flags & REWARD_ACTIVE)
		reward_data["is_debuff"] = !!(reward.reward_flags & REWARD_DEBUFF)
		faction_rewards_data += list(reward_data)
	data["faction_rewards_data"] = faction_rewards_data

	var/list/purchasable_rewards_data = list()
	for(var/datum/campaign_reward/reward AS in purchasable_rewards)
		var/list/reward_data = list()
		reward_data["name"] = initial(reward.name)
		reward_data["type"] = initial(reward)
		reward_data["desc"] = initial(reward.desc)
		reward_data["detailed_desc"] = initial(reward.detailed_desc)
		reward_data["uses_remaining"] = initial(reward.uses)
		reward_data["uses_original"] = initial(reward.uses)
		reward_data["cost"] = initial(reward.cost)
		reward_data["icon"] = initial(reward.ui_icon)
		purchasable_rewards_data += list(reward_data)
	data["purchasable_rewards_data"] = purchasable_rewards_data

	data["active_attrition_points"] = active_attrition_points
	data["total_attrition_points"] = total_attrition_points
	data["faction_leader"] = faction_leader
	data["victory_points"] = victory_points
	data["max_victory_points"] = CAMPAIGN_MAX_VICTORY_POINTS
	data["faction"] = faction
	data["icons"] = GLOB.campaign_icons
	data["mission_icons"] = GLOB.campaign_mission_icons

	return data

/datum/faction_stats/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/datum/game_mode/hvh/campaign/current_mode = SSticker.mode
	if(!istype(current_mode))
		CRASH("campaign_mission loaded without campaign game mode")

	var/mob/living/user = usr

	switch(action)
		if("set_attrition_points")
			if(user != faction_leader)
				to_chat(user, "<span class='warning'>Only your faction's commander can do this.")
				return
			if(current_mode.current_mission?.mission_state != MISSION_STATE_NEW)
				to_chat(user, "<span class='warning'>Current mission already ongoing, unable to assign more personnel at this time.")
				return
			total_attrition_points += active_attrition_points
			active_attrition_points = 0 //reset, you can change your mind up until the mission starts
			var/choice = tgui_input_number(user, "How much manpower would you like to dedicate to this mission?", "Attrition Point selection", 0, total_attrition_points, 0, 60 SECONDS)
			if(!choice)
				choice = 0
			total_attrition_points -= choice
			active_attrition_points = choice
			for(var/mob/living/carbon/human/faction_member AS in GLOB.alive_human_list_faction[faction])
				faction_member.playsound_local(null, 'sound/effects/CIC_order.ogg', 30, 1)
				to_chat(faction_member, "<span class='warning'>[faction_leader] has assigned [choice] attrition points for the next mission.")
			return TRUE

		if("set_next_mission")
			if(user != faction_leader)
				to_chat(user, "<span class='warning'>Only your faction's commander can do this.")
				return
			var/new_mission = text2path(params["new_mission"])
			if(!new_mission)
				return
			if(!available_missions[new_mission])
				return
			var/datum/campaign_mission/choice = available_missions[new_mission]
			if(current_mode.current_mission?.mission_state != MISSION_STATE_FINISHED)
				to_chat(user, "<span class='warning'>Current mission still ongoing!")
				return
			if(!(stats_flags & MISSION_SELECTION_ALLOWED))
				to_chat(user, "<span class='warning'>The opposing side has the initiative, win a mission to regain it.")
				return
			current_mode.load_new_mission(choice)
			available_missions -= new_mission
			return TRUE

		if("activate_reward")
			var/selected_reward = text2path(params["selected_reward"])
			if(!selected_reward)
				return
			if(!faction_rewards[selected_reward])
				return
			var/datum/campaign_reward/choice = faction_rewards[selected_reward]
			if(user != faction_leader)
				if(!(choice.reward_flags & REWARD_SL_AVAILABLE))
					to_chat(user, "<span class='warning'>Only your faction's commander can do this.")
					return
				if(!(ismarineleaderjob(user.job) || issommarineleaderjob(user.job) || ismarinecommandjob(user.job) || issommarinecommandjob(user.job)))
					to_chat(user, "<span class='warning'>Only your faction's leaders can do this.")
					return
			if(!choice.activated_effect())
				return
			for(var/mob/living/carbon/human/faction_member AS in GLOB.alive_human_list_faction[faction])
				faction_member.playsound_local(null, 'sound/effects/CIC_order.ogg', 30, 1)
				faction_member.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:left valign='top'><u>OVERWATCH</u></span><br>" + "[choice.name] asset activated", faction_portrait)
				to_chat(faction_member, "<span class='warning'>[user] has activated the [choice.name] campaign asset.")
			return TRUE

		if("purchase_reward")
			if(user != faction_leader)
				to_chat(user, "<span class='warning'>Only your faction's commander can do this.")
				return
			var/datum/campaign_reward/selected_reward = text2path(params["selected_reward"])
			if(!selected_reward)
				return
			if(!(selected_reward in purchasable_rewards))
				return
			if(initial(selected_reward.cost) > total_attrition_points)
				to_chat(user, "<span class='warning'>[initial(selected_reward.cost) - total_attrition_points] more attrition points required.")
				return
			add_reward(selected_reward)
			total_attrition_points -= initial(selected_reward.cost)
			for(var/mob/living/carbon/human/faction_member AS in GLOB.alive_human_list_faction[faction])
				faction_member.playsound_local(null, 'sound/effects/CIC_order.ogg', 30, 1)
				to_chat(faction_member, "<span class='warning'>[user] has purchased the [initial(selected_reward.name)] campaign asset.")
			return TRUE
