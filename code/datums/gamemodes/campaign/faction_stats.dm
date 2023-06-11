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
	///How many attrition points have been dedicated to the current round
	var/active_attrition_points = 0
	///Future rounds this faction can currently choose from
	var/list/datum/game_round/potential_rounds = list(/datum/game_round/tdm, /datum/game_round/tdm/lv624, /datum/game_round/tdm/desparity) //placeholders
	///Rounds this faction has succesfully completed
	var/list/datum/game_round/finished_rounds = list()
	//probs add persistant rewards here as well

/datum/faction_stats/New(new_faction)
	. = ..()
	faction = new_faction

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
