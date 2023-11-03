///List of all faction_stats datums, by faction
GLOBAL_LIST_EMPTY(faction_stats_datums)

///jobs by faction, ranked by seniority
GLOBAL_LIST_INIT(ranked_jobs_by_faction, list(
	FACTION_TERRAGOV = list(CAPTAIN, FIELD_COMMANDER, STAFF_OFFICER, SQUAD_LEADER),
	FACTION_SOM = list(SOM_COMMANDER, SOM_FIELD_COMMANDER, SOM_STAFF_OFFICER, SOM_SQUAD_LEADER, SOM_SQUAD_VETERAN),
))
