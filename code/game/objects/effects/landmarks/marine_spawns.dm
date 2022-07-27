// these use typepaths to avoid issues caused by mispellings when mapping or job titles changing
/obj/effect/landmark/start/job
	var/job

/obj/effect/landmark/start/job/Initialize()
	. = ..()
	GLOB.spawns_by_job[job] += list(loc)

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
	icon_state = "MD"
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

/obj/effect/landmark/start/job/fallen
	job = /datum/job/fallen

/obj/effect/landmark/start/job/xenomorph
	icon_state = "xeno_spawn"
	job = /datum/job/xenomorph

/obj/effect/landmark/start/job/survivor/Initialize()
	. = ..()
	GLOB.survivor_spawn += src

/obj/effect/landmark/start/job/survivor/Destroy()
	GLOB.survivor_spawn -= src
	return ..()

/obj/effect/landmark/start/job/survivor/scientist
	icon_state = "Scientist"
	job = /datum/job/survivor/scientist

/obj/effect/landmark/start/job/survivor/doctor
	icon_state = "Medical Doctor"
	job = /datum/job/survivor/doctor

/obj/effect/landmark/start/job/survivor/liaison
	icon_state = "Lawyer"
	job = /datum/job/survivor/liaison

/obj/effect/landmark/start/job/survivor/civilian
	icon_state = "Assistant"
	job = /datum/job/survivor/civilian

/obj/effect/landmark/start/job/survivor/chef
	icon_state = "Cook"
	job = /datum/job/survivor/chef

/obj/effect/landmark/start/job/survivor/botanist
	icon_state = "Botanist"
	job = /datum/job/survivor/botanist

/obj/effect/landmark/start/job/survivor/atmos
	icon_state = "Atmospheric Technician"
	job = /datum/job/survivor/atmos

/obj/effect/landmark/start/job/survivor/engineer
	icon_state = "Station Engineer"
	job = /datum/job/survivor/engineer

/obj/effect/landmark/start/job/survivor/chaplain
	icon_state = "Chaplain"
	job = /datum/job/survivor/chaplain

/obj/effect/landmark/start/job/survivor/miner
	icon_state = "Shaft Miner"
	job = /datum/job/survivor/miner

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
