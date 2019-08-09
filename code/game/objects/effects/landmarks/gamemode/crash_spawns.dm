// these use typepaths to avoid issues with spawning on different gamemodes.
/obj/effect/landmark/start/marine/crash
	delete_after_roundstart = FALSE

/obj/effect/landmark/start/marine/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override=FALSE)
	. = ..()
	if(istype(port, /obj/docking_port/mobile/crashmode))
		var/obj/docking_port/mobile/crashmode/C = port
		C.spawnpoints += src
		if(!C.marine_spawns_by_job[job])
			C.marine_spawns_by_job[job] = list()
		C.marine_spawns_by_job[job] += src

/obj/effect/landmark/start/marine/crash/captain
	icon_state = "CAP"
	job = /datum/job/command/captain

/obj/effect/landmark/start/marine/crash/fieldcommander
	icon_state = "FC"
	job = /datum/job/command/fieldcommander

/obj/effect/landmark/start/marine/crash/intelligenceofficer
	icon_state = "IO"
	job = /datum/job/command/intelligenceofficer

/obj/effect/landmark/start/marine/crash/pilotofficer
	icon_state = "PO"
	job = /datum/job/command/pilot

/obj/effect/landmark/start/marine/crash/tankcrewman
	icon_state = "TC"
	job = /datum/job/command/tank_crew

/obj/effect/landmark/start/marine/crash/masteratarms
	icon_state = "MAA"
	job = /datum/job/police/officer

/obj/effect/landmark/start/marine/crash/commandmasteratarms
	icon_state = "CMAA"
	job = /datum/job/police/chief

/obj/effect/landmark/start/marine/crash/chiefshipengineer
	icon_state = "CSE"
	job = /datum/job/engineering/chief

/obj/effect/landmark/start/marine/crash/requisitionsofficer
	icon_state = "RO"
	job = /datum/job/requisitions/officer

/obj/effect/landmark/start/marine/crash/maintenancetech
	icon_state = "SE"
	job = /datum/job/engineering/tech

/obj/effect/landmark/start/marine/crash/cargotechnician
	icon_state = "CT"
	job = /datum/job/requisitions/tech

/obj/effect/landmark/start/marine/crash/cmo
	icon_state = "CMO"
	job = /datum/job/medical/professor

/obj/effect/landmark/start/marine/crash/medicalofficer
	icon_state = "MD"
	job = /datum/job/medical/medicalofficer

/obj/effect/landmark/start/marine/crash/researcher
	icon_state = "MD"
	job = /datum/job/medical/researcher

/obj/effect/landmark/start/marine/crash/corporateliaison
	icon_state = "CL"
	job = /datum/job/civilian/liaison

/obj/effect/landmark/start/marine/crash/synthetic
	icon_state = "Synth"
	job = /datum/job/civilian/synthetic

/obj/effect/landmark/start/marine/crash/squadmarine
	icon_state = "PFC"
	job = /datum/job/marine/standard

/obj/effect/landmark/start/marine/crash/squadengineer
	icon_state = "Eng"
	job = /datum/job/marine/engineer

/obj/effect/landmark/start/marine/crash/squadcorpsman
	icon_state = "HM"
	job = /datum/job/marine/corpsman

/obj/effect/landmark/start/marine/crash/squadsmartgunner
	icon_state = "SGnr"
	job = /datum/job/marine/smartgunner

/obj/effect/landmark/start/marine/crash/squadspecialist
	icon_state = "Spec"
	job = /datum/job/marine/specialist

/obj/effect/landmark/start/marine/crash/squadleader
	icon_state = "SL"
	job = /datum/job/marine/leader


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