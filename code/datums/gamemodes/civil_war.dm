/datum/game_mode/civil_war

/datum/game_mode/civil_war/set_valid_squads()
	SSjob.active_squads[FACTION_TERRAGOV] = list()
	SSjob.active_squads[FACTION_TERRAGOV_REBEL] = list()
	for(var/key in SSjob.squads)
		var/datum/squad/squad = SSjob.squads[key]
		SSjob.active_squads[squad.faction] += squad
	return TRUE
