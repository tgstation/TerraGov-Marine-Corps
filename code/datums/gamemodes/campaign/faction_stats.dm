//stats/points/etc recorded by faction
/datum/faction_stats
	///The faction associated with these stats
	var/faction
	///The decision maker for this leader
	var/mob/faction_leader
	///Victory points earned by this faction
	var/victory_points = 0
	///Dictates how many respawns this faction has access to overall
	var/attrition_points = 30
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
	faction_leader = pick(GLOB.alive_human_list_faction[faction]) //placeholder rng pick for now
