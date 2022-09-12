// these use typepaths to avoid issues with spawning on different gamemodes.
/obj/effect/landmark/start/job/crash
	delete_after_roundstart = FALSE

/obj/effect/landmark/start/job/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override=FALSE)
	. = ..()
	if(istype(port, /obj/docking_port/mobile/crashmode))
		var/obj/docking_port/mobile/crashmode/C = port
		C.spawnpoints += src
		C.spawns_by_job[job] += list(src)

/obj/effect/landmark/start/job/crash/captain
	icon_state = "CAP"
	job = /datum/job/terragov/command/captain

/obj/effect/landmark/start/job/crash/fieldcommander
	icon_state = "FC"
	job = /datum/job/terragov/command/fieldcommander

/obj/effect/landmark/start/job/crash/staffofficer
	icon_state = "IO"
	job = /datum/job/terragov/command/staffofficer

/obj/effect/landmark/start/job/crash/pilotofficer
	icon_state = "PO"
	job = /datum/job/terragov/command/pilot

/obj/effect/landmark/start/job/crash/chiefshipengineer
	icon_state = "CSE"
	job = /datum/job/terragov/engineering/chief

/obj/effect/landmark/start/job/crash/requisitionsofficer
	icon_state = "RO"
	job = /datum/job/terragov/requisitions/officer

/obj/effect/landmark/start/job/crash/cmo
	icon_state = "CMO"
	job = /datum/job/terragov/medical/professor

/obj/effect/landmark/start/job/crash/medicalofficer
	icon_state = "MD"
	job = /datum/job/terragov/medical/medicalofficer

/obj/effect/landmark/start/job/crash/researcher
	icon_state = "MD"
	job = /datum/job/terragov/medical/researcher

/obj/effect/landmark/start/job/crash/corporateliaison
	icon_state = "CL"
	job = /datum/job/terragov/civilian/liaison

/obj/effect/landmark/start/job/crash/synthetic
	icon_state = "Synth"
	job = /datum/job/terragov/silicon/synthetic

/obj/effect/landmark/start/job/crash/squadmarine
	icon_state = "PFC"
	job = /datum/job/terragov/squad/standard

/obj/effect/landmark/start/job/crash/squadengineer
	icon_state = "Eng"
	job = /datum/job/terragov/squad/engineer

/obj/effect/landmark/start/job/crash/squadcorpsman
	icon_state = "HM"
	job = /datum/job/terragov/squad/corpsman

/obj/effect/landmark/start/job/crash/squadsmartgunner
	icon_state = "SGnr"
	job = /datum/job/terragov/squad/smartgunner

/obj/effect/landmark/start/job/crash/squadspecialist
	icon_state = "Spec"
	job = /datum/job/terragov/squad/specialist

/obj/effect/landmark/start/job/crash/squadleader
	icon_state = "SL"
	job = /datum/job/terragov/squad/leader


// Latejoin markers
/obj/effect/landmark/start/latejoin/crash
	delete_after_roundstart = FALSE


/obj/effect/landmark/start/latejoin/crash/Initialize()
	. = ..()
	return INITIALIZE_HINT_NORMAL


/obj/effect/landmark/start/latejoin/crash/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override=FALSE)
	. = ..()
	if(istype(port, /obj/docking_port/mobile/crashmode))
		var/obj/docking_port/mobile/crashmode/C = port
		C.latejoins += src
