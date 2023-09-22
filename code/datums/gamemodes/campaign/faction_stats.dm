///Default assets a faction starts with
GLOBAL_LIST_INIT(campaign_default_assets, list(
	FACTION_TERRAGOV = list(
		/datum/campaign_reward/equipment/mech_heavy,
		/datum/campaign_reward/bonus_job/freelancer,
		/datum/campaign_reward/fire_support,
		/datum/campaign_reward/droppod_refresh,
		/datum/campaign_reward/droppod_enabled,
	),
	FACTION_SOM = list(
		/datum/campaign_reward/equipment/mech_heavy,
		/datum/campaign_reward/bonus_job/colonial_militia,
		/datum/campaign_reward/fire_support/som_cas,
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
		/datum/campaign_reward/equipment/power_armor,
		/datum/campaign_reward/bonus_job/combat_robots,
		/datum/campaign_reward/equipment/medkit_basic,
		/datum/campaign_reward/equipment/materials_pack,
	),
	FACTION_SOM = list(
		/datum/campaign_reward/fire_support/som_cas,
		/datum/campaign_reward/fire_support/som_mortar,
		/datum/campaign_reward/teleporter_charges,
		/datum/campaign_reward/teleporter_enabled,
		/datum/campaign_reward/equipment/gorgon_armor,
		/datum/campaign_reward/equipment/medkit_basic,
		/datum/campaign_reward/equipment/materials_pack,
	),
))
///The weighted potential mission pool by faction
GLOBAL_LIST_INIT(campaign_mission_pool, list(
	FACTION_TERRAGOV = list(
		/datum/campaign_mission/tdm = 10,
		/datum/campaign_mission/tdm/lv624= 10,
		/datum/campaign_mission/tdm/desparity= 10,
		/datum/campaign_mission/destroy_mission/fire_support_raid= 10,
		/datum/campaign_mission/capture_mission= 10,
		/datum/campaign_mission/tdm/mech_wars= 10,
	),
	FACTION_SOM = list(
		/datum/campaign_mission/tdm = 10,
		/datum/campaign_mission/tdm/lv624= 10,
		/datum/campaign_mission/tdm/desparity= 10,
		/datum/campaign_mission/destroy_mission/fire_support_raid= 10,
		/datum/campaign_mission/capture_mission= 10,
		/datum/campaign_mission/tdm/mech_wars= 10,
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

/datum/faction_stats/Destroy(force, ...)
	GLOB.faction_stats_datums -= faction
	return ..()

///Randomly adds a new mission to the available pool
/datum/faction_stats/proc/generate_new_mission()
	if(length(available_missions) >= CAMPAIGN_STANDARD_MISSION_QUANTITY)
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
				if(candidate.job.title == senior_rank)
					senior_rank_list += candidate
			if(!length(senior_rank_list))
				senior_rank_list.Cut()
				continue
			faction_leader = pick(senior_rank_list)

	if(!faction_leader)
		faction_leader = pick(possible_candidates)

	//add some sound effect and maybe a map text thing
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
	for(var/mob/living/carbon/human/human_mob AS in GLOB.alive_human_list_faction[faction])
		human_mob.revive(TRUE)
		human_mob.forceMove(pick(GLOB.spawns_by_job[human_mob.job.type]))
		var/obj/item/card/id/user_id = human_mob.get_idcard()
		if(user_id)
			user_id.can_buy_loadout = TRUE //they can buy a new loadout if they want

	addtimer(CALLBACK(src, PROC_REF(get_selector)), AFTER_MISSION_LEADER_DELAY) //if the leader died, we load a new one after a minute to give respawns some time

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

	//complex ones
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
	data["current_mission"] = current_mission_data

	var/list/available_missions_data = list()
	for(var/i in available_missions)
		var/datum/campaign_mission/potential_mission = available_missions[i]
		var/list/mission_data = list() //each relevant bit of info regarding the mission is added to the list. Many more to come
		mission_data["typepath"] = "[potential_mission.type]"
		mission_data["name"] = potential_mission.name
		mission_data["map_name"] = potential_mission.map_name
		mission_data["objective_description"] = potential_mission.starting_faction_objective_description
		mission_data["mission_brief"] = potential_mission.starting_faction_mission_brief
		mission_data["mission_rewards"] = potential_mission.starting_faction_additional_rewards
		available_missions_data += list(mission_data)
	data["available_missions"] = available_missions_data

	var/list/finished_missions_data = list()
	for(var/datum/campaign_mission/finished_mission AS in finished_missions)
		var/list/mission_data = list() //each relevant bit of info regarding the mission is added to the list. Many more to come
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
		var/list/reward_data = list() //each relevant bit of info regarding the reward is added to the list. Many more to come
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

	//simple ones
	data["active_attrition_points"] = active_attrition_points
	data["total_attrition_points"] = total_attrition_points
	data["faction_leader"] = faction_leader
	data["victory_points"] = victory_points
	data["faction"] = faction
	data["icons"] = GLOB.campaign_icons

	return data

/datum/faction_stats/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/datum/game_mode/hvh/campaign/current_mode = SSticker.mode
	if(!istype(current_mode))
		CRASH("campaign_mission loaded without campaign game mode")

	var/mob/user = usr
	if(user != faction_leader)
		to_chat(user, "<span class='warning'>Only your faction's commander can do this.")
		return

	switch(action)
		if("set_attrition_points")
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
			if(!choice.activated_effect())
				return
			for(var/mob/living/carbon/human/faction_member AS in GLOB.alive_human_list_faction[faction])
				faction_member.playsound_local(null, 'sound/effects/CIC_order.ogg', 30, 1)
				to_chat(faction_member, "<span class='warning'>[user] has activated the [choice.name] campaign asset.")
			return TRUE

		if("purchase_reward")
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
