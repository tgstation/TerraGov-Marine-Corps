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
	var/list/datum/campaign_mission/potential_missions = list(/datum/campaign_mission/tdm, /datum/campaign_mission/tdm/lv624, /datum/campaign_mission/tdm/desparity) //placeholders
	///Missions this faction has succesfully completed
	var/list/datum/campaign_mission/finished_missions = list()
	///List of all rewards the faction has earnt this campaign
	var/list/datum/campaign_reward/faction_rewards = list()

/datum/faction_stats/New(new_faction)
	. = ..()
	faction = new_faction
	add_reward(/datum/campaign_reward/equipment/mech_heavy) //testuse
	add_reward(/datum/campaign_reward/bonus_job/colonial_militia) //testuse
	add_reward(/datum/campaign_reward/teleporter_charges) //testuse
	add_reward(/datum/campaign_reward/droppod_refresh) //testuse
	add_reward(/datum/campaign_reward/cas_support) //testuse

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
	faction_rewards += new new_reward(src)
