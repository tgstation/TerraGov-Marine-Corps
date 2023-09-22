/datum/job/terragov/squad/proc/spawn_by_squads(squad)
	if(!(title in GLOB.start_squad_landmarks_list[squad]))
		return pick(GLOB.start_squad_landmarks_list[squad][SQUAD_MARINE])
	return pick(GLOB.start_squad_landmarks_list[squad][title])
