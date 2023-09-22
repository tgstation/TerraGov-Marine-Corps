/obj/effect/landmark/start/squad
	icon = 'modular_RUtgmc/icons/mob/landmarks.dmi'
	var/title
	var/squad

/obj/effect/landmark/start/squad/Initialize()
	. = ..()
	if(!(squad in GLOB.start_squad_landmarks_list))
		GLOB.start_squad_landmarks_list[squad] = list()
	GLOB.start_squad_landmarks_list[squad][title] += list(loc)

/obj/effect/landmark/start/squad/squadmarine
	icon_state = "marine_spawn"
	title = SQUAD_MARINE

/obj/effect/landmark/start/squad/squadmarine/alpha
	squad = ALPHA_SQUAD
	icon_state = "marine_spawn_alpha"

/obj/effect/landmark/start/squad/squadmarine/bravo
	squad = BRAVO_SQUAD
	icon_state = "marine_spawn_bravo"

/obj/effect/landmark/start/squad/squadmarine/charlie
	squad = CHARLIE_SQUAD
	icon_state = "marine_spawn_charlie"

/obj/effect/landmark/start/squad/squadmarine/delta
	squad = DELTA_SQUAD
	icon_state = "marine_spawn_delta"

/obj/effect/landmark/start/squad/squadengineer
	icon_state = "engi_spawn"
	title = SQUAD_ENGINEER

/obj/effect/landmark/start/squad/squadengineer/alpha
	squad = ALPHA_SQUAD
	icon_state = "engi_spawn_alpha"

/obj/effect/landmark/start/squad/squadengineer/bravo
	squad = BRAVO_SQUAD
	icon_state = "engi_spawn_bravo"

/obj/effect/landmark/start/squad/squadengineer/charlie
	squad = CHARLIE_SQUAD
	icon_state = "engi_spawn_charlie"

/obj/effect/landmark/start/squad/squadengineer/delta
	squad = DELTA_SQUAD
	icon_state = "engi_spawn_delta"

/obj/effect/landmark/start/squad/squadcorpsman
	icon_state = "medic_spawn"
	title = SQUAD_CORPSMAN

/obj/effect/landmark/start/squad/squadcorpsman/alpha
	squad = ALPHA_SQUAD
	icon_state = "medic_spawn_alpha"

/obj/effect/landmark/start/squad/squadcorpsman/bravo
	squad = BRAVO_SQUAD
	icon_state = "medic_spawn_bravo"

/obj/effect/landmark/start/squad/squadcorpsman/charlie
	squad = CHARLIE_SQUAD
	icon_state = "medic_spawn_charlie"

/obj/effect/landmark/start/squad/squadcorpsman/delta
	squad = DELTA_SQUAD
	icon_state = "medic_spawn_delta"

/obj/effect/landmark/start/squad/squadsmartgunner
	icon_state = "smartgunner_spawn"
	title = SQUAD_SMARTGUNNER

/obj/effect/landmark/start/squad/squadsmartgunner/alpha
	squad = ALPHA_SQUAD
	icon_state = "smartgunner_spawn_alpha"

/obj/effect/landmark/start/squad/squadsmartgunner/bravo
	squad = BRAVO_SQUAD
	icon_state = "smartgunner_spawn_bravo"

/obj/effect/landmark/start/squad/squadsmartgunner/charlie
	squad = CHARLIE_SQUAD
	icon_state = "smartgunner_spawn_charlie"

/obj/effect/landmark/start/squad/squadsmartgunner/delta
	squad = DELTA_SQUAD
	icon_state = "smartgunner_spawn_delta"

/obj/effect/landmark/start/squad/squadleader
	icon_state = "leader_spawn"
	title = SQUAD_LEADER

/obj/effect/landmark/start/squad/squadleader/alpha
	squad = ALPHA_SQUAD
	icon_state = "leader_spawn_alpha"

/obj/effect/landmark/start/squad/squadleader/bravo
	squad = BRAVO_SQUAD
	icon_state = "leader_spawn_bravo"

/obj/effect/landmark/start/squad/squadleader/charlie
	squad = CHARLIE_SQUAD
	icon_state = "leader_spawn_charlie"

/obj/effect/landmark/start/squad/squadleader/delta
	squad = DELTA_SQUAD
	icon_state = "leader_spawn_delta"
