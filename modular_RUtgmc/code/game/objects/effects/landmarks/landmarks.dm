/obj/effect/landmark/start/latejoin_squad
	icon = 'modular_RUtgmc/icons/mob/landmarks.dmi'
	icon_state = "marine_spawn_late"
	var/squad

/obj/effect/landmark/start/latejoin_squad/Initialize()
	. = ..()
	if(!(squad in GLOB.latejoin_squad_landmarks_list))
		GLOB.latejoin_squad_landmarks_list[squad] = list()
	GLOB.latejoin_squad_landmarks_list[squad] += loc

/obj/effect/landmark/start/latejoin_squad/alpha
	icon_state = "marine_spawn_alpha_late"
	squad = ALPHA_SQUAD

/obj/effect/landmark/start/latejoin_squad/bravo
	icon_state = "marine_spawn_bravo_late"
	squad = BRAVO_SQUAD

/obj/effect/landmark/start/latejoin_squad/charlie
	icon_state = "marine_spawn_charlie_late"
	squad = CHARLIE_SQUAD

/obj/effect/landmark/start/latejoin_squad/delta
	icon_state = "marine_spawn_delta_late"
	squad = DELTA_SQUAD
