// these use typepaths to avoid issues with spawning on different gamemodes.
/atom/movable/effect/landmark/start/job/crash
	delete_after_roundstart = FALSE

/atom/movable/effect/landmark/start/job/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override=FALSE)
	. = ..()
	if(istype(port, /obj/docking_port/mobile/crashmode))
		var/obj/docking_port/mobile/crashmode/C = port
		C.spawnpoints += src
		C.spawns_by_job[job] += list(src)

/atom/movable/effect/landmark/start/job/crash/captain
	icon_state = "CAP"
	job = /datum/job/terragov/command/captain

/atom/movable/effect/landmark/start/job/crash/fieldcommander
	icon_state = "FC"
	job = /datum/job/terragov/command/fieldcommander

/atom/movable/effect/landmark/start/job/crash/staffofficer
	icon_state = "IO"
	job = /datum/job/terragov/command/staffofficer

/atom/movable/effect/landmark/start/job/crash/pilotofficer
	icon_state = "PO"
	job = /datum/job/terragov/command/pilot

/atom/movable/effect/landmark/start/job/crash/chiefshipengineer
	icon_state = "CSE"
	job = /datum/job/terragov/engineering/chief

/atom/movable/effect/landmark/start/job/crash/requisitionsofficer
	icon_state = "RO"
	job = /datum/job/terragov/requisitions/officer

/atom/movable/effect/landmark/start/job/crash/shiptech
	icon_state = "ST"
	job = /datum/job/terragov/engineering/tech

/atom/movable/effect/landmark/start/job/crash/cmo
	icon_state = "CMO"
	job = /datum/job/terragov/medical/professor

/atom/movable/effect/landmark/start/job/crash/medicalofficer
	icon_state = "MD"
	job = /datum/job/terragov/medical/medicalofficer

/atom/movable/effect/landmark/start/job/crash/researcher
	icon_state = "MD"
	job = /datum/job/terragov/medical/researcher

/atom/movable/effect/landmark/start/job/crash/corporateliaison
	icon_state = "CL"
	job = /datum/job/terragov/civilian/liaison

/atom/movable/effect/landmark/start/job/crash/synthetic
	icon_state = "Synth"
	job = /datum/job/terragov/silicon/synthetic

/atom/movable/effect/landmark/start/job/crash/squadmarine
	icon_state = "PFC"
	job = /datum/job/terragov/squad/standard

/atom/movable/effect/landmark/start/job/crash/squadengineer
	icon_state = "Eng"
	job = /datum/job/terragov/squad/engineer

/atom/movable/effect/landmark/start/job/crash/squadcorpsman
	icon_state = "HM"
	job = /datum/job/terragov/squad/corpsman

/atom/movable/effect/landmark/start/job/crash/squadsmartgunner
	icon_state = "SGnr"
	job = /datum/job/terragov/squad/smartgunner

/atom/movable/effect/landmark/start/job/crash/squadspecialist
	icon_state = "Spec"
	job = /datum/job/terragov/squad/specialist

/atom/movable/effect/landmark/start/job/crash/squadleader
	icon_state = "SL"
	job = /datum/job/terragov/squad/leader


// Latejoin markers
/atom/movable/effect/landmark/start/latejoin/crash
	delete_after_roundstart = FALSE


/atom/movable/effect/landmark/start/latejoin/crash/Initialize()
	. = ..()
	return INITIALIZE_HINT_NORMAL


/atom/movable/effect/landmark/start/latejoin/crash/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override=FALSE)
	. = ..()
	if(istype(port, /obj/docking_port/mobile/crashmode))
		var/obj/docking_port/mobile/crashmode/C = port
		C.latejoins += src
