// these use typepaths to avoid issues caused by mispellings when mapping or job titles changing
/obj/effect/landmark/start/marine
	var/job

/obj/effect/landmark/start/marine/Initialize()
	if(!GLOB.marine_spawns_by_job[job])
		GLOB.marine_spawns_by_job[job] = list()
	GLOB.marine_spawns_by_job[job] += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/start/marine/commander
	job = /datum/job/command/commander

/obj/effect/landmark/start/marine/fieldofficer
	job = /datum/job/command/fieldofficer
	
/obj/effect/landmark/start/marine/staffofficer
	job = /datum/job/command/bridge
	
/obj/effect/landmark/start/marine/pilotofficer
	job = /datum/job/command/pilot

/obj/effect/landmark/start/marine/tankcrewman
	job = /datum/job/command/tank_crew
	
/obj/effect/landmark/start/marine/mp
	job = /datum/job/command/police
	
/obj/effect/landmark/start/marine/chiefmp
	job = /datum/job/command/warrant

/obj/effect/landmark/start/marine/chiefengineer
	job = /datum/job/logistics/engineering
	
/obj/effect/landmark/start/marine/requisitionsofficer
	job = /datum/job/logistics/requisition

/obj/effect/landmark/start/marine/maintenancetech
	job = /datum/job/logistics/tech/maint
	
/obj/effect/landmark/start/marine/cargotechnician
	job = /datum/job/logistics/tech/cargo
	
/obj/effect/landmark/start/marine/cmo
	job = /datum/job/medical/professor
	
/obj/effect/landmark/start/marine/doctor
	job = /datum/job/medical/doctor
	
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
		
/obj/effect/landmark/start/marine/squadmedic
	job = /datum/job/marine/medic
	
/obj/effect/landmark/start/marine/squadsmartgunner
	job = /datum/job/marine/smartgunner

/obj/effect/landmark/start/marine/squadspecialist
	job = /datum/job/marine/specialist

/obj/effect/landmark/start/marine/squadleader
	job = /datum/job/marine/leader
