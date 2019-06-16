// these use typepaths to avoid issues caused by mispellings when mapping or job titles changing
/obj/effect/landmark/start/marine
	var/job

/obj/effect/landmark/start/marine/Initialize()
	. = ..()
	if(!GLOB.marine_spawns_by_job[job])
		GLOB.marine_spawns_by_job[job] = list()
	GLOB.marine_spawns_by_job[job] += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/start/marine/captain
	icon_state = "CAP"
	job = /datum/job/command/captain

/obj/effect/landmark/start/marine/fieldcommander
	icon_state = "FC"
	job = /datum/job/command/fieldcommander

/obj/effect/landmark/start/marine/intelligenceofficer
	icon_state = "IO"
	job = /datum/job/command/intelligenceofficer

/obj/effect/landmark/start/marine/pilotofficer
	icon_state = "PO"
	job = /datum/job/command/pilot

/obj/effect/landmark/start/marine/tankcrewman
	icon_state = "TC"
	job = /datum/job/command/tank_crew

/obj/effect/landmark/start/marine/masteratarms
	icon_state = "MAA"
	job = /datum/job/command/masteratarms

/obj/effect/landmark/start/marine/commandmasteratarms
	icon_state = "CMAA"
	job = /datum/job/command/commandmasteratarms

/obj/effect/landmark/start/marine/chiefshipengineer
	icon_state = "CSE"
	job = /datum/job/logistics/engineering

/obj/effect/landmark/start/marine/requisitionsofficer
	icon_state = "RO"
	job = /datum/job/logistics/requisition

/obj/effect/landmark/start/marine/maintenancetech
	icon_state = "SE"
	job = /datum/job/logistics/tech/maint

/obj/effect/landmark/start/marine/cargotechnician
	icon_state = "CT"
	job = /datum/job/logistics/tech/cargo

/obj/effect/landmark/start/marine/cmo
	icon_state = "CMO"
	job = /datum/job/medical/professor

/obj/effect/landmark/start/marine/medicalofficer
	icon_state = "MD"
	job = /datum/job/medical/medicalofficer

/obj/effect/landmark/start/marine/researcher
	icon_state = "MD"
	job = /datum/job/medical/researcher

/obj/effect/landmark/start/marine/corporateliaison
	icon_state = "CL"
	job = /datum/job/civilian/liaison

/obj/effect/landmark/start/marine/synthetic
	icon_state = "Synth"
	job = /datum/job/civilian/synthetic

/obj/effect/landmark/start/marine/squadmarine
	icon_state = "PFC"
	job = /datum/job/marine/standard

/obj/effect/landmark/start/marine/squadengineer
	icon_state = "Eng"
	job = /datum/job/marine/engineer

/obj/effect/landmark/start/marine/squadcorpsman
	icon_state = "HM"
	job = /datum/job/marine/corpsman

/obj/effect/landmark/start/marine/squadsmartgunner
	icon_state = "SGnr"
	job = /datum/job/marine/smartgunner

/obj/effect/landmark/start/marine/squadspecialist
	icon_state = "Spec"
	job = /datum/job/marine/specialist

/obj/effect/landmark/start/marine/squadleader
	icon_state = "SL"
	job = /datum/job/marine/leader
