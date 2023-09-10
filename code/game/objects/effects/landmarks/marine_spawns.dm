// these use typepaths to avoid issues caused by mispellings when mapping or job titles changing
/obj/effect/landmark/start/job
	var/job

/obj/effect/landmark/start/job/Initialize()
	. = ..()
	GLOB.spawns_by_job[job] += list(loc)

/obj/effect/landmark/start/squad
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

/obj/effect/landmark/start/squad/squadmarine/foreign
	squad = FOREIGN_SQUAD
	icon_state = "marine_spawn_foreign"

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

/obj/effect/landmark/start/squad/squadengineer/foreign
	squad = FOREIGN_SQUAD
	icon_state = "engi_spawn_foreign"

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

/obj/effect/landmark/start/squad/squadcorpsman/foreign
	squad = FOREIGN_SQUAD
	icon_state = "medic_spawn_foreign"

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

/obj/effect/landmark/start/squad/squadsmartgunner/foreign
	squad = FOREIGN_SQUAD
	icon_state = "smartgunner_spawn_foreign"

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

/obj/effect/landmark/start/squad/squadleader/foreign
	squad = FOREIGN_SQUAD
	icon_state = "leader_spawn_foreign"

/obj/effect/landmark/start/job/captain
	icon_state = "CAP"
	job = /datum/job/terragov/command/captain

/obj/effect/landmark/start/job/fieldcommander
	icon_state = "FC"
	job = /datum/job/terragov/command/fieldcommander

/obj/effect/landmark/start/job/staffofficer
	icon_state = "IO"
	job = /datum/job/terragov/command/staffofficer

/obj/effect/landmark/start/job/pilotofficer
	icon_state = "PO"
	job = /datum/job/terragov/command/pilot

/obj/effect/landmark/start/job/chiefshipengineer
	icon_state = "CSE"
	job = /datum/job/terragov/engineering/chief

/obj/effect/landmark/start/job/requisitionsofficer
	icon_state = "RO"
	job = /datum/job/terragov/requisitions/officer

/obj/effect/landmark/start/job/mechpilot
	icon_state = "MP"
	job = /datum/job/terragov/command/mech_pilot

/obj/effect/landmark/start/job/shiptech
	icon_state = "SE"
	job = /datum/job/terragov/engineering/tech

/obj/effect/landmark/start/job/cmo
	icon_state = "CMO"
	job = /datum/job/terragov/medical/professor

/obj/effect/landmark/start/job/medicalofficer
	icon_state = "MD"
	job = /datum/job/terragov/medical/medicalofficer

/obj/effect/landmark/start/job/researcher
	icon_state = "Research"
	job = /datum/job/terragov/medical/researcher

/obj/effect/landmark/start/job/corporateliaison
	icon_state = "CL"
	job = /datum/job/terragov/civilian/liaison

/obj/effect/landmark/start/job/synthetic
	icon_state = "Synth"
	job = /datum/job/terragov/silicon/synthetic

/obj/effect/landmark/start/job/squadmarine
	icon_state = "PFC"
	job = /datum/job/terragov/squad/standard

/obj/effect/landmark/start/job/squadengineer
	icon_state = "Eng"
	job = /datum/job/terragov/squad/engineer

/obj/effect/landmark/start/job/squadcorpsman
	icon_state = "HM"
	job = /datum/job/terragov/squad/corpsman

/obj/effect/landmark/start/job/squadsmartgunner
	icon_state = "SGnr"
	job = /datum/job/terragov/squad/smartgunner

/obj/effect/landmark/start/job/squadspecialist
	icon_state = "Spec"
	job = /datum/job/terragov/squad/specialist

/obj/effect/landmark/start/job/squadleader
	icon_state = "SL"
	job = /datum/job/terragov/squad/leader

/obj/effect/landmark/start/job/ai
	icon_state = "AI"
	job = /datum/job/terragov/silicon/ai

/obj/effect/landmark/start/job/captain/rebel
	job = /datum/job/terragov/command/captain/rebel

/obj/effect/landmark/start/job/fieldcommander/rebel
	job = /datum/job/terragov/command/fieldcommander/rebel

/obj/effect/landmark/start/job/staffofficer/rebel
	job = /datum/job/terragov/command/staffofficer/rebel

/obj/effect/landmark/start/job/pilotofficer/rebel
	job = /datum/job/terragov/command/pilot/rebel

/obj/effect/landmark/start/job/chiefshipengineer/rebel
	job = /datum/job/terragov/engineering/chief/rebel

/obj/effect/landmark/start/job/requisitionsofficer/rebel
	job = /datum/job/terragov/requisitions/officer/rebel

/obj/effect/landmark/start/job/shiptech/rebel
	job = /datum/job/terragov/engineering/tech/rebel

/obj/effect/landmark/start/job/cmo/rebel
	job = /datum/job/terragov/medical/professor/rebel

/obj/effect/landmark/start/job/medicalofficer/rebel
	job = /datum/job/terragov/medical/medicalofficer/rebel

/obj/effect/landmark/start/job/researcher/rebel
	job = /datum/job/terragov/medical/researcher/rebel

/obj/effect/landmark/start/job/synthetic/rebel
	job = /datum/job/terragov/silicon/synthetic/rebel

/obj/effect/landmark/start/job/squadmarine/rebel
	job = /datum/job/terragov/squad/standard/rebel

/obj/effect/landmark/start/job/squadengineer/rebel
	job = /datum/job/terragov/squad/engineer/rebel

/obj/effect/landmark/start/job/squadcorpsman/rebel
	job = /datum/job/terragov/squad/corpsman/rebel

/obj/effect/landmark/start/job/squadsmartgunner/rebel
	job = /datum/job/terragov/squad/smartgunner/rebel

/obj/effect/landmark/start/job/squadleader/rebel
	job = /datum/job/terragov/squad/leader/rebel

/obj/effect/landmark/start/job/ai/rebel
	job = /datum/job/terragov/silicon/ai/rebel

/obj/effect/landmark/start/job/survivor
	icon_state = "Shaft Miner"
	job = /datum/job/survivor/rambo

/obj/effect/landmark/start/job/fallen
	job = /datum/job/fallen/marine

/obj/effect/landmark/start/job/fallen/xenomorph
	job = /datum/job/fallen/xenomorph

/obj/effect/landmark/start/job/xenomorph
	icon_state = "xeno_spawn"
	job = /datum/job/xenomorph

//SOM
/obj/effect/landmark/start/job/som/squadstandard
	icon_state = "PFC"
	job = /datum/job/som/squad/standard

/obj/effect/landmark/start/job/som/squadveteran
	icon_state = "SGnr"
	job = /datum/job/som/squad/veteran

/obj/effect/landmark/start/job/som/squadengineer
	icon_state = "Eng"
	job = /datum/job/som/squad/engineer

/obj/effect/landmark/start/job/som/squadcorpsman
	icon_state = "HM"
	job = /datum/job/som/squad/medic

/obj/effect/landmark/start/job/som/squadleader
	icon_state = "SL"
	job = /datum/job/som/squad/leader
