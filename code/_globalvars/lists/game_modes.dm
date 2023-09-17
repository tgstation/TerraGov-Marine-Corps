///List of all faction_stats datums, by faction
GLOBAL_LIST_EMPTY(faction_stats_datums)

///jobs by faction, ranked by seniority
GLOBAL_LIST_INIT(ranked_jobs_by_faction, list(
	FACTION_TERRAGOV = list(CAPTAIN, FIELD_COMMANDER, SQUAD_LEADER),
	FACTION_SOM = list(SOM_SQUAD_LEADER, SOM_SQUAD_VETERAN), //Add new roles
))
