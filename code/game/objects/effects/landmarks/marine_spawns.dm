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
	job = /datum/job/command/captain

/obj/effect/landmark/start/marine/fieldcommander
	job = /datum/job/command/fieldcommander
	
/obj/effect/landmark/start/marine/intelligenceofficer
	job = /datum/job/command/intelligenceofficer
	
/obj/effect/landmark/start/marine/pilotofficer
	job = /datum/job/command/pilot

/obj/effect/landmark/start/marine/tankcrewman
	job = /datum/job/command/tank_crew
	
/obj/effect/landmark/start/marine/masteratarms
	job = /datum/job/command/masteratarms
	
/obj/effect/landmark/start/marine/commandmasteratarms
	job = /datum/job/command/commandmasteratarms

/obj/effect/landmark/start/marine/chiefshipengineer
	job = /datum/job/logistics/engineering
	
/obj/effect/landmark/start/marine/requisitionsofficer
	job = /datum/job/logistics/requisition

/obj/effect/landmark/start/marine/maintenancetech
	job = /datum/job/logistics/tech/maint
	
/obj/effect/landmark/start/marine/cargotechnician
	job = /datum/job/logistics/tech/cargo
	
/obj/effect/landmark/start/marine/cmo
	job = /datum/job/medical/professor
	
/obj/effect/landmark/start/marine/medicalofficer
	job = /datum/job/medical/medicalofficer
	
/obj/effect/landmark/start/marine/researcher
	job = /datum/job/medical/researcher

/obj/effect/landmark/start/marine/corporateliaison
	job = /datum/job/civilian/liaison
	
/obj/effect/landmark/start/marine/synthetic
	job = /datum/job/civilian/synthetic
	
/obj/effect/landmark/start/marine/squadmarine
	job = /datum/job/marine/standard
	
/obj/effect/landmark/start/marine/squadengineer
	job = /datum/job/marine/engineer
		
/obj/effect/landmark/start/marine/squadcorpsman
	job = /datum/job/marine/corpsman
	
/obj/effect/landmark/start/marine/squadsmartgunner
	job = /datum/job/marine/smartgunner

/obj/effect/landmark/start/marine/squadspecialist
	job = /datum/job/marine/specialist

/obj/effect/landmark/start/marine/squadleader
	job = /datum/job/marine/leader
