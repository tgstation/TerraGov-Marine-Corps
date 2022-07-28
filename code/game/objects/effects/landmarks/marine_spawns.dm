// these use typepaths to avoid issues caused by mispellings when mapping or job titles changing
/atom/movable/effect/landmark/start/job
	var/job

/atom/movable/effect/landmark/start/job/Initialize()
	. = ..()
	GLOB.spawns_by_job[job] += list(loc)

/atom/movable/effect/landmark/start/job/captain
	icon_state = "CAP"
	job = /datum/job/terragov/command/captain

/atom/movable/effect/landmark/start/job/fieldcommander
	icon_state = "FC"
	job = /datum/job/terragov/command/fieldcommander

/atom/movable/effect/landmark/start/job/staffofficer
	icon_state = "IO"
	job = /datum/job/terragov/command/staffofficer

/atom/movable/effect/landmark/start/job/pilotofficer
	icon_state = "PO"
	job = /datum/job/terragov/command/pilot

/atom/movable/effect/landmark/start/job/chiefshipengineer
	icon_state = "CSE"
	job = /datum/job/terragov/engineering/chief

/atom/movable/effect/landmark/start/job/requisitionsofficer
	icon_state = "RO"
	job = /datum/job/terragov/requisitions/officer

/atom/movable/effect/landmark/start/job/shiptech
	icon_state = "SE"
	job = /datum/job/terragov/engineering/tech

/atom/movable/effect/landmark/start/job/cmo
	icon_state = "CMO"
	job = /datum/job/terragov/medical/professor

/atom/movable/effect/landmark/start/job/medicalofficer
	icon_state = "MD"
	job = /datum/job/terragov/medical/medicalofficer

/atom/movable/effect/landmark/start/job/researcher
	icon_state = "MD"
	job = /datum/job/terragov/medical/researcher

/atom/movable/effect/landmark/start/job/corporateliaison
	icon_state = "CL"
	job = /datum/job/terragov/civilian/liaison

/atom/movable/effect/landmark/start/job/synthetic
	icon_state = "Synth"
	job = /datum/job/terragov/silicon/synthetic

/atom/movable/effect/landmark/start/job/squadmarine
	icon_state = "PFC"
	job = /datum/job/terragov/squad/standard

/atom/movable/effect/landmark/start/job/squadengineer
	icon_state = "Eng"
	job = /datum/job/terragov/squad/engineer

/atom/movable/effect/landmark/start/job/squadcorpsman
	icon_state = "HM"
	job = /datum/job/terragov/squad/corpsman

/atom/movable/effect/landmark/start/job/squadsmartgunner
	icon_state = "SGnr"
	job = /datum/job/terragov/squad/smartgunner

/atom/movable/effect/landmark/start/job/squadspecialist
	icon_state = "Spec"
	job = /datum/job/terragov/squad/specialist

/atom/movable/effect/landmark/start/job/squadleader
	icon_state = "SL"
	job = /datum/job/terragov/squad/leader

/atom/movable/effect/landmark/start/job/ai
	icon_state = "AI"
	job = /datum/job/terragov/silicon/ai

/atom/movable/effect/landmark/start/job/captain/rebel
	job = /datum/job/terragov/command/captain/rebel

/atom/movable/effect/landmark/start/job/fieldcommander/rebel
	job = /datum/job/terragov/command/fieldcommander/rebel

/atom/movable/effect/landmark/start/job/staffofficer/rebel
	job = /datum/job/terragov/command/staffofficer/rebel

/atom/movable/effect/landmark/start/job/pilotofficer/rebel
	job = /datum/job/terragov/command/pilot/rebel

/atom/movable/effect/landmark/start/job/chiefshipengineer/rebel
	job = /datum/job/terragov/engineering/chief/rebel

/atom/movable/effect/landmark/start/job/requisitionsofficer/rebel
	job = /datum/job/terragov/requisitions/officer/rebel

/atom/movable/effect/landmark/start/job/shiptech/rebel
	job = /datum/job/terragov/engineering/tech/rebel

/atom/movable/effect/landmark/start/job/cmo/rebel
	job = /datum/job/terragov/medical/professor/rebel

/atom/movable/effect/landmark/start/job/medicalofficer/rebel
	job = /datum/job/terragov/medical/medicalofficer/rebel

/atom/movable/effect/landmark/start/job/researcher/rebel
	job = /datum/job/terragov/medical/researcher/rebel

/atom/movable/effect/landmark/start/job/synthetic/rebel
	job = /datum/job/terragov/silicon/synthetic/rebel

/atom/movable/effect/landmark/start/job/squadmarine/rebel
	job = /datum/job/terragov/squad/standard/rebel

/atom/movable/effect/landmark/start/job/squadengineer/rebel
	job = /datum/job/terragov/squad/engineer/rebel

/atom/movable/effect/landmark/start/job/squadcorpsman/rebel
	job = /datum/job/terragov/squad/corpsman/rebel

/atom/movable/effect/landmark/start/job/squadsmartgunner/rebel
	job = /datum/job/terragov/squad/smartgunner/rebel

/atom/movable/effect/landmark/start/job/squadleader/rebel
	job = /datum/job/terragov/squad/leader/rebel

/atom/movable/effect/landmark/start/job/ai/rebel
	job = /datum/job/terragov/silicon/ai/rebel

/atom/movable/effect/landmark/start/job/survivor
	icon_state = "Shaft Miner"
	job = /datum/job/survivor/rambo

/atom/movable/effect/landmark/start/job/fallen
	job = /datum/job/fallen

/atom/movable/effect/landmark/start/job/xenomorph
	icon_state = "xeno_spawn"
	job = /datum/job/xenomorph

//SOM
/atom/movable/landmark/start/job/som/squadstandard
	icon_state = "PFC"
	job = /datum/job/som/squad/standard

/atom/movable/landmark/start/job/som/squadveteran
	icon_state = "SGnr"
	job = /datum/job/som/squad/veteran

/atom/movable/landmark/start/job/som/squadengineer
	icon_state = "Eng"
	job = /datum/job/som/squad/engineer

/atom/movable/landmark/start/job/som/squadcorpsman
	icon_state = "HM"
	job = /datum/job/som/squad/medic

/atom/movable/landmark/start/job/som/squadleader
	icon_state = "SL"
	job = /datum/job/som/squad/leader
