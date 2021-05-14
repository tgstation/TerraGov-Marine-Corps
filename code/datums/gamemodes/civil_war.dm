/datum/game_mode/civil_war/set_valid_squads()
	SSjobs.active_squads[FACTION_TERRAGOV] = list()
	SSjobs.active_squads[FACTION_TERRAGOV_REBEL] = list()
	for(var/key in SSjobs.squads)
		var/datum/squad/squad = SSjobs.squads[key]
		SSjobs.active_squads[squad.faction] += squad
	return TRUE
