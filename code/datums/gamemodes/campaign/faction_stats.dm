//stats/points/etc recorded by faction
/datum/faction_stats
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
	var/list/datum/campaign_mission/potential_missions = list()
	///Missions this faction has succesfully completed
	var/list/datum/campaign_mission/finished_missions = list()
	///List of all rewards the faction has earnt this campaign
	var/list/datum/campaign_reward/faction_rewards = list()

/datum/faction_stats/New(new_faction)
	. = ..()
	faction = new_faction
	//some testuse rewards
	add_reward(/datum/campaign_reward/equipment/mech_heavy)
	add_reward(/datum/campaign_reward/bonus_job/colonial_militia)
	add_reward(/datum/campaign_reward/teleporter_charges)
	add_reward(/datum/campaign_reward/droppod_refresh)
	add_reward(/datum/campaign_reward/fire_support)
	add_reward(/datum/campaign_reward/teleporter_enabled)
	add_reward(/datum/campaign_reward/droppod_enabled)

	load_default_missions()

///The default available missions for this faction
/datum/faction_stats/proc/load_default_missions()
	var/list/default_missions = list(/datum/campaign_mission/tdm, /datum/campaign_mission/tdm/lv624, /datum/campaign_mission/tdm/desparity) //placeholders todo: make this a var or something so it can be modified by faction
	for(var/new_mission in default_missions)
		add_new_mission(new_mission)

///Adds a mission to the potential mission pool
/datum/faction_stats/proc/add_new_mission(datum/campaign_mission/new_mission)
	potential_missions[new_mission] = new new_mission(faction)

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
